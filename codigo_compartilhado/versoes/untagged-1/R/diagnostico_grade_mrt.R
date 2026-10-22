# diagnostico_grade_mrt.R — diagnóstico da grade da MRT, versão 1.0 (errata da D5 de 14/10/2026, item 2; entrada 80 do
# log do Artigo 1). Só leitura: não reajusta modelo nem recalcula MRT, AF, BLUP ou bootstrap. A grade examinada é a da
# grade_tmr da tag segunda_etapa-v1.0, passada por quem chama. O Artigo 2 reusa estas funções (errata, item 6).
#
# Duas bases, como na testa_contribuicoes (posthoc_af.R): argvar_busca (a da busca da MRT, usada na grade, nos extremos
# da célula e em f″) e argvar_attrdl (a que a attrdl reconstrói de attr(cb, "argvar"), sem o cen, usada nos dias). Nos
# dados observados as duas são iguais (teste (i) do item 2); separá-las deixa o diagnóstico acusar base trocada.
#
# Funções:
#   f_ns(z, argvar, coef): f(z) = B(z)·coef com a base de dlnm::onebasis, sem o cen.
#   f2_ns(z, argvar, coef): f″(z) analítica para argvar ns, com a construção do splines::ns (splineDesign com derivs = 2
#     e a mesma projeção da restrição natural nos Boundary.knots); só dentro dos Boundary.knots.
#   f2_num(z, argvar, coef, h): f″ por segunda diferença central, passo h (conferência; 1e-3 °C por padrão).
#   distancia_celulas(j, k): número de células entre a célula [g_j, g_(j+1)] e o ponto g_k da MRT; 0 quando a MRT é um
#     dos extremos da célula (vizinha).
#   classifica_celula(M, h, u_min, f_a, f_b, f_x, dist, tol): cota = M·h²/8; razão_MRT = −u_min/cota; razão_célula =
#     [mín(f(a), f(b)) − f(x*)]/cota; classe "a, vizinha" (dist = 0) ou "a, quase empate de mínimos locais" (dist > 0)
#     se M > 0 e as duas razões ≤ 1 + tol; senão "anomala".
#   parte1_grade(p1, p99, mrt, grade): n da grade, primeiro ponto, último ponto do seq de 0,1 °C, se o p99 foi
#     acrescentado (p99 − último do seq > 1e-8, o critério da grade_tmr), se o último ponto é o p99 (|dif| ≤ 1e-8) e
#     |MRT − p99|.
#   diagnostica_minimo(coef, argvar_busca, argvar_attrdl, x, p1, p99, mrt, grade, min_delta_gravado, tol_gravado,
#     passo_num): u_t = f(x_t) − f(MRT) nos dias com x_t no p1–p99 (base da attrdl; mesma expressão da
#     testa_contribuicoes); u_min; com u_min < −1e-8: célula [a, b] do dia do mínimo x* por findInterval, distância,
#     última célula, célula parcial (b = p99 e b − a < 0,1 − 1e-8), M = máx f″ em [a, b] (extremos e nós internos da
#     argvar_busca na célula), analítico e numérico, e a classe com cada um. Classes: "a, …", "b" (x* além do último ou
#     aquém do primeiro ponto da grade: p99 ou p1 fora dela), "anomala", "parada" (u_min diferente do gravado em mais de
#     tol_gravado). Não devolve x* nem a data do dia do mínimo.

f_ns <- function(z, argvar, coef) { av <- argvar; av$cen <- NULL; drop(unclass(do.call(dlnm::onebasis, c(list(x = z), av))) %*% coef) }

f2_ns <- function(z, argvar, coef) {
  if (!identical(argvar$fun, "ns")) stop("f2_ns: argvar não é ns")
  bk <- argvar$Boundary.knots; kn <- sort(argvar$knots); ic <- isTRUE(argvar$intercept)
  if (any(z < bk[1] - 1e-12 | z > bk[2] + 1e-12)) stop("f2_ns: z fora dos Boundary.knots")
  ak <- sort(c(rep(bk, 4L), kn))
  B2 <- splines::splineDesign(ak, z, ord = 4L, derivs = rep(2L, length(z)))
  const <- splines::splineDesign(ak, bk, ord = 4L, derivs = c(2L, 2L))
  if (!ic) { const <- const[, -1, drop = FALSE]; B2 <- B2[, -1, drop = FALSE] }
  qc <- qr(t(const)); B2 <- as.matrix(t(qr.qty(qc, t(B2))))[, -(1L:2L), drop = FALSE]
  drop(B2 %*% coef)
}

f2_num <- function(z, argvar, coef, h = 1e-3) (f_ns(z + h, argvar, coef) - 2 * f_ns(z, argvar, coef) + f_ns(z - h, argvar, coef)) / h^2

distancia_celulas <- function(j, k) if (k <= j) j - k else k - (j + 1L)

classifica_celula <- function(M, h, u_min, f_a, f_b, f_x, dist, tol = 1e-6) {
  cota <- M * h^2 / 8; r_mrt <- -u_min / cota; r_cel <- (min(f_a, f_b) - f_x) / cota
  ok <- is.finite(M) && M > 0 && r_mrt <= 1 + tol && r_cel <= 1 + tol
  list(cota = cota, razao_mrt = r_mrt, razao_celula = r_cel,
       classe = if (!ok) "anomala" else if (dist == 0) "a, vizinha" else "a, quase empate de mínimos locais")
}

parte1_grade <- function(p1, p99, mrt, grade) {
  sq <- seq(p1, p99, by = 0.1); n <- length(grade)
  data.frame(n_grade = n, primeiro = grade[1], primeiro_eh_p1 = abs(grade[1] - p1) <= 1e-8, ultimo_seq = sq[length(sq)],
             p99_acrescentado = (p99 - sq[length(sq)]) > 1e-8, ultimo = grade[n], ultimo_eh_p99 = abs(grade[n] - p99) <= 1e-8,
             mrt_no_p99 = abs(mrt - p99) <= 1e-8, dif_mrt_p99 = abs(mrt - p99), stringsAsFactors = FALSE)
}

diagnostica_minimo <- function(coef, argvar_busca, argvar_attrdl, x, p1, p99, mrt, grade, min_delta_gravado = NULL,
                               tol_gravado = 1e-13, passo_num = 1e-3) {
  dentro <- x >= p1 & x <= p99; xd <- x[dentro]
  u <- f_ns(xd, argvar_attrdl, coef) - f_ns(mrt, argvar_attrdl, coef); i <- which.min(u); u_min <- u[i]; xs <- xd[i]
  out <- data.frame(n_dentro = sum(dentro), u_min = u_min, dif_gravado = NA_real_, a = NA_real_, b = NA_real_, h = NA_real_,
                    distancia = NA_integer_, ultima = NA, parcial = NA, M = NA_real_, M_num = NA_real_, cota = NA_real_,
                    razao_mrt = NA_real_, razao_celula = NA_real_, razao_mrt_num = NA_real_, razao_celula_num = NA_real_,
                    classe = NA_character_, classe_num = NA_character_, motivo = "", stringsAsFactors = FALSE)
  if (!is.null(min_delta_gravado)) {
    out$dif_gravado <- abs(u_min - min_delta_gravado)
    if (!(out$dif_gravado <= tol_gravado)) { out$classe <- out$classe_num <- "parada"; out$motivo <- "u_min difere do gravado"; return(out) }
  }
  if (u_min >= -1e-8) { out$motivo <- "u_min >= -1e-8: fora da Parte 2"; return(out) }
  n <- length(grade)
  if (xs > grade[n] + 1e-8 || xs < grade[1] - 1e-8) {
    out$classe <- out$classe_num <- "b"; out$motivo <- "dia do mínimo fora dos pontos extremos da grade"; return(out) }
  j <- min(findInterval(xs, grade, rightmost.closed = TRUE), n - 1L); a <- grade[j]; b <- grade[j + 1L]
  k <- which.min(abs(grade - mrt))
  if (abs(grade[k] - mrt) > 1e-8) { out$classe <- out$classe_num <- "anomala"; out$motivo <- "MRT não é ponto da grade"; return(out) }
  dist <- distancia_celulas(j, k); kn <- argvar_busca$knots; zk <- c(a, b, kn[kn > a & kn < b])
  M <- max(f2_ns(zk, argvar_busca, coef)); Mn <- max(f2_num(zk, argvar_busca, coef, passo_num))
  fa <- f_ns(a, argvar_busca, coef); fb <- f_ns(b, argvar_busca, coef); fx <- f_ns(xs, argvar_attrdl, coef)
  ca <- classifica_celula(M, b - a, u_min, fa, fb, fx, dist); cn <- classifica_celula(Mn, b - a, u_min, fa, fb, fx, dist)
  out$a <- a; out$b <- b; out$h <- b - a; out$distancia <- as.integer(dist); out$ultima <- j == n - 1L
  out$parcial <- abs(b - p99) <= 1e-8 && (b - a) < 0.1 - 1e-8; out$M <- M; out$M_num <- Mn; out$cota <- ca$cota
  out$razao_mrt <- ca$razao_mrt; out$razao_celula <- ca$razao_celula; out$razao_mrt_num <- cn$razao_mrt; out$razao_celula_num <- cn$razao_celula
  out$classe <- ca$classe; out$classe_num <- cn$classe
  if (ca$classe != cn$classe) out$motivo <- "f″ analítica e numérica mudam a classe"
  out
}
