# 86_figuras_m3_fase4.R — Fase 4, marco M3: figuras do manuscrito (A1-123). Só lê saídas gravadas (SHA-256 conferido);
# nenhum ajuste. R base (sem ggplot2, que não está no renv): PDF vetorial pelo dispositivo quartz com Arial embutida (conferido
# no fim com pypdf) e PNG a 300 dpi só para revisão interna. Rótulos em inglês americano.
#   fig01: curva combinada cumulativa (lag 0–7), RR contra a TMR combinada, no eixo médio de p1 a p99, com IC 95%;
#   fig02: lag-resposta combinada no p99 e no p1 contra a TMR, com IC 95%;
#   fig03: as 26 curvas BLUP, cada uma na grade p1–p99 da própria concentração, contra a TMR BLUP, com IC 95%
#          (segunda_etapa::curva com os coeficientes e a vcov BLUP do 45 e a argvar da 1ª etapa do 32);
#   fig04: forest das sensibilidades, RR no x99 e no x1 com IC 95% (primário, chaves da C1, D3, C3, feriados locais e C4,
#          da tabela de sensibilidades v2 e da tabela do critério da C1); borda = 1 sem IC, marcada.
# Saídas (fora do git): figuras/fig0N_<nome>_v1_<RODADA>.pdf e .png. Log logs/figuras_m3_fase4_<RODADA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/86_figuras_m3_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
VERSAO <- "v4"   # v2: correções da auditoria do M3 (A1-124): letras maiores, MRT marcada com ponto, primário com círculo cheio, rótulos da E9 e UF; v3: padrão da revista (A1-151): 190 mm de largura, corpo ≥ 7 pt medido no PDF, Fig. 4 mais baixa e sem a nota interna, PNG com fundo branco; v4: o título longo da Fig. 3 (São José dos Campos/SP) saiu cortado na v3: cex do título ajustado à largura do painel, com mínimo de 0,9 (7,1 pt), e xpd
arq <- file.path("logs", paste0("figuras_m3_fase4_", rodada, "_", VERSAO, ".md")); stopifnot(!file.exists(arq))
dir.create("figuras", recursive = TRUE, showWarnings = FALSE)
NOMES <- c(fig01 = "curva_combinada", fig02 = "lagresposta", fig03 = "curvas_concentracoes", fig04 = "sensibilidades")
f_out <- unlist(lapply(names(NOMES), function(k) file.path("figuras", paste0(k, "_", NOMES[[k]], "_", VERSAO, "_", rodada, c(".pdf", ".png")))))
for (p in f_out) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/86_figuras_m3_fase4.R"; CC <- file.path(REPO, "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
sujos <- git("status", "--porcelain", "--", ESTE); if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current"); st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:"); inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
sha_se <- sha(file.path(CC, "R", "segunda_etapa.R")); if (!identical(sha_se, tag_sha("segunda_etapa-v1.1", "codigo_compartilhado/R/segunda_etapa.R"))) stop("segunda_etapa.R difere da tag")
FIXO <- c("01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds" = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d",
          "01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds" = "52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e")
DO_LOG <- c("01_saidas/fase4/tabela_sensibilidades_fase4_v2.csv" = "logs/m2_menores_tabela_v2_fase4_20261019.md",
            "01_saidas/fase4/criterio_c1_fase4_20261019.csv" = "logs/c1_chaves_fase4_20261019.md")
sha_ent <- vapply(c(names(FIXO), names(DO_LOG)), sha, "")
if (!identical(unname(sha_ent[names(FIXO)]), unname(FIXO))) stop("entrada da Fase 2 ou 3 com SHA-256 diferente do registrado")
for (p in names(DO_LOG)) if (!grepl(paste0("`", p, "`: `", sha_ent[[p]], "`"), paste(readLines(DO_LOG[[p]], encoding = "UTF-8"), collapse = "\n"), fixed = TRUE)) stop(p, ": SHA-256 diferente do registrado em ", DO_LOG[[p]])
suppressPackageStartupMessages(library(dlnm))
f <- new.env(); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f)
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
mun <- as.data.frame(concentracoes()); sem_uf <- !grepl("/", nome); nome[sem_uf] <- paste0(nome[sem_uf], "/", mun$SIGLA_UF[match(names(nome)[sem_uf], mun$CD_RECORTE)])   # Manaus/AM, Campo Grande/MS
rds32 <- readRDS(names(FIXO)[1])$resultados; r45 <- readRDS(names(FIXO)[2])
tv2 <- utils::read.csv(names(DO_LOG)[1], stringsAsFactors = FALSE, encoding = "UTF-8", na.strings = c("", "NA"))
c1 <- utils::read.csv(names(DO_LOG)[2], stringsAsFactors = FALSE, encoding = "UTF-8", na.strings = c("", "NA"))
FAM <- "Arial"
dispositivos <- function(base, larg, alt, desenha) {
  # quartz (macOS): o cairo do R exige o XQuartz, que não está instalado; o quartz embute a Arial (TrueType, subconjunto)
  grDevices::quartz(type = "pdf", file = paste0(base, ".pdf"), width = larg, height = alt, family = FAM); desenha(); grDevices::dev.off()
  grDevices::quartz(type = "png", file = paste0(base, ".png"), width = larg, height = alt, dpi = 300, family = FAM, bg = "white"); desenha(); grDevices::dev.off() }
LARG <- 190 / 25.4   # v3: largura de página inteira do guia (2.244 px a 300 dpi = 190 mm); alturas das Figs. 3 e 4: 229 mm
# v3: com mfrow 6 × 5 (Fig. 3) e layout 1 × 3 (Fig. 4), o R multiplica o cex por 0,66; os cex abaixo dão ≥ 7 pt (12 pt × 0,66 × cex)
base_de <- function(k) file.path("figuras", paste0(k, "_", NOMES[[k]], "_", VERSAO, "_", rodada))
eixo_log <- function(lim) { t <- pretty(lim, n = 6); t <- t[t >= lim[1] & t <= lim[2]]; graphics::axis(2, at = t, labels = formatC(t, format = "f", digits = 2), las = 1, cex.axis = 0.8) }
banda <- function(x, li, ls, cor = grDevices::rgb(0.2, 0.4, 0.7, 0.25)) graphics::polygon(c(x, rev(x)), c(li, rev(ls)), col = cor, border = NA)

# ------------------------------------------------------------------ fig01
cc <- r45$curva_combinada; tc <- r45$tmr[r45$tmr$nivel == "combinada", ]; ct <- r45$contrastes[r45$contrastes$nivel == "combinada", ]
stopifnot(nrow(cc) == 101, nrow(tc) == 1)
lim1 <- range(c(cc$rr_li, cc$rr_ls, 1)) * c(0.98, 1.02)
dispositivos(base_de("fig01"), LARG, 5.0, function() {
  graphics::par(mar = c(4.2, 4.6, 3.2, 1), mgp = c(2.6, 0.7, 0), family = FAM)
  graphics::plot(cc$x, cc$rr, type = "n", log = "y", ylim = lim1, xlab = "Daily mean temperature (°C), pooled axis of the 26 urban concentrations",
                 ylab = "Cumulative relative risk, lag 0–7", yaxt = "n", cex.lab = 0.85, cex.axis = 0.8)
  eixo_log(lim1); graphics::abline(h = 1, col = "grey45", lwd = 0.8)
  banda(cc$x, cc$rr_li, cc$rr_ls); graphics::lines(cc$x, cc$rr, lwd = 2, col = grDevices::rgb(0.1, 0.25, 0.55))
  graphics::abline(v = tc$tmr, lty = 2, col = "grey20")
  pc <- c("p1", "p10", "p25", "p50", "p75", "p90", "p99"); xp <- cc$x[match(pc, cc$rotulo)]
  graphics::axis(3, at = xp, labels = sub("^p", "", pc), cex.axis = 0.75, mgp = c(2, 0.5, 0)); graphics::mtext("Percentile of the pooled axis", side = 3, line = 1.8, cex = 0.75)
  graphics::text(tc$tmr, lim1[2] / 1.01, sprintf("MRT %.1f °C", tc$tmr), pos = 2, cex = 0.75) })

# ------------------------------------------------------------------ fig02
lr <- r45$lagresposta$curva; stopifnot(all(c("p99", "p1") %in% lr$valor))
lim2 <- range(c(lr$rr_li, lr$rr_ls, 1)) * c(0.995, 1.005)
dispositivos(base_de("fig02"), LARG, 3.6, function() {
  graphics::par(mfrow = c(1, 2), mar = c(4, 4.4, 2, 0.8), mgp = c(2.4, 0.6, 0), family = FAM)
  for (v in c("p99", "p1")) { z <- lr[lr$valor == v, ]
    graphics::plot(z$lag, z$rr, type = "n", ylim = lim2, xlab = "Lag (days)", ylab = "Relative risk", cex.lab = 0.85, cex.axis = 0.8, las = 1)
    graphics::abline(h = 1, col = "grey45", lwd = 0.8); banda(z$lag, z$rr_li, z$rr_ls); graphics::lines(z$lag, z$rr, lwd = 2, col = grDevices::rgb(0.1, 0.25, 0.55))
    graphics::title(main = sprintf("%s percentile (%.1f °C) vs MRT", c(p99 = "99th", p1 = "1st")[[v]], ct$temperatura[ct$percentil == v]), cex.main = 0.85, font.main = 1) } })

# ------------------------------------------------------------------ fig03
tb <- r45$tmr[r45$tmr$nivel == "blup", ]
cur <- lapply(ordem, function(r) { b <- r45$blup[[r]]; av <- rds32[[r]]$principal$base$argvar; x <- unname(r45$grade[r, ]); cen <- tb$tmr[tb$recorte_principal == r]
  z <- f$curva(b$coef, b$vcov, av, x, cen); z$cen <- cen; z })
names(cur) <- ordem
lim3 <- c(0.75, 1.35)
dispositivos(base_de("fig03"), LARG, 229 / 25.4, function() {
  graphics::par(mfrow = c(6, 5), mar = c(2.2, 2.4, 1.6, 0.4), oma = c(2.4, 2.6, 0, 0), mgp = c(1.4, 0.4, 0), tcl = -0.25, family = FAM)
  for (r in ordem) { z <- cur[[r]]; li <- pmax(z$rr_li, lim3[1]); ls <- pmin(z$rr_ls, lim3[2])
    graphics::plot(z$x, z$rr, type = "n", log = "y", ylim = lim3, xlab = "", ylab = "", yaxt = "n", cex.axis = 0.92)
    graphics::axis(2, at = c(0.8, 1, 1.2), labels = c("0.8", "1.0", "1.2"), las = 1, cex.axis = 0.92)
    graphics::abline(h = 1, col = "grey55", lwd = 0.6); banda(z$x, li, ls); graphics::lines(z$x, pmin(pmax(z$rr, lim3[1]), lim3[2]), lwd = 1.4, col = grDevices::rgb(0.1, 0.25, 0.55))
    graphics::abline(v = z$cen, lty = 2, col = "grey25", lwd = 0.7); graphics::points(z$cen[1], 1, pch = 16, cex = 0.8, col = "grey15")
    cx <- max(0.9, min(1.0, 0.98 * diff(graphics::par("usr")[1:2]) / graphics::strwidth(nome[[r]], cex = 1.0, font = 1)))   # v4
    graphics::title(main = nome[[r]], cex.main = cx, font.main = 1, line = 0.4, xpd = NA) }
  graphics::mtext("Daily mean temperature (°C), percentiles 1 to 99 of each concentration", side = 1, outer = TRUE, line = 1, cex = 0.85)
  graphics::mtext("Cumulative relative risk, lag 0–7 (BLUP, vs concentration-specific MRT)", side = 2, outer = TRUE, line = 1, cex = 0.85) })

# ------------------------------------------------------------------ fig04
EN <- c("P0" = "Primary analysis", "K1" = "Municipal temperature (case time series)", "K2" = "Lag 0–14", "K3" = "ns(time, 99 df), no strata", "K4" = "+ PM2.5 (lag 0–1, linear)",
        "K5" = "γ = 1 in the offset", "K6" = "Spontaneous preterm birth (i)", "C2-D3" = "+ lagged deviance residuals (lags 1–7)",
        "C3-E1" = "Births-weighted metropolitan temperature", "C3-E2" = "Maximum temperature", "C3-E3" = "Minimum temperature", "C3-E4" = "Apparent temperature",
        "C3-E5" = "+ relative humidity (lag 0–3)", "C3-P1" = "+ PM2.5, zero-missing series (23 concentrations)", "C3-CB1" = "Lag 0–4", "C3-CB2" = "Lag 0–21",
        "C3-CB3" = "Quadratic B-spline, knots p10/p75/p90", "C3-CB4" = "Natural spline, knots p50/p90", "C3-T1" = "ns(time, 74 df), no strata", "C3-T2" = "ns(time, 123 df), no strata",
        "C3-T3" = "Strata × day of week", "C3-T4" = "Excluding Dec 24 to Jan 1", "C3-T5" = "Excluding 2020–2021", "C3-T6" = "Warm season, Nov–Mar (own axis)",
        "C3-T7" = "+ negative control exposure (t+1 to t+7)", "C3-FL" = "+ local holidays", "C3-D1" = "Fetal deaths in the risk set", "C3-D2" = "Delivery risk weights by entry year",
        "C3-D3o" = "No offset", "C3-D4" = "Possible-event window", "C3-O1" = "Extremely preterm, 22–27 wk (18 concentrations)", "C3-O2" = "Very preterm, 28–31 wk",
        "C3-O3" = "Moderate-to-late preterm, 32–36 wk", "C3-O4" = "Spontaneous preterm birth (ii)", "C3-O5" = "LMP-dated births, GA from the SINASC field (i)", "C3-O6" = "LMP-dated births, GA from the LMP (ii)",
        "C3-O7" = "2011 cohort, arm A (no offset)", "C3-O8" = "2011 cohort, arm B (no offset)", "C3-O9" = "Early term, 37–38 wk (comparison)", "C3-O10" = "Early term, intersection window",
        "C4-FIX" = "Fixed-effects meta-analysis", "C4-MULTI" = "Multilevel meta-analysis", "C4-UMA" = "One-stage model", "C4-S3" = "Penalized DLNM (vs concentration-specific reference)")
k1 <- data.frame(id = paste0("K", c1$chave), rr99 = c1$rr99, rr99_li = c1$rr99_li, rr99_ls = c1$rr99_ls, rr01 = c1$rr01, rr01_li = c1$rr01_li, rr01_ls = c1$rr01_ls,
                 borda = ifelse(c1$fronteira %in% TRUE, c1$lado_borda, NA), stringsAsFactors = FALSE)
v2 <- tv2[!is.na(tv2$rr99) & tv2$id != "P0", c("id", "rr99", "rr99_li", "rr99_ls", "rr01", "rr01_li", "rr01_ls", "borda")]
p0 <- tv2[tv2$id == "P0", c("id", "rr99", "rr99_li", "rr99_ls", "rr01", "rr01_li", "rr01_ls", "borda")]
fo <- rbind(p0, k1, v2); stopifnot(all(fo$id %in% names(EN)), !anyDuplicated(fo$id))
GR <- c("Primary" = "^P0$", "Key sensitivity analyses (prespecified criterion)" = "^K", "Residual autocorrelation" = "^C2", "Exposure" = "^C3-(E|P)",
        "Cross-basis" = "^C3-CB", "Time trend and calendar" = "^C3-(T|FL)", "Risk set and offset" = "^C3-D", "Outcome definition" = "^C3-O", "Pooling and model" = "^C4")
linhas <- list(); for (g in names(GR)) { s <- fo[grepl(GR[[g]], fo$id), ]; linhas[[length(linhas) + 1]] <- data.frame(id = NA, rotulo = g, cab = TRUE); linhas[[length(linhas) + 1]] <- data.frame(id = s$id, rotulo = EN[s$id], cab = FALSE) }
lay <- do.call(rbind, linhas); lay$y <- rev(seq_len(nrow(lay))); fo <- fo[match(lay$id[!lay$cab], fo$id), ]; yv <- lay$y[!lay$cab]
lim4 <- c(0.85, 1.30)
dispositivos(base_de("fig04"), LARG, 229 / 25.4, function() {
  graphics::layout(matrix(1:3, 1), widths = c(2.3, 1, 1)); graphics::par(family = FAM, oma = c(0, 0, 0, 0))
  graphics::par(mar = c(4.2, 0.2, 2, 0)); graphics::plot.new(); graphics::plot.window(xlim = c(0, 1), ylim = c(0.5, nrow(lay) + 0.5))
  graphics::text(0.02, lay$y, lay$rotulo, adj = 0, cex = ifelse(lay$cab, 1.0, 0.92), font = ifelse(lay$cab, 2, 1))
  for (lado in c("99", "01")) { rr <- fo[[paste0("rr", lado)]]; li <- fo[[paste0("rr", lado, "_li")]]; ls <- fo[[paste0("rr", lado, "_ls")]]; bo <- fo$borda %in% c(if (lado == "99") "x99" else "x1")
    graphics::par(mar = c(4.2, 0.6, 2, 0.6), mgp = c(2.3, 0.6, 0))
    graphics::plot(NA, xlim = lim4, ylim = c(0.5, nrow(lay) + 0.5), log = "x", yaxt = "n", xlab = "Relative risk (95% CI)", cex.lab = 1.0, cex.axis = 0.95, xaxt = "n")
    graphics::axis(1, at = c(0.9, 1, 1.1, 1.2), labels = c("0.90", "1.00", "1.10", "1.20"), cex.axis = 0.95)
    graphics::abline(v = 1, col = "grey45", lwd = 0.8); graphics::abline(v = rr[fo$id == "P0"], col = grDevices::rgb(0.1, 0.25, 0.55, 0.5), lty = 3)
    ok <- !bo & !is.na(li); graphics::segments(pmax(li[ok], lim4[1]), yv[ok], pmin(ls[ok], lim4[2]), yv[ok], lwd = 1)
    graphics::points(rr[ok], yv[ok], pch = ifelse(fo$id[ok] == "P0", 16, 15), cex = ifelse(fo$id[ok] == "P0", 1.1, 0.75))
    if (any(bo)) graphics::points(rep(1, sum(bo)), yv[bo], pch = 5, cex = 0.8)
    graphics::title(main = if (lado == "99") "99th vs MRT (heat)" else "1st vs MRT (cold)", cex.main = 1.05, font.main = 1) } })   # v3: sem a nota interna (a legenda explica os símbolos)

# ------------------------------------------------------------------ conferência das fontes embutidas (pypdf)
pdfs <- f_out[grepl("\\.pdf$", f_out)]
py <- "import sys\nfrom pypdf import PdfReader\nfor p in sys.argv[1:]:\n    fs=set(); emb=set()\n    for pg in PdfReader(p).pages:\n        r=pg.get('/Resources') or {}; ft=r.get('/Font') or {}\n        for k in ft:\n            o=ft[k].get_object(); b=str(o.get('/BaseFont')); fs.add(b)\n            dd=o.get('/FontDescriptor'); dsc=o.get('/DescendantFonts')\n            if dsc: dd=dsc[0].get_object().get('/FontDescriptor')\n            if dd and any(x in dd.get_object() for x in ('/FontFile','/FontFile2','/FontFile3')): emb.add(b)\n    print(p, '|', ';'.join(sorted(fs)), '|', 'embutidas: '+str(len(emb))+'/'+str(len(fs)))\n"
tf <- tempfile(fileext = ".py"); writeLines(py, tf); fontes <- system2("python3", c("-I", tf, shQuote(pdfs)), stdout = TRUE, stderr = TRUE); unlink(tf)
# v3: menor corpo de letra de cada PDF, em pt, no tamanho nativo (Tf × escala do Tm nos content streams; regra: ≥ 7 pt)
pyc <- "import re, sys, zlib\nfor p in sys.argv[1:]:\n    d = open(p, 'rb').read(); t = []\n    for m in re.finditer(rb'stream\\r?\\n(.*?)\\r?\\nendstream', d, re.S):\n        try: s = zlib.decompress(m.group(1))\n        except Exception: continue\n        for bt in re.findall(rb'BT(.*?)ET', s, re.S):\n            tf = re.findall(rb'/\\S+\\s+([\\d.]+)\\s+Tf', bt); tm = re.findall(rb'([-\\d.]+)\\s+([-\\d.]+)\\s+[-\\d.]+\\s+[-\\d.]+\\s+[-\\d.]+\\s+[-\\d.]+\\s+Tm', bt)\n            if tf: t.append(float(tf[-1]) * ((float(tm[-1][0]) ** 2 + float(tm[-1][1]) ** 2) ** 0.5 if tm else 1.0))\n    print(p, min(t), max(t), len(t))\n"
tf <- tempfile(fileext = ".py"); writeLines(pyc, tf); corpo <- system2("python3", c("-I", tf, shQuote(pdfs)), stdout = TRUE, stderr = TRUE); unlink(tf)
corpo_min <- vapply(strsplit(corpo, " "), function(x) as.numeric(x[length(x) - 2]), 0); ok_corpo <- length(corpo_min) == 4 && all(corpo_min >= 7)
ok_fontes <- all(grepl("Arial", fontes)) && all(vapply(regmatches(fontes, regexpr("embutidas: [0-9]+/[0-9]+", fontes)), function(s) { n <- as.integer(strsplit(sub("embutidas: ", "", s), "/")[[1]]); n[1] == n[2] && n[2] > 0 }, TRUE))
sha_out <- vapply(f_out, sha, ""); stopifnot(versao() == "4443971b")
md <- c("# Fase 4, marco M3: figuras do manuscrito", "",
  sprintf("- **Gerado por:** `00_scripts/86_figuras_m3_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()`: %s.", sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Código:** `segunda_etapa.R` `%s` (tag `segunda_etapa-v1.1`). **Entradas (SHA-256 = registrados):** %s.", sha_se, paste(sprintf("`%s` (`%s`)", names(sha_ent), sha_ent), collapse = "; ")),
  "- **Decisões:** A1-123, A1-124 e A1-151 (v3).", "",
  "## Figuras", "",
  "| Figura | Conteúdo |", "|---|---|",
  "| fig01 | Curva combinada cumulativa (lag 0–7) no eixo médio, p1–p99, IC 95%, TMR combinada tracejada; eixo superior em percentis |",
  "| fig02 | Lag-resposta combinada no p99 e no p1 contra a TMR, IC 95% |",
  sprintf("| fig03 | As 26 curvas BLUP na grade p1–p99 de cada concentração, contra a TMR BLUP; IC 95%% cortado em %s a %s no eixo y |", lim3[1], lim3[2]),
  sprintf("| fig04 | Forest de %d análises (primário, 6 chaves da C1, D3, 31 da C3, feriados locais e 4 da C4), RR no x99 e no x1; borda marcada com losango aberto |", nrow(fo)), "",
  "## Fontes nos PDFs (pypdf)", "", paste0("- ", fontes), "", sprintf("- **Arial embutida em todos os PDFs:** %s.", if (ok_fontes) "sim" else "NÃO"), "",
  "## Corpo de letra nos PDFs (v3; pt no tamanho nativo: menor, maior, nº de blocos de texto)", "", paste0("- ", corpo), "",
  sprintf("- **Tamanhos (mm):** fig01 %.0f × %.0f; fig02 %.0f × %.0f; fig03 %.0f × %.0f; fig04 %.0f × %.0f. **Corpo mínimo ≥ 7 pt em todas:** %s.", LARG * 25.4, 5.0 * 25.4, LARG * 25.4, 3.6 * 25.4, LARG * 25.4, 229, LARG * 25.4, 229, if (ok_corpo) "sim" else "NÃO"), "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", f_out, sha_out), "", sprintf("- **Resultado:** %s.", if (ok_fontes && ok_corpo) "ok" else "FALHA na conferência das fontes ou do corpo de letra"), "")
writeLines(md, arq, useBytes = TRUE); cat("gravado:", arq, "| fontes ok:", ok_fontes, "| corpo mínimo:", paste(round(corpo_min, 2), collapse = " "), "\n"); if (!(ok_fontes && ok_corpo)) quit(status = 1)
