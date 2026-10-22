# 22_monta_ptb_espontaneo.R — Fase 1, A4: séries diárias de PTB espontâneo por concentração (sensibilidade-chave 6;
# especificação v2.0.2, §3.4, com a errata E5). Nenhum modelo.
# - Fonte: nascimentos(), população do ptb (pop_ptb, coorte_fixa_22, ptb), por concentração e data do nascimento.
# - Classificação (códigos como texto; o vazio da base é NA, comparado com %in%, nunca com ==):
#   iniciado por profissional: sttrabpart = "1" ou (parto = "2" e stcesparto_aj = "1");
#   espontâneo: sttrabpart = "2" e (parto = "1" ou (parto = "2" e stcesparto_aj = "2"));
#   ignorado: o resto (todo PTB que não é explicitamente iniciado nem espontâneo).
# - Séries: ptb_espontaneo_i (espontâneos), ptb_espontaneo_ii (espontâneos + ignorados), ptb_iniciado, ptb_ignorado.
#   Z_t não muda (§3.4): as séries são juntadas por chave à série da A2 (serie_ptb_principal.rds, gravada pelo 20).
# - Identidade exata, dia a dia: espontâneo (i) + iniciado + ignorado = ptb da A2. Se alguma linha divergir, para.
# Grava (fora do git) 01_saidas/fase1/serie_ptb_espontaneo.rds (a série da A2 mais as 4 colunas) e o log
# logs/ptb_espontaneo_fase1_<FASE1_DATA>.md. Nunca sobrescreve. Depende do 20.
# Sigilo: o log traz só a classificação, o esquema e o resultado da identidade; nenhuma contagem diária.
# Uso (de artigo1_prematuridade/):  FASE1_DATA=AAAAMMDD Rscript 00_scripts/22_monta_ptb_espontaneo.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE1_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
saida <- file.path("01_saidas", "fase1"); stopifnot(dir.exists(saida))
rds_in <- file.path(saida, "serie_ptb_principal.rds"); stopifnot(file.exists(rds_in))
rds_out <- file.path(saida, "serie_ptb_espontaneo.rds")
arq <- file.path("logs", paste0("ptb_espontaneo_fase1_", hoje, ".md"))
for (p in c(rds_out, arq)) stopifnot(!file.exists(p))
D <- as.Date
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
conc <- as.data.frame(concentracoes())[, c("CD_MUN6", "CD_RECORTE")]

log_msg("lendo nascimentos()")
n <- as.data.frame(nascimentos(c("CD_MUN6", "data", "pop_ptb", "coorte_fixa_22", "ptb", "sttrabpart", "stcesparto_aj", "parto")))
n <- n[n$pop_ptb %in% TRUE & n$coorte_fixa_22 %in% TRUE & n$ptb %in% TRUE, ]
n$data <- D(n$data)
n$recorte_principal <- conc$CD_RECORTE[match(n$CD_MUN6, conc$CD_MUN6)]; stopifnot(!anyNA(n$recorte_principal))
for (k in c("sttrabpart", "stcesparto_aj", "parto")) stopifnot(is.character(n[[k]]))
ini <- n$sttrabpart %in% "1" | (n$parto %in% "2" & n$stcesparto_aj %in% "1")
esp <- n$sttrabpart %in% "2" & (n$parto %in% "1" | (n$parto %in% "2" & n$stcesparto_aj %in% "2"))
stopifnot(!any(ini & esp))                                        # categorias mutuamente exclusivas
ign <- !ini & !esp
chave <- paste(n$recorte_principal, as.integer(n$data))
conta <- function(x) tapply(x, chave, sum)
c_esp <- conta(esp); c_ini <- conta(ini); c_ign <- conta(ign)
rm(n); invisible(gc())

s <- readRDS(rds_in)
k_s <- paste(s$recorte_principal, as.integer(s$data))
stopifnot(all(names(c_esp) %in% k_s))                              # nenhum PTB fora do período gravado
pega <- function(cn) { v <- as.integer(cn[k_s]); v[is.na(v)] <- 0L; v }
s$ptb_espontaneo_i <- pega(c_esp); s$ptb_iniciado <- pega(c_ini); s$ptb_ignorado <- pega(c_ign)
base_na <- is.na(s$ptb)                                            # 2011: ptb NA na base; as séries novas também
for (k in c("ptb_espontaneo_i", "ptb_iniciado", "ptb_ignorado")) s[[k]][base_na] <- NA_integer_
s$ptb_espontaneo_ii <- s$ptb_espontaneo_i + s$ptb_ignorado
soma <- s$ptb_espontaneo_i + s$ptb_iniciado + s$ptb_ignorado
dias_comp <- sum(!base_na); dif <- sum(soma[!base_na] != s$ptb[!base_na])
stopifnot(identical(names(c_esp), names(c_ini)), identical(names(c_esp), names(c_ign)))   # mesma chave nos três tapply
n_na_extra <- sum((c_esp + c_ini + c_ign)[!(names(c_esp) %in% k_s[!base_na])])          # PTB em dia com ptb NA na base
mascara_n <- function(x) if (x > 0 && x < 10) "<10" else format(x)   # nunca uma contagem de 1 a 9 em mensagem
if (dif > 0 || n_na_extra > 0) stop("identidade espontâneo (i) + iniciado + ignorado = ptb falhou em ", mascara_n(dif),
                                     " dia(s); há PTB em dia com ptb NA na base: ", if (n_na_extra > 0) "sim" else "não", ". Parar.")
col_novas <- c("ptb_espontaneo_i", "ptb_espontaneo_ii", "ptb_iniciado", "ptb_ignorado")
outras <- setdiff(names(s), col_novas); pos <- which(outras == "nv_unicos")
s <- s[, c(outras[1:pos], col_novas, outras[(pos + 1):length(outras)])]
stopifnot(identical(setdiff(names(s), col_novas), names(readRDS(rds_in))))   # colunas da A2 intactas e na ordem
saveRDS(s, rds_out)
log_msg("gravado", rds_out)

stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
md <- c("# Fase 1, A4: séries de PTB espontâneo por concentração (`serie_ptb_espontaneo.rds`)", "",
        sprintf("- **Gerado por:** `00_scripts/22_monta_ptb_espontaneo.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        "- **Fonte:** `nascimentos()`, população do `ptb` (`pop_ptb`, `coorte_fixa_22`, `ptb`), por concentração e data do nascimento. Z_t não muda (§3.4): as séries foram juntadas por chave à série da A2.",
        "- **Classificação** (§3.4 com a errata E5; códigos como texto; o vazio da base é NA e foi comparado com `%in%`, nunca com `==`):",
        "  - **iniciado por profissional:** `sttrabpart` = \"1\" ou (`parto` = \"2\" e `stcesparto_aj` = \"1\");",
        "  - **espontâneo:** `sttrabpart` = \"2\" e (`parto` = \"1\" ou (`parto` = \"2\" e `stcesparto_aj` = \"2\"));",
        "  - **ignorado:** o resto, isto é, todo PTB que não é explicitamente iniciado nem espontâneo.",
        "  - As duas primeiras categorias são mutuamente exclusivas (conferido: nenhum PTB nas duas).",
        "- **Séries:** `ptb_espontaneo_i` (espontâneos), `ptb_espontaneo_ii` (espontâneos + ignorados), `ptb_iniciado` e `ptb_ignorado`, colocadas depois de `nv_unicos`. As demais colunas são as da A2, sem mudança. Em 2011 (2011-12-14 a 2011-12-31), onde o `ptb` da base é NA, as quatro também são NA.",
        sprintf("- **Identidade exata, dia a dia:** espontâneo (i) + iniciado + ignorado = `ptb` da A2 em %s de %s dias-concentração com `ptb` definido (%s divergências). Nenhum PTB da população caiu fora do período gravado nem num dia com `ptb` NA.",
                br(dias_comp - dif), br(dias_comp), br(dif)),
        "  - **O que ela testa:** como \"ignorado\" é o resto, a soma das três fecha por construção da classificação. A identidade confere, portanto, que o PTB contado a partir de `nascimentos()` é igual, dia a dia e por concentração, ao `ptb` da `serie_diaria` da base. A classificação em si é conferida à parte: as duas categorias explícitas são exclusivas, e o 25 a refaz com outro código (auditoria da Fase 1, achado 9).",
        "- **Percentuais por ano e por concentração:** na A6, item 9 (`conferencias_fase1_*.md`), só com anos inteiros de 2013 a 2023.",
        sprintf("- **Arquivo gravado (fora do git), SHA-256:** `01_saidas/fase1/serie_ptb_espontaneo.rds`: `%s`.", sha(rds_out)), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "\n")
