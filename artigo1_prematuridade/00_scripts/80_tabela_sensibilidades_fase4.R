# 80_tabela_sensibilidades_fase4.R — Fase 4, fecho da C2 à C4: tabela_sensibilidades_fase4.csv (mensagem "C2, C3 e C4 em
# lote", 19/10/2026, "Saída final"). Uma linha por análise: TMR (°C e percentil), IC da TMR, RR no x99 (IC), RR no x1 (IC),
# número de concentrações, φ (mín., mediana, máx.), fallback e marca de borda (com o RR contra a mediana, descritivo, D13,
# item 3). Só lê saídas já gravadas, com o SHA-256 conferido contra o registrado no log de cada script; nenhum ajuste novo.
# Linhas: principal (Fase 3, referência); C2 (D3); C3 (31 análises do 74, mais as duas sem análise e os feriados locais,
# pendentes); C4 (efeitos fixos, multinível, os quatro exploratórios da D15 com o Wald na nota, uma etapa e S3).
# A tabela do critério da C1 fica à parte (criterio_c1_fase4_20261019.csv).
# Saída (fora do git): 01_saidas/fase4/tabela_sensibilidades_fase4.csv. Log logs/tabela_sensibilidades_fase4_<RODADA>.md.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/80_tabela_sensibilidades_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("tabela_sensibilidades_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
f_csv <- file.path("01_saidas", "fase4", "tabela_sensibilidades_fase4.csv"); stopifnot(!file.exists(f_csv))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/80_tabela_sensibilidades_fase4.R"
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
icf <- function(a, li, ls, d = 3) ifelse(is.na(a), "—", ifelse(is.na(li), paste0(br(a, d), " (borda)"), sprintf("%s (%s a %s)", br(a, d), br(li, d), br(ls, d))))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
sujos <- git("status", "--porcelain", "--", ESTE); if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current"); st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:"); inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
# entradas: as da Fase 2 e 3 com SHA fixo; as da Fase 4 com o SHA registrado no log do script que as gravou
FIXO <- c("01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds" = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d",
          "01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds" = "52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e")
DO_LOG <- c("01_saidas/fase4/d3_fase4_20261019.rds" = "logs/d3_fase4_20261019.md", "01_saidas/fase4/c3_fase4_20261019.csv" = "logs/c3_fase4_20261019.md",
            "01_saidas/fase4/c4_meta_fase4_20261019.rds" = "logs/c4_meta_fase4_20261019.md", "01_saidas/fase4/c4_uma_etapa_fase4_20261019.rds" = "logs/c4_uma_etapa_fase4_20261019.md",
            "01_saidas/fase4/c4_s3_fase4_20261019.rds" = "logs/c4_s3_fase4_20261019.md")
sha_ent <- vapply(c(names(FIXO), names(DO_LOG)), sha, "")
if (!identical(unname(sha_ent[names(FIXO)]), unname(FIXO))) stop("entrada da Fase 2 ou 3 com SHA-256 diferente do registrado")
for (p in names(DO_LOG)) if (!grepl(paste0("`", p, "`: `", sha_ent[[p]], "`"), paste(readLines(DO_LOG[[p]], encoding = "UTF-8"), collapse = "\n"), fixed = TRUE)) stop(p, ": SHA-256 diferente do registrado em ", DO_LOG[[p]])
rds32 <- readRDS(names(FIXO)[1])$resultados; r45 <- readRDS(names(FIXO)[2])
d3 <- readRDS(names(DO_LOG)[1])$d3$linha; c3 <- utils::read.csv(names(DO_LOG)[2], stringsAsFactors = FALSE, encoding = "UTF-8")
c4m <- readRDS(names(DO_LOG)[3]); c4u <- readRDS(names(DO_LOG)[4]); c4s <- readRDS(names(DO_LOG)[5])
phi32 <- vapply(rds32, function(x) x$principal$phi, 0); stopifnot(length(phi32) == 26L, all(is.finite(phi32)))
COLS <- c("id", "grupo", "analise", "status", "n_concentracoes", "tmr_c", "tmr_percentil", "ic_tmr_li", "ic_tmr_ls", "rr99", "rr99_li", "rr99_ls", "rr01", "rr01_li", "rr01_ls",
          "borda", "rr_mediana_x99", "rr_mediana_x99_li", "rr_mediana_x99_ls", "rr_mediana_x1", "rr_mediana_x1_li", "rr_mediana_x1_ls", "phi_min", "phi_med", "phi_max", "fallback", "nota")
linha <- function(...) { a <- list(...); z <- setNames(as.list(rep(NA, length(COLS))), COLS); z[names(a)] <- a; as.data.frame(z, stringsAsFactors = FALSE) }
phis <- function(v) list(phi_min = min(v), phi_med = stats::median(v), phi_max = max(v))
de_fluxo <- function(x, id, grupo, analise) {   # linha do fluxo comum (72 e 74): percentil_tmr em 0–1
  b <- if (isTRUE(x$fronteira)) x$lado_borda else NA_character_
  do.call(linha, c(list(id = id, grupo = grupo, analise = analise, status = "ok", n_concentracoes = as.integer(x$incluidas), tmr_c = x$tmr, tmr_percentil = 100 * x$percentil_tmr,
                        ic_tmr_li = x$ic_tmr_li, ic_tmr_ls = x$ic_tmr_ls, rr99 = x$rr99, rr99_li = x$rr99_li, rr99_ls = x$rr99_ls, rr01 = x$rr01, rr01_li = x$rr01_li, rr01_ls = x$rr01_ls, borda = b,
                        rr_mediana_x99 = x$rr99_mediana, rr_mediana_x99_li = x$rr99_mediana_li, rr_mediana_x99_ls = x$rr99_mediana_ls,
                        rr_mediana_x1 = x$rr01_mediana, rr_mediana_x1_li = x$rr01_mediana_li, rr_mediana_x1_ls = x$rr01_mediana_ls,
                        phi_min = x$phi_min, phi_med = x$phi_med, phi_max = x$phi_max, fallback = x$passo_fallback,
                        nota = if (!is.na(x$motivos_exclusao) && nzchar(x$motivos_exclusao)) paste("excluídas:", x$motivos_exclusao) else NA_character_))) }
# principal (Fase 3)
tc <- r45$tmr[r45$tmr$nivel == "combinada", ]; cc <- r45$contrastes[r45$contrastes$nivel == "combinada", ]; c99 <- cc[cc$percentil == "p99", ]; c01 <- cc[cc$percentil == "p1", ]
stopifnot(nrow(tc) == 1, nrow(c99) == 1, nrow(c01) == 1, !tc$fronteira)
tab <- list(do.call(linha, c(list(id = "P0", grupo = "Principal", analise = "Principal (Fase 3; referência)", status = "ok", n_concentracoes = 26L, tmr_c = tc$tmr, tmr_percentil = 100 * tc$percentil_tmr,
                                  ic_tmr_li = tc$ic_li, ic_tmr_ls = tc$ic_ls, rr99 = c99$rr, rr99_li = c99$rr_li, rr99_ls = c99$rr_ls, rr01 = c01$rr, rr01_li = c01$rr_li, rr01_ls = c01$rr_ls,
                                  fallback = "nenhum"), phis(phi32))))
tab[[length(tab) + 1]] <- de_fluxo(d3, "C2-D3", "Autocorrelação", "D3: resíduos de deviance defasados (lags 1–7)")
GRUPO <- c(E = "Exposição", P = "PM2.5", CB = "Cross-basis", T = "Tempo e calendário", D = "Denominador", O = "Desfecho")   # grupos da tabela da C3 na mensagem
for (k in seq_len(nrow(c3))) tab[[length(tab) + 1]] <- de_fluxo(c3[k, ], paste0("C3-", c3$id[k]), GRUPO[[sub("[0-9].*$", "", c3$id[k])]], sub("^(Exposição|PM2\\.5|Cross-basis|Denominador|Desfecho): ", "", c3$rotulo[k]))
tab[[length(tab) + 1]] <- linha(id = "C3-NB", grupo = "Modelo", analise = "Binomial negativa", status = sprintf("não se aplica (φ > 2 em %d de 26 no principal)", sum(phi32 > 2)))
tab[[length(tab) + 1]] <- linha(id = "C3-N2000", grupo = "Inclusão", analise = "Corte de 2.000 eventos", status = "idêntico ao principal (nenhuma concentração sai; log do 74)")
tab[[length(tab) + 1]] <- linha(id = "C3-FL", grupo = "Calendário", analise = "Feriados locais", status = "pendente (sem a tag feriados_locais-v1.0)")
mods <- c4m$modelos; stopifnot(nrow(mods) == 3L)
for (k in 2:3) { x <- mods[k, ]
  tab[[length(tab) + 1]] <- do.call(linha, c(list(id = c("", "C4-FIX", "C4-MULTI")[k], grupo = "Meta-análise", analise = x$rotulo, status = "ok", n_concentracoes = 26L, tmr_c = x$tmr, tmr_percentil = 100 * x$percentil_tmr,
    ic_tmr_li = x$ic_tmr_li, ic_tmr_ls = x$ic_tmr_ls, rr99 = x$rr99, rr99_li = x$rr99_li, rr99_ls = x$rr99_ls, rr01 = x$rr01, rr01_li = x$rr01_li, rr01_ls = x$rr01_ls,
    borda = if (isTRUE(x$fronteira)) x$lado_borda else NA_character_, rr_mediana_x99 = x$rr99_mediana, rr_mediana_x1 = x$rr01_mediana, fallback = "nenhum (1ª etapa do 32)"), phis(phi32))) }
ex <- c4m$exploratorios; rot_ex <- c(regiao = "Exploratório da D15: macrorregião (fator)", cesarea = "Exploratório da D15: % de cesárea (centrada)", prenatal = "Exploratório da D15: pré-natal com 7 ou mais consultas (centrada)")
for (k in seq_len(nrow(ex))) tab[[length(tab) + 1]] <- linha(id = paste0("C4-EX-", ex$termo[k]), grupo = "Meta-regressão exploratória", analise = rot_ex[[ex$termo[k]]], status = ex$status[k], n_concentracoes = 26L,
  nota = sprintf("Wald %s (%d gl; p = %s); Q residual com o termo %s (%d gl), sem %s (%d gl)", br(ex$estatistica[k], 2), as.integer(ex$gl[k]), formatC(ex$p[k], format = "g", digits = 3, decimal.mark = ","), br(ex$Q_com[k], 1), as.integer(ex$gl_com[k]), br(ex$Q_sem[k], 1), as.integer(ex$gl_sem[k])))
tab[[length(tab) + 1]] <- linha(id = "C4-EX-idhm", grupo = "Meta-regressão exploratória", analise = "Exploratório da D15: IDHM 2010 (centrado)", status = "pendente (download não feito; A1-103 e A1-104)")
cu <- c4u$curva; a <- c4u$ajuste; r99 <- cu$rr[cu$rr$rotulo == "x99", ]; r01 <- cu$rr[cu$rr$rotulo == "x1", ]; mdn <- cu$rr_mediana
tab[[length(tab) + 1]] <- linha(id = "C4-UMA", grupo = "Modelo", analise = "Uma etapa (D11, 5.3)", status = a$status, n_concentracoes = length(a$unidades), tmr_c = cu$tmr, tmr_percentil = cu$tmr_pct,
  ic_tmr_li = cu$ic_tmr[1], ic_tmr_ls = cu$ic_tmr[2], rr99 = r99$rr, rr99_li = r99$rr_li, rr99_ls = r99$rr_ls, rr01 = r01$rr, rr01_li = r01$rr_li, rr01_ls = r01$rr_ls,
  borda = if (cu$fronteira) cu$lado_borda else NA_character_, rr_mediana_x99 = if (is.null(mdn)) NA else mdn$rr[1], rr_mediana_x99_li = if (is.null(mdn)) NA else mdn$rr_li[1], rr_mediana_x99_ls = if (is.null(mdn)) NA else mdn$rr_ls[1],
  rr_mediana_x1 = if (is.null(mdn)) NA else mdn$rr[2], rr_mediana_x1_li = if (is.null(mdn)) NA else mdn$rr_li[2], rr_mediana_x1_ls = if (is.null(mdn)) NA else mdn$rr_ls[2],
  phi_min = a$phi, phi_med = a$phi, phi_max = a$phi, fallback = "sem fallback (D11, 5.3)", nota = "φ único; percentil da própria concentração; eixo do principal")
ps <- c4s$por_concentracao; inc <- ps$status == "ok"; e <- function(m) exp(m$estimativa + c(0, -1, 1) * 1.96 * m$ep); s99 <- e(c4s$meta_p99); s01 <- e(c4s$meta_p1)
tab[[length(tab) + 1]] <- do.call(linha, c(list(id = "C4-S3", grupo = "Modelo", analise = "S3: DLNM penalizado (D11, 5.2)", status = "ok", n_concentracoes = sum(inc), tmr_percentil = 100 * c4s$q_tmr,
  rr99 = s99[1], rr99_li = s99[2], rr99_ls = s99[3], rr01 = s01[1], rr01_li = s01[2], rr01_ls = s01[3], fallback = "não se aplica (concentração que não converge sai)",
  nota = paste0("referência no quantil q da TMR combinada do principal em cada concentração; contrastes no p99 e no p1 da própria concentração; meta univariada",
                if (any(!inc)) paste0("; fora: ", paste(ps$concentracao[!inc], collapse = ", ")) else "")), phis(ps$phi[inc])))
tab <- do.call(rbind, tab); stopifnot(!anyDuplicated(tab$id), nrow(tab) == 1 + 1 + nrow(c3) + 3 + 2 + nrow(ex) + 1 + 2)
# D13, item 3: no lado da borda o contraste vale 1, sem IC (o fluxo comum grava 1 a 1; aqui vira NA, como na uma etapa)
b99 <- tab$borda %in% "x99"; b01 <- tab$borda %in% "x1"; stopifnot(all(tab$rr99[b99] == 1), all(tab$rr01[b01] == 1))
tab$rr99_li[b99] <- NA; tab$rr99_ls[b99] <- NA; tab$rr01_li[b01] <- NA; tab$rr01_ls[b01] <- NA
num <- vapply(tab, is.double, TRUE); out <- tab; out[num] <- lapply(out[num], function(v) ifelse(is.na(v), NA, sprintf("%.17g", v)))
utils::write.csv(out, f_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8"); sha_out <- sha(f_csv)
stopifnot(versao() == "4443971b")
md_txt <- c("# Fase 4, fecho da C2 à C4: tabela das sensibilidades", "",
  sprintf("- **Gerado por:** `00_scripts/80_tabela_sensibilidades_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()`: %s.", sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Entradas (SHA-256 = registrados no log de origem):** %s.", paste(sprintf("`%s` (`%s`)", names(sha_ent), sha_ent), collapse = "; ")),
  "- **Leitura:** borda = o lado em que a TMR caiu na ponta da grade; ali o contraste vale 1, sem IC (o fluxo comum grava o IC como 1 a 1; aqui fica vazio) e o RR contra a mediana fica no CSV como descritivo (D13, item 3). A S3 não estima TMR: o percentil é o da referência.", "",
  tabela_md(data.frame(ID = tab$id, Análise = paste0(tab$grupo, ": ", tab$analise), N = ifelse(is.na(tab$n_concentracoes), "—", tab$n_concentracoes),
                       `TMR °C (percentil)` = ifelse(is.na(tab$tmr_c), ifelse(is.na(tab$tmr_percentil), "—", paste0("— (", br(tab$tmr_percentil, 1), ")")), sprintf("%s (%s)", br(tab$tmr_c, 1), br(tab$tmr_percentil, 1))),
                       `IC da TMR` = ifelse(is.na(tab$ic_tmr_li), "—", sprintf("%s a %s", br(tab$ic_tmr_li, 1), br(tab$ic_tmr_ls, 1))),
                       `RR x99 (IC)` = icf(tab$rr99, tab$rr99_li, tab$rr99_ls), `RR x1 (IC)` = icf(tab$rr01, tab$rr01_li, tab$rr01_ls),
                       `φ (mín.; med.; máx.)` = ifelse(is.na(tab$phi_med), "—", sprintf("%s; %s; %s", br(tab$phi_min, 3), br(tab$phi_med, 3), br(tab$phi_max, 3))),
                       Fallback = ifelse(is.na(tab$fallback), "—", tab$fallback), Borda = ifelse(is.na(tab$borda), "—", tab$borda),
                       `Situação ou nota` = ifelse(tab$status == "ok", ifelse(is.na(tab$nota), "ok", tab$nota), tab$status), check.names = FALSE)), "",
  sprintf("- **Saída (fora do git):** `%s`: `%s` (%d linhas).", f_csv, sha_out, nrow(tab)), "")
writeLines(md_txt, arq, useBytes = TRUE); cat("gravado:", arq, "| linhas:", nrow(tab), "\n")
