# 54_confere_travas_diagnostico.R — Fase 3: travas do diagnóstico da grade da MRT (entradas 82(a) e 83(a); pareceres do
# chat do Artigo 1 de 14/10/2026, v1.1, seção 1), só leitura. O 53 fica congelado no 937dbbf; este script não o altera nem
# altera os produtos dele.
#   Parte A: bateria de testes sintéticos (testa_diagnostico_grade_mrt.R) e 39 defeitos plantados (os 23 do 53, com os
#            textos de busca revalidados contra a função nova, 3 um por trava removida, 6 da reauditoria e 7 da entrada 83(a)).
#   Parte B: a função com as travas nas 26 concentrações, com as mesmas entradas do 53 (SHA-256 conferido). Reconstrói o
#            mesmo `out` do 53 (merge das Partes 1 e 2) e compara, como texto, cada coluna do CSV do 53 (números em
#            %.17g, NA = "", lógicos TRUE/FALSE). As colunas novas (travas) vão à parte. Se qualquer valor ou classe
#            mudar: PARADA, registrada no log, sem corrigir nada.
# Não reajusta modelo nem recalcula MRT, AF, BLUP ou bootstrap. Não grava CSV. O log só traz igual/diferente por coluna,
# contagens, travas por concentração, testes e defeitos; nenhum u_min, x_t, data, contagem diária ou série diária.
# Grava logs/travas_diagnostico_grade_mrt_fase3_<FASE3_DATA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/54_confere_travas_diagnostico.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; CC <- file.path("..", "codigo_compartilhado")
arq <- file.path("logs", paste0("travas_diagnostico_grade_mrt_fase3_", hoje, ".md")); stopifnot(!file.exists(arq))
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha_git <- function(rev, a) sub(" .*", "", system(paste("git -C", shQuote(REPO), "show", shQuote(paste0(rev, ":", a)), "| shasum -a 256"), intern = TRUE))
sn <- function(x) ifelse(is.na(x), "—", ifelse(x, "sim", "não"))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
# texto de cada coluna como o 53 grava no CSV (escreve_csv do 53: números em %.17g, NA = "", lógicos TRUE/FALSE), em memória
para_texto <- function(df) {
  num <- vapply(df, is.double, TRUE); df[num] <- lapply(df[num], function(v) ifelse(is.na(v), NA, sprintf("%.17g", v)))
  tc <- textConnection("txt_csv", "w", local = TRUE); utils::write.csv(df, tc, row.names = FALSE, na = ""); close(tc)
  utils::read.csv(text = txt_csv, colClasses = "character", na.strings = character(0), check.names = FALSE, encoding = "UTF-8")
}

# ------------------------------------------------------------------ conferências
s_info <- sessionInfo()
if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib")) stop("BLAS/LAPACK fora da referência (§8)")
TAG <- "segunda_etapa-v1.0"; if (!identical(git("rev-parse", paste0(TAG, "^{commit}")), "410dd6d6d3d315004f22fd7197c326de77f3c2f4")) stop("tag fora do commit esperado")
for (a in git("ls-tree", "-r", "--name-only", TAG, "codigo_compartilhado/R/")) if (!identical(sha_git(TAG, a), sha(file.path(REPO, a)))) stop(a, " difere da tag ", TAG)
TAG_PH <- "posthoc_af-v1.0"; if (!identical(git("rev-parse", paste0(TAG_PH, "^{commit}")), "dc89ae753aeabd806593c7f3cb0dcbca4efc5f17")) stop("tag ", TAG_PH, " fora do commit esperado")
f_ph <- "codigo_compartilhado/R/posthoc_af.R"; if (!identical(sha_git(TAG_PH, f_ph), sha(file.path(REPO, f_ph)))) stop("posthoc_af.R diferente da tag ", TAG_PH)
C53 <- "937dbbf1b084c6ca473d10627987922aa02a1322"
congelados <- c("artigo1_prematuridade/00_scripts/53_diagnostico_grade_mrt.R", "artigo1_prematuridade/logs/diagnostico_grade_mrt_fase3_20261014.md",
                "artigo1_prematuridade/00_scripts/45_segunda_etapa_principal.R")
for (a in congelados) if (!identical(sha_git(C53, a), sha(file.path(REPO, a)))) stop(a, " diferente do commit ", C53)
suppressPackageStartupMessages({ library(dlnm) })
f_se <- file.path(CC, "R", "segunda_etapa.R"); f_dg <- file.path(CC, "R", "diagnostico_grade_mrt.R")
f_td <- file.path(CC, "tests", "testa_diagnostico_grade_mrt.R"); f_run <- file.path(CC, "tests", "roda_testes.R")
carrega <- function(arquivo_dg, grade_sem_p99 = FALSE) { e <- new.env(); sys.source(f_se, envir = e); sys.source(arquivo_dg, envir = e)
  if (grade_sem_p99) e$grade_tmr <- function(x_inf, x_sup) seq(x_inf, x_sup, by = 0.1)   # defeito plantado só na cópia em memória
  e }
f <- carrega(f_dg)
L50 <- paste(readLines(file.path("logs", "posthoc_af_fase3_20261013.md"), encoding = "UTF-8"), collapse = "\n")
L46 <- paste(readLines(file.path("logs", "fracao_atribuivel_fase3_20261013.md"), encoding = "UTF-8"), collapse = "\n")
L53 <- paste(readLines(file.path("logs", "diagnostico_grade_mrt_fase3_20261014.md"), encoding = "UTF-8"), collapse = "\n")
ENT <- c(rds2 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", ser1 = "01_saidas/fase1/serie_ptb_principal.rds",
         rds45 = "01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds", rds50 = "01_saidas/fase3/posthoc_af_fase3_20261013.rds",
         item2 = "01_saidas/fase3/posthoc_item2_fase3_20261013.csv", neg = "01_saidas/fase3/contribuicoes_negativas_fase3_20261013.csv",
         csv53 = "01_saidas/fase3/diagnostico_grade_mrt_fase3_20261014.csv")
fonte <- list(rds2 = L50, ser1 = L50, rds45 = L50, rds50 = L50, item2 = L50, neg = L46, csv53 = L53)
sha_ent <- vapply(ENT, sha, "")
ent_ok <- vapply(names(ENT), function(k) grepl(sprintf("`%s`: `%s`", ENT[[k]], sha_ent[[k]]), fonte[[k]], fixed = TRUE), TRUE)
if (!all(ent_ok)) stop("entrada com SHA-256 diferente do log: ", paste(names(ENT)[!ent_ok], collapse = ", "))
if (!identical(sha_ent[["csv53"]], "c27f652dbacba6807e2b599019f96fc1b6f15448e2581fecadc3ff59567ef3c9")) stop("CSV do 53 diferente do registrado")
sha_cod <- vapply(c(f_dg, f_td, f_run, f_se), sha, "")
names(sha_cod) <- c("codigo_compartilhado/R/diagnostico_grade_mrt.R", "codigo_compartilhado/tests/testa_diagnostico_grade_mrt.R",
                    "codigo_compartilhado/tests/roda_testes.R", "codigo_compartilhado/R/segunda_etapa.R")
log_msg("conferências: ok")

# ------------------------------------------------------------------ Parte A: testes e defeitos plantados
source(f_run); source(f_td)
r0 <- roda_testes(f, testes_diagnostico_grade_mrt); print(r0[, c("teste", "ok")], row.names = FALSE)
src <- paste0(paste(readLines(f_dg, encoding = "UTF-8"), collapse = "\n"), "\n")
defeitos <- list(
  # pedidos pela mensagem v1.1 do chat (seção 4); o 1º com o texto de busca revalidado contra a função nova
  list("h = 0,1 na célula parcial", list(c("ca <- classifica_celula(M, b - a, u_min, fa, fb, fx, dist, tol_f = tol_f, mrt_argmin = arg)\n  cn <- classifica_celula(Mn, b - a, u_min, fa, fb, fx, dist, tol_f = tol_f, mrt_argmin = arg)",
                                            "ca <- classifica_celula(M, 0.1, u_min, fa, fb, fx, dist, tol_f = tol_f, mrt_argmin = arg)\n  cn <- classifica_celula(Mn, 0.1, u_min, fa, fb, fx, dist, tol_f = tol_f, mrt_argmin = arg)"))),
  list("grade sem o p99 (grade_tmr trocada por seq de 0,1 °C, na cópia em memória)", list(), TRUE),
  list("razão da célula só contra f(MRT)", list(c("r_cel <- (min(f_a, f_b) - f_x) / cota", "r_cel <- -u_min / cota"))),
  list("M num ponto (f″ no dia do mínimo), e não o máximo na célula", list(c("M <- max(f2_ns(zk, argvar_busca, coef))", "M <- f2_ns(xs, argvar_busca, coef)"))),
  list("vizinhança com distância ≤ 1", list(c("else if (dist == 0) \"a, vizinha\"", "else if (dist <= 1) \"a, vizinha\""))),
  # acrescentados pela sessão (53)
  list("u_min com a base da busca, e não com a da attrdl", list(c("u <- f_ns(xd, argvar_attrdl, coef) - f_ns(mrt, argvar_attrdl, coef)", "u <- f_ns(xd, argvar_busca, coef) - f_ns(mrt, argvar_busca, coef)"))),
  list("dias fora do p1–p99 incluídos", list(c("dentro <- x >= p1 & x <= p99; xd <- x[dentro]", "dentro <- rep(TRUE, length(x)); xd <- x[dentro]"))),
  list("M sem os nós internos da célula", list(c("zk <- c(a, b, kn[kn > a & kn < b])", "zk <- c(a, b)"))),
  list("tolerância do u_min gravado frouxa (1e-6)", list(c("tol_gravado = 1e-13", "tol_gravado = 1e-6"))),
  list("tolerância das razões frouxa (1,5)", list(c("r_mrt <= 1 + tol && r_cel <= 1 + tol", "r_mrt <= 1.5 && r_cel <= 1.5"))),
  list("classe (b) não detectada", list(c("if (xs > grade[n] + 1e-8 || xs < grade[1] - 1e-8) {", "if (FALSE) {"))),
  # da auditoria independente do 53 (achados 1, 3 e 7)
  list("x* tirado do vetor completo, e não dos dias dentro do p1–p99", list(c("i <- which.min(u); u_min <- u[i]; xs <- xd[i]", "i <- which.min(u); u_min <- u[i]; xs <- x[i]"))),
  list("sem a trava M > 0", list(c("ok <- is.finite(M) && M > 0 &&", "ok <- is.finite(M) &&"))),
  list("M com a base da attrdl", list(c("M <- max(f2_ns(zk, argvar_busca, coef))", "M <- max(f2_ns(zk, argvar_attrdl, coef))"))),
  list("f(a) e f(b) com a base da attrdl", list(c("fa <- f_ns(a, argvar_busca, coef); fb <- f_ns(b, argvar_busca, coef)", "fa <- f_ns(a, argvar_attrdl, coef); fb <- f_ns(b, argvar_attrdl, coef)"))),
  list("f(x*) com a base da busca", list(c("fx <- f_ns(xs, argvar_attrdl, coef)", "fx <- f_ns(xs, argvar_busca, coef)"))),
  list("classe numérica calculada com o M analítico", list(c("cn <- classifica_celula(Mn, b - a,", "cn <- classifica_celula(M, b - a,"))),
  list("célula parcial sem a condição de h", list(c("out$parcial <- abs(b - p99) <= 1e-8 && (b - a) < 0.1 - 1e-8", "out$parcial <- abs(b - p99) <= 1e-8"))),
  list("classe (b) só do lado do p99", list(c("if (xs > grade[n] + 1e-8 || xs < grade[1] - 1e-8) {", "if (xs > grade[n] + 1e-8) {"))),
  list("sem a checagem de MRT fora dos pontos da grade", list(c("if (mrt != grade[k]) {", "if (FALSE) {"))),
  list("primeiro ponto = p1 sempre verdadeiro", list(c("primeiro_eh_p1 = abs(grade[1] - p1) <= 1e-8", "primeiro_eh_p1 = TRUE"))),
  list("tolerância de último = p99 em 1e-2", list(c("ultimo_eh_p99 = abs(grade[n] - p99) <= 1e-8", "ultimo_eh_p99 = abs(grade[n] - p99) <= 1e-2"))),
  list("p99 acrescentado com > 0, e não > 1e-8", list(c("p99_acrescentado = (p99 - sq[length(sq)]) > 1e-8", "p99_acrescentado = (p99 - sq[length(sq)]) > 0"))),
  # um por trava da entrada 82(a), removida
  list("sem a trava de coerência das razões", list(c("coer <- (min(f_a, f_b) - f_x) + u_min >= -tol_f", "coer <- TRUE"))),
  list("sem a trava da MRT como argmin de f na grade", list(c("arg <- fg[k] <= min(fg) + tol_f", "arg <- TRUE"))),
  list("sem a trava h ≤ 0,1 + 1e-8", list(c("h_ok <- h <= 0.1 + 1e-8", "h_ok <- TRUE"))),
  # da reauditoria em contexto limpo (achados 1, 2, 3, 4 e 6)
  list("M = máx|f″|, e não máx f″", list(c("M <- max(f2_ns(zk, argvar_busca, coef))", "M <- max(abs(f2_ns(zk, argvar_busca, coef)))"))),
  list("tolerância da coerência em 1e-6, e não tol_f", list(c("coer <- (min(f_a, f_b) - f_x) + u_min >= -tol_f", "coer <- (min(f_a, f_b) - f_x) + u_min >= -1e-6"))),
  list("tolerância do argmin em 1e-6, e não tol_f", list(c("arg <- fg[k] <= min(fg) + tol_f", "arg <- fg[k] <= min(fg) + 1e-6"))),
  list("ponto k da MRT por findInterval, e não pelo ponto mais próximo", list(c("k <- which.min(abs(grade - mrt))", "k <- findInterval(mrt, grade)"))),
  list("célula por findInterval sem rightmost.closed e sem o min", list(c("j <- min(findInterval(xs, grade, rightmost.closed = TRUE), n - 1L)", "j <- findInterval(xs, grade)"))),
  list("tol_f e mrt_argmin com valor padrão (trava 2 pulada numa chamada direta)", list(c("dist, tol_f, mrt_argmin, tol = 1e-6) {", "dist, tol_f = 1e-12, mrt_argmin = TRUE, tol = 1e-6) {"))),
  # da entrada 83(a) (parecer do chat, seções 1.1 a 1.3)
  list("MRT na grade com tolerância de 1e-8, e não igualdade exata", list(c("if (mrt != grade[k]) {", "if (abs(grade[k] - mrt) > 1e-8) {"))),
  list("f(grade) da trava 2 na base da attrdl", list(c("fg <- f_ns(grade, argvar_busca, coef)", "fg <- f_ns(grade, argvar_attrdl, coef)"))),
  list("motivo da f″ numérica omitido", list(c("if (ca$classe != cn$classe) \"f″ analítica e numérica mudam a classe\"), collapse = \"; \")", "NULL), collapse = \"; \")"))),
  list("motivo da f″ numérica sobrescrevendo os outros", list(c("out$motivo <- paste(c(ca$motivos, if (ca$classe != cn$classe) \"f″ analítica e numérica mudam a classe\"), collapse = \"; \")",
                                                                "out$motivo <- if (ca$classe != cn$classe) \"f″ analítica e numérica mudam a classe\" else paste(ca$motivos, collapse = \"; \")"))),
  list("tol_f fixo em 1e-12", list(c("tol_f <- 1e-12 * max(1, max(abs(fg)))", "tol_f <- 1e-12"))),
  list("tol_f sem o máx(1, ·)", list(c("tol_f <- 1e-12 * max(1, max(abs(fg)))", "tol_f <- 1e-12 * max(abs(fg))"))),
  list("anômala sem trava sem motivo (M ≤ 0 ou razão acima de 1 + tol)", list(c("motivos = c(mot_base, mot_trava)", "motivos = mot_trava")))
)
res_def <- do.call(rbind, lapply(defeitos, function(d) {
  s2 <- src
  for (tr in d[[2]]) { if (lengths(regmatches(s2, gregexpr(tr[1], s2, fixed = TRUE))) != 1) stop("texto de busca sem exatamente uma ocorrência: ", d[[1]]); s2 <- sub(tr[1], tr[2], s2, fixed = TRUE) }
  tf <- file.path(tempdir(), "diagnostico_grade_mrt_com_defeito.R"); writeLines(s2, tf, useBytes = TRUE)
  rr <- roda_testes(carrega(tf, isTRUE(d[3][[1]])), testes_diagnostico_grade_mrt); unlink(tf)
  stopifnot(identical(rr$teste, r0$teste)); novos <- rr$teste[!rr$ok & r0$ok]
  data.frame(Defeito = d[[1]], `Testes derrubados (dos que passam no original)` = length(novos), Quais = if (length(novos)) paste(novos, collapse = ", ") else "nenhum",
             check.names = FALSE, stringsAsFactors = FALSE) }))
ok_testes <- all(r0$ok) && all(res_def[[2]] >= 1) && identical(sha(f_dg), sha_cod[[1]])
log_msg("Parte A: testes", sum(r0$ok), "/", nrow(r0), "| defeitos derrubados:", sum(res_def[[2]] >= 1), "/", nrow(res_def))
if (!ok_testes) stop("testes sintéticos ou defeitos plantados falharam: nada foi calculado com os dados")

# ------------------------------------------------------------------ Parte B: a função com as travas nas 26 (só leitura)
r45 <- readRDS(ENT[["rds45"]]); r50 <- readRDS(ENT[["rds50"]])
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES; stopifnot(identical(r45$ordem, ordem))
nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
P1 <- lapply(readRDS(ENT[["rds2"]])$resultados[ordem], `[[`, "principal")
tb45 <- r45$tmr[r45$tmr$nivel == "blup", ]; tb45 <- tb45[match(ordem, tb45$recorte_principal), ]; stopifnot(identical(tb45$recorte_principal, ordem))
it2 <- r50$item2[match(ordem, r50$item2$recorte_principal), ]; stopifnot(identical(it2$recorte_principal, ordem))
INI <- as.Date("2012-04-07"); INI_JAN <- as.Date("2012-04-14"); FIM <- as.Date("2024-08-06")
s <- readRDS(ENT[["ser1"]]); s <- as.data.frame(s)[s$data >= INI & s$data <= FIM, c("recorte_principal", "data", "tmean_nucleo", "janela_principal")]
dados <- lapply(ordem, function(r) { z <- s[s$recorte_principal == r, ]; z <- z[order(z$data), ]
  stopifnot(nrow(z) == 4505L, all(diff(z$data) == 1), identical(z$janela_principal, z$data >= INI_JAN))
  cb <- f$monta_cb(z$tmean_nucleo, z$data, P1[[r]]$base$argvar, P1[[r]]$base$arglag, lag = 7)
  g <- r45$grade[r, ]; list(x = z$tmean_nucleo[z$janela_principal], argvar_attrdl = attr(cb, "argvar"), p1 = g[["p1"]], p99 = g[["p99"]]) })
names(dados) <- ordem; rm(s)
# o mesmo `out` do 53 (Parte 1 e Parte 2, merge por concentração)
p1t <- do.call(rbind, lapply(ordem, function(r) { d <- dados[[r]]; mrt <- tb45$tmr[tb45$recorte_principal == r]
  cbind(data.frame(recorte_principal = r, p1 = d$p1, p99 = d$p99, mrt = mrt, stringsAsFactors = FALSE), f$parte1_grade(d$p1, d$p99, mrt, f$grade_tmr(d$p1, d$p99))) }))
p1t$n_grade_45 <- tb45$n_grade
p1t$x_inf_45 <- abs(tb45$x_inf - p1t$p1) == 0 & abs(tb45$x_sup - p1t$p99) == 0
p2t <- do.call(rbind, lapply(ordem, function(r) { d <- dados[[r]]; mrt <- tb45$tmr[tb45$recorte_principal == r]
  cbind(data.frame(recorte_principal = r, stringsAsFactors = FALSE),
        f$diagnostica_minimo(r45$blup[[r]]$coef, P1[[r]]$base$argvar, d$argvar_attrdl, d$x, d$p1, d$p99, mrt, f$grade_tmr(d$p1, d$p99),
                             min_delta_gravado = it2$min_delta[it2$recorte_principal == r])) }))
out <- merge(p1t, p2t, by = "recorte_principal", sort = FALSE); out <- out[match(ordem, out$recorte_principal), ]
out <- cbind(out[, "recorte_principal", drop = FALSE], concentracao = unname(nome[out$recorte_principal]), out[, setdiff(names(out), "recorte_principal")])
# f″ > 0 em toda a célula do mínimo (contagem)
neg <- out$u_min < -1e-8
f2_pos <- vapply(which(neg), function(i) { r <- out$recorte_principal[i]; av <- P1[[r]]$base$argvar; kn <- av$knots
  zk <- c(out$a[i], out$b[i], kn[kn > out$a[i] & kn < out$b[i]]); min(f$f2_ns(zk, av, r45$blup[[r]]$coef)) > 0 }, TRUE)
# com a MRT exatamente no ponto da grade, f(mrt) é idêntico a f(grade)[k] (a trava 2 com f(mrt) é mutante equivalente)
fmrt_igual <- vapply(which(neg), function(i) { r <- out$recorte_principal[i]; av <- P1[[r]]$base$argvar; cf <- r45$blup[[r]]$coef
  gg <- f$grade_tmr(out$p1[i], out$p99[i]); k <- match(out$mrt[i], gg); !is.na(k) && identical(f$f_ns(out$mrt[i], av, cf), f$f_ns(gg, av, cf)[k]) }, TRUE)
log_msg("Parte B: função com as travas nas 26")

# ------------------------------------------------------------------ comparação, como texto, com o CSV do 53
v53 <- utils::read.csv(ENT[["csv53"]], colClasses = "character", na.strings = character(0), check.names = FALSE, encoding = "UTF-8")
col53 <- names(v53); col_novas <- setdiff(names(out), col53); faltam <- setdiff(col53, names(out))
t54 <- para_texto(out[, intersect(col53, names(out)), drop = FALSE])
cmp <- data.frame(Coluna = col53, Resultado = vapply(col53, function(cn) if (cn %in% names(t54) && identical(t54[[cn]], v53[[cn]])) "igual" else "DIFERENTE", ""),
                  `Linhas diferentes` = vapply(col53, function(cn) if (cn %in% names(t54)) sum(t54[[cn]] != v53[[cn]]) else nrow(v53), 0L), check.names = FALSE, stringsAsFactors = FALSE)
iguais <- nrow(v53) == nrow(out) && !length(faltam) && all(cmp$Resultado == "igual")
travas_ok <- all(out$trava_coerencia[neg]) && all(out$trava_mrt_argmin[neg]) && all(out$trava_h[neg]) && all(is.na(out$trava_coerencia[!neg])) && all(fmrt_igual)
para <- !iguais || !travas_ok
log_msg("comparação com o CSV do 53:", sum(cmp$Resultado == "igual"), "/", nrow(cmp), "colunas iguais | travas nas", sum(neg), ":", if (travas_ok) "passam" else "NÃO passam")

# ------------------------------------------------------------------ log
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
md <- c("# Fase 3: travas do diagnóstico da grade da MRT (entrada 82(a); só leitura)", "",
  sprintf("- **Gerado por:** `00_scripts/54_confere_travas_diagnostico.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
  sprintf("- **Ambiente:** R %s; dlnm %s; splines %s. BLAS/LAPACK: `%s` / `%s` (referência).", paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"),
          packageVersion("splines"), s_info$BLAS, s_info$LAPACK),
  "- **Rótulo:** travas registradas na entrada 82(a) antes de rodar, depois de ver os resultados do 53 (não é desvio). Nada foi reajustado nem recalculado: as entradas são as do 53.",
  "- **Código (SHA-256):**", sprintf("  - `%s`: `%s`;", names(sha_cod), sha_cod),
  sprintf("  - todos os arquivos de `codigo_compartilhado/R/` da tag `%s` iguais aos do disco; `posthoc_af.R` igual ao da tag `%s`; o 53, o log dele e o 45 iguais aos do commit `937dbbf`.", TAG, TAG_PH),
  "- **Entradas (SHA-256 conferidos contra os logs do 50, do 46 e do 53):**", sprintf("  - `%s`: `%s`;", ENT, sha_ent), "",
  "## Travas (entrada 82(a))", "",
  "- Em `classifica_celula`, para as duas classes (`classe` e `classe_num`), com tol_f = 1e-12·máx(1, máx|f(grade)|) e f(grade) na base da busca:",
  "  1. **coerência das razões:** [mín(f(a), f(b)) − f(x*)] − (−u_min) ≥ −tol_f;",
  "  2. **a MRT é o argmin de f na grade:** f(grade)[k] ≤ mín f(grade) + tol_f, com o k do ponto da grade da MRT;",
  "  3. **h ≤ 0,1 + 1e-8.**",
  "- Cada trava que cai acrescenta o seu motivo em `motivo`, separado por \"; \"; o resultado de cada uma sai em `trava_coerencia`, `trava_mrt_argmin` e `trava_h`.",
  "- **Entrada 83(a):** a MRT tem de ser exatamente (bit a bit) um ponto da grade (`mrt != grade[k]` dá anômala, \"MRT não é ponto da grade\"), e não mais a até 1e-8; toda anômala tem motivo (\"M ≤ 0 ou não finito\", \"razão MRT acima de 1 + tol\", \"razão célula acima de 1 + tol\", antes dos das travas).", "",
  "## Parte A: testes sintéticos e defeitos plantados", "",
  "- `td10_travas` (novo): um caso por trava, com as outras duas passando e as duas classes anômalas, cada um com o seu motivo: (1) base dos dias com os nós deslocados em −0,005 °C, razões ≤ 1 e f(MRT) da base dos dias acima do da busca; (2) curva em W com o primeiro poço raso e a MRT no vizinho do argmin, abaixo dos extremos da célula do mínimo; (2b) a mesma trava na escala de tol_f, com a MRT passada 1e-10 acima do argmin; (3) grade de 0,12 °C; e os três motivos juntos (grade de 0,12 °C e MRT no outro extremo da célula).",
  "- `td8`: os casos de tolerância das razões passaram a usar razão célula = razão MRT; entraram as três travas na regra da classe, a fronteira da tolerância da coerência (folga de −5e-12 cai; de −5e-13, passa) e o erro numa chamada sem `tol_f` e `mrt_argmin`.",
  "- Da 1ª reauditoria: `td11_borda_f2_sinal` (novo; célula do p1 com f″ de −0,003 a 0,002, M = 0,002); no `td6`, x* exatamente no p99 com a MRT fora do argmin dá anômala, sem erro.",
  "- Da entrada 83(a): no `td5`, a MRT a 5e-9 °C do ponto e a MRT deslocada 1 ulp (`g[k]·(1 + .Machine$double.eps)`, com `mrt != grade[k]` afirmado no teste) e a MRT abaixo do p1 dão anômala, e f(mrt) é idêntico a f(grade)[k]; no `td4`, a trava 2 passa pela base da busca embora o argmin pela base dos dias seja outro, e os motivos de razão aparecem; no `td8`, os motivos de M ≤ 0 e de razão acima de 1 + tol; `td12_motivo_f2_e_tol_f` (novo): passo numérico de 2 °C (analítica (a), numérica anômala, motivo só o da f″), f″ em V na célula com a base dos dias deslocada (analítica anômala por razão, numérica (a), travas passando, motivo \"razão célula acima de 1 + tol; f″ analítica e numérica mudam a classe\"), e a escala de tol_f com máx|f(grade)| = 10 (folga de −5e-12 passa) e = 0,01 (folga de −5e-13 passa, pelo máx(1, ·)).", "",
  tabela_md(data.frame(Teste = paste0("`", r0$teste, "`"), Resultado = ifelse(r0$ok, "passou", paste("FALHOU:", r0$mensagem)), check.names = FALSE)), "",
  "Defeitos plantados (cada um numa cópia de `diagnostico_grade_mrt.R`, salvo o da grade, plantado na `grade_tmr` da cópia em memória). Cada texto de busca foi revalidado contra a função nova, com exatamente uma ocorrência; mudou só o do 1º (a chamada da `classifica_celula`, agora em duas linhas e com `tol_f` e `mrt_argmin`). Mudaram, contra a função anterior, o 1º (a chamada da `classifica_celula`, em duas linhas) e o \"sem a checagem de MRT fora dos pontos da grade\" (agora `if (mrt != grade[k]) {`). Os 23 primeiros são os do 53; os 3 seguintes, um por trava removida; os 6 seguintes, da 1ª reauditoria; os 7 últimos, da entrada 83(a):", "",
  tabela_md(res_def), "",
  sprintf("- **Resultado:** %d/%d testes; cada um dos %d defeitos derruba pelo menos um teste.", sum(r0$ok), nrow(r0), nrow(res_def)),
  "- **M = máx|f″| e `findInterval` sem `rightmost.closed`,** antes sobreviventes justificados, caem desde a 1ª reauditoria: o `td11` (célula da borda) e o `td6` (x* no p99).",
  sprintf("- **f″ > 0 em toda a célula do mínimo** em %d das %d concentrações da Parte 2.", sum(f2_pos), sum(neg)),
  sprintf("- **Mutante equivalente:** a trava 2 com f(mrt) em vez de f(grade)[k]. Com a MRT exatamente no ponto da grade (entrada 83(a)), f(mrt) é idêntico a f(grade)[k]: conferido num teste (`td5`) e nas concentrações da Parte 2 (%d de %d). A justificativa anterior (\"a trava 1 também cai\") era falsa num quase empate, onde só a trava do argmin cai (entrada 83(b)).", sum(fmrt_igual), sum(neg)),
  "- **Sobrevivente justificado:** sem a checagem razão MRT ≤ 1 + tol, redundante com a coerência (razão célula ≥ razão MRT − tol_f/cota) e com razão célula ≤ 1 + tol.", "",
  "## Parte B: a função com as travas nas 26, comparada com o CSV do 53", "",
  sprintf("- **CSV do 53:** `%s` (SHA-256 `%s…`), %d linhas e %d colunas. O `out` foi reconstruído como no 53 e convertido em texto como o 53 grava (números em `%%.17g`, NA = \"\", lógicos TRUE/FALSE), em memória.",
          ENT[["csv53"]], substr(sha_ent[["csv53"]], 1, 8), nrow(v53), ncol(v53)),
  sprintf("- **Colunas iguais:** %d de %d%s. Colunas novas, à parte: %s.", sum(cmp$Resultado == "igual"), nrow(cmp), if (length(faltam)) sprintf(" (faltam: %s)", paste(faltam, collapse = ", ")) else "",
          paste0("`", col_novas, "`", collapse = ", ")), "",
  tabela_md(cmp), "",
  sprintf("- **Travas nas %d concentrações com u_min < −1e-8:** coerência %d, argmin %d, h %d (passam); nas outras %d, as travas não se aplicam (fora da Parte 2).",
          sum(neg), sum(out$trava_coerencia[neg]), sum(out$trava_mrt_argmin[neg]), sum(out$trava_h[neg]), sum(!neg)), "",
  tabela_md(data.frame(Concentração = out$concentracao, `Parte 2` = sn(neg), Classe = ifelse(is.na(out$classe), "—", out$classe),
                       `Classe (f″ numérica)` = ifelse(is.na(out$classe_num), "—", out$classe_num), Coerência = sn(out$trava_coerencia),
                       `MRT = argmin` = sn(out$trava_mrt_argmin), `h ≤ 0,1` = sn(out$trava_h), check.names = FALSE)), "",
  "## Resultado", "",
  if (para) c("**PARADA.**", if (!iguais) "- algum valor ou classe do 53 mudou (ver a tabela de colunas);", if (!travas_ok) "- alguma trava cai nas concentrações da Parte 2;", "",
              "Nada foi corrigido.") else
    sprintf("**Sem parada.** Com as travas, nenhum valor nem classe do 53 muda (%d de %d colunas iguais, como texto); nas %d concentrações da Parte 2, as três travas passam.", sum(cmp$Resultado == "igual"), nrow(cmp), sum(neg)), "",
  sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "|", if (para) "PARADA" else "sem parada", "\n")
