"""Conciliações pedidas pela coordenação em 07/10/2026 (A2 e A3). Lê microdado na Forja e imprime SÓ agregados:
Brasil × ano (A2) e concentração × ano (A3), com contagem < 10 = "<10".

A2 — de onde vieram os 16,4% / 13,0% (2012) → 6,0% (2024) de óbitos sem IG da pendência P-SIM: refaz a conta no SIM
     bruto do Brasil inteiro (todos os óbitos fetais do DOFET e todos os neonatais precoces do DO, de qualquer
     GRAVIDEZ), nas duas regras: "sem IG nenhuma" da P-SIM (SEMAGESTAC vazio ou 99 e GESTACAO vazia ou 9) e a da base
     (SEMAGESTAC fora de 1–47 ou igual a 9 ou 99).
A3 — Salvador e Aracaju contra a mediana das 26: eventos da série principal (coorte fixa), % de óbitos com IG válida
     (tabela individual, todos os residentes) e % de óbito fetal com município de residência ignorado NA UF do núcleo
     (o óbito com município ignorado não tem município, então não pode ser atribuído a uma concentração).

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/conciliacao_coordenacao_20261007.py
"""
import config as C  # antes do polars (R8)

import pandas as pd
import polars as pl

ANOS = list(range(2012, 2025))
ALVO = {"2927408": "Salvador/BA", "2800308": "Aracaju/SE"}
pd.set_option("display.width", 250)
pd.set_option("display.max_columns", 30)


def mascara(n) -> str:
    n = int(n)
    return "<10" if 0 < n < 10 else f"{n:,}".replace(",", ".")


def neonatal_precoce() -> pl.Expr:
    unid, qtd = pl.col("IDADE").str.slice(0, 1), pl.col("IDADE").str.slice(1, 2).cast(pl.Int32, strict=False)
    return (pl.col("TIPOBITO") == "2") & (unid.is_in(["0", "1"]) | ((unid == "2") & (qtd <= 6)))


def a2():
    sg = pl.col("SEMAGESTAC").str.strip_chars()
    gc = pl.col("GESTACAO").str.strip_chars()
    sem_psim = (sg.is_null() | (sg == "") | (sg == "99")) & (gc.is_null() | (gc == "") | (gc == "9"))
    sgi = sg.cast(pl.Int32, strict=False)
    sem_base = ~(sgi.is_between(1, 47) & (sgi != 9)).fill_null(False)   # vazio vira nulo no cast: conta como sem IG
    linhas = []
    for ano in ANOS:
        for sist, pasta, filtro in (("fetal (DOFET)", C.SIM / "_dofet" / "parquet", pl.col("TIPOBITO") == "1"),
                                    ("neonatal precoce (DO)", C.SIM / "parquet", neonatal_precoce())):
            arqs = [p for p in sorted((pasta / f"ano={ano}").glob("uf=*.parquet")) if not p.name.startswith("._")]
            r = (pl.concat([pl.scan_parquet(p).select("TIPOBITO", "IDADE", "SEMAGESTAC", "GESTACAO") for p in arqs])
                 .filter(filtro).select(pl.len().alias("n"), sem_psim.sum().alias("psim"), sem_base.sum().alias("base"))
                 .collect().row(0, named=True))
            linhas.append({"ano": ano, "tipo": sist, "denominador_todos": mascara(r["n"]),
                           "sem_IG_nenhuma_PSIM": mascara(r["psim"]), "pct_PSIM": round(100 * r["psim"] / r["n"], 1),
                           "sem_SEMAGESTAC_valido": mascara(r["base"]), "pct_sem_SEMAGESTAC": round(100 * r["base"] / r["n"], 1)})
    print("\n=== A2: Brasil inteiro, SIM bruto, todos os registros (qualquer GRAVIDEZ) ===")
    print(pd.DataFrame(linhas).to_string(index=False))


def a3():
    mun = pd.read_csv(C.RM / "concentracoes_urbanas_municipios.csv", dtype=str)
    nuc = pd.read_csv(C.RM / "cidade_nucleo.csv", dtype=str)
    uf_nuc = nuc.merge(mun[["CD_MUN", "SIGLA_UF"]], left_on="CD_MUN_NUCLEO", right_on="CD_MUN")[["CD_RECORTE", "SIGLA_UF"]]
    m = pl.from_pandas(mun[["CD_MUN6", "CD_RECORTE"]])
    s = (pl.scan_parquet(C.PROC / "serie_diaria_municipio.parquet")
         .filter(pl.col("data").dt.year().is_between(2012, 2024))
         .join(m.lazy(), on="CD_MUN6").group_by("CD_RECORTE", pl.col("data").dt.year().alias("ano"))
         .agg([pl.col(c).sum() for c in ("nv_unicos", "ptb", "obito_fetal_principal", "obito_neonatal_precoce",
                                          "obito_perinatal")]).collect().to_pandas())
    o = (pl.scan_parquet(C.PROC / "obitos_perinatais.parquet")
         .filter(pl.col("ano_obito").is_between(2012, 2024)).join(m.lazy(), on="CD_MUN6")
         .group_by("CD_RECORTE", pl.col("ano_obito").cast(pl.Int32).alias("ano"), "tipo")
         .agg(pl.len().alias("n"), pl.col("ga_sem").is_not_null().sum().alias("ig_valida"))
         .collect().to_pandas())
    o = o.pivot_table(index=["CD_RECORTE", "ano"], columns="tipo", values=["n", "ig_valida"]).reset_index()
    o.columns = ["CD_RECORTE", "ano", "ig_fetal", "ig_neo", "n_fetal_todos", "n_neo_todos"]
    a = pd.read_csv(C.LOGS / "aceite_fase1_uf_ano.csv", dtype=str)
    a = a[a.sistema == "SIM-DOFET"].drop_duplicates(["ano", "uf"])
    # "<10 casos" (máscara do aceite): para a mediana entra o limite superior, 9 / n; na tela fica "≤ x"
    pequeno = a.pct_mun_invalido.str.startswith("<")
    teto = 100 * 9 / a.n_base.astype(float)
    a["pct_mun_ign_UF"] = pd.to_numeric(a.pct_mun_invalido, errors="coerce").where(~pequeno, teto)
    a["pct_mun_ign_txt"] = a.pct_mun_ign_UF.round(2).astype(str).where(~pequeno, "≤ " + teto.round(2).astype(str))
    a["ano"] = a.ano.astype(int)
    d = (s.merge(o, on=["CD_RECORTE", "ano"]).merge(uf_nuc, on="CD_RECORTE")
         .merge(a[["ano", "uf", "pct_mun_ign_UF", "pct_mun_ign_txt"]], left_on=["SIGLA_UF", "ano"], right_on=["uf", "ano"],
                how="left"))
    d["razao_perinatal_ptb"] = d.obito_perinatal / d.ptb
    d["pct_ptb"] = 100 * d.ptb / d.nv_unicos
    d["fetal_por_mil"] = 1000 * d.obito_fetal_principal / (d.nv_unicos + d.obito_fetal_principal)
    d["neo_por_mil_nv"] = 1000 * d.obito_neonatal_precoce / d.nv_unicos
    d["pct_ig_fetal"] = 100 * d.ig_fetal / d.n_fetal_todos
    d["pct_ig_neo"] = 100 * d.ig_neo / d.n_neo_todos
    met = ["razao_perinatal_ptb", "pct_ptb", "fetal_por_mil", "neo_por_mil_nv", "pct_ig_fetal", "pct_ig_neo", "pct_mun_ign_UF"]
    med = d.groupby("ano")[met].median()
    tot = d.groupby("CD_RECORTE")[["obito_perinatal", "ptb"]].sum()
    raz = (tot.obito_perinatal / tot.ptb).sort_values()
    print("\n=== A3: razão óbito perinatal / prematuro, 2012–2024, 26 concentrações ===")
    print(f"mínimo {raz.min():.3f} | mediana {raz.median():.3f} | máximo {raz.max():.3f}")
    print("5 maiores:", ", ".join(f"{nuc.set_index('CD_RECORTE').at[k, 'NM_RECORTE']} {v:.3f}" for k, v in raz.tail(5).items()))
    for cod, nome in ALVO.items():
        x = d[d.CD_RECORTE == cod].sort_values("ano").set_index("ano")
        uf = x.SIGLA_UF.iloc[0]
        t = pd.DataFrame({
            "óbito fetal (princ.)": x.obito_fetal_principal.map(mascara),
            "neonatal precoce (princ.)": x.obito_neonatal_precoce.map(mascara),
            "prematuros": x.ptb.map(mascara),
            "razão": x.razao_perinatal_ptb.round(3), "razão med26": med.razao_perinatal_ptb.round(3),
            "% PTB": x.pct_ptb.round(2), "% PTB med26": med.pct_ptb.round(2),
            "fetal ‰": x.fetal_por_mil.round(1), "fetal ‰ med26": med.fetal_por_mil.round(1),
            "neo ‰ NV": x.neo_por_mil_nv.round(1), "neo ‰ med26": med.neo_por_mil_nv.round(1),
            "% IG fetal": x.pct_ig_fetal.round(1), "% IG fetal med26": med.pct_ig_fetal.round(1),
            "% IG neo": x.pct_ig_neo.round(1), "% IG neo med26": med.pct_ig_neo.round(1),
            f"% mun ign DOFET {uf}": x.pct_mun_ign_txt, "% mun ign med26": med.pct_mun_ign_UF.round(2),
        })
        print(f"\n--- {nome} (UF do núcleo: {uf}) ---")
        print(t.to_string())


def a5():
    """p10 observado a termo × Pedreira, e % de PIG por Pedreira na semana completa e com +3 dias interpolados."""
    ped = pl.read_csv(C.PIG / "pedreira2011_p10.csv", schema_overrides={"sexo": pl.Utf8}).select("semana", "sexo", "p10_g")
    prox = ped.with_columns(pl.col("semana") - 1).rename({"p10_g": "p10_prox"})
    ref = ped.join(prox, on=["semana", "sexo"], how="left").with_columns(
        p10_mais3=pl.when(pl.col("p10_prox").is_not_null())
        .then(pl.col("p10_g") + 3 / 7 * (pl.col("p10_prox") - pl.col("p10_g"))).otherwise(pl.col("p10_g")))
    n = (pl.scan_parquet(C.PROC / "nascimentos.parquet")
         .filter(pl.col("periodo_principal") & pl.col("unico") & pl.col("coorte_fixa_37") & pl.col("ga_sem").is_between(37, 42)
                 & pl.col("peso_g").is_not_null() & pl.col("sexo").is_in(["1", "2"]))
         .with_columns(sexo=pl.when(pl.col("sexo") == "1").then(pl.lit("M")).otherwise(pl.lit("F")),
                       semana=pl.col("ga_sem").cast(pl.Int64))
         .join(ref.lazy(), on=["semana", "sexo"]))
    p10 = (n.group_by("semana", "sexo").agg(pl.len().alias("n"), pl.col("peso_g").quantile(0.10, "linear").alias("p10_obs"),
                                             pl.col("p10_g").first().alias("p10_pedreira"))
           .with_columns(dif_g=pl.col("p10_obs") - pl.col("p10_pedreira")).sort("sexo", "semana").collect())
    pig = (n.group_by("semana").agg(pl.len().alias("n"), (100 * (pl.col("peso_g") < pl.col("p10_g")).mean()).round(2).alias("pct_semana_completa"),
                                    (100 * (pl.col("peso_g") < pl.col("p10_mais3")).mean()).round(2).alias("pct_mais3"))
           .sort("semana").collect())
    tot = n.select((100 * (pl.col("peso_g") < pl.col("p10_g")).mean()).alias("completa"),
                   (100 * (pl.col("peso_g") < pl.col("p10_mais3")).mean()).alias("mais3")).collect()
    print("\n=== A5: p10 observado a termo × Pedreira (NV únicos 37–42, 2012–2024, coorte_fixa_37, peso válido, sexo conhecido) ===")
    print(p10.to_pandas().to_string(index=False))
    print(pig.to_pandas().to_string(index=False))
    print(f"total % PIG Pedreira: semana completa {tot.item(0, 0):.2f} | +3 dias interpolado {tot.item(0, 1):.2f}")


if __name__ == "__main__":
    a2()
    a3()
    a5()
