# 07b — Classificação do PIG em três curvas (E8; adendo v1.2, D5). Regras: logs/desvios_especificacao.md (05/10/2026).
#
# Rodar a partir da RAIZ da base (dados_artigos_perinatais_clima):
#   Rscript 07_pig_referencia/07b_pig_classificacao.R              # 06_processados/ e logs/
#   Rscript 07_pig_referencia/07b_pig_classificacao.R --rascunho   # _tmp/rascunho_07/ (teste, dentro da Forja)
#
# Entradas: 06_processados/nascimentos.parquet (06b); 07_pig_referencia/oms_kiserud2017_p10.csv e
#           pedreira2011_p10.csv (07a, com dupla leitura).
# Saída:    pig_classificacao.parquet: 1 linha por NV único de 24–42 semanas com peso válido (chave id_nasc).
#   pop_pig_principal  único, 37–42, sexo conhecido, coorte_fixa_37, |z| <= 5
#   pig_sens_pretermo  único, 24–36, sexo conhecido, |z| <= 5 (coorte e período ficam para o artigo)
#   ig21_ref_nao_verificada  IG < 33 (referência de muito pré-termo do INTERGROWTH; E8: "não verificado")
#   ig21_z, ig21_z_extremo   escore z de peso INTERGROWTH-21st com 7 × IG + 3 dias; extremo = |z| > 5
#   pig_ig21 (< p10, 7 × IG + 3), pig_ig21_p3 (< p3), pig_ig21_g0 (7 × IG), pig_ig21_g6 (7 × IG + 6)
#   pig_pedreira  peso < p10 de Pedreira 2011 (sexo, semana completa; a tabela é por semana completa)
#   pig_oms       peso < p10 da OMS/Kiserud 2017 por sexo (Tabelas 14 e 15) na semana inteira (= semana exata
#                 da curva); NA em 41–42 semanas
#   pig_oms_meio_semana  idem, com o p10 interpolado (linear) em 7 × IG + 3 dias, como o INTERGROWTH; NA de 40 em
#                 diante, porque a curva termina em 40+0 (auditoria do 07, A2)
#   pig_oms_sem_sexo  como pig_oms, Tabela 11 (sem sexo)
# Logs agregados (26 concentrações × ano): pig_resumo_ano.csv e pig_concordancia.csv. Uma linha com qualquer
# contagem entre 1 e 9, publicada ou dedutível por subtração dentro dela, sai inteira em branco (suprimido =
# TRUE); assim nenhuma contagem < 10 é recuperável (auditoria do 07, A1).

suppressPackageStartupMessages({ library(arrow); library(dplyr); library(gigs) })

IG_MIN <- 24L; IG_MAX <- 42L; TERMO <- 37L; IG_NAO_VERIF <- 33L; Z_MAX <- 5
Z_P10 <- qnorm(0.10); Z_P3 <- qnorm(0.03)
CURVAS <- c("pig_ig21", "pig_ig21_p3", "pig_ig21_g0", "pig_ig21_g6", "pig_pedreira", "pig_oms", "pig_oms_meio_semana",
            "pig_oms_sem_sexo")
PARES <- list(c("pig_ig21", "pig_pedreira"), c("pig_ig21", "pig_oms"), c("pig_pedreira", "pig_oms"),
              c("pig_oms", "pig_oms_sem_sexo"), c("pig_oms", "pig_oms_meio_semana"))
SEXO_VALIDO <- c("0", "1", "2", "9")

sexo_ig <- function(sexo) ifelse(sexo %in% "1", "M", ifelse(sexo %in% "2", "F", NA_character_))

conferir_referencia <- function(ref, semanas, sexos, nome) {
  esperado <- expand.grid(semana = semanas, sexo = sexos, stringsAsFactors = FALSE)
  chave <- paste(ref$semana, ref$sexo)
  if (anyDuplicated(chave) || !all(paste(esperado$semana, esperado$sexo) %in% chave))
    stop(nome, ": falta par (semana, sexo) ou há par repetido")
  r <- ref[paste(ref$semana, ref$sexo) %in% paste(esperado$semana, esperado$sexo), ]
  if (any(!is.finite(r$p10_g)) || any(r$p10_g <= 0)) stop(nome, ": p10 vazio ou não positivo")
  for (s in sexos) if (any(diff(r$p10_g[r$sexo == s][order(r$semana[r$sexo == s])]) <= 0))
    stop(nome, ": p10 não cresce com a semana (sexo ", s, ")")
  invisible(TRUE)
}

z_ig21 <- function(peso_g, dias, sx) {
  z <- rep(NA_real_, length(peso_g))
  ok <- !is.na(sx) & !is.na(peso_g) & !is.na(dias)
  if (any(ok)) z[ok] <- suppressWarnings(suppressMessages(
    gigs::value2zscore(peso_g[ok] / 1000, dias[ok], sx[ok], family = "ig_nbs", acronym = "wfga")))
  z
}

p10_de <- function(ref, ga, sx) ref$p10_g[match(paste(ga, sx), paste(ref$semana, ref$sexo))]

p10_meio_semana <- function(ref, ga, sx) {
  a <- p10_de(ref, ga, sx); b <- p10_de(ref, ga + 1L, sx)
  a + (3 / 7) * (b - a)          # NA quando falta a semana seguinte (40 em diante na OMS)
}

abaixo <- function(peso, lim) ifelse(is.na(lim) | is.na(peso), NA, peso < lim)

classificar <- function(nasc, oms, pedreira) {
  fora <- setdiff(unique(nasc$sexo[!is.na(nasc$sexo)]), SEXO_VALIDO)
  if (length(fora)) stop("sexo com código fora de {0, 1, 2, 9}: ", paste(head(fora, 5), collapse = ", "))
  b <- nasc[nasc$unico %in% TRUE & !is.na(nasc$ga_sem) & nasc$ga_sem >= IG_MIN & nasc$ga_sem <= IG_MAX &
              !is.na(nasc$peso_g), ]
  sx <- sexo_ig(b$sexo); ga <- as.integer(b$ga_sem); peso <- as.numeric(b$peso_g)
  z3 <- z_ig21(peso, 7L * ga + 3L, sx)
  z0 <- z_ig21(peso, 7L * ga, sx)
  z6 <- z_ig21(peso, 7L * ga + 6L, sx)
  extremo <- !is.na(z3) & abs(z3) > Z_MAX
  elegivel <- !is.na(sx) & !is.na(z3) & !extremo
  oms_sx <- oms[oms$sexo %in% c("F", "M"), ]
  amb <- rep("ambos", length(ga))
  lim_ped <- if (is.null(pedreira)) rep(NA_real_, length(ga)) else p10_de(pedreira, ga, sx)
  data.frame(
    id_nasc = b$id_nasc, ano = b$ano,
    pop_pig_principal = elegivel & ga >= TERMO & b$coorte_fixa_37 %in% TRUE,
    pig_sens_pretermo = elegivel & ga < TERMO,
    ig21_ref_nao_verificada = ga < IG_NAO_VERIF,
    ig21_z = z3, ig21_z_extremo = extremo,
    pig_ig21 = z3 < Z_P10, pig_ig21_p3 = z3 < Z_P3, pig_ig21_g0 = z0 < Z_P10, pig_ig21_g6 = z6 < Z_P10,
    pig_pedreira = abaixo(peso, lim_ped), pig_oms = abaixo(peso, p10_de(oms_sx, ga, sx)),
    pig_oms_meio_semana = abaixo(peso, p10_meio_semana(oms_sx, ga, sx)),
    pig_oms_sem_sexo = abaixo(peso, p10_de(oms[oms$sexo == "ambos", ], ga, amb)),
    .sexo_ignorado = is.na(sx), .termo_coorte = ga >= TERMO & b$coorte_fixa_37 %in% TRUE, .ga = ga
  )
}

pequeno <- function(n) any(n > 0 & n < 10, na.rm = TRUE)
fmt <- function(n) format(n, scientific = FALSE, trim = TRUE, big.mark = "")
mascara <- function(n) ifelse(is.na(n), "", ifelse(n > 0 & n < 10, "<10", fmt(n)))

linha_resumo <- function(x, pop, a, base = NULL) {
  # contagens publicadas e as que se deduzem por subtração dentro da linha (sensíveis também)
  cont <- c(n = nrow(x))
  cel <- list(populacao = pop, ano = a)
  if (!is.null(base)) {
    n_t <- nrow(base); n_s <- sum(base$.sexo_ignorado); n_z <- sum(base$ig21_z_extremo)
    cont <- c(cont, n_termo = n_t, sexo = n_s, z = n_z, resto = n_t - nrow(x) - n_s - n_z,
              oms_na = sum(x$.ga >= 41L))
  }
  for (cv in CURVAS) {
    n_cl <- sum(!is.na(x[[cv]])); n_pig <- sum(x[[cv]] %in% TRUE)
    cont <- c(cont, setNames(c(n_cl, n_pig, n_cl - n_pig, nrow(x) - n_cl), paste0(cv, c("_cl", "_pig", "_nao", "_na"))))
  }
  sup <- pequeno(cont)
  cel$suprimido <- sup
  if (!is.null(base)) {
    cel$n_termo_coorte37 <- if (sup) "" else fmt(cont[["n_termo"]])
    cel$n_sexo_ignorado <- if (sup) "" else fmt(cont[["sexo"]])
    cel$n_z_extremo <- if (sup) "" else fmt(cont[["z"]])
    cel$n_oms_na_41_42 <- if (sup) "" else fmt(cont[["oms_na"]])
  }
  cel$n <- if (sup) "" else fmt(cont[["n"]])
  for (cv in CURVAS) {
    cel[[paste0(cv, "_n_classificados")]] <- if (sup) "" else fmt(cont[[paste0(cv, "_cl")]])
    cel[[paste0(cv, "_pct")]] <- if (sup || cont[[paste0(cv, "_cl")]] == 0) "" else
      sprintf("%.2f", 100 * cont[[paste0(cv, "_pig")]] / cont[[paste0(cv, "_cl")]])
  }
  as.data.frame(cel, stringsAsFactors = FALSE)
}

resumo_ano <- function(cls) {
  linhas <- list()
  for (a in sort(unique(cls$ano[cls$pop_pig_principal])))
    linhas[[length(linhas) + 1]] <- linha_resumo(cls[cls$pop_pig_principal & cls$ano == a, ], "pop_pig_principal", a,
                                                 base = cls[cls$.termo_coorte & cls$ano == a, ])
  for (a in sort(unique(cls$ano[cls$pig_sens_pretermo])))
    linhas[[length(linhas) + 1]] <- linha_resumo(cls[cls$pig_sens_pretermo & cls$ano == a, ], "pig_sens_pretermo", a)
  bind_rows(linhas)
}

kappa_txt <- function(n) {
  tot <- sum(n); if (tot == 0) return(c("", ""))
  po <- (n[["ss"]] + n[["nn"]]) / tot
  pe <- ((n[["ss"]] + n[["sn"]]) * (n[["ss"]] + n[["ns"]]) + (n[["ns"]] + n[["nn"]]) * (n[["sn"]] + n[["nn"]])) / tot^2
  c(sprintf("%.2f", 100 * po), if (1 - pe > 0) sprintf("%.4f", (po - pe) / (1 - pe)) else "")
}

concordancia <- function(cls) {
  d <- cls[cls$pop_pig_principal, ]
  linhas <- list()
  for (p in PARES) {
    sup_algum <- FALSE; tot <- c(ss = 0, sn = 0, ns = 0, nn = 0)
    for (a in sort(unique(d$ano))) {
      x <- d[d$ano == a, ]
      ok <- !is.na(x[[p[1]]]) & !is.na(x[[p[2]]])
      u <- x[[p[1]]][ok]; v <- x[[p[2]]][ok]
      n <- as.numeric(c(ss = sum(u & v), sn = sum(u & !v), ns = sum(!u & v), nn = sum(!u & !v)))   # double: o produto estoura inteiro
      names(n) <- c("ss", "sn", "ns", "nn")
      tot <- tot + n
      sup <- pequeno(c(n, sum(n), nrow(x) - sum(n)))      # inclui os excluídos por NA, dedutíveis de pig_resumo_ano
      sup_algum <- sup_algum || sup
      k <- kappa_txt(n)
      linhas[[length(linhas) + 1]] <- data.frame(curva_a = p[1], curva_b = p[2], ano = as.character(a), suprimido = sup,
        n = if (sup) "" else fmt(sum(n)), n_pig_ambas = if (sup) "" else fmt(n[["ss"]]),
        n_pig_so_a = if (sup) "" else fmt(n[["sn"]]), n_pig_so_b = if (sup) "" else fmt(n[["ns"]]),
        n_nenhuma = if (sup) "" else fmt(n[["nn"]]), concordancia_pct = if (sup) "" else k[1],
        kappa = if (sup) "" else k[2], stringsAsFactors = FALSE)
    }
    k <- kappa_txt(tot)    # 2012–2024: só as medidas, sem contagens (que seriam a soma dos anos)
    linhas[[length(linhas) + 1]] <- data.frame(curva_a = p[1], curva_b = p[2], ano = "2012-2024", suprimido = sup_algum,
      n = "", n_pig_ambas = "", n_pig_so_a = "", n_pig_so_b = "", n_nenhuma = "",
      concordancia_pct = if (sup_algum) "" else k[1], kappa = if (sup_algum) "" else k[2], stringsAsFactors = FALSE)
  }
  bind_rows(linhas)
}

registrar_integridade <- function(raiz, arquivo, n_linhas, obs) {
  csv <- file.path(raiz, "logs", "integridade.csv")
  agora <- sub("(\\d{2})(\\d{2})$", "\\1:\\2", format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"))
  lin <- data.frame(data_hora = agora, sistema = "PIG", ano = "2011-2024", uf = "concentracoes", arquivo = basename(arquivo),
                    status = "derivado", url = "", bytes = "", md5_origem = "", md5_parquet = unname(tools::md5sum(arquivo)),
                    n_linhas = n_linhas, n_colunas = "", n_municipios = "", pct_mun_invalido = "", observacao = obs)
  write.table(lin, csv, sep = ",", append = TRUE, col.names = !file.exists(csv), row.names = FALSE, qmethod = "double")
}

registrar_proveniencia <- function(raiz, saidas, insumos, script) {
  # mesmo formato do utils.registrar_proveniencia (Python): uma linha por saída × insumo, só acréscimo
  csv <- file.path(raiz, "logs", "proveniencia.csv")
  agora <- sub("(\\d{2})(\\d{2})$", "\\1:\\2", format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"))
  m_ins <- unname(tools::md5sum(file.path(raiz, insumos)))
  if (anyNA(m_ins)) stop("insumo ausente na proveniência: ", paste(insumos[is.na(m_ins)], collapse = ", "))
  rel <- function(s) substr(s, nchar(raiz) + 2L, nchar(s))
  execucao <- paste0(basename(script), "@", agora, "#", Sys.getpid(), "-", format(as.numeric(Sys.time()) * 1e6, scientific = FALSE))
  linhas <- do.call(rbind, lapply(saidas, function(s) data.frame(
    data_hora = agora, execucao = execucao, saida = rel(s),
    md5_saida = unname(tools::md5sum(s)), insumo = insumos, md5_insumo = m_ins, stringsAsFactors = FALSE)))
  write.table(linhas, csv, sep = ",", append = TRUE, col.names = !file.exists(csv), row.names = FALSE, qmethod = "double")
}

main <- function(args = commandArgs(trailingOnly = TRUE), raiz = getwd()) {
  stopifnot("Rode a partir da raiz da base (pasta com 06_processados/)" = dir.exists(file.path(raiz, "06_processados")))
  rascunho <- "--rascunho" %in% args
  destino <- if (rascunho) file.path(raiz, "_tmp", "rascunho_07") else file.path(raiz, "06_processados")
  logs <- if (rascunho) destino else file.path(raiz, "logs")
  dir.create(destino, showWarnings = FALSE, recursive = TRUE)
  arq_log <- file.path(logs, paste0("07b_pig_classificacao_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".log"))
  log_msg <- function(...) {
    m <- paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " | ", paste0(...))
    message(m); cat(m, "\n", file = arq_log, append = TRUE, sep = "")
  }
  log_msg("ROOT = ", raiz, if (rascunho) " (rascunho)" else "")
  log_msg("gigs ", as.character(packageVersion("gigs")), " (", packageDescription("gigs")$RemoteSha, "); ", R.version.string)
  writeLines(capture.output(sessionInfo()), file.path(logs, paste0("sessionInfo_07b_", format(Sys.Date(), "%Y%m%d"), ".txt")))

  ref <- file.path(raiz, "07_pig_referencia")
  cc_ref <- c(semana = "integer", sexo = "character", p10_g = "numeric")
  oms <- read.csv(file.path(ref, "oms_kiserud2017_p10.csv"), colClasses = cc_ref)
  conferir_referencia(oms, 14:40, c("F", "M", "ambos"), "oms_kiserud2017_p10.csv")
  arq_ped <- file.path(ref, "pedreira2011_p10.csv")
  pedreira <- NULL
  if (file.exists(arq_ped)) {
    pedreira <- read.csv(arq_ped, colClasses = cc_ref)
    conferir_referencia(pedreira, IG_MIN:IG_MAX, c("F", "M"), "pedreira2011_p10.csv")
  } else if (rascunho) {
    log_msg("AVISO: pedreira2011_p10.csv ausente; no rascunho, pig_pedreira fica NA")
  } else {
    stop("pedreira2011_p10.csv ausente (rode o 07a com o PDF de Pedreira 2011 em originais/)")
  }

  nasc <- as.data.frame(read_parquet(file.path(raiz, "06_processados", "nascimentos.parquet"),
    col_select = c("id_nasc", "ano", "ga_sem", "peso_g", "sexo", "unico", "coorte_fixa_37")))
  log_msg("nascimentos lidos: ", mascara(nrow(nasc)))
  cls <- classificar(nasc, oms, pedreira)
  if (anyDuplicated(cls$id_nasc)) stop("id_nasc duplicado na classificação")
  log_msg("classificados (únicos, 24–42 semanas, peso válido): ", mascara(nrow(cls)), " | população principal: ",
          mascara(sum(cls$pop_pig_principal)), " | pré-termo (sensibilidade): ", mascara(sum(cls$pig_sens_pretermo)),
          " | |z| > 5: ", mascara(sum(cls$ig21_z_extremo)), " | sexo ignorado: ", mascara(sum(cls$.sexo_ignorado)))

  # tudo calculado antes; grava em .part e só então renomeia (auditoria do 07, A6)
  ra <- resumo_ano(cls); cc <- concordancia(cls)
  saidas <- c(parquet = file.path(destino, "pig_classificacao.parquet"),
              resumo = file.path(logs, "pig_resumo_ano.csv"), conc = file.path(logs, "pig_concordancia.csv"))
  write_parquet(cls[, !(names(cls) %in% c("ano", ".sexo_ignorado", ".termo_coorte", ".ga"))],
                paste0(saidas[["parquet"]], ".part"), compression = "zstd")
  write.csv(ra, paste0(saidas[["resumo"]], ".part"), row.names = FALSE, na = "")
  write.csv(cc, paste0(saidas[["conc"]], ".part"), row.names = FALSE, na = "")
  for (f in saidas) if (!file.rename(paste0(f, ".part"), f) || !file.exists(f) || file.size(f) == 0) stop("falha ao gravar ", f)
  pp <- cls[cls$pop_pig_principal, ]
  log_msg("% PIG na população principal (2012–2024): ",
          paste(sprintf("%s %.2f", CURVAS, sapply(CURVAS, function(cv) 100 * mean(pp[[cv]], na.rm = TRUE))), collapse = "; "))
  log_msg("linhas suprimidas (alguma contagem 1–9): resumo ", sum(ra$suprimido), " de ", nrow(ra),
          "; concordância ", sum(cc$suprimido), " de ", nrow(cc))
  if (!rascunho) {
    registrar_integridade(raiz, saidas[["parquet"]], nrow(cls), "07b; microdado individual (id_nasc); E8 tres curvas")
    registrar_proveniencia(raiz, unname(saidas),
                           c("06_processados/nascimentos.parquet", "07_pig_referencia/oms_kiserud2017_p10.csv",
                             "07_pig_referencia/pedreira2011_p10.csv", "07_pig_referencia/07b_pig_classificacao.R"),
                           "07b_pig_classificacao.R")
  }
  log_msg("FIM 07b (", if (rascunho) "rascunho" else "projeto", ")")
  invisible(cls)
}

if (sys.nframe() == 0L) main()
