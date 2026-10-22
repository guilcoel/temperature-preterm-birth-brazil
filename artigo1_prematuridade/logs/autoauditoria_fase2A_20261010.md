# Fase 2, A3.1: autoauditoria da Parte A

- **Gerado por:** `00_scripts/33_autoauditoria_fase2A.R`, em 2026-10-10 13:11:30 -03. Rodada `20261010`. `versao()` no início = 4443971b (o fim está na última linha).
- **BLAS/LAPACK:** `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib`.
- **Código auditado (SHA-256):**
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009`;
  - `codigo_compartilhado/tests/gera_sintetico.R`: `d53bb35d65cd350d26b5b55cd33c5fa393b26d41c34434f01195f82a2b3f5642`;
  - `codigo_compartilhado/tests/testa_ajusta_dlnm.R`: `bea75cc35c987e09b8b339eb20772e7fccd5234c7284a127b4e6e59dfafe5941`;
  - `codigo_compartilhado/tests/testa_ajusta_dlnm_mc.R`: `a89c00501931c9251b40fd71f62907142e61b4a734834b2ac659581c754303d7`;
  - `codigo_compartilhado/tests/roda_testes.R`: `40e7b537c500a29bfd852ac67a4fcde3fbd58128321f60fc438826360436768e`;
- **Método:** cada número dos logs do 30, do 31 e do 38 foi recalculado com código diferente do que o gerou e procurado no texto do log, com a mesma formatação.
- **Código diferente:** somas por estrato com split/vapply e ACF manual (A0); quantil tipo 7 à mão; θ por kronecker + qr.solve; verdadeiro θ pelo crossreduce(coef = θ); viés esperado do teste 7 com glm de Poisson e factor(estrato); as 200 réplicas de cada cenário de Monte Carlo (1.000 no 5b, como no 38) geradas de novo (mesma semente e ordem) e reajustadas com glm(quasipoisson) + factor(estrato) + crossreduce, sem `ajusta_dlnm()`; IC de Wilson pelo `prop.test(correct = FALSE)`; chance de cobertura acima de 0,98 por soma de `dbinom`; ruído branco do teste 9 com `acf(type = "partial")`; os testes rápidos de cada um dos 28 defeitos (lidos do 31) rodados de novo.
- **Limite:** os testes de Monte Carlo de cada defeito não foram rodados de novo aqui (só os rápidos); os testes de Monte Carlo listados no 31 para cada defeito são aceitos como estão.

## Resultado: 44 de 44 conferências iguais

| Item | Conferência | N | Resultado |
|---|---|---|---|
| A0 | as 26 linhas da tabela por concentração (fração intra, 5 ACF, desvios em feriados e demais dias) | 26 | igual |
| Base fixa | nós, cen, p99 e Boundary.knots (quantil tipo 7 à mão) |  4 | igual |
| Teste 5 | θ (16, notação científica), R² e os dois verdadeiros |  4 | igual |
| Teste 7 | viés esperado, EP de Poisson (4.500 dias), EP de MC e razão (glm de Poisson) |  4 | igual |
| Testes 5, 5b e 6 | cobertura, viés, EP e IC de MC (reajuste com glm) |  3 | igual |
| Testes 5 e 5b, descritivo | dobradiça contra 0,03 × (p99 − p75) e contra o verdadeiro θ (reajuste com glm) |  3 | igual |
| Testes 5 e 5b, descritivo | viés da dobradiça em % do verdadeiro e diferença entre os verdadeiros (texto do erro de especificação) |  3 | igual |
| Teste 5 | γ̂ médio, EP de MC e distância em EP (glm) |  2 | igual |
| Testes 5, 5b e 6 | φ médio (glm) |  1 | igual |
| Teste 7 | zw − z_w_gama e viés do nenhum (glm) |  2 | igual |
| Diagnóstico do 5b | as 4 linhas da tabela (1–200, 201–1.000, 1–1.000 e o 5 para comparar; glm) |  4 | igual |
| Diagnóstico do 5b | chance de cobertura acima de 0,98 por acaso (soma de dbinom de 197 a 200) |  1 | igual |
| Teste 9 | fração do ruído branco fora da faixa e IC de Wilson (acf parcial) |  1 | igual |
| A2 | testes rápidos passam na versão original (re-rodados) |  1 | igual |
| A2 | testes que passam / total no log do 31 = recalculado (rápidos re-rodados + critérios de MC com glm) |  2 | igual |
| Defeitos | "cross-basis montada depois de cortar a janela": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  5 | igual |
| Defeitos | "estratos vazios mantidos": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  3 | igual |
| Defeitos | "log_w fora do modelo no z_w_gama": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  6 | igual |
| Defeitos | "cen ignorado, centrando no 0 °C": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "lag atravessando unidades sem group": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "PACF no vetor empilhado": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "φ com n − length(coef)": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "vcov sem φ (dispersão 1)": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "limite da PACF com os dias da grade, NA incluídos": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "sem checagem de convergência": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "sem checagem de vcov positiva-definida (16 × 16)": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "sem checagem de vcov positiva-definida (reduzida)": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "EP de γ devolvido como variância": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "QAIC sem φ": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "Boundary.knots só da janela": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "grade da PACF só com os dias da janela": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "erro em φ, QAIC ou PACF não capturado": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "sem o ramo "vcov indisponível"": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "erro no crossreduce não capturado": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "offset não finito dentro do ajuste": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "γ̂ tirado do coeficiente errado": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "zw com offset log_z": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  0 | igual |
| Defeitos | "z_w_gama com offset log_zw": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  2 | igual |
| Defeitos | "linhas por unidade contadas antes de tirar os estratos vazios": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "estratos usados contados antes de tirar os vazios": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "dias removidos contados fora das linhas de ajuste": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "`fora` sem checar lag NA": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "EP de γ sem checar a variância": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| SHA-256 | função e testes iguais aos do log do 31 (o código auditado é o testado) |  5 | igual |

`versao()` no fim: 4443971b.
