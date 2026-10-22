# 93_selecao_ausentes_m5b.R — Fase 4, M5b: fluxograma de seleção (Supplementary Figure S1) e dados ausentes (Supplementary Table S6)
# (mensagem do chat do A1 de 20/10, M5b, item 1; A1-144). Lê os microdados pela interface da base (09_acesso), só para contar; nada
# individual sai. Saem só totais nacionais (26 concentrações somadas), com 1 a 9 como "<10" e supressão complementar.
# Ordem das etapas = a do código da base (00_scripts/06b_desfechos.py): gestação não única (múltipla; ignorada) → IG ausente, < 22 ou
# ≥ 45 → IG de 43 a 44 → população da prematuridade (única com IG de 22 a 42) → coorte fixa. A janela é pela data de nascimento.
# Conferências: (1) a chegada tem de ser igual aos totais da série do principal (13.509.914 NV e 1.378.030 PTB): se não fechar, para;
# (2) por ano (2013–2023), as partições têm de ser iguais às do logs/fluxograma_exclusoes.csv da base (MD5 da entrega da base).
# Saídas (fora do git): figuras/figS1_fluxograma_<VERSAO>_<RODADA>.{pdf,png}; tabelas/tabS6_ausentes_<VERSAO>_<RODADA>.csv;
# tabelas/figS1_contagens_<VERSAO>_<RODADA>.csv. Log logs/selecao_ausentes_m5b_<RODADA>_<VERSAO>.md.
# v2 (20/10): na Tabela S6, contagem não nula com menos de 0,05% sai como "(<0.1%)" (a v1 escrevia "(0.0%)") e zero sai sem
# percentual; o log passa ao formato brasileiro. Contagens e figura iguais às da v1 (saídas da v1 na lixeira; SHA-256 no log).
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/93_selecao_ausentes_m5b.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
VERSAO <- "v2"
arq <- file.path("logs", paste0("selecao_ausentes_m5b_", rodada, "_", VERSAO, ".md")); stopifnot(!file.exists(arq))
ANTERIOR <- c("figuras/figS1_fluxograma_v1_20261020.pdf" = "73334a7ff6e587457d6d7c34234bff8eac881f6039ebbff0fd915bc7a6206314",
              "figuras/figS1_fluxograma_v1_20261020.png" = "896903f3a87f79e3f7381a80d5396ffdf1fecb5261d4571b020758ad01e74fed",
              "tabelas/tabS6_ausentes_v1_20261020.csv" = "21b919bb478ad2fd6a8fa946f03903522e279e324d5f2ef88b2c791ae3ac0f5f",
              "tabelas/figS1_contagens_v1_20261020.csv" = "6945c2ff32030f7840c2fae8be2775919bcb06bb6fb2fdb2b11584ad18160c94")
for (p in names(ANTERIOR)) if (file.exists(p)) stop(p, ": saída da v1 ainda no lugar (mova para a lixeira antes)")
dir.create("figuras", recursive = TRUE, showWarnings = FALSE); dir.create("tabelas", recursive = TRUE, showWarnings = FALSE)
OUT <- c(pdf = file.path("figuras", paste0("figS1_fluxograma_", VERSAO, "_", rodada, ".pdf")), png = file.path("figuras", paste0("figS1_fluxograma_", VERSAO, "_", rodada, ".png")),
         s6 = file.path("tabelas", paste0("tabS6_ausentes_", VERSAO, "_", rodada, ".csv")), cont = file.path("tabelas", paste0("figS1_contagens_", VERSAO, "_", rodada, ".csv")))
for (p in OUT) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/93_selecao_ausentes_m5b.R"
BASE <- "/Volumes/Forja/Doc/dados_artigos_perinatais_clima"
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
sujos <- git("status", "--porcelain", "--", ESTE); if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current"); st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:"); inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")

# ------------------------------------------------------------------ entradas
S4 <- "01_saidas/fase4/serie_ptb_fase4.rds"; SHA_S4 <- "e70190c1bf7c0fa5ba9c9f1e3cacb46f1ef8d647fc04a8606d181f7c819793e0"
stopifnot(identical(sha(S4), SHA_S4))
FLUX <- file.path(BASE, "logs", "fluxograma_exclusoes.csv"); MD5_FLUX <- "28440d0d6207901807436c3fee481406"   # RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md, l. 142
stopifnot(identical(system2("md5", c("-q", shQuote(FLUX)), stdout = TRUE), MD5_FLUX))
s4 <- as.data.frame(readRDS(S4)); j4 <- s4$janela_principal %in% TRUE
alvo_nv <- sum(s4$nv_unicos[j4]); alvo_ptb <- sum(s4$ptb[j4]); stopifnot(alvo_nv == 13509914, alvo_ptb == 1378030)
ini <- min(s4$data[j4]); fim <- max(s4$data[j4]); stopifnot(ini == as.Date("2012-04-14"), fim == as.Date("2024-08-06"))
mun <- as.data.frame(concentracoes()); stopifnot(nrow(mun) == 277L)
log_msg("nascimentos()")
n <- as.data.frame(nascimentos(c("CD_MUN6", "data", "ano", "grav_cat", "ig_cat", "ga_sem", "pop_ptb", "ptb", "coorte_fixa_22", "peso_g",
                                  "parto", "consultas_cat", "sttrabpart", "stcesparto", "ig_dum_sem")))
stopifnot(all(n$CD_MUN6 %in% mun$CD_MUN6), all(n$grav_cat %in% c("unica", "multipla", "ignorada")), all(n$ig_cat %in% c("ausente", "lt22", "22_42", "43_44", "ge45")))
rc <- mun$CD_RECORTE[match(n$CD_MUN6, mun$CD_MUN6)]
unica <- n$grav_cat == "unica"; cf <- n$coorte_fixa_22 %in% TRUE
# a população da base tem de ser igual à reconstrução pelas categorias
stopifnot(identical(n$pop_ptb %in% TRUE, unica & n$ig_cat == "22_42"), all(!(n$ptb %in% TRUE) | (n$pop_ptb %in% TRUE)))

# ------------------------------------------------------------------ conferência por ano com o fluxograma da base (2013–2023)
fx <- utils::read.csv(FLUX, stringsAsFactors = FALSE); fx <- fx[fx$sistema == "SINASC" & fx$ano %in% 2013:2023, ]
meu <- do.call(rbind, lapply(2013:2023, function(a) { k <- n$ano == a
  data.frame(ano = a, total_residentes = sum(k), nao_unico = sum(k & !unica), unico_ig_ausente = sum(k & unica & n$ig_cat == "ausente"),
             unico_ig_lt22 = sum(k & unica & n$ig_cat == "lt22"), unico_ig_43_44 = sum(k & unica & n$ig_cat == "43_44"), unico_ig_ge45 = sum(k & unica & n$ig_cat == "ge45"),
             populacao_principal = sum(k & n$pop_ptb %in% TRUE), fora_coorte_fixa_22 = sum(k & n$pop_ptb %in% TRUE & !cf), na_serie_principal = sum(k & n$pop_ptb %in% TRUE & cf)) }))
cols <- setdiff(names(meu), "ano")
confere_ano <- all(vapply(cols, function(cc) identical(as.numeric(meu[[cc]]), as.numeric(fx[[cc]][match(meu$ano, fx$ano)])), TRUE))
stopifnot(confere_ano)

# ------------------------------------------------------------------ fluxograma na janela principal
jn <- n$data >= ini & n$data <= fim
N0 <- sum(jn)
e_mult <- sum(jn & n$grav_cat == "multipla"); e_ign <- sum(jn & n$grav_cat == "ignorada")
n1 <- sum(jn & unica)
e_aus <- sum(jn & unica & n$ig_cat == "ausente"); e_lt22 <- sum(jn & unica & n$ig_cat == "lt22"); e_ge45 <- sum(jn & unica & n$ig_cat == "ge45")
e_ig <- e_aus + e_lt22 + e_ge45; e_4344 <- sum(jn & unica & n$ig_cat == "43_44")
n2 <- sum(jn & n$pop_ptb %in% TRUE); e_coorte <- sum(jn & n$pop_ptb %in% TRUE & !cf)
fim_nv <- sum(jn & n$pop_ptb %in% TRUE & cf); fim_ptb <- sum(jn & n$ptb %in% TRUE & cf)
fecha <- c(particao0 = N0 == e_mult + e_ign + n1, particao1 = n1 == e_ig + e_4344 + n2, particao2 = n2 == e_coorte + fim_nv,
           nv = fim_nv == alvo_nv, ptb = fim_ptb == alvo_ptb)
if (!all(fecha)) stop("o fluxograma NÃO fecha com a série do principal (", paste(names(fecha)[!fecha], collapse = ", "), "): PARE e reporte; nada foi gravado")
principais <- c(e_mult, e_ign, e_ig, e_4344, e_coorte)
if (any(principais < 10)) stop("exclusão principal com menos de 10: a supressão complementar exige outra apresentação; PARE e reporte")
mostra_decomp <- all(c(e_aus, e_lt22, e_ge45) >= 10)
# critério de inclusão por concentração (≥ 90% de IG e peso válidos), recontado só para registro (a conferência prespecificada é a da especificação, l. 398)
pc_ig <- tapply(!is.na(n$ga_sem[jn]), rc[jn], mean); pc_peso <- tapply(!is.na(n$peso_g[jn]), rc[jn], mean)
pc_ambos <- tapply(!is.na(n$ga_sem[jn]) & !is.na(n$peso_g[jn]), rc[jn], mean)
stopifnot(length(pc_ambos) == 26L)

# ------------------------------------------------------------------ Tabela S6 (população analítica; A1-144, item 3, e A1-145)
# Variáveis da Tabela 1 (87_tabelas_m3_fase4.R): PTB (pela IG), % de cesárea (PARTO), % com 7 ou mais consultas (CONSULTAS) e temperatura
# do núcleo (da série do principal, em concentração-dias). Ignorado = as regras do 68 (PARTO fora de {1, 2}; CONSULTAS fora de {1, 2, 3, 4}).
# Variáveis do critério de inclusão e das sensibilidades: peso (NA = ausente ou fora de 200 a 7.000 g), STTRABPART e STCESPARTO (PTB
# espontâneo; fora de {1, 2}; STCESPARTO só entre as cesáreas) e DUM (`ig_dum_sem` NA = ausente ou inválida, pela regra da base).
an <- jn & n$pop_ptb %in% TRUE & cf; stopifnot(sum(an) == alvo_nv)
mascara <- function(x) if (x >= 1 && x <= 9) "<10" else formatC(x, format = "d", big.mark = ",")
linha <- function(rotulo, uso, den, k) { pct <- if (k <= 9) "" else if (100 * k / den < 0.05) " (<0.1%)" else sprintf(" (%s%%)", formatC(100 * k / den, format = "f", digits = 1))
  data.frame(Variable = rotulo, Use = uso, Denominator = formatC(den, format = "d", big.mark = ","), `Missing or unknown, n (%)` = paste0(mascara(k), pct), check.names = FALSE) }
na_ig <- sum(an & is.na(n$ga_sem)); stopifnot(na_ig == 0L)
dias_t <- sum(j4); na_t <- sum(is.na(s4$tmean_nucleo[j4])); stopifnot(dias_t == 26L * 4498L)
ces <- an & n$parto %in% "2"
S6 <- rbind(
  linha("Gestational age (SEMAGESTAC)", "Outcome; Table 1", sum(an), na_ig),
  linha("Mode of delivery (PARTO)", "Table 1", sum(an), sum(an & !(n$parto %in% c("1", "2")))),
  linha("Prenatal visits (CONSULTAS)", "Table 1", sum(an), sum(an & !(n$consultas_cat %in% c("1", "2", "3", "4")))),
  linha("Daily mean temperature of the core city (concentration-days)", "Exposure; Table 1", dias_t, na_t),
  linha("Birth weight (PESO; missing or outside 200–7,000 g)", "Inclusion criterion", sum(an), sum(an & is.na(n$peso_g))),
  linha("Labor induction (STTRABPART)", "Spontaneous preterm birth", sum(an), sum(an & !(n$sttrabpart %in% c("1", "2")))),
  linha("Cesarean before the onset of labor (STCESPARTO; cesarean deliveries)", "Spontaneous preterm birth", sum(ces), sum(ces & !(n$stcesparto %in% c("1", "2")))),
  linha("Date of the last menstrual period (DTULTMENST; missing or invalid)", "Internal consistency of gestational age", sum(an), sum(an & is.na(n$ig_dum_sem))))
utils::write.csv(S6, OUT[["s6"]], row.names = FALSE, fileEncoding = "UTF-8")
CONT <- data.frame(etapa = c("NV de residentes dos 277 municípios na janela", "gestação múltipla", "gestação ignorada (GRAVIDEZ)", "NV únicos",
                             "IG ausente, < 22 ou ≥ 45", "  IG ausente", "  IG < 22", "  IG ≥ 45", "IG de 43 a 44", "NV únicos de 22 a 42 semanas",
                             "início fora da coorte fixa", "população analítica (NV)", "população analítica (PTB)"),
                   n = c(N0, e_mult, e_ign, n1, e_ig, e_aus, e_lt22, e_ge45, e_4344, n2, e_coorte, fim_nv, fim_ptb))
CONT$n_publicavel <- vapply(seq_len(nrow(CONT)), function(i) if (grepl("^  ", CONT$etapa[i]) && !mostra_decomp) "suprimido" else mascara(CONT$n[i]), "")
utils::write.csv(CONT[, c("etapa", "n_publicavel")], OUT[["cont"]], row.names = FALSE, fileEncoding = "UTF-8")

# ------------------------------------------------------------------ Figura S1 (quartz, Arial)
f0 <- function(x) formatC(x, format = "d", big.mark = ",")
desenha <- function() {
  par(mar = c(0, 0, 0, 0), family = "Arial"); plot.new(); plot.window(xlim = c(0, 10), ylim = c(0, 12), xaxs = "i", yaxs = "i")
  caixa <- function(x0, x1, y, h, txt, cex = 0.72) { rect(x0, y - h / 2, x1, y + h / 2, lwd = 0.8); text((x0 + x1) / 2, y, txt, cex = cex) }
  xm0 <- 0.3; xm1 <- 4.9; xc <- (xm0 + xm1) / 2; xe0 <- 5.4; xe1 <- 9.7
  caixa(xm0, xm1, 11.1, 1.2, sprintf("Live births to residents of the 277 municipalities,\nApril 14, 2012, to August 6, 2024\nn = %s", f0(N0)))
  caixa(xe0, xe1, 9.85, 0.7, sprintf("Multiple pregnancy\nn = %s", f0(e_mult)))
  caixa(xe0, xe1, 8.95, 0.7, sprintf("Pregnancy type unknown\nn = %s", f0(e_ign)))
  caixa(xm0, xm1, 7.9, 0.8, sprintf("Singleton live births\nn = %s", f0(n1)))
  txt_ig <- if (mostra_decomp) sprintf("Gestational age missing or outside 22–44 weeks\nn = %s\n(missing, %s; <22 weeks, %s; ≥45 weeks, %s)", f0(e_ig), f0(e_aus), f0(e_lt22), f0(e_ge45)) else sprintf("Gestational age missing or outside 22–44 weeks\nn = %s", f0(e_ig))
  caixa(xe0, xe1, 6.7, 1.0, txt_ig, cex = 0.66)
  caixa(xe0, xe1, 5.65, 0.7, sprintf("Gestational age 43–44 weeks\nn = %s", f0(e_4344)))
  caixa(xm0, xm1, 4.6, 0.8, sprintf("Singleton live births at 22–42 weeks\nn = %s", f0(n2)))
  caixa(xe0, xe1, 3.45, 1.0, sprintf("Estimated pregnancy start outside the\nfixed cohort (July 31, 2011, to March 5, 2024)\nn = %s", f0(e_coorte)), cex = 0.66)
  caixa(xm0, xm1, 2.1, 1.1, sprintf("Analytic population\n%s live births\n%s preterm births (22–36 weeks)", f0(fim_nv), f0(fim_ptb)))
  arrows(xc, 11.1 - 0.6, xc, 7.9 + 0.4, length = 0.07); arrows(xc, 7.9 - 0.4, xc, 4.6 + 0.4, length = 0.07); arrows(xc, 4.6 - 0.4, xc, 2.1 + 0.55, length = 0.07)
  for (y in c(9.85, 8.95, 6.7, 5.65, 3.45)) arrows(xc, y, xe0, y, length = 0.07)
  text(5, 0.75, "All 26 urban concentrations met the inclusion criteria (complete exposure data, valid gestational age\nand birth weight in at least 90% of live births, at least 1,000 events, and model convergence).", cex = 0.6)
}
quartz(type = "pdf", file = OUT[["pdf"]], width = 7.5, height = 8.5, family = "Arial"); desenha(); dev.off()
quartz(type = "png", file = OUT[["png"]], width = 7.5, height = 8.5, dpi = 300, family = "Arial", bg = "white"); desenha(); dev.off()
stopifnot(versao() == "4443971b")

# ------------------------------------------------------------------ log
sha_out <- vapply(OUT, sha, "")
pc_txt <- function(x) formatC(100 * x, format = "f", digits = 2, decimal.mark = ",")
fb <- function(x) formatC(x, format = "d", big.mark = ".")
CONT$n_log <- vapply(seq_len(nrow(CONT)), function(i) if (grepl("^  ", CONT$etapa[i]) && !mostra_decomp) "suprimido" else if (CONT$n[i] >= 1 && CONT$n[i] <= 9) "<10" else fb(CONT$n[i]), "")
md <- c("# Fase 4, M5b: fluxograma de seleção (Figura S1) e dados ausentes (Tabela S6)", "",
  sprintf("- **Gerado por:** `00_scripts/93_selecao_ausentes_m5b.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()`: %s.", sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Entradas:** `%s` (SHA-256 `%s`, igual ao registrado); `nascimentos()` da base `4443971b` (microdado; só contado); `logs/fluxograma_exclusoes.csv` da base (MD5 `%s`, igual ao da entrega da base).", S4, SHA_S4, MD5_FLUX),
  "- **Ordem das etapas:** a do código da base (`00_scripts/06b_desfechos.py`, `derivadas` e `logs_agregados`): gestação não única (`grav_cat` múltipla ou ignorada) → IG ausente, < 22 ou ≥ 45 (`ig_cat`) → IG de 43 a 44 → população da prematuridade (`pop_ptb`: única com IG de 22 a 42) → coorte fixa (`coorte_fixa_22`). A janela é pela data de nascimento (2012-04-14 a 2024-08-06). O critério de ≥ 90% de IG e peso válidos é por concentração e não exclui nascimentos.",
  sprintf("- **Conferências:** a população da base é igual à reconstruída pelas categorias (`identical`); as partições de 2013 a 2023, por ano, são iguais às do fluxograma da base (%s); a chegada é igual aos totais da série do principal (%s NV e %s PTB): %s.",
          if (confere_ano) "iguais" else "DIFERENTES", fb(alvo_nv), fb(alvo_ptb), if (all(fecha)) "fecha" else "NÃO FECHA"),
  "", "## Contagens por etapa (totais nacionais; 26 concentrações somadas)", "",
  "| Etapa | n |", "|---|---|", sprintf("| %s | %s |", CONT$etapa, CONT$n_log), "",
  sprintf("- **Critério de inclusão, recontado na janela para registro:** IG válida em pelo menos %s%% dos NV de cada concentração; peso válido em pelo menos %s%%; os dois juntos em pelo menos %s%% (a menor, %s). A conferência prespecificada é a da especificação (todas passam; a menor, Fortaleza, 93,08%%).",
          pc_txt(min(pc_ig)), pc_txt(min(pc_peso)), pc_txt(min(pc_ambos)), unname(setNames(mun$NM_RECORTE, mun$CD_RECORTE)[names(which.min(pc_ambos))])),
  "", "## Tabela S6 (população analítica)", "", "| Variable | Use | Denominator | Missing or unknown, n (%) |", "|---|---|---|---|",
  sprintf("| %s | %s | %s | %s |", S6[[1]], S6[[2]], S6[[3]], S6[[4]]), "",
  "- **Sigilo:** só totais nacionais; 1 a 9 como \"<10\"; a decomposição da IG fora de 22 a 44 só aparece se as três partes tiverem pelo menos 10 (supressão complementar); nada diário nem por concentração.",
  "", "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", OUT, sha_out), "",
  "- **Saídas da v1 (mesmas contagens; percentual \"(0.0%)\" em contagem não nula), na lixeira:**", sprintf("  - `%s`: `%s`;", names(ANTERIOR), ANTERIOR), "", "- **Resultado:** ok.", "")
writeLines(md, arq, useBytes = TRUE); cat("gravado:", arq, "\n")
