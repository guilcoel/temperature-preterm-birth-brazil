# 90_manuscrito_m4_fase4.R — Fase 4: correções v3 do Methods e do Results e marco M4 (manuscrito completo), em inglês americano
# (A1-127). Só lê saídas gravadas (SHA-256 conferido contra os logs de origem); nenhum ajuste. Todo número sai das saídas por
# código, e as afirmações factuais são conferidas por stopifnot antes de entrar no texto.
# Frases prescritas: entram literais e inteiras, conferidas contra o arquivo de spec (SHA-256 conferido no SHA256SUMS ou no
# INDICE), com as substituições que as próprias decisões ou o chat do A1 mandam, todas listadas no log. Pela regra do chat
# (correção 5), as que não ficam no texto principal vão inteiras para o Supplementary Methods, com remissão no texto.
# Citações como chaves [@Chave], resolvidas pelo script 91 contra manuscrito/referencias_m4.csv (só as verificadas).
# Placeholders que não são inventados aqui: o link anônimo do revisor e os dados da página de título (o DOI e o [repository] saíram pela A1-143).
# Saídas (fora do git): manuscrito/m4/{manuscrito,suplemento,pagina_titulo,highlights,legendas}_<RODADA>.md.
# Log logs/manuscrito_m4_fase4_<RODADA>.md (contagem de palavras por seção, conferências e o texto inteiro).
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/90_manuscrito_m4_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
VERSAO <- "v8"   # v2: auditoria do M4 (A1-129); v3: auditoria do chat sobre o M4 (A1-132); v4: auditoria curta da v3 (A1-134); v5: retorno do chat e M5 (A1-138); v6: códigos e algoritmos para a RECORD (A1-139); v7: M5b (A1-143 a A1-145); v8: regra da Introduction restaurada (A1-147)
arq <- file.path("logs", paste0("manuscrito_m4_fase4_", rodada, "_", VERSAO, ".md")); stopifnot(!file.exists(arq))
D <- file.path("manuscrito", "m4"); dir.create(D, recursive = TRUE, showWarnings = FALSE)
OUT <- setNames(file.path(D, paste0(c("manuscrito", "suplemento", "pagina_titulo", "highlights", "legendas"), "_", VERSAO, "_", rodada, ".md")),
                c("manuscrito", "suplemento", "pagina_titulo", "highlights", "legendas"))
for (p in OUT) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/90_manuscrito_m4_fase4.R"
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
DRY <- identical(Sys.getenv("DRY"), "1")   # ensaio: só conta palavras e confere, sem gravar nada (nem log)
sujos <- git("status", "--porcelain", "--", ESTE); if (!DRY && length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current"); st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:"); inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
FIXO <- c(rds32 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", rds45 = "01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds",
          af = "01_saidas/fase3/fracao_atribuivel_fase3_20261013.csv", ph = "01_saidas/fase3/posthoc_af_fase3_20261013.rds", s4 = "01_saidas/fase4/serie_ptb_fase4.rds")
SHA_FIXO <- c(rds32 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d", rds45 = "52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e",
              af = "9437e9668c729ffd502a159038d2d557b4d8767d1a046cb86eef13ddb2659a48", ph = "223e09366a445b99bd947d3f59f66fa20d755b019af149bfeb4bac026593d11d",
              s4 = "e70190c1bf7c0fa5ba9c9f1e3cacb46f1ef8d647fc04a8606d181f7c819793e0")
DO_LOG <- c("01_saidas/fase4/criterio_c1_fase4_20261019.csv" = "logs/c1_chaves_fase4_20261019.md", "01_saidas/fase4/tabela_sensibilidades_fase4_v2.csv" = "logs/m2_menores_tabela_v2_fase4_20261019.md",
            "01_saidas/fase4/tmr_p10p90_fase4_20261019.csv" = "logs/tmr_p10p90_fase4_20261019.md", "01_saidas/fase4/contrastes_estacao_quente_fase4.csv" = "logs/m2_menores_tabela_v2_fase4_20261019.md",
            "01_saidas/fase4/ic_tmr_uma_etapa_16coef_fase4.rds" = "logs/m2_menores_tabela_v2_fase4_20261019.md", "01_saidas/fase4/pacf_d3_fase4_20261019.csv" = "logs/d3_fase4_20261019.md",
            "01_saidas/fase3/contribuicoes_negativas_fase3_20261013.csv" = "logs/fracao_atribuivel_fase3_20261013.md", "01_saidas/fase3/posthoc_item2_fase3_20261013.csv" = "logs/posthoc_af_fase3_20261013.md",
            "01_saidas/fase4/c3_fase4_20261019.rds" = "logs/c3_fase4_20261019.md")
sha_fx <- vapply(FIXO, sha, ""); if (!identical(unname(sha_fx), unname(SHA_FIXO))) stop("entrada fixa com SHA-256 diferente do registrado: ", paste(names(FIXO)[sha_fx != SHA_FIXO], collapse = ", "))
sha_dl <- vapply(names(DO_LOG), sha, ""); for (p in names(DO_LOG)) if (!grepl(paste0("`", p, "`: `", sha_dl[[p]], "`"), paste(readLines(DO_LOG[[p]], encoding = "UTF-8"), collapse = "\n"), fixed = TRUE)) stop(p, ": SHA-256 diferente do registrado em ", DO_LOG[[p]])
# arquivos de spec com as frases prescritas (SHA-256 conferido no manifesto ou no índice)
SPEC <- c(dec08 = "spec/decisoes_metodo_20261008.md", d5 = "spec/decisoes_metodo_20261013_D5_interpretacao_AF.md", e5 = "spec/decisoes_metodo_20261014_errata_D5.md",
          d10 = "spec/decisoes_metodo_20261015_TODOS_D10_concordancia_coordenacao_git.md", comp = "spec/decisoes_metodo_20261013_complemento.md")
man <- paste(readLines(file.path(REPO, "spec", "SHA256SUMS"), encoding = "UTF-8"), collapse = "\n"); ind <- paste(readLines(file.path(REPO, "spec", "INDICE_decisoes_metodo_TODOS.md"), encoding = "UTF-8"), collapse = "\n")
sha_sp <- vapply(SPEC, function(p) sha(file.path(REPO, p)), "")
stopifnot(grepl(paste0(sha_sp[["dec08"]], "  ", SPEC[["dec08"]]), man, fixed = TRUE), all(vapply(sha_sp[-1], function(s) grepl(s, ind, fixed = TRUE), TRUE)))
lit <- function(k, inicio) { l <- readLines(file.path(REPO, SPEC[[k]]), encoding = "UTF-8"); l <- sub("^\\s*> ", "", l[grepl(paste0("^\\s*> ", inicio), l)]); stopifnot(length(l) == 1L); l }

src <- new.env(); sys.source(file.path(REPO, "codigo_compartilhado", "R", "segunda_etapa.R"), envir = src)
nuc <- as.data.frame(cidade_nucleo()); src$confere_ordem(nuc$CD_RECORTE); ordem <- src$ORDEM_CONCENTRACOES; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
rds32 <- readRDS(FIXO[["rds32"]])$resultados; r45 <- readRDS(FIXO[["rds45"]]); ph <- readRDS(FIXO[["ph"]])
af <- utils::read.csv(FIXO[["af"]], colClasses = c(recorte_principal = "character"), encoding = "UTF-8")
c1 <- utils::read.csv(names(DO_LOG)[1], stringsAsFactors = FALSE, encoding = "UTF-8", na.strings = c("", "NA"))
tv2 <- utils::read.csv(names(DO_LOG)[2], stringsAsFactors = FALSE, encoding = "UTF-8", na.strings = c("", "NA"))
p1090 <- utils::read.csv(names(DO_LOG)[3], colClasses = c(recorte_principal = "character"), encoding = "UTF-8")
nov <- utils::read.csv(names(DO_LOG)[4], encoding = "UTF-8")
ic16 <- readRDS(names(DO_LOG)[5])
pacf <- utils::read.csv(names(DO_LOG)[6], colClasses = c(recorte_principal = "character"), encoding = "UTF-8")
neg <- utils::read.csv(names(DO_LOG)[7], colClasses = c(recorte_principal = "character"), encoding = "UTF-8")
it2 <- utils::read.csv(names(DO_LOG)[8], colClasses = c(recorte_principal = "character"), encoding = "UTF-8")
s4 <- as.data.frame(readRDS(FIXO[["s4"]])); j <- s4$janela_principal %in% TRUE
mun <- as.data.frame(concentracoes())
f1 <- function(x) formatC(x, format = "f", digits = 1); f2 <- function(x) formatC(x, format = "f", digits = 2); f3 <- function(x) formatC(x, format = "f", digits = 3); f4 <- function(x) formatC(x, format = "f", digits = 4)
n_ <- function(x) formatC(x, format = "d", big.mark = ",")
pP <- function(p) if (p < 0.001) "P < .001" else paste("P =", sub("^0", "", formatC(p, format = "f", digits = if (p < 0.01) 3 else 2)))
pv <- function(p) if (p < 0.001) "<.001" else sub("^0", "", formatC(p, format = "f", digits = if (p < 0.01) 3 else 2))
ci3 <- function(a, li, ls) sprintf("%s (95%% CI, %s–%s)", f3(a), f3(li), f3(ls)); ci3s <- function(a, li, ls) sprintf("%s; 95%% CI, %s–%s", f3(a), f3(li), f3(ls))
ci4s <- function(a, li, ls) sprintf("%s; 95%% CI, %s–%s", f4(a), f4(li), f4(ls))
abs3 <- function(a, li, ls) sprintf("%s (95%% confidence interval, %s to %s)", f3(a), f3(li), f3(ls))
pct <- function(x) paste0(f1(100 * x), "%")
mn <- function(s) sub("^-", "−", s)   # sinal de menos tipográfico
sup <- function(e) chartr("-0123456789", "⁻⁰¹²³⁴⁵⁶⁷⁸⁹", as.character(e))
sci <- function(x, d) vapply(x, function(v) { e <- floor(log10(abs(v))); mn(sprintf("%s × 10%s", formatC(v / 10^e, format = "f", digits = d), sup(e))) }, "")
lista <- function(v) if (length(v) < 3) paste(v, collapse = " and ") else paste0(paste(v[-length(v)], collapse = ", "), ", and ", v[length(v)])

# ------------------------------------------------------------------ números (os do 88 v2, mais os da v3)
stopifnot(all(vapply(rds32, function(x) identical(x$situacao, "principal") && is.null(x$fallback), TRUE)))
n_ptb <- sum(s4$ptb[j]); n_nv <- sum(s4$nv_unicos[j]); n_dias <- length(unique(s4$data[j])); stopifnot(n_ptb >= 10, n_nv >= 10)
af_den <- sum(af$denominador[af$analise == "principal" & af$componente == "total" & af$recorte_principal %in% ordem]); stopifnot(identical(as.numeric(n_ptb), as.numeric(af_den)))
phi <- vapply(rds32, function(x) x$principal$phi, 0); gama <- vapply(rds32, function(x) x$principal$gama, 0)
tc <- r45$tmr[r45$tmr$nivel == "combinada", ]; tb <- r45$tmr[r45$tmr$nivel == "blup", ]
ct <- r45$contrastes[r45$contrastes$nivel == "combinada", ]; rr <- function(p, k) ct[[k]][ct$percentil == p]
h <- r45$meta$heterogeneidade$residual; w <- r45$meta$wald
n_borda <- sum(tb$fronteira & abs(tb$tmr - tb$x_sup) < 1e-9); stopifnot(n_borda == sum(tb$fronteira))
afp <- function(k, an = "principal") af[af$analise == an & af$recorte_principal == "total" & af$componente == k, ]
an_t <- afp("total"); lr <- r45$lagresposta$curva
pool_null <- all(ct$rr_li <= 1 & ct$rr_ls >= 1)
ic_inteiro <- isTRUE(all.equal(c(tc$ic_li, tc$ic_ls), c(tc$x_inf, tc$x_sup), tolerance = 1e-9))
stopifnot(pool_null, ic_inteiro, n_borda == 10L, ph$resumo$n_falhas == 0L, !ph$resumo$passa)
# calor extremo = acima de max(p97,5; MRT): coincide com o calor nas concentrações com MRT no p97,5 ou acima, que são as 10 da borda
stopifnot(sum(tb$percentil_tmr >= 0.975) == n_borda, all(tb$fronteira[tb$percentil_tmr >= 0.975]), all(tb$percentil_tmr > 0.025))
dentro99 <- sum(c1$dentro99); dentro01 <- sum(c1$dentro01); fora01 <- c1[!c1$dentro01, ]
oa <- tv2[!is.na(tv2$tmr_c) & tv2$id != "P0", ]; oa_nb <- oa[is.na(oa$borda), ]; oa_b <- oa[!is.na(oa$borda), ]
med <- do.call(rbind, lapply(seq_len(nrow(oa_b)), function(k) { z <- oa_b[k, ]; rbind(data.frame(id = z$id, lado = "x99", rr = z$rr_mediana_x99, li = z$rr_mediana_x99_li, ls = z$rr_mediana_x99_ls), data.frame(id = z$id, lado = "x1", rr = z$rr_mediana_x1, li = z$rr_mediana_x1_li, ls = z$rr_mediana_x1_ls)) }))
med_ex <- med[!is.na(med$li) & (med$li > 1 | med$ls < 1), ]
uni <- tv2[tv2$id == "C4-UMA", ]; s3 <- tv2[tv2$id == "C4-S3", ]; fix <- tv2[tv2$id == "C4-FIX", ]; fl <- tv2[tv2$id == "C3-FL", ]
cb2 <- tv2[tv2$id == "C3-CB2", ]; e3 <- tv2[tv2$id == "C3-E3", ]
d3s <- tv2[tv2$id == "C2-D3", ]; stopifnot(nrow(d3s) == 1L)
o1 <- tv2[tv2$id == "C3-O1", ]; o2 <- tv2[tv2$id == "C3-O2", ]; o3 <- tv2[tv2$id == "C3-O3", ]
pex <- tv2[grepl("^C4-EX", tv2$id), ]; pex_p <- as.numeric(gsub(",", ".", sub("^.*p = ([0-9,]+)\\).*$", "\\1", pex$nota)))
p90hit <- sum(abs(p1090$busca_p10_p90 - p1090$p90) < 1e-9); p10hit <- sum(abs(p1090$busca_p10_p90 - p1090$p10) < 1e-9); icfaixa <- sum(abs(p1090$ic_li - p1090$p10) < 1e-9 & abs(p1090$ic_ls - p1090$p90) < 1e-9)
lr_int <- lr[abs(lr$lag - round(lr$lag)) < 1e-9 & lr$lag %in% 0:7, ]
lag_ex <- function(v, lado) { z <- lr_int[lr_int$valor == v, ]; z[if (lado == "lo") z$rr_ls < 1 else z$rr_li > 1, ] }
lag_txt <- function(z) paste(vapply(seq_len(nrow(z)), function(k) sprintf("%d (%s)", as.integer(z$lag[k]), ci4s(z$rr[k], z$rr_li[k], z$rr_ls[k])), ""), collapse = " and ")
n_lag_ex <- nrow(lag_ex("p1", "lo")) + nrow(lag_ex("p1", "hi")) + nrow(lag_ex("p99", "lo")) + nrow(lag_ex("p99", "hi"))
stopifnot(nrow(lr_int) == 16L, nrow(lag_ex("p1", "lo")) == 1L, nrow(lag_ex("p1", "hi")) == 2L, nrow(lag_ex("p99", "lo")) == 1L, nrow(lag_ex("p99", "hi")) == 1L)
# conferências das afirmações do Results (as do 88 v2)
stopifnot(dentro99 == 6L, dentro01 == 5L, nrow(fora01) == 1L, fora01$chave == 2L, all(c1$fronteira %in% FALSE), all(nov$rr_li <= 1 & nov$rr_ls >= 1), nrow(oa) == 36L, nrow(oa_b) == 7L,
          nrow(med_ex) == 1L, med_ex$id == "C3-O2", med_ex$lado == "x1", rr("p99", "rr_li") <= 1, rr("p99", "rr_ls") >= 1, rr("p1", "rr_li") <= 1, rr("p1", "rr_ls") >= 1)
excl <- oa_nb[(oa_nb$rr99_li > 1) | (oa_nb$rr01_li > 1) | (oa_nb$rr99_ls < 1) | (oa_nb$rr01_ls < 1), ]
stopifnot(setequal(paste(excl$id, ifelse(excl$rr01_li > 1 | excl$rr01_ls < 1, "x1", "x99")), c("C3-CB2 x1", "C3-E3 x1")))
# subtipos: nenhum RR contra a MRT exclui 1; no muito, a MRT está no p99
stopifnot(o1$rr99_li <= 1, o1$rr99_ls >= 1, o1$rr01_li <= 1, o1$rr01_ls >= 1, o3$rr99_li <= 1, o3$rr99_ls >= 1, o3$rr01_li <= 1, o3$rr01_ls >= 1, identical(o2$borda, "x99"), o2$rr01_li <= 1, o2$rr01_ls >= 1)
n_o1 <- as.integer(o1$n_concentracoes); stopifnot(n_o1 == 18L)
n_sens <- sum(tv2$status == "ok" & tv2$id != "P0") + nrow(c1); stopifnot(n_sens == 47L)   # análises rodadas da tabela de sensibilidades (sem o primário, sem a binomial negativa não disparada e sem o corte de 2.000, idêntico) + 6 chaves
x99nov <- nov[nov$percentil == "p99", ]
# IC da TMR: fração de sorteios na borda superior (combinada do primário e uma etapa com 16 coeficientes)
frac_comb <- c(x_inf = tc$prop_sorteios_x_inf, x_sup = tc$prop_sorteios_x_sup); frac_uni <- ic16$prop_bordas
stopifnot(ic16$n == 1000L, isTRUE(all.equal(ic16$ic16, c(uni$ic_tmr_li, uni$ic_tmr_ls), tolerance = 1e-9)), length(frac_uni) == 2L, frac_uni[2] > 0.025, frac_comb[["x_sup"]] > 0.025)
# PACF da D3
pq <- aggregate(cbind(fora_literal, fora_nula) ~ recorte_principal, data = pacf, FUN = any); stopifnot(nrow(pq) == 26L)
n_pacf_lit <- sum(pq$fora_literal); n_pacf_nula <- sum(pq$fora_nula)
# contribuições negativas (principal, forward com BLUP)
negp <- neg[neg$analise == "principal", ]; stopifnot(nrow(negp) == 26L, nrow(it2) == 26L)
neg_dentro <- sum(negp$soma_negativas_dentro_p1_p99); neg_fora <- sum(negp$soma_negativas_fora_p1_p99); n_neg_fora <- sum(negp$soma_negativas_fora_p1_p99 < 0)
stopifnot(n_neg_fora <= n_borda, all(negp$recorte_principal[negp$soma_negativas_fora_p1_p99 < 0] %in% tb$recorte_principal[tb$fronteira]))
ponte <- afp("total", "ponte"); bw <- afp("total", "backward")
fx <- function(k) ph$resumo$descritivas[[k]]
# D12, 4.1: as concentrações fora do subtipo extremo
fora_ext <- setdiff(ordem, readRDS(names(DO_LOG)[9])$O1$incluidas); stopifnot(length(fora_ext) == 26L - n_o1)
Psi_av <- eigen(r45$meta$Psi, symmetric = TRUE, only.values = TRUE)$values; posto_ef <- sum(Psi_av > 1e-8 * max(Psi_av)); stopifnot(posto_ef == 2L)

# ------------------------------------------------------------------ frases prescritas (lidas da spec; substituições listadas no log)
ETICA <- lit("dec08", "This study used publicly available")
e5l <- lit("e5", "Because the reference temperature was the minimum"); stopifnot(grepl(" \\[restante da D5, item 2, sem mudança\\]$", e5l))
d5l <- lit("d5", "Because the reference temperature was the minimum"); resto <- sub("^.*are conditional on the estimated MRT\\. ", "", d5l)
stopifnot(startsWith(resto, "The empirical confidence intervals also treated"))
D5BIAS <- sub(" \\[restante da D5, item 2, sem mudança\\]$", paste0(" ", resto), e5l)
ERR <- lit("e5", "The attributable fraction should not be read")
SUB_ERR <- c("none of the pooled relative risks excluded the null" = "none of the pooled cumulative relative risks of the primary analysis excluded the null",   # chat do A1, correção 4
             "[k] of 1,000 replicates failed and are reported in the Supplementary Methods" = "no replicate failed")                                                 # [k] da errata da D5 (0 falhas)
for (k in names(SUB_ERR)) { stopifnot(grepl(k, ERR, fixed = TRUE)); ERR <- sub(k, SUB_ERR[[k]], ERR, fixed = TRUE) }
# os números embutidos na frase da errata têm de ser os das saídas
stopifnot(grepl(sprintf("Wald χ² = %s, %d df; %s)", f2(ph$p1$W), as.integer(ph$p1$gl), pP(ph$p1$p)), ERR, fixed = TRUE),
          grepl(sprintf("observed attributable fraction (%s%%)", f2(100 * ph$af_obs)), ERR, fixed = TRUE),
          grepl(sprintf("(median, %s%%; 2.5th–97.5th percentiles, %s%%–%s%%;", f2(100 * ph$resumo$af_total[[1]]), f2(100 * ph$resumo$af_total[[2]]), f2(100 * ph$resumo$af_total[[3]])), ERR, fixed = TRUE),
          grepl(sprintf("99th percentile in %d of 26 urban concentrations", n_borda), ERR, fixed = TRUE))
D10G <- lit("d10", "A result was considered robust if")
SEEDS <- lit("comp", "Monte Carlo samples for the empirical")
POSTHOC <- lit("d5", "Post hoc analyses \\(not prespecified\\)")
# D1 (literal do 88 v2, conferido pelo chat), com a troca pedida pelo chat do A1 (Menor de Methods): "on the same day and the following 7 days"
D1 <- "Attributable numbers and fractions were computed with the forward perspective, which assigns to the exposure on each day the events occurring on the same day and the following 7 days, using the BLUP-reduced coefficients of each urban concentration, as in the MCC study.[@Gasparrini2015] The backward perspective, which requires the full first-stage cross-basis coefficients, was computed as a sensitivity analysis.[@GasparriniLeone2014]"
# D8, errata, adaptada ao A1 (literal do 88 v2, conferido pelo chat); vai inteira para o suplemento
D8E <- "When a concentration-specific MRT fell at the 99th percentile, the contrast at that percentile equals 1 by construction (conditional on the estimated MRT, whose bootstrap confidence interval is reported) and is shown without a confidence interval. As prespecified sensitivity analyses, relative risks against the median are also reported, together with the minimum searched between the 10th and 90th percentiles (with its bootstrap confidence interval); the handling of degenerate contrasts and of searches that again fell at a boundary (reported with a flag, without further search) was defined post hoc."
# §8 com o complemento (literal do 88 v2, conferido pelo chat), sem a última frase, trocada pela de disponibilidade do chat (correção 2)
SOFT <- "Analyses were performed in R version 4.5.1 using the packages dlnm (v2.4.10), gnm (v1.1-5), and mixmeta (v1.2.0), with mgcv (v1.9-3) for the penalized model; attributable risk was computed with the attrdl function,[@GasparriniLeone2014] which uses tsModel (v0.6-2), and MASS (v7.3-65) was used in the post hoc simulations; package versions were locked with renv (v1.2.4), and all stochastic procedures used fixed seeds (20261001 for pooled quantities and 20261001 + i for the i-th urban concentration)."

# ------------------------------------------------------------------ Methods (v3)
M <- c("## Methods", "",
"### Study design, setting, and population", "",
sprintf("We conducted a two-stage time-series analysis of daily counts of preterm births in the 26 large urban concentrations defined by the Brazilian Institute of Geography and Statistics, which comprise %d municipalities.[@IBGE2016] The study population comprised singleton live births at 22 0/7 to 42 6/7 weeks of gestation to residents of these concentrations, recorded in the Brazilian Live Birth Information System (SINASC).[@SINASC] Births were restricted to a fixed cohort of pregnancies (estimated start dates from July 31, 2011, to March 5, 2024) to avoid fixed-cohort bias.[@Strand2011] The main analysis window ran from April 14, 2012, to August 6, 2024 (%s days). All 26 concentrations met the prespecified inclusion criteria (Supplementary Methods).", nrow(mun), n_(n_dias)), "",
"The analysis followed a prespecified analysis plan, version-controlled before any outcome analysis (commit [blinded for review], October 9, 2026; archived at [blinded for review]). Deviations were recorded, with their rationale, before the corresponding analyses were run (Supplementary Table S1; full log available with the analysis code). Reporting follows the STROBE and RECORD statements.[@vonElm2007; @Benchimol2015]", "",
ETICA, "",
"### Outcome and exposure", "",
"The outcome was preterm birth (22 to 36 completed weeks); extremely (22–27 weeks), very (28–31 weeks), and moderate-to-late (32–36 weeks) preterm births were secondary outcomes. Daily mean temperature (the average of the maximum and minimum) came from the Brazilian Daily Weather Gridded Data (BR-DWGD, version 3.2.4; 0.1° grid), area-weighted over each municipality.[@Xavier2022] The exposure was the daily mean temperature of the core city of each concentration, assigned to all its municipalities (Supplementary Methods).", "",
"### Statistical analysis", "",
"In the first stage, we fitted, for each concentration, a conditional quasi-Poisson regression with year-by-month strata, which control for seasonality and long-term trends.[@Armstrong2014; @Bhaskaran2013] The offset was the logarithm of the number of ongoing pregnancies at 22 to 36 weeks of gestation; the logarithm of a delivery-risk weight (the mean gestational-week-specific risk of delivery among ongoing pregnancies) entered with an estimated coefficient, to account for the seasonality of conceptions and the gestational-age composition of the population at risk.[@VicedoCabrera2014; @Huang2023] Day of the week, national holidays, carnival, and movable holidays were covariates. Temperature was modeled with a distributed lag nonlinear model:[@Gasparrini2010] a natural cubic spline with knots at the 10th, 75th, and 90th percentiles of daily temperature for the exposure–response function and a natural cubic spline with an intercept and two log-spaced knots over lags of 0 to 7 days for the lag–response function.", "",
"In the second stage, each model was reduced to the overall cumulative (lag 0–7) exposure–response curve,[@Gasparrini2013] and the four reduced coefficients were pooled with a multivariate random-effects meta-regression fitted by restricted maximum likelihood, with the mean and range (99th minus 1st percentile) of daily temperature as meta-predictors.[@Gasparrini2012; @Sera2019] Concentration-specific curves were obtained as best linear unbiased predictions (BLUPs). As in the Multi-Country Multi-City (MCC) Collaborative Research Network study,[@Gasparrini2015] the pooled curve was predicted at the mean of the meta-predictors on a common percentile scale (the average of the concentration-specific percentiles).", "",
"The minimum-risk temperature (MRT) was the minimum of the curve on a 0.1 °C grid between the 1st and 99th percentiles, with a 95% confidence interval (CI) from 1,000 parametric bootstrap samples;[@Tobias2017] concentration-specific MRTs were obtained in the same way from the BLUP curves. The primary contrast was the cumulative relative risk (RR) at the 99th percentile vs the MRT, with the 1st percentile as co-primary contrast; contrasts at the 95th, 90th, 10th, and 5th percentiles were secondary. Contrasts are reported in percentiles and in °C; boundary cases are described in the Supplementary Methods. The estimated between-concentration covariance matrix was singular (effective rank 2 of 4); concentration-specific MRTs at the boundary are therefore not independent evidence, and the Wald test of the pooled curve may be anticonservative.", "",
paste(D1, "Empirical CIs used 1,000 Monte Carlo samples (Supplementary Methods). Components were heat and cold (above and below the MRT) and extreme heat and extreme cold (above the higher of the 97.5th percentile and the MRT, and below the 2.5th percentile); in the 10 concentrations whose MRT fell at the 99th percentile, heat and extreme heat coincide.", D5BIAS), "",
"### Sensitivity analyses", "",
paste("Six prespecified key sensitivity analyses assessed robustness: municipal temperature in a municipal case time series,[@Gasparrini2022] lag 0–14, a natural spline of time instead of strata, adjustment for fine particulate matter (PM2.5, lag 0–1), a fixed coefficient of 1 for the delivery-risk weight, and spontaneous preterm birth.", D10G,
      "Other prespecified and exploratory analyses are described in the Supplementary Methods and Supplementary Table S2."), "",
"### Software and data availability", "",
"Analyses were performed in R, version 4.5.1,[@RCore] with the dlnm, gnm, and mixmeta packages.[@Gasparrini2011; @gnm; @Sera2019] SINASC and SIM microdata are publicly available from DATASUS,[@SINASC; @SIM] and BR-DWGD, CAMS, and human development index data from their public repositories.[@BRDWGD; @CAMS_EAC4; @AtlasDH] Analysis code, the deviation log, and the analysis plan are available for review at [anonymous review link].", "")

# ------------------------------------------------------------------ Results (v3)
lo1 <- lag_ex("p1", "lo"); hi1 <- lag_ex("p1", "hi"); lo99 <- lag_ex("p99", "lo"); hi99 <- lag_ex("p99", "hi")
R <- c("## Results", "",
sprintf("The analysis included %s singleton live births and %s preterm births (%s%%) in the 26 urban concentrations over %s days (Table 1; Supplementary Figure S1).",
        n_(n_nv), n_(n_ptb), f1(100 * n_ptb / n_nv), n_(n_dias)), "",
sprintf("The pooled cumulative exposure–response curve was close to flat (Figure 1). The pooled MRT was %s °C (%sth percentile of the pooled axis; 95%% CI, %s–%s °C, the entire search range). Compared with the MRT, the RR was %s at the 99th percentile (%s °C) and %s at the 1st percentile (%s °C) (Table 2). Secondary contrasts ranged from %s to %s (Supplementary Table S3), and none of the pooled cumulative relative risks of the primary analysis excluded the null.",
        f1(tc$tmr), f1(100 * tc$percentil_tmr), f1(tc$ic_li), f1(tc$ic_ls), ci3(rr("p99", "rr"), rr("p99", "rr_li"), rr("p99", "rr_ls")), f1(rr("p99", "temperatura")),
        ci3(rr("p1", "rr"), rr("p1", "rr_li"), rr("p1", "rr_ls")), f1(rr("p1", "temperatura")), f3(min(ct$rr[ct$percentil %in% c("p95", "p90", "p10", "p5")])), f3(max(ct$rr[ct$percentil %in% c("p95", "p90", "p10", "p5")]))), "",
sprintf("Residual heterogeneity was low (Cochran Q = %s, %d df; %s; I² = %s%%), and neither meta-predictor was associated with the curve (Wald %s for the mean and %s for the range). Concentration-specific MRTs ranged from %s to %s °C and fell at the 99th percentile in %d of 26 concentrations (Figure 3, Supplementary Table S4); in these %d, the minimum searched between the 10th and 90th percentiles fell at a boundary in %d, and its 95%% CI spanned the entire search range in %d.",
        f1(h$Q), as.integer(h$df), pP(h$p), f1(h$I2), pP(w$p[w$termo == "media"]), pP(w$p[w$termo == "amplitude"]), f1(min(tb$tmr)), f1(max(tb$tmr)), n_borda, n_borda, p90hit + p10hit, icfaixa), "",
sprintf("Lag-specific estimates are descriptive, without adjustment for multiple comparisons (16 lag-specific estimates) (Figure 2). At the 1st percentile, the RR was below 1 at lag %s and above 1 at lags %s; at the 99th percentile, it was below 1 at lag %s and above 1 at lag %s. The 95%% CIs of the other %d estimates included 1.",
        lag_txt(lo1), lag_txt(hi1), lag_txt(lo99), lag_txt(hi99), 16L - n_lag_ex), "",
sprintf("If the associations were causal, %s preterm births (empirical 95%% CI, %s–%s), or %s%% (%s%%–%s%%), would be attributable to nonoptimal temperature (forward perspective; %s%% to heat and %s%% to cold; backward perspective in Table 2). In post hoc analyses, a Wald test did not reject a flat pooled curve (χ² = %s, %d df; %s), and the observed attributable fraction did not exceed the 97.5th percentile of its distribution under no association in any urban concentration (median, %s%%; 2.5th–97.5th percentiles, %s%%–%s%%; Supplementary Table S5).",
        n_(round(an_t$an)), n_(round(an_t$an_li)), n_(round(an_t$an_ls)), f2(100 * an_t$af), f2(100 * an_t$af_li), f2(100 * an_t$af_ls), f2(100 * afp("calor")$af), f2(100 * afp("frio")$af),
        f2(ph$p1$W), as.integer(ph$p1$gl), pP(ph$p1$p), f2(100 * ph$resumo$af_total[[1]]), f2(100 * ph$resumo$af_total[[2]]), f2(100 * ph$resumo$af_total[[3]])), "",
sprintf("In the key sensitivity analyses (Table 3, Figure 4), the 99th percentile contrast fell within the primary 95%% CI in %d of 6 analyses and the 1st percentile contrast in %d of 6; the exception was lag 0–14 (RR at the 1st percentile, %s).",
        dentro99, dentro01, ci3s(fora01$rr01, fora01$rr01_li, fora01$rr01_ls)), "",
sprintf("In the warm season (November–March), the RR at the 99th percentile of the warm-season axis was %s, and no warm-season contrast excluded 1. For the preterm subtypes, no RR against the MRT excluded 1; for very preterm birth, whose pooled MRT fell at the 99th percentile, the RR at the 1st percentile against the median was %s. Among the other %d sensitivity analyses with an interior pooled MRT, the CI excluded 1 only at the 1st percentile with lag 0–21 (%s) and with minimum temperature as the exposure (%s).",
        ci3(x99nov$rr, x99nov$rr_li, x99nov$rr_ls), ci3(med_ex$rr, med_ex$li, med_ex$ls), nrow(oa_nb), ci3s(cb2$rr01, cb2$rr01_li, cb2$rr01_ls), ci3s(e3$rr01, e3$rr01_li, e3$rr01_ls)), "")

R <- R[c(1:6, 9:10, 7:8, 11:length(R))]; stopifnot(grepl("^Lag-specific", R[7]), grepl("^Residual heterogeneity", R[9]))   # ordem de citação das figuras (2 antes de 3)

# ------------------------------------------------------------------ Supplementary Methods (com as frases prescritas movidas inteiras)
nm_ext <- unname(nome[fora_ext]); sem_uf <- !grepl("/", nm_ext); nm_ext[sem_uf] <- paste0(nm_ext[sem_uf], "/", mun$SIGLA_UF[match(fora_ext[sem_uf], mun$CD_RECORTE)]); stopifnot(all(grepl("/[A-Z]{2}$", nm_ext)))
S <- c("# Supplementary Material", "",
"## Supplementary Methods", "",
"Abbreviations: BLUP, best linear unbiased prediction; CI, confidence interval; MCC, Multi-Country Multi-City Collaborative Research Network; MRT, minimum-risk temperature; RR, relative risk; SINASC, Brazilian Live Birth Information System.", "",
"The analysis plan was version-controlled before any outcome analysis. Decisions taken after the analysis plan was version-controlled, with their labels and whether they used any result of this study, are listed in Supplementary Table S1.", "",
"### Study population and inclusion criteria", "",
"The 26 urban concentrations are the large urban concentrations defined by the Brazilian Institute of Geography and Statistics (2nd edition, based on the 2010 Census).[@IBGE2016] The core city of each concentration was its most populous municipality in the 2022 Census (in the Vitória concentration, Serra). The main analysis window (April 14, 2012, to August 6, 2024) is the period in which every gestational week from 22 to 36 had a complete set of ongoing pregnancies in the fixed cohort; the first 7 days before the window served as lag warm-up and were not part of the fitted data.",
"Concentrations were included if they had complete exposure data, valid gestational age and birth weight in at least 90% of live births, at least 1,000 events, and model convergence; a prespecified fallback specification for nonconvergence was defined. All 26 concentrations met the criteria in the primary analysis, and the fallback was not needed. The selection of the analytic population is shown in Supplementary Figure S1, and missing or unknown values of the variables in Table 1 and of those used in the inclusion criteria and sensitivity analyses are shown in Supplementary Table S6. Strata without events were removed from the fitted data, dispersion was estimated by the Pearson statistic, and the movable holidays were Ash Wednesday, Good Friday, and Corpus Christi.",
sprintf("Dispersion ranged from %s to %s across concentrations, and the estimated coefficient of the logarithm of the delivery-risk weight ranged from %s to %s; this coefficient is reported as a diagnostic only. Delivery-risk weights computed per person-day would differ from the primary weights by a factor of 1.00017 (week 22) to 1.0187 (week 36); with an estimated coefficient, this difference is absorbed. The early-term comparison used person-day weights.", f2(min(phi)), f2(max(phi)), f2(min(gama)), f2(max(gama))), "",
"### Outcome definitions", "",
sprintf("Preterm subtypes used an offset restricted to the gestational weeks of the subtype, with the delivery-risk weights of the primary analysis; a concentration with fewer than 1,000 events of a subtype was excluded from the meta-analysis of that subtype. For extremely preterm birth, %d concentrations were included; the %d excluded were %s. With fewer concentrations, the extremely preterm curve may cover a different set of climates, and the meta-predictors, although the same, are evaluated at the mean of the included concentrations.",
        n_o1, length(fora_ext), lista(nm_ext)),
"Spontaneous preterm birth was defined from the SINASC fields on labor induction, mode of delivery, and the timing of cesarean delivery: preterm birth without induction of labor and with either vaginal delivery or cesarean delivery after the onset of labor. In version (i), a key sensitivity analysis, births with unknown onset were excluded from the numerator; in version (ii), they were counted as spontaneous.",
"One outcome sensitivity analysis was restricted to births with gestational age dated by the last menstrual period, with the outcome defined from the SINASC gestational-age field (version i) and from the last menstrual period (version ii), each with its own fixed cohort, offset, and delivery-risk weights. This subpopulation has a higher prevalence of preterm birth and unequal coverage across concentrations and years. Its concordance criterion (a difference of at most 1 week between the two gestational-age measures) excluded almost no births; the actual restriction is having a recorded last menstrual period. Validation studies of SINASC found that gestational age had the lowest agreement among the variables tested in a national linkage with the Birth in Brazil survey, with a kappa of 0.461,[@Szwarcwald2019] and regular agreement with a field study in four public maternity hospitals in São Paulo, with a kappa of 0.56.[@Bonilha2018]",
"In one sensitivity analysis, fetal deaths from the Mortality Information System (SIM)[@SIM] were added to the number of ongoing pregnancies. By construction, this analysis nearly reproduces the primary analysis: adding fetal deaths changes the logarithm of the offset by about 0.005, with very small within-month variation.", "",
"### Codes, algorithms, and data cleaning", "",
"Live births were selected from the SINASC files by single pregnancy (GRAVIDEZ = 1), municipality of residence (CODMUNRES) among the 277 municipalities of the urban concentrations, date of birth (DTNASC), and gestational age in completed weeks (SEMAGESTAC, 22 to 42; values outside 22 to 44 were set to missing). The pregnancy start date was DTNASC minus (7 × SEMAGESTAC + 3) days, and the fixed cohort comprised start dates from July 31, 2011, to March 5, 2024. Preterm birth was SEMAGESTAC 22 to 36 (subtypes 22–27, 28–31, and 32–36). Birth weight (PESO) was valid from 200 to 7,000 g. Spontaneous preterm birth was STTRABPART = 2 (labor not induced) with PARTO = 1 (vaginal delivery) or with PARTO = 2 (cesarean delivery) and STCESPARTO = 2 (cesarean delivery after the onset of labor). Gestational age by the last menstrual period was the number of completed weeks between DTULTMENST and DTNASC. The 2011 arm used the categorical field GESTACAO (codes 2 to 6 for 22 to 42 weeks and 2 to 4 for 22 to 36 weeks).",
"Fetal deaths for the sensitivity analysis were selected from the SIM fetal-death files (TIPOBITO = 1) by single pregnancy, municipality of residence (CODMUNRES), and SEMAGESTAC from 22 to 42 weeks. SINASC and SIM were not linked at the individual level; each was aggregated separately into daily counts by municipality of residence. The complete public national files for 2011 to 2024 were downloaded from DATASUS, and all records were available to the investigators.", "",
"### Exposure, air pollution, and local holidays", "",
"Fine particulate matter (PM2.5) came from the Copernicus Atmosphere Monitoring Service global reanalysis (EAC4),[@Inness2019; @CAMS_EAC4] as the daily mean of the core city on the approximate local day (UTC−3), entered linearly as the lag 0–1 moving average. Its role as a confounder of temperature effects is debated,[@Buckley2014] and adjustment may remove part of the effect if temperature influences PM2.5. The 0.75° grid (about 80 km) has not been validated against monitoring stations in all concentrations, and a small proportion of values are exact zeros of unverified origin; a time-constant bias does not affect a within-series adjustment, but a time-varying bias does. The adjusted result is read as a robustness check, not as a correction.",
"Local holidays were compiled from the municipal, state, and district legislation applicable to the core municipality of each concentration only; pregnant individuals residing in other municipalities of a concentration may have had a different calendar.", "",
"### Second stage and boundary contrasts", "",
paste("Pooled lag–response curves at the 99th and 1st percentiles against the pooled MRT were obtained from a second multivariate meta-analysis of the corresponding lag-specific coefficients. Cochran Q, I², and Wald tests for the meta-predictors were computed from the meta-regression.", D8E),
sprintf("The estimated between-concentration covariance matrix had eigenvalues %s; its effective rank was 2 of 4. The BLUPs are therefore constrained to a family of curves with few free parameters, concentration-specific MRTs at the boundary are not independent, and the Wald test of the pooled curve may be anticonservative.",
        lista(sci(Psi_av, 1))), "",
"### Attributable fraction", "",
paste(SEEDS, "Because the forward perspective averages the events of the following 7 days, the last 7 days of the analysis window were excluded from the forward computation, which was rescaled to the observed total; the backward perspective does not lose these days."),
sprintf("Negative daily contributions. In the primary analysis (forward perspective, BLUP-reduced coefficients), negative daily contributions within the 1st–99th percentile range summed to %s events across the 26 urban concentrations (%s preterm births), consistent with the 0.1 °C resolution of the MRT search grid; the smallest difference between the curve on observed days within that range and the grid minimum was %s on the log scale. Negative contributions outside that range summed to %s events, all in the %d concentrations whose MRT was at the 99th percentile.",
        mn(formatC(neg_dentro, format = "f", digits = 3)), n_(sum(negp$denominador)), sci(min(it2$min_delta), 3), mn(f1(neg_fora)), n_neg_fora),
sprintf("Bridge analysis. To separate the effect of shrinkage from that of the perspective, the forward attributable fraction was also computed with first-stage coefficients: %s%% (empirical 95%% CI, %s%%–%s%%), compared with %s%% with BLUP-reduced coefficients (forward) and %s%% with the backward perspective. The first stage has no shrinkage, the backward perspective produces negative daily contributions, and the empirical CIs treat concentrations as independent.",
        f2(100 * ponte$af), f2(100 * ponte$af_li), f2(100 * ponte$af_ls), f2(100 * an_t$af), f2(100 * bw$af)), "",
"### Post hoc analyses", "",
POSTHOC,
sprintf("The distributions under no association are shown in Supplementary Table S5. The observed heat and cold attributable fractions were %s%% and %s%% (medians under no association, %s%% and %s%%); the observed RRs at the 99th and 1st percentiles were %s and %s (medians, %s and %s); and the MRT fell at the 99th percentile in %d concentrations (median, %d) and at the 1st percentile in %d (median, %d).",
        f2(100 * ph$obs_desc[["af_calor"]]), f2(100 * ph$obs_desc[["af_frio"]]), f2(100 * fx("mediana")[1]), f2(100 * fx("mediana")[2]), f3(ph$obs_desc[["rr_x99"]]), f3(ph$obs_desc[["rr_x1"]]), f3(fx("mediana")[3]), f3(fx("mediana")[4]),
        as.integer(ph$obs_desc[["n_mrt_p99"]]), as.integer(fx("mediana")[5]), as.integer(ph$obs_desc[["n_mrt_p1"]]), as.integer(fx("mediana")[6])), "",
"### Other sensitivity analyses", "",
"The remaining prespecified sensitivity analyses (closed list) addressed residual autocorrelation, the exposure metric, the cross-basis (including a penalized distributed lag model), time trend and calendar (including local holidays), the risk set and offset, the outcome definition, and the pooling model (fixed-effects, multilevel, and one-stage models); exploratory meta-regressions added one concentration characteristic at a time (macroregion, cesarean delivery, prenatal care, and the municipal human development index). All are listed in Supplementary Table S2.",
"Because the primary 95% CIs included 1 for both contrasts, the robustness criterion was of limited informativeness: it could detect a sensitivity estimate larger than the upper limit of the primary CI, but it could not distinguish robustness from a null result; evidence of an association was assessed with the post hoc test of the pooled curve.",
"The natural spline of time had 8 degrees of freedom per year of data (99 in total); the code of the MCC study assigns degrees of freedom per calendar year, which would give full-year degrees of freedom to the two partial years (2012 and 2024).",
sprintf("Residual autocorrelation. In the partial autocorrelation function of the deviance residuals of the primary models (lags 1–7), at least one lag fell outside ±2/√n in %d of 26 concentrations and outside the 2.5th–97.5th percentiles of a simulated null distribution that accounts for the projection of the residuals on the fitted model (weighted least squares) in %d of 26; this description was not used for any decision. With lagged deviance residuals (lags 1–7) added to the models, the RR was %s at the 99th percentile and %s at the 1st percentile.", n_pacf_lit, n_pacf_nula, ci3(d3s$rr99, d3s$rr99_li, d3s$rr99_ls), ci3(d3s$rr01, d3s$rr01_li, d3s$rr01_ls)),
sprintf("One-stage model. The one-stage model stacks the 26 series in a single conditional quasi-Poisson model with a common cross-basis on the concentration-specific percentile scale (lags not crossing concentrations), one coefficient of the delivery-risk weight per concentration, and a common dispersion; its curve is an average curve, without meta-predictors and without between-concentration heterogeneity, and it is therefore not the same quantity as the pooled curve of the primary analysis. Its MRT was %s °C (95%% CI, %s–%s °C). The upper limit of this CI is sensitive to Monte Carlo error: %s%% of the 1,000 bootstrap samples fell at the 99th percentile (%s%% at the 1st), just above the 2.5%% that defines the limit, whereas %s%% did so for the pooled MRT of the primary analysis (%s%% at the 1st percentile). Drawing the 16 cross-basis coefficients or the 4 reduced coefficients gives the same theoretical distribution, because the reduction is linear; the two intervals differ only by Monte Carlo error.",
        f1(uni$tmr_c), f1(uni$ic_tmr_li), f1(uni$ic_tmr_ls), f1(100 * frac_uni[2]), f1(100 * frac_uni[1]), f1(100 * frac_comb[["x_sup"]]), f1(100 * frac_comb[["x_inf"]])),
"Penalized model. The penalized distributed lag model (cubic P-splines in both dimensions with second-order difference penalties, fitted by extended quasi-likelihood with restricted maximum likelihood) has no pooled curve or MRT of its own: concentration-specific log RRs at the 99th and 1st percentiles were contrasted against the temperature corresponding to the percentile of the pooled MRT of the primary analysis and pooled by univariate meta-regression. It therefore estimates a different quantity from the primary analysis, can fall below 1, and was not a key sensitivity analysis.[@Gasparrini2017; @Wood2011]",
sprintf("Exploratory meta-regressions added one characteristic at a time to the mean and range of temperature; no exploratory meta-predictor was associated with the curve (P = %s to %s). The municipal human development index was the population-weighted mean of the 2010 municipal values;[@AtlasDH] because the index is a geometric mean of three indexes, this average is an approximation, and it predates the study period.", pv(min(pex_p)), pv(max(pex_p))), "",
"### Software", "",
paste(SOFT, "The gnm package was used for the conditional models.[@gnm]"), "")

# ------------------------------------------------------------------ Abstract (sem abreviações; percentuais com n/N; P quando há alegação)
mi <- function(x) paste(formatC(x / 1e6, format = "f", digits = 1), "million")
A <- c("## Abstract", "",
"Background: High and low ambient temperatures have been associated with preterm birth, but estimates vary, and temporal studies can be biased by the seasonality of conceptions and by changes in the number of pregnancies at risk.", "",
"Objective: To estimate the short-term association between daily mean ambient temperature and preterm birth in the 26 large urban concentrations of Brazil.", "",
sprintf("Study Design: This two-stage time-series study included singleton live births at 22 to 42 weeks of gestation to residents of 26 urban concentrations, recorded in the national live birth information system from April 2012 to August 2024. In each concentration, daily counts of preterm births (22 to 36 weeks) were modeled with conditional quasi-Poisson regression, with ongoing pregnancies at 22 to 36 weeks as the offset, a delivery-risk weight, and a distributed lag nonlinear function of core-city daily mean temperature over 0 to 7 days. Concentration-specific estimates were pooled by multivariate meta-regression. The primary contrasts were the cumulative relative risks at the 99th and 1st temperature percentiles compared with the minimum-risk temperature. The analysis plan was version-controlled before any outcome analysis."), "",
sprintf("Results: Of %s live births, %s (%s%%) were preterm. The pooled exposure–response curve was close to flat, and the minimum-risk temperature was imprecisely estimated (%s °C; 95%% confidence interval, %s to %s °C, the entire search range). The cumulative relative risk was %s at the 99th percentile (%s °C) and %s at the 1st percentile (%s °C); none of the pooled cumulative relative risks of the primary analysis excluded 1, and a post hoc test did not reject a flat curve (%s). The 99th percentile contrast fell within the primary confidence interval in %d of 6 key sensitivity analyses, and the 1st percentile contrast in %d of 6. If the associations were causal, %s of %s preterm births (%s%%; empirical 95%% confidence interval, %s%% to %s%%) would be attributable to nonoptimal temperatures, but this fraction did not exceed the 97.5th percentile of its distribution under no association (median, %s%%; 97.5th percentile, %s%%).",
        n_(n_nv), n_(n_ptb), f1(100 * n_ptb / n_nv), f1(tc$tmr), f1(tc$ic_li), f1(tc$ic_ls), abs3(rr("p99", "rr"), rr("p99", "rr_li"), rr("p99", "rr_ls")), f1(rr("p99", "temperatura")),
        sprintf("%s (%s to %s)", f3(rr("p1", "rr")), f3(rr("p1", "rr_li")), f3(rr("p1", "rr_ls"))), f1(rr("p1", "temperatura")), pP(ph$p1$p), dentro99, dentro01, n_(round(an_t$an)), n_(n_ptb), f2(100 * an_t$af), f2(100 * an_t$af_li), f2(100 * an_t$af_ls), f2(100 * ph$resumo$af_total[[1]]), f2(100 * ph$resumo$af_total[[3]])), "",
sprintf("Conclusion: In 26 Brazilian urban concentrations, short-term exposure to heat and cold was not clearly associated with preterm birth; the data were compatible with cumulative relative risks of up to %s at the 99th temperature percentile and up to %s at the 1st percentile (upper 95%% confidence limits), and a delayed association with cold could not be excluded.", f3(rr("p99", "rr_ls")), f3(rr("p1", "rr_ls"))), "")

# ------------------------------------------------------------------ front matter
TIT <- "Short-term ambient temperature exposure and preterm birth in 26 Brazilian urban concentrations"
COND <- sprintf("In %s births in 26 Brazilian urban concentrations, short-term heat and cold showed no clear association with preterm birth.", mi(n_nv))
STIT <- "Ambient temperature and preterm birth in Brazilian urban concentrations"
GL <- c("### A. Why was this study conducted?", "",
"- To estimate the short-term association between daily ambient temperature and preterm birth in large Brazilian cities, accounting for the pregnancies at risk.", "",
"### B. What are the key findings?", "",
sprintf("- Among %s preterm births, the pooled cumulative relative risk vs the minimum-risk temperature was %s at the 99th and %s at the 1st temperature percentile.",
        n_(n_ptb), abs3(rr("p99", "rr"), rr("p99", "rr_li"), rr("p99", "rr_ls")), sprintf("%s (%s to %s)", f3(rr("p1", "rr")), f3(rr("p1", "rr_li")), f3(rr("p1", "rr_ls")))),
sprintf("- A post hoc test did not reject a flat exposure–response curve (%s).", pP(ph$p1$p)), "",
"### C. What does this study add to what is already known?", "",
sprintf("- In large Brazilian cities, short-term heat and cold were not clearly associated with preterm birth; the data were compatible with cumulative relative risks of up to %s at the 99th and %s at the 1st percentile.", f3(rr("p99", "rr_ls")), f3(rr("p1", "rr_ls"))), "")
KW <- c("attributable fraction", "cold", "distributed lag nonlinear model", "environmental epidemiology", "heat", "multivariate meta-analysis", "time-series analysis")
COI_CEGO <- "The authors report no conflict of interest. [to be confirmed by the authors]"

# ------------------------------------------------------------------ Introduction (sem dados nem conclusões; literatura conferida nos abstracts, referencias_m4.csv)
I <- c("## Introduction", "",
"Preterm birth affected an estimated 13.4 million live births worldwide in 2020, 9.9% of all births.[@Ohuma2023] In a national population-based study in Brazil, 11.5% of births were preterm.[@Leal2016]", "",
"In a systematic review and meta-analysis that included 70 studies, the odds of preterm birth increased by 5% per 1 °C of temperature and by 16% during heat waves,[@Chersich2020] and other systematic reviews have reported associations with heat.[@Bekkar2020; @Wang2026] Proposed mechanisms include dehydration, reduced placental blood flow, and an inflammatory response, although the evidence is limited.[@Samuels2022] A multicountry study attributed 1.4% of warm-season preterm births to heat across 250 locations in 13 countries.[@Iniguez2026] Two-stage designs with distributed lag nonlinear models, developed for temperature and mortality, allow nonlinear and delayed associations to be estimated and pooled across many locations.[@Gasparrini2010; @Gasparrini2015]", "",
"Temporal studies of preterm birth face specific threats to validity. Conceptions are seasonal, and the number and gestational-age composition of ongoing pregnancies change over time; analyses that ignore the population at risk, or whose study period truncates pregnancies at its start and end, can produce spurious seasonal patterns.[@Darrow2009; @Strand2011] In simulations, time-series analyses were unbiased when they accounted for the ongoing pregnancies at risk and their weighted probability of delivery,[@Huang2023] and, in another simulation, misspecified adjustment for seasonality introduced severe bias.[@Girgin2026] Large studies in the United States found increases of about 1% to 2% in preterm birth after heat waves.[@Darrow2024; @Fitch2025]", "",
"Brazil's large urban concentrations range from equatorial to subtropical climates. Brazilian evidence on climate and preterm birth includes a review reporting more preterm births during heat waves in record-breaking droughts in southeastern Brazil,[@Libonati2022] a nationwide cohort in which drought was associated with preterm birth,[@Rocha2026] a nationwide preprint that used daily live births as the offset and found U-shaped curves in cold and moderate regions and higher risk at lag 0 in warm regions,[@Couto2026] and an ongoing study of heat and birth outcomes.[@RibeiroSilva2025] The multicountry study analyzed the warm season only.[@Iniguez2026] We estimated the short-term association between daily mean temperature, over its whole range, and preterm birth in the 26 large urban concentrations of Brazil, using the national live birth registry, a design that accounts for the seasonality of conceptions and the pregnancies at risk, and a prespecified analysis plan.", "")

# ------------------------------------------------------------------ Comment
C <- c("## Comment", "",
"### Principal Findings", "",
sprintf("In this time-series study of %s preterm births in 26 Brazilian urban concentrations, short-term exposure to heat and cold was not clearly associated with preterm birth. The pooled exposure–response curve was close to flat, the RRs at the 99th and 1st percentiles had 95%% CIs that included 1, a post hoc test did not reject a flat curve, and the pooled MRT could not be located with precision. This null result was consistent across the key sensitivity analyses, except for a larger RR at the 1st percentile with a lag of 0 to 14 days.", n_(n_ptb)), "",
"### Results in the Context of What Is Known", "",
sprintf("Our estimates do not exclude associations of the size reported after heat waves in large US studies, about 1%% to 2%%:[@Darrow2024; @Fitch2025] the upper 95%% confidence limits were %s at the 99th percentile and %s at the 99th percentile of the warm season. Meta-analyses, which combine heterogeneous designs and exposure definitions, have reported larger associations with heat,[@Chersich2020; @Wang2026] and a multicountry analysis attributed 1.4%% of warm-season preterm births to heat.[@Iniguez2026] Differences in the exposure contrast and setting may contribute to these differences: the US studies compared heat-wave days, defined by local thresholds in the warm season, with other days, whereas we contrasted extreme percentiles of the whole-year distribution with an estimated MRT, in tropical and subtropical climates, with core-city temperature as the exposure. As in the US time-series study,[@Darrow2024] we accounted for the ongoing pregnancies at risk, here with their weighted probability of delivery.[@Huang2023] The larger RRs at the 1st percentile with lags of 0 to 14 and 0 to 21 days and with minimum temperature as the exposure, together with lag-specific RRs above 1 at lags 6 and 7, are compatible with a delayed association with cold, which was not a prespecified hypothesis.",
        f3(rr("p99", "rr_ls")), f3(x99nov$rr_ls)), "",
"### Clinical Implications", "",
"At the population level, these data do not provide evidence that short-term ambient temperature is an important trigger of preterm birth in large Brazilian cities and, on their own, do not justify temperature-based changes in obstetric care. Protection of pregnant individuals from extreme heat may still be warranted for other outcomes, such as stillbirth.[@Chersich2020]", "",
"### Research Implications", "",
"Studies of temperature and preterm birth should account for the pregnancies at risk and the seasonality of conceptions, report the full exposure–response curve with a test against a flat curve, and interpret attributable fractions against their distribution under no association, because fractions computed against an estimated minimum are biased upward. Prespecified analyses of delayed cold effects, heat waves, humidity, preterm birth by onset, and individual-level exposure could show whether small or subgroup-specific associations exist.", "",
"### Strengths and Limitations", "",
sprintf("Strengths include a national registry of %s births across equatorial to subtropical climates, a design that accounts for the pregnancies at risk and fixed-cohort bias, and a prespecified analysis plan with a closed list of sensitivity analyses.", mi(n_nv)), "",
ERR, "",
sprintf("The estimated between-concentration covariance matrix was singular (effective rank 2 of 4), so the BLUPs are constrained to a low-dimensional family of curves, concentration-specific MRTs at the boundary are not independent, and the Wald test may be anticonservative. The backward perspective uses first-stage coefficients without shrinkage, which are unstable in smaller concentrations (it is read for the total only), and produces negative daily contributions (Supplementary Methods). The pooled curve uses a common percentile scale, and in the equatorial concentrations (Manaus, Belém, and Fortaleza) the 1st percentile is not cold in absolute terms. Gestational age in SINASC differs from completed weeks by the last menstrual period in about 21%% of records with that date (by 1 week), which may misclassify births near 37 weeks[@Szwarcwald2019; @Bonilha2018]; the pattern suggests a calculation convention, which would be nondifferential with respect to daily temperature, but the mechanism is undetermined. Exposure was outdoor core-city (or municipal) temperature assigned by residence at birth, without individual, indoor, or mobility data; this misclassification would mainly reduce precision and tend to attenuate associations. With %d sensitivity and exploratory analyses and 16 lag-specific estimates, the few CIs that excluded 1 should be read in light of multiple comparisons. The results apply to live births in large urban areas and may not apply to non-urban populations, and local holidays were available only for the core municipality. PM2.5 came from a coarse reanalysis, so the adjusted analysis is a robustness check, not a correction. The analysis adding fetal deaths to the pregnancies at risk nearly reproduces the primary analysis by construction, the human development index is an approximation from 2010, the penalized and one-stage models estimate different quantities, and the upper CI limit of the one-stage MRT is sensitive to Monte Carlo error (Supplementary Methods).", n_sens), "",
"### Conclusions", "",
"In 26 Brazilian urban concentrations, short-term exposure to heat and cold was not clearly associated with preterm birth. Burdens attributed to temperature against the minimum of an estimated curve should be interpreted against their distribution under no association.", "")

# ------------------------------------------------------------------ Glossary, declaração de IA, legendas, highlights, página de título
G <- c("## Glossary", "",
"- Cross-basis: the two-dimensional set of basis functions that describes, at the same time, the shape of the exposure–response relationship and its distribution over lags in a distributed lag nonlinear model.",
"- Cumulative relative risk: the relative risk associated with a given temperature, compared with the reference temperature, accumulated over all lags considered (here, 0 to 7 days), that is, the product of the lag-specific relative risks.",
"- Distributed lag nonlinear model: a regression framework that models nonlinear exposure–response relationships and delayed effects jointly.",
"- Lag: the delay, in days, between the exposure and the outcome.",
"- Minimum-risk temperature: the temperature at which the estimated exposure–response curve reaches its minimum, used as the reference for relative risks and attributable fractions.", "")
IA <- c("## Declaration of generative AI and AI-assisted technologies in the writing process", "",
"During the preparation of this work, the authors used Claude (Anthropic) to write and review analysis code and to draft and edit the text of the manuscript. After using this tool, the authors reviewed and edited the content as needed and take full responsibility for the content of the publication.", "")
LEG <- c("# Figure legends", "",
"Figure 1. Pooled cumulative (lag 0–7) exposure–response curve between daily mean temperature and preterm birth in 26 Brazilian urban concentrations, 2012–2024. The curve was predicted at the mean of the meta-predictors on the pooled percentile axis (1st to 99th percentiles); the shaded band is the 95% confidence interval, and the dashed line marks the pooled minimum-risk temperature. MRT, minimum-risk temperature.", "",
"Figure 2. Pooled lag–response curves at the 99th (left) and 1st (right) percentiles of the pooled temperature axis against the pooled minimum-risk temperature, with 95% confidence intervals. MRT, minimum-risk temperature.", "",
"Figure 3. Concentration-specific cumulative (lag 0–7) exposure–response curves (best linear unbiased predictions), each on the 1st–99th percentile range of its own temperature distribution, against the concentration-specific minimum-risk temperature (dashed line and dot); shaded bands are 95% confidence intervals, truncated at 0.75 and 1.35 on the vertical axis. BLUP, best linear unbiased prediction; MRT, minimum-risk temperature.", "",
"Figure 4. Relative risks at the 99th (heat) and 1st (cold) percentiles against the pooled minimum-risk temperature in the primary analysis and in the sensitivity analyses. The filled circle is the primary analysis; open diamonds mark analyses in which the pooled minimum-risk temperature fell at the grid boundary on that side (contrast fixed at 1); the dotted line marks the primary estimate. Exposure-metric and warm-season analyses are on their own temperature axes; the penalized model is contrasted with a concentration-specific reference. CI, confidence interval; df, degrees of freedom; DLNM, distributed lag nonlinear model; GA, gestational age; LMP, last menstrual period; MRT, minimum-risk temperature; ns, natural spline; PM2.5, fine particulate matter; SINASC, Brazilian Live Birth Information System; γ, coefficient of the logarithm of the delivery-risk weight; (i) and (ii), versions of the outcome definition (Supplementary Methods).", "")
HL <- c("Daily temperature and preterm birth were studied in 26 Brazilian urban areas",
        "No clear short-term association was found for heat or cold",
        "A post hoc test did not reject a flat exposure-response curve",
        "Attributable fractions against an estimated minimum are biased upward")

# ------------------------------------------------------------------ Tabela S5 (decisões depois do primário; mensagem do chat de 20/10, item 7; textos conferidos nos documentos de spec)
S5T <- data.frame(check.names = FALSE,
  Decision = c("D1 (October 13, 2026)", "D2 (October 13, 2026)", "D3 (October 13, 2026)", "Complement (October 13, 2026)", "D5 and erratum (October 13 and 14, 2026)",
               "D6, items 1.5, 2, and 3 (October 13, 2026)", "D7, item M7 (October 13, 2026)", "D8, item 1, and erratum (October 14, 2026)", "D10 (October 15, 2026)", "D11 (October 15, 2026)",
               "D12 (October 15, 2026)", "D13, item 3 (October 15, 2026)", "D15 (October 16, 2026)", "D16 (October 16, 2026)", "D17 (October 19, 2026)"),
  `What was decided` = c(
    "Attributable fraction: forward perspective with BLUP-reduced coefficients as primary (the plan specified the backward perspective, which cannot use reduced coefficients); backward perspective with first-stage coefficients as sensitivity analysis; forward computation without shrinkage as a bridge",
    "Prediction basis of the pooled curve: knots and boundary knots as the averages of the first-stage values; temperature axis as the average of the concentration-specific percentiles",
    "Residual autocorrelation: lagged deviance residuals (lags 1–7) added in all concentrations, without the prespecified partial autocorrelation trigger, which fired in 99.5%–100% of simulated series without autocorrelation; partial autocorrelation reported descriptively",
    "Concentration-specific seeds for the Monte Carlo samples and the bootstrap; cross-basis computed on the consecutive daily series; operational rules for the MRT search",
    "Interpretation of the attributable fraction against the estimated MRT: required Methods, Results, and Limitations text; attributable fraction kept out of the Abstract conclusion; post hoc test of the pooled curve against a flat curve and distribution of the attributable fraction under no association; erratum on negative contributions within the 1st–99th percentile range (grid resolution)",
    "Person-day delivery-risk weights declared as negligible for preterm birth and used in the early-term comparison; corrected code tests; reporting of the pooled curve (°C and percentiles, Cochran Q, I², Wald tests, lag–response)",
    "Two-step fallback for nonconvergence (lag basis by concentration, then exposure basis in all concentrations)",
    "Single rule for an MRT at the boundary of the search range: contrast equal to 1 by construction, without CI; RR against the median and the minimum searched between the 10th and 90th percentiles reported as sensitivity analyses",
    "Operational rules of the robustness criterion: each sensitivity analysis with its own pooled MRT; direction condition met by construction; 99th and 1st percentile contrasts assessed separately; boundary contrast deemed not assessable; fallback handling",
    "Specification of sensitivity analyses on calendar (Christmas week, 2020–2021, local holidays), cross-basis lags, penalized DLNM, one-stage model, warm season, the fallback rule, and the overdispersion rule, with parameters fixed before running",
    "Preterm subtypes (offset restricted to the subtype weeks; rule for the delivery-risk weight coefficient; exclusion of concentrations with <1,000 subtype events), delivery-risk weight by year of entry, and the 2011 arm",
    "One-stage MRT at the boundary: contrast equal to 1 without CI, RR against the median as descriptive, and no additional search between the 10th and 90th percentiles",
    "Definitions of the exploratory meta-predictors (macroregion, cesarean delivery, ≥7 prenatal visits, and the 2010 municipal human development index)",
    "Degrees of freedom of the natural spline of time proportional to the window (99); weighted projection for the null distribution of the partial autocorrelation; fetal deaths added to the pregnancies at risk with the primary delivery-risk weights",
    "Correction of a D16 sentence; construction rules of the local-holiday table (holiday vs optional day off; effective dates)"),
  Label = c("Post hoc choice (the prespecified combination could not be computed)", "Clarification of the plan (gap in the primary contrast)", "Post hoc choice (defective prespecified rule, shown by simulation)",
            "Correction of a defective rule (seeds) and clarification", "Post hoc", "Clarification of the plan", "Clarification of the plan",
            "Interpretation (side of the boundary); post hoc (boundary contrast and handling); prespecified sensitivity analyses (median and 10th–90th percentile search)",
            "Clarification of the plan (four items) and post hoc choice (boundary)", "Clarification of the plan or post hoc choice, by item",
            "Post hoc choices (offset, exclusion rule, year-of-entry weights, 2011 arm); clarification (coefficient rule)", "Interpretation (side); boundary contrast and descriptive RR post hoc",
            "Post hoc choice (definition gap)", "Clarification of the plan", "Text correction; construction rules post hoc relative to the primary results"),
  `Used results of this study` = c("No (before the second stage)", "No (before the second stage)", "No (decided by simulation; first-stage residual autocorrelation had been seen)",
            "No (before the second stage)", "Yes (primary results)", "No", "No (the fallback was not needed)", "No; primary results already known", "No; primary results already known",
            "No for the decisions; the penalized DLNM uses the primary pooled MRT as input", "No (counts and exposure only)", "No", "No (registry counts, IBGE, and Atlas data only)",
            "No", "No (decided without results of the local-holiday analysis)"))
stopifnot(nrow(S5T) == 15L, !anyNA(S5T))

# ------------------------------------------------------------------ contagens e conferências das regras da revista (mensagem do chat, seção 4)
wc_ <- function(x) { x <- x[!grepl("^#", x) & nzchar(trimws(x))]; x <- sub("^- ", "", gsub("\\[@[^]]*\\]", "", x)); sum(lengths(strsplit(trimws(x), "\\s+"))) }
n_w <- c(abstract = wc_(A), introduction = wc_(I), methods = wc_(M), results = wc_(R), comment = wc_(C))
n_main <- sum(n_w[c("introduction", "methods", "results", "comment")]); n_mr <- sum(n_w[c("methods", "results")])
WCLINE <- sprintf("Abstract: %s words; Main text: %s words", n_(n_w[["abstract"]]), n_(n_main))
com_sec <- sub("^### ", "", C[grepl("^### ", C)])
abrev <- function(x) { x <- x[!grepl("^#", x)]; unique(unlist(regmatches(x, gregexpr("\\b[A-Z]{2,}[0-9.]*\\b", x)))) }
tw <- setdiff(tolower(strsplit(TIT, "[ -]")[[1]]), c("and", "in", "of", "26")); kw_w <- tolower(unlist(strsplit(KW, "[ -]")))
regras <- c(
  titulo_palavras = length(strsplit(TIT, " ")[[1]]) %in% 10:14, titulo_sem_abrev = !length(abrev(TIT)),
  condensation = length(strsplit(COND, " ")[[1]]) <= 25 && nchar(COND) <= 210,
  short_title = nchar(STIT) >= 64 && nchar(STIT) <= 96 && !length(abrev(STIT)),
  glance = wc_(GL) + sum(lengths(strsplit(sub("^### ", "", GL[grepl("^### ", GL)]), " "))) <= 130 && !length(abrev(GL)),
  keywords = length(KW) == 7 && identical(KW, sort(KW, method = "radix")) && !any(c("and", "of") %in% kw_w) && !length(intersect(tw, kw_w)),
  abstract_palavras = n_w[["abstract"]] >= 250 && n_w[["abstract"]] <= 500, abstract_sem_abrev = !length(abrev(A)),
  main_text = n_main <= 3000, methods_results = n_mr <= 1705, introduction = n_w[["introduction"]] >= 300 && n_w[["introduction"]] <= 450,   # M+R: limite do chat (M5b), até 1.705
  comment_palavras = n_w[["comment"]] >= 900 && n_w[["comment"]] <= 1100,
  comment_secoes = identical(com_sec, c("Principal Findings", "Results in the Context of What Is Known", "Clinical Implications", "Research Implications", "Strengths and Limitations", "Conclusions")),
  highlights = length(HL) %in% 3:5 && all(nchar(HL) <= 85))
TODO <- c(A, I, M, R, C, G, IA, S, LEG, GL, COND, STIT, TIT, HL)
proib <- c(novidade = any(grepl("\\b(the first (study|analysis|to)|first to|novel|unprecedented)\\b", TODO, ignore.case = TRUE)),
           registro = any(grepl("preregistered|registered protocol", TODO, ignore.case = TRUE)), maes = any(grepl("\\bmothers?\\b", TODO, ignore.case = TRUE)),
           cego = any(grepl("Guilherme|Coelho|UNICAMP|Unicamp|unicamp|CliMaterna|GitHub|github|guilcoel|/Volumes|artigos_perinatais", TODO)))
chaves <- sort(unique(sub("^@", "", trimws(unlist(strsplit(unlist(regmatches(TODO, gregexpr("(?<=\\[@)[^]]+(?=\\])", TODO, perl = TRUE))), ";"))))))
literal_ok <- c(etica = ETICA %in% M, d5_vies = any(grepl(D5BIAS, M, fixed = TRUE)), d10_1g = any(grepl(D10G, M, fixed = TRUE)), errata_d5 = ERR %in% C,
                sementes = any(grepl(SEEDS, S, fixed = TRUE)), posthoc_d5 = POSTHOC %in% S, d8_errata = any(grepl(D8E, S, fixed = TRUE)), soft_s8 = any(grepl(SOFT, S, fixed = TRUE)), d1 = any(grepl(D1, M, fixed = TRUE)))
cat("palavras:", paste(names(n_w), n_w, collapse = "; "), "| main:", n_main, "| M+R:", n_mr, "\n")
cat("regras falhas:", paste(names(regras)[!regras], collapse = ", "), "| proibidos:", paste(names(proib)[proib], collapse = ", "), "| literais faltando:", paste(names(literal_ok)[!literal_ok], collapse = ", "), "\n")
cat("abreviações no abstract:", paste(abrev(A), collapse = " "), "| chaves:", length(chaves), "\n")
if (DRY) { cat("chaves:", chaves, "\n"); cat("DRY: nada gravado\n"); quit(save = "no") }
stopifnot(all(regras), !any(proib), all(literal_ok))

# ------------------------------------------------------------------ gravação
MS <- c(paste("#", TIT), "", "## Condensation", "", COND, "", "## Short Title", "", STIT, "", "## AJOG at a Glance", "", GL,
        "## Blinded Conflict of Interest Statement", "", COI_CEGO, "", "## Keywords", "", paste(KW, collapse = "; "), "", "## Word count", "", WCLINE, "",
        A, I, M, R, C, G, IA)
PT <- c(paste("#", TIT), "", "## Short Title", "", STIT, "", "## Authors", "", "[Author names, degrees, and affiliations: to be confirmed by the authors]", "",
        "## Corresponding author", "", "[Name and address: to be confirmed by the authors]. E-mail: guilcoel@unicamp.br", "",
        "## Conflicts of Interest", "", "[To be confirmed by the authors]", "", "## Source of Funding", "", "[To be confirmed by the authors]", "",
        "## Acknowledgments", "", "[To be confirmed by the authors]", "", "## Information blinded in the manuscript", "", "Prespecified analysis plan: commit 86069e5 (October 9, 2026). Analysis plan, decision log, and code: deposited with a DOI in the institutional data repository upon acceptance; frozen version identified by the tag of October 9, 2026, and the SHA-256 of the plan (a30398496c2bad285a22a55e3bee67c6df1bbdd6439ad9f0f712c2b964a9ed04). Anonymous link for reviewers, cited in the blinded manuscript: [anonymous review link].", "", "## Word count", "", WCLINE, "")
HLMD <- c("# Highlights", "", paste("-", HL), "")
writeLines(MS, OUT[["manuscrito"]], useBytes = TRUE); writeLines(S, OUT[["suplemento"]], useBytes = TRUE); writeLines(PT, OUT[["pagina_titulo"]], useBytes = TRUE)
writeLines(HLMD, OUT[["highlights"]], useBytes = TRUE); writeLines(LEG, OUT[["legendas"]], useBytes = TRUE)
f_s5 <- file.path(D, paste0("tabS5_decisoes_", VERSAO, "_", rodada, ".csv")); stopifnot(!file.exists(f_s5)); utils::write.csv(S5T, f_s5, row.names = FALSE, fileEncoding = "UTF-8"); OUT <- c(OUT, tabS5 = f_s5)
sha_out <- vapply(OUT, sha, ""); stopifnot(versao() == "4443971b")
md <- c("# Fase 4: correções v3 (Methods e Results) e marco M4 (manuscrito completo)", "",
  sprintf("- **Gerado por:** `00_scripts/90_manuscrito_m4_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()`: %s.", sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  "- **Entradas (SHA-256 = registrados):**", sprintf("  - `%s`: `%s`;", c(FIXO, names(DO_LOG)), c(sha_fx, sha_dl)),
  "- **Spec das frases prescritas (SHA-256 conferido no `spec/SHA256SUMS` ou no índice):**", sprintf("  - `%s`: `%s`;", SPEC, sha_sp), "",
  "## Contagem de palavras (sem títulos de seção e sem as chaves de citação)", "",
  "| Seção | Palavras | Meta |", "|---|---|---|",
  sprintf("| Abstract | %d | 250–500 (300–400) |", n_w[["abstract"]]), sprintf("| Introduction | %d | ~400 |", n_w[["introduction"]]),
  sprintf("| Methods | %d | ~1.150 |", n_w[["methods"]]), sprintf("| Results | %d | ~550 |", n_w[["results"]]), sprintf("| Methods + Results | %d | ≤ 1.705 |", n_mr),
  sprintf("| Comment | %d | 900–1.100 |", n_w[["comment"]]), sprintf("| Texto principal (Introduction a Comment) | %d | ≤ 3.000 |", n_main), "",
  sprintf("- **Front matter:** título com %d palavras; condensation com %d palavras e %d caracteres; short title com %d caracteres; AJOG at a Glance com %d palavras (com os títulos A, B e C); 7 keywords em ordem alfabética, sem palavra do título; highlights com %s caracteres.",
          length(strsplit(TIT, " ")[[1]]), length(strsplit(COND, " ")[[1]]), nchar(COND), nchar(STIT), wc_(GL) + sum(lengths(strsplit(sub("^### ", "", GL[grepl("^### ", GL)]), " "))), paste(nchar(HL), collapse = ", ")),
  sprintf("- **Regras conferidas por código (todas verdadeiras):** %s. **Proibidos ausentes:** \"first\"/\"novel\"/\"unprecedented\" como novidade, \"preregistered\", \"registered protocol\", \"mothers\" e nomes, instituição, GitHub e caminhos (duplo-cego) no manuscrito, no suplemento, nas legendas e nos highlights. Nenhuma afirmação de novidade, então não há busca a documentar.", paste(names(regras), collapse = ", ")),
  "- **Frases prescritas e onde ficaram (regra do chat, correção 5):**",
  "  - texto principal: ética (decisões de 08/10, §2, literal); D1 (fração atribuível, literal do 88 v2, com \"on the same day and the following 7 days\" no lugar de \"over the following 0–7 days\", Menor do chat); frase do viés da AF (errata da D5, item 4, seguida do resto do item 2 da D5, l. 64, literal); D10, 1g (literal); frase da D8, 1.1 e 1.2 (Ψ singular, redação da sessão, correção 3); errata da D5 na Comment (Strengths and Limitations), literal, com \"none of the pooled cumulative relative risks of the primary analysis excluded the null\" (correção 4) e [k] = \"no replicate failed\";",
  "  - Supplementary Methods, inteiras, com remissão no texto: D8 errata adaptada (literal do 88 v2); sementes do Monte Carlo (complemento de 13/10, literal); parágrafo post hoc da D5 (l. 123, literal); §8 com o complemento (literal do 88 v2, sem a frase da base e do repositório, trocada pela de disponibilidade do chat no texto principal); D1, item 5; D10, 1b; E9; D12, 4.1 (as 8 concentrações e as duas declarações); D16 (`z_fetal`; gl do ns(tempo)); D15; D11, 5.2 e 5.3; D17; §2.3; PACF da D3; ponte da D1; contribuições negativas; distribuições do P2 (também na Tabela S4).",
  "  - Todas as frases lidas da spec são conferidas por `identical`/`grepl(fixed = TRUE)` contra o texto gravado; os números embutidos na errata da D5 são conferidos contra as saídas.",
  sprintf("- **Disponibilidade (correção 2):** a frase do chat, com \"from [ref]\" resolvido como \"from its public repository\" com a citação do BR-DWGD (Xavier 2022), porque uma referência sobrescrita depois de \"from\" não se lê; o [repository] da página de título saiu na v7 (A1-143)."),
  sprintf("- **IC da TMR da uma etapa (correção 7):** 16 coeficientes (letra da D11, 5.3), IC %s–%s °C. **Justificativa corrigida:** a redução é linear, então sortear os 16 coeficientes da cross-basis ou os 4 reduzidos dá a mesma distribuição teórica; a diferença entre os IC de 16 e de 4 coeficientes (%s–%s °C) é ruído de Monte Carlo (o auditor do chat mostrou com 200 mil sorteios). **Fração de sorteios na borda:** uma etapa, %s no x99 e %s no x1; MRT combinada do primário, %s no x99 e %s no x1. O limite superior da uma etapa depende de a fração no x99 passar de 2,5%% (%s): sensível ao Monte Carlo, declarado no Supplementary Methods.",
          f1(ic16$ic16[1]), f1(ic16$ic16[2]), f1(ic16$ic4[1]), f1(ic16$ic4[2]), formatC(frac_uni[2], format = "f", digits = 3), formatC(frac_uni[1], format = "f", digits = 3), formatC(frac_comb[["x_sup"]], format = "f", digits = 3), formatC(frac_comb[["x_inf"]], format = "f", digits = 3), formatC(frac_uni[2], format = "f", digits = 3)),
  sprintf("- **RR contra a mediana do lado sem borda (Menor de logs):** %s.", paste(sprintf("%s %s: %s", med$id, med$lado, ifelse(is.na(med$li), "sem IC (borda)", ci3s(med$rr, med$li, med$ls))), collapse = "; ")),
  sprintf("- **Ψ:** autovalores %s; posto efetivo %d.", paste(formatC(Psi_av, format = "e", digits = 3), collapse = ", "), posto_ef),
  sprintf("- **Chaves de citação usadas (%d):** %s. O script 91 resolve só as verificadas em `manuscrito/referencias_m4.csv`; as outras viram [ref] e são listadas no log do 91.", length(chaves), paste(chaves, collapse = ", ")),
  "- **Placeholders:** o link anônimo do revisor (o DOI e o [repository] saíram da página de título pela A1-143: depósito só depois do aceite), a declaração de conflito de interesses cega e os dados da página de título (autores, afiliações, financiamento, agradecimentos) ficam para Guilherme confirmar.",
  "- **Declaração de IA:** modelo da Elsevier, citando Claude (Anthropic) para código e para redação e edição do texto (o chat pediu \"código e edição de linguagem\"; o texto foi redigido com o Claude, então a declaração diz isso; Guilherme decide).", "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", OUT, sha_out), "",
  "## Texto do manuscrito", "", MS, "", "## Texto do suplemento", "", S, "", "## Legendas", "", LEG, "", "## Página de título", "", PT, "", "## Highlights", "", HLMD, "",
  "- **Resultado:** ok.", "")
writeLines(md, arq, useBytes = TRUE); cat("gravado:", arq, "\n")
