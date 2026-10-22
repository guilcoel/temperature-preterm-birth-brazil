"""Conferência independente do 07b (PIG): recalcula em pandas, sem R, a partir de nascimentos.parquet e das
tabelas de p10 do 07a, e compara com pig_classificacao.parquet célula a célula (NA no mesmo lugar):
- a população (uma linha por NV único de 24–42 semanas com peso válido; mesma chave id_nasc);
- pig_oms (por sexo), pig_oms_meio_semana (p10 interpolado em 7 × IG + 3), pig_oms_sem_sexo e pig_pedreira;
- os limiares do INTERGROWTH a partir do z gravado: pig_ig21 = z < Φ⁻¹(0,10), pig_ig21_p3 = z < Φ⁻¹(0,03),
  ig21_z_extremo = |z| > 5; pop_pig_principal, pig_sens_pretermo e ig21_ref_nao_verificada;
- os logs pig_resumo_ano.csv e pig_concordancia.csv: todas as contagens, %, concordância e kappa, e a
  supressão em bloco (linha em branco exatamente onde há alguma contagem 1–9, publicada ou dedutível).
O valor do z em si (gigs) é conferido no teste em R contra a tabela do INTERGROWTH.

Lê microdado na Forja; imprime só diferenças agregadas.

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/conferencia_07_independente.py                 # 06_processados/ e logs/
    ORIGEM=../_tmp/rascunho_07 PYTHONPATH=. uv run python testes/conferencia_07_independente.py
Sai com código 1 se alguma conferência falhar.
"""
import os
import sys
from pathlib import Path
from statistics import NormalDist

import config as C  # antes do polars (R8)

import numpy as np
import pandas as pd

R = Path(os.environ.get("ORIGEM", C.PROC))
LOGS = R if "ORIGEM" in os.environ else C.LOGS
REF = C.ROOT / "07_pig_referencia"
res = {}

n = pd.read_parquet(C.PROC / "nascimentos.parquet", columns=["id_nasc", "ano", "ga_sem", "peso_g", "sexo", "unico", "coorte_fixa_37"])
b = n[n["unico"].fillna(False) & n["ga_sem"].between(24, 42) & n["peso_g"].notna()].copy()
b["sx"] = b["sexo"].map({"1": "M", "2": "F"})
c = pd.read_parquet(R / "pig_classificacao.parquet")
res["população: mesmas linhas e mesma chave (id_nasc)"] = (
    len(c) == len(b) and c["id_nasc"].is_unique and set(c["id_nasc"]) == set(b["id_nasc"]), f"{len(c)} linhas")
j = b.merge(c, on="id_nasc", how="inner")


def iguais(obs, esp):
    o, e = pd.Series(obs).astype("boolean"), pd.Series(esp).astype("boolean")
    return int(((o.isna() != e.isna()) | (o.notna() & e.notna() & (o != e))).sum())


def limite(ref, sexo_col):
    t = ref.rename(columns={"semana": "ga_sem", "sexo": "_s"})
    return j[["ga_sem", sexo_col]].rename(columns={sexo_col: "_s"}).merge(t[["ga_sem", "_s", "p10_g"]], how="left",
                                                                         on=["ga_sem", "_s"])["p10_g"].to_numpy()


oms = pd.read_csv(REF / "oms_kiserud2017_p10.csv")
j["_ambos"] = "ambos"
oms_sx = oms[oms["sexo"] != "ambos"]
lim = {"pig_oms": limite(oms_sx, "sx"), "pig_oms_sem_sexo": limite(oms[oms["sexo"] == "ambos"], "_ambos")}
# meio da semana: p10 interpolado em 7 × IG + 3 (3/7 do caminho até a semana seguinte); NA sem a semana seguinte
j["_ga1"] = j["ga_sem"] + 1
a_ = lim["pig_oms"]
b_ = j[["_ga1", "sx"]].rename(columns={"_ga1": "ga_sem", "sx": "_s"}).merge(
    oms_sx.rename(columns={"semana": "ga_sem", "sexo": "_s"})[["ga_sem", "_s", "p10_g"]], how="left", on=["ga_sem", "_s"])["p10_g"].to_numpy()
lim["pig_oms_meio_semana"] = a_ + (3 / 7) * (b_ - a_)
if (REF / "pedreira2011_p10.csv").exists():
    lim["pig_pedreira"] = limite(pd.read_csv(REF / "pedreira2011_p10.csv"), "sx")
else:
    res["pig_pedreira todo NA (tabela ainda ausente)"] = (bool(j["pig_pedreira"].isna().all()), "")
peso = j["peso_g"].to_numpy(dtype=float)
for col, l in lim.items():
    esp = pd.Series(np.where(np.isnan(l), np.nan, peso < l)).where(~np.isnan(l)).astype("boolean")
    d = iguais(j[col], esp)
    res[f"{col}: recálculo pela tabela de p10"] = (d == 0, f"{d} células diferentes")

z = j["ig21_z"].to_numpy(dtype=float)
zt = pd.Series(z)
p10, p3 = NormalDist().inv_cdf(0.10), NormalDist().inv_cdf(0.03)
extremo = zt.abs() > 5
eleg = j["sx"].notna().to_numpy() & zt.notna().to_numpy() & ~extremo.to_numpy()
ga = j["ga_sem"].to_numpy()
esperado = {
    "pig_ig21": (zt < p10).where(zt.notna()),
    "pig_ig21_p3": (zt < p3).where(zt.notna()),
    "ig21_z_extremo": extremo.fillna(False),
    "pop_pig_principal": pd.Series(eleg & (ga >= 37) & j["coorte_fixa_37"].fillna(False).to_numpy()),
    "pig_sens_pretermo": pd.Series(eleg & (ga < 37)),
    "ig21_ref_nao_verificada": pd.Series(ga < 33),
}
for col, esp in esperado.items():
    d = iguais(j[col].reset_index(drop=True), esp)
    res[f"{col}: regra a partir do z gravado e das colunas do 06b"] = (d == 0, f"{d} células diferentes")
res["z ausente só onde o sexo é ignorado"] = (bool((zt.isna().to_numpy() == j["sx"].isna().to_numpy()).all()),
                                              f"{int(zt.isna().sum())} z ausentes")
mono = j[["pig_ig21_g0", "pig_ig21", "pig_ig21_g6"]].astype("boolean").dropna()
res["sensibilidade de IG: PIG com +0 ⊂ +3 ⊂ +6 (z cai com a idade)"] = (
    bool((~mono["pig_ig21_g0"] | mono["pig_ig21"]).all() and (~mono["pig_ig21"] | mono["pig_ig21_g6"]).all()), "")

# logs: recálculo das contagens de cada linha; suprimida se e só se alguma contagem (publicada ou dedutível) é 1–9
curvas = ["pig_ig21", "pig_ig21_p3", "pig_ig21_g0", "pig_ig21_g6", "pig_pedreira", "pig_oms", "pig_oms_meio_semana",
          "pig_oms_sem_sexo"]
peq = lambda v: any(0 < x < 10 for x in v)
ra = pd.read_csv(LOGS / "pig_resumo_ano.csv", dtype=str, keep_default_na=False)
termo = j[(j["ga_sem"] >= 37) & j["coorte_fixa_37"].fillna(False)]
dif, n_sup = 0, 0
for pop in ("pop_pig_principal", "pig_sens_pretermo"):
    for a, g in j[j[pop]].groupby("ano"):
        lin = ra[(ra["populacao"] == pop) & (ra["ano"] == str(a))].iloc[0]
        cont, pub = [len(g)], {"n": str(len(g))}
        if pop == "pop_pig_principal":
            t_ = termo[termo["ano"] == a]
            ns, nz = int(t_["sx"].isna().sum()), int(t_["ig21_z_extremo"].sum())
            ona = int((g["ga_sem"] >= 41).sum())
            cont += [len(t_), ns, nz, len(t_) - len(g) - ns - nz, ona]
            pub.update(n_termo_coorte37=str(len(t_)), n_sexo_ignorado=str(ns), n_z_extremo=str(nz), n_oms_na_41_42=str(ona))
        for cv in curvas:
            x = g[cv].astype("boolean")
            n_cl, n_pig = int(x.notna().sum()), int(x.fillna(False).sum())
            cont += [n_cl, n_pig, n_cl - n_pig, len(g) - n_cl]
            pub[f"{cv}_n_classificados"] = str(n_cl)
            pub[f"{cv}_pct"] = f"{100 * n_pig / n_cl:.2f}" if n_cl > 0 else ""
        sup = peq(cont)
        n_sup += sup
        if (lin["suprimido"] == "TRUE") != sup:
            dif += 1
        elif not sup:
            dif += sum(lin[k] != v for k, v in pub.items())
        else:
            dif += sum(lin[k] != "" for k in pub)
res["pig_resumo_ano.csv: contagens e % recalculadas; supressão exatamente onde há contagem 1–9"] = (
    dif == 0, f"{dif} células diferentes; {n_sup} linhas suprimidas")
cc = pd.read_csv(LOGS / "pig_concordancia.csv", dtype=str, keep_default_na=False)
pp = j[j["pop_pig_principal"]]
dif_k, n_sup = 0, 0


def kap(u, v):
    ss, sn, ns, nn = (u & v).sum(), (u & ~v).sum(), (~u & v).sum(), (~u & ~v).sum()
    t = float(ss + sn + ns + nn)
    if t == 0:
        return (ss, sn, ns, nn), "", ""
    po = (ss + nn) / t
    pe = ((ss + sn) * (ss + ns) + (ns + nn) * (sn + nn)) / t ** 2
    return (ss, sn, ns, nn), f"{100 * po:.2f}", (f"{(po - pe) / (1 - pe):.4f}" if 1 - pe > 0 else "")


for (ca, cb), grupo in cc.groupby(["curva_a", "curva_b"], sort=False):
    sup_algum, U, V = False, [], []
    for a, g in pp.groupby("ano"):
        lin = grupo[grupo["ano"] == str(a)].iloc[0]
        u, v = g[ca].astype("boolean"), g[cb].astype("boolean")
        ok = u.notna() & v.notna()
        u, v = u[ok].astype(bool).to_numpy(), v[ok].astype(bool).to_numpy()
        U.append(u); V.append(v)
        cel, cpct, kk = kap(u, v)
        sup = peq(list(cel) + [sum(cel), len(g) - sum(cel)])
        sup_algum |= sup
        n_sup += sup
        if (lin["suprimido"] == "TRUE") != sup:
            dif_k += 1
        elif not sup:
            esp = [str(sum(cel)), *map(str, cel), cpct, kk]
            dif_k += sum(o != e for o, e in zip(lin[["n", "n_pig_ambas", "n_pig_so_a", "n_pig_so_b", "n_nenhuma",
                                                    "concordancia_pct", "kappa"]], esp))
    tot = grupo[grupo["ano"] == "2012-2024"].iloc[0]
    _, cpct, kk = kap(np.concatenate(U), np.concatenate(V))
    esp = ["", ""] if sup_algum else [cpct, kk]
    dif_k += (tot["concordancia_pct"] != esp[0]) + (tot["kappa"] != esp[1]) + any(tot[c] != "" for c in ("n", "n_pig_ambas"))
res["pig_concordancia.csv: 2 × 2, concordância e kappa recalculados; supressão onde há contagem 1–9"] = (
    dif_k == 0, f"{dif_k} células diferentes; {n_sup} linhas suprimidas")

for k, (ok, det) in res.items():
    print("OK   " if ok else "FALHA", k, "|", det)
falhas = sum(not ok for ok, _ in res.values())
print(f"{len(res) - falhas}/{len(res)} conferências OK")
sys.exit(1 if falhas else 0)
