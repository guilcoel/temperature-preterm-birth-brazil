# 46_fracao_atribuivel.R — Fase 3, Parte C, C5: fração atribuível nas três análises da D1 (principal forward com os
# BLUPs; ponte forward com os reduzidos da primeira etapa; backward com os 16 coeficientes da primeira etapa), nas 26
# concentrações e no total, com a attrdl conferida por SHA-256 e o código das tags. Escolhas no desvio 77 (d) a (f).
# Antes de calcular, confere: o código contra as duas tags, a attrdl.R, o BLAS e o LAPACK, o SHA-256 das entradas e o da
# RDS do 45 contra o log dele. Por concentração i (posição na ordem travada):
#   - forward: as 4.498 linhas da janela (tmean_nucleo e ptb); backward: as 4.505 linhas, com ptb = NA no aquecimento;
#   - basis = monta_cb nas 4.505 linhas, com a argvar e a arglag da RDS; cen = TMR BLUP da grade p1–p99 (D4(g));
#   - componentes da D4(h) com o p2,5 e o p97,5 da concentração; semente 20261001 + i antes de cada chamada (C1);
#   - o denominador, nas três análises, tem de ser igual ao n$eventos da primeira etapa.
# Total: soma dos AN; eCI pelos percentis da soma, sorteio a sorteio, das simulações das 26; AF = AN / soma dos
# denominadores. Contribuições negativas: soma das contribuições diárias negativas ao AN total (attrdl com tot = FALSE,
# só a estimativa pontual), calculada aqui e gravada só como soma na janela. Nenhuma série diária, AN ou AF diário sai.
# Grava logs/fracao_atribuivel_fase3_<FASE3_DATA>.md e 01_saidas/fase3/*. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/46_fracao_atribuivel.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; CC <- file.path("..", "codigo_compartilhado")
arq <- file.path("logs", paste0("fracao_atribuivel_fase3_", hoje, ".md")); stopifnot(!file.exists(arq))
L45_arq <- file.path("logs", paste0("segunda_etapa_fase3_", hoje, ".md"))
OUT <- file.path("01_saidas", "fase3"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
f45 <- file.path(OUT, paste0("segunda_etapa_principal_fase3_", hoje, ".rds"))
saidas <- c(af = file.path(OUT, paste0("fracao_atribuivel_fase3_", hoje, ".csv")), neg = file.path(OUT, paste0("contribuicoes_negativas_fase3_", hoje, ".csv")),
            sims = file.path(OUT, paste0("fracao_atribuivel_simulacoes_fase3_", hoje, ".rds")))
stopifnot(!any(file.exists(saidas)))
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
escreve_csv <- function(df, p) { num <- vapply(df, is.double, TRUE); df[num] <- lapply(df[num], function(v) ifelse(is.na(v), NA, sprintf("%.17g", v)))
  utils::write.csv(df, p, row.names = FALSE, na = "", fileEncoding = "UTF-8") }

# ------------------------------------------------------------------ BLAS, código = tags, attrdl.R
s_info <- sessionInfo()
if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib"))
  stop("BLAS/LAPACK fora da referência (§8): ", s_info$BLAS, " / ", s_info$LAPACK)
TAGS <- c("ajusta_dlnm-v1.0" = "caf5022f9a655877d8e3931dd3d02d7dce429fe5", "segunda_etapa-v1.0" = "410dd6d6d3d315004f22fd7197c326de77f3c2f4")
for (tg in names(TAGS)) {
  if (!identical(git("rev-parse", paste0(tg, "^{commit}")), TAGS[[tg]])) stop("a tag ", tg, " não aponta para o commit esperado")
  arqs_R <- git("ls-tree", "-r", "--name-only", tg, "codigo_compartilhado/R/")
  st <- vapply(arqs_R, function(a) sub(" .*", "", system(paste("git -C", shQuote(REPO), "show", shQuote(paste0(tg, ":", a)), "| shasum -a 256"), intern = TRUE)), "")
  if (!identical(unname(st), unname(vapply(arqs_R, function(a) sha(file.path(REPO, a)), "")))) stop("codigo_compartilhado/R/ no disco difere da tag ", tg)
}
sha_se <- sha(file.path(CC, "R", "segunda_etapa.R"))
f_at <- file.path(CC, "inst", "terceiros", "attrdl.R"); SHA_ATTRDL <- "d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d"
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta) })
f <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = f); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f)
attrdl <- f$carrega_attrdl(f_at, SHA_ATTRDL)

# ------------------------------------------------------------------ entradas e RDS do 45
ENT <- c(rds2 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", ser1 = "01_saidas/fase1/serie_ptb_principal.rds")
SHA_ENT <- c(rds2 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d", ser1 = "635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917")
sha_ent <- vapply(ENT, sha, ""); if (!identical(sha_ent, SHA_ENT)) stop("entrada com SHA-256 diferente do registrado")
L45 <- paste(readLines(L45_arq, encoding = "UTF-8"), collapse = "\n"); sha45 <- sha(f45)
if (!grepl(sprintf("`%s`: `%s`", f45, sha45), L45, fixed = TRUE)) stop("RDS do 45 com SHA-256 diferente do log do 45")
r45 <- readRDS(f45)
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES; stopifnot(identical(r45$ordem, ordem))
nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE); idx <- setNames(f$indice_concentracao(ordem), ordem)
P1 <- readRDS(ENT[["rds2"]])$resultados[ordem]; P1 <- lapply(P1, `[[`, "principal")
INI <- as.Date("2012-04-07"); INI_JAN <- as.Date("2012-04-14"); FIM <- as.Date("2024-08-06")
s <- readRDS(ENT[["ser1"]]); s <- as.data.frame(s)[s$data >= INI & s$data <= FIM, c("recorte_principal", "data", "tmean_nucleo", "ptb", "janela_principal")]
serie <- lapply(ordem, function(r) { z <- s[s$recorte_principal == r, ]; z <- z[order(z$data), ]
  stopifnot(nrow(z) == 4505L, all(diff(z$data) == 1), identical(z$janela_principal, z$data >= INI_JAN), sum(z$janela_principal) == 4498L,
            !anyNA(z$tmean_nucleo), !anyNA(z$ptb[z$janela_principal])); z }); names(serie) <- ordem; rm(s)
tmr_b <- r45$tmr[r45$tmr$nivel == "blup", ]; tmr_b <- setNames(tmr_b$tmr, tmr_b$recorte_principal)
log_msg("conferências de código, BLAS, entradas e RDS do 45: ok")

# ------------------------------------------------------------------ C5: as três análises por concentração
AN <- c("principal", "ponte", "backward")
tab <- list(); sims <- list(); neg <- list(); den_ok <- list(); adit <- list()
for (r in ordem) {
  z <- serie[[r]]; jw <- which(z$janela_principal); p <- P1[[r]]; b <- r45$blup[[r]]; g <- r45$grade[r, ]; i <- idx[[r]]
  cb <- f$monta_cb(z$tmean_nucleo, z$data, p$base$argvar, p$base$arglag, lag = 7)
  args <- list(
    principal = list(x = z$tmean_nucleo[jw], cases = z$ptb[jw], datas = z$data[jw], coef = b$coef, vcov = b$vcov),
    ponte = list(x = z$tmean_nucleo[jw], cases = z$ptb[jw], datas = z$data[jw], coef = unname(p$reduzida$coef), vcov = unname(p$reduzida$vcov)),
    backward = list(x = z$tmean_nucleo, cases = c(rep(NA_real_, 7), z$ptb[jw]), datas = z$data, coef = unname(p$coef_cb), vcov = unname(p$vcov_cb)))
  for (a in AN) {
    A <- args[[a]]
    fa <- f$fracao_atribuivel(a, A$x, A$cases, A$datas, cb, A$coef, A$vcov, tmr_b[[r]], g[["p2,5"]], g[["p97,5"]], i, attrdl, nsim = 1000)
    if (fa$status != "ok") stop(nome[[r]], " / ", a, ": ", fa$mensagem)
    tab[[paste(r, a)]] <- cbind(data.frame(analise = a, recorte_principal = r, stringsAsFactors = FALSE), fa$componentes, denominador = fa$denominador, semente = fa$semente)
    sims[[a]][[r]] <- fa$sims
    den_ok[[paste(r, a)]] <- identical(as.integer(fa$denominador), as.integer(p$n$eventos))
    ad <- setNames(fa$componentes$an, fa$componentes$componente)
    adit[[paste(r, a)]] <- data.frame(analise = a, recorte_principal = r, dif = unname(ad["total"] - ad["calor"] - ad["frio"]),
                                      dif_sims = max(abs(fa$sims[, "total"] - fa$sims[, "calor"] - fa$sims[, "frio"])))
    dir <- if (a == "backward") "back" else "forw"
    v <- attrdl(A$x, cb, A$cases, coef = A$coef, vcov = A$vcov, type = "an", dir = dir, tot = FALSE, cen = tmr_b[[r]], sim = FALSE)
    fora <- A$x < g[["p1"]] | A$x > g[["p99"]]; ng <- !is.na(v) & v < 0                # no forward, a contribuição do dia t vem da exposição do dia t
    neg[[paste(r, a)]] <- data.frame(analise = a, recorte_principal = r, soma_negativas = sum(v[ng]), alguma = any(ng),
                                     soma_negativas_fora_p1_p99 = if (dir == "forw") sum(v[ng & fora]) else NA_real_,
                                     soma_negativas_dentro_p1_p99 = if (dir == "forw") sum(v[ng & !fora]) else NA_real_,
                                     denominador = fa$denominador, stringsAsFactors = FALSE)
  }
  log_msg(nome[[r]], "ok")
}
if (!all(unlist(den_ok))) stop("denominador diferente do n$eventos da primeira etapa: ", paste(names(den_ok)[!unlist(den_ok)], collapse = ", "))
tab <- do.call(rbind, tab); rownames(tab) <- NULL; neg <- do.call(rbind, neg); rownames(neg) <- NULL; adit <- do.call(rbind, adit); rownames(adit) <- NULL
adit_fw <- adit[adit$analise != "backward", ]
if (max(abs(adit_fw$dif)) > 1e-8 || max(adit_fw$dif_sims) > 1e-8) stop("forward: calor + frio diferente do total")

# ------------------------------------------------------------------ total das 26
COMP <- c("total", "calor", "frio", "calor_extremo", "frio_extremo")
den_c <- tab[tab$analise == "principal" & tab$componente == "total", c("recorte_principal", "denominador")]; stopifnot(nrow(den_c) == 26)   # uma linha por concentração
den_tot <- sum(den_c$denominador)
tot <- do.call(rbind, lapply(AN, function(a) do.call(rbind, lapply(COMP, function(cmp) {
  an <- sum(tab$an[tab$analise == a & tab$componente == cmp])
  sm <- Reduce(`+`, lapply(ordem, function(r) sims[[a]][[r]][, cmp])); q <- unname(stats::quantile(sm, c(0.025, 0.975), type = 7))
  data.frame(analise = a, recorte_principal = "total", componente = cmp, an = an, an_li = q[1], an_ls = q[2], af = an / den_tot, af_li = q[1] / den_tot,
             af_ls = q[2] / den_tot, denominador = den_tot, semente = NA_integer_, stringsAsFactors = FALSE) }))))
af_t <- rbind(tab, tot)
escreve_csv(af_t, saidas[["af"]]); escreve_csv(neg, saidas[["neg"]])
saveRDS(list(simulacoes = sims, ordem = ordem, sha_segunda_etapa = sha_se, sha_attrdl = SHA_ATTRDL, sha_rds45 = sha45, data = hoje), saidas[["sims"]])
sha_out <- vapply(saidas, sha, "")

# ------------------------------------------------------------------ log
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
an_txt <- function(d) sprintf("%s (%s a %s)", br(d$an, 0), br(d$an_li, 0), br(d$an_ls, 0))
af_txt <- function(d) sprintf("%s%% (%s a %s)", br(100 * d$af, 2), br(100 * d$af_li, 2), br(100 * d$af_ls, 2))
rot_c <- c(total = "Total", calor = "Calor", frio = "Frio", calor_extremo = "Calor extremo (> p97,5)", frio_extremo = "Frio extremo (< p2,5)")
rot_a <- c(principal = "Principal (forward, BLUPs)", ponte = "Ponte (forward, reduzidos da primeira etapa; diagnóstico)", backward = "Sensibilidade (backward, 16 coeficientes da primeira etapa)")
tabela_conc <- function(a) do.call(rbind, lapply(ordem, function(r) { d <- tab[tab$analise == a & tab$recorte_principal == r, ]; d <- d[match(COMP, d$componente), ]
  data.frame(Concentração = nome[[r]], i = idx[[r]], `AN total (eCI)` = an_txt(d[1, ]), `AF total (eCI)` = af_txt(d[1, ]), Calor = an_txt(d[2, ]), Frio = an_txt(d[3, ]),
             `Calor extremo` = an_txt(d[4, ]), `Frio extremo` = an_txt(d[5, ]), check.names = FALSE) }))
tabela_af <- function(a) do.call(rbind, lapply(ordem, function(r) { d <- tab[tab$analise == a & tab$recorte_principal == r, ]; d <- d[match(COMP, d$componente), ]
  data.frame(Concentração = nome[[r]], Total = af_txt(d[1, ]), Calor = af_txt(d[2, ]), Frio = af_txt(d[3, ]), `Calor extremo` = af_txt(d[4, ]), `Frio extremo` = af_txt(d[5, ]), check.names = FALSE) }))
fr_r <- r45$tmr$recorte_principal[r45$tmr$nivel == "blup" & r45$tmr$fronteira]
ce_igual <- vapply(ordem, function(r) tmr_b[[r]] >= r45$grade[r, "p97,5"], TRUE)
np <- neg[neg$analise == "principal", ]; nfw <- neg[neg$analise != "backward", ]
md_txt <- c("# Fase 3, Parte C, C5: fração atribuível (D1)", "",
  sprintf("- **Gerado por:** `00_scripts/46_fracao_atribuivel.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
  sprintf("- **Ambiente:** R %s; dlnm %s; tsModel %s. BLAS/LAPACK: `%s` / `%s` (referência). Semente 20261001 + i antes de cada chamada da `attrdl` da concentração i (complemento C1); 1.000 simulações.",
          paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("tsModel"), s_info$BLAS, s_info$LAPACK),
  sprintf("- **Código:** igual às tags `ajusta_dlnm-v1.0` e `segunda_etapa-v1.0`; `codigo_compartilhado/R/segunda_etapa.R`: `%s`; `attrdl.R`: `%s`.", sha_se, SHA_ATTRDL),
  "- **Entradas (SHA-256 conferidos):**", sprintf("  - `%s`: `%s`;", c(ENT, f45), c(sha_ent, sha45)), "  - a RDS do 45 confere com o log do 45.",
  "- **Linhas:** *forward* (principal e ponte) nas 4.498 linhas da janela; *backward* nas 4.505 linhas, com `ptb` = NA nos 7 dias de aquecimento. `cen` = TMR BLUP da grade p1–p99 de cada concentração, mesmo na fronteira (D4(g)).", "",
  "## Denominador", "",
  sprintf("- O denominador de cada concentração (eventos da janela principal) é igual ao `n$eventos` da primeira etapa nas três análises: %s. Total das 26: %s eventos.",
          if (all(unlist(den_ok))) "sim, nas 26" else "NÃO", br(den_tot, 0)), "",
  tabela_md(data.frame(Concentração = nome[ordem], i = idx[ordem], Denominador = br(den_c$denominador[match(ordem, den_c$recorte_principal)], 0), check.names = FALSE)), "",
  "## Total das 26 concentrações", "",
  "AN = número atribuível (arredondado ao inteiro; estimativa, não contagem, sem a máscara \"<10\"; D4(d)); AF = AN / total de eventos da janela; eCI 95% pelos percentis 2,5 e 97,5 da soma, sorteio a sorteio, das simulações das 26.", "",
  tabela_md(do.call(rbind, lapply(AN, function(a) do.call(rbind, lapply(COMP, function(cmp) { d <- tot[tot$analise == a & tot$componente == cmp, ]
    data.frame(`Análise` = rot_a[[a]], Componente = rot_c[[cmp]], `AN (eCI)` = an_txt(d), `AF (eCI)` = af_txt(d), check.names = FALSE) }))))), "",
  "**Leitura das três análises (D1, item 3; sem leitura inferencial da ponte):** principal × ponte isola o efeito do encolhimento; ponte × *backward*, o da perspectiva.", "",
  "## Por concentração", "",
  unlist(lapply(AN, function(a) c(sprintf("### %s", rot_a[[a]]), "", "**AN por componente e AF do total (eCI):**", "", tabela_md(tabela_conc(a)), "",
                                  "**AF por componente (eCI):**", "", tabela_md(tabela_af(a)), ""))),
  "## Contribuições negativas", "",
  "Soma, na janela, das contribuições diárias negativas ao AN total (estimativa pontual da `attrdl` com `tot = FALSE`; no *forward*, sem a reescala da função). Só a soma sai; nenhuma contribuição diária é gravada.", "",
  sprintf("- **Concentrações com alguma contribuição diária negativa:** principal %d de 26; ponte %d de 26; *backward* %d de 26. Inclui contribuições minúsculas: a TMR é o mínimo só nos pontos da grade de 0,1 °C, e entre dois pontos a curva pode descer um pouco abaixo dela.",
          sum(neg$alguma[neg$analise == "principal"]), sum(neg$alguma[neg$analise == "ponte"]), sum(neg$alguma[neg$analise == "backward"])),
  sprintf("- **Concentrações com soma das contribuições negativas de pelo menos 1 evento atribuível (arredondada ≤ −1):** principal %d de 26; ponte %d de 26; *backward* %d de 26.",
          sum(round(neg$soma_negativas[neg$analise == "principal"]) <= -1), sum(round(neg$soma_negativas[neg$analise == "ponte"]) <= -1), sum(round(neg$soma_negativas[neg$analise == "backward"]) <= -1)), "",
  sprintf("- **Onde estão (forward):** no principal, a soma das contribuições negativas é %s, das quais %s vêm de dias com temperatura fora de p1–p99 e %s de dias dentro; na ponte, %s, com %s fora e %s dentro. A TMR é o mínimo só entre p1 e p99 (C5): fora dessa faixa, a curva pode ficar abaixo dela. As concentrações com TMR BLUP na fronteira são %d (%s); a TMR fica no p97,5 ou acima em %d concentrações, e nelas o calor extremo é igual ao calor por construção (D4(h)).",
          br(sum(np$soma_negativas), 1), br(sum(np$soma_negativas_fora_p1_p99), 1), br(sum(np$soma_negativas_dentro_p1_p99), 3),
          br(sum(neg$soma_negativas[neg$analise == "ponte"]), 1), br(sum(neg$soma_negativas_fora_p1_p99[neg$analise == "ponte"]), 1), br(sum(neg$soma_negativas_dentro_p1_p99[neg$analise == "ponte"]), 1),
          length(fr_r), paste(nome[fr_r], collapse = ", "), sum(ce_igual)),
  if (sum(neg$soma_negativas_dentro_p1_p99[neg$analise == "ponte"]) < sum(neg$soma_negativas_fora_p1_p99[neg$analise == "ponte"]))
    "- Na ponte, a maior parte vem de dias dentro de p1–p99: a curva sem encolhimento tem outro mínimo, e, com o `cen` na TMR BLUP, pode ficar abaixo de 1 perto dele (D1, limitações)." else NULL,
  "- No *backward*, a contribuição do dia t vem das exposições de t − 7 a t, e a soma não é separada por faixa.", "",
  tabela_md(do.call(rbind, lapply(ordem, function(r) { d <- neg[neg$recorte_principal == r, ]; d <- d[match(AN, d$analise), ]
    data.frame(Concentração = nome[[r]], `TMR na fronteira` = if (r %in% fr_r) "sim" else "não", Principal = br(d$soma_negativas[1], 0), `Principal, fora de p1–p99` = br(d$soma_negativas_fora_p1_p99[1], 0),
               Ponte = br(d$soma_negativas[2], 0), `Ponte, fora de p1–p99` = br(d$soma_negativas_fora_p1_p99[2], 0), Backward = br(d$soma_negativas[3], 0), check.names = FALSE) }))), "",
  "## Aditividade e os 7 últimos dias", "",
  sprintf("- **Forward (principal e ponte):** |total − (calor + frio)| máximo %s na estimativa e %s nas simulações (critério ≤ 1e-8). **Backward** (só reportado, sem teste; complemento C1, item 5): total − (calor + frio) entre %s e %s.",
          formatC(max(abs(adit_fw$dif)), format = "e", digits = 1), formatC(max(adit_fw$dif_sims), format = "e", digits = 1),
          br(min(adit$dif[adit$analise == "backward"]), 1), br(max(adit$dif[adit$analise == "backward"]), 1)),
  "- **Os 7 últimos dias da janela (D1, item 5):** no *forward*, a média dos eventos de t a t + 7 fica NA nos 7 últimos dias da janela; a `attrdl` exclui esses dias do cálculo da AF e reescala o AN ao total observado; os eventos depois de 2024-08-06 não são usados. O *backward* não perde esses dias.", "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", saidas, sha_out), "",
  sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md_txt, arq, useBytes = TRUE)
cat("gravado:", arq, "| AF total principal:", round(100 * tot$af[tot$analise == "principal" & tot$componente == "total"], 2), "%\n")
