# Fase 3, A2: testes da segunda etapa (`segunda_etapa.R`)

- **Gerado por:** `00_scripts/41_testes_segunda_etapa.R`, em 2026-10-13 14:32:44 -03. Rodada `20261013`. `versao()` no início = 4443971b (o fim está na última linha).
- **Ambiente:** R 4.5.1; dlnm 2.4.10; gnm 1.1.5; mixmeta 1.2.0; tsModel 0.6.2. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib`. Semente 20261001 (Mersenne-Twister, Inversion, Rejection); sementes por concentração conforme o complemento C1.
- **Arquivos testados (SHA-256):**
  - `codigo_compartilhado/R/segunda_etapa.R`: `1fb4543a3d4f0fd31bbf35571944c37756c33b1a1d11f876d48bd9bdd3aa9abb` (igual antes e depois dos defeitos: sim);
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009` (tag `ajusta_dlnm-v1.0`, sem mudança);
  - `codigo_compartilhado/tests/testa_segunda_etapa.R`: `d10194168b8982127f4c9a050217fe97d7bf54f1800e6d521d86cdef1a5c0605`;
  - `codigo_compartilhado/tests/testa_segunda_etapa_mc.R`: `c3ae1fcd00928fe762e439c1e2f01d8ea5d913403aeb6b4827337dc0a8c54aaf`;
  - `codigo_compartilhado/tests/roda_testes.R`: `40e7b537c500a29bfd852ac67a4fcde3fbd58128321f60fc438826360436768e`;
  - `codigo_compartilhado/inst/terceiros/attrdl.R`: `d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d` (conferido contra o registrado).
- **Entradas (SHA-256 conferidos contra os logs que as geraram), usadas só como atributos, exposição, percentis, metapreditores e covariâncias:**
  - `01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds`: `5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d`;
  - `01_saidas/fase1/referencias_exposicao.csv`: `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467`;
  - `01_saidas/fase1/serie_ptb_principal.rds`: `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917`;
  - `01_saidas/fase3/percentis_exposicao_fase3_20261013.csv`: `e2bd54e9fc2df3689916331c0db79000b4fd01e1ed3d48f6c536c4a3a099b490`;

## Teste 5: parâmetros declarados antes das réplicas

- **Base:** a combinada das 26 `argvar` reais (D2): ns com nós 21,611; 26,541; 27,717 e Boundary.knots 15,541 e 31,337 °C.
- **β:** projeção, por mínimos quadrados na grade de 301 pontos entre os Boundary.knots, de log RR verdadeiro contra o x50 = 0,02 por °C acima do x75 do eixo médio: -5.2495e-03; 3.1409e-02; 7.6718e-02; 9.8256e-02. Log RR verdadeiro em x99 contra x50 = 0,05614 (exigido ≥ 0,05).
- **Ψ verdadeiro:** não diagonal, com DP = metade da raiz da média das variâncias das S_i (9.837e-02; 7.323e-02; 2.371e-01; 1.203e-01) e correlação 0,3 entre os 4 coeficientes.
- **S_i:** as vcov reduzidas reais da Fase 2 (já vistas), só como covariâncias dos coeficientes sintéticos (desvio 72d). **Metapreditores:** média e amplitude de ano inteiro do CSV, com efeito verdadeiro nulo.
- **cen:** x50 do eixo médio (24,936 °C). **TMR verdadeira** (mínimo da curva verdadeira na grade entre x1 e x99 do eixo): 23,7 °C. **Réplicas:** 1000 de 26 unidades; os sorteios de todas as réplicas são feitos antes dos ajustes.

## Resultado: 18/18 testes

| Teste | Resultado |
|---|---|
| `t01_d2_nos_medios` | passou |
| `t02_d2_boundary_knots` | passou |
| `t03_d2_curva_contra_crossreduce` | passou |
| `t04_base_combinada` | passou |
| `t06_tmr` | passou |
| `t06b_fronteira_pelo_indice` | passou |
| `t07_estabilidade_mixmeta` | passou |
| `t06c_semente_bootstrap_por_concentracao` | passou |
| `t07c_q_i2_wald_predicao_blup` | passou |
| `t07b_coeficientes_nulos` | passou |
| `t08_attrdl` | passou |
| `t09_vcov_gnm_com_phi` | passou |
| `t10_lagresposta` | passou |
| `t11_ordem_e_semente` | passou |
| `t12_serial_igual_paralelo` | passou |
| `t13_serie_consecutiva_lag1` | passou |
| `t14_grade_sem_quase_duplicata` | passou |
| `t05_recuperacao_meta` | passou |

## Monte Carlo (teste 5)

- **Cobertura do IC 95% do log RR combinado em x99 contra x50:** 0,949 (EP de MC 0,0070; IC Wilson [0,934; 0,961]); critério 0,92–0,98.
- **Viés:** -0,00052 (EP de MC 0,00061; IC MC [-0,00170; 0,00067]); relativo -0,92% (EP 1,08%); critério |·| < 10%. EP médio 0,0197; DP das estimativas 0,0191.
- **EQM contra os coeficientes verdadeiros das unidades:** BLUP 9.526e-02; primeira etapa 3.367e-01; parte fixa X_iβ̂ (predição de cada unidade pelos seus metapreditores) 1.060e-01. Critério implementado: o do BLUP é o menor desses três.
- **EQM da predição na média dos metapreditores** (a mesma predição para todas as unidades; só reportado): 9.183e-02. O prompt (A2.5) fala em "predição da média"; o comparador implementado é a parte fixa X_iβ̂ de cada unidade, interpretação feita ao escrever o teste e registrada no desvio 74. Com inclinações verdadeiras nulas, a predição na média funciona como comparador "oráculo". A escolha é do chat (desvio 74).
- **BLUP = fórmula à mão** (Xβ̂ + Ψ̂(Ψ̂ + S_i)⁻¹(y_i − Xβ̂)), numa réplica: diferença máxima 1.8e-15 (critério ≤ 1e-8).
- **Cobertura do IC 95% da TMR combinada (bootstrap da D4(a)), só reportada:** 0,939.
- **Método do mixmeta nas réplicas:** reml/diag em 2; reml/unstr em 998. Duração: 3,2 min.

## Valores descritivos dos testes rápidos

- **Teste 2:** maior |Boundary.knots − range(x)| nas 26 = 0.0e+00.
- **Teste 3:** maior diferença entre `curva()` (4 coeficientes) e o `crossreduce` com 16 coeficientes sintéticos, nas 26 concentrações e nos seus percentis = 1.1e-16 (critério ≤ 1e-10).
- **Teste 6 (quadrática):** DP das TMR sorteadas 1,047 × EP pelo método delta 1,000 (critério: diferença < 20%); largura do IC 4,00 °C.
- **Teste 8(f):** correlação entre as simulações das concentrações 1 e 2 (mesma vcov) = -0,042 (critério |r| < 0,15).
- **Teste 8, *backward* (sem teste de aditividade; complemento C1, item 5):** total − (calor + frio) = 0,0091 no AN sintético.

## Defeitos plantados (cada um numa cópia; a bateria inteira roda em cada cópia)

Os 13 primeiros são os do prompt (A2, item 11); os 8 seguintes vêm do complemento de 13/10; os 18 seguintes, da auditoria independente da Parte A (desvio 74); os 13 últimos, da re-auditoria independente das correções (desvio 75).
O teste 5 (Monte Carlo) só roda numa cópia quando nenhum teste rápido cai. Um defeito conta só se derrubar um teste que passa na versão original.

| Defeito | Trocas | Testes derrubados (dos que passam no original) | Quais |
|---|---|---|---|
| Boundary.knots omitidos na base de predição | 1 | 2 | t03_d2_curva_contra_crossreduce, t04_base_combinada |
| nós da base combinada pela mediana | 1 | 1 | t04_base_combinada |
| cen ignorado na curva | 1 | 2 | t03_d2_curva_contra_crossreduce, t04_base_combinada |
| BLUP trocado pela predição da média | 1 | 1 | t07c_q_i2_wald_predicao_blup |
| bootstrap sem a vcov (sorteios iguais ao ponto) | 1 | 2 | t06_tmr, t06c_semente_bootstrap_por_concentracao |
| grade da TMR sem o x_sup | 1 | 2 | t06_tmr, t06c_semente_bootstrap_por_concentracao |
| semente única para todas as concentrações | 1 | 3 | t06c_semente_bootstrap_por_concentracao, t08_attrdl, t11_ordem_e_semente |
| set.seed só uma vez antes dos componentes | 3 | 1 | t08_attrdl |
| calor e frio com o range trocado | 1 | 1 | t08_attrdl |
| calor extremo sem o max(p97,5, TMR) | 1 | 1 | t08_attrdl |
| denominador com os eventos do aquecimento | 1 | 1 | t08_attrdl |
| sequência de estabilidade pulando o diag | 1 | 1 | t07_estabilidade_mixmeta |
| centro da reduz_var ignorado | 1 | 1 | t10_lagresposta |
| ordem das concentrações sem trava | 1 | 1 | t11_ordem_e_semente |
| grade da TMR com unique() (quase-duplicata) | 1 | 1 | t14_grade_sem_quase_duplicata |
| fronteira da TMR por == em °C | 2 | 1 | t06b_fronteira_pelo_indice |
| sem a checagem de coeficientes nulos antes do mixmeta | 1 | 1 | t07b_coeficientes_nulos |
| set.seed sem o kind explícito | 1 | 2 | t11_ordem_e_semente, t12_serial_igual_paralelo |
| attrdl sem a checagem de datas consecutivas | 1 | 1 | t08_attrdl |
| cross-basis aceitando série não consecutiva | 1 | 1 | t13_serie_consecutiva_lag1 |
| falha do mixmeta com !isTRUE(converged) | 1 | 1 | t07_estabilidade_mixmeta |
| Q/I² residual e total trocados | 1 | 1 | t07c_q_i2_wald_predicao_blup |
| Wald do termo errado | 1 | 1 | t07c_q_i2_wald_predicao_blup |
| bootstrap com a semente da curva combinada em todas as concentrações | 1 | 1 | t06c_semente_bootstrap_por_concentracao |
| frio extremo sem o min(p2,5, TMR) | 1 | 1 | t08_attrdl |
| frio extremo igual ao frio | 1 | 1 | t08_attrdl |
| predição no primeiro conjunto de metapreditores, e não na média | 1 | 1 | t07c_q_i2_wald_predicao_blup |
| vcov do BLUP trocada pela vcov da predição | 1 | 1 | t07c_q_i2_wald_predicao_blup |
| IC da TMR pelos percentis 5 e 95 | 1 | 1 | t06_tmr |
| IC da curva com qnorm(0,95) | 1 | 1 | t03_d2_curva_contra_crossreduce |
| posição no eixo deslocada | 1 | 1 | t10_lagresposta |
| soma dos lags só de 1 a 7 | 1 | 1 | t10_lagresposta |
| ponte calculada como backward | 1 | 1 | t08_attrdl |
| busca da fronteira entre p10 e p50 | 1 | 1 | t06_tmr |
| sem conferência do SHA-256 da attrdl | 1 | 1 | t11_ordem_e_semente |
| semente sem validar o i | 1 | 1 | t11_ordem_e_semente |
| eCI da attrdl pelos percentis 5 e 95 | 1 | 1 | t08_attrdl |
| fração atribuível sem conferir o aquecimento contra o lag | 1 | 1 | t08_attrdl |
| fração atribuível sem conferir o número de coeficientes | 2 | 1 | t08_attrdl |
| semente da attrdl com o índice deslocado | 2 | 1 | t08_attrdl |
| simulações da attrdl sempre forward | 1 | 1 | t08_attrdl |
| bootstrap da TMR numa grade sem o x_sup | 1 | 1 | t06c_semente_bootstrap_por_concentracao |
| EP da curva por lag sem as covariâncias | 1 | 1 | t10_lagresposta |
| IC da curva por lag com qnorm(0,95) | 1 | 1 | t10_lagresposta |
| IC da soma dos lags com qnorm(0,95) | 1 | 1 | t10_lagresposta |
| forward aceitando NA nos cases | 1 | 1 | t08_attrdl |
| busca da TMR devolvendo o p10 no campo p50 | 1 | 1 | t06_tmr |
| curva por lag com lags padrão de 1 em 1 | 1 | 1 | t10_lagresposta |
| Ψ devolvido do modelo só com intercepto | 1 | 1 | t07c_q_i2_wald_predicao_blup |
| índice da concentração sem recusar código fora da ordem | 1 | 1 | t11_ordem_e_semente |
| posição no eixo extrapolando (rule = 2) | 1 | 1 | t10_lagresposta |
| IC da AF com os limites trocados | 1 | 1 | t08_attrdl |

- **Resultado:** todos os testes passam na versão original e cada um dos 52 defeitos derruba pelo menos um teste.

`versao()` no fim: 4443971b.
