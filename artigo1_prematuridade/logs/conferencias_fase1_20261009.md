# Fase 1, A6: conferências agregadas

- **Gerado por:** `00_scripts/23_confere_fase1.R`, em 2026-10-09 21:12:57 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Entradas:** `01_saidas/fase1/serie_ptb_principal.rds` (A2), `serie_ptb_municipal.rds` (A3), `serie_ptb_espontaneo.rds` (A4), `wj_ptb_concentracao.csv` e `referencias_exposicao.csv`; A5.2 e A5.3 da Fase 0 refeita; `gestacoes_em_risco(nivel = "recorte")`, `nascimentos()` e `calendario()` da base.
- **Sigilo:** só agregados por concentração × janela, concentração × ano ou mais grossos, com "<10" e supressão complementar; nenhum valor de um único dia.

## 1. Cobertura

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

## 2. Totais de PTB na janela principal contra a A5.2 congelada

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

## 3. Offset

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

## 4. Recomputação independente do Z_tj

- **População da base no `z_nv`:** `pop_ptb & coorte_fixa_22` (código da base `00_scripts/06d_gestacoes_em_risco.py`, linha 50, lido sem rodar; `DICIONARIO.md`: "gestações em curso que terminaram em NV único com IG 22–42", só da coorte fixa). `pop_ptb` = único com IG 22–42. É a mesma população do w_j (`unico`, `ga_sem` 22–42, `coorte_fixa_22`; o 20 conferiu linha a linha). Não houve motivo para parar.
- **Recomputação:** a partir de `nascimentos()`, pela regra da base (a gestação de início s = `dum_est` está na semana j no dia t quando ⌊(t − s)/7⌋ = j e o término é ≥ t), semanas 22 a 42, para São Paulo, Sorocaba e Florianópolis em 5 datas da janela principal sorteadas com `set.seed(20261001)`: 2012-09-29, 2013-01-24, 2013-02-21, 2018-11-06, 2023-09-09.
- **Resultado:** **igual**, em 315 células comparadas (3 concentrações × 5 datas × 21 semanas). Os valores não são mostrados.

## 5. w_j (risco condicional de parto na semana j)

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

## 6. Estratos (janela principal)

- **Concentração × ano × mês:** 3.874 estratos; sem nenhum PTB: 0 (esperado 0; seriam removidos no modelo).
- **Município × ano × mês (A3):** 277 municípios, 41.273 estratos; sem nenhum PTB: 3.428 (removidos no ajuste da case time series).

## 7. Calendário (janela principal, 4.498 dias; igual nas 26 concentrações)

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

## 8. Referências de exposição (só exposição)

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

## 9. PTB espontâneo (A4; só anos inteiros de 2013 a 2023)

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

## 10. Case time series municipal (A3)

- **Municípios:** 277.
- **Dias-município com Z_t > 0 na janela principal:** 1.245.946 (de 1.245.946 = 277 × 4.498).
- **Municípios sem nenhum PTB na janela principal:** 0.
- **Nós da `tmean_mun` agrupada:** só gravados (`01_saidas/fase1/nos_tmean_mun_concentracao.csv`), sem ir para o retorno.

## Resultado

- **Todas as conferências obrigatórias passaram** (itens 1, 2, 3, 4, 6, 7, 8 e 9; os itens 3 (DP), 5 e 10 são descritivos).
- **Valores em formato de máquina** (entrada da autoauditoria; fora do git): `01_saidas/fase1/conferencias_valores.csv`, SHA-256 `f2912b6f08a15977fba35b1e442d6d9813fac7fb39ecacc393da153dc64f8c1b`.

`versao()` no fim: 4443971b.
