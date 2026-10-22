# FONTE — Malhas territoriais (IBGE)

**Data de acesso:** 2026-10-01 (America/Sao_Paulo)

| Item | Valor |
|---|---|
| Produto | IBGE, Malha Municipal Digital — https://www.ibge.gov.br/geociencias/organizacao-do-territorio/malhas-territoriais/15774-malhas.html |
| Versão usada | **2024**, coerente com o fim do período. A 2025 também existe no servidor |
| Arquivos | `BR_Municipios_2024.zip` (199M), `BR_UF_2024.zip` (14M), de 2025-04-29 |
| Diretório | https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2024/Brasil/ |
| Outros disponíveis no mesmo diretório | `BR_Pais_2024`, `BR_Regioes_2024`, `BR_RG_Imediatas_2024`, `BR_RG_Intermediarias_2024` |
| Sistema de referência | SIRGAS 2000 (EPSG:4674); conferido na leitura e gravado no log |

## Processamento (`05_shapefiles.py`)

O script baixa, registra o MD5, descompacta, lê e grava `municipios_2024.gpkg` (com `CD_MUN6` = 6 primeiros dígitos, a chave de ligação com o DATASUS).

**Feições que não são municípios:** o Leia-me da malha de 2019 informa "2 Áreas Estaduais Operacionais (Lagoa dos Patos e Lagoa Mirim)" (https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2019/Leia_me_Malha_Digital_2019.pdf). Na malha 2024 (conferido em 2026-10-02), elas aparecem como `4300002` (Área Operacional "Lagoa dos Patos") e `4300001` (Área Operacional "Lagoa Mirim"). O script as exclui **só pelo código** e para se o conjunto excluído for diferente desse.

- **Correção de 2026-10-02:** a versão anterior também casava pelo nome e excluía por engano o **município Lagoa dos Patos (MG, 3137304)**. Corrigido; nenhum recorte metropolitano foi afetado.

**Resultado (2026-10-02):**

| Item | Valor |
|---|---|
| `BR_Municipios_2024.zip` | 208.153.231 bytes, MD5 119f37dad6fa1f84512b5f0dcb1635a3, 5.573 feições, EPSG:4674 |
| `BR_UF_2024.zip` | 14.674.008 bytes, MD5 edc1a3250b8d2f573f700bb5fc89b365, 27 feições, EPSG:4674 |
| `municipios_2024.gpkg` | **5.571 municípios** |

- Comparação com o Censo 2022 (tabela SIDRA 4709): só **Boa Esperança do Norte (MT, 5101837)** está na malha e não no Censo. É um município criado depois de 2011; o ano de instalação ainda não foi verificado em fonte oficial. Pelo E17, ele não encosta em nenhuma concentração urbana, então não afeta o recorte.
- **Os 277 municípios das 26 concentrações urbanas estão na malha** (o `04` para se faltar algum). Os 1.442 municípios das RMs legais de 2024, que ficam só como documentação, também estão.
- **Contagem de feições** (auditoria A7/R18): o zip tem 5.573 feições, porque inclui as duas lagoas (4300001 e 4300002). O `n_municipios` = 5.573 da linha `IBGE-malha` do `integridade.csv` conta feições, não municípios. O `municipios_2024.gpkg` tem 5.571.

## Alternativa em R

O pacote `geobr` (IPEA) traz `read_metro_area()` e `read_municipality()`. Não é usado aqui para manter a fonte primária do IBGE com checksum.
