# 71_autoauditoria_c1_fase4.R — Fase 4, Parte C1: autoauditoria com código diferente (mensagem da C1 do chat do A1,
# 18/10/2026, item 3; plano da Fase 4, script 71). Refaz, sem a ajusta_dlnm nem a segunda_etapa:
#   a. chave 3: glm quasi-Poisson montado à mão (crossbasis do dlnm sobre as 4.505 linhas; ns(data numérica, df = 99) só
#      nos dias do ajuste; calendário; log_w; offset log_z), em 2 concentrações; coeficientes e vcov da cross-basis;
#   b. chave 5: offset calculado à mão, log(Σ_j Z_tj·w_j) a partir de z22…z36 e do w_j do CSV da Fase 1, e gnm com
#      eliminate = estrato (estratos sem evento fora), em 2 concentrações;
#   c. chave 1: gnm à mão numa concentração (municípios empilhados, crossbasis com group = CD_MUN6, eliminate =
#      estrato_mun, offset log_z, log_w como covariável, dias com Z_t = 0 e estratos sem evento fora);
#   d. TMR e RR de uma chave (a 5) por crosspred direto: onebasis com a argvar da base combinada, crosspred(model.link =
#      "log") na grade de 0,1 °C entre x1 e x99 do eixo, mínimo pelo allfit; RR no x99 e no x1 contra essa TMR.
#   Tolerâncias: coeficientes e vcov ≤ 1e-6 relativo ao maior valor absoluto (o glm/gnm à mão para pelo mesmo critério
#   de convergência, mas com outra ordem de colunas); TMR igual (mesma grade); RR ≤ 1e-8.
# Lê o RDS do 70 e as séries da Fase 1 e da B1 (SHA-256 conferido contra os logs). Grava
#   logs/autoauditoria_c1_fase4_<RODADA>.md. Nunca sobrescreve. Divergência: grava o log e quit(status = 1).
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD RODADA70=AAAAMMDD Rscript 00_scripts/71_autoauditoria_c1_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); r70 <- Sys.getenv("RODADA70"); stopifnot(grepl("^[0-9]{8}$", rodada), grepl("^[0-9]{8}$", r70))
arq <- file.path("logs", paste0("autoauditoria_c1_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/71_autoauditoria_c1_fase4.R"
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
sujos <- git("status", "--porcelain", "--", ESTE)
if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current")
st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:")
inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"); t0 <- Sys.time()
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(splines) })

f70 <- file.path("01_saidas", "fase4", paste0("c1_chaves_fase4_", r70, ".rds")); log70 <- file.path("logs", paste0("c1_chaves_fase4_", r70, ".md"))
sha70 <- sha(f70); ok_sha70 <- any(grepl(sha70, readLines(log70, encoding = "UTF-8"), fixed = TRUE))
R <- readRDS(f70); res <- R$resultados
s4 <- readRDS("01_saidas/fase4/serie_ptb_fase4.rds"); mun <- readRDS("01_saidas/fase1/serie_ptb_municipal.rds")
wj <- utils::read.csv("01_saidas/fase1/wj_ptb_concentracao.csv", colClasses = c(recorte_principal = "character"))
ref <- utils::read.csv("01_saidas/fase1/referencias_exposicao.csv", colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]
INI <- as.Date("2012-04-07"); FIM <- as.Date("2024-08-06"); AL <- list(fun = "ns", knots = logknots(7, nk = 2), intercept = TRUE)
CAL <- "dia_semana + feriado_nacional + carnaval + moveis"
rel <- function(a, b) max(abs(a - b)) / max(abs(b))
comp <- function(fit_cf, fit_v, z) c(coef = rel(fit_cf, z$coef_cb), vcov = rel(fit_v, z$vcov_cb))
linhas <- list()

serie_r <- function(r) { x <- as.data.frame(s4)[s4$recorte_principal == r & s4$data >= INI & s4$data <= FIM, ]; x[order(x$data), ] }
cb_de <- function(x, rr, ...) crossbasis(x, lag = 7, argvar = list(fun = "ns", knots = c(rr$p10, rr$p75, rr$p90)), arglag = AL, ...)
# a. chave 3: glm à mão
for (r in c("3550308", "2800308")) {
  x <- serie_r(r); rr <- ref[ref$recorte_principal == r, ]; cb <- cb_de(x$tmean_nucleo, rr)
  u <- x$janela_principal & stats::complete.cases(unclass(cb)) & is.finite(x$log_z) & is.finite(x$log_w)
  tn <- as.numeric(x$data[u]); NS <- ns(tn, df = 99)
  dfm <- data.frame(y = x$ptb[u], ds = x$dia_semana[u], fn = x$feriado_nacional[u], ca = x$carnaval[u], mv = x$moveis[u], lw = x$log_w[u], lz = x$log_z[u])
  m <- glm(y ~ unclass(cb)[u, ] + NS + ds + fn + ca + mv + lw + offset(lz), family = quasipoisson, data = dfm)
  k <- grep("^unclass", names(coef(m))); z <- res$chave3$fits[[r]]
  d <- comp(unname(coef(m)[k]), unname(vcov(m)[k, k]), z); linhas[[length(linhas) + 1]] <- data.frame(Item = paste0("a. Chave 3 por glm à mão, ", r), coef = d[["coef"]], vcov = d[["vcov"]])
}
# b. chave 5: offset à mão
for (r in c("3106200", "5002704")) {
  x <- serie_r(r); rr <- ref[ref$recorte_principal == r, ]; cb <- cb_de(x$tmean_nucleo, rr)
  w <- setNames(wj$w_j[wj$recorte_principal == r], wj$j[wj$recorte_principal == r]); Z <- as.matrix(x[, paste0("z", 22:36)])
  off <- log(drop(Z %*% w[as.character(22:36)]))
  u <- x$janela_principal & stats::complete.cases(unclass(cb)) & is.finite(off)
  ev <- tapply(x$ptb[u], x$estrato[u], sum); u <- u & !(x$estrato %in% names(ev)[ev == 0])
  m <- gnm(x$ptb[u] ~ unclass(cb)[u, ] + x$dia_semana[u] + x$feriado_nacional[u] + x$carnaval[u] + x$moveis[u], offset = off[u],
           eliminate = factor(x$estrato[u]), family = quasipoisson, verbose = FALSE)
  k <- 1:16; z <- res$chave5$fits[[r]]
  d <- comp(unname(coef(m)[k]), unname(vcov(m)[k, k]), z); linhas[[length(linhas) + 1]] <- data.frame(Item = paste0("b. Chave 5 com offset à mão, ", r), coef = d[["coef"]], vcov = d[["vcov"]])
}
# c. chave 1: gnm à mão numa concentração (Aracaju)
r <- "2800308"; x <- as.data.frame(mun)[mun$recorte_principal == r & mun$data >= INI & mun$data <= FIM, ]; x <- x[order(x$CD_MUN6, x$data), ]
pm <- R$resultados$chave1$fits[[r]]$base$argvar
cb <- crossbasis(x$tmean_mun, lag = 7, argvar = list(fun = "ns", knots = pm$knots), arglag = AL, group = x$CD_MUN6)
u <- x$linha_modelo & stats::complete.cases(unclass(cb)) & is.finite(x$log_z) & is.finite(x$log_w)
ev <- tapply(x$ptb[u], x$estrato_mun[u], sum); u <- u & !(x$estrato_mun %in% names(ev)[ev == 0])
m <- gnm(x$ptb[u] ~ unclass(cb)[u, ] + x$dia_semana[u] + x$feriado_nacional[u] + x$carnaval[u] + x$moveis[u] + x$log_w[u], offset = x$log_z[u],
         eliminate = factor(x$estrato_mun[u]), family = quasipoisson, verbose = FALSE)
z <- res$chave1$fits[[r]]; d <- comp(unname(coef(m)[1:16]), unname(vcov(m)[1:16, 1:16]), z)
ok_bk <- isTRUE(all.equal(attr(cb, "argvar")$Boundary.knots, pm$Boundary.knots, tolerance = 0))
linhas[[length(linhas) + 1]] <- data.frame(Item = paste0("c. Chave 1 por gnm à mão, ", r, " (Boundary.knots iguais: ", if (ok_bk) "sim" else "NÃO", ")"), coef = d[["coef"]], vcov = d[["vcov"]])
# d. TMR e RR da chave 5 por crosspred direto
c5 <- res$chave5; eixo <- readRDS("01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds")$eixo
g <- seq(eixo[["p1"]], eixo[["p99"]], by = 0.1); if (max(g) < eixo[["p99"]] - 1e-9) g <- c(g, eixo[["p99"]])
ob <- do.call(onebasis, c(list(x = g), c5$base)); pc <- c5$meta$pred_media$coef; pv <- c5$meta$pred_media$vcov
cp0 <- crosspred(ob, coef = pc, vcov = pv, model.link = "log", at = g, cen = mean(g))
tmr_cp <- g[which.min(cp0$allfit)]
ob2 <- do.call(onebasis, c(list(x = unname(eixo[c("p99", "p1")])), c5$base))
cp <- crosspred(ob2, coef = pc, vcov = pv, model.link = "log", at = unname(eixo[c("p99", "p1")]), cen = tmr_cp)
rr_cp <- unname(cp$allRRfit[as.character(unname(eixo[c("p99", "p1")]))])
d_tmr <- abs(tmr_cp - c5$tmr$tmr); d_rr <- max(abs(rr_cp - c5$curva$rr))

tab <- do.call(rbind, linhas)
ok <- ok_sha70 && all(tab$coef <= 1e-6) && all(tab$vcov <= 1e-6) && d_tmr == 0 && d_rr <= 1e-8 && ok_bk
md <- c("# Fase 4, Parte C1: autoauditoria com código diferente", "",
  sprintf("- **Gerado por:** `00_scripts/71_autoauditoria_c1_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`; RDS do 70 da rodada `%s` (SHA-256 `%s`, %s no log do 70).",
          sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, r70, sha70, if (ok_sha70) "igual ao" else "DIFERENTE do"),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"), "",
  "## Coeficientes e vcov da cross-basis (diferença relativa ao maior valor absoluto; tolerância 1e-6)", "",
  tabela_md(data.frame(Item = tab$Item, Coeficientes = formatC(tab$coef, format = "e", digits = 1), vcov = formatC(tab$vcov, format = "e", digits = 1), check.names = FALSE)), "",
  "## TMR e RR da chave 5 por `crosspred` direto", "",
  sprintf("- TMR: crosspred %s °C; 70 %s °C (diferença %s). RR no x99 e no x1: diferença máxima %s.", br(tmr_cp, 1), br(c5$tmr$tmr, 1), format(d_tmr), formatC(d_rr, format = "e", digits = 1)), "",
  sprintf("- **Resultado:** %s. Tempo: %.1f min.", if (ok) "nenhuma divergência" else "DIVERGÊNCIA (ver as tabelas)", as.numeric(difftime(Sys.time(), t0, units = "mins"))), "")
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| ok:", ok, "\n")
if (!ok) quit(status = 1)
