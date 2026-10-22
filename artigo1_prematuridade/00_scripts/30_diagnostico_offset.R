# 30_diagnostico_offset.R — Fase 2, A0: diagnóstico descritivo do offset (decisão 1(a) do chat; desvio 51).
# Só com a serie_ptb_principal.rds (Fase 1), na janela principal, SEM usar ptb nem nenhuma exposição. Por concentração:
#   1. fração da variância de log_w dentro dos estratos concentração × ano × mês (SQ intra-estrato / SQ total);
#   2. autocorrelação de log_w nos lags 1, 7, 14, 28 e 365, depois de tirar a média de cada estrato (dias consecutivos);
#   3. média do desvio de log_w em relação à média do estrato nos dias de feriado nacional, carnaval ou móveis, e nos
#      demais dias.
# Não há regra de decisão: é registro para o eMethods. Só agregados por concentração (nenhum valor de um único dia).
# Grava logs/diagnostico_offset_fase2_<FASE2_DATA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE2_DATA=AAAAMMDD Rscript 00_scripts/30_diagnostico_offset.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE2_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
f_in <- file.path("01_saidas", "fase1", "serie_ptb_principal.rds"); stopifnot(file.exists(f_in))
arq <- file.path("logs", paste0("diagnostico_offset_fase2_", hoje, ".md")); stopifnot(!file.exists(arq))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
nuc <- as.data.frame(cidade_nucleo()); nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE); ordem <- nuc$CD_RECORTE

s <- readRDS(f_in)
s <- s[s$janela_principal, c("recorte_principal", "data", "log_w", "estrato", "feriado_nacional", "carnaval", "moveis")]   # sem ptb nem exposição
stopifnot(!anyNA(s$log_w), all(table(s$recorte_principal) == 4498))
LAGS <- c(1, 7, 14, 28, 365)
res <- do.call(rbind, lapply(ordem, function(r) {
  x <- s[s$recorte_principal == r, ]; x <- x[order(x$data), ]
  stopifnot(all(diff(x$data) == 1))                                    # dias consecutivos
  m_e <- ave(x$log_w, x$estrato, FUN = mean); dev <- x$log_w - m_e
  frac <- sum(dev^2) / sum((x$log_w - mean(x$log_w))^2)
  ac <- acf(dev, lag.max = max(LAGS), plot = FALSE, demean = TRUE)$acf[LAGS + 1]
  fer <- x$feriado_nacional == 1 | x$carnaval == 1 | x$moveis == 1
  data.frame(recorte_principal = r, n_dias = nrow(x), n_estratos = length(unique(x$estrato)), frac_intra = frac,
             t(setNames(ac, paste0("acf_", LAGS))), dev_feriados = mean(dev[fer]), dev_demais = mean(dev[!fer]),
             n_dias_feriados = sum(fer), stringsAsFactors = FALSE)
}))
stopifnot(nrow(res) == 26, length(unique(res$n_dias_feriados)) == 1)  # o calendário é o mesmo nas 26
resumo <- function(v, d) sprintf("%s (%s a %s)", br(median(v), d), br(min(v), d), br(max(v), d))
s_info <- sessionInfo()
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
md <- c("# Fase 2, A0: diagnóstico descritivo do offset (`log_w`)", "",
        sprintf("- **Gerado por:** `00_scripts/30_diagnostico_offset.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        sprintf("- **BLAS/LAPACK** (`sessionInfo()`): `%s` / `%s`. R %s.", s_info$BLAS, s_info$LAPACK, paste(R.version$major, R.version$minor, sep = ".")),
        sprintf("- **Entrada:** `01_saidas/fase1/serie_ptb_principal.rds` (SHA-256 `%s`), só as colunas `recorte_principal`, `data`, `log_w`, `estrato`, `feriado_nacional`, `carnaval` e `moveis`, na janela principal (4.498 dias por concentração). Sem `ptb` e sem exposição.", sha(f_in)),
        "- **Decisão 1(a) do chat (desvio 51):** o método não muda (γ estimado no principal; γ = 1 é a sensibilidade-chave nº 5). Este diagnóstico é registro para o eMethods, sem regra de decisão.",
        "- **Definições, por concentração:**",
        "  - **fração intra-estrato** = Σ (log_w − média do estrato)² / Σ (log_w − média geral)², com estratos concentração × ano × mês;",
        "  - **ACF** = autocorrelação do desvio em relação à média do estrato, em dias consecutivos, nos lags 1, 7, 14, 28 e 365 (`acf`, `demean = TRUE`);",
        sprintf("  - **desvio médio** em relação à média do estrato, nos %s dias de feriado nacional, carnaval ou móveis da janela principal, e nos demais dias.", br(res$n_dias_feriados[1])), "",
        "## Resumo nas 26 concentrações (mediana, mínimo a máximo)", "",
        tabela_md(data.frame(Medida = c("Fração da variância de log_w dentro dos estratos", paste("ACF lag", LAGS),
                                        "Desvio médio nos feriados, carnaval e móveis", "Desvio médio nos demais dias"),
                             Valor = c(resumo(res$frac_intra, 4), vapply(paste0("acf_", LAGS), function(k) resumo(res[[k]], 3), ""),
                                       resumo(res$dev_feriados, 5), resumo(res$dev_demais, 5)), check.names = FALSE)), "",
        "## Por concentração", "",
        tabela_md(data.frame(Concentração = nome[res$recorte_principal], `Fração intra` = br(res$frac_intra, 4),
                             `ACF 1` = br(res$acf_1, 3), `ACF 7` = br(res$acf_7, 3), `ACF 14` = br(res$acf_14, 3),
                             `ACF 28` = br(res$acf_28, 3), `ACF 365` = br(res$acf_365, 3),
                             `Desvio feriados` = br(res$dev_feriados, 5), `Desvio demais` = br(res$dev_demais, 5), check.names = FALSE)), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "\n")
