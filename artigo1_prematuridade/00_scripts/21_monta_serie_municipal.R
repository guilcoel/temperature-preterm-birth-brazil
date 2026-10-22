# 21_monta_serie_municipal.R — Fase 1, A3: conjunto da case time series municipal do PTB (sensibilidade-chave 1;
# especificação v2.0.2, §1.1 e §3.1). Nenhum modelo.
# - Fontes: serie_diaria(nivel = "municipio", coorte_fixa = TRUE) (ptb, tmean_mun, tmean_nucleo);
#   gestacoes_em_risco(nivel = "municipio") (z_nv, semanas 22–36); calendario().
# - Offset: w_j da concentração (A2, 01_saidas/fase1/wj_ptb_concentracao.csv) aplicado ao Z_tj municipal, com
#   monta_offset(..., periodo = NULL). O gestacoes_em_risco é esparso (só células com z_nv ou z_fetal > 0): os
#   dias-município sem célula nas semanas 22–36 entram com Z = 0 na grade completa de 2011-12-14 a 2024-11-15 (desvios 44 e 48) e saem
#   marcados em z_t_zero, com offset NA; antes de 2012-01-01, Z_t = 0 pela coorte fixa.
# - Período gravado: 2011-12-14 a 2024-11-15, todos os dias de cada município, sem lacuna (a crossbasis com
#   group = CD_MUN6 precisa da série consecutiva). linha_modelo = (Z_t > 0) e dia na janela principal.
# - Nós: p10, p75 e p90 da tmean_mun de 2012-01-01 a 2024-12-31, com os municípios da concentração agrupados.
# Grava (fora do git) 01_saidas/fase1/serie_ptb_municipal.rds e nos_tmean_mun_concentracao.csv, e o log
# logs/serie_municipal_fase1_<FASE1_DATA>.md. Nunca sobrescreve. Depende do 20 (w_j).
# Sigilo: o log traz só esquema e contagens agregadas; nenhuma linha município × dia.
# Uso (de artigo1_prematuridade/):  FASE1_DATA=AAAAMMDD Rscript 00_scripts/21_monta_serie_municipal.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE1_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
source(file.path("..", "codigo_compartilhado", "R", "offset.R"))
saida <- file.path("01_saidas", "fase1"); stopifnot(dir.exists(saida))
wj_in <- file.path(saida, "wj_ptb_concentracao.csv"); stopifnot(file.exists(wj_in))
rds_out <- file.path(saida, "serie_ptb_municipal.rds"); nos_out <- file.path(saida, "nos_tmean_mun_concentracao.csv")
arq <- file.path("logs", paste0("serie_municipal_fase1_", hoje, ".md"))
for (p in c(rds_out, nos_out, arq)) stopifnot(!file.exists(p))
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

# ------------------------------------------------------------------ série municipal
log_msg("lendo serie_diaria(municipio)")
m_all <- as.data.frame(serie_diaria(nivel = "municipio", coorte_fixa = TRUE,
                                    colunas = c("CD_MUN6", "recorte_principal", "data", "ptb", "tmean_mun", "tmean_nucleo")))
m_all$data <- D(m_all$data)
m <- m_all[m_all$data >= GRAV[1] & m_all$data <= GRAV[2], ]
n_dias_grav <- as.integer(GRAV[2] - GRAV[1]) + 1L
n_mun <- length(unique(m$CD_MUN6))
stopifnot(n_mun == 277, nrow(m) == n_mun * n_dias_grav, !anyDuplicated(m[, c("CD_MUN6", "data")]),
          identical(unname(m$recorte_principal), conc$CD_RECORTE[match(m$CD_MUN6, conc$CD_MUN6)]))
cal <- as.data.frame(calendario()); cal$data <- D(cal$data)
cal <- cal[, c("data", "ano", "mes", "dia_semana", "feriado_nacional", "carnaval", "quarta_cinzas", "sexta_paixao", "corpus_christi")]
m <- merge(m, cal, by = "data", all.x = TRUE, sort = FALSE)
stopifnot(!anyNA(m$dia_semana))
m$dia_semana <- factor(m$dia_semana, levels = 1:7, labels = c("seg", "ter", "qua", "qui", "sex", "sab", "dom"))
m$moveis <- as.integer(m$quarta_cinzas == 1 | m$sexta_paixao == 1 | m$corpus_christi == 1)
m$feriado_nacional <- as.integer(m$feriado_nacional); m$carnaval <- as.integer(m$carnaval)
m$ano <- as.integer(m$ano); m$mes <- as.integer(m$mes)
m$estrato_mun <- paste(m$CD_MUN6, m$ano, sprintf("%02d", m$mes), sep = "_")
m$janela_principal <- m$data >= JP[1] & m$data <= JP[2]
m$janela_evento_possivel <- m$data >= JE[1] & m$data <= JE[2]

# ------------------------------------------------------------------ Z_tj municipal (esparso → grade completa) e offset
log_msg("lendo gestacoes_em_risco(municipio)")
z <- as.data.frame(gestacoes_em_risco(nivel = "municipio")); z$data <- D(z$data)
z <- z[z$data <= GRAV[2] & z$semana %in% SEM, c("CD_MUN6", "data", "semana", "z_nv")]; names(z)[4] <- "z"
z_ini <- D("2012-01-01"); stopifnot(min(z$data) >= z_ini)
dias_z <- seq(GRAV[1], GRAV[2], by = "day")                        # grade completa do período gravado (desvio 48)
grade <- expand.grid(CD_MUN6 = sort(unique(m$CD_MUN6)), data = dias_z, stringsAsFactors = FALSE)
k_z <- paste(z$CD_MUN6, as.integer(z$data)); k_g <- paste(grade$CD_MUN6, as.integer(grade$data))
falta <- grade[!(k_g %in% k_z), ]
n_zero_2011 <- sum(falta$data < z_ini); n_sem_celula <- sum(falta$data >= z_ini)   # antes da grade da base; sem célula
stopifnot(n_zero_2011 == n_mun * as.integer(z_ini - GRAV[1]))
n_zero_fill <- nrow(falta)
if (n_zero_fill > 0) z <- rbind(z, data.frame(CD_MUN6 = falta$CD_MUN6, data = falta$data, semana = 22L, z = 0L))
z$recorte_principal <- conc$CD_RECORTE[match(z$CD_MUN6, conc$CD_MUN6)]; stopifnot(!anyNA(z$recorte_principal))
wj <- read.csv(wj_in, stringsAsFactors = FALSE, colClasses = c(recorte_principal = "character"), fileEncoding = "UTF-8")
stopifnot(nrow(wj) == 26 * length(SEM))
log_msg("monta_offset por concentração")
off <- do.call(rbind, lapply(sort(unique(z$recorte_principal)), function(r) {
  monta_offset(z[z$recorte_principal == r, c("CD_MUN6", "data", "semana", "z")], wj[wj$recorte_principal == r, c("j", "w_j")],
               SEM, periodo = NULL)
}))
rm(z, grade, falta, k_z, k_g); invisible(gc())
stopifnot(nrow(off) == n_mun * length(dias_z))
m <- merge(m, off, by = c("CD_MUN6", "data"), all.x = TRUE, sort = FALSE)
m$linha_modelo <- m$janela_principal & !is.na(m$z_t) & m$z_t > 0

col_final <- c("CD_MUN6", "recorte_principal", "data", "ptb",
               "z_t", "w_t", "log_z", "log_w", "log_zw", "z_t_zero",
               "tmean_mun", "tmean_nucleo",
               "dia_semana", "feriado_nacional", "carnaval", "moveis",
               "ano", "mes", "estrato_mun", "janela_principal", "janela_evento_possivel", "linha_modelo")
serie <- m[order(m$recorte_principal, m$CD_MUN6, m$data), col_final]; rownames(serie) <- NULL
dz <- serie$data >= z_ini
stopifnot(nrow(serie) == n_mun * n_dias_grav, !anyNA(serie$z_t), !anyNA(serie$z_t_zero), all(serie$z_t[!dz] == 0),
          identical(is.na(serie$log_zw), serie$z_t == 0), !anyNA(serie$tmean_mun), !anyNA(serie$tmean_nucleo),
          all(is.na(serie$ptb[!dz])), !anyNA(serie$ptb[dz]))                    # ptb NA só em 2011 (base)
so_fetal <- sum(serie$z_t_zero[dz]) - n_sem_celula                  # dias com célula só por z_fetal (z_nv = 0)
stopifnot(so_fetal >= 0)
txt_fetal <- if (so_fetal == 0) "nenhum dia-município" else if (so_fetal < 10) "<10 dias-município" else paste(br(so_fetal), "dias-município")
saveRDS(serie, rds_out)
log_msg("gravado", rds_out)

# ------------------------------------------------------------------ nós da tmean_mun agrupada (só exposição)
ex <- m_all[m_all$data >= REF[1] & m_all$data <= REF[2], c("recorte_principal", "tmean_mun")]
stopifnot(!anyNA(ex$tmean_mun))
nos <- do.call(rbind, lapply(sort(unique(ex$recorte_principal)), function(r) {
  x <- ex$tmean_mun[ex$recorte_principal == r]; q <- quantile(x, c(.10, .75, .90), type = 7, names = FALSE)
  data.frame(recorte_principal = r, n_valores = length(x), p10 = q[1], p75 = q[2], p90 = q[3], stringsAsFactors = FALSE)
}))
nos$concentracao <- nome[nos$recorte_principal]
stopifnot(nrow(nos) == 26)
write.csv(nos, nos_out, row.names = FALSE)

# ------------------------------------------------------------------ log
tipo <- function(x) if (is.factor(x)) paste0("factor (", paste(levels(x), collapse = ", "), ")") else class(x)[1]
desc <- c(CD_MUN6 = "município (6 dígitos)", recorte_principal = "concentração", data = "dia", ptb = "PTB (22–36), coorte fixa 22",
          z_t = "Σ_{j=22}^{36} z_nv do município (0 nos dias sem célula nas semanas 22–36 e de 2011-12-14 a 2011-12-31)",
          w_t = "Σ_j Z_tj·w_j / Z_t, com o w_j da concentração (NA se Z_t = 0)", log_z = "log(Z_t)", log_w = "log(W_t)",
          log_zw = "log(Σ_j Z_tj·w_j), γ = 1 (NA se Z_t = 0)", z_t_zero = "Z_t = 0", tmean_mun = "exposição do município (°C)",
          tmean_nucleo = "exposição da cidade-núcleo (°C)", dia_semana = "dia da semana", feriado_nacional = "0/1",
          carnaval = "0/1", moveis = "0/1", ano = "ano", mes = "mês", estrato_mun = "município_ano_mês",
          janela_principal = "2012-04-14 a 2024-08-06", janela_evento_possivel = "2012-01-04 a 2024-11-15",
          linha_modelo = "Z_t > 0 e janela principal (§3.1: dias de Z_t = 0 fora)")
esquema <- data.frame(`#` = seq_along(col_final), Coluna = paste0("`", col_final, "`"),
                      Tipo = vapply(serie[col_final], tipo, ""), Conteúdo = unname(desc[col_final]), check.names = FALSE)
jp <- serie$janela_principal
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
md <- c("# Fase 1, A3: conjunto da case time series municipal (`serie_ptb_municipal.rds`)", "",
        sprintf("- **Gerado por:** `00_scripts/21_monta_serie_municipal.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        "- **Fontes:** `serie_diaria(nivel = \"municipio\", coorte_fixa = TRUE)` (`ptb`, `tmean_mun`, `tmean_nucleo`); `gestacoes_em_risco(nivel = \"municipio\")` (`z_nv`, semanas 22–36); `calendario()`; w_j da concentração gravado pelo 20.",
        sprintf("- **Período gravado:** 2011-12-14 a 2024-11-15, %s dias × %d municípios = %s linhas, sem lacuna (a `crossbasis` com `group = CD_MUN6` precisa da série consecutiva).",
                br(n_dias_grav), n_mun, br(nrow(serie))),
        sprintf("- **Offset:** `monta_offset(..., periodo = NULL)` por concentração, com o w_j dela, sobre a grade completa de 2011-12-14 a 2024-11-15 (desvios 44 e 48). O `gestacoes_em_risco` é esparso (só células com `z_nv` ou `z_fetal` > 0) e começa em 2012-01-01. Entraram com Z = 0: os %s dias-município de 2011-12-14 a 2011-12-31 (pela coorte fixa, nenhuma gestação chega à semana 22 antes de 2012-01-01) e, de 2012-01-01 a 2024-11-15, %s dias-município sem célula nas semanas 22 a 36. Também têm Z_t = 0 %s com célula nas semanas 22 a 36 só por `z_fetal` (`z_nv` = 0). Todos esses dias saem com `z_t_zero` = TRUE e offset NA (conferido por código). O offset existe nos dias com Z_t > 0 fora da janela de evento possível; quem decide o que entra no ajuste é a `linha_modelo`.",
                br(n_zero_2011), br(n_sem_celula), txt_fetal),
        sprintf("- **`linha_modelo`** = Z_t > 0 e dia na janela principal: %s dias-município de %s na janela principal. %s",
                br(sum(serie$linha_modelo)), br(sum(jp)),
                if (sum(serie$linha_modelo) == sum(jp)) "Nenhum dia da janela principal tem Z_t = 0." else "Os demais têm Z_t = 0 e saem só no ajuste, depois de montada a cross-basis."),
        "- **NA de propósito:** como na série principal, `ptb` é NA de 2011-12-14 a 2011-12-31 (contagens de 2011 que dependem de IG), e só nesses dias (conferido por código); esses dias só servem de aquecimento da exposição.",
        "- **Nós:** p10, p75 e p90 da `tmean_mun` de 2012-01-01 a 2024-12-31, municípios da concentração agrupados, `quantile(type = 7)`. Ficam só gravados (`01_saidas/fase1/nos_tmean_mun_concentracao.csv`), sem ir para o retorno.",
        "- **Arquivos gravados (fora do git), SHA-256:**",
        sprintf("  - `01_saidas/fase1/serie_ptb_municipal.rds`: `%s`;", sha(rds_out)),
        sprintf("  - `01_saidas/fase1/nos_tmean_mun_concentracao.csv`: `%s`.", sha(nos_out)), "",
        "## Esquema", "", "Uma linha por `CD_MUN6` × `data`, ordenada por concentração, município e data.", "",
        tabela_md(esquema), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "\n")
