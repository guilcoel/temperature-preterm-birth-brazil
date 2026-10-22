# testa_sens_agudos.R — testes da sens_agudos v1.0 (Fase 4 do Artigo 1; prompt da Fase 4, seção 2, itens 3 e 6; D11,
# 5.2 e 5.3; D13, item 3; D16, item 2; mensagem de respostas ao plano, P3, P11 e m6; A1-97 e A1-99). Só dado sintético.
# Cada teste recebe `f` (ambiente com ajusta_dlnm.R, segunda_etapa.R v1.1, sens_agudos.R e gera_sintetico.R) e para com
# erro se uma conferência falhar. Referências independentes da função testada: interpolação linear própria, cross-basis e
# preditor montados à mão (dado gerado do próprio modelo, y = μ), predict.gam(type = "lpmatrix"), GLS e REML à mão,
# Magnus pela pressão de vapor. Executor: roda_testes_fase4.R.

if (!exists(".REF", inherits = FALSE)) .REF <- new.env()
.sa_perto <- function(a, b, tol, rel = FALSE) {
  a <- as.numeric(a); b <- as.numeric(b)
  if (length(a) != length(b)) stop("tamanhos diferentes: ", length(a), " × ", length(b))
  d <- if (rel) max(abs(a - b) / pmax(abs(b), 1e-300)) else max(abs(a - b))
  if (!is.finite(d) || d > tol) stop("diferença ", format(d), " > ", format(tol))
  invisible(d)
}
.sa_semeia <- function(s) set.seed(s, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
.sa_arglag <- function() list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE)
# percentil por interpolação linear própria (quantis estritamente crescentes), 0 e 100 fora do range
.sa_pct <- function(x, ref) {
  q <- stats::quantile(ref, seq(0, 1, 0.001), type = 7, names = FALSE); stopifnot(!is.unsorted(q, strictly = TRUE))
  vapply(x, function(v) { if (v <= q[1]) return(0); if (v >= q[1001]) return(100); i <- max(which(q <= v)); (i - 1) * 0.1 + 0.1 * (v - q[i]) / (q[i + 1] - q[i]) }, 0)
}
# séries empilhadas com efeito comum na escala de percentil, γ por unidade e y = μ (esperado), geradas do próprio modelo
.sa_uma_etapa_dados <- function(U = 3L, N = 700L) {
  .sa_semeia(20261001); lst <- list(); ref <- list(); dows <- c(0, .02, .02, .02, .01, -.15, -.25)
  for (u in seq_len(U)) {
    n <- N + 7L; data <- as.Date("2015-01-01") + 0:(n - 1); t <- seq_len(n)
    tm <- 20 + 2 * u + 5 * sin(2 * pi * t / 365.25) + as.numeric(stats::arima.sim(list(ar = 0.6), n = n, sd = 1.5))
    lst[[u]] <- data.frame(unidade = paste0("c", u), data = data, tmean = tm, log_z = log(1 + 0.1 * sin(2 * pi * (t - 100) / 365.25)),
                           log_w = log(0.01) + 0.03 * sin(2 * pi * t / 91) + 0.01 * cos(t / 7), dia_semana = factor(format(data, "%u")),
                           feriado_nacional = as.integer(format(data, "%m-%d") %in% c("01-01", "05-01", "09-07")), carnaval = 0L, moveis = 0L,
                           estrato = paste0("c", u, "_", format(data, "%Y-%m")), janela = t > 7, stringsAsFactors = FALSE)
    ref[[paste0("c", u)]] <- tm
  }
  d <- do.call(rbind, lst); pct <- unlist(lapply(seq_len(U), function(u) .sa_pct(lst[[u]]$tmean, ref[[u]])))
  av <- list(fun = "ns", knots = c(10, 75, 90), Boundary.knots = range(pct), intercept = FALSE)
  cb <- dlnm::crossbasis(pct, lag = 7, argvar = av, arglag = .sa_arglag(), group = d$unidade)
  theta <- c(0.004, -0.002, 0.003, 0.001, 0.010, -0.006, 0.004, 0.002, 0.006, -0.003, 0.005, 0.001, 0.020, -0.010, 0.012, 0.004)
  gam_v <- 1 + seq_len(U) / 4; est <- factor(d$estrato); a_est <- stats::rnorm(nlevels(est), 0, 0.1)[as.integer(est)]
  eta <- 3 + a_est + d$log_z + gam_v[as.integer(factor(d$unidade))] * d$log_w + drop(unclass(cb) %*% theta) + c(0, .02, .02, .02, .01, -.15, -.25)[as.integer(d$dia_semana)] - 0.2 * d$feriado_nacional
  d$y <- exp(eta); d$y[is.na(d$y)] <- 0
  list(d = d, ref = ref, theta = theta, gama = setNames(gam_v, paste0("c", seq_len(U))), av = av)
}
.sa_s3_dados <- function(f, n = 1000L) { .sa_semeia(20261001); bf <- f$base_fixa(20000); d <- f$gera_sintetico(n_dias = n, eventos_dia = 30, efeito = "dobradica", bf = bf); d$tmean <- d$temp; d }

testes_sens_agudos <- list(

  # percentil_conc = interpolação linear própria nos 1.001 quantis; fora do range, 0 e 100; controle: rule = 1 dá NA ali
  tsa_percentil_conc = function(f) {
    .sa_semeia(11); ref <- stats::rnorm(4749, 24, 3); x <- c(stats::rnorm(500, 24, 3), min(ref) - 1, max(ref) + 0.5, stats::quantile(ref, c(0.25, 0.5), names = FALSE))
    p <- f$percentil_conc(x, ref); .sa_perto(p, .sa_pct(x, ref), 1e-10)
    fora <- x < min(ref) | x > max(ref); stopifnot(sum(fora) >= 2, all(p[fora] %in% c(0, 100)))
    q <- stats::quantile(ref, seq(0, 1, 0.001), type = 7, names = FALSE)
    if (!all(is.na(stats::approx(q, seq(0, 100, 0.1), xout = x[fora], rule = 1, ties = mean)$y))) stop("controle: rule = 1 deveria dar NA fora do range")
  },

  # uma etapa: com y = μ gerado do próprio modelo (cross-basis comum em percentil, γ por unidade), recupera os 16
  # coeficientes (≤ 1e-6) e os γ (≤ 1e-4, limite da convergência do gnm, que para pela variação relativa da deviance; a
  # tolerância de 1e-4 só no γ vem da auditoria do chat de 18/10, N1: com 1e-4 nos coeficientes, o percentil pelo
  # quantil tipo 8 passava); as primeiras 7 linhas de cada unidade saem NA na cross-basis (group)
  tsa_uma_etapa_recupera = function(f) {
    s <- .sa_uma_etapa_dados(); r <- f$uma_etapa(s$d, s$ref, .sa_arglag())
    stopifnot(identical(r$status, "ok"), isTRUE(r$cb_na_aquecimento), r$n$estratos_usados == length(unique(s$d$estrato[s$d$janela])))
    .sa_perto(r$coef_cb, s$theta, 1e-6); .sa_perto(r$gama, s$gama, 1e-4); .sa_perto(r$argvar$Boundary.knots, s$av$Boundary.knots, 0)
  },

  # curva da uma etapa: TMR interior (sem borda, sem RR contra a mediana); curva crescente → TMR em x1, contraste do x1 = 1
  # sem IC e RR contra a mediana descritivo (D13, item 3); bootstrap reprodutível (semente 20261001)
  tsa_curva_uma_etapa = function(f) {
    probs <- c(1:99, 2.5, 97.5); o <- order(probs); probs <- probs[o]; eixo <- stats::qnorm(probs / 100, 24, 3)
    av <- list(fun = "ns", knots = c(10, 75, 90), Boundary.knots = c(0, 100), intercept = FALSE); g <- seq(0, 100, 0.5)
    B <- unclass(do.call(dlnm::onebasis, c(list(x = g), av)))
    cf_in <- unname(stats::lm.fit(B, ((g - 70) / 30)^2)$coefficients); cf_mo <- unname(stats::lm.fit(B, g / 100)$coefficients)
    res <- function(cf, v = 1e-4) list(status = "ok", argvar = av, reduzida = list(coef = cf, vcov = diag(4) * v))
    a <- f$curva_uma_etapa(res(cf_in), eixo, probs, nsim = 300); b <- f$curva_uma_etapa(res(cf_in), eixo, probs, nsim = 300)
    stopifnot(!a$fronteira, is.null(a$rr_mediana), identical(a$rr$rotulo, c("x99", "x1")), all(is.finite(a$rr$rr_li)), identical(a$ic_tmr, b$ic_tmr))
    if (!(abs(a$tmr_pct - 70) < 2)) stop("TMR interior fora do mínimo construído: ", a$tmr_pct)
    # o IC do bootstrap é o refeito à mão com a semente 20261001 (curva combinada; C1, item 4) e os mesmos sorteios
    gg <- f$grade_tmr(eixo[probs == 1], eixo[probs == 99]); pg <- stats::approx(eixo, probs, xout = gg, rule = 1)$y
    ab <- f$curva_uma_etapa(res(cf_in, 1), eixo, probs, nsim = 300)     # variância maior: os sorteios se espalham pela grade
    Rc <- chol(diag(4) * 1); .sa_semeia(20261001); sims <- cf_in + t(Rc) %*% matrix(stats::rnorm(4 * 300), 4)
    tm <- gg[apply(unclass(do.call(dlnm::onebasis, c(list(x = pg), av))) %*% sims, 2, which.min)]
    if (length(unique(tm)) < 10) stop("cenário: sorteios do bootstrap pouco espalhados")
    if (!identical(ab$tmr_sim, tm)) stop("sorteios da TMR diferentes do bootstrap à mão com a semente 20261001")
    if (!identical(ab$ic_tmr, unname(stats::quantile(tm, c(0.025, 0.975), type = 7)))) stop("IC da TMR diferente do bootstrap à mão")
    m <- f$curva_uma_etapa(res(cf_mo), eixo, probs, nsim = 300)
    stopifnot(m$fronteira, identical(m$lado_borda, "x1"), m$indice == 1L, m$rr$rr[2] == 1, is.na(m$rr$rr_li[2]), is.na(m$rr$rr_ls[2]), !is.null(m$rr_mediana))
    .sa_perto(m$tmr, eixo[probs == 1], 0)
  },

  # S3: log RR do crosspred (at fora de ordem) = diferença do lpmatrix no termo s(Q,L) (≤ 1e-8); dimensão 72; controle:
  # com a referência na mediana, a diferença passa de 1e-8
  tsa_s3_lpmatrix = function(f) {
    d <- .sa_s3_dados(f); at <- unname(stats::quantile(d$temp, c(0.99, 0.01), type = 7)); cen <- unname(stats::quantile(d$temp, 0.25, type = 7))
    r <- f$ajusta_s3(d, at = at, cen = cen, devolve_fit = TRUE); stopifnot(identical(r$status, "ok"), r$dim_s == 72L)
    lp <- c(f$confere_s3_lpmatrix(r$fit, at[1], cen), f$confere_s3_lpmatrix(r$fit, at[2], cen)); .sa_perto(r$logrr, lp, 1e-8)
    ctrl <- f$confere_s3_lpmatrix(r$fit, at[1], stats::median(d$temp))
    if (!(abs(ctrl - r$logrr[1]) > 1e-8)) stop("controle sem poder: referência na mediana deu ", format(abs(ctrl - r$logrr[1])))
  },

  # mgcv instalado: os quatro pontos da P11; o estado do gerador de quem chama não muda (identical antes e depois), e
  # sem .Random.seed continua sem (auditoria do chat de 18/10, N4)
  tsa_confere_mgcv = function(f) {
    ge <- globalenv(); s_ini <- if (exists(".Random.seed", envir = ge, inherits = FALSE)) get(".Random.seed", envir = ge) else NULL
    on.exit(if (is.null(s_ini)) suppressWarnings(rm(".Random.seed", envir = ge)) else assign(".Random.seed", s_ini, envir = ge), add = TRUE)
    .sa_semeia(99); s0 <- get(".Random.seed", envir = ge)
    m <- f$confere_mgcv(); .REF$mgcv <- m
    if (!identical(get(".Random.seed", envir = ge), s0)) stop("confere_mgcv mudou o estado do gerador de quem chama")
    stopifnot(identical(m$versao, "1.9.3"), m$ps_m_padrao_2_2, m$k_so_aviso, m$vcov_igual_Vp, m$dim_cb_72)
    rm(".Random.seed", envir = ge); invisible(f$confere_mgcv())
    if (exists(".Random.seed", envir = ge, inherits = FALSE)) stop("confere_mgcv criou .Random.seed onde não havia")
  },

  # meta univariada: coeficientes = GLS à mão com o τ² do ajuste; τ² = REML à mão (otimização própria); predição na média;
  # controle: com S trocada (permutada), os coeficientes mudam
  tsa_meta_univariada = function(f) {
    .sa_semeia(5); n <- 26; md <- data.frame(media = stats::rnorm(n, 24, 2), amplitude = stats::rnorm(n, 12, 2)); v <- stats::runif(n, 5e-4, 4e-3)
    y <- 0.02 + 0.01 * (md$media - 24) - 0.005 * (md$amplitude - 12) + stats::rnorm(n, 0, sqrt(v + 2e-3))
    r <- f$meta_univariada(y, v, md); stopifnot(identical(r$status, "ok"))
    X <- cbind(1, md$media, md$amplitude); w <- 1 / (v + r$tau2); beta <- solve(crossprod(X, w * X), crossprod(X, w * y))
    .sa_perto(r$coef, beta, 1e-8, rel = TRUE); .sa_perto(r$estimativa, sum(colMeans(X) * beta), 1e-10)
    nll <- function(t2) { w <- 1 / (v + t2); A <- crossprod(X, w * X); b <- solve(A, crossprod(X, w * y)); 0.5 * (sum(log(v + t2)) + log(det(A)) + sum(w * (y - X %*% b)^2)) }
    t2 <- stats::optimize(nll, c(0, 0.05), tol = 1e-12)$minimum; .sa_perto(r$tau2, t2, 1e-4 * max(t2, 1e-6))
    f$confere_meta(r, c("media", "amplitude"), matrix(y, ncol = 1))                        # Wald com 1 gl e total presentes
    .sa_semeia(6); r2 <- f$meta_univariada(y, v[sample(n)], md)
    if (!(max(abs(r2$coef - r$coef)) > 1e-6)) stop("controle sem poder: S permutada não mudou os coeficientes")
  },

  # projeção ponderada: max|X′W^{1/2}e*| ≤ 1e-10 × escala; idempotente; controle: a projeção por MQO falha nesse teste
  tsa_projeta_ponderada = function(f) {
    .sa_semeia(9); n <- 600; e <- factor(rep(1:20, each = 30)); X <- cbind(stats::model.matrix(~ e - 1), matrix(stats::rnorm(n * 5), n))
    W <- exp(stats::rnorm(n, 3, 0.4)); E <- matrix(stats::rnorm(n * 50), n)
    Es <- f$projeta_ponderada(E, X, W); Xw <- sqrt(W) * X; esc <- max(abs(crossprod(Xw, E)))
    if (!(max(abs(crossprod(Xw, Es))) <= 1e-10 * esc)) stop("projeção ponderada não zera o desenho: ", format(max(abs(crossprod(Xw, Es))) / esc))
    .sa_perto(f$projeta_ponderada(Es, X, W), Es, 1e-12)
    Eo <- qr.resid(qr(X), E); if (!(max(abs(crossprod(Xw, Eo))) > 1e-4 * esc)) stop("controle sem poder: a projeção por MQO passou no teste ponderado")
  },

  # nula da PACF: pesos de trabalho = μ̂ (< 1e-8); projeção zera o desenho (≤ 1e-10 × escala); semente 20261001 + i
  # (reprodutível e igual à geração à mão); PACF do lag 1 perto de −1/m; controle: outra concentração (i) dá outra nula
  tsa_nula_pacf = function(f) {
    .sa_semeia(20261001); d <- f$gera_sintetico(n_dias = 900, eventos_dia = 30)
    q <- stats::quantile(d$temp, c(.10, .50, .75, .90), type = 7, names = FALSE)
    sp <- f$spec_agudo("y", "temp", "janela", 7, argvar = list(fun = "ns", knots = q[c(1, 3, 4)]), arglag = .sa_arglag(), cen = q[2])
    r <- f$ajusta_dlnm(d, sp, devolve_matriz = TRUE); mt <- r$matriz; stopifnot(identical(r$status, "ok"))
    if (!(f$confere_pesos(mt$peso_trabalho, mt$mu) < 1e-8)) stop("pesos de trabalho ≠ μ̂")
    jan <- which(d$janela); pos <- mt$linhas - jan[1] + 1L; ng <- length(jan)
    a <- f$nula_pacf(mt, pos, ng, i = 3, R = 200); b <- f$nula_pacf(mt, pos, ng, i = 3, R = 200)
    stopifnot(identical(a, b), a$semente == 20261004L, a$orto <= 1e-10 * a$escala)
    X <- f$desenho_completo(mt); .sa_semeia(20261004); E <- matrix(stats::rnorm(nrow(X) * 200), nrow(X))
    P1 <- vapply(1:200, function(k) f$pacf_grade(qr.resid(qr(sqrt(mt$peso_trabalho) * X), E[, k]), pos, ng, 7)[1], 0)
    .sa_perto(a$media[1], mean(P1), 1e-12)
    if (!(a$media[1] > -0.06 && a$media[1] < -0.01)) stop("PACF nula do lag 1 longe de −1/m: ", format(a$media[1]))
    c4 <- f$nula_pacf(mt, pos, ng, i = 4, R = 200); if (identical(c4$media, a$media)) stop("controle: semente de outra concentração deu a mesma nula")
  },

  # médias em janela por data: controle negativo (t+1 a t+7), UR (lag 0–3) e PM2.5 (lag 0–1), conferidas à mão
  tsa_media_janela = function(f) {
    x <- c(3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8, 9, 7, 9, 3); d <- as.Date("2020-02-25") + seq_along(x) - 1
    cn <- f$media_janela(x, d, 1, 7); ur <- f$media_janela(x, d, -3, 0); pm <- f$media_janela(x, d, -1, 0)
    .sa_perto(cn[1], mean(x[2:8]), 1e-14); .sa_perto(cn[9], mean(x[10:16]), 1e-14); stopifnot(all(is.na(cn[10:16])))
    .sa_perto(ur[4], mean(x[1:4]), 1e-14); .sa_perto(ur[16], mean(x[13:16]), 1e-14); stopifnot(all(is.na(ur[1:3])))
    .sa_perto(pm[2], mean(x[1:2]), 1e-14); stopifnot(is.na(pm[1]))
    i <- which(d == as.Date("2020-03-01")); .sa_perto(ur[i], mean(x[d >= as.Date("2020-02-27") & d <= as.Date("2020-03-01")]), 1e-14)
  },

  # temperatura aparente: fórmula da §1.1 contra uma implementação independente (Magnus pela pressão de vapor) e o valor
  # conferido à mão (25 °C, UR 60%: 26,456 °C)
  tsa_temperatura_aparente = function(f) {
    g <- expand.grid(t = seq(5, 38, by = 1.5), rh = seq(20, 100, by = 5))
    e <- g$rh / 100 * 6.112 * exp(17.27 * g$t / (237.7 + g$t)); lnr <- log(e / 6.112); td <- 237.7 * lnr / (17.27 - lnr)
    .sa_perto(f$temperatura_aparente(g$t, g$rh), -2.653 + 0.994 * g$t + 0.0153 * td^2, 1e-10)
    .sa_perto(f$temperatura_aparente(25, 60), 26.45597, 1e-5)
  },

  # S3 contra um gam escrito aqui, em dado com estrato vazio (auditoria da Parte A, achado 2): mesma família, método,
  # estratos (vazio removido) e log_w; log RR igual (≤ 1e-8)
  tsa_s3_gam_independente = function(f) {
    d <- .sa_s3_dados(f, n = 900L); vz <- unique(d$estrato[d$janela])[7]; d$y[d$estrato == vz] <- 0
    at <- unname(stats::quantile(d$temp, c(0.99, 0.01), type = 7)); cen <- unname(stats::quantile(d$temp, 0.3, type = 7))
    r <- f$ajusta_s3(d, at = at, cen = cen, devolve_fit = TRUE); stopifnot(identical(r$status, "ok"), r$n$estratos_removidos == 1L)
    n <- nrow(d); Q <- matrix(vapply(0:7, function(l) c(rep(NA, l), d$temp[seq_len(n - l)]), numeric(n)), n); L <- matrix(rep(0:7, each = n), n)
    u <- d$janela & stats::complete.cases(Q) & d$estrato != vz
    m <- mgcv::gam(y ~ s(Q, L, bs = "cb", k = c(10, 8), xt = list(bs = "ps")) + factor(e) + ds + fer + car + mov + lw + offset(lz), family = stats::quasipoisson, method = "REML",
                   data = list(y = d$y[u], Q = Q[u, ], L = L[u, ], e = d$estrato[u], ds = d$dia_semana[u], fer = d$feriado_nacional[u], car = d$carnaval[u], mov = d$moveis[u], lw = d$log_w[u], lz = d$log_z[u]))
    cp <- dlnm::crosspred("Q", m, at = at, cen = cen); .sa_perto(r$logrr, cp$allfit[match(at, cp$predvar)], 1e-8); .sa_perto(r$ep, cp$allse[match(at, cp$predvar)], 1e-8)
    stopifnot(identical(r$fit$family$family, "quasipoisson"), identical(r$fit$method, "REML"), nlevels(r$fit$model$est) == length(unique(d$estrato[u])), "log_w" %in% names(stats::coef(r$fit)))
  },

  # uma etapa com estrato vazio (auditoria da Parte A, achado 6): o estrato sai, e φ e os coeficientes batem com o gnm
  # escrito aqui sem esse estrato
  tsa_uma_etapa_estrato_vazio = function(f) {
    .sa_semeia(41); al <- .sa_arglag(); lst <- lapply(1:3, function(k) { x <- f$gera_sintetico(n_dias = 700, eventos_dia = 25, unidade = paste0("c", k)); x$tmean <- x$temp; x })
    lst[[2]]$y[lst[[2]]$estrato == unique(lst[[2]]$estrato[lst[[2]]$janela])[6]] <- 0
    du <- do.call(rbind, lst); du$unidade <- rep(paste0("c", 1:3), each = 707); ref <- setNames(lapply(lst, `[[`, "tmean"), paste0("c", 1:3))
    r <- f$uma_etapa(du, ref, al); stopifnot(identical(r$status, "ok"), r$n$estratos_removidos == 1L)
    pct <- unlist(lapply(1:3, function(k) .sa_pct(lst[[k]]$tmean, ref[[k]])))
    cb <- dlnm::crossbasis(pct, lag = 7, argvar = list(fun = "ns", knots = c(10, 75, 90), Boundary.knots = range(pct)), arglag = al, group = du$unidade)
    ev <- tapply(du$y[du$janela], du$estrato[du$janela], sum); u <- du$janela & stats::complete.cases(cb) & !(du$estrato %in% names(ev)[ev == 0])
    m <- gnm::gnm(du$y[u] ~ unclass(cb)[u, ] + du$dia_semana[u] + du$feriado_nacional[u] + du$carnaval[u] + du$moveis[u] + du$log_w[u]:factor(du$unidade[u]),
                  eliminate = factor(du$estrato[u]), offset = du$log_z[u], family = stats::quasipoisson, verbose = FALSE)
    .sa_perto(r$coef_cb, stats::coef(m)[1:16], 1e-8); .sa_perto(r$phi, sum(stats::residuals(m, type = "pearson")^2) / m$df.residual, 1e-10, rel = TRUE)
  },

  # m3: estratos com dia da semana: sem dia_semana, posto completo; com dia_semana mantido, deficiência acusada
  tsa_confere_posto = function(f) {
    .sa_semeia(20261001); d <- f$gera_sintetico(n_dias = 900, eventos_dia = 30); d$estrato_dow <- paste(d$estrato, d$dia_semana, sep = "_")
    q <- stats::quantile(d$temp, c(.10, .50, .75, .90), type = 7, names = FALSE); av <- list(fun = "ns", knots = q[c(1, 3, 4)])
    s1 <- f$spec_agudo("y", "temp", "janela", 7, argvar = av, arglag = .sa_arglag(), estrato = "estrato_dow", covariaveis = c("feriado_nacional", "carnaval", "moveis"), cen = q[2])
    p1 <- f$confere_posto(f$ajusta_dlnm(d, s1, devolve_matriz = TRUE)$matriz); if (!isTRUE(p1$completo)) stop("posto incompleto sem dia_semana: ", p1$posto, " de ", p1$colunas)
    s2 <- f$spec_agudo("y", "temp", "janela", 7, argvar = av, arglag = .sa_arglag(), estrato = "estrato_dow", cen = q[2])
    p2 <- f$confere_posto(f$ajusta_dlnm(d, s2, devolve_matriz = TRUE)$matriz)
    if (!(identical(p2$completo, FALSE) && p2$colunas - p2$posto == 6L)) stop("controle: dia_semana mantido não acusou a deficiência de 6 colunas (", p2$posto, " de ", p2$colunas, ")")
  },

  # achado C e auditoria do chat de 18/10, M1 (camada de conteúdo): o log não leva coeficientes BLUP por concentração.
  # Barra as quatro variantes do chat (literal, rótulo "Coeficientes BLUP (por concentração):", título em inglês, tabela
  # sem título com colunas b1, b2) e outras formas (tabela sem b com notação científica, célula curta "Coeficiente BLUP",
  # texto numa string só, cabeçalho literal no meio da prosa, coluna de diagnóstico com "coef" no cabeçalho, células a
  # mais que o cabeçalho). Calibração:
  # passam a prosa que só menciona os coeficientes, a célula longa e a tabela de diferenças (diagnóstico numérico). Logs
  # reais: o da AF da Fase 3 (controle positivo do chat) e o post hoc da AF passam; o 45 (com a tabela) é barrado. O
  # gravador confere e não sobrescreve; máscara "<10"
  tsa_log_sigilo = function(f) {
    limpo <- c("# Log", "", "| Concentração | TMR BLUP (°C) | RR BLUP p99 |", "|---|---|---|", "| X | 28,1 | 1,02 |")
    f$confere_log_sigilo(limpo)
    tab <- function(cab, linha) c(cab, paste0("|", paste(rep("---", lengths(strsplit(cab, "|", fixed = TRUE)) - 1L), collapse = "|"), "|"), linha)
    barra <- list(literal = c(limpo, "", "## BLUPs por concentração (coeficientes)", "| x | 0,01 |"),
                  rotulo = c(limpo, "", "Coeficientes BLUP (por concentração):"),
                  ingles = c(limpo, "", "BLUP coefficients by urban concentration"),
                  tabela_sem_titulo = c(limpo, "", tab("| Concentração | b1 | b2 |", "| X | -2.016e-02 (4.267e-02) | 1.100e-02 (3.000e-03) |")),
                  antiga_1 = c(limpo, "Tabela de coeficientes BLUP por concentração"), antiga_2 = c(limpo, "blups por concentracao (coeficientes"),
                  tabela_sem_b = c(limpo, "", tab("| Concentração | Primeiro | Segundo |", "| X | -2.016e-02 (4.267e-02) | 1.100e-02 (3.000e-03) |")),
                  celula_curta = c(limpo, "", tab("| Concentração | Coeficiente BLUP | EP |", "| X | -2,016 | 4,267 |")),
                  string_unica = paste(c("Texto corrido do log, sem título, com mais de seis palavras.", "", "BLUP coefficients by urban concentration"), collapse = "\n"),
                  literal_em_prosa = c(limpo, "", "- Nota: os coeficientes BLUP por concentração vão para a tabela do suplemento, com EP, nas 26 concentrações."),
                  diag_com_coef = tab("| Concentração | Diferença de coeficientes | Δ coef | Folga coef |", "| X | 1.0e-02 | 2.0e-02 | 3.0e-02 |"),
                  celulas_a_mais = tab("| Concentração | Diferença das bases | g | Menor Δ_t |", "| X | 1.0e-08 | 2.0e-08 | 3.0e-08 | 4.0e-08 |"))
    for (n in names(barra)) if (!inherits(tryCatch(f$confere_log_sigilo(barra[[n]]), error = function(e) e), "error")) stop("controle: log com coeficientes BLUP aceito (", n, ")")
    passa <- list(prosa = c(limpo, "", "- A tabela de coeficientes BLUP da segunda etapa fica na RDS, fora do git, e não entra neste log (A1-82(c))."),
                  celula_longa = tab("| Item | Nota |", "| 6 | A tabela de coeficientes BLUP da segunda etapa fica na RDS, fora do git |"),
                  diagnostico = tab("| Concentração | Diferença das bases | g | Menor Δ_t |", "| X | 1.0e-08 | 2.0e-08 | 3.0e-08 |"))
    for (n in names(passa)) { e <- tryCatch(f$confere_log_sigilo(passa[[n]]), error = function(e) e); if (inherits(e, "error")) stop("falso positivo (", n, "): ", conditionMessage(e)) }
    if (is.null(.REF$repo)) stop(".REF$repo ausente: o executor tem de dizer onde está o repositório")
    lg <- function(a) readLines(file.path(.REF$repo, "artigo1_prematuridade", "logs", a), encoding = "UTF-8", warn = FALSE)
    for (a in c("fracao_atribuivel_fase3_20261013.md", "posthoc_af_fase3_20261013.md")) {
      e <- tryCatch(f$confere_log_sigilo(lg(a)), error = function(e) e); if (inherits(e, "error")) stop("log real legítimo barrado (", a, "): ", conditionMessage(e)) }
    if (!inherits(tryCatch(f$confere_log_sigilo(lg("segunda_etapa_fase3_20261013.md")), error = function(e) e), "error")) stop("controle: o log 45, com a tabela dos coeficientes, passou")
    tf <- tempfile(fileext = ".md"); f$escreve_log_seguro(limpo, tf); if (!identical(readLines(tf), limpo)) stop("gravação diferente")
    if (!inherits(tryCatch(f$escreve_log_seguro(limpo, tf), error = function(e) e), "error")) stop("sobrescreveu o log")
    tf2 <- tempfile(fileext = ".md"); if (!inherits(tryCatch(f$escreve_log_seguro(c(limpo, "## BLUPs por concentração (coeficientes)"), tf2), error = function(e) e), "error") || file.exists(tf2)) stop("gravou log sujo")
    unlink(tf); if (!identical(f$mascara_contagem(c(0, 1, 9, 10, 125)), c("0", "<10", "<10", "10", "125"))) stop("máscara <10 errada")
  },

  # M1, camada do locale: num subprocesso com LC_ALL=C, a confere_log_sigilo para (mesmo com um log limpo); controle: o
  # mesmo subprocesso com LC_ALL=en_US.UTF-8 passa (no Mac, o R desta sessão diz "pt_BR", sem o codeset no nome)
  tsa_log_sigilo_locale = function(f) {
    if (is.null(.REF$caminho_sa)) stop(".REF$caminho_sa ausente: o executor tem de dizer onde está a sens_agudos.R")
    tf <- tempfile(fileext = ".R")
    writeLines(c(sprintf('e <- new.env(); sys.source("%s", envir = e)', .REF$caminho_sa), 'cat("utf8=", l10n_info()[["UTF-8"]], "\\n", sep = "")',
                 'r <- tryCatch({ e$confere_log_sigilo(c("| Concentracao | TMR |", "|---|---|", "| X | 28,1 |")); "passa" }, error = function(z) if (grepl("locale", conditionMessage(z), fixed = TRUE)) "barra_locale" else "barra_outro")',
                 'cat(r, "\\n")'), tf)
    rs <- file.path(R.home("bin"), "Rscript")
    oc <- system2(rs, c("--vanilla", shQuote(tf)), stdout = TRUE, stderr = TRUE, env = "LC_ALL=C")
    ou <- system2(rs, c("--vanilla", shQuote(tf)), stdout = TRUE, stderr = TRUE, env = "LC_ALL=en_US.UTF-8"); unlink(tf)
    if (!any(grepl("utf8=FALSE", oc, fixed = TRUE))) stop("cenário: o subprocesso com LC_ALL=C ficou em UTF-8: ", paste(oc, collapse = " | "))
    if (!any(grepl("barra_locale", oc, fixed = TRUE))) stop("locale C não barrou: ", paste(oc, collapse = " | "))
    if (!(any(grepl("utf8=TRUE", ou, fixed = TRUE)) && any(grepl("passa", ou, fixed = TRUE)))) stop("controle: no locale UTF-8 o log limpo não passou: ", paste(ou, collapse = " | "))
  },

  # M1, camada estrutural: tabela_log monta a tabela só com colunas da lista branca; para em coluna de coeficiente, vcov,
  # Ψ ou BLUP, em coluna fora da lista, em coluna-lista e em contagem não mascarada; os rótulos passam pela conferência
  # de conteúdo (rótulos b1, b2 param)
  tsa_tabela_log = function(f) {
    df <- data.frame(concentracao = c("A", "B"), tmr = c(28.1, 27.4), ic = c("26,0 a 29,3", "25,1 a 28,8"), q = c(12.3, 4.5), p = c(0.04, 0.61),
                     n_mascarado = f$mascara_contagem(c(5, 120)), stringsAsFactors = FALSE)
    ls <- f$tabela_log(df, rotulos = c("Concentração", "TMR (°C)", "IC 95%", "Q", "p", "Eventos"))
    stopifnot(length(ls) == 4L, identical(ls[1], "| Concentração | TMR (°C) | IC 95% | Q | p | Eventos |"), grepl("| <10 |", ls[3], fixed = TRUE))
    erro <- function(d, padrao, ...) { m <- tryCatch({ f$tabela_log(d, ...); NA_character_ }, error = function(e) conditionMessage(e))
      if (is.na(m) || !grepl(padrao, m, fixed = TRUE)) stop("tabela_log não parou como devia (", padrao, "): ", m) }
    for (nm in c("b1", "coef_media", "vcov11", "tmr_blup", "psi1")) { d2 <- df; d2[[nm]] <- 0.1; erro(d2, "coluna proibida") }
    d3 <- df; d3$eventos <- "120"; erro(d3, "fora da lista branca")
    d4 <- df; d4$tmr <- I(list(1, 2)); erro(d4, "coluna-lista")
    d5 <- df; d5$n_mascarado <- c(5, 120); erro(d5, "mascaradas")
    erro(df[, c("concentracao", "tmr", "q")], "confere_log_sigilo", rotulos = c("Concentração", "b1", "b2"))
  },

  # auditoria do chat de 18/10, N5: desenho_completo tira as colunas linearmente dependentes (carnaval constante em 0,
  # coeficiente NA; moveis constante em 1, colinear com os estratos) e a projeção é a mesma do desenho montado aqui sem
  # elas (≤ 1e-10); controle: com o desenho bruto, a projeta_ponderada para (posto incompleto)
  tsa_desenho_completo = function(f) {
    .sa_semeia(20261001); d <- f$gera_sintetico(n_dias = 700, eventos_dia = 30); d$carnaval <- 0L; d$moveis <- 1L
    q <- stats::quantile(d$temp, c(.10, .50, .75, .90), type = 7, names = FALSE)
    r <- f$ajusta_dlnm(d, f$spec_agudo("y", "temp", "janela", 7, argvar = list(fun = "ns", knots = q[c(1, 3, 4)]), arglag = .sa_arglag(), cen = q[2]), devolve_matriz = TRUE)
    stopifnot(identical(r$status, "ok")); mt <- r$matriz; X <- f$desenho_completo(mt)
    if (!identical(attr(X, "removidas"), c("carnaval", "moveis"))) stop("colunas removidas: ", paste(attr(X, "removidas"), collapse = ", "))
    Xm <- cbind(stats::model.matrix(~ e - 1, data.frame(e = droplevels(factor(mt$estrato)))), mt$X[, setdiff(colnames(mt$X), c("carnaval", "moveis"))])
    stopifnot(qr(Xm)$rank == ncol(Xm), ncol(X) == ncol(Xm))
    .sa_semeia(7); E <- matrix(stats::rnorm(nrow(X) * 5), nrow(X)); W <- mt$peso_trabalho
    .sa_perto(f$projeta_ponderada(E, X, W), qr.resid(qr(sqrt(W) * Xm), E), 1e-10)
    m <- tryCatch({ f$projeta_ponderada(E, f$.desenho_bruto(mt), W); NA_character_ }, error = function(e) conditionMessage(e))
    if (is.na(m) || !grepl("posto incompleto", m, fixed = TRUE)) stop("controle: a projeção com o desenho bruto não parou: ", m)
  },

  # achado 4: pacf_grade = PACF da série com 0 fora (C2, item 3), conferida à mão com buracos; a convenção NA difere
  tsa_pacf_convencao = function(f) {
    .sa_semeia(19); n <- 600; r <- stats::rnorm(n); pos <- setdiff(seq_len(n), c(101:130, 401:431)); v0 <- numeric(n); v0[pos] <- r[pos]
    .sa_perto(f$pacf_grade(r[pos], pos, n, 7), stats::pacf(v0, lag.max = 7, plot = FALSE)$acf[1:7], 1e-14)
    vna <- rep(NA_real_, n); vna[pos] <- r[pos]; pna <- stats::pacf(vna, lag.max = 7, plot = FALSE, na.action = stats::na.pass)$acf[1:7]
    if (!(max(abs(pna - f$pacf_grade(r[pos], pos, n, 7))) > 1e-6)) stop("controle sem poder: convenções NA e 0 coincidem com buracos")
  }
)
