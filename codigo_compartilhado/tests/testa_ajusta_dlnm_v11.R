# testa_ajusta_dlnm_v11.R — testes da ajusta_dlnm v1.1 (Fase 4 do Artigo 1; prompt da Fase 4, seção 2, item 1; D16,
# itens 1 e 2; A1-97 e A1-99). Só dado sintético (gera_sintetico.R, carregado em `f` por quem chama). Cada teste recebe
# `f` (ambiente com ajusta_dlnm.R v1.1 e o gerador) e para com erro se uma conferência falhar. A v1.0, lida da tag
# ajusta_dlnm-v1.0 por git show, vem em .REF$a10 (ambiente com spec_agudo e ajusta_dlnm da v1.0), posto por quem chama.
# Referências independentes da função: gnm/glm chamados à mão sobre as mesmas linhas. Executor: roda_testes_fase4.R.

if (!exists(".REF", inherits = FALSE)) .REF <- new.env()
.v11_perto <- function(a, b, tol, rel = FALSE) {
  a <- as.numeric(a); b <- as.numeric(b)
  if (length(a) != length(b)) stop("tamanhos diferentes: ", length(a), " × ", length(b))
  d <- if (rel) max(abs(a - b) / pmax(abs(b), 1e-300)) else max(abs(a - b))
  if (!is.finite(d) || d > tol) stop("diferença ", format(d), " > ", format(tol))
  invisible(d)
}
.v11_longe <- function(a, b, tol) { d <- max(abs(as.numeric(a) - as.numeric(b))); if (!(d > tol)) stop("controle sem poder: diferença ", format(d), " ≤ ", format(tol)); invisible(d) }
.v11_arglag <- function() list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE)
.v11_argvar <- function(x) { q <- stats::quantile(x, c(.10, .75, .90), type = 7, names = FALSE); list(fun = "ns", knots = q) }
.v11_dados <- function(f, n = 1095, eventos = 30, semente = 20261001, ...) {
  set.seed(semente, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection"); f$gera_sintetico(n_dias = n, eventos_dia = eventos, ...)
}
.v11_spec <- function(f, d, ...) f$spec_agudo("y", "temp", "janela", 7, argvar = .v11_argvar(d$temp), arglag = .v11_arglag(), cen = stats::median(d$temp), ...)
# espelho independente: as linhas de ajuste montadas à mão (janela, cross-basis completa, covariáveis, offset finito)
.v11_linhas <- function(d, sp, cb) {
  ok <- d$janela & stats::complete.cases(cb) & stats::complete.cases(d[, c("y", sp$covariaveis), drop = FALSE]) & is.finite(d$log_z) & is.finite(d$log_w)
  ok
}

testes_ajusta_dlnm_v11 <- list(

  # sem os argumentos novos, todos os campos da v1.0 saem idênticos (identical) aos da v1.0, nos três offsets e com group
  tv11_regressao_v10 = function(f) {
    if (is.null(.REF$a10)) stop("v1.0 (.REF$a10) ausente")
    d <- .v11_dados(f, n = 900, gamma = 1.2, efeito = "dobradica", bf = f$base_fixa(20000))
    d2 <- rbind(.v11_dados(f, n = 400, unidade = "u1", semente = 1), .v11_dados(f, n = 400, unidade = "u2", semente = 2))
    casos <- list(list(d, list()), list(d, list(offset = "zw")), list(d, list(offset = "nenhum")), list(d2, list(group = "unidade")))
    for (cs in casos) {
      dd <- cs[[1]]; a <- cs[[2]]
      s10 <- do.call(.REF$a10$spec_agudo, c(list("y", "temp", "janela", 7, argvar = .v11_argvar(dd$temp), arglag = .v11_arglag(), cen = stats::median(dd$temp)), a))
      s11 <- do.call(f$spec_agudo, c(list("y", "temp", "janela", 7, argvar = .v11_argvar(dd$temp), arglag = .v11_arglag(), cen = stats::median(dd$temp)), a))
      if (!identical(unclass(s10), unclass(s11))) stop("spec_agudo v1.1 diferente da v1.0 sem os argumentos novos")
      r10 <- .REF$a10$ajusta_dlnm(dd, s10); r11 <- f$ajusta_dlnm(dd, s11)
      dif <- names(r10)[!vapply(names(r10), function(nm) identical(unclass(r10[[nm]]), unclass(r11[[nm]])), TRUE)]
      if (length(dif)) stop("campos da v1.0 diferentes na v1.1: ", paste(dif, collapse = ", "))
      if (!("eventos_removidos" %in% names(r11)) || "residuos_deviance" %in% names(r11)) stop("campos novos: eventos_removidos sempre, resíduos só a pedido")
    }
  },

  # resíduos de deviance (a pedido): os do gnm sobre as mesmas linhas, NA fora; soma dos quadrados = deviance; controle:
  # Pearson difere
  tv11_residuos_deviance = function(f) {
    d <- .v11_dados(f); sp <- .v11_spec(f, d); r <- f$ajusta_dlnm(d, sp, devolve_residuos = TRUE); stopifnot(identical(r$status, "ok"))
    cb <- dlnm::crossbasis(d$temp, lag = 7, argvar = sp$argvar, arglag = sp$arglag); u <- .v11_linhas(d, sp, cb)
    m <- gnm::gnm(d$y[u] ~ unclass(cb)[u, ] + d$dia_semana[u] + d$feriado_nacional[u] + d$carnaval[u] + d$moveis[u] + d$log_w[u],
                  eliminate = factor(d$estrato[u]), offset = d$log_z[u], family = stats::quasipoisson, verbose = FALSE)
    if (length(r$residuos_deviance) != nrow(d) || !all(is.na(r$residuos_deviance[!u])) || anyNA(r$residuos_deviance[u])) stop("resíduos com NA fora do lugar")
    .v11_perto(r$residuos_deviance[u], stats::residuals(m, type = "deviance"), 1e-10)
    .v11_perto(sum(r$residuos_deviance[u]^2), m$deviance, 1e-8, rel = TRUE)
    .v11_longe(r$residuos_deviance[u], stats::residuals(m, type = "pearson"), 1e-6)
  },

  # covariável em coluna-matriz (ns de 3 gl e uma matriz de 1 coluna) = as mesmas colunas expandidas; a v1.0 não aceita
  tv11_coluna_matriz = function(f) {
    d <- .v11_dados(f); nc <- splines::ns(c(d$temp[-1], NA), df = 3)          # ns de 3 gl de uma série deslocada (com NA)
    d$nc <- matrix(as.numeric(nc), ncol = 3); for (j in 1:3) d[[paste0("nc", j)]] <- d$nc[, j]
    d$um <- matrix(sin(seq_len(nrow(d)) / 20), ncol = 1)
    cov0 <- c("dia_semana", "feriado_nacional", "carnaval", "moveis")
    rM <- f$ajusta_dlnm(d, .v11_spec(f, d, covariaveis = c(cov0, "nc", "um")))
    d$um1 <- d$um[, 1]; rE <- f$ajusta_dlnm(d, .v11_spec(f, d, covariaveis = c(cov0, "nc1", "nc2", "nc3", "um1")))
    stopifnot(identical(rM$status, "ok"), identical(rE$status, "ok"), rM$n$dias_usados == rE$n$dias_usados)
    .v11_perto(rM$coef_cb, rE$coef_cb, 1e-10); .v11_perto(rM$vcov_cb, rE$vcov_cb, 1e-12); .v11_perto(rM$gama, rE$gama, 1e-10)
    if (is.null(.REF$a10)) stop("v1.0 (.REF$a10) ausente")
    s10 <- .REF$a10$spec_agudo("y", "temp", "janela", 7, argvar = .v11_argvar(d$temp), arglag = .v11_arglag(), cen = stats::median(d$temp), covariaveis = c(cov0, "nc"))
    r10 <- tryCatch(.REF$a10$ajusta_dlnm(d, s10), error = function(e) e)
    if (!inherits(r10, "error") && identical(r10$status, "ok")) stop("controle: a v1.0 aceitou a coluna-matriz")
  },

  # estrato = NULL: glm quasi-Poisson não condicional com ns(tempo, gl) só nas linhas do ajuste = glm direto (≤ 1e-8);
  # controle: o modelo condicional difere
  tv11_glm_sem_eliminate = function(f) {
    d <- .v11_dados(f, eventos = 3); g <- 25L
    r <- f$ajusta_dlnm(d, .v11_spec(f, d, estrato = NULL, tempo_gl = g)); stopifnot(identical(r$status, "ok"))
    sp <- .v11_spec(f, d); cb <- dlnm::crossbasis(d$temp, lag = 7, argvar = sp$argvar, arglag = sp$arglag); u <- .v11_linhas(d, sp, cb)
    nt <- splines::ns(as.numeric(d$data[u]), df = g)
    m <- stats::glm(d$y[u] ~ unclass(cb)[u, ] + d$dia_semana[u] + d$feriado_nacional[u] + d$carnaval[u] + d$moveis[u] + nt + d$log_w[u],
                    offset = d$log_z[u], family = stats::quasipoisson)
    .v11_perto(r$coef_cb, stats::coef(m)[2:17], 1e-8); .v11_perto(r$vcov_cb, stats::vcov(m)[2:17, 2:17], 1e-8)
    .v11_perto(r$gama, stats::coef(m)[length(stats::coef(m))], 1e-8)
    .v11_perto(r$phi, sum(stats::residuals(m, type = "pearson")^2) / m$df.residual, 1e-10, rel = TRUE)
    rc <- f$ajusta_dlnm(d, sp); .v11_longe(rc$coef_cb, r$coef_cb, 1e-6)
    stopifnot(is.na(r$n$estratos_usados), r$n$estratos_removidos == 0L)
  },

  # D16: sem estratos, as linhas do ajuste são todos os dias da janela, inclusive os sem evento; controle: tirar os dias
  # sem evento muda o número de linhas e os coeficientes
  tv11_d16_linhas_sem_evento = function(f) {
    d <- .v11_dados(f, eventos = 1.5); g <- 20L; n_jan <- sum(d$janela); n_zero <- sum(d$y[d$janela] == 0)
    if (n_zero < 50) stop("cenário sem dias de zero evento suficientes")
    r <- f$ajusta_dlnm(d, .v11_spec(f, d, estrato = NULL, tempo_gl = g), devolve_residuos = TRUE); stopifnot(identical(r$status, "ok"))
    if (r$n$dias_usados != n_jan) stop("linhas do ajuste (", r$n$dias_usados, ") ≠ dias da janela (", n_jan, ")")
    if (r$n$dias_removidos_estrato_vazio != 0L || sum(!is.na(r$residuos_deviance)) != n_jan) stop("dias sem evento fora do ajuste")
    sp <- .v11_spec(f, d); cb <- dlnm::crossbasis(d$temp, lag = 7, argvar = sp$argvar, arglag = sp$arglag); u <- .v11_linhas(d, sp, cb) & d$y > 0
    nt <- splines::ns(as.numeric(d$data[u]), df = g)
    m0 <- stats::glm(d$y[u] ~ unclass(cb)[u, ] + d$dia_semana[u] + d$feriado_nacional[u] + d$carnaval[u] + d$moveis[u] + nt + d$log_w[u],
                     offset = d$log_z[u], family = stats::quasipoisson)
    if (sum(u) == n_jan) stop("controle sem poder: tirar os dias sem evento não mudou as linhas")
    .v11_longe(stats::coef(m0)[2:17], r$coef_cb, 1e-6)
  },

  # γ aliasado (log_w constante, glm com intercepto): γ NA e EP NA, sem o aviso de variância não finita
  tv11_ep_gama_na = function(f) {
    d <- .v11_dados(f); d$log_w <- log(0.01)
    r <- f$ajusta_dlnm(d, .v11_spec(f, d, estrato = NULL, tempo_gl = 15L))
    stopifnot(identical(r$status, "ok"), is.na(r$gama), is.na(r$ep_gama))
    if (any(grepl("variância de γ", r$avisos, fixed = TRUE))) stop("aviso de variância de γ com γ NA")
    if (!any(grepl("aliasado fora da cross-basis", r$avisos, fixed = TRUE))) stop("aliasamento de log_w não registrado")
  },

  # eventos removidos = eventos da janela fora das linhas de ajuste (covariável NA e offset não finito), contados à mão
  tv11_eventos_removidos = function(f) {
    d <- .v11_dados(f); jan <- which(d$janela)
    i_na <- jan[c(10, 50, 300, 301)]; i_inf <- jan[c(20, 700)]
    d$feriado_nacional[i_na] <- NA; d$log_z[i_inf] <- -Inf
    r <- f$ajusta_dlnm(d, .v11_spec(f, d)); stopifnot(identical(r$status, "ok"))
    esperado <- sum(d$y[c(i_na, i_inf)])
    if (esperado <= 0) stop("cenário com zero evento nos dias removidos")
    if (!identical(as.numeric(r$eventos_removidos), as.numeric(esperado))) stop("eventos removidos ", r$eventos_removidos, " ≠ ", esperado)
    if (r$n$eventos + r$eventos_removidos != sum(d$y[d$janela])) stop("eventos usados + removidos ≠ eventos da janela")
  },

  # matriz devolvida: X das colunas não eliminadas, fator dos estratos, pesos de trabalho = μ̂ (< 1e-8); escore ponderado ≈ 0
  # (até a tolerância do IRLS, < 1e-5 do escore em valor absoluto); controle: com pesos 1, o escore fica pelo menos 100 vezes maior
  tv11_devolve_matriz = function(f) {
    d <- .v11_dados(f); r <- f$ajusta_dlnm(d, .v11_spec(f, d), devolve_matriz = TRUE); stopifnot(identical(r$status, "ok"), !is.null(r$matriz))
    mt <- r$matriz; n <- r$n$dias_usados
    stopifnot(nrow(mt$X) == n, ncol(mt$X) == 16L + 6L + 3L + 1L, length(mt$estrato) == n, length(mt$peso_trabalho) == n, length(mt$linhas) == n)
    if (!(max(abs(mt$peso_trabalho - mt$mu) / mt$mu) < 1e-8)) stop("pesos de trabalho ≠ μ̂")
    Xf <- cbind(stats::model.matrix(~ e - 1, data.frame(e = mt$estrato)), mt$X); y <- d$y[mt$linhas]
    rp <- (y - mt$mu) / sqrt(mt$mu); esc <- max(abs(crossprod(sqrt(mt$peso_trabalho) * Xf, abs(rp))))
    s_w <- max(abs(crossprod(sqrt(mt$peso_trabalho) * Xf, rp))) / esc
    s_1 <- max(abs(crossprod(Xf, rp))) / esc
    if (!(s_w < 1e-5)) stop("escore ponderado não zera: ", format(s_w))
    # controle (auditoria do chat de 18/10, N2): com pesos 1, o mesmo critério tem de falhar (s_1 > 1e-5)
    if (!(s_1 > 1e-5)) stop("controle sem poder: escore com pesos 1 = ", format(s_1), ", com pesos de trabalho = ", format(s_w))
    # sem estratos (glm): a matriz sai sem o fator dos estratos e com o intercepto em X. W = μ̂ a 1e-8 é teste do modelo
    # condicional (o da nula da PACF; D16, item 2): no glm, os pesos de trabalho guardados são os da penúltima iteração
    # do IRLS e diferem de μ̂ na ordem da tolerância de convergência (registrado no log do 60)
    r2 <- f$ajusta_dlnm(d, .v11_spec(f, d, estrato = NULL, tempo_gl = 15L), devolve_matriz = TRUE)
    stopifnot(is.null(r2$matriz$estrato), identical(colnames(r2$matriz$X)[1], "(Intercept)"), length(r2$matriz$peso_trabalho) == r2$n$dias_usados)
    .REF$glm_w_mu <- max(abs(r2$matriz$peso_trabalho - r2$matriz$mu) / r2$matriz$mu)
  },

  # validação da spec: estrato = NULL sem tempo_gl, tempo_gl com estrato e tempo_gl fracionário dão erro
  tv11_spec_validacao = function(f) {
    d <- .v11_dados(f, n = 400)
    for (a in list(list(estrato = NULL), list(tempo_gl = 10L), list(estrato = NULL, tempo_gl = 2.5)))
      if (!inherits(tryCatch(do.call(.v11_spec, c(list(f, d), a)), error = function(e) e), "error")) stop("spec_agudo aceitou argumentos inválidos")
    s <- .v11_spec(f, d, estrato = NULL, tempo_gl = 10L); stopifnot(is.null(s$estrato), identical(s$tempo_gl, 10L))
  }
)
