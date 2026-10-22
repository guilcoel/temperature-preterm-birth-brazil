# FONTE — Recortes de análise: grandes concentrações urbanas (IBGE)

**Data de acesso:** 2026-10-01 (documentação das RMs); downloads em 2026-10-02; script atual rodado em 2026-10-03 (America/Sao_Paulo)

A pasta guarda **dois** produtos do IBGE:

- **Unidade de análise:** as 26 grandes concentrações urbanas (seções 1 a 6).
- **Só documentação:** a composição legal das Regiões Metropolitanas (seção 7).

> **Atenção (auditoria de 03/10/2026, R1):** o 06a, o 06b, o 06d e o 06c já foram migrados para `concentracoes_urbanas_municipios.csv` e `cidade_nucleo.csv` em 05/10/2026. Falta o 07 (R), que ainda lê o nome antigo `nascimentos_rm.parquet` e está travado.

A troca de RM para concentração urbana foi decidida em 02/10/2026 e vale para os três estudos (ver `logs/desvios_especificacao.md`).

## 1. Produto oficial (unidade de análise)

IBGE, *Arranjos Populacionais e Concentrações Urbanas do Brasil*, 2ª ed. (Rio de Janeiro: IBGE, 2016), com base no Censo 2010.

- **Definição de concentração urbana (do `LEIA_ME_2ed.txt` oficial):** município isolado ou arranjo populacional com mais de 100 mil habitantes. Arranjo é o agrupamento de dois ou mais municípios com forte integração por movimento pendular para trabalho ou estudo, ou por contiguidade da mancha urbana.
- **Grande concentração urbana:** a base classifica 26 como "Grande" e 159 como "Média".
  - O corte de 750 mil habitantes vem da publicação. O texto da publicação **não foi conferido** nesta sessão; o `LEIA_ME` não traz o corte.
  - Os dados são coerentes com ele: a menor grande tem 779.704 habitantes e a maior média, 747.228 (Censo 2010).
- **Composição fixa** para todo o período de 2011 a 2024 (unidade espacial estável no DLNM). A delimitação é de 2010; a população de 2022 serve só para a cidade-núcleo e para descrever.
- **Duas versões oficiais da composição** (dicionário do IBGE, aba `ComposicaoRecortes_01_PorMun`):

  | Campo | O que é (segundo o dicionário) | Concentrações | Municípios | Pop 2010 |
  |---|---|---:|---:|---:|
  | `CodGrandeConcUrbana` | Composição básica | 26 | 256 | 77.865.512 |
  | `CodGrandeConcUrb_ConsidAnalise` (**usado**) | "considerada no texto de análise da publicação" | 26 | 277 | 79.124.493 |

  A diferença está toda em duas concentrações. Porto Alegre/RS entra pela 2ª integração do arranjo (29 municípios contra 12), que junta o arranjo de Novo Hamburgo/São Leopoldo. São José dos Campos/SP entra pela 1ª integração (10 contra 6), que junta Taubaté. **Os 256 municípios do texto de referência de Guilherme correspondem à composição básica.** A escolha de 277 está em `logs/desvios_especificacao.md`, 02/10/2026; reconfirmada por Guilherme em 03/10/2026 ("é nosso critério").

## 2. Arquivos (`originais/arranjos_populacionais_2ed/`)

Base: https://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/arranjos_populacionais/base_de_dados_2ed/

| Arquivo | Bytes | MD5 |
|---|---:|---|
| `ArranjosPopulacionais_mbd_2ed.zip` (Access `.mdb`, *personal geodatabase*) | 87.547.997 | ff551d31dfdcc07f79c930b9db5f7a3c |
| `DICIONARIO_ArranjosPopulacionais_2ed.xls` | 58.368 | 9a6bad67a5d8db65cf74d8d9a8120990 |
| `LEIA_ME_2ed.txt` | 1.426 | a0371ea8a66488c2f4455b1747d31ed7 |

Baixados em 2026-10-02.
- **Leitura:** `access-parser` 0.0.6 (Python puro, sem driver ODBC). O `.mdb` é extraído para um diretório temporário e apagado depois; é dado público, não microdado.
- **Tabelas usadas:**
  - `ComposicaoRecortes_01_PorMunicipio`, com o campo `CodGrandeConcUrb_ConsidAnalise` (o código da concentração, 7 dígitos, igual ao código do município-sede que representa o arranjo; ver seção 4);
  - `ConcentracoesUrbanas_ConsideradasAnalise_01`, a referência para a conferência.

## 3. Processamento (`04_regioes_metropolitanas.py`)

Roda depois do `05_shapefiles.py`, porque precisa da malha de 2024. O script **para com erro** quando:

- não houver exatamente 26 concentrações, ou um município aparecer em duas;
- o tipo da concentração não for reconhecido;
- o número de municípios ou a soma da população de 2010 de alguma concentração não bater com a tabela oficial das concentrações;
- o código e o nome do recorte não forem 1:1 (auditoria A3);
- algum município faltar na malha de 2024 ou no Censo 2022;
- a sede do IBGE não for membro da própria concentração;
- houver empate no maior município de 2022 (regra do E15 indefinida).

**Saídas** (MD5 no `logs/integridade.csv`, sistema `IBGE-concentracoes-tidy`):

| Arquivo | Linhas | Conteúdo | MD5 (2026-10-03) |
|---|---:|---|---|
| `concentracoes_urbanas_municipios.csv` | 277 | `CD_RECORTE`, `NM_RECORTE`, `TIPO_RECORTE`, `CD_MUN`, `CD_MUN6`, `NM_MUN`, `SIGLA_UF`, `POP_CENSO2010`, `POP_CENSO2022` | c118857dbc825f182735f847e927a8d7 |
| `cidade_nucleo.csv` | 26 | cidade-núcleo (E15: maior em 2022), sede do IBGE, `NUCLEO_DIFERE_SEDE`, nº de municípios e populações (seção 4) | 7da35560a5b6e5be0745561dbf2c7e58 |
| `municipios_novos_origem.csv` | 6 | E17 (seção 5) | 1468fb4728dc2eeb274672f93564a676 |

**Resultado:** 26 concentrações e 277 municípios; população de 79.124.493 em 2010 e 83.589.648 em 2022 (41,2% do Brasil).

| `TIPO_RECORTE` | Concentrações |
|---|---:|
| `arranjo` | 22 |
| `municipio_isolado` (Manaus; Campo Grande) | 2 |
| `arranjo_1a_integracao` (São José dos Campos/SP) | 1 |
| `arranjo_2a_integracao` (Porto Alegre/RS) | 1 |

A maior é São Paulo/SP (37 municípios; 20.673.280 hab. em 2022) e a menor, Campo Grande (898.100).

## 4. Cidade-núcleo (E15)

**Correção de 03/10/2026 (auditoria, R2): a premissa do desvio de 02/10 estava errada.**

- O código da concentração **não identifica "o" núcleo**. Ele é a **sede** que representa o arranjo. Pelo dicionário do IBGE (aba `Sedes_03_ArranjosPop`), a sede é a do município de maior população, "com exceção de Vitória/ES que é representado pela capital".
- O IBGE marca **vários núcleos** por arranjo (campo `Nucleo`, tabela `Municipios_06_Calibracao`), e "um arranjo populacional pode ter mais de um núcleo". Nas concentrações:

  | Concentração | Núcleos marcados pelo IBGE | Maior município em 2010 | Maior município em 2022 |
  |---|---|---|---|
  | Vitória/ES | Vitória, Vila Velha, Serra e Cariacica | Vila Velha | Serra |
  | Baixada Santista/SP | Santos, São Vicente, Guarujá e Praia Grande | Santos | Santos |
  | Porto Alegre/RS | Porto Alegre, Novo Hamburgo, São Leopoldo, Sapiranga e Ivoti | Porto Alegre | Porto Alegre |
  | São José dos Campos/SP | São José dos Campos e Taubaté | São José dos Campos | São José dos Campos |

  As outras 22 concentrações têm um núcleo só.

**Regra (decisão de Guilherme, 03/10/2026; revoga o desvio de 02/10):** a cidade-núcleo é o **município de maior população no Censo 2022**, nas 26 concentrações. É o padrão de Guilherme para todos os estudos: "maior número de pessoas expostas".

**Colunas do `cidade_nucleo.csv`** (desde 03/10/2026):
- `CD_MUN_NUCLEO`, `NM_MUN_NUCLEO`, `POP_CENSO2022_NUCLEO`: a cidade-núcleo pelo E15.
- `CD_MUN_SEDE_IBGE`, `NM_MUN_SEDE_IBGE`, `POP_CENSO2022_SEDE`: a sede do IBGE, só como referência.
- `NUCLEO_DIFERE_SEDE`: vale 1 só em **Vitória/ES**, onde o núcleo é **Serra** (3205002; 520.653 hab.) e a sede é Vitória (3205309; 322.869 hab.).

**O script para** se houver empate no maior município ou se a sede não for membro da concentração. Hoje não há empate em nenhuma das 26.

## 5. Municípios novos (E17)

São 6 os municípios da malha de 2024 que não existiam na base de 2010: Mojuí dos Campos/PA, Pescaria Brava/SC, Balneário Rincão/SC, Pinto Bandeira/RS, Paraíso das Águas/MS e Boa Esperança do Norte/MT.

**Nenhum encosta** (`intersects` na malha 2024) em município de concentração. Um município novo sempre faz divisa com aquele de onde saiu, então nenhum saiu de município das concentrações, e o recorte não muda. O ano de instalação e o município de origem continuam como **"não verificado"** no CSV, sem efeito na análise.

## 6. População do Censo 2022

| Item | Valor |
|---|---|
| Produto | IBGE, Censo Demográfico 2022, **tabela SIDRA 4709**: "População residente, Variação absoluta de população residente e Taxa de crescimento geométrico" (https://sidra.ibge.gov.br/tabela/4709) |
| Variável | 93, "População residente" (pessoas); período 2022; nível N6 (município) e N1 (Brasil) |
| Acesso | API de agregados do IBGE (`config.SIDRA_POP2022`), em 2026-10-02 às 15:46 (BRT). O script reaproveita o JSON se ele já existir |
| Originais | `originais/censo2022_pop_sidra4709_N6.json` (689.303 bytes; MD5 455a8a7ff0ddaa2421737178856826c0) e `..._N1.json` (223 bytes; MD5 0a9edff51dfd71ad45bc4ab2bb0ab06c) |
| Derivado | `populacao_censo2022.csv` (`CD_MUN`, `CD_MUN6`, `NM_MUN_UF`, `POP_CENSO2022`); MD5 5c6c35238f22f7f821354a5611b8fb75, idêntico ao gerado avulso em 02/10 |

**Conferência no script:** 5.570 municípios, códigos únicos, valores numéricos; soma dos municípios (203.080.756) = total do Brasil (N1). A tabela 4714 também traz a variável 93; os valores das duas não foram comparados.

## 7. RMs legais (só documentação)

IBGE, *Recortes Metropolitanos e Aglomerações Urbanas*: https://www.ibge.gov.br/geociencias/organizacao-do-territorio/divisao-regional/18354-recortes-metropolitanos-e-aglomeracoes-urbanas.html

- O IBGE **apenas compila** esses recortes. As RMs e AUs são instituídas por lei complementar estadual e as RIDEs por lei federal.
- Arquivos em `originais/`, de `.../estrutura_territorial/municipios_por_regioes_metropolitanas/Situacao_2020a2029/`:

| Arquivo | Bytes | MD5 |
|---|---:|---|
| `Composicao_RM_2024.xlsx` | 125.374 | e79147440aea15287b25324d35679f1c |
| `Relatorio_Alteracoes_RM_2024.xlsx` | 9.493 | 246826b84a9d39886f227f2a6ad89a30 |
| `Composicao_RM_2025.xlsx` | 128.460 | 0a1105b9c6c14eb7b1aa296c00e9a027 |
| `Relatorio_Alteracoes_RM_2025.xlsx` | 12.615 | 8551052f42c6a9c505eb3b4c7ac56c48 |

**Estrutura do xlsx:** duas abas.
- **Recortes metropolitanos:** `COD_RECMETROPOL`, `COD_CATMETROPOL`, `COD_SUBCATMETROPOL`, `COD_MUN`, `LEG`, `DATA` e outras.
- **Aglomerações urbanas:** as mesmas colunas, com `RECAU`, `CATAU` e `SUBCATAU`.
- O recorte é a **categoria** (`COD_CATMETROPOL`/`COD_CATAU`).
- **O código da categoria se repete entre as abas:** 00301, 00401 e 00501 são ao mesmo tempo uma AU (Franca/SP; Sul/RS; Litoral Norte/RS) e uma RM de Roraima.
  - Por isso, desde 2026-10-03, `CD_RECORTE` leva o prefixo da aba (`AU_` ou `RM_`) e o script exige código 1:1 com nome (auditoria A3).
  - Sem o prefixo, os `rm_municipios_*.csv` são idênticos byte a byte aos de 02/10. Os `rm_resumo_*.csv` têm o mesmo conteúdo, mas mudam a ordem das linhas, porque o prefixo altera a ordenação (auditoria R10).

**Saídas:** `rm_municipios_{2024,2025}.csv` (1 linha por município × recorte) e `rm_resumo_{ano}.csv`.

**Composição de 2024:** 1.480 linhas, 1.442 municípios e 87 recortes, assim distribuídos:

| Tipo | Recortes |
|---|---:|
| RM | 77 |
| RIDE | 3 |
| AU | 3 |
| COLAR | 2 |
| EXPANSAO | 1 |
| ENTORNO | 1 |

**Municípios em duas RMs:**
- **2024:** 26, todos em SC. Há também 12 municípios em RIDE e RM ao mesmo tempo.
- **2025:** 83 RMs e 27 municípios em duas RMs, em SC e em TO (auditoria R9).

**Relação com as concentrações:** 17 dos 277 municípios das concentrações não estão em nenhum recorte legal, nem em 2024 nem em 2025. São 8 de Aracaju, 5 de Porto Alegre, 2 do Rio de Janeiro, 1 de Recife e Campo Grande.

As decisões de desenho tomadas para as RMs (SC, RIDE, categorias periféricas, ≥ 1 milhão) foram **substituídas** pela unidade de concentração urbana e ficam só no histórico do `desvios_especificacao.md`.
