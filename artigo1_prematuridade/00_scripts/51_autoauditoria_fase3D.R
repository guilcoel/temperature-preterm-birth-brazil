# 51_autoauditoria_fase3D.R — Fase 3, Parte D, autoauditoria: refaz com código diferente as contas do 50 e procura os
# números no texto do log do 50, com a mesma formatação. Código diferente (desvio 79(h)):
#   - P1 com o mixmeta chamado direto (sem meta_curva nem wald_curva): predição x̄B̂, vcov e W à mão;
#   - testes do item 2 à mão (splines::ns) em São Paulo e Sorocaba;
#   - réplicas 1, 2, 500 e 1.000 da P2, fixadas no desvio 79(h), refeitas à mão: a sequência de sorteios é regenerada
#     (set.seed uma vez e MASS::mvrnorm na ordem), o mixmeta é chamado direto com o método da réplica, os BLUPs pelo
#     mixmeta::blup, a MRT na grade montada à mão, a AF forward à mão (sem a attrdl) e os RR combinados à mão;
#   - quantis, comparação, falhas e descritivas recalculados do CSV de réplicas.
# Só agregados saem no log. Grava logs/autoauditoria_parteD_fase3_<FASE3_DATA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/51_autoauditoria_fase3D.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("autoauditoria_parteD_fase3_", hoje, ".md")); stopifnot(!file.exists(arq))
suppressPackageStartupMessages({ library(mixmeta); library(splines) })
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
pc <- function(x, d = 2) paste0(br(100 * x, d), "%")
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
R <- list(); reg <- function(item, o_que, n, ok) R[[length(R) + 1]] <<- data.frame(Item = item, `Conferência` = o_que, N = n, Resultado = if (isTRUE(ok)) "igual" else "DIFERENTE", check.names = FALSE)
perto <- function(a, b, tol) { a <- as.numeric(a); b <- as.numeric(b); length(a) == length(b) && all(is.finite(a) == is.finite(b)) && max(abs(a - b)[is.finite(a)], 0) <= tol }
L50 <- paste(readLines(file.path("logs", paste0("posthoc_af_fase3_", hoje, ".md")), encoding = "UTF-8"), collapse = "\n")
no_texto <- function(item, o_que, alvos) reg(item, o_que, length(alvos), all(vapply(alvos, function(a) grepl(a, L50, fixed = TRUE), TRUE)))

# ------------------------------------------------------------------ entradas
OUT <- file.path("01_saidas", "fase3")
f50 <- c(rep = file.path(OUT, paste0("posthoc_p2_replicas_fase3_", hoje, ".csv")), item2 = file.path(OUT, paste0("posthoc_item2_fase3_", hoje, ".csv")),
         rds = file.path(OUT, paste0("posthoc_af_fase3_", hoje, ".rds")))
ok_sha <- all(vapply(f50, function(p) grepl(sprintf("`%s`: `%s`", p, sha(p)), L50, fixed = TRUE), TRUE))
reg("Entradas", "CSV e RDS do 50 com os SHA-256 do log", 3, ok_sha); if (!ok_sha) stop("saídas do 50 diferentes do log")
stopifnot(sha("01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds") == "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d",
          sha("01_saidas/fase1/serie_ptb_principal.rds") == "635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917",
          sha("01_saidas/fase1/referencias_exposicao.csv") == "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467")
r50 <- readRDS(f50[["rds"]]); tab <- utils::read.csv(f50[["rep"]], stringsAsFactors = FALSE); it2 <- utils::read.csv(f50[["item2"]], colClasses = c(recorte_principal = "character"))
r45 <- readRDS(file.path(OUT, "segunda_etapa_principal_fase3_20261013.rds"))
ORDEM <- c("3550308", "3304557", "3106200", "5300108", "2611606", "4314902", "2304400", "4106902", "2927408", "5208707", "3509502", "1302603", "1501402",
           "3205309", "3548500", "3549904", "2111300", "2408102", "2704302", "4205407", "2507507", "2211001", "2800308", "5103403", "3552205", "5002704")
nuc <- as.data.frame(cidade_nucleo()); stopifnot(identical(nuc$CD_RECORTE, ORDEM), identical(r45$ordem, ORDEM)); nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
P1 <- lapply(readRDS("01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds")$resultados[ORDEM], `[[`, "principal")
ref <- utils::read.csv("01_saidas/fase1/referencias_exposicao.csv", colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ORDEM, ref$recorte_principal), ]
md <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1); xb <- c(1, colMeans(md)); X <- kronecker(t(xb), diag(4))
S <- lapply(ORDEM, function(r) unname(P1[[r]]$reduzida$vcov)); Y <- t(vapply(ORDEM, function(r) unname(P1[[r]]$reduzida$coef), numeric(4)))
Bns <- function(z, av) unclass(splines::ns(z, knots = av$knots, Boundary.knots = av$Boundary.knots, intercept = isTRUE(av$intercept)))
grade_mao <- function(a, b) { g <- seq(a, b, by = 0.1); if (b - g[length(g)] > 1e-8) g <- c(g, b); g }

# ------------------------------------------------------------------ P1 à mão
log_msg("P1")
m <- mixmeta(Y ~ media + amplitude, S = S, data = md, method = r45$meta$metodo, bscov = r45$meta$bscov)
b <- drop(X %*% coef(m)); V <- X %*% vcov(m) %*% t(X); W <- drop(t(b) %*% solve(V) %*% b); pW <- 1 - pchisq(W, 4)
reg("P1", "W e p (mixmeta direto, predição x̄B̂ e vcov à mão)", 2, perto(c(W, pW), c(r50$p1$W, r50$p1$p), 1e-8))
no_texto("P1", "W, gl e p no log do 50", sprintf("**W = %s; gl = 4; p = %s**", br(W, 2), formatC(pW, format = "g", digits = 3, decimal.mark = ",")))

# ------------------------------------------------------------------ dados das concentrações
s <- readRDS("01_saidas/fase1/serie_ptb_principal.rds"); s <- as.data.frame(s)[s$data >= as.Date("2012-04-14") & s$data <= as.Date("2024-08-06"), c("recorte_principal", "data", "tmean_nucleo", "ptb")]
D <- lapply(ORDEM, function(r) { z <- s[s$recorte_principal == r, ]; z <- z[order(z$data), ]; g <- r45$grade[r, ]; n <- nrow(z)
  cbar <- vapply(seq_len(n), function(t) if (t + 7 <= n) mean(z$ptb[t:(t + 7)]) else NA_real_, 0)
  list(x = z$tmean_nucleo, y = z$ptb, cbar = cbar, av = P1[[r]]$base$argvar, p1 = g[["p1"]], p99 = g[["p99"]], p2_5 = g[["p2,5"]], p97_5 = g[["p97,5"]]) })
names(D) <- ORDEM; rm(s)
an_mao <- function(d, cf, mrt, rg) { xx <- d$x; if (!is.null(rg)) xx[xx < rg[1] | xx > rg[2]] <- mrt
  af <- 1 - exp(-drop(sweep(Bns(xx, d$av), 2, Bns(mrt, d$av)[1, ]) %*% cf)); an <- af * d$cbar; ok <- !is.na(an); sum(an[ok]) / sum(d$cbar[ok]) * sum(d$y) }

# ------------------------------------------------------------------ testes do item 2 à mão (São Paulo e Sorocaba)
log_msg("item 2")
tb45 <- r45$tmr[r45$tmr$nivel == "blup", ]
for (r in c("3550308", "3552205")) { d <- D[[r]]; cf <- unname(r45$blup[[r]]$coef); mrt <- tb45$tmr[tb45$recorte_principal == r]
  gf <- c(seq(d$p1, d$p99, by = 0.001), d$p99); f <- function(z) drop(Bns(z, d$av) %*% cf); g <- f(mrt) - min(f(gf))
  xd <- d$x[d$x >= d$p1 & d$x <= d$p99]; mdl <- min(f(xd) - f(mrt)); i2 <- it2[it2$recorte_principal == r, ]
  reg("Item 2", sprintf("g e menor Δ_t de %s (splines::ns, à mão)", nome[[r]]), 2, perto(c(g, mdl), c(i2$g, i2$min_delta), 1e-10)) }
reg("Item 2", "contagem de concentrações com o teste (ii) ok e com o diagnóstico de passo 1e-5 ok (CSV × RDS)", 2,
    identical(sum(it2$contribuicoes_ok), sum(r50$item2$contribuicoes_ok)) && identical(sum(it2$ok_passo_1e5), sum(r50$item2$ok_passo_1e5)))

# ------------------------------------------------------------------ réplicas 1, 2, 500 e 1.000 à mão
log_msg("réplicas à mão")
alvo <- c(1L, 2L, 500L, 1000L); th <- list()
set.seed(20261001, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
for (rr in seq_len(max(alvo))) { t1 <- t(vapply(S, function(sg) MASS::mvrnorm(1, rep(0, 4), sg), numeric(4))); if (rr %in% alvo) th[[as.character(rr)]] <- t1 }
eixo <- r45$eixo; base <- r45$base
for (rr in alvo) { lin <- tab[tab$replica == rr, ]; stopifnot(nrow(lin) == 1)
  if (isTRUE(lin$falhou)) { reg("P2", sprintf("réplica %d (falhou no 50; não refeita)", rr), 1, TRUE); next }
  mt <- strsplit(lin$metodo, "/", fixed = TRUE)[[1]]; Yr <- th[[as.character(rr)]]
  mr <- mixmeta(Yr ~ media + amplitude, S = S, data = md, method = mt[1], bscov = mt[2]); bl <- blup(mr)
  an <- matrix(NA_real_, 26, 3); den <- numeric(26); sup <- inf <- logical(26)
  for (k in seq_along(ORDEM)) { d <- D[[ORDEM[k]]]; cf <- unname(bl[k, ]); gg <- grade_mao(d$p1, d$p99); j <- which.min(drop(Bns(gg, d$av) %*% cf)); mrt <- gg[j]
    sup[k] <- j == length(gg); inf[k] <- j == 1
    an[k, ] <- c(an_mao(d, cf, mrt, NULL), an_mao(d, cf, mrt, c(mrt, Inf)), an_mao(d, cf, mrt, c(-Inf, mrt))); den[k] <- sum(d$y) }
  pcf <- drop(X %*% coef(mr)); gc <- grade_mao(eixo[["p1"]], eixo[["p99"]]); mc <- gc[which.min(drop(Bns(gc, base) %*% pcf))]
  rrc <- exp(drop(sweep(Bns(unname(eixo[c("p99", "p1")]), base), 2, Bns(mc, base)[1, ]) %*% pcf))
  ok <- perto(colSums(an) / sum(den), c(lin$af_total, lin$af_calor, lin$af_frio), 1e-10) && perto(c(mc, rrc), c(lin$tmr_combinada, lin$rr_x99, lin$rr_x1), 1e-10) &&
        lin$n_mrt_p99 == sum(sup) && lin$n_mrt_p1 == sum(inf)
  reg("P2", sprintf("réplica %d refeita à mão (sorteios regenerados, mixmeta direto, MRT na grade, AF forward e RR combinados à mão)", rr), 1, ok) }

# ------------------------------------------------------------------ resumo da P2 recalculado do CSV
log_msg("resumo")
# o CSV foi gravado com sprintf("%.17g"), e a leitura de texto pode errar 1 ulp: o CSV é conferido contra a RDS no texto,
# em igualdade exata, e os quantis são recalculados dos valores da RDS (1ª rodada do 51: descritivas diferindo em 1 ulp)
t17 <- function(v) ifelse(is.na(v), NA_character_, sprintf("%.17g", v)); tabt <- utils::read.csv(f50[["rep"]], colClasses = "character")
num_cols <- c("af_total", "af_calor", "af_frio", "rr_x99", "rr_x1", "tmr_combinada")
reg("P2", "CSV de réplicas igual à tabela da RDS (texto %.17g, igualdade exata; colunas numéricas, falhas e métodos)", length(num_cols) + 2,
    all(vapply(num_cols, function(v) identical(ifelse(tabt[[v]] == "", NA_character_, tabt[[v]]), t17(r50$p2[[v]])), TRUE)) &&
    identical(as.logical(tabt$falhou), r50$p2$falhou) && identical(tabt$metodo, r50$p2$metodo))
tab <- r50$p2
okr <- !tab$falhou; q <- quantile(tab$af_total[okr], c(0.5, 0.025, 0.975), type = 7, names = FALSE); af_obs <- r50$af_obs
a46 <- utils::read.csv(file.path(OUT, "fracao_atribuivel_fase3_20261013.csv"), colClasses = c(recorte_principal = "character"))
reg("P2", "AF observada = AF total do principal no CSV do 46", 1, perto(af_obs, a46$af[a46$analise == "principal" & a46$recorte_principal == "total" & a46$componente == "total"], 0))
reg("P2", "número de réplicas e de falhas", 2, nrow(tab) == 1000 && sum(tab$falhou) == r50$resumo$n_falhas)
reg("P2", "mediana, p2,5 e p97,5 da AF total nula e a comparação", 4, perto(q, r50$resumo$af_total, 0) && identical(af_obs > q[3], r50$resumo$passa))
no_texto("P2", "AF observada, distribuição nula e comparação no log do 50", sprintf("**Única comparação:** AF total observada (principal) %s contra a distribuição nula: mediana %s (p2,5 a p97,5: %s a %s). A AF observada **%s** o p97,5.",
         pc(af_obs), pc(q[1]), pc(q[2]), pc(q[3]), if (af_obs > q[3]) "passa" else "não passa"))
desc <- vapply(c("af_calor", "af_frio", "rr_x99", "rr_x1", "n_mrt_p99", "n_mrt_p1"), function(v) quantile(tab[[v]][okr], c(0.5, 0.025, 0.975), type = 7, names = FALSE), numeric(3))
reg("P2", "descritivas (calor, frio, RR no x99 e no x1, MRT no p99 e no p1)", 6,
    perto(as.vector(desc), as.vector(t(as.matrix(r50$resumo$descritivas[, c("mediana", "p2_5", "p97_5")]))), 0))
reg("P2", "observado: 10 MRT BLUP no p99 e nenhuma no p1", 2, r50$obs_desc[["n_mrt_p99"]] == 10 && r50$obs_desc[["n_mrt_p1"]] == 0)

stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
res <- do.call(rbind, R); n_ok <- sum(res$Resultado == "igual")
md_txt <- c("# Fase 3, Parte D: autoauditoria", "",
            sprintf("- **Gerado por:** `00_scripts/51_autoauditoria_fase3D.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
            sprintf("- **BLAS/LAPACK:** `%s` / `%s`.", sessionInfo()$BLAS, sessionInfo()$LAPACK),
            "- **Método:** as contas do 50 refeitas com código diferente e comparadas com as saídas (CSV e RDS, com os SHA-256 do log); os números refeitos foram procurados no texto do log com a mesma formatação.",
            "- **Código diferente:** P1 com o `mixmeta` chamado direto e W à mão; testes do item 2 com `splines::ns`; réplicas 1, 2, 500 e 1.000 (fixadas no desvio 79(h)) com a sequência de sorteios regenerada, o `mixmeta` direto, a MRT na grade montada à mão, a AF *forward* à mão (sem a `attrdl`) e os RR combinados à mão; CSV de réplicas conferido contra a RDS no texto `%.17g`; quantis e comparação recalculados dos valores da RDS.",
            "- **Tolerâncias:** 1e-8 a 1e-10, conforme a escala; quantis e textos com igualdade exata.", "",
            sprintf("## Resultado: %d de %d conferências iguais", n_ok, nrow(res)), "", tabela_md(res), "",
            sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md_txt, arq, useBytes = TRUE)
cat("gravado:", arq, "|", n_ok, "de", nrow(res), "iguais\n")
