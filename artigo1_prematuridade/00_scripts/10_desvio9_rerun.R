# 10_desvio9_rerun.R — Fase 0 refeita (base 4443971b), A8: reconferência das condições do desvio 9 (coluna "Perda" da
# A5.2), nos dois desfechos (PTB e óbito perinatal).
#   1. células de 1 a 9 na "Perda" (esperado 0) e menor perda diferente de zero (Fase 0A: 40);
#   2. fontes: toda tabela publicada na Forja com contagens do mesmo desfecho, da mesma população e da mesma concentração
#      (ou das 26 somadas), numeradas, com SHA-256; cada número delas que entra na prova é conferido contra a série;
#   3. prova por código, exaustiva no nível das parcelas (concentração × trecho do calendário × subtipo ou tipo), de que
#      nenhuma combinação das tabelas isola uma contagem menor que 10 dentro das pontas fora da janela;
#   4. a frase de resultado.
# Só lê agregados (séries diárias por concentração e tabelas publicadas); não lê microdado. Sem exposição.
# Grava logs/desvio9_fase0_rerun_<FASE0_RERUN_DATA>.md (nunca sobrescreve).
# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/10_desvio9_rerun.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
BASE <- "/Volumes/Forja/Doc/dados_artigos_perinatais_clima"
hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("desvio9_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
sha256 <- function(f) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(f)), stdout = TRUE))
classe <- function(x) ifelse(x == 0, "0", ifelse(x > 0 & x < 10, "1 a 9", ifelse(x >= 10, "≥ 10", "negativo")))
D <- as.Date
nuc <- as.data.frame(cidade_nucleo()); REC <- nuc$CD_RECORTE; nome <- setNames(nuc$NM_RECORTE, REC); NR <- length(REC)
stopifnot(NR == 26)
para <- function(...) { cat("PARAR:", ..., "\n"); quit(status = 1) }

# ================================================================ 1. coluna "Perda" da A5.2 refeita
f52 <- file.path("01_saidas", "fase0_rerun", "a5_2_eventos_janelas.csv"); f52_0 <- file.path("01_saidas", "fase0", "a5_2_eventos_janelas.csv")
a52 <- read.csv(f52, stringsAsFactors = FALSE, colClasses = c(recorte_principal = "character"))
stopifnot(nrow(a52) == 4 * NR, all(a52$perda == a52$total_2012_2024 - a52$eventos_janela))
igual_0A <- identical(sha256(f52), sha256(f52_0))
tab_perda <- do.call(rbind, lapply(split(a52, paste(a52$desfecho, a52$janela)), function(d) {
  nz <- d$perda[d$perda > 0]
  data.frame(Desfecho = d$desfecho[1], Janela = d$janela[1], Concentrações = nrow(d), `Células de 1 a 9` = sum(d$perda > 0 & d$perda < 10),
             `Células = 0` = sum(d$perda == 0), `Menor perda ≠ 0` = if (length(nz)) br(min(nz)) else "—",
             Onde = if (length(nz)) d$concentracao[d$perda == min(nz)][1] else "—", check.names = FALSE)
}))
n19 <- sum(a52$perda > 0 & a52$perda < 10); nz <- a52$perda[a52$perda > 0]; min_nz <- min(nz)
quem_min <- with(a52[a52$perda == min_nz, ][1, ], sprintf("%s, %s, janela %s", concentracao, desfecho, janela))
cat("Perda: células de 1 a 9 =", n19, "| menor ≠ 0 =", min_nz, "(", quem_min, ")\n")

# ================================================================ 2. fontes
A1 <- function(p) file.path("/Volumes/Forja/Doc/artigos_perinatais_clima/artigo1_prematuridade", p)
B <- function(p) file.path(BASE, p)
entrega <- list.files(BASE, pattern = "^ENTREGA_COORDENACAO_[0-9a-f]{8}_20261007\\.md$")   # a ENTREGA da versão anterior (nome com o hash)
stopifnot(length(entrega) == 1)
fontes <- data.frame(stringsAsFactors = FALSE, rbind(
  c(A1("01_saidas/fase0_rerun/a5_2_eventos_janelas.csv"), "A5.2 refeita: PTB e perinatal por concentração; total 2012–2024, na janela e perda, nas janelas principal e de evento possível", "no modelo"),
  c(A1(paste0("logs/recontagens_fase0_rerun_", hoje, ".md")), "as mesmas tabelas da A5.2 refeita, em markdown (vão para o RESPOSTA refeito)", "= F1"),
  c(A1("01_saidas/fase0/a5_2_eventos_janelas.csv"), "A5.2 da Fase 0A", "= F1 (SHA-256 igual)"),
  c(A1("RESPOSTA_artigo1_prematuridade_FASE0A_20261008.md"), "RESPOSTA da Fase 0A: A5.2 publicada", "= F1"),
  c(A1("RESPOSTA_artigo1_prematuridade_FASE0A_complemento_20261008.md"), "complemento: nenhuma tabela de contagem de PTB ou de óbito por concentração (só a menor perda, que está em F1)", "nada novo"),
  c(A1("01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv"), "A7 refeita: NV e PTB por concentração na janela principal, por nível da DUM (mascarada)", "no modelo (células publicadas)"),
  c(A1("01_saidas/fase0_rerun/a7_populacao_dum_ano.csv"), "A7 refeita: NV e PTB por ano, 2013–2023, 26 somadas (mascarada)", "no modelo (células publicadas)"),
  c(A1(paste0("logs/populacao_dum_fase0_rerun_", hoje, ".md")), "as tabelas da A7 em markdown, mais a linha das 26 somadas", "no modelo (linha das 26 somadas)"),
  c(B(entrega), "§5: por ano, 26 somadas (NV, PTB, óbito fetal, neonatal precoce, perinatal); §6: por concentração, PTB e perinatal 2012–2024", "no modelo; conferido contra a série"),
  c(B("logs/relatorio_entrega_20261007.html"), "as tabelas da ENTREGA, mais, por ano e 26 somadas, os subtipos do PTB e as variantes do perinatal (sem coorte, sem IG, indexado no óbito, até 24 h, sem anomalia)", "no modelo ou por argumento (seção 4); conferido"),
  c(B("logs/relatorio_entrega_20261008.html"), "igual ao F10, regerado na troca de versão", "= F10; conferido"),
  c(B("logs/totais_anuais.csv"), "por ano, 26 somadas, todas as contagens da série (com e sem coorte fixa)", "no modelo ou por argumento; conferido"),
  c(B("logs/criterios_inclusao_recorte.csv"), "por concentração: eventos_periodo_principal de PTB e perinatal (= total 2012–2024)", "no modelo; conferido"),
  c(B("ENTREGA_COORDENACAO_conciliacoes_20261007.md"), "§A3: Salvador e Aracaju por ano, 2012–2024 (óbito fetal, neonatal precoce, PTB e % PTB, que dá o NV); §A2: por ano, 26 somadas, fetal e neonatal principais e sem IG", "§A3 no modelo, com o NV tratado como exato (conservador); §A2 = F12 ou por argumento; conferido"),
  c(B("RESPOSTA_QUESTIONAMENTO_20261007.md"), "Q5: zeros nas bordas (0 PTB e 0 NV antes de 2012-01-04; 0 PTB depois de 2024-11-15); Q6: 0 neonatal da coorte nascido de 25 a 31/12/2024; Q8 e Q11: por semana de IG, 2012–2024, 26 somadas; Q9b: PTB por `GESTACAO`, 2012 e 2013, 26 somadas", "zeros no modelo; o resto por argumento"),
  c(B("RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md"), "§6: NV por ano e por disponibilidade da DUM; nenhuma contagem de PTB nem de óbito", "fora do desfecho (a A7 trata dela no `12_…`)")))
names(fontes) <- c("caminho", "conteudo", "tratamento")
fontes$sha <- vapply(fontes$caminho, sha256, ""); fontes$n <- paste0("F", seq_len(nrow(fontes)))
stopifnot(all(nchar(fontes$sha) == 64))

# ================================================================ 3. séries (agregadas) e parcelas do calendário
sd <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "nv_unicos", "ptb",
  "ptb_extremo", "ptb_muito", "ptb_moderado_tardio", "obito_fetal_principal", "obito_neonatal_precoce", "obito_perinatal",
  "obito_ate24h", "obito_perinatal_24h", "obito_perinatal_sem_anomalia")))
sd$data <- as.Date(sd$data); sd <- sd[sd$data >= D("2012-01-01") & sd$data <= D("2024-12-31"), ]
sd$r <- match(sd$recorte_principal, REC); stopifnot(!anyNA(sd$r))
# trechos: 1 = q1, 2 = q2, 3 = parte de 2012 na janela, 4..14 = 2013..2023, 15 = parte de 2024 na janela, 16 = q3, 17 = q4
ini_ptb <- D(c("2012-01-01", "2012-01-04", "2012-04-14", paste0(2013:2023, "-01-01"), "2024-01-01", "2024-08-07", "2024-11-16"))
ini_per <- D(c("2012-01-01", "2012-01-04", "2012-05-26", paste0(2013:2023, "-01-01"), "2024-01-01", "2024-08-07", "2024-12-25"))
sd$pP <- findInterval(as.numeric(sd$data), as.numeric(ini_ptb)); sd$pD <- findInterval(as.numeric(sd$data), as.numeric(ini_per))
NP <- 17L
soma <- function(v, p) { x <- tapply(v, list(factor(sd$r, 1:NR), factor(p, 1:NP)), sum, na.rm = TRUE); x[is.na(x)] <- 0; x }
stopifnot(!anyNA(sd[, c("nv_unicos", "ptb", "ptb_extremo", "ptb_muito", "ptb_moderado_tardio", "obito_fetal_principal")]))
stopifnot(all(sd$ptb == sd$ptb_extremo + sd$ptb_muito + sd$ptb_moderado_tardio))
na_neo <- is.na(sd$obito_neonatal_precoce)
stopifnot(identical(na_neo, is.na(sd$obito_perinatal)), identical(na_neo, is.na(sd$obito_ate24h)),
          identical(na_neo, is.na(sd$obito_perinatal_24h)), identical(na_neo, is.na(sd$obito_perinatal_sem_anomalia)),
          all(sd$pD[na_neo] == 17L), all(na_neo[sd$pD == 17L]))
ok <- !na_neo
stopifnot(all(sd$obito_perinatal[ok] == sd$obito_fetal_principal[ok] + sd$obito_neonatal_precoce[ok]),
          all(sd$obito_perinatal_24h[ok] == sd$obito_fetal_principal[ok] + sd$obito_ate24h[ok]),
          all(sd$obito_ate24h[ok] <= sd$obito_neonatal_precoce[ok]), all(sd$obito_perinatal_sem_anomalia[ok] <= sd$obito_perinatal[ok]))
# PTB: subtipo s = 1 extremo, 2 muito, 3 moderado-tardio, 4 não PTB (NV − PTB)
VP <- array(0, c(NR, NP, 4))
VP[, , 1] <- soma(sd$ptb_extremo, sd$pP); VP[, , 2] <- soma(sd$ptb_muito, sd$pP); VP[, , 3] <- soma(sd$ptb_moderado_tardio, sd$pP)
VP[, , 4] <- soma(sd$nv_unicos - sd$ptb, sd$pP)
# perinatal: margens por concentração × trecho (o trecho 17, censurado, só tem o fetal)
MD <- list(fetal = soma(sd$obito_fetal_principal, sd$pD), neo = soma(sd$obito_neonatal_precoce, sd$pD),
           per = soma(sd$obito_perinatal, sd$pD), ate24h = soma(sd$obito_ate24h, sd$pD),
           per24h = soma(sd$obito_perinatal_24h, sd$pD), semanom = soma(sd$obito_perinatal_sem_anomalia, sd$pD))

# ================================================================ 3b. conferência: cada número publicado que entra na prova = série
num <- function(x) as.numeric(gsub("[^0-9]", "", x))            # tira separador de milhar e marcas de nota ("*", "†")
tab_md <- function(linhas, cab) { i <- grep(cab, linhas, fixed = TRUE)[1]; stopifnot(!is.na(i)); j <- i + 2
  while (j <= length(linhas) && startsWith(linhas[j], "|")) j <- j + 1
  do.call(rbind, lapply(strsplit(linhas[(i + 2):(j - 1)], "|", fixed = TRUE), function(z) trimws(z[-1]))) }
anos_ptb <- function(y) if (y == 2012) 1:3 else if (y == 2024) 15:17 else y - 2009L
anos_per <- function(y, censura) if (y == 2012) 1:3 else if (y == 2024) (if (censura) 15:16 else 15:17) else y - 2009L
s_ano <- function(m, y, pp) sum(m[, pp])
conf <- data.frame(conferencia = character(), ok = logical(), stringsAsFactors = FALSE)
cf <- function(txt, ok) conf[nrow(conf) + 1, ] <<- list(txt, isTRUE(ok))
# A5.2 refeita × série, com as definições de trecho do modelo
for (dd in c("ptb", "obito_perinatal")) for (jj in c("principal", "evento possível")) {
  x <- a52[a52$desfecho == dd & a52$janela == jj, ]; x <- x[match(REC, x$recorte_principal), ]
  if (dd == "ptb") { tot <- apply(VP[, , 1:3], 1, sum); jan <- apply(VP[, if (jj == "principal") 3:15 else 2:16, 1:3], 1, sum) }
  else { tot <- rowSums(MD$per[, 1:16]); jan <- rowSums(MD$per[, if (jj == "principal") 3:15 else 2:16]) }
  cf(sprintf("A5.2 refeita (F1), %s, janela %s: total, na janela e perda = série nos trechos do modelo", dd, jj),
     all(x$total_2012_2024 == tot) && all(x$eventos_janela == jan) && all(x$perda == tot - jan))
}
ta <- read.csv(fontes$caminho[12], stringsAsFactors = FALSE); ta <- ta[ta$versao == "principal" & ta$ano %in% 2012:2024, ]
ta <- ta[match(2012:2024, ta$ano), ]
mod_ano <- data.frame(ano = 2012:2024)
mod_ano$nv <- sapply(2012:2024, function(y) sum(VP[, anos_ptb(y), ])); mod_ano$ptb <- sapply(2012:2024, function(y) sum(VP[, anos_ptb(y), 1:3]))
for (k in 1:3) mod_ano[[c("ext", "muito", "mod")[k]]] <- sapply(2012:2024, function(y) sum(VP[, anos_ptb(y), k]))
mod_ano$fetal <- sapply(2012:2024, function(y) s_ano(MD$fetal, y, anos_per(y, FALSE)))
for (v in c("neo", "per", "ate24h", "per24h", "semanom")) mod_ano[[v]] <- sapply(2012:2024, function(y) s_ano(MD[[v]], y, anos_per(y, TRUE)))
cf("Totais anuais (F12), 2012–2024: NV, PTB, extremo, muito, moderado-tardio, fetal, neonatal, perinatal, até 24 h, perinatal 24 h, sem anomalia = série nos trechos do modelo",
   all(ta$nv_unicos == mod_ano$nv) && all(ta$ptb == mod_ano$ptb) && all(ta$ptb_extremo == mod_ano$ext) && all(ta$ptb_muito == mod_ano$muito) &&
   all(ta$ptb_moderado_tardio == mod_ano$mod) && all(ta$obito_fetal_principal == mod_ano$fetal) && all(ta$obito_neonatal_precoce == mod_ano$neo) &&
   all(ta$obito_perinatal == mod_ano$per) && all(ta$obito_ate24h == mod_ano$ate24h) && all(ta$obito_perinatal_24h == mod_ano$per24h) &&
   all(ta$obito_perinatal_sem_anomalia == mod_ano$semanom))
en <- readLines(fontes$caminho[9], encoding = "UTF-8")
e5 <- tab_md(en, "| Ano | NV únicos 22–42 | Prematuros |"); e5 <- e5[match(as.character(2012:2024), gsub("\\*", "", e5[, 1])), ]
cf("ENTREGA §5 (F9): NV, PTB, fetal, neonatal, perinatal por ano = totais anuais",
   all(num(e5[, 2]) == ta$nv_unicos) && all(num(e5[, 3]) == ta$ptb) && all(num(e5[, 5]) == ta$obito_fetal_principal) &&
   all(num(e5[, 6]) == ta$obito_neonatal_precoce) && all(num(e5[, 7]) == ta$obito_perinatal))
e6 <- tab_md(en, "| Concentração | Cidade-núcleo |"); e6 <- e6[match(nome[REC], e6[, 1]), ]
tot_ptb <- a52$total_2012_2024[a52$desfecho == "ptb" & a52$janela == "principal"][match(REC, a52$recorte_principal[a52$desfecho == "ptb" & a52$janela == "principal"])]
tot_per <- a52$total_2012_2024[a52$desfecho == "obito_perinatal" & a52$janela == "principal"][match(REC, a52$recorte_principal[a52$desfecho == "obito_perinatal" & a52$janela == "principal"])]
cf("ENTREGA §6 (F9): PTB e perinatal 2012–2024 por concentração = total da A5.2", !anyNA(e6[, 1]) && all(num(e6[, 5]) == tot_ptb) && all(num(e6[, 6]) == tot_per))
ci <- read.csv(fontes$caminho[13], stringsAsFactors = FALSE, colClasses = c(CD_RECORTE = "character"))
cf("criterios_inclusao_recorte.csv (F13): eventos_periodo_principal = total da A5.2, PTB e perinatal",
   all(ci$eventos_periodo_principal[ci$desfecho == "prematuridade"][match(REC, ci$CD_RECORTE[ci$desfecho == "prematuridade"])] == tot_ptb) &&
   all(ci$eventos_periodo_principal[ci$desfecho == "obito_perinatal"][match(REC, ci$CD_RECORTE[ci$desfecho == "obito_perinatal"])] == tot_per))
html_tab <- function(f, cab) {
  t <- paste(readLines(f, encoding = "UTF-8", warn = FALSE), collapse = " ")
  tb <- regmatches(t, gregexpr("<table.*?</table>", t, perl = TRUE))[[1]]; tb <- tb[grepl(cab, tb, fixed = TRUE)][1]; stopifnot(!is.na(tb))
  tr <- regmatches(tb, gregexpr("<tr[^>]*>.*?</tr>", tb, perl = TRUE))[[1]]
  tr <- tr[grepl("<td", tr)]
  do.call(rbind, lapply(tr, function(x) trimws(gsub("<[^>]+>", "", regmatches(x, gregexpr("<td[^>]*>.*?</td>", x, perl = TRUE))[[1]]))))
}
for (fi in 10:11) {
  h6 <- html_tab(fontes$caminho[fi], "Prematuros 2012–2024"); h6 <- h6[match(nome[REC], h6[, 1]), ]
  h5 <- html_tab(fontes$caminho[fi], "NV únicos 22–42 sem."); h5 <- h5[match(as.character(2012:2024), gsub("\\*", "", h5[, 1])), ]
  hv <- html_tab(fontes$caminho[fi], "Prematuros, sem coorte fixa"); hv <- hv[match(as.character(2012:2024), gsub("\\*", "", hv[, 1])), ]
  cf(sprintf("Relatório %s (%s): por concentração (PTB e perinatal 2012–2024) = A5.2; por ano (NV, PTB, 3 subtipos, fetal, neonatal, perinatal) e variantes (indexado no óbito, até 24 h, sem anomalia) = totais anuais",
             basename(fontes$caminho[fi]), fontes$n[fi]),
     !anyNA(h6[, 1]) && all(num(h6[, 5]) == tot_ptb) && all(num(h6[, 7]) == tot_per) &&
     all(num(h5[, 2]) == ta$nv_unicos) && all(num(h5[, 3]) == ta$ptb) && all(num(h5[, 5]) == ta$ptb_extremo) && all(num(h5[, 6]) == ta$ptb_muito) &&
     all(num(h5[, 7]) == ta$ptb_moderado_tardio) && all(num(h5[, 8]) == ta$obito_fetal_principal) && all(num(h5[, 9]) == ta$obito_neonatal_precoce) &&
     all(num(h5[, 10]) == ta$obito_perinatal) && all(num(hv[, 7]) == ta$obito_perinatal_idx_obito) && all(num(hv[, 8]) == ta$obito_perinatal_24h) &&
     all(num(hv[, 9]) == ta$obito_perinatal_sem_anomalia))
}
cc <- readLines(fontes$caminho[14], encoding = "UTF-8")
conc_a3 <- c(Salvador = "Salvador/BA", Aracaju = "Aracaju/SE")
for (cn in names(conc_a3)) {
  i0 <- grep(paste0("**", cn, " (UF:"), cc, fixed = TRUE); stopifnot(length(i0) == 1)
  t3 <- tab_md(cc[i0:length(cc)], "| Ano | Óbito fetal | Neonatal precoce | Prematuros |"); t3 <- t3[match(as.character(2012:2024), t3[, 1]), ]
  ri <- match(conc_a3[[cn]], nome[REC])
  cf(sprintf("Conciliações §A3 (F14), %s: óbito fetal, neonatal precoce e PTB por ano, 2012–2024 = série nos trechos do modelo", cn),
     !is.na(ri) && all(num(t3[, 2]) == sapply(2012:2024, function(y) sum(MD$fetal[ri, anos_per(y, FALSE)]))) &&
     all(num(t3[, 3]) == sapply(2012:2024, function(y) sum(MD$neo[ri, anos_per(y, TRUE)]))) &&
     all(num(t3[, 4]) == sapply(2012:2024, function(y) sum(VP[ri, anos_ptb(y), 1:3]))))
}
cf("Q5 (F15): 0 PTB e 0 NV de 2012-01-01 a 2012-01-03; 0 PTB de 2024-11-16 a 2024-12-31 (na série)", sum(VP[, 1, ]) == 0 && sum(VP[, 17, 1:3]) == 0)
cf("Q6 (F15): neonatal precoce de 2024-12-25 a 2024-12-31 é NA nas 26 (censura); a Q6 publica que é 0 no SIM de 2024", all(na_neo[sd$pD == 17L]))
print(conf, right = FALSE)
if (!all(conf$ok)) para("um número publicado não bate com a série nos trechos do modelo")

# ================================================================ 4. prova exaustiva (identificabilidade linear + não negatividade)
# rows: lista de vetores de átomos (cada um, uma soma publicada com coeficiente 1); val_row: valor publicado de cada uma.
# coords: parcelas disjuntas (vetores de átomos) de que se montam as contagens candidatas; ub: limite superior de cada uma.
# Toda contagem candidata é uma união de parcelas; uma união com valor de 1 a 9 só pode conter parcelas com ub ≤ 9 (J).
# Identificável ⇔ o indicador está no espaço das linhas. Em J: x' H x = 0, H = diag(|parcela|) − (TᵀQ)(TᵀQ)ᵀ; o núcleo de H,
# separado em blocos de suporte disjunto (projetor bloco-diagonal), é enumerado por bloco. Fechamento de zeros: soma
# publicada ou identificável = 0 ⇒ cada átomo dela é 0 (contagens não negativas), e isso entra como linha conhecida.
prova <- function(rows, val_row, n_at, coords, ub, valor_coord = NULL, max_enum = 18L) {
  zeros <- integer(); hist <- character()
  z0 <- which(val_row == 0); if (length(z0)) zeros <- unique(unlist(rows[z0]))
  repeat {
    R <- c(rows, as.list(zeros)); vr <- c(val_row, rep(0, length(zeros)))
    M <- matrix(0, length(R), n_at); for (i in seq_along(R)) M[i, R[[i]]] <- 1
    q <- qr(t(M), tol = 1e-9); Q <- qr.Q(q)[, seq_len(q$rank), drop = FALSE]
    res2 <- function(ix) length(ix) - sum(colSums(Q[ix, , drop = FALSE])^2)
    val_uniao <- function(ix) { x <- numeric(n_at); x[ix] <- 1; cf <- qr.coef(q, x); cf[is.na(cf)] <- 0
      if (max(abs(t(M) %*% cf - x)) > 1e-6) stop("união não identificável passada a val_uniao"); sum(cf * vr) }
    zc <- vapply(coords, function(ix) all(ix %in% zeros), TRUE)
    J <- which(ub <= 9 & !zc)
    if (!length(J)) { d <- 0L; blocos <- list(); unioes <- list(); break }
    TQ <- t(vapply(coords[J], function(ix) colSums(Q[ix, , drop = FALSE]), numeric(ncol(Q))))
    if (ncol(Q) == 1) TQ <- matrix(TQ, ncol = 1)
    H <- diag(lengths(coords[J]), nrow = length(J)) - TQ %*% t(TQ)
    e <- eigen(H, symmetric = TRUE); Nn <- e$vectors[, e$values < 1e-7, drop = FALSE]; d <- ncol(Nn)
    unioes <- list(); blocos <- list()
    if (d > 0) {
      P <- Nn %*% t(Nn); sup <- which(diag(P) > 1e-9)
      adj <- abs(P[sup, sup, drop = FALSE]) > 1e-9; comp <- rep(0L, length(sup)); k <- 0L
      for (i in seq_along(sup)) if (!comp[i]) { k <- k + 1L; fila <- i; comp[i] <- k
        while (length(fila)) { v <- fila[1]; fila <- fila[-1]; nv <- which(adj[v, ] & !comp); comp[nv] <- k; fila <- c(fila, nv) } }
      for (b in seq_len(k)) {
        Bj <- sup[comp == b]; dimB <- round(sum(diag(P[Bj, Bj, drop = FALSE])))
        blocos[[b]] <- c(tam = length(Bj), dim = dimB)
        if (length(Bj) <= max_enum) {
          S <- as.matrix(expand.grid(rep(list(0:1), length(Bj))))[-1, , drop = FALSE]
          r2 <- rowSums((S %*% H[Bj, Bj, drop = FALSE]) * S)
          for (s in which(r2 < 1e-7)) unioes[[length(unioes) + 1]] <- J[Bj[S[s, ] == 1]]
        } else if (dimB == 1) {
          u <- P[Bj, Bj[which.max(diag(P[Bj, Bj]))]]; u <- u / u[which.max(abs(u))]
          if (all(abs(u - 1) < 1e-6)) unioes[[length(unioes) + 1]] <- J[Bj]
        } else return(list(erro = sprintf("bloco de %d parcelas com dimensão %d: não enumerável", length(Bj), dimB)))
      }
    }
    vals <- vapply(unioes, function(js) if (!is.null(valor_coord)) sum(valor_coord[js]) else val_uniao(unlist(coords[js])), 0)
    if (any(abs(vals - round(vals)) > 1e-4)) stop("valor de união identificável não é inteiro")
    vals <- round(vals)                                              # contagens: o resíduo de ponto flutuante (±1e-10) sai
    novos <- setdiff(unique(unlist(lapply(unioes[vals == 0], function(js) unlist(coords[js])))), zeros)
    hist <- c(hist, sprintf("passo %d: %d linhas, posto %d, |J| = %d, núcleo %d, uniões identificáveis %d (valor 0: %d), átomos novos com zero: %d",
                            length(hist) + 1, length(R), q$rank, length(J), d, length(unioes), sum(vals == 0), length(novos)))
    if (!length(novos)) break
    zeros <- c(zeros, novos)
  }
  list(rank = q$rank, n_rows = length(rows), n_zeros = length(zeros), J = length(J), d = d, blocos = blocos, unioes = unioes,
       vals = if (length(unioes)) vals else numeric(), furos = if (length(unioes)) sum(vals > 0 & vals < 10) else 0L, hist = hist,
       res2 = res2, zeros = zeros)
}

# ---------------------------------------------------------------- PTB: átomos r × trecho (17) × s (4) × nível da DUM k (3)
aP <- function(rr, pp, ss, kk) { g <- expand.grid(rr = rr, pp = pp, ss = ss, kk = kk); g$rr + NR * (g$pp - 1L) + NR * NP * (g$ss - 1L) + NR * NP * 4L * (g$kk - 1L) }
nP <- NR * NP * 4L * 3L
rowsP <- list(); valP <- numeric(); rotP <- character()
addP <- function(ix, v, rot) { rowsP[[length(rowsP) + 1]] <<- ix; valP <<- c(valP, v); rotP <<- c(rotP, rot) }
vP <- function(rr, pp, ss) sum(VP[rr, pp, ss])
for (i in seq_len(NR)) {
  addP(aP(i, 1:17, 1:3, 1:3), vP(i, 1:17, 1:3), "A5.2 PTB total 2012–2024 (F1, F3, F4, F9 §6, F10, F11, F13)")
  addP(aP(i, 3:15, 1:3, 1:3), vP(i, 3:15, 1:3), "A5.2 PTB na janela principal (F1; = A7 PTB (a))")
  addP(aP(i, c(1, 2, 16, 17), 1:3, 1:3), vP(i, c(1, 2, 16, 17), 1:3), "A5.2 PTB perda principal (F1)")
  addP(aP(i, 2:16, 1:3, 1:3), vP(i, 2:16, 1:3), "A5.2 PTB na janela de evento possível (F1)")
  addP(aP(i, c(1, 17), 1:3, 1:3), vP(i, c(1, 17), 1:3), "A5.2 PTB perda de evento possível (F1)")
}
SK <- list(nv_a = list(s = 1:4, k = 1:3), nv_b = list(s = 1:4, k = 1:2), nv_c = list(s = 1:4, k = 1L),
           ptb_a = list(s = 1:3, k = 1:3), ptb_b = list(s = 1:3, k = 1:2), ptb_c = list(s = 1:3, k = 1L))
mascarado <- function(x) x %in% c("supr.", "<10")
a7c <- read.csv(fontes$caminho[6], stringsAsFactors = FALSE, colClasses = "character"); a7c <- a7c[match(REC, a7c$recorte_principal), ]
a7a <- read.csv(fontes$caminho[7], stringsAsFactors = FALSE, colClasses = "character")
stopifnot(!anyNA(a7c$recorte_principal), identical(a7a$ano, as.character(2013:2023)))
for (ce in names(SK)) {
  for (i in seq_len(NR)) if (!mascarado(a7c[[ce]][i])) addP(aP(i, 3:15, SK[[ce]]$s, SK[[ce]]$k), as.numeric(a7c[[ce]][i]), paste("A7 por concentração (F6)", ce))
  if (!any(mascarado(a7c[[ce]]))) addP(aP(1:NR, 3:15, SK[[ce]]$s, SK[[ce]]$k), sum(as.numeric(a7c[[ce]])), paste("A7 26 somadas (F8)", ce))
  if (ce %in% names(a7a)) for (j in seq_len(nrow(a7a))) if (!mascarado(a7a[[ce]][j]))
    addP(aP(1:NR, as.integer(a7a$ano[j]) - 2009L, SK[[ce]]$s, SK[[ce]]$k), as.numeric(a7a[[ce]][j]), paste("A7 por ano (F7)", ce))
}
for (y in 2012:2024) {
  pp <- anos_ptb(y)
  addP(aP(1:NR, pp, 1:4, 1:3), vP(1:NR, pp, 1:4), "totais anuais NV (F9 §5, F10–F12)")
  addP(aP(1:NR, pp, 1:3, 1:3), vP(1:NR, pp, 1:3), "totais anuais PTB")
  for (s in 1:3) addP(aP(1:NR, pp, s, 1:3), vP(1:NR, pp, s), "totais anuais, subtipo do PTB (F10–F12)")
  for (cn in conc_a3) { ri <- match(cn, nome[REC])
    addP(aP(ri, pp, 1:3, 1:3), vP(ri, pp, 1:3), "conciliações §A3 PTB por ano (F14)")
    addP(aP(ri, pp, 1:4, 1:3), vP(ri, pp, 1:4), "conciliações §A3 NV por ano, tirado do % PTB (F14; conservador)") }
}
for (i in seq_len(NR)) { addP(aP(i, 1L, 1:4, 1:3), 0, "Q5: 0 NV antes de 2012-01-04 (F15)"); addP(aP(i, 17L, 1:3, 1:3), 0, "Q5: 0 PTB depois de 2024-11-15 (F15)") }
gP <- expand.grid(r = 1:NR, p = 1:NP, s = 1:4)
coordsP <- lapply(seq_len(nrow(gP)), function(i) aP(gP$r[i], gP$p[i], gP$s[i], 1:3))
cvalP <- VP[cbind(gP$r, gP$p, gP$s)]
pvP <- prova(rowsP, valP, nP, coordsP, ub = cvalP, valor_coord = cvalP)
if (!is.null(pvP$erro)) para("PTB:", pvP$erro)

# ---------------------------------------------------------------- perinatal: átomos r × trecho (17) × tipo t (6)
# t: 1 fetal sem anomalia, 2 fetal com anomalia, 3 neonatal sem anomalia ≤ 24 h, 4 neonatal sem anomalia > 24 h,
#    5 neonatal com anomalia ≤ 24 h, 6 neonatal com anomalia > 24 h. Os valores por tipo não estão na série (só as margens);
#    cada parcela tem limite superior pelas margens, e o valor de toda união identificável vem das somas publicadas.
TT <- list(fetal = 1:2, neo = 3:6, per = 1:6, ate24h = c(3L, 5L), per24h = c(1L, 2L, 3L, 5L), semanom = c(1L, 3L, 4L))
aD <- function(rr, pp, tt) { g <- expand.grid(rr = rr, pp = pp, tt = tt); g$rr + NR * (g$pp - 1L) + NR * NP * (g$tt - 1L) }
nD <- NR * NP * 6L
rowsD <- list(); valD <- numeric(); rotD <- character()
addD <- function(ix, v, rot) { rowsD[[length(rowsD) + 1]] <<- ix; valD <<- c(valD, v); rotD <<- c(rotD, rot) }
vD <- function(m, rr, pp) sum(MD[[m]][rr, pp])
for (i in seq_len(NR)) {
  addD(aD(i, 1:16, 1:6), vD("per", i, 1:16), "A5.2 perinatal total 2012–2024 (F1, F3, F4, F9 §6, F10, F11, F13)")
  addD(aD(i, 3:15, 1:6), vD("per", i, 3:15), "A5.2 perinatal na janela principal (F1)")
  addD(aD(i, c(1, 2, 16), 1:6), vD("per", i, c(1, 2, 16)), "A5.2 perinatal perda principal (F1)")
  addD(aD(i, 2:16, 1:6), vD("per", i, 2:16), "A5.2 perinatal na janela de evento possível (F1)")
  addD(aD(i, 1L, 1:6), vD("per", i, 1L), "A5.2 perinatal perda de evento possível (F1)")
  addD(aD(i, 17L, 3:6), 0, "Q6: 0 neonatal da coorte nascido de 25 a 31/12/2024 (F15)")
}
for (y in 2012:2024) {
  for (m in names(TT)) { pp <- anos_per(y, m != "fetal"); addD(aD(1:NR, pp, TT[[m]]), vD(m, 1:NR, pp), paste("totais anuais", m, "(F9 §5, F10–F12, F14 §A2)")) }
  for (cn in conc_a3) { ri <- match(cn, nome[REC])
    addD(aD(ri, anos_per(y, FALSE), TT$fetal), vD("fetal", ri, anos_per(y, FALSE)), "conciliações §A3 fetal por ano (F14)")
    addD(aD(ri, anos_per(y, TRUE), TT$neo), vD("neo", ri, anos_per(y, TRUE)), "conciliações §A3 neonatal por ano (F14)") }
}
gD <- expand.grid(r = 1:NR, p = 1:NP, t = 1:6)
coordsD <- lapply(seq_len(nrow(gD)), function(i) aD(gD$r[i], gD$p[i], gD$t[i]))
mg <- function(m) MD[[m]][cbind(gD$r, gD$p)]
com <- mg("per") - mg("semanom"); gt24 <- mg("neo") - mg("ate24h")
ubD <- ifelse(gD$t == 1, pmin(mg("fetal"), mg("semanom")), ifelse(gD$t == 2, pmin(mg("fetal"), com),
       ifelse(gD$t == 3, pmin(mg("ate24h"), mg("semanom")), ifelse(gD$t == 4, pmin(gt24, mg("semanom")),
       ifelse(gD$t == 5, pmin(mg("ate24h"), com), pmin(gt24, com))))))
ubD[gD$p == 17 & gD$t >= 3] <- 0                               # censurado; a Q6 publica 0
ubD[gD$p == 17 & gD$t <= 2] <- mg("fetal")[gD$p == 17 & gD$t <= 2]
pvD <- prova(rowsD, valD, nD, coordsD, ub = ubD)
if (!is.null(pvD$erro)) para("perinatal:", pvD$erro)

# ---------------------------------------------------------------- separar a ponta de 2012 da de 2024 (exemplo do prompt)
pontas <- function(pv, a, s_all, conc_ou_todas) {
  vapply(conc_ou_todas, function(rr) { c(p2012 = pv$res2(unique(a(rr, 1:2, s_all))) < 1e-8, p2024 = pv$res2(unique(a(rr, 16:17, s_all))) < 1e-8) }, c(TRUE, TRUE))
}
aPk <- function(rr, pp, ss) aP(rr, pp, ss, 1:3)
pt_ptb <- pontas(pvP, aPk, 1:3, as.list(seq_len(NR))); pt_ptb26 <- pontas(pvP, aPk, 1:3, list(1:NR))
pt_per <- pontas(pvD, aD, 1:6, as.list(seq_len(NR))); pt_per26 <- pontas(pvD, aD, 1:6, list(1:NR))
n_sep <- sum(pt_ptb) + sum(pt_ptb26) + sum(pt_per) + sum(pt_per26)
ctl_perda <- all(vapply(seq_len(NR), function(i) pvP$res2(aP(i, c(1, 2, 16, 17), 1:3, 1:3)) < 1e-8 && pvD$res2(aD(i, c(1, 2, 16), 1:6)) < 1e-8, TRUE))
cat("PTB: furos", pvP$furos, "| perinatal: furos", pvD$furos, "| pontas separáveis:", n_sep, "| perda identificável (controle):", ctl_perda, "\n")

# ================================================================ 5. resultado e log
ok_tudo <- n19 == 0 && pvP$furos == 0 && pvD$furos == 0 && n_sep == 0 && ctl_perda
frase <- if (ok_tudo) sprintf(paste0("As quatro condições do desvio 9 se mantêm na Fase 0 refeita: a coluna \"Perda\" da A5.2 não tem célula de 1 a 9 ",
  "(a menor perda diferente de zero é %s, %s; as perdas da janela de evento possível são 0 por desenho), e nenhuma combinação das %d fontes listadas ",
  "isola contagem menor que 10 dentro das pontas fora da janela, nem separa a ponta de 2012 da de 2024, por concentração ou nas 26 somadas."),
  br(min_nz), quem_min, nrow(fontes)) else "**Alguma condição do desvio 9 falhou: a coluna \"Perda\" deve sair como \"<10\", com supressão complementar, e Guilherme precisa ser avisado.**"
desc_pv <- function(pv, nome_d) c(
  sprintf("- **%s:** %s linhas publicadas no modelo; átomos com zero conhecido (somas publicadas = 0, zeros da Q5/Q6 e fechamento): %s, cada um como linha própria; posto do sistema com os zeros: %d.", nome_d, br(pv$n_rows), br(pv$n_zeros), pv$rank),
  sprintf("  - **Parcelas que podem valer de 1 a 9 (J):** %s; núcleo de H em J: dimensão %d, em %d bloco(s)%s.", br(pv$J), pv$d, length(pv$blocos),
          if (length(pv$blocos)) paste0(" (tamanho × dimensão: ", paste(vapply(pv$blocos, function(b) paste0(b[["tam"]], " × ", b[["dim"]]), ""), collapse = "; "), ")") else ""),
  sprintf("  - **Uniões identificáveis dentro de J:** %d; por valor: %s. **Com valor de 1 a 9: %d.**", length(pv$unioes),
          if (length(pv$vals)) paste(names(table(classe(pv$vals))), table(classe(pv$vals)), sep = " → ", collapse = "; ") else "—", pv$furos),
  paste0("  - ", pv$hist))
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
md <- c("# A8: reconferência das condições do desvio 9 (coluna \"Perda\" da A5.2), Fase 0 refeita", "",
        sprintf("- **Gerado por:** `00_scripts/10_desvio9_rerun.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        "- **Só agregados:** séries diárias por concentração (`serie_diaria(nivel = \"recorte\", coorte_fixa = TRUE)`) e as tabelas publicadas. Nenhum microdado; nenhuma exposição.",
        "- **Condições (decisões §6, pelo prompt da Fase 0 refeita):** vale só para a coluna \"Perda\" da A5.2, na RESPOSTA de 08/10 e na refeita; nenhuma célula de 1 a 9; nenhuma contagem menor que 10 recuperável por subtração contra outra tabela; reconferido aqui.", "",
        "## Resultado", "", frase, "",
        "## 1. Coluna \"Perda\" da A5.2 refeita", "",
        sprintf("- **Fonte:** `01_saidas/fase0_rerun/a5_2_eventos_janelas.csv`; SHA-256 igual ao da Fase 0A (`01_saidas/fase0/a5_2_eventos_janelas.csv`): %s.", if (igual_0A) "sim" else "**NÃO**"),
        sprintf("- **Células de 1 a 9:** %d (esperado 0). **Menor perda diferente de zero:** %s (%s); na Fase 0A, 40.", n19, br(min_nz), quem_min), "",
        tabela_md(tab_perda), "",
        "- **Perdas = 0 na janela de evento possível:** são zeros por desenho da coorte fixa (Q5 da base: nenhum PTB ou NV antes de 2012-01-04, nenhum PTB depois de 2024-11-15; o perinatal depois de 2024-12-24 é NA por censura). Zero não é contagem de 1 a 9.", "",
        "## 2. Fontes (todas as tabelas publicadas na Forja com contagens de PTB ou de óbito perinatal da mesma população, por concentração ou das 26 somadas)", "",
        tabela_md(data.frame(`Nº` = fontes$n, Arquivo = paste0("`", sub("^/Volumes/Forja/Doc/", "", fontes$caminho), "`"),
                             `SHA-256` = paste0("`", fontes$sha, "`"), Conteúdo = fontes$conteudo, `Na prova` = fontes$tratamento, check.names = FALSE)), "",
        "## 3. Conferência: os números publicados que entram na prova = série nos trechos do modelo", "",
        tabela_md(data.frame(Conferência = conf$conferencia, Resultado = ifelse(conf$ok, "bate", "**NÃO bate**"))), "",
        "## 4. Prova por código", "",
        "- **Trechos do calendário (1 a 17), por desfecho:** PTB: 2012-01-01..01-03 (q1), 2012-01-04..04-13 (q2), 2012-04-14..12-31 (parte de 2012 na janela), 2013 a 2023, 2024-01-01..08-06 (parte de 2024 na janela), 2024-08-07..11-15 (q3), 2024-11-16..12-31 (q4). Perinatal: q2 = 2012-01-04..05-25, parte de 2012 na janela a partir de 2012-05-26, q3 = 2024-08-07..12-24, q4 = 2024-12-25..12-31 (censura). As **pontas** são q1, q2, q3 e q4.",
        "- **Átomos:** PTB: concentração (26) × trecho (17) × subtipo (extremo, muito, moderado-tardio, não PTB) × nível da DUM da A7 (3) = 5.304. Perinatal: concentração × trecho × tipo (fetal ou neonatal ≤ 24 h ou > 24 h, com ou sem anomalia; 6) = 2.652. Cada tabela publicada é uma soma de átomos com coeficiente 1.",
        "- **Contagem candidata:** qualquer união de parcelas (PTB: concentração × trecho × subtipo; perinatal: concentração × trecho × tipo), em qualquer combinação de concentrações e trechos, inclusive as pontas, uma de cada vez ou juntas. Só pode valer de 1 a 9 se cada parcela dela valer no máximo 9; essas formam J (perinatal: pelo limite que as margens publicadas dão a cada tipo).",
        "- **Método:** uma união é recuperável por subtração (combinação linear das tabelas) se, e só se, o indicador dela está no espaço das linhas publicadas. Em J, isso é x'Hx = 0, com H = diag(nº de átomos da parcela) − (TᵀQ)(TᵀQ)ᵀ, onde Q é uma base ortonormal do espaço das linhas. O núcleo de H é separado em blocos de suporte disjunto (o projetor é bloco-diagonal), e cada bloco é enumerado inteiro (até 18 parcelas) ou, se tem dimensão 1, testado pela união do bloco. Assim, a busca cobre **todas** as uniões de parcelas de J, não só uma lista de exemplos. **Não negatividade:** uma soma publicada ou identificável que vale 0 zera cada átomo dela, e o zero entra como linha conhecida; o passo se repete até não aparecer zero novo.", "",
        desc_pv(pvP, "PTB"), "", desc_pv(pvD, "Perinatal"), "",
        sprintf("- **Separar a ponta de 2012 da de 2024 (exemplo do prompt):** a ponta de 2012 (q1 + q2) ou a de 2024 (q3 + q4), sozinha, é identificável em %d de %d casos (26 concentrações + as 26 somadas, × 2 pontas, × 2 desfechos). Controle: a perda principal de cada concentração (q1 + q2 + q3 + q4), que é publicada, é identificável nos dois desfechos: %s.",
                n_sep, 2 * 2 * (NR + 1), if (ctl_perda) "sim" else "**NÃO**"), "",
        "### Tabelas que não entram no modelo, e por quê", "",
        "- **Outra população, com átomos próprios** (sem coorte fixa; óbitos sem IG; NV múltiplos; NV de 43–44 semanas; PIG, que soma NV a termo da coorte de 37 semanas com peso válido; 2011 de sensibilidade): cada uma soma átomos que só aparecem nas tabelas dessa mesma população (por concentração, por ano ou as duas). Numa combinação que identifique só átomos da população principal, esses átomos têm de se cancelar; quando a população tem tabela por concentração e por ano, o único cancelamento é a identidade soma das concentrações = soma dos anos, que não diz nada da população principal. Então essas tabelas não acrescentam nada. (Os NV de 43–44 semanas aparecem também na Tabela 1b do RESPOSTA da base, que o `12_…` trata.)",
        "- **Indexado no óbito** (`*_idx_obito`, por ano, 26 somadas): difere do indexado na data-índice só pelos óbitos neonatais que atravessam a virada do ano (fluxo para o ano seguinte, átomo exclusivo desse par de colunas). A cadeia identifica cada fluxo anual; classe de cada um, sem exibir valor: %FLUXOS%. Nenhum fluxo cai nas pontas: o de 2011 para 2012 é 0 (coorte fixa) e o de 2024 para 2025 é 0 (Q6).",
        "- **Por semana de IG** (Q8 e Q11, 2012–2024, 26 somadas) e **PTB por `GESTACAO`** (Q9b, 2012 e 2013, 26 somadas): publicam todas as categorias de uma variável que nenhuma outra tabela usa. O espaço das linhas fica invariante a permutar essas categorias, e as contagens candidatas somam a variável; pela média sobre as permutações (operador de Reynolds), essas tabelas só identificam o que a margem delas já identifica, e a margem (totais de 2012–2024 ou do ano) está no modelo.",
        "- **RESPOSTA da base (`ig_dum_sem`), §6:** NV por ano e por disponibilidade da DUM; nenhuma contagem de PTB nem de óbito. A relação dela com a A7 é conferida no `12_autoauditoria_itens_novos_rerun.R`.",
        "", sprintf("`versao()` no fim: %s.", v_fim))
# fluxos neonatais que atravessam a virada do ano (só a classe)
fl <- cumsum(ta$obito_neonatal_precoce - ta$obito_neonatal_precoce_idx_obito)
md <- sub("%FLUXOS%", paste(sprintf("%d: %s", 2012:2024, classe(fl)), collapse = "; "), md, fixed = TRUE)
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "\n", frase, "\n")
if (!ok_tudo) quit(status = 1)
