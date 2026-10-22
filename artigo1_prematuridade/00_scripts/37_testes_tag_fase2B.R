# 37_testes_tag_fase2B.R — Fase 2, Parte B, passo 2: roda os testes de novo antes da tag `ajusta_dlnm-v1.0` (desvio 58:
# log próprio, porque o 31 tem trava contra sobrescrita). Baterias: os testes rápidos e de Monte Carlo da ajusta_dlnm()
# (os mesmos do 31, sem os defeitos plantados) e a bateria do offset.R (Fase 1), porque a tag cobre todo
# codigo_compartilhado/R/. Confere que:
#   - o código e os testes no disco são os do commit da Parte A e os do log do 31 (SHA-256);
#   - nada está pendente em artigo1_prematuridade/ nem em codigo_compartilhado/ antes de rodar (desvio 60);
#   - o HEAD é o commit da Parte A (COMMIT_A) e o código no disco é igual ao dele (git diff);
#   - cada teste dá o mesmo resultado do log do 31 (e a bateria do offset, o da Fase 1), com as mesmas coberturas
#     e o mesmo viés do `nenhum` no teste 7. Os demais números de Monte Carlo não são comparados um a um.
# A falha conhecida do 5b (desvio 61) se repete por construção (mesma semente): o resultado é 19/20, e não n/n.
# Só dado sintético; nada da base (o source do acesso.R só registra versao()). Semente 20261001, em série.
# Grava logs/testes_tag_fase2B_<FASE2_DATA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE2_DATA=AAAAMMDD Rscript 00_scripts/37_testes_tag_fase2B.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE2_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("testes_tag_fase2B_", hoje, ".md")); stopifnot(!file.exists(arq))
git <- function(...) system2("git", c("-C", "/Volumes/Forja/Doc/artigos_perinatais_clima", ...), stdout = TRUE)
pend <- git("status", "--porcelain", "--untracked-files=all", "--", "artigo1_prematuridade", "codigo_compartilhado")
pend <- setdiff(pend, "?? artigo1_prematuridade/00_scripts/37_testes_tag_fase2B.R")   # o próprio script, ainda sem commit
if (length(pend)) stop("há arquivo pendente em artigo1_prematuridade/ ou codigo_compartilhado/: rodar só com o status limpo")
head_c <- git("rev-parse", "HEAD"); head_s <- git("log", "-1", shQuote("--format=%h %s"))
COMMIT_A <- "caf5022f9a655877d8e3931dd3d02d7dce429fe5"                 # commit da Parte A, alvo da tag
if (!identical(head_c, COMMIT_A)) stop("o HEAD não é o commit da Parte A: ", head_c)
if (length(git("diff", "--name-only", COMMIT_A, "--", "codigo_compartilhado"))) stop("codigo_compartilhado/ difere do commit da Parte A")
suppressPackageStartupMessages({ library(dlnm); library(gnm) })
CC <- file.path("..", "codigo_compartilhado")
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
L31 <- paste(readLines(file.path("logs", paste0("testes_ajusta_dlnm_fase2_", hoje, ".md")), encoding = "UTF-8"), collapse = "\n")
L24 <- paste(readLines(file.path("logs", "testes_compartilhado_fase1_20261009.md"), encoding = "UTF-8"), collapse = "\n")

# SHA-256: o que está no disco é o que o 31 (função) e a Fase 1 (offset) testaram
arqs <- c("codigo_compartilhado/R/ajusta_dlnm.R", "codigo_compartilhado/R/offset.R", "codigo_compartilhado/tests/gera_sintetico.R",
          "codigo_compartilhado/tests/testa_ajusta_dlnm.R", "codigo_compartilhado/tests/testa_ajusta_dlnm_mc.R",
          "codigo_compartilhado/tests/testa_offset.R", "codigo_compartilhado/tests/roda_testes.R")
shas <- vapply(arqs, function(a) sha(file.path("..", a)), "")
no_log <- vapply(arqs, function(a) { alvo <- sprintf("`%s`: `%s`", a, shas[[a]])
  if (a %in% c("codigo_compartilhado/R/offset.R", "codigo_compartilhado/tests/testa_offset.R")) grepl(alvo, L24, fixed = TRUE) else grepl(alvo, L31, fixed = TRUE) }, TRUE)
if (!all(no_log)) stop("SHA-256 diferente do testado: ", paste(arqs[!no_log], collapse = ", "))

# baterias
source(file.path(CC, "tests", "roda_testes.R")); source(file.path(CC, "tests", "testa_ajusta_dlnm.R"))
source(file.path(CC, "tests", "testa_ajusta_dlnm_mc.R")); source(file.path(CC, "tests", "testa_offset.R"))
f <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = f); sys.source(file.path(CC, "tests", "gera_sintetico.R"), envir = f)
set.seed(20261001); .MC$bf <- f$base_fixa(100000); .MC$proj <- f$projeta_theta(.MC$bf); .MC$R <- 200L
r_u <- roda_testes(f, testes_ajusta_dlnm); r_m <- roda_testes(f, testes_ajusta_dlnm_mc)
fo <- new.env(); sys.source(file.path(CC, "R", "offset.R"), envir = fo); r_o <- roda_testes(fo, testes_offset)
todos <- rbind(r_u, r_m)

# mesmo resultado do log do 31: cada teste com o mesmo desfecho (e a mesma mensagem, se falhou); mesmas coberturas
lin31 <- vapply(seq_len(nrow(todos)), function(i) sprintf("| `%s` | %s |", todos$teste[i], if (todos$ok[i]) "passou" else paste("FALHOU:", todos$mensagem[i])), "")
igual31 <- vapply(lin31, function(l) grepl(l, L31, fixed = TRUE), TRUE)
cobs <- c(t05 = .MC$t05$theta$cobertura, t05b = .MC$t05b$theta$cobertura, t06 = .MC$t06$nulo$cobertura)
cob_txt <- sprintf("%s (EP %s; IC Wilson %s)", br(cobs, 3), br(c(.MC$t05$theta$ep_cob, .MC$t05b$theta$ep_cob, .MC$t06$nulo$ep_cob), 4),
                   c(sprintf("[%s; %s]", br(.MC$t05$theta$ic_cob[1], 3), br(.MC$t05$theta$ic_cob[2], 3)),
                     sprintf("[%s; %s]", br(.MC$t05b$theta$ic_cob[1], 3), br(.MC$t05b$theta$ic_cob[2], 3)),
                     sprintf("[%s; %s]", br(.MC$t06$nulo$ic_cob[1], 3), br(.MC$t06$nulo$ic_cob[2], 3))))
cob_igual <- vapply(cob_txt, function(t) grepl(t, L31, fixed = TRUE), TRUE)
t7_txt <- sprintf("viés médio %s (EP de MC %s;", br(.MC$t07$nenhum_vies, 4), br(.MC$t07$ep_nenhum, 4)); t7_igual <- grepl(t7_txt, L31, fixed = TRUE)
o_igual <- all(r_o$ok) && grepl("bateria original passa inteira", L24, fixed = TRUE)
FALHA_CONHECIDA <- c(t05b_recuperacao_contagem_baixa = "cobertura 0.985 fora de 0,92–0,98")
falhas <- todos$teste[!todos$ok]
so_conhecida <- all(falhas %in% names(FALHA_CONHECIDA)) && identical(unname(todos$mensagem[!todos$ok]), unname(FALHA_CONHECIDA[falhas]))
ok <- all(igual31) && all(cob_igual) && t7_igual && o_igual && so_conhecida

stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
md <- c("# Fase 2, Parte B, passo 2: testes de novo antes da tag `ajusta_dlnm-v1.0`", "",
        sprintf("- **Gerado por:** `00_scripts/37_testes_tag_fase2B.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha). Nada da base foi lido.",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
        sprintf("- **Ambiente:** R %s; dlnm %s; gnm %s. BLAS/LAPACK: `%s` / `%s`. Semente 20261001, em série.",
                paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("gnm"), sessionInfo()$BLAS, sessionInfo()$LAPACK),
        sprintf("- **Commit no disco:** `%s` (%s), o da Parte A; `codigo_compartilhado/` igual a ele (`git diff` vazio). Antes de rodar, nada pendente em `artigo1_prematuridade/` nem em `codigo_compartilhado/` (desvio 60), fora este script, ainda sem commit.", head_c, head_s),
        "- **Arquivos (SHA-256), conferidos contra o testado** (função e testes dela: log do 31; `offset.R` e `testa_offset.R`: log da Fase 1):",
        sprintf("  - `%s`: `%s`;", arqs, shas), "",
        sprintf("## Resultado: %d/%d testes da `ajusta_dlnm()` e %d/%d do `offset.R`", sum(todos$ok), nrow(todos), sum(r_o$ok), nrow(r_o)), "",
        tabela_md(data.frame(Teste = paste0("`", c(todos$teste, r_o$teste), "`"),
                             Resultado = c(ifelse(todos$ok, "passou", paste("FALHOU:", todos$mensagem)), ifelse(r_o$ok, "passou", paste("FALHOU:", r_o$mensagem))),
                             `Mesmo resultado do log de referência` = c(ifelse(igual31, "sim", "NÃO"), rep(if (o_igual) "sim" else "NÃO", nrow(r_o))), check.names = FALSE)), "",
        sprintf("- **Coberturas de Monte Carlo** (5, 5b e 6): %s; iguais às do log do 31: %s. Viés do `nenhum` no teste 7: %s; igual: %s.",
                paste(cob_txt, collapse = "; "), if (all(cob_igual)) "sim" else "NÃO", sub(" \\(EP de MC.*", "", sub("viés médio ", "", t7_txt)), if (t7_igual) "sim" else "NÃO"),
        sprintf("- **Falhas:** %s.", if (length(falhas)) paste0(paste0("`", falhas, "`", collapse = ", "), if (so_conhecida) " — a falha conhecida do 5b, com a mesma mensagem (desvio 61); o critério \"n/n\" do passo 2 da Parte B não é atingido por causa dela" else " — FALHA NOVA") else "nenhuma"),
        sprintf("- **Conclusão:** %s", if (ok) "o código no disco é o testado e auditado na Parte A, e os testes dão o mesmo resultado por teste e as mesmas coberturas do log do 31 (e o mesmo resultado da Fase 1 no offset). A tag depende do [ok] de Guilherme, que decide sobre o n/n com a falha conhecida." else "DIFERENÇA em relação aos logs de referência: não criar a tag; diagnóstico antes."), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| ajusta_dlnm:", sum(todos$ok), "/", nrow(todos), "| offset:", sum(r_o$ok), "/", nrow(r_o), "| igual às referências:", ok, "\n")
if (!ok) quit(status = 1)
