# Fase 3, Parte C: segunda etapa do modelo principal (C1 a C4) e conferência da cross-basis (C6)

- **Gerado por:** `00_scripts/45_segunda_etapa_principal.R`, em 2026-10-13 22:08:32 -03. Rodada `20261013`. `versao()` no início = 4443971b (o fim está na última linha).
- **Ambiente:** R 4.5.1; dlnm 2.4.10; gnm 1.1.5; mixmeta 1.2.0. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib` (referência). Semente 20261001; sementes por concentração conforme o complemento C1 (bootstrap com i = posição na ordem; combinada com i = 0).
- **Código (SHA-256, iguais aos das tags):**
  - `codigo_compartilhado/R/.gitkeep`: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`;
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009`;
  - `codigo_compartilhado/R/offset.R`: `55111b2cc510d7b1c7b78b7f84e99997c5202825e0353da70bab0b4bea290bae`;
  - `codigo_compartilhado/R/segunda_etapa.R`: `1fb4543a3d4f0fd31bbf35571944c37756c33b1a1d11f876d48bd9bdd3aa9abb`;
  - tags `ajusta_dlnm-v1.0` (commit `caf5022f9a655877d8e3931dd3d02d7dce429fe5`) e `segunda_etapa-v1.0` (commit `410dd6d6d3d315004f22fd7197c326de77f3c2f4`); `codigo_compartilhado/inst/terceiros/attrdl.R`: `d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d`.
- **Entradas (SHA-256 conferidos):**
  - `01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds`: `5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d`;
  - `01_saidas/fase2/reduzida_coef_vcov_fase2_20261010.csv`: `50f58701005f9cbaf722f5043844f0e6680be5717b011419b2b3b4b688e58c4d`;
  - `01_saidas/fase2/crossbasis_coef_vcov_fase2_20261010.csv`: `8eed876c0bc0983705305042324c79ab1f0d619a41a97d8139503b73957e4ddd`;
  - `01_saidas/fase1/referencias_exposicao.csv`: `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467`;
  - `01_saidas/fase1/serie_ptb_principal.rds`: `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917`;
  - `01_saidas/fase3/percentis_exposicao_fase3_20261013.csv`: `e2bd54e9fc2df3689916331c0db79000b4fd01e1ed3d48f6c536c4a3a099b490`;
- Os CSV `reduzida_coef_vcov` e `crossbasis_coef_vcov` da Fase 2 são iguais à RDS (comparação exata no texto, com o mesmo `sprintf("%.17g")` da gravação). A `tmean_nucleo` de 2012–2024 lida para a C4 reproduz a grade da A0 (igualdade exata no texto `%.17g`).

## C6: cross-basis remontada contra a da Fase 2 (antes de qualquer curva)

- Nas 26 concentrações, a cross-basis pelo caminho da Fase 2 (nós do CSV, fronteiras padrão, 4.505 linhas) e a montada pela `monta_cb` com a `argvar` e a `arglag` da RDS têm o mesmo padrão de NA: sim; diferença máxima nas demais células: 0.0e+00 (critério ≤ 1e-12); atributos `argvar`, `arglag`, `lag`, `range` e `df` das duas `identical()` aos da RDS: sim, nas 26.

## C1: meta-análise da curva geral

- **Método usado:** reml, Ψ unstr (tentativas: reml/unstr: ok). Convergiu: sim. Menor autovalor de Ψ: 8.284e-17.
- **Avisos do mixmeta:** nenhum.
- **Ψ:** autovalores de Ψ 2.657e-02; 5.493e-04; 2 abaixo de 1e-8 × o maior; posto efetivo 2 de 4 (autovalores acima de 1e-8 × o maior): Ψ singular, só reportado (A1.2; a sequência de estabilidade age só em erro ou não convergência).

**Heterogeneidade (Q de Cochran multivariado e I²):**

| Tipo | Q | gl | p | I² |
|---|---|---|---|---|
| residual | 92,92 |  92 | 0,454 | 1,0% |
| total | 102,33 | 100 | 0,417 | 2,3% |

**Wald de cada metapreditor:**

| Termo | Estatística | gl | p |
|---|---|---|---|
| media | 6,06 | 4 | 0,195 |
| amplitude | 4,82 | 4 | 0,307 |

**Coeficientes da meta-regressão (EP):**

| Coeficiente | Estimativa | EP |
|---|---|---|
| y1.(Intercept) | 1.2077e-01 | 6.0045e-01 |
| y2.(Intercept) | -4.3579e-01 | 4.6896e-01 |
| y3.(Intercept) | 8.5658e-01 | 1.5217e+00 |
| y4.(Intercept) | 1.5153e+00 | 8.6189e-01 |
| y1.media | -3.8549e-03 | 2.0172e-02 |
| y2.media | 1.3934e-02 | 1.5731e-02 |
| y3.media | -2.9850e-02 | 5.1072e-02 |
| y4.media | -4.8059e-02 | 2.8732e-02 |
| y1.amplitude | -4.8261e-03 | 1.0760e-02 |
| y2.amplitude | 5.6007e-03 | 8.7064e-03 |
| y3.amplitude | -1.6964e-02 | 2.7766e-02 |
| y4.amplitude | -3.0968e-02 | 1.6998e-02 |

**Ψ (4 × 4):**

|   | b1 | b2 | b3 | b4 |
|---|---|---|---|---|
| b1 | 1.701e-04 | 3.868e-04 | 1.373e-03 | 1.468e-03 |
| b2 | 3.868e-04 | 1.070e-03 | 2.601e-03 | 2.970e-03 |
| b3 | 1.373e-03 | 2.601e-03 | 1.251e-02 | 1.285e-02 |
| b4 | 1.468e-03 | 2.970e-03 | 1.285e-02 | 1.337e-02 |

**BLUPs por concentração (coeficientes reduzidos da curva cumulativa; EP entre parênteses):**

| Concentração | i | b1 | b2 | b3 | b4 |
|---|---|---|---|---|---|
| São Paulo/SP |  1 | -2.016e-02 (4.267e-02) | -1.521e-02 (3.575e-02) | 4.670e-02 (1.168e-01) | 1.255e-01 (7.481e-02) |
| Rio de Janeiro/RJ |  2 | -2.404e-02 (3.314e-02) | 1.405e-02 (3.259e-02) | 4.440e-03 (1.050e-01) | 4.281e-02 (8.182e-02) |
| Belo Horizonte/MG |  3 | -2.467e-02 (4.279e-02) | -6.877e-02 (3.879e-02) | -1.574e-02 (1.300e-01) | 6.032e-02 (9.551e-02) |
| Brasília/DF |  4 | -2.870e-02 (6.240e-02) | -9.906e-02 (5.259e-02) | -1.401e-01 (1.715e-01) | -2.835e-02 (1.126e-01) |
| Recife/PE |  5 | -6.200e-03 (4.734e-02) | -2.357e-02 (4.451e-02) | 5.708e-03 (1.428e-01) | 9.813e-02 (1.078e-01) |
| Porto Alegre/RS |  6 | -6.814e-02 (5.519e-02) | -5.045e-02 (5.365e-02) | -1.743e-01 (1.667e-01) | -1.953e-01 (1.292e-01) |
| Fortaleza/CE |  7 | -1.395e-02 (5.503e-02) | -2.744e-02 (5.028e-02) | -6.818e-02 (1.660e-01) | 3.183e-03 (1.247e-01) |
| Curitiba/PR |  8 | -3.536e-02 (6.394e-02) | -7.802e-02 (5.425e-02) | 2.221e-02 (1.763e-01) | 8.537e-02 (1.155e-01) |
| Salvador/BA |  9 | -5.382e-03 (4.319e-02) | -9.499e-03 (4.181e-02) | 3.040e-02 (1.351e-01) | 1.155e-01 (1.050e-01) |
| Goiânia/GO | 10 | -3.490e-02 (3.225e-02) | -4.622e-02 (3.526e-02) | -1.604e-01 (1.127e-01) | -1.013e-01 (9.452e-02) |
| Campinas/SP | 11 | -4.028e-02 (3.446e-02) | -6.160e-02 (3.688e-02) | -1.029e-01 (1.216e-01) | -5.079e-02 (1.018e-01) |
| Manaus | 12 | -2.488e-02 (5.730e-02) | -7.065e-03 (5.176e-02) | -1.550e-01 (1.684e-01) | -1.012e-01 (1.227e-01) |
| Belém/PA | 13 | -1.690e-02 (5.725e-02) | -3.498e-02 (5.257e-02) | -1.166e-01 (1.723e-01) | -3.968e-02 (1.296e-01) |
| Vitória/ES | 14 | -2.802e-02 (3.271e-02) | -3.741e-02 (3.638e-02) | -7.171e-02 (1.200e-01) | -2.081e-02 (1.033e-01) |
| Baixada Santista/SP | 15 | -4.831e-02 (3.031e-02) | -5.492e-02 (3.676e-02) | -1.627e-01 (1.194e-01) | -1.322e-01 (1.069e-01) |
| São José dos Campos/SP | 16 | -1.395e-02 (5.555e-02) | -4.858e-02 (4.934e-02) | 1.055e-01 (1.637e-01) | 1.944e-01 (1.172e-01) |
| São Luís/MA | 17 | -8.672e-03 (5.560e-02) | -2.521e-03 (5.104e-02) | -4.341e-02 (1.666e-01) | 3.358e-02 (1.244e-01) |
| Natal/RN | 18 | -1.559e-03 (5.218e-02) | -1.746e-02 (4.916e-02) | 2.543e-02 (1.611e-01) | 1.206e-01 (1.242e-01) |
| Maceió/AL | 19 | -1.214e-02 (5.055e-02) | -3.931e-02 (4.825e-02) | -7.070e-02 (1.575e-01) | 3.082e-02 (1.226e-01) |
| Florianópolis/SC | 20 | -3.164e-02 (3.659e-02) | -1.731e-02 (4.201e-02) | -5.067e-04 (1.379e-01) | 4.578e-02 (1.214e-01) |
| João Pessoa/PB | 21 | -6.623e-03 (4.985e-02) | -1.606e-02 (4.798e-02) | -1.308e-02 (1.564e-01) | 7.538e-02 (1.225e-01) |
| Teresina/PI | 22 | -2.102e-02 (6.086e-02) | -7.999e-03 (5.568e-02) | -9.365e-02 (1.817e-01) | -5.026e-02 (1.351e-01) |
| Aracaju/SE | 23 | -1.117e-02 (4.850e-02) | -2.408e-02 (4.791e-02) | -3.705e-02 (1.577e-01) | 4.477e-02 (1.272e-01) |
| Cuiabá/MT | 24 | -5.579e-02 (9.070e-02) | 2.043e-02 (7.922e-02) | -1.971e-01 (2.536e-01) | -2.408e-01 (1.762e-01) |
| Sorocaba/SP | 25 | -4.353e-02 (3.368e-02) | -5.834e-02 (3.931e-02) | -1.125e-01 (1.294e-01) | -6.987e-02 (1.144e-01) |
| Campo Grande | 26 | -5.912e-02 (7.627e-02) | 1.209e-02 (6.977e-02) | -1.757e-01 (2.212e-01) | -2.130e-01 (1.626e-01) |

## C2: curva combinada e TMR combinada (contraste primário)

- **Base combinada (D2):** ns com nós 21,611; 26,541; 27,717 e Boundary.knots 15,541 e 31,337 °C (médias dos `attr(cb, "argvar")` das 26).
- **Eixo médio (A0):** x1 = 18,774 °C, x50 = 24,936 °C, x99 = 29,475 °C. Curva na média dos metapreditores (média 24,768 °C; amplitude 10,701 °C).
- **TMR combinada:** 28,2 °C, no percentil 93,8 do eixo médio (q_TMR = 0,9378); IC 95% do bootstrap da D4(a): 18,8 a 29,5 °C. Na fronteira da grade x1–x99: não.
- **Extensão do IC da TMR combinada:** o IC é a faixa de busca inteira (x1 a x99); 3,5% dos sorteios caem no x1 e 30,9% no x99.

**RR cumulativo de lag 0–7 contra a TMR combinada (IC 95%; a TMR é tratada como fixa):**

| Contraste | Percentil | °C | RR |
|---|---|---|---|
| x99 (primário) | p99 | 29,475 | 1,003 (0,978 a 1,029) |
| x1 (coprimário) | p1 | 18,774 | 1,020 (0,990 a 1,051) |
| x95 | p95 | 28,352 | 1,000 (0,998 a 1,002) |
| x90 | p90 | 27,717 | 1,001 (0,996 a 1,005) |
| x10 | p10 | 21,611 | 1,010 (0,989 a 1,032) |
| x5 | p5 | 20,635 | 1,013 (0,991 a 1,035) |

## C3: curvas BLUP e TMR por concentração

- **TMR BLUP na fronteira da grade p1–p99:** 10 de 26 (Porto Alegre/RS, Goiânia/GO, Campinas/SP, Manaus, Belém/PA, Baixada Santista/SP, Teresina/PI, Cuiabá/MT, Sorocaba/SP, Campo Grande). Na fronteira, o `cen` da C5 continua sendo a TMR da grade (D4(g)).
- **IC da TMR BLUP igual à grade p1–p99 inteira:** 18 de 26. A coluna "Sorteios nas pontas" dá a porcentagem dos 1.000 sorteios do bootstrap no p1 e no p99 da concentração.

| Concentração | i | TMR °C (IC 95%) | Percentil da TMR | Fronteira | Sorteios nas pontas | RR p99 (°C) | RR p1 (°C) |
|---|---|---|---|---|---|---|---|
| São Paulo/SP |  1 | 24,1 (12,6 a 25,9) | 77,3 | não | 12,2% / 1,8% | 1,051 (0,997 a 1,109) (27,6) | 1,011 (0,974 a 1,050) (12,6) |
| Rio de Janeiro/RJ |  2 | 23,1 (17,5 a 31,0) | 37,6 | não | 17,2% / 10,1% | 1,037 (0,970 a 1,109) (31,0) | 1,012 (0,978 a 1,047) (17,5) |
| Belo Horizonte/MG |  3 | 26,2 (19,7 a 28,3) | 92,5 | não | 1,2% / 9,3% | 1,023 (0,973 a 1,077) (28,3) | 1,045 (0,997 a 1,096) (16,9) |
| Brasília/DF |  4 | 26,1 (18,9 a 27,3) | 95,5 | não | 1,6% / 34,1% | 1,009 (0,948 a 1,073) (27,3) | 1,059 (0,990 a 1,132) (18,1) |
| Recife/PE |  5 | 28,1 (23,2 a 29,4) | 86,3 | não | 21,9% / 10,5% | 1,045 (0,954 a 1,144) (29,4) | 1,010 (0,948 a 1,075) (23,2) |
| Porto Alegre/RS |  6 | 30,2 (9,5 a 30,2) | 99,0 | sim (p10–p90: 26,9) | 3,0% / 81,8% | 1,000 (1,000 a 1,000) (30,2) | 1,118 (0,972 a 1,285) (9,5) |
| Fortaleza/CE |  7 | 29,9 (25,4 a 30,5) | 97,3 | não | 15,6% / 35,6% | 1,002 (0,955 a 1,051) (30,5) | 1,012 (0,936 a 1,094) (25,4) |
| Curitiba/PR |  8 | 23,4 (9,0 a 26,3) | 85,5 | não | 3,1% / 5,7% | 1,072 (0,963 a 1,193) (26,3) | 1,063 (0,994 a 1,138) (9,0) |
| Salvador/BA |  9 | 24,3 (22,6 a 29,7) | 15,6 | não | 22,6% / 6,1% | 1,049 (0,954 a 1,153) (29,7) | 1,006 (0,963 a 1,052) (22,6) |
| Goiânia/GO | 10 | 30,1 (20,6 a 30,1) | 99,0 | sim (p10–p90: 27,6) | 1,8% / 75,2% | 1,000 (1,000 a 1,000) (30,1) | 1,060 (0,955 a 1,175) (19,9) |
| Campinas/SP | 11 | 28,0 (17,6 a 28,0) | 99,0 | sim (p10–p90: 26,1) | 1,7% / 47,7% | 1,000 (1,000 a 1,000) (28,0) | 1,053 (0,962 a 1,151) (13,7) |
| Manaus | 12 | 31,7 (24,9 a 31,7) | 99,0 | sim (p10–p90: 26,5) | 8,9% / 62,3% | 1,000 (1,000 a 1,000) (31,7) | 1,033 (0,924 a 1,155) (24,9) |
| Belém/PA | 13 | 30,0 (25,5 a 30,0) | 99,0 | sim (p10–p90: 29,2) | 10,2% / 52,8% | 1,000 (1,000 a 1,000) (30,0) | 1,029 (0,912 a 1,161) (25,5) |
| Vitória/ES | 14 | 29,1 (19,7 a 30,0) | 95,6 | não | 5,6% / 41,9% | 1,001 (0,952 a 1,053) (30,0) | 1,032 (0,958 a 1,111) (19,7) |
| Baixada Santista/SP | 15 | 29,8 (20,1 a 29,8) | 99,0 | sim (p10–p90: 27,5) | 0,3% / 79,4% | 1,000 (1,000 a 1,000) (29,8) | 1,074 (0,977 a 1,180) (15,3) |
| São José dos Campos/SP | 16 | 24,4 (13,2 a 25,5) | 84,0 | não | 10,3% / 1,5% | 1,074 (0,997 a 1,157) (26,5) | 1,037 (0,969 a 1,110) (13,2) |
| São Luís/MA | 17 | 26,4 (25,0 a 30,2) | 6,6 | não | 23,3% / 27,1% | 1,024 (0,917 a 1,142) (30,2) | 1,010 (0,961 a 1,062) (25,0) |
| Natal/RN | 18 | 25,2 (24,2 a 29,4) | 7,7 | não | 22,0% / 8,5% | 1,043 (0,937 a 1,162) (29,4) | 1,004 (0,968 a 1,042) (24,2) |
| Maceió/AL | 19 | 28,4 (23,3 a 29,1) | 95,3 | não | 15,4% / 26,4% | 1,008 (0,957 a 1,062) (29,1) | 1,021 (0,944 a 1,103) (23,3) |
| Florianópolis/SC | 20 | 23,5 (12,5 a 28,9) | 67,1 | não | 8,6% / 20,6% | 1,023 (0,942 a 1,111) (28,9) | 1,021 (0,979 a 1,065) (12,5) |
| João Pessoa/PB | 21 | 25,1 (23,9 a 29,6) | 9,1 | não | 20,4% / 16,1% | 1,027 (0,927 a 1,137) (29,6) | 1,005 (0,973 a 1,039) (23,9) |
| Teresina/PI | 22 | 31,9 (25,4 a 31,9) | 99,0 | sim (p10–p90: 27,1) | 16,1% / 48,7% | 1,000 (1,000 a 1,000) (31,9) | 1,025 (0,889 a 1,181) (25,4) |
| Aracaju/SE | 23 | 28,9 (23,9 a 29,9) | 92,7 | não | 19,4% / 22,8% | 1,011 (0,948 a 1,079) (29,9) | 1,012 (0,941 a 1,088) (23,9) |
| Cuiabá/MT | 24 | 32,3 (17,2 a 32,3) | 99,0 | sim (p10–p90: 25,3) | 7,0% / 70,3% | 1,000 (1,000 a 1,000) (32,3) | 1,081 (0,916 a 1,275) (17,2) |
| Sorocaba/SP | 25 | 28,3 (17,2 a 28,3) | 99,0 | sim (p10–p90: 26,2) | 1,8% / 56,5% | 1,000 (1,000 a 1,000) (28,3) | 1,057 (0,955 a 1,171) (13,3) |
| Campo Grande | 26 | 30,5 (12,6 a 30,5) | 99,0 | sim (p10–p90: 22,9) | 6,5% / 71,2% | 1,000 (1,000 a 1,000) (30,5) | 1,087 (0,917 a 1,288) (12,6) |

**Concentrações com TMR BLUP na fronteira: RR contra a mediana (p50) da concentração** (§7 e A1.4; só reportado: o `cen` da C5 continua sendo a TMR da grade, D4(g); IC 95%; °C entre colchetes):

| Concentração | p50 (°C) | p99 | p95 | p90 | p10 | p5 | p1 |
|---|---|---|---|---|---|---|---|
| Porto Alegre/RS | 21,4 | 0,940 (0,846 a 1,044) [30,2] | 0,978 (0,922 a 1,037) [28,1] | 0,990 (0,945 a 1,037) [26,9] | 1,031 (0,991 a 1,072) [14,1] | 1,039 (0,994 a 1,085) [12,3] | 1,051 (0,977 a 1,130) [9,5] |
| Goiânia/GO | 25,2 | 0,943 (0,851 a 1,044) [30,1] | 0,969 (0,924 a 1,016) [28,5] | 0,982 (0,954 a 1,011) [27,6] | 0,996 (0,974 a 1,017) [22,3] | 0,995 (0,971 a 1,020) [21,5] | 0,999 (0,972 a 1,026) [19,9] |
| Campinas/SP | 22,5 | 0,973 (0,901 a 1,052) [28,0] | 0,976 (0,935 a 1,018) [26,7] | 0,979 (0,948 a 1,010) [26,1] | 1,011 (0,987 a 1,036) [17,9] | 1,014 (0,988 a 1,041) [16,6] | 1,024 (0,993 a 1,057) [13,7] |
| Manaus | 28,2 | 0,961 (0,868 a 1,065) [31,7] | 0,993 (0,944 a 1,044) [30,5] | 1,001 (0,966 a 1,038) [30,0] | 0,984 (0,954 a 1,015) [26,5] | 0,985 (0,952 a 1,019) [25,9] | 0,993 (0,954 a 1,034) [24,9] |
| Belém/PA | 28,3 | 0,967 (0,867 a 1,079) [30,0] | 0,976 (0,924 a 1,032) [29,4] | 0,983 (0,945 a 1,023) [29,2] | 0,989 (0,960 a 1,020) [27,1] | 0,987 (0,952 a 1,024) [26,6] | 0,995 (0,951 a 1,042) [25,5] |
| Baixada Santista/SP | 23,1 | 0,951 (0,873 a 1,036) [29,8] | 0,971 (0,923 a 1,021) [28,4] | 0,981 (0,946 a 1,017) [27,5] | 1,008 (0,985 a 1,032) [18,7] | 1,012 (0,987 a 1,038) [17,5] | 1,021 (0,994 a 1,049) [15,3] |
| Teresina/PI | 28,2 | 0,985 (0,873 a 1,111) [31,9] | 0,998 (0,929 a 1,072) [31,2] | 1,003 (0,951 a 1,059) [30,8] | 0,997 (0,975 a 1,020) [26,8] | 0,999 (0,972 a 1,026) [26,4] | 1,010 (0,951 a 1,072) [25,4] |
| Cuiabá/MT | 27,2 | 0,943 (0,815 a 1,091) [32,3] | 1,008 (0,928 a 1,094) [30,7] | 1,022 (0,964 a 1,084) [29,7] | 0,996 (0,956 a 1,039) [24,0] | 1,002 (0,944 a 1,064) [21,6] | 1,019 (0,946 a 1,098) [17,2] |
| Sorocaba/SP | 22,4 | 0,971 (0,888 a 1,061) [28,3] | 0,977 (0,931 a 1,026) [27,0] | 0,982 (0,948 a 1,016) [26,2] | 1,012 (0,987 a 1,037) [17,7] | 1,016 (0,988 a 1,044) [16,4] | 1,026 (0,994 a 1,059) [13,3] |
| Campo Grande | 25,3 | 0,944 (0,823 a 1,084) [30,5] | 1,009 (0,942 a 1,081) [28,9] | 1,020 (0,966 a 1,077) [28,2] | 0,999 (0,952 a 1,049) [19,9] | 1,007 (0,952 a 1,066) [17,4] | 1,026 (0,947 a 1,112) [12,6] |

**RR nos p95, p90, p10 e p5 da concentração contra a TMR BLUP (IC 95%; °C entre colchetes):**

| Concentração | p95 | p90 | p10 | p5 |
|---|---|---|---|---|
| São Paulo/SP | 1,016 (0,993 a 1,040) [26,3] | 1,005 (0,992 a 1,019) [25,5] | 1,006 (0,975 a 1,037) [16,6] | 1,008 (0,975 a 1,041) [15,1] |
| Rio de Janeiro/RJ | 1,028 (0,987 a 1,070) [29,6] | 1,021 (0,988 a 1,055) [28,7] | 1,004 (0,990 a 1,018) [20,1] | 1,007 (0,988 a 1,025) [19,1] |
| Belo Horizonte/MG | 1,001 (0,994 a 1,008) [26,6] | 1,001 (0,995 a 1,007) [25,8] | 1,040 (0,998 a 1,083) [19,4] | 1,042 (0,998 a 1,087) [18,5] |
| Brasília/DF | 1,000 (0,995 a 1,006) [26,0] | 1,010 (0,978 a 1,042) [25,1] | 1,057 (0,993 a 1,125) [20,1] | 1,056 (0,991 a 1,126) [19,4] |
| Recife/PE | 1,013 (0,977 a 1,052) [28,8] | 1,001 (0,991 a 1,012) [28,4] | 1,002 (0,955 a 1,052) [24,3] | 1,004 (0,954 a 1,057) [23,9] |
| Porto Alegre/RS | 1,040 (0,974 a 1,111) [28,1] | 1,053 (0,966 a 1,149) [26,9] | 1,096 (0,978 a 1,228) [14,1] | 1,105 (0,981 a 1,245) [12,3] |
| Fortaleza/CE | 1,001 (0,983 a 1,019) [29,6] | 1,004 (0,969 a 1,040) [29,3] | 1,006 (0,945 a 1,070) [26,8] | 1,005 (0,943 a 1,072) [26,4] |
| Curitiba/PR | 1,018 (0,982 a 1,055) [24,9] | 1,003 (0,991 a 1,014) [24,0] | 1,055 (1,000 a 1,112) [13,8] | 1,059 (1,002 a 1,119) [12,3] |
| Salvador/BA | 1,015 (0,959 a 1,074) [28,9] | 1,005 (0,958 a 1,055) [28,5] | 1,000 (0,995 a 1,005) [24,0] | 1,002 (0,986 a 1,018) [23,5] |
| Goiânia/GO | 1,028 (0,964 a 1,096) [28,5] | 1,042 (0,956 a 1,136) [27,6] | 1,056 (0,954 a 1,169) [22,3] | 1,056 (0,954 a 1,169) [21,5] |
| Campinas/SP | 1,003 (0,961 a 1,046) [26,7] | 1,006 (0,950 a 1,064) [26,1] | 1,039 (0,960 a 1,125) [17,9] | 1,042 (0,961 a 1,130) [16,6] |
| Manaus | 1,032 (0,964 a 1,106) [30,5] | 1,041 (0,956 a 1,134) [30,0] | 1,024 (0,924 a 1,134) [26,5] | 1,024 (0,923 a 1,136) [25,9] |
| Belém/PA | 1,009 (0,942 a 1,081) [29,4] | 1,017 (0,930 a 1,111) [29,2] | 1,023 (0,918 a 1,140) [27,1] | 1,021 (0,915 a 1,138) [26,6] |
| Vitória/ES | 1,000 (0,996 a 1,004) [29,0] | 1,001 (0,978 a 1,024) [28,4] | 1,020 (0,960 a 1,085) [21,7] | 1,024 (0,960 a 1,092) [20,9] |
| Baixada Santista/SP | 1,021 (0,978 a 1,065) [28,4] | 1,032 (0,970 a 1,098) [27,5] | 1,060 (0,971 a 1,157) [18,7] | 1,064 (0,973 a 1,163) [17,5] |
| São José dos Campos/SP | 1,021 (0,992 a 1,050) [25,5] | 1,004 (0,993 a 1,015) [24,9] | 1,036 (0,986 a 1,088) [16,9] | 1,038 (0,985 a 1,092) [15,8] |
| São Luís/MA | 1,017 (0,953 a 1,085) [29,8] | 1,015 (0,961 a 1,072) [29,5] | 1,001 (0,996 a 1,006) [26,7] | 1,000 (0,995 a 1,005) [26,2] |
| Natal/RN | 1,010 (0,945 a 1,080) [28,9] | 1,001 (0,947 a 1,059) [28,6] | 1,000 (0,997 a 1,003) [25,3] | 1,000 (0,996 a 1,005) [25,0] |
| Maceió/AL | 1,000 (0,998 a 1,001) [28,3] | 1,002 (0,984 a 1,021) [28,0] | 1,010 (0,950 a 1,073) [24,3] | 1,012 (0,949 a 1,079) [23,9] |
| Florianópolis/SC | 1,010 (0,966 a 1,057) [27,4] | 1,005 (0,976 a 1,035) [26,4] | 1,012 (0,977 a 1,049) [16,5] | 1,016 (0,979 a 1,054) [14,9] |
| João Pessoa/PB | 1,008 (0,945 a 1,076) [29,1] | 1,003 (0,950 a 1,060) [28,8] | 1,000 (0,999 a 1,001) [25,1] | 1,001 (0,994 a 1,007) [24,7] |
| Teresina/PI | 1,013 (0,952 a 1,078) [31,2] | 1,019 (0,932 a 1,113) [30,8] | 1,012 (0,893 a 1,146) [26,8] | 1,014 (0,893 a 1,151) [26,4] |
| Aracaju/SE | 1,000 (0,992 a 1,009) [29,0] | 1,001 (0,994 a 1,008) [28,7] | 1,003 (0,950 a 1,058) [25,0] | 1,005 (0,949 a 1,064) [24,6] |
| Cuiabá/MT | 1,069 (0,974 a 1,172) [30,7] | 1,084 (0,959 a 1,225) [29,7] | 1,057 (0,914 a 1,222) [24,0] | 1,063 (0,917 a 1,232) [21,6] |
| Sorocaba/SP | 1,007 (0,960 a 1,056) [27,0] | 1,011 (0,948 a 1,080) [26,2] | 1,042 (0,951 a 1,142) [17,7] | 1,046 (0,953 a 1,148) [16,4] |
| Campo Grande | 1,068 (0,970 a 1,177) [28,9] | 1,080 (0,959 a 1,217) [28,2] | 1,058 (0,918 a 1,220) [19,9] | 1,066 (0,921 a 1,234) [17,4] |

## C4: lag–resposta combinada (D4(b))

- **Centro:** o °C de cada concentração no percentil da TMR combinada (q_TMR = 0,9378), pela `tmean_nucleo` de 2012–2024. Valor = p99 e p1 de cada concentração (grade da A0). `arglag` comum às 26 (ns com intercepto, nós 0,982; 2,622).
- **Meta-análise:** p99 com reml/unstr; p1 com reml/unstr (mesma fórmula e mesma sequência de estabilidade da C1).
- **Ψ da lag–resposta:** p99: autovalores de Ψ 1.130e-03; 1.388e-04; 2 abaixo de 1e-8 × o maior; posto efetivo 2 de 4 (autovalores acima de 1e-8 × o maior): Ψ singular, só reportado (A1.2; a sequência de estabilidade age só em erro ou não convergência). p1: autovalores de Ψ 3.664e-04; 3 abaixo de 1e-8 × o maior; posto efetivo 1 de 4 (autovalores acima de 1e-8 × o maior): Ψ singular, só reportado (A1.2; a sequência de estabilidade age só em erro ou não convergência).

**Heterogeneidade das duas meta-análises da lag–resposta:**

| Valor | Tipo | Q | gl | p | I² |
|---|---|---|---|---|---|
| p99 | residual | 97,36 |  92 | 0,331 | 5,5% |
| p99 | total | 110,56 | 100 | 0,221 | 9,5% |
| p1 | residual | 70,27 |  92 | 0,955 | 0,0% |
| p1 | total | 81,23 | 100 | 0,915 | 0,0% |

**RR por lag (nos lags inteiros; a curva de 0,1 em 0,1 está no CSV):**

| Lag | RR no p99 | RR no p1 |
|---|---|---|
| 0 | 1,010 (0,999 a 1,021) | 0,978 (0,964 a 0,993) |
| 1 | 1,006 (0,996 a 1,015) | 1,006 (0,996 a 1,015) |
| 2 | 0,998 (0,991 a 1,006) | 1,006 (0,998 a 1,015) |
| 3 | 0,993 (0,986 a 0,999) | 0,998 (0,992 a 1,004) |
| 4 | 0,992 (0,984 a 1,000) | 0,996 (0,989 a 1,003) |
| 5 | 0,996 (0,989 a 1,002) | 1,001 (0,995 a 1,007) |
| 6 | 1,002 (0,997 a 1,007) | 1,009 (1,003 a 1,016) |
| 7 | 1,010 (1,000 a 1,019) | 1,020 (1,009 a 1,031) |

- **Soma dos lags 0–7 (estimando diferente do RR cumulativo da C2):** p99 1,006 (0,982 a 1,031); p1 1,014 (0,984 a 1,046). Ao lado, o RR cumulativo da C2 contra a TMR combinada, na escala do eixo médio: x99 1,003 (0,978 a 1,029); x1 1,020 (0,990 a 1,051).

## Saídas (fora do git)

- `01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds`: `52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e`;
- `01_saidas/fase3/meta_curva_fase3_20261013.csv`: `6958d5083a2b10d9b3449d56d02315eda9cbc4588aa5773c7e8df3af8edfec76`;
- `01_saidas/fase3/blups_fase3_20261013.csv`: `5b38a59e61de47dc18df2ed45106d0d325ae5dc3982d13b0620d3ef3552829c1`;
- `01_saidas/fase3/tmr_fase3_20261013.csv`: `621f1598bba60b6e3862a2bb4b7c3dd2d0ff0ce34dd23d8568f92749a12c8447`;
- `01_saidas/fase3/contrastes_fase3_20261013.csv`: `2a4c634e81ab9f1d336186608e7d5b5444523140a3cfe35c2e56efbcd176db96`;
- `01_saidas/fase3/curva_combinada_fase3_20261013.csv`: `4855ffdb50831e23eeffaa3bd25822afa4f5399e90a5df05184485f5b07cd93d`;
- `01_saidas/fase3/lagresposta_fase3_20261013.csv`: `6a60db902a2e5b5ba679563000216f8e391e0836dc00aac277895b23b84af212`;
- `01_saidas/fase3/lagresposta_meta_fase3_20261013.csv`: `9040effec6722babada664b55505b52175559be4e9cd8e2a58fc2e89515ffeb2`;

`versao()` no fim: 4443971b.
