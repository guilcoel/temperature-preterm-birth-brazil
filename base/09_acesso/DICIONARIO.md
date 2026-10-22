# Dicionário de dados — dados_artigos_perinatais_clima

Base comum aos três artigos DLNM perinatal × clima: prematuridade, óbito perinatal e PIG.
- **Versão:** `versao` em `manifesto.json`, também devolvida por `versao()` nas interfaces.
- **Acesso:** `acesso.R` e `acesso.py`, mesmos nomes de função nas duas.
- **Regras e decisões:** `logs/desvios_especificacao.md`.
- **Fontes:** `FONTE.md` de cada pasta.

**Convenções**
- **Tipos:** os dos parquets são os do arquivo. Nos CSV, a interface devolve **texto** (`str (CSV)`); o conteúdo numérico aparece na definição e é convertido no uso.
- **Recorte:** as 26 grandes concentrações urbanas do IBGE, 277 municípios (`04_regioes_metropolitanas/`). `recorte_principal` = `CD_RECORTE` = código da concentração (7 dígitos). A cidade-núcleo é o município mais populoso no Censo 2022.
- **Município:** `CD_MUN6` = 6 primeiros dígitos do código IBGE, o padrão do DATASUS. `CD_MUN` = 7 dígitos.
- **IG** = `SEMAGESTAC`, em semanas completas. **s** (início da gestação) = data do término − (7 × IG + 3) dias.
- **Coorte fixa (E6):**
  - `coorte_fixa_22`: s entre 2011-07-31 e 2024-03-05;
  - `coorte_fixa_37`: s entre 2011-04-17 e 2024-03-05.
- **Períodos:** `periodo_principal` = 2012–2024; `periodo_sens2011` = 2011 (E18).
- **NA de propósito:**
  - 2011, nas colunas que dependem de IG;
  - a partir de 25/12/2024, nas colunas neonatais indexadas no nascimento (`censura_neonatal_dez2024`);
  - fora de 2011–2024, nas contagens das séries do 06c.
- **Sigilo** (coluna `sigilo` do manifesto; a interface avisa ao ler):
  - `microdado`: nunca exibir linha;
  - `restrito`: só agregados recorte × ano ou mais grossos, com contagem < 10 como "<10";
  - `publico`: sem restrição.

---

## Desfechos (06b)

### `06_processados/nascimentos.parquet`
**Sigilo:** microdado. Uma linha por nascido vivo residente nos 277 municípios, 2011–2024. Chave: `id_nasc`.

| Coluna | Tipo | Definição |
|---|---|---|
| `id_nasc` | int64 | Id estável: ano × 10⁹ + índice da UF × 10⁷ + linha no arquivo de origem. Interno; não identifica pessoa |
| `CD_MUN6` | str | Município de residência da mãe (`CODMUNRES`, 6 dígitos) |
| `data` | date | Data do nascimento (`DTNASC`) |
| `ano` | int16 | Ano do arquivo do SINASC |
| `ga_sem` | int16 | IG em semanas completas, válida de 22 a 44; fora disso, NA |
| `semagestac_bruto` | str | `SEMAGESTAC` como veio |
| `ig_cat` | str | `ausente` (vazio, 9 ou 99), `lt22`, `22_42`, `43_44`, `ge45` |
| `gestacao_cat` | str | `GESTACAO` bruta (faixas de IG; códigos no dicionário oficial do SINASC) |
| `metodo_ig` | str | `TPMETESTIM` bruto (método de estimação da IG) |
| `dum_est` | date | s = `data` − (7 × `ga_sem` + 3) |
| `unico` | bool | `GRAVIDEZ` = 1 |
| `gravidez` | str | `GRAVIDEZ` bruta |
| `grav_cat` | str | `unica`, `multipla` (2 ou 3) ou `ignorada` |
| `pop_ptb` | bool | População da prematuridade (E3): único com IG 22–42 |
| `ptb` | bool | `pop_ptb` com IG ≤ 36 |
| `ptb_extremo`, `ptb_muito`, `ptb_moderado_tardio` | bool | `pop_ptb` com IG ≤ 27; 28–31; 32–36 |
| `ig_43_44` | bool | Único com IG 43–44 (à parte) |
| `coorte_fixa_22`, `coorte_fixa_37` | bool | s dentro da coorte fixa (convenções) |
| `periodo_principal`, `periodo_sens2011` | bool | Ano 2012–2024; ano 2011 |
| `nv_gestacao_sens2011` | bool | 2011, único, `GESTACAO` 2–6 (22–42 semanas) (E18) |
| `ptb_gestacao_sens2011` | bool | 2011, único, `GESTACAO` 2–4 (22–36 semanas) (E18) |
| `peso_g` | int16 | `PESO` em g, válido de 200 a 7.000; fora disso, NA |
| `sexo` | str | `SEXO`: 1 = M, 2 = F, 0 = ignorado (letras M/F/I convertidas). Há também o código 9, fora do dicionário |
| `idade_mae` | int16 | `IDADEMAE`, válida de 10 a 60 |
| `escmae2010`, `escmae` | str | Escolaridade da mãe (`ESCMAE2010`, `ESCMAE`), códigos brutos |
| `raca_mae` | str | `RACACORMAE` bruta |
| `estciv_mae` | str | `ESTCIVMAE` bruta (covariável do PIG, E10) |
| `n_gest_ant` | int16 | `QTDGESTANT`, de 0 a 30 |
| `n_part_vag`, `n_part_ces` | int16 | `QTDPARTNOR`, `QTDPARTCES`, de 0 a 30 |
| `paridade` | int16 | `n_part_vag` + `n_part_ces`; NA se faltar alguma |
| `paridade_filvivo` | int16 | `QTDFILVIVO`, de 0 a 30 (sensibilidade) |
| `n_fil_mort` | int16 | `QTDFILMORT`, de 0 a 30 |
| `flag_paridade_incoerente` | bool | `paridade_filvivo` > 0 e `paridade` = 0 |
| `n_consultas` | int16 | `CONSPRENAT`, de 0 a 60 |
| `consultas_cat` | str | `CONSULTAS` bruta (faixas) |
| `parto` | str | `PARTO` bruto (1 = vaginal, 2 = cesáreo; ver dicionário) |
| `sttrabpart` | str | `STTRABPART` bruto: códigos 1, 2 e 9 (não há 3 no dado nem no dicionário) |
| `stcesparto` | str | `STCESPARTO` bruto |
| `stcesparto_aj` | str | `STCESPARTO`, com parto vaginal e campo vazio = "3" (não se aplica) |
| `apresentacao` | str | `TPAPRESENT` bruta |
| `robson` | str | `TPROBSON` bruto (grupo de Robson) |
| `idanomal`, `codanomal` | str | `IDANOMAL`, `CODANOMAL` brutos (anomalia congênita) |
| `uf_arquivo` | str | UF do arquivo de origem do DATASUS |
| `status_arquivo` | str | `definitivo` ou `preliminar` (diretório do DATASUS); nesta versão, todos `definitivo` |
| `ig_dum_sem` | int16 | IG pela DUM, em semanas completas, na escala do `SEMAGESTAC` (`ga_sem`): ⌊(`DTNASC` − `DTULTMENST`) / 7⌋, com a diferença em dias de calendário entre datas sem hora (sem fuso). **NA** quando a DUM está ausente, quando não é analisável (precisa ter 8 dígitos ddmmaaaa de uma data que existe), quando é posterior ao parto ou quando é anterior a parto − 50 semanas, ou seja, diferença > 350 dias. O corte é em dias, **antes** do ⌊·⌋: de 351 a 356 dias = NA, embora o piso desse 50. Também é NA se a data do parto não for válida. **Nenhum outro filtro.** **Regras de uso, que cabem aos artigos e não à base** (especificação v2.0.2, §3.5; decisões, seção 8): faixa plausível de 20 a 45 semanas, inclusive, e concordância \|`SEMAGESTAC` − `ig_dum_sem`\| ≤ 1. Na base, o `SEMAGESTAC` está em `semagestac_bruto` (texto, como veio) e em `ga_sem` (só 22–44). Com o `ga_sem`, ficam de fora SEMAGESTAC 20, 21 e 45; a escolha é do artigo. A `DTULTMENST` bruta não está em nenhum arquivo da base (minimização, LGPD). No PIG: `pig(com_nascimentos = "ig_dum_sem")` (junção 1:1 por `id_nasc`). Coluna nova da versão `4443971b` (08/10/2026); não existe na `7e99bf94` |

### `06_processados/obitos_perinatais.parquet`
**Sigilo:** microdado. Uma linha por óbito fetal (DOFET, `TIPOBITO` 1) ou neonatal precoce (DO, `TIPOBITO` 2, até 6 dias), residente nos 277 municípios, 2011–2024. Chave: `id_obito`.

| Coluna | Tipo | Definição |
|---|---|---|
| `id_obito` | int64 | Id estável como `id_nasc`; o DOFET soma 5 × 10⁸ |
| `tipo` | str | `fetal` ou `neonatal_precoce` |
| `CD_MUN6` | str | Município de residência (`CODMUNRES`) |
| `data_indice` | date | Data-índice (E5): fetal = `DTOBITO`; neonatal = `DTNASC` |
| `data_obito`, `data_nasc` | date | `DTOBITO`, `DTNASC` |
| `ano_obito` | int16 | Ano do arquivo do SIM |
| `ga_sem` | int16 | `SEMAGESTAC` de 1 a 47; 9 e 99 = ignorado (NA) |
| `semagestac_bruto` | str | `SEMAGESTAC` como veio |
| `gestacao_cat` | str | `GESTACAO` bruta |
| `peso_g` | int16 | `PESO`, válido de 1 a 6.999 g |
| `criterio_fetal` | str | Hierárquico (E4), em que a primeira variável disponível decide: `1_semagestac` (IG ≥ 22); senão `2_gestacao` (`GESTACAO` 2–6); senão `3_peso` (≥ 500 g); NA se não entra |
| `unico` | bool | `GRAVIDEZ` = 1 |
| `gravidez` | str | `GRAVIDEZ` bruta |
| `ig_22_42` | bool | `ga_sem` entre 22 e 42 |
| `s_ini` | date | s = `data_indice` − (7 × `ga_sem` + 3) |
| `coorte_fixa_22` | bool | s na coorte fixa |
| `principal` | bool | Único, IG 22–42, data-índice presente e `idade_valida`; fetal só por `1_semagestac` |
| `sem_ig` | bool | Único, sem IG, data-índice presente e `idade_valida`; fetal por `2_gestacao` ou `3_peso` |
| `idade` | str | `IDADE` bruta (0xx minutos, 1xx horas, 2xx dias) |
| `idade_valida` | bool | Minutos ≤ 59, horas ≤ 23 ou dias; fetal = verdadeiro |
| `ate24h` | bool | Neonatal com `IDADE` em minutos ou horas, ou 200 |
| `sexo` | str | `SEXO` bruto do SIM (ver `02_sim/FONTE.md`) |
| `raca_cor` | str | `RACACOR` bruta |
| `parto` | str | `PARTO` bruto |
| `obitoparto` | str | `OBITOPARTO` bruto (1 antes, 2 durante, 3 depois, 9 ignorado) |
| `idade_mae` | int16 | `IDADEMAE`, de 10 a 60 |
| `causabas` | str | `CAUSABAS` (CID-10) |
| `anomalia_causabas` | bool | `CAUSABAS` começa com Q |
| `anomalia_qualquer_linha` | bool | Algum Qnn na causa básica ou nas linhas A–D e II |
| `cb_cap16_perinatal` | bool | `CAUSABAS` começa com P |
| `uf_arquivo`, `status_arquivo` | str | Como no `nascimentos`; o DOFET vem num arquivo nacional (`BR`) |

### `06_processados/serie_diaria_municipio{,_sem_coorte_fixa}.parquet`
**Sigilo:** restrito. Município × dia, de 2011-01-01 a 2024-12-31 (277 × 5.114). Nomes exatos da especificação.
- **Com coorte fixa (principal):** só entram gestações da coorte fixa, e as colunas `*_sem_ig` são NA.
- **Sem coorte fixa:** sem essa restrição, e com as `*_sem_ig` preenchidas.
- **Contagens por data-índice** (E5): nascimento ou óbito.

| Coluna | Tipo | Definição |
|---|---|---|
| `CD_MUN6`, `data` | str, date | Chave |
| `nv_unicos` | int32 | NV únicos com IG 22–42 (população da prematuridade) |
| `nv_multiplos_ou_ign` | int32 | NV não únicos (múltiplos ou gravidez ignorada), sem coorte |
| `ptb`, `ptb_extremo`, `ptb_muito`, `ptb_moderado_tardio` | int32 | Prematuros (≤ 36; ≤ 27; 28–31; 32–36) entre os `nv_unicos` |
| `nv_ig_43_44` | int32 | NV únicos com IG 43–44 |
| `obito_fetal_principal` | int32 | Óbitos fetais `principal` (data = óbito) |
| `obito_fetal_sem_ig` | int32 | Óbitos fetais `sem_ig` |
| `obito_neonatal_precoce` | int32 | Neonatais `principal`, na data do **nascimento** |
| `obito_neonatal_precoce_sem_ig` | int32 | Neonatais `sem_ig`, na data do nascimento |
| `obito_perinatal` | int32 | `obito_fetal_principal` + `obito_neonatal_precoce` |
| `obito_neonatal_precoce_idx_obito` | int32 | Neonatais `principal`, na data do **óbito** |
| `obito_perinatal_idx_obito` | int32 | Fetais + neonatais, na data do óbito |
| `obito_ate24h` | int32 | Neonatais `principal` com `ate24h` |
| `obito_perinatal_24h` | int32 | `obito_fetal_principal` + `obito_ate24h` |
| `obito_perinatal_sem_anomalia` | int32 | Perinatal sem `anomalia_causabas` |
| `recorte_principal`, `tipo_recorte` | str | Concentração e tipo (arranjo, arranjo de 1ª ou 2ª integração, município isolado) |
| `periodo_principal`, `periodo_sens2011` | bool | 2012–2024; 2011 |
| `ptb_gestacao_sens2011`, `nv_gestacao_sens2011` | int32 | Só em 2011 (NA nos outros anos): NV únicos por `GESTACAO` 2–4 e 2–6 |
| `censura_neonatal_dez2024` | bool | Data ≥ 2024-12-25: colunas neonatais indexadas no nascimento = NA |

### `06_processados/gestacoes_em_risco.parquet`
**Sigilo:** restrito. Formato longo e esparso, só células > 0.
- **Granularidade:** município × dia (2012-01-01 a 2024-12-31) × semana gestacional 22–42 (E7).
- **Definição:** uma gestação de início s está na semana j no dia t quando (t − s) // 7 = j e o término é ≥ t. Entram só gestações da coorte fixa.

| Coluna | Tipo | Definição |
|---|---|---|
| `CD_MUN6`, `data`, `semana` | str, date, int16 | Chave |
| `z_nv` | int32 | Gestações em curso que terminaram em NV único com IG 22–42 |
| `z_fetal` | int32 | Idem, terminadas em óbito fetal `principal` |

---

## Clima, PM2.5 e calendário (06a, 06e)

### `06_processados/clima_municipio_diario_2010_2025.parquet`
**Sigilo:** público. BR-DWGD v_3.2.4 (0,1°), média ponderada por área no polígono do município. Município × dia, de 2010-01-01 a 2025-01-31.

| Coluna | Tipo | Definição |
|---|---|---|
| `CD_MUN`, `CD_MUN6`, `data` | str, str, date | Chave |
| `tmax`, `tmin` | double | Temperatura máxima e mínima do dia (°C) |
| `tmean` | double | (`tmax` + `tmin`) / 2 (°C) |
| `rh_mean` | double | Umidade relativa média do dia (%) |
| `pr` | double | Precipitação (mm) |

### `06_processados/pm25_municipio_diario_2010_2025.parquet`
**Sigilo:** público. CAMS EAC4 (0,75°, a cada 3 h), PM2.5 de superfície em µg/m³, ponderado por área. Mesma grade de datas do clima.

| Coluna | Tipo | Definição |
|---|---|---|
| `CD_MUN`, `CD_MUN6`, `data` | str, str, date | Chave |
| `pm25` | double | Média do dia UTC (00–21 UTC), zeros mantidos; NA se faltar horário |
| `pm25_zero_na` | double | Dia UTC, com zero exato = NA por célula; exige ≥ 6 dos 8 horários |
| `pm25_local` | double | Dia aproximadamente local (UTC−3: 03–21 UTC + 00 UTC do dia seguinte); NA em 2025-01-31 |
| `pm25_local_zero_na` | double | Idem, com zero = NA e ≥ 6/8 horários (em 2025-01-31 pode usar 7 horários) |
| `n_horarios` | int64 | Horários com dado no dia UTC |
| `n_horarios_zero` | int64 | Horários do dia UTC com zero exato em alguma célula do município |

### `06_processados/{clima,pm25}_pesos_municipio.parquet`
**Sigilo:** público. Pesos de área por célula da grade (BR-DWGD e CAMS).

| Coluna | Tipo | Definição |
|---|---|---|
| `CD_MUN` | str | Município (7 dígitos) |
| `i_lat`, `i_lon` | int64 | Índices da célula na grade |
| `w` | double | Peso da célula: área da interseção célula × município (só células válidas) dividida pela soma do município, ou seja, soma 1 por município; 1 no `vizinho_centroide` |
| `metodo` | str | `area` ou `vizinho_centroide` (município sem célula válida; nenhum nos 277) |
| `dist_graus` | double | Distância do centroide à célula usada (0 em `area`) |
| `frac_area_coberta` | double | Fração da área do município coberta por células válidas |

### `06_processados/calendario_2010_2025.parquet`
**Sigilo:** público. Um dia por linha, de 2010-01-01 a 2025-01-31. Só feriados de lei federal (`08_calendario/FONTE.md`).

| Coluna | Tipo | Definição |
|---|---|---|
| `data`, `ano`, `mes` | date, int32, int32 | Data |
| `dia_semana` | int32 | 1 = segunda … 7 = domingo |
| `fim_de_semana` | int64 | 1 se sábado ou domingo |
| `feriado_nacional` | int64 | 1 se feriado nacional por lei federal |
| `feriado_nome`, `base_legal` | str | Nome e lei |
| `carnaval`, `quarta_cinzas`, `sexta_paixao`, `corpus_christi` | int64 | 1 no dia; à parte, porque não são feriados nacionais por lei federal |

---

## Séries ligadas e exposições (06c)

Versões da exposição, sempre como colunas; o artigo escolhe:
- **`_nucleo`:** série do município-núcleo, a mesma para todo o recorte;
- **`_mun`:** série do próprio município;
- **`_rm_nv`:** média dos municípios do recorte, ponderada pelo total de NV de 2011–2024 e renormalizada sobre os municípios com dado no dia.

Variáveis: `tmean`, `rh` (= `rh_mean`), `pm25`, `pm25_zero_na`, `pm25_local`, `pm25_local_zero_na`.

### `06_processados/serie_diaria_recorte{,_sem_coorte_fixa}.parquet`
**Sigilo:** restrito. Concentração × dia, de 2010-12-11 a 2025-01-07 (26 × 5.142); é a **série principal** dos artigos de série temporal.
- **Contagens:** soma das colunas homônimas do `serie_diaria_municipio*`.
- **NA:** fora de 2011–2024, e onde a coluna é NA nos municípios (2011, censura, `*_sem_ig` na versão com coorte).
- **Flags:** FALSE fora de 2011–2024.

| Coluna | Tipo | Definição |
|---|---|---|
| `recorte_principal`, `tipo_recorte`, `data` | str, str, date | Chave e tipo |
| `nv_unicos`, `nv_multiplos_ou_ign`, `ptb`, `ptb_extremo`, `ptb_muito`, `ptb_moderado_tardio`, `nv_ig_43_44` | int32 | Como na série municipal |
| `obito_fetal_principal`, `obito_fetal_sem_ig`, `obito_neonatal_precoce`, `obito_neonatal_precoce_sem_ig`, `obito_perinatal`, `obito_neonatal_precoce_idx_obito`, `obito_perinatal_idx_obito`, `obito_ate24h`, `obito_perinatal_24h`, `obito_perinatal_sem_anomalia` | int32 | Como na série municipal |
| `ptb_gestacao_sens2011`, `nv_gestacao_sens2011` | int32 | Só em 2011 |
| `periodo_principal`, `periodo_sens2011`, `censura_neonatal_dez2024` | bool | Como na série municipal; FALSE fora de 2011–2024 |
| `n_municipios` | uint32 | Municípios do recorte |
| `CD_MUN6_NUCLEO` | str | Cidade-núcleo (6 dígitos) |
| `tmean_nucleo`, `rh_nucleo`, `pm25_nucleo`, `pm25_zero_na_nucleo`, `pm25_local_nucleo`, `pm25_local_zero_na_nucleo` | double | Exposição da cidade-núcleo |
| `tmean_rm_nv`, `rh_rm_nv`, `pm25_rm_nv`, `pm25_zero_na_rm_nv`, `pm25_local_rm_nv`, `pm25_local_zero_na_rm_nv` | double | Média do recorte ponderada por NV |

### `06_processados/serie_diaria_municipio_clima{,_sem_coorte_fixa}.parquet`
**Sigilo:** restrito. Município × dia, de 2010-12-11 a 2025-01-07 (277 × 5.142). Tem as colunas do `serie_diaria_municipio*`, com contagens NA e flags FALSE fora de 2011–2024, mais as exposições.

| Coluna | Tipo | Definição |
|---|---|---|
| `CD_MUN6`, `data` | str, date | Chave |
| `nv_unicos`, `nv_multiplos_ou_ign`, `ptb`, `ptb_extremo`, `ptb_muito`, `ptb_moderado_tardio`, `nv_ig_43_44` | int32 | Como na série municipal |
| `obito_fetal_principal`, `obito_fetal_sem_ig`, `obito_neonatal_precoce`, `obito_neonatal_precoce_sem_ig`, `obito_perinatal`, `obito_neonatal_precoce_idx_obito`, `obito_perinatal_idx_obito`, `obito_ate24h`, `obito_perinatal_24h`, `obito_perinatal_sem_anomalia` | int32 | Como na série municipal |
| `recorte_principal`, `tipo_recorte` | str | Concentração e tipo |
| `periodo_principal`, `periodo_sens2011`, `censura_neonatal_dez2024` | bool | Como na série municipal |
| `ptb_gestacao_sens2011`, `nv_gestacao_sens2011` | int32 | Só em 2011 |
| `tmean_mun`, `rh_mun`, `pm25_mun`, `pm25_zero_na_mun`, `pm25_local_mun`, `pm25_local_zero_na_mun` | double | Exposição do próprio município |
| `tmean_nucleo`, `rh_nucleo`, `pm25_nucleo`, `pm25_zero_na_nucleo`, `pm25_local_nucleo`, `pm25_local_zero_na_nucleo` | double | Exposição da cidade-núcleo do seu recorte |

### `06_processados/gestacoes_em_risco_recorte.parquet`
**Sigilo:** restrito. Concentração × dia × semana, só células > 0: soma do `gestacoes_em_risco` dos municípios.

| Coluna | Tipo | Definição |
|---|---|---|
| `recorte_principal`, `data`, `semana` | str, date, int16 | Chave |
| `z_nv`, `z_fetal` | int32 | Como no municipal |

### `06_processados/expo_semanal_{tmean,rh,pm25}_{nucleo,rm_nv}.parquet`
**Sigilo:** público. Matriz semanal gestacional (E8), concentração × início da gestação, em grade completa de 2010-01-01 a 2024-12-31 (26 × 5.479).

| Coluna | Tipo | Definição |
|---|---|---|
| `recorte_principal` | str | Concentração |
| `dum_est` | date | Início da gestação (liga com `nascimentos.dum_est` ou com um s recalculado: `ligar_expo_semanal`) |
| `s01`–`s37` | double | `s{k}` = média dos dias `dum_est` + 7(k−1) a `dum_est` + 7k − 1 (semanas completas 0+0 a 36+6). NA se faltar dia ou se a semana passar de 2025-01-31. **Não corta no parto** (pré-termo: NA nas semanas k > IG) |

### `06_processados/expo_semanal_{tmean,rh,pm25}_mun.parquet`
**Sigilo:** público. Igual à anterior, por município (277 × 5.479). Outras variáveis (por exemplo `pm25_zero_na`, `tmax`) saem com `matriz_semanal(var, versão)` na interface, com o mesmo cálculo.

| Coluna | Tipo | Definição |
|---|---|---|
| `CD_MUN6` | str | Município |
| `dum_est` | date | Início da gestação |
| `s01`–`s37` | double | Como acima |

---

## PIG (07a, 07b)

### `06_processados/pig_classificacao.parquet`
**Sigilo:** microdado. Uma linha por NV único de 24–42 semanas com peso válido. Chave: `id_nasc`, que liga com o `nascimentos`.
A IG pela DUM (`ig_dum_sem`, sensibilidade da §3.5) não é coluna deste arquivo, que não mudou: vem do `nascimentos` pela interface, com `pig(com_nascimentos = "ig_dum_sem")`. A junção é por `id_nasc`, único nos dois arquivos, e todo `id_nasc` do PIG está no `nascimentos` (testes `paridade_ig_dum_sem.py` e `.R`). Mantém a ordem e o nº de linhas do PIG.

| Coluna | Tipo | Definição |
|---|---|---|
| `id_nasc` | int64 | Chave do `nascimentos` |
| `pop_pig_principal` | bool | População principal do PIG (E8): IG 37–42, sexo conhecido, `coorte_fixa_37` e \|z\| ≤ 5 |
| `pig_sens_pretermo` | bool | Sensibilidade de pré-termo: IG 24–36, sexo conhecido, \|z\| ≤ 5 |
| `ig21_ref_nao_verificada` | bool | IG < 33: referência de muito pré-termo do INTERGROWTH ("não verificado", E8) |
| `ig21_z` | double | Escore z de peso INTERGROWTH-21st (gigs, 7 × IG + 3 dias); NA se o sexo for ignorado |
| `ig21_z_extremo` | bool | \|z\| > 5 |
| `pig_ig21` | bool | z < Φ⁻¹(0,10), com 7 × IG + 3 dias (principal) |
| `pig_ig21_p3` | bool | z < Φ⁻¹(0,03) |
| `pig_ig21_g0`, `pig_ig21_g6` | bool | PIG com 7 × IG e com 7 × IG + 6 dias (sensibilidades) |
| `pig_pedreira` | bool | Peso < p10 de Pedreira 2011 (sexo, semana completa) |
| `pig_oms` | bool | Peso < p10 da OMS/Kiserud 2017 por sexo na semana inteira; NA em 41–42 |
| `pig_oms_meio_semana` | bool | Idem, com o p10 interpolado em 7 × IG + 3; NA a partir de 40 |
| `pig_oms_sem_sexo` | bool | Peso < p10 da Tabela 11 (sem sexo); NA em 41–42 |

### `07_pig_referencia/oms_kiserud2017_p10.csv`
**Sigilo:** público. p10 do peso fetal estimado, semanas 14–40, com dupla leitura (`07_pig_referencia/FONTE.md`).

| Coluna | Tipo | Definição |
|---|---|---|
| `semana` | str (CSV) | Semana gestacional (valor da curva na semana inteira) (inteiro) |
| `sexo` | str (CSV) | `F` (Tabela 14), `M` (Tabela 15) ou `ambos` (Tabela 11) |
| `p10_g` | str (CSV) | p10 em gramas (inteiro) |
| `tabela` | str (CSV) | Tabela do artigo |

### `07_pig_referencia/pedreira2011_p10.csv`
**Sigilo:** público. p10 do peso ao nascer por sexo, semanas completas 22–42 (Table I), com dupla leitura.

| Coluna | Tipo | Definição |
|---|---|---|
| `semana` | str (CSV) | Semana completa (inteiro) |
| `sexo` | str (CSV) | `F` ou `M` |
| `p10_g` | str (CSV) | p10 em gramas (inteiro) |
| `tabela` | str (CSV) | `Table I` |
| `observacao` | str (CSV) | Incoerência do impresso, quando houver (p10 F de 33 semanas) |

---

## Recortes (04)

### `04_regioes_metropolitanas/concentracoes_urbanas_municipios.csv`
**Sigilo:** público. Os 277 municípios das 26 grandes concentrações urbanas (IBGE, *Arranjos Populacionais e Concentrações Urbanas do Brasil*, 2ª ed., 2016).

| Coluna | Tipo | Definição |
|---|---|---|
| `CD_RECORTE`, `NM_RECORTE` | str (CSV) | Código (7 dígitos) e nome da concentração |
| `TIPO_RECORTE` | str (CSV) | `arranjo`, `arranjo_1a_integracao`, `arranjo_2a_integracao` ou `municipio_isolado` |
| `CD_MUN`, `CD_MUN6`, `NM_MUN`, `SIGLA_UF` | str (CSV) | Município |
| `POP_CENSO2010`, `POP_CENSO2022` | str (CSV) | População nos Censos 2010 e 2022 (inteiro) |

### `04_regioes_metropolitanas/cidade_nucleo.csv`
**Sigilo:** público. Uma linha por concentração.

| Coluna | Tipo | Definição |
|---|---|---|
| `CD_RECORTE`, `NM_RECORTE`, `TIPO_RECORTE` | str (CSV) | Concentração |
| `N_MUNICIPIOS` | str (CSV) | Municípios na concentração (inteiro) |
| `POP_CENSO2010_RECORTE`, `POP_CENSO2022_RECORTE` | str (CSV) | População da concentração (inteiro) |
| `CD_MUN_NUCLEO`, `NM_MUN_NUCLEO`, `POP_CENSO2022_NUCLEO` | str (CSV) | Cidade-núcleo: o município mais populoso em 2022 (E15): código e nome (texto) e população (inteiro) |
| `CD_MUN_SEDE_IBGE`, `NM_MUN_SEDE_IBGE`, `POP_CENSO2022_SEDE` | str (CSV) | Sede segundo o IBGE (só referência): código e nome (texto) e população (inteiro) |
| `NUCLEO_DIFERE_SEDE` | str (CSV) | 1 se o núcleo difere da sede (só Vitória/ES, cujo núcleo é Serra) (inteiro) |

### `04_regioes_metropolitanas/municipios_novos_origem.csv`
**Sigilo:** público. Municípios instalados depois de 2010, na malha de 2024 (E17).

| Coluna | Tipo | Definição |
|---|---|---|
| `CD_MUN`, `NM_MUN`, `SIGLA_UF` | str (CSV) | Município novo |
| `CONCENTRACOES_VIZINHAS` | str (CSV) | Concentrações com que faz divisa (vazio se nenhuma) |
| `ENCOSTA_EM_CONCENTRACAO` | str (CSV) | 1 se encosta em município de concentração (inteiro) |
| `CD_MUN_ORIGEM`, `ANO_INSTALACAO` | str (CSV) | Preenchidos com "não verificado": como nenhum município novo encosta em concentração, a origem não foi levantada (E17) |
| `FONTE` | str (CSV) | Método da identificação (malha IBGE 2024 × base de Arranjos de 2016), não a lei de criação |

### `04_regioes_metropolitanas/populacao_censo2022.csv`
**Sigilo:** público. Censo 2022 (SIDRA, tabela 4709), todos os municípios.

| Coluna | Tipo | Definição |
|---|---|---|
| `CD_MUN`, `CD_MUN6` | str (CSV) | Município |
| `NM_MUN_UF` | str (CSV) | Nome e UF, como no SIDRA |
| `POP_CENSO2022` | str (CSV) | População residente (inteiro) |

---

## Logs agregados

Descritos em `logs/LEIAME_logs.md` e listados no manifesto, com md5. São públicos (agregados com "<10").
