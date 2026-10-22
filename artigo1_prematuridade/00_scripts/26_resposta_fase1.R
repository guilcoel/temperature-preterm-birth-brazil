# 26_resposta_fase1.R — Fase 1: monta o retorno RESPOSTA_artigo1_prematuridade_FASE1_<FASE1_DATA>.md a partir dos logs
# da fase (24, 20, 21, 22, 23, 25, auditoria) e do log de desvios. Os números da narrativa vêm dos logs ou de
# 01_saidas/fase1/conferencias_valores.csv; no fim, o script confere que cada número da narrativa aparece num log.
# Não lê a base (o source do acesso.R só registra versao()). Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE1_DATA=AAAAMMDD Rscript 00_scripts/26_resposta_fase1.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE1_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
out <- paste0("RESPOSTA_artigo1_prematuridade_FASE1_", hoje, ".md"); stopifnot(!file.exists(out))
lg <- function(n) file.path("logs", paste0(n, "_fase1_", hoje, ".md"))
f_log <- c(a1 = lg("testes_compartilhado"), a2 = lg("serie_principal"), a3 = lg("serie_municipal"), a4 = lg("ptb_espontaneo"),
           a6 = lg("conferencias"), a7 = lg("autoauditoria"), aud = file.path("logs", paste0("auditoria_fase1_", hoje, ".md")),
           dev = file.path("logs", "desvios_especificacao.md"))
stopifnot(all(file.exists(f_log)))
L <- lapply(f_log, readLines, encoding = "UTF-8")
V <- read.csv(file.path("01_saidas", "fase1", "conferencias_valores.csv"), stringsAsFactors = FALSE,
              colClasses = c(item = "character", chave = "character"), fileEncoding = "UTF-8")
val <- function(item, chave) V$valor[V$item == item & V$chave == chave]
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
git <- function(...) system2("git", c("-C", "/Volumes/Forja/Doc/artigos_perinatais_clima", ...), stdout = TRUE)
# trecho de um log entre um título (regex) e o próximo título de mesmo nível ou mais alto
secao <- function(x, titulo, nivel = 2) {
  i <- grep(titulo, x)[1]; stopifnot(!is.na(i))
  prox <- grep(paste0("^#{1,", nivel, "} "), x); prox <- prox[prox > i]
  fim <- if (length(prox)) prox[1] - 1 else length(x)
  x[(i + 1):fim]
}
rebaixa <- function(x, n = 1) sub("^(#+) ", paste0("\\1", strrep("#", n), " "), x)          # desce o nível dos títulos
linha_dev <- function(n) { x <- grep(paste0("^\\| ", n, " \\|"), L$dev, value = TRUE); stopifnot(length(x) == 1); x }
cab_dev <- L$dev[grep("^\\| # \\|", L$dev)[1] + 0:1]
num_txt <- function(x, padrao) regmatches(x, regexpr(padrao, x, perl = TRUE))

# ------------------------------------------------------------------ números da narrativa (todos tirados dos logs)
a2 <- paste(L$a2, collapse = "\n"); a3 <- paste(L$a3, collapse = "\n"); a1 <- paste(L$a1, collapse = "\n"); a7 <- paste(L$a7, collapse = "\n")
lin_pri <- num_txt(a2, "[0-9.]+(?= linhas\\. A janela principal)"); lin_mun <- num_txt(a3, "[0-9.]+(?= linhas, sem lacuna)")
bat <- num_txt(a1, "(?<=Bateria original: )[0-9]+/[0-9]+")
auto <- num_txt(a7, "(?<=## Resultado: )[0-9]+ de [0-9]+")
an <- as.numeric(strsplit(auto, " de ")[[1]])
if (an[1] != an[2]) stop("a autoauditoria não deu n/n (", auto, "): parar antes de gravar o retorno")          # desvio 49
a6 <- paste(L$a6, collapse = "\n")
if (grepl("**FALHA:**", a6, fixed = TRUE) || !grepl("Todas as conferências obrigatórias passaram", a6, fixed = TRUE))
  stop("o log da A6 tem FALHA ou não diz que as obrigatórias passaram: parar antes de gravar o retorno")
def <- grep("^\\| (N_j|W_t|semana 36)", L$a1, value = TRUE); stopifnot(length(def) == 3)
def_n <- vapply(strsplit(def, " \\| "), function(p) p[3], "")
dp_sp_v <- val("3", "dp_logw_3550308"); dp_so_v <- val("3", "dp_logw_3552205")
dp_sp <- br(dp_sp_v, 4); dp_so <- br(dp_so_v, 4)
lado <- function(obs, prev) if (obs > 1.1 * prev) "acima" else if (obs < 0.9 * prev) "abaixo" else "perto"
r_comp <- br(sqrt(val("3", "zt_medio_3550308") / val("3", "zt_medio_3552205")), 2)        # razão esperada só por composição
r_esp <- br(0.022 / 0.007, 2); r_obs <- br(dp_so_v / dp_sp_v, 2)                        # prevista (§3.1) e observada
n_cresc <- val("5", "conc_crescente"); tot <- br(val("2", "ptb_jp_total")); cel <- val("4", "celulas")
stopifnot(val("4", "diferentes") == 0, val("9", "dif_identidade") == 0, val("6", "estratos_sem_ptb") == 0)
nuc <- as.data.frame(cidade_nucleo()); nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
p_ign <- vapply(nuc$CD_RECORTE, function(r) val("9", paste0("pct_ign_", r)), 0); top3 <- names(sort(p_ign, decreasing = TRUE))[1:3]
ign_txt <- paste(sprintf("%s %s%%", sub("/.*", "", nome[top3]), br(p_ign[top3], 1)), collapse = ", ")    # as três maiores
aud <- paste(L$aud, collapse = "\n")
n_ach <- num_txt(aud, "(?<=\\*\\*Achados:\\*\\* )[0-9]+")
stopifnot(length(grep("^## Reauditoria", L$aud)) == 1)                                   # seção obrigatória (desvio 49)
reaud <- num_txt(aud, "(?<=\\*\\*Achados da primeira auditoria:\\*\\* )[^\n]+"); stopifnot(length(reaud) == 1)
n_novos <- num_txt(aud, "(?<=\\*\\*Achados novos:\\*\\* )[0-9]+"); stopifnot(length(n_novos) == 1)
dev_n <- as.integer(sub("^\\| ([0-9]+) \\|.*", "\\1", grep("^\\| [0-9]+ \\|", L$dev, value = TRUE)))
dev_fase <- sort(dev_n[dev_n >= 40]); stopifnot(all(diff(dev_fase) == 1))                 # todos a partir do 40, sem número fixo
dev_de <- function(padrao) { x <- grep(padrao, L$dev, value = TRUE, fixed = TRUE); stopifnot(length(x) == 1); as.integer(sub("^\\| ([0-9]+) \\|.*", "\\1", x)) }
n_corr <- dev_de("Correções da reauditoria"); n_inc <- dev_de("Incidente de sigilo: cópia temporária")

# ------------------------------------------------------------------ git e arquivos
arqs <- c("00_scripts/24_testes_compartilhado_fase1.R", "00_scripts/20_monta_serie_principal.R", "00_scripts/21_monta_serie_municipal.R",
          "00_scripts/22_monta_ptb_espontaneo.R", "00_scripts/23_confere_fase1.R", "00_scripts/25_autoauditoria_fase1.R",
          "00_scripts/26_resposta_fase1.R", "../codigo_compartilhado/R/offset.R", "../codigo_compartilhado/tests/testa_offset.R",
          "../codigo_compartilhado/tests/roda_testes.R", "../codigo_compartilhado/DESCRIPTION")
tab_arq <- c("| Arquivo | SHA-256 |", "|---|---|", sprintf("| `%s` | `%s` |", sub("^\\.\\./", "", arqs), vapply(arqs, sha, "")))
saidas <- unlist(lapply(L[c("a2", "a3", "a4")], function(x) grep("^  - `01_saidas/fase1/|SHA-256:\\*\\* `01_saidas", x, value = TRUE)))
ver <- do.call(rbind, lapply(c("a1", "a2", "a3", "a4", "a6", "a7"), function(k) {
  x <- paste(L[[k]], collapse = "\n")
  data.frame(Log = paste0("`", basename(f_log[[k]]), "`"), Script = num_txt(x, "(?<=Gerado por:\\*\\* `)[^`]+"),
             Início = num_txt(x, "(?<=`versao\\(\\)` no início = )[0-9a-f]{8}"), Fim = num_txt(x, "(?<=`versao\\(\\)` no fim: )[0-9a-f]{8}"),
             stringsAsFactors = FALSE)
}))
stopifnot(all(ver$Início == "4443971b"), all(ver$Fim == "4443971b"))
tab_ver <- c("| Log | Script | `versao()` no início | `versao()` no fim |", "|---|---|---|---|",
             sprintf("| %s | `%s` | %s | %s |", ver$Log, ver$Script, ver$Início, ver$Fim),
             "| (este retorno) | `00_scripts/26_resposta_fase1.R` | 4443971b | 4443971b (conferido no fim do script) |")
st <- git("status", "--porcelain", "--untracked-files=all"); lg3 <- git("log", "--oneline", "-3")
tag <- git("rev-parse", "spec-v2.0.2-congelada-20261009"); tag_c <- git("rev-parse", "spec-v2.0.2-congelada-20261009^{commit}")

# ------------------------------------------------------------------ texto
md <- c(
  "# Artigo 1: prematuridade. Fase 1: séries, offset e funções compartilhadas (sem modelo)", "",
  "**Para:** chat do Artigo 1 (prematuridade), via Guilherme.", "",
  sprintf("**Data:** %s/%s/%s.", substr(hoje, 7, 8), substr(hoje, 5, 6), substr(hoje, 1, 4)), "",
  "**Base:** `4443971b`, somente leitura.", "",
  "**Prompt:** Fase 1, v1.1, do chat do Artigo 1, com o plano aprovado por Guilherme (decisões nos desvios 40 a 45).", "",
  sprintf("**Tag congelada:** `spec-v2.0.2-congelada-20261009` (objeto `%s`, aponta para `%s`), sem mudança.", tag, tag_c), "",
  "## 1. Resumo", "",
  sprintf("- **Conjuntos analíticos montados, fora do git, em `01_saidas/fase1/`:** série principal (%s linhas: 26 concentrações × 4.721 dias, de 2011-12-14 a 2024-11-15), série da case time series municipal (%s linhas, sem lacuna) e série de PTB espontâneo. O esquema da série principal é o contrato de entrada do `ajusta_dlnm()` (seção 4). Nenhum modelo foi ajustado.",
          lin_pri, lin_mun),
  sprintf("- **Conferências da A6, todas as obrigatórias passaram** (conferido no log da A6): soma de PTB na janela principal igual à A5.2 nas 26 concentrações (total %s); Z_tj recomputado de `nascimentos()` igual ao `z_nv` da base (%d células); offset completo na janela de evento possível; todas as semanas de 22 a 36 em todos os dias da janela principal; calendário e referências de exposição iguais à base e à A5.3; identidade do espontâneo sem divergência.",
          tot, cel),
  sprintf("- **Funções compartilhadas** `calcula_wj()` e `monta_offset()`: bateria sintética %s; os 3 defeitos plantados derrubam %s, %s e %s testes.", bat, def_n[1], def_n[2], def_n[3]),
  sprintf("- **Dupla auditoria:** autoauditoria %s iguais, com código diferente. A auditoria independente achou %s pontos, um deles bloqueante de sigilo: o desvio 46 publicava uma contagem de 1 a 9. Foi corrigido antes do commit, e a cadeia rodou de novo com as correções (desvios 46 a 48). A reauditoria das correções achou %s pontos novos, todos tratados antes do commit (desvio %d), e a cadeia rodou pela terceira vez, com dados idênticos byte a byte aos da segunda. **Dois incidentes da sessão, registrados:** a contagem do nº 46 saiu também numa mensagem ao Guilherme e no stdout (desvio 47; não tem volta); e, na 3ª rodada, cópias dos RDS e CSV ficaram menos de um minuto fora da Forja, no scratchpad do Mac Mini, antes de voltarem (desvio %d).",
          auto, n_ach, n_novos, n_corr, n_inc),
  sprintf("- **Para o chat avaliar:** (a) o DP intra-estrato de `log_w` ficou %s da previsão da §3.1 em São Paulo (%s, previsto ~0,007) e %s em Sorocaba (%s, previsto ~0,022); (b) o w_j é crescente de 22 a 36 em %d de 26 concentrações; (c) o PTB com início ignorado é alto em algumas concentrações (2013–2023; as três maiores: %s), o que pesa na versão (ii) do espontâneo. Detalhes na seção 5 e nas observações.",
          lado(dp_sp_v, 0.007), dp_sp, lado(dp_so_v, 0.022), dp_so, n_cresc, ign_txt), "",
  "## 2. A0: linhas novas do log de desvios", "",
  "**Linha 5 do cabeçalho**, trocada como pede a A0.1 (a única linha antiga alterada):", "",
  L$dev[5], "",
  "**Linhas 37 a 39:**", "", cab_dev, linha_dev(37), linha_dev(38), linha_dev(39), "",
  "**A0.4:** a consulta ao `CreateEvent` em segundo plano foi encerrada às 21:40Z (desvio 38).", "",
  "**Commit separado da A0:** `41ca2f6`, local, antes de qualquer script da fase (desvio 41).", "",
  "## 3. A1: funções, testes e defeitos plantados", "",
  rebaixa(c("## Funções", secao(L$a1, "^## Funções"))),
  rebaixa(c(grep("^## Bateria original", L$a1, value = TRUE), secao(L$a1, "^## Bateria original"))),
  rebaixa(c(grep("^## Defeitos plantados", L$a1, value = TRUE), secao(L$a1, "^## Defeitos plantados"))),
  "Os testes estão em `codigo_compartilhado/tests/` e foram escritos em R base, porque o `testthat` não está no `renv.lock` (desvio 42).", "",
  "## 4. Esquema do conjunto analítico principal: contrato de entrada do `ajusta_dlnm()`", "",
  secao(L$a2, "^## Esquema do conjunto analítico principal"),
  "**Notas do contrato:**", "",
  "- **Dias de modelo:** `janela_principal` (principal) ou `janela_evento_possivel` (sensibilidade); os 7, 14 ou 21 dias anteriores servem de aquecimento da cross-basis.",
  "- **Offset:** `log_z` + γ·`log_w` (γ estimado) ou `log_zw` (γ = 1). É NA fora da janela de evento possível.",
  "- **Contagens:** NA de 2011-12-14 a 2011-12-31 (contagens de 2011 que dependem de IG, na base). Nesses dias, `z_t` = 0 e `z_t_zero` = TRUE (desvio 48).",
  "- **Estrato e calendário:** `estrato` = `recorte_principal`_ano_mês, para o `eliminate`; `dia_semana` é fator com 7 níveis, segunda primeiro.",
  "- **Séries das sensibilidades:** a A3 e a A4 têm esquema próprio, nos logs `serie_municipal_fase1_*.md` e `ptb_espontaneo_fase1_*.md`. Na A3, quem decide o ajuste é a `linha_modelo`.", "",
  "**A5: o que fica para a Fase 4** (registrado no log do 20):", "", secao(L$a2, "^## A5: o que fica para a Fase 4"),
  "## 5. Conferências da A6, completas", "",
  sprintf("Transcritas de `logs/%s`. Só agregados por concentração × janela, concentração × ano ou mais grossos.", basename(f_log[["a6"]])), "",
  rebaixa(unlist(lapply(c("^## 1\\. Cobertura", "^## 2\\. Totais", "^## 3\\. Offset", "^## 4\\. Recomputação", "^## 5\\. w_j", "^## 6\\. Estratos",
                         "^## 7\\. Calendário", "^## 8\\. Referências", "^## 9\\. PTB espontâneo", "^## 10\\. Case time series", "^## Resultado"),
                       function(t) c(grep(t, L$a6, value = TRUE), secao(L$a6, t))))),
  "### Observações para o chat", "",
  sprintf("- **DP de `log_w` (item 3):** São Paulo (%s; previsto ~0,007 na §3.1) fica %s da previsão, e Sorocaba (%s; previsto ~0,022) fica %s. Se a variação fosse só ruído de composição, a razão Sorocaba/São Paulo seria de cerca de %s (raiz da razão dos Z_t médios); a especificação prevê %s e o observado é %s. Há um componente que não cai com o tamanho da concentração.",
          dp_sp, lado(dp_sp_v, 0.007), dp_so, lado(dp_so_v, 0.022), r_comp, r_esp, r_obs),
  "  - Hipóteses do auditor, não verificadas: quedas de nascimentos em feriados, herdadas por s = parto − (7·IG + 3); preferência de registro da IG que varia no tempo; forma real da sazonalidade das concepções. O dia da semana dos partos se anula nas semanas completas.",
  "  - É checagem de plausibilidade, sem critério de parada. Sugestão: antes da Fase 2, um diagnóstico agregado na Forja (parte da variância de `log_w` no estrato explicada por tendência; autocorrelação nos lags 7 e 365), sem desfecho.",
  sprintf("- **w_j (item 5):** é crescente de 22 a 36 em %d de 26 concentrações; nas outras há inversões locais. Não é critério de parada. Pode refletir preferência de registro de algumas semanas (§3.1).", n_cresc),
  "- **PTB espontâneo (item 9):** o % de ignorados cai no tempo, como a especificação previa. O nível por concentração varia muito, o que afeta a distância entre as versões (i) e (ii).", "",
  "## 6. Dupla auditoria", "",
  "### Autoauditoria (`25_autoauditoria_fase1.R`)", "",
  grep("^- \\*\\*(Método|Código diferente|Tolerâncias)", L$a7, value = TRUE), "",
  rebaixa(c(grep("^## Resultado", L$a7, value = TRUE), secao(L$a7, "^## Resultado")), 2),
  "### Auditoria independente", "",
  sprintf("Transcrita de `logs/%s`.", basename(f_log[["aud"]])), "",
  rebaixa(secao(L$aud, "^## Etapa 2: auditoria independente"), 1),
  rebaixa(c("## Regeneração da cadeia (desvio 48)", secao(L$aud, "^## Regeneração da cadeia")), 1),
  rebaixa(c(grep("^## Reauditoria", L$aud, value = TRUE), secao(L$aud, "^## Reauditoria")), 1),
  "## 7. Desvios novos", "",
  sprintf("As linhas 37 a 39 estão na seção 2. As decisões do plano foram registradas antes de rodar (40 a 45, no commit da A0 `41ca2f6`); os achados de execução e de auditoria, nas linhas 46 a %d.", max(dev_fase)), "",
  cab_dev, vapply(dev_fase, linha_dev, ""), "",
  "## 8. Scripts e comandos para reproduzir", "",
  "Da pasta `artigo1_prematuridade/`, com o `renv` do artigo (R 4.5.1), nesta ordem. Cada script tem trava contra sobrescrita: para reproduzir, mande antes os arquivos gravados para o Lixo ou rode numa cópia.", "",
  "```", sprintf("FASE1_DATA=%s Rscript 00_scripts/%s.R", hoje,
                 c("24_testes_compartilhado_fase1", "20_monta_serie_principal", "21_monta_serie_municipal", "22_monta_ptb_espontaneo",
                   "23_confere_fase1", "25_autoauditoria_fase1", "26_resposta_fase1")), "```", "",
  "| Script | Bloco | Grava |", "|---|---|---|",
  "| `24_testes_compartilhado_fase1.R` | A1 | `logs/testes_compartilhado_fase1_<data>.md` |",
  "| `20_monta_serie_principal.R` | A2 (e registro da A5) | `01_saidas/fase1/serie_ptb_principal.rds`, `wj_ptb_concentracao.csv`, `referencias_exposicao.csv`; `logs/serie_principal_fase1_<data>.md` |",
  "| `21_monta_serie_municipal.R` | A3 | `01_saidas/fase1/serie_ptb_municipal.rds`, `nos_tmean_mun_concentracao.csv`; `logs/serie_municipal_fase1_<data>.md` |",
  "| `22_monta_ptb_espontaneo.R` | A4 | `01_saidas/fase1/serie_ptb_espontaneo.rds`; `logs/ptb_espontaneo_fase1_<data>.md` |",
  "| `23_confere_fase1.R` | A6 | `logs/conferencias_fase1_<data>.md`; `01_saidas/fase1/conferencias_valores.csv` |",
  "| `25_autoauditoria_fase1.R` | A7.1 | `logs/autoauditoria_fase1_<data>.md` |",
  "| `26_resposta_fase1.R` | retorno | este arquivo |", "",
  "**SHA-256 do código** (no momento de gravar este retorno):", "", tab_arq, "",
  "**SHA-256 dos arquivos gravados** (fora do git; conforme os logs):", "", saidas, "",
  "## 9. `versao()` no início e no fim de cada script", "", tab_ver, "",
  "## 10. `git status`", "",
  "Saída de `git status --porcelain --untracked-files=all`, tirada antes do commit da fase e antes de gravar este retorno (que, por isso, não aparece nela e entra no mesmo commit). O `01_saidas/` não aparece porque está no `.gitignore`:", "",
  "```", if (length(st)) st else "(limpo)", "```", "",
  "`git log --oneline -3`:", "", "```", lg3, "```", "",
  "O commit da fase (`Fase 1 do Artigo 1: series, offset e funcoes compartilhadas (sem modelo)`) leva código, testes, logs e este retorno, nunca dados. O push espera o [ok] de Guilherme.")

# ------------------------------------------------------------------ autoauditoria do retorno: números da narrativa estão nos logs
narr <- md[seq_len(grep("^## 2\\. A0", md)[1] - 1)]
i_obs <- grep("^### Observações para o chat", md); i_aud <- grep("^## 6\\. Dupla auditoria", md)
narr <- c(narr, md[i_obs:i_aud])
# tokens: decimais com vírgula, milhares com ponto, "n/n" e "n de n"; busca com limite de número (desvio 49): "20,9" não casa com "20,95"
toks <- unique(unlist(regmatches(narr, gregexpr("[0-9]+ de [0-9]+|[0-9]+/[0-9]+|[0-9][0-9.]*,[0-9]+|[0-9]{1,3}(\\.[0-9]{3})+", narr))))
todos <- paste(unlist(L), collapse = "\n")
esc <- function(t) gsub("([.\\\\|()\\[\\]{}^$*+?])", "\\\\\\1", t, perl = TRUE)
tem <- function(t) grepl(paste0("(?<![0-9.,])", esc(t), "(?![0-9]|,[0-9])"), todos, perl = TRUE)
fora <- toks[!vapply(toks, tem, logical(1))]
if (length(fora)) stop("números da narrativa sem origem nos logs: ", paste(fora, collapse = ", "))
stopifnot(versao() == "4443971b")
writeLines(md, out, useBytes = TRUE)
cat("gravado:", out, "| números da narrativa conferidos contra os logs:", length(toks), "| SHA-256:", sha(out), "\n")
