# 87_tabelas_m3_fase4.R — Fase 4, marco M3: tabelas do manuscrito (A1-123). Só lê saídas gravadas (SHA-256 conferido);
# nenhum ajuste. Texto das tabelas em inglês americano, números com ponto decimal (formato do manuscrito).
#   tab01: características das 26 concentrações (municípios, PTB na janela principal, % de cesárea e de pré-natal com 7 ou
#          mais consultas, média e p1–p99 da tmean_nucleo de 2012–2024, MRT BLUP com o percentil);
#   tab02: resultados principais (MRT combinada com IC; RR no p99, p95, p90, p10, p5 e p1 contra a MRT; heterogeneidade e
#          Wald dos metapreditores; fração atribuível forward com BLUP, principal, e backward, sensibilidade);
#   tab03: critério da C1 (seis chaves);
#   tabS1: sensibilidades v2 (todas as linhas), com rótulos em inglês;
#   tabS2: BLUPs por concentração (MRT com IC; RR no p99 e no p1 contra a MRT BLUP; borda).
# Contagens só por concentração na janela inteira (todas ≥ 10). Controle: PTB da B1.5 = denominador da fração atribuível.
# Saídas (fora do git): tabelas/<nome>_v1_<RODADA>.csv. Log logs/tabelas_m3_fase4_<RODADA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/87_tabelas_m3_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
VERSAO <- "v4"   # v2: P em 2 casas (estilo AJOG); v3: auditoria interna do M3 (A1-124); v4: auditoria do chat (A1-127): travessão no IC da AF e do AN, linha do AN, S3 e S4; as anteriores ficam
arq <- file.path("logs", paste0("tabelas_m3_fase4_", rodada, "_", VERSAO, ".md")); stopifnot(!file.exists(arq))
dir.create("tabelas", recursive = TRUE, showWarnings = FALSE)
NOMES <- c("tab01_caracteristicas", "tab02_resultados_principais", "tab03_criterio_c1", "tabS1_sensibilidades", "tabS2_blups", "tabS3_contrastes_concentracoes", "tabS4_nula_posthoc")
f_out <- setNames(file.path("tabelas", paste0(NOMES, "_", VERSAO, "_", rodada, ".csv")), NOMES); for (p in f_out) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/87_tabelas_m3_fase4.R"
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
sujos <- git("status", "--porcelain", "--", ESTE); if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current"); st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:"); inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
FIXO <- c("01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds" = "52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e",
          "01_saidas/fase1/referencias_exposicao.csv" = "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467",
          "01_saidas/fase3/fracao_atribuivel_fase3_20261013.csv" = "9437e9668c729ffd502a159038d2d557b4d8767d1a046cb86eef13ddb2659a48",
          "01_saidas/fase3/posthoc_af_fase3_20261013.rds" = "223e09366a445b99bd947d3f59f66fa20d755b019af149bfeb4bac026593d11d")
DO_LOG <- c("01_saidas/fase4/contagens_insumos_fase4.csv" = "logs/contagens_insumos_fase4_20261018.md",
            "01_saidas/fase4/criterio_c1_fase4_20261019.csv" = "logs/c1_chaves_fase4_20261019.md",
            "01_saidas/fase4/tabela_sensibilidades_fase4_v2.csv" = "logs/m2_menores_tabela_v2_fase4_20261019.md",
            "01_saidas/fase4/tmr_p10p90_fase4_20261019.csv" = "logs/tmr_p10p90_fase4_20261019.md")
sha_ent <- vapply(c(names(FIXO), names(DO_LOG)), sha, "")
if (!identical(unname(sha_ent[names(FIXO)]), unname(FIXO))) stop("entrada fixa com SHA-256 diferente do registrado: ", paste(names(FIXO)[sha_ent[names(FIXO)] != FIXO], collapse = ", "))
for (p in names(DO_LOG)) if (!grepl(paste0("`", p, "`: `", sha_ent[[p]], "`"), paste(readLines(DO_LOG[[p]], encoding = "UTF-8"), collapse = "\n"), fixed = TRUE)) stop(p, ": SHA-256 diferente do registrado em ", DO_LOG[[p]])
src <- new.env(); sys.source(file.path(REPO, "codigo_compartilhado", "R", "segunda_etapa.R"), envir = src)
nuc <- as.data.frame(cidade_nucleo()); src$confere_ordem(nuc$CD_RECORTE); ordem <- src$ORDEM_CONCENTRACOES
nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE); nucleo <- setNames(nuc$NM_MUN_NUCLEO, nuc$CD_RECORTE)
r45 <- readRDS(names(FIXO)[1])
ref <- utils::read.csv(names(FIXO)[2], colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8"); ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ordem, ref$recorte_principal), ]
af <- utils::read.csv(names(FIXO)[3], colClasses = c(recorte_principal = "character"), encoding = "UTF-8")
cont <- utils::read.csv(names(DO_LOG)[1], colClasses = c(recorte_principal = "character")); cont <- cont[match(ordem, cont$recorte_principal), ]
c1 <- utils::read.csv(names(DO_LOG)[2], stringsAsFactors = FALSE, encoding = "UTF-8", na.strings = c("", "NA"))
tv2 <- utils::read.csv(names(DO_LOG)[3], stringsAsFactors = FALSE, encoding = "UTF-8", na.strings = c("", "NA"))
mun <- as.data.frame(concentracoes()); n_mun <- vapply(ordem, function(r) sum(mun$CD_RECORTE == r), 0L)
sem_uf <- !grepl("/", nome); nome[sem_uf] <- paste0(nome[sem_uf], "/", mun$SIGLA_UF[match(names(nome)[sem_uf], mun$CD_RECORTE)])   # municípios isolados (Manaus, Campo Grande)
p1090 <- utils::read.csv(names(DO_LOG)[4], colClasses = c(recorte_principal = "character"), encoding = "UTF-8")
f1 <- function(x) formatC(x, format = "f", digits = 1); f2 <- function(x) formatC(x, format = "f", digits = 2); f3 <- function(x) formatC(x, format = "f", digits = 3)
n_ <- function(x) formatC(x, format = "d", big.mark = ",")
ci <- function(a, li, ls, d = 3) ifelse(is.na(a), "—", ifelse(is.na(li), "1 (boundary)", sprintf("%s (%s–%s)", formatC(a, format = "f", digits = d), formatC(li, format = "f", digits = d), formatC(ls, format = "f", digits = d))))
pc <- function(p) vapply(p, function(x) if (x < 0.001) "<.001" else sub("^0", "", formatC(x, format = "f", digits = if (x < 0.01) 3 else 2)), "")   # estilo AJOG: 2 casas, 3 abaixo de .01
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"), apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
grava <- function(df, k) utils::write.csv(df, f_out[[k]], row.names = FALSE, fileEncoding = "UTF-8")

# ------------------------------------------------------------------ tab01
tb <- r45$tmr[r45$tmr$nivel == "blup", ]; tb <- tb[match(ordem, tb$recorte_principal), ]
den <- af[af$analise == "principal" & af$componente == "total" & af$recorte_principal %in% ordem, ]; den <- den[match(ordem, den$recorte_principal), ]
ok_den <- identical(as.numeric(cont$ptb), as.numeric(den$denominador)); if (!ok_den) stop("PTB da B1.5 diferente do denominador da fração atribuível")
stopifnot(all(cont$ptb >= 10))
t1 <- data.frame(`Urban concentration` = nome[ordem], `Core city` = nucleo[ordem], Municipalities = n_mun, `Preterm births, n` = n_(cont$ptb),
                 `Cesarean, %` = f1(cont$pct_cesarea), `≥7 prenatal visits, %` = f1(cont$pct_prenatal_7mais),
                 `Mean temperature, °C` = f1(ref$media), `1st–99th percentile, °C` = sprintf("%s–%s", f1(ref$p1), f1(ref$p99)),
                 `MRT (BLUP), °C (percentile)` = sprintf("%s (%s)%s", f1(tb$tmr), f1(100 * tb$percentil_tmr), ifelse(tb$fronteira, "†", "")), check.names = FALSE, row.names = NULL)
t1 <- rbind(t1, data.frame(`Urban concentration` = "All 26", `Core city` = "—", Municipalities = sum(n_mun), `Preterm births, n` = n_(sum(cont$ptb)), `Cesarean, %` = "—",
                           `≥7 prenatal visits, %` = "—", `Mean temperature, °C` = "—", `1st–99th percentile, °C` = "—",
                           `MRT (BLUP), °C (percentile)` = sprintf("%s (%s), pooled", f1(r45$tmr$tmr[r45$tmr$nivel == "combinada"]), f1(100 * r45$tmr$percentil_tmr[r45$tmr$nivel == "combinada"])), check.names = FALSE))
grava(t1, "tab01_caracteristicas")

# ------------------------------------------------------------------ tab02
tc <- r45$tmr[r45$tmr$nivel == "combinada", ]; ct <- r45$contrastes[r45$contrastes$nivel == "combinada", ]; PER <- c("p99", "p95", "p90", "p10", "p5", "p1")
ct <- ct[match(PER, ct$percentil), ]; h <- r45$meta$heterogeneidade$residual; w <- r45$meta$wald
aft <- function(an) { z <- af[af$analise == an & af$recorte_principal == "total", ]; z[match(c("total", "calor", "frio", "calor_extremo", "frio_extremo"), z$componente), ] }
afp <- aft("principal"); afb <- aft("backward")
t2 <- rbind(
  data.frame(Quantity = "Pooled MRT, °C (percentile) [95% CI]", `Temperature, °C` = f1(tc$tmr), Estimate = sprintf("%s (%s) [%s–%s]", f1(tc$tmr), f1(100 * tc$percentil_tmr), f1(tc$ic_li), f1(tc$ic_ls)), check.names = FALSE),
  data.frame(Quantity = paste0("Cumulative RR (lag 0–7), ", c("99th", "95th", "90th", "10th", "5th", "1st"), " percentile vs MRT"), `Temperature, °C` = f1(ct$temperatura),
             Estimate = ci(ct$rr, ct$rr_li, ct$rr_ls), check.names = FALSE),
  data.frame(Quantity = c("Residual heterogeneity, Cochran Q (df); P; I²", "Wald test, mean temperature (meta-predictor); P", "Wald test, temperature range (meta-predictor); P"), `Temperature, °C` = "—",
             Estimate = c(sprintf("%s (%d); %s; %s%%", f1(h$Q), as.integer(h$df), pc(h$p), f1(h$I2)), pc(w$p[w$termo == "media"]), pc(w$p[w$termo == "amplitude"])), check.names = FALSE),
  data.frame(Quantity = paste0("Attributable fraction, % [eCI], ", c("total", "heat", "cold", "extreme heat (>97.5th)", "extreme cold (<2.5th)"), " (forward, BLUP; backward)"), `Temperature, °C` = "—",
             Estimate = sprintf("%s (%s–%s); %s (%s–%s)", f2(100 * afp$af), f2(100 * afp$af_li), f2(100 * afp$af_ls), f2(100 * afb$af), f2(100 * afb$af_li), f2(100 * afb$af_ls)), check.names = FALSE),
  data.frame(Quantity = "Attributable number, n (eCI), total (forward, BLUP; backward)", `Temperature, °C` = "—",
             Estimate = sprintf("%s (%s–%s); %s (%s–%s)", n_(round(afp$an[1])), n_(round(afp$an_li[1])), n_(round(afp$an_ls[1])), n_(round(afb$an[1])), n_(round(afb$an_li[1])), n_(round(afb$an_ls[1]))), check.names = FALSE))
stopifnot(all(afp$af_li > 0), all(afb$af_li > 0), afp$an_li[1] > 0, afb$an_li[1] > 0)   # travessão sem ambiguidade de sinal
grava(t2, "tab02_resultados_principais")

# ------------------------------------------------------------------ tab03
EN_K <- c("Municipal temperature (case time series)", "Lag 0–14", "ns(time, 99 df), no strata", "+ PM2.5 (lag 0–1, linear)", "γ = 1 in the offset", "Spontaneous preterm birth (i)")
t3 <- data.frame(Key = c1$chave, Analysis = EN_K[c1$chave], `MRT, °C (percentile) [95% CI]` = sprintf("%s (%s) [%s–%s]", f1(c1$tmr), f1(100 * c1$percentil_tmr), f1(c1$ic_tmr_li), f1(c1$ic_tmr_ls)),
                 `RR 99th vs MRT (95% CI)` = ci(c1$rr99, c1$rr99_li, c1$rr99_ls), `RR 1st vs MRT (95% CI)` = ci(c1$rr01, c1$rr01_li, c1$rr01_ls),
                 `Within primary 95% CI (99th; 1st)` = sprintf("%s; %s", ifelse(c1$dentro99, "yes", "no"), ifelse(c1$dentro01, "yes", "no")),
                 `Same direction (99th; 1st)` = sprintf("%s; %s", ifelse(c1$direcao99, "yes", "no"), ifelse(c1$direcao01, "yes", "no")), check.names = FALSE)
grava(t3, "tab03_criterio_c1")

# ------------------------------------------------------------------ tabS1
EN <- c("P0" = "Primary analysis", "C2-D3" = "+ lagged deviance residuals (lags 1–7)", "C3-E1" = "Births-weighted metropolitan temperature", "C3-E2" = "Maximum temperature", "C3-E3" = "Minimum temperature",
        "C3-E4" = "Apparent temperature", "C3-E5" = "+ relative humidity (lag 0–3)", "C3-P1" = "+ PM2.5, zero-missing series (23 concentrations)", "C3-CB1" = "Lag 0–4", "C3-CB2" = "Lag 0–21",
        "C3-CB3" = "Quadratic B-spline, knots p10/p75/p90", "C3-CB4" = "Natural spline, knots p50/p90", "C3-T1" = "ns(time, 74 df), no strata", "C3-T2" = "ns(time, 123 df), no strata", "C3-T3" = "Strata × day of week",
        "C3-T4" = "Excluding Dec 24 to Jan 1", "C3-T5" = "Excluding 2020–2021", "C3-T6" = "Warm season, Nov–Mar (own axis; MRT searched between 1st and 50th)", "C3-T7" = "+ negative control exposure (t+1 to t+7)",
        "C3-D1" = "Fetal deaths in the risk set", "C3-D2" = "Delivery risk weights by entry year", "C3-D3o" = "No offset", "C3-D4" = "Possible-event window (2012-01-04 to 2024-11-15)",
        "C3-O1" = "Extremely preterm, 22–27 wk (18 concentrations)", "C3-O2" = "Very preterm, 28–31 wk", "C3-O3" = "Moderate-to-late preterm, 32–36 wk", "C3-O4" = "Spontaneous preterm birth (ii)",
        "C3-O5" = "Births with gestational age dated by the LMP, GA from the SINASC field (i)", "C3-O6" = "Births with gestational age dated by the LMP, GA from the LMP (ii)", "C3-O7" = "2011 cohort, arm A (no offset, no fixed cohort)", "C3-O8" = "2011 cohort, arm B (no offset, no fixed cohort)",
        "C3-O9" = "Early term, 37–38 wk (comparison outcome)", "C3-O10" = "Early term, intersection window", "C3-NB" = "Negative binomial model", "C3-N2000" = "Inclusion threshold of 2,000 events", "C3-FL" = "+ local holidays (and Dec 24 and 31)",
        "C4-FIX" = "Fixed-effects meta-analysis", "C4-MULTI" = "Multilevel meta-analysis (concentration within macroregion)", "C4-EX-regiao" = "Exploratory meta-regression: macroregion",
        "C4-EX-cesarea" = "Exploratory meta-regression: cesarean, %", "C4-EX-prenatal" = "Exploratory meta-regression: ≥7 prenatal visits, %", "C4-EX-idhm" = "Exploratory meta-regression: MHDI 2010",
        "C4-UMA" = "One-stage model", "C4-S3" = "Penalized DLNM (contrasts vs concentration-specific reference)")
stopifnot(all(tv2$id %in% names(EN)))
nota_en <- function(id, st) ifelse(id == "C3-NB", "Not applicable (dispersion >2 in 0 of 26 concentrations in the primary analysis)", ifelse(id == "C3-N2000", "Identical to the primary analysis (no concentration excluded)", ""))
ex <- grepl("^C4-EX", tv2$id); wx <- regmatches(tv2$nota, regexec("^Wald ([0-9]+,[0-9]+) \\(([0-9]+) gl; p = ([0-9,]+)\\)", tv2$nota))
wald_en <- vapply(seq_along(wx), function(k) if (ex[k] && length(wx[[k]]) == 4) sprintf("Wald %s (%s df); P = %s", sub(",", ".", wx[[k]][2]), wx[[k]][3], pc(as.numeric(sub(",", ".", wx[[k]][4])))) else "", "")
stopifnot(all(nzchar(wald_en[ex])))
tS1 <- data.frame(ID = tv2$id, Analysis = EN[tv2$id], `N concentrations` = ifelse(is.na(tv2$n_concentracoes), "—", tv2$n_concentracoes),
                  `MRT, °C (percentile)` = ifelse(is.na(tv2$tmr_c), "—", sprintf("%s (%s)", f1(tv2$tmr_c), f1(tv2$tmr_percentil))),
                  `MRT 95% CI, °C` = ifelse(is.na(tv2$ic_tmr_li), "—", sprintf("%s–%s", f1(tv2$ic_tmr_li), f1(tv2$ic_tmr_ls))),
                  `RR 99th vs MRT (95% CI)` = ci(tv2$rr99, tv2$rr99_li, tv2$rr99_ls), `RR 1st vs MRT (95% CI)` = ci(tv2$rr01, tv2$rr01_li, tv2$rr01_ls),
                  `Dispersion (min; median; max)` = ifelse(is.na(tv2$phi_med), "—", sprintf("%s; %s; %s", f2(tv2$phi_min), f2(tv2$phi_med), f2(tv2$phi_max))),
                  `RR vs median, 99th (95% CI)` = ifelse(is.na(tv2$borda), "\u2014", ci(tv2$rr_mediana_x99, tv2$rr_mediana_x99_li, tv2$rr_mediana_x99_ls)),
                  `RR vs median, 1st (95% CI)` = ifelse(is.na(tv2$borda), "\u2014", ci(tv2$rr_mediana_x1, tv2$rr_mediana_x1_li, tv2$rr_mediana_x1_ls)),
                  Note = ifelse(ex, wald_en, nota_en(tv2$id, tv2$status)), check.names = FALSE)
grava(tS1, "tabS1_sensibilidades")

# ------------------------------------------------------------------ tabS2
cb <- r45$contrastes[r45$contrastes$nivel == "blup", ]
g <- function(r, p, col) cb[[col]][cb$recorte_principal == r & cb$percentil == p]
tS2 <- data.frame(`Urban concentration` = nome[ordem], `MRT, °C (percentile) [95% CI]` = sprintf("%s (%s) [%s–%s]%s", f1(tb$tmr), f1(100 * tb$percentil_tmr), f1(tb$ic_li), f1(tb$ic_ls), ifelse(tb$fronteira, "†", "")),
                  `99th percentile, °C` = f1(vapply(ordem, g, 0, p = "p99", col = "temperatura")),
                  `RR 99th vs MRT (95% CI)` = ifelse(tb$fronteira, "1 (boundary)", ci(vapply(ordem, g, 0, p = "p99", col = "rr"), vapply(ordem, g, 0, p = "p99", col = "rr_li"), vapply(ordem, g, 0, p = "p99", col = "rr_ls"))),
                  `1st percentile, °C` = f1(vapply(ordem, g, 0, p = "p1", col = "temperatura")),
                  `RR 1st vs MRT (95% CI)` = ci(vapply(ordem, g, 0, p = "p1", col = "rr"), vapply(ordem, g, 0, p = "p1", col = "rr_li"), vapply(ordem, g, 0, p = "p1", col = "rr_ls")), check.names = FALSE, row.names = NULL)
# borda: busca entre p10 e p90 (73) e RR contra a mediana (linhas blup_mediana do 45)
cm <- r45$contrastes[r45$contrastes$nivel == "blup_mediana", ]; gm <- function(r, p, col) { v <- cm[[col]][cm$recorte_principal == r & cm$percentil == p]; if (length(v)) v else NA_real_ }
ib <- match(ordem, p1090$recorte_principal); stopifnot(identical(!is.na(ib), tb$fronteira))
tS2$`Minimum searched between 10th and 90th, °C [95% CI]` <- ifelse(is.na(ib), "\u2014", sprintf("%s [%s\u2013%s]%s", f1(p1090$busca_p10_p90[ib]), f1(p1090$ic_li[ib]), f1(p1090$ic_ls[ib]),
  ifelse(abs(p1090$busca_p10_p90[ib] - p1090$p90[ib]) < 1e-9 | abs(p1090$busca_p10_p90[ib] - p1090$p10[ib]) < 1e-9, "\u2021", "")))
tS2$`RR vs median, 99th (95% CI)` <- ifelse(tb$fronteira, ci(vapply(ordem, gm, 0, p = "p99", col = "rr"), vapply(ordem, gm, 0, p = "p99", col = "rr_li"), vapply(ordem, gm, 0, p = "p99", col = "rr_ls")), "\u2014")
tS2$`RR vs median, 1st (95% CI)` <- ifelse(tb$fronteira, ci(vapply(ordem, gm, 0, p = "p1", col = "rr"), vapply(ordem, gm, 0, p = "p1", col = "rr_li"), vapply(ordem, gm, 0, p = "p1", col = "rr_ls")), "\u2014")
grava(tS2, "tabS2_blups")
# S3: contrastes secundários por concentração (linhas blup do 45), em °C
PS <- c("p95", "p90", "p10", "p5"); tS3 <- data.frame(`Urban concentration` = nome[ordem], check.names = FALSE, row.names = NULL)
for (pp in PS) { lab <- c(p95 = "95th", p90 = "90th", p10 = "10th", p5 = "5th")[[pp]]
  tS3[[paste0(lab, " percentile, °C")]] <- f1(vapply(ordem, g, 0, p = pp, col = "temperatura"))
  tS3[[paste0("RR ", lab, " vs MRT (95% CI)")]] <- ci(vapply(ordem, g, 0, p = pp, col = "rr"), vapply(ordem, g, 0, p = pp, col = "rr_li"), vapply(ordem, g, 0, p = pp, col = "rr_ls")) }
grava(tS3, "tabS3_contrastes_concentracoes")
# S4: distribuição sob nenhuma associação (P2 da D5, item 4, passo 7)
ph <- readRDS(names(FIXO)[4]); dsc <- ph$resumo$descritivas; od <- ph$obs_desc; stopifnot(ph$resumo$n == 1000L, ph$resumo$n_falhas == 0L)
fq <- function(q, v) if (q %in% c("af_calor", "af_frio")) paste0(f2(100 * v), "%") else if (q %in% c("rr_x99", "rr_x1")) f3(v) else formatC(v, format = "d")
lab4 <- c(af_calor = "Attributable fraction, heat", af_frio = "Attributable fraction, cold", rr_x99 = "Pooled RR, 99th percentile vs MRT", rr_x1 = "Pooled RR, 1st percentile vs MRT", n_mrt_p99 = "Concentrations with the MRT at the 99th percentile, n", n_mrt_p1 = "Concentrations with the MRT at the 1st percentile, n")
tS4 <- data.frame(Quantity = c("Attributable fraction, total", lab4[dsc$quantidade]),
                  Observed = c(paste0(f2(100 * ph$af_obs), "%"), vapply(dsc$quantidade, function(q) fq(q, od[[q]]), "")),
                  `Null median` = c(paste0(f2(100 * ph$resumo$af_total[["mediana"]]), "%"), vapply(seq_len(nrow(dsc)), function(k) fq(dsc$quantidade[k], dsc$mediana[k]), "")),
                  `Null 2.5th–97.5th percentiles` = c(sprintf("%s%%–%s%%", f2(100 * ph$resumo$af_total[["p2_5"]]), f2(100 * ph$resumo$af_total[["p97_5"]])), vapply(seq_len(nrow(dsc)), function(k) sprintf("%s–%s", fq(dsc$quantidade[k], dsc$p2_5[k]), fq(dsc$quantidade[k], dsc$p97_5[k])), "")), check.names = FALSE, row.names = NULL)
grava(tS4, "tabS4_nula_posthoc")
sha_out <- vapply(f_out, sha, ""); stopifnot(versao() == "4443971b")
md <- c("# Fase 4, marco M3: tabelas do manuscrito", "",
  sprintf("- **Gerado por:** `00_scripts/87_tabelas_m3_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()`: %s.", sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  "- **Entradas (SHA-256 = registrados):**", sprintf("  - `%s`: `%s`;", names(sha_ent), sha_ent),
  sprintf("- **Controle:** PTB por concentração da B1.5 igual ao denominador da fração atribuível nas 26: %s (total %s). Todas as contagens ≥ 10.", if (ok_den) "sim" else "não", n_(sum(cont$ptb))),
  "- **Decisões:** A1-123, A1-124 e A1-127. Tabelas em inglês americano, prontas para o manuscrito; † = MRT na borda da grade (p99); ‡ = mínimo da busca p10–p90 numa ponta da faixa.", "",
  "## tab01", "", tabela_md(t1), "", "## tab02", "", tabela_md(t2), "", "## tab03", "", tabela_md(t3), "", "## tabS1", "", tabela_md(tS1), "", "## tabS2", "", tabela_md(tS2), "", "## tabS3", "", tabela_md(tS3), "", "## tabS4", "", tabela_md(tS4), "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", f_out, sha_out), "", "- **Resultado:** ok.", "")
writeLines(md, arq, useBytes = TRUE); cat("gravado:", arq, "\n")
