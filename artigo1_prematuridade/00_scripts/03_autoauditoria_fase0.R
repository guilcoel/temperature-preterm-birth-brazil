# 03_autoauditoria_fase0.R — Fase 0, A7.1: autoauditoria por código dos números da A5, por caminhos independentes.
#
# Refaz cada número da A5 por um caminho diferente do 02_recontagens_fase0.R e compara com os CSV de 01_saidas/fase0/:
#   - contagens: série municipal (serie_diaria(nivel = "municipio")) somada por concentração pelo concentracoes(),
#     em vez da série por concentração;
#   - temperatura e PM2.5 diários: diaria_recorte(var, "nucleo"), que lê o clima municipal da cidade-núcleo,
#     em vez da coluna da série;
#   - médias semanais: recalculadas a partir dos dias, em vez de lidas do expo_semanal();
#   - dias das janelas: seq() de datas.
# Também confere o que o git aceitaria na raiz do repositório dos artigos (C7), as regras de script e log (C9) e, no
# complemento da Fase 0A, a MM14 (C10) e os itens 1, 2, 3, 5, 6 e 7 (C11).
#
# Linha vermelha e sigilo como no 02: nenhum desfecho é cruzado com exposição; o log só tem contagens agregadas e diferenças.
# Fase 0 refeita (base 4443971b): confere os CSV de 01_saidas/fase0_rerun/ e os logs _rerun_ (a MM14 e a MM9 da C10 vêm do
# a5_4c_mm14_mm9_equivalentes.csv do 08_mm14_equivalente_rerun.R). Grava logs/autoauditoria_fase0_rerun_<FASE0_RERUN_DATA>.md
# e nunca sobrescreve; os logs de autoauditoria da Fase 0A (Parte A e complemento) são registro. Sai com 1 se alguma
# conferência falhar. As conferências dos itens novos (A1, A3, A6–A9) estão no 12_autoauditoria_itens_novos_rerun.R.
# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/03_autoauditoria_fase0.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")

RAIZ <- "/Volumes/Forja/Doc/artigos_perinatais_clima"
saida <- file.path("01_saidas", "fase0_rerun")
hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
D <- as.Date; INI <- D("2012-01-01"); FIM <- D("2024-12-31")
TOL <- 1e-8
P <- c(.01, .025, .05, .10, .25, .50, .75, .90, .95, .975, .99)
PN <- paste0("p", c("1", "2,5", "5", "10", "25", "50", "75", "90", "95", "97,5", "99"))

ler_csv <- function(f) read.csv(file.path(saida, f), stringsAsFactors = FALSE, check.names = FALSE,
                                colClasses = c(recorte_principal = "character"))
a51 <- read.csv(file.path(saida, "a5_1_totais.csv"), stringsAsFactors = FALSE)
a52 <- ler_csv("a5_2_eventos_janelas.csv"); a53 <- ler_csv("a5_3_percentis_diarios.csv")
a54 <- ler_csv("a5_4_semanal_mm.csv"); a55 <- ler_csv("a5_5_pm25_dias_utilizaveis.csv")
a54b <- ler_csv("a5_4c_mm14_mm9_equivalentes.csv")                 # A5 da rodada refeita (08_mm14_equivalente_rerun.R)

res <- data.frame()
confere <- function(item, conferencia, esperado, obtido, ok) {
  res <<- rbind(res, data.frame(item = item, conferencia = conferencia, esperado = as.character(esperado),
                                obtido = as.character(obtido), ok = isTRUE(ok), stringsAsFactors = FALSE))
}
dif_max <- function(a, b) max(abs(a - b))
fmt <- function(x) format(signif(x, 3), scientific = TRUE)

# ---------------------------------------------------------------- C1 dias das janelas
dias <- function(a, b) length(seq(D(a), D(b), by = "day"))
mes <- as.integer(format(seq(INI, FIM, by = "day"), "%m"))
jan <- list(c("PTB principal", "2012-04-14", "2024-08-06", 4498), c("perinatal principal", "2012-05-26", "2024-08-06", 4456),
            c("termo precoce (regra do principal)", "2012-04-28", "2024-11-19", 4589), c("2012–2024", "2012-01-01", "2024-12-31", 4749))
for (j in jan) confere("C1", paste("dias da janela", j[1]), j[4], dias(j[2], j[3]), dias(j[2], j[3]) == as.integer(j[4]))
confere("C1", "dias de novembro a março em 2012–2024", 1967, sum(mes %in% c(11, 12, 1, 2, 3)), sum(mes %in% c(11, 12, 1, 2, 3)) == 1967)
dj <- unique(a52[, c("desfecho", "janela", "ini", "fim", "dias_janela")])
ok_dj <- mapply(function(i, f, n) dias(i, f) == n, dj$ini, dj$fim, dj$dias_janela)
confere("C1", "dias_janela do CSV da A5.2 = seq() das datas (4 janelas)", "4 de 4", paste(sum(ok_dj), "de 4"), all(ok_dj))

# ---------------------------------------------------------------- C2 e C3 contagens pela série municipal (sem exposição)
mun <- as.data.frame(serie_diaria(nivel = "municipio", coorte_fixa = TRUE,
                                  colunas = c("CD_MUN6", "data", "nv_unicos", "ptb", "obito_perinatal")))
mun$data <- as.Date(mun$data)
conc <- as.data.frame(concentracoes())
mun$rec <- as.character(conc$CD_RECORTE)[match(as.character(mun$CD_MUN6), as.character(conc$CD_MUN6))]
confere("C2", "municípios da série municipal, todos mapeados no concentracoes()", 277,
        length(unique(mun$CD_MUN6)), length(unique(mun$CD_MUN6)) == 277 && !anyNA(mun$rec))
m12 <- mun[mun$data >= INI & mun$data <= FIM, ]
esperado <- c(nv_unicos = 13791848, ptb = 1405697, obito_perinatal = 180064)
for (v in names(esperado)) {
  s <- sum(m12[[v]], na.rm = TRUE)
  confere("C2", paste("total de", v, "em 2012–2024, pela série municipal"), esperado[[v]], s,
          s == esperado[[v]] && s == a51$soma[a51$coluna == v])
  dna <- sort(unique(m12$data[is.na(m12[[v]])]))
  esp_na <- a51$dias_com_NA[a51$coluna == v]
  confere("C2", paste("dias com NA em", v), esp_na,
          if (length(dna)) paste0(length(dna), " (", paste(format(range(dna)), collapse = " a "), ")") else "0",
          length(dna) == esp_na)
}
for (i in seq_len(nrow(dj))) {
  j <- dj[i, ]; v <- j$desfecho
  dentro <- m12$data >= D(j$ini) & m12$data <= D(j$fim)
  ev <- tapply(m12[[v]][dentro], m12$rec[dentro], sum, na.rm = TRUE)
  tot <- tapply(m12[[v]], m12$rec, sum, na.rm = TRUE)
  csv <- a52[a52$desfecho == v & a52$janela == j$janela, ]
  d_ev <- dif_max(ev[csv$recorte_principal], csv$eventos_janela); d_tot <- dif_max(tot[csv$recorte_principal], csv$total_2012_2024)
  confere("C3", sprintf("%s, janela %s: eventos e total por concentração (26), série municipal × CSV", v, j$janela),
          "diferença 0", sprintf("eventos %s; total %s", d_ev, d_tot), nrow(csv) == 26 && d_ev == 0 && d_tot == 0)
  pp <- 100 * (sum(tot) - sum(ev)) / sum(tot)
  confere("C3", sprintf("%s, janela %s: perda total %%", v, j$janela),
          sprintf("%.4f", 100 * sum(csv$perda) / sum(csv$total_2012_2024)), sprintf("%.4f", pp),
          abs(pp - 100 * sum(csv$perda) / sum(csv$total_2012_2024)) < 1e-9)
}
fora <- sum(m12$ptb[m12$data < D("2012-01-04") | m12$data > D("2024-11-15")], na.rm = TRUE)
confere("C3", "PTB fora da janela de evento possível, série municipal", 0, fora, fora == 0)
pmin <- a52[a52$janela == "principal", ]
peq <- sum(unlist(a52[, c("total_2012_2024", "eventos_janela", "perda")]) %in% 1:9)
confere("C3", "contagens de 1 a 9 na A5.2 (exigiriam máscara ou supressão)", 0, peq, peq == 0)
abaixo <- function(v, lim) paste(sort(pmin$concentracao[pmin$desfecho == v & pmin$eventos_janela < lim]), collapse = ", ")
confere("C3", "perinatal, janela principal, abaixo de 2.000", "Campo Grande, Florianópolis/SC, Sorocaba/SP",
        abaixo("obito_perinatal", 2000), abaixo("obito_perinatal", 2000) == "Campo Grande, Florianópolis/SC, Sorocaba/SP")
confere("C3", "abaixo de 1.000 na janela principal (PTB e perinatal)", "", paste0(abaixo("ptb", 1000), abaixo("obito_perinatal", 1000)),
        abaixo("ptb", 1000) == "" && abaixo("obito_perinatal", 1000) == "")
rm(mun, m12); invisible(gc())

# ---------------------------------------------------------------- C4 percentis diários pelo clima municipal da cidade-núcleo
tn <- as.data.frame(diaria_recorte("tmean", "nucleo")); tn$data <- as.Date(tn$data)
tn$recorte_principal <- as.character(tn$recorte_principal)
sd <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_nucleo")))
sd$data <- as.Date(sd$data); sd$recorte_principal <- as.character(sd$recorte_principal)
t12 <- tn[tn$data >= INI & tn$data <= FIM, ]
k <- merge(t12, sd, by = c("recorte_principal", "data"))
confere("C4", "tmean diária: diaria_recorte() × coluna tmean_nucleo da série (2012–2024)", "26 × 4.749 dias iguais",
        sprintf("%d dias casados; diferença máxima %s", nrow(k), fmt(dif_max(k$x, k$tmean_nucleo))),
        nrow(k) == 26 * 4749 && dif_max(k$x, k$tmean_nucleo) < TOL)
pct_conf <- function(df, rotulo) {
  csv <- a53[a53$periodo == rotulo, ]
  d7 <- d6 <- dn <- 0
  for (r in csv$recorte_principal) {
    x <- df$x[df$recorte_principal == r]
    q7 <- quantile(x, P, type = 7, names = FALSE); q6 <- quantile(x, P, type = 6, names = FALSE)
    lin <- csv[csv$recorte_principal == r, ]
    d7 <- max(d7, dif_max(q7, unlist(lin[PN])), abs(mean(x) - lin$media), abs(min(x) - lin$minimo), abs(max(x) - lin$maximo),
              abs((q7[11] - q7[1]) - lin$amplitude_p99_p1))
    d6 <- max(d6, dif_max(q6, unlist(lin[PN])))
    dn <- max(dn, abs(length(x) - lin$n_dias) + abs(sum(is.na(x)) - lin$n_NA))
  }
  confere("C4", sprintf("%s: n, NA, média, mín., máx., 11 percentis (type 7) e p99 − p1, 26 concentrações", rotulo),
          sprintf("diferença < %s", fmt(TOL)), sprintf("%s (n e NA: %s)", fmt(d7), dn), d7 < TOL && dn == 0)
  confere("C4", sprintf("%s: sensibilidade da conferência (type 6 contra o CSV)", rotulo), "diferença > 0",
          fmt(d6), d6 > 1e-6)
}
pct_conf(t12, "ano inteiro 2012–2024")
pct_conf(t12[as.integer(format(t12$data, "%m")) %in% c(11, 12, 1, 2, 3), ], "novembro a março")

# ---------------------------------------------------------------- C5 semanas e médias móveis recalculadas dos dias
es <- as.data.frame(expo_semanal("tmean", "nucleo")); es$dum_est <- as.Date(es$dum_est)
es$recorte_principal <- as.character(es$recorte_principal)
dum <- seq(D("2011-04-17"), D("2024-03-05"), by = "day")
sc <- sprintf("s%02d", 1:37)
d_semana <- d54 <- d54b <- 0; n_ok <- 0
for (r in a54$recorte_principal) {
  g <- tn[tn$recorte_principal == r, ]; g <- g[order(g$data), ]
  stopifnot(all(diff(g$data) == 1))
  cs <- c(0, cumsum(g$x)); n7 <- nrow(g) - 6
  m7 <- (cs[(1:n7) + 7] - cs[1:n7]) / 7                              # média dos dias i..i+6
  ini <- outer(match(dum, g$data), 7L * (0:36), "+")                  # posição do 1º dia de s01..s37
  S <- matrix(m7[ini], nrow = length(dum))
  e <- es[es$recorte_principal == r & es$dum_est >= dum[1] & es$dum_est <= dum[length(dum)], ]
  e <- e[order(e$dum_est), ]
  if (nrow(e) == length(dum) && all(e$dum_est == dum)) n_ok <- n_ok + 1
  d_semana <- max(d_semana, dif_max(S, as.matrix(e[, sc])))
  emp <- as.vector(S); dist <- m7[sort(unique(as.vector(ini)))]
  pc <- c(.01, .10, .75, .90, .99)
  qi <- quantile(emp, pc, type = 7, names = FALSE); qii <- quantile(dist, pc, type = 7, names = FALSE)
  mm9 <- rowMeans(S[, 29:37]); t1 <- rowMeans(S[, 1:14]); t2 <- rowMeans(S[, 15:28])
  qm <- quantile(mm9, c(.01, .5, .99), type = 7, names = FALSE); Fi <- ecdf(emp)
  lin <- a54[a54$recorte_principal == r, ]
  d54 <- max(d54, dif_max(qi, unlist(lin[paste0("i_p", c(1, 10, 75, 90, 99))])),
             dif_max(qii, unlist(lin[paste0("ii_p", c(1, 10, 75, 90, 99))])),
             dif_max(qi - qii, unlist(lin[paste0("dif_p", c(1, 10, 75, 90, 99))])),
             dif_max(qm, c(lin$mm9_p1, lin$mm9_p50, lin$mm9_p99)),
             abs(100 * Fi(qm[3]) - lin$mm9_p99_em_pct_semanal_i), abs(100 * Fi(qm[1]) - lin$mm9_p1_em_pct_semanal_i),
             dif_max(quantile(t1, c(.01, .99), type = 7, names = FALSE), c(lin$t1_p1, lin$t1_p99)),
             dif_max(quantile(t2, c(.01, .99), type = 7, names = FALSE), c(lin$t2_p1, lin$t2_p99)),
             abs(length(dist) - lin$n_janelas_ii), abs(nrow(S) - lin$n_dum_est))
  # C10 (complemento, item 4): MM14 e MM9, percentil semanal equivalente na leitura (i), pelo caminho dos dias
  lb <- a54b[a54b$recorte_principal == r, ]
  q1 <- quantile(t1, c(.01, .99), type = 7, names = FALSE); q2 <- quantile(t2, c(.01, .99), type = 7, names = FALSE)
  q9 <- quantile(mm9, c(.01, .99), type = 7, names = FALSE)
  d54b <- max(d54b, if (nrow(lb) != 1) Inf else max(
    dif_max(c(q1, q2, q9), c(lb$t1_p1, lb$t1_p99, lb$t2_p1, lb$t2_p99, lb$mm9_p1, lb$mm9_p99)),
    dif_max(100 * Fi(c(q1, q2, q9)), c(lb$t1_p1_pct_i, lb$t1_p99_pct_i, lb$t2_p1_pct_i, lb$t2_p99_pct_i,
                                       lb$mm9_p1_pct_i, lb$mm9_p99_pct_i)),
    abs(nrow(S) - lb$n_dum_est)))
}
confere("C10", "MM14 (1º e 2º trimestres) e MM9: p1, p99 e percentil semanal equivalente (i), recalculados dos dias × CSV da A5 (08)",
        sprintf("< %s", fmt(TOL)), fmt(d54b), nrow(a54b) == 26 && d54b < TOL)
confere("C5", "expo_semanal: dum_est de 2011-04-17 a 2024-03-05, todos os dias, por concentração", "26 de 26",
        paste(n_ok, "de 26"), n_ok == 26)
confere("C5", "s01…s37 do expo_semanal × médias de 7 dias recalculadas da tmean diária da cidade-núcleo", sprintf("< %s", fmt(TOL)),
        fmt(d_semana), d_semana < TOL)
confere("C5", "A5.4 inteira (leituras (i) e (ii), diferenças, MM9, ecdf, MM14, contagens) recalculada × CSV", sprintf("< %s", fmt(TOL)),
        fmt(d54), d54 < TOL)
rm(es, sd, k); invisible(gc())

# ---------------------------------------------------------------- C6 PM2.5 pelo PM2.5 municipal da cidade-núcleo
pn <- as.data.frame(diaria_recorte("pm25_local_zero_na", "nucleo")); pn$data <- as.Date(pn$data)
pn$recorte_principal <- as.character(pn$recorte_principal)
sp <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE,
                                 colunas = c("recorte_principal", "data", "pm25_local_zero_na_nucleo")))
sp$data <- as.Date(sp$data); sp$recorte_principal <- as.character(sp$recorte_principal)
kp <- merge(pn[pn$data >= INI & pn$data <= FIM, ], sp, by = c("recorte_principal", "data"))
mesmo_na <- all(is.na(kp$x) == is.na(kp$pm25_local_zero_na_nucleo))
dv <- dif_max(kp$x[!is.na(kp$x)], kp$pm25_local_zero_na_nucleo[!is.na(kp$x)])
confere("C6", "PM2.5 diário: diaria_recorte() × coluna da série (2012–2024)", "mesmos NA e valores iguais",
        sprintf("%d dias casados; NA iguais: %s; diferença máxima %s", nrow(kp), mesmo_na, fmt(dv)),
        nrow(kp) == 26 * 4749 && mesmo_na && dv < TOL)
d55 <- 0
for (i in seq_len(nrow(a55))) {
  lin <- a55[i, ]
  g <- pn[pn$recorte_principal == lin$recorte_principal, ]; g <- g[order(g$data), ]
  ma <- (g$x + c(NA, g$x[-nrow(g)])) / 2
  ini <- D(sub(".*\\((\\S+) a .*", "\\1", lin$janela)); fim <- D(sub(".* a (\\S+)\\)$", "\\1", lin$janela))
  w <- g$data >= ini & g$data <= fim
  d55 <- max(d55, abs(sum(!is.na(ma[w])) - lin$dias_utilizaveis), abs(sum(w) - lin$dias_janela),
             abs(sum(is.na(g$x[w])) - lin$sem_valor_janela))
}
confere("C6", "dias de modelo utilizáveis, dias da janela e dias sem valor (26 × 2 janelas) × CSV", "diferença 0", d55, d55 == 0)
cg <- a55$sem_valor_2012_2024[a55$concentracao == "Campo Grande"][1]
confere("C6", "Campo Grande, dias sem valor em 2012–2024 (especificação §2.3)", 361, cg, cg == 361)
naop <- sort(unique(a55$concentracao[!a55$passa_90]))
confere("C6", "concentrações abaixo de 90%", "Brasília/DF, Campo Grande, Goiânia/GO", paste(naop, collapse = ", "),
        identical(naop, c("Brasília/DF", "Campo Grande", "Goiânia/GO")))

# ---------------------------------------------------------------- C7 o que o git aceitaria
git <- function(...) suppressWarnings(system2("git", c("-C", RAIZ, ...), stdout = TRUE, stderr = TRUE))
livres <- git("ls-files", "--others", "--exclude-standard")
ext_dado <- "\\.(parquet|dbc|csv|tsv|rds|rda|rdata|feather|fst|qs|arrow|sqlite|duckdb|xlsx|xls|json|zip|gz|sav|dta|rhistory)$"
dado <- livres[grepl(ext_dado, tolower(livres)) & !grepl("^artigo[^/]*/renv/settings\\.json$", livres)]
confere("C7", "arquivos que o git aceitaria com extensão de dado (fora a exceção do renv/settings.json)", 0,
        if (length(dado)) paste(dado, collapse = "; ") else 0, length(dado) == 0)
grandes <- livres[file.size(file.path(RAIZ, livres)) > 5 * 1024^2]
confere("C7", "arquivos que o git aceitaria com mais de 5 MB", 0, length(grandes), length(grandes) == 0)
alvo <- c(file.path("artigo1_prematuridade/00_scripts", c("00_ambiente.R", "00_dependencias.R", "01_interface.R",
                                                            "02_recontagens_fase0.R", "03_autoauditoria_fase0.R",
                                                            "04_mm14_equivalentes_fase0.R")),
          file.path("artigo1_prematuridade/logs", c("ambiente_fase0_20261008.md", "attrdl_consulta_20261008.md", "auditoria_fase0_20261008.md",
                                                     "desvios_especificacao.md", "interface_fase0_20261008.md",
                                                     "interface_conclusoes_fase0_20261008.md", "recontagens_fase0_20261008.md",
                                                     "renv_fase0_20261008.md", "sessionInfo_20261008.txt",
                                                     "mm14_fase0_20261008.md", "csv_sha256_fase0_20261008.md",
                                                     "complemento_fase0A_saidas_20261008.md", "autoauditoria_fase0_20261008.md",
                                                     "auditoria_complemento_fase0A_20261008.md")),
          "artigo1_prematuridade/00_scripts/05_saidas_complemento_fase0A.sh",
          "artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_20261008.md",
          "artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_complemento_20261008.md", "artigo1_prematuridade/CLAUDE.md",
          "artigo1_prematuridade/renv.lock", "artigo1_prematuridade/.Renviron", "artigo1_prematuridade/.Rprofile",
          "ferramentas/checa_sigilo.sh", "ferramentas/testa_checa_sigilo.sh", "ferramentas/baixa_attrdl.R",
          "codigo_compartilhado/inst/terceiros/ORIGEM.md",
          "docs/coordenacao/RESPOSTA_chat_A1_auditoria_20261008.md", "docs/coordenacao/RESPOSTA_chat_A1_ajustes_20261008.md",
          # Fase 0 refeita: scripts, arquivador e logs gerados até aqui
          file.path("artigo1_prematuridade/00_scripts", c("06_entrada_rerun.R", "07_compara_fase0_rerun.R", "08_mm14_equivalente_rerun.R",
                                                            "09_populacao_dum_rerun.R", "10_desvio9_rerun.R", "11_sha256_csv_rerun.R",
                                                            "12_autoauditoria_itens_novos_rerun.R")),
          "ferramentas/arquiva_fase0A_rerun.sh",
          file.path("artigo1_prematuridade/logs", paste0(c("inventario_fase0A_rerun_", "auditoria_plano_fase0_rerun_", "entrada_fase0_rerun_",
                                                           "ambiente_fase0_rerun_", "interface_fase0_rerun_", "recontagens_fase0_rerun_",
                                                           "comparacao_a4_fase0_rerun_", "mm14_equivalente_fase0_rerun_",
                                                           "populacao_dum_fase0_rerun_", "desvio9_fase0_rerun_", "csv_sha256_fase0_rerun_"),
                                                         hoje, ".md")),
          file.path("artigo1_prematuridade/logs", paste0("sessionInfo_rerun_", hoje, ".txt")))
fora <- alvo[!alvo %in% livres]
confere("C7", sprintf("scripts, logs e configuração da Fase 0 que devem entrar no git (%d)", length(alvo)), "todos",
        if (length(fora)) paste("faltam:", paste(fora, collapse = "; ")) else "todos", length(fora) == 0)

# ---------------------------------------------------------------- C9 regras de todo script e log (achados 5, 6, 7 e 13 da auditoria independente)
scripts <- list.files("00_scripts", pattern = "\\.R$", full.names = TRUE)
regra <- vapply(scripts, function(f) {
  s <- readLines(f, encoding = "UTF-8")
  sum(grepl('stopifnot(versao() == "4443971b")', s, fixed = TRUE)) >= 2 && any(grepl("set.seed(20261001)", s, fixed = TRUE))
}, logical(1))
confere("C9", "todo script de 00_scripts/ confere versao() no início e no fim e fixa a semente", paste(length(scripts), "de", length(scripts)),
        paste(sum(regra), "de", length(scripts), if (!all(regra)) paste("; falham:", paste(basename(scripts[!regra]), collapse = ", ")) else ""),
        all(regra))
logs_gerados <- file.path("logs", paste0(c("entrada_fase0_rerun_", "ambiente_fase0_rerun_", "interface_fase0_rerun_", "recontagens_fase0_rerun_",
                                           "comparacao_a4_fase0_rerun_", "mm14_equivalente_fase0_rerun_", "populacao_dum_fase0_rerun_",
                                           "desvio9_fase0_rerun_", "csv_sha256_fase0_rerun_"), hoje, ".md"))
fim_ok <- vapply(logs_gerados, function(f) file.exists(f) && any(grepl("no fim", x <- readLines(f, encoding = "UTF-8"), fixed = TRUE) &
                                                                 grepl("4443971b", x, fixed = TRUE)), logical(1))
confere("C9", "logs gerados na rodada refeita registram a versao() do fim (4443971b)", paste(length(fim_ok), "de", length(fim_ok)),
        paste(sum(fim_ok), "de", length(fim_ok), if (!all(fim_ok)) paste("; faltam:", paste(basename(logs_gerados[!fim_ok]), collapse = ", ")) else ""),
        all(fim_ok))
rec <- readLines(file.path("logs", paste0("recontagens_fase0_rerun_", hoje, ".md")), encoding = "UTF-8")
neg0 <- sum(grepl("(^|[^0-9,.])-0,0+([^0-9]|$)", rec))
confere("C9", "\"-0,000\" no log da A5", 0, neg0, neg0 == 0)
itf <- readLines(file.path("logs", paste0("interface_fase0_rerun_", hoje, ".md")), encoding = "UTF-8")
dup <- sum(grepl("casa com [0-9]+ linhas", itf)); nenc <- sum(grepl("padrão não encontrado", itf, fixed = TRUE))
confere("C9", "padrões de evidência da interface que casam com mais de uma linha, ou com nenhuma (achado 7 da auditoria do plano)", "0 e 0",
        paste(dup, "e", nenc), dup == 0 && nenc == 0)
for (pasta in c(file.path("01_saidas", "fase0"), saida)) {
  csvs <- file.path("artigo1_prematuridade", pasta, list.files(pasta, pattern = "\\.csv$"))
  ign <- git("check-ignore", csvs)
  confere("C7", sprintf("CSV de %s ignorados pelo git", pasta), paste(length(csvs), "de", length(csvs)),
          paste(length(intersect(ign, csvs)), "de", length(csvs)), length(csvs) > 0 && setequal(ign, csvs))
}
commits <- git("rev-list", "--all", "--count")
confere("C7", "commits no repositório (Parte A não faz commit)", 0, commits[1], identical(commits[1], "0"))

# ---------------------------------------------------------------- C11 complemento da Fase 0A (itens 1, 2, 3, 5, 6 e 7)
sha256 <- function(f) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(f)), stdout = TRUE))
gi <- readLines(file.path(RAIZ, ".gitignore"))
att <- file.path(RAIZ, "codigo_compartilhado/inst/terceiros/attrdl.R")
origem <- readLines(file.path(RAIZ, "codigo_compartilhado/inst/terceiros/ORIGEM.md"), encoding = "UTF-8")
s_att <- sha256(att); h_att <- git("hash-object", "--no-filters", att)
confere("C11", "item 1: attrdl.R com 7.411 bytes, SHA-1 do blob bff2a939… e SHA-256 igual ao do ORIGEM.md",
        "7411; bff2a939…; no ORIGEM.md", sprintf("%d; %s; %s", file.size(att), substr(h_att, 1, 8), substr(s_att, 1, 8)),
        file.size(att) == 7411 && identical(h_att, "bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a") && any(grepl(s_att, origem, fixed = TRUE)))
ig_att <- git("check-ignore", "codigo_compartilhado/inst/terceiros/attrdl.R")
confere("C11", "item 1: attrdl.R ignorado; a regra inst/terceiros/*.R saiu do .gitignore; ORIGEM.md e baixa_attrdl.R entram", "sim",
        ifelse(length(ig_att) == 1 && !any(gi == "!/codigo_compartilhado/inst/terceiros/*.R"), "sim", "não"),
        length(ig_att) == 1 && !any(gi == "!/codigo_compartilhado/inst/terceiros/*.R") &&
          all(c("codigo_compartilhado/inst/terceiros/ORIGEM.md", "ferramentas/baixa_attrdl.R") %in% livres))
confere("C11", "item 1: ORIGEM.md registra nsim = 5000 (padrão) e nsim = 1000 (§7)", "sim",
        ifelse(any(grepl("nsim = 5000", origem, fixed = TRUE)) && any(grepl("nsim = 1000", origem, fixed = TRUE)), "sim", "não"),
        any(grepl("nsim = 5000", origem, fixed = TRUE)) && any(grepl("nsim = 1000", origem, fixed = TRUE)))
lk <- jsonlite::fromJSON("renv.lock", simplifyVector = FALSE)
url <- vapply(lk$R$Repositories, `[[`, "", "URL")
falso <- sum(grepl("127.0.0.1", readLines("renv.lock"), fixed = TRUE))
confere("C11", "item 2: repositórios do renv.lock (sem o endereço falso do hydrate)", "https://cloud.r-project.org; 0",
        paste0(paste(url, collapse = ", "), "; ", falso), identical(url, "https://cloud.r-project.org") && falso == 0)
cs <- readLines(file.path(RAIZ, "ferramentas/checa_sigilo.sh"))
pad_tok <- c("gh[pousr]_[A-Za-z0-9]{36}", "github_pat_[A-Za-z0-9_]{22,}",
             "(GITHUB_PAT|GITHUB_TOKEN|GH_TOKEN)[\"']?[[:space:]]*(=|:|<-)[[:space:]]*[\"']?[A-Za-z0-9_]{20,}",
             "BEGIN [A-Z ]*PRIVATE KEY")
no_script <- vapply(c("gh[pousr]_[A-Za-z0-9]{36}", "github_pat_[A-Za-z0-9_]{22,}",
                      "(GITHUB_PAT|GITHUB_TOKEN|GH_TOKEN)[\\\"']?[[:space:]]*(=|:|<-)[[:space:]]*[\\\"']?[A-Za-z0-9_]{20,}",
                      "BEGIN [A-Z ]*PRIVATE KEY"), function(p) any(grepl(p, cs, fixed = TRUE)), TRUE)
erro_ok <- any(grepl('if [ "$st" -gt 1 ]', cs, fixed = TRUE))
confere("C11", "item 3: checa_sigilo.sh usa git grep --cached com os 4 padrões (os mesmos desta conferência) e barra erro do git grep",
        "sim", ifelse(any(grepl("git grep --cached", cs, fixed = TRUE)) && all(no_script) && erro_ok, "sim", "não"),
        any(grepl("git grep --cached", cs, fixed = TRUE)) && all(no_script) && erro_ok)
com_tok <- livres[vapply(file.path(RAIZ, livres), function(f) {
  x <- tryCatch(readLines(f, warn = FALSE, encoding = "UTF-8"), error = function(e) character())
  any(vapply(pad_tok, function(p) any(grepl(p, x, useBytes = TRUE)), TRUE))
}, logical(1))]
confere("C11", "item 3: arquivos que o git aceitaria com token ou chave privada (mesmos padrões do hook)", 0,
        if (length(com_tok)) paste(com_tok, collapse = "; ") else 0, length(com_tok) == 0)
tab_sha <- readLines(file.path("logs", paste0("csv_sha256_fase0_rerun_", hoje, ".md")), encoding = "UTF-8")
sha_ok <- vapply(list.files(saida, pattern = "^[^.].*\\.csv$", full.names = TRUE), function(f)   # nome e SHA na mesma linha (sem os ._* do exFAT)
  any(grepl(sprintf("| `artigo1_prematuridade/01_saidas/fase0_rerun/%s` |", basename(f)), tab_sha, fixed = TRUE) &
      grepl(sprintf("`%s` |", sha256(f)), tab_sha, fixed = TRUE)),
  logical(1))
confere("C11", "A6: SHA-256 de cada CSV de 01_saidas/fase0_rerun igual ao do log da A6", paste(length(sha_ok), "de", length(sha_ok)),
        paste(sum(sha_ok), "de", length(sha_ok)), length(sha_ok) > 0 && all(sha_ok))
dv <- readLines("logs/desvios_especificacao.md", encoding = "UTF-8")
n_dv <- sort(as.integer(sub("^\\| ([0-9]+) \\|.*", "\\1", grep("^\\| [0-9]+ \\|", dv, value = TRUE))))
confere("C11", "desvios numerados de 1 a N, sem lacuna nem repetição", paste0("1–", max(n_dv)), paste(range(n_dv), collapse = "–"),
        identical(n_dv, seq_len(max(n_dv))) && max(n_dv) > 9)
pmin <- min(a52$perda[a52$perda > 0])
confere("C11", "item 6 (desvio 9): menor perda diferente de zero na A5.2, e perdas de 1 a 9", "40; 0",
        paste0(pmin, "; ", sum(a52$perda %in% 1:9)), pmin == 40 && sum(a52$perda %in% 1:9) == 0)
docs <- c("RESPOSTA_chat_A1_auditoria_20261008.md", "RESPOSTA_chat_A1_ajustes_20261008.md")
iguais <- vapply(docs, function(d) identical(sha256(file.path(RAIZ, "docs/coordenacao", d)), sha256(file.path(RAIZ, "logs/_entrada_chat", d))), TRUE)
ig_docs <- git("check-ignore", "docs/coordenacao/x.csv", "docs/coordenacao/sub/y.md", "docs/outro.md")
confere("C11", "item 7: docs/coordenacao com os 2 documentos idênticos aos de _entrada_chat; só *.md liberado", "2 de 2; 3 de 3 ignorados",
        sprintf("%d de 2; %d de 3 ignorados", sum(iguais), length(ig_docs)),
        all(iguais) && length(ig_docs) == 3 && any(gi == "!/docs/coordenacao/*.md"))

# ---------------------------------------------------------------- log
v_fim <- versao()
confere("C8", "versao() no início", "4443971b", v_ini, v_ini == "4443971b")
confere("C8", "versao() no fim", "4443971b", v_fim, v_fim == "4443971b")
md <- c("# Autoauditoria por código da Fase 0 refeita (base 4443971b): A5 refeita (A4 e A5 do prompt) e regras de script, log e git", "",
        sprintf("- **Gerado por:** `00_scripts/03_autoauditoria_fase0.R`, em %s. `versao()` no início = %s e no fim = %s.",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), v_ini, v_fim),
        "- **Método:** cada número da A5 é refeito por um caminho diferente do `02_recontagens_fase0.R` e comparado com os CSV de `01_saidas/fase0_rerun/`.",
        "  - **Contagens:** série municipal somada por concentração pelo `concentracoes()`.",
        "  - **Temperatura e PM2.5:** `diaria_recorte(var, \"nucleo\")`, o clima municipal da cidade-núcleo.",
        "  - **Semanas:** médias de 7 dias recalculadas da temperatura diária.",
        "  - **Janelas:** `seq()` de datas.",
        "  - **Git (C7):** o que entraria num `git add`. **Regras de script e log (C9):** conferências acrescentadas depois da auditoria independente.",
        "  - **MM14 e MM9 (C10):** refeitas dos dias e comparadas com o CSV da A5 (`08_mm14_equivalente_rerun.R`). **C11:** itens 1, 2, 3 e 7 do complemento, a A6 e a numeração do log de desvios.",
        sprintf("- **Tolerância numérica:** %s °C. Contagens: igualdade exata.", fmt(TOL)),
        sprintf("- **Resultado:** %d de %d conferências ok.", sum(res$ok), nrow(res)), "",
        "| Item | Conferência | Esperado | Obtido | Ok |", "|---|---|---|---|---|",
        sprintf("| %s | %s | %s | %s | %s |", res$item, res$conferencia, res$esperado, res$obtido, ifelse(res$ok, "sim", "**NÃO**")))
arq <- file.path("logs", paste0("autoauditoria_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq))   # nunca sobrescreve
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "\n")
print(res[, c("item", "conferencia", "obtido", "ok")], row.names = FALSE, right = FALSE)
stopifnot(versao() == "4443971b")
cat("versao() no fim:", versao(), "\n")
if (!all(res$ok)) quit(status = 1)
