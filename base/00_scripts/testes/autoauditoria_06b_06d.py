"""Autoauditoria 06b + 06d: identidades entre séries, bases individuais e gestações em risco.
Lê microdado na Forja; imprime só agregados (nada por município × dia).

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/autoauditoria_06b_06d.py
    ORIGEM=../_tmp/rascunho_06b ORIGEM_06D=../_tmp/rascunho_06d PYTHONPATH=. uv run python testes/autoauditoria_06b_06d.py
Sai com código 1 se alguma identidade falhar.
"""
import datetime as dt
import os
import sys
from pathlib import Path

import config as C  # antes do polars (R8)

import numpy as np
import polars as pl

P = Path(os.environ.get("ORIGEM", C.PROC))
P6D = Path(os.environ.get("ORIGEM_06D", C.PROC))
s = pl.read_parquet(P / "serie_diaria_municipio.parquet")
sc = pl.read_parquet(P / "serie_diaria_municipio_sem_coorte_fixa.parquet")
nasc = pl.scan_parquet(P / "nascimentos.parquet")
ob = pl.scan_parquet(P / "obitos_perinatais.parquet")
chk = {}

conta = ["nv_unicos", "nv_multiplos_ou_ign", "ptb", "ptb_extremo", "ptb_muito", "ptb_moderado_tardio", "nv_ig_43_44",
         "obito_fetal_principal", "obito_neonatal_precoce", "obito_perinatal", "obito_neonatal_precoce_idx_obito",
         "obito_perinatal_idx_obito", "obito_ate24h", "obito_perinatal_24h", "obito_perinatal_sem_anomalia"]
# 1. identidades dentro da série (onde não NA)
for nome, x in (("principal", s), ("sem coorte", sc)):
    ok = x.filter(pl.col("nv_unicos").is_not_null())
    chk[f"{nome}: ptb = extremo + muito + moderado_tardio"] = ok.select((pl.col("ptb") == pl.col("ptb_extremo") + pl.col("ptb_muito") + pl.col("ptb_moderado_tardio")).all()).item()
    chk[f"{nome}: ptb <= nv_unicos"] = ok.select((pl.col("ptb") <= pl.col("nv_unicos")).all()).item()
    okp = x.filter(pl.col("obito_perinatal").is_not_null())
    chk[f"{nome}: perinatal = fetal + neonatal"] = okp.select((pl.col("obito_perinatal") == pl.col("obito_fetal_principal") + pl.col("obito_neonatal_precoce")).all()).item()
    chk[f"{nome}: perinatal_24h e sem_anomalia <= perinatal"] = okp.select(((pl.col("obito_perinatal_24h") <= pl.col("obito_perinatal")) & (pl.col("obito_perinatal_sem_anomalia") <= pl.col("obito_perinatal"))).all()).item()
# 2. sem coorte >= principal, célula a célula
j = s.join(sc, on=["CD_MUN6", "data"], suffix="_sc")
chk["sem coorte >= principal em todas as células e colunas"] = all(
    j.filter(pl.col(c).is_not_null()).select((pl.col(c + "_sc") >= pl.col(c)).all()).item() for c in conta)
# 3. NA de propósito
a = pl.col("data").dt.year()
chk["2011: NA em todas as colunas de IG; múltiplos preenchido"] = (s.filter(a == 2011).select(pl.col("nv_unicos").null_count()).item() == s.filter(a == 2011).height
                                                                and s.filter(a == 2011)["nv_multiplos_ou_ign"].null_count() == 0)
cen = s.filter(pl.col("data") >= pl.lit(dt.date(2024, 12, 25)))
chk["censura: neonatal NA em 25–31/12/2024 e fetal preenchido"] = (cen["obito_neonatal_precoce"].null_count() == cen.height
                                                                   and cen["obito_fetal_principal"].null_count() == 0 and cen.height == 277 * 7)
chk["principal: *_sem_ig todo NA"] = s["obito_fetal_sem_ig"].null_count() == s.height == s["obito_neonatal_precoce_sem_ig"].null_count()
# 4. série x base individual (2012–2024)
n_ind = nasc.filter(pl.col("pop_ptb") & pl.col("coorte_fixa_22") & (pl.col("ano") >= 2012)).select(pl.len()).collect().item()
chk["nv_unicos (principal) = NV únicos 22–42 da coorte na base individual"] = int(s["nv_unicos"].sum()) == n_ind
f_ind = ob.filter((pl.col("tipo") == "fetal") & pl.col("principal") & pl.col("coorte_fixa_22")).select(pl.len()).collect().item()
chk["fetal principal (série) = base individual"] = int(s["obito_fetal_principal"].sum()) == f_ind
neo_ind = ob.filter((pl.col("tipo") == "neonatal_precoce") & pl.col("principal") & pl.col("coorte_fixa_22")
                    & (pl.col("data_indice") < pl.lit(dt.date(2024, 12, 25)))).select(pl.len()).collect().item()
chk["neonatal principal (série, sem os dias censurados) = base individual"] = int(s["obito_neonatal_precoce"].sum()) == neo_ind
# 5. 06d: total Brasil em 20 dias sorteados = gestações com s + 154 <= t <= término (contagem vetorizada, sem 06d)
z = pl.scan_parquet(P6D / "gestacoes_em_risco.parquet")
g = nasc.filter(pl.col("pop_ptb") & pl.col("coorte_fixa_22")).select("dum_est", "data").collect()
s0 = g["dum_est"].to_numpy().astype("datetime64[D]"); e0 = g["data"].to_numpy().astype("datetime64[D]")
rng = np.random.default_rng(C.SEED + 1)
dias = rng.choice(np.arange(np.datetime64("2012-01-01"), np.datetime64("2024-12-31")), 20, replace=False)
zt = z.with_columns(pl.col("data").cast(pl.Date)).filter(pl.col("data").is_in([dt.date.fromisoformat(str(d)) for d in dias])).group_by("data").agg(pl.col("z_nv").sum()).collect()
zt = dict(zip([np.datetime64(d, "D") for d in zt["data"].to_list()], zt["z_nv"].to_list()))
bate = [int(((s0 + 154 <= d) & (d <= e0)).sum()) == zt.get(d, 0) for d in dias]
chk["06d: Σ z_nv no Brasil = contagem vetorizada em 20 dias sorteados"] = all(bate)
for k, v in chk.items():
    print("OK   " if v else "FALHA", k)
sys.exit(0 if all(chk.values()) else 1)
