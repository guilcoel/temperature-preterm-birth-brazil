"""Interface de acesso à base dados_artigos_perinatais_clima (Python). Par exato de acesso.R: mesmos nomes e
mesmos resultados. Lê os arquivos pelo manifesto (09_acesso/manifesto.json, gerado pelo 00_scripts/08_manifesto.py)
e confere o md5 de cada um na primeira leitura da sessão.

SIGILO (LGPD; regras na raiz da Forja e no CLAUDE.md do projeto):
- "microdado" (nascimentos, obitos, pig): uma linha por pessoa. Nunca exibir linha, nem copiar para fora da Forja.
- "restrito" (séries por município/concentração × dia, gestações em risco): só sair agregado recorte × ano (ou
  mais grosso), com contagem < 10 como "<10". Nada de município × dia na tela.
- "publico": clima, referências e logs agregados.

Uso:
    import sys; sys.path.insert(0, "/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso")
    import acesso as A
    A.versao()                               # identificador da versão da base (citar no artigo)
    s = A.serie_diaria("recorte")            # concentração × dia, com coorte fixa, contagens + exposições
    m = A.expo_semanal("tmean", "nucleo")    # matriz s01..s37 gravada pelo 06c
    m2 = A.matriz_semanal("pm25_zero_na", "rm_nv")   # qualquer variável diária, mesmo cálculo do 06c
    n = A.ligar_expo_semanal(A.nascimentos(["id_nasc", "CD_MUN6", "data", "ga_sem"]), "tmean", "nucleo")

Raiz: variável de ambiente DADOS_PERINATAIS_CLIMA_RAIZ ou /Volumes/Forja/Doc/dados_artigos_perinatais_clima.
Requer polars, numpy e pyarrow (o ambiente do projeto: ~/.venvs/dados_perinatais_clima).

Importe este módulo ANTES do polars: ele fixa a pasta de spill do polars em _tmp/ da Forja (POLARS_TEMP_DIR e
POLARS_OOC_SPILL_DIR), para que nenhum pedaço de microdado vá para a pasta temporária do sistema, no disco interno.
"""
from __future__ import annotations

import datetime as dt
import hashlib
import json
import os
import sys
from functools import lru_cache
from pathlib import Path

RAIZ_PADRAO = "/Volumes/Forja/Doc/dados_artigos_perinatais_clima"
_TMP = Path(os.environ.get("DADOS_PERINATAIS_CLIMA_RAIZ", RAIZ_PADRAO)) / "_tmp"
if _TMP.parent.exists():                       # antes do import do polars (como no config.py do projeto)
    _TMP.mkdir(exist_ok=True)
    os.environ["POLARS_TEMP_DIR"] = str(_TMP)
    os.environ["POLARS_OOC_SPILL_DIR"] = str(_TMP)
if "polars" in sys.modules:
    print("AVISO: o polars foi importado antes do acesso.py; a pasta de spill pode não ser a _tmp/ da Forja.",
          file=sys.stderr)

import numpy as np  # noqa: E402
import polars as pl  # noqa: E402

CLIMA_INI, CLIMA_FIM = dt.date(2010, 1, 1), dt.date(2025, 1, 31)
S_INI, S_FIM = dt.date(2010, 1, 1), dt.date(2024, 12, 31)
N_SEM = 37
VAR_CLIMA = {"tmax": "tmax", "tmin": "tmin", "tmean": "tmean", "rh": "rh_mean", "pr": "pr"}
VAR_PM25 = ("pm25", "pm25_zero_na", "pm25_local", "pm25_local_zero_na")
_conferidos: set[str] = set()
_avisados: set[str] = set()


def raiz() -> Path:
    r = Path(os.environ.get("DADOS_PERINATAIS_CLIMA_RAIZ", RAIZ_PADRAO))
    if not (r / "09_acesso" / "manifesto.json").exists():
        raise FileNotFoundError(f"base não encontrada em {r} (o volume Forja está montado?)")
    return r


@lru_cache(maxsize=1)
def manifesto() -> dict:
    return json.loads((raiz() / "09_acesso" / "manifesto.json").read_text(encoding="utf-8"))


def versao() -> str:
    return manifesto()["versao"]


def _entrada(caminho: str) -> dict:
    for a in manifesto()["arquivos"]:
        if a["caminho"] == caminho:
            return a
    raise KeyError(f"{caminho} não está no manifesto")


def _md5(p: Path) -> str:
    h = hashlib.md5()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""):
            h.update(b)
    return h.hexdigest()


def verificar(caminhos: list[str] | None = None, parar: bool = True) -> dict:
    """Recalcula o md5 e compara com o manifesto: {caminho: True/False}; arquivo ausente = False.
    Com parar=True, lista todos os que falharam (como no acesso.R)."""
    if caminhos is None:
        caminhos = [a["caminho"] for a in manifesto()["arquivos"]]
    elif isinstance(caminhos, str):
        caminhos = [caminhos]
    res = {}
    for c in caminhos:
        e = _entrada(c)                     # caminho fora do manifesto: KeyError, não "ausente"
        p = raiz() / c
        res[c] = p.exists() and _md5(p) == e["md5"]
        if res[c]:
            _conferidos.add(c)
    ruins = [c for c, ok in res.items() if not ok]
    if parar and ruins:
        raise ValueError(f"md5 difere do manifesto ou arquivo ausente (versão {versao()}): {', '.join(ruins)}")
    return res


def ler(caminho: str, colunas: list[str] | None = None, conferir: bool = True) -> pl.DataFrame:
    """Lê um arquivo do manifesto (parquet ou CSV), conferindo o md5 na primeira leitura da sessão."""
    e = _entrada(caminho)
    if isinstance(colunas, str):            # um nome só, como no R (auditoria de 08/10/2026, achado 2)
        colunas = [colunas]
    if conferir and caminho not in _conferidos:
        verificar([caminho])
    if e["sigilo"] != "publico" and caminho not in _avisados:
        print(f"AVISO DE SIGILO: {caminho}: '{e['sigilo']}'. Não exibir linhas; só agregados recorte × ano, com < 10 como '<10'.",
              file=sys.stderr)          # stderr: filtro de warnings não o esconde (auditoria do fechamento, A13)
        _avisados.add(caminho)
    p = raiz() / caminho
    if p.suffix == ".parquet":
        return pl.read_parquet(p, columns=colunas)
    df = pl.read_csv(p, infer_schema_length=0, null_values=[""])   # vazio, com ou sem aspas, = null (como no R)
    return df.select(colunas) if colunas else df


# ---------------------------------------------------------------------------- tabelas
def nascimentos(colunas=None) -> pl.DataFrame:
    return ler("06_processados/nascimentos.parquet", colunas)


def obitos(colunas=None) -> pl.DataFrame:
    return ler("06_processados/obitos_perinatais.parquet", colunas)


def pig(colunas=None, com_nascimentos: list[str] | None = None) -> pl.DataFrame:
    """Classificação do PIG (07b). com_nascimentos: colunas do nascimentos.parquet a juntar por id_nasc (lista ou um
    nome só, por exemplo "ig_dum_sem"); mantém a ordem e o nº de linhas do pig_classificacao."""
    p = ler("06_processados/pig_classificacao.parquet", colunas)
    if isinstance(com_nascimentos, str):    # como no R: um nome só (auditoria de 08/10/2026, achado 2)
        com_nascimentos = [com_nascimentos]
    if com_nascimentos:
        p = p.join(nascimentos(["id_nasc", *[c for c in com_nascimentos if c != "id_nasc"]]), on="id_nasc", how="left",
                   maintain_order="left")
    return p


def serie_diaria(nivel: str = "recorte", coorte_fixa: bool = True, colunas=None) -> pl.DataFrame:
    """nivel 'recorte' (concentração × dia) ou 'municipio' (município × dia); grade 2010-12-11 a 2025-01-07 (06c)."""
    nome = {"recorte": "serie_diaria_recorte", "municipio": "serie_diaria_municipio_clima"}[nivel]
    return ler(f"06_processados/{nome}{'' if coorte_fixa else '_sem_coorte_fixa'}.parquet", colunas)


def gestacoes_em_risco(nivel: str = "recorte") -> pl.DataFrame:
    return ler({"recorte": "06_processados/gestacoes_em_risco_recorte.parquet",
                "municipio": "06_processados/gestacoes_em_risco.parquet"}[nivel])


def clima_municipal(colunas=None) -> pl.DataFrame:
    return ler("06_processados/clima_municipio_diario_2010_2025.parquet", colunas)


def pm25_municipal(colunas=None) -> pl.DataFrame:
    return ler("06_processados/pm25_municipio_diario_2010_2025.parquet", colunas)


def calendario() -> pl.DataFrame:
    return ler("06_processados/calendario_2010_2025.parquet")


def concentracoes() -> pl.DataFrame:
    return ler("04_regioes_metropolitanas/concentracoes_urbanas_municipios.csv")


def cidade_nucleo() -> pl.DataFrame:
    return ler("04_regioes_metropolitanas/cidade_nucleo.csv")


def referencias_pig() -> dict:
    return {"oms": ler("07_pig_referencia/oms_kiserud2017_p10.csv"), "pedreira": ler("07_pig_referencia/pedreira2011_p10.csv")}


def expo_semanal(var: str, versao_expo: str) -> pl.DataFrame:
    """Matriz gravada pelo 06c: var em tmean, rh, pm25; versao_expo em nucleo, rm_nv, mun."""
    return ler(f"06_processados/expo_semanal_{var}_{versao_expo}.parquet")


# ---------------------------------------------------------------------------- matriz semanal de qualquer variável
def _diaria_municipal(var: str) -> pl.DataFrame:
    if var in VAR_CLIMA:
        d = clima_municipal(["CD_MUN6", "data", VAR_CLIMA[var]]).rename({VAR_CLIMA[var]: "x"})
    elif var in VAR_PM25:
        d = pm25_municipal(["CD_MUN6", "data", var]).rename({var: "x"})
    else:
        raise ValueError(f"variável {var}: use uma de {list(VAR_CLIMA) + list(VAR_PM25)}")
    return d.with_columns(pl.col("x").fill_nan(None))


def _unidades_x_dias(d: pl.DataFrame, chave: str) -> tuple[list[str], np.ndarray]:
    n_dias = (CLIMA_FIM - CLIMA_INI).days + 1
    d = d.sort(chave, "data")
    unid = d[chave].unique(maintain_order=True).to_list()
    datas = pl.date_range(CLIMA_INI, CLIMA_FIM, "1d", eager=True)
    if len(d) != len(unid) * n_dias or not (d["data"] == pl.concat([datas] * len(unid))).all():
        raise ValueError("série diária incompleta")
    return unid, d["x"].fill_null(np.nan).to_numpy().reshape(len(unid), n_dias)


def _medias_semanais(x: np.ndarray) -> np.ndarray:
    m7 = np.lib.stride_tricks.sliding_window_view(x, 7, axis=1).mean(axis=2)
    n_s = (S_FIM - S_INI).days + 1
    idx = (S_INI - CLIMA_INI).days + np.arange(n_s)[:, None] + 7 * np.arange(N_SEM)[None, :]
    ok = idx < m7.shape[1]
    out = np.full((x.shape[0], n_s, N_SEM), np.nan)
    out[:, ok] = m7[:, idx[ok]]
    return out


def pesos_rm_nv() -> pl.DataFrame:
    """Peso do `_rm_nv` (06c): total de nascidos vivos residentes em 2011–2024, por município."""
    return nascimentos(["CD_MUN6"]).group_by("CD_MUN6").agg(pl.len().cast(pl.Float64).alias("w"))


def diaria_recorte(var: str, versao_expo: str) -> pl.DataFrame:
    """Série diária por concentração na cobertura inteira do clima (2010-01-01 a 2025-01-31): 'nucleo' ou 'rm_nv'."""
    d = _diaria_municipal(var)
    mun = concentracoes().select("CD_MUN6", pl.col("CD_RECORTE").alias("recorte_principal"))
    if versao_expo == "nucleo":
        nuc = cidade_nucleo().select(pl.col("CD_RECORTE").alias("recorte_principal"),
                                     pl.col("CD_MUN_NUCLEO").str.slice(0, 6).alias("CD_MUN6"))
        return nuc.join(d, on="CD_MUN6", maintain_order="left").select("recorte_principal", "data", "x")
    if versao_expo == "rm_nv":
        w = d.join(mun, on="CD_MUN6").join(pesos_rm_nv(), on="CD_MUN6")
        den = pl.col("w").filter(pl.col("x").is_not_null()).sum()
        return w.group_by("recorte_principal", "data").agg(
            pl.when(den > 0).then((pl.col("x") * pl.col("w")).sum() / den).otherwise(None).alias("x"))
    raise ValueError("versao_expo: 'nucleo' ou 'rm_nv'")


def matriz_semanal(var: str, versao_expo: str) -> pl.DataFrame:
    """s01..s37 de qualquer variável diária (tmax, tmin, tmean, rh, pr e as quatro de PM2.5), nas versões
    'nucleo', 'rm_nv' e 'mun', com o cálculo do 06c: s{k} = média dos dias dum_est + 7(k−1) … dum_est + 7k − 1,
    NA se faltar dia; dum_est de 2010-01-01 a 2024-12-31 (grade completa)."""
    if versao_expo == "mun":
        chave, d = "CD_MUN6", _diaria_municipal(var)
    else:
        chave, d = "recorte_principal", diaria_recorte(var, versao_expo)
    unid, x = _unidades_x_dias(d, chave)
    arr = _medias_semanais(x)
    n_s = arr.shape[1]
    cols = {chave: np.repeat(np.array(unid, dtype=object), n_s).tolist(),
            "dum_est": pl.concat([pl.date_range(S_INI, S_FIM, "1d", eager=True)] * len(unid))}
    cols.update({f"s{k + 1:02d}": arr[:, :, k].ravel() for k in range(N_SEM)})
    return pl.DataFrame(cols).with_columns(pl.col(r"^s\d\d$").fill_nan(None))


def ligar_expo_semanal(nasc: pl.DataFrame, var: str, versao_expo: str, ajuste_dias: int = 3,
                       matriz: pl.DataFrame | None = None) -> pl.DataFrame:
    """Junta s01..s37 a cada nascimento (mesma ordem de linhas de nasc) pelo início da gestação recalculado:
    dum = data − (7 × ga_sem + ajuste_dias) (3 = principal; 0 e 6 = sensibilidades do E8).
    nasc precisa de CD_MUN6, data e ga_sem. Matriz: a gravada (tmean, rh, pm25) ou matriz_semanal(var, versão).
    A matriz não corta no parto: para pré-termo, ponha NA nas semanas k > IG."""
    if matriz is None:
        gravada = var in ("tmean", "rh", "pm25")
        matriz = expo_semanal(var, versao_expo) if gravada else matriz_semanal(var, versao_expo)
    n = nasc.with_columns(dum_est=(pl.col("data") - pl.duration(days=7 * pl.col("ga_sem").cast(pl.Int64) + ajuste_dias)))
    if versao_expo == "mun":
        return n.join(matriz, on=["CD_MUN6", "dum_est"], how="left", maintain_order="left")
    mun = concentracoes().select("CD_MUN6", pl.col("CD_RECORTE").alias("recorte_principal"))
    return (n.join(mun, on="CD_MUN6", how="left", maintain_order="left")
            .join(matriz, on=["recorte_principal", "dum_est"], how="left", maintain_order="left"))
