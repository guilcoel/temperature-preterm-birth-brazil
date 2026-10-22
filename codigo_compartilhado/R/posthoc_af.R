# posthoc_af.R — análises post hoc da D5 (P1 e P2), versão 1.0. Decisão `spec/decisoes_metodo_20261013_D5_interpretacao_AF.md`
# (item 4) e entradas 78 e 79 do log do Artigo 1. Não muda nenhuma análise especificada.
# Requer, no mesmo ambiente, as funções de segunda_etapa.R da tag segunda_etapa-v1.0 (meta_curva, busca_tmr, curva,
# componentes_attrdl, semeia), sem alterá-las, e o MASS do renv.lock. Nenhuma função grava arquivo ou devolve série diária.
#
# Funções:
#   wald_curva(coef, vcov): P1, W = b' V^-1 b, gl = length(b), p pela qui-quadrado.
#   sorteia_nulo(S): um sorteio theta_i* ~ N(0, S_i) por unidade, na ordem da lista, com MASS::mvrnorm (sem semente).
#   replica_nula(theta, S, metapred, dados, base, eixo, attrdl, ajusta): uma réplica da P2 (D5, item 4, passos 3 a 6):
#     meta_curva (mesma sequência de estabilidade e mesma definição de falha); MRT BLUP pela busca_tmr na grade p1–p99
#     de cada unidade, com a argvar da cross-basis (a mesma que a attrdl usa); AF forward pontual (attrdl com sim =
#     FALSE) nos componentes total, calor e frio contra a MRT da réplica; RR combinados no x99 e no x1 contra a MRT
#     combinada da réplica; número de MRT no p99 e no p1 pelo índice da grade. Não refaz a semente nem consome o gerador.
#   p2_nulo(R, S, metapred, dados, base, eixo, attrdl, ajusta, guarda_sorteios, progresso): semeia(0) uma única vez
#     antes do laço (D5, item 4, passo 1) e R réplicas; falhas contadas, nunca substituídas.
#   resumo_p2(tab, af_obs): mediana e p2,5 a p97,5; a única comparação (AF observada > p97,5), também com as falhas nos
#     dois extremos; descritivas sem p.
#   testa_base_mrt(basis, argvar_busca, grade): pré-condição (entrada 78(c)(i)): base da attrdl contra a da busca.
#   testa_contribuicoes(coef, argvar_busca, argvar_attrdl, x, p1, p99, mrt, passo): folga g = f(MRT) − mín f na grade
#     fina, com a base da busca da MRT, e menor Delta_t = f(x_t) − f(MRT) nos dias dentro do p1–p99, com a base que a
#     attrdl reconstrói (entrada 78(c)(ii)); exige Delta_t ≥ −max(g, 0) − 1e-12. Com as duas bases iguais, a condição
#     equivale a f(x_t) ≥ mín f na grade fina − 1e-12; com bases diferentes, aparecem dias abaixo de −g.
#
# `dados` é uma lista por unidade, na ordem de S, com: x e cases (as linhas da janela), basis (a cross-basis da série
# completa e consecutiva, com aquecimento), p1, p99, p10, p90, p50, p2_5 e p97_5 (grade de percentis da unidade).

wald_curva <- function(coef, vcov) {
  b <- as.numeric(coef); V <- as.matrix(vcov)
  stopifnot(length(b) >= 1, nrow(V) == length(b), ncol(V) == length(b))
  w <- drop(crossprod(b, solve(V, b)))
  list(W = w, gl = length(b), p = stats::pchisq(w, length(b), lower.tail = FALSE))
}

sorteia_nulo <- function(S) {
  k <- nrow(S[[1]]); stopifnot(all(vapply(S, nrow, 0L) == k))
  t(vapply(S, function(s) MASS::mvrnorm(1, mu = rep(0, k), Sigma = s), numeric(k)))
}

replica_nula <- function(theta, S, metapred, dados, base, eixo, attrdl, ajusta = mixmeta::mixmeta) {
  mc <- meta_curva(theta, S, metapred, ajusta = ajusta)
  out <- list(falhou = mc$status != "ok", metodo = if (mc$status == "ok") paste(mc$metodo, mc$bscov, sep = "/") else "falhou",
              af_total = NA_real_, af_calor = NA_real_, af_frio = NA_real_, rr_x99 = NA_real_, rr_x1 = NA_real_,
              tmr_combinada = NA_real_, n_mrt_p99 = NA_integer_, n_mrt_p1 = NA_integer_)
  if (out$falhou) return(out)
  n <- length(dados); an <- matrix(NA_real_, n, 3, dimnames = list(NULL, c("total", "calor", "frio"))); den <- numeric(n)
  sup <- inf <- logical(n)
  for (k in seq_len(n)) {
    d <- dados[[k]]; b <- mc$blup[[k]]; av <- attr(d$basis, "argvar")
    tb <- busca_tmr(b$coef, av, d$p1, d$p99, d$p10, d$p90, d$p50)
    inf[k] <- tb$indice == 1L; sup[k] <- tb$indice == tb$n_grade
    rg <- componentes_attrdl(tb$tmr, d$p2_5, d$p97_5)
    for (cmp in colnames(an))
      an[k, cmp] <- attrdl(d$x, d$basis, d$cases, coef = b$coef, vcov = b$vcov, type = "an", dir = "forw", tot = TRUE,
                           cen = tb$tmr, range = rg[[cmp]], sim = FALSE)
    den[k] <- sum(d$cases)
  }
  tc <- busca_tmr(mc$pred_media$coef, base, eixo[["p1"]], eixo[["p99"]], eixo[["p10"]], eixo[["p90"]], eixo[["p50"]])
  cc <- curva(mc$pred_media$coef, mc$pred_media$vcov, base, unname(eixo[c("p99", "p1")]), tc$tmr)
  out$af_total <- sum(an[, "total"]) / sum(den); out$af_calor <- sum(an[, "calor"]) / sum(den); out$af_frio <- sum(an[, "frio"]) / sum(den)
  out$rr_x99 <- cc$rr[1]; out$rr_x1 <- cc$rr[2]; out$tmr_combinada <- tc$tmr; out$n_mrt_p99 <- sum(sup); out$n_mrt_p1 <- sum(inf)
  out
}

p2_nulo <- function(R, S, metapred, dados, base, eixo, attrdl, ajusta = mixmeta::mixmeta, guarda_sorteios = FALSE, progresso = NULL) {
  stopifnot(R >= 1, length(S) == length(dados), nrow(metapred) == length(S))
  semeia(0)                                                       # D5, item 4, passo 1: uma única vez, antes do laço
  linhas <- vector("list", R); sorteios <- if (guarda_sorteios) vector("list", R) else NULL
  for (r in seq_len(R)) {
    th <- sorteia_nulo(S); if (guarda_sorteios) sorteios[[r]] <- th
    z <- replica_nula(th, S, metapred, dados, base, eixo, attrdl, ajusta)
    linhas[[r]] <- data.frame(replica = r, falhou = z$falhou, metodo = z$metodo, af_total = z$af_total, af_calor = z$af_calor,
                              af_frio = z$af_frio, rr_x99 = z$rr_x99, rr_x1 = z$rr_x1, tmr_combinada = z$tmr_combinada,
                              n_mrt_p99 = z$n_mrt_p99, n_mrt_p1 = z$n_mrt_p1, stringsAsFactors = FALSE)
    if (!is.null(progresso)) progresso(r)
  }
  tab <- do.call(rbind, linhas); rownames(tab) <- NULL
  if (guarda_sorteios) attr(tab, "sorteios") <- sorteios
  tab
}

resumo_p2 <- function(tab, af_obs) {
  ok <- !tab$falhou; nf <- sum(tab$falhou); q <- function(v) unname(stats::quantile(v, c(0.5, 0.025, 0.975), type = 7))
  af <- tab$af_total[ok]; qa <- q(af)
  lim <- function(v) unname(stats::quantile(c(af, rep(v, nf)), 0.975, type = 7))     # falhas nos extremos (±1e300 = ±infinito)
  p975_inf <- if (nf) lim(-1e300) else qa[3]; p975_sup <- if (nf) lim(1e300) else qa[3]
  desc <- do.call(rbind, lapply(c("af_calor", "af_frio", "rr_x99", "rr_x1", "n_mrt_p99", "n_mrt_p1"), function(v) {
    x <- q(tab[[v]][ok]); data.frame(quantidade = v, mediana = x[1], p2_5 = x[2], p97_5 = x[3], stringsAsFactors = FALSE) }))
  list(n = nrow(tab), n_falhas = nf, replicas_falhas = tab$replica[tab$falhou], metodos = table(tab$metodo),
       af_total = c(mediana = qa[1], p2_5 = qa[2], p97_5 = qa[3]), af_obs = af_obs, passa = af_obs > qa[3],
       p97_5_falhas_inf = p975_inf, p97_5_falhas_sup = p975_sup, passa_falhas_inf = af_obs > p975_inf, passa_falhas_sup = af_obs > p975_sup,
       descritivas = desc)
}

testa_base_mrt <- function(basis, argvar_busca, grade) {
  av_attrdl <- attr(basis, "argvar"); av_attrdl$cen <- NULL                # como a attrdl (l. 55 e 124)
  Ba <- unclass(do.call(dlnm::onebasis, c(list(x = grade), av_attrdl)))
  Bb <- unclass(do.call(dlnm::onebasis, c(list(x = grade), argvar_busca)))
  if (!identical(dim(Ba), dim(Bb))) return(list(dif = Inf, ok = FALSE))
  d <- max(abs(Ba - Bb)); list(dif = d, ok = is.finite(d) && d <= 1e-12)
}

testa_contribuicoes <- function(coef, argvar_busca, argvar_attrdl, x, p1, p99, mrt, passo = 0.001) {
  argvar_attrdl$cen <- NULL                                              # como a attrdl (l. 55 e 124)
  fb <- function(z) drop(unclass(do.call(dlnm::onebasis, c(list(x = z), argvar_busca))) %*% coef)
  fa <- function(z) drop(unclass(do.call(dlnm::onebasis, c(list(x = z), argvar_attrdl))) %*% coef)
  gf <- seq(p1, p99, by = passo); if (p99 - gf[length(gf)] > 1e-8) gf <- c(gf, p99)
  g <- fb(mrt) - min(fb(gf))
  dentro <- x >= p1 & x <= p99; dl <- fa(x[dentro]) - fa(mrt)
  list(g = g, min_delta = if (any(dentro)) min(dl) else NA_real_, n_dentro = sum(dentro),
       ok = g >= -1e-12 && (!any(dentro) || all(dl >= -max(g, 0) - 1e-12)))
}
