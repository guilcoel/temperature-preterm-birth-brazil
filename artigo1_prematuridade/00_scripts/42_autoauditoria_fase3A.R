# 42_autoauditoria_fase3A.R — Fase 3, A3.1: autoauditoria da Parte A. Recalcula, com código diferente, os números dos
# logs do 40 (percentis) e do 41 (testes) e procura cada um no texto deles, com a mesma formatação.
# Código diferente de propósito:
#   - A0: quantil tipo 7 à mão (ordenação e interpolação), média por soma; eixo por apply;
#   - teste 5: as mesmas 1.000 réplicas (mesma semente e ordem dos sorteios), com o mixmeta chamado direto (sem a
#     meta_curva), β por lm.fit, base pelo splines::ns, BLUP pela fórmula Xβ̂ + Ψ̂(Ψ̂ + S_i)⁻¹(y_i − Xβ̂), bootstrap da
#     TMR com a base do splines::ns e a mesma regra de semente (complemento C1);
#   - valores descritivos: Boundary.knots contra range por pmax; teste 6 com o polinômio avaliado à mão; teste 8 com a
#     fração atribuível forward e backward calculadas à mão (sem a attrdl), com os mesmos sorteios dela;
#   - defeitos: os testes rápidos de cada cópia rodam de novo; os que falham têm de estar na lista do log.
# Lê a exposição da base só nas colunas de exposição e as entradas da Fase 2 só como atributos e covariâncias.
# Grava logs/autoauditoria_parteA_fase3_<FASE3_DATA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/42_autoauditoria_fase3A.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("autoauditoria_parteA_fase3_", hoje, ".md")); stopifnot(!file.exists(arq))
le_txt <- function(p) paste(readLines(p, encoding = "UTF-8"), collapse = "\n")   # não usar "ler" (é do acesso.R)
L40 <- le_txt(file.path("logs", paste0("percentis_exposicao_fase3_", hoje, ".md"))); L41 <- le_txt(file.path("logs", paste0("testes_segunda_etapa_fase3_", hoje, ".md")))
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta) })
CC <- file.path("..", "codigo_compartilhado")
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
icf <- function(v, d = 3) sprintf("[%s; %s]", br(v[1], d), br(v[2], d))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
R <- list()
reg <- function(item, o_que, n, ok) R[[length(R) + 1]] <<- data.frame(Item = item, Conferência = o_que, N = n, Resultado = if (isTRUE(ok)) "igual" else "DIFERENTE", check.names = FALSE, stringsAsFactors = FALSE)
no_texto <- function(item, o_que, alvo, textos) { ok <- vapply(textos, function(t) grepl(t, alvo, fixed = TRUE), TRUE); reg(item, o_que, length(textos), all(ok))
  if (!all(ok)) cat("AUSENTE:", head(textos[!ok], 3), sep = "\n") }
q7 <- function(x, p) { x <- sort(x); n <- length(x); h <- (n - 1) * p + 1; lo <- floor(h); hi <- pmin(lo + 1, n); x[lo] + (h - lo) * (x[hi] - x[lo]) }
ORDEM <- c("3550308", "3304557", "3106200", "5300108", "2611606", "4314902", "2304400", "4106902", "2927408", "5208707", "3509502", "1302603", "1501402",
           "3205309", "3548500", "3549904", "2111300", "2408102", "2704302", "4205407", "2507507", "2211001", "2800308", "5103403", "3552205", "5002704")
nuc <- as.data.frame(cidade_nucleo()); reg("Ordem", "cidade_nucleo() = ordem gravada (vetor literal escrito de novo aqui)", 26, identical(nuc$CD_RECORTE, ORDEM))
nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)

# ------------------------------------------------------------------ A0 (log do 40)
log_msg("A0")
ex <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_nucleo")))
ex <- ex[as.Date(ex$data) >= as.Date("2012-01-01") & as.Date(ex$data) <= as.Date("2024-12-31"), ]
P <- c(seq(1, 99) / 100, 0.025, 0.975); P <- P[order(P)]
G <- t(vapply(ORDEM, function(r) q7(ex$tmean_nucleo[ex$recorte_principal == r], P), numeric(length(P))))
f_a0 <- file.path("01_saidas", "fase3", paste0("percentis_exposicao_fase3_", hoje, ".csv"))
a0 <- utils::read.csv(f_a0, colClasses = c(recorte_principal = "character"))
Ga0 <- t(vapply(ORDEM, function(r) a0$valor[a0$recorte_principal == r], numeric(length(P))))
reg("A0", "grade 26 × 101 (quantil tipo 7 à mão) = CSV da A0 (≤ 1e-12)", 26 * 101, max(abs(G - Ga0)) <= 1e-12)
eixo <- apply(G, 2, function(v) sum(v) / length(v)); rot <- unique(a0$rotulo); names(eixo) <- rot
reg("A0", "eixo médio (média à mão) = linhas do eixo no CSV (≤ 1e-12)", 101, max(abs(eixo - a0$valor[a0$recorte_principal == "eixo_medio"])) <= 1e-12)
chave <- c("p1", "p2,5", "p5", "p10", "p50", "p90", "p95", "p97,5", "p99")
no_texto("A0", "eixo médio nos percentis-chave e SHA-256 do CSV no log do 40", L40, c(sprintf("| %s | %s |", chave, br(eixo[chave], 3)), sha(f_a0)))
no_texto("A0", "as 101 linhas da grade completa no log do 40", L40,
         vapply(seq_along(rot), function(j) paste0("| ", rot[j], " | ", br(eixo[j], 3), " | ", paste(br(G[, j], 3), collapse = " | "), " |"), ""))
rm(ex); invisible(gc())

# ------------------------------------------------------------------ entradas reais (atributos e covariâncias)
rds <- readRDS(file.path("01_saidas", "fase2", "primeira_etapa_principal_fase2_20261010.rds"))$resultados
AV <- lapply(ORDEM, function(r) rds[[r]]$principal$base$argvar); S <- lapply(ORDEM, function(r) rds[[r]]$principal$reduzida$vcov); rm(rds)
ref <- utils::read.csv(file.path("01_saidas", "fase1", "referencias_exposicao.csv"), colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ORDEM, ref$recorte_principal), ]
md <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1)
s1 <- readRDS(file.path("01_saidas", "fase1", "serie_ptb_principal.rds")); s1 <- s1[s1$data >= as.Date("2012-04-07") & s1$data <= as.Date("2024-08-06"), c("recorte_principal", "tmean_nucleo")]
bk_dif <- max(vapply(seq_along(ORDEM), function(j) { x <- s1$tmean_nucleo[s1$recorte_principal == ORDEM[j]]; max(abs(AV[[j]]$Boundary.knots - c(min(x), max(x)))) }, 0)); rm(s1)
no_texto("Teste 2", "maior |Boundary.knots − range| (pmin/pmax à mão)", L41, sprintf("maior |Boundary.knots − range(x)| nas 26 = %s", formatC(bk_dif, format = "e", digits = 1)))

# ------------------------------------------------------------------ teste 5: declarações e Monte Carlo com mixmeta direto
log_msg("teste 5: declarações")
kn <- apply(do.call(rbind, lapply(AV, function(a) a$knots)), 2, function(v) sum(v) / length(v))
bkm <- apply(do.call(rbind, lapply(AV, function(a) a$Boundary.knots)), 2, function(v) sum(v) / length(v))
Bns <- function(x) splines::ns(x, knots = kn, Boundary.knots = bkm, intercept = FALSE)
x50 <- eixo[["p50"]]; x75 <- eixo[["p75"]]; x99 <- eixo[["p99"]]; x1 <- eixo[["p1"]]
g <- seq(bkm[1], bkm[2], length.out = 301); Xg <- sweep(unclass(Bns(g)), 2, unclass(Bns(x50))[1, ])
beta <- stats::lm.fit(Xg, 0.02 * pmax(g - x75, 0))$coefficients
dv99 <- unclass(Bns(x99))[1, ] - unclass(Bns(x50))[1, ]; v99 <- sum(dv99 * beta)
sdp <- 0.5 * sqrt(apply(do.call(rbind, lapply(S, diag)), 2, mean)); Psi <- outer(sdp, sdp) * (0.3 + 0.7 * diag(4))
gt <- seq(x1, x99, by = 0.1); if (x99 - gt[length(gt)] > 1e-8) gt <- c(gt, x99)
tmr_v <- gt[which.min(unclass(Bns(gt)) %*% beta)]
no_texto("Teste 5", "base combinada, β, log RR verdadeiro, DP de Ψ, cen e TMR verdadeira (declarados)", L41,
         c(sprintf("ns com nós %s e Boundary.knots %s °C", paste(br(kn, 3), collapse = "; "), paste(br(bkm, 3), collapse = " e ")),
           paste(formatC(beta, format = "e", digits = 4), collapse = "; "), sprintf("Log RR verdadeiro em x99 contra x50 = %s", br(v99, 5)),
           paste(formatC(sdp, format = "e", digits = 3), collapse = "; "), sprintf("**cen:** x50 do eixo médio (%s °C)", br(x50, 3)),
           sprintf("**TMR verdadeira** (mínimo da curva verdadeira na grade entre x1 e x99 do eixo): %s °C", br(tmr_v, 1))))
log_msg("teste 5: 1.000 réplicas com mixmeta direto")
Rr <- 1000L; n <- 26L; k <- 4L; set.seed(20261001)
U <- array(stats::rnorm(Rr * n * k), c(Rr, n, k)); E <- array(stats::rnorm(Rr * n * k), c(Rr, n, k)); cP <- chol(Psi); cS <- lapply(S, chol)
ajuste <- function(Y) { for (s in list(c("reml", "unstr"), c("reml", "diag"), c("ml", "diag"))) {
  m <- tryCatch(mixmeta(Y ~ media + amplitude, S = S, data = md, method = s[1], bscov = s[2]), error = function(e) NULL)
  if (!is.null(m) && !isFALSE(m$converged)) return(list(m = m, metodo = paste(s, collapse = "/"))) }; NULL }
lr <- se <- numeric(Rr); msq <- matrix(NA_real_, Rr, 4); met <- character(Rr); cob_t <- logical(Rr); nd <- data.frame(media = mean(md$media), amplitude = mean(md$amplitude))
Bg <- unclass(Bns(gt))
for (rp in seq_len(Rr)) {
  th <- matrix(0, n, k); y <- matrix(0, n, k)
  for (i in seq_len(n)) { th[i, ] <- beta + crossprod(cP, U[rp, i, ]); y[i, ] <- th[i, ] + crossprod(cS[[i]], E[rp, i, ]) }
  a <- ajuste(y); m <- a$m; met[rp] <- a$metodo
  pr <- predict(m, newdata = nd, vcov = TRUE); lr[rp] <- sum(dv99 * pr$fit); se[rp] <- sqrt(drop(t(dv99) %*% pr$vcov %*% dv99))
  Bm <- matrix(coef(m), 3, k, byrow = TRUE); fx <- cbind(1, md$media, md$amplitude) %*% Bm; Ps <- m$Psi
  bl <- t(vapply(seq_len(n), function(i) drop(fx[i, ] + Ps %*% solve(Ps + S[[i]], y[i, ] - fx[i, ])), numeric(k)))
  pmd <- matrix(pr$fit, n, k, byrow = TRUE)
  msq[rp, ] <- c(mean(rowSums((bl - th)^2)), mean(rowSums((y - th)^2)), mean(rowSums((fx - th)^2)), mean(rowSums((pmd - th)^2)))
  set.seed(20261001, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
  sims <- pr$fit + t(chol(pr$vcov)) %*% matrix(stats::rnorm(k * 1000), k)
  tm <- gt[apply(Bg %*% sims, 2, which.min)]; ci <- stats::quantile(tm, c(0.025, 0.975), type = 7, names = FALSE)
  cob_t[rp] <- ci[1] <= tmr_v && tmr_v <= ci[2]
}
z <- qnorm(0.975); cob <- mean(abs(lr - v99) <= z * se); ep_c <- sqrt(cob * (1 - cob) / Rr)
wil <- suppressWarnings(as.numeric(prop.test(round(cob * Rr), Rr, correct = FALSE)$conf.int))
vies <- mean(lr) - v99; epv <- sd(lr) / sqrt(Rr); ms <- colMeans(msq); tm_cob <- mean(cob_t); tb <- table(met)
no_texto("Teste 5", "cobertura, EP e IC de Wilson (mixmeta direto; Wilson pelo prop.test)", L41,
         sprintf("%s (EP de MC %s; IC Wilson %s); critério 0,92–0,98", br(cob, 3), br(ep_c, 4), icf(wil, 3)))
no_texto("Teste 5", "viés, EP, IC, viés relativo, EP médio e DP das estimativas", L41,
         sprintf("**Viés:** %s (EP de MC %s; IC MC %s); relativo %s%% (EP %s%%); critério |·| < 10%%. EP médio %s; DP das estimativas %s.",
                 br(vies, 5), br(epv, 5), icf(vies + c(-1, 1) * 1.96 * epv, 5), br(100 * vies / v99, 2), br(100 * epv / v99, 2), br(mean(se), 4), br(sd(lr), 4)))
no_texto("Teste 5", "EQM do BLUP (fórmula à mão), da primeira etapa e da parte fixa", L41,
         sprintf("BLUP %s; primeira etapa %s; parte fixa X_iβ̂ (predição de cada unidade pelos seus metapreditores) %s", formatC(ms[1], format = "e", digits = 3),
                 formatC(ms[2], format = "e", digits = 3), formatC(ms[3], format = "e", digits = 3)))
no_texto("Teste 5", "EQM da predição na média dos metapreditores (só reportado; desvio 74)", L41,
         sprintf("(a mesma predição para todas as unidades; só reportado): %s.", formatC(ms[4], format = "e", digits = 3)))
no_texto("Teste 5", "cobertura da TMR (bootstrap com splines::ns) e métodos do mixmeta", L41,
         c(sprintf("só reportada:** %s.", br(tm_cob, 3)), sprintf("**Método do mixmeta nas réplicas:** %s.", paste(sprintf("%s em %d", names(tb), as.integer(tb)), collapse = "; "))))
dif_log <- as.numeric(sub(",", ".", regmatches(L41, regexpr("(?<=diferença máxima )[0-9.e+-]+", L41, perl = TRUE))))
reg("Teste 5", "diferença BLUP × fórmula à mão no log ≤ 1e-8", 1, length(dif_log) == 1 && dif_log <= 1e-8)
mc_ok <- cob >= 0.92 && cob <= 0.98 && abs(vies / v99) < 0.10 && ms[1] < ms[2] && ms[1] < ms[3]

# ------------------------------------------------------------------ testes 6 e 8: valores descritivos com código à mão
log_msg("testes 6 e 8")
semeia <- function(i) set.seed(20261001 + i, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
V6 <- matrix(c(4e-4, -1e-5, -1e-5, 4e-7), 2); cf6 <- c(-0.5, 0.01); g6 <- seq(15, 35, by = 0.1)
semeia(3); sm <- cf6 + t(chol(V6)) %*% matrix(rnorm(2000), 2); tm6 <- g6[apply(sm, 2, function(b) which.min(b[1] * g6 + b[2] * g6^2))]
gr6 <- c(-1 / (2 * cf6[2]), cf6[1] / (2 * cf6[2]^2)); epd <- sqrt(drop(t(gr6) %*% V6 %*% gr6))
no_texto("Teste 6", "DP das TMR sorteadas, EP delta e largura do IC (polinômio à mão)", L41,
         sprintf("DP das TMR sorteadas %s × EP pelo método delta %s (critério: diferença < 20%%); largura do IC %s °C", br(sd(tm6), 3), br(epd, 3), br(diff(quantile(tm6, c(.025, .975), type = 7)), 2)))
# teste 8: mesma montagem sintética do teste (série, coeficientes, vcov), AF calculada à mão
set.seed(20261001); nn <- 1100; tt <- seq_len(nn); x <- 22 + 5 * sin(2 * pi * tt / 365.25) + as.numeric(arima.sim(list(ar = 0.6), n = nn, sd = 1.5))
cb <- crossbasis(x, lag = 7, argvar = list(fun = "ns", knots = unname(quantile(x, c(.1, .75, .9), type = 7)), Boundary.knots = range(x), intercept = FALSE),
                 arglag = list(fun = "ns", knots = logknots(7, nk = 2), intercept = TRUE))
set.seed(20261001); cases <- rpois(nn, 30); cases[1:7] <- NA
c16 <- c(0.01, 0.002, -0.004, 0.003, 0.02, 0.004, -0.002, 0.001, 0.015, 0.003, -0.003, 0.002, 0.03, 0.006, -0.005, 0.004)
set.seed(20261002); A <- matrix(rnorm(256), 16); V16 <- (crossprod(A) / 16 + diag(16)) * 1e-6
cr <- crossreduce(cb, coef = c16, vcov = V16, model.link = "log", type = "overall", cen = 22); c4 <- unname(coef(cr)); V4 <- unname(vcov(cr))
av <- attr(cb, "argvar"); al <- attr(cb, "arglag"); jw <- 8:nn
Bv <- function(z) splines::ns(z, knots = av$knots, Boundary.knots = av$Boundary.knots, intercept = FALSE)
bc <- unclass(Bv(22))[1, ]; cbar <- vapply(seq_along(jw), function(t) if (t + 7 <= length(jw)) mean(cases[jw][t:(t + 7)]) else NA_real_, 0)
an_fw <- function(b, rg = NULL) { xx <- x[jw]; if (!is.null(rg)) xx[xx < rg[1] | xx > rg[2]] <- 22
  af <- 1 - exp(-drop(sweep(unclass(Bv(xx)), 2, bc) %*% b)); a <- af * cbar; ok <- !is.na(a); sum(a[ok]) / sum(cbar[ok]) * sum(cases[jw]) }
sims_mao <- function(i) { semeia(i); ev <- eigen(V4); X <- matrix(rnorm(4 * 1000), 1000); cs <- c4 + ev$vectors %*% diag(sqrt(ev$values), 4) %*% t(X); apply(cs, 2, an_fw) }
cor8 <- cor(sims_mao(1), sims_mao(2))
no_texto("Teste 8", "correlação entre as simulações das concentrações 1 e 2 (AF forward à mão, mesmos sorteios da attrdl)", L41, sprintf("(mesma vcov) = %s (critério", br(cor8, 3)))
# backward à mão: η_t = Σ_l Σ_v Σ_j β_vj [B_v(x_{t−l}) − B_v(cen)] C_j(l), com x trocado pela cen fora do range
Cl <- unclass(do.call(onebasis, c(list(x = 0:7), al))); Bmat <- matrix(c16, 4, 4, byrow = TRUE)
an_bk <- function(rg = NULL) { xx <- x; if (!is.null(rg)) xx[xx < rg[1] | xx > rg[2]] <- 22
  eta <- vapply(jw, function(t) sum(vapply(0:7, function(l) sum(outer(unclass(Bv(xx[t - l]))[1, ] - bc, Cl[l + 1, ]) * Bmat), 0)), 0)
  af <- 1 - exp(-eta); a <- af * cases[jw]; sum(a) / sum(cases[jw]) * sum(cases[jw]) }
dif_bk <- an_bk() - (an_bk(c(22, Inf)) + an_bk(c(-Inf, 22)))
no_texto("Teste 8", "backward: total − (calor + frio) (backward à mão)", L41, sprintf("total − (calor + frio) = %s no AN sintético", br(dif_bk, 4)))

# ------------------------------------------------------------------ SHA, n/n e defeitos
log_msg("SHA, n/n e defeitos")
arqs <- c("codigo_compartilhado/R/segunda_etapa.R", "codigo_compartilhado/R/ajusta_dlnm.R", "codigo_compartilhado/tests/testa_segunda_etapa.R",
          "codigo_compartilhado/tests/testa_segunda_etapa_mc.R", "codigo_compartilhado/tests/roda_testes.R", "codigo_compartilhado/inst/terceiros/attrdl.R")
shas <- vapply(arqs, function(a) sha(file.path("..", a)), "")
no_texto("SHA-256", "código e testes iguais aos do log do 41", L41, sprintf("`%s`: `%s`", arqs, shas))
source(file.path(CC, "tests", "roda_testes.R")); source(file.path(CC, "tests", "testa_segunda_etapa.R")); source(file.path(CC, "tests", "testa_segunda_etapa_mc.R"))
f <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = f); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f)
.R3$argvar <- AV; .R3$S <- S; .R3$metapred <- md; .R3$codigos <- nuc$CD_RECORTE; .R3$grade <- Ga0; colnames(.R3$grade) <- rot; .R3$eixo <- eixo
rds <- readRDS(file.path("01_saidas", "fase2", "primeira_etapa_principal_fase2_20261010.rds"))$resultados; .R3$arglag <- lapply(ORDEM, function(r) rds[[r]]$principal$base$arglag); rm(rds)
s1 <- readRDS(file.path("01_saidas", "fase1", "serie_ptb_principal.rds")); s1 <- s1[s1$data >= as.Date("2012-04-07") & s1$data <= as.Date("2024-08-06"), c("recorte_principal", "data", "tmean_nucleo")]
.R3$x <- lapply(ORDEM, function(r) { zz <- s1[s1$recorte_principal == r, ]; zz$tmean_nucleo[order(zz$data)] }); rm(s1)
.R3$nos_csv <- as.matrix(ref[, c("p10", "p75", "p90")]); .R3$attrdl_path <- file.path(CC, "inst", "terceiros", "attrdl.R"); .R3$attrdl <- f$carrega_attrdl(file.path(CC, "inst", "terceiros", "attrdl.R"), shas[["codigo_compartilhado/inst/terceiros/attrdl.R"]])
r0 <- roda_testes(f, testes_segunda_etapa)
nn_log <- as.numeric(strsplit(regmatches(L41, regexpr("(?<=## Resultado: )[0-9]+/[0-9]+", L41, perl = TRUE)), "/")[[1]])
reg("A2", "testes que passam / total no log do 41 = recalculado (rápidos re-rodados + critérios do teste 5 refeitos)", 2,
    identical(nn_log, c(sum(r0$ok) + as.numeric(mc_ok), nrow(r0) + 1)))
ex41 <- parse(file.path("00_scripts", "41_testes_segunda_etapa.R"), encoding = "UTF-8")
i_def <- which(vapply(ex41, function(e) is.call(e) && identical(e[[1]], as.name("<-")) && identical(e[[2]], as.name("defeitos")), TRUE)); eval(ex41[[i_def]])
src <- paste0(paste(readLines(file.path(CC, "R", "segunda_etapa.R"), encoding = "UTF-8"), collapse = "\n"), "\n"); linhas41 <- strsplit(L41, "\n")[[1]]
for (d in defeitos) {
  s2 <- src; for (tr in d[[2]]) s2 <- sub(tr[1], tr[2], s2, fixed = TRUE)
  tf <- file.path(tempdir(), "def3.R"); writeLines(s2, tf, useBytes = TRUE)
  g2 <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = g2); sys.source(tf, envir = g2); unlink(tf)
  rr2 <- roda_testes(g2, testes_segunda_etapa); fal <- rr2$teste[!rr2$ok]
  lin <- linhas41[startsWith(linhas41, paste0("| ", d[[1]], " |"))]
  cols <- if (length(lin) == 1) trimws(strsplit(lin, " | ", fixed = TRUE)[[1]]) else character(0)
  quais <- if (length(cols) >= 4) sub(" \\|$", "", cols[length(cols)]) else ""; lista <- strsplit(sub(" \\(falha também.*$", "", quais), ", ", fixed = TRUE)[[1]]
  # regra do desvio 74: com um rápido caído, o teste 5 não roda e a lista é só a dos rápidos; sem rápido caído, a lista é só o teste 5
  ok <- length(lin) == 1 && !identical(lista, "nenhum") && (if (length(fal)) setequal(lista, fal) else identical(lista, "t05_recuperacao_meta"))
  reg("Defeitos", paste0("\"", d[[1]], "\": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5"), length(fal), ok)
}

stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
res <- do.call(rbind, R); n_ok <- sum(res$Resultado == "igual")
md_txt <- c("# Fase 3, A3.1: autoauditoria da Parte A", "",
            sprintf("- **Gerado por:** `00_scripts/42_autoauditoria_fase3A.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
            sprintf("- **BLAS/LAPACK:** `%s` / `%s`.", sessionInfo()$BLAS, sessionInfo()$LAPACK),
            "- **Arquivos auditados (SHA-256):**", sprintf("  - `%s`: `%s`;", arqs, shas),
            "- **Método:** cada número dos logs do 40 e do 41 foi recalculado com código diferente e procurado no texto com a mesma formatação.",
            "- **Código diferente:** quantil tipo 7 à mão (A0); as 1.000 réplicas do teste 5 com os mesmos sorteios, ajustadas com o `mixmeta` chamado direto (sem `meta_curva`), β por `lm.fit`, base pelo `splines::ns`, BLUP pela fórmula e bootstrap da TMR com a base do `splines::ns`; teste 6 com o polinômio avaliado à mão; teste 8 com a fração atribuível *forward* e *backward* calculadas à mão, sem a `attrdl`, com os mesmos sorteios; testes rápidos de cada defeito rodados de novo.",
            "- **Limite:** a diferença BLUP × fórmula do log do 41 é conferida só como ≤ 1e-8, porque o valor exato depende do código; o teste 5 de cada defeito não roda de novo (os testes de Monte Carlo listados no 41 são aceitos como estão; pela regra do desvio 74, o 41 só roda o teste 5 numa cópia quando nenhum teste rápido cai).", "",
            sprintf("## Resultado: %d de %d conferências iguais", n_ok, nrow(res)), "", tabela_md(res), "",
            sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md_txt, arq, useBytes = TRUE)
cat("gravado:", arq, "|", n_ok, "de", nrow(res), "iguais\n")
if (n_ok < nrow(res)) { print(res[res$Resultado != "igual", ]); quit(status = 1) }
