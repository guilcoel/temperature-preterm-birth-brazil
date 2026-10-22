# testa_segunda_etapa_v11.R — testes da segunda_etapa v1.1 (Fase 4 do Artigo 1; prompt da Fase 4, seção 2, item 2;
# D15; mensagem de respostas ao plano, seção 4; A1-97). Só dado sintético. Cada teste recebe `f` (ambiente com
# segunda_etapa.R v1.1 e ajusta_dlnm.R) e para com erro se uma conferência falhar. A v1.0.1, lida da tag
# segunda_etapa-v1.0.1 por git show, vem em .REF$s10, posta por quem chama; a teste3_fonte_independente
# (codigo_compartilhado/tests/teste3_fonte_independente.R) fica no ambiente global, posta por quem chama (assim os
# mutantes B1 e B2 entram pela cópia). Referências independentes: GLS à mão, qtest de reajuste e contas por nome.
# Executor: roda_testes_fase4.R.
#   Os 2 testes da v1.0.2 (pendência A1-87(h)): ts11_v102_cen_fora_de_x (mata o mutante A2 da auditoria de 15/10: a
#   curva() centrada no ponto de x mais próximo de cen) e ts11_v102_argvar_errada (controle com nós de quantile(x_cb) e
#   com fronteiras p1–p99: a diferença tem de passar de 1e-8; mata os mutantes B1 e B2, que tiram nós ou fronteiras da
#   argvar dentro da função do teste 3).

if (!exists(".REF", inherits = FALSE)) .REF <- new.env()
.m_perto <- function(a, b, tol, rel = FALSE) {
  a <- as.numeric(a); b <- as.numeric(b)
  if (length(a) != length(b)) stop("tamanhos diferentes: ", length(a), " × ", length(b))
  d <- if (rel) max(abs(a - b) / pmax(abs(b), 1e-300)) else max(abs(a - b))
  if (!is.finite(d) || d > tol) stop("diferença ", format(d), " > ", format(tol))
  invisible(d)
}
.m_erro <- function(fun) { m <- tryCatch({ fun(); NA_character_ }, error = function(e) conditionMessage(e)); if (is.na(m)) stop("esperava erro e não houve"); invisible(m) }
.m_semeia <- function(s) set.seed(s, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
.REG <- factor(rep(c("N", "NE", "SE", "S", "CO"), c(2, 9, 8, 3, 4)))
# 26 unidades, 4 coeficientes, metapreditores média e amplitude; Ψ na unidade (psi) e, opcional, efeito de região
.m_sint <- function(semente = 20261016, psi = 1e-3, tau_reg = 0) {
  .m_semeia(semente); n <- 26L; k <- 4L
  md <- data.frame(media = stats::rnorm(n, 24, 2), amplitude = stats::rnorm(n, 12, 2)); md$xmedia <- md$media + stats::rnorm(n, 0, 1)
  md$regiao <- .REG; md$cesarea <- stats::rnorm(n, 55, 8)
  S <- lapply(seq_len(n), function(i) { A <- matrix(stats::rnorm(k * k), k); (crossprod(A) / k + diag(k)) * 2e-3 })
  beta <- rbind(c(0.1, -0.05, 0.08, 0.02), c(0.01, 0.005, -0.004, 0.003), c(-0.003, 0.002, 0.001, 0.004))
  ur <- matrix(stats::rnorm(nlevels(.REG) * k, 0, sqrt(tau_reg)), nlevels(.REG))[as.integer(.REG), , drop = FALSE]
  Y <- t(vapply(seq_len(n), function(i) drop(c(1, md$media[i] - 24, md$amplitude[i] - 12) %*% beta) + ur[i, ] +
                  MASS::mvrnorm(1, rep(0, k), S[[i]] + diag(k) * psi), numeric(k)))
  list(Y = Y, S = S, md = md)
}
# GLS multivariado de efeitos fixos à mão, na ordem do mixmeta (por termo): X_i = x_i′ ⊗ I_k
.m_gls <- function(Y, S, X) {
  k <- ncol(Y); p <- ncol(X); A <- matrix(0, p * k, p * k); bb <- numeric(p * k)
  for (i in seq_len(nrow(X))) { Xi <- X[i, , drop = FALSE] %x% diag(k); Si <- solve(S[[i]]); A <- A + t(Xi) %*% Si %*% Xi; bb <- bb + t(Xi) %*% Si %*% Y[i, ] }
  list(beta = drop(solve(A, bb)), vcov = solve(A))
}
.m_series <- function() {
  datas <- seq(as.Date("2012-01-01"), as.Date("2024-12-31"), by = "day")
  .m_semeia(20261015); t <- seq_along(datas)
  s <- 24 + 4 * sin(2 * pi * t / 365.25) + as.numeric(stats::arima.sim(list(ar = 0.7), n = length(t), sd = 1))
  jan <- datas >= as.Date("2012-04-07") & datas <= as.Date("2024-08-06")
  s[which(datas == as.Date("2012-01-20"))] <- max(s[jan]) + 1.5; s[which(datas == as.Date("2024-12-10"))] <- min(s[jan]) - 1.5
  list(serie_nos = s, x_cb = s[jan])
}
.m_t3_base <- function() {
  ss <- .m_series(); nos <- unname(stats::quantile(ss$serie_nos, c(0.10, 0.75, 0.90), type = 7))
  cb <- dlnm::crossbasis(ss$x_cb, lag = 7, argvar = list(fun = "ns", knots = nos), arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE))
  x <- unname(stats::quantile(ss$serie_nos, c(0.01, 0.05, 0.10, 0.90, 0.95, 0.99), type = 7))   # os 6 percentis do contraste
  list(ss = ss, av = attr(cb, "argvar"), x = x, cen = unname(stats::quantile(ss$serie_nos, 0.5, type = 7)), coef = c(0.02, -0.015, 0.03, 0.05))
}
.ulp <- function(x) 2^(floor(log2(abs(x))) - 52)

testes_segunda_etapa_v11 <- list(

  # regressão: as funções da v1.0 que não mudaram têm o mesmo código (deparse); a meta_curva dá identical() à v1.0.1 em
  # todos os campos, com duas fórmulas contínuas
  ts11_regressao_v10 = function(f) {
    if (is.null(.REF$s10)) stop("v1.0.1 (.REF$s10) ausente")
    for (nm in setdiff(ls(.REF$s10, all.names = TRUE), "meta_curva"))
      if (!identical(deparse(.REF$s10[[nm]]), deparse(f[[nm]]))) stop("função da v1.0 mudou de código: ", nm)
    m <- .m_sint()
    for (fm in list(~ media + amplitude, ~ media + xmedia)) {
      a <- .REF$s10$meta_curva(m$Y, m$S, m$md[, c("media", "amplitude", "xmedia")], formula = fm)
      b <- f$meta_curva(m$Y, m$S, m$md[, c("media", "amplitude", "xmedia")], formula = fm)
      if (!identical(names(a), names(b))) stop("campos da meta_curva diferentes")
      dif <- names(a)[!vapply(names(a), function(nm) identical(a[[nm]], b[[nm]]), TRUE)]
      if (length(dif)) stop("meta_curva v1.1 ≠ v1.0.1 em: ", paste(dif, collapse = ", "))
    }
  },

  # termos contínuos: índices pelo assign = índices por nome exato (regra da v1.0) e Wald idêntico
  ts11_wald_continuos = function(f) {
    m <- .m_sint(); r <- f$meta_curva(m$Y, m$S, m$md, formula = ~ media + amplitude)
    fit <- mixmeta::mixmeta(unname(m$Y) ~ media + amplitude, S = m$S, data = m$md, method = r$metodo, bscov = r$bscov)
    for (t in c("media", "amplitude")) {
      ind <- which(sub("^[^.]*\\.", "", names(stats::coef(fit))) == t); stopifnot(length(ind) == 4L)
      w <- drop(t(stats::coef(fit)[ind]) %*% solve(stats::vcov(fit)[ind, ind]) %*% stats::coef(fit)[ind])
      if (!identical(r$wald$estatistica[r$wald$termo == t], w)) stop("Wald do termo contínuo ", t, " diferente do da seleção por nome")
    }
  },

  # termo-fator (macrorregião): Wald com k × (níveis − 1) = 16 gl, igual ao à mão pelos nomes; sem predição na média;
  # controle: a v1.0.1 não aceita o fator
  ts11_fator = function(f) {
    m <- .m_sint(); r <- f$meta_curva(m$Y, m$S, m$md, formula = ~ media + amplitude + regiao)
    stopifnot(identical(r$status, "ok"), is.null(r$pred_media), identical(r$wald$termo, c("media", "amplitude", "regiao")), r$wald$gl[3] == 16L)
    ind <- grep("\\.regiao", names(r$coef_meta)); stopifnot(length(ind) == 16L)
    w <- drop(t(r$coef_meta[ind]) %*% solve(r$vcov_meta[ind, ind]) %*% r$coef_meta[ind])
    .m_perto(r$wald$estatistica[3], w, 1e-10, rel = TRUE)
    if (is.null(.REF$s10)) stop("v1.0.1 (.REF$s10) ausente")
    .m_erro(function() .REF$s10$meta_curva(m$Y, m$S, m$md, formula = ~ media + amplitude + regiao))
  },

  # efeitos fixos = GLS à mão (coeficientes e vcov); controle: com Ψ grande, o efeito fixo subestima os EP (< 0,8 dos do
  # REML) e deixa heterogeneidade (Q/gl > 2)
  ts11_meta_fixos = function(f) {
    m <- .m_sint(psi = 0); r <- f$meta_fixos(m$Y, m$S, m$md); stopifnot(identical(r$status, "ok"))
    g <- .m_gls(unname(m$Y), m$S, cbind(1, m$md$media, m$md$amplitude))
    .m_perto(r$coef_meta, g$beta, 1e-8, rel = TRUE); .m_perto(r$vcov_meta, g$vcov, 1e-10)
    stopifnot(r$wald$gl == c(4L, 4L), r$heterogeneidade$residual$df == 92)
    h <- .m_sint(psi = 0.05); rf <- f$meta_fixos(h$Y, h$S, h$md); rr <- f$meta_curva(h$Y, h$S, h$md)
    razao <- sqrt(diag(rf$vcov_meta))[1:4] / sqrt(diag(rr$vcov_meta))[1:4]
    if (!(max(razao) < 0.8 && rf$heterogeneidade$residual$Q / rf$heterogeneidade$residual$df > 2)) stop("controle sem poder: razão de EP ", format(max(razao)))
  },

  # multinível: com variância de região grande, a log-verossimilhança REML supera a do modelo de um nível em > 5 e a Ψ
  # da região é diagonal; controle: sem efeito de região, a diferença fica < 2; falha nas três tentativas → "falhou"
  ts11_meta_multinivel = function(f) {
    um_nivel <- function(m) as.numeric(stats::logLik(mixmeta::mixmeta(unname(m$Y) ~ media + amplitude, S = m$S, data = m$md, method = "reml", bscov = "unstr")))
    m <- .m_sint(psi = 2e-4, tau_reg = 0.02); r <- f$meta_multinivel(m$Y, m$S, m$md, m$md$regiao)
    stopifnot(identical(r$status, "ok"), identical(r$bscov, c("diag", "unstr")), identical(r$metodo, "reml"))
    Pr <- r$Psi[[1]]; if (max(abs(Pr[upper.tri(Pr)])) != 0) stop("Ψ da região não diagonal")
    if (!(r$logLik - um_nivel(m) > 5)) stop("multinível não supera o de um nível com variância de região grande: ", format(r$logLik - um_nivel(m)))
    m0 <- .m_sint(psi = 2e-4, tau_reg = 0); r0 <- f$meta_multinivel(m0$Y, m0$S, m0$md, m0$md$regiao)
    if (!(identical(r0$status, "ok") && r0$logLik - um_nivel(m0) < 2)) stop("controle: sem efeito de região, diferença de ", format(r0$logLik - um_nivel(m0)))
    rf <- f$meta_multinivel(m$Y, m$S, m$md, m$md$regiao, ajusta = function(...) stop("falha simulada"))
    stopifnot(identical(rf$status, "falhou"), length(rf$tentativas) == 3L)
  },

  # exploratório: contínuo centrado na média das 26; Wald com 4 gl; "sem" = residual da base (média + amplitude), não o
  # total só com intercepto; coeficientes do intercepto = os do ajuste com o termo centrado; fator com 16 gl
  ts11_meta_exploratoria = function(f) {
    m <- .m_sint(); r <- f$meta_exploratoria(m$Y, m$S, m$md, "cesarea"); stopifnot(identical(r$status, "ok"), r$wald$gl == 4L)
    if (!identical(r$centro, mean(m$md$cesarea))) stop("centro diferente da média das 26")
    b <- f$meta_curva(m$Y, m$S, m$md, formula = ~ media + amplitude)
    if (!identical(r$heterogeneidade$sem, b$heterogeneidade$residual)) stop("\"sem\" diferente do residual da base")
    if (identical(r$heterogeneidade$sem$df, b$heterogeneidade$total$df)) stop("controle: \"sem\" igual ao modelo só com intercepto")
    mc <- m$md; mc$cesarea <- mc$cesarea - mean(mc$cesarea)
    fc <- mixmeta::mixmeta(unname(m$Y) ~ media + amplitude + cesarea, S = m$S, data = mc, method = r$metodo_com, bscov = r$bscov_com)
    .m_perto(r$coef_meta[1:4], stats::coef(fc)[1:4], 1e-10)
    fu <- mixmeta::mixmeta(unname(m$Y) ~ media + amplitude + cesarea, S = m$S, data = m$md, method = r$metodo_com, bscov = r$bscov_com)
    if (!(max(abs(stats::coef(fu)[1:4] - r$coef_meta[1:4])) > 1e-6)) stop("controle sem poder: centrar não mudou o intercepto")
    .m_perto(r$heterogeneidade$com$Q, f$meta_curva(m$Y, m$S, mc, formula = ~ media + amplitude + cesarea)$heterogeneidade$residual$Q, 0)
    rr <- f$meta_exploratoria(m$Y, m$S, m$md, "regiao"); stopifnot(identical(rr$status, "ok"), rr$wald$gl == 16L, is.na(rr$centro))
  },

  # confere_meta: ajuste ok passa; status "falhou" com wald vazio para; gl diferente para; sem total para
  ts11_confere_meta = function(f) {
    m <- .m_sint(); r <- f$meta_curva(m$Y, m$S, m$md); f$confere_meta(r, c("media", "amplitude"), m$Y)
    .m_erro(function() f$confere_meta(list(status = "falhou", tentativas = "x", wald = NULL), c("media", "amplitude"), m$Y))
    # wald NULL (nrow e all dão logical(0), que passam no stopifnot) e total presente; depois da M2, a conferência dos
    # nomes também pega
    .m_erro(function() f$confere_meta(list(status = "falhou", wald = NULL, heterogeneidade = list(total = list(Q = 1))), c("media", "amplitude"), m$Y))
    # status "falhou" com wald sem a estatística e total presente (depois da M2, o tamanho da estatística também pega)
    .m_erro(function() f$confere_meta(list(status = "falhou", wald = data.frame(termo = c("media", "amplitude"), gl = c(4L, 4L)), heterogeneidade = list(total = list(Q = 1))), c("media", "amplitude"), m$Y))
    # status "ok" com wald NULL e total presente: o is.data.frame pega (auditoria da Parte A, achado 1)
    .m_erro(function() f$confere_meta(list(status = "ok", wald = NULL, heterogeneidade = list(total = list(Q = 1))), c("media", "amplitude"), m$Y))
    .m_erro(function() f$confere_meta(list(status = "falhou", wald = data.frame(termo = character(0), gl = integer(0))), c("media", "amplitude"), m$Y))
    r2 <- r; r2$wald$gl[2] <- 3L; .m_erro(function() f$confere_meta(r2, c("media", "amplitude"), m$Y))
    r3 <- r; r3$heterogeneidade$total <- NULL; .m_erro(function() f$confere_meta(r3, c("media", "amplitude"), m$Y))
    # com a M2, os casos acima deixaram de isolar o status e o is.data.frame: status "falhou" com todo o resto válido
    # (só o status pega) e wald em lista com os campos certos (nrow de lista é NULL, e NULL == 2 dá logical(0); só o
    # is.data.frame pega)
    rs <- r; rs$status <- "falhou"; .m_erro(function() f$confere_meta(rs, c("media", "amplitude"), m$Y))
    rl <- r; rl$wald <- as.list(r$wald); .m_erro(function() f$confere_meta(rl, c("media", "amplitude"), m$Y))
    # auditoria do chat de 18/10, M2: nome do termo errado, ordem trocada, estatística do Wald NA e Q total NA; cada um só
    # pela sua condição (os demais campos válidos)
    r4 <- r; r4$wald$termo[2] <- "amplitud"; .m_erro(function() f$confere_meta(r4, c("media", "amplitude"), m$Y))
    .m_erro(function() f$confere_meta(r, c("amplitude", "media"), m$Y))
    r5 <- r; r5$wald$estatistica[1] <- NA; .m_erro(function() f$confere_meta(r5, c("media", "amplitude"), m$Y))
    r6 <- r; r6$wald$estatistica[2] <- Inf; .m_erro(function() f$confere_meta(r6, c("media", "amplitude"), m$Y))
    r7 <- r; r7$heterogeneidade$total$Q <- NA_real_; .m_erro(function() f$confere_meta(r7, c("media", "amplitude"), m$Y))
    # campos ausentes (is.finite e == de NULL dão logical(0), que passa no stopifnot): só as checagens de tamanho pegam
    r8 <- r; r8$heterogeneidade$total$Q <- NULL; .m_erro(function() f$confere_meta(r8, c("media", "amplitude"), m$Y))
    r9 <- r; r9$wald$estatistica <- NULL; .m_erro(function() f$confere_meta(r9, c("media", "amplitude"), m$Y))
    r10 <- r; r10$wald$gl <- NULL; .m_erro(function() f$confere_meta(r10, c("media", "amplitude"), m$Y))
  },

  # Q por coeficiente: = qtest()$Q[-1] e df[-1] do reajuste e = conta à mão (< 1e-8); gl = 23; sem coluna p
  ts11_q_por_coeficiente = function(f) {
    m <- .m_sint(); r <- f$meta_curva(m$Y, m$S, m$md); q <- f$q_por_coeficiente(r, m$Y, m$S, m$md)
    if ("p" %in% names(q) || any(grepl("^p", names(q)))) stop("q_por_coeficiente devolve coluna p")
    stopifnot(identical(q$rotulo, rep("por coeficiente (não univariado)", 4)), all(q$gl == 23))
    fit <- mixmeta::mixmeta(unname(m$Y) ~ media + amplitude, S = m$S, data = m$md, method = r$metodo, bscov = r$bscov)
    qt <- mixmeta::qtest(fit); .m_perto(q$Q, qt$Q[-1], 0); .m_perto(q$gl, qt$df[-1], 0)
    X <- cbind(1, m$md$media, m$md$amplitude); g <- .m_gls(unname(m$Y), m$S, X); B <- matrix(g$beta, ncol = 4, byrow = TRUE)
    Qm <- vapply(1:4, function(j) sum((m$Y[, j] - X %*% B[, j])^2 / vapply(m$S, function(s) s[j, j], 0)), 0)
    .m_perto(q$Q, Qm, 1e-8, rel = TRUE)
  },

  # confere_eixo: bordas idênticas passam; 1 ulp de diferença em cada borda para; percentil NA para
  ts11_confere_eixo = function(f) {
    .m_semeia(7); e <- sort(stats::rnorm(101, 25, 4)); f$confere_eixo(e[1], e[101], e)
    x1 <- e[1] + .ulp(e[1]); if (identical(x1, e[1])) stop("1 ulp não mudou o valor")
    .m_erro(function() f$confere_eixo(x1, e[101], e)); .m_erro(function() f$confere_eixo(e[1], e[101] - .ulp(e[101]), e))
    .m_erro(function() f$confere_eixo(e[1], e[101], e, pct = c(3, NA)))
    if (!is.na(f$posicao_no_eixo(x1 - 2 * .ulp(e[1]), e, seq_along(e)))) stop("posicao_no_eixo deveria dar NA abaixo do eixo")
  },

  # decide_teste3: os cinco critérios; um caso por critério violado
  ts11_decide_teste3 = function(f) {
    r <- list(dif = 1e-12, dif_controle_p1p99 = 1e-3, dif_controle_serie = 0, dif_nos = 0, dif_fronteiras = 0); xcb <- c(10, 30); x <- c(12, 20, 28)
    d <- f$decide_teste3(r, x, xcb); stopifnot(d$ok, length(d$falhas) == 0L)
    casos <- list(list("dif", 2e-8, "dif > 1e-8"), list("dif_controle_p1p99", 5e-9, "controle p1–p99 sem poder (≤ 1e-8)"),
                  list("dif_nos", 2e-12, "dif_nos > 1e-12"), list("dif_fronteiras", 2e-12, "dif_fronteiras > 1e-12"))
    for (cs in casos) { rr <- r; rr[[cs[[1]]]] <- cs[[2]]; dd <- f$decide_teste3(rr, x, xcb); if (dd$ok || !identical(dd$falhas, cs[[3]])) stop("critério não aplicado: ", cs[[1]]) }
    dd <- f$decide_teste3(r, c(9.9, 20), xcb); if (dd$ok || !identical(dd$falhas, "grade fora de range(x_cb)")) stop("critério da grade não aplicado")
    rr <- r; rr$dif_controle_serie <- 0; if (!f$decide_teste3(rr, x, xcb)$ok) stop("controle range(serie_nos) não deveria decidir")
    # limiares exatos (auditoria da Parte A, Nota 3): dif = 1e-8 passa; controle = 1e-8 não tem poder; dif_nos e
    # dif_fronteiras = 1e-12 passam
    rr <- r; rr$dif <- 1e-8; if (!f$decide_teste3(rr, x, xcb)$ok) stop("dif = 1e-8 deveria passar")
    rr <- r; rr$dif_controle_p1p99 <- 1e-8; if (f$decide_teste3(rr, x, xcb)$ok) stop("controle = 1e-8 deveria falhar")
    rr <- r; rr$dif_nos <- 1e-12; rr$dif_fronteiras <- 1e-12; if (!f$decide_teste3(rr, x, xcb)$ok) stop("dif_nos e dif_fronteiras = 1e-12 deveriam passar")
  },

  # v1.0.2 (1): teste 3 com x = os 6 percentis e cen fora de x (a mediana): a curva() bate com a fonte independente
  ts11_v102_cen_fora_de_x = function(f) {
    b <- .m_t3_base(); if (!(min(abs(b$x - b$cen)) > 0.5)) stop("cenário: cen dentro de x")
    r <- teste3_fonte_independente(f$curva, b$coef, b$av, b$x, b$cen, b$ss$serie_nos, c(0.10, 0.75, 0.90), b$ss$x_cb, fun = "ns")
    d <- f$decide_teste3(r, b$x, b$ss$x_cb); if (!d$ok) stop("teste 3 com cen fora de x: ", paste(d$falhas, collapse = "; "))
  },

  # v1.0.2 (2): controle com a argvar errada (nós de quantile(x_cb); fronteiras p1–p99 da serie_nos): diferença > 1e-8
  ts11_v102_argvar_errada = function(f) {
    b <- .m_t3_base()
    av1 <- b$av; av1$knots <- unname(stats::quantile(b$ss$x_cb, c(0.10, 0.75, 0.90), type = 7))
    av2 <- b$av; av2$Boundary.knots <- unname(stats::quantile(b$ss$serie_nos, c(0.01, 0.99), type = 7))
    xin <- b$x[b$x > av2$Boundary.knots[1] & b$x < av2$Boundary.knots[2]]; if (length(xin) < 4) stop("cenário: poucos pontos dentro das fronteiras p1–p99")
    for (cs in list(list(av1, b$x, "nós de quantile(x_cb)"), list(av2, xin, "fronteiras p1–p99"))) {
      r <- teste3_fonte_independente(f$curva, b$coef, cs[[1]], cs[[2]], b$cen, b$ss$serie_nos, c(0.10, 0.75, 0.90), b$ss$x_cb, fun = "ns")
      if (!(r$dif > 1e-8)) stop("controle com argvar errada (", cs[[3]], ") sem poder: dif = ", format(r$dif))
      if (f$decide_teste3(r, cs[[2]], b$ss$x_cb)$ok) stop("decide_teste3 aceitou a argvar errada (", cs[[3]], ")")
    }
  },

  # confere_meta nas saídas válidas de toda meta-análise nova (efeitos fixos, multinível, exploratória contínua e com
  # fator) e parada nas saídas "falhou" (auditoria da Parte A, achado 1)
  ts11_confere_meta_novas = function(f) {
    m <- .m_sint(); tr <- c("media", "amplitude")
    f$confere_meta(f$meta_fixos(m$Y, m$S, m$md), tr, m$Y)
    f$confere_meta(f$meta_multinivel(m$Y, m$S, m$md, m$md$regiao), tr, m$Y)
    f$confere_meta(f$meta_exploratoria(m$Y, m$S, m$md, "cesarea"), "cesarea", m$Y)
    f$confere_meta(f$meta_exploratoria(m$Y, m$S, m$md, "regiao"), "regiao", m$Y, gl = 16L)
    falha <- function(...) stop("falha simulada")
    .m_erro(function() f$confere_meta(f$meta_fixos(m$Y, m$S, m$md, ajusta = falha), tr, m$Y))
    .m_erro(function() f$confere_meta(f$meta_multinivel(m$Y, m$S, m$md, m$md$regiao, ajusta = falha), tr, m$Y))
    .m_erro(function() f$confere_meta(f$meta_exploratoria(m$Y, m$S, m$md, "cesarea", ajusta = falha), "cesarea", m$Y))
    h <- f$meta_fixos(m$Y, m$S, m$md); .m_perto(h$heterogeneidade$total$df, 100, 0)
    q0 <- mixmeta::qtest(mixmeta::mixmeta(unname(m$Y) ~ 1, S = m$S, method = "fixed")); .m_perto(h$heterogeneidade$total$Q, q0$Q[1], 1e-10, rel = TRUE)
  }
)
