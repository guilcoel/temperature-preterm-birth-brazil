# 72_d3_residuos_defasados_fase4.R — Fase 4, Parte C2, D3: resíduos defasados e PACF (mensagem "C2, C3 e C4 em lote",
# 19/10/2026, item 72; decisões de 13/10, D3; D16, item 2; complemento, C1 item 4 e C2 item 3; novo modo de trabalho).
# 1. Por concentração, o principal é reajustado com a ajusta_dlnm v1.1 (spec do 32), com devolve_residuos e
#    devolve_matriz; conferência: coeficientes e vcov iguais aos do 32 (≤ 1e-10).
# 2. PACF dos resíduos de deviance do principal, lags 1 a 7, só descritivas (suplemento):
#    - observada: pacf_grade (série posta na grade dos 4.498 dias da janela, 0 fora do ajuste);
#    - literal: fora de ±2/√n, n = dias do ajuste;
#    - recentrada: observada − média da nula, com a faixa de 2,5% a 97,5% da nula (nula_pacf: 1.000 séries de ruído
#      branco gaussiano nas linhas do ajuste, projetadas fora do desenho completo por mínimos quadrados PONDERADOS com os
#      pesos de trabalho finais, D16, item 2; semente 20261001 + i, com o kind explícito); testes: max|W − μ̂|/μ̂ < 1e-8 e
#      max|X′W^{1/2}e*| ≤ 1e-10 × escala.
# 3. D3, sensibilidade: os resíduos de deviance do próprio principal defasados nos lags 1 a 7, na série completa (0 fora
#    do ajuste e antes do início), entram de uma vez como coluna-matriz (res_lag) no principal; as duas etapas refeitas
#    pelo fluxo comum (fluxo_c_fase4.R: fallback da D7, M7, φ, teste 3, meta_curva, TMR com IC bootstrap, RR no x99 e
#    no x1); também os RR por concentração (BLUP no p99 e no p1 da concentração contra a TMR BLUP, com IC).
# Saídas (fora do git): 01_saidas/fase4/d3_fase4_<RODADA>.rds e pacf_d3_fase4_<RODADA>.csv (suplemento; só PACF, sem
#   dado diário). Log logs/d3_fase4_<RODADA>.md. Nunca sobrescreve. Confere antes: script e módulo commitados e limpos;
#   código igual ao das tags; SHA-256 das entradas = registrados; BLAS/LAPACK de referência.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/72_d3_residuos_defasados_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("d3_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase4"); f_out <- c(rds = file.path(OUT, paste0("d3_fase4_", rodada, ".rds")), pacf = file.path(OUT, paste0("pacf_d3_fase4_", rodada, ".csv")))
for (p in f_out) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/72_d3_residuos_defasados_fase4.R"; MOD <- "artigo1_prematuridade/00_scripts/fluxo_c_fase4.R"
CC <- file.path(REPO, "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
icf <- function(a, li, ls, d = 3) sprintf("%s (%s a %s)", br(a, d), br(li, d), br(ls, d))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
escreve_csv <- function(df, p) { num <- vapply(df, is.double, TRUE); df[num] <- lapply(df[num], function(v) ifelse(is.na(v), NA, sprintf("%.17g", v)))
  utils::write.csv(df, p, row.names = FALSE, na = "", fileEncoding = "UTF-8") }

sujos <- git("status", "--porcelain", "--", ESTE, MOD)
if (length(sujos)) { cat(sujos, sep = "\n"); stop("script ou módulo com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current")
st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:")
inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"); t0 <- Sys.time()
s_info <- sessionInfo(); if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib")) stop("BLAS/LAPACK fora da referência (§8)")
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
COD <- c("codigo_compartilhado/R/ajusta_dlnm.R" = "ajusta_dlnm-v1.1", "codigo_compartilhado/R/segunda_etapa.R" = "segunda_etapa-v1.1",
         "codigo_compartilhado/R/sens_agudos.R" = "sens_agudos-v1.0", "codigo_compartilhado/tests/teste3_fonte_independente.R" = "segunda_etapa-v1.1")
sha_cod <- vapply(names(COD), function(p) sha(file.path(REPO, p)), ""); for (p in names(COD)) if (!identical(sha_cod[[p]], tag_sha(COD[[p]], p))) stop(p, " difere da tag ", COD[[p]])
ENT <- c(s4 = "01_saidas/fase4/serie_ptb_fase4.rds", rds32 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds",
         rds45 = "01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds", ref = "01_saidas/fase1/referencias_exposicao.csv")
SHA_ENT <- c(s4 = "e70190c1bf7c0fa5ba9c9f1e3cacb46f1ef8d647fc04a8606d181f7c819793e0", rds32 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d",
             rds45 = "52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e", ref = "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467")
sha_ent <- vapply(ENT, sha, ""); if (!identical(unname(sha_ent), unname(SHA_ENT))) stop("entrada com SHA-256 diferente do registrado: ", paste(names(ENT)[sha_ent != SHA_ENT], collapse = ", "))
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta); library(splines) })
f <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = f); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f)
sys.source(file.path(CC, "R", "sens_agudos.R"), envir = f); sa <- f   # a sens_agudos usa semeia/semente da segunda_etapa no mesmo ambiente
source(file.path(CC, "tests", "teste3_fonte_independente.R"))
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
idx <- setNames(f$indice_concentracao(ordem), ordem)
CAL <- c("dia_semana", "feriado_nacional", "carnaval", "moveis"); AL7 <- list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE)
ref <- utils::read.csv(ENT[["ref"]], colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ordem, ref$recorte_principal), ]; stopifnot(identical(ref$recorte_principal, ordem))
md <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1, row.names = ordem)
sys.source(file.path(REPO, MOD), envir = environment())
INI <- as.Date("2012-04-07"); FIM <- as.Date("2024-08-06")
s4 <- readRDS(ENT[["s4"]]); s4 <- as.data.frame(s4)[s4$data >= INI & s4$data <= FIM, ]
dados_r <- function(r) { x <- s4[s4$recorte_principal == r, ]; x <- x[order(x$data), ]; rownames(x) <- NULL; stopifnot(all(diff(x$data) == 1), nrow(x) == 4505L); x }
nos_p <- function(r) { z <- ref[ref$recorte_principal == r, ]; list(p10 = z$p10, p75 = z$p75, p90 = z$p90, p50 = z$p50) }
rds32 <- readRDS(ENT[["rds32"]])$resultados; r45 <- readRDS(ENT[["rds45"]])
sdr <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_nucleo"))); sdr$data <- as.Date(sdr$data)
sdr <- sdr[sdr$data >= as.Date("2012-01-01") & sdr$data <= as.Date("2024-12-31"), ]

# ------------------------------------------------------------------ 1–2. principal com resíduos e matriz; PACF e nula
log_msg("principal com resíduos, PACF e nula (26 × 1.000 séries)")
reslag <- list(); pacf_t <- list(); dif32 <- 0; testes_nula <- list()
for (r in ordem) {
  x <- dados_r(r); np <- nos_p(r)
  z <- f$ajusta_dlnm(x, spec_c(argvar = list(fun = "ns", knots = c(np$p10, np$p75, np$p90)), arglag = AL7, cen = np$p50), devolve_matriz = TRUE, devolve_residuos = TRUE)
  stopifnot(identical(z$status, "ok")); q <- rds32[[r]]$principal
  dif32 <- max(dif32, abs(z$coef_cb - q$coef_cb), abs(z$vcov_cb - q$vcov_cb))
  mt <- z$matriz; jan <- which(x$janela_principal); pos <- mt$linhas - jan[1] + 1L; ng <- length(jan); n_aj <- length(pos)
  r_obs <- z$residuos_deviance[mt$linhas]; obs <- sa$pacf_grade(r_obs, pos, ng, 7L)
  nl <- sa$nula_pacf(mt, pos, ng, i = idx[[r]], R = 1000L, lag.max = 7L)
  testes_nula[[r]] <- data.frame(recorte_principal = r, w_mu = sa$confere_pesos(mt$peso_trabalho, mt$mu), orto_rel = nl$orto / nl$escala, semente = nl$semente)
  lim <- 2 / sqrt(n_aj)
  pacf_t[[r]] <- data.frame(recorte_principal = r, concentracao = nome[[r]], lag = 1:7, observada = obs, limite_literal = lim, fora_literal = abs(obs) > lim,
                            media_nula = nl$media, q025_nula = nl$q025, q975_nula = nl$q975, recentrada = obs - nl$media,
                            fora_nula = obs < nl$q025 | obs > nl$q975, n_ajuste = n_aj, stringsAsFactors = FALSE)
  rd <- z$residuos_deviance; rd[is.na(rd)] <- 0; n <- length(rd)
  reslag[[r]] <- sapply(1:7, function(l) c(rep(0, l), rd[seq_len(n - l)]))
}
pacf_t <- do.call(rbind, pacf_t); testes_nula <- do.call(rbind, testes_nula)
ok_32 <- dif32 <= 1e-10; ok_w <- all(testes_nula$w_mu < 1e-8); ok_orto <- all(testes_nula$orto_rel <= 1e-10)
if (!(ok_32 && ok_w && ok_orto)) stop("conferência do principal ou da nula falhou: dif32 = ", dif32, "; W/μ ", max(testes_nula$w_mu), "; orto ", max(testes_nula$orto_rel))

# ------------------------------------------------------------------ 3. D3: resíduos defasados, duas etapas
log_msg("D3: duas etapas com os resíduos defasados")
cfg <- list(id = "C2-D3", rotulo = "D3: resíduos de deviance defasados (lags 1–7), todas as concentrações",
            dados = function(r) { x <- dados_r(r); x$res_lag <- reslag[[r]]; x }, extra = list(covariaveis = c(CAL, "res_lag")), nos = nos_p,
            eixo = r45$eixo, eixo_p = r45$eixo_p, grade = r45$grade, serie_nos = function(r) sdr$tmean_nucleo[sdr$recorte_principal == r], xcol = "tmean_nucleo")
d3 <- roda_analise(cfg)
conc <- do.call(rbind, lapply(seq_along(d3$incluidas), function(i) { r <- d3$incluidas[i]; av <- d3$fits[[r]]$base$argvar; g <- r45$grade[r, ]; b <- d3$meta$blup[[i]]
  tb <- f$busca_tmr(b$coef, av, g[["p1"]], g[["p99"]], g[["p10"]], g[["p90"]], g[["p50"]]); cv <- f$curva(b$coef, b$vcov, av, unname(g[c("p99", "p1")]), tb$tmr)
  lado <- if (!tb$fronteira) NA_character_ else if (tb$indice == 1L) "p1" else "p99"
  data.frame(recorte_principal = r, concentracao = nome[[r]], tmr_blup = tb$tmr, fronteira = tb$fronteira, lado = lado, rr99 = cv$rr[1], rr99_li = cv$rr_li[1], rr99_ls = cv$rr_ls[1],
             rr01 = cv$rr[2], rr01_li = cv$rr_li[2], rr01_ls = cv$rr_ls[2], stringsAsFactors = FALSE) }))

# ------------------------------------------------------------------ gravação e log
saveRDS(list(d3 = d3, pacf = pacf_t, testes_nula = testes_nula, por_concentracao = conc, dif32 = dif32, sha_codigo = sha_cod, sha_entradas = sha_ent, rodada = rodada), f_out[["rds"]])
escreve_csv(pacf_t, f_out[["pacf"]]); sha_out <- vapply(f_out, sha, "")
stopifnot(versao() == "4443971b")
lin <- d3$linha
res_pacf <- do.call(rbind, lapply(ordem, function(r) { p <- pacf_t[pacf_t$recorte_principal == r, ]
  data.frame(Concentração = nome[[r]], `Lags 1–7 (observada)` = paste(br(p$observada, 3), collapse = "; "), `±2/√n` = br(p$limite_literal[1], 4),
             `Fora (literal)` = if (any(p$fora_literal)) paste(p$lag[p$fora_literal], collapse = ",") else "—", `Média da nula, lag 1` = br(p$media_nula[1], 4),
             `Recentrada, lags 1–7` = paste(br(p$recentrada, 3), collapse = "; "), `Fora da faixa 2,5–97,5% da nula` = if (any(p$fora_nula)) paste(p$lag[p$fora_nula], collapse = ",") else "—", check.names = FALSE) }))
md_txt <- c("# Fase 4, Parte C2: D3 (resíduos defasados) e PACF com a nula ponderada", "",
  sprintf("- **Gerado por:** `00_scripts/72_d3_residuos_defasados_fase4.R` (SHA-256 `%s`) e o módulo `00_scripts/fluxo_c_fase4.R` (`%s`), início em %s, fim em %s. Rodada `%s`. `versao()`: %s.",
          sha(file.path(REPO, ESTE)), sha(file.path(REPO, MOD)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  "- **Código (igual ao das tags):**", sprintf("  - `%s`: `%s` (`%s`);", names(sha_cod), sha_cod, COD),
  "- **Entradas (SHA-256 = registrados):**", sprintf("  - `%s`: `%s`;", ENT, sha_ent), "",
  "## Conferências", "",
  sprintf("- Principal reajustado com a v1.1 = 32 (coeficientes e vcov da cross-basis): diferença máxima %s (tolerância 1e-10).", formatC(dif32, format = "e", digits = 1)),
  sprintf("- Pesos de trabalho = μ̂: max|W − μ̂|/μ̂ = %s (< 1e-8). Projeção ponderada: max|X′W^{1/2}e*| / escala = %s (≤ 1e-10). Sementes da nula: %s a %s (20261001 + i).",
          formatC(max(testes_nula$w_mu), format = "e", digits = 1), formatC(max(testes_nula$orto_rel), format = "e", digits = 1), min(testes_nula$semente), max(testes_nula$semente)), "",
  "## PACF dos resíduos de deviance do principal (suplemento; só descritiva)", "", tabela_md(res_pacf), "",
  sprintf("- Concentrações com algum lag fora de ±2/√n (literal): %d de 26; com algum lag fora da faixa de 2,5%% a 97,5%% da nula: %d de 26. Nenhuma decisão depende delas (D3).",
          length(unique(pacf_t$recorte_principal[pacf_t$fora_literal])), length(unique(pacf_t$recorte_principal[pacf_t$fora_nula]))), "",
  "## D3: duas etapas com os resíduos defasados nos lags 1 a 7", "",
  tabela_md(fmt_linhas(lin, br, icf)), "",
  sprintf("- Meta-análise: %s / %s; Wald da média p = %s; da amplitude p = %s.", lin$metodo, lin$bscov, formatC(lin$wald_media_p, format = "g", digits = 3), formatC(lin$wald_amplitude_p, format = "g", digits = 3)), "",
  "## RR por concentração (BLUP da D3, no p99 e no p1 da concentração contra a TMR BLUP)", "",
  tabela_md(data.frame(Concentração = conc$concentracao, `TMR BLUP (°C)` = sprintf("%s%s", br(conc$tmr_blup, 1), ifelse(conc$fronteira, paste0(" [borda ", conc$lado, "]"), "")),
                       `RR p99 (IC)` = icf(conc$rr99, conc$rr99_li, conc$rr99_ls), `RR p1 (IC)` = icf(conc$rr01, conc$rr01_li, conc$rr01_ls), check.names = FALSE)), "",
  "- Na borda, o contraste daquele lado vale 1 por construção (sem IC), como no 45.", "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", f_out, sha_out), "",
  sprintf("- **Resultado:** conferências ok; D3 com %d concentrações. Tempo: %.1f min.", lin$incluidas, as.numeric(difftime(Sys.time(), t0, units = "mins"))), "")
writeLines(md_txt, arq, useBytes = TRUE)
cat("gravado:", arq, "| D3:", lin$incluidas, "conc.; TMR", round(lin$tmr, 1), "; minutos", round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 1), "\n")
