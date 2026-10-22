# 00_ambiente.R — Fase 0, A3 (itens 1 a 3): registra o ambiente R e confere as versões esperadas.
# Especificação v2.0.2, §8. Não instala nem atualiza nada; só lê o que está instalado.
#
# Grava:
#   logs/sessionInfo_rerun_<FASE0_RERUN_DATA>.txt  sessionInfo(), extSoftVersion(), La_version() e La_library()
#   logs/ambiente_fase0_rerun_<FASE0_RERUN_DATA>.md  tabela pacote → versão esperada → versão encontrada, BLAS e dependências do acesso.R
# Fase 0 refeita (base 4443971b): nomes com _rerun_ e a data fixa da rodada; nunca sobrescreve (a Fase 0A fica como registro).
# Para (exit 1) se alguma versão divergir.
#
# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/00_ambiente.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")

hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
dir.create("logs", showWarnings = FALSE)
arq <- file.path("logs", paste0("sessionInfo_rerun_", hoje, ".txt")); stopifnot(!file.exists(arq))
arq_md <- file.path("logs", paste0("ambiente_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq_md))
sink(arq)
cat("# sessionInfo — artigo1_prematuridade — ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n\n", sep = "")
print(sessionInfo())
cat("\n# extSoftVersion()\n"); print(extSoftVersion())
cat("\n# La_version()\n"); print(La_version())
cat("\n# La_library()\n"); print(La_library())
sink()
cat("gravado:", arq, "\n")

# versões esperadas (especificação v2.0.2, §8; prompt da Fase 0, A3.2). gnm 1.1-5 no CRAN = 1.1.5 em packageVersion()
esperado <- c(R = "4.5.1", dlnm = "2.4.10", gnm = "1.1.5", mixmeta = "1.2.0", mvmeta = "1.0.3",
              renv = "1.2.4", gigs = "0.5.2.9000", arrow = "21.0.0.1")
versao_de <- function(p) if (p == "R") paste(R.version$major, R.version$minor, sep = ".") else
  tryCatch(as.character(packageVersion(p)), error = function(e) "não instalado")
tab <- data.frame(pacote = names(esperado), esperada = unname(esperado),
                  encontrada = vapply(names(esperado), versao_de, ""), row.names = NULL)
tab$confere <- tab$esperada == tab$encontrada
print(tab, row.names = FALSE)

sha_gigs <- tryCatch(packageDescription("gigs")$RemoteSha, error = function(e) NA)
sha_ok <- identical(sha_gigs, "fb58fe6596d4b289d5362c5efe00f882984d3186")
cat("gigs RemoteSha:", sha_gigs, "| confere:", sha_ok, "\n")
cat("tsModel (A3.3; já instalado, só registro):", versao_de("tsModel"), "\n")

blas <- sessionInfo()$BLAS
cat("BLAS:", blas, "\n")
cat("LAPACK:", La_library(), "\n")
cat("BLAS de referência do R (libRblas):", grepl("libRblas", blas), "\n")

# log em markdown (vai para o git): versões, R de compilação de cada binário, BLAS e dependências do acesso.R
compilado <- function(p) if (p == "R") "—" else
  tryCatch(sub(";.*", "", packageDescription(p)$Built), error = function(e) "—")
extra <- c("tsModel", "dplyr", "jsonlite", "splines", "tools")
dep_acesso <- tryCatch(sort(unique(renv::dependencies("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R",
                                                      progress = FALSE, quiet = TRUE)$Package)),
                       error = function(e) paste("erro:", conditionMessage(e)))
md <- c("# A3: ambiente R do Artigo 1", "",
        sprintf("- **Gerado por:** `00_scripts/00_ambiente.R`, em %s. `versao()` no início = %s (o fim está na última linha).", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), v_ini),
        sprintf("- **Biblioteca em uso:** `%s`.", .libPaths()[1]),
        sprintf("- **`sessionInfo()` completo:** `%s`.", arq), "",
        "| Pacote | Versão esperada (§8) | Versão encontrada | Confere | Compilado em |", "|---|---|---|---|---|",
        sprintf("| %s | %s | %s | %s | %s |", tab$pacote, tab$esperada, tab$encontrada, ifelse(tab$confere, "sim", "**NÃO**"),
                vapply(tab$pacote, compilado, "")),
        sprintf("| %s | — | %s | — | %s |", extra, vapply(extra, versao_de, ""), vapply(extra, compilado, "")), "",
        sprintf("- **`gigs` RemoteSha:** `%s` (confere com `fb58fe6596d4b289d5362c5efe00f882984d3186`: %s).", sha_gigs, ifelse(sha_ok, "sim", "**NÃO**")),
        sprintf("- **BLAS:** `%s` (BLAS de referência do R: %s).", blas, ifelse(grepl("libRblas", blas), "sim", "**NÃO**")),
        sprintf("- **LAPACK:** `%s`, versão %s.", La_library(), La_version()),
        sprintf("- **Dependências do `acesso.R` (`renv::dependencies`):** %s.", paste(dep_acesso, collapse = ", ")))
stopifnot(versao() == "4443971b")
cat("versao() no fim:", versao(), "\n")
md <- c(md, "", sprintf("`versao()` no fim: %s.", versao()))
writeLines(md, arq_md, useBytes = TRUE)
cat("gravado:", arq_md, "\n")
if (!all(tab$confere) || !sha_ok) {
  cat("DIVERGÊNCIA de versão: parar e reportar.\n")
  quit(status = 1)
}
