"""Teste da interface de acesso em Python (09_acesso/acesso.py) contra a base. Lê microdado na Forja; imprime só
agregados. Grava em _tmp/teste_acesso/ duas matrizes de exposição (públicas) e um resumo AGREGADO da ligação com
os nascimentos (somas sobre 2.000 nascimentos; nenhuma linha individual), que o teste em R compara com os dele.

Uso (de 00_scripts/; rodar ANTES do teste em R):
    PYTHONPATH=. uv run python testes/teste_acesso.py
Sai com código 1 se algum caso falhar.
"""
import contextlib
import io
import os
import subprocess
import sys
from pathlib import Path

import config as C  # noqa: F401  (só caminhos; o acesso.py fixa o spill do polars antes de importá-lo)

sys.path.insert(0, str(C.ROOT / "09_acesso"))
import acesso as A  # noqa: E402
import numpy as np  # noqa: E402
import polars as pl  # noqa: E402

res = {}
OUT = C.TMP / "teste_acesso"
OUT.mkdir(parents=True, exist_ok=True)


def mesma_matriz(a: pl.DataFrame, b: pl.DataFrame, tol=1e-9) -> tuple[bool, str]:
    k = a.columns[0]
    a, b = a.sort(k, "dum_est"), b.sort(k, "dum_est")
    if a.columns != b.columns or len(a) != len(b) or not a[k].equals(b[k]) or not a["dum_est"].equals(b["dum_est"]):
        return False, "estrutura diferente"
    x = a.select(pl.col(r"^s\d\d$")).to_numpy().astype(float)
    y = b.select(pl.col(r"^s\d\d$")).to_numpy().astype(float)
    na = int((np.isnan(x) != np.isnan(y)).sum())
    ok = ~np.isnan(x) & ~np.isnan(y)
    d = float(np.abs(x[ok] - y[ok]).max()) if ok.any() else 0.0
    return na == 0 and d < tol, f"dif máx {d:.1e}; NA discordantes {na}; {x.size} células"


man = A.manifesto()
res["versão e manifesto"] = (A.versao() == man["versao"] and len(man["arquivos"]) > 0, A.versao())
ver = A.verificar()
res["md5 de todos os arquivos = manifesto"] = (all(ver.values()), f"{sum(ver.values())}/{len(ver)}")
for var in ("tmean", "rh", "pm25"):
    for v in ("nucleo", "rm_nv", "mun"):
        ok, det = mesma_matriz(A.matriz_semanal(var, v), A.expo_semanal(var, v))
        res[f"matriz_semanal('{var}', '{v}') = expo_semanal gravada pelo 06c"] = (ok, det)
err = io.StringIO()
with contextlib.redirect_stderr(err):
    A._avisados.clear()
    n = A.nascimentos(["id_nasc", "CD_MUN6", "data", "ga_sem", "unico"])
res["aviso de sigilo (stderr) ao ler microdado"] = ("microdado" in err.getvalue(), "")
# spill: processo limpo, SEM o config.py (que também fixa as variáveis) e sem POLARS_* no ambiente (B3)
amb = {k: v for k, v in os.environ.items() if not k.startswith("POLARS_") and k != "PYTHONPATH"}
r = subprocess.run([sys.executable, "-c", f"import os, sys; sys.path.insert(0, {str(C.ROOT / '09_acesso')!r}); import acesso; "
                    "print(os.environ.get('POLARS_TEMP_DIR'), os.environ.get('POLARS_OOC_SPILL_DIR'), 'config' in sys.modules)"],
                   capture_output=True, text=True, env=amb, cwd="/")
res["spill do polars na _tmp/ da Forja, num processo sem config.py"] = (
    r.stdout.split() == [str(C.ROOT / "_tmp"), str(C.ROOT / "_tmp"), "False"], r.stdout.strip()[-60:])
cc = A.ler("logs/pig_concordancia.csv")
tot = cc.filter(pl.col("ano") == "2012-2024")
res["CSV: célula vazia entre aspas vira null (B4)"] = (len(tot) > 0 and tot["n"].null_count() == len(tot), f"{len(tot)} linhas")
def _b7():
    try:
        A.verificar(["06_processados/nao_existe.parquet"]); fora = False
    except KeyError:
        fora = True
    except Exception:  # noqa: BLE001 — outro erro (ex.: "ausente") não é o esperado
        fora = False
    try:
        um, vazio = list(A.verificar("06_processados/calendario_2010_2025.parquet").values()), A.verificar([])
    except Exception:  # noqa: BLE001
        return False
    return um == [True] and vazio == {} and fora


res["verificar: um caminho em texto; [] confere nada; caminho fora do manifesto dá erro (B7)"] = (_b7(), "")
ent = {a["caminho"]: a for a in man["arquivos"]}
res["nascimentos: nº de linhas = manifesto"] = (len(n) == ent["06_processados/nascimentos.parquet"]["n_linhas"], "")
for nivel, cf, arq in (("recorte", True, "serie_diaria_recorte"), ("municipio", False, "serie_diaria_municipio_clima_sem_coorte_fixa")):
    s = A.serie_diaria(nivel, cf, ["data"])
    res[f"serie_diaria('{nivel}', coorte_fixa={cf}) = {arq}"] = (len(s) == ent[f"06_processados/{arq}.parquet"]["n_linhas"], "")
p = A.pig(["id_nasc", "pop_pig_principal"], com_nascimentos=["ano"])
res["pig(com_nascimentos=['ano']): uma linha por classificado"] = (
    len(p) == ent["06_processados/pig_classificacao.parquet"]["n_linhas"] and p["ano"].null_count() == 0, "")

# ligar_expo_semanal: amostra determinística, refeita igual no teste em R (os 2.000 menores id_nasc elegíveis)
amostra = n.filter(pl.col("unico") & pl.col("ga_sem").is_between(37, 42) & (pl.col("data").dt.year() >= 2012)).sort("id_nasc").head(2000)
lig = A.ligar_expo_semanal(amostra, "tmean", "nucleo")
cl = A.clima_municipal(["CD_MUN6", "data", "tmean"])
nuc = A.cidade_nucleo().select(pl.col("CD_RECORTE").alias("recorte_principal"), pl.col("CD_MUN_NUCLEO").str.slice(0, 6).alias("NUC"))
lig = lig.join(nuc, on="recorte_principal")
dif = 0.0
for r in lig.select("NUC", "dum_est", "s05").iter_rows():
    ini = r[1] + __import__("datetime").timedelta(days=28)
    x = cl.filter((pl.col("CD_MUN6") == r[0]) & pl.col("data").is_between(ini, ini + __import__("datetime").timedelta(days=6)))["tmean"]
    dif = max(dif, abs(x.mean() - r[2]))
res["ligar_expo_semanal: mesmas linhas; s05 = média dos dias 28–34 desde a DUM (2.000 sorteios)"] = (
    len(lig) == len(amostra) and lig["s05"].null_count() == 0 and dif < 1e-9, f"dif máx {dif:.1e}")
lig2 = A.ligar_expo_semanal(amostra, "tmean", "nucleo")
res["ligar_expo_semanal: mesma ordem de linhas e colunas = entrada + dum_est + recorte_principal + s01..s37"] = (
    lig2["id_nasc"].equals(amostra["id_nasc"])
    and lig2.columns == [*amostra.columns, "dum_est", "recorte_principal", *[f"s{k:02d}" for k in range(1, 38)]], "")
l0 = A.ligar_expo_semanal(amostra, "tmean", "nucleo", ajuste_dias=0)
l6 = A.ligar_expo_semanal(amostra, "tmean", "nucleo", ajuste_dias=6)
res["ligar_expo_semanal: ajuste +0/+6 desloca a DUM em 3 dias para cada lado"] = (
    ((l0.sort("id_nasc")["dum_est"] - lig.sort("id_nasc")["dum_est"]).dt.total_days() == 3).all()
    and ((lig.sort("id_nasc")["dum_est"] - l6.sort("id_nasc")["dum_est"]).dt.total_days() == 3).all(), "")

# insumos do teste em R (mesmo cálculo nas duas linguagens)
A.matriz_semanal("pm25_zero_na", "rm_nv").write_parquet(OUT / "py_pm25_zero_na_rm_nv.parquet")
A.matriz_semanal("tmax", "nucleo").write_parquet(OUT / "py_tmax_nucleo.parquet")
sem = [f"s{k:02d}" for k in range(1, 38)]
resumo = lig2.select(pl.len().alias("n"), pl.col("recorte_principal").n_unique().alias("n_recortes"),
                     (pl.col("dum_est") - pl.date(2010, 1, 1)).dt.total_days().sum().alias("soma_dias_dum"),
                     *[pl.col(s).sum().alias(f"soma_{s}") for s in sem], *[pl.col(s).null_count().alias(f"na_{s}") for s in sem])
resumo.write_csv(OUT / "py_ligar_resumo.csv")   # agregado (somas); nenhuma linha individual sai do processo

for k, (ok, det) in res.items():
    print("OK   " if ok else "FALHA", k, "|", det)
f = sum(not ok for ok, _ in res.values())
print(f"{len(res) - f}/{len(res)} casos OK")
sys.exit(1 if f else 0)
