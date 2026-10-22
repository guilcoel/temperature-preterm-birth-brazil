# Prespecified analysis plan, analysis code and aggregated results for short-term ambient temperature and preterm birth in 26 Brazilian urban concentrations, 2012-2024

Reproduction package of the article *Short-term ambient temperature exposure and preterm birth in 26 Brazilian urban concentrations* (version `v5`, built on 20261022).

**Authors:** Guilherme Coelho (Universidade Estadual de Campinas (UNICAMP); ORCID [0000-0003-3045-4057](https://orcid.org/0000-0003-3045-4057)); Charles M'poca Charles (Universidade Estadual de Campinas (UNICAMP); ORCID [0000-0001-7133-0574](https://orcid.org/0000-0001-7133-0574)); Clarimar José Coelho (Pontifícia Universidade Católica de Goiás (PUC Goiás); ORCID [0000-0002-5163-2986](https://orcid.org/0000-0002-5163-2986)); Danielle Satie Kassada (Universidade Estadual de Campinas (UNICAMP); ORCID [0000-0002-6960-6444](https://orcid.org/0000-0002-6960-6444)); Rodolfo de Carvalho Pacagnella (Universidade Estadual de Campinas (UNICAMP); ORCID [0000-0002-5739-0009](https://orcid.org/0000-0002-5739-0009)).

**Dataset DOI:** https://doi.org/10.25824/redu/PWKND6 (Research Data Repository of the University of Campinas, REDU; the DOI resolves once the dataset is published).

**Code repository:** https://github.com/guilcoel/temperature-preterm-birth-brazil

**Funding:** Fundação de Amparo à Pesquisa do Estado de São Paulo (FAPESP), grant 2025/10862-7.

It contains **no individual-level data**.

## Contents

| Folder or file | Content |
|---|---|
| `plano/` | Prespecified analysis plan (specification v2.0.2, version-controlled and frozen on 2026-10-09 before any outcome analysis), the method decisions that apply to this article, their index, `SHA256SUMS`, and the freezing record |
| `base/` | Code that downloads the public data (SINASC, SIM, BR-DWGD, CAMS EAC4, IBGE) and builds the analysis database (Python; `pyproject.toml`, `uv.lock`), its tests, the access interface (`09_acesso/`), and documentation of each source (`*/FONTE.md`) |
| `codigo_compartilhado/` | R functions shared by the acute-outcome analyses (latest versions used by this article in `R/`; every version used, as snapshots of the version-control tags, in `versoes/`), their tests, and the public table of local holidays |
| `ferramentas/baixa_attrdl.R` | Downloads the third-party `attrdl.R`, which is not redistributed |
| `artigo1_prematuridade/00_scripts/` | All analysis scripts of this article, numbered in the order they were written; `MANIFEST.csv` gives the role of each file in the package |
| `artigo1_prematuridade/logs/` | Run, audit, and decision logs, including the deviation log (`desvios_especificacao.md`) |
| `artigo1_prematuridade/renv.lock` | R package versions (R 4.5.1) |
| `resultados/` | Aggregated results: Tables 1–3, Supplementary Tables S1–S6 (CSV), Figures 1–4 and Supplementary Figure S1 (PDF) |
| `RERUNNING.md` | How to rerun the analysis outside the original environment, with the pipeline order and, per script, the date variable, the shared-code versions, the checks to adapt, and the run logs |

Files by role: base code: 49; base documentation: 17; base interface: 1; check: 4; deviation log: 1; diagnostic (offset, descriptive): 1; environment: 7; local holiday table validation (v1.0; needs the authors' working folder): 1; local holiday table validation (v1.1; needs the authors' working folder): 1; package documentation: 6; phase 0 descriptive (before any outcome model): 13; phase report: 14; pipeline helper (sourced by 72, 74, 84): 1; pipeline: LMP and 2011 analyses inputs: 1; pipeline: MHDI extraction (Python): 1; pipeline: MRT grid diagnostic: 1; pipeline: Methods and Results text: 1; pipeline: attributable fraction: 1; pipeline: bootstrap CI of the 10th–90th percentile minimum: 1; pipeline: closed list of sensitivity analyses: 1; pipeline: counts and meta-predictor inputs: 1; pipeline: daily exposure percentiles (Phase 0, read by 20): 1; pipeline: daily series (Phase 1): 1; pipeline: exploratory MHDI meta-regression: 1; pipeline: exposure and offset series (Phase 4): 1; pipeline: exposure percentile grids (Phase 3): 1; pipeline: figures: 1; pipeline: first stage (Phase 2): 1; pipeline: key sensitivity analyses: 1; pipeline: local holiday sensitivity analysis: 1; pipeline: main deliverable (docx): 1; pipeline: meta-analysis by other models: 1; pipeline: municipal case time series data (key sensitivity 1): 1; pipeline: one-stage model: 1; pipeline: penalized DLNM: 1; pipeline: percentile grids (Phase 4): 1; pipeline: post hoc analyses: 1; pipeline: residual autocorrelation (lagged residuals): 1; pipeline: second stage (Phase 3): 1; pipeline: selection flowchart and missing data: 1; pipeline: sensitivity table: 1; pipeline: sensitivity table v2 and one-stage CI: 1; pipeline: spontaneous preterm birth series (key sensitivity 6): 1; pipeline: supplementary material (docx): 1; pipeline: tables: 1; pipeline: tests of the post hoc functions (its log is read by 50): 1; plan: 22; report to the methods chat: 6; result (aggregated): 14; run or audit log: 184; self-audit: 8; shared code: 1; shared code (latest version used): 6; shared code doc: 1; shared code snapshot at a tag: 55; shared code snapshot at an untagged commit: 2; shared code test: 17; shared reference data: 2; superseded draft: 3; test: 10; test diagnostic: 1; tool: downloads the third-party attrdl.R (not redistributed): 1.

## Data

All inputs are public. Individual-level records are not redistributed; they are downloaded from the original sources by `base/00_scripts/`:
- SINASC (live births) and SIM (fetal deaths), DATASUS: `01_download_sinasc.py`, `02_download_sim.py`;
- BR-DWGD (daily weather, version 3.2.4): `03_download_clima.py`;
- CAMS global reanalysis EAC4 (PM2.5): `03b_download_cams.py` (requires a free account on the Copernicus Atmosphere Data Store; see the script header);
- IBGE urban concentrations, municipalities, and population: `04_regioes_metropolitanas.py`, `05_shapefiles.py`;
- municipal human development index (Atlas of Human Development in Brazil): `artigo1_prematuridade/00_scripts/81_idhm_atlas_fase4.py`.

Processing: `06a_clima_municipal.py`, `06b_desfechos.py`, `06c_exposicao.py`, `06d_gestacoes_em_risco.py`, `06e_calendario.py`, `07a_referencias_pig.py`, and `08_manifesto.py`.
The analysis used database version `4443971b`, checked by the analysis scripts through `versao()`.

## Running

Pipeline order: `02_recontagens_fase0.R`, `20_monta_serie_principal.R`, `21_monta_serie_municipal.R`, `22_monta_ptb_espontaneo.R`, `32_primeira_etapa_principal.R`, `40_percentis_exposicao.R`, `45_segunda_etapa_principal.R`, `46_fracao_atribuivel.R`, `49_testes_posthoc_af.R`, `50_posthoc_af.R`, `53_diagnostico_grade_mrt.R`, `65_percentis_exposicao_fase4.R`, `66_series_exposicao_offset_fase4.R`, `67_ig_dum_e_2011_fase4.R`, `68_contagens_insumos_fase4.R`, `70_chaves_c1_fase4.R`, `72_d3_residuos_defasados_fase4.R`, `73_tmr_p10p90_fase4.R`, `74_c3_lista_fechada_fase4.R`, `77_c4_meta_fase4.R`, `78_c4_uma_etapa_fase4.R`, `79_c4_s3_fase4.R`, `81_idhm_atlas_fase4.py`, `82_c4_idhm_fase4.R`, `84_c3_feriados_locais_fase4.R`, `80_tabela_sensibilidades_fase4.R`, `85_m2_menores_tabela_v2_fase4.R`, `86_figuras_m3_fase4.R`, `87_tabelas_m3_fase4.R`, `90_manuscrito_m4_fase4.R`, `93_selecao_ausentes_m5b.R`, `94_entrega_metodos_resultados.py`, `95_suplemento_entrega.py`. `RERUNNING.md` explains the adaptations needed outside the original environment
(paths, database version, version-control checks, shared-code versions, run dates, input checksums, platform, third-party code), script by script.

## Map of results

| Result | Script |
|---|---|
| Tables 1–3, Supplementary Tables S2 and S4–S6 | `87_tabelas_m3_fase4.R` (inputs produced by the earlier pipeline scripts) |
| Supplementary Table S1 | `90_manuscrito_m4_fase4.R` |
| Supplementary Table S3 and Supplementary Figure S1 | `93_selecao_ausentes_m5b.R` |
| Figures 1–4 | `86_figuras_m3_fase4.R` |
| Methods and Results text, main document, supplementary material | `90_manuscrito_m4_fase4.R`, `94_entrega_metodos_resultados.py`, `95_suplemento_entrega.py` |

Supplementary tables follow the numbering of the article. The source CSV names in the logs are the working names (`tabS1`…`tabS6`, `tabS5_decisoes`); the map
from working names to article numbers is in `MANIFEST.csv`.

## Confidentiality

Only aggregated results are included: counts by urban concentration and year or coarser, with counts from 1 to 9 shown as "<10" and complementary suppression,
and model estimates. Daily series and individual-level records are not included.

## Not included

The two packaging scripts (`92_pacote_submissao_m5_fase4.py` and `96_pacote_reproducao.py`); copies of messages exchanged with the methods chat and the coordination
sessions, prompts, and other internal instructions (`mensagem_*`, `passagem_*`, `prompt_*`, `pedido_*`, `confirmacoes_chat_*`, `CLAUDE.md`); one audit log that names a third party;
intermediate outputs (`01_saidas/`); the third-party `attrdl.R` (see `ferramentas/baixa_attrdl.R`). Two documents of the database delivery cite a private report by link; that
report is not part of the package. `renv/activate.R` is part of renv (© Posit, MIT License). The `DESCRIPTION` of the shared code predates the license decision; the license
below applies.

**Verifying the frozen plan.** From `plano/`, `shasum -a 256 -c --ignore-missing spec/SHA256SUMS` checks the specification, the method decisions, and the phase 0 report against the checksums recorded when the plan was frozen on 2026-10-09; the four other entries refer to internal coordination files that are not part of this package.

## License

Code: MIT License (`LICENSE`). Documents, logs, results, and figures: Creative Commons Attribution 4.0 International (`LICENSE-docs.md`).

## Citation

Coelho, Guilherme; Charles, Charles M'poca; Coelho, Clarimar José; Kassada, Danielle Satie; Pacagnella, Rodolfo de Carvalho, 2026, "Prespecified analysis plan, analysis code and aggregated results for short-term ambient temperature and preterm birth in 26 Brazilian urban concentrations, 2012-2024", https://doi.org/10.25824/redu/PWKND6, Repositório de Dados de Pesquisa da Unicamp. The citation of the article will be added upon publication. Machine-readable metadata: `CITATION.cff`.
