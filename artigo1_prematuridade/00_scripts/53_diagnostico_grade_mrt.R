# 53_diagnostico_grade_mrt.R — Fase 3: diagnóstico da grade da MRT (errata da D5 de 14/10/2026, item 2; entrada 80),
# só leitura. Não reajusta modelo nem recalcula MRT, AF, BLUP ou bootstrap: usa a MRT BLUP, os coeficientes BLUP, o p1 e
# o p99 da RDS do 45, e o menor Δ_t da RDS do 50. Usa codigo_compartilhado/R/diagnostico_grade_mrt.R e a grade_tmr da tag
# segunda_etapa-v1.0, sem alterá-la.
#   1. Conferências: código da tag; posthoc_af.R da tag posthoc_af-v1.0; entradas com o SHA-256 dos logs do 50 e do 46.
#   2. Testes sintéticos (testa_diagnostico_grade_mrt.R) e defeitos plantados, cada um numa cópia da função.
#   3. Parte 1 (26): a grade começa no p1 e termina no p99? Linhas do código citadas; exemplo detalhado.
#   4. Parte 2 (u_min < −1e-8; devem ser 15): u_min contra o gravado; célula; distância; M (analítico e numérico);
#      cota = M·h²/8; razões; classe.
#   5. Autoauditoria: Recife e uma das três concentrações do teste (ii) com splines::ns e código próprio.
# Paradas da seção 4 da mensagem v1.1 do chat: são registradas no log e no console, sem corrigir nada.
# Sai por concentração: p1, p99, MRT, a, b, distância, u_min, M, cota, razões, classe. Não sai: data nem x_t do dia do
# mínimo, contagem ou contribuição desse dia, série diária. Grava logs/diagnostico_grade_mrt_fase3_<FASE3_DATA>.md e
# 01_saidas/fase3/diagnostico_grade_mrt_fase3_<FASE3_DATA>.csv. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/53_diagnostico_grade_mrt.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; CC <- file.path("..", "codigo_compartilhado")
arq <- file.path("logs", paste0("diagnostico_grade_mrt_fase3_", hoje, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase3"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
f_csv <- file.path(OUT, paste0("diagnostico_grade_mrt_fase3_", hoje, ".csv")); stopifnot(!file.exists(f_csv))
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha_git <- function(rev, a) sub(" .*", "", system(paste("git -C", shQuote(REPO), "show", shQuote(paste0(rev, ":", a)), "| shasum -a 256"), intern = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
sci <- function(x, d = 3) ifelse(is.na(x), "—", formatC(x, format = "e", digits = d))
sn <- function(x) ifelse(is.na(x), "—", ifelse(x, "sim", "não"))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
escreve_csv <- function(df, p) { num <- vapply(df, is.double, TRUE); df[num] <- lapply(df[num], function(v) ifelse(is.na(v), NA, sprintf("%.17g", v)))
  utils::write.csv(df, p, row.names = FALSE, na = "", fileEncoding = "UTF-8") }
linhas_de <- function(txt, padrao) grep(padrao, txt, fixed = TRUE)

# ------------------------------------------------------------------ 1. conferências
s_info <- sessionInfo()
if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib")) stop("BLAS/LAPACK fora da referência (§8)")
TAG <- "segunda_etapa-v1.0"; if (!identical(git("rev-parse", paste0(TAG, "^{commit}")), "410dd6d6d3d315004f22fd7197c326de77f3c2f4")) stop("tag fora do commit esperado")
for (a in git("ls-tree", "-r", "--name-only", TAG, "codigo_compartilhado/R/")) if (!identical(sha_git(TAG, a), sha(file.path(REPO, a)))) stop(a, " difere da tag ", TAG)
TAG_PH <- "posthoc_af-v1.0"; if (!identical(git("rev-parse", paste0(TAG_PH, "^{commit}")), "dc89ae753aeabd806593c7f3cb0dcbca4efc5f17")) stop("tag ", TAG_PH, " fora do commit esperado")
SHA_PH <- "a90096b7"; f_ph <- "codigo_compartilhado/R/posthoc_af.R"
if (!identical(sha_git(TAG_PH, f_ph), sha(file.path(REPO, f_ph))) || !startsWith(sha(file.path(REPO, f_ph)), SHA_PH)) stop("posthoc_af.R diferente da tag ", TAG_PH)
f45s <- "artigo1_prematuridade/00_scripts/45_segunda_etapa_principal.R"
if (length(git("status", "--porcelain", "--", f45s))) stop("45 com mudança local em relação ao commit")
suppressPackageStartupMessages({ library(dlnm) })
f_se <- file.path(CC, "R", "segunda_etapa.R"); f_dg <- file.path(CC, "R", "diagnostico_grade_mrt.R")
f_td <- file.path(CC, "tests", "testa_diagnostico_grade_mrt.R"); f_run <- file.path(CC, "tests", "roda_testes.R")
carrega <- function(arquivo_dg, grade_sem_p99 = FALSE) { e <- new.env(); sys.source(f_se, envir = e); sys.source(arquivo_dg, envir = e)
  if (grade_sem_p99) e$grade_tmr <- function(x_inf, x_sup) seq(x_inf, x_sup, by = 0.1)   # defeito plantado só na cópia em memória
  e }
f <- carrega(f_dg)
L50 <- paste(readLines(file.path("logs", "posthoc_af_fase3_20261013.md"), encoding = "UTF-8"), collapse = "\n")
L46 <- paste(readLines(file.path("logs", "fracao_atribuivel_fase3_20261013.md"), encoding = "UTF-8"), collapse = "\n")
ENT <- c(rds2 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", ser1 = "01_saidas/fase1/serie_ptb_principal.rds",
         rds45 = "01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds", rds50 = "01_saidas/fase3/posthoc_af_fase3_20261013.rds",
         item2 = "01_saidas/fase3/posthoc_item2_fase3_20261013.csv", neg = "01_saidas/fase3/contribuicoes_negativas_fase3_20261013.csv")
fonte <- c(rds2 = "50", ser1 = "50", rds45 = "50", rds50 = "50", item2 = "50", neg = "46")
sha_ent <- vapply(ENT, sha, "")
ent_ok <- vapply(names(ENT), function(k) grepl(sprintf("`%s`: `%s`", ENT[[k]], sha_ent[[k]]), if (fonte[[k]] == "50") L50 else L46, fixed = TRUE), TRUE)
if (!all(ent_ok)) stop("entrada com SHA-256 diferente do log: ", paste(names(ENT)[!ent_ok], collapse = ", "))
sha_cod <- vapply(c(f_dg, f_td, f_run, f_se, file.path(REPO, f_ph)), sha, "")
names(sha_cod) <- c("codigo_compartilhado/R/diagnostico_grade_mrt.R", "codigo_compartilhado/tests/testa_diagnostico_grade_mrt.R",
                    "codigo_compartilhado/tests/roda_testes.R", "codigo_compartilhado/R/segunda_etapa.R", f_ph)
log_msg("conferências: ok")

# ------------------------------------------------------------------ 2. testes sintéticos e defeitos plantados
source(f_run); source(f_td)
r0 <- roda_testes(f, testes_diagnostico_grade_mrt); print(r0[, c("teste", "ok")], row.names = FALSE)
src <- paste0(paste(readLines(f_dg, encoding = "UTF-8"), collapse = "\n"), "\n")
defeitos <- list(
  # pedidos pela mensagem v1.1 do chat (seção 4)
  list("h = 0,1 na célula parcial", list(c("ca <- classifica_celula(M, b - a, u_min, fa, fb, fx, dist); cn <- classifica_celula(Mn, b - a, u_min, fa, fb, fx, dist)",
                                            "ca <- classifica_celula(M, 0.1, u_min, fa, fb, fx, dist); cn <- classifica_celula(Mn, 0.1, u_min, fa, fb, fx, dist)"))),
  list("grade sem o p99 (grade_tmr trocada por seq de 0,1 °C, na cópia em memória)", list(), TRUE),
  list("razão da célula só contra f(MRT)", list(c("r_cel <- (min(f_a, f_b) - f_x) / cota", "r_cel <- -u_min / cota"))),
  list("M num ponto (f″ no dia do mínimo), e não o máximo na célula", list(c("M <- max(f2_ns(zk, argvar_busca, coef))", "M <- f2_ns(xs, argvar_busca, coef)"))),
  list("vizinhança com distância ≤ 1", list(c("else if (dist == 0) \"a, vizinha\"", "else if (dist <= 1) \"a, vizinha\""))),
  # acrescentados pela sessão
  list("u_min com a base da busca, e não com a da attrdl", list(c("u <- f_ns(xd, argvar_attrdl, coef) - f_ns(mrt, argvar_attrdl, coef)", "u <- f_ns(xd, argvar_busca, coef) - f_ns(mrt, argvar_busca, coef)"))),
  list("dias fora do p1–p99 incluídos", list(c("dentro <- x >= p1 & x <= p99; xd <- x[dentro]", "dentro <- rep(TRUE, length(x)); xd <- x[dentro]"))),
  list("M sem os nós internos da célula", list(c("zk <- c(a, b, kn[kn > a & kn < b])", "zk <- c(a, b)"))),
  list("tolerância do u_min gravado frouxa (1e-6)", list(c("tol_gravado = 1e-13", "tol_gravado = 1e-6"))),
  list("tolerância das razões frouxa (1,5)", list(c("r_mrt <= 1 + tol && r_cel <= 1 + tol", "r_mrt <= 1.5 && r_cel <= 1.5"))),
  list("classe (b) não detectada", list(c("if (xs > grade[n] + 1e-8 || xs < grade[1] - 1e-8) {", "if (FALSE) {"))),
  # da auditoria independente (achados 1, 3 e 7)
  list("x* tirado do vetor completo, e não dos dias dentro do p1–p99", list(c("i <- which.min(u); u_min <- u[i]; xs <- xd[i]", "i <- which.min(u); u_min <- u[i]; xs <- x[i]"))),
  list("sem a trava M > 0", list(c("ok <- is.finite(M) && M > 0 &&", "ok <- is.finite(M) &&"))),
  list("M com a base da attrdl", list(c("M <- max(f2_ns(zk, argvar_busca, coef))", "M <- max(f2_ns(zk, argvar_attrdl, coef))"))),
  list("f(a) e f(b) com a base da attrdl", list(c("fa <- f_ns(a, argvar_busca, coef); fb <- f_ns(b, argvar_busca, coef)", "fa <- f_ns(a, argvar_attrdl, coef); fb <- f_ns(b, argvar_attrdl, coef)"))),
  list("f(x*) com a base da busca", list(c("fx <- f_ns(xs, argvar_attrdl, coef)", "fx <- f_ns(xs, argvar_busca, coef)"))),
  list("classe numérica calculada com o M analítico", list(c("cn <- classifica_celula(Mn, b - a,", "cn <- classifica_celula(M, b - a,"))),
  list("célula parcial sem a condição de h", list(c("out$parcial <- abs(b - p99) <= 1e-8 && (b - a) < 0.1 - 1e-8", "out$parcial <- abs(b - p99) <= 1e-8"))),
  list("classe (b) só do lado do p99", list(c("if (xs > grade[n] + 1e-8 || xs < grade[1] - 1e-8) {", "if (xs > grade[n] + 1e-8) {"))),
  list("sem a checagem de MRT fora dos pontos da grade", list(c("if (abs(grade[k] - mrt) > 1e-8) {", "if (FALSE) {"))),
  list("primeiro ponto = p1 sempre verdadeiro", list(c("primeiro_eh_p1 = abs(grade[1] - p1) <= 1e-8", "primeiro_eh_p1 = TRUE"))),
  list("tolerância de último = p99 em 1e-2", list(c("ultimo_eh_p99 = abs(grade[n] - p99) <= 1e-8", "ultimo_eh_p99 = abs(grade[n] - p99) <= 1e-2"))),
  list("p99 acrescentado com > 0, e não > 1e-8", list(c("p99_acrescentado = (p99 - sq[length(sq)]) > 1e-8", "p99_acrescentado = (p99 - sq[length(sq)]) > 0")))
)
res_def <- do.call(rbind, lapply(defeitos, function(d) {
  s2 <- src
  for (tr in d[[2]]) { stopifnot(lengths(regmatches(s2, gregexpr(tr[1], s2, fixed = TRUE))) == 1); s2 <- sub(tr[1], tr[2], s2, fixed = TRUE) }
  tf <- file.path(tempdir(), "diagnostico_grade_mrt_com_defeito.R"); writeLines(s2, tf, useBytes = TRUE)
  rr <- roda_testes(carrega(tf, isTRUE(d[3][[1]])), testes_diagnostico_grade_mrt); unlink(tf)
  stopifnot(identical(rr$teste, r0$teste)); novos <- rr$teste[!rr$ok & r0$ok]
  data.frame(Defeito = d[[1]], `Testes derrubados (dos que passam no original)` = length(novos), Quais = if (length(novos)) paste(novos, collapse = ", ") else "nenhum",
             check.names = FALSE, stringsAsFactors = FALSE) }))
ok_testes <- all(r0$ok) && all(res_def[[2]] >= 1) && identical(sha(f_dg), sha_cod[[1]])
log_msg("testes:", sum(r0$ok), "/", nrow(r0), "| defeitos derrubados:", sum(res_def[[2]] >= 1), "/", nrow(res_def))
if (!ok_testes) stop("testes sintéticos ou defeitos plantados falharam: nada foi calculado com os dados")

# ------------------------------------------------------------------ dados (só leitura)
r45 <- readRDS(ENT[["rds45"]]); r50 <- readRDS(ENT[["rds50"]])
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES; stopifnot(identical(r45$ordem, ordem))
nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
P1 <- lapply(readRDS(ENT[["rds2"]])$resultados[ordem], `[[`, "principal")
tb45 <- r45$tmr[r45$tmr$nivel == "blup", ]; tb45 <- tb45[match(ordem, tb45$recorte_principal), ]; stopifnot(identical(tb45$recorte_principal, ordem))
it2 <- r50$item2[match(ordem, r50$item2$recorte_principal), ]; stopifnot(identical(it2$recorte_principal, ordem))
it2c <- utils::read.csv(ENT[["item2"]], colClasses = "character"); it2c <- it2c[match(ordem, it2c$recorte_principal), ]
csv_rds_ok <- identical(it2c$min_delta, sprintf("%.17g", it2$min_delta)) && identical(it2c$g, sprintf("%.17g", it2$g))
INI <- as.Date("2012-04-07"); INI_JAN <- as.Date("2012-04-14"); FIM <- as.Date("2024-08-06")
s <- readRDS(ENT[["ser1"]]); s <- as.data.frame(s)[s$data >= INI & s$data <= FIM, c("recorte_principal", "data", "tmean_nucleo", "janela_principal")]
dados <- lapply(ordem, function(r) { z <- s[s$recorte_principal == r, ]; z <- z[order(z$data), ]
  stopifnot(nrow(z) == 4505L, all(diff(z$data) == 1), identical(z$janela_principal, z$data >= INI_JAN))
  cb <- f$monta_cb(z$tmean_nucleo, z$data, P1[[r]]$base$argvar, P1[[r]]$base$arglag, lag = 7)
  g <- r45$grade[r, ]; list(x = z$tmean_nucleo[z$janela_principal], argvar_attrdl = attr(cb, "argvar"), p1 = g[["p1"]], p99 = g[["p99"]]) })
names(dados) <- ordem; rm(s)
log_msg("dados lidos")

# ------------------------------------------------------------------ 3. Parte 1
p1t <- do.call(rbind, lapply(ordem, function(r) { d <- dados[[r]]; mrt <- tb45$tmr[tb45$recorte_principal == r]
  cbind(data.frame(recorte_principal = r, p1 = d$p1, p99 = d$p99, mrt = mrt, stringsAsFactors = FALSE), f$parte1_grade(d$p1, d$p99, mrt, f$grade_tmr(d$p1, d$p99))) }))
p1t$n_grade_45 <- tb45$n_grade
p1t$x_inf_45 <- abs(tb45$x_inf - p1t$p1) == 0 & abs(tb45$x_sup - p1t$p99) == 0
para_p1 <- !all(p1t$primeiro_eh_p1) || !all(p1t$ultimo_eh_p99)
para_p1b <- !all(p1t$n_grade == p1t$n_grade_45) || !all(p1t$x_inf_45)
mrt_p99 <- p1t$recorte_principal[p1t$mrt_no_p99]
mrt_idx <- t(vapply(ordem, function(r) { g <- f$grade_tmr(dados[[r]]$p1, dados[[r]]$p99); m <- tb45$tmr[tb45$recorte_principal == r]; c(ult = m == g[length(g)], prim = m == g[1]) }, c(ult = TRUE, prim = TRUE)))
mrt_ult <- ordem[mrt_idx[, "ult"]]; fronteira_45 <- tb45$recorte_principal[tb45$fronteira]
fronteira_ok <- identical(mrt_ult, fronteira_45) && identical(mrt_ult, mrt_p99) && !any(mrt_idx[, "prim"])
p99_g0 <- all(it2$g[match(mrt_p99, ordem)] == 0) && all(it2$min_delta[match(mrt_p99, ordem)] > 0)
ex <- p1t[p1t$p99_acrescentado & p1t$mrt_no_p99, ][1, ]
txt_se <- git("show", paste0(TAG, ":codigo_compartilhado/R/segunda_etapa.R")); txt_45 <- readLines(file.path(REPO, f45s), encoding = "UTF-8")
txt_ph <- git("show", paste0(TAG_PH, ":", f_ph))
l_gt <- linhas_de(txt_se, "grade_tmr <- function(x_inf, x_sup) {"); l_gt <- l_gt:(l_gt + 4L)
stopifnot(identical(txt_se[l_gt[3]], "  g <- seq(x_inf, x_sup, by = 0.1)"), identical(txt_se[l_gt[4]], "  if (x_sup - g[length(g)] > 1e-8) g <- c(g, x_sup)"))
l_bt <- linhas_de(txt_se, "g <- grade_tmr(x_inf, x_sup)")
l_45 <- c(linhas_de(txt_45, "av <- P1[[r]]$base$argvar; g <- grade[r, ]; b <- blup[[r]]"), linhas_de(txt_45, "tb <- f$busca_tmr(b$coef, av, g[[\"p1\"]], g[[\"p99\"]]"),
          linhas_de(txt_45, "gg <- f$grade_tmr(g[[\"p1\"]], g[[\"p99\"]])"))
l_tc <- linhas_de(txt_ph, "dentro <- x >= p1 & x <= p99; dl <- fa(x[dentro]) - fa(mrt)")
log_msg("Parte 1: primeiro = p1 em", sum(p1t$primeiro_eh_p1), "| último = p99 em", sum(p1t$ultimo_eh_p99), "| p99 acrescentado em", sum(p1t$p99_acrescentado),
        "| MRT no p99 em", length(mrt_p99))

# ------------------------------------------------------------------ 4. Parte 2
p2t <- do.call(rbind, lapply(ordem, function(r) { d <- dados[[r]]; mrt <- tb45$tmr[tb45$recorte_principal == r]
  cbind(data.frame(recorte_principal = r, stringsAsFactors = FALSE),
        f$diagnostica_minimo(r45$blup[[r]]$coef, P1[[r]]$base$argvar, d$argvar_attrdl, d$x, d$p1, d$p99, mrt, f$grade_tmr(d$p1, d$p99),
                             min_delta_gravado = it2$min_delta[it2$recorte_principal == r])) }))
neg <- p2t$u_min < -1e-8; n_neg <- sum(neg)
para_n15 <- n_neg != 15L
para_grav <- any(p2t$classe %in% "parada") || !(max(p2t$dif_gravado) <= 1e-13)
para_classe <- any(p2t$classe[neg] %in% c("b", "anomala")) || !all(startsWith(p2t$classe[neg], "a, "))
para_num <- any(p2t$classe[neg] != p2t$classe_num[neg])
rec <- p2t[p2t$recorte_principal == "2611606", ]
tres <- c("3304557", "2408102", "2800308"); aud_2 <- tres[tres %in% p2t$recorte_principal[neg]][1]
log_msg("Parte 2: u_min < -1e-8 em", n_neg, "| classes:", paste(names(table(p2t$classe[neg])), table(p2t$classe[neg]), collapse = "; "))

# ------------------------------------------------------------------ negativos do AN (conferência, sem linhas)
ng <- utils::read.csv(ENT[["neg"]], colClasses = c(recorte_principal = "character")); ng <- ng[ng$analise == "principal", ]
soma_fora <- sum(ng$soma_negativas_fora_p1_p99); soma_dentro <- sum(ng$soma_negativas_dentro_p1_p99)
neg_ok <- nrow(ng) == 26L && identical(br(soma_fora, 2), "-38,70")

# ------------------------------------------------------------------ 5. autoauditoria (código próprio, splines::ns, sem a onebasis e sem as funções do diagnóstico)
fns <- function(z, av, cf) drop(unclass(splines::ns(z, knots = av$knots, Boundary.knots = av$Boundary.knots, intercept = isTRUE(av$intercept))) %*% cf)
f2_poli <- function(z, lo, hi, av, cf) { t <- seq(lo, hi, length.out = 4); s0 <- (t - lo) / (hi - lo); co <- solve(cbind(1, s0, s0^2, s0^3), fns(t, av, cf))
  (2 * co[3] + 6 * co[4] * (z - lo) / (hi - lo)) / (hi - lo)^2 }
autoaud <- do.call(rbind, lapply(c("2611606", aud_2), function(r) {
  d <- dados[[r]]; av <- P1[[r]]$base$argvar; a2 <- d$argvar_attrdl; cf <- r45$blup[[r]]$coef; mrt <- tb45$tmr[tb45$recorte_principal == r]
  xd <- d$x[d$x >= d$p1 & d$x <= d$p99]; u <- fns(xd, a2, cf) - fns(mrt, a2, cf); xs <- xd[which.min(u)]
  gg <- pmin(d$p1 + (0:floor((d$p99 - d$p1) / 0.1 + 1e-10)) * 0.1, d$p99); if (d$p99 - gg[length(gg)] > 1e-8) gg <- c(gg, d$p99)
  a <- max(gg[gg <= xs]); b <- min(gg[gg > xs]); br0 <- sort(unique(c(a, b, av$knots[av$knots > a & av$knots < b])))
  M <- max(unlist(lapply(seq_len(length(br0) - 1L), function(i) c(f2_poli(br0[i], br0[i], br0[i + 1L], av, cf), f2_poli(br0[i + 1L], br0[i], br0[i + 1L], av, cf)))))
  p <- p2t[p2t$recorte_principal == r, ]
  data.frame(recorte_principal = r, dif_u_min = abs(min(u) - p$u_min), celula_igual = identical(c(a, b), c(p$a, p$b)), dif_rel_M = abs(M - p$M) / abs(M),
             ok = abs(min(u) - p$u_min) <= 1e-13 && identical(c(a, b), c(p$a, p$b)) && abs(M - p$M) / abs(M) <= 1e-6, stringsAsFactors = FALSE) }))
log_msg("autoauditoria:", paste(nome[autoaud$recorte_principal], ifelse(autoaud$ok, "ok", "DIFERENTE"), collapse = "; "))

# ------------------------------------------------------------------ paradas
paradas <- c(if (para_p1) "Parte 1: o primeiro ponto da grade não é o p1 ou o último não é o p99 (> 1e-8) em alguma concentração",
             if (para_p1b) "Parte 1: n da grade ou extremos diferentes dos registrados pelo 45",
             if (!fronteira_ok) "Parte 1: MRT no último ponto da grade diferente das concentrações com fronteira no 45",
             if (para_n15) sprintf("Parte 2: %d concentrações com u_min < −1e-8, e não 15", n_neg),
             if (para_grav) "Parte 2: u_min diferente do menor Δ_t gravado pelo 50 em mais de 1e-13",
             if (para_classe) "Parte 2: classe (b) ou anômala",
             if (para_num) "Parte 2: f″ analítica e numérica mudam a classe",
             if (!csv_rds_ok) "CSV do item 2 diferente da RDS do 50",
             if (!neg_ok) "soma das contribuições negativas fora do p1–p99 diferente de −38,70",
             if (!all(autoaud$ok)) "autoauditoria com diferença")
para <- length(paradas) > 0

# ------------------------------------------------------------------ saídas
out <- merge(p1t, p2t, by = "recorte_principal", sort = FALSE); out <- out[match(ordem, out$recorte_principal), ]
out <- cbind(out[, "recorte_principal", drop = FALSE], concentracao = unname(nome[out$recorte_principal]), out[, setdiff(names(out), "recorte_principal")])
escreve_csv(out, f_csv); sha_csv <- sha(f_csv)

# ------------------------------------------------------------------ log
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
q <- out[neg, ]
fx <- function(x, d = 4) br(x, d)
md <- c("# Fase 3: diagnóstico da grade da MRT (errata da D5, item 2; só leitura)", "",
  sprintf("- **Gerado por:** `00_scripts/53_diagnostico_grade_mrt.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
  sprintf("- **Ambiente:** R %s; dlnm %s; splines %s. BLAS/LAPACK: `%s` / `%s` (referência).", paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"),
          packageVersion("splines"), s_info$BLAS, s_info$LAPACK),
  "- **Rótulo:** diagnóstico descritivo pedido pela errata da D5 (`spec/decisoes_metodo_20261014_errata_D5.md`, SHA-256 `9c9fb65d…`), registrado na entrada 80 antes de rodar. Nada foi reajustado nem recalculado: MRT BLUP, coeficientes BLUP, p1 e p99 vêm da RDS do 45; o menor Δ_t, da RDS do 50.",
  "- **Código (SHA-256):**", sprintf("  - `%s`: `%s`;", names(sha_cod), sha_cod),
  sprintf("  - todos os arquivos de `codigo_compartilhado/R/` da tag `%s` iguais aos do disco; `posthoc_af.R` igual ao da tag `%s`; o 45 sem mudança local em relação ao commit.", TAG, TAG_PH),
  "- **Entradas (SHA-256 conferidos contra o log do 50; o CSV de contribuições negativas, contra o log do 46):**", sprintf("  - `%s`: `%s`;", ENT, sha_ent),
  sprintf("  - o CSV do item 2 é igual à RDS do 50 no texto `%%.17g` (menor Δ_t e g): %s.", sn(csv_rds_ok)), "",
  "## Testes sintéticos e defeitos plantados", "",
  "- Em todos os cenários, os dias fora do p1–p99 ficam intercalados com os de dentro (no começo e no meio do vetor), para o índice do vetor completo não coincidir com o dos dias de dentro (auditoria independente, achado 1).",
  "- `td1`: mergulho na célula vizinha da MRT, com nó da `argvar` dentro da célula e f″ máxima nesse nó → (a, vizinha); u_min, célula, M, cota e razões (também a razão com o M numérico) contra a conta à mão (`splines::ns` e polinômio cúbico exato de cada trecho).",
  "- `td2`: célula parcial no p99 (h = 0,04 °C) → (a), com a cota do h real; com (p99 − p1)/0,1 inteiro, a última célula é cheia e não é parcial.",
  "- `td3`: quase empate de dois mínimos locais a 80 células um do outro → (a, quase empate de mínimos locais), declarada; razão da célula contra mín(f(a), f(b)), maior que a razão contra f(MRT).",
  "- `td4`: base dos dias diferente da base da busca (nós deslocados em 0,4 °C) → razão > 1 → anômala; célula, M, f(a), f(b) e f(x*), cada um com a sua base, contra a conta à mão.",
  "- `td5`: u_min diferente do gravado em 1e-12 → parada; em 5e-14, segue; MRT a 1e-6 °C de um ponto da grade → anômala.",
  "- `td6`: grade sem o p99, MRT no último ponto do `seq` e curva ainda descendo → (b); o simétrico no p1 (grade sem o p1, curva subindo) → (b); com a `grade_tmr`, MRT no extremo e nenhum negativo (dias fora do p1–p99 não contam).",
  "- `td7`: Parte 1 (n da grade, p99 acrescentado ou não, último ponto = p99, MRT no p99), com (p99 − p1)/0,1 inteiro e não inteiro, com grade sem o p99, sem o p1, com o último ponto a 0,005 °C do p99 e com folga de 5e-9 (o p99 não é acrescentado).",
  "- `td8`: distância em células; vizinha só com distância 0; tolerância 1e-6 nas razões; M = 0 e M < 0 → anômala.",
  "- `td9`: f e f″ da função contra `splines::ns` e o polinômio exato de cada trecho; f″ numérica; f″ fora dos Boundary.knots dá erro.", "",
  tabela_md(data.frame(Teste = paste0("`", r0$teste, "`"), Resultado = ifelse(r0$ok, "passou", paste("FALHOU:", r0$mensagem)), check.names = FALSE)), "",
  "Defeitos plantados (cada um numa cópia de `diagnostico_grade_mrt.R`, salvo o da grade, plantado na `grade_tmr` da cópia em memória; a bateria inteira roda em cada cópia). Os cinco primeiros são os pedidos pelo chat; os seis seguintes, da sessão; os doze últimos, da auditoria independente:", "",
  tabela_md(res_def), "",
  sprintf("- **Resultado:** %d/%d testes; cada um dos %d defeitos derruba pelo menos um teste.", sum(r0$ok), nrow(r0), nrow(res_def)), "",
  "## Parte 1: a grade da MRT começa no p1 e termina no p99?", "",
  sprintf("- **Código, na tag `%s`** (`codigo_compartilhado/R/segunda_etapa.R`): `grade_tmr` nas linhas %d–%d: `g <- seq(x_inf, x_sup, by = 0.1)` (linha %d) e `if (x_sup - g[length(g)] > 1e-8) g <- c(g, x_sup)` (linha %d); `busca_tmr` e `boot_tmr` chamam `grade_tmr(x_inf, x_sup)` nas linhas %s.",
          TAG, l_gt[1], l_gt[5], l_gt[3], l_gt[4], paste(l_bt, collapse = " e ")),
  sprintf("- **Chamadas no 45** (`00_scripts/45_segunda_etapa_principal.R`, commit `ec38fc3`): linha %d (`g <- grade[r, ]`, a linha da concentração na grade de percentis da A0), linha %d (`busca_tmr(b$coef, av, g[[\"p1\"]], g[[\"p99\"]], …)`) e linha %d (`grade_tmr(g[[\"p1\"]], g[[\"p99\"]])`): x_inf = p1 e x_sup = p99 da concentração.",
          l_45[1], l_45[2], l_45[3]),
  sprintf("- **Primeiro ponto = p1:** %d de 26. **Último ponto = p99** (|dif| ≤ 1e-8): %d de 26. **p99 acrescentado** (p99 − último do `seq` > 1e-8): %d de 26. n da grade e extremos iguais aos registrados pelo 45: %s.",
          sum(p1t$primeiro_eh_p1), sum(p1t$ultimo_eh_p99), sum(p1t$p99_acrescentado), sn(!para_p1b)),
  sprintf("- **MRT no p99:** a MRT BLUP é exatamente o último ponto da grade (o p99) em %d de 26 (%s), as mesmas com `fronteira = TRUE` no 45 (%d); nenhuma no primeiro ponto: %s. Nelas, |MRT − p99| = %s, g = 0 e menor Δ_t > 0 no 50: %s.", length(mrt_ult),
          paste(nome[mrt_ult], collapse = ", "), length(fronteira_45), sn(fronteira_ok), sci(max(p1t$dif_mrt_p99[p1t$mrt_no_p99])), sn(p99_g0)),
  if (!is.na(ex$recorte_principal)) sprintf("- **Exemplo detalhado (%s):** p1 = %s °C, p99 = %s °C, (p99 − p1)/0,1 = %s (não inteiro); o `seq` de 0,1 °C termina em %s °C, a %s °C do p99, e a `grade_tmr` acrescenta o p99 como %dº ponto; a MRT BLUP é %s °C, igual ao p99 (|dif| = %s), isto é, o último ponto da grade, o acrescentado.",
          nome[[ex$recorte_principal]], fx(ex$p1), fx(ex$p99), fx((ex$p99 - ex$p1) / 0.1, 2), fx(ex$ultimo_seq), fx(ex$p99 - ex$ultimo_seq), ex$n_grade, fx(ex$mrt), sci(ex$dif_mrt_p99)) else "- Nenhuma concentração com p99 acrescentado e MRT no p99.", "",
  tabela_md(data.frame(Concentração = nome[p1t$recorte_principal], p1 = fx(p1t$p1), p99 = fx(p1t$p99), `(p99 − p1)/0,1` = fx((p1t$p99 - p1t$p1) / 0.1, 2), `n da grade` = as.character(p1t$n_grade),
                       `Primeiro = p1` = sn(p1t$primeiro_eh_p1), `Último do seq` = fx(p1t$ultimo_seq), `p99 acrescentado` = sn(p1t$p99_acrescentado), `Último = p99` = sn(p1t$ultimo_eh_p99),
                       MRT = fx(p1t$mrt), `MRT no p99` = sn(p1t$mrt_no_p99), check.names = FALSE)), "",
  "## Parte 2: onde fica o dia de menor contribuição", "",
  sprintf("- **u_min** = mín[f(x_t) − f(MRT)] nos dias da janela com x_t no p1–p99, com a base que a `attrdl` reconstrói de `attr(cb, \"argvar\")` sem o `cen` (mesma expressão da `testa_contribuicoes`, `posthoc_af.R` da tag `%s`, linha %d). Igual ao menor Δ_t gravado pelo 50 nas 26: diferença máxima %s (critério ≤ 1e-13).",
          TAG_PH, l_tc, sci(max(p2t$dif_gravado), 1)),
  sprintf("- **u_min < −1e-8:** %d de 26%s. As outras %d: %s.", n_neg, if (para_n15) " (esperado: 15)" else "", sum(!neg),
          paste(sprintf("%s (%s)", nome[p2t$recorte_principal[!neg]], sci(p2t$u_min[!neg])), collapse = "; ")),
  "- **Célula** [a, b]: pontos da grade da MRT em volta do dia do mínimo (`findInterval`). **Distância:** número de células entre ela e a MRT (0 = a MRT é a ou b). **Parcial:** b = p99 e b − a < 0,1 − 1e-8.",
  "- **M** = máx f″ em [a, b] = máx{f″(a), f″(b), f″ nos nós internos da `argvar` em (a, b)}, analítico (`splines::splineDesign` com `derivs = 2` na construção da `ns`); conferência por segunda diferença central com passo de 1e-3 °C. **Cota** = M·(b − a)²/8. **Razão MRT** = −u_min/cota; **razão célula** = [mín(f(a), f(b)) − f(x*)]/cota.",
  sprintf("- **Classes:** %s. Com a f″ numérica, as mesmas: %s. Distância 0 em %d de %d; células parciais: %d; última célula: %d.",
          paste(sprintf("%s em %d", names(table(q$classe)), as.integer(table(q$classe))), collapse = "; "), sn(!para_num), sum(q$distancia == 0L, na.rm = TRUE), n_neg,
          sum(q$parcial, na.rm = TRUE), sum(q$ultima, na.rm = TRUE)),
  sprintf("- **Coerência das razões** (conferência descritiva acrescentada pela auditoria independente, achado 2; não muda a classe da especificação): razão célula ≥ razão MRT − 1e-9 em %d de %d. Com as bases iguais e a MRT como mínimo da grade, vale sempre; nas %d, as duas razões são iguais (diferença máxima %s), porque a MRT é um dos extremos da célula.",
          sum(q$razao_celula >= q$razao_mrt - 1e-9), n_neg, n_neg, sci(max(abs(q$razao_celula - q$razao_mrt)), 1)),
  sprintf("- **Faixa de M:** %s a %s °C⁻² (numérico: %s a %s). **Razões máximas:** MRT %s; célula %s.", fx(min(q$M), 5), fx(max(q$M), 5), fx(min(q$M_num), 5), fx(max(q$M_num), 5),
          fx(max(q$razao_mrt)), fx(max(q$razao_celula))),
  sprintf("- **Recife:** u_min = %s; célula de %s °C (%s); M = %s °C⁻² (numérico %s); o u_min exige M ≥ 8·|u_min|/h² = %s °C⁻²; M ≥ 0,033 °C⁻² (o limite da errata, com h = 0,1 °C): %s.",
          sci(rec$u_min), fx(rec$h, 2), if (isTRUE(rec$parcial)) "parcial" else "inteira", fx(rec$M, 5), fx(rec$M_num, 5), fx(8 * abs(rec$u_min) / rec$h^2, 5), sn(rec$M >= 0.033)), "",
  tabela_md(data.frame(Concentração = nome[q$recorte_principal], MRT = fx(q$mrt), a = fx(q$a), b = fx(q$b), h = fx(q$h, 2), Distância = as.character(q$distancia), `Última` = sn(q$ultima),
                       Parcial = sn(q$parcial), u_min = sci(q$u_min), `M (°C⁻²)` = fx(q$M, 5), `M numérico` = fx(q$M_num, 5), Cota = sci(q$cota), `Razão MRT` = fx(q$razao_mrt),
                       `Razão célula` = fx(q$razao_celula), Classe = q$classe, `Classe (f″ numérica)` = q$classe_num, check.names = FALSE)), "",
  "## Contribuições negativas ao AN (conferência do CSV do 46, sem imprimir linhas)", "",
  sprintf("- Principal, soma nas 26: fora do p1–p99 %s eventos; dentro, %s. Fora = −38,70 com duas casas: %s.", br(soma_fora, 2), br(soma_dentro, 3), sn(neg_ok)), "",
  "## Autoauditoria (código próprio: `splines::ns` com os nós e os Boundary.knots da `argvar`, grade e célula próprias, f″ pelo polinômio cúbico exato de cada trecho)", "",
  sprintf("- Concentrações: Recife e %s (a primeira, na ordem travada, das três em que o teste (ii) do item 2 caiu e que está entre as de u_min < −1e-8).", nome[[aud_2]]), "",
  tabela_md(data.frame(Concentração = nome[autoaud$recorte_principal], `Dif. u_min` = sci(autoaud$dif_u_min, 1), `Célula igual` = sn(autoaud$celula_igual),
                       `Dif. relativa de M` = sci(autoaud$dif_rel_M, 1), Resultado = ifelse(autoaud$ok, "ok", "DIFERENTE"), check.names = FALSE)), "",
  "## Resultado", "",
  if (para) c("**PARADA.** Motivo(s):", sprintf("- %s;", paradas), "", "Nada foi corrigido. Os passos 5 e 6 da mensagem v1.1 ficam suspensos.") else
    sprintf("**Sem parada.** A grade começa no p1 e termina no p99 nas 26; as %d concentrações com u_min < −1e-8 são classe (a), %s. Causa dos negativos dentro do p1–p99: resolução da grade de 0,1 °C (errata, item 2, causa (a)).",
            n_neg, if (all(q$distancia == 0L)) "todas com o dia do mínimo numa célula vizinha da MRT" else sprintf("%d com o dia do mínimo numa célula vizinha da MRT e %d por quase empate de mínimos locais", sum(q$distancia == 0L), sum(q$distancia > 0L))), "",
  "## Saída (fora do git)", "", sprintf("- `%s`: `%s` (por concentração; sem data, x_t, contagem ou contribuição do dia do mínimo).", f_csv, sha_csv), "",
  sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "|", if (para) paste("PARADA:", paste(paradas, collapse = " | ")) else "sem parada", "\n")
