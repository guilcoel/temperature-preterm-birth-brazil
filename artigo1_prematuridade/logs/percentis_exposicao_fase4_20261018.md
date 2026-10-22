# Fase 4, Parte B1.2: grades de percentis, só de exposição

- **Gerado por:** `00_scripts/65_percentis_exposicao_fase4.R` (SHA-256 `adf3f0f74c762ed332a8cdeee8c08641c8e40786281e37f327964cc4b3b33a31`), início em 2026-10-18 20:46:06 -0300, fim em 2026-10-18 20:46:08 -0300. Rodada `20261018`. `versao()` no início: 4443971b; no fim: 4443971b.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `ac7dfb8469f6c4f952da8beab0faa5747babe271` (ramo `main`); último commit da `COORD` no `HEAD`: `a925d35 COORD: COORD-8 (tags da Fase 4, Parte A do A1)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: `?? artigo1_prematuridade/logs/reconferencia_series_fase1_fase4_20261018.md`.
- **Código:** `sens_agudos.R` SHA-256 `22baa6ea8e952654a5aca25220d1b3b18130ec36862e12d0a6701b184e201dbc` (igual ao da tag `sens_agudos-v1.0`); `segunda_etapa.R` SHA-256 `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7` (igual ao da tag `segunda_etapa-v1.1`; só a ordem das 26).
- **Fontes:** `serie_diaria(nivel = "recorte")` (`tmean_nucleo`, `tmean_rm_nv`); `serie_diaria(nivel = "municipio")` (`tmean_mun`); `clima_municipal()` do município-núcleo de `cidade_nucleo()` (`tmax`, `tmin`, `tmean`, `rh_mean`). Período 2012-01-01 a 2024-12-31; `quantile(type = 7)` nos percentis 1 a 99, 2,5 e 97,5 (101 percentis).

## Conferências

| Conferência | Maior diferença | Tolerância | Confere |
|---|---|---|---|
| a. `tmean_nucleo` nov–mar contra o `referencias_exposicao.csv` (p1, p10, p50, p75, p90, p99, média, amplitude, n de dias) | 5.0e-14 | 1e-12 | sim |
| b. `tmean_mun` agrupada contra o `nos_tmean_mun_concentracao.csv` (p10, p75, p90, n de valores) | 5.0e-14 | 1e-12 | sim |
| c. `tmean` do `clima_municipal()` do núcleo contra a `tmean_nucleo` da `serie_diaria()`, todos os dias | 0.0e+00 | 0 | sim |
| AT da `temperatura_aparente()` contra a implementação independente, todos os dias | 1.4e-14 | 1e-10 | sim |
| d. NA nas seis exposições no período | 0 | 0 | sim |

## Valores por exposição

| Exposição | Valores por concentração (mín.–máx.) | NA |
|---|---|---|
| `tmean_mun` agrupada (municípios da concentração juntos; nós e eixo da chave 1) | 4.749 – 175.713 | 0 |
| `tmean_rm_nv` | 4.749 – 4.749 | 0 |
| Tmax do núcleo | 4.749 – 4.749 | 0 |
| Tmin do núcleo | 4.749 – 4.749 | 0 |
| Temperatura aparente do núcleo (§1.1) | 4.749 – 4.749 | 0 |
| `tmean_nucleo` só de novembro a março | 1.967 – 1.967 | 0 |

## Eixo médio (média das 26) nos percentis-chave (°C)

| Percentil | tmean_mun_agrupada | tmean_rm_nv | tmax_nucleo | tmin_nucleo | at_nucleo | tmean_nucleo_nov_mar |
|---|---|---|---|---|---|---|
| p1 | 18,588 | 18,785 | 22,038 | 13,699 | 19,814 | 21,888 |
| p2,5 | 19,605 | 19,791 | 23,286 | 14,790 | 21,137 | 22,608 |
| p10 | 21,481 | 21,633 | 25,569 | 16,776 | 23,684 | 23,984 |
| p50 | 24,865 | 24,957 | 29,575 | 20,432 | 28,602 | 26,248 |
| p75 | 26,492 | 26,560 | 31,551 | 21,922 | 30,933 | 27,285 |
| p90 | 27,683 | 27,723 | 33,145 | 22,906 | 32,516 | 28,142 |
| p97,5 | 28,866 | 28,877 | 34,845 | 23,833 | 33,994 | 29,065 |
| p99 | 29,491 | 29,467 | 35,746 | 24,317 | 34,703 | 29,582 |

- A grade completa de cada concentração e de cada exposição está no CSV (formato longo, 17 dígitos).

## Saída (fora do git)

- `01_saidas/fase4/percentis_exposicao_fase4_20261018.csv`: `2b973708974c72ad2c044aa0dbd522fbc52c59b494ff570cf948542357214444`.

- **Resultado:** todas as conferências passam. Tempo: 2 s.

