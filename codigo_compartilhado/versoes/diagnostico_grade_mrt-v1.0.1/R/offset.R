# offset.R — offset de gestações em risco (especificação v2.0.2, §3.1), genérico para os três artigos. Versão 1.1.
# Só R base. Nenhuma regra específica de um artigo: população, semanas e período vêm de quem chama.
#
# Versão 1.1 (Fase 4 do Artigo 1; prompt da Fase 4, seção 2, itens 4 e 8; D6, 1.1 e 1.5; D12, 4.1 e 4.2; A1-97). Aditiva:
# calcula_wj e monta_offset sem `ano` em w dão o mesmo da v1.0 (regressão no script 60). Novidades:
#   - calcula_wj_ano(ig, inicio, semanas): w_j por ano de ENTRADA na semana j (D12, 4.2): N_yj = gestações que entram na
#     semana j (data inicio + 7j) no ano y, ou seja, com IG ≥ j; n_yj = as que, entre elas, terminam na semana j (IG = j);
#     w_j(y) = n_yj / N_yj, sem suavização. inicio = s = parto − (7·IG + 3), da definição da base. Só saem os pares (ano, j)
#     com N_yj > 0.
#   - calcula_wj_pd(ig, semanas): peso por pessoa-dia (D6, 1.1): PD_j = 7(N_j − T_j) + 4T_j, com T_j = n_j (término na
#     semana j; no A1, só NV), e w_j = n_j / PD_j. 7·w_j^PD / w_j^g = 7/(7 − 3h_j), h_j = T_j/N_j (D8, item 3).
#   - monta_offset aceita w com coluna `ano` (data.frame ano, j, w_j): o w_j de cada linha de z_tj é o do ano da `data`
#     (o ano de t; D12, 4.2, "o w_j aplicado é o do ano de t"). Par (ano, j) sem w (N = 0) ou com w_j NA: o termo sai de
#     Σ_j Z_tj·w_j (D12, 4.2) e Z_tj continua em Z_t; o número de células (dia, semana) com Z_tj > 0 sem w sai em
#     attr(saída, "termos_sem_w"). A restrição a um conjunto de semanas (D12, 4.1) já existia na v1.0 (`semanas`).
#   - regra_gama(dist_ig, semanas, eventos, cenario, pesos) e decide_gama(dist_ig, semanas, eventos, pesos): regra única
#     de γ da §3.2 (D6, item 4). EP aproximado = 1/√(eventos × DP²), DP = desvio-padrão intra-mês de log W_t com Z liso:
#     concepções com intensidade c(s) no dia s (cosseno: 1 + 0,10·cos(2πs/365,25); pico: 1 + 0,10·sin(2πs/365,25) +
#     0,05·sin(4πs/365,25) + 0,08·exp(−½((s mod 365,25 − 75)/6)²), fórmula da D6, item 4); E[Z_tj] = Σ_{d=0}^{6}
#     c(t − 7j − d)·[S_{j+1} + p_j·1{d ≤ 3}], com p_j = P(IG = j) e S_j = P(IG ≥ j) de dist_ig (a gestação com IG = j fica
#     4 dos 7 dias na semana j; D6, 1.1); W_t = Σ_j Z_tj·w_j / Σ_j Z_tj nas `semanas`, com w_j por gestação (p_j/S_j) ou
#     por pessoa-dia (p_j/(7(S_j − p_j) + 4p_j)). DP pela média dos quadrados dos desvios em relação à média de cada mês
#     civil, nos dias 365·ano_ini a 365·(ano_ini + anos) (dia 0 = 2000-01-01). decide_gama: γ = 1 se o EP for ≥ 1 em
#     algum dos dois cenários; senão, γ estimado.
#
# calcula_wj(ig, semanas)
#   Risco condicional de término na semana j, dado que a gestação chegou a j, contado em toda a população recebida:
#   w_j = n_j / N_j, com n_j = nº com ig == j e N_j = nº com ig >= j.
#   ig: IG em semanas completas, uma por gestação. Devolve data.frame(j, n_j, N_j, w_j), uma linha por j de `semanas`.
#   Para com erro se houver NA ou valor não inteiro em `ig`, ou se algum N_j for 0.
#
# monta_offset(z_tj, w, semanas, periodo)
#   z_tj: formato longo, com `data` (Date), `semana` e `z` (gestações em risco); as demais colunas são chave junto com
#         `data` (por exemplo, recorte_principal ou CD_MUN6). Pode ser esparso, só com células > 0, como o
#         gestacoes_em_risco da base. Linhas de semanas fora de `semanas` são ignoradas na soma.
#   w:    data.frame com `j` e `w_j` (a saída de calcula_wj) ou vetor nomeado pelas semanas.
#   periodo: obrigatório, NULL ou c(início, fim).
#     - c(início, fim): dentro do período, todo dia de cada unidade tem de estar em z_tj com Z_t > 0 (dia ausente =
#       Z_t = 0 → erro). Fora dele, o offset é NA.
#     - NULL: os dias de Z_t = 0 são marcados, sem erro, mas a grade de cada unidade tem de ser completa, do primeiro ao
#       último dia presente: quem chama inclui os dias sem célula com z = 0. Dia faltando no meio da grade → erro. A
#       função não sabe o intervalo esperado de cada unidade: garantir que a grade começa e termina nos dias certos é
#       de quem chama (por exemplo, conferindo o nº de linhas).
#   Devolve uma linha por chave, na ordem da primeira aparição em z_tj:
#     z_t = Σ_j Z_tj;  w_t = Σ_j Z_tj·w_j / Z_t;  log_z;  log_w;  log_zw = log(Σ_j Z_tj·w_j) (offset com γ = 1);
#     z_t_zero = (Z_t == 0).
#   Offset (log_*) NA fora do período e quando Z_t = 0; w_t NA quando Z_t = 0. Nunca −Inf.
#   Para com erro se: `periodo` não for NULL nem c(início, fim) com início ≤ fim; alguma semana de `semanas` não tiver
#   w_j; algum w_j for negativo; algum Z_tj for negativo ou NA; algum dia do período tiver Z_t = 0 ou faltar; com
#   periodo = NULL, faltar dia no meio da grade de alguma unidade; ou algum dia com offset tiver Σ_j Z_tj·w_j = 0 com
#   Z_t > 0 (daria −Inf).

calcula_wj <- function(ig, semanas) {
  if (anyNA(ig)) stop("calcula_wj: IG com NA")
  if (any(ig != round(ig))) stop("calcula_wj: IG não inteira")
  ig <- as.integer(ig); semanas <- as.integer(semanas)
  n_j <- vapply(semanas, function(j) sum(ig == j), numeric(1))
  N_j <- vapply(semanas, function(j) sum(ig >= j), numeric(1))
  if (any(N_j == 0)) stop("calcula_wj: N_j = 0 na(s) semana(s) ", paste(semanas[N_j == 0], collapse = ", "))
  data.frame(j = semanas, n_j = n_j, N_j = N_j, w_j = n_j / N_j)
}

monta_offset <- function(z_tj, w, semanas, periodo) {
  stopifnot(is.data.frame(z_tj), all(c("data", "semana", "z") %in% names(z_tj)), inherits(z_tj$data, "Date"))
  semanas <- as.integer(semanas)
  por_ano <- is.data.frame(w) && "ano" %in% names(w)                 # v1.1: w_j por ano (D12, 4.2)
  if (!por_ano) wj <- if (is.data.frame(w)) setNames(as.numeric(w$w_j), as.character(w$j)) else w
  if (!is.null(periodo) && (length(periodo) != 2 || anyNA(as.Date(periodo)) || as.Date(periodo[1]) > as.Date(periodo[2])))
    stop("monta_offset: periodo tem de ser NULL ou c(início, fim), com início ≤ fim")
  if (por_ano) {
    if (any(w$w_j < 0, na.rm = TRUE)) stop("monta_offset: w_j negativo")
    chave_w <- paste(as.integer(w$ano), as.integer(w$j)); if (anyDuplicated(chave_w)) stop("monta_offset: par (ano, j) repetido em w")
    wv <- setNames(as.numeric(w$w_j), chave_w)
  } else {
    sem_w <- semanas[is.na(wj[as.character(semanas)])]          # nome ausente ou valor NA
    if (length(sem_w)) stop("monta_offset: semana(s) sem w_j: ", paste(sem_w, collapse = ", "))
    if (any(wj[as.character(semanas)] < 0)) stop("monta_offset: w_j negativo")
  }
  if (anyNA(z_tj$z) || any(z_tj$z < 0)) stop("monta_offset: Z_tj negativo ou NA")

  chave <- setdiff(names(z_tj), c("semana", "z"))
  k <- do.call(paste, c(unname(as.list(z_tj[chave])), sep = "\r"))
  u <- unique(k); g <- match(k, u)
  dentro <- as.integer(z_tj$semana) %in% semanas
  zz <- ifelse(dentro, as.numeric(z_tj$z), 0)
  zw <- numeric(nrow(z_tj))
  if (por_ano) {                                                     # o w_j do ano de t; sem w: o termo sai da soma (D12, 4.2)
    wk <- unname(wv[paste(as.integer(format(z_tj$data[dentro], "%Y")), as.integer(z_tj$semana[dentro]))])
    n_sem_w <- sum(is.na(wk) & z_tj$z[dentro] > 0); wk[is.na(wk)] <- 0
    zw[dentro] <- as.numeric(z_tj$z[dentro]) * wk
  } else zw[dentro] <- as.numeric(z_tj$z[dentro]) * wj[as.character(z_tj$semana[dentro])]
  z_t <- as.vector(rowsum(zz, g)); s_zw <- as.vector(rowsum(zw, g))

  out <- z_tj[!duplicated(k), chave, drop = FALSE]; rownames(out) <- NULL
  pos <- z_t > 0
  em <- if (is.null(periodo)) rep(TRUE, nrow(out)) else out$data >= as.Date(periodo[1]) & out$data <= as.Date(periodo[2])

  unidade <- if (length(chave) > 1) do.call(paste, c(unname(as.list(out[setdiff(chave, "data")])), sep = "\r")) else rep("", nrow(out))
  if (!is.null(periodo)) {
    dias <- seq(as.Date(periodo[1]), as.Date(periodo[2]), by = "day")
    falhas <- 0
    for (un in unique(unidade)) {
      i <- unidade == un & em
      falhas <- falhas + sum(!(dias %in% out$data[i & pos]))
    }
    if (falhas > 0) stop("monta_offset: ", falhas, " dia(s) com Z_t = 0 ou ausente(s) dentro do período")
  } else {
    buracos <- 0                                                  # grade completa, do primeiro ao último dia da unidade
    for (un in unique(unidade)) {
      d <- out$data[unidade == un]
      buracos <- buracos + (as.integer(max(d) - min(d)) + 1L - length(unique(d)))
    }
    if (buracos > 0) stop("monta_offset: ", buracos, " dia(s) ausente(s) na grade (com periodo = NULL, inclua os dias sem célula com z = 0)")
  }

  ok <- em & pos
  if (any(ok & s_zw <= 0)) stop("monta_offset: Σ Z_tj·w_j = 0 com Z_t > 0 em ", sum(ok & s_zw <= 0), " dia(s) (offset daria −Inf)")
  out$z_t <- z_t
  out$w_t <- ifelse(pos, s_zw / ifelse(pos, z_t, 1), NA_real_)
  out$log_z <- ifelse(ok, log(ifelse(ok, z_t, 1)), NA_real_)
  out$log_w <- ifelse(ok, log(ifelse(ok, out$w_t, 1)), NA_real_)
  out$log_zw <- ifelse(ok, log(ifelse(ok, s_zw, 1)), NA_real_)
  out$z_t_zero <- !pos
  if (por_ano) attr(out, "termos_sem_w") <- n_sem_w
  out
}

# ------------------------------------------------------------------ v1.1: w_j por ano de entrada, pessoa-dia e regra de γ
calcula_wj_ano <- function(ig, inicio, semanas) {
  if (anyNA(ig)) stop("calcula_wj_ano: IG com NA")
  if (any(ig != round(ig))) stop("calcula_wj_ano: IG não inteira")
  if (!inherits(inicio, "Date") || length(inicio) != length(ig) || anyNA(inicio)) stop("calcula_wj_ano: inicio tem de ser Date, sem NA, um por gestação")
  ig <- as.integer(ig); semanas <- as.integer(semanas)
  out <- do.call(rbind, lapply(semanas, function(j) {
    entra <- ig >= j
    if (!any(entra)) return(NULL)
    ano <- as.integer(format(inicio[entra] + 7L * j, "%Y"))          # ano da entrada na semana j (data s + 7j)
    N <- tabulate(match(ano, sort(unique(ano)))); anos <- sort(unique(ano))
    n <- vapply(anos, function(y) sum(ig[entra][ano == y] == j), numeric(1))
    data.frame(ano = anos, j = j, n_j = n, N_j = as.numeric(N), w_j = n / N)
  }))
  out <- out[order(out$ano, out$j), , drop = FALSE]; rownames(out) <- NULL
  out
}

calcula_wj_pd <- function(ig, semanas) {
  if (anyNA(ig)) stop("calcula_wj_pd: IG com NA")
  if (any(ig != round(ig))) stop("calcula_wj_pd: IG não inteira")
  ig <- as.integer(ig); semanas <- as.integer(semanas)
  n_j <- vapply(semanas, function(j) sum(ig == j), numeric(1))
  N_j <- vapply(semanas, function(j) sum(ig >= j), numeric(1))
  if (any(N_j == 0)) stop("calcula_wj_pd: N_j = 0 na(s) semana(s) ", paste(semanas[N_j == 0], collapse = ", "))
  PD_j <- 7 * (N_j - n_j) + 4 * n_j                                   # T_j = n_j: 4 dos 7 dias na semana do término
  data.frame(j = semanas, n_j = n_j, N_j = N_j, PD_j = PD_j, w_j = n_j / PD_j)
}

.concepcoes <- function(s, cenario) {
  if (cenario == "cosseno") 1 + 0.10 * cos(2 * pi * s / 365.25) else
    1 + 0.10 * sin(2 * pi * s / 365.25) + 0.05 * sin(4 * pi * s / 365.25) + 0.08 * exp(-0.5 * (((s %% 365.25) - 75) / 6)^2)
}

# E[Z_tj] com Z liso (dias t × semanas): Σ_{d=0}^{6} c(t − 7j − d)·[S_{j+1} + p_j·1{d ≤ 3}] (D6, 1.1)
.z_liso <- function(p, sem_dist, semanas, t, cenario) {
  S <- rev(cumsum(rev(p))); ii <- match(semanas, sem_dist); pj <- p[ii]; Sj1 <- c(S[-1], 0)[ii]
  Z <- vapply(seq_along(semanas), function(k)
    rowSums(matrix(vapply(0:6, function(d) .concepcoes(t - 7 * semanas[k] - d, cenario) * (Sj1[k] + pj[k] * (d <= 3)), numeric(length(t))), nrow = length(t))),
    numeric(length(t)))
  matrix(Z, nrow = length(t))
}

regra_gama <- function(dist_ig, semanas, eventos, cenario = c("cosseno", "pico"), pesos = c("gestacao", "pessoa_dia"),
                       ano_ini = 3L, anos = 10L) {
  cenario <- match.arg(cenario); pesos <- match.arg(pesos)
  sem_dist <- as.integer(names(dist_ig))
  if (anyNA(sem_dist) || any(diff(sem_dist) != 1)) stop("regra_gama: dist_ig tem de ter nomes = semanas inteiras consecutivas")
  if (!all(semanas %in% sem_dist)) stop("regra_gama: semanas fora de dist_ig")
  if (!(is.numeric(eventos) && length(eventos) == 1 && eventos > 0)) stop("regra_gama: eventos tem de ser um número positivo")
  p <- as.numeric(dist_ig) / sum(dist_ig); S <- rev(cumsum(rev(p)))  # S[i] = P(IG ≥ semana i)
  ii <- match(semanas, sem_dist); pj <- p[ii]; Sj <- S[ii]; Sj1 <- c(S[-1], 0)[ii]
  w <- if (pesos == "gestacao") pj / Sj else pj / (7 * (Sj - pj) + 4 * pj)
  t <- seq(365 * ano_ini, 365 * (ano_ini + anos))
  Z <- .z_liso(p, sem_dist, semanas, t, cenario)
  lw <- log(drop(Z %*% w) / rowSums(Z))
  mes <- format(as.Date("2000-01-01") + t, "%Y-%m")
  dp <- sqrt(mean((lw - stats::ave(lw, mes))^2))
  list(cenario = cenario, pesos = pesos, dp = dp, ep = 1 / sqrt(eventos * dp^2))
}

decide_gama <- function(dist_ig, semanas, eventos, pesos = c("gestacao", "pessoa_dia")) {
  pesos <- match.arg(pesos)
  ep <- vapply(c("cosseno", "pico"), function(cz) regra_gama(dist_ig, semanas, eventos, cz, pesos)$ep, numeric(1))
  list(ep = ep, gama = if (any(ep >= 1)) "1" else "estimado")
}
