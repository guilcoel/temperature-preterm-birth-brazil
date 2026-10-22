# 44_testes_tag_fase3.R — Fase 3, Parte B, passo 2: roda os testes de novo antes da tag `segunda_etapa-v1.0` (log próprio,
# porque o 41 tem trava contra sobrescrita). Bateria: os testes rápidos e o teste 5 (Monte Carlo, 1.000 réplicas) do
# segunda_etapa.R, os mesmos do 41, sem os defeitos plantados. Confere que:
#   - nada está pendente em artigo1_prematuridade/ nem em codigo_compartilhado/ antes de rodar, fora este script;
#   - o commit da Parte A (COMMIT_A, alvo da tag) é ancestral do HEAD, e codigo_compartilhado/ no disco é igual a ele;
#   - o desvio 76 está no HEAD (registrado antes desta rodada);
#   - o código e os testes no disco têm os SHA-256 do log do 41; ajusta_dlnm.R e offset.R, os da tag ajusta_dlnm-v1.0;
#   - cada teste dá o mesmo resultado do log do 41, e os parâmetros declarados, os números do Monte Carlo (salvo a
#     duração) e os valores descritivos dos testes rápidos saem com o mesmo texto do log do 41.
# Conferência do desvio 76: numa cópia do segunda_etapa.R, o BLUP de cada unidade vira a parte fixa X_iβ̂
# (predict(fit) do mixmeta, com a vcov do BLUP mantida); a bateria rápida e o teste 5 rodam nessa cópia, este mesmo que
# um teste rápido caia, e o log informa que testes caem e com que mensagem.
# Dados reais só como no 41 (atributos, exposição, percentis, metapreditores e vcov como covariâncias; desvio 72d).
# Semente 20261001, em série. Grava logs/testes_tag_fase3_<FASE3_DATA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/44_testes_tag_fase3.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("testes_tag_fase3_", hoje, ".md")); stopifnot(!file.exists(arq))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
pend <- git("status", "--porcelain", "--untracked-files=all", "--", "artigo1_prematuridade", "codigo_compartilhado")
pend <- setdiff(pend, "?? artigo1_prematuridade/00_scripts/44_testes_tag_fase3.R")   # o próprio script, ainda sem commit
if (length(pend)) stop("há arquivo pendente em artigo1_prematuridade/ ou codigo_compartilhado/: rodar só com o status limpo")
COMMIT_A <- "410dd6d6d3d315004f22fd7197c326de77f3c2f4"                 # commit da Parte A, alvo da tag
if (!identical(git("rev-parse", paste0(substr(COMMIT_A, 1, 7), "^{commit}")), COMMIT_A)) stop("COMMIT_A não confere com o repositório")
if (system2("git", c("-C", REPO, "merge-base", "--is-ancestor", COMMIT_A, "HEAD")) != 0) stop("o commit da Parte A não é ancestral do HEAD")
if (length(git("diff", "--name-only", COMMIT_A, "--", "codigo_compartilhado"))) stop("codigo_compartilhado/ difere do commit da Parte A")
head_c <- git("rev-parse", "HEAD"); head_s <- git("log", "-1", "--format=%h %s")
d76 <- grepl("^\\| 76 \\| 2026-10-13 \\|", git("show", "HEAD:artigo1_prematuridade/logs/desvios_especificacao.md"))
if (sum(d76) != 1) stop("o desvio 76 não está no HEAD")
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta) })
CC <- file.path("..", "codigo_compartilhado")
f_se <- file.path(CC, "R", "segunda_etapa.R"); f_aj <- file.path(CC, "R", "ajusta_dlnm.R")
f_tr <- file.path(CC, "tests", "testa_segunda_etapa.R"); f_tm <- file.path(CC, "tests", "testa_segunda_etapa_mc.R"); f_run <- file.path(CC, "tests", "roda_testes.R")
f_at <- file.path(CC, "inst", "terceiros", "attrdl.R"); SHA_ATTRDL <- "d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d"
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
ic <- function(v, d = 3) sprintf("[%s; %s]", br(v[1], d), br(v[2], d))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
L41 <- paste(readLines(file.path("logs", paste0("testes_segunda_etapa_fase3_", hoje, ".md")), encoding = "UTF-8"), collapse = "\n")

# ------------------------------------------------------------------ SHA-256: o disco é o que o 41 testou (e a tag ajusta_dlnm-v1.0)
arqs41 <- c("codigo_compartilhado/R/segunda_etapa.R", "codigo_compartilhado/R/ajusta_dlnm.R", "codigo_compartilhado/tests/testa_segunda_etapa.R",
            "codigo_compartilhado/tests/testa_segunda_etapa_mc.R", "codigo_compartilhado/tests/roda_testes.R", "codigo_compartilhado/inst/terceiros/attrdl.R")
sha41 <- vapply(arqs41, function(a) sha(file.path("..", a)), "")
no41 <- vapply(arqs41, function(a) grepl(sprintf("`%s`: `%s`", a, sha41[[a]]), L41, fixed = TRUE), TRUE)
if (!all(no41)) stop("SHA-256 diferente do testado no 41: ", paste(arqs41[!no41], collapse = ", "))
if (!identical(sha41[["codigo_compartilhado/inst/terceiros/attrdl.R"]], SHA_ATTRDL)) stop("attrdl.R com SHA-256 diferente do registrado")
tag_aj <- git("cat-file", "-p", "ajusta_dlnm-v1.0")
for (a in c("codigo_compartilhado/R/ajusta_dlnm.R", "codigo_compartilhado/R/offset.R"))
  if (!any(tag_aj == paste0(sha(file.path("..", a)), "  ", a))) stop(a, " difere do registrado na tag ajusta_dlnm-v1.0")
todos_arq <- git("ls-files", "--", "codigo_compartilhado/R", "codigo_compartilhado/tests")
sha_todos <- vapply(todos_arq, function(a) sha(file.path("..", a)), "")

# ------------------------------------------------------------------ entradas e .R3 (como no 41)
ENT <- c(rds2 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", ref = "01_saidas/fase1/referencias_exposicao.csv",
         ser1 = "01_saidas/fase1/serie_ptb_principal.rds", a0 = paste0("01_saidas/fase3/percentis_exposicao_fase3_", hoje, ".csv"))
SHA_ENT <- c(rds2 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d", ref = "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467",
             ser1 = "635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917")
sha_ent <- vapply(ENT, sha, "")
if (!identical(sha_ent[names(SHA_ENT)], SHA_ENT)) stop("entrada com SHA-256 diferente do registrado: ", paste(names(SHA_ENT)[sha_ent[names(SHA_ENT)] != SHA_ENT], collapse = ", "))
if (!grepl(sprintf("`%s`: `%s`", ENT[["a0"]], sha_ent[["a0"]]), L41, fixed = TRUE)) stop("grade da A0 com SHA-256 diferente da usada no 41")
source(f_run); source(f_tr); source(f_tm)
carrega <- function(arquivo_se) { e <- new.env(); sys.source(f_aj, envir = e); sys.source(arquivo_se, envir = e); e }
f0 <- carrega(f_se); ordem <- f0$ORDEM_CONCENTRACOES
nuc <- as.data.frame(cidade_nucleo()); f0$confere_ordem(nuc$CD_RECORTE); .R3$codigos <- nuc$CD_RECORTE
rds <- readRDS(ENT[["rds2"]])$resultados
.R3$argvar <- lapply(ordem, function(r) rds[[r]]$principal$base$argvar); .R3$arglag <- lapply(ordem, function(r) rds[[r]]$principal$base$arglag)
.R3$S <- lapply(ordem, function(r) rds[[r]]$principal$reduzida$vcov); rm(rds)                 # só as vcov reduzidas, como covariâncias
s <- readRDS(ENT[["ser1"]]); s <- s[s$data >= as.Date("2012-04-07") & s$data <= as.Date("2024-08-06"), c("recorte_principal", "data", "tmean_nucleo")]
.R3$x <- lapply(ordem, function(r) { z <- s[s$recorte_principal == r, ]; stopifnot(nrow(z) == 4505); z$tmean_nucleo[order(z$data)] }); rm(s)
gr <- utils::read.csv(ENT[["a0"]], colClasses = c(recorte_principal = "character"))
.R3$grade <- t(vapply(ordem, function(r) { z <- gr[gr$recorte_principal == r, ]; setNames(z$valor, z$rotulo) }, numeric(101)))
ez <- gr[gr$recorte_principal == "eixo_medio", ]; .R3$eixo <- setNames(ez$valor, ez$rotulo)
ref <- utils::read.csv(ENT[["ref"]], colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ordem, ref$recorte_principal), ]; stopifnot(identical(ref$recorte_principal, ordem))
.R3$nos_csv <- as.matrix(ref[, c("p10", "p75", "p90")]); .R3$metapred <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1)
.R3$attrdl_path <- f_at; .R3$attrdl <- f0$carrega_attrdl(f_at, SHA_ATTRDL); .R3$R_mc <- 1000L

# ------------------------------------------------------------------ bateria (a mesma do 41)
log_msg("bateria: rápidos"); r_u <- roda_testes(f0, testes_segunda_etapa); T3_u <- as.list(.T3)
log_msg("bateria: Monte Carlo (1.000 réplicas)"); .R3$relata_tmr <- TRUE; t_mc <- Sys.time()
r_m <- roda_testes(f0, testes_segunda_etapa_mc); dur_mc <- as.numeric(Sys.time() - t_mc, units = "mins"); T3_m <- as.list(.T3)
todos <- rbind(r_u, r_m); print(todos[, c("teste", "ok")], row.names = FALSE)
lin41 <- vapply(seq_len(nrow(todos)), function(i) sprintf("| `%s` | %s |", todos$teste[i], if (todos$ok[i]) "passou" else paste("FALHOU:", todos$mensagem[i])), "")
igual41 <- vapply(lin41, function(l) grepl(l, L41, fixed = TRUE), TRUE)
n_41 <- regmatches(L41, regexpr("(?<=## Resultado: )[0-9]+/[0-9]+", L41, perl = TRUE)); n_44 <- sprintf("%d/%d", sum(todos$ok), nrow(todos))

# textos com a mesma formatação do 41 (parâmetros declarados, Monte Carlo sem a duração, valores descritivos)
t5 <- T3_m$t05; d5 <- T3_m$t05_decl
txt <- c(
  base = sprintf("- **Base:** a combinada das 26 `argvar` reais (D2): ns com nós %s e Boundary.knots %s °C.", paste(br(d5$base$knots, 3), collapse = "; "), paste(br(d5$base$Boundary.knots, 3), collapse = " e ")),
  beta = sprintf("projeção, por mínimos quadrados na grade de 301 pontos entre os Boundary.knots, de log RR verdadeiro contra o x50 = 0,02 por °C acima do x75 do eixo médio: %s. Log RR verdadeiro em x99 contra x50 = %s (exigido ≥ 0,05).",
                 paste(formatC(d5$beta, format = "e", digits = 4), collapse = "; "), br(d5$v99, 5)),
  psi = sprintf("com DP = metade da raiz da média das variâncias das S_i (%s) e correlação 0,3 entre os 4 coeficientes.", paste(formatC(d5$sdp, format = "e", digits = 3), collapse = "; ")),
  cen = sprintf("- **cen:** x50 do eixo médio (%s °C). **TMR verdadeira** (mínimo da curva verdadeira na grade entre x1 e x99 do eixo): %s °C. **Réplicas:** %d de 26 unidades;", br(d5$cen, 3), br(d5$tmr_verdadeira, 1), d5$R),
  cobertura = sprintf("- **Cobertura do IC 95%% do log RR combinado em x99 contra x50:** %s (EP de MC %s; IC Wilson %s); critério 0,92–0,98.", br(t5$cobertura, 3), br(t5$ep_cob, 4), ic(t5$ic_cob, 3)),
  vies = sprintf("- **Viés:** %s (EP de MC %s; IC MC %s); relativo %s%% (EP %s%%); critério |·| < 10%%. EP médio %s; DP das estimativas %s.",
                 br(t5$vies, 5), br(t5$ep_vies, 5), ic(t5$vies + c(-1, 1) * 1.96 * t5$ep_vies, 5), br(100 * t5$vies_rel, 2), br(100 * t5$ep_vies_rel, 2), br(t5$se_medio, 4), br(t5$dp_lr, 4)),
  eqm = sprintf("- **EQM contra os coeficientes verdadeiros das unidades:** BLUP %s; primeira etapa %s; parte fixa X_iβ̂ (predição de cada unidade pelos seus metapreditores) %s.",
                formatC(t5$mse[["blup"]], format = "e", digits = 3), formatC(t5$mse[["primeira_etapa"]], format = "e", digits = 3), formatC(t5$mse[["parte_fixa"]], format = "e", digits = 3)),
  eqm_media = sprintf("- **EQM da predição na média dos metapreditores** (a mesma predição para todas as unidades; só reportado): %s.", formatC(t5$mse[["predicao_media"]], format = "e", digits = 3)),
  blup_formula = sprintf("numa réplica: diferença máxima %s (critério ≤ 1e-8).", formatC(t5$dif_blup, format = "e", digits = 1)),
  cob_tmr = sprintf("- **Cobertura do IC 95%% da TMR combinada (bootstrap da D4(a)), só reportada:** %s.", br(t5$cob_tmr, 3)),
  metodos = sprintf("- **Método do mixmeta nas réplicas:** %s. Duração:", paste(sprintf("%s em %d", names(t5$metodos), as.integer(t5$metodos)), collapse = "; ")),
  t02 = sprintf("- **Teste 2:** maior |Boundary.knots − range(x)| nas 26 = %s.", formatC(T3_u$t02, format = "e", digits = 1)),
  t03 = sprintf("nas 26 concentrações e nos seus percentis = %s (critério ≤ 1e-10).", formatC(T3_u$t03, format = "e", digits = 1)),
  t06 = sprintf("- **Teste 6 (quadrática):** DP das TMR sorteadas %s × EP pelo método delta %s (critério: diferença < 20%%); largura do IC %s °C.", br(T3_u$t06[["dp_boot"]], 3), br(T3_u$t06[["ep_delta"]], 3), br(T3_u$t06[["largura"]], 2)),
  t08f = sprintf("- **Teste 8(f):** correlação entre as simulações das concentrações 1 e 2 (mesma vcov) = %s (critério |r| < 0,15).", br(T3_u$t08_cor, 3)),
  t08b = sprintf("total − (calor + frio) = %s no AN sintético.", br(T3_u$t08_backward_dif, 4)))
txt_igual <- vapply(txt, function(t) grepl(t, L41, fixed = TRUE), TRUE)

# ------------------------------------------------------------------ conferência do desvio 76: BLUP trocado pela parte fixa
src <- paste0(paste(readLines(f_se, encoding = "UTF-8"), collapse = "\n"), "\n")
alvo <- "out$blup <- lapply(b, function(z) list(coef = unname(z$blup), vcov = unname(z$vcov)))"
troca <- "fx_def <- stats::predict(fit); out$blup <- lapply(seq_along(b), function(j) list(coef = unname(fx_def[j, ]), vcov = unname(b[[j]]$vcov)))"
stopifnot(lengths(regmatches(src, gregexpr(alvo, src, fixed = TRUE))) == 1)
tf <- file.path(tempdir(), "segunda_etapa_blup_parte_fixa.R"); writeLines(sub(alvo, troca, src, fixed = TRUE), tf, useBytes = TRUE)
log_msg("desvio 76: BLUP trocado pela parte fixa (rápidos e teste 5)"); g <- carrega(tf); unlink(tf)
ru_d <- roda_testes(g, testes_segunda_etapa); .R3$relata_tmr <- FALSE; rm_d <- roda_testes(g, testes_segunda_etapa_mc)
caem_d <- ru_d$teste[!ru_d$ok]; pego <- length(caem_d) > 0 || !rm_d$ok[1]
if (!identical(sha(f_se), sha41[["codigo_compartilhado/R/segunda_etapa.R"]])) stop("segunda_etapa.R mudou durante a rodada")

ok <- all(todos$ok) && identical(n_44, n_41) && all(igual41) && all(txt_igual) && pego

# ------------------------------------------------------------------ log
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
s_info <- sessionInfo()
md <- c("# Fase 3, Parte B, passo 2: testes de novo antes da tag `segunda_etapa-v1.0`", "",
        sprintf("- **Gerado por:** `00_scripts/44_testes_tag_fase3.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        sprintf("- **Ambiente:** R %s; dlnm %s; gnm %s; mixmeta %s; tsModel %s. BLAS/LAPACK: `%s` / `%s`. Semente 20261001 (Mersenne-Twister, Inversion, Rejection), em série; sementes por concentração conforme o complemento C1.",
                paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("gnm"), packageVersion("mixmeta"), packageVersion("tsModel"), s_info$BLAS, s_info$LAPACK),
        sprintf("- **Commit no disco:** HEAD `%s` (%s). O commit da Parte A, `%s`, alvo da tag, é ancestral do HEAD, e `codigo_compartilhado/` no disco é igual a ele (`git diff` vazio). Antes de rodar, nada pendente em `artigo1_prematuridade/` nem em `codigo_compartilhado/`, fora este script, ainda sem commit. O desvio 76 está no HEAD.",
                head_c, head_s, COMMIT_A),
        "- **Arquivos conferidos contra o testado no 41 (SHA-256):**", sprintf("  - `%s`: `%s`;", arqs41, sha41),
        "- `codigo_compartilhado/R/ajusta_dlnm.R` e `codigo_compartilhado/R/offset.R` com os SHA-256 registrados na tag `ajusta_dlnm-v1.0`.",
        "- **Entradas (SHA-256), usadas só como no 41:**", sprintf("  - `%s`: `%s`;", ENT, sha_ent), "",
        sprintf("## Resultado: %s testes (log do 41: %s)", n_44, n_41), "",
        tabela_md(data.frame(Teste = paste0("`", todos$teste, "`"), Resultado = ifelse(todos$ok, "passou", paste("FALHOU:", todos$mensagem)),
                             `Mesmo resultado do log do 41` = ifelse(igual41, "sim", "NÃO"), check.names = FALSE)), "",
        "## Números iguais aos do log do 41", "",
        "Cada linha abaixo foi montada com a mesma formatação do 41 e procurada, como texto, no log do 41. A duração do Monte Carlo não é comparada.", "",
        tabela_md(data.frame(Item = names(txt), Texto = gsub("|", "\\|", txt, fixed = TRUE), `Igual ao 41` = ifelse(txt_igual, "sim", "NÃO"), check.names = FALSE)), "",
        sprintf("- **Duração do Monte Carlo:** %s min.", br(dur_mc, 1)), "",
        "## Conferência do desvio 76: BLUP trocado pela parte fixa", "",
        sprintf("- **Troca, numa cópia de `segunda_etapa.R`:** `%s` → `%s`.", alvo, troca),
        sprintf("- **Testes rápidos que caem:** %s.", if (length(caem_d)) paste(sprintf("`%s` (%s)", caem_d, ru_d$mensagem[!ru_d$ok]), collapse = "; ") else "nenhum"),
        sprintf("- **Teste 5, rodado mesmo assim (sem a cobertura da TMR):** %s.", if (rm_d$ok[1]) "passou" else paste("caiu:", rm_d$mensagem[1])),
        sprintf("- **Defeito pego:** %s.", if (pego) "sim" else "NÃO"), "",
        "## SHA-256 de `codigo_compartilhado/R/` e `codigo_compartilhado/tests/` (para a mensagem da tag)", "",
        sprintf("- `%s`: `%s`;", todos_arq, sha_todos), "",
        sprintf("- **Conclusão:** %s", if (ok) sprintf("o código no disco é o testado e auditado na Parte A; os testes dão %s, o mesmo resultado por teste e os mesmos números do log do 41; o defeito \"BLUP trocado pela parte fixa\" é pego. A tag `segunda_etapa-v1.0` vai no commit `%s`.", n_44, COMMIT_A) else "FALHA: ver as tabelas; diagnóstico antes de qualquer mudança, sem tag."), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| testes:", n_44, "| iguais ao 41:", all(igual41) && all(txt_igual), "| desvio 76 pego:", pego, "| ok:", ok, "\n")
if (!ok) quit(status = 1)
