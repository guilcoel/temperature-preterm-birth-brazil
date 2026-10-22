# 45_segunda_etapa_principal.R — Fase 3, Parte C: segunda etapa do modelo principal com os dados reais (C1 a C4) e a
# conferência da cross-basis (C6), com o código das tags ajusta_dlnm-v1.0 e segunda_etapa-v1.0. Escolhas no desvio 77.
# Antes de ajustar, confere: o SHA-256 do código contra as duas tags e o da attrdl.R; o BLAS e o LAPACK de referência;
# o SHA-256 das entradas; os CSV da Fase 2 iguais à RDS. Depois, antes de qualquer curva (C6): a cross-basis pelo caminho
# da Fase 2 e pela monta_cb com a argvar e a arglag da RDS, iguais entre si, com os atributos identical() aos da RDS.
# Qualquer falha para o script.
#   - C1: meta_curva dos 4 coeficientes reduzidos (média e amplitude de ano inteiro como metapreditores).
#   - C2: base_combinada (D2), eixo médio da A0, curva na média dos metapreditores, TMR combinada (grade x1–x99,
#         bootstrap com i = 0, fronteira pelo índice), q_TMR no eixo e contrastes em x99, x1, x95, x90, x10 e x5.
#   - C3: por concentração, TMR BLUP na grade p1–p99 da concentração, bootstrap com i = posição na ordem, contrastes.
#   - C4: lag–resposta (D4(b)): reduz_var no p99 e no p1, centro pelo q_TMR (ou p50 na fronteira), meta-análise e
#         curva nos lags 0–7 de 0,1 em 0,1; soma dos lags 0–7.
# Só resultados de modelo e agregados por concentração saem no log; nenhuma série diária, resíduo ou valor ajustado.
# Grava logs/segunda_etapa_fase3_<FASE3_DATA>.md e 01_saidas/fase3/*. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/45_segunda_etapa_principal.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; CC <- file.path("..", "codigo_compartilhado")
arq <- file.path("logs", paste0("segunda_etapa_fase3_", hoje, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase3"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
nomes_out <- c(rds = "segunda_etapa_principal", meta = "meta_curva", blups = "blups", tmr = "tmr", contrastes = "contrastes",
               curva = "curva_combinada", lag = "lagresposta", lag_meta = "lagresposta_meta")
saidas <- setNames(file.path(OUT, paste0(nomes_out, "_fase3_", hoje, ifelse(names(nomes_out) == "rds", ".rds", ".csv"))), names(nomes_out))
stopifnot(!any(file.exists(saidas)))
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
ic <- function(a, b, d = 3) sprintf("%s (%s a %s)", br(a[1], d), br(b[1], d), br(b[2], d))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
escreve_csv <- function(df, p) { num <- vapply(df, is.double, TRUE); df[num] <- lapply(df[num], function(v) ifelse(is.na(v), NA, sprintf("%.17g", v)))
  utils::write.csv(df, p, row.names = FALSE, na = "", fileEncoding = "UTF-8") }

# ------------------------------------------------------------------ BLAS de referência (§8; desvio 65d)
s_info <- sessionInfo()
if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib"))
  stop("BLAS/LAPACK fora da referência (§8): ", s_info$BLAS, " / ", s_info$LAPACK)

# ------------------------------------------------------------------ código = as duas tags; attrdl.R
TAGS <- c("ajusta_dlnm-v1.0" = "caf5022f9a655877d8e3931dd3d02d7dce429fe5", "segunda_etapa-v1.0" = "410dd6d6d3d315004f22fd7197c326de77f3c2f4")
sha_tag <- list()
for (tg in names(TAGS)) {
  if (!identical(git("rev-parse", paste0(tg, "^{commit}")), TAGS[[tg]])) stop("a tag ", tg, " não aponta para o commit esperado")
  arqs_R <- git("ls-tree", "-r", "--name-only", tg, "codigo_compartilhado/R/")
  st <- vapply(arqs_R, function(a) sub(" .*", "", system(paste("git -C", shQuote(REPO), "show", shQuote(paste0(tg, ":", a)), "| shasum -a 256"), intern = TRUE)), "")
  sd <- vapply(arqs_R, function(a) sha(file.path(REPO, a)), "")
  if (!identical(unname(st), unname(sd))) stop("codigo_compartilhado/R/ no disco difere da tag ", tg)
  sha_tag[[tg]] <- sd
}
f_at <- file.path(CC, "inst", "terceiros", "attrdl.R"); SHA_ATTRDL <- "d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d"
if (!identical(sha(f_at), SHA_ATTRDL)) stop("attrdl.R com SHA-256 diferente do registrado")
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta) })
f <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = f); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f)

# ------------------------------------------------------------------ entradas (SHA-256 contra os logs que as geraram)
ENT <- c(rds2 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", red = "01_saidas/fase2/reduzida_coef_vcov_fase2_20261010.csv",
         cbc = "01_saidas/fase2/crossbasis_coef_vcov_fase2_20261010.csv", ref = "01_saidas/fase1/referencias_exposicao.csv",
         ser1 = "01_saidas/fase1/serie_ptb_principal.rds", a0 = "01_saidas/fase3/percentis_exposicao_fase3_20261013.csv")
SHA_ENT <- c(rds2 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d", red = "50f58701005f9cbaf722f5043844f0e6680be5717b011419b2b3b4b688e58c4d",
             cbc = "8eed876c0bc0983705305042324c79ab1f0d619a41a97d8139503b73957e4ddd", ref = "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467",
             ser1 = "635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917", a0 = "e2bd54e9fc2df3689916331c0db79000b4fd01e1ed3d48f6c536c4a3a099b490")
sha_ent <- vapply(ENT, sha, "")
if (!identical(sha_ent, SHA_ENT)) stop("entrada com SHA-256 diferente do registrado: ", paste(names(SHA_ENT)[sha_ent != SHA_ENT], collapse = ", "))
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES
nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE); idx <- setNames(f$indice_concentracao(ordem), ordem)
rds <- readRDS(ENT[["rds2"]])$resultados; stopifnot(identical(names(rds)[order(match(names(rds), ordem))], ordem))
P1 <- lapply(ordem, function(r) rds[[r]]$principal); names(P1) <- ordem
if (!all(vapply(rds[ordem], `[[`, "", "situacao") == "principal") || !all(vapply(P1, `[[`, "", "status") == "ok")) stop("concentração fora do modelo principal")
if (!all(vapply(P1, function(p) p$reduzida$dim, 0L) == 4L)) stop("coeficientes reduzidos com dimensão diferente de 4")
le_longo <- function(p) { d <- utils::read.csv(p, colClasses = c(recorte_principal = "character", valor = "character")); d[d$especificacao == "principal", ] }
txt17 <- function(v) sprintf("%.17g", as.numeric(v))                    # o CSV foi gravado assim: igualdade exata no texto (a leitura de texto pode errar 1 ulp)
red_t <- le_longo(ENT[["red"]]); cb_t <- le_longo(ENT[["cbc"]])
csv_ok <- all(vapply(ordem, function(r) {
  pr <- P1[[r]]; a <- red_t[red_t$recorte_principal == r, ]; b <- cb_t[cb_t$recorte_principal == r, ]
  identical(a$valor[a$tipo == "coef"], txt17(pr$reduzida$coef)) && identical(a$valor[a$tipo == "vcov"], txt17(pr$reduzida$vcov)) &&
    identical(b$valor[b$tipo == "coef"], txt17(pr$coef_cb)) && identical(b$valor[b$tipo == "vcov"], txt17(pr$vcov_cb)) }, TRUE))
if (!csv_ok) stop("CSV da Fase 2 diferentes da RDS")
ref <- utils::read.csv(ENT[["ref"]], colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ordem, ref$recorte_principal), ]; stopifnot(identical(ref$recorte_principal, ordem))
gr <- utils::read.csv(ENT[["a0"]], colClasses = c(recorte_principal = "character", valor = "character")); gr$valor_txt <- gr$valor; gr$valor <- as.numeric(gr$valor)
prob <- function(rot) as.numeric(sub(",", ".", sub("^p", "", rot), fixed = TRUE)) / 100
ez <- gr[gr$recorte_principal == "eixo_medio", ]; ez <- ez[order(prob(ez$rotulo)), ]
eixo <- setNames(ez$valor, ez$rotulo); eixo_p <- prob(ez$rotulo); stopifnot(length(eixo) == 101, !is.unsorted(eixo, strictly = TRUE))
grade <- t(vapply(ordem, function(r) { z <- gr[gr$recorte_principal == r, ]; z <- z[order(prob(z$rotulo)), ]; stopifnot(identical(z$rotulo, ez$rotulo)); setNames(z$valor, z$rotulo) }, numeric(101)))
INI <- as.Date("2012-04-07"); INI_JAN <- as.Date("2012-04-14"); FIM <- as.Date("2024-08-06")
s <- readRDS(ENT[["ser1"]]); s <- as.data.frame(s)[s$data >= INI & s$data <= FIM, c("recorte_principal", "data", "tmean_nucleo", "janela_principal")]
serie <- lapply(ordem, function(r) { z <- s[s$recorte_principal == r, ]; z <- z[order(z$data), ]
  stopifnot(nrow(z) == 4505L, all(diff(z$data) == 1), identical(z$janela_principal, z$data >= INI_JAN), !anyNA(z$tmean_nucleo)); z }); names(serie) <- ordem; rm(s)
ex <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_nucleo")))   # tmean_ref da C4, como no 40
ex$data <- as.Date(ex$data); ex <- ex[ex$data >= as.Date("2012-01-01") & ex$data <= as.Date("2024-12-31"), ]
tref <- lapply(ordem, function(r) { z <- ex[ex$recorte_principal == r, ]; z <- z[order(z$data), ]; stopifnot(nrow(z) == 4749L, all(diff(z$data) == 1), !anyNA(z$tmean_nucleo)); z$tmean_nucleo })
names(tref) <- ordem; rm(ex)
tref_ok <- all(vapply(ordem, function(r) { z <- gr[gr$recorte_principal == r, ]; z <- z[order(prob(z$rotulo)), ]
  identical(txt17(stats::quantile(tref[[r]], eixo_p, type = 7, names = FALSE)), z$valor_txt) }, TRUE))
if (!tref_ok) stop("a tmean de 2012–2024 não reproduz a grade da A0")
log_msg("conferências de código, BLAS e entradas: ok")

# ------------------------------------------------------------------ C6: cross-basis remontada = a da Fase 2 (antes de qualquer curva)
ATR <- c("argvar", "arglag", "lag", "range", "df")
c6 <- do.call(rbind, lapply(ordem, function(r) {
  z <- serie[[r]]; rr <- ref[ref$recorte_principal == r, ]; b <- P1[[r]]$base
  cbA <- dlnm::crossbasis(z$tmean_nucleo, lag = 7, argvar = list(fun = "ns", knots = c(rr$p10, rr$p75, rr$p90)),
                          arglag = list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE))
  cbB <- f$monta_cb(z$tmean_nucleo, z$data, b$argvar, b$arglag, lag = 7)
  A <- unclass(cbA); B <- unclass(cbB); attributes(A) <- attributes(B) <- list(dim = dim(B))
  na_igual <- identical(is.na(A), is.na(B)); d <- max(abs(A - B), na.rm = TRUE)
  atr <- all(vapply(ATR, function(a) identical(attr(cbA, a), b[[a]]) && identical(attr(cbB, a), b[[a]]), TRUE))
  data.frame(recorte_principal = r, dif_max = d, na_igual = na_igual, atributos_identicos = atr, stringsAsFactors = FALSE)
}))
c6_ok <- all(c6$na_igual) && all(c6$dif_max <= 1e-12) && all(c6$atributos_identicos)
if (!c6_ok) stop("C6: a cross-basis remontada não bate com a da Fase 2; parar antes de qualquer curva")
log_msg("C6: cross-basis remontada igual à da Fase 2 nas 26 (diferença máxima", format(max(c6$dif_max)), ")")

# ------------------------------------------------------------------ C1: meta-análise da curva geral
md <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1, row.names = ordem)
Y <- t(vapply(ordem, function(r) unname(P1[[r]]$reduzida$coef), numeric(4))); S <- lapply(ordem, function(r) unname(P1[[r]]$reduzida$vcov))
mc <- f$meta_curva(Y, S, md); if (mc$status != "ok") stop("C1: meta_curva falhou: ", paste(mc$tentativas, collapse = "; "))
log_msg("C1:", mc$metodo, "/", mc$bscov)
blup <- setNames(mc$blup, ordem)

# ------------------------------------------------------------------ C2: curva combinada e TMR combinada
argvars <- lapply(ordem, function(r) P1[[r]]$base$argvar); base <- f$base_combinada(argvars)
pc <- mc$pred_media$coef; pv <- mc$pred_media$vcov
tc <- f$busca_tmr(pc, base, eixo[["p1"]], eixo[["p99"]], eixo[["p10"]], eixo[["p90"]], eixo[["p50"]])
bc <- f$boot_tmr(pc, pv, base, eixo[["p1"]], eixo[["p99"]], i = 0)
q_tmr <- f$posicao_no_eixo(tc$tmr, unname(eixo), eixo_p)
PCT <- c("p99", "p1", "p95", "p90", "p10", "p5")
cc <- f$curva(pc, pv, base, unname(eixo[PCT]), tc$tmr)
contr_c <- data.frame(nivel = "combinada", recorte_principal = "combinada", percentil = PCT, temperatura = unname(eixo[PCT]), cen = tc$tmr,
                      rr = cc$rr, rr_li = cc$rr_li, rr_ls = cc$rr_ls, logrr = cc$logrr, ep = cc$ep, stringsAsFactors = FALSE)
curva_c <- cbind(data.frame(rotulo = names(eixo), probabilidade = eixo_p), f$curva(pc, pv, base, unname(eixo), tc$tmr))
log_msg("C2: TMR combinada", tc$tmr, "°C; fronteira:", tc$fronteira)

# ------------------------------------------------------------------ C3: curvas BLUP e TMR por concentração
tmr_l <- list(); contr_l <- list()
for (r in ordem) {
  av <- P1[[r]]$base$argvar; g <- grade[r, ]; b <- blup[[r]]
  tb <- f$busca_tmr(b$coef, av, g[["p1"]], g[["p99"]], g[["p10"]], g[["p90"]], g[["p50"]])
  bb <- f$boot_tmr(b$coef, b$vcov, av, g[["p1"]], g[["p99"]], i = idx[[r]])
  q <- if (!is.unsorted(unname(g), strictly = TRUE)) f$posicao_no_eixo(tb$tmr, unname(g), eixo_p) else NA_real_   # percentis empatados: sem interpolação
  gg <- f$grade_tmr(g[["p1"]], g[["p99"]])
  tmr_l[[r]] <- data.frame(nivel = "blup", recorte_principal = r, concentracao = nome[[r]], i = idx[[r]], tmr = tb$tmr, percentil_tmr = q, fronteira = tb$fronteira,
                           tmr_p10_p90 = tb$tmr_p10_p90, ic_li = bb$ic[1], ic_ls = bb$ic[2], motivo_ic = bb$motivo, x_inf = g[["p1"]], x_sup = g[["p99"]],
                           n_grade = tb$n_grade, prop_sorteios_x_inf = mean(bb$tmr_sim == gg[1]), prop_sorteios_x_sup = mean(bb$tmr_sim == gg[length(gg)]), stringsAsFactors = FALSE)
  cv <- f$curva(b$coef, b$vcov, av, unname(g[PCT]), tb$tmr)
  contr_l[[r]] <- data.frame(nivel = "blup", recorte_principal = r, percentil = PCT, temperatura = unname(g[PCT]), cen = tb$tmr,
                             rr = cv$rr, rr_li = cv$rr_li, rr_ls = cv$rr_ls, logrr = cv$logrr, ep = cv$ep, stringsAsFactors = FALSE)
  if (tb$fronteira) { cm <- f$curva(b$coef, b$vcov, av, unname(g[PCT]), g[["p50"]])          # §7 e A1.4: na fronteira, também contra a mediana (só reportado; D4(g))
    contr_l[[paste(r, "mediana")]] <- data.frame(nivel = "blup_mediana", recorte_principal = r, percentil = PCT, temperatura = unname(g[PCT]), cen = g[["p50"]],
                                                 rr = cm$rr, rr_li = cm$rr_li, rr_ls = cm$rr_ls, logrr = cm$logrr, ep = cm$ep, stringsAsFactors = FALSE) }
}
tmr_c <- data.frame(nivel = "combinada", recorte_principal = "combinada", concentracao = "combinada", i = 0L, tmr = tc$tmr, percentil_tmr = q_tmr,
                    fronteira = tc$fronteira, tmr_p10_p90 = tc$tmr_p10_p90, ic_li = bc$ic[1], ic_ls = bc$ic[2], motivo_ic = bc$motivo,
                    x_inf = eixo[["p1"]], x_sup = eixo[["p99"]], n_grade = tc$n_grade, prop_sorteios_x_inf = mean(bc$tmr_sim == f$grade_tmr(eixo[["p1"]], eixo[["p99"]])[1]),
                    prop_sorteios_x_sup = mean(bc$tmr_sim == utils::tail(f$grade_tmr(eixo[["p1"]], eixo[["p99"]]), 1)), stringsAsFactors = FALSE)
tmr_t <- rbind(tmr_c, do.call(rbind, tmr_l)); rownames(tmr_t) <- NULL
contr_t <- rbind(contr_c, do.call(rbind, contr_l)); rownames(contr_t) <- NULL
log_msg("C3: TMR BLUP nas 26; na fronteira:", sum(tmr_t$fronteira[tmr_t$nivel == "blup"]))

# ------------------------------------------------------------------ C4: lag–resposta combinada (D4(b))
al <- P1[[ordem[1]]]$base$arglag; stopifnot(all(vapply(ordem, function(r) identical(P1[[r]]$base$arglag, al), TRUE)))
lr_unid <- list(); R99 <- R01 <- list()
for (r in ordem) {
  z <- serie[[r]]; b <- P1[[r]]; g <- grade[r, ]
  cen <- f$centro_lagresposta(tref[[r]], q_tmr, tc$fronteira)
  cb <- f$monta_cb(z$tmean_nucleo, z$data, b$base$argvar, b$base$arglag, lag = 7)
  R99[[r]] <- f$reduz_var(cb, unname(b$coef_cb), unname(b$vcov_cb), g[["p99"]], cen)
  R01[[r]] <- f$reduz_var(cb, unname(b$coef_cb), unname(b$vcov_cb), g[["p1"]], cen)
  lr_unid[[r]] <- data.frame(recorte_principal = r, centro = cen, p99 = g[["p99"]], p1 = g[["p1"]], stringsAsFactors = FALSE)
}
lr_unid <- do.call(rbind, lr_unid); rownames(lr_unid) <- NULL
meta_lag <- function(Rl) { m <- f$meta_curva(t(vapply(ordem, function(r) Rl[[r]]$coef, numeric(4))), lapply(ordem, function(r) Rl[[r]]$vcov), md)
  if (m$status != "ok") stop("C4: meta_curva da lag–resposta falhou: ", paste(m$tentativas, collapse = "; ")); m }
m99 <- meta_lag(R99); m01 <- meta_lag(R01)
lag_t <- rbind(cbind(valor = "p99", f$curva_lag(m99$pred_media$coef, m99$pred_media$vcov, al)), cbind(valor = "p1", f$curva_lag(m01$pred_media$coef, m01$pred_media$vcov, al)))
soma <- rbind(p99 = f$soma_lags(m99$pred_media$coef, m99$pred_media$vcov, al), p1 = f$soma_lags(m01$pred_media$coef, m01$pred_media$vcov, al))
log_msg("C4: lag–resposta p99", m99$metodo, "/", m99$bscov, "; p1", m01$metodo, "/", m01$bscov)

# ------------------------------------------------------------------ saídas
het <- function(m, rot) do.call(rbind, lapply(c("residual", "total"), function(k) { h <- m$heterogeneidade[[k]]
  data.frame(meta = rot, tipo = k, Q = if (is.null(h)) NA else h$Q, gl = if (is.null(h)) NA else h$df, p = if (is.null(h)) NA else h$p, I2 = if (is.null(h)) NA else h$I2) }))
meta_t <- rbind(
  data.frame(meta = "curva_geral", quantidade = "coeficiente", nome = names(mc$coef_meta), valor = unname(mc$coef_meta), ep = sqrt(diag(mc$vcov_meta)), stringsAsFactors = FALSE),
  data.frame(meta = "curva_geral", quantidade = "psi", nome = paste0("psi_", rep(1:4, 4), "_", rep(1:4, each = 4)), valor = as.vector(mc$Psi), ep = NA_real_, stringsAsFactors = FALSE),
  data.frame(meta = "curva_geral", quantidade = "predicao_media", nome = paste0("b", 1:4), valor = pc, ep = sqrt(diag(pv)), stringsAsFactors = FALSE))
blups_t <- do.call(rbind, lapply(ordem, function(r) data.frame(recorte_principal = r, concentracao = nome[[r]], coeficiente = paste0("b", 1:4),
                                                               blup = blup[[r]]$coef, ep = sqrt(diag(blup[[r]]$vcov)), primeira_etapa = unname(P1[[r]]$reduzida$coef),
                                                               ep_primeira_etapa = sqrt(diag(P1[[r]]$reduzida$vcov)), stringsAsFactors = FALSE)))
lagm_t <- rbind(het(m99, "lag_p99"), het(m01, "lag_p1"), het(mc, "curva_geral"))
res <- list(meta = mc, blup = blup, base = base, eixo = eixo, eixo_p = eixo_p, grade = grade, tmr = tmr_t, contrastes = contr_t, curva_combinada = curva_c,
            boot_combinada = bc, q_tmr = q_tmr, lagresposta = list(unidades = lr_unid, reduzidos_p99 = R99, reduzidos_p1 = R01, meta_p99 = m99, meta_p1 = m01,
            curva = lag_t, soma = soma, arglag = al), c6 = c6, ordem = ordem, indice = idx, sha_codigo = sha_tag, sha_attrdl = SHA_ATTRDL, sha_entradas = sha_ent,
            blas = s_info$BLAS, lapack = s_info$LAPACK, versao_base = v_ini, data = hoje)
saveRDS(res, saidas[["rds"]])
escreve_csv(meta_t, saidas[["meta"]]); escreve_csv(blups_t, saidas[["blups"]]); escreve_csv(tmr_t, saidas[["tmr"]]); escreve_csv(contr_t, saidas[["contrastes"]])
escreve_csv(curva_c, saidas[["curva"]]); escreve_csv(lag_t, saidas[["lag"]]); escreve_csv(lagm_t, saidas[["lag_meta"]])
sha_out <- vapply(saidas, sha, "")

# ------------------------------------------------------------------ log
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
nm <- function(r) ifelse(r == "combinada", "combinada", nome[r])
pct_txt <- function(p) sub("^p", "p", p)
pfmt <- function(p) formatC(p, format = "g", digits = 3, decimal.mark = ",")
wald_t <- function(m) data.frame(Termo = m$wald$termo, `Estatística` = br(m$wald$estatistica, 2), gl = m$wald$gl, p = pfmt(m$wald$p), check.names = FALSE)
het_t <- function(m) do.call(rbind, lapply(c("residual", "total"), function(k) { h <- m$heterogeneidade[[k]]
  if (is.null(h)) return(data.frame(Tipo = k, Q = "indisponível", gl = NA, p = NA, `I²` = NA, check.names = FALSE))
  data.frame(Tipo = k, Q = br(h$Q, 2), gl = h$df, p = pfmt(h$p), `I²` = paste0(br(h$I2, 1), "%"), check.names = FALSE) }))
fmt_rr <- function(d) sprintf("%s (%s a %s)", br(d$rr, 3), br(d$rr_li, 3), br(d$rr_ls, 3))
autov <- function(m) { e <- eigen(m$Psi, symmetric = TRUE, only.values = TRUE)$values; k <- sum(e > 1e-8 * max(e))   # abaixo do limiar: ruído numérico, não impresso
  sprintf("autovalores de Ψ %s; posto efetivo %d de 4 (autovalores acima de 1e-8 × o maior)%s",
          paste(c(formatC(e[seq_len(k)], format = "e", digits = 3), if (k < 4) sprintf("%d abaixo de 1e-8 × o maior", 4 - k)), collapse = "; "), k,
          if (k < 4) ": Ψ singular, só reportado (A1.2; a sequência de estabilidade age só em erro ou não convergência)" else "") }
tb_t <- tmr_t[tmr_t$nivel == "blup", ]; ic_inteiro <- abs(tb_t$ic_li - tb_t$x_inf) < 1e-9 & abs(tb_t$ic_ls - tb_t$x_sup) < 1e-9
ic_c_inteiro <- abs(tmr_c$ic_li - tmr_c$x_inf) < 1e-9 && abs(tmr_c$ic_ls - tmr_c$x_sup) < 1e-9
cb_txt <- contr_t[contr_t$nivel == "combinada", ]
md_txt <- c("# Fase 3, Parte C: segunda etapa do modelo principal (C1 a C4) e conferência da cross-basis (C6)", "",
  sprintf("- **Gerado por:** `00_scripts/45_segunda_etapa_principal.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
  sprintf("- **Ambiente:** R %s; dlnm %s; gnm %s; mixmeta %s. BLAS/LAPACK: `%s` / `%s` (referência). Semente 20261001; sementes por concentração conforme o complemento C1 (bootstrap com i = posição na ordem; combinada com i = 0).",
          paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("gnm"), packageVersion("mixmeta"), s_info$BLAS, s_info$LAPACK),
  "- **Código (SHA-256, iguais aos das tags):**", sprintf("  - `%s`: `%s`;", names(sha_tag[["segunda_etapa-v1.0"]]), sha_tag[["segunda_etapa-v1.0"]]),
  sprintf("  - tags `ajusta_dlnm-v1.0` (commit `%s`) e `segunda_etapa-v1.0` (commit `%s`); `codigo_compartilhado/inst/terceiros/attrdl.R`: `%s`.", TAGS[[1]], TAGS[[2]], SHA_ATTRDL),
  "- **Entradas (SHA-256 conferidos):**", sprintf("  - `%s`: `%s`;", ENT, sha_ent),
  "- Os CSV `reduzida_coef_vcov` e `crossbasis_coef_vcov` da Fase 2 são iguais à RDS (comparação exata no texto, com o mesmo `sprintf(\"%.17g\")` da gravação). A `tmean_nucleo` de 2012–2024 lida para a C4 reproduz a grade da A0 (igualdade exata no texto `%.17g`).", "",
  "## C6: cross-basis remontada contra a da Fase 2 (antes de qualquer curva)", "",
  sprintf("- Nas 26 concentrações, a cross-basis pelo caminho da Fase 2 (nós do CSV, fronteiras padrão, 4.505 linhas) e a montada pela `monta_cb` com a `argvar` e a `arglag` da RDS têm o mesmo padrão de NA: %s; diferença máxima nas demais células: %s (critério ≤ 1e-12); atributos `argvar`, `arglag`, `lag`, `range` e `df` das duas `identical()` aos da RDS: %s.",
          if (all(c6$na_igual)) "sim" else "NÃO", formatC(max(c6$dif_max), format = "e", digits = 1), if (all(c6$atributos_identicos)) "sim, nas 26" else "NÃO"), "",
  "## C1: meta-análise da curva geral", "",
  sprintf("- **Método usado:** %s, Ψ %s (tentativas: %s). Convergiu: %s. Menor autovalor de Ψ: %s.", mc$metodo, mc$bscov, paste(mc$tentativas, collapse = "; "),
          if (isTRUE(mc$convergiu)) "sim" else as.character(mc$convergiu), formatC(mc$Psi_autovalor_min, format = "e", digits = 3)),
  if (length(mc$avisos)) sprintf("- **Avisos do mixmeta:** %s.", paste(unique(mc$avisos), collapse = "; ")) else "- **Avisos do mixmeta:** nenhum.",
  sprintf("- **Ψ:** %s.", autov(mc)), "",
  "**Heterogeneidade (Q de Cochran multivariado e I²):**", "", tabela_md(het_t(mc)), "",
  "**Wald de cada metapreditor:**", "", tabela_md(wald_t(mc)), "",
  "**Coeficientes da meta-regressão (EP):**", "",
  tabela_md(data.frame(Coeficiente = names(mc$coef_meta), Estimativa = formatC(mc$coef_meta, format = "e", digits = 4), EP = formatC(sqrt(diag(mc$vcov_meta)), format = "e", digits = 4), check.names = FALSE)), "",
  "**Ψ (4 × 4):**", "", tabela_md(data.frame(` ` = paste0("b", 1:4), matrix(formatC(mc$Psi, format = "e", digits = 3), 4, dimnames = list(NULL, paste0("b", 1:4))), check.names = FALSE)), "",
  "**BLUPs por concentração (coeficientes reduzidos da curva cumulativa; EP entre parênteses):**", "",
  tabela_md(data.frame(Concentração = nome[ordem], i = idx[ordem], t(vapply(ordem, function(r) sprintf("%s (%s)", formatC(blup[[r]]$coef, format = "e", digits = 3),
                                                                                                         formatC(sqrt(diag(blup[[r]]$vcov)), format = "e", digits = 3)), character(4))), check.names = FALSE) |>
              stats::setNames(c("Concentração", "i", paste0("b", 1:4)))), "",
  "## C2: curva combinada e TMR combinada (contraste primário)", "",
  sprintf("- **Base combinada (D2):** ns com nós %s e Boundary.knots %s °C (médias dos `attr(cb, \"argvar\")` das 26).", paste(br(base$knots, 3), collapse = "; "), paste(br(base$Boundary.knots, 3), collapse = " e ")),
  sprintf("- **Eixo médio (A0):** x1 = %s °C, x50 = %s °C, x99 = %s °C. Curva na média dos metapreditores (média %s °C; amplitude %s °C).",
          br(eixo[["p1"]], 3), br(eixo[["p50"]], 3), br(eixo[["p99"]], 3), br(mc$pred_media$metapred$media, 3), br(mc$pred_media$metapred$amplitude, 3)),
  sprintf("- **TMR combinada:** %s °C, no percentil %s do eixo médio (q_TMR = %s); IC 95%% do bootstrap da D4(a): %s a %s °C. Na fronteira da grade x1–x99: %s.%s",
          br(tc$tmr, 1), br(100 * q_tmr, 1), br(q_tmr, 4), br(bc$ic[1], 1), br(bc$ic[2], 1), if (tc$fronteira) "sim" else "não",
          if (tc$fronteira) sprintf(" Busca entre x10 e x90: %s °C.", br(tc$tmr_p10_p90, 1)) else ""),
  sprintf("- **Extensão do IC da TMR combinada:** %s; %s%% dos sorteios caem no x1 e %s%% no x99.", if (ic_c_inteiro) "o IC é a faixa de busca inteira (x1 a x99)" else "o IC não cobre a faixa de busca inteira",
          br(100 * tmr_c$prop_sorteios_x_inf, 1), br(100 * tmr_c$prop_sorteios_x_sup, 1)), "",
  "**RR cumulativo de lag 0–7 contra a TMR combinada (IC 95%; a TMR é tratada como fixa):**", "",
  tabela_md(data.frame(Contraste = c("x99 (primário)", "x1 (coprimário)", "x95", "x90", "x10", "x5"), Percentil = cb_txt$percentil, `°C` = br(cb_txt$temperatura, 3),
                       RR = fmt_rr(cb_txt), check.names = FALSE)), "",
  "## C3: curvas BLUP e TMR por concentração", "",
  sprintf("- **TMR BLUP na fronteira da grade p1–p99:** %d de 26%s. Na fronteira, o `cen` da C5 continua sendo a TMR da grade (D4(g)).", sum(tmr_t$fronteira[tmr_t$nivel == "blup"]),
          if (any(tmr_t$fronteira[tmr_t$nivel == "blup"])) paste0(" (", paste(nome[tmr_t$recorte_principal[tmr_t$nivel == "blup" & tmr_t$fronteira]], collapse = ", "), ")") else ""),
  sprintf("- **IC da TMR BLUP igual à grade p1–p99 inteira:** %d de 26. A coluna \"Sorteios nas pontas\" dá a porcentagem dos 1.000 sorteios do bootstrap no p1 e no p99 da concentração.", sum(ic_inteiro)), "",
  tabela_md(do.call(rbind, lapply(ordem, function(r) { t1 <- tmr_t[tmr_t$recorte_principal == r, ]; d <- contr_t[contr_t$recorte_principal == r, ]; d <- d[match(PCT, d$percentil), ]
    data.frame(Concentração = nome[[r]], i = t1$i, `TMR °C (IC 95%)` = sprintf("%s (%s a %s)", br(t1$tmr, 1), br(t1$ic_li, 1), br(t1$ic_ls, 1)), `Percentil da TMR` = br(100 * t1$percentil_tmr, 1),
               Fronteira = if (t1$fronteira) sprintf("sim (p10–p90: %s)", br(t1$tmr_p10_p90, 1)) else "não",
               `Sorteios nas pontas` = sprintf("%s%% / %s%%", br(100 * t1$prop_sorteios_x_inf, 1), br(100 * t1$prop_sorteios_x_sup, 1)),
               `RR p99 (°C)` = sprintf("%s (%s)", fmt_rr(d[1, ]), br(d$temperatura[1], 1)), `RR p1 (°C)` = sprintf("%s (%s)", fmt_rr(d[2, ]), br(d$temperatura[2], 1)), check.names = FALSE) }))), "",
  "**Concentrações com TMR BLUP na fronteira: RR contra a mediana (p50) da concentração** (§7 e A1.4; só reportado: o `cen` da C5 continua sendo a TMR da grade, D4(g); IC 95%; °C entre colchetes):", "",
  if (any(contr_t$nivel == "blup_mediana")) tabela_md(do.call(rbind, lapply(unique(contr_t$recorte_principal[contr_t$nivel == "blup_mediana"]), function(r) {
    d <- contr_t[contr_t$nivel == "blup_mediana" & contr_t$recorte_principal == r, ]; d <- d[match(PCT, d$percentil), ]
    data.frame(Concentração = nome[[r]], `p50 (°C)` = br(d$cen[1], 1), p99 = sprintf("%s [%s]", fmt_rr(d[1, ]), br(d$temperatura[1], 1)), p95 = sprintf("%s [%s]", fmt_rr(d[3, ]), br(d$temperatura[3], 1)),
               p90 = sprintf("%s [%s]", fmt_rr(d[4, ]), br(d$temperatura[4], 1)), p10 = sprintf("%s [%s]", fmt_rr(d[5, ]), br(d$temperatura[5], 1)),
               p5 = sprintf("%s [%s]", fmt_rr(d[6, ]), br(d$temperatura[6], 1)), p1 = sprintf("%s [%s]", fmt_rr(d[2, ]), br(d$temperatura[2], 1)), check.names = FALSE) }))) else "Nenhuma.", "",
  "**RR nos p95, p90, p10 e p5 da concentração contra a TMR BLUP (IC 95%; °C entre colchetes):**", "",
  tabela_md(do.call(rbind, lapply(ordem, function(r) { d <- contr_t[contr_t$recorte_principal == r, ]; d <- d[match(PCT, d$percentil), ]
    data.frame(Concentração = nome[[r]], p95 = sprintf("%s [%s]", fmt_rr(d[3, ]), br(d$temperatura[3], 1)), p90 = sprintf("%s [%s]", fmt_rr(d[4, ]), br(d$temperatura[4], 1)),
               p10 = sprintf("%s [%s]", fmt_rr(d[5, ]), br(d$temperatura[5], 1)), p5 = sprintf("%s [%s]", fmt_rr(d[6, ]), br(d$temperatura[6], 1)), check.names = FALSE) }))), "",
  "## C4: lag–resposta combinada (D4(b))", "",
  sprintf("- **Centro:** %s. Valor = p99 e p1 de cada concentração (grade da A0). `arglag` comum às 26 (ns com intercepto, nós %s).",
          if (tc$fronteira) "a TMR combinada está na fronteira, então o centro é o p50 de cada concentração nos dois lados" else sprintf("o °C de cada concentração no percentil da TMR combinada (q_TMR = %s), pela `tmean_nucleo` de 2012–2024", br(q_tmr, 4)),
          paste(br(al$knots, 3), collapse = "; ")),
  sprintf("- **Meta-análise:** p99 com %s/%s; p1 com %s/%s (mesma fórmula e mesma sequência de estabilidade da C1).", m99$metodo, m99$bscov, m01$metodo, m01$bscov),
  sprintf("- **Ψ da lag–resposta:** p99: %s. p1: %s.", autov(m99), autov(m01)), "",
  "**Heterogeneidade das duas meta-análises da lag–resposta:**", "",
  tabela_md(rbind(cbind(Valor = "p99", het_t(m99)), cbind(Valor = "p1", het_t(m01)))), "",
  "**RR por lag (nos lags inteiros; a curva de 0,1 em 0,1 está no CSV):**", "",
  tabela_md(do.call(rbind, lapply(0:7, function(l) { a <- lag_t[lag_t$valor == "p99" & abs(lag_t$lag - l) < 1e-9, ]; b <- lag_t[lag_t$valor == "p1" & abs(lag_t$lag - l) < 1e-9, ]
    data.frame(Lag = l, `RR no p99` = fmt_rr(a), `RR no p1` = fmt_rr(b), check.names = FALSE) }))), "",
  sprintf("- **Soma dos lags 0–7 (estimando diferente do RR cumulativo da C2):** p99 %s; p1 %s. Ao lado, o RR cumulativo da C2 contra a TMR combinada, na escala do eixo médio: x99 %s; x1 %s.",
          sprintf("%s (%s a %s)", br(soma["p99", "rr"], 3), br(soma["p99", "rr_li"], 3), br(soma["p99", "rr_ls"], 3)),
          sprintf("%s (%s a %s)", br(soma["p1", "rr"], 3), br(soma["p1", "rr_li"], 3), br(soma["p1", "rr_ls"], 3)), fmt_rr(cb_txt[1, ]), fmt_rr(cb_txt[2, ])), "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", saidas, sha_out), "",
  sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md_txt, arq, useBytes = TRUE)
cat("gravado:", arq, "| TMR combinada:", tc$tmr, "| fronteira BLUP:", sum(tmr_t$fronteira[tmr_t$nivel == "blup"]), "\n")
