"""Teste sintético do 06a: campos de valor conhecido (nenhum dado real) para os pesos por área,
a renormalização, os dias faltantes, o vizinho do centroide, a fração de área coberta e as
quatro variantes do PM2.5 (dia UTC e local; zeros mantidos e zero -> NA).

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/teste_06a_sintetico.py
    ALVO_DIR=../_tmp/diffs/c1/novo PYTHONPATH=. uv run python testes/teste_06a_sintetico.py
Sai com código 1 se algum caso falhar.
"""
import importlib.util
import logging
import os
import sys
from pathlib import Path

import geopandas as gpd
import numpy as np
import pandas as pd
import xarray as xr
from shapely.geometry import box

ALVO = Path(os.environ.get("ALVO_DIR", Path(__file__).resolve().parent.parent))
sp = importlib.util.spec_from_file_location("m06a", ALVO / "06a_clima_municipal.py")
m = importlib.util.module_from_spec(sp); sp.loader.exec_module(m)
logging.basicConfig(level=logging.CRITICAL)
log = logging.getLogger("t")
res = {}

# grade 0,1°, 10 dias
lat = np.round(np.arange(-23.95, -23.0, 0.1), 2); lon = np.round(np.arange(-46.95, -46.0, 0.1), 2)
datas = pd.date_range("2020-01-01", periods=10, freq="D")
val = np.zeros((10, len(lat), len(lon))); val[:] = np.arange(10)[:, None, None] + 0.0
iA, jA = 3, 3
val[:, iA, jA + 1] += 3.0                              # célula B = dia + 3
val[3, iA, jA + 1] = np.nan                            # dia 3: B sem dado
val[5, iA, jA] = np.nan; val[5, iA, jA + 1] = np.nan   # dia 5: A e B sem dado
val[:, 8:, 8:] = np.nan                                # canto sem dado (máscara)
da = xr.DataArray(val, coords={"time": datas, "lat": lat, "lon": lon}, dims=("time", "lat", "lon"))
x0, y0 = lon[jA] - 0.05, lat[iA] - 0.05
mun1 = box(x0, y0, x0 + 0.15, y0 + 0.1)                # A inteira + metade de B -> 2/3 e 1/3
mun2 = box(lon[9] - 0.02, lat[9] - 0.02, lon[9] + 0.02, lat[9] + 0.02)   # no canto sem dado
munis = gpd.GeoDataFrame({"CD_MUN": ["1000001", "1000002"]}, geometry=[mun1, mun2], crs=4326)
tab = m.pesos(munis, lat, lon, m.mascara_valida(da.chunk({"time": 5}), log), log)
w1 = tab[tab.CD_MUN == "1000001"].set_index(["i_lat", "i_lon"])["w"]
res["pesos 2/3 e 1/3"] = abs(w1[(iA, jA)] - 2 / 3) < 2e-3 and abs(w1[(iA, jA + 1)] - 1 / 3) < 2e-3
res["município sem célula válida -> vizinho do centroide"] = tab.loc[tab.CD_MUN == "1000002", "metodo"].iloc[0] == "vizinho_centroide"
res["frac_area_coberta: 1 no município 1, 0 no 2"] = (abs(tab.loc[tab.CD_MUN == "1000001", "frac_area_coberta"].iloc[0] - 1) < 1e-6
                                                      and tab.loc[tab.CD_MUN == "1000002", "frac_area_coberta"].iloc[0] == 0)
serie, falt = m.extrair(da, tab, "tmax", log)
s1 = serie[serie.CD_MUN == "1000001"].set_index("data")["tmax"]
esper = pd.Series(np.arange(10) + 1.0, index=datas); esper[datas[3]] = 3.0; esper[datas[5]] = np.nan
res["média ponderada e renormalização"] = np.allclose(s1.values, esper.values, atol=2e-3, equal_nan=True)
f1 = falt[falt.CD_MUN == "1000001"].iloc[0]
res["dias faltantes contados antes da renormalização"] = (f1.n_dias_alguma_celula_sem_dado == 2 and f1.n_dias_sem_dado == 1
                                                          and str(f1.primeira_data) == "2020-01-04" and str(f1.ultima_data) == "2020-01-06")

# PM2.5: grade 0,75°, 3 dias × 8 horários
latp = np.array([-24.0, -23.25]); lonp = np.array([-47.25, -46.5])
tempos = pd.date_range("2010-01-01", periods=24, freq="3h")
m.C.CLIMA_INI, m.C.CLIMA_FIM = "2010-01-01", "2010-01-03"
pm = np.full((24, 2, 2), 10.0); pm[:, 0, 1] = 20.0
pm[8:11, 0, 1] = 0.0          # dia 2: 3 horários com zero numa célula
pm[16:19, :, :] = 0.0         # dia 3: 3 horários com zero em todas
dap = xr.DataArray(pm, coords={"time": tempos, "lat": latp, "lon": lonp}, dims=("time", "lat", "lon"))
mp = gpd.GeoDataFrame({"CD_MUN": ["1000001"]}, geometry=[box(-47.25, -24.0, -46.5, -23.9)], crs=4326)
tabp = m.pesos(mp, latp, lonp, np.ones((2, 2), bool), log)
d = m.extrair_pm25(dap, tabp, log).set_index("data")
res["dia sem zero: pm25 = pm25_zero_na = 15"] = np.isclose(d.iloc[0].pm25, 15) and np.isclose(d.iloc[0].pm25_zero_na, 15)
res["dia 2: zeros mantidos x zero -> NA por célula"] = (np.isclose(d.iloc[1].pm25, (5 * 15 + 3 * 5) / 8)
                                                       and np.isclose(d.iloc[1].pm25_zero_na, (5 * 15 + 3 * 10) / 8)
                                                       and d.iloc[1].n_horarios_zero == 3)
res["dia 3: 5 de 8 válidos -> pm25_zero_na NA"] = np.isnan(d.iloc[2].pm25_zero_na) and np.isclose(d.iloc[2].pm25, 5 * 15 / 8)
res["dia local 1 = 03–21 UTC + 00 UTC do dia 2"] = (np.isclose(d.iloc[0].pm25_local, (7 * 15 + 5) / 8)
                                                    and np.isclose(d.iloc[0].pm25_local_zero_na, (7 * 15 + 10) / 8))
res["último dia local sem as 00 UTC seguintes -> NA"] = np.isnan(d.iloc[2].pm25_local)
for kk, v in res.items():
    print("OK   " if v else "FALHA", kk)
falhas = sum(not v for v in res.values())
print(f"{len(res) - falhas}/{len(res)} casos OK")
sys.exit(1 if falhas else 0)
