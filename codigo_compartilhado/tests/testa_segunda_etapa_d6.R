# testa_segunda_etapa_d6.R — testes da segunda_etapa v1.0.1, só de testes (D6, item 2 e 3.4; entrada 86 do log do A1).
# Cada teste recebe `f` (ambiente com segunda_etapa.R) e para com erro se uma conferência falhar. Só dado sintético.
# Quem chama faz source de teste3_fonte_independente.R antes (a função fica no ambiente global). Executor: roda_testes.R.
#   - td6_t3_ns e td6_t3_bs: teste 3 da D2 (errata da D6, 2.2), com a estrutura de datas do A1 (serie_nos de 2012-01-01 a
#     2024-12-31, 4.749 dias; x_cb da janela de 2012-04-07 a 2024-08-06, 4.505 dias; os dois extremos da serie_nos nos
#     244 dias fora da janela, para range(x_cb) ≠ range(serie_nos)); variante S1 com bs de grau 2.
#   - td6_wald_selecao_exata: com media e xmedia no modelo, os dois Wald da meta_curva têm gl = 4 e batem com a forma
#     quadrática à mão (o grep de substring da fwald pegaria 8).
#   - td6_q_por_coeficiente: receita do chamador (D6, 3.2; conformidade, achado 2): qtest() de um mixmeta reajustado com
#     Y sem nomes de coluna e o mesmo método e Ψ da meta_curva; coef identical() ao coef_meta; Q[-1] igual ao cálculo à
#     mão (diagonal de cada S_i e coeficientes do GLS multivariado de efeitos fixos com a mesma X); gl = 23 (n = 26, 3 termos).

.d6_perto <- function(a, b, tol, rel = FALSE) {
  a <- as.numeric(a); b <- as.numeric(b)
  if (length(a) != length(b)) stop("tamanhos diferentes: ", length(a), " × ", length(b))
  d <- if (rel) max(abs(a - b) / pmax(abs(b), 1e-300)) else max(abs(a - b))
  if (!is.finite(d) || d > tol) stop("diferença ", format(d), " > ", format(tol))
  invisible(d)
}
.d6_semeia <- function(s) set.seed(s, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
# série sintética com a estrutura de datas do A1; os dois extremos ficam fora da janela
.d6_series <- function() {
  datas <- seq(as.Date("2012-01-01"), as.Date("2024-12-31"), by = "day"); stopifnot(length(datas) == 4749L)
  .d6_semeia(20261015); t <- seq_along(datas)
  s <- 24 + 4 * sin(2 * pi * t / 365.25) + as.numeric(stats::arima.sim(list(ar = 0.7), n = length(t), sd = 1))
  jan <- datas >= as.Date("2012-04-07") & datas <= as.Date("2024-08-06"); stopifnot(sum(jan) == 4505L, sum(!jan) == 244L)
  s[which(datas == as.Date("2012-01-20"))] <- max(s[jan]) + 1.5; s[which(datas == as.Date("2024-12-10"))] <- min(s[jan]) - 1.5
  stopifnot(which.max(s) %in% which(!jan), which.min(s) %in% which(!jan))
  list(serie_nos = s, x_cb = s[jan])
}
.d6_t3 <- function(f, fun, degree = NULL) {
  ss <- .d6_series(); nos <- unname(stats::quantile(ss$serie_nos, c(0.10, 0.75, 0.90), type = 7))
  av_in <- if (fun == "ns") list(fun = "ns", knots = nos) else list(fun = "bs", knots = nos, degree = degree)
  cb <- dlnm::crossbasis(ss$x_cb, lag = 7, argvar = av_in, arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE))
  av <- attr(cb, "argvar"); k <- if (fun == "ns") length(nos) + 1L else length(nos) + degree   # colunas da base sem intercepto
  pc <- unname(stats::quantile(ss$serie_nos, c(0.01, 0.99), type = 7)); x <- f$grade_tmr(pc[1], pc[2])
  coef <- c(0.02, -0.015, 0.03, 0.05, -0.01)[seq_len(k)]; cen <- x[which.min(abs(x - stats::median(ss$serie_nos)))]
  r <- teste3_fonte_independente(f$curva, coef, av, x, cen, ss$serie_nos, c(0.10, 0.75, 0.90), ss$x_cb, fun = fun, degree = degree)
  if (!identical(unname(av$Boundary.knots), range(ss$x_cb))) stop("a argvar do crossbasis não guardou Boundary.knots = range(x_cb)")
  if (!(r$dif <= 1e-8)) stop("teste 3: fonte independente difere da curva(): ", format(r$dif))
  if (!(r$dif_controle_p1p99 > 1e-8)) stop("controle p1–p99 sem poder: ", format(r$dif_controle_p1p99))
  if (!(r$dif_controle_serie > 1e-8)) stop("controle range(serie_nos) sem poder: ", format(r$dif_controle_serie))
  if (!(r$dif_nos <= 1e-12 && r$dif_fronteiras == 0)) stop("nós ou fronteiras da argvar diferentes dos recalculados")
  invisible(r)
}
.d6_meta_sint <- function() {
  .d6_semeia(20261016); n <- 26L; k <- 4L
  md <- data.frame(media = stats::rnorm(n, 24, 2), amplitude = stats::rnorm(n, 12, 2)); md$xmedia <- md$media + stats::rnorm(n, 0, 1)
  S <- lapply(seq_len(n), function(i) { A <- matrix(stats::rnorm(k * k), k); (crossprod(A) / k + diag(k)) * 2e-3 })
  beta <- rbind(c(0.1, -0.05, 0.08, 0.02), c(0.01, 0.005, -0.004, 0.003), c(-0.003, 0.002, 0.001, 0.004))
  Y <- t(vapply(seq_len(n), function(i) drop(c(1, md$media[i] - 24, md$amplitude[i] - 12) %*% beta) + MASS::mvrnorm(1, rep(0, k), S[[i]] + diag(k) * 1e-3), numeric(k)))
  list(Y = Y, S = S, md = md)
}

testes_segunda_etapa_d6 <- list(

  td6_t3_ns = function(f) .d6_t3(f, "ns"),                                # teste 3 da D2 (errata da D6, 2.2)

  td6_t3_bs = function(f) .d6_t3(f, "bs", degree = 2),                    # variante S1: bs de grau 2, nos dois lados

  td6_wald_selecao_exata = function(f) {                                 # D6, 3.2: um Wald por metapreditor, 4 gl, seleção exata
    m <- .d6_meta_sint(); r <- f$meta_curva(m$Y, m$S, m$md, formula = ~ media + xmedia)
    if (!identical(r$status, "ok")) stop("meta_curva falhou: ", paste(r$tentativas, collapse = "; "))
    stopifnot(identical(r$wald$termo, c("media", "xmedia")), all(r$wald$gl == 4L))
    nm <- names(r$coef_meta)
    for (t in c("media", "xmedia")) {
      ind <- which(sub("^[^.]*\\.", "", nm) == t); stopifnot(length(ind) == 4L)
      w <- drop(t(r$coef_meta[ind]) %*% solve(r$vcov_meta[ind, ind]) %*% r$coef_meta[ind])
      .d6_perto(r$wald$estatistica[r$wald$termo == t], w, 1e-10, rel = TRUE)
      .d6_perto(r$wald$p[r$wald$termo == t], stats::pchisq(w, 4, lower.tail = FALSE), 1e-12)
    }
  },

  td6_q_por_coeficiente = function(f) {                                  # D6, 3.2 e conformidade, achado 2: receita do chamador
    m <- .d6_meta_sint(); r <- f$meta_curva(m$Y, m$S, m$md[, c("media", "amplitude")])
    if (!identical(r$status, "ok")) stop("meta_curva falhou")
    Yd <- unname(m$Y); md <- m$md[, c("media", "amplitude")]
    fit <- mixmeta::mixmeta(Yd ~ media + amplitude, S = m$S, data = md, method = r$metodo, bscov = r$bscov)
    if (!identical(stats::coef(fit), r$coef_meta)) stop("coef do reajuste não é identical() ao coef_meta")
    q <- mixmeta::qtest(fit); stopifnot(length(q$Q) == 5L, all(q$df[-1] == 23L))
    # à mão: GLS multivariado de efeitos fixos com a mesma X; Q_j = Σ_i (y_ij − x_i'β̂_j)² / S_i[j, j]
    X <- cbind(1, md$media, md$amplitude); n <- nrow(X); k <- ncol(Yd); p <- ncol(X)
    A <- matrix(0, p * k, p * k); bb <- numeric(p * k)
    for (i in seq_len(n)) { Xi <- X[i, , drop = FALSE] %x% diag(k); Si <- solve(m$S[[i]]); A <- A + t(Xi) %*% Si %*% Xi; bb <- bb + t(Xi) %*% Si %*% Yd[i, ] }
    beta <- matrix(solve(A, bb), ncol = k, byrow = TRUE)
    Qm <- vapply(seq_len(k), function(j) sum((Yd[, j] - X %*% beta[, j])^2 / vapply(m$S, function(s) s[j, j], 0)), 0)
    .d6_perto(unname(q$Q[-1]), Qm, 1e-8, rel = TRUE)
    I2 <- pmax(0, (q$Q[-1] - q$df[-1]) / q$Q[-1]) * 100; stopifnot(all(I2 >= 0 & I2 <= 100))
    .d6_perto(unname(q$pvalue[-1]), stats::pchisq(Qm, 23, lower.tail = FALSE), 1e-8)
  }
)
