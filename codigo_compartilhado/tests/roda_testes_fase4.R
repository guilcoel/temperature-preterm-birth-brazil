# roda_testes_fase4.R — executor dos testes da Fase 4 do Artigo 1 (prompt da Parte A, seção 2), em R base, como o
# roda_testes.R, com o tipo de cada falha (Nota 3 da auditoria de 15/10/2026):
#   "erro": a condição foi sinalizada com algum quadro ativo de uma função do código testado (definida em `f` ou num
#           ambiente filho dele): o código quebrou;
#   "critério": a condição foi sinalizada fora do código testado (stop/stopifnot do próprio teste, depois de o código
#           testado devolver): o teste reprovou.
# Avisos viram erro, como no roda_testes.R, com o mesmo critério de tipo.
#
# roda_testes_fase4(f, testes): data.frame(teste, ok, tipo, mensagem).

roda_testes_fase4 <- function(f, testes) {
  de_f <- function(fn) {
    if (!is.function(fn)) return(FALSE)
    e <- environment(fn)
    for (k in 1:8) { if (is.null(e) || identical(e, emptyenv())) return(FALSE); if (identical(e, f)) return(TRUE); e <- parent.env(e) }
    FALSE
  }
  res <- lapply(names(testes), function(nm) {
    tipo <- ""
    marca <- function() { fs <- lapply(seq_len(sys.nframe()), sys.function); if (any(vapply(fs, de_f, TRUE))) "erro" else "critério" }
    m <- tryCatch(withCallingHandlers({ testes[[nm]](f); "" },
                                      warning = function(w) { tipo <<- marca(); stop("aviso: ", conditionMessage(w)) },
                                      error = function(e) if (!nzchar(tipo)) tipo <<- marca()),
                  error = function(e) conditionMessage(e))
    data.frame(teste = nm, ok = identical(m, ""), tipo = if (identical(m, "")) "" else tipo, mensagem = m, stringsAsFactors = FALSE)
  })
  do.call(rbind, res)
}
