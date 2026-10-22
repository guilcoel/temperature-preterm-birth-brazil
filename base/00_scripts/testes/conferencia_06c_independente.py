"""Conferência independente do 06c: recalcula em pandas, sem importar o 06c, a partir das saídas do
06a, do 06b e do 06d, e compara com as saídas do 06c CÉLULA A CÉLULA, com NA no mesmo lugar
(auditoria do 06c, A5): as duas séries (município e recorte, com e sem coorte fixa) em todas as
contagens, flags e exposições (6 variáveis × versões); todas as células das 9 matrizes; o
dias_faltantes_pm25.csv; as gestações em risco por recorte.

Lê nascimentos.parquet (microdado) só para contar NV por município; imprime só diferenças agregadas.

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/conferencia_06c_independente.py                  # 06_processados/ e logs/
    ORIGEM=../_tmp/rascunho_06c PYTHONPATH=. uv run python testes/conferencia_06c_independente.py
Sai com código 1 se alguma conferência falhar.
"""
import os
import sys
from pathlib import Path

import config as C  # antes do polars (R8)

import numpy as np
import pandas as pd
import polars as pl
import pyarrow.parquet as pq

R = Path(os.environ.get("ORIGEM", C.PROC))
CSV_FALT = (R if "ORIGEM" in os.environ else C.LOGS) / "dias_faltantes_pm25.csv"
TOL = 1e-9
GRADE = pd.date_range("2010-12-11", "2025-01-07", freq="D")
S_DATAS = pd.date_range("2010-01-01", "2024-12-31", freq="D")
VARS = ["tmean", "rh", "pm25", "pm25_zero_na", "pm25_local", "pm25_local_zero_na"]
FLAGS = ["periodo_principal", "periodo_sens2011", "censura_neonatal_dez2024"]
res = {}


def compara(obs, esp):
    """(dif. máxima onde os dois têm valor, nº de células com NA discordante)."""
    o, e_ = pd.Series(obs).reset_index(drop=True), pd.Series(esp).reset_index(drop=True)
    na_o, na_e = o.isna().to_numpy(), e_.isna().to_numpy()
    ok = ~na_o & ~na_e
    d = float(np.max(np.abs(o[ok].astype(float).to_numpy() - e_[ok].astype(float).to_numpy()))) if ok.any() else 0.0
    return d, int((na_o != na_e).sum())


def anota(nome, difs):
    """difs: lista de (dif, na_disc); ok se todas as difs < TOL e nenhum NA discordante."""
    dmax = max((d for d, _ in difs), default=0.0)
    nas = sum(n for _, n in difs)
    res[nome] = (dmax < TOL and nas == 0, f"dif máx {dmax:.1e}; NA discordantes {nas}; {len(difs)} colunas")


mun = pd.read_csv(C.RM / "concentracoes_urbanas_municipios.csv", dtype=str)
nuc = pd.read_csv(C.RM / "cidade_nucleo.csv", dtype=str)
REC = dict(zip(mun["CD_MUN6"], mun["CD_RECORTE"]))
NUC = dict(zip(nuc["CD_RECORTE"], nuc["CD_MUN_NUCLEO"].str[:6]))
NMUN = mun.groupby("CD_RECORTE").size()
recortes, muns = sorted(NUC), sorted(REC)

cl = pd.read_parquet(C.PROC / "clima_municipio_diario_2010_2025.parquet", columns=["CD_MUN6", "data", "tmean", "rh_mean"])
pm = pd.read_parquet(C.PROC / "pm25_municipio_diario_2010_2025.parquet", columns=["CD_MUN6", "data", *VARS[2:]])
ex = cl.rename(columns={"rh_mean": "rh"}).merge(pm, on=["CD_MUN6", "data"])
ex["data"] = pd.to_datetime(ex["data"])
ex = ex.sort_values(["CD_MUN6", "data"], ignore_index=True)
W = dict(pl.scan_parquet(C.PROC / "nascimentos.parquet").group_by("CD_MUN6").agg(pl.len()).collect().iter_rows())
ex["CD_RECORTE"], ex["w"] = ex["CD_MUN6"].map(REC), ex["CD_MUN6"].map(W).astype(float)

# exposição esperada por recorte × dia (cobertura inteira do clima)
g = [ex["CD_RECORTE"], ex["data"]]
esp = {}
for v in VARS:
    ok = ex[v].notna()
    num = (ex[v].where(ok, 0.0) * ex["w"]).groupby(g).sum()
    den = ex["w"].where(ok, 0.0).groupby(g).sum()
    esp[f"{v}_rm_nv"] = num / den.where(den > 0)
inv = {n: r for r, n in NUC.items()}
en = ex[ex["CD_MUN6"].isin(inv)].assign(CD_RECORTE=lambda d: d["CD_MUN6"].map(inv)).set_index(["CD_RECORTE", "data"])
for v in VARS:
    esp[f"{v}_nucleo"] = en[v]
esp_rec = pd.DataFrame(esp).sort_index()

# ---------------------------------------------------------------------------- séries
for suf in ("", "_sem_coorte_fixa"):
    s6 = pd.read_parquet(C.PROC / f"serie_diaria_municipio{suf}.parquet")
    s6["data"] = pd.to_datetime(s6["data"])
    cont = [c for c, tp in pl.scan_parquet(C.PROC / f"serie_diaria_municipio{suf}.parquet").collect_schema().items() if tp.is_integer()]
    # município × dia
    sm = pd.read_parquet(R / f"serie_diaria_municipio_clima{suf}.parquet")
    sm["data"] = pd.to_datetime(sm["data"])
    sm = sm.sort_values(["CD_MUN6", "data"], ignore_index=True)
    idx = pd.MultiIndex.from_product([muns, GRADE], names=["CD_MUN6", "data"])
    chave_ok = len(sm) == len(idx) and (pd.MultiIndex.from_frame(sm[["CD_MUN6", "data"]]) == idx).all()
    e6 = s6.set_index(["CD_MUN6", "data"]).reindex(idx)
    difs = [compara(sm[c], e6[c]) for c in cont]
    fl = e6[FLAGS].astype("boolean").fillna(False)
    difs += [compara(sm[f].astype(float), fl[f].astype(float)) for f in FLAGS]
    exg = ex.set_index(["CD_MUN6", "data"]).reindex(idx)
    difs += [compara(sm[f"{v}_mun"], exg[v]) for v in VARS]
    rn = esp_rec.reindex(pd.MultiIndex.from_arrays([sm["CD_MUN6"].map(REC), sm["data"]]))
    difs += [compara(sm[f"{v}_nucleo"], rn[f"{v}_nucleo"]) for v in VARS]
    ok_rec = (sm["recorte_principal"] == sm["CD_MUN6"].map(REC)).all()
    anota(f"série município × dia{suf}: {len(cont)} contagens, 3 flags, 6 _mun, 6 _nucleo", difs)
    res[f"série município × dia{suf}: chave e recorte"] = (bool(chave_ok and ok_rec), f"{len(sm)} linhas")
    # recorte × dia
    sr = pd.read_parquet(R / f"serie_diaria_recorte{suf}.parquet")
    sr["data"] = pd.to_datetime(sr["data"])
    sr = sr.sort_values(["recorte_principal", "data"], ignore_index=True)
    idr = pd.MultiIndex.from_product([recortes, GRADE], names=["recorte_principal", "data"])
    chave_ok = len(sr) == len(idr) and (pd.MultiIndex.from_frame(sr[["recorte_principal", "data"]]) == idr).all()
    s6["recorte_principal"] = s6["CD_MUN6"].map(REC)
    gb = s6.groupby(["recorte_principal", "data"])
    soma = gb[cont].sum(min_count=1)
    soma = soma.where(gb[cont].count() == gb.size().to_numpy()[:, None])        # NA se algum município é NA
    er6 = soma.reindex(idr)
    difs = [compara(sr[c], er6[c]) for c in cont]
    flr = gb[FLAGS].first().reindex(idr).astype("boolean").fillna(False)
    difs += [compara(sr[f].astype(float), flr[f].astype(float)) for f in FLAGS]
    eg = esp_rec.reindex(idr)
    difs += [compara(sr[f"{v}_{x}"], eg[f"{v}_{x}"]) for v in VARS for x in ("nucleo", "rm_nv")]
    meta = ((sr["n_municipios"] == sr["recorte_principal"].map(NMUN)).all()
            and (sr["CD_MUN6_NUCLEO"] == sr["recorte_principal"].map(NUC)).all())
    anota(f"série recorte × dia{suf}: {len(cont)} contagens, 3 flags, 6 _nucleo, 6 _rm_nv", difs)
    res[f"série recorte × dia{suf}: chave, n_municipios e CD_MUN6_NUCLEO"] = (bool(chave_ok and meta), f"{len(sr)} linhas")

# ---------------------------------------------------------------------------- matrizes (todas as células)
datas = pd.date_range(ex["data"].min(), ex["data"].max(), freq="D")
pos = (S_DATAS[0] - datas[0]).days + np.arange(len(S_DATAS))[:, None] + 7 * np.arange(37)[None, :]
valido = pos < len(datas)
for var in ("tmean", "rh", "pm25"):
    diario = {"mun": ex.pivot(index="data", columns="CD_MUN6", values=var).reindex(index=datas, columns=muns)}
    diario["nucleo"] = diario["mun"][[NUC[r] for r in recortes]].set_axis(recortes, axis=1)
    diario["rm_nv"] = esp_rec[f"{var}_rm_nv"].unstack(0).reindex(index=datas, columns=recortes)
    for versao in ("nucleo", "rm_nv", "mun"):
        x = diario[versao]
        m7 = x.rolling(7, min_periods=7).mean().shift(-6).to_numpy()            # dias × unidades
        esperado = np.full((x.shape[1], len(S_DATAS), 37), np.nan)
        esperado[:, valido] = m7[pos[valido]].T
        t = pq.read_table(R / f"expo_semanal_{var}_{versao}.parquet").to_pandas()
        chave = t.columns[0]
        t = t.sort_values([chave, "dum_est"], ignore_index=True)
        chave_ok = (list(t[chave].unique()) == list(x.columns) and len(t) == x.shape[1] * len(S_DATAS)
                    and (pd.to_datetime(t["dum_est"]).to_numpy() == np.tile(S_DATAS.to_numpy(), x.shape[1])).all())
        obs = t[[f"s{k:02d}" for k in range(1, 38)]].to_numpy(dtype=float).reshape(x.shape[1], len(S_DATAS), 37)
        na_d = int((np.isnan(obs) != np.isnan(esperado)).sum())
        ok = ~np.isnan(obs) & ~np.isnan(esperado)
        d = float(np.abs(obs[ok] - esperado[ok]).max())
        res[f"matriz {var}_{versao}: todas as {obs.size} células"] = (bool(chave_ok and d < TOL and na_d == 0),
                                                                     f"dif máx {d:.1e}; NA discordantes {na_d}")
        del t, obs, esperado

# ---------------------------------------------------------------------------- dias_faltantes_pm25.csv
eg = ex[ex["data"].isin(GRADE)]
princ = lambda d: (d >= "2012-01-01") & (d <= "2024-12-31")
linhas = []
for v in VARS[2:]:
    for versao in ("nucleo", "rm_nv"):
        sr_ = esp_rec[f"{v}_{versao}"].reset_index()
        sr_ = sr_[sr_["data"].isin(GRADE)]
        for r, q in sr_.groupby("CD_RECORTE"):
            na = q[f"{v}_{versao}"].isna()
            lin = {"recorte_principal": r, "variante": v, "versao": versao, "n_dias_grade": len(q),
                   "n_faltantes_grade": int(na.sum()), "n_faltantes_2012_2024": int((na & princ(q["data"])).sum()),
                   "primeira_falta": q.loc[na, "data"].min(), "ultima_falta": q.loc[na, "data"].max()}
            if versao == "rm_nv":
                gq = eg[eg["CD_RECORTE"] == r].groupby("data")[v]
                parc = (gq.count() > 0) & (gq.count() < gq.size())
                lin["n_dias_renormalizados_grade"] = int(parc.sum())
                lin["n_dias_renormalizados_2012_2024"] = int((parc & princ(parc.index.to_series())).sum())
            linhas.append(lin)
    for r, q in eg.groupby("CD_RECORTE"):
        na = q[v].isna()
        linhas.append({"recorte_principal": r, "variante": v, "versao": "mun", "n_dias_grade": len(q),
                       "n_faltantes_grade": int(na.sum()), "n_faltantes_2012_2024": int((na & princ(q["data"])).sum()),
                       "primeira_falta": q.loc[na, "data"].min(), "ultima_falta": q.loc[na, "data"].max(),
                       "n_municipios_com_falta": q.loc[na, "CD_MUN6"].nunique()})
ef = pd.DataFrame(linhas)
of = pd.read_csv(CSV_FALT, dtype={"recorte_principal": str})
j = ef.merge(of, on=["recorte_principal", "variante", "versao"], how="outer", suffixes=("_esp", "_obs"), indicator=True)
nd = 0
for c in ("n_dias_grade", "n_faltantes_grade", "n_faltantes_2012_2024", "n_dias_renormalizados_grade",
          "n_dias_renormalizados_2012_2024", "n_municipios_com_falta"):
    nd += int((j[f"{c}_esp"].fillna(-1).astype(float) != j[f"{c}_obs"].fillna(-1).astype(float)).sum())
for c in ("primeira_falta", "ultima_falta"):
    nd += int((pd.to_datetime(j[f"{c}_esp"]).fillna(pd.Timestamp(0)) != pd.to_datetime(j[f"{c}_obs"]).fillna(pd.Timestamp(0))).sum())
res["dias_faltantes_pm25.csv: todas as linhas e colunas"] = (nd == 0 and (j["_merge"] == "both").all() and len(of) == 26 * 4 * 3,
                                                            f"{nd} células diferentes; {len(of)} linhas")

# ---------------------------------------------------------------------------- gestações em risco
gm = pq.read_table(C.PROC / "gestacoes_em_risco.parquet", read_dictionary=["CD_MUN6"]).to_pandas()
gm["CD_RECORTE"] = gm["CD_MUN6"].map(REC).astype("category")
gx = gm.groupby(["CD_RECORTE", "data", "semana"], observed=True)[["z_nv", "z_fetal"]].sum().reset_index()
gx["CD_RECORTE"] = gx["CD_RECORTE"].astype(str)
gx = gx.set_index(["CD_RECORTE", "data", "semana"])
gy = pd.read_parquet(R / "gestacoes_em_risco_recorte.parquet").set_index(["recorte_principal", "data", "semana"])
gy.index.names = gx.index.names
jj = gx.join(gy, how="outer", rsuffix="_06c").fillna(0)
d = int((jj["z_nv"] - jj["z_nv_06c"]).abs().sum() + (jj["z_fetal"] - jj["z_fetal_06c"]).abs().sum())
res["gestações em risco: recorte × dia × semana = soma dos municípios"] = (d == 0 and len(gx) == len(gy), f"dif {d}; {len(gy)} células")

for k, (ok, det) in res.items():
    print("OK   " if ok else "FALHA", k, "|", det)
falhas = sum(not ok for ok, _ in res.values())
print(f"{len(res) - falhas}/{len(res)} conferências OK")
sys.exit(1 if falhas else 0)
