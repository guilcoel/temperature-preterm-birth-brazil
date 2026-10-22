# 55_testes_v101.R — testes da segunda_etapa v1.0.1, só de testes (D6, item 2 e 3.4; entrada 86), no modelo do 44.
# Roda, sem mudar o codigo_compartilhado/R/segunda_etapa.R (igual ao da tag segunda_etapa-v1.0):
#   - os testes rápidos de testa_segunda_etapa.R (todos, inclusive os que pedem o .R3 real e a attrdl, como o 44; sem o
#     Monte Carlo de testa_segunda_etapa_mc.R, que não entra na v1.0.1);
#   - os testes novos de testa_segunda_etapa_d6.R (teste 3 da D2 com fonte independente, variante S1, Wald com seleção
#     exata e receita do Q por coeficiente);
#   - 3 mutantes, cada um numa cópia do segunda_etapa.R (nunca no arquivo), que um teste rápido tem de matar.
# Confere antes: nada pendente em artigo1_prematuridade/ e codigo_compartilhado/ além dos arquivos novos desta rodada; o
# segunda_etapa.R, o ajusta_dlnm.R e o offset.R no disco iguais aos do commit 410dd6d (tag segunda_etapa-v1.0).
# Dados reais só como no 41 e no 44 (atributos, exposição, percentis, metapreditores e vcov como covariâncias).
# Semente 20261001. Grava logs/testes_v101_<RODADA>.md. Nunca sobrescreve. Numa falha, sai com quit(status = 1) (83(a4)).
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/55_testes_v101.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("testes_v101_", rodada, ".md")); stopifnot(!file.exists(arq))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
novos <- c("?? artigo1_prematuridade/00_scripts/55_testes_v101.R", "?? codigo_compartilhado/tests/teste3_fonte_independente.R",
           "?? codigo_compartilhado/tests/testa_segunda_etapa_d6.R", " M codigo_compartilhado/tests/testa_segunda_etapa.R")
pend <- setdiff(git("status", "--porcelain", "--untracked-files=all", "--", "artigo1_prematuridade", "codigo_compartilhado"), novos)
if (length(pend)) { cat("pendentes:", pend, sep = "\n"); stop("há arquivo pendente em artigo1_prematuridade/ ou codigo_compartilhado/ fora dos desta rodada") }
TAG <- "segunda_etapa-v1.0"; COMMIT_TAG <- "410dd6d6d3d315004f22fd7197c326de77f3c2f4"
if (!identical(git("rev-parse", paste0(TAG, "^{commit}")), COMMIT_TAG)) stop("tag ", TAG, " fora do commit esperado")
cod_R <- c("codigo_compartilhado/R/segunda_etapa.R", "codigo_compartilhado/R/ajusta_dlnm.R", "codigo_compartilhado/R/offset.R")
if (length(git("diff", "--name-only", COMMIT_TAG, "--", cod_R))) stop("segunda_etapa.R, ajusta_dlnm.R ou offset.R diferem do 410dd6d")
head_c <- git("rev-parse", "HEAD"); head_s <- git("log", "-1", shQuote("--format=%h %s")); stopifnot(length(head_s) == 1L)
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta) })
CC <- file.path("..", "codigo_compartilhado")
f_se <- file.path(CC, "R", "segunda_etapa.R"); f_aj <- file.path(CC, "R", "ajusta_dlnm.R")
f_tr <- file.path(CC, "tests", "testa_segunda_etapa.R"); f_t6 <- file.path(CC, "tests", "testa_segunda_etapa_d6.R")
f_t3 <- file.path(CC, "tests", "teste3_fonte_independente.R"); f_run <- file.path(CC, "tests", "roda_testes.R")
f_at <- file.path(CC, "inst", "terceiros", "attrdl.R"); SHA_ATTRDL <- "d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d"
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
if (!identical(sha(f_at), SHA_ATTRDL)) stop("attrdl.R com SHA-256 diferente do registrado")
sha_se <- sha(f_se)

# ------------------------------------------------------------------ entradas e .R3 (como no 41 e no 44)
ENT <- c(rds2 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", ref = "01_saidas/fase1/referencias_exposicao.csv",
         ser1 = "01_saidas/fase1/serie_ptb_principal.rds", a0 = "01_saidas/fase3/percentis_exposicao_fase3_20261013.csv")
SHA_ENT <- c(rds2 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d", ref = "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467",
             ser1 = "635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917")
sha_ent <- vapply(ENT, sha, "")
if (!identical(sha_ent[names(SHA_ENT)], SHA_ENT)) stop("entrada com SHA-256 diferente do registrado")
L41 <- paste(readLines(file.path("logs", "testes_segunda_etapa_fase3_20261013.md"), encoding = "UTF-8"), collapse = "\n")
if (!grepl(sprintf("`%s`: `%s`", ENT[["a0"]], sha_ent[["a0"]]), L41, fixed = TRUE)) stop("grade da A0 com SHA-256 diferente da usada no 41")
source(f_run); source(f_tr); source(f_t3); source(f_t6)
carrega <- function(arquivo_se) { e <- new.env(); sys.source(f_aj, envir = e); sys.source(arquivo_se, envir = e); e }
f0 <- carrega(f_se); ordem <- f0$ORDEM_CONCENTRACOES
nuc <- as.data.frame(cidade_nucleo()); f0$confere_ordem(nuc$CD_RECORTE); .R3$codigos <- nuc$CD_RECORTE
rds <- readRDS(ENT[["rds2"]])$resultados
.R3$argvar <- lapply(ordem, function(r) rds[[r]]$principal$base$argvar); .R3$arglag <- lapply(ordem, function(r) rds[[r]]$principal$base$arglag)
.R3$S <- lapply(ordem, function(r) rds[[r]]$principal$reduzida$vcov); rm(rds)
s <- readRDS(ENT[["ser1"]]); s <- s[s$data >= as.Date("2012-04-07") & s$data <= as.Date("2024-08-06"), c("recorte_principal", "data", "tmean_nucleo")]
.R3$x <- lapply(ordem, function(r) { z <- s[s$recorte_principal == r, ]; stopifnot(nrow(z) == 4505); z$tmean_nucleo[order(z$data)] }); rm(s)
gr <- utils::read.csv(ENT[["a0"]], colClasses = c(recorte_principal = "character"))
.R3$grade <- t(vapply(ordem, function(r) { z <- gr[gr$recorte_principal == r, ]; setNames(z$valor, z$rotulo) }, numeric(101)))
ez <- gr[gr$recorte_principal == "eixo_medio", ]; .R3$eixo <- setNames(ez$valor, ez$rotulo)
ref <- utils::read.csv(ENT[["ref"]], colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ordem, ref$recorte_principal), ]; stopifnot(identical(ref$recorte_principal, ordem))
.R3$nos_csv <- as.matrix(ref[, c("p10", "p75", "p90")]); .R3$metapred <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1)
.R3$attrdl_path <- f_at; .R3$attrdl <- f0$carrega_attrdl(f_at, SHA_ATTRDL); .R3$R_mc <- 1000L

# ------------------------------------------------------------------ bateria
bateria <- function(f) rbind(cbind(arquivo = "testa_segunda_etapa.R", roda_testes(f, testes_segunda_etapa)),
                             cbind(arquivo = "testa_segunda_etapa_d6.R", roda_testes(f, testes_segunda_etapa_d6)))
log_msg("bateria no original"); r0 <- bateria(f0); print(r0[, c("arquivo", "teste", "ok")], row.names = FALSE)

# ------------------------------------------------------------------ mutantes (cópias do segunda_etapa.R)
src <- paste0(paste(readLines(f_se, encoding = "UTF-8"), collapse = "\n"), "\n")
mutantes <- list(
  list(".base_x sem os Boundary.knots da argvar", ".base_x <- function(x, argvar) unclass(do.call(dlnm::onebasis, c(list(x = x), argvar)))",
       ".base_x <- function(x, argvar) unclass(do.call(dlnm::onebasis, c(list(x = x), argvar[names(argvar) != \"Boundary.knots\"])))"),
  list("seleção do Wald por grep de substring", "ind <- which(sub(\"^[^.]*\\\\.\", \"\", names(stats::coef(fit))) == t)",
       "ind <- grep(t, names(stats::coef(fit)))"),
  list("curva() com os knots da argvar multiplicados por 1,001", "B <- .base_x(x, argvar); Bc <- .base_x(cen, argvar)",
       "argvar$knots <- argvar$knots * 1.001; B <- .base_x(x, argvar); Bc <- .base_x(cen, argvar)"))
res_mut <- do.call(rbind, lapply(mutantes, function(m) {
  if (lengths(regmatches(src, gregexpr(m[[2]], src, fixed = TRUE))) != 1) stop("texto do mutante sem exatamente uma ocorrência: ", m[[1]])
  tf <- file.path(tempdir(), "segunda_etapa_mutante.R"); writeLines(sub(m[[2]], m[[3]], src, fixed = TRUE), tf, useBytes = TRUE)
  log_msg("mutante:", m[[1]]); rr <- bateria(carrega(tf)); unlink(tf)
  stopifnot(identical(rr$teste, r0$teste)); caem <- rr$teste[!rr$ok & r0$ok]
  data.frame(Mutante = m[[1]], `Testes que caem (dos que passam no original)` = length(caem), Quais = if (length(caem)) paste(caem, collapse = ", ") else "nenhum",
             check.names = FALSE, stringsAsFactors = FALSE) }))
if (!identical(sha(f_se), sha_se)) stop("segunda_etapa.R mudou durante a rodada")
ok <- all(r0$ok) && all(res_mut[[2]] >= 1)
todos_arq <- git("ls-files", "--others", "--cached", "--exclude-standard", "--", "codigo_compartilhado/R", "codigo_compartilhado/tests")
sha_todos <- vapply(todos_arq, function(a) sha(file.path("..", a)), "")

# ------------------------------------------------------------------ log
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
s_info <- sessionInfo()
md <- c("# segunda_etapa v1.0.1, só de testes: testes e mutantes (D6, item 2 e 3.4; entrada 86)", "",
  sprintf("- **Gerado por:** `00_scripts/55_testes_v101.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), rodada, v_ini),
  sprintf("- **Ambiente:** R %s; dlnm %s; gnm %s; mixmeta %s. BLAS/LAPACK: `%s` / `%s`. Semente 20261001 (Mersenne-Twister, Inversion, Rejection).",
          paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("gnm"), packageVersion("mixmeta"), s_info$BLAS, s_info$LAPACK),
  sprintf("- **HEAD no disco:** `%s` (%s). Pendentes, só os desta rodada: os dois arquivos novos de `codigo_compartilhado/tests/`, a mudança de comentário em `testa_segunda_etapa.R` e este script.", head_c, head_s),
  sprintf("- **Código sem mudança:** `segunda_etapa.R`, `ajusta_dlnm.R` e `offset.R` no disco iguais aos do commit `%s` (tag `%s`; `git diff` vazio). `attrdl.R` conferido.", COMMIT_TAG, TAG),
  "- **Entradas (SHA-256), usadas só como no 41 e no 44:**", sprintf("  - `%s`: `%s`;", ENT, sha_ent),
  "- **Fora desta bateria:** o Monte Carlo de `testa_segunda_etapa_mc.R` (1.000 réplicas), que não muda na v1.0.1.", "",
  sprintf("## Resultado: %d/%d testes", sum(r0$ok), nrow(r0)), "",
  tabela_md(data.frame(Arquivo = paste0("`", r0$arquivo, "`"), Teste = paste0("`", r0$teste, "`"), Resultado = ifelse(r0$ok, "passou", paste("FALHOU:", r0$mensagem)), check.names = FALSE)), "",
  "- `td6_t3_ns` e `td6_t3_bs`: teste 3 da D2 (errata da D6, 2.2), com a estrutura de datas do A1 (serie_nos de 4.749 dias; x_cb de 4.505; os dois extremos da serie_nos nos 244 dias fora da janela), argvar ns (p10/p75/p90) e bs de grau 2 (S1); critérios: dif ≤ 1e-8, controles com fronteiras p1–p99 e range(serie_nos) > 1e-8.",
  "- `td6_wald_selecao_exata`: com `media` e `xmedia`, os dois Wald da `meta_curva` têm gl = 4 e batem com a forma quadrática à mão.",
  "- `td6_q_por_coeficiente`: receita do chamador; `qtest()` do `mixmeta` reajustado com `unname(Y)` e o mesmo método e Ψ; `coef` `identical()` ao `coef_meta`; `Q[-1]` igual ao cálculo à mão; gl = 23.",
  "- Comentários mudados em `testa_segunda_etapa.R`, sem mexer no nome nem no código: `t03` (\"curva() contra crossreduce, mesma argvar (não é o teste 3 da errata da D6)\") e `t09_vcov_gnm_com_phi` (\"tautológico pela D6, 2.2 (vcov.gnm l. 76 e summary.gnm l. 85); vale testa_ajusta_dlnm_d1_errata.R (a85c388)\").", "",
  "## Mutantes (cada um numa cópia do `segunda_etapa.R`; a bateria rápida inteira roda em cada cópia)", "",
  tabela_md(res_mut), "",
  sprintf("- **Resultado:** %s.", if (ok) sprintf("todos os testes passam no original, e os %d mutantes são mortos", nrow(res_mut)) else "FALHA: ver as tabelas"), "",
  "## SHA-256 de `codigo_compartilhado/R/` e `codigo_compartilhado/tests/` (para a mensagem da tag)", "",
  sprintf("- `%s`: `%s`;", todos_arq, sha_todos), "",
  sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| testes:", sum(r0$ok), "/", nrow(r0), "| mutantes mortos:", sum(res_mut[[2]] >= 1), "/", nrow(res_mut), "| ok:", ok, "\n")
if (!ok) quit(status = 1)
