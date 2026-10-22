# Rerunning the analysis outside the original environment

The scripts in this package are the exact code that produced the results, with the provenance checks that guarded each run in the authors'
environment. Outside it, those checks cannot be satisfied as written, and the source data downloaded today may differ from the data downloaded in
October 2026. Rerunning therefore requires the adaptations below, and exact numerical agreement is not guaranteed.

## Adaptations

1. **Paths.** Scripts set the repository and database roots as constants near the top (`REPO`, `BASE`, `CC`, and the `source()` of `09_acesso/acesso.R`). Point them to your copies.
2. **Database version.** Every R script checks `versao() == "4443971b"`, the hash of the manifest of the authors' database build (`base/09_acesso/manifesto.json`). A rebuild from new downloads has another version; replace the expected value with the `versao()` of your build.
3. **Version control.** Scripts require a clean `git status`, record `HEAD`, and some check that version-control tags point to specific commits of the authors' private repository, that a `COORD:` commit exists, or query remote tags. Remove or adapt these checks (column "Checks to adapt").
4. **Shared-code versions.** Scripts load the shared functions from `codigo_compartilhado/R/`, and many first check them against version-control tags (column "Tags checked"). Before running a script, place in `codigo_compartilhado/R/` the versions in its row (column "Versions cited in its logs", matched by SHA-256 against every version in the history), copied from `codigo_compartilhado/versoes/<label>/`. Labels are tags, `untagged-<n>` (a version that ran from a commit without a tag), or `package copy` (the file in `codigo_compartilhado/` itself). The snapshots and their SHA-256 are listed at the end.
5. **Run dates.** Each script names its outputs and its log after a date variable (column "Date variable"); downstream scripts read upstream outputs by the original dates, which appear in the names of the run logs (last column, which lists every log that cites the script). Use the same dates, in a copy without the package's run logs (scripts never overwrite an existing log), and keep the package's logs for comparison.
6. **Input checksums.** Many scripts compare the SHA-256 of their inputs with values recorded in earlier logs. After a rebuild these differ; update or remove the comparisons.
7. **Platform.** The runs used macOS with R's reference BLAS/LAPACK (`libRblas.0.dylib`) and the `quartz()` PDF device. On other systems, adapt the BLAS check and use `cairo_pdf()`.
8. **Third-party code.** `attrdl()` (A. Gasparrini) has no license and is not redistributed: run `Rscript ferramentas/baixa_attrdl.R` from the package root; it downloads the file at the pinned commit and checks its size and hashes (`codigo_compartilhado/inst/terceiros/ORIGEM.md`).
9. **Software.** R 4.5.1 with `renv::restore()` in `artigo1_prematuridade/`; Python 3.12 with `uv sync` in `base/00_scripts/` for the database; Python modules imported by the analysis scripts are listed in the table (`docx` is the `python-docx` package, whose version was not pinned).
10. **Inputs downloaded by hand.** Script 81 reads two spreadsheets of the Atlas of Human Development in Brazil (see its header). Scripts 90, 94, and 95 assemble the article text and need manuscript drafts that are not part of this package.
11. **Local holidays.** The table of local holidays (`codigo_compartilhado/dados_referencia/`) was compiled and validated outside this repository; scripts `69_feriados_locais_fase4.R` and `83_feriados_locais_v11_fase4.R` validated versions 1.0 and 1.1 against the authors' working folder and cannot run elsewhere. Both validated versions are in `codigo_compartilhado/versoes/feriados_locais-v1.0/` and `codigo_compartilhado/versoes/feriados_locais-v1.1/`.

## Pipeline, in order

| # | Script | Date variable | Tags checked | Versions of shared code and reference data cited in its logs | Checks to adapt | Python modules | Logs that cite the script in their first lines (date in the name) |
|---|---|---|---|---|---|---|---|
| 1 | `02_recontagens_fase0.R` | `FASE0_RERUN_DATA` | — | — | database version `4443971b` | — | `autoauditoria_fase0_complemento_20261008.md`, `autoauditoria_fase0_rerun_20261009.md`, `csv_sha256_fase0_20261008.md`, `csv_sha256_fase0_rerun_20261009.md`, `inventario_fase0A_rerun_20261009.md`, `inventario_fase0A_rerun_conferencia1_20261009.md`, `inventario_fase0A_rerun_conferencia2_20261009.md`, `mm14_equivalente_fase0_rerun_20261009.md`, `recontagens_fase0_20261008.md`, `recontagens_fase0_rerun_20261009.md` |
| 2 | `20_monta_serie_principal.R` | `FASE1_DATA` | — | `R/offset.R` (ajusta_dlnm-v1.0, first commit after the run) | database version `4443971b`; input SHA-256 checked against earlier logs | — | `serie_principal_fase1_20261009.md` |
| 3 | `21_monta_serie_municipal.R` | `FASE1_DATA` | — | `R/offset.R` (ajusta_dlnm-v1.0, first commit after the run) | database version `4443971b`; input SHA-256 checked against earlier logs | — | `serie_municipal_fase1_20261009.md` |
| 4 | `22_monta_ptb_espontaneo.R` | `FASE1_DATA` | — | — | database version `4443971b`; input SHA-256 checked against earlier logs | — | `ptb_espontaneo_fase1_20261009.md` |
| 5 | `32_primeira_etapa_principal.R` | `FASE2_DATA` | `ajusta_dlnm-v1.0` | `R/ajusta_dlnm.R` (ajusta_dlnm-v1.0), `R/offset.R` (ajusta_dlnm-v1.0) | reference BLAS/LAPACK; tag → commit hash; database version `4443971b`; input SHA-256 checked against earlier logs | — | `primeira_etapa_fase2_20261010.md` |
| 6 | `40_percentis_exposicao.R` | `FASE3_DATA` | — | `R/segunda_etapa.R` (segunda_etapa-v1.0, first commit after the run) | database version `4443971b`; input SHA-256 checked against earlier logs | — | `CONFORMIDADE_D6_34_segunda_etapa_v1.0_A1_20261015.md`, `percentis_exposicao_fase3_20261013.md` |
| 7 | `45_segunda_etapa_principal.R` | `FASE3_DATA` | `ajusta_dlnm-v1.0`, `segunda_etapa-v1.0` | `R/ajusta_dlnm.R` (ajusta_dlnm-v1.0), `R/offset.R` (ajusta_dlnm-v1.0), `R/segunda_etapa.R` (segunda_etapa-v1.0) | reference BLAS/LAPACK; tag → commit hash; database version `4443971b`; input SHA-256 checked against earlier logs | — | `CONFORMIDADE_D6_34_segunda_etapa_v1.0_A1_20261015.md`, `segunda_etapa_fase3_20261013.md` |
| 8 | `46_fracao_atribuivel.R` | `FASE3_DATA` | `ajusta_dlnm-v1.0`, `segunda_etapa-v1.0` | `R/ajusta_dlnm.R` (ajusta_dlnm-v1.0, by run date), `R/segunda_etapa.R` (segunda_etapa-v1.0) | reference BLAS/LAPACK; tag → commit hash; database version `4443971b`; input SHA-256 checked against earlier logs | — | `fracao_atribuivel_fase3_20261013.md` |
| 9 | `49_testes_posthoc_af.R` | `FASE3_DATA` | `segunda_etapa-v1.0` | `R/ajusta_dlnm.R` (ajusta_dlnm-v1.0), `R/posthoc_af.R` (posthoc_af-v1.0), `R/segunda_etapa.R` (segunda_etapa-v1.0), `tests/roda_testes.R` (package copy), `tests/testa_posthoc_af.R` (package copy) | tag → commit hash; database version `4443971b`; input SHA-256 checked against earlier logs | — | `testes_posthoc_af_fase3_20261013.md` |
| 10 | `50_posthoc_af.R` | `FASE3_DATA` | `segunda_etapa-v1.0` | `R/ajusta_dlnm.R` (ajusta_dlnm-v1.0), `R/posthoc_af.R` (posthoc_af-v1.0), `R/segunda_etapa.R` (segunda_etapa-v1.0), `tests/testa_posthoc_af.R` (package copy) | reference BLAS/LAPACK; tag → commit hash; database version `4443971b`; input SHA-256 checked against earlier logs | — | `posthoc_af_fase3_20261013.md` |
| 11 | `53_diagnostico_grade_mrt.R` | `FASE3_DATA` | `posthoc_af-v1.0`, `segunda_etapa-v1.0` | `R/diagnostico_grade_mrt.R` (untagged-1), `R/posthoc_af.R` (posthoc_af-v1.0), `R/segunda_etapa.R` (segunda_etapa-v1.0), `tests/roda_testes.R` (package copy), `tests/testa_diagnostico_grade_mrt.R` (untagged-1) | reference BLAS/LAPACK; clean git status; tag → commit hash; database version `4443971b`; input SHA-256 checked against earlier logs | — | `diagnostico_grade_mrt_fase3_20261014.md` |
| 12 | `65_percentis_exposicao_fase4.R` | `RODADA` | `segunda_etapa-v1.1`, `sens_agudos-v1.0` | `R/segunda_etapa.R` (segunda_etapa-v1.1), `R/sens_agudos.R` (sens_agudos-v1.0) | clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `percentis_exposicao_fase4_20261018.md` |
| 13 | `66_series_exposicao_offset_fase4.R` | `RODADA` | `offset-v1.1`, `segunda_etapa-v1.1`, `sens_agudos-v1.0` | `R/offset.R` (offset-v1.1), `R/segunda_etapa.R` (segunda_etapa-v1.1), `R/sens_agudos.R` (sens_agudos-v1.0) | clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `series_exposicao_offset_fase4_20261018.md` |
| 14 | `67_ig_dum_e_2011_fase4.R` | `RODADA` | `offset-v1.1`, `segunda_etapa-v1.1` | `R/offset.R` (offset-v1.1), `R/segunda_etapa.R` (segunda_etapa-v1.1) | clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `ig_dum_e_2011_fase4_20261018.md` |
| 15 | `68_contagens_insumos_fase4.R` | `RODADA` | `offset-v1.1`, `segunda_etapa-v1.1` | `R/offset.R` (offset-v1.1), `R/segunda_etapa.R` (segunda_etapa-v1.1) | clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `contagens_insumos_fase4_20261018.md` |
| 16 | `70_chaves_c1_fase4.R` | `RODADA` | `ajusta_dlnm-v1.1`, `diagnostico_grade_mrt-v1.0.1`, `offset-v1.1`, `segunda_etapa-v1.1`, `sens_agudos-v1.0` | `R/ajusta_dlnm.R` (ajusta_dlnm-v1.1), `R/segunda_etapa.R` (segunda_etapa-v1.1), `tests/teste3_fonte_independente.R` (package copy) | reference BLAS/LAPACK; clean git status; a `COORD:` commit in the history; remote tags (`git ls-remote`); database version `4443971b`; input SHA-256 checked against earlier logs; a coordination hand-off note | — | `c1_chaves_fase4_20261019.md` |
| 17 | `72_d3_residuos_defasados_fase4.R` | `RODADA` | `ajusta_dlnm-v1.1`, `segunda_etapa-v1.1`, `sens_agudos-v1.0` | `R/ajusta_dlnm.R` (ajusta_dlnm-v1.1), `R/segunda_etapa.R` (segunda_etapa-v1.1), `R/sens_agudos.R` (sens_agudos-v1.0), `tests/teste3_fonte_independente.R` (package copy) | reference BLAS/LAPACK; clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `d3_fase4_20261019.md` |
| 18 | `73_tmr_p10p90_fase4.R` | `RODADA` | `segunda_etapa-v1.1` | `R/segunda_etapa.R` (segunda_etapa-v1.1) | clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `tmr_p10p90_fase4_20261019.md` |
| 19 | `74_c3_lista_fechada_fase4.R` | `RODADA` | `ajusta_dlnm-v1.1`, `feriados_locais-v1.0`, `segunda_etapa-v1.1`, `sens_agudos-v1.0` | `R/ajusta_dlnm.R` (ajusta_dlnm-v1.1), `R/segunda_etapa.R` (segunda_etapa-v1.1), `R/sens_agudos.R` (sens_agudos-v1.0), `tests/teste3_fonte_independente.R` (package copy) | reference BLAS/LAPACK; clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `c3_fase4_20261019.md` |
| 20 | `77_c4_meta_fase4.R` | `RODADA` | `segunda_etapa-v1.1` | `R/segunda_etapa.R` (segunda_etapa-v1.1) | clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `c4_meta_fase4_20261019.md` |
| 21 | `78_c4_uma_etapa_fase4.R` | `RODADA` | `segunda_etapa-v1.1`, `sens_agudos-v1.0` | `R/segunda_etapa.R` (segunda_etapa-v1.1), `R/sens_agudos.R` (sens_agudos-v1.0) | reference BLAS/LAPACK; clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `c4_uma_etapa_fase4_20261019.md` |
| 22 | `79_c4_s3_fase4.R` | `RODADA` | `segunda_etapa-v1.1`, `sens_agudos-v1.0` | `R/segunda_etapa.R` (segunda_etapa-v1.1), `R/sens_agudos.R` (sens_agudos-v1.0) | reference BLAS/LAPACK; clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `c4_s3_fase4_20261019.md` |
| 23 | `81_idhm_atlas_fase4.py` | `RODADA` | — | — | clean git status; a `COORD:` commit in the history; input SHA-256 checked against earlier logs | `openpyxl` | `idhm_atlas_fase4_20261019.md` |
| 24 | `82_c4_idhm_fase4.R` | `RODADA` | `segunda_etapa-v1.1` | `R/segunda_etapa.R` (segunda_etapa-v1.1) | clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `c4_idhm_fase4_20261019.md` |
| 25 | `84_c3_feriados_locais_fase4.R` | `RODADA` | `ajusta_dlnm-v1.1`, `feriados_locais-v1.1`, `segunda_etapa-v1.1`, `sens_agudos-v1.0` | `R/ajusta_dlnm.R` (ajusta_dlnm-v1.1), `R/segunda_etapa.R` (segunda_etapa-v1.1), `R/sens_agudos.R` (sens_agudos-v1.0), `dados_referencia/feriados_locais_nucleo_2011_2024.csv` (feriados_locais-v1.1), `tests/teste3_fonte_independente.R` (package copy) | reference BLAS/LAPACK; clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `c3_feriados_locais_fase4_20261019.md` |
| 26 | `80_tabela_sensibilidades_fase4.R` | `RODADA` | — | — | clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `tabela_sensibilidades_fase4_20261019.md` |
| 27 | `85_m2_menores_tabela_v2_fase4.R` | `RODADA` | `segunda_etapa-v1.1`, `sens_agudos-v1.0` | `R/segunda_etapa.R` (segunda_etapa-v1.1), `R/sens_agudos.R` (sens_agudos-v1.0) | clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `m2_menores_tabela_v2_fase4_20261019.md` |
| 28 | `86_figuras_m3_fase4.R` | `RODADA` | `segunda_etapa-v1.1` | `R/segunda_etapa.R` (segunda_etapa-v1.1) | quartz() PDF device; clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `figuras_m3_fase4_20261019.md`, `figuras_m3_fase4_20261019_v2.md`, `figuras_m3_fase4_20261020_v3.md`, `figuras_m3_fase4_20261020_v4.md` |
| 29 | `87_tabelas_m3_fase4.R` | `RODADA` | — | `R/segunda_etapa.R` (segunda_etapa-v1.1, by run date) | clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `tabelas_m3_fase4_20261019.md`, `tabelas_m3_fase4_20261019_v2.md`, `tabelas_m3_fase4_20261019_v3.md`, `tabelas_m3_fase4_20261019_v4.md` |
| 30 | `90_manuscrito_m4_fase4.R` | `RODADA` | — | `R/segunda_etapa.R` (segunda_etapa-v1.1, by run date) | clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `manuscrito_m4_fase4_20261019.md`, `manuscrito_m4_fase4_20261019_v2.md`, `manuscrito_m4_fase4_20261019_v3.md`, `manuscrito_m4_fase4_20261019_v4.md`, `manuscrito_m4_fase4_20261019_v5.md`, `manuscrito_m4_fase4_20261019_v6.md`, `manuscrito_m4_fase4_20261019_v7.md`, `manuscrito_m4_fase4_20261019_v8.md` |
| 31 | `93_selecao_ausentes_m5b.R` | `RODADA` | — | — | quartz() PDF device; clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs | — | `selecao_ausentes_m5b_20261020.md`, `selecao_ausentes_m5b_20261020_v2.md` |
| 32 | `94_entrega_metodos_resultados.py` | `RODADA` | — | — | clean git status; a `COORD:` commit in the history; input SHA-256 checked against earlier logs | `docx` | `entrega_metodos_resultados_20261020_v1.md`, `entrega_metodos_resultados_20261020_v2.md`, `entrega_metodos_resultados_20261020_v3.md`, `entrega_metodos_resultados_20261020_v4.md`, `entrega_metodos_resultados_20261021_v5.md`, `entrega_metodos_resultados_20261021_v6.md` |
| 33 | `95_suplemento_entrega.py` | `RODADA` | — | — | clean git status; a `COORD:` commit in the history; input SHA-256 checked against earlier logs | `docx` | `suplemento_entrega_20261021_v1.md`, `suplemento_entrega_20261021_v2.md` |
| 34 | `69_feriados_locais_fase4.R (not runnable outside)` | `RODADA` | — | `dados_referencia/README.md` (feriados_locais-v1.0), `dados_referencia/feriados_locais_nucleo_2011_2024.csv` (feriados_locais-v1.0) | clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs; files outside the package (authors' working folders or ~/Downloads) | — | `feriados_locais_fase4_20261019.md` |
| 35 | `83_feriados_locais_v11_fase4.R (not runnable outside)` | `RODADA` | — | `dados_referencia/README.md` (feriados_locais-v1.1), `dados_referencia/feriados_locais_nucleo_2011_2024.csv` (feriados_locais-v1.0), `dados_referencia/feriados_locais_nucleo_2011_2024.csv` (feriados_locais-v1.1) | clean git status; a `COORD:` commit in the history; database version `4443971b`; input SHA-256 checked against earlier logs; files outside the package (authors' working folders or ~/Downloads) | — | `feriados_locais_v11_fase4_20261019.md`, `feriados_locais_v11_fase4_20261019_b.md`, `feriados_locais_v11_fase4_20261019_c.md` |

## Shared-code snapshots

| Label | File | SHA-256 |
|---|---|---|
| `ajusta_dlnm-v1.0` | `R/ajusta_dlnm.R` | `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009` |
| `ajusta_dlnm-v1.0` | `R/offset.R` | `55111b2cc510d7b1c7b78b7f84e99997c5202825e0353da70bab0b4bea290bae` |
| `ajusta_dlnm-v1.1` | `R/ajusta_dlnm.R` | `2acf21797f576a5a5c34a4cdab081a8bec2d09473d9993759e4d3409935eb68b` |
| `ajusta_dlnm-v1.1` | `R/diagnostico_grade_mrt.R` | `b263bdf6453a950a4fc544860baf3b989f190e432740a1c89065b15e7b2f9731` |
| `ajusta_dlnm-v1.1` | `R/offset.R` | `b2aac93b4681c26d74427172bcdd3adb62fbf8cd75bea97910153892e12ed398` |
| `ajusta_dlnm-v1.1` | `R/posthoc_af.R` | `a90096b74237afee576532460def71937083e1d6363e6d1ef8f1e204b1f0af73` |
| `ajusta_dlnm-v1.1` | `R/segunda_etapa.R` | `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7` |
| `ajusta_dlnm-v1.1` | `R/sens_agudos.R` | `22baa6ea8e952654a5aca25220d1b3b18130ec36862e12d0a6701b184e201dbc` |
| `diagnostico_grade_mrt-v1.0.1` | `R/ajusta_dlnm.R` | `2acf21797f576a5a5c34a4cdab081a8bec2d09473d9993759e4d3409935eb68b` |
| `diagnostico_grade_mrt-v1.0.1` | `R/diagnostico_grade_mrt.R` | `b263bdf6453a950a4fc544860baf3b989f190e432740a1c89065b15e7b2f9731` |
| `diagnostico_grade_mrt-v1.0.1` | `R/offset.R` | `7f34790f7fac3d670504048249f26d76d80657dde5eb2a0388c2b7365c9ead81` |
| `diagnostico_grade_mrt-v1.0.1` | `R/posthoc_af.R` | `a90096b74237afee576532460def71937083e1d6363e6d1ef8f1e204b1f0af73` |
| `diagnostico_grade_mrt-v1.0.1` | `R/segunda_etapa.R` | `9605885a317480c5dda5dbc02af47c42d50f31f9a4dfa29c8fe879d0b10d86b0` |
| `diagnostico_grade_mrt-v1.0.1` | `R/sens_agudos.R` | `9ddf7ac9490bec30e78a4415dead86f9158102bae9740259a3a66d406e4ee22b` |
| `feriados_locais-v1.0` | `R/ajusta_dlnm.R` | `2acf21797f576a5a5c34a4cdab081a8bec2d09473d9993759e4d3409935eb68b` |
| `feriados_locais-v1.0` | `R/diagnostico_grade_mrt.R` | `b263bdf6453a950a4fc544860baf3b989f190e432740a1c89065b15e7b2f9731` |
| `feriados_locais-v1.0` | `R/offset.R` | `b2aac93b4681c26d74427172bcdd3adb62fbf8cd75bea97910153892e12ed398` |
| `feriados_locais-v1.0` | `R/posthoc_af.R` | `a90096b74237afee576532460def71937083e1d6363e6d1ef8f1e204b1f0af73` |
| `feriados_locais-v1.0` | `R/segunda_etapa.R` | `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7` |
| `feriados_locais-v1.0` | `R/sens_agudos.R` | `22baa6ea8e952654a5aca25220d1b3b18130ec36862e12d0a6701b184e201dbc` |
| `feriados_locais-v1.0` | `dados_referencia/README.md` | `2dc6fac8b4618294911b4dc45fb5a70dd66be60c3f0b36ea28d920dfbea37dcb` |
| `feriados_locais-v1.0` | `dados_referencia/feriados_locais_nucleo_2011_2024.csv` | `ef5d99b1bfb1d0a33f44ad057e8b542015ce61aa9da5fb3d73caf117daba2e03` |
| `feriados_locais-v1.1` | `R/ajusta_dlnm.R` | `2acf21797f576a5a5c34a4cdab081a8bec2d09473d9993759e4d3409935eb68b` |
| `feriados_locais-v1.1` | `R/diagnostico_grade_mrt.R` | `b263bdf6453a950a4fc544860baf3b989f190e432740a1c89065b15e7b2f9731` |
| `feriados_locais-v1.1` | `R/offset.R` | `b2aac93b4681c26d74427172bcdd3adb62fbf8cd75bea97910153892e12ed398` |
| `feriados_locais-v1.1` | `R/posthoc_af.R` | `a90096b74237afee576532460def71937083e1d6363e6d1ef8f1e204b1f0af73` |
| `feriados_locais-v1.1` | `R/segunda_etapa.R` | `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7` |
| `feriados_locais-v1.1` | `R/sens_agudos.R` | `22baa6ea8e952654a5aca25220d1b3b18130ec36862e12d0a6701b184e201dbc` |
| `feriados_locais-v1.1` | `dados_referencia/README.md` | `d0efb9009966ab5f27e96642411cf897bcda37cdbdca1dfb805da34cfc76528d` |
| `feriados_locais-v1.1` | `dados_referencia/feriados_locais_nucleo_2011_2024.csv` | `4a3d4f15bc51125c892cfb2acf55d542d7146b02161c1a7a2b151f64183a5fca` |
| `offset-v1.1` | `R/ajusta_dlnm.R` | `2acf21797f576a5a5c34a4cdab081a8bec2d09473d9993759e4d3409935eb68b` |
| `offset-v1.1` | `R/diagnostico_grade_mrt.R` | `b263bdf6453a950a4fc544860baf3b989f190e432740a1c89065b15e7b2f9731` |
| `offset-v1.1` | `R/offset.R` | `b2aac93b4681c26d74427172bcdd3adb62fbf8cd75bea97910153892e12ed398` |
| `offset-v1.1` | `R/posthoc_af.R` | `a90096b74237afee576532460def71937083e1d6363e6d1ef8f1e204b1f0af73` |
| `offset-v1.1` | `R/segunda_etapa.R` | `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7` |
| `offset-v1.1` | `R/sens_agudos.R` | `22baa6ea8e952654a5aca25220d1b3b18130ec36862e12d0a6701b184e201dbc` |
| `posthoc_af-v1.0` | `R/ajusta_dlnm.R` | `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009` |
| `posthoc_af-v1.0` | `R/offset.R` | `55111b2cc510d7b1c7b78b7f84e99997c5202825e0353da70bab0b4bea290bae` |
| `posthoc_af-v1.0` | `R/posthoc_af.R` | `a90096b74237afee576532460def71937083e1d6363e6d1ef8f1e204b1f0af73` |
| `posthoc_af-v1.0` | `R/segunda_etapa.R` | `1fb4543a3d4f0fd31bbf35571944c37756c33b1a1d11f876d48bd9bdd3aa9abb` |
| `segunda_etapa-v1.0` | `R/ajusta_dlnm.R` | `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009` |
| `segunda_etapa-v1.0` | `R/offset.R` | `55111b2cc510d7b1c7b78b7f84e99997c5202825e0353da70bab0b4bea290bae` |
| `segunda_etapa-v1.0` | `R/segunda_etapa.R` | `1fb4543a3d4f0fd31bbf35571944c37756c33b1a1d11f876d48bd9bdd3aa9abb` |
| `segunda_etapa-v1.1` | `R/ajusta_dlnm.R` | `2acf21797f576a5a5c34a4cdab081a8bec2d09473d9993759e4d3409935eb68b` |
| `segunda_etapa-v1.1` | `R/diagnostico_grade_mrt.R` | `b263bdf6453a950a4fc544860baf3b989f190e432740a1c89065b15e7b2f9731` |
| `segunda_etapa-v1.1` | `R/offset.R` | `b2aac93b4681c26d74427172bcdd3adb62fbf8cd75bea97910153892e12ed398` |
| `segunda_etapa-v1.1` | `R/posthoc_af.R` | `a90096b74237afee576532460def71937083e1d6363e6d1ef8f1e204b1f0af73` |
| `segunda_etapa-v1.1` | `R/segunda_etapa.R` | `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7` |
| `segunda_etapa-v1.1` | `R/sens_agudos.R` | `22baa6ea8e952654a5aca25220d1b3b18130ec36862e12d0a6701b184e201dbc` |
| `sens_agudos-v1.0` | `R/ajusta_dlnm.R` | `2acf21797f576a5a5c34a4cdab081a8bec2d09473d9993759e4d3409935eb68b` |
| `sens_agudos-v1.0` | `R/diagnostico_grade_mrt.R` | `b263bdf6453a950a4fc544860baf3b989f190e432740a1c89065b15e7b2f9731` |
| `sens_agudos-v1.0` | `R/offset.R` | `b2aac93b4681c26d74427172bcdd3adb62fbf8cd75bea97910153892e12ed398` |
| `sens_agudos-v1.0` | `R/posthoc_af.R` | `a90096b74237afee576532460def71937083e1d6363e6d1ef8f1e204b1f0af73` |
| `sens_agudos-v1.0` | `R/segunda_etapa.R` | `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7` |
| `sens_agudos-v1.0` | `R/sens_agudos.R` | `22baa6ea8e952654a5aca25220d1b3b18130ec36862e12d0a6701b184e201dbc` |
| `untagged-1` | `R/diagnostico_grade_mrt.R` | `ad17f502d2aeb6499fef70b8779e207a36d102ad0d8b4f0fb1d537c1bf723bd4` |
| `untagged-1` | `tests/testa_diagnostico_grade_mrt.R` | `514cb77ab2d9d31d55f104c365ae8d57b5d5722dd208215034d8c95eabe02b1e` |
