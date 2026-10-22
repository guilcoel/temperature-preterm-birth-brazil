# 84_c3_feriados_locais_fase4.R — Fase 4, Parte C3: sensibilidade dos feriados locais (§4, l. 383; D11, 3.3; D17, 2f;
# mensagem da COORD de 19/10, 15:54, item 3.2). Completa a lista fechada da §10.2 rodada no 74 (linha "Feriados locais",
# pendente até a tag). Mesmo fluxo comum do 74 (fluxo_c_fase4.R): 1ª etapa nas 26, fallback da D7, M7, φ, teste 3,
# meta_curva (média + amplitude), TMR combinada no eixo do principal com IC bootstrap (semente 20261001), RR no x99 e no
# x1, borda pela D13, item 3.
# Decisões de implementação, registradas antes de rodar (A1-119; post hoc em relação ao primário, sem resultado visto):
#   - tabela: feriados_locais_nucleo_2011_2024.csv lida da tag feriados_locais-v1.1 (commit bc586c0) com git show,
#     SHA-256 conferido (4a3d4f15…); a v1.0 não é usada (D17, 2f);
#   - indicador binário feriado_local = 1 na data da tabela da concentração, ou em 24/12 ou 31/12 (D11, 3.3: "mais 24/12
#     e 31/12"); 0 nos demais dias, inclusive nos dias de aquecimento; nenhuma concentração fica sem linha (Brasília
#     entra com o 30/11);
#   - somado ao calendário do principal (dia_semana, feriado_nacional, carnaval, moveis); o resto igual ao principal
#     (janela principal, 7 dias de aquecimento, nós e eixo da tmean_nucleo, arglag do principal, offset com γ estimado);
#   - conferência: nenhuma data do indicador coincide com feriado_nacional, carnaval ou moveis da série (a tabela já
#     exclui essas datas).
# Saídas (fora do git): 01_saidas/fase4/c3_feriados_locais_fase4_<RODADA>.rds e .csv. Log logs/c3_feriados_locais_fase4_<RODADA>.md.
# Nunca sobrescreve. Confere antes: script e módulo commitados e limpos; código igual ao das tags; SHA-256 das entradas.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/84_c3_feriados_locais_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("c3_feriados_locais_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase4"); f_out <- c(rds = file.path(OUT, paste0("c3_feriados_locais_fase4_", rodada, ".rds")), csv = file.path(OUT, paste0("c3_feriados_locais_fase4_", rodada, ".csv")))
for (p in f_out) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/84_c3_feriados_locais_fase4.R"; MOD <- "artigo1_prematuridade/00_scripts/fluxo_c_fase4.R"
CC <- file.path(REPO, "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
icf <- function(a, li, ls, d = 3) sprintf("%s (%s a %s)", br(a, d), br(li, d), br(ls, d))
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
escreve_csv <- function(df, p) { num <- vapply(df, is.double, TRUE); df[num] <- lapply(df[num], function(v) ifelse(is.na(v), NA, sprintf("%.17g", v)))
  utils::write.csv(df, p, row.names = FALSE, na = "", fileEncoding = "UTF-8") }

sujos <- git("status", "--porcelain", "--", ESTE, MOD); if (length(sujos)) { cat(sujos, sep = "\n"); stop("script ou módulo com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current"); st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:"); inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"); t0 <- Sys.time()
s_info <- sessionInfo(); if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib")) stop("BLAS/LAPACK fora da referência (§8)")
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
COD <- c("codigo_compartilhado/R/ajusta_dlnm.R" = "ajusta_dlnm-v1.1", "codigo_compartilhado/R/segunda_etapa.R" = "segunda_etapa-v1.1",
         "codigo_compartilhado/R/sens_agudos.R" = "sens_agudos-v1.0", "codigo_compartilhado/tests/teste3_fonte_independente.R" = "segunda_etapa-v1.1")
sha_cod <- vapply(names(COD), function(p) sha(file.path(REPO, p)), ""); for (p in names(COD)) if (!identical(sha_cod[[p]], tag_sha(COD[[p]], p))) stop(p, " difere da tag ", COD[[p]])
# tabela de feriados locais v1.1, lida da tag
TAG_FL <- "feriados_locais-v1.1"; CAM_FL <- "codigo_compartilhado/dados_referencia/feriados_locais_nucleo_2011_2024.csv"
commit_fl <- git("rev-parse", paste0(TAG_FL, "^{commit}")); stopifnot(identical(commit_fl, "bc586c021f27d9499479229465f5924d0f1ac1cf"))
sha_fl <- tag_sha(TAG_FL, CAM_FL); stopifnot(identical(sha_fl, "4a3d4f15bc51125c892cfb2acf55d542d7146b02161c1a7a2b151f64183a5fca"))
fl <- utils::read.csv(text = paste(git("show", paste0(TAG_FL, ":", CAM_FL)), collapse = "\n"), colClasses = "character", encoding = "UTF-8", check.names = FALSE, na.strings = character(0))
stopifnot(nrow(fl) == 1178L, length(unique(fl$concentracao)) == 26L)
ENT <- c(s4 = "01_saidas/fase4/serie_ptb_fase4.rds", rds32 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds",
         rds45 = "01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds", ref = "01_saidas/fase1/referencias_exposicao.csv")
SHA_FIXO <- c(s4 = "e70190c1bf7c0fa5ba9c9f1e3cacb46f1ef8d647fc04a8606d181f7c819793e0", rds32 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d",
              rds45 = "52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e", ref = "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467")
sha_ent <- vapply(ENT, sha, ""); if (!identical(unname(sha_ent), unname(SHA_FIXO))) stop("entrada com SHA-256 diferente do registrado")
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta); library(splines) })
f <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = f); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f); sys.source(file.path(CC, "R", "sens_agudos.R"), envir = f)
source(file.path(CC, "tests", "teste3_fonte_independente.R"))
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
stopifnot(setequal(unique(fl$concentracao), ordem))
CAL <- c("dia_semana", "feriado_nacional", "carnaval", "moveis"); AL7 <- list(fun = "ns", knots = dlnm::logknots(7, nk = 2), intercept = TRUE)
ref <- utils::read.csv(ENT[["ref"]], colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ordem, ref$recorte_principal), ]; stopifnot(identical(ref$recorte_principal, ordem))
md <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1, row.names = ordem)
sys.source(file.path(REPO, MOD), envir = environment())
r45 <- readRDS(ENT[["rds45"]]); rds32 <- readRDS(ENT[["rds32"]])$resultados
D <- as.Date; JP <- D(c("2012-04-14", "2024-08-06")); INI <- JP[1] - 7L; FIMP <- JP[2]
s4full <- as.data.frame(readRDS(ENT[["s4"]]))
fatia <- function(df, r, ini, fim = D("2024-12-31")) { x <- df[df$recorte_principal == r & df$data >= ini & df$data <= fim, ]; x <- x[order(x$data), ]; rownames(x) <- NULL; stopifnot(nrow(x) > 0, all(diff(x$data) == 1)); x }
nos_p <- function(r) { z <- ref[ref$recorte_principal == r, ]; list(p10 = z$p10, p75 = z$p75, p90 = z$p90, p50 = z$p50) }
sdr <- as.data.frame(serie_diaria(nivel = "recorte", coorte_fixa = TRUE, colunas = c("recorte_principal", "data", "tmean_nucleo"))); sdr$data <- D(sdr$data)
sdr <- sdr[sdr$data >= D("2012-01-01") & sdr$data <= D("2024-12-31"), ]
base_p <- list(nos = nos_p, eixo = r45$eixo, eixo_p = r45$eixo_p, grade = r45$grade, serie_nos = function(r) sdr$tmean_nucleo[sdr$recorte_principal == r], xcol = "tmean_nucleo")
cfg_de <- function(id, rotulo, dados, extra = list(), ...) { a <- base_p; a$id <- id; a$rotulo <- rotulo; a$dados <- dados; a$extra <- extra; m <- list(...); a[names(m)] <- m; a }
datas_fl <- split(D(fl$data), fl$concentracao)
com_fl <- function(r) { x <- fatia(s4full, r, INI, FIMP)
  x$feriado_local <- as.integer(x$data %in% datas_fl[[r]] | format(x$data, "%m-%d") %in% c("12-24", "12-31")); x }
# conferências do indicador, por concentração, só nos dias da janela principal
conf <- do.call(rbind, lapply(ordem, function(r) { x <- com_fl(r); j <- x$janela_principal %in% TRUE
  data.frame(recorte_principal = r, concentracao = nome[[r]], dias_janela = sum(j), dias_indicador = sum(x$feriado_local[j]),
             da_tabela = sum(x$data[j] %in% datas_fl[[r]]), dez_24_31 = sum(format(x$data[j], "%m-%d") %in% c("12-24", "12-31")),
             sobreposicao = sum(x$feriado_local[j] == 1 & (x$feriado_nacional[j] == 1 | x$carnaval[j] == 1 | x$moveis[j] == 1)), stringsAsFactors = FALSE) }))
if (any(conf$sobreposicao > 0)) stop("indicador de feriado local coincide com feriado nacional, carnaval ou moveis: ", paste(conf$concentracao[conf$sobreposicao > 0], collapse = ", "))
stopifnot(all(conf$dias_indicador > 0))
cfg <- cfg_de("FL", "Calendário: feriados locais (tabela v1.1, mais 24/12 e 31/12; D11, 3.3; D17)", com_fl, list(covariaveis = c(CAL, "feriado_local")))
z <- roda_analise(cfg); tab <- z$linha
saveRDS(list(analise = z[setdiff(names(z), c("dados", "fits_completos"))], conferencia_indicador = conf, tag = TAG_FL, commit_tag = commit_fl, sha_tabela = sha_fl,
             sha_codigo = sha_cod, sha_entradas = sha_ent, rodada = rodada), f_out[["rds"]])
escreve_csv(tab, f_out[["csv"]]); sha_out <- vapply(f_out, sha, "")
stopifnot(versao() == "4443971b")
tc <- r45$tmr[r45$tmr$nivel == "combinada", ]; cc <- r45$contrastes[r45$contrastes$nivel == "combinada", ]
md_txt <- c("# Fase 4, Parte C3: sensibilidade dos feriados locais (tabela v1.1)", "",
  sprintf("- **Gerado por:** `00_scripts/84_c3_feriados_locais_fase4.R` (SHA-256 `%s`) e o módulo `00_scripts/fluxo_c_fase4.R` (`%s`), início em %s, fim em %s. Rodada `%s`. `versao()`: %s.",
          sha(file.path(REPO, ESTE)), sha(file.path(REPO, MOD)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  "- **Código (igual ao das tags):**", sprintf("  - `%s`: `%s` (`%s`);", names(sha_cod), sha_cod, COD),
  sprintf("- **Tabela de feriados locais:** tag `%s` (commit `%s`), `%s`, SHA-256 `%s`, %s linhas, 26 núcleos.", TAG_FL, substr(commit_fl, 1, 7), CAM_FL, sha_fl, br(nrow(fl))),
  "- **Entradas (SHA-256 = registrados):**", sprintf("  - `%s`: `%s`;", ENT, sha_ent),
  "- **Decisões de implementação:** no cabeçalho do script e na A1-119.", "",
  "## Indicador (dias da janela principal; contagem de calendário, sem desfecho)", "",
  tabela_md(data.frame(Concentração = conf$concentracao, `Dias com o indicador` = conf$dias_indicador, `Da tabela` = conf$da_tabela, `24/12 e 31/12` = conf$dez_24_31, check.names = FALSE)), "",
  "- Nenhuma data do indicador coincide com `feriado_nacional`, `carnaval` ou `moveis`.", "",
  "## Resultado (sensibilidade descritiva; sem critério de concordância)", "", tabela_md(fmt_linhas(tab, br, icf)), "",
  sprintf("- **Principal (Fase 3), para comparação:** TMR %s °C (percentil %s); RR x99 %s; RR x1 %s.", br(tc$tmr, 1), br(100 * tc$percentil_tmr, 1),
          icf(cc$rr[cc$percentil == "p99"], cc$rr_li[cc$percentil == "p99"], cc$rr_ls[cc$percentil == "p99"]), icf(cc$rr[cc$percentil == "p1"], cc$rr_li[cc$percentil == "p1"], cc$rr_ls[cc$percentil == "p1"])),
  if (nzchar(tab$excluidas)) sprintf("- **Concentrações fora:** %s (%s).", tab$excluidas, tab$motivos_exclusao) else "- Nenhuma concentração saiu por falha de ajuste.", "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", f_out, sha_out), "",
  sprintf("- **Resultado:** ok; tempo %.1f min.", as.numeric(difftime(Sys.time(), t0, units = "mins"))), "")
writeLines(md_txt, arq, useBytes = TRUE)
cat("gravado:", arq, "| TMR", round(tab$tmr, 1), "| x99", round(tab$rr99, 3), "| x1", round(tab$rr01, 3), "\n")
