"""98 — Critério de aceite da fase 1 (README §3), agora reproduzível (auditoria A5, 03/10/2026).

Contagem por UF de RESIDÊNCIA (2 primeiros dígitos do CODMUNRES) × ano, nos três sistemas,
contra duas referências:
  - CliMaterna (base antiga do grupo, na Forja): SINASC 2011–2024; SIM-DO e SIM-DOFET 2011–2022;
  - TabNet/DATASUS: SIM-DO e SIM-DOFET 2022–2024, óbitos por residência × UF, guardados em
    logs/referencia_tabnet_sim_2022_2024.json. Consulta feita à mão no formulário web em
    2026-10-02 17:23 BRT ("Mortalidade - Brasil",
    http://tabnet.datasus.gov.br/cgi/tabcgi.exe?sim/cnv/obt10uf.def, arquivos obtuf22–24.dbf;
    "Óbitos fetais - Brasil", http://tabnet.datasus.gov.br/cgi/tabcgi.exe?sim/cnv/fet10uf.def,
    fetuf22–24.dbf;
    Linha = Unidade da Federação; Incremento = Óbitos p/ Residênc; o TabNet informava "Dados
    finais disponíveis até 2024 - data de extração 02/12/2025"). Não é refeita aqui.
Também: % de município de residência inválido (vazio, fora de 6 dígitos ou UF+0000) por UF ×
ano, e a UF do arquivo (_UF) contra a UF do CODMUNRES (SINASC e SIM-DO; o DOFET é nacional).
A sigla de cada código de UF vem da malha oficial do IBGE (05_shapefiles/municipios_2024.gpkg).

Lê microdado, só as colunas CODMUNRES e _UF, e grava SÓ agregados UF × ano. Contagem < 10
aparece como "<10"; a diferença e a % de inválido também são mascaradas quando permitiriam
recuperar uma contagem < 10 (auditoria C2). Sai com código 1 se alguma diferença for diferente
de zero OU se faltar alguma referência esperada (COBERTURA; auditoria C1).

Uso (depois do 05 e dos downloads):
    uv run 98_aceite_fase1.py
Saída:
    logs/aceite_fase1_uf_ano.csv, logs/98_aceite_fase1_*.log
"""
from __future__ import annotations

import json
import sys

import config as C  # antes do polars: o spill em disco fica em config.TMP (auditoria R8)
import utils as U

import pandas as pd
import polars as pl

PASTA = {"SINASC": C.SINASC, "SIM-DO": C.SIM, "SIM-DOFET": C.SIM / "_dofet"}
CLIMATERNA = {
    "SINASC": lambda a: C.CLIMATERNA_RAW / "SINASC" / f"sinasc_{a}.parquet",
    "SIM-DO": lambda a: C.CLIMATERNA_RAW / "DATASUS" / f"sim_{a}.parquet",
    "SIM-DOFET": lambda a: C.CLIMATERNA_RAW / "DATASUS" / "sim_dofet" / f"dofet_raw_{a}.parquet",
}
TABNET = C.LOGS / "referencia_tabnet_sim_2022_2024.json"
# cobertura esperada (sistema, referência) -> anos; falta de referência é erro (auditoria C1)
COBERTURA = {("SINASC", "CliMaterna"): range(2011, 2025), ("SIM-DO", "CliMaterna"): range(2011, 2023),
             ("SIM-DOFET", "CliMaterna"): range(2011, 2023), ("SIM-DO", "TabNet"): range(2022, 2025),
             ("SIM-DOFET", "TabNet"): range(2022, 2025)}
N_UFS = 27
INVALIDO = (pl.col("CODMUNRES").is_null() | ~pl.col("CODMUNRES").str.contains(r"^\d{6}$")
            | pl.col("CODMUNRES").str.ends_with("0000"))


def mascara(n) -> str:
    return "<10" if pd.notna(n) and n < 10 else ("" if pd.isna(n) else str(int(n)))


def sigla_por_codigo() -> dict[str, str]:
    import pyogrio
    m = pyogrio.read_dataframe(C.SHP / "municipios_2024.gpkg", columns=["CD_MUN", "SIGLA_UF"], read_geometry=False)
    par = m.assign(cod=m["CD_MUN"].str[:2])[["cod", "SIGLA_UF"]].drop_duplicates()
    if len(par) != 27 or not par["cod"].is_unique:
        raise SystemExit(f"malha: esperado 27 pares código-UF, achei {len(par)}")
    return dict(zip(par["cod"], par["SIGLA_UF"]))


def contar(arqs, siglas, com_uf: bool) -> pd.DataFrame:
    cols = ["CODMUNRES"] + (["_UF"] if com_uf else [])
    lf = pl.concat([pl.scan_parquet(a).select(cols) for a in arqs], how="vertical")
    lf = lf.with_columns(uf=pl.col("CODMUNRES").str.slice(0, 2).replace_strict(siglas, default="??").fill_null("??"),
                         inv=INVALIDO)
    aggs = [pl.len().alias("n"), pl.col("inv").sum().alias("n_inv")]
    if com_uf:
        aggs.append((pl.col("_UF") != pl.col("uf")).sum().alias("n_uf_difere"))
    return lf.group_by("uf").agg(aggs).collect().to_pandas()


def main():
    log = U.get_logger("98_aceite_fase1")
    siglas = sigla_por_codigo()
    tab = json.loads(TABNET.read_text(encoding="utf-8"))
    linhas, inval, ufdif = [], [], []
    for sist, pasta in PASTA.items():
        for ano in C.ANOS:
            arqs = sorted(p for p in (pasta / "parquet" / f"ano={ano}").glob("uf=*.parquet")
                          if not p.name.startswith("._"))
            if not arqs:
                log.error("%s %d: sem parquet", sist, ano)
                linhas.append({"sistema": sist, "ano": ano, "uf": "??", "referencia": "-", "dif": None})
                continue
            base = contar(arqs, siglas, com_uf=(sist != "SIM-DOFET"))
            for r in base.itertuples():
                inval.append({"sistema": sist, "ano": ano, "uf": r.uf, "pct": 100 * r.n_inv / r.n, "n_inv": r.n_inv})
            if sist != "SIM-DOFET":
                ufdif.append({"sistema": sist, "ano": ano, "n_uf_difere": int(base["n_uf_difere"].sum())})
            refs = {}
            p = CLIMATERNA[sist](ano)
            if p.exists():
                refs["CliMaterna"] = contar([p], siglas, com_uf=False).set_index("uf")["n"]
            chave = f"{sist}_{ano}"
            if chave in tab:
                refs["TabNet"] = pd.Series({siglas[k[:2]]: int(v) for k, v in tab[chave].items()
                                            if k[:2].isdigit() and k[:2] in siglas})
            nb = base.set_index("uf")["n"]
            for ref, nr in refs.items():
                ufs = sorted(set(nb.index) | set(nr.index))
                for uf in ufs:
                    b, r_ = nb.get(uf), nr.get(uf)
                    linhas.append({"sistema": sist, "ano": ano, "uf": uf, "referencia": ref,
                                   "n_base": b, "n_ref": r_,
                                   "dif": (b if pd.notna(b) else 0) - (r_ if pd.notna(r_) else 0)})
            log.info("%s %d: %d UFs na base | referências: %s", sist, ano, (nb.index != "??").sum(),
                     list(refs) or "nenhuma")

    df = pd.DataFrame(linhas)
    inv = pd.DataFrame(inval)
    df = df.merge(inv.rename(columns={"pct": "pct_mun_invalido"}), on=["sistema", "ano", "uf"], how="left")
    pequeno = (df["n_base"] < 10) | (df["n_ref"] < 10)
    saida = df.assign(n_base=df["n_base"].map(mascara), n_ref=df["n_ref"].map(mascara),
                      dif=df["dif"].where(~pequeno).astype("Int64").astype(str).replace("<NA>", "mascarado"),
                      pct_mun_invalido=[("<10 casos" if n < 10 else f"{p:.4f}") if pd.notna(n) else ""
                                        for p, n in zip(df["pct_mun_invalido"], df["n_inv"])]).drop(columns="n_inv")
    saida.to_csv(C.LOGS / "aceite_fase1_uf_ano.csv", index=False)

    erros = 0
    for (sist, ref), d in df[df["referencia"] != "-"].groupby(["sistema", "referencia"]):
        ruins = d[d["dif"] != 0]
        erros += len(ruins)
        log.info("%-9s x %-10s | anos %d–%d | %d células UF x ano | diferença != 0: %d%s", sist, ref,
                 d["ano"].min(), d["ano"].max(), len(d), len(ruins),
                 "" if ruins.empty else " -> " + "; ".join(f"{r.ano} {r.uf} ({r.dif:+.0f})" for r in ruins.itertuples()))
    sem_ref = df[df["referencia"] == "-"]
    erros += len(sem_ref)
    for (sist, ref), anos in COBERTURA.items():
        for ano in anos:
            n = int(((df["sistema"] == sist) & (df["referencia"] == ref) & (df["ano"] == ano) & (df["uf"] != "??")).sum())
            if n != N_UFS:
                erros += 1
                log.error("Cobertura: %s x %s %d com %d UFs comparadas (esperado %d)", sist, ref, ano, n, N_UFS)
    esperado = N_UFS * sum(len(a) for a in COBERTURA.values())
    n_cel = int(((df["referencia"] != "-") & (df["uf"] != "??")).sum())
    if n_cel != esperado:
        erros += 1
        log.error("Células UF x ano comparadas: %d (esperado %d)", n_cel, esperado)
    for d in ufdif:
        if d["n_uf_difere"]:
            erros += 1
            log.error("%s %d: %d registros com _UF diferente da UF do CODMUNRES", d["sistema"], d["ano"], d["n_uf_difere"])
    log.info("_UF = UF do CODMUNRES em 100%% dos registros: %s",
             "sim" if not any(d["n_uf_difere"] for d in ufdif) else "NÃO")
    alto = inv[(inv["pct"] >= 1) & (inv["uf"] != "??")].sort_values(["sistema", "ano", "uf"])
    for sist, d in alto.groupby("sistema"):
        log.info("Município inválido >= 1%% | %s: %d células: %s", sist, len(d),
                 "; ".join(f"{r.ano} {r.uf} " + (f"{r.pct:.2f}%" if r.n_inv >= 10 else "<10 casos")
                           for r in d.itertuples()))  # mesma máscara do CSV (auditoria A1)
    sem_uf = inv[inv["uf"] == "??"]
    if len(sem_uf):
        log.warning("Registros com UF de residência irreconhecível: %s",
                    sem_uf.groupby("sistema").size().to_dict())
    log.info("Gravado %s (%d linhas). %s", (C.LOGS / "aceite_fase1_uf_ano.csv").name, len(saida),
             "ACEITE: OK" if not erros else f"ACEITE: {erros} problema(s)")
    externos = [f"meta:{f(a)}" for s, f in CLIMATERNA.items() for a in C.ANOS if f(a).exists()]   # CliMaterna: tamanho e data
    U.registrar_proveniencia([C.LOGS / "aceite_fase1_uf_ano.csv"],
                             ["integridade:SINASC", "integridade:SIM-DO", "integridade:SIM-DOFET",
                              str(TABNET.relative_to(C.ROOT)), "05_shapefiles/municipios_2024.gpkg", *externos, *U.codigo(__file__)], __file__)
    if erros:
        sys.exit(1)


if __name__ == "__main__":
    main()
