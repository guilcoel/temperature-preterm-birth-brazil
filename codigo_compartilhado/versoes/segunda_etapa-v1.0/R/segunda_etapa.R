# segunda_etapa.R — segunda etapa do desenho agudo (meta-análise, BLUPs, TMR, contrastes, lag–resposta e fração
# atribuível), versão 1.0. Prompt da Fase 3 do Artigo 1 (v1.1), A1; especificação v2.0.2 §6 e §7; decisões de 13/10
# (D1 a D3) e o complemento de 13/10 (C1 a C3); desvios 68 a 75 do Artigo 1.
# Requer dlnm e mixmeta (renv do artigo). Nenhuma função grava arquivo, imprime contagem ou devolve série diária.
#
# Sementes (complemento C1; desvios 71 e 73): toda simulação da concentração i (1 a 26, na ordem travada abaixo) usa
#   set.seed(20261001 + i, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
# imediatamente antes; a curva combinada usa i = 0 (20261001). O kind explícito torna a execução serial igual à paralela.
#
# Funções:
#   ORDEM_CONCENTRACOES; confere_ordem(codigos); indice_concentracao(codigo), que recusa código fora da ordem;
#     semente(i), que recusa i fora de 0 a 26 ou não inteiro; semeia(i)
#   base_combinada(lista_argvar): argvar média (nós e Boundary.knots = médias; mesma fun, intercept e degree).
#   meta_curva(coef, vcov, metapred, formula, ajusta): mixmeta REML com Ψ não estruturado; se falhar (erro ou
#     isFALSE(converged)), Ψ diagonal; depois ML com Ψ diagonal. Devolve o método usado, coeficientes e vcov,
#     predição na média dos metapreditores, BLUPs com vcov, Q e I² (residual e total), Wald de cada termo e Ψ.
#     Antes de ajustar, exige max(abs(coef da unidade)) > 1e-10 em cada unidade e recusa fórmula sem metapreditores
#     (o modelo só com intercepto é ajustado à parte, para o Q e o I² totais). Os coeficientes saem como y1…yk, sem
#     os nomes das colunas de coef.
#   curva(coef, vcov, argvar, x, cen): log RR, EP e RR com IC 95% em x contra cen, com a base sempre por
#     do.call(onebasis, c(list(x = x), argvar)) (Boundary.knots explícitos).
#   grade_tmr(x_inf, x_sup); busca_tmr(coef, argvar, x_inf, x_sup, p10, p90, p50); boot_tmr(...): TMR na grade
#     de 0,1 °C (com x_sup), fronteira pelo índice do mínimo, bootstrap paramétrico por Cholesky.
#   posicao_no_eixo(valor, eixo_valores, eixo_probs); centro_lagresposta(tmean_ref, q, fronteira): centro da
#     lag–resposta (D4(b)); na fronteira, o p50 da concentração.
#   reduz_var(cb, coef16, vcov16, valor, cen): crossreduce(type = "var", model.link = "log").
#   curva_lag(coef, vcov, arglag, lags); soma_lags(coef, vcov, arglag, lags = 0:7).
#   monta_cb(x, datas, argvar, arglag, lag): cross-basis na série completa e consecutiva (complemento C2).
#   carrega_attrdl(caminho, sha256): carrega a attrdl conferida por SHA-256, com o dlnm como ambiente pai.
#   fracao_atribuivel(analise, x, cases, datas, basis, coef, vcov, tmr, p2_5, p97_5, i, attrdl, nsim, n_aquec): AN e AF
#     dos cinco componentes, com eCI, nas três análises da D1 (principal e ponte forward, com os coeficientes reduzidos;
#     backward, com todos os coeficientes da cross-basis). Devolve status de erro, sem chamar a attrdl, se os tamanhos
#     ou as datas não baterem, se o forward tiver NA nos cases, se o backward não tiver NA nos n_aquec dias de
#     aquecimento, se o número de coeficientes não for o da análise ou se n_aquec diferir do lag máximo da cross-basis.

ORDEM_CONCENTRACOES <- c("3550308", "3304557", "3106200", "5300108", "2611606", "4314902", "2304400", "4106902",
                         "2927408", "5208707", "3509502", "1302603", "1501402", "3205309", "3548500", "3549904",
                         "2111300", "2408102", "2704302", "4205407", "2507507", "2211001", "2800308", "5103403",
                         "3552205", "5002704")   # ordem de cidade_nucleo() em 13/10/2026 (desvio 73); nunca sort()

confere_ordem <- function(codigos) {
  if (!identical(as.character(codigos), ORDEM_CONCENTRACOES)) stop("ordem das concentrações diferente da gravada (desvio 73)")
  invisible(TRUE)
}
indice_concentracao <- function(codigo) {
  i <- match(as.character(codigo), ORDEM_CONCENTRACOES)
  if (anyNA(i)) stop("concentração fora da ordem gravada: ", paste(codigo[is.na(i)], collapse = ", "))
  i
}
semente <- function(i) {
  if (length(i) != 1 || !is.numeric(i) || is.na(i) || i != round(i) || i < 0 || i > length(ORDEM_CONCENTRACOES))
    stop("semente: i tem de ser um inteiro de 0 (curva combinada) a ", length(ORDEM_CONCENTRACOES), " (posição na ordem gravada)")
  20261001L + as.integer(i)
}
semeia <- function(i) set.seed(semente(i), kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")

# ------------------------------------------------------------------ base de predição combinada (D2)
base_combinada <- function(lista_argvar) {
  stopifnot(is.list(lista_argvar), length(lista_argvar) >= 1)
  campo <- function(nome) lapply(lista_argvar, `[[`, nome)
  fun <- unique(vapply(campo("fun"), as.character, ""))
  if (length(fun) != 1) stop("base_combinada: argvar com fun diferentes")
  nk <- unique(vapply(campo("knots"), length, 0L))
  if (length(nk) != 1) stop("base_combinada: argvar com número de nós diferente")
  ic <- unique(vapply(campo("intercept"), isTRUE, TRUE))
  if (length(ic) != 1) stop("base_combinada: argvar com intercept diferente")
  if (fun == "bs") { dg <- unique(vapply(campo("degree"), function(d) if (is.null(d)) 3 else d, 0)); if (length(dg) != 1) stop("base_combinada: argvar com degree diferente") }
  bk <- campo("Boundary.knots"); if (any(vapply(bk, length, 0L) != 2)) stop("base_combinada: argvar sem Boundary.knots")
  out <- lista_argvar[[1]]
  out$knots <- colMeans(do.call(rbind, campo("knots")))
  out$Boundary.knots <- colMeans(do.call(rbind, bk))
  out
}

# ------------------------------------------------------------------ meta-análise (§6; A1.2)
.base_x <- function(x, argvar) unclass(do.call(dlnm::onebasis, c(list(x = x), argvar)))
meta_curva <- function(coef, vcov, metapred, formula = ~ media + amplitude, ajusta = mixmeta::mixmeta) {
  coef <- as.matrix(coef); stopifnot(is.list(vcov), length(vcov) == nrow(coef), nrow(metapred) == nrow(coef))
  nulas <- which(apply(abs(coef), 1, max) <= 1e-10)
  if (length(nulas)) stop("meta_curva: coeficientes identicamente nulos na(s) unidade(s) ", paste(nulas, collapse = ", "))
  Y <- coef; dimnames(Y) <- NULL; md <- as.data.frame(metapred)             # sem nomes: os coeficientes saem como y1…yk
  termos <- attr(stats::terms(formula), "term.labels")
  if (!length(termos)) stop("meta_curva: a fórmula precisa de metapreditores (o modelo só com intercepto é ajustado à parte, como total)")
  fml <- stats::as.formula(paste("Y ~", paste(termos, collapse = " + "))); environment(fml) <- environment()
  roda <- function(method, bscov, f = fml) {
    av <- character(0)
    fit <- withCallingHandlers(tryCatch(ajusta(f, S = vcov, data = md, method = method, bscov = bscov), error = function(e) e),
                               warning = function(w) { av <<- c(av, conditionMessage(w)); invokeRestart("muffleWarning") })
    list(fit = fit, avisos = av, falhou = inherits(fit, "error") || isFALSE(fit$converged))
  }
  seq_est <- list(c("reml", "unstr"), c("reml", "diag"), c("ml", "diag"))
  tentativas <- character(0); usado <- NULL
  for (s in seq_est) {
    r <- roda(s[1], s[2])
    tentativas <- c(tentativas, sprintf("%s/%s: %s", s[1], s[2], if (inherits(r$fit, "error")) paste("erro:", conditionMessage(r$fit)) else if (r$falhou) "não convergiu" else "ok"))
    if (!r$falhou) { usado <- c(s, r); break }
  }
  out <- list(status = "falhou", tentativas = tentativas, metodo = NA_character_, bscov = NA_character_)
  if (is.null(usado)) return(out)
  fit <- usado$fit
  nd <- as.data.frame(t(colMeans(md[, termos, drop = FALSE])))
  pred <- stats::predict(fit, newdata = nd, vcov = TRUE)
  b <- mixmeta::blup(fit, vcov = TRUE)
  qi2 <- function(f) { q <- mixmeta::qtest(f); Q <- unname(q$Q[1]); df <- unname(q$df[1]); list(Q = Q, df = df, p = unname(q$pvalue[1]), I2 = max(0, (Q - df) / Q) * 100) }
  fit0 <- roda(usado[[1]], usado[[2]], stats::as.formula("Y ~ 1", env = environment()))
  wald <- do.call(rbind, lapply(termos, function(t) {
    ind <- which(sub("^[^.]*\\.", "", names(stats::coef(fit))) == t)
    cf <- stats::coef(fit)[ind]; V <- stats::vcov(fit)[ind, ind, drop = FALSE]
    w <- drop(t(cf) %*% solve(V) %*% cf)
    data.frame(termo = t, estatistica = w, gl = length(ind), p = stats::pchisq(w, length(ind), lower.tail = FALSE), stringsAsFactors = FALSE)
  }))
  out$status <- "ok"; out$metodo <- usado[[1]]; out$bscov <- usado[[2]]; out$avisos <- usado$avisos
  out$convergiu <- if (is.null(fit$converged)) NA else fit$converged
  out$coef_meta <- stats::coef(fit); out$vcov_meta <- stats::vcov(fit)
  out$pred_media <- list(coef = unname(pred$fit), vcov = unname(pred$vcov), metapred = nd)
  out$blup <- lapply(b, function(z) list(coef = unname(z$blup), vcov = unname(z$vcov)))
  out$heterogeneidade <- list(residual = qi2(fit), total = if (fit0$falhou) NULL else qi2(fit0$fit))
  out$wald <- wald; out$Psi <- fit$Psi
  out$Psi_autovalor_min <- min(eigen(fit$Psi, symmetric = TRUE, only.values = TRUE)$values)
  out
}

# ------------------------------------------------------------------ curvas (§6, §7)
curva <- function(coef, vcov, argvar, x, cen) {
  B <- .base_x(x, argvar); Bc <- .base_x(cen, argvar)
  X <- sweep(B, 2, Bc[1, ]); lr <- drop(X %*% coef); ep <- sqrt(pmax(0, rowSums((X %*% vcov) * X))); z <- stats::qnorm(0.975)
  data.frame(x = x, logrr = lr, ep = ep, rr = exp(lr), rr_li = exp(lr - z * ep), rr_ls = exp(lr + z * ep))
}

# ------------------------------------------------------------------ TMR (§7; D4(a), (i); complemento C3)
grade_tmr <- function(x_inf, x_sup) {
  stopifnot(is.finite(x_inf), is.finite(x_sup), x_sup > x_inf)
  g <- seq(x_inf, x_sup, by = 0.1)
  if (x_sup - g[length(g)] > 1e-8) g <- c(g, x_sup)
  g
}
.minimo_grade <- function(coef, argvar, g) { i <- which.min(drop(.base_x(g, argvar) %*% coef)); list(tmr = g[i], indice = i, fronteira = i %in% c(1L, length(g))) }
busca_tmr <- function(coef, argvar, x_inf, x_sup, p10, p90, p50) {
  g <- grade_tmr(x_inf, x_sup); m <- .minimo_grade(coef, argvar, g)
  out <- list(tmr = m$tmr, indice = m$indice, n_grade = length(g), fronteira = m$fronteira, tmr_p10_p90 = NA_real_, p50 = p50)
  if (m$fronteira) out$tmr_p10_p90 <- .minimo_grade(coef, argvar, grade_tmr(p10, p90))$tmr
  out
}
boot_tmr <- function(coef, vcov, argvar, x_inf, x_sup, i, nsim = 1000) {
  k <- length(coef); g <- grade_tmr(x_inf, x_sup)
  R <- tryCatch(chol(vcov), error = function(e) e)
  if (inherits(R, "error")) return(list(tmr_sim = NULL, ic = c(NA_real_, NA_real_), motivo = paste("vcov não positiva-definida:", conditionMessage(R))))
  semeia(i)
  sims <- coef + t(R) %*% matrix(stats::rnorm(k * nsim), k)
  eta <- .base_x(g, argvar) %*% sims
  tmr <- g[apply(eta, 2, which.min)]
  list(tmr_sim = tmr, ic = unname(stats::quantile(tmr, c(0.025, 0.975), type = 7)), motivo = NA_character_)
}

# ------------------------------------------------------------------ lag–resposta (D4(b); complemento C3)
posicao_no_eixo <- function(valor, eixo_valores, eixo_probs) {
  stopifnot(length(eixo_valores) == length(eixo_probs), !is.unsorted(eixo_valores, strictly = TRUE))
  stats::approx(eixo_valores, eixo_probs, xout = valor, rule = 1)$y
}
centro_lagresposta <- function(tmean_ref, q, fronteira) {
  if (isTRUE(fronteira)) return(unname(stats::quantile(tmean_ref, 0.5, type = 7)))
  stopifnot(is.finite(q), q >= 0, q <= 1)
  unname(stats::quantile(tmean_ref, q, type = 7))
}
reduz_var <- function(cb, coef16, vcov16, valor, cen) {
  r <- dlnm::crossreduce(cb, coef = coef16, vcov = vcov16, model.link = "log", type = "var", value = valor, cen = cen)
  list(coef = unname(stats::coef(r)), vcov = unname(stats::vcov(r)))
}
curva_lag <- function(coef, vcov, arglag, lags = seq(0, 7, by = 0.1)) {
  B <- .base_x(lags, arglag); lr <- drop(B %*% coef); ep <- sqrt(pmax(0, rowSums((B %*% vcov) * B))); z <- stats::qnorm(0.975)
  data.frame(lag = lags, logrr = lr, ep = ep, rr = exp(lr), rr_li = exp(lr - z * ep), rr_ls = exp(lr + z * ep))
}
soma_lags <- function(coef, vcov, arglag, lags = 0:7) {
  s <- colSums(.base_x(lags, arglag)); lr <- sum(s * coef); ep <- sqrt(drop(t(s) %*% vcov %*% s)); z <- stats::qnorm(0.975)
  c(logrr = lr, ep = ep, rr = exp(lr), rr_li = exp(lr - z * ep), rr_ls = exp(lr + z * ep))
}

# ------------------------------------------------------------------ cross-basis na série consecutiva (complemento C2)
monta_cb <- function(x, datas, argvar, arglag, lag = 7) {
  stopifnot(length(x) == length(datas), inherits(datas, "Date"))
  if (any(diff(datas) != 1)) stop("monta_cb: datas não consecutivas (a cross-basis exige a série completa)")
  dlnm::crossbasis(x, lag = lag, argvar = argvar, arglag = arglag)
}

# ------------------------------------------------------------------ fração atribuível (D1; D4(d), (f), (g), (h))
carrega_attrdl <- function(caminho, sha256) {
  h <- sub(" .*", "", system2("shasum", c("-a", "256", shQuote(caminho)), stdout = TRUE))
  if (!identical(h, sha256)) stop("attrdl.R com SHA-256 diferente do conferido: ", h)
  e <- new.env(parent = asNamespace("dlnm")); sys.source(caminho, envir = e)   # onebasis sem prefixo (l. 124) resolve no dlnm
  e$attrdl
}
componentes_attrdl <- function(tmr, p2_5, p97_5) list(total = NULL, calor = c(tmr, Inf), frio = c(-Inf, tmr),
                                                      calor_extremo = c(max(p97_5, tmr), Inf), frio_extremo = c(-Inf, min(p2_5, tmr)))
fracao_atribuivel <- function(analise = c("principal", "ponte", "backward"), x, cases, datas, basis, coef, vcov, tmr,
                              p2_5, p97_5, i, attrdl, nsim = 1000, n_aquec = 7L) {
  analise <- match.arg(analise); dir <- if (analise == "backward") "back" else "forw"
  out <- list(status = "falhou", analise = analise, dir = dir, mensagem = NA_character_)
  if (length(x) != length(cases) || length(x) != length(datas)) { out$mensagem <- "x, cases e datas com tamanhos diferentes"; return(out) }
  if (any(diff(datas) != 1)) { out$mensagem <- "datas não consecutivas (a attrdl defasa por posição)"; return(out) }
  if (dir == "back" && !all(is.na(cases[seq_len(n_aquec)]))) { out$mensagem <- "backward: cases dos dias de aquecimento têm de ser NA"; return(out) }
  if (dir == "forw" && anyNA(cases)) { out$mensagem <- "forward: cases com NA na janela"; return(out) }
  if (dir == "back" && length(coef) != ncol(basis)) { out$mensagem <- "backward exige todos os coeficientes da cross-basis da primeira etapa"; return(out) }
  if (dir == "forw" && length(coef) >= ncol(basis)) { out$mensagem <- "forward (principal e ponte) exige os coeficientes reduzidos"; return(out) }
  if (!identical(as.numeric(n_aquec), as.numeric(attr(basis, "lag")[2]))) { out$mensagem <- "n_aquec diferente do lag máximo da cross-basis"; return(out) }
  den <- sum(cases, na.rm = TRUE)
  comp <- componentes_attrdl(tmr, p2_5, p97_5)
  res <- tryCatch({
    lst <- lapply(names(comp), function(nm) {
      rg <- comp[[nm]]
      semeia(i); an <- attrdl(x, basis, cases, coef = coef, vcov = vcov, type = "an", dir = dir, tot = TRUE, cen = tmr, range = rg, sim = FALSE)
      semeia(i); sim <- attrdl(x, basis, cases, coef = coef, vcov = vcov, type = "an", dir = dir, tot = TRUE, cen = tmr, range = rg, sim = TRUE, nsim = nsim)
      list(an = an, sim = sim)
    })
    names(lst) <- names(comp); lst
  }, error = function(e) e)
  if (inherits(res, "error")) { out$mensagem <- paste("erro na attrdl:", conditionMessage(res)); return(out) }
  sims <- sapply(res, `[[`, "sim")
  ic <- function(v) unname(stats::quantile(v, c(0.025, 0.975), type = 7))
  tab <- do.call(rbind, lapply(names(res), function(nm) {
    a <- res[[nm]]$an; c95 <- ic(res[[nm]]$sim)
    data.frame(componente = nm, an = a, an_li = c95[1], an_ls = c95[2], af = a / den, af_li = c95[1] / den, af_ls = c95[2] / den, stringsAsFactors = FALSE)
  }))
  out$status <- "ok"; out$mensagem <- "ok"; out$componentes <- tab; out$denominador <- den; out$sims <- sims
  out$range <- comp; out$semente <- semente(i)
  out
}
