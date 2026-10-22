# 64_reconfere_series_fase1.R — Fase 4, Parte B1.1: reconferência das séries da Fase 1 (mensagem da Parte B do chat
# do A1, 18/10/2026, item B1.1; plano da Fase 4, script 64). Nenhum modelo.
# - SHA-256 dos seis arquivos da RESPOSTA da Fase 1 (l. 662–668), lidos da própria RESPOSTA (nunca digitados), contra
#   os arquivos em 01_saidas/fase1/. Divergência: PARE.
# - Reconstrução a partir da base 4443971b: os scripts 20, 21 e 22 da Fase 1, lidos do commit 5bc94ec por git show e com
#   o SHA-256 conferido contra a tabela da RESPOSTA, rodam numa caixa de areia dentro da Forja
#   (01_saidas/fase4/_reconstrucao_64_<RODADA>/, fora do git), com o offset.R da Fase 1 (também do 5bc94ec, SHA
#   conferido) e a A5.3 refeita que o 20 compara. Os três RDS saem identical() aos de 01_saidas/fase1/ e os três CSV
#   saem com o mesmo conteúdo (read.csv identical) e o mesmo SHA-256. Divergência: PARE.
# - A caixa de areia vai para a lixeira do volume (trash, que no disco externo fica no próprio volume) no fim; os SHA-256
#   do que ela gerou ficam no log.
# Sigilo: o log traz só SHA-256, nomes de arquivo e o resultado das comparações; nenhuma contagem nem série.
# Confere antes: este script commitado e limpo. Grava logs/reconferencia_series_fase1_fase4_<RODADA>.md. Nunca
# sobrescreve. Numa divergência, grava o log e sai com quit(status = 1).
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/64_reconfere_series_fase1.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("reconferencia_series_fase1_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/64_reconfere_series_fase1.R"
COMMIT_F1 <- "5bc94ec"
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")

# ------------------------------------------------------------------ cabeçalho (protocolo v1.1, 3.8)
sujos <- git("status", "--porcelain", "--", ESTE)
if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current")
st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:")
stopifnot(length(head_c) == 1L, length(ramo) == 1L, length(coord) == 1L)
inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"); t0 <- Sys.time()

# ------------------------------------------------------------------ 1. SHA-256 contra a RESPOSTA da Fase 1
resp <- readLines("RESPOSTA_artigo1_prematuridade_FASE1_20261009.md", encoding = "UTF-8")
l_arq <- grep("`01_saidas/fase1/[^`]+`: `[0-9a-f]{64}`", resp)
stopifnot(length(l_arq) == 6L, all(l_arq >= 662 & l_arq <= 668))                 # as seis linhas da l. 662–668
esp <- data.frame(arquivo = sub(".*`(01_saidas/fase1/[^`]+)`.*", "\\1", resp[l_arq]),
                  esperado = sub(".*`([0-9a-f]{64})`.*", "\\1", resp[l_arq]), stringsAsFactors = FALSE)
stopifnot(!anyDuplicated(esp$arquivo))
esp$obtido <- vapply(esp$arquivo, function(p) if (file.exists(p)) sha(p) else NA_character_, "")
esp$confere <- !is.na(esp$obtido) & esp$obtido == esp$esperado
ok_sha <- all(esp$confere)
log_msg("SHA-256 das seis séries:", sum(esp$confere), "de 6 conferem")

# ------------------------------------------------------------------ 2. reconstrução na caixa de areia
l_scr <- grep("^\\| `(00_scripts/2[012]_[^`]+|codigo_compartilhado/R/offset\\.R)` \\| `[0-9a-f]{64}` \\|", resp)
scr <- data.frame(caminho = sub("^\\| `([^`]+)`.*", "\\1", resp[l_scr]), esperado = sub(".*`([0-9a-f]{64})`.*", "\\1", resp[l_scr]), stringsAsFactors = FALSE)
stopifnot(setequal(scr$caminho, c("00_scripts/20_monta_serie_principal.R", "00_scripts/21_monta_serie_municipal.R",
                                  "00_scripts/22_monta_ptb_espontaneo.R", "codigo_compartilhado/R/offset.R")))
cx <- normalizePath(file.path("01_saidas", "fase4"), mustWork = FALSE); dir.create(cx, recursive = TRUE, showWarnings = FALSE)
cx <- file.path(normalizePath(cx), paste0("_reconstrucao_64_", rodada)); stopifnot(!file.exists(cx))
a1x <- file.path(cx, "artigo1_prematuridade")
for (d in c(file.path(a1x, "00_scripts"), file.path(a1x, "01_saidas", "fase0_rerun"), file.path(a1x, "logs"), file.path(cx, "codigo_compartilhado", "R")))
  dir.create(d, recursive = TRUE)
destino <- function(p) if (startsWith(p, "codigo_compartilhado/")) file.path(cx, p) else file.path(a1x, p)
no_git <- function(p) if (startsWith(p, "codigo_compartilhado/")) p else paste0("artigo1_prematuridade/", p)
for (i in seq_len(nrow(scr))) {
  txt <- system2("git", c("-C", REPO, "show", paste0(COMMIT_F1, ":", no_git(scr$caminho[i]))), stdout = TRUE)
  writeLines(txt, destino(scr$caminho[i]), useBytes = TRUE)
}
scr$obtido <- vapply(scr$caminho, function(p) sha(destino(p)), "")
scr$confere <- scr$obtido == scr$esperado
a53 <- file.path("01_saidas", "fase0_rerun", "a5_3_percentis_diarios.csv"); stopifnot(file.exists(a53))
file.copy(a53, file.path(a1x, a53), copy.date = TRUE)
writeLines(sprintf(".libPaths(c(\"%s\", .libPaths()))", .libPaths()[1]), file.path(a1x, ".Rprofile"))
rs <- file.path(R.home("bin"), "Rscript")
roda <- data.frame(script = c("20_monta_serie_principal.R", "21_monta_serie_municipal.R", "22_monta_ptb_espontaneo.R"), status = NA_integer_, segundos = NA_real_, stringsAsFactors = FALSE)
if (all(scr$confere)) {
  dir_ant <- setwd(a1x)
  for (k in seq_len(nrow(roda))) {
    log_msg("reconstrução:", roda$script[k]); tk <- Sys.time()
    st <- system2(rs, file.path("00_scripts", roda$script[k]), env = "FASE1_DATA=19000101",
                  stdout = file.path("logs", paste0("saida_", roda$script[k], ".txt")), stderr = file.path("logs", paste0("erro_", roda$script[k], ".txt")))
    roda$status[k] <- st; roda$segundos[k] <- as.numeric(difftime(Sys.time(), tk, units = "secs"))
    if (st != 0) break
  }
  setwd(dir_ant)
}
ok_roda <- all(scr$confere) && all(roda$status %in% 0L)

# ------------------------------------------------------------------ 3. comparação com 01_saidas/fase1/
comp <- data.frame(arquivo = esp$arquivo, stringsAsFactors = FALSE)
comp$sha_reconstruido <- vapply(comp$arquivo, function(p) { q <- file.path(a1x, p); if (file.exists(q)) sha(q) else NA_character_ }, "")
comp$mesmo_sha <- !is.na(comp$sha_reconstruido) & comp$sha_reconstruido == esp$obtido
comp$identical_objeto <- vapply(comp$arquivo, function(p) {
  q <- file.path(a1x, p); if (!file.exists(q)) return(FALSE)
  if (grepl("\\.rds$", p)) identical(readRDS(p), readRDS(q))
  else identical(read.csv(p, stringsAsFactors = FALSE, colClasses = "character"), read.csv(q, stringsAsFactors = FALSE, colClasses = "character"))
}, TRUE)
eh_csv <- grepl("\\.csv$", comp$arquivo)
ok_comp <- ok_roda && all(comp$identical_objeto) && all(comp$mesmo_sha[eh_csv])
ok <- ok_sha && ok_comp
log_msg("reconstrução:", if (ok_comp) "idêntica" else "DIVERGE")

# ------------------------------------------------------------------ 4. caixa de areia para a lixeira do volume
sha_cx <- if (dir.exists(a1x)) { fs <- list.files(a1x, recursive = TRUE, full.names = TRUE, all.files = TRUE); fs <- fs[!grepl("/\\._", fs)]
  data.frame(arquivo = sub(paste0("^", a1x, "/"), "", fs), sha256 = vapply(fs, sha, ""), stringsAsFactors = FALSE) } else NULL
st_lixo <- system2("trash", shQuote(cx)); lixo_ok <- st_lixo == 0 && !file.exists(cx)
stopifnot(versao() == "4443971b"); v_fim <- versao()

# ------------------------------------------------------------------ log
md <- c("# Fase 4, Parte B1.1: reconferência das séries da Fase 1 (SHA-256 e reconstrução a partir da base)", "",
  sprintf("- **Gerado por:** `00_scripts/64_reconfere_series_fase1.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()` no início: %s; no fim: %s.",
          sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini, v_fim),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Ambiente:** R %s; arrow %s. Semente 20261001 (Mersenne-Twister, Inversion, Rejection), sem sorteio neste script.", paste(R.version$major, R.version$minor, sep = "."), packageVersion("arrow")), "",
  "## 1. SHA-256 das seis séries contra a RESPOSTA da Fase 1 (l. 662–668)", "",
  tabela_md(data.frame(Arquivo = paste0("`", esp$arquivo, "`"), Esperado = paste0("`", esp$esperado, "`"), Obtido = paste0("`", esp$obtido, "`"),
                       Confere = ifelse(esp$confere, "sim", "NÃO"), check.names = FALSE)), "",
  "## 2. Reconstrução a partir da base 4443971b", "",
  sprintf("- **Código:** os scripts 20, 21 e 22 e o `offset.R` da Fase 1, lidos do commit `%s` por `git show`, com o SHA-256 conferido contra a tabela da RESPOSTA da Fase 1:", COMMIT_F1), "",
  tabela_md(data.frame(Arquivo = paste0("`", scr$caminho, "`"), Esperado = paste0("`", scr$esperado, "`"), Obtido = paste0("`", scr$obtido, "`"),
                       Confere = ifelse(scr$confere, "sim", "NÃO"), check.names = FALSE)), "",
  sprintf("- **Caixa de areia:** `01_saidas/fase4/_reconstrucao_64_%s/` (fora do git, dentro da Forja), com a mesma árvore relativa (`artigo1_prematuridade/` e `codigo_compartilhado/R/`), a A5.3 refeita copiada (SHA-256 `%s`) e um `.Rprofile` que põe a biblioteca do `renv` do A1 na frente. Cada script rodou com `FASE1_DATA=19000101`.", rodada, sha(a53)),
  tabela_md(data.frame(Script = paste0("`", roda$script, "`"), `Saída` = ifelse(is.na(roda$status), "não rodou", as.character(roda$status)),
                       Segundos = ifelse(is.na(roda$segundos), "—", sprintf("%.0f", roda$segundos)), check.names = FALSE)), "",
  "## 3. Comparação com `01_saidas/fase1/`", "",
  tabela_md(data.frame(Arquivo = paste0("`", comp$arquivo, "`"), `identical() do objeto` = ifelse(comp$identical_objeto, "sim", "NÃO"),
                       `Mesmo SHA-256 do arquivo` = ifelse(comp$mesmo_sha, "sim", ifelse(eh_csv, "NÃO", "não (RDS: só o objeto conta)")), check.names = FALSE)), "",
  "- Nos RDS conta o `identical()` do objeto lido (`readRDS`); o arquivo pode diferir em bytes de compressão sem diferir no conteúdo. Nos CSV contam o conteúdo (`read.csv` com todas as colunas em texto, `identical()`) e o SHA-256.", "",
  "## 4. Caixa de areia", "",
  sprintf("- **Para a lixeira do volume** (`trash`): %s.", if (lixo_ok) "feito; a caixa não existe mais no caminho original" else "FALHOU; a caixa ficou no lugar"),
  "- **SHA-256 do que a caixa continha** (séries e logs agregados da reconstrução):", "",
  if (!is.null(sha_cx)) tabela_md(data.frame(Arquivo = paste0("`", sha_cx$arquivo, "`"), `SHA-256` = paste0("`", sha_cx$sha256, "`"), check.names = FALSE)) else "- (nada)", "",
  sprintf("- **Resultado:** %s. Tempo total: %.0f s.", if (ok) "as seis séries conferem pelo SHA-256 e a reconstrução a partir da base é idêntica" else "DIVERGÊNCIA: PARE (ver as tabelas)",
          as.numeric(difftime(Sys.time(), t0, units = "secs"))), "")
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| SHA:", sum(esp$confere), "/ 6 | reconstrução:", if (ok_comp) "idêntica" else "DIVERGE", "| ok:", ok, "\n")
if (!ok) quit(status = 1)
