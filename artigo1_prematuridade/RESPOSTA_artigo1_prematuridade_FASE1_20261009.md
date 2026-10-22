# Artigo 1: prematuridade. Fase 1: séries, offset e funções compartilhadas (sem modelo)

**Para:** chat do Artigo 1 (prematuridade), via Guilherme.

**Data:** 09/10/2026.

**Base:** `4443971b`, somente leitura.

**Prompt:** Fase 1, v1.1, do chat do Artigo 1, com o plano aprovado por Guilherme (decisões nos desvios 40 a 45).

**Tag congelada:** `spec-v2.0.2-congelada-20261009` (objeto `9f92398978db61ca1006dcf5d1195a4adc6bd94c`, aponta para `86069e5a8d1d67d0b8e02c9a45d533f91644fcc4`), sem mudança.

## 1. Resumo

- **Conjuntos analíticos montados, fora do git, em `01_saidas/fase1/`:** série principal (122.746 linhas: 26 concentrações × 4.721 dias, de 2011-12-14 a 2024-11-15), série da case time series municipal (1.307.717 linhas, sem lacuna) e série de PTB espontâneo. O esquema da série principal é o contrato de entrada do `ajusta_dlnm()` (seção 4). Nenhum modelo foi ajustado.
- **Conferências da A6, todas as obrigatórias passaram** (conferido no log da A6): soma de PTB na janela principal igual à A5.2 nas 26 concentrações (total 1.378.030); Z_tj recomputado de `nascimentos()` igual ao `z_nv` da base (315 células); offset completo na janela de evento possível; todas as semanas de 22 a 36 em todos os dias da janela principal; calendário e referências de exposição iguais à base e à A5.3; identidade do espontâneo sem divergência.
- **Funções compartilhadas** `calcula_wj()` e `monta_offset()`: bateria sintética 21/21; os 3 defeitos plantados derrubam 2, 6 e 3 testes.
- **Dupla auditoria:** autoauditoria 54 de 54 iguais, com código diferente. A auditoria independente achou 12 pontos, um deles bloqueante de sigilo: o desvio 46 publicava uma contagem de 1 a 9. Foi corrigido antes do commit, e a cadeia rodou de novo com as correções (desvios 46 a 48). A reauditoria das correções achou 12 pontos novos, todos tratados antes do commit (desvio 49), e a cadeia rodou pela terceira vez, com dados idênticos byte a byte aos da segunda. **Dois incidentes da sessão, registrados:** a contagem do nº 46 saiu também numa mensagem ao Guilherme e no stdout (desvio 47; não tem volta); e, na 3ª rodada, cópias dos RDS e CSV ficaram menos de um minuto fora da Forja, no scratchpad do Mac Mini, antes de voltarem (desvio 50).
- **Para o chat avaliar:** (a) o DP intra-estrato de `log_w` ficou acima da previsão da §3.1 em São Paulo (0,0155, previsto ~0,007) e acima em Sorocaba (0,0265, previsto ~0,022); (b) o w_j é crescente de 22 a 36 em 20 de 26 concentrações; (c) o PTB com início ignorado é alto em algumas concentrações (2013–2023; as três maiores: Goiânia 20,9%, Brasília 16,4%, Curitiba 15,6%), o que pesa na versão (ii) do espontâneo. Detalhes na seção 5 e nas observações.

## 2. A0: linhas novas do log de desvios

**Linha 5 do cabeçalho**, trocada como pede a A0.1 (a única linha antiga alterada):

  - `decisoes_metodo_20261008.md` (Revisão 2 final), SHA-256 `62afa891f123da1e84bc71def238ccbb321681b83872eb2c267eac0e37cf030f`. Até 09/10/2026, a referência era `20fc42e4…` (desvio nº 37).

**Linhas 37 a 39:**

| # | Data | Etapa | Referência | O que divergiu | Causa | Efeito nos resultados | Decisão | Evidência |
|---|---|---|---|---|---|---|---|---|
| 37 | 2026-10-09 | Fase 1, A0 | Prompt da Fase 1, A0.1; decisão do chat do Artigo 1 de 09/10/2026; auditoria da Parte B, achado 6 | A linha 5 do cabeçalho deste log passou a citar as decisões na Revisão 2 final (`62afa891f123da1e84bc71def238ccbb321681b83872eb2c267eac0e37cf030f`), com a nota "Até 09/10/2026, a referência era `20fc42e4…`". É a única linha antiga alterada; o resto só recebe acréscimos | O cabeçalho citava a versão substituída ao lado da tag que congela a Revisão 2 (nº 30 e 36) | Nenhum | Decisão do chat do Artigo 1 | Linha 5 deste log |
| 38 | 2026-10-09 | Fase 1, A0 | Prompt da Fase 1, A0.2 e A0.4; desvios nº 35 e 36 (a) | **Encerramento do nº 35.** A API de eventos do GitHub não lista nada deste repositório, nem os pushes da `main`: deu 0 eventos em todas as consultas, a última às 2026-10-09T21:40:32Z. A prova de horário no servidor é o `branch_creation` de `refs/heads/main` em `86069e5a8d1d67d0b8e02c9a45d533f91644fcc4`, às 2026-10-09T19:20:11Z, no log de atividade (`GET /repos/guilcoel/artigos_perinatais_clima/activity`). A consulta em segundo plano foi encerrada às 21:40Z | A API de eventos não registra este repositório | Nenhum | Desvio nº 35 encerrado, por decisão do chat do Artigo 1 | `logs/congelamento_spec.md` (adendo e encerramento); log de atividade do GitHub |
| 39 | 2026-10-09 | Fase 1, A0 | Prompt da Fase 1, A0.3; desvios nº 34 e 36 (b) | A reescrita do `CLAUDE.md` do artigo (5 linhas, no commit `ec22aca`) foi ratificada pelo chat do Artigo 1 em 09/10/2026 | Ela tinha sido feita sem [ok] prévio | Nenhum | Desvio nº 36 (b) ratificado | Prompt da Fase 1, A0.3 |

**A0.4:** a consulta ao `CreateEvent` em segundo plano foi encerrada às 21:40Z (desvio 38).

**Commit separado da A0:** `41ca2f6`, local, antes de qualquer script da fase (desvio 41).

## 3. A1: funções, testes e defeitos plantados

### Funções

- **`calcula_wj(ig, semanas)`:** w_j = n_j / N_j, com n_j = nº com `ig` = j e N_j = nº com `ig` ≥ j, contados em toda a população recebida. Devolve `j`, `n_j`, `N_j` e `w_j`. Para se houver NA ou valor não inteiro em `ig`, ou N_j = 0.
- **`monta_offset(z_tj, w, semanas, periodo)`** (`periodo` obrigatório, NULL ou c(início, fim); desvio 48): Z_t = Σ_j Z_tj; W_t = Σ_j Z_tj·w_j / Z_t; `log_z`, `log_w`, `log_zw` = log(Σ_j Z_tj·w_j) (offset com γ = 1); `z_t_zero`.
  - Offset NA fora do `periodo` e com Z_t = 0; `w_t` NA com Z_t = 0. Nunca −Inf.
  - Para com erro se: `periodo` não for NULL nem c(início, fim) com início ≤ fim; semana de `semanas` sem w_j; w_j negativo; Z_tj negativo ou NA; dia do `periodo` com Z_t = 0 ou ausente (por unidade); com `periodo = NULL`, dia faltando no meio da grade de alguma unidade; Σ_j Z_tj·w_j = 0 com Z_t > 0 num dia com offset (desvio 49).
  - Entrada esparsa (desvios 44, 48 e 49): a chave é `data` mais as demais colunas que não são `semana` nem `z`; semanas fora de `semanas` são ignoradas; com `periodo = NULL`, os dias de Z_t = 0 são marcados, e a grade tem de vir completa do primeiro ao último dia de cada unidade (quem chama inclui os dias sem célula com z = 0 e garante o intervalo).

### Bateria original: 21/21

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

### Defeitos plantados (cada um numa cópia; tem de derrubar pelo menos um teste)

| Defeito | Troca na cópia | Testes que falham | Quais |
|---|---|---|---|
| N_j com > em vez de ≥ | `N_j <- vapply(semanas, function(j) sum(ig >= j), numeric(1))` → `N_j <- vapply(semanas, function(j) sum(ig > j), numeric(1))` | 2 | wj_conta_a_mao, wj_denominador_na_populacao_inteira |
| W_t sem dividir por Z_t | `out$w_t <- ifelse(pos, s_zw / ifelse(pos, z_t, 1), NA_real_)` → `out$w_t <- ifelse(pos, s_zw, NA_real_)` | 6 | offset_conta_a_mao, offset_identidade_log, offset_w_constante, offset_uma_semana, chave_com_unidades, integracao_wj_offset |
| semana 36 fora da soma | `dentro <- as.integer(z_tj$semana) %in% semanas` → `dentro <- as.integer(z_tj$semana) %in% setdiff(semanas, 36L)` | 3 | offset_conta_a_mao, offset_uma_semana, integracao_wj_offset |

- **Resultado:** bateria original passa inteira e os 3 defeitos são detectados.

`versao()` no fim: 4443971b.
Os testes estão em `codigo_compartilhado/tests/` e foram escritos em R base, porque o `testthat` não está no `renv.lock` (desvio 42).

## 4. Esquema do conjunto analítico principal: contrato de entrada do `ajusta_dlnm()`


Uma linha por `recorte_principal` × `data`, ordenada por concentração e data.

| # | Coluna | Tipo | Conteúdo |
|---|---|---|---|
|  1 | `recorte_principal` | character | concentração (código IBGE de 7 dígitos) |
|  2 | `data` | Date | dia |
|  3 | `ptb` | integer | PTB (22–36 semanas), coorte fixa 22 |
|  4 | `ptb_extremo` | integer | ≤ 27 semanas |
|  5 | `ptb_muito` | integer | 28–31 semanas |
|  6 | `ptb_moderado_tardio` | integer | 32–36 semanas |
|  7 | `nv_unicos` | integer | NV únicos 22–42, coorte fixa 22 |
|  8 | `z_t` | numeric | Σ_{j=22}^{36} z_nv |
|  9 | `w_t` | numeric | Σ_j Z_tj·w_j / Z_t |
| 10 | `log_z` | numeric | log(Z_t); offset |
| 11 | `log_w` | numeric | log(W_t); termo γ·log(W_t) |
| 12 | `log_zw` | numeric | log(Σ_j Z_tj·w_j) = offset com γ = 1 |
| 13 | `z_t_zero` | logical | Z_t = 0 (TRUE de 2011-12-14 a 2011-12-31) |
| 14 | `tmean_nucleo` | numeric | exposição principal (°C) |
| 15 | `tmean_rm_nv` | numeric | sensibilidade de nível (°C) |
| 16 | `rh_nucleo` | numeric | umidade relativa (%) |
| 17 | `pm25_local_nucleo` | numeric | PM2.5 local, variante principal (µg/m³) |
| 18 | `pm25_local_zero_na_nucleo` | numeric | PM2.5 local, zero = NA (variante secundária) |
| 19 | `dia_semana` | factor (seg, ter, qua, qui, sex, sab, dom) | dia da semana (calendario()) |
| 20 | `feriado_nacional` | integer | feriado nacional por lei federal (0/1) |
| 21 | `carnaval` | integer | segunda e terça de carnaval (0/1) |
| 22 | `moveis` | integer | quarta de cinzas, sexta da paixão ou corpus christi (0/1) |
| 23 | `ano` | integer | ano (calendario()) |
| 24 | `mes` | integer | mês (calendario()) |
| 25 | `estrato` | character | concentração_ano_mês (eliminate do gnm) |
| 26 | `janela_principal` | logical | 2012-04-14 a 2024-08-06 |
| 27 | `janela_evento_possivel` | logical | 2012-01-04 a 2024-11-15 |

**Notas do contrato:**

- **Dias de modelo:** `janela_principal` (principal) ou `janela_evento_possivel` (sensibilidade); os 7, 14 ou 21 dias anteriores servem de aquecimento da cross-basis.
- **Offset:** `log_z` + γ·`log_w` (γ estimado) ou `log_zw` (γ = 1). É NA fora da janela de evento possível.
- **Contagens:** NA de 2011-12-14 a 2011-12-31 (contagens de 2011 que dependem de IG, na base). Nesses dias, `z_t` = 0 e `z_t_zero` = TRUE (desvio 48).
- **Estrato e calendário:** `estrato` = `recorte_principal`_ano_mês, para o `eliminate`; `dia_semana` é fator com 7 níveis, segunda primeiro.
- **Séries das sensibilidades:** a A3 e a A4 têm esquema próprio, nos logs `serie_municipal_fase1_*.md` e `ptb_espontaneo_fase1_*.md`. Na A3, quem decide o ajuste é a `linha_modelo`.

**A5: o que fica para a Fase 4** (registrado no log do 20):


- a §3.5 redefinida (decisões §12, versões (i) e (ii), com coorte fixa e Z_t próprios);
- o termo precoce (desvio 4): a janela vai até 2024-11-19, depois do fim do período gravado, e usa Z nas semanas 37–38; a Fase 4 extrai de novo;
- Tmax, Tmin e temperatura aparente (§1.1 e §10.2), de `clima_municipal()`;
- `z_fetal` em Z;
- w_j por ano;
- 2011 por `GESTACAO`;
- os feriados locais.

`versao()` no fim: 4443971b.
## 5. Conferências da A6, completas

Transcritas de `logs/conferencias_fase1_20261009.md`. Só agregados por concentração × janela, concentração × ano ou mais grossos.

### 1. Cobertura

- **Dias na janela principal:** 26 de 26 concentrações com 4.498 dias (mínimo 4.498, máximo 4.498).
- **NA nas colunas de modelo, na janela principal mais os 7 dias de aquecimento** (2012-04-07 a 2024-08-06), por concentração: a tabela dá o total nas 26 e quantas concentrações têm algum NA na coluna. Esperado: 0 em tudo, menos `pm25_local_zero_na_nucleo`.

| Coluna | NA (26 somadas) | Concentrações com NA | Esperado |
|---|---|---|---|
| `ptb` | 0 | 0/26 | 0 |
| `ptb_extremo` | 0 | 0/26 | 0 |
| `ptb_muito` | 0 | 0/26 | 0 |
| `ptb_moderado_tardio` | 0 | 0/26 | 0 |
| `nv_unicos` | 0 | 0/26 | 0 |
| `z_t` | 0 | 0/26 | 0 |
| `w_t` | 0 | 0/26 | 0 |
| `log_z` | 0 | 0/26 | 0 |
| `log_w` | 0 | 0/26 | 0 |
| `log_zw` | 0 | 0/26 | 0 |
| `tmean_nucleo` | 0 | 0/26 | 0 |
| `tmean_rm_nv` | 0 | 0/26 | 0 |
| `rh_nucleo` | 0 | 0/26 | 0 |
| `pm25_local_nucleo` | 0 | 0/26 | 0 |
| `pm25_local_zero_na_nucleo` | 1.605 | 21/26 | NA permitido (variante secundária, caso completo) |
| `dia_semana` | 0 | 0/26 | 0 |
| `feriado_nacional` | 0 | 0/26 | 0 |
| `carnaval` | 0 | 0/26 | 0 |
| `moveis` | 0 | 0/26 | 0 |
| `estrato` | 0 | 0/26 | 0 |

- **`pm25_local_zero_na_nucleo`** (só exposição): NA em 21 concentrações; por concentração: Manaus 3; Belém/PA 2; São Luís/MA 1; Teresina/PI 179; Fortaleza/CE 1; Natal/RN 21; Recife/PE 1; Maceió/AL 9; Aracaju/SE 10; Salvador/BA 15; Belo Horizonte/MG 80; Vitória/ES 74; São José dos Campos/SP 13; Sorocaba/SP 4; Curitiba/PR 72; Florianópolis/SC 3; Porto Alegre/RS 49; Campo Grande 343; Cuiabá/MT 79; Goiânia/GO 324; Brasília/DF 322.
- **Janela de evento possível mais 21 dias de aquecimento** (2011-12-14 a 2024-11-15): NA na `tmean_nucleo` = 0 (esperado 0).

### 2. Totais de PTB na janela principal contra a A5.2 congelada

- **Resultado:** 26 de 26 iguais; total das 26 = 1.378.030 (A5.2: 1.378.030). Tem de bater exatamente: bate.

| Concentração | Soma na série (A2) | "Na janela" (A5.2) | Igual |
|---|---|---|---|
| São Paulo/SP | 335.025 | 335.025 | sim |
| Rio de Janeiro/RJ | 182.818 | 182.818 | sim |
| Belo Horizonte/MG | 74.772 | 74.772 | sim |
| Brasília/DF | 68.110 | 68.110 | sim |
| Recife/PE | 66.373 | 66.373 | sim |
| Porto Alegre/RS | 58.605 | 58.605 | sim |
| Fortaleza/CE | 62.530 | 62.530 | sim |
| Curitiba/PR | 45.773 | 45.773 | sim |
| Salvador/BA | 49.778 | 49.778 | sim |
| Goiânia/GO | 42.244 | 42.244 | sim |
| Campinas/SP | 33.354 | 33.354 | sim |
| Manaus | 45.564 | 45.564 | sim |
| Belém/PA | 41.518 | 41.518 | sim |
| Vitória/ES | 27.150 | 27.150 | sim |
| Baixada Santista/SP | 25.520 | 25.520 | sim |
| São José dos Campos/SP | 26.377 | 26.377 | sim |
| São Luís/MA | 29.093 | 29.093 | sim |
| Natal/RN | 25.665 | 25.665 | sim |
| Maceió/AL | 22.492 | 22.492 | sim |
| Florianópolis/SC | 13.943 | 13.943 | sim |
| João Pessoa/PB | 19.500 | 19.500 | sim |
| Teresina/PI | 20.111 | 20.111 | sim |
| Aracaju/SE | 16.618 | 16.618 | sim |
| Cuiabá/MT | 16.986 | 16.986 | sim |
| Sorocaba/SP | 13.393 | 13.393 | sim |
| Campo Grande | 14.718 | 14.718 | sim |

### 3. Offset

- **Janela de evento possível** (2012-01-04 a 2024-11-15): dias-concentração com Z_t ≤ 0 ou offset NA = 0 (esperado 0).
- **Janela principal:** dias-concentração em que falta alguma semana de 22 a 36 no `gestacoes_em_risco` = 0 (esperado 0; conferido nos 26 × 4.498 dias).
- **DP de `log_w` dentro dos estratos concentração × ano × mês da janela principal** (média dos DP dos 149 estratos de cada concentração). Previsão da especificação (§3.1): cerca de 0,022 numa concentração do tamanho de Sorocaba e 0,007 numa do tamanho de São Paulo. Observado: **Sorocaba 0,0265; São Paulo 0,0155**; faixa nas 26 de 0,0143 (Rio de Janeiro/RJ) a 0,0291 (Maceió/AL). Checagem de plausibilidade, não critério de parada.
- Nenhum valor de um único dia (mínimo, máximo) é reportado (especificação §8).

| Concentração | Z_t médio na janela principal | DP médio de log_w intra-estrato |
|---|---|---|
| São Paulo/SP | 78.150 | 0,0155 |
| Rio de Janeiro/RJ | 41.338 | 0,0143 |
| Belo Horizonte/MG | 17.279 | 0,0157 |
| Brasília/DF | 14.964 | 0,0224 |
| Recife/PE | 14.199 | 0,0224 |
| Porto Alegre/RS | 13.073 | 0,0163 |
| Fortaleza/CE | 12.525 | 0,0207 |
| Curitiba/PR | 11.969 | 0,0150 |
| Salvador/BA | 11.846 | 0,0163 |
| Goiânia/GO | 9.265 | 0,0227 |
| Campinas/SP | 7.124 | 0,0201 |
| Manaus | 10.307 | 0,0159 |
| Belém/PA | 7.482 | 0,0231 |
| Vitória/ES | 6.939 | 0,0174 |
| Baixada Santista/SP | 5.741 | 0,0231 |
| São José dos Campos/SP | 5.396 | 0,0264 |
| São Luís/MA | 5.546 | 0,0290 |
| Natal/RN | 4.667 | 0,0272 |
| Maceió/AL | 4.757 | 0,0291 |
| Florianópolis/SC | 3.728 | 0,0243 |
| João Pessoa/PB | 4.546 | 0,0278 |
| Teresina/PI | 4.205 | 0,0257 |
| Aracaju/SE | 4.070 | 0,0230 |
| Cuiabá/MT | 4.027 | 0,0261 |
| Sorocaba/SP | 3.228 | 0,0265 |
| Campo Grande | 3.689 | 0,0250 |

### 4. Recomputação independente do Z_tj

- **População da base no `z_nv`:** `pop_ptb & coorte_fixa_22` (código da base `00_scripts/06d_gestacoes_em_risco.py`, linha 50, lido sem rodar; `DICIONARIO.md`: "gestações em curso que terminaram em NV único com IG 22–42", só da coorte fixa). `pop_ptb` = único com IG 22–42. É a mesma população do w_j (`unico`, `ga_sem` 22–42, `coorte_fixa_22`; o 20 conferiu linha a linha). Não houve motivo para parar.
- **Recomputação:** a partir de `nascimentos()`, pela regra da base (a gestação de início s = `dum_est` está na semana j no dia t quando ⌊(t − s)/7⌋ = j e o término é ≥ t), semanas 22 a 42, para São Paulo, Sorocaba e Florianópolis em 5 datas da janela principal sorteadas com `set.seed(20261001)`: 2012-09-29, 2013-01-24, 2013-02-21, 2018-11-06, 2023-09-09.
- **Resultado:** **igual**, em 315 células comparadas (3 concentrações × 5 datas × 21 semanas). Os valores não são mostrados.

### 5. w_j (risco condicional de parto na semana j)

- **Pares concentração × semana com n_j < 10:** 0 (de 390). Mínimo, mediana e máximo entre as concentrações usam só os pares com n_j ≥ 10 (desvio 40); nesta rodada, nenhum par ficou de fora.
- **26 somadas** (Σ n_j / Σ N_j): 0,00039 na semana 22 e 0,04281 na semana 36. Especificação (§3.1, distribuição agregada da Q8): cerca de 0,0004 e 0,0428.
- **w_j crescente de 22 a 36 semanas** (estritamente, em todos os passos): 20 de 26 concentrações. Não é critério de parada.
  - Não crescentes: Manaus, São Luís/MA, Aracaju/SE, Salvador/BA, Curitiba/PR, Florianópolis/SC.

| Semana | Mínimo (26) | Mediana (26) | Máximo (26) | Pares excluídos (n_j < 10) | 26 somadas |
|---|---|---|---|---|---|
| 22 | 0,00023 | 0,00037 | 0,00076 | 0 | 0,00039 |
| 23 | 0,00039 | 0,00051 | 0,00067 | 0 | 0,00051 |
| 24 | 0,00046 | 0,00071 | 0,00090 | 0 | 0,00072 |
| 25 | 0,00063 | 0,00082 | 0,00116 | 0 | 0,00085 |
| 26 | 0,00079 | 0,00108 | 0,00135 | 0 | 0,00109 |
| 27 | 0,00108 | 0,00127 | 0,00167 | 0 | 0,00129 |
| 28 | 0,00097 | 0,00155 | 0,00201 | 0 | 0,00162 |
| 29 | 0,00141 | 0,00175 | 0,00251 | 0 | 0,00181 |
| 30 | 0,00184 | 0,00260 | 0,00364 | 0 | 0,00263 |
| 31 | 0,00273 | 0,00337 | 0,00467 | 0 | 0,00336 |
| 32 | 0,00430 | 0,00524 | 0,00707 | 0 | 0,00538 |
| 33 | 0,00683 | 0,00792 | 0,01098 | 0 | 0,00796 |
| 34 | 0,01045 | 0,01362 | 0,01780 | 0 | 0,01359 |
| 35 | 0,01520 | 0,02256 | 0,02964 | 0 | 0,02214 |
| 36 | 0,03637 | 0,04296 | 0,05215 | 0 | 0,04281 |

### 6. Estratos (janela principal)

- **Concentração × ano × mês:** 3.874 estratos; sem nenhum PTB: 0 (esperado 0; seriam removidos no modelo).
- **Município × ano × mês (A3):** 277 municípios, 41.273 estratos; sem nenhum PTB: 3.428 (removidos no ajuste da case time series).

### 7. Calendário (janela principal, 4.498 dias; igual nas 26 concentrações)

| Item | Dias |
|---|---|
| dia_semana = seg | 643 |
| dia_semana = ter | 643 |
| dia_semana = qua | 642 |
| dia_semana = qui | 642 |
| dia_semana = sex | 642 |
| dia_semana = sab | 643 |
| dia_semana = dom | 643 |
| feriado_nacional | 98 |
| carnaval (segunda e terça) | 24 |
| moveis (quarta de cinzas, sexta da paixão, corpus christi) | 37 |

- **Origem:** todas as colunas de calendário da série (feriado, carnaval, móveis, ano e mês) conferidas contra o `calendario()` da base, por `data`, e o rótulo do dia da semana contra `format(data, "%u")` (1 = segunda) e contra o `calendario()`, nos 116.948 dias-concentração da janela principal: 0 divergências.

### 8. Referências de exposição (só exposição)

- **Igualdade com a A5.3 refeita** (A2.6; ano inteiro e novembro a março; 52 linhas; as 9 colunas existem nos dois arquivos, sem NA). Maior |diferença| por coluna: n_dias 0; p1 0; p10 0; p50 0; p75 0; p90 0; p99 0; media 0; amplitude_p99_p1 0 (tolerância 1e-12): igual.
- **Metapreditores** (§6): média e amplitude (p99 − p1) da `tmean_nucleo` diária de 2012-01-01 a 2024-12-31, °C.

| Concentração | Média (°C) | Amplitude p99 − p1 (°C) |
|---|---|---|
| São Paulo/SP | 21,16 | 15,06 |
| Rio de Janeiro/RJ | 24,28 | 13,51 |
| Belo Horizonte/MG | 22,80 | 11,37 |
| Brasília/DF | 22,79 | 9,16 |
| Recife/PE | 26,40 | 6,22 |
| Porto Alegre/RS | 20,95 | 20,73 |
| Fortaleza/CE | 28,04 | 5,07 |
| Curitiba/PR | 19,07 | 17,34 |
| Salvador/BA | 26,29 | 7,09 |
| Goiânia/GO | 25,05 | 10,19 |
| Campinas/SP | 22,14 | 14,30 |
| Manaus | 28,22 | 6,75 |
| Belém/PA | 28,21 | 4,50 |
| Vitória/ES | 25,16 | 10,31 |
| Baixada Santista/SP | 23,07 | 14,51 |
| São José dos Campos/SP | 21,11 | 13,30 |
| São Luís/MA | 28,15 | 5,22 |
| Natal/RN | 27,05 | 5,17 |
| Maceió/AL | 26,26 | 5,83 |
| Florianópolis/SC | 21,59 | 16,31 |
| João Pessoa/PB | 27,09 | 5,68 |
| Teresina/PI | 28,52 | 6,52 |
| Aracaju/SE | 27,00 | 6,05 |
| Cuiabá/MT | 26,88 | 15,07 |
| Sorocaba/SP | 22,10 | 15,02 |
| Campo Grande | 24,57 | 17,93 |

### 9. PTB espontâneo (A4; só anos inteiros de 2013 a 2023)

- **Identidade da A4** (espontâneo (i) + iniciado + ignorado = `ptb`, dia a dia): 0 divergências em 122.278 dias-concentração com `ptb` definido.
- **Por ano, 26 concentrações somadas** (% entre os PTB da população do `ptb`, pelo ano da data do parto), com a comparação da especificação ao lado: % de `sttrabpart` "9" ou vazio entre **todos os NV das 26 concentrações** (população da Q2a: `nascimentos()`, sem coorte e sem filtro de gravidez ou de IG, pelo `ano` do arquivo do SINASC; desvios 45 e 48). A especificação (§3.4) dá 8,9% em 2012 e 1,6% em 2024; aqui as pontas não entram, então a comparação é só de tendência.

| Ano | Espontâneo (i) | Iniciado | Ignorado | sttrabpart 9 ou vazio, todos os NV (Q2a) |
|---|---|---|---|---|
| 2013 | 44,5 | 46,5 | 9,0 | 6,7 |
| 2014 | 46,9 | 44,5 | 8,6 | 5,7 |
| 2015 | 48,5 | 43,7 | 7,8 | 5,4 |
| 2016 | 49,9 | 43,1 | 7,0 | 4,2 |
| 2017 | 51,3 | 43,0 | 5,8 | 4,1 |
| 2018 | 52,2 | 42,9 | 5,0 | 3,6 |
| 2019 | 52,9 | 43,1 | 3,9 | 3,0 |
| 2020 | 51,8 | 44,0 | 4,2 | 3,1 |
| 2021 | 50,6 | 44,6 | 4,7 | 3,4 |
| 2022 | 50,6 | 45,3 | 4,1 | 2,6 |
| 2023 | 49,9 | 46,8 | 3,3 | 1,9 |

- **Por concentração, 2013 a 2023 somados** (% entre os PTB). Categoria com menos de 10 casos sai como "<10 casos", com supressão complementar: 0 células mascaradas.

| Concentração | Espontâneo (i) | Iniciado | Ignorado |
|---|---|---|---|
| São Paulo/SP | 43,3 | 55,4 | 1,4 |
| Rio de Janeiro/RJ | 48,6 | 44,6 | 6,8 |
| Belo Horizonte/MG | 44,4 | 54,2 | 1,4 |
| Brasília/DF | 46,6 | 37,0 | 16,4 |
| Recife/PE | 58,8 | 39,1 | 2,1 |
| Porto Alegre/RS | 40,7 | 57,9 | 1,5 |
| Fortaleza/CE | 49,2 | 37,5 | 13,3 |
| Curitiba/PR | 40,3 | 44,1 | 15,6 |
| Salvador/BA | 50,0 | 41,0 | 8,9 |
| Goiânia/GO | 52,3 | 26,8 | 20,9 |
| Campinas/SP | 59,0 | 37,4 | 3,6 |
| Manaus | 73,3 | 17,0 | 9,8 |
| Belém/PA | 66,6 | 29,0 | 4,5 |
| Vitória/ES | 48,6 | 47,7 | 3,8 |
| Baixada Santista/SP | 46,5 | 50,6 | 3,0 |
| São José dos Campos/SP | 40,8 | 54,4 | 4,7 |
| São Luís/MA | 61,5 | 26,2 | 12,3 |
| Natal/RN | 47,1 | 44,7 | 8,2 |
| Maceió/AL | 65,8 | 28,7 | 5,5 |
| Florianópolis/SC | 55,4 | 41,2 | 3,4 |
| João Pessoa/PB | 62,5 | 32,5 | 5,1 |
| Teresina/PI | 80,8 | 13,0 | 6,2 |
| Aracaju/SE | 37,1 | 62,4 | 0,5 |
| Cuiabá/MT | 47,3 | 50,3 | 2,3 |
| Sorocaba/SP | 46,7 | 52,2 | 1,1 |
| Campo Grande | 72,0 | 27,4 | 0,6 |

### 10. Case time series municipal (A3)

- **Municípios:** 277.
- **Dias-município com Z_t > 0 na janela principal:** 1.245.946 (de 1.245.946 = 277 × 4.498).
- **Municípios sem nenhum PTB na janela principal:** 0.
- **Nós da `tmean_mun` agrupada:** só gravados (`01_saidas/fase1/nos_tmean_mun_concentracao.csv`), sem ir para o retorno.

### Resultado

- **Todas as conferências obrigatórias passaram** (itens 1, 2, 3, 4, 6, 7, 8 e 9; os itens 3 (DP), 5 e 10 são descritivos).
- **Valores em formato de máquina** (entrada da autoauditoria; fora do git): `01_saidas/fase1/conferencias_valores.csv`, SHA-256 `f2912b6f08a15977fba35b1e442d6d9813fac7fb39ecacc393da153dc64f8c1b`.

`versao()` no fim: 4443971b.
### Observações para o chat

- **DP de `log_w` (item 3):** São Paulo (0,0155; previsto ~0,007 na §3.1) fica acima da previsão, e Sorocaba (0,0265; previsto ~0,022) fica acima. Se a variação fosse só ruído de composição, a razão Sorocaba/São Paulo seria de cerca de 4,92 (raiz da razão dos Z_t médios); a especificação prevê 3,14 e o observado é 1,71. Há um componente que não cai com o tamanho da concentração.
  - Hipóteses do auditor, não verificadas: quedas de nascimentos em feriados, herdadas por s = parto − (7·IG + 3); preferência de registro da IG que varia no tempo; forma real da sazonalidade das concepções. O dia da semana dos partos se anula nas semanas completas.
  - É checagem de plausibilidade, sem critério de parada. Sugestão: antes da Fase 2, um diagnóstico agregado na Forja (parte da variância de `log_w` no estrato explicada por tendência; autocorrelação nos lags 7 e 365), sem desfecho.
- **w_j (item 5):** é crescente de 22 a 36 em 20 de 26 concentrações; nas outras há inversões locais. Não é critério de parada. Pode refletir preferência de registro de algumas semanas (§3.1).
- **PTB espontâneo (item 9):** o % de ignorados cai no tempo, como a especificação previa. O nível por concentração varia muito, o que afeta a distância entre as versões (i) e (ii).

## 6. Dupla auditoria

### Autoauditoria (`25_autoauditoria_fase1.R`)

- **Método:** cada número dos logs da Fase 1 foi recalculado a partir dos arquivos de origem (base, RDS e CSV da fase), com código diferente do que o gerou, e comparado com o valor registrado (`01_saidas/fase1/conferencias_valores.csv`, gravado pelo 23 com os mesmos números do log da A6) ou com o texto dos logs do 20, 21, 22 e 24.
- **Código diferente:** `rowsum`, `aggregate`, `colSums` e `table` no lugar de `tapply`; w_j por `cumsum` de tabela concentração × IG, sem `calcula_wj()`; offset recalculado direto do `gestacoes_em_risco`, sem `monta_offset()`; classificação do espontâneo por códigos combinados e expressões regulares; Z_tj por intervalo de datas [s + 7j, s + 7j + 6] com término ≥ t; calendário contado direto no `calendario()`; média e amplitude direto da `serie_diaria`.
- **Tolerâncias:** contagens, exatas; razões e logaritmos, 1e-12 a 1e-15; médias e percentuais, 1e-9.

#### Resultado: 54 de 54 conferências iguais

| Item | Conferência | N | Maior dif. | Resultado |
|---|---|---|---|---|
| A1 | bateria n/n no log do 24 |      1 | — | igual |
| A1 | testes que passam (re-rodados) = total de testes |      1 | 0 | igual |
| A2 | w_j por concentração × semana (cumsum de tabela × CSV do 20) |    390 | 4.86e-17 | igual |
| A2 | NV da população do w_j, nº de linhas e pares com n_j < 10 no log do 20 |      3 | — | igual |
| A2 | linhas da série principal = 26 × 4.721 |      1 | 0 | igual |
| offset | z_t na janela de evento possível (rowsum × RDS) | 122200 | 0 | igual |
| offset | log_w (Σ Z·w / Z, recalculado × RDS) | 122200 | 2.66e-15 | igual |
| offset | log_zw (recalculado × RDS) | 122200 | 2.22e-15 | igual |
| offset | offset NA fora da janela de evento possível |      1 | 0 | igual |
| A6.1 | NA nas 20 colunas de modelo (colSums × valores do 23) |     20 | 0 | igual |
| A6.1 | dias na janela principal: mínimo e máximo entre as 26 (table) = 4.498 |      3 | 0 | igual |
| A6.1 | NA na tmean_nucleo de 2011-12-14 a 2024-11-15 |      1 | 0 | igual |
| A6.3 | dias da janela de evento possível com Z_t ≤ 0 ou offset NA |      1 | 0 | igual |
| A6.3 | dias da janela principal sem alguma semana de 22 a 36 (rowsum) |      1 | 0 | igual |
| A6.2 | PTB na janela principal por concentração (rowsum × valores do 23) |     26 | 0 | igual |
| A6.2 | PTB na janela principal × A5.2 congelada |     26 | 0 | igual |
| A6.2 | os 26 totais e o total das 26 no texto do log da A6 |     27 | — | igual |
| A6.3 | Z_t médio por concentração (aggregate × valores do 23) |     26 | 4.37e-11 | igual |
| A6.3 | DP médio intra-estrato de log_w (aggregate × valores do 23) |     26 | 4.86e-17 | igual |
| A6.3 | DP de Sorocaba e de São Paulo no texto do log |      2 | — | igual |
| A6.3 | Z_t médio e DP das 26 concentrações na tabela do log |     26 | — | igual |
| A6.4 | células comparadas e diferentes (intervalo de datas × base) |      2 | 0 | igual |
| A6.5 | w_j com as 26 somadas (cumsum × valores do 23) |     15 | 4.16e-17 | igual |
| A6.5 | mínimo, mediana e máximo entre as concentrações, só n_j ≥ 10 (apply × valores do 23) |     45 | 4.86e-17 | igual |
| A6.5 | pares com n_j < 10 e concentrações com w_j crescente |      2 | 0 | igual |
| A6.6 | estratos e estratos sem PTB (principal e municipal) |      4 | 0 | igual |
| A6.7 | dias por dia da semana (format(data, "%u")), feriados, carnaval e móveis (calendario() direto × valores do 23) |     10 | 0 | igual |
| A6.8 | média e amplitude p99 − p1 da tmean_nucleo (serie_diaria direto × valores do 23) |     52 | 4.62e-14 | igual |
| A6.8 / A2.6 | 9 valores × 2 períodos × 26 recalculados da serie_diaria × A5.3 refeita |    468 | 4.97e-14 | igual |
| A6.8 / A2.6 | 9 valores × 2 períodos × 26 recalculados da serie_diaria × referencias_exposicao.csv do 20 |    468 | 4.97e-14 | igual |
| A6.8 | média e amplitude das 26 na tabela do log |     26 | — | igual |
| A6.9 | % espontâneo, iniciado e ignorado por ano, 2013–2023 (códigos combinados × valores do 23) |     33 | 4.97e-14 | igual |
| A6.9 | % por concentração, 2013–2023 (códigos combinados × valores do 23) |     78 | 4.97e-14 | igual |
| A6.9 | células mascaradas na tabela por concentração (regra reimplementada × 23) |      1 | 0 | igual |
| A6.9 | % de sttrabpart 9 ou vazio entre todos os NV, por ano (table × valores do 23) |     11 | 5.33e-15 | igual |
| A6.9 / A4 | identidade espontâneo (i) + iniciado + ignorado = ptb (divergências) |      1 | 0 | igual |
| A4 | identidade no log do 22 |      1 | — | igual |
| A6.10 | municípios, dias-município com Z_t > 0 e municípios sem PTB (janela principal) |      3 | 0 | igual |
| A3 | linhas da série municipal no log do 21 |      1 | — | igual |
| A3 | dias-município sem célula nas semanas 22 a 36, de 2012-01-01 a 2024-11-15 (base × log do 21) |      1 | 0 | igual |
| A3 | dias-município de 2011-12-14 a 2011-12-31 (277 × 18 × log do 21) |      1 | 0 | igual |
| A3 | dias-município com z_t_zero no RDS = 2011 + sem célula nas semanas 22–36 + com célula só por z_fetal |      1 | 0 | igual |
| A3 | offset NA exatamente nos dias de Z_t = 0 (todo o período gravado) |      1 | 0 | igual |
| A3 | dias só com z_fetal mascarados no log do 21 |      1 | — | igual |
| A6.7 | rótulo do dia da semana × format(data, "%u"), dia a dia, em todas as linhas da série principal (divergências) |      1 | 0 | igual |
| A6.1 | NA e concentrações com NA, por coluna, na tabela do log |     20 | — | igual |
| A6.1 | NA de PM2.5 (zero = NA) por concentração no log |      1 | — | igual |
| A6.3 | estratos por concentração na janela principal (todas iguais) |      1 | 0 | igual |
| A6.3 | nº de estratos por concentração no texto do log |      1 | — | igual |
| A6.4 | as 5 datas sorteadas no texto do log |      1 | — | igual |
| A6.5 | concentrações com w_j não crescente no texto do log |      1 | — | igual |
| A3 | linha_modelo no log do 21 |      1 | — | igual |
| A1 | testes derrubados por cada defeito (re-rodados) na tabela do log do 24 |      3 | — | igual |
| A6 | SHA-256 do conferencias_valores.csv no log da A6 |      1 | — | igual |

`versao()` no fim: 4443971b.
### Auditoria independente

Transcrita de `logs/auditoria_fase1_20261009.md`.


- **Quem auditou:** subagente em contexto limpo.
- **O que leu:**
  - os scripts 20 a 25;
  - o código e os testes compartilhados;
  - os logs `_fase1_` e o log de desvios;
  - a transcrição do prompt da Fase 1;
  - as seções pedidas da especificação e das decisões, em `spec/`;
  - a RESPOSTA refeita da Fase 0, em `spec/`;
  - `09_acesso/` da base.
- **Proibições respeitadas:**
  - não abriu `.parquet`, `.rds`, `.dbc` nem os CSV de `01_saidas/`;
  - não rodou script que lê a base;
  - só rodou R com dado sintético;
  - não alterou o repositório.
- **Veredito:** os conjuntos analíticos estão corretos onde importa: janelas, w_j, W_t, offset, estratos, calendário, classificação do espontâneo e totais da A5.2.
- **Achados:** 12. Um bloqueante de sigilo, 4 para corrigir e 7 notas.

| # | Achado | Gravidade | Reprodução própria | Correção |
|---|---|---|---|---|
| 1 | O desvio 46 publicava, sem "<10", uma contagem de 1 a 9 (dias-município com célula só por `z_fetal`) e os dois totais que a derivam. O 25 imprimia a mesma contagem no stdout | bloqueante (sigilo) | Leitura da linha do nº 46 e da linha 200 do 25 | O nº 46 foi mascarado antes do commit ("<10", sem os totais), e o 25 não imprime mais o número; registrado no desvio 47. A contagem saiu também numa mensagem da sessão ao Guilherme e no stdout; isso não tem volta e fica registrado no desvio 47 |
| 2 | A comparação com a A5.3, que é critério de parada, passaria calada se faltasse uma coluna no CSV: `NULL` → `max(abs(...))` = −Inf → `all(<= 1e-12)` dá TRUE. O 25 não refazia a A5.3 | corrigir | Sintético: com coluna ausente, `max|dif|` = `-Inf` e `all(d <= 1e-12)` = `TRUE`. Nesta rodada, as 9 colunas existem na A5.3 (`TRUE`), ou seja, a falha não ocorreu | O 20 e o 23 conferem que as colunas existem e que não há NA, e o 20 registra a diferença por coluna. O 25 recalcula os 9 valores × 2 períodos × 26 direto da `serie_diaria` e compara com a A5.3 e com o CSV do 20 (desvio 48 (c) e (e)) |
| 3 | `monta_offset()` com `periodo = NULL`, que era o padrão, deixava sumir um dia ausente de uma entrada esparsa, sem erro e sem `z_t_zero` | corrigir | Sintético na versão da primeira rodada: valor padrão `NULL`; 4 linhas devolvidas para 5 dias, e o dia ausente sumiu | `periodo` passou a ser obrigatório; com `NULL`, a função para se faltar dia na grade de uma unidade. Testes novos: "dia ausente com NULL" e "Z_tj NA". Agora são 17/17 (desvio 48 (a)). A série da A3 não muda, porque o 21 já completava a grade |
| 4 | Afirmações fixas nos logs: "nesta rodada, nenhum par ficou de fora" (23); "os demais têm Z_t = 0" quando não havia demais (21); os NA declarados no 20 e no 21 não eram conferidos por código; o 25 tinha expectativas escritas à mão (15 e "n_j < 10: 0") | corrigir | `grep` das linhas no 21 (128) e no 23 (154) | Os textos passaram a depender do dado. O 20 e o 21 conferem por código cada NA declarado. O 25 deriva as expectativas do valor recalculado (desvio 48 (c) e (e)) |
| 5 | Lacunas do 25: faltavam 12 das 20 colunas da A6.1, os 4.498 dias, o `viol_je`, os dias incompletos, a A5.3 e os rótulos do dia da semana; o mínimo, a mediana e o máximo saíam sem o filtro do nº 40; e o 25 comparava células < 10 com células mascaradas (com uma célula < 10, o 23 mascara 2) | corrigir | Sintético: com x = (5, 100, 200), o 23 mascara 2 e o 25 contava 1 | O 25 ganhou as conferências que faltavam, o filtro do nº 40, a máscara reimplementada e mais trechos de texto conferidos. O 23 autotesta a máscara com dado sintético (desvio 48 (d) e (e)) |
| 6 | DP intra-estrato de `log_w` fora da previsão: São Paulo 0,0155 contra cerca de 0,007, e Sorocaba 0,0265 contra cerca de 0,022. Se fosse só ruído de composição, a razão Sorocaba/São Paulo seria cerca de √(78.150/3.228) = 4,92; a especificação prevê 3,14; o observado é 1,71. Há um componente que não cai com o tamanho | nota | Contas sobre o log da A6: 4,92; 3,14; 1,71 | Registrado na RESPOSTA, com as hipóteses do auditor: quedas de nascimentos em feriados herdadas por s; preferência de registro da IG variando no tempo; forma real da sazonalidade das concepções. O dia da semana dos partos se anula nas semanas completas. É uma checagem de plausibilidade, sem critério de parada. Sugestão para o chat: diagnóstico agregado antes da Fase 2 |
| 7 | A conferência do calendário era circular: `as.integer(fator)` devolve os códigos com que o fator foi montado | nota | `calendario()$dia_semana` = `format(data, "%u")` em todos os dias: `TRUE` (os rótulos estavam certos) | O 23 e o 25 conferem contra `format(data, "%u")` (desvio 48 (d)) |
| 8 | De 2011-12-14 a 2011-12-31, Z_t = 0 é conhecido (coorte fixa), mas tinha sido gravado como NA, com `z_t_zero` NA. Na A3, há offset de 2012-01-01 a 03 (evento impossível) | nota | Principal: 468 linhas de 2011, todas com `z_t` e `z_t_zero` NA. Municipal: há offset não NA em dias-município de 2012-01-01 a 03 (contagem omitida: agregado mais fino que concentração × ano; reauditoria, novo 9) | `z_t` = 0 e `z_t_zero` = TRUE nesses dias, na A2 e na A3 (desvio 48 (b), que substitui a última frase do nº 44 (d)). O offset da A3 fora da janela de evento possível ficou, como nota: o prompt pede `periodo = NULL`, e a `linha_modelo` governa o ajuste (desvio 48 (f)) |
| 9 | A identidade da A4 fecha por construção da classificação (ignorado = resto): ela testa que o PTB do `nascimentos()` é igual ao da `serie_diaria`, dia a dia | nota | Leitura do 22 (linhas 40 e 54–55) | O log do 22 passou a explicar o que a identidade testa |
| 10 | Padrão frouxo em dois testes: `"1 dia(s)"` com `fixed = TRUE` aceita "11 dia(s)" | nota | `grepl("1 dia(s)", "11 dia(s)", fixed = TRUE)` = `TRUE` | Padrões ancorados com o prefixo `monta_offset: ` (desvio 48 (a)) |
| 11 | Ano do arquivo contra ano do parto na A6.9, sem registro | nota | Leitura do 23: Q2a por `nb2$ano` (arquivo), séries por `format(esp$data, "%Y")` | Registrado no desvio 48 (d) e no texto do log da A6 |
| 12 | Afastamentos pequenos sem registro: o padrão do `periodo`, a A6.1 só somada nas 26, o arquivo extra `conferencias_valores.csv`; e a `DESCRIPTION` sem `Imports: stats` | nota | Leitura: `formals` mostra o valor padrão `NULL`; a `DESCRIPTION` não tinha `Imports` | O padrão foi tirado; a A6.1 mostra quantas concentrações têm NA em cada coluna; o arquivo extra foi registrado; a `DESCRIPTION` declara `Imports: stats` (desvio 48) |

### Regeneração da cadeia (desvio 48)

**Artefatos da primeira rodada enviados para `/Volumes/Forja/.Trashes/501/`, com SHA-256 e horário:**

| Arquivo | SHA-256 | Gravado |
|---|---|---|
| `01_saidas/fase1/conferencias_valores.csv` | `f2912b6f08a15977fba35b1e442d6d9813fac7fb39ecacc393da153dc64f8c1b` | 19:33:21 |
| `01_saidas/fase1/nos_tmean_mun_concentracao.csv` | `93c2e43244b3b2ecd5db7b690073f62dbb249f5a21a6c46671e0e328d90565be` | 19:28:04 |
| `01_saidas/fase1/referencias_exposicao.csv` | `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467` | 19:25:15 |
| `01_saidas/fase1/serie_ptb_espontaneo.rds` | `66483e7953e4fca6dae76031016cc424924ad6cc63115293073f40bae4cd9a57` | 19:29:41 |
| `01_saidas/fase1/serie_ptb_municipal.rds` | `786239730ecc1a9df9034cae5bd12d34fff45463158b185c8db93f3f3a5117bd` | 19:28:04 |
| `01_saidas/fase1/serie_ptb_principal.rds` | `67f022b47daa75b8e9c8375220d7fc58dcfac95914d5e46557c6d2777d68e983` | 19:25:15 |
| `01_saidas/fase1/wj_ptb_concentracao.csv` | `23e753ba36743c7eae2a577b9c3f1aa11d2c60803dde95ac47b30b6aea756cd3` | 19:25:12 |
| `logs/testes_compartilhado_fase1_20261009.md` | `8e43cb831dc0f66d72bae69eb6bc3e5a202232f02909e22318f1b8cdaa367f38` | 19:22:41 |
| `logs/serie_principal_fase1_20261009.md` | `12ab6be4000bef62318ece0ee888a9d8c6460cd639c3cf7942d0e26bb2c7c26d` | 19:25:15 |
| `logs/serie_municipal_fase1_20261009.md` | `f2fb7f3642c3d3918976f30247ddf3ada75cad1d9451206bc2643b969b513aa5` | 19:28:04 |
| `logs/ptb_espontaneo_fase1_20261009.md` | `bb464cc796d395ffbf199dd2556374f635afab3572abd3557c3565a2489113c6` | 19:29:41 |
| `logs/conferencias_fase1_20261009.md` | `7e042f565701b31a915949b6a583afff723ce90df2f55eb80abe2172df1a9594` | 19:33:21 |
| `logs/autoauditoria_fase1_20261009.md` | `fa3f50acffec9aabe0e86d7d71bd79e5f617c3287ff33b62fc015902ceed9fda` | 19:41:57 |

A primeira versão do log da autoauditoria (19:37:40, `350ab0af…`) já tinha ido para o Lixo antes (desvio 46).

**Nova rodada:** 24 às 20:16:50, 20 às 20:16:52, 21 às 20:17:01, 22 às 20:17:43, 23 às 20:17:48 e 25 às 20:18:42. Todos terminaram com código 0, `versao()` = 4443971b no início e no fim, e o 23 terminou sem nenhuma falha.

**Comparação entre a primeira rodada e a nova (por código):**
- `wj_ptb_concentracao.csv`, `referencias_exposicao.csv`, `nos_tmean_mun_concentracao.csv` e `conferencias_valores.csv` são **idênticos byte a byte**.
- Nos três RDS (principal, municipal e espontâneo), as únicas colunas diferentes são `z_t` e `z_t_zero`, e **só de 2011-12-14 a 2011-12-31**. Era NA, passou a ser 0 e TRUE (desvio 48 (b)). Todas as outras colunas são idênticas.
- Os números das conferências da A6 não mudaram. Mudaram só a apresentação da A6.1 (coluna de concentrações com NA) e os textos.

### Reauditoria (independente, depois das correções; desvios 49 e 50)

- **Quem reauditou:** um subagente novo, em contexto limpo, com as mesmas proibições:
  - não abriu `.parquet`, `.rds`, `.dbc` nem os CSV de `01_saidas/`;
  - não rodou script que lê a base;
  - só rodou R com dado sintético;
  - não alterou o repositório.
- **Tentativa anterior:** foi interrompida quando a sessão reiniciou e não deixou relatório; ficaram só os arquivos de trabalho dela, no scratchpad.
- **O que leu:**
  - o log desta auditoria e os desvios 37 a 48;
  - os scripts 20 a 26;
  - o código e os testes compartilhados;
  - os logs `_fase1_`;
  - a transcrição do prompt.
- **Veredito:** as correções não criaram erro nos dados.
- **Achados da primeira auditoria:** 10 resolvidos e 2 parcialmente. O 4 voltava a aparecer no script 26, e o 5 ainda tinha lacunas na autoauditoria. Os dois foram tratados no desvio 49.
- **Achados novos:** 12. Nenhum bloqueante: 5 para corrigir e 7 notas. Todos foram reproduzidos por código próprio e tratados no desvio 49.

| # | Achado novo | Gravidade | Reprodução própria | Correção |
|---|---|---|---|---|
| 1 | Sigilo latente: a coluna "Maior dif." do 25 gravava a diferença exata em conferência de contagem; o 26 transcreveria a tabela sem conferir se o 25 deu n/n; o `stop` do 22 imprimia contagens de PTB | corrigir | Com o `confere()` do 25 e números sintéticos (1.007 contra 1.000), a coluna gravou a diferença exata (7) | Nas contagens, o 25 grava só "0" ou "diferente", e o `no_texto` não grava mais o trecho ausente. O 22 mascara de 1 a 9 como "<10" e não imprime a contagem de PTB. O 26 para se o 25 não der n/n ou se o log da A6 tiver FALHA |
| 2 | O 26 tinha a lista de desvios fixa (40 a 48), e a seção da reauditoria era opcional | corrigir | Leitura: `vapply(40:48, …)` e um `if (length(grep("^## Reauditoria" …)))` | Lista a partir do nº 40, sem número fixo e conferida em sequência; seção da reauditoria obrigatória (`stopifnot`) |
| 3 | Textos fixos no 26: "todas as obrigatórias passaram", as três concentrações escolhidas à mão, "acima" e as razões 4,92, 3,14 e 1,71 | corrigir | Leitura das linhas 46, 79, 83 e 111 do 26 | O texto vem do log da A6 (o script para se faltar a frase); as três maiores % de ignorado são calculadas; "acima"/"abaixo"/"perto" depende do valor; as razões são calculadas dos valores |
| 4 | A conferência final do 26 era fraca: ignorava "n/n" e "n de n" e buscava por substring ("20,9" casava com "20,95") | nota | `grepl("20,9", "20,95", fixed = TRUE)` = `TRUE` | Tokens "n/n" e "n de n" incluídos; busca com limite de número (`(?<![0-9.,])…(?![0-9]\|,[0-9])`); lista de exclusões retirada |
| 5 | Faltavam testes para garantias declaradas: o `periodo` sem valor padrão, a trava de Σ Z·w = 0 e o `z_t_zero` só onde Z_t = 0 | corrigir | Os 3 defeitos plantados (padrão `NULL`, `if (FALSE) stop(`, `z_t_zero <- !ok`) não derrubavam nenhum teste | 4 testes novos (`periodo_sem_valor_padrao`, `erro_soma_zw_zero`, `z_t_zero_so_onde_z_e_zero`, `erro_entradas_invalidas`). A bateria tem 21 testes, e cada um desses defeitos agora derruba 1 |
| 6 | Com `periodo = NULL`, a checagem da grade só vê buraco interno; entradas inválidas (`periodo` invertido ou de tamanho 1, w_j negativo) davam erro cru ou passavam | nota | Sintético: sem o primeiro dia da unidade, a função passa sem erro (4 linhas) | Validação de `periodo` e de w_j negativo. A documentação diz que garantir o intervalo da grade é de quem chama; a A3 monta a grade inteira e confere o nº de linhas |
| 7 | No 25, o dia da semana era conferido só por contagens, e o vetor delas é palíndromo | nota | `identical(x, rev(x))` = `TRUE` com 643/643/642/642/642/643/643 | O 25 confere o rótulo dia a dia contra `format(data, "%u")` em todas as linhas da série principal |
| 8 | Números sem autoauditoria: concentrações com NA da A6.1, NA de PM2.5 por concentração, estratos por concentração, as 5 datas, a lista de w_j não crescente, a `linha_modelo` do 21 e os testes derrubados por cada defeito | nota | Leitura do 25 | O 25 confere todos esses números (54 conferências) |
| 9 | O log desta auditoria trazia uma contagem de dias-município de 2012-01-01 a 03, mais fina que concentração × ano | corrigir | Leitura da linha do achado 8 | O número foi retirado do texto antes do commit |
| 10 | O desvio 48 (c) diz que o 23 registra a diferença por coluna, mas ele registrava só a maior | nota | Leitura do 23 | O 23 registra a diferença por coluna |
| 11 | "Sem célula" queria dizer "sem célula nas semanas 22 a 36" | nota | Leitura do 21 e do 25 | Redação corrigida no 21 e no 25 |
| 12 | Nenhum log registrava o SHA-256 do `conferencias_valores.csv`, e o `git status` do retorno é tirado antes de gravá-lo | nota | Leitura | O 23 grava o CSV antes do log e registra o SHA-256; o 25 o confere; o retorno diz que o `git status` é anterior a ele |

**Incidente (desvio 50):**
- **O que aconteceu:** para comparar a 2ª rodada com a 3ª, a sessão copiou os 3 RDS e os 4 CSV da 2ª rodada para o scratchpad (`/private/tmp`, disco interno do Mac Mini).
- **Correção:** menos de um minuto depois, moveu as cópias de volta para dentro da Forja (`01_saidas/rodada2_comparacao_fase1/`, fora do git) e conferiu que não sobrou nenhum `.rds` desta sessão em `/private/tmp`. Depois da comparação, as cópias foram para o Lixo da Forja.
- **O que não aconteceu:** nada foi enviado a serviço externo, nem entrou em git, chat ou log.

**Regeneração da cadeia (3ª rodada, desvio 49).** Artefatos da 2ª rodada enviados para `/Volumes/Forja/.Trashes/501/`, com SHA-256 e horário:

| Arquivo | SHA-256 | Gravado |
|---|---|---|
| `01_saidas/fase1/conferencias_valores.csv` | `f2912b6f08a15977fba35b1e442d6d9813fac7fb39ecacc393da153dc64f8c1b` | 20:17:55 |
| `01_saidas/fase1/nos_tmean_mun_concentracao.csv` | `93c2e43244b3b2ecd5db7b690073f62dbb249f5a21a6c46671e0e328d90565be` | 20:17:43 |
| `01_saidas/fase1/referencias_exposicao.csv` | `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467` | 20:17:01 |
| `01_saidas/fase1/serie_ptb_espontaneo.rds` | `654ecbf5cda28dc066709d99238a11370c1205da0f08183152fb326df9a99af7` | 20:17:48 |
| `01_saidas/fase1/serie_ptb_municipal.rds` | `04dad6b1b54472802594ef3ed44adcf327c02e0cd7ed88dd90af63b86770cd49` | 20:17:43 |
| `01_saidas/fase1/serie_ptb_principal.rds` | `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917` | 20:17:01 |
| `01_saidas/fase1/wj_ptb_concentracao.csv` | `23e753ba36743c7eae2a577b9c3f1aa11d2c60803dde95ac47b30b6aea756cd3` | 20:16:58 |
| `logs/testes_compartilhado_fase1_20261009.md` | `b06d5f41bc386bbe844490fbbf16e6a46ffa87b798a1467e056dbbd5fe2156e9` | 20:16:52 |
| `logs/serie_principal_fase1_20261009.md` | `14a0fd9a389246b4afda4396c186d786e5fe1b78bde88e200e529a5e80ade856` | 20:17:01 |
| `logs/serie_municipal_fase1_20261009.md` | `466db72f89e5ad483d1a02bb37d6ccf50f6f8999839d3c361e75cfff047826e4` | 20:17:43 |
| `logs/ptb_espontaneo_fase1_20261009.md` | `4fb1e8751888014639ce83cc340b5d403403464b9c2a736bb773406346633990` | 20:17:48 |
| `logs/conferencias_fase1_20261009.md` | `f3f31f6f3880f148f67ae1f0e8e322e77c5cae223b9295a8b00fb8ca4ad65368` | 20:17:55 |
| `logs/autoauditoria_fase1_20261009.md` | `d43f34470b541c4d178286510a2300474785330ffc5ac7ba294e9c3a85cea0da` | 20:19:21 |

**3ª rodada:**
- **Horários de início:** 24 às 21:11:57, 20 às 21:11:59, 21 às 21:12:09, 22 às 21:12:51, 23 às 21:12:56 e 25 às 21:13:03.
- **Resultado:**
  - todos terminaram com código 0, com `versao()` = 4443971b no início e no fim;
  - bateria de testes: 21/21;
  - o 23 terminou sem nenhuma falha;
  - autoauditoria: 54 de 54.
- **Comparação entre a 2ª e a 3ª rodada:** os 3 RDS e os 4 CSV (`serie_ptb_principal.rds`, `serie_ptb_municipal.rds`, `serie_ptb_espontaneo.rds`, `wj_ptb_concentracao.csv`, `referencias_exposicao.csv`, `nos_tmean_mun_concentracao.csv` e `conferencias_valores.csv`) são **idênticos byte a byte**. As correções da reauditoria mudaram só conferências, textos e testes, não os dados.
## 7. Desvios novos

As linhas 37 a 39 estão na seção 2. As decisões do plano foram registradas antes de rodar (40 a 45, no commit da A0 `41ca2f6`); os achados de execução e de auditoria, nas linhas 46 a 50.

| # | Data | Etapa | Referência | O que divergiu | Causa | Efeito nos resultados | Decisão | Evidência |
|---|---|---|---|---|---|---|---|---|
| 40 | 2026-10-09 | Fase 1, A6.5 (registrado antes de rodar) | Prompt da Fase 1, A6.5 ("mínimo, mediana e máximo entre as 26 concentrações") e regra de sigilo do mesmo prompt ("nenhum w_j com numerador menor que 10 sai da Forja") | O mínimo, a mediana e o máximo de w_j por semana são calculados só com os pares concentração × semana com n_j ≥ 10. O retorno informa quantos pares ficaram de fora, que é o nº de pares com n_j < 10 que a A6.5 já pede | O mínimo e o máximo são o w_j de uma única concentração; com n_j < 10, publicá-los violaria a regra | Nenhum nos dados; muda só o que é publicado | Decisão de Guilherme em 09/10, entre as opções apresentadas | `23_confere_fase1.R`; `logs/conferencias_fase1_<data>.md` |
| 41 | 2026-10-09 | Fase 1, git (registrado antes de rodar) | Prompt da Fase 1, A0 ("primeiro commit da Fase 1") e seção Git (um commit no fim) | São dois commits locais: a A0 sozinha, antes de rodar qualquer script; no fim, o commit da fase, com a mensagem do prompt. Os dois pushes esperam o [ok] | Os desvios ficam versionados antes da execução | Nenhum | Decisão de Guilherme em 09/10 | `git log` |
| 42 | 2026-10-09 | Fase 1, A1 (registrado antes de rodar) | Prompt da Fase 1, A1.3 (testes) e regra "use só os pacotes do `renv.lock`" | Os testes são escritos em R base (`stopifnot`, `tryCatch` e um executor que conta n/n), sem o `testthat`, que não está no `renv.lock` | Pacote ausente do ambiente congelado | Nenhum | Decisão de Guilherme em 09/10 | `codigo_compartilhado/tests/` |
| 43 | 2026-10-09 | Fase 1, A1, A5 e A7 (registrado antes de rodar) | Prompt da Fase 1: "scripts numerados de 20 a 29 … um script por bloco (A1 a A6)", com os nomes 20 (A2), 21 (A3), 22 (A4) e 23 (A6) já fixados | O script da A1 é o `24_testes_compartilhado_fase1.R`, que roda antes do 20. Ele roda a bateria de testes e os 3 defeitos plantados, em cópias das funções numa pasta temporária; o código original não é tocado. A A5 não tem script: o registro fica no log do 20. A autoauditoria e a RESPOSTA ficam nos scripts 25 e 26 | O prompt fixou os números 20 a 23 para os outros blocos | Nenhum | Registrado (plano aprovado por Guilherme em 09/10) | `00_scripts/24_testes_compartilhado_fase1.R`, `25_autoauditoria_fase1.R`, `26_resposta_fase1.R` |
| 44 | 2026-10-09 | Fase 1, A1 e A2 (registrado antes de rodar) | Prompt da Fase 1, A1.2 (`monta_offset(z_tj, w, semanas, periodo)`); o `gestacoes_em_risco` grava só células > 0 (`DICIONARIO.md`) | Regras da função para entrada esparsa. (a) A chave é qualquer conjunto de colunas além de `semana` e `z`, com a data na coluna `data`. (b) Semanas fora de `semanas` são ignoradas na soma, porque o `gestacoes_em_risco` traz as semanas 22 a 42. (c) Com `periodo`, todo dia do período tem de estar presente em cada unidade, com Z_t > 0; um dia ausente equivale a Z_t = 0 e dá erro. (d) Com `periodo = NULL`, a função não confere a grade: na série municipal, quem chama completa os dias com Z = 0, e a função só marca `z_t_zero`. Na série principal, `z_t` e `w_t` ficam NA de 2011-12-14 a 2011-12-31, antes da grade do `gestacoes_em_risco`, que começa em 2012-01-01 | Um dia com Z_t = 0 não aparece na entrada esparsa | Nenhum | Registrado (plano aprovado por Guilherme em 09/10) | `codigo_compartilhado/R/offset.R` |
| 45 | 2026-10-09 | Fase 1, A6.9 (registrado antes de rodar) | Prompt da Fase 1, A6.9 ("reporte esse % na mesma população") | O % de `sttrabpart` "9" ou vazio é calculado sobre todos os NV das 26 concentrações, por `ano`, de 2013 a 2023. A população é a da Q2a: `nascimentos()`, sem coorte e sem filtro de gravidez ou de IG. Na tabela por concentração, uma categoria com menos de 10 casos sai como "<10", com supressão complementar | Leitura do prompt | Nenhum | Registrado (plano aprovado por Guilherme em 09/10) | `23_confere_fase1.R` |
| 46 | 2026-10-09 | Fase 1, A7.1 (registrado antes de rodar de novo) | Prompt da Fase 1, A7.1; `00_scripts/25_autoauditoria_fase1.R` | **Regeneração do log da autoauditoria.** Na primeira rodada (19:37:40; SHA-256 `350ab0af86e60bc58b604d16c2f51ab154c34ff113f6bf9600e00dd3e658cc9a`, enviada para `/Volumes/Forja/.Trashes/501/`), 29 de 30 conferências deram igual. A 30ª esperava que os dias-município com Z_t = 0 no RDS da A3 fossem só os "sem célula" do log do 21. A diferença são <10 dias-município que têm célula no `gestacoes_em_risco` só por `z_fetal` > 0, com `z_nv` = 0 nas semanas 22 a 36: o arquivo guarda células com `z_nv` ou `z_fetal` > 0. Esses dias também saem com `z_t_zero` = TRUE e offset NA. (Texto mascarado antes do commit, por sigilo: desvio 47.) O dado e o log do 21 estão certos; o erro era da expectativa da conferência. A conferência foi refeita com as duas parcelas recalculadas da base | Erro de expectativa na conferência | Nenhum | Conferência corrigida; log gerado de novo | `logs/autoauditoria_fase1_20261009.md` |
| 47 | 2026-10-09 | Fase 1, auditoria independente (antes do commit) | `logs/auditoria_fase1_20261009.md`, achado 1; regra de sigilo do prompt ("<10" e supressão complementar) | **Sigilo: mascaramento do nº 46 antes do commit.** O texto original do nº 46 trazia, por extenso, uma contagem de 1 a 9 (dias-município com célula só por `z_fetal`) e os dois totais de que ela é a diferença. O texto foi trocado por "<10", sem os totais, antes de entrar no git. A mesma contagem saiu também na saída do script 25 (stdout da sessão) e numa mensagem da sessão ao Guilherme; isso não tem como ser desfeito e fica registrado aqui. O script 25 não imprime mais esse número | Falha da sessão ao redigir o nº 46 e a mensagem | Nenhum nos dados | Corrigido antes do commit; nenhuma contagem de 1 a 9 vai para log, commit ou chat | Linha do nº 46; `00_scripts/25_autoauditoria_fase1.R` |
| 48 | 2026-10-09 | Fase 1, auditoria independente (registrado antes de rodar de novo) | `logs/auditoria_fase1_20261009.md`, achados 2 a 5, 7, 8, 10 a 12; desvio nº 44 (d) | **Correções e regeneração da cadeia 24, 20, 21, 22, 23 e 25.** Os artefatos da primeira rodada (7 arquivos em `01_saidas/fase1/` e 6 logs `_fase1_20261009`, com os SHA-256 listados na auditoria) vão para `/Volumes/Forja/.Trashes/501/`, e tudo roda de novo com o código corrigido. (a) `monta_offset()`: `periodo` passa a ser argumento obrigatório, sem valor padrão; com `periodo = NULL`, a função para se faltar dia na grade de alguma unidade (a grade tem de vir completa, com Z = 0). A `DESCRIPTION` declara `Imports: stats`. Os testes ganham os casos "dia ausente com NULL" e "Z_tj NA", e os padrões de erro ficam ancorados. (b) Séries A2 e A3: de 2011-12-14 a 2011-12-31, `z_t` = 0 e `z_t_zero` = TRUE, com `w_t` e offset NA; antes eram NA. Pela coorte fixa (s ≥ 2011-07-31), nenhuma gestação chega à semana 22 antes de 2012-01-01. Isso substitui a última frase do nº 44 (d). (c) O 20 e o 23 conferem que as colunas da A5.3 existem e registram a diferença por coluna; o 20 confere por código os NA declarados no log; os textos dos logs passam a depender do dado. (d) O 23 confere o dia da semana contra `format(data, "%u")`, mostra quantas concentrações têm NA em cada coluna da A6.1 (antes, só a soma das 26) e autotesta a máscara "<10". Na A6.9, o % da Q2a usa o `ano` do arquivo do SINASC, e as séries usam o ano da data do parto. (e) O 25 passa a conferir as 20 colunas da A6.1, os 4.498 dias, o `viol_je`, os dias incompletos e a A5.3 recalculada direto da `serie_diaria`; usa os rótulos do dia da semana por `format(data, "%u")`, o filtro do nº 40 e a máscara reimplementada; e tira as expectativas escritas à mão. (f) Fica como estava, como nota: na A3, há offset nos dias de Z_t > 0 fora da janela de evento possível (2012-01-01 a 2012-01-03), porque o prompt pede `periodo = NULL`; quem decide o ajuste é a `linha_modelo`. O arquivo extra `01_saidas/fase1/conferencias_valores.csv` (fora do git) é a entrada da autoauditoria | Achados da auditoria independente, reproduzidos por código próprio | Nenhum nos totais, no w_j nem no offset da janela de evento possível; muda só o `z_t`/`z_t_zero` de 2011-12-14 a 2011-12-31 | Corrigido; a cadeia roda de novo | `logs/auditoria_fase1_20261009.md`; `codigo_compartilhado/`; `00_scripts/20` a `25` |
| 49 | 2026-10-09 | Fase 1, reauditoria independente (registrado antes de rodar de novo) | `logs/auditoria_fase1_20261009.md`, seção "Reauditoria": novos 1 a 12; desvios nº 47 e 48 | **Correções da reauditoria e 3ª rodada da cadeia 24, 20, 21, 22, 23 e 25.** Os artefatos da 2ª rodada (7 arquivos em `01_saidas/fase1/` e 6 logs `_fase1_20261009`, com os SHA-256 listados na auditoria) vão para `/Volumes/Forja/.Trashes/501/`. (a) **Sigilo.** O 25 não grava mais a diferença exata em conferência de contagem ("igual" ou "diferente", sem o valor). O 22 não põe contagem de PTB em mensagem de erro (1 a 9 sai como "<10"). O 26 para se o 25 não der n/n ou se o log da A6 tiver FALHA. O log da auditoria deixou de trazer uma contagem de dias-município de 2012-01-01 a 03, mais fina que concentração × ano (texto corrigido antes do commit). (b) **26.** Lista de desvios a partir do nº 40 sem número fixo; seção da reauditoria obrigatória; textos tirados do dado (resultado da A6, as três maiores % de PTB com início ignorado, "acima"/"abaixo" da previsão, razões dos DP calculadas); conferência final dos números com limite de palavra. (c) **`monta_offset()`.** Valida `periodo` (tamanho 2, início ≤ fim) e w_j negativo. A documentação diz que, com `periodo = NULL`, a grade vai do primeiro ao último dia presente de cada unidade, e quem chama garante o intervalo (a A3 monta a grade inteira e confere o nº de linhas). Testes novos: `periodo` sem valor padrão, Σ Z·w = 0 com Z_t > 0, `z_t_zero` só onde Z_t = 0 e entradas inválidas. (d) **Conferências.** O 23 registra a diferença por coluna da A5.3 e o SHA-256 do `conferencias_valores.csv`. O 25 confere o dia da semana dia a dia; as concentrações com NA da A6.1; os NA de PM2.5 por concentração; os estratos por concentração; as 5 datas sorteadas; a lista de w_j não crescente; a `linha_modelo` do 21; os testes derrubados por defeito; e o SHA-256 do CSV de valores. (e) **Redação.** "Sem célula" passa a "sem célula nas semanas 22 a 36" | Achados da reauditoria, reproduzidos por código próprio | Nenhum nos dados (os RDS e CSV não devem mudar; conferido na auditoria) | Corrigido; a cadeia roda de novo | `logs/auditoria_fase1_20261009.md`; `codigo_compartilhado/`; `00_scripts/20` a `26` |
| 50 | 2026-10-09 | Fase 1, 3ª rodada (registrado depois do fato) | Regras da Forja e do prompt: séries diárias e conjuntos analíticos "ficam só em `artigo1_prematuridade/01_saidas/fase1/`" e "nenhuma série diária … sai da Forja" | **Incidente de sigilo: cópia temporária para fora da Forja.** Para comparar a 2ª rodada com a 3ª, a sessão copiou os 3 RDS e os 4 CSV da 2ª rodada para o scratchpad da sessão (`/private/tmp/claude-501/…`, disco interno do Mac Mini). Ao perceber, menos de um minuto depois, moveu as cópias de volta para dentro da Forja (`01_saidas/rodada2_comparacao_fase1/`, fora do git) e conferiu que não sobrou nenhum `.rds` desta sessão em `/private/tmp`. Depois da comparação, as cópias foram para `/Volumes/Forja/.Trashes/501/`. Nada foi enviado a serviço externo, nem entrou em git, chat ou log | Falha da sessão | Nenhum nos dados | Registrado; comparações futuras ficam sempre dentro da Forja | `logs/auditoria_fase1_20261009.md`, seção "Reauditoria" |

## 8. Scripts e comandos para reproduzir

Da pasta `artigo1_prematuridade/`, com o `renv` do artigo (R 4.5.1), nesta ordem. Cada script tem trava contra sobrescrita: para reproduzir, mande antes os arquivos gravados para o Lixo ou rode numa cópia.

```
FASE1_DATA=20261009 Rscript 00_scripts/24_testes_compartilhado_fase1.R
FASE1_DATA=20261009 Rscript 00_scripts/20_monta_serie_principal.R
FASE1_DATA=20261009 Rscript 00_scripts/21_monta_serie_municipal.R
FASE1_DATA=20261009 Rscript 00_scripts/22_monta_ptb_espontaneo.R
FASE1_DATA=20261009 Rscript 00_scripts/23_confere_fase1.R
FASE1_DATA=20261009 Rscript 00_scripts/25_autoauditoria_fase1.R
FASE1_DATA=20261009 Rscript 00_scripts/26_resposta_fase1.R
```

| Script | Bloco | Grava |
|---|---|---|
| `24_testes_compartilhado_fase1.R` | A1 | `logs/testes_compartilhado_fase1_<data>.md` |
| `20_monta_serie_principal.R` | A2 (e registro da A5) | `01_saidas/fase1/serie_ptb_principal.rds`, `wj_ptb_concentracao.csv`, `referencias_exposicao.csv`; `logs/serie_principal_fase1_<data>.md` |
| `21_monta_serie_municipal.R` | A3 | `01_saidas/fase1/serie_ptb_municipal.rds`, `nos_tmean_mun_concentracao.csv`; `logs/serie_municipal_fase1_<data>.md` |
| `22_monta_ptb_espontaneo.R` | A4 | `01_saidas/fase1/serie_ptb_espontaneo.rds`; `logs/ptb_espontaneo_fase1_<data>.md` |
| `23_confere_fase1.R` | A6 | `logs/conferencias_fase1_<data>.md`; `01_saidas/fase1/conferencias_valores.csv` |
| `25_autoauditoria_fase1.R` | A7.1 | `logs/autoauditoria_fase1_<data>.md` |
| `26_resposta_fase1.R` | retorno | este arquivo |

**SHA-256 do código** (no momento de gravar este retorno):

| Arquivo | SHA-256 |
|---|---|
| `00_scripts/24_testes_compartilhado_fase1.R` | `cb6e95f992916a71be4616a7b375027dec40f1951aeb743954bb6788c1e66474` |
| `00_scripts/20_monta_serie_principal.R` | `d2d5d00ff0034cba9543e69b61f52c4452a8ab65fd4d8a0256ea46cb60b713e8` |
| `00_scripts/21_monta_serie_municipal.R` | `260c973c2b4c6fcc380b030c427042c61c4794d9cd8e2fe47d44cf856708d1c6` |
| `00_scripts/22_monta_ptb_espontaneo.R` | `af25e94c0df6f401c2de1afaad0416b08d363beceb5c9f6ed417d1dfb07c3ca1` |
| `00_scripts/23_confere_fase1.R` | `31e255ebb84a9998d4b09c6c3fe78b0d054a2862d21caf9cd17a2962a16aea93` |
| `00_scripts/25_autoauditoria_fase1.R` | `d3c70f2e6aba43873546d56ef07c2b5a7104d4761973f23bab7a3986da167d97` |
| `00_scripts/26_resposta_fase1.R` | `7c6abc00e109447321c6ae69c8d0cf3caa37e52d942279e7ad6d6a11d6ef439a` |
| `codigo_compartilhado/R/offset.R` | `55111b2cc510d7b1c7b78b7f84e99997c5202825e0353da70bab0b4bea290bae` |
| `codigo_compartilhado/tests/testa_offset.R` | `6a7a4d96994d3e4cb0f411617517cd22b38e693787a309821ba5791380ab7eec` |
| `codigo_compartilhado/tests/roda_testes.R` | `40e7b537c500a29bfd852ac67a4fcde3fbd58128321f60fc438826360436768e` |
| `codigo_compartilhado/DESCRIPTION` | `1d3fa68d61a8eda509df1f44970403ac16d6e519646c80ff30e08d08d56c358b` |

**SHA-256 dos arquivos gravados** (fora do git; conforme os logs):

  - `01_saidas/fase1/serie_ptb_principal.rds`: `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917`;
  - `01_saidas/fase1/wj_ptb_concentracao.csv`: `23e753ba36743c7eae2a577b9c3f1aa11d2c60803dde95ac47b30b6aea756cd3`;
  - `01_saidas/fase1/referencias_exposicao.csv`: `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467`.
  - `01_saidas/fase1/serie_ptb_municipal.rds`: `04dad6b1b54472802594ef3ed44adcf327c02e0cd7ed88dd90af63b86770cd49`;
  - `01_saidas/fase1/nos_tmean_mun_concentracao.csv`: `93c2e43244b3b2ecd5db7b690073f62dbb249f5a21a6c46671e0e328d90565be`.
- **Arquivo gravado (fora do git), SHA-256:** `01_saidas/fase1/serie_ptb_espontaneo.rds`: `654ecbf5cda28dc066709d99238a11370c1205da0f08183152fb326df9a99af7`.

## 9. `versao()` no início e no fim de cada script

| Log | Script | `versao()` no início | `versao()` no fim |
|---|---|---|---|
| `testes_compartilhado_fase1_20261009.md` | `00_scripts/24_testes_compartilhado_fase1.R` | 4443971b | 4443971b |
| `serie_principal_fase1_20261009.md` | `00_scripts/20_monta_serie_principal.R` | 4443971b | 4443971b |
| `serie_municipal_fase1_20261009.md` | `00_scripts/21_monta_serie_municipal.R` | 4443971b | 4443971b |
| `ptb_espontaneo_fase1_20261009.md` | `00_scripts/22_monta_ptb_espontaneo.R` | 4443971b | 4443971b |
| `conferencias_fase1_20261009.md` | `00_scripts/23_confere_fase1.R` | 4443971b | 4443971b |
| `autoauditoria_fase1_20261009.md` | `00_scripts/25_autoauditoria_fase1.R` | 4443971b | 4443971b |
| (este retorno) | `00_scripts/26_resposta_fase1.R` | 4443971b | 4443971b (conferido no fim do script) |

## 10. `git status`

Saída de `git status --porcelain --untracked-files=all`, tirada antes do commit da fase e antes de gravar este retorno (que, por isso, não aparece nela e entra no mesmo commit). O `01_saidas/` não aparece porque está no `.gitignore`:

```
 M artigo1_prematuridade/logs/desvios_especificacao.md
 M codigo_compartilhado/DESCRIPTION
?? artigo1_prematuridade/00_scripts/20_monta_serie_principal.R
?? artigo1_prematuridade/00_scripts/21_monta_serie_municipal.R
?? artigo1_prematuridade/00_scripts/22_monta_ptb_espontaneo.R
?? artigo1_prematuridade/00_scripts/23_confere_fase1.R
?? artigo1_prematuridade/00_scripts/24_testes_compartilhado_fase1.R
?? artigo1_prematuridade/00_scripts/25_autoauditoria_fase1.R
?? artigo1_prematuridade/00_scripts/26_resposta_fase1.R
?? artigo1_prematuridade/logs/auditoria_fase1_20261009.md
?? artigo1_prematuridade/logs/autoauditoria_fase1_20261009.md
?? artigo1_prematuridade/logs/conferencias_fase1_20261009.md
?? artigo1_prematuridade/logs/ptb_espontaneo_fase1_20261009.md
?? artigo1_prematuridade/logs/serie_municipal_fase1_20261009.md
?? artigo1_prematuridade/logs/serie_principal_fase1_20261009.md
?? artigo1_prematuridade/logs/testes_compartilhado_fase1_20261009.md
?? artigo2_obito_perinatal/.Renviron
?? artigo2_obito_perinatal/.Rprofile
?? artigo2_obito_perinatal/00_scripts/00_ambiente.R
?? artigo2_obito_perinatal/00_scripts/00_dependencias.R
?? artigo2_obito_perinatal/00_scripts/01_inventario_interface.R
?? artigo2_obito_perinatal/00_scripts/02_percentis_exposicao.R
?? artigo2_obito_perinatal/00_scripts/03_recontagens.R
?? artigo2_obito_perinatal/00_scripts/04_bordas_denominador.R
?? artigo2_obito_perinatal/00_scripts/05_estrutura_tag_compartilhado.R
?? artigo2_obito_perinatal/00_scripts/06_autoauditoria.py
?? artigo2_obito_perinatal/00_scripts/07_verificador_supressao.R
?? artigo2_obito_perinatal/00_scripts/08_resposta.R
?? artigo2_obito_perinatal/CLAUDE.md
?? artigo2_obito_perinatal/logs/ambiente_fase0_20261009.md
?? artigo2_obito_perinatal/logs/autoauditoria_python_fase0_20261009.md
?? artigo2_obito_perinatal/logs/bordas_denominador_fase0_20261009.md
?? artigo2_obito_perinatal/logs/desvios_especificacao.md
?? artigo2_obito_perinatal/logs/fase0_log_20261009.md
?? artigo2_obito_perinatal/logs/inventario_interface_fase0_20261009.md
?? artigo2_obito_perinatal/logs/percentis_exposicao_fase0_20261009.md
?? artigo2_obito_perinatal/logs/prompt_fase0_20261008.md
?? artigo2_obito_perinatal/logs/recontagens_fase0_20261009.md
?? artigo2_obito_perinatal/logs/renv_fase0_20261009.md
?? artigo2_obito_perinatal/logs/sessionInfo_20261009.txt
?? artigo2_obito_perinatal/logs/tag_compartilhado_fase0_20261009.md
?? artigo2_obito_perinatal/logs/verificador_supressao_fase0_20261009.md
?? artigo2_obito_perinatal/renv.lock
?? artigo2_obito_perinatal/renv/activate.R
?? artigo2_obito_perinatal/renv/settings.json
?? artigo3_pig/.Renviron
?? artigo3_pig/.Rprofile
?? artigo3_pig/00_scripts/00_dependencias.R
?? artigo3_pig/00_scripts/00_setup_ambiente.R
?? artigo3_pig/00_scripts/01_verifica_interface.R
?? artigo3_pig/00_scripts/02_covariaveis_descritivo.R
?? artigo3_pig/00_scripts/03_percentis_exposicao.R
?? artigo3_pig/00_scripts/04_teste_sintetico_crossreduce_attrdl.R
?? artigo3_pig/00_scripts/05_pendencias.R
?? artigo3_pig/00_scripts/06_autoauditoria_fase0.py
?? artigo3_pig/00_scripts/07_resposta_fase0.R
?? artigo3_pig/CLAUDE.md
?? artigo3_pig/logs/ambiente_fase0_20261009.md
?? artigo3_pig/logs/autoauditoria_fase0_20261009.md
?? artigo3_pig/logs/covariaveis_fase0_20261009.md
?? artigo3_pig/logs/desvios_especificacao.md
?? artigo3_pig/logs/interface_fase0_20261009.md
?? artigo3_pig/logs/pendencias_fase0_20261009.md
?? artigo3_pig/logs/percentis_exposicao_fase0_20261009.md
?? artigo3_pig/logs/prompt_fase0_chat_A3_20261008.md
?? artigo3_pig/logs/renv_fase0_20261009.md
?? artigo3_pig/logs/sessionInfo_20261009.txt
?? artigo3_pig/logs/teste_sintetico_fase0_20261009.md
?? artigo3_pig/renv.lock
?? artigo3_pig/renv/activate.R
?? artigo3_pig/renv/settings.json
?? codigo_compartilhado/R/offset.R
?? codigo_compartilhado/tests/roda_testes.R
?? codigo_compartilhado/tests/testa_offset.R
```

`git log --oneline -3`:

```
41ca2f6 Fase 1 do Artigo 1, A0: pendencias da Parte B e desvios 37 a 45 (antes de rodar)
ccc741f Registra a auditoria da Parte B (desvio 36) e o retorno da Fase 0B
ec22aca Registra o congelamento (tag spec-v2.0.2-congelada-20261009) e fecha a Parte B da Fase 0 (B7 e B8)
```

O commit da fase (`Fase 1 do Artigo 1: series, offset e funcoes compartilhadas (sem modelo)`) leva código, testes, logs e este retorno, nunca dados. O push espera o [ok] de Guilherme.
