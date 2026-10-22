# 33_autoauditoria_fase2A.R — Fase 2, A3.1: autoauditoria da Parte A. Recalcula, com código diferente, os números dos
# logs do 30 (diagnóstico do offset), do 31 (testes) e do 38 (diagnóstico do 5b) e confere contra o texto deles.
# Código diferente de propósito:
#   - A0: soma de quadrados por estrato com split/vapply e ACF manual (produto de defasagens), sem acf();
#   - base fixa: quantil tipo 7 à mão; θ por kronecker + qr.solve, sem lm.fit; verdadeiro θ pelo crossreduce(coef = θ);
#   - teste 7: viés esperado com glm de Poisson e factor(estrato), sem gnm;
#   - Monte Carlo: as mesmas réplicas (mesma semente e ordem), reajustadas com glm(quasipoisson) + factor(estrato) e
#     crossreduce, sem ajusta_dlnm(); cobertura, viés, EP, γ̂ e φ recalculados e comparados com o log do 31; IC de Wilson
#     pelo prop.test(correct = FALSE); no 5b, as 1.000 réplicas do 38 (a mesma sequência), com a chance de cobertura
#     acima de 0,98 por soma de dbinom (sem pbinom);
#   - ruído branco do teste 9: as mesmas 200 séries, com acf(type = "partial"), sem .pacf_por_unidade();
#   - defeitos: os testes rápidos de cada cópia com defeito rodam de novo; os que falham têm de estar na lista do log.
# Lê a série principal só no bloco da A0 (log_w e calendário). Grava logs/autoauditoria_fase2A_<FASE2_DATA>.md.
# Uso (de artigo1_prematuridade/):  FASE2_DATA=AAAAMMDD Rscript 00_scripts/33_autoauditoria_fase2A.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE2_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("autoauditoria_fase2A_", hoje, ".md")); stopifnot(!file.exists(arq))
txt <- function(n) paste(readLines(file.path("logs", paste0(n, "_fase2_", hoje, ".md")), encoding = "UTF-8"), collapse = "\n")
L30 <- txt("diagnostico_offset"); L31 <- txt("testes_ajusta_dlnm"); L38 <- txt("diagnostico_t05b")
suppressPackageStartupMessages({ library(dlnm); library(gnm) })
CC <- file.path("..", "codigo_compartilhado")
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
R <- list()
no_texto <- function(item, o_que, alvo, textos) {
  ok <- vapply(textos, function(s) grepl(s, alvo, fixed = TRUE), logical(1))
  R[[length(R) + 1]] <<- data.frame(Item = item, Conferência = o_que, N = length(textos),
                                    Resultado = if (all(ok)) "igual" else sprintf("AUSENTE: %d de %d trecho(s)", sum(!ok), length(ok)),
                                    check.names = FALSE, stringsAsFactors = FALSE)
}
confere <- function(item, o_que, a, b, tol = 0) {
  ok <- length(a) == length(b) && !anyNA(a) && !anyNA(b) && all(abs(as.numeric(a) - as.numeric(b)) <= tol)
  R[[length(R) + 1]] <<- data.frame(Item = item, Conferência = o_que, N = length(a), Resultado = if (ok) "igual" else "DIFERENTE",
                                    check.names = FALSE, stringsAsFactors = FALSE)
}
q7 <- function(x, p) { x <- sort(x); n <- length(x); h <- (n - 1) * p + 1; lo <- floor(h); hi <- pmin(lo + 1, n); x[lo] + (h - lo) * (x[hi] - x[lo]) }

# ------------------------------------------------------------------ A0 (log do 30): só log_w e calendário
log_msg("A0")
nuc <- as.data.frame(cidade_nucleo()); nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE); ordem <- nuc$CD_RECORTE
s <- readRDS(file.path("01_saidas", "fase1", "serie_ptb_principal.rds"))
s <- s[s$janela_principal, c("recorte_principal", "data", "log_w", "estrato", "feriado_nacional", "carnaval", "moveis")]
acf_manual <- function(x, k) { x <- x - mean(x); sum(x[1:(length(x) - k)] * x[(1 + k):length(x)]) / sum(x^2) }
linhas30 <- vapply(ordem, function(r) {
  x <- s[s$recorte_principal == r, ]; x <- x[order(x$data), ]
  grupos <- split(x$log_w, x$estrato)
  ssw <- sum(vapply(grupos, function(g) sum((g - mean(g))^2), 0)); sst <- stats::var(x$log_w) * (nrow(x) - 1)
  medias <- vapply(grupos, mean, 0); dev <- x$log_w - medias[x$estrato]
  fer <- (x$feriado_nacional + x$carnaval + x$moveis) > 0
  a <- vapply(c(1, 7, 14, 28, 365), function(k) acf_manual(dev, k), 0)
  paste0("| ", nome[r], " | ", br(ssw / sst, 4), " | ", paste(br(a, 3), collapse = " | "), " | ", br(mean(dev[fer]), 5), " | ", br(mean(dev[!fer]), 5), " |")
}, "")
no_texto("A0", "as 26 linhas da tabela por concentração (fração intra, 5 ACF, desvios em feriados e demais dias)", L30, linhas30)
rm(s); invisible(gc())

# ------------------------------------------------------------------ base fixa, θ, verdadeiros (log do 31)
log_msg("base fixa e θ")
f <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = f); sys.source(file.path(CC, "tests", "gera_sintetico.R"), envir = f)
set.seed(20261001); xref <- f$gera_temp(100000)
qq <- q7(xref, c(.10, .50, .75, .90, .99)); bk <- range(xref)
no_texto("Base fixa", "nós, cen, p99 e Boundary.knots (quantil tipo 7 à mão)", L31,
         c(paste(br(qq[c(1, 3, 4)], 3), collapse = "; "), paste("cen = p50 =", br(qq[2], 3)), paste("p99 =", br(qq[5], 3)), paste(br(bk, 3), collapse = " e ")))
argvar <- list(fun = "ns", knots = qq[c(1, 3, 4)], Boundary.knots = bk); arglag <- list(fun = "ns", knots = logknots(7, nk = 2), intercept = TRUE)
xg <- seq(bk[1], bk[2], length.out = 301)
bx <- unclass(do.call(onebasis, c(list(x = xg), argvar))); bl <- unclass(do.call(onebasis, c(list(x = 0:7), arglag)))
X <- do.call(rbind, lapply(1:8, function(j) t(vapply(seq_along(xg), function(i) kronecker(bx[i, ], bl[j, ]), numeric(16)))))
y <- unlist(lapply(0:7, function(l) if (l <= 2) 0.01 * pmax(xg - qq[3], 0) else rep(0, length(xg))))
th <- qr.solve(X, y); r2 <- 1 - sum((y - X %*% th)^2) / sum((y - mean(y))^2)
cbr <- crossbasis(xref[1:50], lag = 7, argvar = argvar, arglag = arglag)
vt <- crossreduce(cbr, coef = th, vcov = diag(1e-20, 16), model.link = "log", type = "overall", cen = qq[2], at = qq[5])$fit[1]
no_texto("Teste 5", "θ (16, notação científica), R² e os dois verdadeiros", L31,
         c(paste(formatC(th, format = "e", digits = 4), collapse = "; "), paste("R² da projeção:**", br(r2, 4)),
           paste("versão θ (critério) =", br(vt, 5)), paste("0,03 × (p99 − p75) =", br(0.03 * (qq[5] - qq[3]), 5))))

# ------------------------------------------------------------------ teste 7: viés esperado com glm de Poisson
log_msg("teste 7: viés esperado")
bf <- list(argvar = argvar, arglag = arglag, cen = qq[2], p99 = qq[5], p75 = qq[3], lag = 7L)
set.seed(20261001); longa <- f$gera_sintetico(45000, eventos_dia = 30, gamma = 1, efeito = "nenhum", bf = bf, a_Z = 0.3, fase_Z = f$PARAM_GERADOR$t_fase, esperado = TRUE)
cbl <- crossbasis(longa$temp, lag = 7, argvar = argvar, arglag = arglag); u <- longa$janela & stats::complete.cases(cbl)
gl <- suppressWarnings(stats::glm(longa$y[u] ~ unclass(cbl)[u, ] + longa$dia_semana[u] + longa$feriado_nacional[u] + longa$carnaval[u] +
                                    longa$moveis[u] + factor(longa$estrato[u]), family = stats::poisson))
bv <- unclass(do.call(onebasis, c(list(x = c(qq[5], qq[2])), argvar))); dv <- bv[1, ] - bv[2, ]
red <- crossreduce(cbl, coef = stats::coef(gl)[2:17], vcov = stats::vcov(gl)[2:17, 2:17], model.link = "log", type = "overall", cen = qq[2])
v7 <- sum(dv * stats::coef(red)); se7 <- sqrt(drop(t(dv) %*% stats::vcov(red) %*% dv)) * sqrt(10); ep7 <- se7 / sqrt(200)
no_texto("Teste 7", "viés esperado, EP de Poisson (4.500 dias), EP de MC e razão (glm de Poisson)", L31,
         c(paste("viés esperado =", br(v7, 4)), paste("EP de Poisson para 4.500 dias =", br(se7, 4)), paste("EP de MC esperado com 200 réplicas =", br(ep7, 4)),
           paste("razão =", br(v7 / ep7, 1))))
rm(longa, cbl, gl); invisible(gc())

# ------------------------------------------------------------------ Monte Carlo: as mesmas réplicas, reajustadas com glm
log_msg("Monte Carlo com glm (mesmas réplicas)")
pr_th <- list(theta = th)
est_glm <- function(d, offset) {
  cb <- crossbasis(d$temp, lag = 7, argvar = argvar, arglag = arglag)
  ok <- d$janela & stats::complete.cases(cb); ev <- tapply(d$y[ok], d$estrato[ok], sum); u <- ok & !(d$estrato %in% names(ev)[ev == 0])
  fe <- factor(d$estrato[u]); cbu <- unclass(cb)[u, ]
  g <- switch(offset,
    z_w_gama = stats::glm(d$y[u] ~ cbu + d$dia_semana[u] + d$feriado_nacional[u] + d$carnaval[u] + d$moveis[u] + d$log_w[u] + fe, offset = d$log_z[u], family = stats::quasipoisson),
    zw = stats::glm(d$y[u] ~ cbu + d$dia_semana[u] + d$feriado_nacional[u] + d$carnaval[u] + d$moveis[u] + fe, offset = d$log_zw[u], family = stats::quasipoisson),
    nenhum = stats::glm(d$y[u] ~ cbu + d$dia_semana[u] + d$feriado_nacional[u] + d$carnaval[u] + d$moveis[u] + fe, family = stats::quasipoisson))
  cf <- stats::coef(g); i <- 2:17; rr <- crossreduce(cb, coef = cf[i], vcov = stats::vcov(g)[i, i], model.link = "log", type = "overall", cen = qq[2])
  gam <- if (offset == "z_w_gama") cf[["d$log_w[u]"]] else NA_real_
  c(est = sum(dv * stats::coef(rr)), se = sqrt(drop(t(dv) %*% stats::vcov(rr) %*% dv)), gama = gam,
    phi = sum(stats::residuals(g, type = "pearson")^2) / g$df.residual)
}
roda <- function(gerar, offsets, n_rep = 200) { set.seed(20261001); lapply(seq_len(n_rep), function(i) { d <- gerar(); lapply(offsets, function(o) est_glm(d, o)) }) }
wilson_pt <- function(k, n) suppressWarnings(as.numeric(stats::prop.test(k, n, correct = FALSE)$conf.int))   # Wilson pelo prop.test
cobre <- function(m, verd) (m[, "est"] - stats::qnorm(.975) * m[, "se"] <= verd) & (verd <= m[, "est"] + stats::qnorm(.975) * m[, "se"])
resumo <- function(m, verd) { est <- m[, "est"]; k <- sum(cobre(m, verd)); n <- nrow(m); cob <- k / n
  list(k = k, n = n, cob = cob, ep_cob = sqrt(cob * (1 - cob) / n), ic_cob = wilson_pt(k, n), vies = mean(est) - verd, ep_vies = stats::sd(est) / sqrt(n)) }
fmt <- function(s, verd) sprintf("| %s | %s (EP %s; IC Wilson [%s; %s]) | %s (EP %s; IC MC [%s; %s]) |", br(verd, 4), br(s$cob, 3), br(s$ep_cob, 4),
  br(s$ic_cob[1], 3), br(s$ic_cob[2], 3), br(s$vies, 4), br(s$ep_vies, 4), br(s$vies - 1.96 * s$ep_vies, 4), br(s$vies + 1.96 * s$ep_vies, 4))
para_mat <- function(x, k) do.call(rbind, lapply(x, `[[`, k))
g5 <- para_mat(roda(function() f$gera_sintetico(4500, eventos_dia = 30, gamma = 1.3, efeito = "theta", bf = bf, theta = th), "z_w_gama"), 1)
g5b1000 <- para_mat(roda(function() f$gera_sintetico(4500, eventos_dia = 3, gamma = 1.3, efeito = "theta", bf = bf, theta = th), "z_w_gama", n_rep = 1000), 1)
g5b <- g5b1000[1:200, ]                                              # as 200 do teste são as primeiras da mesma sequência
g6 <- para_mat(roda(function() f$gera_sintetico(4500, eventos_dia = 30, gamma = 1.3, efeito = "nenhum", bf = bf), "z_w_gama"), 1)
x7 <- roda(function() f$gera_sintetico(4500, eventos_dia = 30, gamma = 1, efeito = "nenhum", bf = bf, a_Z = 0.3, fase_Z = f$PARAM_GERADOR$t_fase), c("zw", "z_w_gama", "nenhum"))
g7zw <- para_mat(x7, 1); g7g <- para_mat(x7, 2); g7n <- para_mat(x7, 3)
no_texto("Testes 5, 5b e 6", "cobertura, viés, EP e IC de MC (reajuste com glm)", L31,
         c(fmt(resumo(g5, vt), vt), fmt(resumo(g5b, vt), vt), fmt(resumo(g6, 0), 0)))
vh <- 0.03 * (qq[5] - qq[3])
g5h <- para_mat(roda(function() f$gera_sintetico(4500, eventos_dia = 30, gamma = 1.3, efeito = "dobradica", bf = bf), "z_w_gama"), 1)
g5bh <- para_mat(roda(function() f$gera_sintetico(4500, eventos_dia = 3, gamma = 1.3, efeito = "dobradica", bf = bf), "z_w_gama"), 1)
no_texto("Testes 5 e 5b, descritivo", "dobradiça contra 0,03 × (p99 − p75) e contra o verdadeiro θ (reajuste com glm)", L31,
         c(fmt(resumo(g5h, vh), vh), fmt(resumo(g5h, vt), vt), fmt(resumo(g5bh, vh), vh)))
sh5 <- resumo(g5h, vh); sh5b <- resumo(g5bh, vh)
no_texto("Testes 5 e 5b, descritivo", "viés da dobradiça em % do verdadeiro e diferença entre os verdadeiros (texto do erro de especificação)", L31,
         c(sprintf("%s (EP de MC %s; %s%% do verdadeiro)", br(sh5$vies, 4), br(sh5$ep_vies, 4), br(100 * sh5$vies / vh, 1)),
           sprintf("%s (EP %s; %s%%)", br(sh5b$vies, 4), br(sh5b$ep_vies, 4), br(100 * sh5b$vies / vh, 1)),
           sprintf("θ − dobradiça = %s", br(vt - vh, 5))))
gm <- mean(g5[, "gama"]); gep <- stats::sd(g5[, "gama"]) / sqrt(200)
no_texto("Teste 5", "γ̂ médio, EP de MC e distância em EP (glm)", L31, c(sprintf("média %s (EP de MC %s;", br(gm, 4), br(gep, 4)), sprintf("distância = %s EP", br((gm - 1.3) / gep, 2))))
no_texto("Testes 5, 5b e 6", "φ médio (glm)", L31, sprintf("teste 5 = %s; teste 5b = %s; teste 6 = %s", br(mean(g5[, "phi"]), 3), br(mean(g5b[, "phi"]), 3), br(mean(g6[, "phi"]), 3)))
dif <- g7zw[, "est"] - g7g[, "est"]; md <- mean(dif); epd <- stats::sd(dif) / sqrt(200); mn <- mean(g7n[, "est"]); epn <- stats::sd(g7n[, "est"]) / sqrt(200)
no_texto("Teste 7", "zw − z_w_gama e viés do nenhum (glm)", L31,
         c(sprintf("diferença média %s (EP de MC %s;", br(md, 5), br(epd, 5)), sprintf("viés médio %s (EP de MC %s;", br(mn, 4), br(epn, 4))))

# ------------------------------------------------------------------ log do 38: as 1.000 réplicas do 5b, com glm
log_msg("log do 38")
lin38 <- function(m, rot) {
  k <- sum(cobre(m, vt)); n <- nrow(m); ic <- wilson_pt(k, n); z <- (m[, "est"] - vt) / m[, "se"]
  sprintf("| %s | %d | %s (%d de %d) [%s; %s] | %s | %s | %s | %s | %s | %s | %d |", rot, n, br(k / n, 3), k, n, br(ic[1], 3), br(ic[2], 3),
          br(stats::sd(m[, "est"]), 4), br(mean(m[, "se"]), 4), br(mean(m[, "se"]) / stats::sd(m[, "est"]), 3), br(mean(z), 3), br(stats::sd(z), 3),
          br(mean(m[, "phi"]), 3), 0L)
}
stopifnot(all(is.finite(g5b1000)), all(is.finite(g5)))               # no reajuste com glm não há réplica falha
no_texto("Diagnóstico do 5b", "as 4 linhas da tabela (1–200, 201–1.000, 1–1.000 e o 5 para comparar; glm)", L38,
         c(lin38(g5b1000[1:200, ], "5b: 1 a 200 (as do teste)"), lin38(g5b1000[201:1000, ], "5b: 201 a 1.000 (mesma sequência)"),
           lin38(g5b1000, "5b: 1 a 1.000"), lin38(g5, "5: 1 a 200 (contagem alta, para comparar)")))
c1000 <- sum(cobre(g5b1000, vt)) / 1000
no_texto("Diagnóstico do 5b", "chance de cobertura acima de 0,98 por acaso (soma de dbinom de 197 a 200)", L38,
         sprintf("%s%% se a cobertura verdadeira for 0,95; %s%% se for %s", br(100 * sum(stats::dbinom(197:200, 200, 0.95)), 1),
                 br(100 * sum(stats::dbinom(197:200, 200, c1000)), 1), br(c1000, 3)))

# ------------------------------------------------------------------ ruído branco do teste 9 (mesmas séries, acf parcial)
log_msg("ruído branco")
set.seed(20261001); invisible(stats::arima.sim(list(ar = 0.3), n = 4500))
fora_rb <- sum(vapply(1:200, function(i) { x <- stats::rnorm(4500)
  sum(abs(stats::acf(x, lag.max = 7, type = "partial", plot = FALSE)$acf[1:7]) > 2 / sqrt(4500)) }, 0))
icr <- wilson_pt(fora_rb, 1400)
no_texto("Teste 9", "fração do ruído branco fora da faixa e IC de Wilson (acf parcial)", L31,
         sprintf("%s%% dos lags fora da faixa (IC Wilson [%s; %s]%%", br(100 * fora_rb / 1400, 2), br(100 * icr[1], 2), br(100 * icr[2], 2)))

# ------------------------------------------------------------------ n/n e defeitos (testes rápidos de novo)
log_msg("defeitos: testes rápidos de novo")
source(file.path(CC, "tests", "roda_testes.R")); source(file.path(CC, "tests", "testa_ajusta_dlnm.R"))
r0 <- roda_testes(f, testes_ajusta_dlnm)
confere("A2", "testes rápidos passam na versão original (re-rodados)", sum(r0$ok), nrow(r0))
nn <- regmatches(L31, regexpr("(?<=## Resultado: )[0-9]+/[0-9]+", L31, perl = TRUE)); nnv <- as.numeric(strsplit(nn, "/")[[1]])
# quantos testes passam, recalculado: os rápidos (re-rodados) mais os 4 de Monte Carlo pelos critérios do prompt, sobre o
# reajuste com glm (o 5b falha com cobertura acima de 0,98; desvio 61)
s5 <- resumo(g5, vt); s5b <- resumo(g5b, vt); s6 <- resumo(g6, 0)
mc_ok <- c(t05 = s5$cob >= 0.92 && s5$cob <= 0.98 && abs(s5$vies / vt) < 0.10 && abs((gm - 1.3) / gep) < 2,
           t05b = s5b$cob >= 0.92 && s5b$cob <= 0.98, t06 = s6$cob >= 0.92 && s6$cob <= 0.98,
           t07 = abs(md / epd) < 2 && mn > 0 && mn / epn > 3)
confere("A2", "testes que passam / total no log do 31 = recalculado (rápidos re-rodados + critérios de MC com glm)",
        nnv, c(sum(r0$ok) + sum(mc_ok), nrow(r0) + length(mc_ok)))
src <- paste0(paste(readLines(file.path(CC, "R", "ajusta_dlnm.R"), encoding = "UTF-8"), collapse = "\n"), "\n")
# a lista de defeitos é lida do próprio 31 (a expressão `defeitos <- list(...)`), para não haver cópia divergente
ex31 <- parse(file.path("00_scripts", "31_testes_ajusta_dlnm.R"), encoding = "UTF-8")
i_def <- which(vapply(ex31, function(e) identical(e[[1]], as.name("<-")) && identical(e[[2]], as.name("defeitos")), TRUE)); stopifnot(length(i_def) == 1)
eval(ex31[[i_def]])
source(file.path(CC, "tests", "testa_ajusta_dlnm_mc.R")); nomes_mc <- names(testes_ajusta_dlnm_mc)
linhas31 <- strsplit(L31, "\n")[[1]]
for (d in defeitos) {
  stopifnot(lengths(regmatches(src, gregexpr(d[[2]], src, fixed = TRUE))) == 1)
  tf <- file.path(tempdir(), "def.R"); writeLines(sub(d[[2]], d[[3]], src, fixed = TRUE), tf, useBytes = TRUE)
  g <- new.env(); sys.source(tf, envir = g); sys.source(file.path(CC, "tests", "gera_sintetico.R"), envir = g); unlink(tf)
  rr <- roda_testes(g, testes_ajusta_dlnm); falham <- rr$teste[!rr$ok]
  lin <- linhas31[startsWith(linhas31, paste0("| ", d[[1]], " |"))]   # comparação literal (o nome tem parênteses)
  cols <- if (length(lin) == 1) trimws(strsplit(lin, " | ", fixed = TRUE)[[1]]) else character(0)
  quais <- if (length(cols) >= 4) sub(" \\(falha também no original.*$", "", sub(" \\|$", "", cols[length(cols)])) else ""
  lista <- if (identical(quais, "nenhum")) character(0) else strsplit(quais, ", ", fixed = TRUE)[[1]]
  n_log <- if (length(cols) >= 4) suppressWarnings(as.integer(cols[length(cols) - 1])) else NA_integer_
  # os rápidos que falham (re-rodados) estão na lista; o resto da lista é só de testes de Monte Carlo (não re-rodados aqui)
  ok <- length(lin) == 1 && length(lista) >= 1 && identical(n_log, length(lista)) && all(falham %in% lista) && all(setdiff(lista, falham) %in% nomes_mc)
  R[[length(R) + 1]] <- data.frame(Item = "Defeitos", Conferência = paste0("\"", d[[1]], "\": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo"),
                                   N = length(falham), Resultado = if (ok) "igual" else "DIFERENTE", check.names = FALSE, stringsAsFactors = FALSE)
}
sha_33 <- c(`codigo_compartilhado/R/ajusta_dlnm.R` = sha(file.path(CC, "R", "ajusta_dlnm.R")),
            `codigo_compartilhado/tests/gera_sintetico.R` = sha(file.path(CC, "tests", "gera_sintetico.R")),
            `codigo_compartilhado/tests/testa_ajusta_dlnm.R` = sha(file.path(CC, "tests", "testa_ajusta_dlnm.R")),
            `codigo_compartilhado/tests/testa_ajusta_dlnm_mc.R` = sha(file.path(CC, "tests", "testa_ajusta_dlnm_mc.R")),
            `codigo_compartilhado/tests/roda_testes.R` = sha(file.path(CC, "tests", "roda_testes.R")))
no_texto("SHA-256", "função e testes iguais aos do log do 31 (o código auditado é o testado)", L31, sprintf("`%s`: `%s`", names(sha_33), sha_33))

stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
res <- do.call(rbind, R); n_ok <- sum(res$Resultado == "igual")
md <- c("# Fase 2, A3.1: autoauditoria da Parte A", "",
        sprintf("- **Gerado por:** `00_scripts/33_autoauditoria_fase2A.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        sprintf("- **BLAS/LAPACK:** `%s` / `%s`.", sessionInfo()$BLAS, sessionInfo()$LAPACK),
        "- **Código auditado (SHA-256):**", sprintf("  - `%s`: `%s`;", names(sha_33), sha_33),
        "- **Método:** cada número dos logs do 30, do 31 e do 38 foi recalculado com código diferente do que o gerou e procurado no texto do log, com a mesma formatação.",
        sprintf("- **Código diferente:** somas por estrato com split/vapply e ACF manual (A0); quantil tipo 7 à mão; θ por kronecker + qr.solve; verdadeiro θ pelo crossreduce(coef = θ); viés esperado do teste 7 com glm de Poisson e factor(estrato); as 200 réplicas de cada cenário de Monte Carlo (1.000 no 5b, como no 38) geradas de novo (mesma semente e ordem) e reajustadas com glm(quasipoisson) + factor(estrato) + crossreduce, sem `ajusta_dlnm()`; IC de Wilson pelo `prop.test(correct = FALSE)`; chance de cobertura acima de 0,98 por soma de `dbinom`; ruído branco do teste 9 com `acf(type = \"partial\")`; os testes rápidos de cada um dos %d defeitos (lidos do 31) rodados de novo.", length(defeitos)),
        "- **Limite:** os testes de Monte Carlo de cada defeito não foram rodados de novo aqui (só os rápidos); os testes de Monte Carlo listados no 31 para cada defeito são aceitos como estão.", "",
        sprintf("## Resultado: %d de %d conferências iguais", n_ok, nrow(res)), "",
        tabela_md(res), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "|", n_ok, "de", nrow(res), "iguais\n")
if (n_ok < nrow(res)) { print(res[res$Resultado != "igual", ]); quit(status = 1) }
