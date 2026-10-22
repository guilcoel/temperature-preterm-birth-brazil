# 69_feriados_locais_fase4.R — Fase 4, Parte B2: validação da tabela de feriados locais dos núcleos e montagem do patch
# para a COORD (mensagem da Parte B do chat do A1, 18/10/2026, item 3; D11, 3.3; P12). Só dado público; nenhum desfecho.
# Entrada: 01_saidas/fase4/feriados/feriados_locais_nucleo_2011_2024.csv e README_feriados_locais.md (pesquisa na web
#   por subagente, B2; conferida data a data por auditoria independente antes de rodar este script).
# Validação (falha: grava o log e quit(status = 1), sem patch):
#   - esquema: cabeçalho igual às 8 colunas da D11, 3.3 (concentracao, cidade_nucleo, data, nome, esfera, ato_normativo,
#     url_fonte, conferido_por), nenhum outro campo, nenhum campo vazio, arquivo < 1 MB;
#   - concentracao entre as 26 e cidade_nucleo igual ao município-núcleo de cidade_nucleo();
#   - datas válidas, de 2011-01-01 a 2024-12-31; esfera "estadual" ou "municipal"; url_fonte começando por http;
#   - nenhuma data que coincida com feriado nacional ou com os móveis já no modelo (carnaval, quarta de cinzas, sexta da
#     paixão, corpus christi), pelo calendario() da base;
#   - nenhum 24/12 nem 31/12 (entram só no indicador); nenhum 20/11 em 2024 (nacional);
#   - sem duplicata (concentracao, data).
# Patch para a COORD (D11, 3.3; P12), em ~/Downloads/patch_feriados_locais_<RODADA>/ e no zip de mesmo nome:
#   - codigo_compartilhado/dados_referencia/feriados_locais_nucleo_2011_2024.csv e README.md;
#   - gitignore.diff: as duas linhas de exceção de caminho exato;
#   - checa_sigilo.diff: a segunda exceção de caminho exato (como a do renv/settings.json), com as três exigências da
#     P12 (cabeçalho = as 8 colunas, nenhum outro campo, menos de 1 MB);
#   - testa_checa_sigilo.diff: os casos de teste (positivo: cabeçalho errado no caminho exato e .csv em outro caminho;
#     negativo: a tabela no caminho exato), preparados no índice por git update-index --cacheinfo, sem tocar a pasta de
#     trabalho (a tabela real no caminho exato não pode ser sobrescrita);
#   - LEIAME_PATCH.md e SHA256SUMS.
#   O patch é conferido aqui num repositório git temporário (fora do repositório do projeto): o checa_sigilo.sh com a
#   exceção deixa passar a tabela no caminho exato e barra o cabeçalho errado e o .csv em outro caminho.
#   O A1 não commita nada em codigo_compartilhado/dados_referencia/ nem em ferramentas/: a COORD aplica, Guilherme aprova
#   e a tag feriados_locais-v1.0 vem depois.
# Grava logs/feriados_locais_fase4_<RODADA>.md. Nunca sobrescreve. Confere antes: este script commitado e limpo.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/69_feriados_locais_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("feriados_locais_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/69_feriados_locais_fase4.R"
F_CSV <- file.path("01_saidas", "fase4", "feriados", "feriados_locais_nucleo_2011_2024.csv")
F_README <- file.path("01_saidas", "fase4", "feriados", "README_feriados_locais.md")
PATCH <- file.path(Sys.getenv("HOME"), "Downloads", paste0("patch_feriados_locais_", rodada)); ZIP <- paste0(PATCH, ".zip")
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

# ------------------------------------------------------------------ validação
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
md_ <- format(d, "%m-%d"); confere(!any(md_ %in% c("12-24", "12-31")), "24/12 ou 31/12 na tabela")
confere(!any(md_ == "11-20" & format(d, "%Y") == "2024"), "20/11 de 2024 na tabela (nacional)")
dup <- duplicated(t[, c("concentracao", "data")]); confere(!any(dup), paste0("duplicatas (concentracao, data): ", sum(dup)))
ok <- length(falhas) == 0
por_nucleo <- data.frame(Concentração = nuc$NM_RECORTE, `Cidade-núcleo` = nuc$NM_MUN_NUCLEO,
                         Estaduais = vapply(nuc$CD_RECORTE, function(r) sum(t$concentracao == r & t$esfera == "estadual"), 0L),
                         Municipais = vapply(nuc$CD_RECORTE, function(r) sum(t$concentracao == r & t$esfera == "municipal"), 0L), check.names = FALSE)
por_nucleo$Total <- por_nucleo$Estaduais + por_nucleo$Municipais

# ------------------------------------------------------------------ patch (só com a validação ok)
sha_patch <- NULL; verif <- NULL
if (ok) {
  dir.create(file.path(PATCH, "codigo_compartilhado", "dados_referencia"), recursive = TRUE)
  file.copy(F_CSV, file.path(PATCH, "codigo_compartilhado", "dados_referencia", "feriados_locais_nucleo_2011_2024.csv"))
  file.copy(F_README, file.path(PATCH, "codigo_compartilhado", "dados_referencia", "README.md"))
  novo <- function(orig, f) { tf <- file.path(tempdir(), basename(orig)); writeLines(f(readLines(file.path(REPO, orig), warn = FALSE)), tf, useBytes = TRUE); tf }
  # .gitignore: as duas exceções de caminho exato, logo depois das do codigo_compartilhado
  gi <- novo(".gitignore", function(l) { i <- max(grep("^!/codigo_compartilhado/", l))
    append(l, c("!/codigo_compartilhado/dados_referencia/feriados_locais_nucleo_2011_2024.csv", "!/codigo_compartilhado/dados_referencia/README.md"), after = i) })
  # checa_sigilo.sh: segunda exceção de caminho exato, com as três exigências da P12
  cs <- novo("ferramentas/checa_sigilo.sh", function(l) {
    i_cab <- which(l == "# liberada no .gitignore). O limite de tamanho vale também para ela."); stopifnot(length(i_cab) == 1)
    l <- append(l, c("# Segunda exceção, também de caminho exato: ^codigo_compartilhado/dados_referencia/feriados_locais_nucleo_2011_2024\\.csv$",
                     "# (tabela de feriados locais da D11, 3.3; P12). Exigências: cabeçalho igual às 8 colunas da D11, 3.3, nenhum outro",
                     "# campo e blob menor que 1 MB; se alguma falhar, barra."), after = i_cab)
    i_ex <- which(l == "  if printf '%s\\n' \"$f\" | grep -Eq '^artigo[^/]*/renv/settings\\.json$'; then"); stopifnot(length(i_ex) == 1)
    bloco <- c("  if printf '%s\\n' \"$f\" | grep -Eq '^codigo_compartilhado/dados_referencia/feriados_locais_nucleo_2011_2024\\.csv$'; then",
               "    excecao=1",
               "    cab=$(git show \":$f\" 2>/dev/null | head -n 1 | tr -d '\\r')",
               "    if [ \"$cab\" != \"concentracao,cidade_nucleo,data,nome,esfera,ato_normativo,url_fonte,conferido_por\" ]; then",
               "      echo \"feriados locais: cabeçalho diferente das 8 colunas da D11, 3.3 (ou com outro campo): $f\"",
               "      continue",
               "    fi",
               "    tam_f=$(git cat-file -s \":$f\" 2>/dev/null || echo 0)",
               "    if [ \"$tam_f\" -ge 1048576 ]; then",
               "      echo \"feriados locais: blob de 1 MB ou mais ($tam_f bytes): $f\"",
               "      continue",
               "    fi",
               "  fi")
    append(l, bloco, after = i_ex - 1) })
  # testa_checa_sigilo.sh: casos no índice, sem tocar a pasta de trabalho
  ts <- novo("ferramentas/testa_checa_sigilo.sh", function(l) {
    i <- grep("^echo \"=== erro: cópia temporária do script com padrão inválido\"$", l); stopifnot(length(i) == 1)
    bloco <- c("# Feriados locais (D11, 3.3; P12): casos preparados só no índice (git update-index --cacheinfo), para não sobrescrever a",
               "# tabela real no caminho exato; o blob sai do índice no fim (git rm --cached) e fica solto em .git/objects.",
               "FER=codigo_compartilhado/dados_referencia/feriados_locais_nucleo_2011_2024.csv",
               "CABF=concentracao,cidade_nucleo,data,nome,esfera,ato_normativo,url_fonte,conferido_por",
               "indice() {   # $1 = rótulo, $2 = caminho, $3 = conteúdo, $4 = saída esperada do script (0 ou 1)",
               "  b=$(printf '%s\\n' \"$3\" | git hash-object -w --stdin)",
               "  git update-index --add --cacheinfo 100644,\"$b\",\"$2\"",
               "  sh ferramentas/checa_sigilo.sh > \"$TMP\" 2>&1; s=$?",
               "  echo \"=== $1: $2\"; sed 's/^/  sh: /' \"$TMP\"; echo \"  saída do script: $s (esperado $4)\"",
               "  [ \"$s\" -eq \"$4\" ] || falhas=$((falhas + 1))",
               "  git rm -q --cached \"$2\"; rm -f \"$TMP\"",
               "}",
               "indice \"feriados: cabeçalho certo no caminho exato\" \"$FER\" \"$CABF",
               "3550308,São Paulo,2011-07-09,Revolução Constitucionalista,estadual,Lei estadual 9.497/1997,https://exemplo.invalid,teste\" 0",
               "indice \"feriados: cabeçalho errado no caminho exato\" \"$FER\" \"a,b\" 1",
               "indice \"feriados: coluna a mais no caminho exato\" \"$FER\" \"$CABF,extra\" 1",
               "indice \"feriados: .csv em outro caminho\" \"codigo_compartilhado/dados_referencia/outro.csv\" \"$CABF\" 1",
               "")
    append(l, bloco, after = i - 1) })
  dif <- function(orig, novo_f, saida) { o <- suppressWarnings(system2("diff", c("-u", "--label", paste0("a/", orig), "--label", paste0("b/", orig), shQuote(file.path(REPO, orig)), shQuote(novo_f)), stdout = TRUE))
    writeLines(o, file.path(PATCH, saida), useBytes = TRUE) }
  dif(".gitignore", gi, "gitignore.diff"); dif("ferramentas/checa_sigilo.sh", cs, "checa_sigilo.diff"); dif("ferramentas/testa_checa_sigilo.sh", ts, "testa_checa_sigilo.diff")
  # verificação do patch num repositório temporário (fora do repositório do projeto)
  tr <- file.path(tempdir(), "verifica_patch"); dir.create(file.path(tr, "ferramentas"), recursive = TRUE)
  file.copy(cs, file.path(tr, "ferramentas", "checa_sigilo.sh"))
  vg <- function(...) system2("git", c("-C", tr, ...), stdout = TRUE, stderr = TRUE)
  vg("init", "-q"); vg("config", "user.email", "teste@local.invalid"); vg("config", "user.name", "teste")
  caso <- function(rotulo, caminho, conteudo, esperado) {
    dir.create(dirname(file.path(tr, caminho)), recursive = TRUE, showWarnings = FALSE); writeLines(conteudo, file.path(tr, caminho), useBytes = TRUE)
    vg("add", "-f", caminho)
    s <- system(paste("cd", shQuote(tr), "&& sh ferramentas/checa_sigilo.sh >/dev/null 2>&1; echo $?"), intern = TRUE)
    vg("rm", "-q", "--cached", caminho); unlink(file.path(tr, caminho))
    data.frame(Caso = rotulo, Esperado = esperado, Obtido = as.integer(s), stringsAsFactors = FALSE) }
  real <- readLines(F_CSV, encoding = "UTF-8", warn = FALSE)
  verif <- rbind(caso("tabela real no caminho exato", "codigo_compartilhado/dados_referencia/feriados_locais_nucleo_2011_2024.csv", real, 0L),
                 caso("cabeçalho errado no caminho exato", "codigo_compartilhado/dados_referencia/feriados_locais_nucleo_2011_2024.csv", c("a,b", "1,2"), 1L),
                 caso("coluna a mais no caminho exato", "codigo_compartilhado/dados_referencia/feriados_locais_nucleo_2011_2024.csv", paste0(real[1], ",extra"), 1L),
                 caso(".csv em outro caminho", "codigo_compartilhado/dados_referencia/outro.csv", real, 1L))
  unlink(tr, recursive = TRUE)
  ok_verif <- all(verif$Esperado == verif$Obtido); if (!ok_verif) falhas <- c(falhas, "a verificação do patch no repositório temporário falhou")
  sh_ok <- system2("sh", c("-n", shQuote(cs))) == 0 && system2("sh", c("-n", shQuote(ts))) == 0
  if (!sh_ok) falhas <- c(falhas, "sh -n acusou erro de sintaxe no checa_sigilo.sh ou no testa_checa_sigilo.sh com o patch")
  writeLines(c("# Patch dos feriados locais para a COORD (D11, 3.3; P12)", "",
               sprintf("Gerado por `artigo1_prematuridade/00_scripts/69_feriados_locais_fase4.R` (rodada %s), sobre o `HEAD` `%s`.", rodada, head_c), "",
               "1. Copiar `codigo_compartilhado/dados_referencia/` (a tabela e o `README.md`) para a mesma pasta do repositório.",
               "2. Aplicar `gitignore.diff`, `checa_sigilo.diff` e `testa_checa_sigilo.diff` (por exemplo, `git apply` com `--check` antes), da raiz do repositório.",
               "3. Rodar `sh ferramentas/testa_checa_sigilo.sh` (índice vazio antes) e conferir \"falhas: 0\".",
               "4. Commit da COORD, com o [ok] de Guilherme; a tag `feriados_locais-v1.0` vem depois, com autorização nomeando tag e SHA.",
               "5. O SHA-256 da tabela entra nos logs do A1 e do A2 (D11, 3.3).", "",
               "O A1 não commitou nada em `codigo_compartilhado/dados_referencia/` nem em `ferramentas/`."), file.path(PATCH, "LEIAME_PATCH.md"), useBytes = TRUE)
  fs <- sort(list.files(PATCH, recursive = TRUE)); fs <- fs[!grepl("(^|/)\\._", fs)]
  writeLines(vapply(fs, function(p) paste0(sha(file.path(PATCH, p)), "  ", p), ""), file.path(PATCH, "SHA256SUMS"))
  system(paste("cd", shQuote(PATCH), "&& zip -q -X -r", shQuote(ZIP), ". -x '.*' -x '*/._*' -x '._*'"))
  sha_patch <- c(zip = sha(ZIP), tabela = sha(F_CSV), readme = sha(F_README))
}
ok <- length(falhas) == 0
stopifnot(versao() == "4443971b")
md <- c("# Fase 4, Parte B2: feriados locais dos núcleos (validação e patch para a COORD)", "",
  sprintf("- **Gerado por:** `00_scripts/69_feriados_locais_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()` no início e no fim: %s.",
          sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Entrada:** `%s` (SHA-256 `%s`; %s linhas) e `%s` (SHA-256 `%s`).", F_CSV, sha(F_CSV), br(nrow(t)), F_README, sha(F_README)), "",
  "## Validação", "",
  if (length(falhas)) paste0("- **FALHAS:** ", paste(falhas, collapse = "; "), ".") else "- Esquema, núcleos, datas, esferas, URLs, sobreposição com os feriados nacionais e os móveis do modelo, 24/12, 31/12, 20/11 de 2024 e duplicatas: tudo confere.", "",
  "## Datas por núcleo (2011–2024)", "", tabela_md(por_nucleo), "",
  if (!is.null(verif)) c("## Verificação do patch num repositório temporário", "", tabela_md(verif), "") else "",
  if (!is.null(sha_patch)) c("## Patch para a COORD (fora do git)", "", sprintf("- `%s` (SHA-256 `%s`), com a tabela (`%s`), o README (`%s`), os três diffs, o `LEIAME_PATCH.md` e o `SHA256SUMS`.", ZIP, sha_patch[["zip"]], sha_patch[["tabela"]], sha_patch[["readme"]]), "") else "",
  sprintf("- **Resultado:** %s.", if (ok) "validação e patch ok" else "FALHA: PARE (sem patch)"), "")
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "|", if (ok) "ok" else paste("FALHA:", paste(falhas, collapse = "; ")), "\n")
if (!ok) quit(status = 1)
