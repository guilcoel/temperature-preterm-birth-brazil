# Fase 3, Parte B, passo 2: testes de novo antes da tag `segunda_etapa-v1.0`

- **Gerado por:** `00_scripts/44_testes_tag_fase3.R`, em 2026-10-13 21:09:47 -03. Rodada `20261013`. `versao()` no início = 4443971b (o fim está na última linha).
- **Ambiente:** R 4.5.1; dlnm 2.4.10; gnm 1.1.5; mixmeta 1.2.0; tsModel 0.6.2. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib`. Semente 20261001 (Mersenne-Twister, Inversion, Rejection), em série; sementes por concentração conforme o complemento C1.
- **Arquivos conferidos contra o testado no 41 (SHA-256):**
  - `codigo_compartilhado/R/segunda_etapa.R`: `1fb4543a3d4f0fd31bbf35571944c37756c33b1a1d11f876d48bd9bdd3aa9abb`;
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009`;
  - `codigo_compartilhado/tests/testa_segunda_etapa.R`: `d10194168b8982127f4c9a050217fe97d7bf54f1800e6d521d86cdef1a5c0605`;
  - `codigo_compartilhado/tests/testa_segunda_etapa_mc.R`: `c3ae1fcd00928fe762e439c1e2f01d8ea5d913403aeb6b4827337dc0a8c54aaf`;
  - `codigo_compartilhado/tests/roda_testes.R`: `40e7b537c500a29bfd852ac67a4fcde3fbd58128321f60fc438826360436768e`;
  - `codigo_compartilhado/inst/terceiros/attrdl.R`: `d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d`;
- `codigo_compartilhado/R/ajusta_dlnm.R` e `codigo_compartilhado/R/offset.R` com os SHA-256 registrados na tag `ajusta_dlnm-v1.0`.
- **Entradas (SHA-256), usadas só como no 41:**
  - `01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds`: `5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d`;
  - `01_saidas/fase1/referencias_exposicao.csv`: `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467`;
  - `01_saidas/fase1/serie_ptb_principal.rds`: `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917`;
  - `01_saidas/fase3/percentis_exposicao_fase3_20261013.csv`: `e2bd54e9fc2df3689916331c0db79000b4fd01e1ed3d48f6c536c4a3a099b490`;

## Resultado: 18/18 testes (log do 41: 18/18)

| Teste | Resultado | Mesmo resultado do log do 41 |
|---|---|---|
| `t01_d2_nos_medios` | passou | sim |
| `t02_d2_boundary_knots` | passou | sim |
| `t03_d2_curva_contra_crossreduce` | passou | sim |
| `t04_base_combinada` | passou | sim |
| `t06_tmr` | passou | sim |
| `t06b_fronteira_pelo_indice` | passou | sim |
| `t07_estabilidade_mixmeta` | passou | sim |
| `t06c_semente_bootstrap_por_concentracao` | passou | sim |
| `t07c_q_i2_wald_predicao_blup` | passou | sim |
| `t07b_coeficientes_nulos` | passou | sim |
| `t08_attrdl` | passou | sim |
| `t09_vcov_gnm_com_phi` | passou | sim |
| `t10_lagresposta` | passou | sim |
| `t11_ordem_e_semente` | passou | sim |
| `t12_serial_igual_paralelo` | passou | sim |
| `t13_serie_consecutiva_lag1` | passou | sim |
| `t14_grade_sem_quase_duplicata` | passou | sim |
| `t05_recuperacao_meta` | passou | sim |

## Números iguais aos do log do 41

Cada linha abaixo foi montada com a mesma formatação do 41 e procurada, como texto, no log do 41. A duração do Monte Carlo não é comparada.

| Item | Texto | Igual ao 41 |
|---|---|---|
| base | - **Base:** a combinada das 26 `argvar` reais (D2): ns com nós 21,611; 26,541; 27,717 e Boundary.knots 15,541 e 31,337 °C. | sim |
| beta | projeção, por mínimos quadrados na grade de 301 pontos entre os Boundary.knots, de log RR verdadeiro contra o x50 = 0,02 por °C acima do x75 do eixo médio: -5.2495e-03; 3.1409e-02; 7.6718e-02; 9.8256e-02. Log RR verdadeiro em x99 contra x50 = 0,05614 (exigido ≥ 0,05). | sim |
| psi | com DP = metade da raiz da média das variâncias das S_i (9.837e-02; 7.323e-02; 2.371e-01; 1.203e-01) e correlação 0,3 entre os 4 coeficientes. | sim |
| cen | - **cen:** x50 do eixo médio (24,936 °C). **TMR verdadeira** (mínimo da curva verdadeira na grade entre x1 e x99 do eixo): 23,7 °C. **Réplicas:** 1000 de 26 unidades; | sim |
| cobertura | - **Cobertura do IC 95% do log RR combinado em x99 contra x50:** 0,949 (EP de MC 0,0070; IC Wilson [0,934; 0,961]); critério 0,92–0,98. | sim |
| vies | - **Viés:** -0,00052 (EP de MC 0,00061; IC MC [-0,00170; 0,00067]); relativo -0,92% (EP 1,08%); critério \|·\| < 10%. EP médio 0,0197; DP das estimativas 0,0191. | sim |
| eqm | - **EQM contra os coeficientes verdadeiros das unidades:** BLUP 9.526e-02; primeira etapa 3.367e-01; parte fixa X_iβ̂ (predição de cada unidade pelos seus metapreditores) 1.060e-01. | sim |
| eqm_media | - **EQM da predição na média dos metapreditores** (a mesma predição para todas as unidades; só reportado): 9.183e-02. | sim |
| blup_formula | numa réplica: diferença máxima 1.8e-15 (critério ≤ 1e-8). | sim |
| cob_tmr | - **Cobertura do IC 95% da TMR combinada (bootstrap da D4(a)), só reportada:** 0,939. | sim |
| metodos | - **Método do mixmeta nas réplicas:** reml/diag em 2; reml/unstr em 998. Duração: | sim |
| t02 | - **Teste 2:** maior \|Boundary.knots − range(x)\| nas 26 = 0.0e+00. | sim |
| t03 | nas 26 concentrações e nos seus percentis = 1.1e-16 (critério ≤ 1e-10). | sim |
| t06 | - **Teste 6 (quadrática):** DP das TMR sorteadas 1,047 × EP pelo método delta 1,000 (critério: diferença < 20%); largura do IC 4,00 °C. | sim |
| t08f | - **Teste 8(f):** correlação entre as simulações das concentrações 1 e 2 (mesma vcov) = -0,042 (critério \|r\| < 0,15). | sim |
| t08b | total − (calor + frio) = 0,0091 no AN sintético. | sim |

- **Duração do Monte Carlo:** 3,9 min.

## Conferência do desvio 76: BLUP trocado pela parte fixa

- **Troca, numa cópia de `segunda_etapa.R`:** `out$blup <- lapply(b, function(z) list(coef = unname(z$blup), vcov = unname(z$vcov)))` → `fx_def <- stats::predict(fit); out$blup <- lapply(seq_along(b), function(j) list(coef = unname(fx_def[j, ]), vcov = unname(b[[j]]$vcov)))`.
- **Testes rápidos que caem:** `t07c_q_i2_wald_predicao_blup` (diferença 0.1131248 > 1e-10).
- **Teste 5, rodado mesmo assim (sem a cobertura da TMR):** caiu: EQM dos BLUPs não é o menor: 0.10595475 / 0.33667388 / 0.10595475 / 0.09182945.
- **Defeito pego:** sim.

## SHA-256 de `codigo_compartilhado/R/` e `codigo_compartilhado/tests/` (para a mensagem da tag)

- `codigo_compartilhado/R/.gitkeep`: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`;
- `codigo_compartilhado/R/ajusta_dlnm.R`: `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009`;
- `codigo_compartilhado/R/offset.R`: `55111b2cc510d7b1c7b78b7f84e99997c5202825e0353da70bab0b4bea290bae`;
- `codigo_compartilhado/R/segunda_etapa.R`: `1fb4543a3d4f0fd31bbf35571944c37756c33b1a1d11f876d48bd9bdd3aa9abb`;
- `codigo_compartilhado/tests/.gitkeep`: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`;
- `codigo_compartilhado/tests/gera_sintetico.R`: `d53bb35d65cd350d26b5b55cd33c5fa393b26d41c34434f01195f82a2b3f5642`;
- `codigo_compartilhado/tests/roda_testes.R`: `40e7b537c500a29bfd852ac67a4fcde3fbd58128321f60fc438826360436768e`;
- `codigo_compartilhado/tests/testa_ajusta_dlnm.R`: `bea75cc35c987e09b8b339eb20772e7fccd5234c7284a127b4e6e59dfafe5941`;
- `codigo_compartilhado/tests/testa_ajusta_dlnm_mc.R`: `a89c00501931c9251b40fd71f62907142e61b4a734834b2ac659581c754303d7`;
- `codigo_compartilhado/tests/testa_offset.R`: `6a7a4d96994d3e4cb0f411617517cd22b38e693787a309821ba5791380ab7eec`;
- `codigo_compartilhado/tests/testa_segunda_etapa.R`: `d10194168b8982127f4c9a050217fe97d7bf54f1800e6d521d86cdef1a5c0605`;
- `codigo_compartilhado/tests/testa_segunda_etapa_mc.R`: `c3ae1fcd00928fe762e439c1e2f01d8ea5d913403aeb6b4827337dc0a8c54aaf`;

- **Conclusão:** o código no disco é o testado e auditado na Parte A; os testes dão 18/18, o mesmo resultado por teste e os mesmos números do log do 41; o defeito "BLUP trocado pela parte fixa" é pego. A tag `segunda_etapa-v1.0` vai no commit `410dd6d6d3d315004f22fd7197c326de77f3c2f4`.

`versao()` no fim: 4443971b.
