# 07_compara_fase0_rerun.R — Fase 0 refeita (base 4443971b), A4: compara cada CSV de 01_saidas/fase0_rerun/ (gerado pelo
# 02_recontagens_fase0.R) com o CSV correspondente da Fase 0A (01_saidas/fase0/), pelo SHA-256; onde o SHA diferir,
# compara célula a célula. Também confere o SHA da Fase 0A contra o registrado em logs/csv_sha256_fase0_20261008.md.
# O esperado é zero diferença: a base mudou só a coluna ig_dum_sem, e a série, a matriz semanal e o calendário têm o mesmo
# md5 da versão anterior da base (manifesto do commit 9f1957b). Qualquer diferença numérica: o script sai com 1 (parar e reportar).
# Só lê CSV agregados. Grava logs/comparacao_a4_fase0_rerun_<FASE0_RERUN_DATA>.md (nunca sobrescreve).
# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/07_compara_fase0_rerun.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("comparacao_a4_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq))

sha256 <- function(f) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(f)), stdout = TRUE))
csvs <- c("a5_1_totais.csv", "a5_2_eventos_janelas.csv", "a5_3_percentis_diarios.csv", "a5_4_semanal_mm.csv",
          "a5_5_pm25_dias_utilizaveis.csv")
reg <- readLines("logs/csv_sha256_fase0_20261008.md", encoding = "UTF-8")
linhas <- character(); detalhes <- character(); dif_total <- 0
for (f in csvs) {
  a <- file.path("01_saidas", "fase0", f); b <- file.path("01_saidas", "fase0_rerun", f)
  stopifnot(file.exists(a), file.exists(b))
  sa <- sha256(a); sb <- sha256(b)
  no_log <- any(grepl(sprintf("| `%s` |", f), reg, fixed = TRUE) & grepl(sprintf("`%s` |", sa), reg, fixed = TRUE))
  celulas <- 0
  if (sa != sb) {                                   # célula a célula
    x <- read.csv(a, colClasses = "character", check.names = FALSE); y <- read.csv(b, colClasses = "character", check.names = FALSE)
    if (!identical(dim(x), dim(y)) || !identical(names(x), names(y))) {
      celulas <- NA
      detalhes <- c(detalhes, sprintf("- `%s`: dimensões ou colunas diferentes (%s × %s).", f, paste(dim(x), collapse = "×"), paste(dim(y), collapse = "×")))
    } else {
      d <- x != y; d[is.na(d)] <- !(is.na(x) & is.na(y))[is.na(d)]
      celulas <- sum(d)
      for (j in which(colSums(d) > 0)) {
        nx <- suppressWarnings(as.numeric(x[[j]][d[, j]])); ny <- suppressWarnings(as.numeric(y[[j]][d[, j]]))
        detalhes <- c(detalhes, sprintf("- `%s`, coluna `%s`: %d célula(s) diferente(s); maior |diferença| numérica %s.",
                                        f, names(x)[j], sum(d[, j]), format(suppressWarnings(max(abs(nx - ny), na.rm = TRUE)))))
      }
    }
  }
  dif_total <- dif_total + (sa != sb)
  linhas <- c(linhas, sprintf("| `%s` | `%s` | `%s` | %s | %s | %s |", f, sa, sb, ifelse(sa == sb, "sim", "**NÃO**"),
                              ifelse(no_log, "sim", "**NÃO**"), ifelse(sa == sb, "—", as.character(celulas))))
  if (!no_log) dif_total <- dif_total + 1
}
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
md <- c("# A4: comparação dos CSV da Fase 0 refeita com os da Fase 0A", "",
        sprintf("- **Gerado por:** `00_scripts/07_compara_fase0_rerun.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        "- **Método:** SHA-256 de cada CSV de `01_saidas/fase0_rerun/` × o da Fase 0A em `01_saidas/fase0/`, e o da Fase 0A × o registrado em `logs/csv_sha256_fase0_20261008.md`. Onde o SHA difere, comparação célula a célula (texto) e, nas células numéricas, a maior diferença absoluta.",
        "- **O `a5_4b_mm14_equivalentes.csv` do complemento** não entra aqui: a MM14 da rodada refeita sai do `08_mm14_equivalente_rerun.R` (A5), que faz a própria comparação.",
        sprintf("- **Resultado:** %s.", if (dif_total == 0) "nenhuma diferença; os 5 CSV são idênticos byte a byte aos da Fase 0A" else "HÁ DIFERENÇA: parar e reportar"), "",
        "| CSV | SHA-256 da Fase 0A | SHA-256 da rodada refeita | Igual | SHA da Fase 0A = log da Fase 0A | Células diferentes |",
        "|---|---|---|---|---|---|", linhas, "",
        if (length(detalhes)) c("## Diferenças", "", detalhes, "") else character(),
        "- **Logs em markdown:** o `logs/recontagens_fase0_rerun_*.md` difere do da Fase 0A no texto (data, versão, caminhos e uma frase da MM14 reescrita depois da Fase 0A, às 18h29 de 08/10, sem nova rodada). A prova dos números são os CSV acima.",
        "", sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| CSV diferentes:", dif_total, "\n")
if (dif_total > 0) { cat("DIFERENÇA ENTRE A FASE 0 REFEITA E A FASE 0A: parar e reportar.\n"); quit(status = 1) }
