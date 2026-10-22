# Fase 1, A2: série principal do PTB por concentração (`serie_ptb_principal.rds`)

- **Gerado por:** `00_scripts/20_monta_serie_principal.R`, em 2026-10-09 21:12:09 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Fontes:** `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)`; `gestacoes_em_risco(nivel = "recorte")` (`z_nv`, semanas 22–36); `calendario()`, por `data`; `nascimentos()` só para o w_j.
- **Período gravado:** 2011-12-14 a 2024-11-15, 4.721 dias × 26 concentrações = 122.746 linhas. A janela principal tem 4.498 dias por concentração.
- **w_j:** `calcula_wj()` por concentração, j de 22 a 36, sobre os NV com `unico`, `ga_sem` 22–42 e `coorte_fixa_22`. A população é idêntica a `pop_ptb & coorte_fixa_22` (conferido linha a linha: sim); são 13.791.848 NV nas 26 concentrações somadas. Pares concentração × semana com n_j < 10: 0. O w_j por concentração fica só em `01_saidas/fase1/wj_ptb_concentracao.csv`; o resumo publicável está na A6 (`conferencias_fase1_20261009.md`).
- **Offset:** `monta_offset()` por concentração, com `periodo` = janela de evento possível (2012-01-04 a 2024-11-15). Rodou sem erro nas 26, ou seja, Z_t > 0 em todos os dias dessa janela. O `gestacoes_em_risco` começa em 2012-01-01. De 2011-12-14 a 2011-12-31, `z_t` = 0 e `z_t_zero` = TRUE, com `w_t` e offset NA: pela coorte fixa (s ≥ 2011-07-31), nenhuma gestação chega à semana 22 antes de 2012-01-01 (desvio 48). De 2012-01-01 a 2012-01-03, `z_t` e `w_t` são calculados e o offset é NA (fora da janela de evento possível). Conferido por código antes de gravar.
- **NA de propósito, fora de qualquer dia de modelo:** a base grava como NA, em 2011, as contagens que dependem de IG. Por isso `ptb`, os subtipos e `nv_unicos` são NA de 2011-12-14 a 2011-12-31 (dias que só servem de aquecimento da exposição), e só nesses dias (conferido por código antes de gravar).
- **Referências de exposição** (`01_saidas/fase1/referencias_exposicao.csv`): `tmean_nucleo` diária de 2012-01-01 a 2024-12-31, `quantile(type = 7)`, ano inteiro e novembro a março (52 linhas). Comparação com a A5.3 refeita (`01_saidas/fase0_rerun/a5_3_percentis_diarios.csv`), coluna a coluna (as 9 colunas existem nos dois arquivos, sem NA; tolerância 1e-12): n_dias 0.000000e+00; p1 4.973799e-14; p10 4.973799e-14; p50 4.973799e-14; p75 4.973799e-14; p90 4.973799e-14; p99 4.973799e-14; media 4.973799e-14; amplitude_p99_p1 4.618528e-14. Resultado: igual.
- **Arquivos gravados (fora do git), SHA-256:**
  - `01_saidas/fase1/serie_ptb_principal.rds`: `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917`;
  - `01_saidas/fase1/wj_ptb_concentracao.csv`: `23e753ba36743c7eae2a577b9c3f1aa11d2c60803dde95ac47b30b6aea756cd3`;
  - `01_saidas/fase1/referencias_exposicao.csv`: `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467`.

## Esquema do conjunto analítico principal (contrato de entrada do `ajusta_dlnm()`)

Uma linha por `recorte_principal` × `data`, ordenada por concentração e data.

| # | Coluna | Tipo | Conteúdo |
|---|---|---|---|
|  1 | `recorte_principal` | character | concentração (código IBGE de 7 dígitos) |
|  2 | `data` | Date | dia |
|  3 | `ptb` | integer | PTB (22–36 semanas), coorte fixa 22 |
|  4 | `ptb_extremo` | integer | ≤ 27 semanas |
|  5 | `ptb_muito` | integer | 28–31 semanas |
|  6 | `ptb_moderado_tardio` | integer | 32–36 semanas |
|  7 | `nv_unicos` | integer | NV únicos 22–42, coorte fixa 22 |
|  8 | `z_t` | numeric | Σ_{j=22}^{36} z_nv |
|  9 | `w_t` | numeric | Σ_j Z_tj·w_j / Z_t |
| 10 | `log_z` | numeric | log(Z_t); offset |
| 11 | `log_w` | numeric | log(W_t); termo γ·log(W_t) |
| 12 | `log_zw` | numeric | log(Σ_j Z_tj·w_j) = offset com γ = 1 |
| 13 | `z_t_zero` | logical | Z_t = 0 (TRUE de 2011-12-14 a 2011-12-31) |
| 14 | `tmean_nucleo` | numeric | exposição principal (°C) |
| 15 | `tmean_rm_nv` | numeric | sensibilidade de nível (°C) |
| 16 | `rh_nucleo` | numeric | umidade relativa (%) |
| 17 | `pm25_local_nucleo` | numeric | PM2.5 local, variante principal (µg/m³) |
| 18 | `pm25_local_zero_na_nucleo` | numeric | PM2.5 local, zero = NA (variante secundária) |
| 19 | `dia_semana` | factor (seg, ter, qua, qui, sex, sab, dom) | dia da semana (calendario()) |
| 20 | `feriado_nacional` | integer | feriado nacional por lei federal (0/1) |
| 21 | `carnaval` | integer | segunda e terça de carnaval (0/1) |
| 22 | `moveis` | integer | quarta de cinzas, sexta da paixão ou corpus christi (0/1) |
| 23 | `ano` | integer | ano (calendario()) |
| 24 | `mes` | integer | mês (calendario()) |
| 25 | `estrato` | character | concentração_ano_mês (eliminate do gnm) |
| 26 | `janela_principal` | logical | 2012-04-14 a 2024-08-06 |
| 27 | `janela_evento_possivel` | logical | 2012-01-04 a 2024-11-15 |

## A5: o que fica para a Fase 4 (não montado nesta fase)

- a §3.5 redefinida (decisões §12, versões (i) e (ii), com coorte fixa e Z_t próprios);
- o termo precoce (desvio 4): a janela vai até 2024-11-19, depois do fim do período gravado, e usa Z nas semanas 37–38; a Fase 4 extrai de novo;
- Tmax, Tmin e temperatura aparente (§1.1 e §10.2), de `clima_municipal()`;
- `z_fetal` em Z;
- w_j por ano;
- 2011 por `GESTACAO`;
- os feriados locais.

`versao()` no fim: 4443971b.
