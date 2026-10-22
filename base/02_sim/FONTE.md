# FONTE — SIM (Sistema de Informações sobre Mortalidade): óbitos fetais e neonatais precoces

**Data de acesso à documentação:** 2026-10-01 (America/Sao_Paulo)
**Responsável:** Ministério da Saúde, SVSA/DAENT/CGIAE; disseminação pelo DATASUS.

Os óbitos perinatais vêm do SIM, **não do SINASC**. Óbitos fetais estão no arquivo nacional DOFET; óbitos não fetais (incluindo os neonatais precoces) estão nos arquivos DO por UF de residência.

## 1. Onde baixar

| Item | Endereço |
|---|---|
| Óbitos não fetais por UF, residência (definitivo) | `ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/CID10/DORES/DO{UF}{AAAA}.dbc` |
| Óbitos fetais, nacional (definitivo) | `ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/CID10/DOFET/DOFET{AA}.dbc` (ano com **2 dígitos**) |
| Preliminares | `ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/PRELIM/DORES/` e `.../SIM/PRELIM/DOFET/` |
| Portal de dados abertos | https://dadosabertos.saude.gov.br/dataset/sim |
| Dicionário oficial ("Estrutura do SIM", atualizado 06/2025) | https://s3.sa-east-1.amazonaws.com/ckan.saude.gov.br/SIM/Dicionario_SIM_2025.pdf |

O padrão `DOFET{AA}` foi confirmado pelos arquivos já existentes no Forja (`DOFET23.dbc`, `DOFET24.dbc`). O diretório DORES é o mesmo usado no código do CliMaterna. No microdatasus, os sistemas equivalentes são `"SIM-DO"` e `"SIM-DOFET"`.

## 2. Versão e período

- O portal, em 2026-10-01, rotula só 2025 como "preliminar" e 2026 como "1ª prévia". Os arquivos de 2023 (atualizado em 16/09/2026) e 2024 (18/02/2026) aparecem sem rótulo; é inferência que sejam definitivos.
- Período baixado: **2011–2024**, ou seja, **378 arquivos DO** (14 anos × 27 UFs) mais **14 arquivos DOFET**, **todos do diretório definitivo** (download de 02/10/2026). A análise principal é 2012–2024. O SIM de 2011 não tem `SEMAGESTAC` (só a faixa `GESTACAO`) e entra só como sensibilidade (adendo v1.3, E18).
- Conferência (`98_aceite_fase1.py`): diferença 0 por UF × ano contra o CliMaterna (2011–2022) e contra o TabNet (2022–2024), no DO e no DOFET.
- Como no SINASC, o status efetivamente usado (definitivo ou preliminar) fica gravado.

## 3. Definição operacional do óbito perinatal (implementada em `06b_desfechos.py`)

Período perinatal (CID-10, OMS): de **22 semanas completas (154 dias) de gestação até 7 dias completos após o nascimento**.

| Componente | Fonte | Critério |
|---|---|---|
| Óbito fetal | DOFET, `TIPOBITO = 1` | Hierárquico (`criterio_fetal`): **a primeira variável disponível decide**: com `SEMAGESTAC` válido, entra só se ≥ 22 (não passa para `GESTACAO` nem para o peso); sem `SEMAGESTAC`, decide a `GESTACAO` (2–6 entra; 1 não entra); sem as duas, decide o `PESO` (≥ 500 g). Categorias `1_semagestac`, `2_gestacao` e `3_peso` (auditoria A14) |
| Óbito neonatal precoce | DO, `TIPOBITO = 2` | idade de 0 a 6 dias (ver codificação de `IDADE` abaixo); data-índice pelo E5 = `DTNASC` do registro de óbito; `DTOBITO` como sensibilidade; as duas como colunas (implementado no `06b_desfechos.py` em 05/10/2026) |

**`SEMAGESTAC` ignorado:** o dicionário define "9 – ignorado", e no dado aparece **99**. No DOFET 2012 há 860 registros (2,7%) com 99 e 51 com 9; em 2017, 514 e 16; em 2022, 383 e 18. Os dois valores são tratados como ausentes. Lidos como número, os 99 entrariam todos como ≥ 22 semanas.

**Regra única para `SEMAGESTAC`** (auditoria A11, 03/10/2026): os códigos **9 e 99 são ignorado** em todos os documentos e scripts. Uma tabela antiga das pendências (P-SIM) contou o 9 como válido. A diferença é pequena (51 registros no DOFET 2012, 0,16%), e a contagem oficial sai do 06b.

**Corte de IG do neonatal (E4):** o principal é único com `SEMAGESTAC` válido de 22 a 42 no DO; os sem IG válida vão para `obito_neonatal_precoce_sem_ig`, e os com IG fora de 22–42 só para o fluxograma. (Texto anterior, superado: "o critério vai como coluna e a escolha fica para o artigo".)

**Data-índice (E5):** o óbito fetal é indexado pela `DTOBITO`. O neonatal precoce é indexado pela `DTNASC` do registro de óbito, com a `DTOBITO` como sensibilidade. As duas datas ficam como colunas.

Data do óbito: `DTOBITO`, data-índice do óbito fetal (E5). Município: `CODMUNRES`; no óbito fetal, o dicionário instrui considerar a residência da mãe.

### ⚠️ Codificação de `IDADE`: o dicionário de 2025 diverge do dado

O texto do dicionário diz: *"O primeiro, de 1 dígito, indica a unidade da idade (se 1 = minuto, se 2 = hora, se 3 = mês, se 4 = ano, se = 5 idade maior que 100 anos)"*. Ele lista "dias" entre os subcampos, mas sem código de unidade para dias.

No dado (SIM 2012, óbitos não fetais, só contagem agregada) a distribuição do 1º dígito é:

| 1º dígito | n | Faixa do subcampo | Interpretação |
|---|---:|---|---|
| 0 | 2,706 | 01–59 | minutos |
| 1 | 6,382 | 00–23 | horas |
| 2 | 18,347 | 00–29 | dias |
| 3 | 11,684 | 01–11 | meses |
| 4 | 1,131,456 | 00–99 | anos |
| 5 | 6,825 | 00–21 | +100 anos |
| 9 | 3,766 | 99 | ignorado |

**Codificação adotada (a do dado, a mesma do `process_sim` do microdatasus): 0 = minutos, 1 = horas, 2 = dias, 3 = meses, 4 = anos, 5 = mais de 100 anos.** Neonatal precoce = 1º dígito 0 ou 1, ou 1º dígito 2 com subcampo ≤ 06. Seguir o texto do dicionário trocaria dias por meses e produziria um desfecho errado.

### CID-10 relevantes (causa básica, `CAUSABAS`)

O desfecho principal é o óbito perinatal **por todas as causas**. As marcações abaixo servem para análises de sensibilidade:

- **Cap. XVI, P00–P96**: algumas afecções originadas no período perinatal (`cb_cap16_perinatal`). Inclui P00–P04 (fatores maternos e complicações da gravidez/parto), P05–P08 (crescimento fetal e duração da gestação; P07 = prematuridade/baixo peso), P20–P29 (respiratórias e cardiovasculares; P20–P21 hipóxia/asfixia), P35–P39 (infecções), P95 (morte fetal de causa não especificada).
- **Cap. XVII, Q00–Q99**: malformações congênitas (na base: `anomalia_causabas` pela causa básica e `anomalia_qualquer_linha` por qualquer linha da declaração). A sensibilidade "sem anomalia" exclui esse grupo, porque anomalias têm pouca plausibilidade de efeito agudo da temperatura.
- Referência: CID-10 da OMS, https://icd.who.int/browse10/2019/en

## 4. Variáveis usadas (conferidas no dicionário E no esquema dos parquets SIM 2012 e DOFET 2012/2022 do Forja)

`TIPOBITO` (1 fetal; 2 não fetal) · `DTOBITO` (ddmmaaaa) · `DTNASC` · `IDADE` (ver acima) · `SEXO` · `RACACOR` (1 branca; 2 preta; 3 amarela; 4 parda; 5 indígena) · `CODMUNRES` · `CODMUNOCOR` · `LOCOCOR` · `IDADEMAE` · `ESCMAE` / `ESCMAE2010` · `QTDFILVIVO` / `QTDFILMORT` · `GRAVIDEZ` · `SEMAGESTAC` · `GESTACAO` · `PARTO` · `OBITOPARTO` (1 antes; 2 durante; 3 depois; 9 ign.) · `PESO` · `CAUSABAS` · `LINHAA`–`LINHAD`, `LINHAII`.

- `CODMUNRES`: o dicionário diz 7 caracteres, mas **no dado tem 6 dígitos** (conferido em SIM 2012 e DOFET 2012). A ligação usa os 6 primeiros dígitos do código IBGE.
- O arquivo DO de cada UF contém **só óbitos não fetais** (no SIM 2012, 100% `TIPOBITO = 2`); o DOFET contém **só fetais** (no DOFET 2012, 100% `TIPOBITO = 1`). O 06b filtra `TIPOBITO` mesmo assim, para não depender disso nos outros anos.

## 5. Endereço

Como no SINASC, **não há endereço, CEP ou setor censitário** na base pública; o caminho de acesso restrito é o mesmo (Nota Informativa nº 5/2025-DAENT/SVSA/MS, ngd@saude.gov.br; ver `01_sinasc/FONTE.md`, seção 5).

## 6. Referência de contagens (base CliMaterna, metadado do parquet)

| Ano | SIM-DO (nacional) | DOFET |
|---|---:|---:|
| 2012 | 1,181,166 | 32,229 |
| 2013 | 1,210,474 | 31,981 |
| 2014 | 1,227,039 | 32,145 |
| 2015 | 1,264,175 | 32,994 |
| 2016 | 1,309,774 | 30,210 |
| 2017 | 1,312,663 | 30,620 |
| 2018 | 1,316,719 | 30,690 |
| 2019 | 1,349,801 | 29,105 |
| 2020 | 1,556,824 | 28,993 |
| 2021 | 1,832,649 | 29,325 |
| 2022 | 1,544,266 | 27,394 |
| 2023–2024 | — (não existe na base antiga) | — |
