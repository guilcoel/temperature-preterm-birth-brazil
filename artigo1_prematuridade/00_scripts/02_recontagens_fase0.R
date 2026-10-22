# 02_recontagens_fase0.R — Fase 0, A5: recontagens descritivas e percentis de exposição (pendência 10; §2.3, §3.3, §5).
#
# Linha vermelha: nenhum desfecho é cruzado com exposição. As contagens de eventos (A5.1, A5.2) não leem exposição;
# os percentis (A5.3, A5.4) e o PM2.5 (A5.5) leem só colunas de exposição.
# Sigilo: só agregados por concentração × janela inteira. Contagem de 1 a 9 = "<10", com supressão complementar
# na identidade total 2012–2024 = janela + perda.
#
# Grava (fora do git): 01_saidas/fase0_rerun/a5_*.csv.  Resumo (no git): logs/recontagens_fase0_rerun_<FASE0_RERUN_DATA>.md
# Fase 0 refeita (base 4443971b): mesmas contas da Fase 0A; só o hash, os caminhos de saída, a data fixa da rodada e a
# trava contra sobrescrita mudaram (os CSV e o log da Fase 0A, em 01_saidas/fase0/, são registro).
# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/02_recontagens_fase0.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
suppressPackageStartupMessages(library(dplyr))

saida <- file.path("01_saidas", "fase0_rerun")
dir.create(saida, recursive = TRUE, showWarnings = FALSE)
hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
write.csv <- function(x, file, ...) { stopifnot(!file.exists(file)); utils::write.csv(x, file, ...) }   # nunca sobrescreve
D <- as.Date
INI <- D("2012-01-01"); FIM <- D("2024-12-31")
P <- c(.01, .025, .05, .10, .25, .50, .75, .90, .95, .975, .99)

nuc <- as.data.frame(cidade_nucleo())
nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)

br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0                 # sem "-0,000"
  formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
masc <- function(n) ifelse(is.na(n), "NA", ifelse(n > 0 & n < 10, "<10", br(n)))
md <- character()
add <- function(...) md <<- c(md, ...)
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"),
                            paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))

# ---------------------------------------------------------------- A5.1 totais conhecidos (sem exposição)
cont <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE,
                                   colunas = c("recorte_principal", "data", "nv_unicos", "ptb", "obito_perinatal")))
cont$data <- as.Date(cont$data)
c12 <- cont[cont$data >= INI & cont$data <= FIM, ]
esperado <- c(nv_unicos = 13791848, ptb = 1405697, obito_perinatal = 180064)
a51 <- do.call(rbind, lapply(names(esperado), function(v) {
  na_dia <- tapply(is.na(c12[[v]]), c12$data, any)
  dias_na <- as.Date(names(na_dia)[na_dia])
  data.frame(coluna = v, soma = sum(c12[[v]], na.rm = TRUE), esperado = esperado[[v]],
             dias_com_NA = length(dias_na),
             datas_NA = if (length(dias_na)) paste(format(range(dias_na)), collapse = " a ") else "—")
}))
a51$confere <- a51$soma == a51$esperado
print(a51, row.names = FALSE)
write.csv(a51, file.path(saida, "a5_1_totais.csv"), row.names = FALSE)
if (!all(a51$confere)) { cat("TOTAL NÃO CONFERE: parar e reportar.\n"); quit(status = 1) }

# ---------------------------------------------------------------- A5.2 eventos por concentração nas janelas (sem exposição)
janelas <- data.frame(
  desfecho = c("ptb", "ptb", "obito_perinatal", "obito_perinatal"),
  janela = c("principal", "evento possível", "principal", "evento possível"),
  ini = D(c("2012-04-14", "2012-01-04", "2012-05-26", "2012-01-04")),
  fim = D(c("2024-08-06", "2024-11-15", "2024-08-06", "2024-12-24")), stringsAsFactors = FALSE)
janelas$dias <- as.integer(janelas$fim - janelas$ini) + 1L
a52 <- do.call(rbind, lapply(seq_len(nrow(janelas)), function(i) {
  j <- janelas[i, ]
  c12 %>% group_by(recorte_principal) %>%
    summarise(total_2012_2024 = sum(.data[[j$desfecho]], na.rm = TRUE),
              eventos_janela = sum(.data[[j$desfecho]][data >= j$ini & data <= j$fim], na.rm = TRUE),
              dias_com_valor_desfecho = sum(!is.na(.data[[j$desfecho]][data >= j$ini & data <= j$fim])), .groups = "drop") %>%
    mutate(desfecho = j$desfecho, janela = j$janela, ini = j$ini, fim = j$fim, dias_janela = j$dias)
})) %>% mutate(perda = total_2012_2024 - eventos_janela, perda_pct = 100 * perda / total_2012_2024,
               concentracao = nome[recorte_principal])
write.csv(a52, file.path(saida, "a5_2_eventos_janelas.csv"), row.names = FALSE)

# publicação: máscara + supressão complementar (total = janela + perda; se uma parte for 1–9, a outra sai suprimida)
pub52 <- a52 %>% mutate(
  peq_perda = perda > 0 & perda < 10, peq_jan = eventos_janela > 0 & eventos_janela < 10,
  Total = masc(total_2012_2024),
  Janela = ifelse(peq_perda, "supr.", masc(eventos_janela)),
  Perda = ifelse(peq_jan, "supr.", masc(perda)),
  `Perda %` = ifelse(peq_perda | peq_jan, "—", br(perda_pct, 2)),
  `Dias com valor do desfecho` = paste0(dias_com_valor_desfecho, "/", dias_janela))
supressoes <- sum(pub52$peq_perda | pub52$peq_jan)
# margens do resumo: se alguma concentração do grupo tiver parte suprimida ou total mascarado, a margem também sai
# suprimida, para a célula não ser recuperada por subtração da soma das outras
resumo52 <- a52 %>% group_by(desfecho, janela) %>%
  summarise(supr_partes = any((perda > 0 & perda < 10) | (eventos_janela > 0 & eventos_janela < 10)),
            supr_total = any(total_2012_2024 > 0 & total_2012_2024 < 10),
            total = sum(total_2012_2024), janela_ev = sum(eventos_janela), perda = sum(perda),
            perda_pct = 100 * sum(perda) / sum(total_2012_2024),
            minimo = min(eventos_janela), quem_min = concentracao[which.min(eventos_janela)],
            abaixo_1000 = paste(concentracao[eventos_janela < 1000], collapse = ", "),
            abaixo_2000 = paste(concentracao[eventos_janela < 2000], collapse = ", "), .groups = "drop")
print(as.data.frame(resumo52))
ptb_fora_evento <- sum(c12$ptb[c12$data < D("2012-01-04") | c12$data > D("2024-11-15")], na.rm = TRUE)
cat("PTB fora da janela de evento possível (2012–2024):", ptb_fora_evento, "\n")

# ---------------------------------------------------------------- A5.3 percentis da exposição diária (só clima)
ex <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE,
                                 colunas = c("recorte_principal", "data", "tmean_nucleo")))
ex$data <- as.Date(ex$data)
ex <- ex[ex$data >= INI & ex$data <= FIM, ]
if (anyNA(ex$tmean_nucleo)) { cat("NA na tmean_nucleo: parar e reportar.\n"); quit(status = 1) }
pct_tab <- function(df, rotulo) {
  df %>% group_by(recorte_principal) %>% group_modify(function(g, k) {
    q <- quantile(g$tmean_nucleo, P, type = 7, names = FALSE)
    data.frame(n_dias = nrow(g), n_NA = sum(is.na(g$tmean_nucleo)), media = mean(g$tmean_nucleo),
               minimo = min(g$tmean_nucleo), maximo = max(g$tmean_nucleo),
               t(setNames(q, paste0("p", c("1", "2,5", "5", "10", "25", "50", "75", "90", "95", "97,5", "99")))),
               amplitude_p99_p1 = q[11] - q[1], check.names = FALSE)
  }) %>% ungroup() %>% mutate(periodo = rotulo, concentracao = nome[recorte_principal])
}
a53 <- pct_tab(ex, "ano inteiro 2012–2024")
a53q <- pct_tab(ex[as.integer(format(ex$data, "%m")) %in% c(11, 12, 1, 2, 3), ], "novembro a março")
write.csv(rbind(a53, a53q), file.path(saida, "a5_3_percentis_diarios.csv"), row.names = FALSE)
cat("A5.3 dias por concentração: ano", paste(range(a53$n_dias), collapse = "–"), "| quente",
    paste(range(a53q$n_dias), collapse = "–"), "\n")

# ---------------------------------------------------------------- A5.4 exposição semanal e médias móveis (só clima)
es <- as.data.frame(expo_semanal("tmean", "nucleo"))
es$dum_est <- as.Date(es$dum_est)
es <- es[es$dum_est >= D("2011-04-17") & es$dum_est <= D("2024-03-05"), ]
sc <- sprintf("s%02d", 1:37)
if (anyNA(es[, sc])) { cat("NA na matriz semanal: parar e reportar.\n"); quit(status = 1) }
P4 <- c(.01, .10, .75, .90, .99)
a54 <- es %>% group_by(recorte_principal) %>% group_modify(function(g, k) {
  m <- as.matrix(g[, sc])
  emp <- as.vector(m)                                               # (i) empilhada, sem ponderação por pessoa
  ini <- rep(g$dum_est, times = 37) + rep(7L * (0:36), each = nrow(g))   # início de cada janela de 7 dias
  dist <- tapply(emp, ini, function(v) v[1])                        # (ii) cada janela de calendário uma vez
  difmax <- max(tapply(emp, ini, function(v) diff(range(v))))       # a mesma janela tem o mesmo valor?
  q1 <- quantile(emp, P4, type = 7, names = FALSE); q2 <- quantile(as.numeric(dist), P4, type = 7, names = FALSE)
  mm9 <- rowMeans(m[, sprintf("s%02d", 29:37)])
  t1 <- rowMeans(m[, sprintf("s%02d", 1:14)]); t2 <- rowMeans(m[, sprintf("s%02d", 15:28)])
  qm <- quantile(mm9, c(.01, .50, .99), type = 7, names = FALSE)
  F <- ecdf(emp)
  idx <- match(g$dum_est + 98L, g$dum_est); ok <- !is.na(idx)      # t2 de d deve ser t1 de d + 98 dias
  vezes <- table(ini)                                               # quantas vezes cada janela entra na (i)
  data.frame(n_dum_est = nrow(g), n_valores_i = length(emp), n_janelas_ii = length(dist),
             dif_max_mesma_janela = difmax, vezes_min = min(vezes), vezes_max = max(vezes),
             janela_ini_min = min(ini), janela_ini_max = max(ini),
             t(setNames(q1, paste0("i_p", c(1, 10, 75, 90, 99)))), t(setNames(q2, paste0("ii_p", c(1, 10, 75, 90, 99)))),
             t(setNames(q1 - q2, paste0("dif_p", c(1, 10, 75, 90, 99)))),
             mm9_p1 = qm[1], mm9_p50 = qm[2], mm9_p99 = qm[3],
             mm9_p99_em_pct_semanal_i = 100 * F(qm[3]), mm9_p1_em_pct_semanal_i = 100 * F(qm[1]),
             t1_p1 = quantile(t1, .01, type = 7, names = FALSE), t1_p99 = quantile(t1, .99, type = 7, names = FALSE),
             t2_p1 = quantile(t2, .01, type = 7, names = FALSE), t2_p99 = quantile(t2, .99, type = 7, names = FALSE),
             t2_menos_t1_desloc98 = max(abs(t2[ok] - t1[idx[ok]])))
}) %>% ungroup() %>% mutate(concentracao = nome[recorte_principal])
write.csv(a54, file.path(saida, "a5_4_semanal_mm.csv"), row.names = FALSE)
difs <- abs(as.matrix(a54[, grep("^dif_p", names(a54))]))
acima <- which(difs > 0.05, arr.ind = TRUE)
conc_acima <- unique(a54$concentracao[acima[, "row"]])
mm14_igual_p99 <- sum(abs(a54$t1_p99 - a54$t2_p99) < 1e-9); mm14_igual_p1 <- sum(abs(a54$t1_p1 - a54$t2_p1) < 1e-9)
cat("A5.4 maior |diferença (i) − (ii)| entre percentis:", max(difs), "°C |", nrow(acima), "pares acima de 0,05 em",
    length(conc_acima), "concentrações | maior diferença dentro da mesma janela:", max(a54$dif_max_mesma_janela), "\n")

# ---------------------------------------------------------------- A5.5 dias de modelo utilizáveis do PM2.5 (só exposição)
pm <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE,
                                 colunas = c("recorte_principal", "data", "pm25_local_zero_na_nucleo")))
pm$data <- as.Date(pm$data)
pm <- pm %>% arrange(recorte_principal, data) %>% group_by(recorte_principal) %>%
  mutate(consecutivo = c(TRUE, diff(data) == 1),
         ma01 = (pm25_local_zero_na_nucleo + lag(pm25_local_zero_na_nucleo)) / 2,
         util = !is.na(ma01)) %>% ungroup()
if (!all(pm$consecutivo)) { cat("Série do PM2.5 com data faltando: parar e reportar.\n"); quit(status = 1) }
pm_brutos <- pm %>% filter(data >= INI, data <= FIM) %>% group_by(recorte_principal) %>%
  summarise(dias_2012_2024 = n(), sem_valor_2012_2024 = sum(is.na(pm25_local_zero_na_nucleo)), .groups = "drop")
a55 <- do.call(rbind, lapply(which(janelas$janela == "principal"), function(i) {
  j <- janelas[i, ]
  pm %>% filter(data >= j$ini, data <= j$fim) %>% group_by(recorte_principal) %>%
    summarise(dias_janela = n(), sem_valor_janela = sum(is.na(pm25_local_zero_na_nucleo)),
              dias_utilizaveis = sum(util), .groups = "drop") %>% left_join(pm_brutos, by = "recorte_principal") %>%
    mutate(janela = paste0(j$desfecho, " principal (", j$ini, " a ", j$fim, ")"),
           pct = 100 * dias_utilizaveis / dias_janela, passa_90 = pct >= 90, concentracao = nome[recorte_principal])
}))
write.csv(a55, file.path(saida, "a5_5_pm25_dias_utilizaveis.csv"), row.names = FALSE)
cat("A5.5 não passam (≥ 90%):", paste(unique(a55$concentracao[!a55$passa_90]), collapse = ", "), "\n")

# ---------------------------------------------------------------- resumo em markdown (só agregados, mascarados)
add("# A5: recontagens descritivas e percentis de exposição (Fase 0)", "",
    sprintf("- **Gerado por:** `00_scripts/02_recontagens_fase0.R`, em %s. `versao()` no início = %s (o fim está na última linha).", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), v_ini),
    "- **Linha vermelha:** nenhum desfecho é cruzado com exposição. As contagens leem só colunas de desfecho; os percentis, só colunas de exposição.",
    "- **Sigilo:** só agregados por concentração × janela inteira. Contagem de 1 a 9 = \"<10\", com supressão complementar na identidade total = janela + perda.",
    sprintf("- **Supressões complementares aplicadas na A5.2:** %d.", supressoes),
    "- **Tabelas completas:** CSV em `01_saidas/fase0_rerun/`, fora do git.", "",
    "## A5.1 Totais conhecidos (série com coorte fixa, 2012-01-01 a 2024-12-31, 26 concentrações)", "",
    tabela_md(data.frame(Coluna = a51$coluna, Soma = br(a51$soma), Esperado = br(a51$esperado),
                         `Confere` = ifelse(a51$confere, "sim", "NÃO"), `Dias com NA` = a51$dias_com_NA,
                         `Datas com NA` = a51$datas_NA, check.names = FALSE)), "",
    "As somas usam `na.rm = TRUE`. Os dias com NA são os da censura neonatal de dezembro de 2024, só no `obito_perinatal`.", "",
    "## A5.2 Eventos por concentração nas janelas", "",
    "- **Dias com valor do desfecho:** dias da janela sem NA na coluna do desfecho, não dias de modelo.",
    "- **Janela de evento possível do perinatal:** a especificação (§3.2) usa só os dias com Z_t > 0. Essa restrição entra no modelo, na Fase 2, e não está aplicada aqui. Por construção da coorte fixa, não se espera evento em dia com Z_t = 0; a Fase 2 confere.", "")
for (dj in split(pub52, paste(pub52$desfecho, pub52$janela))) {
  j <- dj[1, ]
  add(sprintf("### %s, janela %s (%s a %s; %d dias)", j$desfecho, j$janela, j$ini, j$fim, j$dias_janela), "",
      tabela_md(data.frame(Concentração = dj$concentracao, `Total 2012–2024` = dj$Total, `Na janela` = dj$Janela,
                           Perda = dj$Perda, `Perda %` = dj$`Perda %`, `Dias com valor do desfecho` = dj$`Dias com valor do desfecho`,
                           check.names = FALSE)[order(-dj$total_2012_2024), ]), "")
}
s_p <- resumo52$supr_partes; s_t <- resumo52$supr_total
add("### Resumo da A5.2", "",
    tabela_md(data.frame(Desfecho = resumo52$desfecho, Janela = resumo52$janela, Total = ifelse(s_t, "supr.", br(resumo52$total)),
                         `Na janela` = ifelse(s_p | s_t, "supr.", br(resumo52$janela_ev)),
                         Perda = ifelse(s_p | s_t, "supr.", br(resumo52$perda)),
                         `Perda %` = ifelse(s_p | s_t, "—", br(resumo52$perda_pct, 2)),
                         Mínimo = paste0(masc(resumo52$minimo), " (", resumo52$quem_min, ")"),
                         `< 1.000` = ifelse(resumo52$abaixo_1000 == "", "nenhuma", resumo52$abaixo_1000),
                         `< 2.000` = ifelse(resumo52$abaixo_2000 == "", "nenhuma", resumo52$abaixo_2000), check.names = FALSE)), "",
    sprintf("- **PTB fora da janela de evento possível** (antes de 2012-01-04 ou depois de 2024-11-15), em 2012–2024: %s.", masc(ptb_fora_evento)),
    "- **Referência da especificação (§5 e 3ª auditoria, por simulação com concepções uniformes):** perda de cerca de 2,3% no PTB (2,26%) e 3,2% no perinatal (3,17%); perinatal na janela principal com Florianópolis em cerca de 1.418–1.420, Sorocaba 1.456 e Campo Grande 1.874.", "",
    "## A5.3 Percentis da `tmean_nucleo` diária (°C; `quantile(type = 7)`)", "")
renomeia <- function(df, nomes) { names(df) <- nomes; df }
for (tt in list(a53, a53q)) {
  x <- renomeia(as.data.frame(lapply(tt[, c("media", "minimo", "maximo", "p1", "p2,5", "p5", "p10", "p25", "p50", "p75",
                                            "p90", "p95", "p97,5", "p99", "amplitude_p99_p1")], br, d = 2)),
                c("Média", "Mín.", "Máx.", "p1", "p2,5", "p5", "p10", "p25", "p50", "p75", "p90", "p95", "p97,5", "p99", "p99 − p1"))
  add(sprintf("### %s (%s dias por concentração)", tt$periodo[1], paste(unique(tt$n_dias), collapse = "/")), "",
      tabela_md(cbind(Concentração = tt$concentracao, Dias = tt$n_dias, `Sem valor` = tt$n_NA, x)), "")
}
pc <- c(1, 10, 75, 90, 99)
x54 <- renomeia(as.data.frame(lapply(a54[, c(paste0("i_p", pc), paste0("ii_p", pc), paste0("dif_p", pc))], br, d = 3)),
                c(paste0("(i) p", pc), paste0("(ii) p", pc), paste0("dif. p", pc)))
D0 <- D("2011-04-17"); D1 <- D("2024-03-05")
pos99 <- a54$mm9_p99_em_pct_semanal_i; pos1 <- a54$mm9_p1_em_pct_semanal_i
add("## A5.4 Exposição semanal e médias móveis (`expo_semanal(\"tmean\", \"nucleo\")`, `dum_est` de 2011-04-17 a 2024-03-05)", "",
    "Leitura (i): todos os valores `s01`…`s37` empilhados, sem ponderação por pessoa. Leitura (ii): cada janela de 7 dias de calendário uma vez. Diferença = (i) − (ii), em °C.", "",
    tabela_md(cbind(Concentração = a54$concentracao, `dum_est` = a54$n_dum_est, `Janelas (ii)` = a54$n_janelas_ii, x54)), "",
    sprintf("- **Maior |diferença|:** %s °C. Pares concentração × percentil acima de 0,05 °C: %d de %d, em %d concentrações (%s).",
            br(max(difs), 3), nrow(acima), length(difs), length(conc_acima), paste(conc_acima, collapse = ", ")),
    if (nrow(acima)) "- **⚑ Sinalização:** a diferença passa de 0,05 °C. A regra da distribuição semanal (§1.2), leitura (i) ou (ii), tem de ser fixada pelo chat de métodos antes da tag." else "- **Sem sinalização:** nenhuma diferença passa de 0,05 °C.",
    sprintf("- **Por que diferem:** na leitura (i), cada janela entra tantas vezes quantos `dum_est` a contêm, de %d a %d vezes. Só as janelas que começam de %s a %s entram 37 vezes; as das pontas (começo de %s a %s e de %s a %s) entram menos. A (ii) dá peso igual às %s janelas.",
            min(a54$vezes_min), max(a54$vezes_max), format(D0 + 252), format(D1), format(min(a54$janela_ini_min)), format(D0 + 251),
            format(D1 + 1), format(max(a54$janela_ini_max)), br(a54$n_janelas_ii[1])),
    sprintf("- **Consistência:** a mesma janela de calendário tem o mesmo valor em todas as linhas (maior diferença: %s °C).", format(max(a54$dif_max_mesma_janela))), "",
    "### MM9 (`s29`…`s37`) e MM14 (1º trimestre `s01`…`s14`; 2º trimestre `s15`…`s28`), em °C", "",
    tabela_md(cbind(Concentração = a54$concentracao,
                    renomeia(as.data.frame(lapply(a54[, c("mm9_p1", "mm9_p50", "mm9_p99", "t1_p1", "t1_p99", "t2_p1", "t2_p99")], br, d = 2)),
                             c("MM9 p1", "MM9 p50", "MM9 p99", "1º tri p1", "1º tri p99", "2º tri p1", "2º tri p99")),
                    `p99 da MM9 = percentil semanal (i)` = br(pos99, 1),
                    `p1 da MM9 = percentil semanal (i)` = br(pos1, 1))), "",
    sprintf("- **Percentil semanal (i) equivalente ao p99 da MM9:** média p%s, de p%s a p%s. **Ao p1 da MM9:** média p%s, de p%s a p%s.",
            br(mean(pos99), 1), br(min(pos99), 1), br(max(pos99), 1), br(mean(pos1), 1), br(min(pos1), 1), br(max(pos1), 1)),
    "- **Referência da especificação (§3.3, por simulação):** p99 da MM9 perto do p93–94 (cerca de p89 a p99); p1 perto do p6 (p3,1 a p9,1).",
    sprintf("- **MM14:** o p99 é igual nos dois trimestres em %d de 26 concentrações, e o p1 em %d. É resultado observado, não garantido. A MM14 do 2º trimestre de um `dum_est` é a do 1º trimestre do `dum_est` 98 dias depois (maior diferença conferida: %s °C), então as duas distribuições só diferem nas pontas. O percentil coincide quando os valores das pontas não alcançam a cauda.",
            mm14_igual_p99, mm14_igual_p1, format(max(a54$t2_menos_t1_desloc98))), "",
    "## A5.5 Dias de modelo utilizáveis do `pm25_local_zero_na_nucleo` (média móvel de lag 0–1)", "",
    tabela_md(data.frame(Concentração = a55$concentracao, Janela = a55$janela, Dias = a55$dias_janela,
                         `Sem valor (brutos)` = a55$sem_valor_janela, Utilizáveis = a55$dias_utilizaveis, `%` = br(a55$pct, 2),
                         `≥ 90%` = ifelse(a55$passa_90, "passa", "NÃO passa"),
                         `Sem valor em 2012–2024` = paste0(a55$sem_valor_2012_2024, "/", a55$dias_2012_2024),
                         check.names = FALSE)[order(a55$janela, a55$pct), ]), "",
    sprintf("- **Não passam (≥ 90%%):** %s.", ifelse(any(!a55$passa_90), paste(unique(a55$concentracao[!a55$passa_90]), collapse = ", "), "nenhuma")),
    sprintf("- **Conferência com a §2.3:** Campo Grande tem %d/%d dias sem valor em 2012–2024; a especificação cita 361/4.749.",
            pm_brutos$sem_valor_2012_2024[nome[pm_brutos$recorte_principal] == "Campo Grande"],
            pm_brutos$dias_2012_2024[nome[pm_brutos$recorte_principal] == "Campo Grande"]))
stopifnot(versao() == "4443971b")
cat("versao() no fim:", versao(), "\n")
add("", sprintf("`versao()` no fim: %s.", versao()))
arq <- file.path("logs", paste0("recontagens_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "\n")
