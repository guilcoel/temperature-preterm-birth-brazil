# 41_testes_segunda_etapa.R — Fase 3, A2: testes da segunda etapa (codigo_compartilhado/R/segunda_etapa.R) e defeitos
# plantados. Prompt da Fase 3 v1.1 (A2) e complemento de 13/10 (desvios 71 a 73).
# - Testes rápidos: codigo_compartilhado/tests/testa_segunda_etapa.R (1–4 e 6–11 do prompt, mais os do complemento).
# - Monte Carlo: codigo_compartilhado/tests/testa_segunda_etapa_mc.R (teste 5; 1.000 réplicas).
# - Dados reais usados SÓ como atributos da base (argvar e arglag da Fase 2), exposição (tmean_nucleo das 4.505 linhas),
#   percentis (A0), nós do CSV, metapreditores (média e amplitude) e as vcov reduzidas da Fase 2 como covariâncias de
#   coeficientes sintéticos (desvio 72d). Nenhum coeficiente real, RR ou curva com o desfecho real.
# - Defeitos: cada um numa cópia de segunda_etapa.R. Os testes rápidos rodam em toda cópia; o teste 5 (Monte Carlo) só
#   roda quando nenhum teste rápido cai, sem a cobertura da TMR, que é só reportada (desvio 74). Um defeito conta só se
#   derrubar um teste que passa no original.
# Grava logs/testes_segunda_etapa_fase3_<FASE3_DATA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/41_testes_segunda_etapa.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("testes_segunda_etapa_fase3_", hoje, ".md")); stopifnot(!file.exists(arq))
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta) })
CC <- file.path("..", "codigo_compartilhado")
f_se <- file.path(CC, "R", "segunda_etapa.R"); f_aj <- file.path(CC, "R", "ajusta_dlnm.R")
f_tr <- file.path(CC, "tests", "testa_segunda_etapa.R"); f_tm <- file.path(CC, "tests", "testa_segunda_etapa_mc.R"); f_run <- file.path(CC, "tests", "roda_testes.R")
f_at <- file.path(CC, "inst", "terceiros", "attrdl.R"); SHA_ATTRDL <- "d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d"
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
ic <- function(v, d = 3) sprintf("[%s; %s]", br(v[1], d), br(v[2], d))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
sha_antes <- sha(f_se)

# ------------------------------------------------------------------ entradas (SHA-256 contra os logs que as geraram)
ENT <- c(rds2 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", ref = "01_saidas/fase1/referencias_exposicao.csv",
         ser1 = "01_saidas/fase1/serie_ptb_principal.rds", a0 = paste0("01_saidas/fase3/percentis_exposicao_fase3_", hoje, ".csv"))
SHA_ENT <- c(rds2 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d", ref = "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467",
             ser1 = "635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917")
sha_ent <- vapply(ENT, sha, "")
if (!identical(sha_ent[names(SHA_ENT)], SHA_ENT)) stop("entrada com SHA-256 diferente do registrado: ", paste(names(SHA_ENT)[sha_ent[names(SHA_ENT)] != SHA_ENT], collapse = ", "))
L40 <- paste(readLines(file.path("logs", paste0("percentis_exposicao_fase3_", hoje, ".md")), encoding = "UTF-8"), collapse = "\n")
if (!grepl(sha_ent[["a0"]], L40, fixed = TRUE)) stop("grade da A0 com SHA-256 diferente do log do 40")
source(f_run); source(f_tr); source(f_tm)
carrega <- function(arquivo_se) { e <- new.env(); sys.source(f_aj, envir = e); sys.source(arquivo_se, envir = e); e }
f0 <- carrega(f_se); ordem <- f0$ORDEM_CONCENTRACOES
nuc <- as.data.frame(cidade_nucleo()); f0$confere_ordem(nuc$CD_RECORTE); .R3$codigos <- nuc$CD_RECORTE
rds <- readRDS(ENT[["rds2"]])$resultados
.R3$argvar <- lapply(ordem, function(r) rds[[r]]$principal$base$argvar); .R3$arglag <- lapply(ordem, function(r) rds[[r]]$principal$base$arglag)
.R3$S <- lapply(ordem, function(r) rds[[r]]$principal$reduzida$vcov); rm(rds)                 # só as vcov reduzidas, como covariâncias
s <- readRDS(ENT[["ser1"]]); s <- s[s$data >= as.Date("2012-04-07") & s$data <= as.Date("2024-08-06"), c("recorte_principal", "data", "tmean_nucleo")]
.R3$x <- lapply(ordem, function(r) { z <- s[s$recorte_principal == r, ]; stopifnot(nrow(z) == 4505); z$tmean_nucleo[order(z$data)] }); rm(s)
gr <- utils::read.csv(ENT[["a0"]], colClasses = c(recorte_principal = "character"))
.R3$grade <- t(vapply(ordem, function(r) { z <- gr[gr$recorte_principal == r, ]; setNames(z$valor, z$rotulo) }, numeric(101)))
ez <- gr[gr$recorte_principal == "eixo_medio", ]; .R3$eixo <- setNames(ez$valor, ez$rotulo)
ref <- utils::read.csv(ENT[["ref"]], colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ordem, ref$recorte_principal), ]; stopifnot(identical(ref$recorte_principal, ordem))
.R3$nos_csv <- as.matrix(ref[, c("p10", "p75", "p90")]); .R3$metapred <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1)
.R3$attrdl_path <- f_at; .R3$attrdl <- f0$carrega_attrdl(f_at, SHA_ATTRDL); .R3$R_mc <- 1000L

# ------------------------------------------------------------------ bateria original
log_msg("bateria original: rápidos"); r_u <- roda_testes(f0, testes_segunda_etapa); T3_u <- as.list(.T3)
log_msg("bateria original: Monte Carlo (1.000 réplicas)"); .R3$relata_tmr <- TRUE; t_mc <- Sys.time()
r_m <- roda_testes(f0, testes_segunda_etapa_mc); dur_mc <- as.numeric(Sys.time() - t_mc, units = "mins"); T3_m <- as.list(.T3)
todos <- rbind(r_u, r_m); print(todos[, c("teste", "ok")], row.names = FALSE)

# ------------------------------------------------------------------ defeitos plantados (cada um numa cópia)
src <- paste0(paste(readLines(f_se, encoding = "UTF-8"), collapse = "\n"), "\n")
defeitos <- list(
  # do prompt (A2, item 11)
  list("Boundary.knots omitidos na base de predição", list(c("unclass(do.call(dlnm::onebasis, c(list(x = x), argvar)))", "unclass(do.call(dlnm::onebasis, c(list(x = x), argvar[setdiff(names(argvar), \"Boundary.knots\")])))"))),
  list("nós da base combinada pela mediana", list(c("out$knots <- colMeans(do.call(rbind, campo(\"knots\")))", "out$knots <- apply(do.call(rbind, campo(\"knots\")), 2, stats::median)"))),
  list("cen ignorado na curva", list(c("X <- sweep(B, 2, Bc[1, ])", "X <- B"))),
  list("BLUP trocado pela predição da média", list(c("out$blup <- lapply(b, function(z) list(coef = unname(z$blup), vcov = unname(z$vcov)))", "out$blup <- lapply(b, function(z) list(coef = unname(pred$fit), vcov = unname(pred$vcov)))"))),
  list("bootstrap sem a vcov (sorteios iguais ao ponto)", list(c("sims <- coef + t(R) %*% matrix(stats::rnorm(k * nsim), k)", "sims <- coef + 0 * (t(R) %*% matrix(stats::rnorm(k * nsim), k))"))),
  list("grade da TMR sem o x_sup", list(c("if (x_sup - g[length(g)] > 1e-8) g <- c(g, x_sup)", "g <- g"))),
  list("semente única para todas as concentrações", list(c("  20261001L + as.integer(i)\n}", "  20261001L\n}"))),
  list("set.seed só uma vez antes dos componentes", list(c("semeia(i); an <- attrdl(", "an <- attrdl("), c("semeia(i); sim <- attrdl(", "sim <- attrdl("), c("  res <- tryCatch({\n    lst <- lapply(", "  semeia(i)\n  res <- tryCatch({\n    lst <- lapply("))),
  list("calor e frio com o range trocado", list(c("calor = c(tmr, Inf), frio = c(-Inf, tmr)", "calor = c(-Inf, tmr), frio = c(tmr, Inf)"))),
  list("calor extremo sem o max(p97,5, TMR)", list(c("calor_extremo = c(max(p97_5, tmr), Inf)", "calor_extremo = c(p97_5, Inf)"))),
  list("denominador com os eventos do aquecimento", list(c("if (dir == \"back\" && !all(is.na(cases[seq_len(n_aquec)])))", "if (FALSE)"))),
  list("sequência de estabilidade pulando o diag", list(c("seq_est <- list(c(\"reml\", \"unstr\"), c(\"reml\", \"diag\"), c(\"ml\", \"diag\"))", "seq_est <- list(c(\"reml\", \"unstr\"), c(\"ml\", \"diag\"))"))),
  list("centro da reduz_var ignorado", list(c("type = \"var\", value = valor, cen = cen)", "type = \"var\", value = valor)"))),
  # do complemento de 13/10 (desvio 73)
  list("ordem das concentrações sem trava", list(c("if (!identical(as.character(codigos), ORDEM_CONCENTRACOES)) stop(", "if (FALSE) stop("))),
  list("grade da TMR com unique() (quase-duplicata)", list(c("  g <- seq(x_inf, x_sup, by = 0.1)\n  if (x_sup - g[length(g)] > 1e-8) g <- c(g, x_sup)", "  g <- unique(c(seq(x_inf, x_sup, by = 0.1), x_sup))"))),
  list("fronteira da TMR por == em °C", list(c("fronteira = m$fronteira, tmr_p10_p90", "fronteira = m$tmr %in% c(x_inf, x_sup), tmr_p10_p90"), c("if (m$fronteira) out$tmr_p10_p90", "if (out$fronteira) out$tmr_p10_p90"))),
  list("sem a checagem de coeficientes nulos antes do mixmeta", list(c("if (length(nulas)) stop(", "if (FALSE) stop("))),
  list("set.seed sem o kind explícito", list(c("semeia <- function(i) set.seed(semente(i), kind = \"Mersenne-Twister\", normal.kind = \"Inversion\", sample.kind = \"Rejection\")", "semeia <- function(i) set.seed(semente(i))"))),
  list("attrdl sem a checagem de datas consecutivas", list(c("if (any(diff(datas) != 1)) { out$mensagem <- \"datas não consecutivas", "if (FALSE) { out$mensagem <- \"datas não consecutivas"))),
  list("cross-basis aceitando série não consecutiva", list(c("if (any(diff(datas) != 1)) stop(\"monta_cb:", "if (FALSE) stop(\"monta_cb:"))),
  list("falha do mixmeta com !isTRUE(converged)", list(c("isFALSE(fit$converged)", "!isTRUE(fit$converged)"))),
  # da auditoria independente da Parte A (desvio 74)
  list("Q/I² residual e total trocados", list(c("out$heterogeneidade <- list(residual = qi2(fit), total = if (fit0$falhou) NULL else qi2(fit0$fit))", "out$heterogeneidade <- list(residual = if (fit0$falhou) NULL else qi2(fit0$fit), total = qi2(fit))"))),
  list("Wald do termo errado", list(c("ind <- which(sub(\"^[^.]*\\\\.\", \"\", names(stats::coef(fit))) == t)", "ind <- which(sub(\"^[^.]*\\\\.\", \"\", names(stats::coef(fit))) == rev(termos)[match(t, termos)])"))),
  list("bootstrap com a semente da curva combinada em todas as concentrações", list(c("  semeia(i)\n  sims <- coef + t(R)", "  semeia(0)\n  sims <- coef + t(R)"))),
  list("frio extremo sem o min(p2,5, TMR)", list(c("frio_extremo = c(-Inf, min(p2_5, tmr))", "frio_extremo = c(-Inf, p2_5)"))),
  list("frio extremo igual ao frio", list(c("frio_extremo = c(-Inf, min(p2_5, tmr))", "frio_extremo = c(-Inf, tmr)"))),
  list("predição no primeiro conjunto de metapreditores, e não na média", list(c("nd <- as.data.frame(t(colMeans(md[, termos, drop = FALSE])))", "nd <- md[1, termos, drop = FALSE]"))),
  list("vcov do BLUP trocada pela vcov da predição", list(c("list(coef = unname(z$blup), vcov = unname(z$vcov))", "list(coef = unname(z$blup), vcov = unname(pred$vcov))"))),
  list("IC da TMR pelos percentis 5 e 95", list(c("ic = unname(stats::quantile(tmr, c(0.025, 0.975), type = 7))", "ic = unname(stats::quantile(tmr, c(0.05, 0.95), type = 7))"))),
  list("IC da curva com qnorm(0,95)", list(c("rowSums((X %*% vcov) * X))); z <- stats::qnorm(0.975)", "rowSums((X %*% vcov) * X))); z <- stats::qnorm(0.95)"))),
  list("posição no eixo deslocada", list(c("xout = valor, rule = 1", "xout = valor + 1, rule = 1"))),
  list("soma dos lags só de 1 a 7", list(c("soma_lags <- function(coef, vcov, arglag, lags = 0:7)", "soma_lags <- function(coef, vcov, arglag, lags = 1:7)"))),
  list("ponte calculada como backward", list(c("dir <- if (analise == \"backward\") \"back\" else \"forw\"", "dir <- if (analise %in% c(\"backward\", \"ponte\")) \"back\" else \"forw\""))),
  list("busca da fronteira entre p10 e p50", list(c("grade_tmr(p10, p90)", "grade_tmr(p10, p50)"))),
  list("sem conferência do SHA-256 da attrdl", list(c("if (!identical(h, sha256)) stop(", "if (FALSE) stop("))),
  list("semente sem validar o i", list(c("  if (length(i) != 1 || !is.numeric(i) || is.na(i) || i != round(i) || i < 0 || i > length(ORDEM_CONCENTRACOES))\n    stop(", "  if (FALSE)\n    stop("))),
  list("eCI da attrdl pelos percentis 5 e 95", list(c("ic <- function(v) unname(stats::quantile(v, c(0.025, 0.975), type = 7))", "ic <- function(v) unname(stats::quantile(v, c(0.05, 0.95), type = 7))"))),
  list("fração atribuível sem conferir o aquecimento contra o lag", list(c("if (!identical(as.numeric(n_aquec), as.numeric(attr(basis, \"lag\")[2])))", "if (FALSE)"))),
  list("fração atribuível sem conferir o número de coeficientes", list(c("if (dir == \"back\" && length(coef) != ncol(basis))", "if (FALSE)"), c("if (dir == \"forw\" && length(coef) >= ncol(basis))", "if (FALSE)"))),
  # da re-auditoria independente das correções da Parte A (desvio 75)
  list("semente da attrdl com o índice deslocado", list(c("semeia(i); an <- attrdl(", "semeia(i - 1); an <- attrdl("), c("semeia(i); sim <- attrdl(", "semeia(i - 1); sim <- attrdl("))),
  list("simulações da attrdl sempre forward", list(c("sim <- attrdl(x, basis, cases, coef = coef, vcov = vcov, type = \"an\", dir = dir,", "sim <- attrdl(x, basis, cases, coef = coef, vcov = vcov, type = \"an\", dir = \"forw\","))),
  list("bootstrap da TMR numa grade sem o x_sup", list(c("k <- length(coef); g <- grade_tmr(x_inf, x_sup)", "k <- length(coef); g <- seq(x_inf, x_sup, by = 0.1)"))),
  list("EP da curva por lag sem as covariâncias", list(c("rowSums((B %*% vcov) * B)", "rowSums((B %*% diag(diag(vcov), nrow(vcov))) * B)"))),
  list("IC da curva por lag com qnorm(0,95)", list(c("rowSums((B %*% vcov) * B))); z <- stats::qnorm(0.975)", "rowSums((B %*% vcov) * B))); z <- stats::qnorm(0.95)"))),
  list("IC da soma dos lags com qnorm(0,95)", list(c("ep <- sqrt(drop(t(s) %*% vcov %*% s)); z <- stats::qnorm(0.975)", "ep <- sqrt(drop(t(s) %*% vcov %*% s)); z <- stats::qnorm(0.95)"))),
  list("forward aceitando NA nos cases", list(c("if (dir == \"forw\" && anyNA(cases))", "if (FALSE)"))),
  list("busca da TMR devolvendo o p10 no campo p50", list(c("tmr_p10_p90 = NA_real_, p50 = p50)", "tmr_p10_p90 = NA_real_, p50 = p10)"))),
  list("curva por lag com lags padrão de 1 em 1", list(c("lags = seq(0, 7, by = 0.1)", "lags = seq(0, 7, by = 1)"))),
  list("Ψ devolvido do modelo só com intercepto", list(c("out$wald <- wald; out$Psi <- fit$Psi", "out$wald <- wald; out$Psi <- if (fit0$falhou) fit$Psi else fit0$fit$Psi"))),
  list("índice da concentração sem recusar código fora da ordem", list(c("if (anyNA(i)) stop(\"concentração fora", "if (FALSE) stop(\"concentração fora"))),
  list("posição no eixo extrapolando (rule = 2)", list(c("xout = valor, rule = 1", "xout = valor, rule = 2"))),
  list("IC da AF com os limites trocados", list(c("af_li = c95[1] / den, af_ls = c95[2] / den", "af_li = c95[2] / den, af_ls = c95[1] / den")))
)
grupos <- c(prompt = 13L, complemento = 8L, auditoria = 18L, reauditoria = 13L)   # na ordem da lista; conferido abaixo pelo 1º defeito de cada grupo
inicio <- cumsum(c(1L, grupos[-length(grupos)]))
stopifnot(sum(grupos) == length(defeitos), identical(vapply(defeitos[inicio], `[[`, "", 1),
          c("Boundary.knots omitidos na base de predição", "ordem das concentrações sem trava", "Q/I² residual e total trocados", "semente da attrdl com o índice deslocado")))
.R3$relata_tmr <- FALSE
res_def <- do.call(rbind, lapply(defeitos, function(d) {
  s2 <- src
  for (tr in d[[2]]) { stopifnot(lengths(regmatches(s2, gregexpr(tr[1], s2, fixed = TRUE))) == 1); s2 <- sub(tr[1], tr[2], s2, fixed = TRUE) }
  tf <- file.path(tempdir(), "segunda_etapa_com_defeito.R"); writeLines(s2, tf, useBytes = TRUE)
  log_msg("defeito:", d[[1]]); g <- carrega(tf)
  ru <- roda_testes(g, testes_segunda_etapa)
  rm_ <- if (any(!ru$ok & r_u$ok)) data.frame(teste = r_m$teste, ok = NA, mensagem = "não rodado (um teste rápido já caiu)", stringsAsFactors = FALSE) else roda_testes(g, testes_segunda_etapa_mc)
  rr <- rbind(ru[, c("teste", "ok", "mensagem")], rm_[, c("teste", "ok", "mensagem")]); unlink(tf)
  stopifnot(identical(rr$teste, todos$teste)); rr$ok[is.na(rr$ok)] <- TRUE
  novos <- rr$teste[!rr$ok & todos$ok]; do_orig <- rr$teste[!rr$ok & !todos$ok]
  data.frame(Defeito = d[[1]], Trocas = length(d[[2]]), `Testes derrubados (dos que passam no original)` = length(novos),
             Quais = paste0(if (length(novos)) paste(novos, collapse = ", ") else "nenhum", if (length(do_orig)) paste0(" (falha também no original: ", paste(do_orig, collapse = ", "), ")") else ""),
             check.names = FALSE, stringsAsFactors = FALSE)
}))
sha_depois <- sha(f_se)
def_ok <- all(res_def$`Testes derrubados (dos que passam no original)` >= 1)
ok <- all(todos$ok) && def_ok && identical(sha_antes, sha_depois)

# ------------------------------------------------------------------ log
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
t5 <- T3_m$t05; d5 <- T3_m$t05_decl; s_info <- sessionInfo()
md <- c("# Fase 3, A2: testes da segunda etapa (`segunda_etapa.R`)", "",
        sprintf("- **Gerado por:** `00_scripts/41_testes_segunda_etapa.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        sprintf("- **Ambiente:** R %s; dlnm %s; gnm %s; mixmeta %s; tsModel %s. BLAS/LAPACK: `%s` / `%s`. Semente 20261001 (Mersenne-Twister, Inversion, Rejection); sementes por concentração conforme o complemento C1.",
                paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("gnm"), packageVersion("mixmeta"), packageVersion("tsModel"), s_info$BLAS, s_info$LAPACK),
        "- **Arquivos testados (SHA-256):**",
        sprintf("  - `codigo_compartilhado/R/segunda_etapa.R`: `%s` (igual antes e depois dos defeitos: %s);", sha_antes, if (identical(sha_antes, sha_depois)) "sim" else "NÃO"),
        sprintf("  - `codigo_compartilhado/R/ajusta_dlnm.R`: `%s` (tag `ajusta_dlnm-v1.0`, sem mudança);", sha(f_aj)),
        sprintf("  - `codigo_compartilhado/tests/testa_segunda_etapa.R`: `%s`;", sha(f_tr)), sprintf("  - `codigo_compartilhado/tests/testa_segunda_etapa_mc.R`: `%s`;", sha(f_tm)),
        sprintf("  - `codigo_compartilhado/tests/roda_testes.R`: `%s`;", sha(f_run)), sprintf("  - `codigo_compartilhado/inst/terceiros/attrdl.R`: `%s` (conferido contra o registrado).", sha(f_at)),
        "- **Entradas (SHA-256 conferidos contra os logs que as geraram), usadas só como atributos, exposição, percentis, metapreditores e covariâncias:**",
        sprintf("  - `%s`: `%s`;", ENT, sha_ent), "",
        "## Teste 5: parâmetros declarados antes das réplicas", "",
        sprintf("- **Base:** a combinada das 26 `argvar` reais (D2): ns com nós %s e Boundary.knots %s °C.", paste(br(d5$base$knots, 3), collapse = "; "), paste(br(d5$base$Boundary.knots, 3), collapse = " e ")),
        sprintf("- **β:** projeção, por mínimos quadrados na grade de 301 pontos entre os Boundary.knots, de log RR verdadeiro contra o x50 = 0,02 por °C acima do x75 do eixo médio: %s. Log RR verdadeiro em x99 contra x50 = %s (exigido ≥ 0,05).",
                paste(formatC(d5$beta, format = "e", digits = 4), collapse = "; "), br(d5$v99, 5)),
        sprintf("- **Ψ verdadeiro:** não diagonal, com DP = metade da raiz da média das variâncias das S_i (%s) e correlação 0,3 entre os 4 coeficientes.", paste(formatC(d5$sdp, format = "e", digits = 3), collapse = "; ")),
        "- **S_i:** as vcov reduzidas reais da Fase 2 (já vistas), só como covariâncias dos coeficientes sintéticos (desvio 72d). **Metapreditores:** média e amplitude de ano inteiro do CSV, com efeito verdadeiro nulo.",
        sprintf("- **cen:** x50 do eixo médio (%s °C). **TMR verdadeira** (mínimo da curva verdadeira na grade entre x1 e x99 do eixo): %s °C. **Réplicas:** %d de 26 unidades; os sorteios de todas as réplicas são feitos antes dos ajustes.",
                br(d5$cen, 3), br(d5$tmr_verdadeira, 1), d5$R), "",
        sprintf("## Resultado: %d/%d testes", sum(todos$ok), nrow(todos)), "",
        tabela_md(data.frame(Teste = paste0("`", todos$teste, "`"), Resultado = ifelse(todos$ok, "passou", paste("FALHOU:", todos$mensagem)), check.names = FALSE)), "",
        "## Monte Carlo (teste 5)", "",
        sprintf("- **Cobertura do IC 95%% do log RR combinado em x99 contra x50:** %s (EP de MC %s; IC Wilson %s); critério 0,92–0,98.", br(t5$cobertura, 3), br(t5$ep_cob, 4), ic(t5$ic_cob, 3)),
        sprintf("- **Viés:** %s (EP de MC %s; IC MC %s); relativo %s%% (EP %s%%); critério |·| < 10%%. EP médio %s; DP das estimativas %s.",
                br(t5$vies, 5), br(t5$ep_vies, 5), ic(t5$vies + c(-1, 1) * 1.96 * t5$ep_vies, 5), br(100 * t5$vies_rel, 2), br(100 * t5$ep_vies_rel, 2), br(t5$se_medio, 4), br(t5$dp_lr, 4)),
        sprintf("- **EQM contra os coeficientes verdadeiros das unidades:** BLUP %s; primeira etapa %s; parte fixa X_iβ̂ (predição de cada unidade pelos seus metapreditores) %s. Critério implementado: o do BLUP é o menor desses três.",
                formatC(t5$mse[["blup"]], format = "e", digits = 3), formatC(t5$mse[["primeira_etapa"]], format = "e", digits = 3), formatC(t5$mse[["parte_fixa"]], format = "e", digits = 3)),
        sprintf("- **EQM da predição na média dos metapreditores** (a mesma predição para todas as unidades; só reportado): %s. O prompt (A2.5) fala em \"predição da média\"; o comparador implementado é a parte fixa X_iβ̂ de cada unidade, interpretação feita ao escrever o teste e registrada no desvio 74. Com inclinações verdadeiras nulas, a predição na média funciona como comparador \"oráculo\". A escolha é do chat (desvio 74).",
                formatC(t5$mse[["predicao_media"]], format = "e", digits = 3)),
        sprintf("- **BLUP = fórmula à mão** (Xβ̂ + Ψ̂(Ψ̂ + S_i)⁻¹(y_i − Xβ̂)), numa réplica: diferença máxima %s (critério ≤ 1e-8).", formatC(t5$dif_blup, format = "e", digits = 1)),
        sprintf("- **Cobertura do IC 95%% da TMR combinada (bootstrap da D4(a)), só reportada:** %s.", br(t5$cob_tmr, 3)),
        sprintf("- **Método do mixmeta nas réplicas:** %s. Duração: %s min.", paste(sprintf("%s em %d", names(t5$metodos), as.integer(t5$metodos)), collapse = "; "), br(dur_mc, 1)), "",
        "## Valores descritivos dos testes rápidos", "",
        sprintf("- **Teste 2:** maior |Boundary.knots − range(x)| nas 26 = %s.", formatC(T3_u$t02, format = "e", digits = 1)),
        sprintf("- **Teste 3:** maior diferença entre `curva()` (4 coeficientes) e o `crossreduce` com 16 coeficientes sintéticos, nas 26 concentrações e nos seus percentis = %s (critério ≤ 1e-10).", formatC(T3_u$t03, format = "e", digits = 1)),
        sprintf("- **Teste 6 (quadrática):** DP das TMR sorteadas %s × EP pelo método delta %s (critério: diferença < 20%%); largura do IC %s °C.", br(T3_u$t06[["dp_boot"]], 3), br(T3_u$t06[["ep_delta"]], 3), br(T3_u$t06[["largura"]], 2)),
        sprintf("- **Teste 8(f):** correlação entre as simulações das concentrações 1 e 2 (mesma vcov) = %s (critério |r| < 0,15).", br(T3_u$t08_cor, 3)),
        sprintf("- **Teste 8, *backward* (sem teste de aditividade; complemento C1, item 5):** total − (calor + frio) = %s no AN sintético.", br(T3_u$t08_backward_dif, 4)), "",
        "## Defeitos plantados (cada um numa cópia; a bateria inteira roda em cada cópia)", "",
        sprintf("Os %d primeiros são os do prompt (A2, item 11); os %d seguintes vêm do complemento de 13/10; os %d seguintes, da auditoria independente da Parte A (desvio 74); os %d últimos, da re-auditoria independente das correções (desvio 75).", grupos[["prompt"]], grupos[["complemento"]], grupos[["auditoria"]], grupos[["reauditoria"]]),
        "O teste 5 (Monte Carlo) só roda numa cópia quando nenhum teste rápido cai. Um defeito conta só se derrubar um teste que passa na versão original.", "",
        tabela_md(res_def), "",
        sprintf("- **Resultado:** %s.", if (ok) sprintf("todos os testes passam na versão original e cada um dos %d defeitos derruba pelo menos um teste", nrow(res_def)) else "FALHA: ver as tabelas; diagnóstico antes de qualquer mudança (nunca troca de semente, réplicas ou critério)"), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| resultado:", if (ok) "ok" else "FALHA", "\n")
if (!ok) quit(status = 1)
