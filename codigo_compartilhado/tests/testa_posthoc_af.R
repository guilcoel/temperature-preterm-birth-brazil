# testa_posthoc_af.R — testes sintéticos de posthoc_af.R (D5, item 4; entradas 78 e 79 do log do Artigo 1).
# Cada teste recebe `f` (ambiente com ajusta_dlnm.R, segunda_etapa.R e posthoc_af.R) e para com erro se uma conferência
# falhar. Só dado sintético. Quem chama põe em .P3$attrdl a attrdl carregada por carrega_attrdl. Executor: roda_testes.R.

if (!exists(".P3", inherits = FALSE)) .P3 <- new.env()
.p_perto <- function(a, b, tol, rel = FALSE) {
  a <- as.numeric(a); b <- as.numeric(b)
  if (length(a) != length(b)) stop("tamanhos diferentes: ", length(a), " × ", length(b))
  d <- if (rel) max(abs(a - b) / pmax(abs(b), 1e-300)) else max(abs(a - b))
  if (!is.finite(d) || d > tol) stop("diferença ", format(d), " > ", format(tol))
  invisible(d)
}
.p_semeia <- function(s) set.seed(s, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
.p_vcov <- function(k, escala, semente) { .p_semeia(semente); A <- matrix(stats::rnorm(k * k), k); (crossprod(A) / k + diag(k)) * escala }
# cenário sintético: 6 unidades, 450 dias (443 na janela), cross-basis ns × ns com lag 7, como a do desenho agudo
.p_cenario <- function() {
  if (!is.null(.P3$cen)) return(.P3$cen)
  n_u <- 6; n <- 450; arglag <- list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE)
  P <- c(0.01, 0.025, 0.1, 0.5, 0.9, 0.975, 0.99)
  dados <- lapply(seq_len(n_u), function(u) {
    .p_semeia(20261100 + u); t <- seq_len(n)
    x <- 20 + u + 5 * sin(2 * pi * t / 365.25) + as.numeric(stats::arima.sim(list(ar = 0.6), n = n, sd = 1.5))
    cases <- stats::rpois(n, 25 + 3 * u)
    q <- stats::quantile(x, P, type = 7, names = FALSE)
    cb <- dlnm::crossbasis(x, lag = 7, argvar = list(fun = "ns", knots = unname(stats::quantile(x, c(.1, .75, .9), type = 7))), arglag = arglag)
    list(x = x[8:n], cases = cases[8:n], basis = cb, p1 = q[1], p2_5 = q[2], p10 = q[3], p50 = q[4], p90 = q[5], p97_5 = q[6], p99 = q[7])
  })
  S <- lapply(seq_len(n_u), function(u) .p_vcov(4, 2e-3, 20261200 + u))
  .p_semeia(20261300); md <- data.frame(media = stats::rnorm(n_u, 24, 2), amplitude = stats::rnorm(n_u, 10, 1.5))
  argvars <- lapply(dados, function(d) attr(d$basis, "argvar"))
  base <- list(fun = "ns", knots = colMeans(do.call(rbind, lapply(argvars, `[[`, "knots"))),
               Boundary.knots = colMeans(do.call(rbind, lapply(argvars, `[[`, "Boundary.knots"))), intercept = FALSE)
  eixo <- c(p1 = mean(vapply(dados, `[[`, 0, "p1")), p10 = mean(vapply(dados, `[[`, 0, "p10")), p50 = mean(vapply(dados, `[[`, 0, "p50")),
            p90 = mean(vapply(dados, `[[`, 0, "p90")), p99 = mean(vapply(dados, `[[`, 0, "p99")))
  .P3$cen <- list(dados = dados, S = S, md = md, base = base, eixo = eixo); .P3$cen
}
.p_attrdl <- function() { if (is.null(.P3$attrdl)) stop("attrdl (.P3$attrdl) ausente"); .P3$attrdl }
.p_ns <- function(z, av) unclass(splines::ns(z, knots = av$knots, Boundary.knots = av$Boundary.knots, intercept = isTRUE(av$intercept)))
.p_grade <- function(a, b) { g <- seq(a, b, by = 0.1); if (b - g[length(g)] > 1e-8) g <- c(g, b); g }
# AF forward à mão (sem a attrdl): x fora do range vira a MRT; média dos eventos de t a t + 7; reescala ao total observado
.p_an_mao <- function(x, cases, av, coef, mrt, rg) {
  n <- length(x); xx <- x; if (!is.null(rg)) xx[xx < rg[1] | xx > rg[2]] <- mrt
  cbar <- vapply(seq_len(n), function(t) if (t + 7 <= n) mean(cases[t:(t + 7)]) else NA_real_, 0)
  af <- 1 - exp(-drop(sweep(.p_ns(xx, av), 2, .p_ns(mrt, av)[1, ]) %*% coef)); an <- af * cbar; ok <- !is.na(an)
  sum(an[ok]) / sum(cbar[ok]) * sum(cases)
}

testes_posthoc_af <- list(

  tp1_wald_contra_conta_a_mao = function(f) {
    b <- c(0.03, -0.01, 0.05, 0.02); V <- .p_vcov(4, 1e-3, 20261401)                       # vcov não diagonal
    w <- f$wald_curva(b, V); wm <- sum(b * (solve(V) %*% b))
    .p_perto(c(w$W, w$gl, w$p), c(wm, 4, 1 - stats::pchisq(wm, 4)), 1e-12, rel = TRUE)
    if (max(abs(V[upper.tri(V)])) < 1e-6) stop("caso do Wald sem covariâncias")
  },

  tp2_reprodutibilidade_e_sequencia_de_sorteios = function(f) {
    cz <- .p_cenario(); at <- .p_attrdl()
    a <- f$p2_nulo(3, cz$S, cz$md, cz$dados, cz$base, cz$eixo, at, guarda_sorteios = TRUE)
    b <- f$p2_nulo(3, cz$S, cz$md, cz$dados, cz$base, cz$eixo, at)
    c2 <- f$p2_nulo(2, cz$S, cz$md, cz$dados, cz$base, cz$eixo, at)
    attr(a, "sorteios") -> sa; attributes(a)$sorteios <- NULL
    if (!identical(a, b)) stop("a mesma semente não reproduziu as réplicas")
    if (!identical(c2, a[1:2, ])) stop("as 2 primeiras réplicas de um laço de 3 diferem das de um laço de 2")
    .p_semeia(20261001); mao <- lapply(1:3, function(r) t(vapply(cz$S, function(s) MASS::mvrnorm(1, rep(0, 4), s), numeric(4))))
    if (!identical(sa, mao)) stop("sorteios diferentes da sequência à mão (semente uma vez antes do laço)")
    if (identical(sa[[1]], sa[[2]])) stop("réplicas 1 e 2 com os mesmos sorteios")
    RNGkind("L'Ecuyer-CMRG"); d <- f$p2_nulo(3, cz$S, cz$md, cz$dados, cz$base, cz$eixo, at); RNGkind("Mersenne-Twister", "Inversion", "Rejection")
    if (!identical(d, a)) stop("com outro RNGkind antes, as réplicas mudaram (a semente tem de fixar o kind)")      # auditoria da Parte D, achado 5
  },

  tp3_falhas_contadas_com_stub = function(f) {
    cz <- .p_cenario(); at <- .p_attrdl()
    stub <- function(formula, S, data, method, bscov) { Y <- get("Y", envir = environment(formula)); if (Y[1, 1] > 0) stop("falha simulada")
      do.call(mixmeta::mixmeta, list(formula, S = S, data = data, method = method, bscov = bscov)) }
    tab <- f$p2_nulo(8, cz$S, cz$md, cz$dados, cz$base, cz$eixo, at, ajusta = stub, guarda_sorteios = TRUE)
    esp <- vapply(attr(tab, "sorteios"), function(th) th[1, 1] > 0, TRUE)
    if (nrow(tab) != 8 || !identical(tab$falhou, esp)) stop("falhas não contadas como esperado")
    if (!any(esp) || all(esp)) stop("caso do stub sem mistura de falhas e sucessos")
    if (!all(is.na(tab$af_total[esp])) || any(tab$metodo[esp] != "falhou") || anyNA(tab$af_total[!esp])) stop("réplica com falha substituída ou sem marca")
    rs <- f$resumo_p2(tab, af_obs = 0.01)
    if (rs$n_falhas != sum(esp) || !identical(rs$replicas_falhas, tab$replica[esp])) stop("resumo sem as falhas")
    .p_perto(rs$af_total, stats::quantile(tab$af_total[!esp], c(.5, .025, .975), type = 7, names = FALSE), 0)
    if (!(rs$p97_5_falhas_inf <= rs$af_total[["p97_5"]] && rs$af_total[["p97_5"]] <= rs$p97_5_falhas_sup)) stop("limites das falhas fora de ordem")
    st2 <- function(formula, S, data, method, bscov) { if (bscov == "unstr") stop("falha simulada só no Ψ não estruturado")         # auditoria, achado 5
      do.call(mixmeta::mixmeta, list(formula, S = S, data = data, method = method, bscov = bscov)) }
    t2 <- f$p2_nulo(2, cz$S, cz$md, cz$dados, cz$base, cz$eixo, at, ajusta = st2)
    if (any(t2$falhou) || any(t2$metodo != "reml/diag")) stop("réplica que caiu no Ψ diagonal foi contada como falha")
  },

  tp4_sorteios_nulos_com_media_zero = function(f) {
    cz <- .p_cenario(); .p_semeia(20261402); R <- 4000
    d <- t(vapply(seq_len(R), function(r) f$sorteia_nulo(cz$S)[2, ], numeric(4)))
    ep <- sqrt(diag(cz$S[[2]]) / R)
    if (any(abs(colMeans(d)) > 4 * ep)) stop("média dos sorteios longe de 0: ", paste(format(colMeans(d) / ep), collapse = " "))
    if (max(abs(stats::cov(d) - cz$S[[2]])) / max(abs(cz$S[[2]])) > 0.1) stop("covariância dos sorteios longe de S_i")
  },

  tp5_testes_do_item_2 = function(f) {
    cz <- .p_cenario(); d <- cz$dados[[3]]; av <- attr(d$basis, "argvar"); g <- f$grade_tmr(d$p1, d$p99)
    tb <- f$testa_base_mrt(d$basis, av, g); if (!tb$ok || tb$dif != 0) stop("(i) base da attrdl diferente da base da busca no caso igual")
    av2 <- av; av2$Boundary.knots <- av$Boundary.knots + c(-1, 1)
    if (f$testa_base_mrt(d$basis, av2, g)$ok) stop("(i) não detectou Boundary.knots diferentes")
    gf <- seq(d$p1, d$p99, by = 0.001); Bf <- unclass(do.call(dlnm::onebasis, c(list(x = gf), av)))
    cf <- qr.solve(Bf, 0.002 * (gf - (d$p50 + 0.037))^2 - 0.002 * (d$p1 - (d$p50 + 0.037))^2)   # mínimo interior, fora dos pontos da grade de 0,1
    mrt <- f$busca_tmr(cf, av, d$p1, d$p99, d$p10, d$p90, d$p50)$tmr
    tc <- f$testa_contribuicoes(cf, av, attr(d$basis, "argvar"), d$x, d$p1, d$p99, mrt)
    if (!tc$ok || tc$g < -1e-12) stop("(ii) o teste caiu com a MRT da grade e a mesma base")
    if (!(tc$g > 1e-10 && tc$min_delta < -1e-12)) stop("(ii) caso sem folga positiva nem Delta negativo (não separa o teste sem folga)")
    if (f$testa_contribuicoes(cf, av, av2, d$x, d$p1, d$p99, mrt)$ok) stop("(ii) não detectou a base da attrdl diferente da base da busca")
    cfd <- qr.solve(Bf, -0.01 * (gf - d$p1)); mrtd <- f$busca_tmr(cfd, av, d$p1, d$p99, d$p10, d$p90, d$p50)$tmr      # decrescente: MRT no p99 (auditoria, achado 5)
    if (!f$testa_contribuicoes(cfd, av, av, c(d$x, d$p99 + 0.5), d$p1, d$p99, mrtd)$ok) stop("(ii) contou um dia fora do p1–p99")
  },

  tp6_replica_contra_contas_a_mao = function(f) {
    cz <- .p_cenario(); at <- .p_attrdl(); .p_semeia(20261403); th <- f$sorteia_nulo(cz$S)
    z <- f$replica_nula(th, cz$S, cz$md, cz$dados, cz$base, cz$eixo, at)
    if (z$falhou) stop("réplica sintética falhou")
    mt <- strsplit(z$metodo, "/", fixed = TRUE)[[1]]
    m <- mixmeta::mixmeta(th ~ media + amplitude, S = cz$S, data = cz$md, method = mt[1], bscov = mt[2]); bl <- mixmeta::blup(m)
    an <- matrix(NA_real_, length(cz$dados), 3); den <- numeric(length(cz$dados)); sup <- inf <- logical(length(cz$dados))
    for (k in seq_along(cz$dados)) { d <- cz$dados[[k]]; av <- attr(d$basis, "argvar"); cf <- unname(bl[k, ])
      gg <- .p_grade(d$p1, d$p99); j <- which.min(drop(.p_ns(gg, av) %*% cf)); mrt <- gg[j]; sup[k] <- j == length(gg); inf[k] <- j == 1
      an[k, ] <- c(.p_an_mao(d$x, d$cases, av, cf, mrt, NULL), .p_an_mao(d$x, d$cases, av, cf, mrt, c(mrt, Inf)), .p_an_mao(d$x, d$cases, av, cf, mrt, c(-Inf, mrt)))
      den[k] <- sum(d$cases) }
    .p_perto(c(z$af_total, z$af_calor, z$af_frio), colSums(an) / sum(den), 1e-10)
    if (z$n_mrt_p99 != sum(sup) || z$n_mrt_p1 != sum(inf)) stop("contagem de MRT nas pontas diferente da conta à mão")
    B <- matrix(stats::coef(m), 3, 4, byrow = TRUE); pc <- drop(c(1, colMeans(cz$md)) %*% B)
    gc <- .p_grade(cz$eixo[["p1"]], cz$eixo[["p99"]]); mc <- gc[which.min(drop(.p_ns(gc, cz$base) %*% pc))]
    rr <- exp(drop(sweep(.p_ns(unname(cz$eixo[c("p99", "p1")]), cz$base), 2, .p_ns(mc, cz$base)[1, ]) %*% pc))
    .p_perto(c(z$tmr_combinada, z$rr_x99, z$rr_x1), c(mc, rr), 1e-10)
  },

  tp7_isolamento_do_gerador = function(f) {
    cz <- .p_cenario(); at <- .p_attrdl()
    .p_semeia(20261404); th <- f$sorteia_nulo(cz$S); st <- .Random.seed
    .p_semeia(20261404); th2 <- f$sorteia_nulo(cz$S); invisible(f$replica_nula(th2, cz$S, cz$md, cz$dados, cz$base, cz$eixo, at))
    if (!identical(.Random.seed, st)) stop("a réplica consumiu o gerador ou refez a semente")
  },

  tp8_resumo_contra_conta_a_mao = function(f) {
    .p_semeia(20261405); n <- 50
    tab <- data.frame(replica = seq_len(n), falhou = FALSE, metodo = "reml/unstr", af_total = stats::runif(n, 0, 0.03), af_calor = stats::runif(n, 0, 0.01),
                      af_frio = stats::runif(n, 0, 0.02), rr_x99 = stats::runif(n, 1, 1.1), rr_x1 = stats::runif(n, 1, 1.1), tmr_combinada = 25,
                      n_mrt_p99 = sample(0:5, n, TRUE), n_mrt_p1 = sample(0:2, n, TRUE), stringsAsFactors = FALSE)
    q975 <- stats::quantile(tab$af_total, 0.975, type = 7, names = FALSE)
    r1 <- f$resumo_p2(tab, q975 + 1e-6); r2 <- f$resumo_p2(tab, q975 - 1e-6)
    if (!isTRUE(r1$passa) || !isFALSE(r2$passa) || r1$n_falhas != 0) stop("comparação com o p97,5 errada")
    .p_perto(r1$af_total, stats::quantile(tab$af_total, c(.5, .025, .975), type = 7, names = FALSE), 0)
    .p_perto(r1$descritivas$mediana[r1$descritivas$quantidade == "rr_x99"], stats::median(tab$rr_x99), 0)
    if (r1$p97_5_falhas_inf != q975 || r1$p97_5_falhas_sup != q975) stop("sem falhas, os limites deviam coincidir com o p97,5")
    if (!isFALSE(f$resumo_p2(tab, q975)$passa)) stop("AF observada igual ao p97,5 não passa (comparação estrita)")       # auditoria, achado 5
  }
)
