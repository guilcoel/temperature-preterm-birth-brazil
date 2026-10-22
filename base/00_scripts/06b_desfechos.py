"""06b — Desfechos: bases individuais e série diária por município (prematuridade e óbito
perinatal; o PIG sai no 07 a partir da base de nascimentos).

Recorte: residência (CODMUNRES, 6 dígitos) num dos 277 municípios das 26 grandes
concentrações urbanas (04). A base guarda TODOS os registros desses municípios, com flags;
as escolhas de método viram colunas (princípio de 03/10/2026). Itens da especificação: E1–E6,
E9, E10, E12, E17, E18; decisões e desvios em logs/desvios_especificacao.md.

Definições (detalhe nos desvios e em 06_processados/FONTE.md):
- IG (E1): SEMAGESTAC em semanas completas; s = data do parto − (7 × IG + 3) = `dum_est`.
  SINASC: válida 22–44 (43–44 à parte; < 22 e >= 45 inválidas). SIM: 1–47, com 9 e 99 = ignorado.
- Gestação única (E2): GRAVIDEZ == "1".
- Prematuridade (E3): população = NV único com IG 22–42; desfecho = IG 22–36.
- Óbito fetal (E4): DOFET, TIPOBITO 1, critério hierárquico (1_semagestac >= 22; senão
  2_gestacao 2–6; senão 3_peso >= 500 g). Principal = único + 1_semagestac com IG 22–42.
  `obito_fetal_sem_ig` = único sem IG válida que entra por 2_gestacao ou 3_peso.
- Óbito neonatal precoce (E4): DO, TIPOBITO 2, IDADE 0xx (min), 1xx (h) ou 2xx <= 06 (dias).
  Principal = único + IG 22–42 + DTNASC presente; `_sem_ig` = único sem IG válida.
- Data-índice (E5): fetal = DTOBITO; neonatal = DTNASC do registro de óbito. As versões
  `_idx_obito` usam a DTOBITO com o mesmo conjunto de óbitos.
- Coorte fixa (E6): `coorte_fixa_22` = s em [2011-07-31; 2024-03-05]; `coorte_fixa_37` = s em
  [2011-04-17; 2024-03-05]. A série principal usa só a coorte fixa; a outra versão, não.
- 2011 (desvio de 05/10): colunas que dependem de IG = NA; só as `*_sens2011` (E18:
  GESTACAO 2–6 e 2–4) ficam preenchidas.
- Censura de dez/2024 (desvio de 05/10): nascidos em 25–31/12/2024 que morrem em jan/2025
  estão no DO 2025, não baixado; colunas neonatais indexadas no nascimento = NA a partir de 25/12
  (IDADE 206 de quem nasceu em 25/12 à noite pode cair em 01/01/2025; auditoria A5).
- IG pela DUM (decisões, seção 8; §3.5 da especificação v2.0.2; desvio de 08/10): `ig_dum_sem` =
  ⌊(DTNASC − DTULTMENST) / 7⌋, diferença em dias de calendário (data sem hora), int16. NA se a DUM
  falta, não é analisável (8 dígitos ddmmaaaa de uma data que existe), é posterior ao parto ou é
  anterior a parto − 350 dias (corte em dias, antes do ⌊·⌋). Nenhum outro filtro: a faixa 20–45 e a
  concordância com o SEMAGESTAC são regras de uso dos artigos. A DTULTMENST não vai para nenhum arquivo.

Uso:
    uv run 06b_desfechos.py                 # saídas em 06_processados/ e logs/
    uv run 06b_desfechos.py --rascunho      # saídas em _tmp/rascunho_06b/ (teste; dentro da Forja)
Saídas:
    nascimentos.parquet, obitos_perinatais.parquet           (individuais; microdado, ficam na Forja)
    serie_diaria_municipio.parquet                           (coorte fixa; *_sem_ig = NA)
    serie_diaria_municipio_sem_coorte_fixa.parquet
    logs: fluxograma_exclusoes.csv, validacao_e5_datas.csv, criterios_inclusao_recorte.csv,
          totais_anuais.csv, obitos_por_criterio.csv (só agregados; contagem < 10 = "<10")
"""
from __future__ import annotations

import argparse
import datetime as dt
import os

import config as C  # antes do polars: o spill em disco fica em config.TMP (R8)
import utils as U

import numpy as np
import pandas as pd
import polars as pl
import pyarrow.parquet as pq

COORTE_22 = (dt.date(2011, 7, 31), dt.date(2024, 3, 5))
COORTE_37 = (dt.date(2011, 4, 17), dt.date(2024, 3, 5))
ANO_SENS = 2011
PRINCIPAL = (2012, 2024)
CENSURA_INI = dt.date(2024, 12, 25)   # IDADE 206 de quem nasceu em 25/12 à noite cai em 2025 (A5)
DUM_MAX_DIAS = 350                    # DUM anterior a parto − 50 semanas = NA; corte em dias, antes do ⌊·⌋ (seção 8)
SERIE_INI, SERIE_FIM = dt.date(C.ANO_INI, 1, 1), dt.date(C.ANO_FIM, 12, 31)
N_ARQ = {"SINASC": 27 * len(C.ANOS), "SIM-DO": 27 * len(C.ANOS), "SIM-DOFET": len(C.ANOS)}
PASTA = {"SINASC": C.SINASC, "SIM-DO": C.SIM, "SIM-DOFET": C.SIM / "_dofet"}

# colunas da série diária: nomes exatos da especificação
COL_NV = ["nv_unicos", "nv_multiplos_ou_ign", "ptb", "ptb_extremo", "ptb_muito", "ptb_moderado_tardio", "nv_ig_43_44"]
COL_OB = ["obito_fetal_principal", "obito_fetal_sem_ig", "obito_neonatal_precoce", "obito_neonatal_precoce_sem_ig",
          "obito_perinatal", "obito_neonatal_precoce_idx_obito", "obito_perinatal_idx_obito", "obito_ate24h",
          "obito_perinatal_24h", "obito_perinatal_sem_anomalia"]
COL_SENS = ["ptb_gestacao_sens2011", "nv_gestacao_sens2011"]
# dependem do óbito neonatal indexado no nascimento (censura de dez/2024)
COL_CENSURA = ["obito_neonatal_precoce", "obito_neonatal_precoce_sem_ig", "obito_perinatal", "obito_ate24h",
               "obito_perinatal_24h", "obito_perinatal_sem_anomalia"]


def para(log, msg, *args):
    log.error(msg, *args)
    raise SystemExit(1)


def mascara(n) -> str:
    return "" if n is None or pd.isna(n) else ("<10" if 0 < n < 10 else str(int(n)))


# ---------------------------------------------------------------------------- leitura
def arquivos(sistema: str, ano: int) -> list:
    return sorted(p for p in (PASTA[sistema] / "parquet" / f"ano={ano}").glob("uf=*.parquet")
                  if not p.name.startswith("._"))


def conferir_entradas(log) -> None:
    """378 + 378 + 14 parquets e nenhuma FALHA/AUSENTE no registro (auditoria B15)."""
    for sist, n in N_ARQ.items():
        achados = sum(len(arquivos(sist, a)) for a in C.ANOS)
        if achados != n:
            para(log, "%s: %d parquets (esperado %d)", sist, achados, n)
    reg = pd.read_csv(C.INTEGRIDADE_CSV, dtype=str)
    reg = reg[reg["sistema"].isin(N_ARQ)].sort_values("data_hora").drop_duplicates(["sistema", "ano", "uf"], keep="last")
    ruins = reg[reg["status"].isin(["FALHA", "AUSENTE"])]
    if len(ruins):
        para(log, "integridade.csv com FALHA/AUSENTE: %s", ruins[["sistema", "ano", "uf", "status"]].values.tolist())
    log.info("Entradas: %s parquets; nenhuma FALHA/AUSENTE", N_ARQ)


def scan(sistema: str, ano: int, extras: list[str]) -> pl.LazyFrame:
    """Lê os parquets do ano com um id estável: ano * 1e9 + índice da UF * 1e7 + linha (B12)."""
    partes = []
    for p in arquivos(sistema, ano):
        if pq.ParquetFile(p).metadata.num_rows >= 10_000_000:   # o id reserva 10^7 linhas por arquivo (A13)
            raise ValueError(f"{p.name}: linhas demais para o esquema de id")
        uf = p.stem.split("=")[1]
        iuf = C.UFS.index(uf) + 1 if uf in C.UFS else 0
        lf = pl.scan_parquet(p).with_row_index("linha")
        nomes = lf.collect_schema().names()
        faltam = [c for c in extras if c not in nomes]
        lf = lf.with_columns([pl.lit(None, dtype=pl.Utf8).alias(c) for c in faltam])
        partes.append(lf.select(
            (pl.lit(ano, pl.Int64) * 1_000_000_000 + iuf * 10_000_000 + pl.col("linha").cast(pl.Int64)).alias("id"),
            *[pl.col(c).cast(pl.Utf8) for c in extras]))
    return pl.concat(partes, how="vertical")


def numero(col: str, lo: int, hi: int) -> pl.Expr:
    x = pl.col(col).str.strip_chars().cast(pl.Int32, strict=False)
    return pl.when(x.is_between(lo, hi)).then(x).otherwise(None)


def data_dmy(col: str) -> pl.Expr:
    return pl.col(col).str.strip_chars().str.zfill(8).str.strptime(pl.Date, "%d%m%Y", strict=False)


def em_coorte(s: pl.Expr, faixa) -> pl.Expr:
    return s.is_between(pl.lit(faixa[0]), pl.lit(faixa[1])).fill_null(False)


def data_dum(col: str) -> pl.Expr:
    """DTULTMENST como data sem hora. Analisável = exatamente 8 dígitos ddmmaaaa de uma data que existe; o resto
    (vazio, 7 dígitos, letras, 31/02, mês 13...) = NA. Sem o zfill do `data_dmy`: no dado, toda DUM preenchida
    tem 8 dígitos (perfil agregado de 08/10/2026), e 7 dígitos seria ambíguo."""
    s = pl.col(col).str.strip_chars()
    return pl.when(s.str.contains(r"^\d{8}$")).then(s.str.strptime(pl.Date, "%d%m%Y", strict=False))


def dias_dum(col_data: str, col_dum: str) -> pl.Expr:
    """Dias de calendário entre a DUM e o parto (`col_data` já é data)."""
    return (pl.col(col_data) - data_dum(col_dum)).dt.total_days()


def ig_pela_dum(col_data: str, col_dum: str) -> pl.Expr:
    """`ig_dum_sem` = ⌊dias / 7⌋ com 0 ≤ dias ≤ 350; fora disso, ou sem alguma das datas, NA (seção 8)."""
    d = dias_dum(col_data, col_dum)
    return pl.when(d.is_between(0, DUM_MAX_DIAS)).then(d // 7).cast(pl.Int16)


def motivo_na_ig_dum(col_data: str, col_dum: str) -> pl.Expr:
    """Por que `ig_dum_sem` é NA (null quando não é). Só para logs agregados; não vai para arquivo."""
    d = dias_dum(col_data, col_dum)
    return (pl.when(pl.col(col_dum).str.strip_chars().replace("", None).is_null()).then(pl.lit("ausente"))
            .when(data_dum(col_dum).is_null()).then(pl.lit("nao_analisavel"))
            .when(pl.col(col_data).is_null()).then(pl.lit("parto_sem_data"))
            .when(d < 0).then(pl.lit("posterior_ao_parto"))
            .when(d > DUM_MAX_DIAS).then(pl.lit("anterior_50_semanas")))


# ---------------------------------------------------------------------------- nascimentos
SIN_COLS = ["CODMUNRES", "DTNASC", "SEMAGESTAC", "GESTACAO", "TPMETESTIM", "GRAVIDEZ", "PESO", "SEXO",
            "IDADEMAE", "ESCMAE", "ESCMAE2010", "RACACORMAE", "ESTCIVMAE", "QTDGESTANT", "QTDPARTNOR",
            "QTDPARTCES", "QTDFILVIVO", "QTDFILMORT", "CONSPRENAT", "CONSULTAS", "PARTO", "STTRABPART",
            "STCESPARTO", "TPAPRESENT", "TPROBSON", "IDANOMAL", "CODANOMAL", "DTULTMENST", "_UF", "_STATUS"]


def derivar_nascimentos(lf: pl.LazyFrame, ano: int) -> pl.LazyFrame:
    """Variáveis derivadas de cada NV (E1–E3, E6, E10, E12, E18). Recebe colunas brutas em texto."""
    sg = pl.col("SEMAGESTAC").str.strip_chars().cast(pl.Int32, strict=False)
    ga = pl.when(sg.is_between(22, 44)).then(sg).otherwise(None)
    unico = (pl.col("GRAVIDEZ") == "1").fill_null(False)
    vag, ces = numero("QTDPARTNOR", 0, 30), numero("QTDPARTCES", 0, 30)
    return lf.with_columns(
        data=data_dmy("DTNASC"), ga_sem=ga,
        ig_cat=pl.when(sg.is_null() | sg.is_in([9, 99])).then(pl.lit("ausente"))   # 9 e 99 = ignorado, como no SIM (A16)
               .when(sg < 22).then(pl.lit("lt22")).when(sg <= 42).then(pl.lit("22_42"))
               .when(sg <= 44).then(pl.lit("43_44")).otherwise(pl.lit("ge45")),
        unico=unico,
        grav_cat=pl.when(pl.col("GRAVIDEZ") == "1").then(pl.lit("unica"))
                 .when(pl.col("GRAVIDEZ").is_in(["2", "3"])).then(pl.lit("multipla")).otherwise(pl.lit("ignorada")),
        peso_g=numero("PESO", 200, 7000),
        sexo=pl.col("SEXO").replace({"M": "1", "F": "2", "I": "0"}),
        idade_mae=numero("IDADEMAE", 10, 60),
        n_gest_ant=numero("QTDGESTANT", 0, 30), n_part_vag=vag, n_part_ces=ces,
        paridade=vag + ces,                                  # NA se faltar alguma (P-COV)
        paridade_filvivo=numero("QTDFILVIVO", 0, 30), n_fil_mort=numero("QTDFILMORT", 0, 30),
        n_consultas=numero("CONSPRENAT", 0, 60),
        stcesparto_aj=pl.when((pl.col("PARTO") == "1") & pl.col("STCESPARTO").is_null()).then(pl.lit("3"))
                        .otherwise(pl.col("STCESPARTO")),   # P-E12: vaginal com vazio = não se aplica
    ).with_columns(
        dum_est=pl.col("data") - pl.duration(days=pl.col("ga_sem") * 7 + 3),
        ig_dum_sem=ig_pela_dum("data", "DTULTMENST"),        # seção 8; a DTULTMENST não sai daqui
        flag_paridade_incoerente=((pl.col("paridade_filvivo") > 0) & (pl.col("paridade") == 0)).fill_null(False),
        pop_ptb=(pl.col("unico") & pl.col("ga_sem").is_between(22, 42)).fill_null(False),
        ig_43_44=(pl.col("unico") & pl.col("ga_sem").is_between(43, 44)).fill_null(False),
    ).with_columns(
        ptb=(pl.col("pop_ptb") & (pl.col("ga_sem") <= 36)).fill_null(False),
        ptb_extremo=(pl.col("pop_ptb") & (pl.col("ga_sem") <= 27)).fill_null(False),
        ptb_muito=(pl.col("pop_ptb") & pl.col("ga_sem").is_between(28, 31)).fill_null(False),
        ptb_moderado_tardio=(pl.col("pop_ptb") & pl.col("ga_sem").is_between(32, 36)).fill_null(False),
        coorte_fixa_22=em_coorte(pl.col("dum_est"), COORTE_22),
        coorte_fixa_37=em_coorte(pl.col("dum_est"), COORTE_37),
        periodo_principal=pl.lit(PRINCIPAL[0] <= ano <= PRINCIPAL[1]),
        periodo_sens2011=pl.lit(ano == ANO_SENS),
        nv_gestacao_sens2011=pl.lit(ano == ANO_SENS) & unico & pl.col("GESTACAO").is_in(["2", "3", "4", "5", "6"]).fill_null(False),
        ptb_gestacao_sens2011=pl.lit(ano == ANO_SENS) & unico & pl.col("GESTACAO").is_in(["2", "3", "4"]).fill_null(False),
    )


NASC_SAIDA = ["id_nasc", "CD_MUN6", "data", "ano", "ga_sem", "semagestac_bruto", "ig_cat", "gestacao_cat", "metodo_ig",
              "dum_est", "unico", "gravidez", "grav_cat", "pop_ptb", "ptb", "ptb_extremo", "ptb_muito",
              "ptb_moderado_tardio", "ig_43_44", "coorte_fixa_22", "coorte_fixa_37", "periodo_principal",
              "periodo_sens2011", "nv_gestacao_sens2011", "ptb_gestacao_sens2011", "peso_g", "sexo", "idade_mae",
              "escmae2010", "escmae", "raca_mae", "estciv_mae", "n_gest_ant", "n_part_vag", "n_part_ces", "paridade",
              "paridade_filvivo", "n_fil_mort", "flag_paridade_incoerente", "n_consultas", "consultas_cat", "parto",
              "sttrabpart", "stcesparto", "stcesparto_aj", "apresentacao", "robson", "idanomal", "codanomal",
              "uf_arquivo", "status_arquivo", "ig_dum_sem"]   # ig_dum_sem no fim: as colunas de antes não mudam de lugar


def nascimentos_ano(ano: int, mun6: list[str]) -> pl.DataFrame:
    lf = scan("SINASC", ano, SIN_COLS).filter(pl.col("CODMUNRES").str.slice(0, 6).is_in(mun6))
    return derivar_nascimentos(lf, ano).select(
        pl.col("id").alias("id_nasc"), pl.col("CODMUNRES").str.slice(0, 6).alias("CD_MUN6"), "data",
        pl.lit(ano, pl.Int16).alias("ano"), pl.col("ga_sem").cast(pl.Int16), pl.col("SEMAGESTAC").alias("semagestac_bruto"),
        "ig_cat", pl.col("GESTACAO").alias("gestacao_cat"), pl.col("TPMETESTIM").alias("metodo_ig"), "dum_est",
        "unico", pl.col("GRAVIDEZ").alias("gravidez"), "grav_cat", "pop_ptb", "ptb", "ptb_extremo", "ptb_muito",
        "ptb_moderado_tardio", "ig_43_44", "coorte_fixa_22", "coorte_fixa_37", "periodo_principal", "periodo_sens2011",
        "nv_gestacao_sens2011", "ptb_gestacao_sens2011", pl.col("peso_g").cast(pl.Int16), "sexo",
        pl.col("idade_mae").cast(pl.Int16), pl.col("ESCMAE2010").alias("escmae2010"), pl.col("ESCMAE").alias("escmae"),
        pl.col("RACACORMAE").alias("raca_mae"), pl.col("ESTCIVMAE").alias("estciv_mae"),
        *[pl.col(c).cast(pl.Int16) for c in ("n_gest_ant", "n_part_vag", "n_part_ces", "paridade", "paridade_filvivo",
                                             "n_fil_mort")],
        "flag_paridade_incoerente", pl.col("n_consultas").cast(pl.Int16), pl.col("CONSULTAS").alias("consultas_cat"),
        pl.col("PARTO").alias("parto"), pl.col("STTRABPART").alias("sttrabpart"), pl.col("STCESPARTO").alias("stcesparto"),
        "stcesparto_aj", pl.col("TPAPRESENT").alias("apresentacao"), pl.col("TPROBSON").alias("robson"),
        pl.col("IDANOMAL").alias("idanomal"), pl.col("CODANOMAL").alias("codanomal"),
        pl.col("_UF").alias("uf_arquivo"), pl.col("_STATUS").alias("status_arquivo"), "ig_dum_sem",
    ).sort("id_nasc").collect()


# ---------------------------------------------------------------------------- óbitos
SIM_COLS = ["CODMUNRES", "TIPOBITO", "DTOBITO", "DTNASC", "IDADE", "SEXO", "RACACOR", "GRAVIDEZ", "SEMAGESTAC",
            "GESTACAO", "PESO", "PARTO", "OBITOPARTO", "IDADEMAE", "ESCMAE", "ESCMAE2010", "CAUSABAS",
            "LINHAA", "LINHAB", "LINHAC", "LINHAD", "LINHAII", "_UF", "_STATUS"]


def derivar_obitos(lf: pl.LazyFrame, tipo: str) -> pl.LazyFrame:
    """Óbito fetal (DOFET) ou neonatal precoce (DO), com data-índice, IG, coorte e critérios (E2, E4–E6)."""
    sg = pl.col("SEMAGESTAC").str.strip_chars().cast(pl.Int32, strict=False)
    ga = pl.when(sg.is_between(1, 47) & (sg != 9)).then(sg).otherwise(None)   # 9 e 99 = ignorado
    gcat, peso = pl.col("GESTACAO"), numero("PESO", 1, 6999)
    unid = pl.col("IDADE").str.slice(0, 1)
    qtd = pl.col("IDADE").str.slice(1, 2).cast(pl.Int32, strict=False)
    lf = lf.with_columns(ga_sem=ga, peso_g=peso, data_obito=data_dmy("DTOBITO"), data_nasc=data_dmy("DTNASC"),
                         unico=(pl.col("GRAVIDEZ") == "1").fill_null(False))
    if tipo == "fetal":
        criterio = (pl.when(ga.is_not_null()).then(pl.when(ga >= 22).then(pl.lit("1_semagestac")))
                    .when(gcat.is_in(["1", "2", "3", "4", "5", "6"])).then(pl.when(gcat != "1").then(pl.lit("2_gestacao")))
                    .when(peso.is_not_null()).then(pl.when(peso >= 500).then(pl.lit("3_peso")))
                    .otherwise(None))
        lf = lf.filter(pl.col("TIPOBITO") == "1").with_columns(
            tipo=pl.lit("fetal"), criterio_fetal=criterio, data_indice=pl.col("data_obito"),
            ate24h=pl.lit(False), idade_valida=pl.lit(True))
    else:
        neo = (pl.col("TIPOBITO") == "2") & (unid.is_in(["0", "1"]) | ((unid == "2") & (qtd <= 6)))
        lf = lf.filter(neo).with_columns(
            tipo=pl.lit("neonatal_precoce"), criterio_fetal=pl.lit(None, pl.Utf8), data_indice=pl.col("data_nasc"),
            ate24h=(unid.is_in(["0", "1"]) | (pl.col("IDADE") == "200")).fill_null(False),
            idade_valida=(((unid == "0") & (qtd <= 59)) | ((unid == "1") & (qtd <= 23)) | (unid == "2")).fill_null(False))
    return lf.with_columns(
        s_ini=pl.col("data_indice") - pl.duration(days=pl.col("ga_sem") * 7 + 3),
        ig_22_42=pl.col("ga_sem").is_between(22, 42).fill_null(False),
        anomalia_causabas=pl.col("CAUSABAS").str.starts_with("Q").fill_null(False),
        anomalia_qualquer_linha=pl.any_horizontal(
            [pl.col(c).str.contains(r"Q\d{2}").fill_null(False) for c in ("CAUSABAS", "LINHAA", "LINHAB", "LINHAC",
                                                                          "LINHAD", "LINHAII")]),
        cb_cap16_perinatal=pl.col("CAUSABAS").str.starts_with("P").fill_null(False),
    ).with_columns(
        coorte_fixa_22=em_coorte(pl.col("s_ini"), COORTE_22),
        principal=(pl.col("unico") & pl.col("ig_22_42") & pl.col("data_indice").is_not_null() & pl.col("idade_valida")
                   & ((pl.col("tipo") == "neonatal_precoce") | (pl.col("criterio_fetal") == "1_semagestac"))),
        sem_ig=(pl.col("unico") & pl.col("ga_sem").is_null() & pl.col("data_indice").is_not_null() & pl.col("idade_valida")
                & ((pl.col("tipo") == "neonatal_precoce") | pl.col("criterio_fetal").is_in(["2_gestacao", "3_peso"]))),
    )


OB_SAIDA = ["id_obito", "tipo", "CD_MUN6", "data_indice", "data_obito", "data_nasc", "ano_obito", "ga_sem",
            "semagestac_bruto", "gestacao_cat", "peso_g", "criterio_fetal", "unico", "gravidez", "ig_22_42", "s_ini",
            "coorte_fixa_22", "principal", "sem_ig", "idade", "idade_valida", "ate24h", "sexo", "raca_cor", "parto",
            "obitoparto", "idade_mae", "causabas", "anomalia_causabas", "anomalia_qualquer_linha", "cb_cap16_perinatal",
            "uf_arquivo", "status_arquivo"]


def do_sem_idade_ano(ano: int, mun6: list[str]) -> int:
    """Óbitos não fetais (TIPOBITO 2) com IDADE ausente ou fora do padrão, mas com DTOBITO − DTNASC
    de 0 a 6 dias: não entram como neonatal precoce e vão para o fluxograma (auditoria A10)."""
    lf = scan("SIM-DO", ano, SIM_COLS).filter(pl.col("CODMUNRES").str.slice(0, 6).is_in(mun6) & (pl.col("TIPOBITO") == "2"))
    dias = (data_dmy("DTOBITO") - data_dmy("DTNASC")).dt.total_days()
    ruim = pl.col("IDADE").is_null() | ~pl.col("IDADE").str.contains(r"^[0-4]\d\d$")
    return int(lf.filter(ruim & dias.is_between(0, 6)).select(pl.len()).collect().item())


def obitos_ano(ano: int, mun6: list[str]) -> pl.DataFrame:
    partes = []
    for sist, tipo in (("SIM-DOFET", "fetal"), ("SIM-DO", "neonatal")):
        lf = scan(sist, ano, SIM_COLS).filter(pl.col("CODMUNRES").str.slice(0, 6).is_in(mun6))
        lf = derivar_obitos(lf, tipo).with_columns(
            pl.col("id") + (0 if tipo == "neonatal" else 500_000_000))   # ids do DOFET não colidem com os do DO
        partes.append(lf.select(
            pl.col("id").alias("id_obito"), "tipo", pl.col("CODMUNRES").str.slice(0, 6).alias("CD_MUN6"), "data_indice",
            "data_obito", "data_nasc", pl.lit(ano, pl.Int16).alias("ano_obito"), pl.col("ga_sem").cast(pl.Int16),
            pl.col("SEMAGESTAC").alias("semagestac_bruto"), pl.col("GESTACAO").alias("gestacao_cat"),
            pl.col("peso_g").cast(pl.Int16), "criterio_fetal", "unico", pl.col("GRAVIDEZ").alias("gravidez"), "ig_22_42",
            "s_ini", "coorte_fixa_22", "principal", "sem_ig", pl.col("IDADE").alias("idade"), "idade_valida", "ate24h",
            pl.col("SEXO").alias("sexo"), pl.col("RACACOR").alias("raca_cor"), pl.col("PARTO").alias("parto"),
            pl.col("OBITOPARTO").alias("obitoparto"), numero("IDADEMAE", 10, 60).cast(pl.Int16).alias("idade_mae"),
            pl.col("CAUSABAS").alias("causabas"), "anomalia_causabas", "anomalia_qualquer_linha", "cb_cap16_perinatal",
            pl.col("_UF").alias("uf_arquivo"), pl.col("_STATUS").alias("status_arquivo")))
    return pl.concat(partes, how="vertical").sort("id_obito").collect()


# ---------------------------------------------------------------------------- série diária
def serie(nasc: pl.LazyFrame, ob: pl.LazyFrame, mun: pd.DataFrame, coorte: bool) -> pl.DataFrame:
    """Série município × dia, 2011–2024, nas regras do E3–E6, E9, E18 e dos desvios de 05/10."""
    c22n = pl.col("coorte_fixa_22") if coorte else pl.lit(True)
    nv = nasc.filter(pl.col("data").is_between(pl.lit(SERIE_INI), pl.lit(SERIE_FIM))).group_by("CD_MUN6", "data").agg(
        (pl.col("pop_ptb") & c22n).sum().alias("nv_unicos"),
        (~pl.col("unico")).sum().alias("nv_multiplos_ou_ign"),
        (pl.col("ptb") & c22n).sum().alias("ptb"),
        (pl.col("ptb_extremo") & c22n).sum().alias("ptb_extremo"),
        (pl.col("ptb_muito") & c22n).sum().alias("ptb_muito"),
        (pl.col("ptb_moderado_tardio") & c22n).sum().alias("ptb_moderado_tardio"),
        (pl.col("ig_43_44") & c22n).sum().alias("nv_ig_43_44"),
        pl.col("ptb_gestacao_sens2011").sum().alias("ptb_gestacao_sens2011"),
        pl.col("nv_gestacao_sens2011").sum().alias("nv_gestacao_sens2011"),
    )
    c22o = pl.col("coorte_fixa_22") if coorte else pl.lit(True)
    fet, neo = pl.col("tipo") == "fetal", pl.col("tipo") == "neonatal_precoce"
    pf, pn = fet & pl.col("principal") & c22o, neo & pl.col("principal") & c22o
    sem_anom = ~pl.col("anomalia_causabas")
    por_indice = ob.group_by("CD_MUN6", pl.col("data_indice").alias("data")).agg(
        pf.sum().alias("obito_fetal_principal"),
        (fet & pl.col("sem_ig")).sum().alias("obito_fetal_sem_ig"),
        pn.sum().alias("obito_neonatal_precoce"),
        (neo & pl.col("sem_ig")).sum().alias("obito_neonatal_precoce_sem_ig"),
        (pn & pl.col("ate24h")).sum().alias("obito_ate24h"),
        ((pf | pn) & sem_anom).sum().alias("obito_perinatal_sem_anomalia"),
    )
    por_obito = ob.group_by("CD_MUN6", pl.col("data_obito").alias("data")).agg(
        pn.sum().alias("obito_neonatal_precoce_idx_obito"),
        pf.sum().alias("_fetal_idx_obito"),
    )
    datas = pl.date_range(SERIE_INI, SERIE_FIM, "1d", eager=True).alias("data")
    grade = pl.DataFrame({"CD_MUN6": sorted(mun["CD_MUN6"])}).join(pl.DataFrame(datas), how="cross")
    s = (grade.lazy().join(nv, on=["CD_MUN6", "data"], how="left").join(por_indice, on=["CD_MUN6", "data"], how="left")
         .join(por_obito, on=["CD_MUN6", "data"], how="left").collect())
    conta = COL_NV + COL_SENS + [c for c in COL_OB if c not in ("obito_perinatal", "obito_perinatal_idx_obito",
                                                                 "obito_perinatal_24h")] + ["_fetal_idx_obito"]
    s = s.with_columns([pl.col(c).fill_null(0).cast(pl.Int32) for c in conta]).with_columns(
        obito_perinatal=pl.col("obito_fetal_principal") + pl.col("obito_neonatal_precoce"),
        obito_perinatal_idx_obito=pl.col("_fetal_idx_obito") + pl.col("obito_neonatal_precoce_idx_obito"),
        obito_perinatal_24h=pl.col("obito_fetal_principal") + pl.col("obito_ate24h"),
    ).drop("_fetal_idx_obito")
    ano = pl.col("data").dt.year()
    depende_ig = [c for c in COL_NV + COL_OB if c != "nv_multiplos_ou_ign"]
    censura = pl.col("data") >= pl.lit(CENSURA_INI)
    s = s.with_columns(
        # 2011: colunas que dependem de IG = NA (desvio de 05/10); *_sens2011 só em 2011
        [pl.when(ano == ANO_SENS).then(None).otherwise(pl.col(c)).alias(c) for c in depende_ig]
        + [pl.when(ano == ANO_SENS).then(pl.col(c)).otherwise(None).alias(c) for c in COL_SENS]
    ).with_columns(
        # censura de dez/2024 (desvio de 05/10)
        [pl.when(censura).then(None).otherwise(pl.col(c)).alias(c) for c in COL_CENSURA]
    )
    if coorte:  # E4: sem coorte fixa para as colunas sem IG no arquivo principal
        s = s.with_columns([pl.lit(None, pl.Int32).alias(c) for c in ("obito_fetal_sem_ig", "obito_neonatal_precoce_sem_ig")])
    rec = pl.from_pandas(mun[["CD_MUN6", "CD_RECORTE", "TIPO_RECORTE"]]).rename(
        {"CD_RECORTE": "recorte_principal", "TIPO_RECORTE": "tipo_recorte"})
    return (s.join(rec, on="CD_MUN6", how="left").with_columns(
        periodo_principal=ano.is_between(*PRINCIPAL), periodo_sens2011=ano == ANO_SENS,
        censura_neonatal_dez2024=censura)
        .select(["CD_MUN6", "data", *COL_NV, *COL_OB, "recorte_principal", "tipo_recorte", "periodo_principal",
                 "periodo_sens2011", *COL_SENS, "censura_neonatal_dez2024"]).sort("CD_MUN6", "data"))


# ---------------------------------------------------------------------------- logs agregados
def suprimir(df: pd.DataFrame, identidades: list[tuple[str, list[str]]]) -> pd.DataFrame:
    """Máscara "<10" com supressão complementar (auditoria A2 do 06b): em cada linha, para cada
    identidade total = soma das partes, nenhuma célula mascarada pode ser recuperada por subtração.
    Se só uma célula da identidade está mascarada, mascara também a menor parte não nula restante
    (ou o total). Repete até estabilizar, porque as identidades se encadeiam."""
    val = df.copy()
    masc = val.map(lambda x: isinstance(x, (int, float, np.integer)) and not pd.isna(x) and 0 < x < 10)
    for _ in range(10):
        mudou = False
        for total, partes in identidades:
            for i in val.index:
                cel = [total] + partes
                if sum(bool(masc.at[i, c]) for c in cel) != 1:
                    continue
                livres = [c for c in partes if not masc.at[i, c] and val.at[i, c] not in (0, None) and not pd.isna(val.at[i, c])]
                alvo = min(livres, key=lambda c: val.at[i, c]) if livres else total
                masc.at[i, alvo] = True
                mudou = True
        if not mudou:
            break
    out = val.astype(object)
    for c in val.columns:
        if c in masc.columns:
            out.loc[masc[c], c] = "<10"
    return out


def mascarar_e5(e5: pd.DataFrame) -> pd.DataFrame:
    """Máscara "<10" do validacao_e5_datas com supressão complementar: neonatais = com as duas datas + sem alguma
    data, e a última parte é dedutível por subtração (auditoria do fechamento, A15)."""
    cont = ["neonatais", "dtnasc_ausente", "dtnasc_depois_do_obito", "idade_discorda_datas", "com_as_duas_datas"]
    e5 = e5.copy()
    e5["_sem_alguma_data"] = e5["neonatais"] - e5["com_as_duas_datas"]
    m = suprimir(e5[cont + ["_sem_alguma_data"]].astype(int), [("neonatais", ["com_as_duas_datas", "_sem_alguma_data"])])
    e5[cont] = m[cont].map(lambda x: x if x == "<10" else str(int(x)))
    # a % (com a discordância) reconstrói com_as_duas_datas: some quando ela ou a discordância estão suprimidas (B1)
    if "pct_concordancia" in e5.columns:
        e5["pct_concordancia"] = e5["pct_concordancia"].astype(object)
        e5.loc[(e5["com_as_duas_datas"] == "<10") | (e5["idade_discorda_datas"] == "<10"), "pct_concordancia"] = ""
    return e5.drop(columns="_sem_alguma_data")


def soma_na(c: str) -> pl.Expr:
    """Soma que devolve NA quando todas as células são NA (auditoria A1 do 06b)."""
    return pl.when(pl.col(c).is_not_null().any()).then(pl.col(c).sum()).otherwise(None).alias(c)


def logs_agregados(nasc: pl.LazyFrame, ob: pl.LazyFrame, series: dict, mun: pd.DataFrame, do_sem_idade: dict,
                   destino, log) -> None:
    ano = pl.col("ano")
    # fluxograma em partições explícitas (cada linha fecha por soma)
    flux_n = nasc.group_by(ano).agg(
        pl.len().alias("total_residentes"), (~pl.col("unico")).sum().alias("nao_unico"),
        (pl.col("unico") & (pl.col("ig_cat") == "ausente")).sum().alias("unico_ig_ausente"),
        (pl.col("unico") & (pl.col("ig_cat") == "lt22")).sum().alias("unico_ig_lt22"),
        (pl.col("unico") & (pl.col("ig_cat") == "43_44")).sum().alias("unico_ig_43_44"),
        (pl.col("unico") & (pl.col("ig_cat") == "ge45")).sum().alias("unico_ig_ge45"),
        pl.col("pop_ptb").sum().alias("populacao_principal"),
        (pl.col("pop_ptb") & ~pl.col("coorte_fixa_22")).sum().alias("fora_coorte_fixa_22"),
        (pl.col("pop_ptb") & pl.col("coorte_fixa_22")).sum().alias("na_serie_principal"),
    ).sort("ano").collect().to_pandas().assign(sistema="SINASC")
    un, ga_nulo = pl.col("unico"), pl.col("ga_sem").is_null()
    ok_dados = pl.col("data_indice").is_not_null() & pl.col("idade_valida")
    flux_o = ob.group_by("tipo", pl.col("ano_obito").alias("ano")).agg(
        pl.len().alias("total_residentes"), (~un).sum().alias("nao_unico"),
        pl.col("sem_ig").sum().alias("unico_ig_ausente_sem_ig"),
        (un & ga_nulo & ~pl.col("sem_ig")).sum().alias("unico_ig_ausente_excluido"),
        (un & ~ga_nulo & ~pl.col("ig_22_42")).sum().alias("unico_ig_fora_22_42"),
        pl.col("principal").sum().alias("populacao_principal"),
        (un & pl.col("ig_22_42") & ~pl.col("principal")).sum().alias("unico_ig_22_42_sem_data_ou_idade"),
        (pl.col("principal") & ~pl.col("coorte_fixa_22")).sum().alias("fora_coorte_fixa_22"),
        (pl.col("principal") & pl.col("coorte_fixa_22")).sum().alias("na_serie_principal"),
    ).sort("tipo", "ano").collect().to_pandas().rename(columns={"tipo": "sistema"})
    flux_o["do_neonatal_idade_ausente_datas_ate6d"] = [
        do_sem_idade.get(int(a)) if s_ == "neonatal_precoce" else None for s_, a in zip(flux_o["sistema"], flux_o["ano"])]
    flux = pd.concat([flux_n, flux_o], ignore_index=True)
    ident = [("total_residentes", ["nao_unico", "unico_ig_ausente", "unico_ig_lt22", "unico_ig_43_44", "unico_ig_ge45",
                                   "unico_ig_ausente_sem_ig", "unico_ig_ausente_excluido", "unico_ig_fora_22_42",
                                   "populacao_principal", "unico_ig_22_42_sem_data_ou_idade"]),
             ("populacao_principal", ["fora_coorte_fixa_22", "na_serie_principal"])]
    flux = flux.fillna(0)
    num = [c for c in flux.columns if c not in ("sistema", "ano")]
    flux[num] = flux[num].astype(int)
    for c in [c for c in ident[0][1] if c not in flux.columns]:
        flux[c] = 0
    flux = pd.concat([flux[["sistema", "ano"]], suprimir(flux[num], ident)], axis=1)
    flux.to_csv(destino / "fluxograma_exclusoes.csv", index=False)

    # E5: datas do óbito neonatal (minutos e horas: dias entre as datas em {0, 1}; dias: igual à IDADE)
    neo = ob.filter(pl.col("tipo") == "neonatal_precoce")
    dias = (pl.col("data_obito") - pl.col("data_nasc")).dt.total_days()
    unid = pl.col("idade").str.slice(0, 1)
    qtd = pl.col("idade").str.slice(1, 2).cast(pl.Int32, strict=False)
    discorda = (((unid == "2") & (dias != qtd)) | (unid.is_in(["0", "1"]) & ~dias.is_in([0, 1]))).fill_null(False)
    e5 = neo.group_by(pl.col("ano_obito").alias("ano")).agg(
        pl.len().alias("neonatais"), pl.col("data_nasc").is_null().sum().alias("dtnasc_ausente"),
        (pl.col("data_nasc") > pl.col("data_obito")).sum().alias("dtnasc_depois_do_obito"),
        (discorda & dias.is_not_null()).sum().alias("idade_discorda_datas"),
        dias.is_not_null().sum().alias("com_as_duas_datas"),
    ).sort("ano").collect().to_pandas()
    pct = (100 * (1 - e5["idade_discorda_datas"] / e5["com_as_duas_datas"])).round(2)
    # a % é omitida quando permitiria recuperar uma discordância < 10 (A2)
    e5["pct_concordancia"] = [p if d >= 10 or d == 0 else "" for p, d in zip(pct, e5["idade_discorda_datas"])]
    mascarar_e5(e5).to_csv(destino / "validacao_e5_datas.csv", index=False)

    # óbitos por critério: largo, com o total na mesma linha e supressão complementar
    crit = ob.group_by(pl.col("ano_obito").alias("ano"), "tipo").agg(
        pl.len().alias("total"), *[(pl.col("criterio_fetal") == c).sum().alias(c) for c in ("1_semagestac", "2_gestacao", "3_peso")],
        pl.col("criterio_fetal").is_null().sum().alias("sem_criterio_fetal")).sort("ano", "tipo").collect().to_pandas()
    cc = ["total", "1_semagestac", "2_gestacao", "3_peso", "sem_criterio_fetal"]
    crit = pd.concat([crit[["ano", "tipo"]], suprimir(crit[cc], [("total", cc[1:])])], axis=1)
    crit.to_csv(destino / "obitos_por_criterio.csv", index=False)

    # totais anuais das duas versões, com NA onde a série é NA (A1)
    tot = []
    for versao, s_ in series.items():
        t = s_.group_by(pl.col("data").dt.year().alias("ano")).agg([soma_na(c) for c in COL_NV + COL_OB + COL_SENS]).sort("ano")
        tot.append(t.to_pandas().assign(versao=versao))
    tot = pd.concat(tot, ignore_index=True)
    for c in COL_NV + COL_OB + COL_SENS:
        tot[c] = tot[c].map(lambda x: "" if pd.isna(x) else mascara(x))
    tot[["versao", "ano"] + COL_NV + COL_OB + COL_SENS].to_csv(destino / "totais_anuais.csv", index=False)

    # E10: critérios de inclusão por concentração (período principal, série com coorte fixa)
    s_cf = series["principal"]
    ev = s_cf.filter(pl.col("periodo_principal")).group_by("recorte_principal").agg(
        pl.col("ptb").sum(), pl.col("obito_perinatal").sum()).to_pandas().set_index("recorte_principal")
    comp = nasc.filter(pl.col("periodo_principal") & pl.col("unico")).group_by("CD_MUN6").agg(
        pl.len().alias("n"), (pl.col("ga_sem").is_not_null() & pl.col("peso_g").is_not_null()).sum().alias("ok"),
        (pl.col("coorte_fixa_37") & pl.col("ga_sem").is_between(37, 42) & pl.col("peso_g").is_not_null()).sum().alias("pop_pig"),
    ).collect().to_pandas().merge(mun[["CD_MUN6", "CD_RECORTE"]], on="CD_MUN6").groupby("CD_RECORTE")[["n", "ok", "pop_pig"]].sum()
    nuc = pd.read_csv(C.RM / "cidade_nucleo.csv", dtype=str)
    # dias sem tmean (união de Tmax e Tmin), lidos da própria série de clima (A8)
    clima = pl.read_parquet(C.PROC / f"clima_municipio_diario_{C.CLIMA_INI[:4]}_{C.CLIMA_FIM[:4]}.parquet", columns=["CD_MUN", "tmean"])
    falt = clima.group_by("CD_MUN").agg(pl.col("tmean").is_null().sum().alias("n")).to_pandas().set_index("CD_MUN")["n"]
    linhas = []
    for r in nuc.itertuples():
        cp = comp.loc[r.CD_RECORTE]
        muns = mun.loc[mun["CD_RECORTE"] == r.CD_RECORTE, "CD_MUN"]
        pct_ok = 100 * cp["ok"] / cp["n"]
        d_nuc = int(falt.get(r.CD_MUN_NUCLEO, 0))
        base = {"CD_RECORTE": r.CD_RECORTE, "NM_RECORTE": r.NM_RECORTE, "dias_faltantes_tmean_nucleo": d_nuc,
                "reprova_1a_etapa_exposicao": d_nuc > 0,
                "municipios_tmean_incompleto": int((falt.reindex(muns).fillna(0) > 0).sum()),
                "pct_nv_ig_e_peso_validos": round(pct_ok, 2), "flag_completude_90": bool(pct_ok >= 90),
                "populacao_pig_principal": mascara(int(cp["pop_pig"]))}
        for desf, n in (("prematuridade", int(ev.at[r.CD_RECORTE, "ptb"])), ("obito_perinatal", int(ev.at[r.CD_RECORTE, "obito_perinatal"]))):
            linhas.append({**base, "desfecho": desf, "eventos_periodo_principal": mascara(n),
                           "flag_500": n >= 500, "flag_1000": n >= 1000, "flag_2000": n >= 2000})
    pd.DataFrame(linhas).to_csv(destino / "criterios_inclusao_recorte.csv", index=False)
    log.info("Logs agregados gravados em %s: fluxograma_exclusoes, validacao_e5_datas, obitos_por_criterio, "
             "totais_anuais (duas versões), criterios_inclusao_recorte", destino)


def gravar_tabela(df_iter, campos: list[str], saida, log) -> int:
    """Grava ano a ano num único parquet (.part + os.replace); devolve o nº de linhas."""
    tmp, escritor, n = saida.with_suffix(".parquet.part"), None, 0
    for df in df_iter:
        t = df.select(campos).to_arrow()
        if escritor is None:
            escritor = pq.ParquetWriter(tmp, t.schema, compression="zstd")
        escritor.write_table(t)
        n += len(df)
    escritor.close()
    os.replace(tmp, saida)
    if not saida.exists() or saida.stat().st_size == 0:
        para(log, "falha ao gravar %s", saida)
    return n


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--rascunho", action="store_true", help="saídas em _tmp/rascunho_06b (teste, dentro da Forja)")
    a = p.parse_args()
    log = U.get_logger("06b_desfechos")
    saida_dir = C.TMP / "rascunho_06b" if a.rascunho else C.PROC
    logs_dir = saida_dir if a.rascunho else C.LOGS
    saida_dir.mkdir(parents=True, exist_ok=True)
    conferir_entradas(log)

    mun = pd.read_csv(C.RM / "concentracoes_urbanas_municipios.csv", dtype=str)
    if len(mun) != 277 or not mun["CD_MUN6"].is_unique:
        para(log, "concentrações: %d municípios (esperado 277, CD_MUN6 único)", len(mun))
    mun6 = sorted(mun["CD_MUN6"])
    # E17: municípios instalados depois de 2010 — só há o que reatribuir se algum encostar numa concentração (A4)
    novos = pd.read_csv(C.RM / "municipios_novos_origem.csv", dtype=str)
    encosta = novos[novos["ENCOSTA_EM_CONCENTRACAO"] == "1"]
    if len(encosta):
        para(log, "E17: %d municípios novos encostam em concentração (%s); a origem precisa ser levantada antes",
             len(encosta), encosta["CD_MUN"].tolist())
    log.info("Recorte: %d municípios de %d concentrações; E17: %d municípios novos na malha, nenhum encosta em "
             "concentração, 0 reatribuídos", len(mun6), mun["CD_RECORTE"].nunique(), len(novos))

    f_nasc, f_ob = saida_dir / "nascimentos.parquet", saida_dir / "obitos_perinatais.parquet"
    n_nasc = gravar_tabela((nascimentos_ano(ano, mun6) for ano in C.ANOS), NASC_SAIDA, f_nasc, log)
    log.info("nascimentos: %d registros", n_nasc)
    n_ob = gravar_tabela((obitos_ano(ano, mun6) for ano in C.ANOS), OB_SAIDA, f_ob, log)
    log.info("óbitos (fetais e neonatais precoces): %d registros", n_ob)

    nasc, ob = pl.scan_parquet(f_nasc), pl.scan_parquet(f_ob)
    do_sem_idade = {ano: do_sem_idade_ano(ano, mun6) for ano in C.ANOS}
    saidas = {}
    for coorte, nome in ((True, "serie_diaria_municipio.parquet"), (False, "serie_diaria_municipio_sem_coorte_fixa.parquet")):
        s = serie(nasc, ob, mun, coorte)
        tmp = saida_dir / (nome + ".part")
        s.write_parquet(tmp, compression="zstd")
        os.replace(tmp, saida_dir / nome)
        saidas[nome] = s
        log.info("%s: %d linhas (%d municípios × %d dias)", nome, len(s), s["CD_MUN6"].n_unique(), s["data"].n_unique())
    logs_agregados(nasc, ob, {"principal": saidas["serie_diaria_municipio.parquet"],
                              "sem_coorte_fixa": saidas["serie_diaria_municipio_sem_coorte_fixa.parquet"]},
                   mun, do_sem_idade, logs_dir, log)

    # completude de ESTCIVMAE (E10) e IG por mês de 2011 (P-E18), só agregados
    est = nasc.group_by("ano").agg((pl.col("estciv_mae").is_not_null().mean() * 100).round(2).alias("pct")).sort("ano").collect()
    log.info("ESTCIVMAE preenchido (%%, 277 municípios): %s", dict(zip(est["ano"].to_list(), est["pct"].to_list())))
    m11 = nasc.filter(pl.col("ano") == ANO_SENS).group_by(pl.col("data").dt.month().alias("mes")).agg(
        (pl.col("ga_sem").is_not_null().mean() * 100).round(1).alias("pct")).sort("mes").collect()
    log.info("2011, %% de NV com IG válida por mês: %s", dict(zip(m11["mes"].to_list(), m11["pct"].to_list())))

    if not a.rascunho:
        for f in (f_nasc, f_ob, *(saida_dir / n for n in saidas)):
            U.registrar_integridade([{
                "sistema": "DESFECHOS", "ano": f"{C.ANO_INI}-{C.ANO_FIM}", "uf": "concentracoes", "arquivo": f.name,
                "status": "derivado", "n_linhas": pl.scan_parquet(f).select(pl.len()).collect().item(),
                "md5_parquet": U.md5(f), "observacao": "06b; microdado individual nas tabelas de registro",
            }])
        U.registrar_proveniencia(
            [f_nasc, f_ob, *(saida_dir / n for n in saidas),
             *(logs_dir / n for n in ("fluxograma_exclusoes.csv", "validacao_e5_datas.csv", "obitos_por_criterio.csv",
                                      "totais_anuais.csv", "criterios_inclusao_recorte.csv"))],
            ["integridade:SINASC", "integridade:SIM-DO", "integridade:SIM-DOFET",
             "04_regioes_metropolitanas/concentracoes_urbanas_municipios.csv", "04_regioes_metropolitanas/cidade_nucleo.csv",
             "04_regioes_metropolitanas/municipios_novos_origem.csv",
             f"06_processados/clima_municipio_diario_{C.CLIMA_INI[:4]}_{C.CLIMA_FIM[:4]}.parquet", *U.codigo(__file__)], __file__)
    log.info("FIM 06b (%s)", "rascunho" if a.rascunho else "projeto")


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception:  # noqa: BLE001 — a exceção vai para o .log (auditoria A12)
        U.get_logger("06b_desfechos").exception("06b interrompido por exceção")
        raise
