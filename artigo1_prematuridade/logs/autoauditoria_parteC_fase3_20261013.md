# Fase 3, Parte C: autoauditoria

- **Gerado por:** `00_scripts/47_autoauditoria_fase3C.R`, em 2026-10-13 22:08:35 -03. Rodada `20261013`. `versao()` no início = 4443971b (o fim está na última linha).
- **BLAS/LAPACK:** `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib`.
- **Método:** as contas principais do 45 e do 46 refeitas com código diferente e comparadas com as saídas (RDS e CSV, com os SHA-256 dos logs); os números refeitos foram procurados no texto dos logs com a mesma formatação.
- **Código diferente:** `mixmeta` chamado direto (sem `meta_curva`); bases pelo `splines::ns` (sem `onebasis`, `base_combinada` e `curva`); grade da TMR montada à mão; bootstrap à mão na combinada (i = 0), em São Paulo (i = 1) e em Sorocaba (i = 25), fixados no desvio 77(g); coeficientes de lag pelos 16 coeficientes à mão (sem `crossreduce`); AN *forward* à mão em São Paulo e Sorocaba; totais pela soma das simulações; denominadores recontados na série.
- **Tolerâncias:** 1e-8 a 1e-14, conforme a escala de cada quantidade; textos com igualdade exata.

## Resultado: 42 de 42 conferências iguais

| Item | Conferência | N | Resultado |
|---|---|---|---|
| Entradas | RDS e CSV do 45 e do 46 com os SHA-256 dos logs |   4 | igual |
| C1 | coeficientes, vcov e Ψ da meta-regressão (mixmeta direto) |   3 | igual |
| C1 | Q, gl e I² residual e total |   2 | igual |
| C1 | Q e I² no log do 45 |   4 | igual |
| C1 | Wald de cada metapreditor (forma quadrática à mão) |   2 | igual |
| C1 | Wald no log do 45 |   2 | igual |
| C1 | predição na média dos metapreditores (x̄B̂ e vcov à mão) |   2 | igual |
| C1 | autovalores e posto efetivo de Ψ no log do 45 |   1 | igual |
| C1 | BLUPs e vcov dos BLUPs (mixmeta::blup) |  26 | igual |
| C2 | base combinada (nós e Boundary.knots médios) |   2 | igual |
| C2 | TMR combinada na grade à mão e fronteira pelo índice |   2 | igual |
| C2 | q_TMR (approx no eixo médio) |   1 | igual |
| C2 | IC da TMR combinada (bootstrap à mão, i = 0) |   1 | igual |
| C2 | proporção de sorteios no x1 e no x99 (bootstrap à mão) |   2 | igual |
| C2 | TMR combinada, percentil e IC no log do 45 |   1 | igual |
| C2 | RR combinados em x99, x1, x95, x90, x10 e x5 (log RR e EP) |   6 | igual |
| C2 | contrastes combinados no log do 45 |   6 | igual |
| C3 | TMR BLUP na grade à mão nas 26 |  26 | igual |
| C3 | fronteira pelo índice nas 26 |  26 | igual |
| C3 | RR por concentração nos p99, p95, p90, p10, p5 e p1 (log RR e EP; splines::ns) |  26 | igual |
| C3 | RR contra a mediana nas concentrações com TMR BLUP na fronteira (splines::ns) |  10 | igual |
| C3 | número de TMR BLUP na fronteira no log do 45 |   1 | igual |
| C3 | IC da TMR BLUP de São Paulo/SP (bootstrap à mão, i = 1) |   1 | igual |
| C3 | proporção de sorteios no p1 e no p99 de São Paulo/SP (bootstrap à mão) |   2 | igual |
| C3 | TMR e IC de São Paulo/SP no log do 45 |   1 | igual |
| C3 | IC da TMR BLUP de Sorocaba/SP (bootstrap à mão, i = 25) |   1 | igual |
| C3 | proporção de sorteios no p1 e no p99 de Sorocaba/SP (bootstrap à mão) |   2 | igual |
| C3 | TMR e IC de Sorocaba/SP no log do 45 |   1 | igual |
| C4 | centro da lag–resposta (quantile no q_TMR, ou p50 na fronteira) nas 26 |  26 | igual |
| C4 | coeficientes de lag no p99 e no p1 pelos 16 coeficientes à mão (sem crossreduce) nas 26 |  52 | igual |
| C4 | predição na média da lag–resposta no p99 e no p1 (mixmeta direto) |   2 | igual |
| C4 | soma dos lags 0–7 no p99 e no p1 (à mão) |   2 | igual |
| C4 | soma dos lags no log do 45 |   1 | igual |
| C4 | RR por lag inteiro no log do 45 |   8 | igual |
| C5 | denominadores recontados na série = os do 46 = n$eventos da Fase 2 |  26 | igual |
| C5 | AN forward à mão, São Paulo/SP, cinco componentes (principal) |   5 | igual |
| C5 | AN forward à mão, Sorocaba/SP, cinco componentes (principal) |   5 | igual |
| C5 | AF, AF inferior e AF superior = AN / denominador em todas as linhas do 46 | 405 | igual |
| C5 | contribuições negativas de Sorocaba (principal), total, fora e dentro de p1–p99, à mão |   3 | igual |
| C5 | totais das 26 (AN, eCI pela soma das simulações e AF), três análises × cinco componentes |  15 | igual |
| C5 | totais no log do 46 |  15 | igual |
| C5 | denominador total no log do 46 |   1 | igual |

`versao()` no fim: 4443971b.
