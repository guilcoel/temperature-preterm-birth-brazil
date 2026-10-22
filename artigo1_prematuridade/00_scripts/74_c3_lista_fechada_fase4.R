# 74_c3_lista_fechada_fase4.R — Fase 4, Parte C3: o resto da lista fechada da §10.2 (mensagem "C2, C3 e C4 em lote",
# 19/10/2026, seção C3; plano da Fase 4, script 75; D11; D12; D16; novo modo de trabalho). Sensibilidades descritivas,
# sem critério de concordância. Cada análise passa pelo fluxo comum (fluxo_c_fase4.R): 1ª etapa nas concentrações da
# análise, fallback da D7, M7, φ, teste 3, meta_curva (média + amplitude da tmean_nucleo), TMR combinada no eixo da
# própria análise com IC bootstrap (semente 20261001), RR no x99 e no x1 com IC, borda pela D13, item 3, e D10, 1d.
# Decisões de implementação, registradas antes de rodar (rótulo: post hoc, não mudam o estimando; A1-107):
#   - UR e controle negativo: ns de 3 gl da média móvel (UR, lag 0–3; controle negativo, t+1 a t+7), com os 2 nós nos
#     tercis e as fronteiras no range dos dias da janela principal da concentração, somada ao principal;
#   - exposição (tmean_rm_nv, Tmax, Tmin, AT) e estação quente: nós, cen = p50, eixo e grade pela grade da B1.2 (65) da
#     própria exposição (D6, 2.2, tabela: a série da sensibilidade), Boundary.knots do x passado; estação quente: nós de
#     nov–mar, ajuste só nos dias de nov–mar da janela principal (a cross-basis usa a série inteira, para os lags), TMR na
#     grade entre x1 e x50 do eixo de nov–mar, RR no x99 e no x1 desse eixo;
#   - estratos × dia da semana: estrato = concentração × ano × mês × dia da semana, sem a covariável dia_semana; posto
#     completo conferido em cada ajuste (confere_posto);
#   - sem 24/12–01/01 e sem 2020–21: só os dias de ajuste saem (a cross-basis e o aquecimento ficam);
#   - subtipos: offset restrito às semanas do subtipo (B1.3), γ pela regra (A1-102: extremo e muito γ = 1, offset log
#     Σ Z_tj·w_j do subtipo; moderado-tardio γ estimado), corte de 1.000 eventos por subtipo (lista da B1.5);
#   - §3.5 (i) e (ii): Z_t e w_j da própria versão (B1.4), γ estimado, corte de 1.000 (nenhuma sai);
#   - 2011, braços A e B: sem offset e sem coorte fixa, nós e eixo do principal, Boundary.knots do x de cada braço (D12,
#     4.3), 7 dias de aquecimento (P7);
#   - termo precoce: γ = 1 com o w_j por pessoa-dia (offset log Σ Z_tj·w_j das semanas 37–38), na janela dele e na
#     interseção, nós e eixo do principal;
#   - feriados locais: pendente, porque a tag feriados_locais-v1.0 não existe (a COORD está em pausa);
#   - sem análise: binomial negativa (φ > 2 em 0 de 26 no principal, lido do 32) e corte de 2.000 (nenhuma concentração
#     sai: mínimo de PTB na janela principal lido da B1.5).
# Saídas (fora do git): 01_saidas/fase4/c3_fase4_<RODADA>.rds e c3_fase4_<RODADA>.csv. Log logs/c3_fase4_<RODADA>.md.
# Nunca sobrescreve. Confere antes: script e módulo commitados e limpos; código igual ao das tags; SHA-256 das entradas.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/74_c3_lista_fechada_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("c3_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase4"); f_out <- c(rds = file.path(OUT, paste0("c3_fase4_", rodada, ".rds")), csv = file.path(OUT, paste0("c3_fase4_", rodada, ".csv")))
for (p in f_out) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/74_c3_lista_fechada_fase4.R"; MOD <- "artigo1_prematuridade/00_scripts/fluxo_c_fase4.R"
CC <- file.path(REPO, "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
icf <- function(a, li, ls, d = 3) sprintf("%s (%s a %s)", br(a, d), br(li, d), br(ls, d))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
escreve_csv <- function(df, p) { num <- vapply(df, is.double, TRUE); df[num] <- lapply(df[num], function(v) ifelse(is.na(v), NA, sprintf("%.17g", v)))
  utils::write.csv(df, p, row.names = FALSE, na = "", fileEncoding = "UTF-8") }

sujos <- git("status", "--porcelain", "--", ESTE, MOD); if (length(sujos)) { cat(sujos, sep = "\n"); stop("script ou módulo com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current"); st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:"); inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"); t0 <- Sys.time()
s_info <- sessionInfo(); if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib")) stop("BLAS/LAPACK fora da referência (§8)")
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
COD <- c("codigo_compartilhado/R/ajusta_dlnm.R" = "ajusta_dlnm-v1.1", "codigo_compartilhado/R/segunda_etapa.R" = "segunda_etapa-v1.1",
         "codigo_compartilhado/R/sens_agudos.R" = "sens_agudos-v1.0", "codigo_compartilhado/tests/teste3_fonte_independente.R" = "segunda_etapa-v1.1")
sha_cod <- vapply(names(COD), function(p) sha(file.path(REPO, p)), ""); for (p in names(COD)) if (!identical(sha_cod[[p]], tag_sha(COD[[p]], p))) stop(p, " difere da tag ", COD[[p]])
ENT <- c(s4 = "01_saidas/fase4/serie_ptb_fase4.rds", esp = "01_saidas/fase1/serie_ptb_espontaneo.rds", dum = "01_saidas/fase4/serie_ig_dum_fase4.rds",
         g11 = "01_saidas/fase4/serie_2011_gestacao_fase4.rds", tp = "01_saidas/fase4/serie_termo_precoce_fase4.rds", pct = "01_saidas/fase4/percentis_exposicao_fase4_20261018.csv",
         pm = "01_saidas/fase4/pm25_zero_na_lista_fase4.csv", cont = "01_saidas/fase4/contagens_insumos_fase4.csv",
         rds32 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", rds45 = "01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds", ref = "01_saidas/fase1/referencias_exposicao.csv")
LOGS_B1 <- c("logs/series_exposicao_offset_fase4_20261018.md", "logs/ig_dum_e_2011_fase4_20261018.md", "logs/percentis_exposicao_fase4_20261018.md", "logs/contagens_insumos_fase4_20261018.md")
SHA_FIXO <- c(esp = "654ecbf5cda28dc066709d99238a11370c1205da0f08183152fb326df9a99af7", rds32 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d",
              rds45 = "52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e", ref = "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467")
sha_ent <- vapply(ENT, sha, ""); txt_b1 <- paste(unlist(lapply(LOGS_B1, readLines, encoding = "UTF-8")), collapse = "\n")
ok_b1 <- vapply(c("s4", "dum", "g11", "tp", "pct", "pm", "cont"), function(k) grepl(paste0("`", ENT[[k]], "`: `", sha_ent[[k]], "`"), txt_b1, fixed = TRUE), TRUE)
if (!all(ok_b1) || !identical(unname(sha_ent[names(SHA_FIXO)]), unname(SHA_FIXO))) stop("entrada com SHA-256 diferente do registrado: ", paste(c(names(ok_b1)[!ok_b1], names(SHA_FIXO)[sha_ent[names(SHA_FIXO)] != SHA_FIXO]), collapse = ", "))
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta); library(splines) })
f <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = f); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f); sys.source(file.path(CC, "R", "sens_agudos.R"), envir = f)
source(file.path(CC, "tests", "teste3_fonte_independente.R"))
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
CAL <- c("dia_semana", "feriado_nacional", "carnaval", "moveis"); AL7 <- list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE)
ref <- utils::read.csv(ENT[["ref"]], colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ordem, ref$recorte_principal), ]; stopifnot(identical(ref$recorte_principal, ordem))
md <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1, row.names = ordem)
sys.source(file.path(REPO, MOD), envir = environment())
r45 <- readRDS(ENT[["rds45"]]); rds32 <- readRDS(ENT[["rds32"]])$resultados
D <- as.Date; JP <- D(c("2012-04-14", "2024-08-06"))
s4full <- as.data.frame(readRDS(ENT[["s4"]])); esp <- as.data.frame(readRDS(ENT[["esp"]])); dum <- as.data.frame(readRDS(ENT[["dum"]]))
g11 <- as.data.frame(readRDS(ENT[["g11"]])); tp <- as.data.frame(readRDS(ENT[["tp"]]))
pct <- utils::read.csv(ENT[["pct"]], colClasses = c(recorte_principal = "character", valor = "character")); pct$valor <- as.numeric(pct$valor)
pm <- utils::read.csv(ENT[["pm"]], colClasses = c(recorte_principal = "character")); cont <- utils::read.csv(ENT[["cont"]], colClasses = c(recorte_principal = "character"))
corte <- function(col) ordem[ordem %in% cont$recorte_principal[cont[[col]] >= 1000]]
fatia <- function(df, r, ini, fim = D("2024-12-31")) { x <- df[df$recorte_principal == r & df$data >= ini & df$data <= fim, ]; x <- x[order(x$data), ]; rownames(x) <- NULL; stopifnot(nrow(x) > 0, all(diff(x$data) == 1)); x }
INI <- JP[1] - 7L; FIMP <- JP[2]
nos_p <- function(r) { z <- ref[ref$recorte_principal == r, ]; list(p10 = z$p10, p75 = z$p75, p90 = z$p90, p50 = z$p50) }
grade_de <- function(e) t(vapply(ordem, function(r) { z <- pct[pct$exposicao == e & pct$recorte_principal == r, ]; z <- z[order(z$percentil), ]; setNames(z$valor, z$rotulo) }, numeric(101)))
eixo_de <- function(e) { z <- pct[pct$exposicao == e & pct$recorte_principal == "eixo_medio", ]; z <- z[order(z$percentil), ]; list(v = setNames(z$valor, z$rotulo), p = z$percentil / 100) }
nos_de <- function(e) { G <- grade_de(e); function(r) list(p10 = G[r, "p10"], p75 = G[r, "p75"], p90 = G[r, "p90"], p50 = G[r, "p50"]) }
# séries de referência da exposição (2012–2024) para o teste 3
sdr <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_nucleo", "tmean_rm_nv"))); sdr$data <- D(sdr$data)
sdr <- sdr[sdr$data >= D("2012-01-01") & sdr$data <= D("2024-12-31"), ]
nuc6 <- setNames(substr(nuc$CD_MUN_NUCLEO, 1, 6), nuc$CD_RECORTE)
cl <- as.data.frame(clima_municipal(c("CD_MUN6", "data", "tmax", "tmin", "tmean", "rh_mean"))); cl$data <- D(cl$data)
cl <- cl[cl$CD_MUN6 %in% nuc6 & cl$data >= D("2012-01-01") & cl$data <= D("2024-12-31"), ]; cl$recorte_principal <- names(nuc6)[match(cl$CD_MUN6, nuc6)]
cl$at <- f$temperatura_aparente(cl$tmean, cl$rh_mean); cl <- cl[order(cl$recorte_principal, cl$data), ]
sn <- list(tmean_nucleo = function(r) sdr$tmean_nucleo[sdr$recorte_principal == r], tmean_rm_nv = function(r) sdr$tmean_rm_nv[sdr$recorte_principal == r],
           tmax = function(r) cl$tmax[cl$recorte_principal == r], tmin = function(r) cl$tmin[cl$recorte_principal == r], at = function(r) cl$at[cl$recorte_principal == r],
           nov_mar = function(r) { z <- sdr[sdr$recorte_principal == r, ]; z$tmean_nucleo[as.integer(format(z$data, "%m")) %in% c(11, 12, 1, 2, 3)] })
ns3 <- function(v, jan) { k <- stats::quantile(v[jan], c(1, 2) / 3, type = 7, names = FALSE); b <- range(v[jan]); m <- unclass(ns(v, knots = k, Boundary.knots = b)); attributes(m) <- list(dim = dim(m)); m }
base_p <- list(nos = nos_p, eixo = r45$eixo, eixo_p = r45$eixo_p, grade = r45$grade, serie_nos = sn$tmean_nucleo, xcol = "tmean_nucleo")
cfg_de <- function(id, rotulo, dados, extra = list(), ...) { a <- base_p; a$id <- id; a$rotulo <- rotulo; a$dados <- dados; a$extra <- extra; m <- list(...); a[names(m)] <- m; a }
expo <- function(id, rotulo, col, e, snf) { ex <- eixo_de(e); cfg_de(id, rotulo, function(r) fatia(s4full, r, INI, FIMP), list(exposicao = col), nos = nos_de(e), eixo = ex$v, eixo_p = ex$p, grade = grade_de(e), serie_nos = snf, xcol = col) }
evq <- eixo_de("tmean_nucleo_nov_mar")
CFG <- list(
  expo("E1", "Exposição: `tmean_rm_nv`", "tmean_rm_nv", "tmean_rm_nv", sn$tmean_rm_nv),
  expo("E2", "Exposição: Tmax do núcleo", "tmax_nucleo", "tmax_nucleo", sn$tmax),
  expo("E3", "Exposição: Tmin do núcleo", "tmin_nucleo", "tmin_nucleo", sn$tmin),
  expo("E4", "Exposição: temperatura aparente do núcleo", "at_nucleo", "at_nucleo", sn$at),
  cfg_de("E5", "Exposição: UR (ns de 3 gl na média de lag 0–3, somada)", function(r) { x <- fatia(s4full, r, INI, FIMP); x$ns_ur <- ns3(x$rh_media_0_3, x$janela_principal); x }, list(covariaveis = c(CAL, "ns_ur"))),
  cfg_de("P1", "PM2.5: `pm25_local_zero_na_nucleo`, linear, lag 0–1 (23 concentrações)", function(r) fatia(s4full, r, INI, FIMP), list(covariaveis = c(CAL, "pm25_local_zero_na_0_1")), incluir = ordem[ordem %in% pm$recorte_principal[pm$entra]]),
  cfg_de("CB1", "Cross-basis: lag 0–4", function(r) fatia(s4full, r, JP[1] - 4L, FIMP), lag = 4L),
  cfg_de("CB2", "Cross-basis: lag 0–21", function(r) fatia(s4full, r, JP[1] - 21L, FIMP), lag = 21L),
  cfg_de("CB3", "Cross-basis: S1 (`bs` de grau 2, nós p10/p75/p90)", function(r) fatia(s4full, r, INI, FIMP), fun = "bs", degree = 2L),
  cfg_de("CB4", "Cross-basis: S2 (`ns`, nós p50/p90)", function(r) fatia(s4full, r, INI, FIMP), argvar_s2 = TRUE),
  cfg_de("T1", "Tempo: ns(tempo, 74 gl), sem estratos", function(r) fatia(s4full, r, INI, FIMP), list(estrato = NULL, tempo_gl = 74)),
  cfg_de("T2", "Tempo: ns(tempo, 123 gl), sem estratos", function(r) fatia(s4full, r, INI, FIMP), list(estrato = NULL, tempo_gl = 123)),
  cfg_de("T3", "Calendário: estratos × dia da semana, sem `dia_semana`", function(r) { x <- fatia(s4full, r, INI, FIMP); x$estrato_dow <- paste(x$estrato, x$dia_semana, sep = "_"); x },
         list(estrato = "estrato_dow", covariaveis = c("feriado_nacional", "carnaval", "moveis")), devolve_matriz = TRUE, confere = function(z) f$confere_posto(z$matriz)$completo),
  cfg_de("T4", "Calendário: sem 24/12 a 01/01 (só do ajuste)", function(r) { x <- fatia(s4full, r, INI, FIMP); mm <- format(x$data, "%m-%d")
    x$jan_t4 <- x$janela_principal & !(mm %in% c(sprintf("12-%02d", 24:31), "01-01")); x }, list(janela = "jan_t4")),
  cfg_de("T5", "Calendário: sem 2020–2021 (dias de evento, só do ajuste)", function(r) { x <- fatia(s4full, r, INI, FIMP); x$jan_t5 <- x$janela_principal & !(x$ano %in% 2020:2021); x }, list(janela = "jan_t5")),
  cfg_de("T6", "Estação quente (nov–mar; TMR em x1–x50 do eixo de nov–mar)", function(r) { x <- fatia(s4full, r, INI, FIMP); x$jan_t6 <- x$janela_principal & as.integer(format(x$data, "%m")) %in% c(11, 12, 1, 2, 3); x },
         list(janela = "jan_t6"), nos = nos_de("tmean_nucleo_nov_mar"), eixo = evq$v, eixo_p = evq$p, grade = grade_de("tmean_nucleo_nov_mar"), serie_nos = sn$nov_mar, tmr_sup = "p50"),
  cfg_de("T7", "Calendário: controle negativo (ns de 3 gl na média de t+1 a t+7)", function(r) { x <- fatia(s4full, r, INI, FIMP); x$ns_cn <- ns3(x$cn_tmean_1_7, x$janela_principal); x }, list(covariaveis = c(CAL, "ns_cn"))),
  cfg_de("D1", "Denominador: `z_fetal` em Z (w_j do principal)", function(r) { x <- fatia(s4full, r, INI, FIMP); x$log_z <- x$log_z_fetal; x$log_w <- x$log_w_fetal; x }),
  cfg_de("D2", "Denominador: w_j por ano de entrada", function(r) { x <- fatia(s4full, r, INI, FIMP); x$log_w <- x$log_w_ano; x }),
  cfg_de("D3o", "Denominador: sem offset", function(r) fatia(s4full, r, INI, FIMP), list(offset = "nenhum")),
  cfg_de("D4", "Denominador: janela de evento possível (2012-01-04 a 2024-11-15)", function(r) fatia(s4full, r, D("2012-01-04") - 7L, D("2024-11-15")), list(janela = "janela_evento_possivel")),
  cfg_de("O1", "Desfecho: subtipo extremo (22–27; γ = 1; corte de 1.000)", function(r) { x <- fatia(s4full, r, INI, FIMP); x$log_zw <- x$log_zw_extremo; x }, list(desfecho = "ptb_extremo", offset = "zw"), incluir = corte("extremo")),
  cfg_de("O2", "Desfecho: subtipo muito (28–31; γ = 1)", function(r) { x <- fatia(s4full, r, INI, FIMP); x$log_zw <- x$log_zw_muito; x }, list(desfecho = "ptb_muito", offset = "zw"), incluir = corte("muito")),
  cfg_de("O3", "Desfecho: subtipo moderado-tardio (32–36; γ estimado)", function(r) { x <- fatia(s4full, r, INI, FIMP); x$log_z <- x$log_z_moderado_tardio; x$log_w <- x$log_w_moderado_tardio; x },
         list(desfecho = "ptb_moderado_tardio"), incluir = corte("moderado_tardio")),
  cfg_de("O4", "Desfecho: PTB espontâneo (ii)", function(r) fatia(esp, r, INI, FIMP), list(desfecho = "ptb_espontaneo_ii")),
  cfg_de("O5", "Desfecho: §3.5, versão (i) (IG pelo SEMAGESTAC; Z_t e w_j próprios)", function(r) { x <- fatia(dum, r, INI, FIMP); x$log_z <- x$log_z_i; x$log_w <- x$log_w_i; x }, list(desfecho = "ptb_dum_i"), incluir = corte("dum_i")),
  cfg_de("O6", "Desfecho: §3.5, versão (ii) (IG pela DUM; Z_t e w_j próprios)", function(r) { x <- fatia(dum, r, INI, FIMP); x$log_z <- x$log_z_ii; x$log_w <- x$log_w_ii; x }, list(desfecho = "ptb_dum_ii"), incluir = corte("dum_ii")),
  cfg_de("O7", "Desfecho: 2011, braço A (2011–2024; GESTACAO; sem offset e sem coorte fixa)", function(r) fatia(g11, r, D("2010-12-25"), D("2024-12-31")), list(desfecho = "ptb_gestacao", janela = "braco_A", offset = "nenhum")),
  cfg_de("O8", "Desfecho: 2011, braço B (2012–2024; GESTACAO; sem offset e sem coorte fixa)", function(r) fatia(g11, r, D("2011-12-25"), D("2024-12-31")), list(desfecho = "ptb_gestacao", janela = "braco_B", offset = "nenhum")),
  cfg_de("O9", "Desfecho: termo precoce (37–38; γ = 1; pessoa-dia; 2012-04-28 a 2024-11-19)", function(r) fatia(tp, r, D("2012-04-21"), D("2024-11-19")), list(desfecho = "termo_precoce", janela = "janela_termo", offset = "zw")),
  cfg_de("O10", "Desfecho: termo precoce na interseção (2012-04-28 a 2024-08-06)", function(r) fatia(tp, r, D("2012-04-21"), D("2024-11-19")), list(desfecho = "termo_precoce", janela = "janela_intersecao", offset = "zw")))
res <- list(); falhas <- character(0)
for (cfg in CFG) { log_msg("análise", cfg$id)
  z <- tryCatch(roda_analise(cfg), error = function(e) e)
  if (inherits(z, "error")) { falhas <- c(falhas, paste0(cfg$id, ": ", conditionMessage(z))); log_msg("FALHOU", cfg$id, conditionMessage(z)) } else res[[cfg$id]] <- z }
tab <- do.call(rbind, lapply(res, `[[`, "linha")); rownames(tab) <- NULL
phi32 <- vapply(ordem, function(r) rds32[[r]]$principal$phi, 0); min_ptb <- min(cont$ptb)
sem <- data.frame(id = c("BN", "C2000", "FL"), rotulo = c("Binomial negativa", "Corte de 2.000 eventos", "Feriados locais"),
                  situacao = c(sprintf("não se aplica (φ > 2 em %d de 26 no principal; φ máximo %s)", sum(phi32 > 2), br(max(phi32), 3)),
                               if (min_ptb >= 2000) sprintf("idêntico ao principal: nenhuma concentração sai (mínimo de PTB na janela principal = %s)", br(min_ptb)) else "ALGUMA CONCENTRAÇÃO SAIRIA: ver",
                               if (length(git("tag", "-l", "feriados_locais-v1.0"))) "tag existe: rodar" else "pendente: a tag feriados_locais-v1.0 não existe (COORD em pausa; patch P12)"), stringsAsFactors = FALSE)
saveRDS(lapply(res, function(z) z[setdiff(names(z), c("dados", "fits_completos"))]), f_out[["rds"]]); escreve_csv(tab, f_out[["csv"]]); sha_out <- vapply(f_out, sha, "")
stopifnot(versao() == "4443971b")
md_txt <- c("# Fase 4, Parte C3: o resto da lista fechada da §10.2", "",
  sprintf("- **Gerado por:** `00_scripts/74_c3_lista_fechada_fase4.R` (SHA-256 `%s`) e o módulo `00_scripts/fluxo_c_fase4.R` (`%s`), início em %s, fim em %s. Rodada `%s`. `versao()`: %s.",
          sha(file.path(REPO, ESTE)), sha(file.path(REPO, MOD)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  "- **Código (igual ao das tags):**", sprintf("  - `%s`: `%s` (`%s`);", names(sha_cod), sha_cod, COD),
  "- **Entradas (SHA-256 = logs da B1 ou registrados):**", sprintf("  - `%s`: `%s`;", ENT, sha_ent),
  "- **Decisões de implementação:** no cabeçalho do script e na A1-107.", "",
  "## Análises (sensibilidades descritivas; sem critério de concordância)", "", tabela_md(fmt_linhas(tab, br, icf)), "",
  "- Borda: o contraste daquele lado vale 1 por construção, com o RR contra a mediana do eixo como descritivo (D13, item 3; D10, 1d). Na estação quente, a grade da TMR vai de x1 a x50 do eixo de nov–mar.",
  if (any(nzchar(tab$excluidas))) c("", "- **Concentrações fora:**", sprintf("  - %s: %s (%s);", tab$id[nzchar(tab$excluidas)], tab$excluidas[nzchar(tab$excluidas)], tab$motivos_exclusao[nzchar(tab$excluidas)])) else "- Nenhuma concentração saiu por falha de ajuste.",
  "", "## Linhas sem análise e pendências", "", tabela_md(data.frame(Linha = sem$rotulo, Situação = sem$situacao, check.names = FALSE)), "",
  if (length(falhas)) c("## Falhas de execução", "", paste0("- ", falhas), "") else "- Nenhuma falha de execução.", "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", f_out, sha_out), "",
  sprintf("- **Resultado:** %d análises rodadas de %d; tempo %.1f min.", nrow(tab), length(CFG), as.numeric(difftime(Sys.time(), t0, units = "mins"))), "")
writeLines(md_txt, arq, useBytes = TRUE)
cat("gravado:", arq, "| análises:", nrow(tab), "de", length(CFG), "| falhas:", length(falhas), "| minutos:", round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 1), "\n")
if (length(falhas)) quit(status = 1)
