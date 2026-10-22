"""98b — Pendência B19: códigos de residência (CODMUNRES) que parecem válidos (não terminam em 0000) mas não
estão na lista do IBGE (Censo 2022, 5.570 municípios + municípios instalados depois de 2010).

Varre o Brasil inteiro (SINASC, SIM-DO e SIM-DOFET, 2011–2024), lendo só a coluna CODMUNRES. Grava
logs/codigos_residencia_fora_ibge.csv com sistema, código, UF (2 primeiros dígitos), nº de registros (contagem
< 10 = "<10") e anos em que aparece. Diz se algum desses códigos poderia pertencer a um dos 277 municípios das
concentrações (mesmo prefixo de 5 dígitos que um deles); nesse caso, PARA, porque registros estariam sendo
perdidos sem aviso.

Uso (de 00_scripts/):
    uv run 98b_codigos_residencia.py
"""
from __future__ import annotations

import config as C  # antes do polars (R8)
import utils as U

import pandas as pd
import polars as pl

PASTA = {"SINASC": C.SINASC, "SIM-DO": C.SIM, "SIM-DOFET": C.SIM / "_dofet"}


def mascara(n: int) -> str:
    return "<10" if 0 < n < 10 else str(n)


def main():
    log = U.get_logger("98b_codigos_residencia")
    ibge = set(pd.read_csv(C.RM / "populacao_censo2022.csv", dtype=str)["CD_MUN6"])
    novos = set(pd.read_csv(C.RM / "municipios_novos_origem.csv", dtype=str)["CD_MUN"].str[:6])
    validos = ibge | novos
    conc = set(pd.read_csv(C.RM / "concentracoes_urbanas_municipios.csv", dtype=str)["CD_MUN6"])
    log.info("Lista do IBGE: %d códigos (Censo 2022) + %d novos = %d", len(ibge), len(novos - ibge), len(validos))
    linhas, totais = [], {}
    for sist, pasta in PASTA.items():
        for ano in C.ANOS:
            arqs = [p for p in sorted((pasta / "parquet" / f"ano={ano}").glob("uf=*.parquet")) if not p.name.startswith("._")]
            cod = pl.concat([pl.scan_parquet(p).select(pl.col("CODMUNRES").cast(pl.Utf8).str.strip_chars().str.slice(0, 6))
                             for p in arqs]).group_by("CODMUNRES").len().collect()
            tot = int(cod["len"].sum())
            fora = cod.filter(pl.col("CODMUNRES").is_not_null() & ~pl.col("CODMUNRES").str.ends_with("0000")
                              & ~pl.col("CODMUNRES").is_in(list(validos)))
            totais[(sist, ano)] = (tot, int(fora["len"].sum()), len(fora))
            for c, n in fora.iter_rows():
                linhas.append({"sistema": sist, "ano": ano, "codigo": c, "n": n})
    det = pd.DataFrame(linhas, columns=["sistema", "ano", "codigo", "n"])
    if len(det):
        res = det.groupby(["sistema", "codigo"]).agg(n=("n", "sum"), anos=("ano", lambda a: ",".join(map(str, sorted(set(a)))))).reset_index()
        res["uf"] = res["codigo"].str[:2]
        res["mesmo_prefixo_de_municipio_das_concentracoes"] = res["codigo"].str[:5].isin({c[:5] for c in conc})
        res["n"] = res["n"].map(mascara)
    else:
        res = pd.DataFrame(columns=["sistema", "codigo", "n", "anos", "uf", "mesmo_prefixo_de_municipio_das_concentracoes"])
    res.to_csv(C.LOGS / "codigos_residencia_fora_ibge.csv", index=False)
    U.registrar_proveniencia([C.LOGS / "codigos_residencia_fora_ibge.csv"],
                             ["integridade:SINASC", "integridade:SIM-DO", "integridade:SIM-DOFET",
                              "04_regioes_metropolitanas/populacao_censo2022.csv", "04_regioes_metropolitanas/municipios_novos_origem.csv",
                              "04_regioes_metropolitanas/concentracoes_urbanas_municipios.csv", *U.codigo(__file__)], __file__)
    for sist in PASTA:
        t = sum(v[0] for k, v in totais.items() if k[0] == sist)
        f = sum(v[1] for k, v in totais.items() if k[0] == sist)
        log.info("%s 2011–2024: %d registros; com código válido fora da lista do IBGE: %s (%.4f%%) em %d códigos distintos",
                 sist, t, mascara(f), 100 * f / t if t else 0, det.loc[det["sistema"] == sist, "codigo"].nunique())
    suspeitos = res[res["mesmo_prefixo_de_municipio_das_concentracoes"] == True]  # noqa: E712
    if len(suspeitos):
        log.error("códigos fora da lista com o prefixo de um dos 277 municípios: %s", suspeitos["codigo"].tolist())
        raise SystemExit(1)
    log.info("Nenhum código fora da lista tem o prefixo de 5 dígitos de um município das concentrações (B19 sem perda)")


if __name__ == "__main__":
    main()
