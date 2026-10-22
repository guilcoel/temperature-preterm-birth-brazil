"""Funções comuns: log, download com retry, checksum, DBC -> parquet, integridade."""
from __future__ import annotations

import csv
import datetime as dt
import hashlib
import logging
import os
import re
import shutil
import sys
import tempfile
import time
import urllib.error
import urllib.request
from pathlib import Path
from typing import Iterable

import config as C

# --------------------------------------------------------------------------
# Log
# --------------------------------------------------------------------------

def get_logger(nome: str) -> logging.Logger:
    C.LOGS.mkdir(parents=True, exist_ok=True)
    stamp = dt.datetime.now().strftime("%Y%m%d_%H%M%S")
    log = logging.getLogger(nome)
    if log.handlers:
        return log
    log.setLevel(logging.INFO)
    fmt = logging.Formatter("%(asctime)s | %(levelname)s | %(message)s", "%Y-%m-%d %H:%M:%S")
    fh = logging.FileHandler(C.LOGS / f"{nome}_{stamp}.log", encoding="utf-8")
    fh.setFormatter(fmt)
    sh = logging.StreamHandler(sys.stdout)
    sh.setFormatter(fmt)
    log.addHandler(fh)
    log.addHandler(sh)
    log.info("ROOT = %s", C.ROOT)
    return log


def agora() -> str:
    return dt.datetime.now().astimezone().isoformat(timespec="seconds")


# --------------------------------------------------------------------------
# Checksum
# --------------------------------------------------------------------------

def md5(path: Path, bloco: int = 1 << 20) -> str:
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(bloco), b""):
            h.update(chunk)
    return h.hexdigest()


# --------------------------------------------------------------------------
# Download
# --------------------------------------------------------------------------

def baixar(url: str, destino: Path, log: logging.Logger, tentativas: int = 4,
           timeout: int = 180) -> bool:
    """Baixa url -> destino. Retorna True se gravou; False se 404/550 (não existe).

    Grava em .part e renomeia. A Forja não é APFS: depois do rename, confere se o
    arquivo existe e tem o tamanho esperado antes de seguir.
    """
    destino.parent.mkdir(parents=True, exist_ok=True)
    tmp = destino.with_suffix(destino.suffix + ".part")
    for k in range(1, tentativas + 1):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (pesquisa academica UNICAMP)"})
            with urllib.request.urlopen(req, timeout=timeout) as r, open(tmp, "wb") as f:
                esperado = r.headers.get("Content-length")
                shutil.copyfileobj(r, f, length=1 << 20)
            tamanho = tmp.stat().st_size
            if tamanho == 0:
                raise IOError("arquivo vazio")
            # urllib engole erro de fim de transferência FTP: confere o tamanho anunciado
            if esperado is not None and int(esperado) != tamanho:
                raise IOError(f"download truncado ({tamanho} de {esperado} bytes)")
            os.replace(tmp, destino)
            if not destino.exists() or destino.stat().st_size != tamanho:
                raise IOError("rename não confirmou o arquivo (disco não-APFS?)")
            return True
        except urllib.error.HTTPError as e:
            if e.code == 404:
                return False
            log.warning("HTTP %s em %s (tentativa %d)", e.code, url, k)
        except urllib.error.URLError as e:
            msg = str(e.reason)
            if "550" in msg or "No such file" in msg or "not found" in msg.lower():
                return False
            log.warning("URLError %s em %s (tentativa %d)", msg, url, k)
        except Exception as e:  # noqa: BLE001
            log.warning("%s em %s (tentativa %d)", e, url, k)
        if tmp.exists():
            tmp.unlink()
        time.sleep(5 * k)
    raise RuntimeError(f"Falhou após {tentativas} tentativas: {url}")


def baixar_primeiro_disponivel(nome: str, dirs: dict[str, str], destino_dir: Path,
                               log: logging.Logger, checar_definitivo: bool = False
                               ) -> tuple[Path, str, str] | None:
    """Tenta cada diretório (ordem = prioridade) e as grafias .dbc/.DBC.

    Retorna (caminho_local, status, url) ou None se não existir em lugar nenhum.
    Reaproveita o cache local; se o cache for 'preliminar' e checar_definitivo=True,
    tenta antes o diretório definitivo (o preliminar antigo fica guardado).
    """
    ordem = list(dirs)
    for status in ordem:
        local = destino_dir / f"{nome}__{status}.dbc"
        if local.exists() and local.stat().st_size > 0:
            if status == ordem[0] or not checar_definitivo:
                return local, status, "(cache local)"
            base = dirs[ordem[0]]
            try:
                for ext in (".dbc", ".DBC"):
                    novo = destino_dir / f"{nome}__{ordem[0]}.dbc"
                    if baixar(f"{base}/{nome}{ext}", novo, log):
                        log.info("ATUALIZADO para %s: %s", ordem[0], nome)
                        return novo, ordem[0], f"{base}/{nome}{ext}"
            except RuntimeError as e:
                log.warning("não consegui checar versão %s de %s (%s); usando cache %s",
                            ordem[0], nome, e, status)
            return local, status, "(cache local)"
    for status, base in dirs.items():
        for ext in (".dbc", ".DBC"):
            url = f"{base}/{nome}{ext}"
            local = destino_dir / f"{nome}__{status}.dbc"
            if baixar(url, local, log):
                log.info("OK %s  [%s]  %s", nome, status, url)
                return local, status, url
    return None


# --------------------------------------------------------------------------
# DBC -> parquet (em lotes, para não estourar RAM)
# --------------------------------------------------------------------------

def dbc_para_parquet(dbc: Path, saida: Path, extras: dict[str, str], lote: int = 200_000) -> dict:
    """Descomprime o .dbc (datasus-dbc), lê o .dbf (dbfread) e grava parquet.

    Todas as colunas como texto (é o formato original do DATASUS; zeros à
    esquerda de códigos são preservados). Colunas `extras` são constantes
    acrescentadas (arquivo de origem, status, UF).
    Retorna dict com n_linhas, n_colunas, colunas.
    """
    import datasus_dbc
    import pyarrow as pa
    import pyarrow.parquet as pq
    from dbfread import DBF

    saida.parent.mkdir(parents=True, exist_ok=True)
    C.TMP.mkdir(parents=True, exist_ok=True)
    # microdado não sai da Forja; o PID no nome separa resto de execução morta de rodada paralela viva
    tmpdir = Path(tempfile.mkdtemp(prefix=f"dbc_{os.getpid()}_", dir=C.TMP))
    try:
        dbf = tmpdir / (dbc.stem + ".dbf")
        datasus_dbc.decompress(str(dbc), str(dbf))
        # raw=True: lê os bytes crus de TODO campo (inclusive N/F/D, se houver) e
        # decodifica como texto -> preserva zeros à esquerda e o formato original.
        tabela = DBF(str(dbf), encoding="latin-1", char_decode_errors="replace", load=False, raw=True)
        campos = list(tabela.field_names)
        tipos = {f.name: f.type for f in tabela.fields}
        colunas = campos + list(extras)
        schema = pa.schema([(c, pa.string()) for c in colunas])
        tmp_out = saida.with_suffix(".parquet.part")
        writer = pq.ParquetWriter(tmp_out, schema, compression="zstd")
        n = 0
        buf: dict[str, list] = {c: [] for c in campos}

        def flush():
            nonlocal buf
            if not buf[campos[0]]:
                return
            m = len(buf[campos[0]])
            arrays = [pa.array(buf[c], type=pa.string()) for c in campos]
            arrays += [pa.array([v] * m, type=pa.string()) for v in extras.values()]
            writer.write_table(pa.Table.from_arrays(arrays, schema=schema))
            buf = {c: [] for c in campos}

        for rec in tabela:
            for c in campos:
                v = rec[c]
                if v is None:
                    buf[c].append(None)
                else:
                    s = (v.decode("latin-1", "replace") if isinstance(v, bytes) else str(v)).strip()
                    buf[c].append(s if s != "" else None)
            n += 1
            if n % lote == 0:
                flush()
        flush()
        writer.close()
        os.replace(tmp_out, saida)
        nao_texto = {k: t for k, t in tipos.items() if t != "C"}
        # o cabeçalho conta também os registros marcados como deletados ('*'), que o dbfread
        # não itera (auditoria R3): truncamento é cabeçalho != lidas + deletados
        return {"n_linhas": n, "n_colunas": len(colunas), "colunas": campos,
                "n_registros_cabecalho": tabela.header.numrecords,
                "n_registros_deletados": len(tabela.deleted), "campos_nao_texto": nao_texto}
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


# --------------------------------------------------------------------------
# Integridade
# --------------------------------------------------------------------------
CAMPOS_INTEGRIDADE = [
    "data_hora", "sistema", "ano", "uf", "arquivo", "status", "url", "bytes",
    "md5_origem", "md5_parquet", "n_linhas", "n_colunas", "n_municipios",
    "pct_mun_invalido", "observacao",
]


def registrar_integridade(linhas: Iterable[dict]) -> None:
    """Acrescenta linhas ao logs/integridade.csv (cria cabeçalho se novo)."""
    C.LOGS.mkdir(parents=True, exist_ok=True)
    novo = not C.INTEGRIDADE_CSV.exists()
    with open(C.INTEGRIDADE_CSV, "a", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=CAMPOS_INTEGRIDADE, extrasaction="ignore")
        if novo:
            w.writeheader()
        for l in linhas:
            l.setdefault("data_hora", agora())
            w.writerow(l)


def ultima_observacao(sistema: str, ano, uf: str, md5_parquet: str) -> str:
    """Última observação não vazia já registrada para o MESMO parquet (mesmo md5).

    A reauditoria não reconverte o .dbc, então não sabe dos avisos da conversão
    (cabeçalho DBF != lidas, campos não-texto); sem isto eles sumiriam (auditoria A2).
    """
    if not C.INTEGRIDADE_CSV.exists():
        return ""
    obs = ""
    with open(C.INTEGRIDADE_CSV, newline="", encoding="utf-8") as f:
        for l in csv.DictReader(f):
            if ((l["sistema"], l["ano"], l["uf"], l["md5_parquet"]) == (sistema, str(ano), uf, md5_parquet)
                    and l["observacao"]):
                obs = l["observacao"]
    return obs


# --------------------------------------------------------------------------
# Proveniência (auditoria da última etapa, B8 e B9): md5 de cada saída e dos insumos, gravados na geração
# --------------------------------------------------------------------------
CAMPOS_PROVENIENCIA = ["data_hora", "execucao", "saida", "md5_saida", "insumo", "md5_insumo"]


def proveniencia_csv() -> Path:
    return C.LOGS / "proveniencia.csv"


def md5_insumo(ref: str) -> str:
    """md5 de um insumo:
    - "integridade:SISTEMA": md5 da lista ordenada "arquivo:md5" da última linha de cada arquivo do sistema no
      integridade.csv (insumos brutos já auditados no download; não relê gigabytes);
    - "meta:/caminho": md5 de "tamanho:mtime_ns" (arquivo grande fora da base; só o aceite da fase 1 usa);
    - caminho relativo à raiz (ou absoluto): md5 do arquivo; se for pasta, da lista ordenada "nome:md5"."""
    if ref.startswith("integridade:"):
        sist, ult = ref.split(":", 1)[1], {}
        with open(C.INTEGRIDADE_CSV, newline="", encoding="utf-8") as f:
            for l in csv.DictReader(f):
                if l["sistema"] == sist:
                    ult[l["arquivo"]] = l["md5_parquet"] or l["md5_origem"]
        if not ult:
            raise ValueError(f"insumo {ref}: sistema sem linha no integridade.csv")
        return hashlib.md5("\n".join(f"{k}:{v}" for k, v in sorted(ult.items())).encode()).hexdigest()
    if ref.startswith("meta:"):
        st = Path(ref[5:]).stat()
        return hashlib.md5(f"{st.st_size}:{st.st_mtime_ns}".encode()).hexdigest()
    p = Path(ref) if ref.startswith("/") else C.ROOT / ref
    if p.is_dir():
        arqs = sorted(q for q in p.rglob("*") if q.is_file() and not q.name.startswith("._"))
        return hashlib.md5("\n".join(f"{q.relative_to(p)}:{md5(q)}" for q in arqs).encode()).hexdigest()
    return md5(p)


def codigo(script: str) -> list[str]:
    """Insumos de código de um script do 00_scripts que importa config e utils."""
    return [f"00_scripts/{Path(script).name}", "00_scripts/config.py", "00_scripts/utils.py"]


def registrar_proveniencia(saidas: Iterable[Path], insumos: list[str], script: str) -> None:
    """Uma linha por saída × insumo no logs/proveniencia.csv (só acréscimo). Chamar só na execução do projeto
    (nunca no --rascunho), depois que as saídas estão gravadas. O 08 confere estes md5 contra o disco."""
    C.LOGS.mkdir(parents=True, exist_ok=True)
    execucao = f"{Path(script).name}@{agora()}#{os.getpid()}-{time.time_ns()}"   # único, mesmo no mesmo segundo
    m_ins = {r: md5_insumo(r) for r in dict.fromkeys(insumos)}
    novo = not proveniencia_csv().exists()
    with open(proveniencia_csv(), "a", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=CAMPOS_PROVENIENCIA)
        if novo:
            w.writeheader()
        for s in saidas:
            s = Path(s)
            rel, m_s = str(s.resolve().relative_to(C.ROOT.resolve())), md5(s)
            for r, m_i in m_ins.items():
                w.writerow({"data_hora": agora(), "execucao": execucao, "saida": rel, "md5_saida": m_s,
                            "insumo": r, "md5_insumo": m_i})


def ultima_proveniencia(saidas: set[str]) -> dict[str, list[dict]]:
    """{saída: linhas da última execução que a gravou} (as linhas de uma execução são contíguas)."""
    ult: dict[str, list[dict]] = {}
    if not proveniencia_csv().exists():
        return ult
    with open(proveniencia_csv(), newline="", encoding="utf-8") as f:
        for l in csv.DictReader(f):
            if l["saida"] in saidas:
                if not ult.get(l["saida"]) or ult[l["saida"]][0]["execucao"] != l["execucao"]:
                    ult[l["saida"]] = []
                ult[l["saida"]].append(l)
    return ult


def _pid_vivo(pid: int) -> bool:
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    return True


def tmp_restos() -> list[Path]:
    """Pastas dbc_<pid>_* deixadas em C.TMP por execução interrompida (só lista).

    Pasta de OUTRO processo ainda vivo (rodada em paralelo) não conta; a do próprio
    processo e nome sem PID (formato antigo) contam como resto. Limitação: um PID
    reciclado por outro programa esconde um resto antigo até esse programa terminar.
    """
    if not C.TMP.exists():
        return []
    restos = []
    for p in sorted(C.TMP.glob("dbc_*")):
        if not p.is_dir():
            continue
        m = re.match(r"dbc_(\d+)_", p.name)
        pid = int(m.group(1)) if m else None
        # a pasta do PRÓPRIO processo também conta: no fim do lote ela já deveria ter
        # sido apagada; se sobrou, o rmtree falhou (auditoria C3)
        if pid is None or pid == os.getpid() or not _pid_vivo(pid):
            restos.append(p)
    return restos


def resumo_municipios(parquet: Path, col: str = "CODMUNRES") -> tuple[int, float]:
    """Nº de códigos distintos de município e % de códigos inválidos.

    Inválido = vazio, não-numérico, tamanho != 6, ou terminado em '0000'
    (código de UF com município ignorado, ex.: 350000).
    """
    import polars as pl

    lf = pl.scan_parquet(parquet).select(pl.col(col).alias("m"))
    r = lf.select(
        pl.col("m").n_unique().alias("n"),
        (
            pl.col("m").is_null()
            | ~pl.col("m").str.contains(r"^\d{6}$")
            | pl.col("m").str.ends_with("0000")
        ).mean().alias("inv"),
    ).collect()
    return int(r["n"][0]), round(float(r["inv"][0]) * 100, 4)


def completude(parquet: Path, variaveis: list[str]) -> list[dict]:
    """% vazio de cada variável-chave (ausente no arquivo = 100 e flag)."""
    import polars as pl

    lf = pl.scan_parquet(parquet)
    cols = lf.collect_schema().names()
    presentes = [v for v in variaveis if v in cols]
    out = []
    if presentes:
        r = lf.select([pl.col(v).is_null().mean().alias(v) for v in presentes]).collect()
        for v in presentes:
            out.append({"variavel": v, "presente": 1, "pct_vazio": round(float(r[v][0]) * 100, 3)})
    for v in variaveis:
        if v not in cols:
            out.append({"variavel": v, "presente": 0, "pct_vazio": 100.0})
    return out


def gravar_completude(nome: str, linhas: list[dict]) -> None:
    caminho = C.LOGS / f"completude_{nome}.csv"
    novo = not caminho.exists()
    with open(caminho, "a", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["data_hora", "ano", "uf", "variavel", "presente", "pct_vazio"])
        if novo:
            w.writeheader()
        for l in linhas:
            l.setdefault("data_hora", agora())
            w.writerow(l)
