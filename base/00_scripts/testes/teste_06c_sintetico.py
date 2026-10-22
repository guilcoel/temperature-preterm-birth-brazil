"""Teste sintético do 06c (nenhum dado real). Cobre os itens (f), (i), (m) e (o) da especificação,
o `_rm_nv` com renormalização, todas as células das 9 matrizes semanais (contra uma média móvel
calculada aqui, em pandas), o log de dias faltantes de PM2.5, os ramos de parada e uma execução
do main() inteiro sobre 12 municípios inventados (com uma falha no meio, para conferir o staging).

Desenho: R2 = {A periferia, B núcleo}, R1 = {C}; cidade_nucleo fora de ordem e núcleo que não é o
menor código; as quatro variantes de PM2.5 são diferentes entre si (auditoria do 06c, A1–A4, A14).

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/teste_06c_sintetico.py
    ALVO_DIR=../_tmp/diffs/c06c2 PYTHONPATH=. uv run python testes/teste_06c_sintetico.py
Grava só em _tmp/teste_06c_main/ (dentro da Forja). Sai com código 1 se algum caso falhar.
"""
import datetime as dt
import hashlib
import importlib.util
import logging
import os
import sys
from pathlib import Path

import numpy as np
import pandas as pd
import polars as pl

ALVO = Path(os.environ.get("ALVO_DIR", Path(__file__).resolve().parent.parent))
sp = importlib.util.spec_from_file_location("m06c", ALVO / "06c_exposicao.py")
m = importlib.util.module_from_spec(sp); sp.loader.exec_module(m)
logging.basicConfig(level=logging.CRITICAL)
log = logging.getLogger("t")
mudo = logging.getLogger("06c_exposicao"); mudo.addHandler(logging.NullHandler()); mudo.propagate = False
res = {}
rng = np.random.default_rng(20261001)
D = dt.date.fromisoformat


def para(f, *a, **k) -> bool:
    try:
        f(*a, **k)
    except (SystemExit, ValueError):
        return True
    return False


def nulo(df, col, mm, datas):
    return df.with_columns(pl.when((pl.col("CD_MUN6") == mm) & pl.col("data").is_in(datas)).then(None)
                           .otherwise(pl.col(col)).alias(col))


def sintetico(muns, rec, tipo):
    """clima, pm (cobertura inteira) e série do 06b (2011–2024) inventados para `muns`."""
    dias = pl.date_range(m.clima_ini(), m.clima_fim(), "1d", eager=True)
    nd = len(dias)
    cl, pm, ss = [], [], []
    est = pl.date_range(D("2011-01-01"), D("2024-12-31"), "1d", eager=True)
    for k, mm in enumerate(muns):
        cl.append(pl.DataFrame({"CD_MUN": mm + "0", "CD_MUN6": mm, "data": dias, "tmax": 0.0, "tmin": 0.0,
                                "tmean": 20 + 2 * k + rng.normal(0, 3, nd), "rh_mean": rng.uniform(40, 95, nd), "pr": 0.0}))
        b = rng.uniform(5, 40, nd)
        pm.append(pl.DataFrame({"CD_MUN": mm + "0", "CD_MUN6": mm, "data": dias, "pm25": b, "pm25_zero_na": b + 1,
                                "pm25_local": b + 2, "pm25_local_zero_na": b + 3, "n_horarios": 8, "n_horarios_zero": 0}))
        n = len(est)
        ss.append(pl.DataFrame({"CD_MUN6": mm, "data": est,
                                "nv_unicos": rng.integers(0, 30, n).astype(np.int32), "ptb": rng.integers(0, 4, n).astype(np.int32),
                                "obito_neonatal_precoce": rng.integers(0, 2, n).astype(np.int32),
                                "obito_fetal_sem_ig": rng.integers(0, 2, n).astype(np.int32),
                                "recorte_principal": rec[mm], "tipo_recorte": tipo[rec[mm]]}))
    s = pl.concat(ss)
    ano = pl.col("data").dt.year()
    s = s.with_columns(
        nv_unicos=pl.when(ano == 2011).then(None).otherwise(pl.col("nv_unicos")),
        ptb=pl.when(ano == 2011).then(None).otherwise(pl.col("ptb")),
        obito_neonatal_precoce=pl.when((ano == 2011) | (pl.col("data") >= D("2024-12-25"))).then(None)
        .otherwise(pl.col("obito_neonatal_precoce")),
        periodo_principal=ano.is_between(2012, 2024), periodo_sens2011=ano == 2011,
        nv_gestacao_sens2011=pl.when(ano == 2011).then(pl.lit(7, pl.Int32)).otherwise(None),
        censura_neonatal_dez2024=pl.col("data") >= D("2024-12-25"))
    s = s.with_columns(obito_perinatal=(pl.col("obito_neonatal_precoce") + 1).cast(pl.Int32))
    return pl.concat(cl), pl.concat(pm), s


# ---------------------------------------------------------------------------- funções, 3 municípios
A, B, Cm = "100001", "100002", "200001"
REC = {A: "R2", B: "R2", Cm: "R1"}
TIPO = {"R2": "arranjo", "R1": "municipio_isolado"}
muns = [A, B, Cm]
mun = pl.DataFrame({"CD_MUN6": muns, "recorte_principal": [REC[x] for x in muns], "tipo_recorte": [TIPO[REC[x]] for x in muns]})
nuc = pl.DataFrame({"recorte_principal": ["R2", "R1"], "CD_MUN6_NUCLEO": [B, Cm]})
W = {A: 30, B: 10, Cm: 5}
NUCLEO = {"R2": B, "R1": Cm}
d_so_nuc, d_ambos, d_pm, d_loc, d_2011, d_2025, d0 = (D("2015-03-10"), D("2015-03-11"), D("2016-06-01"), D("2017-01-01"),
                                                      D("2011-06-01"), D("2025-01-03"), D("2018-07-01"))
clima, pm, s = sintetico(muns, REC, TIPO)
pm = nulo(pm, "pm25_zero_na", B, [d_so_nuc, d_ambos, d_2011, d_2025])
pm = nulo(pm, "pm25_zero_na", A, [d_ambos])
pm = nulo(pm, "pm25", B, [d_pm])
pm = pm.with_columns(pm25=pl.when((pl.col("CD_MUN6") == A) & (pl.col("data") == d_pm)).then(0.0).otherwise(pl.col("pm25")))
pm = nulo(pm, "pm25_local_zero_na", A, [d_loc])
e = m.exposicao_municipal(clima, pm, muns, log)
w = m.pesos_nv(pl.LazyFrame({"CD_MUN6": [x for x in muns for _ in range(W[x])]}), muns, log)
er = m.expo_recorte(e, mun, nuc, w)
sm = m.serie_municipio_clima(s, e, er, mun, log)
res["conferir_entrada aceita a série correta"] = not para(m.conferir_entrada, sm, s, log)
sr = m.serie_recorte(sm, er, nuc, log)
ng = m.n_grade()

# (f) grade, contagens NA e flags FALSE (não nulas) fora de 2011–2024, nos dois níveis
dentro = pl.col("data").is_between(D("2011-01-01"), D("2024-12-31"))
for nome, df, n_u in (("município", sm, 3), ("recorte", sr, 2)):
    fora = df.filter(~dentro)
    res[f"(f) {nome}: grade 2010-12-11 a 2025-01-07; fora do estudo contagens NA e flags FALSE, nunca nulas"] = (
        len(df) == n_u * ng and df["data"].min() == m.GRADE_INI and df["data"].max() == m.GRADE_FIM
        and len(fora) == n_u * 28 and all(fora[c].null_count() == len(fora) for c in m.contagens(sm))
        and all(df[f].null_count() == 0 for f in m.FLAGS)
        and fora.select([(~pl.col(f)).all() for f in m.FLAGS]).row(0) == (True, True, True))


def serie_e(mm, col, grade=True):
    x = e.filter(pl.col("CD_MUN6") == mm)
    if grade:
        x = x.filter(pl.col("data").is_between(m.GRADE_INI, m.GRADE_FIM))
    return x.sort("data")[col]


# (i) periferia recebe o núcleo e mantém o próprio valor, nas 6 variáveis
a_ = sm.filter(pl.col("CD_MUN6") == A).sort("data")
b_ = sm.filter(pl.col("CD_MUN6") == B).sort("data")
res["(i) periferia: *_nucleo = série do núcleo (B) e *_mun = a própria, nas 6 variáveis"] = (
    all(a_[f"{v}_nucleo"].eq_missing(serie_e(B, v)).all() and a_[f"{v}_mun"].eq_missing(serie_e(A, v)).all() for v in m.EXPO)
    and not (a_["tmean_mun"] == a_["tmean_nucleo"]).any())
res["série do recorte: *_nucleo = núcleo do cidade_nucleo (fora de ordem), nas 6 variáveis"] = all(
    sr.filter(pl.col("recorte_principal") == r).sort("data")[f"{v}_nucleo"].eq_missing(serie_e(NUCLEO[r], v)).all()
    for r in NUCLEO for v in m.EXPO)


# _rm_nv contra cálculo independente, nas 6 variáveis e na cobertura inteira
def rm_esperado(rec, v):
    ms = [x for x in muns if REC[x] == rec]
    xs = {x: serie_e(x, v, grade=False).to_numpy() for x in ms}
    num = sum(np.where(np.isnan(xs[x]), 0, xs[x] * W[x]) for x in ms)
    den = sum(np.where(np.isnan(xs[x]), 0, W[x]) for x in ms)
    return np.where(den > 0, num / np.where(den > 0, den, 1), np.nan)


def iguais(a, b):
    return a.shape == b.shape and np.array_equal(np.isnan(a), np.isnan(b)) and np.allclose(a, b, atol=1e-9, rtol=0, equal_nan=True)


res["_rm_nv = Σ w·x / Σ w sobre quem tem dado, nas 6 variáveis, nos 2 recortes (cobertura inteira)"] = all(
    iguais(er.filter(pl.col("recorte_principal") == r).sort("data")[f"{v}_rm_nv"].to_numpy(), rm_esperado(r, v))
    for r in NUCLEO for v in m.EXPO)

# (m) recorte = soma dos municípios, célula a célula, em todas as contagens; gestações em risco
r2 = sr.filter(pl.col("recorte_principal") == "R2").sort("data")
r1 = sr.filter(pl.col("recorte_principal") == "R1").sort("data")
c_ = sm.filter(pl.col("CD_MUN6") == Cm).sort("data")
res["(m) contagens do R2 = A + B e do R1 = C, célula a célula, com NA no mesmo lugar"] = (
    all((a_[c].cast(pl.Int64) + b_[c].cast(pl.Int64)).eq_missing(r2[c].cast(pl.Int64)).all()
        and c_[c].cast(pl.Int64).eq_missing(r1[c].cast(pl.Int64)).all() for c in m.contagens(sm))
    and r2.filter(pl.col("data").dt.year() == 2011)["nv_unicos"].null_count() == 365
    and r2.filter(pl.col("data") >= D("2024-12-25"))["obito_neonatal_precoce"].null_count() == 14
    and r2.filter(pl.col("data").dt.year() == 2011)["nv_gestacao_sens2011"].unique().to_list() == [14]
    and r2["n_municipios"].unique().to_list() == [2] and r2["CD_MUN6_NUCLEO"].unique().to_list() == [B])
gr_m = pl.DataFrame({"CD_MUN6": [A, B, B, Cm], "data": [D("2015-01-01")] * 4, "semana": [30, 30, 31, 30],
                     "z_nv": [3, 4, 1, 9], "z_fetal": [0, 1, 0, 0]}).with_columns(pl.col("z_nv", "z_fetal").cast(pl.Int32))
res["(m) gestações em risco do R2 = A + B por dia e semana"] = m.gestacoes_recorte(gr_m.lazy(), mun).sort(
    "recorte_principal", "semana").rows() == [("R1", D("2015-01-01"), 30, 9, 0), ("R2", D("2015-01-01"), 30, 7, 1),
                                              ("R2", D("2015-01-01"), 31, 1, 0)]
res["conferir_somas aceita a série correta"] = not para(m.conferir_somas, sm, sr, "teste", log)


# (o) PM2.5: NA do núcleo continua NA; zero fica zero; renormalização
def val(rec, d, col):
    return sr.filter((pl.col("recorte_principal") == rec) & (pl.col("data") == d))[col].item()


a_pm = a_.filter(pl.col("data") == d_pm)
res["(o) pm25_nucleo = NA no dia sem dado do núcleo (recorte e periferia); pm25_mun da periferia = 0"] = (
    val("R2", d_pm, "pm25_nucleo") is None and a_pm["pm25_nucleo"].item() is None and a_pm["pm25_mun"].item() == 0.0)
res["(o) zero entra no _rm_nv (= 0 com o núcleo sem dado)"] = val("R2", d_pm, "pm25_rm_nv") == 0.0
res["_rm_nv: núcleo sem dado -> valor da periferia; os dois sem dado -> NA"] = (
    np.isclose(val("R2", d_so_nuc, "pm25_zero_na_rm_nv"),
               e.filter((pl.col("CD_MUN6") == A) & (pl.col("data") == d_so_nuc))["pm25_zero_na"].item())
    and val("R2", d_ambos, "pm25_zero_na_rm_nv") is None and val("R2", d_ambos, "pm25_zero_na_nucleo") is None)

# matrizes semanais: todas as células, contra média móvel própria (pandas rolling)
n_s = (m.S_FIM - m.S_INI).days + 1
idx = (m.S_INI - m.clima_ini()).days + np.arange(n_s)[:, None] + 7 * np.arange(37)[None, :]


def mat_esperada(x):
    m7 = pd.Series(x).rolling(7, min_periods=7).mean().shift(-6).to_numpy()   # média dos dias d..d+6
    out = np.full((n_s, 37), np.nan)
    ok = idx < len(m7)
    out[ok] = m7[idx[ok]]
    return out


COL = {"tmean": "tmean", "rh": "rh", "pm25": "pm25"}
ok_mat, n_cel = True, 0
datas_s = pl.date_range(m.S_INI, m.S_FIM, "1d", eager=True)
for var in m.SEMANAIS:
    mt = m.matrizes_semanais(e, er, nuc, muns, var)
    esperado = {"mun": {x: serie_e(x, COL[var], grade=False).to_numpy() for x in muns},
                "nucleo": {r: serie_e(NUCLEO[r], COL[var], grade=False).to_numpy() for r in NUCLEO},
                "rm_nv": {r: rm_esperado(r, COL[var]) for r in NUCLEO}}
    for versao, tab in mt.items():
        chave = tab.columns[0]
        ok_mat &= chave == ("CD_MUN6" if versao == "mun" else "recorte_principal") and tab.width == 2 + 37
        ok_mat &= len(tab) == len(esperado[versao]) * n_s
        for u, x in esperado[versao].items():
            t = tab.filter(pl.col(chave) == u).sort("dum_est")
            ok_mat &= t["dum_est"].equals(datas_s)
            obs = t.select([f"s{k:02d}" for k in range(1, 38)]).to_numpy()
            ok_mat &= iguais(obs, mat_esperada(x))
            n_cel += obs.size
res[f"matrizes: todas as {n_cel} células das 9 matrizes = média móvel própria (NA no mesmo lugar)"] = ok_mat

xx = np.tile(np.arange(len(serie_e(A, "tmean", grade=False)), dtype=float), (2, 1)); xx[1, 20] = np.nan
mx = m.medias_semanais(xx, m.clima_ini())
res["medias_semanais: dia NaN anula só as semanas que o contêm"] = (
    np.isclose(mx[0, 0, 0], 3.0) and np.isclose(mx[0, 1, 2], 1 + 14 + 3) and np.isnan(mx[1, 14, 0])
    and np.isnan(mx[1, 20, 0]) and not np.isnan(mx[1, 21, 0]) and np.isnan(mx[1, 0, 2]) and not np.isnan(mx[1, 0, 3]))

# dias faltantes de PM2.5 (E16), com faltas em 2011 e em 2025 (dentro da grade, fora de 2012–2024)
nuc_csv = pd.DataFrame({"CD_RECORTE": ["R2", "R1"], "NM_RECORTE": ["Dois", "Um"], "CD_MUN_NUCLEO": [B + "0", Cm + "0"]})
fa = m.dias_faltantes_pm25(e, er, mun, nuc_csv)


def lin(rec, var, versao):
    return fa[(fa.recorte_principal == rec) & (fa.variante == var) & (fa.versao == versao)].iloc[0]


n_, r_, u_, lo = lin("R2", "pm25_zero_na", "nucleo"), lin("R2", "pm25_zero_na", "rm_nv"), lin("R2", "pm25_zero_na", "mun"), \
    lin("R2", "pm25_local_zero_na", "rm_nv")
res["dias_faltantes_pm25: grade × 2012–2024, renormalizados e município-dias"] = (
    n_.n_faltantes_grade == 4 and n_.n_faltantes_2012_2024 == 2 and n_.primeira_falta == d_2011 and n_.ultima_falta == d_2025
    and n_.n_dias_grade == ng and r_.n_faltantes_grade == 1 and r_.n_dias_renormalizados_grade == 3
    and r_.n_dias_renormalizados_2012_2024 == 1 and u_.n_faltantes_grade == 5 and u_.n_municipios_com_falta == 2
    and u_.n_dias_grade == 2 * ng and lo.n_dias_renormalizados_grade == 1 and lo.n_faltantes_grade == 0
    and fa[fa.recorte_principal == "R1"].n_faltantes_grade.sum() == 0 and len(fa) == 2 * 4 * 3)

# ramos de parada (A6, A7, A8, A9, A14)
mais1 = lambda df, col, cond: df.with_columns(pl.when(cond).then(pl.col(col) + 1).otherwise(pl.col(col)).alias(col))
eh = lambda mm, d: (pl.col("CD_MUN6") == mm) & (pl.col("data") == d)
res["para: contagem da série estendida diferente do 06b (A6)"] = para(m.conferir_entrada, mais1(sm, "nv_unicos", eh(A, d0)), s, log)
res["para: recorte que não soma os municípios"] = para(m.conferir_somas, sm, mais1(sr, "ptb", pl.col("data") == d0), "x", log)
res["para: NA só num município do recorte no mesmo dia"] = para(
    m.serie_recorte, sm.with_columns(nv_unicos=pl.when(eh(A, d0)).then(None).otherwise(pl.col("nv_unicos"))), er, nuc, log)
res["para: flag diferente entre municípios do recorte"] = para(
    m.serie_recorte, sm.with_columns(periodo_principal=pl.when(eh(A, d0)).then(False).otherwise(pl.col("periodo_principal"))),
    er, nuc, log)
res["para: tipo_recorte misto no mesmo recorte (A7)"] = para(
    m.serie_recorte, sm.with_columns(tipo_recorte=pl.when(pl.col("CD_MUN6") == A).then(pl.lit("outro")).otherwise(pl.col("tipo_recorte"))),
    er, nuc, log)
res["para: data nula no clima (A8)"] = para(m.exposicao_municipal, clima.with_columns(
    data=pl.when(eh(A, d0)).then(None).otherwise(pl.col("data"))), pm, muns, log)
res["para: dia faltando no clima e no PM2.5"] = (para(m.exposicao_municipal, clima.filter(~eh(A, d0)), pm, muns, log)
                                                and para(m.exposicao_municipal, clima, pm.filter(~eh(B, d0)), muns, log))
res["para: série do 06b com dia faltando ou flag nula"] = (
    para(m.serie_municipio_clima, s.filter(pl.col("data") != d0), e, er, mun, log)
    and para(m.serie_municipio_clima, s.with_columns(periodo_sens2011=pl.when(eh(A, d0)).then(None)
                                                    .otherwise(pl.col("periodo_sens2011"))), e, er, mun, log))
res["pivô: para com dia faltando"] = para(m.pivo, e.filter(~eh(A, d0)), "CD_MUN6", "tmean", muns)
cl_nan = clima.with_columns(tmean=pl.when(eh(Cm, d0)).then(float("nan")).otherwise(pl.col("tmean")))
e_nan = m.exposicao_municipal(cl_nan, pm, muns, log)
res["NaN na entrada vira NA (null), não NaN"] = (e_nan.filter(eh(Cm, d0))["tmean"].item() is None
                                                and e_nan.select(pl.col("tmean").is_nan().sum()).item() == 0)
n0 = m.N_MUNICIPIOS
m.N_MUNICIPIOS = 3
mc = pd.DataFrame({"CD_MUN6": muns, "CD_RECORTE": [REC[x] for x in muns], "TIPO_RECORTE": [TIPO[REC[x]] for x in muns]})
nc = pd.DataFrame({"CD_RECORTE": ["R2", "R1"], "CD_MUN_NUCLEO": [B + "0", Cm + "0"]})
res["conferir_recortes: aceita o certo; para com recorte repetido/faltando, núcleo fora, tipo misto (A9)"] = (
    not para(m.conferir_recortes, mc, nc, log)
    and para(m.conferir_recortes, mc, pd.DataFrame({"CD_RECORTE": ["R2", "R2"], "CD_MUN_NUCLEO": [B + "0", A + "0"]}), log)
    and para(m.conferir_recortes, mc, pd.DataFrame({"CD_RECORTE": ["R2", "R1"], "CD_MUN_NUCLEO": [Cm + "0", Cm + "0"]}), log)
    and para(m.conferir_recortes, mc.assign(TIPO_RECORTE=["arranjo", "outro", "municipio_isolado"]), nc, log))
m.N_MUNICIPIOS = n0

# ---------------------------------------------------------------------------- main() inteiro, 12 municípios
C = m.C
T = C.TMP / "teste_06c_main"
pastas = {k: T / k for k in ("proc", "rm", "logs", "tmp")}
for p in pastas.values():
    p.mkdir(parents=True, exist_ok=True)
muns12 = [f"3{r}{i:04d}" for r in (1, 2, 3) for i in range(1, 5)]
rec12 = {x: f"RC{x[1]}" for x in muns12}
tipo12 = {"RC1": "arranjo", "RC2": "arranjo", "RC3": "municipio_isolado"}
nuc12 = {"RC3": muns12[10], "RC1": muns12[2], "RC2": muns12[5]}          # fora de ordem; núcleo ≠ 1º município
cl12, pm12, s12 = sintetico(muns12, rec12, tipo12)
ano = f"{C.CLIMA_INI[:4]}_{C.CLIMA_FIM[:4]}"
cl12.write_parquet(pastas["proc"] / f"clima_municipio_diario_{ano}.parquet")
pm12.write_parquet(pastas["proc"] / f"pm25_municipio_diario_{ano}.parquet")
pl.DataFrame({"CD_MUN6": [x for k, x in enumerate(muns12) for _ in range(k + 1)]}).write_parquet(pastas["proc"] / "nascimentos.parquet")
s12.write_parquet(pastas["proc"] / "serie_diaria_municipio.parquet")
s12.write_parquet(pastas["proc"] / "serie_diaria_municipio_sem_coorte_fixa.parquet")
gr_ok = pl.DataFrame({"CD_MUN6": muns12[:3], "data": [D("2016-01-01")] * 3, "semana": [25, 25, 26],
                      "z_nv": [1, 2, 3], "z_fetal": [0, 1, 0]}).with_columns(pl.col("z_nv", "z_fetal").cast(pl.Int32),
                                                                             pl.col("semana").cast(pl.Int16))
gr_ok.write_parquet(pastas["proc"] / "gestacoes_em_risco.parquet")
pd.DataFrame({"CD_RECORTE": [rec12[x] for x in muns12], "TIPO_RECORTE": [tipo12[rec12[x]] for x in muns12],
              "CD_MUN": [x + "0" for x in muns12], "CD_MUN6": muns12}).to_csv(pastas["rm"] / "concentracoes_urbanas_municipios.csv", index=False)
pd.DataFrame({"CD_RECORTE": list(nuc12), "NM_RECORTE": [f"nome {r}" for r in nuc12],
              "CD_MUN_NUCLEO": [x + "0" for x in nuc12.values()]}).to_csv(pastas["rm"] / "cidade_nucleo.csv", index=False)
orig = {k: getattr(C, k) for k in ("PROC", "RM", "LOGS", "TMP")}
integ_real = orig["LOGS"] / "integridade.csv"
md5_integ = hashlib.md5(integ_real.read_bytes()).hexdigest() if integ_real.exists() else None
C.PROC, C.RM, C.LOGS, C.TMP = pastas["proc"], pastas["rm"], pastas["logs"], pastas["tmp"]
m.N_MUNICIPIOS = 12
argv0 = sys.argv
sys.argv = ["06c_exposicao.py", "--rascunho"]
try:
    m.main(); ok_main = True
except SystemExit:
    ok_main = False
destino = pastas["tmp"] / "rascunho_06c"
esperados = ([f"serie_diaria_{n}{s_}.parquet" for n in ("municipio_clima", "recorte") for s_ in ("", "_sem_coorte_fixa")]
             + ["gestacoes_em_risco_recorte.parquet"]
             + [f"expo_semanal_{v}_{x}.parquet" for v in m.SEMANAIS for x in ("nucleo", "rm_nv", "mun")])
srm = pl.read_parquet(destino / "serie_diaria_recorte.parquet") if ok_main else None
nuc_ok = ok_main and all(
    srm.filter(pl.col("recorte_principal") == r).sort("data")["tmean_nucleo"].eq_missing(
        cl12.filter((pl.col("CD_MUN6") == n) & pl.col("data").is_between(m.GRADE_INI, m.GRADE_FIM)).sort("data")["tmean"]).all()
    for r, n in nuc12.items())
res["main(): roda, grava os 14 parquets e o CSV, esvazia o staging, núcleo pelo cidade_nucleo fora de ordem"] = (
    ok_main and all((destino / f).exists() for f in esperados) and (destino / "dias_faltantes_pm25.csv").exists()
    and not (destino / "_staging_06c").exists() and nuc_ok
    and (hashlib.md5(integ_real.read_bytes()).hexdigest() if integ_real.exists() else None) == md5_integ)
# falha no meio (gestação em risco de município fora do recorte): nada do destino muda (A10)
antes = {f: hashlib.md5((destino / f).read_bytes()).hexdigest() for f in esperados} if ok_main else {}
gr_ok.with_columns(CD_MUN6=pl.lit("999999")).write_parquet(pastas["proc"] / "gestacoes_em_risco.parquet")
falhou = para(m.main)
depois = {f: hashlib.md5((destino / f).read_bytes()).hexdigest() for f in esperados} if ok_main else {1: 1}
res["main(): falha no meio para sem substituir nenhuma saída do destino (staging, A10)"] = (
    falhou and antes == depois and (destino / "_staging_06c" / "serie_diaria_recorte.parquet").exists())
gr_ok.write_parquet(pastas["proc"] / "gestacoes_em_risco.parquet")
sys.argv = argv0
for k, v in orig.items():
    setattr(C, k, v)
m.N_MUNICIPIOS = n0

for kk, v in res.items():
    print("OK   " if v else "FALHA", kk)
falhas = sum(not v for v in res.values())
print(f"{len(res) - falhas}/{len(res)} casos OK")
sys.exit(1 if falhas else 0)
