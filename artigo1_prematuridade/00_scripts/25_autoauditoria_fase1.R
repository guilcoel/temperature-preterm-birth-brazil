# 25_autoauditoria_fase1.R — Fase 1, A7.1: autoauditoria. Recalcula, com código diferente e a partir dos arquivos de
# origem (base, RDS e CSV da fase), os números dos logs da Fase 1 e compara com o que foi registrado:
# - 01_saidas/fase1/conferencias_valores.csv (os números do log da A6, gravados pelo 23) e o próprio texto do log;
# - os números dos logs do 24 (testes), 20 (série principal), 21 (municipal) e 22 (espontâneo).
# Código diferente de propósito: rowsum/aggregate/table no lugar de tapply; w_j por cumsum de tabela, e não por
# calcula_wj(); offset recalculado direto do gestacoes_em_risco, sem monta_offset(); classificação do espontâneo por
# códigos combinados; Z_tj por intervalo de datas [s + 7j, s + 7j + 6].
# Grava logs/autoauditoria_fase1_<FASE1_DATA>.md. Nunca sobrescreve. Só agregados; nenhuma linha de microdado.
# Uso (de artigo1_prematuridade/):  FASE1_DATA=AAAAMMDD Rscript 00_scripts/25_autoauditoria_fase1.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE1_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
S <- file.path("01_saidas", "fase1")
arq <- file.path("logs", paste0("autoauditoria_fase1_", hoje, ".md")); stopifnot(!file.exists(arq))
logs <- c(a6 = paste0("conferencias_fase1_", hoje, ".md"), a1 = paste0("testes_compartilhado_fase1_", hoje, ".md"),
          a2 = paste0("serie_principal_fase1_", hoje, ".md"), a3 = paste0("serie_municipal_fase1_", hoje, ".md"),
          a4 = paste0("ptb_espontaneo_fase1_", hoje, ".md"))
txt <- lapply(logs, function(f) paste(readLines(file.path("logs", f), encoding = "UTF-8"), collapse = "\n"))
D <- as.Date
JP <- D(c("2012-04-14", "2024-08-06")); JE <- D(c("2012-01-04", "2024-11-15")); SEM <- 22:36
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
ler_csv <- function(f) read.csv(f, stringsAsFactors = FALSE, colClasses = c(recorte_principal = "character"), check.names = FALSE, fileEncoding = "UTF-8")
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
R <- list()                                                        # uma linha por conferência
confere <- function(item, o_que, recomputado, registrado, tol = 0) {
  ok <- length(recomputado) == length(registrado) && !anyNA(recomputado) && !anyNA(registrado) &&
        all(abs(as.numeric(recomputado) - as.numeric(registrado)) <= tol)
  # sigilo (desvio 49): em conferência de contagem (tol = 0), a diferença nunca é gravada, só "0" ou "diferente"
  dif <- if (length(recomputado) != length(registrado)) "tamanho" else if (tol == 0) { if (ok) "0" else "diferente (valor não gravado)" } else
    format(signif(max(abs(as.numeric(recomputado) - as.numeric(registrado))), 3))
  R[[length(R) + 1]] <<- data.frame(Item = item, Conferência = o_que, N = length(recomputado), `Maior dif.` = dif,
                                    Resultado = if (ok) "igual" else "DIFERENTE", check.names = FALSE, stringsAsFactors = FALSE)
}
no_texto <- function(item, o_que, log, textos) {                    # o número formatado aparece no texto do log
  ok <- vapply(textos, function(s) grepl(s, txt[[log]], fixed = TRUE), logical(1))
  R[[length(R) + 1]] <<- data.frame(Item = item, Conferência = o_que, N = length(textos), `Maior dif.` = "—",
                                    Resultado = if (all(ok)) "igual" else sprintf("AUSENTE: %d de %d trecho(s) (texto não gravado)", sum(!ok), length(ok)),
                                    check.names = FALSE, stringsAsFactors = FALSE)
}
V <- read.csv(file.path(S, "conferencias_valores.csv"), stringsAsFactors = FALSE, colClasses = c(item = "character", chave = "character"),
              fileEncoding = "UTF-8")
val <- function(item, chave) V$valor[V$item == item & V$chave == chave]
nuc <- as.data.frame(cidade_nucleo()); nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE); ordem <- nuc$CD_RECORTE
conc <- as.data.frame(concentracoes())[, c("CD_MUN6", "CD_RECORTE")]
pri <- readRDS(file.path(S, "serie_ptb_principal.rds")); mun <- readRDS(file.path(S, "serie_ptb_municipal.rds"))
esp <- readRDS(file.path(S, "serie_ptb_espontaneo.rds")); wj <- ler_csv(file.path(S, "wj_ptb_concentracao.csv"))
jp <- pri$janela_principal

# ------------------------------------------------------------------ A1 (24): re-roda a bateria
log_msg("A1")
f0 <- new.env(); sys.source(file.path("..", "codigo_compartilhado", "R", "offset.R"), envir = f0)
source(file.path("..", "codigo_compartilhado", "tests", "roda_testes.R")); source(file.path("..", "codigo_compartilhado", "tests", "testa_offset.R"))
r0 <- roda_testes(f0, testes_offset)
no_texto("A1", "bateria n/n no log do 24", "a1", sprintf("Bateria original: %d/%d", sum(r0$ok), nrow(r0)))
confere("A1", "testes que passam (re-rodados) = total de testes", sum(r0$ok), nrow(r0))

# ------------------------------------------------------------------ A2 (20): w_j, linhas, população
log_msg("A2")
nb <- as.data.frame(nascimentos(c("CD_MUN6", "unico", "ga_sem", "coorte_fixa_22")))
nb <- nb[nb$unico %in% TRUE & nb$coorte_fixa_22 %in% TRUE & nb$ga_sem %in% 22:42, ]
nb$r <- conc$CD_RECORTE[match(nb$CD_MUN6, conc$CD_MUN6)]
tb <- table(factor(nb$r, levels = ordem), factor(nb$ga_sem, levels = 22:42))   # concentração × IG
Nj <- t(apply(tb, 1, function(x) rev(cumsum(rev(x)))))             # N_j = Σ_{k ≥ j} n_k
w_rec <- tb[, as.character(SEM)] / Nj[, as.character(SEM)]
w_reg <- matrix(wj$w_j[match(paste(rep(ordem, each = 15), rep(SEM, 26)), paste(wj$recorte_principal, wj$j))], nrow = 26, byrow = TRUE)
confere("A2", "w_j por concentração × semana (cumsum de tabela × CSV do 20)", c(w_rec), c(w_reg), tol = 1e-15)   # as duas 26 × 15
no_texto("A2", "NV da população do w_j, nº de linhas e pares com n_j < 10 no log do 20", "a2",
         c(br(nrow(nb)), br(nrow(pri)), paste0("Pares concentração × semana com n_j < 10: ", sum(tb[, as.character(SEM)] < 10))))
confere("A2", "linhas da série principal = 26 × 4.721", nrow(pri), 26 * 4721)
rm(nb); invisible(gc())

# ------------------------------------------------------------------ offset recalculado sem monta_offset()
log_msg("offset")
z <- as.data.frame(gestacoes_em_risco(nivel = "recorte")); z$data <- D(z$data)
zz <- z[z$semana %in% SEM & z$data >= JE[1] & z$data <= JE[2], ]
zz$w <- wj$w_j[match(paste(zz$recorte_principal, zz$semana), paste(wj$recorte_principal, wj$j))]
g <- paste(zz$recorte_principal, as.integer(zz$data))
zt <- rowsum(as.numeric(zz$z_nv), g); szw <- rowsum(as.numeric(zz$z_nv) * zz$w, g)
k_p <- paste(pri$recorte_principal, as.integer(pri$data))[pri$janela_evento_possivel]
i <- match(k_p, rownames(zt))
confere("offset", "z_t na janela de evento possível (rowsum × RDS)", zt[i, 1], pri$z_t[pri$janela_evento_possivel])
confere("offset", "log_w (Σ Z·w / Z, recalculado × RDS)", log(szw[i, 1] / zt[i, 1]), pri$log_w[pri$janela_evento_possivel], tol = 1e-12)
confere("offset", "log_zw (recalculado × RDS)", log(szw[i, 1]), pri$log_zw[pri$janela_evento_possivel], tol = 1e-12)
confere("offset", "offset NA fora da janela de evento possível", sum(!is.na(pri$log_zw[!pri$janela_evento_possivel])), 0)

# ------------------------------------------------------------------ A6.1 a A6.3
log_msg("A6.1–3")
aq <- pri$data >= D("2012-04-07") & pri$data <= JP[2]
col_mod <- c("ptb", "ptb_extremo", "ptb_muito", "ptb_moderado_tardio", "nv_unicos", "z_t", "w_t", "log_z", "log_w", "log_zw",
             "tmean_nucleo", "tmean_rm_nv", "rh_nucleo", "pm25_local_nucleo", "pm25_local_zero_na_nucleo",
             "dia_semana", "feriado_nacional", "carnaval", "moveis", "estrato")
na_rec <- colSums(is.na(pri[aq, col_mod]))
confere("A6.1", "NA nas 20 colunas de modelo (colSums × valores do 23)", na_rec, vapply(col_mod, function(k) val("1", paste0("na_", k)), 0))
dj <- as.numeric(table(pri$recorte_principal[jp]))
confere("A6.1", "dias na janela principal: mínimo e máximo entre as 26 (table) = 4.498", c(min(dj), max(dj), length(dj)), c(4498, 4498, 26))
confere("A6.1", "NA na tmean_nucleo de 2011-12-14 a 2024-11-15", sum(is.na(pri$tmean_nucleo)), val("1", "na_tmean_je21"))
je <- pri$janela_evento_possivel
confere("A6.3", "dias da janela de evento possível com Z_t ≤ 0 ou offset NA",
        sum(pri$z_t[je] <= 0 | is.na(pri$log_z[je]) | is.na(pri$log_w[je]) | is.na(pri$log_zw[je])), val("3", "viol_je"))
zp <- z[z$data >= JP[1] & z$data <= JP[2] & z$semana %in% SEM & z$z_nv > 0, ]
nsem <- rowsum(rep(1, nrow(zp)), paste(zp$recorte_principal, as.integer(zp$data)))   # uma linha por chave × semana
confere("A6.3", "dias da janela principal sem alguma semana de 22 a 36 (rowsum)", sum(nsem[, 1] < 15) + 26 * 4498 - nrow(nsem), val("3", "dias_incompletos"))
s2 <- rowsum(pri$ptb[jp], pri$recorte_principal[jp])
confere("A6.2", "PTB na janela principal por concentração (rowsum × valores do 23)", s2[ordem, 1], vapply(ordem, function(r) val("2", paste0("ptb_jp_", r)), 0))
a52 <- ler_csv(file.path("01_saidas", "fase0_rerun", "a5_2_eventos_janelas.csv")); a52 <- a52[a52$desfecho == "ptb" & a52$janela == "principal", ]
confere("A6.2", "PTB na janela principal × A5.2 congelada", s2[ordem, 1], a52$eventos_janela[match(ordem, a52$recorte_principal)])
no_texto("A6.2", "os 26 totais e o total das 26 no texto do log da A6", "a6", c(paste("|", br(s2[ordem, 1]), "|"), br(sum(s2[, 1]))))
zt_m <- aggregate(z_t ~ recorte_principal, data = pri[jp, ], FUN = mean)
confere("A6.3", "Z_t médio por concentração (aggregate × valores do 23)", zt_m$z_t[match(ordem, zt_m$recorte_principal)],
        vapply(ordem, function(r) val("3", paste0("zt_medio_", r)), 0), tol = 1e-9)
dp_e <- aggregate(log_w ~ estrato + recorte_principal, data = pri[jp, ], FUN = sd)
dp_c <- aggregate(log_w ~ recorte_principal, data = dp_e, FUN = mean)
confere("A6.3", "DP médio intra-estrato de log_w (aggregate × valores do 23)", dp_c$log_w[match(ordem, dp_c$recorte_principal)],
        vapply(ordem, function(r) val("3", paste0("dp_logw_", r)), 0), tol = 1e-12)
no_texto("A6.3", "DP de Sorocaba e de São Paulo no texto do log", "a6",
         c(paste("Sorocaba", br(val("3", "dp_logw_3552205"), 4)), paste("São Paulo", br(val("3", "dp_logw_3550308"), 4))))
no_texto("A6.3", "Z_t médio e DP das 26 concentrações na tabela do log", "a6",
         paste0("| ", nome[ordem], " | ", br(zt_m$z_t[match(ordem, zt_m$recorte_principal)]), " | ",
                br(dp_c$log_w[match(ordem, dp_c$recorte_principal)], 4), " |"))

# ------------------------------------------------------------------ A6.4 (Z_tj por intervalo de datas)
log_msg("A6.4")
alvo <- c("3550308", "3552205", "4205407"); set.seed(20261001); datas_s <- sort(sample(seq(JP[1], JP[2], by = "day"), 5))
nz <- as.data.frame(nascimentos(c("CD_MUN6", "data", "dum_est", "pop_ptb", "coorte_fixa_22")))
nz$r <- conc$CD_RECORTE[match(nz$CD_MUN6, conc$CD_MUN6)]
nz <- nz[nz$pop_ptb %in% TRUE & nz$coorte_fixa_22 %in% TRUE & nz$r %in% alvo, ]; nz$data <- D(nz$data); nz$dum_est <- D(nz$dum_est)
dif4 <- 0; cel4 <- 0
for (r in alvo) { g4 <- nz[nz$r == r, ]; for (k in seq_along(datas_s)) for (j in 22:42) {
  t <- datas_s[k]
  rec <- sum(g4$dum_est + 7 * j <= t & t <= g4$dum_est + 7 * j + 6 & g4$data >= t)
  b <- z$z_nv[z$recorte_principal == r & z$data == t & z$semana == j]; b <- if (length(b)) b else 0
  dif4 <- dif4 + (rec != b); cel4 <- cel4 + 1
} }
rm(nz); invisible(gc())
confere("A6.4", "células comparadas e diferentes (intervalo de datas × base)", c(cel4, dif4), c(val("4", "celulas"), val("4", "diferentes")))

# ------------------------------------------------------------------ A6.5 a A6.8
log_msg("A6.5–8")
w26 <- colSums(tb)[as.character(SEM)] / rev(cumsum(rev(colSums(tb))))[as.character(SEM)]
confere("A6.5", "w_j com as 26 somadas (cumsum × valores do 23)", w26, vapply(SEM, function(j) val("5", paste0("w26_", j)), 0), tol = 1e-15)
w_f <- w_rec; w_f[tb[, as.character(SEM)] < 10] <- NA                 # filtro do desvio 40: só pares com n_j ≥ 10
confere("A6.5", "mínimo, mediana e máximo entre as concentrações, só n_j ≥ 10 (apply × valores do 23)",
        c(apply(w_f, 2, min, na.rm = TRUE), apply(w_f, 2, median, na.rm = TRUE), apply(w_f, 2, max, na.rm = TRUE)),
        c(vapply(SEM, function(j) val("5", paste0("wmin_", j)), 0), vapply(SEM, function(j) val("5", paste0("wmed_", j)), 0),
          vapply(SEM, function(j) val("5", paste0("wmax_", j)), 0)), tol = 1e-15)
confere("A6.5", "pares com n_j < 10 e concentrações com w_j crescente", c(sum(tb[, as.character(SEM)] < 10), sum(apply(w_rec, 1, function(x) all(diff(x) > 0)))),
        c(val("5", "pares_nj_lt10"), val("5", "conc_crescente")))
e6 <- aggregate(ptb ~ estrato, data = pri[jp, ], FUN = sum); m6 <- aggregate(ptb ~ estrato_mun, data = mun[mun$janela_principal, ], FUN = sum)
confere("A6.6", "estratos e estratos sem PTB (principal e municipal)", c(nrow(e6), sum(e6$ptb == 0), nrow(m6), sum(m6$ptb == 0)),
        c(val("6", "n_estratos"), val("6", "estratos_sem_ptb"), val("6", "n_estratos_mun"), val("6", "estratos_mun_sem_ptb")))
cal <- as.data.frame(calendario()); cal$data <- D(cal$data); cj <- cal[cal$data >= JP[1] & cal$data <= JP[2], ]
mv <- as.integer(cj$quarta_cinzas == 1 | cj$sexta_paixao == 1 | cj$corpus_christi == 1)
confere("A6.7", "dias por dia da semana (format(data, \"%u\")), feriados, carnaval e móveis (calendario() direto × valores do 23)",
        c(as.numeric(table(factor(as.integer(format(cj$data, "%u")), levels = 1:7))), sum(cj$feriado_nacional), sum(cj$carnaval), sum(mv)),
        c(vapply(c("seg", "ter", "qua", "qui", "sex", "sab", "dom"), function(k) val("7", paste0("dias_", k)), 0),
          val("7", "feriado_nacional"), val("7", "carnaval"), val("7", "moveis")))
ex <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_nucleo")))
ex$data <- D(ex$data); ex <- ex[ex$data >= D("2012-01-01") & ex$data <= D("2024-12-31"), ]
q8 <- aggregate(tmean_nucleo ~ recorte_principal, data = ex, FUN = function(x) c(mean(x), diff(quantile(x, c(.01, .99), type = 7))))
q8 <- q8[match(ordem, q8$recorte_principal), ]
confere("A6.8", "média e amplitude p99 − p1 da tmean_nucleo (serie_diaria direto × valores do 23)",
        c(q8$tmean_nucleo[, 1], q8$tmean_nucleo[, 2]),
        c(vapply(ordem, function(r) val("8", paste0("media_", r)), 0), vapply(ordem, function(r) val("8", paste0("amplitude_", r)), 0)), tol = 1e-12)
# A5.3 inteira (A2.6): os 9 valores × 2 períodos, recalculados direto da serie_diaria, contra a A5.3 e contra o CSV do 20
a53 <- read.csv(file.path("01_saidas", "fase0_rerun", "a5_3_percentis_diarios.csv"), stringsAsFactors = FALSE, check.names = FALSE,
                colClasses = c(recorte_principal = "character"), fileEncoding = "UTF-8")
ref <- ler_csv(file.path(S, "referencias_exposicao.csv"))
k9 <- c("n_dias", "p1", "p10", "p50", "p75", "p90", "p99", "media", "amplitude_p99_p1")
stopifnot(all(k9 %in% names(a53)), all(k9 %in% names(ref)))
calc9 <- function(x) { q <- quantile(x, c(.01, .10, .50, .75, .90, .99), type = 7, names = FALSE); c(length(x), q, mean(x), q[6] - q[1]) }
mes_ex <- as.integer(format(ex$data, "%m")); grupos <- list(`ano inteiro 2012–2024` = rep(TRUE, nrow(ex)), `novembro a março` = mes_ex %in% c(11, 12, 1, 2, 3))
rec9 <- do.call(rbind, lapply(names(grupos), function(gq) t(vapply(ordem, function(r) calc9(ex$tmean_nucleo[grupos[[gq]] & ex$recorte_principal == r]), numeric(9)))))
chv <- paste(rep(ordem, 2), rep(names(grupos), each = 26))
i_a <- match(chv, paste(a53$recorte_principal, a53$periodo)); i_r <- match(chv, paste(ref$recorte_principal, ref$periodo))
stopifnot(!anyNA(i_a), !anyNA(i_r))
confere("A6.8 / A2.6", "9 valores × 2 períodos × 26 recalculados da serie_diaria × A5.3 refeita", c(rec9), c(as.matrix(a53[i_a, k9])), tol = 1e-12)
confere("A6.8 / A2.6", "9 valores × 2 períodos × 26 recalculados da serie_diaria × referencias_exposicao.csv do 20", c(rec9), c(as.matrix(ref[i_r, k9])), tol = 1e-12)
no_texto("A6.8", "média e amplitude das 26 na tabela do log", "a6",
         paste0("| ", nome[ordem], " | ", br(q8$tmean_nucleo[, 1], 2), " | ", br(q8$tmean_nucleo[, 2], 2), " |"))

# ------------------------------------------------------------------ A6.9 (classificação por códigos combinados)
log_msg("A6.9")
ne <- as.data.frame(nascimentos(c("CD_MUN6", "data", "pop_ptb", "coorte_fixa_22", "ptb", "sttrabpart", "stcesparto_aj", "parto")))
ne <- ne[ne$pop_ptb %in% TRUE & ne$coorte_fixa_22 %in% TRUE & ne$ptb %in% TRUE, ]
cod <- paste(ifelse(is.na(ne$sttrabpart), "_", ne$sttrabpart), ifelse(is.na(ne$parto), "_", ne$parto),
             ifelse(is.na(ne$stcesparto_aj), "_", ne$stcesparto_aj), sep = "|")
classe <- ifelse(grepl("^1\\|", cod) | grepl("^.\\|2\\|1$", cod), "ini",
                 ifelse(grepl("^2\\|1\\|", cod) | grepl("^2\\|2\\|2$", cod), "esp", "ign"))
ne$ano <- as.integer(format(D(ne$data), "%Y")); ne$r <- conc$CD_RECORTE[match(ne$CD_MUN6, conc$CD_MUN6)]
e9 <- ne$ano >= 2013 & ne$ano <= 2023
ta <- table(ne$ano[e9], factor(classe[e9], levels = c("esp", "ini", "ign"))); pa <- 100 * ta / rowSums(ta)
confere("A6.9", "% espontâneo, iniciado e ignorado por ano, 2013–2023 (códigos combinados × valores do 23)", c(pa),
        c(vapply(2013:2023, function(a) val("9", paste0("pct_esp_", a)), 0), vapply(2013:2023, function(a) val("9", paste0("pct_ini_", a)), 0),
          vapply(2013:2023, function(a) val("9", paste0("pct_ign_", a)), 0)), tol = 1e-9)
tc <- table(factor(ne$r[e9], levels = ordem), factor(classe[e9], levels = c("esp", "ini", "ign"))); pc <- 100 * tc / rowSums(tc)
confere("A6.9", "% por concentração, 2013–2023 (códigos combinados × valores do 23)", c(pc),
        c(vapply(ordem, function(r) val("9", paste0("pct_esp_", r)), 0), vapply(ordem, function(r) val("9", paste0("pct_ini_", r)), 0),
          vapply(ordem, function(r) val("9", paste0("pct_ign_", r)), 0)), tol = 1e-9)
mascaradas <- sum(apply(tc, 1, function(x) { k <- sum(x < 10); if (k == 1) 2 else k }))   # regra reimplementada: 1 → +1 complementar
confere("A6.9", "células mascaradas na tabela por concentração (regra reimplementada × 23)", mascaradas, val("9", "celulas_mascaradas"))
rm(ne); invisible(gc())
nq <- as.data.frame(nascimentos(c("ano", "sttrabpart"))); nq <- nq[nq$ano >= 2013 & nq$ano <= 2023, ]
q2 <- 100 * as.numeric(table(nq$ano[is.na(nq$sttrabpart) | nq$sttrabpart == "9"])) / as.numeric(table(nq$ano))
confere("A6.9", "% de sttrabpart 9 ou vazio entre todos os NV, por ano (table × valores do 23)", q2,
        vapply(2013:2023, function(a) val("9", paste0("pct_q2a_", a)), 0), tol = 1e-9)
rm(nq); invisible(gc())
ok9 <- !is.na(esp$ptb)
confere("A6.9 / A4", "identidade espontâneo (i) + iniciado + ignorado = ptb (divergências)",
        sum(rowSums(esp[ok9, c("ptb_espontaneo_i", "ptb_iniciado", "ptb_ignorado")]) != esp$ptb[ok9]), val("9", "dif_identidade"))
no_texto("A4", "identidade no log do 22", "a4", sprintf("em %s de %s dias-concentração", br(sum(ok9)), br(sum(ok9))))

# ------------------------------------------------------------------ A6.10 e A3 (21)
log_msg("A6.10")
jm <- mun$janela_principal
mp <- aggregate(ptb ~ CD_MUN6, data = mun[jm, ], FUN = sum)
confere("A6.10", "municípios, dias-município com Z_t > 0 e municípios sem PTB (janela principal)",
        c(length(unique(mun$CD_MUN6)), sum(jm & mun$z_t > 0, na.rm = TRUE), sum(mp$ptb == 0)),
        c(val("10", "n_mun"), val("10", "dias_mun_zt_pos_jp"), val("10", "mun_sem_ptb_jp")))
no_texto("A3", "linhas da série municipal no log do 21", "a3", br(nrow(mun)))
# dias-município com Z_t = 0 (2012-01-01 a 2024-11-15), recalculados da base em duas parcelas (desvio 46):
# (a) sem nenhuma célula nas semanas 22–36 (os "sem célula" do log do 21) e (b) com célula só por z_fetal (z_nv = 0)
zm <- as.data.frame(gestacoes_em_risco(nivel = "municipio")); zm$data <- D(zm$data)
zm <- zm[zm$semana %in% SEM & zm$data <= JE[2], ]
km <- paste(zm$CD_MUN6, as.integer(zm$data)); snv <- rowsum(as.numeric(zm$z_nv), km)
n_dias_z <- as.integer(JE[2] - D("2012-01-01")) + 1L
sem_celula <- 277 * n_dias_z - nrow(snv); so_fetal <- sum(snv[, 1] == 0)
rm(zm, km, snv); invisible(gc())
num_txt <- function(padrao) as.numeric(gsub("\\.", "", regmatches(txt$a3, regexpr(padrao, txt$a3, perl = TRUE))))
reg_21 <- num_txt("[0-9.]+(?= dias-município sem célula)")
reg_2011 <- num_txt("(?<=os )[0-9.]+(?= dias-município de 2011-12-14)")
n_2011 <- 277 * as.integer(D("2012-01-01") - D("2011-12-14"))
confere("A3", "dias-município sem célula nas semanas 22 a 36, de 2012-01-01 a 2024-11-15 (base × log do 21)", sem_celula, reg_21)
confere("A3", "dias-município de 2011-12-14 a 2011-12-31 (277 × 18 × log do 21)", n_2011, reg_2011)
confere("A3", "dias-município com z_t_zero no RDS = 2011 + sem célula nas semanas 22–36 + com célula só por z_fetal", sum(mun$z_t_zero), n_2011 + sem_celula + so_fetal)
confere("A3", "offset NA exatamente nos dias de Z_t = 0 (todo o período gravado)", sum(xor(is.na(mun$log_zw), mun$z_t == 0)), 0)
no_texto("A3", "dias só com z_fetal mascarados no log do 21", "a3",
         paste(if (so_fetal == 0) "nenhum dia-município" else if (so_fetal < 10) "<10 dias-município" else paste(br(so_fetal), "dias-município"),
               "com célula nas semanas 22 a 36 só por"))
if (so_fetal > 0 && so_fetal < 10) cat("A3: dias com célula só por z_fetal: <10 (sigilo)\n")   # nunca imprimir 1–9

# ------------------------------------------------------------------ conferências acrescentadas na reauditoria (desvio 49)
log_msg("reauditoria")
rot <- c("seg", "ter", "qua", "qui", "sex", "sab", "dom")
confere("A6.7", "rótulo do dia da semana × format(data, \"%u\"), dia a dia, em todas as linhas da série principal (divergências)",
        sum(as.character(pri$dia_semana) != rot[as.integer(format(pri$data, "%u"))]), 0)
na_k <- vapply(col_mod, function(k) sum(tapply(is.na(pri[[k]][aq]), pri$recorte_principal[aq], any)), numeric(1))
no_texto("A6.1", "NA e concentrações com NA, por coluna, na tabela do log", "a6",
         paste0("| `", col_mod, "` | ", br(na_rec[col_mod]), " | ", na_k, "/26 |"))
na_pm <- tapply(is.na(pri$pm25_local_zero_na_nucleo[aq]), pri$recorte_principal[aq], sum); na_pm <- na_pm[na_pm > 0]   # ordem do código, como no 23
no_texto("A6.1", "NA de PM2.5 (zero = NA) por concentração no log", "a6", paste(sprintf("%s %s", nome[names(na_pm)], br(na_pm)), collapse = "; "))
e_c <- table(sub("_.*", "", unique(pri$estrato[jp])))
confere("A6.3", "estratos por concentração na janela principal (todas iguais)", length(unique(as.numeric(e_c))), 1)
no_texto("A6.3", "nº de estratos por concentração no texto do log", "a6", paste0("média dos DP dos ", br(as.numeric(e_c)[1]), " estratos"))
no_texto("A6.4", "as 5 datas sorteadas no texto do log", "a6", paste(format(datas_s), collapse = ", "))
cr <- vapply(split(wj, factor(wj$recorte_principal, levels = sort(unique(wj$recorte_principal)))),
             function(x) { x <- x[order(x$j), ]; all(diff(x$w_j) > 0) }, logical(1))
if (any(!cr)) no_texto("A6.5", "concentrações com w_j não crescente no texto do log", "a6", paste0("Não crescentes: ", paste(nome[names(cr)[!cr]], collapse = ", "), "."))
no_texto("A3", "linha_modelo no log do 21", "a3", sprintf("%s dias-município de %s na janela principal", br(sum(mun$linha_modelo)), br(sum(mun$janela_principal))))
src24 <- paste0(paste(readLines(file.path("..", "codigo_compartilhado", "R", "offset.R"), encoding = "UTF-8"), collapse = "\n"), "\n")
alvos <- list(c("N_j <- vapply(semanas, function(j) sum(ig >= j), numeric(1))", "N_j <- vapply(semanas, function(j) sum(ig > j), numeric(1))"),
              c("out$w_t <- ifelse(pos, s_zw / ifelse(pos, z_t, 1), NA_real_)", "out$w_t <- ifelse(pos, s_zw, NA_real_)"),
              c("dentro <- as.integer(z_tj$semana) %in% semanas", "dentro <- as.integer(z_tj$semana) %in% setdiff(semanas, 36L)"))
esp_def <- vapply(alvos, function(a) {
  tf <- tempfile(fileext = ".R"); writeLines(sub(a[1], a[2], src24, fixed = TRUE), tf); g <- new.env(); sys.source(tf, envir = g); unlink(tf)
  rr <- roda_testes(g, testes_offset); paste0("| ", sum(!rr$ok), " | ", paste(rr$teste[!rr$ok], collapse = ", "), " |")
}, "")
no_texto("A1", "testes derrubados por cada defeito (re-rodados) na tabela do log do 24", "a1", esp_def)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
no_texto("A6", "SHA-256 do conferencias_valores.csv no log da A6", "a6", sha(file.path(S, "conferencias_valores.csv")))

stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
res <- do.call(rbind, R)
n_ok <- sum(res$Resultado == "igual")
md <- c("# Fase 1, A7.1: autoauditoria", "",
        sprintf("- **Gerado por:** `00_scripts/25_autoauditoria_fase1.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        "- **Método:** cada número dos logs da Fase 1 foi recalculado a partir dos arquivos de origem (base, RDS e CSV da fase), com código diferente do que o gerou, e comparado com o valor registrado (`01_saidas/fase1/conferencias_valores.csv`, gravado pelo 23 com os mesmos números do log da A6) ou com o texto dos logs do 20, 21, 22 e 24.",
        "- **Código diferente:** `rowsum`, `aggregate`, `colSums` e `table` no lugar de `tapply`; w_j por `cumsum` de tabela concentração × IG, sem `calcula_wj()`; offset recalculado direto do `gestacoes_em_risco`, sem `monta_offset()`; classificação do espontâneo por códigos combinados e expressões regulares; Z_tj por intervalo de datas [s + 7j, s + 7j + 6] com término ≥ t; calendário contado direto no `calendario()`; média e amplitude direto da `serie_diaria`.",
        "- **Tolerâncias:** contagens, exatas; razões e logaritmos, 1e-12 a 1e-15; médias e percentuais, 1e-9.", "",
        sprintf("## Resultado: %d de %d conferências iguais", n_ok, nrow(res)), "",
        tabela_md(res), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "|", n_ok, "de", nrow(res), "iguais\n")
if (n_ok < nrow(res)) { print(res[res$Resultado != "igual", ]); quit(status = 1) }
