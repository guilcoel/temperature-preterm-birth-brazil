# 36_resposta_fase2C.R — Fase 2, Parte C: monta RESPOSTA_artigo1_prematuridade_FASE2C_<FASE2_DATA>.md a partir dos logs do
# 32 (primeira etapa), do 35 (autoauditoria), da auditoria independente e do log de desvios. Os números da narrativa vêm dos
# logs; no fim, o script confere que cada número da narrativa aparece num log. Para se a autoauditoria não der n/n, se
# faltar a seção da auditoria independente, se o código no disco diferir da tag ou se as saídas não tiverem o SHA-256 do
# log. Não lê a base (o source do acesso.R só registra versao()). Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE2_DATA=AAAAMMDD Rscript 00_scripts/36_resposta_fase2C.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE2_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"
out <- paste0("RESPOSTA_artigo1_prematuridade_FASE2C_", hoje, ".md"); stopifnot(!file.exists(out))
f_log <- c(pe = file.path("logs", paste0("primeira_etapa_fase2_", hoje, ".md")), aa = file.path("logs", paste0("autoauditoria_fase2C_", hoje, ".md")),
           aud = file.path("logs", paste0("auditoria_fase2C_", hoje, ".md")), audB = file.path("logs", paste0("auditoria_fase2B_", hoje, ".md")),
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
if (an[1] != an[2]) stop("a autoauditoria da Parte C não deu n/n (", aa, ")")
if (!length(grep("^## Auditoria independente", L$aud))) stop("falta a seção da auditoria independente")
n_aud <- num(paste(secao(L$aud, "^## Auditoria independente"), collapse = "\n"), "(?<=\\*\\*Achados:\\*\\* )[0-9]+")
arqs_R <- git("ls-tree", "-r", "--name-only", "ajusta_dlnm-v1.0", "codigo_compartilhado/R/")
for (a in arqs_R) {
  h <- sha(file.path(REPO, a)); if (!grepl(sprintf("`%s`: `%s`", a, h), J$pe, fixed = TRUE)) stop("SHA-256 de ", a, " difere do usado no 32")
  ht <- sub(" .*", "", system(paste0("git -C ", shQuote(REPO), " show ", shQuote(paste0("ajusta_dlnm-v1.0:", a)), " | shasum -a 256"), intern = TRUE))
  if (!identical(h, ht)) stop(a, " no disco difere da tag")
}
saidas <- file.path("01_saidas", "fase2", paste0(c("primeira_etapa_principal", "reduzida_coef_vcov", "crossbasis_coef_vcov", "pacf", "diagnosticos"), "_fase2_", hoje,
                                                 c(".rds", ".csv", ".csv", ".csv", ".csv")))
for (p in saidas) if (!grepl(sprintf("`%s`: `%s`", p, sha(p)), J$pe, fixed = TRUE)) stop("SHA-256 de ", p, " difere do log do 32")
for (p in saidas) if (system2("git", c("-C", REPO, "check-ignore", "-q", file.path("artigo1_prematuridade", p))) != 0) stop(p, " não está fora do git")

# ------------------------------------------------------------------ números da narrativa (dos logs)
st <- num(J$pe, "(?<=\\*\\*Status:\\*\\* )[0-9]+ de 26"); n_fb <- num(J$pe, "(?<=fallback em )[0-9]+"); n_ne <- num(J$pe, "(?<=não estimáveis )[0-9]+")
n_pend <- num(J$pe, "(?<=decisões pendentes )[0-9]+")
phi2 <- num(J$pe, "(?<=\\*\\*φ > 2:\\*\\* )[0-9]+ de 26"); lit <- num(J$pe, "(?<=fora de ±2/√n\\): )[0-9]+ de 26")
rec <- num(J$pe, "(?<=recentrada em −1/\\(m − 1\\): )[0-9]+ de 26"); bon <- num(J$pe, "(?<=recentrada com Bonferroni nos 7 lags: )[0-9]+ de 26")
dentro <- num(J$pe, "(?<=dentro dos Boundary.knots:\\*\\* )[0-9]+ de 26")
sinal <- num(J$pe, "(?<=\\(lags de todas as concentrações\\): )[^.]+")
nulo <- num(J$audB, "(?<=A regra literal \\(±2/√n\\) sinaliza )[0-9]+")
nulo_rec <- num(J$audB, "(?<=sinaliza )[0-9]+(?=\\. Recentrada e com Bonferroni)"); nulo_bon <- num(J$audB, "(?<=Recentrada e com Bonferroni nos 7 lags, sinaliza )[0-9]+")
dif_max <- num(J$aa, "(?<=coeficientes da cross-basis )[0-9.e-]+")
dev_n <- as.integer(sub("^\\| ([0-9]+) \\|.*", "\\1", grep("^\\| [0-9]+ \\|", L$dev, value = TRUE))); dev_c <- c(64L, 65L, 66L); stopifnot(all(dev_c %in% dev_n))
if (as.integer(n_pend) > 0) stop("há decisão pendente no 32: a RESPOSTA tem de tratá-la antes")
blas <- num(J$pe, "(?<=BLAS/LAPACK: `)[^`]+")
ver <- do.call(rbind, lapply(c("pe", "aa"), function(k) data.frame(Log = paste0("`", basename(f_log[[k]]), "`"),
  Script = num(J[[k]], "(?<=Gerado por:\\*\\* `)[^`]+"), Inicio = num(J[[k]], "(?<=`versao\\(\\)` no início = )[0-9a-f]{8}"),
  Fim = num(J[[k]], "(?<=`versao\\(\\)` no fim: )[0-9a-f]{8}"), stringsAsFactors = FALSE)))
stopifnot(all(ver$Inicio == "4443971b"), all(ver$Fim == "4443971b"))
arqs <- c("00_scripts/32_primeira_etapa_principal.R", "00_scripts/35_autoauditoria_fase2C.R", "00_scripts/36_resposta_fase2C.R")
tab_arq <- c("| Arquivo | SHA-256 |", "|---|---|", sprintf("| `artigo1_prematuridade/%s` | `%s` |", arqs, vapply(arqs, sha, "")))
gst <- git("status", "--porcelain", "--untracked-files=all"); glg <- git("log", "--oneline", "-4")

# ------------------------------------------------------------------ texto
md <- c(
  "# Artigo 1: prematuridade. Fase 2, Parte C: primeira etapa do modelo principal nas 26 concentrações", "",
  "**Para:** chat do Artigo 1 (prematuridade), via Guilherme.", "",
  sprintf("**Data:** %s/%s/%s.", substr(hoje, 7, 8), substr(hoje, 5, 6), substr(hoje, 1, 4)), "",
  "**Base:** `4443971b`, somente leitura. **Código:** tag `ajusta_dlnm-v1.0` (commit `caf5022`), publicada com o `main` em `92565b9` depois do [ok] de Guilherme (Parte B; desvio 64).", "",
  "**Prompt:** Fase 2, v1.1, Parte C, depois de \"PRIMEIRA ETAPA LIBERADA\" (10/10). Escolhas registradas antes de rodar no desvio 65.", "",
  "## 1. Resumo", "",
  sprintf("- **Ajustes:** %s concentrações com `status = \"ok\"` no modelo principal; fallback em %s; não estimáveis %s; decisões pendentes %s. Todas com cross-basis de 16 parâmetros e curva reduzida de 4, a entrada da Fase 3.", st, n_fb, n_ne, n_pend),
  sprintf("- **φ > 2:** %s. A binomial negativa não é acionada pela regra da §2.1.", phi2),
  sprintf("- **PACF, regra literal da §2.1:** %s com algum lag de 1 a 7 fora de ±2/√n. Pela regra literal, nelas a sensibilidade com resíduos defasados entraria na Fase 4; a regra que vale é decisão pendente do chat (desvio 65c).", lit),
  sprintf("- **Para o chat (desvio 65c):** num modelo correto, com os estratos mensais eliminados, a PACF dos resíduos fica em torno de −1/(m − 1) ≈ −0,0343 (m ≈ 30,2 dias por estrato), e a regra literal dispara quase sempre: em 100 réplicas simuladas sem autocorrelação, sinalizou %s das 100 (auditoria final da Parte B). Recentrada em −1/(m − 1), a mesma regra sinalizou %s das 100 réplicas (efeito de testar 7 lags) e, com Bonferroni nos 7 lags, %s. Nos dados, a recentrada sinaliza %s e a recentrada com Bonferroni %s, acima do esperado sem autocorrelação. Lags sinalizados: %s. A literal só pega lags muito negativos (o artefato dos estratos); a recentrada aponta autocorrelação residual positiva e pequena em parte das concentrações (auditoria independente, achado 2). A regra que decide a sensibilidade da Fase 4 é do chat.",
          nulo, nulo_rec, nulo_bon, rec, bon, sinal),
  sprintf("- **p1 e p99 (ano inteiro) dentro dos Boundary.knots:** %s.", dentro),
  sprintf("- **Dupla auditoria:** autoauditoria %s iguais (26 ajustes refeitos com `glm`, diferença relativa máxima de %s nos coeficientes da cross-basis); auditoria independente com %s achados (seção 6).", aa, dif_max, n_aud),
  "- **Ainda não** (Fase 3): RR, curva, MRT, contraste e gráficos.", "",
  "## 2. Entradas, especificação e linhas passadas", "",
  grep("^- \\*\\*(Ambiente|Código|Entradas|Por que o CSV|Linhas passadas|Especificação)|^  - `codigo_compartilhado", L$pe, value = TRUE), "",
  com_titulo(L$pe, "^## Especificação usada"),
  com_titulo(L$pe, "^## Resumo nas 26"),
  "## 3. Diagnósticos por concentração", "", secao(L$pe, "^## Diagnósticos por concentração"),
  "## 4. PACF dos resíduos de deviance", "", secao(L$pe, "^## PACF dos resíduos"),
  "## 5. Saídas", "", secao(L$pe, "^## Saídas"),
  "**Como ler os CSVs (para a Fase 3):** `read.csv(arquivo, colClasses = c(recorte_principal = \"character\"))` (sem isso, o código IBGE vira inteiro). Os números estão gravados como texto com 17 dígitos significativos e são convertidos pelo `read.csv`, com erro de até 1 ULP; a RDS guarda os valores exatos. Formato longo: `tipo` = coef (índice `i`) ou vcov (`i`, `j`), `dim` = 16 ou 4. Na cross-basis, a ordem dos coeficientes é a do dlnm (v1.l1, v1.l2, …, v4.l4: base da temperatura por fora, base do lag por dentro); na reduzida, os 4 coeficientes são os da base da temperatura (ns com nós p10/p75/p90 e os Boundary.knots da concentração). Os atributos completos da base (`argvar` com `intercept`, `arglag`, `lag`) estão só na RDS.", "",
  "## 6. Dupla auditoria", "",
  "### Autoauditoria (`35_autoauditoria_fase2C.R`)", "",
  grep("^- \\*\\*(Método|Maiores diferenças|Tolerâncias)", L$aa, value = TRUE), "", com_titulo(L$aa, "^## Resultado:", 1),
  "### Auditoria independente", "", sprintf("Transcrita de `logs/%s`.", basename(f_log[["aud"]])), "",
  sub("^(#+) ", "\\1# ", L$aud[-1]),
  "## 7. Desvios", "",
  "O desvio 64 é da Parte B (tag com 19/20); o 65, das escolhas da Parte C, registrado antes de rodar; o 66, das correções da auditoria independente da Parte C, registrado antes de rodar de novo o 32 e o 35.", "",
  cab_dev, vapply(dev_c, linha_dev, ""), "",
  "## 8. Comandos para reproduzir", "",
  "Da pasta `artigo1_prematuridade/`, com o `renv` do artigo (R 4.5.1), nesta ordem. Cada script tem trava contra sobrescrita.", "",
  "```", sprintf("FASE2_DATA=%s Rscript 00_scripts/%s.R", hoje, c("32_primeira_etapa_principal", "35_autoauditoria_fase2C", "36_resposta_fase2C")), "```", "",
  sprintf("**BLAS/LAPACK** (log do 32): `%s`.", blas), "",
  "**`versao()` no início e no fim de cada script:**", "",
  "| Log | Script | Início | Fim |", "|---|---|---|---|", sprintf("| %s | `%s` | %s | %s |", ver$Log, ver$Script, ver$Inicio, ver$Fim),
  "| (este retorno) | `00_scripts/36_resposta_fase2C.R` | 4443971b | 4443971b (conferido no fim do script) |", "",
  "**SHA-256 dos scripts** (no momento de gravar este retorno):", "", tab_arq, "",
  "## 9. `git status`", "",
  "Saída de `git status --porcelain --untracked-files=all`, tirada antes de gravar este retorno e antes do commit local da Parte C. Os arquivos de outras sessões (Artigos 2 e 3), se houver, só são mostrados; as saídas em `01_saidas/` ficam fora do git:", "",
  "```", if (length(gst)) gst else "(limpo)", "```", "", "`git log --oneline -4`:", "", "```", glg, "```", "",
  "Commit local da Parte C (scripts, logs, desvios 65 e 66 e este retorno). **Push só depois do [ok]** de Guilherme, com a lista de commits (desvio 60).")

# ------------------------------------------------------------------ números da narrativa (seção 1) estão nos logs
narr <- md[seq_len(grep("^## 2\\. Entradas", md)[1] - 1)]
toks <- unique(unlist(regmatches(narr, gregexpr("[0-9]+ de [0-9]+|-?[0-9][0-9.]*,[0-9]+|[0-9]\\.[0-9]e-[0-9]+|[0-9]{1,3}(\\.[0-9]{3})+", narr))))
todos <- paste(unlist(L), collapse = "\n")
esc <- function(t) gsub("([.\\\\|()\\[\\]{}^$*+?])", "\\\\\\1", t, perl = TRUE)
fora <- toks[!vapply(toks, function(t) grepl(paste0("(?<![0-9.,])", esc(t), "(?![0-9]|,[0-9])"), todos, perl = TRUE), logical(1))]
if (length(fora)) stop("números da narrativa sem origem nos logs: ", paste(fora, collapse = ", "))
stopifnot(versao() == "4443971b")
writeLines(md, out, useBytes = TRUE)
cat("gravado:", out, "| números da narrativa conferidos:", length(toks), "| SHA-256:", sha(out), "\n")
