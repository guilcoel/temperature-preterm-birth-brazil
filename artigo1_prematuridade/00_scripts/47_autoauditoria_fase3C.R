# 47_autoauditoria_fase3C.R — Fase 3, Parte C, autoauditoria: refaz com código diferente as contas principais do 45 e
# do 46 e procura cada número no texto dos logs, com a mesma formatação. Código diferente:
#   - meta-análise com o mixmeta chamado direto (sem meta_curva): coeficientes, vcov, Ψ, Q e I² (qtest), Wald à mão,
#     predição na média dos metapreditores à mão (x̄B̂) e BLUPs pelo mixmeta::blup;
#   - bases pelo splines::ns (sem dlnm::onebasis, base_combinada nem curva): curva combinada, contrastes e curvas BLUP;
#   - TMR na grade montada à mão (seq de 0,1 °C mais o x_sup), fronteira pelo índice, nas 26 e na combinada;
#   - bootstrap à mão (set.seed com o kind explícito, Cholesky, rnorm) na combinada (i = 0), em São Paulo (i = 1) e em
#     Sorocaba (i = 25), fixados no desvio 77(g);
#   - lag–resposta: q_TMR por approx, centro por quantile, coeficientes de lag pelos 16 coeficientes à mão (sem
#     crossreduce), meta-análise com o mixmeta direto e soma dos lags à mão;
#   - AN forward à mão (principal) em São Paulo e Sorocaba, nos cinco componentes; totais das 26 e eCI pela soma das
#     simulações; denominadores recontados na série.
# Só agregados saem no log. Grava logs/autoauditoria_parteC_fase3_<FASE3_DATA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/47_autoauditoria_fase3C.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("autoauditoria_parteC_fase3_", hoje, ".md")); stopifnot(!file.exists(arq))
suppressPackageStartupMessages({ library(mixmeta); library(splines) })
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
R <- list(); reg <- function(item, o_que, n, ok) R[[length(R) + 1]] <<- data.frame(Item = item, `Conferência` = o_que, N = n, Resultado = if (isTRUE(ok)) "igual" else "DIFERENTE", check.names = FALSE)
perto <- function(a, b, tol) { a <- as.numeric(a); b <- as.numeric(b); length(a) == length(b) && all(is.finite(a) == is.finite(b)) && max(abs(a - b)[is.finite(a)], 0) <= tol }
lg <- function(n) paste(readLines(file.path("logs", paste0(n, "_fase3_", hoje, ".md")), encoding = "UTF-8"), collapse = "\n")
L45 <- lg("segunda_etapa"); L46 <- lg("fracao_atribuivel")
no_texto <- function(item, o_que, L, alvos) reg(item, o_que, length(alvos), all(vapply(alvos, function(a) grepl(a, L, fixed = TRUE), TRUE)))

# ------------------------------------------------------------------ entradas (SHA-256 contra os logs)
f45 <- file.path("01_saidas", "fase3", paste0("segunda_etapa_principal_fase3_", hoje, ".rds")); f46 <- file.path("01_saidas", "fase3", paste0("fracao_atribuivel_fase3_", hoje, ".csv")); fneg <- file.path("01_saidas", "fase3", paste0("contribuicoes_negativas_fase3_", hoje, ".csv"))
fsim <- file.path("01_saidas", "fase3", paste0("fracao_atribuivel_simulacoes_fase3_", hoje, ".rds"))
ok_sha <- grepl(sprintf("`%s`: `%s`", f45, sha(f45)), L45, fixed = TRUE) && grepl(sprintf("`%s`: `%s`", f46, sha(f46)), L46, fixed = TRUE) && grepl(sprintf("`%s`: `%s`", fsim, sha(fsim)), L46, fixed = TRUE) &&
  grepl(sprintf("`%s`: `%s`", fneg, sha(fneg)), L46, fixed = TRUE)
reg("Entradas", "RDS e CSV do 45 e do 46 com os SHA-256 dos logs", 4, ok_sha); if (!ok_sha) stop("saídas do 45/46 diferentes das registradas")
f_rds2 <- "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds"; f_ser <- "01_saidas/fase1/serie_ptb_principal.rds"; f_ref <- "01_saidas/fase1/referencias_exposicao.csv"
f_a0 <- "01_saidas/fase3/percentis_exposicao_fase3_20261013.csv"
stopifnot(sha(f_rds2) == "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d", sha(f_ser) == "635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917",
          sha(f_ref) == "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467", sha(f_a0) == "e2bd54e9fc2df3689916331c0db79000b4fd01e1ed3d48f6c536c4a3a099b490")
r45 <- readRDS(f45); a46 <- utils::read.csv(f46, colClasses = c(recorte_principal = "character")); sm46 <- readRDS(fsim)$simulacoes
ORDEM <- c("3550308", "3304557", "3106200", "5300108", "2611606", "4314902", "2304400", "4106902", "2927408", "5208707", "3509502", "1302603", "1501402",
           "3205309", "3548500", "3549904", "2111300", "2408102", "2704302", "4205407", "2507507", "2211001", "2800308", "5103403", "3552205", "5002704")
nuc <- as.data.frame(cidade_nucleo()); stopifnot(identical(nuc$CD_RECORTE, ORDEM), identical(r45$ordem, ORDEM)); nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
P1 <- lapply(readRDS(f_rds2)$resultados[ORDEM], `[[`, "principal")
ref <- utils::read.csv(f_ref, colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ORDEM, ref$recorte_principal), ]
gr <- utils::read.csv(f_a0, colClasses = c(recorte_principal = "character"))
pr <- function(rot) as.numeric(sub(",", ".", sub("^p", "", rot), fixed = TRUE)) / 100
gpc <- function(r) { z <- gr[gr$recorte_principal == r, ]; z <- z[order(pr(z$rotulo)), ]; setNames(z$valor, z$rotulo) }
eixo <- gpc("eixo_medio"); ep <- pr(names(eixo))
md <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1)
Bns <- function(x, av) unclass(splines::ns(x, knots = av$knots, Boundary.knots = av$Boundary.knots, intercept = isTRUE(av$intercept)))[, , drop = FALSE]
grade_mao <- function(a, b) { g <- seq(a, b, by = 0.1); if (b - g[length(g)] > 1e-8) g <- c(g, b); g }
z95 <- qnorm(0.975)

# ------------------------------------------------------------------ C1: mixmeta direto
log_msg("C1")
Y <- t(vapply(ORDEM, function(r) unname(P1[[r]]$reduzida$coef), numeric(4))); S <- lapply(ORDEM, function(r) unname(P1[[r]]$reduzida$vcov))
m <- mixmeta(Y ~ media + amplitude, S = S, data = md, method = r45$meta$metodo, bscov = r45$meta$bscov)
m0 <- mixmeta(Y ~ 1, S = S, data = md, method = r45$meta$metodo, bscov = r45$meta$bscov)
reg("C1", "coeficientes, vcov e Ψ da meta-regressão (mixmeta direto)", 3, perto(coef(m), r45$meta$coef_meta, 1e-10) && perto(vcov(m), r45$meta$vcov_meta, 1e-12) && perto(m$Psi, r45$meta$Psi, 1e-12))
qq <- function(mm) { q <- qtest(mm); c(Q = unname(q$Q[1]), df = unname(q$df[1]), I2 = max(0, (q$Q[1] - q$df[1]) / q$Q[1]) * 100) }
h1 <- qq(m); h0 <- qq(m0)
reg("C1", "Q, gl e I² residual e total", 2, perto(h1, unlist(r45$meta$heterogeneidade$residual[c("Q", "df", "I2")]), 1e-8) && perto(h0, unlist(r45$meta$heterogeneidade$total[c("Q", "df", "I2")]), 1e-8))
no_texto("C1", "Q e I² no log do 45", L45, c(sprintf("| residual | %s | ", br(h1[["Q"]], 2)), sprintf("| %s%% |", br(h1[["I2"]], 1)), sprintf("| total | %s | ", br(h0[["Q"]], 2)), sprintf("| %s%% |", br(h0[["I2"]], 1))))
wd <- vapply(c("media", "amplitude"), function(t) { ind <- grep(paste0("\\.", t, "$"), names(coef(m))); b <- coef(m)[ind]; drop(t(b) %*% solve(vcov(m)[ind, ind]) %*% b) }, 0)
reg("C1", "Wald de cada metapreditor (forma quadrática à mão)", 2, perto(wd, r45$meta$wald$estatistica, 1e-8))
no_texto("C1", "Wald no log do 45", L45, sprintf("| %s | %s | 4 |", names(wd), br(wd, 2)))
Bm <- matrix(coef(m), 3, 4, byrow = TRUE); xb <- c(1, colMeans(md)); pm <- drop(xb %*% Bm); Xb <- kronecker(t(xb), diag(4)); pv <- Xb %*% vcov(m) %*% t(Xb)
reg("C1", "predição na média dos metapreditores (x̄B̂ e vcov à mão)", 2, perto(pm, r45$meta$pred_media$coef, 1e-12) && perto(pv, r45$meta$pred_media$vcov, 1e-14))
ev <- eigen(m$Psi, symmetric = TRUE, only.values = TRUE)$values; k_ef <- sum(ev > 1e-8 * max(ev))
no_texto("C1", "autovalores e posto efetivo de Ψ no log do 45", L45, sprintf("autovalores de Ψ %s; posto efetivo %d de 4",
         paste(c(formatC(ev[seq_len(k_ef)], format = "e", digits = 3), if (k_ef < 4) sprintf("%d abaixo de 1e-8 × o maior", 4 - k_ef)), collapse = "; "), k_ef))
bl <- blup(m, vcov = TRUE)
reg("C1", "BLUPs e vcov dos BLUPs (mixmeta::blup)", 26, perto(unlist(lapply(bl, `[[`, "blup")), unlist(lapply(r45$blup, `[[`, "coef")), 1e-10) && perto(unlist(lapply(bl, `[[`, "vcov")), unlist(lapply(r45$blup, `[[`, "vcov")), 1e-12))

# ------------------------------------------------------------------ C2: curva combinada com splines::ns, TMR e bootstrap à mão
log_msg("C2")
avs <- lapply(ORDEM, function(r) P1[[r]]$base$argvar)
bm <- list(knots = colMeans(do.call(rbind, lapply(avs, `[[`, "knots"))), Boundary.knots = colMeans(do.call(rbind, lapply(avs, `[[`, "Boundary.knots"))), intercept = FALSE)
reg("C2", "base combinada (nós e Boundary.knots médios)", 2, perto(bm$knots, r45$base$knots, 1e-12) && perto(bm$Boundary.knots, r45$base$Boundary.knots, 1e-12))
gc <- grade_mao(eixo[["p1"]], eixo[["p99"]]); eta <- drop(Bns(gc, bm) %*% pm); ic0 <- which.min(eta); tmr_c <- gc[ic0]; fr_c <- ic0 %in% c(1, length(gc))
tc45 <- r45$tmr[r45$tmr$nivel == "combinada", ]
reg("C2", "TMR combinada na grade à mão e fronteira pelo índice", 2, perto(tmr_c, tc45$tmr, 1e-12) && identical(fr_c, tc45$fronteira))
q_mao <- approx(unname(eixo), ep, xout = tmr_c)$y
reg("C2", "q_TMR (approx no eixo médio)", 1, perto(q_mao, r45$q_tmr, 1e-14))
boot_mao <- function(cf, V, av, a, b, i) { g <- grade_mao(a, b); set.seed(20261001 + i, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
  sm <- cf + t(chol(V)) %*% matrix(rnorm(length(cf) * 1000), length(cf)); t <- g[apply(Bns(g, av) %*% sm, 2, which.min)]
  structure(quantile(t, c(0.025, 0.975), type = 7, names = FALSE), pontas = c(mean(t == g[1]), mean(t == g[length(g)]))) }
bc <- boot_mao(pm, pv, bm, eixo[["p1"]], eixo[["p99"]], 0)
reg("C2", "IC da TMR combinada (bootstrap à mão, i = 0)", 1, perto(bc, c(tc45$ic_li, tc45$ic_ls), 1e-12))
reg("C2", "proporção de sorteios no x1 e no x99 (bootstrap à mão)", 2, perto(attr(bc, "pontas"), c(tc45$prop_sorteios_x_inf, tc45$prop_sorteios_x_sup), 0))
no_texto("C2", "TMR combinada, percentil e IC no log do 45", L45, sprintf("**TMR combinada:** %s °C, no percentil %s do eixo médio (q_TMR = %s); IC 95%% do bootstrap da D4(a): %s a %s °C.",
                                                                       br(tmr_c, 1), br(100 * q_mao, 1), br(q_mao, 4), br(bc[1], 1), br(bc[2], 1)))
PCT <- c("p99", "p1", "p95", "p90", "p10", "p5")
Xc <- sweep(Bns(unname(eixo[PCT]), bm), 2, Bns(tmr_c, bm)[1, ]); lr <- drop(Xc %*% pm); se <- sqrt(rowSums((Xc %*% pv) * Xc))
cc45 <- r45$contrastes[r45$contrastes$nivel == "combinada", ]
reg("C2", "RR combinados em x99, x1, x95, x90, x10 e x5 (log RR e EP)", 6, perto(lr, cc45$logrr, 1e-12) && perto(se, cc45$ep, 1e-12))
no_texto("C2", "contrastes combinados no log do 45", L45, sprintf("| %s | %s | %s (%s a %s) |", PCT, br(eixo[PCT], 3), br(exp(lr), 3), br(exp(lr - z95 * se), 3), br(exp(lr + z95 * se), 3)))

# ------------------------------------------------------------------ C3: TMR BLUP nas 26 (grade à mão) e bootstrap de SP e Sorocaba
log_msg("C3")
tb45 <- r45$tmr[r45$tmr$nivel == "blup", ]; tb_ok <- fr_ok <- logical(26); rr_ok <- logical(26)
for (k in seq_along(ORDEM)) { r <- ORDEM[k]; av <- P1[[r]]$base$argvar; g <- gpc(r); cf <- unname(r45$blup[[r]]$coef); V <- unname(r45$blup[[r]]$vcov)
  gg <- grade_mao(g[["p1"]], g[["p99"]]); e <- drop(Bns(gg, av) %*% cf); j <- which.min(e)
  tb_ok[k] <- perto(gg[j], tb45$tmr[tb45$recorte_principal == r], 1e-12); fr_ok[k] <- identical(j %in% c(1, length(gg)), tb45$fronteira[tb45$recorte_principal == r])
  X <- sweep(Bns(unname(g[PCT]), av), 2, Bns(gg[j], av)[1, ]); d45 <- r45$contrastes[r45$contrastes$nivel == "blup" & r45$contrastes$recorte_principal == r, ]
  rr_ok[k] <- perto(drop(X %*% cf), d45$logrr, 1e-12) && perto(sqrt(rowSums((X %*% V) * X)), d45$ep, 1e-12) }
reg("C3", "TMR BLUP na grade à mão nas 26", 26, all(tb_ok)); reg("C3", "fronteira pelo índice nas 26", 26, all(fr_ok))
reg("C3", "RR por concentração nos p99, p95, p90, p10, p5 e p1 (log RR e EP; splines::ns)", 26, all(rr_ok))
med_ok <- TRUE; n_med <- 0L
for (r in tb45$recorte_principal[tb45$fronteira]) { av <- P1[[r]]$base$argvar; g <- gpc(r); cf <- unname(r45$blup[[r]]$coef); V <- unname(r45$blup[[r]]$vcov)
  X <- sweep(Bns(unname(g[PCT]), av), 2, Bns(g[["p50"]], av)[1, ]); d45 <- r45$contrastes[r45$contrastes$nivel == "blup_mediana" & r45$contrastes$recorte_principal == r, ]
  med_ok <- med_ok && nrow(d45) == 6 && perto(drop(X %*% cf), d45$logrr, 1e-12) && perto(sqrt(rowSums((X %*% V) * X)), d45$ep, 1e-12) && perto(d45$cen, rep(g[["p50"]], 6), 0); n_med <- n_med + 1L }
reg("C3", "RR contra a mediana nas concentrações com TMR BLUP na fronteira (splines::ns)", n_med, med_ok && n_med == sum(tb45$fronteira) && sum(r45$contrastes$nivel == "blup_mediana") == 6 * n_med)
n_fr <- sum(tb45$fronteira); no_texto("C3", "número de TMR BLUP na fronteira no log do 45", L45, sprintf("**TMR BLUP na fronteira da grade p1–p99:** %d de 26", n_fr))
for (r in c("3550308", "3552205")) { i <- match(r, ORDEM); g <- gpc(r)
  b <- boot_mao(unname(r45$blup[[r]]$coef), unname(r45$blup[[r]]$vcov), P1[[r]]$base$argvar, g[["p1"]], g[["p99"]], i); t1 <- tb45[tb45$recorte_principal == r, ]
  reg("C3", sprintf("IC da TMR BLUP de %s (bootstrap à mão, i = %d)", nome[[r]], i), 1, perto(b, c(t1$ic_li, t1$ic_ls), 1e-12))
  reg("C3", sprintf("proporção de sorteios no p1 e no p99 de %s (bootstrap à mão)", nome[[r]]), 2, perto(attr(b, "pontas"), c(t1$prop_sorteios_x_inf, t1$prop_sorteios_x_sup), 0))
  no_texto("C3", sprintf("TMR e IC de %s no log do 45", nome[[r]]), L45, sprintf("| %s | %2d | %s (%s a %s) |", nome[[r]], i, br(t1$tmr, 1), br(b[1], 1), br(b[2], 1))) }

# ------------------------------------------------------------------ C4: lag–resposta à mão
log_msg("C4")
s <- readRDS(f_ser); s <- as.data.frame(s)[s$data >= as.Date("2012-04-07") & s$data <= as.Date("2024-08-06"), c("recorte_principal", "data", "tmean_nucleo", "ptb", "janela_principal")]
ex <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_nucleo"))); ex$data <- as.Date(ex$data)
ex <- ex[ex$data >= as.Date("2012-01-01") & ex$data <= as.Date("2024-12-31"), ]
al <- r45$lagresposta$arglag; BL <- function(l) unclass(splines::ns(l, knots = al$knots, Boundary.knots = al$Boundary.knots, intercept = TRUE))
cen_ok <- red_ok <- logical(26); C99 <- C01 <- matrix(NA, 26, 4); V99 <- V01 <- list()
for (k in seq_along(ORDEM)) { r <- ORDEM[k]; av <- P1[[r]]$base$argvar; g <- gpc(r)
  tr <- ex$tmean_nucleo[ex$recorte_principal == r][order(ex$data[ex$recorte_principal == r])]
  cen <- if (fr_c) quantile(tr, 0.5, type = 7, names = FALSE) else quantile(tr, q_mao, type = 7, names = FALSE)
  cen_ok[k] <- perto(cen, r45$lagresposta$unidades$centro[r45$lagresposta$unidades$recorte_principal == r], 1e-12)
  c16 <- unname(P1[[r]]$coef_cb); V16 <- unname(P1[[r]]$vcov_cb)
  red <- function(v) { dv <- Bns(v, av)[1, ] - Bns(cen, av)[1, ]; M <- kronecker(t(dv), diag(4)); list(coef = drop(M %*% c16), vcov = M %*% V16 %*% t(M)) }
  a <- red(g[["p99"]]); b <- red(g[["p1"]]); C99[k, ] <- a$coef; C01[k, ] <- b$coef; V99[[k]] <- a$vcov; V01[[k]] <- b$vcov
  red_ok[k] <- perto(a$coef, r45$lagresposta$reduzidos_p99[[r]]$coef, 1e-12) && perto(b$coef, r45$lagresposta$reduzidos_p1[[r]]$coef, 1e-12) &&
    perto(a$vcov, r45$lagresposta$reduzidos_p99[[r]]$vcov, 1e-14) && perto(b$vcov, r45$lagresposta$reduzidos_p1[[r]]$vcov, 1e-14) }
reg("C4", "centro da lag–resposta (quantile no q_TMR, ou p50 na fronteira) nas 26", 26, all(cen_ok))
reg("C4", "coeficientes de lag no p99 e no p1 pelos 16 coeficientes à mão (sem crossreduce) nas 26", 52, all(red_ok))
ml <- function(C, V, mm) { y <- C; fit <- mixmeta(y ~ media + amplitude, S = V, data = md, method = mm$metodo, bscov = mm$bscov)
  B <- matrix(coef(fit), 3, 4, byrow = TRUE); p <- drop(xb %*% B); X <- kronecker(t(xb), diag(4)); list(coef = p, vcov = X %*% vcov(fit) %*% t(X)) }
p99 <- ml(C99, V99, r45$lagresposta$meta_p99); p01 <- ml(C01, V01, r45$lagresposta$meta_p1)
reg("C4", "predição na média da lag–resposta no p99 e no p1 (mixmeta direto)", 2, perto(p99$coef, r45$lagresposta$meta_p99$pred_media$coef, 1e-10) && perto(p01$coef, r45$lagresposta$meta_p1$pred_media$coef, 1e-10))
sl <- function(p) { s1 <- colSums(BL(0:7)); lr <- sum(s1 * p$coef); se <- sqrt(drop(t(s1) %*% p$vcov %*% s1)); c(lr, se) }
s99 <- sl(p99); s01 <- sl(p01)
reg("C4", "soma dos lags 0–7 no p99 e no p1 (à mão)", 2, perto(c(s99, s01), c(log(r45$lagresposta$soma["p99", "rr"]), r45$lagresposta$soma["p99", "ep"], log(r45$lagresposta$soma["p1", "rr"]), r45$lagresposta$soma["p1", "ep"]), 1e-10))
fs <- function(v) sprintf("%s (%s a %s)", br(exp(v[1]), 3), br(exp(v[1] - z95 * v[2]), 3), br(exp(v[1] + z95 * v[2]), 3))
no_texto("C4", "soma dos lags no log do 45", L45, sprintf("p99 %s; p1 %s.", fs(s99), fs(s01)))
lag_int <- function(p) t(vapply(0:7, function(l) { b <- BL(l)[1, ]; c(sum(b * p$coef), sqrt(drop(t(b) %*% p$vcov %*% b))) }, numeric(2)))
L99 <- lag_int(p99); L01 <- lag_int(p01)
no_texto("C4", "RR por lag inteiro no log do 45", L45, sprintf("| %d | %s | %s |", 0:7, apply(L99, 1, fs), apply(L01, 1, fs)))

# ------------------------------------------------------------------ C5: denominadores, AN forward à mão (SP e Sorocaba), totais
log_msg("C5")
den_mao <- vapply(ORDEM, function(r) sum(s$ptb[s$recorte_principal == r & s$janela_principal]), 0)
den46 <- a46$denominador[a46$analise == "principal" & a46$componente == "total"][match(ORDEM, a46$recorte_principal[a46$analise == "principal" & a46$componente == "total"])]
reg("C5", "denominadores recontados na série = os do 46 = n$eventos da Fase 2", 26, perto(den_mao, den46, 0) && perto(den_mao, vapply(ORDEM, function(r) P1[[r]]$n$eventos, 0L), 0))
for (r in c("3550308", "3552205")) { z <- s[s$recorte_principal == r, ]; z <- z[order(z$data), ]; z <- z[z$janela_principal, ]; av <- P1[[r]]$base$argvar; g <- gpc(r)
  cf <- unname(r45$blup[[r]]$coef); tmr <- tb45$tmr[tb45$recorte_principal == r]; x <- z$tmean_nucleo; y <- z$ptb; n <- length(x)
  cbar <- vapply(seq_len(n), function(t) if (t + 7 <= n) mean(y[t:(t + 7)]) else NA_real_, 0)
  mao <- function(rg) { xx <- x; if (!is.null(rg)) xx[xx < rg[1] | xx > rg[2]] <- tmr; af <- 1 - exp(-drop(sweep(Bns(xx, av), 2, Bns(tmr, av)[1, ]) %*% cf)); an <- af * cbar; ok <- !is.na(an)
    sum(an[ok]) / sum(cbar[ok]) * sum(y) }
  rgs <- list(total = NULL, calor = c(tmr, Inf), frio = c(-Inf, tmr), calor_extremo = c(max(g[["p97,5"]], tmr), Inf), frio_extremo = c(-Inf, min(g[["p2,5"]], tmr)))
  an_m <- vapply(rgs, mao, 0); d <- a46[a46$analise == "principal" & a46$recorte_principal == r, ]; d <- d[match(names(rgs), d$componente), ]
  reg("C5", sprintf("AN forward à mão, %s, cinco componentes (principal)", nome[[r]]), 5, perto(an_m, d$an, 1e-8)) }
reg("C5", "AF, AF inferior e AF superior = AN / denominador em todas as linhas do 46", nrow(a46), perto(c(a46$af, a46$af_li, a46$af_ls), c(a46$an, a46$an_li, a46$an_ls) / a46$denominador, 1e-14))
ng46 <- utils::read.csv(file.path("01_saidas", "fase3", paste0("contribuicoes_negativas_fase3_", hoje, ".csv")), colClasses = c(recorte_principal = "character"))
local({ r <- "3552205"; z <- s[s$recorte_principal == r, ]; z <- z[order(z$data), ]; z <- z[z$janela_principal, ]; av <- P1[[r]]$base$argvar; g <- gpc(r)
  tmr <- tb45$tmr[tb45$recorte_principal == r]; x <- z$tmean_nucleo; y <- z$ptb; n <- length(x)
  cbar <- vapply(seq_len(n), function(t) if (t + 7 <= n) mean(y[t:(t + 7)]) else NA_real_, 0)
  v <- (1 - exp(-drop(sweep(Bns(x, av), 2, Bns(tmr, av)[1, ]) %*% unname(r45$blup[[r]]$coef)))) * cbar; ng <- !is.na(v) & v < 0; fora <- x < g[["p1"]] | x > g[["p99"]]
  d <- ng46[ng46$analise == "principal" & ng46$recorte_principal == r, ]
  reg("C5", "contribuições negativas de Sorocaba (principal), total, fora e dentro de p1–p99, à mão", 3,
      perto(c(sum(v[ng]), sum(v[ng & fora]), sum(v[ng & !fora])), c(d$soma_negativas, d$soma_negativas_fora_p1_p99, d$soma_negativas_dentro_p1_p99), 1e-8)) })
COMP <- c("total", "calor", "frio", "calor_extremo", "frio_extremo"); tot_ok <- TRUE; txt_tot <- character(0)
for (a in c("principal", "ponte", "backward")) for (cmp in COMP) {
  an <- sum(a46$an[a46$analise == a & a46$componente == cmp & a46$recorte_principal != "total"]); smt <- Reduce(`+`, lapply(ORDEM, function(r) sm46[[a]][[r]][, cmp]))
  q <- quantile(smt, c(0.025, 0.975), type = 7, names = FALSE); dt <- a46[a46$analise == a & a46$componente == cmp & a46$recorte_principal == "total", ]
  tot_ok <- tot_ok && perto(c(an, q, an / sum(den_mao)), c(dt$an, dt$an_li, dt$an_ls, dt$af), 1e-8)
  txt_tot <- c(txt_tot, sprintf("| %s (%s a %s) | %s%% (%s a %s) |", br(an, 0), br(q[1], 0), br(q[2], 0), br(100 * an / sum(den_mao), 2), br(100 * q[1] / sum(den_mao), 2), br(100 * q[2] / sum(den_mao), 2))) }
reg("C5", "totais das 26 (AN, eCI pela soma das simulações e AF), três análises × cinco componentes", 15, tot_ok)
no_texto("C5", "totais no log do 46", L46, txt_tot)
no_texto("C5", "denominador total no log do 46", L46, sprintf("Total das 26: %s eventos.", br(sum(den_mao), 0)))

stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
res <- do.call(rbind, R); n_ok <- sum(res$Resultado == "igual")
md_txt <- c("# Fase 3, Parte C: autoauditoria", "",
            sprintf("- **Gerado por:** `00_scripts/47_autoauditoria_fase3C.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
            sprintf("- **BLAS/LAPACK:** `%s` / `%s`.", sessionInfo()$BLAS, sessionInfo()$LAPACK),
            "- **Método:** as contas principais do 45 e do 46 refeitas com código diferente e comparadas com as saídas (RDS e CSV, com os SHA-256 dos logs); os números refeitos foram procurados no texto dos logs com a mesma formatação.",
            "- **Código diferente:** `mixmeta` chamado direto (sem `meta_curva`); bases pelo `splines::ns` (sem `onebasis`, `base_combinada` e `curva`); grade da TMR montada à mão; bootstrap à mão na combinada (i = 0), em São Paulo (i = 1) e em Sorocaba (i = 25), fixados no desvio 77(g); coeficientes de lag pelos 16 coeficientes à mão (sem `crossreduce`); AN *forward* à mão em São Paulo e Sorocaba; totais pela soma das simulações; denominadores recontados na série.",
            "- **Tolerâncias:** 1e-8 a 1e-14, conforme a escala de cada quantidade; textos com igualdade exata.", "",
            sprintf("## Resultado: %d de %d conferências iguais", n_ok, nrow(res)), "", tabela_md(res), "",
            sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md_txt, arq, useBytes = TRUE)
cat("gravado:", arq, "|", n_ok, "de", nrow(res), "iguais\n")
