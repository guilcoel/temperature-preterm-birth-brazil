# 83_feriados_locais_v11_fase4.R — Fase 4, Parte B2: validação da tabela de feriados locais v1.1 (critério da D17, 2.0)
# e patch para a COORD (D17, 2f; mensagem da COORD de 19/10, item 4.6: tabela, README, SHA256SUMS e LEIAME, sem diff do
# .gitignore nem do checa_sigilo.sh, que já valem para o mesmo caminho). Só dado público; nenhum desfecho.
# Entrada: 01_saidas/fase4/feriados/feriados_locais_nucleo_2011_2024.csv e README_feriados_locais.md (rodada 3 da
#   pesquisa, pela D17, auditada antes de rodar este script); a v1.0 lida da tag feriados_locais-v1.0, para a diferença.
# Validação (falha: grava o log e quit(status = 1), sem patch): a mesma do 69 (esquema de 8 colunas, < 1 MB, campos
#   cheios, concentração entre as 26 e cidade-núcleo de cidade_nucleo(), datas de 2011 a 2024, esfera, URL, nenhuma data
#   nacional ou móvel do modelo, nenhum 24/12 nem 31/12, nenhum 20/11 de 2024, sem duplicata), mais as datas citadas na
#   D17: DF 30/11 em 2011–2024; AL 30/11 em 2018–2024 e nenhum antes; AL 16/09 em 2024 (os anos de 2011 a 2023 presentes
#   são listados, porque entram só com o decreto do ano); SP 2020 com 20 e 21/05 e sem 20/11.
# Verificação: o ferramentas/checa_sigilo.sh do HEAD (que já tem a exceção de caminho exato) num repositório git
#   temporário fora do projeto: a tabela nova no caminho exato passa; cabeçalho errado, coluna a mais e .csv em outro
#   caminho são barrados.
# Patch (fora do git): ~/Downloads/patch_feriados_locais_v1.1_<RODADA>/ e o zip de mesmo nome, com
#   codigo_compartilhado/dados_referencia/ (tabela e README.md), LEIAME_PATCH.md e SHA256SUMS.
# Grava logs/feriados_locais_v11_fase4_<RODADA>.md. Nunca sobrescreve. Confere antes: este script commitado e limpo.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD [SUFIXO=b] Rscript 00_scripts/83_feriados_locais_v11_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
sufixo <- Sys.getenv("SUFIXO"); stopifnot(grepl("^[a-z]?$", sufixo))   # reentrega no mesmo dia: SUFIXO=b, c… (nunca sobrescreve)
rotulo <- paste0(rodada, if (nzchar(sufixo)) paste0("_", sufixo) else "")
arq <- file.path("logs", paste0("feriados_locais_v11_fase4_", rotulo, ".md")); stopifnot(!file.exists(arq))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/83_feriados_locais_v11_fase4.R"
F_CSV <- file.path("01_saidas", "fase4", "feriados", "feriados_locais_nucleo_2011_2024.csv")
F_README <- file.path("01_saidas", "fase4", "feriados", "README_feriados_locais.md")
CAMINHO <- "codigo_compartilhado/dados_referencia/feriados_locais_nucleo_2011_2024.csv"
PATCH <- file.path(Sys.getenv("HOME"), "Downloads", paste0("patch_feriados_locais_v1.1_", rotulo)); ZIP <- paste0(PATCH, ".zip")
stopifnot(file.exists(F_CSV), file.exists(F_README), !file.exists(PATCH), !file.exists(ZIP))
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
sujos <- git("status", "--porcelain", "--", ESTE)
if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current")
st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:")
inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
tag_v10 <- git("rev-parse", "feriados_locais-v1.0^{commit}")
v10 <- utils::read.csv(text = paste(git("show", paste0(tag_v10, ":", CAMINHO)), collapse = "\n"), colClasses = "character", encoding = "UTF-8", check.names = FALSE, na.strings = character(0))
sha_v10 <- { tf <- tempfile(); writeLines(git("show", paste0(tag_v10, ":", CAMINHO)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
stopifnot(identical(sha_v10, "ef5d99b1bfb1d0a33f44ad057e8b542015ce61aa9da5fb3d73caf117daba2e03"))

# ------------------------------------------------------------------ validação (a do 69, mais as datas da D17)
CAB <- c("concentracao", "cidade_nucleo", "data", "nome", "esfera", "ato_normativo", "url_fonte", "conferido_por")
falhas <- character(0); confere <- function(cond, txt) { if (!isTRUE(cond)) falhas <<- c(falhas, txt); isTRUE(cond) }
cab_txt <- readLines(F_CSV, n = 1, encoding = "UTF-8", warn = FALSE)
confere(identical(sub("\r$", "", cab_txt), paste(CAB, collapse = ",")), "cabeçalho diferente das 8 colunas da D11, 3.3")
confere(file.size(F_CSV) < 1048576, "tabela com 1 MB ou mais")
t <- utils::read.csv(F_CSV, colClasses = "character", encoding = "UTF-8", check.names = FALSE, na.strings = character(0))
confere(identical(names(t), CAB), "colunas lidas ≠ as 8 da D11")
confere(all(nzchar(trimws(as.matrix(t)))), "campo vazio na tabela")
nuc <- as.data.frame(cidade_nucleo()); nome_nuc <- setNames(nuc$NM_MUN_NUCLEO, nuc$CD_RECORTE)
confere(all(t$concentracao %in% nuc$CD_RECORTE), "código de concentração fora das 26")
confere(all(t$cidade_nucleo == nome_nuc[t$concentracao]), "cidade_nucleo ≠ município-núcleo de cidade_nucleo()")
d <- as.Date(t$data, format = "%Y-%m-%d")
confere(!anyNA(d) && all(format(d, "%Y-%m-%d") == t$data), "data inválida ou fora do formato AAAA-MM-DD")
confere(all(d >= as.Date("2011-01-01") & d <= as.Date("2024-12-31"), na.rm = TRUE), "data fora de 2011–2024")
confere(all(t$esfera %in% c("estadual", "municipal")), "esfera fora de {estadual, municipal}")
confere(all(grepl("^https?://", t$url_fonte)), "url_fonte sem http")
cal <- as.data.frame(calendario()); cal$data <- as.Date(cal$data)
no_modelo <- cal$data[cal$feriado_nacional == 1 | cal$carnaval == 1 | cal$quarta_cinzas == 1 | cal$sexta_paixao == 1 | cal$corpus_christi == 1]
sob <- d %in% no_modelo; confere(!any(sob), paste0("datas que coincidem com feriado nacional ou móvel no modelo: ", sum(sob)))
md_ <- format(d, "%m-%d"); ano <- format(d, "%Y")
confere(!any(md_ %in% c("12-24", "12-31")), "24/12 ou 31/12 na tabela (entram pelo indicador)")
confere(!any(md_ == "11-20" & ano == "2024"), "20/11 de 2024 na tabela (nacional)")
dup <- duplicated(t[, c("concentracao", "data")]); confere(!any(dup), paste0("duplicatas (concentracao, data): ", sum(dup)))
DF <- "5300108"; MCZ <- "2704302"; SP <- "3550308"
df_30 <- sort(ano[t$concentracao == DF & md_ == "11-30"]); confere(identical(df_30, as.character(2011:2024)), "DF 30/11 não está em todos os anos de 2011 a 2024 (D17, 2c)")
ev <- t$concentracao == MCZ & t$esfera == "estadual" & grepl("Evang", t$nome) & md_ %in% c("11-29", "11-30", "12-01")   # data efetiva (D17, 2b e 2e): 29/11/2021, 01/12/2023
al_30 <- sort(unique(ano[ev])); confere(identical(al_30, as.character(2018:2024)) && !any(grepl("Evang", t$nome[t$concentracao == MCZ]) & ano[t$concentracao == MCZ] < "2018"), "AL, Dia do Evangélico estadual fora de 2018–2024 ou faltando ano (D17, 2c)")
al_16 <- sort(ano[t$concentracao == MCZ & md_ == "09-16"]); confere("2024" %in% al_16, "AL 16/09 de 2024 ausente (Lei 9.358/2024)")
sp20 <- t$data[t$concentracao == SP & ano == "2020"]
confere(all(c("2020-05-20", "2020-05-21") %in% sp20) && !("2020-11-20" %in% sp20) && !("2020-05-22" %in% sp20), "SP 2020 fora do 2b da D17 (20 e 21/05 entram; 20/11 sai; 22/05 é ponto facultativo)")
ok <- length(falhas) == 0
fmt_anos <- function(a) if (length(a)) paste(range(a), collapse = "–") else "nenhum ano"
por_nucleo <- data.frame(Concentração = nuc$NM_RECORTE, `Cidade-núcleo` = nuc$NM_MUN_NUCLEO,
                         Estaduais = vapply(nuc$CD_RECORTE, function(r) sum(t$concentracao == r & t$esfera == "estadual"), 0L),
                         Municipais = vapply(nuc$CD_RECORTE, function(r) sum(t$concentracao == r & t$esfera == "municipal"), 0L), check.names = FALSE)
por_nucleo$Total <- por_nucleo$Estaduais + por_nucleo$Municipais
# diferença contra a v1.0 (por chave concentração × data)
k1 <- paste(t$concentracao, t$data); k0 <- paste(v10$concentracao, v10$data)
nova <- !(k1 %in% k0); removida <- !(k0 %in% k1)
comum <- k1[k1 %in% k0]; a1 <- t[match(comum, k1), ]; a0 <- v10[match(comum, k0), ]
alterada <- rowSums(as.matrix(a1[, setdiff(CAB, "conferido_por")]) != as.matrix(a0[, setdiff(CAB, "conferido_por")])) > 0
dif_nuc <- data.frame(Concentração = nuc$NM_RECORTE,
                      `v1.0` = vapply(nuc$CD_RECORTE, function(r) sum(v10$concentracao == r), 0L),
                      Novas = vapply(nuc$CD_RECORTE, function(r) sum(t$concentracao[nova] == r), 0L),
                      Removidas = vapply(nuc$CD_RECORTE, function(r) sum(v10$concentracao[removida] == r), 0L),
                      Alteradas = vapply(nuc$CD_RECORTE, function(r) sum(a1$concentracao[alterada] == r), 0L),
                      `v1.1` = por_nucleo$Total, check.names = FALSE)
dif_nuc <- dif_nuc[dif_nuc$Novas + dif_nuc$Removidas + dif_nuc$Alteradas > 0, ]

# ------------------------------------------------------------------ verificação com o checa_sigilo.sh do HEAD e patch
verif <- NULL; sha_patch <- NULL
if (ok) {
  tr <- file.path(tempdir(), "verifica_v11"); dir.create(file.path(tr, "ferramentas"), recursive = TRUE)
  writeLines(git("show", "HEAD:ferramentas/checa_sigilo.sh"), file.path(tr, "ferramentas", "checa_sigilo.sh"), useBytes = TRUE)
  vg <- function(...) system2("git", c("-C", tr, ...), stdout = TRUE, stderr = TRUE)
  vg("init", "-q"); vg("config", "user.email", "teste@local.invalid"); vg("config", "user.name", "teste")
  caso <- function(rotulo, caminho, conteudo, esperado) {
    dir.create(dirname(file.path(tr, caminho)), recursive = TRUE, showWarnings = FALSE); writeLines(conteudo, file.path(tr, caminho), useBytes = TRUE)
    vg("add", "-f", caminho)
    s <- system(paste("cd", shQuote(tr), "&& sh ferramentas/checa_sigilo.sh >/dev/null 2>&1; echo $?"), intern = TRUE)
    vg("rm", "-q", "--cached", caminho); unlink(file.path(tr, caminho))
    data.frame(Caso = rotulo, Esperado = esperado, Obtido = as.integer(s), stringsAsFactors = FALSE) }
  real <- readLines(F_CSV, encoding = "UTF-8", warn = FALSE)
  verif <- rbind(caso("tabela v1.1 no caminho exato", CAMINHO, real, 0L),
                 caso("cabeçalho errado no caminho exato", CAMINHO, c("a,b", "1,2"), 1L),
                 caso("coluna a mais no caminho exato", CAMINHO, paste0(real[1], ",extra"), 1L),
                 caso(".csv em outro caminho", "codigo_compartilhado/dados_referencia/outro.csv", real, 1L))
  unlink(tr, recursive = TRUE)
  if (!all(verif$Esperado == verif$Obtido)) falhas <- c(falhas, "a verificação com o checa_sigilo.sh do HEAD falhou")
}
ok <- length(falhas) == 0
if (ok) {
  dir.create(file.path(PATCH, "codigo_compartilhado", "dados_referencia"), recursive = TRUE)
  file.copy(F_CSV, file.path(PATCH, CAMINHO)); file.copy(F_README, file.path(PATCH, "codigo_compartilhado", "dados_referencia", "README.md"))
  writeLines(c("# Patch dos feriados locais v1.1 para a COORD (D17, 2f)", "",
               sprintf("Gerado por `artigo1_prematuridade/00_scripts/83_feriados_locais_v11_fase4.R` (rodada %s), sobre o `HEAD` `%s`.", rotulo, head_c), "",
               "1. Conferir o `SHA256SUMS`.",
               "2. Copiar `codigo_compartilhado/dados_referencia/` (a tabela v1.1 e o `README.md`) para a mesma pasta do repositório, por cima da v1.0.",
               "3. Sem diff do `.gitignore` nem do `checa_sigilo.sh`: as exceções de caminho exato da v1.0 valem para a v1.1 (mesmo caminho, mesmo cabeçalho, < 1 MB).",
               "4. Commit da COORD, com o [ok] de Guilherme; a tag `feriados_locais-v1.1` vem depois, sobre commit já no remoto, com autorização nomeando tag e SHA.",
               "5. O SHA-256 da tabela v1.1 entra nos logs do A1 e do A2 (D11, 3.3; D17, 2f)."), file.path(PATCH, "LEIAME_PATCH.md"), useBytes = TRUE)
  fs <- sort(list.files(PATCH, recursive = TRUE)); fs <- fs[!grepl("(^|/)\\._", fs)]
  writeLines(vapply(fs, function(p) paste0(sha(file.path(PATCH, p)), "  ", p), ""), file.path(PATCH, "SHA256SUMS"))
  system(paste("cd", shQuote(PATCH), "&& zip -q -X -r", shQuote(ZIP), ". -x '.*' -x '*/._*' -x '._*'"))
  sha_patch <- c(zip = sha(ZIP), tabela = sha(F_CSV), readme = sha(F_README))
}
stopifnot(versao() == "4443971b")
md <- c("# Fase 4, Parte B2: feriados locais v1.1 (D17; validação e patch para a COORD)", "",
  sprintf("- **Gerado por:** `00_scripts/83_feriados_locais_v11_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()` no início e no fim: %s.",
          sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rotulo, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Entrada:** `%s` (SHA-256 `%s`; %s linhas, %d núcleos) e `%s` (SHA-256 `%s`). **v1.0:** tag `feriados_locais-v1.0` (`%s`), tabela `%s` (%s linhas).",
          F_CSV, sha(F_CSV), br(nrow(t)), length(unique(t$concentracao)), F_README, sha(F_README), substr(tag_v10, 1, 7), sha_v10, br(nrow(v10))), "",
  "## Validação", "",
  if (ok) "- Esquema, núcleos, datas, esferas, URLs, sobreposição com os feriados nacionais e os móveis do modelo, 24/12, 31/12, 20/11 de 2024, duplicatas e as datas citadas na D17: tudo confere." else paste0("- **FALHA:** ", falhas),
  sprintf("- **D17, 2c:** DF 30/11 em %s; AL 30/11 em %s; AL 16/09 em %s (de 2011 a 2023, só nos anos com o decreto achado; os ausentes estão no README).",
          fmt_anos(df_30), fmt_anos(al_30), if (length(al_16)) paste(al_16, collapse = ", ") else "nenhum ano"), "",
  "## Diferença contra a v1.0 (por concentração × data)", "",
  sprintf("- **Novas:** %d. **Removidas:** %d. **Alteradas** (nome, esfera, ato ou URL): %d.", sum(nova), sum(removida), sum(alterada)), "",
  tabela_md(dif_nuc), "",
  "## Datas por núcleo (2011–2024), v1.1", "", tabela_md(por_nucleo), "",
  if (!is.null(verif)) c("## Verificação com o `checa_sigilo.sh` do `HEAD` num repositório temporário", "", tabela_md(verif), "") else character(0),
  "## Patch para a COORD (fora do git)", "",
  if (ok) sprintf("- `%s` (SHA-256 `%s`), com a tabela (`%s`), o README (`%s`), o `LEIAME_PATCH.md` e o `SHA256SUMS`.", ZIP, sha_patch[["zip"]], sha_patch[["tabela"]], sha_patch[["readme"]]) else "- Não gerado.",
  "", sprintf("- **Resultado:** %s.", if (ok) "validação e patch ok" else "FALHA: sem patch"), "")
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "|", if (ok) "ok" else "FALHA", "\n")
if (!ok) quit(status = 1)
