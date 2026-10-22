# 31_testes_ajusta_dlnm.R — Fase 2, A2: testes da ajusta_dlnm() com dado sintético, Monte Carlo e 28 defeitos plantados
# (os 7 do prompt, 9 da auditoria independente, desvio 62, e 12 da re-auditoria, desvio 63).
# Nada da base é lido (o source do acesso.R só registra versao()). Semente 20261001, RNG padrão, em série (§8).
# - Testes rápidos: codigo_compartilhado/tests/testa_ajusta_dlnm.R (1–4, 8–10 e os rápidos do desvio 58).
# - Monte Carlo: codigo_compartilhado/tests/testa_ajusta_dlnm_mc.R (5, 5b, 6 e 7; 200 réplicas; desvios 55 e 57).
# - Antes das réplicas, declara no log: a base fixa, θ, o R² da projeção, os dois verdadeiros e a conta exata do viés
#   esperado do modelo "nenhum" no teste 7 (pseudoverdadeiro numa série longa sem ruído; desvio 57).
# - Defeitos: cada um numa cópia de ajusta_dlnm.R, numa pasta temporária; a bateria inteira roda em cada cópia. Um defeito
#   conta como detectado só se derrubar um teste que passa na versão original (o 5b falha também no original; desvio 61).
# Grava logs/testes_ajusta_dlnm_fase2_<FASE2_DATA>.md (ou, com SUFIXO=tag, ..._tag_<data>.md: Parte B). Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE2_DATA=AAAAMMDD Rscript 00_scripts/31_testes_ajusta_dlnm.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE2_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
sufixo <- Sys.getenv("SUFIXO"); stopifnot(sufixo %in% c("", "tag"))
arq <- file.path("logs", paste0("testes_ajusta_dlnm_fase2_", if (nzchar(sufixo)) paste0(sufixo, "_") else "", hoje, ".md")); stopifnot(!file.exists(arq))
suppressPackageStartupMessages({ library(dlnm); library(gnm) })
CC <- file.path("..", "codigo_compartilhado")
f_fun <- file.path(CC, "R", "ajusta_dlnm.R"); f_ger <- file.path(CC, "tests", "gera_sintetico.R")
f_tu <- file.path(CC, "tests", "testa_ajusta_dlnm.R"); f_tm <- file.path(CC, "tests", "testa_ajusta_dlnm_mc.R"); f_run <- file.path(CC, "tests", "roda_testes.R")
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
sha_antes <- sha(f_fun)
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
ic <- function(v, d = 3) sprintf("[%s; %s]", br(v[1], d), br(v[2], d))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
carrega <- function(arquivo_funcao) { e <- new.env(); sys.source(arquivo_funcao, envir = e); sys.source(f_ger, envir = e); e }
source(f_run); source(f_tu); source(f_tm)

# ------------------------------------------------------------------ base fixa, θ e verdadeiros (antes de qualquer réplica)
f0 <- carrega(f_fun)
set.seed(20261001); bf <- f0$base_fixa(100000); proj <- f0$projeta_theta(bf)
.MC$bf <- bf; .MC$proj <- proj; .MC$R <- 200L
set.seed(20261001); amostra <- f0$gera_sintetico(4500, eventos_dia = 30, gamma = 1.3, efeito = "theta", bf = bf, theta = proj$theta)
dp_intra <- mean(tapply(amostra$log_w[amostra$janela], amostra$estrato[amostra$janela], stats::sd))

# ------------------------------------------------------------------ teste 7: conta do viés esperado, antes das réplicas
log_msg("conta do viés esperado do teste 7")
set.seed(20261001)
longa <- f0$gera_sintetico(45000, eventos_dia = 30, gamma = 1, efeito = "nenhum", bf = bf, a_Z = 0.3, fase_Z = f0$PARAM_GERADOR$t_fase, esperado = TRUE)
cbl <- crossbasis(longa$temp, lag = 7, argvar = bf$argvar, arglag = bf$arglag); ul <- longa$janela & stats::complete.cases(cbl)
ml <- gnm(longa$y[ul] ~ unclass(cbl)[ul, ] + longa$dia_semana[ul] + longa$feriado_nacional[ul] + longa$carnaval[ul] + longa$moveis[ul],
          eliminate = factor(longa$estrato[ul]), family = quasipoisson, verbose = FALSE)
i_cb <- 1:16; Vl <- vcov(ml, dispersion = 1)[i_cb, i_cb]
redl <- crossreduce(cbl, coef = coef(ml)[i_cb], vcov = Vl, model.link = "log", type = "overall", cen = bf$cen)
bl <- unclass(do.call(onebasis, c(list(x = c(bf$p99, bf$cen)), attributes(cbl)$argvar))); dvl <- bl[1, ] - bl[2, ]
vies7 <- sum(dvl * coef(redl)); se7_45000 <- sqrt(drop(t(dvl) %*% vcov(redl) %*% dvl))
se7_4500 <- se7_45000 * sqrt(45000 / 4500); ep7 <- se7_4500 / sqrt(.MC$R); razao7 <- vies7 / ep7
dev_t <- longa$temp - ave(longa$temp, longa$estrato); dev_z <- longa$log_z - ave(longa$log_z, longa$estrato)
lin7 <- sum(dev_t * dev_z) / sum(dev_t^2) * (bf$p99 - bf$cen)        # aproximação linear dentro do estrato
if (!(vies7 > 0 && razao7 >= 5)) stop("teste 7: viés esperado ", format(vies7), " = ", format(razao7), " EP de MC (< 5): ajustar a antes de rodar")
rm(longa, cbl, ml); invisible(gc())

# ------------------------------------------------------------------ bateria original
log_msg("bateria original: testes rápidos"); r_u <- roda_testes(f0, testes_ajusta_dlnm)
log_msg("bateria original: Monte Carlo (200 réplicas)"); t_mc <- Sys.time(); r_m <- roda_testes(f0, testes_ajusta_dlnm_mc)
dur_mc <- as.numeric(Sys.time() - t_mc, units = "mins")
MC0 <- as.list(.MC)                                                  # guarda os resultados antes dos defeitos
todos <- rbind(r_u, r_m); print(todos[, c("teste", "ok")], row.names = FALSE)

# ------------------------------------------------------------------ defeitos plantados
src <- paste0(paste(readLines(f_fun, encoding = "UTF-8"), collapse = "\n"), "\n")
defeitos <- list(
  list("cross-basis montada depois de cortar a janela", "  base_linhas <- seq_len(nrow(dados))", "  base_linhas <- which(dados[[spec$janela]] %in% TRUE)"),
  list("estratos vazios mantidos", "  vazios <- names(ev)[ev == 0]", "  vazios <- character(0)"),
  list("log_w fora do modelo no z_w_gama", "if (spec$offset == \"z_w_gama\") { md$log_w", "if (FALSE) { md$log_w"),
  list("cen ignorado, centrando no 0 °C", "cen = spec$cen, at = spec$cen)", "cen = 0, at = spec$cen)"),
  list("lag atravessando unidades sem group", "group = if (is.null(spec$group)) NULL else grp), error = function(e) e)", "group = NULL), error = function(e) e)"),
  list("PACF no vetor empilhado", "out$pacf <- .pacf_por_unidade(rd[grade], grp[grade])", "out$pacf <- .pacf_por_unidade(rd[grade], rep(\"1\", sum(grade)))"),
  list("φ com n − length(coef)", "out$phi <- sum(rp^2) / m$df.residual", "out$phi <- sum(rp^2) / (length(rp) - length(stats::coef(m)))"),
  # da auditoria independente (desvio 62)
  list("vcov sem φ (dispersão 1)", "V <- tryCatch(stats::vcov(m), error", "V <- tryCatch(stats::vcov(m, dispersion = 1), error"),
  list("limite da PACF com os dias da grade, NA incluídos", "lim <- if (calcula) 2 / sqrt(n) else NA_real_", "lim <- if (calcula) 2 / sqrt(length(v)) else NA_real_"),
  list("sem checagem de convergência", "if (!out$convergiu || any(grepl(\"converg\", avisos, ignore.case = TRUE))) falhas", "if (FALSE) falhas"),
  list("sem checagem de vcov positiva-definida (16 × 16)", "if (!is.finite(out$autovalor_min_cb) || out$autovalor_min_cb <= 0) falhas", "if (FALSE) falhas"),
  list("sem checagem de vcov positiva-definida (reduzida)", "if (!is.finite(out$autovalor_min_red) || out$autovalor_min_red <= 0) falhas", "if (FALSE) falhas"),
  list("EP de γ devolvido como variância", "out$ep_gama <- sqrt(vg) else", "out$ep_gama <- vg else"),
  list("QAIC sem φ", "+ 2 * out$phi * k", "+ 2 * k"),
  list("Boundary.knots só da janela", "lag = spec$lag, argvar = spec$argvar,",
       "lag = spec$lag, argvar = utils::modifyList(spec$argvar, list(Boundary.knots = range(dados[[spec$exposicao]][dados[[spec$janela]] %in% TRUE]))),"),
  list("grade da PACF só com os dias da janela", "if (length(i)) grade[min(i):max(i)] <- TRUE", "if (length(i)) grade[i] <- TRUE"),
  # da re-auditoria (desvio 63)
  list("erro em φ, QAIC ou PACF não capturado", "}, error = function(e) conditionMessage(e))", "}, error = function(e) stop(e))"),
  list("sem o ramo \"vcov indisponível\"", "} else if (is.null(V)) falhas <- c(falhas, \"vcov indisponível\")", "}"),
  list("erro no crossreduce não capturado", "cen = spec$cen, at = spec$cen), error = function(e) e)", "cen = spec$cen, at = spec$cen), error = function(e) stop(e))"),
  list("offset não finito dentro do ajuste", "for (k in off_cols) ok <- ok & is.finite(dados[[k]])", "for (k in off_cols) ok <- ok"),
  list("γ̂ tirado do coeficiente errado", "out$gama <- unname(cf[\"log_w\"])", "out$gama <- unname(cf[length(cf) - 1])"),
  list("zw com offset log_z", "zw = dados$log_zw[usar]", "zw = dados$log_z[usar]"),
  list("z_w_gama com offset log_zw", "z_w_gama = dados$log_z[usar], zw", "z_w_gama = dados$log_zw[usar], zw"),
  list("linhas por unidade contadas antes de tirar os estratos vazios", "i <- usar & grp == u", "i <- ok & grp == u"),
  list("estratos usados contados antes de tirar os vazios", "estratos_usados = length(unique(est[usar]))", "estratos_usados = length(unique(est[ok]))"),
  list("dias removidos contados fora das linhas de ajuste", "dias_removidos_estrato_vazio = sum(ok & est %in% vazios)", "dias_removidos_estrato_vazio = sum(est %in% vazios)"),
  list("`fora` sem checar lag NA", "fora = if (calcula && !anyNA(p))", "fora = if (calcula)"),
  list("EP de γ sem checar a variância", "if (is.finite(vg) && vg >= 0) out$ep_gama <- sqrt(vg) else out$avisos", "out$ep_gama <- sqrt(vg); if (FALSE) out$avisos"))
res_def <- do.call(rbind, lapply(defeitos, function(d) {
  stopifnot(lengths(regmatches(src, gregexpr(d[[2]], src, fixed = TRUE))) == 1)   # alvo existe e é único
  tf <- file.path(tempdir(), "ajusta_dlnm_com_defeito.R"); writeLines(sub(d[[2]], d[[3]], src, fixed = TRUE), tf, useBytes = TRUE)
  log_msg("defeito:", d[[1]]); g <- carrega(tf)
  rr <- rbind(roda_testes(g, testes_ajusta_dlnm), roda_testes(g, testes_ajusta_dlnm_mc)); unlink(tf)
  stopifnot(identical(rr$teste, todos$teste))
  novos <- rr$teste[!rr$ok & todos$ok]; do_orig <- rr$teste[!rr$ok & !todos$ok]   # só conta o que passa no original
  data.frame(Defeito = d[[1]], `Troca na cópia` = paste0("`", d[[2]], "` → `", d[[3]], "`"),
             `Testes derrubados (dos que passam no original)` = length(novos),
             Quais = paste0(if (length(novos)) paste(novos, collapse = ", ") else "nenhum",
                            if (length(do_orig)) paste0(" (falha também no original: ", paste(do_orig, collapse = ", "), ")") else ""),
             check.names = FALSE, stringsAsFactors = FALSE)
}))
sha_depois <- sha(f_fun)
falhas_orig <- todos$teste[!todos$ok]
FALHA_CONHECIDA <- c(t05b_recuperacao_contagem_baixa = "cobertura 0.985 fora de 0,92–0,98")   # desvio 61: nome E mensagem (desvio 63)
conhecida <- length(falhas_orig) == 0 || (all(falhas_orig %in% names(FALHA_CONHECIDA)) &&
                                          identical(unname(todos$mensagem[!todos$ok]), unname(FALHA_CONHECIDA[falhas_orig])))
def_ok <- all(res_def$`Testes derrubados (dos que passam no original)` >= 1)
ok <- def_ok && identical(sha_antes, sha_depois) && conhecida

# ------------------------------------------------------------------ log
s_info <- sessionInfo(); P <- f0$PARAM_GERADOR
linha_mc <- function(nome, s, criterio) sprintf("| %s | %s | %s (EP %s; IC Wilson %s) | %s (EP %s; IC MC %s) | %s |", nome, br(s$verdadeiro, 4),
  br(s$cobertura, 3), br(s$ep_cob, 4), ic(s$ic_cob, 3), br(s$vies, 4), br(s$ep_vies, 4), ic(s$ic_vies, 4), criterio)
t5 <- MC0$t05; t5b <- MC0$t05b; t6 <- MC0$t06; t7 <- MC0$t07
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
md <- c("# Fase 2, A2: testes da `ajusta_dlnm()` com dado sintético", "",
        sprintf("- **Gerado por:** `00_scripts/31_testes_ajusta_dlnm.R`, em %s. Rodada `%s`%s. `versao()` no início = %s (o fim está na última linha). Nada da base foi lido.",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, if (nzchar(sufixo)) " (Parte B: testes de novo antes da tag)" else "", v_ini),
        sprintf("- **Ambiente:** R %s; dlnm %s; gnm %s. BLAS/LAPACK: `%s` / `%s`. RNG padrão (Mersenne-Twister), semente 20261001, em série.",
                paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("gnm"), s_info$BLAS, s_info$LAPACK),
        "- **Arquivos testados (SHA-256):**",
        sprintf("  - `codigo_compartilhado/R/ajusta_dlnm.R`: `%s` (igual antes e depois dos defeitos: %s);", sha_antes, if (identical(sha_antes, sha_depois)) "sim" else "NÃO"),
        sprintf("  - `codigo_compartilhado/tests/gera_sintetico.R`: `%s`;", sha(f_ger)),
        sprintf("  - `codigo_compartilhado/tests/testa_ajusta_dlnm.R`: `%s`;", sha(f_tu)),
        sprintf("  - `codigo_compartilhado/tests/testa_ajusta_dlnm_mc.R`: `%s`;", sha(f_tm)),
        sprintf("  - `codigo_compartilhado/tests/roda_testes.R`: `%s`.", sha(f_run)), "",
        "## Gerador comum (parâmetros declarados)", "",
        sprintf("- **Temperatura:** %s + %s·sin(2π(t − %s)/365,25) + AR(1) estacionário (ρ = %s; DP marginal %s °C).", P$t_media, P$t_amp, P$t_fase, P$rho_t, P$dp_t),
        "- **Z_t:** 1 + a·sin(2π(t − φ_Z)/365,25); a = 0,1 e φ_Z = 100 nos testes 1–6 e 8–10; a = 0,3 e φ_Z = 15 (mesma fase da temperatura) no teste 7.",
        sprintf("- **log W_t:** log(0,01) + %s·sin(2π(t − %s)/365,25) + AR(1) (ρ = %s; DP marginal 0,0275). DP intra-estrato obtido numa réplica: %s (alvo ~0,02, Fase 1).",
                P$logw_amp, P$logw_fase, P$rho_logw, br(dp_intra, 4)),
        sprintf("- **Calendário:** dia da semana (efeitos %s, de segunda a domingo), feriados fixos (%s; efeito %s), carnaval (%s; %s) e móveis (%s; %s). Efeito aleatório de estrato N(0; %s²). Estratos ano × mês.",
                paste(br(P$dow, 2), collapse = "/"), paste(P$feriados, collapse = ", "), br(P$b_feriado, 2), paste(P$carnaval, collapse = ", "), br(P$b_carnaval, 2),
                paste(P$moveis, collapse = ", "), br(P$b_moveis, 2), br(P$dp_estrato, 2)),
        "- **Contagens:** y ~ Poisson(μ), com μ calibrado para ~30 (testes 5, 6 e 7) ou ~3 (5b) eventos por dia na janela; 4.500 dias de janela mais 7 de aquecimento. No teste 1, y ~ binomial negativa com tamanho 5 (sobredisperso), para a vcov depender de φ (desvio 62).",
        sprintf("- **Base fixa dos testes de Monte Carlo** (série de referência de 100.000 dias, semente 20261001): nós p10/p75/p90 = %s °C; cen = p50 = %s °C; p99 = %s °C; Boundary.knots = %s °C; arglag ns com nós %s e intercepto.",
                paste(br(bf$knots, 3), collapse = "; "), br(bf$cen, 3), br(bf$p99, 3), paste(br(bf$bk, 3), collapse = " e "), paste(br(bf$arglag$knots, 3), collapse = " e ")), "",
        "## Teste 5: efeito dentro do espaço da cross-basis (desvio 55)", "",
        sprintf("- **θ** (16 coeficientes, mínimos quadrados na grade de 301 temperaturas × lags 0–7; alvo 0,03/°C acima do p75, repartido igualmente nos lags 0, 1 e 2): %s.", paste(formatC(proj$theta, format = "e", digits = 4), collapse = "; ")),
        sprintf("- **R² da projeção:** %s.", br(proj$r2, 4)),
        sprintf("- **Log RR verdadeiro no p99 contra o cen:** versão θ (critério) = %s; dobradiça original = 0,03 × (p99 − p75) = %s; diferença (erro de aproximação da base) = %s.",
                br(proj$verdadeiro_theta, 5), br(proj$verdadeiro_dobradica, 5), br(proj$verdadeiro_theta - proj$verdadeiro_dobradica, 5)), "",
        "## Teste 7: viés esperado declarado antes das réplicas (desvio 57)", "",
        "- **Desenho:** γ = 1; sem efeito de temperatura (estimando verdadeiro = 0); a = 0,3; Z_t na mesma fase da temperatura.",
        sprintf("- **Sinal esperado do viés do modelo `nenhum`:** positivo. Com Z_t e temperatura subindo juntos dentro do mês, omitir log Z_t joga na temperatura parte da variação de μ."),
        sprintf("- **Conta exata** (pseudoverdadeiro: modelo `nenhum` ajustado a y = μ numa série sem ruído de 45.000 dias, mesma base): viés esperado = %s no log RR do p99 contra o cen, isto é, %s·a. EP de Poisson para 4.500 dias = %s; EP de MC esperado com 200 réplicas = %s; razão = %s EP de MC (exigido ≥ 5).",
                br(vies7, 4), br(vies7 / 0.3, 3), br(se7_4500, 4), br(ep7, 4), br(razao7, 1)),
        sprintf("- **Aproximação linear dentro do estrato** (inclinação de log Z_t na temperatura × (p99 − cen)): %s, ou %s·a. Para comparar com as estimativas prévias de ~0,17·a (sessão) e ~0,19·a (conferência de Guilherme). A conta exata passa da linear porque o modelo é não linear (ns) e o p99 fica na cauda.",
                br(lin7, 4), br(lin7 / 0.3, 3)), "",
        sprintf("## Resultado: %d/%d testes", sum(todos$ok), nrow(todos)), "",
        tabela_md(data.frame(Teste = paste0("`", todos$teste, "`"), Resultado = ifelse(todos$ok, "passou", paste("FALHOU:", todos$mensagem)), check.names = FALSE)), "",
        sprintf("Duração da bateria de Monte Carlo: %s min. Ruído branco do teste 9 (200 réplicas × 7 lags): %s%% dos lags fora da faixa (IC Wilson %s%%; exigido entre 3%% e 7%%).",
                br(dur_mc, 1), br(100 * MC0$frac_ruido_branco, 2), ic(100 * .wilson(MC0$frac_ruido_branco, 1400), 2)), "",
        if (length(falhas_orig)) sprintf("- **Falha na versão original:** %s. %s", paste0("`", falhas_orig, "`", collapse = ", "),
          if (conhecida) sprintf("É a falha do 5b já diagnosticada, com a mesma mensagem (\"%s\"), reportada como está (desvio 61; `logs/diagnostico_t05b_fase2_%s.md`).", FALHA_CONHECIDA[[1]], hoje)
          else "FALHA NOVA (nome ou mensagem diferente da falha conhecida): diagnóstico antes de qualquer mudança.") else NULL,
        if (length(falhas_orig)) "" else NULL,
        "## Monte Carlo: coberturas e vieses (200 réplicas; IC da cobertura por Wilson; IC do viés = ± 1,96 EP de MC)", "",
        "| Cenário | Verdadeiro | Cobertura do IC 95% | Viés | Critério |", "|---|---|---|---|---|",
        linha_mc("5: contagem alta, efeito θ", t5$theta, sprintf("cobertura 0,92–0,98; |viés relativo| < 10%% (obtido %s%%, EP %s%%)", br(100 * t5$theta$vies_rel, 2), br(100 * t5$theta$ep_vies_rel, 2))),
        linha_mc("5b: contagem baixa, efeito θ", t5b$theta, sprintf("cobertura 0,92–0,98; viés relativo só reportado (%s%%, EP %s%%)", br(100 * t5b$theta$vies_rel, 2), br(100 * t5b$theta$ep_vies_rel, 2))),
        linha_mc("5, descritivo: dobradiça contra 0,03 × (p99 − p75)", t5$dobradica, "sem critério"),
        linha_mc("5, descritivo: dobradiça contra o verdadeiro θ", t5$dobradica_vs_theta, "sem critério"),
        linha_mc("5b, descritivo: dobradiça contra 0,03 × (p99 − p75)", t5b$dobradica, "sem critério"),
        linha_mc("6: nulo, contagem alta", t6$nulo, "cobertura do RR = 1 entre 0,92 e 0,98"), "",
        sprintf("- **Erro de especificação (dobradiça, efeito fora do espaço da cross-basis):** o número relevante é o viés observado contra o verdadeiro da própria dobradiça, %s (EP de MC %s; %s%% do verdadeiro) com contagem alta e %s (EP %s; %s%%) com contagem baixa. A diferença entre os dois verdadeiros (θ − dobradiça = %s) mede só o erro de aproximação da base no p99; o viés observado mede o que o modelo erra quando a curva verdadeira não está no espaço da base.",
                br(t5$dobradica$vies, 4), br(t5$dobradica$ep_vies, 4), br(100 * t5$dobradica$vies_rel, 1), br(t5b$dobradica$vies, 4), br(t5b$dobradica$ep_vies, 4),
                br(100 * t5b$dobradica$vies_rel, 1), br(proj$verdadeiro_theta - proj$verdadeiro_dobradica, 5)),
        sprintf("- **γ̂ (teste 5):** média %s (EP de MC %s; IC MC %s); alvo 1,3; distância = %s EP de MC (exigido < 2).",
                br(t5$gama$media, 4), br(t5$gama$ep, 4), ic(t5$gama$ic, 4), br(t5$gama$dif_em_ep, 2)),
        sprintf("- **γ̂ (teste 5b):** média %s (EP de MC %s; IC MC %s), só reportado.", br(t5b$gama$media, 4), br(t5b$gama$ep, 4), ic(t5b$gama$ic, 4)),
        sprintf("- **φ médio:** teste 5 = %s; teste 5b = %s; teste 6 = %s. Réplicas com `status = \"falhou\"`: teste 5 = %d; 5b = %d (dobradiça: %d e %d); 6 = %d.",
                br(t5$phi_medio, 3), br(t5b$phi_medio, 3), br(t6$phi_medio, 3), t5$falhou, t5b$falhou, t5$falhou_dobradica, t5b$falhou_dobradica, t6$falhou),
        sprintf("- **Teste 7, `zw` contra `z_w_gama`** (pareados): diferença média %s (EP de MC %s; IC MC %s) = %s EP (exigido |·| < 2).",
                br(t7$dif_media, 5), br(t7$ep_dif, 5), ic(t7$ic_dif, 5), br(t7$dif_em_ep, 2)),
        sprintf("- **Teste 7, `nenhum`:** viés médio %s (EP de MC %s; IC MC %s) = %s EP de MC, sinal %s (exigido > 3 EP, positivo; esperado %s). Coberturas do 0: `zw` %s, `z_w_gama` %s, `nenhum` %s. γ̂ médio no `z_w_gama`: %s (alvo 1).",
                br(t7$nenhum_vies, 4), br(t7$ep_nenhum, 4), ic(t7$ic_nenhum, 4), br(t7$nenhum_em_ep, 1), if (t7$nenhum_vies > 0) "positivo" else "negativo", br(vies7, 4),
                br(t7$zw$cobertura, 3), br(t7$z_w_gama$cobertura, 3), br(t7$nenhum$cobertura, 3), br(t7$gama$media, 3)), "",
        "## Observação para o chat: PACF dos resíduos num modelo correto", "",
        sprintf("- Nos testes 5 e 6 (modelo correto, sem autocorrelação gerada), a PACF média dos resíduos de deviance nos lags 1 a 7 foi %s (teste 5) e %s (teste 6). Fração de réplicas com algum lag fora de ±2/√n: %s%% (teste 5) e %s%% (teste 6).",
                paste(br(t5$pacf_media, 3), collapse = "; "), paste(br(t6$pacf_media, 3), collapse = "; "), br(100 * t5$pacf_alguma_fora, 1), br(100 * t6$pacf_alguma_fora, 1)),
        "- **Leitura:** com estratos mensais eliminados, os resíduos de cada estrato somam ~0, o que induz uma autocorrelação de cerca de −1/(m − 1) ≈ −0,034 (m ≈ 30 dias). Com n ≈ 4.500, a faixa ±2/√n é de ±0,030, então a regra da §2.1 (PACF fora da faixa em algum lag de 1 a 7) tende a disparar em quase todas as unidades mesmo sem autocorrelação real. A função calcula como o prompt pede; a leitura do critério é decisão do chat (antes da Parte C).", "",
        "## Defeitos plantados (cada um numa cópia; a bateria inteira roda em cada cópia)", "",
        "Os 7 primeiros são os do prompt; os 9 seguintes vêm da auditoria independente (desvio 62); os 12 últimos, da re-auditoria (desvio 63). Um defeito conta como detectado só se derrubar um teste que passa na versão original.", "",
        tabela_md(res_def), "",
        sprintf("- **Resultado:** %s.", if (ok) paste0(if (length(falhas_orig)) paste0("na versão original, só falha o já diagnosticado, com a mesma mensagem (", paste(falhas_orig, collapse = ", "), "; desvio 61)") else "todos os testes passam na versão original",
                                                       "; cada um dos ", nrow(res_def), " defeitos derruba pelo menos um teste que passa no original")
                else "FALHA: ver as tabelas; diagnóstico antes de qualquer mudança (nunca troca de semente)"), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| resultado:", if (ok) "ok" else "FALHA", "\n")
if (!ok) quit(status = 1)
