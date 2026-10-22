# Fase 4, Parte A: segunda_etapa v1.1 — testes e mutantes (só dado sintético)

- **Gerado por:** `00_scripts/61_testes_segunda_etapa_v11.R` (SHA-256 `146ed5f419cec683704a12d405764a9f07e8c0bb4509979f6f6f47db459832a9`), início em 2026-10-18 13:31:30 -0300, fim em 2026-10-18 13:34:25 -0300. Rodada `20261018`.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `c52d2fd3f0e77b6697470613e637788d9e2a5333` (ramo `main`); último commit da `COORD` no `HEAD`: `257fdb0 COORD: COORD-6 (D16 e indice rev. 7)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: `?? artigo1_prematuridade/logs/testes_ajusta_offset_v11_fase4_20261018.md`.
- **Ambiente:** R 4.5.1; dlnm 2.4.10; gnm 1.1.5; mixmeta 1.2.0. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib` (referência). Locale `pt_BR` (UTF-8, conferido no início). Semente 20261001 (Mersenne-Twister, Inversion, Rejection). Não toca a base.
- **Código e testes (SHA-256; todos commitados e limpos antes de rodar):**
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `2acf21797f576a5a5c34a4cdab081a8bec2d09473d9993759e4d3409935eb68b`;
  - `codigo_compartilhado/R/segunda_etapa.R`: `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7`;
  - `codigo_compartilhado/tests/roda_testes_fase4.R`: `b176d9e1fd46f7d87a81d2bad3604f08a8178662c6a24dfc18c828a27ec9a509`;
  - `codigo_compartilhado/tests/teste3_fonte_independente.R`: `547389f5c256edf1bebf9e7542fb32c70997808cf39d4191a3ce1197871ee2f3`;
  - `codigo_compartilhado/tests/testa_segunda_etapa.R`: `754190ad16d55db9fa9670a3c31257d384afabac2c9f5e4bd1a871e1478748dc`;
  - `codigo_compartilhado/tests/testa_segunda_etapa_d6.R`: `d7e5ed9f3b5bc304f1b1fa6a3254079a909eaba14450add385c0870b9a091ec4`;
  - `codigo_compartilhado/tests/testa_segunda_etapa_v11.R`: `359e3a4480a242a0397de27819175029f6d94659b3cb03fdf8cc34a8d6bdb895`;
  - `codigo_compartilhado/inst/terceiros/attrdl.R`: `d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d`;
  - `artigo1_prematuridade/00_scripts/61_testes_segunda_etapa_v11.R`: `146ed5f419cec683704a12d405764a9f07e8c0bb4509979f6f6f47db459832a9`;
- **Regressão:** a v1.0.1 lida da tag `segunda_etapa-v1.0.1` (commit `403b0a2`) por `git show`.
- **Fora da bateria:** `t01_d2_nos_medios`, `t02_d2_boundary_knots`, `t03_d2_curva_contra_crossreduce`, `t11_ordem_e_semente` (exigem atributos reais da Fase 2; o `t11` passa pela porta `.s_reais()`; o código da ordem e da semente é o da v1.0.1, conferido por deparse no `ts11_regressao_v10`; rodaram no 44 e no 55 e voltam no portão da C1) e o Monte Carlo de `testa_segunda_etapa_mc.R`.
- **Os 2 testes da v1.0.2 (A1-87(h)):** `ts11_v102_cen_fora_de_x` (x = os 6 percentis, cen = a mediana, fora de x) e `ts11_v102_argvar_errada` (nós de quantile(x_cb); fronteiras p1–p99): matam os mutantes A2, B1 e B2 (tabela de mutantes).

## Resultado: 30/30 testes (7 s)

| Arquivo | Teste | Resultado |
|---|---|---|
| `testa_segunda_etapa.R` | `t04_base_combinada` | passou |
| `testa_segunda_etapa.R` | `t06_tmr` | passou |
| `testa_segunda_etapa.R` | `t06b_fronteira_pelo_indice` | passou |
| `testa_segunda_etapa.R` | `t07_estabilidade_mixmeta` | passou |
| `testa_segunda_etapa.R` | `t06c_semente_bootstrap_por_concentracao` | passou |
| `testa_segunda_etapa.R` | `t07c_q_i2_wald_predicao_blup` | passou |
| `testa_segunda_etapa.R` | `t07b_coeficientes_nulos` | passou |
| `testa_segunda_etapa.R` | `t08_attrdl` | passou |
| `testa_segunda_etapa.R` | `t09_vcov_gnm_com_phi` | passou |
| `testa_segunda_etapa.R` | `t10_lagresposta` | passou |
| `testa_segunda_etapa.R` | `t12_serial_igual_paralelo` | passou |
| `testa_segunda_etapa.R` | `t13_serie_consecutiva_lag1` | passou |
| `testa_segunda_etapa.R` | `t14_grade_sem_quase_duplicata` | passou |
| `testa_segunda_etapa_d6.R` | `td6_t3_ns` | passou |
| `testa_segunda_etapa_d6.R` | `td6_t3_bs` | passou |
| `testa_segunda_etapa_d6.R` | `td6_wald_selecao_exata` | passou |
| `testa_segunda_etapa_d6.R` | `td6_q_por_coeficiente` | passou |
| `testa_segunda_etapa_v11.R` | `ts11_regressao_v10` | passou |
| `testa_segunda_etapa_v11.R` | `ts11_wald_continuos` | passou |
| `testa_segunda_etapa_v11.R` | `ts11_fator` | passou |
| `testa_segunda_etapa_v11.R` | `ts11_meta_fixos` | passou |
| `testa_segunda_etapa_v11.R` | `ts11_meta_multinivel` | passou |
| `testa_segunda_etapa_v11.R` | `ts11_meta_exploratoria` | passou |
| `testa_segunda_etapa_v11.R` | `ts11_confere_meta` | passou |
| `testa_segunda_etapa_v11.R` | `ts11_q_por_coeficiente` | passou |
| `testa_segunda_etapa_v11.R` | `ts11_confere_eixo` | passou |
| `testa_segunda_etapa_v11.R` | `ts11_decide_teste3` | passou |
| `testa_segunda_etapa_v11.R` | `ts11_v102_cen_fora_de_x` | passou |
| `testa_segunda_etapa_v11.R` | `ts11_v102_argvar_errada` | passou |
| `testa_segunda_etapa_v11.R` | `ts11_confere_meta_novas` | passou |

## Mutantes (cada um numa cópia do arquivo; a bateria inteira roda em cada cópia)

| Mutante | Arquivo | Testes que caem | Por critério | Por erro | Quais |
|---|---|---|---|---|---|
| seleção do termo com rep(assign, times = k) (ordem trocada) | segunda_etapa.R | 13 | 0 | 13 | t07_estabilidade_mixmeta, t07c_q_i2_wald_predicao_blup, td6_wald_selecao_exata, td6_q_por_coeficiente, ts11_regressao_v10, ts11_wald_continuos, ts11_fator, ts11_meta_fixos, ts11_meta_multinivel, ts11_meta_exploratoria, ts11_confere_meta, ts11_q_por_coeficiente, ts11_confere_meta_novas |
| ordem trocada e sem a conferência dos nomes | segunda_etapa.R |  5 | 5 |  0 | t07c_q_i2_wald_predicao_blup, td6_wald_selecao_exata, ts11_regressao_v10, ts11_wald_continuos, ts11_fator |
| predição na média forçada com fator (colMeans) | segunda_etapa.R |  3 | 0 |  3 | ts11_fator, ts11_meta_exploratoria, ts11_confere_meta_novas |
| confere_meta sem a checagem do status | segunda_etapa.R |  1 | 1 |  0 | ts11_confere_meta |
| q_por_coeficiente com coluna p | segunda_etapa.R |  1 | 1 |  0 | ts11_q_por_coeficiente |
| confere_eixo com tolerância de 1e-8, e não bit a bit | segunda_etapa.R |  1 | 1 |  0 | ts11_confere_eixo |
| decide_teste3 sem o critério da grade em range(x_cb) | segunda_etapa.R |  1 | 1 |  0 | ts11_decide_teste3 |
| exploratório contínuo sem centrar | segunda_etapa.R |  1 | 1 |  0 | ts11_meta_exploratoria |
| exploratório: "sem" = modelo só com intercepto (total) | segunda_etapa.R |  1 | 1 |  0 | ts11_meta_exploratoria |
| multinível com Ψ não estruturada na região e diagonal na concentração | segunda_etapa.R |  1 | 1 |  0 | ts11_meta_multinivel |
| efeitos fixos ajustados por REML | segunda_etapa.R |  1 | 1 |  0 | ts11_meta_fixos |
| A2: curva() centrada no ponto de x mais próximo de cen | segunda_etapa.R |  2 | 2 |  0 | ts11_regressao_v10, ts11_v102_cen_fora_de_x |
| .base_x sem os Boundary.knots da argvar (mutante 1 do 55) | segunda_etapa.R |  6 | 2 |  4 | t04_base_combinada, td6_t3_ns, td6_t3_bs, ts11_regressao_v10, ts11_v102_cen_fora_de_x, ts11_v102_argvar_errada |
| curva() com os knots da argvar × 1,001 (mutante 3 do 55) | segunda_etapa.R |  5 | 5 |  0 | t04_base_combinada, td6_t3_ns, td6_t3_bs, ts11_regressao_v10, ts11_v102_cen_fora_de_x |
| B1: teste 3 com os nós tirados da argvar | teste3_fonte_independente.R |  1 | 1 |  0 | ts11_v102_argvar_errada |
| B2: teste 3 com as fronteiras tiradas da argvar | teste3_fonte_independente.R |  1 | 1 |  0 | ts11_v102_argvar_errada |
| confere_meta sem o is.data.frame do wald (auditoria, achado 1) | segunda_etapa.R |  1 | 1 |  0 | ts11_confere_meta |
| efeitos fixos sem o total (auditoria, achado 1) | segunda_etapa.R |  1 | 0 |  1 | ts11_confere_meta_novas |
| multinível sem o total (auditoria, achado 1) | segunda_etapa.R |  1 | 0 |  1 | ts11_confere_meta_novas |
| exploratório sem o total (auditoria, achado 1) | segunda_etapa.R |  1 | 0 |  1 | ts11_confere_meta_novas |
| decide_teste3 com dif < 1e-8, e não ≤ (auditoria, Nota 3) | segunda_etapa.R |  1 | 1 |  0 | ts11_decide_teste3 |
| decide_teste3 com controle ≥ 1e-8, e não > (auditoria, Nota 3) | segunda_etapa.R |  1 | 1 |  0 | ts11_decide_teste3 |
| confere_meta sem conferir os nomes e a ordem dos termos (chat, M2) | segunda_etapa.R |  1 | 1 |  0 | ts11_confere_meta |
| confere_meta sem exigir a estatística do Wald finita (chat, M2) | segunda_etapa.R |  1 | 1 |  0 | ts11_confere_meta |
| confere_meta sem exigir o Q total finito (chat, M2) | segunda_etapa.R |  1 | 1 |  0 | ts11_confere_meta |
| confere_meta com is.finite(Q) sem isTRUE (Q ausente passa) | segunda_etapa.R |  1 | 1 |  0 | ts11_confere_meta |
| confere_meta sem o tamanho da coluna gl (gl ausente passa) | segunda_etapa.R |  1 | 1 |  0 | ts11_confere_meta |
| confere_meta sem o tamanho da estatística (estatística ausente passa) | segunda_etapa.R |  1 | 1 |  0 | ts11_confere_meta |

- **Resultado:** todos os testes passam no original, e os 28 mutantes são mortos.

