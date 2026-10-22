# 09_populacao_dum_rerun.R — Fase 0 refeita (base 4443971b), A7: população da sensibilidade da §3.5 (IG pela DUM).
# Descritivo: contagens de NV e PTB por concentração e por disponibilidade/concordância da DUM. Nenhum desfecho é
# cruzado com exposição, estação, mês ou macrorregião.
#
# População = a do PTB: pop_ptb (único, ga_sem 22–42) & coorte_fixa_22, nas 26 concentrações, parto na janela principal
# (2012-04-14 a 2024-08-06). A IG é o ga_sem (a coluna que a definição do ptb usa; faz o papel do SEMAGESTAC).
#   (a) todos;  (b) ig_dum_sem de 20 a 45, inclusive;  (c) (b) e |ga_sem − ig_dum_sem| ≤ 1.
# Saídas: por concentração (janela inteira) e por ano, com as 26 somadas, só de 2013 a 2023 (decisão de Guilherme,
# 09/10/2026: 2012 e 2024 não são anos inteiros na janela). Nenhuma contagem por concentração × ano sai.
# Reconciliação (para se falhar): (a) por concentração = série diária na janela = "Na janela" da A5.2 (PTB); (a) por
# ano = série diária = logs/totais_anuais.csv da base; e cada concentração × período interno = série diária.
# Sigilo: "<10" e supressão complementar; o (a) do PTB já é público (A5.2) e o (a) por ano também (totais anuais).
# Prova: identificabilidade linear (posto) num modelo de átomos com todas as tabelas publicadas que tocam esta população.
# Microdado: só agregado em memória; nada em nível de registro é exibido nem gravado. Grava só CSV já mascarados.
# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/09_populacao_dum_rerun.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
BASE <- "/Volumes/Forja/Doc/dados_artigos_perinatais_clima"
hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
saida <- file.path("01_saidas", "fase0_rerun"); stopifnot(dir.exists(saida))
csv_conc <- file.path(saida, "a7_populacao_dum_concentracao.csv"); csv_ano <- file.path(saida, "a7_populacao_dum_ano.csv")
arq <- file.path("logs", paste0("populacao_dum_fase0_rerun_", hoje, ".md"))
stopifnot(!file.exists(csv_conc), !file.exists(csv_ano), !file.exists(arq))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
zero_ou_para <- function(n, o_que) if (n == 0) "0" else { cat("DIVERGÊNCIA em", o_que, "(contagem não exibida): parar e reportar.\n"); quit(status = 1) }
D <- as.Date; JI <- D("2012-04-14"); JF <- D("2024-08-06"); ANOS <- 2013:2023

# ---------------------------------------------------------------- concentrações (ordem fixa = cidade_nucleo())
nuc <- as.data.frame(cidade_nucleo()); REC <- nuc$CD_RECORTE; nome <- setNames(nuc$NM_RECORTE, REC); NR <- length(REC)
mun <- as.data.frame(concentracoes())[, c("CD_RECORTE", "CD_MUN6")]
stopifnot(NR == 26, nrow(mun) == 277, !anyDuplicated(mun$CD_MUN6), setequal(unique(mun$CD_RECORTE), REC))

# ---------------------------------------------------------------- microdado → átomos (só contagens em memória)
# átomo = concentração r (26) × período p (13: 1 = 2012-04-14..2012-12-31; 2..12 = 2013..2023; 13 = 2024-01-01..2024-08-06)
#         × o (1 = PTB, 2 = não PTB) × k (1 = c: DUM plausível e concordante; 2 = d: plausível e discordante; 3 = e: sem DUM plausível)
n <- nascimentos(c("CD_MUN6", "data", "unico", "ga_sem", "pop_ptb", "ptb", "coorte_fixa_22", "ig_dum_sem"))
n$data <- as.Date(n$data)
def_pop <- sum(xor(n$pop_ptb %in% TRUE, (n$unico & n$ga_sem >= 22 & n$ga_sem <= 42) %in% TRUE))
pop <- (n$pop_ptb & n$coorte_fixa_22) %in% TRUE & n$data >= JI & n$data <= JF
def_ptb <- sum(xor(n$ptb[pop] %in% TRUE, (n$ga_sem[pop] <= 36) %in% TRUE))
ga <- n$ga_sem[pop]; ig <- n$ig_dum_sem[pop]; dt <- n$data[pop]; ptb <- n$ptb[pop] %in% TRUE
r <- match(mun$CD_RECORTE[match(n$CD_MUN6[pop], mun$CD_MUN6)], REC)
rm(n); invisible(gc())
na_r <- sum(is.na(r)); na_ga <- sum(is.na(ga))
invisible(c(zero_ou_para(def_pop, "pop_ptb × (unico & ga_sem 22–42)"), zero_ou_para(def_ptb, "ptb × (pop_ptb & ga_sem ≤ 36)"),
            zero_ou_para(na_r, "município fora das 26 concentrações"), zero_ou_para(na_ga, "ga_sem NA na população")))
b <- !is.na(ig) & ig >= 20 & ig <= 45
cc <- b & abs(as.integer(ga) - as.integer(ig)) <= 1
k <- ifelse(cc, 1L, ifelse(b, 2L, 3L)); o <- ifelse(ptb, 1L, 2L)
p <- findInterval(as.numeric(dt), as.numeric(D(paste0(2013:2024, "-01-01")))) + 1L
stopifnot(all(p %in% 1:13))
A <- array(tabulate(r + NR * (p - 1L) + NR * 13L * (o - 1L) + NR * 26L * (k - 1L), NR * 13L * 2L * 3L), c(NR, 13, 2, 3))
n_pop <- length(r); rm(ga, ig, dt, ptb, r, b, cc, k, o, p); invisible(gc())
stopifnot(sum(A) == n_pop)

# ---------------------------------------------------------------- tabelas verdadeiras (só em memória)
niv <- list(a = 1:3, b = 1:2, c = 1L)
conc <- data.frame(recorte_principal = REC, concentracao = unname(nome[REC]), stringsAsFactors = FALSE)
for (L in names(niv)) {
  conc[[paste0("nv_", L)]] <- apply(A[, , , niv[[L]], drop = FALSE], 1, sum)
  conc[[paste0("ptb_", L)]] <- apply(A[, , 1, niv[[L]], drop = FALSE], 1, sum)
}
ano <- data.frame(ano = ANOS)
for (L in c("a", "c")) {
  ano[[paste0("nv_", L)]] <- apply(A[, 2:12, , niv[[L]], drop = FALSE], 2, sum)
  ano[[paste0("ptb_", L)]] <- apply(A[, 2:12, 1, niv[[L]], drop = FALSE], 2, sum)
}

# ---------------------------------------------------------------- reconciliação (para se falhar)
sd <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "nv_unicos", "ptb")))
sd$data <- as.Date(sd$data); sd <- sd[sd$data >= JI & sd$data <= JF, ]
sd$p <- findInterval(as.numeric(sd$data), as.numeric(D(paste0(2013:2024, "-01-01")))) + 1L
sd$r <- match(sd$recorte_principal, REC); stopifnot(!anyNA(sd$r), !anyNA(sd$nv_unicos), !anyNA(sd$ptb))
s_nv <- tapply(sd$nv_unicos, list(factor(sd$r, 1:NR), factor(sd$p, 1:13)), sum)
s_ptb <- tapply(sd$ptb, list(factor(sd$r, 1:NR), factor(sd$p, 1:13)), sum)
rc <- c(conc_nv = all(conc$nv_a == rowSums(s_nv)), conc_ptb = all(conc$ptb_a == rowSums(s_ptb)),
        cel_nv = all(apply(A, 1:2, sum) == s_nv), cel_ptb = all(apply(A[, , 1, ], 1:2, sum) == s_ptb))
a52 <- read.csv(file.path(saida, "a5_2_eventos_janelas.csv"), stringsAsFactors = FALSE, colClasses = c(recorte_principal = "character"))
a52 <- a52[a52$desfecho == "ptb" & a52$janela == "principal", ]
rc["a52_na_janela"] <- nrow(a52) == NR && all(conc$ptb_a == a52$eventos_janela[match(REC, a52$recorte_principal)])
ta <- read.csv(file.path(BASE, "logs", "totais_anuais.csv"), stringsAsFactors = FALSE)
ta <- ta[ta$versao == "principal", ]
rc["ano_serie"] <- all(ano$nv_a == colSums(s_nv)[2:12]) && all(ano$ptb_a == colSums(s_ptb)[2:12])
rc["ano_totais_anuais"] <- all(ano$nv_a == ta$nv_unicos[match(ANOS, ta$ano)]) && all(ano$ptb_a == ta$ptb[match(ANOS, ta$ano)])
print(rc)
if (!all(rc)) { cat("RECONCILIAÇÃO DA A7 FALHOU: parar e explicar antes de seguir.\n"); quit(status = 1) }

# ---------------------------------------------------------------- supressão (gulosa por linha, local) e prova global
# Átomos locais de uma linha (soma no período da linha): ptb_c, ptb_d, ptb_e, non_c, non_d, non_e.
LOC <- rbind(nv_a = c(1, 1, 1, 1, 1, 1), nv_b = c(1, 1, 0, 1, 1, 0), nv_c = c(1, 0, 0, 1, 0, 0),
             ptb_a = c(1, 1, 1, 0, 0, 0), ptb_b = c(1, 1, 0, 0, 0, 0), ptb_c = c(1, 0, 0, 0, 0, 0))
SUB <- as.matrix(expand.grid(rep(list(0:1), 6)))[-1, ]; dimnames(SUB) <- NULL       # 63 combinações não vazias (das 64)
posto <- function(M) if (length(M) == 0 || nrow(M) == 0) 0L else qr(M, tol = 1e-9)$rank
ident_loc <- function(v, R) posto(rbind(R, v)) == posto(R)
mascara <- function(at6, cel, ordem) {           # cel: células da linha; ordem: quem pode sair, nessa ordem
  pub <- cel
  repeat {
    vaz <- SUB %*% at6; peq <- which(vaz > 0 & vaz < 10)
    furo <- any(vapply(peq, function(i) ident_loc(SUB[i, ], LOC[pub, , drop = FALSE]), TRUE))
    if (!furo) return(setdiff(cel, pub))
    sai <- intersect(ordem, pub)
    if (!length(sai)) { cat("Supressão local não fecha: parar e reportar.\n"); quit(status = 1) }
    pub <- setdiff(pub, sai[1])
  }
}
at_linha <- function(Asub) c(sum(Asub[, , 1, 1]), sum(Asub[, , 1, 2]), sum(Asub[, , 1, 3]), sum(Asub[, , 2, 1]), sum(Asub[, , 2, 2]), sum(Asub[, , 2, 3]))
m_conc <- lapply(seq_len(NR), function(i) mascara(at_linha(A[i, , , , drop = FALSE]), rownames(LOC), c("ptb_b", "nv_b", "ptb_c", "nv_c", "nv_a")))
m_ano <- lapply(2:12, function(pp) mascara(at_linha(A[, pp, , , drop = FALSE]), c("nv_a", "nv_c", "ptb_a", "ptb_c"), c("ptb_c", "nv_c")))
oculta <- function(cel, lista) vapply(lista, function(m) cel %in% m, TRUE)
# linha "26 somadas" da tabela por concentração: só publica a coluna que não tem célula suprimida
tot_pub <- setNames(vapply(rownames(LOC), function(ce) !any(oculta(ce, m_conc)), TRUE), rownames(LOC))

# modelo global de átomos: janela W[r, p, o, k] (2.028) + pontas fora da janela O[r, q, o] (208), q = 1: 2012-01-01..01-03;
# 2: 2012-01-04..04-13; 3: 2024-08-07..11-15; 4: 2024-11-16..12-31
NW <- NR * 13L * 2L * 3L; NA_ <- NW + NR * 4L * 2L
Wi <- function(rr, pp, oo, kk) { g <- expand.grid(rr = rr, pp = pp, oo = oo, kk = kk)
  g$rr + NR * (g$pp - 1L) + NR * 13L * (g$oo - 1L) + NR * 26L * (g$kk - 1L) }
Oi <- function(rr, qq, oo) { g <- expand.grid(rr = rr, qq = qq, oo = oo); NW + g$rr + NR * (g$qq - 1L) + NR * 4L * (g$oo - 1L) }
OK_ <- list(nv_a = list(o = 1:2, k = 1:3), nv_b = list(o = 1:2, k = 1:2), nv_c = list(o = 1:2, k = 1L),
            ptb_a = list(o = 1L, k = 1:3), ptb_b = list(o = 1L, k = 1:2), ptb_c = list(o = 1L, k = 1L))
linhas <- list(); rot <- character()
pub_linha <- function(idx, rotulo) { v <- numeric(NA_); v[idx] <- 1; linhas[[length(linhas) + 1]] <<- v; rot <<- c(rot, rotulo) }
for (i in seq_len(NR)) for (ce in setdiff(rownames(LOC), m_conc[[i]])) pub_linha(Wi(i, 1:13, OK_[[ce]]$o, OK_[[ce]]$k), paste("A7 conc", REC[i], ce))
for (ce in names(tot_pub)[tot_pub]) pub_linha(Wi(1:NR, 1:13, OK_[[ce]]$o, OK_[[ce]]$k), paste("A7 26 somadas", ce))
for (j in seq_along(ANOS)) for (ce in setdiff(c("nv_a", "nv_c", "ptb_a", "ptb_c"), m_ano[[j]])) pub_linha(Wi(1:NR, j + 1L, OK_[[ce]]$o, OK_[[ce]]$k), paste("A7 ano", ANOS[j], ce))
for (i in seq_len(NR)) {                         # A5.2 do PTB (Fase 0A, complemento e esta rodada), ENTREGA §6, criterios_inclusao
  pub_linha(c(Wi(i, 1:13, 1L, 1:3), Oi(i, 1:4, 1L)), paste("A5.2 total 2012–2024", REC[i]))
  pub_linha(Wi(i, 1:13, 1L, 1:3), paste("A5.2 na janela principal", REC[i]))
  pub_linha(Oi(i, 1:4, 1L), paste("A5.2 perda principal", REC[i]))
  pub_linha(c(Wi(i, 1:13, 1L, 1:3), Oi(i, 2:3, 1L)), paste("A5.2 na janela de evento possível", REC[i]))
  pub_linha(Oi(i, c(1L, 4L), 1L), paste("A5.2 perda de evento possível", REC[i]))
}
for (oo in list(nv = 1:2, ptb = 1L)) for (y in 2012:2024) {   # totais anuais das 26 (base: totais_anuais.csv, ENTREGA §5, relatórios)
  idx <- if (y == 2012) c(Wi(1:NR, 1L, oo, 1:3), Oi(1:NR, 1:2, oo)) else if (y == 2024) c(Wi(1:NR, 13L, oo, 1:3), Oi(1:NR, 3:4, oo)) else Wi(1:NR, y - 2011L, oo, 1:3)
  pub_linha(idx, paste("totais anuais", y, if (length(oo) == 2) "nv" else "ptb"))
}
M <- do.call(rbind, linhas)
qm <- qr(t(M), tol = 1e-9); Q <- qr.Q(qm)[, seq_len(qm$rank), drop = FALSE]
resid2 <- function(idx) length(idx) - sum(colSums(Q[idx, , drop = FALSE])^2)       # idx sem repetição; 0 = identificável
ident <- function(idx) resid2(idx) < 1e-8
# candidatos: grupos de células (r, p) × 63 combinações de (o, k)
OKP <- list(c(1, 1), c(1, 2), c(1, 3), c(2, 1), c(2, 2), c(2, 3))
grupos <- c(lapply(seq_len(NR), function(i) list(r = i, p = 1:13, g = "concentração, janela inteira")),
            lapply(2:12, function(pp) list(r = 1:NR, p = pp, g = "ano, 26 somadas")),
            list(list(r = 1:NR, p = 1L, g = "ponta de 2012 dentro da janela, 26 somadas"),
                 list(r = 1:NR, p = 13L, g = "ponta de 2024 dentro da janela, 26 somadas"),
                 list(r = 1:NR, p = c(1L, 13L), g = "pontas de 2012 + 2024 dentro da janela, 26 somadas"),
                 list(r = 1:NR, p = 1:13, g = "26 somadas, janela inteira")),
            lapply(seq_len(NR), function(i) list(r = i, p = c(1L, 13L), g = "concentração, pontas de 2012 + 2024")),
            unlist(lapply(seq_len(NR), function(i) lapply(1:13, function(pp) list(r = i, p = pp, g = "concentração × período"))), recursive = FALSE))
res <- do.call(rbind, lapply(grupos, function(G) {
  t(vapply(seq_len(nrow(SUB)), function(s) {
    ks <- OKP[SUB[s, ] == 1]
    idx <- unlist(lapply(ks, function(x) Wi(G$r, G$p, x[1], x[2])))
    c(valor = sum(A[idx]), id = ident(idx))
  }, c(valor = 0, id = 0)))
}))
g_rot <- rep(vapply(grupos, `[[`, "", "g"), each = nrow(SUB))
peq <- res[, "valor"] > 0 & res[, "valor"] < 10
furos <- sum(peq & res[, "id"] == 1)
cat("candidatos:", nrow(res), "| com valor de 1 a 9:", sum(peq), "| identificáveis entre esses:", furos, "\n")
# controles: toda célula publicada é identificável; toda célula suprimida não é
ctl_pub <- all(vapply(linhas, function(v) ident(which(v == 1)), TRUE))
sup_conc <- unlist(lapply(seq_len(NR), function(i) lapply(m_conc[[i]], function(ce) Wi(i, 1:13, OK_[[ce]]$o, OK_[[ce]]$k))), recursive = FALSE)
sup_ano <- unlist(lapply(seq_along(ANOS), function(j) lapply(m_ano[[j]], function(ce) Wi(1:NR, j + 1L, OK_[[ce]]$o, OK_[[ce]]$k))), recursive = FALSE)
ctl_sup <- !any(vapply(c(sup_conc, sup_ano), ident, TRUE))
n_ident <- sum(res[, "id"] == 1)
if (furos > 0 || !ctl_pub || !ctl_sup) { cat("FURO DE SIGILO OU CONTROLE FALHOU: parar e reportar.\n"); quit(status = 1) }

# ---------------------------------------------------------------- publicação (só mascarado)
cel_txt <- function(x, oculto, fmt) ifelse(oculto, ifelse(x > 0 & x < 10, "<10", "supr."), ifelse(x > 0 & x < 10, "<10", fmt(x)))
pct_txt <- function(num, den, oculto, fmt) ifelse(oculto, "—", fmt(100 * num / den))
plain <- function(x) format(x, scientific = FALSE, trim = TRUE); plain2 <- function(x) sprintf("%.2f", x)
monta_conc <- function(fmt, fmtp) {
  out <- conc[, c("recorte_principal", "concentracao")]
  for (oo in c("nv", "ptb")) {
    out[[paste0(oo, "_a")]] <- cel_txt(conc[[paste0(oo, "_a")]], oculta(paste0(oo, "_a"), m_conc), fmt)
    for (L in c("b", "c")) {
      ce <- paste0(oo, "_", L); oc <- oculta(ce, m_conc)
      out[[ce]] <- cel_txt(conc[[ce]], oc, fmt)
      out[[paste0(ce, "_pct")]] <- pct_txt(conc[[ce]], conc[[paste0(oo, "_a")]], oc | oculta(paste0(oo, "_a"), m_conc), fmtp)
    }
  }
  out
}
monta_ano <- function(fmt, fmtp) {
  out <- data.frame(ano = ANOS)
  for (oo in c("nv", "ptb")) {
    out[[paste0(oo, "_a")]] <- cel_txt(ano[[paste0(oo, "_a")]], oculta(paste0(oo, "_a"), m_ano), fmt)
    ce <- paste0(oo, "_c"); oc <- oculta(ce, m_ano)
    out[[ce]] <- cel_txt(ano[[ce]], oc, fmt)
    out[[paste0(ce, "_pct")]] <- pct_txt(ano[[ce]], ano[[paste0(oo, "_a")]], oc | oculta(paste0(oo, "_a"), m_ano), fmtp)
  }
  out
}
pub_conc <- monta_conc(plain, plain2); pub_ano <- monta_ano(plain, plain2)
write.csv(pub_conc, csv_conc, row.names = FALSE); write.csv(pub_ano, csv_ano, row.names = FALSE)

# ---------------------------------------------------------------- resumo em markdown
bc <- monta_conc(br, function(x) br(x, 2)); ba <- monta_ano(br, function(x) br(x, 2))
tot <- vapply(rownames(LOC), function(ce) sum(conc[[ce]]), 0)
tl <- function(ce) if (tot_pub[[ce]]) br(tot[[ce]]) else "supr."
tp <- function(ce, den) if (tot_pub[[ce]] && tot_pub[[den]]) br(100 * tot[[ce]] / tot[[den]], 2) else "—"
o_ <- order(-conc$ptb_a)
t_conc <- rbind(data.frame(Concentração = bc$concentracao, `NV (a)` = bc$nv_a, `NV (b)` = bc$nv_b, `% (b)` = bc$nv_b_pct,
                           `NV (c)` = bc$nv_c, `% (c)` = bc$nv_c_pct, `PTB (a)` = bc$ptb_a, `PTB (b)` = bc$ptb_b, `% (b) ` = bc$ptb_b_pct,
                           `PTB (c)` = bc$ptb_c, `% (c) ` = bc$ptb_c_pct, check.names = FALSE)[o_, ],
                data.frame(Concentração = "**26 somadas**", `NV (a)` = tl("nv_a"), `NV (b)` = tl("nv_b"), `% (b)` = tp("nv_b", "nv_a"),
                           `NV (c)` = tl("nv_c"), `% (c)` = tp("nv_c", "nv_a"), `PTB (a)` = tl("ptb_a"), `PTB (b)` = tl("ptb_b"),
                           `% (b) ` = tp("ptb_b", "ptb_a"), `PTB (c)` = tl("ptb_c"), `% (c) ` = tp("ptb_c", "ptb_a"), check.names = FALSE))
pct <- function(ce, den) 100 * conc[[ce]] / conc[[den]]
faixa <- function(x, oc) { x <- x[!oc]; if (!length(x)) "—" else
  sprintf("de %s%% a %s%% (%s)", br(min(x), 2), br(max(x), 2), if (length(x) == 26) "26 concentrações" else
    sprintf("nas %d concentrações com a célula publicada; as outras %d estão suprimidas", length(x), 26 - length(x))) }
sup_col <- vapply(rownames(LOC), function(ce) sum(oculta(ce, m_conc)), 0L)
grandes <- min(c(conc$nv_a - conc$nv_b, conc$ptb_a - conc$ptb_b, conc$nv_a - conc$nv_c, conc$ptb_a - conc$ptb_c,
                 ano$nv_a - ano$nv_c, ano$ptb_a - ano$ptb_c)) >= 10
n_sup_conc <- sum(lengths(m_conc)); n_sup_ano <- sum(lengths(m_ano))
mil <- sum(conc$ptb_c >= 1000)
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
md <- c("# A7: população da sensibilidade da §3.5 (IG pela DUM), Fase 0 refeita", "",
        sprintf("- **Gerado por:** `00_scripts/09_populacao_dum_rerun.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        "- **Descritivo, sem exposição:** contagens de NV e PTB por concentração e por ano, por disponibilidade e concordância da DUM. Nenhum desfecho cruzado com temperatura, PM2.5, estação, mês ou macrorregião.",
        "- **População (a do PTB):** `pop_ptb` (único, `ga_sem` de 22 a 42) e `coorte_fixa_22`, residentes nas 26 concentrações (277 municípios), com parto na janela principal, de 2012-04-14 a 2024-08-06. Lida por `nascimentos()`; agregada em memória.",
        sprintf("  - **Conferências da definição (contagem de divergências):** `pop_ptb` × (`unico` e `ga_sem` de 22 a 42) = %s; `ptb` × (`pop_ptb` e `ga_sem` ≤ 36) = %s; município fora das 26 = %s; `ga_sem` NA na população = %s.",
                zero_ou_para(def_pop, ""), zero_ou_para(def_ptb, ""), zero_ou_para(na_r, ""), zero_ou_para(na_ga, "")),
        "- **IG usada (papel do `SEMAGESTAC` na regra de concordância):** `ga_sem`, a coluna que a definição do `ptb` usa (`06b_desfechos.py`: `ptb = pop_ptb & ga_sem <= 36`). Pelo `DICIONARIO.md` (linha 80), o `SEMAGESTAC` está no `ga_sem` (só 22–44) e no `semagestac_bruto` (texto); como a população já é de 22 a 42 semanas, a perda dos SEMAGESTAC 20, 21 e 45 que o `ga_sem` causaria não afeta esta população.",
        "- **Níveis:** **(a)** todos; **(b)** DUM plausível, `ig_dum_sem` de 20 a 45, inclusive; **(c)** (b) e |`ga_sem` − `ig_dum_sem`| ≤ 1. Percentual mantido = nível / (a).",
        "- **Por ano:** só de 2013 a 2023, com as 26 concentrações somadas (decisão de Guilherme, 09/10/2026: 2012 e 2024 não são anos inteiros na janela principal). Nenhuma contagem por concentração × ano sai.",
        "- **CSV (fora do git, já mascarados):** `01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv` e `01_saidas/fase0_rerun/a7_populacao_dum_ano.csv`.", "",
        "## Reconciliação", "",
        tabela_md(data.frame(Conferência = c("(a) por concentração, NV = soma de `nv_unicos` da série diária na janela principal",
                                              "(a) por concentração, PTB = soma de `ptb` da série diária na janela principal",
                                              "(a) PTB por concentração = \"Na janela\" da A5.2 refeita (`a5_2_eventos_janelas.csv`, PTB, principal)",
                                              "Cada concentração × período (26 × 13), NV, = série diária (interno; não sai)",
                                              "Cada concentração × período (26 × 13), PTB, = série diária (interno; não sai)",
                                              "(a) por ano, 2013–2023, NV e PTB = série diária",
                                              "(a) por ano, 2013–2023, NV e PTB = `logs/totais_anuais.csv` da base (`versao` = principal)"),
                             Resultado = ifelse(rc[c("conc_nv", "conc_ptb", "a52_na_janela", "cel_nv", "cel_ptb", "ano_serie", "ano_totais_anuais")], "bate", "**NÃO bate**"))), "",
        "## 1. Por concentração, janela principal inteira", "", tabela_md(t_conc), "",
        sprintf("- **Percentual mantido em (b):** NV %s; PTB %s.", faixa(pct("nv_b", "nv_a"), oculta("nv_b", m_conc)), faixa(pct("ptb_b", "ptb_a"), oculta("ptb_b", m_conc))),
        sprintf("- **Percentual mantido em (c):** NV %s; PTB %s.", faixa(pct("nv_c", "nv_a"), oculta("nv_c", m_conc)), faixa(pct("ptb_c", "ptb_a"), oculta("ptb_c", m_conc))),
        sprintf("- **Concentrações com 1.000 PTB ou mais em (c):** %d de 26%s.", mil,
                if (mil < 26) paste0("; abaixo: ", paste(conc$concentracao[conc$ptb_c < 1000], collapse = ", ")) else ""), "",
        "## 2. Por ano, 26 concentrações somadas (2013–2023)", "",
        tabela_md(data.frame(Ano = ba$ano, `NV (a)` = ba$nv_a, `NV (c)` = ba$nv_c, `% (c)` = ba$nv_c_pct,
                             `PTB (a)` = ba$ptb_a, `PTB (c)` = ba$ptb_c, `% (c) ` = ba$ptb_c_pct, check.names = FALSE)), "",
        "## Sigilo", "",
        "- **Regra:** contagem de 1 a 9 = \"<10\"; supressão complementar (\"supr.\") quando uma diferença entre níveis, ou entre NV e PTB, de 1 a 9 ficaria recuperável. O (a) do PTB por concentração já é público (\"Na janela\" da A5.2), e o (a) por ano também (totais anuais da base); por isso, quando uma diferença é pequena, sai o (b) ou o (c), nunca o (a) do PTB. O \"%\" sai \"—\" quando a célula dele está suprimida.",
        sprintf("- **Supressões aplicadas:** %d célula(s) na tabela por concentração (%s); %d na tabela por ano.%s", n_sup_conc,
                paste(sprintf("`%s` em %d", names(sup_col)[sup_col > 0], sup_col[sup_col > 0]), collapse = ", "), n_sup_ano,
                if (n_sup_conc) paste0(" Na linha \"26 somadas\", a coluna que tem célula suprimida acima também sai \"supr.\": ", paste0("`", names(tot_pub)[!tot_pub], "`", collapse = ", "), ".") else ""),
        sprintf("- **Por que só o (b) sai:** a concordância passa de 99,9%%, então a diferença (b) − (c), DUM plausível e discordante, é a que fica pequena. As diferenças (a) − (b) e (a) − (c), de NV e de PTB, são %s em todas as linhas das duas tabelas (conferido no código).",
                if (grandes) "≥ 10" else "**< 10 em alguma linha**"),
        "- **Prova (identificabilidade linear, por posto):**",
        sprintf("  - **Átomos:** contagens de concentração (26) × período (13: a parte de 2012 na janela, 2013 a 2023, a parte de 2024 na janela) × PTB ou não PTB × nível da DUM (c; plausível e discordante; sem DUM plausível) = %s; mais as pontas fora da janela, por concentração × PTB ou não PTB × 4 trechos (2012-01-01..03, 2012-01-04..04-13, 2024-08-07..11-15, 2024-11-16..12-31) = %s.", br(NW), br(NA_ - NW)),
        sprintf("  - **Tabelas publicadas no modelo (%d linhas, posto %d):** as duas desta A7 (só as células publicadas); a A5.2 do PTB (total 2012–2024, na janela e perda, nas janelas principal e de evento possível), que é também a da Fase 0A, do complemento, da ENTREGA §6 e do `criterios_inclusao_recorte.csv`; e os totais anuais das 26 (NV e PTB, 2012 a 2024), que são os da ENTREGA §5 e do `totais_anuais.csv`.", nrow(M), qm$rank),
        "  - **Tabelas por subtipo** (PTB extremo, muito e moderado-tardio, nos totais anuais): todas as outras tabelas do modelo tratam os três subtipos do mesmo jeito, e os candidatos abaixo também; por simetria, as linhas por subtipo não identificam nada que a linha do PTB já não identifique.",
        sprintf("  - **Candidatos:** %s grupos de células (cada concentração na janela inteira; cada ano de 2013 a 2023; as partes de 2012 e de 2024 na janela, separadas e juntas; as 26 somadas; cada concentração nas duas partes; e cada concentração × período, que não é publicada) × as 63 combinações não vazias (das 64) dos 6 átomos (PTB e não PTB × 3 níveis) = %s somas.", br(length(grupos)), br(nrow(res))),
        sprintf("  - **Resultado:** %s somas têm valor de 1 a 9; identificáveis entre elas: **%d**. Controles: toda célula publicada é identificável (%s); nenhuma célula suprimida é (%s); %s somas candidatas são identificáveis no total, o que mostra que o teste distingue.",
                br(sum(peq)), furos, if (ctl_pub) "sim" else "NÃO", if (ctl_sup) "sim" else "NÃO", br(n_ident)),
        "  - **Combinações entre concentrações:** só as linhas do nível (b) por concentração separam o discordante (d) do sem DUM plausível (e); as linhas por ano, a linha \"26 somadas\" publicada e as tabelas externas trazem d e e sempre juntos. Assim, nenhuma soma de átomos de várias concentrações isola um d além do que a linha de cada concentração já isola, e as linhas por concentração estão todas entre os candidatos.",
        "", sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", csv_conc, ",", csv_ano, "e", arq, "| supressões:", n_sup_conc, "+", n_sup_ano, "| PTB(c) ≥ 1000:", mil, "\n")
