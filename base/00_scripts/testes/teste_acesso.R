# Teste da interface de acesso em R (09_acesso/acesso.R) contra a base e contra a interface em Python. Lê
# microdado na Forja; imprime só agregados. Rodar DEPOIS de testes/teste_acesso.py, que grava em
# _tmp/teste_acesso/ as matrizes do Python.
#
# Uso (da raiz da base):
#   Rscript 00_scripts/testes/teste_acesso.R
# Sai com código 1 se algum caso falhar.

source("09_acesso/acesso.R")
res <- list(); det <- list()
ok <- function(nome, cond, d = "") { res[[nome]] <<- isTRUE(cond); det[[nome]] <<- d }

mesma_matriz <- function(a, b, tol = 1e-9) {
  k <- names(a)[1]
  a <- a[order(a[[k]], a$dum_est), ]; b <- b[order(b[[k]], b$dum_est), ]
  if (!identical(names(a), names(b)) || nrow(a) != nrow(b) || !all(a[[k]] == b[[k]]) || !all(a$dum_est == b$dum_est))
    return(list(FALSE, "estrutura diferente"))
  x <- as.matrix(a[, grep("^s\\d\\d$", names(a))]); y <- as.matrix(b[, grep("^s\\d\\d$", names(b))])
  na <- sum(is.na(x) != is.na(y)); okc <- !is.na(x) & !is.na(y)
  d <- if (any(okc)) max(abs(x[okc] - y[okc])) else 0
  list(na == 0 && d < tol, sprintf("dif máx %.1e; NA discordantes %d; %d células", d, na, length(x)))
}

man <- manifesto()
ok("versão e manifesto", identical(versao(), man$versao), versao())
v <- verificar(c("06_processados/expo_semanal_tmean_nucleo.parquet", "06_processados/expo_semanal_pm25_rm_nv.parquet",
                 "06_processados/clima_municipio_diario_2010_2025.parquet", "06_processados/pm25_municipio_diario_2010_2025.parquet",
                 "06_processados/nascimentos.parquet"))
ok("md5 dos arquivos usados = manifesto", all(v), sprintf("%d/%d", sum(v), length(v)))
for (vv in list(c("tmean", "nucleo"), c("rh", "rm_nv"), c("pm25", "rm_nv"), c("tmean", "mun"))) {
  r <- mesma_matriz(matriz_semanal(vv[1], vv[2]), expo_semanal(vv[1], vv[2]))
  ok(sprintf("R: matriz_semanal('%s', '%s') = expo_semanal gravada pelo 06c", vv[1], vv[2]), r[[1]], r[[2]])
}
py <- file.path(raiz(), "_tmp", "teste_acesso")
for (vv in list(c("pm25_zero_na", "rm_nv"), c("tmax", "nucleo"))) {
  f <- file.path(py, sprintf("py_%s_%s.parquet", vv[1], vv[2]))
  if (!file.exists(f)) { ok(sprintf("R = Python: %s %s", vv[1], vv[2]), FALSE, "rode antes testes/teste_acesso.py"); next }
  r <- mesma_matriz(matriz_semanal(vv[1], vv[2]), as.data.frame(arrow::read_parquet(f)))
  ok(sprintf("R = Python: matriz_semanal('%s', '%s')", vv[1], vv[2]), r[[1]], r[[2]])
}
ent <- setNames(man$arquivos, vapply(man$arquivos, `[[`, "", "caminho"))
.acesso$avisados <- character(0)      # o aviso sai uma vez por sessão; os pesos da _rm_nv já leram nascimentos
saida_err <- capture.output(n <- suppressMessages(suppressWarnings(nascimentos(c("id_nasc", "CD_MUN6", "data", "ga_sem", "unico")))),
                            type = "message")
ok("aviso de sigilo visível mesmo dentro de suppressMessages/suppressWarnings (stderr; B5)", any(grepl("microdado", saida_err)))
ok("nascimentos: nº de linhas = manifesto", nrow(n) == ent[["06_processados/nascimentos.parquet"]]$n_linhas)
am <- n[n$unico %in% TRUE & !is.na(n$ga_sem) & n$ga_sem >= 37 & n$ga_sem <= 42 & format(n$data, "%Y") >= "2012", ]
am <- am[order(am$id_nasc), ][1:2000, ]          # mesma amostra determinística do teste em Python
lig <- suppressMessages(ligar_expo_semanal(am, "tmean", "nucleo"))
ok("ligar_expo_semanal: mesmas linhas, MESMA ORDEM e colunas = entrada + dum_est + recorte_principal + s01..s37",
   nrow(lig) == nrow(am) && !anyNA(lig$s01) && identical(lig$id_nasc, am$id_nasc) &&
     identical(names(lig), c(names(am), "dum_est", "recorte_principal", sprintf("s%02d", 1:37))))
l6 <- suppressMessages(ligar_expo_semanal(am, "tmean", "nucleo", ajuste_dias = 6))
ok("ligar_expo_semanal: ajuste +6 desloca a DUM 3 dias", all(as.integer(lig$dum_est - l6$dum_est) == 3L))
fr <- file.path(py, "py_ligar_resumo.csv")      # só somas (agregado), gravadas pelo teste em Python (B2)
if (file.exists(fr)) {
  rp <- read.csv(fr)
  sem <- sprintf("s%02d", 1:37)
  rr <- c(n = nrow(lig), n_recortes = length(unique(lig$recorte_principal)),
          soma_dias_dum = sum(as.numeric(lig$dum_est - as.Date("2010-01-01"))),
          setNames(colSums(lig[, sem]), paste0("soma_", sem)), setNames(colSums(is.na(lig[, sem])), paste0("na_", sem)))
  d <- max(abs(rr - unlist(rp[1, names(rr)])))
  ok("R = Python: ligar_expo_semanal na mesma amostra (somas de dum_est e de s01..s37, NA por semana)",
     identical(sort(names(rp)), sort(names(rr))) && d < 1e-6, sprintf("dif máx das somas %.1e", d))
} else ok("R = Python: ligar_expo_semanal", FALSE, "rode antes testes/teste_acesso.py")
ok("ligar_expo_semanal: matriz sem a chave da versão pedida dá erro (B6)",
   inherits(tryCatch(ligar_expo_semanal(am[1:5, ], "tmean", "nucleo", matriz = expo_semanal("tmean", "mun")[1:10, ]),
                     error = function(e) e), "error"))
ok("verificar: caminho fora do manifesto dá erro (B7)",
   inherits(tryCatch(verificar("06_processados/nao_existe.parquet", parar = FALSE), error = function(e) e), "error"))
cc <- ler("logs/pig_concordancia.csv")
ok("CSV: célula vazia entre aspas vira NA (como no Python; B4)", all(is.na(cc$n[cc$ano == "2012-2024"])) && any(cc$ano == "2012-2024"))
pg <- suppressMessages(pig(c("id_nasc", "pop_pig_principal"), com_nascimentos = "ano"))
pg0 <- suppressMessages(pig(c("id_nasc", "pop_pig_principal")))
ok("pig(com_nascimentos): mesma ordem de linhas do pig_classificacao e ano preenchido",
   identical(pg$id_nasc, pg0$id_nasc) && !anyNA(pg$ano) && identical(names(pg), c("id_nasc", "pop_pig_principal", "ano")))
ok("CSV: célula vazia vira NA, como no Python", is.na(referencias_pig()$pedreira$observacao[1]))

for (k in names(res)) cat(if (res[[k]]) "OK   " else "FALHA", k, "|", det[[k]], "\n")
f <- sum(!unlist(res))
cat(sprintf("%d/%d casos OK\n", length(res) - f, length(res)))
quit(status = if (f) 1 else 0)
