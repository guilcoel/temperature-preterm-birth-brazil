# Fase 4: correções v3 (Methods e Results) e marco M4 (manuscrito completo)

- **Gerado por:** `00_scripts/90_manuscrito_m4_fase4.R` (SHA-256 `c8790c440b01789f503d2a1a8bb582d71bb732cafd0d015508f65fccf5a5ae79`), início em 2026-10-20 10:38:50 -0300, fim em 2026-10-20 10:38:50 -0300. Rodada `20261019`. `versao()`: 4443971b.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `a3d3e1919311817d20c92de2798e01e30c5465db` (ramo `main`); último commit da `COORD` no `HEAD`: `b03d6c7 COORD: COORD-16 (push de 000aad4..6523bc0 ao a1-fase4 e tag feriados_locais-v1.1 no bc586c0)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: vazio.
- **Entradas (SHA-256 = registrados):**
  - `01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds`: `5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d`;
  - `01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds`: `52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e`;
  - `01_saidas/fase3/fracao_atribuivel_fase3_20261013.csv`: `9437e9668c729ffd502a159038d2d557b4d8767d1a046cb86eef13ddb2659a48`;
  - `01_saidas/fase3/posthoc_af_fase3_20261013.rds`: `223e09366a445b99bd947d3f59f66fa20d755b019af149bfeb4bac026593d11d`;
  - `01_saidas/fase4/serie_ptb_fase4.rds`: `e70190c1bf7c0fa5ba9c9f1e3cacb46f1ef8d647fc04a8606d181f7c819793e0`;
  - `01_saidas/fase4/criterio_c1_fase4_20261019.csv`: `886ca12c00ba43318e48ce784b8dac2e923d5cc4905013a82077b25882488168`;
  - `01_saidas/fase4/tabela_sensibilidades_fase4_v2.csv`: `838752c256b90751b0e7e79f23e6a3b3aa495f943f63094d2d4874d7cf165288`;
  - `01_saidas/fase4/tmr_p10p90_fase4_20261019.csv`: `9519e756ea0aba2b83991de9012534429608714e9e4d3dd5a97857abd864a102`;
  - `01_saidas/fase4/contrastes_estacao_quente_fase4.csv`: `47a688e9235eee5c865eb13936e78209caa1e07fb403018420acd93501180d6a`;
  - `01_saidas/fase4/ic_tmr_uma_etapa_16coef_fase4.rds`: `779efd8535a7f6f79858318c0b5da3cdeb3316e3bdd0c5a894391ca6f24b232c`;
  - `01_saidas/fase4/pacf_d3_fase4_20261019.csv`: `a2f0daa2da1ae60ecfe5fcc5822b964a0e432b1c920798e919b4d4ef58f99159`;
  - `01_saidas/fase3/contribuicoes_negativas_fase3_20261013.csv`: `4641b22af30316679f035977668651f49e60e874a68747f7e89cd1ba21a2a1d1`;
  - `01_saidas/fase3/posthoc_item2_fase3_20261013.csv`: `1da3e93205b0a5dd9e16bee068f9a66b69ebe953291e01fa81ba3d6038817511`;
  - `01_saidas/fase4/c3_fase4_20261019.rds`: `8b0ac9be1784d32b8ca8f767fcb09f7896378ae98948f663fbeafde1fc0457c2`;
- **Spec das frases prescritas (SHA-256 conferido no `spec/SHA256SUMS` ou no índice):**
  - `spec/decisoes_metodo_20261008.md`: `62afa891f123da1e84bc71def238ccbb321681b83872eb2c267eac0e37cf030f`;
  - `spec/decisoes_metodo_20261013_D5_interpretacao_AF.md`: `24f131e8b3cb45f05efcaa8b59ba97bbaaec5f50f106939a16836b3fd66f668a`;
  - `spec/decisoes_metodo_20261014_errata_D5.md`: `9c9fb65d6963ba674a7ff0d75419d5713fdfed94724ff0f6bd9a00c69653814b`;
  - `spec/decisoes_metodo_20261015_TODOS_D10_concordancia_coordenacao_git.md`: `d1863f5fe3d97478278051cd2d62bf9ff4d98ccf4da5a3366f94a8900326eb9f`;
  - `spec/decisoes_metodo_20261013_complemento.md`: `189d9b2db6462d56cc2a7d2c35e75e3a4532a1c666c03632063fb408d5ff0936`;

## Contagem de palavras (sem títulos de seção e sem as chaves de citação)

| Seção | Palavras | Meta |
|---|---|---|
| Abstract | 400 | 250–500 (300–400) |
| Introduction | 363 | ~400 |
| Methods | 1184 | ~1.150 |
| Results | 514 | ~550 |
| Methods + Results | 1698 | ≤ 1.700 |
| Comment | 926 | 900–1.100 |
| Texto principal (Introduction a Comment) | 2987 | ≤ 3.000 |

- **Front matter:** título com 12 palavras; condensation com 20 palavras e 133 caracteres; short title com 71 caracteres; AJOG at a Glance com 129 palavras (com os títulos A, B e C); 7 keywords em ordem alfabética, sem palavra do título; highlights com 76, 58, 61, 69 caracteres.
- **Regras conferidas por código (todas verdadeiras):** titulo_palavras, titulo_sem_abrev, condensation, short_title, glance, keywords, abstract_palavras, abstract_sem_abrev, main_text, methods_results, introduction, comment_palavras, comment_secoes, highlights. **Proibidos ausentes:** "first"/"novel"/"unprecedented" como novidade, "preregistered", "registered protocol", "mothers" e nomes, instituição, GitHub e caminhos (duplo-cego) no manuscrito, no suplemento, nas legendas e nos highlights. Nenhuma afirmação de novidade, então não há busca a documentar.
- **Frases prescritas e onde ficaram (regra do chat, correção 5):**
  - texto principal: ética (decisões de 08/10, §2, literal); D1 (fração atribuível, literal do 88 v2, com "on the same day and the following 7 days" no lugar de "over the following 0–7 days", Menor do chat); frase do viés da AF (errata da D5, item 4, seguida do resto do item 2 da D5, l. 64, literal); D10, 1g (literal); frase da D8, 1.1 e 1.2 (Ψ singular, redação da sessão, correção 3); errata da D5 na Comment (Strengths and Limitations), literal, com "none of the pooled cumulative relative risks of the primary analysis excluded the null" (correção 4) e [k] = "no replicate failed";
  - Supplementary Methods, inteiras, com remissão no texto: D8 errata adaptada (literal do 88 v2); sementes do Monte Carlo (complemento de 13/10, literal); parágrafo post hoc da D5 (l. 123, literal); §8 com o complemento (literal do 88 v2, sem a frase da base e do repositório, trocada pela de disponibilidade do chat no texto principal); D1, item 5; D10, 1b; E9; D12, 4.1 (as 8 concentrações e as duas declarações); D16 (`z_fetal`; gl do ns(tempo)); D15; D11, 5.2 e 5.3; D17; §2.3; PACF da D3; ponte da D1; contribuições negativas; distribuições do P2 (também na Tabela S4).
  - Todas as frases lidas da spec são conferidas por `identical`/`grepl(fixed = TRUE)` contra o texto gravado; os números embutidos na errata da D5 são conferidos contra as saídas.
- **Disponibilidade (correção 2):** a frase do chat, com "from [ref]" resolvido como "from its public repository" com a citação do BR-DWGD (Xavier 2022), porque uma referência sobrescrita depois de "from" não se lê; [repository] fica como placeholder (decisão de Guilherme).
- **IC da TMR da uma etapa (correção 7):** 16 coeficientes (letra da D11, 5.3), IC 22.9–29.5 °C. **Justificativa corrigida:** a redução é linear, então sortear os 16 coeficientes da cross-basis ou os 4 reduzidos dá a mesma distribuição teórica; a diferença entre os IC de 16 e de 4 coeficientes (22.8–27.9 °C) é ruído de Monte Carlo (o auditor do chat mostrou com 200 mil sorteios). **Fração de sorteios na borda:** uma etapa, 0.026 no x99 e 0.008 no x1; MRT combinada do primário, 0.309 no x99 e 0.035 no x1. O limite superior da uma etapa depende de a fração no x99 passar de 2,5% (0.026): sensível ao Monte Carlo, declarado no Supplementary Methods.
- **RR contra a mediana do lado sem borda (Menor de logs):** C3-CB1 x99: 0.997; 95% CI, 0.969–1.026; C3-CB1 x1: 0.996; 95% CI, 0.979–1.015; C3-CB4 x99: 0.991; 95% CI, 0.958–1.025; C3-CB4 x1: 1.009; 95% CI, 0.988–1.032; C3-T5 x99: 0.983; 95% CI, 0.948–1.020; C3-T5 x1: 1.013; 95% CI, 0.987–1.040; C3-O2 x99: 0.984; 95% CI, 0.902–1.073; C3-O2 x1: 1.089; 95% CI, 1.007–1.177; C3-O5 x99: 0.966; 95% CI, 0.918–1.016; C3-O5 x1: 1.010; 95% CI, 0.977–1.044; C3-O9 x99: 1.003; 95% CI, 0.979–1.029; C3-O9 x1: 0.997; 95% CI, 0.975–1.019; C3-O10 x99: 1.006; 95% CI, 0.981–1.031; C3-O10 x1: 0.994; 95% CI, 0.972–1.017.
- **Ψ:** autovalores 2.657e-02, 5.493e-04, 7.717e-11, 8.284e-17; posto efetivo 2.
- **Chaves de citação usadas (44):** Armstrong2014, AtlasDH, Bekkar2020, Benchimol2015, Bhaskaran2013, BRDWGD, Buckley2014, CAMS_EAC4, Chersich2020, Couto2026, Darrow2009, Darrow2024, Fitch2025, Gasparrini2010, Gasparrini2011, Gasparrini2012, Gasparrini2013, Gasparrini2015, Gasparrini2017, Gasparrini2022, GasparriniLeone2014, Girgin2026, gnm, Huang2023, IBGE2016, Iniguez2026, Inness2019, Leal2016, Libonati2022, Ohuma2023, RCore, RibeiroSilva2025, Rocha2026, Samuels2022, Sera2019, SIM, SINASC, Strand2011, Tobias2017, VicedoCabrera2014, vonElm2007, Wang2026, Wood2011, Xavier2022. O script 91 resolve só as verificadas em `manuscrito/referencias_m4.csv`; as outras viram [ref] e são listadas no log do 91.
- **Placeholders:** [repository], o DOI XXXXXXXXXXXXX (A1-113), a declaração de conflito de interesses cega e os dados da página de título (autores, afiliações, financiamento, agradecimentos) ficam para Guilherme confirmar.
- **Declaração de IA:** modelo da Elsevier, citando Claude (Anthropic) para código e para redação e edição do texto (o chat pediu "código e edição de linguagem"; o texto foi redigido com o Claude, então a declaração diz isso; Guilherme decide).

## Saídas (fora do git)

- `manuscrito/m4/manuscrito_v6_20261019.md`: `ba80e07f21d0fed9baef1766ac7e013d384807d109d87e24bcbba89ade129592`;
- `manuscrito/m4/suplemento_v6_20261019.md`: `2500518978285b3619096f76587a2780c0f9903affc1ad13140871ddac9d0be0`;
- `manuscrito/m4/pagina_titulo_v6_20261019.md`: `c4a3dec95257875778b74be55af9145d4e04757efdbfd102aff4678ab9a67300`;
- `manuscrito/m4/highlights_v6_20261019.md`: `d5a7e2834ce6110fe58e508cbeebaf6ae760329af17f4ad0f1b122890bd60772`;
- `manuscrito/m4/legendas_v6_20261019.md`: `a2be9ef3c6ad218a1c622cdad19d3289508fb42129498d1497e86251fcd75ea1`;
- `manuscrito/m4/tabS5_decisoes_v6_20261019.csv`: `08f0e6690fc0692b2bfc178c084467869aa3d613f7b30e349d3213147f99e0e6`;

## Texto do manuscrito

# Short-term ambient temperature exposure and preterm birth in 26 Brazilian urban concentrations

## Condensation

In 13.5 million births in 26 Brazilian urban concentrations, short-term heat and cold showed no clear association with preterm birth.

## Short Title

Ambient temperature and preterm birth in Brazilian urban concentrations

## AJOG at a Glance

### A. Why was this study conducted?

- To estimate the short-term association between daily ambient temperature and preterm birth in large Brazilian cities, accounting for the pregnancies at risk.

### B. What are the key findings?

- Among 1,378,030 preterm births, the pooled cumulative relative risk vs the minimum-risk temperature was 1.003 (95% confidence interval, 0.978 to 1.029) at the 99th and 1.020 (0.990 to 1.051) at the 1st temperature percentile.
- A post hoc test did not reject a flat exposure–response curve (P = .76).

### C. What does this study add to what is already known?

- In large Brazilian cities, short-term heat and cold were not clearly associated with preterm birth; the data were compatible with cumulative relative risks of up to 1.029 at the 99th and 1.051 at the 1st percentile.

## Blinded Conflict of Interest Statement

The authors report no conflict of interest. [to be confirmed by the authors]

## Keywords

attributable fraction; cold; distributed lag nonlinear model; environmental epidemiology; heat; multivariate meta-analysis; time-series analysis

## Word count

Abstract: 400 words; Main text: 2,987 words

## Abstract

Background: High and low ambient temperatures have been associated with preterm birth, but estimates vary, and temporal studies can be biased by the seasonality of conceptions and by changes in the number of pregnancies at risk.

Objective: To estimate the short-term association between daily mean ambient temperature and preterm birth in the 26 large urban concentrations of Brazil.

Study Design: This two-stage time-series study included singleton live births at 22 to 42 weeks of gestation to residents of 26 urban concentrations, recorded in the national live birth information system from April 2012 to August 2024. In each concentration, daily counts of preterm births (22 to 36 weeks) were modeled with conditional quasi-Poisson regression, with ongoing pregnancies at 22 to 36 weeks as the offset, a delivery-risk weight, and a distributed lag nonlinear function of core-city daily mean temperature over 0 to 7 days. Concentration-specific estimates were pooled by multivariate meta-regression. The primary contrasts were the cumulative relative risks at the 99th and 1st temperature percentiles compared with the minimum-risk temperature. The analysis plan was version-controlled before any outcome analysis.

Results: Of 13,509,914 live births, 1,378,030 (10.2%) were preterm. The pooled exposure–response curve was close to flat, and the minimum-risk temperature was imprecisely estimated (28.2 °C; 95% confidence interval, 18.8 to 29.5 °C, the entire search range). The cumulative relative risk was 1.003 (95% confidence interval, 0.978 to 1.029) at the 99th percentile (29.5 °C) and 1.020 (0.990 to 1.051) at the 1st percentile (18.8 °C); none of the pooled cumulative relative risks of the primary analysis excluded 1, and a post hoc test did not reject a flat curve (P = .76). The 99th percentile contrast fell within the primary confidence interval in 6 of 6 key sensitivity analyses, and the 1st percentile contrast in 5 of 6. If the associations were causal, 25,362 of 1,378,030 preterm births (1.84%; empirical 95% confidence interval, 0.87% to 2.70%) would be attributable to nonoptimal temperatures, but this fraction did not exceed the 97.5th percentile of its distribution under no association (median, 1.67%; 97.5th percentile, 3.00%).

Conclusion: In 26 Brazilian urban concentrations, short-term exposure to heat and cold was not clearly associated with preterm birth; the data were compatible with cumulative relative risks of up to 1.029 at the 99th temperature percentile and up to 1.051 at the 1st percentile (upper 95% confidence limits), and a delayed association with cold could not be excluded.

## Introduction

Preterm birth affected an estimated 13.4 million live births worldwide in 2020, 9.9% of all births.[@Ohuma2023] In a national population-based study in Brazil, 11.5% of births were preterm.[@Leal2016]

In a systematic review and meta-analysis that included 70 studies, the odds of preterm birth increased by 5% per 1 °C of temperature and by 16% during heat waves,[@Chersich2020] and other systematic reviews have reported associations with heat.[@Bekkar2020; @Wang2026] Proposed mechanisms include dehydration, reduced placental blood flow, and an inflammatory response, although the evidence is limited.[@Samuels2022] A multicountry study attributed 1.4% of warm-season preterm births to heat across 250 locations in 13 countries.[@Iniguez2026] Two-stage designs with distributed lag nonlinear models, developed for temperature and mortality, allow nonlinear and delayed associations to be estimated and pooled across many locations.[@Gasparrini2010; @Gasparrini2015]

Temporal studies of preterm birth face specific threats to validity. Conceptions are seasonal, and the number and gestational-age composition of ongoing pregnancies change over time; analyses that ignore the population at risk, or whose study period truncates pregnancies at its start and end, can produce spurious seasonal patterns.[@Darrow2009; @Strand2011] In simulations, time-series analyses were unbiased when they accounted for the ongoing pregnancies at risk and their weighted probability of delivery,[@Huang2023] and, in another simulation, misspecified adjustment for seasonality introduced severe bias.[@Girgin2026] Large studies in the United States found increases of about 1% to 2% in preterm birth after heat waves.[@Darrow2024; @Fitch2025]

Brazil's large urban concentrations range from equatorial to subtropical climates. Brazilian evidence on climate and preterm birth includes a review reporting more preterm births during heat waves in record-breaking droughts in southeastern Brazil,[@Libonati2022] a nationwide cohort in which drought was associated with preterm birth,[@Rocha2026] a nationwide preprint that used daily live births as the offset and found U-shaped curves in cold and moderate regions and higher risk at lag 0 in warm regions,[@Couto2026] and an ongoing study of heat and birth outcomes.[@RibeiroSilva2025] The multicountry study analyzed the warm season only.[@Iniguez2026] We estimated the short-term association between daily mean temperature, over its whole range, and preterm birth in the 26 large urban concentrations of Brazil, using the national live birth registry, a design that accounts for the seasonality of conceptions and the pregnancies at risk, and a prespecified analysis plan.

## Methods

### Study design, setting, and population

We conducted a two-stage time-series analysis of daily counts of preterm births in the 26 large urban concentrations defined by the Brazilian Institute of Geography and Statistics, which comprise 277 municipalities.[@IBGE2016] The study population comprised singleton live births at 22 0/7 to 42 6/7 weeks of gestation to residents of these concentrations, recorded in the Brazilian Live Birth Information System (SINASC).[@SINASC] Births were restricted to a fixed cohort of pregnancies (estimated start dates from July 31, 2011, to March 5, 2024) to avoid fixed-cohort bias.[@Strand2011] The main analysis window ran from April 14, 2012, to August 6, 2024 (4,498 days). All 26 concentrations met the prespecified inclusion criteria (Supplementary Methods).

The analysis followed a prespecified analysis plan, version-controlled before any outcome analysis (commit [blinded for review], October 9, 2026; archived at [blinded for review]). Deviations were recorded, with their rationale, before the corresponding analyses were run (Supplementary Table S1; full log available with the analysis code). Reporting follows the STROBE and RECORD statements.[@vonElm2007; @Benchimol2015]

This study used publicly available, deidentified data from Brazil's national live birth (SINASC) and mortality (SIM) information systems. In accordance with Brazilian National Health Council Resolution No. 674/2022, article 26, items II and III, research using publicly accessible and public-domain information is exempt from review by the research ethics committee system. The requirement for informed consent was waived because only deidentified, publicly available secondary data were used. Individual-level records were analyzed only on a secure local workstation and were never displayed or shared; all reported outputs are aggregated, with counts below 10 suppressed, in compliance with Brazil's General Data Protection Law.

### Outcome and exposure

The outcome was preterm birth (22 to 36 completed weeks); extremely (22–27 weeks), very (28–31 weeks), and moderate-to-late (32–36 weeks) preterm births were secondary outcomes. Daily mean temperature (the average of the maximum and minimum) came from the Brazilian Daily Weather Gridded Data (BR-DWGD, version 3.2.4; 0.1° grid), area-weighted over each municipality.[@Xavier2022] The exposure was the daily mean temperature of the core city of each concentration, assigned to all its municipalities (Supplementary Methods).

### Statistical analysis

In the first stage, we fitted, for each concentration, a conditional quasi-Poisson regression with year-by-month strata, which control for seasonality and long-term trends.[@Armstrong2014; @Bhaskaran2013] The offset was the logarithm of the number of ongoing pregnancies at 22 to 36 weeks of gestation; the logarithm of a delivery-risk weight (the mean gestational-week-specific risk of delivery among ongoing pregnancies) entered with an estimated coefficient, to account for the seasonality of conceptions and the gestational-age composition of the population at risk.[@VicedoCabrera2014; @Huang2023] Day of the week, national holidays, carnival, and movable holidays were covariates. Temperature was modeled with a distributed lag nonlinear model:[@Gasparrini2010] a natural cubic spline with knots at the 10th, 75th, and 90th percentiles of daily temperature for the exposure–response function and a natural cubic spline with an intercept and two log-spaced knots over lags of 0 to 7 days for the lag–response function.

In the second stage, each model was reduced to the overall cumulative (lag 0–7) exposure–response curve,[@Gasparrini2013] and the four reduced coefficients were pooled with a multivariate random-effects meta-regression fitted by restricted maximum likelihood, with the mean and range (99th minus 1st percentile) of daily temperature as meta-predictors.[@Gasparrini2012; @Sera2019] Concentration-specific curves were obtained as best linear unbiased predictions (BLUPs). As in the Multi-Country Multi-City (MCC) Collaborative Research Network study,[@Gasparrini2015] the pooled curve was predicted at the mean of the meta-predictors on a common percentile scale (the average of the concentration-specific percentiles).

The minimum-risk temperature (MRT) was the minimum of the curve on a 0.1 °C grid between the 1st and 99th percentiles, with a 95% confidence interval (CI) from 1,000 parametric bootstrap samples;[@Tobias2017] concentration-specific MRTs were obtained in the same way from the BLUP curves. The primary contrast was the cumulative relative risk (RR) at the 99th percentile vs the MRT, with the 1st percentile as co-primary contrast; contrasts at the 95th, 90th, 10th, and 5th percentiles were secondary. Contrasts are reported in percentiles and in °C; boundary cases are described in the Supplementary Methods. The estimated between-concentration covariance matrix was singular (effective rank 2 of 4); concentration-specific MRTs at the boundary are therefore not independent evidence, and the Wald test of the pooled curve may be anticonservative.

Attributable numbers and fractions were computed with the forward perspective, which assigns to the exposure on each day the events occurring on the same day and the following 7 days, using the BLUP-reduced coefficients of each urban concentration, as in the MCC study.[@Gasparrini2015] The backward perspective, which requires the full first-stage cross-basis coefficients, was computed as a sensitivity analysis.[@GasparriniLeone2014] Empirical CIs used 1,000 Monte Carlo samples (Supplementary Methods). Components were heat and cold (above and below the MRT) and extreme heat and extreme cold (above the higher of the 97.5th percentile and the MRT, and below the 2.5th percentile); in the 10 concentrations whose MRT fell at the 99th percentile, heat and extreme heat coincide. Because the reference temperature was the minimum of each estimated exposure–response curve within the 1st–99th percentile range, daily contributions within that range are non-negative by construction, up to the 0.1 °C resolution of the MRT search grid (negative contributions within that range were negligible; Supplementary Methods), and the attributable fraction is expected to be positive (biased upward) even in the absence of an association; for the same reason, and to the same grid resolution, relative risks against the MRT are not lower than 1, and their confidence intervals, like the empirical confidence intervals of the attributable fraction, are conditional on the estimated MRT. The empirical confidence intervals also treated urban concentrations as independent, although BLUPs share the pooled mean, which narrows them. As post hoc analyses, we tested the pooled exposure–response curve against a flat curve and estimated the distribution of the attributable fraction under no association in any urban concentration (Supplementary Methods).

### Sensitivity analyses

Six prespecified key sensitivity analyses assessed robustness: municipal temperature in a municipal case time series,[@Gasparrini2022] lag 0–14, a natural spline of time instead of strata, adjustment for fine particulate matter (PM2.5, lag 0–1), a fixed coefficient of 1 for the delivery-risk weight, and spontaneous preterm birth. A result was considered robust if, in each key sensitivity analysis, the estimate had the same direction as the primary estimate and fell within its 95% confidence interval. Each sensitivity analysis re-estimated its own pooled minimum-risk temperature; because a contrast against the minimum of the same pooled curve cannot be lower than 1, the direction condition was always met, and the criterion reduced to inclusion in the primary confidence interval. The 99th and 1st percentile contrasts were assessed separately. A contrast was deemed not assessable when the pooled minimum-risk temperature of the sensitivity analysis fell at that percentile. These operational rules were defined after the primary results were known. Other prespecified and exploratory analyses are described in the Supplementary Methods and Supplementary Table S2.

### Software and data availability

Analyses were performed in R, version 4.5.1,[@RCore] with the dlnm, gnm, and mixmeta packages.[@Gasparrini2011; @gnm; @Sera2019] SINASC and SIM microdata are publicly available from DATASUS,[@SINASC; @SIM] and BR-DWGD, CAMS, and human development index data from their public repositories.[@BRDWGD; @CAMS_EAC4; @AtlasDH] Analysis code, the deviation log, and the analysis plan are available for review at [anonymous review link].

## Results

The analysis included 13,509,914 singleton live births and 1,378,030 preterm births (10.2%) in the 26 urban concentrations over 4,498 days (Table 1).

The pooled cumulative exposure–response curve was close to flat (Figure 1). The pooled MRT was 28.2 °C (93.8th percentile of the pooled axis; 95% CI, 18.8–29.5 °C, the entire search range). Compared with the MRT, the RR was 1.003 (95% CI, 0.978–1.029) at the 99th percentile (29.5 °C) and 1.020 (95% CI, 0.990–1.051) at the 1st percentile (18.8 °C) (Table 2). Secondary contrasts ranged from 1.000 to 1.013 (Supplementary Table S3), and none of the pooled cumulative relative risks of the primary analysis excluded the null.

Lag-specific estimates are descriptive, without adjustment for multiple comparisons (16 lag-specific estimates) (Figure 2). At the 1st percentile, the RR was below 1 at lag 0 (0.9781; 95% CI, 0.9638–0.9926) and above 1 at lags 6 (1.0093; 95% CI, 1.0031–1.0156) and 7 (1.0200; 95% CI, 1.0089–1.0313); at the 99th percentile, it was below 1 at lag 3 (0.9927; 95% CI, 0.9861–0.9994) and above 1 at lag 7 (1.0097; 95% CI, 1.0004–1.0192). The 95% CIs of the other 11 estimates included 1.

Residual heterogeneity was low (Cochran Q = 92.9, 92 df; P = .45; I² = 1.0%), and neither meta-predictor was associated with the curve (Wald P = .19 for the mean and P = .31 for the range). Concentration-specific MRTs ranged from 23.1 to 32.3 °C and fell at the 99th percentile in 10 of 26 concentrations (Figure 3, Supplementary Table S4); in these 10, the minimum searched between the 10th and 90th percentiles fell at a boundary in 7, and its 95% CI spanned the entire search range in 8.

If the associations were causal, 25,362 preterm births (empirical 95% CI, 12,026–37,232), or 1.84% (0.87%–2.70%), would be attributable to nonoptimal temperature (forward perspective; 0.23% to heat and 1.61% to cold; backward perspective in Table 2). In post hoc analyses, a Wald test did not reject a flat pooled curve (χ² = 1.86, 4 df; P = .76), and the observed attributable fraction did not exceed the 97.5th percentile of its distribution under no association in any urban concentration (median, 1.67%; 2.5th–97.5th percentiles, 0.83%–3.00%; Supplementary Table S5).

In the key sensitivity analyses (Table 3, Figure 4), the 99th percentile contrast fell within the primary 95% CI in 6 of 6 analyses and the 1st percentile contrast in 5 of 6; the exception was lag 0–14 (RR at the 1st percentile, 1.057; 95% CI, 1.019–1.098).

In the warm season (November–March), the RR at the 99th percentile of the warm-season axis was 1.011 (95% CI, 0.976–1.047), and no warm-season contrast excluded 1. For the preterm subtypes, no RR against the MRT excluded 1; for very preterm birth, whose pooled MRT fell at the 99th percentile, the RR at the 1st percentile against the median was 1.089 (95% CI, 1.007–1.177). Among the other 29 sensitivity analyses with an interior pooled MRT, the CI excluded 1 only at the 1st percentile with lag 0–21 (1.076; 95% CI, 1.025–1.130) and with minimum temperature as the exposure (1.036; 95% CI, 1.002–1.071).

## Comment

### Principal Findings

In this time-series study of 1,378,030 preterm births in 26 Brazilian urban concentrations, short-term exposure to heat and cold was not clearly associated with preterm birth. The pooled exposure–response curve was close to flat, the RRs at the 99th and 1st percentiles had 95% CIs that included 1, a post hoc test did not reject a flat curve, and the pooled MRT could not be located with precision. This null result was consistent across the key sensitivity analyses, except for a larger RR at the 1st percentile with a lag of 0 to 14 days.

### Results in the Context of What Is Known

Our estimates do not exclude associations of the size reported after heat waves in large US studies, about 1% to 2%:[@Darrow2024; @Fitch2025] the upper 95% confidence limits were 1.029 at the 99th percentile and 1.047 at the 99th percentile of the warm season. Meta-analyses, which combine heterogeneous designs and exposure definitions, have reported larger associations with heat,[@Chersich2020; @Wang2026] and a multicountry analysis attributed 1.4% of warm-season preterm births to heat.[@Iniguez2026] Differences in the exposure contrast and setting may contribute to these differences: the US studies compared heat-wave days, defined by local thresholds in the warm season, with other days, whereas we contrasted extreme percentiles of the whole-year distribution with an estimated MRT, in tropical and subtropical climates, with core-city temperature as the exposure. As in the US time-series study,[@Darrow2024] we accounted for the ongoing pregnancies at risk, here with their weighted probability of delivery.[@Huang2023] The larger RRs at the 1st percentile with lags of 0 to 14 and 0 to 21 days and with minimum temperature as the exposure, together with lag-specific RRs above 1 at lags 6 and 7, are compatible with a delayed association with cold, which was not a prespecified hypothesis.

### Clinical Implications

At the population level, these data do not provide evidence that short-term ambient temperature is an important trigger of preterm birth in large Brazilian cities and, on their own, do not justify temperature-based changes in obstetric care. Protection of pregnant individuals from extreme heat may still be warranted for other outcomes, such as stillbirth.[@Chersich2020]

### Research Implications

Studies of temperature and preterm birth should account for the pregnancies at risk and the seasonality of conceptions, report the full exposure–response curve with a test against a flat curve, and interpret attributable fractions against their distribution under no association, because fractions computed against an estimated minimum are biased upward. Prespecified analyses of delayed cold effects, heat waves, humidity, preterm birth by onset, and individual-level exposure could show whether small or subgroup-specific associations exist.

### Strengths and Limitations

Strengths include a national registry of 13.5 million births across equatorial to subtropical climates, a design that accounts for the pregnancies at risk and fixed-cohort bias, and a prespecified analysis plan with a closed list of sensitivity analyses.

The attributable fraction should not be read as evidence of an association. Its point estimate is biased upward when the reference is the estimated MRT, and its empirical confidence interval does not incorporate the uncertainty of the MRT or the dependence between BLUPs. In this study, none of the pooled cumulative relative risks of the primary analysis excluded the null, the pooled MRT was imprecisely estimated (its 95% CI spanned the entire search range), and the MRT fell at the 99th percentile in 10 of 26 urban concentrations. In post hoc analyses, a test of the pooled exposure–response curve did not reject a flat curve (Wald χ² = 1.86, 4 df; P = .76), and the observed attributable fraction (1.84%) did not exceed the 97.5th percentile of its distribution under no association in any urban concentration (median, 1.67%; 2.5th–97.5th percentiles, 0.83%–3.00%; no replicate failed).

The estimated between-concentration covariance matrix was singular (effective rank 2 of 4), so the BLUPs are constrained to a low-dimensional family of curves, concentration-specific MRTs at the boundary are not independent, and the Wald test may be anticonservative. The backward perspective uses first-stage coefficients without shrinkage, which are unstable in smaller concentrations (it is read for the total only), and produces negative daily contributions (Supplementary Methods). The pooled curve uses a common percentile scale, and in the equatorial concentrations (Manaus, Belém, and Fortaleza) the 1st percentile is not cold in absolute terms. Gestational age in SINASC differs from completed weeks by the last menstrual period in about 21% of records with that date (by 1 week), which may misclassify births near 37 weeks; the pattern suggests a calculation convention, which would be nondifferential with respect to daily temperature, but the mechanism is undetermined. Exposure was outdoor core-city (or municipal) temperature assigned by residence at birth, without individual, indoor, or mobility data; this misclassification would mainly reduce precision and tend to attenuate associations. With 47 sensitivity and exploratory analyses and 16 lag-specific estimates, the few CIs that excluded 1 should be read in light of multiple comparisons. The results apply to live births in large urban areas and may not apply to non-urban populations, and local holidays were available only for the core municipality. PM2.5 came from a coarse reanalysis, so the adjusted analysis is a robustness check, not a correction. The analysis adding fetal deaths to the pregnancies at risk nearly reproduces the primary analysis by construction, the human development index is an approximation from 2010, the penalized and one-stage models estimate different quantities, and the upper CI limit of the one-stage MRT is sensitive to Monte Carlo error (Supplementary Methods).

### Conclusions

In 26 Brazilian urban concentrations, short-term exposure to heat and cold was not clearly associated with preterm birth. Burdens attributed to temperature against the minimum of an estimated curve should be interpreted against their distribution under no association.

## Glossary

- Cross-basis: the two-dimensional set of basis functions that describes, at the same time, the shape of the exposure–response relationship and its distribution over lags in a distributed lag nonlinear model.
- Cumulative relative risk: the relative risk associated with a given temperature, compared with the reference temperature, accumulated over all lags considered (here, 0 to 7 days), that is, the product of the lag-specific relative risks.
- Distributed lag nonlinear model: a regression framework that models nonlinear exposure–response relationships and delayed effects jointly.
- Lag: the delay, in days, between the exposure and the outcome.
- Minimum-risk temperature: the temperature at which the estimated exposure–response curve reaches its minimum, used as the reference for relative risks and attributable fractions.

## Declaration of generative AI and AI-assisted technologies in the writing process

During the preparation of this work, the authors used Claude (Anthropic) to write and review analysis code and to draft and edit the text of the manuscript. After using this tool, the authors reviewed and edited the content as needed and take full responsibility for the content of the publication.


## Texto do suplemento

# Supplementary Material

## Supplementary Methods

Abbreviations: BLUP, best linear unbiased prediction; CI, confidence interval; MCC, Multi-Country Multi-City Collaborative Research Network; MRT, minimum-risk temperature; RR, relative risk; SINASC, Brazilian Live Birth Information System.

The analysis plan was version-controlled before any outcome analysis. Decisions taken after the analysis plan was version-controlled, with their labels and whether they used any result of this study, are listed in Supplementary Table S1.

### Study population and inclusion criteria

The 26 urban concentrations are the large urban concentrations defined by the Brazilian Institute of Geography and Statistics (2nd edition, based on the 2010 Census).[@IBGE2016] The core city of each concentration was its most populous municipality in the 2022 Census (in the Vitória concentration, Serra). The main analysis window (April 14, 2012, to August 6, 2024) is the period in which every gestational week from 22 to 36 had a complete set of ongoing pregnancies in the fixed cohort; the first 7 days before the window served as lag warm-up and were not part of the fitted data.
Concentrations were included if they had complete exposure data, valid gestational age and birth weight in at least 90% of live births, at least 1,000 events, and model convergence; a prespecified fallback specification for nonconvergence was defined. All 26 concentrations met the criteria in the primary analysis, and the fallback was not needed. Strata without events were removed from the fitted data, dispersion was estimated by the Pearson statistic, and the movable holidays were Ash Wednesday, Good Friday, and Corpus Christi.
Dispersion ranged from 0.98 to 1.12 across concentrations, and the estimated coefficient of the logarithm of the delivery-risk weight ranged from 0.50 to 1.65; this coefficient is reported as a diagnostic only. Delivery-risk weights computed per person-day would differ from the primary weights by a factor of 1.00017 (week 22) to 1.0187 (week 36); with an estimated coefficient, this difference is absorbed. The early-term comparison used person-day weights.

### Outcome definitions

Preterm subtypes used an offset restricted to the gestational weeks of the subtype, with the delivery-risk weights of the primary analysis; a concentration with fewer than 1,000 events of a subtype was excluded from the meta-analysis of that subtype. For extremely preterm birth, 18 concentrations were included; the 8 excluded were Maceió/AL, Florianópolis/SC, João Pessoa/PB, Teresina/PI, Aracaju/SE, Cuiabá/MT, Sorocaba/SP, and Campo Grande/MS. With fewer concentrations, the extremely preterm curve may cover a different set of climates, and the meta-predictors, although the same, are evaluated at the mean of the included concentrations.
Spontaneous preterm birth was defined from the SINASC fields on labor induction, mode of delivery, and the timing of cesarean delivery: preterm birth without induction of labor and with either vaginal delivery or cesarean delivery after the onset of labor. In version (i), a key sensitivity analysis, births with unknown onset were excluded from the numerator; in version (ii), they were counted as spontaneous.
One outcome sensitivity analysis was restricted to births with gestational age dated by the last menstrual period, with the outcome defined from the SINASC gestational-age field (version i) and from the last menstrual period (version ii), each with its own fixed cohort, offset, and delivery-risk weights. This subpopulation has a higher prevalence of preterm birth and unequal coverage across concentrations and years. Its concordance criterion (a difference of at most 1 week between the two gestational-age measures) excluded almost no births; the actual restriction is having a recorded last menstrual period.
In one sensitivity analysis, fetal deaths from the Mortality Information System (SIM)[@SIM] were added to the number of ongoing pregnancies. By construction, this analysis nearly reproduces the primary analysis: adding fetal deaths changes the logarithm of the offset by about 0.005, with very small within-month variation.

### Codes, algorithms, and data cleaning

Live births were selected from the SINASC files by single pregnancy (GRAVIDEZ = 1), municipality of residence (CODMUNRES) among the 277 municipalities of the urban concentrations, date of birth (DTNASC), and gestational age in completed weeks (SEMAGESTAC, 22 to 42; values outside 22 to 44 were set to missing). The pregnancy start date was DTNASC minus (7 × SEMAGESTAC + 3) days, and the fixed cohort comprised start dates from July 31, 2011, to March 5, 2024. Preterm birth was SEMAGESTAC 22 to 36 (subtypes 22–27, 28–31, and 32–36). Birth weight (PESO) was valid from 200 to 7,000 g. Spontaneous preterm birth was STTRABPART = 2 (labor not induced) with PARTO = 1 (vaginal delivery) or with PARTO = 2 (cesarean delivery) and STCESPARTO = 2 (cesarean delivery after the onset of labor). Gestational age by the last menstrual period was the number of completed weeks between DTULTMENST and DTNASC. The 2011 arm used the categorical field GESTACAO (codes 2 to 6 for 22 to 42 weeks and 2 to 4 for 22 to 36 weeks).
Fetal deaths for the sensitivity analysis were selected from the SIM fetal-death files (TIPOBITO = 1) by single pregnancy, municipality of residence (CODMUNRES), and SEMAGESTAC from 22 to 42 weeks. SINASC and SIM were not linked at the individual level; each was aggregated separately into daily counts by municipality of residence. The complete public national files for 2011 to 2024 were downloaded from DATASUS, and all records were available to the investigators.

### Exposure, air pollution, and local holidays

Fine particulate matter (PM2.5) came from the Copernicus Atmosphere Monitoring Service global reanalysis (EAC4),[@Inness2019; @CAMS_EAC4] as the daily mean of the core city on the approximate local day (UTC−3), entered linearly as the lag 0–1 moving average. Its role as a confounder of temperature effects is debated,[@Buckley2014] and adjustment may remove part of the effect if temperature influences PM2.5. The 0.75° grid (about 80 km) has not been validated against monitoring stations in all concentrations, and a small proportion of values are exact zeros of unverified origin; a time-constant bias does not affect a within-series adjustment, but a time-varying bias does. The adjusted result is read as a robustness check, not as a correction.
Local holidays were compiled from the municipal, state, and district legislation applicable to the core municipality of each concentration only; pregnant individuals residing in other municipalities of a concentration may have had a different calendar.

### Second stage and boundary contrasts

Pooled lag–response curves at the 99th and 1st percentiles against the pooled MRT were obtained from a second multivariate meta-analysis of the corresponding lag-specific coefficients. Cochran Q, I², and Wald tests for the meta-predictors were computed from the meta-regression. When a concentration-specific MRT fell at the 99th percentile, the contrast at that percentile equals 1 by construction (conditional on the estimated MRT, whose bootstrap confidence interval is reported) and is shown without a confidence interval. As prespecified sensitivity analyses, relative risks against the median are also reported, together with the minimum searched between the 10th and 90th percentiles (with its bootstrap confidence interval); the handling of degenerate contrasts and of searches that again fell at a boundary (reported with a flag, without further search) was defined post hoc.
The estimated between-concentration covariance matrix had eigenvalues 2.7 × 10⁻², 5.5 × 10⁻⁴, 7.7 × 10⁻¹¹, and 8.3 × 10⁻¹⁷; its effective rank was 2 of 4. The BLUPs are therefore constrained to a family of curves with few free parameters, concentration-specific MRTs at the boundary are not independent, and the Wald test of the pooled curve may be anticonservative.

### Attributable fraction

Monte Carlo samples for the empirical confidence intervals were drawn with a concentration-specific seed, so that samples were independent across urban concentrations and shared across the total and the heat, cold, extreme-heat, and extreme-cold components within each concentration. Because the forward perspective averages the events of the following 7 days, the last 7 days of the analysis window were excluded from the forward computation, which was rescaled to the observed total; the backward perspective does not lose these days.
Negative daily contributions. In the primary analysis (forward perspective, BLUP-reduced coefficients), negative daily contributions within the 1st–99th percentile range summed to −0.034 events across the 26 urban concentrations (1,378,030 preterm births), consistent with the 0.1 °C resolution of the MRT search grid; the smallest difference between the curve on observed days within that range and the grid minimum was −4.151 × 10⁻⁵ on the log scale. Negative contributions outside that range summed to −38.7 events, all in the 10 concentrations whose MRT was at the 99th percentile.
Bridge analysis. To separate the effect of shrinkage from that of the perspective, the forward attributable fraction was also computed with first-stage coefficients: 2.87% (empirical 95% CI, 1.48%–3.98%), compared with 1.84% with BLUP-reduced coefficients (forward) and 2.89% with the backward perspective. The first stage has no shrinkage, the backward perspective produces negative daily contributions, and the empirical CIs treat concentrations as independent.

### Post hoc analyses

Post hoc analyses (not prespecified). First, we tested whether the pooled cumulative exposure–response curve, predicted at the mean of the meta-predictors, was flat, with a Wald test of its four coefficients (χ², 4 df); this test does not depend on the estimated MRT. Second, to describe the attributable fraction produced by the analytic pipeline when no urban concentration has any association, we drew first-stage reduced coefficients from multivariate normal distributions with mean zero and the estimated first-stage covariance matrices, and repeated the second-stage meta-analysis, the MRT search, and the forward attributable-fraction computation (1,000 replicates; failed replicates were counted and reported). We report the median and 2.5th–97.5th percentiles of this distribution. Because this reference assumes no association in any concentration, an observed attributable fraction above it indicates concentration-specific associations or heterogeneity, not a pooled association.
The distributions under no association are shown in Supplementary Table S5. The observed heat and cold attributable fractions were 0.23% and 1.61% (medians under no association, 0.73% and 0.79%); the observed RRs at the 99th and 1st percentiles were 1.003 and 1.020 (medians, 1.008 and 1.008); and the MRT fell at the 99th percentile in 10 concentrations (median, 6) and at the 1st percentile in 0 (median, 6).

### Other sensitivity analyses

The remaining prespecified sensitivity analyses (closed list) addressed residual autocorrelation, the exposure metric, the cross-basis (including a penalized distributed lag model), time trend and calendar (including local holidays), the risk set and offset, the outcome definition, and the pooling model (fixed-effects, multilevel, and one-stage models); exploratory meta-regressions added one concentration characteristic at a time (macroregion, cesarean delivery, prenatal care, and the municipal human development index). All are listed in Supplementary Table S2.
Because the primary 95% CIs included 1 for both contrasts, the robustness criterion was of limited informativeness: it could detect a sensitivity estimate larger than the upper limit of the primary CI, but it could not distinguish robustness from a null result; evidence of an association was assessed with the post hoc test of the pooled curve.
The natural spline of time had 8 degrees of freedom per year of data (99 in total); the code of the MCC study assigns degrees of freedom per calendar year, which would give full-year degrees of freedom to the two partial years (2012 and 2024).
Residual autocorrelation. In the partial autocorrelation function of the deviance residuals of the primary models (lags 1–7), at least one lag fell outside ±2/√n in 25 of 26 concentrations and outside the 2.5th–97.5th percentiles of a simulated null distribution that accounts for the projection of the residuals on the fitted model (weighted least squares) in 13 of 26; this description was not used for any decision. With lagged deviance residuals (lags 1–7) added to the models, the RR was 1.002 (95% CI, 0.980–1.026) at the 99th percentile and 1.021 (95% CI, 0.990–1.053) at the 1st percentile.
One-stage model. The one-stage model stacks the 26 series in a single conditional quasi-Poisson model with a common cross-basis on the concentration-specific percentile scale (lags not crossing concentrations), one coefficient of the delivery-risk weight per concentration, and a common dispersion; its curve is an average curve, without meta-predictors and without between-concentration heterogeneity, and it is therefore not the same quantity as the pooled curve of the primary analysis. Its MRT was 27.3 °C (95% CI, 22.9–29.5 °C). The upper limit of this CI is sensitive to Monte Carlo error: 2.6% of the 1,000 bootstrap samples fell at the 99th percentile (0.8% at the 1st), just above the 2.5% that defines the limit, whereas 30.9% did so for the pooled MRT of the primary analysis (3.5% at the 1st percentile). Drawing the 16 cross-basis coefficients or the 4 reduced coefficients gives the same theoretical distribution, because the reduction is linear; the two intervals differ only by Monte Carlo error.
Penalized model. The penalized distributed lag model (cubic P-splines in both dimensions with second-order difference penalties, fitted by extended quasi-likelihood with restricted maximum likelihood) has no pooled curve or MRT of its own: concentration-specific log RRs at the 99th and 1st percentiles were contrasted against the temperature corresponding to the percentile of the pooled MRT of the primary analysis and pooled by univariate meta-regression. It therefore estimates a different quantity from the primary analysis, can fall below 1, and was not a key sensitivity analysis.[@Gasparrini2017; @Wood2011]
Exploratory meta-regressions added one characteristic at a time to the mean and range of temperature; no exploratory meta-predictor was associated with the curve (P = .29 to .89). The municipal human development index was the population-weighted mean of the 2010 municipal values;[@AtlasDH] because the index is a geometric mean of three indexes, this average is an approximation, and it predates the study period.

### Software

Analyses were performed in R version 4.5.1 using the packages dlnm (v2.4.10), gnm (v1.1-5), and mixmeta (v1.2.0), with mgcv (v1.9-3) for the penalized model; attributable risk was computed with the attrdl function,[@GasparriniLeone2014] which uses tsModel (v0.6-2), and MASS (v7.3-65) was used in the post hoc simulations; package versions were locked with renv (v1.2.4), and all stochastic procedures used fixed seeds (20261001 for pooled quantities and 20261001 + i for the i-th urban concentration). The gnm package was used for the conditional models.[@gnm]


## Legendas

# Figure legends

Figure 1. Pooled cumulative (lag 0–7) exposure–response curve between daily mean temperature and preterm birth in 26 Brazilian urban concentrations, 2012–2024. The curve was predicted at the mean of the meta-predictors on the pooled percentile axis (1st to 99th percentiles); the shaded band is the 95% confidence interval, and the dashed line marks the pooled minimum-risk temperature. MRT, minimum-risk temperature.

Figure 2. Pooled lag–response curves at the 99th (left) and 1st (right) percentiles of the pooled temperature axis against the pooled minimum-risk temperature, with 95% confidence intervals. MRT, minimum-risk temperature.

Figure 3. Concentration-specific cumulative (lag 0–7) exposure–response curves (best linear unbiased predictions), each on the 1st–99th percentile range of its own temperature distribution, against the concentration-specific minimum-risk temperature (dashed line and dot); shaded bands are 95% confidence intervals, truncated at 0.75 and 1.35 on the vertical axis. BLUP, best linear unbiased prediction; MRT, minimum-risk temperature.

Figure 4. Relative risks at the 99th (heat) and 1st (cold) percentiles against the pooled minimum-risk temperature in the primary analysis and in the sensitivity analyses. The filled circle is the primary analysis; open diamonds mark analyses in which the pooled minimum-risk temperature fell at the grid boundary on that side (contrast fixed at 1); the dotted line marks the primary estimate. Exposure-metric and warm-season analyses are on their own temperature axes; the penalized model is contrasted with a concentration-specific reference. CI, confidence interval; df, degrees of freedom; DLNM, distributed lag nonlinear model; GA, gestational age; LMP, last menstrual period; MRT, minimum-risk temperature; ns, natural spline; PM2.5, fine particulate matter; SINASC, Brazilian Live Birth Information System; γ, coefficient of the logarithm of the delivery-risk weight; (i) and (ii), versions of the outcome definition (Supplementary Methods).


## Página de título

# Short-term ambient temperature exposure and preterm birth in 26 Brazilian urban concentrations

## Short Title

Ambient temperature and preterm birth in Brazilian urban concentrations

## Authors

[Author names, degrees, and affiliations: to be confirmed by the authors]

## Corresponding author

[Name and address: to be confirmed by the authors]. E-mail: guilcoel@unicamp.br

## Conflicts of Interest

[To be confirmed by the authors]

## Source of Funding

[To be confirmed by the authors]

## Acknowledgments

[To be confirmed by the authors]

## Information blinded in the manuscript

Prespecified analysis plan: commit 86069e5 (October 9, 2026); archived at XXXXXXXXXXXXX. Analysis code, deviation log, and aggregated results: [repository]. Anonymous link for reviewers, cited in the blinded manuscript: [anonymous review link].

## Word count

Abstract: 400 words; Main text: 2,987 words


## Highlights

# Highlights

- Daily temperature and preterm birth were studied in 26 Brazilian urban areas
- No clear short-term association was found for heat or cold
- A post hoc test did not reject a flat exposure-response curve
- Attributable fractions against an estimated minimum are biased upward


- **Resultado:** ok.

