# 63_testes_diagnostico_v101.R — Fase 4, Parte A: diagnostico_grade_mrt v1.0.1, só testes e mensagens (mensagem da Parte
# A do chat do Artigo 1, 16/10/2026, seção 2; prompt da Fase 4, seção 2, item 7; P14 do plano: script novo, derivado da
# Parte A do 54; o 54 e o log dele ficam intocados). Só dado sintético: não roda a Parte B do 54 (dados reais).
#   - Rótulo: as travas são da entrada 82(a), registrada antes de rodar; a regra "a MRT tem de ser exatamente um ponto da
#     grade" e os motivos das anômalas são alteração post hoc (entrada 83(a)), feita depois de ver os resultados do 53 e
#     do 54 (Menor 5 da reauditoria). A v1.0.1 não muda nenhuma função: só testes (Menores 1 a 3 e Notas 8 e 9) e
#     mensagens (Menores 4 e 5; Nota 10).
#   - Conferência de que nenhuma classe nem valor do 53 muda: o corpo de cada função da v1.0.1 é idêntico (deparse) ao
#     da tag diagnostico_grade_mrt-v1.0 (c7ce6a5). A grade é a grade_tmr da tag segunda_etapa-v1.0.1, lida por git show.
#   - Bateria testa_diagnostico_grade_mrt.R e defeitos plantados: os 39 do 54 (textos revalidados: a função não mudou),
#     mais os da reauditoria (tol_f 10×; classe só no caminho "MRT não é ponto da grade"; classe só na parada; sem a
#     checagem razão MRT ≤ 1 + tol, antes sobrevivente; M não finito sem is.finite; mrt_no_p99 com tolerância de 1e-2).
#     Os mutantes equivalentes ou quase equivalentes (Notas 6 e 7) vão a uma tabela à parte e não contam como defeito.
# Confere antes: este script, o código e os testes commitados e limpos; BLAS e LAPACK de referência. Semente 20261001.
# Grava logs/testes_diagnostico_v101_fase4_<RODADA>.md. Nunca sobrescreve. Numa falha, quit(status = 1).
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/63_testes_diagnostico_v101.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("testes_diagnostico_v101_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/63_testes_diagnostico_v101.R"
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
de_tag <- function(tag, a) { tf <- tempfile(fileext = ".R"); writeLines(git("show", paste0(tag, ":", a)), tf, useBytes = TRUE); tf }

# ------------------------------------------------------------------ conferências e cabeçalho (protocolo v1.1, 3.8)
s_info <- sessionInfo()
if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib")) stop("BLAS/LAPACK fora da referência (§8)")
F_DG <- "codigo_compartilhado/R/diagnostico_grade_mrt.R"; F_SE <- "codigo_compartilhado/R/segunda_etapa.R"
TST <- c(run = "codigo_compartilhado/tests/roda_testes_fase4.R", t_dg = "codigo_compartilhado/tests/testa_diagnostico_grade_mrt.R")
F54 <- c("artigo1_prematuridade/00_scripts/54_confere_travas_diagnostico.R", "artigo1_prematuridade/logs/travas_diagnostico_grade_mrt_fase3_20261014.md")
sujos <- git("status", "--porcelain", "--", ESTE, F_DG, TST, F54)
if (length(sujos)) { cat(sujos, sep = "\n"); stop("script, código, testes ou o 54 com mudança não commitada: não roda") }
TAG_DG <- "diagnostico_grade_mrt-v1.0"; if (!identical(git("rev-parse", paste0(TAG_DG, "^{commit}")), "c7ce6a5a131be915780e6aaaac5cd93deb26c079")) stop("tag ", TAG_DG, " fora do commit esperado")
TAG_SE <- "segunda_etapa-v1.0.1"; if (!identical(git("rev-parse", paste0(TAG_SE, "^{commit}")), "403b0a2d4b60c425d38cb39fcbef0f7b147891c1")) stop("tag ", TAG_SE, " fora do commit esperado")
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current")
st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:")   # system2 não cita argumentos (lição do 55)
stopifnot(length(head_c) == 1L, length(ramo) == 1L, length(coord) == 1L)
inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
suppressPackageStartupMessages({ library(dlnm) })
sha_cod <- vapply(file.path(REPO, c(F_DG, TST, F54, ESTE)), sha, ""); names(sha_cod) <- c(F_DG, TST, F54, ESTE)
f_se_tag <- de_tag(TAG_SE, F_SE)

# ------------------------------------------------------------------ nenhuma função muda: corpo idêntico ao da tag v1.0
e10 <- new.env(); sys.source(de_tag(TAG_DG, F_DG), envir = e10); e11 <- new.env(); sys.source(file.path(REPO, F_DG), envir = e11)
fun_iguais <- identical(sort(ls(e10, all.names = TRUE)), sort(ls(e11, all.names = TRUE))) &&
  all(vapply(ls(e10, all.names = TRUE), function(n) identical(deparse(e10[[n]]), deparse(e11[[n]])), TRUE))
if (!fun_iguais) stop("alguma função da v1.0.1 difere da v1.0: a v1.0.1 é só de testes e mensagens")

# ------------------------------------------------------------------ bateria e defeitos plantados
for (k in names(TST)) source(file.path(REPO, TST[[k]]))
carrega <- function(arquivo_dg, grade_sem_p99 = FALSE) { e <- new.env(); sys.source(f_se_tag, envir = e); sys.source(arquivo_dg, envir = e)
  if (grade_sem_p99) e$grade_tmr <- function(x_inf, x_sup) seq(x_inf, x_sup, by = 0.1)   # defeito plantado só na cópia em memória
  e }
log_msg("bateria no original"); r0 <- roda_testes_fase4(carrega(file.path(REPO, F_DG)), testes_diagnostico_grade_mrt)
print(r0[, c("teste", "ok", "tipo")], row.names = FALSE)
src <- paste0(paste(readLines(file.path(REPO, F_DG), encoding = "UTF-8"), collapse = "\n"), "\n")
defeitos <- list(
  # os 39 do 54 (os mesmos textos de busca; a função não mudou)
  list("h = 0,1 na célula parcial", list(c("ca <- classifica_celula(M, b - a, u_min, fa, fb, fx, dist, tol_f = tol_f, mrt_argmin = arg)\n  cn <- classifica_celula(Mn, b - a, u_min, fa, fb, fx, dist, tol_f = tol_f, mrt_argmin = arg)",
                                            "ca <- classifica_celula(M, 0.1, u_min, fa, fb, fx, dist, tol_f = tol_f, mrt_argmin = arg)\n  cn <- classifica_celula(Mn, 0.1, u_min, fa, fb, fx, dist, tol_f = tol_f, mrt_argmin = arg)"))),
  list("grade sem o p99 (grade_tmr trocada por seq de 0,1 °C, na cópia em memória)", list(), TRUE),
  list("razão da célula só contra f(MRT)", list(c("r_cel <- (min(f_a, f_b) - f_x) / cota", "r_cel <- -u_min / cota"))),
  list("M num ponto (f″ no dia do mínimo), e não o máximo na célula", list(c("M <- max(f2_ns(zk, argvar_busca, coef))", "M <- f2_ns(xs, argvar_busca, coef)"))),
  list("vizinhança com distância ≤ 1", list(c("else if (dist == 0) \"a, vizinha\"", "else if (dist <= 1) \"a, vizinha\""))),
  list("u_min com a base da busca, e não com a da attrdl", list(c("u <- f_ns(xd, argvar_attrdl, coef) - f_ns(mrt, argvar_attrdl, coef)", "u <- f_ns(xd, argvar_busca, coef) - f_ns(mrt, argvar_busca, coef)"))),
  list("dias fora do p1–p99 incluídos", list(c("dentro <- x >= p1 & x <= p99; xd <- x[dentro]", "dentro <- rep(TRUE, length(x)); xd <- x[dentro]"))),
  list("M sem os nós internos da célula", list(c("zk <- c(a, b, kn[kn > a & kn < b])", "zk <- c(a, b)"))),
  list("tolerância do u_min gravado frouxa (1e-6)", list(c("tol_gravado = 1e-13", "tol_gravado = 1e-6"))),
  list("tolerância das razões frouxa (1,5)", list(c("r_mrt <= 1 + tol && r_cel <= 1 + tol", "r_mrt <= 1.5 && r_cel <= 1.5"))),
  list("classe (b) não detectada", list(c("if (xs > grade[n] + 1e-8 || xs < grade[1] - 1e-8) {", "if (FALSE) {"))),
  list("x* tirado do vetor completo, e não dos dias dentro do p1–p99", list(c("i <- which.min(u); u_min <- u[i]; xs <- xd[i]", "i <- which.min(u); u_min <- u[i]; xs <- x[i]"))),
  list("sem a trava M > 0", list(c("ok <- is.finite(M) && M > 0 &&", "ok <- is.finite(M) &&"))),
  list("M com a base da attrdl", list(c("M <- max(f2_ns(zk, argvar_busca, coef))", "M <- max(f2_ns(zk, argvar_attrdl, coef))"))),
  list("f(a) e f(b) com a base da attrdl", list(c("fa <- f_ns(a, argvar_busca, coef); fb <- f_ns(b, argvar_busca, coef)", "fa <- f_ns(a, argvar_attrdl, coef); fb <- f_ns(b, argvar_attrdl, coef)"))),
  list("f(x*) com a base da busca", list(c("fx <- f_ns(xs, argvar_attrdl, coef)", "fx <- f_ns(xs, argvar_busca, coef)"))),
  list("classe numérica calculada com o M analítico", list(c("cn <- classifica_celula(Mn, b - a,", "cn <- classifica_celula(M, b - a,"))),
  list("célula parcial sem a condição de h", list(c("out$parcial <- abs(b - p99) <= 1e-8 && (b - a) < 0.1 - 1e-8", "out$parcial <- abs(b - p99) <= 1e-8"))),
  list("classe (b) só do lado do p99", list(c("if (xs > grade[n] + 1e-8 || xs < grade[1] - 1e-8) {", "if (xs > grade[n] + 1e-8) {"))),
  list("sem a checagem de MRT fora dos pontos da grade", list(c("if (mrt != grade[k]) {", "if (FALSE) {"))),
  list("primeiro ponto = p1 sempre verdadeiro", list(c("primeiro_eh_p1 = abs(grade[1] - p1) <= 1e-8", "primeiro_eh_p1 = TRUE"))),
  list("tolerância de último = p99 em 1e-2", list(c("ultimo_eh_p99 = abs(grade[n] - p99) <= 1e-8", "ultimo_eh_p99 = abs(grade[n] - p99) <= 1e-2"))),
  list("p99 acrescentado com > 0, e não > 1e-8", list(c("p99_acrescentado = (p99 - sq[length(sq)]) > 1e-8", "p99_acrescentado = (p99 - sq[length(sq)]) > 0"))),
  list("sem a trava de coerência das razões", list(c("coer <- (min(f_a, f_b) - f_x) + u_min >= -tol_f", "coer <- TRUE"))),
  list("sem a trava da MRT como argmin de f na grade", list(c("arg <- fg[k] <= min(fg) + tol_f", "arg <- TRUE"))),
  list("sem a trava h ≤ 0,1 + 1e-8", list(c("h_ok <- h <= 0.1 + 1e-8", "h_ok <- TRUE"))),
  list("M = máx|f″|, e não máx f″", list(c("M <- max(f2_ns(zk, argvar_busca, coef))", "M <- max(abs(f2_ns(zk, argvar_busca, coef)))"))),
  list("tolerância da coerência em 1e-6, e não tol_f", list(c("coer <- (min(f_a, f_b) - f_x) + u_min >= -tol_f", "coer <- (min(f_a, f_b) - f_x) + u_min >= -1e-6"))),
  list("tolerância do argmin em 1e-6, e não tol_f", list(c("arg <- fg[k] <= min(fg) + tol_f", "arg <- fg[k] <= min(fg) + 1e-6"))),
  list("ponto k da MRT por findInterval, e não pelo ponto mais próximo", list(c("k <- which.min(abs(grade - mrt))", "k <- findInterval(mrt, grade)"))),
  list("célula por findInterval sem rightmost.closed e sem o min", list(c("j <- min(findInterval(xs, grade, rightmost.closed = TRUE), n - 1L)", "j <- findInterval(xs, grade)"))),
  list("tol_f e mrt_argmin com valor padrão (trava 2 pulada numa chamada direta)", list(c("dist, tol_f, mrt_argmin, tol = 1e-6) {", "dist, tol_f = 1e-12, mrt_argmin = TRUE, tol = 1e-6) {"))),
  list("MRT na grade com tolerância de 1e-8, e não igualdade exata", list(c("if (mrt != grade[k]) {", "if (abs(grade[k] - mrt) > 1e-8) {"))),
  list("f(grade) da trava 2 na base da attrdl", list(c("fg <- f_ns(grade, argvar_busca, coef)", "fg <- f_ns(grade, argvar_attrdl, coef)"))),
  list("motivo da f″ numérica omitido", list(c("if (ca$classe != cn$classe) \"f″ analítica e numérica mudam a classe\"), collapse = \"; \")", "NULL), collapse = \"; \")"))),
  list("motivo da f″ numérica sobrescrevendo os outros", list(c("out$motivo <- paste(c(ca$motivos, if (ca$classe != cn$classe) \"f″ analítica e numérica mudam a classe\"), collapse = \"; \")",
                                                                "out$motivo <- if (ca$classe != cn$classe) \"f″ analítica e numérica mudam a classe\" else paste(ca$motivos, collapse = \"; \")"))),
  list("tol_f fixo em 1e-12", list(c("tol_f <- 1e-12 * max(1, max(abs(fg)))", "tol_f <- 1e-12"))),
  list("tol_f sem o máx(1, ·)", list(c("tol_f <- 1e-12 * max(1, max(abs(fg)))", "tol_f <- 1e-12 * max(abs(fg))"))),
  list("anômala sem trava sem motivo (M ≤ 0 ou razão acima de 1 + tol)", list(c("motivos = c(mot_base, mot_trava)", "motivos = mot_trava"))),
  # da reauditoria das travas (Menores 1 a 3; Notas 8 e 9)
  list("Menor 1: tol_f 10× mais frouxo", list(c("tol_f <- 1e-12 * max(1, max(abs(fg)))", "tol_f <- 1e-11 * max(1, max(abs(fg)))"))),
  list("Menor 2 (A3): só a classe analítica no caminho \"MRT não é ponto da grade\"", list(c("if (mrt != grade[k]) { out$classe <- out$classe_num <- \"anomala\";", "if (mrt != grade[k]) { out$classe <- \"anomala\";"))),
  list("Menor 2 (X3): só a classe analítica na parada", list(c("out$classe <- out$classe_num <- \"parada\"", "out$classe <- \"parada\""))),
  list("Menor 3: sem a checagem razão MRT ≤ 1 + tol (antes sobrevivente)", list(c("ok <- is.finite(M) && M > 0 && r_mrt <= 1 + tol && r_cel <= 1 + tol", "ok <- is.finite(M) && M > 0 && r_cel <= 1 + tol"))),
  list("Nota 8 (A2): M não finito sem is.finite no motivo", list(c("m_ok <- is.finite(M) && M > 0", "m_ok <- M > 0"))),
  list("Nota 9 (A5): mrt_no_p99 com tolerância de 1e-2", list(c("mrt_no_p99 = abs(mrt - p99) <= 1e-8", "mrt_no_p99 = abs(mrt - p99) <= 1e-2")))
)
equivalentes <- list(
  list("trava 2 com f(mrt), e não f(grade)[k] (equivalente com a MRT exatamente no ponto da grade, f(mrt) pela base da busca; Nota 6)", list(c("arg <- fg[k] <= min(fg) + tol_f", "arg <- f_ns(mrt, argvar_busca, coef) <= min(fg) + tol_f"))),
  list("X4: k por max(1L, findInterval(...)) (quase equivalente sob igualdade exata; Nota 7)", list(c("k <- which.min(abs(grade - mrt))", "k <- max(1L, findInterval(mrt, grade))")))
)
roda_def <- function(d) {
  s2 <- src
  for (tr in d[[2]]) { if (lengths(regmatches(s2, gregexpr(tr[1], s2, fixed = TRUE))) != 1) stop("texto de busca sem exatamente uma ocorrência: ", d[[1]]); s2 <- sub(tr[1], tr[2], s2, fixed = TRUE) }
  tf <- tempfile(fileext = ".R"); writeLines(s2, tf, useBytes = TRUE)
  log_msg("defeito:", d[[1]]); rr <- roda_testes_fase4(carrega(tf, isTRUE(d[3][[1]])), testes_diagnostico_grade_mrt); unlink(tf)
  stopifnot(identical(rr$teste, r0$teste)); caem <- !rr$ok & r0$ok
  tipos <- table(factor(rr$tipo[caem], levels = c("critério", "erro")))
  data.frame(Defeito = d[[1]], `Testes derrubados` = sum(caem), `Por critério` = tipos[["critério"]], `Por erro` = tipos[["erro"]],
             Quais = if (any(caem)) paste(rr$teste[caem], collapse = ", ") else "nenhum", check.names = FALSE, stringsAsFactors = FALSE)
}
res_def <- do.call(rbind, lapply(defeitos, roda_def)); res_eq <- do.call(rbind, lapply(equivalentes, roda_def))
if (!identical(sha(file.path(REPO, F_DG)), sha_cod[[F_DG]])) stop("diagnostico_grade_mrt.R mudou durante a rodada")
ok <- all(r0$ok) && all(res_def[["Testes derrubados"]] >= 1) && fun_iguais

# ------------------------------------------------------------------ log
md <- c("# Fase 4, Parte A: diagnostico_grade_mrt v1.0.1 — só testes e mensagens (dado sintético)", "",
  sprintf("- **Gerado por:** `00_scripts/63_testes_diagnostico_v101.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`.", sha_cod[[ESTE]], inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Ambiente:** R %s; dlnm %s; splines %s. BLAS/LAPACK: `%s` / `%s` (referência). Semente 20261001. Não toca a base; a Parte B do 54 (26 concentrações) não roda.",
          paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("splines"), s_info$BLAS, s_info$LAPACK),
  "- **Rótulo:** travas da entrada 82(a), registrada antes de rodar; a MRT como ponto exato da grade e os motivos das anômalas são **alteração post hoc (entrada 83(a)), depois de ver os resultados do 53 e do 54** (Menor 5). A v1.0.1 não muda nenhuma função.",
  "- **Código, testes e o 54 (SHA-256; todos commitados e limpos antes de rodar; o 54 e o log dele não são alterados):**", sprintf("  - `%s`: `%s`;", names(sha_cod), sha_cod),
  sprintf("- **Nenhuma classe nem valor do 53 muda:** o corpo de cada função da v1.0.1 é idêntico, por `deparse`, ao da tag `%s` (`c7ce6a5`): %s. A grade é a `grade_tmr` da tag `%s`, lida por `git show`.", TAG_DG, if (fun_iguais) "sim" else "NÃO", TAG_SE), "",
  sprintf("## Resultado: %d/%d testes", sum(r0$ok), nrow(r0)), "",
  "- Novos ou alterados na v1.0.1: `td5` (asserções de `classe_num` nos caminhos \"MRT não é ponto da grade\" e \"parada\"; Menor 2); `td7` (p99 a 0,005 °C do último ponto do seq e MRT no penúltimo; Nota 9); `td13_tol_f_frouxo` (folga da coerência em −5e-12 com máx|f(grade)| < 1, entre −10·tol_f e −tol_f: anômala; Menor 1); `td14_cota_pequena` (M = 1e-6, h = 0,1, razão MRT = 1,0001, razão célula = 1: anômala só pela checagem da razão MRT; Menor 3); `td15_M_nao_finito` (M = Inf e NaN: motivo \"M ≤ 0 ou não finito\"; Nota 8).", "",
  tabela_md(data.frame(Teste = paste0("`", r0$teste, "`"), Resultado = ifelse(r0$ok, "passou", paste0("FALHOU (", r0$tipo, "): ", r0$mensagem)), check.names = FALSE)), "",
  sprintf("## Defeitos plantados (%d: os 39 do 54 e %d da reauditoria; cada um numa cópia da função, salvo o da grade, plantado na `grade_tmr` da cópia em memória)", nrow(res_def), nrow(res_def) - 39L), "",
  "- Os textos de busca dos 39 do 54 são os mesmos e foram revalidados contra a função (exatamente uma ocorrência cada); a função não mudou desde o 54. (Este texto corrige o do log do 54, que dizia, ao mesmo tempo, que mudara só o do 1º e que mudaram o 1º e o \"sem a checagem\": Menor 4.)", "",
  tabela_md(res_def), "",
  "## Mutantes equivalentes ou quase equivalentes (não contam como defeito; registro das Notas 6 e 7)", "",
  tabela_md(res_eq), "",
  "- A trava 2 com f(mrt) é equivalente porque a MRT é exatamente um ponto da grade e f(mrt) é calculado **pela base da busca** (com a base da attrdl não seria; Nota 6). O X4 só cai, se cair, por erro no caso da MRT abaixo do p1; sob igualdade exata é equivalente (Nota 7).", "",
  sprintf("- **Resultado:** %s.", if (ok) sprintf("%d/%d testes; cada um dos %d defeitos derruba pelo menos um teste (inclusive o antes sobrevivente \"sem a checagem razão MRT ≤ 1 + tol\"); nenhuma função mudou", sum(r0$ok), nrow(r0), nrow(res_def)) else "FALHA: ver as tabelas"), "")
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| testes:", sum(r0$ok), "/", nrow(r0), "| defeitos derrubados:", sum(res_def[["Testes derrubados"]] >= 1), "/", nrow(res_def), "| funções iguais:", fun_iguais, "| ok:", ok, "\n")
if (!ok) quit(status = 1)
