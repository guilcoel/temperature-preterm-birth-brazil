"""Descritivo de qualidade da `ig_dum_sem` (pedido de 08/10/2026, item 6) e comparação com o Q2d de 07/10/2026.
Lê microdado na Forja (nascimentos.parquet e o SINASC bruto, para o motivo do NA e o TPMETESTIM); grava e imprime só
agregados por ano (ou 2012–2024 somados). Não cruza com clima nem com desfecho além da própria IG.

Sigilo: contagem de 1 a 9 sai "<10", com supressão complementar ("supr.") nas identidades
    n = não NA + ausente + não analisável + parto sem data + posterior ao parto + anterior a 50 semanas;
    não NA = 20–45 + fora de 20–45;   20–45 = comparáveis + sem SEMAGESTAC;
    comparáveis = |dif| ≤ 1 + |dif| > 1;   |dif| ≤ 1 = iguais + |dif| = 1
(na tabela 2a: n do código 8 = comparáveis + não comparáveis; comparáveis = iguais + diferentes). As contagens são
tratadas como recuperáveis mesmo quando só o % sai (conservador); a célula complementar é a que deixa o MENOR número
de células suprimidas. Um % cujo denominador está suprimido também sai "supr.". O total 2012–2024 da tabela 2a herda
como "supr." toda célula mascarada em algum ano da mesma população (total = soma dos anos; auditoria, achado 6). As
linhas de populações aninhadas (NV únicos ⊃ coorte; todos os NV ⊃ únicos) não publicam a diferença entre elas, então não
entram nas identidades. Nas tabelas 2b e 3, só %: "<10" = numerador de 1 a 9 (% perto de 0); "compl.<10" =
complemento de 1 a 9 (% perto de 100) (auditoria, achado 8). Na coorte_fixa_22, quando há de 1 a 9 registros fora de
20–45, a supressão mínima esconde o % não NA, que difere do % de 20–45 publicado em menos de 10 registros (achado 7).

Tabela 1 (por ano), nos NV únicos das 26 concentrações (2011–2024) e, à parte, nos NV únicos da coorte_fixa_22
(2012–2024): n; % com ig_dum_sem não NA; % NA por motivo; % com ig_dum_sem de 20 a 45 (sobre n); n comparáveis
(ig_dum_sem 20–45 e SEMAGESTAC válido, ou seja, `ga_sem` 22–44, a IG da base); entre eles, % com
|ga_sem − ig_dum_sem| ≤ 1 e % iguais.
Tabela 2 (Q2d): só registros com TPMETESTIM = 8, lido do bruto: % iguais entre os comparáveis, por ano e em 2012–2024
somados, na população do Q2d (todos os NV dos 277 municípios, 2012–2024) e nos NV únicos. Compatível se a diferença
para o 79,1% do Q2d for ≤ 1 ponto percentual. Cobertura (2b): % com ig_dum_sem não NA × % com código 8, por ano, em
todos os NV (o mesmo denominador do Q2), e % não NA dentro do código 8, fora dele e entre os registros em branco.
Tabela 3 (exploratória, só IG): nos NV únicos comparáveis, a distribuição de SEMAGESTAC − ig_dum_sem (−1, 0, +1,
outro) por resto de (DTNASC − DUM) ÷ 7 e por o intervalo conter ou não um 29/02.
Autoauditoria embutida (divergências, que têm de ser 0): (a) ig_dum_sem do arquivo = recalculada do bruto pelas
funções do 06b; (b) = conta independente em pandas (to_datetime + numpy), sem as funções do 06b; (c) NA no arquivo
⇔ há motivo; (d) TPMETESTIM do bruto = metodo_ig do arquivo; (e) todo NV do arquivo achado no bruto pelo id, e só ele.

Uso (de 00_scripts/):
    ORIGEM=../_tmp/rascunho_06b PYTHONPATH=. uv run python testes/descritivo_ig_dum_sem.py
    PYTHONPATH=. uv run python testes/descritivo_ig_dum_sem.py             # 06_processados/
Grava logs/descritivo_ig_dum_sem_{,q2d_,bissexto_}AAAAMMDD.csv (agregados).
Sai com código 1 se a autoauditoria divergir.
"""
from __future__ import annotations

import datetime as dt
import importlib.util
import os
import sys
from pathlib import Path

import config as C  # antes do polars (R8)
import utils as U

import numpy as np
import pandas as pd
import polars as pl

ALVO = Path(os.environ.get("ALVO_DIR", Path(__file__).resolve().parent.parent))
sp = importlib.util.spec_from_file_location("m06b", ALVO / "06b_desfechos.py")
m = importlib.util.module_from_spec(sp); sp.loader.exec_module(m)
R = Path(os.environ.get("ORIGEM", C.PROC)).resolve()
HOJE = dt.date.today().strftime("%Y%m%d")
Q2D_REF = 79.1                                  # % iguais no código 8, 2012–2024 somados (RESPOSTA_QUESTIONAMENTO_20261007)
Q2_COD8 = {2013: 52.58, 2024: 32.67}            # % de NV com código 8 (idem, Q2)
MOTIVOS = ["ausente", "nao_analisavel", "parto_sem_data", "posterior_ao_parto", "anterior_50_semanas"]
IDENT = [("n", ["nao_na", *MOTIVOS]), ("nao_na", ["ig_20_45", "fora_20_45"]), ("ig_20_45", ["comparaveis", "sem_semagestac"]),
         ("comparaveis", ["concorda_1", "discorda_1"]), ("concorda_1", ["igual", "dif_1"])]
pd.set_option("display.width", 250)
pd.set_option("display.max_columns", 30)
pd.set_option("display.max_rows", 100)


def marcar(c: dict, ident=IDENT, extra=()) -> dict:
    """{célula: "<10" | "supr."} para as que não podem sair: as de 1 a 9 e, em cada identidade com uma só célula
    mascarada, mais uma (a parte ou o total) que impeça a subtração. Entre as candidatas, escolhe a que termina com
    MENOS células mascaradas depois de propagar pelas outras identidades (desempate: a de menor valor). Uma célula
    0 não é candidata, salvo o total, que entra quando as outras partes são todas 0."""
    def propagar(marca: dict) -> dict:
        for tot, partes in ident:
            cel = [tot, *partes]
            if sum(k in marca for k in cel) == 1:
                cands = [k for k in cel if k not in marca and c[k] > 0]
                if not cands:
                    raise ValueError(f"identidade {tot}: célula pequena sem complemento possível")
                return min((propagar({**marca, k: "supr."}) for k in cands),
                           key=lambda m: (len(m), sum(c[k] for k in m if m[k] == "supr.")))
        return marca
    inicio = {k: "<10" for k, v in c.items() if 0 < v < 10}
    inicio.update({k: "supr." for k in extra if k not in inicio})     # vindas de outra linha (total = soma dos anos)
    return propagar(inicio)


def pct(c: dict, marca: dict, num: str, den: str) -> str:
    if num in marca:
        return marca[num]
    if den in marca:
        return "supr."
    return "—" if c[den] == 0 else f"{100 * c[num] / c[den]:.2f}"


def pct_seguro(num: int, den: int, casas: int = 2) -> str:
    """% que não revela contagem de 1 a 9 nem no numerador nem no complemento (como no questionamento de 07/10).
    "<10" = numerador de 1 a 9 (o % é perto de 0); "compl.<10" = complemento de 1 a 9 (o % é perto de 100)."""
    if den == 0:
        return "—"
    if 0 < num < 10:
        return "<10"
    if 0 < den - num < 10:
        return "compl.<10"
    return f"{100 * num / den:.{casas}f}"


def contagens(g: pl.DataFrame) -> dict:
    ig, ga = pl.col("ig_dum_sem"), pl.col("ga_sem")
    comp = ig.is_between(20, 45) & ga.is_not_null()
    r = g.select(
        pl.len().alias("n"), ig.is_not_null().sum().alias("nao_na"),
        *[(pl.col("motivo") == k).sum().alias(k) for k in MOTIVOS],
        ig.is_between(20, 45).sum().alias("ig_20_45"), comp.sum().alias("comparaveis"),
        (comp & ((ga.cast(pl.Int32) - ig.cast(pl.Int32)).abs() <= 1)).sum().alias("concorda_1"),
        (comp & (ga == ig)).sum().alias("igual"),
    ).row(0, named=True)
    r = {k: int(v) for k, v in r.items()}
    r["fora_20_45"] = r["nao_na"] - r["ig_20_45"]
    r["sem_semagestac"] = r["ig_20_45"] - r["comparaveis"]
    r["discorda_1"] = r["comparaveis"] - r["concorda_1"]
    r["dif_1"] = r["concorda_1"] - r["igual"]
    return r


def independente(j: pl.DataFrame) -> int:
    """Divergências entre a ig_dum_sem do arquivo e uma conta em pandas, sem as funções do 06b."""
    p = j.select("DTNASC", "DTULTMENST", pl.col("ig_dum_sem").cast(pl.Float64)).to_pandas()
    s = p["DTULTMENST"].str.strip()
    dum = pd.to_datetime(s.where(s.str.fullmatch(r"\d{8}").fillna(False).astype(bool)), format="%d%m%Y", errors="coerce")
    nas = pd.to_datetime(p["DTNASC"].str.strip().str.zfill(8), format="%d%m%Y", errors="coerce")
    d = (nas - dum).dt.days.to_numpy(dtype=float)
    ind = np.where((d >= 0) & (d <= 350), np.floor(d / 7), np.nan)
    x = p["ig_dum_sem"].to_numpy(dtype=float)
    return int((~((ind == x) | (np.isnan(ind) & np.isnan(x)))).sum())


def main():
    log = U.get_logger("descritivo_ig_dum_sem")
    arq = R / "nascimentos.parquet"
    log.info("nascimentos: %s (md5 %s) | 06b: %s (md5 %s)", arq, U.md5(arq), ALVO / "06b_desfechos.py",
             U.md5(ALVO / "06b_desfechos.py"))
    mun6 = pd.read_csv(C.RM / "concentracoes_urbanas_municipios.csv", dtype=str)["CD_MUN6"].tolist()
    aud = {"a_arquivo_vs_06b_bruto": 0, "b_arquivo_vs_pandas": 0, "c_na_sem_motivo_ou_motivo_sem_na": 0,
           "d_tpmetestim_vs_metodo_ig": 0, "e_nv_sem_par_no_bruto": 0, "e_bruto_sem_par_no_arquivo": 0}
    t1, q2d, cob, b29 = [], [], [], []
    n_ano_absurdo = 0
    for ano in C.ANOS:
        bruto = (m.scan("SINASC", ano, ["CODMUNRES", "DTNASC", "DTULTMENST", "TPMETESTIM"])
                 .filter(pl.col("CODMUNRES").str.slice(0, 6).is_in(mun6))
                 .with_columns(data_b=m.data_dmy("DTNASC"))
                 .with_columns(ig_b=m.ig_pela_dum("data_b", "DTULTMENST"), motivo=m.motivo_na_ig_dum("data_b", "DTULTMENST"),
                               cod=pl.col("TPMETESTIM").str.strip_chars().replace("", None).fill_null("vazio"))
                 .select(pl.col("id").alias("id_nasc"), "DTNASC", "DTULTMENST", "TPMETESTIM", "ig_b", "motivo", "cod", "data_b",
                         m.data_dum("DTULTMENST").alias("dum_b"))
                 .collect())
        nasc = (pl.scan_parquet(arq).filter(pl.col("ano") == ano)
                .select("id_nasc", "unico", "ga_sem", "coorte_fixa_22", "metodo_ig", "ig_dum_sem").collect())
        j = nasc.join(bruto, on="id_nasc", how="left")
        aud["e_nv_sem_par_no_bruto"] += int(j["cod"].null_count())
        aud["e_bruto_sem_par_no_arquivo"] += int(bruto.join(nasc, on="id_nasc", how="anti").height)
        aud["a_arquivo_vs_06b_bruto"] += int(j["ig_dum_sem"].ne_missing(j["ig_b"]).sum())
        aud["b_arquivo_vs_pandas"] += independente(j)
        aud["c_na_sem_motivo_ou_motivo_sem_na"] += int((j["ig_dum_sem"].is_null() != j["motivo"].is_not_null()).sum())
        aud["d_tpmetestim_vs_metodo_ig"] += int(j["metodo_ig"].ne_missing(j["TPMETESTIM"]).sum())
        for pop, filtro in (("nv_unicos", pl.col("unico")), ("nv_unicos_coorte_fixa_22", pl.col("unico") & pl.col("coorte_fixa_22"))):
            c = contagens(j.filter(filtro))
            if c["n"] == 0:
                continue
            mk = marcar(c)
            t1.append({"ano": ano, "populacao": pop, "n": str(mk.get("n", c["n"])),
                       "pct_nao_na": pct(c, mk, "nao_na", "n"), **{f"pct_na_{k}": pct(c, mk, k, "n") for k in MOTIVOS},
                       "pct_20_45": pct(c, mk, "ig_20_45", "n"), "n_comparaveis": str(mk.get("comparaveis", c["comparaveis"])),
                       "pct_concorda_1": pct(c, mk, "concorda_1", "comparaveis"), "pct_igual": pct(c, mk, "igual", "comparaveis"),
                       **{f"_{k}": v for k, v in c.items()}})
        if ano >= 2012:
            for pop, filtro in (("todos_nv_q2d", pl.lit(True)), ("nv_unicos", pl.col("unico"))):
                g = j.filter(filtro & (pl.col("cod") == "8"))
                c = contagens(g)
                q2d.append({"ano": str(ano), "populacao": pop, "_n8": c["n"], "_comp": c["comparaveis"], "_igual": c["igual"]})
        nn, c8 = pl.col("ig_dum_sem").is_not_null(), pl.col("cod") == "8"
        tot = j.select(pl.len().alias("n"), c8.sum().alias("cod8"), nn.sum().alias("nao_na"), (c8 & nn).sum().alias("cod8_nao_na"),
                       (~c8 & nn).sum().alias("fora8_nao_na"), (pl.col("cod") == "vazio").sum().alias("vazio"),
                       ((pl.col("cod") == "vazio") & nn).sum().alias("vazio_nao_na")).row(0, named=True)
        cob.append({"ano": ano, **{k: int(v) for k, v in tot.items()}})
        # exploratório (tabela 3): SEMAGESTAC − ig_dum_sem por resto de dias ÷ 7 e por o intervalo conter um 29/02
        d = (pl.col("data_b") - pl.col("dum_b")).dt.total_days()
        f29 = lambda dt_: pl.date(dt_.dt.year(), 3, 1) - pl.duration(days=1)
        cruza = ((pl.col("data_b").dt.is_leap_year() & (pl.col("dum_b") < f29(pl.col("data_b"))) & (f29(pl.col("data_b")) <= pl.col("data_b")))
                 | (pl.col("dum_b").dt.is_leap_year() & (pl.col("dum_b") < f29(pl.col("dum_b"))) & (f29(pl.col("dum_b")) <= pl.col("data_b"))))
        dif = pl.col("ga_sem").cast(pl.Int32) - pl.col("ig_dum_sem").cast(pl.Int32)
        b29.append(j.filter(pl.col("unico") & pl.col("ig_dum_sem").is_between(20, 45) & pl.col("ga_sem").is_not_null())
                   .group_by(cruza.alias("cruza_29fev"), (d % 7).alias("resto_dias_7"),
                             pl.when(dif.is_between(-1, 1)).then(dif.cast(pl.Utf8)).otherwise(pl.lit("outro")).alias("dif"))
                   .agg(pl.len().alias("n")))
        ano_dum = pl.col("dum_b").dt.year()
        n_ano_absurdo += int(j.select(((ano_dum < 1900) | (ano_dum > 2025)).sum()).item())
        log.info("ano %d lido: %s NV", ano, f"{len(nasc):,}")

    # tabela 1
    t1 = pd.DataFrame(t1)
    pub = t1[[c for c in t1.columns if not c.startswith("_")]]
    pub.to_csv(C.LOGS / f"descritivo_ig_dum_sem_{HOJE}.csv", index=False)
    log.info("\n=== Tabela 1: ig_dum_sem, NV únicos das 26 concentrações (e na coorte_fixa_22) ===\n%s", pub.to_string(index=False))
    # contagens exatas por motivo, 2011–2024 somados, NV únicos (para o "0" dos motivos ser verificável; achado 13)
    u = t1[t1["populacao"] == "nv_unicos"]
    tot_mot = {k: int(u[f"_{k}"].sum()) for k in MOTIVOS}
    log.info("NA por motivo, NV únicos, 2011–2024 somados: %s", {k: ("<10" if 0 < v < 10 else v) for k, v in tot_mot.items()})
    log.info("DUM analisável com ano fora de 1900–2025, todos os NV, 2011–2024 (cai em 'anterior'/'posterior'; o valor é "
             "NA de qualquer forma): %s", "<10" if 0 < n_ano_absurdo < 10 else n_ano_absurdo)

    # tabela 2: Q2d (código 8) e cobertura
    q = pd.DataFrame(q2d)
    soma = q.groupby("populacao", as_index=False)[["_n8", "_comp", "_igual"]].sum().assign(ano="2012-2024")
    q = pd.concat([q, soma], ignore_index=True)
    ident_q = [("n8", ["comp", "nao_comp"]), ("comp", ["igual", "diferente"])]
    linhas_q, mascaras_anos = [], {}
    for r in q.to_dict("records"):                    # os anos vêm antes do total de cada população
        c = {"n8": r["_n8"], "comp": r["_comp"], "nao_comp": r["_n8"] - r["_comp"], "igual": r["_igual"],
             "diferente": r["_comp"] - r["_igual"]}
        # total 2012–2024 = soma dos anos: célula mascarada em algum ano também sai do total (auditoria, achado 6)
        extra = mascaras_anos.get(r["populacao"], set()) if r["ano"] == "2012-2024" else ()
        mk = marcar(c, ident_q, extra)
        if r["ano"] != "2012-2024":
            mascaras_anos.setdefault(r["populacao"], set()).update(mk)
        linhas_q.append({"ano": r["ano"], "populacao": r["populacao"], "n_cod8": str(mk.get("n8", c["n8"])),   # texto: no
                         "n_comparaveis_cod8": str(mk.get("comp", c["comp"])),                             # concat, int viraria float
                         "pct_igual_cod8": pct(c, mk, "igual", "comp")})
    qp = pd.DataFrame(linhas_q)
    cb = pd.DataFrame(cob)
    cb["pct_cod8"] = [pct_seguro(a, b) for a, b in zip(cb["cod8"], cb["n"])]
    cb["pct_ig_dum_sem_nao_na"] = [pct_seguro(a, b) for a, b in zip(cb["nao_na"], cb["n"])]
    cb["cobertura_passa_cod8"] = cb["nao_na"] > cb["cod8"]
    cb["pct_nao_na_entre_cod8"] = [pct_seguro(a, b) for a, b in zip(cb["cod8_nao_na"], cb["cod8"])]
    cb["pct_nao_na_fora_cod8"] = [pct_seguro(a, b) for a, b in zip(cb["fora8_nao_na"], cb["n"] - cb["cod8"])]
    cb["pct_nao_na_entre_vazios"] = [pct_seguro(a, b) for a, b in zip(cb["vazio_nao_na"], cb["vazio"])]
    cp = cb[["ano", "pct_cod8", "pct_ig_dum_sem_nao_na", "cobertura_passa_cod8", "pct_nao_na_entre_cod8",
             "pct_nao_na_fora_cod8", "pct_nao_na_entre_vazios"]]
    pd.concat([qp.assign(tabela="q2d_cod8"), cp.assign(tabela="cobertura_todos_nv", ano=cp["ano"].astype(str))],
              ignore_index=True).to_csv(C.LOGS / f"descritivo_ig_dum_sem_q2d_{HOJE}.csv", index=False)
    log.info("\n=== Tabela 2a: %% iguais (ga_sem = ig_dum_sem) nos comparáveis, só TPMETESTIM = 8 (bruto) ===\n%s",
             qp.to_string(index=False))
    log.info("\n=== Tabela 2b: cobertura em todos os NV dos 277 municípios ===\n%s", cp.to_string(index=False))

    # tabela 3 (exploratória): diferença SEMAGESTAC − ig_dum_sem por resto de dias ÷ 7 e 29/02 no intervalo
    b = pl.concat(b29).group_by("cruza_29fev", "resto_dias_7", "dif").agg(pl.col("n").sum()).to_pandas()
    w = b.pivot_table(index=["cruza_29fev", "resto_dias_7"], columns="dif", values="n", aggfunc="sum", fill_value=0)
    for k in ("-1", "0", "1", "outro"):
        if k not in w.columns:
            w[k] = 0
    w["n"] = w[["-1", "0", "1", "outro"]].sum(axis=1)
    t3 = pd.DataFrame({"n_comparaveis": w["n"].map(lambda v: "<10" if 0 < v < 10 else str(int(v))),
                       **{f"pct_dif_{k}": [pct_seguro(int(a), int(t)) for a, t in zip(w[k], w["n"])] for k in ("-1", "0", "1", "outro")}},
                      index=w.index).reset_index()
    t3.to_csv(C.LOGS / f"descritivo_ig_dum_sem_bissexto_{HOJE}.csv", index=False)
    log.info("\n=== Tabela 3 (exploratória): SEMAGESTAC − ig_dum_sem nos NV únicos comparáveis, 2011–2024, por resto de "
             "(DTNASC − DUM) ÷ 7 e por o intervalo conter um 29/02 ===\n%s", t3.to_string(index=False))
    s = q[(q["ano"] == "2012-2024") & (q["populacao"] == "todos_nv_q2d")].iloc[0]
    v = 100 * s["_igual"] / s["_comp"]
    compat = abs(v - Q2D_REF) <= 1.0
    log.info("Q2d: %.2f%% agora × %.1f%% em 07/10 (diferença %.2f p.p.): %s", v, Q2D_REF, v - Q2D_REF,
             "COMPATÍVEL (≤ 1 p.p.)" if compat else "INCOMPATÍVEL")
    for a, ref in Q2_COD8.items():
        r = cb[cb["ano"] == a].iloc[0]
        log.info("Q2: código 8 em %d = %.2f%% agora × %.2f%% em 07/10", a, 100 * r["cod8"] / r["n"], ref)
    log.info("cobertura da ig_dum_sem > fração do código 8 em todos os anos: %s", bool(cb["cobertura_passa_cod8"].all()))

    # autoauditoria: partição e divergências
    part = all(r["_n"] == r["_nao_na"] + sum(r[f"_{k}"] for k in MOTIVOS) for r in t1.to_dict("records"))
    log.info("autoauditoria: partição de n fecha em todas as linhas: %s | divergências: %s", part, aud)
    ok = part and not any(aud.values())
    log.info("FIM descritivo (%s)", "autoauditoria OK" if ok else "AUTOAUDITORIA DIVERGIU")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
