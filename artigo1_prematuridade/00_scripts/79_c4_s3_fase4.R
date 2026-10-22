# 79_c4_s3_fase4.R — Fase 4, Parte C4: S3, DLNM penalizado (mensagem "C2, C3 e C4 em lote", 19/10/2026, item 79; D11,
# 5.2; plano, script 79). ajusta_s3() da sens_agudos v1.0 (tag) por concentração: mgcv::gam(y ~ s(Q, L, bs = "cb", k =
# c(10, 8), xt = list(bs = "ps")) + estrato + calendário + log_w + offset(log_z), quasipoisson, REML), janela principal
# com 7 dias de aquecimento; log RR cumulativo no p99 e no p1 da concentração (grade da A0) contra a referência = quantil
# da tmean_nucleo de 2012–2024 da concentração no q da TMR combinada do primário (lido do RDS do 45). Concentração que não
# convergir sai da 2ª etapa, com registro. 2ª etapa: meta_univariada (REML, média + amplitude) no p99 e no p1, com
# predição na média dos metapreditores; RR combinado com IC.
# Saída (fora do git): 01_saidas/fase4/c4_s3_fase4_<RODADA>.rds e .csv. Log logs/c4_s3_fase4_<RODADA>.md.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/79_c4_s3_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("c4_s3_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
f_out <- c(rds = file.path("01_saidas", "fase4", paste0("c4_s3_fase4_", rodada, ".rds")), csv = file.path("01_saidas", "fase4", paste0("c4_s3_fase4_", rodada, ".csv"))); for (p in f_out) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/79_c4_s3_fase4.R"; CC <- file.path(REPO, "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
icf <- function(a, li, ls, d = 3) sprintf("%s (%s a %s)", br(a, d), br(li, d), br(ls, d))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
sujos <- git("status", "--porcelain", "--", ESTE); if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current"); st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:"); inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"); t0 <- Sys.time()
s_info <- sessionInfo(); if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib")) stop("BLAS/LAPACK fora da referência (§8)")
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
COD <- c("codigo_compartilhado/R/segunda_etapa.R" = "segunda_etapa-v1.1", "codigo_compartilhado/R/sens_agudos.R" = "sens_agudos-v1.0")
sha_cod <- vapply(names(COD), function(p) sha(file.path(REPO, p)), ""); for (p in names(COD)) if (!identical(sha_cod[[p]], tag_sha(COD[[p]], p))) stop(p, " difere da tag")
ENT <- c(s4 = "01_saidas/fase4/serie_ptb_fase4.rds", rds45 = "01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds", ref = "01_saidas/fase1/referencias_exposicao.csv")
SHA_ENT <- c(s4 = "e70190c1bf7c0fa5ba9c9f1e3cacb46f1ef8d647fc04a8606d181f7c819793e0", rds45 = "52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e", ref = "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467")
sha_ent <- vapply(ENT, sha, ""); if (!identical(unname(sha_ent), unname(SHA_ENT))) stop("entrada com SHA-256 diferente do registrado")
suppressPackageStartupMessages({ library(dlnm); library(mgcv); library(mixmeta) })
f <- new.env(); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f); sys.source(file.path(CC, "R", "sens_agudos.R"), envir = f)
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
r45 <- readRDS(ENT[["rds45"]]); q_tmr <- r45$tmr$percentil_tmr[r45$tmr$nivel == "combinada"]; stopifnot(length(q_tmr) == 1, q_tmr > 0, q_tmr < 1, isTRUE(all.equal(q_tmr, r45$q_tmr, tolerance = 0)))
ref <- utils::read.csv(ENT[["ref"]], colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8"); ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ordem, ref$recorte_principal), ]
md <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1, row.names = ordem)
INI <- as.Date("2012-04-07"); FIM <- as.Date("2024-08-06"); s4 <- as.data.frame(readRDS(ENT[["s4"]])); s4 <- s4[s4$data >= INI & s4$data <= FIM, ]
sdr <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_nucleo"))); sdr$data <- as.Date(sdr$data)
sdr <- sdr[sdr$data >= as.Date("2012-01-01") & sdr$data <= as.Date("2024-12-31"), ]
CAL <- c("dia_semana", "feriado_nacional", "carnaval", "moveis")
por <- list()
for (r in ordem) { tk <- Sys.time()
  x <- s4[s4$recorte_principal == r, ]; x <- x[order(x$data), ]; stopifnot(nrow(x) == 4505L, all(diff(x$data) == 1))
  g <- r45$grade[r, ]; cen <- unname(stats::quantile(sdr$tmean_nucleo[sdr$recorte_principal == r], q_tmr, type = 7))
  z <- tryCatch(f$ajusta_s3(x, at = unname(g[c("p99", "p1")]), cen = cen, desfecho = "ptb", exposicao = "tmean_nucleo", janela = "janela_principal", estrato = "estrato", covariaveis = CAL),
                error = function(e) list(status = "falhou", mensagem = conditionMessage(e)))
  por[[r]] <- data.frame(recorte_principal = r, concentracao = nome[[r]], status = z$status, mensagem = z$mensagem, cen = cen, p99 = g[["p99"]], p1 = g[["p1"]],
                         logrr99 = if (identical(z$status, "ok")) z$logrr[1] else NA, ep99 = if (identical(z$status, "ok")) z$ep[1] else NA,
                         logrr01 = if (identical(z$status, "ok")) z$logrr[2] else NA, ep01 = if (identical(z$status, "ok")) z$ep[2] else NA,
                         edf = if (identical(z$status, "ok")) z$edf_s else NA, phi = if (identical(z$status, "ok")) z$phi else NA, segundos = as.numeric(difftime(Sys.time(), tk, units = "secs")), stringsAsFactors = FALSE)
  log_msg(nome[[r]], z$status)
}
por <- do.call(rbind, por); inc <- por$status == "ok"
m99 <- f$meta_univariada(por$logrr99[inc], por$ep99[inc]^2, md[inc, , drop = FALSE]); m01 <- f$meta_univariada(por$logrr01[inc], por$ep01[inc]^2, md[inc, , drop = FALSE])
comb <- function(m) c(rr = exp(m$estimativa), li = exp(m$estimativa - 1.96 * m$ep), ls = exp(m$estimativa + 1.96 * m$ep))
c99 <- comb(m99); c01 <- comb(m01)
saveRDS(list(por_concentracao = por, meta_p99 = m99, meta_p1 = m01, q_tmr = q_tmr, sha_codigo = sha_cod, sha_entradas = sha_ent, rodada = rodada), f_out[["rds"]])
utils::write.csv(por, f_out[["csv"]], row.names = FALSE, fileEncoding = "UTF-8"); sha_out <- vapply(f_out, sha, "")
stopifnot(versao() == "4443971b")
md_txt <- c("# Fase 4, Parte C4: S3, DLNM penalizado (D11, 5.2)", "",
  sprintf("- **Gerado por:** `00_scripts/79_c4_s3_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()`: %s.", sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  "- **Código (igual ao das tags):**", sprintf("  - `%s`: `%s` (`%s`);", names(sha_cod), sha_cod, COD), sprintf("- **Entradas (SHA-256 = registrados):** %s.", paste(sprintf("`%s` (`%s`)", ENT, sha_ent), collapse = "; ")),
  sprintf("- **Referência:** quantil q = %s (TMR combinada do primário, lido do RDS do 45) da tmean_nucleo de 2012–2024 de cada concentração; contrastes no p99 e no p1 da concentração.", formatC(q_tmr, format = "f", digits = 4, decimal.mark = ",")), "",
  "## Combinado (meta univariada REML, média + amplitude, predição na média)", "",
  sprintf("- **Concentrações na 2ª etapa:** %d de 26%s.", sum(inc), if (any(!inc)) paste0("; fora: ", paste(sprintf("%s (%s)", por$concentracao[!inc], por$mensagem[!inc]), collapse = "; ")) else ""),
  sprintf("- **RR no p99 contra a referência:** %s. **RR no p1:** %s.", icf(c99[["rr"]], c99[["li"]], c99[["ls"]]), icf(c01[["rr"]], c01[["li"]], c01[["ls"]])),
  sprintf("- **τ² e I²:** p99 τ² = %s, Q = %s (%d gl); p1 τ² = %s, Q = %s (%d gl).", formatC(m99$tau2, format = "e", digits = 2), br(m99$heterogeneidade$residual$Q, 1), as.integer(m99$heterogeneidade$residual$df),
          formatC(m01$tau2, format = "e", digits = 2), br(m01$heterogeneidade$residual$Q, 1), as.integer(m01$heterogeneidade$residual$df)), "",
  "## Por concentração", "",
  tabela_md(data.frame(Concentração = por$concentracao, Status = por$status, `RR p99` = ifelse(inc, br(exp(por$logrr99), 3), "—"), `RR p1` = ifelse(inc, br(exp(por$logrr01), 3), "—"),
                       `edf do termo` = ifelse(inc, br(por$edf, 1), "—"), φ = ifelse(inc, br(por$phi, 3), "—"), Segundos = br(por$segundos, 0), check.names = FALSE)), "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", f_out, sha_out), "", sprintf("- **Resultado:** ok. Tempo: %.1f min.", as.numeric(difftime(Sys.time(), t0, units = "mins"))), "")
writeLines(md_txt, arq, useBytes = TRUE); cat("gravado:", arq, "| incluídas:", sum(inc), "\n")
