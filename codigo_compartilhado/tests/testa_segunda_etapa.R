# testa_segunda_etapa.R — testes rápidos da segunda etapa (prompt da Fase 3 do Artigo 1, A2; complemento de 13/10).
# Cada teste recebe `f` (ambiente com segunda_etapa.R e ajusta_dlnm.R) e para com erro se uma conferência falhar.
# Os testes t01 a t03 usam dados reais SÓ de atributos da base, exposição, percentis e códigos das concentrações, postos
# por quem chama em .R3 (argvar e arglag da Fase 2, x das 4.505 linhas por concentração, grade e eixo da A0, nós do
# CSV, códigos de cidade_nucleo()); nenhum coeficiente real é usado e nenhum RR ou curva é calculado com eles.
# Os demais usam só dado sintético. Resultados descritivos vão para .T3 (para o log). Executor: roda_testes.R.

if (!exists(".R3", inherits = FALSE)) .R3 <- new.env()
if (!exists(".T3", inherits = FALSE)) .T3 <- new.env()
.s_perto <- function(a, b, tol, rel = FALSE) {
  a <- as.numeric(a); b <- as.numeric(b)
  if (length(a) != length(b)) stop("tamanhos diferentes: ", length(a), " × ", length(b))
  d <- if (rel) max(abs(a - b) / pmax(abs(b), 1e-300)) else max(abs(a - b))
  if (!is.finite(d) || d > tol) stop("diferença ", format(d), " > ", format(tol))
  invisible(d)
}
.s_erro <- function(fun, padrao) { m <- tryCatch({ fun(); NA_character_ }, error = function(e) conditionMessage(e))
  if (is.na(m) || !grepl(padrao, m)) stop("esperava erro com '", padrao, "', veio: ", m) }
.s_reais <- function() { if (is.null(.R3$argvar)) stop("dados reais (.R3) ausentes: o teste precisa dos atributos da Fase 2"); .R3 }
# cópia de uma função de `f` com trocas no corpo e stubs (só para testar ramos; mesmo padrão da Fase 2)
.s_stub <- function(f, nome, trocas, stubs) {
  g <- f[[nome]]; b <- paste(deparse(body(g), width.cutoff = 500L), collapse = "\n")
  for (t in trocas) { if (!grepl(t[1], b, fixed = TRUE)) stop("alvo do stub não encontrado: ", t[1]); b <- sub(t[1], t[2], b, fixed = TRUE) }
  body(g) <- parse(text = b)[[1]]; e <- new.env(parent = environment(f[[nome]])); for (k in names(stubs)) assign(k, stubs[[k]], envir = e)
  environment(g) <- e; g
}
# série sintética de temperatura (sem desfecho real)
.s_temp <- function(n, semente = 20261001) { set.seed(semente); t <- seq_len(n)
  22 + 5 * sin(2 * pi * t / 365.25) + as.numeric(stats::arima.sim(list(ar = 0.6), n = n, sd = 1.5)) }
.s_argvar <- function(x) list(fun = "ns", knots = unname(stats::quantile(x, c(.1, .75, .9), type = 7)), Boundary.knots = range(x), intercept = FALSE)
.s_cb <- function(x) dlnm::crossbasis(x, lag = 7, argvar = .s_argvar(x), arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE))
.s_vcov <- function(k, escala = 1e-4, semente = 20261002) { set.seed(semente); A <- matrix(stats::rnorm(k * k), k); (crossprod(A) / k + diag(k)) * escala }

testes_segunda_etapa <- list(

  t01_d2_nos_medios = function(f) {                                  # D2, teste 1 (atributos reais)
    r <- .s_reais(); nos <- do.call(rbind, lapply(r$argvar, `[[`, "knots"))
    .s_perto(colMeans(nos), colMeans(r$nos_csv), 1e-12)               # média dos nós da 1ª etapa = média dos p10/p75/p90 do CSV
    .s_perto(colMeans(nos), r$eixo[c("p10", "p75", "p90")], 1e-12)    # = eixo médio nesses percentis
  },

  t02_d2_boundary_knots = function(f) {                              # D2, teste 2 (atributos e exposição reais)
    r <- .s_reais()
    d <- vapply(seq_along(r$argvar), function(j) max(abs(r$argvar[[j]]$Boundary.knots - range(r$x[[j]]))), 0)
    .T3$t02 <- max(d); if (max(d) > 1e-12) stop("Boundary.knots diferentes do range das 4.505 linhas: ", format(max(d)))
  },

  t03_d2_curva_contra_crossreduce = function(f) {                    # curva() contra crossreduce, mesma argvar (não é o teste 3 da errata da D6)
    r <- .s_reais(); set.seed(20261001); dmax <- 0
    for (j in seq_along(r$argvar)) {
      cb <- dlnm::crossbasis(r$x[[j]], lag = 7, argvar = r$argvar[[j]], arglag = r$arglag[[j]])
      c16 <- stats::rnorm(16, 0, 0.01); V16 <- .s_vcov(16, 1e-5, 20261000 + j)
      at <- unname(r$grade[j, ]); cen <- unname(r$grade[j, "p50"])
      cr <- dlnm::crossreduce(cb, coef = c16, vcov = V16, model.link = "log", type = "overall", cen = cen, at = at)
      cv <- f$curva(stats::coef(cr), stats::vcov(cr), r$argvar[[j]], at, cen)
      dmax <- max(dmax, abs(cv$logrr - log(cr$RRfit)), abs(cv$ep - (log(cr$RRhigh) - log(cr$RRfit)) / stats::qnorm(0.975)),
                  abs(log(cv$rr_li) - log(cr$RRlow)), abs(log(cv$rr_ls) - log(cr$RRhigh)))                     # IC 95% do RR (desvio 74)
    }
    .T3$t03 <- dmax; if (dmax > 1e-10) stop("curva() difere do crossreduce com 16 coeficientes: ", format(dmax))
  },

  t04_base_combinada = function(f) {                                 # média (não mediana), erros, curva com fronteiras explícitas
    av <- lapply(list(c(18, 25, 27), c(19, 26, 28), c(20, 27, 29), c(24, 30, 33)), function(k) list(fun = "ns", knots = k, Boundary.knots = c(k[1] - 8, k[3] + 4), intercept = FALSE))
    b <- f$base_combinada(av)
    .s_perto(b$knots, colMeans(do.call(rbind, lapply(av, `[[`, "knots"))), 1e-12)
    .s_perto(b$Boundary.knots, colMeans(do.call(rbind, lapply(av, `[[`, "Boundary.knots"))), 1e-12)
    if (max(abs(b$knots - apply(do.call(rbind, lapply(av, `[[`, "knots")), 2, stats::median))) < 0.1) stop("caso não separa média de mediana")
    .s_erro(function() f$base_combinada(c(av[1:2], list(modifyList(av[[3]], list(fun = "bs"))))), "fun")
    .s_erro(function() f$base_combinada(c(av[1:2], list(modifyList(av[[3]], list(knots = c(1, 2)))))), "número de nós")
    .s_erro(function() f$base_combinada(c(av[1:2], list(modifyList(av[[3]], list(intercept = TRUE))))), "intercept")
    x <- seq(12, 34, 0.5); cf <- c(0.02, -0.01, 0.03, 0.05); V <- .s_vcov(4)
    man <- unclass(do.call(dlnm::onebasis, c(list(x = x), list(fun = "ns", knots = colMeans(do.call(rbind, lapply(av, `[[`, "knots"))),
                                                               Boundary.knots = colMeans(do.call(rbind, lapply(av, `[[`, "Boundary.knots"))), intercept = FALSE))))
    manc <- unclass(do.call(dlnm::onebasis, c(list(x = 24), list(fun = "ns", knots = colMeans(do.call(rbind, lapply(av, `[[`, "knots"))),
                                                                Boundary.knots = colMeans(do.call(rbind, lapply(av, `[[`, "Boundary.knots"))), intercept = FALSE))))
    .s_perto(f$curva(cf, V, b, x, 24)$logrr, drop(sweep(man, 2, manc[1, ]) %*% cf), 1e-12)
  },

  t06_tmr = function(f) {                                            # busca, fronteira, grade com x_sup, bootstrap
    av <- list(fun = "poly", degree = 2, scale = 1, intercept = FALSE)        # curva quadrática: b·x + a·x², mínimo em −b/(2a)
    cf <- c(-0.5, 0.01)                                                        # mínimo em 25 °C
    bt <- f$busca_tmr(cf, av, 15, 35, 18, 32, 25); if (abs(bt$tmr - 25) >= 0.1 || bt$fronteira) stop("mínimo interior não achado")
    if (!identical(bt$p50, 25)) stop("busca_tmr devolveu o p50 errado: ", format(bt$p50))            # desvio 75
    bm <- f$busca_tmr(c(0.1, 0), av, 15, 35, 18, 32, 25)                       # monótona crescente: fronteira no x_inf
    if (!bm$fronteira || abs(bm$tmr - 15) > 1e-12 || abs(bm$tmr_p10_p90 - 18) > 1e-12) stop("curva monótona: fronteira ou busca p10–p90 errada")
    g <- f$grade_tmr(15, 34.97); if (abs(g[length(g)] - 34.97) > 1e-12) stop("grade sem o x_sup")
    b1 <- f$boot_tmr(cf, .s_vcov(2, 1e-8), av, 15, 35, i = 3); b2 <- f$boot_tmr(cf, .s_vcov(2, 1e-8), av, 15, 35, i = 3)
    if (!identical(b1$tmr_sim, b2$tmr_sim)) stop("boot_tmr não reprodutível com a mesma semente")
    b0 <- f$boot_tmr(cf, diag(1e-20, 2), av, 15, 35, i = 3); if (diff(b0$ic) > 1e-6) stop("IC com V ≈ 0 não colapsa: ", format(diff(b0$ic)))
    V <- matrix(c(4e-4, -1e-5, -1e-5, 4e-7), 2)                                 # vcov real de (b, a), positiva-definida
    bq <- f$boot_tmr(cf, V, av, 15, 35, i = 3)
    grad <- c(-1 / (2 * cf[2]), cf[1] / (2 * cf[2]^2)); ep_delta <- sqrt(drop(t(grad) %*% V %*% grad))
    .T3$t06 <- c(dp_boot = stats::sd(bq$tmr_sim), ep_delta = ep_delta, largura = diff(bq$ic))
    if (diff(bq$ic) <= 0 || abs(stats::sd(bq$tmr_sim) / ep_delta - 1) > 0.2) stop("bootstrap da quadrática: DP ", format(stats::sd(bq$tmr_sim)), " × delta ", format(ep_delta))
    .s_perto(bq$ic, stats::quantile(bq$tmr_sim, c(0.025, 0.975), type = 7, names = FALSE), 0)          # IC = percentis 2,5 e 97,5 (desvio 74)
    cub <- list(fun = "poly", degree = 3, scale = 1, intercept = FALSE)       # 0,001·(x − 28)²(x − 10): mínimo global no x_inf = 8, local em 28
    b3 <- f$busca_tmr(c(1.344, -0.066, 0.001), cub, 8, 35, 12, 32, 20)
    if (!b3$fronteira || abs(b3$tmr - 8) > 1e-12 || abs(b3$tmr_p10_p90 - 28) > 0.1) stop("busca entre p10 e p90 errada: ", format(b3$tmr_p10_p90))
    bn <- f$boot_tmr(cf, matrix(c(1, 2, 2, 1), 2), av, 15, 35, i = 3)
    if (!all(is.na(bn$ic)) || is.na(bn$motivo)) stop("vcov não positiva-definida deveria dar IC NA com motivo")
  },

  t06b_fronteira_pelo_indice = function(f) {                         # complemento C3: índice, nunca == em °C
    av <- list(fun = "poly", degree = 2, scale = 1, intercept = FALSE)
    b <- f$busca_tmr(c(-0.1, 0), av, 20.4, 30.3, 21, 29, 25)                   # decrescente: mínimo no fim da grade (30,2999…)
    if (!isTRUE(b$fronteira)) stop("fronteira no fim da grade não detectada")
  },

  t07_estabilidade_mixmeta = function(f) {                           # sequência unstr → diag → ml; isFALSE(converged)
    set.seed(20261001); Y <- matrix(stats::rnorm(26 * 4, 0.05, 0.05), 26); S <- lapply(1:26, function(i) diag(0.002, 4))
    md <- data.frame(media = stats::rnorm(26, 25, 3), amplitude = stats::rnorm(26, 10, 2))
    real <- function(formula, S, data, method, bscov) do.call(mixmeta::mixmeta, list(formula, S = S, data = data, method = method, bscov = bscov))   # do.call: a fórmula vai como valor
    st1 <- function(formula, S, data, method, bscov) { m <- real(formula, S = S, data = data, method = method, bscov = bscov); if (bscov == "unstr") m$converged <- FALSE; m }
    r1 <- f$meta_curva(Y, S, md, ajusta = st1); if (r1$status != "ok" || r1$metodo != "reml" || r1$bscov != "diag") stop("não convergência: não caiu em reml/diag")
    st2 <- function(formula, S, data, method, bscov) { if (method == "reml") stop("erro simulado"); real(formula, S = S, data = data, method = method, bscov = bscov) }
    r2 <- f$meta_curva(Y, S, md, ajusta = st2); if (r2$status != "ok" || r2$metodo != "ml" || r2$bscov != "diag") stop("erro: não caiu em ml/diag")
    st3 <- function(formula, S, data, method, bscov) { m <- real(formula, S = S, data = data, method = method, bscov = bscov); m$converged <- NULL; m }
    r3 <- f$meta_curva(Y, S, md, ajusta = st3); if (r3$status != "ok" || r3$bscov != "unstr") stop("ajuste sem o campo converged foi tratado como falha (deve ser isFALSE)")
    r4 <- f$meta_curva(Y, S, md, ajusta = function(...) stop("sempre falha")); if (r4$status != "falhou" || length(r4$tentativas) != 3) stop("três falhas: status ou tentativas")
  },

  t06c_semente_bootstrap_por_concentracao = function(f) {            # complemento C1, item 4: 20261001 + i no bootstrap (desvio 74)
    av <- list(fun = "poly", degree = 2, scale = 1, intercept = FALSE); cf <- c(-0.5, 0.01); V <- matrix(c(4e-4, -1e-5, -1e-5, 4e-7), 2)
    b5 <- f$boot_tmr(cf, V, av, 15, 35, i = 5)
    set.seed(20261006, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
    sm <- cf + t(chol(V)) %*% matrix(stats::rnorm(2 * 1000), 2); g <- seq(15, 35, by = 0.1)                     # grade à mão (desvio 75)
    tm <- g[apply(sm, 2, function(b) which.min(b[1] * g + b[2] * g^2))]
    if (!identical(b5$tmr_sim, tm)) stop("boot_tmr(i = 5) diferente do sorteio à mão com a semente 20261006")
    if (identical(b5$tmr_sim, f$boot_tmr(cf, V, av, 15, 35, i = 6)$tmr_sim)) stop("concentrações diferentes com os mesmos sorteios")
    # mínimo em 40: decrescente em [15; 34,97], TMR no x_sup, que não é múltiplo de 0,1; sorteios na grade da estimativa (D4(a) e (i); desvio 75)
    cfd <- c(-0.8, 0.01); bd <- f$boot_tmr(cfd, V, av, 15, 34.97, i = 5); gm <- c(seq(15, 34.97, by = 0.1), 34.97)
    set.seed(20261006, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
    sd5 <- cfd + t(chol(V)) %*% matrix(stats::rnorm(2 * 1000), 2); td <- gm[apply(sd5, 2, function(b) which.min(b[1] * gm + b[2] * gm^2))]
    if (!identical(bd$tmr_sim, td)) stop("boot_tmr fora da grade da estimativa (x_sup não múltiplo de 0,1)")
    est <- f$busca_tmr(cfd, av, 15, 34.97, 18, 32, 25)$tmr
    if (abs(est - 34.97) > 1e-12 || est < bd$ic[1] || est > bd$ic[2]) stop("IC do bootstrap exclui a estimativa na fronteira: ", format(est), " × ", paste(format(bd$ic), collapse = "–"))
  },

  t07c_q_i2_wald_predicao_blup = function(f) {                       # contas à mão (desvio 74)
    set.seed(20261001); n <- 26; k <- 4
    md <- data.frame(media = stats::rnorm(n, 25, 3), amplitude = stats::rnorm(n, 10, 2))
    S <- lapply(seq_len(n), function(i) .s_vcov(k, 0.002, 20261100 + i))
    Y <- t(vapply(seq_len(n), function(i) c(0.05, 0.02, 0.08, 0.03) + 0.004 * (md$media[i] - 25) + stats::rnorm(k, 0, 0.06), numeric(k)))
    r <- f$meta_curva(Y, S, md); if (r$status != "ok") stop("meta_curva falhou")
    qgls <- function(X) { p <- ncol(X); W <- lapply(S, solve); A <- matrix(0, p * k, p * k); bb <- numeric(p * k)
      Xi <- lapply(seq_len(n), function(i) kronecker(t(X[i, ]), diag(k)))       # coeficientes por termo, depois por desfecho (y1.termo…)
      for (i in seq_len(n)) { A <- A + t(Xi[[i]]) %*% W[[i]] %*% Xi[[i]]; bb <- bb + t(Xi[[i]]) %*% W[[i]] %*% Y[i, ] }
      be <- solve(A, bb); Q <- sum(vapply(seq_len(n), function(i) { e <- Y[i, ] - Xi[[i]] %*% be; drop(t(e) %*% W[[i]] %*% e) }, 0)); df <- n * k - p * k
      c(Q = Q, df = df, I2 = max(0, (Q - df) / Q) * 100) }
    hr <- qgls(cbind(1, md$media, md$amplitude)); ht <- qgls(matrix(1, n, 1))
    .s_perto(c(r$heterogeneidade$residual$Q, r$heterogeneidade$residual$df, r$heterogeneidade$residual$I2), hr, 1e-8, rel = TRUE)
    .s_perto(c(r$heterogeneidade$total$Q, r$heterogeneidade$total$df, r$heterogeneidade$total$I2), ht, 1e-8, rel = TRUE)
    for (t in c("media", "amplitude")) { ind <- grep(paste0("\\.", t, "$"), names(r$coef_meta)); b <- r$coef_meta[ind]
      w <- drop(t(b) %*% solve(r$vcov_meta[ind, ind]) %*% b); wl <- r$wald[r$wald$termo == t, ]
      .s_perto(c(wl$estatistica, wl$gl, wl$p), c(w, length(ind), stats::pchisq(w, length(ind), lower.tail = FALSE)), 1e-10, rel = TRUE) }
    xb <- c(1, mean(md$media), mean(md$amplitude)); Xb <- kronecker(t(xb), diag(k))
    .s_perto(r$pred_media$coef, drop(Xb %*% r$coef_meta), 1e-12); .s_perto(r$pred_media$vcov, Xb %*% r$vcov_meta %*% t(Xb), 1e-15)
    Yd <- Y; m <- mixmeta::mixmeta(Yd ~ media + amplitude, S = S, data = md, method = "reml", bscov = "unstr"); bd <- mixmeta::blup(m, vcov = TRUE)
    .s_perto(unlist(lapply(r$blup, `[[`, "coef")), unlist(lapply(bd, `[[`, "blup")), 1e-10)
    .s_perto(unlist(lapply(r$blup, `[[`, "vcov")), unlist(lapply(bd, `[[`, "vcov")), 1e-12)
    if (r$bscov != "unstr") stop("caso do t07c devia convergir em reml/unstr"); .s_perto(r$Psi, m$Psi, 1e-12)      # Ψ do modelo com metapreditores (desvio 75)
  },

  t07b_coeficientes_nulos = function(f) {                            # complemento C3: max(abs(coef)) > 1e-10 antes do mixmeta
    set.seed(20261001); Y <- matrix(stats::rnorm(26 * 4, 0.05, 0.05), 26); Y[5, ] <- 0; S <- lapply(1:26, function(i) diag(0.002, 4))
    md <- data.frame(media = stats::rnorm(26, 25, 3), amplitude = stats::rnorm(26, 10, 2))
    .s_erro(function() f$meta_curva(Y, S, md), "nulos")
  },

  t08_attrdl = function(f) {                                         # D1; D4(f), (g), (h); complemento C1 e C2
    attrdl <- .R3$attrdl; if (is.null(attrdl)) stop("attrdl (.R3$attrdl) ausente")
    n <- 1100; x <- .s_temp(n); datas <- as.Date("2015-01-01") + seq_len(n) - 1; cb <- .s_cb(x)
    set.seed(20261001); cases <- stats::rpois(n, 30); cases[1:7] <- NA                   # 7 dias de aquecimento
    c16 <- c(0.01, 0.002, -0.004, 0.003, 0.02, 0.004, -0.002, 0.001, 0.015, 0.003, -0.003, 0.002, 0.03, 0.006, -0.005, 0.004)
    V16 <- .s_vcov(16, 1e-6); tmr <- 22; p <- stats::quantile(x, c(.025, .975), type = 7, names = FALSE)
    cr <- dlnm::crossreduce(cb, coef = c16, vcov = V16, model.link = "log", type = "overall", cen = tmr); c4 <- unname(stats::coef(cr)); V4 <- unname(stats::vcov(cr))
    jw <- 8:n                                                                              # janela
    # (a) reduzidos + backward e 16 coeficientes + forward: recusados antes da attrdl (desvio 74); erro dentro da attrdl capturado (stub)
    ra <- f$fracao_atribuivel("backward", x, cases, datas, cb, c4, V4, tmr, p[1], p[2], 1, attrdl, nsim = 50)
    if (ra$status != "falhou" || !grepl("backward exige", ra$mensagem)) stop("(a) reduzidos no backward deviam ser recusados")
    r16 <- f$fracao_atribuivel("principal", x[jw], cases[jw], datas[jw], cb, c16, V16, tmr, p[1], p[2], 1, attrdl, nsim = 20)
    if (r16$status != "falhou" || !grepl("forward \\(principal e ponte\\) exige", r16$mensagem)) stop("(a) forward com 16 coeficientes devia ser recusado")
    rn5 <- f$fracao_atribuivel("backward", x, cases, datas, cb, c16, V16, tmr, p[1], p[2], 1, attrdl, nsim = 20, n_aquec = 5)
    if (rn5$status != "falhou" || !grepl("n_aquec diferente", rn5$mensagem)) stop("(a) n_aquec diferente do lag devia ser recusado")
    cn <- cases[jw]; cn[300] <- NA; rna <- f$fracao_atribuivel("principal", x[jw], cn, datas[jw], cb, c4, V4, tmr, p[1], p[2], 1, attrdl, nsim = 20)
    if (rna$status != "falhou" || !grepl("forward: cases com NA", rna$mensagem)) stop("(a) forward com NA nos cases devia ser recusado")   # desvio 75
    re <- f$fracao_atribuivel("principal", x[jw], cases[jw], datas[jw], cb, c4, V4, tmr, p[1], p[2], 1, function(...) stop("erro simulado"), nsim = 20)
    if (re$status != "falhou" || !grepl("erro na attrdl: erro simulado", re$mensagem)) stop("(a) erro dentro da attrdl não foi capturado")
    # (b) forward: AN de cada componente = cálculo à mão
    rf <- f$fracao_atribuivel("principal", x[jw], cases[jw], datas[jw], cb, c4, V4, tmr, p[1], p[2], 1, attrdl, nsim = 200)
    if (rf$status != "ok") stop("(b) forward falhou: ", rf$mensagem)
    av <- attr(cb, "argvar"); bc <- unclass(do.call(dlnm::onebasis, c(list(x = tmr), av)))[1, ]
    cbar <- vapply(seq_along(jw), function(t) if (t + 7 <= length(jw)) mean(cases[jw][t:(t + 7)]) else NA_real_, 0)
    mao <- function(rg) { xx <- x[jw]; if (!is.null(rg)) xx[xx < rg[1] | xx > rg[2]] <- tmr
      af <- 1 - exp(-drop(sweep(unclass(do.call(dlnm::onebasis, c(list(x = xx), av))), 2, bc) %*% c4)); an <- af * cbar; ok <- !is.na(an)
      sum(an[ok]) / sum(cbar[ok]) * sum(cases[jw]) }
    comp <- list(total = NULL, calor = c(tmr, Inf), frio = c(-Inf, tmr), calor_extremo = c(max(p[2], tmr), Inf), frio_extremo = c(-Inf, min(p[1], tmr)))   # D4(h), literais
    .s_perto(rf$componentes$an, vapply(comp, mao, 0), 1e-8)
    eci <- t(apply(rf$sims, 2, stats::quantile, c(0.025, 0.975), type = 7, names = FALSE))
    .s_perto(c(rf$componentes$an_li, rf$componentes$an_ls), c(eci[rf$componentes$componente, 1], eci[rf$componentes$componente, 2]), 0)
    .s_perto(c(rf$componentes$af, rf$componentes$af_li, rf$componentes$af_ls), c(rf$componentes$an, rf$componentes$an_li, rf$componentes$an_ls) / sum(cases[jw]), 1e-15)   # desvio 75
    rp <- f$fracao_atribuivel("ponte", x[jw], cases[jw], datas[jw], cb, c4, V4, tmr, p[1], p[2], 1, attrdl, nsim = 200)   # ponte = forward com os mesmos reduzidos
    if (rp$status != "ok" || rp$dir != "forw") stop("ponte devia ser forward"); .s_perto(rp$componentes$an, rf$componentes$an, 0); .s_perto(rp$sims, rf$sims, 0)
    # (c) forward: calor + frio = total, na estimativa e em cada simulação
    a <- setNames(rf$componentes$an, rf$componentes$componente); .s_perto(a["calor"] + a["frio"], a["total"], 1e-8)
    .s_perto(rf$sims[, "calor"] + rf$sims[, "frio"], rf$sims[, "total"], 1e-8)
    # (d) curva crescente com a TMR no p1 sintético (= mínimo da série): calor > 0 e frio = 0
    x2 <- x[jw]; m0 <- min(x2); x2[order(x2)[1:ceiling(0.02 * length(x2))]] <- m0                # p1 = mínimo
    cbm <- .s_cb(c(x[1:7], x2))                                                                # curva crescente: projeção de 0,02·(x − mínimo)
    avm <- attr(cbm, "argvar"); cm <- solve(crossprod(unclass(do.call(dlnm::onebasis, c(list(x = sort(x2)), avm)))), crossprod(unclass(do.call(dlnm::onebasis, c(list(x = sort(x2)), avm))), 0.02 * (sort(x2) - m0)))
    p1 <- stats::quantile(x2, 0.01, type = 7, names = FALSE); if (abs(p1 - m0) > 1e-12) stop("caso (d) mal montado: p1 ≠ mínimo")
    rd <- f$fracao_atribuivel("principal", x2, cases[jw], datas[jw], cbm, drop(cm), diag(1e-8, 4), p1, p[1], p[2], 1, attrdl, nsim = 20)
    ad <- setNames(rd$componentes$an, rd$componentes$componente)
    if (!(ad["calor"] > 0) || abs(ad["frio"]) > 1e-12) stop("(d) calor ", format(ad["calor"]), " e frio ", format(ad["frio"]))
    # (e) exposição constante na série inteira (nós e Boundary.knots explícitos; desvio 72c): forward = backward = 1 − exp(−f(x))
    xc <- rep(25, n); cbc <- dlnm::crossbasis(xc, lag = 7, argvar = .s_argvar(x), arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE))
    crc <- dlnm::crossreduce(cbc, coef = c16, vcov = V16, model.link = "log", type = "overall", cen = tmr)
    afv <- 1 - exp(-drop(sweep(unclass(do.call(dlnm::onebasis, c(list(x = 25), attr(cbc, "argvar")))), 2, unclass(do.call(dlnm::onebasis, c(list(x = tmr), attr(cbc, "argvar"))))[1, ]) %*% stats::coef(crc)))
    ef <- f$fracao_atribuivel("principal", xc[jw], cases[jw], datas[jw], cbc, unname(stats::coef(crc)), unname(stats::vcov(crc)), tmr, p[1], p[2], 1, attrdl, nsim = 20)
    eb <- f$fracao_atribuivel("backward", xc, cases, datas, cbc, c16, V16, tmr, p[1], p[2], 1, attrdl, nsim = 20)
    .s_perto(ef$componentes$af[1], afv, 1e-8); .s_perto(eb$componentes$af[1], afv, 1e-8)
    # (f) mesma semente nos componentes; concentrações diferentes, sorteios independentes
    r1 <- f$fracao_atribuivel("principal", x[jw], cases[jw], datas[jw], cb, c4, V4, tmr, p[1], p[2], 1, attrdl, nsim = 1000)
    r2 <- f$fracao_atribuivel("principal", x[jw], cases[jw], datas[jw], cb, c4, V4, tmr, p[1], p[2], 2, attrdl, nsim = 1000)
    rr <- stats::cor(r1$sims[, "total"], r2$sims[, "total"]); .T3$t08_cor <- rr
    if (abs(rr) >= 0.15) stop("(f) concentrações 1 e 2 com sorteios correlacionados: r = ", format(rr))
    # (g) denominador: só eventos da janela; backward exige NA no aquecimento
    rb <- f$fracao_atribuivel("backward", x, cases, datas, cb, c16, V16, tmr, p[1], p[2], 1, attrdl, nsim = 50)
    if (rb$status != "ok" || rb$denominador != sum(cases[jw])) stop("(g) denominador do backward diferente dos eventos da janela")
    cw <- cases; cw[1:7] <- 30
    if (f$fracao_atribuivel("backward", x, cw, datas, cb, c16, V16, tmr, p[1], p[2], 1, attrdl, nsim = 50)$status != "falhou") stop("(g) eventos no aquecimento deviam ser recusados")
    .T3$t08_backward_dif <- unname(setNames(rb$componentes$an, rb$componentes$componente)["total"] - sum(setNames(rb$componentes$an, rb$componentes$componente)[c("calor", "frio")]))
    # (h) TMR acima do p97,5: o calor extremo não pega dias abaixo da TMR (= calor) e não fica negativo
    th <- unname(stats::quantile(x[jw], 0.99, type = 7))
    cmh <- solve(crossprod(unclass(do.call(dlnm::onebasis, c(list(x = sort(x)), attr(cb, "argvar"))))), crossprod(unclass(do.call(dlnm::onebasis, c(list(x = sort(x)), attr(cb, "argvar")))), 0.02 * (sort(x) - min(x))))
    rh <- f$fracao_atribuivel("principal", x[jw], cases[jw], datas[jw], cb, drop(cmh), diag(1e-8, 4), th, p[1], p[2], 1, attrdl, nsim = 20)
    ah <- setNames(rh$componentes$an, rh$componentes$componente)
    if (ah["calor_extremo"] < -1e-12 || abs(ah["calor_extremo"] - ah["calor"]) > 1e-8) stop("(h) calor extremo ", format(ah["calor_extremo"]), " × calor ", format(ah["calor"]))
    # (i) TMR abaixo do p2,5: o frio extremo não pega dias acima da TMR (= frio) e não fica negativo (desvio 74)
    tl <- unname(stats::quantile(x[jw], 0.01, type = 7)); if (!(tl < p[1])) stop("caso (i) mal montado")
    cml <- solve(crossprod(unclass(do.call(dlnm::onebasis, c(list(x = sort(x)), attr(cb, "argvar"))))), crossprod(unclass(do.call(dlnm::onebasis, c(list(x = sort(x)), attr(cb, "argvar")))), -0.02 * (sort(x) - min(x))))   # decrescente e 0 na fronteira inferior (cabe na base ns sem intercepto)
    rl <- f$fracao_atribuivel("principal", x[jw], cases[jw], datas[jw], cb, drop(cml), diag(1e-8, 4), tl, p[1], p[2], 1, attrdl, nsim = 20)
    al <- setNames(rl$componentes$an, rl$componentes$componente)
    if (al["frio_extremo"] < -1e-12 || abs(al["frio_extremo"] - al["frio"]) > 1e-8) stop("(i) frio extremo ", format(al["frio_extremo"]), " × frio ", format(al["frio"]))
    # (j) simulações e AN iguais à attrdl chamada direto com a semente 20261001 + i (C1), no forward e no backward (desvio 75)
    s5f <- f$fracao_atribuivel("principal", x[jw], cases[jw], datas[jw], cb, c4, V4, tmr, p[1], p[2], 5, attrdl, nsim = 100)
    s5b <- f$fracao_atribuivel("backward", x, cases, datas, cb, c16, V16, tmr, p[1], p[2], 5, attrdl, nsim = 100)
    if (s5f$status != "ok" || s5b$status != "ok") stop("(j) fracao_atribuivel falhou")
    sem5 <- function() set.seed(20261006, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
    for (cc in c("total", "calor", "frio_extremo")) { rg <- comp[[cc]]
      sem5(); dfw <- attrdl(x[jw], cb, cases[jw], coef = c4, vcov = V4, type = "an", dir = "forw", tot = TRUE, cen = tmr, range = rg, sim = TRUE, nsim = 100)
      sem5(); dbk <- attrdl(x, cb, cases, coef = c16, vcov = V16, type = "an", dir = "back", tot = TRUE, cen = tmr, range = rg, sim = TRUE, nsim = 100)
      abk <- attrdl(x, cb, cases, coef = c16, vcov = V16, type = "an", dir = "back", tot = TRUE, cen = tmr, range = rg, sim = FALSE)
      .s_perto(s5f$sims[, cc], dfw, 0); .s_perto(s5b$sims[, cc], dbk, 0)
      .s_perto(s5b$componentes$an[s5b$componentes$componente == cc], abk, 1e-12) }
    if (max(abs(s5b$sims[, "total"] - s5f$sims[, "total"])) < 1e-6) stop("(j) backward e forward com as mesmas simulações")
    # complemento C2: datas consecutivas e tamanho
    dd <- datas[jw]; dd[100] <- dd[100] + 1
    if (f$fracao_atribuivel("principal", x[jw], cases[jw], dd, cb, c4, V4, tmr, p[1], p[2], 1, attrdl, nsim = 20)$status != "falhou") stop("datas não consecutivas deviam ser recusadas")
    if (f$fracao_atribuivel("principal", x[jw][-1], cases[jw], datas[jw], cb, c4, V4, tmr, p[1], p[2], 1, attrdl, nsim = 20)$status != "falhou") stop("tamanhos diferentes deviam ser recusados")
  },

  t09_vcov_gnm_com_phi = function(f) {                               # tautológico pela D6, 2.2 (vcov.gnm l. 76 e summary.gnm l. 85); vale testa_ajusta_dlnm_d1_errata.R (a85c388)
    set.seed(20261001); d <- data.frame(y = stats::rpois(600, 12), x1 = stats::rnorm(600), x2 = stats::rnorm(600), e = factor(rep(1:30, each = 20)))
    m <- gnm::gnm(y ~ x1 + x2, eliminate = e, family = stats::quasipoisson, data = d, verbose = FALSE)
    .s_perto(stats::vcov(m), summary(m)$cov.scaled, 1e-10, rel = TRUE)
  },

  t10_lagresposta = function(f) {                                    # reduz_var: à mão; depende do cen; fronteira → p50
    x <- .s_temp(800); cb <- .s_cb(x); set.seed(20261001); c16 <- stats::rnorm(16, 0, 0.01); V16 <- .s_vcov(16, 1e-6)
    valor <- 30; cen <- 22; rv <- f$reduz_var(cb, c16, V16, valor, cen)
    av <- attr(cb, "argvar"); al <- attr(cb, "arglag")
    dv <- unclass(do.call(dlnm::onebasis, c(list(x = valor), av)))[1, ] - unclass(do.call(dlnm::onebasis, c(list(x = cen), av)))[1, ]
    BL <- unclass(do.call(dlnm::onebasis, c(list(x = 0:7), al)))
    mao <- vapply(0:7, function(l) sum(outer(dv, BL[l + 1, ]) * matrix(c16, 4, 4, byrow = TRUE)), 0)   # coeficientes v1.l1…v4.l4
    .s_perto(f$curva_lag(rv$coef, rv$vcov, al, 0:7)$logrr, mao, 1e-10)
    crv <- dlnm::crossreduce(cb, coef = c16, vcov = V16, model.link = "log", type = "var", value = valor, cen = cen); cl <- f$curva_lag(rv$coef, rv$vcov, al, 0:7)
    if (length(crv$RRfit) != 8) stop("crossreduce(type = 'var') sem os lags 0 a 7")
    .s_perto(c(cl$ep, log(cl$rr_li), log(cl$rr_ls)), c((log(crv$RRhigh) - log(crv$RRfit)) / stats::qnorm(0.975), log(crv$RRlow), log(crv$RRhigh)), 1e-10)   # desvio 75
    cd <- f$curva_lag(rv$coef, rv$vcov, al); if (length(cd$lag) != 71 || max(abs(cd$lag - (0:70) / 10)) > 1e-12) stop("curva_lag sem os lags 0 a 7 de 0,1 em 0,1 (D4(b))")
    r0 <- f$reduz_var(cb, c16, V16, valor, valor); if (max(abs(r0$coef)) > 1e-12) stop("cen = valor deveria zerar os coeficientes")
    r2 <- f$reduz_var(cb, c16, V16, valor, 25); if (max(abs(r2$coef - rv$coef)) < 1e-6) stop("trocar o cen não mudou os coeficientes")
    so <- f$soma_lags(rv$coef, rv$vcov, al)                                  # soma dos lags 0–7 = curva geral (overall) no mesmo valor e centro (desvio 74)
    cro <- dlnm::crossreduce(cb, coef = c16, vcov = V16, model.link = "log", type = "overall", cen = cen, at = valor)
    .s_perto(c(so[["logrr"]], so[["ep"]]), c(log(cro$RRfit), (log(cro$RRhigh) - log(cro$RRfit)) / stats::qnorm(0.975)), 1e-10)
    .s_perto(log(c(so[["rr_li"]], so[["rr_ls"]])), log(c(cro$RRlow, cro$RRhigh)), 1e-10)                                  # desvio 75
    .s_perto(f$posicao_no_eixo(25, c(10, 20, 30), c(0.1, 0.5, 0.9)), 0.7, 1e-12)
    if (!is.na(f$posicao_no_eixo(35, c(10, 20, 30), c(0.1, 0.5, 0.9)))) stop("posição fora do eixo deveria ser NA (sem extrapolar)")   # desvio 75
    tref <- .s_temp(4749); if (abs(f$centro_lagresposta(tref, 0.3, TRUE) - stats::quantile(tref, 0.5, type = 7, names = FALSE)) > 1e-12) stop("fronteira: centro deveria ser o p50")
    if (abs(f$centro_lagresposta(tref, 0.3, FALSE) - stats::quantile(tref, 0.3, type = 7, names = FALSE)) > 1e-12) stop("centro fora da fronteira deveria ser o quantil q")
  },

  t11_ordem_e_semente = function(f) {                                # complemento C1: ordem travada e kind explícito
    r <- .s_reais(); f$confere_ordem(r$codigos)
    .s_erro(function() f$confere_ordem(sort(r$codigos)), "ordem")
    if (!identical(f$indice_concentracao(r$codigos), seq_len(26))) stop("índices diferentes de 1 a 26")
    .s_erro(function() f$indice_concentracao(c(r$codigos[3], "9999999")), "fora da ordem")                               # desvio 75
    if (f$semente(0) != 20261001L || f$semente(26) != 20261027L) stop("semente(i) ≠ 20261001 + i")
    for (v in list(27, 2.5, -1)) .s_erro(function() f$semente(v), "inteiro")              # i fora de 0…26 ou fracionário (desvio 74)
    if (is.null(r$attrdl_path)) stop("caminho da attrdl (.R3$attrdl_path) ausente"); .s_erro(function() f$carrega_attrdl(r$attrdl_path, strrep("0", 64)), "SHA-256")
    RNGkind("L'Ecuyer-CMRG"); f$semeia(3); k <- RNGkind(); RNGkind("Mersenne-Twister", "Inversion", "Rejection")
    if (!identical(k[1:3], c("Mersenne-Twister", "Inversion", "Rejection"))) stop("semeia() não fixou o kind: ", paste(k, collapse = "/"))
  },

  t12_serial_igual_paralelo = function(f) {                          # complemento C1, item 3
    av <- list(fun = "poly", degree = 2, scale = 1, intercept = FALSE); cf <- c(-0.5, 0.01); V <- matrix(c(4e-4, -1e-5, -1e-5, 4e-7), 2)
    RNGkind("Mersenne-Twister", "Inversion", "Rejection")
    s <- lapply(1:3, function(i) f$boot_tmr(cf, V, av, 15, 35, i = i, nsim = 300)$tmr_sim)
    RNGkind("L'Ecuyer-CMRG"); set.seed(20261001)
    p <- parallel::mclapply(1:3, function(i) f$boot_tmr(cf, V, av, 15, 35, i = i, nsim = 300)$tmr_sim, mc.cores = 2, mc.set.seed = TRUE)
    RNGkind("Mersenne-Twister", "Inversion", "Rejection")
    if (!identical(s, p)) stop("execução paralela (L'Ecuyer no processo) diferente da serial")
  },

  t13_serie_consecutiva_lag1 = function(f) {                         # complemento C2: lag 1 = data − 1, mesmo depois de estrato removido
    n <- 400; x <- .s_temp(n); datas <- as.Date("2015-01-01") + seq_len(n) - 1
    cb <- f$monta_cb(x, datas, list(fun = "lin"), list(fun = "integer"), lag = 7)
    est <- format(datas, "%Y-%m"); vazio <- unique(est)[4]; dia1 <- which(est == vazio)[length(which(est == vazio))] + 1   # 1º dia depois do estrato
    if (abs(unclass(cb)[dia1, "v1.l2"] - x[dia1 - 1]) > 1e-12) stop("lag 1 ≠ exposição da data − 1 depois do estrato removido")
    .s_erro(function() f$monta_cb(x[-50], datas[-50], list(fun = "lin"), list(fun = "integer"), lag = 7), "consecutivas")
    # a ajusta_dlnm (Fase 2) calcula a cross-basis na série completa: com um estrato vazio, coeficientes = gnm com a cross-basis completa
    set.seed(20261001); y <- stats::rpois(n, 25); y[est == vazio] <- 0
    d <- data.frame(data = datas, y = y, temp = x, janela = seq_len(n) > 7, estrato = est, dia_semana = factor(format(datas, "%u")),
                    feriado_nacional = 0L, carnaval = 0L, moveis = 0L, log_z = 0, log_w = log(0.01) + 0.01 * sin(seq_len(n) / 9))
    sp <- f$spec_agudo("y", "temp", "janela", 7, argvar = .s_argvar(x), arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE), cen = 22)
    r <- f$ajusta_dlnm(d, sp); if (r$status != "ok" || r$n$estratos_removidos != 1) stop("ajusta_dlnm: status ou estrato removido")
    cbf <- dlnm::crossbasis(x, lag = 7, argvar = sp$argvar, arglag = sp$arglag); u <- d$janela & est != vazio
    m <- gnm::gnm(y[u] ~ unclass(cbf)[u, ] + d$dia_semana[u] + d$log_w[u], eliminate = factor(est[u]), offset = d$log_z[u], family = stats::quasipoisson, verbose = FALSE)
    .s_perto(r$coef_cb, stats::coef(m)[1:16], 1e-8)
  },

  t14_grade_sem_quase_duplicata = function(f) {                      # complemento C3 (i)
    g <- f$grade_tmr(20.4, 30.3)
    if (min(diff(g)) < 0.05) stop("grade com quase-duplicata (", format(min(diff(g))), ")")
    if (abs(g[length(g)] - 30.3) > 1e-8 || length(g) != 100) stop("grade com fim ou tamanho errado: ", length(g))
  }
)
