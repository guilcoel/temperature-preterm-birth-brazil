# Q7 do questionamento de 07/10/2026: versão do R e dos pacotes de análise; procura renv.lock (não cria).
# Uso (da raiz do projeto): Rscript 00_scripts/testes/questionamento_20261007_ambiente.R
cat("R:", R.version.string, "\n")
for (p in c("dlnm", "gnm", "mixmeta", "mvmeta", "splines2", "gigs", "renv", "arrow")) {
  v <- tryCatch(as.character(packageVersion(p)), error = function(e) "não instalado")
  cat(sprintf("%-9s %s\n", p, v))
}
d <- tryCatch(packageDescription("gigs"), error = function(e) NULL)
if (!is.null(d)) for (f in c("RemoteSha", "RemoteUrl", "Repository", "Built")) if (!is.null(d[[f]])) cat("gigs", f, ":", d[[f]], "\n")
lock <- list.files("/Volumes/Forja/Doc", pattern = "^renv\\.lock$", recursive = TRUE, full.names = TRUE)
cat("renv.lock em /Volumes/Forja/Doc:", if (length(lock)) paste(lock, collapse = ", ") else "nenhum", "\n")
