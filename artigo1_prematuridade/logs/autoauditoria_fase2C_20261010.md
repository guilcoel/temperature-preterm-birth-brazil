# Fase 2, Parte C: autoauditoria da primeira etapa

- **Gerado por:** `00_scripts/35_autoauditoria_fase2C.R`, em 2026-10-10 18:20:14 -03. Rodada `20261010`. `versao()` no início = 4443971b (o fim está na última linha).
- **BLAS/LAPACK:** `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib`.
- **sessionInfo() completo:** `logs/sessionInfo_fase2C_20261010.txt` (§8).
- **Método:** os 26 ajustes foram refeitos com `glm(quasipoisson)` + `factor(estrato)` (epsilon 1e-12), sem `ajusta_dlnm()`, com as referências lidas à mão (`readLines`/`strsplit`); a redução, com `crossreduce`; a PACF, com `pacf()` direto nos resíduos de deviance (a janela é contínua). Cada número foi comparado com as saídas e procurado no texto do log com a mesma formatação.
- **Maiores diferenças** (glm × função): coeficientes da cross-basis 3.7e-08; vcov 16 × 16 3.9e-08; coeficientes reduzidos 9.4e-08; vcov 4 × 4 3.9e-08 (relativas); PACF 1.1e-09 (absoluta).
- **Tolerâncias** (mudadas depois de ver o resultado: a 1ª rodada deste script deu 2 conferências diferentes sem defeito, e a 2ª só imprimiu as diferenças; os dois logs estão na lixeira, com os SHA-256 no desvio 66): φ, relativa ≤ 1e-6, porque a diferença glm × gnm é ruído de convergência da mesma ordem que a dos coeficientes (φ: 2.1e-08); nós, cen e Boundary.knots, ≤ 1e-12, porque o `read.csv` do R lê textos de 17 dígitos com até 1 ULP de erro (máx. 3.6e-15; a RDS guarda os valores exatos).

## Resultado: 22 de 22 conferências iguais

| Item | Conferência | N | Resultado |
|---|---|---|---|
| Código | SHA-256 de cada arquivo de codigo_compartilhado/R/ na tag (git show) = o do log |  3 | igual |
| Código | disco = tag (git diff vazio em codigo_compartilhado/R/) |  1 | igual |
| BLAS | BLAS e LAPACK de referência (libRblas.0.dylib / libRlapack.dylib) e iguais aos do log |  2 | igual |
| Saídas | SHA-256 das 5 saídas gravadas = os do log |  5 | igual |
| Linhas | 4.505 linhas por concentração (2012-04-07 a 2024-08-06), 7 de aquecimento fora da janela | 26 | igual |
| Linhas | período e n das linhas passadas no log |  1 | igual |
| Ajustes (glm) | coeficientes da cross-basis: dif. relativa máx. ≤ 1e-6 | 26 | igual |
| Ajustes (glm) | vcov da cross-basis 16 × 16: dif. relativa máx. ≤ 1e-6 | 26 | igual |
| Ajustes (glm) | coeficientes reduzidos (crossreduce): dif. relativa máx. ≤ 1e-6 | 26 | igual |
| Ajustes (glm) | vcov reduzida 4 × 4: dif. relativa máx. ≤ 1e-6 | 26 | igual |
| Ajustes (glm) | φ (dif. relativa ≤ 1e-6), γ̂ (dif. ≤ 1e-6), EP de γ (dif. relativa ≤ 1e-6), QAIC (dif. relativa ≤ 1e-8) | 26 | igual |
| PACF | lags 1 a 7 (pacf direto nos resíduos do glm; dif. ≤ 1e-6) e as três regras de "fora" | 26 | igual |
| Especificação | nós p10/p75/p90 e cen = p50 iguais aos do CSV de referências (lido à mão); Boundary.knots = range das linhas passadas (dif. ≤ 1e-12) | 26 | igual |
| Dimensões e dias | 16 e 16 × 16; 4 e 4 × 4; 4.498 dias e todos os estratos usados, nenhum removido | 26 | igual |
| Log | as 26 linhas da tabela de especificação (nós, cen, Boundary.knots, p1/p99) | 26 | igual |
| Log | as 26 linhas da tabela de diagnósticos (com os valores do glm) | 26 | igual |
| Log | as 26 linhas da tabela da PACF (com os valores do glm) | 26 | igual |
| Log | resumo nas 26 (φ > 2, PACF nas três regras, p1/p99 dentro) |  5 | igual |
| RDS | 26 concentrações, as do cidade_nucleo(), com tag, commit e SHA-256 do código iguais aos do log | 26 | igual |
| RDS | nenhum vetor com tamanho de série diária (máximo < 1.000 elementos; a vcov 16 × 16 tem 256) |  1 | igual |
| RDS | spec, nós e Boundary.knots da base, arglag (nós e intercepto), lag 0–7, df 4 × 4, cen da reduzida = p50 e RR no cen = 1 | 26 | igual |
| Log | sinal dos lags sinalizados nas três regras (recalculado dos valores do glm) |  1 | igual |

`versao()` no fim: 4443971b.
