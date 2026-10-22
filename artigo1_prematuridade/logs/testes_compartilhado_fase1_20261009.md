# Fase 1, A1: testes de `calcula_wj()` e `monta_offset()` e defeitos plantados

- **Gerado por:** `00_scripts/24_testes_compartilhado_fase1.R`, em 2026-10-09 21:11:59 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha). O script não lê a base.
- **Arquivos testados (SHA-256):**
  - `codigo_compartilhado/R/offset.R`: `55111b2cc510d7b1c7b78b7f84e99997c5202825e0353da70bab0b4bea290bae` (igual antes e depois dos defeitos: sim);
  - `codigo_compartilhado/tests/testa_offset.R`: `6a7a4d96994d3e4cb0f411617517cd22b38e693787a309821ba5791380ab7eec`;
  - `codigo_compartilhado/tests/roda_testes.R`: `40e7b537c500a29bfd852ac67a4fcde3fbd58128321f60fc438826360436768e`.
- **Testes:** só com dado sintético, em R base, sem `testthat` (desvio 42). Um teste passa se terminar sem erro e sem aviso.

## Funções

- **`calcula_wj(ig, semanas)`:** w_j = n_j / N_j, com n_j = nº com `ig` = j e N_j = nº com `ig` ≥ j, contados em toda a população recebida. Devolve `j`, `n_j`, `N_j` e `w_j`. Para se houver NA ou valor não inteiro em `ig`, ou N_j = 0.
- **`monta_offset(z_tj, w, semanas, periodo)`** (`periodo` obrigatório, NULL ou c(início, fim); desvio 48): Z_t = Σ_j Z_tj; W_t = Σ_j Z_tj·w_j / Z_t; `log_z`, `log_w`, `log_zw` = log(Σ_j Z_tj·w_j) (offset com γ = 1); `z_t_zero`.
  - Offset NA fora do `periodo` e com Z_t = 0; `w_t` NA com Z_t = 0. Nunca −Inf.
  - Para com erro se: `periodo` não for NULL nem c(início, fim) com início ≤ fim; semana de `semanas` sem w_j; w_j negativo; Z_tj negativo ou NA; dia do `periodo` com Z_t = 0 ou ausente (por unidade); com `periodo = NULL`, dia faltando no meio da grade de alguma unidade; Σ_j Z_tj·w_j = 0 com Z_t > 0 num dia com offset (desvio 49).
  - Entrada esparsa (desvios 44, 48 e 49): a chave é `data` mais as demais colunas que não são `semana` nem `z`; semanas fora de `semanas` são ignoradas; com `periodo = NULL`, os dias de Z_t = 0 são marcados, e a grade tem de vir completa do primeiro ao último dia de cada unidade (quem chama inclui os dias sem célula com z = 0 e garante o intervalo).

## Bateria original: 21/21

| Teste | Resultado |
|---|---|
| `wj_conta_a_mao` | passou |
| `wj_denominador_na_populacao_inteira` | passou |
| `wj_erros` | passou |
| `offset_conta_a_mao` | passou |
| `offset_identidade_log` | passou |
| `offset_w_constante` | passou |
| `offset_uma_semana` | passou |
| `offset_ignora_semanas_fora` | passou |
| `erro_semana_sem_w` | passou |
| `erro_z_negativo` | passou |
| `erro_z_na` | passou |
| `erro_dia_zero_no_periodo` | passou |
| `erro_dia_ausente_com_periodo_null` | passou |
| `fora_do_periodo_na` | passou |
| `periodo_null_marca_zero` | passou |
| `chave_com_unidades` | passou |
| `periodo_sem_valor_padrao` | passou |
| `erro_soma_zw_zero` | passou |
| `z_t_zero_so_onde_z_e_zero` | passou |
| `erro_entradas_invalidas` | passou |
| `integracao_wj_offset` | passou |

## Defeitos plantados (cada um numa cópia; tem de derrubar pelo menos um teste)

| Defeito | Troca na cópia | Testes que falham | Quais |
|---|---|---|---|
| N_j com > em vez de ≥ | `N_j <- vapply(semanas, function(j) sum(ig >= j), numeric(1))` → `N_j <- vapply(semanas, function(j) sum(ig > j), numeric(1))` | 2 | wj_conta_a_mao, wj_denominador_na_populacao_inteira |
| W_t sem dividir por Z_t | `out$w_t <- ifelse(pos, s_zw / ifelse(pos, z_t, 1), NA_real_)` → `out$w_t <- ifelse(pos, s_zw, NA_real_)` | 6 | offset_conta_a_mao, offset_identidade_log, offset_w_constante, offset_uma_semana, chave_com_unidades, integracao_wj_offset |
| semana 36 fora da soma | `dentro <- as.integer(z_tj$semana) %in% semanas` → `dentro <- as.integer(z_tj$semana) %in% setdiff(semanas, 36L)` | 3 | offset_conta_a_mao, offset_uma_semana, integracao_wj_offset |

- **Resultado:** bateria original passa inteira e os 3 defeitos são detectados.

`versao()` no fim: 4443971b.
