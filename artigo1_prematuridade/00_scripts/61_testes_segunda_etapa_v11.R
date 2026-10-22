# 61_testes_segunda_etapa_v11.R — Fase 4, Parte A: testes e mutantes da segunda_etapa v1.1, só com dado sintético
# (mensagem da Parte A do chat do Artigo 1, 16/10/2026, seção 2; mensagem de respostas ao plano, seção 4; A1-97).
# Não toca a base: nenhum nascimentos(), série real ou RDS da Fase 2 ou 3.
# Roda:
#   - regressão: a v1.0.1 lida da tag segunda_etapa-v1.0.1 por git show (ts11_regressao_v10: as funções que não mudaram
#     têm o mesmo código, por deparse; a meta_curva dá identical() em todos os campos com fórmulas contínuas);
#   - baterias: testa_segunda_etapa.R sem t01, t02, t03 e t11 (os três primeiros exigem atributos reais da Fase 2; o t11
#     passa pela porta .s_reais(), que exige os mesmos atributos, para ler os códigos; o código da ordem e da semente é o
#     da v1.0.1, conferido por deparse; os quatro rodaram no 44 e no 55 e voltam no portão da C1), testa_segunda_etapa_d6.R e testa_segunda_etapa_v11.R (com os 2 testes da v1.0.2); fora:
#     o Monte Carlo de testa_segunda_etapa_mc.R. A attrdl (código, não dado) é a de inst/terceiros, conferida por SHA-256;
#     os códigos das 26 concentrações vêm da ordem literal da tag (nenhuma leitura da base);
#   - mutantes: cópias da segunda_etapa.R e, para os mutantes B1 e B2 da auditoria de 15/10, da função do teste 3
#     (teste3_fonte_independente.R, carregada no ambiente global como no 55); morto = algum teste que passa no original
#     cai; o log separa erro de critério (roda_testes_fase4.R).
# Confere antes: este script, o código e os testes commitados e limpos; BLAS e LAPACK de referência; locale UTF-8
# (auditoria do chat de 18/10, M1). Semente 20261001.
# Grava logs/testes_segunda_etapa_v11_fase4_<RODADA>.md. Nunca sobrescreve. Numa falha, quit(status = 1).
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/61_testes_segunda_etapa_v11.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
if (!isTRUE(l10n_info()[["UTF-8"]])) stop("locale não UTF-8: a conferência de sigilo do log não vale fora dele (auditoria do chat de 18/10, M1)")
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("testes_segunda_etapa_v11_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/61_testes_segunda_etapa_v11.R"
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
de_tag <- function(tag, a) { tf <- tempfile(fileext = ".R"); writeLines(git("show", paste0(tag, ":", a)), tf, useBytes = TRUE); tf }

# ------------------------------------------------------------------ conferências e cabeçalho (protocolo v1.1, 3.8)
s_info <- sessionInfo()
if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib")) stop("BLAS/LAPACK fora da referência (§8)")
COD <- c(aj = "codigo_compartilhado/R/ajusta_dlnm.R", se = "codigo_compartilhado/R/segunda_etapa.R")
TST <- c(run = "codigo_compartilhado/tests/roda_testes_fase4.R", t3 = "codigo_compartilhado/tests/teste3_fonte_independente.R",
         t_se = "codigo_compartilhado/tests/testa_segunda_etapa.R", t_d6 = "codigo_compartilhado/tests/testa_segunda_etapa_d6.R",
         t_se11 = "codigo_compartilhado/tests/testa_segunda_etapa_v11.R")
ATTRDL <- "codigo_compartilhado/inst/terceiros/attrdl.R"; SHA_ATTRDL <- "d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d"
sujos <- git("status", "--porcelain", "--", ESTE, COD, TST, ATTRDL)
if (length(sujos)) { cat(sujos, sep = "\n"); stop("script, código ou testes com mudança não commitada: não roda") }
TAG <- "segunda_etapa-v1.0.1"; if (!identical(git("rev-parse", paste0(TAG, "^{commit}")), "403b0a2d4b60c425d38cb39fcbef0f7b147891c1")) stop("tag ", TAG, " fora do commit esperado")
if (!identical(sha(file.path(REPO, ATTRDL)), SHA_ATTRDL)) stop("attrdl.R com SHA-256 diferente do registrado")
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current")
st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:")   # system2 não cita argumentos (lição do 55)
stopifnot(length(head_c) == 1L, length(ramo) == 1L, length(coord) == 1L)
inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta) })
sha_cod <- vapply(file.path(REPO, c(COD, TST, ATTRDL, ESTE)), sha, ""); names(sha_cod) <- c(COD, TST, ATTRDL, ESTE)

# ------------------------------------------------------------------ ambiente de teste e baterias
.REF <- new.env(); .REF$s10 <- new.env(); sys.source(de_tag(TAG, COD[["se"]]), envir = .REF$s10)
for (k in names(TST)) source(file.path(REPO, TST[[k]]))
.R3$codigos <- .REF$s10$ORDEM_CONCENTRACOES; .R3$attrdl_path <- file.path(REPO, ATTRDL); .R3$attrdl <- .REF$s10$carrega_attrdl(.R3$attrdl_path, SHA_ATTRDL)
FORA <- c("t01_d2_nos_medios", "t02_d2_boundary_knots", "t03_d2_curva_contra_crossreduce", "t11_ordem_e_semente")   # t11: porta .s_reais()
stopifnot(all(FORA %in% names(testes_segunda_etapa))); t_se_sint <- testes_segunda_etapa[setdiff(names(testes_segunda_etapa), FORA)]
texto <- lapply(c(COD, t3 = TST[["t3"]]), function(a) paste0(paste(readLines(file.path(REPO, a), encoding = "UTF-8"), collapse = "\n"), "\n"))
carrega <- function(troca = NULL) {
  e <- new.env()
  for (k in names(COD)) sys.source(if (!is.null(troca) && identical(troca$alvo, k)) troca$arquivo else file.path(REPO, COD[[k]]), envir = e)
  e
}
bateria <- function(f) rbind(cbind(arquivo = "testa_segunda_etapa.R", roda_testes_fase4(f, t_se_sint)),
                             cbind(arquivo = "testa_segunda_etapa_d6.R", roda_testes_fase4(f, testes_segunda_etapa_d6)),
                             cbind(arquivo = "testa_segunda_etapa_v11.R", roda_testes_fase4(f, testes_segunda_etapa_v11)))
log_msg("bateria no original"); t0 <- Sys.time(); r0 <- bateria(carrega()); t_bat <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
print(r0[, c("arquivo", "teste", "ok", "tipo")], row.names = FALSE)

# ------------------------------------------------------------------ mutantes
mutantes <- list(
  list("seleção do termo com rep(assign, times = k) (ordem trocada)", "se", list(c("ind <- which(rep(asg, each = k) == ti)", "ind <- which(rep(asg, times = k) == ti)"))),
  list("ordem trocada e sem a conferência dos nomes", "se", list(c("ind <- which(rep(asg, each = k) == ti)", "ind <- which(rep(asg, times = k) == ti)"),
                                                                 c("  if (!identical(names(stats::coef(fit))[ind], esperado)) stop(", "  if (FALSE) stop("))),
  list("predição na média forçada com fator (colMeans)", "se", list(c("numericos <- all(vapply(termos, function(t) is.numeric(md[[t]]), TRUE))", "numericos <- TRUE"))),
  list("confere_meta sem a checagem do status", "se", list(c("stopifnot(identical(m$status, \"ok\"), is.data.frame(m$wald), nrow(m$wald) == length(termos), identical(", "stopifnot(is.data.frame(m$wald), nrow(m$wald) == length(termos), identical("))),
  list("q_por_coeficiente com coluna p", "se", list(c("gl = unname(q$df[-1]),\n             rotulo", "gl = unname(q$df[-1]), p = unname(q$pvalue[-1]),\n             rotulo"))),
  list("confere_eixo com tolerância de 1e-8, e não bit a bit", "se", list(c("if (!identical(x_inf, eixo_valores[1]))", "if (abs(x_inf - eixo_valores[1]) > 1e-8)"))),
  list("decide_teste3 sem o critério da grade em range(x_cb)", "se", list(c("if (!isTRUE(all(x >= min(x_cb) & x <= max(x_cb)))) \"grade fora de range(x_cb)\"", "NULL"))),
  list("exploratório contínuo sem centrar", "se", list(c("centro <- mean(md[[termo]]); md[[termo]] <- md[[termo]] - centro", "centro <- mean(md[[termo]])"))),
  list("exploratório: \"sem\" = modelo só com intercepto (total)", "se", list(c("sem = if (identical(m0$status, \"ok\")) m0$heterogeneidade$residual else NULL", "sem = m1$heterogeneidade$total"))),
  list("multinível com Ψ não estruturada na região e diagonal na concentração", "se", list(c("list(list(\"reml\", c(\"diag\", \"unstr\"))", "list(list(\"reml\", c(\"unstr\", \"diag\"))"))),
  list("efeitos fixos ajustados por REML", "se", list(c("r <- .roda_mixmeta(ajusta, fml, vcov, md, \"fixed\", \"unstr\")", "r <- .roda_mixmeta(ajusta, fml, vcov, md, \"reml\", \"unstr\")"))),
  list("A2: curva() centrada no ponto de x mais próximo de cen", "se", list(c("B <- .base_x(x, argvar); Bc <- .base_x(cen, argvar)", "B <- .base_x(x, argvar); Bc <- .base_x(x[which.min(abs(x - cen))], argvar)"))),
  list(".base_x sem os Boundary.knots da argvar (mutante 1 do 55)", "se", list(c(".base_x <- function(x, argvar) unclass(do.call(dlnm::onebasis, c(list(x = x), argvar)))",
                                                                                 ".base_x <- function(x, argvar) unclass(do.call(dlnm::onebasis, c(list(x = x), argvar[names(argvar) != \"Boundary.knots\"])))"))),
  list("curva() com os knots da argvar × 1,001 (mutante 3 do 55)", "se", list(c("B <- .base_x(x, argvar); Bc <- .base_x(cen, argvar)", "argvar$knots <- argvar$knots * 1.001; B <- .base_x(x, argvar); Bc <- .base_x(cen, argvar)"))),
  list("B1: teste 3 com os nós tirados da argvar", "t3", list(c("nos <- unname(stats::quantile(serie_nos, probs_nos, type = 7))", "nos <- unname(argvar$knots)"))),
  list("B2: teste 3 com as fronteiras tiradas da argvar", "t3", list(c("list(dif = max(abs(lr_ind(range(x_cb)) - ref)),", "list(dif = max(abs(lr_ind(argvar$Boundary.knots) - ref)),"))),
  # da auditoria independente da Parte A (achado 1; Nota 3)
  list("confere_meta sem o is.data.frame do wald (auditoria, achado 1)", "se", list(c("stopifnot(identical(m$status, \"ok\"), is.data.frame(m$wald), nrow(m$wald) == length(termos), identical(", "stopifnot(identical(m$status, \"ok\"), nrow(m$wald) == length(termos), identical("))),
  list("efeitos fixos sem o total (auditoria, achado 1)", "se", list(c("total = if (r0$falhou) NULL else .qi2(r0$fit)); out$wald", "total = NULL); out$wald"))),
  list("multinível sem o total (auditoria, achado 1)", "se", list(c("total = if (r0$falhou) NULL else .qi2(r0$fit))\n  out\n}", "total = NULL)\n  out\n}"))),
  list("exploratório sem o total (auditoria, achado 1)", "se", list(c("total = m1$heterogeneidade$total)", "total = NULL)"))),
  list("decide_teste3 com dif < 1e-8, e não ≤ (auditoria, Nota 3)", "se", list(c("if (!isTRUE(r$dif <= 1e-8)) \"dif > 1e-8\"", "if (!isTRUE(r$dif < 1e-8)) \"dif > 1e-8\""))),
  list("decide_teste3 com controle ≥ 1e-8, e não > (auditoria, Nota 3)", "se", list(c("if (!isTRUE(r$dif_controle_p1p99 > 1e-8))", "if (!isTRUE(r$dif_controle_p1p99 >= 1e-8))"))),
  # da auditoria do chat de 18/10 (M2) e das checagens de tamanho acrescentadas junto
  list("confere_meta sem conferir os nomes e a ordem dos termos (chat, M2)", "se", list(c("identical(as.character(m$wald$termo), termos),\n            length(m$wald$gl)", "\n            length(m$wald$gl)"))),
  list("confere_meta sem exigir a estatística do Wald finita (chat, M2)", "se", list(c("all(is.finite(m$wald$estatistica)),\n            !is.null", "TRUE,\n            !is.null"))),
  list("confere_meta sem exigir o Q total finito (chat, M2)", "se", list(c("!is.null(m$heterogeneidade$total), isTRUE(is.finite(m$heterogeneidade$total$Q)))\n  invisible(TRUE)", "!is.null(m$heterogeneidade$total), TRUE)\n  invisible(TRUE)"))),
  list("confere_meta com is.finite(Q) sem isTRUE (Q ausente passa)", "se", list(c("isTRUE(is.finite(m$heterogeneidade$total$Q)))\n  invisible(TRUE)", "is.finite(m$heterogeneidade$total$Q))\n  invisible(TRUE)"))),
  list("confere_meta sem o tamanho da coluna gl (gl ausente passa)", "se", list(c("\n            length(m$wald$gl) == length(termos), all(m$wald$gl == gl)", "\n            all(m$wald$gl == gl)"))),
  list("confere_meta sem o tamanho da estatística (estatística ausente passa)", "se", list(c("all(m$wald$gl == gl), length(m$wald$estatistica) == length(termos), all(is.finite(m$wald$estatistica)),\n", "all(m$wald$gl == gl), all(is.finite(m$wald$estatistica)),\n")))
)
res_mut <- do.call(rbind, lapply(mutantes, function(m) {
  src <- texto[[m[[2]]]]
  for (tr in m[[3]]) { if (lengths(regmatches(src, gregexpr(tr[1], src, fixed = TRUE))) != 1) stop("texto do mutante sem exatamente uma ocorrência: ", m[[1]]); src <- sub(tr[1], tr[2], src, fixed = TRUE) }
  tf <- tempfile(fileext = ".R"); writeLines(src, tf, useBytes = TRUE)
  log_msg("mutante:", m[[1]])
  if (m[[2]] == "t3") { source(tf); rr <- bateria(carrega()); source(file.path(REPO, TST[["t3"]])) } else rr <- bateria(carrega(list(alvo = m[[2]], arquivo = tf)))
  unlink(tf); stopifnot(identical(rr$teste, r0$teste)); caem <- !rr$ok & r0$ok
  tipos <- table(factor(rr$tipo[caem], levels = c("critério", "erro")))
  data.frame(Mutante = m[[1]], Arquivo = basename(c(COD, t3 = TST[["t3"]])[[m[[2]]]]), `Testes que caem` = sum(caem), `Por critério` = tipos[["critério"]], `Por erro` = tipos[["erro"]],
             Quais = if (any(caem)) paste(rr$teste[caem], collapse = ", ") else "nenhum", check.names = FALSE, stringsAsFactors = FALSE) }))
if (!identical(unname(vapply(file.path(REPO, c(COD, TST[["t3"]])), sha, "")), unname(sha_cod[c(COD, TST[["t3"]])]))) stop("código mudou durante a rodada")
ok <- all(r0$ok) && all(res_mut[["Testes que caem"]] >= 1)

# ------------------------------------------------------------------ log
md <- c("# Fase 4, Parte A: segunda_etapa v1.1 — testes e mutantes (só dado sintético)", "",
  sprintf("- **Gerado por:** `00_scripts/61_testes_segunda_etapa_v11.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`.", sha_cod[[ESTE]], inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Ambiente:** R %s; dlnm %s; gnm %s; mixmeta %s. BLAS/LAPACK: `%s` / `%s` (referência). Locale `%s` (UTF-8, conferido no início). Semente 20261001 (Mersenne-Twister, Inversion, Rejection). Não toca a base.",
          paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("gnm"), packageVersion("mixmeta"), s_info$BLAS, s_info$LAPACK, Sys.getlocale("LC_CTYPE")),
  "- **Código e testes (SHA-256; todos commitados e limpos antes de rodar):**", sprintf("  - `%s`: `%s`;", names(sha_cod), sha_cod),
  sprintf("- **Regressão:** a v1.0.1 lida da tag `%s` (commit `403b0a2`) por `git show`.", TAG),
  sprintf("- **Fora da bateria:** %s (exigem atributos reais da Fase 2; o `t11` passa pela porta `.s_reais()`; o código da ordem e da semente é o da v1.0.1, conferido por deparse no `ts11_regressao_v10`; rodaram no 44 e no 55 e voltam no portão da C1) e o Monte Carlo de `testa_segunda_etapa_mc.R`.", paste0("`", FORA, "`", collapse = ", ")),
  "- **Os 2 testes da v1.0.2 (A1-87(h)):** `ts11_v102_cen_fora_de_x` (x = os 6 percentis, cen = a mediana, fora de x) e `ts11_v102_argvar_errada` (nós de quantile(x_cb); fronteiras p1–p99): matam os mutantes A2, B1 e B2 (tabela de mutantes).", "",
  sprintf("## Resultado: %d/%d testes (%.0f s)", sum(r0$ok), nrow(r0), t_bat), "",
  tabela_md(data.frame(Arquivo = paste0("`", r0$arquivo, "`"), Teste = paste0("`", r0$teste, "`"), Resultado = ifelse(r0$ok, "passou", paste0("FALHOU (", r0$tipo, "): ", r0$mensagem)), check.names = FALSE)), "",
  "## Mutantes (cada um numa cópia do arquivo; a bateria inteira roda em cada cópia)", "",
  tabela_md(res_mut), "",
  sprintf("- **Resultado:** %s.", if (ok) sprintf("todos os testes passam no original, e os %d mutantes são mortos", nrow(res_mut)) else "FALHA: ver as tabelas"), "")
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| testes:", sum(r0$ok), "/", nrow(r0), "| mutantes mortos:", sum(res_mut[["Testes que caem"]] >= 1), "/", nrow(res_mut), "| ok:", ok, "\n")
if (!ok) quit(status = 1)
