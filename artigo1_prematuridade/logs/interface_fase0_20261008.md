# A4: verificação da interface (só esquema)

- **Gerado por:** `00_scripts/01_interface.R`, em 2026-10-08 16:09:08 -03.
- **Base:** `versao()` no início = 7e99bf94 (o fim está na última linha); manifesto de 2026-10-06.
- **Fontes:** colunas e tipos vêm do `09_acesso/manifesto.json`; definições, do código de construção da base. Nenhuma linha de dado lida.

## Colunas

| Função | Arquivo | Coluna | Presente | Tipo | Nota |
|---|---|---|---|---|---|
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `recorte_principal` | sim | `large_string` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `data` | sim | `date32[day]` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `nv_unicos` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb_extremo` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb_muito` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb_moderado_tardio` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `obito_perinatal` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `tmean_nucleo` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `tmean_rm_nv` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `rh_nucleo` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `pm25_local_nucleo` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `pm25_local_zero_na_nucleo` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `dia_semana` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `feriado_nacional` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `carnaval` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `quarta_cinzas` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `sexta_paixao` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `corpus_christi` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `nv_termo_precoce` | não | `—` | termo precoce / NV por semana: nomes procurados |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb_37_38` | não | `—` | termo precoce / NV por semana: nomes procurados |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `nv_semana` | não | `—` | termo precoce / NV por semana: nomes procurados |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `CD_MUN6` | sim | `large_string` |  |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `data` | sim | `date32[day]` |  |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `ptb` | sim | `int32` |  |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `tmean_mun` | sim | `double` |  |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `tmean_nucleo` | sim | `double` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `recorte_principal` | sim | `large_string` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `data` | sim | `date32[day]` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `semana` | sim | `int16` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `z_nv` | sim | `int32` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `z_fetal` | sim | `int32` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `CD_MUN6` | sim | `large_string` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `data` | sim | `date32[day]` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `semana` | sim | `int16` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `z_nv` | sim | `int32` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `z_fetal` | sim | `int32` |  |
| `expo_semanal("tmean", "nucleo")` | `expo_semanal_tmean_nucleo.parquet` | `recorte_principal` | sim | `large_string` |  |
| `expo_semanal("tmean", "nucleo")` | `expo_semanal_tmean_nucleo.parquet` | `dum_est` | sim | `date32[day]` |  |
| `nascimentos()` | `nascimentos.parquet` | `STTRABPART` | não | `—` |  |
| `nascimentos()` | `nascimentos.parquet` | `sttrabpart` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `stcesparto` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `stcesparto_aj` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `PARTO` | não | `—` |  |
| `nascimentos()` | `nascimentos.parquet` | `parto` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `DTULTMENST` | não | `—` |  |
| `nascimentos()` | `nascimentos.parquet` | `TPMETESTIM` | não | `—` |  |
| `nascimentos()` | `nascimentos.parquet` | `metodo_ig` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `gestacao_cat` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `ga_sem` | sim | `int16` |  |
| `nascimentos()` | `nascimentos.parquet` | `dum_est` | sim | `date32[day]` |  |
| `nascimentos()` | `nascimentos.parquet` | `CD_MUN6` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `data` | sim | `date32[day]` |  |
| `nascimentos()` | `nascimentos.parquet` | `unico` | sim | `bool` |  |
| `nascimentos()` | `nascimentos.parquet` | `coorte_fixa_22` | sim | `bool` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `data` | sim | `date32[day]` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `dia_semana` | sim | `int32` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `feriado_nacional` | sim | `int64` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `carnaval` | sim | `int64` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `quarta_cinzas` | sim | `int64` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `sexta_paixao` | sim | `int64` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `corpus_christi` | sim | `int64` |  |
| `expo_semanal("tmean", "nucleo")` | `expo_semanal_tmean_nucleo.parquet` | `s01 … s37` | sim (37 de 37) | `double` |  |

## Referências (tabelas públicas)

- **`concentracoes()`:** 277 municípios em 26 concentrações.
- **`cidade_nucleo()`:** 26 linhas; um núcleo por concentração: sim.

## Evidências do código de construção (para os itens (a)–(g) do chat)

- (a), (d) `06b_desfechos.py`, linha 206: `pl.col("PARTO").alias("parto"), pl.col("STTRABPART").alias("sttrabpart"), pl.col("STCESPARTO").alias("stcesparto"),`
- (e) `06b_desfechos.py`, linha 197: `"ig_cat", pl.col("GESTACAO").alias("gestacao_cat"), pl.col("TPMETESTIM").alias("metodo_ig"), "dum_est",`
- (c) `utils.py`, linha 194: `buf[c].append(s if s != "" else None)`
- (c), (d) `06b_desfechos.py`, linha 161: `stcesparto_aj=pl.when((pl.col("PARTO") == "1") & pl.col("STCESPARTO").is_null()).then(pl.lit("3"))`
- (f) `06b_desfechos.py`, linha 142: `sg = pl.col("SEMAGESTAC").str.strip_chars().cast(pl.Int32, strict=False)`
- (f) `06b_desfechos.py`, linha 143: `ga = pl.when(sg.is_between(22, 44)).then(sg).otherwise(None)`
- (f) `06b_desfechos.py`, linha 166: `pop_ptb=(pl.col("unico") & pl.col("ga_sem").is_between(22, 42)).fill_null(False),`
- (f) `06b_desfechos.py`, linha 169: `ptb=(pl.col("pop_ptb") & (pl.col("ga_sem") <= 36)).fill_null(False),`
- (g) `06b_desfechos.py`, linha 144: `unico = (pl.col("GRAVIDEZ") == "1").fill_null(False)`

A leitura destas evidências, escrita à mão, está em `logs/interface_conclusoes_fase0_20261008.md`.

`versao()` no fim: 7e99bf94.
