# Fase 1, A3: conjunto da case time series municipal (`serie_ptb_municipal.rds`)

- **Gerado por:** `00_scripts/21_monta_serie_municipal.R`, em 2026-10-09 21:12:51 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Fontes:** `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` (`ptb`, `tmean_mun`, `tmean_nucleo`); `gestacoes_em_risco(nivel = "municipio")` (`z_nv`, semanas 22–36); `calendario()`; w_j da concentração gravado pelo 20.
- **Período gravado:** 2011-12-14 a 2024-11-15, 4.721 dias × 277 municípios = 1.307.717 linhas, sem lacuna (a `crossbasis` com `group = CD_MUN6` precisa da série consecutiva).
- **Offset:** `monta_offset(..., periodo = NULL)` por concentração, com o w_j dela, sobre a grade completa de 2011-12-14 a 2024-11-15 (desvios 44 e 48). O `gestacoes_em_risco` é esparso (só células com `z_nv` ou `z_fetal` > 0) e começa em 2012-01-01. Entraram com Z = 0: os 4.986 dias-município de 2011-12-14 a 2011-12-31 (pela coorte fixa, nenhuma gestação chega à semana 22 antes de 2012-01-01) e, de 2012-01-01 a 2024-11-15, 434 dias-município sem célula nas semanas 22 a 36. Também têm Z_t = 0 <10 dias-município com célula nas semanas 22 a 36 só por `z_fetal` (`z_nv` = 0). Todos esses dias saem com `z_t_zero` = TRUE e offset NA (conferido por código). O offset existe nos dias com Z_t > 0 fora da janela de evento possível; quem decide o que entra no ajuste é a `linha_modelo`.
- **`linha_modelo`** = Z_t > 0 e dia na janela principal: 1.245.946 dias-município de 1.245.946 na janela principal. Nenhum dia da janela principal tem Z_t = 0.
- **NA de propósito:** como na série principal, `ptb` é NA de 2011-12-14 a 2011-12-31 (contagens de 2011 que dependem de IG), e só nesses dias (conferido por código); esses dias só servem de aquecimento da exposição.
- **Nós:** p10, p75 e p90 da `tmean_mun` de 2012-01-01 a 2024-12-31, municípios da concentração agrupados, `quantile(type = 7)`. Ficam só gravados (`01_saidas/fase1/nos_tmean_mun_concentracao.csv`), sem ir para o retorno.
- **Arquivos gravados (fora do git), SHA-256:**
  - `01_saidas/fase1/serie_ptb_municipal.rds`: `04dad6b1b54472802594ef3ed44adcf327c02e0cd7ed88dd90af63b86770cd49`;
  - `01_saidas/fase1/nos_tmean_mun_concentracao.csv`: `93c2e43244b3b2ecd5db7b690073f62dbb249f5a21a6c46671e0e328d90565be`.

## Esquema

Uma linha por `CD_MUN6` × `data`, ordenada por concentração, município e data.

| # | Coluna | Tipo | Conteúdo |
|---|---|---|---|
|  1 | `CD_MUN6` | character | município (6 dígitos) |
|  2 | `recorte_principal` | character | concentração |
|  3 | `data` | Date | dia |
|  4 | `ptb` | integer | PTB (22–36), coorte fixa 22 |
|  5 | `z_t` | numeric | Σ_{j=22}^{36} z_nv do município (0 nos dias sem célula nas semanas 22–36 e de 2011-12-14 a 2011-12-31) |
|  6 | `w_t` | numeric | Σ_j Z_tj·w_j / Z_t, com o w_j da concentração (NA se Z_t = 0) |
|  7 | `log_z` | numeric | log(Z_t) |
|  8 | `log_w` | numeric | log(W_t) |
|  9 | `log_zw` | numeric | log(Σ_j Z_tj·w_j), γ = 1 (NA se Z_t = 0) |
| 10 | `z_t_zero` | logical | Z_t = 0 |
| 11 | `tmean_mun` | numeric | exposição do município (°C) |
| 12 | `tmean_nucleo` | numeric | exposição da cidade-núcleo (°C) |
| 13 | `dia_semana` | factor (seg, ter, qua, qui, sex, sab, dom) | dia da semana |
| 14 | `feriado_nacional` | integer | 0/1 |
| 15 | `carnaval` | integer | 0/1 |
| 16 | `moveis` | integer | 0/1 |
| 17 | `ano` | integer | ano |
| 18 | `mes` | integer | mês |
| 19 | `estrato_mun` | character | município_ano_mês |
| 20 | `janela_principal` | logical | 2012-04-14 a 2024-08-06 |
| 21 | `janela_evento_possivel` | logical | 2012-01-04 a 2024-11-15 |
| 22 | `linha_modelo` | logical | Z_t > 0 e janela principal (§3.1: dias de Z_t = 0 fora) |

`versao()` no fim: 4443971b.
