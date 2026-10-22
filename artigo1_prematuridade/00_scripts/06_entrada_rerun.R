# 06_entrada_rerun.R — Fase 0 refeita (base 4443971b), A0: conferências de entrada. Só leitura; não instala nada.
#
#   A0.1 base: versao() = 4443971b com o renv do artigo ativo; HEAD da base = 2ef7f67; nada pendente nos rastreados;
#        não rastreados listados à parte; RESPOSTA_BASE_ig_dum_sem localizado pelo git ls-files e SHA-256 conferido;
#   A0.2 interface: git diff --stat 9f1957b 2ef7f67 -- 09_acesso/; SHA-256 do acesso.R; renv::dependencies() do
#        acesso.R igual à lista da Fase 0A (arrow, dplyr, jsonlite, tools; logs/ambiente_fase0_20261008.md);
#   A0.3 ambiente: renv::status() sem pendência; versões da §8 iguais às encontradas na Fase 0A (mesmo log) e o
#        RemoteSha do gigs.
# Grava logs/entrada_fase0_rerun_<FASE0_RERUN_DATA>.md (nunca sobrescreve). Sai com 1 se alguma conferência falhar.
# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=20261009 Rscript 00_scripts/06_entrada_rerun.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
BASE <- "/Volumes/Forja/Doc/dados_artigos_perinatais_clima"
source(file.path(BASE, "09_acesso/acesso.R")); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
RODADA <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", RODADA))
arq <- file.path("logs", paste0("entrada_fase0_rerun_", RODADA, ".md")); stopifnot(!file.exists(arq))

res <- data.frame()
confere <- function(item, conferencia, esperado, obtido, ok)
  res <<- rbind(res, data.frame(item = item, conferencia = conferencia, esperado = as.character(esperado),
                                obtido = as.character(obtido), ok = isTRUE(ok), stringsAsFactors = FALSE))
git <- function(...) suppressWarnings(system2("git", c("-C", BASE, ...), stdout = TRUE, stderr = TRUE))
sha256 <- function(f) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(f)), stdout = TRUE))

# A0.1
confere("A0.1", "versao() com o renv do artigo ativo", "4443971b", v_ini, v_ini == "4443971b")
confere("A0.1", "renv ativo (biblioteca do projeto)", "artigo1_prematuridade/renv/library", .libPaths()[1],
        grepl("artigo1_prematuridade/renv/library", .libPaths()[1], fixed = TRUE))
head_b <- git("rev-parse", "--short", "HEAD")
confere("A0.1", "git rev-parse --short HEAD da base", "2ef7f67", head_b, identical(head_b, "2ef7f67"))
pend <- git("status", "--porcelain", "--untracked-files=no")
confere("A0.1", "git status --porcelain --untracked-files=no da base (vazio)", "vazio",
        if (length(pend)) paste(pend, collapse = "; ") else "vazio", length(pend) == 0)
nao_rastr <- sub("^\\?\\? ", "", grep("^\\?\\?", git("status", "--porcelain"), value = TRUE))
resp <- grep("RESPOSTA_BASE_ig_dum_sem", git("ls-files"), value = TRUE)
sha_resp <- if (length(resp) == 1) sha256(file.path(BASE, resp)) else NA
confere("A0.1", "RESPOSTA da base localizado pelo git ls-files", "1 arquivo", paste(resp, collapse = "; "), length(resp) == 1)
confere("A0.1", "SHA-256 do RESPOSTA da base", "5374778d7276a8f8f95507fab2981068157b5bedb60177c5715627850d2b6961", sha_resp,
        identical(sha_resp, "5374778d7276a8f8f95507fab2981068157b5bedb60177c5715627850d2b6961"))

# A0.2
dstat <- git("diff", "--stat", "9f1957b", "2ef7f67", "--", "09_acesso/")
mudou <- trimws(sub("\\|.*", "", grep("\\|", dstat, value = TRUE)))
confere("A0.2", "acesso.R fora do diff 9f1957b..2ef7f67 em 09_acesso/ (não mudou)", "não está no diff",
        paste(mudou, collapse = ", "), !"09_acesso/acesso.R" %in% mudou)
sha_acesso <- sha256(file.path(BASE, "09_acesso/acesso.R"))
deps <- sort(unique(renv::dependencies(file.path(BASE, "09_acesso/acesso.R"), progress = FALSE, quiet = TRUE)$Package))
amb0 <- readLines("logs/ambiente_fase0_20261008.md", encoding = "UTF-8")
dep0 <- sort(trimws(strsplit(sub(".*`renv::dependencies`\\):\\*\\* *(.*)\\.$", "\\1",
                                 grep("Dependências do `acesso.R`", amb0, value = TRUE)), ",")[[1]]))
confere("A0.2", "renv::dependencies() do acesso.R = lista da Fase 0A (sem pacote novo)", paste(dep0, collapse = ", "),
        paste(deps, collapse = ", "), identical(deps, dep0))

# A0.3
st_txt <- capture.output(st <- renv::status())
confere("A0.3", "renv::status() sem pendência", "synchronized = TRUE", paste0("synchronized = ", isTRUE(st$synchronized)),
        isTRUE(st$synchronized))
linhas0 <- grep("^\\| [A-Za-z]", amb0, value = TRUE)
linhas0 <- linhas0[!grepl("^\\| Pacote", linhas0)]
cel <- strsplit(linhas0, "\\|")
fase0 <- setNames(trimws(vapply(cel, `[`, "", 4)), trimws(vapply(cel, `[`, "", 2)))
fase0 <- fase0[c("R", "dlnm", "gnm", "mixmeta", "mvmeta", "renv", "gigs", "arrow")]
agora <- vapply(names(fase0), function(p) if (p == "R") paste(R.version$major, R.version$minor, sep = ".") else
  tryCatch(as.character(packageVersion(p)), error = function(e) "não instalado"), "")
for (p in names(fase0)) confere("A0.3", paste("versão de", p, "= Fase 0A"), fase0[[p]], agora[[p]], identical(fase0[[p]], agora[[p]]))
sha_gigs <- tryCatch(packageDescription("gigs")$RemoteSha, error = function(e) NA)
confere("A0.3", "gigs RemoteSha", "fb58fe6596d4b289d5362c5efe00f882984d3186", sha_gigs,
        identical(sha_gigs, "fb58fe6596d4b289d5362c5efe00f882984d3186"))

stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
confere("A0", "versao() no fim", "4443971b", v_fim, v_fim == "4443971b")
md <- c("# A0: conferências de entrada da Fase 0 refeita (base 4443971b)", "",
        sprintf("- **Gerado por:** `00_scripts/06_entrada_rerun.R`, em %s. Rodada `%s`. `versao()` no início = %s e no fim = %s.",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), RODADA, v_ini, v_fim),
        "- **Ordem:** a A1 (inventário e `.tar`, sem R) rodou antes desta A0; nenhuma edição foi feita antes dela.",
        sprintf("- **Resultado:** %d de %d conferências ok.", sum(res$ok), nrow(res)), "",
        "| Item | Conferência | Esperado | Obtido | Ok |", "|---|---|---|---|---|",
        sprintf("| %s | %s | %s | %s | %s |", res$item, res$conferencia, res$esperado, res$obtido, ifelse(res$ok, "sim", "**NÃO**")), "",
        sprintf("- **Caminho do RESPOSTA da base:** `%s/%s`.", BASE, resp),
        sprintf("- **SHA-256 do `09_acesso/acesso.R`:** `%s`.", sha_acesso),
        sprintf("- **Não rastreados na base** (não fazem parar): %s.", if (length(nao_rastr)) paste0("`", nao_rastr, "`", collapse = ", ") else "nenhum"), "",
        "## `git -C <base> diff --stat 9f1957b 2ef7f67 -- 09_acesso/`", "", "```", dstat, "```", "",
        "## `renv::status()`", "", "```", st_txt, "```")
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "\n")
print(res[, c("item", "conferencia", "obtido", "ok")], row.names = FALSE, right = FALSE)
if (!all(res$ok)) { cat("CONFERÊNCIA DE ENTRADA FALHOU: parar e reportar.\n"); quit(status = 1) }
