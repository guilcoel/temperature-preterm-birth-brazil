# 11_sha256_csv_rerun.R — Fase 0 refeita (base 4443971b), A6: SHA-256 dos CSV de 01_saidas/fase0_rerun/ (decisões §9 e §11).
# Uma linha por CSV: caminho relativo à raiz do repositório, SHA-256, bytes, linhas, conteúdo, script que gerou, o que
# sustenta (distribuição semanal (i); percentis da MM9; percentis da MM14; percentis semanais equivalentes) e máscara.
# Compara com a Fase 0A (01_saidas/fase0/). Só lê CSV agregados. Grava logs/csv_sha256_fase0_rerun_<FASE0_RERUN_DATA>.md.
# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/11_sha256_csv_rerun.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("csv_sha256_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
sha256 <- function(f) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(f)), stdout = TRUE))

pasta <- file.path("01_saidas", "fase0_rerun")
csv <- sort(list.files(pasta, pattern = "\\.csv$")); csv <- csv[!startsWith(csv, "._")]
info <- list(   # gerado por | conteúdo | (i) | MM9 | MM14 | equivalentes | máscara
  a5_1_totais.csv = c("02_recontagens_fase0.R", "A5.1: totais da série com coorte fixa, 2012–2024, 26 somadas (NV únicos, PTB, óbito perinatal)", "", "", "", "", "não precisa: totais das 26"),
  a5_2_eventos_janelas.csv = c("02_recontagens_fase0.R", "A5.2: PTB e perinatal por concentração; total 2012–2024, na janela e perda, nas janelas principal e de evento possível", "", "", "", "", "sem máscara no CSV; nenhuma célula de 1 a 9 (A8; desvio 9)"),
  a5_3_percentis_diarios.csv = c("02_recontagens_fase0.R", "A5.3: percentis da `tmean_nucleo` diária por concentração (ano inteiro e novembro a março)", "", "", "", "", "não se aplica (exposição)"),
  a5_4_semanal_mm.csv = c("02_recontagens_fase0.R", "A5.4: percentis das leituras (i) e (ii) da exposição semanal; MM9 (p1, p50, p99); MM14 do 1º e do 2º trimestre (p1, p99); percentil semanal (i) equivalente do p1 e do p99 da MM9", "sim (`i_p1`…`i_p99`)", "sim", "sim (°C)", "MM9", "não se aplica (exposição)"),
  a5_4c_mm14_mm9_equivalentes.csv = c("08_mm14_equivalente_rerun.R", "A5: p1 e p99 da MM14 do 1º e do 2º trimestre e da MM9 (°C) e o percentil semanal (i) equivalente de cada um", "usada no cálculo (não gravada)", "sim", "sim (°C)", "MM9 e MM14", "não se aplica (exposição)"),
  a5_5_pm25_dias_utilizaveis.csv = c("02_recontagens_fase0.R", "A5.5: dias de modelo utilizáveis do `pm25_local_zero_na_nucleo` (lag 0–1) por concentração e janela", "", "", "", "", "não se aplica (exposição)"),
  a7_populacao_dum_ano.csv = c("09_populacao_dum_rerun.R", "A7: NV e PTB por ano, 2013–2023, 26 somadas, níveis (a) e (c) da DUM, e % mantido", "", "", "", "", "sim: gravado já mascarado (nenhuma supressão necessária)"),
  a7_populacao_dum_concentracao.csv = c("09_populacao_dum_rerun.R", "A7: NV e PTB por concentração na janela principal, níveis (a), (b) e (c) da DUM, e % mantido", "", "", "", "", "sim: gravado já mascarado (\"supr.\" e \"—\")"))
stopifnot(setequal(csv, names(info)))
lin <- vapply(file.path(pasta, csv), function(f) length(readLines(f, warn = FALSE)), 0L)
byt <- file.size(file.path(pasta, csv)); sh <- vapply(file.path(pasta, csv), sha256, "")
sh0 <- vapply(csv, function(f) { g <- file.path("01_saidas", "fase0", f); if (file.exists(g)) sha256(g) else NA_character_ }, "")
# a5_4c × a5_4b do complemento: mesmos números?
c4 <- read.csv(file.path(pasta, "a5_4c_mm14_mm9_equivalentes.csv"), colClasses = c(recorte_principal = "character"))
b4 <- read.csv(file.path("01_saidas", "fase0", "a5_4b_mm14_equivalentes.csv"), colClasses = c(recorte_principal = "character"))
b4 <- b4[match(c4$recorte_principal, b4$recorte_principal), ]
nm <- setdiff(names(c4), c("recorte_principal", "concentracao"))
d4 <- max(vapply(nm, function(k) max(abs(c4[[k]] - b4[[k]])), 0))
fase0a <- ifelse(!is.na(sh0) & sh0 == sh, "igual (mesmo SHA-256)", ifelse(is.na(sh0), "novo", "**diferente**"))
fase0a[csv == "a5_4c_mm14_mm9_equivalentes.csv"] <- sprintf("novo; mesmos números do `a5_4b_mm14_equivalentes.csv` do complemento (maior diferença %s; SHA-256 do a5_4b: `%s`), texto diferente em alguma última casa", format(d4, digits = 2), sha256(file.path("01_saidas", "fase0", "a5_4b_mm14_equivalentes.csv")))
fase0a[csv %in% c("a7_populacao_dum_ano.csv", "a7_populacao_dum_concentracao.csv")] <- "novo (A7)"
if (any(fase0a == "**diferente**") || d4 > 1e-9) { cat("CSV DIFERENTE DA FASE 0A: parar e reportar.\n"); quit(status = 1) }
ok_lin <- all(lin >= 2)
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
g <- function(i) vapply(csv, function(f) info[[f]][i], "")
md <- c("# A6: SHA-256 dos CSV de `01_saidas/fase0_rerun/` (Fase 0 refeita)", "",
        sprintf("- **Gerado por:** `00_scripts/11_sha256_csv_rerun.R`, em %s, com `shasum -a 256`. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        "- **Para que serve:** registrar exatamente quais arquivos sustentam os números da Fase 0 refeita; a Revisão 2 final copia estes SHA-256 para a seção 11 das decisões. Os CSV ficam fora do git.",
        "- **Os modelos não leem estes CSV.** São saídas descritivas, gravadas por `write.csv` com 15 dígitos significativos; os logs `.md` trazem os valores arredondados.",
        "- **Caminho:** relativo à raiz do repositório (`/Volumes/Forja/Doc/artigos_perinatais_clima`). **Linhas:** do arquivo, com o cabeçalho.", "",
        tabela_md(data.frame(Caminho = paste0("`artigo1_prematuridade/01_saidas/fase0_rerun/", csv, "`"), `SHA-256` = paste0("`", sh, "`"),
                             Bytes = br(byt), Linhas = lin, Conteúdo = g(2), `Gerado por` = paste0("`", g(1), "`"), check.names = FALSE)), "",
        "## O que cada CSV sustenta", "",
        tabela_md(data.frame(CSV = paste0("`", csv, "`"), `Distribuição semanal (i)` = ifelse(g(3) == "", "—", g(3)),
                             `Percentis da MM9` = ifelse(g(4) == "", "—", g(4)), `Percentis da MM14` = ifelse(g(5) == "", "—", g(5)),
                             `Percentis semanais equivalentes` = ifelse(g(6) == "", "—", g(6)), Máscara = g(7), `Fase 0A` = fase0a, check.names = FALSE)), "",
        "```", "$ shasum -a 256 01_saidas/fase0_rerun/*.csv", sprintf("%s  01_saidas/fase0_rerun/%s", sh, csv),
        "$ ls -l 01_saidas/fase0_rerun/*.csv", sprintf("%d %s 01_saidas/fase0_rerun/%s", byt, format(file.mtime(file.path(pasta, csv)), "%b %e %H:%M"), csv), "```", "",
        sprintf("- **Conferências:** %d CSV, todos com cabeçalho e dados (%s); os cinco da A4 com o mesmo SHA-256 da Fase 0A; os `._*` (AppleDouble do exFAT) não são CSV e ficam de fora.", length(csv), if (ok_lin) "sim" else "NÃO"),
        "", sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "\n")
print(data.frame(csv, sh = substr(sh, 1, 12), lin, fase0a = substr(fase0a, 1, 30)), row.names = FALSE)
