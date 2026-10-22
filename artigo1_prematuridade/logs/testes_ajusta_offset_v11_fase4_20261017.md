# Fase 4, Parte A: ajusta_dlnm v1.1 e offset v1.1 — testes e mutantes (só dado sintético)

- **Gerado por:** `00_scripts/60_testes_ajusta_offset_v11.R` (SHA-256 `be110c09528722e0ed816f126ab6e9b79aa750bdfe133dec6a700a8f2173c3e9`), início em 2026-10-17 08:35:53 -0300, fim em 2026-10-17 08:39:10 -0300. Rodada `20261017`.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `b0533a02740be2cb0cb787093db79b26d7152708` (ramo `main`); último commit da `COORD` no `HEAD`: `257fdb0 COORD: COORD-6 (D16 e indice rev. 7)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: vazio.
- **Ambiente:** R 4.5.1; dlnm 2.4.10; gnm 1.1.5. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib` (referência). Semente 20261001 (Mersenne-Twister, Inversion, Rejection). Não toca a base.
- **Código e testes (SHA-256; todos commitados e limpos antes de rodar):**
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `2acf21797f576a5a5c34a4cdab081a8bec2d09473d9993759e4d3409935eb68b`;
  - `codigo_compartilhado/R/offset.R`: `b2aac93b4681c26d74427172bcdd3adb62fbf8cd75bea97910153892e12ed398`;
  - `codigo_compartilhado/tests/roda_testes_fase4.R`: `b176d9e1fd46f7d87a81d2bad3604f08a8178662c6a24dfc18c828a27ec9a509`;
  - `codigo_compartilhado/tests/gera_sintetico.R`: `d53bb35d65cd350d26b5b55cd33c5fa393b26d41c34434f01195f82a2b3f5642`;
  - `codigo_compartilhado/tests/testa_ajusta_dlnm.R`: `bea75cc35c987e09b8b339eb20772e7fccd5234c7284a127b4e6e59dfafe5941`;
  - `codigo_compartilhado/tests/testa_ajusta_dlnm_d1_errata.R`: `d4648aa745e85a6dc92e35c0d5fad02cd47c8c7272bcf3c49813eefe5f05907b`;
  - `codigo_compartilhado/tests/testa_offset.R`: `6a7a4d96994d3e4cb0f411617517cd22b38e693787a309821ba5791380ab7eec`;
  - `codigo_compartilhado/tests/testa_ajusta_dlnm_v11.R`: `75bc2adb58fceb2dea43f2fcd8e8db6589af6cc60b3ce17807c31bbd3cf6cb48`;
  - `codigo_compartilhado/tests/testa_offset_v11.R`: `66903f1119c418ba0548b731f7155888194fae16e6fb566becb892bba21a07e1`;
  - `artigo1_prematuridade/00_scripts/60_testes_ajusta_offset_v11.R`: `be110c09528722e0ed816f126ab6e9b79aa750bdfe133dec6a700a8f2173c3e9`;
- **Regressão:** a v1.0 lida da tag `ajusta_dlnm-v1.0` (commit `caf5022`) por `git show`; os campos da v1.0 têm de sair `identical()` na v1.1 sem os argumentos novos.
- **Fora da bateria:** o Monte Carlo de `testa_ajusta_dlnm_mc.R` (1.000 réplicas), sem mudança na v1.1.

## Resultado: 60/60 testes (11 s)

| Arquivo | Teste | Resultado |
|---|---|---|
| `testa_ajusta_dlnm.R` | `t01_equivalencia_eliminate` | passou |
| `testa_ajusta_dlnm.R` | `t02_estratos_vazios` | passou |
| `testa_ajusta_dlnm.R` | `t03_aquecimento` | passou |
| `testa_ajusta_dlnm.R` | `t04_group` | passou |
| `testa_ajusta_dlnm.R` | `t08a_falha_capturada` | passou |
| `testa_ajusta_dlnm.R` | `t08b_especificacao_fallback` | passou |
| `testa_ajusta_dlnm.R` | `t09a_pacf_por_unidade` | passou |
| `testa_ajusta_dlnm.R` | `t09b_pacf_ar1_e_ruido_branco` | passou |
| `testa_ajusta_dlnm.R` | `t09c_pacf_janela_com_lacuna` | passou |
| `testa_ajusta_dlnm.R` | `t08c_ramos_de_falha_com_stub` | passou |
| `testa_ajusta_dlnm.R` | `t15_intercepto_e_unidade_pequena` | passou |
| `testa_ajusta_dlnm.R` | `t16_offset_nao_finito_e_contagens` | passou |
| `testa_ajusta_dlnm.R` | `t10_cen` | passou |
| `testa_ajusta_dlnm.R` | `t12_spec_rejeita_nk_e_confere_nos` | passou |
| `testa_ajusta_dlnm.R` | `t13_offsets_e_gama` | passou |
| `testa_ajusta_dlnm.R` | `t14_dia_faltando_e_sigilo` | passou |
| `testa_ajusta_dlnm_d1_errata.R` | `t01_quasipoisson_passa` | passou |
| `testa_ajusta_dlnm_d1_errata.R` | `t02_controle_poisson_falha_i` | passou |
| `testa_ajusta_dlnm_d1_errata.R` | `t03_estrato_vazio` | passou |
| `testa_ajusta_dlnm_d1_errata.R` | `t04_controle_sem_eliminate_falha_ii` | passou |
| `testa_offset.R` | `wj_conta_a_mao` | passou |
| `testa_offset.R` | `wj_denominador_na_populacao_inteira` | passou |
| `testa_offset.R` | `wj_erros` | passou |
| `testa_offset.R` | `offset_conta_a_mao` | passou |
| `testa_offset.R` | `offset_identidade_log` | passou |
| `testa_offset.R` | `offset_w_constante` | passou |
| `testa_offset.R` | `offset_uma_semana` | passou |
| `testa_offset.R` | `offset_ignora_semanas_fora` | passou |
| `testa_offset.R` | `erro_semana_sem_w` | passou |
| `testa_offset.R` | `erro_z_negativo` | passou |
| `testa_offset.R` | `erro_z_na` | passou |
| `testa_offset.R` | `erro_dia_zero_no_periodo` | passou |
| `testa_offset.R` | `erro_dia_ausente_com_periodo_null` | passou |
| `testa_offset.R` | `fora_do_periodo_na` | passou |
| `testa_offset.R` | `periodo_null_marca_zero` | passou |
| `testa_offset.R` | `chave_com_unidades` | passou |
| `testa_offset.R` | `periodo_sem_valor_padrao` | passou |
| `testa_offset.R` | `erro_soma_zw_zero` | passou |
| `testa_offset.R` | `z_t_zero_so_onde_z_e_zero` | passou |
| `testa_offset.R` | `erro_entradas_invalidas` | passou |
| `testa_offset.R` | `integracao_wj_offset` | passou |
| `testa_ajusta_dlnm_v11.R` | `tv11_regressao_v10` | passou |
| `testa_ajusta_dlnm_v11.R` | `tv11_residuos_deviance` | passou |
| `testa_ajusta_dlnm_v11.R` | `tv11_coluna_matriz` | passou |
| `testa_ajusta_dlnm_v11.R` | `tv11_glm_sem_eliminate` | passou |
| `testa_ajusta_dlnm_v11.R` | `tv11_d16_linhas_sem_evento` | passou |
| `testa_ajusta_dlnm_v11.R` | `tv11_ep_gama_na` | passou |
| `testa_ajusta_dlnm_v11.R` | `tv11_eventos_removidos` | passou |
| `testa_ajusta_dlnm_v11.R` | `tv11_devolve_matriz` | passou |
| `testa_ajusta_dlnm_v11.R` | `tv11_spec_validacao` | passou |
| `testa_offset_v11.R` | `to11_regressao_v10` | passou |
| `testa_offset_v11.R` | `to11_wj_ano_d12` | passou |
| `testa_offset_v11.R` | `to11_pd_fator` | passou |
| `testa_offset_v11.R` | `to11_monta_offset_ano` | passou |
| `testa_offset_v11.R` | `to11_periodo_null_zero` | passou |
| `testa_offset_v11.R` | `to11_regra_gama_calibracao` | passou |
| `testa_offset_v11.R` | `to11_regra_gama_eventos4` | passou |
| `testa_offset_v11.R` | `to11_z_liso_pertenca` | passou |
| `testa_offset_v11.R` | `to11_wj_ano_bordas` | passou |
| `testa_offset_v11.R` | `to11_regra_gama_guarda` | passou |

## Calibração da regra_gama (A1-97(d))

- Insumos fixos: distribuição de IG da Q8 (`RESPOSTA_QUESTIONAMENTO_20261007.md` da base, SHA-256 `16fe31e9…011e`) e os totais de eventos (PTB 22–36 = 1.405.697; termo precoce 37–38 = 4.307.836). Tolerância relativa de 10%.

| Caso | Obtido | Publicado | Diferença relativa |
|---|---|---|---|
| PTB, mínimo dos dois cenários | 0.0700 | 0.07 | +0.04% |
| PTB, máximo dos dois cenários | 0.1407 | 0.14 | +0.49% |
| termo precoce, pico estreito | 0.2853 | 0.29 | -1.60% |
| termo precoce, cosseno | 1.7012 | 1.68 | +1.26% |
| termo precoce por pessoa-dia, cosseno | 1.5853 | 1.58 | +0.34% |

- Controles: com os eventos × 4, o EP cai exatamente pela metade (`identical`, `to11_regra_gama_eventos4`); o mutante com DP no lugar de DP² tem de cair na calibração (tabela de mutantes).

## Observação: pesos de trabalho no glm

- Sem estratos (glm), max|W − μ̂|/μ̂ = 1e-07: o glm guarda os pesos de trabalho da penúltima iteração do IRLS. O teste W = μ̂ < 1e-8 da D16, item 2, é do modelo condicional (gnm), o da nula da PACF, onde passa (`tv11_devolve_matriz`).

## Mutantes (cada um numa cópia do arquivo de código; a bateria inteira roda em cada cópia)

| Mutante | Arquivo | Testes que caem | Por critério | Por erro | Quais |
|---|---|---|---|---|---|
| resíduo de Pearson no lugar do de deviance | ajusta_dlnm.R | 2 | 2 | 0 | t08c_ramos_de_falha_com_stub, tv11_residuos_deviance |
| glm não condicional com poisson (φ fixo em 1) | ajusta_dlnm.R | 1 | 1 | 0 | tv11_glm_sem_eliminate |
| coluna-matriz tratada como vetor | ajusta_dlnm.R | 1 | 0 | 1 | tv11_coluna_matriz |
| eventos removidos contando a janela inteira | ajusta_dlnm.R | 1 | 1 | 0 | tv11_eventos_removidos |
| pesos a priori no lugar dos de trabalho | ajusta_dlnm.R | 1 | 1 | 0 | tv11_devolve_matriz |
| sem estratos, os dias sem evento saem do ajuste (D16) | ajusta_dlnm.R | 2 | 2 | 0 | tv11_glm_sem_eliminate, tv11_d16_linhas_sem_evento |
| EP de γ calculado com γ NA (sem o ramo NA) | ajusta_dlnm.R | 1 | 1 | 0 | tv11_ep_gama_na |
| ns(tempo) calculado com o aquecimento (D16) | ajusta_dlnm.R | 1 | 1 | 0 | tv11_glm_sem_eliminate |
| w_j por ano de nascimento, e não de entrada (D12, 4.2) | offset.R | 2 | 2 | 0 | to11_wj_ano_d12, to11_wj_ano_bordas |
| pessoa-dia com 3 dias no lugar de 4 | offset.R | 1 | 1 | 0 | to11_pd_fator |
| w_j aplicado pelo ano de entrada da gestação, e não pelo ano de t | offset.R | 1 | 1 | 0 | to11_monta_offset_ano |
| par (ano, j) sem w não sai da soma (NA propaga) | offset.R | 1 | 0 | 1 | to11_monta_offset_ano |
| regra de γ com DP no lugar de DP² (controle negativo da calibração) | offset.R | 1 | 1 | 0 | to11_regra_gama_calibracao |
| regra de γ com a gestação do término presente 7 dias, e não 4 | offset.R | 1 | 1 | 0 | to11_z_liso_pertenca |
| w_j por ano de s + 7j + 3 (auditoria, achado 3) | offset.R | 1 | 1 | 0 | to11_wj_ano_bordas |
| w_j por ano de s (auditoria, achado 3) | offset.R | 2 | 2 | 0 | to11_wj_ano_d12, to11_wj_ano_bordas |
| w por ano sem a guarda de semana sem w em nenhum ano (auditoria, achado 5) | offset.R | 1 | 1 | 0 | to11_monta_offset_ano |
| termos_sem_w contando células com z = 0 (auditoria, Nota 4) | offset.R | 1 | 1 | 0 | to11_monta_offset_ano |
| regra de γ sem a guarda da semana 42 (auditoria, Nota 9) | offset.R | 1 | 1 | 0 | to11_regra_gama_guarda |

- **Resultado:** todos os testes passam no original, e os 19 mutantes são mortos.

