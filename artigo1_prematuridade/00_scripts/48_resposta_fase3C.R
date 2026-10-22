# 48_resposta_fase3C.R — Fase 3, Parte C: monta RESPOSTA_artigo1_prematuridade_FASE3C_<FASE3_DATA>.md a partir dos logs
# do 45 (C1 a C4 e C6), do 46 (C5), do 47 (autoauditoria), da auditoria independente e do log de desvios. Os números da
# narrativa vêm dos logs, e no fim o script confere que cada um aparece num log. Para se a autoauditoria não der n/n, se
# faltar a seção da auditoria independente, se o código no disco diferir das tags, ou se alguma saída no disco diferir
# do SHA-256 registrado no log que a gerou. Só tabelas, sem leitura nem interpretação causal. Não lê a base. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/48_resposta_fase3C.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"
out <- paste0("RESPOSTA_artigo1_prematuridade_FASE3C_", hoje, ".md"); stopifnot(!file.exists(out))
lg <- function(n) file.path("logs", paste0(n, "_fase3_", hoje, ".md"))
f_log <- c(se = lg("segunda_etapa"), fa = lg("fracao_atribuivel"), aa = lg("autoauditoria_parteC"), aud = lg("auditoria_parteC"), dev = file.path("logs", "desvios_especificacao.md"))
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
                                           sub("^(#+) ", paste0("\\1", strrep("#", n), " "), secao(x, titulo, nivel = 2)))
linha_dev <- function(n) { x <- grep(paste0("^\\| ", n, " \\|"), L$dev, value = TRUE); stopifnot(length(x) == 1); x }
cab_dev <- L$dev[grep("^\\| # \\|", L$dev)[1] + 0:1]

# ------------------------------------------------------------------ travas
aa <- num(J$aa, "(?<=## Resultado: )[0-9]+ de [0-9]+"); an <- as.numeric(strsplit(aa, " de ")[[1]])
if (an[1] != an[2]) stop("a autoauditoria da Parte C não deu n/n (", aa, ")")
if (!length(grep("^## Auditoria independente", L$aud))) stop("falta a seção da auditoria independente")
n_aud <- num(paste(secao(L$aud, "^## Auditoria independente"), collapse = "\n"), "(?<=\\*\\*Achados:\\*\\* )[0-9]+")
n_reaud <- num(paste(secao(L$aud, "^## Re-auditoria das correções"), collapse = "\n"), "(?<=\\*\\*Achados:\\*\\* )[0-9]+")
TAGS <- c("ajusta_dlnm-v1.0" = "caf5022f9a655877d8e3931dd3d02d7dce429fe5", "segunda_etapa-v1.0" = "410dd6d6d3d315004f22fd7197c326de77f3c2f4")
for (tg in names(TAGS)) {
  if (!identical(git("rev-parse", paste0(tg, "^{commit}")), TAGS[[tg]])) stop("tag ", tg, " fora do commit esperado")
  a_R <- git("ls-tree", "-r", "--name-only", tg, "codigo_compartilhado/R/")
  st <- vapply(a_R, function(a) sub(" .*", "", system(paste("git -C", shQuote(REPO), "show", shQuote(paste0(tg, ":", a)), "| shasum -a 256"), intern = TRUE)), "")
  if (!identical(unname(st), unname(vapply(a_R, function(a) sha(file.path(REPO, a)), "")))) stop("codigo_compartilhado/R/ difere da tag ", tg)
}
saidas_log <- function(Lx) { m <- regmatches(Lx, gregexpr("`01_saidas/fase3/[^`]+`: `[0-9a-f]{64}`", Lx))[[1]]
  data.frame(arquivo = sub("^`([^`]+)`.*", "\\1", m), sha = sub(".*: `([0-9a-f]{64})`$", "\\1", m), stringsAsFactors = FALSE) }
so <- rbind(saidas_log(J$se), saidas_log(J$fa)); so <- so[!duplicated(so$arquivo) & grepl(paste0("_fase3_", hoje, "\\."), so$arquivo) & !grepl("percentis_exposicao", so$arquivo), ]
if (nrow(so) < 11) stop("saídas da Parte C ausentes no log")
sha_disco <- vapply(so$arquivo, sha, ""); if (!identical(unname(sha_disco), so$sha)) stop("saída no disco diferente do SHA-256 registrado")

# ------------------------------------------------------------------ números da narrativa (dos logs)
metodo <- num(J$se, "(?<=\\*\\*Método usado:\\*\\* )[a-z]+, Ψ [a-z]+")
tmr_c <- num(J$se, "(?<=\\*\\*TMR combinada:\\*\\* )[0-9,]+ °C, no percentil [0-9,]+ do eixo médio \\(q_TMR = [0-9,]+\\); IC 95% do bootstrap da D4\\(a\\): [0-9,]+ a [0-9,]+ °C")
fr_c <- num(J$se, "(?<=Na fronteira da grade x1–x99: )(sim|não)")
rr99 <- num(J$se, "(?<=\\| x99 \\(primário\\) \\| p99 \\| )[0-9,]+ \\| [0-9,]+ \\([0-9,]+ a [0-9,]+\\)"); rr1 <- num(J$se, "(?<=\\| x1 \\(coprimário\\) \\| p1 \\| )[0-9,]+ \\| [0-9,]+ \\([0-9,]+ a [0-9,]+\\)")
fmt_c <- function(s) { p <- strsplit(s, " | ", fixed = TRUE)[[1]]; sprintf("%s, em %s °C", p[2], p[1]) }
n_fr <- num(J$se, "(?<=\\*\\*TMR BLUP na fronteira da grade p1–p99:\\*\\* )[0-9]+ de 26")
het_r <- gsub(" +", " ", num(J$se, "(?<=\\| residual \\| )[0-9,]+ \\| +[0-9]+ \\| [0-9,e-]+ \\| [0-9,]+%"))
psi_c1 <- num(J$se, "(?<=\\*\\*Ψ:\\*\\* autovalores de Ψ )[^\n]*?posto efetivo [0-9] de 4")
cob_c <- sub("\\.$", "", num(J$se, "(?<=\\*\\*Extensão do IC da TMR combinada:\\*\\* )[^\n]+"))
ic_int <- num(J$se, "(?<=\\*\\*IC da TMR BLUP igual à grade p1–p99 inteira:\\*\\* )[0-9]+ de 26")
soma <- num(J$se, "(?<=\\*\\*Soma dos lags 0–7 \\(estimando diferente do RR cumulativo da C2\\):\\*\\* )p99 [0-9,]+ \\([0-9,]+ a [0-9,]+\\); p1 [0-9,]+ \\([0-9,]+ a [0-9,]+\\)")
c6 <- num(J$se, "(?<=diferença máxima nas demais células: )[0-9.e+-]+")
tot <- function(rot) num(J$fa, paste0("(?<=\\| ", rot, " \\| Total \\| )[0-9.-]+ \\([0-9.-]+ a [0-9.-]+\\) \\| [0-9,-]+% \\([0-9,-]+ a [0-9,-]+\\)"))
t_pr <- tot("Principal \\(forward, BLUPs\\)"); t_po <- tot("Ponte \\(forward, reduzidos da primeira etapa; diagnóstico\\)"); t_bk <- tot("Sensibilidade \\(backward, 16 coeficientes da primeira etapa\\)")
den_t <- num(J$fa, "(?<=Total das 26: )[0-9.]+(?= eventos)")
dev_n <- as.integer(sub("^\\| ([0-9]+) \\|.*", "\\1", grep("^\\| [0-9]+ \\|", L$dev, value = TRUE))); stopifnot(77 %in% dev_n)
ver <- do.call(rbind, lapply(c("se", "fa", "aa"), function(k) data.frame(Log = paste0("`", basename(f_log[[k]]), "`"),
  Script = num(J[[k]], "(?<=Gerado por:\\*\\* `)[^`]+"), Inicio = num(J[[k]], "(?<=`versao\\(\\)` no início = )[0-9a-f]{8}"),
  Fim = num(J[[k]], "(?<=`versao\\(\\)` no fim: )[0-9a-f]{8}"), stringsAsFactors = FALSE)))
stopifnot(all(ver$Inicio == "4443971b"), all(ver$Fim == "4443971b"))
arqs <- c("00_scripts/45_segunda_etapa_principal.R", "00_scripts/46_fracao_atribuivel.R", "00_scripts/47_autoauditoria_fase3C.R", "00_scripts/48_resposta_fase3C.R")
tab_arq <- c("| Arquivo | SHA-256 |", "|---|---|", sprintf("| `artigo1_prematuridade/%s` | `%s` |", arqs, vapply(arqs, sha, "")),
             sprintf("| `%s` | `%s` |", paste0("artigo1_prematuridade/", so$arquivo), so$sha))
gst <- git("status", "--porcelain", "--untracked-files=all"); glg <- git("log", "--oneline", "-4")

# ------------------------------------------------------------------ texto
md <- c(
  "# Artigo 1: prematuridade. Fase 3, Parte C: segunda etapa com os dados reais", "",
  "**Para:** chat do Artigo 1 (prematuridade), via Guilherme. **Antes de qualquer push.**", "",
  sprintf("**Data:** %s/%s/%s.", substr(hoje, 7, 8), substr(hoje, 5, 6), substr(hoje, 1, 4)), "",
  "**Base:** `4443971b`, somente leitura. **Prompt:** Fase 3, v1.1 (`docs/coordenacao/PROMPT_artigo1_prematuridade_FASE3_20261013.md`, SHA-256 `953f14d9…`), com o complemento de 13/10 e os desvios 71 a 77; o 77 (escolhas de implementação da Parte C) foi registrado num commit próprio antes de rodar. **Código:** tags `ajusta_dlnm-v1.0` e `segunda_etapa-v1.0` (SHA-256 conferidos), `attrdl.R` `d34c4c30…`.", "",
  "**Só tabelas, sem leitura nem interpretação causal.** \"If causal\" fica para a redação. Sensibilidades (inclusive a D3), figuras e texto ficam para as fases 4 a 6.", "",
  "## 1. Resumo", "",
  sprintf("- **C6, antes de qualquer curva:** a cross-basis remontada é igual à da Fase 2 nas 26 (diferença máxima %s; atributos `identical()`).", c6),
  sprintf("- **C1:** %s; heterogeneidade residual (Q | gl | p | I²): %s.", metodo, het_r),
  sprintf("- **C2:** TMR combinada %s; na fronteira: %s. RR cumulativo de lag 0–7 contra a TMR combinada: x99 (primário) %s; x1 (coprimário) %s.", tmr_c, fr_c, fmt_c(rr99), fmt_c(rr1)),
  sprintf("- **C3:** TMR BLUP na fronteira da grade p1–p99 em %s concentrações (o `cen` da C5 continua sendo a TMR da grade; D4(g)).", sub(" de 26", "", n_fr)),
  sprintf("- **C4:** soma dos lags 0–7 (estimando diferente do RR cumulativo): %s.", soma),
  sprintf("- **C5 (total das 26; %s eventos na janela):** principal %s; ponte %s; *backward* %s (AN com eCI | AF com eCI).", den_t, t_pr, t_po, t_bk),
  sprintf("- **Dupla auditoria:** autoauditoria %s iguais; auditoria independente com %s achados, todos aceitos e corrigidos, e re-auditoria das correções com %s notas, também aceitas (seção 5). A autoauditoria achou um erro no denominador total do 46 (somava as cinco linhas de componentes de cada concentração), corrigido antes desta RESPOSTA; ver a seção 5.", aa, n_aud, n_reaud),
  sprintf("- **Diagnósticos (só reportados, sem interpretação):** Ψ da C1 com autovalores %s (singular); extensão do IC da TMR combinada: %s; IC da TMR BLUP igual à grade p1–p99 inteira em %s; nas %s com TMR BLUP na fronteira, os RR saem também contra a mediana (§7; seção 3, C3).", psi_c1, cob_c, ic_int, n_fr),
  "- **Pendências:** nenhuma desta parte. **Sem push:** esta RESPOSTA vai para o chat antes.", "",
  "## 2. Conferências e diagnósticos (C6)", "",
  L$se[grep("^- \\*\\*Ambiente", L$se)[1]:(grep("^## C6", L$se)[1] - 1)],
  com_titulo(L$se, "^## C6"),
  "## 3. C1 a C4: meta-análise, curva e TMR combinadas, curvas BLUP e lag–resposta", "",
  com_titulo(L$se, "^## C1"), com_titulo(L$se, "^## C2"), com_titulo(L$se, "^## C3"), com_titulo(L$se, "^## C4"),
  "## 4. C5: fração atribuível", "",
  grep("^- \\*\\*(Linhas)", L$fa, value = TRUE), "",
  com_titulo(L$fa, "^## Denominador"), com_titulo(L$fa, "^## Total das 26"),
  "### Por concentração", "", sub("^### ", "#### ", secao(L$fa, "^## Por concentração")),
  com_titulo(L$fa, "^## Contribuições negativas"), com_titulo(L$fa, "^## Aditividade"),
  "## 5. Dupla auditoria", "",
  "### Autoauditoria (`47_autoauditoria_fase3C.R`)", "",
  grep("^- \\*\\*(Método|Código diferente|Tolerâncias)", L$aa, value = TRUE), "", com_titulo(L$aa, "^## Resultado:", 1),
  "### Registro da dupla auditoria", "", sprintf("Transcrito de `logs/%s`.", basename(f_log[["aud"]])), "", sub("^(#+) ", "\\1# ", L$aud[-1]),
  "## 6. Desvio desta parte", "",
  "O desvio 77 foi registrado num commit próprio (`d511c54`) antes de rodar a Parte C. Os desvios 71 a 76 estão nas RESPOSTAs e nos commits anteriores.", "",
  cab_dev, linha_dev(77), "",
  "## 7. Saídas, comandos e ambiente", "",
  "Da pasta `artigo1_prematuridade/`, com o `renv` do artigo (R 4.5.1), nesta ordem. Cada script tem trava contra sobrescrita.", "",
  "```", sprintf("FASE3_DATA=%s Rscript 00_scripts/%s.R", hoje, c("45_segunda_etapa_principal", "46_fracao_atribuivel", "47_autoauditoria_fase3C", "48_resposta_fase3C")), "```", "",
  "**`versao()` no início e no fim de cada script:**", "",
  "| Log | Script | Início | Fim |", "|---|---|---|---|", sprintf("| %s | `%s` | %s | %s |", ver$Log, ver$Script, ver$Inicio, ver$Fim),
  "| (este retorno) | `00_scripts/48_resposta_fase3C.R` | 4443971b | 4443971b (conferido no fim do script) |", "",
  "**SHA-256 dos scripts e das saídas** (as saídas ficam fora do git, em `01_saidas/fase3/`; conferidas contra os logs no momento de gravar este retorno):", "", tab_arq, "",
  "## 8. `git status`", "",
  "Saída de `git status --porcelain --untracked-files=all`, antes de gravar este retorno e antes do commit local da Parte C. Arquivos de outras sessões, se houver, só são mostrados:", "",
  "```", if (length(gst)) gst else "(limpo)", "```", "", "`git log --oneline -4`:", "", "```", glg, "```", "",
  "Commit local da Parte C. **Sem push:** a RESPOSTA vai para o chat do Artigo 1 antes.")

narr <- md[seq_len(grep("^## 2\\. Conferências", md)[1] - 1)]
toks <- unique(unlist(regmatches(narr, gregexpr("[0-9]+ de [0-9]+|[0-9]+/[0-9]+|-?[0-9][0-9.]*,[0-9]+|[0-9]\\.[0-9]+e[-+][0-9]+", narr))))
todos <- paste(unlist(L), collapse = "\n")
esc <- function(t) gsub("([.\\\\|()\\[\\]{}^$*+?])", "\\\\\\1", t, perl = TRUE)
fora <- toks[!vapply(toks, function(t) grepl(paste0("(?<![0-9.,])", esc(t), "(?![0-9]|,[0-9])"), todos, perl = TRUE), logical(1))]
if (length(fora)) stop("números da narrativa sem origem nos logs: ", paste(fora, collapse = ", "))
stopifnot(versao() == "4443971b")
writeLines(md, out, useBytes = TRUE)
cat("gravado:", out, "| números da narrativa conferidos:", length(toks), "| SHA-256:", sha(out), "\n")
