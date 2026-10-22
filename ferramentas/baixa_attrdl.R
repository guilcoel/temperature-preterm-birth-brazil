# baixa_attrdl.R — baixa a attrdl() de Gasparrini no commit fixado e confere tamanho, SHA-1 do blob do git e SHA-256.
#
# O attrdl.R não entra no git: o repositório de origem (gasparrini/2014_gasparrini_BMCmrm_Rcodedata) não tem licença.
# Este script é o caminho reprodutível para obtê-lo. A origem está em codigo_compartilhado/inst/terceiros/ORIGEM.md.
#
# - Baixa para um arquivo temporário e só grava no destino se tamanho e SHA-1 do blob baterem.
# - Se o destino já existir, não baixa: só confere.
# - Sai com 1 se algo não bater.
# - Usa só R base, mais o git e o shasum do sistema. Não lê a base de dados.
#
# Uso (da raiz de artigos_perinatais_clima/):  Rscript ferramentas/baixa_attrdl.R [destino]
#   sem argumento, o destino é codigo_compartilhado/inst/terceiros/attrdl.R

COMMIT <- "e629be7809853f390d305d8e73ac4b152a54f092"   # 2022-04-02, "Fix issue in attrdl with clogit"
URL <- paste0("https://raw.githubusercontent.com/gasparrini/2014_gasparrini_BMCmrm_Rcodedata/", COMMIT, "/attrdl.R")
TAMANHO <- 7411                                          # bytes, pela API do GitHub (git/trees do commit)
SHA1_BLOB <- "bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a"   # SHA-1 do blob no commit
SHA256 <- "d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d"   # do 1º download conferido, 2026-10-08
args <- commandArgs(trailingOnly = TRUE)                  # destino opcional, para testar o download fora do projeto
DESTINO <- if (length(args)) args[1] else "codigo_compartilhado/inst/terceiros/attrdl.R"

if (!file.exists("ferramentas/baixa_attrdl.R")) stop("rode da raiz de artigos_perinatais_clima/")

confere <- function(f) {
  tam <- file.size(f)
  sha1 <- system2("git", c("hash-object", "--no-filters", shQuote(f)), stdout = TRUE)
  sha256 <- sub(" .*", "", system2("shasum", c("-a", "256", shQuote(f)), stdout = TRUE))
  cat(sprintf("tamanho: %s bytes (esperado %d)\n", tam, TAMANHO))
  cat(sprintf("git hash-object: %s (esperado %s)\n", sha1, SHA1_BLOB))
  cat(sprintf("SHA-256: %s (esperado %s)\n", sha256, ifelse(is.na(SHA256), "ainda não registrado", SHA256)))
  ok <- isTRUE(tam == TAMANHO) && identical(sha1, SHA1_BLOB) && (is.na(SHA256) || identical(sha256, SHA256))
  cat("confere:", ok, "\n")
  ok
}

if (file.exists(DESTINO)) {
  cat("O destino já existe; só confiro:", DESTINO, "\n")
  quit(status = if (confere(DESTINO)) 0 else 1)
}
tmp <- tempfile(fileext = ".R")
cat("baixando:", URL, "\n")
st <- download.file(URL, tmp, mode = "wb", quiet = TRUE)
if (st != 0 || !confere(tmp)) {
  unlink(tmp)
  cat("NÃO CONFERE: nada foi gravado em", DESTINO, "\n")
  quit(status = 1)
}
stopifnot(file.copy(tmp, DESTINO, overwrite = FALSE))
unlink(tmp)
cat("gravado:", DESTINO, "\n")
quit(status = if (confere(DESTINO)) 0 else 1)
