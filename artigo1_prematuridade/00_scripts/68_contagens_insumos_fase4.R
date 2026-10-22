# 68_contagens_insumos_fase4.R — Fase 4, Parte B1.5: contagens e insumos dos metapreditores (mensagem da Parte B do
# chat do A1, 18/10/2026, item B1.5; plano da Fase 4, script 68; D12, 4.1; D15; A1-89, A1-94, A1-96, A1-98). Nenhum
# modelo de desfecho; nenhuma contagem cruzada com clima.
# 1. Eventos por concentração (só contagens):
#    - na janela principal (2012-04-14 a 2024-08-06): PTB do principal (referência), os três subtipos, PTB espontâneo (i)
#      e (ii) (séries da Fase 1, conferidas no 64), §3.5 (i) e (ii) (série do 67);
#    - termo precoce: na janela dele (2012-04-28 a 2024-11-19) e na interseção (2012-04-28 a 2024-08-06) (série do 66).
#    No log: contagem de 1 a 9 sai como "<10"; supressão complementar nos conjuntos encaixados que saem na mesma linha
#    (extremo + muito + moderado-tardio = PTB; espontâneo (i) ⊂ (ii) ⊂ PTB; §3.5 (i) ⊂ PTB; termo na interseção ⊂ termo
#    na janela): se uma diferença entre eles cair de 1 a 9, ou se exatamente uma parte da partição dos subtipos for
#    mascarada, a célula complementar sai como "s.c." (supressão complementar). Sem linha de total.
# 2. Listas da regra de < 1.000 eventos na janela principal: subtipos (D12, 4.1) e §3.5, versões (i) e (ii) (A1-98).
#    PTB espontâneo (i): se alguma concentração tiver < 1.000, PARE (não há regra registrada; a decisão vem do chat).
# 3. regra_gama() e decide_gama() do offset v1.1 (regra única da §3.2; D12, 4.1; A1-89): insumos fixos = distribuição de
#    IG da Q8 (RESPOSTA_QUESTIONAMENTO_20261007.md da base, seção Q8, lida do arquivo, SHA-256 conferido; total
#    13.791.848 conferido) e eventos = soma da Q8 nas semanas de cada desfecho:
#    - subtipos (pesos por gestação): extremo 22–27, muito 28–31, moderado-tardio 32–36;
#    - termo precoce por pessoa-dia: 37–38;
#    - o PTB (22–36, por gestação) entra como referência da calibração da Parte A (EP de 0,07 a 0,14: γ estimado).
#    Conferência extra: a distribuição da Q8 é igual à recontada pela interface (NV da população do principal nascidos
#    em 2012–2024).
# 4. consultas_cat (D15, item 1): distribuição por ano, 2012–2024, na população da D15 (NV únicos com ga_sem de 22 a 42
#    das 26 concentrações, nascidos de 2012-01-01 a 2024-12-31, sem coorte fixa). Critério de estabilidade, fixado aqui
#    antes de rodar (a mensagem não dá número): (a) em todo ano, os códigos 1, 2, 3 e 4 presentes e nenhum código fora
#    de {1, 2, 3, 4, 9} além do vazio (NA); (b) ignorado (9 ou NA) ≤ 10% dos NV em todo ano; (c) variação do % de
#    ignorado entre anos consecutivos ≤ 5 pontos percentuais; (d) variação, entre anos consecutivos, da fração do código 4
#    entre os códigos 1–4 ≤ 10 pontos. Se algum falhar: PARE (a cobertura de pré-natal não é calculada).
# 5. Insumos dos metapreditores (D15), na mesma população da D15, um valor por concentração (soma dos numeradores ÷ soma
#    dos denominadores): % de cesárea (parto = 2 ÷ parto ∈ {1, 2}; ignorado = 9 ou vazio, reportado); cobertura de
#    pré-natal (consultas_cat = 4 ÷ consultas_cat ∈ {1, 2, 3, 4}; ignorado reportado); macrorregião pelo 1º dígito do
#    código IBGE do município-núcleo (1 Norte, 2 Nordeste, 3 Sudeste, 4 Sul, 5 Centro-Oeste), conferida contra a §6
#    (2, 9, 8, 3 e 4 concentrações; senão PARE).
# 6. IDHM 2010: NÃO baixado. O site do Atlas (www.atlasbrasil.org.br) não tem arquivo estático da tabela municipal: o
#    caminho antigo dos dados brutos dá 404 no www, o domínio sem www tem certificado autoassinado, e a tabela só sai pela
#    ferramenta de consulta (/consulta/planilha), que monta a planilha por POST à API do site depois de escolher
#    indicadores e territórios. Pela mensagem (B1.5: "se o download exigir conta, formulário ou outro domínio, PARE e
#    informe"), o IDHM fica pendente; ele só entra na meta-regressão exploratória da C4 e não bloqueia a C1.
# Grava, fora do git: 01_saidas/fase4/contagens_insumos_fase4.csv (contagens sem máscara, para a C1) e
#   01_saidas/fase4/consultas_cat_por_ano_fase4.csv. Grava logs/contagens_insumos_fase4_<RODADA>.md (só com máscara).
#   Nunca sobrescreve. PARE: grava o log e sai com quit(status = 1).
# Confere antes: este script commitado e limpo; offset.R e segunda_etapa.R iguais aos das tags.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD Rscript 00_scripts/68_contagens_insumos_fase4.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao()
rodada <- Sys.getenv("RODADA"); stopifnot(grepl("^[0-9]{8}$", rodada))
arq <- file.path("logs", paste0("contagens_insumos_fase4_", rodada, ".md")); stopifnot(!file.exists(arq))
OUT <- file.path("01_saidas", "fase4"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
f_out <- c(cont = "contagens_insumos_fase4.csv", cons = "consultas_cat_por_ano_fase4.csv")
f_out <- setNames(file.path(OUT, f_out), names(f_out)); for (p in f_out) stopifnot(!file.exists(p))
REPO <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; ESTE <- "artigo1_prematuridade/00_scripts/68_contagens_insumos_fase4.R"
CC <- file.path(REPO, "codigo_compartilhado")
F_Q8 <- "/Volumes/Forja/Doc/dados_artigos_perinatais_clima/RESPOSTA_QUESTIONAMENTO_20261007.md"; SHA_Q8 <- "16fe31e9af56e3e950e2bf11f795b19fedd4552c9983798b5eac4227385d011e"
git <- function(...) system2("git", c("-C", REPO, ...), stdout = TRUE)
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
tabela_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                            apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
log_msg <- function(...) cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")

sujos <- git("status", "--porcelain", "--", ESTE)
if (length(sujos)) { cat(sujos, sep = "\n"); stop("script com mudança não commitada: não roda") }
head_c <- git("rev-parse", "HEAD"); ramo <- git("branch", "--show-current")
st_a1 <- git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord <- git("log", "-1", shQuote("--format=%h %s"), "--grep=^COORD:")
stopifnot(length(head_c) == 1L, length(ramo) == 1L, length(coord) == 1L)
inicio <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"); t0 <- Sys.time()
tag_sha <- function(tag, p) { tf <- tempfile(); writeLines(git("show", paste0(tag, ":", p)), tf, useBytes = TRUE); s <- sha(tf); unlink(tf); s }
COD <- c(offset = "offset-v1.1", segunda_etapa = "segunda_etapa-v1.1")
sha_cod <- vapply(names(COD), function(k) sha(file.path(CC, "R", paste0(k, ".R"))), "")
for (k in names(COD)) if (!identical(sha_cod[[k]], tag_sha(COD[[k]], paste0("codigo_compartilhado/R/", k, ".R")))) stop(k, ".R difere da tag ", COD[[k]])
of <- new.env(); sys.source(file.path(CC, "R", "offset.R"), envir = of)
se <- new.env(); sys.source(file.path(CC, "R", "segunda_etapa.R"), envir = se)
D <- as.Date; JP <- D(c("2012-04-14", "2024-08-06"))
nuc <- as.data.frame(cidade_nucleo()); se$confere_ordem(nuc$CD_RECORTE); ordem <- se$ORDEM_CONCENTRACOES; nome <- setNames(nuc$NM_RECORTE, nuc$CD_RECORTE)
conc <- as.data.frame(concentracoes())[, c("CD_MUN6", "CD_RECORTE")]
falhas <- character(0); para <- character(0)
confere <- function(cond, txt) { if (!isTRUE(cond)) falhas <<- c(falhas, txt); isTRUE(cond) }

# ------------------------------------------------------------------ entradas (SHA no log)
f_in <- c(s1 = "01_saidas/fase1/serie_ptb_principal.rds", esp = "01_saidas/fase1/serie_ptb_espontaneo.rds",
          dum = "01_saidas/fase4/serie_ig_dum_fase4.rds", tp = "01_saidas/fase4/serie_termo_precoce_fase4.rds")
stopifnot(all(file.exists(f_in))); sha_in <- vapply(f_in, sha, "")
s1 <- readRDS(f_in[["s1"]]); es <- readRDS(f_in[["esp"]]); du <- readRDS(f_in[["dum"]]); tp <- readRDS(f_in[["tp"]])
soma <- function(df, col, jan) vapply(ordem, function(r) sum(df[[col]][df$recorte_principal == r & df[[jan]]]), 0)
es$jp <- es$janela_principal; du$jp <- du$janela_principal; s1$jp <- s1$janela_principal
ev <- data.frame(recorte_principal = ordem, concentracao = unname(nome[ordem]),
                 ptb = soma(s1, "ptb", "jp"), extremo = soma(s1, "ptb_extremo", "jp"), muito = soma(s1, "ptb_muito", "jp"), moderado_tardio = soma(s1, "ptb_moderado_tardio", "jp"),
                 esp_i = soma(es, "ptb_espontaneo_i", "jp"), esp_ii = soma(es, "ptb_espontaneo_ii", "jp"), esp_ignorado = soma(es, "ptb_ignorado", "jp"), esp_iniciado = soma(es, "ptb_iniciado", "jp"),
                 dum_i = soma(du, "ptb_dum_i", "jp"), dum_ii = soma(du, "ptb_dum_ii", "jp"),
                 termo_janela = soma(tp, "termo_precoce", "janela_termo"), termo_intersecao = soma(tp, "termo_precoce", "janela_intersecao"), stringsAsFactors = FALSE)
ok_part <- confere(all(ev$extremo + ev$muito + ev$moderado_tardio == ev$ptb) && all(ev$esp_i + ev$esp_ignorado == ev$esp_ii) &&
                   all(ev$esp_ii + ev$esp_iniciado == ev$ptb) && all(ev$dum_i <= ev$ptb) && all(ev$termo_intersecao <= ev$termo_janela), "identidades das contagens não fecham")

# máscara "<10" e supressão complementar nos encaixados da mesma linha
mascara <- function(x) ifelse(x >= 1 & x <= 9, "<10", br(x))
tab <- data.frame(Concentração = ev$concentracao, PTB = mascara(ev$ptb), Extremo = mascara(ev$extremo), Muito = mascara(ev$muito), `Moderado-tardio` = mascara(ev$moderado_tardio),
                  `Espontâneo (i)` = mascara(ev$esp_i), `Espontâneo (ii)` = mascara(ev$esp_ii), `§3.5 (i)` = mascara(ev$dum_i), `§3.5 (ii)` = mascara(ev$dum_ii),
                  `Termo precoce, janela` = mascara(ev$termo_janela), `Termo precoce, interseção` = mascara(ev$termo_intersecao), check.names = FALSE, stringsAsFactors = FALSE)
pequeno <- function(d) d >= 1 & d <= 9
n_sc <- 0
for (i in seq_len(nrow(ev))) {
  sub <- c(Extremo = ev$extremo[i], Muito = ev$muito[i], `Moderado-tardio` = ev$moderado_tardio[i]); msk <- pequeno(sub)
  if (sum(msk) == 1) { k <- names(sort(sub[!msk]))[1]; tab[i, k] <- "s.c."; n_sc <- n_sc + 1 }
  for (par in list(c("Espontâneo (ii)", ev$esp_ii[i] - ev$esp_i[i]), c("PTB", ev$ptb[i] - ev$esp_ii[i]), c("§3.5 (i)", ev$ptb[i] - ev$dum_i[i]),
                   c("Termo precoce, janela", ev$termo_janela[i] - ev$termo_intersecao[i])))
    if (pequeno(as.numeric(par[2])) && tab[i, par[1]] != "s.c.") { tab[i, par[1]] <- "s.c."; n_sc <- n_sc + 1 }
}

# listas da regra de < 1.000 (D12, 4.1; A1-98) e a parada do espontâneo (i)
lista <- function(col) ev$concentracao[ev[[col]] < 1000]
listas <- list(extremo = lista("extremo"), muito = lista("muito"), moderado_tardio = lista("moderado_tardio"), dum_i = lista("dum_i"), dum_ii = lista("dum_ii"))
esp_i_baixo <- lista("esp_i")
if (length(esp_i_baixo)) para <- c(para, paste0("PTB espontâneo (i) com < 1.000 eventos em: ", paste(esp_i_baixo, collapse = ", "), " (sem regra registrada; a decisão vem do chat)"))

# ------------------------------------------------------------------ regra_gama (Q8)
ok_sha_q8 <- confere(identical(sha(F_Q8), SHA_Q8), "SHA-256 do RESPOSTA_QUESTIONAMENTO diferente do registrado")
q8l <- readLines(F_Q8, encoding = "UTF-8"); iq <- grep("^## Q8\\.", q8l); fim <- grep("^## Q9\\.", q8l)
lin <- q8l[iq:fim]; lin <- lin[grepl("^\\| (2[2-9]|3[0-9]|4[0-2]) \\|", lin)]
q8 <- setNames(as.numeric(gsub("\\.", "", sub("^\\| [0-9]+ \\| ([0-9.]+) \\|.*", "\\1", lin))), sub("^\\| ([0-9]+) \\|.*", "\\1", lin))
ok_q8 <- confere(identical(names(q8), as.character(22:42)) && sum(q8) == 13791848, "Q8 lida do arquivo incompleta ou com total ≠ 13.791.848")
DES <- list(extremo = list(sem = 22:27, pesos = "gestacao"), muito = list(sem = 28:31, pesos = "gestacao"), moderado_tardio = list(sem = 32:36, pesos = "gestacao"),
            termo_precoce = list(sem = 37:38, pesos = "pessoa_dia"), ptb_referencia = list(sem = 22:36, pesos = "gestacao"))
rg <- do.call(rbind, lapply(names(DES), function(k) { d <- DES[[k]]; ev_k <- sum(q8[as.character(d$sem)])
  ep <- vapply(c("cosseno", "pico"), function(cz) of$regra_gama(q8, d$sem, ev_k, cz, d$pesos)$ep, 0)
  g <- of$decide_gama(q8, d$sem, ev_k, d$pesos)
  data.frame(desfecho = k, semanas = paste(range(d$sem), collapse = "–"), pesos = d$pesos, eventos_q8 = ev_k, ep_cosseno = ep[["cosseno"]], ep_pico = ep[["pico"]],
             gama = if (is.list(g)) g$gama else g, stringsAsFactors = FALSE) }))
ok_ref_ptb <- confere(identical(rg$gama[rg$desfecho == "ptb_referencia"], "estimado") && max(abs(range(unlist(rg[rg$desfecho == "ptb_referencia", c("ep_cosseno", "ep_pico")])) - c(0.07, 0.14)) / c(0.07, 0.14)) <= 0.10,
                      "referência do PTB fora da calibração (EP de 0,07 a 0,14 e γ estimado)")

# ------------------------------------------------------------------ nascimentos(): Q8 recontada, consultas_cat e metapreditores
log_msg("nascimentos()")
n <- as.data.frame(nascimentos(c("CD_MUN6", "data", "ano", "unico", "ga_sem", "pop_ptb", "coorte_fixa_22", "parto", "consultas_cat")))
n$data <- D(n$data); n$recorte_principal <- conc$CD_RECORTE[match(n$CD_MUN6, conc$CD_MUN6)]; stopifnot(!anyNA(n$recorte_principal))
p_ano <- n$ano >= 2012 & n$ano <= 2024
q8_re <- tabulate(n$ga_sem[n$pop_ptb %in% TRUE & n$coorte_fixa_22 %in% TRUE & p_ano] - 21L, nbins = 21)
ok_q8_re <- confere(identical(as.numeric(q8_re), unname(q8)), "Q8 recontada pela interface ≠ Q8 do arquivo")
pd15 <- n$pop_ptb %in% TRUE & n$data >= D("2012-01-01") & n$data <= D("2024-12-31")
ok_pd15 <- confere(identical(pd15, n$unico %in% TRUE & !is.na(n$ga_sem) & n$ga_sem >= 22 & n$ga_sem <= 42 & n$data >= D("2012-01-01") & n$data <= D("2024-12-31")), "população da D15 ≠ definição")
ca <- n$consultas_cat[pd15]; an <- as.integer(format(n$data[pd15], "%Y")); cods <- c("1", "2", "3", "4", "9")
cons <- do.call(rbind, lapply(2012:2024, function(y) { x <- ca[an == y]
  data.frame(ano = y, nv = length(x), c1 = sum(x %in% "1"), c2 = sum(x %in% "2"), c3 = sum(x %in% "3"), c4 = sum(x %in% "4"), c9 = sum(x %in% "9"), vazio = sum(is.na(x)),
             outros = sum(!is.na(x) & !(x %in% cods))) }))
cons$pct_ign <- 100 * (cons$c9 + cons$vazio) / cons$nv; cons$pct_c4_validos <- 100 * cons$c4 / (cons$c1 + cons$c2 + cons$c3 + cons$c4)
crit <- c(a = all(cons$c1 > 0 & cons$c2 > 0 & cons$c3 > 0 & cons$c4 > 0 & cons$outros == 0), b = all(cons$pct_ign <= 10),
          c = all(abs(diff(cons$pct_ign)) <= 5), d = all(abs(diff(cons$pct_c4_validos)) <= 10))
estavel <- all(crit)
if (!estavel) para <- c(para, paste0("consultas_cat instável (critério(s) ", paste(names(crit)[!crit], collapse = ", "), "): cobertura de pré-natal não calculada"))
pr <- n$parto[pd15]; rc <- n$recorte_principal[pd15]
meta <- data.frame(recorte_principal = ordem, concentracao = unname(nome[ordem]), stringsAsFactors = FALSE)
meta$cesarea_num <- vapply(ordem, function(r) sum(rc == r & pr %in% "2"), 0); meta$cesarea_den <- vapply(ordem, function(r) sum(rc == r & pr %in% c("1", "2")), 0)
meta$parto_ignorado <- vapply(ordem, function(r) sum(rc == r & !(pr %in% c("1", "2"))), 0)
meta$prenatal_num <- vapply(ordem, function(r) sum(rc == r & ca %in% "4"), 0); meta$prenatal_den <- vapply(ordem, function(r) sum(rc == r & ca %in% c("1", "2", "3", "4")), 0)
meta$consultas_ignorado <- vapply(ordem, function(r) sum(rc == r & !(ca %in% c("1", "2", "3", "4"))), 0)
meta$pct_cesarea <- 100 * meta$cesarea_num / meta$cesarea_den
meta$pct_prenatal_7mais <- if (estavel) 100 * meta$prenatal_num / meta$prenatal_den else NA_real_
REG <- c("1" = "Norte", "2" = "Nordeste", "3" = "Sudeste", "4" = "Sul", "5" = "Centro-Oeste")
meta$macrorregiao <- unname(REG[substr(nuc$CD_MUN_NUCLEO[match(ordem, nuc$CD_RECORTE)], 1, 1)])
n_reg <- table(factor(meta$macrorregiao, levels = REG))
ok_reg <- confere(identical(as.integer(n_reg), c(2L, 9L, 8L, 3L, 4L)), "macrorregiões ≠ (2, 9, 8, 3, 4) da §6")
rm(n); invisible(gc())

# ------------------------------------------------------------------ gravação e log
ok_conf <- length(falhas) == 0; ok <- ok_conf && length(para) == 0
if (ok_conf) { utils::write.csv(merge(ev, meta, by = c("recorte_principal", "concentracao"), sort = FALSE), f_out[["cont"]], row.names = FALSE); utils::write.csv(cons, f_out[["cons"]], row.names = FALSE) }
sha_out <- vapply(f_out, function(p) if (file.exists(p)) sha(p) else "(não gravado)", "")
stopifnot(versao() == "4443971b"); v_fim <- versao()
conf <- data.frame(Conferência = c("Identidades: extremo + muito + moderado-tardio = PTB; espontâneo (i) + ignorado = (ii); (ii) + iniciado = PTB; §3.5 (i) ≤ PTB; termo na interseção ≤ na janela",
                                   "SHA-256 do `RESPOSTA_QUESTIONAMENTO_20261007.md` = registrado (`16fe31e9…011e`)", "Q8 lida do arquivo: semanas 22–42, total 13.791.848",
                                   "Q8 recontada pela interface (população do principal, nascidos em 2012–2024) = Q8 do arquivo",
                                   "Referência do PTB na calibração (EP de 0,07 a 0,14, ±10%; γ estimado)", "População da D15 = definição explícita", "Macrorregiões = (2, 9, 8, 3, 4), como a §6"),
                   Confere = ifelse(c(ok_part, ok_sha_q8, ok_q8, ok_q8_re, ok_ref_ptb, ok_pd15, ok_reg), "sim", "NÃO"), check.names = FALSE)
lst <- function(v) if (length(v)) paste(v, collapse = ", ") else "nenhuma"
pc <- function(x, d = 1) br(x, d)
md <- c("# Fase 4, Parte B1.5: contagens e insumos dos metapreditores", "",
  sprintf("- **Gerado por:** `00_scripts/68_contagens_insumos_fase4.R` (SHA-256 `%s`), início em %s, fim em %s. Rodada `%s`. `versao()` no início: %s; no fim: %s.",
          sha(file.path(REPO, ESTE)), inicio, format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"), rodada, v_ini, v_fim),
  sprintf("- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `%s` (ramo `%s`); último commit da `COORD` no `HEAD`: `%s`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: %s.",
          head_c, ramo, coord, if (length(st_a1)) paste0("`", paste(st_a1, collapse = "`; `"), "`") else "vazio"),
  sprintf("- **Código (igual ao das tags):** `offset.R` `%s` (`offset-v1.1`); `segunda_etapa.R` `%s` (`segunda_etapa-v1.1`; só a ordem das 26).", sha_cod[["offset"]], sha_cod[["segunda_etapa"]]),
  "- **Entradas (SHA-256):**", sprintf("  - `%s`: `%s`;", f_in, sha_in), "",
  "## Conferências", "", tabela_md(conf), "",
  "## 1. Eventos por concentração", "",
  "- Janela principal (2012-04-14 a 2024-08-06), salvo o termo precoce: na janela dele (2012-04-28 a 2024-11-19) e na interseção (2012-04-28 a 2024-08-06). \"<10\": contagem de 1 a 9; \"s.c.\": supressão complementar. Sem linha de total.",
  sprintf("- Supressões complementares aplicadas: %d.", n_sc), "", tabela_md(tab), "",
  "## 2. Listas da regra de < 1.000 eventos (janela principal)", "",
  tabela_md(data.frame(Desfecho = c("Subtipo extremo (D12, 4.1)", "Subtipo muito (D12, 4.1)", "Subtipo moderado-tardio (D12, 4.1)", "§3.5, versão (i) (A1-98)", "§3.5, versão (ii) (A1-98)"),
                       `Concentrações com < 1.000 (saem da meta-análise desse desfecho)` = c(lst(listas$extremo), lst(listas$muito), lst(listas$moderado_tardio), lst(listas$dum_i), lst(listas$dum_ii)),
                       `Entram` = 26L - lengths(listas), check.names = FALSE)), "",
  sprintf("- **PTB espontâneo (i):** concentrações com < 1.000 eventos: %s.%s", lst(esp_i_baixo), if (length(esp_i_baixo)) " **PARE: não há regra registrada; a decisão vem do chat.**" else ""), "",
  "## 3. Regra única de γ (§3.2; D12, 4.1; A1-89), com a Q8", "",
  tabela_md(data.frame(Desfecho = c(extremo = "Subtipo extremo", muito = "Subtipo muito", moderado_tardio = "Subtipo moderado-tardio", termo_precoce = "Termo precoce (pessoa-dia)", ptb_referencia = "PTB (referência da calibração)")[rg$desfecho],
                       Semanas = rg$semanas, Pesos = ifelse(rg$pesos == "gestacao", "por gestação", "por pessoa-dia"), `Eventos (Q8)` = br(rg$eventos_q8),
                       `EP, cosseno` = br(rg$ep_cosseno, 3), `EP, pico` = br(rg$ep_pico, 3), γ = ifelse(rg$gama == "1", "γ = 1", "estimado"), check.names = FALSE)), "",
  "- γ = 1 quando o EP aproximado é ≥ 1 em algum dos dois cenários; senão, γ estimado (`decide_gama` do offset v1.1).", "",
  "## 4. `consultas_cat` por ano (população da D15)", "",
  tabela_md(data.frame(Ano = cons$ano, NV = br(cons$nv), `1 (nenhuma), %` = pc(100 * cons$c1 / cons$nv, 2), `2 (1–3), %` = pc(100 * cons$c2 / cons$nv, 2), `3 (4–6), %` = pc(100 * cons$c3 / cons$nv, 2),
                       `4 (7 ou mais), %` = pc(100 * cons$c4 / cons$nv, 2), `9 ou vazio, %` = pc(cons$pct_ign, 2), `Código fora de {1, 2, 3, 4, 9}` = mascara(cons$outros),
                       `4 entre os válidos, %` = pc(cons$pct_c4_validos, 2), check.names = FALSE)), "",
  tabela_md(data.frame(Critério = c("(a) códigos 1–4 presentes em todo ano; nenhum fora de {1, 2, 3, 4, 9}", "(b) ignorado ≤ 10% em todo ano", "(c) variação do % de ignorado entre anos ≤ 5 pontos",
                                    "(d) variação do % do código 4 entre os válidos ≤ 10 pontos"), Atende = ifelse(crit, "sim", "NÃO"), check.names = FALSE)), "",
  sprintf("- **Resultado:** %s.", if (estavel) "códigos e completude estáveis; a cobertura de pré-natal é calculada" else "**instável: PARE (a cobertura de pré-natal não é calculada)**"), "",
  "## 5. Insumos dos metapreditores (D15; população da D15, um valor por concentração)", "",
  tabela_md(data.frame(Concentração = meta$concentracao, `% cesárea` = pc(meta$pct_cesarea), `Parto ignorado` = mascara(meta$parto_ignorado),
                       `% com 7 ou mais consultas` = if (estavel) pc(meta$pct_prenatal_7mais) else "—", `Consultas ignoradas` = mascara(meta$consultas_ignorado), Macrorregião = meta$macrorregiao, check.names = FALSE)), "",
  sprintf("- **Macrorregiões:** %s.", paste(sprintf("%s %d", names(n_reg), as.integer(n_reg)), collapse = "; ")), "",
  "## 6. IDHM 2010: não baixado (PARE do item B1.5)", "",
  "- O site do Atlas (`www.atlasbrasil.org.br`) não tem arquivo estático da tabela municipal do IDHM 2010: o caminho antigo dos dados brutos (`/2013/data/rawData/atlas2013_dadosbrutos_pt.xlsx`) dá 404 no `www`; o domínio sem `www` responde com certificado autoassinado (não contornado); a tabela só sai pela ferramenta de consulta (`/consulta/planilha`), que monta a planilha por POST à API do próprio site (`/api/dadosgridDowload`) depois de escolher indicadores e territórios, ou seja, um formulário.",
  "- Pela mensagem (\"se o download exigir conta, formulário ou outro domínio, PARE e informe\"), nada foi baixado. O IDHM só entra na meta-regressão exploratória da C4 e não bloqueia a C1. Decisão para Guilherme e o chat.", "",
  "## Saídas (fora do git; contagens sem máscara, só para uso interno)", "", sprintf("- `%s`: `%s`;", f_out, sha_out), "",
  sprintf("- **Resultado:** %s. Tempo: %.0f s.",
          if (!ok_conf) paste("FALHA: PARE —", paste(falhas, collapse = "; ")) else if (length(para)) paste("PARE —", paste(para, collapse = "; ")) else "todas as conferências passam; nenhuma parada",
          as.numeric(difftime(Sys.time(), t0, units = "secs"))), "")
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "|", if (ok) "ok" else paste("PARE/FALHA:", paste(c(falhas, para), collapse = "; ")), "\n")
if (!ok) quit(status = 1)
