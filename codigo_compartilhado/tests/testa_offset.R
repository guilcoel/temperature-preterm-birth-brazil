# testa_offset.R — testes de calcula_wj() e monta_offset() (codigo_compartilhado/R/offset.R), só com dado sintético.
# Cada teste recebe `f` (ambiente ou lista com as duas funções) e para com erro se alguma conferência falhar.
# Executor: codigo_compartilhado/tests/roda_testes.R.

.t_perto <- function(a, b, tol = 1e-12) {
  if (length(a) != length(b)) stop("tamanho diferente: ", length(a), " × ", length(b))
  if (any(is.na(a) != is.na(b))) stop("NA em posições diferentes")
  ok <- !is.na(a)
  if (any(abs(a[ok] - b[ok]) > tol)) stop("valor diferente: máx |dif| = ", format(max(abs(a[ok] - b[ok]))))
  invisible(TRUE)
}
.t_erro <- function(fun, padrao) {
  m <- tryCatch({ fun(); NA_character_ }, error = function(e) conditionMessage(e))
  if (is.na(m)) stop("esperava erro com '", padrao, "', mas não houve erro")
  if (!grepl(padrao, m, fixed = TRUE)) stop("erro diferente do esperado: ", m)
  invisible(TRUE)
}
.t_sem_menos_inf <- function(r) {
  for (k in c("log_z", "log_w", "log_zw", "w_t")) if (any(is.infinite(r[[k]]))) stop("−Inf/Inf em ", k)
  invisible(TRUE)
}
.t_d <- function(x) as.Date(x)
.t_w <- data.frame(j = 22:36, w_j = seq(0.0004, 0.0428, length.out = 15))   # w_j sintético, crescente
# Z_tj sintético e determinístico, todo > 0: n_dias dias a partir de 2020-01-01, semanas 22 a 36
.t_z <- function(n_dias = 60) {
  g <- expand.grid(dia = seq_len(n_dias), semana = 22:36)
  data.frame(data = .t_d("2019-12-31") + g$dia, semana = g$semana, z = (g$dia * 7 + g$semana * 3) %% 50 + 1)
}

testes_offset <- list(

  wj_conta_a_mao = function(f) {
    ig <- c(22, 22, 23, 24, 24, 24, 36, 37, 40)
    r <- f$calcula_wj(ig, c(22, 23, 24, 25, 36))
    .t_perto(r$j, c(22, 23, 24, 25, 36))
    .t_perto(r$n_j, c(2, 1, 3, 0, 1))
    .t_perto(r$N_j, c(9, 7, 6, 3, 3))
    .t_perto(r$w_j, c(2 / 9, 1 / 7, 3 / 6, 0, 1 / 3))
  },

  wj_denominador_na_populacao_inteira = function(f) {     # N_36 conta também as IG de 37 a 42
    r <- f$calcula_wj(c(rep(36, 4), rep(40, 6)), 36)
    .t_perto(c(r$n_j, r$N_j, r$w_j), c(4, 10, 0.4))
  },

  wj_erros = function(f) {
    .t_erro(function() f$calcula_wj(c(22, NA, 30), 22:36), "IG com NA")
    .t_erro(function() f$calcula_wj(c(22, 23), 22:24), "N_j = 0")
    .t_erro(function() f$calcula_wj(c(22.5, 30), 22:36), "IG não inteira")
  },

  offset_conta_a_mao = function(f) {
    z <- data.frame(data = .t_d(c("2020-01-01", "2020-01-01", "2020-01-01", "2020-01-02", "2020-01-02")),
                    semana = c(22, 30, 36, 22, 36), z = c(10, 5, 2, 4, 6))
    w <- data.frame(j = 22:36, w_j = c(0.001, rep(0.005, 7), 0.01, rep(0.02, 5), 0.04))   # w_22, w_30, w_36 = 0,001; 0,01; 0,04
    r <- f$monta_offset(z, w, 22:36, periodo = c("2020-01-01", "2020-01-02"))
    # dia 1: Z = 17, Σ Z·w = 0,01 + 0,05 + 0,08 = 0,14; dia 2: Z = 10, Σ Z·w = 0,004 + 0,24 = 0,244
    .t_perto(r$z_t, c(17, 10))
    .t_perto(r$w_t, c(0.14 / 17, 0.0244))
    .t_perto(r$log_z, log(c(17, 10)))
    .t_perto(r$log_w, log(c(0.14 / 17, 0.0244)))
    .t_perto(r$log_zw, log(c(0.14, 0.244)))
    stopifnot(identical(r$z_t_zero, c(FALSE, FALSE)), identical(r$data, .t_d(c("2020-01-01", "2020-01-02"))))
  },

  offset_identidade_log = function(f) {
    r <- f$monta_offset(.t_z(), .t_w, 22:36, periodo = c("2020-01-01", "2020-02-29"))
    .t_perto(r$log_zw, r$log_z + r$log_w)
    stopifnot(!anyNA(r$log_zw))
  },

  offset_w_constante = function(f) {
    w <- data.frame(j = 22:36, w_j = 0.02)
    r <- f$monta_offset(.t_z(), w, 22:36, periodo = c("2020-01-01", "2020-02-29"))
    .t_perto(r$w_t, rep(0.02, 60), tol = 1e-15)
    .t_perto(r$log_w, rep(log(0.02), 60), tol = 1e-12)
  },

  offset_uma_semana = function(f) {
    for (j in c(22L, 29L, 36L)) {
      z <- data.frame(data = .t_d("2020-01-01") + 0:9, semana = j, z = 1:10)
      r <- f$monta_offset(z, .t_w, 22:36, periodo = c("2020-01-01", "2020-01-10"))
      .t_perto(r$w_t, rep(.t_w$w_j[.t_w$j == j], 10))
      .t_perto(r$z_t, as.numeric(1:10))
    }
  },

  offset_ignora_semanas_fora = function(f) {
    z <- .t_z(10)
    extra <- data.frame(data = .t_d("2020-01-01") + 0:9, semana = 40, z = 1000)
    r1 <- f$monta_offset(z, .t_w, 22:36, periodo = c("2020-01-01", "2020-01-10"))
    r2 <- f$monta_offset(rbind(z, extra), .t_w, 22:36, periodo = c("2020-01-01", "2020-01-10"))
    for (k in c("z_t", "w_t", "log_z", "log_w", "log_zw")) .t_perto(r2[[k]], r1[[k]])
  },

  erro_semana_sem_w = function(f) {
    .t_erro(function() f$monta_offset(.t_z(5), .t_w[.t_w$j != 36, ], 22:36, periodo = NULL), "monta_offset: semana(s) sem w_j: 36")
    w_na <- .t_w; w_na$w_j[w_na$j == 30] <- NA
    .t_erro(function() f$monta_offset(.t_z(5), w_na, 22:36, periodo = NULL), "monta_offset: semana(s) sem w_j: 30")
  },

  erro_z_negativo = function(f) {
    z <- .t_z(5); z$z[3] <- -1
    .t_erro(function() f$monta_offset(z, .t_w, 22:36, periodo = NULL), "monta_offset: Z_tj negativo ou NA")
  },

  erro_z_na = function(f) {
    z <- .t_z(5); z$z[7] <- NA
    .t_erro(function() f$monta_offset(z, .t_w, 22:36, periodo = NULL), "monta_offset: Z_tj negativo ou NA")
  },

  erro_dia_zero_no_periodo = function(f) {
    z <- .t_z(3); z$z[z$data == .t_d("2020-01-02")] <- 0                          # dia com Z_t = 0 explícito
    .t_erro(function() f$monta_offset(z, .t_w, 22:36, periodo = c("2020-01-01", "2020-01-03")), "monta_offset: 1 dia(s) com Z_t = 0")
    z2 <- .t_z(3); z2 <- z2[z2$data != .t_d("2020-01-02"), ]                       # dia ausente
    .t_erro(function() f$monta_offset(z2, .t_w, 22:36, periodo = c("2020-01-01", "2020-01-03")), "monta_offset: 1 dia(s) com Z_t = 0")
  },

  erro_dia_ausente_com_periodo_null = function(f) {                              # entrada esparsa sem a grade completa
    z <- .t_z(5); z <- z[z$data != .t_d("2020-01-03"), ]
    .t_erro(function() f$monta_offset(z, .t_w, 22:36, periodo = NULL), "monta_offset: 1 dia(s) ausente(s) na grade")
  },

  fora_do_periodo_na = function(f) {
    r <- f$monta_offset(.t_z(5), .t_w, 22:36, periodo = c("2020-01-02", "2020-01-04"))
    dentro <- c(FALSE, TRUE, TRUE, TRUE, FALSE)
    for (k in c("log_z", "log_w", "log_zw")) stopifnot(identical(is.na(r[[k]]), !dentro))
    stopifnot(!anyNA(r$z_t), !anyNA(r$w_t))
    .t_sem_menos_inf(r)
  },

  periodo_null_marca_zero = function(f) {
    z <- .t_z(3); z$z[z$data == .t_d("2020-01-02")] <- 0
    r <- f$monta_offset(z, .t_w, 22:36, periodo = NULL)
    stopifnot(identical(r$z_t_zero, c(FALSE, TRUE, FALSE)))
    for (k in c("log_z", "log_w", "log_zw", "w_t")) stopifnot(identical(is.na(r[[k]]), c(FALSE, TRUE, FALSE)))
    .t_perto(r$z_t[2], 0)
    .t_sem_menos_inf(r)
  },

  chave_com_unidades = function(f) {
    za <- .t_z(3); za$CD_MUN6 <- "A"
    zb <- .t_z(3); zb$CD_MUN6 <- "B"; zb$z <- zb$z * 2
    r <- f$monta_offset(rbind(za, zb), .t_w, 22:36, periodo = c("2020-01-01", "2020-01-03"))
    stopifnot(nrow(r) == 6, identical(r$CD_MUN6, rep(c("A", "B"), each = 3)))
    .t_perto(r$z_t[r$CD_MUN6 == "B"], 2 * r$z_t[r$CD_MUN6 == "A"])
    .t_perto(r$w_t[r$CD_MUN6 == "B"], r$w_t[r$CD_MUN6 == "A"])
    zb2 <- zb[zb$data != .t_d("2020-01-02"), ]                                     # falta um dia só na unidade B
    .t_erro(function() f$monta_offset(rbind(za, zb2), .t_w, 22:36, periodo = c("2020-01-01", "2020-01-03")), "monta_offset: 1 dia(s) com Z_t = 0")
    .t_erro(function() f$monta_offset(rbind(za, zb2), .t_w, 22:36, periodo = NULL), "monta_offset: 1 dia(s) ausente(s) na grade")
  },

  periodo_sem_valor_padrao = function(f) {                                       # o argumento é obrigatório
    stopifnot("periodo" %in% names(formals(f$monta_offset)))
    if (!identical(formals(f$monta_offset)$periodo, quote(expr = ))) stop("periodo tem valor padrão")
    .t_erro(function() f$monta_offset(.t_z(3), .t_w, 22:36), "periodo")
  },

  erro_soma_zw_zero = function(f) {                                              # Σ Z·w = 0 com Z_t > 0 daria −Inf
    w0 <- .t_w; w0$w_j[w0$j == 30] <- 0
    z <- data.frame(data = .t_d("2020-01-01") + 0:2, semana = 30L, z = 5L)
    .t_erro(function() f$monta_offset(z, w0, 22:36, periodo = c("2020-01-01", "2020-01-03")), "monta_offset: Σ Z_tj·w_j = 0")
  },

  z_t_zero_so_onde_z_e_zero = function(f) {                                      # fora do período com Z_t > 0: FALSE
    r <- f$monta_offset(.t_z(5), .t_w, 22:36, periodo = c("2020-01-02", "2020-01-04"))
    stopifnot(identical(r$z_t_zero, rep(FALSE, 5)), all(is.na(r$log_zw[c(1, 5)])))
  },

  erro_entradas_invalidas = function(f) {
    .t_erro(function() f$monta_offset(.t_z(3), .t_w, 22:36, periodo = c("2020-01-03", "2020-01-01")), "monta_offset: periodo tem de ser")
    .t_erro(function() f$monta_offset(.t_z(3), .t_w, 22:36, periodo = "2020-01-01"), "monta_offset: periodo tem de ser")
    wn <- .t_w; wn$w_j[wn$j == 25] <- -0.001
    .t_erro(function() f$monta_offset(.t_z(3), wn, 22:36, periodo = NULL), "monta_offset: w_j negativo")
  },

  integracao_wj_offset = function(f) {
    ig <- rep(22:42, times = c(1, 1, 2, 2, 3, 4, 5, 7, 9, 12, 16, 22, 30, 45, 70, 140, 300, 420, 380, 150, 20))
    w <- f$calcula_wj(ig, 22:36)
    z <- .t_z(20)
    r <- f$monta_offset(z, w, 22:36, periodo = c("2020-01-01", "2020-01-20"))
    wv <- setNames(w$w_j, w$j)
    manual <- vapply(split(z, z$data), function(d) sum(d$z * wv[as.character(d$semana)]) / sum(d$z), numeric(1))
    .t_perto(r$w_t, unname(manual))
  }
)
