# 24_testes_compartilhado_fase1.R — Fase 1, A1: testes sintéticos de calcula_wj() e monta_offset()
# (codigo_compartilhado/R/offset.R) e 3 defeitos plantados. Roda antes do 20 (desvio 43). Não lê a base: o source do
# acesso.R serve só para registrar versao() no início e no fim, como em todo script da fase.
# - Bateria: codigo_compartilhado/tests/testa_offset.R, executor roda_testes.R (R base; desvio 42). Tem de passar n/n.
# - Defeitos: cada um é uma troca de texto numa CÓPIA do offset.R, numa pasta temporária (o original não é tocado; o
#   SHA-256 dele é conferido antes e depois). Cada defeito tem de derrubar pelo menos um teste.
# Grava logs/testes_compartilhado_fase1_<FASE1_DATA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE1_DATA=AAAAMMDD Rscript 00_scripts/24_testes_compartilhado_fase1.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE1_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("testes_compartilhado_fase1_", hoje, ".md")); stopifnot(!file.exists(arq))
CC <- file.path("..", "codigo_compartilhado")
f_fun <- file.path(CC, "R", "offset.R"); f_tes <- file.path(CC, "tests", "testa_offset.R"); f_run <- file.path(CC, "tests", "roda_testes.R")
stopifnot(file.exists(f_fun), file.exists(f_tes), file.exists(f_run))
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
sha_fun_antes <- sha(f_fun)
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))

source(f_run); source(f_tes)
f0 <- new.env(); sys.source(f_fun, envir = f0)
r0 <- roda_testes(f0, testes_offset)
print(r0[, c("teste", "ok")], row.names = FALSE)
cat("bateria original:", sum(r0$ok), "/", nrow(r0), "\n")

src <- paste0(paste(readLines(f_fun, encoding = "UTF-8"), collapse = "\n"), "\n")
defeitos <- list(
  list(nome = "N_j com > em vez de ≥",
       de = "N_j <- vapply(semanas, function(j) sum(ig >= j), numeric(1))",
       para = "N_j <- vapply(semanas, function(j) sum(ig > j), numeric(1))"),
  list(nome = "W_t sem dividir por Z_t",
       de = "out$w_t <- ifelse(pos, s_zw / ifelse(pos, z_t, 1), NA_real_)",
       para = "out$w_t <- ifelse(pos, s_zw, NA_real_)"),
  list(nome = "semana 36 fora da soma",
       de = "dentro <- as.integer(z_tj$semana) %in% semanas",
       para = "dentro <- as.integer(z_tj$semana) %in% setdiff(semanas, 36L)"))
res_def <- lapply(defeitos, function(d) {
  n <- lengths(regmatches(src, gregexpr(d$de, src, fixed = TRUE)))
  stopifnot(n == 1)                                                    # o alvo existe e é único
  tf <- file.path(tempdir(), "offset_com_defeito.R"); writeLines(sub(d$de, d$para, src, fixed = TRUE), tf, useBytes = TRUE)
  g <- new.env(); sys.source(tf, envir = g)
  rr <- roda_testes(g, testes_offset); unlink(tf)
  data.frame(Defeito = d$nome, `Troca na cópia` = paste0("`", d$de, "` → `", d$para, "`"),
             `Testes que falham` = sum(!rr$ok), Quais = paste(rr$teste[!rr$ok], collapse = ", "), check.names = FALSE)
})
res_def <- do.call(rbind, res_def)
print(res_def[, c("Defeito", "Testes que falham")], row.names = FALSE)
sha_fun_depois <- sha(f_fun)
ok <- all(r0$ok) && all(res_def$`Testes que falham` >= 1) && identical(sha_fun_antes, sha_fun_depois)

stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
md <- c("# Fase 1, A1: testes de `calcula_wj()` e `monta_offset()` e defeitos plantados", "",
        sprintf("- **Gerado por:** `00_scripts/24_testes_compartilhado_fase1.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha). O script não lê a base.",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        "- **Arquivos testados (SHA-256):**",
        sprintf("  - `codigo_compartilhado/R/offset.R`: `%s` (igual antes e depois dos defeitos: %s);", sha_fun_antes, if (identical(sha_fun_antes, sha_fun_depois)) "sim" else "NÃO"),
        sprintf("  - `codigo_compartilhado/tests/testa_offset.R`: `%s`;", sha(f_tes)),
        sprintf("  - `codigo_compartilhado/tests/roda_testes.R`: `%s`.", sha(f_run)),
        "- **Testes:** só com dado sintético, em R base, sem `testthat` (desvio 42). Um teste passa se terminar sem erro e sem aviso.", "",
        "## Funções", "",
        "- **`calcula_wj(ig, semanas)`:** w_j = n_j / N_j, com n_j = nº com `ig` = j e N_j = nº com `ig` ≥ j, contados em toda a população recebida. Devolve `j`, `n_j`, `N_j` e `w_j`. Para se houver NA ou valor não inteiro em `ig`, ou N_j = 0.",
        "- **`monta_offset(z_tj, w, semanas, periodo)`** (`periodo` obrigatório, NULL ou c(início, fim); desvio 48): Z_t = Σ_j Z_tj; W_t = Σ_j Z_tj·w_j / Z_t; `log_z`, `log_w`, `log_zw` = log(Σ_j Z_tj·w_j) (offset com γ = 1); `z_t_zero`.",
        "  - Offset NA fora do `periodo` e com Z_t = 0; `w_t` NA com Z_t = 0. Nunca −Inf.",
        "  - Para com erro se: `periodo` não for NULL nem c(início, fim) com início ≤ fim; semana de `semanas` sem w_j; w_j negativo; Z_tj negativo ou NA; dia do `periodo` com Z_t = 0 ou ausente (por unidade); com `periodo = NULL`, dia faltando no meio da grade de alguma unidade; Σ_j Z_tj·w_j = 0 com Z_t > 0 num dia com offset (desvio 49).",
        "  - Entrada esparsa (desvios 44, 48 e 49): a chave é `data` mais as demais colunas que não são `semana` nem `z`; semanas fora de `semanas` são ignoradas; com `periodo = NULL`, os dias de Z_t = 0 são marcados, e a grade tem de vir completa do primeiro ao último dia de cada unidade (quem chama inclui os dias sem célula com z = 0 e garante o intervalo).", "",
        sprintf("## Bateria original: %d/%d", sum(r0$ok), nrow(r0)), "",
        tabela_md(data.frame(Teste = paste0("`", r0$teste, "`"), Resultado = ifelse(r0$ok, "passou", paste("FALHOU:", r0$mensagem)), check.names = FALSE)), "",
        "## Defeitos plantados (cada um numa cópia; tem de derrubar pelo menos um teste)", "",
        tabela_md(res_def), "",
        sprintf("- **Resultado:** %s.", if (ok) "bateria original passa inteira e os 3 defeitos são detectados" else "FALHA: parar e reportar"), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| resultado:", if (ok) "ok" else "FALHA", "\n")
if (!ok) quit(status = 1)
