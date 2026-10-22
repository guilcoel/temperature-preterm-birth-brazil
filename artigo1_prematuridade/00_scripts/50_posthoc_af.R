# 50_posthoc_af.R — Fase 3, Parte D: análises post hoc da D5 (não pré-especificadas), registradas nas entradas 78 e 79
# antes de rodar. Usa codigo_compartilhado/R/posthoc_af.R com as funções da tag segunda_etapa-v1.0, sem alterá-las.
# Antes de calcular, confere: segunda_etapa.R e ajusta_dlnm.R iguais à tag; attrdl.R; MASS igual ao renv.lock; BLAS e
# LAPACK de referência; SHA-256 das entradas; a RDS do 45 e o CSV do 46 contra os logs deles.
#   - Testes do item 2 (entrada 78(c)) no principal observado, nas 26: (i) base da attrdl × base da busca da MRT;
#     (ii) folga g na grade fina de 0,001 °C e menor Δ_t nos dias da janela dentro do p1–p99.
#   - P1: Wald (4 gl) dos coeficientes previstos na média dos metapreditores, com a vcov da predição.
#   - P2: 1.000 réplicas sob o nulo estrito (D5, item 4, passos 1 a 7); falhas contadas; única comparação: AF total
#     observada × p97,5 da distribuição nula; o resto descritivo, sem p.
# Só resultados de modelo e agregados; nenhuma série diária, AN ou AF diário. Grava logs/posthoc_af_fase3_<FASE3_DATA>.md
# e 01_saidas/fase3/posthoc_*. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE3_DATA=AAAAMMDD Rscript 00_scripts/50_posthoc_af.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE3_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; CC <- file.path("..", "codigo_compartilhado")
arq <- file.path("logs", paste0("posthoc_af_fase3_", hoje, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase3"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
saidas <- c(rep = file.path(OUT, paste0("posthoc_p2_replicas_fase3_", hoje, ".csv")), item2 = file.path(OUT, paste0("posthoc_item2_fase3_", hoje, ".csv")),
            rds = file.path(OUT, paste0("posthoc_af_fase3_", hoje, ".rds")))
stopifnot(!any(file.exists(saidas)))
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
pc <- function(x, d = 2) paste0(br(100 * x, d), "%")
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
escreve_csv <- function(df, p) { num <- vapply(df, is.double, TRUE); df[num] <- lapply(df[num], function(v) ifelse(is.na(v), NA, sprintf("%.17g", v)))
  utils::write.csv(df, p, row.names = FALSE, na = "", fileEncoding = "UTF-8") }

# ------------------------------------------------------------------ conferências
s_info <- sessionInfo()
if (!(basename(s_info$BLAS) == "libRblas.0.dylib" && basename(s_info$LAPACK) == "libRlapack.dylib")) stop("BLAS/LAPACK fora da referência (§8)")
TAG <- "segunda_etapa-v1.0"; if (!identical(git("rev-parse", paste0(TAG, "^{commit}")), "410dd6d6d3d315004f22fd7197c326de77f3c2f4")) stop("tag fora do commit esperado")
for (a in git("ls-tree", "-r", "--name-only", TAG, "codigo_compartilhado/R/")) {
  st <- sub(" .*", "", system(paste("git -C", shQuote(REPO), "show", shQuote(paste0(TAG, ":", a)), "| shasum -a 256"), intern = TRUE))
  if (!identical(st, sha(file.path(REPO, a)))) stop(a, " difere da tag ", TAG) }
lock <- jsonlite::fromJSON("renv.lock")$Packages$MASS$Version
if (utils::packageVersion("MASS") != package_version(lock)) stop("MASS diferente do renv.lock")
f_at <- file.path(CC, "inst", "terceiros", "attrdl.R"); SHA_ATTRDL <- "d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d"
suppressPackageStartupMessages({ library(dlnm); library(gnm); library(mixmeta) })
f <- new.env(); for (a in c("ajusta_dlnm.R", "segunda_etapa.R", "posthoc_af.R")) sys.source(file.path(CC, "R", a), envir = f)
attrdl <- f$carrega_attrdl(f_at, SHA_ATTRDL)
sha_cod <- vapply(c("codigo_compartilhado/R/posthoc_af.R", "codigo_compartilhado/R/segunda_etapa.R", "codigo_compartilhado/R/ajusta_dlnm.R",
                    "codigo_compartilhado/tests/testa_posthoc_af.R"), function(a) sha(file.path(REPO, a)), "")
L49 <- paste(readLines(file.path("logs", paste0("testes_posthoc_af_fase3_", hoje, ".md")), encoding = "UTF-8"), collapse = "\n")
if (!grepl(sprintf("`codigo_compartilhado/R/posthoc_af.R`: `%s`", sha_cod[[1]]), L49, fixed = TRUE)) stop("posthoc_af.R diferente do testado no 49")
if (!grepl("cada um dos 15 defeitos derruba pelo menos um teste", L49, fixed = TRUE)) stop("o 49 não passou")
ENT <- c(rds2 = "01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds", ser1 = "01_saidas/fase1/serie_ptb_principal.rds",
         ref = "01_saidas/fase1/referencias_exposicao.csv")
SHA_ENT <- c(rds2 = "5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d", ser1 = "635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917",
             ref = "281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467")
sha_ent <- vapply(ENT, sha, ""); if (!identical(sha_ent, SHA_ENT)) stop("entrada com SHA-256 diferente do registrado")
f45 <- file.path("01_saidas", "fase3", "segunda_etapa_principal_fase3_20261013.rds"); f46 <- file.path("01_saidas", "fase3", "fracao_atribuivel_fase3_20261013.csv")
L45 <- paste(readLines("logs/segunda_etapa_fase3_20261013.md", encoding = "UTF-8"), collapse = "\n"); L46 <- paste(readLines("logs/fracao_atribuivel_fase3_20261013.md", encoding = "UTF-8"), collapse = "\n")
sha45 <- sha(f45); sha46 <- sha(f46)
if (!grepl(sprintf("`%s`: `%s`", f45, sha45), L45, fixed = TRUE) || !grepl(sprintf("`%s`: `%s`", f46, sha46), L46, fixed = TRUE)) stop("saídas do 45/46 diferentes dos logs")
r45 <- readRDS(f45); a46 <- utils::read.csv(f46, colClasses = c(recorte_principal = "character"))
nuc <- as.data.frame(cidade_nucleo()); f$confere_ordem(nuc$CD_RECORTE); ordem <- f$ORDEM_CONCENTRACOES; stopifnot(identical(r45$ordem, ordem))
nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
P1 <- lapply(readRDS(ENT[["rds2"]])$resultados[ordem], `[[`, "principal")
ref <- utils::read.csv(ENT[["ref"]], colClasses = c(recorte_principal = "character"), check.names = FALSE, encoding = "UTF-8")
ref <- ref[ref$periodo == "ano inteiro 2012–2024", ]; ref <- ref[match(ordem, ref$recorte_principal), ]; stopifnot(identical(ref$recorte_principal, ordem))
md <- data.frame(media = ref$media, amplitude = ref$amplitude_p99_p1, row.names = ordem)
S <- lapply(ordem, function(r) unname(P1[[r]]$reduzida$vcov))
base <- f$base_combinada(lapply(ordem, function(r) P1[[r]]$base$argvar)); if (!identical(base, r45$base)) stop("base combinada diferente da do 45")
eixo <- r45$eixo
INI <- as.Date("2012-04-07"); INI_JAN <- as.Date("2012-04-14"); FIM <- as.Date("2024-08-06")
s <- readRDS(ENT[["ser1"]]); s <- as.data.frame(s)[s$data >= INI & s$data <= FIM, c("recorte_principal", "data", "tmean_nucleo", "ptb", "janela_principal")]
dados <- lapply(ordem, function(r) { z <- s[s$recorte_principal == r, ]; z <- z[order(z$data), ]
  stopifnot(nrow(z) == 4505L, all(diff(z$data) == 1), identical(z$janela_principal, z$data >= INI_JAN), !anyNA(z$ptb[z$janela_principal]))
  jw <- which(z$janela_principal); g <- r45$grade[r, ]
  list(x = z$tmean_nucleo[jw], cases = z$ptb[jw], basis = f$monta_cb(z$tmean_nucleo, z$data, P1[[r]]$base$argvar, P1[[r]]$base$arglag, lag = 7),
       p1 = g[["p1"]], p2_5 = g[["p2,5"]], p10 = g[["p10"]], p50 = g[["p50"]], p90 = g[["p90"]], p97_5 = g[["p97,5"]], p99 = g[["p99"]]) })
names(dados) <- ordem; rm(s)
den_ok <- all(vapply(ordem, function(r) identical(as.integer(sum(dados[[r]]$cases)), as.integer(P1[[r]]$n$eventos)), TRUE)); if (!den_ok) stop("eventos da janela diferentes do n$eventos")
log_msg("conferências: ok")

# ------------------------------------------------------------------ testes do item 2 no principal observado
tb45 <- r45$tmr[r45$tmr$nivel == "blup", ]
it2 <- do.call(rbind, lapply(ordem, function(r) { d <- dados[[r]]; av <- P1[[r]]$base$argvar; mrt <- tb45$tmr[tb45$recorte_principal == r]
  b <- f$testa_base_mrt(d$basis, av, f$grade_tmr(d$p1, d$p99))
  ct <- f$testa_contribuicoes(r45$blup[[r]]$coef, av, attr(d$basis, "argvar"), d$x, d$p1, d$p99, mrt)
  data.frame(recorte_principal = r, dif_base = b$dif, base_ok = b$ok, g = ct$g, min_delta = ct$min_delta, n_dentro = ct$n_dentro, contribuicoes_ok = ct$ok, stringsAsFactors = FALSE) }))
# diagnóstico (acrescentado depois da rodada de desenvolvimento, sem mudar o critério registrado): quanto o menor f(x_t)
# fica abaixo do mínimo da grade, com o passo registrado (0,001 °C) e com um passo 100 vezes menor (1e-5 °C)
diag2 <- do.call(rbind, lapply(ordem, function(r) { d <- dados[[r]]; av <- P1[[r]]$base$argvar; cf <- r45$blup[[r]]$coef
  fb <- function(z) drop(unclass(do.call(dlnm::onebasis, c(list(x = z), av))) %*% cf)
  fa <- function(z) { a2 <- attr(d$basis, "argvar"); a2$cen <- NULL; drop(unclass(do.call(dlnm::onebasis, c(list(x = z), a2))) %*% cf) }
  xd <- d$x[d$x >= d$p1 & d$x <= d$p99]; mx <- min(fa(xd))
  m3 <- min(fb(c(seq(d$p1, d$p99, by = 1e-3), d$p99))); m5 <- min(fb(c(seq(d$p1, d$p99, by = 1e-5), d$p99)))
  data.frame(recorte_principal = r, falta_passo_1e3 = mx - m3, falta_passo_1e5 = mx - m5, ok_passo_1e5 = (mx - m5) >= -1e-12, stringsAsFactors = FALSE) }))
it2 <- merge(it2, diag2, by = "recorte_principal", sort = FALSE); it2 <- it2[match(ordem, it2$recorte_principal), ]; rownames(it2) <- NULL
log_msg("item 2: base ok em", sum(it2$base_ok), "| contribuições ok em", sum(it2$contribuicoes_ok), "| diagnóstico com passo 1e-5 ok em", sum(it2$ok_passo_1e5))

# ------------------------------------------------------------------ P1
p1 <- f$wald_curva(r45$meta$pred_media$coef, r45$meta$pred_media$vcov)
log_msg("P1: W =", round(p1$W, 3), "| p =", signif(p1$p, 3))

# ------------------------------------------------------------------ P2
R <- 1000L; t0 <- Sys.time()
tab <- f$p2_nulo(R, S, md, unname(dados), base, eixo, attrdl, progresso = function(r) if (r %% 100 == 0) log_msg("P2: réplica", r))
dur <- as.numeric(Sys.time() - t0, units = "mins")
obs <- a46[a46$analise == "principal" & a46$recorte_principal == "total", ]; af_obs <- obs$af[obs$componente == "total"]
rs <- f$resumo_p2(tab, af_obs)
cc <- r45$contrastes[r45$contrastes$nivel == "combinada", ]
obs_desc <- c(af_calor = obs$af[obs$componente == "calor"], af_frio = obs$af[obs$componente == "frio"], rr_x99 = cc$rr[cc$percentil == "p99"], rr_x1 = cc$rr[cc$percentil == "p1"],
              n_mrt_p99 = sum(abs(tb45$tmr - tb45$x_sup) < 1e-8), n_mrt_p1 = sum(abs(tb45$tmr - tb45$x_inf) < 1e-8))
log_msg("P2:", R, "réplicas em", round(dur, 1), "min | falhas:", rs$n_falhas, "| AF obs > p97,5:", rs$passa)

# ------------------------------------------------------------------ saídas
escreve_csv(tab, saidas[["rep"]]); escreve_csv(it2, saidas[["item2"]])
saveRDS(list(p1 = p1, item2 = it2, p2 = tab, resumo = rs, obs_desc = obs_desc, af_obs = af_obs, sha_codigo = sha_cod, sha_entradas = c(sha_ent, rds45 = sha45, csv46 = sha46),
             blas = s_info$BLAS, lapack = s_info$LAPACK, versao_base = v_ini, data = hoje), saidas[["rds"]])
sha_out <- vapply(saidas, sha, "")

# ------------------------------------------------------------------ log
stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
fq <- function(x, tipo) switch(tipo, af = pc(x, 2), rr = br(x, 3), n = br(x, 1), n0 = br(x, 0))
tipo_de <- c(af_calor = "af", af_frio = "af", rr_x99 = "rr", rr_x1 = "rr", n_mrt_p99 = "n", n_mrt_p1 = "n")
rot <- c(af_calor = "AF de calor", af_frio = "AF de frio", rr_x99 = "RR combinado no x99 (contra a MRT combinada)", rr_x1 = "RR combinado no x1 (contra a MRT combinada)",
         n_mrt_p99 = "Número de MRT BLUP no p99 (de 26)", n_mrt_p1 = "Número de MRT BLUP no p1 (de 26)")
md_txt <- c("# Fase 3, Parte D: análises post hoc da D5 (não pré-especificadas)", "",
  sprintf("- **Gerado por:** `00_scripts/50_posthoc_af.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha).", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini),
  sprintf("- **Ambiente:** R %s; dlnm %s; mixmeta %s; MASS %s (igual ao `renv.lock`). BLAS/LAPACK: `%s` / `%s` (referência).",
          paste(R.version$major, R.version$minor, sep = "."), packageVersion("dlnm"), packageVersion("mixmeta"), packageVersion("MASS"), s_info$BLAS, s_info$LAPACK),
  "- **Rótulo:** análises post hoc, registradas nas entradas 78 e 79 (commits `7e071cd` e `e925532`) antes de rodar e depois de ver os resultados da Fase 3; decisão de origem `spec/decisoes_metodo_20261013_D5_interpretacao_AF.md` (SHA-256 `24f131e8…`). Nenhuma análise especificada muda.",
  "- **Código (SHA-256):**", sprintf("  - `%s`: `%s`;", names(sha_cod), sha_cod),
  "  - `segunda_etapa.R` e `ajusta_dlnm.R` iguais aos da tag `segunda_etapa-v1.0`; `posthoc_af.R` igual ao testado no 49; `attrdl.R` conferido.",
  "- **Entradas (SHA-256 conferidos):**", sprintf("  - `%s`: `%s`;", c(ENT, f45, f46), c(sha_ent, sha45, sha46)),
  "  - a RDS do 45 e o CSV do 46 conferem com os logs deles; os eventos da janela de cada concentração são o `n$eventos` da primeira etapa.", "",
  "## Testes do item 2 (entrada 78(c)), no principal observado", "",
  sprintf("- **(i) Pré-condição:** a base que a `attrdl` reconstrói de `attr(cb, \"argvar\")` é igual à base da busca da MRT (a `argvar` da RDS, usada no 45), na grade p1–p99 de cada concentração: %s; diferença máxima %s (critério ≤ 1e-12).",
          if (all(it2$base_ok)) "sim, nas 26" else sprintf("NÃO em %d", sum(!it2$base_ok)), formatC(max(it2$dif_base), format = "e", digits = 1)),
  sprintf("- **(ii) Contribuições:** g = f(MRT) − mín f na grade fina de 0,001 °C entre o p1 e o p99 (base da busca), e Δ_t = f(x_t) − f(MRT) nos dias da janela com x_t dentro do p1–p99 (base que a `attrdl` reconstrói); exigido Δ_t ≥ −max(g, 0) − 1e-12: %s. **g máximo:** %s; **menor Δ_t:** %s.",
          if (all(it2$contribuicoes_ok)) "sim, nas 26" else sprintf("NÃO em %d (%s)", sum(!it2$contribuicoes_ok), paste(nome[it2$recorte_principal[!it2$contribuicoes_ok]], collapse = ", ")),
          formatC(max(it2$g), format = "e", digits = 3), formatC(min(it2$min_delta), format = "e", digits = 3)),
  "- Implementação: com as duas bases iguais, a condição (ii) equivale a f(x_t) ≥ mín f na grade fina − 1e-12; ela cai se a base da `attrdl` diferir da base da busca. A folga g mede quanto a MRT da grade de 0,1 °C fica acima do mínimo na grade fina.",
  sprintf("- **Diagnóstico** (acrescentado depois da rodada de desenvolvimento, que mostrou a falha; o critério registrado, com o passo de 0,001 °C, não muda): quanto o menor f(x_t) dos dias dentro do p1–p99 fica abaixo do mínimo da grade, com o passo registrado e com um passo 100 vezes menor (1e-5 °C). Com o passo de 1e-5 °C, o menor f(x_t) fica a no máximo 1e-12 abaixo do mínimo da grade em %s. %s",
          if (all(it2$ok_passo_1e5)) "todas as 26 concentrações" else sprintf("%d de 26", sum(it2$ok_passo_1e5)),
          if (any(!it2$contribuicoes_ok) && all(it2$ok_passo_1e5[!it2$contribuicoes_ok]) && all(it2$base_ok)) "Nas concentrações em que o teste (ii) cai, a falha vem da resolução da grade fina: há dias com x_t entre dois pontos da grade de 0,001 °C, mais perto do mínimo da curva, e a base da `attrdl` é igual à da busca (teste (i)). A decisão sobre o critério fica com o chat." else ""), "",
  tabela_md(data.frame(Concentração = nome[it2$recorte_principal], `Diferença das bases` = formatC(it2$dif_base, format = "e", digits = 1), g = formatC(it2$g, format = "e", digits = 3),
                       `Menor Δ_t` = formatC(it2$min_delta, format = "e", digits = 3), `Dias dentro do p1–p99` = br(it2$n_dentro, 0),
                       Resultado = ifelse(it2$base_ok & it2$contribuicoes_ok, "ok", "FALHOU"),
                       `Diagnóstico: falta com passo 0,001` = formatC(it2$falta_passo_1e3, format = "e", digits = 2),
                       `Diagnóstico: falta com passo 1e-5` = formatC(it2$falta_passo_1e5, format = "e", digits = 2), check.names = FALSE)), "",
  "## P1: teste de Wald da curva combinada", "",
  sprintf("- Os 4 coeficientes previstos pelo `mixmeta` na média dos metapreditores (média %s °C; amplitude %s °C), com a vcov da predição: **W = %s; gl = %d; p = %s** (χ²). O teste não depende da MRT.",
          br(r45$meta$pred_media$metapred$media, 3), br(r45$meta$pred_media$metapred$amplitude, 3), br(p1$W, 2), p1$gl, formatC(p1$p, format = "g", digits = 3, decimal.mark = ",")), "",
  "## P2: referência nula da AF (nulo estrito; descritiva)", "",
  sprintf("- **Procedimento** (D5, item 4, passos 1 a 7; entrada 79): `set.seed(20261001, kind = \"Mersenne-Twister\", normal.kind = \"Inversion\", sample.kind = \"Rejection\")` uma vez antes do laço; %s réplicas; em cada uma, θᵢ* ~ N(0, Sᵢ) pelo `MASS::mvrnorm` nas 26 concentrações, na ordem travada, com Sᵢ = vcov reduzida da primeira etapa; segunda etapa com a sequência de estabilidade da C1; MRT BLUP na grade p1–p99; AF *forward* pontual (`attrdl` com `sim = FALSE`) na série completa e consecutiva, contra a MRT da réplica; RR combinados contra a MRT combinada da réplica. Duração: %s min.", br(R, 0), br(dur, 1)),
  sprintf("- **Falhas** (sequência inteira do `mixmeta` falhou): %s de %s%s.", br(rs$n_falhas, 0), br(rs$n, 0), if (rs$n_falhas) paste0(" (réplicas ", paste(rs$replicas_falhas, collapse = ", "), ")") else ""),
  sprintf("- **Método do `mixmeta` nas réplicas:** %s.", paste(sprintf("%s em %d", names(rs$metodos), as.integer(rs$metodos)), collapse = "; ")), "",
  sprintf("**Única comparação:** AF total observada (principal) %s contra a distribuição nula: mediana %s (p2,5 a p97,5: %s a %s). A AF observada **%s** o p97,5.",
          pc(af_obs), pc(rs$af_total[["mediana"]]), pc(rs$af_total[["p2_5"]]), pc(rs$af_total[["p97_5"]]), if (rs$passa) "passa" else "não passa"),
  if (rs$n_falhas) sprintf("Com as %d réplicas que falharam nos dois extremos, o p97,5 fica entre %s e %s; a AF observada %s e %s esses limites.", rs$n_falhas,
                           if (rs$p97_5_falhas_inf < -1e299) "−∞" else pc(rs$p97_5_falhas_inf), if (rs$p97_5_falhas_sup > 1e299) "+∞" else pc(rs$p97_5_falhas_sup),
                           if (rs$passa_falhas_inf) "passa" else "não passa", if (rs$passa_falhas_sup) "passa" else "não passa") else
    "Sem falhas: a distribuição com e sem as réplicas que falharam é a mesma.", "",
  "**Distribuições descritivas, sem p** (réplicas sem falha; observado ao lado):", "",
  tabela_md(do.call(rbind, lapply(rs$descritivas$quantidade, function(v) { d <- rs$descritivas[rs$descritivas$quantidade == v, ]; tp <- tipo_de[[v]]
    data.frame(Quantidade = rot[[v]], Observado = fq(obs_desc[[v]], if (tp == "n") "n0" else tp) , `Mediana nula` = fq(d$mediana, tp),
               `p2,5 a p97,5 nulos` = sprintf("%s a %s", fq(d$p2_5, tp), fq(d$p97_5, tp)), check.names = FALSE) }))), "",
  "- **O que a P2 não é** (D5, item 4): não corrige a AF (nada é subtraído); não testa associação combinada (isso é a P1); supõe coeficientes normais com a vcov estimada, como a própria segunda etapa, e não reajusta o `gnm`. Como o nulo é o estrito, uma AF observada acima da referência indicaria associações específicas de concentração ou heterogeneidade, não uma associação combinada.", "",
  "## Saídas (fora do git)", "", sprintf("- `%s`: `%s`;", saidas, sha_out), "",
  sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md_txt, arq, useBytes = TRUE)
cat("gravado:", arq, "| P1 p =", signif(p1$p, 3), "| P2 falhas:", rs$n_falhas, "| AF obs > p97,5:", rs$passa, "\n")
