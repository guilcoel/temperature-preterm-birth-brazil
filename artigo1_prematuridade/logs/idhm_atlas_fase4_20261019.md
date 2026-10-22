# Fase 4, Parte C4: IDHM 2010 por município (Atlas do Desenvolvimento Humano no Brasil)

- **Gerado por:** `00_scripts/81_idhm_atlas_fase4.py` (SHA-256 `e1f954b6dff5cc8d2c8e7271513d7d2992181866a9a27baf189d3616a34f84a2`), início em 2026-10-19 11:13:01 -0300, fim em 2026-10-19 11:13:09 -0300. Rodada `20261019`.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `eddb2b8632e63d2191a88ca2bc9091824532d998` (ramo `main`); último commit da `COORD` no `HEAD`: `63a2342 COORD: COORD-9 (pausa da COORD e novo modo de trabalho do A1, 19/10)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: vazio.
- **Fonte:** Atlas do Desenvolvimento Humano no Brasil (PNUD, Ipea e FJP), arquivo `censo_total_1991_2010.xlsx`, planilha `MUN 91-00-10`, colunas `ANO`, `Codmun7`, `IDHM` e `POP`; baixado de https://www.atlasbrasil.org.br/cockpit/storage/uploads/dados/ em 19/10/2026 (A1-113).
- **Entradas (SHA-256 = registrados na A1-113):** `01_saidas/fase4/idhm_atlas_download/censo_total_1991_2010.xlsx` (`a7046af2c47fe5a07ae474495f2941c6135a009de38bf40a4a90876498bb6602`); `01_saidas/fase4/idhm_atlas_download/censo_metadados_1991_2010.xlsx` (`b273991a54b2dc4bafe2dad53225751621e8898dbb70fe52c1888d10007d57bf`).

## Resultado

- **Municípios em 2010:** 5.565; IDHM de 0,418 a 0,862; nenhum código duplicado, nenhum IDHM fora de (0, 1).
- **Saída (fora do git):** `01_saidas/fase4/idhm/idhm2010_municipios_atlas.csv`: `d818f65becb0945f622aac3bfc4bd21050bb665d7c038f19ff41facab386efcc`.
- **Resultado:** ok.
