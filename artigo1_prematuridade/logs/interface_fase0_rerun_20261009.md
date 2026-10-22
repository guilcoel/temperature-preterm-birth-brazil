# A3 da Fase 0 refeita (base 4443971b): verificação da interface, só esquema (a A4 da Fase 0A refeita)

- **Gerado por:** `00_scripts/01_interface.R`, em 2026-10-09 08:43:21 -03.
- **Base:** `versao()` no início = 4443971b (o fim está na última linha); manifesto de 2026-10-08.
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
| `nascimentos()` | `nascimentos.parquet` | `ig_dum_sem` | sim | `int16` |  |
| `pig(com_nascimentos = "ig_dum_sem")` | `pig_classificacao.parquet` | `id_nasc` | sim | `int64` | ig_dum_sem vem do nascimentos pela junção por id_nasc (não é coluna do pig_classificacao) |
| `pig(com_nascimentos = "ig_dum_sem")` | `pig_classificacao.parquet` | `ig_dum_sem` | não | `—` | ig_dum_sem vem do nascimentos pela junção por id_nasc (não é coluna do pig_classificacao) |
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

- (a), (d) `06b_desfechos.py`, linha 242: `pl.col("PARTO").alias("parto"), pl.col("STTRABPART").alias("sttrabpart"), pl.col("STCESPARTO").alias("stcesparto"),`
- (e) `06b_desfechos.py`, linha 233: `"ig_cat", pl.col("GESTACAO").alias("gestacao_cat"), pl.col("TPMETESTIM").alias("metodo_ig"), "dum_est",`
- (c) `utils.py`, linha 194: `buf[c].append(s if s != "" else None)`
- (c), (d) `06b_desfechos.py`, linha 196: `stcesparto_aj=pl.when((pl.col("PARTO") == "1") & pl.col("STCESPARTO").is_null()).then(pl.lit("3"))`
- (f) `06b_desfechos.py`, linha 177: `sg = pl.col("SEMAGESTAC").str.strip_chars().cast(pl.Int32, strict=False)`
- (f) `06b_desfechos.py`, linha 178: `ga = pl.when(sg.is_between(22, 44)).then(sg).otherwise(None)`
- (f) `06b_desfechos.py`, linha 202: `pop_ptb=(pl.col("unico") & pl.col("ga_sem").is_between(22, 42)).fill_null(False),`
- (f) `06b_desfechos.py`, linha 205: `ptb=(pl.col("pop_ptb") & (pl.col("ga_sem") <= 36)).fill_null(False),`
- (g) `06b_desfechos.py`, linha 179: `unico = (pl.col("GRAVIDEZ") == "1").fill_null(False)`

A leitura destas evidências, escrita à mão, está em `logs/interface_conclusoes_fase0_20261008.md`. **Na base 4443971b, os números de linha do `06b_desfechos.py` mudaram** (o commit `2ef7f67` acrescentou as funções da `ig_dum_sem` antes de `derivar_nascimentos`). Os padrões acima são os mesmos, e as linhas citadas aqui são as atuais. O arquivo de conclusões, que é da Fase 0A, cita as linhas antigas e não foi refeito.

## A3: mudanças de esquema entre a versão anterior (7e99bf94; manifesto do commit `9f1957b` da base) e a 4443971b

- `06_processados/nascimentos.parquet`: novas `ig_dum_sem` (int16); saíram nenhuma; tipo mudou nenhum.

## A3: `ig_dum_sem` em `nascimentos()` e em `pig(com_nascimentos = "ig_dum_sem")`

- (pig) `acesso.R`, linha 89: `pig <- function(colunas = NULL, com_nascimentos = NULL) {`
- (pig) `acesso.R`, linha 94: `n <- nascimentos(c("id_nasc", extra))`
- (pig) `acesso.R`, linha 95: `i <- match(p$id_nasc, n$id_nasc)`
- (ig_dum_sem) `DICIONARIO.md`, linha 80: `| `ig_dum_sem` | int16 | IG pela DUM, em semanas completas, na escala do `SEMAGESTAC` (`ga_sem`): ⌊(`DTNASC` − `DTULTMENST`) / 7⌋, com a diferença em dias de calendário entre datas sem hora (sem fuso). **NA** quando a DUM está ausente, quando não é analisável (precisa ter 8 dígitos ddmmaaaa de uma data que existe), quando é posterior ao parto ou quando é anterior a parto − 50 semanas, ou seja, diferença > 350 dias. O corte é em dias, **antes** do ⌊·⌋: de 351 a 356 dias = NA, embora o piso desse 50. Também é NA se a data do parto não for válida. **Nenhum outro filtro.** **Regras de uso, que cabem aos artigos e não à base** (especificação v2.0.2, §3.5; decisões, seção 8): faixa plausível de 20 a 45 semanas, inclusive, e concordância \|`SEMAGESTAC` − `ig_dum_sem`\| ≤ 1. Na base, o `SEMAGESTAC` está em `semagestac_bruto` (texto, como veio) e em `ga_sem` (só 22–44). Com o `ga_sem`, ficam de fora SEMAGESTAC 20, 21 e 45; a escolha é do artigo. A `DTULTMENST` bruta não está em nenhum arquivo da base (minimização, LGPD). No PIG: `pig(com_nascimentos = "ig_dum_sem")` (junção 1:1 por `id_nasc`). Coluna nova da versão `4443971b` (08/10/2026); não existe na `7e99bf94` |`
- (pig) `DICIONARIO.md`, linha 285: `A IG pela DUM (`ig_dum_sem`, sensibilidade da §3.5) não é coluna deste arquivo, que não mudou: vem do `nascimentos` pela interface, com `pig(com_nascimentos = "ig_dum_sem")`. A junção é por `id_nasc`, único nos dois arquivos, e todo `id_nasc` do PIG está no `nascimentos` (testes `paridade_ig_dum_sem.py` e `.R`). Mantém a ordem e o nº de linhas do PIG.`

- **Junção 1:1 por `id_nasc`, provada na base** (logs agregados, sem linha de dado):
  - `logs/paridade_ig_dum_sem_py_20261008_201224.log`: OK    pig(com_nascimentos): mesmo nº de linhas e mesma ordem do pig (junção 1:1) | / _tmp/paridade_ig_dum_sem/py_4443971b.csv gravado | 6/6 casos OK
  - `logs/paridade_ig_dum_sem_R_20261008_201246.log`: 2026-10-08 20:12:46 | OK    R: pig(com_nascimentos) com o mesmo nº de linhas e a mesma ordem do pig (junção 1:1) | / 2026-10-08 20:12:46 | 7/7 casos OK

`versao()` no fim: 4443971b.
