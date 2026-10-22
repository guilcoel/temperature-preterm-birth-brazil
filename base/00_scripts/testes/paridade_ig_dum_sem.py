"""Paridade R × Python da `ig_dum_sem` pelas funções da interface (`nascimentos`, `pig(com_nascimentos)`), na raiz
que a interface resolver: a base (padrão), a base sintética do teste_ig_dum_sem_sintetico.py ou uma raiz de conferência
(DADOS_PERINATAIS_CLIMA_RAIZ). Lê microdado na Forja; grava e imprime só agregados.

Grava em _tmp/paridade_ig_dum_sem/py_<versao>.csv (agregado sem máscara: tratar como restrito; vai para o trash no
fim da troca), que o paridade_ig_dum_sem.R compara com o dele, e o resultado em logs/paridade_ig_dum_sem_py_*.log:
- frequência por ano × valor (NA incluído), em `nascimentos()` e em `pig(com_nascimentos)`;
- checksum que amarra o valor ao registro: Σ (id_nasc mod 1.000.003) × (ig_dum_sem + 1), NA = 0 (inteiro exato,
  < 2^53 em double; troca de valor entre registros muda a soma, o que a frequência não pega).
Confere aqui que a junção pig × nascimentos é um para um: id_nasc único nos dois, todo id do pig no nascimentos,
`pig(com_nascimentos)` com o mesmo nº de linhas e a mesma ordem do pig.

Uso (de 00_scripts/; depois, da raiz, o paridade_ig_dum_sem.R com a mesma DADOS_PERINATAIS_CLIMA_RAIZ):
    PYTHONPATH=. uv run python testes/paridade_ig_dum_sem.py
    DADOS_PERINATAIS_CLIMA_RAIZ=<raiz> PYTHONPATH=. uv run python testes/paridade_ig_dum_sem.py
Sai com código 1 se algum caso falhar.
"""
import sys
from pathlib import Path

RAIZ_BASE = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(RAIZ_BASE / "09_acesso"))
import acesso as A  # noqa: E402  (antes do polars)
import polars as pl  # noqa: E402

P = 1_000_003
OUT = RAIZ_BASE / "_tmp" / "paridade_ig_dum_sem"
OUT.mkdir(parents=True, exist_ok=True)
res = {}


def resumo(df: pl.DataFrame, fonte: str) -> pl.DataFrame:
    freq = df.group_by("ano", "ig_dum_sem").agg(pl.len().cast(pl.Int64).alias("n")).with_columns(
        pl.lit(fonte).alias("fonte"), pl.lit("freq").alias("medida"))
    chk = df.select(pl.lit(fonte).alias("fonte"), pl.lit("checksum").alias("medida"), pl.lit(None, pl.Int16).alias("ano"),
                    pl.lit(None, pl.Int16).alias("ig_dum_sem"),
                    ((pl.col("id_nasc") % P) * (pl.col("ig_dum_sem").cast(pl.Int64) + 1).fill_null(0)).sum().alias("n"))
    return pl.concat([freq.select("fonte", "medida", "ano", "ig_dum_sem", "n"),
                      chk.select("fonte", "medida", pl.col("ano").cast(pl.Int16), pl.col("ig_dum_sem").cast(pl.Int16), "n")])


v = A.versao()
n = A.nascimentos(["id_nasc", "ano", "ig_dum_sem"])
res["nascimentos: ig_dum_sem é Int16"] = (n.schema["ig_dum_sem"] == pl.Int16, str(n.schema["ig_dum_sem"]))
res["nascimentos: id_nasc único"] = (n["id_nasc"].is_unique().all(), f"{len(n):,} linhas")
p0 = A.pig(["id_nasc"])
p = A.pig(["id_nasc"], com_nascimentos=["ano", "ig_dum_sem"])
p_txt = A.pig("id_nasc", com_nascimentos="ig_dum_sem")          # a forma documentada, com texto (achado 2)
res["pig('id_nasc', com_nascimentos='ig_dum_sem') = forma com lista"] = (
    p_txt.equals(p.select("id_nasc", "ig_dum_sem")), f"{len(p_txt):,} linhas")
res["pig: id_nasc único"] = (p0["id_nasc"].is_unique().all(), f"{len(p0):,} linhas")
res["pig: todo id_nasc está no nascimentos"] = (p0.join(n, on="id_nasc", how="anti").height == 0, "")
res["pig(com_nascimentos): mesmo nº de linhas e mesma ordem do pig (junção 1:1)"] = (
    p["id_nasc"].equals(p0["id_nasc"]) and p["ano"].null_count() == 0, "")
r = pl.concat([resumo(n, "nascimentos"), resumo(p, "pig")]).sort("fonte", "medida", "ano", "ig_dum_sem", nulls_last=True)
arq = OUT / f"py_{v}.csv"
r.write_csv(arq)                      # agregado SEM máscara (pode ter célula de 1 a 9): restrito, fica em _tmp/ da Forja
sys.path.insert(0, str(RAIZ_BASE / "00_scripts"))
import utils as U  # noqa: E402  (só para o log em logs/)

log = U.get_logger("paridade_ig_dum_sem_py")
log.info("raiz = %s | versao() = %s", A.raiz(), v)
for k, (ok, det) in res.items():
    log.info("%s %s | %s", "OK   " if ok else "FALHA", k, det)
f = sum(not ok for ok, _ in res.values())
log.info("%s gravado | %d/%d casos OK", arq.relative_to(RAIZ_BASE), len(res) - f, len(res))
sys.exit(1 if f else 0)
