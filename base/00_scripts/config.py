"""Configuração central da base dados_artigos_perinatais_clima.

Tudo que é caminho, período ou URL mora aqui. Os scripts numerados só importam
deste módulo. Mudou o período? Mude aqui e rode de novo.
"""
from __future__ import annotations

import os
from pathlib import Path

# --------------------------------------------------------------------------
# Caminhos (ROOT = pasta-mãe de 00_scripts, resolvido a partir deste arquivo)
# --------------------------------------------------------------------------
ROOT = Path(__file__).resolve().parent.parent
SCRIPTS = ROOT / "00_scripts"
SINASC = ROOT / "01_sinasc"
SIM = ROOT / "02_sim"
CLIMA = ROOT / "03_clima"
RM = ROOT / "04_regioes_metropolitanas"
SHP = ROOT / "05_shapefiles"
PROC = ROOT / "06_processados"
PIG = ROOT / "07_pig_referencia"
CALENDARIO = ROOT / "08_calendario"
LOGS = ROOT / "logs"
INTEGRIDADE_CSV = LOGS / "integridade.csv"
# Temporários com microdado (o .dbf descomprimido): SEMPRE dentro da Forja, nunca no
# $TMPDIR do disco interno (auditoria A1, 02/10/2026). Fora do git.
TMP = ROOT / "_tmp"
# O spill em disco do polars (motor streaming) também fica na Forja (auditoria R8, 03/10/2026).
# Atribuição forçada: um POLARS_TEMP_DIR herdado do shell não pode levar microdado para fora
# (auditoria C5). No polars 1.44.2 a variável é lida na hora do spill, então a ordem dos
# imports não importa (auditoria C4); mesmo assim os scripts importam config primeiro.
os.environ["POLARS_TEMP_DIR"] = str(TMP)
os.environ["POLARS_OOC_SPILL_DIR"] = str(TMP)

# Base antiga do CliMaterna, usada SÓ para conferência cruzada de contagens: o 99 lê o
# metadado num_rows; o 98 lê só a coluna CODMUNRES e grava contagens UF x ano. Nenhuma
# linha individual é gravada nem sai da Forja.
CLIMATERNA_RAW = Path("/Volumes/Forja/CliMaterna/01_data/raw")

# --------------------------------------------------------------------------
# Período
# --------------------------------------------------------------------------
ANO_INI = 2011
ANO_FIM = 2024
ANOS = list(range(ANO_INI, ANO_FIM + 1))

# Adendo v1.1 (01/10/2026): estudo começa em 2011 e o clima em 2010-01-01, para
# cobrir a janela gestacional completa de quem nasceu em jan/2011 (até 44 semanas:
# 44*7+3 = 311 dias antes do parto) e os lags. 2010-01-01 dá folga de 365 dias.
CLIMA_INI = "2010-01-01"
# Fim estendido além do estudo: o controle negativo da especificação usa a
# temperatura futura (lead +1 a +7 dias) dos partos de dez/2024. BR-DWGD v_3.2.4
# vai até 2025-12-31.
CLIMA_FIM = "2025-01-31"

SEED = 20261001

UFS = [
    "AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "GO", "MA", "MG", "MS", "MT",
    "PA", "PB", "PE", "PI", "PR", "RJ", "RN", "RO", "RR", "RS", "SC", "SE", "SP", "TO",
]

# --------------------------------------------------------------------------
# DATASUS — diretórios do FTP (confirmados no código já usado no CliMaterna e
# na documentação do microdatasus). Ordem = prioridade: definitivo, depois
# preliminar. O status efetivamente usado fica gravado no log de integridade.
# --------------------------------------------------------------------------
FTP = "ftp://ftp.datasus.gov.br/dissemin/publicos"

SINASC_DIRS = {
    "definitivo": f"{FTP}/SINASC/1996_/Dados/DNRES",
    "preliminar": f"{FTP}/SINASC/PRELIM/DNRES",
}
SIM_DO_DIRS = {
    "definitivo": f"{FTP}/SIM/CID10/DORES",
    "preliminar": f"{FTP}/SIM/PRELIM/DORES",
}
SIM_DOFET_DIRS = {
    "definitivo": f"{FTP}/SIM/CID10/DOFET",
    "preliminar": f"{FTP}/SIM/PRELIM/DOFET",
}


def nome_sinasc(uf: str, ano: int) -> str:
    return f"DN{uf}{ano}"


def nome_sim_do(uf: str, ano: int) -> str:
    return f"DO{uf}{ano}"


def nome_dofet(ano: int) -> str:
    # DOFET é nacional e usa ano com 2 dígitos (ex.: DOFET23.dbc)
    return f"DOFET{str(ano)[-2:]}"


# --------------------------------------------------------------------------
# Variáveis que precisam existir (conferidas no dicionário oficial E no dado).
# Ver 01_sinasc/FONTE.md e 02_sim/FONTE.md.
# --------------------------------------------------------------------------
SINASC_VARS_CHAVE = [
    "DTNASC", "PESO", "SEMAGESTAC", "GESTACAO", "TPMETESTIM", "SEXO",
    "CODMUNRES", "CODMUNNASC", "IDADEMAE", "ESCMAE", "ESCMAE2010",
    "RACACORMAE", "RACACOR", "QTDFILVIVO", "QTDFILMORT", "QTDGESTANT",
    "QTDPARTNOR", "QTDPARTCES", "PARIDADE", "CONSULTAS", "CONSPRENAT",
    "MESPRENAT", "GRAVIDEZ", "PARTO", "STTRABPART", "STCESPARTO", "TPAPRESENT",
    "TPROBSON", "IDANOMAL",
    "CODANOMAL", "LOCNASC", "DTULTMENST",
    "ESTCIVMAE",  # E10: covariável do PIG (05/10/2026; a completude 2011–2024 está no log do 06b)
]
SIM_VARS_CHAVE = [
    "TIPOBITO", "DTOBITO", "DTNASC", "IDADE", "SEXO", "RACACOR", "CODMUNRES",
    "CODMUNOCOR", "LOCOCOR", "IDADEMAE", "ESCMAE", "ESCMAE2010", "QTDFILVIVO",
    "QTDFILMORT", "GRAVIDEZ", "SEMAGESTAC", "GESTACAO", "PARTO", "OBITOPARTO",
    "PESO", "CAUSABAS", "LINHAA", "LINHAB", "LINHAC", "LINHAD", "LINHAII",
]

# --------------------------------------------------------------------------
# IBGE
# --------------------------------------------------------------------------
IBGE_RM_DIR = (
    "https://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/"
    "municipios_por_regioes_metropolitanas/Situacao_2020a2029"
)
# RMs legais: só documentação desde 02/10/2026 (a unidade de análise são as
# grandes concentrações urbanas, abaixo). Posições 2024 e 2025.
IBGE_RM_ARQUIVOS = [
    "Composicao_RM_2024.xlsx",
    "Relatorio_Alteracoes_RM_2024.xlsx",
    "Composicao_RM_2025.xlsx",
    "Relatorio_Alteracoes_RM_2025.xlsx",
]
IBGE_MALHA_DIR = (
    "https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/"
    "malhas_municipais/municipio_2024/Brasil"
)
IBGE_MALHA_ARQUIVOS = ["BR_Municipios_2024.zip", "BR_UF_2024.zip"]
# Unidade de análise: as 26 grandes concentrações urbanas (base oficial em Access .mdb)
IBGE_ARRANJOS_DIR = (
    "https://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/"
    "arranjos_populacionais/base_de_dados_2ed"
)
IBGE_ARRANJOS_ARQUIVOS = ["ArranjosPopulacionais_mbd_2ed.zip",
                          "DICIONARIO_ArranjosPopulacionais_2ed.xls", "LEIA_ME_2ed.txt"]
IBGE_ARRANJOS_EDICAO = "Arranjos Populacionais e Concentrações Urbanas do Brasil, 2ª ed. (2016), Censo 2010"
# Censo 2022, população residente por município (SIDRA 4709, variável 93); {nivel} = N6 ou N1
SIDRA_POP2022 = ("https://servicodados.ibge.gov.br/api/v3/agregados/4709/periodos/2022/"
                 "variaveis/93?localidades={nivel}%5Ball%5D")

# --------------------------------------------------------------------------
# Feriados nacionais (E11): leis federais, texto vigente no site do Planalto
# (conferido em 05/10/2026; o 06e baixa as páginas e confere as datas no texto)
PLANALTO = "https://www.planalto.gov.br/ccivil_03"
LEIS_FERIADOS = {
    "Lei 662/1949": f"{PLANALTO}/leis/l0662.htm",
    "Lei 10.607/2002": f"{PLANALTO}/leis/2002/l10607.htm",
    "Lei 6.802/1980": f"{PLANALTO}/leis/l6802.htm",
    "Lei 14.759/2023": f"{PLANALTO}/_ato2023-2026/2023/lei/l14759.htm",
    "Lei 9.093/1995": f"{PLANALTO}/leis/l9093.htm",
}

# --------------------------------------------------------------------------
# BR-DWGD (Xavier et al.) — versão v_3.2.4 (abr/2026), 1961-01-01 a 2025-12-31
# --------------------------------------------------------------------------
BRDWGD_VERSAO = "v_3.2.4"
BRDWGD_DRIVE = "https://drive.google.com/drive/folders/11-qnvwojirAtaQxSE03N0_SUrbcsz44N"
BRDWGD_VARS = ["Tmax", "Tmin", "RH", "pr"]
# A pasta do Drive só tem zips (README da pasta, lido em 02/10/2026).
# Zip diário -> variáveis que interessam dentro dele (ignora ETo, u2, Rs e os *_Control).
BRDWGD_ZIPS = {
    "pr_Tmax_Tmin_NetCDF_Files.zip": ["pr", "Tmax", "Tmin"],
    "ETo_u2_RH_Rs_NetCDF_Files.zip": ["RH"],
}

# --------------------------------------------------------------------------
# CAMS EAC4 (Copernicus/ECMWF) — PM2.5 a cada 3 h, para o E16 (sensibilidade)
# --------------------------------------------------------------------------
CAMS_DATASET = "cams-global-reanalysis-eac4"
CAMS_VAR = "particulate_matter_2.5um"
CAMS_AREA = [7, -75, -35, -31]   # N, W, S, E: Brasil + 1° de margem (inclui Fernando de Noronha)
