"""05 — Malha municipal e de UFs do IBGE, 2024 (SIRGAS 2000).

Uso:
    uv run 05_shapefiles.py
Saídas:
    05_shapefiles/originais/BR_Municipios_2024.zip, BR_UF_2024.zip
    05_shapefiles/BR_Municipios_2024/ (shp descompactado)
    05_shapefiles/municipios_2024.gpkg  (cópia GeoPackage, CD_MUN + CD_MUN6)
"""
import zipfile

import config as C
import utils as U

ORIG = C.SHP / "originais"
NAO_MUNICIPIOS = {"4300001", "4300002"}


def main():
    import geopandas as gpd

    log = U.get_logger("05_shapefiles")
    ORIG.mkdir(parents=True, exist_ok=True)
    for arq in C.IBGE_MALHA_ARQUIVOS:
        z = ORIG / arq
        url = f"{C.IBGE_MALHA_DIR}/{arq}"
        if not z.exists():
            try:
                if not U.baixar(url, z, log, timeout=600):
                    log.error("não achei %s", url)
                    continue
            except RuntimeError as e:
                log.error("falha ao baixar %s: %s", url, e)
                continue
        pasta = C.SHP / z.stem
        with zipfile.ZipFile(z) as f:
            f.extractall(pasta)
        shp = next(p for p in pasta.rglob("*.shp") if not p.name.startswith("._"))
        g = gpd.read_file(shp)
        log.info("%s: %d feições | CRS %s | colunas %s", arq, len(g), g.crs, list(g.columns))
        obs = f"CRS={g.crs}"
        if "CD_MUN" in g.columns:
            g["CD_MUN6"] = g["CD_MUN"].astype(str).str[:6]
            # Lagoa dos Patos e Lagoa Mirim (RS) são "Áreas Operacionais" com código próprio,
            # 4300002 e 4300001 (conferidos na malha 2024). Exclusão SÓ pelo código: o nome
            # "Lagoa dos Patos" também é de um município de MG (3137304).
            nao_mun = (g["CD_MUN"].astype(str).isin(NAO_MUNICIPIOS)
                       | ~g["CD_MUN"].astype(str).str.match(r"^\d{7}$"))
            if set(g.loc[nao_mun, "CD_MUN"].astype(str)) != NAO_MUNICIPIOS:
                log.error("Feições excluídas diferentes do esperado: %s",
                          g.loc[nao_mun, ["CD_MUN", "NM_MUN"]].values.tolist())
                raise SystemExit(1)
            obs += f"; feições não-municipais excluídas={int(nao_mun.sum())} {g.loc[nao_mun, 'CD_MUN'].tolist()}"
            log.info("Municípios válidos: %d", int((~nao_mun).sum()))
            g[~nao_mun].to_file(C.SHP / "municipios_2024.gpkg", driver="GPKG")
        U.registrar_integridade([{
            "sistema": "IBGE-malha", "ano": 2024, "uf": "BR", "arquivo": arq, "status": "oficial",
            "url": url, "bytes": z.stat().st_size, "md5_origem": U.md5(z), "n_linhas": len(g),
            "n_municipios": g["CD_MUN"].nunique() if "CD_MUN" in g else "", "observacao": obs,
        }])


if __name__ == "__main__":
    main()
