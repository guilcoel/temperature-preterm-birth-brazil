# testa_ajusta_dlnm_d1_errata.R — teste da dispersão da D1, item 2, no texto da errata da D6
# (spec/decisoes_metodo_20261013_D6_respostas_A2.md, item 2.2), para a tag ajusta_dlnm-v1.0.1, só de testes: nenhum
# arquivo de R/ muda. Preparado pelo Artigo 2 (desvios 103 e 127 do A2). Só dado sintético (gera_sintetico.R). Mesmo
# executor (roda_testes.R) e mesmo `f` de testa_ajusta_dlnm.R (ajusta_dlnm, spec_agudo e o gerador).
#   (i)  phi_P = soma dos resíduos de Pearson ao quadrado ÷ df.residual(m), calculado à parte, coincide com
#        summary(m)$dispersion, com tolerância relativa de 1e-6;
#   (ii) os estratos sem evento foram removidos, all(tapply(y, estrato, sum) > 0), e df.residual(m) == n − n_estratos − p,
#        com p = número de coeficientes não eliminados (e não aliasados) do modelo.
#   Controles negativos (D6): o mesmo modelo com family = poisson, em dado sintético com φ verdadeiro ≈ 2 (binomial
#   negativa de tamanho 30 com média ≈ 30 eventos por dia: φ ≈ 1 + μ/θ ≈ 2), tem de falhar em (i); a cópia com o estrato
#   vazio mantido tem de falhar em (ii). Controle a mais, não pedido pela D6, para dar poder à segunda metade de (ii): o
#   mesmo modelo sem o eliminate (intercepto no lugar dos estratos) tem de falhar em (ii).
#   A ajusta_dlnm() v1.0 não devolve o modelo: os testes usam o gnm espelho (a mesma montagem e a mesma chamada da função,
#   como no desvio 55 do A2), conferido contra a função (coeficientes e vcov da cross-basis, φ e contagens) antes de
#   aplicar (i) e (ii).
#
# confere_d1_errata(m, y, estrato, tol = 1e-6): aplica (i) e (ii) a um modelo ajustado e devolve uma lista com os números,
#   ok_i e ok_ii. y e estrato são os das linhas do modelo. Fica aqui para os scripts dos artigos aplicarem o mesmo teste
#   aos modelos reais (B0.5 da Fase 3 do A2).
#
# Uso, da raiz do repositório:
#   f <- new.env(); sys.source("codigo_compartilhado/R/ajusta_dlnm.R", envir = f)
#   sys.source("codigo_compartilhado/tests/gera_sintetico.R", envir = f)
#   source("codigo_compartilhado/tests/roda_testes.R"); source("codigo_compartilhado/tests/testa_ajusta_dlnm_d1_errata.R")
#   r <- roda_testes(f, testes_ajusta_dlnm_d1_errata); print(r); stopifnot(all(r$ok))

if (!exists(".MC", inherits = FALSE)) .MC <- new.env()                 # resultados descritivos para o log

confere_d1_errata <- function(m, y, estrato, tol = 1e-6) {
  gl <- stats::df.residual(m)
  phi_P <- sum(stats::residuals(m, type = "pearson")^2) / gl
  disp <- summary(m)$dispersion
  rel <- abs(phi_P - disp) / abs(disp)
  estrato <- factor(as.character(estrato))                           # níveis = estratos presentes nas linhas do modelo
  com_evento <- all(tapply(y, estrato, sum) > 0)
  n <- length(y); n_estratos <- nlevels(estrato); p <- sum(!is.na(stats::coef(m)))
  gl_ok <- isTRUE(gl == n - n_estratos - p)
  list(phi_P = phi_P, dispersao_summary = disp, dif_relativa = rel, ok_i = isTRUE(rel <= tol),
       todos_estratos_com_evento = com_evento, df_residual = gl, n = n, n_estratos = n_estratos, p = p,
       gl_ok = gl_ok, ok_ii = com_evento && gl_ok)
}

# dado com φ verdadeiro ≈ 2 e especificação com nós da própria série (como a .a_spec de testa_ajusta_dlnm.R)
.d1_dados <- function(f, n = 1095) f$gera_sintetico(n_dias = n, eventos_dia = 30, tamanho_nb = 30)
.d1_spec <- function(f, d) {
  q <- stats::quantile(d$temp, c(.10, .50, .75, .90), type = 7, names = FALSE)
  f$spec_agudo("y", "temp", "janela", 7, argvar = list(fun = "ns", knots = q[c(1, 3, 4)]),
               arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE), offset = "z_w_gama", cen = q[2])
}
# gnm espelho: a montagem e a chamada da ajusta_dlnm() v1.0 (linhas de ajuste, estratos vazios, md, fórmula e offset),
# com três trocas só para os controles: a família, manter os estratos vazios e tirar o eliminate
.d1_espelho <- function(dados, spec, familia = stats::quasipoisson, manter_vazios = FALSE, eliminar = TRUE) {
  off_cols <- switch(spec$offset, z_w_gama = c("log_z", "log_w"), zw = "log_zw", nenhum = character(0))
  grp <- if (is.null(spec$group)) NULL else as.character(dados[[spec$group]])
  cb <- dlnm::crossbasis(dados[[spec$exposicao]], lag = spec$lag, argvar = spec$argvar, arglag = spec$arglag, group = grp)
  ok <- dados[[spec$janela]] %in% TRUE & stats::complete.cases(cb) &
        stats::complete.cases(dados[, unique(c(spec$desfecho, spec$covariaveis, spec$estrato)), drop = FALSE])
  for (k in off_cols) ok <- ok & is.finite(dados[[k]])
  est <- as.character(dados[[spec$estrato]])
  ev <- tapply(dados[[spec$desfecho]][ok], est[ok], sum)
  usar <- if (manter_vazios) ok else ok & !(est %in% names(ev)[ev == 0])
  md <- data.frame(y = dados[[spec$desfecho]][usar], est = factor(est[usar]))
  for (k in spec$covariaveis) md[[k]] <- dados[[k]][usar]
  md$cb <- unclass(cb)[usar, , drop = FALSE]
  termos <- c("cb", spec$covariaveis)
  if (spec$offset == "z_w_gama") { md$log_w <- dados$log_w[usar]; termos <- c(termos, "log_w") }
  off <- switch(spec$offset, z_w_gama = dados$log_z[usar], zw = dados$log_zw[usar], nenhum = NULL)
  form <- stats::as.formula(paste("y ~", paste(termos, collapse = " + ")))
  m <- if (eliminar) gnm::gnm(form, eliminate = est, family = familia, data = md, offset = off, verbose = FALSE) else
         gnm::gnm(form, family = familia, data = md, offset = off, verbose = FALSE)
  if (is.null(m)) stop("o gnm espelho não devolveu modelo")
  list(m = m, y = md$y, estrato = md$est)
}
# espelho = função: coeficientes e vcov da cross-basis e φ (≤ 1e-10), dias e estratos usados
.d1_igual_funcao <- function(e, r) {
  cf <- stats::coef(e$m); i_cb <- grep("^cb", names(cf)); V <- stats::vcov(e$m)
  if (!identical(names(cf)[i_cb], names(r$coef_cb))) stop("nomes da cross-basis diferentes entre o espelho e a função")
  d <- c(coef = max(abs(cf[i_cb] - r$coef_cb)), vcov = max(abs(V[i_cb, i_cb] - r$vcov_cb)),
         phi = abs(sum(stats::residuals(e$m, type = "pearson")^2) / stats::df.residual(e$m) - r$phi))
  if (any(!is.finite(d)) || any(d > 1e-10)) stop("espelho diferente da função: ", paste(names(d), format(d), collapse = "; "))
  if (length(e$y) != r$n$dias_usados || nlevels(e$estrato) != r$n$estratos_usados) stop("contagens do espelho diferentes das da função")
  invisible(TRUE)
}

testes_ajusta_dlnm_d1_errata <- list(

  t01_quasipoisson_passa = function(f) {                             # (i) e (ii) passam no espelho, igual à função; φ ≈ 2
    set.seed(20261001); d <- .d1_dados(f); sp <- .d1_spec(f, d)
    r <- f$ajusta_dlnm(d, sp); if (r$status != "ok") stop("ajuste falhou: ", r$mensagem)
    e <- .d1_espelho(d, sp); .d1_igual_funcao(e, r)
    z <- confere_d1_errata(e$m, e$y, e$estrato); assign("t01", z, envir = .MC)
    if (!z$ok_i) stop("(i) falhou: diferença relativa ", format(z$dif_relativa))
    if (!z$ok_ii) stop("(ii) falhou: estratos com evento ", z$todos_estratos_com_evento, ", gl ", z$df_residual, " ≠ ", z$n - z$n_estratos - z$p)
    if (z$phi_P < 1.5 || z$phi_P > 2.5) stop("o dado devia ter φ ≈ 2 (φ estimado = ", format(z$phi_P), ")")
    if (z$p != 26) stop("p devia ser 26 (16 da cross-basis, 6 do dia da semana, 3 de feriados e log_w): ", z$p)
  },

  t02_controle_poisson_falha_i = function(f) {                       # D6: Poisson com φ verdadeiro ≈ 2 falha em (i)
    set.seed(20261001); d <- .d1_dados(f); sp <- .d1_spec(f, d)
    e <- .d1_espelho(d, sp, familia = stats::poisson)
    z <- confere_d1_errata(e$m, e$y, e$estrato); assign("t02", z, envir = .MC)
    if (!isTRUE(z$dispersao_summary == 1)) stop("na Poisson a dispersão do summary devia ser 1: ", format(z$dispersao_summary))
    if (z$phi_P < 1.5) stop("o dado devia ter φ ≈ 2 (φ de Pearson = ", format(z$phi_P), ")")
    if (z$ok_i) stop("controle negativo: a Poisson com φ ≈ 2 passou em (i)")
  },

  t03_estrato_vazio = function(f) {                                  # sem o vazio, (i) e (ii) passam; com ele, (ii) falha (D6)
    set.seed(20261001); d <- .d1_dados(f)
    vazio <- unique(d$estrato[d$janela])[5]; d$y[d$estrato == vazio] <- 0
    sp <- .d1_spec(f, d); r <- f$ajusta_dlnm(d, sp); if (r$status != "ok") stop("ajuste falhou: ", r$mensagem)
    if (r$n$estratos_removidos != 1) stop("a função devia remover 1 estrato")
    e <- .d1_espelho(d, sp); .d1_igual_funcao(e, r)
    z <- confere_d1_errata(e$m, e$y, e$estrato); assign("t03", z, envir = .MC)
    if (!z$ok_i || !z$ok_ii) stop("com o estrato vazio removido, (i) ou (ii) falhou")
    k <- .d1_espelho(d, sp, manter_vazios = TRUE)
    zk <- confere_d1_errata(k$m, k$y, k$estrato); assign("t03_mantido", zk, envir = .MC)
    if (zk$n_estratos != z$n_estratos + 1 || zk$todos_estratos_com_evento) stop("a cópia devia manter o estrato vazio")
    if (zk$ok_ii) stop("controle negativo: a cópia com o estrato vazio mantido passou em (ii)")
  },

  t04_controle_sem_eliminate_falha_ii = function(f) {                # controle a mais: sem eliminate, o gl não desconta os estratos
    set.seed(20261001); d <- .d1_dados(f); sp <- .d1_spec(f, d)
    s <- .d1_espelho(d, sp, eliminar = FALSE)
    z <- confere_d1_errata(s$m, s$y, s$estrato); assign("t04", z, envir = .MC)
    if (!z$todos_estratos_com_evento) stop("o dado deste controle não devia ter estrato vazio")
    if (z$gl_ok || z$ok_ii) stop("controle negativo: o modelo sem eliminate passou em (ii)")
  }
)
