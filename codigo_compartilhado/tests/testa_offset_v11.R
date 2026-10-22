# testa_offset_v11.R — testes da offset v1.1 (Fase 4 do Artigo 1; prompt da Fase 4, seção 2, itens 4 e 8; D6, 1.1 e
# 1.5; D8, item 3; D12, 4.1 e 4.2; mensagem de respostas ao plano, P8 e m8; A1-97(d)). Só dado sintético e as contagens
# agregadas da Q8. Cada teste recebe `f` (ambiente com offset.R v1.1) e para com erro se uma conferência falhar. A v1.0,
# lida da tag ajusta_dlnm-v1.0 por git show, vem em .REF$o10, posto por quem chama. Executor: roda_testes_fase4.R.
#
# Calibração da regra_gama (A1-97(d), fixada antes de rodar): insumos fixos = distribuição de IG da Q8 (NV únicos da
# coorte_fixa_22, 26 concentrações, 2012–2024; RESPOSTA_QUESTIONAMENTO_20261007.md da base, seção Q8, SHA-256
# 16fe31e9af56e3e950e2bf11f795b19fedd4552c9983798b5eac4227385d011e) e os totais de eventos (PTB 22–36 = 1.405.697, §3.2,
# l. 221; termo precoce 37–38 = 1.313.679 + 2.994.157 = 4.307.836, da mesma Q8). Mapeamento: PTB, mínimo e máximo dos EP
# dos dois cenários contra 0,07 e 0,14; termo precoce, pico estreito = 0,29 e cosseno = 1,68 (§3.2, l. 233); termo
# precoce por pessoa-dia, cosseno ≈ 1,58 (D6, 1.5). Tolerância relativa de 10% em cada número. Controle: o mutante com
# DP no lugar de DP² falha a calibração (no script 60). Teste de escala, que não é controle negativo (auditoria do chat de
# 18/10, N3): com os eventos × 4, o EP cai exatamente pela metade.

if (!exists(".REF", inherits = FALSE)) .REF <- new.env()
.o_perto <- function(a, b, tol, rel = FALSE) {
  a <- as.numeric(a); b <- as.numeric(b)
  if (length(a) != length(b)) stop("tamanhos diferentes: ", length(a), " × ", length(b))
  d <- if (rel) max(abs(a - b) / pmax(abs(b), 1e-300)) else max(abs(a - b))
  if (!is.finite(d) || d > tol) stop("diferença ", format(d), " > ", format(tol))
  invisible(d)
}
.Q8 <- c(5341, 7062, 9895, 11641, 14965, 17795, 22289, 24850, 35962, 45850, 73181, 107600, 182297, 293045, 553924,
         1313679, 2994157, 4234956, 2782081, 901325, 159953)
names(.Q8) <- 22:42
.EV_PTB <- 1405697; .EV_TP <- 1313679 + 2994157
# z_tj sintético: 3 unidades × 3 semanas × dias de 2019-12-20 a 2020-01-12 (atravessa o ano), z inteiro positivo
.o_ztj <- function(semente = 20261001) {
  set.seed(semente, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
  g <- expand.grid(data = seq(as.Date("2019-12-20"), as.Date("2020-01-12"), by = "day"), semana = 34:36, rp = c("A", "B", "C"), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$z <- stats::rpois(nrow(g), 200) + 1L; g[, c("rp", "data", "semana", "z")]
}
# população com composição de IG idêntica em cada dia de início s da coorte fixa 22 (2011-07-31 a 2024-03-05):
# por entrada na semana j, w_j(ano) é exatamente c_j / Σ_{i ≥ j} c_i em todo ano
.o_pop <- function() {
  cj <- c(1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 8, 15, 30, 60, 50, 20, 5, 1); ig1 <- rep(22:42, cj)
  s <- seq(as.Date("2011-07-31"), as.Date("2024-03-05"), by = "day")
  list(ig = rep(ig1, times = length(s)), inicio = rep(s, each = length(ig1)), cj = setNames(cj, 22:42))
}

testes_offset_v11 <- list(

  # calcula_wj e monta_offset sem `ano` em w: identical() à v1.0 (com período e com periodo = NULL)
  to11_regressao_v10 = function(f) {
    if (is.null(.REF$o10)) stop("v1.0 (.REF$o10) ausente")
    set.seed(20261001, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
    ig <- sample(22:42, 5000, replace = TRUE, prob = .Q8)
    if (!identical(f$calcula_wj(ig, 22:36), .REF$o10$calcula_wj(ig, 22:36))) stop("calcula_wj v1.1 ≠ v1.0")
    z <- .o_ztj(); w <- f$calcula_wj(sample(22:42, 3000, replace = TRUE, prob = .Q8), 34:36)
    for (per in list(NULL, c("2019-12-22", "2020-01-10")))
      if (!identical(f$monta_offset(z, w, 34:36, per), .REF$o10$monta_offset(z, w, 34:36, per))) stop("monta_offset v1.1 ≠ v1.0")
  },

  # D12, 4.2: por ano de ENTRADA, w_j(ano) = c_j/Σ_{i≥j} c_i em todos os anos (razão 1); controle: pela definição por ano
  # de nascimento, o w_22 de 2012 sai inflado (razão > 1,01)
  to11_wj_ano_d12 = function(f) {
    p <- .o_pop(); w <- f$calcula_wj_ano(p$ig, p$inicio, 22:36)
    verd <- vapply(22:36, function(j) p$cj[[as.character(j)]] / sum(p$cj[as.character(j:42)]), 0)
    razao <- w$w_j / verd[match(w$j, 22:36)]
    if (!all(abs(razao - 1) < 1e-12)) stop("razão por ano de entrada fora de 1: ", format(max(abs(razao - 1))))
    stopifnot(min(w$ano) == 2012L, max(w$ano) == 2024L, all(w$N_j > 0))
    parto <- p$inicio + 7L * p$ig + 3L; anon <- as.integer(format(parto, "%Y"))
    j <- 22L; y <- 2012L; wn <- sum(p$ig == j & anon == y) / sum(p$ig >= j & anon == y)
    if (!(wn / verd[1] > 1.01)) stop("controle sem poder: definição por ano de nascimento com razão ", format(wn / verd[1]))
  },

  # D6, 1.1, e D8, item 3: 7·w^PD/w^g = 7/(7 − 3h_j), h_j = n_j/N_j
  to11_pd_fator = function(f) {
    set.seed(20261001, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
    ig <- sample(22:42, 20000, replace = TRUE, prob = .Q8)
    pd <- f$calcula_wj_pd(ig, 22:41); g <- f$calcula_wj(ig, 22:41); h <- g$n_j / g$N_j
    .o_perto(7 * pd$w_j / g$w_j, 7 / (7 - 3 * h), 1e-13, rel = TRUE)
    .o_perto(pd$PD_j, 7 * (g$N_j - g$n_j) + 4 * g$n_j, 0)
    if (!inherits(tryCatch(f$calcula_wj_pd(c(23, 24), 22:26), error = function(e) e), "error")) stop("N_j = 0 aceito")
  },

  # monta_offset com w por ano: (a) w igual em todos os anos = v1.0; (b) w diferente por ano = conta à mão com o ano de t;
  # (c) par (ano, j) sem w: o termo sai da soma e é contado; (d) restrição às semanas = conta à mão
  to11_monta_offset_ano = function(f) {
    z <- .o_ztj(); wj <- c(`34` = 0.012, `35` = 0.020, `36` = 0.043)
    wa <- data.frame(ano = rep(2019:2020, each = 3), j = rep(34:36, 2), w_j = rep(wj, 2))
    a <- f$monta_offset(z, wa, 34:36, NULL); b <- f$monta_offset(z, data.frame(j = 34:36, w_j = wj), 34:36, NULL)
    attr(a, "termos_sem_w") <- NULL; if (!identical(a, b)) stop("(a) w igual por ano ≠ w único")
    wb <- data.frame(ano = rep(2019:2020, each = 3), j = rep(34:36, 2), w_j = c(wj, wj * c(2, 0.5, 3)))
    o <- f$monta_offset(z, wb, 34:36, NULL)
    zz <- z; zz$w <- wb$w_j[match(paste(format(zz$data, "%Y"), zz$semana), paste(wb$ano, wb$j))]
    k <- paste(zz$rp, zz$data); num <- tapply(zz$z * zz$w, k, sum); den <- tapply(zz$z, k, sum)
    ko <- paste(o$rp, o$data); .o_perto(o$log_zw, log(num[ko]), 1e-13); .o_perto(o$log_w, log(num[ko] / den[ko]), 1e-13)
    stopifnot(identical(attr(o, "termos_sem_w"), 0L))
    wc <- wb[!(wb$ano == 2020 & wb$j == 36), ]; oc <- f$monta_offset(z, wc, 34:36, NULL)
    zz$w2 <- ifelse(format(zz$data, "%Y") == "2020" & zz$semana == 36, 0, zz$w); num2 <- tapply(zz$z * zz$w2, k, sum)
    .o_perto(oc$log_zw, log(num2[ko]), 1e-13); .o_perto(oc$log_z, log(den[ko]), 1e-13)
    if (attr(oc, "termos_sem_w") != sum(format(z$data, "%Y") == "2020" & z$semana == 36)) stop("(c) contagem de termos sem w")
    # semana sem w em nenhum ano: erro (auditoria da Parte A, achado 5); células com z = 0 sem w não contam (Nota 4)
    if (!inherits(tryCatch(f$monta_offset(z, wb[wb$j != 36, ], 34:36, NULL), error = function(e) e), "error")) stop("semana sem w em nenhum ano aceita")
    z0 <- z; i0 <- which(format(z0$data, "%Y") == "2020" & z0$semana == 36)[1:5]; z0$z[i0] <- 0L
    o0 <- f$monta_offset(z0, wc, 34:36, NULL)
    if (attr(o0, "termos_sem_w") != sum(format(z$data, "%Y") == "2020" & z$semana == 36) - 5L) stop("termos_sem_w contou célula com z = 0")
    od <- f$monta_offset(z, wb, 35:36, NULL); s2 <- zz$semana %in% 35:36
    nd <- tapply((zz$z * zz$w)[s2], k[s2], sum); dd <- tapply(zz$z[s2], k[s2], sum)
    .o_perto(od$log_z, log(dd[ko]), 1e-13); .o_perto(od$log_w, log(nd[ko] / dd[ko]), 1e-13)
  },

  # m8: unidade com dias de Z_t = 0 na grade completa: com periodo = NULL, marcados e com offset NA (saem do ajuste);
  # com período, erro
  to11_periodo_null_zero = function(f) {
    z <- .o_ztj(); z <- z[z$rp == "A", ]; d0 <- as.Date(c("2019-12-25", "2020-01-03")); z$z[z$data %in% d0] <- 0L
    o <- f$monta_offset(z, data.frame(j = 34:36, w_j = c(0.012, 0.020, 0.043)), 34:36, NULL)
    stopifnot(nrow(o) == 24L, identical(o$z_t_zero, o$data %in% d0), all(is.na(o$log_z[o$z_t_zero])), all(is.na(o$log_w[o$z_t_zero])),
              all(is.finite(o$log_z[!o$z_t_zero])))
    if (!inherits(tryCatch(f$monta_offset(z, data.frame(j = 34:36, w_j = c(0.012, 0.020, 0.043)), 34:36, c("2019-12-20", "2020-01-12")), error = function(e) e), "error"))
      stop("com período, dia de Z_t = 0 deveria dar erro")
  },

  # calibração da regra única de γ contra os números publicados (10%), e decisões: PTB estimado, termo precoce γ = 1
  to11_regra_gama_calibracao = function(f) {
    ptb <- f$decide_gama(.Q8, 22:36, .EV_PTB); tp <- f$decide_gama(.Q8, 37:38, .EV_TP); tpd <- f$decide_gama(.Q8, 37:38, .EV_TP, "pessoa_dia")
    .REF$calibracao <- rbind(data.frame(caso = "PTB, mínimo dos dois cenários", obtido = min(ptb$ep), publicado = 0.07),
                             data.frame(caso = "PTB, máximo dos dois cenários", obtido = max(ptb$ep), publicado = 0.14),
                             data.frame(caso = "termo precoce, pico estreito", obtido = tp$ep[["pico"]], publicado = 0.29),
                             data.frame(caso = "termo precoce, cosseno", obtido = tp$ep[["cosseno"]], publicado = 1.68),
                             data.frame(caso = "termo precoce por pessoa-dia, cosseno", obtido = tpd$ep[["cosseno"]], publicado = 1.58))
    .REF$calibracao$dif_rel <- .REF$calibracao$obtido / .REF$calibracao$publicado - 1
    if (any(abs(.REF$calibracao$dif_rel) > 0.10)) stop("calibração fora de 10%: ", paste(.REF$calibracao$caso[abs(.REF$calibracao$dif_rel) > 0.10], collapse = "; "))
    stopifnot(identical(ptb$gama, "estimado"), identical(tp$gama, "1"), identical(tpd$gama, "1"))
  },

  # teste de escala (não é controle negativo; quem mata o mutante do DP é a calibração): com os eventos × 4, o EP cai
  # exatamente pela metade (os dois cenários, os dois pesos)
  to11_regra_gama_eventos4 = function(f) {
    for (cz in c("cosseno", "pico")) for (ps in c("gestacao", "pessoa_dia")) {
      e1 <- f$regra_gama(.Q8, 37:38, .EV_TP, cz, ps)$ep; e4 <- f$regra_gama(.Q8, 37:38, 4 * .EV_TP, cz, ps)$ep
      if (!identical(e4, e1 / 2)) stop("eventos × 4 não dividiu o EP por 2 exatamente (", cz, ", ", ps, "): ", format(e4 / e1, digits = 17))
    }
  },

  # Z liso da regra de γ = contagem por força bruta da pertença da base: a gestação de início s está na semana j no dia t
  # quando ⌊(t − s)/7⌋ = j e o término (s + 7·IG + 3) é ≥ t (D6, 1.1), somando c(s)·P(IG = g) em s e g
  to11_z_liso_pertenca = function(f) {
    p <- as.numeric(.Q8) / sum(.Q8); sem <- 22:42; t <- c(1200L, 1301L, 1777L, 2100L)
    for (cz in c("cosseno", "pico")) {
      Z <- f$.z_liso(p, sem, 22:38, t, cz)
      B <- t(vapply(t, function(tt) {
        s <- (tt - 7L * 42L - 6L):tt; cs <- f$.concepcoes(s, cz)
        vapply(22:38, function(j) sum(vapply(seq_along(sem), function(gi) sum(cs * p[gi] * (floor((tt - s) / 7) == j & s + 7 * sem[gi] + 3 >= tt)), 0)), 0)
      }, numeric(17)))
      .o_perto(Z, B, 1e-12, rel = TRUE)
    }
  },

  # D12, 4.2, nas bordas do ano (auditoria da Parte A, achado 3): entrada na semana 30 em 31/12 conta em 2019; em 01/01,
  # em 2020 (as regras "ano de s" e "ano de s + 7j + 3" erram); e, com s e IG aleatórios (composição variando no tempo),
  # w_j(ano) = a contagem à mão por ano de entrada
  to11_wj_ano_bordas = function(f) {
    s1 <- as.Date("2019-12-31") - 210L; s2 <- as.Date("2020-01-01") - 210L
    w <- f$calcula_wj_ano(c(30L, 31L), c(s1, s2), 30L)
    if (!identical(w$ano, c(2019L, 2020L)) || !identical(w$w_j, c(1, 0)) || !identical(w$N_j, c(1, 1))) stop("borda do ano por entrada errada")
    set.seed(20261001, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
    n <- 30000; ig <- sample(22:42, n, replace = TRUE, prob = .Q8); s <- as.Date("2011-07-31") + sample(0:4600, n, replace = TRUE)
    ig[s > as.Date("2018-01-01")] <- pmin(42L, ig[s > as.Date("2018-01-01")] + sample(0:1, sum(s > as.Date("2018-01-01")), replace = TRUE))
    w <- f$calcula_wj_ano(ig, s, 22:36)
    for (k in seq_len(nrow(w))) { j <- w$j[k]; y <- w$ano[k]; e <- ig >= j & as.integer(format(s + 7L * j, "%Y")) == y
      if (sum(e) != w$N_j[k] || sum(e & ig == j) != w$n_j[k]) stop("contagem por ano de entrada diferente da feita à mão (ano ", y, ", semana ", j, ")") }
  },

  # regra_gama: dist_ig sem a cauda até a semana 42 dá erro (auditoria da Parte A, Nota 9)
  to11_regra_gama_guarda = function(f) {
    if (!inherits(tryCatch(f$regra_gama(.Q8[as.character(22:41)], 37:38, .EV_TP), error = function(e) e), "error")) stop("dist_ig até a semana 41 aceita")
  }
)
