"""Teste sintético do 06d (gestações em risco): casos feitos à mão e uma comparação semana a semana
com força bruta em gestações sintéticas sorteadas (nenhum dado real).

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/teste_06d_sintetico.py
    ALVO_DIR=../_tmp/diffs/c1/novo PYTHONPATH=. uv run python testes/teste_06d_sintetico.py
Sai com código 1 se algum caso falhar.
"""
import datetime as dt
import importlib.util
import os
import sys
from pathlib import Path

import numpy as np
import pandas as pd

ALVO = Path(os.environ.get("ALVO_DIR", Path(__file__).resolve().parent.parent))
sp = importlib.util.spec_from_file_location("m06d", ALVO / "06d_gestacoes_em_risco.py")
m = importlib.util.module_from_spec(sp); sp.loader.exec_module(m)
res = {}
n_dias = (m.FIM - m.D0).days + 1
d = lambda date: (date - m.D0).days
k = lambda j: j - 22

s = dt.date(2015, 1, 1)
g = lambda ig, mun="A", s=s: {"CD_MUN6": mun, "s": s, "termino": s + dt.timedelta(days=7 * ig + 3), "ig": ig}
G = pd.DataFrame([g(22), g(23), g(40), g(30, "B")])
Z = m.contar(G, {"A": 0, "B": 1}, n_dias)
res["soma = dias em risco (4 + 11 + 130 + 60)"] = int(Z.sum()) == m.dias_em_risco(G) == 4 + 11 + 130 + 60
res["dia s+154: 3 gestações de A na semana 22"] = Z[0, k(22), d(s + dt.timedelta(days=154))] == 3
res["dia s+158: 2 em A (a de IG 22 terminou em s+157)"] = Z[0, k(22), d(s + dt.timedelta(days=158))] == 2
t = s + dt.timedelta(days=161)
res["dia s+161: 2 em A na semana 23, 0 na 22"] = Z[0, k(23), d(t)] == 2 and Z[0, k(22), d(t)] == 0
res["o dia do término conta (s+164: 2 em A)"] = Z[0, k(23), d(s + dt.timedelta(days=164))] == 2
res["dia seguinte ao término (s+165: 1 em A)"] = Z[0, k(23), d(s + dt.timedelta(days=165))] == 1
res["município B separado (semana 30 no dia s+213)"] = Z[1, k(30), d(s + dt.timedelta(days=213))] == 1 and Z[1].sum() == 60

# força bruta semana a semana, em 3.000 gestações sorteadas, 3 municípios, 40 dias sorteados
rng = np.random.default_rng(20261001)
n = 3000
ss = [dt.date(2011, 7, 31) + dt.timedelta(days=int(x)) for x in rng.integers(0, 4600, n)]
igs = rng.integers(22, 43, n)
R = pd.DataFrame({"CD_MUN6": rng.choice(["A", "B", "C"], n), "s": ss,
                  "termino": [a + dt.timedelta(days=int(7 * i + 3)) for a, i in zip(ss, igs)], "ig": igs})
R = R[R["termino"] <= m.FIM]
Z = m.contar(R, {"A": 0, "B": 1, "C": 2}, n_dias)
dif = 0
for t in [dt.date(2012, 1, 1) + dt.timedelta(days=int(x)) for x in rng.integers(0, 4700, 40)]:
    for mi, mun in enumerate("ABC"):
        r = R[R["CD_MUN6"] == mun]
        sem = np.array([(t - a).days // 7 for a in r["s"]])
        vivo = np.array([e >= t for e in r["termino"]])
        for j in range(22, 43):
            dif += abs(int(((sem == j) & vivo).sum()) - int(Z[mi, k(j), d(t)]))
res["força bruta semana a semana (3.000 gestações, 40 dias, 3 municípios): 0 diferenças"] = dif == 0
for kk, v in res.items():
    print("OK   " if v else "FALHA", kk)
falhas = sum(not v for v in res.values())
print(f"{len(res) - falhas}/{len(res)} casos OK")
sys.exit(1 if falhas else 0)
