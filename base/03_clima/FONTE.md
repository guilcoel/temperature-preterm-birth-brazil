# FONTE — BR-DWGD (Brazilian Daily Weather Gridded Data), Xavier et al.

**Data de acesso:** 2026-10-01 (página do autor); download dos zips em 2026-10-02 (America/Sao_Paulo)

## 1. Citação obrigatória

Xavier AC, Scanlon BR, King CW, Alves AI. New improved Brazilian daily weather gridded data (1961–2020). *International Journal of Climatology* 2022;42(16):8390–8404. https://doi.org/10.1002/joc.7731

## 2. Versão mais recente

Fonte: página oficial do autor, https://sites.google.com/site/alexandrecandidoxavierufes/brazilian-daily-weather-gridded-data

| Atributo | Valor |
|---|---|
| **Versão** | **v_3.2.4** ("April 2026: update grid (from 1961/01/01 to 2025/12/31, version v_3.2.4)"); no Google Earth Engine desde maio/2026 |
| Período | **1961-01-01 a 2025-12-31** |
| Resolução temporal | diária |
| Resolução espacial | **0,1° × 0,1°** |
| Cobertura | só território brasileiro; lat 33,85° S – 5,35° N; lon 73,85° O – 34,85° O |
| Variáveis | precipitação (`pr`, mm); temperatura máxima e mínima (`Tmax`, `Tmin`, °C); radiação solar (`Rs`, MJ/m²); umidade relativa (`RH`, %); vento a 2 m (`u2`, m/s); evapotranspiração (`ETo`, mm) |
| Relatório da versão | "currently under construction": https://drive.google.com/file/d/1BXtsNRcq3JYmO-RAIMOOIyqJI-mOpU7S/view |

Versões anteriores: v_3.2.3 (dez/2024, até 2024-03-20, com apoio do projeto Climaterna); v_3.2.2 (jun/2023, novo contorno da costa do NE); v_3.1 (mar/2023, mais pluviômetros em 2001–2022).

**Consequência para o período:** a v_3.2.4 cobre 2010-01-01 a 2025-01-31 inteiro (clima baixado; análise principal 2012–2024, sensibilidade 2011). O fator que limita o período é o DATASUS, e não o clima; por isso o estudo vai até **2024**. A base antiga do CliMaterna usa a **v_3.2.3**, que termina em 2024-03-20 e portanto **não cobre 2024 inteiro**; isso justifica baixar a v_3.2.4.

## 3. Temperatura média

**O BR-DWGD não fornece temperatura média diária.** Aqui ela é calculada como `tmean = (Tmax + Tmin) / 2`, convenção usual em DLNM quando só há extremos diários. Fica registrado como decisão metodológica.

## 4. Como obter

| Via | Endereço | Uso aqui |
|---|---|---|
| NetCDF compactado (Google Drive) | https://drive.google.com/drive/folders/11-qnvwojirAtaQxSE03N0_SUrbcsz44N | **principal**: `03_download_clima.py` lista a pasta (gdown), baixa os zips diários `pr_Tmax_Tmin_NetCDF_Files.zip` e `ETo_u2_RH_Rs_NetCDF_Files.zip` e extrai só os blocos de `Tmax`, `Tmin`, `RH` e `pr` que cobrem 2010-01-01 a 2025-01-31 (o mês extra de 2025 serve ao controle negativo com temperatura futura) |
| NetCDF (Dropbox) | https://www.dropbox.com/scl/fo/t225fii1ir4o5ozga0o3u/ALZsq0F4zeCykN4GgoD8D6s?rlkey=93nkonzxn08c4wioztkjq0x52&st=oq6g1i0m&dl=0 | alternativa manual |
| Google Earth Engine | `ee.ImageCollection('projects/ee-alexandrexavier/assets/BR-DWGD')` | alternativa (exige conta GEE) |
| Dado municipal pronto (DataClimaBR) | https://ee-deborapdsouza.projects.earthengine.app/view/dataclimabr | conferência, não fonte principal |
| Códigos do autor | https://github.com/AlexandreCandidoXavier/BR-DWGD | lógica de extração municipal replicada |

**Estrutura da pasta (listada em 02/10/2026; `03_clima/_listagem_drive.json` e `_README_drive_BRDWGD.txt`).** A pasta não tem NetCDF solto, só zips. Cada zip diário traz as variáveis de 1961–2025 em três blocos (1961–1980, 1981–2000, 2001–2025); há também zips de "Controls" e um zip mensal, que não são usados. O script baixa os dois zips diários para `03_clima/zip/` e extrai para `03_clima/netcdf/` só os blocos `20010101_20251231`:

| Zip (guardado em `03_clima/zip/`) | Bytes | MD5 | Extraído |
|---|---|---|---|
| `pr_Tmax_Tmin_NetCDF_Files.zip` | 7.720.536.326 | afe5542d788d6435c76c37cdf1906ac8 | `pr_`, `Tmax_`, `Tmin_20010101_20251231_BR-DWGD_UFES_UTEXAS_v_3.2.4.nc` |
| `ETo_u2_RH_Rs_NetCDF_Files.zip` | 2.226.324.137 | 1f95c2a43649d720099b1e4149ca6fb8 | `RH_20010101_20251231_BR-DWGD_UFES_UTEXAS_v_3.2.4.nc` |

**Versão.** "v_3.2.4" aparece **só no nome dos arquivos**. Nenhum atributo interno cita a versão; o atributo `title` ainda diz "(1961-2020)", texto não atualizado pelos autores, e `history` traz "Created Tue Apr 7 17:02:18 2026". A procedência fica no md5 dos zips oficiais, registrado no `logs/integridade.csv`.

**Metadados e empacotamento (verificados no arquivo).**
- Grade de 393 lat × 391 lon. Em todos os dias, 53,79% das células são NaN: é a máscara fora do território.
- Unidades declaradas: "Celcius degrees" (grafia dos autores, fora do padrão CF), "%" e "mm". Não usar conversão automática de unidade; tratar como °C.
- Tmax e Tmin: int16, passo de ~0,001 °C. pr: int16, passo de ~0,007 mm. **RH: uint8, passo de ~0,39 ponto percentual**, discretização grosseira mas aceitável para a sensibilidade.

## 5. Extração por município (`06a_clima_municipal.py`)

- É uma média **ponderada pela área** de interseção célula ∩ polígono municipal, calculada em projeção equivalente (ESRI:102033).
- Células sem dado são ignoradas, com pesos renormalizados a cada dia.
- Município sem célula válida usa a célula válida mais próxima do centroide, a mesma lógica do script oficial `extraindo_dados_nivel_municipal.py` (corrigido pelo autor em 08/11/2023). A distância fica registrada e há alerta se passar de 0,15°.
- Malha: IBGE 2024 (`05_shapefiles`).
- **Rodada de 2026-10-05** (277 municípios das concentrações). O resultado está em `06_processados/FONTE.md`:
  - célula válida = com dado em algum dia: 71.007 células, nenhuma muda de validade;
  - nenhum município precisou do vizinho do centroide;
  - 5.510 dias por município; NaN 0% em `tmean` e `rh_mean`;
  - dias faltantes (contados antes da renormalização, `logs/dias_faltantes_clima.csv`): 0 nas 4 variáveis.
- **Área coberta** (`frac_area_coberta` nas tabelas de pesos; auditoria A4): a parte do município fora da máscara do BR-DWGD, quase sempre mar, fica fora da média. No BR-DWGD, 21 dos 277 municípios têm cobertura menor que 0,90 e 7 menor que 0,75; o mínimo é Mangaratiba/RJ, com 0,44. No CAMS, que não tem máscara, só Vitória fica abaixo (0,89), possivelmente pelas ilhas oceânicas do município, fora da área baixada (não verificado).
- A umidade sai como `rh_mean`, a umidade relativa média do dia em % (passo de ~0,39 ponto percentual, ver §4).
- Também é possível extrair por coordenada (ponto), como no `export2cvs_daily_points.py` do autor (`.sel(..., method='nearest')`), mas aqui não se usa, porque o desfecho é municipal.

## 6. Verificação de integridade (`03_download_clima.py --auditar`)

Para cada NetCDF são registrados:
- MD5 do `.nc` (coluna `md5_parquet`) e MD5 do zip de origem (`md5_origem`);
- bytes, variável, primeira e última data;
- nº de dias vs. esperado e datas duplicadas;
- resolução e fração de NaN em 15 datas do período (que deve ser constante);
- mínimo e máximo de uma amostra (plausibilidade), unidade e atributos globais.

Depois o script confere que as quatro variáveis têm a mesma grade e a cobertura contínua, dia a dia (inclusive buracos entre arquivos), de 2010-01-01 a 2025-01-31. Qualquer falha encerra com código de erro e vai para o `.log`. Tudo vai para `03_clima/_auditoria_netcdf.json` e `logs/integridade.csv`. Na extração, um `.nc` só é aceito como "já extraído" se o tamanho conferir com o do membro do zip; a gravação usa arquivo `.part` e renomeia no fim. Auditoria de 02/10/2026: OK; independente, sem achado crítico (`logs/auditoria_20261002.md`).

## 7. Limitações a declarar

- É dado interpolado de estações e pluviômetros. O erro tende a ser maior onde há poucas estações. A densidade de estações em cada uma das 26 concentrações urbanas não foi verificada; vale conferir com a localização das estações e pluviômetros publicada no catálogo comunitário do GEE (`projects/sat-io/open-datasets/BR-DWGD/WEATHER_STATIONS` e `.../RAIN_GAUGES`, https://gee-community-catalog.org/projects/br_dwgd/).
- A temperatura média é derivada de (Tmax+Tmin)/2.
- A média municipal ponderada por área não pondera por população. Dentro de concentrações grandes (por exemplo, São Paulo, com 37 municípios) isso dilui ilhas de calor. Daí a série da cidade-núcleo (`tmean_nucleo`), ao lado da média do recorte ponderada por nascidos vivos.

---

# PM2.5 — CAMS EAC4 (Copernicus/ECMWF), para o E16 (sensibilidade)

**Decisão:** reanálise CAMS EAC4 baixada direto da Atmosphere Data Store, em vez do SISAM/INPE citado no adendo v1.2 (Guilherme, 02/10/2026; ver `logs/desvios_especificacao.md`). O SISAM usa o próprio CAMS como fonte (Jacobson et al., Rev Bras Epidemiol 2024, doi:10.1590/1980-549720240068; Requia et al., Nat Commun 2021, doi:10.1038/s41467-021-26822-7), mas não documenta a agregação por município nem a resolução.

| Atributo | Valor |
|---|---|
| Produto | CAMS global reanalysis (EAC4), conjunto `cams-global-reanalysis-eac4`; licença CC-BY |
| Acesso | https://ads.atmosphere.copernicus.eu/datasets/cams-global-reanalysis-eac4, via `cdsapi` 0.7.7, com conta e token pessoais em `~/.cdsapirc` (fora do projeto). Baixado em 2026-10-02 (BRT): o de 2025 às 16:37–16:38 (log `logs/03b_download_cams_20261002_163749.log`) e os de 2010–2024 das 16:42 às 17:58 (log `logs/03b_download_cams_20261002_164250.log`) |
| Variável | `particulate_matter_2.5um` (no arquivo, `pm2p5`), nível único (superfície), em **kg m⁻³** (× 10⁹ = µg/m³) |
| Resolução | **0,75° × 0,75°** (grade de 56 × 59 na área baixada), **a cada 3 h** (00, 03, …, 21 UTC) — conferida nos arquivos |
| Área | N 7°, W −75°, S −35°, E −31° (Brasil + 1° de margem, inclui Fernando de Noronha) |
| Período | **2010-01-01 00:00 a 2025-01-31 21:00 UTC**; 16 arquivos, um por ano (2025 só janeiro) |
| Arquivos | `cams_pm25/eac4_pm25_AAAA.nc`, 451,2 MB no total (451.150.167 bytes); MD5 por arquivo em `logs/integridade.csv` (sistema `CAMS-EAC4`); requisições na íntegra em `cams_pm25/_manifesto_cams.json` |
| Script | `00_scripts/03b_download_cams.py`, adaptado de `CliMaterna/A03_temperatura_prematuridade/05_scripts/06i_cams_download_v1_20260907.py` |

**Auditoria (`03b_download_cams.py --auditar`): "AUDITORIA: OK" em 2026-10-02 e de novo em 2026-10-03, já com as checagens do diff 3.**
- Todos os dias do período têm os 8 horários: 2.920 tempos nos anos normais, 2.928 nos bissextos e 248 em jan/2025. Não há dia faltando nem tempo duplicado.
- Unidade `kg m**-3` nos 16 arquivos. Na amostra de ~20 tempos por ano, não há NaN nem valor negativo.
- **Grade idêntica nos 16 arquivos**, conferida pelo md5 de lat + lon (f6f1d8413a034a0ef8751093d9150809): lat −34,50 a 6,75 e lon −75,00 a −31,50, a 0,75°. Os md5 dos `.nc` são iguais aos de 02/10.
- **Faixa no arquivo inteiro** (desde o diff 3 de 03/10; antes era uma amostra de ~20 tempos por ano): mínimo de 0 µg/m³ em todos os anos. O máximo por célula vai de 699 (jan/2025) a 6.493 µg/m³ (2020). Os máximos altos podem vir de queimadas, inclusive fora do Brasil dentro da área baixada; os valores dentro do território serão vistos na extração.
- **Zeros exatos:** de 2,04% a 3,30% de todos os valores de cada arquivo (na amostra antiga, 2,5% a 3,8%), quase todos de 12 a 21 UTC, em episódios de concentração baixa. A % de cada ano vai para o `integridade.csv` e para o manifesto. Ver P-PM25-ZERO em `logs/pendencias_especificacao.md`: a base vai gravar as duas variantes (com zeros e com zero → NA), e a escolha fica para cada paper.

**Proteções do download (diff 3, 2026-10-03):**
- Um arquivo completo com problema de conteúdo (unidade, NaN, negativo) **não é baixado de novo**: o erro é registrado para conferência à mão.
- Um arquivo incompleto é baixado de novo, e o `.part` é verificado **antes** de substituir o atual. Se o download novo falhar, o arquivo atual fica intacto.

**Extração por município (`06a`, rodada de 2026-10-05):**
- Mesma ponderação por área do BR-DWGD, com tabela de pesos própria (`pm25_pesos_municipio.parquet`). A grade recortada em torno dos 277 municípios tem 1.681 células de 0,75°.
- A média diária é feita no **dia UTC** (00–21 UTC), deslocado de 2 a 4 h do horário local, e também no **dia aproximadamente local** (UTC−3: 03–21 UTC do dia mais 00 UTC do seguinte), em `pm25_local` e `pm25_local_zero_na` (desvio de 05/10; auditoria A12). O último dia (2025-01-31) fica sem o dia local. Em 2010–2025, o dia local difere do UTC em 1,0 µg/m³ na média (correlação 0,993).
- Duas variantes (P-PM25-ZERO):
  - `pm25`, com zeros, tem 0% de NA;
  - `pm25_zero_na`, com ≥ 6 de 8 horários, tem 1,25% de dias-município NA;
  - 6,7% dos dias-município têm algum horário com zero.
- Médias de 2012–2024 nas cidades-núcleo, em µg/m³: Serra 8,8; Recife 10,9; Curitiba 12,7; Brasília 13,5; Manaus 16,4; Porto Alegre 18,5; **São Paulo 42,0**.
- **Picos:** o máximo diário municipal é de 960 µg/m³ em **Várzea Grande** (concentração de Cuiabá), em 13/09/2020. Dias-município acima de 250 µg/m³ entre 2010 e 2025, somando os municípios de cada **concentração**: Rio de Janeiro 50, Cuiabá 44, São Paulo 26, Belo Horizonte 22, Campinas 11 e Teresina 11. **No próprio município**, o Rio e São Paulo têm 1 dia cada; Cuiabá e Várzea Grande têm 22 cada (correção da auditoria A6). Cuiabá (2020, 2024) e Teresina coincidem com anos de queimadas. A média de 42 µg/m³ em São Paulo é coerente com a superestimativa do CAMS no Sudeste (abaixo). Não são erro de extração. Por decisão de 06/10/2026, não serão validados contra estações (ver abaixo).

**Feito e decidido:**
- A série da cidade-núcleo (`pm25_nucleo`) e a média do recorte saem do 06c (05/10/2026).
- **Sem validação contra estações de superfície:** decisão de Guilherme em 06/10/2026, para usar o mesmo padrão de medida, CAMS, em todas as concentrações (ver `logs/desvios_especificacao.md`). Os dados da CETESB (SP, no CliMaterna: `pollution_daily_all.parquet`, MP2.5 em 11 estações, 2011–2023) ficam disponíveis se um artigo quiser validar depois.

**Limitações a declarar:**
- A grade de 0,75° (cerca de 80 km) é grosseira para a cidade-núcleo.
- O viés contra medição no Brasil muda de sinal conforme o lugar: na RM de SP, série mensal, o CAMS superestima o PM2.5 em cerca de 50% (Paiva et al., J South Hemisph Earth Syst Sci 2025, doi:10.1071/ES24041); em Salvador, série diária, o SISAM/CAMS subestima (Jacobson et al. 2024).
- A concordância dia a dia é modesta (CCC de 0,20 em Salvador).
