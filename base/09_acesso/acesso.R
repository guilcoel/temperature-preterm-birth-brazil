# Interface de acesso à base dados_artigos_perinatais_clima (R). Par exato de acesso.py: mesmos nomes e
# mesmos resultados. Lê os arquivos pelo manifesto (09_acesso/manifesto.json, gerado pelo 00_scripts/08_manifesto.py)
# e confere o md5 de cada um na primeira leitura da sessão.
#
# SIGILO (LGPD; regras na raiz da Forja e no CLAUDE.md do projeto):
# - "microdado" (nascimentos, obitos, pig): uma linha por pessoa. Nunca exibir linha, nem copiar para fora da Forja.
# - "restrito" (séries por município/concentração × dia, gestações em risco): só sair agregado recorte × ano (ou
#   mais grosso), com contagem < 10 como "<10". Nada de município × dia na tela.
# - "publico": clima, referências e logs agregados.
#
# Uso:
#   source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R")
#   versao()                                # identificador da versão da base (citar no artigo)
#   s <- serie_diaria("recorte")            # concentração × dia, com coorte fixa, contagens + exposições
#   m <- expo_semanal("tmean", "nucleo")    # matriz s01..s37 gravada pelo 06c
#   m2 <- matriz_semanal("pm25_zero_na", "rm_nv")   # qualquer variável diária, mesmo cálculo do 06c
#   n <- ligar_expo_semanal(nascimentos(c("id_nasc", "CD_MUN6", "data", "ga_sem")), "tmean", "nucleo")
#
# Raiz: variável de ambiente DADOS_PERINATAIS_CLIMA_RAIZ ou /Volumes/Forja/Doc/dados_artigos_perinatais_clima.
# Requer arrow e jsonlite.

suppressPackageStartupMessages({ library(arrow); library(jsonlite) })

.acesso <- new.env()
.acesso$conferidos <- character(0)
.acesso$avisados <- character(0)
.acesso$manifesto <- NULL
RAIZ_PADRAO <- "/Volumes/Forja/Doc/dados_artigos_perinatais_clima"
CLIMA_INI <- as.Date("2010-01-01"); CLIMA_FIM <- as.Date("2025-01-31")
S_INI <- as.Date("2010-01-01"); S_FIM <- as.Date("2024-12-31")
N_SEM <- 37L
VAR_CLIMA <- c(tmax = "tmax", tmin = "tmin", tmean = "tmean", rh = "rh_mean", pr = "pr")
VAR_PM25 <- c("pm25", "pm25_zero_na", "pm25_local", "pm25_local_zero_na")

raiz <- function() {
  r <- Sys.getenv("DADOS_PERINATAIS_CLIMA_RAIZ", RAIZ_PADRAO)
  if (!file.exists(file.path(r, "09_acesso", "manifesto.json")))
    stop("base não encontrada em ", r, " (o volume Forja está montado?)")
  r
}

manifesto <- function() {
  if (is.null(.acesso$manifesto))
    .acesso$manifesto <- fromJSON(file.path(raiz(), "09_acesso", "manifesto.json"), simplifyVector = FALSE)
  .acesso$manifesto
}

versao <- function() manifesto()$versao

.entrada <- function(caminho) {
  for (a in manifesto()$arquivos) if (identical(a$caminho, caminho)) return(a)
  stop(caminho, " não está no manifesto")
}

verificar <- function(caminhos = NULL, parar = TRUE) {
  # TRUE/FALSE por caminho; arquivo ausente = FALSE. Com parar = TRUE, lista todos os que falharam.
  if (is.null(caminhos)) caminhos <- vapply(manifesto()$arquivos, `[[`, "", "caminho")
  res <- vapply(caminhos, function(c) {
    e <- .entrada(c)                     # caminho fora do manifesto: erro, não "ausente"
    m <- unname(tools::md5sum(file.path(raiz(), c)))
    !is.na(m) && m == e$md5
  }, logical(1))
  .acesso$conferidos <- union(.acesso$conferidos, caminhos[res])
  if (parar && !all(res)) stop("md5 difere do manifesto ou arquivo ausente (versão ", versao(), "): ",
                               paste(caminhos[!res], collapse = ", "))
  res
}

ler <- function(caminho, colunas = NULL, conferir = TRUE) {
  e <- .entrada(caminho)
  if (conferir && !(caminho %in% .acesso$conferidos)) verificar(caminho)
  if (e$sigilo != "publico" && !(caminho %in% .acesso$avisados)) {
    cat("AVISO DE SIGILO: ", caminho, ": '", e$sigilo, "'. Não exibir linhas; só agregados recorte × ano, com < 10 como '<10'.\n",
        sep = "", file = stderr())        # stderr: suppressMessages/suppressWarnings não o escondem
    .acesso$avisados <- c(.acesso$avisados, caminho)
  }
  p <- file.path(raiz(), caminho)
  if (grepl("\\.parquet$", p)) {
    return(as.data.frame(if (is.null(colunas)) read_parquet(p) else read_parquet(p, col_select = dplyr::all_of(colunas))))
  }
  d <- read.csv(p, colClasses = "character", check.names = FALSE, na.strings = "")   # vazio = NA, como no Python
  if (is.null(colunas)) d else d[, colunas, drop = FALSE]
}

# ---------------------------------------------------------------------------- tabelas
nascimentos <- function(colunas = NULL) ler("06_processados/nascimentos.parquet", colunas)
obitos <- function(colunas = NULL) ler("06_processados/obitos_perinatais.parquet", colunas)

pig <- function(colunas = NULL, com_nascimentos = NULL) {
  # mantém a ordem das linhas do pig_classificacao; as colunas do nascimentos vão para o fim (como no Python)
  p <- ler("06_processados/pig_classificacao.parquet", colunas)
  extra <- setdiff(com_nascimentos, "id_nasc")
  if (length(extra)) {
    n <- nascimentos(c("id_nasc", extra))
    i <- match(p$id_nasc, n$id_nasc)
    for (c in extra) p[[c]] <- n[[c]][i]
  }
  p
}

serie_diaria <- function(nivel = "recorte", coorte_fixa = TRUE, colunas = NULL) {
  nome <- c(recorte = "serie_diaria_recorte", municipio = "serie_diaria_municipio_clima")[[nivel]]
  ler(paste0("06_processados/", nome, if (coorte_fixa) "" else "_sem_coorte_fixa", ".parquet"), colunas)
}

gestacoes_em_risco <- function(nivel = "recorte")
  ler(c(recorte = "06_processados/gestacoes_em_risco_recorte.parquet", municipio = "06_processados/gestacoes_em_risco.parquet")[[nivel]])

clima_municipal <- function(colunas = NULL) ler("06_processados/clima_municipio_diario_2010_2025.parquet", colunas)
pm25_municipal <- function(colunas = NULL) ler("06_processados/pm25_municipio_diario_2010_2025.parquet", colunas)
calendario <- function() ler("06_processados/calendario_2010_2025.parquet")
concentracoes <- function() ler("04_regioes_metropolitanas/concentracoes_urbanas_municipios.csv")
cidade_nucleo <- function() ler("04_regioes_metropolitanas/cidade_nucleo.csv")
referencias_pig <- function() list(oms = ler("07_pig_referencia/oms_kiserud2017_p10.csv"),
                                   pedreira = ler("07_pig_referencia/pedreira2011_p10.csv"))
expo_semanal <- function(var, versao_expo) ler(paste0("06_processados/expo_semanal_", var, "_", versao_expo, ".parquet"))

# ---------------------------------------------------------------------------- matriz semanal de qualquer variável
.diaria_municipal <- function(var) {
  if (var %in% names(VAR_CLIMA)) {
    d <- clima_municipal(c("CD_MUN6", "data", VAR_CLIMA[[var]]))
  } else if (var %in% VAR_PM25) {
    d <- pm25_municipal(c("CD_MUN6", "data", var))
  } else stop("variável ", var, ": use uma de ", paste(c(names(VAR_CLIMA), VAR_PM25), collapse = ", "))
  names(d)[3] <- "x"
  d$x[is.nan(d$x)] <- NA
  d
}

pesos_rm_nv <- function() {
  n <- nascimentos("CD_MUN6")
  t <- table(n$CD_MUN6)
  data.frame(CD_MUN6 = names(t), w = as.numeric(t), stringsAsFactors = FALSE)
}

diaria_recorte <- function(var, versao_expo) {
  d <- .diaria_municipal(var)
  mun <- concentracoes()[, c("CD_MUN6", "CD_RECORTE")]
  names(mun)[2] <- "recorte_principal"
  if (versao_expo == "nucleo") {
    nuc <- cidade_nucleo()
    nuc <- data.frame(recorte_principal = nuc$CD_RECORTE, CD_MUN6 = substr(nuc$CD_MUN_NUCLEO, 1, 6), stringsAsFactors = FALSE)
    m <- merge(nuc, d, by = "CD_MUN6")
    return(m[, c("recorte_principal", "data", "x")])
  }
  if (versao_expo != "rm_nv") stop("versao_expo: 'nucleo' ou 'rm_nv'")
  m <- merge(merge(d, mun, by = "CD_MUN6"), pesos_rm_nv(), by = "CD_MUN6")
  ok <- !is.na(m$x)
  num <- tapply(ifelse(ok, m$x * m$w, 0), list(m$recorte_principal, as.character(m$data)), sum)
  den <- tapply(ifelse(ok, m$w, 0), list(m$recorte_principal, as.character(m$data)), sum)
  v <- ifelse(den > 0, num / den, NA_real_)
  data.frame(recorte_principal = rep(rownames(v), times = ncol(v)), data = as.Date(rep(colnames(v), each = nrow(v))),
             x = as.vector(v), stringsAsFactors = FALSE)
}

.medias_semanais <- function(x) {
  # x: unidades × dias (dia 1 = CLIMA_INI). m7[, d] = média dos dias d..d+6 (NA se faltar algum)
  nd <- ncol(x); n7 <- nd - 6L
  soma <- x[, 1:n7, drop = FALSE]
  for (j in 1:6) soma <- soma + x[, (1 + j):(n7 + j), drop = FALSE]
  m7 <- soma / 7
  n_s <- as.integer(S_FIM - S_INI) + 1L
  i0 <- as.integer(S_INI - CLIMA_INI)
  idx <- i0 + outer(0:(n_s - 1L), 7L * (0:(N_SEM - 1L)), "+") + 1L     # n_s × 37, 1-indexado
  ok <- idx <= n7
  lapply(seq_len(nrow(x)), function(u) { r <- matrix(NA_real_, n_s, N_SEM); r[ok] <- m7[u, idx[ok]]; r })
}

matriz_semanal <- function(var, versao_expo) {
  if (versao_expo == "mun") { chave <- "CD_MUN6"; d <- .diaria_municipal(var) }
  else { chave <- "recorte_principal"; d <- diaria_recorte(var, versao_expo) }
  d <- d[order(d[[chave]], d$data), ]
  unid <- unique(d[[chave]])
  n_dias <- as.integer(CLIMA_FIM - CLIMA_INI) + 1L
  if (nrow(d) != length(unid) * n_dias || !all(d$data == rep(seq(CLIMA_INI, CLIMA_FIM, by = "day"), length(unid))))
    stop("série diária incompleta")
  x <- matrix(d$x, nrow = length(unid), byrow = TRUE)
  arr <- .medias_semanais(x)
  n_s <- as.integer(S_FIM - S_INI) + 1L
  out <- data.frame(rep(unid, each = n_s), rep(seq(S_INI, S_FIM, by = "day"), length(unid)), stringsAsFactors = FALSE)
  names(out) <- c(chave, "dum_est")
  vals <- do.call(rbind, arr)
  colnames(vals) <- sprintf("s%02d", 1:N_SEM)
  cbind(out, as.data.frame(vals))
}

ligar_expo_semanal <- function(nasc, var, versao_expo, ajuste_dias = 3L, matriz = NULL) {
  # dum = data − (7 × ga_sem + ajuste_dias) (3 = principal; 0 e 6 = sensibilidades do E8). nasc: CD_MUN6, data, ga_sem.
  # Devolve as linhas de nasc NA MESMA ORDEM, com dum_est (e recorte_principal) e s01..s37 no fim, como no Python.
  # A matriz não corta no parto: para pré-termo, ponha NA nas semanas k > IG.
  if (is.null(matriz)) matriz <- if (var %in% c("tmean", "rh", "pm25")) expo_semanal(var, versao_expo) else matriz_semanal(var, versao_expo)
  nasc$dum_est <- as.Date(nasc$data) - (7L * as.integer(nasc$ga_sem) + as.integer(ajuste_dias))
  if (versao_expo == "mun") {
    chave <- "CD_MUN6"
  } else {
    chave <- "recorte_principal"
    mun <- concentracoes()
    nasc$recorte_principal <- mun$CD_RECORTE[match(nasc$CD_MUN6, mun$CD_MUN6)]
  }
  if (!all(c(chave, "dum_est") %in% names(matriz))) stop("matriz sem as colunas ", chave, " e dum_est (versão '", versao_expo, "')")
  i <- match(paste(nasc[[chave]], nasc$dum_est), paste(matriz[[chave]], matriz$dum_est))
  for (s in grep("^s\\d\\d$", names(matriz), value = TRUE)) nasc[[s]] <- matriz[[s]][i]
  nasc
}
