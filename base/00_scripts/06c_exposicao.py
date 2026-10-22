"""06c — Exposições ligadas às séries diárias e matriz semanal gestacional (E8, E9, E15, E16).

Lê o 06a (clima e PM2.5 por município × dia), o 06b (séries município × dia e, só para o peso do
`_rm_nv`, o total de nascidos vivos por município) e o 06d (gestações em risco). Uma execução
grava tudo (desvios de 05/10/2026):

1. Exposições diárias em três versões:
   - `_nucleo`: série do município-núcleo da concentração (cidade_nucleo.csv, CD_MUN_NUCLEO),
     a mesma para todos os municípios do recorte (E15);
   - `_mun`:    série do próprio município (média ponderada por área, no 06a);
   - `_rm_nv`:  média dos municípios do recorte ponderada pelo total de nascidos vivos residentes
     em 2011–2024 (peso fixo), renormalizada sobre os municípios com dado no dia; NA se nenhum.
   Variáveis: tmean, rh (rh_mean do 06a) e as quatro variantes de PM2.5 do 06a.
2. Séries ligadas, grade de 2010-12-11 a 2025-01-07 (E9), contagens NA fora de 2011–2024:
   - serie_diaria_municipio_clima[_sem_coorte_fixa].parquet: município × dia, contagens e flags
     do 06b, exposições `_mun` e `_nucleo`;
   - serie_diaria_recorte[_sem_coorte_fixa].parquet: concentração × dia, soma das contagens dos
     municípios (NA quando a coluna é NA no dia), exposições `_nucleo` e `_rm_nv`.
3. gestacoes_em_risco_recorte.parquet: soma, por dia e semana, das gestações em risco (06d) dos
   municípios do recorte.
4. Matrizes semanais (E8) expo_semanal_{tmean|rh|pm25}_{nucleo|rm_nv|mun}.parquet. Chave:
   recorte_principal (ou CD_MUN6, na `_mun`) e dum_est, em grade completa de 2010-01-01 a
   2024-12-31; colunas s01..s37, com s{k} = média dos dias dum_est + 7(k−1) … dum_est + 7k − 1,
   NA se faltar qualquer dia. Não corta no parto (pré-termo: o artigo põe NA nas semanas k > IG).
   PM2.5 só na variante `pm25`; as outras saem da série diária.
5. logs/dias_faltantes_pm25.csv (E16): por recorte, variante e versão (`nucleo`, `rm_nv`, `mun`).

Tudo é gravado primeiro em `_staging_06c/`, dentro da pasta de destino, e só é movido para o lugar
(e registrado no integridade.csv) depois que todas as saídas e conferências passaram.

Uso:
    uv run 06c_exposicao.py              # 06_processados/ e logs/
    uv run 06c_exposicao.py --rascunho   # grava em _tmp/rascunho_06c/ (teste; dentro da Forja);
                                         # lê as entradas de 06_processados/
"""
from __future__ import annotations

import argparse
import datetime as dt
import os

import config as C  # antes do polars (R8)
import utils as U

import numpy as np
import pandas as pd
import polars as pl

GRADE_INI, GRADE_FIM = dt.date(2010, 12, 11), dt.date(2025, 1, 7)
ESTUDO_INI, ESTUDO_FIM = dt.date(C.ANO_INI, 1, 1), dt.date(C.ANO_FIM, 12, 31)
PRINC_INI = dt.date(2012, 1, 1)
S_INI, S_FIM = dt.date(2010, 1, 1), dt.date(2024, 12, 31)
N_SEM = 37
PM25 = ["pm25", "pm25_zero_na", "pm25_local", "pm25_local_zero_na"]
EXPO = {"tmean": "tmean", "rh": "rh_mean", **{v: v for v in PM25}}   # nome na base: coluna do 06a
SEMANAIS = ("tmean", "rh", "pm25")
FLAGS = ["periodo_principal", "periodo_sens2011", "censura_neonatal_dez2024"]
CHAVES = ["CD_MUN6", "data", "recorte_principal", "tipo_recorte"]
N_MUNICIPIOS = 277


def clima_ini() -> dt.date:
    return dt.date.fromisoformat(C.CLIMA_INI)


def clima_fim() -> dt.date:
    return dt.date.fromisoformat(C.CLIMA_FIM)


def n_grade() -> int:
    return (GRADE_FIM - GRADE_INI).days + 1


def para(log, msg, *args):
    log.error(msg, *args)
    raise SystemExit(1)


# ---------------------------------------------------------------------------- entradas
def conferir_chave(df: pl.DataFrame, nome: str, muns: list[str], ini: dt.date, fim: dt.date, log) -> None:
    """Município × dia completo: sem chave nula ou duplicada, todos os municípios e todos os dias (A8)."""
    n_dias = (fim - ini).days + 1
    chave = df.select("CD_MUN6", "data")
    if (chave.null_count().sum_horizontal().item() or len(df) != len(muns) * n_dias or chave.is_duplicated().any()
            or sorted(df["CD_MUN6"].unique().to_list()) != sorted(muns)
            or df["data"].min() != ini or df["data"].max() != fim):
        para(log, "%s incompleto: %d linhas (esperado %d municípios × %d dias, sem chave nula ou duplicada)",
             nome, len(df), len(muns), n_dias)


def conferir_recortes(mun_csv: pd.DataFrame, nuc_csv: pd.DataFrame, log) -> None:
    """Composição (04): 277 municípios únicos, um tipo por recorte (A7); cidade-núcleo: um núcleo por
    recorte, os mesmos recortes do 04, cada núcleo dentro do próprio recorte (A9)."""
    if len(mun_csv) != N_MUNICIPIOS or not mun_csv["CD_MUN6"].is_unique or mun_csv[["CD_MUN6", "CD_RECORTE", "TIPO_RECORTE"]].isna().any().any():
        para(log, "concentrações: %d municípios (esperado %d, CD_MUN6 único, sem vazio)", len(mun_csv), N_MUNICIPIOS)
    if (mun_csv.groupby("CD_RECORTE")["TIPO_RECORTE"].nunique() != 1).any():
        para(log, "concentrações: recorte com mais de um TIPO_RECORTE")
    dono = dict(zip(mun_csv["CD_MUN6"], mun_csv["CD_RECORTE"]))
    if (not nuc_csv["CD_RECORTE"].is_unique or set(nuc_csv["CD_RECORTE"]) != set(mun_csv["CD_RECORTE"])
            or any(dono.get(str(n)[:6]) != r for r, n in zip(nuc_csv["CD_RECORTE"], nuc_csv["CD_MUN_NUCLEO"]))):
        para(log, "cidade_nucleo.csv: recorte repetido, faltando ou com núcleo fora do próprio recorte")


# ---------------------------------------------------------------------------- exposições diárias
def exposicao_municipal(clima: pl.DataFrame, pm: pl.DataFrame, muns: list[str], log) -> pl.DataFrame:
    """Município × dia, na cobertura inteira do clima: tmean, rh e as quatro variantes de PM2.5."""
    conferir_chave(clima, "clima do 06a", muns, clima_ini(), clima_fim(), log)
    conferir_chave(pm, "PM2.5 do 06a", muns, clima_ini(), clima_fim(), log)
    e = (clima.select("CD_MUN6", "data", pl.col("tmean"), pl.col("rh_mean").alias("rh"))
         .join(pm.select("CD_MUN6", "data", *PM25), on=["CD_MUN6", "data"], how="left"))
    return e.with_columns([pl.col(v).fill_nan(None) for v in EXPO]).sort("CD_MUN6", "data")


def pesos_nv(nasc: pl.LazyFrame, muns: list[str], log) -> pl.DataFrame:
    """Peso fixo do `_rm_nv`: total de nascidos vivos residentes em 2011–2024, por município."""
    w = nasc.group_by("CD_MUN6").agg(pl.len().cast(pl.Float64).alias("w")).collect()
    if sorted(w["CD_MUN6"].to_list()) != sorted(muns) or (w["w"] <= 0).any():
        para(log, "peso do _rm_nv: %d municípios com NV (esperado %d, todos > 0)", len(w), len(muns))
    return w


def expo_recorte(e: pl.DataFrame, mun: pl.DataFrame, nuc: pl.DataFrame, w: pl.DataFrame) -> pl.DataFrame:
    """Recorte × dia: `{v}_nucleo` e `{v}_rm_nv` para cada variável."""
    nucleo = (nuc.join(e, left_on="CD_MUN6_NUCLEO", right_on="CD_MUN6", how="left")
              .select("recorte_principal", "data", *[pl.col(v).alias(f"{v}_nucleo") for v in EXPO]))
    aggs = []
    for v in EXPO:
        den = pl.col("w").filter(pl.col(v).is_not_null()).sum()
        aggs.append(pl.when(den > 0).then((pl.col(v) * pl.col("w")).sum() / den).otherwise(None).alias(f"{v}_rm_nv"))
    rm = (e.join(mun.select("CD_MUN6", "recorte_principal"), on="CD_MUN6").join(w, on="CD_MUN6")
          .group_by("recorte_principal", "data").agg(aggs))
    return nucleo.join(rm, on=["recorte_principal", "data"], how="left").sort("recorte_principal", "data")


# ---------------------------------------------------------------------------- séries ligadas
def grade(df: pl.DataFrame) -> pl.DataFrame:
    datas = pl.DataFrame(pl.date_range(GRADE_INI, GRADE_FIM, "1d", eager=True).alias("data"))
    return df.join(datas, how="cross")


def contagens(s: pl.DataFrame) -> list[str]:
    return [c for c in s.columns if c not in CHAVES + FLAGS and s.schema[c].is_integer()]


def serie_municipio_clima(s: pl.DataFrame, e: pl.DataFrame, er: pl.DataFrame, mun: pl.DataFrame, log) -> pl.DataFrame:
    """Grade estendida (E9): contagens e flags do 06b (NA e FALSE fora de 2011–2024), `_mun` e `_nucleo`."""
    conferir_chave(s, "série do 06b", mun["CD_MUN6"].to_list(), ESTUDO_INI, ESTUDO_FIM, log)
    if s.select(FLAGS).null_count().sum_horizontal().item():
        para(log, "série do 06b com flag nula")
    conf = s.select("CD_MUN6", "recorte_principal", "tipo_recorte").unique().join(
        mun, on="CD_MUN6", how="full", suffix="_04")
    if len(conf) != len(mun) or (conf["recorte_principal"] != conf["recorte_principal_04"]).any() \
            or (conf["tipo_recorte"] != conf["tipo_recorte_04"]).any():
        para(log, "recorte da série do 06b difere de concentracoes_urbanas_municipios.csv")
    out = (grade(mun.select("CD_MUN6", "recorte_principal", "tipo_recorte"))
           .join(s.drop("recorte_principal", "tipo_recorte"), on=["CD_MUN6", "data"], how="left")
           .with_columns([pl.col(f).fill_null(False) for f in FLAGS])
           .join(e.select("CD_MUN6", "data", *[pl.col(v).alias(f"{v}_mun") for v in EXPO]),
                 on=["CD_MUN6", "data"], how="left")
           .join(er.select("recorte_principal", "data", *[f"{v}_nucleo" for v in EXPO]),
                 on=["recorte_principal", "data"], how="left"))
    expo = [f"{v}_{x}" for x in ("mun", "nucleo") for v in EXPO]
    return out.select(*s.columns, *expo).sort("CD_MUN6", "data")


def conferir_entrada(sm: pl.DataFrame, s: pl.DataFrame, log) -> None:
    """Em 2011–2024, cada contagem e cada flag da série estendida é igual à do 06b, célula a célula,
    com NA no mesmo lugar (A6); fora, contagens NA e flags FALSE."""
    cols = contagens(s) + FLAGS
    j = sm.filter(pl.col("data").is_between(ESTUDO_INI, ESTUDO_FIM)).select("CD_MUN6", "data", *cols).join(
        s.select("CD_MUN6", "data", *cols), on=["CD_MUN6", "data"], how="full", suffix="_6b")
    difere = [c for c in cols if not j.select(pl.col(c).eq_missing(pl.col(f"{c}_6b")).all()).item()]
    fora = sm.filter(~pl.col("data").is_between(ESTUDO_INI, ESTUDO_FIM))
    if (len(j) != len(s) or difere or fora.select(contagens(s)).null_count().sum_horizontal().item() != len(fora) * len(contagens(s))
            or fora.select(pl.any_horizontal(FLAGS).any()).item() or sm.select(FLAGS).null_count().sum_horizontal().item()):
        para(log, "série estendida difere do 06b (colunas: %s) ou tem contagem/flag fora do estudo", difere)


def serie_recorte(sm: pl.DataFrame, er: pl.DataFrame, nuc: pl.DataFrame, log) -> pl.DataFrame:
    """Concentração × dia: soma das contagens dos municípios; NA se a coluna for NA no dia (o mesmo
    padrão em todos os municípios do recorte, senão para); exposições `_nucleo` e `_rm_nv`."""
    cont = contagens(sm)
    aggs = [pl.len().alias("n_municipios"), pl.col("tipo_recorte").first(), pl.col("tipo_recorte").n_unique().alias("_nu_tipo")]
    aggs += [pl.col(c).cast(pl.Int64).sum().alias(c) for c in cont]
    aggs += [pl.col(c).null_count().alias(f"_na_{c}") for c in cont]
    aggs += [pl.col(f).first().alias(f) for f in FLAGS] + [pl.col(f).n_unique().alias(f"_nu_{f}") for f in FLAGS]
    r = sm.group_by("recorte_principal", "data").agg(aggs)
    diverge = r.filter(pl.any_horizontal(
        [(pl.col(f"_na_{c}") > 0) & (pl.col(f"_na_{c}") < pl.col("n_municipios")) for c in cont]
        + [pl.col(f"_nu_{f}") > 1 for f in FLAGS + ["tipo"]]))
    if len(diverge):
        para(log, "%d recorte × dia com padrão de NA, de flag ou de tipo diferente entre os municípios", len(diverge))
    r = r.with_columns([pl.when(pl.col(f"_na_{c}") > 0).then(None).otherwise(pl.col(c)).cast(pl.Int32).alias(c)
                        for c in cont])
    expo = [f"{v}_{x}" for x in ("nucleo", "rm_nv") for v in EXPO]
    r = (r.join(nuc, on="recorte_principal", how="left")
         .join(er.select("recorte_principal", "data", *expo), on=["recorte_principal", "data"], how="left"))
    r = r.select("recorte_principal", "tipo_recorte", "data", *cont, *FLAGS, "n_municipios", "CD_MUN6_NUCLEO",
                 *expo).sort("recorte_principal", "data")
    n_rec = sm["recorte_principal"].n_unique()
    if len(r) != n_rec * n_grade() or r.select("recorte_principal", "data").is_duplicated().any():   # A7
        para(log, "série do recorte com %d linhas (esperado %d recortes × %d dias, chave única)", len(r), n_rec, n_grade())
    return r


def conferir_somas(sm: pl.DataFrame, sr: pl.DataFrame, nome: str, log) -> None:
    """Σ recorte = Σ municípios em cada contagem, e NA do recorte × nº de municípios = NA dos municípios."""
    for c in contagens(sm):
        a, b = sm[c].cast(pl.Int64).sum(), sr[c].cast(pl.Int64).sum()
        na_m = sm[c].null_count()
        na_r = int((sr[c].is_null().cast(pl.Int64) * sr["n_municipios"]).sum())
        if a != b or na_m != na_r:
            para(log, "%s, %s: soma dos municípios %s != soma dos recortes %s (NA %d x %d)", nome, c, a, b, na_m, na_r)
    log.info("%s: soma das contagens e NA do recorte = municípios, em %d colunas (confere)", nome, len(contagens(sm)))


def gestacoes_recorte(gr: pl.LazyFrame, mun: pl.DataFrame) -> pl.DataFrame:
    return (gr.join(mun.lazy().select("CD_MUN6", "recorte_principal"), on="CD_MUN6", how="left")
            .group_by("recorte_principal", "data", "semana")
            .agg(pl.col("z_nv").cast(pl.Int64).sum().cast(pl.Int32), pl.col("z_fetal").cast(pl.Int64).sum().cast(pl.Int32))
            .sort("recorte_principal", "data", "semana").collect())


# ---------------------------------------------------------------------------- matriz semanal
def medias_semanais(x: np.ndarray, d0: dt.date) -> np.ndarray:
    """x: unidade × dia (dia 0 = d0). Devolve unidade × dum_est (S_INI..S_FIM) × semana (1..37):
    média dos dias dum_est + 7(k−1) … dum_est + 7k − 1; NaN se faltar algum dia ou passar do fim."""
    m7 = np.lib.stride_tricks.sliding_window_view(x, 7, axis=1).mean(axis=2)   # dias d..d+6
    n_s = (S_FIM - S_INI).days + 1
    idx = (S_INI - d0).days + np.arange(n_s)[:, None] + 7 * np.arange(N_SEM)[None, :]
    ok = (idx >= 0) & (idx < m7.shape[1])
    out = np.full((x.shape[0], n_s, N_SEM), np.nan)
    out[:, ok] = m7[:, idx[ok]]
    return out


def tabela_semanal(nome_chave: str, chaves: list[str], arr: np.ndarray) -> pl.DataFrame:
    n_u, n_s, _ = arr.shape
    datas = pl.date_range(S_INI, S_FIM, "1d", eager=True)
    cols = {nome_chave: np.repeat(np.array(chaves, dtype=object), n_s).tolist(),
            "dum_est": pl.concat([datas] * n_u)}
    cols.update({f"s{k + 1:02d}": arr[:, :, k].ravel() for k in range(N_SEM)})
    return pl.DataFrame(cols).with_columns(pl.col(r"^s\d\d$").fill_nan(None))   # NA como null, não NaN


def pivo(df: pl.DataFrame, chave: str, col: str, unidades: list[str]) -> np.ndarray:
    """Unidade × dia (cobertura inteira do clima), na ordem de `unidades`; NaN onde for NA.
    Exige, em cada unidade, os dias consecutivos de clima_ini a clima_fim (A8)."""
    n_dias = (clima_fim() - clima_ini()).days + 1
    d = df.select(chave, "data", col).sort(chave, "data")
    datas = pl.date_range(clima_ini(), clima_fim(), "1d", eager=True)
    if (len(d) != len(unidades) * n_dias or d[chave].null_count() or d["data"].null_count()
            or d[chave].unique(maintain_order=True).to_list() != sorted(unidades)
            or not (d["data"] == pl.concat([datas] * len(unidades))).all()):
        raise ValueError(f"pivô de {col}: grade incompleta ou dias fora de ordem")
    x = d[col].fill_null(np.nan).to_numpy().reshape(len(unidades), n_dias)
    ordem = {u: i for i, u in enumerate(sorted(unidades))}
    return x[[ordem[u] for u in unidades]]


def matrizes_semanais(e: pl.DataFrame, er: pl.DataFrame, nuc: pl.DataFrame, muns: list[str], var: str) -> dict:
    """{versão: tabela s01..s37}. `_nucleo` e `_rm_nv` com chave recorte_principal; `_mun` com CD_MUN6."""
    recortes, nucleos = nuc["recorte_principal"].to_list(), nuc["CD_MUN6_NUCLEO"].to_list()
    x_mun = pivo(e, "CD_MUN6", var, muns)
    ordem = {m: i for i, m in enumerate(muns)}
    entradas = {"nucleo": (x_mun[[ordem[n] for n in nucleos]], "recorte_principal", recortes),
                "rm_nv": (pivo(er, "recorte_principal", f"{var}_rm_nv", recortes), "recorte_principal", recortes),
                "mun": (x_mun, "CD_MUN6", muns)}
    return {v: tabela_semanal(ch, un, medias_semanais(x, clima_ini())) for v, (x, ch, un) in entradas.items()}


# ---------------------------------------------------------------------------- PM2.5 faltante
def dias_faltantes_pm25(e: pl.DataFrame, er: pl.DataFrame, mun: pl.DataFrame, nuc_csv: pd.DataFrame) -> pd.DataFrame:
    """Por recorte × variante × versão, na grade da série e em 2012–2024 (E16).
    `nucleo` e `rm_nv`: dias NA. `rm_nv` também conta os dias com valor calculado sobre só parte dos
    municípios (renormalizados). `mun`: município-dias NA somados no recorte e nº de municípios com falta (A13)."""
    na_grade = pl.col("data").is_between(GRADE_INI, GRADE_FIM)
    princ = pl.col("data").is_between(PRINC_INI, ESTUDO_FIM)
    g = er.filter(na_grade)
    gm = e.filter(na_grade).join(mun.select("CD_MUN6", "recorte_principal"), on="CD_MUN6")
    partes = []
    for v in PM25:
        for versao in ("nucleo", "rm_nv"):
            col = pl.col(f"{v}_{versao}")
            partes.append(g.group_by("recorte_principal").agg(
                pl.len().alias("n_dias_grade"), col.is_null().sum().alias("n_faltantes_grade"),
                (col.is_null() & princ).sum().alias("n_faltantes_2012_2024"),
                pl.col("data").filter(col.is_null()).min().alias("primeira_falta"),
                pl.col("data").filter(col.is_null()).max().alias("ultima_falta"),
            ).with_columns(variante=pl.lit(v), versao=pl.lit(versao)))
        # dias do recorte com ao menos um município sem dado, mas com _rm_nv calculado (renormalizado)
        parcial = gm.group_by("recorte_principal", "data").agg(
            (pl.col(v).is_null().any() & pl.col(v).is_not_null().any()).alias("_parcial"))
        ren = parcial.group_by("recorte_principal").agg(
            pl.col("_parcial").sum().alias("n_dias_renormalizados_grade"),
            (pl.col("_parcial") & princ).sum().alias("n_dias_renormalizados_2012_2024"))
        partes[-1] = partes[-1].join(ren, on="recorte_principal", how="left")
        partes.append(gm.group_by("recorte_principal").agg(
            pl.len().alias("n_dias_grade"), pl.col(v).is_null().sum().alias("n_faltantes_grade"),
            (pl.col(v).is_null() & princ).sum().alias("n_faltantes_2012_2024"),
            pl.col("data").filter(pl.col(v).is_null()).min().alias("primeira_falta"),
            pl.col("data").filter(pl.col(v).is_null()).max().alias("ultima_falta"),
            pl.col("CD_MUN6").filter(pl.col(v).is_null()).n_unique().alias("n_municipios_com_falta"),
        ).with_columns(variante=pl.lit(v), versao=pl.lit("mun")))
    t = pl.concat(partes, how="diagonal_relaxed").to_pandas()
    nomes = nuc_csv.rename(columns={"CD_RECORTE": "recorte_principal"})[["recorte_principal", "NM_RECORTE", "CD_MUN_NUCLEO"]]
    t = nomes.merge(t, on="recorte_principal", how="right")
    for c in ("primeira_falta", "ultima_falta"):
        t[c] = pd.to_datetime(t[c]).dt.date
    return t[["recorte_principal", "NM_RECORTE", "CD_MUN_NUCLEO", "variante", "versao", "n_dias_grade",
              "n_faltantes_grade", "n_faltantes_2012_2024", "primeira_falta", "ultima_falta",
              "n_dias_renormalizados_grade", "n_dias_renormalizados_2012_2024", "n_municipios_com_falta"]].sort_values(
        ["variante", "versao", "recorte_principal"], ignore_index=True)


# ---------------------------------------------------------------------------- gravação
def gravar(df: pl.DataFrame, saida, log) -> None:
    tmp = saida.with_suffix(saida.suffix + ".part")
    df.write_parquet(tmp, compression="zstd")
    os.replace(tmp, saida)
    if not saida.exists() or saida.stat().st_size == 0:
        para(log, "falha ao gravar %s", saida)


def pct_na(df: pl.DataFrame, cols: list[str]) -> dict:
    return {c: round(100 * df[c].null_count() / len(df), 3) for c in cols}


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--rascunho", action="store_true", help="grava em _tmp/rascunho_06c (dentro da Forja); lê de 06_processados")
    a = p.parse_args()
    log = U.get_logger("06c_exposicao")
    destino = C.TMP / "rascunho_06c" if a.rascunho else C.PROC
    logs_dir = destino if a.rascunho else C.LOGS
    staging = destino / "_staging_06c"          # A10: nada substitui saída antiga antes de tudo passar
    staging.mkdir(parents=True, exist_ok=True)

    mun_csv = pd.read_csv(C.RM / "concentracoes_urbanas_municipios.csv", dtype=str)
    nuc_csv = pd.read_csv(C.RM / "cidade_nucleo.csv", dtype=str)
    conferir_recortes(mun_csv, nuc_csv, log)
    mun = pl.from_pandas(mun_csv[["CD_MUN6", "CD_RECORTE", "TIPO_RECORTE"]]).rename(
        {"CD_RECORTE": "recorte_principal", "TIPO_RECORTE": "tipo_recorte"})
    muns = sorted(mun["CD_MUN6"].to_list())
    nuc = pl.DataFrame({"recorte_principal": nuc_csv["CD_RECORTE"], "CD_MUN6_NUCLEO": nuc_csv["CD_MUN_NUCLEO"].str[:6]})
    log.info("%d municípios, %d concentrações; núcleo de cada uma dentro dela (confere)", len(muns), len(nuc))

    ano = f"{C.CLIMA_INI[:4]}_{C.CLIMA_FIM[:4]}"
    e = exposicao_municipal(pl.read_parquet(C.PROC / f"clima_municipio_diario_{ano}.parquet"),
                            pl.read_parquet(C.PROC / f"pm25_municipio_diario_{ano}.parquet"), muns, log)
    w = pesos_nv(pl.scan_parquet(C.PROC / "nascimentos.parquet"), muns, log)
    er = expo_recorte(e, mun, nuc, w)
    log.info("Exposição municipal: %d linhas; por recorte: %d linhas; %% NA (cobertura do clima): %s",
             len(e), len(er), pct_na(er, [c for c in er.columns if c.endswith(("_nucleo", "_rm_nv"))]))

    arquivos = []
    for sufixo in ("", "_sem_coorte_fixa"):
        s = pl.read_parquet(C.PROC / f"serie_diaria_municipio{sufixo}.parquet")
        sm = serie_municipio_clima(s, e, er, mun, log)
        conferir_entrada(sm, s, log)
        sr = serie_recorte(sm, er, nuc, log)
        conferir_somas(sm, sr, f"série{sufixo or ' com coorte fixa'}", log)
        for nome, df in ((f"serie_diaria_municipio_clima{sufixo}.parquet", sm), (f"serie_diaria_recorte{sufixo}.parquet", sr)):
            gravar(df, staging / nome, log)
            arquivos.append((nome, len(df), "E9; grade 2010-12-11 a 2025-01-07; contagens NA fora de 2011-2024"))
            log.info("%s: %d linhas (%d dias); %% NA nas exposições: %s", nome, len(df), df["data"].n_unique(),
                     pct_na(df, [c for c in df.columns if c.endswith(("_mun", "_nucleo", "_rm_nv"))]))
        tot = sr.filter(pl.col("periodo_principal")).select(pl.col("nv_unicos", "ptb", "obito_perinatal").sum()).to_dicts()[0]
        log.info("Série do recorte%s, 2012–2024, soma das 26 concentrações (dias censurados de dez/2024 ficam fora "
                 "das colunas neonatais): %s", sufixo, tot)

    gr_mun = pl.scan_parquet(C.PROC / "gestacoes_em_risco.parquet")
    gr = gestacoes_recorte(gr_mun, mun)
    t_mun = gr_mun.select(pl.col("z_nv").cast(pl.Int64).sum(), pl.col("z_fetal").cast(pl.Int64).sum()).collect().to_dicts()[0]
    t_rec = gr.select(pl.col("z_nv").cast(pl.Int64).sum(), pl.col("z_fetal").cast(pl.Int64).sum()).to_dicts()[0]
    if t_mun != t_rec or gr["recorte_principal"].null_count():
        para(log, "gestações em risco: total dos municípios %s != total dos recortes %s", t_mun, t_rec)
    gravar(gr, staging / "gestacoes_em_risco_recorte.parquet", log)
    arquivos.append(("gestacoes_em_risco_recorte.parquet", len(gr), "E7 por recorte (soma dos municipios)"))
    log.info("gestacoes_em_risco_recorte: %d células; totais iguais aos dos municípios %s (confere)", len(gr), t_rec)

    for var in SEMANAIS:
        for versao, tab in matrizes_semanais(e, er, nuc, muns, var).items():
            nome = f"expo_semanal_{var}_{versao}.parquet"
            gravar(tab, staging / nome, log)
            arquivos.append((nome, len(tab), f"E8; s01..s37; dum_est {S_INI} a {S_FIM}"))
            n_u = tab[tab.columns[0]].n_unique()
            log.info("%s: %d linhas (%d unidades × %d inícios); %% NA em s01 %.3f, em s37 %.3f; %.1f MB", nome, len(tab),
                     n_u, len(tab) // n_u, 100 * tab["s01"].null_count() / len(tab),
                     100 * tab["s37"].null_count() / len(tab), (staging / nome).stat().st_size / 1e6)

    falt = dias_faltantes_pm25(e, er, mun, nuc_csv)
    falt.to_csv(staging / "dias_faltantes_pm25.csv", index=False)
    r = falt.groupby(["variante", "versao"])[["n_faltantes_grade", "n_faltantes_2012_2024"]].agg(["sum", "max"])
    log.info("dias_faltantes_pm25.csv (soma e máximo por recorte; `mun` em município-dias):\n%s", r.to_string())

    # tudo passou: move do staging para o destino e só então registra (A10)
    for nome, _, _ in arquivos:
        os.replace(staging / nome, destino / nome)
    os.replace(staging / "dias_faltantes_pm25.csv", logs_dir / "dias_faltantes_pm25.csv")
    try:
        staging.rmdir()                      # só se estiver vazia (criada por este script)
    except OSError:
        log.warning("%s não ficou vazia (restos ._* do disco não-APFS?); conferir", staging)
    log.info("%d arquivos movidos de %s para %s", len(arquivos) + 1, staging.name, destino)
    if not a.rascunho:
        U.registrar_integridade([{
            "sistema": "EXPOSICAO", "ano": f"{C.ANO_INI}-{C.ANO_FIM}", "uf": "concentracoes", "arquivo": nome,
            "status": "derivado", "n_linhas": n, "md5_parquet": U.md5(destino / nome), "observacao": obs}
            for nome, n, obs in arquivos])
        ano = f"{C.CLIMA_INI[:4]}_{C.CLIMA_FIM[:4]}"
        U.registrar_proveniencia(
            [*(destino / nome for nome, _, _ in arquivos), logs_dir / "dias_faltantes_pm25.csv"],
            [f"06_processados/clima_municipio_diario_{ano}.parquet", f"06_processados/pm25_municipio_diario_{ano}.parquet",
             "06_processados/nascimentos.parquet", "06_processados/serie_diaria_municipio.parquet",
             "06_processados/serie_diaria_municipio_sem_coorte_fixa.parquet", "06_processados/gestacoes_em_risco.parquet",
             "04_regioes_metropolitanas/concentracoes_urbanas_municipios.csv", "04_regioes_metropolitanas/cidade_nucleo.csv",
             *U.codigo(__file__)], __file__)
    log.info("FIM 06c (%s)", "rascunho" if a.rascunho else "projeto")


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception:  # noqa: BLE001 — a exceção vai para o .log (auditoria A12)
        U.get_logger("06c_exposicao").exception("06c interrompido por exceção")
        raise
