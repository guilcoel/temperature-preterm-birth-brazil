# 67_ig_dum_e_2011_fase4.R — Fase 4, Parte B1.4: §3.5 (sensibilidade restrita aos nascimentos com IG datada pela DUM) e
# 2011 (mensagem da Parte B do chat do A1, 18/10/2026, item B1.4; plano da Fase 4, script 67; especificação v2.0.2, §3.5
# e §3.6; decisões de 08/10, §12; D12, 4.3; P7 aceita na mensagem de respostas ao plano). Nenhum modelo de desfecho.
# 1. Z_tj próprio a partir de nascimentos(): a gestação de início s e IG g (término = s + 7g + 3 = data do nascimento)
#    está na semana j no dia t quando ⌊(t − s)/7⌋ = j e o término é ≥ t (definição da base; especificação §3.1). Logo
#    Z_tj(t) = Σ_{d=0}^{6} #{s = t − 7j − d, g > j} + Σ_{d=0}^{3} #{s = t − 7j − d, g = j}, calculado por somas acumuladas
#    em s (função z_proprio abaixo).
#    CONTROLE OBRIGATÓRIO: o mesmo cálculo na população inteira (pop_ptb & coorte_fixa_22, s = dum_est, g = ga_sem)
#    reproduz o z_nv do gestacoes_em_risco(nivel = "recorte") exatamente (identical), em todas as concentrações, dias de
#    2012-01-01 a 2024-12-31 e semanas de 22 a 42. Se não reproduzir: PARE (grava o log e quit(status = 1)).
# 2. §3.5, decisões de 08/10, §12:
#    - elegibilidade (igual nas duas versões): NV únicos com ga_sem de 22 a 42, ig_dum_sem de 22 a 42 e
#      |ga_sem − ig_dum_sem| ≤ 1;
#    - versão (i): IG = ga_sem, s = dum_est da base (= data − (7·ga_sem + 3)), coorte fixa com s de 2011-07-31 a
#      2024-03-05 (§5), a partir de todos os elegíveis (conferido: igual à coorte_fixa_22 da base nos elegíveis);
#      PTB = ga_sem ≤ 36;
#    - versão (ii): IG = ig_dum_sem, s = data − (7·ig_dum_sem + 3), a mesma coorte fixa de datas; PTB = ig_dum_sem ≤ 36;
#    - em cada versão: Z_tj próprio (semanas 22–36) e w_j recalculado (calcula_wj, por concentração) na subpopulação;
#      offset por monta_offset() com periodo = janela principal (2012-04-14 a 2024-08-06; Z_t > 0 em todos os dias,
#      senão PARE); γ segue a regra do principal (estimado).
# 3. 2011 (§3.6; P7): braço A de 2011-01-01 a 2024-12-31 e braço B de 2012-01-01 a 2024-12-31 (data do parto), 7 dias de
#    aquecimento em cada, sem offset e sem coorte fixa; desfecho = gestacao_cat ∈ {2, 3, 4} entre os NV únicos com
#    gestacao_cat ∈ {2, …, 6}; calendário e estratos da §3.1; nós e eixo do principal (D12, 4.3; ficam com a C3).
#    Controle: em 2011, as duas contagens são identical às colunas ptb_gestacao_sens2011 e nv_gestacao_sens2011 da
#    serie_diaria(nivel = "recorte", coorte_fixa = FALSE) (o braço não tem coorte fixa).
# Grava, fora do git, em 01_saidas/fase4/: serie_ig_dum_fase4.rds (grade da série principal, 2011-12-14 a 2024-11-15, com
#   exposição, calendário e estratos do principal, mais ptb_dum_i, ptb_dum_ii, nv_dum_i, nv_dum_ii e o offset de cada
#   versão), serie_2011_gestacao_fase4.rds (2010-12-25 a 2024-12-31) e wj_ig_dum_fase4.csv.
# Sigilo: séries e CSV com contagens ficam na Forja, fora do git; o log traz só conferências e percentuais agregados por
#   concentração na janela inteira; as contagens por concentração saem no 68, com "<10". Nada diário.
# Confere antes: este script commitado e limpo; offset.R e segunda_etapa.R iguais aos das tags.
# Grava logs/ig_dum_e_2011_fase4_<RODADA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/67_ig_dum_e_2011_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("ig_dum_e_2011_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase4"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
f_out <- c(dum = "serie_ig_dum_fase4.rds", g2011 = "serie_2011_gestacao_fase4.rds", wj = "wj_ig_dum_fase4.csv")
f_out <- setNames(file.path(OUT, f_out), names(f_out)); for (p in f_out) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/67_ig_dum_e_2011_fase4.R"
CC <- file.path(REPO, "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")

sujos <- git("status", "--porcelain", "--", ESTE)
if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current")
st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:")
stopifnot(length(head_c) == 1L, length(ramo) == 1L, length(coord) == 1L)
inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"); t0 <- Sys.time()
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
COD <- c(offset = "offset-v1.1", segunda_etapa = "segunda_etapa-v1.1")
sha_cod <- vapply(names(COD), function(k) sha(file.path(CC, "R", paste0(k, ".R"))), "")
for (k in names(COD)) if (!identical(sha_cod[[k]], tag_sha(COD[[k]], paste0("codigo_compartilhado/R/", k, ".R")))) stop(k, ".R difere da tag ", COD[[k]])
of <- new.env(); sys.source(file.path(CC, "R", "offset.R"), envir = of)
se <- new.env(); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = se)

D <- as.Date
GRAV <- D(c("2011-12-14", "2024-11-15")); JP <- D(c("2012-04-14", "2024-08-06")); COORTE <- D(c("2011-07-31", "2024-03-05"))
SEM <- 22:36; SEM_TODAS <- 22:42
nuc <- as.data.frame(cidade_nucleo()); se$confere_ordem(nuc$CD_RECORTE); ordem <- se$ORDEM_CONCENTRACOES; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
conc <- as.data.frame(concentracoes())[, c("CD_MUN6", "CD_RECORTE")]
falhas <- character(0); confere <- function(cond, txt) { if (!isTRUE(cond)) falhas <<- c(falhas, txt); isTRUE(cond) }

# Z_tj próprio: matriz dias × semanas, por somas acumuladas em s
z_proprio <- function(s, g, datas, semanas) {
  s0 <- min(s, datas) - 7L * max(semanas) - 7L; si <- as.integer(s - s0) + 1L; ns <- as.integer(max(datas) - s0) + 1L
  stopifnot(all(si >= 1L)); si <- pmin(si, ns + 1L)                  # inícios depois do último dia não contam em nenhuma janela
  td <- as.integer(datas - s0) + 1L
  sapply(semanas, function(j) {
    cA <- c(0, cumsum(tabulate(si[g > j], nbins = ns + 1L))); cB <- c(0, cumsum(tabulate(si[g == j], nbins = ns + 1L)))
    hi <- td - 7L * j; jan <- function(cs, lo, hi) { lo <- pmax(lo, 1L); ifelse(hi >= lo, cs[hi + 1L] - cs[lo], 0) }
    jan(cA, hi - 6L, hi) + jan(cB, hi - 3L, hi)
  })
}

# ------------------------------------------------------------------ leitura
log_msg("nascimentos()")
n <- as.data.frame(nascimentos(c("CD_MUN6", "data", "unico", "ga_sem", "ig_dum_sem", "dum_est", "pop_ptb", "coorte_fixa_22", "gestacao_cat")))
n$data <- D(n$data); n$dum_est <- D(n$dum_est)
n$recorte_principal <- conc$CD_RECORTE[match(n$CD_MUN6, conc$CD_MUN6)]; stopifnot(!anyNA(n$recorte_principal))
pop <- n$pop_ptb %in% TRUE & n$coorte_fixa_22 %in% TRUE

# ------------------------------------------------------------------ 1. controle: população inteira contra o gestacoes_em_risco
log_msg("controle do Z_tj próprio")
d_ctl <- seq(D("2012-01-01"), D("2024-12-31"), by = "day")
z <- as.data.frame(gestacoes_em_risco(nivel = "recorte")); z$data <- D(z$data)
ctl <- vapply(ordem, function(r) {
  k <- pop & n$recorte_principal == r
  mp <- z_proprio(n$dum_est[k], n$ga_sem[k], d_ctl, SEM_TODAS)
  zr <- z[z$recorte_principal == r, ]; mb <- matrix(0L, length(d_ctl), length(SEM_TODAS))
  ii <- cbind(match(zr$data, d_ctl), match(zr$semana, SEM_TODAS)); ok <- !is.na(ii[, 1]) & !is.na(ii[, 2])
  stopifnot(all(ok)); mb[ii] <- zr$z_nv
  identical(matrix(as.integer(round(mp)), nrow(mp)), mb) && all(mp == round(mp))
}, TRUE)
ok_ctl <- confere(all(ctl), paste0("Z_tj próprio NÃO reproduz o gestacoes_em_risco em: ", paste(nome[ordem[!ctl]], collapse = ", ")))
log_msg("controle:", sum(ctl), "de 26")

# ------------------------------------------------------------------ 2. §3.5, versões (i) e (ii)
eleg <- n$unico %in% TRUE & !is.na(n$ga_sem) & n$ga_sem >= 22 & n$ga_sem <= 42 & !is.na(n$ig_dum_sem) & n$ig_dum_sem >= 22 & n$ig_dum_sem <= 42 & abs(n$ga_sem - n$ig_dum_sem) <= 1
s_i <- n$dum_est; s_ii <- n$data - (7L * as.integer(n$ig_dum_sem) + 3L)
ok_si <- confere(all(s_i[eleg] == n$data[eleg] - (7L * n$ga_sem[eleg] + 3L)), "dum_est ≠ data − (7·ga_sem + 3) nos elegíveis")
pop_i <- eleg & s_i >= COORTE[1] & s_i <= COORTE[2]; pop_ii <- eleg & s_ii >= COORTE[1] & s_ii <= COORTE[2]
ok_coorte <- confere(identical(pop_i, eleg & n$coorte_fixa_22 %in% TRUE), "coorte da versão (i) ≠ coorte_fixa_22 da base nos elegíveis")
datas_g <- seq(GRAV[1], GRAV[2], by = "day"); nd <- length(datas_g)
conta <- function(sel) tabulate((match(n$recorte_principal[sel], ordem) - 1L) * nd + as.integer(n$data[sel] - GRAV[1]) + 1L, nbins = 26L * nd)
dentro <- n$data >= GRAV[1] & n$data <= GRAV[2]
s1 <- readRDS(file.path("01_saidas", "fase1", "serie_ptb_principal.rds"))
base <- s1[order(match(s1$recorte_principal, ordem), s1$data), c("recorte_principal", "data", "tmean_nucleo", "dia_semana", "feriado_nacional", "carnaval", "moveis", "ano", "mes", "estrato", "janela_principal")]
stopifnot(nrow(base) == 26L * nd, all(base$data == rep(datas_g, times = 26)))
base$ptb_dum_i <- conta(dentro & pop_i & n$ga_sem <= 36); base$ptb_dum_ii <- conta(dentro & pop_ii & n$ig_dum_sem <= 36)
base$nv_dum_i <- conta(dentro & pop_i); base$nv_dum_ii <- conta(dentro & pop_ii)
wjv <- list(); ok_off <- TRUE
for (v in c("i", "ii")) {
  pv <- if (v == "i") pop_i else pop_ii; gv <- if (v == "i") n$ga_sem else as.integer(n$ig_dum_sem); sv <- if (v == "i") s_i else s_ii
  for (r in ordem) {
    k <- pv & n$recorte_principal == r
    w <- of$calcula_wj(gv[k], SEM); wjv[[paste(v, r)]] <- data.frame(versao = v, recorte_principal = r, w)
    m <- z_proprio(sv[k], gv[k], datas_g, SEM)
    zl <- data.frame(data = rep(datas_g, times = length(SEM)), semana = rep(SEM, each = nd), z = as.vector(m))
    o <- tryCatch(of$monta_offset(zl, w, SEM, periodo = JP), error = function(e) e)
    if (inherits(o, "error")) { ok_off <- FALSE; falhas <- c(falhas, paste0("offset da versão (", v, ") em ", nome[[r]], ": ", conditionMessage(o))); next }
    i <- base$recorte_principal == r; stopifnot(length(o$data) == nd, all(o$data == datas_g))
    for (cc in c("z_t", "w_t", "log_z", "log_w", "log_zw")) base[[paste0(cc, "_", v)]][i] <- o[[cc]]
  }
}
wjv <- do.call(rbind, wjv); rownames(wjv) <- NULL
jp <- base$janela_principal
ok_jp <- confere(ok_off && !anyNA(base$log_zw_i[jp]) && !anyNA(base$log_zw_ii[jp]) && all(base$z_t_i[jp] > 0) && all(base$z_t_ii[jp] > 0), "offset das versões da §3.5 incompleto na janela principal")
cob <- do.call(rbind, lapply(ordem, function(r) { i <- base$recorte_principal == r & jp
  data.frame(concentracao = unname(nome[r]), nv_i = sum(base$nv_dum_i[i]), nv_ii = sum(base$nv_dum_ii[i]), ptb_i = sum(base$ptb_dum_i[i]), ptb_ii = sum(base$ptb_dum_ii[i])) }))
nv_pr <- vapply(ordem, function(r) sum(s1$nv_unicos[s1$recorte_principal == r & s1$janela_principal]), 0)
ptb_pr <- vapply(ordem, function(r) sum(s1$ptb[s1$recorte_principal == r & s1$janela_principal]), 0)

# ------------------------------------------------------------------ 3. 2011 por GESTACAO (§3.6; P7)
log_msg("2011")
d11 <- seq(D("2010-12-25"), D("2024-12-31"), by = "day"); nd11 <- length(d11)
p11 <- n$unico %in% TRUE & n$gestacao_cat %in% c("2", "3", "4", "5", "6"); e11 <- p11 & n$gestacao_cat %in% c("2", "3", "4")
conta11 <- function(sel) tabulate((match(n$recorte_principal[sel], ordem) - 1L) * nd11 + as.integer(n$data[sel] - d11[1]) + 1L, nbins = 26L * nd11)
g11 <- data.frame(recorte_principal = rep(ordem, each = nd11), data = rep(d11, times = 26), ptb_gestacao = conta11(e11), nv_gestacao = conta11(p11), stringsAsFactors = FALSE)
sdf <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = FALSE, colunas = c("recorte_principal", "data", "ptb_gestacao_sens2011", "nv_gestacao_sens2011", "tmean_nucleo")))
sdf$data <- D(sdf$data)
g11 <- merge(g11, sdf, by = c("recorte_principal", "data"), all.x = TRUE, sort = FALSE)
g11 <- g11[order(match(g11$recorte_principal, ordem), g11$data), ]
a11 <- format(g11$data, "%Y") == "2011"
ok_11 <- confere(identical(as.integer(g11$ptb_gestacao[a11]), as.integer(g11$ptb_gestacao_sens2011[a11])) && identical(as.integer(g11$nv_gestacao[a11]), as.integer(g11$nv_gestacao_sens2011[a11])),
                 "2011: contagem por gestacao_cat ≠ ptb/nv_gestacao_sens2011 da serie_diaria sem coorte fixa")
g11$ptb_gestacao_sens2011 <- NULL; g11$nv_gestacao_sens2011 <- NULL
cal <- as.data.frame(calendario()); cal$data <- D(cal$data)
cal <- cal[, c("data", "ano", "mes", "dia_semana", "feriado_nacional", "carnaval", "quarta_cinzas", "sexta_paixao", "corpus_christi")]
g11 <- merge(g11, cal, by = "data", all.x = TRUE, sort = FALSE)
g11$dia_semana <- factor(g11$dia_semana, levels = 1:7, labels = c("seg", "ter", "qua", "qui", "sex", "sab", "dom"))
g11$moveis <- as.integer(g11$quarta_cinzas == 1 | g11$sexta_paixao == 1 | g11$corpus_christi == 1)
g11$feriado_nacional <- as.integer(g11$feriado_nacional); g11$carnaval <- as.integer(g11$carnaval); g11$ano <- as.integer(g11$ano); g11$mes <- as.integer(g11$mes)
g11$estrato <- paste(g11$recorte_principal, g11$ano, sprintf("%02d", g11$mes), sep = "_")
g11$braco_A <- g11$data >= D("2011-01-01"); g11$braco_B <- g11$data >= D("2012-01-01")
g11 <- g11[order(match(g11$recorte_principal, ordem), g11$data), c("recorte_principal", "data", "ptb_gestacao", "nv_gestacao", "tmean_nucleo", "dia_semana", "feriado_nacional",
                                                                    "carnaval", "moveis", "ano", "mes", "estrato", "braco_A", "braco_B")]
rownames(g11) <- NULL
ok_g11 <- confere(nrow(g11) == 26L * nd11 && !anyNA(g11$tmean_nucleo) && !anyNA(g11$dia_semana), "série de 2011 incompleta")
rm(n); invisible(gc())

# ------------------------------------------------------------------ gravação e log
ok <- length(falhas) == 0
if (ok) { saveRDS(base, f_out[["dum"]]); saveRDS(g11, f_out[["g2011"]]); utils::write.csv(wjv, f_out[["wj"]], row.names = FALSE) }
sha_out <- vapply(f_out, function(p) if (file.exists(p)) sha(p) else "(não gravado)", "")
stopifnot(versao() == "4443971b"); v_fim <- versao()
conf <- data.frame(Conferência = c("**Controle obrigatório:** Z_tj próprio na população inteira = `z_nv` do `gestacoes_em_risco(recorte)`, 26 concentrações, 2012-01-01 a 2024-12-31, semanas 22–42 (`identical`)",
                                   "`dum_est` = data − (7·`ga_sem` + 3) nos elegíveis", "Coorte da versão (i) = `coorte_fixa_22` da base nos elegíveis",
                                   "Offset das versões (i) e (ii): Z_t > 0 e offset sem NA em todos os dias da janela principal",
                                   "2011: contagens = `ptb_gestacao_sens2011` e `nv_gestacao_sens2011` da `serie_diaria(coorte_fixa = FALSE)` (`identical`)", "Série de 2011 completa"),
                   Confere = ifelse(c(ok_ctl, ok_si, ok_coorte, ok_jp, ok_11, ok_g11), "sim", "NÃO"), check.names = FALSE)
pc <- function(a, b) br(100 * a / b, 1)
md <- c("# Fase 4, Parte B1.4: §3.5 (IG datada pela DUM) e 2011", "",
  sprintf("- **Gerado por:** `00_scripts/67_ig_dum_e_2011_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()` no início: %s; no fim: %s.",
          sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini, v_fim),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Código (igual ao das tags):** `offset.R` `%s` (`offset-v1.1`); `segunda_etapa.R` `%s` (`segunda_etapa-v1.1`; só a ordem das 26).", sha_cod[["offset"]], sha_cod[["segunda_etapa"]]), "",
  "## Conferências", "", tabela_md(conf), "",
  "## §3.5: cobertura das versões na janela principal (percentual da população e dos PTB do principal; as contagens saem no 68)", "",
  tabela_md(data.frame(Concentração = cob$concentracao, `NV (i), % do principal` = pc(cob$nv_i, nv_pr), `NV (ii), %` = pc(cob$nv_ii, nv_pr),
                       `PTB (i), % do principal` = pc(cob$ptb_i, ptb_pr), `PTB (ii), %` = pc(cob$ptb_ii, ptb_pr), check.names = FALSE)), "",
  "- Elegibilidade comum: NV únicos com `ga_sem` e `ig_dum_sem` de 22 a 42 e |`ga_sem` − `ig_dum_sem`| ≤ 1; cada versão com a sua coorte fixa (datas da §5) a partir de todos os elegíveis; Z_t (semanas 22–36) e w_j recalculados na subpopulação de cada versão; offset na janela principal.", "",
  "## 2011 (§3.6; P7)", "",
  "- Série de 2010-12-25 a 2024-12-31 (7 dias de aquecimento antes de 2011-01-01); braço A de 2011-01-01 a 2024-12-31 e braço B de 2012-01-01 a 2024-12-31 (colunas `braco_A` e `braco_B`); `ptb_gestacao` = `gestacao_cat` ∈ {2, 3, 4} entre os NV únicos com `gestacao_cat` ∈ {2, …, 6}; sem offset e sem coorte fixa; calendário e estratos da §3.1.", "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", f_out, sha_out), "",
  sprintf("- **Resultado:** %s. Tempo: %.0f s.", if (ok) "todas as conferências passam" else paste("FALHA: PARE —", paste(falhas, collapse = "; ")), as.numeric(difftime(Sys.time(), t0, units = "secs"))), "")
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| conferências:", if (ok) "ok" else paste("FALHA:", paste(falhas, collapse = "; ")), "\n")
if (!ok) quit(status = 1)
