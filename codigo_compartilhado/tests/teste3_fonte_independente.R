# teste3_fonte_independente.R — teste 3 da D2, na versão por desfecho da errata da D6 (item 2.2;
# spec/decisoes_metodo_20261013_D6_respostas_A2.md), para a segunda_etapa v1.0.1, só de testes (entrada 86 do log do A1).
#
# A curva de cada concentração é prevista também com uma base de fonte independente da argvar, centrada na mesma cen:
#   splines::ns(x, knots = quantile(serie_nos, probs_nos, type = 7), Boundary.knots = range(x_cb), intercept = FALSE)
#   e, na S1, splines::bs(..., degree = 2) com os mesmos argumentos. As duas predições têm de coincidir até 1e-8.
# A independência está na origem dos nós e das fronteiras, não no código da spline: o dlnm usa splines::ns e splines::bs.
#
# Tabela da D6, item 2 (serie_nos, probs_nos e x_cb por análise):
#   | Análise                                  | serie_nos (relida da base)                           | probs_nos             | x_cb                                      |
#   | Agudos, principal                        | tmean_nucleo diária de 2012-01-01 a 2024-12-31       | p10/p75/p90           | série da janela mais L = 7 dias           |
#   | Agudos, lag 0–14 e 0–21                  | idem                                                 | idem                  | janela mais L = 14 ou 21 dias             |
#   | Agudos, S2 / estação quente / tmean_mun / | a série de exposição da sensibilidade (estação       | p50/p90 (S2) ou       | janela mais L dias da mesma série         |
#   |   Tmax, Tmin, AT                         |   quente: só novembro a março)                       |   p10/p75/p90         |                                           |
#   | PIG                                      | médias de 7 dias alinhadas em dum_est, 2011-04-17 a  | p10/p75/p90           | todos os valores da matriz s01…s37        |
#   |                                          |   2024-03-05 (§1.2)                                  |                       |   passada ao crossbasis                   |
# Controle negativo: com as fronteiras trocadas (pela amplitude p1–p99 da serie_nos, sempre; e por range(serie_nos),
# que só tem poder quando range(x_cb) ≠ range(serie_nos), nota 6 da conformidade da D6, 3.4), a diferença tem de ser > 1e-8.
#
# teste3_fonte_independente(curva, coef, argvar, x, cen, serie_nos, probs_nos, x_cb, fun = c("ns", "bs"), degree = NULL)
#   curva: a função curva da segunda_etapa carregada por quem chama (assim, um mutante entra pela cópia); é chamada com
#     vcov = diag(length(coef)), porque o log RR não depende da vcov.
#   Devolve: dif (diferença máxima entre o log RR da fonte independente e o da curva()), dif_nos (argvar$knots contra
#     os nós recalculados), dif_fronteiras (argvar$Boundary.knots contra range(x_cb)), dif_controle_p1p99 e
#     dif_controle_serie (o mesmo cálculo com fronteiras c(p1, p99) da serie_nos e com range(serie_nos)).
#   Não decide: quem decide é quem chama.
#   x e cen têm de ficar dentro das fronteiras: no bs, fora delas sai aviso, que o roda_testes converte em erro.

teste3_fonte_independente <- function(curva, coef, argvar, x, cen, serie_nos, probs_nos, x_cb, fun = c("ns", "bs"), degree = NULL) {
  fun <- match.arg(fun)
  if (fun == "bs" && is.null(degree)) stop("teste3_fonte_independente: bs exige degree")
  nos <- unname(stats::quantile(serie_nos, probs_nos, type = 7))
  lr_ind <- function(bk) {
    b <- if (fun == "ns") splines::ns(x, knots = nos, Boundary.knots = bk, intercept = FALSE) else
      splines::bs(x, knots = nos, Boundary.knots = bk, degree = degree, intercept = FALSE)
    bc <- stats::predict(b, cen)
    drop(sweep(unclass(b)[, , drop = FALSE], 2, bc[1, ]) %*% coef)
  }
  ref <- curva(coef, diag(length(coef)), argvar, x, cen)$logrr
  list(dif = max(abs(lr_ind(range(x_cb)) - ref)),
       dif_nos = max(abs(unname(argvar$knots) - nos)),
       dif_fronteiras = max(abs(unname(argvar$Boundary.knots) - range(x_cb))),
       dif_controle_p1p99 = max(abs(lr_ind(unname(stats::quantile(serie_nos, c(0.01, 0.99), type = 7))) - ref)),
       dif_controle_serie = max(abs(lr_ind(range(serie_nos)) - ref)))
}
