"""Não regressão da versão com `ig_dum_sem` contra a 7e99bf94 (pedido de 08/10/2026, item 5). Lê microdado na Forja;
imprime e grava em log só contagens, nomes de coluna e hashes. Diferença sai como nº de linhas por coluna, nunca valor.

Fase `pre` (ANTES de trocar a versão ativa; ORIGEM = rascunho do 06b, padrão _tmp/rascunho_06b):
 1. o manifesto 7e99bf94 sai do git (commit 9f1957b), e a versão é recalculada a partir da lista dele;
 2. os arquivos da 7e99bf94 no disco têm o md5 do manifesto (nada foi trocado ainda);
 3. saídas do 06b, rascunho × ativas: óbitos, as duas séries e os 5 logs agregados com md5 idêntico; no nascimentos,
    o mesmo nº de linhas, as colunas antigas na mesma ordem e com o mesmo tipo, cada uma idêntica (NA no mesmo lugar)
    e com o mesmo hash por coluna, e uma só coluna a mais, `ig_dum_sem` (int16), no fim;
 4. versão prevista = lista caminho:md5 da 7e99bf94 com o md5 do nascimentos do rascunho;
 5. 99 simulado: o 99_relatorio_integridade roda numa cópia do integridade.csv acrescida das linhas que a troca vai
    gravar (06b, 06d, 06c, 07b) e numa cópia do README, em _tmp/; o bloco automático é comparado com o da 7e99bf94;
 6. raiz de conferência em _tmp/raiz_ig_dum_sem/ (nascimentos do rascunho, pig ativo, referências do PIG e manifesto
    próprio), para a paridade R × Python pela interface antes da troca (paridade_ig_dum_sem.py e .R com
    DADOS_PERINATAIS_CLIMA_RAIZ) e para o 07b --rascunho sobre o nascimentos novo.
Fase `regen` (ANTES da troca, depois de rodar `06d --rascunho`, `06c --rascunho` e, com a raiz de conferência como
diretório de trabalho, `07b --rascunho`): as 19 saídas do 06c (15), 06d (1) e 07b (3) regeradas têm o md5 da 7e99bf94. Sem isso,
o 99 simulado e a versão prevista só supõem que regravar não muda nada (auditoria independente de 08/10, achado 3).
Fase `pos` (DEPOIS da troca, do 99 e do 08): manifesto novo × 7e99bf94 (mesmos arquivos e nº de linhas; md5 igual em
todos fora o nascimentos; colunas do nascimentos = antigas + ig_dum_sem); versão recalculada do disco; nascimentos
ativo = o do rascunho conferido na fase pre; bloco do 99 no README × o da 7e99bf94 e × o simulado. Falha se a fase
pre não tiver deixado o previsto.json e o 99 simulado.

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/nao_regressao_ig_dum_sem.py pre
    PYTHONPATH=. uv run python testes/nao_regressao_ig_dum_sem.py regen
    PYTHONPATH=. uv run python testes/nao_regressao_ig_dum_sem.py pos
Sai com código 1 se algo divergir do esperado.
"""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import logging
import os
import shutil
import subprocess
import sys
from collections import Counter
from pathlib import Path

import config as C  # antes do polars (R8)
import utils as U

import pandas as pd
import polars as pl
import pyarrow as pa
import pyarrow.parquet as pq

COMMIT_7E99 = "9f1957b"
VERSAO_ANTIGA = "7e99bf94"
NASC = "06_processados/nascimentos.parquet"
SAIDAS_06B = ["06_processados/obitos_perinatais.parquet", "06_processados/serie_diaria_municipio.parquet",
              "06_processados/serie_diaria_municipio_sem_coorte_fixa.parquet"]
LOGS_06B = ["fluxograma_exclusoes.csv", "validacao_e5_datas.csv", "obitos_por_criterio.csv", "totais_anuais.csv",
            "criterios_inclusao_recorte.csv"]
REGERADOS = ["DESFECHOS", "GESTACOES-RISCO", "EXPOSICAO", "PIG"]      # sistemas do integridade.csv que a troca regrava
RASCUNHO = Path(os.environ.get("ORIGEM", C.TMP / "rascunho_06b")).resolve()
OUT = C.TMP / "nao_regressao_ig_dum_sem"
INI, FIM = "<!-- INTEGRIDADE:INICIO -->", "<!-- INTEGRIDADE:FIM -->"
res: dict[str, tuple[bool, str]] = {}


def git_show(caminho: str) -> str:
    return subprocess.run(["git", "-C", str(C.ROOT), "show", f"{COMMIT_7E99}:{caminho}"], capture_output=True,
                          text=True, check=True).stdout


def versao_de(md5s: dict[str, str]) -> str:
    """Mesma conta do 08_manifesto: SHA-256 da lista ordenada caminho:md5, 8 primeiros hex."""
    return hashlib.sha256("\n".join(f"{c}:{m}" for c, m in sorted(md5s.items())).encode()).hexdigest()[:8]


def manifesto_antigo() -> dict:
    man = json.loads(git_show("09_acesso/manifesto.json"))
    md5s = {a["caminho"]: a["md5"] for a in man["arquivos"]}
    res["manifesto 7e99bf94 lido do git; versão recalculada da lista = 7e99bf94"] = (
        man["versao"] == VERSAO_ANTIGA and versao_de(md5s) == VERSAO_ANTIGA, f"commit {COMMIT_7E99}, {len(md5s)} arquivos")
    return man


def hash_coluna(s: pl.Series) -> str:
    return hashlib.sha256(s.hash(seed=0).to_numpy().tobytes()).hexdigest()[:16]


def comparar_nascimentos(antigo: Path, novo: Path, log) -> None:
    sa, sn = pq.read_schema(antigo), pq.read_schema(novo)
    la, ln = pq.ParquetFile(antigo).metadata.num_rows, pq.ParquetFile(novo).metadata.num_rows
    res["nascimentos: mesmo nº de linhas"] = (la == ln, f"{la:,} × {ln:,}")
    res["nascimentos: colunas antigas na mesma ordem e uma a mais, ig_dum_sem (int16), no fim"] = (
        sn.names[:len(sa.names)] == sa.names and sn.names[len(sa.names):] == ["ig_dum_sem"]
        and sn.field("ig_dum_sem").type == pa.int16(), f"{len(sa.names)} → {len(sn.names)} colunas")
    res["nascimentos: tipo de cada coluna antiga igual"] = (all(sa.field(c).type == sn.field(c).type for c in sa.names), "")
    difs = []
    for c in sa.names:
        a, b = pl.read_parquet(antigo, columns=[c])[c], pl.read_parquet(novo, columns=[c])[c]
        n_dif = int(a.ne_missing(b).sum()) if len(a) == len(b) else -1
        ha, hb = hash_coluna(a), hash_coluna(b)
        igual = a.equals(b, check_dtypes=True, check_names=True, null_equal=True)
        log.info("coluna %-26s linhas diferentes %d | NA %d × %d | hash %s × %s | %s", c, n_dif, a.null_count(),
                 b.null_count(), ha, hb, "idêntica" if igual and ha == hb and n_dif == 0 else "DIFERENTE")
        if not (igual and ha == hb and n_dif == 0):
            difs.append(f"{c} ({n_dif} linhas)")
    res[f"nascimentos: as {len(sa.names)} colunas antigas idênticas (equals com NA, 0 linha diferente, hash igual)"] = (
        not difs, "; ".join(difs) or "todas")


def bloco_99(texto: str) -> list[str]:
    return texto.split(INI, 1)[1].split(FIM, 1)[0].strip().splitlines()


def comparar_blocos(antigo: list[str], novo: list[str], rotulo: str, log, esperado_nasc: bool = True) -> None:
    """Só pode mudar a linha do 'Gerado por' e a linha do nascimentos.parquet (md5); a ordem das linhas pode mudar
    porque os scripts regravados registram de novo no integridade.csv."""
    a, n = Counter(antigo), Counter(novo)
    so_a, so_n = list((a - n).elements()), list((n - a).elements())
    for l in so_a:
        log.info("%s | só na 7e99bf94: %s", rotulo, l[:160])
    for l in so_n:
        log.info("%s | só na nova:      %s", rotulo, l[:160])
    gerado = lambda ls: [l for l in ls if l.startswith("_Gerado por")]
    nasc = lambda ls: [l for l in ls if "| nascimentos.parquet" in l]
    outras = [l for l in so_a + so_n if l not in gerado(so_a + so_n) + nasc(so_a + so_n)]
    ok_nasc = (len(nasc(so_a)) == 1 and len(nasc(so_n)) == 1) if esperado_nasc else not nasc(so_a + so_n)
    res[f"99 ({rotulo}): só mudam o 'Gerado por' e{'' if esperado_nasc else ' não'} a linha do nascimentos.parquet"] = (
        not outras and ok_nasc, f"{len(so_a)} linha(s) só na antiga, {len(so_n)} só na nova; outras: {len(outras)}")


def simular_99(md5_nasc: str, log) -> list[str]:
    sim = OUT / "sim99"
    (sim / "logs").mkdir(parents=True, exist_ok=True)
    shutil.copyfile(C.INTEGRIDADE_CSV, sim / "logs" / "integridade.csv")
    shutil.copyfile(C.ROOT / "README.md", sim / "README.md")
    reg = pd.read_csv(C.INTEGRIDADE_CSV, dtype=str, keep_default_na=False)
    ult = (reg[reg["sistema"].isin(REGERADOS)].sort_values("data_hora", kind="stable")
           .drop_duplicates(["sistema", "arquivo"], keep="last").copy())
    ult["data_hora"] = U.agora()
    ult.loc[ult["arquivo"] == "nascimentos.parquet", "md5_parquet"] = md5_nasc
    ult[U.CAMPOS_INTEGRIDADE].to_csv(sim / "logs" / "integridade.csv", mode="a", header=False, index=False)
    sp = importlib.util.spec_from_file_location("m99", C.SCRIPTS / "99_relatorio_integridade.py")
    m99 = importlib.util.module_from_spec(sp)
    sp.loader.exec_module(m99)
    lg = logging.getLogger("99_relatorio_integridade")     # o 99 simulado loga só em arquivo, dentro de _tmp/
    lg.handlers.clear()
    lg.setLevel(logging.INFO)
    lg.addHandler(logging.FileHandler(sim / "logs" / "99_simulado.log", encoding="utf-8"))
    orig = (C.INTEGRIDADE_CSV, C.LOGS, C.ROOT)
    try:
        C.INTEGRIDADE_CSV, C.LOGS, C.ROOT = sim / "logs" / "integridade.csv", sim / "logs", sim
        try:
            m99.main()
            cod = 0
        except SystemExit as e:
            cod = e.code or 0
    finally:
        C.INTEGRIDADE_CSV, C.LOGS, C.ROOT = orig
        lg.handlers.clear()
    res["99 simulado roda sem erro nas checagens automáticas"] = (cod == 0, f"código {cod}; {len(ult)} linhas acrescentadas")
    return bloco_99((sim / "README.md").read_text(encoding="utf-8"))


def raiz_conferencia(versao_prev: str, log) -> None:
    r = C.TMP / "raiz_ig_dum_sem"
    (r / "06_processados").mkdir(parents=True, exist_ok=True)
    (r / "09_acesso").mkdir(parents=True, exist_ok=True)
    (r / "07_pig_referencia").mkdir(parents=True, exist_ok=True)
    pares = {NASC: RASCUNHO / "nascimentos.parquet", "06_processados/pig_classificacao.parquet": C.PROC / "pig_classificacao.parquet",
             # para o 07b --rascunho rodar nesta raiz, sobre o nascimentos novo (fase regen)
             "07_pig_referencia/oms_kiserud2017_p10.csv": C.PIG / "oms_kiserud2017_p10.csv",
             "07_pig_referencia/pedreira2011_p10.csv": C.PIG / "pedreira2011_p10.csv"}
    arqs = []
    for rel, src in pares.items():
        shutil.copyfile(src, r / rel)
        m = U.md5(r / rel)
        if m != U.md5(src):
            res[f"raiz de conferência: cópia de {rel}"] = (False, "md5 da cópia difere")
        if rel.startswith("06_processados/"):
            arqs.append({"caminho": rel, "md5": m, "sigilo": "microdado"})
    (r / "09_acesso" / "manifesto.json").write_text(json.dumps({"versao": f"{versao_prev}-conferencia", "arquivos": arqs}),
                                                    encoding="utf-8")
    log.info("raiz de conferência: %s (versão %s-conferencia)", r, versao_prev)


def fase_pre(log) -> None:
    man = manifesto_antigo()
    disco = {a["caminho"]: U.md5(C.ROOT / a["caminho"]) for a in man["arquivos"]}
    dif = [c for c, m in disco.items() if m != {a["caminho"]: a["md5"] for a in man["arquivos"]}[c]]
    res["ativos no disco = manifesto 7e99bf94 (nenhum arquivo trocado ainda)"] = (not dif, f"{len(disco) - len(dif)}/{len(disco)}")
    for rel in SAIDAS_06B:
        a, b = C.ROOT / rel, RASCUNHO / Path(rel).name
        la, lb = pq.ParquetFile(a).metadata.num_rows, pq.ParquetFile(b).metadata.num_rows
        res[f"{Path(rel).name}: rascunho = ativo (md5 e nº de linhas)"] = (U.md5(a) == U.md5(b) and la == lb, f"{la:,} linhas")
    for n in LOGS_06B:
        res[f"logs/{n}: rascunho = ativo (md5)"] = (U.md5(C.LOGS / n) == U.md5(RASCUNHO / n), "")
    comparar_nascimentos(C.ROOT / NASC, RASCUNHO / "nascimentos.parquet", log)
    md5_novo = U.md5(RASCUNHO / "nascimentos.parquet")
    prev = versao_de({**{a["caminho"]: a["md5"] for a in man["arquivos"]}, NASC: md5_novo})
    log.info("md5 do nascimentos: 7e99bf94 %s → rascunho %s | versão prevista: %s", disco[NASC], md5_novo, prev)
    comparar_blocos(bloco_99(git_show("README.md")), simular_99(md5_novo, log), "simulado × 7e99bf94", log)
    raiz_conferencia(prev, log)
    (OUT / "previsto.json").write_text(json.dumps({"versao_prevista": prev, "md5_nascimentos": md5_novo}), encoding="utf-8")


def fase_regen(log) -> None:
    """ANTES da troca: o 06d e o 06c rodados com --rascunho (lendo o 06_processados ativo, cujas colunas que eles leem
    são idênticas no nascimentos novo) e o 07b --rascunho rodado na raiz de conferência (lendo o nascimentos NOVO)
    gravam arquivos com o md5 da 7e99bf94. Prova que regravar depois da troca não muda nada (auditoria, achado 3)."""
    man = manifesto_antigo()
    pasta = {"06c_exposicao.py": C.TMP / "rascunho_06c", "06d_gestacoes_em_risco.py": C.TMP / "rascunho_06d",
             "07b_pig_classificacao.R": C.TMP / "raiz_ig_dum_sem" / "_tmp" / "rascunho_07"}
    alvo = [a for a in man["arquivos"] if a["gerado_por"] in pasta]
    for a in alvo:
        novo = pasta[a["gerado_por"]] / Path(a["caminho"]).name
        ok = novo.exists() and U.md5(novo) == a["md5"]
        log.info("%-60s %s", a["caminho"], "idêntico" if ok else ("AUSENTE no rascunho" if not novo.exists() else "DIFERENTE"))
        res[f"regerado = 7e99bf94: {a['caminho']} ({a['gerado_por']})"] = (ok, "md5 igual" if ok else "")
    res["regen: todos os arquivos do 06c, 06d e 07b conferidos"] = (len(alvo) == 19, f"{len(alvo)} arquivos (esperado 19: 15 do 06c, 1 do 06d e 3 do 07b)")


def fase_pos(log) -> None:
    antigo = manifesto_antigo()
    novo = json.loads((C.ROOT / "09_acesso" / "manifesto.json").read_text(encoding="utf-8"))
    ca, cn = {a["caminho"]: a for a in antigo["arquivos"]}, {a["caminho"]: a for a in novo["arquivos"]}
    res["manifesto novo: mesmos arquivos da 7e99bf94"] = (set(ca) == set(cn), f"{len(cn)} arquivos")
    disco = {c: U.md5(C.ROOT / c) for c in cn}
    res["manifesto novo = disco; versão recalculada do disco = versao do manifesto"] = (
        all(disco[c] == cn[c]["md5"] for c in cn) and versao_de(disco) == novo["versao"], novo["versao"])
    prev = OUT / "previsto.json"
    res["fase pre registrada (previsto.json existe)"] = (prev.exists(), str(prev.relative_to(C.ROOT)))   # achado 3: não pular
    if prev.exists():
        p = json.loads(prev.read_text(encoding="utf-8"))
        res["versão nova = a prevista na fase pre"] = (novo["versao"] == p["versao_prevista"], p["versao_prevista"])
        res["nascimentos ativo = o do rascunho conferido na fase pre (md5)"] = (disco[NASC] == p["md5_nascimentos"], disco[NASC])
    linhas = [c for c in ca if ca[c]["n_linhas"] != cn.get(c, {}).get("n_linhas")]
    res["mesmo nº de linhas em todos os arquivos"] = (not linhas, f"divergem: {linhas}" if linhas else f"{len(ca)} arquivos")
    md5_dif = sorted(c for c in ca if c in cn and ca[c]["md5"] != cn[c]["md5"])
    res["md5 igual ao da 7e99bf94 em todos os arquivos, menos o nascimentos"] = (md5_dif == [NASC], f"mudaram: {md5_dif}")
    col_a = [(c["nome"], c["tipo"]) for c in ca[NASC]["colunas"]]
    col_n = [(c["nome"], c["tipo"]) for c in cn[NASC]["colunas"]]
    res["nascimentos no manifesto: colunas antigas (nome e tipo) + ig_dum_sem int16 no fim"] = (
        col_n[:-1] == col_a and col_n[-1] == ("ig_dum_sem", "int16"), f"{len(col_a)} → {len(col_n)}")
    novo_bloco = bloco_99((C.ROOT / "README.md").read_text(encoding="utf-8"))
    comparar_blocos(bloco_99(git_show("README.md")), novo_bloco, "README novo × 7e99bf94", log)
    sim = OUT / "sim99" / "README.md"
    res["99 simulado da fase pre existe"] = (sim.exists(), str(sim.relative_to(C.ROOT)))
    if sim.exists():
        comparar_blocos(bloco_99(sim.read_text(encoding="utf-8")), novo_bloco, "README novo × simulado", log,
                        esperado_nasc=False)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("fase", choices=["pre", "regen", "pos"])
    a = ap.parse_args()
    log = U.get_logger(f"nao_regressao_ig_dum_sem_{a.fase}")
    OUT.mkdir(parents=True, exist_ok=True)
    log.info("fase %s | rascunho: %s", a.fase, RASCUNHO)
    {"pre": fase_pre, "regen": fase_regen, "pos": fase_pos}[a.fase](log)
    for k, (ok, det) in res.items():
        log.info("%s %s | %s", "OK   " if ok else "FALHA", k, det)
    f = sum(not ok for ok, _ in res.values())
    log.info("%d/%d conferências OK", len(res) - f, len(res))
    sys.exit(1 if f else 0)


if __name__ == "__main__":
    main()
