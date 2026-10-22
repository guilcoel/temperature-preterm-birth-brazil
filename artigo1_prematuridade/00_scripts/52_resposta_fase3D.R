# 52_resposta_fase3D.R — Fase 3, Parte D: monta RESPOSTA_artigo1_prematuridade_FASE3D_<FASE3_DATA>.md a partir dos logs
# do 49 (testes), do 50 (post hoc), do 51 (autoauditoria), da auditoria independente e do log de desvios. Os números da
# narrativa vêm dos logs e são conferidos no fim. Para se o 49 não passou, se a autoauditoria não der n/n, se faltar a
# seção da auditoria independente ou se uma saída no disco diferir do SHA-256 do log. Rótulo: post hoc, não
# pré-especificado; sem leitura causal. Não lê a base. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/52_resposta_fase3D.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"
out <- paste0("RESPOSTA_artigo1_prematuridade_FASE3D_", hoje, ".md"); stopifnot(!file.exists(out))
lg <- function(n) file.path("logs", paste0(n, "_fase3_", hoje, ".md"))
f_log <- c(t = lg("testes_posthoc_af"), ph = lg("posthoc_af"), aa = lg("autoauditoria_parteD"), aud = lg("auditoria_parteD"), dev = file.path("logs", "desvios_especificacao.md"))
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
com_titulo <- function(x, titulo, n = 1) c(sub("^(#+) ", paste0("\\1", strrep("#", n), " "), grep(titulo, x, value = TRUE)[1]), "",
                                           sub("^(#+) ", paste0("\\1", strrep("#", n), " "), secao(x, titulo, nivel = 2)))
linha_dev <- function(n) { x <- grep(paste0("^\\| ", n, " \\|"), L$dev, value = TRUE); stopifnot(length(x) == 1); x }
cab_dev <- L$dev[grep("^\\| # \\|", L$dev)[1] + 0:1]

# ------------------------------------------------------------------ travas
if (!grepl("cada um dos 15 defeitos derruba pelo menos um teste", J$t, fixed = TRUE)) stop("o 49 não passou")
nt <- num(J$t, "(?<=## Resultado: )[0-9]+/[0-9]+"); ntv <- as.numeric(strsplit(nt, "/")[[1]]); if (ntv[1] != ntv[2]) stop("testes do 49 sem n/n")
aa <- num(J$aa, "(?<=## Resultado: )[0-9]+ de [0-9]+"); an <- as.numeric(strsplit(aa, " de ")[[1]]); if (an[1] != an[2]) stop("autoauditoria sem n/n")
if (!length(grep("^## Auditoria independente", L$aud))) stop("falta a seção da auditoria independente")
n_aud <- num(paste(secao(L$aud, "^## Auditoria independente"), collapse = "\n"), "(?<=\\*\\*Achados:\\*\\* )[0-9]+")
TAG <- "segunda_etapa-v1.0"
for (a in git("ls-tree", "-r", "--name-only", TAG, "codigo_compartilhado/R/")) {
  st <- sub(" .*", "", system(paste("git -C", shQuote(REPO), "show", shQuote(paste0(TAG, ":", a)), "| shasum -a 256"), intern = TRUE))
  if (!identical(st, sha(file.path(REPO, a)))) stop(a, " difere da tag ", TAG) }
sp <- sha(file.path(REPO, "codigo_compartilhado/R/posthoc_af.R"))
if (!grepl(sprintf("`codigo_compartilhado/R/posthoc_af.R`: `%s`", sp), J$t, fixed = TRUE) || !grepl(sprintf("`codigo_compartilhado/R/posthoc_af.R`: `%s`", sp), J$ph, fixed = TRUE))
  stop("posthoc_af.R diferente do testado no 49 ou do usado no 50")
so <- regmatches(J$ph, gregexpr("`01_saidas/fase3/posthoc_[^`]+`: `[0-9a-f]{64}`", J$ph))[[1]]
so <- data.frame(arquivo = sub("^`([^`]+)`.*", "\\1", so), sha = sub(".*: `([0-9a-f]{64})`$", "\\1", so), stringsAsFactors = FALSE)
if (nrow(so) != 3 || !identical(unname(vapply(so$arquivo, sha, "")), so$sha)) stop("saída do 50 diferente do SHA-256 registrado")

# ------------------------------------------------------------------ números da narrativa (dos logs)
p1 <- num(J$ph, "(?<=\\*\\*W = )[0-9,]+; gl = 4; p = [0-9,e-]+(?=\\*\\*)")
comp <- num(J$ph, "(?<=\\*\\*Única comparação:\\*\\* )[^\n]+")
falhas <- num(J$ph, "(?<=\\*\\*Falhas\\*\\* \\(sequência inteira do `mixmeta` falhou\\): )[0-9.]*[0-9] de [0-9.]*[0-9]")
base_i <- num(J$ph, "(?<=nas grade p1–p99 de cada concentração: |na grade p1–p99 de cada concentração: )[^;]+")
cont_ii <- num(J$ph, "(?<=exigido Δ_t ≥ −max\\(g, 0\\) − 1e-12: )[^.]+(?=\\. \\*\\*g máximo)")
gmax <- num(J$ph, "(?<=\\*\\*g máximo:\\*\\* )[0-9]\\.[0-9]+e[-+][0-9]+"); mind <- num(J$ph, "(?<=\\*\\*menor Δ_t:\\*\\* )-?[0-9]\\.[0-9]+e[-+][0-9]+")
diag <- num(J$ph, "(?<=Com o passo de 1e-5 °C, o menor f\\(x_t\\) fica a no máximo 1e-12 abaixo do mínimo da grade em )[^.]+")
ver <- do.call(rbind, lapply(c("t", "ph", "aa"), function(k) data.frame(Log = paste0("`", basename(f_log[[k]]), "`"),
  Script = num(J[[k]], "(?<=Gerado por:\\*\\* `)[^`]+"), Inicio = num(J[[k]], "(?<=`versao\\(\\)` no início = )[0-9a-f]{8}"),
  Fim = num(J[[k]], "(?<=`versao\\(\\)` no fim: )[0-9a-f]{8}"), stringsAsFactors = FALSE)))
stopifnot(all(ver$Inicio == "4443971b"), all(ver$Fim == "4443971b"))
arqs <- c("00_scripts/49_testes_posthoc_af.R", "00_scripts/50_posthoc_af.R", "00_scripts/51_autoauditoria_fase3D.R", "00_scripts/52_resposta_fase3D.R")
tab_arq <- c("| Arquivo | SHA-256 |", "|---|---|",
             sprintf("| `%s` | `%s` |", c("codigo_compartilhado/R/posthoc_af.R", "codigo_compartilhado/tests/testa_posthoc_af.R", paste0("artigo1_prematuridade/", arqs), paste0("artigo1_prematuridade/", so$arquivo)),
                     c(sp, sha(file.path(REPO, "codigo_compartilhado/tests/testa_posthoc_af.R")), vapply(arqs, sha, ""), so$sha)))
gst <- git("status", "--porcelain", "--untracked-files=all"); glg <- git("log", "--oneline", "-4")

# ------------------------------------------------------------------ texto
md <- c(
  "# Artigo 1: prematuridade. Fase 3, Parte D: análises post hoc da D5 (P1 e P2)", "",
  "**Para:** chat do Artigo 1 (prematuridade), via Guilherme.", "",
  sprintf("**Data:** %s/%s/%s.", substr(hoje, 7, 8), substr(hoje, 5, 6), substr(hoje, 1, 4)), "",
  "**Rótulo:** análises **post hoc, não pré-especificadas**, registradas antes de rodar (entradas 78 e 79; commits `7e071cd` e `e925532`) e **depois de ver os resultados da Fase 3**. Decisão de origem: `spec/decisoes_metodo_20261013_D5_interpretacao_AF.md` (SHA-256 `24f131e8…`). Nenhuma análise especificada muda. Só tabelas, sem leitura causal.", "",
  "**Código:** `codigo_compartilhado/R/posthoc_af.R` (para a tag `posthoc_af-v1.0`, que só sai depois da aprovação desta RESPOSTA, no commit que rodou), com as funções da tag `segunda_etapa-v1.0` sem alteração.", "",
  "## 1. Resumo", "",
  sprintf("- **Testes sintéticos (49):** %s; cada um dos 15 defeitos plantados (11 do plano e 4 da auditoria independente) derruba pelo menos um teste.", nt),
  sprintf("- **Testes do item 2 no principal observado:** (i) pré-condição (base da `attrdl` = base da busca da MRT): %s; (ii) contribuições: %s; g máximo %s; menor Δ_t %s. Diagnóstico com passo de 1e-5 °C: ok em %s.", base_i, cont_ii, gmax, mind, diag),
  sprintf("- **P1 (Wald da curva combinada, 4 gl):** W = %s.", p1),
  sprintf("- **P2 (referência nula da AF, nulo estrito, descritiva):** falhas %s. %s", falhas, comp),
  sprintf("- **Dupla auditoria:** autoauditoria %s iguais; auditoria independente com %s achados (seção 5).", aa, n_aud),
  if (!grepl("^sim, nas 26$", cont_ii)) "- **Pendência para o chat:** o teste (ii) do item 2, como registrado (passo de 0,001 °C e tolerância de 1e-12), cai por resolução da grade fina nas concentrações listadas. As faltas cabem na cota teórica da grade, f″·h²/8; contra o mínimo contínuo da curva o teste passa nas 26, e com passo de 1e-5 °C também; as bases são iguais (teste (i)). Decidir entre aceitar o (i) como a pré-condição do item 1.4 da D5 ou redefinir o (ii), com g contra o mínimo contínuo ou com tolerância ≥ máx f″·h²/8 (seção 5, achado 1 da auditoria independente)." else NULL,
  "- **Implementação do teste (ii):** g com a base da busca da MRT e Δ_t com a base que a `attrdl` reconstrói, para que o teste detecte base diferente; leitura fiel da entrada 78(c), segundo o auditor independente (achado 2). Com as bases iguais, as duas leituras dão os mesmos números.",
  "- **Para o chat de métodos (D5, item 1.1 e frase de Methods):** a menor contribuição diária dentro do p1–p99 é −4,15e-05 e fica abaixo de −1e-8 em 15 das 26 concentrações, e não \"na ordem de 10⁻⁹\"; dentro do p1–p99 o AN soma −0,034, e fora, −38,70 (0,15% do AN total). Sugestão do auditor: qualificar \"non-negative by construction\" com \"up to the 0.1 °C resolution of the MRT search grid\", ou dar a magnitude no suplemento (seção 5, achado 4).",
  "- **Sem push e sem tag:** esta RESPOSTA vai para o chat antes.", "",
  "## 2. Testes sintéticos (`49_testes_posthoc_af.R`)", "",
  com_titulo(L$t, "^## O que cada teste confere"), com_titulo(L$t, "^## Resultado:"), com_titulo(L$t, "^## Defeitos plantados"),
  "## 3. Resultados (`50_posthoc_af.R`)", "",
  L$ph[grep("^- \\*\\*Rótulo", L$ph)[1]:(grep("^## Testes do item 2", L$ph)[1] - 1)],
  com_titulo(L$ph, "^## Testes do item 2"), com_titulo(L$ph, "^## P1"), com_titulo(L$ph, "^## P2"),
  "## 4. Texto obrigatório e decisão de relato (D5, item 2)", "",
  "O texto de Methods, Results, Limitations e Supplementary Methods está na D5 (itens 2 e 4) e entra na redação (Fase 6). Para o Limitations e o Results, os números desta Parte D são: o resultado da P1 (seção 3) e se a AF observada passa o p97,5 da referência nula (seção 3). A AF fica fora da conclusão do Abstract.", "",
  "## 5. Dupla auditoria", "",
  "### Autoauditoria (`51_autoauditoria_fase3D.R`)", "",
  grep("^- \\*\\*(Método|Código diferente|Tolerâncias)", L$aa, value = TRUE), "", com_titulo(L$aa, "^## Resultado:", 1),
  "### Registro da dupla auditoria", "", sprintf("Transcrito de `logs/%s`.", basename(f_log[["aud"]])), "", sub("^(#+) ", "\\1# ", L$aud[-1]), "",
  "## 6. Entradas do log desta parte", "",
  "As entradas 78 (registro da D5, não é desvio) e 79 (escolhas de implementação) foram registradas em commits próprios antes de rodar.", "",
  cab_dev, linha_dev(78), linha_dev(79), "",
  "## 7. Comandos, ambiente e SHA-256", "",
  "Da pasta `artigo1_prematuridade/`, com o `renv` do artigo (R 4.5.1), nesta ordem. Cada script tem trava contra sobrescrita.", "",
  "```", sprintf("FASE3_DATA=%s Rscript 00_scripts/%s.R", hoje, c("49_testes_posthoc_af", "50_posthoc_af", "51_autoauditoria_fase3D", "52_resposta_fase3D")), "```", "",
  "**`versao()` no início e no fim de cada script:**", "",
  "| Log | Script | Início | Fim |", "|---|---|---|---|", sprintf("| %s | `%s` | %s | %s |", ver$Log, ver$Script, ver$Inicio, ver$Fim),
  "| (este retorno) | `00_scripts/52_resposta_fase3D.R` | 4443971b | 4443971b (conferido no fim do script) |", "",
  "**SHA-256 do código, dos scripts e das saídas** (saídas fora do git, em `01_saidas/fase3/`, conferidas contra o log do 50):", "", tab_arq, "",
  "## 8. `git status`", "",
  "Saída de `git status --porcelain --untracked-files=all`, antes de gravar este retorno e antes do commit local da Parte D. Arquivos de outras sessões, se houver, só são mostrados:", "",
  "```", if (length(gst)) gst else "(limpo)", "```", "", "`git log --oneline -4`:", "", "```", glg, "```", "",
  "Commit local da Parte D. **Sem push e sem tag:** a RESPOSTA vai para o chat do Artigo 1 antes; a tag `posthoc_af-v1.0` só depois da aprovação, no commit que rodou.")

narr <- md[seq_len(grep("^## 2\\. Testes sintéticos", md)[1] - 1)]
toks <- unique(unlist(regmatches(narr, gregexpr("[0-9]+ de [0-9]+|[0-9]+/[0-9]+|-?[0-9][0-9.]*,[0-9]+|-?[0-9]\\.[0-9]+e[-+][0-9]+", narr))))
todos <- paste(unlist(L), collapse = "\n")
esc <- function(t) gsub("([.\\\\|()\\[\\]{}^$*+?])", "\\\\\\1", t, perl = TRUE)
fora <- toks[!vapply(toks, function(t) grepl(paste0("(?<![0-9.,])", esc(t), "(?![0-9]|,[0-9])"), todos, perl = TRUE), logical(1))]
if (length(fora)) stop("números da narrativa sem origem nos logs: ", paste(fora, collapse = ", "))
stopifnot(versao() == "4443971b")
writeLines(md, out, useBytes = TRUE)
cat("gravado:", out, "| números da narrativa conferidos:", length(toks), "| SHA-256:", sha(out), "\n")
