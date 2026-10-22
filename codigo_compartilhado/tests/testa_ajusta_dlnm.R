# testa_ajusta_dlnm.R — testes rápidos da ajusta_dlnm() e da spec_agudo() (prompt da Fase 2 do Artigo 1, A2: testes 1 a 4
# e 8 a 10, mais os rápidos do desvio 58). Só dado sintético (gera_sintetico.R). Cada teste recebe `f` (ambiente com
# ajusta_dlnm, spec_agudo, .pacf_por_unidade e o gerador) e para com erro se uma conferência falhar.
# Requer dlnm e gnm carregáveis. Os testes de Monte Carlo (5, 5b, 6 e 7) estão em testa_ajusta_dlnm_mc.R.

if (!exists(".MC", inherits = FALSE)) .MC <- new.env()                 # resultados descritivos para o log
.a_perto <- function(a, b, tol, rel = FALSE) {
  a <- as.numeric(a); b <- as.numeric(b)
  if (length(a) != length(b) || anyNA(a) || anyNA(b)) stop("tamanho diferente ou NA")
  d <- if (rel) max(abs(a - b) / pmax(abs(b), 1e-300)) else max(abs(a - b))
  if (d > tol) stop("diferença ", format(d), " > ", format(tol))
  invisible(TRUE)
}
.a_erro <- function(fun, padrao) {
  m <- tryCatch({ fun(); NA_character_ }, error = function(e) conditionMessage(e))
  if (is.na(m)) stop("esperava erro com '", padrao, "'")
  if (!grepl(padrao, m, fixed = TRUE)) stop("erro diferente do esperado: ", m)
  invisible(TRUE)
}
# especificação com nós tirados da própria série (Boundary.knots = range das linhas recebidas)
.a_spec <- function(f, d, offset = "z_w_gama", group = NULL, cen = NULL, argvar = NULL, arglag = NULL) {
  q <- stats::quantile(d$temp, c(.10, .50, .75, .90), type = 7, names = FALSE)
  f$spec_agudo("y", "temp", "janela", 7,
               argvar = if (is.null(argvar)) list(fun = "ns", knots = q[c(1, 3, 4)]) else argvar,
               arglag = if (is.null(arglag)) list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE) else arglag,
               offset = offset, group = group, cen = if (is.null(cen)) q[2] else cen)
}
.a_dados <- function(f, n = 730, ...) f$gera_sintetico(n_dias = n, eventos_dia = 30, ...)
# cópia da ajusta_dlnm com trocas no corpo e funções-stub (só para testar ramos de falha; desvio 62)
.a_stub <- function(f, trocas, stubs) {
  g <- f$ajusta_dlnm; b <- paste(deparse(body(g), width.cutoff = 500L), collapse = "\n")
  for (t in trocas) { if (!grepl(t[1], b, fixed = TRUE)) stop("alvo do stub não encontrado: ", t[1]); b <- sub(t[1], t[2], b, fixed = TRUE) }
  body(g) <- parse(text = b)[[1]]
  e <- new.env(parent = environment(f$ajusta_dlnm)); for (k in names(stubs)) assign(k, stubs[[k]], envir = e)
  environment(g) <- e; g
}
# linhas de ajuste reconstruídas fora da função (para os testes de equivalência), com a mesma regra
.a_linhas <- function(d, cb) {
  ok <- d$janela & stats::complete.cases(cb)
  ev <- tapply(d$y[ok], d$estrato[ok], sum)
  ok & !(d$estrato %in% names(ev)[ev == 0])
}

testes_ajusta_dlnm <- list(

  t01_equivalencia_eliminate = function(f) {                         # gnm(eliminate) = glm(+ factor(estrato)): coef, φ, vcov, γ̂ e EP, QAIC
    set.seed(20261001); d <- .a_dados(f, 1095, tamanho_nb = 5)        # sobredisperso (φ ≫ 1), para a vcov depender de φ
    sp <- .a_spec(f, d); r <- f$ajusta_dlnm(d, sp); if (r$status != "ok") stop("ajuste falhou: ", r$mensagem)
    cb <- dlnm::crossbasis(d$temp, lag = 7, argvar = sp$argvar, arglag = sp$arglag); u <- .a_linhas(d, cb)
    g <- stats::glm(d$y[u] ~ unclass(cb)[u, ] + d$dia_semana[u] + d$feriado_nacional[u] + d$carnaval[u] + d$moveis[u] +
                      d$log_w[u] + factor(d$estrato[u]), offset = d$log_z[u], family = stats::quasipoisson,
                    control = stats::glm.control(epsilon = 1e-12, maxit = 100))   # glm convergido a fundo (a vcov depende disso)
    cg <- stats::coef(g)[2:17]
    .a_perto(r$coef_cb, cg, 1e-6)
    phi_g <- sum(stats::residuals(g, type = "pearson")^2) / g$df.residual
    .a_perto(r$phi, phi_g, 1e-8, rel = TRUE)
    if (phi_g < 2) stop("o dado do teste 1 devia ser sobredisperso (φ = ", format(phi_g), ")")
    Vg <- stats::vcov(g)[2:17, 2:17]
    if (max(abs(r$vcov_cb - Vg)) / max(abs(Vg)) > 1e-6) stop("vcov da cross-basis difere da do glm quasi-Poisson")
    .a_perto(r$gama, stats::coef(g)[["d$log_w[u]"]], 1e-6)            # γ̂ (desvio 63)
    .a_perto(r$ep_gama, sqrt(stats::vcov(g)["d$log_w[u]", "d$log_w[u]"]), 1e-6, rel = TRUE)
    k <- sum(!is.na(stats::coef(g))) - length(unique(d$estrato[u]))   # parâmetros fora dos estratos (intercepto + S − 1 indicadoras)
    .a_perto(r$qaic, -2 * sum(stats::dpois(d$y[u], stats::fitted(g), log = TRUE)) + 2 * phi_g * k, 1e-8, rel = TRUE)
  },

  t02_estratos_vazios = function(f) {                                # estratos sem evento não mudam coef, EP nem φ
    set.seed(20261001); d <- .a_dados(f, 730)
    ext <- utils::tail(d, 61); ext$data <- max(d$data) + 1:61
    ext$estrato <- paste("u1", format(ext$data, "%Y"), format(ext$data, "%m"), "x", sep = "_")
    rng <- range(d$temp); ext$temp <- stats::runif(61, rng[1] + 0.5, rng[2] - 0.5)   # dentro do range: Boundary.knots iguais
    ext$y <- 0; ext$janela <- TRUE; d2 <- rbind(d, ext)
    sp <- .a_spec(f, d); r1 <- f$ajusta_dlnm(d, sp); r2 <- f$ajusta_dlnm(d2, sp)
    if (r1$status != "ok" || r2$status != "ok") stop("ajuste falhou")
    .a_perto(r1$boundary_knots, r2$boundary_knots, 0)
    .a_perto(r1$coef_cb, r2$coef_cb, 1e-8)
    .a_perto(sqrt(diag(r1$vcov_cb)), sqrt(diag(r2$vcov_cb)), 1e-8)
    .a_perto(r1$phi, r2$phi, 1e-8, rel = TRUE)
    stopifnot(r1$n$estratos_removidos == 0, r2$n$estratos_removidos == length(unique(ext$estrato)))
  },

  t03_aquecimento = function(f) {                                    # cross-basis na série inteira; ajuste desde o 1º dia
    set.seed(20261001); d <- .a_dados(f, 730)
    d$temp[which(!d$janela)[1]] <- max(d$temp) + 2                   # extremo no aquecimento: range da janela ≠ range de tudo
    cb_cortada <- dlnm::crossbasis(d$temp[d$janela], lag = 7, argvar = list(fun = "ns", knots = c(18, 25, 27)),
                                   arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE))
    stopifnot(sum(!stats::complete.cases(cb_cortada)) == 7)          # cortar antes perderia os 7 primeiros dias
    r <- f$ajusta_dlnm(d, .a_spec(f, d)); if (r$status != "ok") stop("ajuste falhou")
    stopifnot(r$linhas_por_unidade$primeira == min(d$data[d$janela]), r$n$dias_usados == sum(d$janela),
              r$n$dias_sem_base_ou_offset == 0)
    .a_perto(r$boundary_knots, range(d$temp), 0)                     # Boundary.knots = range de TODAS as linhas recebidas
    stopifnot(r$boundary_knots[2] > max(d$temp[d$janela]))
  },

  t04_group = function(f) {                                          # com group, as 7 primeiras linhas de cada unidade são NA
    set.seed(20261001)
    a <- f$gera_sintetico(n_dias = 365, aquec = 0, eventos_dia = 30, unidade = "A")
    b <- f$gera_sintetico(n_dias = 365, aquec = 0, eventos_dia = 30, unidade = "B", inicio = as.Date("2013-06-01"))
    d <- rbind(a, b)
    r <- f$ajusta_dlnm(d, .a_spec(f, d, group = "unidade")); if (r$status != "ok") stop("ajuste falhou: ", r$mensagem)
    lp <- r$linhas_por_unidade
    stopifnot(nrow(lp) == 2, all(lp$n == 365 - 7), lp$primeira[lp$unidade == "A"] == min(a$data) + 7,
              lp$primeira[lp$unidade == "B"] == min(b$data) + 7)
  },

  t08a_falha_capturada = function(f) {                               # status "falhou", sem erro e sem trocar de spec
    set.seed(20261001); d <- .a_dados(f, 730)
    sp <- f$spec_agudo("y", "temp", "janela", 7, argvar = list(fun = "ns", knots = c(21, 22, 23)),
                       arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE), cen = 22)
    d$temp <- ifelse((seq_len(nrow(d)) %/% 10) %% 2 == 0, 20, 24)      # só dois valores: cross-basis aliasada
    r <- tryCatch(f$ajusta_dlnm(d, sp), error = function(e) stop("erro não capturado: ", conditionMessage(e)))
    stopifnot(r$status == "falhou", grepl("aliasado", r$mensagem), identical(r$spec, sp))
    d$temp <- 22                                                       # temperatura constante: erro na base, capturado
    r1 <- tryCatch(f$ajusta_dlnm(d, sp), error = function(e) stop("erro não capturado: ", conditionMessage(e)))
    stopifnot(r1$status == "falhou", identical(r1$spec, sp))
    d2 <- .a_dados(f, 730); d2$y <- 0                                   # sem nenhum evento: nenhuma linha de ajuste
    r2 <- tryCatch(f$ajusta_dlnm(d2, .a_spec(f, d2)), error = function(e) stop("erro não capturado: ", conditionMessage(e)))
    stopifnot(r2$status == "falhou")
  },

  t08b_especificacao_fallback = function(f) {                        # ns p50/p90 × strata 0–1, 2–4, 5–7: 9, 3 e 3 × 3
    set.seed(20261001); d <- .a_dados(f, 1095)
    q <- stats::quantile(d$temp, c(.50, .90), type = 7, names = FALSE)
    sp <- .a_spec(f, d, argvar = list(fun = "ns", knots = q), arglag = list(fun = "strata", breaks = c(2, 5), intercept = TRUE))
    r <- f$ajusta_dlnm(d, sp); if (r$status != "ok") stop("ajuste falhou: ", r$mensagem)
    stopifnot(r$dim_cb == 9, length(r$coef_cb) == 9, all(dim(r$vcov_cb) == 9), r$reduzida$dim == 3,
              length(r$reduzida$coef) == 3, all(dim(r$reduzida$vcov) == 3))
  },

  t09a_pacf_por_unidade = function(f) {                              # por unidade, grade com NA, igual ao cálculo à mão
    set.seed(20261001)
    a <- f$gera_sintetico(n_dias = 730, eventos_dia = 30, unidade = "A")
    b <- f$gera_sintetico(n_dias = 730, eventos_dia = 30, unidade = "B", inicio = as.Date("2015-01-01"))
    mes_b <- unique(b$estrato[b$janela])[5]; b$y[b$estrato == mes_b] <- 0   # um estrato sem evento na unidade B
    d <- rbind(a, b); sp <- .a_spec(f, d, group = "unidade")
    r <- f$ajusta_dlnm(d, sp); if (r$status != "ok") stop("ajuste falhou")
    stopifnot(r$n$estratos_removidos == 1)
    cb <- dlnm::crossbasis(d$temp, lag = 7, argvar = sp$argvar, arglag = sp$arglag, group = d$unidade); u <- .a_linhas(d, cb)
    m <- gnm::gnm(d$y[u] ~ unclass(cb)[u, ] + d$dia_semana[u] + d$feriado_nacional[u] + d$carnaval[u] + d$moveis[u] + d$log_w[u],
                  eliminate = factor(d$estrato[u]), offset = d$log_z[u], family = stats::quasipoisson, verbose = FALSE)
    rd <- rep(NA_real_, nrow(d)); rd[u] <- stats::residuals(m, type = "deviance")
    for (un in c("A", "B")) {
      v <- rd[d$janela & d$unidade == un]
      p <- as.numeric(stats::pacf(v, lag.max = 7, na.action = stats::na.pass, plot = FALSE)$acf)[1:7]
      linha <- r$pacf[r$pacf$unidade == un, ]
      .a_perto(unlist(linha[paste0("lag", 1:7)]), p, 1e-10)
      nv <- sum(!is.na(v)); stopifnot(linha$n == nv)
      .a_perto(linha$limite, 2 / sqrt(nv), 1e-12)
      if (!identical(linha$fora, paste(which(abs(p) > 2 / sqrt(nv)), collapse = ","))) stop("lags fora da faixa diferentes")
    }
    stopifnot(r$pacf$n[r$pacf$unidade == "B"] < r$pacf$n[r$pacf$unidade == "A"])   # o estrato removido vira NA na grade de B
  },

  t09b_pacf_ar1_e_ruido_branco = function(f) {                       # AR(1) ρ = 0,3 fora da faixa; ruído branco 3–7%
    set.seed(20261001)
    x <- as.numeric(stats::arima.sim(list(ar = 0.3), n = 4500))
    p <- f$.pacf_por_unidade(x, rep("1", 4500))
    if (!("1" %in% strsplit(p$fora, ",")[[1]])) stop("lag 1 do AR(1) dentro da faixa")
    fora <- vapply(1:200, function(i) { q <- f$.pacf_por_unidade(stats::rnorm(4500), rep("1", 4500))
      sum(abs(unlist(q[paste0("lag", 1:7)])) > q$limite) }, numeric(1))
    frac <- sum(fora) / (200 * 7); assign("frac_ruido_branco", frac, envir = .MC)
    if (frac < 0.03 || frac > 0.07) stop("fração fora da faixa no ruído branco = ", format(frac))
  },

  t09c_pacf_janela_com_lacuna = function(f) {                        # grade da 1ª à última data da janela, com NA na lacuna
    set.seed(20261001); d <- f$gera_sintetico(n_dias = 1460, eventos_dia = 30)
    md <- format(d$data, "%m-%d"); d$janela[md >= "12-22" | md <= "01-06"] <- FALSE; d$janela[1:7] <- FALSE
    sp <- .a_spec(f, d); r <- f$ajusta_dlnm(d, sp); if (r$status != "ok") stop("ajuste falhou")
    cb <- dlnm::crossbasis(d$temp, lag = 7, argvar = sp$argvar, arglag = sp$arglag); u <- .a_linhas(d, cb)
    m <- gnm::gnm(d$y[u] ~ unclass(cb)[u, ] + d$dia_semana[u] + d$feriado_nacional[u] + d$carnaval[u] + d$moveis[u] + d$log_w[u],
                  eliminate = factor(d$estrato[u]), offset = d$log_z[u], family = stats::quasipoisson, verbose = FALSE)
    rd <- rep(NA_real_, nrow(d)); rd[u] <- stats::residuals(m, type = "deviance")
    jan <- which(d$janela); v <- rd[min(jan):max(jan)]                 # a lacuna fica como NA, sem juntar os lados
    p <- as.numeric(stats::pacf(v, lag.max = 7, na.action = stats::na.pass, plot = FALSE)$acf)[1:7]
    .a_perto(unlist(r$pacf[1, paste0("lag", 1:7)]), p, 1e-10)
    stopifnot(r$pacf$n == sum(!is.na(v)), length(v) > sum(d$janela))
  },

  t08c_ramos_de_falha_com_stub = function(f) {                       # não convergência, gnm nulo, vcov (não PD, Inf, erro), φ/QAIC/PACF, crossreduce, var(γ) < 0
    set.seed(20261001); d <- .a_dados(f, 730); sp <- .a_spec(f, d)
    chama <- function(g) withCallingHandlers(tryCatch(g(d, sp), error = function(e) stop("erro não capturado: ", conditionMessage(e))),
                                             warning = function(w) stop("aviso escapou da função: ", conditionMessage(w)))
    r1 <- chama(.a_stub(f, list(c("gnm::gnm(", "gnm_stub(")), list(gnm_stub = function(...) { warning("Algorithm failed - no model could be estimated"); NULL })))
    stopifnot(r1$status == "falhou", grepl("não devolveu modelo", r1$mensagem))
    r2 <- chama(.a_stub(f, list(c("gnm::gnm(", "gnm_stub(")), list(gnm_stub = function(...) { cl <- match.call(); cl[[1]] <- quote(gnm::gnm); m <- eval(cl, parent.frame()); m$converged <- FALSE; m })))
    stopifnot(r2$status == "falhou", grepl("não convergiu", r2$mensagem))
    vc <- function(mexe) .a_stub(f, list(c("stats::vcov(", "vcov_stub(")), list(vcov_stub = function(m, ...) mexe(stats::vcov(m, ...))))   # 1ª ocorrência: a vcov do gnm
    r3 <- chama(vc(function(V) { V[1, 1] <- -abs(V[1, 1]); V }))
    stopifnot(r3$status == "falhou", grepl("vcov da cross-basis não positiva-definida", r3$mensagem))
    r4 <- chama(vc(function(V) { V[1, 1] <- Inf; V }))
    stopifnot(r4$status == "falhou", grepl("vcov da cross-basis não positiva-definida", r4$mensagem))
    r6 <- chama(vc(function(V) stop("vcov simulada")))
    stopifnot(r6$status == "falhou", grepl("vcov indisponível", r6$mensagem))
    r7 <- chama(.a_stub(f, list(c("stats::residuals(m, type = \"pearson\")", "residuos_stub()")), list(residuos_stub = function() stop("resíduos simulados"))))
    stopifnot(r7$status == "falhou", grepl("erro em φ, QAIC ou PACF", r7$mensagem))
    r8 <- chama(.a_stub(f, list(c("dlnm::crossreduce(", "crossreduce_stub(")), list(crossreduce_stub = function(...) stop("crossreduce simulado"))))
    stopifnot(r8$status == "falhou", grepl("erro no crossreduce", r8$mensagem))
    r9 <- chama(vc(function(V) { V["log_w", "log_w"] <- -abs(V["log_w", "log_w"]); V }))   # só a variância de γ: não muda o status
    stopifnot(r9$status == "ok", is.na(r9$ep_gama), any(grepl("variância de γ", r9$avisos)))
    r5 <- chama(.a_stub(f, list(c("dlnm::crossreduce(", "crossreduce_stub(")),
                        list(crossreduce_stub = function(...) { x <- dlnm::crossreduce(...); x$vcov[1, 1] <- -abs(x$vcov[1, 1]); x })))
    stopifnot(r5$status == "falhou", grepl("vcov reduzida não positiva-definida", r5$mensagem))
  },

  t15_intercepto_e_unidade_pequena = function(f) {                   # arglag sem intercepto dá erro; n ≤ 8: PACF NA
    .a_erro(function() f$spec_agudo("y", "temp", "janela", 7, argvar = list(fun = "ns", knots = c(18, 25, 27)),
                                    arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = FALSE), cen = 22), "intercept = TRUE")
    sp <- f$spec_agudo("y", "temp", "janela", 7, argvar = list(fun = "ns", knots = c(18, 25, 27)),
                       arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2)), cen = 22)
    stopifnot(isTRUE(sp$arglag$intercept))
    p <- f$.pacf_por_unidade(c(stats::rnorm(5), rep(NA, 3)), rep("u", 8))
    stopifnot(is.na(p$fora), is.na(p$limite), all(is.na(unlist(p[paste0("lag", 1:7)]))))
    set.seed(20261001); v <- rep(c(1, NA), 50); v[!is.na(v)] <- stats::rnorm(50)   # n = 50, mas lags NA (dias alternados)
    p <- f$.pacf_por_unidade(v, rep("u", 100))
    stopifnot(p$n == 50, anyNA(unlist(p[paste0("lag", 1:7)])), is.na(p$fora))
  },

  t16_offset_nao_finito_e_contagens = function(f) {                  # offset NA/−Inf na janela sai do ajuste; contagens de controle (desvio 63)
    set.seed(20261001); d <- .a_dados(f, 730)
    ej <- unique(d$estrato[d$janela]); s_vazio <- ej[6]; s_off <- ej[9]
    d$y[d$estrato == s_vazio] <- 0                                   # estrato sem evento
    i_v <- which(d$estrato == s_vazio & d$janela)[1:2]; d$log_z[i_v] <- NA            # 2 dias de offset NA no estrato vazio
    i_o <- which(d$estrato == s_off & d$janela)[1:11]; d$log_z[i_o[1:10]] <- NA; d$log_z[i_o[11]] <- -Inf   # 11 dias noutro estrato
    r <- f$ajusta_dlnm(d, .a_spec(f, d)); if (r$status != "ok") stop("ajuste falhou: ", r$mensagem)
    n_jan <- sum(d$janela); n_vazio <- sum(d$janela & d$estrato == s_vazio)
    stopifnot(r$n$dias_janela == n_jan, r$n$dias_sem_base_ou_offset == 13, r$n$dias_removidos_estrato_vazio == n_vazio - 2,
              r$n$dias_usados == n_jan - 11 - n_vazio, r$n$estratos_removidos == 1, r$n$estratos_usados == length(ej) - 1,
              r$linhas_por_unidade$n == r$n$dias_usados, r$pacf$n == r$n$dias_usados)
    u <- d$janela & is.finite(d$log_z) & d$estrato != s_vazio        # mesmo ajuste sem as linhas, pela cross-basis da série inteira
    cb <- dlnm::crossbasis(d$temp, lag = 7, argvar = .a_spec(f, d)$argvar, arglag = .a_spec(f, d)$arglag)
    m <- gnm::gnm(d$y[u] ~ unclass(cb)[u, ] + d$dia_semana[u] + d$feriado_nacional[u] + d$carnaval[u] + d$moveis[u] + d$log_w[u],
                  eliminate = factor(d$estrato[u]), offset = d$log_z[u], family = stats::quasipoisson, verbose = FALSE)
    .a_perto(r$coef_cb, stats::coef(m)[1:16], 1e-8)
  },

  t10_cen = function(f) {                                            # RR no cen = 1; cen devolvido = spec$cen (p50 e outro)
    set.seed(20261001); d <- .a_dados(f, 1095)
    for (cen in c(stats::quantile(d$temp, .50, names = FALSE), stats::quantile(d$temp, .25, names = FALSE))) {
      r <- f$ajusta_dlnm(d, .a_spec(f, d, cen = cen)); if (r$status != "ok") stop("ajuste falhou")
      if (abs(r$reduzida$cen - cen) > 0) stop("cen devolvido diferente do da spec")
      if (abs(log(r$reduzida$rr_no_cen)) >= 1e-10) stop("RRfit no cen diferente de 1")
    }
  },

  t12_spec_rejeita_nk_e_confere_nos = function(f) {                  # desvio 58
    .a_erro(function() f$spec_agudo("y", "temp", "janela", 7, argvar = list(fun = "ns", knots = c(18, 25, 27)),
                                    arglag = list(fun = "ns", nk = 2, intercept = TRUE), cen = 22), "não passe nk")
    .a_erro(function() f$spec_agudo("y", "temp", "janela", 7, argvar = list(fun = "ns", knots = c(18, 25, 27)),
                                    arglag = list(fun = "ns", knots = c(1, 3), intercept = TRUE), cen = 22), "logknots(7, nk = 2)")
    sp <- f$spec_agudo("y", "temp", "janela", 7, argvar = list(fun = "ns", knots = c(18, 25, 27)),
                       arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE), cen = 22)
    stopifnot(isTRUE(all.equal(round(sp$arglag$knots, 3), c(0.982, 2.622))))
  },

  t13_offsets_e_gama = function(f) {                                 # z_w_gama devolve γ̂; zw e nenhum não
    set.seed(20261001); d <- .a_dados(f, 1095)
    r1 <- f$ajusta_dlnm(d, .a_spec(f, d, offset = "z_w_gama")); r2 <- f$ajusta_dlnm(d, .a_spec(f, d, offset = "zw"))
    r3 <- f$ajusta_dlnm(d, .a_spec(f, d, offset = "nenhum"))
    stopifnot(r1$status == "ok", r2$status == "ok", r3$status == "ok", is.finite(r1$gama), is.finite(r1$ep_gama),
              is.na(r2$gama), is.na(r3$gama))
  },

  t14_dia_faltando_e_sigilo = function(f) {                          # dia faltando dá erro; nada de resíduo ou ajustado sai
    set.seed(20261001); d <- .a_dados(f, 730)
    .a_erro(function() f$ajusta_dlnm(d[-100, ], .a_spec(f, d)), "dia faltando")
    r <- f$ajusta_dlnm(d, .a_spec(f, d))
    if (any(grepl("resid|fitted|ajustad", names(r), ignore.case = TRUE))) stop("a saída tem resíduos ou ajustados")
    tam <- unlist(lapply(r[setdiff(names(r), c("base", "spec"))], function(x) if (is.atomic(x)) length(x) else 0))
    if (any(tam >= nrow(d) / 2)) stop("a saída tem vetor do tamanho da série")
  }
)
