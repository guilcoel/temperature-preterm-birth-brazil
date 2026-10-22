"""04 — Recortes de análise: grandes concentrações urbanas do IBGE (unidade principal)
e, só como documentação, a composição legal das Regiões Metropolitanas.

Unidade de análise (decisão de 02/10/2026; ver logs/desvios_especificacao.md): as 26
"grandes concentrações urbanas" do IBGE, *Arranjos Populacionais e Concentrações
Urbanas do Brasil*, 2ª ed. (2016) — arranjos populacionais e municípios isolados com
mais de 750 mil habitantes no Censo 2010. A composição vem da base oficial (Access
.mdb), campo CodGrandeConcUrb_ConsidAnalise da tabela ComposicaoRecortes_01_PorMunicipio,
e é conferida contra a tabela ConcentracoesUrbanas_ConsideradasAnalise_01.

Cidade-núcleo (E15; decisão de 03/10/2026, que revoga o desvio de 02/10): o município de
maior população no Censo 2022. A sede do IBGE (o próprio código da concentração, que
representa o arranjo) fica só como referência, com flag quando difere (só Vitória/ES:
núcleo = Serra, sede = Vitória).

Também: população do Censo 2022 por município (SIDRA 4709, variável 93) e a checagem
do E17 — municípios da malha 2024 que não existiam na base de 2010 e se o polígono de
cada um encosta em alguma concentração (só assim poderia ter saído de um município dela).

Uso (depois do 05_shapefiles.py, que gera a malha 2024):
    uv run 04_regioes_metropolitanas.py
Saídas (04_regioes_metropolitanas/):
    originais/arranjos_populacionais_2ed/*          base oficial do IBGE
    originais/censo2022_pop_sidra4709_{N6,N1}.json  resposta da API de agregados do IBGE
    populacao_censo2022.csv
    concentracoes_urbanas_municipios.csv            1 linha por município das 26 concentrações
    cidade_nucleo.csv                               1 linha por concentração
    municipios_novos_origem.csv                     E17
    rm_municipios_{2024,2025}.csv, rm_resumo_{ano}.csv   RMs legais, só documentação
"""
from __future__ import annotations

import json
import re
import sys
import tempfile
import zipfile

import pandas as pd

import config as C
import utils as U

ORIG = C.RM / "originais"
ARRANJOS = ORIG / "arranjos_populacionais_2ed"
N_GRANDES = 26
TIPO_CONC = {
    "Arranjo populacional": "arranjo",
    "Primeira integração do arranjo": "arranjo_1a_integracao",
    "Segunda integração do arranjo": "arranjo_2a_integracao",
    "Município isolado": "municipio_isolado",
}

# ----------------------------------------------------------------------------
# RMs legais (só documentação): colunas reais dos xlsx do IBGE, conferidas em
# 02/10/2026. A unidade de análise NÃO é mais a RM.
# ----------------------------------------------------------------------------
COLUNAS = {
    "metropolitano": {
        "COD_MUN": "CD_MUN", "NOME_MUN": "NM_MUN", "SIGLA_UF": "SIGLA_UF",
        "COD_CATMETROPOL": "CD_RECORTE", "LABEL_CATMETROPOL": "NM_RECORTE",
        "NOME_CATMETROPOL": "NM_CATEGORIA", "COD_RECMETROPOL": "CD_RECORTE_IBGE",
        "NOME_SUBCATMETROPOL": "NM_SUBCATEGORIA", "LEG": "LEI", "DATA": "DATA_LEI",
    },
    "aglomeracao": {
        "COD_MUN": "CD_MUN", "NOME_MUN": "NM_MUN", "SIGLA_UF": "SIGLA_UF",
        "COD_CATAU": "CD_RECORTE", "LABEL_CATAU": "NM_RECORTE",
        "NOME_CATAU": "NM_CATEGORIA", "COD_RECAU": "CD_RECORTE_IBGE",
        "NOME_SUBCATAU": "NM_SUBCATEGORIA", "LEG": "LEI", "DATA": "DATA_LEI",
    },
}
TIPOS = [
    ("Região Metropolitana", "RM"),
    ("Região Integrada de Desenvolvimento", "RIDE"),
    ("Região Administrativa Integrada de Desenvolvimento", "RIDE"),  # Petrolina/Juazeiro
    ("Colar Metropolitano", "COLAR"),
    ("Área de Expansão Metropolitana", "EXPANSAO"),
    ("Entorno Metropolitano", "ENTORNO"),
    ("Aglomeração Urbana", "AU"),
]


def para(log, msg, *args):
    log.error(msg, *args)
    sys.exit(1)


def baixar_lista(base: str, arquivos: list[str], destino, sistema: str, log, ano_padrao: str = "") -> None:
    destino.mkdir(parents=True, exist_ok=True)
    for arq in arquivos:
        alvo = destino / arq
        if not alvo.exists():
            try:
                U.baixar(f"{base}/{arq}", alvo, log, timeout=600) or log.error("não achei %s", arq)
            except RuntimeError as e:
                log.error("falha ao baixar %s: %s", arq, e)
        if alvo.exists():
            ano = re.search(r"20\d\d", arq)
            U.registrar_integridade([{
                "sistema": sistema, "ano": ano.group() if ano else ano_padrao, "uf": "BR", "arquivo": arq,
                "status": "oficial", "url": f"{base}/{arq}", "bytes": alvo.stat().st_size,
                "md5_origem": U.md5(alvo),
            }])


# ----------------------------------------------------------------------------
# Censo 2022
# ----------------------------------------------------------------------------
def populacao_censo2022(log) -> pd.DataFrame:
    respostas = {}
    for nivel in ("N6", "N1"):
        alvo = ORIG / f"censo2022_pop_sidra4709_{nivel}.json"
        url = C.SIDRA_POP2022.format(nivel=nivel)
        if not alvo.exists():
            U.baixar(url, alvo, log, timeout=300) or para(log, "SIDRA não respondeu: %s", url)
        respostas[nivel] = json.loads(alvo.read_text(encoding="utf-8"))
        n_loc = len(respostas[nivel][0]["resultados"][0]["series"])
        U.registrar_integridade([{
            "sistema": "IBGE-Censo2022", "ano": 2022, "uf": "BR", "arquivo": alvo.name, "status": "oficial",
            "url": url, "bytes": alvo.stat().st_size, "md5_origem": U.md5(alvo), "n_linhas": n_loc,
            "observacao": f"SIDRA 4709 var. 93, nível {nivel}: {n_loc} localidade(s)",
        }])
    serie = respostas["N6"][0]["resultados"][0]["series"]
    df = pd.DataFrame([{"CD_MUN": s["localidade"]["id"], "NM_MUN_UF": s["localidade"]["nome"],
                        "POP_CENSO2022": s["serie"].get("2022")} for s in serie])
    if not df["POP_CENSO2022"].str.fullmatch(r"\d+").all():
        para(log, "população com valor não numérico no SIDRA 4709")
    df["POP_CENSO2022"] = df["POP_CENSO2022"].astype(int)
    df["CD_MUN6"] = df["CD_MUN"].str[:6]
    total = int(respostas["N1"][0]["resultados"][0]["series"][0]["serie"]["2022"])
    if len(df) != 5570 or not df["CD_MUN"].is_unique or df["POP_CENSO2022"].sum() != total:
        para(log, "Censo 2022: %d municípios, soma %d contra Brasil %d", len(df), df["POP_CENSO2022"].sum(), total)
    saida = C.RM / "populacao_censo2022.csv"
    df[["CD_MUN", "CD_MUN6", "NM_MUN_UF", "POP_CENSO2022"]].to_csv(saida, index=False)
    log.info("Censo 2022: %d municípios, soma = total do Brasil (%s)", len(df), f"{total:,}")
    U.registrar_integridade([{
        "sistema": "IBGE-Censo2022-tidy", "ano": 2022, "uf": "BR", "arquivo": saida.name, "status": "derivado",
        "n_linhas": len(df), "n_municipios": len(df), "md5_parquet": U.md5(saida),
        "observacao": f"SIDRA 4709 var. 93; soma N6 = N1 = {total}",
    }])
    return df


# ----------------------------------------------------------------------------
# Grandes concentrações urbanas (IBGE, Arranjos Populacionais 2ª ed.)
# ----------------------------------------------------------------------------
def ler_mdb(log) -> tuple[pd.DataFrame, pd.DataFrame]:
    from access_parser import AccessParser
    z = ARRANJOS / C.IBGE_ARRANJOS_ARQUIVOS[0]
    with tempfile.TemporaryDirectory(prefix="arranjos_") as tmp, zipfile.ZipFile(z) as f:
        nomes = [n for n in f.namelist() if n.lower().endswith(".mdb")]
        if len(nomes) != 1:
            para(log, "zip dos arranjos com %d .mdb (esperado 1): %s", len(nomes), f.namelist())
        mdb = f.extract(nomes[0], tmp)
        db = AccessParser(mdb)
        comp = pd.DataFrame(db.parse_table("ComposicaoRecortes_01_PorMunicipio"))
        conc = pd.DataFrame(db.parse_table("ConcentracoesUrbanas_ConsideradasAnalise_01"))
    return comp.drop(columns=["Shape"], errors="ignore"), conc.drop(columns=["Shape"], errors="ignore")


def texto_codigo(s: pd.Series) -> pd.Series:
    return s.astype(str).str.strip().str.replace(r"\.0$", "", regex=True)


def montar_concentracoes(comp: pd.DataFrame, conc: pd.DataFrame, malha: pd.DataFrame,
                         pop: pd.DataFrame, log) -> pd.DataFrame:
    comp = comp.assign(CD_MUN=texto_codigo(comp["CodMunT"]),
                       CD_RECORTE=texto_codigo(comp["CodGrandeConcUrb_ConsidAnalise"]))
    g = comp[comp["CD_RECORTE"].str.fullmatch(r"\d{7}")].copy()
    g["TIPO_RECORTE"] = g["TipoGrandeConcUrb_ConsidAnalise"].str.split(" - ").str[-1].map(TIPO_CONC)
    if g["TIPO_RECORTE"].isna().any():
        para(log, "tipo de concentração não reconhecido: %s",
             g.loc[g["TIPO_RECORTE"].isna(), "TipoGrandeConcUrb_ConsidAnalise"].unique().tolist())
    if g["CD_RECORTE"].nunique() != N_GRANDES or not g["CD_MUN"].is_unique:
        para(log, "esperadas %d concentrações e município único; achei %d concentrações e %d repetidos",
             N_GRANDES, g["CD_RECORTE"].nunique(), int(g["CD_MUN"].duplicated().sum()))
    # conferência contra a tabela das concentrações (nº de municípios e população 2010)
    c = conc.assign(CD_RECORTE=texto_codigo(conc["CodConcUrb_ConsidAnalise"]))
    c = c[c["TipoConcUrb_ConsidAnalise"].str.startswith("Grande")]
    ref = c.set_index("CD_RECORTE")[["NumeroDeMunicipios", "PopTot2010_Brasil"]].astype(float)
    obs = g.groupby("CD_RECORTE").agg(n=("CD_MUN", "size"), pop=("PopTot2010", "sum")).astype(float)
    dif = obs.join(ref, how="outer")
    dif = dif[(dif["n"] != dif["NumeroDeMunicipios"]) | ((dif["pop"] - dif["PopTot2010_Brasil"]).abs() > 0.5)]
    if len(dif):
        para(log, "composição não bate com a tabela das concentrações: %s", dif.to_dict("index"))
    fora = sorted(set(g["CD_MUN"]) - set(malha["CD_MUN"]))
    if fora:
        para(log, "municípios das concentrações fora da malha 2024: %s", fora)
    g = (g.merge(malha[["CD_MUN", "NM_MUN", "SIGLA_UF"]], on="CD_MUN", how="left")
          .merge(pop[["CD_MUN", "POP_CENSO2022"]], on="CD_MUN", how="left"))
    g = g.rename(columns={"NomeGrandeConcUrb_ConsidAnalise": "NM_RECORTE", "PopTot2010": "POP_CENSO2010"})
    # chave única nos dois sentidos (auditoria A3: nas RMs o código colidia entre AU e RM)
    par = g[["CD_RECORTE", "NM_RECORTE"]].drop_duplicates()
    if not (par["CD_RECORTE"].is_unique and par["NM_RECORTE"].is_unique):
        para(log, "CD_RECORTE e NM_RECORTE não são 1:1: %s", par[par.duplicated("CD_RECORTE", keep=False)
                                                                 | par.duplicated("NM_RECORTE", keep=False)].values.tolist())
    if g["POP_CENSO2022"].isna().any():
        para(log, "município das concentrações sem população do Censo 2022: %s",
             g.loc[g["POP_CENSO2022"].isna(), "CD_MUN"].tolist())
    g["CD_MUN6"] = g["CD_MUN"].str[:6]
    g["POP_CENSO2010"] = g["POP_CENSO2010"].astype(float).round().astype(int)
    return g[["CD_RECORTE", "NM_RECORTE", "TIPO_RECORTE", "CD_MUN", "CD_MUN6", "NM_MUN", "SIGLA_UF",
              "POP_CENSO2010", "POP_CENSO2022"]].sort_values(["CD_RECORTE", "CD_MUN"])


def cidade_nucleo(g: pd.DataFrame, log) -> pd.DataFrame:
    linhas = []
    for cd, sub in g.groupby("CD_RECORTE"):
        sede = sub[sub["CD_MUN"] == cd]
        if len(sede) != 1:
            para(log, "sede %s não está entre os municípios da própria concentração", cd)
        topo = sub["POP_CENSO2022"].max()
        if (sub["POP_CENSO2022"] == topo).sum() != 1:
            para(log, "empate no maior município de 2022 em %s; regra do E15 indefinida", cd)
        nuc = sub.loc[sub["POP_CENSO2022"].idxmax()]
        linhas.append({
            "CD_RECORTE": cd, "NM_RECORTE": sub["NM_RECORTE"].iloc[0], "TIPO_RECORTE": sub["TIPO_RECORTE"].iloc[0],
            "N_MUNICIPIOS": len(sub), "POP_CENSO2010_RECORTE": int(sub["POP_CENSO2010"].sum()),
            "POP_CENSO2022_RECORTE": int(sub["POP_CENSO2022"].sum()),
            "CD_MUN_NUCLEO": nuc["CD_MUN"], "NM_MUN_NUCLEO": nuc["NM_MUN"],
            "POP_CENSO2022_NUCLEO": int(nuc["POP_CENSO2022"]),
            "CD_MUN_SEDE_IBGE": cd, "NM_MUN_SEDE_IBGE": sede["NM_MUN"].iloc[0],
            "POP_CENSO2022_SEDE": int(sede["POP_CENSO2022"].iloc[0]),
            "NUCLEO_DIFERE_SEDE": int(nuc["CD_MUN"] != cd),
        })
    df = pd.DataFrame(linhas).sort_values("POP_CENSO2022_RECORTE", ascending=False)
    for r in df[df["NUCLEO_DIFERE_SEDE"] == 1].itertuples():
        log.warning("%s: cidade-núcleo (E15, maior em 2022) = %s (%s hab.); sede do IBGE = %s (%s hab.)",
                    r.NM_RECORTE, r.NM_MUN_NUCLEO, f"{r.POP_CENSO2022_NUCLEO:,}",
                    r.NM_MUN_SEDE_IBGE, f"{r.POP_CENSO2022_SEDE:,}")
    return df


def checar_e17(comp: pd.DataFrame, g: pd.DataFrame, malha_geo, log) -> pd.DataFrame:
    """Municípios da malha 2024 ausentes da base de 2010 e se encostam em alguma concentração."""
    import geopandas as gpd
    antigos = set(texto_codigo(comp["CodMunT"]))
    novos = malha_geo[~malha_geo["CD_MUN"].isin(antigos)][["CD_MUN", "NM_MUN", "SIGLA_UF", "geometry"]]
    conc = malha_geo.merge(g[["CD_MUN", "NM_RECORTE"]], on="CD_MUN")[["NM_RECORTE", "geometry"]]
    toque = gpd.sjoin(novos, conc, how="left", predicate="intersects")
    out = (toque.groupby(["CD_MUN", "NM_MUN", "SIGLA_UF"], dropna=False)["NM_RECORTE"]
           .agg(lambda s: "; ".join(sorted(set(s.dropna())))).reset_index()
           .rename(columns={"NM_RECORTE": "CONCENTRACOES_VIZINHAS"}))
    out["ENCOSTA_EM_CONCENTRACAO"] = (out["CONCENTRACOES_VIZINHAS"] != "").astype(int)
    out["CD_MUN_ORIGEM"] = "não verificado"
    out["ANO_INSTALACAO"] = "não verificado"
    out["FONTE"] = "malha IBGE 2024 x base Arranjos Populacionais 2ª ed. (municípios de 2010)"
    if out["ENCOSTA_EM_CONCENTRACAO"].any():
        log.warning("E17: municípios novos que encostam em concentração (origem a levantar em fonte oficial; "
                    "NÃO decidir): %s", out.loc[out["ENCOSTA_EM_CONCENTRACAO"] == 1, "NM_MUN"].tolist())
    log.info("E17: %d municípios da malha 2024 não existiam em 2010; %d encostam em alguma concentração",
             len(out), int(out["ENCOSTA_EM_CONCENTRACAO"].sum()))
    return out


# ----------------------------------------------------------------------------
# RMs legais (só documentação)
# ----------------------------------------------------------------------------
def tipo_recorte(nome: str) -> str:
    n = " ".join(str(nome).split())  # o xlsx de 2025 traz nome com espaço no início
    for prefixo, tipo in TIPOS:
        if n.startswith(prefixo):
            return tipo
    raise ValueError(f"Categoria do IBGE não reconhecida: {nome!r}. Ajuste TIPOS.")


def ler_composicao_rm(xlsx, log) -> pd.DataFrame:
    partes = []
    for nome, df in pd.read_excel(xlsx, sheet_name=None, dtype=str).items():
        log.info("Aba '%s': %d linhas | colunas: %s", nome, len(df), list(df.columns))
        aba = next((k for k, m in COLUNAS.items() if set(m) <= set(df.columns)), None)
        if aba is None:
            para(log, "Aba '%s' sem as colunas esperadas. Ajuste COLUNAS.", nome)
        d = df[list(COLUNAS[aba])].rename(columns=COLUNAS[aba])
        # COD_CATAU repete COD_CATMETROPOL (00301, 00401, 00501): prefixo da aba torna a chave única
        d["CD_RECORTE"] = ("AU_" if aba == "aglomeracao" else "RM_") + d["CD_RECORTE"]
        partes.append(d)
    df = pd.concat(partes, ignore_index=True)
    par = df[["CD_RECORTE", "NM_RECORTE"]].drop_duplicates()
    if not par["CD_RECORTE"].is_unique:
        para(log, "CD_RECORTE com mais de um nome: %s",
             par[par.duplicated("CD_RECORTE", keep=False)].values.tolist())
    if not df["CD_MUN"].str.fullmatch(r"\d{7}").all():
        para(log, "Há código de município fora do padrão de 7 dígitos.")
    df["TIPO_RECORTE"] = df["NM_CATEGORIA"].map(tipo_recorte)
    df["NM_CATEGORIA"] = df["NM_CATEGORIA"].str.split().str.join(" ")
    # São Paulo aparece uma vez por sub-região da RMSP: 1 linha por município x recorte
    outras = [c for c in df.columns if c not in ("CD_MUN", "CD_RECORTE", "NM_SUBCATEGORIA")]
    df = df.groupby(["CD_MUN", "CD_RECORTE"], as_index=False, sort=False).agg(
        {**{c: "first" for c in outras},
         "NM_SUBCATEGORIA": lambda s: "; ".join(sorted(set(s.dropna())))})
    df["CD_MUN6"] = df["CD_MUN"].str[:6]
    return df


def rms_legais(log) -> None:
    baixar_lista(C.IBGE_RM_DIR, C.IBGE_RM_ARQUIVOS, ORIG, "IBGE-RM", log)
    for ano in (2024, 2025):
        xlsx = ORIG / f"Composicao_RM_{ano}.xlsx"
        if not xlsx.exists():
            continue
        df = ler_composicao_rm(xlsx, log)
        df.to_csv(C.RM / f"rm_municipios_{ano}.csv", index=False)
        res = df.groupby(["CD_RECORTE", "NM_RECORTE", "TIPO_RECORTE"]).agg(
            n_municipios=("CD_MUN", "nunique"),
            ufs=("SIGLA_UF", lambda s: ",".join(sorted(set(s.dropna()))))).reset_index()
        res.to_csv(C.RM / f"rm_resumo_{ano}.csv", index=False)
        # municípios em mais de um recorte legal (como o 04 anterior registrava; auditoria R9)
        multi = (df.groupby("CD_MUN")["TIPO_RECORTE"].agg(lambda s: "+".join(sorted(s)))
                 .loc[lambda s: s.str.contains("+", regex=False)].value_counts().to_dict())
        log.info("RMs legais %d (documentação): %d recortes | %s | municípios em mais de um recorte: %s",
                 ano, len(res), res["TIPO_RECORTE"].value_counts().to_dict(), multi)
        U.registrar_integridade([{
            "sistema": "IBGE-RM-tidy", "ano": ano, "uf": "BR", "arquivo": f"rm_municipios_{ano}.csv",
            "status": "derivado", "n_linhas": len(df), "n_municipios": df["CD_MUN"].nunique(),
            "md5_parquet": U.md5(C.RM / f"rm_municipios_{ano}.csv"),
            "observacao": f"só documentação; {len(res)} recortes; CD_RECORTE com prefixo AU_/RM_; multi={multi}",
        }])


def main():
    import geopandas as gpd

    log = U.get_logger("04_regioes_metropolitanas")
    gpkg = C.SHP / "municipios_2024.gpkg"
    if not gpkg.exists():
        para(log, "Falta %s: rode antes o 05_shapefiles.py", gpkg)
    malha_geo = gpd.read_file(gpkg, columns=["CD_MUN", "NM_MUN", "SIGLA_UF"])
    malha = pd.DataFrame(malha_geo.drop(columns="geometry"))

    pop = populacao_censo2022(log)
    baixar_lista(C.IBGE_ARRANJOS_DIR, C.IBGE_ARRANJOS_ARQUIVOS, ARRANJOS, "IBGE-ARRANJOS", log, ano_padrao="2016")
    comp, conc = ler_mdb(log)
    g = montar_concentracoes(comp, conc, malha, pop, log)
    nuc = cidade_nucleo(g, log)
    e17 = checar_e17(comp, g, malha_geo, log)

    saidas = {"concentracoes_urbanas_municipios.csv": g, "cidade_nucleo.csv": nuc,
              "municipios_novos_origem.csv": e17}
    for nome, df in saidas.items():
        df.to_csv(C.RM / nome, index=False)
        U.registrar_integridade([{
            "sistema": "IBGE-concentracoes-tidy", "ano": 2010, "uf": "BR", "arquivo": nome, "status": "derivado",
            "n_linhas": len(df), "n_municipios": df["CD_MUN"].nunique() if "CD_MUN" in df else "",
            "md5_parquet": U.md5(C.RM / nome), "observacao": C.IBGE_ARRANJOS_EDICAO,
        }])
    log.info("Concentrações: %d | municípios: %d | pop 2010: %s | pop 2022: %s | tipos: %s",
             g["CD_RECORTE"].nunique(), len(g), f"{g['POP_CENSO2010'].sum():,}", f"{g['POP_CENSO2022'].sum():,}",
             nuc["TIPO_RECORTE"].value_counts().to_dict())
    U.registrar_proveniencia([C.RM / n for n in (*saidas, "populacao_censo2022.csv")],
                             ["integridade:IBGE-ARRANJOS", "integridade:IBGE-Censo2022", "05_shapefiles/municipios_2024.gpkg",
                              *U.codigo(__file__)], __file__)

    rms_legais(log)
    U.registrar_proveniencia([C.RM / f"{n}_{a}.csv" for n in ("rm_municipios", "rm_resumo") for a in (2024, 2025)],
                             ["integridade:IBGE-RM", *U.codigo(__file__)], __file__)


if __name__ == "__main__":
    main()
