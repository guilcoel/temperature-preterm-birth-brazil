# 65_percentis_exposicao_fase4.R — Fase 4, Parte B1.2: grades de percentis, só de exposição (mensagem da Parte B do chat
# do A1, 18/10/2026, item B1.2; plano da Fase 4, script 65; especificação v2.0.2, §1.1). Nenhum desfecho, nenhum modelo.
# - Exposições, por concentração, de 2012-01-01 a 2024-12-31, quantile(type = 7) nos percentis 1 a 99, 2,5 e 97,5:
#   1. tmean_mun agrupada: a tmean_mun diária de todos os municípios da concentração juntos (serie_diaria(nivel =
#      "municipio")), como os nós da chave 1 na Fase 1 (21_monta_serie_municipal.R); o eixo da chave 1 é a média dos
#      percentis das 26 (D2, "Abrangência");
#   2. tmean_rm_nv (serie_diaria(nivel = "recorte"));
#   3. Tmax e Tmin do núcleo (clima_municipal(), município-núcleo de cidade_nucleo());
#   4. temperatura aparente (AT) do núcleo: AT = −2,653 + 0,994·T + 0,0153·Td², T = tmean, Td por Magnus a partir de tmean
#      e rh_mean (§1.1), pela temperatura_aparente() da sens_agudos v1.0 (tag sens_agudos-v1.0; SHA do arquivo conferido
#      contra a tag), conferida em todos os dias contra uma implementação independente (Magnus pela pressão de vapor,
#      a do teste tsa_temperatura_aparente da Parte A), tolerância 1e-10;
#   5. tmean_nucleo só de novembro a março (estação quente, §1.1).
#   Para cada exposição, o eixo médio = média, nas 26, de cada percentil.
# - Conferências (diferença esperada 0; os CSV da Fase 1 têm 15 algarismos significativos, então a tolerância é 1e-12):
#   a. tmean_nucleo de novembro a março contra as linhas "novembro a março" do referencias_exposicao.csv (p1, p10, p50,
#      p75, p90, p99, média, amplitude e n de dias);
#   b. tmean_mun agrupada contra o nos_tmean_mun_concentracao.csv (p10, p75, p90 e n de valores);
#   c. tmean do clima_municipal() do núcleo igual à tmean_nucleo da serie_diaria() em todos os dias (mesma fonte);
#   d. nenhum NA em nenhuma exposição no período (NA em exposição: PARE, CLAUDE.md do artigo).
#   Qualquer conferência que falhe: grava o log e sai com quit(status = 1).
# Exposição é dado público. Grava 01_saidas/fase4/percentis_exposicao_fase4_<RODADA>.csv (formato longo, 17 dígitos) e
# logs/percentis_exposicao_fase4_<RODADA>.md. Nunca sobrescreve. Confere antes: este script commitado e limpo.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/65_percentis_exposicao_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("percentis_exposicao_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase4"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
f_csv <- file.path(OUT, paste0("percentis_exposicao_fase4_", rodada, ".csv")); stopifnot(!file.exists(f_csv))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/65_percentis_exposicao_fase4.R"
CC <- file.path(REPO, "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")

# ------------------------------------------------------------------ cabeçalho (protocolo v1.1, 3.8) e código da tag
sujos <- git("status", "--porcelain", "--", ESTE)
if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current")
st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:")
stopifnot(length(head_c) == 1L, length(ramo) == 1L, length(coord) == 1L)
inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"); t0 <- Sys.time()
f_sa <- file.path(CC, "R", "sens_agudos.R"); f_se <- file.path(CC, "R", "segunda_etapa.R")
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
sha_sa <- sha(f_sa); sha_se <- sha(f_se)
stopifnot(identical(sha_sa, tag_sha("sens_agudos-v1.0", "codigo_compartilhado/R/sens_agudos.R")),
          identical(sha_se, tag_sha("segunda_etapa-v1.1", "codigo_compartilhado/R/segunda_etapa.R")))
sa <- new.env(); sys.source(f_sa, envir = sa); se <- new.env(); sys.source(f_se, envir = se)

nuc <- as.data.frame(cidade_nucleo()); se$confere_ordem(nuc$CD_RECORTE)
ordem <- se$ORDEM_CONCENTRACOES; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
nuc6 <- setNames(substr(nuc$CD_MUN_NUCLEO, 1, 6), nuc$CD_RECORTE)
P <- sort(c(seq_len(99) / 100, 0.025, 0.975))
rot <- ifelse(abs(P * 100 - round(P * 100)) < 1e-9, paste0("p", round(P * 100)), paste0("p", sub("\\.", ",", vapply(P * 100, function(v) as.character(v), ""))))
R1 <- as.Date("2012-01-01"); R2 <- as.Date("2024-12-31")

# ------------------------------------------------------------------ leitura (só exposição)
log_msg("lendo exposições")
sr <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_nucleo", "tmean_rm_nv")))
sr$data <- as.Date(sr$data); sr <- sr[sr$data >= R1 & sr$data <= R2, ]
sm <- as.data.frame(serie_diaria(nivel = "municipio", coorte_fixa = TRUE, colunas = c("CD_MUN6", "recorte_principal", "data", "tmean_mun")))
sm$data <- as.Date(sm$data); sm <- sm[sm$data >= R1 & sm$data <= R2, ]
cl <- as.data.frame(clima_municipal(c("CD_MUN6", "data", "tmax", "tmin", "tmean", "rh_mean")))
cl$data <- as.Date(cl$data); cl <- cl[cl$data >= R1 & cl$data <= R2 & cl$CD_MUN6 %in% nuc6, ]
cl$recorte_principal <- names(nuc6)[match(cl$CD_MUN6, nuc6)]
n_dias <- as.integer(R2 - R1) + 1L
stopifnot(nrow(sr) == 26 * n_dias, nrow(cl) == 26 * n_dias, !anyDuplicated(cl[, c("recorte_principal", "data")]))
cl <- merge(cl, sr, by = c("recorte_principal", "data"), sort = FALSE)
stopifnot(nrow(cl) == 26 * n_dias)
cl$at_nucleo <- sa$temperatura_aparente(cl$tmean, cl$rh_mean)
# implementação independente: pressão de vapor e(T, UR) = UR/100 · 6,112·exp(17,27T/(237,7 + T)); Td = 237,7·ln(e/6,112)/(17,27 − ln(e/6,112))
e_vap <- cl$rh_mean / 100 * 6.112 * exp(17.27 * cl$tmean / (237.7 + cl$tmean)); lnr <- log(e_vap / 6.112); td <- 237.7 * lnr / (17.27 - lnr)
dif_at <- max(abs(cl$at_nucleo - (-2.653 + 0.994 * cl$tmean + 0.0153 * td^2)))
dif_tmean <- max(abs(cl$tmean - cl$tmean_nucleo))
mes <- as.integer(format(cl$data, "%m")); quente <- mes %in% c(11, 12, 1, 2, 3)

expos <- list(
  tmean_mun_agrupada = list(rot = "`tmean_mun` agrupada (municípios da concentração juntos; nós e eixo da chave 1)", df = sm, col = "tmean_mun"),
  tmean_rm_nv = list(rot = "`tmean_rm_nv`", df = sr, col = "tmean_rm_nv"),
  tmax_nucleo = list(rot = "Tmax do núcleo", df = cl, col = "tmax"),
  tmin_nucleo = list(rot = "Tmin do núcleo", df = cl, col = "tmin"),
  at_nucleo = list(rot = "Temperatura aparente do núcleo (§1.1)", df = cl, col = "at_nucleo"),
  tmean_nucleo_nov_mar = list(rot = "`tmean_nucleo` só de novembro a março", df = cl[quente, ], col = "tmean_nucleo"))
na_expo <- vapply(expos, function(e) sum(is.na(e$df[[e$col]])), 0L)
grades <- lapply(expos, function(e) t(vapply(ordem, function(r) { x <- e$df[[e$col]][e$df$recorte_principal == r]; quantile(x, P, type = 7, names = FALSE, na.rm = FALSE) }, numeric(length(P)))))
for (k in names(grades)) dimnames(grades[[k]]) <- list(ordem, rot)
nval <- lapply(expos, function(e) vapply(ordem, function(r) sum(e$df$recorte_principal == r), 0L))
medias <- lapply(expos, function(e) vapply(ordem, function(r) mean(e$df[[e$col]][e$df$recorte_principal == r]), 0))

# ------------------------------------------------------------------ conferências
f_ref <- file.path("01_saidas", "fase1", "referencias_exposicao.csv"); f_nos <- file.path("01_saidas", "fase1", "nos_tmean_mun_concentracao.csv")
ref <- utils::read.csv(f_ref, colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "novembro a março", ]; stopifnot(nrow(ref) == 26); rr <- ref[match(ordem, ref$recorte_principal), ]
gq <- grades$tmean_nucleo_nov_mar
dif_a <- cbind(p1 = gq[, "p1"] - rr$p1, p10 = gq[, "p10"] - rr$p10, p50 = gq[, "p50"] - rr$p50, p75 = gq[, "p75"] - rr$p75, p90 = gq[, "p90"] - rr$p90,
               p99 = gq[, "p99"] - rr$p99, media = medias$tmean_nucleo_nov_mar - rr$media, amplitude = (gq[, "p99"] - gq[, "p1"]) - rr$amplitude_p99_p1,
               n = nval$tmean_nucleo_nov_mar - rr$n_dias)
nos <- utils::read.csv(f_nos, colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
stopifnot(nrow(nos) == 26); nn <- nos[match(ordem, nos$recorte_principal), ]; gm <- grades$tmean_mun_agrupada
dif_b <- cbind(p10 = gm[, "p10"] - nn$p10, p75 = gm[, "p75"] - nn$p75, p90 = gm[, "p90"] - nn$p90, n = nval$tmean_mun_agrupada - nn$n_valores)
max_a <- max(abs(dif_a)); max_b <- max(abs(dif_b))
conf <- data.frame(Conferência = c("a. `tmean_nucleo` nov–mar contra o `referencias_exposicao.csv` (p1, p10, p50, p75, p90, p99, média, amplitude, n de dias)",
                                   "b. `tmean_mun` agrupada contra o `nos_tmean_mun_concentracao.csv` (p10, p75, p90, n de valores)",
                                   "c. `tmean` do `clima_municipal()` do núcleo contra a `tmean_nucleo` da `serie_diaria()`, todos os dias",
                                   "AT da `temperatura_aparente()` contra a implementação independente, todos os dias",
                                   "d. NA nas seis exposições no período"),
                   `Maior diferença` = c(formatC(max_a, format = "e", digits = 1), formatC(max_b, format = "e", digits = 1), formatC(dif_tmean, format = "e", digits = 1),
                                         formatC(dif_at, format = "e", digits = 1), as.character(sum(na_expo))),
                   Tolerância = c("1e-12", "1e-12", "0", "1e-10", "0"),
                   Confere = c(max_a <= 1e-12, max_b <= 1e-12, dif_tmean == 0, dif_at <= 1e-10, sum(na_expo) == 0), check.names = FALSE)
ok <- all(conf$Confere); conf$Confere <- ifelse(conf$Confere, "sim", "NÃO")
log_msg("conferências:", if (ok) "todas conferem" else "FALHA")

# ------------------------------------------------------------------ saída
eixos <- lapply(grades, colMeans)
longo <- do.call(rbind, lapply(names(grades), function(k) rbind(
  data.frame(exposicao = k, recorte_principal = rep(ordem, each = length(P)), concentracao = rep(unname(nome[ordem]), each = length(P)),
             n_valores = rep(nval[[k]], each = length(P)), percentil = rep(P * 100, times = 26), rotulo = rep(rot, times = 26), valor = as.vector(t(grades[[k]])), stringsAsFactors = FALSE),
  data.frame(exposicao = k, recorte_principal = "eixo_medio", concentracao = "Eixo médio (média das 26)", n_valores = NA_integer_, percentil = P * 100, rotulo = rot,
             valor = unname(eixos[[k]]), stringsAsFactors = FALSE))))
longo$valor <- sprintf("%.17g", longo$valor); longo$percentil <- sprintf("%.17g", longo$percentil)
if (ok) { utils::write.csv(longo, f_csv, row.names = FALSE, fileEncoding = "UTF-8"); sha_csv <- sha(f_csv) } else sha_csv <- "(não gravado)"
stopifnot(versao() == "4443971b"); v_fim <- versao()

chave <- c("p1", "p2,5", "p10", "p50", "p75", "p90", "p97,5", "p99")
tab_eixo <- data.frame(Percentil = chave, check.names = FALSE)
for (k in names(eixos)) tab_eixo[[k]] <- br(eixos[[k]][chave], 3)
tab_n <- data.frame(Exposição = vapply(expos, `[[`, "", "rot"), `Valores por concentração (mín.–máx.)` = vapply(nval, function(v) paste(br(min(v)), "–", br(max(v))), ""),
                    `NA` = na_expo, check.names = FALSE)
md <- c("# Fase 4, Parte B1.2: grades de percentis, só de exposição", "",
  sprintf("- **Gerado por:** `00_scripts/65_percentis_exposicao_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()` no início: %s; no fim: %s.",
          sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini, v_fim),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Código:** `sens_agudos.R` SHA-256 `%s` (igual ao da tag `sens_agudos-v1.0`); `segunda_etapa.R` SHA-256 `%s` (igual ao da tag `segunda_etapa-v1.1`; só a ordem das 26).", sha_sa, sha_se),
  "- **Fontes:** `serie_diaria(nivel = \"recorte\")` (`tmean_nucleo`, `tmean_rm_nv`); `serie_diaria(nivel = \"municipio\")` (`tmean_mun`); `clima_municipal()` do município-núcleo de `cidade_nucleo()` (`tmax`, `tmin`, `tmean`, `rh_mean`). Período 2012-01-01 a 2024-12-31; `quantile(type = 7)` nos percentis 1 a 99, 2,5 e 97,5 (101 percentis).", "",
  "## Conferências", "", tabela_md(conf), "",
  "## Valores por exposição", "", tabela_md(tab_n), "",
  "## Eixo médio (média das 26) nos percentis-chave (°C)", "", tabela_md(tab_eixo), "",
  "- A grade completa de cada concentração e de cada exposição está no CSV (formato longo, 17 dígitos).", "",
  "## Saída (fora do git)", "",
  sprintf("- `%s`: `%s`.", f_csv, sha_csv), "",
  sprintf("- **Resultado:** %s. Tempo: %.0f s.", if (ok) "todas as conferências passam" else "FALHA: PARE (ver a tabela de conferências)", as.numeric(difftime(Sys.time(), t0, units = "secs"))), "")
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| conferências:", if (ok) "ok" else "FALHA", "| a:", format(max_a), "| b:", format(max_b), "| AT:", format(dif_at), "\n")
if (!ok) quit(status = 1)
