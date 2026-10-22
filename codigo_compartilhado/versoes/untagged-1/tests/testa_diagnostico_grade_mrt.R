# testa_diagnostico_grade_mrt.R — testes sintéticos de diagnostico_grade_mrt.R (errata da D5 de 14/10/2026, item 2;
# entrada 80 do log do Artigo 1). Cada teste recebe `f` (ambiente com segunda_etapa.R da tag segunda_etapa-v1.0 e
# diagnostico_grade_mrt.R) e para com erro se uma conferência falhar. A grade é sempre a f$grade_tmr, salvo no caso (b),
# que usa de propósito uma grade sem o p99. Só dado sintético. Referências independentes da função testada:
# splines::ns direto (não a onebasis) e f″ pelo polinômio cúbico exato de cada trecho sem nó. Executor: roda_testes.R.

.d_perto <- function(a, b, tol, rel = FALSE) {
  a <- as.numeric(a); b <- as.numeric(b)
  if (length(a) != length(b)) stop("tamanhos diferentes: ", length(a), " × ", length(b))
  d <- if (rel) max(abs(a - b) / pmax(abs(b), 1e-300)) else max(abs(a - b))
  if (!is.finite(d) || d > tol) stop("diferença ", format(d), " > ", format(tol))
  invisible(d)
}
.D_P1 <- 14.03; .D_P99 <- 29.97                               # (p99 − p1)/0,1 = 159,4: o p99 entra como ponto extra
.d_av <- function(knots) list(fun = "ns", knots = knots, Boundary.knots = c(12, 32), intercept = FALSE)
.d_ns <- function(z, av) unclass(splines::ns(z, knots = av$knots, Boundary.knots = av$Boundary.knots, intercept = isTRUE(av$intercept)))
.d_f <- function(z, av, cf) drop(.d_ns(z, av) %*% cf)
# f, f′ e f″ exatas de cada coluna da base em z, pelo polinômio cúbico do trecho [lo, hi] sem nó no interior
.d_derivs_base <- function(z, lo, hi, av) {
  t <- seq(lo, hi, length.out = 4); s <- (t - lo) / (hi - lo); co <- solve(cbind(1, s, s^2, s^3), .d_ns(t, av)); q <- (z - lo) / (hi - lo); w <- hi - lo
  list(d1 = drop(c(0, 1, 2 * q, 3 * q^2) %*% co) / w, d2 = drop(c(0, 0, 2, 6 * q) %*% co) / w^2)
}
.d_trecho <- function(z, av) { br <- c(av$Boundary.knots[1], av$knots, av$Boundary.knots[2]); i <- max(1L, min(findInterval(z, br), length(br) - 1L)); c(br[i], br[i + 1L]) }
.d_l1 <- function(z, av) { tr <- .d_trecho(z, av); .d_derivs_base(z, tr[1], tr[2], av)$d1 }
.d_l2 <- function(z, av) { tr <- .d_trecho(z, av); .d_derivs_base(z, tr[1], tr[2], av)$d2 }
# coeficientes com f″ fixada nos nós `nos_s` (valores `s`) e f′ = 0 nos pontos `m`, mais linhas extras (lista de c(linha, lado direito))
.d_constroi <- function(av, nos_s, s, m, extra = list()) {
  A <- rbind(do.call(rbind, lapply(nos_s, .d_l2, av = av)), do.call(rbind, lapply(m, .d_l1, av = av)), do.call(rbind, lapply(extra, function(e) e$linha)))
  drop(solve(A, c(s, rep(0, length(m)), vapply(extra, function(e) e$lado, 0))))
}
.d_min <- function(av, cf, lo, hi) stats::optimize(function(z) .d_f(z, av, cf), c(lo, hi), tol = 1e-12)$minimum
.d_f2_trecho <- function(z, lo, hi, av, cf) sum(.d_derivs_base(z, lo, hi, av)$d2 * cf)
# máx f″ em [a, b]: f″ é linear em cada trecho entre nós, então o máximo está num extremo de trecho
.d_M <- function(a, b, av, cf) {
  br <- sort(unique(c(a, b, av$knots[av$knots > a & av$knots < b]))); v <- numeric(0)
  for (i in seq_len(length(br) - 1L)) v <- c(v, .d_f2_trecho(br[i], br[i], br[i + 1L], av, cf), .d_f2_trecho(br[i + 1L], br[i], br[i + 1L], av, cf))
  max(v)
}
.d_celula <- function(xs, g) { j <- findInterval(xs, g); c(a = g[j], b = g[j + 1L], j = j) }
# dias fora do p1–p99 intercalados com os de dentro (no começo e no meio), para o índice de x não coincidir com o dos dias de dentro
.d_intercala <- function(dentro, fora) { k <- length(dentro) %/% 2; c(fora[1], dentro[seq_len(k)], fora[-1], dentro[-seq_len(k)]) }
# cenário 1: curva convexa com mínimo em 21,985, na célula [21,93; 22,03] da grade, com o nó 22 dentro da célula e f″
# máxima nesse nó (0,04), acima dos dois extremos
.d_cen1 <- function(f) {
  av <- .d_av(c(16, 19, 21, 22, 23, 25, 28)); cf <- .d_constroi(av, av$knots, c(0.005, 0.01, 0.02, 0.04, 0.02, 0.01, 0.005), 21.985)
  g <- f$grade_tmr(.D_P1, .D_P99); mrt <- g[which.min(.d_f(g, av, cf))]; xs <- .d_min(av, cf, 21.5, 22.5)
  ce <- .d_celula(xs, g)
  ok <- ce[["a"]] < 22 && 22 < ce[["b"]] && (abs(mrt - ce[["a"]]) < 1e-12 || abs(mrt - ce[["b"]]) < 1e-12) &&
    .d_f2_trecho(22, ce[["a"]], 22, av, cf) > max(.d_f2_trecho(ce[["a"]], ce[["a"]], 22, av, cf), .d_f2_trecho(ce[["b"]], 22, ce[["b"]], av, cf)) + 1e-6
  if (!ok) stop("cenário 1 mal construído")
  list(av = av, cf = cf, g = g, mrt = mrt, xs = xs, ce = ce, x = .d_intercala(c(seq(.D_P1, .D_P99, length.out = 400), xs), c(13, 31)))
}

testes_diagnostico_grade_mrt <- list(

  # mergulho em célula vizinha → (a, vizinha); u_min, célula, M (com o nó interno), cota e razões contra a conta à mão
  td1_celula_vizinha = function(f) {
    s <- .d_cen1(f); a <- s$ce[["a"]]; b <- s$ce[["b"]]
    d <- f$diagnostica_minimo(s$cf, s$av, s$av, s$x, .D_P1, .D_P99, s$mrt, s$g)
    u <- .d_f(s$x[s$x >= .D_P1 & s$x <= .D_P99], s$av, s$cf) - .d_f(s$mrt, s$av, s$cf)
    .d_perto(d$u_min, min(u), 1e-13); stopifnot(d$u_min < -1e-8, d$n_dentro == 401L)
    stopifnot(identical(d$classe, "a, vizinha"), identical(d$classe_num, "a, vizinha"), d$distancia == 0L, !d$parcial, !d$ultima)
    .d_perto(c(d$a, d$b), c(a, b), 0); .d_perto(d$h, b - a, 0)
    M <- .d_M(a, b, s$av, s$cf); cota <- M * (b - a)^2 / 8
    .d_perto(d$M, M, 1e-7, rel = TRUE); .d_perto(d$M_num, M, 1e-3, rel = TRUE); .d_perto(d$cota, cota, 1e-7, rel = TRUE)
    .d_perto(d$razao_mrt, -min(u) / cota, 1e-6, rel = TRUE)
    .d_perto(d$razao_celula, (min(.d_f(c(a, b), s$av, s$cf)) - .d_f(s$xs, s$av, s$cf)) / cota, 1e-6, rel = TRUE)
    .d_perto(d$razao_mrt_num, -min(u) / (d$M_num * (b - a)^2 / 8), 1e-9, rel = TRUE)
    stopifnot(d$razao_mrt <= 1, d$razao_celula <= 1)
  },

  # célula parcial no p99 com h < 0,1 → (a), com a cota do h real
  td2_celula_parcial_p99 = function(f) {
    av <- .d_av(c(18, 24, 27, 29, 30.5)); cf <- .d_constroi(av, av$knots, c(0.002, 0.005, 0.01, 0.02, 0.015), 29.95)
    g <- f$grade_tmr(.D_P1, .D_P99); n <- length(g); mrt <- g[which.min(.d_f(g, av, cf))]; xs <- .d_min(av, cf, 29.5, 30.5)
    a <- g[n - 1L]; b <- g[n]
    if (!(xs > a && xs < b && (abs(mrt - a) < 1e-12 || abs(mrt - b) < 1e-12) && b - a < 0.1 - 1e-8)) stop("cenário 2 mal construído")
    d <- f$diagnostica_minimo(cf, av, av, .d_intercala(c(seq(.D_P1, .D_P99, length.out = 400), xs), c(13, 31.5)), .D_P1, .D_P99, mrt, g)
    stopifnot(identical(d$classe, "a, vizinha"), identical(d$classe_num, "a, vizinha"), d$parcial, d$ultima, d$distancia == 0L)
    .d_perto(d$b, .D_P99, 0); .d_perto(d$h, .D_P99 - a, 1e-12); stopifnot(d$h < 0.05)
    M <- .d_M(a, b, av, cf); cota <- M * (.D_P99 - a)^2 / 8
    .d_perto(d$M, M, 1e-7, rel = TRUE); .d_perto(d$cota, cota, 1e-7, rel = TRUE); .d_perto(d$razao_mrt, -d$u_min / cota, 1e-6, rel = TRUE)
    # (p99 − p1)/0,1 inteiro: a última célula é cheia (h = 0,1) e não é parcial
    g2 <- f$grade_tmr(14, 30); n2 <- length(g2); m2 <- g2[which.min(.d_f(g2, av, cf))]
    if (!(xs > g2[n2 - 1L] && xs < g2[n2] && abs(g2[n2] - 30) < 1e-12)) stop("cenário 2 (inteiro) mal construído")
    d2 <- f$diagnostica_minimo(cf, av, av, .d_intercala(c(seq(14, 30, length.out = 400), xs), c(13, 31.5)), 14, 30, m2, g2)
    stopifnot(identical(d2$classe, "a, vizinha"), d2$ultima, !d2$parcial); .d_perto(d2$h, 0.1, 1e-12)
  },

  # quase empate de dois mínimos locais longe um do outro → (a, quase empate) declarada; razão da célula contra os extremos
  td3_quase_empate = function(f) {
    av <- .d_av(c(14, 16, 18, 20, 22, 24, 26, 28)); g <- f$grade_tmr(.D_P1, .D_P99)
    m1 <- g[which.min(abs(g - 17.03))]; m2 <- 25.08; q <- g[which.min(abs(g - 25.03))]
    empate <- list(linha = 2 * .d_ns(m1, av) - .d_ns(m2, av) - .d_ns(q, av), lado = 0)   # f(m1) a meio caminho entre f(m2) e f(25,03)
    cf <- .d_constroi(av, c(14, 16, 18, 24, 26, 28), c(0.03, 0.08, 0.08, 0.07, 0.09, 0.03), c(m1, m2), list(empate))
    fg <- .d_f(g, av, cf); mrt <- g[which.min(fg)]; xs <- .d_min(av, cf, 24.5, 25.5); ce <- .d_celula(xs, g); k <- which(abs(g - mrt) < 1e-12)
    C1 <- .d_f(.d_min(av, cf, 16, 18), av, cf); C2 <- .d_f(xs, av, cf); G1 <- min(fg[g < 21]); G2 <- min(fg[g > 21])
    if (!(abs(mrt - m1) < 1e-12 && G2 > G1 && G1 > C2 && C1 > C2 && ce[["j"]] - k > 1 && abs(xs - m2) < 1e-6)) stop("cenário 3 mal construído")
    d <- f$diagnostica_minimo(cf, av, av, .d_intercala(c(seq(.D_P1, .D_P99, length.out = 700), xs), c(13, 31.5)), .D_P1, .D_P99, mrt, g)
    stopifnot(identical(d$classe, "a, quase empate de mínimos locais"), identical(d$classe_num, d$classe), d$distancia == ce[["j"]] - k)
    .d_perto(c(d$a, d$b), c(ce[["a"]], ce[["b"]]), 0)
    M <- .d_M(ce[["a"]], ce[["b"]], av, cf); cota <- M * (ce[["b"]] - ce[["a"]])^2 / 8
    .d_perto(d$u_min, C2 - .d_f(mrt, av, cf), 1e-12)
    .d_perto(d$razao_celula, (min(.d_f(ce[c("a", "b")], av, cf)) - C2) / cota, 1e-6, rel = TRUE)
    .d_perto(d$razao_mrt, (.d_f(mrt, av, cf) - C2) / cota, 1e-6, rel = TRUE)
    stopifnot(d$razao_celula > d$razao_mrt + 0.2, d$razao_celula <= 1)
  },

  # base dos dias diferente da base da busca → razão > 1 → anômala
  td4_base_trocada = function(f) {
    s <- .d_cen1(f); av2 <- s$av; av2$knots <- s$av$knots + 0.4
    d <- f$diagnostica_minimo(s$cf, s$av, av2, s$x, .D_P1, .D_P99, s$mrt, s$g)
    u <- .d_f(s$x[s$x >= .D_P1 & s$x <= .D_P99], av2, s$cf) - .d_f(s$mrt, av2, s$cf)
    .d_perto(d$u_min, min(u), 1e-12)
    stopifnot(identical(d$classe, "anomala"), identical(d$classe_num, "anomala"), max(d$razao_mrt, d$razao_celula) > 1)
    # cada termo com a sua base: dia do mínimo e f(x*) pela base dos dias; grade, f(a), f(b) e f″ pela base da busca
    xd <- s$x[s$x >= .D_P1 & s$x <= .D_P99]; x2 <- xd[which.min(u)]; ce <- .d_celula(x2, s$g)
    M <- .d_M(ce[["a"]], ce[["b"]], s$av, s$cf); cota <- M * (ce[["b"]] - ce[["a"]])^2 / 8
    .d_perto(c(d$a, d$b), c(ce[["a"]], ce[["b"]]), 0); .d_perto(d$M, M, 1e-7, rel = TRUE); .d_perto(d$razao_mrt, -min(u) / cota, 1e-6, rel = TRUE)
    .d_perto(d$razao_celula, (min(.d_f(ce[c("a", "b")], s$av, s$cf)) - .d_f(x2, av2, s$cf)) / cota, 1e-6, rel = TRUE)
  },

  # u_min diferente do gravado em mais de 1e-13 → parada; dentro da tolerância, segue
  td5_gravado = function(f) {
    s <- .d_cen1(f); um <- min(.d_f(s$x[s$x >= .D_P1 & s$x <= .D_P99], s$av, s$cf) - .d_f(s$mrt, s$av, s$cf))
    d1 <- f$diagnostica_minimo(s$cf, s$av, s$av, s$x, .D_P1, .D_P99, s$mrt, s$g, min_delta_gravado = um + 1e-12)
    d2 <- f$diagnostica_minimo(s$cf, s$av, s$av, s$x, .D_P1, .D_P99, s$mrt, s$g, min_delta_gravado = um + 5e-14)
    stopifnot(identical(d1$classe, "parada"), is.na(d1$a), d1$dif_gravado > 9e-13, identical(d2$classe, "a, vizinha"), d2$dif_gravado < 1e-13)
    # MRT a 1e-6 °C de um ponto da grade (fora da tolerância de 1e-8): anômala, mesmo com as razões abaixo de 1
    d3 <- f$diagnostica_minimo(s$cf, s$av, s$av, s$x, .D_P1, .D_P99, s$mrt + 1e-6, s$g)
    stopifnot(identical(d3$classe, "anomala"), d3$u_min < -1e-8)
  },

  # grade sem o p99, MRT no último ponto do seq e curva ainda descendo → (b); com a grade_tmr, MRT no p99 e sem negativo
  td6_grade_sem_p99 = function(f) {
    av <- .d_av(c(18, 24, 27, 29, 30.5)); cf <- .d_constroi(av, av$knots, c(0.002, 0.005, 0.01, 0.02, 0.015), 31)
    zz <- seq(.D_P1, .D_P99, by = 0.001); if (any(diff(.d_f(zz, av, cf)) >= 0)) stop("cenário 6 mal construído")
    g0 <- seq(.D_P1, .D_P99, by = 0.1); m0 <- g0[which.min(.d_f(g0, av, cf))]; stopifnot(m0 == g0[length(g0)])
    x <- .d_intercala(c(seq(.D_P1, .D_P99, length.out = 400), .D_P99), c(30.5, 31.2))
    d0 <- f$diagnostica_minimo(cf, av, av, x, .D_P1, .D_P99, m0, g0)
    stopifnot(identical(d0$classe, "b"), identical(d0$classe_num, "b"), d0$u_min < -1e-5)
    g <- f$grade_tmr(.D_P1, .D_P99); mrt <- g[which.min(.d_f(g, av, cf))]; .d_perto(mrt, .D_P99, 0)
    d <- f$diagnostica_minimo(cf, av, av, x, .D_P1, .D_P99, mrt, g)
    stopifnot(is.na(d$classe), d$u_min >= -1e-15, d$n_dentro == 401L)
    p0 <- f$parte1_grade(.D_P1, .D_P99, m0, g0); p <- f$parte1_grade(.D_P1, .D_P99, mrt, g)
    stopifnot(!p0$ultimo_eh_p99, p0$p99_acrescentado, p$ultimo_eh_p99, p$mrt_no_p99, !p0$mrt_no_p99)
    # simétrico no p1: grade sem o p1, curva subindo desde abaixo do p1, MRT no primeiro ponto → (b); com a grade_tmr, sem negativo
    cf1 <- .d_constroi(av, av$knots, c(0.002, 0.005, 0.01, 0.02, 0.015), 13)
    if (any(diff(.d_f(zz, av, cf1)) <= 0)) stop("cenário 6 (p1) mal construído")
    g1 <- seq(.D_P1 + 0.04, .D_P99, by = 0.1); if (.D_P99 - g1[length(g1)] > 1e-8) g1 <- c(g1, .D_P99); m1 <- g1[which.min(.d_f(g1, av, cf1))]; stopifnot(m1 == g1[1])
    x1 <- .d_intercala(c(.D_P1, seq(.D_P1, .D_P99, length.out = 400)), c(12.5, 31))
    d1 <- f$diagnostica_minimo(cf1, av, av, x1, .D_P1, .D_P99, m1, g1)
    stopifnot(identical(d1$classe, "b"), identical(d1$classe_num, "b"), d1$u_min < -1e-5)
    gp <- f$grade_tmr(.D_P1, .D_P99); mp <- gp[which.min(.d_f(gp, av, cf1))]; .d_perto(mp, .D_P1, 0)
    dp <- f$diagnostica_minimo(cf1, av, av, x1, .D_P1, .D_P99, mp, gp); stopifnot(is.na(dp$classe), dp$u_min >= -1e-15)
  },

  # Parte 1: primeiro ponto, último do seq, p99 acrescentado, último ponto = p99, MRT no p99
  td7_parte1 = function(f) {
    g <- f$grade_tmr(.D_P1, .D_P99); p <- f$parte1_grade(.D_P1, .D_P99, 29.97, g)
    stopifnot(p$n_grade == 161L, p$primeiro_eh_p1, p$p99_acrescentado, p$ultimo_eh_p99, p$mrt_no_p99)
    .d_perto(p$ultimo_seq, .D_P1 + 159 * 0.1, 1e-12); .d_perto(p$ultimo, .D_P99, 0)
    g2 <- f$grade_tmr(14, 30); p2 <- f$parte1_grade(14, 30, 29.9, g2)
    stopifnot(p2$n_grade == 161L, p2$primeiro_eh_p1, !p2$p99_acrescentado, p2$ultimo_eh_p99, !p2$mrt_no_p99)
    p3 <- f$parte1_grade(.D_P1, .D_P99, 29.93, seq(.D_P1, .D_P99, by = 0.1))
    stopifnot(p3$n_grade == 160L, !p3$ultimo_eh_p99, !p3$mrt_no_p99)
    p4 <- f$parte1_grade(.D_P1, .D_P99, 29.97, c(seq(.D_P1 + 0.04, .D_P99, by = 0.1), .D_P99)); stopifnot(!p4$primeiro_eh_p1, p4$ultimo_eh_p99)
    p5 <- f$parte1_grade(14.075, 29.98, 29.9, seq(14.075, 29.98, by = 0.1)); stopifnot(p5$p99_acrescentado, !p5$ultimo_eh_p99)
    .d_perto(29.98 - p5$ultimo, 0.005, 1e-9)
    p6 <- f$parte1_grade(14, 30 + 5e-9, 29.9, f$grade_tmr(14, 30 + 5e-9)); stopifnot(!p6$p99_acrescentado, p6$ultimo_eh_p99, p6$n_grade == 161L)
  },

  # distância em células e regras da classe (vizinha só com distância 0; tolerância 1e-6; M > 0)
  td8_distancia_classe = function(f) {
    stopifnot(f$distancia_celulas(5L, 5L) == 0L, f$distancia_celulas(5L, 6L) == 0L, f$distancia_celulas(5L, 4L) == 1L,
              f$distancia_celulas(5L, 3L) == 2L, f$distancia_celulas(5L, 7L) == 1L, f$distancia_celulas(5L, 9L) == 3L)
    h <- 0.1; M <- 0.04; cota <- M * h^2 / 8
    k <- function(r_mrt, r_cel, dist, MM = M) f$classifica_celula(MM, h, -r_mrt * cota, 1, 1, 1 - r_cel * cota, dist)$classe
    stopifnot(identical(k(0.5, 0.5, 0L), "a, vizinha"), identical(k(0.5, 0.7, 1L), "a, quase empate de mínimos locais"),
              identical(k(0.5, 0.7, 4L), "a, quase empate de mínimos locais"), identical(k(1 + 5e-7, 0.5, 0L), "a, vizinha"),
              identical(k(1 + 2e-6, 0.5, 0L), "anomala"), identical(k(0.5, 1 + 2e-6, 0L), "anomala"), identical(k(0.5, 0.5, 0L, 0), "anomala"),
              identical(k(0.5, 0.5, 0L, -M), "anomala"))   # M < 0 dá razões negativas: só a trava M > 0 a barra
    r <- f$classifica_celula(M, h, -0.3 * cota, 1, 1.2, 1 - 0.6 * cota, 2L)
    .d_perto(c(r$cota, r$razao_mrt, r$razao_celula), c(cota, 0.3, 0.6), 1e-9, rel = TRUE)
  },

  # f e f″ da função contra splines::ns e contra o polinômio exato de cada trecho; f″ fora dos Boundary.knots dá erro
  td9_f_e_f2 = function(f) {
    av <- c(.d_av(c(15.2, 21.7, 26.1)), cen = 20); cf <- c(0.03, -0.11, 0.07, 0.19)
    z <- c(seq(12, 32, by = 0.37), av$knots, 12, 32); .d_perto(f$f_ns(z, av, cf), .d_f(z, av[names(av) != "cen"], cf), 1e-14)
    br <- c(12, av$knots, 32); ref <- unlist(lapply(seq_len(length(br) - 1L), function(i) {
      zi <- seq(br[i], br[i + 1L], length.out = 7); vapply(zi, function(q) .d_f2_trecho(q, br[i], br[i + 1L], av, cf), 0) }))
    zi <- unlist(lapply(seq_len(length(br) - 1L), function(i) seq(br[i], br[i + 1L], length.out = 7)))
    .d_perto(f$f2_ns(zi, av, cf), ref, 1e-9)
    .d_perto(f$f2_num(seq(13, 31, by = 0.5), av, cf), f$f2_ns(seq(13, 31, by = 0.5), av, cf), 1e-6)
    if (!inherits(try(f$f2_ns(32.5, av, cf), silent = TRUE), "try-error")) stop("f2_ns aceitou z fora dos Boundary.knots")
  }
)
