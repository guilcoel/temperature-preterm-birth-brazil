# 77_c4_meta_fase4.R — Fase 4, Parte C4: meta-análise do principal por outros modelos (mensagem "C2, C3 e C4 em lote",
# 19/10/2026, item 77; §6; D15; plano, script 77). Usa os coeficientes reduzidos da 1ª etapa do principal (32).
#   - efeitos fixos (meta_fixos) e multinível (meta_multinivel: concentração dentro de macrorregião; Ψ diagonal na região e
#     não estruturada na concentração; REML → diag → ML): confere_meta, curva na média dos metapreditores, TMR combinada no
#     eixo do principal (grade de 0,1 °C entre x1 e x99; IC bootstrap, semente 20261001, i = 0), RR no x99 e no x1 com
#     IC, borda pela D13, item 3; Q e I² residuais e totais; Wald;
#   - os exploratórios da D15, um de cada vez, somados à base (média + amplitude): macrorregião (fator, 5 níveis), % de
#     cesárea e cobertura de pré-natal (contínuos, centrados na média das 26; B1.5); Wald do termo (gl = 4 × gl do termo),
#     Q e I² residuais com e sem ele; confere_meta. IDHM: pendente (A1-103 e A1-104: download não feito).
# Saídas (fora do git): 01_saidas/fase4/c4_meta_fase4_<RODADA>.rds e .csv. Log logs/c4_meta_fase4_<RODADA>.md.
# Nunca sobrescreve. Confere antes: script commitado e limpo; código igual ao das tags; SHA-256 das entradas.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/77_c4_meta_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("c4_meta_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase4"); f_out <- c(rds = file.path(OUT, paste0("c4_meta_fase4_", rodada, ".rds")), csv = file.path(OUT, paste0("c4_meta_fase4_", rodada, ".csv")))
for (p in f_out) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/77_c4_meta_fase4.R"; CC <- file.path(REPO, "codigo_compartilhado")
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
icf <- function(a, li, ls, d = 3) sprintf("%s (%s a %s)", br(a, d), br(li, d), br(ls, d)); pfmt <- function(p) formatC(p, format = "g", digits = 3, decimal.mark = ",")
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
escreve_csv <- function(df, p) { num <- vapply(df, is.double, TRUE); df[num] <- lapply(df[num], function(v) ifelse(is.na(v), NA, sprintf("%.17g", v)))
  utils::write.csv(df, p, row.names = FALSE, na = "", fileEncoding = "UTF-8") }
sujos <- git("status", "--porcelain", "--", ESTE); if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current"); st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:"); inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"); t0 <- Sys.time()
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
sha_se <- sha(file.path(CC, "R", "segunda_etapa.R")); if (!identical(sha_se, tag_sha("segunda_etapa-v1.1", "codigo_compartilhado/R/segunda_etapa.R"))) stop("segunda_etapa.R difere da tag")
ENT <- c(rds32 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", rds45 = "01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds",
         ref = "01_saidas/fase1/referencias_exposicao.csv", cont = "01_saidas/fase4/contagens_insumos_fase4.csv")
SHA_FIXO <- c(rds32 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d", rds45 = "52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e",
              ref = "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467")
sha_ent <- vapply(ENT, sha, ""); ok_cont <- grepl(paste0("`", ENT[["cont"]], "`: `", sha_ent[["cont"]], "`"), paste(readLines("logs/contagens_insumos_fase4_20261018.md", encoding = "UTF-8"), collapse = "\n"), fixed = TRUE)
if (!ok_cont || !identical(unname(sha_ent[names(SHA_FIXO)]), unname(SHA_FIXO))) stop("entrada com SHA-256 diferente do registrado")
suppressPackageStartupMessages({ library(dlnm); library(mixmeta) })
f <- new.env(); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = f)
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
rds32 <- readRDS(ENT[["rds32"]])$resultados; r45 <- readRDS(ENT[["rds45"]])
ref <- utils::read.csv(ENT[["ref"]], colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ordem, ref$recorte_principal), ]
cont <- utils::read.csv(ENT[["cont"]], colClasses = c(recorte_principal = "character")); cont <- cont[match(ordem, cont$recorte_principal), ]
md <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1, row.names = ordem)
mdx <- data.frame(md, regiao = cont$macrorregiao, cesarea = cont$pct_cesarea, prenatal = cont$pct_prenatal_7mais, row.names = ordem)
Y0 <- t(vapply(ordem, function(r) unname(rds32[[r]]$principal$reduzida$coef), numeric(4))); S0 <- lapply(ordem, function(r) unname(rds32[[r]]$principal$reduzida$vcov))
base <- f$base_combinada(lapply(ordem, function(r) rds32[[r]]$principal$base$argvar)); eixo <- r45$eixo; ep <- r45$eixo_p
f$confere_eixo(eixo[["p1"]], eixo[["p99"]], unname(eixo))
curva_meta <- function(m, rot) { pc <- m$pred_media$coef; pv <- m$pred_media$vcov
  tc <- f$busca_tmr(pc, base, eixo[["p1"]], eixo[["p99"]], eixo[["p10"]], eixo[["p90"]], eixo[["p50"]]); bc <- f$boot_tmr(pc, pv, base, eixo[["p1"]], eixo[["p99"]], i = 0)
  cc <- f$curva(pc, pv, base, unname(eixo[c("p99", "p1")]), tc$tmr); lado <- if (!tc$fronteira) NA_character_ else if (tc$indice == 1L) "x1" else "x99"
  cm <- if (tc$fronteira) f$curva(pc, pv, base, unname(eixo[c("p99", "p1")]), eixo[["p50"]]) else NULL; h <- m$heterogeneidade
  data.frame(rotulo = rot, tmr = tc$tmr, percentil_tmr = f$posicao_no_eixo(tc$tmr, unname(eixo), ep), fronteira = tc$fronteira, lado_borda = lado, ic_tmr_li = bc$ic[1], ic_tmr_ls = bc$ic[2],
             rr99 = cc$rr[1], rr99_li = cc$rr_li[1], rr99_ls = cc$rr_ls[1], rr01 = cc$rr[2], rr01_li = cc$rr_li[2], rr01_ls = cc$rr_ls[2],
             rr99_mediana = if (is.null(cm)) NA else cm$rr[1], rr01_mediana = if (is.null(cm)) NA else cm$rr[2],
             Q_res = h$residual$Q, gl_res = h$residual$df, p_res = h$residual$p, I2_res = h$residual$I2, Q_tot = h$total$Q, gl_tot = h$total$df, I2_tot = h$total$I2,
             wald_media_p = m$wald$p[m$wald$termo == "media"], wald_amplitude_p = m$wald$p[m$wald$termo == "amplitude"], stringsAsFactors = FALSE) }
mf <- f$meta_fixos(Y0, S0, md); f$confere_meta(mf, c("media", "amplitude"), Y0)
mm <- f$meta_multinivel(Y0, S0, md, cont$macrorregiao); f$confere_meta(mm, c("media", "amplitude"), Y0)
mc0 <- r45$meta
modelos <- rbind(curva_meta(mc0, "Principal (REML, Ψ não estruturada; Fase 3, referência)"), curva_meta(mf, "Efeitos fixos"), curva_meta(mm, sprintf("Multinível (concentração dentro de macrorregião; %s, Ψ %s)", mm$metodo, paste(mm$bscov, collapse = "/"))))
exp_t <- do.call(rbind, lapply(c("regiao", "cesarea", "prenatal"), function(tm) { e <- f$meta_exploratoria(Y0, S0, mdx, tm)
  if (!identical(e$status, "ok")) return(data.frame(termo = tm, status = e$status, centro = NA, estatistica = NA, gl = NA, p = NA, Q_com = NA, gl_com = NA, I2_com = NA, Q_sem = NA, gl_sem = NA, I2_sem = NA, metodo = NA, stringsAsFactors = FALSE))
  gl_t <- if (tm == "regiao") 4L * (length(unique(mdx$regiao)) - 1L) else 4L; f$confere_meta(list(status = "ok", wald = e$wald, heterogeneidade = list(total = e$heterogeneidade$total)), tm, Y0, gl = gl_t)
  data.frame(termo = tm, status = "ok", centro = e$centro, estatistica = e$wald$estatistica, gl = e$wald$gl, p = e$wald$p, Q_com = e$heterogeneidade$com$Q, gl_com = e$heterogeneidade$com$df,
             I2_com = e$heterogeneidade$com$I2, Q_sem = e$heterogeneidade$sem$Q, gl_sem = e$heterogeneidade$sem$df, I2_sem = e$heterogeneidade$sem$I2, metodo = paste(e$metodo_com, e$bscov_com), stringsAsFactors = FALSE) }))
saveRDS(list(fixos = mf, multinivel = mm, modelos = modelos, exploratorios = exp_t, sha_entradas = sha_ent, rodada = rodada), f_out[["rds"]]); escreve_csv(modelos, f_out[["csv"]]); sha_out <- vapply(f_out, sha, "")
stopifnot(versao() == "4443971b")
rotulo_t <- c(regiao = "Macrorregião (fator, 5 níveis)", cesarea = "% de cesárea (centrada)", prenatal = "Cobertura de pré-natal, 7 ou mais consultas (centrada)")
md_txt <- c("# Fase 4, Parte C4: meta-análise do principal por efeitos fixos, multinível e exploratórios da D15", "",
  sprintf("- **Gerado por:** `00_scripts/77_c4_meta_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()`: %s.", sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Código:** `segunda_etapa.R` `%s` (tag `segunda_etapa-v1.1`). **Entradas (SHA-256 = registrados):** %s.", sha_se, paste(sprintf("`%s` (`%s`)", ENT, sha_ent), collapse = "; ")), "",
  "## Modelos (curva na média dos metapreditores; TMR no eixo do principal)", "",
  tabela_md(data.frame(Modelo = modelos$rotulo, `TMR °C (percentil)` = sprintf("%s (%s)%s", br(modelos$tmr, 1), br(100 * modelos$percentil_tmr, 1), ifelse(modelos$fronteira, paste0(" [borda ", modelos$lado_borda, "]"), "")),
                       `IC da TMR` = sprintf("%s a %s", br(modelos$ic_tmr_li, 1), br(modelos$ic_tmr_ls, 1)), `RR x99 (IC)` = icf(modelos$rr99, modelos$rr99_li, modelos$rr99_ls), `RR x1 (IC)` = icf(modelos$rr01, modelos$rr01_li, modelos$rr01_ls),
                       `Q residual (gl); I²` = sprintf("%s (%d); %s%%", br(modelos$Q_res, 1), as.integer(modelos$gl_res), br(modelos$I2_res, 1)), `Q total (gl); I²` = sprintf("%s (%d); %s%%", br(modelos$Q_tot, 1), as.integer(modelos$gl_tot), br(modelos$I2_tot, 1)), check.names = FALSE)), "",
  sprintf("- Multinível: tentativas %s; log-verossimilhança %s.", paste(mm$tentativas, collapse = " | "), br(mm$logLik, 2)), "",
  "## Exploratórios da D15 (um de cada vez, somados à média e à amplitude; exploratórios e rotulados como tal)", "",
  tabela_md(data.frame(Metapreditor = rotulo_t[exp_t$termo], Wald = sprintf("%s (%s gl; p = %s)", br(exp_t$estatistica, 2), exp_t$gl, pfmt(exp_t$p)),
                       `Q residual com o termo (gl); I²` = sprintf("%s (%s); %s%%", br(exp_t$Q_com, 1), exp_t$gl_com, br(exp_t$I2_com, 1)),
                       `Q residual sem (gl); I²` = sprintf("%s (%s); %s%%", br(exp_t$Q_sem, 1), exp_t$gl_sem, br(exp_t$I2_sem, 1)), Método = exp_t$metodo, check.names = FALSE)), "",
  "- **IDHM 2010:** pendente (download não feito; A1-103 e A1-104). Sem valor de P confirmatório nos exploratórios (§6).", "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", f_out, sha_out), "", sprintf("- **Resultado:** ok. Tempo: %.1f min.", as.numeric(difftime(Sys.time(), t0, units = "mins"))), "")
writeLines(md_txt, arq, useBytes = TRUE); cat("gravado:", arq, "\n")
