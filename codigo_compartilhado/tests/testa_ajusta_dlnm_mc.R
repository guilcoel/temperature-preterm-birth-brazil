# testa_ajusta_dlnm_mc.R — testes de Monte Carlo da ajusta_dlnm() (prompt da Fase 2 do Artigo 1, A2: testes 5, 5b, 6 e 7;
# desvios 55 e 57). Só dado sintético. Antes de rodar, quem chama põe em .MC: bf (base_fixa), proj (projeta_theta) e
# R (nº de réplicas, 200). Cada teste guarda os resultados em .MC (para o log) e para com erro se um critério falhar.
# Regra do prompt: falha de critério leva a diagnóstico, nunca a troca de semente; todas as réplicas usam a semente 20261001.

if (!exists(".MC", inherits = FALSE)) .MC <- new.env()
.Z975 <- stats::qnorm(0.975)
.wilson <- function(p, n, z = .Z975) {                               # IC de Wilson de uma proporção (desvio 62)
  d <- 1 + z^2 / n; centro <- (p + z^2 / (2 * n)) / d
  centro + c(-1, 1) * z / d * sqrt(p * (1 - p) / n + z^2 / (4 * n^2))
}

.mc_est <- function(r, bf) {                                         # log RR no p99 contra o cen, pela base devolvida
  if (!identical(r$status, "ok")) return(c(est = NA_real_, se = NA_real_))
  b <- unclass(do.call(dlnm::onebasis, c(list(x = c(bf$p99, bf$cen)), r$base$argvar)))
  dv <- b[1, ] - b[2, ]
  c(est = sum(dv * r$reduzida$coef), se = sqrt(drop(t(dv) %*% r$reduzida$vcov %*% dv)))
}
.mc_resumo <- function(est, se, verdadeiro) {
  ok <- is.finite(est) & is.finite(se); est <- est[ok]; se <- se[ok]; R <- length(est)
  cob <- mean(abs(est - verdadeiro) <= .Z975 * se); ep_cob <- sqrt(cob * (1 - cob) / R)
  vies <- mean(est) - verdadeiro; ep_vies <- stats::sd(est) / sqrt(R)
  list(R = R, verdadeiro = verdadeiro, cobertura = cob, ep_cob = ep_cob, ic_cob = .wilson(cob, R),
       vies = vies, ep_vies = ep_vies, ic_vies = vies + c(-1, 1) * 1.96 * ep_vies,
       vies_rel = if (verdadeiro != 0) vies / verdadeiro else NA_real_,
       ep_vies_rel = if (verdadeiro != 0) ep_vies / abs(verdadeiro) else NA_real_, media = mean(est), dp = stats::sd(est), se_medio = mean(se))
}
.mc_spec <- function(f, bf, offset) f$spec_agudo("y", "temp", "janela", 7, argvar = bf$argvar, arglag = bf$arglag, offset = offset, cen = bf$cen)
# roda R réplicas de um cenário e devolve est, se, γ̂, φ, status e PACF (descritivo)
.mc_cenario <- function(f, R, gerar, offsets) {
  bf <- .MC$bf
  res <- lapply(seq_len(R), function(i) {
    d <- gerar()
    lapply(offsets, function(o) {
      r <- f$ajusta_dlnm(d, .mc_spec(f, bf, o)); e <- .mc_est(r, bf)
      list(est = e[["est"]], se = e[["se"]], gama = if (is.null(r$gama)) NA_real_ else r$gama, phi = if (is.null(r$phi)) NA_real_ else r$phi,
           status = r$status, pacf_fora = if (is.null(r$pacf)) NA else nchar(r$pacf$fora[1]) > 0,
           pacf = if (is.null(r$pacf)) rep(NA_real_, 7) else unlist(r$pacf[1, paste0("lag", 1:7)]))
    })
  })
  setNames(lapply(seq_along(offsets), function(k) {
    x <- lapply(res, `[[`, k)
    list(est = vapply(x, `[[`, 0, "est"), se = vapply(x, `[[`, 0, "se"), gama = vapply(x, `[[`, 0, "gama"),
         phi = vapply(x, `[[`, 0, "phi"), falhou = sum(vapply(x, function(z) z$status != "ok", TRUE)),
         pacf_alguma_fora = mean(vapply(x, function(z) isTRUE(z$pacf_fora), TRUE)),
         pacf_media = colMeans(do.call(rbind, lapply(x, `[[`, "pacf")), na.rm = TRUE))
  }), offsets)
}
.mc_gama <- function(g, alvo) { g <- g[is.finite(g)]; R <- length(g); m <- mean(g); ep <- stats::sd(g) / sqrt(R)
  list(media = m, ep = ep, ic = m + c(-1, 1) * 1.96 * ep, alvo = alvo, dif_em_ep = (m - alvo) / ep) }

testes_ajusta_dlnm_mc <- list(

  t05_recuperacao_contagem_alta = function(f) {                      # ~30 eventos/dia, γ = 1,3, efeito = cb %*% θ
    bf <- .MC$bf; pr <- .MC$proj; R <- .MC$R
    set.seed(20261001)
    a <- .mc_cenario(f, R, function() f$gera_sintetico(4500, eventos_dia = 30, gamma = 1.3, efeito = "theta", bf = bf, theta = pr$theta), "z_w_gama")[[1]]
    set.seed(20261001)
    h <- .mc_cenario(f, R, function() f$gera_sintetico(4500, eventos_dia = 30, gamma = 1.3, efeito = "dobradica", bf = bf), "z_w_gama")[[1]]
    s <- .mc_resumo(a$est, a$se, pr$verdadeiro_theta); g <- .mc_gama(a$gama, 1.3)
    .MC$t05 <- list(theta = s, gama = g, phi_medio = mean(a$phi, na.rm = TRUE), falhou = a$falhou, pacf_alguma_fora = a$pacf_alguma_fora,
                    pacf_media = a$pacf_media, dobradica = .mc_resumo(h$est, h$se, pr$verdadeiro_dobradica),
                    dobradica_vs_theta = .mc_resumo(h$est, h$se, pr$verdadeiro_theta), falhou_dobradica = h$falhou)
    if (s$cobertura < 0.92 || s$cobertura > 0.98) stop("cobertura ", format(s$cobertura), " fora de 0,92–0,98")
    if (abs(s$vies_rel) >= 0.10) stop("viés relativo ", format(s$vies_rel), " ≥ 10%")
    if (abs(g$dif_em_ep) >= 2) stop("γ̂ médio ", format(g$media), " a ", format(g$dif_em_ep), " EP de MC de 1,3")
  },

  t05b_recuperacao_contagem_baixa = function(f) {                    # ~3 eventos/dia (tamanho de Sorocaba)
    bf <- .MC$bf; pr <- .MC$proj; R <- .MC$R
    set.seed(20261001)
    a <- .mc_cenario(f, R, function() f$gera_sintetico(4500, eventos_dia = 3, gamma = 1.3, efeito = "theta", bf = bf, theta = pr$theta), "z_w_gama")[[1]]
    set.seed(20261001)
    h <- .mc_cenario(f, R, function() f$gera_sintetico(4500, eventos_dia = 3, gamma = 1.3, efeito = "dobradica", bf = bf), "z_w_gama")[[1]]
    s <- .mc_resumo(a$est, a$se, pr$verdadeiro_theta)
    .MC$t05b <- list(theta = s, gama = .mc_gama(a$gama, 1.3), phi_medio = mean(a$phi, na.rm = TRUE), falhou = a$falhou,
                     pacf_alguma_fora = a$pacf_alguma_fora, dobradica = .mc_resumo(h$est, h$se, pr$verdadeiro_dobradica),
                     dobradica_vs_theta = .mc_resumo(h$est, h$se, pr$verdadeiro_theta), falhou_dobradica = h$falhou)
    if (s$cobertura < 0.92 || s$cobertura > 0.98) stop("cobertura ", format(s$cobertura), " fora de 0,92–0,98")
  },

  t06_nulo = function(f) {                                           # sem efeito, contagem alta: cobertura do RR = 1
    bf <- .MC$bf; R <- .MC$R
    set.seed(20261001)
    a <- .mc_cenario(f, R, function() f$gera_sintetico(4500, eventos_dia = 30, gamma = 1.3, efeito = "nenhum", bf = bf), "z_w_gama")[[1]]
    s <- .mc_resumo(a$est, a$se, 0)
    .MC$t06 <- list(nulo = s, falhou = a$falhou, phi_medio = mean(a$phi, na.rm = TRUE), pacf_alguma_fora = a$pacf_alguma_fora, pacf_media = a$pacf_media)
    if (s$cobertura < 0.92 || s$cobertura > 0.98) stop("cobertura ", format(s$cobertura), " fora de 0,92–0,98")
  },

  t07_offset = function(f) {                                         # γ = 1, Z_t e temperatura em fase, a = 0,3, sem efeito
    bf <- .MC$bf; R <- .MC$R
    set.seed(20261001)
    a <- .mc_cenario(f, R, function() f$gera_sintetico(4500, eventos_dia = 30, gamma = 1, efeito = "nenhum", bf = bf,
                                                       a_Z = 0.3, fase_Z = f$PARAM_GERADOR$t_fase), c("zw", "z_w_gama", "nenhum"))
    dif <- a$zw$est - a$z_w_gama$est; dif <- dif[is.finite(dif)]
    md <- mean(dif); ep_md <- stats::sd(dif) / sqrt(length(dif))
    nen <- a$nenhum$est[is.finite(a$nenhum$est)]; mn <- mean(nen); ep_mn <- stats::sd(nen) / sqrt(length(nen))
    .MC$t07 <- list(dif_media = md, ep_dif = ep_md, ic_dif = md + c(-1, 1) * 1.96 * ep_md, dif_em_ep = md / ep_md,
                    nenhum_vies = mn, ep_nenhum = ep_mn, ic_nenhum = mn + c(-1, 1) * 1.96 * ep_mn, nenhum_em_ep = mn / ep_mn,
                    zw = .mc_resumo(a$zw$est, a$zw$se, 0), z_w_gama = .mc_resumo(a$z_w_gama$est, a$z_w_gama$se, 0),
                    nenhum = .mc_resumo(a$nenhum$est, a$nenhum$se, 0), gama = .mc_gama(a$z_w_gama$gama, 1),
                    falhou = c(zw = a$zw$falhou, z_w_gama = a$z_w_gama$falhou, nenhum = a$nenhum$falhou))
    if (abs(md / ep_md) >= 2) stop("zw − z_w_gama: |diferença média| = ", format(abs(md / ep_md)), " EP de MC (≥ 2)")
    if (!(mn > 0 && mn / ep_mn > 3)) stop("nenhum: viés ", format(mn), " = ", format(mn / ep_mn), " EP de MC (esperado > 3, positivo)")
  }
)
