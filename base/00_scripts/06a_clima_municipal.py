"""06a — Exposições por município × dia: temperatura, umidade e PM2.5.

Unidade: os 277 municípios das 26 grandes concentrações urbanas (04), que já incluem as
26 cidades-núcleo. A série da cidade-núcleo e a média do recorte saem no 06c.

BR-DWGD v_3.2.4 (0,1°, diário): tmax, tmin, tmean = (Tmax + Tmin)/2 (o BR-DWGD não traz a
média), rh_mean (umidade relativa média do dia, %) e pr.
- Média ponderada pela área da interseção célula ∩ município, numa projeção equivalente
  (South America Albers Equal Area, ESRI:102033).
- Célula válida = tem dado em ALGUM dia do período (máscara do Tmax). Num dia sem dado
  numa célula válida, os pesos se renormalizam entre as células restantes do município.
- Dias faltantes são contados ANTES da renormalização (E9) e vão para
  logs/dias_faltantes_clima.csv: por município × variável, dias com alguma célula sem dado,
  dias sem nenhuma célula, primeira e última data afetada.
- Município sem nenhuma célula válida: célula válida mais próxima do centroide, a mesma
  lógica do script oficial do autor (extraindo_dados_nivel_municipal.py). Alerta acima
  de 0,15°.

CAMS EAC4 (0,75°, a cada 3 h): PM2.5 de superfície, em µg/m³ (kg m-3 × 1e9), com a mesma
ponderação por área numa tabela de pesos própria. As escolhas de método viram colunas e ficam
para cada artigo (P-PM25-ZERO; auditoria A12):
- dia UTC (00–21 UTC): pm25 (zeros exatos mantidos; NA se faltar horário) e pm25_zero_na
  (zero exato vira NA por célula; o município fica sem valor no horário se todas as suas
  células forem zero; o dia exige >= 6 dos 8 horários);
- dia aproximadamente local (UTC-3: 03–21 UTC do dia + 00 UTC do dia seguinte): pm25_local e
  pm25_local_zero_na, com as mesmas regras. Fora do horário de Brasília (UTC-4 em MT, MS, AM;
  horário de verão em parte do país até 2019) o deslocamento real é de 2 a 4 h. O último dia
  (2025-01-31) fica sem as 00 UTC do dia seguinte: pm25_local = NA;
- n_horarios, n_horarios_zero: do dia UTC.

Uso:
    uv run 06a_clima_municipal.py                 # 277 municípios das concentrações
    uv run 06a_clima_municipal.py --todos         # todos os municípios da malha 2024
Saídas:
    06_processados/clima_municipio_diario_{ini}_{fim}.parquet
        CD_MUN, CD_MUN6, data, tmax, tmin, tmean, rh_mean, pr
    06_processados/pm25_municipio_diario_{ini}_{fim}.parquet
        CD_MUN, CD_MUN6, data, pm25, pm25_zero_na, pm25_local, pm25_local_zero_na,
        n_horarios, n_horarios_zero
    06_processados/clima_pesos_municipio.parquet, pm25_pesos_municipio.parquet
    logs/dias_faltantes_clima.csv
"""
from __future__ import annotations

import argparse
import os

import config as C
import utils as U

import numpy as np
import pandas as pd

PROJ_AREA = "ESRI:102033"
NOMES = {"Tmax": "tmax", "Tmin": "tmin", "RH": "rh_mean", "pr": "pr"}
CAMS_UNIDADE = "kg m**-3"
CAMS_HORARIOS = 8
MIN_HORARIOS_ZERO_NA = 6


def para(log, msg, *args):
    log.error(msg, *args)
    raise SystemExit(1)


def abrir_var(var: str):
    import xarray as xr
    arqs = sorted(a for a in (C.CLIMA / "netcdf").glob(f"{var}_*.nc") if not a.name.startswith("._"))
    if not arqs:
        raise FileNotFoundError(f"Sem NetCDF de {var} em 03_clima/netcdf (rode 03_download_clima.py)")
    ds = xr.open_mfdataset([str(a) for a in arqs], combine="by_coords")
    lat = next(d for d in ds.dims if d.lower().startswith("lat"))
    lon = next(d for d in ds.dims if d.lower().startswith("lon"))
    da = ds[var].rename({lat: "lat", lon: "lon"}).sel(time=slice(C.CLIMA_INI, C.CLIMA_FIM))
    return da.sortby("lat").sortby("lon").transpose("time", "lat", "lon")


def abrir_cams(log):
    import xarray as xr
    arqs = sorted(a for a in (C.CLIMA / "cams_pm25").glob("eac4_pm25_*.nc") if not a.name.startswith("._"))
    if not arqs:
        para(log, "Sem NetCDF do CAMS em 03_clima/cams_pm25 (rode 03b_download_cams.py)")
    partes = []
    for a in arqs:
        ds = xr.open_dataset(a, engine="netcdf4")
        tn = "valid_time" if "valid_time" in ds.coords else "time"
        da = ds["pm2p5"]
        if da.attrs.get("units") != CAMS_UNIDADE:
            para(log, "%s: unidade %r (esperado %r)", a.name, da.attrs.get("units"), CAMS_UNIDADE)
        partes.append(da.rename({tn: "time", "latitude": "lat", "longitude": "lon"}))
    da = xr.concat(partes, dim="time").sortby("time")
    if pd.Index(da["time"].values).duplicated().any():
        para(log, "CAMS: horário duplicado entre arquivos")
    fim = pd.Timestamp(C.CLIMA_FIM) + pd.Timedelta(hours=23)
    da = da.sel(time=slice(C.CLIMA_INI, fim)) * 1e9          # kg m-3 -> µg m-3
    return da.sortby("lat").sortby("lon").transpose("time", "lat", "lon")


def mascara_valida(da, log) -> np.ndarray:
    """Célula válida = com dado em algum dia. Loga quantas mudam de validade no tempo."""
    import dask
    alguma, todas = (x.values for x in dask.compute(da.notnull().any("time"), da.notnull().all("time")))
    log.info("Máscara: %d células válidas em algum dia; %d mudam de validade ao longo do período",
             int(alguma.sum()), int((alguma & ~todas).sum()))
    return alguma


def pesos(munis, lat: np.ndarray, lon: np.ndarray, valido: np.ndarray, log) -> pd.DataFrame:
    """Tabela (CD_MUN, i_lat, i_lon, w, metodo, dist_graus)."""
    import geopandas as gpd
    from shapely.geometry import box

    dy = float(np.median(np.diff(lat)))
    dx = float(np.median(np.diff(lon)))
    m = munis.to_crs(4326)
    xmin, ymin, xmax, ymax = m.total_bounds
    ii = np.where((lat >= ymin - dy) & (lat <= ymax + dy))[0]
    jj = np.where((lon >= xmin - dx) & (lon <= xmax + dx))[0]
    cel = [(i, j, box(lon[j] - dx / 2, lat[i] - dy / 2, lon[j] + dx / 2, lat[i] + dy / 2))
           for i in ii for j in jj]
    grade = gpd.GeoDataFrame({"i_lat": [c[0] for c in cel], "i_lon": [c[1] for c in cel]},
                             geometry=[c[2] for c in cel], crs=4326)
    log.info("Grade recortada: %d células; %d municípios", len(grade), len(m))
    inter = gpd.overlay(m[["CD_MUN", "geometry"]], grade, how="intersection", keep_geom_type=True)
    inter["area"] = inter.to_crs(PROJ_AREA).area
    inter["valida"] = valido[inter["i_lat"].to_numpy(), inter["i_lon"].to_numpy()]
    # fração da área do município coberta por célula válida (o resto é mar ou fora da máscara;
    # auditoria A4)
    area_mun = m.set_index("CD_MUN").to_crs(PROJ_AREA).area
    coberta = inter[inter["valida"]].groupby("CD_MUN")["area"].sum()
    frac = (coberta / area_mun).reindex(area_mun.index).fillna(0.0).clip(upper=1.0)
    inter = inter[inter["valida"] & (inter["area"] > 0)]
    tab = inter[["CD_MUN", "i_lat", "i_lon", "area"]].rename(columns={"area": "w"})
    tab["metodo"] = "area"
    tab["dist_graus"] = 0.0

    faltam = sorted(set(m["CD_MUN"]) - set(tab["CD_MUN"]))
    if faltam:
        vi, vj = np.where(valido)
        cent = m[m["CD_MUN"].isin(faltam)].to_crs(PROJ_AREA).centroid.to_crs(4326)
        extra = []
        for cd, pt in zip(m.loc[m["CD_MUN"].isin(faltam), "CD_MUN"], cent):
            d2 = (lat[vi] - pt.y) ** 2 + (lon[vj] - pt.x) ** 2
            k = int(np.argmin(d2))
            extra.append({"CD_MUN": cd, "i_lat": vi[k], "i_lon": vj[k], "w": 1.0,
                          "metodo": "vizinho_centroide", "dist_graus": float(np.sqrt(d2[k]))})
        extra = pd.DataFrame(extra)
        tab = pd.concat([tab, extra], ignore_index=True)
        log.warning("%d municípios sem célula válida -> vizinho mais próximo do centroide "
                    "(distância máx. %.3f°)", len(faltam), extra["dist_graus"].max())
        longe = extra[extra["dist_graus"] > 0.15]
        if len(longe):
            log.error("ATENÇÃO: %d municípios com vizinho a > 0,15° (~16 km): %s",
                      len(longe), longe["CD_MUN"].tolist())
    tab["w"] = tab["w"] / tab.groupby("CD_MUN")["w"].transform("sum")
    tab["frac_area_coberta"] = tab["CD_MUN"].map(frac)
    baixa = frac[frac < 0.9].sort_values()
    log.info("Fração da área coberta por célula válida: mín %.3f | %d municípios < 0,90 | %d < 0,75 | menores: %s",
             frac.min(), len(baixa), int((frac < 0.75).sum()), baixa.head(8).round(3).to_dict())
    if set(tab["CD_MUN"]) != set(m["CD_MUN"]):
        para(log, "pesos: municípios sem nenhuma célula atribuída: %s", sorted(set(m["CD_MUN"]) - set(tab["CD_MUN"])))
    return tab


def _indices(tab: pd.DataFrame):
    cods = tab["CD_MUN"].unique()
    idx = {c: k for k, c in enumerate(cods)}
    return cods, tab["CD_MUN"].map(idx).to_numpy(), tab["i_lat"].to_numpy(), tab["i_lon"].to_numpy(), tab["w"].to_numpy()


def extrair(da, tab: pd.DataFrame, nome: str, log) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Média ponderada por município × dia, ano a ano. Devolve também os dias faltantes,
    contados antes da renormalização: (dias com alguma célula sem dado, dias sem nenhuma)."""
    cods, lin, il, jl, w = _indices(tab)
    out, falt = [], []
    anos = sorted(set(pd.to_datetime(da["time"].values).year))
    for ano in anos:
        bloco = da.sel(time=str(ano)).load().values  # (t, lat, lon)
        datas = pd.to_datetime(da.sel(time=str(ano))["time"].values).normalize()
        v = bloco[:, il, jl]                           # (t, n_pares)
        ok = ~np.isnan(v)
        num = np.zeros((len(datas), len(cods)))
        den = np.zeros((len(datas), len(cods)))
        n_falta = np.zeros((len(datas), len(cods)))
        np.add.at(num.T, lin, (np.where(ok, v, 0) * w).T)
        np.add.at(den.T, lin, (ok * w).T)
        np.add.at(n_falta.T, lin, (~ok).astype(float).T)
        with np.errstate(invalid="ignore", divide="ignore"):
            med = np.where(den > 0, num / den, np.nan)
        df = pd.DataFrame(med, index=datas, columns=cods).stack(future_stack=True)
        out.append(df.rename(nome).reset_index().rename(columns={"level_0": "data", "level_1": "CD_MUN"}))
        alguma = pd.DataFrame(n_falta > 0, index=datas, columns=cods)
        nenhuma = pd.DataFrame(den == 0, index=datas, columns=cods)
        falt.append(pd.concat({"alguma": alguma.stack(), "nenhuma": nenhuma.stack()}, axis=1))
        log.info("%s %d: %d dias x %d municípios | dias-município com alguma célula sem dado=%d | "
                 "sem nenhuma=%d", nome, ano, len(datas), len(cods), int(alguma.values.sum()),
                 int(nenhuma.values.sum()))
    f = pd.concat(falt).rename_axis(["data", "CD_MUN"]).reset_index()
    res = []
    for cd, g in f.groupby("CD_MUN"):
        afet = g.loc[g["alguma"], "data"]
        res.append({"CD_MUN": cd, "variavel": nome, "n_dias_alguma_celula_sem_dado": int(g["alguma"].sum()),
                    "n_dias_sem_dado": int(g["nenhuma"].sum()),
                    "primeira_data": afet.min().date() if len(afet) else None,
                    "ultima_data": afet.max().date() if len(afet) else None})
    return pd.concat(out, ignore_index=True), pd.DataFrame(res)


def _diario(idx: np.ndarray, n_dias: int, vals: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """Soma e contagem (sem NaN) por dia, para vals (tempos × municípios)."""
    ok = ~np.isnan(vals)
    soma = np.zeros((n_dias, vals.shape[1]))
    cont = np.zeros((n_dias, vals.shape[1]))
    np.add.at(soma, idx, np.where(ok, vals, 0))
    np.add.at(cont, idx, ok)
    return soma, cont


def extrair_pm25(da, tab: pd.DataFrame, log) -> pd.DataFrame:
    """PM2.5 diário por município: dia UTC e dia aproximadamente local (UTC-3), cada um com
    os zeros mantidos e com zero -> NA (ver docstring do módulo). A agregação diária é feita
    sobre o período inteiro, porque o dia local de 31/12 usa as 00 UTC de 01/01 (outro arquivo)."""
    cods, lin, il, jl, w = _indices(tab)
    tempos_l, hor_l, hor0_l, z_l = [], [], [], []
    for ano in sorted(set(pd.to_datetime(da["time"].values).year)):
        sub = da.sel(time=str(ano))
        v = sub.load().values[:, il, jl]               # (t, n_pares), sem NaN no CAMS
        ok = ~np.isnan(v)
        pos = ok & (v != 0)
        num = np.zeros((v.shape[0], len(cods)))
        den, num0, den0, nzero = (np.zeros_like(num) for _ in range(4))
        np.add.at(num.T, lin, (np.where(ok, v, 0) * w).T)
        np.add.at(den.T, lin, (ok * w).T)
        np.add.at(num0.T, lin, (np.where(pos, v, 0) * w).T)
        np.add.at(den0.T, lin, (pos * w).T)
        np.add.at(nzero.T, lin, (ok & (v == 0)).astype(float).T)
        with np.errstate(invalid="ignore", divide="ignore"):
            hor_l.append(np.where(den > 0, num / den, np.nan))
            hor0_l.append(np.where(den0 > 0, num0 / den0, np.nan))
        z_l.append((nzero > 0).astype(float))
        tempos_l.append(pd.to_datetime(sub["time"].values))
    tempos = pd.DatetimeIndex(np.concatenate([t.to_numpy() for t in tempos_l]))
    hor, hor0, z = np.vstack(hor_l), np.vstack(hor0_l), np.vstack(z_l)
    dias = pd.date_range(C.CLIMA_INI, C.CLIMA_FIM, freq="D")
    dia0 = dias[0]
    out = {}
    for rotulo, desloc in (("", pd.Timedelta(0)), ("_local", pd.Timedelta(hours=3))):
        idx = ((tempos - desloc).normalize() - dia0).days.to_numpy()
        dentro = (idx >= 0) & (idx < len(dias))      # o dia local antes de 2010-01-01 cai fora
        i = idx[dentro]
        s, c = _diario(i, len(dias), hor[dentro])
        s0, c0 = _diario(i, len(dias), hor0[dentro])
        with np.errstate(invalid="ignore", divide="ignore"):
            out[f"pm25{rotulo}"] = np.where(c >= CAMS_HORARIOS, s / np.maximum(c, 1), np.nan)
            out[f"pm25{rotulo}_zero_na"] = np.where(c0 >= MIN_HORARIOS_ZERO_NA, s0 / np.maximum(c0, 1), np.nan)
        if rotulo == "":
            out["n_horarios"] = c.astype(int)
            out["n_horarios_zero"] = _diario(i, len(dias), z[dentro])[0].astype(int)
    n_d, n_m = len(dias), len(cods)
    d = pd.DataFrame({"data": np.repeat(dias.to_numpy(), n_m), "CD_MUN": np.tile(cods, n_d),
                      **{k: v.ravel() for k, v in out.items()}}).sort_values(["data", "CD_MUN"], ignore_index=True)
    log.info("PM2.5: %d dias x %d municípios | dias-município com algum zero=%d | NA: pm25=%d, "
             "pm25_zero_na=%d, pm25_local=%d, pm25_local_zero_na=%d", n_d, n_m, int((d["n_horarios_zero"] > 0).sum()),
             *(int(d[k].isna().sum()) for k in ("pm25", "pm25_zero_na", "pm25_local", "pm25_local_zero_na")))
    return d


def gravar(df: pd.DataFrame, saida, log) -> None:
    tmp = saida.with_suffix(".parquet.part")
    df.to_parquet(tmp, index=False)
    os.replace(tmp, saida)
    if not saida.exists() or saida.stat().st_size == 0:   # Forja não-APFS: conferir a gravação
        para(log, "falha ao gravar %s", saida)


def registrar_auxiliar(caminho, df: pd.DataFrame, descricao: str) -> None:
    """Arquivos auxiliares do 06a também vão para o integridade.csv (auditoria A3)."""
    U.registrar_integridade([{
        "sistema": "CLIMA-auxiliar", "ano": f"{C.CLIMA_INI[:4]}-{C.CLIMA_FIM[:4]}", "uf": "BR",
        "arquivo": caminho.name, "status": "derivado", "n_linhas": len(df),
        "n_municipios": df["CD_MUN"].nunique() if "CD_MUN" in df else "", "md5_parquet": U.md5(caminho),
        "observacao": descricao,
    }])


def conferir_dias(df: pd.DataFrame, nome: str, log) -> tuple[int, int, int]:
    esperado = (pd.Timestamp(C.CLIMA_FIM) - pd.Timestamp(C.CLIMA_INI)).days + 1
    if df.duplicated(["CD_MUN", "data"]).any():
        para(log, "%s: par município × data repetido", nome)
    por_mun = df.groupby("CD_MUN")["data"].nunique()
    if por_mun.min() != esperado or por_mun.max() != esperado:
        para(log, "%s: dias por município %d-%d (esperado %d)", nome, por_mun.min(), por_mun.max(), esperado)
    return int(por_mun.min()), int(por_mun.max()), esperado


def main():
    import geopandas as gpd

    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--todos", action="store_true", help="todos os municípios da malha 2024")
    a = p.parse_args()
    log = U.get_logger("06a_clima_municipal")
    C.PROC.mkdir(parents=True, exist_ok=True)

    munis = gpd.read_file(C.SHP / "municipios_2024.gpkg")
    munis = munis[munis["CD_MUN"].astype(str).str.match(r"^\d{7}$")]
    if not a.todos:
        conc = pd.read_csv(C.RM / "concentracoes_urbanas_municipios.csv", dtype=str)
        fora = sorted(set(conc["CD_MUN"]) - set(munis["CD_MUN"]))
        if fora:
            para(log, "municípios das concentrações fora da malha 2024: %s", fora)
        munis = munis[munis["CD_MUN"].isin(conc["CD_MUN"])]
    log.info("Municípios: %d (%s)", len(munis), "todos" if a.todos else "26 concentrações")

    # --- BR-DWGD: temperatura, umidade, precipitação --------------------------------
    tab, grade_ref, series, faltantes = None, None, [], []
    for var, nome in NOMES.items():
        da = abrir_var(var)
        grade = (da["lat"].values, da["lon"].values)
        if grade_ref is None:
            grade_ref = grade
        elif not (np.allclose(grade[0], grade_ref[0]) and np.allclose(grade[1], grade_ref[1])):
            para(log, "Grade de %s difere da de Tmax: os pesos ficariam desalinhados", var)
        if tab is None:
            tab = pesos(munis, da["lat"].values, da["lon"].values, mascara_valida(da, log), log)
            gravar(tab, C.PROC / "clima_pesos_municipio.parquet", log)
            registrar_auxiliar(C.PROC / "clima_pesos_municipio.parquet", tab, "pesos BR-DWGD (0,1°)")
        serie, falt = extrair(da, tab, nome, log)
        series.append(serie.set_index(["data", "CD_MUN"]))
        faltantes.append(falt)
    df = pd.concat(series, axis=1).reset_index()
    df["tmean"] = (df["tmax"] + df["tmin"]) / 2
    df["CD_MUN6"] = df["CD_MUN"].str[:6]
    df = df[["CD_MUN", "CD_MUN6", "data", "tmax", "tmin", "tmean", "rh_mean", "pr"]]
    dmin, dmax, esperado = conferir_dias(df, "clima", log)
    saida = C.PROC / f"clima_municipio_diario_{C.CLIMA_INI[:4]}_{C.CLIMA_FIM[:4]}.parquet"
    df["data"] = pd.to_datetime(df["data"]).dt.date        # date32 em todas as saídas (AA9)
    gravar(df, saida, log)
    falt = pd.concat(faltantes, ignore_index=True)
    falt.to_csv(C.LOGS / "dias_faltantes_clima.csv", index=False)
    registrar_auxiliar(C.LOGS / "dias_faltantes_clima.csv", falt, "dias faltantes antes da renormalização (E9)")
    viz = tab.groupby("CD_MUN").agg(metodo=("metodo", "first"), dist=("dist_graus", "max"))
    n_viz = int((viz["metodo"] == "vizinho_centroide").sum())
    log.info("Clima: %s | %d linhas | %d municípios | dias/município %d-%d (esperado %d) | "
             "vizinho do centroide: %d (dist. máx. %.3f°) | NaN: tmean %.4f%%, rh_mean %.4f%%",
             saida.name, len(df), df["CD_MUN"].nunique(), dmin, dmax, esperado, n_viz,
             viz.loc[viz["metodo"] == "vizinho_centroide", "dist"].max() if n_viz else 0.0,
             100 * df["tmean"].isna().mean(), 100 * df["rh_mean"].isna().mean())
    log.info("dias_faltantes_clima.csv: %s", falt.groupby("variavel")[
        ["n_dias_alguma_celula_sem_dado", "n_dias_sem_dado"]].sum().to_dict("index"))
    U.registrar_integridade([{
        "sistema": "CLIMA-municipal", "ano": f"{C.CLIMA_INI[:4]}-{C.CLIMA_FIM[:4]}", "uf": "BR",
        "arquivo": saida.name, "status": C.BRDWGD_VERSAO, "n_linhas": len(df),
        "n_municipios": df["CD_MUN"].nunique(), "md5_parquet": U.md5(saida),
        "observacao": f"dias/mun {dmin}-{dmax} de {esperado}; vizinho_centroide={n_viz}; "
                      f"NaN tmean={100 * df['tmean'].isna().mean():.4f}%; rh_mean={100 * df['rh_mean'].isna().mean():.4f}%",
    }])

    # --- CAMS: PM2.5 -------------------------------------------------------------------
    pm = abrir_cams(log)
    tab_pm = pesos(munis, pm["lat"].values, pm["lon"].values,
                   np.ones((pm.sizes["lat"], pm.sizes["lon"]), dtype=bool), log)
    gravar(tab_pm, C.PROC / "pm25_pesos_municipio.parquet", log)
    registrar_auxiliar(C.PROC / "pm25_pesos_municipio.parquet", tab_pm, "pesos CAMS (0,75°)")
    d = extrair_pm25(pm, tab_pm, log)
    d["CD_MUN6"] = d["CD_MUN"].str[:6]
    d = d[["CD_MUN", "CD_MUN6", "data", "pm25", "pm25_zero_na", "pm25_local", "pm25_local_zero_na",
           "n_horarios", "n_horarios_zero"]]
    dmin, dmax, esperado = conferir_dias(d, "PM2.5", log)
    saida_pm = C.PROC / f"pm25_municipio_diario_{C.CLIMA_INI[:4]}_{C.CLIMA_FIM[:4]}.parquet"
    d["data"] = pd.to_datetime(d["data"]).dt.date          # date32 (AA9)
    gravar(d, saida_pm, log)
    log.info("PM2.5: %s | %d linhas | dias/município %d-%d (esperado %d) | NaN: pm25 %.4f%%, "
             "pm25_zero_na %.4f%%, pm25_local %.4f%%, pm25_local_zero_na %.4f%% | dias-município com algum "
             "zero %.2f%%", saida_pm.name, len(d), dmin, dmax, esperado,
             *(100 * d[k].isna().mean() for k in ("pm25", "pm25_zero_na", "pm25_local", "pm25_local_zero_na")),
             100 * (d["n_horarios_zero"] > 0).mean())
    U.registrar_integridade([{
        "sistema": "PM25-municipal", "ano": f"{C.CLIMA_INI[:4]}-{C.CLIMA_FIM[:4]}", "uf": "BR",
        "arquivo": saida_pm.name, "status": "CAMS-EAC4", "n_linhas": len(d),
        "n_municipios": d["CD_MUN"].nunique(), "md5_parquet": U.md5(saida_pm),
        "observacao": f"dia UTC; dias/mun {dmin}-{dmax} de {esperado}; NaN pm25={100 * d['pm25'].isna().mean():.4f}%; "
                      f"pm25_zero_na={100 * d['pm25_zero_na'].isna().mean():.4f}%",
    }])
    if not a.todos:   # proveniência só da versão da base (277 municípios)
        U.registrar_proveniencia([saida, saida_pm, C.PROC / "clima_pesos_municipio.parquet", C.PROC / "pm25_pesos_municipio.parquet",
                                  C.LOGS / "dias_faltantes_clima.csv"],
                                 ["integridade:BR-DWGD", "integridade:CAMS-EAC4", "05_shapefiles/municipios_2024.gpkg",
                                  "04_regioes_metropolitanas/concentracoes_urbanas_municipios.csv", *U.codigo(__file__)], __file__)


if __name__ == "__main__":
    main()
