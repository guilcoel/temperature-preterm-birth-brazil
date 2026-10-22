# 70_chaves_c1_fase4.R — Fase 4, Parte C1: as seis sensibilidades-chave (§9.2) e o critério de concordância (D10, 1a a
# 1g) (mensagem da C1 do chat do A1, 18/10/2026, itens 1 e 2; plano da Fase 4, script 70). Methods e Results não são
# escritos aqui; nada de interpretação.
# PORTÃO (qualquer falha: grava o log e sai com quit(status = 1) antes de qualquer modelo de chave):
#   1. tags no remoto: git ls-remote --tags origin traz ajusta_dlnm-v1.1, offset-v1.1, segunda_etapa-v1.1,
#      sens_agudos-v1.0 e diagnostico_grade_mrt-v1.0.1, cada uma (^{}) no commit registrado (lido da passagem da Parte A,
#      logs/passagem_A1_chat_COORD_push_fase4_parteA_20261018.md, nunca digitado);
#   2. B1 fechada: o log da dupla auditoria da B1 (logs/auditoria_parteB1_fase4_<data>.md) existe e diz "Achados
#      abertos: nenhum"; o SHA-256 das séries e tabelas da B1 que a C1 usa é o dos logs da B1;
#   3. reproduções no principal (P16): a ajusta_dlnm v1.1 reproduz os coeficientes e a vcov (cross-basis e reduzidos)
#      do 32 nas 26 (≤ 1e-10); a meta_curva v1.1, com as entradas do 45, dá identical() à meta do RDS do 45; a confere_meta
#      passa no principal;
#   4. valores do primário lidos do RDS do 45 (nunca digitados), conferidos contra 28,2 °C, q = 0,9378, 1,003 (0,978 a
#      1,029) e 1,020 (0,990 a 1,051), na formatação do log da Fase 3.
# CHAVES (só o que muda em relação ao principal; spec_agudo/ajusta_dlnm v1.1; 1ª etapa nas 26):
#   1. tmean_mun: case time series municipal, um modelo por concentração, com os municípios empilhados (group =
#      CD_MUN6), estratos município × ano × mês (estrato_mun), Z_t municipal e w_j da concentração (série da Fase 1,
#      dias com Z_t = 0 fora por linha_modelo, m8), nós p10/p75/p90 e cen = p50 da tmean_mun agrupada (65), eixo próprio
#      = média dos percentis da tmean_mun agrupada das 26 (65; D2, "Abrangência"), Boundary.knots do x passado;
#   2. lag 0–14: arglag ns com intercepto e logknots(14, nk = 2); 14 dias de aquecimento antes de 2012-04-14 (D11, 5.1);
#   3. ns(tempo): estrato = NULL e tempo_gl = 99 (glm quasi-Poisson não condicional; ns da data sobre os 4.498 dias da
#      janela, sem o aquecimento; D16, item 1);
#   4. PM2.5: pm25_local_0_1 (média de lag 0–1 da pm25_local_nucleo, B1.3) como termo linear somado ao principal (§2.3);
#   5. γ = 1: offset log(Z_t) + log(W_t) (spec offset = "zw"; §3.1);
#   6. PTB espontâneo (i): desfecho ptb_espontaneo_i da série da Fase 1 (B1.3), com Z_t, w_j, janela e γ do principal.
#   Chaves 2 a 6: nós p10/p75/p90 e cen = p50 da tmean_nucleo de ano inteiro (referencias_exposicao.csv), eixo = o da A0
#   (RDS do 45).
# FLUXO COMUM (cada chave): fallback da D7, M7 (passo 1, só a arglag, por concentração, nos lags 0–7: estratos 0–1, 2–4 e
#   5–7; na chave 2, sem estratos definidos para o lag 0–14, a falha é registrada; passo 2, argvar ns p50/p90 nas 26, chave
#   "confundida", D10, 1e; o que ainda falhar sai da 2ª etapa); φ mínimo, mediana e máximo; meta_curva (média + amplitude
#   da tmean_nucleo, P5), confere_meta e confere_eixo; TMR combinada na grade de 0,1 °C entre x1 e x99 do eixo da chave,
#   borda pelo índice; IC bootstrap da TMR (1.000 sorteios, semente 20261001, i = 0); RR no x99 e no x1 contra a TMR, com
#   IC; na borda, aquele contraste "não avaliável" e o RR contra a mediana do eixo como descritivo (D10, 1d); Q e I²
#   residuais; Wald dos metapreditores; Q por coeficiente só descritivo, sem p; teste 3 da D6, 2.2 (decide_teste3) em
#   cada concentração com cross-basis ns (BLUP da chave, grade p1–p99 e percentis da concentração na exposição da chave).
# Saídas (fora do git): 01_saidas/fase4/c1_chaves_fase4_<RODADA>.rds e criterio_c1_fase4_<RODADA>.csv (coeficientes
#   reduzidos podem sair: A1-101, decisão 3). Grava logs/c1_chaves_fase4_<RODADA>.md. Nunca sobrescreve.
# Confere antes: este script commitado e limpo; código igual ao das tags; BLAS/LAPACK de referência (§8).
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/70_chaves_c1_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("c1_chaves_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase4"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
f_out <- c(rds = file.path(OUT, paste0("c1_chaves_fase4_", rodada, ".rds")), csv = file.path(OUT, paste0("criterio_c1_fase4_", rodada, ".csv")))
for (p in f_out) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/70_chaves_c1_fase4.R"
CC <- file.path(REPO, "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
icf <- function(a, li, ls, d = 3) sprintf("%s (%s a %s)", br(a, d), br(li, d), br(ls, d))
pfmt <- function(p) formatC(p, format = "g", digits = 3, decimal.mark = ",")
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
escreve_csv <- function(df, p) { num <- vapply(df, is.double, TRUE); df[num] <- lapply(df[num], function(v) ifelse(is.na(v), NA, sprintf("%.17g", v)))
  utils::write.csv(df, p, row.names = FALSE, na = "", fileEncoding = "UTF-8") }

# ------------------------------------------------------------------ cabeçalho (3.8), BLAS e código das tags
sujos <- git("status", "--porcelain", "--", ESTE)
if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current")
st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:")
stopifnot(length(head_c) == 1L, length(ramo) == 1L, length(coord) == 1L)
inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"); t0 <- Sys.time()
s_info <- sessionInfo()
if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib")) stop("BLAS/LAPACK fora da referência (§8)")
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
COD <- c("codigo_compartilhado/R/ajusta_dlnm.R" = "ajusta_dlnm-v1.1", "codigo_compartilhado/R/segunda_etapa.R" = "segunda_etapa-v1.1",
         "codigo_compartilhado/tests/teste3_fonte_independente.R" = "segunda_etapa-v1.1")
sha_cod <- vapply(names(COD), function(p) sha(file.path(REPO, p)), "")
for (p in names(COD)) if (!identical(sha_cod[[p]], tag_sha(COD[[p]], p))) stop(p, " difere da tag ", COD[[p]])
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta); library(splines) })
f <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = f); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f)
source(file.path(CC, "tests", "teste3_fonte_independente.R"))
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
portao <- data.frame(Item = character(0), Resultado = character(0), Confere = logical(0), stringsAsFactors = FALSE)
reg <- function(item, res, ok) portao[nrow(portao) + 1, ] <<- list(item, res, isTRUE(ok))
INI <- as.Date("2012-04-07"); INI14 <- as.Date("2012-03-31"); INI_JAN <- as.Date("2012-04-14"); FIM <- as.Date("2024-08-06")
CAL <- c("dia_semana", "feriado_nacional", "carnaval", "moveis"); AL7 <- list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE)

# ------------------------------------------------------------------ portão 1: tags no remoto
pas <- readLines("logs/passagem_A1_chat_COORD_push_fase4_parteA_20261018.md", encoding = "UTF-8")
lt <- grep("^[[:space:]]*\\| `[a-z_]+-v[0-9.]+` \\| `[0-9a-f]{40}` \\|", pas)   # a tabela da passagem está indentada dentro de um item de lista
tags_esp <- setNames(sub(".*\\| `([0-9a-f]{40})` \\|.*", "\\1", pas[lt]), sub("^[[:space:]]*\\| `([^`]+)`.*", "\\1", pas[lt]))
lr <- git("ls-remote", "--tags", "origin")
tag_rem <- function(t) { l <- grep(paste0("\trefs/tags/", t, "\\^\\{\\}$"), lr, value = TRUE); if (length(l) == 1) sub("\t.*", "", l) else NA_character_ }
TAGS5 <- c("ajusta_dlnm-v1.1", "offset-v1.1", "segunda_etapa-v1.1", "sens_agudos-v1.0", "diagnostico_grade_mrt-v1.0.1")
rem <- vapply(TAGS5, tag_rem, "")
ok1 <- all(TAGS5 %in% names(tags_esp)) && identical(unname(rem), unname(tags_esp[TAGS5]))
reg("1. Tags da Parte A no remoto, cada uma no commit registrado na passagem", paste(sprintf("%s → %s", TAGS5, substr(rem, 1, 7)), collapse = "; "), ok1)

# ------------------------------------------------------------------ portão 2: B1 fechada e SHA das entradas da B1
f_aud <- sort(Sys.glob("logs/auditoria_parteB1_fase4_*.md"), decreasing = TRUE)[1]
ok2a <- !is.na(f_aud) && any(grepl("^- \\*\\*Achados abertos:\\*\\* nenhum", readLines(f_aud, encoding = "UTF-8")))
le_sha_log <- function(log, alvo) { l <- grep(paste0("`", alvo, "`: `[0-9a-f]{64}`"), readLines(log, encoding = "UTF-8"), value = TRUE, fixed = FALSE); if (length(l)) sub(".*`([0-9a-f]{64})`.*", "\\1", l[1]) else NA }
ENT <- c(s4 = "01_saidas/fase4/serie_ptb_fase4.rds", pct = "01_saidas/fase4/percentis_exposicao_fase4_20261018.csv", cont = "01_saidas/fase4/contagens_insumos_fase4.csv")
LOGB1 <- c(s4 = "logs/series_exposicao_offset_fase4_20261018.md", pct = "logs/percentis_exposicao_fase4_20261018.md", cont = "logs/contagens_insumos_fase4_20261018.md")
sha_ent <- vapply(ENT, sha, ""); sha_log <- vapply(names(ENT), function(k) le_sha_log(LOGB1[[k]], ENT[[k]]), "")
ok2b <- identical(unname(sha_ent), unname(sha_log))
reg("2. B1 fechada (log da dupla auditoria: \"Achados abertos: nenhum\") e SHA-256 das entradas da B1 = logs da B1",
    sprintf("%s; SHA %s", if (is.na(f_aud)) "log da auditoria ausente" else basename(f_aud), if (ok2b) "conferem" else "DIFEREM"), ok2a && ok2b)
ENT_F <- c(rds32 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", rds45 = "01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds",
           ref = "01_saidas/fase1/referencias_exposicao.csv", mun = "01_saidas/fase1/serie_ptb_municipal.rds", esp = "01_saidas/fase1/serie_ptb_espontaneo.rds")
SHA_F <- c(rds32 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d", ref = "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467",
           mun = "04dad6b1b54472802594ef3ed44adcf327c02e0cd7ed88dd90af63b86770cd49", esp = "654ecbf5cda28dc066709d99238a11370c1205da0f08183152fb326df9a99af7")
sha_f <- vapply(ENT_F, sha, ""); ok2c <- identical(unname(sha_f[names(SHA_F)]), unname(SHA_F))
reg("2b. SHA-256 das entradas das Fases 1 a 3 (32, referências, séries municipal e espontânea) = registrados (RESPOSTA da Fase 1; log do 45)", if (ok2c) "conferem" else "DIFEREM", ok2c)

ok_ate2 <- ok1 && ok2a && ok2b && ok2c
# ------------------------------------------------------------------ portão 3: reproduções no principal (P16)
ref <- utils::read.csv(ENT_F[["ref"]], colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ordem, ref$recorte_principal), ]; stopifnot(identical(ref$recorte_principal, ordem))
md <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1, row.names = ordem)
s4 <- readRDS(ENT[["s4"]]); s4 <- as.data.frame(s4)[s4$data >= INI14 & s4$data <= FIM, ]
dados_r <- function(df, r, ini) { x <- df[df$recorte_principal == r & df$data >= ini, ]; x <- x[order(x$data), ]; rownames(x) <- NULL; stopifnot(all(diff(x$data) == 1)); x }
spec_base <- function(rr, ...) { a <- list(desfecho = "ptb", exposicao = "tmean_nucleo", janela = "janela_principal", lag = 7,
  argvar = list(fun = "ns", knots = c(rr$p10, rr$p75, rr$p90)), arglag = AL7, offset = "z_w_gama", cen = rr$p50); m <- list(...); a[names(m)] <- m; do.call(f$spec_agudo, a) }
rds32 <- readRDS(ENT_F[["rds32"]])$resultados; r45 <- readRDS(ENT_F[["rds45"]])
ok3 <- FALSE; dif32 <- NA_real_; ok3b <- FALSE; ok3c <- FALSE
if (ok_ate2) {
  log_msg("portão 3: reprodução do 32 com a v1.1")
  dif32 <- max(vapply(ordem, function(r) { p <- f$ajusta_dlnm(dados_r(s4, r, INI), spec_base(ref[ref$recorte_principal == r, ])); q <- rds32[[r]]$principal
    if (!identical(p$status, "ok")) return(Inf)
    max(abs(p$coef_cb - q$coef_cb), abs(p$vcov_cb - q$vcov_cb), abs(p$reduzida$coef - q$reduzida$coef), abs(p$reduzida$vcov - q$reduzida$vcov)) }, 0))
  ok3 <- dif32 <= 1e-10
  Y0 <- t(vapply(ordem, function(r) unname(rds32[[r]]$principal$reduzida$coef), numeric(4))); S0 <- lapply(ordem, function(r) unname(rds32[[r]]$principal$reduzida$vcov))
  mc0 <- f$meta_curva(Y0, S0, md); ok3b <- identical(mc0, r45$meta)
  ok3c <- !inherits(tryCatch(f$confere_meta(mc0, c("media", "amplitude"), Y0), error = function(e) e), "error")
}
reg("3a. `ajusta_dlnm` v1.1 reproduz coeficientes e vcov (cross-basis e reduzidos) do 32 nas 26 (≤ 1e-10)", if (is.na(dif32)) "não rodou" else sprintf("diferença máxima %s", formatC(dif32, format = "e", digits = 1)), ok3)
reg("3b. `meta_curva` v1.1 com as entradas do 45 = meta do RDS do 45 (`identical`)", if (ok3b) "identical" else "difere ou não rodou", ok3b)
reg("3c. `confere_meta` passa no principal", if (ok3c) "passa" else "falha ou não rodou", ok3c)

# ------------------------------------------------------------------ portão 4: valores do primário (do RDS do 45)
tc0 <- r45$tmr[r45$tmr$nivel == "combinada", ]; c0 <- r45$contrastes[r45$contrastes$nivel == "combinada", ]
p99 <- c0[c0$percentil == "p99", ]; p01 <- c0[c0$percentil == "p1", ]
txt_prim <- c(tmr = br(tc0$tmr, 1), q = br(tc0$percentil_tmr, 4), x99 = icf(p99$rr, p99$rr_li, p99$rr_ls), x1 = icf(p01$rr, p01$rr_li, p01$rr_ls))
ok4 <- identical(unname(txt_prim), c("28,2", "0,9378", "1,003 (0,978 a 1,029)", "1,020 (0,990 a 1,051)"))
reg("4. Primário lido do RDS do 45: TMR combinada, q, RR no x99 e no x1", sprintf("%s °C; q = %s; x99 %s; x1 %s", txt_prim[["tmr"]], txt_prim[["q"]], txt_prim[["x99"]], txt_prim[["x1"]]), ok4)
ok_portao <- all(portao$Confere)
IC99 <- c(p99$rr_li, p99$rr_ls); IC01 <- c(p01$rr_li, p01$rr_ls)

escreve_log <- function(extra, ok) {
  pt <- portao; pt$Confere <- ifelse(pt$Confere, "sim", "NÃO")
  md_txt <- c("# Fase 4, Parte C1: as seis sensibilidades-chave e o critério de concordância (D10)", "",
    sprintf("- **Gerado por:** `00_scripts/70_chaves_c1_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()` no início: %s; no fim: %s.",
            sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini, versao()),
    sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
            head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
    sprintf("- **Ambiente:** R %s; dlnm %s; gnm %s; mixmeta %s. BLAS/LAPACK de referência (`%s` / `%s`). Semente 20261001 (bootstrap da TMR com i = 0).",
            paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("gnm"), packageVersion("mixmeta"), basename(s_info$BLAS), basename(s_info$LAPACK)),
    "- **Código (igual ao das tags):**", sprintf("  - `%s`: `%s` (`%s`);", names(sha_cod), sha_cod, COD), "",
    "## Portão de entrada", "", tabela_md(pt), "", extra,
    sprintf("- **Resultado:** %s. Tempo total: %.1f min.", if (ok) "portão aberto; as seis chaves rodaram" else "PARE (ver o portão e as notas)", as.numeric(difftime(Sys.time(), t0, units = "mins"))), "")
  writeLines(md_txt, arq, useBytes = TRUE)
}
if (!ok_portao) { escreve_log("- **PARE:** um item do portão falhou; nenhum modelo de chave rodou.", FALSE); cat("PORTÃO FALHOU\n"); quit(status = 1) }
log_msg("portão aberto")

# ------------------------------------------------------------------ dados e referências das chaves
pct <- utils::read.csv(ENT[["pct"]], colClasses = c(recorte_principal = "character", valor = "character")); pct$valor <- as.numeric(pct$valor)
rot_ord <- function(z) z[order(z$percentil), ]
grade_mun <- t(vapply(ordem, function(r) { z <- rot_ord(pct[pct$exposicao == "tmean_mun_agrupada" & pct$recorte_principal == r, ]); setNames(z$valor, z$rotulo) }, numeric(101)))
ez1 <- rot_ord(pct[pct$exposicao == "tmean_mun_agrupada" & pct$recorte_principal == "eixo_medio", ]); eixo1 <- setNames(ez1$valor, ez1$rotulo); eixo1_p <- ez1$percentil / 100
eixo0 <- r45$eixo; eixo0_p <- r45$eixo_p; grade0 <- r45$grade
stopifnot(identical(names(eixo1), names(eixo0)), length(eixo1) == 101)
mun <- readRDS(ENT_F[["mun"]]); mun <- as.data.frame(mun)[mun$data >= INI & mun$data <= FIM, ]
esp <- readRDS(ENT_F[["esp"]]); esp <- as.data.frame(esp)[esp$data >= INI & esp$data <= FIM, ]
sdm <- as.data.frame(serie_diaria(nivel = "municipio", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_mun"))); sdm$data <- as.Date(sdm$data)
sdm <- sdm[sdm$data >= as.Date("2012-01-01") & sdm$data <= as.Date("2024-12-31"), ]
sdr <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_nucleo"))); sdr$data <- as.Date(sdr$data)
sdr <- sdr[sdr$data >= as.Date("2012-01-01") & sdr$data <= as.Date("2024-12-31"), ]
nos_mun <- function(r) { g <- grade_mun[r, ]; list(p10 = g[["p10"]], p75 = g[["p75"]], p90 = g[["p90"]], p50 = g[["p50"]]) }
dados_mun <- function(r) { x <- mun[mun$recorte_principal == r, ]; x <- x[order(x$CD_MUN6, x$data), ]; rownames(x) <- NULL
  stopifnot(all(tapply(x$data, x$CD_MUN6, function(d) all(diff(d) == 1)))); x }
CHAVES <- list(
  list(id = 1L, rotulo = "1. `tmean_mun` (case time series municipal)", exp = "tmean_mun", lag = 7L, dados = function(r) dados_mun(r), nos = nos_mun,
       extra = list(exposicao = "tmean_mun", janela = "linha_modelo", estrato = "estrato_mun", group = "CD_MUN6"), eixo = "mun"),
  list(id = 2L, rotulo = "2. Lag 0–14", exp = "tmean_nucleo", lag = 14L, dados = function(r) dados_r(s4, r, INI14), nos = NULL,
       extra = list(lag = 14, arglag = list(fun = "ns", knots = dlnm::logknots(14, nk = 2), intercept = TRUE)), eixo = "nucleo"),
  list(id = 3L, rotulo = "3. ns(tempo, 99 gl), sem estratos", exp = "tmean_nucleo", lag = 7L, dados = function(r) dados_r(s4, r, INI), nos = NULL,
       extra = list(estrato = NULL, tempo_gl = 99), eixo = "nucleo"),
  list(id = 4L, rotulo = "4. PM2.5 (`pm25_local_nucleo`, lag 0–1, linear)", exp = "tmean_nucleo", lag = 7L, dados = function(r) dados_r(s4, r, INI), nos = NULL,
       extra = list(covariaveis = c(CAL, "pm25_local_0_1")), eixo = "nucleo"),
  list(id = 5L, rotulo = "5. γ = 1 (offset log Z_t + log W_t)", exp = "tmean_nucleo", lag = 7L, dados = function(r) dados_r(s4, r, INI), nos = NULL,
       extra = list(offset = "zw"), eixo = "nucleo"),
  list(id = 6L, rotulo = "6. PTB espontâneo (i)", exp = "tmean_nucleo", lag = 7L, dados = function(r) dados_r(esp, r, INI), nos = NULL,
       extra = list(desfecho = "ptb_espontaneo_i"), eixo = "nucleo"))
MOTIVOS_FALLBACK <- c("não convergiu", "coeficiente da cross-basis aliasado", "vcov da cross-basis não positiva-definida", "vcov indisponível", "vcov reduzida não positiva-definida")
elegivel <- function(z) identical(z$status, "falhou") && !is.na(z$mensagem) && all(strsplit(z$mensagem, "; ", fixed = TRUE)[[1]] %in% MOTIVOS_FALLBACK)
PCT <- c("p99", "p1", "p95", "p90", "p10", "p5")

roda_chave <- function(ch) {
  tk <- Sys.time(); log_msg("chave", ch$id)
  rr_de <- function(r) if (is.null(ch$nos)) { z <- ref[ref$recorte_principal == r, ]; list(p10 = z$p10, p75 = z$p75, p90 = z$p90, p50 = z$p50) } else ch$nos(r)
  spec_k <- function(r, passo = 0L, al = NULL) { rr <- rr_de(r); e <- ch$extra
    av <- if (passo == 2L) list(fun = "ns", knots = c(rr$p50, rr$p90)) else list(fun = "ns", knots = c(rr$p10, rr$p75, rr$p90))
    e$argvar <- av; e$cen <- rr$p50; if (!is.null(al)) e$arglag <- al; do.call(spec_base, c(list(rr = rr), e)) }
  AL_P1 <- list(fun = "strata", breaks = c(2, 5), intercept = TRUE)
  dd <- lapply(ordem, ch$dados); names(dd) <- ordem
  fits <- list(); passo <- setNames(rep(0L, 26), ordem); al_conc <- setNames(vector("list", 26), ordem)
  for (r in ordem) {
    z <- f$ajusta_dlnm(dd[[r]], spec_k(r))
    if (!identical(z$status, "ok") && elegivel(z) && ch$lag == 7L) { z2 <- f$ajusta_dlnm(dd[[r]], spec_k(r, al = AL_P1)); if (identical(z2$status, "ok")) { z <- z2; passo[r] <- 1L; al_conc[[r]] <- AL_P1 } }
    fits[[r]] <- z
  }
  falhas1 <- ordem[!vapply(fits, function(z) identical(z$status, "ok"), TRUE)]
  passo2 <- length(falhas1) > 0
  if (passo2) { log_msg("chave", ch$id, ": passo 2 do fallback nas 26")
    for (r in ordem) fits[[r]] <- f$ajusta_dlnm(dd[[r]], spec_k(r, passo = 2L, al = al_conc[[r]])); passo[] <- 2L }
  ok_c <- vapply(fits, function(z) identical(z$status, "ok"), TRUE); inc <- ordem[ok_c]
  phi <- vapply(fits[inc], `[[`, 0, "phi")
  k <- if (passo2) 3L else 4L
  Y <- t(vapply(inc, function(r) unname(fits[[r]]$reduzida$coef), numeric(k))); S <- lapply(inc, function(r) unname(fits[[r]]$reduzida$vcov))
  mdk <- md[inc, , drop = FALSE]
  mc <- f$meta_curva(Y, S, mdk); f$confere_meta(mc, c("media", "amplitude"), Y)
  base <- f$base_combinada(lapply(inc, function(r) fits[[r]]$base$argvar))
  eixo <- if (ch$eixo == "mun") eixo1 else eixo0; ep <- if (ch$eixo == "mun") eixo1_p else eixo0_p
  f$confere_eixo(eixo[["p1"]], eixo[["p99"]], unname(eixo))
  pc <- mc$pred_media$coef; pv <- mc$pred_media$vcov
  tc <- f$busca_tmr(pc, base, eixo[["p1"]], eixo[["p99"]], eixo[["p10"]], eixo[["p90"]], eixo[["p50"]])
  bc <- f$boot_tmr(pc, pv, base, eixo[["p1"]], eixo[["p99"]], i = 0)
  q <- f$posicao_no_eixo(tc$tmr, unname(eixo), ep)
  cc <- f$curva(pc, pv, base, unname(eixo[c("p99", "p1")]), tc$tmr)
  lado <- if (!tc$fronteira) NA_character_ else if (tc$indice == 1L) "x1" else "x99"
  cm <- if (tc$fronteira) f$curva(pc, pv, base, unname(eixo[c("p99", "p1")]), eixo[["p50"]]) else NULL
  qc <- f$q_por_coeficiente(mc, Y, S, mdk)
  t3 <- do.call(rbind, lapply(seq_along(inc), function(i) { r <- inc[i]; av <- fits[[r]]$base$argvar
    g <- if (ch$eixo == "mun") grade_mun[r, ] else grade0[r, ]; x <- c(f$grade_tmr(g[["p1"]], g[["p99"]]), unname(g[PCT]))
    sn <- if (ch$eixo == "mun") sdm$tmean_mun[sdm$recorte_principal == r] else sdr$tmean_nucleo[sdr$recorte_principal == r]
    xcb <- dd[[r]][[ch$exp]]; pr <- if (passo2) c(0.50, 0.90) else c(0.10, 0.75, 0.90)
    v <- teste3_fonte_independente(f$curva, mc$blup[[i]]$coef, av, x, g[["p50"]], sn, pr, xcb, fun = "ns"); d <- f$decide_teste3(v, x, xcb)
    data.frame(recorte_principal = r, dif = v$dif, dif_nos = v$dif_nos, dif_fronteiras = v$dif_fronteiras, controle_p1p99 = v$dif_controle_p1p99, ok = d$ok,
               falhas = paste(d$falhas, collapse = "; "), stringsAsFactors = FALSE) }))
  h <- mc$heterogeneidade$residual
  dentro <- function(v, ic) v >= ic[1] & v <= ic[2]
  linha <- data.frame(chave = ch$id, rotulo = ch$rotulo, incluidas = length(inc), excluidas = paste(nome[ordem[!ok_c]], collapse = ", "),
                      passo_fallback = if (passo2) "passo 2 (confundida)" else if (any(passo == 1L)) paste0("passo 1 em ", paste(nome[ordem[passo == 1L]], collapse = ", ")) else "nenhum",
                      tmr = tc$tmr, percentil_tmr = q, fronteira = tc$fronteira, lado_borda = lado, ic_tmr_li = bc$ic[1], ic_tmr_ls = bc$ic[2],
                      x99 = eixo[["p99"]], rr99 = cc$rr[1], rr99_li = cc$rr_li[1], rr99_ls = cc$rr_ls[1], x1 = eixo[["p1"]], rr01 = cc$rr[2], rr01_li = cc$rr_li[2], rr01_ls = cc$rr_ls[2],
                      avaliavel99 = !identical(lado, "x99"), avaliavel01 = !identical(lado, "x1"),
                      dentro99 = if (identical(lado, "x99")) NA else dentro(cc$rr[1], IC99), dentro01 = if (identical(lado, "x1")) NA else dentro(cc$rr[2], IC01),
                      direcao99 = cc$logrr[1] >= 0, direcao01 = cc$logrr[2] >= 0,
                      rr99_mediana = if (is.null(cm)) NA else cm$rr[1], rr99_mediana_li = if (is.null(cm)) NA else cm$rr_li[1], rr99_mediana_ls = if (is.null(cm)) NA else cm$rr_ls[1],
                      rr01_mediana = if (is.null(cm)) NA else cm$rr[2], rr01_mediana_li = if (is.null(cm)) NA else cm$rr_li[2], rr01_mediana_ls = if (is.null(cm)) NA else cm$rr_ls[2],
                      phi_min = min(phi), phi_med = stats::median(phi), phi_max = max(phi), metodo = mc$metodo, bscov = mc$bscov,
                      Q = h$Q, gl = h$df, p_Q = h$p, I2 = h$I2, wald_media_p = mc$wald$p[mc$wald$termo == "media"], wald_amplitude_p = mc$wald$p[mc$wald$termo == "amplitude"],
                      teste3_ok = sum(t3$ok), teste3_n = nrow(t3), minutos = as.numeric(difftime(Sys.time(), tk, units = "mins")), stringsAsFactors = FALSE)
  enxuto <- lapply(fits, function(z) z[c("status", "mensagem", "avisos", "convergiu", "coef_cb", "vcov_cb", "dim_cb", "base", "boundary_knots", "reduzida", "gama", "ep_gama", "phi", "qaic", "n")])
  list(linha = linha, fits = enxuto, passo = passo, meta = mc, base = base, tmr = tc, boot = bc, curva = cc, mediana = cm, q_coef = qc, teste3 = t3, Y = Y, S = S, incluidas = inc)
}
resultados <- lapply(CHAVES, roda_chave); names(resultados) <- paste0("chave", vapply(CHAVES, `[[`, 0L, "id"))
tab <- do.call(rbind, lapply(resultados, `[[`, "linha")); rownames(tab) <- NULL

# ------------------------------------------------------------------ gravação e log
saveRDS(list(resultados = resultados, criterio = tab, primario = list(tmr = tc0, x99 = p99, x1 = p01), portao = portao, sha_codigo = sha_cod,
             sha_entradas = c(sha_ent, sha_f), versao_base = v_ini, rodada = rodada), f_out[["rds"]])
escreve_csv(tab, f_out[["csv"]]); sha_out <- vapply(f_out, sha, "")
d10 <- readLines(file.path(REPO, "spec", "decisoes_metodo_20261015_TODOS_D10_concordancia_coordenacao_git.md"), encoding = "UTF-8")
i1g <- grep("^### 1g\\.", d10); frase <- sub("^> ", "", d10[i1g + which(grepl("^> A result", d10[(i1g + 1):(i1g + 6)]))])
rrs <- function(v, li, ls) icf(v, li, ls)
crit <- data.frame(Chave = tab$rotulo,
                   `TMR (°C; percentil)` = sprintf("%s; %s", br(tab$tmr, 1), br(100 * tab$percentil_tmr, 1)),
                   `IC da TMR (°C)` = sprintf("%s a %s", br(tab$ic_tmr_li, 1), br(tab$ic_tmr_ls, 1)),
                   `RR x99 (IC)` = ifelse(tab$avaliavel99, rrs(tab$rr99, tab$rr99_li, tab$rr99_ls), paste0("não avaliável (borda); contra a mediana: ", rrs(tab$rr99_mediana, tab$rr99_mediana_li, tab$rr99_mediana_ls))),
                   `x99 no IC do primário (0,978 a 1,029)` = ifelse(is.na(tab$dentro99), "não avaliável", ifelse(tab$dentro99, "sim", "não")),
                   `RR x1 (IC)` = ifelse(tab$avaliavel01, rrs(tab$rr01, tab$rr01_li, tab$rr01_ls), paste0("não avaliável (borda); contra a mediana: ", rrs(tab$rr01_mediana, tab$rr01_mediana_li, tab$rr01_mediana_ls))),
                   `x1 no IC do primário (0,990 a 1,051)` = ifelse(is.na(tab$dentro01), "não avaliável", ifelse(tab$dentro01, "sim", "não")),
                   Fallback = tab$passo_fallback, `φ (mín.; mediana; máx.)` = sprintf("%s; %s; %s", br(tab$phi_min, 3), br(tab$phi_med, 3), br(tab$phi_max, 3)), check.names = FALSE)
diag_t <- data.frame(Chave = tab$rotulo, `Incluídas` = tab$incluidas, `Excluídas` = ifelse(nzchar(tab$excluidas), tab$excluidas, "—"), Método = paste(tab$metodo, tab$bscov, sep = " / "),
                     `Teste 3 (ok/n)` = paste0(tab$teste3_ok, "/", tab$teste3_n), `Q residual (gl; p)` = sprintf("%s (%d; %s)", br(tab$Q, 1), as.integer(tab$gl), pfmt(tab$p_Q)),
                     `I² residual` = paste0(br(tab$I2, 1), "%"), `Wald média (p)` = pfmt(tab$wald_media_p), `Wald amplitude (p)` = pfmt(tab$wald_amplitude_p),
                     `Minutos` = br(tab$minutos, 1), check.names = FALSE)
qc_t <- do.call(rbind, lapply(resultados, function(z) data.frame(Chave = z$linha$rotulo, `Q por coeficiente (gl)` = paste(sprintf("%s (%s)", br(z$q_coef$Q, 1), z$q_coef$gl), collapse = "; "), check.names = FALSE)))
extra <- c("## Tabela do critério (D10, 1a a 1g)", "",
  sprintf("- **Primário (RDS do 45):** TMR combinada %s °C (q = %s); RR no x99 %s; RR no x1 %s. Os vereditos do x99 e do x1 saem separados, sem \"robusto\" único.", txt_prim[["tmr"]], txt_prim[["q"]], txt_prim[["x99"]], txt_prim[["x1"]]), "",
  tabela_md(crit), "",
  "- **Declaração obrigatória (D10, 1b):** com a TMR própria, a direção é ≥ 1 por construção; o critério se reduz a cair no IC do primário; e, como o IC do primário inclui 1 nos dois contrastes, ele é pouco informativo neste artigo.",
  sprintf("- **Direção (log RR ≥ 0) nos contrastes avaliáveis:** %s.", paste(sprintf("chave %d: x99 %s, x1 %s", tab$chave, ifelse(tab$direcao99, "≥ 1", "< 1"), ifelse(tab$direcao01, "≥ 1", "< 1")), collapse = "; ")),
  sprintf("- **Frase de Methods (D10, 1g), lida da D10:** \"%s\"", frase), "",
  "## Diagnósticos por chave", "", tabela_md(diag_t), "",
  "- **Q por coeficiente:** só descritivo, sem p (\"por coeficiente (não univariado)\").", "", tabela_md(qc_t), "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", f_out, sha_out), "")
escreve_log(extra, TRUE)
cat("gravado:", arq, "| portão ok | chaves:", nrow(tab), "| minutos:", round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 1), "\n")
