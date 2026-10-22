"""03 — BR-DWGD (Xavier et al.) v_3.2.4: lista a pasta pública do Drive, baixa os
zips diários que contêm Tmax, Tmin, RH e pr, extrai só os blocos que cobrem o
período e audita cada NetCDF.

A pasta do Drive só tem zips (README da pasta, lido em 02/10/2026). Cada zip traz
as variáveis de 1961–2025 em três blocos; o script baixa os dois zips de
config.BRDWGD_ZIPS para 03_clima/zip/ e extrai para 03_clima/netcdf/ só os blocos
que cobrem CLIMA_INI–CLIMA_FIM, sem os *_Control. A versão v_3.2.4 só aparece no
nome dos arquivos (nenhum atributo interno a cita); a procedência fica no md5 dos
zips, registrado no logs/integridade.csv.

Uso:
    uv run 03_download_clima.py --listar          # só lista o conteúdo da pasta
    uv run 03_download_clima.py                   # baixa os zips, extrai e audita
    uv run 03_download_clima.py --auditar         # só audita o que já está em 03_clima/netcdf

Se o gdown falhar (cota do Google Drive), baixe os zips manualmente pelo link do
config.BRDWGD_DRIVE, coloque-os em 03_clima/zip/ e rode de novo sem opção (o que
já existe é reaproveitado e só extraído).
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
from pathlib import Path

import config as C
import utils as U

NC_DIR = C.CLIMA / "netcdf"
ZIP_DIR = C.CLIMA / "zip"
DATA8 = re.compile(r"(\d{8})[_-](\d{8})")


def cobre_periodo(nome: str) -> bool | None:
    """True/False se o nome traz AAAAMMDD_AAAAMMDD; None se não der para saber."""
    m = DATA8.search(nome)
    if not m:
        return None
    ini, fim = m.group(1), m.group(2)
    return not (fim < C.CLIMA_INI.replace("-", "") or ini > C.CLIMA_FIM.replace("-", ""))


def ncs(padrao: str = "*.nc") -> list[Path]:
    """NetCDF de NC_DIR, sem os AppleDouble (._*) que o disco não-APFS cria."""
    return sorted(p for p in NC_DIR.glob(padrao) if not p.name.startswith("._"))


def zip_de(var: str) -> Path | None:
    """Zip de origem de uma variável, se estiver em ZIP_DIR."""
    nome = next((z for z, vs in C.BRDWGD_ZIPS.items() if var in vs), None)
    return ZIP_DIR / nome if nome and (ZIP_DIR / nome).exists() else None


def listar(log):
    import gdown
    itens = gdown.download_folder(url=C.BRDWGD_DRIVE, skip_download=True, quiet=True)
    out = [{"id": i.id, "path": i.path} for i in itens]
    (C.CLIMA / "_listagem_drive.json").write_text(json.dumps(out, indent=1), encoding="utf-8")
    for i in out:
        log.info("Drive: %s", i["path"])
    return out


def selecionar(itens, log):
    sel = [i | {"nome": Path(i["path"]).name, "vars": C.BRDWGD_ZIPS[Path(i["path"]).name]}
           for i in itens if Path(i["path"]).name in C.BRDWGD_ZIPS]
    faltam = set(C.BRDWGD_ZIPS) - {s["nome"] for s in sel}
    if faltam:
        raise SystemExit(f"Zips esperados ausentes no Drive: {sorted(faltam)}")
    return sel


def baixar(sel, log):
    import gdown
    import zipfile
    NC_DIR.mkdir(parents=True, exist_ok=True)
    ZIP_DIR.mkdir(parents=True, exist_ok=True)
    for i in sel:
        destino = ZIP_DIR / i["nome"]
        if destino.exists() and destino.stat().st_size > 0:
            log.info("já existe: %s", destino.name)
        else:
            log.info("baixando %s", i["nome"])
            gdown.download(id=i["id"], output=str(destino), quiet=False)
        md5_zip = U.md5(destino)
        log.info("%s | %d bytes | md5 %s", destino.name, destino.stat().st_size, md5_zip)
        U.registrar_integridade([{
            "sistema": "BR-DWGD-zip", "ano": "1961-2025", "uf": "BR", "arquivo": destino.name,
            "status": C.BRDWGD_VERSAO, "url": f"https://drive.google.com/file/d/{i['id']}",
            "bytes": destino.stat().st_size, "md5_origem": md5_zip,
            "observacao": f"zip oficial da pasta {C.BRDWGD_DRIVE}; extrai {i['vars']}",
        }])
        with zipfile.ZipFile(destino) as z:
            for info in z.infolist():
                nome = Path(info.filename).name
                if "_Control" in nome or not nome.endswith(".nc"):
                    continue
                if not any(nome.startswith(v + "_") for v in i["vars"]):
                    continue
                if cobre_periodo(nome) is not True:
                    continue
                alvo = NC_DIR / nome
                if alvo.exists() and alvo.stat().st_size == info.file_size:
                    log.info("já extraído (tamanho confere com o zip): %s", nome)
                    continue
                if alvo.exists():
                    log.warning("tamanho difere do zip (%d vs %d), extraindo de novo: %s",
                                alvo.stat().st_size, info.file_size, nome)
                parcial = alvo.with_name(alvo.name + ".part")
                with z.open(info) as src, open(parcial, "wb") as dst:
                    shutil.copyfileobj(src, dst)
                parcial.replace(alvo)
                log.info("extraído: %s", nome)


def auditar(log) -> list[str]:
    """Audita os NetCDF; devolve a lista de erros (vazia se tudo OK)."""
    import numpy as np
    import pandas as pd
    import xarray as xr

    erros: list[str] = []
    linhas = []
    grades = {}
    md5_zip = {}
    for nc in ncs():
        ds = xr.open_dataset(nc)
        var = next((v for v in ds.data_vars if v in C.BRDWGD_VARS), list(ds.data_vars)[0])
        t = pd.to_datetime(ds["time"].values)
        lat = next(d for d in ds.dims if d.lower().startswith("lat"))
        lon = next(d for d in ds.dims if d.lower().startswith("lon"))
        dlat = float(np.abs(np.diff(ds[lat].values)).mean())
        dlon = float(np.abs(np.diff(ds[lon].values)).mean())
        grades[var] = (ds[lat].values.copy(), ds[lon].values.copy())
        amostra = ds[var].isel(time=slice(0, None, max(1, len(t) // 20))).values
        no_periodo = t[(t >= C.CLIMA_INI) & (t <= C.CLIMA_FIM)]
        datas_nan = list(no_periodo[:: max(1, len(no_periodo) // 15)])
        frac_nan = [float(ds[var].sel(time=d).isnull().mean()) for d in datas_nan]
        n_dup = int(t.duplicated().sum())
        info = {
            "arquivo": nc.name, "variavel": var, "t_ini": str(t.min())[:10], "t_fim": str(t.max())[:10],
            "n_dias": int(len(t)), "dias_esperados": int((t.max() - t.min()) / pd.Timedelta(days=1)) + 1,
            "n_datas_duplicadas": n_dup,
            "res_lat": round(dlat, 4), "res_lon": round(dlon, 4),
            "min_amostra": float(np.nanmin(amostra)), "max_amostra": float(np.nanmax(amostra)),
            "frac_nan_min": round(min(frac_nan), 4), "frac_nan_max": round(max(frac_nan), 4),
            "units": str(ds[var].attrs.get("units")),
            "attrs_globais": {k: str(v)[:120] for k, v in ds.attrs.items()},
        }
        ds.close()
        if n_dup:
            erros.append(f"{nc.name}: {n_dup} datas duplicadas")
        if info["frac_nan_max"] - info["frac_nan_min"] > 0.001:
            erros.append(f"{nc.name}: fração de NaN varia entre datas "
                         f"({info['frac_nan_min']}–{info['frac_nan_max']})")
        zip_origem = zip_de(var)
        if zip_origem is not None and zip_origem.name not in md5_zip:
            md5_zip[zip_origem.name] = U.md5(zip_origem)
        info["md5"] = U.md5(nc)
        info["bytes"] = nc.stat().st_size
        info["zip_origem"] = zip_origem.name if zip_origem else None
        gap = info["dias_esperados"] - info["n_dias"]
        log.info("%s | %s | %s→%s | %d dias (faltam %d; dup %d) | %.2f° | [%.1f, %.1f] | NaN %.4f–%.4f",
                 nc.name, var, info["t_ini"], info["t_fim"], info["n_dias"], gap, n_dup,
                 dlat, info["min_amostra"], info["max_amostra"], info["frac_nan_min"], info["frac_nan_max"])
        linhas.append(info)
        # md5_origem = md5 do zip oficial de onde o .nc saiu; md5_parquet = md5 do .nc extraído
        U.registrar_integridade([{
            "sistema": "BR-DWGD", "ano": f"{info['t_ini'][:4]}-{info['t_fim'][:4]}", "uf": "BR",
            "arquivo": nc.name, "status": C.BRDWGD_VERSAO, "url": C.BRDWGD_DRIVE,
            "bytes": info["bytes"], "md5_origem": md5_zip.get(info["zip_origem"], ""),
            "md5_parquet": info["md5"], "n_linhas": info["n_dias"], "n_colunas": 1,
            "observacao": (f"var={var}; faltam {gap} dias; dup {n_dup}; res={dlat:.2f}°; "
                           f"zip={info['zip_origem']}; md5_parquet = md5 do .nc"),
        }])
    (C.CLIMA / "_auditoria_netcdf.json").write_text(json.dumps(linhas, indent=1), encoding="utf-8")

    # mesma grade em todas as variáveis
    ref = next(iter(grades.values()), None)
    for v, (la, lo) in grades.items():
        if not (la.shape == ref[0].shape and lo.shape == ref[1].shape
                and np.allclose(la, ref[0]) and np.allclose(lo, ref[1])):
            erros.append(f"grade de {v} difere das demais")
    log.info("Grade igual nas %d variáveis: %s", len(grades),
             "OK" if not any("grade" in e for e in erros) else "NÃO")

    # cobertura contínua por variável: união dos dias de todos os arquivos
    # (detecta buracos ENTRE arquivos, não só nas pontas)
    esperado = pd.date_range(C.CLIMA_INI, C.CLIMA_FIM, freq="D")
    for v in C.BRDWGD_VARS:
        arqs = [a for a in ncs(f"{v}_*.nc") if "_Control" not in a.name]
        if not arqs:
            erros.append(f"Variável {v}: NENHUM arquivo")
            log.error("Variável %s: NENHUM arquivo", v)
            continue
        dias = set()
        for nc in arqs:
            with xr.open_dataset(nc) as ds:
                dias |= set(pd.to_datetime(ds["time"].values).normalize())
        faltam = esperado.difference(pd.DatetimeIndex(sorted(dias)))
        if len(faltam):
            erros.append(f"Cobertura {v}: faltam {len(faltam)} dias")
        log.info("Cobertura %s %s→%s: %s", v, C.CLIMA_INI, C.CLIMA_FIM,
                 "OK" if len(faltam) == 0 else f"FALTAM {len(faltam)} dias (ex.: {list(faltam[:5].date)})")
    return erros


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--listar", action="store_true")
    p.add_argument("--auditar", action="store_true")
    a = p.parse_args()
    log = U.get_logger("03_download_clima")
    try:
        if not a.auditar:
            itens = listar(log)
            if a.listar:
                return
            sel = selecionar(itens, log)
            log.info("Selecionados %d arquivos", len(sel))
            baixar(sel, log)
        erros = auditar(log)
    except Exception:
        log.exception("Falha no 03_download_clima")
        sys.exit(1)
    if erros:
        for e in erros:
            log.error("AUDITORIA: %s", e)
        sys.exit(1)
    log.info("AUDITORIA: OK")


if __name__ == "__main__":
    main()
