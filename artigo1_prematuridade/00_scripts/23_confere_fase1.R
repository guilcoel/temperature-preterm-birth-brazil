# 23_confere_fase1.R — Fase 1, A6: conferências agregadas dos conjuntos da A2, A3 e A4. Nenhum modelo; nada cruza
# desfecho com exposição, mês ou estação (os estratos entram só como contagem de estratos sem evento).
# Itens 1 a 10 da A6 do prompt da Fase 1, com os desvios 40 (w_j: mínimo, mediana e máximo só com n_j ≥ 10) e 45
# (população da comparação com a Q2a; "<10" com supressão complementar na tabela por concentração).
# Grava logs/conferencias_fase1_<FASE1_DATA>.md e, fora do git, 01_saidas/fase1/conferencias_valores.csv (os números do
# log em formato de máquina, para a autoauditoria do 25). Nunca sobrescreve. Para se uma conferência obrigatória falhar,
# depois de gravar o log (o log registra a falha).
# Sigilo: só agregados por concentração × janela, concentração × ano ou mais grossos; nenhum valor de um único dia;
# na recomputação do Z_tj, só "igual"/"diferente" e o nº de células.
# Uso (de artigo1_prematuridade/):  FASE1_DATA=AAAAMMDD Rscript 00_scripts/23_confere_fase1.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE1_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
saida <- file.path("01_saidas", "fase1"); stopifnot(dir.exists(saida))
f_pri <- file.path(saida, "serie_ptb_principal.rds"); f_mun <- file.path(saida, "serie_ptb_municipal.rds")
f_esp <- file.path(saida, "serie_ptb_espontaneo.rds"); f_wj <- file.path(saida, "wj_ptb_concentracao.csv")
f_ref <- file.path(saida, "referencias_exposicao.csv")
f_a52 <- file.path("01_saidas", "fase0_rerun", "a5_2_eventos_janelas.csv"); f_a53 <- file.path("01_saidas", "fase0_rerun", "a5_3_percentis_diarios.csv")
for (p in c(f_pri, f_mun, f_esp, f_wj, f_ref, f_a52, f_a53)) stopifnot(file.exists(p))
arq <- file.path("logs", paste0("conferencias_fase1_", hoje, ".md")); val_out <- file.path(saida, "conferencias_valores.csv")
for (p in c(arq, val_out)) stopifnot(!file.exists(p))
D <- as.Date
JP <- D(c("2012-04-14", "2024-08-06")); JE <- D(c("2012-01-04", "2024-11-15")); AQ7 <- D("2012-04-07"); GRAV1 <- D("2011-12-14")
SEM <- 22:36
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
ler_csv <- function(f) read.csv(f, stringsAsFactors = FALSE, colClasses = c(recorte_principal = "character"), check.names = FALSE, fileEncoding = "UTF-8")
VAL <- list(); reg <- function(item, chave, valor) VAL[[length(VAL) + 1]] <<- data.frame(item = item, chave = chave, valor = as.numeric(valor), stringsAsFactors = FALSE)
falhas <- character(0); exige <- function(cond, msg) if (!isTRUE(cond)) falhas <<- c(falhas, msg)
nuc <- as.data.frame(cidade_nucleo()); nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE); ordem <- nuc$CD_RECORTE
conc <- as.data.frame(concentracoes())[, c("CD_MUN6", "CD_RECORTE")]
pri <- readRDS(f_pri); mun <- readRDS(f_mun); esp <- readRDS(f_esp)
jp <- pri$janela_principal
md <- c("# Fase 1, A6: conferências agregadas", "",
        sprintf("- **Gerado por:** `00_scripts/23_confere_fase1.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        "- **Entradas:** `01_saidas/fase1/serie_ptb_principal.rds` (A2), `serie_ptb_municipal.rds` (A3), `serie_ptb_espontaneo.rds` (A4), `wj_ptb_concentracao.csv` e `referencias_exposicao.csv`; A5.2 e A5.3 da Fase 0 refeita; `gestacoes_em_risco(nivel = \"recorte\")`, `nascimentos()` e `calendario()` da base.",
        "- **Sigilo:** só agregados por concentração × janela, concentração × ano ou mais grossos, com \"<10\" e supressão complementar; nenhum valor de um único dia.", "")

# ------------------------------------------------------------------ 1. cobertura
log_msg("1. cobertura")
dias_jp <- tapply(jp, pri$recorte_principal, sum)
col_mod <- c("ptb", "ptb_extremo", "ptb_muito", "ptb_moderado_tardio", "nv_unicos", "z_t", "w_t", "log_z", "log_w", "log_zw",
             "tmean_nucleo", "tmean_rm_nv", "rh_nucleo", "pm25_local_nucleo", "pm25_local_zero_na_nucleo",
             "dia_semana", "feriado_nacional", "carnaval", "moveis", "estrato")
aq <- pri$data >= AQ7 & pri$data <= JP[2]
na_col <- vapply(col_mod, function(k) sum(is.na(pri[[k]][aq])), numeric(1))
na_conc <- vapply(col_mod, function(k) sum(tapply(is.na(pri[[k]][aq]), pri$recorte_principal[aq], any)), numeric(1))   # concentrações com algum NA
na_pm_conc <- tapply(is.na(pri$pm25_local_zero_na_nucleo[aq]), pri$recorte_principal[aq], sum)
na_tmean_je21 <- sum(is.na(pri$tmean_nucleo[pri$data >= GRAV1 & pri$data <= JE[2]]))
exige(all(dias_jp == 4498), "1: alguma concentração sem 4.498 dias na janela principal")
exige(all(na_col[setdiff(col_mod, "pm25_local_zero_na_nucleo")] == 0), "1: NA em coluna de modelo")
exige(na_tmean_je21 == 0, "1: NA na tmean_nucleo de 2011-12-14 a 2024-11-15")
for (k in col_mod) reg("1", paste0("na_", k), na_col[[k]]); reg("1", "dias_jp_min", min(dias_jp)); reg("1", "dias_jp_max", max(dias_jp))
reg("1", "na_tmean_je21", na_tmean_je21)
pm_pos <- na_pm_conc[na_pm_conc > 0]
md <- c(md, "## 1. Cobertura", "",
        sprintf("- **Dias na janela principal:** %d de 26 concentrações com 4.498 dias (mínimo %s, máximo %s).", sum(dias_jp == 4498), br(min(dias_jp)), br(max(dias_jp))),
        "- **NA nas colunas de modelo, na janela principal mais os 7 dias de aquecimento** (2012-04-07 a 2024-08-06), por concentração: a tabela dá o total nas 26 e quantas concentrações têm algum NA na coluna. Esperado: 0 em tudo, menos `pm25_local_zero_na_nucleo`.", "",
        tabela_md(data.frame(Coluna = paste0("`", col_mod, "`"), NA_ = br(na_col), Conc = paste0(na_conc, "/26"),
                             Esperado = ifelse(col_mod == "pm25_local_zero_na_nucleo", "NA permitido (variante secundária, caso completo)", "0"),
                             check.names = FALSE) |> setNames(c("Coluna", "NA (26 somadas)", "Concentrações com NA", "Esperado"))), "",
        sprintf("- **`pm25_local_zero_na_nucleo`** (só exposição): NA em %d concentrações; por concentração: %s.", length(pm_pos),
                paste(sprintf("%s %s", nome[names(pm_pos)], br(pm_pos)), collapse = "; ")),
        sprintf("- **Janela de evento possível mais 21 dias de aquecimento** (2011-12-14 a 2024-11-15): NA na `tmean_nucleo` = %s (esperado 0).", br(na_tmean_je21)), "")

# ------------------------------------------------------------------ 2. totais
log_msg("2. totais")
a52 <- ler_csv(f_a52); a52 <- a52[a52$desfecho == "ptb" & a52$janela == "principal", ]
soma_jp <- tapply(pri$ptb[jp], pri$recorte_principal[jp], sum)
t2 <- data.frame(r = ordem, serie = as.numeric(soma_jp[ordem]), a52 = as.numeric(a52$eventos_janela[match(ordem, a52$recorte_principal)]))
exige(all(t2$serie == t2$a52), "2: total de PTB na janela principal difere da A5.2")
exige(sum(t2$serie) == 1378030, "2: total das 26 diferente de 1.378.030")
for (i in seq_len(nrow(t2))) reg("2", paste0("ptb_jp_", t2$r[i]), t2$serie[i]); reg("2", "ptb_jp_total", sum(t2$serie))
md <- c(md, "## 2. Totais de PTB na janela principal contra a A5.2 congelada", "",
        sprintf("- **Resultado:** %d de 26 iguais; total das 26 = %s (A5.2: %s). Tem de bater exatamente: %s.",
                sum(t2$serie == t2$a52), br(sum(t2$serie)), br(sum(t2$a52)), if (all(t2$serie == t2$a52) && sum(t2$serie) == 1378030) "bate" else "NÃO BATE"), "",
        tabela_md(data.frame(Concentração = nome[t2$r], `Soma na série (A2)` = br(t2$serie), `"Na janela" (A5.2)` = br(t2$a52),
                             Igual = ifelse(t2$serie == t2$a52, "sim", "NÃO"), check.names = FALSE)), "")

# ------------------------------------------------------------------ 3. offset
log_msg("3. offset")
je <- pri$janela_evento_possivel
viol_je <- sum(!(pri$z_t[je] > 0) | is.na(pri$log_zw[je]) | is.na(pri$log_z[je]) | is.na(pri$log_w[je]))
z <- as.data.frame(gestacoes_em_risco(nivel = "recorte")); z$data <- D(z$data)
zj <- z[z$data >= JP[1] & z$data <= JP[2] & z$semana %in% SEM & z$z_nv > 0, c("recorte_principal", "data", "semana")]
n_sem <- tapply(zj$semana, paste(zj$recorte_principal, as.integer(zj$data)), function(x) length(unique(x)))
dias_incompletos <- sum(n_sem < 15) + (26 * 4498 - length(n_sem))
zt_med <- tapply(pri$z_t[jp], pri$recorte_principal[jp], mean)
sd_estr <- tapply(pri$log_w[jp], pri$estrato[jp], sd)
r_estr <- sub("_.*", "", names(sd_estr))
dp_med <- tapply(sd_estr, r_estr, mean)
exige(viol_je == 0, "3: dia da janela de evento possível com Z_t ≤ 0 ou offset NA")
exige(dias_incompletos == 0, "3: dia da janela principal sem alguma semana de 22 a 36")
for (r in ordem) { reg("3", paste0("zt_medio_", r), zt_med[[r]]); reg("3", paste0("dp_logw_", r), dp_med[[r]]) }
reg("3", "viol_je", viol_je); reg("3", "dias_incompletos", dias_incompletos); reg("3", "n_estratos_dp", length(sd_estr))
cod_sp <- "3550308"; cod_so <- "3552205"
md <- c(md, "## 3. Offset", "",
        sprintf("- **Janela de evento possível** (2012-01-04 a 2024-11-15): dias-concentração com Z_t ≤ 0 ou offset NA = %s (esperado 0).", br(viol_je)),
        sprintf("- **Janela principal:** dias-concentração em que falta alguma semana de 22 a 36 no `gestacoes_em_risco` = %s (esperado 0; conferido nos 26 × 4.498 dias).", br(dias_incompletos)),
        sprintf("- **DP de `log_w` dentro dos estratos concentração × ano × mês da janela principal** (média dos DP dos %s estratos de cada concentração). Previsão da especificação (§3.1): cerca de 0,022 numa concentração do tamanho de Sorocaba e 0,007 numa do tamanho de São Paulo. Observado: **Sorocaba %s; São Paulo %s**; faixa nas 26 de %s (%s) a %s (%s). Checagem de plausibilidade, não critério de parada.",
                br(length(sd_estr) / 26, 0), br(dp_med[[cod_so]], 4), br(dp_med[[cod_sp]], 4),
                br(min(dp_med), 4), nome[names(which.min(dp_med))], br(max(dp_med), 4), nome[names(which.max(dp_med))]),
        "- Nenhum valor de um único dia (mínimo, máximo) é reportado (especificação §8).", "",
        tabela_md(data.frame(Concentração = nome[ordem], `Z_t médio na janela principal` = br(zt_med[ordem]),
                             `DP médio de log_w intra-estrato` = br(dp_med[ordem], 4), check.names = FALSE)), "")

# ------------------------------------------------------------------ 4. recomputação independente do Z_tj
log_msg("4. recomputação do Z_tj")
alvo <- c("3550308", "3552205", "4205407")                        # São Paulo, Sorocaba, Florianópolis
set.seed(20261001)
datas_s <- sort(sample(seq(JP[1], JP[2], by = "day"), 5))
nb <- as.data.frame(nascimentos(c("CD_MUN6", "data", "dum_est", "pop_ptb", "coorte_fixa_22")))
nb$recorte_principal <- conc$CD_RECORTE[match(nb$CD_MUN6, conc$CD_MUN6)]
nb <- nb[nb$pop_ptb %in% TRUE & nb$coorte_fixa_22 %in% TRUE & nb$recorte_principal %in% alvo, ]
nb$data <- D(nb$data); nb$dum_est <- D(nb$dum_est)
celulas <- 0; dif_z <- 0
for (r in alvo) for (t in as.list(datas_s)) {
  g <- nb[nb$recorte_principal == r, ]
  d <- as.integer(t - g$dum_est); j <- d %/% 7
  em <- g$data >= t & d >= 0                                       # ⌊(t − s)/7⌋ = j e término ≥ t
  rec <- tabulate(j[em & j >= 22 & j <= 42] - 21L, nbins = 21)
  bz <- z[z$recorte_principal == r & z$data == t, ]
  base <- numeric(21); base[bz$semana[bz$semana >= 22 & bz$semana <= 42] - 21L] <- bz$z_nv[bz$semana >= 22 & bz$semana <= 42]
  celulas <- celulas + 21; dif_z <- dif_z + sum(rec != base)
}
rm(nb); invisible(gc())
exige(dif_z == 0, "4: Z_tj recomputado difere do z_nv da base")
reg("4", "celulas", celulas); reg("4", "diferentes", dif_z)
md <- c(md, "## 4. Recomputação independente do Z_tj", "",
        "- **População da base no `z_nv`:** `pop_ptb & coorte_fixa_22` (código da base `00_scripts/06d_gestacoes_em_risco.py`, linha 50, lido sem rodar; `DICIONARIO.md`: \"gestações em curso que terminaram em NV único com IG 22–42\", só da coorte fixa). `pop_ptb` = único com IG 22–42. É a mesma população do w_j (`unico`, `ga_sem` 22–42, `coorte_fixa_22`; o 20 conferiu linha a linha). Não houve motivo para parar.",
        sprintf("- **Recomputação:** a partir de `nascimentos()`, pela regra da base (a gestação de início s = `dum_est` está na semana j no dia t quando ⌊(t − s)/7⌋ = j e o término é ≥ t), semanas 22 a 42, para São Paulo, Sorocaba e Florianópolis em 5 datas da janela principal sorteadas com `set.seed(20261001)`: %s.",
                paste(format(datas_s), collapse = ", ")),
        sprintf("- **Resultado:** %s, em %d células comparadas (3 concentrações × 5 datas × 21 semanas). Os valores não são mostrados.",
                if (dif_z == 0) "**igual**" else "**DIFERENTE**", celulas), "")

# ------------------------------------------------------------------ 5. w_j
log_msg("5. w_j")
wj <- ler_csv(f_wj)
n_lt10 <- sum(wj$n_j < 10)
w5 <- do.call(rbind, lapply(SEM, function(jj) {
  x <- wj[wj$j == jj, ]; v <- x$w_j[x$n_j >= 10]                 # desvio 40: só pares com n_j ≥ 10
  data.frame(j = jj, n_conc = length(v), excl = sum(x$n_j < 10), min = min(v), med = median(v), max = max(v),
             soma26 = sum(x$n_j) / sum(x$N_j))
}))
cresc <- vapply(split(wj, wj$recorte_principal), function(x) { x <- x[order(x$j), ]; all(diff(x$w_j) > 0) }, logical(1))
for (i in seq_len(nrow(w5))) { reg("5", paste0("w26_", w5$j[i]), w5$soma26[i]); reg("5", paste0("wmin_", w5$j[i]), w5$min[i])
  reg("5", paste0("wmed_", w5$j[i]), w5$med[i]); reg("5", paste0("wmax_", w5$j[i]), w5$max[i]) }
reg("5", "pares_nj_lt10", n_lt10); reg("5", "conc_crescente", sum(cresc))
md <- c(md, "## 5. w_j (risco condicional de parto na semana j)", "",
        sprintf("- **Pares concentração × semana com n_j < 10:** %d (de %d). Mínimo, mediana e máximo entre as concentrações usam só os pares com n_j ≥ 10 (desvio 40); %s.", n_lt10, nrow(wj),
                if (n_lt10 == 0) "nesta rodada, nenhum par ficou de fora" else sprintf("ficaram de fora %d pares (coluna \"Pares excluídos\")", n_lt10)),
        sprintf("- **26 somadas** (Σ n_j / Σ N_j): %s na semana 22 e %s na semana 36. Especificação (§3.1, distribuição agregada da Q8): cerca de 0,0004 e 0,0428.",
                br(w5$soma26[1], 5), br(w5$soma26[15], 5)),
        sprintf("- **w_j crescente de 22 a 36 semanas** (estritamente, em todos os passos): %d de 26 concentrações. Não é critério de parada.", sum(cresc)),
        if (any(!cresc)) sprintf("  - Não crescentes: %s.", paste(nome[names(cresc)[!cresc]], collapse = ", ")) else NULL, "",
        tabela_md(data.frame(Semana = w5$j, `Mínimo (26)` = br(w5$min, 5), `Mediana (26)` = br(w5$med, 5), `Máximo (26)` = br(w5$max, 5),
                             `Pares excluídos (n_j < 10)` = w5$excl, `26 somadas` = br(w5$soma26, 5), check.names = FALSE)), "")

# ------------------------------------------------------------------ 6. estratos
log_msg("6. estratos")
n_estr <- length(unique(pri$estrato[jp]))
estr_sem <- sum(tapply(pri$ptb[jp], pri$estrato[jp], sum) == 0)
jm <- mun$janela_principal
n_mun <- length(unique(mun$CD_MUN6))
n_estr_mun <- length(unique(mun$estrato_mun[jm]))
estr_mun_sem <- sum(tapply(mun$ptb[jm], mun$estrato_mun[jm], sum) == 0)
exige(estr_sem == 0, "6: estrato concentração × ano × mês sem PTB")
reg("6", "n_estratos", n_estr); reg("6", "estratos_sem_ptb", estr_sem); reg("6", "n_mun", n_mun)
reg("6", "n_estratos_mun", n_estr_mun); reg("6", "estratos_mun_sem_ptb", estr_mun_sem)
md <- c(md, "## 6. Estratos (janela principal)", "",
        sprintf("- **Concentração × ano × mês:** %s estratos; sem nenhum PTB: %s (esperado 0; seriam removidos no modelo).", br(n_estr), br(estr_sem)),
        sprintf("- **Município × ano × mês (A3):** %d municípios, %s estratos; sem nenhum PTB: %s (removidos no ajuste da case time series).",
                n_mun, br(n_estr_mun), br(estr_mun_sem)), "")

# ------------------------------------------------------------------ 7. calendário
log_msg("7. calendário")
cal <- as.data.frame(calendario()); cal$data <- D(cal$data)
pj <- pri[jp, ]; ic <- match(pj$data, cal$data)
dia_iso <- as.integer(format(pj$data, "%u"))                       # 1 = segunda … 7 = domingo, independente do calendario()
rot <- c("seg", "ter", "qua", "qui", "sex", "sab", "dom")
dif_rot <- sum(as.character(pj$dia_semana) != rot[dia_iso]) + sum(cal$dia_semana[ic] != dia_iso)
dif_cal <- dif_rot + sum(pj$feriado_nacional != cal$feriado_nacional[ic]) +
           sum(pj$carnaval != cal$carnaval[ic]) +
           sum(pj$moveis != as.integer(cal$quarta_cinzas[ic] == 1 | cal$sexta_paixao[ic] == 1 | cal$corpus_christi[ic] == 1)) +
           sum(pj$ano != cal$ano[ic]) + sum(pj$mes != cal$mes[ic])
um <- pj[pj$recorte_principal == ordem[1], ]                       # o calendário é o mesmo nas 26
dsem <- table(um$dia_semana)
exige(dif_cal == 0, "7: calendário da série difere do calendario() da base")
for (k in names(dsem)) reg("7", paste0("dias_", k), dsem[[k]])
reg("7", "feriado_nacional", sum(um$feriado_nacional)); reg("7", "carnaval", sum(um$carnaval)); reg("7", "moveis", sum(um$moveis)); reg("7", "dif_cal", dif_cal)
md <- c(md, "## 7. Calendário (janela principal, 4.498 dias; igual nas 26 concentrações)", "",
        tabela_md(data.frame(Item = c(paste("dia_semana =", names(dsem)), "feriado_nacional", "carnaval (segunda e terça)", "moveis (quarta de cinzas, sexta da paixão, corpus christi)"),
                             Dias = br(c(as.numeric(dsem), sum(um$feriado_nacional), sum(um$carnaval), sum(um$moveis))), check.names = FALSE)), "",
        sprintf("- **Origem:** todas as colunas de calendário da série (feriado, carnaval, móveis, ano e mês) conferidas contra o `calendario()` da base, por `data`, e o rótulo do dia da semana contra `format(data, \"%%u\")` (1 = segunda) e contra o `calendario()`, nos %s dias-concentração da janela principal: %s divergências.",
                br(nrow(pj)), br(dif_cal)), "")

# ------------------------------------------------------------------ 8. referências de exposição
log_msg("8. referências")
ref <- ler_csv(f_ref); a53 <- ler_csv(f_a53)
i53 <- match(paste(ref$recorte_principal, ref$periodo), paste(a53$recorte_principal, a53$periodo))
k8 <- c("n_dias", "p1", "p10", "p50", "p75", "p90", "p99", "media", "amplitude_p99_p1")
stopifnot(nrow(ref) == 52, !anyNA(i53), all(k8 %in% names(ref)), all(k8 %in% names(a53)))   # coluna ausente não passa calada
dif8v <- vapply(k8, function(k) { a <- as.numeric(a53[[k]][i53]); stopifnot(!anyNA(a), !anyNA(ref[[k]])); max(abs(ref[[k]] - a)) }, numeric(1))
dif8 <- max(dif8v)
exige(!anyNA(i53) && dif8 <= 1e-12, "8: referências diferem da A5.3 refeita")
ra <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ra <- ra[match(ordem, ra$recorte_principal), ]
reg("8", "dif_max_a53", dif8)
for (i in seq_len(nrow(ra))) { reg("8", paste0("media_", ra$recorte_principal[i]), ra$media[i]); reg("8", paste0("amplitude_", ra$recorte_principal[i]), ra$amplitude_p99_p1[i]) }
md <- c(md, "## 8. Referências de exposição (só exposição)", "",
        sprintf("- **Igualdade com a A5.3 refeita** (A2.6; ano inteiro e novembro a março; 52 linhas; as 9 colunas existem nos dois arquivos, sem NA). Maior |diferença| por coluna: %s (tolerância 1e-12): %s.",
                paste(sprintf("%s %s", names(dif8v), format(dif8v)), collapse = "; "), if (dif8 <= 1e-12) "igual" else "DIFERENTE"),
        "- **Metapreditores** (§6): média e amplitude (p99 − p1) da `tmean_nucleo` diária de 2012-01-01 a 2024-12-31, °C.", "",
        tabela_md(data.frame(Concentração = nome[ra$recorte_principal], `Média (°C)` = br(ra$media, 2), `Amplitude p99 − p1 (°C)` = br(ra$amplitude_p99_p1, 2), check.names = FALSE)), "")

# ------------------------------------------------------------------ 9. PTB espontâneo
log_msg("9. PTB espontâneo")
ok_id <- !is.na(esp$ptb)
dif_id <- sum(esp$ptb_espontaneo_i[ok_id] + esp$ptb_iniciado[ok_id] + esp$ptb_ignorado[ok_id] != esp$ptb[ok_id])
exige(dif_id == 0, "9: identidade espontâneo (i) + iniciado + ignorado = ptb falhou")
esp$ano <- as.integer(format(esp$data, "%Y")); e9 <- esp[esp$ano >= 2013 & esp$ano <= 2023, ]
pct <- function(a, b) 100 * a / b
ano9 <- aggregate(cbind(ptb, ptb_espontaneo_i, ptb_iniciado, ptb_ignorado) ~ ano, data = e9, FUN = sum)
nb2 <- as.data.frame(nascimentos(c("ano", "sttrabpart")))
nb2 <- nb2[nb2$ano >= 2013 & nb2$ano <= 2023, ]
q2a <- tapply(is.na(nb2$sttrabpart) | nb2$sttrabpart %in% "9", nb2$ano, mean) * 100
rm(nb2); invisible(gc())
conc9 <- aggregate(cbind(ptb, ptb_espontaneo_i, ptb_iniciado, ptb_ignorado) ~ recorte_principal, data = e9, FUN = sum)
conc9 <- conc9[match(ordem, conc9$recorte_principal), ]
mascara <- function(x, tot) {                                      # "<10" com supressão complementar nas 3 categorias
  m <- x < 10
  if (sum(m) == 1) m[which.min(ifelse(m, Inf, x))] <- TRUE         # suprime também a menor das outras
  out <- br(pct(x, tot), 1); out[m] <- "<10 casos"; out
}
mk <- function(x) sum(mascara(x, sum(x)) == "<10 casos")             # autoteste da máscara, com dado sintético
stopifnot(mk(c(100, 200, 300)) == 0, mk(c(5, 100, 200)) == 2, mk(c(5, 6, 200)) == 2, mk(c(200, 9, 100)) == 2)
tab9c <- t(vapply(seq_len(nrow(conc9)), function(i) {
  x <- c(conc9$ptb_espontaneo_i[i], conc9$ptb_iniciado[i], conc9$ptb_ignorado[i]); mascara(x, conc9$ptb[i])
}, character(3)))
n_mascaradas <- sum(tab9c == "<10 casos")
for (i in seq_len(nrow(ano9))) { reg("9", paste0("pct_esp_", ano9$ano[i]), pct(ano9$ptb_espontaneo_i[i], ano9$ptb[i]))
  reg("9", paste0("pct_ini_", ano9$ano[i]), pct(ano9$ptb_iniciado[i], ano9$ptb[i])); reg("9", paste0("pct_ign_", ano9$ano[i]), pct(ano9$ptb_ignorado[i], ano9$ptb[i]))
  reg("9", paste0("pct_q2a_", ano9$ano[i]), q2a[[as.character(ano9$ano[i])]]) }
for (i in seq_len(nrow(conc9))) { reg("9", paste0("pct_esp_", conc9$recorte_principal[i]), pct(conc9$ptb_espontaneo_i[i], conc9$ptb[i]))
  reg("9", paste0("pct_ini_", conc9$recorte_principal[i]), pct(conc9$ptb_iniciado[i], conc9$ptb[i]))
  reg("9", paste0("pct_ign_", conc9$recorte_principal[i]), pct(conc9$ptb_ignorado[i], conc9$ptb[i])) }
reg("9", "dif_identidade", dif_id); reg("9", "dias_identidade", sum(ok_id)); reg("9", "celulas_mascaradas", n_mascaradas)
md <- c(md, "## 9. PTB espontâneo (A4; só anos inteiros de 2013 a 2023)", "",
        sprintf("- **Identidade da A4** (espontâneo (i) + iniciado + ignorado = `ptb`, dia a dia): %s divergências em %s dias-concentração com `ptb` definido.", br(dif_id), br(sum(ok_id))),
        "- **Por ano, 26 concentrações somadas** (% entre os PTB da população do `ptb`, pelo ano da data do parto), com a comparação da especificação ao lado: % de `sttrabpart` \"9\" ou vazio entre **todos os NV das 26 concentrações** (população da Q2a: `nascimentos()`, sem coorte e sem filtro de gravidez ou de IG, pelo `ano` do arquivo do SINASC; desvios 45 e 48). A especificação (§3.4) dá 8,9% em 2012 e 1,6% em 2024; aqui as pontas não entram, então a comparação é só de tendência.", "",
        tabela_md(data.frame(Ano = ano9$ano, `Espontâneo (i)` = br(pct(ano9$ptb_espontaneo_i, ano9$ptb), 1), Iniciado = br(pct(ano9$ptb_iniciado, ano9$ptb), 1),
                             Ignorado = br(pct(ano9$ptb_ignorado, ano9$ptb), 1), `sttrabpart 9 ou vazio, todos os NV (Q2a)` = br(q2a[as.character(ano9$ano)], 1), check.names = FALSE)), "",
        sprintf("- **Por concentração, 2013 a 2023 somados** (%% entre os PTB). Categoria com menos de 10 casos sai como \"<10 casos\", com supressão complementar: %d células mascaradas.", n_mascaradas), "",
        tabela_md(data.frame(Concentração = nome[conc9$recorte_principal], `Espontâneo (i)` = tab9c[, 1], Iniciado = tab9c[, 2], Ignorado = tab9c[, 3], check.names = FALSE)), "")

# ------------------------------------------------------------------ 10. municipal
log_msg("10. municipal")
dias_mun_pos <- sum(mun$janela_principal & !is.na(mun$z_t) & mun$z_t > 0)
mun_sem_ptb <- sum(tapply(mun$ptb[jm], mun$CD_MUN6[jm], sum) == 0)
reg("10", "n_mun", n_mun); reg("10", "dias_mun_zt_pos_jp", dias_mun_pos); reg("10", "mun_sem_ptb_jp", mun_sem_ptb)
md <- c(md, "## 10. Case time series municipal (A3)", "",
        sprintf("- **Municípios:** %d.", n_mun),
        sprintf("- **Dias-município com Z_t > 0 na janela principal:** %s (de %s = %d × 4.498).", br(dias_mun_pos), br(n_mun * 4498), n_mun),
        sprintf("- **Municípios sem nenhum PTB na janela principal:** %d.", mun_sem_ptb),
        "- **Nós da `tmean_mun` agrupada:** só gravados (`01_saidas/fase1/nos_tmean_mun_concentracao.csv`), sem ir para o retorno.", "")

# ------------------------------------------------------------------ fecho
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
write.csv(do.call(rbind, VAL), val_out, row.names = FALSE)               # antes do log, para registrar o SHA-256 nele
sha_val <- sub(" .*", "", system2("shasum", c("-a", "256", shQuote(val_out)), stdout = TRUE))
md <- c(md, "## Resultado", "",
        if (length(falhas)) paste0("- **FALHA:** ", falhas) else "- **Todas as conferências obrigatórias passaram** (itens 1, 2, 3, 4, 6, 7, 8 e 9; os itens 3 (DP), 5 e 10 são descritivos).",
        sprintf("- **Valores em formato de máquina** (entrada da autoauditoria; fora do git): `01_saidas/fase1/conferencias_valores.csv`, SHA-256 `%s`.", sha_val), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "e", val_out, "| falhas:", length(falhas), "\n")
if (length(falhas)) { cat(falhas, sep = "\n"); quit(status = 1) }
