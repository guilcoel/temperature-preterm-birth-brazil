# 12_autoauditoria_itens_novos_rerun.R — Fase 0 refeita (base 4443971b), A10.1: autoauditoria por código dos itens da
# rodada que o 03_autoauditoria_fase0.R não cobre: A0, A1 (inventário e .tar), A2 (prova do grep e CLAUDE.md), A3 (esquema),
# A4, A5 (citações de linha), A6, A7, A8 e A9.
# A7 por caminho independente do 09_populacao_dum_rerun.R: coorte recalculada do dum_est (sem as flags pop_ptb, ptb e
# coorte_fixa_22), concentração por consulta nomeada, contagem por table(); confere cada célula publicada, cada "%", cada
# máscara (suficiente e necessária), todos os pares de diferença das linhas, e refaz a prova de sigilo num modelo ampliado
# com as tabelas da base que tocam a DUM ou a mesma população por ano (Tabela 1b do RESPOSTA da base, com os NV de 43–44
# semanas, e conciliações §A3).
# Microdado só agregado em memória; nada em nível de registro é exibido nem gravado; contagens de 1 a 9 não saem (só a classe).
# Grava logs/autoauditoria_itens_novos_fase0_rerun_<FASE0_RERUN_DATA>.md (nunca sobrescreve). Sai com 1 se algo falhar.
# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/12_autoauditoria_itens_novos_rerun.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
RAIZ <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; BASE <- "/Volumes/Forja/Doc/dados_artigos_perinatais_clima"
hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("autoauditoria_itens_novos_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq))
sha256 <- function(f) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(f)), stdout = TRUE))
classe <- function(x) ifelse(x == 0, "0", ifelse(x > 0 & x < 10, "1 a 9", ifelse(x >= 10, "≥ 10", "negativo")))
lg <- function(n) file.path("logs", paste0(n, hoje, ".md"))
D <- as.Date
res <- data.frame()
confere <- function(item, conferencia, esperado, obtido, ok)
  res <<- rbind(res, data.frame(item = item, conferencia = conferencia, esperado = as.character(esperado),
                                obtido = as.character(obtido), ok = isTRUE(ok), stringsAsFactors = FALSE))
nuc <- as.data.frame(cidade_nucleo()); REC <- nuc$CD_RECORTE; nome <- setNames(nuc$NM_RECORTE, REC); NR <- length(REC)

# ================================================================ A0
ent <- readLines(lg("entrada_fase0_rerun_"), encoding = "UTF-8")
confere("A0", "log da A0: todas as conferências de entrada ok", "19 de 19", sub(".*Resultado:\\*\\* ([0-9]+ de [0-9]+).*", "\\1", grep("Resultado:", ent, value = TRUE)[1]),
        any(grepl("**Resultado:** 19 de 19 conferências ok.", ent, fixed = TRUE)))

# ================================================================ A1 inventário e .tar
inv <- readLines(lg("inventario_fase0A_rerun_"), encoding = "UTF-8")
m <- regmatches(inv, regexec("^\\| `(.+)` \\| ([0-9]+) \\| `([0-9a-f]{64})` \\|$", inv)); m <- do.call(rbind, m[lengths(m) == 4])
it <- data.frame(path = m[, 2], bytes = as.numeric(m[, 3]), sha = m[, 4], stringsAsFactors = FALSE)
n_decl <- as.integer(sub(".*\\*\\*Arquivos:\\*\\* ([0-9]+)\\..*", "\\1", grep("**Arquivos:**", inv, fixed = TRUE, value = TRUE)))
tar <- list.files("01_saidas", pattern = "^arquivo_fase0A_[0-9a-f]{8}\\.tar$", full.names = TRUE); stopifnot(length(tar) == 1)
sha_tar_inv <- sub(".*SHA-256 `([0-9a-f]{64})`.*", "\\1", grep("**Arquivo (fora do git):**", inv, fixed = TRUE, value = TRUE))
st <- sha256(tar)
confere("A1", "SHA-256 do .tar = o registrado no inventário", substr(sha_tar_inv, 1, 16), substr(st, 1, 16), identical(st, sha_tar_inv))
lst <- system2("tar", c("-tf", shQuote(tar)), stdout = TRUE); lst <- lst[!grepl("/$", lst)]
confere("A1", "lista do .tar = tabela do inventário = nº declarado", n_decl, sprintf("tar %d; tabela %d", length(lst), nrow(it)),
        setequal(lst, it$path) && length(lst) == n_decl && nrow(it) == n_decl && !any(grepl("(^|/)\\._|\\.DS_Store$", lst)))
no_tar <- vapply(it$path, function(p) sub(" .*", "", system(sprintf("tar -xOf %s %s | shasum -a 256", shQuote(tar), shQuote(p)), intern = TRUE)), "")
confere("A1", "SHA-256 de cada arquivo dentro do .tar (tar -xOf) = inventário", nrow(it), sum(no_tar == it$sha), all(no_tar == it$sha))
EDIT <- c(paste0("artigo1_prematuridade/00_scripts/", c("00_ambiente.R", "00_dependencias.R", "01_interface.R", "02_recontagens_fase0.R",
                                                       "03_autoauditoria_fase0.R", "04_mm14_equivalentes_fase0.R")), "artigo1_prematuridade/CLAUDE.md")
DESV <- "artigo1_prematuridade/logs/desvios_especificacao.md"
disco <- vapply(file.path(RAIZ, it$path), function(f) if (file.exists(f)) sha256(f) else NA_character_, "")
fixo <- !(it$path %in% c(EDIT, DESV))
confere("A1", "agora: SHA-256 no disco = inventário, fora os 7 editados de propósito e o log de desvios", sum(fixo),
        sum(disco[fixo] == it$sha[fixo], na.rm = TRUE), all(disco[fixo] == it$sha[fixo], na.rm = FALSE) && !anyNA(disco))
dl <- vapply(EDIT, function(p) {
  x <- system2("bash", c("-c", shQuote(sprintf("diff <(tar -xOf %s %s) %s | grep -c '^[<>]'", shQuote(tar), shQuote(p), shQuote(file.path(RAIZ, p))))), stdout = TRUE)
  as.integer(x[1]) }, 0L)
confere("A1", "os 7 editados mudaram (diff contra o .tar, linhas trocadas)", "> 0 em cada", paste(basename(EDIT), dl, sep = ": ", collapse = "; "), all(dl > 0))
bd <- it$bytes[it$path == DESV]; sd0 <- it$sha[it$path == DESV]
pref <- sub(" .*", "", system(sprintf("head -c %d %s | shasum -a 256", bd, shQuote(file.path(RAIZ, DESV))), intern = TRUE))
confere("A1/A9", "log de desvios: os primeiros bytes (tamanho inventariado) têm o SHA-256 inventariado (só linhas novas no fim)",
        substr(sd0, 1, 16), substr(pref, 1, 16), identical(pref, sd0) && file.size(file.path(RAIZ, DESV)) > bd)

# ================================================================ A2 prova do grep e CLAUDE.md
man <- jsonlite::fromJSON(file.path(BASE, "09_acesso/manifesto.json"), simplifyVector = FALSE)
man0 <- jsonlite::fromJSON(paste(system2("git", c("-C", BASE, "show", "9f1957b:09_acesso/manifesto.json"), stdout = TRUE), collapse = "\n"), simplifyVector = FALSE)
velha <- man0$versao; stopifnot(grepl("^[0-9a-f]{8}$", velha), velha != man$versao, man$versao == "4443971b")
gp <- suppressWarnings(system2("grep", c("-rn", velha, "00_scripts", "CLAUDE.md"), stdout = TRUE))
ok_g <- length(gp) == 2 && any(grepl("^CLAUDE.md:42:.*Histórico", gp)) && any(grepl("^CLAUDE.md:13:.*ENTREGA_COORDENACAO_", gp))
confere("A2", "grep da versão antiga em 00_scripts/ e CLAUDE.md: só a linha 42 (histórico) e a 13 (nome da ENTREGA; desvio 19)", "CLAUDE.md:13 e :42",
        paste(sub("^([^:]+:[0-9]+):.*", "\\1", gp), collapse = " e "), ok_g)
antigos <- c("RESPOSTA_artigo1_prematuridade_FASE0A_20261008.md", "RESPOSTA_artigo1_prematuridade_FASE0A_complemento_20261008.md",
             "logs/recontagens_fase0_20261008.md", "logs/interface_fase0_20261008.md", "logs/ambiente_fase0_20261008.md")
tem <- vapply(antigos, function(f) any(grepl(velha, readLines(f, encoding = "UTF-8", warn = FALSE), fixed = TRUE)), TRUE)
confere("A2", "RESPOSTA e logs antigos continuam com a versão antiga", paste(length(antigos), "de", length(antigos)), paste(sum(tem), "de", length(antigos)), all(tem))
cl <- readLines("CLAUDE.md", encoding = "UTF-8")
ok_cl <- any(grepl("**Versão exigida:** `4443971b`", cl, fixed = TRUE)) &&
  any(grepl(sprintf("base trocada de `%s` para `4443971b` em 08/10/2026 (decisões §8); única mudança: coluna `ig_dum_sem`", velha), cl, fixed = TRUE)) &&
  any(grepl("`sttrabpart`, `stcesparto_aj` e `parto` são minúsculos", cl, fixed = TRUE)) &&
  sum(grepl('stopifnot(versao() == "4443971b")', cl, fixed = TRUE)) == 1
confere("A2", "CLAUDE.md: versão exigida, linha de histórico, nomes em minúsculas (E5) e o bloco de início de script", "sim", if (ok_cl) "sim" else "não", ok_cl)

# ================================================================ A3 esquema (manifesto atual × commit 9f1957b)
esq <- function(mm) setNames(lapply(mm$arquivos, function(a) if (is.null(a$colunas)) character() else
  vapply(a$colunas, function(cc) paste(cc$nome, if (is.null(cc$tipo)) "" else cc$tipo), "")), vapply(mm$arquivos, `[[`, "", "caminho"))
e1 <- esq(man); e0 <- esq(man0)
mud <- names(e1)[vapply(names(e1), function(k) !identical(sort(e1[[k]]), sort(e0[[k]])), TRUE)]
NASC <- "06_processados/nascimentos.parquet"
novas <- setdiff(e1[[NASC]], e0[[NASC]]); sairam <- setdiff(e0[[NASC]], e1[[NASC]])
confere("A3", "esquema: mesmos 43 arquivos; só o nascimentos mudou, com a nova `ig_dum_sem` int16; nada saiu nem mudou de tipo",
        "43; nascimentos; ig_dum_sem int16; 0", sprintf("%d; %s; %s; %d", length(e1), paste(mud, collapse = ","), paste(novas, collapse = ","), length(sairam)),
        setequal(names(e1), names(e0)) && length(e1) == 43 && identical(mud, NASC) && identical(novas, "ig_dum_sem int16") && length(sairam) == 0)
itf <- readLines(lg("interface_fase0_rerun_"), encoding = "UTF-8")
ac <- readLines(file.path(BASE, "09_acesso/acesso.R"), encoding = "UTF-8")
pl <- vapply(c("paridade_ig_dum_sem_py_20261008_201224.log", "paridade_ig_dum_sem_R_20261008_201246.log"), function(f) {
  x <- readLines(file.path(BASE, "logs", f), encoding = "UTF-8", warn = FALSE); any(grepl("1:1", x, fixed = TRUE)) && any(grepl("casos OK", x, fixed = TRUE)) }, TRUE)
ok_itf <- any(grepl("| `nascimentos()` | `nascimentos.parquet` | `ig_dum_sem` | sim | `int16` |", itf, fixed = TRUE)) &&
  any(grepl("| `pig(com_nascimentos = \"ig_dum_sem\")` | `pig_classificacao.parquet` | `id_nasc` | sim | `int64` |", itf, fixed = TRUE)) &&
  any(grepl("pig <- function(colunas = NULL, com_nascimentos = NULL) {", ac, fixed = TRUE)) && all(pl)
confere("A3", "log da A3: ig_dum_sem int16 no nascimentos(); pig(com_nascimentos) na assinatura do acesso.R; logs de paridade da base com a junção 1:1",
        "sim", if (ok_itf) "sim" else "não", ok_itf)

# ================================================================ A4
c5 <- c("a5_1_totais.csv", "a5_2_eventos_janelas.csv", "a5_3_percentis_diarios.csv", "a5_4_semanal_mm.csv", "a5_5_pm25_dias_utilizaveis.csv")
ig5 <- vapply(c5, function(f) identical(sha256(file.path("01_saidas/fase0", f)), sha256(file.path("01_saidas/fase0_rerun", f))), TRUE)
cmp <- readLines(lg("comparacao_a4_fase0_rerun_"), encoding = "UTF-8")
confere("A4", "os 5 CSV refeitos têm o SHA-256 dos da Fase 0A (recalculado aqui) e o log da A4 diz o mesmo", "5 de 5; nenhuma diferença",
        sprintf("%d de 5", sum(ig5)), all(ig5) && any(grepl("nenhuma diferença; os 5 CSV são idênticos byte a byte", cmp, fixed = TRUE)))

# ================================================================ A5 citações de linha e resultado
lt <- function(p, n) system(sprintf("tar -xOf %s %s | sed -n '%sp'", shQuote(tar), shQuote(paste0("artigo1_prematuridade/00_scripts/", p)), n), intern = TRUE)
c02 <- c(lt("02_recontagens_fase0.R", 132), lt("02_recontagens_fase0.R", 141)); c04 <- c(lt("04_mm14_equivalentes_fase0.R", 37), lt("04_mm14_equivalentes_fase0.R", "42,44"))
ok_cit0 <- grepl("F <- ecdf(emp)", c02[1], fixed = TRUE) && grepl("mm9_p99_em_pct_semanal_i = 100 * F(qm[3])", c02[2], fixed = TRUE) &&
  grepl("ecdf(as.vector(m))", c04[1], fixed = TRUE) && length(c04) == 4 && all(grepl("100 * Fi(q$", c04[2:4], fixed = TRUE)) &&
  grepl("q$t1[1]", c04[2], fixed = TRUE) && grepl("q$t2[1]", c04[3], fixed = TRUE) && grepl("q$mm9[1]", c04[4], fixed = TRUE)
mm14 <- readLines(lg("mm14_equivalente_fase0_rerun_"), encoding = "UTF-8"); s08 <- readLines("00_scripts/08_mm14_equivalente_rerun.R", encoding = "UTF-8")
ln <- as.integer(regmatches(grep("Onde está aqui", mm14, value = TRUE), gregexpr("linha [0-9]+", grep("Onde está aqui", mm14, value = TRUE)))[[1]] |> sub(pattern = "linha ", replacement = ""))
ok_cit1 <- length(ln) == 3 && grepl("pct_i <- function", s08[ln[1]], fixed = TRUE) && grepl("q7 <- function", s08[ln[2]], fixed = TRUE) &&
  grepl("mm <- list(t1 = c(m[, 1:14]", s08[ln[3]], fixed = TRUE)
confere("A5", "linhas citadas no log da A5: 02 (132, 141) e 04 (37, 42–44) da Fase 0A, lidas do .tar; e as do 08", "sim",
        if (ok_cit0 && ok_cit1) "sim" else sprintf("Fase 0A %s; 08 %s", ok_cit0, ok_cit1), ok_cit0 && ok_cit1)
confere("A5", "log da A5: igual ao complemento e à A5.4 refeita", "sim", if (any(grepl("**Resultado:** igual nas duas comparações.", mm14, fixed = TRUE))) "sim" else "não",
        any(grepl("**Resultado:** igual nas duas comparações.", mm14, fixed = TRUE)))

# ================================================================ A6
a6 <- readLines(lg("csv_sha256_fase0_rerun_"), encoding = "UTF-8")
m6 <- regmatches(a6, regexec("^\\| `artigo1_prematuridade/01_saidas/fase0_rerun/([^`]+)` \\| `([0-9a-f]{64})` \\| ([0-9.]+) \\| +([0-9]+) \\|", a6)); m6 <- do.call(rbind, m6[lengths(m6) == 5])
fs <- list.files("01_saidas/fase0_rerun", pattern = "^[^.].*\\.csv$")
ok6 <- setequal(m6[, 2], fs) && all(vapply(seq_len(nrow(m6)), function(i) { f <- file.path("01_saidas/fase0_rerun", m6[i, 2])
  m6[i, 3] == sha256(f) && as.numeric(gsub("\\.", "", m6[i, 4])) == file.size(f) && as.integer(m6[i, 5]) == length(readLines(f, warn = FALSE)) }, TRUE))
a54 <- read.csv("01_saidas/fase0_rerun/a5_4_semanal_mm.csv"); a54c <- read.csv("01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv")
ok6b <- all(c(paste0("i_p", c(1, 10, 75, 90, 99)), "mm9_p1", "mm9_p50", "mm9_p99", "t1_p1", "t1_p99", "t2_p1", "t2_p99", "mm9_p99_em_pct_semanal_i", "mm9_p1_em_pct_semanal_i") %in% names(a54)) &&
  all(c(paste0(rep(c("t1", "t2", "mm9"), each = 2), c("_p1", "_p99"), "_pct_i")) %in% names(a54c))
confere("A6", "log da A6: um CSV por linha, com SHA-256, bytes e linhas iguais aos arquivos; colunas que sustentam (i), MM9, MM14 e equivalentes existem",
        paste(length(fs), "de", length(fs)), paste(nrow(m6), "linhas;", if (ok6 && ok6b) "iguais" else "DIFERENTES"), ok6 && ok6b)

# ================================================================ A7: recontagem por caminho independente
n <- nascimentos(c("CD_MUN6", "data", "unico", "ga_sem", "dum_est", "ig_dum_sem"))
n$data <- as.Date(n$data); n$dum_est <- as.Date(n$dum_est)
dum_div <- sum(!is.na(n$ga_sem) & (n$dum_est != n$data - (7L * as.integer(n$ga_sem) + 3L)) %in% TRUE)
coorte <- !is.na(n$dum_est) & n$dum_est >= D("2011-07-31") & n$dum_est <= D("2024-03-05")
base_sel <- (n$unico %in% TRUE) & coorte & n$data >= D("2012-01-01") & n$data <= D("2024-12-31") & !is.na(n$ga_sem)
popA <- base_sel & n$ga_sem >= 22 & n$ga_sem <= 42; g43 <- base_sel & n$ga_sem >= 43 & n$ga_sem <= 44
cm <- as.data.frame(concentracoes()); dono <- setNames(as.character(cm$CD_RECORTE), as.character(cm$CD_MUN6))
sel <- popA | g43
x <- data.frame(rec = unname(dono[as.character(n$CD_MUN6[sel])]), data = n$data[sel], ga = as.integer(n$ga_sem[sel]),
                ig = as.integer(n$ig_dum_sem[sel]), pop = popA[sel], stringsAsFactors = FALSE)
rm(n, coorte, base_sel, popA, g43, sel); invisible(gc())
sem_rec <- sum(is.na(x$rec))
x$b <- !is.na(x$ig) & x$ig >= 20 & x$ig <= 45; x$c <- x$b & abs(x$ga - x$ig) <= 1
x$k <- factor(ifelse(x$c, "c", ifelse(x$b, "d", "e")), levels = c("c", "d", "e"))
x$o <- factor(ifelse(x$ga <= 36, "ptb", "non"), levels = c("ptb", "non"))
x$r <- factor(x$rec, levels = REC)
cortes <- D(c("2012-01-04", "2012-04-14", paste0(2013:2024, "-01-01"), "2024-08-07", "2024-11-16"))
x$t <- factor(findInterval(as.numeric(x$data), as.numeric(cortes)), levels = 0:16)   # 0 q1, 1 q2, 2 E12, 3..13 = 2013..2023, 14 E24, 15 q3, 16 q4
xp <- x[x$pop, ]; xg <- x[!x$pop, ]
TT <- table(xp$r, xp$t, xp$o, xp$k)                                      # 26 × 17 × 2 × 3
GG <- table(factor(format(xg$data, "%Y"), levels = 2012:2024), xg$k)       # 13 × 3 (NV de 43–44 semanas, 26 somadas)
rm(x, xp, xg); invisible(gc())
WIN <- as.character(2:14); stopifnot(dim(TT) == c(26, 17, 2, 3))
cel <- function(tt, lev_o, lev_k) apply(TT[, tt, lev_o, lev_k, drop = FALSE], 1, sum)
OK_ <- list(nv_a = list(o = c("ptb", "non"), k = c("c", "d", "e")), nv_b = list(o = c("ptb", "non"), k = c("c", "d")), nv_c = list(o = c("ptb", "non"), k = "c"),
            ptb_a = list(o = "ptb", k = c("c", "d", "e")), ptb_b = list(o = "ptb", k = c("c", "d")), ptb_c = list(o = "ptb", k = "c"))
ver <- sapply(names(OK_), function(ce) cel(WIN, OK_[[ce]]$o, OK_[[ce]]$k))      # 26 × 6, verdadeiro
anos <- 2013:2023; tano <- as.character(anos - 2010L)
ver_ano <- sapply(c("nv_a", "nv_c", "ptb_a", "ptb_c"), function(ce) vapply(tano, function(tt) sum(TT[, tt, OK_[[ce]]$o, OK_[[ce]]$k]), 0))
pc <- read.csv("01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv", colClasses = "character"); pc <- pc[match(REC, pc$recorte_principal), ]
pa <- read.csv("01_saidas/fase0_rerun/a7_populacao_dum_ano.csv", colClasses = "character")
masc <- function(v) v %in% c("supr.", "<10")
ok_cel <- all(vapply(names(OK_), function(ce) all(masc(pc[[ce]]) | suppressWarnings(as.numeric(pc[[ce]])) == ver[, ce]), TRUE)) &&
  all(vapply(colnames(ver_ano), function(ce) all(masc(pa[[ce]]) | suppressWarnings(as.numeric(pa[[ce]])) == ver_ano[, ce]), TRUE))
confere("A7", "recontagem independente (coorte pelo dum_est, consulta nomeada, table()) = cada célula publicada da A7 (26 × 6 e 11 × 4)", "todas",
        if (ok_cel) "todas" else "DIFERENTE", ok_cel && dum_div == 0 && sem_rec == 0 && identical(pa$ano, as.character(anos)))
pct_ok <- all(vapply(c("nv_b", "nv_c", "ptb_b", "ptb_c"), function(ce) { a <- sub("_.*", "_a", ce); p <- pc[[paste0(ce, "_pct")]]
  esc <- masc(pc[[ce]]) | masc(pc[[a]]); all(ifelse(esc, p == "—", p == sprintf("%.2f", 100 * ver[, ce] / ver[, a]))) }, TRUE)) &&
  all(vapply(c("nv_c", "ptb_c"), function(ce) { a <- sub("_.*", "_a", ce); p <- pa[[paste0(ce, "_pct")]]
    esc <- masc(pa[[ce]]) | masc(pa[[a]]); all(ifelse(esc, p == "—", p == sprintf("%.2f", 100 * ver_ano[, ce] / ver_ano[, a]))) }, TRUE))
confere("A7", "\"%\" mantido: = 100 × nível / (a), com 2 casas, e \"—\" exatamente onde a célula ou o (a) está suprimido", "sim", if (pct_ok) "sim" else "não", pct_ok)
# máscaras: suficientes e necessárias, linha a linha (6 átomos por linha: ptb e não ptb × c, d, e)
LOC <- rbind(nv_a = c(1, 1, 1, 1, 1, 1), nv_b = c(1, 1, 0, 1, 1, 0), nv_c = c(1, 0, 0, 1, 0, 0), ptb_a = c(1, 1, 1, 0, 0, 0), ptb_b = c(1, 1, 0, 0, 0, 0), ptb_c = c(1, 0, 0, 0, 0, 0))
SUB <- as.matrix(expand.grid(rep(list(0:1), 6)))[-1, ]; dimnames(SUB) <- NULL
pst <- function(M) if (!length(M) || !nrow(M)) 0L else qr(M, tol = 1e-9)$rank
furo_loc <- function(at6, pub) { v <- SUB %*% at6; any(vapply(which(v > 0 & v < 10), function(i) pst(rbind(LOC[pub, , drop = FALSE], SUB[i, ])) == pst(LOC[pub, , drop = FALSE]), TRUE)) }
at_l <- function(tt, rr) c(sum(TT[rr, tt, "ptb", "c"]), sum(TT[rr, tt, "ptb", "d"]), sum(TT[rr, tt, "ptb", "e"]), sum(TT[rr, tt, "non", "c"]), sum(TT[rr, tt, "non", "d"]), sum(TT[rr, tt, "non", "e"]))
suf <- nec <- logical()
for (i in seq_len(NR)) {
  pub <- names(OK_)[!masc(unlist(pc[i, names(OK_)]))]; at6 <- at_l(WIN, i)
  suf <- c(suf, !furo_loc(at6, pub))
  for (ce in setdiff(names(OK_), pub)) nec <- c(nec, furo_loc(at6, c(pub, ce)) || ver[i, ce] < 10)
}
for (j in seq_along(anos)) { pub <- c("nv_a", "nv_c", "ptb_a", "ptb_c")[!masc(unlist(pa[j, c("nv_a", "nv_c", "ptb_a", "ptb_c")]))]
  suf <- c(suf, !furo_loc(at_l(tano[j], seq_len(NR)), pub)) }
confere("A7", "máscaras suficientes (nenhuma soma de 1 a 9 dos 6 átomos da linha fica recuperável) e necessárias (publicar cada célula suprimida abriria um furo)",
        sprintf("%d linhas; %d supressões", NR + length(anos), sum(masc(unlist(pc[, names(OK_)])))),
        sprintf("suficientes %d de %d; necessárias %d de %d", sum(suf), length(suf), sum(nec), length(nec)), all(suf) && all(nec))
pares <- 0L; furo_par <- 0L
for (i in seq_len(NR)) { pub <- names(OK_)[!masc(unlist(pc[i, names(OK_)]))]
  for (cb in combn(pub, 2, simplify = FALSE)) { pares <- pares + 1L; d <- abs(ver[i, cb[1]] - ver[i, cb[2]]); furo_par <- furo_par + (d > 0 & d < 10) } }
for (j in seq_along(anos)) for (cb in combn(c("nv_a", "nv_c", "ptb_a", "ptb_c"), 2, simplify = FALSE)) {
  pares <- pares + 1L; d <- abs(ver_ano[j, cb[1]] - ver_ano[j, cb[2]]); furo_par <- furo_par + (d > 0 & d < 10) }
confere("A7", "todos os pares de diferença entre células publicadas da mesma linha (concentração e ano)", "0 de 1 a 9",
        sprintf("%d pares; %d de 1 a 9", pares, furo_par), furo_par == 0)

# ---------------------------------------------------------------- A7: modelo ampliado (tabelas da base por ano que tocam a DUM)
rb <- readLines(file.path(BASE, "RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md"), encoding = "UTF-8")
h <- grep("**Tabela 1b.", rb, fixed = TRUE) + 1; stopifnot(length(h) == 1, startsWith(rb[h], "| Ano | n |"))
j <- h + 2; while (startsWith(rb[j], "|")) j <- j + 1
t1b <- do.call(rbind, lapply(strsplit(gsub("\\\\\\|", "¦", rb[(h + 2):(j - 1)]), "|", fixed = TRUE), function(z) trimws(z[-1])))
t1b <- t1b[match(as.character(2012:2024), t1b[, 1]), ]; stopifnot(!anyNA(t1b[, 1]))
nb <- function(z) as.numeric(gsub("[^0-9]", "", z)); pb <- function(z) as.numeric(sub(",", ".", z))
tq <- function(y) as.character(if (y == 2012) 0:2 else if (y == 2024) 14:16 else y - 2010L)
popY <- function(y, o, k) sum(TT[, tq(y), o, k])
n_y <- sapply(2012:2024, function(y) popY(y, c("ptb", "non"), c("c", "d", "e")) + sum(GG[as.character(y), ]))
b_y <- sapply(2012:2024, function(y) popY(y, c("ptb", "non"), c("c", "d")) + sum(GG[as.character(y), c("c", "d")]))
k_y <- sapply(2012:2024, function(y) popY(y, c("ptb", "non"), "c") + GG[as.character(y), "c"])
k_pub <- nb(t1b[, 10]) * pb(t1b[, 11]) / 100
confere("A7", "Tabela 1b do RESPOSTA da base (NV únicos da coorte por ano): n e n comparáveis = recontagem (população do PTB + NV de 43–44 semanas); concordantes = % × n, até o arredondamento",
        "13 de 13", sprintf("n %d; comparáveis %d; concordantes %d", sum(n_y == nb(t1b[, 2])), sum(b_y == nb(t1b[, 10])), sum(abs(k_y - k_pub) <= nb(t1b[, 10]) * 5e-5 + 0.5)),
        all(n_y == nb(t1b[, 2])) && all(b_y == nb(t1b[, 10])) && all(abs(k_y - k_pub) <= nb(t1b[, 10]) * 5e-5 + 0.5))
c43 <- GG[as.character(anos), "c"]; r43 <- rowSums(GG[as.character(anos), c("d", "e")])
confere("A7", "o que a A7 por ano + a Tabela 1b isolam (tratando o % da 1b como exato): NV de 43–44 semanas concordantes, e o resto deles, por ano, 2013–2023",
        "0 ou ≥ 10", paste(unique(c(classe(c43), classe(r43))), collapse = ", "), all(classe(c(c43, r43)) %in% c("0", "≥ 10")))
# átomos: janela W[r, t(13), o, k] + pontas O[r, q(4), o, k] + NV de 43–44 G[ano(13), k]; linhas = tudo que a 09 usa, mais a
# Tabela 1b (n, comparáveis e concordantes por ano), os NV de 43–44 por ano (totais anuais) e as conciliações §A3 (Salvador e Aracaju)
TW <- as.character(2:14); TO <- as.character(c(0, 1, 15, 16)); KK <- c("c", "d", "e"); OO <- c("ptb", "non")
iW <- function(r, t, o, k) { g <- expand.grid(r = r, t = match(t, TW), o = match(o, OO), k = match(k, KK)); g$r + 26L * (g$t - 1L) + 338L * (g$o - 1L) + 676L * (g$k - 1L) }
iO <- function(r, q, o, k) { g <- expand.grid(r = r, q = match(q, TO), o = match(o, OO), k = match(k, KK)); 2028L + g$r + 26L * (g$q - 1L) + 104L * (g$o - 1L) + 208L * (g$k - 1L) }
iG <- function(y, k) { g <- expand.grid(y = y, k = match(k, KK)); 2652L + (g$y - 2011L) + 13L * (g$k - 1L) }
NAT <- 2691L
val <- numeric(NAT)
for (r in seq_len(NR)) for (o in OO) for (k in KK) { val[iW(r, TW, o, k)] <- TT[r, TW, o, k]; val[iO(r, TO, o, k)] <- TT[r, TO, o, k] }
for (y in 2012:2024) for (k in KK) val[iG(y, k)] <- GG[as.character(y), k]
stopifnot(sum(val) == sum(TT) + sum(GG))
anoP <- function(y, r, o, k) if (y == 2012) c(iW(r, "2", o, k), iO(r, c("0", "1"), o, k)) else if (y == 2024) c(iW(r, "14", o, k), iO(r, c("15", "16"), o, k)) else iW(r, as.character(y - 2010L), o, k)
L <- list(); add <- function(ix) L[[length(L) + 1]] <<- ix
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
for (i in seq_len(NR)) { add(iO(i, "0", OO, KK)); add(iO(i, "16", "ptb", KK)) }      # zeros da Q5 (publicados)
M <- matrix(0, length(L), NAT); for (ii in seq_along(L)) M[ii, L[[ii]]] <- 1
qm <- qr(t(M), tol = 1e-9); Q <- qr.Q(qm)[, seq_len(qm$rank), drop = FALSE]
idf <- function(ix) length(ix) - sum(colSums(Q[ix, , drop = FALSE])^2) < 1e-8
OKP <- list(c("ptb", "c"), c("ptb", "d"), c("ptb", "e"), c("non", "c"), c("non", "d"), c("non", "e"))
cand <- function(grupo_ix) {          # grupo_ix: lista de vetores de átomos (coordenadas); testa as 2^m − 1 uniões
  mm <- length(grupo_ix); S <- as.matrix(expand.grid(rep(list(0:1), mm)))[-1, , drop = FALSE]
  t(apply(S, 1, function(s) { ix <- unlist(grupo_ix[s == 1]); c(v = sum(val[ix]), id = idf(ix)) }))
}
coordW <- function(r, t) lapply(OKP, function(ok) iW(r, t, ok[1], ok[2]))
grupos <- c(lapply(seq_len(NR), function(i) coordW(i, TW)), lapply(tano, function(tt) coordW(seq_len(NR), tt)),
            list(coordW(seq_len(NR), "2"), coordW(seq_len(NR), "14"), coordW(seq_len(NR), c("2", "14")), coordW(seq_len(NR), TW)),
            lapply(seq_len(NR), function(i) coordW(i, c("2", "14"))), unlist(lapply(seq_len(NR), function(i) lapply(TW, function(tt) coordW(i, tt))), recursive = FALSE),
            lapply(seq_len(NR), function(i) lapply(OKP, function(ok) iO(i, TO, ok[1], ok[2]))),
            list(lapply(OKP, function(ok) iO(seq_len(NR), c("0", "1"), ok[1], ok[2])), lapply(OKP, function(ok) iO(seq_len(NR), c("15", "16"), ok[1], ok[2]))),
            lapply(2012:2024, function(y) c(lapply(OKP, function(ok) anoP(y, seq_len(NR), ok[1], ok[2])), lapply(KK, function(k) iG(y, k)))))
rs <- do.call(rbind, lapply(grupos, cand))
peq <- rs[, "v"] > 0 & rs[, "v"] < 10; furos <- sum(peq & rs[, "id"] == 1)
ctl_pub <- all(vapply(L, idf, TRUE))
confere("A7", sprintf("modelo ampliado (%d linhas, posto %d; com a Tabela 1b, os NV de 43–44 por ano e as conciliações §A3): uniões candidatas de 1 a 9 identificáveis", length(L), qm$rank),
        "0", sprintf("%d candidatas; %d de 1 a 9; identificáveis entre elas %d; células publicadas identificáveis: %s", nrow(rs), sum(peq), furos, ctl_pub),
        furos == 0 && ctl_pub)

# ================================================================ A8
d9 <- readLines(lg("desvio9_fase0_rerun_"), encoding = "UTF-8")
m9 <- regmatches(d9, regexec("^\\| (F[0-9]+) \\| `([^`]+)` \\| `([0-9a-f]{64})` \\|", d9)); m9 <- do.call(rbind, m9[lengths(m9) == 4])
f9 <- vapply(seq_len(nrow(m9)), function(i) identical(sha256(file.path("/Volumes/Forja/Doc", m9[i, 3])), m9[i, 4]), TRUE)
a52 <- read.csv("01_saidas/fase0_rerun/a5_2_eventos_janelas.csv")
ok9 <- any(grepl("As quatro condições do desvio 9 se mantêm", d9, fixed = TRUE)) && sum(grepl("**Com valor de 1 a 9: 0.**", d9, fixed = TRUE)) == 2 &&
  sum(a52$perda %in% 1:9) == 0 && min(a52$perda[a52$perda > 0]) == 40
confere("A8", "log da A8: frase de resultado, 0 uniões de 1 a 9 nos dois desfechos, perda sem 1 a 9 e menor perda 40 (recalculadas do CSV); SHA-256 das fontes = arquivos agora",
        sprintf("sim; %d de %d", nrow(m9), nrow(m9)), sprintf("%s; %d de %d", if (ok9) "sim" else "não", sum(f9), nrow(m9)), ok9 && all(f9) && nrow(m9) == 16)

# ================================================================ A9
dv <- readLines("logs/desvios_especificacao.md", encoding = "UTF-8"); nd <- as.integer(sub("^\\| ([0-9]+) \\|.*", "\\1", grep("^\\| [0-9]+ \\|", dv, value = TRUE)))
r2 <- grep("^\\| 10 \\|", dv, value = TRUE); r9 <- grep("^\\| 11 \\|", dv, value = TRUE)
ok_a9 <- identical(nd, seq_len(max(nd))) && max(nd) >= 11 &&
  grepl("**Resolução do nº 2 (`DTULTMENST`):** resolvido pela base `4443971b` (decisões §8): coluna `ig_dum_sem`; §3.5 desbloqueada", r2, fixed = TRUE) &&
  grepl("**Resolução do nº 9:** aprovado pelo chat de métodos (decisões, Revisão 2, §6); condições reconferidas na Fase 0 refeita:", r9, fixed = TRUE)
confere("A9", "log de desvios: linhas novas numeradas a partir de 10, com as frases do prompt para a resolução do nº 2 e do nº 9", sprintf("1–%d", max(nd)),
        if (ok_a9) "sim" else "não", ok_a9)

# ================================================================ log
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
confere("C8", "versao() no início e no fim", "4443971b e 4443971b", paste(v_ini, "e", v_fim), v_ini == "4443971b" && v_fim == "4443971b")
md <- c("# Autoauditoria por código dos itens novos da Fase 0 refeita (A0–A9, fora o que o `03` cobre)", "",
        sprintf("- **Gerado por:** `00_scripts/12_autoauditoria_itens_novos_rerun.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        "- **A7 por caminho independente do `09`:** a coorte vem do `dum_est` (2011-07-31 a 2024-03-05), sem as flags `pop_ptb`, `ptb` e `coorte_fixa_22`; a concentração, de uma consulta nomeada ao `concentracoes()`; as contagens, de `table()`. Microdado só agregado em memória.",
        "- **Contagens de 1 a 9:** só a classe sai (\"0\", \"1 a 9\", \"≥ 10\").",
        "- **Modelo ampliado da A7:** o mesmo do `09` (A7, A5.2 do PTB, totais anuais, zeros da Q5), mais a Tabela 1b do RESPOSTA da base (n, comparáveis e concordantes por ano, 2012–2024; o % tratado como exato, o que é conservador), os NV de 43–44 semanas por ano e as conciliações §A3 (NV e PTB por ano em Salvador e em Aracaju), com as pontas fora da janela separadas por nível da DUM.",
        sprintf("- **Resultado:** %d de %d conferências ok.", sum(res$ok), nrow(res)), "",
        "| Item | Conferência | Esperado | Obtido | Ok |", "|---|---|---|---|---|",
        sprintf("| %s | %s | %s | %s | %s |", res$item, res$conferencia, res$esperado, res$obtido, ifelse(res$ok, "sim", "**NÃO**")), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "\n")
print(res[, c("item", "obtido", "ok")], row.names = FALSE, right = FALSE)
if (!all(res$ok)) quit(status = 1)
