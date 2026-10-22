# Fase 4, Parte C1: as seis sensibilidades-chave e o critério de concordância (D10)

- **Gerado por:** `00_scripts/70_chaves_c1_fase4.R` (SHA-256 `6f5deccb761de13181f1605fc0743a69509787a07a7c3061bfae240ce680fea5`), início em 2026-10-19 06:01:37 -0300, fim em 2026-10-19 06:01:56 -0300. Rodada `20261019`. `versao()` no início: 4443971b; no fim: 4443971b.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `5f75566c537691492ba67651ac061315e89a96b1` (ramo `main`); último commit da `COORD` no `HEAD`: `a925d35 COORD: COORD-8 (tags da Fase 4, Parte A do A1)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: vazio.
- **Ambiente:** R 4.5.1; dlnm 2.4.10; gnm 1.1.5; mixmeta 1.2.0. BLAS/LAPACK de referência (`libRblas.0.dylib` / `libRlapack.dylib`). Semente 20261001 (bootstrap da TMR com i = 0).
- **Código (igual ao das tags):**
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `2acf21797f576a5a5c34a4cdab081a8bec2d09473d9993759e4d3409935eb68b` (`ajusta_dlnm-v1.1`);
  - `codigo_compartilhado/R/segunda_etapa.R`: `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7` (`segunda_etapa-v1.1`);
  - `codigo_compartilhado/tests/teste3_fonte_independente.R`: `547389f5c256edf1bebf9e7542fb32c70997808cf39d4191a3ce1197871ee2f3` (`segunda_etapa-v1.1`);

## Portão de entrada

| Item | Resultado | Confere |
|---|---|---|
| 1. Tags da Parte A no remoto, cada uma no commit registrado na passagem | ajusta_dlnm-v1.1 → a926b7a; offset-v1.1 → a926b7a; segunda_etapa-v1.1 → a926b7a; sens_agudos-v1.0 → a926b7a; diagnostico_grade_mrt-v1.0.1 → 8613877 | sim |
| 2. B1 fechada (log da dupla auditoria: "Achados abertos: nenhum") e SHA-256 das entradas da B1 = logs da B1 | auditoria_parteB1_fase4_20261018.md; SHA conferem | sim |
| 2b. SHA-256 das entradas das Fases 1 a 3 (32, referências, séries municipal e espontânea) = registrados (RESPOSTA da Fase 1; log do 45) | conferem | sim |
| 3a. `ajusta_dlnm` v1.1 reproduz coeficientes e vcov (cross-basis e reduzidos) do 32 nas 26 (≤ 1e-10) | diferença máxima 0.0e+00 | sim |
| 3b. `meta_curva` v1.1 com as entradas do 45 = meta do RDS do 45 (`identical`) | identical | sim |
| 3c. `confere_meta` passa no principal | passa | sim |
| 4. Primário lido do RDS do 45: TMR combinada, q, RR no x99 e no x1 | 28,2 °C; q = 0,9378; x99 1,003 (0,978 a 1,029); x1 1,020 (0,990 a 1,051) | sim |

## Tabela do critério (D10, 1a a 1g)

- **Primário (RDS do 45):** TMR combinada 28,2 °C (q = 0,9378); RR no x99 1,003 (0,978 a 1,029); RR no x1 1,020 (0,990 a 1,051). Os vereditos do x99 e do x1 saem separados, sem "robusto" único.

| Chave | TMR (°C; percentil) | IC da TMR (°C) | RR x99 (IC) | x99 no IC do primário (0,978 a 1,029) | RR x1 (IC) | x1 no IC do primário (0,990 a 1,051) | Fallback | φ (mín.; mediana; máx.) |
|---|---|---|---|---|---|---|---|---|
| 1. `tmean_mun` (case time series municipal) | 28,0; 92,7 | 18,6 a 29,5 | 1,006 (0,984 a 1,029) | sim | 1,018 (0,987 a 1,050) | sim | nenhum | 0,966; 1,001; 1,043 |
| 2. Lag 0–14 | 28,1; 93,1 | 23,6 a 29,5 | 1,013 (0,978 a 1,048) | sim | 1,057 (1,019 a 1,098) | não | nenhum | 0,979; 1,009; 1,117 |
| 3. ns(tempo, 99 gl), sem estratos | 27,9; 91,4 | 18,8 a 29,5 | 1,016 (0,988 a 1,045) | sim | 1,012 (0,985 a 1,039) | sim | nenhum | 0,978; 1,013; 1,128 |
| 4. PM2.5 (`pm25_local_nucleo`, lag 0–1, linear) | 28,2; 93,8 | 18,8 a 29,5 | 1,003 (0,979 a 1,029) | sim | 1,021 (0,991 a 1,052) | sim | nenhum | 0,979; 1,009; 1,118 |
| 5. γ = 1 (offset log Z_t + log W_t) | 28,4; 95,1 | 18,8 a 29,5 | 1,002 (0,980 a 1,025) | sim | 1,018 (0,987 a 1,050) | sim | nenhum | 0,979; 1,009; 1,118 |
| 6. PTB espontâneo (i) | 22,3; 15,4 | 20,2 a 29,5 | 1,021 (0,978 a 1,066) | sim | 1,026 (0,994 a 1,060) | sim | nenhum | 0,992; 1,030; 1,140 |

- **Declaração obrigatória (D10, 1b):** com a TMR própria, a direção é ≥ 1 por construção; o critério se reduz a cair no IC do primário; e, como o IC do primário inclui 1 nos dois contrastes, ele é pouco informativo neste artigo.
- **Direção (log RR ≥ 0) nos contrastes avaliáveis:** chave 1: x99 ≥ 1, x1 ≥ 1; chave 2: x99 ≥ 1, x1 ≥ 1; chave 3: x99 ≥ 1, x1 ≥ 1; chave 4: x99 ≥ 1, x1 ≥ 1; chave 5: x99 ≥ 1, x1 ≥ 1; chave 6: x99 ≥ 1, x1 ≥ 1.
- **Frase de Methods (D10, 1g), lida da D10:** "A result was considered robust if, in each key sensitivity analysis, the estimate had the same direction as the primary estimate and fell within its 95% confidence interval. Each sensitivity analysis re-estimated its own pooled minimum-risk temperature; because a contrast against the minimum of the same pooled curve cannot be lower than 1, the direction condition was always met, and the criterion reduced to inclusion in the primary confidence interval. The 99th and 1st percentile contrasts were assessed separately. A contrast was deemed not assessable when the pooled minimum-risk temperature of the sensitivity analysis fell at that percentile. These operational rules were defined after the primary results were known."

## Diagnósticos por chave

| Chave | Incluídas | Excluídas | Método | Teste 3 (ok/n) | Q residual (gl; p) | I² residual | Wald média (p) | Wald amplitude (p) | Minutos |
|---|---|---|---|---|---|---|---|---|---|
| 1. `tmean_mun` (case time series municipal) | 26 | — | reml / unstr | 26/26 | 88,7 (92; 0,577) | 0,0% | 0,0677 | 0,129 | 0,1 |
| 2. Lag 0–14 | 26 | — | reml / unstr | 26/26 | 101,3 (92; 0,239) | 9,2% | 0,817 | 0,869 | 0,0 |
| 3. ns(tempo, 99 gl), sem estratos | 26 | — | reml / unstr | 26/26 | 104,1 (92; 0,183) | 11,6% | 0,231 | 0,195 | 0,1 |
| 4. PM2.5 (`pm25_local_nucleo`, lag 0–1, linear) | 26 | — | reml / unstr | 26/26 | 87,2 (92; 0,621) | 0,0% | 0,16 | 0,237 | 0,0 |
| 5. γ = 1 (offset log Z_t + log W_t) | 26 | — | reml / unstr | 26/26 | 92,4 (92; 0,468) | 0,5% | 0,142 | 0,261 | 0,0 |
| 6. PTB espontâneo (i) | 26 | — | reml / unstr | 26/26 | 102,8 (92; 0,208) | 10,5% | 0,0181 | 0,162 | 0,0 |

- **Q por coeficiente:** só descritivo, sem p ("por coeficiente (não univariado)").

| Chave | Q por coeficiente (gl) |
|---|---|
| 1. `tmean_mun` (case time series municipal) | 14,2 (23); 11,4 (23); 15,0 (23); 20,9 (23) |
| 2. Lag 0–14 | 21,2 (23); 14,1 (23); 25,2 (23); 18,9 (23) |
| 3. ns(tempo, 99 gl), sem estratos | 16,4 (23); 13,2 (23); 21,0 (23); 20,9 (23) |
| 4. PM2.5 (`pm25_local_nucleo`, lag 0–1, linear) | 12,7 (23); 10,0 (23); 15,0 (23); 23,8 (23) |
| 5. γ = 1 (offset log Z_t + log W_t) | 12,2 (23); 10,6 (23); 14,5 (23); 25,5 (23) |
| 6. PTB espontâneo (i) | 23,6 (23); 19,0 (23); 23,7 (23); 20,3 (23) |

## Saídas (fora do git)

- `01_saidas/fase4/c1_chaves_fase4_20261019.rds`: `cf5a7d753819af8c73a7e1080e12e8e5f5745bca69ec92f3e9accd51f88d3f05`;
- `01_saidas/fase4/criterio_c1_fase4_20261019.csv`: `886ca12c00ba43318e48ce784b8dac2e923d5cc4905013a82077b25882488168`;

- **Resultado:** portão aberto; as seis chaves rodaram. Tempo total: 0.3 min.

