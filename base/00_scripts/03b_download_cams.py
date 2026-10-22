"""03b — CAMS EAC4 (Copernicus/ECMWF): PM2.5 de superfície a cada 3 h, para o E16.

Reanálise global de composição atmosférica (EAC4), baixada direto da Atmosphere
Data Store (ADS) com o cdsapi. Uma requisição por ano: a fila da ADS pode expirar
numa requisição longa e não há retomada. Cada ano vira um NetCDF, conferido depois
de baixar. Período = o do clima (config.CLIMA_INI a CLIMA_FIM). Unidade nativa
kg m-3 (x 1e9 = µg m-3). A média diária e a extração por município ficam no 06a/06c.

Pré-requisitos (no navegador, feitos pelo Guilherme; não há API para isso):
  1. conta na ADS (https://ads.atmosphere.copernicus.eu) e um Personal Access Token;
  2. aceite dos Terms of Use na página do conjunto cams-global-reanalysis-eac4;
  3. ~/.cdsapirc com as linhas "url: https://ads.atmosphere.copernicus.eu/api"
     e "key: <token>". O script só confere a URL; nunca imprime a chave.

Adaptado de CliMaterna/A03_temperatura_prematuridade/05_scripts/06i_cams_download_v1_20260907.py.

Uso (dentro de 00_scripts):
    uv run 03b_download_cams.py --dry-run      # só mostra as requisições; não usa a rede
    uv run 03b_download_cams.py --anos 2010    # teste pequeno
    uv run 03b_download_cams.py                # 2010-01-01 a 2025-01-31 (pelo nohup)
    uv run 03b_download_cams.py --auditar      # só confere o que já está em 03_clima/cams_pm25
Saídas:
    03_clima/cams_pm25/eac4_pm25_AAAA.nc, 03_clima/cams_pm25/_manifesto_cams.json
    logs/integridade.csv (sistema CAMS-EAC4), logs/03b_download_cams_*.log
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
import zipfile
from pathlib import Path

import config as C
import utils as U

DEST = C.CLIMA / "cams_pm25"
HORAS = ["00:00", "03:00", "06:00", "09:00", "12:00", "15:00", "18:00", "21:00"]
URL_ADS = f"https://ads.atmosphere.copernicus.eu/datasets/{C.CAMS_DATASET}"
UNIDADE = "kg m**-3"   # atributo `units` do pm2p5 na ADS (conferido nos 16 arquivos, 02/10/2026)


def anos_periodo() -> list[int]:
    return list(range(int(C.CLIMA_INI[:4]), int(C.CLIMA_FIM[:4]) + 1))


def requisicao(ano: int) -> dict:
    ini = max(C.CLIMA_INI, f"{ano}-01-01")
    fim = min(C.CLIMA_FIM, f"{ano}-12-31")
    return {"variable": [C.CAMS_VAR], "date": f"{ini}/{fim}", "time": HORAS,
            "area": C.CAMS_AREA, "data_format": "netcdf"}


def checa_prerequisitos(log) -> None:
    rc = Path.home() / ".cdsapirc"
    if not rc.exists():
        log.error("PARE: ~/.cdsapirc não existe. Ver os pré-requisitos no cabeçalho do script.")
        sys.exit(1)
    if "ads.atmosphere.copernicus.eu" not in rc.read_text():
        log.error("PARE: ~/.cdsapirc não aponta para a ADS "
                  "(esperado 'url: https://ads.atmosphere.copernicus.eu/api').")
        sys.exit(1)
    log.info("~/.cdsapirc encontrado e aponta para a ADS")


def abrir(caminho: Path):
    import xarray as xr
    ds = xr.open_dataset(caminho, engine="netcdf4")   # explícito: o .part não tem extensão .nc
    tn = "valid_time" if "valid_time" in ds.coords else "time"   # a ADS nova usa valid_time
    return ds, tn


def verifica(caminho: Path, ano: int) -> tuple[bool, dict]:
    """Abre o arquivo e confere: 8 tempos por dia em todos os dias pedidos do ano, sem
    duplicata; unidade = UNIDADE; arquivo INTEIRO sem NaN e sem valor negativo (auditorias A8 e C7).
    Grava a impressão digital da grade (md5 de lat+lon) para o --auditar comparar os anos."""
    import numpy as np
    import pandas as pd
    try:
        ds, tn = abrir(caminho)
        with ds:
            var = list(ds.data_vars)[0]
            t = pd.to_datetime(ds[tn].values)
            ini, fim = requisicao(ano)["date"].split("/")
            dias = pd.date_range(ini, fim, freq="D")
            por_dia = pd.Series(1, index=t.normalize()).groupby(level=0).size()
            faltam = dias.difference(por_dia.index)
            incompletos = int((por_dia.reindex(dias).fillna(0) < len(HORAS)).sum())
            lat = next(c for c in ds.coords if c.lower().startswith("lat"))
            lon = next(c for c in ds.coords if c.lower().startswith("lon"))
            amostra = ds[var].values * 1e9   # arquivo inteiro, não amostra (auditoria C7); ~10 milhões de valores
            latv, lonv = ds[lat].values.astype("float64"), ds[lon].values.astype("float64")
            info = {"variavel": var, "unidade": ds[var].attrs.get("units", ""),
                    "t_ini": str(t.min())[:16], "t_fim": str(t.max())[:16], "n_tempos": int(len(t)),
                    "dias_faltando": int(len(faltam)), "dias_incompletos": incompletos,
                    "duplicados": int(t.duplicated().sum()),
                    "n_lat": int(ds.sizes[lat]), "n_lon": int(ds.sizes[lon]),
                    "res_lat": round(float(np.abs(np.diff(ds[lat].values)).mean()), 4),
                    "res_lon": round(float(np.abs(np.diff(ds[lon].values)).mean()), 4),
                    "lat_min": float(latv.min()), "lat_max": float(latv.max()),
                    "lon_min": float(lonv.min()), "lon_max": float(lonv.max()),
                    "grade_md5": hashlib.md5(latv.tobytes() + lonv.tobytes()).hexdigest(),
                    "min_ugm3": round(float(np.nanmin(amostra)), 4),
                    "max_ugm3": round(float(np.nanmax(amostra)), 2),
                    "pct_nan": round(100 * float(np.isnan(amostra).mean()), 4),
                    "pct_zero": round(100 * float((amostra == 0).mean()), 4)}
            negativo = bool(np.nanmin(amostra) < 0)   # mínimo bruto, antes de arredondar (auditoria R5)
        # incompleto = problema de transferência: baixar de novo resolve
        info["incompleto"] = bool(info["dias_faltando"] or info["dias_incompletos"] or info["duplicados"])
        problemas = [p for p, ruim in [
            ("dia faltando", info["dias_faltando"] > 0), ("dia incompleto", info["dias_incompletos"] > 0),
            ("tempo duplicado", info["duplicados"] > 0), (f"unidade != {UNIDADE}", info["unidade"] != UNIDADE),
            ("NaN no arquivo", info["pct_nan"] > 0), ("valor negativo", negativo)] if ruim]
        info["problemas"] = "; ".join(problemas)
        return not problemas, info
    except Exception as e:  # noqa: BLE001
        # erro ao abrir NÃO dispara novo download: pode ser problema do ambiente (engine,
        # coordenada renomeada), e baixar de novo os 16 anos não resolveria (auditoria C6)
        return False, {"erro": str(e)[:300], "incompleto": False}


def baixar_ano(cliente, ano: int, log) -> Path | None:
    alvo = DEST / f"eac4_pm25_{ano}.nc"
    if alvo.exists():
        ok, info = verifica(alvo, ano)
        if ok:
            log.info("%d: já existe e confere (%d tempos) — pulando", ano, info["n_tempos"])
            return alvo
        if not info["incompleto"]:
            # completo, mas com problema de conteúdo (unidade, NaN, negativo): baixar de novo
            # traria o mesmo dado; não baixa e pede conferência (auditoria R4)
            log.error("%d: existe, mas NÃO confere (%s) — não baixo de novo; conferir à mão", ano,
                      info.get("problemas") or info.get("erro"))
            return None
        log.warning("%d: existe mas está incompleto (%s) — baixando de novo; o atual só é "
                    "substituído se o novo conferir", ano, info.get("problemas") or info.get("erro"))
    tmp = alvo.with_suffix(".part")
    log.info("%d: requisitando %s (a fila da ADS pode demorar)", ano, requisicao(ano)["date"])
    try:
        cliente.retrieve(C.CAMS_DATASET, requisicao(ano), str(tmp))
    except Exception as e:  # noqa: BLE001
        msg = str(e)
        if "licen" in msg.lower():
            log.error("PARE: erro de licença. Aceite os Terms of Use em %s e rode de novo.", URL_ADS)
            sys.exit(1)
        log.error("%d: FALHOU (%s) — siga para o próximo e rode de novo depois", ano, msg[:300])
        return None
    if zipfile.is_zipfile(tmp):  # a ADS pode devolver zip com um .nc dentro
        with zipfile.ZipFile(tmp) as z:
            nomes = [n for n in z.namelist() if n.endswith(".nc")]
            if len(nomes) != 1:
                log.error("%d: zip com %d .nc (esperado 1): %s", ano, len(nomes), z.namelist())
                return None
            with z.open(nomes[0]) as src, open(alvo.with_suffix(".nc.part"), "wb") as dst:
                dst.write(src.read())
        tmp.unlink()
        tmp = alvo.with_suffix(".nc.part")
    # verifica ANTES de substituir: um download ruim não apaga o arquivo atual (auditoria R4)
    ok, info = verifica(tmp, ano)
    log.info("%d: %s | %.3f GB | %s", ano, "OK" if ok else "NÃO CONFERE", tmp.stat().st_size / 1e9, info)
    if not ok:
        log.error("%d: download novo não confere; mantido em %s para inspeção, sem substituir %s",
                  ano, tmp.name, alvo.name)
        return None
    os.replace(tmp, alvo)
    if not alvo.exists() or alvo.stat().st_size == 0:   # Forja não-APFS: conferir a gravação
        log.error("%d: falha ao gravar %s", ano, alvo.name)
        return None
    return alvo


def auditar(log) -> bool:
    linhas, todos_ok = [], True
    for ano in anos_periodo():
        alvo = DEST / f"eac4_pm25_{ano}.nc"
        if not alvo.exists():
            log.error("%d: arquivo ausente", ano)
            todos_ok = False
            continue
        ok, info = verifica(alvo, ano)
        todos_ok &= ok
        info |= {"arquivo": alvo.name, "bytes": alvo.stat().st_size, "md5": U.md5(alvo), "confere": ok}
        linhas.append(info)
        log.info("%s | %s", alvo.name, info)
        U.registrar_integridade([{
            "sistema": "CAMS-EAC4", "ano": ano, "uf": "BR", "arquivo": alvo.name,
            "status": "EAC4" if ok else "NAO_CONFERE", "url": URL_ADS, "bytes": info["bytes"],
            "md5_origem": info["md5"], "n_linhas": info.get("n_tempos", ""), "n_colunas": 1,
            "observacao": (f"var={info.get('variavel')}; {info.get('t_ini')}→{info.get('t_fim')}; "
                           f"grade {info.get('n_lat')}x{info.get('n_lon')}; res={info.get('res_lat')}°; "
                           f"dias faltando={info.get('dias_faltando')}; incompletos={info.get('dias_incompletos')}; "
                           f"unidade={info.get('unidade')}; NaN={info.get('pct_nan')}%; "
                           f"arquivo inteiro {info.get('min_ugm3')}–{info.get('max_ugm3')} ug/m3; "
                           f"zeros exatos={info.get('pct_zero')}% (P-PM25-ZERO); "
                           f"problemas={info.get('problemas') or info.get('erro') or 'nenhum'}"),
        }])
    grades = {l.get("grade_md5") for l in linhas}
    if None in grades or len(grades) != 1:   # None = arquivo que nem abriu (auditoria R5)
        log.error("Grade lat/lon diferente entre os anos: %s",
                  {l["arquivo"]: l.get("grade_md5") for l in linhas})
        todos_ok = False
    else:
        l0 = linhas[0]
        log.info("Grade igual nos %d arquivos: lat %.2f a %.2f, lon %.2f a %.2f (md5 %s)", len(linhas),
                 l0["lat_min"], l0["lat_max"], l0["lon_min"], l0["lon_max"], l0["grade_md5"])
    import importlib.metadata as md
    try:
        versao = md.version("cdsapi")
    except md.PackageNotFoundError:
        versao = "não instalado"
    manifesto = {"gerado_em": U.agora(), "dataset": C.CAMS_DATASET, "url": URL_ADS, "licenca": "CC-BY (CAMS)",
                 "unidade_nativa": "kg m-3 (x 1e9 = ug m-3)", "cdsapi": versao,
                 "requisicoes": {a: requisicao(a) for a in anos_periodo()}, "arquivos": linhas}
    (DEST / "_manifesto_cams.json").write_text(json.dumps(manifesto, indent=1, ensure_ascii=False),
                                               encoding="utf-8")
    log.info("AUDITORIA: %s", "OK" if todos_ok else "FALHOU")
    return todos_ok


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--anos", type=int, nargs="*", default=None)
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--auditar", action="store_true")
    a = p.parse_args()
    log = U.get_logger("03b_download_cams")
    anos = a.anos or anos_periodo()
    if a.dry_run:
        for ano in anos:
            log.info("[dry-run] %s <- %s", f"eac4_pm25_{ano}.nc", json.dumps(requisicao(ano)))
        return
    DEST.mkdir(parents=True, exist_ok=True)
    if a.auditar:
        sys.exit(0 if auditar(log) else 1)
    try:
        checa_prerequisitos(log)
        import cdsapi
        cliente = cdsapi.Client()
        falhas = [ano for ano in anos if baixar_ano(cliente, ano, log) is None]
        if falhas:
            log.error("Anos com falha: %s — rode de novo", falhas)
            sys.exit(1)
        if a.anos is None and not auditar(log):
            sys.exit(1)
    except SystemExit:
        raise
    except Exception:  # noqa: BLE001
        log.exception("erro inesperado")
        sys.exit(1)


if __name__ == "__main__":
    main()
