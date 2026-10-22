# gera_sintetico.R — gerador comum dos testes da ajusta_dlnm() (Fase 2 do Artigo 1; desvios 55 e 57). Só dado
# sintético; nada da base. Usa o RNG corrente (a semente é posta por quem chama).
#
# gera_temp(n, t0): temperatura diária 22 + 5·sin(2π(t − 15)/365,25) + ruído AR(1) estacionário (ρ = 0,7; DP 1,5 °C).
# base_fixa(n_ref): série de referência longa para fixar a base dos testes de Monte Carlo (nós p10/p75/p90, cen = p50,
#   p99, p75 e Boundary.knots = range da referência), para que θ e o verdadeiro sejam os mesmos em todas as réplicas.
# projeta_theta(bf): θ (16) por mínimos quadrados na grade temperatura × lag que melhor aproxima a superfície
#   "0,03/°C acima do p75, distribuída igualmente nos lags 0 a 2"; devolve θ, R² e o log RR verdadeiro no p99 contra o cen.
# gera_sintetico(...): uma unidade (n_dias de janela + aquec dias de aquecimento) com Z_t sazonal, log_w com DP
#   intra-estrato ~0,02 (DP marginal do AR(1) = 0,0275), calendário (dia da semana, feriados fixos, carnaval e móveis fixos), estratos ano × mês,
#   efeito de temperatura "nenhum", "theta" (cb %*% θ) ou "dobradica" (0,01·(x − p75)+ nos lags 0, 1 e 2), e
#   y ~ Poisson(μ) com média ≈ eventos_dia na janela (ou y = μ, com esperado = TRUE; ou binomial negativa com
#   tamanho_nb finito, para dado sobredisperso no teste 1; desvio 62).

PARAM_GERADOR <- list(t_media = 22, t_amp = 5, t_fase = 15, rho_t = 0.7, dp_t = 1.5, periodo = 365.25,
                      logw_nivel = log(0.01), logw_amp = 0.01, logw_fase = 60, rho_logw = 0.9,
                      dow = c(seg = 0, ter = 0.02, qua = 0.02, qui = 0.02, sex = 0.01, sab = -0.15, dom = -0.25),
                      b_feriado = -0.20, b_carnaval = -0.15, b_moveis = -0.10, dp_estrato = 0.05,
                      feriados = c("01-01", "04-21", "05-01", "09-07", "10-12", "11-02", "11-15", "12-25"),
                      carnaval = c("02-12", "02-13"), moveis = c("02-14", "04-03", "06-04"))

.ar1 <- function(n, rho, dp) {                                       # AR(1) estacionário com DP marginal dp
  e <- numeric(n); e[1] <- stats::rnorm(1, 0, dp)
  z <- stats::rnorm(n, 0, dp * sqrt(1 - rho^2))
  for (i in seq_len(n)[-1]) e[i] <- rho * e[i - 1] + z[i]
  e
}

gera_temp <- function(n, t0 = 0, p = PARAM_GERADOR) {
  t <- t0 + seq_len(n)
  p$t_media + p$t_amp * sin(2 * pi * (t - p$t_fase) / p$periodo) + .ar1(n, p$rho_t, p$dp_t)
}

base_fixa <- function(n_ref = 100000, p = PARAM_GERADOR) {
  x <- gera_temp(n_ref, 0, p)
  q <- stats::quantile(x, c(.10, .50, .75, .90, .99), type = 7, names = FALSE)
  list(knots = q[c(1, 3, 4)], cen = q[2], p75 = q[3], p99 = q[5], bk = range(x), lag = 7L,
       argvar = list(fun = "ns", knots = q[c(1, 3, 4)], Boundary.knots = range(x)),
       arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE))
}

projeta_theta <- function(bf, n_grade = 301) {
  xg <- seq(bf$bk[1], bf$bk[2], length.out = n_grade); lags <- 0:bf$lag
  bx <- do.call(dlnm::onebasis, c(list(x = xg), bf$argvar))         # 4 colunas (ns, sem intercepto)
  bl <- do.call(dlnm::onebasis, c(list(x = lags), bf$arglag))       # 4 colunas (ns com intercepto em 0..7)
  alvo <- outer(xg, lags, function(x, l) ifelse(l <= 2, 0.01 * pmax(x - bf$p75, 0), 0))   # 0,03/°C repartido em 3 lags
  # coluna (i, k) da cross-basis do dlnm = bx[, i] * bl[, k], na ordem v1.l1, v1.l2, ..., v2.l1, ...
  X <- do.call(rbind, lapply(seq_along(lags), function(j) t(apply(unclass(bx), 1, function(b) as.vector(t(outer(b, unclass(bl)[j, ])))))))
  y <- as.vector(alvo)                                               # empilhado por lag (coluna de alvo), como X
  theta <- stats::lm.fit(X, y)$coefficients
  r2 <- 1 - sum((y - X %*% theta)^2) / sum((y - mean(y))^2)
  bvec <- do.call(dlnm::onebasis, c(list(x = c(bf$p99, bf$cen)), bf$argvar)); dif <- unclass(bvec)[1, ] - unclass(bvec)[2, ]
  M <- matrix(theta, nrow = ncol(bx), byrow = TRUE)                  # linhas: base da variável; colunas: base do lag
  verdadeiro_theta <- sum(dif * (M %*% colSums(unclass(bl))))        # log RR cumulativo no p99 contra o cen
  list(theta = theta, r2 = r2, verdadeiro_theta = verdadeiro_theta, verdadeiro_dobradica = 0.03 * (bf$p99 - bf$p75))
}

gera_sintetico <- function(n_dias = 4500, aquec = 7, eventos_dia = 30, gamma = 1.3, efeito = c("nenhum", "theta", "dobradica"),
                           bf = NULL, theta = NULL, a_Z = 0.1, fase_Z = 100, dp_logw = 0.0275, inicio = as.Date("2012-04-07"),
                           unidade = "u1", esperado = FALSE, tamanho_nb = Inf, p = PARAM_GERADOR) {
  efeito <- match.arg(efeito)
  n <- n_dias + aquec; data <- inicio + 0:(n - 1)
  t <- as.numeric(data - as.Date("2012-01-01"))
  temp <- p$t_media + p$t_amp * sin(2 * pi * (t - p$t_fase) / p$periodo) + .ar1(n, p$rho_t, p$dp_t)
  log_z <- log(1 + a_Z * sin(2 * pi * (t - fase_Z) / p$periodo))
  log_w <- p$logw_nivel + p$logw_amp * sin(2 * pi * (t - p$logw_fase) / p$periodo) + .ar1(n, p$rho_logw, dp_logw)
  ds <- factor(c("seg", "ter", "qua", "qui", "sex", "sab", "dom")[as.integer(format(data, "%u"))],
               levels = c("seg", "ter", "qua", "qui", "sex", "sab", "dom"))
  md <- format(data, "%m-%d")
  fer <- as.integer(md %in% p$feriados); car <- as.integer(md %in% p$carnaval); mov <- as.integer(md %in% p$moveis)
  estrato <- paste(unidade, format(data, "%Y"), format(data, "%m"), sep = "_")
  a_est <- stats::rnorm(length(unique(estrato)), 0, p$dp_estrato)[match(estrato, unique(estrato))]
  f <- numeric(n)
  if (efeito == "theta") {
    cb <- dlnm::crossbasis(temp, lag = bf$lag, argvar = bf$argvar, arglag = bf$arglag)
    f <- as.vector(unclass(cb) %*% theta); f[is.na(f)] <- 0
  } else if (efeito == "dobradica") {
    h <- 0.01 * pmax(temp - bf$p75, 0)
    f <- h + c(0, h[-n]) + c(0, 0, h[-c(n - 1, n)])                  # lags 0, 1 e 2
  }
  janela <- seq_len(n) > aquec
  eta0 <- a_est + log_z + gamma * log_w + f + p$dow[as.character(ds)] + p$b_feriado * fer + p$b_carnaval * car + p$b_moveis * mov
  c0 <- log(eventos_dia / mean(exp(eta0[janela])))
  mu <- exp(c0 + eta0)
  y <- if (esperado) mu else if (is.finite(tamanho_nb)) stats::rnbinom(n, size = tamanho_nb, mu = mu) else stats::rpois(n, mu)
  data.frame(data = data, y = y, temp = temp, log_z = log_z, log_w = log_w, log_zw = log_z + log_w, dia_semana = ds,
             feriado_nacional = fer, carnaval = car, moveis = mov, estrato = estrato, janela = janela, unidade = unidade,
             stringsAsFactors = FALSE)
}
