# Fase 4, marco M3: tabelas do manuscrito

- **Gerado por:** `00_scripts/87_tabelas_m3_fase4.R` (SHA-256 `a0b0e3932b2f8ceb0a11c71af7a447af60651e42af9d017bf6d88e3ffa4e9a52`), início em 2026-10-19 16:34:49 -0300, fim em 2026-10-19 16:34:49 -0300. Rodada `20261019`. `versao()`: 4443971b.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `3fdf3f581be0d55434199a205e676320ede79b79` (ramo `main`); último commit da `COORD` no `HEAD`: `b03d6c7 COORD: COORD-16 (push de 000aad4..6523bc0 ao a1-fase4 e tag feriados_locais-v1.1 no bc586c0)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: vazio.
- **Entradas (SHA-256 = registrados):**
  - `01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds`: `52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e`;
  - `01_saidas/fase1/referencias_exposicao.csv`: `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467`;
  - `01_saidas/fase3/fracao_atribuivel_fase3_20261013.csv`: `9437e9668c729ffd502a159038d2d557b4d8767d1a046cb86eef13ddb2659a48`;
  - `01_saidas/fase4/contagens_insumos_fase4.csv`: `a7e1f60a46574c2cc60b1436406b5bc245228c8a33ea58bbe14f7a5117c946c3`;
  - `01_saidas/fase4/criterio_c1_fase4_20261019.csv`: `886ca12c00ba43318e48ce784b8dac2e923d5cc4905013a82077b25882488168`;
  - `01_saidas/fase4/tabela_sensibilidades_fase4_v2.csv`: `838752c256b90751b0e7e79f23e6a3b3aa495f943f63094d2d4874d7cf165288`;
- **Controle:** PTB por concentração da B1.5 igual ao denominador da fração atribuível nas 26: sim (total 1,378,030). Todas as contagens ≥ 10.
- **Decisões:** A1-123. Tabelas em inglês americano, prontas para o manuscrito; † = MRT na borda da grade (p99).

## tab01

| Urban concentration | Core city | Municipalities | Preterm births, n | Cesarean, % | ≥7 prenatal visits, % | Mean temperature, °C | 1st–99th percentile, °C | MRT (BLUP), °C (percentile) |
|---|---|---|---|---|---|---|---|---|
| São Paulo/SP | São Paulo |  37 | 335,025 | 52.3 | 77.0 | 21.2 | 12.6–27.6 | 24.1 (77.3) |
| Rio de Janeiro/RJ | Rio de Janeiro |  21 | 182,818 | 55.5 | 71.3 | 24.3 | 17.5–31.0 | 23.1 (37.6) |
| Belo Horizonte/MG | Belo Horizonte |  23 | 74,772 | 46.0 | 76.2 | 22.8 | 16.9–28.3 | 26.2 (92.5) |
| Brasília/DF | Brasília |   9 | 68,110 | 51.9 | 70.1 | 22.8 | 18.1–27.3 | 26.1 (95.5) |
| Recife/PE | Recife |  15 | 66,373 | 50.6 | 62.3 | 26.4 | 23.2–29.4 | 28.1 (86.3) |
| Porto Alegre/RS | Porto Alegre |  29 | 58,605 | 51.6 | 74.5 | 21.0 | 9.5–30.2 | 30.2 (99.0)† |
| Fortaleza/CE | Fortaleza |   8 | 62,530 | 64.1 | 65.6 | 28.0 | 25.4–30.5 | 29.9 (97.3) |
| Curitiba/PR | Curitiba |  18 | 45,773 | 56.4 | 84.6 | 19.1 | 9.0–26.3 | 23.4 (85.5) |
| Salvador/BA | Salvador |  10 | 49,778 | 48.2 | 59.7 | 26.3 | 22.6–29.7 | 24.3 (15.6) |
| Goiânia/GO | Goiânia |  15 | 42,244 | 69.5 | 70.7 | 25.1 | 19.9–30.1 | 30.1 (99.0)† |
| Campinas/SP | Campinas |   8 | 33,354 | 63.7 | 82.2 | 22.1 | 13.7–28.0 | 28.0 (99.0)† |
| Manaus | Manaus |   1 | 45,564 | 48.9 | 50.1 | 28.2 | 24.9–31.7 | 31.7 (99.0)† |
| Belém/PA | Belém |   4 | 41,518 | 64.6 | 56.2 | 28.2 | 25.5–30.0 | 30.0 (99.0)† |
| Vitória/ES | Serra |   6 | 27,150 | 59.4 | 68.2 | 25.2 | 19.7–30.0 | 29.1 (95.6) |
| Baixada Santista/SP | Santos |   7 | 25,520 | 54.9 | 77.6 | 23.1 | 15.3–29.8 | 29.8 (99.0)† |
| São José dos Campos/SP | São José dos Campos |  10 | 26,377 | 63.0 | 80.9 | 21.1 | 13.2–26.5 | 24.4 (84.0) |
| São Luís/MA | São Luís |   4 | 29,093 | 54.7 | 50.9 | 28.2 | 25.0–30.2 | 26.4 (6.6) |
| Natal/RN | Natal |   5 | 25,665 | 60.9 | 65.4 | 27.0 | 24.2–29.4 | 25.2 (7.7) |
| Maceió/AL | Maceió |   9 | 22,492 | 60.5 | 55.1 | 26.3 | 23.3–29.1 | 28.4 (95.3) |
| Florianópolis/SC | Florianópolis |  10 | 13,943 | 49.5 | 74.2 | 21.6 | 12.5–28.9 | 23.5 (67.1) |
| João Pessoa/PB | João Pessoa |   6 | 19,500 | 57.8 | 63.7 | 27.1 | 23.9–29.6 | 25.1 (9.1) |
| Teresina/PI | Teresina |   2 | 20,111 | 60.6 | 59.6 | 28.5 | 25.4–31.9 | 31.9 (99.0)† |
| Aracaju/SE | Aracaju |  12 | 16,618 | 47.2 | 58.5 | 27.0 | 23.9–29.9 | 28.9 (92.7) |
| Cuiabá/MT | Cuiabá |   2 | 16,986 | 55.6 | 69.1 | 26.9 | 17.2–32.3 | 32.3 (99.0)† |
| Sorocaba/SP | Sorocaba |   5 | 13,393 | 55.4 | 86.5 | 22.1 | 13.3–28.3 | 28.3 (99.0)† |
| Campo Grande | Campo Grande |   1 | 14,718 | 61.0 | 68.0 | 24.6 | 12.6–30.5 | 30.5 (99.0)† |
| All 26 | — | 277 | 1,378,030 | — | — | — | — | 28.2 (93.8), pooled |

## tab02

| Quantity | Temperature, °C | Estimate |
|---|---|---|
| Pooled MRT, °C (percentile) [95% CI] | 28.2 | 28.2 (93.8) [18.8–29.5] |
| Cumulative RR (lag 0–7), 99th percentile vs MRT | 29.5 | 1.003 (0.978–1.029) |
| Cumulative RR (lag 0–7), 95th percentile vs MRT | 28.4 | 1.000 (0.998–1.002) |
| Cumulative RR (lag 0–7), 90th percentile vs MRT | 27.7 | 1.001 (0.996–1.005) |
| Cumulative RR (lag 0–7), 10th percentile vs MRT | 21.6 | 1.010 (0.989–1.032) |
| Cumulative RR (lag 0–7), 5th percentile vs MRT | 20.6 | 1.013 (0.991–1.035) |
| Cumulative RR (lag 0–7), 1st percentile vs MRT | 18.8 | 1.020 (0.990–1.051) |
| Residual heterogeneity, Cochran Q (df); P; I² | — | 92.9 (92); .454; 1.0% |
| Wald test, mean temperature (meta-predictor); P | — | .195 |
| Wald test, temperature range (meta-predictor); P | — | .307 |
| Attributable fraction, % [eCI], total (forward, BLUP; backward) | — | 1.84 [0.87 to 2.70]; 2.89 [1.58 to 4.05] |
| Attributable fraction, % [eCI], heat (forward, BLUP; backward) | — | 0.23 [0.04 to 0.44]; 0.39 [0.03 to 0.69] |
| Attributable fraction, % [eCI], cold (forward, BLUP; backward) | — | 1.61 [0.67 to 2.45]; 2.50 [1.17 to 3.63] |
| Attributable fraction, % [eCI], extreme heat (>97.5th) (forward, BLUP; backward) | — | 0.08 [0.03 to 0.12]; 0.10 [0.05 to 0.14] |
| Attributable fraction, % [eCI], extreme cold (<2.5th) (forward, BLUP; backward) | — | 0.07 [0.03 to 0.11]; 0.09 [0.02 to 0.15] |

## tab03

| Key | Analysis | MRT, °C (percentile) [95% CI] | RR 99th vs MRT (95% CI) | RR 1st vs MRT (95% CI) | Within primary 95% CI (99th; 1st) | Same direction (99th; 1st) |
|---|---|---|---|---|---|---|
| 1 | Municipal temperature (case time series) | 28.0 (92.7) [18.6–29.5] | 1.006 (0.984–1.029) | 1.018 (0.987–1.050) | yes; yes | yes; yes |
| 2 | Lag 0–14 | 28.1 (93.1) [23.6–29.5] | 1.013 (0.978–1.048) | 1.057 (1.019–1.098) | yes; no | yes; yes |
| 3 | ns(time, 99 df), no strata | 27.9 (91.4) [18.8–29.5] | 1.016 (0.988–1.045) | 1.012 (0.985–1.039) | yes; yes | yes; yes |
| 4 | + PM2.5 (lag 0–1, linear) | 28.2 (93.8) [18.8–29.5] | 1.003 (0.979–1.029) | 1.021 (0.991–1.052) | yes; yes | yes; yes |
| 5 | γ = 1 in the offset | 28.4 (95.1) [18.8–29.5] | 1.002 (0.980–1.025) | 1.018 (0.987–1.050) | yes; yes | yes; yes |
| 6 | Spontaneous preterm birth (i) | 22.3 (15.4) [20.2–29.5] | 1.021 (0.978–1.066) | 1.026 (0.994–1.060) | yes; yes | yes; yes |

## tabS1

| ID | Analysis | N concentrations | MRT, °C (percentile) | MRT 95% CI, °C | RR 99th vs MRT (95% CI) | RR 1st vs MRT (95% CI) | Dispersion (min; median; max) | Note |
|---|---|---|---|---|---|---|---|---|
| P0 | Primary analysis | 26 | 28.2 (93.8) | 18.8–29.5 | 1.003 (0.978–1.029) | 1.020 (0.990–1.051) | 0.98; 1.01; 1.12 |  |
| C2-D3 | + lagged deviance residuals (lags 1–7) | 26 | 28.4 (95.1) | 18.8–29.5 | 1.002 (0.980–1.026) | 1.021 (0.990–1.053) | 0.97; 1.00; 1.12 |  |
| C3-E1 | Births-weighted metropolitan temperature | 26 | 28.2 (93.9) | 18.8–29.5 | 1.004 (0.978–1.030) | 1.021 (0.991–1.052) | 0.98; 1.01; 1.12 |  |
| C3-E2 | Maximum temperature | 26 | 35.1 (98.1) | 22.0–35.7 | 1.000 (0.988–1.013) | 1.009 (0.972–1.047) | 0.97; 1.01; 1.12 |  |
| C3-E3 | Minimum temperature | 26 | 22.9 (89.9) | 18.2–24.3 | 1.006 (0.981–1.033) | 1.036 (1.002–1.071) | 0.98; 1.01; 1.12 |  |
| C3-E4 | Apparent temperature | 26 | 27.6 (40.5) | 19.8–34.7 | 1.001 (0.971–1.031) | 1.014 (0.989–1.039) | 0.98; 1.01; 1.12 |  |
| C3-E5 | + relative humidity (lag 0–3) | 26 | 27.8 (90.5) | 18.8–29.5 | 1.006 (0.978–1.036) | 1.011 (0.980–1.042) | 0.98; 1.01; 1.12 |  |
| C3-P1 | + PM2.5, zero-missing series (23 concentrations) | 23 | 27.7 (89.6) | 18.8–29.5 | 1.015 (0.990–1.041) | 1.025 (0.991–1.060) | 0.98; 1.01; 1.12 |  |
| C3-CB1 | Lag 0–4 | 26 | 18.8 (1.0) | 18.8–29.5 | 1.001 (0.968–1.035) | 1.000 (boundary) | 0.98; 1.01; 1.12 |  |
| C3-CB2 | Lag 0–21 | 26 | 28.1 (93.1) | 22.3–29.5 | 1.025 (0.979–1.074) | 1.076 (1.025–1.130) | 0.98; 1.01; 1.12 |  |
| C3-CB3 | Quadratic B-spline, knots p10/p75/p90 | 26 | 28.7 (96.7) | 18.8–29.5 | 1.004 (0.987–1.021) | 1.015 (0.980–1.051) | 0.98; 1.01; 1.12 |  |
| C3-CB4 | Natural spline, knots p50/p90 | 26 | 29.5 (99.0) | 18.8–29.5 | 1.000 (boundary) | 1.019 (0.979–1.060) | 0.98; 1.01; 1.12 |  |
| C3-T1 | ns(time, 74 df), no strata | 26 | 27.7 (89.6) | 18.8–29.5 | 1.021 (0.990–1.053) | 1.017 (0.991–1.044) | 0.98; 1.02; 1.13 |  |
| C3-T2 | ns(time, 123 df), no strata | 26 | 20.7 (5.2) | 18.8–29.5 | 1.006 (0.973–1.040) | 1.002 (0.984–1.021) | 0.98; 1.01; 1.13 |  |
| C3-T3 | Strata × day of week | 26 | 28.7 (96.7) | 20.8–29.5 | 1.001 (0.982–1.020) | 1.024 (0.990–1.058) | 0.97; 1.02; 1.12 |  |
| C3-T4 | Excluding Dec 24 to Jan 1 | 26 | 28.0 (92.3) | 18.8–29.5 | 1.008 (0.980–1.037) | 1.021 (0.991–1.052) | 0.98; 1.01; 1.12 |  |
| C3-T5 | Excluding 2020–2021 | 26 | 29.5 (99.0) | 18.8–29.5 | 1.000 (boundary) | 1.030 (0.983–1.080) | 0.97; 1.02; 1.13 |  |
| C3-T6 | Warm season, Nov–Mar (own axis; MRT searched between 1st and 50th) | 26 | 26.1 (46.1) | 21.9–26.2 | 1.011 (0.976–1.047) | 1.022 (0.990–1.054) | 0.94; 1.01; 1.11 |  |
| C3-T7 | + negative control exposure (t+1 to t+7) | 26 | 28.1 (93.1) | 18.8–29.5 | 1.004 (0.977–1.031) | 1.016 (0.987–1.047) | 0.98; 1.01; 1.12 |  |
| C3-D1 | Fetal deaths in the risk set | 26 | 28.2 (93.8) | 18.8–29.5 | 1.003 (0.978–1.029) | 1.020 (0.990–1.051) | 0.98; 1.01; 1.12 |  |
| C3-D2 | Delivery risk weights by entry year | 26 | 28.2 (93.8) | 18.8–29.5 | 1.003 (0.978–1.029) | 1.020 (0.990–1.051) | 0.98; 1.01; 1.12 |  |
| C3-D3o | No offset | 26 | 28.2 (93.8) | 19.8–29.5 | 1.006 (0.980–1.034) | 1.022 (0.992–1.054) | 0.99; 1.02; 1.16 |  |
| C3-D4 | Possible-event window (2012-01-04 to 2024-11-15) | 26 | 28.8 (97.1) | 18.8–29.5 | 1.001 (0.985–1.016) | 1.021 (0.988–1.056) | 0.98; 1.01; 1.12 |  |
| C3-O1 | Extremely preterm, 22–27 wk (18 concentrations) | 18 | 27.5 (87.4) | 18.8–29.5 | 1.081 (0.939–1.244) | 1.039 (0.914–1.181) | 0.97; 1.00; 1.04 |  |
| C3-O2 | Very preterm, 28–31 wk | 26 | 29.5 (99.0) | 23.8–29.5 | 1.000 (boundary) | 1.106 (0.995–1.230) | 0.98; 1.01; 1.05 |  |
| C3-O3 | Moderate-to-late preterm, 32–36 wk | 26 | 28.5 (95.7) | 18.8–29.5 | 1.001 (0.979–1.024) | 1.007 (0.975–1.041) | 0.97; 1.02; 1.10 |  |
| C3-O4 | Spontaneous preterm birth (ii) | 26 | 22.5 (17.4) | 18.8–29.5 | 1.017 (0.976–1.061) | 1.021 (0.991–1.052) | 0.99; 1.02; 1.14 |  |
| C3-O5 | Consistent gestational age (i) | 26 | 29.5 (99.0) | 22.4–29.5 | 1.000 (boundary) | 1.046 (0.989–1.105) | 0.97; 1.06; 1.20 |  |
| C3-O6 | Consistent gestational age (ii, LMP) | 26 | 28.1 (93.1) | 18.8–29.5 | 1.005 (0.970–1.041) | 1.008 (0.968–1.048) | 0.98; 1.05; 1.19 |  |
| C3-O7 | 2011 cohort, arm A (no offset, no fixed cohort) | 26 | 28.1 (93.1) | 18.8–29.5 | 1.007 (0.982–1.032) | 1.016 (0.988–1.046) | 0.99; 1.02; 1.15 |  |
| C3-O8 | 2011 cohort, arm B (no offset, no fixed cohort) | 26 | 28.2 (93.8) | 18.8–29.5 | 1.007 (0.983–1.031) | 1.018 (0.988–1.049) | 0.99; 1.02; 1.15 |  |
| C3-O9 | Early term, 37–38 wk (comparison outcome) | 26 | 18.8 (1.0) | 18.8–29.5 | 1.007 (0.980–1.035) | 1.000 (boundary) | 1.01; 1.14; 2.00 |  |
| C3-O10 | Early term, intersection window | 26 | 18.8 (1.0) | 18.8–29.5 | 1.012 (0.984–1.041) | 1.000 (boundary) | 1.01; 1.14; 2.00 |  |
| C3-NB | Negative binomial model | — | — | — | — | — | — | Not applicable (dispersion >2 in 0 of 26 concentrations in the primary analysis) |
| C3-N2000 | Inclusion threshold of 2,000 events | — | — | — | — | — | — | Identical to the primary analysis (no concentration excluded) |
| C3-FL | + local holidays (and Dec 24 and 31) | 26 | 28.1 (93.1) | 18.8–29.5 | 1.004 (0.978–1.031) | 1.020 (0.991–1.051) | 0.98; 1.01; 1.12 |  |
| C4-FIX | Fixed-effects meta-analysis | 26 | 27.7 (89.6) | 18.8–29.5 | 1.009 (0.985–1.033) | 1.012 (0.986–1.038) | 0.98; 1.01; 1.12 |  |
| C4-MULTI | Multilevel meta-analysis (concentration within macroregion) | 26 | 28.2 (93.8) | 18.8–29.5 | 1.003 (0.978–1.029) | 1.020 (0.990–1.051) | 0.98; 1.01; 1.12 |  |
| C4-EX-regiao | Exploratory meta-regression: macroregion | 26 | — | — | — | — | — | Wald 16.55 (16 df); P = 0.415 |
| C4-EX-cesarea | Exploratory meta-regression: cesarean, % | 26 | — | — | — | — | — | Wald 1.13 (4 df); P = 0.89 |
| C4-EX-prenatal | Exploratory meta-regression: ≥7 prenatal visits, % | 26 | — | — | — | — | — | Wald 4.99 (4 df); P = 0.289 |
| C4-EX-idhm | Exploratory meta-regression: MHDI 2010 | 26 | — | — | — | — | — | Wald 1.81 (4 df); P = 0.771 |
| C4-UMA | One-stage model | 26 | 27.3 (85.1) | 22.9–29.5 | 1.019 (0.994–1.044) | 1.020 (0.999–1.042) | 1.03; 1.03; 1.03 |  |
| C4-S3 | Penalized DLNM (contrasts vs concentration-specific reference) | 26 | — | — | 0.998 (0.993–1.002) | 1.014 (0.989–1.041) | 0.98; 1.01; 1.12 |  |

## tabS2

| Urban concentration | MRT, °C (percentile) [95% CI] | 99th percentile, °C | RR 99th vs MRT (95% CI) | 1st percentile, °C | RR 1st vs MRT (95% CI) |
|---|---|---|---|---|---|
| São Paulo/SP | 24.1 (77.3) [12.6–25.9] | 27.6 | 1.051 (0.997–1.109) | 12.6 | 1.011 (0.974–1.050) |
| Rio de Janeiro/RJ | 23.1 (37.6) [17.5–31.0] | 31.0 | 1.037 (0.970–1.109) | 17.5 | 1.012 (0.978–1.047) |
| Belo Horizonte/MG | 26.2 (92.5) [19.7–28.3] | 28.3 | 1.023 (0.973–1.077) | 16.9 | 1.045 (0.997–1.096) |
| Brasília/DF | 26.1 (95.5) [18.9–27.3] | 27.3 | 1.009 (0.948–1.073) | 18.1 | 1.059 (0.990–1.132) |
| Recife/PE | 28.1 (86.3) [23.2–29.4] | 29.4 | 1.045 (0.954–1.144) | 23.2 | 1.010 (0.948–1.075) |
| Porto Alegre/RS | 30.2 (99.0) [9.5–30.2]† | 30.2 | 1 (boundary) | 9.5 | 1.118 (0.972–1.285) |
| Fortaleza/CE | 29.9 (97.3) [25.4–30.5] | 30.5 | 1.002 (0.955–1.051) | 25.4 | 1.012 (0.936–1.094) |
| Curitiba/PR | 23.4 (85.5) [9.0–26.3] | 26.3 | 1.072 (0.963–1.193) | 9.0 | 1.063 (0.994–1.138) |
| Salvador/BA | 24.3 (15.6) [22.6–29.7] | 29.7 | 1.049 (0.954–1.153) | 22.6 | 1.006 (0.963–1.052) |
| Goiânia/GO | 30.1 (99.0) [20.6–30.1]† | 30.1 | 1 (boundary) | 19.9 | 1.060 (0.955–1.175) |
| Campinas/SP | 28.0 (99.0) [17.6–28.0]† | 28.0 | 1 (boundary) | 13.7 | 1.053 (0.962–1.151) |
| Manaus | 31.7 (99.0) [24.9–31.7]† | 31.7 | 1 (boundary) | 24.9 | 1.033 (0.924–1.155) |
| Belém/PA | 30.0 (99.0) [25.5–30.0]† | 30.0 | 1 (boundary) | 25.5 | 1.029 (0.912–1.161) |
| Vitória/ES | 29.1 (95.6) [19.7–30.0] | 30.0 | 1.001 (0.952–1.053) | 19.7 | 1.032 (0.958–1.111) |
| Baixada Santista/SP | 29.8 (99.0) [20.1–29.8]† | 29.8 | 1 (boundary) | 15.3 | 1.074 (0.977–1.180) |
| São José dos Campos/SP | 24.4 (84.0) [13.2–25.5] | 26.5 | 1.074 (0.997–1.157) | 13.2 | 1.037 (0.969–1.110) |
| São Luís/MA | 26.4 (6.6) [25.0–30.2] | 30.2 | 1.024 (0.917–1.142) | 25.0 | 1.010 (0.961–1.062) |
| Natal/RN | 25.2 (7.7) [24.2–29.4] | 29.4 | 1.043 (0.937–1.162) | 24.2 | 1.004 (0.968–1.042) |
| Maceió/AL | 28.4 (95.3) [23.3–29.1] | 29.1 | 1.008 (0.957–1.062) | 23.3 | 1.021 (0.944–1.103) |
| Florianópolis/SC | 23.5 (67.1) [12.5–28.9] | 28.9 | 1.023 (0.942–1.111) | 12.5 | 1.021 (0.979–1.065) |
| João Pessoa/PB | 25.1 (9.1) [23.9–29.6] | 29.6 | 1.027 (0.927–1.137) | 23.9 | 1.005 (0.973–1.039) |
| Teresina/PI | 31.9 (99.0) [25.4–31.9]† | 31.9 | 1 (boundary) | 25.4 | 1.025 (0.889–1.181) |
| Aracaju/SE | 28.9 (92.7) [23.9–29.9] | 29.9 | 1.011 (0.948–1.079) | 23.9 | 1.012 (0.941–1.088) |
| Cuiabá/MT | 32.3 (99.0) [17.2–32.3]† | 32.3 | 1 (boundary) | 17.2 | 1.081 (0.916–1.275) |
| Sorocaba/SP | 28.3 (99.0) [17.2–28.3]† | 28.3 | 1 (boundary) | 13.3 | 1.057 (0.955–1.171) |
| Campo Grande | 30.5 (99.0) [12.6–30.5]† | 30.5 | 1 (boundary) | 12.6 | 1.087 (0.917–1.288) |

## Saídas (fora do git)

- `tabelas/tab01_caracteristicas_v1_20261019.csv`: `5362dc4d33ab5020f25c1326ce5480e48531e20bf79ed850b1805bd23b66d78d`;
- `tabelas/tab02_resultados_principais_v1_20261019.csv`: `307a98d8900bae06ab5c11ed398b02394d8e82d3290bf519263dfc52f4d7aab8`;
- `tabelas/tab03_criterio_c1_v1_20261019.csv`: `e85881abbc1b621375f867f5af06e82395c899a5b35fa8cd257a573242f07870`;
- `tabelas/tabS1_sensibilidades_v1_20261019.csv`: `ee7dbeaa7089650e12e773d16eee143a282f3ba842765ba5b8781bf3710148ae`;
- `tabelas/tabS2_blups_v1_20261019.csv`: `155a2a6ee680d33f5001831f7811eb4d06ebfbdc4ec9e548a76ca97d29b289da`;

- **Resultado:** ok.

