"""06d — Gestações em risco por município × dia × semana gestacional (E7; insumo do offset da
coorte fixa). Substitui o 04_series_offset.R previsto na especificação (desvio de 05/10/2026);
o W_t e o γ ficam para o R de cada artigo.

Uma gestação com início s (= data do término − (7 × IG + 3)) está na semana j no dia t quando
(t − s) // 7 = j e o término é >= t. Entram só gestações da coorte fixa (`coorte_fixa_22`):
- z_nv:    terminadas em nascido vivo único com IG 22–42 (término = nascimento);
- z_fetal: terminadas em óbito fetal único principal, IG 22–42 (término = óbito).
Os nascimentos de 43–44 semanas ficam de fora (E7). O Z_t da prematuridade (semanas 22–36)
usa só z_nv; o do óbito perinatal (22–42), z_nv + z_fetal.

Cálculo por soma de diferenças num arranjo município × semana × dia (sem expandir registro
por registro). Conferência interna: a soma de todas as células é igual à soma, por gestação,
dos dias em risco entre a semana 22 e o término (7 × (IG − 22) + 4). A validação por força
bruta, exigida pelo E7, fica em código separado: 06d_validar_forca_bruta.py.

Uso:
    uv run 06d_gestacoes_em_risco.py              # 06_processados/gestacoes_em_risco.parquet
    uv run 06d_gestacoes_em_risco.py --rascunho   # grava em _tmp/rascunho_06d/ (teste; dentro da Forja);
                                                  # lê nascimentos e óbitos de 06_processados/
Saída (longa e esparsa, só células > 0):
    CD_MUN6, data (2012-01-01 a 2024-12-31), semana (22–42), z_nv, z_fetal
"""
from __future__ import annotations

import argparse
import datetime as dt
import os

import config as C  # antes do polars (R8)
import utils as U

import numpy as np
import pandas as pd
import polars as pl

SEMANAS = np.arange(22, 43)
INI, FIM = dt.date(2012, 1, 1), dt.date(2024, 12, 31)
D0 = dt.date(2011, 1, 1)                     # origem dos índices de dia (antes de qualquer s + 154)


def para(log, msg, *args):
    log.error(msg, *args)
    raise SystemExit(1)


def gestacoes(origem) -> tuple[pd.DataFrame, pd.DataFrame]:
    """(nv, fetal): CD_MUN6, s, termino, ig — só a coorte fixa."""
    nv = (pl.scan_parquet(origem / "nascimentos.parquet")
          .filter(pl.col("pop_ptb") & pl.col("coorte_fixa_22"))
          .select("CD_MUN6", pl.col("dum_est").alias("s"), pl.col("data").alias("termino"), pl.col("ga_sem").alias("ig"))
          .collect().to_pandas())
    fet = (pl.scan_parquet(origem / "obitos_perinatais.parquet")
           .filter((pl.col("tipo") == "fetal") & pl.col("principal") & pl.col("coorte_fixa_22"))
           .select("CD_MUN6", pl.col("s_ini").alias("s"), pl.col("data_indice").alias("termino"), pl.col("ga_sem").alias("ig"))
           .collect().to_pandas())
    return nv, fet


def contar(g: pd.DataFrame, idx_mun: dict, n_dias: int) -> np.ndarray:
    """Z[m, j, d] por soma de diferenças. g: CD_MUN6, s, termino (datas)."""
    n_m, n_j = len(idx_mun), len(SEMANAS)
    m = g["CD_MUN6"].map(idx_mun).to_numpy()
    s = (pd.to_datetime(g["s"]) - pd.Timestamp(D0)).dt.days.to_numpy()
    e = (pd.to_datetime(g["termino"]) - pd.Timestamp(D0)).dt.days.to_numpy()
    tam = n_m * n_j * (n_dias + 1)
    dif = np.zeros(tam, dtype=np.int64)
    for k, j in enumerate(SEMANAS):
        ini = s + 7 * j
        fim = np.minimum(ini + 6, e)
        ok = ini <= e                                        # a gestação chegou à semana j antes de terminar
        base = (m[ok] * n_j + k) * (n_dias + 1)
        dif += np.bincount(base + ini[ok], minlength=tam)
        dif -= np.bincount(base + fim[ok] + 1, minlength=tam)
    return np.cumsum(dif.reshape(n_m, n_j, n_dias + 1), axis=2)[:, :, :n_dias].astype(np.int32)


def dias_em_risco(g: pd.DataFrame) -> int:
    """Soma, por gestação, dos dias da semana 22 até o término: 7 × (IG − 22) + 4 (conferência)."""
    return int((7 * (g["ig"].astype(int) - 22) + 4).sum())


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--rascunho", action="store_true", help="grava em _tmp/rascunho_06d (dentro da Forja); lê de 06_processados")
    a = p.parse_args()
    log = U.get_logger("06d_gestacoes_em_risco")
    origem = C.PROC
    destino = C.TMP / "rascunho_06d" if a.rascunho else C.PROC
    destino.mkdir(parents=True, exist_ok=True)

    nv, fet = gestacoes(origem)
    for nome, g in (("NV", nv), ("fetal", fet)):
        if g[["s", "termino", "ig"]].isna().any().any():
            para(log, "%s: gestação da coorte sem s, término ou IG", nome)
        fora = ((pd.to_datetime(g["s"]) + pd.Timedelta(days=154) < pd.Timestamp(INI))
                | (pd.to_datetime(g["termino"]) > pd.Timestamp(FIM))).sum()
        if fora:
            para(log, "%s: %d gestações da coorte com dias em risco fora de 2012–2024 (coorte fixa mal definida?)", nome, fora)
        log.info("%s: %d gestações da coorte fixa", nome, len(g))

    muns = sorted(pd.read_csv(C.RM / "concentracoes_urbanas_municipios.csv", dtype=str)["CD_MUN6"])
    idx = {c: i for i, c in enumerate(muns)}
    n_dias = (FIM - D0).days + 1
    z_nv, z_fet = contar(nv, idx, n_dias), contar(fet, idx, n_dias)
    for nome, z, g in (("z_nv", z_nv, nv), ("z_fetal", z_fet, fet)):
        if int(z.sum()) != dias_em_risco(g):
            para(log, "%s: soma das células %d != dias em risco das gestações %d", nome, int(z.sum()), dias_em_risco(g))
        log.info("%s: soma das células = dias em risco das gestações = %d (confere)", nome, int(z.sum()))

    d_ini = (INI - D0).days
    z_nv, z_fet = z_nv[:, :, d_ini:], z_fet[:, :, d_ini:]          # 2012-01-01 em diante
    mm, jj, dd = np.nonzero((z_nv > 0) | (z_fet > 0))
    datas = pd.date_range(INI, FIM, freq="D")
    out = pd.DataFrame({"CD_MUN6": np.array(muns)[mm], "data": datas[dd].date,   # date32, como nas outras saídas (AA9)
                        "semana": SEMANAS[jj].astype(np.int16),
                        "z_nv": z_nv[mm, jj, dd], "z_fetal": z_fet[mm, jj, dd]})
    out = out.sort_values(["CD_MUN6", "data", "semana"], ignore_index=True)
    saida = destino / "gestacoes_em_risco.parquet"
    tmp = saida.with_suffix(".parquet.part")
    out.to_parquet(tmp, index=False)
    os.replace(tmp, saida)
    if not saida.exists() or saida.stat().st_size == 0:
        para(log, "falha ao gravar %s", saida)
    log.info("%s: %d células > 0 | %d municípios | %d dias | z_nv total %d | z_fetal total %d",
             saida.name, len(out), out["CD_MUN6"].nunique(), out["data"].nunique(), int(out["z_nv"].sum()),
             int(out["z_fetal"].sum()))
    if not a.rascunho:
        U.registrar_integridade([{
            "sistema": "GESTACOES-RISCO", "ano": "2012-2024", "uf": "concentracoes", "arquivo": saida.name,
            "status": "derivado", "n_linhas": len(out), "n_municipios": out["CD_MUN6"].nunique(),
            "md5_parquet": U.md5(saida), "observacao": "E7; coorte fixa; semanas 22-42; validar com 06d_validar_forca_bruta.py",
        }])
        U.registrar_proveniencia([saida], ["06_processados/nascimentos.parquet", "06_processados/obitos_perinatais.parquet",
                                           "04_regioes_metropolitanas/concentracoes_urbanas_municipios.csv", *U.codigo(__file__)], __file__)


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception:  # noqa: BLE001 — a exceção vai para o .log (auditoria A12)
        U.get_logger("06d_gestacoes_em_risco").exception("06d interrompido por exceção")
        raise
