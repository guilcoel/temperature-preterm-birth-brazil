# 43_resposta_fase3A.R — Fase 3, Parte A: monta RESPOSTA_artigo1_prematuridade_FASE3A_<FASE3_DATA>.md a partir dos logs
# do 40 (percentis), do 41 (testes), do 42 (autoauditoria), da auditoria independente e do log de desvios. Os números da
# narrativa vêm dos logs, e no fim o script confere que cada um aparece num log. Para se a autoauditoria não der n/n, se
# faltar a seção da auditoria independente, se o 41 não tiver todos os testes passando e todos os defeitos derrubados, ou
# se o código no disco diferir do testado no 41 e do auditado no 42. Não lê a base. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/43_resposta_fase3A.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; CC <- file.path("..", "codigo_compartilhado")
out <- paste0("RESPOSTA_artigo1_prematuridade_FASE3A_", hoje, ".md"); stopifnot(!file.exists(out))
lg <- function(n) file.path("logs", paste0(n, "_fase3_", hoje, ".md"))
f_log <- c(a0 = lg("percentis_exposicao"), t = lg("testes_segunda_etapa"), aa = lg("autoauditoria_parteA"), aud = lg("auditoria_parteA"),
           dev = file.path("logs", "desvios_especificacao.md"))
stopifnot(all(file.exists(f_log)))
L <- lapply(f_log, readLines, encoding = "UTF-8"); J <- lapply(L, paste, collapse = "\n")
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
num <- function(x, padrao) { m <- regmatches(x, regexpr(padrao, x, perl = TRUE)); if (!length(m)) stop("não achei no log: ", padrao); m }
secao <- function(x, titulo, nivel = 2) {
  i <- grep(titulo, x)[1]; if (is.na(i)) stop("seção ausente: ", titulo)
  prox <- grep(paste0("^#{1,", nivel, "} "), x); prox <- prox[prox > i]
  x[(i + 1):(if (length(prox)) prox[1] - 1 else length(x))]
}
com_titulo <- function(x, titulo, n = 1) c(sub("^(#+) ", paste0("\\1", strrep("#", n), " "), grep(titulo, x, value = TRUE)[1]),
                                           sub("^(#+) ", paste0("\\1", strrep("#", n), " "), secao(x, titulo)))
linha_dev <- function(n) { x <- grep(paste0("^\\| ", n, " \\|"), L$dev, value = TRUE); stopifnot(length(x) == 1); x }
cab_dev <- L$dev[grep("^\\| # \\|", L$dev)[1] + 0:1]

# ------------------------------------------------------------------ travas
aa <- num(J$aa, "(?<=## Resultado: )[0-9]+ de [0-9]+"); an <- as.numeric(strsplit(aa, " de ")[[1]])
if (an[1] != an[2]) stop("a autoauditoria da Parte A não deu n/n (", aa, ")")
if (!length(grep("^## Auditoria independente", L$aud))) stop("falta a seção da auditoria independente")
n_aud <- num(paste(secao(L$aud, "^## Auditoria independente"), collapse = "\n"), "(?<=\\*\\*Achados:\\*\\* )[0-9]+")
nn <- num(J$t, "(?<=## Resultado: )[0-9]+/[0-9]+"); nnv <- as.numeric(strsplit(nn, "/")[[1]])
if (nnv[1] != nnv[2]) stop("o 41 não tem todos os testes passando (", nn, ")")
n_def <- length(grep("^\\| ", secao(L$t, "^## Defeitos plantados"))) - 1
if (!grepl(sprintf("cada um dos %d defeitos derruba pelo menos um teste", n_def), J$t, fixed = TRUE)) stop("algum defeito não foi detectado")
testados <- c("codigo_compartilhado/R/segunda_etapa.R", "codigo_compartilhado/R/ajusta_dlnm.R", "codigo_compartilhado/tests/testa_segunda_etapa.R",
              "codigo_compartilhado/tests/testa_segunda_etapa_mc.R", "codigo_compartilhado/tests/roda_testes.R", "codigo_compartilhado/inst/terceiros/attrdl.R")
for (a in testados) { alvo <- sprintf("`%s`: `%s`", a, sha(file.path("..", a)))
  if (!grepl(alvo, J$t, fixed = TRUE) || !grepl(alvo, J$aa, fixed = TRUE)) stop("SHA-256 de ", a, " difere do testado no 41 ou do auditado no 42") }
if (length(git("diff", "--name-only", "ajusta_dlnm-v1.0", "--", "codigo_compartilhado/R/ajusta_dlnm.R"))) stop("ajusta_dlnm.R mudou depois da tag")

# ------------------------------------------------------------------ números da narrativa (dos logs)
dif_a0 <- num(J$a0, "(?<=maior diferença absoluta = )[0-9.e+-]+")
x1 <- num(J$a0, "(?<=\\| p1 \\| )[0-9,]+(?= \\|)"); x99 <- num(J$a0, "(?<=\\| p99 \\| )[0-9,]+(?= \\|)"); x50 <- num(J$a0, "(?<=\\| p50 \\| )[0-9,]+(?= \\|)")
cob <- num(J$t, "(?<=contra x50:\\*\\* )[0-9,]+ \\(EP de MC [0-9,]+; IC Wilson \\[[0-9,]+; [0-9,]+\\]\\)")
vrel <- num(J$t, "(?<=relativo )-?[0-9,]+(?=% \\(EP)"); cobt <- num(J$t, "(?<=só reportada:\\*\\* )[0-9,]+")
mse <- num(J$t, "(?<=BLUP )[0-9.e+-]+(?=; primeira etapa)"); mse1 <- num(J$t, "(?<=primeira etapa )[0-9.e+-]+(?=; parte fixa)")
msef <- num(J$t, "(?<=parte fixa X_iβ̂ \\(predição de cada unidade pelos seus metapreditores\\) )[0-9]\\.[0-9]+e[-+][0-9]+"); msep <- num(J$t, "(?<=só reportado\\): )[0-9]\\.[0-9]+e[-+][0-9]+")
literal <- if (as.numeric(msep) < as.numeric(mse)) "pela leitura literal do prompt (\"predição da média\"), o critério cairia, porque o EQM da predição na média é menor que o do BLUP" else if (as.numeric(msep) == as.numeric(mse)) "pela leitura literal do prompt (\"predição da média\"), os dois EQM empatam na precisão do log (4 algarismos), e o critério fica indefinido" else "pela leitura literal do prompt (\"predição da média\"), o critério também passaria"
grp <- as.integer(regmatches(J$t, regexec("Os ([0-9]+) primeiros são os do prompt[^;]*; os ([0-9]+) seguintes vêm do complemento[^;]*; os ([0-9]+) seguintes, da auditoria independente[^;]*; os ([0-9]+) últimos, da re-auditoria", J$t))[[1]][-1])
if (length(grp) != 4 || sum(grp) != n_def) stop("grupos de defeitos do log do 41 não somam o total da tabela")
n_reaud <- num(paste(secao(L$aud, "^## Re-auditoria independente"), collapse = "\n"), "(?<=\\*\\*Achados:\\*\\* )[0-9]+")
dev_n <- as.integer(sub("^\\| ([0-9]+) \\|.*", "\\1", grep("^\\| [0-9]+ \\|", L$dev, value = TRUE))); dev_c <- 71:75; stopifnot(all(dev_c %in% dev_n))
blas <- num(J$t, "(?<=BLAS/LAPACK: `)[^`]+")
ver <- do.call(rbind, lapply(c("a0", "t", "aa"), function(k) data.frame(Log = paste0("`", basename(f_log[[k]]), "`"),
  Script = num(J[[k]], "(?<=Gerado por:\\*\\* `)[^`]+"), Inicio = num(J[[k]], "(?<=`versao\\(\\)` no início = )[0-9a-f]{8}"),
  Fim = num(J[[k]], "(?<=`versao\\(\\)` no fim: )[0-9a-f]{8}"), stringsAsFactors = FALSE)))
stopifnot(all(ver$Inicio == "4443971b"), all(ver$Fim == "4443971b"))
fse <- readLines(file.path(CC, "R", "segunda_etapa.R"), encoding = "UTF-8")
doc <- sub("^# ?", "", fse[seq_len(which(!grepl("^#", fse))[1] - 1)])
fe <- new.env(); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = fe)
assin <- vapply(c("base_combinada", "meta_curva", "curva", "grade_tmr", "busca_tmr", "boot_tmr", "posicao_no_eixo", "centro_lagresposta", "reduz_var",
                  "curva_lag", "soma_lags", "monta_cb", "carrega_attrdl", "componentes_attrdl", "fracao_atribuivel", "confere_ordem", "indice_concentracao", "semente", "semeia"),
                function(nm) { a <- deparse(args(fe[[nm]])); paste0(nm, sub("^function ", "", paste(trimws(a[-length(a)]), collapse = " "))) }, "")
arqs <- c("00_scripts/40_percentis_exposicao.R", "00_scripts/41_testes_segunda_etapa.R", "00_scripts/42_autoauditoria_fase3A.R", "00_scripts/43_resposta_fase3A.R")
tab_arq <- c("| Arquivo | SHA-256 |", "|---|---|", sprintf("| `%s` | `%s` |", c(testados, paste0("artigo1_prematuridade/", arqs)),
                                                           c(vapply(testados, function(a) sha(file.path("..", a)), ""), vapply(arqs, sha, ""))))
gst <- git("status", "--porcelain", "--untracked-files=all"); glg <- git("log", "--oneline", "-4")

# ------------------------------------------------------------------ texto
md <- c(
  "# Artigo 1: prematuridade. Fase 3, Parte A: percentis da exposição, funções da segunda etapa e testes", "",
  "**Para:** chat do Artigo 1 (prematuridade), via Guilherme.", "",
  sprintf("**Data:** %s/%s/%s.", substr(hoje, 7, 8), substr(hoje, 5, 6), substr(hoje, 1, 4)), "",
  "**Base:** `4443971b`, somente leitura. **Prompt:** Fase 3, v1.1 (`docs/coordenacao/PROMPT_artigo1_prematuridade_FASE3_20261013.md`, SHA-256 `953f14d9…`), com o complemento de 13/10 (`spec/decisoes_metodo_20261013_complemento.md`, `189d9b2d…`) e os desvios 71 a 73, registrados num commit próprio antes de rodar; os desvios 74 e 75 (correções da auditoria independente e da re-auditoria) foram registrados antes das rodadas seguintes dos testes.", "",
  "**Nenhuma estimativa nova com o desfecho real.** Os testes usam dados reais só como atributos da base, exposição, percentis, metapreditores e as vcov reduzidas da Fase 2 como covariâncias de coeficientes sintéticos (desvio 72d).", "",
  "## 1. Resumo", "",
  sprintf("- **A0:** grade de percentis (1 a 99, 2,5 e 97,5) da `tmean_nucleo` de 2012-01-01 a 2024-12-31 nas 26 concentrações, conferida contra o `referencias_exposicao.csv` (maior diferença %s). Eixo médio: x1 = %s °C, x50 = %s °C, x99 = %s °C.", dif_a0, x1, x50, x99),
  "- **Código:** `codigo_compartilhado/R/segunda_etapa.R` (v1.0, para a tag `segunda_etapa-v1.0`), com a base combinada (D2), a meta-análise com a sequência de estabilidade, as curvas, a TMR (grade, fronteira pelo índice, bootstrap), a lag–resposta, a cross-basis na série consecutiva e a fração atribuível nas três análises da D1, com as sementes do complemento (20261001 + i, `kind` explícito) e a ordem das 26 travada. A `ajusta_dlnm()` v1.0 não mudou.",
  sprintf("- **Testes:** %s. Teste 5 (1.000 réplicas): cobertura do log RR combinado em x99 %s; viés relativo %s%%; EQM do BLUP %s, contra %s da primeira etapa e %s da parte fixa X_iβ̂ (critério implementado); EQM da predição na média dos metapreditores %s, só reportado (desvio 74); cobertura da TMR combinada %s (só reportada). Os %d defeitos plantados (%d do prompt, %d do complemento, %d da auditoria independente e %d da re-auditoria) derrubam, cada um, pelo menos um teste.",
          nn, cob, vrel, mse, mse1, msef, msep, cobt, n_def, grp[1], grp[2], grp[3], grp[4]),
  sprintf("- **Dupla auditoria:** autoauditoria %s iguais; auditoria independente com %s achados e re-auditoria das correções com %s, todos reproduzidos por código próprio (seção 5). O código estava certo e a bateria de testes estava fraca; as correções estão nos desvios 74 e 75.", aa, n_aud, n_reaud),
  sprintf("- **Pendência para o chat (desvio 74(a)):** escolher o comparador do EQM do teste 5 antes da tag. O critério implementado compara o BLUP com a parte fixa X_iβ̂ de cada unidade; %s. A tag espera \"CÓDIGO DA FASE 3 LIBERADO\"; a Parte C, \"SEGUNDA ETAPA LIBERADA\" (a D4(f) já foi confirmada pelo chat de métodos no complemento).", literal), "",
  "## 2. A0: percentis da exposição", "",
  grep("^- \\*\\*(Fonte|Período|Ordem)", L$a0, value = TRUE), "",
  com_titulo(L$a0, "^## Conferência"), com_titulo(L$a0, "^## Eixo médio"), com_titulo(L$a0, "^## Grade completa"), com_titulo(L$a0, "^## Saída"),
  "## 3. Funções: assinaturas e documentação", "",
  "```r", assin, "```", "", "Documentação (cabeçalho de `codigo_compartilhado/R/segunda_etapa.R`):", "", "```", doc, "```", "",
  "## 4. Testes", "",
  com_titulo(L$t, "^## Teste 5: parâmetros"), com_titulo(L$t, "^## Resultado:"), com_titulo(L$t, "^## Monte Carlo"),
  com_titulo(L$t, "^## Valores descritivos"), com_titulo(L$t, "^## Defeitos plantados"),
  "## 5. Dupla auditoria", "",
  "### Autoauditoria (`42_autoauditoria_fase3A.R`)", "",
  grep("^- \\*\\*(Método|Código diferente|Limite)", L$aa, value = TRUE), "", com_titulo(L$aa, "^## Resultado:", 1),
  "### Auditoria independente", "", sprintf("Transcrita de `logs/%s`.", basename(f_log[["aud"]])), "", sub("^(#+) ", "\\1# ", L$aud[-1]),
  "## 6. Desvios", "",
  "Os desvios 71 a 73 foram registrados num commit próprio (`026306e`) antes de rodar a Parte A. Os desvios 74 (correções da auditoria independente) e 75 (correções da re-auditoria e errata do 74) foram registrados antes da rodada seguinte dos testes, com os SHA-256 do código e dos testes, e entram no commit da Parte A.", "",
  cab_dev, vapply(dev_c, linha_dev, ""), "",
  "## 7. Comandos para reproduzir", "",
  "Da pasta `artigo1_prematuridade/`, com o `renv` do artigo (R 4.5.1), nesta ordem. Cada script tem trava contra sobrescrita.", "",
  "```", sprintf("FASE3_DATA=%s Rscript 00_scripts/%s.R", hoje, c("40_percentis_exposicao", "41_testes_segunda_etapa", "42_autoauditoria_fase3A", "43_resposta_fase3A")), "```", "",
  sprintf("**BLAS/LAPACK** (log do 41): `%s`.", blas), "",
  "**`versao()` no início e no fim de cada script:**", "",
  "| Log | Script | Início | Fim |", "|---|---|---|---|", sprintf("| %s | `%s` | %s | %s |", ver$Log, ver$Script, ver$Inicio, ver$Fim),
  "| (este retorno) | `00_scripts/43_resposta_fase3A.R` | 4443971b | 4443971b (conferido no fim do script) |", "",
  "**SHA-256 do código, dos testes e dos scripts** (no momento de gravar este retorno):", "", tab_arq, "",
  "## 8. `git status`", "",
  "Saída de `git status --porcelain --untracked-files=all`, antes de gravar este retorno e antes do commit local da Parte A. Arquivos de outras sessões, se houver, só são mostrados; as saídas em `01_saidas/` ficam fora do git:", "",
  "```", if (length(gst)) gst else "(limpo)", "```", "", "`git log --oneline -4`:", "", "```", glg, "```", "",
  "Commit local da Parte A. **Sem push e sem tag** (Parte B, só depois de \"CÓDIGO DA FASE 3 LIBERADO\").")

narr <- md[seq_len(grep("^## 2\\. A0", md)[1] - 1)]
toks <- unique(unlist(regmatches(narr, gregexpr("[0-9]+ de [0-9]+|[0-9]+/[0-9]+|-?[0-9][0-9.]*,[0-9]+|[0-9]\\.[0-9]+e[-+][0-9]+", narr))))
todos <- paste(unlist(L), collapse = "\n")
esc <- function(t) gsub("([.\\\\|()\\[\\]{}^$*+?])", "\\\\\\1", t, perl = TRUE)
fora <- toks[!vapply(toks, function(t) grepl(paste0("(?<![0-9.,])", esc(t), "(?![0-9]|,[0-9])"), todos, perl = TRUE), logical(1))]
if (length(fora)) stop("números da narrativa sem origem nos logs: ", paste(fora, collapse = ", "))
stopifnot(versao() == "4443971b")
writeLines(md, out, useBytes = TRUE)
cat("gravado:", out, "| números da narrativa conferidos:", length(toks), "| SHA-256:", sha(out), "\n")
