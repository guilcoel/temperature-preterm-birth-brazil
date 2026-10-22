# 08_mm14_equivalente_rerun.R — Fase 0 refeita (base 4443971b), A5: a que percentil da distribuição semanal (i)
# correspondem o p1 e o p99 da MM14 do 1º trimestre (s01…s14) e do 2º trimestre (s15…s28), por concentração, com a MM9
# (s29…s37) ao lado. Só exposição (expo_semanal("tmean", "nucleo")); nenhum desfecho.
#
# Mesmo método da Fase 0A (decisões §7; leitura (i)): distribuição semanal = todos os s01…s37 de cada dum_est único de
# 2011-04-17 a 2024-03-05, empilhados, sem ponderação; percentis com quantile(type = 7); percentil equivalente = ecdf da
# distribuição (i) avaliada no valor, × 100. Código DIFERENTE do 02 e do 04 (controle, não repetição):
#   - ecdf por findInterval sobre o vetor (i) ordenado (= nº de valores ≤ x / n, a definição da ecdf);
#   - quantil tipo 7 implementado à mão e conferido contra quantile(type = 7);
#   - médias móveis por produto de matriz (m %*% pesos), e não rowMeans.
# Compara com o CSV do complemento (01_saidas/fase0/a5_4b_mm14_equivalentes.csv) e com a MM9 da A5.4 refeita.
# Grava (fora do git) 01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv (mesmas colunas do a5_4b) e o resumo em
# logs/mm14_equivalente_fase0_rerun_<FASE0_RERUN_DATA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/08_mm14_equivalente_rerun.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
saida <- file.path("01_saidas", "fase0_rerun"); stopifnot(dir.exists(saida))
csv_out <- file.path(saida, "a5_4c_mm14_mm9_equivalentes.csv"); stopifnot(!file.exists(csv_out))
arq <- file.path("logs", paste0("mm14_equivalente_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))

q7 <- function(x, p) {                                   # quantil tipo 7 (Hyndman & Fan): h = (n − 1)p + 1
  x <- sort(x); n <- length(x); h <- (n - 1) * p + 1; lo <- floor(h); hi <- pmin(lo + 1, n)
  x[lo] + (h - lo) * (x[hi] - x[lo])
}
pct_i <- function(vs, x) 100 * findInterval(x, vs) / length(vs)   # vs ordenado: nº de valores ≤ x / n  (ecdf × 100)

nuc <- as.data.frame(cidade_nucleo()); nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
es <- as.data.frame(expo_semanal("tmean", "nucleo")); es$dum_est <- as.Date(es$dum_est)
es <- es[es$dum_est >= as.Date("2011-04-17") & es$dum_est <= as.Date("2024-03-05"), ]
sc <- sprintf("s%02d", 1:37)
if (anyNA(es[, sc])) { cat("NA na matriz semanal: parar e reportar.\n"); quit(status = 1) }
w <- function(k) matrix(1 / length(k), nrow = length(k))
dif_q <- 0
linhas <- lapply(sort(unique(es$recorte_principal)), function(r) {
  m <- as.matrix(es[es$recorte_principal == r, sc])
  vs <- sort(c(m))                                                  # leitura (i), ordenada
  mm <- list(t1 = c(m[, 1:14] %*% w(1:14)), t2 = c(m[, 15:28] %*% w(15:28)), mm9 = c(m[, 29:37] %*% w(29:37)))
  q <- lapply(mm, q7, p = c(.01, .99))
  dif_q <<- max(dif_q, unlist(Map(function(a, b) abs(a - quantile(b, c(.01, .99), type = 7, names = FALSE)), q, mm)))
  data.frame(recorte_principal = r, n_dum_est = nrow(m),
             t1_p1 = q$t1[1], t1_p99 = q$t1[2], t2_p1 = q$t2[1], t2_p99 = q$t2[2], mm9_p1 = q$mm9[1], mm9_p99 = q$mm9[2],
             t1_p1_pct_i = pct_i(vs, q$t1[1]), t1_p99_pct_i = pct_i(vs, q$t1[2]),
             t2_p1_pct_i = pct_i(vs, q$t2[1]), t2_p99_pct_i = pct_i(vs, q$t2[2]),
             mm9_p1_pct_i = pct_i(vs, q$mm9[1]), mm9_p99_pct_i = pct_i(vs, q$mm9[2]), stringsAsFactors = FALSE)
})
res <- do.call(rbind, linhas); res$concentracao <- nome[res$recorte_principal]
stopifnot(nrow(res) == 26, all(res$n_dum_est == 4707), dif_q < 1e-12)
write.csv(res, csv_out, row.names = FALSE)

# comparações: complemento (código do 04) e MM9 da A5.4 refeita (código do 02)
ler <- function(f) read.csv(f, stringsAsFactors = FALSE, colClasses = c(recorte_principal = "character"))
comp <- ler(file.path("01_saidas", "fase0", "a5_4b_mm14_equivalentes.csv"))
a54 <- ler(file.path(saida, "a5_4_semanal_mm.csv"))
num <- setdiff(names(res), c("recorte_principal", "concentracao"))
comp <- comp[match(res$recorte_principal, comp$recorte_principal), ]; a54 <- a54[match(res$recorte_principal, a54$recorte_principal), ]
d_comp <- vapply(num, function(k) max(abs(res[[k]] - comp[[k]])), 0)
d_a54 <- c(mm9_p1 = max(abs(res$mm9_p1 - a54$mm9_p1)), mm9_p99 = max(abs(res$mm9_p99 - a54$mm9_p99)),
           mm9_p1_pct_i = max(abs(res$mm9_p1_pct_i - a54$mm9_p1_em_pct_semanal_i)),
           mm9_p99_pct_i = max(abs(res$mm9_p99_pct_i - a54$mm9_p99_em_pct_semanal_i)),
           t1_p1 = max(abs(res$t1_p1 - a54$t1_p1)), t1_p99 = max(abs(res$t1_p99 - a54$t1_p99)),
           t2_p1 = max(abs(res$t2_p1 - a54$t2_p1)), t2_p99 = max(abs(res$t2_p99 - a54$t2_p99)))
TOL <- 1e-9
ok <- all(d_comp < TOL) && all(d_a54 < TOL)

pos <- c(t1_p1_pct_i = "MM14, 1º trimestre, p1", t1_p99_pct_i = "MM14, 1º trimestre, p99",
         t2_p1_pct_i = "MM14, 2º trimestre, p1", t2_p99_pct_i = "MM14, 2º trimestre, p99",
         mm9_p1_pct_i = "MM9, p1 (ao lado)", mm9_p99_pct_i = "MM9, p99 (ao lado)")
resumo <- data.frame(`Valor da média móvel` = unname(pos),
                     `Percentil semanal (i): média nas 26` = paste0("p", br(sapply(names(pos), function(k) mean(res[[k]])), 1)),
                     `Mínimo` = paste0("p", br(sapply(names(pos), function(k) min(res[[k]])), 1), " (", sapply(names(pos), function(k) res$concentracao[which.min(res[[k]])]), ")"),
                     `Máximo` = paste0("p", br(sapply(names(pos), function(k) max(res[[k]])), 1), " (", sapply(names(pos), function(k) res$concentracao[which.max(res[[k]])]), ")"),
                     check.names = FALSE)
print(resumo, row.names = FALSE)
eu <- readLines("00_scripts/08_mm14_equivalente_rerun.R", encoding = "UTF-8")
lin <- function(p) grep(p, eu, fixed = TRUE)[1]
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
o <- order(match(res$recorte_principal, nuc$CD_RECORTE))
md <- c("# A5: percentil semanal equivalente da MM14 (1º e 2º trimestres), com a MM9 ao lado (Fase 0 refeita)", "",
        sprintf("- **Gerado por:** `00_scripts/08_mm14_equivalente_rerun.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        "- **Só exposição:** `expo_semanal(\"tmean\", \"nucleo\")`, `dum_est` de 2011-04-17 a 2024-03-05 (4.707 por concentração). Nenhum desfecho.",
        "- **Método (o mesmo da MM9 na Fase 0A; decisões §7):** distribuição semanal (i) = todos os `s01`…`s37`, empilhados, sem ponderação; percentis com `quantile(type = 7)`; percentil equivalente = `ecdf` da (i) avaliada no valor, × 100, com uma casa.",
        "  - **Onde está na Fase 0A** (versão arquivada no `.tar`): no `02_recontagens_fase0.R`, linha 132 (`F <- ecdf(emp)`) e linha 141 (`mm9_p99_em_pct_semanal_i = 100 * F(qm[3])`); no `04_mm14_equivalentes_fase0.R`, linha 37 (`Fi <- ecdf(as.vector(m))`) e linhas 42–44 (`100 * Fi(q$t1[1])` …).",
        sprintf("  - **Onde está aqui (código diferente):** linha %d (`pct_i`, `findInterval` sobre a (i) ordenada = nº de valores ≤ x / n), linha %d (quantil tipo 7 à mão, conferido contra `quantile(type = 7)`: maior diferença %s) e linha %d (médias móveis por `%%*%%`).",
                lin("pct_i <- function"), lin("q7 <- function"), format(dif_q), lin("mm <- list(t1 = c(m[, 1:14]")),
        sprintf("- **Comparação com o complemento da Fase 0A** (`01_saidas/fase0/a5_4b_mm14_equivalentes.csv`, código do `04`): maior |diferença| em cada uma das 12 colunas numéricas = %s (tolerância %s).",
                format(max(d_comp)), format(TOL)),
        sprintf("- **Comparação com a A5.4 refeita** (`a5_4_semanal_mm.csv`, código do `02`): MM9 e MM14 em °C e percentil equivalente da MM9, maior |diferença| = %s.", format(max(d_a54))),
        sprintf("- **Resultado:** %s.", if (ok) "igual nas duas comparações" else "DIFERENTE: parar e reportar"),
        "- **CSV completo:** `01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv`, fora do git (mesmas colunas do `a5_4b` do complemento).", "",
        "## Resumo nas 26 concentrações", "", tabela_md(resumo), "",
        "## Por concentração (°C e percentil semanal equivalente na leitura (i))", "",
        tabela_md(data.frame(Concentração = res$concentracao[o],
                             `MM14 T1 p1 °C` = br(res$t1_p1[o], 2), `= p (i)` = br(res$t1_p1_pct_i[o], 1),
                             `MM14 T1 p99 °C` = br(res$t1_p99[o], 2), `= p (i) ` = br(res$t1_p99_pct_i[o], 1),
                             `MM14 T2 p1 °C` = br(res$t2_p1[o], 2), `= p (i)  ` = br(res$t2_p1_pct_i[o], 1),
                             `MM14 T2 p99 °C` = br(res$t2_p99[o], 2), `= p (i)   ` = br(res$t2_p99_pct_i[o], 1),
                             `MM9 p1 = p (i)` = br(res$mm9_p1_pct_i[o], 1), `MM9 p99 = p (i)` = br(res$mm9_p99_pct_i[o], 1),
                             check.names = FALSE)), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", csv_out, "e", arq, "| comparações:", if (ok) "iguais" else "DIFERENTES", "\n")
if (!ok) quit(status = 1)
