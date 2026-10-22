# Artigo 1: prematuridade. Fase 3, Parte C: segunda etapa com os dados reais

**Para:** chat do Artigo 1 (prematuridade), via Guilherme. **Antes de qualquer push.**

**Data:** 13/10/2026.

**Base:** `4443971b`, somente leitura. **Prompt:** Fase 3, v1.1 (`docs/coordenacao/PROMPT_artigo1_prematuridade_FASE3_20261013.md`, SHA-256 `953f14d9…`), com o complemento de 13/10 e os desvios 71 a 77; o 77 (escolhas de implementação da Parte C) foi registrado num commit próprio antes de rodar. **Código:** tags `ajusta_dlnm-v1.0` e `segunda_etapa-v1.0` (SHA-256 conferidos), `attrdl.R` `d34c4c30…`.

**Só tabelas, sem leitura nem interpretação causal.** "If causal" fica para a redação. Sensibilidades (inclusive a D3), figuras e texto ficam para as fases 4 a 6.

## 1. Resumo

- **C6, antes de qualquer curva:** a cross-basis remontada é igual à da Fase 2 nas 26 (diferença máxima 0.0e+00; atributos `identical()`).
- **C1:** reml, Ψ unstr; heterogeneidade residual (Q | gl | p | I²): 92,92 | 92 | 0,454 | 1,0%.
- **C2:** TMR combinada 28,2 °C, no percentil 93,8 do eixo médio (q_TMR = 0,9378); IC 95% do bootstrap da D4(a): 18,8 a 29,5 °C; na fronteira: não. RR cumulativo de lag 0–7 contra a TMR combinada: x99 (primário) 1,003 (0,978 a 1,029), em 29,475 °C; x1 (coprimário) 1,020 (0,990 a 1,051), em 18,774 °C.
- **C3:** TMR BLUP na fronteira da grade p1–p99 em 10 concentrações (o `cen` da C5 continua sendo a TMR da grade; D4(g)).
- **C4:** soma dos lags 0–7 (estimando diferente do RR cumulativo): p99 1,006 (0,982 a 1,031); p1 1,014 (0,984 a 1,046).
- **C5 (total das 26; 1.378.030 eventos na janela):** principal 25.362 (12.026 a 37.232) | 1,84% (0,87 a 2,70); ponte 39.516 (20.335 a 54.823) | 2,87% (1,48 a 3,98); *backward* 39.778 (21.787 a 55.852) | 2,89% (1,58 a 4,05) (AN com eCI | AF com eCI).
- **Dupla auditoria:** autoauditoria 42 de 42 iguais; auditoria independente com 6 achados, todos aceitos e corrigidos, e re-auditoria das correções com 3 notas, também aceitas (seção 5). A autoauditoria achou um erro no denominador total do 46 (somava as cinco linhas de componentes de cada concentração), corrigido antes desta RESPOSTA; ver a seção 5.
- **Diagnósticos (só reportados, sem interpretação):** Ψ da C1 com autovalores 2.657e-02; 5.493e-04; 2 abaixo de 1e-8 × o maior; posto efetivo 2 de 4 (singular); extensão do IC da TMR combinada: o IC é a faixa de busca inteira (x1 a x99); 3,5% dos sorteios caem no x1 e 30,9% no x99; IC da TMR BLUP igual à grade p1–p99 inteira em 18 de 26; nas 10 de 26 com TMR BLUP na fronteira, os RR saem também contra a mediana (§7; seção 3, C3).
- **Pendências:** nenhuma desta parte. **Sem push:** esta RESPOSTA vai para o chat antes.

## 2. Conferências e diagnósticos (C6)

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

### C6: cross-basis remontada contra a da Fase 2 (antes de qualquer curva)

- Nas 26 concentrações, a cross-basis pelo caminho da Fase 2 (nós do CSV, fronteiras padrão, 4.505 linhas) e a montada pela `monta_cb` com a `argvar` e a `arglag` da RDS têm o mesmo padrão de NA: sim; diferença máxima nas demais células: 0.0e+00 (critério ≤ 1e-12); atributos `argvar`, `arglag`, `lag`, `range` e `df` das duas `identical()` aos da RDS: sim, nas 26.

## 3. C1 a C4: meta-análise, curva e TMR combinadas, curvas BLUP e lag–resposta

### C1: meta-análise da curva geral

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

### C2: curva combinada e TMR combinada (contraste primário)

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

### C3: curvas BLUP e TMR por concentração

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

### C4: lag–resposta combinada (D4(b))

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

## 4. C5: fração atribuível

- **Linhas:** *forward* (principal e ponte) nas 4.498 linhas da janela; *backward* nas 4.505 linhas, com `ptb` = NA nos 7 dias de aquecimento. `cen` = TMR BLUP da grade p1–p99 de cada concentração, mesmo na fronteira (D4(g)).

### Denominador

- O denominador de cada concentração (eventos da janela principal) é igual ao `n$eventos` da primeira etapa nas três análises: sim, nas 26. Total das 26: 1.378.030 eventos.

| Concentração | i | Denominador |
|---|---|---|
| São Paulo/SP |  1 | 335.025 |
| Rio de Janeiro/RJ |  2 | 182.818 |
| Belo Horizonte/MG |  3 | 74.772 |
| Brasília/DF |  4 | 68.110 |
| Recife/PE |  5 | 66.373 |
| Porto Alegre/RS |  6 | 58.605 |
| Fortaleza/CE |  7 | 62.530 |
| Curitiba/PR |  8 | 45.773 |
| Salvador/BA |  9 | 49.778 |
| Goiânia/GO | 10 | 42.244 |
| Campinas/SP | 11 | 33.354 |
| Manaus | 12 | 45.564 |
| Belém/PA | 13 | 41.518 |
| Vitória/ES | 14 | 27.150 |
| Baixada Santista/SP | 15 | 25.520 |
| São José dos Campos/SP | 16 | 26.377 |
| São Luís/MA | 17 | 29.093 |
| Natal/RN | 18 | 25.665 |
| Maceió/AL | 19 | 22.492 |
| Florianópolis/SC | 20 | 13.943 |
| João Pessoa/PB | 21 | 19.500 |
| Teresina/PI | 22 | 20.111 |
| Aracaju/SE | 23 | 16.618 |
| Cuiabá/MT | 24 | 16.986 |
| Sorocaba/SP | 25 | 13.393 |
| Campo Grande | 26 | 14.718 |

### Total das 26 concentrações

AN = número atribuível (arredondado ao inteiro; estimativa, não contagem, sem a máscara "<10"; D4(d)); AF = AN / total de eventos da janela; eCI 95% pelos percentis 2,5 e 97,5 da soma, sorteio a sorteio, das simulações das 26.

| Análise | Componente | AN (eCI) | AF (eCI) |
|---|---|---|---|
| Principal (forward, BLUPs) | Total | 25.362 (12.026 a 37.232) | 1,84% (0,87 a 2,70) |
| Principal (forward, BLUPs) | Calor | 3.227 (517 a 6.061) | 0,23% (0,04 a 0,44) |
| Principal (forward, BLUPs) | Frio | 22.135 (9.184 a 33.701) | 1,61% (0,67 a 2,45) |
| Principal (forward, BLUPs) | Calor extremo (> p97,5) | 1.037 (369 a 1.650) | 0,08% (0,03 a 0,12) |
| Principal (forward, BLUPs) | Frio extremo (< p2,5) | 982 (463 a 1.457) | 0,07% (0,03 a 0,11) |
| Ponte (forward, reduzidos da primeira etapa; diagnóstico) | Total | 39.516 (20.335 a 54.823) | 2,87% (1,48 a 3,98) |
| Ponte (forward, reduzidos da primeira etapa; diagnóstico) | Calor | 5.276 (587 a 9.817) | 0,38% (0,04 a 0,71) |
| Ponte (forward, reduzidos da primeira etapa; diagnóstico) | Frio | 34.240 (15.192 a 48.179) | 2,48% (1,10 a 3,50) |
| Ponte (forward, reduzidos da primeira etapa; diagnóstico) | Calor extremo (> p97,5) | 1.349 (627 a 1.951) | 0,10% (0,05 a 0,14) |
| Ponte (forward, reduzidos da primeira etapa; diagnóstico) | Frio extremo (< p2,5) | 1.174 (218 a 1.898) | 0,09% (0,02 a 0,14) |
| Sensibilidade (backward, 16 coeficientes da primeira etapa) | Total | 39.778 (21.787 a 55.852) | 2,89% (1,58 a 4,05) |
| Sensibilidade (backward, 16 coeficientes da primeira etapa) | Calor | 5.360 (480 a 9.511) | 0,39% (0,03 a 0,69) |
| Sensibilidade (backward, 16 coeficientes da primeira etapa) | Frio | 34.422 (16.127 a 49.964) | 2,50% (1,17 a 3,63) |
| Sensibilidade (backward, 16 coeficientes da primeira etapa) | Calor extremo (> p97,5) | 1.407 (648 a 1.995) | 0,10% (0,05 a 0,14) |
| Sensibilidade (backward, 16 coeficientes da primeira etapa) | Frio extremo (< p2,5) | 1.222 (215 a 2.026) | 0,09% (0,02 a 0,15) |

**Leitura das três análises (D1, item 3; sem leitura inferencial da ponte):** principal × ponte isola o efeito do encolhimento; ponte × *backward*, o da perspectiva.

### Por concentração


#### Principal (forward, BLUPs)

**AN por componente e AF do total (eCI):**

| Concentração | i | AN total (eCI) | AF total (eCI) | Calor | Frio | Calor extremo | Frio extremo |
|---|---|---|---|---|---|---|---|
| São Paulo/SP |  1 | 1.603 (-2.858 a 5.790) | 0,48% (-0,85 a 1,73) | 877 (-290 a 2.040) | 725 (-3.999 a 4.955) | 469 (-33 a 937) | 91 (-187 a 382) |
| Rio de Janeiro/RJ |  2 | 1.326 (-417 a 3.049) | 0,73% (-0,23 a 1,67) | 1.135 (-872 a 3.022) | 191 (-438 a 793) | 200 (-172 a 552) | 50 (-96 a 202) |
| Belo Horizonte/MG |  3 | 1.758 (-36 a 3.642) | 2,35% (-0,05 a 4,87) | 46 (-72 a 159) | 1.711 (-159 a 3.642) | 40 (-46 a 118) | 83 (-1 a 173) |
| Brasília/DF |  4 | 3.007 (-343 a 5.983) | 4,41% (-0,50 a 8,78) | 13 (-83 a 101) | 2.994 (-402 a 6.045) | 12 (-70 a 86) | 102 (-25 a 214) |
| Recife/PE |  5 | 406 (-1.479 a 2.058) | 0,61% (-2,23 a 3,10) | 114 (-176 a 375) | 292 (-1.620 a 2.011) | 66 (-76 a 189) | 17 (-106 a 120) |
| Porto Alegre/RS |  6 | 3.724 (-1.738 a 8.854) | 6,35% (-2,96 a 15,11) | -14 (-39 a 8) | 3.738 (-1.741 a 8.891) | -14 (-39 a 8) | 159 (-31 a 353) |
| Fortaleza/CE |  7 | 609 (-2.785 a 4.091) | 0,97% (-4,45 a 6,54) | 2 (-32 a 32) | 608 (-2.788 a 4.090) | 2 (-32 a 32) | 21 (-108 a 153) |
| Curitiba/PR |  8 | 1.355 (32 a 2.727) | 2,96% (0,07 a 5,96) | 134 (-99 a 348) | 1.221 (-85 a 2.628) | 80 (-47 a 189) | 71 (-5 a 146) |
| Salvador/BA |  9 | 257 (-828 a 1.288) | 0,52% (-1,66 a 2,59) | 243 (-820 a 1.278) | 14 (-107 a 140) | 69 (-71 a 188) | 8 (-53 a 75) |
| Goiânia/GO | 10 | 2.190 (-1.938 a 5.716) | 5,18% (-4,59 a 13,53) | -3 (-10 a 4) | 2.193 (-1.942 a 5.726) | -3 (-10 a 4) | 60 (-47 a 156) |
| Campinas/SP | 11 | 818 (-1.572 a 2.906) | 2,45% (-4,71 a 8,71) | 0 (-11 a 11) | 818 (-1.580 a 2.916) | 0 (-11 a 11) | 42 (-34 a 104) |
| Manaus | 12 | 1.581 (-2.448 a 5.468) | 3,47% (-5,37 a 12,00) | -6 (-18 a 6) | 1.586 (-2.450 a 5.482) | -6 (-18 a 6) | 37 (-93 a 151) |
| Belém/PA | 13 | 1.120 (-3.473 a 4.905) | 2,70% (-8,37 a 11,81) | 0 (-5 a 4) | 1.120 (-3.478 a 4.909) | 0 (-5 a 4) | 29 (-100 a 134) |
| Vitória/ES | 14 | 326 (-906 a 1.396) | 1,20% (-3,34 a 5,14) | 1 (-41 a 45) | 325 (-927 a 1.418) | 1 (-37 a 40) | 21 (-32 a 65) |
| Baixada Santista/SP | 15 | 1.158 (-796 a 2.871) | 4,54% (-3,12 a 11,25) | -3 (-10 a 4) | 1.161 (-799 a 2.880) | -3 (-10 a 4) | 39 (-11 a 86) |
| São José dos Campos/SP | 16 | 551 (-55 a 1.173) | 2,09% (-0,21 a 4,45) | 91 (-21 a 187) | 460 (-169 a 1.118) | 53 (-3 a 99) | 23 (-18 a 64) |
| São Luís/MA | 17 | 333 (-463 a 1.118) | 1,14% (-1,59 a 3,84) | 324 (-450 a 1.097) | 9 (-37 a 58) | 16 (-62 a 86) | 8 (-28 a 45) |
| Natal/RN | 18 | 135 (-558 a 828) | 0,53% (-2,18 a 3,23) | 132 (-565 a 825) | 4 (-30 a 38) | 29 (-39 a 95) | 3 (-22 a 29) |
| Maceió/AL | 19 | 270 (-618 a 1.121) | 1,20% (-2,75 a 4,99) | 7 (-40 a 48) | 263 (-672 a 1.147) | 7 (-35 a 43) | 12 (-31 a 56) |
| Florianópolis/SC | 20 | 78 (-122 a 257) | 0,56% (-0,87 a 1,85) | 24 (-91 a 135) | 54 (-136 a 242) | 10 (-27 a 44) | 7 (-8 a 21) |
| João Pessoa/PB | 21 | 121 (-438 a 627) | 0,62% (-2,25 a 3,21) | 117 (-442 a 637) | 4 (-23 a 31) | 16 (-46 a 71) | 3 (-15 a 21) |
| Teresina/PI | 22 | 307 (-2.037 a 2.425) | 1,53% (-10,13 a 12,06) | -1 (-7 a 4) | 308 (-2.040 a 2.432) | -1 (-7 a 4) | 12 (-67 a 78) |
| Aracaju/SE | 23 | 90 (-430 a 569) | 0,54% (-2,59 a 3,43) | 5 (-31 a 36) | 84 (-440 a 577) | 5 (-23 a 28) | 5 (-24 a 32) |
| Cuiabá/MT | 24 | 1.011 (-1.129 a 2.990) | 5,95% (-6,64 a 17,60) | -5 (-12 a 1) | 1.016 (-1.129 a 3.002) | -5 (-12 a 1) | 31 (-35 a 90) |
| Sorocaba/SP | 25 | 373 (-644 a 1.432) | 2,79% (-4,80 a 10,69) | 0 (-6 a 4) | 374 (-649 a 1.436) | 0 (-6 a 4) | 18 (-14 a 49) |
| Campo Grande | 26 | 857 (-1.059 a 2.448) | 5,82% (-7,19 a 16,63) | -6 (-14 a 2) | 863 (-1.062 a 2.462) | -6 (-14 a 2) | 29 (-32 a 79) |

**AF por componente (eCI):**

| Concentração | Total | Calor | Frio | Calor extremo | Frio extremo |
|---|---|---|---|---|---|
| São Paulo/SP | 0,48% (-0,85 a 1,73) | 0,26% (-0,09 a 0,61) | 0,22% (-1,19 a 1,48) | 0,14% (-0,01 a 0,28) | 0,03% (-0,06 a 0,11) |
| Rio de Janeiro/RJ | 0,73% (-0,23 a 1,67) | 0,62% (-0,48 a 1,65) | 0,10% (-0,24 a 0,43) | 0,11% (-0,09 a 0,30) | 0,03% (-0,05 a 0,11) |
| Belo Horizonte/MG | 2,35% (-0,05 a 4,87) | 0,06% (-0,10 a 0,21) | 2,29% (-0,21 a 4,87) | 0,05% (-0,06 a 0,16) | 0,11% (0,00 a 0,23) |
| Brasília/DF | 4,41% (-0,50 a 8,78) | 0,02% (-0,12 a 0,15) | 4,40% (-0,59 a 8,88) | 0,02% (-0,10 a 0,13) | 0,15% (-0,04 a 0,31) |
| Recife/PE | 0,61% (-2,23 a 3,10) | 0,17% (-0,27 a 0,57) | 0,44% (-2,44 a 3,03) | 0,10% (-0,11 a 0,28) | 0,03% (-0,16 a 0,18) |
| Porto Alegre/RS | 6,35% (-2,96 a 15,11) | -0,02% (-0,07 a 0,01) | 6,38% (-2,97 a 15,17) | -0,02% (-0,07 a 0,01) | 0,27% (-0,05 a 0,60) |
| Fortaleza/CE | 0,97% (-4,45 a 6,54) | 0,00% (-0,05 a 0,05) | 0,97% (-4,46 a 6,54) | 0,00% (-0,05 a 0,05) | 0,03% (-0,17 a 0,24) |
| Curitiba/PR | 2,96% (0,07 a 5,96) | 0,29% (-0,22 a 0,76) | 2,67% (-0,18 a 5,74) | 0,17% (-0,10 a 0,41) | 0,16% (-0,01 a 0,32) |
| Salvador/BA | 0,52% (-1,66 a 2,59) | 0,49% (-1,65 a 2,57) | 0,03% (-0,22 a 0,28) | 0,14% (-0,14 a 0,38) | 0,02% (-0,11 a 0,15) |
| Goiânia/GO | 5,18% (-4,59 a 13,53) | -0,01% (-0,02 a 0,01) | 5,19% (-4,60 a 13,56) | -0,01% (-0,02 a 0,01) | 0,14% (-0,11 a 0,37) |
| Campinas/SP | 2,45% (-4,71 a 8,71) | 0,00% (-0,03 a 0,03) | 2,45% (-4,74 a 8,74) | 0,00% (-0,03 a 0,03) | 0,12% (-0,10 a 0,31) |
| Manaus | 3,47% (-5,37 a 12,00) | -0,01% (-0,04 a 0,01) | 3,48% (-5,38 a 12,03) | -0,01% (-0,04 a 0,01) | 0,08% (-0,20 a 0,33) |
| Belém/PA | 2,70% (-8,37 a 11,81) | 0,00% (-0,01 a 0,01) | 2,70% (-8,38 a 11,82) | 0,00% (-0,01 a 0,01) | 0,07% (-0,24 a 0,32) |
| Vitória/ES | 1,20% (-3,34 a 5,14) | 0,00% (-0,15 a 0,16) | 1,20% (-3,41 a 5,22) | 0,00% (-0,14 a 0,15) | 0,08% (-0,12 a 0,24) |
| Baixada Santista/SP | 4,54% (-3,12 a 11,25) | -0,01% (-0,04 a 0,01) | 4,55% (-3,13 a 11,29) | -0,01% (-0,04 a 0,01) | 0,15% (-0,04 a 0,34) |
| São José dos Campos/SP | 2,09% (-0,21 a 4,45) | 0,35% (-0,08 a 0,71) | 1,74% (-0,64 a 4,24) | 0,20% (-0,01 a 0,37) | 0,09% (-0,07 a 0,24) |
| São Luís/MA | 1,14% (-1,59 a 3,84) | 1,11% (-1,55 a 3,77) | 0,03% (-0,13 a 0,20) | 0,05% (-0,21 a 0,29) | 0,03% (-0,10 a 0,15) |
| Natal/RN | 0,53% (-2,18 a 3,23) | 0,51% (-2,20 a 3,22) | 0,01% (-0,12 a 0,15) | 0,11% (-0,15 a 0,37) | 0,01% (-0,09 a 0,11) |
| Maceió/AL | 1,20% (-2,75 a 4,99) | 0,03% (-0,18 a 0,21) | 1,17% (-2,99 a 5,10) | 0,03% (-0,16 a 0,19) | 0,05% (-0,14 a 0,25) |
| Florianópolis/SC | 0,56% (-0,87 a 1,85) | 0,18% (-0,65 a 0,97) | 0,39% (-0,97 a 1,73) | 0,07% (-0,19 a 0,31) | 0,05% (-0,06 a 0,15) |
| João Pessoa/PB | 0,62% (-2,25 a 3,21) | 0,60% (-2,27 a 3,27) | 0,02% (-0,12 a 0,16) | 0,08% (-0,23 a 0,36) | 0,02% (-0,08 a 0,11) |
| Teresina/PI | 1,53% (-10,13 a 12,06) | -0,01% (-0,03 a 0,02) | 1,53% (-10,14 a 12,09) | -0,01% (-0,03 a 0,02) | 0,06% (-0,33 a 0,39) |
| Aracaju/SE | 0,54% (-2,59 a 3,43) | 0,03% (-0,18 a 0,22) | 0,51% (-2,65 a 3,47) | 0,03% (-0,14 a 0,17) | 0,03% (-0,14 a 0,19) |
| Cuiabá/MT | 5,95% (-6,64 a 17,60) | -0,03% (-0,07 a 0,01) | 5,98% (-6,65 a 17,67) | -0,03% (-0,07 a 0,01) | 0,18% (-0,21 a 0,53) |
| Sorocaba/SP | 2,79% (-4,80 a 10,69) | 0,00% (-0,04 a 0,03) | 2,79% (-4,84 a 10,72) | 0,00% (-0,04 a 0,03) | 0,13% (-0,10 a 0,36) |
| Campo Grande | 5,82% (-7,19 a 16,63) | -0,04% (-0,10 a 0,01) | 5,86% (-7,22 a 16,73) | -0,04% (-0,10 a 0,01) | 0,20% (-0,22 a 0,53) |

#### Ponte (forward, reduzidos da primeira etapa; diagnóstico)

**AN por componente e AF do total (eCI):**

| Concentração | i | AN total (eCI) | AF total (eCI) | Calor | Frio | Calor extremo | Frio extremo |
|---|---|---|---|---|---|---|---|
| São Paulo/SP |  1 | 512 (-3.508 a 3.803) | 0,15% (-1,05 a 1,14) | 927 (77 a 1.688) | -415 (-4.229 a 2.935) | 470 (134 a 817) | -68 (-426 a 256) |
| Rio de Janeiro/RJ |  2 | 2.204 (143 a 4.228) | 1,21% (0,08 a 2,31) | 1.785 (-302 a 3.691) | 418 (-515 a 1.356) | 219 (-144 a 514) | 58 (-189 a 318) |
| Belo Horizonte/MG |  3 | 3.009 (426 a 5.549) | 4,02% (0,57 a 7,42) | 100 (-74 a 252) | 2.909 (373 a 5.396) | 83 (-50 a 198) | 123 (-41 a 276) |
| Brasília/DF |  4 | 3.802 (214 a 6.986) | 5,58% (0,31 a 10,26) | -83 (-229 a 39) | 3.884 (299 a 7.054) | -70 (-198 a 35) | 104 (-74 a 264) |
| Recife/PE |  5 | 268 (-3.150 a 3.549) | 0,40% (-4,75 a 5,35) | 189 (-154 a 518) | 79 (-3.197 a 3.386) | 98 (-78 a 255) | 66 (-164 a 266) |
| Porto Alegre/RS |  6 | 5.283 (715 a 9.577) | 9,01% (1,22 a 16,34) | -22 (-54 a 4) | 5.305 (726 a 9.632) | -22 (-54 a 4) | 189 (1 a 356) |
| Fortaleza/CE |  7 | 745 (-4.692 a 5.562) | 1,19% (-7,50 a 8,90) | -5 (-94 a 66) | 750 (-4.731 a 5.563) | -5 (-93 a 65) | 53 (-199 a 275) |
| Curitiba/PR |  8 | 2.352 (303 a 4.151) | 5,14% (0,66 a 9,07) | 216 (-13 a 422) | 2.136 (231 a 3.844) | 132 (7 a 238) | 126 (-15 a 253) |
| Salvador/BA |  9 | 607 (-1.866 a 2.866) | 1,22% (-3,75 a 5,76) | 680 (-1.773 a 2.988) | -73 (-402 a 249) | 138 (-53 a 296) | -32 (-194 a 129) |
| Goiânia/GO | 10 | 4.002 (-1.022 a 8.821) | 9,47% (-2,42 a 20,88) | -5 (-22 a 10) | 4.007 (-1.028 a 8.844) | -5 (-22 a 10) | 98 (-76 a 251) |
| Campinas/SP | 11 | 2.197 (-954 a 5.223) | 6,59% (-2,86 a 15,66) | -15 (-44 a 10) | 2.211 (-961 a 5.258) | -15 (-44 a 10) | 128 (16 a 232) |
| Manaus | 12 | 3.069 (-2.967 a 7.799) | 6,73% (-6,51 a 17,12) | -9 (-35 a 15) | 3.078 (-2.959 a 7.818) | -9 (-35 a 15) | 138 (-76 a 310) |
| Belém/PA | 13 | 4.888 (-2.754 a 10.907) | 11,77% (-6,63 a 26,27) | -6 (-21 a 7) | 4.894 (-2.759 a 10.919) | -6 (-21 a 7) | 11 (-290 a 234) |
| Vitória/ES | 14 | 790 (-1.172 a 2.492) | 2,91% (-4,32 a 9,18) | 38 (-57 a 127) | 752 (-1.258 a 2.483) | 35 (-52 a 114) | 81 (-29 a 174) |
| Baixada Santista/SP | 15 | 1.775 (-1.492 a 4.525) | 6,96% (-5,85 a 17,73) | 4 (-17 a 22) | 1.772 (-1.511 a 4.536) | 4 (-17 a 22) | 18 (-109 a 115) |
| São José dos Campos/SP | 16 | 959 (-430 a 2.293) | 3,64% (-1,63 a 8,69) | 206 (52 a 355) | 753 (-586 a 2.126) | 106 (20 a 187) | 37 (-66 a 127) |
| São Luís/MA | 17 | 858 (-1.127 a 2.661) | 2,95% (-3,87 a 9,15) | 838 (-1.121 a 2.632) | 19 (-154 a 161) | 46 (-86 a 153) | 17 (-120 a 126) |
| Natal/RN | 18 | 300 (-1.875 a 2.189) | 1,17% (-7,31 a 8,53) | 376 (-1.812 a 2.289) | -76 (-239 a 60) | 95 (-37 a 203) | -57 (-187 a 45) |
| Maceió/AL | 19 | -115 (-2.190 a 1.680) | -0,51% (-9,74 a 7,47) | -30 (-140 a 55) | -85 (-2.191 a 1.694) | -26 (-127 a 51) | 11 (-136 a 124) |
| Florianópolis/SC | 20 | -348 (-1.160 a 355) | -2,50% (-8,32 a 2,55) | 216 (-121 a 497) | -563 (-1.338 a 142) | 50 (-31 a 112) | 4 (-73 a 64) |
| João Pessoa/PB | 21 | -107 (-1.979 a 1.606) | -0,55% (-10,15 a 8,24) | -135 (-1.984 a 1.587) | 27 (-114 a 150) | 25 (-102 a 123) | 16 (-84 a 96) |
| Teresina/PI | 22 | -284 (-4.902 a 3.627) | -1,41% (-24,38 a 18,04) | 6 (-9 a 18) | -289 (-4.922 a 3.641) | 6 (-9 a 18) | -34 (-213 a 92) |
| Aracaju/SE | 23 | 19 (-1.804 a 1.404) | 0,12% (-10,85 a 8,45) | 16 (-99 a 95) | 3 (-1.784 a 1.396) | 12 (-86 a 74) | 8 (-106 a 100) |
| Cuiabá/MT | 24 | 861 (-2.429 a 3.747) | 5,07% (-14,30 a 22,06) | -4 (-18 a 7) | 865 (-2.435 a 3.760) | -4 (-18 a 7) | 40 (-75 a 126) |
| Sorocaba/SP | 25 | 1.283 (-949 a 2.988) | 9,58% (-7,08 a 22,31) | -5 (-25 a 11) | 1.288 (-954 a 2.995) | -5 (-25 a 11) | 34 (-56 a 100) |
| Campo Grande | 26 | 586 (-1.959 a 2.880) | 3,98% (-13,31 a 19,57) | -3 (-18 a 11) | 589 (-1.971 a 2.892) | -3 (-18 a 11) | 6 (-94 a 84) |

**AF por componente (eCI):**

| Concentração | Total | Calor | Frio | Calor extremo | Frio extremo |
|---|---|---|---|---|---|
| São Paulo/SP | 0,15% (-1,05 a 1,14) | 0,28% (0,02 a 0,50) | -0,12% (-1,26 a 0,88) | 0,14% (0,04 a 0,24) | -0,02% (-0,13 a 0,08) |
| Rio de Janeiro/RJ | 1,21% (0,08 a 2,31) | 0,98% (-0,17 a 2,02) | 0,23% (-0,28 a 0,74) | 0,12% (-0,08 a 0,28) | 0,03% (-0,10 a 0,17) |
| Belo Horizonte/MG | 4,02% (0,57 a 7,42) | 0,13% (-0,10 a 0,34) | 3,89% (0,50 a 7,22) | 0,11% (-0,07 a 0,27) | 0,16% (-0,06 a 0,37) |
| Brasília/DF | 5,58% (0,31 a 10,26) | -0,12% (-0,34 a 0,06) | 5,70% (0,44 a 10,36) | -0,10% (-0,29 a 0,05) | 0,15% (-0,11 a 0,39) |
| Recife/PE | 0,40% (-4,75 a 5,35) | 0,28% (-0,23 a 0,78) | 0,12% (-4,82 a 5,10) | 0,15% (-0,12 a 0,38) | 0,10% (-0,25 a 0,40) |
| Porto Alegre/RS | 9,01% (1,22 a 16,34) | -0,04% (-0,09 a 0,01) | 9,05% (1,24 a 16,43) | -0,04% (-0,09 a 0,01) | 0,32% (0,00 a 0,61) |
| Fortaleza/CE | 1,19% (-7,50 a 8,90) | -0,01% (-0,15 a 0,11) | 1,20% (-7,57 a 8,90) | -0,01% (-0,15 a 0,10) | 0,08% (-0,32 a 0,44) |
| Curitiba/PR | 5,14% (0,66 a 9,07) | 0,47% (-0,03 a 0,92) | 4,67% (0,51 a 8,40) | 0,29% (0,02 a 0,52) | 0,28% (-0,03 a 0,55) |
| Salvador/BA | 1,22% (-3,75 a 5,76) | 1,37% (-3,56 a 6,00) | -0,15% (-0,81 a 0,50) | 0,28% (-0,11 a 0,60) | -0,06% (-0,39 a 0,26) |
| Goiânia/GO | 9,47% (-2,42 a 20,88) | -0,01% (-0,05 a 0,02) | 9,49% (-2,43 a 20,94) | -0,01% (-0,05 a 0,02) | 0,23% (-0,18 a 0,60) |
| Campinas/SP | 6,59% (-2,86 a 15,66) | -0,04% (-0,13 a 0,03) | 6,63% (-2,88 a 15,76) | -0,04% (-0,13 a 0,03) | 0,38% (0,05 a 0,69) |
| Manaus | 6,73% (-6,51 a 17,12) | -0,02% (-0,08 a 0,03) | 6,75% (-6,49 a 17,16) | -0,02% (-0,08 a 0,03) | 0,30% (-0,17 a 0,68) |
| Belém/PA | 11,77% (-6,63 a 26,27) | -0,01% (-0,05 a 0,02) | 11,79% (-6,65 a 26,30) | -0,01% (-0,05 a 0,02) | 0,03% (-0,70 a 0,56) |
| Vitória/ES | 2,91% (-4,32 a 9,18) | 0,14% (-0,21 a 0,47) | 2,77% (-4,64 a 9,15) | 0,13% (-0,19 a 0,42) | 0,30% (-0,11 a 0,64) |
| Baixada Santista/SP | 6,96% (-5,85 a 17,73) | 0,01% (-0,07 a 0,09) | 6,94% (-5,92 a 17,77) | 0,01% (-0,07 a 0,09) | 0,07% (-0,43 a 0,45) |
| São José dos Campos/SP | 3,64% (-1,63 a 8,69) | 0,78% (0,20 a 1,35) | 2,86% (-2,22 a 8,06) | 0,40% (0,08 a 0,71) | 0,14% (-0,25 a 0,48) |
| São Luís/MA | 2,95% (-3,87 a 9,15) | 2,88% (-3,85 a 9,05) | 0,07% (-0,53 a 0,55) | 0,16% (-0,30 a 0,53) | 0,06% (-0,41 a 0,43) |
| Natal/RN | 1,17% (-7,31 a 8,53) | 1,47% (-7,06 a 8,92) | -0,30% (-0,93 a 0,23) | 0,37% (-0,14 a 0,79) | -0,22% (-0,73 a 0,17) |
| Maceió/AL | -0,51% (-9,74 a 7,47) | -0,13% (-0,62 a 0,25) | -0,38% (-9,74 a 7,53) | -0,11% (-0,56 a 0,23) | 0,05% (-0,61 a 0,55) |
| Florianópolis/SC | -2,50% (-8,32 a 2,55) | 1,55% (-0,87 a 3,57) | -4,04% (-9,60 a 1,02) | 0,36% (-0,22 a 0,80) | 0,03% (-0,52 a 0,46) |
| João Pessoa/PB | -0,55% (-10,15 a 8,24) | -0,69% (-10,17 a 8,14) | 0,14% (-0,58 a 0,77) | 0,13% (-0,52 a 0,63) | 0,08% (-0,43 a 0,49) |
| Teresina/PI | -1,41% (-24,38 a 18,04) | 0,03% (-0,04 a 0,09) | -1,44% (-24,48 a 18,10) | 0,03% (-0,04 a 0,09) | -0,17% (-1,06 a 0,46) |
| Aracaju/SE | 0,12% (-10,85 a 8,45) | 0,10% (-0,59 a 0,57) | 0,02% (-10,74 a 8,40) | 0,07% (-0,52 a 0,44) | 0,05% (-0,64 a 0,60) |
| Cuiabá/MT | 5,07% (-14,30 a 22,06) | -0,03% (-0,10 a 0,04) | 5,09% (-14,34 a 22,14) | -0,03% (-0,10 a 0,04) | 0,24% (-0,44 a 0,74) |
| Sorocaba/SP | 9,58% (-7,08 a 22,31) | -0,04% (-0,19 a 0,08) | 9,62% (-7,12 a 22,37) | -0,04% (-0,19 a 0,08) | 0,25% (-0,42 a 0,75) |
| Campo Grande | 3,98% (-13,31 a 19,57) | -0,02% (-0,13 a 0,07) | 4,00% (-13,39 a 19,65) | -0,02% (-0,13 a 0,07) | 0,04% (-0,64 a 0,57) |

#### Sensibilidade (backward, 16 coeficientes da primeira etapa)

**AN por componente e AF do total (eCI):**

| Concentração | i | AN total (eCI) | AF total (eCI) | Calor | Frio | Calor extremo | Frio extremo |
|---|---|---|---|---|---|---|---|
| São Paulo/SP |  1 | 522 (-3.357 a 4.054) | 0,16% (-1,00 a 1,21) | 936 (54 a 1.742) | -414 (-4.176 a 3.283) | 479 (111 a 822) | -65 (-414 a 305) |
| Rio de Janeiro/RJ |  2 | 2.213 (158 a 4.288) | 1,21% (0,09 a 2,35) | 1.793 (-111 a 3.793) | 421 (-524 a 1.371) | 220 (-157 a 546) | 59 (-203 a 316) |
| Belo Horizonte/MG |  3 | 3.024 (394 a 5.622) | 4,04% (0,53 a 7,52) | 107 (-57 a 260) | 2.918 (315 a 5.476) | 91 (-34 a 209) | 125 (-51 a 282) |
| Brasília/DF |  4 | 3.814 (497 a 7.181) | 5,60% (0,73 a 10,54) | -80 (-209 a 49) | 3.894 (570 a 7.286) | -68 (-180 a 43) | 105 (-63 a 284) |
| Recife/PE |  5 | 275 (-2.939 a 3.328) | 0,41% (-4,43 a 5,01) | 192 (-171 a 511) | 84 (-3.164 a 3.186) | 102 (-81 a 275) | 65 (-185 a 266) |
| Porto Alegre/RS |  6 | 5.296 (-170 a 9.675) | 9,04% (-0,29 a 16,51) | -21 (-48 a 8) | 5.316 (-167 a 9.726) | -21 (-48 a 8) | 198 (4 a 379) |
| Fortaleza/CE |  7 | 751 (-3.801 a 5.289) | 1,20% (-6,08 a 8,46) | -3 (-86 a 63) | 755 (-3.817 a 5.352) | -3 (-85 a 62) | 51 (-189 a 292) |
| Curitiba/PR |  8 | 2.366 (375 a 4.250) | 5,17% (0,82 a 9,28) | 221 (-8 a 443) | 2.147 (207 a 3.944) | 137 (10 a 262) | 132 (-21 a 271) |
| Salvador/BA |  9 | 616 (-1.862 a 2.822) | 1,24% (-3,74 a 5,67) | 685 (-1.797 a 2.872) | -70 (-384 a 229) | 144 (-43 a 304) | -30 (-191 a 120) |
| Goiânia/GO | 10 | 4.013 (-2.049 a 8.776) | 9,50% (-4,85 a 20,77) | -4 (-20 a 12) | 4.018 (-2.062 a 8.788) | -4 (-20 a 12) | 98 (-85 a 259) |
| Campinas/SP | 11 | 2.202 (-794 a 5.140) | 6,60% (-2,38 a 15,41) | -14 (-39 a 11) | 2.216 (-816 a 5.182) | -14 (-39 a 11) | 133 (1 a 250) |
| Manaus | 12 | 3.088 (-2.879 a 8.020) | 6,78% (-6,32 a 17,60) | -8 (-34 a 15) | 3.097 (-2.883 a 8.040) | -8 (-34 a 15) | 143 (-64 a 354) |
| Belém/PA | 13 | 4.908 (-3.108 a 11.263) | 11,82% (-7,48 a 27,13) | -7 (-20 a 6) | 4.914 (-3.108 a 11.277) | -7 (-20 a 6) | 11 (-247 a 246) |
| Vitória/ES | 14 | 796 (-1.185 a 2.611) | 2,93% (-4,36 a 9,62) | 39 (-62 a 140) | 757 (-1.235 a 2.558) | 36 (-57 a 127) | 85 (-32 a 191) |
| Baixada Santista/SP | 15 | 1.793 (-1.341 a 4.610) | 7,03% (-5,26 a 18,06) | 4 (-18 a 23) | 1.790 (-1.366 a 4.620) | 4 (-18 a 23) | 22 (-94 a 120) |
| São José dos Campos/SP | 16 | 970 (-476 a 2.203) | 3,68% (-1,81 a 8,35) | 213 (39 a 361) | 757 (-627 a 1.966) | 113 (8 a 195) | 39 (-65 a 131) |
| São Luís/MA | 17 | 865 (-1.073 a 2.647) | 2,97% (-3,69 a 9,10) | 845 (-1.083 a 2.521) | 21 (-145 a 183) | 45 (-82 a 151) | 18 (-113 a 145) |
| Natal/RN | 18 | 317 (-1.783 a 2.385) | 1,23% (-6,95 a 9,29) | 389 (-1.652 a 2.417) | -74 (-214 a 68) | 97 (-45 a 223) | -55 (-161 a 53) |
| Maceió/AL | 19 | -108 (-2.144 a 1.781) | -0,48% (-9,53 a 7,92) | -27 (-126 a 61) | -82 (-2.144 a 1.782) | -23 (-113 a 55) | 11 (-135 a 144) |
| Florianópolis/SC | 20 | -337 (-1.092 a 380) | -2,42% (-7,83 a 2,72) | 219 (-101 a 500) | -557 (-1.262 a 90) | 53 (-33 a 130) | 6 (-70 a 72) |
| João Pessoa/PB | 21 | -105 (-1.927 a 1.486) | -0,54% (-9,88 a 7,62) | -134 (-1.949 a 1.409) | 28 (-101 a 157) | 25 (-97 a 134) | 17 (-70 a 104) |
| Teresina/PI | 22 | -272 (-5.072 a 3.627) | -1,35% (-25,22 a 18,03) | 6 (-8 a 19) | -278 (-5.096 a 3.630) | 6 (-8 a 19) | -35 (-181 a 100) |
| Aracaju/SE | 23 | 26 (-1.843 a 1.493) | 0,16% (-11,09 a 8,98) | 18 (-83 a 102) | 9 (-1.859 a 1.459) | 13 (-71 a 80) | 9 (-114 a 114) |
| Cuiabá/MT | 24 | 867 (-2.331 a 3.492) | 5,10% (-13,72 a 20,56) | -1 (-13 a 11) | 868 (-2.338 a 3.501) | -1 (-13 a 11) | 40 (-78 a 137) |
| Sorocaba/SP | 25 | 1.288 (-724 a 2.946) | 9,62% (-5,41 a 22,00) | -5 (-23 a 9) | 1.294 (-732 a 2.962) | -5 (-23 a 9) | 35 (-56 a 111) |
| Campo Grande | 26 | 591 (-2.009 a 2.963) | 4,02% (-13,65 a 20,13) | -2 (-18 a 11) | 594 (-2.007 a 2.984) | -2 (-18 a 11) | 6 (-93 a 92) |

**AF por componente (eCI):**

| Concentração | Total | Calor | Frio | Calor extremo | Frio extremo |
|---|---|---|---|---|---|
| São Paulo/SP | 0,16% (-1,00 a 1,21) | 0,28% (0,02 a 0,52) | -0,12% (-1,25 a 0,98) | 0,14% (0,03 a 0,25) | -0,02% (-0,12 a 0,09) |
| Rio de Janeiro/RJ | 1,21% (0,09 a 2,35) | 0,98% (-0,06 a 2,07) | 0,23% (-0,29 a 0,75) | 0,12% (-0,09 a 0,30) | 0,03% (-0,11 a 0,17) |
| Belo Horizonte/MG | 4,04% (0,53 a 7,52) | 0,14% (-0,08 a 0,35) | 3,90% (0,42 a 7,32) | 0,12% (-0,04 a 0,28) | 0,17% (-0,07 a 0,38) |
| Brasília/DF | 5,60% (0,73 a 10,54) | -0,12% (-0,31 a 0,07) | 5,72% (0,84 a 10,70) | -0,10% (-0,26 a 0,06) | 0,15% (-0,09 a 0,42) |
| Recife/PE | 0,41% (-4,43 a 5,01) | 0,29% (-0,26 a 0,77) | 0,13% (-4,77 a 4,80) | 0,15% (-0,12 a 0,41) | 0,10% (-0,28 a 0,40) |
| Porto Alegre/RS | 9,04% (-0,29 a 16,51) | -0,04% (-0,08 a 0,01) | 9,07% (-0,29 a 16,60) | -0,04% (-0,08 a 0,01) | 0,34% (0,01 a 0,65) |
| Fortaleza/CE | 1,20% (-6,08 a 8,46) | -0,01% (-0,14 a 0,10) | 1,21% (-6,10 a 8,56) | -0,01% (-0,14 a 0,10) | 0,08% (-0,30 a 0,47) |
| Curitiba/PR | 5,17% (0,82 a 9,28) | 0,48% (-0,02 a 0,97) | 4,69% (0,45 a 8,62) | 0,30% (0,02 a 0,57) | 0,29% (-0,05 a 0,59) |
| Salvador/BA | 1,24% (-3,74 a 5,67) | 1,38% (-3,61 a 5,77) | -0,14% (-0,77 a 0,46) | 0,29% (-0,09 a 0,61) | -0,06% (-0,38 a 0,24) |
| Goiânia/GO | 9,50% (-4,85 a 20,77) | -0,01% (-0,05 a 0,03) | 9,51% (-4,88 a 20,80) | -0,01% (-0,05 a 0,03) | 0,23% (-0,20 a 0,61) |
| Campinas/SP | 6,60% (-2,38 a 15,41) | -0,04% (-0,12 a 0,03) | 6,64% (-2,45 a 15,54) | -0,04% (-0,12 a 0,03) | 0,40% (0,00 a 0,75) |
| Manaus | 6,78% (-6,32 a 17,60) | -0,02% (-0,07 a 0,03) | 6,80% (-6,33 a 17,64) | -0,02% (-0,07 a 0,03) | 0,31% (-0,14 a 0,78) |
| Belém/PA | 11,82% (-7,48 a 27,13) | -0,02% (-0,05 a 0,02) | 11,84% (-7,49 a 27,16) | -0,02% (-0,05 a 0,02) | 0,03% (-0,59 a 0,59) |
| Vitória/ES | 2,93% (-4,36 a 9,62) | 0,14% (-0,23 a 0,52) | 2,79% (-4,55 a 9,42) | 0,13% (-0,21 a 0,47) | 0,31% (-0,12 a 0,70) |
| Baixada Santista/SP | 7,03% (-5,26 a 18,06) | 0,01% (-0,07 a 0,09) | 7,01% (-5,35 a 18,10) | 0,01% (-0,07 a 0,09) | 0,09% (-0,37 a 0,47) |
| São José dos Campos/SP | 3,68% (-1,81 a 8,35) | 0,81% (0,15 a 1,37) | 2,87% (-2,38 a 7,45) | 0,43% (0,03 a 0,74) | 0,15% (-0,25 a 0,50) |
| São Luís/MA | 2,97% (-3,69 a 9,10) | 2,90% (-3,72 a 8,66) | 0,07% (-0,50 a 0,63) | 0,16% (-0,28 a 0,52) | 0,06% (-0,39 a 0,50) |
| Natal/RN | 1,23% (-6,95 a 9,29) | 1,52% (-6,44 a 9,42) | -0,29% (-0,83 a 0,27) | 0,38% (-0,18 a 0,87) | -0,22% (-0,63 a 0,21) |
| Maceió/AL | -0,48% (-9,53 a 7,92) | -0,12% (-0,56 a 0,27) | -0,36% (-9,53 a 7,92) | -0,10% (-0,50 a 0,24) | 0,05% (-0,60 a 0,64) |
| Florianópolis/SC | -2,42% (-7,83 a 2,72) | 1,57% (-0,73 a 3,58) | -4,00% (-9,05 a 0,65) | 0,38% (-0,24 a 0,93) | 0,04% (-0,50 a 0,51) |
| João Pessoa/PB | -0,54% (-9,88 a 7,62) | -0,69% (-10,00 a 7,23) | 0,15% (-0,52 a 0,80) | 0,13% (-0,50 a 0,69) | 0,09% (-0,36 a 0,54) |
| Teresina/PI | -1,35% (-25,22 a 18,03) | 0,03% (-0,04 a 0,09) | -1,38% (-25,34 a 18,05) | 0,03% (-0,04 a 0,09) | -0,18% (-0,90 a 0,50) |
| Aracaju/SE | 0,16% (-11,09 a 8,98) | 0,11% (-0,50 a 0,61) | 0,05% (-11,19 a 8,78) | 0,08% (-0,43 a 0,48) | 0,05% (-0,68 a 0,68) |
| Cuiabá/MT | 5,10% (-13,72 a 20,56) | -0,01% (-0,08 a 0,06) | 5,11% (-13,77 a 20,61) | -0,01% (-0,08 a 0,06) | 0,23% (-0,46 a 0,81) |
| Sorocaba/SP | 9,62% (-5,41 a 22,00) | -0,04% (-0,17 a 0,07) | 9,66% (-5,46 a 22,12) | -0,04% (-0,17 a 0,07) | 0,26% (-0,42 a 0,83) |
| Campo Grande | 4,02% (-13,65 a 20,13) | -0,01% (-0,12 a 0,07) | 4,03% (-13,64 a 20,27) | -0,01% (-0,12 a 0,07) | 0,04% (-0,63 a 0,62) |

### Contribuições negativas

Soma, na janela, das contribuições diárias negativas ao AN total (estimativa pontual da `attrdl` com `tot = FALSE`; no *forward*, sem a reescala da função). Só a soma sai; nenhuma contribuição diária é gravada.

- **Concentrações com alguma contribuição diária negativa:** principal 25 de 26; ponte 26 de 26; *backward* 26 de 26. Inclui contribuições minúsculas: a TMR é o mínimo só nos pontos da grade de 0,1 °C, e entre dois pontos a curva pode descer um pouco abaixo dela.
- **Concentrações com soma das contribuições negativas de pelo menos 1 evento atribuível (arredondada ≤ −1):** principal 7 de 26; ponte 23 de 26; *backward* 26 de 26.

- **Onde estão (forward):** no principal, a soma das contribuições negativas é -38,7, das quais -38,7 vêm de dias com temperatura fora de p1–p99 e -0,034 de dias dentro; na ponte, -2.746,8, com -263,4 fora e -2.483,4 dentro. A TMR é o mínimo só entre p1 e p99 (C5): fora dessa faixa, a curva pode ficar abaixo dela. As concentrações com TMR BLUP na fronteira são 10 (Porto Alegre/RS, Goiânia/GO, Campinas/SP, Manaus, Belém/PA, Baixada Santista/SP, Teresina/PI, Cuiabá/MT, Sorocaba/SP, Campo Grande); a TMR fica no p97,5 ou acima em 10 concentrações, e nelas o calor extremo é igual ao calor por construção (D4(h)).
- Na ponte, a maior parte vem de dias dentro de p1–p99: a curva sem encolhimento tem outro mínimo, e, com o `cen` na TMR BLUP, pode ficar abaixo de 1 perto dele (D1, limitações).
- No *backward*, a contribuição do dia t vem das exposições de t − 7 a t, e a soma não é separada por faixa.

| Concentração | TMR na fronteira | Principal | Principal, fora de p1–p99 | Ponte | Ponte, fora de p1–p99 | Backward |
|---|---|---|---|---|---|---|
| São Paulo/SP | não | 0 | 0 | -414 | -36 | -706 |
| Rio de Janeiro/RJ | não | 0 | 0 | -18 | 0 | -96 |
| Belo Horizonte/MG | não | 0 | 0 | 0 | 0 | -28 |
| Brasília/DF | não | 0 | 0 | -82 | -41 | -68 |
| Recife/PE | não | 0 | 0 | -83 | 0 | -358 |
| Porto Alegre/RS | sim | -14 | -14 | -22 | -22 | -9 |
| Fortaleza/CE | não | 0 | 0 | -5 | -4 | -221 |
| Curitiba/PR | não | 0 | 0 | 0 | 0 | -1 |
| Salvador/BA | não | 0 | 0 | -73 | -15 | -124 |
| Goiânia/GO | sim | -3 | -3 | -5 | -5 | -11 |
| Campinas/SP | sim | 0 | 0 | -15 | -15 | -10 |
| Manaus | sim | -6 | -6 | -9 | -9 | -15 |
| Belém/PA | sim | 0 | 0 | -33 | -33 | -3 |
| Vitória/ES | não | 0 | 0 | -32 | 0 | -20 |
| Baixada Santista/SP | sim | -3 | -3 | -10 | 0 | -20 |
| São José dos Campos/SP | não | 0 | 0 | -8 | 0 | -43 |
| São Luís/MA | não | 0 | 0 | 0 | 0 | -61 |
| Natal/RN | não | 0 | 0 | -129 | -34 | -170 |
| Maceió/AL | não | 0 | 0 | -459 | -16 | -426 |
| Florianópolis/SC | não | 0 | 0 | -571 | 0 | -553 |
| João Pessoa/PB | não | 0 | 0 | -247 | 0 | -250 |
| Teresina/PI | sim | -1 | -1 | -394 | -21 | -423 |
| Aracaju/SE | não | 0 | 0 | -105 | 0 | -183 |
| Cuiabá/MT | sim | -5 | -5 | -4 | -4 | -9 |
| Sorocaba/SP | sim | 0 | 0 | -5 | -5 | -14 |
| Campo Grande | sim | -6 | -6 | -21 | -3 | -28 |

### Aditividade e os 7 últimos dias

- **Forward (principal e ponte):** |total − (calor + frio)| máximo 5.5e-12 na estimativa e 2.3e-11 nas simulações (critério ≤ 1e-8). **Backward** (só reportado, sem teste; complemento C1, item 5): total − (calor + frio) entre -1,4 e 1,2.
- **Os 7 últimos dias da janela (D1, item 5):** no *forward*, a média dos eventos de t a t + 7 fica NA nos 7 últimos dias da janela; a `attrdl` exclui esses dias do cálculo da AF e reescala o AN ao total observado; os eventos depois de 2024-08-06 não são usados. O *backward* não perde esses dias.

## 5. Dupla auditoria

### Autoauditoria (`47_autoauditoria_fase3C.R`)

- **Método:** as contas principais do 45 e do 46 refeitas com código diferente e comparadas com as saídas (RDS e CSV, com os SHA-256 dos logs); os números refeitos foram procurados no texto dos logs com a mesma formatação.
- **Código diferente:** `mixmeta` chamado direto (sem `meta_curva`); bases pelo `splines::ns` (sem `onebasis`, `base_combinada` e `curva`); grade da TMR montada à mão; bootstrap à mão na combinada (i = 0), em São Paulo (i = 1) e em Sorocaba (i = 25), fixados no desvio 77(g); coeficientes de lag pelos 16 coeficientes à mão (sem `crossreduce`); AN *forward* à mão em São Paulo e Sorocaba; totais pela soma das simulações; denominadores recontados na série.
- **Tolerâncias:** 1e-8 a 1e-14, conforme a escala de cada quantidade; textos com igualdade exata.

### Resultado: 42 de 42 conferências iguais

| Item | Conferência | N | Resultado |
|---|---|---|---|
| Entradas | RDS e CSV do 45 e do 46 com os SHA-256 dos logs |   4 | igual |
| C1 | coeficientes, vcov e Ψ da meta-regressão (mixmeta direto) |   3 | igual |
| C1 | Q, gl e I² residual e total |   2 | igual |
| C1 | Q e I² no log do 45 |   4 | igual |
| C1 | Wald de cada metapreditor (forma quadrática à mão) |   2 | igual |
| C1 | Wald no log do 45 |   2 | igual |
| C1 | predição na média dos metapreditores (x̄B̂ e vcov à mão) |   2 | igual |
| C1 | autovalores e posto efetivo de Ψ no log do 45 |   1 | igual |
| C1 | BLUPs e vcov dos BLUPs (mixmeta::blup) |  26 | igual |
| C2 | base combinada (nós e Boundary.knots médios) |   2 | igual |
| C2 | TMR combinada na grade à mão e fronteira pelo índice |   2 | igual |
| C2 | q_TMR (approx no eixo médio) |   1 | igual |
| C2 | IC da TMR combinada (bootstrap à mão, i = 0) |   1 | igual |
| C2 | proporção de sorteios no x1 e no x99 (bootstrap à mão) |   2 | igual |
| C2 | TMR combinada, percentil e IC no log do 45 |   1 | igual |
| C2 | RR combinados em x99, x1, x95, x90, x10 e x5 (log RR e EP) |   6 | igual |
| C2 | contrastes combinados no log do 45 |   6 | igual |
| C3 | TMR BLUP na grade à mão nas 26 |  26 | igual |
| C3 | fronteira pelo índice nas 26 |  26 | igual |
| C3 | RR por concentração nos p99, p95, p90, p10, p5 e p1 (log RR e EP; splines::ns) |  26 | igual |
| C3 | RR contra a mediana nas concentrações com TMR BLUP na fronteira (splines::ns) |  10 | igual |
| C3 | número de TMR BLUP na fronteira no log do 45 |   1 | igual |
| C3 | IC da TMR BLUP de São Paulo/SP (bootstrap à mão, i = 1) |   1 | igual |
| C3 | proporção de sorteios no p1 e no p99 de São Paulo/SP (bootstrap à mão) |   2 | igual |
| C3 | TMR e IC de São Paulo/SP no log do 45 |   1 | igual |
| C3 | IC da TMR BLUP de Sorocaba/SP (bootstrap à mão, i = 25) |   1 | igual |
| C3 | proporção de sorteios no p1 e no p99 de Sorocaba/SP (bootstrap à mão) |   2 | igual |
| C3 | TMR e IC de Sorocaba/SP no log do 45 |   1 | igual |
| C4 | centro da lag–resposta (quantile no q_TMR, ou p50 na fronteira) nas 26 |  26 | igual |
| C4 | coeficientes de lag no p99 e no p1 pelos 16 coeficientes à mão (sem crossreduce) nas 26 |  52 | igual |
| C4 | predição na média da lag–resposta no p99 e no p1 (mixmeta direto) |   2 | igual |
| C4 | soma dos lags 0–7 no p99 e no p1 (à mão) |   2 | igual |
| C4 | soma dos lags no log do 45 |   1 | igual |
| C4 | RR por lag inteiro no log do 45 |   8 | igual |
| C5 | denominadores recontados na série = os do 46 = n$eventos da Fase 2 |  26 | igual |
| C5 | AN forward à mão, São Paulo/SP, cinco componentes (principal) |   5 | igual |
| C5 | AN forward à mão, Sorocaba/SP, cinco componentes (principal) |   5 | igual |
| C5 | AF, AF inferior e AF superior = AN / denominador em todas as linhas do 46 | 405 | igual |
| C5 | contribuições negativas de Sorocaba (principal), total, fora e dentro de p1–p99, à mão |   3 | igual |
| C5 | totais das 26 (AN, eCI pela soma das simulações e AF), três análises × cinco componentes |  15 | igual |
| C5 | totais no log do 46 |  15 | igual |
| C5 | denominador total no log do 46 |   1 | igual |

`versao()` no fim: 4443971b.
### Registro da dupla auditoria

Transcrito de `logs/auditoria_parteC_fase3_20261013.md`.


Registro achado → reprodução → correção, como manda o `CLAUDE.md` do artigo. A série diária só foi lida e processada dentro da Forja; nenhuma linha, valor diário, série diária ou AN/AF diário foi impresso ou gravado. Saem só resultados de modelo e agregados por concentração na janela inteira.

### Etapa 1: autoauditoria (`00_scripts/47_autoauditoria_fase3C.R`)

- **Rodadas de desenvolvimento do 45 e do 46** (gravadas só no scratchpad, antes das oficiais):
  - duas conferências de entrada do 45 falharam por 1 ulp: os CSV `reduzida_coef_vcov` e `crossbasis_coef_vcov` da Fase 2 contra a RDS, e a `tmean_nucleo` de 2012–2024 contra a grade da A0. Os arquivos foram gravados com `sprintf("%.17g")`, e a leitura de texto do R pode errar 1 ulp. As duas passaram a comparar o texto, com o mesmo `sprintf("%.17g")`, em igualdade exata;
  - p-valores e q_TMR com vírgula decimal;
  - a tabela das contribuições negativas ganhou a contagem das concentrações com soma arredondada ≤ −1, ao lado da contagem registrada no desvio 77(e) (qualquer contribuição negativa), que inclui contribuições minúsculas.
- **1ª rodada oficial do 45 e do 46** (21:34), seguida de uma **rodada de desenvolvimento do 47** (só no scratchpad): 32 de 35 conferências iguais. As 3 diferenças vinham de um **erro no 46**:
  - o denominador total somava as 5 linhas de componentes de cada concentração: 6.890.150, isto é, 5 × 1.378.030;
  - a AF das 15 linhas de total (3 análises × 5 componentes) saía dividida por 5; no principal, total 0,37% em vez de 1,84%;
  - AN, eCI dos AN, denominadores por concentração e AF por concentração estavam certos.

  **Correção no 46:** o denominador total passou a somar uma linha por concentração (`den_c`, com `stopifnot(nrow(den_c) == 26)`), e a tabela de denominadores usa a mesma seleção. Saídas e log da 1ª rodada do 46 foram para a lixeira do volume, com SHA-256 anotado (seção "Regeneração dos logs"), e o 46 rodou de novo (21:38).
- **1ª rodada oficial do 47** (21:38): 35 de 35 conferências iguais (log hoje na lixeira).
- **2ª rodada oficial do 47** (21:58, depois das correções da auditoria independente): **42 de 42** (`logs/autoauditoria_parteC_fase3_20261013.md`). Conferências novas: autovalores e posto efetivo de Ψ; proporção de sorteios nas pontas da grade (combinada, São Paulo e Sorocaba); RR contra a mediana nas 10 concentrações com TMR BLUP na fronteira; AF de cada componente igual a AN/denominador em todas as linhas; contribuições negativas de Sorocaba (total, fora e dentro de p1–p99) refeitas à mão. A rodada de desenvolvimento dessa versão deu 41 de 42, por erro da própria conferência do 47 (o filtro dos RR por concentração passou a pegar também as linhas novas contra a mediana); o filtro foi corrigido antes da rodada oficial.
- **3ª rodada oficial do 47** (depois das notas N1 e N3 da re-auditoria; o 45 rodou de novo às 22:08:32 e o 47 às 22:08:35): **42 de 42**. O 45 só mudou o texto do log ("Extensão do IC" e os autovalores de Ψ abaixo do limiar); as 8 saídas dele têm os mesmos SHA-256 de antes, e o 46 não rodou de novo.
- **Limite:** as rodadas de desenvolvimento (32 de 35, 41 de 42 e o SHA-256 igual da RDS do 45) ficaram só no scratchpad da sessão e não são verificáveis por terceiros; o que é verificável são os logs e as saídas em vigor e os arquivos da lixeira, com os SHA-256 abaixo.

### Auditoria independente

- **Auditor:** subagente em contexto limpo. Leu o prompt da Fase 3, as decisões de 13/10 e o complemento, os desvios 71 a 77, o código das tags, os scripts 45 a 47 e os logs em vigor antes das correções da auditoria (45 de 21:34; 46 e 47 de 21:38, já com o denominador corrigido); leu com R, sem imprimir linhas, as saídas da Parte C, a RDS da primeira etapa, o CSV de referências, a grade da A0 e a série da Fase 1; leu a exposição de 2012–2024 só pela `serie_diaria` com as colunas de exposição. Não abriu `.parquet` nem `.dbc` e não escreveu no repositório. Rodou com código próprio (`aud11/*`, no scratchpad).
- **Veredito do auditor:** os números da Parte C estão corretos; refez cada um com código próprio, e todos batem com o que o 45 e o 46 gravaram, dentro de 1e-10 ou menos. O código no disco é o das tags, na árvore e na mensagem de cada uma, e a `attrdl.R` tem o SHA-256 registrado. A correção do denominador total está certa. A RESPOSTA não podia sair por três lacunas de relato (achados 1 a 3); mais três notas de apresentação. Nada muda estimativa nem método.
- **Achados:** 6
  - 3 marcados como "corrigir antes da RESPOSTA" (1 a 3) e 3 como "nota" (4 a 6).
  - Todos foram aceitos e reproduzidos por código próprio da sessão (`repro_aud11.R`, no scratchpad) ou pela leitura do prompt, da especificação e dos scripts.
  - As correções mudam só o relato. O 45, o 46 e o 47 rodaram de novo (21:57 a 21:58); os números já gravados não mudaram.

| Nº | Achado (classificação do auditor) | Reprodução | Correção |
|---|---|---|---|
| 1 | Faltam os RR contra a mediana nas TMR BLUP de fronteira: a especificação (§7: "Se a TMR cair na fronteira, reportar os RRs também contra a mediana") e o prompt (A1.4: "Quem chama reporta as duas"; D4(g)) pedem, e o 45 só calculava contra a TMR. Nas 10 concentrações de fronteira, o RR no p99 sai 1,000 (1,000 a 1,000), porque é a própria TMR (corrigir antes da RESPOSTA) | Leitura do 45: a `busca_tmr` devolve o p50, mas a `curva` só usava `tb$tmr`; TMR na fronteira em 10 de 26 (CSV de TMR) | O 45 calcula, nas concentrações com TMR BLUP na fronteira, os RR nos p99, p95, p90, p10, p5 e p1 contra o p50 da concentração, com IC (nível `blup_mediana` no CSV de contrastes e tabela própria no log). Só reportado: o `cen` da C5 continua sendo a TMR da grade (D4(g)). O 47 confere essas 60 linhas com `splines::ns` |
| 2 | A correção do denominador total do 46 não estava registrada em nenhum log (corrigir antes da RESPOSTA, registro) | Confirmado: só existia o log do 47 com 35 de 35 | Registrada na Etapa 1 deste log, com os números afetados, a correção e os SHA-256 da rodada anterior (seção "Regeneração dos logs"). A RESPOSTA transcreve este log |
| 3 | Falta a AF de cada componente por concentração: o prompt pede "AN e AF de cada componente, com eCI" (C5) e as tabelas completas (D4(d)); por concentração só saía a AF do total (corrigir antes da RESPOSTA, só apresentação) | Leitura do 46: a `tabela_conc` só tinha a AF do total; o CSV já tinha a AF de todas as linhas | O log do 46 ganhou, em cada análise, a tabela "AF por componente (eCI)" das 26 concentrações; o 47 confere AF = AN/denominador em todas as linhas do CSV |
| 4 | A explicação das contribuições negativas do principal estava incompleta: atribuía tudo à resolução de 0,1 °C da grade, e o prompt (C5) já previa a causa principal, os dias fora de p1–p99 (nota) | Código próprio: no principal, as 10 concentrações com dias de RR < 1 contra a TMR BLUP fora de p1–p99 são exatamente as 10 com TMR na fronteira | O 46 separa, no *forward*, a soma das contribuições negativas entre dias fora e dentro de p1–p99 (no principal, −38,7 fora e −0,034 dentro; na ponte, −263,4 fora e −2.483,4 dentro), diz que nas concentrações com TMR no p97,5 ou acima o calor extremo é igual ao calor por construção (D4(h)) e explica a ponte pela limitação da D1 (curva sem encolhimento com o `cen` na TMR BLUP). O *backward* não é separado por faixa (a contribuição do dia t vem de t − 7 a t) |
| 5 | Os IC da TMR cobrem a faixa de busca inteira: o IC da combinada é exatamente de x1 a x99, com 3,5% dos sorteios no x1 e 30,9% no x99; em 18 das 26 concentrações, o IC da TMR BLUP é a grade p1–p99 inteira (nota) | Código próprio: os mesmos 3,5% e 30,9%, e 18 de 26 | O 45 diz isso no log: cobertura do IC da combinada, número de IC BLUP iguais à grade inteira e, por concentração, a porcentagem dos sorteios no p1 e no p99. O 47 confere as proporções com o bootstrap à mão |
| 6 | Ψ está no limite do espaço paramétrico: autovalores 2,657e-02, 5,493e-04, 7,717e-11 e 8,285e-17, posto efetivo 2 (nota) | Código próprio: os mesmos autovalores | O 45 lista os autovalores de Ψ da C1 e das duas meta-análises da lag–resposta, com o posto efetivo (autovalores acima de 1e-8 × o maior; depois da nota N3, os abaixo do limiar só são contados), e declara Ψ singular, só reportado (A1.2: a sequência de estabilidade age só em erro ou não convergência). Na lag–resposta, o posto efetivo é 2 no p99 e 1 no p1 |

#### Conferido e aprovado pelo auditor (resumo)

- Código contra as tags: os 4 arquivos de `codigo_compartilhado/R/` e os 7 de testes têm o mesmo SHA-256 no disco, na árvore e na mensagem das duas tags; a `attrdl.R` tem o hash `d34c4c30…`.
- Ordem das 26 igual à do desvio 73; grade da A0 e eixo médio iguais ao `quantile(type = 7)` do auditor; média e amplitude do CSV iguais às calculadas da exposição.
- Base combinada (D2) igual às médias das 26; os nós médios coincidem com o eixo em p10, p75 e p90; as fronteiras de cada concentração são o range das 4.505 linhas.
- C1: REML com Ψ não estruturado; coeficientes, vcov, Ψ, BLUPs, Q e I² (por GLS à mão) e Wald iguais.
- C2: TMR combinada 28,2 °C, q_TMR 0,9378, IC do bootstrap reproduzido; contrastes iguais pelo `crosspred`.
- C3: as 26 TMR BLUP, a fronteira, a busca p10–p90, o percentil, os IC do bootstrap das 26 e os 156 RR iguais.
- C4: centros, coeficientes de lag (pelo `crosspred` por lag), soma dos lags, RR por lag e Q iguais.
- C5, refeita à mão sem a `attrdl` nas 26 concentrações × 3 análises × 5 componentes: AN, eCI e as 1.000 simulações reproduzidos (confirma a semente 20261001 + i); denominadores iguais ao `n$eventos`; totais, aditividade do *forward* e diferenças do *backward* iguais.
- Fidelidade: os trechos conferidos dos logs do 45 e do 46 batem com o texto exato; as 11 saídas têm o SHA-256 dos logs.

### Re-auditoria das correções

- **Re-auditor:** o mesmo auditor independente, retomado com o próprio contexto e com as mesmas regras de sigilo e de escrita. Leu os logs e as saídas novos e, para conferir os SHA-256, só os 18 arquivos agregados desta fase na lixeira do volume. Rodou com código próprio (`aud11/05_*`, `aud11/06_*`).
- **Veredito do re-auditor:** as seis correções estão certas e não mexeram em nenhum número já conferido; 37 conferências novas, todas iguais. O registro da correção do denominador está fiel e completo no essencial: os 18 SHA-256 da tabela abaixo batem com os arquivos da lixeira, e os números da 1ª rodada do 46 batem com o que a Etapa 1 descreve (denominador total 6.890.150 e AF total do principal 0,37% naquela rodada; o resto idêntico ao atual).
- **Achados:** 3 notas, todas aceitas.

| Nº | Nota do re-auditor | Reprodução | Correção |
|---|---|---|---|
| N1 | "Cobertura do IC da TMR combinada", na Parte C, fala da extensão do IC; na Parte A, a mesma expressão é a probabilidade de cobertura nas réplicas (teste 5) | Confirmado pela leitura dos dois logs | O 45 passou a dizer "Extensão do IC da TMR combinada"; o 48 lê o rótulo novo |
| N2 | A frase sobre o que o auditor leu dizia "os logs da 1ª rodada oficial", mas ele leu o 45 de 21:34 e o 46 e o 47 de 21:38, já corrigidos; as rodadas de desenvolvimento não são verificáveis por terceiros | Confirmado pelos horários dos arquivos da lixeira (45 às 21:34:13; 46 com defeito às 21:34:52; 46 corrigido às 21:38:21; 47 às 21:38:34) | Frase corrigida na seção "Auditoria independente"; limite das rodadas de desenvolvimento declarado na Etapa 1 |
| N3 | Os autovalores de Ψ abaixo do limiar são ruído numérico: o menor da lag–resposta no p1 sai 1,590e-19 no log e 1,189e-19 no ajuste do auditor, com Ψ diferindo em no máximo 1,3e-17 | Confirmado pela ordem de grandeza (abaixo de 1e-8 × o maior) | O 45 imprime só os autovalores acima de 1e-8 × o maior e diz quantos ficam abaixo; o posto efetivo não muda (2 na C1, 2 no p99 e 1 no p1). O 47 confere o texto novo |

- **Conferido e aprovado pelo re-auditor (resumo):**
  - as 60 linhas `blup_mediana` (só nas 10 concentrações de fronteira, com `cen` = p50), recalculadas com `crosspred`;
  - as 78 linhas das tabelas de AF por componente;
  - as somas das contribuições negativas, total, fora e dentro de p1–p99, nas 26 concentrações. No principal, as 10 com contribuição negativa fora de p1–p99 são as 10 de fronteira; a TMR fica no p97,5 ou acima nessas mesmas 10, e nelas o calor extremo é idêntico ao calor no AN, no eCI e nas simulações;
  - as proporções de sorteios nas pontas (combinada e 26 concentrações) e os autovalores e o posto de Ψ;
  - o código igual às tags; as entradas e as 11 saídas com os SHA-256 dos logs; as colunas e linhas antigas idênticas;
  - a autoauditoria com 42 de 42.

### Regeneração dos logs

Os logs e as saídas da Parte C foram regenerados depois das correções; os antigos estão na lixeira do volume, com o SHA-256 anotado. A grade da A0 (`percentis_exposicao_fase3_20261013.csv`) não mudou.

| Arquivo | 1ª rodada do 46 (denominador total 5 ×; lixeira) | Rodada antes das correções da auditoria independente (lixeira) |
|---|---|---|
| `logs/segunda_etapa_fase3_20261013.md` | (a mesma do 45, ao lado) | `c45eef090ad3eab23a9ef6c3257265a4d35b572cd147f87304750b1624301151` |
| `logs/fracao_atribuivel_fase3_20261013.md` | `85126c6cb1f199a5c472f172b010f0587337a99ce9c52e6c5aa06e86a206205b` | `d01f6962fd3c5f41e2c32268d5504064658458de566383554528b59ba22b786b` |
| `logs/autoauditoria_parteC_fase3_20261013.md` | (não havia) | `436edf40b492de918809dc8df977b45972bf41543bff5f083e30a924ecde5f00` |
| `01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds` | (a mesma do 45, ao lado) | `dbfe71cfb272b67e1a465401684e805b9411249b44008c1e2c030941f46faf5d` |
| `01_saidas/fase3/meta_curva_fase3_20261013.csv` | (idem) | `6958d5083a2b10d9b3449d56d02315eda9cbc4588aa5773c7e8df3af8edfec76` |
| `01_saidas/fase3/blups_fase3_20261013.csv` | (idem) | `5b38a59e61de47dc18df2ed45106d0d325ae5dc3982d13b0620d3ef3552829c1` |
| `01_saidas/fase3/tmr_fase3_20261013.csv` | (idem) | `6162d7ff261606cae10dd01944f7ccacadc9fba87cbaa2d479ee28e18a14f649` |
| `01_saidas/fase3/contrastes_fase3_20261013.csv` | (idem) | `14367d1c641a3dee1c17ce85261c750f963055bd0233cfd528ba76b50f5e9dcf` |
| `01_saidas/fase3/curva_combinada_fase3_20261013.csv` | (idem) | `4855ffdb50831e23eeffaa3bd25822afa4f5399e90a5df05184485f5b07cd93d` |
| `01_saidas/fase3/lagresposta_fase3_20261013.csv` | (idem) | `6a60db902a2e5b5ba679563000216f8e391e0836dc00aac277895b23b84af212` |
| `01_saidas/fase3/lagresposta_meta_fase3_20261013.csv` | (idem) | `9040effec6722babada664b55505b52175559be4e9cd8e2a58fc2e89515ffeb2` |
| `01_saidas/fase3/fracao_atribuivel_fase3_20261013.csv` | `c1c2488e4f57ac5805c36c88c4ab8cff6090400350f2ccbffb68061de8017150` | `9437e9668c729ffd502a159038d2d557b4d8767d1a046cb86eef13ddb2659a48` |
| `01_saidas/fase3/contribuicoes_negativas_fase3_20261013.csv` | `b89582919f210a3fd5c07da895078a21fcf091ff358a6b2b0467191e583ec589` | `b89582919f210a3fd5c07da895078a21fcf091ff358a6b2b0467191e583ec589` |
| `01_saidas/fase3/fracao_atribuivel_simulacoes_fase3_20261013.rds` | `9a1a02b779d7e1d336826831df940e1ce1c0a009382cd45cd235e225227bd5cd` | `9a1a02b779d7e1d336826831df940e1ce1c0a009382cd45cd235e225227bd5cd` |

- **Rodada antes das notas N1 e N3 da re-auditoria (lixeira):** `logs/segunda_etapa_fase3_20261013.md` `ef74c818abde85e6bababc33433c7774e3b39b0c7a92faad2a3eb3742ef2194c`; `logs/autoauditoria_parteC_fase3_20261013.md` `221d60e147ec0c3405775799510255e3171aef573470f03d6e7e65cee2063ed2`. As 8 saídas do 45 daquela rodada têm os mesmos SHA-256 das em vigor.
- A RDS do 45 da 1ª rodada oficial tem o mesmo SHA-256 da rodada de desenvolvimento, e as simulações e as contribuições negativas do 46 são idênticas nas duas primeiras rodadas: os cálculos são deterministas.
- Os SHA-256 das saídas em vigor estão nos logs do 45 e do 46 e na RESPOSTA.
## 6. Desvio desta parte

O desvio 77 foi registrado num commit próprio (`d511c54`) antes de rodar a Parte C. Os desvios 71 a 76 estão nas RESPOSTAs e nos commits anteriores.

| # | Data | Etapa | Referência | O que divergiu | Causa | Efeito nos resultados | Decisão | Evidência |
|---|---|---|---|---|---|---|---|---|
| 77 | 2026-10-13 | Fase 3, Parte C, antes de rodar (depois de "SEGUNDA ETAPA LIBERADA"). Artigo 1 | `docs/coordenacao/PROMPT_artigo1_prematuridade_FASE3_20261013.md` (prompt da Fase 3 v1.1, SHA-256 `953f14d929587851665f6cba0793e2d5b7d36dd5b17bc67d523cfa766a0cb864`), Parte C (C1 a C6 e dupla auditoria); D1; D4(b), (d), (g) e (h); complemento C1 e C2 | **Escolhas de implementação da Parte C, sem mudar o método.** (a) **Scripts e saídas:** o 45 faz a C6 (conferência da cross-basis, antes de qualquer curva) e a C1 a C4; o 46, a C5; o 47, a autoauditoria; o 48, a RESPOSTA. Saídas em `01_saidas/fase3/`, fora do git, com sufixo `_fase3_<data>` e SHA-256 no log; o 46 e o 47 conferem o SHA-256 da RDS do 45 contra o log dele. Os CSV `reduzida_coef_vcov` e `crossbasis_coef_vcov` da Fase 2 têm o SHA-256 conferido, e os valores deles têm de ser iguais aos da RDS. (b) **C6:** em cada concentração, a cross-basis pelo caminho da Fase 2 (`crossbasis` nas 4.505 linhas, nós p10/p75/p90 do CSV, fronteiras padrão, `arglag` ns com intercepto e `logknots(7, nk = 2)`) e a montada pela `monta_cb` com a `argvar` e a `arglag` da RDS têm o mesmo padrão de NA e diferença ≤ 1e-12 nas demais células; os atributos `argvar`, `arglag`, `lag`, `range` e `df` das duas são `identical()` aos da RDS. Se falhar, o 45 para antes da C1. (c) **C4:** `tmean_ref` = `tmean_nucleo` diária de 2012-01-01 a 2024-12-31 da concentração, lida como no 40 (`serie_diaria(nivel = "recorte", coorte_fixa = TRUE)`, só com as colunas de exposição); q_TMR = `posicao_no_eixo(TMR combinada, eixo médio, probabilidades)`, com o eixo da A0 (p1 a p99, p2,5 e p97,5) ordenado pela probabilidade e interpolação linear; a `arglag` comum é a das 26, idêntica (conferido); valor = p99 e p1 da concentração na grade da A0. (d) **C5:** *forward* (principal e ponte) nas 4.498 linhas da janela (`tmean_nucleo` e `ptb`); *backward* nas 4.505 linhas, com `ptb` = NA nos 7 dias de aquecimento; `basis` = `monta_cb` nas 4.505 linhas, com a `argvar` e a `arglag` da RDS; principal com o BLUP e a vcov dele; ponte com os reduzidos e a vcov da Fase 2; *backward* com os 16 coeficientes e a vcov 16 × 16 da Fase 2; `cen` = TMR BLUP da grade p1–p99 da concentração, mesmo na fronteira (D4(g)); p2,5 e p97,5 da concentração (A0); i = posição na ordem travada; 1.000 simulações. **Total:** soma dos AN das 26; eCI pelos percentis 2,5 e 97,5 da soma, sorteio a sorteio, das simulações das 26 (D1, item 1); AF total = AN total / soma dos denominadores. O denominador de cada concentração, nas três análises, tem de ser igual ao `n$eventos` da primeira etapa. (e) **Contribuições negativas:** por concentração e análise, a soma das contribuições diárias negativas ao AN total (`attrdl` com `tot = FALSE`, só a estimativa pontual; no *forward*, sem a reescala da função), calculada na Forja e reportada só como soma na janela, arredondada ao inteiro, mais o número de concentrações com alguma. Nenhuma contribuição diária sai. (f) **Os 7 últimos dias da janela:** a diferença entre *forward* e *backward* (D1, item 5) é declarada em texto, sem número próprio. (g) **Autoauditoria:** o bootstrap e o AN *forward* à mão em São Paulo (3550308, i = 1) e Sorocaba (3552205, i = 25), fixados agora, mais o `mixmeta` chamado direto, a curva combinada com `onebasis` à mão e as TMR na grade das 26 e da combinada. (h) **Formatação das tabelas:** RR com 3 casas e IC 95%; TMR em °C com 1 casa (grade de 0,1 °C) e percentis do eixo com 3 casas; AF em % com 2 casas; AN arredondado ao inteiro, sem a máscara "<10" (D4(d)); EP dos BLUPs = raiz da diagonal da vcov do BLUP | Detalhes que o prompt deixa para a implementação | Nenhum efeito no método. Resultados vistos antes do registro: os mesmos dos desvios 68 a 76 (primeira etapa da Fase 2 e testes sintéticos); nenhuma segunda etapa, BLUP, curva combinada, TMR, RR ou fração atribuível com o desfecho real foi calculado | Implementação dentro do plano aprovado por Guilherme em 13/10/2026, com "SEGUNDA ETAPA LIBERADA" (13/10/2026) | Logs da Parte C: `logs/segunda_etapa_fase3_<data>.md`, `logs/fracao_atribuivel_fase3_<data>.md`, `logs/autoauditoria_parteC_fase3_<data>.md` e `logs/auditoria_parteC_fase3_<data>.md` |

## 7. Saídas, comandos e ambiente

Da pasta `artigo1_prematuridade/`, com o `renv` do artigo (R 4.5.1), nesta ordem. Cada script tem trava contra sobrescrita.

```
FASE3_DATA=20261013 Rscript 00_scripts/45_segunda_etapa_principal.R
FASE3_DATA=20261013 Rscript 00_scripts/46_fracao_atribuivel.R
FASE3_DATA=20261013 Rscript 00_scripts/47_autoauditoria_fase3C.R
FASE3_DATA=20261013 Rscript 00_scripts/48_resposta_fase3C.R
```

**`versao()` no início e no fim de cada script:**

| Log | Script | Início | Fim |
|---|---|---|---|
| `segunda_etapa_fase3_20261013.md` | `00_scripts/45_segunda_etapa_principal.R` | 4443971b | 4443971b |
| `fracao_atribuivel_fase3_20261013.md` | `00_scripts/46_fracao_atribuivel.R` | 4443971b | 4443971b |
| `autoauditoria_parteC_fase3_20261013.md` | `00_scripts/47_autoauditoria_fase3C.R` | 4443971b | 4443971b |
| (este retorno) | `00_scripts/48_resposta_fase3C.R` | 4443971b | 4443971b (conferido no fim do script) |

**SHA-256 dos scripts e das saídas** (as saídas ficam fora do git, em `01_saidas/fase3/`; conferidas contra os logs no momento de gravar este retorno):

| Arquivo | SHA-256 |
|---|---|
| `artigo1_prematuridade/00_scripts/45_segunda_etapa_principal.R` | `0c4c623b0ca2fabca652f9c4deedf2d5fa663506676b4c96113e59faa618b89b` |
| `artigo1_prematuridade/00_scripts/46_fracao_atribuivel.R` | `8510fba72abc9016efa29eef4862e66c98e7883322d7eca418ec6fa8d490abef` |
| `artigo1_prematuridade/00_scripts/47_autoauditoria_fase3C.R` | `92245c5b190aa8e349f7a4b6490a4fc26a29c36e46a5d9844cb17514240d91c2` |
| `artigo1_prematuridade/00_scripts/48_resposta_fase3C.R` | `a3bdbd745f0afb2a049eb43a0c71c67494759eb89e921474d17ace5ab3c215fe` |
| `artigo1_prematuridade/01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds` | `52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e` |
| `artigo1_prematuridade/01_saidas/fase3/meta_curva_fase3_20261013.csv` | `6958d5083a2b10d9b3449d56d02315eda9cbc4588aa5773c7e8df3af8edfec76` |
| `artigo1_prematuridade/01_saidas/fase3/blups_fase3_20261013.csv` | `5b38a59e61de47dc18df2ed45106d0d325ae5dc3982d13b0620d3ef3552829c1` |
| `artigo1_prematuridade/01_saidas/fase3/tmr_fase3_20261013.csv` | `621f1598bba60b6e3862a2bb4b7c3dd2d0ff0ce34dd23d8568f92749a12c8447` |
| `artigo1_prematuridade/01_saidas/fase3/contrastes_fase3_20261013.csv` | `2a4c634e81ab9f1d336186608e7d5b5444523140a3cfe35c2e56efbcd176db96` |
| `artigo1_prematuridade/01_saidas/fase3/curva_combinada_fase3_20261013.csv` | `4855ffdb50831e23eeffaa3bd25822afa4f5399e90a5df05184485f5b07cd93d` |
| `artigo1_prematuridade/01_saidas/fase3/lagresposta_fase3_20261013.csv` | `6a60db902a2e5b5ba679563000216f8e391e0836dc00aac277895b23b84af212` |
| `artigo1_prematuridade/01_saidas/fase3/lagresposta_meta_fase3_20261013.csv` | `9040effec6722babada664b55505b52175559be4e9cd8e2a58fc2e89515ffeb2` |
| `artigo1_prematuridade/01_saidas/fase3/fracao_atribuivel_fase3_20261013.csv` | `9437e9668c729ffd502a159038d2d557b4d8767d1a046cb86eef13ddb2659a48` |
| `artigo1_prematuridade/01_saidas/fase3/contribuicoes_negativas_fase3_20261013.csv` | `4641b22af30316679f035977668651f49e60e874a68747f7e89cd1ba21a2a1d1` |
| `artigo1_prematuridade/01_saidas/fase3/fracao_atribuivel_simulacoes_fase3_20261013.rds` | `3afadd6cd887af6ca01eab7f7a146f7de6e0f7ddab4a53793663bb764adaeb91` |

## 8. `git status`

Saída de `git status --porcelain --untracked-files=all`, antes de gravar este retorno e antes do commit local da Parte C. Arquivos de outras sessões, se houver, só são mostrados:

```
 M artigo2_obito_perinatal/logs/desvios_especificacao.md
?? artigo1_prematuridade/00_scripts/45_segunda_etapa_principal.R
?? artigo1_prematuridade/00_scripts/46_fracao_atribuivel.R
?? artigo1_prematuridade/00_scripts/47_autoauditoria_fase3C.R
?? artigo1_prematuridade/00_scripts/48_resposta_fase3C.R
?? artigo1_prematuridade/logs/auditoria_parteC_fase3_20261013.md
?? artigo1_prematuridade/logs/autoauditoria_parteC_fase3_20261013.md
?? artigo1_prematuridade/logs/fracao_atribuivel_fase3_20261013.md
?? artigo1_prematuridade/logs/segunda_etapa_fase3_20261013.md
?? artigo2_obito_perinatal/logs/plano_fase3_20261013.md
```

`git log --oneline -4`:

```
6a77510 Artigo 2, Fase 3, B0: copia do codigo da tag segunda_etapa-v1.0, conferencia da interface e dos insumos (desvios 92 a 94)
0de8aa3 Artigo 3, Fase 2: pedido do prompt da Fase 3 ao chat do A3, errata da contagem de achados da auditoria e varredura de cegamento (43)
d511c54 Fase 3 do Artigo 1, Parte C: desvio 77 (escolhas de implementacao da segunda etapa), antes de rodar
5ed035f Artigo 2, Fase 3, Parte A: registro antes de rodar (desvios 81 a 91), conferencia por codigo (48), tag segunda_etapa-v1.0 liberada para o A2 e mensagem ao chat
```

Commit local da Parte C. **Sem push:** a RESPOSTA vai para o chat do Artigo 1 antes.
