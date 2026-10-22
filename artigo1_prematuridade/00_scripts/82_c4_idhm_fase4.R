# 82_c4_idhm_fase4.R — Fase 4, Parte C4: exploratório do IDHM da D15 (mensagem "C2, C3 e C4 em lote", item 77; D15,
# seção 2; A1-113). Completa o 77, que deixou o IDHM pendente (A1-103 e A1-104).
#   - IDHM da concentração: média dos IDHM 2010 dos seus municípios (saída do 81), ponderada pela população residente do
#     Censo 2010 de cada município (`concentracoes()`, POP_CENSO2010); Manaus e Campo Grande (município isolado) ficam com o
#     IDHM do próprio município. Controle: a POP do Atlas contra a POP_CENSO2010 da base (só relatado).
#   - meta_exploratoria do 77, igual aos outros três: IDHM centrado na média das 26, somado à base (média + amplitude),
#     coeficientes reduzidos do principal (32); Wald do termo (4 gl), Q e I² residuais com e sem ele; confere_meta.
#   - Declarar (D15): o IDHM é média geométrica de três índices, e a média ponderada dos municipais é uma aproximação; o
#     IDHM é de 2010, anterior ao período de estudo; exploratório, sem P confirmatório (§6).
# Saídas (fora do git): 01_saidas/fase4/c4_idhm_fase4_<RODADA>.rds e .csv (IDHM por concentração). Log
# logs/c4_idhm_fase4_<RODADA>.md. Nunca sobrescreve. Confere antes: script commitado e limpo; código igual ao da tag;
# SHA-256 das entradas (o CSV do 81 pelo log do 81).
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/82_c4_idhm_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("c4_idhm_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
f_out <- c(rds = file.path("01_saidas", "fase4", paste0("c4_idhm_fase4_", rodada, ".rds")), csv = file.path("01_saidas", "fase4", paste0("c4_idhm_fase4_", rodada, ".csv")))
for (p in f_out) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/82_c4_idhm_fase4.R"; CC <- file.path(REPO, "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
pfmt <- function(p) formatC(p, format = "g", digits = 3, decimal.mark = ",")
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
sujos <- git("status", "--porcelain", "--", ESTE); if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current"); st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:"); inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
sha_se <- sha(file.path(CC, "R", "segunda_etapa.R")); if (!identical(sha_se, tag_sha("segunda_etapa-v1.1", "codigo_compartilhado/R/segunda_etapa.R"))) stop("segunda_etapa.R difere da tag")
ENT <- c(rds32 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", ref = "01_saidas/fase1/referencias_exposicao.csv", idhm = "01_saidas/fase4/idhm/idhm2010_municipios_atlas.csv")
SHA_FIXO <- c(rds32 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d", ref = "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467")
sha_ent <- vapply(ENT, sha, "")
log81 <- list.files("logs", "^idhm_atlas_fase4_[0-9]{8}\\.md$", full.names = TRUE); stopifnot(length(log81) == 1L)
ok_idhm <- grepl(paste0("`", ENT[["idhm"]], "`: `", sha_ent[["idhm"]], "`"), paste(readLines(log81, encoding = "UTF-8"), collapse = "\n"), fixed = TRUE)
if (!ok_idhm || !identical(unname(sha_ent[names(SHA_FIXO)]), unname(SHA_FIXO))) stop("entrada com SHA-256 diferente do registrado")
suppressPackageStartupMessages({ library(dlnm); library(mixmeta) })
f <- new.env(); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f)
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
rds32 <- readRDS(ENT[["rds32"]])$resultados
ref <- utils::read.csv(ENT[["ref"]], colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ordem, ref$recorte_principal), ]; stopifnot(identical(ref$recorte_principal, ordem))
md <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1, row.names = ordem)
# IDHM da concentração
mun <- as.data.frame(concentracoes()); stopifnot(nrow(mun) == 277L, setequal(unique(mun$CD_RECORTE), ordem))
mun$pop2010 <- as.numeric(mun$POP_CENSO2010); stopifnot(all(is.finite(mun$pop2010)), all(mun$pop2010 > 0))
atl <- utils::read.csv(ENT[["idhm"]], colClasses = c(codmun7 = "character"), encoding = "UTF-8")
j <- match(as.character(mun$CD_MUN), atl$codmun7); if (anyNA(j)) stop("município sem IDHM 2010 no Atlas: ", paste(mun$CD_MUN[is.na(j)], collapse = ", "))
mun$idhm <- atl$idhm[j]; mun$pop_atlas <- atl$pop_atlas[j]
pop_igual <- sum(mun$pop_atlas == mun$pop2010); pop_dif_max <- max(abs(mun$pop_atlas - mun$pop2010) / mun$pop2010)
idhm_c <- vapply(ordem, function(r) { k <- mun$CD_RECORTE == r; stats::weighted.mean(mun$idhm[k], mun$pop2010[k]) }, 0)
n_mun <- vapply(ordem, function(r) sum(mun$CD_RECORTE == r), 0L)
stopifnot(all(is.finite(idhm_c)), all(idhm_c > 0 & idhm_c < 1))
# exploratório, como no 77
Y0 <- t(vapply(ordem, function(r) unname(rds32[[r]]$principal$reduzida$coef), numeric(4))); S0 <- lapply(ordem, function(r) unname(rds32[[r]]$principal$reduzida$vcov))
mdx <- data.frame(md, idhm = unname(idhm_c), row.names = ordem)
e <- f$meta_exploratoria(Y0, S0, mdx, "idhm")
if (identical(e$status, "ok")) f$confere_meta(list(status = "ok", wald = e$wald, heterogeneidade = list(total = e$heterogeneidade$total)), "idhm", Y0, gl = 4L)
tab <- data.frame(recorte_principal = ordem, concentracao = unname(nome[ordem]), n_municipios = unname(n_mun), idhm2010 = unname(idhm_c), stringsAsFactors = FALSE)
saveRDS(list(idhm = tab, exploratorio = e, pop_igual = pop_igual, pop_dif_max = pop_dif_max, sha_entradas = sha_ent, rodada = rodada), f_out[["rds"]])
utils::write.csv(tab, f_out[["csv"]], row.names = FALSE, fileEncoding = "UTF-8"); sha_out <- vapply(f_out, sha, "")
stopifnot(versao() == "4443971b")
md_txt <- c("# Fase 4, Parte C4: exploratório do IDHM (D15, seção 2)", "",
  sprintf("- **Gerado por:** `00_scripts/82_c4_idhm_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()`: %s.", sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Código:** `segunda_etapa.R` `%s` (tag `segunda_etapa-v1.1`). **Entradas (SHA-256 = registrados):** %s.", sha_se, paste(sprintf("`%s` (`%s`)", ENT, sha_ent), collapse = "; ")),
  sprintf("- **Controle da população:** POP do Atlas igual à POP_CENSO2010 da base em %d de 277 municípios (diferença relativa máxima %s); a ponderação usa a da base (D15).", pop_igual, formatC(pop_dif_max, format = "g", digits = 3, decimal.mark = ",")), "",
  "## IDHM 2010 por concentração (média municipal ponderada pela população do Censo 2010)", "",
  tabela_md(data.frame(Concentração = tab$concentracao, Municípios = tab$n_municipios, IDHM = br(tab$idhm2010, 3), check.names = FALSE)), "",
  "## Exploratório (somado à média e à amplitude; IDHM centrado na média das 26)", "",
  if (identical(e$status, "ok")) c(
    sprintf("- **Centro:** %s. **Wald do termo:** %s (%s gl; p = %s).", br(e$centro, 3), br(e$wald$estatistica, 2), e$wald$gl, pfmt(e$wald$p)),
    sprintf("- **Q residual com o termo:** %s (%s gl), I² %s%%; **sem:** %s (%s gl), I² %s%%. Método: %s %s.", br(e$heterogeneidade$com$Q, 1), e$heterogeneidade$com$df, br(e$heterogeneidade$com$I2, 1),
            br(e$heterogeneidade$sem$Q, 1), e$heterogeneidade$sem$df, br(e$heterogeneidade$sem$I2, 1), e$metodo_com, e$bscov_com)) else sprintf("- **Não estimável:** %s.", paste(e$tentativas_com, collapse = " | ")),
  "- **Declarar (D15):** média ponderada dos IDHM municipais como aproximação; IDHM de 2010, anterior ao período de estudo; exploratório, sem P confirmatório (§6).", "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", f_out, sha_out), "", "- **Resultado:** ok.", "")
writeLines(md_txt, arq, useBytes = TRUE); cat("gravado:", arq, "\n")
