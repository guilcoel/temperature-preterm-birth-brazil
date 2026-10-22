# 04_mm14_equivalentes_fase0.R — complemento da Fase 0A, item 4: percentil semanal equivalente do p1 e do p99 da MM14.
#
# Só exposição. Para cada concentração:
#   - distribuição semanal na leitura (i): todos os s01…s37 de cada dum_est único de 2011-04-17 a 2024-03-05, empilhados;
#   - MM14 do 1º trimestre = média de s01…s14; do 2º trimestre = média de s15…s28 (por dum_est);
#   - p1 e p99 de cada MM14 (quantile type = 7) e a posição deles na distribuição semanal (i), pela ecdf.
# A MM9 (s29…s37) entra no resumo só para comparação; os valores dela já estão na A5.4.
# Separado do 02_recontagens_fase0.R para não reescrever o log e os CSV que entraram no RESPOSTA_FASE0A como registro.
#
# Grava (fora do git): 01_saidas/fase0_rerun/a5_4b_mm14_equivalentes.csv.  Resumo (no git): logs/mm14_fase0_rerun_<FASE0_RERUN_DATA>.md
# Fase 0 refeita (base 4443971b): só hash, caminhos, data fixa e trava, para não sobrescrever a Fase 0A. NÃO roda na rodada
# refeita: a A5 é feita pelo 08_mm14_equivalente_rerun.R, com código diferente (controle, não repetição).
# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/04_mm14_equivalentes_fase0.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")

saida <- file.path("01_saidas", "fase0_rerun")
dir.create(saida, recursive = TRUE, showWarnings = FALSE)
hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
D <- as.Date
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0
  formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"),
                            paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))

nuc <- as.data.frame(cidade_nucleo())
nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
es <- as.data.frame(expo_semanal("tmean", "nucleo"))
es$dum_est <- as.Date(es$dum_est)
es <- es[es$dum_est >= D("2011-04-17") & es$dum_est <= D("2024-03-05"), ]
sc <- sprintf("s%02d", 1:37)
if (anyNA(es[, sc])) { cat("NA na matriz semanal: parar e reportar.\n"); quit(status = 1) }

res <- do.call(rbind, lapply(split(es, es$recorte_principal), function(g) {
  m <- as.matrix(g[, sc])
  Fi <- ecdf(as.vector(m))                                          # leitura (i)
  mm <- list(t1 = rowMeans(m[, 1:14]), t2 = rowMeans(m[, 15:28]), mm9 = rowMeans(m[, 29:37]))
  q <- lapply(mm, quantile, probs = c(.01, .99), type = 7, names = FALSE)
  data.frame(recorte_principal = g$recorte_principal[1], n_dum_est = nrow(g),
             t1_p1 = q$t1[1], t1_p99 = q$t1[2], t2_p1 = q$t2[1], t2_p99 = q$t2[2], mm9_p1 = q$mm9[1], mm9_p99 = q$mm9[2],
             t1_p1_pct_i = 100 * Fi(q$t1[1]), t1_p99_pct_i = 100 * Fi(q$t1[2]),
             t2_p1_pct_i = 100 * Fi(q$t2[1]), t2_p99_pct_i = 100 * Fi(q$t2[2]),
             mm9_p1_pct_i = 100 * Fi(q$mm9[1]), mm9_p99_pct_i = 100 * Fi(q$mm9[2]), stringsAsFactors = FALSE)
}))
res$concentracao <- nome[res$recorte_principal]
stopifnot(nrow(res) == 26, all(res$n_dum_est == 4707))
stopifnot(!file.exists(file.path(saida, "a5_4b_mm14_equivalentes.csv")))
write.csv(res, file.path(saida, "a5_4b_mm14_equivalentes.csv"), row.names = FALSE)

pos <- c(t1_p1_pct_i = "MM14, 1º trimestre, p1", t1_p99_pct_i = "MM14, 1º trimestre, p99",
         t2_p1_pct_i = "MM14, 2º trimestre, p1", t2_p99_pct_i = "MM14, 2º trimestre, p99",
         mm9_p1_pct_i = "MM9, p1 (comparação; já na A5.4)", mm9_p99_pct_i = "MM9, p99 (comparação; já na A5.4)")
resumo <- data.frame(`Percentil da média móvel` = unname(pos),
                     `Média` = paste0("p", br(sapply(names(pos), function(k) mean(res[[k]])), 1)),
                     `Mínimo` = paste0("p", br(sapply(names(pos), function(k) min(res[[k]])), 1), " (",
                                       sapply(names(pos), function(k) res$concentracao[which.min(res[[k]])]), ")"),
                     `Máximo` = paste0("p", br(sapply(names(pos), function(k) max(res[[k]])), 1), " (",
                                       sapply(names(pos), function(k) res$concentracao[which.max(res[[k]])]), ")"),
                     check.names = FALSE)
print(resumo, row.names = FALSE)

stopifnot(versao() == "4443971b")
cat("versao() no fim:", versao(), "\n")
o <- order(match(res$recorte_principal, nuc$CD_RECORTE))
md <- c("# Complemento da Fase 0A, item 4: percentil semanal equivalente da MM14", "",
        sprintf("- **Gerado por:** `00_scripts/04_mm14_equivalentes_fase0.R`, em %s. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), v_ini),
        "- **Só exposição:** `expo_semanal(\"tmean\", \"nucleo\")`, com `dum_est` de 2011-04-17 a 2024-03-05 (4.707 por concentração).",
        "- **Leitura (i):** todos os `s01`…`s37`, empilhados. MM14 do 1º trimestre = média de `s01`…`s14`; do 2º = média de `s15`…`s28`. Percentis com `quantile(type = 7)`; posição pela `ecdf` da leitura (i).",
        "- **CSV completo:** `01_saidas/fase0_rerun/a5_4b_mm14_equivalentes.csv`, fora do git.", "",
        "## Resumo nas 26 concentrações", "", tabela_md(resumo), "",
        "## Por concentração (°C e percentil semanal equivalente na leitura (i))", "",
        tabela_md(data.frame(Concentração = res$concentracao[o],
                             `1º tri p1 (°C)` = br(res$t1_p1[o], 2), `= p semanal` = br(res$t1_p1_pct_i[o], 1),
                             `1º tri p99 (°C)` = br(res$t1_p99[o], 2), `= p semanal ` = br(res$t1_p99_pct_i[o], 1),
                             `2º tri p1 (°C)` = br(res$t2_p1[o], 2), `= p semanal  ` = br(res$t2_p1_pct_i[o], 1),
                             `2º tri p99 (°C)` = br(res$t2_p99[o], 2), `= p semanal   ` = br(res$t2_p99_pct_i[o], 1),
                             check.names = FALSE)), "",
        sprintf("`versao()` no fim: %s.", versao()))
arq <- file.path("logs", paste0("mm14_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "\n")
