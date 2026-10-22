# 13_conferencia_final_rerun.R — Fase 0 refeita (base 4443971b), A10: correções pedidas pela auditoria independente e
# conferência final antes do retorno.
#   1. Sigilo da A7, prova exaustiva (achado 1 da auditoria independente): no modelo ampliado do 12 (A7, A5.2 do PTB, totais
#      anuais, zeros da Q5, Tabela 1b do RESPOSTA da base com os NV de 43–44 semanas, conciliações §A3), toda união de átomos
#      (concentração × trecho × PTB ou não × nível da DUM, mais as pontas e os NV de 43–44 por ano) que possa valer de 1 a 9 é
#      testada pelo núcleo de H, com fechamento de zeros (o método do 10). E, como o auditor pediu, o discordante (d) de PTB,
#      de não PTB e de NV, somado em todo subconjunto das concentrações com o (b) suprimido.
#   2. Quadro-resumo da §9, pelos itens que o prompt enumera: média e faixa nas 26, valor da Fase 0A e diferença (achado 3).
#   3. Conferências finais, depois de todas as linhas novas do log de desvios (achado 2): numeração e prefixo do log de
#      desvios, prova do grep, versao() no fim de cada log, SHA-256 dos CSV (A6 e Fase 0A), git sem commit.
# Microdado só agregado em memória; contagens de 1 a 9 não saem. Grava logs/conferencia_final_fase0_rerun_<DATA>.md.
# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/13_conferencia_final_rerun.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
RAIZ <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; BASE <- "/Volumes/Forja/Doc/dados_artigos_perinatais_clima"
hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("conferencia_final_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq))
sha256 <- function(f) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(f)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
classe <- function(x) ifelse(x == 0, "0", ifelse(x > 0 & x < 10, "1 a 9", ifelse(x >= 10, "≥ 10", "negativo")))
D <- as.Date; lg <- function(n) file.path("logs", paste0(n, hoje, ".md"))
res <- data.frame()
confere <- function(item, conferencia, esperado, obtido, ok)
  res <<- rbind(res, data.frame(item = item, conferencia = conferencia, esperado = as.character(esperado),
                                obtido = as.character(obtido), ok = isTRUE(ok), stringsAsFactors = FALSE))
nuc <- as.data.frame(cidade_nucleo()); REC <- nuc$CD_RECORTE; nome <- setNames(nuc$NM_RECORTE, REC); NR <- length(REC)

# ================================================================ 1. sigilo da A7: átomos (mesmo caminho independente do 12)
n <- nascimentos(c("CD_MUN6", "data", "unico", "ga_sem", "dum_est", "ig_dum_sem"))
n$data <- as.Date(n$data); n$dum_est <- as.Date(n$dum_est)
coorte <- !is.na(n$dum_est) & n$dum_est >= D("2011-07-31") & n$dum_est <= D("2024-03-05")
bs <- (n$unico %in% TRUE) & coorte & n$data >= D("2012-01-01") & n$data <= D("2024-12-31") & !is.na(n$ga_sem)
popA <- bs & n$ga_sem >= 22 & n$ga_sem <= 42; g43 <- bs & n$ga_sem >= 43 & n$ga_sem <= 44; sel <- popA | g43
cm <- as.data.frame(concentracoes()); dono <- setNames(as.character(cm$CD_RECORTE), as.character(cm$CD_MUN6))
x <- data.frame(rec = unname(dono[as.character(n$CD_MUN6[sel])]), data = n$data[sel], ga = as.integer(n$ga_sem[sel]),
                ig = as.integer(n$ig_dum_sem[sel]), pop = popA[sel], stringsAsFactors = FALSE)
rm(n, coorte, bs, popA, g43, sel); invisible(gc())
stopifnot(!anyNA(x$rec))
x$b <- !is.na(x$ig) & x$ig >= 20 & x$ig <= 45; x$c <- x$b & abs(x$ga - x$ig) <= 1
x$k <- factor(ifelse(x$c, "c", ifelse(x$b, "d", "e")), levels = c("c", "d", "e"))
x$o <- factor(ifelse(x$ga <= 36, "ptb", "non"), levels = c("ptb", "non")); x$r <- factor(x$rec, levels = REC)
cortes <- D(c("2012-01-04", "2012-04-14", paste0(2013:2024, "-01-01"), "2024-08-07", "2024-11-16"))
x$t <- factor(findInterval(as.numeric(x$data), as.numeric(cortes)), levels = 0:16)   # 0 q1, 1 q2, 2 E12, 3..13 = 2013..2023, 14 E24, 15 q3, 16 q4
xp <- x[x$pop, ]; xg <- x[!x$pop, ]
TT <- table(xp$r, xp$t, xp$o, xp$k); GG <- table(factor(format(xg$data, "%Y"), levels = 2012:2024), xg$k)
rm(x, xp, xg); invisible(gc())
TW <- as.character(2:14); TO <- as.character(c(0, 1, 15, 16)); KK <- c("c", "d", "e"); OO <- c("ptb", "non")
anos <- 2013:2023; tano <- as.character(anos - 2010L)
iW <- function(r, t, o, k) { g <- expand.grid(r = r, t = match(t, TW), o = match(o, OO), k = match(k, KK)); g$r + 26L * (g$t - 1L) + 338L * (g$o - 1L) + 676L * (g$k - 1L) }
iO <- function(r, q, o, k) { g <- expand.grid(r = r, q = match(q, TO), o = match(o, OO), k = match(k, KK)); 2028L + g$r + 26L * (g$q - 1L) + 104L * (g$o - 1L) + 208L * (g$k - 1L) }
iG <- function(y, k) { g <- expand.grid(y = y, k = match(k, KK)); 2652L + (g$y - 2011L) + 13L * (g$k - 1L) }
NAT <- 2691L; val <- numeric(NAT)
for (r in seq_len(NR)) for (o in OO) for (k in KK) { val[iW(r, TW, o, k)] <- TT[r, TW, o, k]; val[iO(r, TO, o, k)] <- TT[r, TO, o, k] }
for (y in 2012:2024) for (k in KK) val[iG(y, k)] <- GG[as.character(y), k]
stopifnot(sum(val) == sum(TT) + sum(GG))
anoP <- function(y, r, o, k) if (y == 2012) c(iW(r, "2", o, k), iO(r, c("0", "1"), o, k)) else if (y == 2024) c(iW(r, "14", o, k), iO(r, c("15", "16"), o, k)) else iW(r, as.character(y - 2010L), o, k)
OK_ <- list(nv_a = list(o = OO, k = KK), nv_b = list(o = OO, k = c("c", "d")), nv_c = list(o = OO, k = "c"),
            ptb_a = list(o = "ptb", k = KK), ptb_b = list(o = "ptb", k = c("c", "d")), ptb_c = list(o = "ptb", k = "c"))
pc <- read.csv("01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv", colClasses = "character"); pc <- pc[match(REC, pc$recorte_principal), ]
pa <- read.csv("01_saidas/fase0_rerun/a7_populacao_dum_ano.csv", colClasses = "character")
masc <- function(v) v %in% c("supr.", "<10")
L <- list(); vL <- numeric(); add <- function(ix) { L[[length(L) + 1]] <<- ix; vL <<- c(vL, sum(val[ix])) }
for (ce in names(OK_)) {
  for (i in seq_len(NR)) if (!masc(pc[[ce]][i])) add(iW(i, TW, OK_[[ce]]$o, OK_[[ce]]$k))
  if (!any(masc(pc[[ce]]))) add(iW(seq_len(NR), TW, OK_[[ce]]$o, OK_[[ce]]$k))
  if (ce %in% names(pa)) for (jj in seq_along(anos)) if (!masc(pa[[ce]][jj])) add(iW(seq_len(NR), tano[jj], OK_[[ce]]$o, OK_[[ce]]$k))
}
for (i in seq_len(NR)) { add(c(iW(i, TW, "ptb", KK), iO(i, TO, "ptb", KK))); add(iW(i, TW, "ptb", KK)); add(iO(i, TO, "ptb", KK))
  add(c(iW(i, TW, "ptb", KK), iO(i, c("1", "15"), "ptb", KK))); add(iO(i, c("0", "16"), "ptb", KK)) }
sal_ara <- match(c("Salvador/BA", "Aracaju/SE"), nome[REC]); stopifnot(!anyNA(sal_ara))
for (y in 2012:2024) {
  add(anoP(y, seq_len(NR), OO, KK)); add(anoP(y, seq_len(NR), "ptb", KK)); add(iG(y, KK))
  add(c(anoP(y, seq_len(NR), OO, KK), iG(y, KK))); add(c(anoP(y, seq_len(NR), OO, c("c", "d")), iG(y, c("c", "d")))); add(c(anoP(y, seq_len(NR), OO, "c"), iG(y, "c")))
  for (ri in sal_ara) { add(anoP(y, ri, OO, KK)); add(anoP(y, ri, "ptb", KK)) }
}
for (i in seq_len(NR)) { add(iO(i, "0", OO, KK)); add(iO(i, "16", "ptb", KK)) }
stopifnot(all(vL[(length(vL) - 2 * NR + 1):length(vL)] == 0))                     # os zeros da Q5 são zero
cat("modelo da A7:", length(L), "linhas,", NAT, "átomos\n")

# ---------------------------------------------------------------- 1a. núcleo de H em J, exato
# Conservador: todo átomo que vale 0 entra como conhecido (linha própria); isso só aumenta o que é identificável. Então uma
# união com valor de 1 a 9 só tem átomos de 1 a 9: J = átomos com 1 ≤ valor ≤ 9. Em J, união identificável ⇔ x'Hx = 0.
# O núcleo de H é separado em blocos de suporte disjunto. Bloco pequeno (≤ 18 átomos): enumerado. Bloco grande: a base é
# escalonada (RREF) com os átomos sem concentração (NV de 43–44 por ano) primeiro; as linhas cujo pivô é um desses são
# "globais" (enumeradas, 2^g escolhas); as outras ficam dentro de uma concentração (conferido). Fixadas as globais, cada
# concentração se resolve sozinha (2^(linhas dela) escolhas, cada uma 0/1 ou inviável), e uma programação dinâmica sobre
# os valores (cortados em 10) diz se alguma união 0/1 identificável vale de 1 a 9.
conc_of <- function(a) ifelse(a <= 2028L, (a - 1L) %% 26L + 1L, ifelse(a <= 2652L, (a - 2029L) %% 26L + 1L, 0L))
rref <- function(A, tol = 1e-9) {
  d <- nrow(A); m <- ncol(A); piv <- integer(); r <- 1L
  for (j in seq_len(m)) { if (r > d) break
    i <- which.max(abs(A[r:d, j])) + r - 1L; if (abs(A[i, j]) < tol) next
    if (i != r) { tmp <- A[r, ]; A[r, ] <- A[i, ]; A[i, ] <- tmp }
    A[r, ] <- A[r, ] / A[r, j]
    for (ii in seq_len(d)[-r]) if (abs(A[ii, j]) > tol) A[ii, ] <- A[ii, ] - A[ii, j] * A[r, ]
    piv <- c(piv, j); r <- r + 1L }
  A[abs(A) < tol] <- 0; list(R = A[seq_along(piv), , drop = FALSE], piv = piv)
}
eh01 <- function(x) all(abs(x - round(x)) < 1e-6) && all(round(x) %in% 0:1)
dp_bloco <- function(at, Bv) {                    # at: átomos do bloco; Bv: base do núcleo restrita ao bloco (|at| × dim)
  g <- conc_of(at); o <- order(g); at <- at[o]; Bv <- Bv[o, , drop = FALSE]; g <- g[o]
  rr <- rref(t(Bv)); R <- rr$R; gp <- g[rr$piv]; glob <- which(gp == 0L)
  for (i in which(gp != 0L)) if (any(R[i, g != gp[i]] != 0)) return(list(erro = "linha de pivô numa concentração cruza outra"))
  if (length(glob) > 16) return(list(erro = "linhas globais demais"))
  v <- val[at]; C <- if (length(glob)) as.matrix(expand.grid(rep(list(0:1), length(glob)))) else matrix(0, 1, 0)
  furo <- FALSE; n_viaveis <- 0; minimo <- Inf
  for (ci in seq_len(nrow(C))) {
    xg <- if (length(glob)) colSums(C[ci, ] * R[glob, , drop = FALSE]) else numeric(length(at))
    if (!eh01(xg[g == 0L])) next
    reach <- rep(FALSE, 11); reach[min(sum(v[g == 0L] * round(xg[g == 0L])), 10) + 1] <- TRUE   # somas 0..9 e "≥ 10"
    viavel <- TRUE
    for (r in setdiff(unique(g), 0L)) {
      cols <- which(g == r); Ir <- which(gp == r)
      A <- if (length(Ir)) as.matrix(expand.grid(rep(list(0:1), length(Ir)))) else matrix(0, 1, 0)
      sv <- unique(unlist(lapply(seq_len(nrow(A)), function(ai) { x <- xg[cols] + if (length(Ir)) colSums(A[ai, ] * R[Ir, cols, drop = FALSE]) else 0
        if (eh01(x)) min(sum(v[cols] * round(x)), 10) else NULL })))
      if (!length(sv)) { viavel <- FALSE; break }
      nr <- rep(FALSE, 11); for (s in which(reach) - 1) for (t in sv) nr[min(s + t, 10) + 1] <- TRUE; reach <- nr
    }
    if (!viavel) next
    n_viaveis <- n_viaveis + 1
    tot <- which(reach) - 1; if (any(tot >= 1 & tot <= 9)) furo <- TRUE
    if (any(tot >= 1)) minimo <- min(minimo, min(tot[tot >= 1]))
  }
  list(furo = furo, n_glob = length(glob), n_viaveis = n_viaveis, minimo = minimo)
}
zeros <- which(val == 0); R0 <- c(L, as.list(zeros)); M <- matrix(0, length(R0), NAT); for (i in seq_along(R0)) M[i, R0[[i]]] <- 1
qm <- qr(t(M), tol = 1e-9); Q <- qr.Q(qm)[, seq_len(qm$rank), drop = FALSE]
J <- which(val >= 1 & val <= 9)
H <- diag(length(J)) - Q[J, , drop = FALSE] %*% t(Q[J, , drop = FALSE])
e <- eigen(H, symmetric = TRUE); Nn <- e$vectors[, e$values < 1e-7, drop = FALSE]; dN <- ncol(Nn)
blocos <- data.frame(); furos <- 0L; uni_peq <- 0L
if (dN > 0) {
  P <- Nn %*% t(Nn); sup <- which(diag(P) > 1e-9)
  adj <- abs(P[sup, sup, drop = FALSE]) > 1e-9; comp <- rep(0L, length(sup)); kk <- 0L
  for (i in seq_along(sup)) if (!comp[i]) { kk <- kk + 1L; fila <- i; comp[i] <- kk
    while (length(fila)) { v <- fila[1]; fila <- fila[-1]; nv <- which(adj[v, ] & !comp); comp[nv] <- kk; fila <- c(fila, nv) } }
  for (b in seq_len(kk)) {
    Bj <- sup[comp == b]; dimB <- round(sum(diag(P[Bj, Bj, drop = FALSE])))
    if (length(Bj) <= 18) {
      S <- as.matrix(expand.grid(rep(list(0:1), length(Bj))))[-1, , drop = FALSE]
      r2 <- rowSums((S %*% H[Bj, Bj, drop = FALSE]) * S); vs <- as.vector(S %*% val[J[Bj]])
      f <- sum(r2 < 1e-7 & vs >= 1 & vs <= 9); furos <- furos + f; uni_peq <- uni_peq + sum(r2 < 1e-7)
      blocos <- rbind(blocos, data.frame(atomos = length(Bj), dim = dimB, metodo = "enumeração", globais = NA, viaveis = sum(r2 < 1e-7), menor = if (any(r2 < 1e-7)) min(vs[r2 < 1e-7]) else NA, furo = f > 0))
    } else {
      ev <- eigen(P[Bj, Bj, drop = FALSE], symmetric = TRUE); Bv <- ev$vectors[, ev$values > 0.5, drop = FALSE]; stopifnot(ncol(Bv) == dimB)
      dp <- dp_bloco(J[Bj], Bv); if (!is.null(dp$erro)) { cat("PARAR:", dp$erro, "\n"); quit(status = 1) }
      furos <- furos + dp$furo
      blocos <- rbind(blocos, data.frame(atomos = length(Bj), dim = dimB, metodo = "RREF + programação dinâmica", globais = dp$n_glob, viaveis = dp$n_viaveis, menor = dp$minimo, furo = dp$furo))
    }
  }
}
print(blocos)
confere("1", sprintf("A7, prova exaustiva no modelo ampliado (%d linhas, mais os %s átomos que valem 0, tratados como conhecidos): uniões de átomos de 1 a 9 (|J| = %d) identificáveis com valor de 1 a 9",
                     length(L), br(length(zeros)), length(J)), "0",
        sprintf("núcleo de dimensão %d em %d bloco(s); a menor união identificável vale %s; de 1 a 9: %d", dN, nrow(blocos),
                if (nrow(blocos)) classe(min(blocos$menor, na.rm = TRUE)) else "—", furos), furos == 0)

# ---------------------------------------------------------------- 1b. d somado em todo subconjunto das concentrações com (b) suprimido
S0 <- which(masc(pc$nv_b) | masc(pc$ptb_b)); k0 <- length(S0)
SS <- as.matrix(expand.grid(rep(list(0:1), k0)))[-1, , drop = FALSE]
tipos <- list(ptb_d = "ptb", non_d = "non", nv_d = OO)
sub_res <- do.call(rbind, lapply(names(tipos), function(tp) {
  ix <- lapply(S0, function(r) iW(r, TW, tipos[[tp]], "d"))
  V <- t(vapply(ix, function(a) colSums(Q[a, , drop = FALSE]), numeric(ncol(Q)))); nat <- lengths(ix); vv <- vapply(ix, function(a) sum(val[a]), 0)
  r2 <- as.vector(SS %*% nat) - rowSums((SS %*% V)^2); v <- as.vector(SS %*% vv)
  data.frame(tipo = tp, subconjuntos = nrow(SS), identificaveis = sum(r2 < 1e-8), de_1_a_9 = sum(v > 0 & v < 10), furos = sum(r2 < 1e-8 & v > 0 & v < 10))
}))
print(sub_res)
confere("1", sprintf("d (PTB, não PTB, NV) somado em todo subconjunto das %d concentrações com (b) suprimido (%s subconjuntos por tipo): identificáveis com valor de 1 a 9",
                     k0, br(nrow(SS))), "0", sprintf("identificáveis: %s; furos: %d", paste(sub_res$tipo, sub_res$identificaveis, sep = " ", collapse = ", "), sum(sub_res$furos)),
        sum(sub_res$furos) == 0)

# ================================================================ 2. quadro-resumo da §9
ler <- function(p) read.csv(p, stringsAsFactors = FALSE, colClasses = c(recorte_principal = "character"))
r52 <- ler("01_saidas/fase0_rerun/a5_2_eventos_janelas.csv"); o52 <- ler("01_saidas/fase0/a5_2_eventos_janelas.csv")
r54 <- ler("01_saidas/fase0_rerun/a5_4_semanal_mm.csv"); o54 <- ler("01_saidas/fase0/a5_4_semanal_mm.csv")
r4c <- ler("01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv"); o4b <- ler("01_saidas/fase0/a5_4b_mm14_equivalentes.csv")
mf <- function(x, d) sprintf("%s (de %s a %s)", br(mean(x), d), br(min(x), d), br(max(x), d))
lin9 <- list(); q9 <- function(item, onde, novo, velho, d, unid = "") {
  lin9[[length(lin9) + 1]] <<- data.frame(Item = item, `Tabela por concentração` = onde, `Média nas 26 (faixa)` = paste0(mf(novo, d), unid),
                                          `Fase 0A: média (faixa)` = paste0(mf(velho, d), unid), `Maior diferença por concentração` = format(signif(max(abs(novo - velho)), 2)), check.names = FALSE) }
for (dd in c("ptb", "obito_perinatal")) {
  rn <- r52[r52$desfecho == dd & r52$janela == "principal", ]; ro <- o52[o52$desfecho == dd & o52$janela == "principal", ]; ro <- ro[match(rn$recorte_principal, ro$recorte_principal), ]
  q9(sprintf("Perda %%, %s, janela principal (total: %s de %s; %s%%)", dd, br(sum(rn$perda)), br(sum(rn$total_2012_2024)), br(100 * sum(rn$perda) / sum(rn$total_2012_2024), 2)),
     "A5.2 (`a5_2_eventos_janelas.csv`)", rn$perda_pct, ro$perda_pct, 2, "%")
  q9(sprintf("Eventos na janela principal, %s; abaixo de 1.000: %d; abaixo de 2.000: %d (%s)", dd, sum(rn$eventos_janela < 1000), sum(rn$eventos_janela < 2000),
             paste(rn$concentracao[rn$eventos_janela < 2000], collapse = ", ")), "A5.2", rn$eventos_janela, ro$eventos_janela, 0)
}
o54 <- o54[match(r54$recorte_principal, o54$recorte_principal), ]; o4b <- o4b[match(r4c$recorte_principal, o4b$recorte_principal), ]
q9("p1 da MM9, em percentil semanal (i)", "A5.4 (`a5_4_semanal_mm.csv`) e A5 (`a5_4c…`)", r54$mm9_p1_em_pct_semanal_i, o54$mm9_p1_em_pct_semanal_i, 1, "")
q9("p99 da MM9, em percentil semanal (i)", "A5.4 e A5", r54$mm9_p99_em_pct_semanal_i, o54$mm9_p99_em_pct_semanal_i, 1, "")
for (k in c("t1_p1", "t1_p99", "t2_p1", "t2_p99")) {
  rot <- c(t1_p1 = "p1 da MM14, 1º trimestre", t1_p99 = "p99 da MM14, 1º trimestre", t2_p1 = "p1 da MM14, 2º trimestre", t2_p99 = "p99 da MM14, 2º trimestre")[[k]]
  q9(paste(rot, "(°C)"), "A5 (`a5_4c_mm14_mm9_equivalentes.csv`)", r4c[[k]], o4b[[k]], 2, " °C")
  q9(paste(rot, "(percentil semanal (i))"), "A5", r4c[[paste0(k, "_pct_i")]], o4b[[paste0(k, "_pct_i")]], 1, "")
}
quadro <- do.call(rbind, lin9)
a7c <- read.csv("01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv", colClasses = c(recorte_principal = "character"))
nva <- as.numeric(a7c$nv_a); nvc <- as.numeric(a7c$nv_c); pta <- as.numeric(a7c$ptb_a); ptc <- as.numeric(a7c$ptb_c)
prop <- sprintf("PTB entre os NV: %s%% em (a) e %s%% em (c), nas 26 somadas; por concentração, de %s%% a %s%% em (a) e de %s%% a %s%% em (c).",
                br(100 * sum(pta) / sum(nva), 2), br(100 * sum(ptc) / sum(nvc), 2), br(min(100 * pta / nva), 2), br(max(100 * pta / nva), 2),
                br(min(100 * ptc / nvc), 2), br(max(100 * ptc / nvc), 2))

# ================================================================ 3. conferências finais
inv <- readLines(lg("inventario_fase0A_rerun_"), encoding = "UTF-8")
md_inv <- regmatches(inv, regexec("^\\| `artigo1_prematuridade/logs/desvios_especificacao.md` \\| ([0-9]+) \\| `([0-9a-f]{64})` \\|$", inv)); md_inv <- md_inv[lengths(md_inv) == 3][[1]]
pref <- sub(" .*", "", system(sprintf("head -c %s logs/desvios_especificacao.md | shasum -a 256", md_inv[2]), intern = TRUE))
dv <- readLines("logs/desvios_especificacao.md", encoding = "UTF-8"); nd <- as.integer(sub("^\\| ([0-9]+) \\|.*", "\\1", grep("^\\| [0-9]+ \\|", dv, value = TRUE)))
confere("3", "log de desvios: numeração 1 a N sem lacuna, e os primeiros bytes com o SHA-256 inventariado (só acréscimos)", "1–N; sim",
        sprintf("1–%d; %s", max(nd), if (identical(pref, md_inv[3])) "sim" else "não"), identical(nd, seq_len(max(nd))) && identical(pref, md_inv[3]))
man0 <- jsonlite::fromJSON(paste(system2("git", c("-C", BASE, "show", "9f1957b:09_acesso/manifesto.json"), stdout = TRUE), collapse = "\n"))
gp <- suppressWarnings(system2("grep", c("-rn", man0$versao, "00_scripts", "CLAUDE.md"), stdout = TRUE))
confere("3", "prova do grep da versão antiga: só CLAUDE.md:13 (nome da ENTREGA; desvio 19) e :42 (histórico)", "CLAUDE.md:13 e :42",
        paste(sub("^([^:]+:[0-9]+):.*", "\\1", gp), collapse = " e "), length(gp) == 2 && all(grepl("^CLAUDE.md:(13|42):", gp)))
logs_r <- lg(c("entrada_fase0_rerun_", "ambiente_fase0_rerun_", "interface_fase0_rerun_", "recontagens_fase0_rerun_", "comparacao_a4_fase0_rerun_",
               "mm14_equivalente_fase0_rerun_", "populacao_dum_fase0_rerun_", "desvio9_fase0_rerun_", "csv_sha256_fase0_rerun_",
               "autoauditoria_fase0_rerun_", "autoauditoria_itens_novos_fase0_rerun_"))
fim <- vapply(logs_r, function(f) any(grepl("no fim", y <- readLines(f, encoding = "UTF-8"), fixed = TRUE) & grepl("4443971b", y, fixed = TRUE)), TRUE)
confere("3", "logs gerados por script nesta rodada registram a versao() do fim (4443971b)", paste(length(fim), "de", length(fim)), paste(sum(fim), "de", length(fim)), all(fim))
a6 <- readLines(lg("csv_sha256_fase0_rerun_"), encoding = "UTF-8"); fs <- list.files("01_saidas/fase0_rerun", pattern = "^[^.].*\\.csv$")
ok6 <- vapply(fs, function(f) any(grepl(sprintf("fase0_rerun/%s` | `%s` |", f, sha256(file.path("01_saidas/fase0_rerun", f))), a6, fixed = TRUE)), TRUE)
c0 <- readLines("logs/csv_sha256_fase0_20261008.md", encoding = "UTF-8"); f0 <- list.files("01_saidas/fase0", pattern = "^[^.].*\\.csv$")
ok0 <- vapply(f0, function(f) any(grepl(sprintf("| `%s` |", f), c0, fixed = TRUE) & grepl(sha256(file.path("01_saidas/fase0", f)), c0, fixed = TRUE)), TRUE)
confere("3", "SHA-256 dos CSV: os 8 de fase0_rerun/ = log da A6; os 6 de fase0/ = log da Fase 0A", "8 e 6", paste(sum(ok6), "e", sum(ok0)),
        all(ok6) && length(ok6) == 8 && all(ok0) && length(ok0) == 6)
git <- function(...) suppressWarnings(system2("git", c("-C", RAIZ, ...), stdout = TRUE, stderr = TRUE))
nc <- git("rev-list", "--all", "--count")
ign <- git("check-ignore", file.path("artigo1_prematuridade/01_saidas/fase0_rerun", fs), "artigo1_prematuridade/01_saidas/reproducao_07_20261009/logs/comparacao_a4_fase0_rerun_20261009.md")
confere("3", "git: nenhum commit; CSV de fase0_rerun/ e a cópia de reprodução ignorados", "0; todos", sprintf("%s; %d de %d", nc[1], length(ign), length(fs) + 1),
        identical(nc[1], "0") && length(ign) == length(fs) + 1)

# ================================================================ log
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
confere("C8", "versao() no início e no fim", "4443971b e 4443971b", paste(v_ini, "e", v_fim), v_ini == "4443971b" && v_fim == "4443971b")
md <- c("# Conferência final da Fase 0 refeita: sigilo exaustivo da A7, quadro-resumo da §9 e conferências finais", "",
        sprintf("- **Gerado por:** `00_scripts/13_conferencia_final_rerun.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        "- **Por quê:** responde aos achados 1, 2 e 3 da auditoria independente (`logs/auditoria_fase0_rerun_20261009.md`).",
        sprintf("- **Resultado:** %d de %d conferências ok.", sum(res$ok), nrow(res)), "",
        "| Item | Conferência | Esperado | Obtido | Ok |", "|---|---|---|---|---|",
        sprintf("| %s | %s | %s | %s | %s |", res$item, res$conferencia, res$esperado, res$obtido, ifelse(res$ok, "sim", "**NÃO**")), "",
        "## 1. Sigilo da A7: prova exaustiva", "",
        "- **Modelo:** o do `12_autoauditoria_itens_novos_rerun.R`: átomos da janela (concentração × 13 trechos × PTB ou não × nível da DUM c, d, e) = 2.028; pontas fora da janela (concentração × 4 trechos × PTB ou não × nível) = 624; NV de 43–44 semanas da coorte por ano × nível = 39. Linhas: as células publicadas da A7 (por concentração, 26 somadas e por ano), a A5.2 do PTB, os totais anuais de NV, PTB e NV de 43–44, a Tabela 1b do RESPOSTA da base (n, comparáveis e concordantes por ano, o % tratado como exato), as conciliações §A3 (NV e PTB por ano em Salvador e Aracaju) e os zeros da Q5. Valores pela recontagem independente do `12` (coorte pelo `dum_est`).",
        "- **Método (o do `10`, no nível de átomo, exato):** toda contagem candidata é uma união de átomos. Conservador: os átomos que valem 0 entram como conhecidos, o que só aumenta o que é identificável; então uma união de 1 a 9 só tem átomos de 1 a 9 (J). Em J, a união é recuperável se e só se x'Hx = 0. O núcleo de H é separado em blocos de suporte disjunto. Bloco de até 18 átomos: todas as uniões enumeradas. Bloco maior: a base é escalonada (RREF), com os NV de 43–44 por ano (sem concentração) como pivôs globais; as 2^g escolhas globais são enumeradas e, fixadas, cada concentração se resolve sozinha (cada escolha dela dá um vetor 0/1 ou é inviável); uma programação dinâmica sobre os valores diz se alguma união 0/1 identificável vale de 1 a 9. A busca cobre **todas** as uniões de átomos de J, inclusive somas sobre qualquer subconjunto de concentrações, trechos e anos.",
        sprintf("  - **Núcleo de H em J:** dimensão %d; |J| = %d; %d linhas mais %s zeros conhecidos; posto %d.", dN, length(J), length(L), br(length(zeros)), qm$rank),
        if (nrow(blocos)) c("", tabela_md(data.frame(Átomos = blocos$atomos, Dimensão = blocos$dim, Método = blocos$metodo,
                                                    `Linhas globais` = ifelse(is.na(blocos$globais), "—", blocos$globais),
                                                    `Escolhas viáveis` = blocos$viaveis, `Menor união identificável` = ifelse(is.na(blocos$menor), "—", classe(blocos$menor)),
                                                    `De 1 a 9` = ifelse(blocos$furo, "**sim**", "não"), check.names = FALSE)), "") else "  - **Núcleo vazio.**",
        sprintf("- **Teste pedido pelo auditor:** o discordante (d), de PTB, de não PTB e de NV, somado na janela inteira em todo subconjunto não vazio das %d concentrações com o (b) suprimido (%s).", k0, paste(nome[REC][S0], collapse = ", ")), "",
        tabela_md(data.frame(Tipo = sub_res$tipo, Subconjuntos = br(sub_res$subconjuntos), `Identificáveis` = br(sub_res$identificaveis),
                             `Com valor de 1 a 9` = br(sub_res$de_1_a_9), `Identificáveis e de 1 a 9` = sub_res$furos, check.names = FALSE)), "",
        "- **Correção de texto (achado 1):** a frase do log da A7 (`logs/populacao_dum_fase0_rerun_20261009.md`, linha 87) diz que as tabelas externas trazem d e e sempre juntos. Isso vale para as tabelas do modelo do `09`, mas não para a Tabela 1b do RESPOSTA da base, que separa c, d e e por ano, nas 26 somadas (n, comparáveis e % |dif| ≤ 1). A prova completa da A7 é a deste log (com a Tabela 1b), mais as conferências do `12`.", "",
        "## 2. Quadro-resumo da §9 (pelos itens que o prompt enumera; a Revisão 2 não está na Forja)", "",
        tabela_md(quadro), "",
        "- **Diferença para a Fase 0A:** é a maior diferença absoluta, concentração a concentração, entre o CSV desta rodada e o da Fase 0A (o da MM14 é o `a5_4b` do complemento).",
        sprintf("- **A7 (informativo para a redação da §3.5):** %s O nível (c) é uma subpopulação selecionada: tem proporção de PTB maior que a população inteira.", prop),
        "- **Inventário da A1 refeito no fim:** `logs/inventario_fase0A_rerun_conferencia2_20261009.md` (rodado depois deste log e do log da auditoria).", "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "\n")
print(res[, c("item", "obtido", "ok")], row.names = FALSE, right = FALSE)
if (!all(res$ok)) quit(status = 1)
