# 32_primeira_etapa_principal.R — Fase 2, Parte C: primeira etapa do modelo PRINCIPAL nas 26 concentrações, com a
# ajusta_dlnm() da tag ajusta_dlnm-v1.0. Escolhas registradas antes de rodar no desvio 65; saídas fora do git (desvio 59).
# No início confere: o código de codigo_compartilhado/R/ = o da tag (SHA-256) e o BLAS/LAPACK de referência (§8).
# Por concentração (uma chamada cada):
#   - linhas passadas: janela principal (2012-04-14 a 2024-08-06) mais os 7 dias anteriores (2012-04-07 a 2012-04-13),
#     nada além (§1.5): os Boundary.knots saem do range de tmean_nucleo nesse conjunto;
#   - spec: ptb, tmean_nucleo, janela_principal, lag 7, argvar ns com nós p10/p75/p90 e cen = p50 das linhas de ano
#     inteiro de referencias_exposicao.csv, arglag ns com intercepto e logknots(7, nk = 2), offset z_w_gama, calendário;
#   - fallback (desvio 65a) só para falha de convergência, aliasamento na cross-basis ou vcov: ns p50/p90 e lag em estratos
#     0–1, 2–4 e 5–7; outra falha, ou γ inválido (65b), vira decisão pendente.
# Sem RR, curva, MRT, contraste nem gráfico (Fase 3). Só agregados por concentração saem no log; nenhum resíduo, valor
# ajustado ou série diária é gravado. Grava logs/primeira_etapa_fase2_<FASE2_DATA>.md e 01_saidas/fase2/*. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE2_DATA=AAAAMMDD Rscript 00_scripts/32_primeira_etapa_principal.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE2_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; CC <- file.path("..", "codigo_compartilhado")
arq <- file.path("logs", paste0("primeira_etapa_fase2_", hoje, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase2"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
saidas <- file.path(OUT, paste0(c("primeira_etapa_principal", "reduzida_coef_vcov", "crossbasis_coef_vcov", "pacf", "diagnosticos"),
                                "_fase2_", hoje, c(".rds", ".csv", ".csv", ".csv", ".csv")))
stopifnot(!any(file.exists(saidas)))
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")

# ------------------------------------------------------------------ BLAS de referência (§8; desvio 65d)
s_info <- sessionInfo()
blas_ok <- basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib"
if (!blas_ok) stop("BLAS/LAPACK fora da referência (§8): ", s_info$BLAS, " / ", s_info$LAPACK, ". Parar e informar antes de ajustar.")

# ------------------------------------------------------------------ código = tag ajusta_dlnm-v1.0 (desvio 65e)
TAG <- "ajusta_dlnm-v1.0"; COMMIT_TAG <- "caf5022f9a655877d8e3931dd3d02d7dce429fe5"
tag_commit <- git("rev-parse", shQuote(paste0(TAG, "^{commit}"))); tag_obj <- git("rev-parse", TAG)
if (!identical(tag_commit, COMMIT_TAG)) stop("a tag ", TAG, " não aponta para o commit esperado: ", tag_commit)
arqs_R <- git("ls-tree", "-r", "--name-only", TAG, "codigo_compartilhado/R/")
sha_tag <- vapply(arqs_R, function(a) sub(" .*", "", system(paste("git -C", shQuote(REPO), "show", shQuote(paste0(TAG, ":", a)), "| shasum -a 256"), intern = TRUE)), "")
sha_disco <- vapply(arqs_R, function(a) sha(file.path(REPO, a)), "")
if (!identical(unname(sha_tag), unname(sha_disco))) stop("codigo_compartilhado/R/ no disco difere da tag ", TAG)
suppressPackageStartupMessages({ library(dlnm); library(gnm) })
f <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = f)

# ------------------------------------------------------------------ entradas
f_ser <- file.path("01_saidas", "fase1", "serie_ptb_principal.rds"); f_ref <- file.path("01_saidas", "fase1", "referencias_exposicao.csv")
sha_ser <- sha(f_ser); sha_ref <- sha(f_ref)
ref <- utils::read.csv(f_ref, colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; stopifnot(nrow(ref) == 26, !anyDuplicated(ref$recorte_principal))
nuc <- as.data.frame(cidade_nucleo()); nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE); ordem <- nuc$CD_RECORTE
stopifnot(length(ordem) == 26, setequal(ordem, ref$recorte_principal))
INI <- as.Date("2012-04-07"); INI_JAN <- as.Date("2012-04-14"); FIM <- as.Date("2024-08-06")
COLS <- c("recorte_principal", "data", "ptb", "tmean_nucleo", "log_z", "log_w", "dia_semana", "feriado_nacional", "carnaval", "moveis",
          "estrato", "janela_principal")
s <- readRDS(f_ser); stopifnot(all(COLS %in% names(s)))
s <- as.data.frame(s)[s$data >= INI & s$data <= FIM, COLS]; rownames(s) <- NULL
n_lin <- as.integer(FIM - INI) + 1L                                     # 4.505 = 4.498 da janela + 7 de aquecimento
stopifnot(all(table(s$recorte_principal)[ordem] == n_lin), !anyNA(s$tmean_nucleo))
jan_ok <- tapply(seq_len(nrow(s)), s$recorte_principal, function(i) {
  x <- s[i, ]; x <- x[order(x$data), ]
  all(diff(x$data) == 1) && identical(x$janela_principal, x$data >= INI_JAN) && sum(x$janela_principal) == 4498L })
stopifnot(all(jan_ok))
log_msg("entradas conferidas: 26 concentrações ×", n_lin, "dias")

# ------------------------------------------------------------------ ajustes
MOTIVOS_FALLBACK <- c("não convergiu", "coeficiente da cross-basis aliasado", "vcov da cross-basis não positiva-definida",
                      "vcov indisponível", "vcov reduzida não positiva-definida")                       # §5, critério 4 (desvio 65a)
spec_principal <- function(rr) f$spec_agudo("ptb", "tmean_nucleo", "janela_principal", 7,
  argvar = list(fun = "ns", knots = c(rr$p10, rr$p75, rr$p90)), arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE),
  offset = "z_w_gama", cen = rr$p50)
spec_fallback <- function(rr) f$spec_agudo("ptb", "tmean_nucleo", "janela_principal", 7,
  argvar = list(fun = "ns", knots = c(rr$p50, rr$p90)), arglag = list(fun = "strata", breaks = c(2, 5), intercept = TRUE),
  offset = "z_w_gama", cen = rr$p50)
elegivel_fallback <- function(r) identical(r$status, "falhou") && !is.na(r$mensagem) && all(strsplit(r$mensagem, "; ", fixed = TRUE)[[1]] %in% MOTIVOS_FALLBACK)
gama_ok <- function(r) is.finite(r$gama) && is.finite(r$ep_gama) && r$ep_gama > 0
res <- list()
for (cd in ordem) {
  x <- s[s$recorte_principal == cd, ]; x <- x[order(x$data), ]; rownames(x) <- NULL
  rr <- ref[ref$recorte_principal == cd, ]
  r1 <- f$ajusta_dlnm(x, spec_principal(rr)); r2 <- NULL; situacao <- "principal"
  if (identical(r1$status, "ok") && !gama_ok(r1)) situacao <- "pendente: γ inválido"
  if (!identical(r1$status, "ok")) {
    if (elegivel_fallback(r1)) {
      r2 <- f$ajusta_dlnm(x, spec_fallback(rr))
      situacao <- if (identical(r2$status, "ok") && gama_ok(r2)) "fallback (decisão pendente para a Fase 3)" else "não estimável (decisão pendente)"
    } else situacao <- "pendente: falha fora do §5, critério 4"
  }
  res[[cd]] <- list(recorte = cd, nome = nome[[cd]], referencia = rr, principal = r1, fallback = r2, situacao = situacao)
  log_msg(nome[[cd]], "|", r1$status, "|", situacao)
}
pend <- vapply(res, function(z) z$situacao != "principal", TRUE)

# ------------------------------------------------------------------ tabelas
dg <- do.call(rbind, lapply(res, function(z) {
  r <- z$principal; bk <- r$boundary_knots
  data.frame(recorte_principal = z$recorte, concentracao = z$nome, situacao = z$situacao, status = r$status, mensagem = r$mensagem,
             convergiu = r$convergiu, dim_cb = r$dim_cb, dim_reduzida = if (is.null(r$reduzida)) NA_integer_ else r$reduzida$dim,
             knot_p10 = z$referencia$p10, knot_p75 = z$referencia$p75, knot_p90 = z$referencia$p90, cen_p50 = z$referencia$p50,
             bk_min = bk[1], bk_max = bk[2], p1_ref = z$referencia$p1, p99_ref = z$referencia$p99,
             p1_p99_dentro_bk = z$referencia$p1 >= bk[1] && z$referencia$p99 <= bk[2],
             dias_janela = r$n$dias_janela, dias_usados = r$n$dias_usados, dias_sem_base_ou_offset = r$n$dias_sem_base_ou_offset,
             dias_removidos_estrato_vazio = r$n$dias_removidos_estrato_vazio, estratos_usados = r$n$estratos_usados,
             estratos_removidos = r$n$estratos_removidos, autovalor_min_cb = r$autovalor_min_cb, autovalor_min_red = r$autovalor_min_red,
             phi = r$phi, gama = r$gama, ep_gama = r$ep_gama, qaic = r$qaic, stringsAsFactors = FALSE)
}))
rownames(dg) <- NULL
pacf_t <- do.call(rbind, lapply(res, function(z) {
  r <- z$principal; if (is.null(r$pacf)) return(NULL)
  p <- unlist(r$pacf[1, paste0("lag", 1:7)]); n <- r$pacf$n; m <- r$n$dias_usados / r$n$estratos_usados; c0 <- -1 / (m - 1)
  data.frame(recorte_principal = z$recorte, concentracao = z$nome, t(p), n = n, limite = r$pacf$limite, fora_literal = r$pacf$fora,
             m_medio = m, centro = c0, fora_recentrada = paste(which(abs(p - c0) > 2 / sqrt(n)), collapse = ","),
             fora_recentrada_bonferroni = paste(which(abs(p - c0) > stats::qnorm(1 - 0.05 / 14) / sqrt(n)), collapse = ","), stringsAsFactors = FALSE)
}))
rownames(pacf_t) <- NULL
longo <- function(qual) do.call(rbind, lapply(res, function(z) {
  do.call(rbind, lapply(c("principal", "fallback"), function(esp) {
    r <- z[[esp]]; if (is.null(r) || !identical(r$status, "ok")) return(NULL)
    cf <- if (qual == "red") r$reduzida$coef else r$coef_cb; V <- if (qual == "red") r$reduzida$vcov else r$vcov_cb; k <- length(cf)
    rbind(data.frame(recorte_principal = z$recorte, especificacao = esp, dim = k, tipo = "coef", i = seq_len(k), j = NA_integer_, valor = unname(cf)),
          data.frame(recorte_principal = z$recorte, especificacao = esp, dim = k, tipo = "vcov", i = rep(seq_len(k), k), j = rep(seq_len(k), each = k), valor = as.vector(V)))
  }))
}))
red_t <- longo("red"); cb_t <- longo("cb")
escreve_csv <- function(df, p) { num <- vapply(df, is.double, TRUE); df[num] <- lapply(df[num], function(v) ifelse(is.na(v), NA, sprintf("%.17g", v)))
  utils::write.csv(df, p, row.names = FALSE, na = "", fileEncoding = "UTF-8") }
saveRDS(list(resultados = res, tag = TAG, tag_objeto = tag_obj, commit_tag = tag_commit, sha_codigo = sha_disco, sha_serie = sha_ser,
             sha_referencias = sha_ref, blas = s_info$BLAS, lapack = s_info$LAPACK, versao_base = v_ini, data = hoje), saidas[1])
escreve_csv(red_t, saidas[2]); escreve_csv(cb_t, saidas[3]); escreve_csv(pacf_t, saidas[4]); escreve_csv(dg, saidas[5])
sha_out <- vapply(saidas, sha, "")

# ------------------------------------------------------------------ resumo nas 26 (C.6)
ok_p <- dg$status == "ok"
n_phi2 <- sum(dg$phi > 2, na.rm = TRUE); tem <- function(x) !is.na(x) & nzchar(x)
n_lit <- sum(tem(pacf_t$fora_literal))
n_rec <- sum(nzchar(pacf_t$fora_recentrada)); n_bonf <- sum(nzchar(pacf_t$fora_recentrada_bonferroni))
PP <- as.matrix(pacf_t[paste0("lag", 1:7)]); nn <- pacf_t$n; cc <- pacf_t$centro               # sinal dos lags sinalizados (desvio 66b)
s_lit <- abs(PP) > 2 / sqrt(nn); s_rec <- abs(PP - cc) > 2 / sqrt(nn); s_bon <- abs(PP - cc) > stats::qnorm(1 - 0.05 / 14) / sqrt(nn)
stopifnot(sum(rowSums(s_lit) > 0) == n_lit, sum(rowSums(s_rec) > 0) == n_rec, sum(rowSums(s_bon) > 0) == n_bonf)
n_fb <- sum(grepl("^fallback", dg$situacao)); n_ne <- sum(grepl("^não estimável", dg$situacao)); n_pend <- sum(pend)
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
fmt_gama <- function(g, e) ifelse(is.finite(g), sprintf("%s (%s)", br(g, 3), br(e, 3)), "NA")
md <- c("# Fase 2, Parte C: primeira etapa do modelo principal nas 26 concentrações", "",
        sprintf("- **Gerado por:** `00_scripts/32_primeira_etapa_principal.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        sprintf("- **Ambiente:** R %s; dlnm %s; gnm %s. BLAS/LAPACK: `%s` / `%s` — de referência (§8; critério do desvio 65d). Semente 20261001, em série.",
                paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("gnm"), s_info$BLAS, s_info$LAPACK),
        sprintf("- **Código:** tag `%s` (objeto `%s`), commit `%s`. SHA-256 no disco = SHA-256 na tag:", TAG, tag_obj, tag_commit),
        sprintf("  - `%s`: `%s`;", arqs_R, sha_disco),
        sprintf("- **Entradas:** `%s` (SHA-256 `%s`) e `%s` (SHA-256 `%s`).", f_ser, sha_ser, f_ref, sha_ref),
        "- **Por que o CSV:** o código canônico da §1.5 calcula os percentis de `tmean_ref` de 2012-01-01 a 2024-12-31, mas a RDS termina em 2024-11-15, e os percentis não podem ser recalculados dela. O CSV foi feito com o código canônico (a conferência da Fase 1 deu diferença 0). Nós p10/p75/p90 e `cen` = p50 vêm das linhas de ano inteiro.",
        sprintf("- **Linhas passadas à função**, por concentração: %s a %s (%s dias: os 7 de aquecimento, de %s a %s, mais a janela principal de 4.498 dias), nada além (§1.5). Os Boundary.knots saem do range de `tmean_nucleo` nesse conjunto.",
                format(INI), format(FIM), br(n_lin), format(INI), format(INI_JAN - 1)),
        "- **Especificação:** `ptb` ~ cross-basis (ns com nós p10/p75/p90 × ns com intercepto e nós `logknots(7, nk = 2)` = 0,982 e 2,622; lag 0–7) + `dia_semana` + `feriado_nacional` + `carnaval` + `moveis` + γ·`log_w`, offset `log_z`, `eliminate` = estrato (concentração × ano × mês), quasi-Poisson. Fallback (só para as falhas do §5, critério 4; desvio 65a): ns p50/p90 e lag em estratos 0–1, 2–4 e 5–7.", "",
        "## Resumo nas 26 (C.6)", "",
        sprintf("- **Status:** %d de 26 com `status = \"ok\"` no principal; fallback em %d; não estimáveis %d; decisões pendentes %d%s.",
                sum(ok_p), n_fb, n_ne, n_pend, if (n_pend) paste0(" (", paste(dg$concentracao[pend], ": ", dg$situacao[pend], collapse = "; "), ")") else ""),
        sprintf("- **φ > 2:** %d de 26 (%s%%). %s", n_phi2, br(100 * n_phi2 / 26, 1),
                if (n_phi2 / 26 > 0.25) "Mais de 25%: a binomial negativa entra como sensibilidade na Fase 4 (§2.1)." else "Não passa de 25%: a binomial negativa não é acionada pela regra da §2.1."),
        sprintf("- **PACF, regra literal da §2.1** (algum lag de 1 a 7 fora de ±2/√n): %d de 26. %s", n_lit,
                if (n_lit > 0) "Pela §2.1, nessas a sensibilidade com resíduos defasados entraria na Fase 4; a regra que vale é decisão pendente do chat (desvio 65c)." else ""),
        sprintf("- **PACF, só descritivo (desvio 65c):** recentrada em −1/(m − 1): %d de 26; recentrada com Bonferroni nos 7 lags: %d de 26. A regra que vale para a Fase 4 é decisão do chat.", n_rec, n_bonf),
        sprintf("- **Sinal dos lags sinalizados** (lags de todas as concentrações): literal %d (%d negativos, %d positivos); recentrada %d (%d acima do centro, %d abaixo); recentrada com Bonferroni %d (%d acima, %d abaixo). Num modelo correto, a PACF fica em torno do centro −1/(m − 1), abaixo de 0.",
                sum(s_lit), sum(s_lit & PP < 0), sum(s_lit & PP > 0), sum(s_rec), sum(s_rec & PP > cc), sum(s_rec & PP < cc), sum(s_bon), sum(s_bon & PP > cc), sum(s_bon & PP < cc)),
        sprintf("- **p1 e p99 (ano inteiro) dentro dos Boundary.knots:** %d de 26 (só reportado; desvio 59).", sum(dg$p1_p99_dentro_bk)), "",
        "## Especificação usada e Boundary.knots, por concentração", "",
        tabela_md(data.frame(Concentração = dg$concentracao, `Nós p10 / p75 / p90 (°C)` = paste(br(dg$knot_p10, 3), br(dg$knot_p75, 3), br(dg$knot_p90, 3), sep = " / "),
                             `cen = p50 (°C)` = br(dg$cen_p50, 3), `Boundary.knots (°C)` = paste(br(dg$bk_min, 3), br(dg$bk_max, 3), sep = " a "),
                             `p1 / p99 ref. (°C)` = paste(br(dg$p1_ref, 3), br(dg$p99_ref, 3), sep = " / "), `Dentro` = ifelse(dg$p1_p99_dentro_bk, "sim", "não"),
                             check.names = FALSE)), "",
        "## Diagnósticos por concentração (principal)", "",
        "γ̂ sai só como diagnóstico, sem interpretação (§3.1).", "",
        tabela_md(data.frame(Concentração = dg$concentracao, Situação = dg$situacao, Convergiu = ifelse(dg$convergiu %in% TRUE, "sim", "não"),
                             `Dim cb / red.` = paste(dg$dim_cb, dg$dim_reduzida, sep = " / "),
                             `Dias usados (janela)` = paste0(br(dg$dias_usados), " (", br(dg$dias_janela), ")"),
                             `Dias sem base/offset` = dg$dias_sem_base_ou_offset, `Estratos usados / removidos` = paste(dg$estratos_usados, dg$estratos_removidos, sep = " / "),
                             `Dias removidos (estrato vazio)` = dg$dias_removidos_estrato_vazio,
                             `Autovalor mín. cb / red.` = paste(formatC(dg$autovalor_min_cb, format = "e", digits = 2), formatC(dg$autovalor_min_red, format = "e", digits = 2), sep = " / "),
                             φ = br(dg$phi, 3), `γ̂ (EP)` = fmt_gama(dg$gama, dg$ep_gama), QAIC = br(dg$qaic, 1), check.names = FALSE)), "",
        "## PACF dos resíduos de deviance, lags 1 a 7 (principal)", "",
        tabela_md(data.frame(Concentração = pacf_t$concentracao,
                             `Lags 1–7` = apply(pacf_t[paste0("lag", 1:7)], 1, function(v) paste(br(as.numeric(v), 3), collapse = "; ")),
                             n = br(pacf_t$n), `±2/√n` = br(pacf_t$limite, 4), `Fora (literal)` = ifelse(tem(pacf_t$fora_literal), pacf_t$fora_literal, ifelse(is.na(pacf_t$fora_literal), "NA", "—")),
                             `−1/(m − 1)` = br(pacf_t$centro, 4), `Fora (recentrada)` = ifelse(nzchar(pacf_t$fora_recentrada), pacf_t$fora_recentrada, "—"),
                             `Fora (recentrada + Bonferroni)` = ifelse(nzchar(pacf_t$fora_recentrada_bonferroni), pacf_t$fora_recentrada_bonferroni, "—"), check.names = FALSE)), "",
        "## Saídas (fora do git; desvio 59)", "",
        sprintf("- `%s`: `%s`;", saidas, sha_out),
        "- Conteúdo: a RDS tem a saída completa da função por concentração (coeficientes e vcov da cross-basis e reduzidos, com a dimensão; atributos da base; γ̂, φ, QAIC, PACF e diagnósticos), sem resíduos, valores ajustados nem série diária; os CSVs têm os coeficientes e as vcov (formato longo, 17 dígitos), a PACF e os diagnósticos.", "",
        "**Ainda não** (Fase 3): RR, curva, MRT e contraste.", "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| ok:", sum(ok_p), "/ 26 | φ>2:", n_phi2, "| PACF literal:", n_lit, "| recentrada:", n_rec, "| Bonferroni:", n_bonf, "| pendentes:", n_pend, "\n")
if (n_pend) quit(status = 2)
