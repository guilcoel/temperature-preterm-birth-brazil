# testa_diagnostico_grade_mrt.R — testes sintéticos de diagnostico_grade_mrt.R (errata da D5 de 14/10/2026, item 2;
# entradas 80, 82(a) e 83(a) do log do Artigo 1). Cada teste recebe `f` (ambiente com segunda_etapa.R da tag segunda_etapa-v1.0 e
# diagnostico_grade_mrt.R) e para com erro se uma conferência falhar. A grade é sempre a f$grade_tmr, salvo no caso (b),
# que usa de propósito uma grade sem o p99. Só dado sintético. Referências independentes da função testada:
# splines::ns direto (não a onebasis) e f″ pelo polinômio cúbico exato de cada trecho sem nó. Executor: roda_testes.R.
# v1.0.1 (Fase 4 do Artigo 1; os 5 Menores e as Notas 8 e 9 de logs/auditoria_travas2_fase3_20261014.md): asserções de
# classe_num no td5 (Menor 2); td13 (Menor 1, tol_f frouxo), td14 (Menor 3, cota pequena), td15 (Nota 8, M não finito) e
# o caso do td7 com o p99 a 0,005 do último ponto do seq (Nota 9). Nenhuma função muda; só testes.

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
    # a trava 2 usa a base da busca: aqui o argmin de f na grade pela base dos dias não é a MRT, e a trava tem de passar
    if (s$g[which.min(.d_f(s$g, av2, s$cf))] == s$mrt) stop("cenário 4 mal construído (argmin igual nas duas bases)")
    stopifnot(isTRUE(d$trava_mrt_argmin), grepl("razão MRT acima de 1 + tol", d$motivo, fixed = TRUE), grepl("razão célula acima de 1 + tol", d$motivo, fixed = TRUE))
  },

  # u_min diferente do gravado em mais de 1e-13 → parada; dentro da tolerância, segue
  td5_gravado = function(f) {
    s <- .d_cen1(f); um <- min(.d_f(s$x[s$x >= .D_P1 & s$x <= .D_P99], s$av, s$cf) - .d_f(s$mrt, s$av, s$cf))
    d1 <- f$diagnostica_minimo(s$cf, s$av, s$av, s$x, .D_P1, .D_P99, s$mrt, s$g, min_delta_gravado = um + 1e-12)
    d2 <- f$diagnostica_minimo(s$cf, s$av, s$av, s$x, .D_P1, .D_P99, s$mrt, s$g, min_delta_gravado = um + 5e-14)
    stopifnot(identical(d1$classe, "parada"), identical(d1$classe_num, "parada"), is.na(d1$a), d1$dif_gravado > 9e-13, identical(d2$classe, "a, vizinha"), d2$dif_gravado < 1e-13)
    # MRT a 1e-6 °C de um ponto da grade (fora da tolerância de 1e-8), deslocada na direção do mínimo, para que as travas
    # da entrada 82(a) passem e só a checagem do ponto da grade a barre: anômala, mesmo com as razões abaixo de 1
    d3 <- f$diagnostica_minimo(s$cf, s$av, s$av, s$x, .D_P1, .D_P99, s$mrt + if (s$mrt > s$xs) -1e-6 else 1e-6, s$g)
    stopifnot(identical(d3$classe, "anomala"), identical(d3$classe_num, "anomala"), identical(d3$motivo, "MRT não é ponto da grade"), d3$u_min < -1e-8)
    # a MRT tem de ser exatamente um ponto da grade (entrada 83(a)): a 5e-9 °C, na direção do mínimo, e a 1 ulp, anômala
    d5 <- f$diagnostica_minimo(s$cf, s$av, s$av, s$x, .D_P1, .D_P99, s$mrt + if (s$mrt > s$xs) -5e-9 else 5e-9, s$g)
    stopifnot(identical(d5$classe, "anomala"), identical(d5$classe_num, "anomala"), identical(d5$motivo, "MRT não é ponto da grade"))
    mu <- s$mrt * (1 + .Machine$double.eps); if (!(mu != s$mrt)) stop("1 ulp não mudou a MRT")
    d6 <- f$diagnostica_minimo(s$cf, s$av, s$av, s$x, .D_P1, .D_P99, mu, s$g)
    stopifnot(identical(d6$classe, "anomala"), identical(d6$classe_num, "anomala"), identical(d6$motivo, "MRT não é ponto da grade"))
    # MRT abaixo do p1 (fora da faixa da grade): anômala, sem erro
    d8 <- f$diagnostica_minimo(s$cf, s$av, s$av, s$x, .D_P1, .D_P99, s$g[1] - 0.05, s$g)
    stopifnot(identical(d8$classe, "anomala"), identical(d8$classe_num, "anomala"), identical(d8$motivo, "MRT não é ponto da grade"))
    # com a MRT no ponto, f(mrt) é idêntico a f(grade)[k] (a trava 2 com f(mrt) é mutante equivalente)
    stopifnot(identical(f$f_ns(s$mrt, s$av, s$cf), f$f_ns(s$g, s$av, s$cf)[match(s$mrt, s$g)]))
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
    # x* exatamente no p99 (último ponto da grade) e MRT 30 pontos antes: anômala, sem erro
    n <- length(g); d7 <- f$diagnostica_minimo(cf, av, av, x, .D_P1, .D_P99, g[n - 30], g)
    stopifnot(identical(d7$classe, "anomala"), !d7$trava_coerencia, !d7$trava_mrt_argmin, d7$b == .D_P99)
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
    # Nota 9: p99 a 0,005 °C do último ponto do seq (acrescentado) e MRT no penúltimo ponto: |MRT − p99| = 0,005 > 1e-8
    g9 <- f$grade_tmr(.D_P1, 29.935); n9 <- length(g9); p9 <- f$parte1_grade(.D_P1, 29.935, g9[n9 - 1L], g9)
    stopifnot(p9$p99_acrescentado, p9$ultimo_eh_p99, !p9$mrt_no_p99); .d_perto(p9$dif_mrt_p99, 0.005, 1e-9)
  },

  # distância em células e regras da classe (vizinha só com distância 0; tolerância 1e-6; M > 0)
  td8_distancia_classe = function(f) {
    stopifnot(f$distancia_celulas(5L, 5L) == 0L, f$distancia_celulas(5L, 6L) == 0L, f$distancia_celulas(5L, 4L) == 1L,
              f$distancia_celulas(5L, 3L) == 2L, f$distancia_celulas(5L, 7L) == 1L, f$distancia_celulas(5L, 9L) == 3L)
    h <- 0.1; M <- 0.04; cota <- M * h^2 / 8
    k <- function(r_mrt, r_cel, dist, MM = M) f$classifica_celula(MM, h, -r_mrt * cota, 1, 1, 1 - r_cel * cota, dist, tol_f = 1e-12, mrt_argmin = TRUE)$classe
    stopifnot(identical(k(0.5, 0.5, 0L), "a, vizinha"), identical(k(0.5, 0.7, 1L), "a, quase empate de mínimos locais"),
              identical(k(0.5, 0.7, 4L), "a, quase empate de mínimos locais"), identical(k(1 + 5e-7, 1 + 5e-7, 0L), "a, vizinha"),
              identical(k(1 + 2e-6, 1 + 2e-6, 0L), "anomala"), identical(k(0.5, 1 + 2e-6, 0L), "anomala"), identical(k(0.5, 0.5, 0L, 0), "anomala"),
              identical(k(0.5, 0.5, 0L, -M), "anomala"))   # M < 0 dá razões negativas: só a trava M > 0 a barra
    r <- f$classifica_celula(M, h, -0.3 * cota, 1, 1.2, 1 - 0.6 * cota, 2L, tol_f = 1e-12, mrt_argmin = TRUE)
    .d_perto(c(r$cota, r$razao_mrt, r$razao_celula), c(cota, 0.3, 0.6), 1e-9, rel = TRUE)
    # travas da entrada 82(a) na regra da classe: razão célula < razão MRT; MRT fora do argmin; h > 0,1 + 1e-8
    stopifnot(identical(k(0.6, 0.5, 0L), "anomala"), identical(f$classifica_celula(M, h, -0.5 * cota, 1, 1, 1 - 0.5 * cota, 0L, tol_f = 1e-12, mrt_argmin = FALSE)$classe, "anomala"),
              identical(f$classifica_celula(M, 0.1 + 2e-8, -0.5 * cota, 1, 1, 1 - 0.5 * cota, 0L, tol_f = 1e-12, mrt_argmin = TRUE)$classe, "anomala"),
              identical(f$classifica_celula(M, 0.1 + 5e-9, -0.5 * cota, 1, 1, 1 - 0.5 * cota, 0L, tol_f = 1e-12, mrt_argmin = TRUE)$classe, "a, vizinha"))
    # toda anômala tem motivo: M ≤ 0, razão acima de 1 + tol
    stopifnot(identical(f$classifica_celula(0, h, -0.5 * cota, 1, 1, 1 - 0.5 * cota, 0L, tol_f = 1e-12, mrt_argmin = TRUE)$motivos, "M ≤ 0 ou não finito"),
              identical(f$classifica_celula(M, h, -1.5 * cota, 1, 1, 1 - 1.5 * cota, 0L, tol_f = 1e-12, mrt_argmin = TRUE)$motivos, c("razão MRT acima de 1 + tol", "razão célula acima de 1 + tol")))
    # escala da tolerância da coerência (tol_f = 1e-12, em unidades de f): folga de −5e-12 cai; de −5e-13, passa
    stopifnot(identical(k(0.5, 0.5 - 1e-7, 0L), "anomala"), identical(k(0.5, 0.5 - 1e-8, 0L), "a, vizinha"))
    # sem tol_f ou sem mrt_argmin, a chamada dá erro (nenhuma trava é pulada em silêncio)
    if (!inherits(try(f$classifica_celula(M, h, -0.5 * cota, 1, 1, 1 - 0.5 * cota, 0L), silent = TRUE), "try-error")) stop("classifica_celula aceitou chamada sem tol_f e mrt_argmin")
  },

  # travas da entrada 82(a), um caso por trava, cada um com as outras duas passando; e os três motivos juntos com "; "
  td10_travas = function(f) {
    so_trava <- function(d, nome, motivo) {
      stopifnot(identical(d$classe, "anomala"), identical(d$classe_num, "anomala"), identical(d$motivo, motivo))
      tr <- c(trava_coerencia = d$trava_coerencia, trava_mrt_argmin = d$trava_mrt_argmin, trava_h = d$trava_h)
      stopifnot(identical(unname(tr), names(tr) != nome), d$razao_mrt <= 1, d$razao_celula <= 1, d$M > 0)
    }
    s <- .d_cen1(f)
    # (1) coerência: base dos dias com os nós deslocados em −0,005 °C; f_dias(MRT) > f_busca(MRT), razões ≤ 1
    av2 <- s$av; av2$knots <- s$av$knots - 0.005
    if (!(.d_f(s$mrt, av2, s$cf) - .d_f(s$mrt, s$av, s$cf) > 1e-9)) stop("cenário da trava 1 mal construído")
    so_trava(f$diagnostica_minimo(s$cf, s$av, av2, s$x, .D_P1, .D_P99, s$mrt, s$g), "trava_coerencia", "razão célula menor que a razão MRT (em unidades de f)")
    # (2) MRT fora do argmin: curva em W com o primeiro poço raso; a MRT passada é o vizinho do argmin, abaixo dos extremos da célula do mínimo
    av <- .d_av(c(14, 16, 18, 20, 22, 24, 26, 28)); g <- f$grade_tmr(.D_P1, .D_P99)
    m1 <- g[which.min(abs(g - 17.03))]; m2 <- 25.08; q <- g[which.min(abs(g - 25.03))]
    cf <- .d_constroi(av, c(14, 16, 18, 24, 26, 28), c(0.001, 0.002, 0.002, 0.07, 0.09, 0.03), c(m1, m2),
                      list(list(linha = 2 * .d_ns(m1, av) - .d_ns(m2, av) - .d_ns(q, av), lado = 0)))
    fg <- .d_f(g, av, cf); w <- g[which.min(abs(g - 17.13))]; xs <- .d_min(av, cf, 24.5, 25.5)
    if (!(g[which.min(fg)] == m1 && .d_f(w, av, cf) - min(fg) > 1e-9 && .d_f(w, av, cf) < min(fg[g > 21]) && abs(xs - m2) < 1e-6)) stop("cenário da trava 2 mal construído")
    so_trava(f$diagnostica_minimo(cf, av, av, .d_intercala(c(seq(.D_P1, .D_P99, length.out = 700), xs), c(13, 31.5)), .D_P1, .D_P99, w, g),
             "trava_mrt_argmin", "MRT não é o argmin de f na grade")
    # (2b) a mesma trava na escala de tol_f: poço 1 entre 17,03 e 17,13, com f(17,13) − f(17,03) = 1e-10 e a MRT passada em 17,13
    p2 <- w; mm <- stats::uniroot(function(m) { cc <- .d_constroi(av, c(14, 16, 18, 24, 26, 28), c(0.001, 0.002, 0.002, 0.07, 0.09, 0.03), c(m, m2),
        list(list(linha = 2 * .d_ns(m1, av) - .d_ns(m2, av) - .d_ns(q, av), lado = 0))); .d_f(p2, av, cc) - .d_f(m1, av, cc) - 1e-10 }, c(17.07, 17.09), tol = 1e-14)$root
    cfb <- .d_constroi(av, c(14, 16, 18, 24, 26, 28), c(0.001, 0.002, 0.002, 0.07, 0.09, 0.03), c(mm, m2), list(list(linha = 2 * .d_ns(m1, av) - .d_ns(m2, av) - .d_ns(q, av), lado = 0)))
    fgb <- .d_f(g, av, cfb); xsb <- .d_min(av, cfb, 24.5, 25.5); dfb <- .d_f(p2, av, cfb) - min(fgb)
    if (!(g[which.min(fgb)] == m1 && dfb > 5e-11 && dfb < 2e-10 && max(abs(fgb)) < 1 && .d_f(p2, av, cfb) < min(fgb[g > 21]))) stop("cenário da trava 2 (escala) mal construído")
    so_trava(f$diagnostica_minimo(cfb, av, av, .d_intercala(c(seq(.D_P1, .D_P99, length.out = 700), xsb), c(13, 31.5)), .D_P1, .D_P99, p2, g),
             "trava_mrt_argmin", "MRT não é o argmin de f na grade")
    # (3) h > 0,1 + 1e-8: grade de 0,12 °C (com o p99), MRT no argmin
    g3 <- seq(.D_P1, .D_P99, by = 0.12); if (.D_P99 - g3[length(g3)] > 1e-8) g3 <- c(g3, .D_P99); m3 <- g3[which.min(.d_f(g3, s$av, s$cf))]
    d3 <- f$diagnostica_minimo(s$cf, s$av, s$av, s$x, .D_P1, .D_P99, m3, g3); so_trava(d3, "trava_h", "h maior que 0,1 + 1e-8"); .d_perto(d3$h, 0.12, 1e-12)
    # as três juntas: grade de 0,12 °C e MRT no outro extremo da célula do mínimo
    ce <- .d_celula(s$xs, g3); outro <- if (abs(m3 - ce[["a"]]) < 1e-12) ce[["b"]] else ce[["a"]]
    d4 <- f$diagnostica_minimo(s$cf, s$av, s$av, s$x, .D_P1, .D_P99, outro, g3)
    stopifnot(identical(d4$classe, "anomala"), identical(d4$classe_num, "anomala"), !d4$trava_coerencia, !d4$trava_mrt_argmin, !d4$trava_h,
              identical(d4$motivo, "razão MRT acima de 1 + tol; razão célula menor que a razão MRT (em unidades de f); MRT não é o argmin de f na grade; h maior que 0,1 + 1e-8"))
    # no cenário 1, as três passam e o motivo fica vazio
    d0 <- f$diagnostica_minimo(s$cf, s$av, s$av, s$x, .D_P1, .D_P99, s$mrt, s$g)
    stopifnot(d0$trava_coerencia, d0$trava_mrt_argmin, d0$trava_h, identical(d0$motivo, ""))
  },

  # célula da borda (p1) com f″ trocando de sinal, |mín f″| > máx f″: M é o máximo de f″, não de |f″| (reauditoria, achado 1)
  td11_borda_f2_sinal = function(f) {
    g <- f$grade_tmr(.D_P1, .D_P99); a <- g[1]; b <- g[2]; av <- .d_av(c(a, b, 20, 25))
    cf <- .d_constroi(av, av$knots, c(-0.003, 0.002, 0.01, 0.01), a + 0.095)
    mrt <- g[which.min(.d_f(g, av, cf))]; xs <- .d_min(av, cf, a + 0.06, b)
    if (!(mrt == b && xs > a && xs < b && .d_f(a, av, cf) > .d_f(xs, av, cf) && .d_f(b, av, cf) - .d_f(xs, av, cf) > 1e-8)) stop("cenário da borda mal construído")
    d <- f$diagnostica_minimo(cf, av, av, .d_intercala(c(seq(.D_P1, .D_P99, length.out = 400), xs), c(13, 31.5)), .D_P1, .D_P99, mrt, g)
    stopifnot(identical(d$classe, "a, vizinha"), identical(d$classe_num, "a, vizinha"), d$a == a, d$b == b, d$u_min < -1e-8)
    M <- .d_M(a, b, av, cf); .d_perto(M, 0.002, 1e-9); .d_perto(d$M, M, 1e-7, rel = TRUE); .d_perto(d$cota, M * (b - a)^2 / 8, 1e-7, rel = TRUE)
  },

  # motivo "f″ analítica e numérica mudam a classe" (omitido ou sobrescrevendo) e a escala de tol_f (entrada 83(a))
  td12_motivo_f2_e_tol_f = function(f) {
    s <- .d_cen1(f)
    # (1) passo numérico de 2 °C: analítica (a), numérica anômala, motivo só o da f″
    d1 <- f$diagnostica_minimo(s$cf, s$av, s$av, s$x, .D_P1, .D_P99, s$mrt, s$g, passo_num = 2)
    stopifnot(identical(d1$classe, "a, vizinha"), identical(d1$classe_num, "anomala"), identical(d1$motivo, "f″ analítica e numérica mudam a classe"))
    # (2) f″ em V na célula e base dos dias com o nó 25 deslocado: analítica anômala por razão, numérica (a), travas passando;
    #     o motivo junta o da razão e o da f″ (com uma trava caindo, as duas classes seriam anômalas e o da f″ não apareceria)
    av <- .d_av(c(16, 19, 21, 22, 23, 25, 28)); cf <- .d_constroi(av, av$knots, c(0.005, 0.01, 0.08, 0.01, 0.08, 0.01, 0.005), 21.985)
    g <- f$grade_tmr(.D_P1, .D_P99); mrt <- g[which.min(.d_f(g, av, cf))]; xs <- .d_min(av, cf, 21.5, 22.5)
    av2 <- av; av2$knots[6] <- av2$knots[6] + 0.05
    d2 <- f$diagnostica_minimo(cf, av, av2, .d_intercala(c(seq(.D_P1, .D_P99, length.out = 400), xs), c(13, 31)), .D_P1, .D_P99, mrt, g, passo_num = 1)
    stopifnot(identical(d2$classe, "anomala"), startsWith(d2$classe_num, "a, "), d2$trava_coerencia, d2$trava_mrt_argmin, d2$trava_h, d2$M_num > d2$M,
              identical(d2$motivo, "razão célula acima de 1 + tol; f″ analítica e numérica mudam a classe"))
    # (3) e (4) escala de tol_f: f multiplicada para máx|f(grade)| = 10 e = 0,01; base dos dias com os nós deslocados para a
    #     folga da coerência ficar em −5e-12 (passa com tol_f = 1e-11) e em −5e-13 (passa com tol_f = 1e-12, pelo máx(1, ·))
    mg <- max(abs(.d_f(s$g, s$av, s$cf)))
    for (caso in list(c(alvo_f = 10, folga = 5e-12), c(alvo_f = 0.01, folga = 5e-13))) {
      cfK <- s$cf * caso[["alvo_f"]] / mg
      dl <- stats::uniroot(function(d) { a2 <- s$av; a2$knots <- s$av$knots + d; .d_f(s$mrt, a2, cfK) - .d_f(s$mrt, s$av, cfK) - caso[["folga"]] }, c(-1e-6, 0), tol = 1e-22)$root
      a3 <- s$av; a3$knots <- s$av$knots + dl; fol <- .d_f(s$mrt, a3, cfK) - .d_f(s$mrt, s$av, cfK)
      if (!(abs(max(abs(.d_f(s$g, s$av, cfK))) - caso[["alvo_f"]]) < 1e-9 * caso[["alvo_f"]] && fol > 0.5 * caso[["folga"]] && fol < 2 * caso[["folga"]])) stop("cenário de escala mal construído")
      d <- f$diagnostica_minimo(cfK, s$av, a3, s$x, .D_P1, .D_P99, s$mrt, s$g)
      stopifnot(identical(d$classe, "a, vizinha"), isTRUE(d$trava_coerencia), d$u_min < -1e-8)
    }
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
  },

  # Menor 1: no cenário 1 (máx|f(grade)| < 1, tol_f = 1e-12), folga da coerência em −5e-12 (entre −10·tol_f e −tol_f):
  # anômala pela trava de coerência (com tol_f 10× mais frouxo, daria "a, vizinha")
  td13_tol_f_frouxo = function(f) {
    s <- .d_cen1(f); mg <- max(abs(.d_f(s$g, s$av, s$cf))); if (!(mg < 1)) stop("cenário do Menor 1 com máx|f(grade)| ≥ 1")
    dl <- stats::uniroot(function(d) { a2 <- s$av; a2$knots <- s$av$knots + d; .d_f(s$mrt, a2, s$cf) - .d_f(s$mrt, s$av, s$cf) - 5e-12 }, c(-1e-6, 0), tol = 1e-22)$root
    a3 <- s$av; a3$knots <- s$av$knots + dl; fol <- .d_f(s$mrt, a3, s$cf) - .d_f(s$mrt, s$av, s$cf)
    if (!(fol > 2e-12 && fol < 9e-12)) stop("folga do cenário fora de (2e-12, 9e-12): ", format(fol))
    d <- f$diagnostica_minimo(s$cf, s$av, a3, s$x, .D_P1, .D_P99, s$mrt, s$g)
    stopifnot(identical(d$classe, "anomala"), identical(d$classe_num, "anomala"), identical(d$trava_coerencia, FALSE), d$u_min < -1e-8,
              grepl("razão célula menor que a razão MRT (em unidades de f)", d$motivo, fixed = TRUE))
  },

  # Menor 3: cota pequena (M = 1e-6, h = 0,1), razão MRT = 1,0001 e razão célula = 1: a coerência passa (folga de
  # −1,25e-13 ≥ −tol_f) e só a checagem razão MRT ≤ 1 + tol barra: anômala, com o motivo dela
  td14_cota_pequena = function(f) {
    M <- 1e-6; h <- 0.1; cota <- M * h^2 / 8
    r <- f$classifica_celula(M, h, -1.0001 * cota, 1, 1, 1 - cota, 0L, tol_f = 1e-12, mrt_argmin = TRUE)
    stopifnot(identical(r$classe, "anomala"), isTRUE(r$trava_coerencia), identical(r$motivos, "razão MRT acima de 1 + tol"))
    .d_perto(c(r$razao_mrt, r$razao_celula), c(1.0001, 1), 1e-6, rel = TRUE)   # 1 − (1 − cota), cota = 1,25e-9: cancelamento ~1e-8
  },

  # Nota 8: M não finito (Inf, NaN) → anômala com o motivo "M ≤ 0 ou não finito"
  td15_M_nao_finito = function(f) {
    cota0 <- 0.04 * 0.1^2 / 8
    for (M in c(Inf, NaN)) {
      r <- f$classifica_celula(M, 0.1, -0.5 * cota0, 1, 1, 1 - 0.5 * cota0, 0L, tol_f = 1e-12, mrt_argmin = TRUE)
      stopifnot(identical(r$classe, "anomala"), identical(r$motivos, "M ≤ 0 ou não finito"))
    }
  }
)
