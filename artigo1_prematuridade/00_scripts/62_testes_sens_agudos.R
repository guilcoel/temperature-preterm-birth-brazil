# 62_testes_sens_agudos.R — Fase 4, Parte A: testes e mutantes da sens_agudos v1.0 (uma etapa, S3 penalizado,
# mapeamento °C ↔ percentil, meta univariada, nula da PACF ponderada, médias em janela e temperatura aparente), só com
# dado sintético (mensagem da Parte A do chat do Artigo 1, 16/10/2026, seção 2; D11, 5.2 e 5.3; D13, item 3; D16,
# item 2; mensagem de respostas ao plano, P3, P11 e m6). Não toca a base: nenhum nascimentos(), série real ou RDS.
# Roda:
#   - a bateria testa_sens_agudos.R (inclui a conferência dos quatro pontos do mgcv 1.9-3, P11);
#   - mutantes em cópias da sens_agudos.R (morto = algum teste que passa no original cai; erro × critério no log);
#   - medida de tempo, no tamanho real com dado sintético: um gam da S3 com 4.498 + 7 dias e a uma etapa com 26
#     unidades de 4.498 + 7 dias, para rever a estimativa de tempo da C4.
# Confere antes: este script, o código e os testes commitados e limpos; BLAS e LAPACK de referência; locale UTF-8
# (auditoria do chat de 18/10, M1). Semente 20261001.
# Grava logs/testes_sens_agudos_fase4_<RODADA>.md. Nunca sobrescreve. Numa falha, quit(status = 1).
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/62_testes_sens_agudos.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
if (!isTRUE(l10n_info()[["UTF-8"]])) stop("locale não UTF-8: a conferência de sigilo do log não vale fora dele (auditoria do chat de 18/10, M1)")
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("testes_sens_agudos_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/62_testes_sens_agudos.R"
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")

# ------------------------------------------------------------------ conferências e cabeçalho (protocolo v1.1, 3.8)
s_info <- sessionInfo()
if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib")) stop("BLAS/LAPACK fora da referência (§8)")
COD <- c(aj = "codigo_compartilhado/R/ajusta_dlnm.R", se = "codigo_compartilhado/R/segunda_etapa.R", sa = "codigo_compartilhado/R/sens_agudos.R")
TST <- c(run = "codigo_compartilhado/tests/roda_testes_fase4.R", ger = "codigo_compartilhado/tests/gera_sintetico.R", t_sa = "codigo_compartilhado/tests/testa_sens_agudos.R")
sujos <- git("status", "--porcelain", "--", ESTE, COD, TST)
if (length(sujos)) { cat(sujos, sep = "\n"); stop("script, código ou testes com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current")
st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:")   # system2 não cita argumentos (lição do 55)
stopifnot(length(head_c) == 1L, length(ramo) == 1L, length(coord) == 1L)
inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta); library(mgcv) })
sha_cod <- vapply(file.path(REPO, c(COD, TST, ESTE)), sha, ""); names(sha_cod) <- c(COD, TST, ESTE)

# ------------------------------------------------------------------ ambiente de teste e bateria
.REF <- new.env(); for (k in names(TST)) source(file.path(REPO, TST[[k]]))
texto <- lapply(COD, function(a) paste0(paste(readLines(file.path(REPO, a), encoding = "UTF-8"), collapse = "\n"), "\n"))
carrega <- function(troca = NULL) {
  e <- new.env()
  for (k in names(COD)) sys.source(if (!is.null(troca) && identical(troca$alvo, k)) troca$arquivo else file.path(REPO, COD[[k]]), envir = e)
  .REF$repo <- REPO   # o tsa_log_sigilo lê logs reais (controle positivo da AF e o 45); o tsa_log_sigilo_locale roda a cópia em teste num subprocesso
  .REF$caminho_sa <- if (!is.null(troca) && identical(troca$alvo, "sa")) troca$arquivo else file.path(REPO, COD[["sa"]])
  sys.source(file.path(REPO, TST[["ger"]]), envir = e); e
}
bateria <- function(f) cbind(arquivo = "testa_sens_agudos.R", roda_testes_fase4(f, testes_sens_agudos))
log_msg("bateria no original"); t0 <- Sys.time(); f0 <- carrega(); r0 <- bateria(f0); t_bat <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
print(r0[, c("teste", "ok", "tipo")], row.names = FALSE)
mg <- f0$confere_mgcv()

# ------------------------------------------------------------------ mutantes
mutantes <- list(
  list("percentil com rule = 1 (NA no aquecimento fora do range)", list(c("xout = tmean, rule = 2, ties = mean)$y", "xout = tmean, rule = 1, ties = mean)$y"))),
  list("uma etapa sem group (lags atravessam as unidades)", list(c("argvar = av, arglag = arglag, group = u_ch)", "argvar = av, arglag = arglag, group = NULL)"))),
  list("uma etapa com um γ comum, e não um por unidade", list(c("md$gama <- G", "md$gama <- matrix(rowSums(G), ncol = 1)"))),
  list("curva da uma etapa sem a regra de borda (D13, item 3)", list(c("if (fronteira) { j <- which(rr$rotulo == lado_borda)", "if (FALSE) { j <- which(rr$rotulo == lado_borda)"))),
  list("bootstrap da uma etapa com semente de concentração (semeia(1))", list(c("semeia(0); sims <- cf + t(R)", "semeia(1); sims <- cf + t(R)"))),
  list("S3 sem casar o crosspred por predvar (at fora de ordem)", list(c("ia <- match(at, cp$predvar)", "ia <- seq_along(at)"))),
  list("meta univariada por ML, e não REML", list(c("ajusta(fml, S = as.numeric(v), data = md, method = \"reml\")", "ajusta(fml, S = as.numeric(v), data = md, method = \"ml\")"))),
  list("projeção sem os pesos (MQO)", list(c("qx <- qr(sqrt(W) * X)", "qx <- qr(X)"))),
  list("nula da PACF com a semente da curva combinada (sem + i)", list(c("semeia(i); E <- matrix(stats::rnorm(n * R), n, R)", "semeia(0); E <- matrix(stats::rnorm(n * R), n, R)"))),
  list("nula da PACF sem os estratos no desenho", list(c("if (!is.null(matriz$estrato)) X <- cbind(", "if (FALSE) X <- cbind("))),
  list("média em janela com lag no lugar de lead", list(c("i <- seq_len(n) + o;", "i <- seq_len(n) - o;"))),
  list("temperatura aparente com Td no lugar de Td²", list(c("-2.653 + 0.994 * tmean + 0.0153 * td^2", "-2.653 + 0.994 * tmean + 0.0153 * td"))),
  # da auditoria independente da Parte A (achados 1, 2, 4 e 6) e dos itens C e m3 da mensagem de respostas ao plano
  list("S3 com poisson (auditoria, achado 2)", list(c("family = stats::quasipoisson, method = \"REML\", data = md)", "family = stats::poisson, method = \"REML\", data = md)"))),
  list("S3 com GCV, e não REML (auditoria, achado 2)", list(c("family = stats::quasipoisson, method = \"REML\", data = md)", "family = stats::quasipoisson, method = \"GCV.Cp\", data = md)"))),
  list("S3 sem os estratos (auditoria, achado 2)", list(c("xt = list(bs = \\\"ps\\\")) + est +\",", "xt = list(bs = \\\"ps\\\")) +\","))),
  list("S3 sem remover os estratos vazios (auditoria, achado 2)", list(c("vazios <- names(ev)[ev == 0]\n  usar <- ok & !(est %in% vazios)\n  md <- data.frame(y = dados[[desfecho]][usar], est = factor(est[usar]), log_w", "vazios <- character(0)\n  usar <- ok & !(est %in% vazios)\n  md <- data.frame(y = dados[[desfecho]][usar], est = factor(est[usar]), log_w"))),
  list("S3 sem log_w (auditoria, achado 2)", list(c("paste(c(covariaveis, \"log_w\"), collapse = \" + \")", "paste(covariaveis, collapse = \" + \")"))),
  list("uma etapa sem remover os estratos vazios (auditoria, achado 6)", list(c("vazios <- names(ev)[ev == 0]\n  usar <- ok & !(est %in% vazios)\n  out$n <- list(dias_usados", "vazios <- character(0)\n  usar <- ok & !(est %in% vazios)\n  out$n <- list(dias_usados"))),
  list("meta univariada sem o total (auditoria, achado 1)", list(c("total = if (inherits(fit0, \"error\")) NULL else qi2(fit0)))", "total = NULL))"))),
  list("PACF da grade com NA fora, e não 0 (auditoria, achado 4)", list(c("v <- numeric(n_grade); v[pos] <- r", "v <- rep(NA_real_, n_grade); v[pos] <- r"))),
  list("posto sem as colunas dos estratos (m3)", list(c("X <- .desenho_bruto(matriz); p <- qr(X)$rank", "X <- matriz$X; p <- qr(X)$rank"))),
  list("filtro sem os cabeçalhos literais (achado C)", list(c("if (any(vapply(.PADROES_BLUP, function(p) any(grepl(p, md, ignore.case = TRUE)), TRUE))) falhas", "if (FALSE) falhas"))),
  list("gravador sem a conferência (achado C)", list(c("confere_log_sigilo(md); writeLines(md, arq", "writeLines(md, arq"))),
  list("máscara <10 sem o 9", list(c("ifelse(n >= 1 & n <= 9, \"<10\"", "ifelse(n >= 1 & n < 9, \"<10\""))),
  # da auditoria do chat de 18/10 (M1, N1, N4 e N5) e da calibração do filtro
  list("filtro sem a checagem de locale (chat, M1)", list(c("if (!isTRUE(l10n_info()[[\"UTF-8\"]])) stop(\"confere_log_sigilo: locale", "if (FALSE) stop(\"confere_log_sigilo: locale"))),
  list("filtro sem BLUP e coef na mesma linha (chat, M1)", list(c("if (any((bc & titulo) | cel)) falhas", "if (FALSE) falhas"))),
  list("filtro sem o cabeçalho b1…b9 (chat, M1)", list(c("if (any(nb >= 2L)) falhas", "if (FALSE) falhas"))),
  list("filtro sem a notação científica (chat, M1)", list(c("if (any(nsci >= 3L)) falhas", "if (FALSE) falhas"))),
  list("filtro sem partir o texto em linhas", list(c("md <- unlist(strsplit(as.character(md), \"\\n\", fixed = TRUE));", "md <- as.character(md);"))),
  list("filtro sem a calibração da prosa (toda linha vale como título)", list(c("titulo <- !tab & (", "titulo <- TRUE | ("))),
  list("filtro sem a isenção das colunas de diagnóstico (falso positivo na AF)", list(c("if (k >= 3L && !is.null(isen)", "if (FALSE && k >= 3L && !is.null(isen)"))),
  list("isenção de diagnóstico sem a lista de nunca isentos", list(c("isen <- grepl(.CAB_DIAGNOSTICO, cab) & !grepl(.CAB_NUNCA_ISENTO, cab)", "isen <- grepl(.CAB_DIAGNOSTICO, cab)"))),
  list("isenção de diagnóstico sem conferir o número de células", list(c(" && length(ns) == length(isen)) ns <- ns[!isen]", ") ns <- ns[!isen]"))),
  list("tabela_log sem a lista branca (chat, M1)", list(c("fora <- setdiff(nm, permitidas); if (length(fora)) stop(", "fora <- setdiff(nm, permitidas); if (FALSE) stop("))),
  list("tabela_log sem os nomes proibidos (chat, M1)", list(c("if (length(proib)) stop(", "if (FALSE) stop("))),
  list("tabela_log sem exigir contagem mascarada (chat, M1)", list(c("if (length(cont) && !all(", "if (FALSE && !all("))),
  list("tabela_log aceita coluna-lista (chat, M1)", list(c("if (any(vapply(df, function(v) is.list(v) || is.matrix(v), TRUE))) stop(", "if (FALSE) stop("))),
  list("tabela_log sem a conferência de conteúdo dos rótulos (chat, M1)", list(c("  confere_log_sigilo(linhas)\n  linhas", "  linhas"))),
  list("confere_mgcv sem restaurar o .Random.seed (chat, N4)", list(c("on.exit(if (is.null(rng0))", "if (FALSE) on.exit(if (is.null(rng0))"))),
  list("desenho_completo sem tirar as colunas dependentes (chat, N5)", list(c("if (length(rem)) X <- X[, sort(", "if (FALSE) X <- X[, sort("))),
  list("percentil pelo quantil tipo 8 (chat, N1)", list(c("q <- stats::quantile(tmean_ref, probs = seq(0, 1, 0.001), type = 7, names = FALSE)", "q <- stats::quantile(tmean_ref, probs = seq(0, 1, 0.001), type = 8, names = FALSE)")))
)
res_mut <- do.call(rbind, lapply(mutantes, function(m) {
  src <- texto[["sa"]]
  for (tr in m[[2]]) { if (lengths(regmatches(src, gregexpr(tr[1], src, fixed = TRUE))) != 1) stop("texto do mutante sem exatamente uma ocorrência: ", m[[1]]); src <- sub(tr[1], tr[2], src, fixed = TRUE) }
  tf <- tempfile(fileext = ".R"); writeLines(src, tf, useBytes = TRUE)
  log_msg("mutante:", m[[1]]); rr <- bateria(carrega(list(alvo = "sa", arquivo = tf))); unlink(tf)
  stopifnot(identical(rr$teste, r0$teste)); caem <- !rr$ok & r0$ok
  tipos <- table(factor(rr$tipo[caem], levels = c("critério", "erro")))
  data.frame(Mutante = m[[1]], `Testes que caem` = sum(caem), `Por critério` = tipos[["critério"]], `Por erro` = tipos[["erro"]],
             Quais = if (any(caem)) paste(rr$teste[caem], collapse = ", ") else "nenhum", check.names = FALSE, stringsAsFactors = FALSE) }))

# ------------------------------------------------------------------ tempo no tamanho real (dado sintético)
log_msg("tempo: S3 com 4.505 dias")
set.seed(20261001, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
bf <- f0$base_fixa(20000); d <- f0$gera_sintetico(n_dias = 4498, eventos_dia = 30, efeito = "dobradica", bf = bf); d$tmean <- d$temp
at <- unname(stats::quantile(d$temp, c(0.99, 0.01), type = 7)); cen <- unname(stats::median(d$temp))
t0 <- Sys.time(); rs3 <- f0$ajusta_s3(d, at = at, cen = cen); t_s3 <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
log_msg("tempo: uma etapa com 26 unidades de 4.505 dias")
lst <- lapply(1:26, function(u) { x <- f0$gera_sintetico(n_dias = 4498, eventos_dia = 30, gamma = 1.2, efeito = "dobradica", bf = bf, unidade = sprintf("c%02d", u)); x$tmean <- x$temp + (u - 13) / 4; x })
du <- do.call(rbind, lst); du$unidade <- rep(sprintf("c%02d", 1:26), each = 4505); ref <- setNames(lapply(lst, `[[`, "tmean"), sprintf("c%02d", 1:26))
t0 <- Sys.time(); rue <- f0$uma_etapa(du, ref, list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE)); t_ue <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
ok <- all(r0$ok) && all(res_mut[["Testes que caem"]] >= 1) && identical(rs3$status, "ok") && identical(rue$status, "ok")
if (!identical(unname(vapply(file.path(REPO, COD), sha, "")), unname(sha_cod[COD]))) stop("código mudou durante a rodada")

# ------------------------------------------------------------------ log
md <- c("# Fase 4, Parte A: sens_agudos v1.0 — testes, mutantes, mgcv 1.9-3 e tempo (só dado sintético)", "",
  sprintf("- **Gerado por:** `00_scripts/62_testes_sens_agudos.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`.", sha_cod[[ESTE]], inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Ambiente:** R %s; dlnm %s; gnm %s; mixmeta %s; mgcv %s. BLAS/LAPACK: `%s` / `%s` (referência). Locale `%s` (UTF-8, conferido no início). Semente 20261001 (Mersenne-Twister, Inversion, Rejection). Não toca a base.",
          paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("gnm"), packageVersion("mixmeta"), packageVersion("mgcv"), s_info$BLAS, s_info$LAPACK, Sys.getlocale("LC_CTYPE")),
  "- **Código e testes (SHA-256; todos commitados e limpos antes de rodar):**", sprintf("  - `%s`: `%s`;", names(sha_cod), sha_cod), "",
  sprintf("## Resultado: %d/%d testes (%.0f s)", sum(r0$ok), nrow(r0), t_bat), "",
  tabela_md(data.frame(Teste = paste0("`", r0$teste, "`"), Resultado = ifelse(r0$ok, "passou", paste0("FALHOU (", r0$tipo, "): ", r0$mensagem)), check.names = FALSE)), "",
  "## mgcv instalado: os quatro pontos da P11 (D11, 5.2)", "",
  tabela_md(data.frame(Ponto = c("versão", "m padrão do ps = c(2, 2) (cúbica, penalidade de 2ª ordem)", "k maior que o número de valores únicos: só aviso",
                                 "vcov.gam devolve Vp (identical com unname)", "dimensão do termo cb com k = c(10, 8)"),
                       Resultado = c(mg$versao, sprintf("%s (m = %s)", mg$ps_m_padrao_2_2, paste(mg$m_ps, collapse = ", ")), sprintf("%s (aviso: \"%s\")", mg$k_so_aviso, mg$aviso_k),
                                     as.character(mg$vcov_igual_Vp), sprintf("%d (= 72: %s)", mg$dim_cb, mg$dim_cb_72)), check.names = FALSE)), "",
  "## Mutantes (cada um numa cópia da `sens_agudos.R`; a bateria inteira roda em cada cópia)", "",
  tabela_md(res_mut), "",
  "## Tempo no tamanho real (dado sintético; Mac Mini, BLAS de referência)", "",
  sprintf("- **S3:** um gam (4.498 dias de ajuste + 7 de aquecimento; cerca de 149 estratos como efeito fixo; termo cb de dimensão %s): %.1f s; status %s. Nas 26 concentrações: cerca de %.0f min.", rs3$dim_s, t_s3, rs3$status, 26 * t_s3 / 60),
  sprintf("- **Uma etapa:** 26 unidades × 4.505 dias (%d linhas de ajuste; %d estratos eliminados): %.1f s; status %s.", rue$n$dias_usados, rue$n$estratos_usados, t_ue, rue$status),
  sprintf("- **Estimativa revista da C4:** S3 ~%.0f min + uma etapa e bootstrap < 1 min + efeitos fixos, multinível e os quatro exploratórios (mixmeta, segundos) ≈ %.0f–%.0f min.", 26 * t_s3 / 60, 26 * t_s3 / 60 + 2, 2 * (26 * t_s3 / 60) + 5), "",
  sprintf("- **Resultado:** %s.", if (ok) sprintf("todos os testes passam no original, os %d mutantes são mortos e as duas medidas de tempo terminaram com status ok", nrow(res_mut)) else "FALHA: ver as tabelas"), "")
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| testes:", sum(r0$ok), "/", nrow(r0), "| mutantes mortos:", sum(res_mut[["Testes que caem"]] >= 1), "/", nrow(res_mut), "| S3", round(t_s3, 1), "s | uma etapa", round(t_ue, 1), "s | ok:", ok, "\n")
if (!ok) quit(status = 1)
