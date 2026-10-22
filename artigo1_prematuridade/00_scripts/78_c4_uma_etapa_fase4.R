# 78_c4_uma_etapa_fase4.R — Fase 4, Parte C4: modelo de uma etapa (mensagem "C2, C3 e C4 em lote", 19/10/2026, item 78;
# D11, 5.3; D13, item 3; plano, script 78). uma_etapa() e curva_uma_etapa() da sens_agudos v1.0 (tag), sem fallback:
# séries das 26 empilhadas (janela principal com 7 dias de aquecimento, cada concentração com o seu), exposição em percentil
# da própria concentração (referência: tmean_nucleo de 2012 a 2024), cross-basis comum com group = concentração, nós nos
# percentis 10, 75 e 90, arglag do principal, gnm quasi-Poisson com eliminate = concentração × ano × mês, offset log Z_t,
# um γ por concentração, calendário comum, φ único. Curva no eixo médio do principal (°C → percentil); TMR na grade de
# 0,1 °C entre x1 e x99, borda pelo índice; IC bootstrap (semente 20261001); RR no x99 e no x1; na borda, o contraste
# daquele lado vale 1 (sem IC) e o RR contra a mediana sai como descritivo (D13, item 3).
# Saída (fora do git): 01_saidas/fase4/c4_uma_etapa_fase4_<RODADA>.rds. Log logs/c4_uma_etapa_fase4_<RODADA>.md.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/78_c4_uma_etapa_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("c4_uma_etapa_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
f_rds <- file.path("01_saidas", "fase4", paste0("c4_uma_etapa_fase4_", rodada, ".rds")); stopifnot(!file.exists(f_rds))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/78_c4_uma_etapa_fase4.R"; CC <- file.path(REPO, "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
icf <- function(a, li, ls, d = 3) sprintf("%s (%s a %s)", br(a, d), br(li, d), br(ls, d))
sujos <- git("status", "--porcelain", "--", ESTE); if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current"); st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:"); inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"); t0 <- Sys.time()
s_info <- sessionInfo(); if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib")) stop("BLAS/LAPACK fora da referência (§8)")
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
COD <- c("codigo_compartilhado/R/segunda_etapa.R" = "segunda_etapa-v1.1", "codigo_compartilhado/R/sens_agudos.R" = "sens_agudos-v1.0")
sha_cod <- vapply(names(COD), function(p) sha(file.path(REPO, p)), ""); for (p in names(COD)) if (!identical(sha_cod[[p]], tag_sha(COD[[p]], p))) stop(p, " difere da tag")
ENT <- c(s4 = "01_saidas/fase4/serie_ptb_fase4.rds", rds45 = "01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds")
SHA_ENT <- c(s4 = "e70190c1bf7c0fa5ba9c9f1e3cacb46f1ef8d647fc04a8606d181f7c819793e0", rds45 = "52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e")
sha_ent <- vapply(ENT, sha, ""); if (!identical(unname(sha_ent), unname(SHA_ENT))) stop("entrada com SHA-256 diferente do registrado")
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta) })
f <- new.env(); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f); sys.source(file.path(CC, "R", "sens_agudos.R"), envir = f)
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES
r45 <- readRDS(ENT[["rds45"]]); INI <- as.Date("2012-04-07"); FIM <- as.Date("2024-08-06")
s4 <- as.data.frame(readRDS(ENT[["s4"]])); s4 <- s4[s4$data >= INI & s4$data <= FIM, ]
d <- do.call(rbind, lapply(ordem, function(r) { x <- s4[s4$recorte_principal == r, ]; x <- x[order(x$data), ]; stopifnot(nrow(x) == 4505L, all(diff(x$data) == 1))
  data.frame(unidade = r, data = x$data, tmean = x$tmean_nucleo, log_z = x$log_z, log_w = x$log_w, y = x$ptb, janela = x$janela_principal, estrato = x$estrato,
             dia_semana = x$dia_semana, feriado_nacional = x$feriado_nacional, carnaval = x$carnaval, moveis = x$moveis, stringsAsFactors = FALSE) }))
sdr <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_nucleo"))); sdr$data <- as.Date(sdr$data)
sdr <- sdr[sdr$data >= as.Date("2012-01-01") & sdr$data <= as.Date("2024-12-31"), ]; sdr <- sdr[order(sdr$recorte_principal, sdr$data), ]
ref <- setNames(lapply(ordem, function(r) sdr$tmean_nucleo[sdr$recorte_principal == r]), ordem)
AL7 <- list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE)
ue <- f$uma_etapa(d, ref, AL7, lag = 7L, nos_pct = c(10, 75, 90))
if (!identical(ue$status, "ok")) { writeLines(c("# Fase 4, Parte C4: uma etapa", "", paste0("- **Falhou (sem fallback; D11, 5.3):** ", ue$mensagem), ""), arq); cat("uma etapa falhou\n"); quit(status = 1) }
cu <- f$curva_uma_etapa(ue, unname(r45$eixo), 100 * r45$eixo_p, nsim = 1000L)   # eixo_p do 45 em 0–1; a exposição da uma etapa está em percentil 0–100
r99 <- cu$rr[cu$rr$rotulo == "x99", ]; r01 <- cu$rr[cu$rr$rotulo == "x1", ]
saveRDS(list(ajuste = ue[setdiff(names(ue), c("matriz"))], curva = cu, sha_codigo = sha_cod, sha_entradas = sha_ent, rodada = rodada), f_rds)
stopifnot(versao() == "4443971b")
fmt <- function(z) if (is.na(z$rr_li)) "1 (borda)" else icf(z$rr, z$rr_li, z$rr_ls)
md_txt <- c("# Fase 4, Parte C4: modelo de uma etapa (D11, 5.3)", "",
  sprintf("- **Gerado por:** `00_scripts/78_c4_uma_etapa_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()`: %s.", sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  "- **Código (igual ao das tags):**", sprintf("  - `%s`: `%s` (`%s`);", names(sha_cod), sha_cod, COD), sprintf("- **Entradas (SHA-256 = registrados):** %s.", paste(sprintf("`%s` (`%s`)", ENT, sha_ent), collapse = "; ")), "",
  "## Resultado", "",
  sprintf("- **Ajuste:** %s linhas de ajuste; %s estratos eliminados; φ = %s; γ por concentração de %s a %s; cross-basis com nós nos percentis 10, 75 e 90 e Boundary.knots %s a %s (percentil).",
          format(ue$n$dias_usados, big.mark = "."), format(ue$n$estratos_usados, big.mark = "."), br(ue$phi, 3), br(min(ue$gama), 3), br(max(ue$gama), 3), br(ue$argvar$Boundary.knots[1], 2), br(ue$argvar$Boundary.knots[2], 2)),
  sprintf("- **TMR:** %s °C (percentil %s)%s; IC bootstrap %s a %s °C.", br(cu$tmr, 1), br(cu$tmr_pct, 1), if (cu$fronteira) paste0(" [borda ", cu$lado_borda, "]") else "", br(cu$ic_tmr[1], 1), br(cu$ic_tmr[2], 1)),
  sprintf("- **RR no x99:** %s. **RR no x1:** %s.", fmt(r99), fmt(r01)),
  if (cu$fronteira) sprintf("- **RR contra a mediana (descritivo):** x99 %s; x1 %s.", icf(cu$rr_mediana$rr[1], cu$rr_mediana$rr_li[1], cu$rr_mediana$rr_ls[1]), icf(cu$rr_mediana$rr[2], cu$rr_mediana$rr_li[2], cu$rr_mediana$rr_ls[2])) else "- TMR interior: sem RR contra a mediana.",
  sprintf("- **Bootstrap:** sorteia os 4 coeficientes reduzidos (overall), não os 16 da cross-basis (auditoria da Parte A, Nota 6; declarado)."), "",
  sprintf("- **Saída (fora do git):** `%s`: `%s`. Tempo: %.1f min.", f_rds, sha(f_rds), as.numeric(difftime(Sys.time(), t0, units = "mins"))), "")
writeLines(md_txt, arq, useBytes = TRUE); cat("gravado:", arq, "| TMR", round(cu$tmr, 1), "\n")
