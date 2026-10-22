"""Questionamento da coordenação (chat de métodos), 07/10/2026: números das perguntas Q1e, Q2–Q6 e Q8–Q11.

Imprime SÓ agregados: o conjunto das 26 concentrações × ano, concentração × período, ou semana gestacional
somada.

**Máscara:** contagem de 1 a 9 = "<10", sem o %. Com **supressão complementar**, como no `suprimir` do 06b: quando
uma identidade (total = soma das partes) tem uma só célula mascarada, a menor outra parte não nula sai como
"supr.".

**Linha vermelha:** nada cruza desfecho com clima ou PM2.5, nenhum desfecho é descrito por estação, mês ou
característica climática, e nenhuma data de evento individual é impressa. O Q10 usa só a exposição.

**Versão:** confere a `versao()` e o md5 dos arquivos lidos pela interface `09_acesso/acesso.py`, no começo e no fim.
O Q2d lê o SINASC bruto (`01_sinasc/parquet/`), fora da interface.

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/questionamento_20261007.py            # todas
    PYTHONPATH=. uv run python testes/questionamento_20261007.py q3 q8     # só algumas
"""
import datetime as dt
import sys

import config as C  # antes do polars (R8)

sys.path.insert(0, str(C.ROOT / "09_acesso"))
import acesso as A  # noqa: E402  (antes do polars, como pede o LEIAME da interface)

import pandas as pd  # noqa: E402
import polars as pl  # noqa: E402

pd.set_option("display.width", 250)
pd.set_option("display.max_columns", 40)
pd.set_option("display.max_rows", 200)
INI, FIM = dt.date(2012, 1, 1), dt.date(2024, 12, 31)
N_DIAS = (FIM - INI).days + 1          # 4.749
CENSURA = dt.date(2024, 12, 25)
P = C.PROC
LIDOS = ["06_processados/nascimentos.parquet", "06_processados/obitos_perinatais.parquet",
         "06_processados/pig_classificacao.parquet", "06_processados/gestacoes_em_risco_recorte.parquet",
         "06_processados/serie_diaria_recorte.parquet", "06_processados/serie_diaria_recorte_sem_coorte_fixa.parquet",
         "06_processados/serie_diaria_municipio.parquet", "06_processados/serie_diaria_municipio_sem_coorte_fixa.parquet",
         "06_processados/serie_diaria_municipio_clima.parquet",
         "06_processados/serie_diaria_municipio_clima_sem_coorte_fixa.parquet",
         "06_processados/pm25_municipio_diario_2010_2025.parquet", "06_processados/calendario_2010_2025.parquet"]


def mascara(n) -> str:
    n = int(n)
    return "<10" if 0 < n < 10 else f"{n:,}".replace(",", ".")


def suprimidas(cont: dict) -> dict:
    """Células de uma identidade (dict código → contagem): {código: "<10" | "supr."} para as que não podem sair."""
    pequenas = {k for k, n in cont.items() if 0 < n < 10}
    out = {k: "<10" for k in pequenas}
    if len(pequenas) == 1:
        livres = [(n, k) for k, n in cont.items() if n > 0 and k not in pequenas]
        if livres:
            out[min(livres)[1]] = "supr."
    return out


def pct_seguro(num: int, den: int, casas: int = 1) -> str:
    """% que não revela contagem de 1 a 9 nem no numerador nem no complemento."""
    if den == 0:
        return "—"
    if 0 < num < 10 or 0 < den - num < 10:
        return "<10 reg."
    return f"{100 * num / den:.{casas}f}"


def recortes() -> pl.DataFrame:
    return pl.read_csv(C.RM / "concentracoes_urbanas_municipios.csv", schema_overrides={c: pl.Utf8 for c in
                       ("CD_RECORTE", "CD_MUN", "CD_MUN6")}).select("CD_MUN6", "CD_RECORTE", "NM_RECORTE")


def nomes() -> dict:
    n = pl.read_csv(C.RM / "cidade_nucleo.csv", infer_schema=False)
    return dict(zip(n["CD_RECORTE"], n["NM_RECORTE"]))


def totais_serie() -> dict:
    """Totais 2012–2024 da série principal (coorte fixa), lidos do log do 06b, para conferência."""
    t = pd.read_csv(C.LOGS / "totais_anuais.csv", dtype=str)
    t = t[(t.versao == "principal") & t.ano.astype(int).between(2012, 2024)]
    return {c: int(t[c].astype(int).sum()) for c in ("nv_unicos", "obito_fetal_principal", "obito_neonatal_precoce")}


def versao(momento: str):
    ok = A.verificar(LIDOS, parar=True)
    print(f"\n=== versão ({momento}): versao() = {A.versao()} | manifesto {A.manifesto()['data_manifesto']} | "
          f"md5 conferido em {sum(ok.values())} de {len(ok)} arquivos lidos ===")


def q1e():
    print("\n=== Q1e: calendário (público), 2012–2024 ===")
    c = pl.read_parquet(P / "calendario_2010_2025.parquet").filter(pl.col("ano").is_between(2012, 2024))
    cols = ["feriado_nacional", "carnaval", "quarta_cinzas", "sexta_paixao", "corpus_christi"]
    print(c.group_by("ano").agg(*[pl.col(k).sum() for k in cols]).sort("ano").to_pandas().to_string(index=False))
    print("dia da semana com carnaval = 1 (1 = segunda):", c.filter(pl.col("carnaval") == 1).group_by("dia_semana").len().sort("dia_semana").rows())
    print("dias que também são feriado_nacional:", {k: c.filter((pl.col(k) == 1) & (pl.col("feriado_nacional") == 1)).height for k in cols[1:]})


def freq(lf: pl.LazyFrame, col: str, ano: str, titulo: str):
    """% por código e ano, com máscara e supressão complementar dentro de cada ano (total = soma dos códigos)."""
    d = (lf.with_columns(pl.col(col).cast(pl.Utf8).str.strip_chars().replace("", None).fill_null("vazio").alias("cod"))
         .group_by(ano, "cod").len().collect().to_pandas())
    linhas = {}
    for a, g in d.groupby(ano):
        cont = dict(zip(g["cod"], g["len"]))
        tot, sup = sum(cont.values()), suprimidas(cont)
        linhas[a] = {"n": mascara(tot), **{k: sup.get(k, f"{100 * n / tot:.2f}") for k, n in cont.items()}}
    w = pd.DataFrame.from_dict(linhas, orient="index").sort_index().fillna("0")
    print(f"\n--- {titulo}: % por código ---")
    print(w.to_string())


def q2():
    print("\n=== Q2: códigos, % por ano (NV residentes nos 277 municípios; óbitos fetais residentes) ===")
    n = pl.scan_parquet(P / "nascimentos.parquet")
    for col, tit in (("sttrabpart", "STTRABPART"), ("stcesparto", "STCESPARTO (bruto)"),
                     ("stcesparto_aj", "stcesparto_aj"), ("parto", "PARTO"), ("metodo_ig", "TPMETESTIM"),
                     ("gestacao_cat", "GESTACAO")):
        freq(n, col, "ano", tit)
    bruto = pl.col("stcesparto").str.strip_chars().replace("", None)
    dif = (n.group_by("ano").agg((bruto.fill_null("vazio") != pl.col("stcesparto_aj").fill_null("vazio")).sum().alias("d"))
           .sort("ano").collect())
    print("\nregistros com stcesparto_aj diferente do bruto, por ano:", [(a, mascara(x) if x else "0") for a, x in dif.rows()])
    o = pl.scan_parquet(P / "obitos_perinatais.parquet").filter(pl.col("tipo") == "fetal")
    freq(o, "obitoparto", "ano_obito", "OBITOPARTO (DOFET, todos os óbitos fetais residentes)")
    freq(o.filter(pl.col("principal")), "obitoparto", "ano_obito", "OBITOPARTO (DOFET, só óbito fetal principal)")


def q2d():
    """TPMETESTIM × DUM no SINASC bruto (277 municípios): o que cada código marca, pelo dado."""
    print("\n=== Q2d: TPMETESTIM × DUM (DTULTMENST), SINASC bruto, NV residentes nos 277 municípios, 2012–2024 ===")
    mun6 = recortes()["CD_MUN6"].to_list()
    data = lambda c: pl.col(c).str.strip_chars().str.zfill(8).str.strptime(pl.Date, "%d%m%Y", strict=False)  # como no 06b
    sg = pl.col("SEMAGESTAC").str.strip_chars().cast(pl.Int32, strict=False)
    partes = []
    for ano in range(2012, 2025):
        arqs = [p for p in sorted((C.SINASC / "parquet" / f"ano={ano}").glob("uf=*.parquet")) if not p.name.startswith("._")]
        partes.append(
            pl.concat([pl.scan_parquet(p).select("CODMUNRES", "DTNASC", "DTULTMENST", "SEMAGESTAC", "TPMETESTIM") for p in arqs])
            .filter(pl.col("CODMUNRES").str.slice(0, 6).is_in(mun6))
            .with_columns(ig_dum=((data("DTNASC") - data("DTULTMENST")).dt.total_days() // 7),
                          sg=pl.when(sg.is_between(22, 44)).then(sg),                  # IG válida do SINASC na base
                          dum_pre=pl.col("DTULTMENST").str.strip_chars().replace("", None).is_not_null(),
                          cod=pl.col("TPMETESTIM").str.strip_chars().replace("", None).fill_null("vazio"),
                          ano=pl.lit(ano))
            .with_columns(dum_ok=pl.col("ig_dum").is_between(20, 45).fill_null(False))
            .group_by("ano", "cod").agg(pl.len().alias("n"), pl.col("dum_pre").sum().alias("dum_pre"),
                                        pl.col("dum_ok").sum().alias("dum_ok"), pl.col("sg").is_not_null().sum().alias("sg"),
                                        (pl.col("dum_ok") & pl.col("sg").is_not_null()).sum().alias("ambos"),
                                        (pl.col("dum_ok") & (pl.col("sg") == pl.col("ig_dum"))).sum().alias("iguais"))
            .collect())
    d = pl.concat(partes).to_pandas()
    for rotulo, x in (("2012–2024 somados", d.groupby("cod")[["n", "dum_pre", "dum_ok", "sg", "ambos", "iguais"]].sum()),
                      ("2022", d[d.ano == 2022].set_index("cod")[["n", "dum_pre", "dum_ok", "sg", "ambos", "iguais"]])):
        t = pd.DataFrame({
            "n": x["n"].map(mascara),
            "% com DTULTMENST preenchida": [pct_seguro(a, b, 2) for a, b in zip(x["dum_pre"], x["n"])],
            "% com DUM plausível (IG pela DUM 20–45)": [pct_seguro(a, b, 2) for a, b in zip(x["dum_ok"], x["n"])],
            "% com SEMAGESTAC 22–44": [pct_seguro(a, b, 1) for a, b in zip(x["sg"], x["n"])],
            "n com DUM plausível e SEMAGESTAC": x["ambos"].map(lambda v: mascara(v) if v else "0"),
            "% SEMAGESTAC = IG pela DUM (entre esses)": [pct_seguro(a, b, 1) for a, b in zip(x["iguais"], x["ambos"])]},
            index=x.index)
        print(f"\n--- {rotulo} ---")
        print(t.to_string())


def q3():
    print("\n=== Q3: PIG por Pedreira na população principal (2012–2024) ===")
    g = pl.scan_parquet(P / "pig_classificacao.parquet").filter(pl.col("pop_pig_principal"))
    r = g.select(pl.len().alias("n"), *[pl.col(c).sum().alias(f"{c}_sim") for c in ("pig_ig21", "pig_pedreira", "pig_oms")],
                 *[pl.col(c).is_null().sum().alias(f"{c}_na") for c in ("pig_ig21", "pig_pedreira", "pig_oms")]).collect().row(0, named=True)
    for c in ("pig_ig21", "pig_pedreira", "pig_oms"):
        den = r["n"] - r[f"{c}_na"]
        print(f"{c}: numerador {r[f'{c}_sim']:,} | denominador {den:,} (NA {r[f'{c}_na']:,}) | {100 * r[f'{c}_sim'] / den:.4f}%")
    a = pd.read_csv(C.LOGS / "pig_resumo_ano.csv", dtype=str)
    a = a[a.populacao == "pop_pig_principal"]
    w = (a.pig_pedreira_pct.astype(float) * a.pig_pedreira_n_classificados.astype(int)).sum() / a.pig_pedreira_n_classificados.astype(int).sum()
    print(f"média anual ponderada dos % arredondados do pig_resumo_ano.csv: {w:.4f}% | n do log: {a.n.astype(int).sum():,}")


def q4():
    print("\n=== Q4: casos de PIG por concentração e curva, população principal, soma 2012–2024 ===")
    nasc = pl.scan_parquet(P / "nascimentos.parquet").select("id_nasc", "CD_MUN6")
    g = (pl.scan_parquet(P / "pig_classificacao.parquet").filter(pl.col("pop_pig_principal"))
         .join(nasc, on="id_nasc").join(recortes().lazy(), on="CD_MUN6")
         .group_by("CD_RECORTE", "NM_RECORTE").agg(pl.len().alias("pop"),
                                                    pl.col("pig_ig21").sum().alias("INTERGROWTH"),
                                                    pl.col("pig_pedreira").sum().alias("Pedreira"),
                                                    pl.col("pig_oms").is_not_null().sum().alias("pop_OMS_37_40"),
                                                    pl.col("pig_oms").sum().alias("OMS_37_40"))
         .sort("pop", descending=True).collect().to_pandas())
    print(g.assign(**{c: g[c].map(mascara) for c in ("pop", "INTERGROWTH", "Pedreira", "pop_OMS_37_40", "OMS_37_40")}).to_string(index=False))
    print(f"total: pop {g['pop'].sum():,}; INTERGROWTH {g.INTERGROWTH.sum():,}; Pedreira {g.Pedreira.sum():,}; OMS {g.OMS_37_40.sum():,}")
    for c in ("INTERGROWTH", "Pedreira", "OMS_37_40"):
        for corte in (1000, 2000):
            abaixo = g.loc[g[c] < corte, "NM_RECORTE"].tolist()
            print(f"{c} < {corte}: {len(abaixo)} — {', '.join(abaixo) if abaixo else 'nenhuma'}")


def q5():
    """Bordas do Z_t. Por concentração só sai o que é estrutural (igual nas 26); o último dia das semanas 22–42 é o
    último término da coorte em cada concentração, uma data de evento individual: sai só a faixa entre as 26."""
    print("\n=== Q5: gestações em risco nas bordas (Z_t por concentração, série principal 2012-01-01 a 2024-12-31) ===")
    z = pl.scan_parquet(P / "gestacoes_em_risco_recorte.parquet")
    for rotulo, semanas, expr in (("22–36, z_nv", (22, 36), pl.col("z_nv")),
                                  ("22–36, z_nv + z_fetal", (22, 36), pl.col("z_nv") + pl.col("z_fetal")),
                                  ("22–42, z_nv", (22, 42), pl.col("z_nv")),
                                  ("22–42, z_nv + z_fetal", (22, 42), pl.col("z_nv") + pl.col("z_fetal"))):
        d = (z.filter(pl.col("semana").is_between(*semanas) & pl.col("data").is_between(INI, FIM))
             .group_by("recorte_principal", "data").agg(expr.sum().alias("Z")).filter(pl.col("Z") > 0)
             .group_by("recorte_principal").agg(pl.col("data").min().alias("primeiro"), pl.col("data").max().alias("ultimo"),
                                                pl.len().alias("dias_Z_pos"))
             .with_columns((N_DIAS - pl.col("dias_Z_pos")).alias("dias_Z_zero"),
                           ((pl.col("ultimo") - pl.col("primeiro")).dt.total_days() + 1 - pl.col("dias_Z_pos")).alias("buracos"))
             .collect())
        print(f"{rotulo}: {d.height} concentrações | primeiro dia {d['primeiro'].min()} a {d['primeiro'].max()} | "
              f"último dia {d['ultimo'].min()} a {d['ultimo'].max()} | dias com Z = 0: {d['dias_Z_zero'].min()} a "
              f"{d['dias_Z_zero'].max()} | dias com Z = 0 entre o primeiro e o último: {d['buracos'].sum()}")
    # bordas do calendário da coordenação, como limites (contagens fora deles; nenhuma data de evento)
    s = pl.scan_parquet(P / "serie_diaria_recorte.parquet").filter(pl.col("data").is_between(INI, FIM))
    lim = s.select(
        pl.col("ptb").filter(pl.col("data") < dt.date(2012, 1, 4)).sum().alias("ptb_antes_2012_01_04"),
        pl.col("ptb").filter(pl.col("data") > dt.date(2024, 11, 15)).sum().alias("ptb_depois_2024_11_15"),
        pl.col("nv_unicos").filter(pl.col("data") < dt.date(2012, 1, 4)).sum().alias("nv_antes_2012_01_04"),
        pl.col("nv_unicos").filter(pl.col("data") > dt.date(2024, 12, 27)).sum().alias("nv_depois_2024_12_27"),
        pl.col("obito_fetal_principal").filter(pl.col("data") > dt.date(2024, 12, 27)).sum().alias("fetal_depois_2024_12_27"),
        pl.col("ptb").filter(pl.col("data").is_between(dt.date(2012, 1, 4), dt.date(2024, 11, 15))).sum().alias("ptb_dentro")).collect()
    print("eventos fora das datas da coordenação (série principal, soma das 26):", lim.rows(named=True)[0])


def q6():
    print("\n=== Q6: censura neonatal de dez/2024 ===")
    cens = ["obito_neonatal_precoce", "obito_neonatal_precoce_sem_ig", "obito_perinatal", "obito_ate24h",
            "obito_perinatal_24h", "obito_perinatal_sem_anomalia"]
    outras = ["obito_fetal_principal", "obito_fetal_sem_ig", "obito_neonatal_precoce_idx_obito", "obito_perinatal_idx_obito",
              "nv_unicos", "ptb"]
    antes = (dt.date(2012, 1, 1), dt.date(2024, 12, 24))
    for arq in ("serie_diaria_recorte", "serie_diaria_recorte_sem_coorte_fixa", "serie_diaria_municipio",
                "serie_diaria_municipio_sem_coorte_fixa", "serie_diaria_municipio_clima",
                "serie_diaria_municipio_clima_sem_coorte_fixa"):
        s = pl.read_parquet(P / f"{arq}.parquet", columns=["data", "censura_neonatal_dez2024", *cens, *outras])
        dias_todo_na = lambda a, b: s.filter(pl.col("data").is_between(a, b)).group_by("data").agg(
            *[pl.col(c).is_null().all().alias(c) for c in cens + outras]).select(*[pl.col(c).sum() for c in cens + outras]).row(0, named=True)
        a, c_ = dias_todo_na(*antes), dias_todo_na(CENSURA, FIM)
        f = s.filter(pl.col("censura_neonatal_dez2024")).select(pl.col("data").min().alias("de"), pl.col("data").max().alias("ate")).row(0)
        print(f"\n--- {arq}: flag TRUE de {f[0]} a {f[1]} ---")
        print(pd.DataFrame({"dias toda NA, 2012-01-01 a 2024-12-24 (de 4.742)": a, "dias toda NA, 2024-12-25 a 31 (de 7)": c_}).to_string())


def q8():
    print("\n=== Q8: IG dos NV únicos da coorte fixa (coorte_fixa_22), 26 concentrações, 2012–2024 ===")
    d = (pl.scan_parquet(P / "nascimentos.parquet")
         .filter(pl.col("pop_ptb") & pl.col("coorte_fixa_22") & pl.col("data").is_between(INI, FIM))
         .group_by("ga_sem").len().sort("ga_sem").collect().to_pandas())
    d["pct"] = (100 * d["len"] / d["len"].sum()).round(3)
    d["n"] = d["len"].map(mascara)
    print(d[["ga_sem", "n", "pct"]].to_string(index=False))
    print(f"total {d['len'].sum():,} | soma de nv_unicos 2012–2024 no logs/totais_anuais.csv: {totais_serie()['nv_unicos']:,}")


def q9():
    print("\n=== Q9b: GESTACAO × SEMAGESTAC, NV únicos, 26 concentrações, 2012 e 2013 ===")
    sg = pl.col("semagestac_bruto").str.strip_chars().cast(pl.Int32, strict=False)
    faixa = (pl.when(sg.is_null() | sg.is_in([9, 99])).then(pl.lit("ausente"))
             .when(sg < 22).then(pl.lit("<22")).when(sg <= 27).then(pl.lit("22-27")).when(sg <= 31).then(pl.lit("28-31"))
             .when(sg <= 36).then(pl.lit("32-36")).when(sg <= 41).then(pl.lit("37-41")).when(sg <= 44).then(pl.lit("42-44"))
             .otherwise(pl.lit(">=45")))
    gc = pl.col("gestacao_cat").str.strip_chars().replace("", None).fill_null("vazio")
    base = pl.scan_parquet(P / "nascimentos.parquet").filter(pl.col("unico") & pl.col("ano").is_in([2012, 2013]))
    cols = ["<22", "22-27", "28-31", "32-36", "37-41", "42-44", ">=45", "ausente"]
    for ano in (2012, 2013):
        b = base.filter(pl.col("ano") == ano).with_columns(faixa.alias("SEMAGESTAC"), gc.alias("GESTACAO"))
        t = (b.group_by("GESTACAO", "SEMAGESTAC").len().collect().to_pandas()
             .pivot(index="GESTACAO", columns="SEMAGESTAC", values="len").reindex(columns=cols).fillna(0).astype(int))
        out = t.map(mascara).astype(object)
        for i in t.index:                                    # linhas e colunas como identidades
            for k, v in suprimidas(t.loc[i].to_dict()).items():
                out.at[i, k] = v
        for c in t.columns:
            for k, v in suprimidas(t[c].to_dict()).items():
                if out.at[k, c] != "<10":
                    out.at[k, c] = v
        print(f"\n--- {ano}: linhas = GESTACAO, colunas = faixa do SEMAGESTAC ---")
        print(out.to_string())
        k = (b.filter(pl.col("GESTACAO").is_in(["2", "3", "4", "5", "6"]) & sg.is_between(22, 44))
             .select(pl.col("GESTACAO").is_in(["2", "3", "4"]).alias("g"), (sg <= 36).alias("s"))
             .group_by("g", "s").len().collect())
        c = {(r["g"], r["s"]): r["len"] for r in k.iter_rows(named=True)}
        a_, b_, c_, d_ = c.get((True, True), 0), c.get((True, False), 0), c.get((False, True), 0), c.get((False, False), 0)
        n = a_ + b_ + c_ + d_
        po = (a_ + d_) / n
        pe = ((a_ + b_) * (a_ + c_) + (c_ + d_) * (b_ + d_)) / n ** 2
        print(f"2×2 (GESTACAO 2–6 e SEMAGESTAC 22–44): <37 nos dois {mascara(a_)} | só GESTACAO {mascara(b_) if b_ else 0} | "
              f"só SEMAGESTAC {mascara(c_) if c_ else 0} | ≥37 nos dois {mascara(d_)} | n {n:,}")
        print(f"concordância {100 * po:.3f}% | kappa {(po - pe) / (1 - pe):.4f}")


def q10():
    print("\n=== Q10: lacunas do PM2.5 por cidade-núcleo, 2012–2024 (4.749 dias) ===")
    nuc = pl.read_csv(C.RM / "cidade_nucleo.csv", infer_schema=False).select(
        "NM_RECORTE", pl.col("CD_MUN_NUCLEO").str.slice(0, 6).alias("CD_MUN6"))
    pm = (pl.scan_parquet(P / "pm25_municipio_diario_2010_2025.parquet").filter(pl.col("data").is_between(INI, FIM))
          .join(nuc.lazy(), on="CD_MUN6")
          .group_by("NM_RECORTE").agg(pl.len().alias("dias"),
                                      *[pl.col(v).is_null().sum().alias(v) for v in ("pm25_local_zero_na", "pm25_zero_na",
                                                                                     "pm25", "pm25_local")])
          .sort("pm25_local_zero_na", descending=True).collect().to_pandas())
    log = pd.read_csv(C.LOGS / "dias_faltantes_pm25.csv", dtype=str)
    log = log[(log.variante == "pm25_local_zero_na") & (log.versao == "nucleo")].set_index("NM_RECORTE")["n_faltantes_2012_2024"]
    pm["pct_local_zero_na"] = (100 * pm.pm25_local_zero_na / N_DIAS).round(2)
    pm["log_06c"] = pm.NM_RECORTE.map(log).astype(float).astype(int)
    pm["bate_log"] = pm.pm25_local_zero_na == pm.log_06c
    print(pm.to_string(index=False))
    # o NA do dia local e o do dia UTC coincidem; os valores não: conferência dia a dia nos 277 municípios
    x = pl.scan_parquet(P / "pm25_municipio_diario_2010_2025.parquet").filter(pl.col("data").is_between(INI, FIM)).select(
        (pl.col("pm25_zero_na").is_null() != pl.col("pm25_local_zero_na").is_null()).sum().alias("NA_so_numa"),
        (pl.col("pm25_zero_na").is_null() & pl.col("pm25_local_zero_na").is_null()).sum().alias("NA_nas_duas"),
        (pl.col("pm25_zero_na").is_not_null() & pl.col("pm25_local_zero_na").is_not_null()).sum().alias("com_valor_nas_duas"),
        ((pl.col("pm25_zero_na") - pl.col("pm25_local_zero_na")).abs() > 1e-9).sum().alias("valores_diferentes"),
        pl.len().alias("municipio_dias")).collect()
    print("pm25_zero_na × pm25_local_zero_na, 277 municípios, 2012–2024:", x.rows(named=True)[0])


def q11():
    print("\n=== Q11: óbitos principais da coorte fixa por semana gestacional, 26 concentrações, 2012–2024 ===")
    o = (pl.scan_parquet(P / "obitos_perinatais.parquet")
         .filter(pl.col("principal") & pl.col("coorte_fixa_22") & pl.col("data_indice").is_between(INI, FIM)))
    cens = o.filter((pl.col("tipo") == "neonatal_precoce") & (pl.col("data_indice") >= CENSURA)).select(pl.len()).collect().item()
    o = o.filter(~((pl.col("tipo") == "neonatal_precoce") & (pl.col("data_indice") >= CENSURA)))
    d = o.group_by("ga_sem", "tipo").len().collect().to_pandas().pivot(index="ga_sem", columns="tipo", values="len").fillna(0).astype(int)
    print(d.map(mascara).to_string())
    ref = totais_serie()
    print(f"total fetal {d['fetal'].sum():,} | neonatal {d['neonatal_precoce'].sum():,} | no logs/totais_anuais.csv: "
          f"fetal {ref['obito_fetal_principal']:,}, neonatal {ref['obito_neonatal_precoce']:,}")
    print(f"neonatais principais da coorte fixa no SIM 2024 com nascimento de 25 a 31/12/2024: {mascara(cens) if cens else 0}")


if __name__ == "__main__":
    escolhidas = sys.argv[1:] or ["q1e", "q2", "q2d", "q3", "q4", "q5", "q6", "q8", "q9", "q10", "q11"]
    versao("antes")
    for q in escolhidas:
        globals()[q]()
    versao("depois")
