# FONTE — 06_processados (produtos derivados)

Nada aqui é baixado; tudo é gerado pelos scripts `06a`, `06b`, `06c`, `06d`, `06e` e `07` a partir de 01–05. **Contém microdado individual: não sai da Forja, não vai para o git nem para o chat.** Só agregados (contagens, coeficientes, figuras) podem sair.

> **Situação em 08/10/2026:** todos os scripts de processamento (06a–06e, 07a e 07b) foram migrados e gerados; a versão vigente é a `4443971b`, que acrescentou a `ig_dum_sem` ao `nascimentos.parquet`. As colunas de cada arquivo estão no `09_acesso/DICIONARIO.md`, e a versão e os md5, no `09_acesso/manifesto.json`. Este arquivo guarda o histórico e os números de cada etapa.

**Gerados (06a e 06e, 2026-10-05).** Clima e PM2.5 são dado público, não microdado. Cada arquivo tem md5 no `logs/integridade.csv`.

| Arquivo | Gerado por | Granularidade | Conteúdo |
|---|---|---|---|
| `clima_municipio_diario_2010_2025.parquet` | 06a | município × dia (277 × 5.510 = 1.526.270 linhas) | `CD_MUN`, `CD_MUN6`, `data`, `tmax`, `tmin`, `tmean`, `rh_mean`, `pr` (BR-DWGD v_3.2.4; ponderação por área) |
| `pm25_municipio_diario_2010_2025.parquet` | 06a | município × dia (1.526.270 linhas) | `CD_MUN`, `CD_MUN6`, `data`, `pm25`, `pm25_zero_na` (dia UTC), `pm25_local`, `pm25_local_zero_na` (dia aproximadamente local), `n_horarios`, `n_horarios_zero` (CAMS EAC4; µg/m³) |
| `clima_pesos_municipio.parquet` | 06a | município × célula de 0,1° | pesos de área, método (área / vizinho do centroide + distância) e `frac_area_coberta` |
| `pm25_pesos_municipio.parquet` | 06a | município × célula de 0,75° | pesos de área e `frac_area_coberta` |
| `calendario_2010_2025.parquet` | 06e | dia (5.510 linhas) | `data`, `ano`, `mes`, `dia_semana`, `fim_de_semana`, `feriado_nacional`, `feriado_nome`, `base_legal`, `carnaval`, `quarta_cinzas`, `sexta_paixao`, `corpus_christi` (ver `08_calendario/FONTE.md`) |

Também do 06a: `logs/dias_faltantes_clima.csv` (agregado; 0 dias faltantes).

**Gerados pelo 06b (2026-10-05). Microdado individual nas duas primeiras linhas.** Regras em `logs/desvios_especificacao.md` (entradas de 05/10) e na docstring do `06b_desfechos.py`. Recorte: residência num dos 277 municípios das concentrações, em 2011–2024.

| Arquivo | Granularidade | Conteúdo |
|---|---|---|
| `nascimentos.parquet` | nascido vivo (16.116.860) | `id_nasc` estável; `CD_MUN6`, `data`, `ano`; IG (`ga_sem`, `semagestac_bruto`, `ig_cat`, `gestacao_cat`, `metodo_ig`), `dum_est` (s = data − (7 × IG + 3)); `unico`, `gravidez`, `grav_cat`; `pop_ptb`, `ptb` e subtipos, `ig_43_44`; `coorte_fixa_22`, `coorte_fixa_37`; `periodo_principal`, `periodo_sens2011`, `nv_gestacao_sens2011`, `ptb_gestacao_sens2011`; peso, sexo, idade, escolaridade, raça/cor e estado civil da mãe; paridade (`paridade` = partos anteriores; `paridade_filvivo`; `flag_paridade_incoerente`); pré-natal; parto, `sttrabpart`, `stcesparto` e `stcesparto_aj`; apresentação, Robson e anomalia; **`ig_dum_sem`** (IG pela DUM, última coluna, desde 08/10/2026) |
| `obitos_perinatais.parquet` | óbito fetal (TIPOBITO 1) ou neonatal precoce (0–6 dias) (259.909) | `id_obito` estável; `tipo`; `data_indice` (fetal = `DTOBITO`; neonatal = `DTNASC`), `data_obito`, `data_nasc`; IG, peso, `criterio_fetal`; `unico`; `principal`, `sem_ig`, `ig_22_42`; `s_ini`, `coorte_fixa_22`; `idade`, `idade_valida`, `ate24h`; `causabas`, `anomalia_causabas`, `anomalia_qualquer_linha`, `cb_cap16_perinatal` |
| `serie_diaria_municipio.parquet` | município × dia, 2011–2024 (277 × 5.114 = 1.416.578) | **Versão principal, com coorte fixa.** Colunas com os nomes da especificação: `nv_unicos`, `nv_multiplos_ou_ign`, `ptb`, `ptb_extremo`, `ptb_muito`, `ptb_moderado_tardio`, `nv_ig_43_44`, `obito_fetal_principal`, `obito_fetal_sem_ig`, `obito_neonatal_precoce`, `obito_neonatal_precoce_sem_ig`, `obito_perinatal`, `obito_neonatal_precoce_idx_obito`, `obito_perinatal_idx_obito`, `obito_ate24h`, `obito_perinatal_24h`, `obito_perinatal_sem_anomalia`, `recorte_principal`, `tipo_recorte`, `periodo_principal`, `periodo_sens2011`, `ptb_gestacao_sens2011`, `nv_gestacao_sens2011`, `censura_neonatal_dez2024`. As colunas `*_sem_ig` são NA aqui (E4) |
| `serie_diaria_municipio_sem_coorte_fixa.parquet` | idem | Mesmas colunas, sem a restrição da coorte fixa; aqui as `*_sem_ig` têm valor |

**IG pela DUM: `ig_dum_sem` (08/10/2026; versão `4443971b`, sucessora da `7e99bf94`).**
- **Definição** (decisões, seção 8; §3.5 da v2.0.2; desvio de 08/10): ⌊(`DTNASC` − `DTULTMENST`) / 7⌋, com a diferença em dias de calendário, int16. NA se a DUM falta, não é analisável (8 dígitos ddmmaaaa de uma data que existe), é posterior ao parto ou é anterior a parto − 350 dias (corte antes do ⌊·⌋). Sem nenhum outro filtro; a faixa 20–45 e a concordância de ±1 semana são regras de uso dos artigos. A `DTULTMENST` bruta é lida no 06b e não sai dele.
- **Não regressão** (`testes/nao_regressao_ig_dum_sem.py`). Antes da troca, fases `pre` e `regen`:
  - mesmo nº de linhas;
  - as 51 colunas antigas do `nascimentos.parquet` ficaram idênticas, com 0 linha diferente e o mesmo hash por coluna;
  - as outras 8 saídas do 06b e as 19 do 06c, do 06d e do 07b, regeradas em rascunho, têm o md5 da `7e99bf94`;
  - no 99 simulado, só muda o md5 do `nascimentos.parquet`.

  Depois da troca, a fase `pos` (12/12) conferiu o manifesto novo: os 43 arquivos têm o mesmo nº de linhas e só o md5 do `nascimentos` mudou. A versão `4443971b` saiu igual à prevista.
- **Cobertura** (NV únicos, `logs/descritivo_ig_dum_sem_20261008.csv`): `ig_dum_sem` não NA em 36,3% em 2011 e 58,1% em 2012, caindo de 52,6% (2013) a 32,6% (2024). O NA é quase todo DUM ausente. Não analisável e parto sem data: 0 registros em 2011–2024 (contagem exata no log do descritivo). Posterior ao parto e anterior a 50 semanas: ≤ 0,01% ao ano. Uma DUM de ano absurdo que existe no calendário (0000, 9999) conta como "anterior" ou "posterior", e não como "não analisável": são menos de 10 no período, e o valor é NA do mesmo jeito. Entre os comparáveis (20–45 e `ga_sem` válido), a concordância de ±1 semana é de 99,9% ou mais; a igualdade exata, de 73,5% a 80,8%, mais baixa nos anos bissextos.
- **TPMETESTIM = 8** (todos os NV, 2012–2024): igualdade exata de 79,13%, contra 79,1% no Q2d de 07/10. De 2013 em diante, a DUM está praticamente só no código 8: a cobertura da `ig_dum_sem` é igual à fração do código 8, e não maior. A DUM nos registros em branco é de 2011–2012.

**NA de propósito nas duas séries:**
- **2011:** colunas que dependem de IG; só as `*_sens2011` preenchidas.
- **25 a 31/12/2024:** colunas neonatais indexadas no nascimento (censura, flag `censura_neonatal_dez2024`; começa em 25/12 desde a correção c1).

**Totais da série principal, 2012–2024:**

| Item | Total |
|---|---:|
| `nv_unicos` | 13.791.848 |
| `ptb` | 1.405.697 |
| `obito_fetal_principal` | 115.789 |
| `obito_neonatal_precoce` | 64.275 |
| `obito_perinatal` | 180.064 |

**Conferência independente** (código separado): diferença 0 em NV, população do PTB, PTB e óbitos fetais nos 14 anos, e a série sem coorte igual à contagem direta.

**Logs agregados do 06b em `logs/`:**
- `fluxograma_exclusoes.csv`: Brasil (277 municípios) × ano, em **partições que fecham por soma**: total = não único + IG ausente (+ sem IG / excluído) + IG < 22 + 43–44 + ≥ 45 + IG fora de 22–42 + população principal + 22–42 sem data ou idade; e população principal = fora da coorte + na série. Tem a coluna `do_neonatal_idade_ausente_datas_ate6d` e usa "<10" com **supressão complementar**, para que nenhuma célula mascarada possa ser recuperada por subtração (auditoria A2).
- `validacao_e5_datas.csv`: com supressão complementar (neonatais = com as duas datas + sem alguma data) e a % de concordância omitida quando ela reconstruiria uma contagem suprimida (auditorias de 06/10/2026, A15 e B1).
- `criterios_inclusao_recorte.csv`: E10, por concentração.
- `totais_anuais.csv`: as duas versões da série (`versao` = principal ou sem coorte fixa), com NA onde a série é NA (2011, `*_sem_ig` no principal, `*_sens2011` fora de 2011).
- `obitos_por_criterio.csv`: ano × tipo, com o total e os critérios na mesma linha e supressão complementar.

**Gerado pelo 06d (2026-10-05):** `gestacoes_em_risco.parquet`, com município × dia × semana gestacional, longo e esparso (24.290.331 células > 0).
- **Colunas:** `CD_MUN6`, `data` (2012-01-01 a 2024-12-31), `semana` (22–42), `z_nv` e `z_fetal` (E7).
- **Definição:** uma gestação de início s está na semana j no dia t quando (t − s) // 7 = j e o término é ≥ t. Entram só gestações da coorte fixa: 13.791.848 de NV únicos com IG 22–42 e 115.789 fetais principais.
- **Conferências:** a soma das células é igual à soma dos dias em risco das gestações; a força bruta em código separado (`06d_validar_forca_bruta.py`) deu 5 de 5 combinações certas, diferença 0 (`logs/validacao_06d_forca_bruta.csv`).
- **Uso:** o Z_t da prematuridade usa `z_nv` nas semanas 22–36; o do óbito perinatal usa `z_nv + z_fetal` nas semanas 22–42. O W_t e o γ ficam para o R de cada artigo.

**Gerados pelo 06c (2026-10-05).** As regras estão em `logs/desvios_especificacao.md` (cinco entradas de 05/10 sobre o 06c) e na docstring do `06c_exposicao.py`.

**Versões da exposição.** As variáveis são `tmean`, `rh` e as quatro variantes de PM2.5, cada uma em três versões:
- `_nucleo`: série do município-núcleo da concentração, a mesma para todos os municípios dela;
- `_mun`: série do próprio município;
- `_rm_nv`: média dos municípios da concentração, ponderada pelo total de NV residentes em 2011–2024 e renormalizada sobre os municípios com dado no dia.

| Arquivo | Granularidade | Conteúdo |
|---|---|---|
| `serie_diaria_municipio_clima.parquet` | município × dia, 2010-12-11 a 2025-01-07 (277 × 5.142 = 1.424.334) | As colunas do `serie_diaria_municipio.parquet` mais `{tmean,rh,pm25,pm25_zero_na,pm25_local,pm25_local_zero_na}_mun` e `..._nucleo`. Contagens NA fora de 2011–2024; flags FALSE fora de 2011–2024 |
| `serie_diaria_municipio_clima_sem_coorte_fixa.parquet` | idem | Idem, a partir da série sem coorte fixa |
| `serie_diaria_recorte.parquet` | concentração × dia, mesma grade (26 × 5.142 = 133.692) | Soma das contagens dos municípios, NA quando a coluna é NA no dia; `periodo_principal`, `periodo_sens2011`, `censura_neonatal_dez2024`, `n_municipios`, `CD_MUN6_NUCLEO`; exposições `_nucleo` e `_rm_nv` |
| `serie_diaria_recorte_sem_coorte_fixa.parquet` | idem | Idem, a partir da série sem coorte fixa |
| `gestacoes_em_risco_recorte.parquet` | concentração × dia × semana, só células > 0 (2.500.825) | `recorte_principal`, `data`, `semana`, `z_nv`, `z_fetal`: soma dos municípios |
| `expo_semanal_{tmean,rh,pm25}_{nucleo,rm_nv}.parquet` | concentração × `dum_est` (26 × 5.479 = 142.454) | `recorte_principal`, `dum_est` (2010-01-01 a 2024-12-31, grade completa), `s01`..`s37`; cerca de 38 MB cada |
| `expo_semanal_{tmean,rh,pm25}_mun.parquet` | município × `dum_est` (277 × 5.479 = 1.517.683) | `CD_MUN6`, `dum_est`, `s01`..`s37`; de 280 a 410 MB cada |

**Matriz semanal.**
- **Semanas:** `s{k}` é a média dos dias `dum_est` + 7(k−1) a `dum_est` + 7k − 1 (semanas completas 0+0 a 36+6).
- **NA:** fica NA se faltar qualquer dia ou se a semana passar de 2025-01-31.
- **Não corta no parto:** nos pré-termo, o artigo põe NA nas semanas k > IG.
- **PM2.5:** só a variante `pm25`. As outras saem da série diária.
- **Ligação:** a chave de ligação com `nascimentos.parquet` é `dum_est` com `CD_MUN6`, ou com `recorte_principal` (pelo `concentracoes_urbanas_municipios.csv`). Com IG ajustada (+0 ou +6 dias), recalcula-se `dum_est` e liga-se do mesmo jeito.

**Totais da série por concentração, 2012–2024:**

| Versão | `nv_unicos` | `ptb` | `obito_perinatal` |
|---|---:|---:|---:|
| Com coorte fixa | 13.791.848 | 1.405.697 | 180.064 |
| Sem coorte fixa | 14.221.644 | 1.454.862 | 185.115 |

Os totais com coorte fixa são iguais aos da série municipal.

**NA nas exposições, na grade de 2010-12-11 a 2025-01-07:**
- **0%** em `tmean`, `rh`, `pm25` e `pm25_local`, nas três versões.
- **`pm25_zero_na` e `pm25_local_zero_na`:** 1,36% no `_nucleo`, 1,06% no `_rm_nv` e 1,26% no `_mun`.
- **Sem validação contra estações de superfície** (decisão de 06/10/2026): o PM2.5 é só CAMS EAC4, reanálise, a mesma fonte em todas as concentrações. Ver `logs/desvios_especificacao.md`.
- **Por concentração:** detalhe em `logs/dias_faltantes_pm25.csv`, nas versões `nucleo`, `rm_nv` (com os dias renormalizados) e `mun` (município-dias).
- **`pm25_zero_na`, em 2012–2024:** 1.676 dias sem dado no núcleo, somando as concentrações, até 361 numa só; 1.300 no `_rm_nv`.

**Conferências.**
- **Internas, no próprio 06c:**
  - entradas completas, sem chave nula nem duplicada;
  - um núcleo por recorte, dentro dele;
  - série estendida igual ao 06b, célula a célula;
  - soma do recorte igual à dos municípios, com chave única;
  - total das gestações em risco igual ao dos municípios.
  - Se algo falha, o script para antes de substituir qualquer saída: tudo vai primeiro para `_staging_06c/`.
- **Teste sintético:** `testes/teste_06c_sintetico.py`, 28/28. Inclui todas as células das 9 matrizes contra uma média móvel própria, os ramos de parada e o `main()` inteiro, com uma falha no meio. Mata os 18 mutantes testados.
- **Conferência independente:** `testes/conferencia_06c_independente.py`, em pandas, sem importar o 06c, 19/19. Compara, célula a célula e com NA no mesmo lugar:
  - as duas séries, nas duas versões (contagens, flags e exposições);
  - todas as 141 milhões de células das 9 matrizes, com diferença ≤ 1,1e-13;
  - o CSV inteiro;
  - as gestações em risco.
- **Auditoria independente e correção c2:** registradas em `logs/auditoria_20261002.md`. Rascunho e projeto têm md5 idêntico.

**Gerado pelo 07b (R):**

| Arquivo | Gerado por | Granularidade | Conteúdo |
|---|---|---|---|
| `pig_classificacao.parquet` | 07b (R) | NV único de 24–42 semanas com peso válido (chave `id_nasc`) | `pop_pig_principal`, `pig_sens_pretermo`, `ig21_ref_nao_verificada`, `ig21_z`, `ig21_z_extremo`, `pig_ig21`, `pig_ig21_p3`, `pig_ig21_g0`, `pig_ig21_g6`, `pig_pedreira`, `pig_oms`, `pig_oms_meio_semana`, `pig_oms_sem_sexo`. **Gerado em 05/10/2026** (14.827.644 linhas; ver `07_pig_referencia/FONTE.md`) |

Chaves de ligação: `CD_MUN6` (6 dígitos) + `data`; por concentração, `recorte_principal` + `data`. Para a exposição gestacional, `CD_MUN6` ou `recorte_principal` + `dum_est`. Para o PIG, `id_nasc`.
