# 35_autoauditoria_fase2C.R — Fase 2, Parte C: autoauditoria da primeira etapa (32). Recalcula, com código diferente,
# cada número do log e das saídas do 32 e confere:
#   - código = tag (SHA-256 pelo git show) e BLAS de referência;
#   - SHA-256 das saídas gravadas = os do log;
#   - linhas passadas (datas e n), nós e cen contra referencias_exposicao.csv (lido com readLines/strsplit), Boundary.knots
#     = range de tmean_nucleo nas linhas passadas;
#   - os 26 ajustes refeitos com glm(quasipoisson) + factor(estrato), sem ajusta_dlnm() (glm convergido a fundo,
#     epsilon 1e-12): coeficientes e vcov da cross-basis (16 × 16) e reduzidos (crossreduce, 4 × 4) contra os CSVs; φ,
#     γ̂ e EP, QAIC e autovalores contra o CSV de diagnósticos; PACF dos resíduos de deviance (pacf() direto na janela,
#     que é contínua) contra o CSV da PACF; as três regras de "fora" recalculadas;
#   - as linhas das tabelas do log, reconstruídas com a mesma formatação, e o resumo nas 26.
# Lê a série principal (Fase 1) só para refazer os ajustes; nada de linha individual sai. Grava
# logs/autoauditoria_fase2C_<FASE2_DATA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE2_DATA=AAAAMMDD Rscript 00_scripts/35_autoauditoria_fase2C.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE2_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"
arq <- file.path("logs", paste0("autoauditoria_fase2C_", hoje, ".md")); stopifnot(!file.exists(arq))
L32 <- readLines(file.path("logs", paste0("primeira_etapa_fase2_", hoje, ".md")), encoding = "UTF-8"); J32 <- paste(L32, collapse = "\n")
OUT <- file.path("01_saidas", "fase2")
sai <- file.path(OUT, paste0(c("primeira_etapa_principal", "reduzida_coef_vcov", "crossbasis_coef_vcov", "pacf", "diagnosticos"), "_fase2_", hoje,
                             c(".rds", ".csv", ".csv", ".csv", ".csv")))
suppressPackageStartupMessages({ library(dlnm); library(gnm) })
f_si <- file.path("logs", paste0("sessionInfo_fase2C_", hoje, ".txt")); stopifnot(!file.exists(f_si))
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
R <- list()
reg <- function(item, o_que, n, ok) R[[length(R) + 1]] <<- data.frame(Item = item, Conferência = o_que, N = n, Resultado = if (isTRUE(ok)) "igual" else "DIFERENTE",
                                                                    check.names = FALSE, stringsAsFactors = FALSE)
no_texto <- function(item, o_que, textos) { ok <- vapply(textos, function(t) grepl(t, J32, fixed = TRUE), TRUE); reg(item, o_que, length(textos), all(ok))
  if (!all(ok)) cat("AUSENTE no log:", head(textos[!ok], 3), sep = "\n") }

# ------------------------------------------------------------------ código, BLAS e SHA das saídas
log_msg("código, BLAS e saídas")
arqs_R <- system2("git", c("-C", REPO, "ls-tree", "-r", "--name-only", "ajusta_dlnm-v1.0", "codigo_compartilhado/R/"), stdout = TRUE)
sh_tag <- vapply(arqs_R, function(a) sub(" .*", "", system(paste0("git -C ", shQuote(REPO), " show ", shQuote(paste0("ajusta_dlnm-v1.0:", a)), " | shasum -a 256"), intern = TRUE)), "")
no_texto("Código", "SHA-256 de cada arquivo de codigo_compartilhado/R/ na tag (git show) = o do log", sprintf("`%s`: `%s`", arqs_R, sh_tag))
reg("Código", "disco = tag (git diff vazio em codigo_compartilhado/R/)", 1,
    length(system2("git", c("-C", REPO, "diff", "--name-only", "ajusta_dlnm-v1.0", "--", "codigo_compartilhado/R"), stdout = TRUE)) == 0)
si <- sessionInfo(); reg("BLAS", "BLAS e LAPACK de referência (libRblas.0.dylib / libRlapack.dylib) e iguais aos do log", 2,
                         basename(si$BLAS) == "libRblas.0.dylib" && basename(si$LAPACK) == "libRlapack.dylib" && grepl(si$BLAS, J32, fixed = TRUE) && grepl(si$LAPACK, J32, fixed = TRUE))
writeLines(utils::capture.output(print(si)), f_si)                    # sessionInfo() completo (§8)
no_texto("Saídas", "SHA-256 das 5 saídas gravadas = os do log", sprintf("`%s`: `%s`", sai, vapply(sai, sha, "")))

# ------------------------------------------------------------------ referências (leitura própria) e linhas passadas
log_msg("referências e linhas")
lin <- readLines(file.path("01_saidas", "fase1", "referencias_exposicao.csv"), encoding = "UTF-8")
cab <- gsub("\"", "", strsplit(lin[1], ",")[[1]]); campos <- lapply(lin[-1], function(l) gsub("\"", "", strsplit(l, ",")[[1]]))
ref <- as.data.frame(do.call(rbind, campos), stringsAsFactors = FALSE); names(ref) <- cab
ref <- ref[grepl("^ano inteiro", ref$periodo), ]; for (k in c("p1", "p10", "p50", "p75", "p90", "p99")) ref[[k]] <- as.numeric(ref[[k]])
nuc <- as.data.frame(cidade_nucleo()); ordem <- nuc$CD_RECORTE; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
s <- readRDS(file.path("01_saidas", "fase1", "serie_ptb_principal.rds"))
d0 <- as.Date("2012-04-07"); d1 <- as.Date("2024-08-06")
s <- s[which(s$data >= d0 & s$data <= d1), ]
reg("Linhas", "4.505 linhas por concentração (2012-04-07 a 2024-08-06), 7 de aquecimento fora da janela", 26,
    all(vapply(ordem, function(r) { x <- s[s$recorte_principal == r, ]; nrow(x) == 4505 && sum(x$janela_principal) == 4498 && !any(x$janela_principal[x$data < as.Date("2012-04-14")]) }, TRUE)))
no_texto("Linhas", "período e n das linhas passadas no log", "2012-04-07 a 2024-08-06 (4.505 dias")

# ------------------------------------------------------------------ 26 ajustes com glm
log_msg("26 ajustes com glm")
cbcsv <- utils::read.csv(sai[3], colClasses = c(recorte_principal = "character")); redcsv <- utils::read.csv(sai[2], colClasses = c(recorte_principal = "character"))
pacsv <- utils::read.csv(sai[4], colClasses = c(recorte_principal = "character", fora_literal = "character", fora_recentrada = "character", fora_recentrada_bonferroni = "character"))
dgcsv <- utils::read.csv(sai[5], colClasses = c(recorte_principal = "character"))
mat <- function(df, r, tipo) { x <- df[df$recorte_principal == r & df$especificacao == "principal" & df$tipo == tipo, ]
  if (tipo == "coef") x$valor[order(x$i)] else { k <- max(x$i); M <- matrix(NA_real_, k, k); M[cbind(x$i, x$j)] <- x$valor; M } }
rel <- function(a, b) max(abs(a - b)) / max(abs(b))
linhas_esp <- linhas_diag <- linhas_pacf <- character(0); tab <- list()
for (r in ordem) {
  x <- s[s$recorte_principal == r, ]; x <- x[order(x$data), ]; rr <- ref[ref$recorte_principal == r, ]; stopifnot(nrow(rr) == 1)
  av <- list(fun = "ns", knots = c(rr$p10, rr$p75, rr$p90)); al <- list(fun = "ns", knots = logknots(7, nk = 2), intercept = TRUE)
  cb <- crossbasis(x$tmean_nucleo, lag = 7, argvar = av, arglag = al); bk <- range(x$tmean_nucleo)
  u <- x$janela_principal; stopifnot(all(stats::complete.cases(unclass(cb)[u, ])), all(is.finite(x$log_z[u])), all(is.finite(x$log_w[u])))
  ev <- tapply(x$ptb[u], x$estrato[u], sum); stopifnot(all(ev > 0))
  g <- stats::glm(x$ptb[u] ~ unclass(cb)[u, ] + x$dia_semana[u] + x$feriado_nacional[u] + x$carnaval[u] + x$moveis[u] + x$log_w[u] + factor(x$estrato[u]),
                  offset = x$log_z[u], family = stats::quasipoisson, control = stats::glm.control(epsilon = 1e-12, maxit = 100))
  cf <- stats::coef(g); V <- stats::vcov(g); i <- 2:17
  phi <- sum(stats::residuals(g, type = "pearson")^2) / g$df.residual
  k <- sum(!is.na(cf)) - length(unique(x$estrato[u]))
  qaic <- -2 * sum(stats::dpois(x$ptb[u], stats::fitted(g), log = TRUE)) + 2 * phi * k
  red <- crossreduce(cb, coef = cf[i], vcov = V[i, i], model.link = "log", type = "overall", cen = rr$p50)
  rd <- stats::residuals(g, type = "deviance"); p <- as.numeric(stats::pacf(rd, lag.max = 7, plot = FALSE)$acf); n <- length(rd)
  m <- n / length(unique(x$estrato[u])); c0 <- -1 / (m - 1)
  f_lit <- paste(which(abs(p) > 2 / sqrt(n)), collapse = ","); f_rec <- paste(which(abs(p - c0) > 2 / sqrt(n)), collapse = ",")
  f_bon <- paste(which(abs(p - c0) > stats::qnorm(1 - 0.05 / 14) / sqrt(n)), collapse = ",")
  gam <- cf[["x$log_w[u]"]]; epg <- sqrt(V["x$log_w[u]", "x$log_w[u]"])
  ev_cb <- min(eigen(V[i, i], symmetric = TRUE, only.values = TRUE)$values); ev_red <- min(eigen(stats::vcov(red), symmetric = TRUE, only.values = TRUE)$values)
  dg <- dgcsv[dgcsv$recorte_principal == r, ]; pc <- pacsv[pacsv$recorte_principal == r, ]
  tab[[r]] <- data.frame(
    r = r, cb_coef = rel(mat(cbcsv, r, "coef"), unname(cf[i])), cb_vcov = rel(mat(cbcsv, r, "vcov"), unname(V[i, i])),
    red_coef = rel(mat(redcsv, r, "coef"), unname(stats::coef(red))), red_vcov = rel(mat(redcsv, r, "vcov"), unname(stats::vcov(red))),
    phi = abs(dg$phi - phi) / phi, gama = abs(dg$gama - gam), ep = abs(dg$ep_gama - epg) / epg, qaic = abs(dg$qaic - qaic) / qaic,
    pacf = max(abs(unlist(pc[paste0("lag", 1:7)]) - p)), fora = identical(pc$fora_literal, f_lit) && identical(pc$fora_recentrada, f_rec) && identical(pc$fora_recentrada_bonferroni, f_bon),
    bk = max(abs(c(dg$bk_min, dg$bk_max) - bk)), nos = max(abs(c(dg$knot_p10, dg$knot_p75, dg$knot_p90, dg$cen_p50) - c(rr$p10, rr$p75, rr$p90, rr$p50))),
    dims = dg$dim_cb == 16 && dg$dim_reduzida == 4 && length(mat(redcsv, r, "coef")) == 4 && all(dim(mat(cbcsv, r, "vcov")) == 16),
    dias = dg$dias_usados == n && dg$estratos_usados == length(unique(x$estrato[u])) && dg$estratos_removidos == 0, stringsAsFactors = FALSE)
  # linhas das tabelas do log, com a formatação do 32 (valores do glm)
  linhas_esp <- c(linhas_esp, sprintf("| %s | %s | %s | %s | %s | %s |", nome[[r]], paste(br(rr$p10, 3), br(rr$p75, 3), br(rr$p90, 3), sep = " / "), br(rr$p50, 3),
                                      paste(br(bk[1], 3), br(bk[2], 3), sep = " a "), paste(br(rr$p1, 3), br(rr$p99, 3), sep = " / "), if (rr$p1 >= bk[1] && rr$p99 <= bk[2]) "sim" else "não"))
  linhas_diag <- c(linhas_diag, sprintf("| %s | principal | sim | 16 / 4 | %s (%s) | 0 | %d / 0 | 0 | %s / %s | %s | %s (%s) | %s |", nome[[r]], br(n), br(4498),
                                        length(unique(x$estrato[u])), formatC(ev_cb, format = "e", digits = 2), formatC(ev_red, format = "e", digits = 2),
                                        br(phi, 3), br(gam, 3), br(epg, 3), br(qaic, 1)))
  linhas_pacf <- c(linhas_pacf, sprintf("| %s | %s | %s | %s | %s | %s | %s | %s |", nome[[r]], paste(br(p, 3), collapse = "; "), br(n), br(2 / sqrt(n), 4),
                                        if (nzchar(f_lit)) f_lit else "—", br(c0, 4), if (nzchar(f_rec)) f_rec else "—", if (nzchar(f_bon)) f_bon else "—"))
  PPg <- rbind(if (exists("PPg")) PPg, p); CCg <- c(if (exists("CCg")) CCg, c0); NNg <- c(if (exists("NNg")) NNg, n)
  tab[[r]]$phi2 <- phi > 2; tab[[r]]$lit <- nzchar(f_lit); tab[[r]]$rec <- nzchar(f_rec); tab[[r]]$bon <- nzchar(f_bon); tab[[r]]$dentro <- rr$p1 >= bk[1] && rr$p99 <= bk[2]
}
TT <- do.call(rbind, tab)
sl <- abs(PPg) > 2 / sqrt(NNg); sr <- abs(PPg - CCg) > 2 / sqrt(NNg); sb <- abs(PPg - CCg) > stats::qnorm(1 - 0.05 / 14) / sqrt(NNg)
sinal_txt <- sprintf("literal %d (%d negativos, %d positivos); recentrada %d (%d acima do centro, %d abaixo); recentrada com Bonferroni %d (%d acima, %d abaixo)",
                     sum(sl), sum(sl & PPg < 0), sum(sl & PPg > 0), sum(sr), sum(sr & PPg > CCg), sum(sr & PPg < CCg), sum(sb), sum(sb & PPg > CCg), sum(sb & PPg < CCg))
reg("Ajustes (glm)", "coeficientes da cross-basis: dif. relativa máx. ≤ 1e-6", 26, max(TT$cb_coef) <= 1e-6)
reg("Ajustes (glm)", "vcov da cross-basis 16 × 16: dif. relativa máx. ≤ 1e-6", 26, max(TT$cb_vcov) <= 1e-6)
reg("Ajustes (glm)", "coeficientes reduzidos (crossreduce): dif. relativa máx. ≤ 1e-6", 26, max(TT$red_coef) <= 1e-6)
reg("Ajustes (glm)", "vcov reduzida 4 × 4: dif. relativa máx. ≤ 1e-6", 26, max(TT$red_vcov) <= 1e-6)
reg("Ajustes (glm)", "φ (dif. relativa ≤ 1e-6), γ̂ (dif. ≤ 1e-6), EP de γ (dif. relativa ≤ 1e-6), QAIC (dif. relativa ≤ 1e-8)", 26,
    max(TT$phi) <= 1e-6 && max(TT$gama) <= 1e-6 && max(TT$ep) <= 1e-6 && max(TT$qaic) <= 1e-8)
reg("PACF", "lags 1 a 7 (pacf direto nos resíduos do glm; dif. ≤ 1e-6) e as três regras de \"fora\"", 26, max(TT$pacf) <= 1e-6 && all(TT$fora))
reg("Especificação", "nós p10/p75/p90 e cen = p50 iguais aos do CSV de referências (lido à mão); Boundary.knots = range das linhas passadas (dif. ≤ 1e-12)", 26, max(TT$nos) <= 1e-12 && max(TT$bk) <= 1e-12)
reg("Dimensões e dias", "16 e 16 × 16; 4 e 4 × 4; 4.498 dias e todos os estratos usados, nenhum removido", 26, all(TT$dims) && all(TT$dias))
no_texto("Log", "as 26 linhas da tabela de especificação (nós, cen, Boundary.knots, p1/p99)", linhas_esp)
no_texto("Log", "as 26 linhas da tabela de diagnósticos (com os valores do glm)", linhas_diag)
no_texto("Log", "as 26 linhas da tabela da PACF (com os valores do glm)", linhas_pacf)
no_texto("Log", "resumo nas 26 (φ > 2, PACF nas três regras, p1/p99 dentro)",
         c(sprintf("**φ > 2:** %d de 26", sum(TT$phi2)), sprintf("(algum lag de 1 a 7 fora de ±2/√n): %d de 26", sum(TT$lit)),
           sprintf("recentrada em −1/(m − 1): %d de 26; recentrada com Bonferroni nos 7 lags: %d de 26", sum(TT$rec), sum(TT$bon)),
           sprintf("**p1 e p99 (ano inteiro) dentro dos Boundary.knots:** %d de 26", sum(TT$dentro)), "26 de 26 com `status = \"ok\"` no principal; fallback em 0"))
rm(s); invisible(gc())

# ------------------------------------------------------------------ conteúdo da RDS (desvio 66c)
log_msg("conteúdo da RDS")
rds <- readRDS(sai[1]); res_r <- rds$resultados
maior <- function(x) if (is.atomic(x)) length(x) else if (is.list(x) || is.environment(x)) max(c(0, vapply(as.list(x), maior, 0))) else 0
reg("RDS", "26 concentrações, as do cidade_nucleo(), com tag, commit e SHA-256 do código iguais aos do log", 26,
    setequal(names(res_r), ordem) && identical(rds$commit_tag, "caf5022f9a655877d8e3931dd3d02d7dce429fe5") && identical(unname(rds$sha_codigo), unname(sh_tag)))
reg("RDS", "nenhum vetor com tamanho de série diária (máximo < 1.000 elementos; a vcov 16 × 16 tem 256)", 1, maior(rds) < 1000)
chk <- vapply(ordem, function(r) {
  z <- res_r[[r]]$principal; rr <- ref[ref$recorte_principal == r, ]; sp <- z$spec; b <- z$base; dg <- dgcsv[dgcsv$recorte_principal == r, ]
  identical(sp$desfecho, "ptb") && identical(sp$exposicao, "tmean_nucleo") && identical(sp$janela, "janela_principal") && sp$lag == 7 &&
    identical(sp$offset, "z_w_gama") && identical(sp$covariaveis, c("dia_semana", "feriado_nacional", "carnaval", "moveis")) &&
    identical(sp$estrato, "estrato") && is.null(sp$group) && abs(sp$cen - rr$p50) <= 1e-12 &&
    max(abs(b$argvar$knots - c(rr$p10, rr$p75, rr$p90))) <= 1e-12 && max(abs(b$argvar$Boundary.knots - c(dg$bk_min, dg$bk_max))) <= 1e-12 &&
    identical(b$argvar$fun, "ns") && identical(b$arglag$fun, "ns") && max(abs(b$arglag$knots - logknots(7, nk = 2))) <= 1e-12 && isTRUE(b$arglag$intercept) &&
    identical(as.numeric(b$lag), c(0, 7)) && identical(as.numeric(b$df), c(4, 4)) &&
    abs(z$reduzida$cen - rr$p50) <= 1e-12 && abs(z$reduzida$rr_no_cen - 1) <= 1e-10 && is.null(res_r[[r]]$fallback)
}, TRUE)
reg("RDS", "spec, nós e Boundary.knots da base, arglag (nós e intercepto), lag 0–7, df 4 × 4, cen da reduzida = p50 e RR no cen = 1", 26, all(chk))
no_texto("Log", "sinal dos lags sinalizados nas três regras (recalculado dos valores do glm)", sinal_txt)

stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
res <- do.call(rbind, R); n_ok <- sum(res$Resultado == "igual")
md <- c("# Fase 2, Parte C: autoauditoria da primeira etapa", "",
        sprintf("- **Gerado por:** `00_scripts/35_autoauditoria_fase2C.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        sprintf("- **BLAS/LAPACK:** `%s` / `%s`.", si$BLAS, si$LAPACK),
        sprintf("- **sessionInfo() completo:** `%s` (§8).", f_si),
        "- **Método:** os 26 ajustes foram refeitos com `glm(quasipoisson)` + `factor(estrato)` (epsilon 1e-12), sem `ajusta_dlnm()`, com as referências lidas à mão (`readLines`/`strsplit`); a redução, com `crossreduce`; a PACF, com `pacf()` direto nos resíduos de deviance (a janela é contínua). Cada número foi comparado com as saídas e procurado no texto do log com a mesma formatação.",
        sprintf("- **Maiores diferenças** (glm × função): coeficientes da cross-basis %s; vcov 16 × 16 %s; coeficientes reduzidos %s; vcov 4 × 4 %s (relativas); PACF %s (absoluta).",
                formatC(max(TT$cb_coef), format = "e", digits = 1), formatC(max(TT$cb_vcov), format = "e", digits = 1), formatC(max(TT$red_coef), format = "e", digits = 1),
                formatC(max(TT$red_vcov), format = "e", digits = 1), formatC(max(TT$pacf), format = "e", digits = 1)),
        sprintf("- **Tolerâncias** (mudadas depois de ver o resultado: a 1ª rodada deste script deu 2 conferências diferentes sem defeito, e a 2ª só imprimiu as diferenças; os dois logs estão na lixeira, com os SHA-256 no desvio 66): φ, relativa ≤ 1e-6, porque a diferença glm × gnm é ruído de convergência da mesma ordem que a dos coeficientes (φ: %s); nós, cen e Boundary.knots, ≤ 1e-12, porque o `read.csv` do R lê textos de 17 dígitos com até 1 ULP de erro (máx. %s; a RDS guarda os valores exatos).",
                formatC(max(TT$phi), format = "e", digits = 1), formatC(max(c(TT$nos, TT$bk)), format = "e", digits = 1)), "",
        sprintf("## Resultado: %d de %d conferências iguais", n_ok, nrow(res)), "",
        tabela_md(res), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "|", n_ok, "de", nrow(res), "iguais\n")
if (n_ok < nrow(res)) { print(res[res$Resultado != "igual", ]); quit(status = 1) }
