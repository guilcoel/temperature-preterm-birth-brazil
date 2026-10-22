# 85_m2_menores_tabela_v2_fase4.R — Fase 4, fecho do M2: as duas Menores da auditoria do M2 (decisões de Guilherme, A1-122)
# e a tabela das sensibilidades v2. Só lê saídas gravadas (SHA-256 conferido contra o log de origem); nenhum reajuste.
#   (a) Menor 1, uma etapa (D11, 5.3): IC da TMR por 1.000 sorteios dos 16 coeficientes da cross-basis (Cholesky da vcov_cb,
#       semente 20261001, i = 0), cada sorteio reduzido ao overall (soma nos lags da base do arglag) e minimizado na grade de
#       0,1 °C entre x1 e x99 do eixo do principal, convertida em percentil. Controle positivo antes: com os 4 coeficientes
#       reduzidos e a mesma semente, o IC do 78 é reproduzido com identical(); a redução à mão dos 16 coeficientes é igual à
#       reduzida salva. O ponto (TMR) não muda. Declarar: limite superior no x99 (censurado pela grade).
#   (b) Menor 2, estação quente (D11, item 6): contrastes p95, p90, p10 e p5 do eixo de nov–mar contra a TMR da T6, com a
#       curva na média dos metapreditores do RDS do 74 (segunda_etapa::curva). Controle: o x99 e o x1 reproduzem a curva salva.
#   (c) tabela_sensibilidades_fase4_v2.csv: a v1 (80) com a uma etapa pelo IC de (a), a linha dos feriados locais (84,
#       tabela v1.1) e a do IDHM (82); a nota da T6 aponta para os contrastes de (b).
# Saídas (fora do git): 01_saidas/fase4/tabela_sensibilidades_fase4_v2.csv, contrastes_estacao_quente_fase4.csv e
# ic_tmr_uma_etapa_16coef_fase4.rds. Log logs/m2_menores_tabela_v2_fase4_<RODADA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/85_m2_menores_tabela_v2_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("m2_menores_tabela_v2_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase4")
f_out <- c(tab = file.path(OUT, "tabela_sensibilidades_fase4_v2.csv"), nov = file.path(OUT, "contrastes_estacao_quente_fase4.csv"), ic = file.path(OUT, "ic_tmr_uma_etapa_16coef_fase4.rds"))
for (p in f_out) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/85_m2_menores_tabela_v2_fase4.R"; CC <- file.path(REPO, "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
icf <- function(a, li, ls, d = 3) ifelse(is.na(a), "—", ifelse(is.na(li), paste0(br(a, d), " (borda)"), sprintf("%s (%s a %s)", br(a, d), br(li, d), br(ls, d))))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
sujos <- git("status", "--porcelain", "--", ESTE); if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current"); st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:"); inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
COD <- c("codigo_compartilhado/R/segunda_etapa.R" = "segunda_etapa-v1.1", "codigo_compartilhado/R/sens_agudos.R" = "sens_agudos-v1.0")
sha_cod <- vapply(names(COD), function(p) sha(file.path(REPO, p)), ""); for (p in names(COD)) if (!identical(sha_cod[[p]], tag_sha(COD[[p]], p))) stop(p, " difere da tag")
FIXO <- c("01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds" = "52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e")
DO_LOG <- c("01_saidas/fase4/c4_uma_etapa_fase4_20261019.rds" = "logs/c4_uma_etapa_fase4_20261019.md", "01_saidas/fase4/c3_fase4_20261019.rds" = "logs/c3_fase4_20261019.md",
            "01_saidas/fase4/percentis_exposicao_fase4_20261018.csv" = "logs/percentis_exposicao_fase4_20261018.md",
            "01_saidas/fase4/tabela_sensibilidades_fase4.csv" = "logs/tabela_sensibilidades_fase4_20261019.md",
            "01_saidas/fase4/c4_idhm_fase4_20261019.rds" = "logs/c4_idhm_fase4_20261019.md", "01_saidas/fase4/c3_feriados_locais_fase4_20261019.csv" = "logs/c3_feriados_locais_fase4_20261019.md")
sha_ent <- vapply(c(names(FIXO), names(DO_LOG)), sha, "")
if (!identical(unname(sha_ent[names(FIXO)]), unname(FIXO))) stop("RDS do 45 com SHA-256 diferente do registrado")
for (p in names(DO_LOG)) if (!grepl(paste0("`", p, "`: `", sha_ent[[p]], "`"), paste(readLines(DO_LOG[[p]], encoding = "UTF-8"), collapse = "\n"), fixed = TRUE)) stop(p, ": SHA-256 diferente do registrado em ", DO_LOG[[p]])
suppressPackageStartupMessages({ library(dlnm); library(mixmeta) })
f <- new.env(); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f); sys.source(file.path(CC, "R", "sens_agudos.R"), envir = f)
r45 <- readRDS(names(FIXO)); E <- names(DO_LOG)

# ------------------------------------------------------------------ (a) uma etapa: IC pelos 16 coeficientes
u <- readRDS(E[1]); a <- u$ajuste; cu <- u$curva
eixo <- unname(r45$eixo); ep <- 100 * r45$eixo_p; x1 <- eixo[ep == 1]; x99 <- eixo[ep == 99]; stopifnot(length(x1) == 1, length(x99) == 1)
g <- f$grade_tmr(x1, x99); pg <- f$posicao_no_eixo(g, eixo, ep); stopifnot(!anyNA(pg))
B <- f$.base_x(pg, a$argvar)
al <- a$arglag[intersect(names(a$arglag), c("fun", "knots", "intercept", "Boundary.knots", "df", "degree"))]
bl <- unclass(do.call(dlnm::onebasis, c(list(x = seq(a$lag[1], a$lag[2])), al)))
M <- kronecker(diag(ncol(B)), matrix(colSums(bl), 1)); stopifnot(nrow(M) == length(a$reduzida$coef), ncol(M) == length(a$coef_cb))
dif_red <- max(abs(drop(M %*% a$coef_cb) - a$reduzida$coef)); if (dif_red > 1e-10) stop("redução à mão dos 16 coeficientes difere da reduzida salva: ", dif_red)
tmr_de <- function(red) g[apply(B %*% red, 2, which.min)]
f$semeia(0); s4 <- a$reduzida$coef + t(chol(a$reduzida$vcov)) %*% matrix(stats::rnorm(length(a$reduzida$coef) * 1000L), length(a$reduzida$coef))
ic4 <- unname(stats::quantile(tmr_de(s4), c(0.025, 0.975), type = 7)); ok_ic4 <- identical(ic4, cu$ic_tmr)
if (!ok_ic4) stop("controle positivo: o IC de 4 coeficientes não reproduz o do 78 com identical()")
f$semeia(0); s16 <- a$coef_cb + t(chol(a$vcov_cb)) %*% matrix(stats::rnorm(length(a$coef_cb) * 1000L), length(a$coef_cb))
tm16 <- tmr_de(M %*% s16); ic16 <- unname(stats::quantile(tm16, c(0.025, 0.975), type = 7))
prop16 <- c(x1 = mean(tm16 == g[1]), x99 = mean(tm16 == g[length(g)]))
ponto <- g[which.min(drop(B %*% a$reduzida$coef))]; stopifnot(isTRUE(all.equal(ponto, cu$tmr, tolerance = 0)))
saveRDS(list(ic16 = ic16, ic4 = ic4, tmr = ponto, prop_bordas = prop16, dif_reducao = dif_red, n = 1000L, semente = "semeia(0)", rodada = rodada), f_out[["ic"]])

# ------------------------------------------------------------------ (b) estação quente: contrastes p95, p90, p10 e p5 de nov–mar
c3 <- readRDS(E[2]); t6 <- c3$T6; stopifnot(identical(t6$linha$id, "T6"))
pct <- utils::read.csv(E[3], colClasses = c(recorte_principal = "character", valor = "character")); pct$valor <- as.numeric(pct$valor)
ev <- pct[pct$exposicao == "tmean_nucleo_nov_mar" & pct$recorte_principal == "eixo_medio", ]; ev <- ev[order(ev$percentil), ]; ex_v <- setNames(ev$valor, ev$rotulo)
pc <- t6$meta$pred_media$coef; pv <- t6$meta$pred_media$vcov; cen <- t6$tmr$tmr
ctl <- f$curva(pc, pv, t6$base, unname(ex_v[c("p99", "p1")]), cen)
ok_ctl <- isTRUE(all.equal(ctl$rr, t6$curva$rr, tolerance = 1e-12)) && isTRUE(all.equal(ctl$rr_li, t6$curva$rr_li, tolerance = 1e-12)) && isTRUE(all.equal(ctl$x, t6$curva$x, tolerance = 1e-12))
if (!ok_ctl) stop("controle: o x99 e o x1 de nov–mar não reproduzem a curva salva da T6")
PER <- c("p99", "p95", "p90", "p10", "p5", "p1"); cv <- f$curva(pc, pv, t6$base, unname(ex_v[PER]), cen)
nov <- data.frame(percentil = PER, temperatura = cv$x, tmr = cen, rr = cv$rr, rr_li = cv$rr_li, rr_ls = cv$rr_ls, stringsAsFactors = FALSE)
num <- vapply(nov, is.double, TRUE); o <- nov; o[num] <- lapply(o[num], function(v) sprintf("%.17g", v)); utils::write.csv(o, f_out[["nov"]], row.names = FALSE, fileEncoding = "UTF-8")

# ------------------------------------------------------------------ (c) tabela v2
tab <- utils::read.csv(E[4], stringsAsFactors = FALSE, encoding = "UTF-8", na.strings = c("", "NA"))
stopifnot(nrow(tab) == 44L, !anyDuplicated(tab$id))
iu <- which(tab$id == "C4-UMA"); stopifnot(length(iu) == 1, isTRUE(all.equal(c(tab$ic_tmr_li[iu], tab$ic_tmr_ls[iu]), cu$ic_tmr, tolerance = 1e-12)))
tab$ic_tmr_li[iu] <- ic16[1]; tab$ic_tmr_ls[iu] <- ic16[2]
tab$nota[iu] <- paste0(tab$nota[iu], "; IC por 1.000 sorteios dos 16 coeficientes da cross-basis (D11, 5.3; A1-122), limite superior no x99 (censurado pela grade)")
it6 <- which(tab$id == "C3-T6"); tab$nota[it6] <- "contrastes p99, p95, p90, p10, p5 e p1 de nov–mar em contrastes_estacao_quente_fase4.csv (D11, item 6; A1-122)"
fl <- utils::read.csv(E[6], stringsAsFactors = FALSE, encoding = "UTF-8", na.strings = c("", "NA")); stopifnot(nrow(fl) == 1L)
ifl <- which(tab$id == "C3-FL"); b <- if (isTRUE(fl$fronteira)) fl$lado_borda else NA_character_
tab[ifl, c("grupo", "analise", "status", "n_concentracoes", "tmr_c", "tmr_percentil", "ic_tmr_li", "ic_tmr_ls", "rr99", "rr99_li", "rr99_ls", "rr01", "rr01_li", "rr01_ls", "borda",
           "phi_min", "phi_med", "phi_max", "fallback", "nota")] <-
  list("Tempo e calendário", "Calendário: feriados locais (tabela v1.1 da tag feriados_locais-v1.1, mais 24/12 e 31/12)", "ok", as.integer(fl$incluidas), fl$tmr, 100 * fl$percentil_tmr,
       fl$ic_tmr_li, fl$ic_tmr_ls, fl$rr99, fl$rr99_li, fl$rr99_ls, fl$rr01, fl$rr01_li, fl$rr01_ls, b, fl$phi_min, fl$phi_med, fl$phi_max, fl$passo_fallback,
       "D11, 3.3; D17; tabela 4a3d4f15… (A1-119)")
idh <- readRDS(E[5])$exploratorio; ii <- which(tab$id == "C4-EX-idhm"); stopifnot(identical(idh$status, "ok"))
tab$status[ii] <- "ok"; tab$n_concentracoes[ii] <- 26L
tab$nota[ii] <- sprintf("Wald %s (%d gl; p = %s); Q residual com o termo %s (%d gl), sem %s (%d gl); IDHM 2010 do Atlas, média ponderada pela população do Censo 2010 (A1-113, A1-114)",
                        br(idh$wald$estatistica, 2), as.integer(idh$wald$gl), formatC(idh$wald$p, format = "g", digits = 3, decimal.mark = ","), br(idh$heterogeneidade$com$Q, 1),
                        as.integer(idh$heterogeneidade$com$df), br(idh$heterogeneidade$sem$Q, 1), as.integer(idh$heterogeneidade$sem$df))
num <- vapply(tab, is.double, TRUE); out <- tab; out[num] <- lapply(out[num], function(v) ifelse(is.na(v), NA, sprintf("%.17g", v)))
utils::write.csv(out, f_out[["tab"]], row.names = FALSE, na = "", fileEncoding = "UTF-8"); sha_out <- vapply(f_out, sha, "")
stopifnot(versao() == "4443971b")
md_txt <- c("# Fase 4, fecho do M2: as duas Menores e a tabela das sensibilidades v2", "",
  sprintf("- **Gerado por:** `00_scripts/85_m2_menores_tabela_v2_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()`: %s.", sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  "- **Código (igual ao das tags):**", sprintf("  - `%s`: `%s` (`%s`);", names(sha_cod), sha_cod, COD),
  "- **Entradas (SHA-256 = registrados):**", sprintf("  - `%s`: `%s`;", names(sha_ent), sha_ent),
  "- **Decisões:** A1-122 (Guilherme, 19/10, 16:22).", "",
  "## (a) Uma etapa: IC da TMR pelos 16 coeficientes da cross-basis (D11, 5.3)", "",
  sprintf("- **Controles:** redução à mão dos 16 coeficientes igual à reduzida salva (diferença máxima %s); o IC de 4 coeficientes com a mesma semente reproduz o do 78 com `identical()`: %s.", formatC(dif_red, format = "e", digits = 1), if (ok_ic4) "sim" else "não"),
  sprintf("- **TMR:** %s °C (sem mudança). **IC com 16 coeficientes:** %s a %s °C (era %s a %s com 4). Sorteios na borda: %s%% no x1 e %s%% no x99; **limite superior no x99, censurado pela grade**.",
          br(ponto, 1), br(ic16[1], 1), br(ic16[2], 1), br(ic4[1], 1), br(ic4[2], 1), br(100 * prop16[["x1"]], 1), br(100 * prop16[["x99"]], 1)), "",
  "## (b) Estação quente: contrastes de nov–mar contra a TMR (D11, item 6)", "",
  sprintf("- **TMR da T6:** %s °C (grade entre x1 e x50 do eixo de nov–mar). **Controle:** o x99 e o x1 reproduzem a curva salva no RDS do 74: %s.", br(cen, 1), if (ok_ctl) "sim" else "não"),
  tabela_md(data.frame(Percentil = nov$percentil, `Temperatura (°C)` = br(nov$temperatura, 1), `RR (IC)` = icf(nov$rr, nov$rr_li, nov$rr_ls), check.names = FALSE)), "",
  "## (c) Tabela das sensibilidades v2 (44 linhas; mudanças contra a v1)", "",
  tabela_md(data.frame(ID = tab$id[c(iu, it6, ifl, ii)], Análise = tab$analise[c(iu, it6, ifl, ii)],
                       `TMR °C (percentil)` = ifelse(is.na(tab$tmr_c[c(iu, it6, ifl, ii)]), "—", sprintf("%s (%s)", br(tab$tmr_c[c(iu, it6, ifl, ii)], 1), br(tab$tmr_percentil[c(iu, it6, ifl, ii)], 1))),
                       `IC da TMR` = ifelse(is.na(tab$ic_tmr_li[c(iu, it6, ifl, ii)]), "—", sprintf("%s a %s", br(tab$ic_tmr_li[c(iu, it6, ifl, ii)], 1), br(tab$ic_tmr_ls[c(iu, it6, ifl, ii)], 1))),
                       `RR x99 (IC)` = icf(tab$rr99[c(iu, it6, ifl, ii)], tab$rr99_li[c(iu, it6, ifl, ii)], tab$rr99_ls[c(iu, it6, ifl, ii)]),
                       `RR x1 (IC)` = icf(tab$rr01[c(iu, it6, ifl, ii)], tab$rr01_li[c(iu, it6, ifl, ii)], tab$rr01_ls[c(iu, it6, ifl, ii)]),
                       Nota = ifelse(is.na(tab$nota[c(iu, it6, ifl, ii)]), "—", tab$nota[c(iu, it6, ifl, ii)]), check.names = FALSE)), "",
  "- **Sem pendência na lista fechada:** os feriados locais e o IDHM entraram; as demais linhas são as da v1.", "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", f_out, sha_out), "", "- **Resultado:** ok.", "")
writeLines(md_txt, arq, useBytes = TRUE); cat("gravado:", arq, "| IC16", round(ic16, 1), "\n")
