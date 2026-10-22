# ajusta_dlnm.R — ajuste DLNM do desenho agudo (case time series, quasi-Poisson condicional), versão 1.1.
# Especificação v2.0.2: §1.2, §1.3, §1.5, §2.1, §3.1, §5 (critério 4), §6 e §8. Desvio 54 do Artigo 1: a assinatura é
# ajusta_dlnm(dados, spec), uma unidade por chamada, só o desenho agudo (prematuridade e óbito perinatal).
# Requer dlnm e gnm (renv do artigo). Não grava arquivo, não imprime nada e não devolve resíduos nem valores ajustados.
#
# spec_agudo(desfecho, exposicao, janela, lag, argvar, arglag, offset, covariaveis, estrato, group, cen)
#   argvar, arglag: listas da crossbasis do dlnm, com os nós já em NÚMEROS (`knots`; `breaks` para fun = "strata").
#     Não aceita `nk`: quem chama resolve logknots(lag, nk = 2) antes. Com lag = 7 e arglag ns, os nós têm de ser os
#     de logknots(7, nk = 2) (0,982 e 2,622). Para o fallback (§5, critério 4): argvar ns com outros nós e arglag
#     list(fun = "strata", breaks = c(2, 5), intercept = TRUE). A arglag tem intercepto (sem ele, grava TRUE, o padrão
#     do dlnm; intercept = FALSE dá erro).
#   offset: "z_w_gama" (offset log_z e log_w como covariável, cujo coeficiente é o γ), "zw" (offset log_zw) ou "nenhum".
#   janela: nome da coluna lógica que marca os dias de ajuste. estrato: coluna dos estratos (eliminate do gnm).
#   group: NULL (uma série) ou nome da coluna de unidade (os lags não atravessam unidades). cen: valor numérico.
#
# ajusta_dlnm(dados, spec)
#   dados: uma unidade (ou várias, com spec$group), ordenada por group e data, sem dia faltando, com as colunas da spec
#   e `data`. A cross-basis é montada sobre TODAS as linhas recebidas (aquecimento incluído) e só depois as linhas de
#   ajuste são escolhidas (§1.5). Os Boundary.knots do ns saem do range de todas as linhas recebidas, salvo se a
#   argvar trouxer Boundary.knots: quem chama decide o conjunto de linhas.
#   Linhas de ajuste: janela TRUE, cross-basis, desfecho, covariáveis e estrato sem NA, e offset finito. Estratos sem
#   evento saem antes do ajuste (§2.1). Modelo: gnm(desfecho ~ cb + covariáveis [+ log_w], offset, eliminate = estrato,
#   family = quasipoisson). Cross-basis, ajuste, φ/QAIC/PACF e crossreduce ficam em tryCatch: erro, gnm sem modelo,
#   aviso de não convergência, coeficiente da cross-basis aliasado ou vcov (da cross-basis ou reduzida) não finita ou
#   não positiva-definida dão status = "falhou", sem interromper quem chama. Aliasamento fora da cross-basis (γ ou
#   calendário) só entra nos avisos (leitura da A1.4 do prompt; desvio 62). Atenção: o gnm com eliminate não marca NA
#   num termo colinear com os estratos; um log_w constante (ou constante dentro de cada estrato) sai com status "ok" e
#   EP de γ enorme (desvio 63). Variância de γ não finita ou negativa: ep_gama = NA, com aviso. A função não troca de
#   especificação (o fallback é de quem chama).
#   Devolve uma lista com: status, mensagem, avisos, convergiu; coef_cb, vcov_cb, dim_cb; base (attributes(cb)
#   [argvar, arglag, lag, range, df]) e boundary_knots; reduzida (coef, vcov, dim, cen, rr_no_cen); gama, ep_gama;
#   phi (Pearson χ² / m$df.residual, já sem estratos vazios); qaic (estilo MCC, desvio 56); pacf (por unidade, sobre a
#   grade da 1ª à última data da janela, com NA fora da janela ou do ajuste; lags 1 a 7, n de dias não NA, limite
#   2/√n e lags fora da faixa; NA se n ≤ 8; `fora` NA se algum lag sair NA); autovalor_min_cb e autovalor_min_red; n (dias, eventos e estratos usados
#   e removidos); linhas_por_unidade (n e primeira e última data de ajuste); spec; versoes.
#   Nota: no crossreduce(type = "overall"), coeficientes e vcov reduzidos não dependem do cen, que só muda fit e RRfit.
#
# Versão 1.1 (Fase 4 do Artigo 1; prompt da Fase 4, seção 2, item 1; D16, item 1; entradas A1-97 e A1-99). Aditiva: sem
# os argumentos novos, os campos da v1.0 saem idênticos aos da v1.0 (regressão no script 60). Novidades:
#   - covariaveis aceita coluna-matriz (por exemplo ns de 3 gl do controle negativo e da UR, ou os resíduos defasados da
#     D3): o subconjunto das linhas usa [usar, , drop = FALSE];
#   - spec_agudo(..., estrato = NULL, tempo_gl = g): modelo NÃO condicional (glm quasi-Poisson, com intercepto), sem
#     estratos e com ns(tempo, df = g) calculado só sobre as linhas do ajuste (data numérica dos dias da janela, sem o
#     aquecimento; nós nos quantis, padrão do ns). Todas as linhas de ajuste entram, inclusive os dias sem evento (a
#     remoção de estratos vazios da §2.1 não se aplica). Os gl são argumento, sem valor fixo (D16: round(gl × n_dias /
#     365,25)). tempo_gl só com estrato = NULL, e estrato = NULL exige tempo_gl;
#   - ajusta_dlnm(dados, spec, devolve_matriz = FALSE, devolve_residuos = FALSE): sai também eventos_removidos (eventos
#     da janela fora das linhas de ajuste); ep_gama = NA, sem aviso, quando γ sai NA (aliasado); com devolve_residuos =
#     TRUE, sai residuos_deviance (alinhados às linhas recebidas, NA fora do ajuste), para os resíduos defasados e a PACF
#     da D3. Os resíduos só saem a pedido: a saída padrão continua sem vetor do tamanho da série (regra de sigilo da v1.0,
#     teste t14 de testa_ajusta_dlnm.R); com devolve_matriz = TRUE, sai `matriz` = list(X = model.matrix das colunas não eliminadas,
#     estrato = fator dos estratos das linhas de ajuste (NULL sem estratos), peso_trabalho = pesos de trabalho finais do
#     IRLS, mu = valores ajustados, linhas = índices das linhas de ajuste), para a nula da PACF (D3; D16, item 2);
#   - no modelo não condicional, n$estratos_usados sai NA e n$estratos_removidos e n$dias_removidos_estrato_vazio saem 0.

spec_agudo <- function(desfecho, exposicao, janela, lag, argvar, arglag,
                       offset = c("z_w_gama", "zw", "nenhum"),
                       covariaveis = c("dia_semana", "feriado_nacional", "carnaval", "moveis"),
                       estrato = "estrato", group = NULL, cen, tempo_gl = NULL) {
  offset <- match.arg(offset)
  if (missing(cen) || !is.numeric(cen) || length(cen) != 1 || is.na(cen)) stop("spec_agudo: cen tem de ser um número")
  stopifnot(is.character(desfecho), length(desfecho) == 1, is.character(exposicao), length(exposicao) == 1,
            is.character(janela), length(janela) == 1, is.null(estrato) || (is.character(estrato) && length(estrato) == 1),
            is.null(group) || (is.character(group) && length(group) == 1), is.character(covariaveis) || is.null(covariaveis),
            is.numeric(lag), length(lag) == 1, lag >= 1, lag == round(lag), is.list(argvar), is.list(arglag))
  if ("nk" %in% c(names(argvar), names(arglag))) stop("spec_agudo: não passe nk; resolva os nós antes (logknots)")
  for (b in list(argvar, arglag)) {
    if (is.null(b$fun)) stop("spec_agudo: argvar e arglag precisam de fun")
    if (identical(b$fun, "ns") && (is.null(b$knots) || !is.numeric(b$knots))) stop("spec_agudo: ns exige knots numéricos")
    if (identical(b$fun, "strata") && (is.null(b$breaks) || !is.numeric(b$breaks))) stop("spec_agudo: strata exige breaks numéricos")
  }
  if (lag == 7 && identical(arglag$fun, "ns") && !isTRUE(all.equal(unname(as.numeric(arglag$knots)), dlnm::logknots(7, nk = 2), tolerance = 1e-6)))
    stop("spec_agudo: com lag = 7, os nós da arglag têm de ser logknots(7, nk = 2) = 0,982 e 2,622")
  if (is.null(arglag$intercept)) arglag$intercept <- TRUE           # o padrão do dlnm, gravado explicitamente
  if (!isTRUE(arglag$intercept)) stop("spec_agudo: a arglag tem de ter intercept = TRUE (§1.3)")
  if (is.null(estrato) && is.null(tempo_gl)) stop("spec_agudo: sem estratos (modelo não condicional), passe tempo_gl (gl do ns(tempo))")
  if (!is.null(tempo_gl) && !is.null(estrato)) stop("spec_agudo: tempo_gl só vale com estrato = NULL (modelo não condicional)")
  if (!is.null(tempo_gl) && !(is.numeric(tempo_gl) && length(tempo_gl) == 1 && tempo_gl >= 1 && tempo_gl == round(tempo_gl)))
    stop("spec_agudo: tempo_gl tem de ser um inteiro positivo")
  sp <- structure(list(desfecho = desfecho, exposicao = exposicao, janela = janela, lag = as.integer(lag), argvar = argvar,
                       arglag = arglag, offset = offset, covariaveis = covariaveis, estrato = estrato, group = group,
                       cen = as.numeric(cen)), class = "spec_agudo")
  if (!is.null(tempo_gl)) sp$tempo_gl <- as.integer(tempo_gl)      # campo só no modelo não condicional (v1.1)
  sp
}

# PACF dos resíduos de deviance, por unidade, sobre a grade completa de datas da unidade, da 1ª à última data da janela
# (NA nos dias fora da janela ou fora do ajuste; desvio 62). r: resíduos nas linhas da grade; unidade: unidade de cada
# linha. Com n ≤ lag.max + 1 dias não NA, a PACF não é calculada: valores, limite e `fora` saem NA. Se algum lag sair
# NA (por exemplo, dias alternados), `fora` sai NA (desvio 63).
.pacf_por_unidade <- function(r, unidade, lag.max = 7) {
  unidades <- unique(unidade)                                        # uma PACF por unidade, nunca no vetor empilhado
  do.call(rbind, lapply(unidades, function(u) {
    v <- r[unidade == u]; n <- sum(!is.na(v))
    calcula <- n > lag.max + 1
    p <- if (calcula) as.numeric(stats::pacf(v, lag.max = lag.max, na.action = stats::na.pass, plot = FALSE)$acf)[seq_len(lag.max)] else rep(NA_real_, lag.max)
    lim <- if (calcula) 2 / sqrt(n) else NA_real_
    data.frame(unidade = as.character(u), t(setNames(p, paste0("lag", seq_len(lag.max)))), n = n, limite = lim,
               fora = if (calcula && !anyNA(p)) paste(which(abs(p) > lim), collapse = ",") else NA_character_, stringsAsFactors = FALSE)
  }))
}

.autovalor_min <- function(v) if (is.null(v) || !all(is.finite(v))) NA_real_ else min(eigen(v, symmetric = TRUE, only.values = TRUE)$values)

ajusta_dlnm <- function(dados, spec, devolve_matriz = FALSE, devolve_residuos = FALSE) {
  stopifnot(inherits(spec, "spec_agudo"), is.data.frame(dados))
  off_cols <- switch(spec$offset, z_w_gama = c("log_z", "log_w"), zw = "log_zw", nenhum = character(0))
  precisa <- unique(c("data", spec$desfecho, spec$exposicao, spec$janela, spec$estrato, spec$covariaveis, spec$group, off_cols))
  falta <- setdiff(precisa, names(dados)); if (length(falta)) stop("ajusta_dlnm: faltam colunas: ", paste(falta, collapse = ", "))
  stopifnot(inherits(dados$data, "Date"))
  grp_todas <- if (is.null(spec$group)) rep("1", nrow(dados)) else as.character(dados[[spec$group]])
  # ordem e dias faltando: unidades contíguas, datas consecutivas dentro de cada unidade
  r <- rle(grp_todas); if (anyDuplicated(r$values)) stop("ajusta_dlnm: dados fora de ordem (unidades não contíguas)")
  for (u in r$values) { d <- dados$data[grp_todas == u]; if (any(diff(d) != 1)) stop("ajusta_dlnm: unidade ", u, " fora de ordem ou com dia faltando") }

  base_linhas <- seq_len(nrow(dados))                                # a cross-basis usa a série inteira recebida (§1.5)
  dados <- dados[base_linhas, , drop = FALSE]; grp <- grp_todas[base_linhas]
  cb <- tryCatch(dlnm::crossbasis(dados[[spec$exposicao]], lag = spec$lag, argvar = spec$argvar, arglag = spec$arglag,
                                  group = if (is.null(spec$group)) NULL else grp), error = function(e) e)
  if (inherits(cb, "error"))
    return(list(status = "falhou", mensagem = paste("erro na cross-basis:", conditionMessage(cb)), avisos = character(0),
                convergiu = NA, spec = spec, n = list(dias_janela = sum(dados[[spec$janela]] %in% TRUE), dias_usados = 0)))
  base <- attributes(cb)[c("argvar", "arglag", "lag", "range", "df")]
  bk <- base$argvar$Boundary.knots

  # linhas de ajuste e estratos vazios
  ok <- dados[[spec$janela]] %in% TRUE & stats::complete.cases(cb) &
        stats::complete.cases(dados[, unique(c(spec$desfecho, spec$covariaveis, spec$estrato)), drop = FALSE])
  for (k in off_cols) ok <- ok & is.finite(dados[[k]])               # offset finito (−Inf ou NA ficam fora)
  condicional <- !is.null(spec$estrato)                              # v1.1: estrato = NULL → glm não condicional
  est <- if (condicional) as.character(dados[[spec$estrato]]) else rep("1", nrow(dados))
  ev <- tapply(dados[[spec$desfecho]][ok], est[ok], sum)
  vazios <- if (condicional) names(ev)[ev == 0] else character(0)    # estratos sem evento saem antes do ajuste (§2.1)
  usar <- ok & !(est %in% vazios)

  out <- list(status = "falhou", mensagem = NA_character_, avisos = character(0), convergiu = NA,
              coef_cb = NULL, vcov_cb = NULL, dim_cb = NA_integer_, base = base, boundary_knots = bk,
              reduzida = NULL, gama = NA_real_, ep_gama = NA_real_, phi = NA_real_, qaic = NA_real_, pacf = NULL,
              autovalor_min_cb = NA_real_, autovalor_min_red = NA_real_,
              n = list(dias_janela = sum(dados[[spec$janela]] %in% TRUE), dias_usados = sum(usar),
                       dias_removidos_estrato_vazio = sum(ok & est %in% vazios),
                       dias_sem_base_ou_offset = sum(dados[[spec$janela]] %in% TRUE & !ok),
                       eventos = sum(dados[[spec$desfecho]][usar]),
                       estratos_usados = if (condicional) length(unique(est[usar])) else NA_integer_,
                       estratos_removidos = length(vazios)),
              linhas_por_unidade = do.call(rbind, lapply(unique(grp), function(u) {
                i <- usar & grp == u
                data.frame(unidade = u, n = sum(i), primeira = if (any(i)) min(dados$data[i]) else as.Date(NA),
                           ultima = if (any(i)) max(dados$data[i]) else as.Date(NA), stringsAsFactors = FALSE)
              })),
              spec = spec, versoes = c(R = paste(R.version$major, R.version$minor, sep = "."),
                                       dlnm = as.character(utils::packageVersion("dlnm")),
                                       gnm = as.character(utils::packageVersion("gnm"))))
  out$eventos_removidos <- sum(dados[[spec$desfecho]][dados[[spec$janela]] %in% TRUE & !usar], na.rm = TRUE)   # v1.1
  if (sum(usar) == 0) { out$mensagem <- "nenhuma linha de ajuste"; return(out) }

  md <- data.frame(y = dados[[spec$desfecho]][usar], est = factor(est[usar]))
  for (k in spec$covariaveis) md[[k]] <- if (is.matrix(dados[[k]])) dados[[k]][usar, , drop = FALSE] else dados[[k]][usar]   # v1.1: coluna-matriz
  md$cb <- unclass(cb)[usar, , drop = FALSE]
  termos <- c("cb", spec$covariaveis)
  if (!condicional) {                                                # v1.1: ns(tempo) só sobre as linhas do ajuste (D16)
    bt <- splines::ns(as.numeric(dados$data[usar]), df = spec$tempo_gl)
    md$ns_tempo <- matrix(as.numeric(bt), nrow = nrow(bt)); termos <- c(termos, "ns_tempo")
  }
  if (spec$offset == "z_w_gama") { md$log_w <- dados$log_w[usar]; termos <- c(termos, "log_w") }   # γ = coeficiente de log_w
  off <- switch(spec$offset, z_w_gama = dados$log_z[usar], zw = dados$log_zw[usar], nenhum = NULL)
  form <- stats::as.formula(paste("y ~", paste(termos, collapse = " + ")))

  avisos <- character(0)
  m <- withCallingHandlers(
    tryCatch(if (condicional) gnm::gnm(form, eliminate = est, family = stats::quasipoisson, data = md, offset = off, verbose = FALSE)
             else stats::glm(form, family = stats::quasipoisson, data = md, offset = off),
             error = function(e) e),
    warning = function(w) { avisos <<- c(avisos, conditionMessage(w)); invokeRestart("muffleWarning") })
  out$avisos <- avisos
  if (inherits(m, "error")) { out$mensagem <- paste("erro no ajuste:", conditionMessage(m)); return(out) }
  if (is.null(m)) { out$mensagem <- "o gnm não devolveu modelo"; return(out) }   # caminho do gnm com "Algorithm failed"
  if (isTRUE(devolve_residuos))                                      # v1.1: só a pedido (D3)
    out$residuos_deviance <- tryCatch({ rd0 <- rep(NA_real_, nrow(dados)); rd0[usar] <- stats::residuals(m, type = "deviance"); rd0 },
                                      error = function(e) NULL)
  if (isTRUE(devolve_matriz))                                        # v1.1: para a nula da PACF (D3; D16, item 2)
    out$matriz <- tryCatch(list(X = stats::model.matrix(m), estrato = if (condicional) md$est else NULL,
                                peso_trabalho = as.numeric(stats::weights(m, type = "working")), mu = as.numeric(stats::fitted(m)),
                                linhas = which(usar)), error = function(e) NULL)

  falhas <- character(0)
  out$convergiu <- isTRUE(m$converged)
  if (!out$convergiu || any(grepl("converg", avisos, ignore.case = TRUE))) falhas <- c(falhas, "não convergiu")
  cf <- stats::coef(m); i_cb <- grep("^cb", names(cf))
  out$coef_cb <- cf[i_cb]; out$dim_cb <- length(i_cb)
  if (anyNA(out$coef_cb)) falhas <- c(falhas, "coeficiente da cross-basis aliasado")
  fora_cb <- setdiff(names(cf)[is.na(cf)], names(cf)[i_cb])          # aliasamento fora da cross-basis: só aviso (desvio 62)
  if (length(fora_cb)) out$avisos <- c(out$avisos, paste("coeficiente aliasado fora da cross-basis:", paste(fora_cb, collapse = ", ")))
  V <- tryCatch(stats::vcov(m), error = function(e) NULL)
  if (!is.null(V) && !anyNA(out$coef_cb)) {
    out$vcov_cb <- V[names(cf)[i_cb], names(cf)[i_cb], drop = FALSE]
    out$autovalor_min_cb <- .autovalor_min(out$vcov_cb)
    if (!is.finite(out$autovalor_min_cb) || out$autovalor_min_cb <= 0) falhas <- c(falhas, "vcov da cross-basis não positiva-definida")
  } else if (is.null(V)) falhas <- c(falhas, "vcov indisponível")
  if (spec$offset == "z_w_gama" && "log_w" %in% names(cf) && !is.null(V)) {
    out$gama <- unname(cf["log_w"])
    if (is.na(out$gama)) out$ep_gama <- NA_real_ else {             # v1.1: γ NA (aliasado) → EP NA, sem aviso
      vg <- V["log_w", "log_w"]
      if (is.finite(vg) && vg >= 0) out$ep_gama <- sqrt(vg) else out$avisos <- c(out$avisos, "variância de γ não finita ou negativa: EP de γ = NA")
    }
  }
  diag_ok <- tryCatch({
    rp <- stats::residuals(m, type = "pearson")
    out$phi <- sum(rp^2) / m$df.residual                             # df.residual do gnm já desconta os estratos eliminados
    k <- sum(!is.na(cf))
    out$qaic <- -2 * sum(stats::dpois(md$y, stats::fitted(m), log = TRUE)) + 2 * out$phi * k   # estilo MCC (desvio 56)
    # PACF dos resíduos de deviance: por unidade, da 1ª à última data da janela, com NA fora da janela ou do ajuste
    jan <- dados[[spec$janela]] %in% TRUE; grade <- logical(nrow(dados))
    for (u in unique(grp)) { i <- which(grp == u & jan); if (length(i)) grade[min(i):max(i)] <- TRUE }
    rd <- rep(NA_real_, nrow(dados)); rd[usar] <- stats::residuals(m, type = "deviance")
    out$pacf <- .pacf_por_unidade(rd[grade], grp[grade])
    TRUE
  }, error = function(e) conditionMessage(e))
  if (!isTRUE(diag_ok)) falhas <- c(falhas, paste("erro em φ, QAIC ou PACF:", diag_ok))

  # curva cumulativa reduzida (overall), com o cen da spec
  if (!anyNA(out$coef_cb) && !is.null(out$vcov_cb)) {
    red <- tryCatch(dlnm::crossreduce(cb, coef = out$coef_cb, vcov = out$vcov_cb, model.link = "log", type = "overall",
                                      cen = spec$cen, at = spec$cen), error = function(e) e)
    if (inherits(red, "error")) falhas <- c(falhas, paste("erro no crossreduce:", conditionMessage(red))) else {
      out$reduzida <- list(coef = stats::coef(red), vcov = stats::vcov(red), dim = length(stats::coef(red)), cen = red$cen,
                           rr_no_cen = unname(red$RRfit[1]))
      out$autovalor_min_red <- .autovalor_min(out$reduzida$vcov)
      if (!is.finite(out$autovalor_min_red) || out$autovalor_min_red <= 0) falhas <- c(falhas, "vcov reduzida não positiva-definida")
    }
  }
  if (length(falhas)) { out$mensagem <- paste(falhas, collapse = "; "); return(out) }
  out$status <- "ok"; out$mensagem <- "ok"
  out
}
