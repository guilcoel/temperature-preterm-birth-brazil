"""Autoauditoria do descritivo da `ig_dum_sem`: refaz, com código próprio (pandas, sem as funções do 06b nem do
descritivo), cada número publicado nos CSVs do descritivo que dá para refazer só com o nascimentos.parquet, e confere
as máscaras. Lê microdado na Forja; imprime só contagens de divergência.

O que confere, célula a célula:
- tabela 1 (`descritivo_ig_dum_sem_AAAAMMDD.csv`): n, % não NA, % de 20 a 45, n comparáveis, % |dif| ≤ 1, % iguais,
  nas duas populações e em todos os anos; % não NA + soma dos % por motivo = 100 (± arredondamento);
- tabela 2a (`..._q2d_...`): n do código 8, n comparáveis e % iguais por ano e em 2012–2024, com o código lido do
  `metodo_ig` (o descritivo lê do bruto e confere que é igual);
- tabela 2b: % do código 8, % não NA, % não NA dentro e fora do código 8 e entre os em branco, e a coluna lógica;
- máscaras: "<10" só com contagem (ou, em "compl.<10", complemento) de 1 a 9; número publicado só com contagem 0 ou
  ≥ 10; e toda linha com "supr." tem ao menos um "<10" na mesma linha (no total 2012–2024 da tabela 2a, em algum ano
  da mesma população). Essa última é condição necessária, não prova que a escolha do complemento foi a mínima.
O que NÃO confere (exige o bruto, que este script não lê): os % por motivo um a um (só a soma) e a tabela 3
(`descritivo_ig_dum_sem_bissexto_*`, que depende da data da DUM). Esses vêm da autoauditoria embutida no descritivo,
que compara o arquivo com o bruto pelas funções do 06b e por uma conta independente em pandas.

Uso (de 00_scripts/):
    ORIGEM=../_tmp/rascunho_06b DATA=20261008 PYTHONPATH=. uv run python testes/autoauditoria_ig_dum_sem.py
Grava o resultado em logs/autoauditoria_ig_dum_sem_*.log. Sai com código 1 se algum número divergir.
"""
import datetime as dt
import os
import sys
from pathlib import Path

import config as C  # antes do polars (R8)

import numpy as np
import pandas as pd
import pyarrow.parquet as pq

R = Path(os.environ.get("ORIGEM", C.PROC)).resolve()
DATA = os.environ.get("DATA", dt.date.today().strftime("%Y%m%d"))
t1 = pd.read_csv(C.LOGS / f"descritivo_ig_dum_sem_{DATA}.csv", dtype=str)
t2 = pd.read_csv(C.LOGS / f"descritivo_ig_dum_sem_q2d_{DATA}.csv", dtype=str)
n = pq.read_table(R / "nascimentos.parquet", columns=["ano", "unico", "ga_sem", "coorte_fixa_22", "metodo_ig",
                                                     "ig_dum_sem"]).to_pandas()
ig = n["ig_dum_sem"].astype("float")
ga = n["ga_sem"].astype("float")
n = n.assign(nao_na=ig.notna(), f2045=ig.between(20, 45), comp=ig.between(20, 45) & ga.notna(),
             conc=(ig.between(20, 45) & ga.notna() & ((ga - ig).abs() <= 1)), igual=(ig.between(20, 45) & ga.notna() & (ga == ig)),
             cod8=n["metodo_ig"].fillna("").str.strip() == "8")
falhas, conferidas = [], 0


def confere(rotulo: str, publicado: str, contagem: int, valor: str | None):
    """publicado: o que está no CSV; contagem: a que o número representa; valor: o que deveria estar escrito."""
    global conferidas
    conferidas += 1
    if publicado == "<10":
        if not 0 < contagem < 10:
            falhas.append(f"{rotulo}: '<10' com contagem fora de 1–9")
    elif publicado == "supr.":
        pass                                  # complementar: conferido no fim (precisa de um "<10" que o justifique)
    elif publicado in ("—",):
        if valor != "—":
            falhas.append(f"{rotulo}: '—' indevido")
    else:
        if 0 < contagem < 10:
            falhas.append(f"{rotulo}: número publicado com contagem de 1 a 9")
        if publicado != valor:
            falhas.append(f"{rotulo}: publicado {publicado} × refeito {valor}")


p2 = lambda a, b: "—" if b == 0 else f"{100 * a / b:.2f}"
for r in t1.to_dict("records"):
    a = int(r["ano"])
    g = n[(n["ano"] == a) & n["unico"] & (n["coorte_fixa_22"] if r["populacao"] == "nv_unicos_coorte_fixa_22" else True)]
    k = {c: int(g[c].sum()) for c in ("nao_na", "f2045", "comp", "conc", "igual")}
    rot = f"t1 {a} {r['populacao']}"
    confere(f"{rot} n", r["n"], len(g), str(len(g)))
    confere(f"{rot} pct_nao_na", r["pct_nao_na"], k["nao_na"], p2(k["nao_na"], len(g)))
    confere(f"{rot} pct_20_45", r["pct_20_45"], k["f2045"], p2(k["f2045"], len(g)))
    confere(f"{rot} n_comparaveis", r["n_comparaveis"], k["comp"], str(k["comp"]))
    confere(f"{rot} pct_concorda_1", r["pct_concorda_1"], k["conc"], p2(k["conc"], k["comp"]))
    confere(f"{rot} pct_igual", r["pct_igual"], k["igual"], p2(k["igual"], k["comp"]))
    mot = [r[c] for c in r if c.startswith("pct_na_")]
    if r["pct_nao_na"] not in ("<10", "supr.") and all(m not in ("<10", "supr.") for m in mot):
        conferidas += 1
        if abs(sum(float(m) for m in mot) + float(r["pct_nao_na"]) - 100) > 0.03:
            falhas.append(f"{rot}: % não NA + % por motivo não fecha 100")

q2a = t2[t2["tabela"] == "q2d_cod8"]
for r in q2a.to_dict("records"):
    anos = range(2012, 2025) if r["ano"] == "2012-2024" else [int(r["ano"])]
    g = n[n["ano"].isin(anos) & n["cod8"] & (n["unico"] if r["populacao"] == "nv_unicos" else True)]
    rot = f"t2a {r['ano']} {r['populacao']}"
    comp, igual = int(g["comp"].sum()), int(g["igual"].sum())
    confere(f"{rot} n_cod8", r["n_cod8"], len(g), str(len(g)))
    confere(f"{rot} n_comparaveis_cod8", r["n_comparaveis_cod8"], comp, str(comp))
    confere(f"{rot} pct_igual_cod8", r["pct_igual_cod8"], igual, p2(igual, comp))


def seguro(num: int, den: int) -> str:                # a regra publicada no descritivo (tabelas 2b e 3)
    return "—" if den == 0 else "<10" if 0 < num < 10 else "compl.<10" if 0 < den - num < 10 else p2(num, den)


vazio = n["metodo_ig"].fillna("").str.strip() == ""
for r in t2[t2["tabela"] == "cobertura_todos_nv"].to_dict("records"):
    sel = n["ano"] == int(r["ano"])
    g = n[sel]
    rot = f"t2b {r['ano']}"
    c8, nn, n8nn = int(g["cod8"].sum()), int(g["nao_na"].sum()), int((g["cod8"] & g["nao_na"]).sum())
    v, vnn = int(vazio[sel].sum()), int((vazio[sel] & g["nao_na"]).sum())
    for col, num, den in (("pct_cod8", c8, len(g)), ("pct_ig_dum_sem_nao_na", nn, len(g)), ("pct_nao_na_entre_cod8", n8nn, c8),
                          ("pct_nao_na_fora_cod8", nn - n8nn, len(g) - c8), ("pct_nao_na_entre_vazios", vnn, v)):
        conferidas += 1
        if str(r[col]) != seguro(num, den):
            falhas.append(f"{rot} {col}: publicado {r[col]} × refeito {seguro(num, den)}")
    conferidas += 1
    if (r["cobertura_passa_cod8"] == "True") != (nn > c8):
        falhas.append(f"{rot}: cobertura_passa_cod8 errado")

# "supr." precisa de uma contagem de 1 a 9 na mesma linha: publicada como "<10" ou numa célula derivada que não sai
# (t1: fora de 20–45, 20–45 sem SEMAGESTAC, |dif| > 1, |dif| = 1; t2a: código 8 não comparável, diferentes; no total
# 2012–2024 da 2a, em algum ano da mesma população)
def ocultas(g: pd.DataFrame, t: str) -> list[int]:
    if t == "t1":
        k = {c: int(g[c].sum()) for c in ("nao_na", "f2045", "comp", "conc", "igual")}
        return [k["nao_na"] - k["f2045"], k["f2045"] - k["comp"], k["comp"] - k["conc"], k["conc"] - k["igual"]]
    return [len(g) - int(g["comp"].sum()), int(g["comp"].sum()) - int(g["igual"].sum())]


for nome, tab, cols in (("t1", t1, [c for c in t1.columns if c not in ("ano", "populacao")]),
                        ("t2a", q2a, ["n_cod8", "n_comparaveis_cod8", "pct_igual_cod8"])):
    for r in tab.to_dict("records"):
        if "supr." not in [str(r[c]) for c in cols]:
            continue
        conferidas += 1
        linhas_base = [r]
        if nome == "t2a" and r["ano"] == "2012-2024":
            linhas_base = q2a[(q2a["populacao"] == r["populacao"]) & (q2a["ano"] != "2012-2024")].to_dict("records")
        pequenas = 0
        for x in linhas_base:
            pequenas += sum(str(x[c]) == "<10" for c in cols)
            if nome == "t1":
                g = n[(n["ano"] == int(x["ano"])) & n["unico"] & (n["coorte_fixa_22"] if x["populacao"] == "nv_unicos_coorte_fixa_22" else True)]
            else:
                g = n[(n["ano"] == int(x["ano"])) & n["cod8"] & (n["unico"] if x["populacao"] == "nv_unicos" else True)]
            pequenas += sum(0 < v < 10 for v in ocultas(g, nome))
        if not pequenas:
            falhas.append(f"{nome} {r['ano']} {r['populacao']}: 'supr.' sem nenhuma contagem de 1 a 9 que o justifique")

import utils as U  # noqa: E402  (só para o log em logs/)

log = U.get_logger("autoauditoria_ig_dum_sem")
log.info("nascimentos: %s (md5 %s) | CSVs do descritivo de %s", R / "nascimentos.parquet", U.md5(R / "nascimentos.parquet"), DATA)
for f in falhas:
    log.info("FALHA %s", f)
log.info("%d/%d números e máscaras do descritivo refeitos e iguais", conferidas - len(falhas), conferidas)
sys.exit(1 if falhas else 0)
