# offset.R — offset de gestações em risco (especificação v2.0.2, §3.1), genérico para os três artigos.
# Só R base. Nenhuma regra específica de um artigo: população, semanas e período vêm de quem chama.
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
  wj <- if (is.data.frame(w)) setNames(as.numeric(w$w_j), as.character(w$j)) else w
  if (!is.null(periodo) && (length(periodo) != 2 || anyNA(as.Date(periodo)) || as.Date(periodo[1]) > as.Date(periodo[2])))
    stop("monta_offset: periodo tem de ser NULL ou c(início, fim), com início ≤ fim")
  sem_w <- semanas[is.na(wj[as.character(semanas)])]          # nome ausente ou valor NA
  if (length(sem_w)) stop("monta_offset: semana(s) sem w_j: ", paste(sem_w, collapse = ", "))
  if (any(wj[as.character(semanas)] < 0)) stop("monta_offset: w_j negativo")
  if (anyNA(z_tj$z) || any(z_tj$z < 0)) stop("monta_offset: Z_tj negativo ou NA")

  chave <- setdiff(names(z_tj), c("semana", "z"))
  k <- do.call(paste, c(unname(as.list(z_tj[chave])), sep = "\r"))
  u <- unique(k); g <- match(k, u)
  dentro <- as.integer(z_tj$semana) %in% semanas
  zz <- ifelse(dentro, as.numeric(z_tj$z), 0)
  zw <- numeric(nrow(z_tj))
  zw[dentro] <- as.numeric(z_tj$z[dentro]) * wj[as.character(z_tj$semana[dentro])]
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
  out
}
