# 49_testes_posthoc_af.R — Fase 3, Parte D: testes sintéticos de codigo_compartilhado/R/posthoc_af.R (D5, item 4;
# entradas 78 e 79) e defeitos plantados, cada um numa cópia de posthoc_af.R. Um defeito conta só se derrubar um teste
# que passa no original. Só dado sintético; nada da base (o source do acesso.R só registra versao()). Semente 20261001.
# Confere que segunda_etapa.R e ajusta_dlnm.R no disco são os da tag segunda_etapa-v1.0 e que o MASS é o do renv.lock.
# Grava logs/testes_posthoc_af_fase3_<FASE3_DATA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/49_testes_posthoc_af.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; CC <- file.path("..", "codigo_compartilhado")
arq <- file.path("logs", paste0("testes_posthoc_af_fase3_", hoje, ".md")); stopifnot(!file.exists(arq))
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")

# ------------------------------------------------------------------ código da tag, MASS do lock
TAG <- "segunda_etapa-v1.0"; if (!identical(git("rev-parse", paste0(TAG, "^{commit}")), "410dd6d6d3d315004f22fd7197c326de77f3c2f4")) stop("tag fora do commit esperado")
for (a in c("codigo_compartilhado/R/segunda_etapa.R", "codigo_compartilhado/R/ajusta_dlnm.R")) {
  st <- sub(" .*", "", system(paste("git -C", shQuote(REPO), "show", shQuote(paste0(TAG, ":", a)), "| shasum -a 256"), intern = TRUE))
  if (!identical(st, sha(file.path(REPO, a)))) stop(a, " difere da tag ", TAG) }
lock <- jsonlite::fromJSON("renv.lock")$Packages$MASS$Version
if (utils::packageVersion("MASS") != package_version(lock)) stop("MASS ", as.character(utils::packageVersion("MASS")), " diferente do renv.lock (", lock, ")")
suppressPackageStartupMessages({ library(dlnm); library(mixmeta) })
f_se <- file.path(CC, "R", "segunda_etapa.R"); f_aj <- file.path(CC, "R", "ajusta_dlnm.R"); f_ph <- file.path(CC, "R", "posthoc_af.R")
f_tp <- file.path(CC, "tests", "testa_posthoc_af.R"); f_run <- file.path(CC, "tests", "roda_testes.R")
f_at <- file.path(CC, "inst", "terceiros", "attrdl.R"); SHA_ATTRDL <- "d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d"
carrega <- function(arquivo_ph) { e <- new.env(); sys.source(f_aj, envir = e); sys.source(f_se, envir = e); sys.source(arquivo_ph, envir = e); e }
source(f_run); source(f_tp)
f0 <- carrega(f_ph); .P3$attrdl <- f0$carrega_attrdl(f_at, SHA_ATTRDL)
sha_antes <- sha(f_ph)

# ------------------------------------------------------------------ bateria original
log_msg("bateria original"); r0 <- roda_testes(f0, testes_posthoc_af); print(r0[, c("teste", "ok")], row.names = FALSE)

# ------------------------------------------------------------------ defeitos plantados
src <- paste0(paste(readLines(f_ph, encoding = "UTF-8"), collapse = "\n"), "\n")
defeitos <- list(
  list("semente refeita dentro do laço", list(c("  for (r in seq_len(R)) {\n    th <- sorteia_nulo(S)", "  for (r in seq_len(R)) {\n    semeia(0); th <- sorteia_nulo(S)"))),
  list("sorteios com média diferente de zero", list(c("mu = rep(0, k)", "mu = rep(0.01, k)"))),
  list("réplica com falha excluída em silêncio", list(c("tab <- do.call(rbind, linhas); rownames(tab) <- NULL", "tab <- do.call(rbind, linhas); tab <- tab[!tab$falhou, ]; rownames(tab) <- NULL"))),
  list("Wald com gl − 1", list(c("stats::pchisq(w, length(b), lower.tail = FALSE)", "stats::pchisq(w, length(b) - 1, lower.tail = FALSE)"))),
  list("Wald só com a diagonal da vcov", list(c("solve(V, b)", "solve(diag(diag(V)), b)"))),
  list("AF contra o p50, e não contra a MRT da réplica", list(c("cen = tb$tmr, range = rg[[cmp]], sim = FALSE)", "cen = d$p50, range = rg[[cmp]], sim = FALSE)"))),
  list("simulações dentro da réplica (consome o gerador)", list(c("cen = tb$tmr, range = rg[[cmp]], sim = FALSE)", "cen = tb$tmr, range = rg[[cmp]], sim = TRUE, nsim = 5) |> mean()"))),
  list("RR combinado contra o p50, e não contra a MRT combinada da réplica", list(c("unname(eixo[c(\"p99\", \"p1\")]), tc$tmr)", "unname(eixo[c(\"p99\", \"p1\")]), eixo[[\"p50\"]])"))),
  list("teste das contribuições sem a folga", list(c("all(dl >= -max(g, 0) - 1e-12)", "all(dl >= -1e-12)"))),
  list("teste da base comparando a base consigo mesma", list(c("Bb <- unclass(do.call(dlnm::onebasis, c(list(x = grade), argvar_busca)))", "Bb <- Ba"))),
  list("busca da MRT sem os Boundary.knots da cross-basis", list(c("av <- attr(d$basis, \"argvar\")", "av <- attr(d$basis, \"argvar\")[c(\"fun\", \"knots\", \"intercept\")]"))),
  # da auditoria independente da Parte D (achado 5)
  list("semente sem o kind explícito", list(c("  semeia(0)                                                       # D5", "  set.seed(20261001)                                              # D5"))),
  list("comparação com o p97,5 não estrita", list(c("passa = af_obs > qa[3]", "passa = af_obs >= qa[3]"))),
  list("teste das contribuições em todos os dias, e não só no p1–p99", list(c("dentro <- x >= p1 & x <= p99; dl <- fa(x[dentro]) - fa(mrt)", "dentro <- rep(TRUE, length(x)); dl <- fa(x[dentro]) - fa(mrt)"))),
  list("réplica que caiu no Ψ diagonal contada como falha", list(c("out <- list(falhou = mc$status != \"ok\",", "out <- list(falhou = mc$status != \"ok\" || isTRUE(mc$bscov == \"diag\"),")))
)
res_def <- do.call(rbind, lapply(defeitos, function(d) {
  s2 <- src
  for (tr in d[[2]]) { stopifnot(lengths(regmatches(s2, gregexpr(tr[1], s2, fixed = TRUE))) == 1); s2 <- sub(tr[1], tr[2], s2, fixed = TRUE) }
  tf <- file.path(tempdir(), "posthoc_af_com_defeito.R"); writeLines(s2, tf, useBytes = TRUE)
  log_msg("defeito:", d[[1]]); g <- carrega(tf); rr <- roda_testes(g, testes_posthoc_af); unlink(tf)
  stopifnot(identical(rr$teste, r0$teste)); novos <- rr$teste[!rr$ok & r0$ok]
  data.frame(Defeito = d[[1]], Trocas = length(d[[2]]), `Testes derrubados (dos que passam no original)` = length(novos),
             Quais = if (length(novos)) paste(novos, collapse = ", ") else "nenhum", check.names = FALSE, stringsAsFactors = FALSE)
}))
sha_depois <- sha(f_ph)
ok <- all(r0$ok) && all(res_def$`Testes derrubados (dos que passam no original)` >= 1) && identical(sha_antes, sha_depois)

# ------------------------------------------------------------------ log
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
s_info <- sessionInfo()
md <- c("# Fase 3, Parte D: testes sintéticos do post hoc (`posthoc_af.R`)", "",
        sprintf("- **Gerado por:** `00_scripts/49_testes_posthoc_af.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha). Nada da base foi lido.", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        sprintf("- **Ambiente:** R %s; dlnm %s; mixmeta %s; MASS %s (igual ao `renv.lock`). BLAS/LAPACK: `%s` / `%s`. Semente 20261001.",
                paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("mixmeta"), packageVersion("MASS"), s_info$BLAS, s_info$LAPACK),
        "- **Arquivos testados (SHA-256):**",
        sprintf("  - `codigo_compartilhado/R/posthoc_af.R`: `%s` (igual antes e depois dos defeitos: %s);", sha_antes, if (identical(sha_antes, sha_depois)) "sim" else "NÃO"),
        sprintf("  - `codigo_compartilhado/R/segunda_etapa.R`: `%s` (tag `segunda_etapa-v1.0`, sem mudança);", sha(f_se)),
        sprintf("  - `codigo_compartilhado/R/ajusta_dlnm.R`: `%s` (tag `segunda_etapa-v1.0`, sem mudança);", sha(f_aj)),
        sprintf("  - `codigo_compartilhado/tests/testa_posthoc_af.R`: `%s`;", sha(f_tp)), sprintf("  - `codigo_compartilhado/tests/roda_testes.R`: `%s`;", sha(f_run)),
        sprintf("  - `codigo_compartilhado/inst/terceiros/attrdl.R`: `%s` (conferido contra o registrado).", sha(f_at)), "",
        "## O que cada teste confere", "",
        "- `tp1`: Wald (W, gl e p) contra a conta à mão, com vcov não diagonal.",
        "- `tp2`: a mesma semente dá as mesmas réplicas; as 2 primeiras de um laço de 3 são as de um laço de 2; os sorteios são os de uma sequência à mão com `set.seed(20261001, kind = ...)` uma vez antes do laço; com outro `RNGkind` ativo antes, as réplicas não mudam.",
        "- `tp3`: com um *stub* que faz a sequência inteira do `mixmeta` falhar quando θ*[1, 1] > 0, as falhas são as esperadas, ficam marcadas e sem AF (nem substituídas nem excluídas), e o resumo as conta; os limites do p97,5 com as falhas nos extremos ficam em volta do p97,5 sem elas; uma réplica que cai no Ψ diagonal não é falha.",
        "- `tp4`: média dos sorteios nulos a menos de 4 EP de 0 e covariância a menos de 10% de S_i (4.000 sorteios).",
        "- `tp5`: os dois testes do item 2 (entrada 78(c)): (i) base da `attrdl` igual à base da busca no caso igual e diferente com outros Boundary.knots; (ii) com a MRT da grade de 0,1 °C e a mesma base, folga positiva, Δ_t negativo e o teste passa; com a base da `attrdl` diferente da base da busca, o teste cai; um dia fora do p1–p99 abaixo do mínimo não conta.",
        "- `tp6`: AF total, calor e frio da réplica contra a AF *forward* à mão (sem a `attrdl`), com a MRT da réplica achada à mão; contagem de MRT nas pontas; MRT combinada e RR combinados no x99 e no x1 à mão (`splines::ns`).",
        "- `tp7`: a réplica não consome o gerador nem refaz a semente (`.Random.seed` igual ao de depois dos sorteios).",
        "- `tp8`: quantis do resumo contra a conta à mão; comparação com o p97,5, estrita (AF igual ao p97,5 não passa); sem falhas, os limites coincidem com o p97,5.", "",
        sprintf("## Resultado: %d/%d testes", sum(r0$ok), nrow(r0)), "",
        tabela_md(data.frame(Teste = paste0("`", r0$teste, "`"), Resultado = ifelse(r0$ok, "passou", paste("FALHOU:", r0$mensagem)), check.names = FALSE)), "",
        "## Defeitos plantados (cada um numa cópia de `posthoc_af.R`; a bateria inteira roda em cada cópia)", "",
        tabela_md(res_def), "",
        sprintf("- **Resultado:** %s.", if (ok) sprintf("todos os testes passam na versão original e cada um dos %d defeitos derruba pelo menos um teste", nrow(res_def)) else "FALHA: ver as tabelas; diagnóstico antes de qualquer mudança"), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| resultado:", if (ok) "ok" else "FALHA", "\n")
if (!ok) quit(status = 1)
