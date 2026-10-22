# 66_series_exposicao_offset_fase4.R — Fase 4, Parte B1.3: séries de exposição e de offset (mensagem da Parte B do chat
# do A1, 18/10/2026, item B1.3; plano da Fase 4, script 66; especificação v2.0.2, §1.1, §2.3 e §3.1; D12, 4.1 e 4.2;
# D16, item 3; D6, 1.1 e 1.5). Nenhum modelo de desfecho.
# Entradas da Fase 1 conferidas pelo 64 (SHA-256 contra a RESPOSTA da Fase 1, conferido de novo aqui):
#   serie_ptb_principal.rds (série principal) e wj_ptb_concentracao.csv (w_j do principal).
# Chave 1 (case time series municipal) e chave 6 (PTB espontâneo, versões (i) e (ii), com os ignorados contados): as
#   séries são as da Fase 1 (serie_ptb_municipal.rds, com offset de periodo = NULL, dias de Z_t = 0 marcados em z_t_zero e
#   fora do ajuste por linha_modelo; serie_ptb_espontaneo.rds), reconstruídas a partir da base e idênticas no 64. Aqui só
#   se conferem o SHA e as colunas que a C1 usa.
# Grava, fora do git, em 01_saidas/fase4/:
#   1. serie_ptb_fase4.rds: a série principal da Fase 1, inalterada (identical nas colunas de origem), mais:
#      - exposição: tmax_nucleo, tmin_nucleo e at_nucleo (clima_municipal() do núcleo; AT pela temperatura_aparente() da
#        sens_agudos v1.0); cn_tmean_1_7 (controle negativo: média da tmean_nucleo de t+1 a t+7, §4); rh_media_0_3 (UR,
#        média de lag 0–3); pm25_local_0_1 e pm25_local_zero_na_0_1 (média de lag 0–1, §2.3). As médias usam
#        media_janela() sobre a serie_diaria() inteira (2010-12-11 a 2025-01-07, datas consecutivas), então os dias do
#        fim do período gravado têm o t+7;
#      - offset com z_fetal (D16, item 3): Z_tj = z_nv + z_fetal (obito_fetal_principal) nas semanas 22–36, w_j do
#        principal, periodo = janela de evento possível (como o principal): z_t_fetal, w_t_fetal, log_z_fetal,
#        log_w_fetal, log_zw_fetal;
#      - offset dos subtipos (D12, 4.1): Z_t e W_t nas semanas do subtipo (extremo 22–27, muito 28–31, moderado-tardio
#        32–36), w_j do principal, periodo = janela principal (sem dia com Z_t do subtipo = 0, senão PARE):
#        z_t_<sub>, log_z_<sub>, log_w_<sub>, log_zw_<sub>;
#      - offset com w_j por ano de entrada (D12, 4.2): calcula_wj_ano() do offset v1.1 na população do principal
#        (unico, ga_sem 22–42, coorte_fixa_22), com s = dum_est (= data − (7·ga_sem + 3), conferido); w do ano de t;
#        periodo = janela de evento possível: w_t_ano, log_w_ano, log_zw_ano; termos sem w contados;
#      - Z_tj por semana (z_nv), j = 22…36: colunas z22…z36.
#   2. serie_termo_precoce_fase4.rds: termo precoce (§3.1; D6, 1.5; A1-89): NV únicos da coorte fixa 22 com ga_sem 37–38
#      por data do nascimento; Z_t = z_nv nas semanas 37–38 (z37, z38); w_j por pessoa-dia (calcula_wj_pd(), semanas 37–38,
#      na população do principal, por concentração); periodo = janela do termo precoce, 2012-04-28 a 2024-11-19, com 7
#      dias de aquecimento antes; tmean_nucleo, calendário e estrato como na série principal; janela_termo e
#      janela_intersecao (2012-04-28 a 2024-08-06).
#   3. wj_ano_ptb_fase4.csv (w_j por concentração × ano × semana), wj_pd_termo_precoce_fase4.csv e
#      pm25_zero_na_lista_fase4.csv.
# Lista do pm25_local_zero_na_nucleo (§2.3; decisões de 08/10, §10): entra a concentração com ≥ 90% dos dias da janela
#   principal com média de lag 0–1 utilizável. Se a lista diferir da registrada (23; saem Campo Grande, Goiânia e
#   Brasília): PARE. A variante principal (pm25_local_nucleo) tem de estar completa na janela.
# Controles: a contagem por data dos NV da população do principal a partir de nascimentos() tem de ser igual à nv_unicos
#   da serie_diaria() (coorte fixa) e a dos PTB, à ptb, em todos os dias de 2012 a 2024; o w_j recalculado com
#   calcula_wj() tem de ser igual ao do CSV da Fase 1. Qualquer falha: grava o log e sai com quit(status = 1).
# Sigilo: as séries e os CSV com contagens ficam na Forja, fora do git. O log traz só esquema, conferências e agregados
#   de exposição; nenhuma contagem por concentração (vão para o 68, com "<10") e nada diário.
# Confere antes: este script commitado e limpo; offset.R, sens_agudos.R e segunda_etapa.R iguais aos das tags.
# Grava logs/series_exposicao_offset_fase4_<RODADA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/66_series_exposicao_offset_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("series_exposicao_offset_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase4"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
f_out <- c(serie = "serie_ptb_fase4.rds", termo = "serie_termo_precoce_fase4.rds", wj_ano = "wj_ano_ptb_fase4.csv",
           wj_pd = "wj_pd_termo_precoce_fase4.csv", pm25 = "pm25_zero_na_lista_fase4.csv")
f_out <- setNames(file.path(OUT, f_out), names(f_out)); for (p in f_out) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/66_series_exposicao_offset_fase4.R"
CC <- file.path(REPO, "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")

# ------------------------------------------------------------------ cabeçalho (protocolo v1.1, 3.8) e código das tags
sujos <- git("status", "--porcelain", "--", ESTE)
if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current")
st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:")
stopifnot(length(head_c) == 1L, length(ramo) == 1L, length(coord) == 1L)
inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"); t0 <- Sys.time()
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
COD <- c(offset = "offset-v1.1", sens_agudos = "sens_agudos-v1.0", segunda_etapa = "segunda_etapa-v1.1")
sha_cod <- vapply(names(COD), function(k) sha(file.path(CC, "R", paste0(k, ".R"))), "")
for (k in names(COD)) if (!identical(sha_cod[[k]], tag_sha(COD[[k]], paste0("codigo_compartilhado/R/", k, ".R")))) stop(k, ".R difere da tag ", COD[[k]])
of <- new.env(); sys.source(file.path(CC, "R", "offset.R"), envir = of)
sa <- new.env(); sys.source(file.path(CC, "R", "sens_agudos.R"), envir = sa)
se <- new.env(); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = se)

D <- as.Date
GRAV <- D(c("2011-12-14", "2024-11-15")); JP <- D(c("2012-04-14", "2024-08-06")); JE <- D(c("2012-01-04", "2024-11-15"))
TP <- D(c("2012-04-28", "2024-11-19")); TPI <- D(c("2012-04-28", "2024-08-06")); TP_GRAV <- c(TP[1] - 7L, TP[2])
SEM <- 22:36; SUB <- list(extremo = 22:27, muito = 28:31, moderado_tardio = 32:36); SEM_TP <- 37:38
nuc <- as.data.frame(cidade_nucleo()); se$confere_ordem(nuc$CD_RECORTE); ordem <- se$ORDEM_CONCENTRACOES
nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE); nuc6 <- setNames(substr(nuc$CD_MUN_NUCLEO, 1, 6), nuc$CD_RECORTE)
conc <- as.data.frame(concentracoes())[, c("CD_MUN6", "CD_RECORTE")]
falhas <- character(0); confere <- function(cond, txt) { if (!isTRUE(cond)) falhas <<- c(falhas, txt); isTRUE(cond) }

# ------------------------------------------------------------------ 0. entradas da Fase 1 (SHA contra a RESPOSTA)
resp <- readLines("RESPOSTA_artigo1_prematuridade_FASE1_20261009.md", encoding = "UTF-8")
l_arq <- grep("`01_saidas/fase1/[^`]+`: `[0-9a-f]{64}`", resp); stopifnot(length(l_arq) == 6L)
esp <- setNames(sub(".*`([0-9a-f]{64})`.*", "\\1", resp[l_arq]), sub(".*`(01_saidas/fase1/[^`]+)`.*", "\\1", resp[l_arq]))
f1 <- c("01_saidas/fase1/serie_ptb_principal.rds", "01_saidas/fase1/wj_ptb_concentracao.csv", "01_saidas/fase1/serie_ptb_municipal.rds", "01_saidas/fase1/serie_ptb_espontaneo.rds")
sha_f1 <- vapply(f1, sha, ""); ok_f1 <- confere(all(sha_f1 == esp[f1]), "SHA-256 de entrada da Fase 1 diferente da RESPOSTA")
s1 <- readRDS(f1[1]); wj <- utils::read.csv(f1[2], colClasses = c(recorte_principal = "character"), encoding = "UTF-8")
mun <- readRDS(f1[3]); esp_s <- readRDS(f1[4])
ok_cols_c1 <- confere(all(c("CD_MUN6", "recorte_principal", "data", "ptb", "tmean_mun", "log_z", "log_w", "z_t_zero", "linha_modelo") %in% names(mun)) &&
                      all(c("ptb_espontaneo_i", "ptb_espontaneo_ii", "ptb_ignorado", "ptb_iniciado") %in% names(esp_s)), "colunas da chave 1 ou da chave 6 ausentes")
n_mun_zero_jp <- sum(mun$z_t_zero & mun$data >= JP[1] & mun$data <= JP[2]); ok_lm <- confere(!any(mun$linha_modelo & mun$z_t_zero), "chave 1: dia com Z_t = 0 dentro do ajuste")
rm(mun, esp_s); invisible(gc())

# ------------------------------------------------------------------ 1. exposição (serie_diaria inteira e clima do núcleo)
log_msg("exposição")
sd <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "nv_unicos", "ptb", "tmean_nucleo", "rh_nucleo",
                                                                                   "pm25_local_nucleo", "pm25_local_zero_na_nucleo")))
sd$data <- D(sd$data); sd <- sd[order(sd$recorte_principal, sd$data), ]
mm <- do.call(rbind, lapply(ordem, function(r) {
  x <- sd[sd$recorte_principal == r, ]; stopifnot(all(diff(x$data) == 1))
  data.frame(recorte_principal = r, data = x$data, cn_tmean_1_7 = sa$media_janela(x$tmean_nucleo, x$data, 1, 7), rh_media_0_3 = sa$media_janela(x$rh_nucleo, x$data, -3, 0),
             pm25_local_0_1 = sa$media_janela(x$pm25_local_nucleo, x$data, -1, 0), pm25_local_zero_na_0_1 = sa$media_janela(x$pm25_local_zero_na_nucleo, x$data, -1, 0), stringsAsFactors = FALSE)
}))
cl <- as.data.frame(clima_municipal(c("CD_MUN6", "data", "tmax", "tmin", "tmean", "rh_mean"))); cl$data <- D(cl$data)
cl <- cl[cl$CD_MUN6 %in% nuc6 & cl$data >= min(sd$data) & cl$data <= max(sd$data), ]; cl$recorte_principal <- names(nuc6)[match(cl$CD_MUN6, nuc6)]
cl$at_nucleo <- sa$temperatura_aparente(cl$tmean, cl$rh_mean)
cl <- cl[, c("recorte_principal", "data", "tmax", "tmin", "tmean", "at_nucleo")]; names(cl)[3:4] <- c("tmax_nucleo", "tmin_nucleo")
ex <- merge(mm, cl, by = c("recorte_principal", "data"), all.x = TRUE, sort = FALSE)
ex <- merge(ex, sd[, c("recorte_principal", "data", "tmean_nucleo")], by = c("recorte_principal", "data"), sort = FALSE)
ok_tm <- confere(isTRUE(all.equal(ex$tmean, ex$tmean_nucleo, tolerance = 0)), "tmean do clima do núcleo ≠ tmean_nucleo da serie_diaria")

# lista da variante zero = NA (§2.3), na janela principal
jp_d <- sd$data >= JP[1] & sd$data <= JP[2]
pm <- do.call(rbind, lapply(ordem, function(r) { k <- mm$recorte_principal == r & mm$data >= JP[1] & mm$data <= JP[2]
  data.frame(recorte_principal = r, concentracao = unname(nome[r]), dias_janela = sum(k), dias_utilizaveis_zero_na = sum(!is.na(mm$pm25_local_zero_na_0_1[k])),
             na_variante_principal = sum(is.na(mm$pm25_local_0_1[k])), stringsAsFactors = FALSE) }))
pm$fracao <- pm$dias_utilizaveis_zero_na / pm$dias_janela; pm$entra <- pm$fracao >= 0.90
REG_FORA <- c("5002704", "5208707", "5300108")                         # registrado (decisões de 08/10, §10): Campo Grande, Goiânia, Brasília
ok_pm <- confere(setequal(pm$recorte_principal[!pm$entra], REG_FORA) && sum(pm$entra) == 23L, "lista do pm25_local_zero_na_nucleo difere da registrada")
ok_pm_p <- confere(all(pm$na_variante_principal == 0), "pm25_local_nucleo com NA na janela principal")

# ------------------------------------------------------------------ 2. nascimentos(): controles, w_j por ano, termo precoce
log_msg("nascimentos()")
n <- as.data.frame(nascimentos(c("CD_MUN6", "data", "ga_sem", "unico", "pop_ptb", "coorte_fixa_22", "dum_est")))
n$data <- D(n$data); n$dum_est <- D(n$dum_est)
n$recorte_principal <- conc$CD_RECORTE[match(n$CD_MUN6, conc$CD_MUN6)]; stopifnot(!anyNA(n$recorte_principal))
pop <- n$pop_ptb %in% TRUE & n$coorte_fixa_22 %in% TRUE
ok_pop <- confere(identical(pop, n$unico %in% TRUE & !is.na(n$ga_sem) & n$ga_sem >= 22 & n$ga_sem <= 42 & n$coorte_fixa_22 %in% TRUE), "pop_ptb & coorte_fixa_22 ≠ definição explícita")
ok_dum <- confere(all(n$dum_est[pop] == n$data[pop] - (7L * n$ga_sem[pop] + 3L)), "dum_est ≠ data − (7·ga_sem + 3)")
d0 <- D("2012-01-01"); d1 <- D("2024-12-31"); nd <- as.integer(d1 - d0) + 1L
conta <- function(sel) { k <- sel & n$data >= d0 & n$data <= d1; tabulate((match(n$recorte_principal[k], ordem) - 1L) * nd + as.integer(n$data[k] - d0) + 1L, nbins = 26L * nd) }
ref <- sd[sd$data >= d0 & sd$data <= d1, ]; ref <- ref[order(match(ref$recorte_principal, ordem), ref$data), ]; stopifnot(nrow(ref) == 26L * nd)
ok_nv <- confere(identical(as.integer(conta(pop)), as.integer(ref$nv_unicos)), "contagem de NV por nascimentos() ≠ nv_unicos da serie_diaria")
ok_ptb <- confere(identical(as.integer(conta(pop & n$ga_sem <= 36)), as.integer(ref$ptb)), "contagem de PTB por nascimentos() ≠ ptb da serie_diaria")
wj_re <- do.call(rbind, lapply(sort(unique(n$recorte_principal[pop])), function(r) data.frame(recorte_principal = r, of$calcula_wj(n$ga_sem[pop & n$recorte_principal == r], SEM))))
wj_o <- wj[order(wj$recorte_principal, wj$j), ]; wj_re <- wj_re[order(wj_re$recorte_principal, wj_re$j), ]
ok_wj <- confere(identical(wj_re$n_j, as.numeric(wj_o$n_j)) && identical(wj_re$N_j, as.numeric(wj_o$N_j)) && max(abs(wj_re$w_j - wj_o$w_j)) <= 1e-15, "w_j recalculado ≠ CSV da Fase 1")
wj_ano <- do.call(rbind, lapply(ordem, function(r) { k <- pop & n$recorte_principal == r; data.frame(recorte_principal = r, of$calcula_wj_ano(n$ga_sem[k], n$dum_est[k], SEM)) }))
wj_pd <- do.call(rbind, lapply(ordem, function(r) data.frame(recorte_principal = r, concentracao = unname(nome[r]), of$calcula_wj_pd(n$ga_sem[pop & n$recorte_principal == r], SEM_TP))))
tp_k <- pop & n$ga_sem %in% SEM_TP & n$data >= TP_GRAV[1] & n$data <= TP_GRAV[2]; nd_tp <- as.integer(TP_GRAV[2] - TP_GRAV[1]) + 1L
tp_cont <- tabulate((match(n$recorte_principal[tp_k], ordem) - 1L) * nd_tp + as.integer(n$data[tp_k] - TP_GRAV[1]) + 1L, nbins = 26L * nd_tp)
rm(n); invisible(gc())

# ------------------------------------------------------------------ 3. Z_tj e offsets
log_msg("gestacoes_em_risco() e offsets")
z <- as.data.frame(gestacoes_em_risco(nivel = "recorte")); z$data <- D(z$data); stopifnot(min(z$data) == D("2012-01-01"))
z <- z[z$data <= TP[2] & z$semana %in% c(SEM, SEM_TP), c("recorte_principal", "data", "semana", "z_nv", "z_fetal")]
d11 <- seq(GRAV[1], D("2011-12-31"), by = "day")
z <- rbind(z, data.frame(recorte_principal = rep(ordem, each = length(d11)), data = rep(d11, times = 26), semana = 22L, z_nv = 0L, z_fetal = 0L, stringsAsFactors = FALSE))
wmain <- function(r) wj[wj$recorte_principal == r, c("j", "w_j")]
off <- function(r, zcol, semanas, w, periodo, faixa) {
  zz <- z[z$recorte_principal == r & z$data >= faixa[1] & z$data <= faixa[2], ]
  o <- of$monta_offset(data.frame(data = zz$data, semana = zz$semana, z = if (zcol == "soma") zz$z_nv + zz$z_fetal else zz[[zcol]]), w, semanas, periodo = periodo)
  list(o = o, sem_w = attr(o, "termos_sem_w"))
}
novos <- list(); n_sem_w <- 0
for (r in ordem) {
  fe <- off(r, "soma", SEM, wmain(r), JE, GRAV)$o
  a <- off(r, "z_nv", SEM, wj_ano[wj_ano$recorte_principal == r, c("ano", "j", "w_j")], JE, GRAV); n_sem_w <- n_sem_w + if (is.null(a$sem_w)) 0 else a$sem_w
  b <- data.frame(recorte_principal = r, data = fe$data, z_t_fetal = fe$z_t, w_t_fetal = fe$w_t, log_z_fetal = fe$log_z, log_w_fetal = fe$log_w, log_zw_fetal = fe$log_zw,
                  w_t_ano = a$o$w_t[match(fe$data, a$o$data)], log_w_ano = a$o$log_w[match(fe$data, a$o$data)], log_zw_ano = a$o$log_zw[match(fe$data, a$o$data)], stringsAsFactors = FALSE)
  for (k in names(SUB)) { o <- off(r, "z_nv", SUB[[k]], wmain(r), JP, GRAV)$o; i <- match(b$data, o$data)
    b[[paste0("z_t_", k)]] <- o$z_t[i]; b[[paste0("log_z_", k)]] <- o$log_z[i]; b[[paste0("log_w_", k)]] <- o$log_w[i]; b[[paste0("log_zw_", k)]] <- o$log_zw[i] }
  zr <- z[z$recorte_principal == r & z$semana %in% SEM & z$data <= GRAV[2], ]
  for (j in SEM) { zj <- zr[zr$semana == j, ]; v <- zj$z_nv[match(b$data, zj$data)]; v[is.na(v)] <- 0L; b[[paste0("z", j)]] <- as.integer(v) }
  novos[[r]] <- b
}
novos <- do.call(rbind, novos)

# ------------------------------------------------------------------ 4. série do PTB da Fase 4
serie <- merge(s1, novos, by = c("recorte_principal", "data"), all.x = TRUE, sort = FALSE)
serie <- merge(serie, ex[, c("recorte_principal", "data", "tmax_nucleo", "tmin_nucleo", "at_nucleo", "cn_tmean_1_7", "rh_media_0_3", "pm25_local_0_1", "pm25_local_zero_na_0_1")],
               by = c("recorte_principal", "data"), all.x = TRUE, sort = FALSE)
serie <- serie[order(serie$recorte_principal, serie$data), ]; rownames(serie) <- NULL
ok_orig <- confere(identical(serie[, names(s1)], s1), "colunas da série principal mudaram no merge")
zsum <- rowSums(as.matrix(serie[, paste0("z", SEM)]))
ok_zsum <- confere(identical(as.numeric(zsum), as.numeric(serie$z_t)), "Σ z22…z36 ≠ z_t da série principal")
ok_sub <- confere(isTRUE(all.equal(serie$z_t_extremo + serie$z_t_muito + serie$z_t_moderado_tardio, as.numeric(serie$z_t), check.attributes = FALSE)), "Σ dos Z_t dos subtipos ≠ Z_t")
jp <- serie$janela_principal; je <- serie$janela_evento_possivel
na_jp <- vapply(c("tmax_nucleo", "tmin_nucleo", "at_nucleo", "cn_tmean_1_7", "rh_media_0_3", "pm25_local_0_1", "log_z_fetal", "log_w_fetal", "log_w_ano",
                  paste0("log_z_", names(SUB)), paste0("log_w_", names(SUB))), function(k) sum(is.na(serie[[k]][jp])), 0L)
ok_na <- confere(all(na_jp == 0), "NA na janela principal numa coluna nova")
ok_fe <- confere(all(serie$z_t_fetal[je] >= serie$z_t[je]) && all(is.na(serie$log_zw_fetal[!je])), "Z_t com z_fetal < Z_t ou offset fora da janela")

# ------------------------------------------------------------------ 5. série do termo precoce
datas_tp <- seq(TP_GRAV[1], TP_GRAV[2], by = "day")
tp <- data.frame(recorte_principal = rep(ordem, each = nd_tp), data = rep(datas_tp, times = 26), termo_precoce = as.integer(tp_cont), stringsAsFactors = FALSE)
otp <- do.call(rbind, lapply(ordem, function(r) { o <- off(r, "z_nv", SEM_TP, setNames(wj_pd$w_j[wj_pd$recorte_principal == r], SEM_TP), TP, TP_GRAV)$o
  zr <- z[z$recorte_principal == r & z$semana %in% SEM_TP, ]
  data.frame(recorte_principal = r, data = o$data, z37 = { v <- zr$z_nv[zr$semana == 37][match(o$data, zr$data[zr$semana == 37])]; v[is.na(v)] <- 0L; as.integer(v) },
             z38 = { v <- zr$z_nv[zr$semana == 38][match(o$data, zr$data[zr$semana == 38])]; v[is.na(v)] <- 0L; as.integer(v) },
             z_t = o$z_t, w_t = o$w_t, log_z = o$log_z, log_w = o$log_w, log_zw = o$log_zw, z_t_zero = o$z_t_zero, stringsAsFactors = FALSE) }))
tp <- merge(tp, otp, by = c("recorte_principal", "data"), all.x = TRUE, sort = FALSE)
tp <- merge(tp, sd[, c("recorte_principal", "data", "tmean_nucleo")], by = c("recorte_principal", "data"), all.x = TRUE, sort = FALSE)
cal <- as.data.frame(calendario()); cal$data <- D(cal$data)
cal <- cal[, c("data", "ano", "mes", "dia_semana", "feriado_nacional", "carnaval", "quarta_cinzas", "sexta_paixao", "corpus_christi")]
tp <- merge(tp, cal, by = "data", all.x = TRUE, sort = FALSE)
tp$dia_semana <- factor(tp$dia_semana, levels = 1:7, labels = c("seg", "ter", "qua", "qui", "sex", "sab", "dom"))
tp$moveis <- as.integer(tp$quarta_cinzas == 1 | tp$sexta_paixao == 1 | tp$corpus_christi == 1)
tp$feriado_nacional <- as.integer(tp$feriado_nacional); tp$carnaval <- as.integer(tp$carnaval); tp$ano <- as.integer(tp$ano); tp$mes <- as.integer(tp$mes)
tp$estrato <- paste(tp$recorte_principal, tp$ano, sprintf("%02d", tp$mes), sep = "_")
tp$janela_termo <- tp$data >= TP[1] & tp$data <= TP[2]; tp$janela_intersecao <- tp$data >= TPI[1] & tp$data <= TPI[2]
tp <- tp[order(tp$recorte_principal, tp$data), c("recorte_principal", "data", "termo_precoce", "z37", "z38", "z_t", "w_t", "log_z", "log_w", "log_zw", "z_t_zero",
                                                 "tmean_nucleo", "dia_semana", "feriado_nacional", "carnaval", "moveis", "ano", "mes", "estrato", "janela_termo", "janela_intersecao")]
rownames(tp) <- NULL
ok_tp <- confere(nrow(tp) == 26L * nd_tp && !anyNA(tp$tmean_nucleo) && !anyNA(tp$log_zw[tp$janela_termo]) && all(tp$z_t[tp$janela_termo] > 0) &&
                 all(is.na(tp$log_zw[!tp$janela_termo])) && !anyNA(tp$dia_semana) && identical(as.numeric(tp$z37 + tp$z38), as.numeric(tp$z_t)), "série do termo precoce incompleta")

# ------------------------------------------------------------------ gravação e log
ok <- length(falhas) == 0
if (ok) {
  saveRDS(serie, f_out[["serie"]]); saveRDS(tp, f_out[["termo"]])
  utils::write.csv(wj_ano, f_out[["wj_ano"]], row.names = FALSE); utils::write.csv(wj_pd, f_out[["wj_pd"]], row.names = FALSE); utils::write.csv(pm, f_out[["pm25"]], row.names = FALSE)
}
sha_out <- vapply(f_out, function(p) if (file.exists(p)) sha(p) else "(não gravado)", "")
stopifnot(versao() == "4443971b"); v_fim <- versao()
tipo <- function(x) if (is.factor(x)) "factor" else class(x)[1]
novas <- setdiff(names(serie), names(s1))
conf <- data.frame(Conferência = c("SHA-256 das entradas da Fase 1 contra a RESPOSTA", "Colunas da chave 1 e da chave 6 presentes", "Chave 1: nenhum dia com Z_t = 0 dentro do ajuste (linha_modelo)",
                                   "tmean do clima do núcleo = tmean_nucleo da serie_diaria", "Lista do pm25_local_zero_na_nucleo = registrada (23; saem Campo Grande, Goiânia, Brasília)",
                                   "pm25_local_nucleo completo na janela principal", "pop_ptb & coorte_fixa_22 = definição explícita", "dum_est = data − (7·ga_sem + 3)",
                                   "NV por nascimentos() = nv_unicos da serie_diaria (2012–2024, todos os dias)", "PTB por nascimentos() = ptb da serie_diaria (2012–2024, todos os dias)",
                                   "w_j recalculado = CSV da Fase 1", "Colunas da série principal intactas (identical)", "Σ z22…z36 = z_t da série principal",
                                   "Σ dos Z_t dos subtipos = Z_t", "Sem NA na janela principal nas colunas novas", "Z_t com z_fetal ≥ Z_t; offset NA fora da janela de evento possível",
                                   "Série do termo precoce completa (Z_t > 0 e offset na janela; z37 + z38 = Z_t)"),
                   Confere = ifelse(c(ok_f1, ok_cols_c1, ok_lm, ok_tm, ok_pm, ok_pm_p, ok_pop, ok_dum, ok_nv, ok_ptb, ok_wj, ok_orig, ok_zsum, ok_sub, ok_na, ok_fe, ok_tp), "sim", "NÃO"), check.names = FALSE)
md <- c("# Fase 4, Parte B1.3: séries de exposição e de offset", "",
  sprintf("- **Gerado por:** `00_scripts/66_series_exposicao_offset_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()` no início: %s; no fim: %s.",
          sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini, v_fim),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Código (igual ao das tags):** `offset.R` `%s` (`offset-v1.1`); `sens_agudos.R` `%s` (`sens_agudos-v1.0`); `segunda_etapa.R` `%s` (`segunda_etapa-v1.1`; só a ordem das 26).", sha_cod[["offset"]], sha_cod[["sens_agudos"]], sha_cod[["segunda_etapa"]]),
  "- **Entradas da Fase 1 (SHA-256 conferido contra a RESPOSTA da Fase 1; reconstruídas no 64):**", sprintf("  - `%s`: `%s`;", f1, sha_f1), "",
  "## Conferências", "", tabela_md(conf), "",
  "## Lista do `pm25_local_zero_na_nucleo` (§2.3; janela principal, 4.498 dias)", "",
  tabela_md(data.frame(Concentração = pm$concentracao, `Dias utilizáveis (média de lag 0–1)` = br(pm$dias_utilizaveis_zero_na), `%` = br(100 * pm$fracao, 1),
                       Entra = ifelse(pm$entra, "sim", "não"), check.names = FALSE)), "",
  sprintf("- **Resultado:** %d concentrações entram; saem %s. A falta não é aleatória: os dias sem valor são episódios com todas as células em zero (concentração baixa; §2.3, declarar).",
          sum(pm$entra), paste(pm$concentracao[!pm$entra], collapse = ", ")), "",
  "## Chave 1 e chave 6 (séries da Fase 1)", "",
  sprintf("- **Chave 1:** `serie_ptb_municipal.rds` da Fase 1 (offset com `periodo = NULL`, w_j da concentração); dias-município com Z_t = 0 na janela principal: %s, todos fora do ajuste (`linha_modelo` = FALSE). Nós e eixo: o 65.", br(n_mun_zero_jp)),
  "- **Chave 6:** `serie_ptb_espontaneo.rds` da Fase 1, com `ptb_espontaneo_i` (espontâneos), `ptb_espontaneo_ii` (espontâneos + ignorados), `ptb_iniciado` e `ptb_ignorado`; Z_t, w_j e janela do principal. As contagens por concentração saem no 68.", "",
  "## Colunas novas da `serie_ptb_fase4.rds`", "",
  tabela_md(data.frame(Coluna = paste0("`", novas, "`"), Tipo = vapply(serie[novas], tipo, ""), check.names = FALSE)), "",
  sprintf("- **w_j por ano:** células (dia, semana) com Z_tj > 0 sem w no ano de t (N = 0): %s; o termo sai de Σ_j Z_tj·w_j (D12, 4.2).", br(n_sem_w)),
  sprintf("- **Linhas:** %s (26 × %s dias, 2011-12-14 a 2024-11-15), as mesmas da série principal.", br(nrow(serie)), br(nrow(serie) / 26)), "",
  "## Série do termo precoce (`serie_termo_precoce_fase4.rds`)", "",
  sprintf("- 26 × %s dias (2012-04-21 a 2024-11-19: 7 de aquecimento e a janela de 2012-04-28 a 2024-11-19); desfecho = NV únicos da coorte fixa 22 com `ga_sem` 37–38, pela data do nascimento; Z_t = `z_nv` nas semanas 37–38; w_j por pessoa-dia (`calcula_wj_pd`, semanas 37–38, população do principal, por concentração); offset com γ = 1 em `log_zw` (γ pela regra única no 68); `janela_intersecao` = 2012-04-28 a 2024-08-06.", br(nd_tp)), "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", f_out, sha_out), "",
  sprintf("- **Resultado:** %s. Tempo: %.0f s.", if (ok) "todas as conferências passam" else paste("FALHA: PARE —", paste(falhas, collapse = "; ")), as.numeric(difftime(Sys.time(), t0, units = "secs"))), "")
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| conferências:", if (ok) "ok" else paste("FALHA:", paste(falhas, collapse = "; ")), "\n")
if (!ok) quit(status = 1)
