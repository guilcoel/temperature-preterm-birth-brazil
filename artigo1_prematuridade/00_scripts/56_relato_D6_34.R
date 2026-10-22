# 56_relato_D6_34.R — conferência da D6, 3.4, nos dados do A1, depois da tag segunda_etapa-v1.0.1 (entrada 86).
# Só leitura e relato: nenhum número reportado muda. Usa o segunda_etapa.R da v1.0 (igual na v1.0.1) e a função do teste 3
# da v1.0.1 (codigo_compartilhado/tests/teste3_fonte_independente.R).
#   (1) Mesmos números: a meta_curva da curva geral (Y e S da RDS da Fase 2; md do referencias_exposicao) e das
#       lag–respostas p99 e p1 (reduzidos da RDS do 45), rodada de novo, contra a RDS do 45: coef_meta, vcov_meta,
#       pred_media, blup, Psi, heterogeneidade e wald; identical() ou diferença relativa ≤ 1e-10. Qualquer falha: PARADA.
#   (2) Guarda do Wald: gl == ncol(Y) (= 4) nas três meta-análises.
#   (3) Q por coeficiente (receita testada na v1.0.1), nas três (3 × 4), "por coeficiente (não univariado)"; e a
#       heterogeneidade das três, com "sem metapreditores" no lugar de "total".
#   (4) Teste 3 da D2 (errata da D6, 2.2) nas 26 curvas BLUP; controle negativo com fronteiras p1–p99.
#   (5) Autoauditoria com código diferente: GLS à mão para o Q por coeficiente; base ns montada com splines::ns direto
#       (sem onebasis e sem a função do teste 3).
# Só agregados e resultados de modelo: nenhuma série, dia isolado ou coeficiente BLUP por concentração.
# Grava logs/relato_D6_34_<RODADA>.md. Nunca sobrescreve. Numa PARADA, grava o log e sai com quit(status = 1) (83(a4)).
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/56_relato_D6_34.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("relato_D6_34_", rodada, ".md")); stopifnot(!file.exists(arq))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; CC <- file.path("..", "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
sha_git <- function(rev, a) sub(" .*", "", system(paste("git -C", shQuote(REPO), "show", shQuote(paste0(rev, ":", a)), "| shasum -a 256"), intern = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
sci <- function(x, d = 1) formatC(x, format = "e", digits = d)
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")

# ------------------------------------------------------------------ conferências de código (como o 45, l. 44–53)
s_info <- sessionInfo()
if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib")) stop("BLAS/LAPACK fora da referência (§8)")
TAGS <- c("segunda_etapa-v1.0" = "410dd6d6d3d315004f22fd7197c326de77f3c2f4", "segunda_etapa-v1.0.1" = "403b0a2d4b60c425d38cb39fcbef0f7b147891c1")
for (tg in names(TAGS)) if (!identical(git("rev-parse", paste0(tg, "^{commit}")), TAGS[[tg]])) stop("a tag ", tg, " não aponta para o commit esperado")
f_se <- "codigo_compartilhado/R/segunda_etapa.R"; f_t3 <- "codigo_compartilhado/tests/teste3_fonte_independente.R"
for (a in git("ls-tree", "-r", "--name-only", "segunda_etapa-v1.0", "codigo_compartilhado/R/")) if (!identical(sha_git("segunda_etapa-v1.0", a), sha(file.path(REPO, a)))) stop(a, " difere da tag segunda_etapa-v1.0")
if (!identical(sha_git("segunda_etapa-v1.0.1", f_se), sha(file.path(REPO, f_se)))) stop("segunda_etapa.R difere do da v1.0.1")
if (!identical(sha_git("segunda_etapa-v1.0.1", f_t3), sha(file.path(REPO, f_t3)))) stop("teste3_fonte_independente.R difere do da v1.0.1")
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta) })
f <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = f); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f)
source(file.path(CC, "tests", "teste3_fonte_independente.R"))

# ------------------------------------------------------------------ entradas (as do 45, e a RDS do 45 contra o log dele)
ENT <- c(rds2 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", ref = "01_saidas/fase1/referencias_exposicao.csv",
         ser1 = "01_saidas/fase1/serie_ptb_principal.rds", a0 = "01_saidas/fase3/percentis_exposicao_fase3_20261013.csv",
         rds45 = "01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds")
SHA_ENT <- c(rds2 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d", ref = "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467",
             ser1 = "635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917", a0 = "e2bd54e9fc2df3689916331c0db79000b4fd01e1ed3d48f6c536c4a3a099b490")
sha_ent <- vapply(ENT, sha, "")
if (!identical(sha_ent[names(SHA_ENT)], SHA_ENT)) stop("entrada com SHA-256 diferente do registrado")
L45 <- paste(readLines(file.path("logs", "segunda_etapa_fase3_20261013.md"), encoding = "UTF-8"), collapse = "\n")
if (!grepl(sprintf("`%s`: `%s`", ENT[["rds45"]], sha_ent[["rds45"]]), L45, fixed = TRUE)) stop("RDS do 45 com SHA-256 diferente do log do 45")
r45 <- readRDS(ENT[["rds45"]])
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES; stopifnot(identical(r45$ordem, ordem))
rds <- readRDS(ENT[["rds2"]])$resultados; P1 <- lapply(ordem, function(r) rds[[r]]$principal); names(P1) <- ordem; rm(rds)
ref <- utils::read.csv(ENT[["ref"]], colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ordem, ref$recorte_principal), ]; stopifnot(identical(ref$recorte_principal, ordem))
md <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1, row.names = ordem)
Y <- t(vapply(ordem, function(r) unname(P1[[r]]$reduzida$coef), numeric(4))); S <- lapply(ordem, function(r) unname(P1[[r]]$reduzida$vcov))
Yl <- function(Rl) t(vapply(ordem, function(r) Rl[[r]]$coef, numeric(4))); Sl <- function(Rl) lapply(ordem, function(r) Rl[[r]]$vcov)
metas <- list(curva_geral = list(Y = Y, S = S, rds = r45$meta),
              lag_p99 = list(Y = Yl(r45$lagresposta$reduzidos_p99), S = Sl(r45$lagresposta$reduzidos_p99), rds = r45$lagresposta$meta_p99),
              lag_p1 = list(Y = Yl(r45$lagresposta$reduzidos_p1), S = Sl(r45$lagresposta$reduzidos_p1), rds = r45$lagresposta$meta_p1))
log_msg("conferências: ok")

# ------------------------------------------------------------------ (1) mesmos números
nums <- function(z) { if (!is.list(z)) z <- list(z); unname(rapply(z, function(e) if (is.numeric(e)) as.numeric(e) else NULL, how = "unlist")) }
compara <- function(a, b) { if (identical(a, b)) return(c(identico = 1, dif_rel = 0))
  x <- nums(a); y <- nums(b); if (length(x) != length(y)) return(c(identico = 0, dif_rel = Inf))
  c(identico = 0, dif_rel = if (all(x == y)) 0 else max(abs(x - y)) / max(abs(y))) }
CAMPOS <- c("coef_meta", "vcov_meta", "pred_media", "blup", "Psi", "heterogeneidade", "wald")
novo <- lapply(metas, function(m) f$meta_curva(m$Y, m$S, md))
cmp1 <- do.call(rbind, lapply(names(metas), function(k) do.call(rbind, lapply(CAMPOS, function(cp) {
  v <- compara(novo[[k]][[cp]], metas[[k]]$rds[[cp]]); data.frame(meta = k, campo = cp, identico = v[["identico"]] == 1, dif_rel = v[["dif_rel"]], stringsAsFactors = FALSE) }))))
ok1 <- all(cmp1$identico | cmp1$dif_rel <= 1e-10) && all(vapply(names(metas), function(k) identical(novo[[k]]$status, "ok") && identical(novo[[k]]$metodo, metas[[k]]$rds$metodo) && identical(novo[[k]]$bscov, metas[[k]]$rds$bscov), TRUE))
log_msg("(1) mesmos números:", if (ok1) "ok" else "FALHOU")

# ------------------------------------------------------------------ (2) guarda do Wald
gl_ok <- vapply(names(metas), function(k) all(metas[[k]]$rds$wald$gl == ncol(metas[[k]]$Y)) && all(novo[[k]]$wald$gl == ncol(metas[[k]]$Y)), TRUE)
log_msg("(2) gl == 4 nos três Wald:", paste(gl_ok, collapse = ", "))

# ------------------------------------------------------------------ (3) Q por coeficiente (receita da v1.0.1) e heterogeneidade
qcoef <- do.call(rbind, lapply(names(metas), function(k) { m <- metas[[k]]; Yd <- unname(m$Y)
  fit <- mixmeta::mixmeta(Yd ~ media + amplitude, S = m$S, data = md, method = m$rds$metodo, bscov = m$rds$bscov)
  if (!identical(stats::coef(fit), m$rds$coef_meta)) stop("receita do Q por coeficiente: coef não é identical() ao coef_meta em ", k)
  q <- mixmeta::qtest(fit)
  data.frame(meta = k, coeficiente = paste0("b", 1:4), Q = unname(q$Q[-1]), gl = unname(q$df[-1]), p = unname(q$pvalue[-1]),
             I2 = pmax(0, (unname(q$Q[-1]) - unname(q$df[-1])) / unname(q$Q[-1])) * 100, stringsAsFactors = FALSE) }))
ok3 <- all(qcoef$gl == 23L)
het <- do.call(rbind, lapply(names(metas), function(k) do.call(rbind, lapply(c("residual", "total"), function(tp) { h <- metas[[k]]$rds$heterogeneidade[[tp]]
  data.frame(meta = k, tipo = if (tp == "total") "sem metapreditores" else "residual (com metapreditores)", Q = h$Q, gl = h$df, p = h$p, I2 = h$I2, stringsAsFactors = FALSE) }))))

# ------------------------------------------------------------------ (4) teste 3 nas 26 curvas BLUP
INI <- as.Date("2012-04-07"); FIM <- as.Date("2024-08-06")
s <- readRDS(ENT[["ser1"]]); s <- as.data.frame(s)[s$data >= INI & s$data <= FIM, c("recorte_principal", "data", "tmean_nucleo")]
x_cb <- lapply(ordem, function(r) { z <- s[s$recorte_principal == r, ]; z <- z[order(z$data), ]; stopifnot(nrow(z) == 4505L, all(diff(z$data) == 1)); z$tmean_nucleo }); names(x_cb) <- ordem; rm(s)
ex <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_nucleo")))   # tref do 45
ex$data <- as.Date(ex$data); ex <- ex[ex$data >= as.Date("2012-01-01") & ex$data <= as.Date("2024-12-31"), ]
tref <- lapply(ordem, function(r) { z <- ex[ex$recorte_principal == r, ]; z <- z[order(z$data), ]; stopifnot(nrow(z) == 4749L, all(diff(z$data) == 1)); z$tmean_nucleo }); names(tref) <- ordem; rm(ex)
PCT <- c("p99", "p1", "p95", "p90", "p10", "p5"); tb45 <- r45$tmr[r45$tmr$nivel == "blup", ]
t3 <- do.call(rbind, lapply(ordem, function(r) { g <- r45$grade[r, ]; x <- c(f$grade_tmr(g[["p1"]], g[["p99"]]), unname(g[PCT]))
  cen <- tb45$tmr[tb45$recorte_principal == r]
  v <- teste3_fonte_independente(f$curva, r45$blup[[r]]$coef, P1[[r]]$base$argvar, x, cen, tref[[r]], c(0.10, 0.75, 0.90), x_cb[[r]], fun = "ns")
  data.frame(recorte_principal = r, dif = v$dif, dif_nos = v$dif_nos, dif_fronteiras = v$dif_fronteiras, controle_p1p99 = v$dif_controle_p1p99,
             controle_serie = v$dif_controle_serie, amplitudes_diferem = !identical(range(x_cb[[r]]), range(tref[[r]])), stringsAsFactors = FALSE) }))
ok4 <- all(t3$dif <= 1e-8) && all(t3$controle_p1p99 > 1e-8)
log_msg("(4) teste 3: máx dif", format(max(t3$dif)), "| controle p1–p99 > 1e-8 em", sum(t3$controle_p1p99 > 1e-8), "de 26")

# ------------------------------------------------------------------ (5) autoauditoria com código diferente
aa_q <- do.call(rbind, lapply(names(metas), function(k) { m <- metas[[k]]; Yd <- unname(m$Y); X <- cbind(1, md$media, md$amplitude); n <- nrow(X); kk <- ncol(Yd); p <- ncol(X)
  A <- matrix(0, p * kk, p * kk); bb <- numeric(p * kk)
  for (i in seq_len(n)) { Xi <- X[i, , drop = FALSE] %x% diag(kk); Si <- solve(m$S[[i]]); A <- A + t(Xi) %*% Si %*% Xi; bb <- bb + t(Xi) %*% Si %*% Yd[i, ] }
  beta <- matrix(solve(A, bb), ncol = kk, byrow = TRUE)
  Qm <- vapply(seq_len(kk), function(j) sum((Yd[, j] - X %*% beta[, j])^2 / vapply(m$S, function(s0) s0[j, j], 0)), 0)
  data.frame(meta = k, dif_rel_Q = max(abs(Qm - qcoef$Q[qcoef$meta == k]) / Qm), gl_mao = n - p, stringsAsFactors = FALSE) }))
aa_b <- vapply(ordem, function(r) { g <- r45$grade[r, ]; x <- c(f$grade_tmr(g[["p1"]], g[["p99"]]), unname(g[PCT])); cen <- tb45$tmr[tb45$recorte_principal == r]
  nos <- unname(stats::quantile(tref[[r]], c(0.10, 0.75, 0.90), type = 7)); bk <- range(x_cb[[r]])
  B <- splines::ns(c(x, cen), knots = nos, Boundary.knots = bk); lr <- drop((B[seq_along(x), , drop = FALSE] - matrix(B[length(x) + 1, ], length(x), ncol(B), byrow = TRUE)) %*% r45$blup[[r]]$coef)
  max(abs(lr - f$curva(r45$blup[[r]]$coef, diag(4), P1[[r]]$base$argvar, x, cen)$logrr)) }, 0)
ok5 <- all(aa_q$dif_rel_Q <= 1e-8) && all(aa_q$gl_mao == 23) && all(aa_b <= 1e-8)
log_msg("(5) autoauditoria:", if (ok5) "ok" else "DIFERENTE")

# ------------------------------------------------------------------ log
para <- !(ok1 && all(gl_ok) && ok3 && ok4 && ok5)
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
rot <- c(curva_geral = "Curva geral", lag_p99 = "Lag–resposta no p99", lag_p1 = "Lag–resposta no p1")
md_txt <- c("# Conferência da D6, 3.4, nos dados do A1 (segunda_etapa v1.0.1, só de testes; entrada 86)", "",
  sprintf("- **Gerado por:** `00_scripts/56_relato_D6_34.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), rodada, v_ini),
  sprintf("- **Ambiente:** R %s; dlnm %s; gnm %s; mixmeta %s. BLAS/LAPACK: `%s` / `%s` (referência).", paste(R.version$major, R.version$minor, sep = "."),
          packageVersion("dlnm"), packageVersion("gnm"), packageVersion("mixmeta"), s_info$BLAS, s_info$LAPACK),
  "- **Código:** tags `segunda_etapa-v1.0` (→ `410dd6d`) e `segunda_etapa-v1.0.1` (→ `403b0a2`) conferidas; `codigo_compartilhado/R/` no disco igual ao da v1.0; o `segunda_etapa.R` é o mesmo nas duas tags; a função do teste 3 é a da v1.0.1.",
  "- **Entradas (SHA-256; as do 45 e a RDS do 45, contra o log do 45):**", sprintf("  - `%s`: `%s`;", ENT, sha_ent),
  "- **Só agregados:** diferenças máximas, contagens, Q, gl, p e I². Nenhuma série, dia isolado ou coeficiente BLUP por concentração.", "",
  "## (1) Mesmos números (meta_curva rodada de novo contra a RDS do 45)", "",
  tabela_md(data.frame(`Meta-análise` = rot[cmp1$meta], Campo = cmp1$campo, `identical()` = ifelse(cmp1$identico, "sim", "não"),
                       `Diferença relativa máxima` = ifelse(cmp1$identico, "0", sci(cmp1$dif_rel)), check.names = FALSE)), "",
  sprintf("- **Critério** (identical() ou diferença relativa ≤ 1e-10, com o mesmo método e Ψ nas três: %s): %s.", paste(sprintf("%s/%s", vapply(metas, function(m) m$rds$metodo, ""), vapply(metas, function(m) m$rds$bscov, "")), collapse = "; "), if (ok1) "cumprido" else "NÃO cumprido"), "",
  "## (2) Guarda do Wald", "",
  sprintf("- `stopifnot(all(m$wald$gl == ncol(Y)))`, com `ncol(Y) = 4`: curva geral %s; lag–resposta no p99 %s; no p1 %s.",
          if (gl_ok[["curva_geral"]]) "ok" else "FALHOU", if (gl_ok[["lag_p99"]]) "ok" else "FALHOU", if (gl_ok[["lag_p1"]]) "ok" else "FALHOU"), "",
  "## (3) Heterogeneidade e Q por coeficiente", "",
  "Heterogeneidade das três meta-análises (\"sem metapreditores\" no lugar do antigo \"total\"; nas tabelas de `logs/segunda_etapa_fase3_20261013.md`, \"total\" lê-se \"sem metapreditores\"):", "",
  tabela_md(data.frame(`Meta-análise` = rot[het$meta], Tipo = het$tipo, Q = br(het$Q, 2), gl = het$gl, p = formatC(het$p, format = "g", digits = 3, decimal.mark = ","), `I² (%)` = br(het$I2, 1), check.names = FALSE)), "",
  "Q por coeficiente (não univariado): `qtest()` do `mixmeta` reajustado com `unname(Y)` e o mesmo método e Ψ (coef `identical()` ao `coef_meta` nas três); usa só a diagonal de cada S_i e os coeficientes do GLS multivariado de efeitos fixos; gl = n − termos = 23.", "",
  tabela_md(data.frame(`Meta-análise` = rot[qcoef$meta], Coeficiente = qcoef$coeficiente, `Q por coeficiente (não univariado)` = br(qcoef$Q, 2), gl = qcoef$gl,
                       p = formatC(qcoef$p, format = "g", digits = 3, decimal.mark = ","), `I² (%)` = br(qcoef$I2, 1), check.names = FALSE)), "",
  "## (4) Teste 3 da D2 (errata da D6, 2.2) nas 26 curvas BLUP", "",
  "- serie_nos = `tmean_nucleo` de 2012-01-01 a 2024-12-31 (a `tref` do 45, 4.749 dias), probs_nos = p10/p75/p90; x_cb = as 4.505 linhas da série do 45; x = `grade_tmr(p1, p99)` da concentração mais os 6 percentis dos contrastes; cen = TMR BLUP da RDS do 45.",
  sprintf("- **Diferença máxima** entre a fonte independente e a `curva()`: %s (critério ≤ 1e-8 nas 26: %s).", sci(max(t3$dif)), if (all(t3$dif <= 1e-8)) "cumprido" else "NÃO"),
  sprintf("- **Controle negativo** (fronteiras p1–p99 da serie_nos): > 1e-8 em %d de 26 (mínimo %s).", sum(t3$controle_p1p99 > 1e-8), sci(min(t3$controle_p1p99), 2)),
  sprintf("- **À parte:** máximo de `dif_nos` (nós da `argvar`, do CSV da Fase 1, contra `quantile(tref)`): %s; máximo de `dif_fronteiras` (`argvar$Boundary.knots` contra `range(x_cb)`): %s.", sci(max(t3$dif_nos)), sci(max(t3$dif_fronteiras))),
  sprintf("- **Informativo, sem critério:** `range(x_cb) ≠ range(serie_nos)` em %d de 26; máximo de `dif_controle_serie`: %s.", sum(t3$amplitudes_diferem), sci(max(t3$controle_serie), 2)), "",
  "## (5) Autoauditoria (código diferente)", "",
  sprintf("- **Q por coeficiente pelo GLS à mão** (vec por unidade, X_i ⊗ I_4): diferença relativa máxima contra o `qtest` %s; gl à mão = 23 nas três.", sci(max(aa_q$dif_rel_Q))),
  sprintf("- **Base ns montada com `splines::ns` direto** (sem `onebasis` e sem a função do teste 3), nós de `quantile(tref)` e fronteiras `range(x_cb)`: diferença máxima contra a `curva()` nas 26 = %s.", sci(max(aa_b))), "",
  "## Resultado", "",
  if (para) "**PARADA.** Algum critério não foi cumprido (ver acima). Nada foi corrigido." else
    "**Sem parada.** A `meta_curva` reproduz a RDS do 45 nas três meta-análises; os três Wald têm 4 gl; o Q por coeficiente sai pela receita testada; o teste 3 passa nas 26, com o controle negativo em 26 de 26. Nenhum número reportado muda.", "",
  sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md_txt, arq, useBytes = TRUE)
cat("gravado:", arq, "|", if (para) "PARADA" else "sem parada", "\n")
if (para) quit(status = 1)
