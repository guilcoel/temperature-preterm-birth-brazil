# 00_dependencias.R — Fase 0, A3.5: pacotes do Artigo 1, para o renv descobrir e travar no renv.lock.
# Não roda análise; só carrega os pacotes. Inclui todas as dependências do acesso.R da base
# (renv::dependencies em 08/10/2026: arrow, dplyr, jsonlite, tools).
#
# Uso (de artigo1_prematuridade/):  Rscript 00_scripts/00_dependencias.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
cat("versao() no início:", versao(), "\n")

library(dlnm)      # cross-basis, crossreduce (especificação §1, §6)
library(gnm)       # quasi-Poisson condicional (§2.1)
library(mixmeta)   # meta-análise da 2ª etapa (§6)
library(mvmeta)    # referência (§8)
library(splines)   # ns()
library(tsModel)   # tsModel:::Lag, usado pela attrdl (§7)
library(arrow)     # leitura dos parquet pela interface
library(gigs)      # INTERGROWTH-21st (classes do PIG já vêm da base; §8)
library(dplyr)     # manipulação; dependência do acesso.R
library(jsonlite)  # dependência do acesso.R
library(tools)     # dependência do acesso.R (md5sum)

cat("pacotes carregados:", paste(c("dlnm", "gnm", "mixmeta", "mvmeta", "splines", "tsModel", "arrow", "gigs",
                                   "dplyr", "jsonlite", "tools"), collapse = ", "), "\n")
stopifnot(versao() == "4443971b")
cat("versao() no fim:", versao(), "\n")
