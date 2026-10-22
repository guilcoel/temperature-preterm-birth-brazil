# 73_tmr_p10p90_fase4.R — Fase 4, Parte C2, TMR: IC bootstrap da busca entre p10 e p90 nas 10 concentrações com a TMR BLUP
# no p99 (mensagem "C2, C3 e C4 em lote", 19/10/2026, item 73; P2 do plano; D8, 1.2(c); errata da D8, opção (i); D16,
# item 4: nada na combinada). Usa só o RDS do 45 e a argvar do 32; nenhum ajuste novo.
# Por concentração i (na ordem travada), com os coeficientes e a vcov BLUP do 45:
#   - controle positivo antes: boot_tmr(…, i) reproduz com identical() o IC da TMR do 45 (ic_li, ic_ls);
#   - os mesmos sorteios: semeia(i), Cholesky da vcov e 1.000 sorteios, como dentro da boot_tmr (conferido: a TMR de cada
#     sorteio na grade p1–p99 é identical à tmr_sim da boot_tmr);
#   - em cada sorteio, o mínimo da curva na grade de 0,1 °C entre o p10 e o p90 da concentração; IC = quantis 2,5% e 97,5%
#     (type = 7); ponto = tmr_p10_p90 da busca_tmr (conferido contra o 45).
# Saídas (fora do git): 01_saidas/fase4/tmr_p10p90_fase4_<RODADA>.csv. Log logs/tmr_p10p90_fase4_<RODADA>.md.
# Nunca sobrescreve. Confere antes: script commitado e limpo; código igual ao das tags; SHA-256 das entradas.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/73_tmr_p10p90_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("tmr_p10p90_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
f_csv <- file.path("01_saidas", "fase4", paste0("tmr_p10p90_fase4_", rodada, ".csv")); stopifnot(!file.exists(f_csv))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/73_tmr_p10p90_fase4.R"; CC <- file.path(REPO, "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
sujos <- git("status", "--porcelain", "--", ESTE); if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current"); st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:"); inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
sha_se <- sha(file.path(CC, "R", "segunda_etapa.R")); if (!identical(sha_se, tag_sha("segunda_etapa-v1.1", "codigo_compartilhado/R/segunda_etapa.R"))) stop("segunda_etapa.R difere da tag")
ENT <- c(rds32 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", rds45 = "01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds")
SHA_ENT <- c(rds32 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d", rds45 = "52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e")
sha_ent <- vapply(ENT, sha, ""); if (!identical(unname(sha_ent), unname(SHA_ENT))) stop("entrada com SHA-256 diferente do registrado")
suppressPackageStartupMessages({ library(dlnm); library(mixmeta) })
f <- new.env(); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f)
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
idx <- setNames(f$indice_concentracao(ordem), ordem)
rds32 <- readRDS(ENT[["rds32"]])$resultados; r45 <- readRDS(ENT[["rds45"]])
tb <- r45$tmr[r45$tmr$nivel == "blup", ]
alvo <- tb$recorte_principal[tb$fronteira & abs(tb$tmr - tb$x_sup) < 1e-9]
stopifnot(length(alvo) == 10L)
res <- do.call(rbind, lapply(alvo, function(r) {
  i <- idx[[r]]; b <- r45$blup[[r]]; av <- rds32[[r]]$principal$base$argvar; g <- r45$grade[r, ]; t45 <- tb[tb$recorte_principal == r, ]
  bc <- f$boot_tmr(b$coef, b$vcov, av, g[["p1"]], g[["p99"]], i = i)
  ok_ic <- identical(bc$ic, c(t45$ic_li, t45$ic_ls))
  k <- length(b$coef); R <- chol(b$vcov); f$semeia(i); sims <- b$coef + t(R) %*% matrix(stats::rnorm(k * 1000L), k)
  g1 <- f$grade_tmr(g[["p1"]], g[["p99"]]); tm1 <- g1[apply(f$.base_x(g1, av) %*% sims, 2, which.min)]
  ok_sims <- identical(tm1, bc$tmr_sim)
  g2 <- f$grade_tmr(g[["p10"]], g[["p90"]]); tm2 <- g2[apply(f$.base_x(g2, av) %*% sims, 2, which.min)]
  bt <- f$busca_tmr(b$coef, av, g[["p1"]], g[["p99"]], g[["p10"]], g[["p90"]], g[["p50"]])
  data.frame(recorte_principal = r, concentracao = nome[[r]], i = i, tmr_blup = t45$tmr, controle_ic_identical = ok_ic, mesmos_sorteios_identical = ok_sims,
             busca_p10_p90 = bt$tmr_p10_p90, busca_igual_45 = isTRUE(all.equal(bt$tmr_p10_p90, t45$tmr_p10_p90, tolerance = 0)), p10 = g[["p10"]], p90 = g[["p90"]],
             ic_li = unname(stats::quantile(tm2, 0.025, type = 7)), ic_ls = unname(stats::quantile(tm2, 0.975, type = 7)),
             prop_p10 = mean(tm2 == g2[1]), prop_p90 = mean(tm2 == g2[length(g2)]), stringsAsFactors = FALSE)
}))
ok <- all(res$controle_ic_identical) && all(res$mesmos_sorteios_identical) && all(res$busca_igual_45)
if (ok) utils::write.csv(res, f_csv, row.names = FALSE, fileEncoding = "UTF-8")
stopifnot(versao() == "4443971b")
md <- c("# Fase 4, Parte C2: IC bootstrap da busca da TMR entre p10 e p90 (10 concentrações com a TMR BLUP no p99)", "",
  sprintf("- **Gerado por:** `00_scripts/73_tmr_p10p90_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()`: %s.", sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Código:** `segunda_etapa.R` `%s` (igual ao da tag `segunda_etapa-v1.1`). **Entradas (SHA-256 = registrados):** %s.", sha_se, paste(sprintf("`%s` (`%s`)", ENT, sha_ent), collapse = "; ")),
  "- **Na combinada:** nada (a TMR combinada é interior; D16, item 4).", "",
  "## Controles", "",
  sprintf("- IC da TMR da Fase 3 reproduzido com `identical()`: %d de 10. Sorteios iguais aos da `boot_tmr` (TMR de cada sorteio `identical`): %d de 10. Ponto da busca igual ao do 45: %d de 10.",
          sum(res$controle_ic_identical), sum(res$mesmos_sorteios_identical), sum(res$busca_igual_45)), "",
  "## Busca entre p10 e p90 (°C), com IC bootstrap (1.000 sorteios, semente 20261001 + i)", "",
  tabela_md(data.frame(Concentração = res$concentracao, i = res$i, `TMR BLUP (p99)` = br(res$tmr_blup, 1), `p10–p90 da concentração` = sprintf("%s a %s", br(res$p10, 1), br(res$p90, 1)),
                       `Busca p10–p90` = br(res$busca_p10_p90, 1), `IC 95%` = sprintf("%s a %s", br(res$ic_li, 1), br(res$ic_ls, 1)),
                       `Sorteios no p10 / no p90` = sprintf("%s%% / %s%%", br(100 * res$prop_p10, 1), br(100 * res$prop_p90, 1)), check.names = FALSE)), "",
  sprintf("- **Saída (fora do git):** `%s`: `%s`.", f_csv, if (ok) sha(f_csv) else "(não gravado)"),
  sprintf("- **Resultado:** %s.", if (ok) "controles ok" else "FALHA nos controles: PARE"), "")
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| ok:", ok, "\n")
if (!ok) quit(status = 1)
