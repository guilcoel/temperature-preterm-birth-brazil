"""06d (validação, E7) — confere o gestacoes_em_risco.parquet por força bruta, em código
separado do 06d, em 5 combinações de município e dia.

Independência (auditoria A7): o início da gestação é RECALCULADO aqui a partir da IG bruta
(`semagestac_bruto`) e da data do término, sem usar `dum_est`/`s_ini` nem as flags de coorte do
06b; a coorte fixa também é recalculada (s em [2011-07-31; 2024-03-05]). A população é a do E7:
NV únicos (GRAVIDEZ = 1) com IG 22–42 e óbitos fetais únicos com IG 22–42.

Em cada combinação (m, t) e em CADA semana j (22–42): z_nv(m, t, j) deve igualar o nº de gestações
de NV residentes em m com (t − s) // 7 = j e término >= t; o mesmo para z_fetal.

Combinações (semente config.SEED): o município com mais NV no total em 2012-01-01, em 2016-06-15 e em
2024-12-20; o com menos NV no total em 2018-07-01; e 1 sorteada. Uma combinação sem nenhuma
gestação de NV em risco, ou nenhuma combinação com óbito fetal em risco, torna a validação não
informativa e o script falha.
Saída: só "bateu / não bateu" por combinação e a diferença agregada — nunca município × dia
(regra do projeto). Sai com código 1 se algo não bater.

Uso:
    uv run 06d_validar_forca_bruta.py               # confere 06_processados/gestacoes_em_risco.parquet
    uv run 06d_validar_forca_bruta.py --rascunho    # confere _tmp/rascunho_06d/
"""
from __future__ import annotations

import argparse
import datetime as dt

import config as C  # antes do polars (R8)
import utils as U

import numpy as np
import pandas as pd
import polars as pl

COORTE = (dt.date(2011, 7, 31), dt.date(2024, 3, 5))


def gestacoes(arquivo, data_col: str, filtro: pl.Expr) -> pl.DataFrame:
    ig = pl.col("semagestac_bruto").str.strip_chars().cast(pl.Int32, strict=False)
    cols = ["CD_MUN6", "gravidez", "semagestac_bruto", data_col] + (["tipo"] if "obitos" in arquivo.name else [])
    g = (pl.scan_parquet(arquivo).select(cols).filter(filtro & (pl.col("gravidez") == "1") & ig.is_between(22, 42))
         .with_columns(ig=ig).with_columns(s=pl.col(data_col) - pl.duration(days=pl.col("ig") * 7 + 3)))
    return (g.filter(pl.col("s").is_between(pl.lit(COORTE[0]), pl.lit(COORTE[1])))
            .select("CD_MUN6", "s", termino=data_col).collect())


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--rascunho", action="store_true")
    a = p.parse_args()
    log = U.get_logger("06d_validar_forca_bruta")
    z = pl.read_parquet((C.TMP / "rascunho_06d" if a.rascunho else C.PROC) / "gestacoes_em_risco.parquet")
    z = z.with_columns(pl.col("data").cast(pl.Date))
    nv = gestacoes(C.PROC / "nascimentos.parquet", "data", pl.lit(True))
    fet = gestacoes(C.PROC / "obitos_perinatais.parquet", "data_obito", pl.col("tipo") == "fetal")

    n_por_mun = nv.group_by("CD_MUN6").len().sort("len", "CD_MUN6")
    maior, menor = n_por_mun["CD_MUN6"][-1], n_por_mun["CD_MUN6"][0]
    rng = np.random.default_rng(C.SEED)
    muns = sorted(n_por_mun["CD_MUN6"].to_list())
    dias = pd.date_range("2012-01-01", "2024-12-31", freq="D")
    combos = [(maior, dt.date(2012, 1, 1)), (maior, dt.date(2016, 6, 15)), (maior, dt.date(2024, 12, 20)),
              (menor, dt.date(2018, 7, 1)), (muns[int(rng.integers(len(muns)))], dias[int(rng.integers(len(dias)))].date())]

    resultados, dif_total, nv_vazias, com_fetal = [], 0, 0, 0
    for n, (m, t) in enumerate(combos, start=1):
        ok_comb = True
        for nome, g in (("z_nv", nv), ("z_fetal", fet)):
            forca = (g.filter((pl.col("CD_MUN6") == m) & (pl.col("termino") >= pl.lit(t)))
                     .with_columns(semana=((pl.lit(t) - pl.col("s")).dt.total_days() // 7))
                     .filter(pl.col("semana").is_between(22, 42)).group_by("semana").len())
            forca = dict(zip(forca["semana"].to_list(), forca["len"].to_list()))
            arq = z.filter((pl.col("CD_MUN6") == m) & (pl.col("data") == pl.lit(t)))
            arq = {int(j): int(v) for j, v in zip(arq["semana"].to_list(), arq[nome].to_list()) if v}
            dif = sum(abs(forca.get(j, 0) - arq.get(j, 0)) for j in range(22, 43))
            dif_total += dif
            ok_comb &= dif == 0
            if nome == "z_nv":
                nv_vazias += sum(forca.values()) == 0
            else:
                com_fetal += sum(forca.values()) > 0
        resultados.append({"combinacao": n, "resultado": "bateu" if ok_comb else "NÃO bateu"})
        log.info("combinação %d: %s (comparação semana a semana)", n, "bateu" if ok_comb else "NÃO bateu")
    log.info("Diferença agregada (soma dos |força bruta − arquivo| por semana, z_nv + z_fetal, 5 combinações): %d", dif_total)
    if not a.rascunho:
        pd.DataFrame(resultados).assign(diferenca_agregada=dif_total).to_csv(C.LOGS / "validacao_06d_forca_bruta.csv", index=False)
        U.registrar_proveniencia([C.LOGS / "validacao_06d_forca_bruta.csv"],
                                 ["06_processados/gestacoes_em_risco.parquet", "06_processados/nascimentos.parquet",
                                  "06_processados/obitos_perinatais.parquet", *U.codigo(__file__)], __file__)
    if nv_vazias or not com_fetal:
        log.error("validação não informativa: %d combinação(ões) sem NV em risco; %d com óbito fetal em risco",
                  nv_vazias, com_fetal)
    if dif_total or nv_vazias or not com_fetal:
        raise SystemExit(1)


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception:  # noqa: BLE001 — a exceção vai para o .log (auditoria A12)
        U.get_logger("06d_validar_forca_bruta").exception("validação interrompida por exceção")
        raise
