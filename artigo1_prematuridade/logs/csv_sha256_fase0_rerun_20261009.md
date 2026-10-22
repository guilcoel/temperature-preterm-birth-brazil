# A6: SHA-256 dos CSV de `01_saidas/fase0_rerun/` (Fase 0 refeita)

- **Gerado por:** `00_scripts/11_sha256_csv_rerun.R`, em 2026-10-09 09:31:19 -03, com `shasum -a 256`. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Para que serve:** registrar exatamente quais arquivos sustentam os números da Fase 0 refeita; a Revisão 2 final copia estes SHA-256 para a seção 11 das decisões. Os CSV ficam fora do git.
- **Os modelos não leem estes CSV.** São saídas descritivas, gravadas por `write.csv` com 15 dígitos significativos; os logs `.md` trazem os valores arredondados.
- **Caminho:** relativo à raiz do repositório (`/Volumes/Forja/Doc/artigos_perinatais_clima`). **Linhas:** do arquivo, com o cabeçalho.

| Caminho | SHA-256 | Bytes | Linhas | Conteúdo | Gerado por |
|---|---|---|---|---|---|
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_1_totais.csv` | `0fe49f86efe2cc3e31c4aa571850b946706a4ef9180d32dc2e979d536ad0642f` | 205 |   4 | A5.1: totais da série com coorte fixa, 2012–2024, 26 somadas (NV únicos, PTB, óbito perinatal) | `02_recontagens_fase0.R` |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_2_eventos_janelas.csv` | `a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5` | 11.454 | 105 | A5.2: PTB e perinatal por concentração; total 2012–2024, na janela e perda, nas janelas principal e de evento possível | `02_recontagens_fase0.R` |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_3_percentis_diarios.csv` | `fa3b8fb141c3b4f306d01201a99af51db5c1469bb5a0b43116b58fd678701650` | 16.223 |  53 | A5.3: percentis da `tmean_nucleo` diária por concentração (ano inteiro e novembro a março) | `02_recontagens_fase0.R` |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_4_semanal_mm.csv` | `c054d81c68aba88e1975380a2d9f2e202fb8694b50f55338ff6881b0eaef8ca6` | 13.181 |  27 | A5.4: percentis das leituras (i) e (ii) da exposição semanal; MM9 (p1, p50, p99); MM14 do 1º e do 2º trimestre (p1, p99); percentil semanal (i) equivalente do p1 e do p99 da MM9 | `02_recontagens_fase0.R` |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv` | `df239471aeee2a16982c70d1b019105a8ce26615fb2918052bc95049c7a00d63` | 6.245 |  27 | A5: p1 e p99 da MM14 do 1º e do 2º trimestre e da MM9 (°C) e o percentil semanal (i) equivalente de cada um | `08_mm14_equivalente_rerun.R` |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_5_pm25_dias_utilizaveis.csv` | `afd134c5931677193aeee11d962c8c8ad78462d2b85e5ff311dd29f95e0e0752` | 6.045 |  53 | A5.5: dias de modelo utilizáveis do `pm25_local_zero_na_nucleo` (lag 0–1) por concentração e janela | `02_recontagens_fase0.R` |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a7_populacao_dum_ano.csv` | `8900d5f94c77a11042890e438af4428f86f72d6343666f2e560bd3ee0a9d8da1` | 684 |  12 | A7: NV e PTB por ano, 2013–2023, 26 somadas, níveis (a) e (c) da DUM, e % mantido | `09_populacao_dum_rerun.R` |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv` | `82204b6b25ae61c74b1cfe891789447620662fc7d1966a37e24bd59dde98f64e` | 2.894 |  27 | A7: NV e PTB por concentração na janela principal, níveis (a), (b) e (c) da DUM, e % mantido | `09_populacao_dum_rerun.R` |

## O que cada CSV sustenta

| CSV | Distribuição semanal (i) | Percentis da MM9 | Percentis da MM14 | Percentis semanais equivalentes | Máscara | Fase 0A |
|---|---|---|---|---|---|---|
| `a5_1_totais.csv` | — | — | — | — | não precisa: totais das 26 | igual (mesmo SHA-256) |
| `a5_2_eventos_janelas.csv` | — | — | — | — | sem máscara no CSV; nenhuma célula de 1 a 9 (A8; desvio 9) | igual (mesmo SHA-256) |
| `a5_3_percentis_diarios.csv` | — | — | — | — | não se aplica (exposição) | igual (mesmo SHA-256) |
| `a5_4_semanal_mm.csv` | sim (`i_p1`…`i_p99`) | sim | sim (°C) | MM9 | não se aplica (exposição) | igual (mesmo SHA-256) |
| `a5_4c_mm14_mm9_equivalentes.csv` | usada no cálculo (não gravada) | sim | sim (°C) | MM9 e MM14 | não se aplica (exposição) | novo; mesmos números do `a5_4b_mm14_equivalentes.csv` do complemento (maior diferença 9.9e-14; SHA-256 do a5_4b: `d6584a135feea42e12221c9b370630b213c470e2a1ad96c006dc9455d6dfd7cc`), texto diferente em alguma última casa |
| `a5_5_pm25_dias_utilizaveis.csv` | — | — | — | — | não se aplica (exposição) | igual (mesmo SHA-256) |
| `a7_populacao_dum_ano.csv` | — | — | — | — | sim: gravado já mascarado (nenhuma supressão necessária) | novo (A7) |
| `a7_populacao_dum_concentracao.csv` | — | — | — | — | sim: gravado já mascarado ("supr." e "—") | novo (A7) |

```
$ shasum -a 256 01_saidas/fase0_rerun/*.csv
0fe49f86efe2cc3e31c4aa571850b946706a4ef9180d32dc2e979d536ad0642f  01_saidas/fase0_rerun/a5_1_totais.csv
a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5  01_saidas/fase0_rerun/a5_2_eventos_janelas.csv
fa3b8fb141c3b4f306d01201a99af51db5c1469bb5a0b43116b58fd678701650  01_saidas/fase0_rerun/a5_3_percentis_diarios.csv
c054d81c68aba88e1975380a2d9f2e202fb8694b50f55338ff6881b0eaef8ca6  01_saidas/fase0_rerun/a5_4_semanal_mm.csv
df239471aeee2a16982c70d1b019105a8ce26615fb2918052bc95049c7a00d63  01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv
afd134c5931677193aeee11d962c8c8ad78462d2b85e5ff311dd29f95e0e0752  01_saidas/fase0_rerun/a5_5_pm25_dias_utilizaveis.csv
8900d5f94c77a11042890e438af4428f86f72d6343666f2e560bd3ee0a9d8da1  01_saidas/fase0_rerun/a7_populacao_dum_ano.csv
82204b6b25ae61c74b1cfe891789447620662fc7d1966a37e24bd59dde98f64e  01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv
$ ls -l 01_saidas/fase0_rerun/*.csv
205 out  9 08:43 01_saidas/fase0_rerun/a5_1_totais.csv
11454 out  9 08:43 01_saidas/fase0_rerun/a5_2_eventos_janelas.csv
16223 out  9 08:43 01_saidas/fase0_rerun/a5_3_percentis_diarios.csv
13181 out  9 08:43 01_saidas/fase0_rerun/a5_4_semanal_mm.csv
6245 out  9 08:44 01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv
6045 out  9 08:43 01_saidas/fase0_rerun/a5_5_pm25_dias_utilizaveis.csv
684 out  9 08:58 01_saidas/fase0_rerun/a7_populacao_dum_ano.csv
2894 out  9 08:58 01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv
```

- **Conferências:** 8 CSV, todos com cabeçalho e dados (sim); os cinco da A4 com o mesmo SHA-256 da Fase 0A; os `._*` (AppleDouble do exFAT) não são CSV e ficam de fora.

`versao()` no fim: 4443971b.
