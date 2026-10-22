# 60_testes_ajusta_offset_v11.R — Fase 4, Parte A: testes e mutantes da ajusta_dlnm v1.1 e da offset v1.1, só com
# dado sintético (mensagem da Parte A do chat do Artigo 1, 16/10/2026, seção 2; plano da Fase 4, seção 3, Parte A;
# entradas A1-97 e A1-99). Não toca a base: nenhum nascimentos(), série real ou RDS da Fase 2 ou 3.
# Roda:
#   - regressão: a v1.0 das duas funções lida da tag ajusta_dlnm-v1.0 por git show (testes tv11_regressao_v10 e
#     to11_regressao_v10);
#   - baterias: testa_ajusta_dlnm.R (rápidos da Fase 2), testa_ajusta_dlnm_d1_errata.R (a85c388, entram na v1.1),
#     testa_offset.R (Fase 1), testa_ajusta_dlnm_v11.R e testa_offset_v11.R (com a calibração da regra_gama, A1-97(d));
#     fora: o Monte Carlo de testa_ajusta_dlnm_mc.R (1.000 réplicas, sem mudança na v1.1);
#   - mutantes: cada um numa cópia do arquivo de código em tempdir() (nunca no arquivo); a bateria inteira roda em cada
#     cópia; morto = algum teste que passa no original cai. O log separa erro (o código quebrou) de critério (o teste
#     reprovou), pelo executor roda_testes_fase4.R (Nota 3 da auditoria de 15/10).
# Confere antes: este script, o código e os testes commitados e limpos; BLAS e LAPACK de referência; locale UTF-8
# (auditoria do chat de 18/10, M1). Semente 20261001.
# Grava logs/testes_ajusta_offset_v11_fase4_<RODADA>.md. Nunca sobrescreve. Numa falha, quit(status = 1).
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/60_testes_ajusta_offset_v11.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
if (!isTRUE(l10n_info()[["UTF-8"]])) stop("locale não UTF-8: a conferência de sigilo do log não vale fora dele (auditoria do chat de 18/10, M1)")
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("testes_ajusta_offset_v11_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/60_testes_ajusta_offset_v11.R"
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
de_tag <- function(tag, a) { tf <- tempfile(fileext = ".R"); writeLines(git("show", paste0(tag, ":", a)), tf, useBytes = TRUE); tf }

# ------------------------------------------------------------------ conferências e cabeçalho (protocolo v1.1, 3.8)
s_info <- sessionInfo()
if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib")) stop("BLAS/LAPACK fora da referência (§8)")
COD <- c(aj = "codigo_compartilhado/R/ajusta_dlnm.R", of = "codigo_compartilhado/R/offset.R")
TST <- c(run = "codigo_compartilhado/tests/roda_testes_fase4.R", ger = "codigo_compartilhado/tests/gera_sintetico.R",
         t_aj = "codigo_compartilhado/tests/testa_ajusta_dlnm.R", t_d1 = "codigo_compartilhado/tests/testa_ajusta_dlnm_d1_errata.R",
         t_of = "codigo_compartilhado/tests/testa_offset.R", t_aj11 = "codigo_compartilhado/tests/testa_ajusta_dlnm_v11.R",
         t_of11 = "codigo_compartilhado/tests/testa_offset_v11.R")
sujos <- git("status", "--porcelain", "--", ESTE, COD, TST)
if (length(sujos)) { cat(sujos, sep = "\n"); stop("script, código ou testes com mudança não commitada: não roda") }
TAG <- "ajusta_dlnm-v1.0"; if (!identical(git("rev-parse", paste0(TAG, "^{commit}")), "caf5022f9a655877d8e3931dd3d02d7dce429fe5")) stop("tag ", TAG, " fora do commit esperado")
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current")
st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:")   # system2 não cita argumentos (lição do 55)
stopifnot(length(head_c) == 1L, length(ramo) == 1L, length(coord) == 1L)
inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
suppressPackageStartupMessages({ library(dlnm); library(gnm) })
sha_cod <- vapply(file.path(REPO, c(COD, TST, ESTE)), sha, ""); names(sha_cod) <- c(COD, TST, ESTE)

# ------------------------------------------------------------------ ambiente de teste e baterias
.REF <- new.env(); .REF$a10 <- new.env(); .REF$o10 <- new.env()
sys.source(de_tag(TAG, COD[["aj"]]), envir = .REF$a10); sys.source(de_tag(TAG, COD[["of"]]), envir = .REF$o10)
for (k in names(TST)) source(file.path(REPO, TST[[k]]))
texto <- lapply(COD, function(a) paste0(paste(readLines(file.path(REPO, a), encoding = "UTF-8"), collapse = "\n"), "\n"))
carrega <- function(troca = NULL) {
  e <- new.env()
  for (k in names(COD)) sys.source(if (!is.null(troca) && identical(troca$alvo, k)) troca$arquivo else file.path(REPO, COD[[k]]), envir = e)
  sys.source(file.path(REPO, TST[["ger"]]), envir = e); e
}
bateria <- function(f) rbind(cbind(arquivo = "testa_ajusta_dlnm.R", roda_testes_fase4(f, testes_ajusta_dlnm)),
                             cbind(arquivo = "testa_ajusta_dlnm_d1_errata.R", roda_testes_fase4(f, testes_ajusta_dlnm_d1_errata)),
                             cbind(arquivo = "testa_offset.R", roda_testes_fase4(f, testes_offset)),
                             cbind(arquivo = "testa_ajusta_dlnm_v11.R", roda_testes_fase4(f, testes_ajusta_dlnm_v11)),
                             cbind(arquivo = "testa_offset_v11.R", roda_testes_fase4(f, testes_offset_v11)))
log_msg("bateria no original"); t0 <- Sys.time(); r0 <- bateria(carrega()); t_bat <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
print(r0[, c("arquivo", "teste", "ok", "tipo")], row.names = FALSE)
calib <- .REF$calibracao; glm_w_mu <- .REF$glm_w_mu

# ------------------------------------------------------------------ mutantes (cópias em tempdir())
mutantes <- list(
  list("resíduo de Pearson no lugar do de deviance", "aj", list(c("rd0[usar] <- stats::residuals(m, type = \"deviance\"); rd0 }", "rd0[usar] <- stats::residuals(m, type = \"pearson\"); rd0 }"))),
  list("glm não condicional com poisson (φ fixo em 1)", "aj", list(c("else stats::glm(form, family = stats::quasipoisson, data = md, offset = off)", "else stats::glm(form, family = stats::poisson, data = md, offset = off)"))),
  list("coluna-matriz tratada como vetor", "aj", list(c("md[[k]] <- if (is.matrix(dados[[k]]))", "md[[k]] <- if (FALSE)"))),
  list("eventos removidos contando a janela inteira", "aj", list(c("sum(dados[[spec$desfecho]][dados[[spec$janela]] %in% TRUE & !usar], na.rm = TRUE)", "sum(dados[[spec$desfecho]][dados[[spec$janela]] %in% TRUE], na.rm = TRUE)"))),
  list("pesos a priori no lugar dos de trabalho", "aj", list(c("stats::weights(m, type = \"working\")", "stats::weights(m, type = \"prior\")"))),
  list("sem estratos, os dias sem evento saem do ajuste (D16)", "aj", list(c("else rep(\"1\", nrow(dados))", "else as.character(seq_len(nrow(dados)))"),
                                                                           c("vazios <- if (condicional) names(ev)[ev == 0] else character(0)", "vazios <- names(ev)[ev == 0]"))),
  list("EP de γ calculado com γ NA (sem o ramo NA)", "aj", list(c("if (is.na(out$gama)) out$ep_gama <- NA_real_ else {", "if (FALSE) out$ep_gama <- NA_real_ else {"))),
  list("ns(tempo) calculado com o aquecimento (D16)", "aj", list(c("bt <- splines::ns(as.numeric(dados$data[usar]), df = spec$tempo_gl)", "bt <- splines::ns(as.numeric(dados$data), df = spec$tempo_gl)[usar, , drop = FALSE]"))),
  list("w_j por ano de nascimento, e não de entrada (D12, 4.2)", "of", list(c("ano <- as.integer(format(inicio[entra] + 7L * j, \"%Y\"))", "ano <- as.integer(format(inicio[entra] + 7L * ig[entra] + 3L, \"%Y\"))"))),
  list("pessoa-dia com 3 dias no lugar de 4", "of", list(c("PD_j <- 7 * (N_j - n_j) + 4 * n_j", "PD_j <- 7 * (N_j - n_j) + 3 * n_j"))),
  list("w_j aplicado pelo ano de entrada da gestação, e não pelo ano de t", "of", list(c("wk <- unname(wv[paste(as.integer(format(z_tj$data[dentro], \"%Y\")), as.integer(z_tj$semana[dentro]))])",
                                                                                         "wk <- unname(wv[paste(as.integer(format(z_tj$data[dentro] - 7L * as.integer(z_tj$semana[dentro]), \"%Y\")), as.integer(z_tj$semana[dentro]))])"))),
  list("par (ano, j) sem w não sai da soma (NA propaga)", "of", list(c("n_sem_w <- sum(is.na(wk) & z_tj$z[dentro] > 0); wk[is.na(wk)] <- 0", "n_sem_w <- sum(is.na(wk) & z_tj$z[dentro] > 0)"))),
  list("regra de γ com DP no lugar de DP² (controle negativo da calibração)", "of", list(c("ep = 1 / sqrt(eventos * dp^2)", "ep = 1 / sqrt(eventos * dp)"))),
  list("regra de γ com a gestação do término presente 7 dias, e não 4", "of", list(c("(Sj1[k] + pj[k] * (d <= 3))", "(Sj1[k] + pj[k] * (d <= 6))"))),
  # da auditoria independente da Parte A (achados 3 e 5; Notas 4 e 9)
  list("w_j por ano de s + 7j + 3 (auditoria, achado 3)", "of", list(c("ano <- as.integer(format(inicio[entra] + 7L * j, \"%Y\"))", "ano <- as.integer(format(inicio[entra] + 7L * j + 3L, \"%Y\"))"))),
  list("w_j por ano de s (auditoria, achado 3)", "of", list(c("ano <- as.integer(format(inicio[entra] + 7L * j, \"%Y\"))", "ano <- as.integer(format(inicio[entra], \"%Y\"))"))),
  list("w por ano sem a guarda de semana sem w em nenhum ano (auditoria, achado 5)", "of", list(c("if (length(sem_w)) stop(\"monta_offset: semana(s) sem w_j em nenhum ano: \"", "if (FALSE) stop(\"monta_offset: semana(s) sem w_j em nenhum ano: \""))),
  list("termos_sem_w contando células com z = 0 (auditoria, Nota 4)", "of", list(c("n_sem_w <- sum(is.na(wk) & z_tj$z[dentro] > 0)", "n_sem_w <- sum(is.na(wk))"))),
  list("regra de γ sem a guarda da semana 42 (auditoria, Nota 9)", "of", list(c("if (max(sem_dist) < 42L) stop(", "if (FALSE) stop(")))
)
res_mut <- do.call(rbind, lapply(mutantes, function(m) {
  src <- texto[[m[[2]]]]
  for (tr in m[[3]]) { if (lengths(regmatches(src, gregexpr(tr[1], src, fixed = TRUE))) != 1) stop("texto do mutante sem exatamente uma ocorrência: ", m[[1]]); src <- sub(tr[1], tr[2], src, fixed = TRUE) }
  tf <- tempfile(fileext = ".R"); writeLines(src, tf, useBytes = TRUE)
  log_msg("mutante:", m[[1]]); rr <- bateria(carrega(list(alvo = m[[2]], arquivo = tf))); unlink(tf)
  stopifnot(identical(rr$teste, r0$teste)); caem <- !rr$ok & r0$ok
  tipos <- table(factor(rr$tipo[caem], levels = c("critério", "erro")))
  data.frame(Mutante = m[[1]], Arquivo = basename(COD[[m[[2]]]]), `Testes que caem` = sum(caem), `Por critério` = tipos[["critério"]], `Por erro` = tipos[["erro"]],
             Quais = if (any(caem)) paste(rr$teste[caem], collapse = ", ") else "nenhum", check.names = FALSE, stringsAsFactors = FALSE) }))
if (!identical(unname(vapply(file.path(REPO, COD), sha, "")), unname(sha_cod[COD]))) stop("código mudou durante a rodada")
ok <- all(r0$ok) && all(res_mut[["Testes que caem"]] >= 1)

# ------------------------------------------------------------------ log
md <- c("# Fase 4, Parte A: ajusta_dlnm v1.1 e offset v1.1 — testes e mutantes (só dado sintético)", "",
  sprintf("- **Gerado por:** `00_scripts/60_testes_ajusta_offset_v11.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`.", sha_cod[[ESTE]], inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Ambiente:** R %s; dlnm %s; gnm %s. BLAS/LAPACK: `%s` / `%s` (referência). Locale `%s` (UTF-8, conferido no início). Semente 20261001 (Mersenne-Twister, Inversion, Rejection). Não toca a base.",
          paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("gnm"), s_info$BLAS, s_info$LAPACK, Sys.getlocale("LC_CTYPE")),
  "- **Código e testes (SHA-256; todos commitados e limpos antes de rodar):**", sprintf("  - `%s`: `%s`;", names(sha_cod), sha_cod),
  sprintf("- **Regressão:** a v1.0 lida da tag `%s` (commit `caf5022`) por `git show`; os campos da v1.0 têm de sair `identical()` na v1.1 sem os argumentos novos.", TAG),
  "- **Fora da bateria:** o Monte Carlo de `testa_ajusta_dlnm_mc.R` (1.000 réplicas), sem mudança na v1.1.", "",
  sprintf("## Resultado: %d/%d testes (%.0f s)", sum(r0$ok), nrow(r0), t_bat), "",
  tabela_md(data.frame(Arquivo = paste0("`", r0$arquivo, "`"), Teste = paste0("`", r0$teste, "`"), Resultado = ifelse(r0$ok, "passou", paste0("FALHOU (", r0$tipo, "): ", r0$mensagem)), check.names = FALSE)), "",
  "## Calibração da regra_gama (A1-97(d))", "",
  "- Insumos fixos: distribuição de IG da Q8 (`RESPOSTA_QUESTIONAMENTO_20261007.md` da base, SHA-256 `16fe31e9…011e`) e os totais de eventos (PTB 22–36 = 1.405.697; termo precoce 37–38 = 4.307.836). Tolerância relativa de 10%.", "",
  if (!is.null(calib)) tabela_md(data.frame(Caso = calib$caso, Obtido = sprintf("%.4f", calib$obtido), Publicado = sprintf("%.2f", calib$publicado), `Diferença relativa` = sprintf("%+.2f%%", 100 * calib$dif_rel), check.names = FALSE)) else "- (calibração não rodou)", "",
  "- Controle: o mutante com DP no lugar de DP² tem de cair na calibração (tabela de mutantes). Teste de escala, que não é controle negativo (auditoria do chat de 18/10, N3): com os eventos × 4, o EP cai exatamente pela metade (`identical`, `to11_regra_gama_eventos4`).", "",
  "## Observação: pesos de trabalho no glm", "",
  sprintf("- Sem estratos (glm), max|W − μ̂|/μ̂ = %s: o glm guarda os pesos de trabalho da penúltima iteração do IRLS. O teste W = μ̂ < 1e-8 da D16, item 2, é do modelo condicional (gnm), o da nula da PACF, onde passa (`tv11_devolve_matriz`).", if (is.null(glm_w_mu)) "—" else format(glm_w_mu, digits = 3)), "",
  "## Mutantes (cada um numa cópia do arquivo de código; a bateria inteira roda em cada cópia)", "",
  tabela_md(res_mut), "",
  sprintf("- **Resultado:** %s.", if (ok) sprintf("todos os testes passam no original, e os %d mutantes são mortos", nrow(res_mut)) else "FALHA: ver as tabelas"), "")
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| testes:", sum(r0$ok), "/", nrow(r0), "| mutantes mortos:", sum(res_mut[["Testes que caem"]] >= 1), "/", nrow(res_mut), "| ok:", ok, "\n")
if (!ok) quit(status = 1)
