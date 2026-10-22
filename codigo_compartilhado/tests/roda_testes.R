# roda_testes.R — executor dos testes do código compartilhado, em R base (o testthat não está no renv.lock; desvio 42
# do Artigo 1). Cada teste é uma função function(f) que termina sem erro quando passa.
#
# roda_testes(f, testes): roda cada teste com tryCatch e devolve data.frame(teste, ok, mensagem).
#   f: ambiente ou lista com as funções testadas (permite rodar sobre cópias com defeito plantado).
#   testes: lista nomeada de funções.
#
# Uso, da raiz do repositório:
#   f <- new.env(); sys.source("codigo_compartilhado/R/offset.R", envir = f)
#   source("codigo_compartilhado/tests/roda_testes.R"); source("codigo_compartilhado/tests/testa_offset.R")
#   r <- roda_testes(f, testes_offset); print(r); stopifnot(all(r$ok))

roda_testes <- function(f, testes) {
  res <- lapply(names(testes), function(nm) {
    m <- tryCatch(withCallingHandlers({ testes[[nm]](f); "" },
                                      warning = function(w) stop("aviso: ", conditionMessage(w))),
                  error = function(e) conditionMessage(e))
    data.frame(teste = nm, ok = identical(m, ""), mensagem = m, stringsAsFactors = FALSE)
  })
  do.call(rbind, res)
}
