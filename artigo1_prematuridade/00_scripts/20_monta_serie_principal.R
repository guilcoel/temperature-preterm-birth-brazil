# 20_monta_serie_principal.R — Fase 1, A2: série principal do PTB por concentração × dia, com offset, exposições e
# calendário (especificação v2.0.2, §1, §3.1 e §4; decisões de 08/10/2026, Revisão 2 final). Nenhum modelo.
# - Período gravado: 2011-12-14 a 2024-11-15 (início da janela de evento possível − 21 dias de aquecimento, até o fim
#   dela). Colunas lógicas janela_principal (2012-04-14 a 2024-08-06) e janela_evento_possivel (2012-01-04 a 2024-11-15).
# - w_j por concentração: calcula_wj() sobre os NV com unico, ga_sem 22–42 e coorte_fixa_22 (o mesmo que pop_ptb &
#   coorte_fixa_22, conferido), no período inteiro da coorte, j de 22 a 36.
# - Offset: monta_offset() com o Z_tj (z_nv, semanas 22–36) de cada concentração, o w_j dela e periodo = janela de evento
#   possível. O gestacoes_em_risco começa em 2012-01-01; de 2011-12-14 a 2011-12-31, Z_t = 0 (nenhuma gestação da coorte
#   fixa chega à semana 22 antes de 2012-01-01), com w_t e offset NA (desvio 48). De 2012-01-01 a 01-03, offset NA.
# - Referências de exposição: tmean_nucleo diária de 2012-01-01 a 2024-12-31 (ano inteiro e novembro a março),
#   comparadas com a A5.3 refeita; para se alguma diferença passar de 1e-12.
# Grava (fora do git) 01_saidas/fase1/serie_ptb_principal.rds, wj_ptb_concentracao.csv e referencias_exposicao.csv, e o
# log logs/serie_principal_fase1_<FASE1_DATA>.md (esquema = contrato de entrada do ajusta_dlnm()). Nunca sobrescreve.
# Sigilo: o log traz só esquema, contagens de linhas e agregados por concentração × período; nenhuma série diária.
# Uso (de artigo1_prematuridade/):  FASE1_DATA=AAAAMMDD Rscript 00_scripts/20_monta_serie_principal.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE1_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
source(file.path("..", "codigo_compartilhado", "R", "offset.R"))
saida <- file.path("01_saidas", "fase1"); dir.create(saida, recursive = TRUE, showWarnings = FALSE)
rds_out <- file.path(saida, "serie_ptb_principal.rds"); wj_out <- file.path(saida, "wj_ptb_concentracao.csv")
ref_out <- file.path(saida, "referencias_exposicao.csv")
arq <- file.path("logs", paste0("serie_principal_fase1_", hoje, ".md"))
for (p in c(rds_out, wj_out, ref_out, arq)) stopifnot(!file.exists(p))
D <- as.Date
GRAV <- D(c("2011-12-14", "2024-11-15")); JP <- D(c("2012-04-14", "2024-08-06")); JE <- D(c("2012-01-04", "2024-11-15"))
REF <- D(c("2012-01-01", "2024-12-31")); SEM <- 22:36
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
nuc <- as.data.frame(cidade_nucleo()); nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
conc <- as.data.frame(concentracoes())[, c("CD_MUN6", "CD_RECORTE")]

# ------------------------------------------------------------------ série diária (contagens e exposições)
log_msg("lendo serie_diaria(recorte)")
col_s <- c("recorte_principal", "data", "ptb", "ptb_extremo", "ptb_muito", "ptb_moderado_tardio", "nv_unicos",
           "tmean_nucleo", "tmean_rm_nv", "rh_nucleo", "pm25_local_nucleo", "pm25_local_zero_na_nucleo")
s_all <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = col_s)); s_all$data <- D(s_all$data)
s <- s_all[s_all$data >= GRAV[1] & s_all$data <= GRAV[2], ]
n_dias_grav <- as.integer(GRAV[2] - GRAV[1]) + 1L
stopifnot(length(unique(s$recorte_principal)) == 26, nrow(s) == 26 * n_dias_grav,
          !anyDuplicated(s[, c("recorte_principal", "data")]))

# ------------------------------------------------------------------ calendário (da base, por data)
cal <- as.data.frame(calendario()); cal$data <- D(cal$data)
cal <- cal[, c("data", "ano", "mes", "dia_semana", "feriado_nacional", "carnaval", "quarta_cinzas", "sexta_paixao", "corpus_christi")]
s <- merge(s, cal, by = "data", all.x = TRUE, sort = FALSE)
stopifnot(!anyNA(s$dia_semana), nrow(s) == 26 * n_dias_grav)
s$dia_semana <- factor(s$dia_semana, levels = 1:7, labels = c("seg", "ter", "qua", "qui", "sex", "sab", "dom"))
s$moveis <- as.integer(s$quarta_cinzas == 1 | s$sexta_paixao == 1 | s$corpus_christi == 1)
s$feriado_nacional <- as.integer(s$feriado_nacional); s$carnaval <- as.integer(s$carnaval)
s$ano <- as.integer(s$ano); s$mes <- as.integer(s$mes)
s$estrato <- paste(s$recorte_principal, s$ano, sprintf("%02d", s$mes), sep = "_")
s$janela_principal <- s$data >= JP[1] & s$data <= JP[2]
s$janela_evento_possivel <- s$data >= JE[1] & s$data <= JE[2]

# ------------------------------------------------------------------ w_j por concentração
log_msg("lendo nascimentos() para o w_j")
n <- as.data.frame(nascimentos(c("CD_MUN6", "unico", "ga_sem", "coorte_fixa_22", "pop_ptb")))
n$recorte_principal <- conc$CD_RECORTE[match(n$CD_MUN6, conc$CD_MUN6)]
stopifnot(!anyNA(n$recorte_principal))
pop <- n$unico %in% TRUE & !is.na(n$ga_sem) & n$ga_sem >= 22 & n$ga_sem <= 42 & n$coorte_fixa_22 %in% TRUE
igual_pop_ptb <- identical(pop, n$pop_ptb %in% TRUE & n$coorte_fixa_22 %in% TRUE)
stopifnot(igual_pop_ptb)
n_pop <- sum(pop)
wj <- do.call(rbind, lapply(sort(unique(n$recorte_principal[pop])), function(r) {
  w <- calcula_wj(n$ga_sem[pop & n$recorte_principal == r], SEM); data.frame(recorte_principal = r, w, stringsAsFactors = FALSE)
}))
stopifnot(nrow(wj) == 26 * length(SEM))
wj$concentracao <- nome[wj$recorte_principal]
write.csv(wj, wj_out, row.names = FALSE)
rm(n); invisible(gc())

# ------------------------------------------------------------------ Z_tj e offset
log_msg("lendo gestacoes_em_risco(recorte)")
z <- as.data.frame(gestacoes_em_risco(nivel = "recorte")); z$data <- D(z$data)
z <- z[z$data <= GRAV[2], c("recorte_principal", "data", "semana", "z_nv")]; names(z)[4] <- "z"
z_ini <- min(z$data); stopifnot(z_ini == D("2012-01-01"))
d11 <- seq(GRAV[1], z_ini - 1, by = "day")                         # 2011-12-14 a 31: Z_t = 0 (desvio 48)
recs <- sort(unique(s$recorte_principal))
z <- rbind(z, data.frame(recorte_principal = rep(recs, each = length(d11)), data = rep(d11, times = length(recs)),
                         semana = 22L, z = 0L, stringsAsFactors = FALSE))
off <- do.call(rbind, lapply(sort(unique(s$recorte_principal)), function(r) {
  o <- monta_offset(z[z$recorte_principal == r, c("data", "semana", "z")], wj[wj$recorte_principal == r, c("j", "w_j")],
                    SEM, periodo = JE)
  data.frame(recorte_principal = r, o, stringsAsFactors = FALSE)
}))
s <- merge(s, off, by = c("recorte_principal", "data"), all.x = TRUE, sort = FALSE)
stopifnot(nrow(s) == 26 * n_dias_grav)

# ------------------------------------------------------------------ conjunto analítico (contrato do ajusta_dlnm)
col_final <- c("recorte_principal", "data",
               "ptb", "ptb_extremo", "ptb_muito", "ptb_moderado_tardio", "nv_unicos",
               "z_t", "w_t", "log_z", "log_w", "log_zw", "z_t_zero",
               "tmean_nucleo", "tmean_rm_nv", "rh_nucleo", "pm25_local_nucleo", "pm25_local_zero_na_nucleo",
               "dia_semana", "feriado_nacional", "carnaval", "moveis",
               "ano", "mes", "estrato", "janela_principal", "janela_evento_possivel")
serie <- s[order(s$recorte_principal, s$data), col_final]; rownames(serie) <- NULL
# conferências antes de gravar (as completas ficam no 23); cada NA declarado no log é conferido aqui
stopifnot(!anyNA(serie$log_zw[serie$janela_evento_possivel]), all(serie$z_t[serie$janela_evento_possivel] > 0),
          all(is.na(serie$log_zw[!serie$janela_evento_possivel])), !anyNA(serie$tmean_nucleo), !anyNA(serie$z_t), !anyNA(serie$z_t_zero))
e11 <- serie$data < z_ini; e0103 <- serie$data >= z_ini & serie$data < JE[1]
cont <- c("ptb", "ptb_extremo", "ptb_muito", "ptb_moderado_tardio", "nv_unicos")
stopifnot(all(is.na(as.matrix(serie[e11, cont]))), !anyNA(serie[!e11, cont]),                       # contagens NA só em 2011
          all(serie$z_t[e11] == 0), all(serie$z_t_zero[e11]), all(is.na(serie$w_t[e11])),          # Z_t = 0 em 2011
          all(serie$z_t[e0103] > 0), !anyNA(serie$w_t[e0103]), all(is.na(serie$log_zw[e0103])))    # 2012-01-01 a 03
saveRDS(serie, rds_out)
log_msg("gravado", rds_out)

# ------------------------------------------------------------------ referências de exposição (só exposição)
ex <- s_all[s_all$data >= REF[1] & s_all$data <= REF[2], c("recorte_principal", "data", "tmean_nucleo")]
stopifnot(!anyNA(ex$tmean_nucleo))
P <- c(.01, .10, .50, .75, .90, .99)
ref_tab <- function(df, rotulo) do.call(rbind, lapply(sort(unique(df$recorte_principal)), function(r) {
  x <- df$tmean_nucleo[df$recorte_principal == r]; q <- quantile(x, P, type = 7, names = FALSE)
  data.frame(recorte_principal = r, periodo = rotulo, n_dias = length(x), p1 = q[1], p10 = q[2], p50 = q[3],
             p75 = q[4], p90 = q[5], p99 = q[6], media = mean(x), amplitude_p99_p1 = q[6] - q[1], stringsAsFactors = FALSE)
}))
mes_ex <- as.integer(format(ex$data, "%m"))
ref <- rbind(ref_tab(ex, "ano inteiro 2012–2024"), ref_tab(ex[mes_ex %in% c(11, 12, 1, 2, 3), ], "novembro a março"))
ref$concentracao <- nome[ref$recorte_principal]
a53 <- read.csv(file.path("01_saidas", "fase0_rerun", "a5_3_percentis_diarios.csv"), stringsAsFactors = FALSE,
                colClasses = c(recorte_principal = "character"), check.names = FALSE, fileEncoding = "UTF-8")
i53 <- match(paste(ref$recorte_principal, ref$periodo), paste(a53$recorte_principal, a53$periodo))
stopifnot(!anyNA(i53), nrow(ref) == 52)
comp <- c(n_dias = "n_dias", p1 = "p1", p10 = "p10", p50 = "p50", p75 = "p75", p90 = "p90", p99 = "p99", media = "media",
          amplitude_p99_p1 = "amplitude_p99_p1")
stopifnot(all(unname(comp) %in% names(a53)), all(names(comp) %in% names(ref)))     # coluna ausente não pode passar calada
dif_ref <- vapply(names(comp), function(k) {
  a <- as.numeric(a53[[comp[[k]]]][i53]); stopifnot(length(a) == nrow(ref), !anyNA(a), !anyNA(ref[[k]]))
  max(abs(ref[[k]] - a))
}, numeric(1))
ok_ref <- all(dif_ref <= 1e-12)
if (!ok_ref) { print(dif_ref); stop("referências diferem da A5.3 refeita em mais de 1e-12: parar") }
write.csv(ref, ref_out, row.names = FALSE)

# ------------------------------------------------------------------ log
tipo <- function(x) if (is.factor(x)) paste0("factor (", paste(levels(x), collapse = ", "), ")") else class(x)[1]
desc <- c(recorte_principal = "concentração (código IBGE de 7 dígitos)", data = "dia",
          ptb = "PTB (22–36 semanas), coorte fixa 22", ptb_extremo = "≤ 27 semanas", ptb_muito = "28–31 semanas",
          ptb_moderado_tardio = "32–36 semanas", nv_unicos = "NV únicos 22–42, coorte fixa 22",
          z_t = "Σ_{j=22}^{36} z_nv", w_t = "Σ_j Z_tj·w_j / Z_t", log_z = "log(Z_t); offset", log_w = "log(W_t); termo γ·log(W_t)",
          log_zw = "log(Σ_j Z_tj·w_j) = offset com γ = 1", z_t_zero = "Z_t = 0 (TRUE de 2011-12-14 a 2011-12-31)",
          tmean_nucleo = "exposição principal (°C)", tmean_rm_nv = "sensibilidade de nível (°C)", rh_nucleo = "umidade relativa (%)",
          pm25_local_nucleo = "PM2.5 local, variante principal (µg/m³)", pm25_local_zero_na_nucleo = "PM2.5 local, zero = NA (variante secundária)",
          dia_semana = "dia da semana (calendario())", feriado_nacional = "feriado nacional por lei federal (0/1)",
          carnaval = "segunda e terça de carnaval (0/1)", moveis = "quarta de cinzas, sexta da paixão ou corpus christi (0/1)",
          ano = "ano (calendario())", mes = "mês (calendario())", estrato = "concentração_ano_mês (eliminate do gnm)",
          janela_principal = "2012-04-14 a 2024-08-06", janela_evento_possivel = "2012-01-04 a 2024-11-15")
esquema <- data.frame(`#` = seq_along(col_final), Coluna = paste0("`", col_final, "`"),
                      Tipo = vapply(serie[col_final], tipo, ""), Conteúdo = unname(desc[col_final]), check.names = FALSE)
n_lt10 <- sum(wj$n_j < 10)
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
md <- c("# Fase 1, A2: série principal do PTB por concentração (`serie_ptb_principal.rds`)", "",
        sprintf("- **Gerado por:** `00_scripts/20_monta_serie_principal.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        "- **Fontes:** `serie_diaria(nivel = \"recorte\", coorte_fixa = TRUE)`; `gestacoes_em_risco(nivel = \"recorte\")` (`z_nv`, semanas 22–36); `calendario()`, por `data`; `nascimentos()` só para o w_j.",
        sprintf("- **Período gravado:** 2011-12-14 a 2024-11-15, %s dias × 26 concentrações = %s linhas. A janela principal tem %s dias por concentração.",
                br(n_dias_grav), br(nrow(serie)), br(sum(serie$janela_principal) / 26)),
        sprintf("- **w_j:** `calcula_wj()` por concentração, j de 22 a 36, sobre os NV com `unico`, `ga_sem` 22–42 e `coorte_fixa_22`. A população é idêntica a `pop_ptb & coorte_fixa_22` (conferido linha a linha: %s); são %s NV nas 26 concentrações somadas. Pares concentração × semana com n_j < 10: %d. O w_j por concentração fica só em `01_saidas/fase1/wj_ptb_concentracao.csv`; o resumo publicável está na A6 (`conferencias_fase1_%s.md`).",
                if (igual_pop_ptb) "sim" else "NÃO", br(n_pop), n_lt10, hoje),
        sprintf("- **Offset:** `monta_offset()` por concentração, com `periodo` = janela de evento possível (2012-01-04 a 2024-11-15). Rodou sem erro nas 26, ou seja, Z_t > 0 em todos os dias dessa janela. O `gestacoes_em_risco` começa em %s. De 2011-12-14 a 2011-12-31, `z_t` = 0 e `z_t_zero` = TRUE, com `w_t` e offset NA: pela coorte fixa (s ≥ 2011-07-31), nenhuma gestação chega à semana 22 antes de 2012-01-01 (desvio 48). De 2012-01-01 a 2012-01-03, `z_t` e `w_t` são calculados e o offset é NA (fora da janela de evento possível). Conferido por código antes de gravar.", format(z_ini)),
        "- **NA de propósito, fora de qualquer dia de modelo:** a base grava como NA, em 2011, as contagens que dependem de IG. Por isso `ptb`, os subtipos e `nv_unicos` são NA de 2011-12-14 a 2011-12-31 (dias que só servem de aquecimento da exposição), e só nesses dias (conferido por código antes de gravar).",
        sprintf("- **Referências de exposição** (`01_saidas/fase1/referencias_exposicao.csv`): `tmean_nucleo` diária de 2012-01-01 a 2024-12-31, `quantile(type = 7)`, ano inteiro e novembro a março (52 linhas). Comparação com a A5.3 refeita (`01_saidas/fase0_rerun/a5_3_percentis_diarios.csv`), coluna a coluna (as 9 colunas existem nos dois arquivos, sem NA; tolerância 1e-12): %s. Resultado: %s.",
                paste(sprintf("%s %s", names(dif_ref), format(dif_ref)), collapse = "; "), if (ok_ref) "igual" else "DIFERENTE"),
        "- **Arquivos gravados (fora do git), SHA-256:**",
        sprintf("  - `01_saidas/fase1/serie_ptb_principal.rds`: `%s`;", sha(rds_out)),
        sprintf("  - `01_saidas/fase1/wj_ptb_concentracao.csv`: `%s`;", sha(wj_out)),
        sprintf("  - `01_saidas/fase1/referencias_exposicao.csv`: `%s`.", sha(ref_out)), "",
        "## Esquema do conjunto analítico principal (contrato de entrada do `ajusta_dlnm()`)", "",
        "Uma linha por `recorte_principal` × `data`, ordenada por concentração e data.", "",
        tabela_md(esquema), "",
        "## A5: o que fica para a Fase 4 (não montado nesta fase)", "",
        "- a §3.5 redefinida (decisões §12, versões (i) e (ii), com coorte fixa e Z_t próprios);",
        "- o termo precoce (desvio 4): a janela vai até 2024-11-19, depois do fim do período gravado, e usa Z nas semanas 37–38; a Fase 4 extrai de novo;",
        "- Tmax, Tmin e temperatura aparente (§1.1 e §10.2), de `clima_municipal()`;",
        "- `z_fetal` em Z;",
        "- w_j por ano;",
        "- 2011 por `GESTACAO`;",
        "- os feriados locais.", "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "\n")
