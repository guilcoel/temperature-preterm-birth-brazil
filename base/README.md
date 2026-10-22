# dados_artigos_perinatais_clima

**Repositório de dados (backup) comum** aos três artigos observacionais com DLNM: **prematuridade**, **óbito perinatal** e **pequeno para a idade gestacional (PIG)**, nessa ordem de análise.
- **Unidade espacial:** as **26 grandes concentrações urbanas do IBGE**, com 277 municípios e cidade-núcleo no maior município do Censo 2022. É o padrão do grupo para todos os estudos.
- **Período:** nascimentos e óbitos de **2011–2024** (análise principal 2012–2024; 2011 só como sensibilidade, E18). Clima e PM2.5 de **2010-01-01 a 2025-01-31**.

Esta base guarda os dados harmonizados, versionados (md5) e documentados. Cada artigo é feito numa conversa própria: lê a base pela **interface de acesso** (`09_acesso/`: `acesso.R`, `acesso.py`, `DICIONARIO.md`, `LEIAME.md`, versão no `manifesto.json`) e monta ali o recorte do seu desfecho. Quando uma escolha é de método, a base grava as variantes como colunas e deixa a decisão para o artigo.

Montada a partir de 2026-10-01. Caminhos em `CAMINHOS.md`. Regras de operação para o Claude Code em `CLAUDE.md`. Decisões e desvios em `logs/desvios_especificacao.md`; catálogo da pasta de logs em `logs/LEIAME_logs.md`.

---

## 1. Fontes

| Pasta | Fonte | Versão / status | Unidade | Documentação |
|---|---|---|---|---|
| `01_sinasc` | SINASC / DATASUS, DNRES por UF | 2011–2024, 378 arquivos, **todos do diretório definitivo** | nascido vivo, município de **residência** (`CODMUNRES`) | `01_sinasc/FONTE.md` |
| `02_sim` | SIM / DATASUS: DO por UF (não fetais) + DOFET nacional (fetais) | 2011–2024, 378 DO + 14 DOFET, **todos definitivos** | óbito, município de residência | `02_sim/FONTE.md` |
| `03_clima` | BR-DWGD, Xavier et al. (Int J Climatol 2022) | **v_3.2.4**; usado de 2010-01-01 a 2025-01-31; 0,1°; diário | grade → município (média ponderada por área) | `03_clima/FONTE.md` |
| `03_clima/cams_pm25` | CAMS EAC4 (Copernicus/ECMWF), PM2.5 de superfície | 2010-01-01 a 2025-01-31; 0,75°; a cada 3 h | grade → município | `03_clima/FONTE.md` |
| `04_regioes_metropolitanas` | IBGE, *Arranjos Populacionais e Concentrações Urbanas do Brasil*, 2ª ed. (2016), e Censo 2022 (SIDRA 4709) | 26 grandes concentrações, 277 municípios; cidade-núcleo = maior município em 2022. As RMs legais de 2024/2025 ficam só como documentação | município × concentração | `04_regioes_metropolitanas/FONTE.md` |
| `08_calendario` | Leis federais de feriados (Planalto) | Lei 662/1949 (red. Lei 10.607/2002), Lei 6.802/1980, Lei 14.759/2023 e Lei 9.093/1995, conferidas no texto | dia | `08_calendario/FONTE.md` |
| `05_shapefiles` | IBGE, Malha Municipal | **2024**, SIRGAS 2000, 5.571 municípios | polígono municipal | `05_shapefiles/FONTE.md` |
| `07_pig_referencia` | INTERGROWTH-21st Newborn Size (Villar et al. 2014; 2016) via pacote R `gigs` 0.5.2.9000; Pedreira et al. 2011 (Table I); OMS, Kiserud et al. 2017 (Tabelas 11, 14 e 15) | p10 extraído com dupla leitura (05/10) | nascido vivo | `07_pig_referencia/FONTE.md` |

**Por que 2024 e não 2022:** a v_3.2.4 do BR-DWGD vai até 2025-12-31, e todos os arquivos do SINASC e do SIM até 2024 vieram do diretório **definitivo** do FTP (status gravado no download). Quem limita o período é o DATASUS, não o clima. A v_3.2.3 que está no CliMaterna termina em 2024-03-20, por isso o clima foi baixado de novo.

## 2. Estado

| Etapa | Script | Estado em 2026-10-08 |
|---|---|---|
| SINASC 2011–2024 | `01_download_sinasc.py` | ✅ baixado e auditado (02/10) |
| SIM DO + DOFET 2011–2024 | `02_download_sim.py` | ✅ baixado e auditado (02/10) |
| BR-DWGD v_3.2.4 | `03_download_clima.py` | ✅ baixado e auditado (02/10) |
| CAMS EAC4 (PM2.5) | `03b_download_cams.py` | ✅ baixado (02/10); `--auditar` OK (03/10) |
| Malha IBGE 2024 | `05_shapefiles.py` | ✅ 5.571 municípios (02/10) |
| Concentrações urbanas, Censo 2022, cidade-núcleo | `04_regioes_metropolitanas.py` | ✅ 26 concentrações e 277 municípios; Serra é o núcleo de Vitória (03/10) |
| Aceite da fase 1 | `99_relatorio_integridade.py`, `98_aceite_fase1.py` | ✅ diferença 0 contra o CliMaterna e o TabNet (UF × ano) |
| Clima, umidade e PM2.5 por município | `06a_clima_municipal.py` | ✅ migrado e gerado (05/10): 277 municípios × 5.510 dias; 0 dias faltantes; PM2.5 nas duas variantes |
| Calendário de feriados | `06e_calendario.py` | ✅ gerado (05/10): 5.510 dias; 8 feriados nacionais por ano em 2010–2023 e 9 em 2024; Carnaval, Paixão e Corpus Christi como colunas à parte |
| Desfechos | `06b_desfechos.py` | ✅ gerado (05/10): 16,1 mi NV e 259.909 óbitos dos 277 municípios; série município × dia com e sem coorte fixa; conferência independente com diferença 0 |
| Gestações em risco (offset, E7) | `06d_gestacoes_em_risco.py`, `06d_validar_forca_bruta.py` | ✅ gerado (05/10): 24,3 mi células município × dia × semana; força bruta 5/5 |
| Ligação / exposição | `06c_exposicao.py` | ✅ migrado (05/10/2026): exposições `_nucleo`, `_mun` e `_rm_nv`; séries município e concentração na grade do E9; gestações em risco por concentração; matrizes semanais s01..s37; ver `06_processados/FONTE.md` |
| PIG | `00_scripts/07a_referencias_pig.py` e `07_pig_referencia/07b_pig_classificacao.R` | ✅ gerado (05/10): p10 da OMS e de Pedreira com dupla leitura; três curvas, sensibilidades de IG e pré-termo; ver `07_pig_referencia/FONTE.md` |
| B19: códigos de residência fora da lista do IBGE | `98b_codigos_residencia.py` | ✅ varredura do Brasil (05/10): **0** códigos fora da lista nos três sistemas |
| Manifesto, interface e dicionário | `08_manifesto.py`, `09_acesso/` | ✅ (05/10): versão da base no `manifesto.json`; interface R e Python testada contra as matrizes do 06c e entre si (duas matrizes não gravadas e a ligação com os nascimentos); dicionário com todas as colunas (cobertura testada) |
| IG pela DUM (`ig_dum_sem`, §3.5 da v2.0.2; decisões, seção 8) | `06b_desfechos.py` | ✅ (08/10): coluna nova no `nascimentos.parquet`, acessível por `nascimentos()` e por `pig(com_nascimentos = "ig_dum_sem")`. A `DTULTMENST` bruta não entra na base. Não regressão contra a `7e99bf94`, antes e depois da troca: as 51 colunas antigas e os outros 42 arquivos ficaram idênticos. Descritivo em `logs/descritivo_ig_dum_sem_20261008.csv`; entrega em `RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md` |

**Versão vigente: `4443971b`** (08/10/2026). Sucede a `7e99bf94` e difere dela só por ter a `ig_dum_sem`. A versão é o SHA-256 da lista caminho:md5 dos 43 arquivos de dados (`09_acesso/LEIAME.md`). A `7e99bf94` se reproduz pelo código do commit `9f1957b` sobre os mesmos brutos.

Auditorias e correções: `logs/auditoria_20261002.md`. Aceite: `logs/aceite_fase1_20261002.md`.

**Histórico: testes feitos antes dos downloads** (2026-10-01, numa VM no Mac, com arquivos do CliMaterna como fonte local e dados sintéticos, ainda com o recorte por RM):

- **Pipeline DATASUS** (download → MD5 → parquet → integridade → completude): rodou com DN AC/RR 2023, DO AC 2023 e DOFET23.
  - O arquivo ausente foi registrado como `AUSENTE`.
  - Na segunda rodada, o parquet foi reaproveitado e só reauditado.
- **Conferência contra fonte independente** (a base CliMaterna, que veio do CSV do portal):
  - os nascidos vivos de AC (14,473) e de RR (13,105) bateram exatamente;
  - nos 3 municípios de teste, nascidos vivos (13,173), IG válida (12,988) e PTB (2,060) bateram exatamente.
- **Óbitos recontados** com código próprio, direto do .dbc: fetais 119 por SEMAGESTAC + 9 por peso; neonatais precoces 51. Idêntico ao pipeline.
- **Extração climática** contra campo sintético de valor conhecido: erro máximo < 5×10⁻⁶.
  - O dia sem dado é renormalizado entre os municípios restantes.
  - O fallback do vizinho mais próximo e o alerta de distância funcionaram.
- **Janelas gestacionais** (T1, T3, gestação, últimas 4 semanas, semana 1, semana 40, janela extra) conferidas contra cálculo manual: valores idênticos. Um dia sem clima anula as janelas e semanas que o contêm.
- **Agregação por RM:** preservou o total de nascidos vivos. Um município em dois recortes entrou nos dois; o filtro por tipo de recorte funcionou.
- **Auditoria independente** (subagente em contexto limpo): 1 achado crítico, 5 maiores e 13 menores, todos corrigidos. Os críticos e maiores foram reproduzidos com código próprio antes de aceitos; o principal é o SEMAGESTAC = 99 nos óbitos fetais.
- **Não testados aqui:** acesso real ao FTP, ao IBGE e ao Drive (rede bloqueada nos ambientes de teste) e o script R do PIG (sem R; conferido contra a documentação do gigs).

## 3. Verificação de integridade

Cada arquivo baixado fica registrado em `logs/integridade.csv` com:

- MD5 do original e do parquet, bytes;
- nº de linhas e colunas;
- nº de municípios distintos e % de código de município inválido;
- status (definitivo ou preliminar) e URL de origem.

A completude de cada variável-chave (% vazio por UF e ano) vai para `logs/completude_<sistema>.csv`. O `99_relatorio_integridade.py` consolida tudo por fonte e ano, **compara com as contagens da base antiga do CliMaterna** e reescreve a seção abaixo.

<!-- INTEGRIDADE:INICIO -->
_Gerado por 99_relatorio_integridade.py em 2026-10-08T20:09:47-03:00. Checksums MD5 por arquivo em logs/integridade.csv; completude por variável em logs/completude_*.csv._

### Checagens automáticas

- OK: todas as UFs em 2011–2024 nos três sistemas; nenhuma FALHA, AUSENTE ou cabeçalho divergente
- Município inválido ≥ 1% (README §3; aceito com ressalva em 02/10/2026): 7 célula(s): SIM-DO 2011 RJ 1.32%; SIM-DO 2012 RJ 1.20%; SIM-DO 2013 RJ 1.12%; SIM-DO 2014 RJ 1.14%; SIM-DOFET 2011 BR 1.47%; SIM-DOFET 2012 BR 1.06%; SIM-DOFET 2013 BR 1.20%
- Observações registradas: 27× `campos não-texto={'CONTADOR': 'N'}`

### DATASUS (por sistema e ano)

| sistema   |   ano |   arquivos |   ausentes |   falhas | status     |    linhas |   municipios_validos | linhas_climaterna   | dif_vs_climaterna   |
|:----------|------:|-----------:|-----------:|---------:|:-----------|----------:|---------------------:|:--------------------|:--------------------|
| SIM-DO    |  2011 |         27 |          0 |        0 | definitivo | 1,170,498 |                 5563 | 1170498             | 0                   |
| SIM-DO    |  2012 |         27 |          0 |        0 | definitivo | 1,181,166 |                 5565 | 1181166             | 0                   |
| SIM-DO    |  2013 |         27 |          0 |        0 | definitivo | 1,210,474 |                 5569 | 1210474             | 0                   |
| SIM-DO    |  2014 |         27 |          0 |        0 | definitivo | 1,227,039 |                 5570 | 1227039             | 0                   |
| SIM-DO    |  2015 |         27 |          0 |        0 | definitivo | 1,264,175 |                 5570 | 1264175             | 0                   |
| SIM-DO    |  2016 |         27 |          0 |        0 | definitivo | 1,309,774 |                 5570 | 1309774             | 0                   |
| SIM-DO    |  2017 |         27 |          0 |        0 | definitivo | 1,312,663 |                 5570 | 1312663             | 0                   |
| SIM-DO    |  2018 |         27 |          0 |        0 | definitivo | 1,316,719 |                 5570 | 1316719             | 0                   |
| SIM-DO    |  2019 |         27 |          0 |        0 | definitivo | 1,349,801 |                 5570 | 1349801             | 0                   |
| SIM-DO    |  2020 |         27 |          0 |        0 | definitivo | 1,556,824 |                 5570 | 1556824             | 0                   |
| SIM-DO    |  2021 |         27 |          0 |        0 | definitivo | 1,832,649 |                 5570 | 1832649             | 0                   |
| SIM-DO    |  2022 |         27 |          0 |        0 | definitivo | 1,544,266 |                 5570 | 1544266             | 0                   |
| SIM-DO    |  2023 |         27 |          0 |        0 | definitivo | 1,465,610 |                 5570 | <NA>                | <NA>                |
| SIM-DO    |  2024 |         27 |          0 |        0 | definitivo | 1,532,015 |                 5570 | <NA>                | <NA>                |
| SIM-DOFET |  2011 |          1 |          0 |        0 | definitivo |    31,613 |                 4105 | 31613               | 0                   |
| SIM-DOFET |  2012 |          1 |          0 |        0 | definitivo |    32,229 |                 3989 | 32229               | 0                   |
| SIM-DOFET |  2013 |          1 |          0 |        0 | definitivo |    31,981 |                 3945 | 31981               | 0                   |
| SIM-DOFET |  2014 |          1 |          0 |        0 | definitivo |    32,145 |                 4025 | 32145               | 0                   |
| SIM-DOFET |  2015 |          1 |          0 |        0 | definitivo |    32,994 |                 4063 | 32994               | 0                   |
| SIM-DOFET |  2016 |          1 |          0 |        0 | definitivo |    30,210 |                 3954 | 30210               | 0                   |
| SIM-DOFET |  2017 |          1 |          0 |        0 | definitivo |    30,620 |                 4018 | 30620               | 0                   |
| SIM-DOFET |  2018 |          1 |          0 |        0 | definitivo |    30,690 |                 3981 | 30690               | 0                   |
| SIM-DOFET |  2019 |          1 |          0 |        0 | definitivo |    29,105 |                 3946 | 29105               | 0                   |
| SIM-DOFET |  2020 |          1 |          0 |        0 | definitivo |    28,993 |                 3875 | 28993               | 0                   |
| SIM-DOFET |  2021 |          1 |          0 |        0 | definitivo |    29,325 |                 3928 | 29325               | 0                   |
| SIM-DOFET |  2022 |          1 |          0 |        0 | definitivo |    27,394 |                 3838 | 27394               | 0                   |
| SIM-DOFET |  2023 |          1 |          0 |        0 | definitivo |    26,545 |                 3826 | <NA>                | <NA>                |
| SIM-DOFET |  2024 |          1 |          0 |        0 | definitivo |    24,364 |                 3719 | <NA>                | <NA>                |
| SINASC    |  2011 |         27 |          0 |        0 | definitivo | 2,913,160 |                 5565 | 2913160             | 0                   |
| SINASC    |  2012 |         27 |          0 |        0 | definitivo | 2,905,789 |                 5565 | 2905789             | 0                   |
| SINASC    |  2013 |         27 |          0 |        0 | definitivo | 2,904,027 |                 5570 | 2904027             | 0                   |
| SINASC    |  2014 |         27 |          0 |        0 | definitivo | 2,979,259 |                 5570 | 2979259             | 0                   |
| SINASC    |  2015 |         27 |          0 |        0 | definitivo | 3,017,668 |                 5570 | 3017668             | 0                   |
| SINASC    |  2016 |         27 |          0 |        0 | definitivo | 2,857,800 |                 5570 | 2857800             | 0                   |
| SINASC    |  2017 |         27 |          0 |        0 | definitivo | 2,923,535 |                 5570 | 2923535             | 0                   |
| SINASC    |  2018 |         27 |          0 |        0 | definitivo | 2,944,932 |                 5570 | 2944932             | 0                   |
| SINASC    |  2019 |         27 |          0 |        0 | definitivo | 2,849,146 |                 5570 | 2849146             | 0                   |
| SINASC    |  2020 |         27 |          0 |        0 | definitivo | 2,730,145 |                 5570 | 2730145             | 0                   |
| SINASC    |  2021 |         27 |          0 |        0 | definitivo | 2,677,101 |                 5570 | 2677101             | 0                   |
| SINASC    |  2022 |         27 |          0 |        0 | definitivo | 2,561,922 |                 5570 | 2561922             | 0                   |
| SINASC    |  2023 |         27 |          0 |        0 | definitivo | 2,537,576 |                 5569 | 2537576             | 0                   |
| SINASC    |  2024 |         27 |          0 |        0 | definitivo | 2,389,325 |                 5570 | 2389325             | 0                   |

### Clima, IBGE e processados

| sistema                 | ano       | arquivo                                               | status    |   n_linhas |   n_municipios | md5_origem                       | md5_parquet                      | observacao                                                                                                                                                                                                                |
|:------------------------|:----------|:------------------------------------------------------|:----------|-----------:|---------------:|:---------------------------------|:---------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| BR-DWGD-zip             | 1961-2025 | ETo_u2_RH_Rs_NetCDF_Files.zip                         | v_3.2.4   |            |                | 1f95c2a43649d720099b1e4149ca6fb8 |                                  | zip oficial da pasta https://drive.google.com/drive/folders/11-qnvwojirAtaQxSE03N0_SUrbcsz44N; extrai ['RH']                                                                                                              |
| BR-DWGD-zip             | 1961-2025 | pr_Tmax_Tmin_NetCDF_Files.zip                         | v_3.2.4   |            |                | afe5542d788d6435c76c37cdf1906ac8 |                                  | zip oficial da pasta https://drive.google.com/drive/folders/11-qnvwojirAtaQxSE03N0_SUrbcsz44N; extrai ['pr', 'Tmax', 'Tmin']                                                                                              |
| BR-DWGD                 | 2001-2025 | RH_20010101_20251231_BR-DWGD_UFES_UTEXAS_v_3.2.4.nc   | v_3.2.4   |      9,131 |                | 1f95c2a43649d720099b1e4149ca6fb8 | 5af7942df70eda465f02a233ca68c759 | var=RH; faltam 0 dias; dup 0; res=0.10°; zip=ETo_u2_RH_Rs_NetCDF_Files.zip; md5_parquet = md5 do .nc                                                                                                                      |
| BR-DWGD                 | 2001-2025 | Tmax_20010101_20251231_BR-DWGD_UFES_UTEXAS_v_3.2.4.nc | v_3.2.4   |      9,131 |                | afe5542d788d6435c76c37cdf1906ac8 | e7f6572fcc583e1d5e03cfc744532c22 | var=Tmax; faltam 0 dias; dup 0; res=0.10°; zip=pr_Tmax_Tmin_NetCDF_Files.zip; md5_parquet = md5 do .nc                                                                                                                    |
| BR-DWGD                 | 2001-2025 | Tmin_20010101_20251231_BR-DWGD_UFES_UTEXAS_v_3.2.4.nc | v_3.2.4   |      9,131 |                | afe5542d788d6435c76c37cdf1906ac8 | 81eafbe1436ed7778c61a73ebea182ed | var=Tmin; faltam 0 dias; dup 0; res=0.10°; zip=pr_Tmax_Tmin_NetCDF_Files.zip; md5_parquet = md5 do .nc                                                                                                                    |
| BR-DWGD                 | 2001-2025 | pr_20010101_20251231_BR-DWGD_UFES_UTEXAS_v_3.2.4.nc   | v_3.2.4   |      9,131 |                | afe5542d788d6435c76c37cdf1906ac8 | 1a4d241ebf37f520c0e61c60ec6448dc | var=pr; faltam 0 dias; dup 0; res=0.10°; zip=pr_Tmax_Tmin_NetCDF_Files.zip; md5_parquet = md5 do .nc                                                                                                                      |
| IBGE-malha              | 2024      | BR_Municipios_2024.zip                                | oficial   |      5,573 |           5573 | 119f37dad6fa1f84512b5f0dcb1635a3 |                                  | CRS=EPSG:4674; feições não-municipais excluídas=2 ['4300002', '4300001']                                                                                                                                                  |
| IBGE-malha              | 2024      | BR_UF_2024.zip                                        | oficial   |         27 |                | edc1a3250b8d2f573f700bb5fc89b365 |                                  | CRS=EPSG:4674                                                                                                                                                                                                             |
| CAMS-EAC4               | 2010      | eac4_pm25_2010.nc                                     | EAC4      |      2,920 |                | 3071280baaae940d33378577faee94e7 |                                  | var=pm2p5; 2010-01-01 00:00→2010-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–5224.21 ug/m3; zeros exatos=2.4211% (P-PM25-ZERO); problemas=nenhum |
| CAMS-EAC4               | 2011      | eac4_pm25_2011.nc                                     | EAC4      |      2,920 |                | 9e2ad3703c67cff14b06691fa8a650d2 |                                  | var=pm2p5; 2011-01-01 00:00→2011-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–2744.63 ug/m3; zeros exatos=2.6111% (P-PM25-ZERO); problemas=nenhum |
| CAMS-EAC4               | 2012      | eac4_pm25_2012.nc                                     | EAC4      |      2,928 |                | cb240580696f6a8c0d18046196675681 |                                  | var=pm2p5; 2012-01-01 00:00→2012-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–4521.5 ug/m3; zeros exatos=2.8914% (P-PM25-ZERO); problemas=nenhum  |
| CAMS-EAC4               | 2013      | eac4_pm25_2013.nc                                     | EAC4      |      2,920 |                | 196e576a2e1de445b429b862f68026e2 |                                  | var=pm2p5; 2013-01-01 00:00→2013-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–2271.78 ug/m3; zeros exatos=2.7798% (P-PM25-ZERO); problemas=nenhum |
| CAMS-EAC4               | 2014      | eac4_pm25_2014.nc                                     | EAC4      |      2,920 |                | d6559b631f70c7de1baa9082d63c4b3d |                                  | var=pm2p5; 2014-01-01 00:00→2014-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–2531.96 ug/m3; zeros exatos=2.1909% (P-PM25-ZERO); problemas=nenhum |
| CAMS-EAC4               | 2015      | eac4_pm25_2015.nc                                     | EAC4      |      2,920 |                | d32ffc71b7287331eea761a7df51c2d7 |                                  | var=pm2p5; 2015-01-01 00:00→2015-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–3765.78 ug/m3; zeros exatos=2.0379% (P-PM25-ZERO); problemas=nenhum |
| CAMS-EAC4               | 2016      | eac4_pm25_2016.nc                                     | EAC4      |      2,928 |                | 69a01a4bb64b49eb5acd1265257e8016 |                                  | var=pm2p5; 2016-01-01 00:00→2016-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–6008.1 ug/m3; zeros exatos=2.4717% (P-PM25-ZERO); problemas=nenhum  |
| CAMS-EAC4               | 2017      | eac4_pm25_2017.nc                                     | EAC4      |      2,920 |                | 5a2a78a011dca035fac806224ae7c4c5 |                                  | var=pm2p5; 2017-01-01 00:00→2017-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–4055.28 ug/m3; zeros exatos=2.8262% (P-PM25-ZERO); problemas=nenhum |
| CAMS-EAC4               | 2018      | eac4_pm25_2018.nc                                     | EAC4      |      2,920 |                | 53776a30fb41fe173f1e9e5613949b36 |                                  | var=pm2p5; 2018-01-01 00:00→2018-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–2475.8 ug/m3; zeros exatos=2.5241% (P-PM25-ZERO); problemas=nenhum  |
| CAMS-EAC4               | 2019      | eac4_pm25_2019.nc                                     | EAC4      |      2,920 |                | 672f866bc1b1df636c58f13dba5ca452 |                                  | var=pm2p5; 2019-01-01 00:00→2019-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–4581.71 ug/m3; zeros exatos=2.6202% (P-PM25-ZERO); problemas=nenhum |
| CAMS-EAC4               | 2020      | eac4_pm25_2020.nc                                     | EAC4      |      2,928 |                | dacc873965ac33837d2b3bbf9e35c7a7 |                                  | var=pm2p5; 2020-01-01 00:00→2020-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–6493.4 ug/m3; zeros exatos=3.3011% (P-PM25-ZERO); problemas=nenhum  |
| CAMS-EAC4               | 2021      | eac4_pm25_2021.nc                                     | EAC4      |      2,920 |                | 22d88f18e6994b1eda9e15048c66bad7 |                                  | var=pm2p5; 2021-01-01 00:00→2021-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–4641.75 ug/m3; zeros exatos=2.5061% (P-PM25-ZERO); problemas=nenhum |
| CAMS-EAC4               | 2022      | eac4_pm25_2022.nc                                     | EAC4      |      2,920 |                | 9917a02ab7a838037564b3f5e234d330 |                                  | var=pm2p5; 2022-01-01 00:00→2022-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–3884.93 ug/m3; zeros exatos=2.7013% (P-PM25-ZERO); problemas=nenhum |
| CAMS-EAC4               | 2023      | eac4_pm25_2023.nc                                     | EAC4      |      2,920 |                | 9df83debbbd3ec4a525c9f4a6b350654 |                                  | var=pm2p5; 2023-01-01 00:00→2023-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–4054.56 ug/m3; zeros exatos=2.9198% (P-PM25-ZERO); problemas=nenhum |
| CAMS-EAC4               | 2024      | eac4_pm25_2024.nc                                     | EAC4      |      2,928 |                | b3b9ead330aa8a9cb85069a3e2494270 |                                  | var=pm2p5; 2024-01-01 00:00→2024-12-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–5848.04 ug/m3; zeros exatos=2.3467% (P-PM25-ZERO); problemas=nenhum |
| CAMS-EAC4               | 2025      | eac4_pm25_2025.nc                                     | EAC4      |        248 |                | 702d24d24765143e2fe4d13022031066 |                                  | var=pm2p5; 2025-01-01 00:00→2025-01-31 21:00; grade 56x59; res=0.75°; dias faltando=0; incompletos=0; unidade=kg m**-3; NaN=0.0%; arquivo inteiro 0.0–699.38 ug/m3; zeros exatos=2.5236% (P-PM25-ZERO); problemas=nenhum  |
| IBGE-Censo2022          | 2022      | censo2022_pop_sidra4709_N6.json                       | oficial   |      5,570 |                | 455a8a7ff0ddaa2421737178856826c0 |                                  | SIDRA 4709 var. 93, nível N6: 5570 localidade(s)                                                                                                                                                                          |
| IBGE-Censo2022          | 2022      | censo2022_pop_sidra4709_N1.json                       | oficial   |          1 |                | 0a9edff51dfd71ad45bc4ab2bb0ab06c |                                  | SIDRA 4709 var. 93, nível N1: 1 localidade(s)                                                                                                                                                                             |
| IBGE-Censo2022-tidy     | 2022      | populacao_censo2022.csv                               | derivado  |      5,570 |           5570 |                                  | 5c6c35238f22f7f821354a5611b8fb75 | SIDRA 4709 var. 93; soma N6 = N1 = 203080756                                                                                                                                                                              |
| IBGE-ARRANJOS           | 2016      | ArranjosPopulacionais_mbd_2ed.zip                     | oficial   |            |                | ff551d31dfdcc07f79c930b9db5f7a3c |                                  |                                                                                                                                                                                                                           |
| IBGE-ARRANJOS           | 2016      | DICIONARIO_ArranjosPopulacionais_2ed.xls              | oficial   |            |                | 9a6bad67a5d8db65cf74d8d9a8120990 |                                  |                                                                                                                                                                                                                           |
| IBGE-ARRANJOS           | 2016      | LEIA_ME_2ed.txt                                       | oficial   |            |                | a0371ea8a66488c2f4455b1747d31ed7 |                                  |                                                                                                                                                                                                                           |
| IBGE-concentracoes-tidy | 2010      | concentracoes_urbanas_municipios.csv                  | derivado  |        277 |            277 |                                  | c118857dbc825f182735f847e927a8d7 | Arranjos Populacionais e Concentrações Urbanas do Brasil, 2ª ed. (2016), Censo 2010                                                                                                                                       |
| IBGE-concentracoes-tidy | 2010      | cidade_nucleo.csv                                     | derivado  |         26 |                |                                  | 7da35560a5b6e5be0745561dbf2c7e58 | Arranjos Populacionais e Concentrações Urbanas do Brasil, 2ª ed. (2016), Censo 2010                                                                                                                                       |
| IBGE-concentracoes-tidy | 2010      | municipios_novos_origem.csv                           | derivado  |          6 |              6 |                                  | 1468fb4728dc2eeb274672f93564a676 | Arranjos Populacionais e Concentrações Urbanas do Brasil, 2ª ed. (2016), Censo 2010                                                                                                                                       |
| IBGE-RM                 | 2024      | Composicao_RM_2024.xlsx                               | oficial   |            |                | e79147440aea15287b25324d35679f1c |                                  |                                                                                                                                                                                                                           |
| IBGE-RM                 | 2024      | Relatorio_Alteracoes_RM_2024.xlsx                     | oficial   |            |                | 246826b84a9d39886f227f2a6ad89a30 |                                  |                                                                                                                                                                                                                           |
| IBGE-RM                 | 2025      | Composicao_RM_2025.xlsx                               | oficial   |            |                | 0a1105b9c6c14eb7b1aa296c00e9a027 |                                  |                                                                                                                                                                                                                           |
| IBGE-RM                 | 2025      | Relatorio_Alteracoes_RM_2025.xlsx                     | oficial   |            |                | 8551052f42c6a9c505eb3b4c7ac56c48 |                                  |                                                                                                                                                                                                                           |
| IBGE-RM-tidy            | 2024      | rm_municipios_2024.csv                                | derivado  |      1,480 |           1442 |                                  | 9c3f82f242c458af09ef9af4961530d0 | só documentação; 87 recortes; CD_RECORTE com prefixo AU_/RM_; multi={'RM+RM': 26, 'RIDE+RM': 12}                                                                                                                          |
| IBGE-RM-tidy            | 2025      | rm_municipios_2025.csv                                | derivado  |      1,508 |           1469 |                                  | db3df768773b61a84dc5dfd98fdbb6cb | só documentação; 93 recortes; CD_RECORTE com prefixo AU_/RM_; multi={'RM+RM': 27, 'RIDE+RM': 12}                                                                                                                          |
| CLIMA-auxiliar          | 2010-2025 | clima_pesos_municipio.parquet                         | derivado  |      2,448 |            277 |                                  | 737f7d88e41ddc942a7809db42fc7c1d | pesos BR-DWGD (0,1°)                                                                                                                                                                                                      |
| CLIMA-auxiliar          | 2010-2025 | dias_faltantes_clima.csv                              | derivado  |      1,108 |            277 |                                  | 417b0441595c2e56f55233b694cacd51 | dias faltantes antes da renormalização (E9)                                                                                                                                                                               |
| CLIMA-municipal         | 2010-2025 | clima_municipio_diario_2010_2025.parquet              | v_3.2.4   |  1,526,270 |            277 |                                  | 4c7cbe6c14652cb19b609f42134f8b32 | dias/mun 5510-5510 de 5510; vizinho_centroide=0; NaN tmean=0.0000%; rh_mean=0.0000%                                                                                                                                       |
| CLIMA-auxiliar          | 2010-2025 | pm25_pesos_municipio.parquet                          | derivado  |        491 |            277 |                                  | 2ef2dc5025c9769fbb2815d6a45da628 | pesos CAMS (0,75°)                                                                                                                                                                                                        |
| PM25-municipal          | 2010-2025 | pm25_municipio_diario_2010_2025.parquet               | CAMS-EAC4 |  1,526,270 |            277 |                                  | 7d6ba7f4134e1163e2bda64e1aec174f | dia UTC; dias/mun 5510-5510 de 5510; NaN pm25=0.0000%; pm25_zero_na=1.2510%                                                                                                                                               |
| PLANALTO-lei            | 1949      | l0662.htm                                             | oficial   |            |                | 020b1cdf6e6d96d25d71f956369c9ac9 |                                  | Lei 662/1949; md5_texto=c8fed9631063366719842106d1a09e3a                                                                                                                                                                  |
| PLANALTO-lei            | 2002      | l10607.htm                                            | oficial   |            |                | 1164b4f4bf7fd3a9f3b089940da4abab |                                  | Lei 10.607/2002; md5_texto=ab5c9aa418bdff017e57a04c4fd3b57a                                                                                                                                                               |
| PLANALTO-lei            | 1980      | l6802.htm                                             | oficial   |            |                | 45ad19aff2bdb25d91379529ae27887b |                                  | Lei 6.802/1980; md5_texto=cee259da8a006dec04f024c8c9acdc4c                                                                                                                                                                |
| PLANALTO-lei            | 2023      | l14759.htm                                            | oficial   |            |                | 83303d71e5a1c0494b1bb2296c5ceb55 |                                  | Lei 14.759/2023; md5_texto=6ce6354ce05824bc043ea0d4f5ac44fd                                                                                                                                                               |
| PLANALTO-lei            | 1995      | l9093.htm                                             | oficial   |            |                | 9cd3b3353e3b276fbfbedd2156df1cfb |                                  | Lei 9.093/1995; md5_texto=8f95f98711342c4fdcf8d3f539f55318                                                                                                                                                                |
| CALENDARIO              | 2010-2025 | calendario_2010_2025.parquet                          | derivado  |      5,510 |                |                                  | 5c719b2b2d97757ac0bbeac8e59c8dbf | feriados nacionais=122; leis conferidas no texto do Planalto                                                                                                                                                              |
| PIG-REF                 | 2017      | oms_kiserud2017_p10.csv                               | derivado  |         81 |                |                                  | 44d8d12044826f984a9d821e221dffa6 | Kiserud 2017 Tabelas 11/14/15; dupla leitura; pdf md5 745de4e3efbc8d34ef49549c0ade3543                                                                                                                                    |
| PIG-REF                 | 2011      | pedreira2011_p10.csv                                  | derivado  |         42 |                |                                  | 2a82b376a80a63799f4c89bef8dc794a | Pedreira 2011 Table I (p10 M/F, 22-42 sem); dupla leitura visual; pdf md5 b2b72dfe0856482655a0369626edb0b0                                                                                                                |
| DESFECHOS               | 2011-2024 | nascimentos.parquet                                   | derivado  | 16,116,860 |                |                                  | 3a78e7ddcfd1f3c4f86e910087347698 | 06b; microdado individual nas tabelas de registro                                                                                                                                                                         |
| DESFECHOS               | 2011-2024 | obitos_perinatais.parquet                             | derivado  |    259,909 |                |                                  | 3fc57216d26cbd236d6acc0bbd7bdd08 | 06b; microdado individual nas tabelas de registro                                                                                                                                                                         |
| DESFECHOS               | 2011-2024 | serie_diaria_municipio.parquet                        | derivado  |  1,416,578 |                |                                  | 1f0ded6fdb15b11c184191d0a6690025 | 06b; microdado individual nas tabelas de registro                                                                                                                                                                         |
| DESFECHOS               | 2011-2024 | serie_diaria_municipio_sem_coorte_fixa.parquet        | derivado  |  1,416,578 |                |                                  | 74cfbb511ec7ebcdea21686e4a74ca90 | 06b; microdado individual nas tabelas de registro                                                                                                                                                                         |
| GESTACOES-RISCO         | 2012-2024 | gestacoes_em_risco.parquet                            | derivado  | 24,290,331 |            277 |                                  | 14fd418d61376c0cbfa1dbb6c11a16ed | E7; coorte fixa; semanas 22-42; validar com 06d_validar_forca_bruta.py                                                                                                                                                    |
| EXPOSICAO               | 2011-2024 | serie_diaria_municipio_clima.parquet                  | derivado  |  1,424,334 |                |                                  | c4793a0ca548c7084bc5f5fdef510ea9 | E9; grade 2010-12-11 a 2025-01-07; contagens NA fora de 2011-2024                                                                                                                                                         |
| EXPOSICAO               | 2011-2024 | serie_diaria_recorte.parquet                          | derivado  |    133,692 |                |                                  | f36cb6649c3b8c9936fe7705059088a8 | E9; grade 2010-12-11 a 2025-01-07; contagens NA fora de 2011-2024                                                                                                                                                         |
| EXPOSICAO               | 2011-2024 | serie_diaria_municipio_clima_sem_coorte_fixa.parquet  | derivado  |  1,424,334 |                |                                  | 4ef14b17aab4a05653c2e779b0379c10 | E9; grade 2010-12-11 a 2025-01-07; contagens NA fora de 2011-2024                                                                                                                                                         |
| EXPOSICAO               | 2011-2024 | serie_diaria_recorte_sem_coorte_fixa.parquet          | derivado  |    133,692 |                |                                  | 26b4e3ff71a57b578ad10cbbc239f7ef | E9; grade 2010-12-11 a 2025-01-07; contagens NA fora de 2011-2024                                                                                                                                                         |
| EXPOSICAO               | 2011-2024 | gestacoes_em_risco_recorte.parquet                    | derivado  |  2,500,825 |                |                                  | 9a371ebc788349c251da4c61a15198af | E7 por recorte (soma dos municipios)                                                                                                                                                                                      |
| EXPOSICAO               | 2011-2024 | expo_semanal_tmean_nucleo.parquet                     | derivado  |    142,454 |                |                                  | 8d202ead98c31964aec47109db3b5547 | E8; s01..s37; dum_est 2010-01-01 a 2024-12-31                                                                                                                                                                             |
| EXPOSICAO               | 2011-2024 | expo_semanal_tmean_rm_nv.parquet                      | derivado  |    142,454 |                |                                  | bf4b8562641954f2020226ef443396e8 | E8; s01..s37; dum_est 2010-01-01 a 2024-12-31                                                                                                                                                                             |
| EXPOSICAO               | 2011-2024 | expo_semanal_tmean_mun.parquet                        | derivado  |  1,517,683 |                |                                  | 09284c63d55e6c36ec1aa23067c6e7a1 | E8; s01..s37; dum_est 2010-01-01 a 2024-12-31                                                                                                                                                                             |
| EXPOSICAO               | 2011-2024 | expo_semanal_rh_nucleo.parquet                        | derivado  |    142,454 |                |                                  | ca736aace4c2ecfd0f3e36cec9c2be03 | E8; s01..s37; dum_est 2010-01-01 a 2024-12-31                                                                                                                                                                             |
| EXPOSICAO               | 2011-2024 | expo_semanal_rh_rm_nv.parquet                         | derivado  |    142,454 |                |                                  | c48908797ffbeb62a5463fb0ac4ffe65 | E8; s01..s37; dum_est 2010-01-01 a 2024-12-31                                                                                                                                                                             |
| EXPOSICAO               | 2011-2024 | expo_semanal_rh_mun.parquet                           | derivado  |  1,517,683 |                |                                  | 9ece1477e308a5536b2b47748e5700d5 | E8; s01..s37; dum_est 2010-01-01 a 2024-12-31                                                                                                                                                                             |
| EXPOSICAO               | 2011-2024 | expo_semanal_pm25_nucleo.parquet                      | derivado  |    142,454 |                |                                  | 595ce3b19f96860e8ce01aaa49a1fc9c | E8; s01..s37; dum_est 2010-01-01 a 2024-12-31                                                                                                                                                                             |
| EXPOSICAO               | 2011-2024 | expo_semanal_pm25_rm_nv.parquet                       | derivado  |    142,454 |                |                                  | 68a6676c175351d7bca54d08593a6561 | E8; s01..s37; dum_est 2010-01-01 a 2024-12-31                                                                                                                                                                             |
| EXPOSICAO               | 2011-2024 | expo_semanal_pm25_mun.parquet                         | derivado  |  1,517,683 |                |                                  | c612949724373b9634fb6b30b53cc095 | E8; s01..s37; dum_est 2010-01-01 a 2024-12-31                                                                                                                                                                             |
| PIG                     | 2011-2024 | pig_classificacao.parquet                             | derivado  | 14,827,644 |                |                                  | 7aeecfc1a67fc675b22bc59bc83b3a36 | 07b; microdado individual (id_nasc); E8 tres curvas                                                                                                                                                                       |
<!-- INTEGRIDADE:FIM -->

**Contagens de referência:**
- **Nacionais:** a coluna `linhas_climaterna` da seção automática acima.
- **Por UF × ano:** `logs/aceite_fase1_uf_ano.csv`, gerado pelo `98_aceite_fase1.py`. São 1.188 células e todas dão diferença 0 contra o CliMaterna (SINASC 2011–2024; SIM-DO e DOFET 2011–2022) e contra o TabNet (SIM-DO e DOFET 2022–2024).

**Critério de aceite:** em cada ano, diferença de linhas zero, ou explicada pelo status (preliminar × definitivo) ou por atualização do DATASUS; 27 UFs presentes; % de município inválido < 1%; nenhuma variável-chave ausente sem explicação no FONTE.md.

## 4. Ligação (linkage)

Os arquivos, colunas e chaves vigentes estão no `09_acesso/DICIONARIO.md`; as regras, no `logs/desvios_especificacao.md`.

```
SINASC (CODMUNRES, DTNASC) ─┐
SIM-DO  (CODMUNRES, DTNASC/DTOBITO)├─► CD_MUN6 ∈ 277 municípios ─► nascimentos / óbitos (06b) ─► série município × dia (06b)
SIM-DOFET (CODMUNRES, DTOBITO)┘                                     │                                   │
                                                                    ├─► gestações em risco (06d)       │
                                                                    └─► PIG (07a, 07b; id_nasc)        ▼
BR-DWGD (0,1°) e CAMS (0,75°) ─► média por área no polígono IBGE 2024 (06a) ─► exposições _mun, _nucleo, _rm_nv (06c)
                                                                                     │
                         séries município e concentração × dia, grade 2010-12-11 a 2025-01-07, e matrizes s01..s37 (06c)
```

1. **Chave espacial.** O DATASUS usa 6 dígitos (`CODMUNRES`, conferido no dado) e o IBGE usa 7 (`CD_MUN`); a ligação é `CD_MUN6` = primeiros 6 dígitos de `CD_MUN`.
   - Códigos terminados em `0000` (município ignorado) são inválidos e ficam contados por UF × ano no aceite (`98_aceite_fase1.py`).
   - Nenhum código que parece válido está fora da lista do IBGE (B19, `98b_codigos_residencia.py`).
2. **Recorte.** Município de **residência da mãe** dentro de uma das 26 concentrações; cada município está em uma só. O município de ocorrência não é usado.
3. **Exposição** (06c), em três versões que ficam como colunas (o artigo escolhe):
   - **`_nucleo`:** clima da cidade-núcleo (maior município em 2022; Serra em Vitória);
   - **`_mun`:** clima do próprio município;
   - **`_rm_nv`:** média dos municípios ponderada pelo total de NV de 2011–2024.

   Variáveis: `tmean`, `rh` e quatro variantes de PM2.5. Os lags 0..L e o lead do controle negativo ficam para o `dlnm::crossbasis` de cada artigo.
4. **Exposição gestacional.** As matrizes `s01..s37` são indexadas pelo início da gestação (`dum_est`), em grade completa. `ligar_expo_semanal()` as liga a cada nascimento com IG + 3 dias (principal), + 0 ou + 6.
5. **PIG.** A classificação liga aos nascimentos pelo `id_nasc`, interno à base, que não identifica a pessoa.

## 5. Definições operacionais

| Desfecho | Definição |
|---|---|
| Prematuridade | População (E3): nascidos vivos **únicos** de 22+0 a 42+6 semanas; 43–44 contados à parte; < 22 e ≥ 45 inválidos. Desfecho: 22+0 a 36+6. Subtipos: < 28; 28–31; 32–36. Série com e sem coorte fixa (E6) e gestações em risco (E7) |
| Óbito fetal (perinatal) | DOFET, `TIPOBITO = 1`, critério **hierárquico** (`criterio_fetal`), em que **a primeira variável disponível decide**: com `SEMAGESTAC` válido, entra só se ≥ 22; sem ele, `GESTACAO` 2–6; sem as duas, `PESO` ≥ 500 g (9 e 99 = ignorado). Principal: único, `SEMAGESTAC` 22–42 |
| Óbito neonatal precoce | DO, `TIPOBITO = 2`, `IDADE` em minutos (0xx), horas (1xx) ou dias (2xx) ≤ 6. **Codificação conferida no dado e no `process_sim` do microdatasus; o texto do dicionário de 2025 diverge** (`02_sim/FONTE.md`). Principal: único, IG 22–42, `DTNASC` presente e `IDADE` válida. Data-índice (E5): `DTNASC`, com `DTOBITO` como sensibilidade (as duas como colunas). Censura a partir de 25/12/2024 |
| Óbito perinatal | Fetal + neonatal precoce; sensibilidades até 24 h e sem anomalia congênita (Q00–Q99 na causa básica) |
| PIG | População principal (E8): NV únicos **a termo** (37+0 a 42+6), sexo conhecido, `coorte_fixa_37` e \|z\| ≤ 5. Peso < p10 do INTERGROWTH-21st (principal; IG + 3 dias, com + 0 e + 6 como sensibilidades), de Pedreira 2011 e da OMS/Kiserud 2017 (por sexo, no meio da semana e sem sexo), em colunas separadas. Pré-termo de 24+0 a 36+6 só como sensibilidade |

## 6. Limitações já identificadas

1. **Sem endereço ou setor censitário** na base pública (SINASC e SIM) de 2012–2024 (2011 não verificado): a exposição é municipal.
   - Achado: os .dbc do SINASC de 2008–2009 ainda traziam `CODBAIRES` (código do bairro de residência, preenchido em cerca de 63% da amostra de SP 2009). A variável não aparece no esquema de 2012 nem no .dbc de 2023.
   - O caminho de acesso restrito está mapeado em `01_sinasc/FONTE.md` §5 (Nota Informativa nº 5/2025-DAENT/SVSA/MS).
2. **A IG vem em semanas completas**, e o método de estimativa (`TPMETESTIM`) é muito incompleto em 2011 (9,2% preenchido) e 2012 (22,0%). Isso afeta a prematuridade e, sobretudo, o PIG.
   - O código 8, que não está no dicionário, aparece de 2013 a 2024, e não só em 2022 (Q2d, 07/10/2026). Pelo dado, marca os registros com DUM: de 2013 em diante, a `ig_dum_sem` existe praticamente só no código 8. Isso é inferência do dado, não do dicionário.
   - O `SEMAGESTAC` não é ⌊dias desde a DUM / 7⌋ puro: a igualdade exata com a `ig_dum_sem` fica em 73,5–80,8% ao ano e cai nos anos bissextos. A concordância de ±1 semana fica em 99,9% ou mais (`logs/descritivo_ig_dum_sem_*`).
3. **A temperatura média é derivada** de (Tmax+Tmin)/2; o BR-DWGD não traz Tmean.
4. **Viés de coorte fixa** em séries temporais de prematuridade: o denominador real são as gestações em risco, e não os nascimentos do dia. A base entrega as duas peças pedidas pela especificação: a flag de coorte fixa em cada registro e a série com e sem ela (E6), e as gestações em risco por semana (06d, E7). A modelagem fica para cada artigo. Isso deve ser tratado no desenho do DLNM (por exemplo, por estratificação temporal ou com a abordagem de gestações em curso), e não na base.
5. **Divergências entre dicionário e dado** (`IDADE`, tamanho de `CODMUNRES`, código 8 em `TPMETESTIM`): resolvidas a favor do dado e documentadas.
6. **PM2.5 do CAMS EAC4** em 0,75° (cerca de 80 km): resolução grosseira para uma exposição municipal. Há zeros exatos em alguns horários (P-PM25-ZERO): a variante `pm25_zero_na` chega a 361 dias faltantes em 2012–2024 num só núcleo. **Sem validação contra estações de superfície**, por decisão de 06/10/2026: a mesma fonte em todas as regiões. É reanálise (modelo com assimilação de satélite), não medida direta.
7. **Curvas do PIG:**
   - a da OMS é de **peso fetal estimado** aplicada ao peso ao nascer (PIG de 15,8% a 19,0%, contra 9,0% no INTERGROWTH e 6,5% em Pedreira);
   - a Table I de Pedreira tem incoerências do impresso em 33–34 semanas, mantidas e sinalizadas;
   - a fórmula do `gigs` difere em até 8 g da tabela que ele traz, em 14 dias de 33–39 semanas, fora da população principal.

## 7. Decisões

**Já tomadas** (detalhe em `logs/desvios_especificacao.md`):
1. **Unidade espacial:** as 26 grandes concentrações urbanas do IBGE, com 277 municípios (`_ConsidAnalise`), no lugar das RMs legais (02/10; reconfirmado em 03/10).
2. **Composição:** fixa (delimitação do IBGE de 2016, Censo 2010) para todo o período.
3. **Cidade-núcleo:** maior município no Censo 2022, ou seja, Serra em Vitória (03/10).
4. **Municípios instalados depois de 2010:** são 6, e nenhum encosta em concentração, então o recorte não muda (E17).
5. **Paridade:** `QTDPARTNOR + QTDPARTCES` como principal e `QTDFILVIVO` como sensibilidade, as duas como colunas (02/10).
6. **PM2.5:** só CAMS EAC4, a mesma fonte em todas as concentrações, sem validação contra estações (06/10).

**Em aberto:**
1. **Pedido de dado com endereço** à NGD/SVSA para as cidades-núcleo (fora do escopo atual).
2. **Variante de PM2.5 e versão da exposição** (`_nucleo`, `_mun`, `_rm_nv`): ficam como colunas; cada artigo escolhe e registra.

**Resolvidos no 06b (05/10/2026):** a definição do óbito neonatal precoce segue o E4, com bordas e censura nos `desvios`; o PTB espontâneo fica com as colunas `sttrabpart` (só 1, 2 e 9: a indução vale para parto vaginal e para cesárea), `stcesparto` e `stcesparto_aj`, e a definição é do artigo.

## 8. Como rodar

Veja `CLAUDE.md`. Em resumo, no Terminal do Mac:

```
cd /Volumes/Forja/Doc/dados_artigos_perinatais_clima/00_scripts
export UV_PROJECT_ENVIRONMENT=$HOME/.venvs/dados_perinatais_clima
uv sync
uv run 99_relatorio_integridade.py
```

O venv fica no disco interno, porque a Forja não é APFS e o venv usa symlinks.

O comando acima não baixa nada: relê o `integridade.csv`, conta municípios válidos no microdado (só a coluna `CODMUNRES`), compara com o metadado do CliMaterna e reescreve o resumo e o bloco automático deste README. A ordem completa, com os testes pequenos de cada download, está no `CLAUDE.md`.

## 9. Referências

- Xavier AC, Scanlon BR, King CW, Alves AI. *Int J Climatol* 2022;42(16):8390–8404. https://doi.org/10.1002/joc.7731
- Saldanha RF, Bastos RR, Barcellos C. Microdatasus. *Cad Saúde Pública* 2019;35(9):e00032419. https://doi.org/10.1590/0102-311X00032419
- Villar J et al. *Lancet* 2014;384(9946):857–868. https://doi.org/10.1016/S0140-6736(14)60932-6
- Villar J et al. *Lancet* 2016;387(10021):844–845. https://doi.org/10.1016/S0140-6736(16)00384-6
- Torezzan C et al. Climaterna dataset. *Data Brief* 2025;62:111920. https://doi.org/10.1016/j.dib.2025.111920
- Ministério da Saúde. Nota Informativa nº 5/2025-DAENT/SVSA/MS (24/09/2025).
- Pedreira CE, Pinto FA, Pereira SP, Costa ES. Birth weight patterns by gestational age in Brazil. *An Acad Bras Cienc* 2011;83(2):619–625. https://doi.org/10.1590/S0001-37652011005000008
- Kiserud T et al. The World Health Organization Fetal Growth Charts. *PLoS Med* 2017;14(1):e1002220. https://doi.org/10.1371/journal.pmed.1002220
- Pacote R `gigs` (rOpenSci), versão 0.5.2.9000. https://docs.ropensci.org/gigs/
