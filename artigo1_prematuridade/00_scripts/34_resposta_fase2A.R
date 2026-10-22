# 34_resposta_fase2A.R — Fase 2, Parte A: monta RESPOSTA_artigo1_prematuridade_FASE2A_<FASE2_DATA>.md a partir dos logs
# da Parte A (30, 31, 38, 33 e auditoria) e do log de desvios. Os números da narrativa vêm dos logs; no fim, o script
# confere que cada número da narrativa aparece num log (com limite de número). Para se a autoauditoria não der n/n ou
# se faltar a seção da auditoria independente. Não lê a base (o source do acesso.R só registra versao()). Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE2_DATA=AAAAMMDD Rscript 00_scripts/34_resposta_fase2A.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE2_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
out <- paste0("RESPOSTA_artigo1_prematuridade_FASE2A_", hoje, ".md"); stopifnot(!file.exists(out))
lg <- function(n) file.path("logs", paste0(n, "_fase2_", hoje, ".md"))
f_log <- c(a0 = lg("diagnostico_offset"), t = lg("testes_ajusta_dlnm"), d5b = lg("diagnostico_t05b"), aa = file.path("logs", paste0("autoauditoria_fase2A_", hoje, ".md")),
           aud = file.path("logs", paste0("auditoria_fase2A_", hoje, ".md")), dev = file.path("logs", "desvios_especificacao.md"))
stopifnot(all(file.exists(f_log)))
L <- lapply(f_log, readLines, encoding = "UTF-8"); J <- lapply(L, paste, collapse = "\n")
CC <- file.path("..", "codigo_compartilhado")
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
git <- function(...) system2("git", c("-C", "/Volumes/Forja/Doc/artigos_perinatais_clima", ...), stdout = TRUE)
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

# ------------------------------------------------------------------ travas e números da narrativa (dos logs)
aa <- num(J$aa, "(?<=## Resultado: )[0-9]+ de [0-9]+"); an <- as.numeric(strsplit(aa, " de ")[[1]])
if (an[1] != an[2]) stop("a autoauditoria não deu n/n (", aa, "): parar antes de gravar o retorno")
if (!length(grep("^## Etapa 2: auditoria independente", L$aud))) stop("falta a seção da auditoria independente")
nn <- num(J$t, "(?<=## Resultado: )[0-9]+/[0-9]+")
cob5 <- num(J$t, "(?<=\\| 5: contagem alta, efeito θ \\| )[0-9,]+ \\| [0-9,]+")
cob5 <- strsplit(cob5, " \\| ")[[1]][2]
vrel5 <- num(J$t, "(?<=obtido )-?[0-9,]+(?=%, EP)")
gama5 <- num(J$t, "(?<=\\*\\*γ̂ \\(teste 5\\):\\*\\* média )[0-9,]+")
cob6 <- strsplit(num(J$t, "(?<=\\| 6: nulo, contagem alta \\| )[0-9,]+ \\| [0-9,]+"), " \\| ")[[1]][2]
cob5b <- strsplit(num(J$t, "(?<=\\| 5b: contagem baixa, efeito θ \\| )[0-9,]+ \\| [0-9,]+"), " \\| ")[[1]][2]
d7 <- num(J$t, "(?<=\\) = )-?[0-9,]+(?= EP \\(exigido \\|·\\| < 2\\))")
v7 <- num(J$t, "(?<=\\*\\*Teste 7, `nenhum`:\\*\\* viés médio )[0-9,]+"); v7e <- num(J$t, "(?<=esperado )[0-9,]+(?=\\))")
if (!grepl("**Conclusão:** o diagnóstico não achou defeito no código nem no teste.", J$d5b, fixed = TRUE)) stop("o 38 não concluiu 'sem defeito': parar")
falhas31 <- grep("^\\| `[^`]+` \\| FALHOU", L$t, value = TRUE)
if (length(falhas31) != 1 || !grepl("`t05b_recuperacao_contagem_baixa`", falhas31)) stop("no 31, a única falha tem de ser a do t05b")
l1000 <- trimws(strsplit(grep("^\\| 5b: 1 a 1\\.000 \\|", L$d5b, value = TRUE), "|", fixed = TRUE)[[1]])
cob5b_1000 <- sub(" \\([0-9]+ de [0-9]+\\)", " (IC de Wilson", l1000[4]); cob5b_1000 <- sub("\\[([0-9,]+); ([0-9,]+)\\]", "\\1 a \\2)", cob5b_1000)
epdp_1000 <- l1000[7]
chance <- num(J$d5b, "(?<=por acaso: )[0-9,]+% se a cobertura verdadeira for 0,95; [0-9,]+% se for [0-9,]+")
frac_a0 <- num(J$a0, "(?<=dentro dos estratos \\| )[0-9,]+ \\([0-9,]+ a [0-9,]+\\)")
acf365 <- num(J$a0, "(?<=ACF lag 365 \\| )[0-9,]+")
fer_a0 <- num(J$a0, "(?<=Desvio médio nos feriados, carnaval e móveis \\| )[0-9,]+")
pacf_t5 <- num(J$t, "(?<=foi )-?[0-9,]+(?=; )")
n_def <- length(grep("^\\| ", secao(L$t, "^## Defeitos plantados"))) - 1   # menos o cabeçalho (o separador começa com "|-")
orig_def <- as.integer(regmatches(J$t, regexec("Os ([0-9]+) primeiros são os do prompt; os ([0-9]+) seguintes vêm da auditoria independente \\(desvio ([0-9]+)\\); os ([0-9]+) últimos, da re-auditoria \\(desvio ([0-9]+)\\)", J$t))[[1]][-1])
stopifnot(length(orig_def) == 5, orig_def[1] + orig_def[2] + orig_def[4] == n_def)
if (!grepl(sprintf("cada um dos %d defeitos derruba pelo menos um teste que passa no original", n_def), J$t, fixed = TRUE)) stop("algum defeito não foi detectado")
n_aud <- num(paste(secao(L$aud, "^## Etapa 2: auditoria independente"), collapse = "\n"), "(?<=\\*\\*Achados:\\*\\* )[0-9]+")
n_reaud <- num(paste(secao(L$aud, "^## Etapa 3: re-auditoria"), collapse = "\n"), "(?<=\\*\\*Achados:\\*\\* )[0-9]+")
dev_n <- as.integer(sub("^\\| ([0-9]+) \\|.*", "\\1", grep("^\\| [0-9]+ \\|", L$dev, value = TRUE)))
dev_fase <- sort(dev_n[dev_n >= 51]); stopifnot(length(dev_fase) >= 11, all(diff(dev_fase) == 1))
stopifnot(max(dev_fase) == orig_def[5], orig_def[3] == orig_def[5] - 1)   # 61 = 5b; os dois últimos = auditoria e re-auditoria
dev_5b <- orig_def[3] - 1

# ------------------------------------------------------------------ assinatura e documentação da função
fsrc <- readLines(file.path(CC, "R", "ajusta_dlnm.R"), encoding = "UTF-8")
doc <- sub("^# ?", "", fsrc[seq_len(which(!grepl("^#", fsrc))[1] - 1)])
fe <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = fe)
assin <- c(paste0("spec_agudo", sub("^function ", "", paste(deparse(args(fe$spec_agudo))[-length(deparse(args(fe$spec_agudo)))], collapse = "\n"))),
           paste0("ajusta_dlnm", sub("^function ", "", paste(deparse(args(fe$ajusta_dlnm))[-length(deparse(args(fe$ajusta_dlnm)))], collapse = "\n"))))
arqs <- c("../codigo_compartilhado/R/ajusta_dlnm.R", "../codigo_compartilhado/R/offset.R", "../codigo_compartilhado/tests/gera_sintetico.R",
          "../codigo_compartilhado/tests/testa_ajusta_dlnm.R", "../codigo_compartilhado/tests/testa_ajusta_dlnm_mc.R", "../codigo_compartilhado/tests/roda_testes.R",
          "00_scripts/30_diagnostico_offset.R", "00_scripts/31_testes_ajusta_dlnm.R", "00_scripts/33_autoauditoria_fase2A.R", "00_scripts/34_resposta_fase2A.R",
          "00_scripts/38_diagnostico_t05b.R")
tab_arq <- c("| Arquivo | SHA-256 |", "|---|---|", sprintf("| `%s` | `%s` |", sub("^\\.\\./", "", arqs), vapply(arqs, sha, "")))
ver <- do.call(rbind, lapply(c("a0", "t", "d5b", "aa"), function(k) data.frame(Log = paste0("`", basename(f_log[[k]]), "`"),
  Script = num(J[[k]], "(?<=Gerado por:\\*\\* `)[^`]+"), Inicio = num(J[[k]], "(?<=`versao\\(\\)` no início = )[0-9a-f]{8}"),
  Fim = num(J[[k]], "(?<=`versao\\(\\)` no fim: )[0-9a-f]{8}"), stringsAsFactors = FALSE)))
stopifnot(all(ver$Inicio == "4443971b"), all(ver$Fim == "4443971b"))
blas <- num(J$t, "(?<=BLAS/LAPACK: `)[^`]+")
# o código e os testes no disco são os mesmos que o 31 testou, o 38 diagnosticou e o 33 auditou
testados <- c("codigo_compartilhado/R/ajusta_dlnm.R", "codigo_compartilhado/tests/gera_sintetico.R", "codigo_compartilhado/tests/testa_ajusta_dlnm.R",
              "codigo_compartilhado/tests/testa_ajusta_dlnm_mc.R", "codigo_compartilhado/tests/roda_testes.R")
for (a in testados) {
  h <- sha(file.path("..", a)); alvo <- sprintf("`%s`: `%s`", a, h)
  if (!grepl(alvo, J$t, fixed = TRUE) || !grepl(alvo, J$aa, fixed = TRUE)) stop("SHA-256 de ", a, " difere do testado no 31 ou do auditado no 33")
}
if (!grepl(sprintf("SHA-256 `%s` (conferido", sha(file.path(CC, "R", "ajusta_dlnm.R"))), J$d5b, fixed = TRUE)) stop("SHA-256 da função difere do diagnosticado no 38")
cob5b_num <- as.numeric(sub(",", ".", cob5b)); stopifnot(cob5b_num > 0.98)
st <- git("status", "--porcelain", "--untracked-files=all"); lg3 <- git("log", "--oneline", "-4")

# ------------------------------------------------------------------ texto
md <- c(
  "# Artigo 1: prematuridade. Fase 2, Parte A: diagnóstico do offset, `ajusta_dlnm()` e testes", "",
  "**Para:** chat do Artigo 1 (prematuridade), via Guilherme.", "",
  sprintf("**Data:** %s/%s/%s.", substr(hoje, 7, 8), substr(hoje, 5, 6), substr(hoje, 1, 4)), "",
  "**Base:** `4443971b`, somente leitura (a Parte A não usa desfecho nem exposição da base: o diagnóstico A0 usa só `log_w` e calendário; os testes, só dado sintético).", "",
  sprintf("**Prompt:** Fase 2, v1.1 (SHA-256 informado `ec2bd62d…`), com o plano aprovado por Guilherme e os ajustes dele (desvios 51 a %d). A decisão sobre o teste 5b é o desvio %d; as correções da auditoria independente e da re-auditoria, os desvios %d e %d.",
          dev_5b - 1, dev_5b, orig_def[3], orig_def[5]), "",
  "## 1. Resumo", "",
  "- **Função:** `ajusta_dlnm(dados, spec)` com `spec_agudo()`, v1.0, só o desenho agudo (desvio 54). Uma unidade por chamada; cross-basis na série inteira recebida; estratos vazios removidos; `gnm` quasi-Poisson com `eliminate`; tudo em `tryCatch`; devolve coeficientes e vcov (cross-basis e reduzida, com dimensão), atributos da base, γ̂, φ, QAIC, PACF por unidade e diagnósticos, sem resíduos nem valores ajustados.",
  sprintf("- **Testes:** %s. Teste 5 (contagem alta): cobertura %s, viés relativo %s%%, γ̂ médio %s. Teste 6 (nulo): cobertura %s. Teste 7: `zw` × `z_w_gama` a %s EP; o modelo sem offset tem o viés positivo previsto (%s, contra %s declarado antes). Os %d defeitos plantados (%d do prompt, %d da auditoria e %d da re-auditoria) derrubam, cada um, pelo menos um teste que passa no original.",
          nn, cob5, vrel5, gama5, cob6, d7, v7, v7e, n_def, orig_def[1], orig_def[2], orig_def[4]),
  sprintf("- **Falha do teste 5b** (~3 eventos por dia): cobertura %s, acima do teto de 0,98. O diagnóstico não achou defeito: na mesma sequência estendida a 1.000 réplicas, a cobertura é %s, com EP/DP de %s. A chance de uma cobertura acima de 0,98 por acaso é de %s (a estimada em 1.000). A falha fica reportada como está; Guilherme decidiu seguir (desvio %d).",
          cob5b, cob5b_1000, epdp_1000, chance, dev_5b),
  sprintf("- **A0 (decisão 1(a)):** a fração da variância de `log_w` dentro dos estratos tem mediana %s; a autocorrelação no lag 365 tem mediana %s; nos feriados, `log_w` fica acima da média do estrato (mediana %s). Registro para o eMethods.", frac_a0, acf365, fer_a0),
  sprintf("- **Para o chat, antes da Parte C:** num modelo correto, a PACF dos resíduos fica em ~%s em todos os lags 1 a 7, por causa dos estratos mensais eliminados; a regra da §2.1 (lag fora de ±2/√n) dispararia em quase todas as concentrações. Dupla auditoria: autoauditoria %s iguais; auditoria independente com %s achados e re-auditoria das correções com %s (seção 5).", pacf_t5, aa, n_aud, n_reaud), "",
  "## 2. Diagnóstico descritivo do offset (A0)", "",
  grep("^- \\*\\*(Entrada|Definições)|^  - \\*\\*(fração|ACF|desvio)", L$a0, value = TRUE), "",
  com_titulo(L$a0, "^## Resumo nas 26"), com_titulo(L$a0, "^## Por concentração"),
  "## 3. Função: assinatura e documentação", "",
  "```r", assin, "```", "",
  "Documentação (cabeçalho de `codigo_compartilhado/R/ajusta_dlnm.R`):", "", "```", doc, "```", "",
  "**Notas:**", "",
  "- **Fallback (§5, critério 4):** a função não troca de especificação; devolve `status = \"falhou\"`. Com `argvar` ns p50/p90 e `arglag` strata 0–1, 2–4 e 5–7, a cross-basis tem 9 parâmetros e a curva reduzida 3 coeficientes e vcov 3 × 3 (teste 8b), numa base diferente da do principal.",
  "- **`cen`:** no `crossreduce(type = \"overall\")`, os coeficientes e a vcov reduzidos não dependem do `cen`; ele só muda `fit` e `RRfit`. A função devolve o `cen` usado e o RR no `cen` (= 1; teste 10). A centragem que vale para os resultados é a da Fase 3, contra a MRT.",
  "- **φ** = Pearson χ² / `m$df.residual` do `gnm`, que já desconta os estratos eliminados (teste 1, contra o `glm` com `factor(estrato)`). **QAIC** no estilo do MCC: −2·logL de Poisson + 2·φ·k, com k = parâmetros fora dos estratos (desvio 56); difere do do `glm` por uma constante.",
  "- **PACF:** por unidade, sobre a grade de datas da 1ª à última data da janela da unidade, com NA nos dias fora da janela ou do ajuste; `pacf(na.action = na.pass)`; limite ±2/√n com n = dias não NA; com n ≤ 8, sai NA, e `fora` sai NA se algum lag sair NA (testes 9a a 9c e 15).",
  "- **Aliasamento:** coeficiente aliasado na cross-basis dá `status = \"falhou\"`; fora dela (γ ou calendário), só aviso (leitura da A1.4). O `gnm` com `eliminate` não marca NA num termo colinear com os estratos: um `log_w` constante, ou constante dentro de cada estrato, sai com status \"ok\" e EP de γ enorme (re-auditoria; desvio 63). Para a cross-basis de temperatura isso é praticamente impossível; para o γ, quem chama tem de olhar o EP.", "",
  "## 4. Testes", "",
  com_titulo(L$t, "^## Gerador comum"), com_titulo(L$t, "^## Teste 5: efeito dentro"), com_titulo(L$t, "^## Teste 7: viés esperado"),
  com_titulo(L$t, "^## Resultado:"), com_titulo(L$t, "^## Monte Carlo:"),
  "### Diagnóstico da falha do teste 5b", "",
  grep("^- \\*\\*(Falha|Diagnóstico)", L$d5b, value = TRUE), "", grep("^\\| ", L$d5b, value = TRUE), "",
  grep("^- \\*\\*(Leitura|Conclusão)|^  - ", L$d5b, value = TRUE), "",
  com_titulo(L$t, "^## Observação para o chat"), com_titulo(L$t, "^## Defeitos plantados"),
  "## 5. Dupla auditoria", "",
  "### Autoauditoria (`33_autoauditoria_fase2A.R`)", "",
  grep("^- \\*\\*(Método|Código diferente|Limite)", L$aa, value = TRUE), "", com_titulo(L$aa, "^## Resultado:", 1),
  "### Auditoria independente", "", sprintf("Transcrita de `logs/%s`.", basename(f_log[["aud"]])), "",
  sub("^(#+) ", "\\1# ", L$aud[-1]),
  "## 6. Desvios", "",
  sprintf("As linhas %d a %d do log de desvios são desta fase. As de %d a %d foram registradas antes de rodar; a %d, antes de seguir depois da falha do 5b; a %d e a %d, antes de rodar de novo os scripts 31, 38 e 33.",
          min(dev_fase), max(dev_fase), min(dev_fase), dev_5b - 1, dev_5b, orig_def[3], orig_def[5]), "",
  cab_dev, vapply(dev_fase, linha_dev, ""), "",
  "## 7. Comandos para reproduzir", "",
  "Da pasta `artigo1_prematuridade/`, com o `renv` do artigo (R 4.5.1), nesta ordem. Cada script tem trava contra sobrescrita.", "",
  "```", sprintf("FASE2_DATA=%s Rscript 00_scripts/%s.R", hoje, c("30_diagnostico_offset", "31_testes_ajusta_dlnm", "38_diagnostico_t05b", "33_autoauditoria_fase2A", "34_resposta_fase2A")), "```", "",
  sprintf("**BLAS/LAPACK** (`sessionInfo()`, log do 31): `%s`.", blas), "",
  "**`versao()` no início e no fim de cada script:**", "",
  "| Log | Script | Início | Fim |", "|---|---|---|---|", sprintf("| %s | `%s` | %s | %s |", ver$Log, ver$Script, ver$Inicio, ver$Fim),
  "| (este retorno) | `00_scripts/34_resposta_fase2A.R` | 4443971b | 4443971b (conferido no fim do script) |", "",
  "**SHA-256 do código, dos testes e dos scripts** (no momento de gravar este retorno):", "", tab_arq, "",
  "## 8. `git status`", "",
  "Saída de `git status --porcelain --untracked-files=all`, tirada antes de gravar este retorno e antes do commit local da Parte A (que, por isso, não aparecem nela). Os arquivos de outras sessões (Artigos 2 e 3), se houver, só são mostrados:", "",
  "```", if (length(st)) st else "(limpo)", "```", "", "`git log --oneline -4`:", "", "```", lg3, "```", "",
  "Commit local da Parte A: código, testes, scripts, logs e este retorno. **Sem push e sem tag** (Parte B, só depois de \"CÓDIGO LIBERADO\").")

# ------------------------------------------------------------------ números da narrativa (seção 1) estão nos logs
narr <- md[seq_len(grep("^## 2\\. Diagnóstico", md)[1] - 1)]
toks <- unique(unlist(regmatches(narr, gregexpr("[0-9]+ de [0-9]+|[0-9]+/[0-9]+|-?[0-9][0-9.]*,[0-9]+|[0-9]{1,3}(\\.[0-9]{3})+", narr))))
todos <- paste(unlist(L), collapse = "\n")
esc <- function(t) gsub("([.\\\\|()\\[\\]{}^$*+?])", "\\\\\\1", t, perl = TRUE)
fora <- toks[!vapply(toks, function(t) grepl(paste0("(?<![0-9.,])", esc(t), "(?![0-9]|,[0-9])"), todos, perl = TRUE), logical(1))]
if (length(fora)) stop("números da narrativa sem origem nos logs: ", paste(fora, collapse = ", "))
stopifnot(versao() == "4443971b")
writeLines(md, out, useBytes = TRUE)
cat("gravado:", out, "| números da narrativa conferidos:", length(toks), "| SHA-256:", sha(out), "\n")
