# 39_auditoria_completa_fase2.R — Fase 2 do Artigo 1: autoauditoria completa, por código, do que foi publicado (Partes A, B
# e C), antes da Fase 3. Só lê; o único acesso à rede é um `git ls-remote` (leitura). Confere:
#   A. git e remoto: main remoto contém o 11ba434; tag ajusta_dlnm-v1.0 igual no remoto e no local, apontando para o
#      caf5022; tag do congelamento intacta; codigo_compartilhado/R/ no HEAD = tag; os 3 commits da Fase 2 só tocam
#      artigo1_prematuridade/ e codigo_compartilhado/; nenhum arquivo de dado rastreado;
#   B. SHA-256 da mensagem da tag = arquivos de R/ e de tests/ no disco;
#   C. baterias de novo: ajusta_dlnm 19/20 (só a falha conhecida do 5b, com a mesma mensagem) e offset 21/21;
#   D. Parte C reproduzida EXATAMENTE: os 26 ajustes refeitos com a função lida da tag (git show), comparados com a RDS
#      gravada pelo 32 por identical();
#   E. documentos: desvios 1–66 contínuos; SHA-256 citados nas auditorias e nos logs = arquivos atuais; RESPOSTAs A e C
#      com o SHA-256 informado e iguais ao commitado; scripts dos "comandos para reproduzir" existem; versao() 4443971b
#      no início e no fim dos logs da Fase 2;
#   F. ambiente: R 4.5.1, dlnm e gnm do renv.lock, BLAS/LAPACK de referência;
#   G. sigilo: nenhum padrão proibido nos arquivos commitados da Fase 2.
# Lê a série principal só para refazer os ajustes (D); nada de linha individual sai.
# Grava logs/auditoria_completa_fase2_<FASE2_DATA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE2_DATA=AAAAMMDD Rscript 00_scripts/39_auditoria_completa_fase2.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE2_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; CC <- file.path("..", "codigo_compartilhado")
arq <- file.path("logs", paste0("auditoria_completa_fase2_", hoje, ".md")); stopifnot(!file.exists(arq))
git <- function(...) suppressWarnings(system2("git", c("-C", REPO, ...), stdout = TRUE, stderr = FALSE))
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
sha_git <- function(ref, a) sub(" .*", "", system(paste0("git -C ", shQuote(REPO), " show ", shQuote(paste0(ref, ":", a)), " | shasum -a 256"), intern = TRUE))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
R <- list()
reg <- function(bloco, o_que, ok, detalhe = "") { R[[length(R) + 1]] <<- data.frame(Bloco = bloco, Conferência = o_que, Resultado = if (isTRUE(ok)) "ok" else "FALHOU",
                                                                                     Detalhe = detalhe, check.names = FALSE, stringsAsFactors = FALSE)
  if (!isTRUE(ok)) cat("FALHOU:", bloco, "|", o_que, "|", detalhe, "\n") }
C_A <- "caf5022f9a655877d8e3931dd3d02d7dce429fe5"; C_B <- "92565b90283a0adaf842e3f279ad0e698c264099"; C_C <- "11ba434edfaff406a6f8e184f6c2ac1a49919e46"
TAG <- "ajusta_dlnm-v1.0"; TAG_OBJ <- "344899ab4a8673f1ad9e7a8bdf53c4e17e51cd76"; TAG_SPEC <- "spec-v2.0.2-congelada-20261009"

# ------------------------------------------------------------------ A. git e remoto
log_msg("A. git e remoto")
lr <- git("ls-remote", "origin", "refs/heads/main", paste0("refs/tags/", TAG), paste0("refs/tags/", TAG, "^{}"), paste0("refs/tags/", TAG_SPEC))
rem <- setNames(sub("\t.*", "", lr), sub(".*\t", "", lr))
main_rem <- rem[["refs/heads/main"]]
desc <- identical(main_rem, C_C) || (length(git("cat-file", "-t", main_rem)) == 1 &&
                                     system2("git", c("-C", REPO, "merge-base", "--is-ancestor", C_C, main_rem)) == 0)
reg("A. git", "main remoto é o 11ba434 ou descende dele", desc, paste("main remoto:", substr(main_rem, 1, 7)))
reg("A. git", "tag ajusta_dlnm-v1.0: objeto igual no remoto e no local (344899ab…), apontando para o caf5022",
    identical(rem[[paste0("refs/tags/", TAG)]], TAG_OBJ) && identical(git("rev-parse", TAG), TAG_OBJ) &&
      identical(rem[[paste0("refs/tags/", TAG, "^{}")]], C_A) && identical(git("rev-parse", shQuote(paste0(TAG, "^{commit}"))), C_A))
reg("A. git", "tag do congelamento igual no remoto e no local", identical(rem[[paste0("refs/tags/", TAG_SPEC)]], git("rev-parse", TAG_SPEC)))
reg("A. git", "codigo_compartilhado/R/ no HEAD e no disco = tag", length(git("diff", "--name-only", TAG, "HEAD", "--", "codigo_compartilhado/R")) == 0 &&
      length(git("diff", "--name-only", TAG, "--", "codigo_compartilhado/R")) == 0)
toca <- unlist(lapply(c(C_A, C_B, C_C), function(c) git("show", "--name-only", "--format=", c)))
reg("A. git", "os 3 commits da Fase 2 só tocam artigo1_prematuridade/ e codigo_compartilhado/", all(grepl("^(artigo1_prematuridade|codigo_compartilhado)/", toca)),
    paste(length(toca), "arquivos"))
dados_git <- grep("\\.(rds|csv|parquet|dbc|rdata|rda|feather|xlsx?)$", git("ls-files", "artigo1_prematuridade", "codigo_compartilhado"), ignore.case = TRUE, value = TRUE)
reg("A. git", "nenhum arquivo de dado rastreado em artigo1_prematuridade/ ou codigo_compartilhado/", length(dados_git) == 0)
pend <- setdiff(git("status", "--porcelain", "--untracked-files=all", "--", "artigo1_prematuridade", "codigo_compartilhado"),
                "?? artigo1_prematuridade/00_scripts/39_auditoria_completa_fase2.R")
reg("A. git", "nada pendente em artigo1_prematuridade/ e codigo_compartilhado/ (fora este script)", length(pend) == 0, paste(pend, collapse = "; "))

# ------------------------------------------------------------------ B. mensagem da tag
log_msg("B. tag")
msg <- git("cat-file", "-p", TAG); lin <- grep("^[0-9a-f]{64}  codigo_compartilhado/", msg, value = TRUE)
ok_b <- vapply(lin, function(l) identical(sha(file.path(REPO, sub("^[0-9a-f]{64}  ", "", sub(" \\(vazio\\)$", "", l)))), substr(l, 1, 64)), TRUE)
reg("B. tag", "SHA-256 da mensagem da tag = arquivos de R/ e tests/ no disco", length(lin) == 8 && all(ok_b), paste(sum(ok_b), "de", length(lin)))

# ------------------------------------------------------------------ C. baterias
log_msg("C. baterias")
suppressPackageStartupMessages({ library(dlnm); library(gnm) })
source(file.path(CC, "tests", "roda_testes.R")); source(file.path(CC, "tests", "testa_ajusta_dlnm.R"))
source(file.path(CC, "tests", "testa_ajusta_dlnm_mc.R")); source(file.path(CC, "tests", "testa_offset.R"))
f <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = f); sys.source(file.path(CC, "tests", "gera_sintetico.R"), envir = f)
set.seed(20261001); .MC$bf <- f$base_fixa(100000); .MC$proj <- f$projeta_theta(.MC$bf); .MC$R <- 200L
tt <- rbind(roda_testes(f, testes_ajusta_dlnm), roda_testes(f, testes_ajusta_dlnm_mc))
fo <- new.env(); sys.source(file.path(CC, "R", "offset.R"), envir = fo); to <- roda_testes(fo, testes_offset)
reg("C. testes", "ajusta_dlnm 19/20, só o t05b, com a mensagem \"cobertura 0.985 fora de 0,92–0,98\"",
    sum(tt$ok) == 19 && nrow(tt) == 20 && identical(tt$teste[!tt$ok], "t05b_recuperacao_contagem_baixa") &&
      identical(tt$mensagem[!tt$ok], "cobertura 0.985 fora de 0,92–0,98"), sprintf("%d/%d", sum(tt$ok), nrow(tt)))
reg("C. testes", "offset 21/21", all(to$ok) && nrow(to) == 21, sprintf("%d/%d", sum(to$ok), nrow(to)))

# ------------------------------------------------------------------ D. Parte C reproduzida exatamente
log_msg("D. Parte C")
tf <- tempfile(fileext = ".R"); writeLines(system(paste0("git -C ", shQuote(REPO), " show ", shQuote(paste0(TAG, ":codigo_compartilhado/R/ajusta_dlnm.R"))), intern = TRUE), tf)
ft <- new.env(); sys.source(tf, envir = ft); unlink(tf)
rds <- readRDS(file.path("01_saidas", "fase2", "primeira_etapa_principal_fase2_20261010.rds"))$resultados
ref <- utils::read.csv(file.path("01_saidas", "fase1", "referencias_exposicao.csv"), colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]
s <- as.data.frame(readRDS(file.path("01_saidas", "fase1", "serie_ptb_principal.rds")))
s <- s[s$data >= as.Date("2012-04-07") & s$data <= as.Date("2024-08-06"), ]
campos <- c("coef_cb", "vcov_cb", "gama", "ep_gama", "phi", "qaic", "pacf", "boundary_knots", "n")
iguais <- vapply(names(rds), function(cd) {
  x <- s[s$recorte_principal == cd, ]; x <- x[order(x$data), ]; rownames(x) <- NULL; rr <- ref[ref$recorte_principal == cd, ]
  sp <- ft$spec_agudo("ptb", "tmean_nucleo", "janela_principal", 7, argvar = list(fun = "ns", knots = c(rr$p10, rr$p75, rr$p90)),
                      arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE), offset = "z_w_gama", cen = rr$p50)
  r <- ft$ajusta_dlnm(x, sp); g <- rds[[cd]]$principal
  all(vapply(campos, function(k) identical(r[[k]], g[[k]]), TRUE)) && identical(r$reduzida$coef, g$reduzida$coef) && identical(r$reduzida$vcov, g$reduzida$vcov)
}, TRUE)
reg("D. Parte C", "os 26 ajustes refeitos com a função da tag são idênticos (identical) aos da RDS do 32", length(iguais) == 26 && all(iguais), paste(sum(iguais), "de", length(iguais)))
rm(s); invisible(gc())

# ------------------------------------------------------------------ E. documentos
log_msg("E. documentos")
dev <- readLines(file.path("logs", "desvios_especificacao.md"), encoding = "UTF-8")
nd <- as.integer(sub("^\\| ([0-9]+) \\|.*", "\\1", grep("^\\| [0-9]+ \\|", dev, value = TRUE)))
reg("E. desvios", "numeração contínua de 1 ao último, sem repetição", identical(nd, seq_len(max(nd))), paste("1 a", max(nd)))
cel <- vapply(grep("^\\| (5[1-9]|6[0-9]) \\|", dev, value = TRUE), function(l) length(strsplit(l, " | ", fixed = TRUE)[[1]]), 0)
reg("E. desvios", "linhas 51 em diante com as 9 colunas", all(cel >= 9), paste(length(cel), "linhas"))
ler <- function(p) paste(readLines(p, encoding = "UTF-8"), collapse = "\n")
cita <- list(
  c("logs/auditoria_fase2A_20261010.md", "logs/testes_ajusta_dlnm_fase2_20261010.md"), c("logs/auditoria_fase2A_20261010.md", "logs/diagnostico_t05b_fase2_20261010.md"),
  c("logs/auditoria_fase2A_20261010.md", "logs/autoauditoria_fase2A_20261010.md"), c("logs/auditoria_fase2B_20261010.md", "logs/testes_tag_fase2B_20261010.md"),
  c("logs/auditoria_fase2C_20261010.md", "logs/primeira_etapa_fase2_20261010.md"), c("logs/auditoria_fase2C_20261010.md", "logs/autoauditoria_fase2C_20261010.md"))
ok_e <- vapply(cita, function(x) grepl(sha(x[2]), ler(x[1]), fixed = TRUE), TRUE)
reg("E. SHA citados", "SHA-256 dos logs que valem, citados nas auditorias A, B e C = arquivos atuais", all(ok_e), paste(sum(ok_e), "de", length(ok_e)))
saidas <- list.files(file.path("01_saidas", "fase2"), pattern = "_fase2_20261010\\.(rds|csv)$", full.names = TRUE)
L32 <- ler(file.path("logs", "primeira_etapa_fase2_20261010.md"))
reg("E. SHA citados", "SHA-256 das 5 saídas da Parte C = os do log do 32", length(saidas) == 5 && all(vapply(saidas, function(p) grepl(sprintf("`%s`: `%s`", p, sha(p)), L32, fixed = TRUE), TRUE)))
resp <- c(RESPOSTA_artigo1_prematuridade_FASE2A_20261010.md = "7f2398eebfd7048fecd102fff386086e7e26e3c7274f390d437f01ddc2fc9763",
          RESPOSTA_artigo1_prematuridade_FASE2C_20261010.md = "9e9d11f2ffd06715da5d65eed6e6d9bb1c576253afeb439dd2ba7e877f45d1cd")
reg("E. RESPOSTAs", "SHA-256 das RESPOSTAs A e C = os informados, e o disco = o commitado (HEAD)",
    all(vapply(names(resp), function(p) identical(sha(p), resp[[p]]) && identical(sha_git("HEAD", file.path("artigo1_prematuridade", p)), resp[[p]]), TRUE)))
secao_cmd <- function(p) { x <- readLines(p, encoding = "UTF-8"); i <- grep("^## [0-9]+\\. Comandos para reproduzir", x); j <- grep("^## ", x); j <- j[j > i][1]; paste(x[i:(j - 1)], collapse = "\n") }
txt_cmd <- paste(vapply(names(resp), secao_cmd, ""), collapse = "\n")       # só a seção de comandos (a do git status lista scripts de outros artigos)
cmd <- unique(unlist(regmatches(txt_cmd, gregexpr("00_scripts/[0-9]{2}_[a-z0-9_]+\\.R", txt_cmd))))
reg("E. RESPOSTAs", "os scripts da seção \"Comandos para reproduzir\" das RESPOSTAs existem", all(file.exists(cmd)), paste(length(cmd), "scripts"))
logs2 <- c(list.files("logs", pattern = "_fase2_20261010\\.md$", full.names = TRUE), file.path("logs", c("testes_tag_fase2B_20261010.md", "autoauditoria_fase2A_20261010.md", "autoauditoria_fase2C_20261010.md")))
v_ok <- vapply(logs2, function(p) { x <- ler(p); grepl("no início = 4443971b", x, fixed = TRUE) && grepl("no fim: 4443971b", x, fixed = TRUE) }, TRUE)
reg("E. logs", "versao() 4443971b no início e no fim dos logs gerados por script na Fase 2", all(v_ok), paste(sum(v_ok), "de", length(v_ok)))

# ------------------------------------------------------------------ F. ambiente
log_msg("F. ambiente")
si <- sessionInfo()
lock <- paste(readLines("renv.lock", warn = FALSE), collapse = "\n")
ver_lock <- function(p) sub(".*\"Version\": \"([^\"]+)\".*", "\\1", regmatches(lock, regexpr(paste0("\"", p, "\": \\{[^}]*\"Version\": \"[^\"]+\""), lock)))
reg("F. ambiente", "R 4.5.1; dlnm e gnm iguais aos do renv.lock; BLAS/LAPACK de referência",
    identical(paste(R.version$major, R.version$minor, sep = "."), "4.5.1") && identical(as.character(packageVersion("dlnm")), ver_lock("dlnm")) &&
      identical(gsub("-", ".", ver_lock("gnm")), as.character(packageVersion("gnm"))) &&
      basename(si$BLAS) == "libRblas.0.dylib" && basename(si$LAPACK) == "libRlapack.dylib",
    sprintf("dlnm %s (lock %s); gnm %s (lock %s)", packageVersion("dlnm"), ver_lock("dlnm"), packageVersion("gnm"), ver_lock("gnm")))

# ------------------------------------------------------------------ G. sigilo
log_msg("G. sigilo")
fase2_arqs <- unique(toca[file.exists(file.path(REPO, toca))])
proib <- "id_nasc|nascimentos\\(|obitos\\(|GITHUB_PAT|ghp_[A-Za-z0-9]|token *=|senha *="
hit <- fase2_arqs[vapply(fase2_arqs, function(a) { x <- readLines(file.path(REPO, a), warn = FALSE, encoding = "UTF-8")
  if (grepl("desvios_especificacao\\.md$", a)) x <- grep("^\\| ([5-9][0-9]|[1-9][0-9]{2}) \\|", x, value = TRUE)   # só as linhas da Fase 2 (51 em diante)
  x <- x[!grepl("^\\s*#", x) & !grepl("proib <-", x, fixed = TRUE)]; any(grepl(proib, x)) }, TRUE)]
reg("G. sigilo", "nenhum padrão proibido (id_nasc, microdado, token, senha) nos arquivos commitados da Fase 2", length(hit) == 0, paste(hit, collapse = "; "))
grandes <- fase2_arqs[file.size(file.path(REPO, fase2_arqs)) > 1e6]
reg("G. sigilo", "nenhum arquivo commitado da Fase 2 acima de 1 MB", length(grandes) == 0, paste(length(fase2_arqs), "arquivos"))

stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
res <- do.call(rbind, R); n_ok <- sum(res$Resultado == "ok")
md <- c("# Fase 2 do Artigo 1: autoauditoria completa por código (Partes A, B e C publicadas)", "",
        sprintf("- **Gerado por:** `00_scripts/39_auditoria_completa_fase2.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        sprintf("- **Ambiente:** R %s; dlnm %s; gnm %s. BLAS/LAPACK: `%s` / `%s`.", paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"),
                packageVersion("gnm"), si$BLAS, si$LAPACK),
        sprintf("- **HEAD local:** `%s`. **main remoto** (ls-remote): `%s`.", git("rev-parse", "HEAD"), main_rem),
        "- **1ª rodada deste script** (log SHA-256 `f8fff13cf67ed971e151da86137c76b847b28d97e1ddbc5438be33b093fc332d`, na lixeira): 19 de 21, com 2 falsos positivos da própria checagem. (i) Os \"scripts que não existem\" eram scripts dos Artigos 2 e 3 listados na seção `git status` das RESPOSTAs; a checagem passou a ler só a seção \"Comandos para reproduzir\". (ii) O \"padrão proibido\" no log de desvios eram menções ao nome da função `nascimentos()` e da coluna `id_nasc` nos desvios 2, 4, 10 e 45 (Fases 0 e 1), nomes e não dados; a varredura desse arquivo passou a cobrir só as linhas da Fase 2 (51 em diante).",
        "- **Escopo:** git e remoto, tag, baterias de teste, reprodução exata da Parte C, coerência dos SHA-256 citados, desvios, ambiente e sigilo. Só leitura; o único acesso à rede foi um `git ls-remote`.", "",
        sprintf("## Resultado: %d de %d conferências ok", n_ok, nrow(res)), "",
        tabela_md(res), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "|", n_ok, "de", nrow(res), "ok\n")
if (n_ok < nrow(res)) quit(status = 1)
