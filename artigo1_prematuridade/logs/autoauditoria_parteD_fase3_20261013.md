# Fase 3, Parte D: autoauditoria

- **Gerado por:** `00_scripts/51_autoauditoria_fase3D.R`, em 2026-10-14 00:02:12 -03. Rodada `20261013`. `versao()` no início = 4443971b (o fim está na última linha).
- **BLAS/LAPACK:** `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib`.
- **Método:** as contas do 50 refeitas com código diferente e comparadas com as saídas (CSV e RDS, com os SHA-256 do log); os números refeitos foram procurados no texto do log com a mesma formatação.
- **Código diferente:** P1 com o `mixmeta` chamado direto e W à mão; testes do item 2 com `splines::ns`; réplicas 1, 2, 500 e 1.000 (fixadas no desvio 79(h)) com a sequência de sorteios regenerada, o `mixmeta` direto, a MRT na grade montada à mão, a AF *forward* à mão (sem a `attrdl`) e os RR combinados à mão; CSV de réplicas conferido contra a RDS no texto `%.17g`; quantis e comparação recalculados dos valores da RDS.
- **Tolerâncias:** 1e-8 a 1e-10, conforme a escala; quantis e textos com igualdade exata.

## Resultado: 17 de 17 conferências iguais

| Item | Conferência | N | Resultado |
|---|---|---|---|
| Entradas | CSV e RDS do 50 com os SHA-256 do log | 3 | igual |
| P1 | W e p (mixmeta direto, predição x̄B̂ e vcov à mão) | 2 | igual |
| P1 | W, gl e p no log do 50 | 1 | igual |
| Item 2 | g e menor Δ_t de São Paulo/SP (splines::ns, à mão) | 2 | igual |
| Item 2 | g e menor Δ_t de Sorocaba/SP (splines::ns, à mão) | 2 | igual |
| Item 2 | contagem de concentrações com o teste (ii) ok e com o diagnóstico de passo 1e-5 ok (CSV × RDS) | 2 | igual |
| P2 | réplica 1 refeita à mão (sorteios regenerados, mixmeta direto, MRT na grade, AF forward e RR combinados à mão) | 1 | igual |
| P2 | réplica 2 refeita à mão (sorteios regenerados, mixmeta direto, MRT na grade, AF forward e RR combinados à mão) | 1 | igual |
| P2 | réplica 500 refeita à mão (sorteios regenerados, mixmeta direto, MRT na grade, AF forward e RR combinados à mão) | 1 | igual |
| P2 | réplica 1000 refeita à mão (sorteios regenerados, mixmeta direto, MRT na grade, AF forward e RR combinados à mão) | 1 | igual |
| P2 | CSV de réplicas igual à tabela da RDS (texto %.17g, igualdade exata; colunas numéricas, falhas e métodos) | 8 | igual |
| P2 | AF observada = AF total do principal no CSV do 46 | 1 | igual |
| P2 | número de réplicas e de falhas | 2 | igual |
| P2 | mediana, p2,5 e p97,5 da AF total nula e a comparação | 4 | igual |
| P2 | AF observada, distribuição nula e comparação no log do 50 | 1 | igual |
| P2 | descritivas (calor, frio, RR no x99 e no x1, MRT no p99 e no p1) | 6 | igual |
| P2 | observado: 10 MRT BLUP no p99 e nenhuma no p1 | 2 | igual |

`versao()` no fim: 4443971b.
