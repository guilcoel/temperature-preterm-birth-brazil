# sens_agudos.R — sensibilidades dos agudos fora da ajusta_dlnm, versão 1.0 (Fase 4 do Artigo 1; prompt da Fase 4,
# seção 2, itens 3 e 6; D11, 5.2 e 5.3; D13, item 3; D16, item 2; entradas A1-93, A1-95, A1-97 e A1-99). Autor: A1;
# o A2 reusa na retomada. Requer dlnm, gnm, mixmeta e mgcv (renv do artigo) e as funções da segunda_etapa (grade_tmr,
# posicao_no_eixo, curva, semeia, .base_x) carregadas no mesmo ambiente. Nenhuma função grava arquivo, imprime contagem
# ou devolve série diária.
#
# Funções:
#   percentil_conc(tmean, tmean_ref): percentil de cada dia na distribuição de referência da concentração (D11, 5.3):
#     approx(quantile(tmean_ref, seq(0, 1, 0.001), type = 7), seq(0, 100, 0.1), xout = tmean, rule = 2, ties = mean).
#     Dias fora do range da referência ficam em 0 ou 100 (rule = 2; declarar).
#   uma_etapa(dados, ref, arglag, lag, nos_pct, covariaveis, desfecho, janela, estrato): modelo único (D11, 5.3): séries
#     empilhadas (unidades contíguas, datas consecutivas, cada uma com os seus dias de aquecimento), percentil por
#     percentil_conc com a referência de cada unidade, cross-basis comum com group = unidade, argvar ns com nós nos
#     percentis nos_pct (10, 75, 90) e Boundary.knots = range(pct) do empilhado (D6, 2.2), arglag do principal; gnm
#     quasi-Poisson com eliminate = estrato (unidade × ano × mês; estratos sem evento removidos), offset log_z, um γ por
#     unidade (colunas log_w × indicadora), calendário comum, φ único. Falha (erro, não convergência, coeficiente da
#     cross-basis aliasado, vcov não positiva-definida): status "falhou", sem fallback (D11, 5.3). Devolve os
#     coeficientes e a vcov da cross-basis, os reduzidos (overall), os γ, φ, a argvar e contagens.
#   curva_uma_etapa(res, eixo_valores, eixo_probs, nsim): curva em percentil, avaliada no eixo médio (°C → percentil por
#     posicao_no_eixo); TMR na grade de 0,1 °C entre x1 e x99 do eixo (grade_tmr), borda pelo índice (C3(b)); IC da TMR
#     por bootstrap paramétrico (Cholesky, semente 20261001, semeia(0)), com os sorteios em tmr_sim; RR no x99 e no x1
#     contra a TMR, com a TMR fixa.
#     TMR na borda (D13, item 3): o contraste daquele lado vale 1 por construção, sem IC; o RR contra a mediana (x50) sai
#     como descritivo; sem busca entre p10 e p90.
#   ajusta_s3(dados, at, cen, desfecho, exposicao, janela, estrato, covariaveis, lag, k): DLNM penalizado (D11, 5.2):
#     mgcv::gam(y ~ s(Q, L, bs = "cb", k = c(10, 8), xt = list(bs = "ps")) + factor(estrato) + calendário + log_w +
#     offset(log_z), family = quasipoisson, method = "REML"); Q = exposição nos lags 0…lag na série consecutiva (com
#     aquecimento), L = matriz dos lags. log RR cumulativo em `at` contra `cen` pelo crosspred (vcov = Vp), na ordem de
#     `at` (o crosspred ordena os valores; o casamento é por predvar). Falha: status
#     "falhou" (a concentração sai da 2ª etapa da S3, com registro).
#   confere_s3_lpmatrix(fit, x, cen, lag): o mesmo log RR pela diferença das predições do predict.gam(type =
#     "lpmatrix") nas linhas Q = x e Q = cen (lags 0…lag), só nas colunas do termo s(Q,L) (teste da D11, 5.2).
#   confere_mgcv(): os quatro pontos da P11 na versão instalada: m padrão do ps = c(2, 2); k maior que o número de
#     valores únicos só dá aviso; vcov.gam devolve Vp (identical com unname); dimensão do termo cb com k = c(10, 8) = 72.
#   meta_univariada(y, v, metapred, formula, ajusta): mixmeta univariado REML com os metapreditores do principal e
#     predição na média (2ª etapa da S3).
#   confere_pesos(W, mu): max|W − μ̂|/μ̂ (D16, item 2: os pesos de trabalho finais são W = μ̂).
#   desenho_completo(matriz): X da nula da PACF = indicadoras dos estratos não vazios + colunas não eliminadas.
#   projeta_ponderada(E, X, W): (I − W^{1/2}X(X′WX)^{−1}X′W^{1/2})E, pela QR de W^{1/2}X (D16, item 2).
#   pacf_grade(r, pos, n_grade, lag.max): PACF de uma série posta numa grade consecutiva de n_grade dias, com o valor nas
#     posições pos e 0 fora (complemento C2, item 3).
#   nula_pacf(matriz, pos, n_grade, i, R, lag.max): R séries de ruído branco gaussiano nas linhas do ajuste (semente
#     20261001 + i, semeia(i)), projetadas por projeta_ponderada no desenho completo, postas na grade com 0 fora e com a
#     PACF de cada uma; devolve a média e os quantis 2,5% e 97,5% por lag, o max|X′W^{1/2}e*| e a escala do teste.
#   media_janela(x, datas, de, ate): média de x nos dias t + de … t + ate (datas consecutivas; NA se faltar algum dia):
#     controle negativo = media_janela(tmean, datas, 1, 7) (t+1 a t+7, §4); UR = media_janela(rh, datas, -3, 0) (lag 0–3,
#     §1.1); PM2.5 = media_janela(pm25, datas, -1, 0) (lag 0–1, §2.3).
#   temperatura_aparente(tmean, rh): AT = −2,653 + 0,994·T + 0,0153·Td², com Td pela fórmula de Magnus (§1.1):
#     α = 17,27·T/(237,7 + T) + ln(UR/100); Td = 237,7·α/(17,27 − α).
#   Na uma_etapa, `cb_na_aquecimento` confere que as primeiras `lag` linhas de cada unidade saem NA na cross-basis (o
#     group impede o lag de atravessar de uma unidade para a outra).

percentil_conc <- function(tmean, tmean_ref) {
  if (anyNA(tmean_ref)) stop("percentil_conc: tmean_ref com NA")
  q <- stats::quantile(tmean_ref, probs = seq(0, 1, 0.001), type = 7, names = FALSE)
  stats::approx(x = q, y = seq(0, 100, 0.1), xout = tmean, rule = 2, ties = mean)$y
}

.autovalor_min_s <- function(v) if (is.null(v) || !all(is.finite(v))) NA_real_ else min(eigen(v, symmetric = TRUE, only.values = TRUE)$values)

uma_etapa <- function(dados, ref, arglag, lag = 7L, nos_pct = c(10, 75, 90),
                      covariaveis = c("dia_semana", "feriado_nacional", "carnaval", "moveis"),
                      desfecho = "y", janela = "janela", estrato = "estrato") {
  stopifnot(is.data.frame(dados), all(c("unidade", "data", "tmean", "log_z", "log_w", desfecho, janela, estrato, covariaveis) %in% names(dados)),
            inherits(dados$data, "Date"), is.list(ref))
  u_ch <- as.character(dados$unidade); r <- rle(u_ch); if (anyDuplicated(r$values)) stop("uma_etapa: unidades não contíguas")
  for (u in r$values) if (any(diff(dados$data[u_ch == u]) != 1)) stop("uma_etapa: unidade ", u, " com datas não consecutivas")
  if (!all(r$values %in% names(ref))) stop("uma_etapa: unidade sem série de referência")
  pct <- numeric(nrow(dados)); for (u in r$values) pct[u_ch == u] <- percentil_conc(dados$tmean[u_ch == u], ref[[u]])
  av <- list(fun = "ns", knots = nos_pct, Boundary.knots = range(pct), intercept = FALSE)
  out <- list(status = "falhou", mensagem = NA_character_, avisos = character(0), unidades = r$values, argvar = av)
  cb <- tryCatch(dlnm::crossbasis(pct, lag = lag, argvar = av, arglag = arglag, group = u_ch), error = function(e) e)
  if (inherits(cb, "error")) { out$mensagem <- paste("erro na cross-basis:", conditionMessage(cb)); return(out) }
  out$argvar <- attr(cb, "argvar"); out$arglag <- attr(cb, "arglag"); out$lag <- attr(cb, "lag")
  out$cb_na_aquecimento <- all(vapply(r$values, function(u) all(is.na(unclass(cb)[which(u_ch == u)[seq_len(lag)], ])), TRUE))
  ok <- dados[[janela]] %in% TRUE & stats::complete.cases(cb) & stats::complete.cases(dados[, c(desfecho, covariaveis, estrato), drop = FALSE]) &
        is.finite(dados$log_z) & is.finite(dados$log_w)
  est <- as.character(dados[[estrato]]); ev <- tapply(dados[[desfecho]][ok], est[ok], sum); vazios <- names(ev)[ev == 0]
  usar <- ok & !(est %in% vazios)
  out$n <- list(dias_usados = sum(usar), eventos = sum(dados[[desfecho]][usar]), estratos_usados = length(unique(est[usar])), estratos_removidos = length(vazios))
  md <- data.frame(y = dados[[desfecho]][usar], est = factor(est[usar]))
  for (k in covariaveis) md[[k]] <- dados[[k]][usar]
  md$cb <- unclass(cb)[usar, , drop = FALSE]
  G <- vapply(r$values, function(u) ifelse(u_ch[usar] == u, dados$log_w[usar], 0), numeric(sum(usar)))
  G <- matrix(G, nrow = sum(usar)); colnames(G) <- paste0("u", seq_along(r$values)); md$gama <- G
  form <- stats::as.formula(paste("y ~", paste(c("cb", covariaveis, "gama"), collapse = " + ")))
  avisos <- character(0)
  m <- withCallingHandlers(tryCatch(gnm::gnm(form, eliminate = est, family = stats::quasipoisson, data = md, offset = dados$log_z[usar], verbose = FALSE),
                                    error = function(e) e),
                           warning = function(w) { avisos <<- c(avisos, conditionMessage(w)); invokeRestart("muffleWarning") })
  out$avisos <- avisos
  if (inherits(m, "error")) { out$mensagem <- paste("erro no ajuste:", conditionMessage(m)); return(out) }
  if (is.null(m)) { out$mensagem <- "o gnm não devolveu modelo"; return(out) }
  falhas <- character(0)
  if (!isTRUE(m$converged) || any(grepl("converg", avisos, ignore.case = TRUE))) falhas <- c(falhas, "não convergiu")
  cf <- stats::coef(m); i_cb <- grep("^cb", names(cf)); i_g <- grep("^gama", names(cf))
  out$coef_cb <- cf[i_cb]; if (anyNA(out$coef_cb)) falhas <- c(falhas, "coeficiente da cross-basis aliasado")
  out$gama <- setNames(unname(cf[i_g]), r$values)
  V <- tryCatch(stats::vcov(m), error = function(e) NULL)
  if (is.null(V)) falhas <- c(falhas, "vcov indisponível") else if (!anyNA(out$coef_cb)) {
    out$vcov_cb <- V[names(cf)[i_cb], names(cf)[i_cb], drop = FALSE]
    if (!isTRUE(.autovalor_min_s(out$vcov_cb) > 0)) falhas <- c(falhas, "vcov da cross-basis não positiva-definida")
  }
  out$phi <- sum(stats::residuals(m, type = "pearson")^2) / m$df.residual
  if (!length(falhas)) {
    red <- tryCatch(dlnm::crossreduce(cb, coef = out$coef_cb, vcov = out$vcov_cb, model.link = "log", type = "overall", cen = 50), error = function(e) e)
    if (inherits(red, "error")) falhas <- c(falhas, paste("erro no crossreduce:", conditionMessage(red))) else
      out$reduzida <- list(coef = unname(stats::coef(red)), vcov = unname(stats::vcov(red)))
  }
  if (length(falhas)) { out$mensagem <- paste(falhas, collapse = "; "); return(out) }
  out$status <- "ok"; out$mensagem <- "ok"
  out
}

curva_uma_etapa <- function(res, eixo_valores, eixo_probs, nsim = 1000L) {
  if (!identical(res$status, "ok")) stop("curva_uma_etapa: ajuste da uma etapa sem status ok")
  stopifnot(length(eixo_valores) == length(eixo_probs), !is.unsorted(eixo_valores, strictly = TRUE))
  iq <- function(p) { i <- which(eixo_probs == p); if (length(i) != 1) stop("curva_uma_etapa: eixo sem o percentil ", p); eixo_valores[i] }
  x1 <- iq(1); x50 <- iq(50); x99 <- iq(99)
  g <- grade_tmr(x1, x99); pg <- posicao_no_eixo(g, eixo_valores, eixo_probs)
  if (anyNA(pg)) stop("curva_uma_etapa: percentil NA na grade (valor fora do eixo)")
  av <- res$argvar; cf <- res$reduzida$coef; V <- res$reduzida$vcov
  eta <- drop(.base_x(pg, av) %*% cf); i <- which.min(eta); fronteira <- i %in% c(1L, length(g))
  R <- tryCatch(chol(V), error = function(e) e)
  tm <- NULL
  ic <- if (inherits(R, "error")) c(NA_real_, NA_real_) else {
    semeia(0); sims <- cf + t(R) %*% matrix(stats::rnorm(length(cf) * nsim), length(cf))
    tm <- g[apply(.base_x(pg, av) %*% sims, 2, which.min)]; unname(stats::quantile(tm, c(0.025, 0.975), type = 7)) }
  p_x <- posicao_no_eixo(c(x99, x1), eixo_valores, eixo_probs)
  rr <- curva(cf, V, av, p_x, pg[i]); rr$rotulo <- c("x99", "x1")
  lado_borda <- if (!fronteira) NA_character_ else if (i == length(g)) "x99" else "x1"
  if (fronteira) { j <- which(rr$rotulo == lado_borda); rr$rr[j] <- 1; rr$rr_li[j] <- NA_real_; rr$rr_ls[j] <- NA_real_ }
  rr_med <- if (fronteira) { m <- curva(cf, V, av, p_x, posicao_no_eixo(x50, eixo_valores, eixo_probs)); m$rotulo <- c("x99", "x1"); m } else NULL
  list(tmr = g[i], tmr_pct = pg[i], indice = i, n_grade = length(g), fronteira = fronteira, lado_borda = lado_borda,
       ic_tmr = ic, tmr_sim = tm, motivo_ic = if (inherits(R, "error")) "vcov não positiva-definida" else NA_character_, rr = rr, rr_mediana = rr_med)
}

ajusta_s3 <- function(dados, at, cen, desfecho = "y", exposicao = "tmean", janela = "janela", estrato = "estrato",
                      covariaveis = c("dia_semana", "feriado_nacional", "carnaval", "moveis"), lag = 7L, k = c(10L, 8L),
                      devolve_fit = FALSE) {
  stopifnot(is.data.frame(dados), inherits(dados$data, "Date"), all(c(desfecho, exposicao, janela, estrato, covariaveis, "log_z", "log_w") %in% names(dados)))
  if (any(diff(dados$data) != 1)) stop("ajusta_s3: datas não consecutivas")
  requireNamespace("dlnm", quietly = TRUE)                            # registra o smooth.construct do bs = "cb"
  n <- nrow(dados); x <- dados[[exposicao]]
  Q <- vapply(0:lag, function(l) c(rep(NA_real_, l), x[seq_len(n - l)]), numeric(n)); Q <- matrix(Q, nrow = n)
  L <- matrix(rep(0:lag, each = n), nrow = n)
  ok <- dados[[janela]] %in% TRUE & stats::complete.cases(Q) & stats::complete.cases(dados[, c(desfecho, covariaveis, estrato), drop = FALSE]) &
        is.finite(dados$log_z) & is.finite(dados$log_w)
  est <- as.character(dados[[estrato]]); ev <- tapply(dados[[desfecho]][ok], est[ok], sum); vazios <- names(ev)[ev == 0]
  usar <- ok & !(est %in% vazios)
  md <- data.frame(y = dados[[desfecho]][usar], est = factor(est[usar]), log_w = dados$log_w[usar], log_z = dados$log_z[usar])
  for (kk in covariaveis) md[[kk]] <- dados[[kk]][usar]
  md$Q <- Q[usar, , drop = FALSE]; md$L <- L[usar, , drop = FALSE]
  form <- stats::as.formula(paste("y ~ s(Q, L, bs = \"cb\", k = c(", k[1], ",", k[2], "), xt = list(bs = \"ps\")) + est +",
                                  paste(c(covariaveis, "log_w"), collapse = " + "), "+ offset(log_z)"))
  out <- list(status = "falhou", mensagem = NA_character_, avisos = character(0),
              n = list(dias_usados = sum(usar), eventos = sum(dados[[desfecho]][usar]), estratos_removidos = length(vazios)))
  avisos <- character(0)
  fit <- withCallingHandlers(tryCatch(mgcv::gam(form, family = stats::quasipoisson, method = "REML", data = md), error = function(e) e),
                             warning = function(w) { avisos <<- c(avisos, conditionMessage(w)); invokeRestart("muffleWarning") })
  out$avisos <- avisos
  if (inherits(fit, "error")) { out$mensagem <- paste("erro no ajuste:", conditionMessage(fit)); return(out) }
  conv <- isTRUE(fit$converged) && (is.null(fit$outer.info$conv) || identical(fit$outer.info$conv, "full convergence"))
  if (!conv) { out$mensagem <- "não convergiu"; return(out) }
  cp <- tryCatch(dlnm::crosspred("Q", fit, at = at, cen = cen, lag = c(0, lag)), error = function(e) e)
  if (inherits(cp, "error")) { out$mensagem <- paste("erro no crosspred:", conditionMessage(cp)); return(out) }
  i_s <- grep("^s\\(Q,L\\)", names(stats::coef(fit)))
  out$status <- "ok"; out$mensagem <- "ok"
  ia <- match(at, cp$predvar); if (anyNA(ia)) { out$status <- "falhou"; out$mensagem <- "crosspred sem algum ponto de at"; return(out) }
  out$logrr <- unname(cp$allfit[ia]); out$ep <- unname(cp$allse[ia])     # o crosspred ordena `at`: casar por predvar
  out$at <- at; out$cen <- cen; out$dim_s <- length(i_s); out$edf_s <- sum(fit$edf[i_s]); out$phi <- fit$scale
  if (isTRUE(devolve_fit)) out$fit <- fit
  out
}

confere_s3_lpmatrix <- function(fit, x, cen, lag = 7L) {
  nd <- fit$model[c(1, 1), , drop = FALSE]
  nd$Q <- rbind(rep(x, lag + 1L), rep(cen, lag + 1L)); nd$L <- rbind(0:lag, 0:lag)
  Xp <- mgcv::predict.gam(fit, newdata = nd, type = "lpmatrix")
  i_s <- grep("^s\\(Q,L\\)", colnames(Xp))
  drop((Xp[1, i_s] - Xp[2, i_s]) %*% stats::coef(fit)[i_s])
}

confere_mgcv <- function() {
  requireNamespace("dlnm", quietly = TRUE)
  sm <- mgcv::smooth.construct(mgcv::s(x, bs = "ps"), data.frame(x = seq(0, 1, length.out = 50)), NULL)
  aviso <- NULL; erro <- NULL
  tryCatch(withCallingHandlers(mgcv::smooth.construct(mgcv::s(x, bs = "ps", k = 10), data.frame(x = rep(0:7, 10)), NULL),
                               warning = function(w) { aviso <<- conditionMessage(w); invokeRestart("muffleWarning") }),
           error = function(e) erro <<- conditionMessage(e))
  set.seed(20261001, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
  n <- 300; d <- data.frame(z = stats::runif(n)); d$y <- stats::rpois(n, exp(1 + sin(2 * pi * d$z)))
  fz <- mgcv::gam(y ~ s(z, bs = "ps"), family = stats::quasipoisson, method = "REML", data = d)
  Qm <- matrix(stats::rnorm(50 * 8), 50); Lm <- matrix(rep(0:7, each = 50), 50)
  sc <- mgcv::smoothCon(mgcv::s(Q, L, bs = "cb", k = c(10, 8), xt = list(bs = "ps")), data = list(Q = Qm, L = Lm), knots = NULL, absorb.cons = TRUE, n = 50L)
  list(versao = as.character(utils::packageVersion("mgcv")), m_ps = sm$m, ps_m_padrao_2_2 = identical(as.numeric(sm$m), c(2, 2)),
       aviso_k = aviso, erro_k = erro, k_so_aviso = !is.null(aviso) && is.null(erro),
       vcov_igual_Vp = identical(unname(stats::vcov(fz)), unname(fz$Vp)), dim_cb = ncol(sc[[1]]$X), dim_cb_72 = ncol(sc[[1]]$X) == 72L)
}

meta_univariada <- function(y, v, metapred, formula = ~ media + amplitude, ajusta = mixmeta::mixmeta) {
  stopifnot(length(y) == length(v), nrow(metapred) == length(y), all(v > 0))
  md <- as.data.frame(metapred); md$.y <- as.numeric(y); termos <- attr(stats::terms(formula), "term.labels")
  fml <- stats::as.formula(paste(".y ~", paste(termos, collapse = " + "))); environment(fml) <- environment()
  av <- character(0)
  fit <- withCallingHandlers(tryCatch(ajusta(fml, S = as.numeric(v), data = md, method = "reml"), error = function(e) e),
                             warning = function(w) { av <<- c(av, conditionMessage(w)); invokeRestart("muffleWarning") })
  if (inherits(fit, "error") || isFALSE(fit$converged)) return(list(status = "falhou", mensagem = if (inherits(fit, "error")) conditionMessage(fit) else "não convergiu"))
  nd <- as.data.frame(t(colMeans(md[, termos, drop = FALSE]))); pr <- stats::predict(fit, newdata = nd, vcov = TRUE)
  list(status = "ok", avisos = av, coef = stats::coef(fit), vcov = stats::vcov(fit), tau2 = as.numeric(fit$Psi),
       estimativa = unname(as.numeric(pr[["fit"]])), ep = sqrt(unname(as.numeric(pr[["vcov"]]))), metapred_media = nd)   # univariado: vetor nomeado
}

confere_pesos <- function(W, mu) max(abs(W - mu) / mu)

desenho_completo <- function(matriz) {
  X <- matriz$X
  if (!is.null(matriz$estrato)) X <- cbind(stats::model.matrix(~ estrato - 1, data.frame(estrato = droplevels(factor(matriz$estrato)))), X)
  X
}

projeta_ponderada <- function(E, X, W) {
  stopifnot(nrow(as.matrix(E)) == nrow(X), length(W) == nrow(X), all(W > 0))
  qx <- qr(sqrt(W) * X)
  if (qx$rank < ncol(X)) stop("projeta_ponderada: desenho com posto incompleto (", qx$rank, " de ", ncol(X), ")")
  qr.resid(qx, as.matrix(E))
}

pacf_grade <- function(r, pos, n_grade, lag.max = 7L) {
  v <- numeric(n_grade); v[pos] <- r
  as.numeric(stats::pacf(v, lag.max = lag.max, plot = FALSE)$acf)[seq_len(lag.max)]
}

nula_pacf <- function(matriz, pos, n_grade, i, R = 1000L, lag.max = 7L) {
  X <- desenho_completo(matriz); W <- matriz$peso_trabalho; n <- nrow(X)
  stopifnot(length(pos) == n)
  semeia(i); E <- matrix(stats::rnorm(n * R), n, R)
  Es <- projeta_ponderada(E, X, W)
  Xw <- sqrt(W) * X
  orto <- max(abs(crossprod(Xw, Es))); escala <- max(abs(crossprod(Xw, E)))
  P <- t(vapply(seq_len(R), function(r) pacf_grade(Es[, r], pos, n_grade, lag.max), numeric(lag.max)))
  list(media = colMeans(P), q025 = apply(P, 2, stats::quantile, 0.025, type = 7), q975 = apply(P, 2, stats::quantile, 0.975, type = 7),
       orto = orto, escala = escala, R = R, semente = semente(i))
}

media_janela <- function(x, datas, de, ate) {
  stopifnot(length(x) == length(datas), inherits(datas, "Date"), de <= ate)
  if (any(diff(datas) != 1)) stop("media_janela: datas não consecutivas")
  n <- length(x); M <- vapply(de:ate, function(o) { i <- seq_len(n) + o; v <- rep(NA_real_, n); ok <- i >= 1 & i <= n; v[ok] <- x[i[ok]]; v }, numeric(n))
  rowMeans(matrix(M, nrow = n))
}

temperatura_aparente <- function(tmean, rh) {
  a <- 17.27 * tmean / (237.7 + tmean) + log(rh / 100)
  td <- 237.7 * a / (17.27 - a)
  -2.653 + 0.994 * tmean + 0.0153 * td^2
}
