# Fase 2, Parte B, passo 2: testes de novo antes da tag `ajusta_dlnm-v1.0`

- **Gerado por:** `00_scripts/37_testes_tag_fase2B.R`, em 2026-10-10 17:52:39 -03. Rodada `20261010`. `versao()` no início = 4443971b (o fim está na última linha). Nada da base foi lido.
- **Ambiente:** R 4.5.1; dlnm 2.4.10; gnm 1.1.5. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib`. Semente 20261001, em série.
- **Commit no disco:** `caf5022f9a655877d8e3931dd3d02d7dce429fe5` (caf5022 Fase 2 do Artigo 1, Parte A: ajusta_dlnm(), testes sinteticos, diagnostico do offset e dupla auditoria (sem modelo de desfecho real)), o da Parte A; `codigo_compartilhado/` igual a ele (`git diff` vazio). Antes de rodar, nada pendente em `artigo1_prematuridade/` nem em `codigo_compartilhado/` (desvio 60), fora este script, ainda sem commit.
- **Arquivos (SHA-256), conferidos contra o testado** (função e testes dela: log do 31; `offset.R` e `testa_offset.R`: log da Fase 1):
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009`;
  - `codigo_compartilhado/R/offset.R`: `55111b2cc510d7b1c7b78b7f84e99997c5202825e0353da70bab0b4bea290bae`;
  - `codigo_compartilhado/tests/gera_sintetico.R`: `d53bb35d65cd350d26b5b55cd33c5fa393b26d41c34434f01195f82a2b3f5642`;
  - `codigo_compartilhado/tests/testa_ajusta_dlnm.R`: `bea75cc35c987e09b8b339eb20772e7fccd5234c7284a127b4e6e59dfafe5941`;
  - `codigo_compartilhado/tests/testa_ajusta_dlnm_mc.R`: `a89c00501931c9251b40fd71f62907142e61b4a734834b2ac659581c754303d7`;
  - `codigo_compartilhado/tests/testa_offset.R`: `6a7a4d96994d3e4cb0f411617517cd22b38e693787a309821ba5791380ab7eec`;
  - `codigo_compartilhado/tests/roda_testes.R`: `40e7b537c500a29bfd852ac67a4fcde3fbd58128321f60fc438826360436768e`;

## Resultado: 19/20 testes da `ajusta_dlnm()` e 21/21 do `offset.R`

| Teste | Resultado | Mesmo resultado do log de referência |
|---|---|---|
| `t01_equivalencia_eliminate` | passou | sim |
| `t02_estratos_vazios` | passou | sim |
| `t03_aquecimento` | passou | sim |
| `t04_group` | passou | sim |
| `t08a_falha_capturada` | passou | sim |
| `t08b_especificacao_fallback` | passou | sim |
| `t09a_pacf_por_unidade` | passou | sim |
| `t09b_pacf_ar1_e_ruido_branco` | passou | sim |
| `t09c_pacf_janela_com_lacuna` | passou | sim |
| `t08c_ramos_de_falha_com_stub` | passou | sim |
| `t15_intercepto_e_unidade_pequena` | passou | sim |
| `t16_offset_nao_finito_e_contagens` | passou | sim |
| `t10_cen` | passou | sim |
| `t12_spec_rejeita_nk_e_confere_nos` | passou | sim |
| `t13_offsets_e_gama` | passou | sim |
| `t14_dia_faltando_e_sigilo` | passou | sim |
| `t05_recuperacao_contagem_alta` | passou | sim |
| `t05b_recuperacao_contagem_baixa` | FALHOU: cobertura 0.985 fora de 0,92–0,98 | sim |
| `t06_nulo` | passou | sim |
| `t07_offset` | passou | sim |
| `wj_conta_a_mao` | passou | sim |
| `wj_denominador_na_populacao_inteira` | passou | sim |
| `wj_erros` | passou | sim |
| `offset_conta_a_mao` | passou | sim |
| `offset_identidade_log` | passou | sim |
| `offset_w_constante` | passou | sim |
| `offset_uma_semana` | passou | sim |
| `offset_ignora_semanas_fora` | passou | sim |
| `erro_semana_sem_w` | passou | sim |
| `erro_z_negativo` | passou | sim |
| `erro_z_na` | passou | sim |
| `erro_dia_zero_no_periodo` | passou | sim |
| `erro_dia_ausente_com_periodo_null` | passou | sim |
| `fora_do_periodo_na` | passou | sim |
| `periodo_null_marca_zero` | passou | sim |
| `chave_com_unidades` | passou | sim |
| `periodo_sem_valor_padrao` | passou | sim |
| `erro_soma_zw_zero` | passou | sim |
| `z_t_zero_so_onde_z_e_zero` | passou | sim |
| `erro_entradas_invalidas` | passou | sim |
| `integracao_wj_offset` | passou | sim |

- **Coberturas de Monte Carlo** (5, 5b e 6): 0,965 (EP 0,0130; IC Wilson [0,930; 0,983]); 0,985 (EP 0,0086; IC Wilson [0,957; 0,995]); 0,960 (EP 0,0139; IC Wilson [0,923; 0,980]); iguais às do log do 31: sim. Viés do `nenhum` no teste 7: 0,0959; igual: sim.
- **Falhas:** `t05b_recuperacao_contagem_baixa` — a falha conhecida do 5b, com a mesma mensagem (desvio 61); o critério "n/n" do passo 2 da Parte B não é atingido por causa dela.
- **Conclusão:** o código no disco é o testado e auditado na Parte A, e os testes dão o mesmo resultado por teste e as mesmas coberturas do log do 31 (e o mesmo resultado da Fase 1 no offset). A tag depende do [ok] de Guilherme, que decide sobre o n/n com a falha conhecida.

`versao()` no fim: 4443971b.
