# fluxo_c_fase4.R — fluxo comum das análises da Parte C da Fase 4 do Artigo 1 (C2 a C4), carregado por sys.source pelos
# scripts 72 a 79 (mensagem "C2, C3 e C4 em lote", 19/10/2026; fluxo da C1 sem o critério de concordância). Não roda nada
# sozinho, não lê dado e não grava arquivo.
# Exige, no ambiente de quem chama: f (ajusta_dlnm.R e segunda_etapa.R das tags v1.1), teste3_fonte_independente (tests/),
#   ordem (as 26 concentrações na ORDEM_CONCENTRACOES), nome (nomes por código), md (metapreditores média e amplitude da
#   tmean_nucleo, linhas = ordem; P5), CAL (calendário do principal) e AL7 (arglag do principal).
# roda_analise(cfg): uma análise inteira:
#   - 1ª etapa em cfg$incluir (padrão: as 26), com o fallback da D7, M7, na forma corrigida depois da auditoria da C1 (M1):
#     passo 1 (só a arglag, estratos 0–1, 2–4 e 5–7) por concentração, só para os motivos da §5, critério 4 (não
#     convergência, aliasamento na cross-basis, vcov) e só no lag 0–7; falha por outro motivo, ou num lag sem estratos
#     definidos, é registrada e a concentração sai da 2ª etapa (sem pular para o passo 2; A1-97(c), N3); passo 2 (argvar ns
#     p50/p90 nas incluídas, com a arglag em estratos nas que precisaram do passo 1 ou falharam nele) só no lag 0–7 e se
#     alguma falha elegível restar depois do passo 1; o que ainda falhar sai da 2ª etapa;
#   - φ (mínimo, mediana, máximo); teste 3 da D6, 2.2 (teste3_fonte_independente + decide_teste3) em cada cross-basis ns
#     ou bs, com a grade p1–p99 e os percentis da concentração na exposição da análise, cen = p50 da concentração;
#   - meta_curva (média + amplitude) e confere_meta; base_combinada; confere_eixo; TMR combinada na grade de 0,1 °C entre
#     x1 e o limite superior do eixo (x99; x50 na estação quente), borda pelo índice; IC bootstrap da TMR (1.000 sorteios,
#     semente 20261001, i = 0); RR no x99 e no x1 contra a TMR, com IC; na borda em x1 ou x99, aquele contraste vale 1 por
#     construção (marcado) e sai o RR contra a mediana do eixo como descritivo (D13, item 3; D10, 1d); Q e I² residuais;
#     Wald dos metapreditores.
#   cfg: id, rotulo, dados(r) (data.frame de uma concentração, com as colunas da spec), extra (lista para spec_agudo, além
#     de argvar, arglag e cen), nos(r) (lista p10, p75, p90, p50), fun ("ns" ou "bs"), degree (bs), lag, eixo (vetor
#     nomeado de 101 percentis), eixo_p, grade (matriz ordem × 101), serie_nos(r), xcol (coluna da exposição), incluir,
#     tmr_sup ("p99" ou "p50"), argvar_s2 (TRUE: argvar ns p50/p90 desde o início), confere(z) (conferência extra por ajuste,
#     que devolve TRUE/FALSE), devolve_matriz.

MOTIVOS_FALLBACK <- c("não convergiu", "coeficiente da cross-basis aliasado", "vcov da cross-basis não positiva-definida", "vcov indisponível", "vcov reduzida não positiva-definida")
PCT_T3 <- c("p99", "p1", "p95", "p90", "p10", "p5")
elegivel_fb <- function(z) identical(z$status, "falhou") && !is.na(z$mensagem) && all(strsplit(z$mensagem, "; ", fixed = TRUE)[[1]] %in% MOTIVOS_FALLBACK)
spec_c <- function(desfecho = "ptb", exposicao = "tmean_nucleo", janela = "janela_principal", lag = 7, argvar, arglag, offset = "z_w_gama", cen, ...) {
  a <- list(desfecho = desfecho, exposicao = exposicao, janela = janela, lag = lag, argvar = argvar, arglag = arglag, offset = offset, cen = cen)
  m <- list(...); a[names(m)] <- m; do.call(f$spec_agudo, a)
}
roda_analise <- function(cfg) {
  tk <- Sys.time(); inc0 <- if (is.null(cfg$incluir)) ordem else cfg$incluir
  lag <- if (is.null(cfg$lag)) 7L else cfg$lag; fun <- if (is.null(cfg$fun)) "ns" else cfg$fun; tmr_sup <- if (is.null(cfg$tmr_sup)) "p99" else cfg$tmr_sup
  al0 <- if (lag == 7L) AL7 else list(fun = "ns", knots = dlnm::logknots(lag, nk = 2), intercept = TRUE)
  AL_P1 <- if (lag == 7L) list(fun = "strata", breaks = c(2, 5), intercept = TRUE) else NULL
  av_de <- function(r, passo2) { k <- cfg$nos(r)
    if (passo2 || isTRUE(cfg$argvar_s2)) return(list(fun = "ns", knots = c(k$p50, k$p90)))
    if (fun == "bs") list(fun = "bs", knots = c(k$p10, k$p75, k$p90), degree = cfg$degree) else list(fun = "ns", knots = c(k$p10, k$p75, k$p90)) }
  sp <- function(r, passo2 = FALSE, al = al0) { e <- cfg$extra; e$argvar <- av_de(r, passo2); e$arglag <- al; e$cen <- cfg$nos(r)$p50; e$lag <- lag; do.call(spec_c, e) }
  ajusta <- function(d, s) f$ajusta_dlnm(d, s, devolve_matriz = isTRUE(cfg$devolve_matriz))
  dd <- lapply(inc0, cfg$dados); names(dd) <- inc0
  fits <- list(); passo <- setNames(rep(0L, length(inc0)), inc0); motivo <- setNames(rep("", length(inc0)), inc0); precisou <- setNames(rep(FALSE, length(inc0)), inc0)
  for (r in inc0) {
    z <- ajusta(dd[[r]], sp(r))
    if (!identical(z$status, "ok")) {
      precisou[r] <- TRUE
      if (elegivel_fb(z) && !is.null(AL_P1)) { z1 <- ajusta(dd[[r]], sp(r, al = AL_P1))
        if (identical(z1$status, "ok")) { z <- z1; passo[r] <- 1L } else motivo[r] <- paste("passo 1 falhou:", z1$mensagem)
      } else motivo[r] <- if (!elegivel_fb(z)) paste("falha fora do §5, critério 4:", z$mensagem) else paste("sem estratos definidos para o lag 0–", lag, ": ", z$mensagem, sep = "")
    }
    fits[[r]] <- z
  }
  falha_eleg <- inc0[!vapply(fits, function(z) identical(z$status, "ok"), TRUE) & grepl("^passo 1 falhou", motivo)]
  passo2 <- length(falha_eleg) > 0 && lag == 7L
  if (passo2) { for (r in inc0) { fits[[r]] <- ajusta(dd[[r]], sp(r, passo2 = TRUE, al = if (precisou[r]) AL_P1 else al0))
    motivo[r] <- if (identical(fits[[r]]$status, "ok")) "" else paste("passo 2 falhou:", fits[[r]]$mensagem) }; passo[] <- 2L }
  ok_c <- vapply(fits, function(z) identical(z$status, "ok"), TRUE)
  if (!is.null(cfg$confere)) { cf <- vapply(inc0[ok_c], function(r) isTRUE(cfg$confere(fits[[r]])), TRUE); if (!all(cf)) stop("análise ", cfg$id, ": conferência extra falhou em ", paste(inc0[ok_c][!cf], collapse = ", ")) }
  inc <- inc0[ok_c]; phi <- vapply(fits[inc], `[[`, 0, "phi"); k <- length(fits[[inc[1]]]$reduzida$coef)
  Y <- t(vapply(inc, function(r) unname(fits[[r]]$reduzida$coef), numeric(k))); S <- lapply(inc, function(r) unname(fits[[r]]$reduzida$vcov))
  mdk <- md[inc, , drop = FALSE]
  mc <- f$meta_curva(Y, S, mdk); f$confere_meta(mc, c("media", "amplitude"), Y)
  base <- f$base_combinada(lapply(inc, function(r) fits[[r]]$base$argvar))
  eixo <- cfg$eixo; ep <- cfg$eixo_p; f$confere_eixo(eixo[["p1"]], eixo[["p99"]], unname(eixo))
  pc <- mc$pred_media$coef; pv <- mc$pred_media$vcov
  tc <- f$busca_tmr(pc, base, eixo[["p1"]], eixo[[tmr_sup]], eixo[["p10"]], eixo[["p90"]], eixo[["p50"]])
  bc <- f$boot_tmr(pc, pv, base, eixo[["p1"]], eixo[[tmr_sup]], i = 0)
  q <- f$posicao_no_eixo(tc$tmr, unname(eixo), ep)
  cc <- f$curva(pc, pv, base, unname(eixo[c("p99", "p1")]), tc$tmr)
  lado <- if (!tc$fronteira) NA_character_ else if (tc$indice == 1L) "x1" else if (tmr_sup == "p99") "x99" else "x50"
  cm <- if (lado %in% c("x1", "x99")) f$curva(pc, pv, base, unname(eixo[c("p99", "p1")]), eixo[["p50"]]) else NULL
  t3 <- do.call(rbind, lapply(seq_along(inc), function(i) { r <- inc[i]; av <- fits[[r]]$base$argvar; g <- cfg$grade[r, ]
    x <- c(f$grade_tmr(g[["p1"]], g[["p99"]]), unname(g[PCT_T3])); xcb <- dd[[r]][[cfg$xcol]]
    fz <- if (identical(av$fun, "bs")) "bs" else "ns"; pr <- if (length(av$knots) == 2) c(0.50, 0.90) else c(0.10, 0.75, 0.90)
    v <- teste3_fonte_independente(f$curva, mc$blup[[i]]$coef, av, x, g[["p50"]], cfg$serie_nos(r), pr, xcb, fun = fz, degree = if (fz == "bs") av$degree else NULL)
    d <- f$decide_teste3(v, x, xcb)
    data.frame(recorte_principal = r, dif = v$dif, controle_p1p99 = v$dif_controle_p1p99, ok = d$ok, falhas = paste(d$falhas, collapse = "; "), stringsAsFactors = FALSE) }))
  h <- mc$heterogeneidade$residual
  linha <- data.frame(id = cfg$id, rotulo = cfg$rotulo, incluidas = length(inc), excluidas = paste(nome[inc0[!ok_c]], collapse = ", "),
                      motivos_exclusao = paste(motivo[inc0[!ok_c]], collapse = " | "),
                      passo_fallback = if (passo2) "passo 2" else if (any(passo == 1L)) paste0("passo 1 em ", paste(nome[inc0[passo == 1L]], collapse = ", ")) else "nenhum",
                      tmr = tc$tmr, percentil_tmr = q, fronteira = tc$fronteira, lado_borda = lado, ic_tmr_li = bc$ic[1], ic_tmr_ls = bc$ic[2],
                      x99 = eixo[["p99"]], rr99 = cc$rr[1], rr99_li = cc$rr_li[1], rr99_ls = cc$rr_ls[1], x1 = eixo[["p1"]], rr01 = cc$rr[2], rr01_li = cc$rr_li[2], rr01_ls = cc$rr_ls[2],
                      borda99 = identical(lado, "x99"), borda01 = identical(lado, "x1"),
                      rr99_mediana = if (is.null(cm)) NA else cm$rr[1], rr99_mediana_li = if (is.null(cm)) NA else cm$rr_li[1], rr99_mediana_ls = if (is.null(cm)) NA else cm$rr_ls[1],
                      rr01_mediana = if (is.null(cm)) NA else cm$rr[2], rr01_mediana_li = if (is.null(cm)) NA else cm$rr_li[2], rr01_mediana_ls = if (is.null(cm)) NA else cm$rr_ls[2],
                      phi_min = min(phi), phi_med = stats::median(phi), phi_max = max(phi), metodo = mc$metodo, bscov = mc$bscov,
                      Q = h$Q, gl = h$df, p_Q = h$p, I2 = h$I2, wald_media_p = mc$wald$p[mc$wald$termo == "media"], wald_amplitude_p = mc$wald$p[mc$wald$termo == "amplitude"],
                      teste3_ok = sum(t3$ok), teste3_n = nrow(t3), minutos = as.numeric(difftime(Sys.time(), tk, units = "mins")), stringsAsFactors = FALSE)
  enxuto <- lapply(fits, function(z) z[intersect(c("status", "mensagem", "avisos", "convergiu", "coef_cb", "vcov_cb", "dim_cb", "base", "boundary_knots", "reduzida", "gama", "ep_gama", "phi", "qaic", "n"), names(z))])
  list(linha = linha, fits = enxuto, fits_completos = if (isTRUE(cfg$guardar_completos)) fits else NULL, passo = passo, motivo = motivo, meta = mc, base = base, tmr = tc, boot = bc, curva = cc,
       mediana = cm, teste3 = t3, Y = Y, S = S, incluidas = inc, dados = if (isTRUE(cfg$guardar_dados)) dd else NULL)
}
fmt_linhas <- function(tab, br, icf) data.frame(Análise = tab$rotulo, `TMR °C (percentil)` = sprintf("%s (%s)%s", br(tab$tmr, 1), br(100 * tab$percentil_tmr, 1), ifelse(tab$fronteira, paste0(" [borda ", tab$lado_borda, "]"), "")),
  `IC da TMR` = sprintf("%s a %s", br(tab$ic_tmr_li, 1), br(tab$ic_tmr_ls, 1)),
  `RR x99 (IC)` = ifelse(tab$borda99, paste0("1 (borda); contra a mediana ", icf(tab$rr99_mediana, tab$rr99_mediana_li, tab$rr99_mediana_ls)), icf(tab$rr99, tab$rr99_li, tab$rr99_ls)),
  `RR x1 (IC)` = ifelse(tab$borda01, paste0("1 (borda); contra a mediana ", icf(tab$rr01_mediana, tab$rr01_mediana_li, tab$rr01_mediana_ls)), icf(tab$rr01, tab$rr01_li, tab$rr01_ls)),
  N = tab$incluidas, Fallback = tab$passo_fallback, `φ (mín.; med.; máx.)` = sprintf("%s; %s; %s", br(tab$phi_min, 3), br(tab$phi_med, 3), br(tab$phi_max, 3)),
  `Teste 3` = paste0(tab$teste3_ok, "/", tab$teste3_n), `Q (gl); I²` = sprintf("%s (%d); %s%%", br(tab$Q, 1), as.integer(tab$gl), br(tab$I2, 1)), check.names = FALSE)
