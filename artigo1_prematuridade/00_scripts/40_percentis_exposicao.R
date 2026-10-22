# 40_percentis_exposicao.R — Fase 3, A0: grade de percentis da exposição por concentração e eixo médio (D2; D4(c);
# desvios 69, 71 e 72). Só exposição, sem desfecho: a serie_diaria() é lida com a mesma função e os mesmos argumentos
# da Fase 1 (20_monta_serie_principal.R), mas só com as colunas recorte_principal, data e tmean_nucleo (desvio 72a).
#   1. por concentração, quantile(type = 7) da tmean_nucleo diária de 2012-01-01 a 2024-12-31 nos percentis 1 a 99,
#      2,5 e 97,5;
#   2. conferência: p1, p10, p50, p75, p90, p99, média e amplitude (p99 − p1) iguais às linhas de ano inteiro do
#      referencias_exposicao.csv, com diferença ≤ 1e-12 (o CSV tem 15 dígitos significativos); se não, para;
#   3. eixo médio: a média, nas 26, de cada percentil da grade.
# A ordem das 26 é a gravada em codigo_compartilhado/R/segunda_etapa.R (desvio 73). Exposição é dado público.
# Grava 01_saidas/fase3/percentis_exposicao_fase3_<FASE3_DATA>.csv e logs/percentis_exposicao_fase3_<FASE3_DATA>.md.
# Nunca sobrescreve. Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/40_percentis_exposicao.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("percentis_exposicao_fase3_", hoje, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase3"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
f_csv <- file.path(OUT, paste0("percentis_exposicao_fase3_", hoje, ".csv")); stopifnot(!file.exists(f_csv))
CC <- file.path("..", "codigo_compartilhado")
se <- new.env(); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = se)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))

nuc <- as.data.frame(cidade_nucleo()); se$confere_ordem(nuc$CD_RECORTE)
ordem <- se$ORDEM_CONCENTRACOES; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
f_ref <- file.path("01_saidas", "fase1", "referencias_exposicao.csv"); sha_ref <- sha(f_ref)
ref <- utils::read.csv(f_ref, colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; stopifnot(nrow(ref) == 26)
ex <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_nucleo")))
ex$data <- as.Date(ex$data)
ex <- ex[ex$data >= as.Date("2012-01-01") & ex$data <= as.Date("2024-12-31"), ]
stopifnot(setequal(unique(ex$recorte_principal), ordem), !anyNA(ex$tmean_nucleo))
P <- sort(c(seq_len(99) / 100, 0.025, 0.975)); rot <- ifelse(abs(P * 100 - round(P * 100)) < 1e-9, paste0("p", round(P * 100)), paste0("p", sub("\\.", ",", vapply(P * 100, function(v) as.character(v), ""))))
grade <- t(vapply(ordem, function(r) {
  x <- ex$tmean_nucleo[ex$recorte_principal == r]; stopifnot(all(diff(sort(ex$data[ex$recorte_principal == r])) == 1))
  quantile(x, P, type = 7, names = FALSE)
}, numeric(length(P))))
dimnames(grade) <- list(ordem, rot)
n_dias <- vapply(ordem, function(r) sum(ex$recorte_principal == r), 0L)
media <- vapply(ordem, function(r) mean(ex$tmean_nucleo[ex$recorte_principal == r]), 0)

# conferência contra o referencias_exposicao.csv (ano inteiro)
rr <- ref[match(ordem, ref$recorte_principal), ]
dif <- cbind(p1 = grade[, "p1"] - rr$p1, p10 = grade[, "p10"] - rr$p10, p50 = grade[, "p50"] - rr$p50, p75 = grade[, "p75"] - rr$p75,
             p90 = grade[, "p90"] - rr$p90, p99 = grade[, "p99"] - rr$p99, media = media - rr$media,
             amplitude = (grade[, "p99"] - grade[, "p1"]) - rr$amplitude_p99_p1, n_dias = n_dias - rr$n_dias)
max_dif <- apply(abs(dif), 1, max)
if (any(max_dif > 1e-12)) stop("A0: percentis recalculados diferem do referencias_exposicao.csv (máx. ", format(max(max_dif)), "); parar")
eixo <- colMeans(grade)

# saída: formato longo, 17 dígitos (concentrações e eixo médio)
longo <- rbind(data.frame(recorte_principal = rep(ordem, each = length(P)), concentracao = rep(unname(nome[ordem]), each = length(P)),
                          percentil = rep(P * 100, times = 26), rotulo = rep(rot, times = 26), valor = as.vector(t(grade)), stringsAsFactors = FALSE),
               data.frame(recorte_principal = "eixo_medio", concentracao = "Eixo médio (média das 26)", percentil = P * 100, rotulo = rot, valor = unname(eixo), stringsAsFactors = FALSE))
longo$valor <- sprintf("%.17g", longo$valor); longo$percentil <- sprintf("%.17g", longo$percentil)
utils::write.csv(longo, f_csv, row.names = FALSE, fileEncoding = "UTF-8")
sha_csv <- sha(f_csv)

stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
chave <- c("p1", "p2,5", "p5", "p10", "p50", "p90", "p95", "p97,5", "p99")
tab_grade <- data.frame(Percentil = rot, `Eixo médio` = br(eixo, 3), check.names = FALSE)
for (r in ordem) tab_grade[[nome[[r]]]] <- br(grade[r, ], 3)
md <- c("# Fase 3, A0: grade de percentis da exposição e eixo médio", "",
        sprintf("- **Gerado por:** `00_scripts/40_percentis_exposicao.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        sprintf("- **BLAS/LAPACK:** `%s` / `%s`.", sessionInfo()$BLAS, sessionInfo()$LAPACK),
        "- **Fonte:** `serie_diaria(nivel = \"recorte\", coorte_fixa = TRUE, colunas = c(\"recorte_principal\", \"data\", \"tmean_nucleo\"))`, a mesma função e os mesmos argumentos que geraram o `referencias_exposicao.csv` na Fase 1, só com as colunas de exposição (desvio 72a). Sem desfecho.",
        sprintf("- **Período:** 2012-01-01 a 2024-12-31 (%s dias por concentração; datas consecutivas conferidas). `quantile(type = 7)` nos percentis 1 a 99, 2,5 e 97,5 (%d percentis).", br(unique(n_dias)), length(P)),
        sprintf("- **Ordem das 26:** a gravada em `codigo_compartilhado/R/segunda_etapa.R` (desvio 73), conferida contra `cidade_nucleo()`."), "",
        "## Conferência contra o `referencias_exposicao.csv` (linhas de ano inteiro)", "",
        sprintf("- **Arquivo:** `%s`, SHA-256 `%s`.", f_ref, sha_ref),
        sprintf("- **Resultado:** p1, p10, p50, p75, p90, p99, média, amplitude (p99 − p1) e n de dias iguais nas 26 concentrações; maior diferença absoluta = %s (tolerância 1e-12; o CSV tem 15 dígitos significativos).",
                formatC(max(max_dif), format = "e", digits = 1)), "",
        "## Eixo médio (média das 26) nos percentis-chave", "",
        tabela_md(data.frame(Percentil = chave, `°C` = br(eixo[chave], 3), check.names = FALSE)), "",
        "## Grade completa (°C)", "",
        tabela_md(tab_grade), "",
        "## Saída (fora do git)", "",
        sprintf("- `%s`: `%s` (formato longo, 17 dígitos; 26 concentrações e o eixo médio).", f_csv, sha_csv), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| maior diferença contra o CSV:", format(max(max_dif)), "| SHA da grade:", sha_csv, "\n")
