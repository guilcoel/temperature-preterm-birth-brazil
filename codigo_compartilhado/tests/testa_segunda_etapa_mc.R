# testa_segunda_etapa_mc.R — teste 5 do prompt da Fase 3 (A2): recuperação da meta-análise por Monte Carlo, com
# 1.000 réplicas de 26 unidades. Dado sintético: coeficientes verdadeiros β + u_i, u_i ~ N(0, Ψ), e estimativas
# y_i ~ N(β + u_i, S_i). As S_i são as vcov reduzidas reais da Fase 2, usadas só como covariâncias (desvio 72d); os
# metapreditores (média e amplitude, de ano inteiro) entram com efeito verdadeiro nulo. A base é a combinada (média dos
# nós e dos Boundary.knots das 26 argvar reais; D2) e o cen é o x50 do eixo médio. Quem chama põe em .R3: argvar, S,
# metapred, eixo, R_mc (réplicas; 1.000) e relata_tmr (TRUE na bateria original; a cobertura da TMR é só reportada).
# Os sorteios de todas as réplicas são feitos antes dos ajustes (a boot_tmr reinicia a semente; complemento C1).

testes_segunda_etapa_mc <- list(

  t05_recuperacao_meta = function(f) {
    r <- .s_reais(); R <- if (is.null(r$R_mc)) 1000L else as.integer(r$R_mc)
    base <- f$base_combinada(r$argvar); ex <- r$eixo
    B <- function(x) unclass(do.call(dlnm::onebasis, c(list(x = x), base)))
    # β: projeção, na base combinada, de um log RR verdadeiro contra o x50 = 0,02 por °C acima do x75 (mínimos quadrados)
    g <- seq(base$Boundary.knots[1], base$Boundary.knots[2], length.out = 301); Xg <- sweep(B(g), 2, B(ex[["p50"]])[1, ])
    beta <- qr.solve(Xg, 0.02 * pmax(g - ex[["p75"]], 0))
    dv99 <- B(ex[["p99"]])[1, ] - B(ex[["p50"]])[1, ]; v99 <- sum(dv99 * beta)
    if (v99 < 0.05) stop("log RR verdadeiro em x99 contra x50 = ", format(v99), " (< 0,05): ajustar β antes de rodar")
    S <- r$S; k <- 4L; n <- length(S); md <- r$metapred
    sdp <- 0.5 * sqrt(colMeans(t(vapply(S, diag, numeric(k))))); Rc <- matrix(0.3, k, k); diag(Rc) <- 1
    Psi <- diag(sdp) %*% Rc %*% diag(sdp)
    tmr_v <- f$busca_tmr(beta, base, ex[["p1"]], ex[["p99"]], ex[["p10"]], ex[["p90"]], ex[["p50"]])$tmr
    .T3$t05_decl <- list(beta = beta, v99 = v99, Psi = Psi, sdp = sdp, tmr_verdadeira = tmr_v, base = base, R = R,
                         S = "vcov reduzidas reais da Fase 2 (só covariâncias)", cen = ex[["p50"]])
    set.seed(20261001); U <- array(stats::rnorm(R * n * k), c(R, n, k)); E <- array(stats::rnorm(R * n * k), c(R, n, k))
    cP <- chol(Psi); cS <- lapply(S, chol)
    lr <- se <- numeric(R); mse <- matrix(NA_real_, R, 4, dimnames = list(NULL, c("blup", "primeira_etapa", "parte_fixa", "predicao_media")))   # predicao_media: só reportada (desvio 74)
    metodo <- character(R); cobre_tmr <- rep(NA, R); dif_blup <- NA_real_
    for (rep in seq_len(R)) {
      th <- t(vapply(seq_len(n), function(i) beta + drop(t(cP) %*% U[rep, i, ]), numeric(k)))
      y <- t(vapply(seq_len(n), function(i) th[i, ] + drop(t(cS[[i]]) %*% E[rep, i, ]), numeric(k)))
      fit <- f$meta_curva(y, S, md); if (fit$status != "ok") stop("réplica ", rep, ": meta_curva falhou")
      metodo[rep] <- paste(fit$metodo, fit$bscov, sep = "/")
      lr[rep] <- sum(dv99 * fit$pred_media$coef); se[rep] <- sqrt(drop(t(dv99) %*% fit$pred_media$vcov %*% dv99))
      cm <- fit$coef_meta; Bm <- t(vapply(c("(Intercept)", "media", "amplitude"), function(t) cm[paste0("y", seq_len(k), ".", t)], numeric(k)))
      fixa <- cbind(1, md$media, md$amplitude) %*% Bm
      bl <- t(vapply(fit$blup, `[[`, numeric(k), "coef"))
      pm <- matrix(fit$pred_media$coef, n, k, byrow = TRUE)
      mse[rep, ] <- c(mean(rowSums((bl - th)^2)), mean(rowSums((y - th)^2)), mean(rowSums((fixa - th)^2)), mean(rowSums((pm - th)^2)))
      if (rep == 1) {                                                 # BLUP = fórmula à mão
        Ps <- fit$Psi; mao <- t(vapply(seq_len(n), function(i) drop(fixa[i, ] + Ps %*% solve(Ps + S[[i]], y[i, ] - fixa[i, ])), numeric(k)))
        dif_blup <- max(abs(mao - bl))
      }
      if (isTRUE(r$relata_tmr)) { bt <- f$boot_tmr(fit$pred_media$coef, fit$pred_media$vcov, base, ex[["p1"]], ex[["p99"]], i = 0)
        cobre_tmr[rep] <- !anyNA(bt$ic) && bt$ic[1] <= tmr_v && tmr_v <= bt$ic[2] }
    }
    z <- stats::qnorm(0.975); cob <- mean(abs(lr - v99) <= z * se); ep_cob <- sqrt(cob * (1 - cob) / R)
    wil <- function(p, n) { d <- 1 + z^2 / n; (p + z^2 / (2 * n)) / d + c(-1, 1) * z / d * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) }
    vies <- mean(lr) - v99; ep_vies <- stats::sd(lr) / sqrt(R); msem <- colMeans(mse)
    .T3$t05 <- list(cobertura = cob, ep_cob = ep_cob, ic_cob = wil(cob, R), vies = vies, ep_vies = ep_vies, vies_rel = vies / v99,
                    ep_vies_rel = ep_vies / v99, mse = msem, dif_blup = dif_blup, metodos = table(metodo),
                    cob_tmr = if (isTRUE(r$relata_tmr)) mean(cobre_tmr) else NA_real_, se_medio = mean(se), dp_lr = stats::sd(lr))
    if (cob < 0.92 || cob > 0.98) stop("cobertura ", format(cob), " fora de 0,92–0,98")
    if (abs(vies / v99) >= 0.10) stop("viés relativo ", format(vies / v99), " ≥ 10%")
    if (!(msem["blup"] < msem["primeira_etapa"] && msem["blup"] < msem["parte_fixa"])) stop("EQM dos BLUPs não é o menor: ", paste(format(msem), collapse = " / "))
    if (!is.finite(dif_blup) || dif_blup > 1e-8) stop("BLUP difere da fórmula à mão: ", format(dif_blup))
  }
)
