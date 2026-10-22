# Paridade R × Python da ig_dum_sem pelas funções da interface (acesso.R): frequência por ano × valor (NA incluído)
# em nascimentos() e em pig(com_nascimentos), e o checksum Σ (id_nasc mod 1.000.003) × (ig_dum_sem + 1), NA = 0,
# comparados com o que o paridade_ig_dum_sem.py gravou em _tmp/paridade_ig_dum_sem/py_<versao>.csv. Confere também
# a junção 1:1 pig × nascimentos em R. Lê microdado na Forja; imprime só agregados e grava o resultado em
# logs/paridade_ig_dum_sem_R_*.log.
#
# Uso (da raiz da base, DEPOIS do paridade_ig_dum_sem.py e com a mesma DADOS_PERINATAIS_CLIMA_RAIZ):
#   Rscript 00_scripts/testes/paridade_ig_dum_sem.R
#   DADOS_PERINATAIS_CLIMA_RAIZ=<raiz> Rscript 00_scripts/testes/paridade_ig_dum_sem.R
# Sai com código 1 se algum caso falhar.

base <- getwd()
source(file.path(base, "09_acesso", "acesso.R"))
P <- 1000003
res <- list(); det <- list()
ok <- function(nome, cond, d = "") { res[[nome]] <<- isTRUE(cond); det[[nome]] <<- d }

resumo <- function(df, fonte) {
  t <- as.data.frame(table(ano = df$ano, ig_dum_sem = df$ig_dum_sem, useNA = "ifany"), stringsAsFactors = FALSE)
  t <- t[t$Freq > 0, ]
  id <- df$id_nasc %% P                                    # integer64 (bit64) ou inteiro; resto < 2^31
  chk <- sum(as.numeric(id) * ifelse(is.na(df$ig_dum_sem), 0, as.numeric(df$ig_dum_sem) + 1))
  rbind(data.frame(fonte = fonte, medida = "freq", ano = as.integer(t$ano), ig_dum_sem = as.integer(t$ig_dum_sem),
                   n = as.numeric(t$Freq), stringsAsFactors = FALSE),
        data.frame(fonte = fonte, medida = "checksum", ano = NA_integer_, ig_dum_sem = NA_integer_, n = chk,
                   stringsAsFactors = FALSE))
}
chave <- function(d) paste(d$fonte, d$medida, d$ano, d$ig_dum_sem, sep = "|")

v <- versao()
n <- suppressMessages(nascimentos(c("id_nasc", "ano", "ig_dum_sem")))
ok("R: ig_dum_sem chega como inteiro", is.integer(n$ig_dum_sem), class(n$ig_dum_sem)[1])
ok("R: id_nasc único no nascimentos", !anyDuplicated(n$id_nasc), sprintf("%d linhas", nrow(n)))
p0 <- suppressMessages(pig("id_nasc"))
p <- suppressMessages(pig("id_nasc", com_nascimentos = c("ano", "ig_dum_sem")))
p_txt <- suppressMessages(pig("id_nasc", com_nascimentos = "ig_dum_sem"))
ok("R: pig('id_nasc', com_nascimentos = 'ig_dum_sem') = forma com vetor",
   identical(p_txt$ig_dum_sem, p$ig_dum_sem) && identical(as.character(p_txt$id_nasc), as.character(p$id_nasc)))
ok("R: id_nasc único no pig e todo id do pig no nascimentos", !anyDuplicated(p0$id_nasc) && all(p0$id_nasc %in% n$id_nasc),
   sprintf("%d linhas", nrow(p0)))
ok("R: pig(com_nascimentos) com o mesmo nº de linhas e a mesma ordem do pig (junção 1:1)",
   identical(as.character(p$id_nasc), as.character(p0$id_nasc)) && !anyNA(p$ano))
r <- rbind(resumo(n, "nascimentos"), resumo(p, "pig"))
f <- file.path(base, "_tmp", "paridade_ig_dum_sem", paste0("py_", v, ".csv"))
if (file.exists(f)) {
  py <- read.csv(f, na.strings = c("", "NA"), colClasses = c("character", "character", "integer", "integer", "numeric"))
  i <- match(chave(r), chave(py))
  so_r <- sum(is.na(i)); so_py <- sum(!chave(py) %in% chave(r))
  dif <- if (any(!is.na(i))) max(abs(r$n[!is.na(i)] - py$n[i[!is.na(i)]])) else Inf
  ok("R = Python: frequência por ano × valor (NA incluído), em nascimentos() e em pig(com_nascimentos)",
     so_r == 0 && so_py == 0 && dif == 0 && nrow(r) == nrow(py),
     sprintf("%d células; só no R %d; só no Python %d; dif. máx. %s", nrow(r), so_r, so_py, format(dif)))
  ok("R = Python: checksum que amarra valor e id_nasc, nas duas funções",
     all(r$n[r$medida == "checksum"] == py$n[match(chave(r[r$medida == "checksum", ]), chave(py))]))
} else ok("R = Python", FALSE, paste("rode antes testes/paridade_ig_dum_sem.py (falta", basename(f), ")"))

nf <- sum(!unlist(res))
saida <- c(sprintf("raiz = %s | versao() = %s", raiz(), v),
           vapply(names(res), function(k) paste(if (res[[k]]) "OK   " else "FALHA", k, "|", det[[k]]), ""),
           sprintf("%d/%d casos OK", length(res) - nf, length(res)))
cat(saida, sep = "\n")
writeLines(paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "|", saida),
           file.path(base, "logs", paste0("paridade_ig_dum_sem_R_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".log")))
quit(status = if (nf) 1 else 0)
