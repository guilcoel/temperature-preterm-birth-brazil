"""Conferência independente do 06b: conta direto do microdado bruto (sem importar o 06b) e compara
com as saídas. Lê microdado na Forja; imprime só agregados Brasil × ano.

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/conferencia_06b_independente.py                 # 06_processados/
    ORIGEM=../_tmp/rascunho_06b PYTHONPATH=. uv run python testes/conferencia_06b_independente.py
Sai com código 1 se alguma diferença for diferente de zero.
"""
import os
import sys
from pathlib import Path

import config as C  # antes do polars (R8)

import pandas as pd
import polars as pl

R = Path(os.environ.get("ORIGEM", C.PROC))
mun6 = pd.read_csv(C.RM / "concentracoes_urbanas_municipios.csv", dtype=str)["CD_MUN6"].tolist()


def arqs(pasta, ano):
    return [str(p) for p in sorted((pasta / "parquet" / f"ano={ano}").glob("uf=*.parquet")) if not p.name.startswith("._")]


linhas = []
for ano in C.ANOS:
    sin = pl.concat([pl.scan_parquet(a).select("CODMUNRES", "SEMAGESTAC", "GRAVIDEZ") for a in arqs(C.SINASC, ano)])
    sin = sin.filter(pl.col("CODMUNRES").str.slice(0, 6).is_in(mun6))
    sg = pl.col("SEMAGESTAC").cast(pl.Int32, strict=False)
    a = sin.select(pl.len().alias("nv"), ((pl.col("GRAVIDEZ") == "1") & sg.is_between(22, 42)).sum().alias("unico_22_42"),
                   ((pl.col("GRAVIDEZ") == "1") & sg.is_between(22, 36)).sum().alias("ptb_22_36")).collect().to_dicts()[0]
    br = pl.concat([pl.scan_parquet(x).select(pl.len()) for x in arqs(C.SINASC, ano)]).sum().collect().item()
    dofet = pl.concat([pl.scan_parquet(x).select("CODMUNRES", "TIPOBITO") for x in arqs(C.SIM / "_dofet", ano)])
    f = dofet.filter(pl.col("CODMUNRES").str.slice(0, 6).is_in(mun6) & (pl.col("TIPOBITO") == "1")).select(pl.len()).collect().item()
    linhas.append({"ano": ano, **a, "nv_brasil": br, "fetais_tipobito1": f})
ind = pd.DataFrame(linhas)

nasc = pl.scan_parquet(R / "nascimentos.parquet")
b = nasc.group_by("ano").agg(pl.len().alias("nv_06b"), pl.col("pop_ptb").sum().alias("pop_ptb_06b"),
                             pl.col("ptb").sum().alias("ptb_06b")).collect().to_pandas()
ob = pl.scan_parquet(R / "obitos_perinatais.parquet")
fo = ob.filter(pl.col("tipo") == "fetal").group_by(pl.col("ano_obito").alias("ano")).agg(pl.len().alias("fetais_06b")).collect().to_pandas()
t = ind.merge(b, on="ano").merge(fo, on="ano")
difs = {"nv": (t["nv"] - t["nv_06b"]).abs().sum(), "pop_ptb": (t["unico_22_42"] - t["pop_ptb_06b"]).abs().sum(),
        "ptb": (t["ptb_22_36"] - t["ptb_06b"]).abs().sum(), "fetais": (t["fetais_tipobito1"] - t["fetais_06b"]).abs().sum()}
print("Diferenças absolutas somadas nos 14 anos (base individual x contagem direta):", {k: int(v) for k, v in difs.items()})
print("NV nas concentrações / Brasil, 2012–2024:",
      round(100 * t.loc[t.ano >= 2012, "nv"].sum() / t.loc[t.ano >= 2012, "nv_brasil"].sum(), 2), "%")
sc = pl.read_parquet(R / "serie_diaria_municipio_sem_coorte_fixa.parquet")
x = sc.filter(pl.col("periodo_principal")).select(pl.col("nv_unicos").sum(), pl.col("ptb").sum()).to_dicts()[0]
d_serie = abs(x["nv_unicos"] - int(t.loc[t.ano >= 2012, "unico_22_42"].sum())) + abs(x["ptb"] - int(t.loc[t.ano >= 2012, "ptb_22_36"].sum()))
print("Série sem coorte 2012–2024 x contagem direta (nv_unicos + ptb), diferença:", d_serie)
sys.exit(1 if sum(difs.values()) or d_serie else 0)
