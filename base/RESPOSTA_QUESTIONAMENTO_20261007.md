# Resposta ao questionamento da base `7e99bf94`

- **De:** Claude Code, na pasta `/Volumes/Forja/Doc/dados_artigos_perinatais_clima`
- **Para:** chat de métodos (coordenação)
- **Data:** 07/10/2026

**Sigilo.** Tudo aqui é agregado: o conjunto das 26 concentrações × ano, concentração × período, ou semana gestacional somada.
- Contagens de 1 a 9 aparecem como "<10", sem o %.
- Quando uma tabela tem uma só célula "<10" numa identidade (total = soma das partes), a menor outra parte sai como "supr." (supressão complementar, a mesma regra do `suprimir` do 06b). Assim, nenhum "<10" pode ser recuperado por subtração.
- Nenhuma data de evento individual é publicada.

**Linha vermelha.** Nenhuma resposta cruza desfecho com temperatura, umidade ou PM2.5, nem descreve desfecho por estação, mês, região ou característica climática. Uma parte do Q5 ficou fora da linha vermelha, explicada lá.

**Versão da base:** `7e99bf94` antes e depois.
- Pela interface, às 18:01, em Python e em R.
- Na saída do script de respostas, no começo e no fim, com o md5 conferido contra o manifesto nos 12 arquivos lidos (`logs/questionamento_20261007_saida.txt`, linhas 2 e 434).

## Resumo

- **A base não mudou, e todas as perguntas foram respondidas.** Os totais calculados conferem com o log do 06b (`totais_anuais.csv`): 13.791.848 NV únicos, 115.789 óbitos fetais e 64.275 neonatais precoces na coorte fixa, em 2012–2024.
- **Três correções ao pedido:**
  1. **Nome da função:** é `serie_diaria(nivel = "recorte")`; não existe `nivel = "concentracao"`.
  2. **`TPMETESTIM` código 8:** aparece desde 2013, com 33% a 53% dos NV por ano, e não só em 2022. O dicionário oficial não o define. Pelo dado, o 8 marca os registros **com DUM**: 100% têm a DUM preenchida, contra 0,00% nos códigos 1, 2 e 9. Nenhum código identifica ultrassom.
  3. **Pedreira:** o valor exato é 817.753 ÷ 12.669.440 = **6,4545%**, ou seja, 6,45%. O 6,46% vinha da média dos % anuais já arredondados e foi corrigido na entrega.
- **Bordas:**
  - nas semanas 22–36, Z_t > 0 vai de 2012-01-01 a 2024-11-18, igual nas 26 concentrações;
  - as datas da coordenação (2012-01-04, 2024-11-15 e 2024-12-27) estão certas como limites de **evento**: o dado não tem nenhum evento fora delas;
  - na prematuridade, há 3 dias em cada borda com Z_t > 0 mas sem evento possível.
- **`GESTACAO` × `SEMAGESTAC`:** a faixa é derivada do `SEMAGESTAC` quando ele existe; em 2012 e 2013, a concordância é de 100% e o kappa é 1.
  - A série não tem PTB por faixa em 2012–2024.
  - O `nascimentos` tem a `gestacao_cat` em todos os anos, e o artigo pode montar essa série pela interface.
  - Criar a coluna na própria base gera uma versão nova; não fiz.
- **Ambiente R:**
  - R 4.5.1, dlnm 2.4.10, gnm 1.1.5, mixmeta 1.2.0, mvmeta 1.0.3, gigs 0.5.2.9000 (commit `fb58fe6…`);
  - splines2 não está instalado;
  - não existe `renv.lock`.
- **Dupla auditoria:** a auditoria independente achou 13 pontos. Reproduzi todos e corrigi 12; o achado 4 corrigi em parte e registrei o que fica com vocês. O mais grave era um "<10" que podia ser recuperado por subtração no Q2f (seção final).

---

## Q1. Nomes exatos das colunas

Fontes: `09_acesso/DICIONARIO.md` e `09_acesso/acesso.py` / `acesso.R`, que têm as mesmas funções. O `teste_dicionario.py` rodou em 07/10/2026 e confirmou as colunas dos 31 arquivos (`logs/teste_dicionario_20261007.txt`).

### Q1a–c. Exposições diárias: temperatura, umidade e PM2.5

| Variável | `_nucleo` | `_mun` | `_rm_nv` |
|---|---|---|---|
| Temperatura média | `tmean_nucleo` | `tmean_mun` | `tmean_rm_nv` |
| Umidade relativa | `rh_nucleo` | `rh_mun` | `rh_rm_nv` |
| PM2.5, dia UTC, zeros mantidos | `pm25_nucleo` | `pm25_mun` | `pm25_rm_nv` |
| PM2.5, dia UTC, zero = NA | `pm25_zero_na_nucleo` | `pm25_zero_na_mun` | `pm25_zero_na_rm_nv` |
| PM2.5, dia local | `pm25_local_nucleo` | `pm25_local_mun` | `pm25_local_rm_nv` |
| PM2.5, dia local, zero = NA | `pm25_local_zero_na_nucleo` | `pm25_local_zero_na_mun` | `pm25_local_zero_na_rm_nv` |

**Onde estão** (grade de 2010-12-11 a 2025-01-07):

| Versão | Arquivo | Função |
|---|---|---|
| `_nucleo` e `_rm_nv` | `06_processados/serie_diaria_recorte.parquet` (com coorte fixa) e `serie_diaria_recorte_sem_coorte_fixa.parquet` | `serie_diaria(nivel = "recorte", coorte_fixa = TRUE/FALSE)` |
| `_nucleo` e `_mun` | `06_processados/serie_diaria_municipio_clima.parquet` e `serie_diaria_municipio_clima_sem_coorte_fixa.parquet` | `serie_diaria(nivel = "municipio", coorte_fixa = TRUE/FALSE)` |

A versão `_rm_nv` só existe por concentração, e a `_mun` só por município.

**Séries de origem, sem sufixo:**
- `clima_municipal()` traz `tmean`, `rh_mean`, `tmax`, `tmin` e `pr`;
- `pm25_municipal()` traz `pm25`, `pm25_zero_na`, `pm25_local`, `pm25_local_zero_na`, `n_horarios` e `n_horarios_zero`;
- `diaria_recorte(var, versao_expo)`, com `versao_expo` = `"nucleo"` ou `"rm_nv"`, dá a série por concentração na cobertura inteira, de 2010-01-01 a 2025-01-31.

### Q1d. Matrizes semanais `s01`…`s37`

| Arquivo | Chave | Colunas | Função |
|---|---|---|---|
| `06_processados/expo_semanal_{tmean,rh,pm25}_nucleo.parquet` e `..._rm_nv.parquet` | `recorte_principal`, `dum_est` | `s01` … `s37` | `expo_semanal(var, "nucleo")`, `expo_semanal(var, "rm_nv")` |
| `06_processados/expo_semanal_{tmean,rh,pm25}_mun.parquet` | `CD_MUN6`, `dum_est` | `s01` … `s37` | `expo_semanal(var, "mun")` |

- **Variante de PM2.5:** a matriz gravada é só a do `pm25`. As outras três variantes, e também `tmax`, `tmin` e `pr`, saem de `matriz_semanal(var, versao_expo)`, com o mesmo cálculo.
- **Ligação com os nascimentos:** `ligar_expo_semanal(nasc, var, versao_expo, ajuste_dias = 3)`.
- **Grade:** `dum_est` vai de 2010-01-01 a 2024-12-31.
- **Definição:** `s{k}` é a média dos dias `dum_est` + 7(k−1) a `dum_est` + 7k − 1.
- **A matriz não corta no parto:** nos pré-termo, ponha NA nas semanas k > IG.

### Q1e. Calendário

Arquivo `06_processados/calendario_2010_2025.parquet`, lido por `calendario()`. Contagens de 2012–2024 no `q1e()`.

| Item | Coluna | Observação |
|---|---|---|
| Feriado nacional (lei federal) | `feriado_nacional` (0/1), com `feriado_nome` e `base_legal` | 8 por ano em 2012–2023; 9 em 2024, com 20/11 (Lei 14.759/2023) |
| Carnaval | `carnaval` (0/1) | **Uma coluna só**, marcada na segunda e na terça (2 dias por ano: 13 segundas e 13 terças em 2012–2024). Para separar os dois dias, use `dia_semana` (1 = segunda, 2 = terça) |
| Quarta de Cinzas | `quarta_cinzas` (0/1) | 1 dia por ano |
| Sexta-Feira da Paixão | `sexta_paixao` (0/1) | 1 dia por ano |
| Corpus Christi | `corpus_christi` (0/1) | 1 dia por ano |
| Outras | `data`, `ano`, `mes`, `dia_semana` (1 = segunda … 7 = domingo), `fim_de_semana` | — |

Em 2012–2024, que é o período conferido, nenhum dia dessas quatro colunas coincide com `feriado_nacional`.

### Q1f. Série diária por concentração

Função: `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` lê `serie_diaria_recorte.parquet`; com `coorte_fixa = FALSE`, lê `serie_diaria_recorte_sem_coorte_fixa.parquet`.

| Grupo | Colunas |
|---|---|
| Chave e identificação | `recorte_principal`, `tipo_recorte`, `data`, `n_municipios`, `CD_MUN6_NUCLEO` |
| Nascidos vivos e prematuridade | `nv_unicos`, `nv_multiplos_ou_ign`, `ptb`, `ptb_extremo`, `ptb_muito`, `ptb_moderado_tardio`, `nv_ig_43_44` |
| Óbitos, principal | `obito_fetal_principal`, `obito_neonatal_precoce` (na data do nascimento), `obito_perinatal` |
| `_idx_obito` | `obito_neonatal_precoce_idx_obito`, `obito_perinatal_idx_obito`. Não há `obito_fetal_idx_obito`: o fetal já é indexado no óbito |
| 24 h | `obito_ate24h`, `obito_perinatal_24h` |
| Sem anomalia | `obito_perinatal_sem_anomalia` |
| `_sem_ig` | `obito_fetal_sem_ig`, `obito_neonatal_precoce_sem_ig`: NA no arquivo com coorte fixa e preenchidas no sem coorte |
| 2011 | `ptb_gestacao_sens2011`, `nv_gestacao_sens2011`: só em 2011, NA nos outros anos |
| Flags | `periodo_principal`, `periodo_sens2011`, `censura_neonatal_dez2024` |
| Exposições | as de Q1a–c, versões `_nucleo` e `_rm_nv` |

### Q1g. Gestações em risco

| Nível | Função | Arquivo | Colunas |
|---|---|---|---|
| Concentração | `gestacoes_em_risco(nivel = "recorte")` (é o padrão) | `06_processados/gestacoes_em_risco_recorte.parquet` | `recorte_principal`, `data`, `semana`, `z_nv`, `z_fetal` |
| Município | `gestacoes_em_risco(nivel = "municipio")` | `06_processados/gestacoes_em_risco.parquet` | `CD_MUN6`, `data`, `semana`, `z_nv`, `z_fetal` |

**Os dois níveis existem.**

- **Unidade:** número de gestações em curso (`int32`). Uma gestação de início s está na semana j no dia t quando (t − s) // 7 = j e o término é ≥ t.
- **`z_nv`:** gestações que terminaram em NV único de 22–42 semanas.
- **`z_fetal`:** gestações que terminaram em óbito fetal principal.
- **Recorte:** só a `coorte_fixa_22`; `semana` de 22 a 42 (`int16`); `data` de 2012-01-01 a 2024-12-31.
- **Formato:** longo e esparso, só com as células > 0. A ausência de linha vale zero.

### Q1h. Flags de período e de coorte fixa

| Flag | Onde está | Definição |
|---|---|---|
| `periodo_principal` | `nascimentos.parquet`; `serie_diaria_municipio*`, `serie_diaria_recorte*`, `serie_diaria_municipio_clima*` | Ano 2012–2024. FALSE fora de 2011–2024 nos arquivos do 06c |
| `periodo_sens2011` | os mesmos | Ano 2011 |
| `coorte_fixa_22` | `nascimentos.parquet`, `obitos_perinatais.parquet` | s entre 2011-07-31 e 2024-03-05 |
| `coorte_fixa_37` | só no `nascimentos.parquet`; está embutida no `pop_pig_principal` do `pig_classificacao.parquet` | s entre 2011-04-17 e 2024-03-05 |
| `censura_neonatal_dez2024` | séries diárias | TRUE de 2024-12-25 a 2024-12-31. FALSE fora de 2011–2024 nos arquivos do 06c, inclusive de 2025-01-01 a 2025-01-07 |

**Nas séries, a coorte fixa não é coluna:** ela é a escolha do arquivo, `coorte_fixa = TRUE/FALSE`. Funções de acesso: `nascimentos(colunas)`, `obitos(colunas)` e `serie_diaria(...)`.

### Q1i. Colunas do PIG

Função: `pig(colunas, com_nascimentos)`, que lê `06_processados/pig_classificacao.parquet`.

| Curva / variante | Coluna |
|---|---|
| INTERGROWTH-21st, 7 × IG + 3 dias (principal) | `pig_ig21`; escore `ig21_z`; \|z\| > 5 em `ig21_z_extremo` |
| INTERGROWTH, p3 | `pig_ig21_p3` |
| INTERGROWTH, + 0 dia / + 6 dias | `pig_ig21_g0` / `pig_ig21_g6` |
| Pedreira 2011 (semana completa) | `pig_pedreira` |
| OMS (Kiserud 2017) por sexo, semana inteira | `pig_oms` (NA em 41–42) |
| OMS no meio da semana (7 × IG + 3, interpolado) | `pig_oms_meio_semana` (NA a partir de 40) |
| OMS sem sexo (Tabela 11) | `pig_oms_sem_sexo` (NA em 41–42) |
| Populações e flags | `pop_pig_principal`, `pig_sens_pretermo`, `ig21_ref_nao_verificada` (IG < 33) |

O escore z do INTERGROWTH só é gravado para o ajuste de +3 dias. Para +0 e +6, a base grava só a classificação.

---

## Q2. Códigos

**Fontes dos códigos:**
- SINASC: dicionário oficial `01_sinasc/doc_oficial/Estrutura_SINASC_para_CD.pdf`, "Arquivo atualizado em 12/2019" (CGIAE), com o texto copiado literalmente.
- `OBITOPARTO`: dicionário do SIM de 2025, transcrito em `02_sim/FONTE.md`; o PDF não está no disco.

**População:** as frequências são do **conjunto das 26 concentrações** (NV residentes nos 277 municípios, de qualquer `GRAVIDEZ`), por ano do arquivo. São a população do estudo, não o Brasil inteiro. Posso fazer a versão do Brasil inteiro pelo SINASC bruto, se precisarem.

**Leitura das tabelas:**
- o % é sobre todos os NV do ano;
- "vazio" é campo em branco;
- "0" é contagem zero;
- "0,00" é contagem de 10 ou mais abaixo de 0,005%.

### Q2a. `STTRABPART`

Dicionário: "1– Sim; 2– Não; 9– Ignorado" ("Houve indução do Trabalho de parto?"). O código 3 não existe no dicionário nem no dado.

| Ano | n | 1 | 2 | 9 | vazio |
|---|---:|---:|---:|---:|---:|
| 2011 | 1.225.863 | 12,72 | 36,90 | 3,25 | 47,13 |
| 2012 | 1.235.598 | 23,35 | 67,72 | 4,58 | 4,35 |
| 2013 | 1.236.836 | 22,58 | 70,71 | 4,20 | 2,50 |
| 2014 | 1.263.441 | 21,31 | 72,96 | 4,22 | 1,50 |
| 2015 | 1.281.436 | 21,04 | 73,55 | 3,87 | 1,54 |
| 2016 | 1.205.521 | 19,99 | 75,81 | 3,24 | 0,96 |
| 2017 | 1.222.093 | 18,90 | 77,04 | 3,21 | 0,85 |
| 2018 | 1.208.856 | 17,60 | 78,80 | 2,95 | 0,65 |
| 2019 | 1.159.588 | 17,35 | 79,69 | 2,31 | 0,65 |
| 2020 | 1.097.935 | 17,48 | 79,46 | 2,24 | 0,82 |
| 2021 | 1.053.313 | 17,91 | 78,69 | 2,32 | 1,09 |
| 2022 | 1.007.755 | 18,33 | 79,11 | 1,63 | 0,93 |
| 2023 | 989.549 | 18,44 | 79,69 | 1,34 | 0,53 |
| 2024 | 929.076 | 18,91 | 79,49 | 1,19 | 0,41 |

### Q2b. `STCESPARTO` (bruto) e `stcesparto_aj`

Dicionário: "1-Sim; 2-Não; 3 - Não se aplica; 9-Ignorado" ("Cesárea ocorreu antes do trabalho de parto iniciar").

O `stcesparto_aj` troca o vazio por 3 no parto vaginal (`PARTO` = 1). Contado registro a registro, ele difere do bruto **só em 2014 (540.212 NV) e 2015 (574.491)**, e em 0 nos outros anos.

| Ano | 1 | 2 | 3 bruto | 3 `_aj` | 9 | vazio bruto | vazio `_aj` |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2011 | 14,14 | 12,20 | 43,41 | 43,41 | 2,78 | 27,47 | 27,47 |
| 2012 | 29,32 | 20,33 | 42,57 | 42,57 | 4,38 | 3,39 | 3,39 |
| 2013 | 31,06 | 20,18 | 42,17 | 42,17 | 4,39 | 2,20 | 2,20 |
| 2014 | 30,96 | 20,29 | 2,21 | 44,97 | 2,26 | 44,27 | 1,52 |
| 2015 | 29,38 | 20,05 | 0 | 44,83 | 3,98 | 46,60 | 1,76 |
| 2016 | 28,94 | 20,64 | 45,50 | 45,50 | 3,60 | 1,32 | 1,32 |
| 2017 | 28,72 | 20,96 | 45,93 | 45,93 | 3,21 | 1,18 | 1,18 |
| 2018 | 28,50 | 21,91 | 46,09 | 46,09 | 2,70 | 0,81 | 0,81 |
| 2019 | 28,72 | 22,14 | 46,10 | 46,10 | 2,19 | 0,84 | 0,84 |
| 2020 | 29,11 | 22,24 | 45,67 | 45,67 | 1,99 | 0,99 | 0,99 |
| 2021 | 28,99 | 21,86 | 46,16 | 46,16 | 1,88 | 1,11 | 1,11 |
| 2022 | 29,97 | 22,32 | 45,16 | 45,16 | 1,77 | 0,78 | 0,78 |
| 2023 | 31,45 | 22,45 | 43,92 | 43,92 | 1,65 | 0,52 | 0,52 |
| 2024 | 32,58 | 22,30 | 43,11 | 43,11 | 1,59 | 0,42 | 0,42 |

### Q2c. `PARTO`

Dicionário: "1– Vaginal; 2– Cesário; 9– Ignorado".

| Ano | 1 | 2 | 9 | vazio |
|---|---:|---:|---:|---:|
| 2011 | 43,41 | 56,42 | 0,00 | 0,16 |
| 2012 | 42,57 | 57,29 | 0,00 | 0,13 |
| 2013 | 42,17 | 57,71 | 0,00 | 0,13 |
| 2014 | 42,76 | 57,15 | 0,00 | 0,09 |
| 2015 | 44,83 | 55,09 | 0,00 | 0,07 |
| 2016 | 45,49 | 54,45 | 0,00 | 0,05 |
| 2017 | 45,93 | 54,03 | 0,00 | 0,04 |
| 2018 | 46,09 | 53,86 | 0,00 | 0,05 |
| 2019 | 46,10 | 53,84 | 0,00 | 0,05 |
| 2020 | 45,67 | 54,29 | 0,00 | 0,04 |
| 2021 | 46,16 | 53,80 | 0,00 | 0,03 |
| 2022 | 45,16 | 54,81 | 0,00 | 0,03 |
| 2023 | 43,92 | 56,05 | 0,00 | 0,03 |
| 2024 | 43,11 | 56,86 | <10 | supr. |

### Q2d. `TPMETESTIM`

**O dicionário oficial (12/2019)** diz, literalmente: "1– Exame físico; 2– Outro método; 9– Ignorado" ("Método utilizado para verificar n° de semanas de gestação"). **O código 8 não está no dicionário.**

| Ano | 1 | 2 | 8 | 9 | vazio |
|---|---:|---:|---:|---:|---:|
| 2011 | 7,97 | 3,65 | 0 | 1,56 | 86,82 |
| 2012 | 17,08 | 11,43 | 0 | 2,76 | 68,73 |
| 2013 | 20,57 | 13,90 | 52,58 | 3,46 | 9,49 |
| 2014 | 24,13 | 16,98 | 46,50 | 3,77 | 8,62 |
| 2015 | 27,82 | 19,05 | 40,63 | 10,76 | 1,74 |
| 2016 | 29,61 | 21,37 | 37,61 | 10,14 | 1,27 |
| 2017 | 30,19 | 23,23 | 37,27 | 8,24 | 1,07 |
| 2018 | 30,53 | 22,60 | 38,39 | 7,63 | 0,86 |
| 2019 | 32,53 | 23,14 | 36,97 | 6,44 | 0,92 |
| 2020 | 31,84 | 24,23 | 35,71 | 7,21 | 1,00 |
| 2021 | 30,77 | 25,26 | 35,01 | 8,01 | 0,94 |
| 2022 | 30,48 | 27,34 | 34,23 | 7,43 | 0,53 |
| 2023 | 30,96 | 28,72 | 33,56 | 6,29 | 0,47 |
| 2024 | 30,08 | 31,55 | 32,67 | 5,22 | 0,48 |

**O código 8 aparece de 2013 a 2024, e não só em 2022.** Para ver o que ele marca, cruzei o código com a DUM (`DTULTMENST`) do SINASC bruto, nos 277 municípios, em 2012–2024 somados (função `q2d()`, com a data lida como no 06b):

| Código | n | % com `DTULTMENST` preenchida | % com DUM plausível (IG pela DUM 20–45 sem.) | % com `SEMAGESTAC` 22–44 | n com DUM plausível e `SEMAGESTAC` | % `SEMAGESTAC` = IG pela DUM, entre esses |
|---|---:|---:|---:|---:|---:|---:|
| 1 | 4.165.912 | 0,00 | 0,00 | 100,0 | 67 | 59,7 |
| 2 | 3.239.694 | 0,00 | 0,00 | 99,9 | 88 | 58,0 |
| **8** | 5.301.546 | **100,00** | **99,95** | 99,8 | 5.288.695 | 79,1 |
| 9 | 1.001.326 | 0,00 | 0,00 | 99,9 | 13 | <10 reg. |
| vazio | 1.182.519 | 60,72 | 60,67 | 80,8 | 715.531 | 75,2 |

Em 2022, o 8 tem 344.932 NV, com 100,00% de DUM preenchida e 80,2% de concordância. Os códigos 1, 2 e 9 de 2022 não têm nenhum registro com DUM plausível e `SEMAGESTAC`.

**Leitura** (inferência do dado, não do dicionário):
- o **8 marca os registros com DUM**, para os quais o método "não se aplica";
- o 1 (exame físico), o 2 (outro método) e o 9 (ignorado) ficam praticamente restritos aos registros sem DUM. Abaixo de 0,005% deles têm DUM: 67, 88 e 13 registros com DUM plausível e `SEMAGESTAC`, entre milhões.

**Nenhum código identifica ultrassom.** "Outro método" pode incluir o ultrassom, sem distinção. A variável separa, então, "DUM × exame físico × outro método × ignorado", e só a partir de 2013. Em 2011 e 2012 o 8 não aparece. No agregado de 2012–2024, 60,7% dos registros em branco têm DUM, e a maior parte desses brancos é de 2012. A conferência com a DUM não cobriu 2011.

**O significado oficial do 8 não está verificado.** O único documento achado na web com o 8 é um guia de implementação FHIR da Secretaria de Saúde de Goiás, que é fonte secundária e regional: [ValueSet método-idade-gestacional](https://fhir.saude.go.gov.br/r4/core/ValueSet-metodo-idade-gestacional.html). Nele, o 8 é "Outro método" (1 = exame físico, 9 = ignorado), o que não concilia com o dicionário federal, em que "Outro método" é o 2. Vale pedir ao DATASUS o dicionário vigente.

### Q2e. `GESTACAO`

Dicionário: "1– Menos de 22 semanas; 2– 22 a 27 semanas; 3– 28 a 31 semanas; 4– 32 a 36 semanas; 5– 37 a 41 semanas; 6– 42 semanas e mais; 9– Ignorado."

| Ano | 1 | 2 | 3 | 4 | 5 | 6 | 9 | vazio |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 2011 | 0,05 | 0,49 | 1,01 | 8,49 | 85,17 | 2,23 | 0,05 | 2,51 |
| 2012 | 0,05 | 0,53 | 1,11 | 10,31 | 81,93 | 2,69 | 0,01 | 3,37 |
| 2013 | 0,05 | 0,53 | 1,08 | 9,70 | 83,45 | 2,49 | 0,01 | 2,69 |
| 2014 | 0,05 | 0,54 | 1,03 | 9,43 | 85,07 | 2,19 | 0,00 | 1,70 |
| 2015 | 0,05 | 0,52 | 1,02 | 9,06 | 85,84 | 1,94 | 0,01 | 1,57 |
| 2016 | supr. | 0,54 | 1,02 | 9,25 | 86,26 | 1,62 | <10 | 1,27 |
| 2017 | 0,05 | 0,53 | 1,06 | 9,12 | 86,53 | 1,65 | 0,00 | 1,06 |
| 2018 | supr. | 0,54 | 1,05 | 9,27 | 86,66 | 1,58 | <10 | 0,85 |
| 2019 | 0,05 | 0,55 | 1,04 | 9,29 | 86,72 | 1,48 | 0,00 | 0,86 |
| 2020 | 0,05 | 0,55 | 1,06 | 9,47 | 86,57 | 1,30 | 0,01 | 1,00 |
| 2021 | 0,05 | 0,56 | 1,05 | 9,54 | 86,53 | 1,32 | 0,01 | 0,93 |
| 2022 | supr. | 0,58 | 1,09 | 9,96 | 86,49 | 1,29 | <10 | 0,53 |
| 2023 | 0,06 | 0,59 | 1,08 | 10,05 | 86,54 | 1,21 | 0,00 | 0,47 |
| 2024 | supr. | 0,60 | 1,10 | 10,41 | 86,29 | 1,05 | <10 | 0,48 |

### Q2f. `OBITOPARTO` (DOFET)

Dicionário do SIM (via `02_sim/FONTE.md`): 1 = antes, 2 = durante, 3 = depois, 9 = ignorado.

| Ano | Todos os fetais: n | 1 | 2 | 3 | 9 | vazio | Fetal principal: n | 1 | 2 | 3 | 9 | vazio |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2011 | 12.092 | 92,76 | 0 | 0 | 1,82 | 5,43 | — | — | — | — | — | — |
| 2012 | 12.767 | 89,41 | 3,27 | 0 | 1,85 | 5,48 | 9.530 | 93,74 | 3,21 | 0 | 1,31 | 1,74 |
| 2013 | 12.507 | 90,05 | 2,72 | 0 | 1,77 | 5,46 | 9.605 | 93,96 | 2,92 | 0 | 1,13 | 1,99 |
| 2014 | 12.639 | 90,66 | 2,68 | <10 | supr. | 4,96 | 10.019 | 94,35 | 2,53 | <10 | supr. | 2,04 |
| 2015 | 13.155 | 90,65 | 3,27 | 0 | 1,43 | 4,65 | 10.388 | 94,37 | 3,13 | 0 | 1,03 | 1,47 |
| 2016 | 11.911 | 90,71 | 3,60 | 0 | 1,55 | 4,13 | 9.540 | 93,67 | 3,61 | 0 | 1,19 | 1,53 |
| 2017 | 12.097 | 90,50 | 3,93 | 0 | 1,97 | 3,60 | 9.706 | 93,72 | 3,64 | 0 | 1,46 | 1,18 |
| 2018 | 12.161 | 90,25 | 4,00 | 0 | 2,06 | 3,69 | 9.718 | 93,41 | 3,95 | 0 | 1,41 | 1,22 |
| 2019 | 11.371 | 90,34 | 4,31 | 0 | 1,63 | 3,72 | 9.119 | 93,63 | 3,90 | 0 | 1,06 | 1,40 |
| 2020 | 11.521 | 89,62 | 4,92 | 0 | 2,13 | 3,33 | 9.251 | 92,71 | 4,44 | 0 | 1,57 | 1,28 |
| 2021 | 11.340 | 89,33 | 4,93 | 0 | 2,17 | 3,57 | 9.004 | 92,69 | 4,58 | 0 | 1,47 | 1,27 |
| 2022 | 10.552 | 89,46 | 5,50 | 0 | 1,85 | 3,19 | 8.236 | 92,96 | 4,89 | 0 | 1,30 | 0,85 |
| 2023 | 10.104 | 88,34 | 5,41 | 0 | 3,21 | 3,04 | 7.908 | 91,59 | 4,68 | 0 | 2,88 | 0,85 |
| 2024 | 9.390 | 88,94 | 5,18 | 0 | 2,51 | 3,38 | 7.147 | 92,88 | 4,31 | 0 | 1,75 | 1,06 |

- **O "durante" (2) não aparece em 2011, e o "depois" (3) é praticamente vazio.** O óbito intraparto fica entre 2,5% e 5,5% e cresce no tempo.
- **Unidade das colunas:** as duas contam pelo `ano_obito` (ano do arquivo do SIM). "Todos os fetais" inclui qualquer `GRAVIDEZ` e qualquer critério; o "fetal principal" é o da série, sem a restrição da coorte fixa.

---

## Q3. PIG por Pedreira: numerador e denominador

População principal: 2012–2024, NV únicos a termo, `coorte_fixa_37`, \|z\| ≤ 5 e sexo conhecido.

| Curva | Numerador (PIG) | Denominador | % exato |
|---|---:|---:|---:|
| **Pedreira** | **817.753** | **12.669.440** | **6,4545%** |
| INTERGROWTH-21st (+3 dias) | 1.139.462 | 12.669.440 | 8,9938% |
| OMS por sexo (37–40 semanas; 1.085.255 de 41–42 ficam NA) | 1.835.341 | 11.584.185 | 15,8435% |

- **O valor certo é 6,45%.** O 6,46% vinha da média anual ponderada dos % do `pig_resumo_ano.csv` já arredondados a 2 casas (6,4553%), que passa a fronteira do arredondamento. Corrigi a seção 5 de `ENTREGA_COORDENACAO_7e99bf94_20261007.md`.
- **A conciliação A5** traz 6,45% para esta população e 6,50% para a população de antes do filtro \|z\| ≤ 5, sem o qual entram 6.218 NV a mais. Os dois números não conflitam.

## Q4. Casos de PIG por concentração e curva (população principal, 2012–2024)

| Concentração | População principal | INTERGROWTH | Pedreira | Classificados pela OMS (37–40) | OMS (37–40) |
|---|---:|---:|---:|---:|---:|
| São Paulo/SP | 3.208.457 | 289.580 | 209.925 | 2.989.241 | 483.305 |
| Rio de Janeiro/RJ | 1.692.296 | 153.617 | 111.270 | 1.541.895 | 246.054 |
| Belo Horizonte/MG | 708.082 | 75.352 | 53.938 | 645.157 | 121.112 |
| Brasília/DF | 610.235 | 63.360 | 45.270 | 548.744 | 97.652 |
| Recife/PE | 577.088 | 48.337 | 33.938 | 515.064 | 74.325 |
| Porto Alegre/RS | 534.751 | 38.996 | 27.990 | 490.644 | 66.338 |
| Fortaleza/CE | 503.853 | 40.500 | 28.466 | 451.797 | 62.302 |
| Curitiba/PR | 496.181 | 39.293 | 28.821 | 468.864 | 68.114 |
| Salvador/BA | 487.867 | 49.219 | 34.895 | 429.726 | 75.148 |
| Manaus | 420.162 | 35.684 | 25.355 | 391.185 | 61.917 |
| Goiânia/GO | 375.366 | 36.860 | 26.406 | 347.180 | 58.477 |
| Belém/PA | 299.002 | 33.021 | 23.815 | 269.341 | 47.033 |
| Campinas/SP | 289.753 | 24.842 | 17.643 | 267.708 | 41.326 |
| Vitória/ES | 286.846 | 24.264 | 17.019 | 257.176 | 40.856 |
| Baixada Santista/SP | 235.438 | 20.608 | 14.860 | 216.122 | 33.138 |
| São Luís/MA | 221.373 | 22.373 | 15.664 | 189.800 | 30.452 |
| São José dos Campos/SP | 215.485 | 17.743 | 12.906 | 201.927 | 29.201 |
| Maceió/AL | 193.168 | 18.406 | 12.758 | 169.996 | 26.891 |
| Natal/RN | 186.706 | 15.545 | 11.091 | 165.654 | 22.780 |
| João Pessoa/PB | 186.137 | 16.342 | 11.413 | 164.063 | 24.009 |
| Teresina/PI | 169.125 | 16.247 | 11.553 | 150.625 | 24.295 |
| Aracaju/SE | 168.037 | 12.132 | 8.846 | 157.311 | 21.759 |
| Cuiabá/MT | 165.241 | 12.604 | 9.260 | 152.213 | 20.392 |
| Florianópolis/SC | 154.180 | 11.050 | 7.612 | 136.120 | 18.260 |
| Campo Grande | 152.311 | 12.390 | 8.914 | 139.835 | 20.645 |
| Sorocaba/SP | 132.300 | 11.097 | 8.125 | 126.797 | 19.560 |
| **Total** | **12.669.440** | **1.139.462** | **817.753** | **11.584.185** | **1.835.341** |

**Nenhuma concentração fica abaixo de 1.000 nem de 2.000 casos em nenhuma curva.** Os menores valores são de Florianópolis: 11.050 pelo INTERGROWTH, 7.612 por Pedreira e 18.260 pela OMS.

## Q5. Gestações em risco nas bordas

Z_t = Σ_j Z_tj por concentração, na série principal (2012-01-01 a 2024-12-31, 4.749 dias), calculado com `gestacoes_em_risco(nivel = "recorte")`.

| Faixa de semanas | Primeiro dia com Z_t > 0 | Último dia com Z_t > 0 | Dias com Z_t = 0 |
|---|---|---|---|
| 22–36 (`z_nv`, ou `z_nv` + `z_fetal`) | 2012-01-01, igual nas 26 | 2024-11-18, igual nas 26 | 43, igual nas 26: de 2024-11-19 a 2024-12-31 |
| 22–42 (`z_nv`, ou `z_nv` + `z_fetal`) | 2012-01-01, igual nas 26 | entre 2024-12-20 e 2024-12-27, conforme a concentração | de 4 a 11, todos no fim de 2024 |

- **Nenhum dia tem Z_t = 0 entre o primeiro e o último dia com Z_t > 0**, nas 26 concentrações e nas quatro combinações. Somar ou não o `z_fetal` não muda nenhuma borda.
- **Fora da linha vermelha:** o último dia por concentração nas semanas 22–42, e com ele o número de dias com Z_t = 0. O último dia com Z_t > 0 é a data do último término da coorte naquela concentração, ou seja, a data de um evento individual (um nascimento ou óbito fetal). Por isso sai só a faixa entre as 26.
- **Nas semanas 22–36 publico por concentração:** as bordas são as do desenho da coorte, iguais nas 26, e não dependem de nenhum registro isolado.

**As datas da coordenação estão certas como limites de evento.** Pela convenção s = término − (7 × IG + 3), um término na semana completa j cai no dia s + 7j + 3. Conferi, na série principal somada nas 26, que **não há nenhum evento fora desses limites**:

| Limite | Calendário | Eventos fora do limite, no dado |
|---|---|---|
| Primeiro PTB / NV possível | s mínimo + 157 = 2012-01-04 | 0 PTB e 0 NV antes de 2012-01-04 |
| Último PTB possível | s máximo + 255 = 2024-11-15 | 0 PTB depois de 2024-11-15 |
| Último término possível (perinatal) | s máximo + 297 = 2024-12-27 | 0 NV e 0 óbito fetal depois de 2024-12-27 |

Os 1.405.697 PTB da série principal caem todos de 2012-01-04 a 2024-11-15.

**Consequência para o modelo:**
- **Prematuridade:** de 2012-01-01 a 2012-01-03 e de 2024-11-16 a 2024-11-18, Z_t > 0 mas não pode haver PTB. Os 43 dias de 2024-11-19 em diante têm Z_t = 0 (log Z indefinido).
- **Perinatal:** depois de 2024-12-27 não há nenhum término possível.
- **Recomendação:** restringir a janela de ajuste às datas de evento possível (PTB: 2012-01-04 a 2024-11-15) ou declarar os 6 dias de borda. A escolha é da especificação.

## Q6. Censura neonatal de dez/2024

Conferido nos **seis** arquivos de série:
- os do 06b: `serie_diaria_municipio` e `serie_diaria_municipio_sem_coorte_fixa`;
- os do 06c: `serie_diaria_recorte`, `serie_diaria_recorte_sem_coorte_fixa`, `serie_diaria_municipio_clima` e `serie_diaria_municipio_clima_sem_coorte_fixa`. São os que a interface devolve.

| Coluna | Dias toda NA, 2012-01-01 a 2024-12-24 (de 4.742) | Dias toda NA, 2024-12-25 a 2024-12-31 (de 7) |
|---|---:|---:|
| `obito_neonatal_precoce`, `obito_perinatal`, `obito_ate24h`, `obito_perinatal_24h`, `obito_perinatal_sem_anomalia` | 0 | 7 |
| `obito_neonatal_precoce_sem_ig` (arquivos sem coorte) | 0 | 7 |
| `obito_fetal_principal`, `obito_neonatal_precoce_idx_obito`, `obito_perinatal_idx_obito`, `nv_unicos`, `ptb` | 0 | 0 |
| `obito_fetal_sem_ig` (arquivos sem coorte) | 0 | 0 |
| `obito_fetal_sem_ig`, `obito_neonatal_precoce_sem_ig` (arquivos com coorte) | 4.742 | 7 |

- **Confirmado:** as colunas neonatais indexadas no nascimento ficam NA em todas as linhas de 2024-12-25 a 2024-12-31, e não antes, nos seis arquivos.
- **O óbito fetal não fica NA**, nem as colunas `_idx_obito`, que são indexadas no óbito.
- **A flag acompanha:** `censura_neonatal_dez2024` é TRUE exatamente de 2024-12-25 a 2024-12-31.
- **NA por desenho, não por censura:**
  - no arquivo com coorte fixa, as duas `_sem_ig` são NA em todos os dias;
  - em 2011, todas as colunas que dependem de IG são NA.

**Alcance da censura.** No SIM de 2024 não há nenhum neonatal principal da coorte fixa nascido de 25 a 31/12/2024. A censura existe por outro motivo: os óbitos de janeiro de 2025 de quem nasceu até 27/12/2024 estão no DO 2025, que não foi baixado. Esse efeito não é mensurável na base; o desvio de 05/10 o descreve como mínimo na versão com coorte fixa.

## Q7. Ambiente R

| Item | Versão |
|---|---|
| R | 4.5.1 (2025-06-13) |
| dlnm | 2.4.10 |
| gnm | 1.1.5 |
| mixmeta | 1.2.0 |
| mvmeta | 1.0.3 |
| splines2 | **não instalado** (a base não usa) |
| gigs | 0.5.2.9000, r-universe da rOpenSci, `RemoteSha` = `fb58fe6596d4b289d5362c5efe00f882984d3186`, compilado em R 4.5.3 (2026-09-07) |
| renv | 1.2.4 |
| arrow | 21.0.0.1 |

**`renv.lock`: não existe** em `/Volumes/Forja/Doc` (busca recursiva). Não criei nenhum.

## Q8. IG dos NV únicos da coorte fixa

NV únicos da `coorte_fixa_22`, 26 concentrações, 2012–2024 somados.

| Semana | n | % |
|---|---:|---:|
| 22 | 5.341 | 0,039 |
| 23 | 7.062 | 0,051 |
| 24 | 9.895 | 0,072 |
| 25 | 11.641 | 0,084 |
| 26 | 14.965 | 0,109 |
| 27 | 17.795 | 0,129 |
| 28 | 22.289 | 0,162 |
| 29 | 24.850 | 0,180 |
| 30 | 35.962 | 0,261 |
| 31 | 45.850 | 0,332 |
| 32 | 73.181 | 0,531 |
| 33 | 107.600 | 0,780 |
| 34 | 182.297 | 1,322 |
| 35 | 293.045 | 2,125 |
| 36 | 553.924 | 4,016 |
| 37 | 1.313.679 | 9,525 |
| 38 | 2.994.157 | 21,710 |
| 39 | 4.234.956 | 30,706 |
| 40 | 2.782.081 | 20,172 |
| 41 | 901.325 | 6,535 |
| 42 | 159.953 | 1,160 |
| **Total** | **13.791.848** | 100 |

O total é igual à soma de `nv_unicos` de 2012–2024 lida do `logs/totais_anuais.csv` pelo próprio script.

## Q9. PTB pela faixa `GESTACAO`

### Q9a. A coluna existe para 2012–2024?

**Não como coluna da série.** As colunas `ptb_gestacao_sens2011` e `nv_gestacao_sens2011` só são preenchidas em 2011: o 06b as calcula com `ano == 2011` e a série põe NA nos outros anos.

**O que existe:** a `gestacao_cat` (`GESTACAO` bruta) está no `nascimentos.parquet` em **todos** os anos. O artigo pode montar a série de 2012–2024 pela interface, agregando `nascimentos(c("CD_MUN6", "data", "unico", "gestacao_cat"))` por concentração × dia, sem mexer na base.

**Para virar coluna da própria base** seria preciso:
1. mudar o 06b, para calcular as duas colunas em todos os anos;
2. rodar de novo o 06b e, por proveniência, o 06c, o 06d e o 07b, que dependem do `nascimentos`;
3. rodar o 08 e os testes.

Isso gera **uma versão nova da base**. Não fiz nada disso.

**Atenção à comparação:** a sensibilidade de 2011 é **sem coorte fixa**. A série comparável de 2012–2024 também teria de ser sem coorte.

### Q9b. Concordância `GESTACAO` × `SEMAGESTAC`, 2012 e 2013

NV únicos, 26 concentrações. Nas tabelas, as linhas são a `GESTACAO` e as colunas são a faixa calculada do `SEMAGESTAC`. "supr." é a supressão complementar.

**2012**

| `GESTACAO` | < 22 | 22–27 | 28–31 | 32–36 | 37–41 | 42–44 | ≥ 45 | ausente |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 564 | 0 | 0 | 0 | 0 | 0 | 0 | 14 |
| 2 | 0 | 5.482 | 0 | 0 | 0 | 0 | 0 | 89 |
| 3 | 0 | 0 | 11.636 | 0 | 0 | 0 | 0 | 160 |
| 4 | 0 | 0 | 0 | 113.478 | 0 | 0 | 0 | 1.250 |
| 5 | 0 | 0 | 0 | 0 | 983.256 | 0 | 0 | 17.045 |
| 6 | 0 | 0 | 0 | 0 | 0 | 31.005 | 1.778 | 141 |
| 9 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 126 |
| vazio | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 40.641 |

**2013**

| `GESTACAO` | < 22 | 22–27 | 28–31 | 32–36 | 37–41 | 42–44 | ≥ 45 | ausente |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | supr. | 0 | 0 | 0 | 0 | 0 | 0 | <10 |
| 2 | 0 | supr. | 0 | 0 | 0 | 0 | 0 | <10 |
| 3 | 0 | 0 | 11.387 | 0 | 0 | 0 | 0 | 19 |
| 4 | 0 | 0 | 0 | 107.151 | 0 | 0 | 0 | 99 |
| 5 | 0 | 0 | 0 | 0 | 1.017.855 | 0 | 0 | 1.710 |
| 6 | 0 | 0 | 0 | 0 | 0 | 29.030 | 1.550 | 25 |
| 9 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 86 |
| vazio | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 32.528 |

**PTB (< 37 semanas)**, entre os registros com `GESTACAO` 2–6 e `SEMAGESTAC` 22–44:

| Ano | < 37 nos dois | Só pela faixa | Só pela semana | ≥ 37 nos dois | n | Concordância | Kappa |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2012 | 130.596 | 0 | 0 | 1.014.261 | 1.144.857 | 100,000% | 1,0000 |
| 2013 | 124.103 | 0 | 0 | 1.046.885 | 1.170.988 | 100,000% | 1,0000 |

**O que a concordância perfeita mostra:** quando o `SEMAGESTAC` existe, a `GESTACAO` é derivada dele. A faixa e a semana só divergem em dois grupos:
- os registros que têm a faixa sem a semana: 18.685 nos códigos 2–6 em 2012 e cerca de 1,9 mil em 2013;
- o código 6 com `SEMAGESTAC` ≥ 45, que é IG inválida na base: 1.778 em 2012 e 1.550 em 2013.

A concordância não diz nada sobre 2011: nas 26 concentrações, 47,3% dos NV únicos de 2011 não tinham `SEMAGESTAC` válido (`fluxograma_exclusoes.csv`: 565.982 de 1.196.192).

## Q10. Lacunas do `pm25_local_zero_na` por cidade-núcleo, 2012–2024

Os valores foram contados no `pm25_municipal()` da cidade-núcleo, em 4.749 dias, e conferidos com o `logs/dias_faltantes_pm25.csv`: batem nos 26.

| Concentração | Dias sem valor | % |
|---|---:|---:|
| Campo Grande | 361 | 7,60 |
| Goiânia/GO | 332 | 6,99 |
| Brasília/DF | 332 | 6,99 |
| Teresina/PI | 179 | 3,77 |
| Vitória/ES | 84 | 1,77 |
| Belo Horizonte/MG | 82 | 1,73 |
| Cuiabá/MT | 82 | 1,73 |
| Curitiba/PR | 78 | 1,64 |
| Porto Alegre/RS | 57 | 1,20 |
| Natal/RN | 21 | 0,44 |
| São José dos Campos/SP | 15 | 0,32 |
| Salvador/BA | 15 | 0,32 |
| Aracaju/SE | 10 | 0,21 |
| Maceió/AL | 9 | 0,19 |
| Sorocaba/SP | 6 | 0,13 |
| Florianópolis/SC | 5 | 0,11 |
| Manaus | 3 | 0,06 |
| Belém/PA | 2 | 0,04 |
| Fortaleza/CE | 1 | 0,02 |
| São Luís/MA | 1 | 0,02 |
| Recife/PE | 1 | 0,02 |
| Baixada Santista/SP, Campinas/SP, João Pessoa/PB, Rio de Janeiro/RJ, São Paulo/SP | 0 | 0 |

**As lacunas são idênticas às do `pm25_zero_na` em todos os núcleos, e não é cópia.** Nos 277 municípios, em 2012–2024:
- nenhum dia tem NA em só uma das duas variantes;
- 16.706 dias-município têm NA nas duas;
- dos 1.298.767 dias-município com valor nas duas, os valores diferem em 1.298.738 e coincidem em 29.

**Por que o NA coincide:** o 06a conta os horários válidos de cada variante na sua própria janela, e um horário só vira NA quando todas as células do município são zero. A pendência P-PM25-ZERO registrou que os zeros do CAMS caem quase só às 12, 15, 18 e 21 UTC, horários que estão nas duas janelas. As janelas diferem só no horário das 00 UTC, de dias diferentes. Que esse horário nunca seja todo zero num município é **inferência**, compatível com a coincidência total, mas não testada à parte.

As lacunas de 1 a 9 dias são de exposição, não de desfecho, e por isso vão sem máscara.

## Q11. Óbitos principais da coorte fixa por semana gestacional

Óbitos fetais principais e neonatais precoces principais, `coorte_fixa_22`, data-índice de 2012 a 2024, 26 concentrações somadas.

| Semana | Óbito fetal | Neonatal precoce |
|---|---:|---:|
| 22 | 5.698 | 3.935 |
| 23 | 5.572 | 4.490 |
| 24 | 5.953 | 4.905 |
| 25 | 5.049 | 4.205 |
| 26 | 5.400 | 4.541 |
| 27 | 5.609 | 3.987 |
| 28 | 6.453 | 3.778 |
| 29 | 5.057 | 2.810 |
| 30 | 5.933 | 2.824 |
| 31 | 5.680 | 2.320 |
| 32 | 6.910 | 2.555 |
| 33 | 5.649 | 2.299 |
| 34 | 6.465 | 2.483 |
| 35 | 6.274 | 2.411 |
| 36 | 7.457 | 2.588 |
| 37 | 7.137 | 3.051 |
| 38 | 7.040 | 3.371 |
| 39 | 6.162 | 3.580 |
| 40 | 4.393 | 2.843 |
| 41 | 1.575 | 1.107 |
| 42 | 323 | 192 |
| **Total** | **115.789** | **64.275** |

- **Os totais são iguais aos da série principal**, lidos do `logs/totais_anuais.csv` pelo próprio script.
- **Leitura de dado:** nos fetais, as semanas 24, 28, 30, 32, 34 e 36 superam as duas vizinhas (por exemplo, 27: 5.609; 28: 6.453; 29: 5.057). A semana 26 é exceção. Isso sugere preferência por alguns valores no registro da IG, e pesa no cálculo de w_j. Não testei formalmente.

---

## Scripts e comandos

| Pergunta | Script ou fonte | Função |
|---|---|---|
| Q1 | `09_acesso/DICIONARIO.md`, `09_acesso/acesso.py` | — |
| Q1e | `00_scripts/testes/questionamento_20261007.py` | `q1e` |
| Q2 | idem | `q2`, `q2d` |
| Q3, Q4, Q5, Q6, Q8 | idem | `q3`, `q4`, `q5`, `q6`, `q8` |
| Q9b | idem | `q9` |
| Q10, Q11 | idem | `q10`, `q11` |
| Versão e md5, antes e depois | idem | `versao` |
| Q7 | `00_scripts/testes/questionamento_20261007_ambiente.R` | — |
| Conciliação A2/A3/A5 citada no Q3 | `00_scripts/testes/conciliacao_coordenacao_20261007.py` | — |

**Python**, de `00_scripts/`, um comando por linha:

```bash
export UV_PROJECT_ENVIRONMENT=$HOME/.venvs/dados_perinatais_clima
```
```bash
PYTHONPATH=. uv run python testes/questionamento_20261007.py
```

Para rodar só algumas perguntas, passe os nomes das funções, por exemplo `PYTHONPATH=. uv run python testes/questionamento_20261007.py q3 q8`.

**R**, da raiz do projeto:

```bash
Rscript 00_scripts/testes/questionamento_20261007_ambiente.R
```

**Saídas desta resposta**, com exit 0 e só agregados:
- `logs/questionamento_20261007_saida.txt`;
- `logs/questionamento_20261007_ambiente.txt`;
- `logs/teste_dicionario_20261007.txt`.

## Dupla auditoria

### Autoauditoria

| Conferência | Resultado |
|---|---|
| Totais contra a série principal, lidos dos logs pelo script | Q8: 13.791.848. Q11: 115.789 fetais e 64.275 neonatais. Q3/Q4: 12.669.440 (`pig_resumo_ano.csv`) |
| Lacunas do PM2.5 contra o log do 06c | Q10: as 26 batem |
| Dias com Z = 0 | Q5: 43 dias = de 2024-11-19 a 2024-12-31 |
| Bordas contra o calendário | 0 evento fora dos limites s + 157, s + 255 e s + 297 |
| Versão | `7e99bf94` e md5 conferido (12 de 12) no começo e no fim da execução |

### Auditoria independente

Feita por um subagente em contexto limpo, que leu só a resposta, os scripts, o dicionário, os logs agregados e o código, sem abrir parquet nem microdado. Cada achado foi reproduzido com código próprio antes de ser aceito.

| # | Gravidade | Achado | Reprodução | Correção |
|---|---|---|---|---|
| 1 | Alta | Q2f: com o n e os % de 2 casas publicados, o "<10" do código 3 em 2014 saía exato por subtração no fetal principal, e com só 2 valores possíveis em todos os fetais | Reproduzido com conta própria de intervalos. Nas tabelas com n na casa do milhão, o arredondamento impede a recuperação | Supressão complementar em todas as tabelas de código: a menor outra parte sai como "supr." (Q2c, Q2e, Q2f) |
| 2 | Média | Nenhuma saída registrava a versão, e o script lia os parquets sem passar pela conferência de md5 | Reproduzido: a saída anterior não tinha a versão | O script confere `versao()` e o md5 dos 12 arquivos pela interface, no começo e no fim |
| 3 | Média | Q2d: troquei por "—" valores que existiam (59,7; 58,0; 23,1); o parse da data não usava `zfill(8)`; a faixa de `SEMAGESTAC` era 1–44, não a da base; faltava máscara nos denominadores pequenos | Reproduzido | Q2d refeito: `zfill(8)` como no 06b, DUM preenchida separada de DUM plausível, `SEMAGESTAC` 22–44, máscara no numerador e no complemento. A leitura se mantém, com 67, 88 e 13 registros dos códigos 1, 2 e 9 com DUM, entre milhões |
| 4 | Média | Q5 publicava a data do último óbito fetal e neonatal e, por concentração, o último dia com Z_t > 0 nas semanas 22–42, que é a data de um evento individual | Reproduzido pela regra do 06d: Z_tj vai até o término de cada gestação | As datas de evento saíram. Nas semanas 22–42 sai só a faixa entre as 26; o limite da coordenação é conferido como "0 evento fora". **Em aberto:** a coordenação pediu o último dia por concentração; fica fora da linha vermelha |
| 5 | Baixa | Q9b 2013: a soma das duas células "<10" da coluna "ausente" saía por subtração com o fluxograma, mas cada célula sozinha não | Reproduzido | Supressão complementar também nas linhas da tabela cruzada. Com duas células mascaradas na coluna, segue a regra do 06b |
| 6 | Baixa | Q6 conferia os arquivos do 06b, mas não os `serie_diaria_municipio_clima*` que a interface devolve; e o "não antes" se apoiava em 5 dias | Reproduzido | Q6 agora confere os seis arquivos, em 2012-01-01 a 2024-12-24 inteiro |
| 7 | Baixa | Q1h dizia que a flag de censura é "data ≥ 2024-12-25", mas nos arquivos do 06c ela é FALSE em 2025 | Confirmado no dicionário | Definição corrigida |
| 8 | Baixa | Q10 usava como denominador todos os dias-município, inclusive os 16.706 com NA nas duas | Reproduzido: 1.298.767 comparáveis, 29 iguais | Denominador corrigido |
| 9 | Baixa | Q10: o horário dos zeros não aparecia em nenhuma saída | O horário está na pendência P-PM25-ZERO, que o auditor não podia ler; a parte "00 UTC nunca todo zero" é inferência | Fonte citada e inferência marcada |
| 10 | Baixa | Q9b usava o 42% do Brasil para 2011 | Reproduzido pelo fluxograma: 47,3% dos NV únicos das 26 concentrações sem `SEMAGESTAC` válido | Número trocado |
| 11 | Baixa | "A censura não tira nenhum óbito" enganava: os óbitos de janeiro de 2025 de quem nasceu até 27/12 não estão na base | Confirmado | Frase reescrita no Q6 |
| 12 | Baixa | As conferências de total no script eram textos fixos | Confirmado | O script lê os totais do `totais_anuais.csv` e compara |
| 13 | Baixa | Afirmações não verificáveis com os arquivos que o auditor podia ler | Confirmado | `teste_dicionario` gravado em log; link do guia de Goiás; diferença exata do `stcesparto_aj` por ano (Q2b); período conferido do calendário declarado (Q1e); origem do 6,50% explicada (Q3) |

**Sem achado em:** percentuais e arredondamentos (Q3, Q8, Q9b, Q10), datas de borda do Q5, ambiente R, definições do Q9a e linha vermelha (nenhuma resposta cruza desfecho com clima ou PM2.5).

## Versão da base, antes e depois

| Momento | Como | `versao()` |
|---|---|---|
| Antes, 18:01 | Interface em Python e em R | `7e99bf94` |
| Começo da execução final do script | `acesso.versao()` e `acesso.verificar()` em 12 arquivos | `7e99bf94`, md5 12 de 12 |
| Fim da execução final do script | idem | `7e99bf94`, md5 12 de 12 |
| Depois de escrever esta resposta, 18:43 | Interface em Python e em R | `7e99bf94` |

A base não mudou durante o questionamento.
