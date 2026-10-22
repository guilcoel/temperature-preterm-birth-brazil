# Artigo 1: prematuridade. Fase 2, Parte C: primeira etapa do modelo principal nas 26 concentrações

**Para:** chat do Artigo 1 (prematuridade), via Guilherme.

**Data:** 10/10/2026.

**Base:** `4443971b`, somente leitura. **Código:** tag `ajusta_dlnm-v1.0` (commit `caf5022`), publicada com o `main` em `92565b9` depois do [ok] de Guilherme (Parte B; desvio 64).

**Prompt:** Fase 2, v1.1, Parte C, depois de "PRIMEIRA ETAPA LIBERADA" (10/10). Escolhas registradas antes de rodar no desvio 65.

## 1. Resumo

- **Ajustes:** 26 de 26 concentrações com `status = "ok"` no modelo principal; fallback em 0; não estimáveis 0; decisões pendentes 0. Todas com cross-basis de 16 parâmetros e curva reduzida de 4, a entrada da Fase 3.
- **φ > 2:** 0 de 26. A binomial negativa não é acionada pela regra da §2.1.
- **PACF, regra literal da §2.1:** 25 de 26 com algum lag de 1 a 7 fora de ±2/√n. Pela regra literal, nelas a sensibilidade com resíduos defasados entraria na Fase 4; a regra que vale é decisão pendente do chat (desvio 65c).
- **Para o chat (desvio 65c):** num modelo correto, com os estratos mensais eliminados, a PACF dos resíduos fica em torno de −1/(m − 1) ≈ −0,0343 (m ≈ 30,2 dias por estrato), e a regra literal dispara quase sempre: em 100 réplicas simuladas sem autocorrelação, sinalizou 100 das 100 (auditoria final da Parte B). Recentrada em −1/(m − 1), a mesma regra sinalizou 31 das 100 réplicas (efeito de testar 7 lags) e, com Bonferroni nos 7 lags, 3. Nos dados, a recentrada sinaliza 13 de 26 e a recentrada com Bonferroni 8 de 26, acima do esperado sem autocorrelação. Lags sinalizados: literal 70 (70 negativos, 0 positivos); recentrada 24 (23 acima do centro, 1 abaixo); recentrada com Bonferroni 13 (13 acima, 0 abaixo). A literal só pega lags muito negativos (o artefato dos estratos); a recentrada aponta autocorrelação residual positiva e pequena em parte das concentrações (auditoria independente, achado 2). A regra que decide a sensibilidade da Fase 4 é do chat.
- **p1 e p99 (ano inteiro) dentro dos Boundary.knots:** 26 de 26.
- **Dupla auditoria:** autoauditoria 22 de 22 iguais (26 ajustes refeitos com `glm`, diferença relativa máxima de 3.7e-08 nos coeficientes da cross-basis); auditoria independente com 8 achados (seção 6).
- **Ainda não** (Fase 3): RR, curva, MRT, contraste e gráficos.

## 2. Entradas, especificação e linhas passadas

- **Ambiente:** R 4.5.1; dlnm 2.4.10; gnm 1.1.5. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib` — de referência (§8; critério do desvio 65d). Semente 20261001, em série.
- **Código:** tag `ajusta_dlnm-v1.0` (objeto `344899ab4a8673f1ad9e7a8bdf53c4e17e51cd76`), commit `caf5022f9a655877d8e3931dd3d02d7dce429fe5`. SHA-256 no disco = SHA-256 na tag:
  - `codigo_compartilhado/R/.gitkeep`: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`;
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009`;
  - `codigo_compartilhado/R/offset.R`: `55111b2cc510d7b1c7b78b7f84e99997c5202825e0353da70bab0b4bea290bae`;
- **Entradas:** `01_saidas/fase1/serie_ptb_principal.rds` (SHA-256 `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917`) e `01_saidas/fase1/referencias_exposicao.csv` (SHA-256 `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467`).
- **Por que o CSV:** o código canônico da §1.5 calcula os percentis de `tmean_ref` de 2012-01-01 a 2024-12-31, mas a RDS termina em 2024-11-15, e os percentis não podem ser recalculados dela. O CSV foi feito com o código canônico (a conferência da Fase 1 deu diferença 0). Nós p10/p75/p90 e `cen` = p50 vêm das linhas de ano inteiro.
- **Linhas passadas à função**, por concentração: 2012-04-07 a 2024-08-06 (4.505 dias: os 7 de aquecimento, de 2012-04-07 a 2012-04-13, mais a janela principal de 4.498 dias), nada além (§1.5). Os Boundary.knots saem do range de `tmean_nucleo` nesse conjunto.
- **Especificação:** `ptb` ~ cross-basis (ns com nós p10/p75/p90 × ns com intercepto e nós `logknots(7, nk = 2)` = 0,982 e 2,622; lag 0–7) + `dia_semana` + `feriado_nacional` + `carnaval` + `moveis` + γ·`log_w`, offset `log_z`, `eliminate` = estrato (concentração × ano × mês), quasi-Poisson. Fallback (só para as falhas do §5, critério 4; desvio 65a): ns p50/p90 e lag em estratos 0–1, 2–4 e 5–7.

### Especificação usada e Boundary.knots, por concentração

| Concentração | Nós p10 / p75 / p90 (°C) | cen = p50 (°C) | Boundary.knots (°C) | p1 / p99 ref. (°C) | Dentro |
|---|---|---|---|---|---|
| São Paulo/SP | 16,594 / 23,855 / 25,477 | 21,327 | 6,863 a 30,175 | 12,581 / 27,644 | sim |
| Rio de Janeiro/RJ | 20,124 / 26,687 / 28,652 | 24,184 | 14,885 a 33,471 | 17,485 / 30,991 | sim |
| Belo Horizonte/MG | 19,416 / 24,679 / 25,827 | 22,976 | 12,430 a 31,300 | 16,899 / 28,270 | sim |
| Brasília/DF | 20,142 / 24,074 / 25,145 | 22,969 | 12,371 a 28,892 | 18,127 / 27,283 | sim |
| Recife/PE | 24,322 / 27,529 / 28,378 | 26,472 | 21,996 a 30,268 | 23,187 / 29,406 | sim |
| Porto Alegre/RS | 14,115 / 24,606 / 26,943 | 21,396 | 6,833 a 33,537 | 9,482 / 30,211 | sim |
| Fortaleza/CE | 26,803 / 28,689 / 29,272 | 28,033 | 23,894 a 31,783 | 25,411 / 30,480 | sim |
| Curitiba/PR | 13,785 / 22,143 / 24,019 | 19,282 | 3,218 a 27,979 | 8,989 / 26,325 | sim |
| Salvador/BA | 23,989 / 27,651 / 28,473 | 26,363 | 21,390 a 30,948 | 22,647 / 29,734 | sim |
| Goiânia/GO | 22,251 / 26,429 / 27,634 | 25,194 | 13,692 a 31,588 | 19,880 / 30,069 | sim |
| Campinas/SP | 17,870 / 24,717 / 26,064 | 22,464 | 8,864 a 30,452 | 13,664 / 27,966 | sim |
| Manaus | 26,456 / 29,089 / 29,964 | 28,238 | 22,705 a 33,312 | 24,911 / 31,662 | sim |
| Belém/PA | 27,119 / 28,782 / 29,176 | 28,287 | 23,772 a 30,744 | 25,466 / 29,969 | sim |
| Vitória/ES | 21,710 / 27,227 / 28,427 | 25,280 | 17,720 a 31,404 | 19,665 / 29,972 | sim |
| Baixada Santista/SP | 18,744 / 25,491 / 27,471 | 23,131 | 9,880 a 32,677 | 15,262 / 29,776 | sim |
| São José dos Campos/SP | 16,918 / 23,656 / 24,919 | 21,533 | 9,627 a 28,512 | 13,182 / 26,486 | sim |
| São Luís/MA | 26,729 / 28,946 / 29,494 | 28,203 | 23,712 a 31,001 | 25,027 / 30,248 | sim |
| Natal/RN | 25,320 / 28,002 / 28,568 | 27,209 | 22,847 a 30,185 | 24,185 / 29,351 | sim |
| Maceió/AL | 24,334 / 27,338 / 27,957 | 26,410 | 22,033 a 30,551 | 23,270 / 29,104 | sim |
| Florianópolis/SC | 16,543 / 24,450 / 26,395 | 21,795 | 8,692 a 32,558 | 12,545 / 28,856 | sim |
| João Pessoa/PB | 25,141 / 28,166 / 28,760 | 27,298 | 22,199 a 30,509 | 23,884 / 29,567 | sim |
| Teresina/PI | 26,821 / 29,612 / 30,816 | 28,219 | 24,073 a 33,062 | 25,386 / 31,908 | sim |
| Aracaju/SE | 25,042 / 28,071 / 28,686 | 27,143 | 22,681 a 31,507 | 23,864 / 29,917 | sim |
| Cuiabá/MT | 23,990 / 28,456 / 29,748 | 27,155 | 11,322 a 34,707 | 17,225 / 32,291 | sim |
| Sorocaba/SP | 17,718 / 24,733 / 26,179 | 22,444 | 8,383 a 31,053 | 13,313 / 28,337 | sim |
| Campo Grande | 19,882 / 26,977 / 28,195 | 25,331 | 7,978 a 32,581 | 12,599 / 30,529 | sim |

### Resumo nas 26 (C.6)

- **Status:** 26 de 26 com `status = "ok"` no principal; fallback em 0; não estimáveis 0; decisões pendentes 0.
- **φ > 2:** 0 de 26 (0,0%). Não passa de 25%: a binomial negativa não é acionada pela regra da §2.1.
- **PACF, regra literal da §2.1** (algum lag de 1 a 7 fora de ±2/√n): 25 de 26. Pela §2.1, nessas a sensibilidade com resíduos defasados entraria na Fase 4; a regra que vale é decisão pendente do chat (desvio 65c).
- **PACF, só descritivo (desvio 65c):** recentrada em −1/(m − 1): 13 de 26; recentrada com Bonferroni nos 7 lags: 8 de 26. A regra que vale para a Fase 4 é decisão do chat.
- **Sinal dos lags sinalizados** (lags de todas as concentrações): literal 70 (70 negativos, 0 positivos); recentrada 24 (23 acima do centro, 1 abaixo); recentrada com Bonferroni 13 (13 acima, 0 abaixo). Num modelo correto, a PACF fica em torno do centro −1/(m − 1), abaixo de 0.
- **p1 e p99 (ano inteiro) dentro dos Boundary.knots:** 26 de 26 (só reportado; desvio 59).

## 3. Diagnósticos por concentração


γ̂ sai só como diagnóstico, sem interpretação (§3.1).

| Concentração | Situação | Convergiu | Dim cb / red. | Dias usados (janela) | Dias sem base/offset | Estratos usados / removidos | Dias removidos (estrato vazio) | Autovalor mín. cb / red. | φ | γ̂ (EP) | QAIC |
|---|---|---|---|---|---|---|---|---|---|---|---|
| São Paulo/SP | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 1.75e-05 / 2.40e-04 | 1,112 | 1,102 (0,103) | 32.461,3 |
| Rio de Janeiro/RJ | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 3.40e-05 / 4.70e-04 | 1,081 | 1,138 (0,151) | 29.557,8 |
| Belo Horizonte/MG | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 8.02e-05 / 1.12e-03 | 0,997 | 1,362 (0,211) | 25.165,2 |
| Brasília/DF | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 1.05e-04 / 1.48e-03 | 1,033 | 0,685 (0,158) | 24.871,9 |
| Recife/PE | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 1.90e-04 / 2.47e-03 | 1,059 | 0,542 (0,161) | 24.865,0 |
| Porto Alegre/RS | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 1.22e-04 / 1.67e-03 | 0,981 | 0,902 (0,230) | 24.004,5 |
| Fortaleza/CE | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 1.38e-04 / 1.80e-03 | 1,025 | 1,015 (0,174) | 24.467,8 |
| Curitiba/PR | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 1.14e-04 / 1.54e-03 | 1,004 | 1,001 (0,291) | 22.974,3 |
| Salvador/BA | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 1.85e-04 / 2.52e-03 | 1,009 | 0,805 (0,254) | 23.383,7 |
| Goiânia/GO | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 1.64e-04 / 2.24e-03 | 1,000 | 0,961 (0,184) | 22.532,1 |
| Campinas/SP | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 1.57e-04 / 2.18e-03 | 0,993 | 0,786 (0,256) | 21.453,2 |
| Manaus | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 1.64e-04 / 2.22e-03 | 1,006 | 0,579 (0,268) | 22.949,3 |
| Belém/PA | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 2.85e-04 / 3.73e-03 | 1,118 | 0,762 (0,203) | 22.921,4 |
| Vitória/ES | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 2.07e-04 / 2.82e-03 | 0,997 | 0,691 (0,330) | 20.501,7 |
| Baixada Santista/SP | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 2.51e-04 / 3.46e-03 | 1,016 | 1,123 (0,258) | 20.258,2 |
| São José dos Campos/SP | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 1.99e-04 / 2.82e-03 | 0,982 | 1,021 (0,217) | 20.291,1 |
| São Luís/MA | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 2.67e-04 / 3.50e-03 | 1,065 | 0,844 (0,185) | 21.098,3 |
| Natal/RN | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 3.39e-04 / 4.56e-03 | 1,037 | 1,034 (0,218) | 20.433,9 |
| Maceió/AL | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 4.12e-04 / 5.56e-03 | 1,009 | 0,961 (0,218) | 19.672,9 |
| Florianópolis/SC | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 5.41e-04 / 7.49e-03 | 1,008 | 1,292 (0,331) | 17.375,7 |
| João Pessoa/PB | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 4.41e-04 / 6.01e-03 | 0,998 | 0,805 (0,239) | 18.941,5 |
| Teresina/PI | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 3.93e-04 / 5.07e-03 | 0,979 | 1,418 (0,253) | 19.044,9 |
| Aracaju/SE | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 7.11e-04 / 9.21e-03 | 1,034 | 1,476 (0,328) | 18.342,9 |
| Cuiabá/MT | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 4.72e-04 / 6.60e-03 | 0,985 | 1,650 (0,276) | 18.242,7 |
| Sorocaba/SP | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 4.23e-04 / 5.90e-03 | 1,023 | 1,487 (0,311) | 17.239,0 |
| Campo Grande | principal | sim | 16 / 4 | 4.498 (4.498) | 0 | 149 / 0 | 0 | 3.92e-04 / 5.40e-03 | 1,028 | 0,503 (0,316) | 17.725,2 |

## 4. PACF dos resíduos de deviance


| Concentração | Lags 1–7 | n | ±2/√n | Fora (literal) | −1/(m − 1) | Fora (recentrada) | Fora (recentrada + Bonferroni) |
|---|---|---|---|---|---|---|---|
| São Paulo/SP | 0,020; 0,011; -0,018; -0,026; -0,037; 0,011; -0,003 | 4.498 | 0,0298 | 5 | -0,0343 | 1,2,6,7 | 1,2,6 |
| Rio de Janeiro/RJ | 0,012; -0,012; -0,026; 0,009; -0,031; -0,025; -0,011 | 4.498 | 0,0298 | 5 | -0,0343 | 1,4 | 1,4 |
| Belo Horizonte/MG | -0,031; -0,025; -0,045; -0,045; -0,033; -0,038; -0,011 | 4.498 | 0,0298 | 1,3,4,5,6 | -0,0343 | — | — |
| Brasília/DF | -0,026; 0,011; 0,018; -0,013; -0,008; -0,044; -0,036 | 4.498 | 0,0298 | 6,7 | -0,0343 | 2,3 | 2,3 |
| Recife/PE | -0,036; -0,017; -0,032; -0,017; -0,016; -0,020; -0,011 | 4.498 | 0,0298 | 1,3 | -0,0343 | — | — |
| Porto Alegre/RS | -0,030; -0,007; -0,045; -0,071; -0,028; -0,057; -0,034 | 4.498 | 0,0298 | 1,3,4,6,7 | -0,0343 | 4 | — |
| Fortaleza/CE | -0,026; 0,010; -0,008; -0,032; -0,038; -0,029; -0,008 | 4.498 | 0,0298 | 4,5 | -0,0343 | 2 | 2 |
| Curitiba/PR | -0,006; -0,028; 0,002; 0,001; -0,030; -0,019; -0,040 | 4.498 | 0,0298 | 5,7 | -0,0343 | 3,4 | — |
| Salvador/BA | -0,026; -0,025; -0,021; -0,013; -0,031; -0,043; -0,043 | 4.498 | 0,0298 | 5,6,7 | -0,0343 | — | — |
| Goiânia/GO | 0,009; -0,007; -0,037; -0,029; -0,034; -0,020; -0,036 | 4.498 | 0,0298 | 3,5,7 | -0,0343 | 1 | 1 |
| Campinas/SP | -0,045; -0,031; -0,038; -0,019; -0,024; -0,025; -0,038 | 4.498 | 0,0298 | 1,2,3,7 | -0,0343 | — | — |
| Manaus | -0,013; -0,019; -0,034; -0,052; -0,052; 0,009; -0,021 | 4.498 | 0,0298 | 3,4,5 | -0,0343 | 6 | 6 |
| Belém/PA | -0,026; -0,011; -0,020; 0,010; -0,026; -0,035; 0,024 | 4.498 | 0,0298 | 6 | -0,0343 | 4,7 | 4,7 |
| Vitória/ES | -0,048; -0,041; -0,055; -0,045; -0,029; -0,050; -0,028 | 4.498 | 0,0298 | 1,2,3,4,6 | -0,0343 | — | — |
| Baixada Santista/SP | -0,022; -0,005; -0,040; -0,014; -0,026; -0,011; -0,013 | 4.498 | 0,0298 | 3 | -0,0343 | — | — |
| São José dos Campos/SP | -0,034; -0,025; -0,036; -0,019; -0,014; -0,027; -0,011 | 4.498 | 0,0298 | 1,3 | -0,0343 | — | — |
| São Luís/MA | 0,003; -0,004; 0,006; 0,000; -0,001; -0,017; -0,007 | 4.498 | 0,0298 | — | -0,0343 | 1,2,3,4,5 | — |
| Natal/RN | -0,053; -0,009; -0,012; 0,014; -0,025; -0,031; -0,006 | 4.498 | 0,0298 | 1,6 | -0,0343 | 4 | 4 |
| Maceió/AL | -0,018; -0,029; -0,017; -0,049; -0,046; -0,008; -0,045 | 4.498 | 0,0298 | 4,5,7 | -0,0343 | — | — |
| Florianópolis/SC | -0,022; -0,032; -0,045; -0,038; -0,036; -0,015; -0,051 | 4.498 | 0,0298 | 2,3,4,5,7 | -0,0343 | — | — |
| João Pessoa/PB | -0,012; -0,017; -0,040; -0,045; -0,007; -0,004; -0,046 | 4.498 | 0,0298 | 3,4,7 | -0,0343 | 6 | — |
| Teresina/PI | -0,044; -0,020; -0,010; -0,024; -0,037; -0,008; -0,003 | 4.498 | 0,0298 | 1,5 | -0,0343 | 7 | — |
| Aracaju/SE | -0,020; -0,041; -0,039; -0,042; -0,025; -0,029; -0,043 | 4.498 | 0,0298 | 2,3,4,7 | -0,0343 | — | — |
| Cuiabá/MT | -0,006; -0,031; -0,022; -0,038; -0,030; -0,031; -0,037 | 4.498 | 0,0298 | 2,4,5,6,7 | -0,0343 | — | — |
| Sorocaba/SP | -0,023; -0,019; -0,040; -0,045; -0,006; -0,057; -0,015 | 4.498 | 0,0298 | 3,4,6 | -0,0343 | — | — |
| Campo Grande | -0,009; -0,012; -0,031; -0,027; -0,024; -0,020; -0,006 | 4.498 | 0,0298 | 3 | -0,0343 | — | — |

## 5. Saídas


- `01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds`: `5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d`;
- `01_saidas/fase2/reduzida_coef_vcov_fase2_20261010.csv`: `50f58701005f9cbaf722f5043844f0e6680be5717b011419b2b3b4b688e58c4d`;
- `01_saidas/fase2/crossbasis_coef_vcov_fase2_20261010.csv`: `8eed876c0bc0983705305042324c79ab1f0d619a41a97d8139503b73957e4ddd`;
- `01_saidas/fase2/pacf_fase2_20261010.csv`: `5ab465ab5b1059896f596842e52c78aa0978090cafb4ebd2ef8ddbe5a7e7908f`;
- `01_saidas/fase2/diagnosticos_fase2_20261010.csv`: `0f28e346a39cc242bd42a225cc2c7090d408298d43277aba37e291b0391c02eb`;
- Conteúdo: a RDS tem a saída completa da função por concentração (coeficientes e vcov da cross-basis e reduzidos, com a dimensão; atributos da base; γ̂, φ, QAIC, PACF e diagnósticos), sem resíduos, valores ajustados nem série diária; os CSVs têm os coeficientes e as vcov (formato longo, 17 dígitos), a PACF e os diagnósticos.

**Ainda não** (Fase 3): RR, curva, MRT e contraste.

`versao()` no fim: 4443971b.
**Como ler os CSVs (para a Fase 3):** `read.csv(arquivo, colClasses = c(recorte_principal = "character"))` (sem isso, o código IBGE vira inteiro). Os números estão gravados como texto com 17 dígitos significativos e são convertidos pelo `read.csv`, com erro de até 1 ULP; a RDS guarda os valores exatos. Formato longo: `tipo` = coef (índice `i`) ou vcov (`i`, `j`), `dim` = 16 ou 4. Na cross-basis, a ordem dos coeficientes é a do dlnm (v1.l1, v1.l2, …, v4.l4: base da temperatura por fora, base do lag por dentro); na reduzida, os 4 coeficientes são os da base da temperatura (ns com nós p10/p75/p90 e os Boundary.knots da concentração). Os atributos completos da base (`argvar` com `intercept`, `arglag`, `lag`) estão só na RDS.

## 6. Dupla auditoria

### Autoauditoria (`35_autoauditoria_fase2C.R`)

- **Método:** os 26 ajustes foram refeitos com `glm(quasipoisson)` + `factor(estrato)` (epsilon 1e-12), sem `ajusta_dlnm()`, com as referências lidas à mão (`readLines`/`strsplit`); a redução, com `crossreduce`; a PACF, com `pacf()` direto nos resíduos de deviance (a janela é contínua). Cada número foi comparado com as saídas e procurado no texto do log com a mesma formatação.
- **Maiores diferenças** (glm × função): coeficientes da cross-basis 3.7e-08; vcov 16 × 16 3.9e-08; coeficientes reduzidos 9.4e-08; vcov 4 × 4 3.9e-08 (relativas); PACF 1.1e-09 (absoluta).
- **Tolerâncias** (mudadas depois de ver o resultado: a 1ª rodada deste script deu 2 conferências diferentes sem defeito, e a 2ª só imprimiu as diferenças; os dois logs estão na lixeira, com os SHA-256 no desvio 66): φ, relativa ≤ 1e-6, porque a diferença glm × gnm é ruído de convergência da mesma ordem que a dos coeficientes (φ: 2.1e-08); nós, cen e Boundary.knots, ≤ 1e-12, porque o `read.csv` do R lê textos de 17 dígitos com até 1 ULP de erro (máx. 3.6e-15; a RDS guarda os valores exatos).

### Resultado: 22 de 22 conferências iguais

| Item | Conferência | N | Resultado |
|---|---|---|---|
| Código | SHA-256 de cada arquivo de codigo_compartilhado/R/ na tag (git show) = o do log |  3 | igual |
| Código | disco = tag (git diff vazio em codigo_compartilhado/R/) |  1 | igual |
| BLAS | BLAS e LAPACK de referência (libRblas.0.dylib / libRlapack.dylib) e iguais aos do log |  2 | igual |
| Saídas | SHA-256 das 5 saídas gravadas = os do log |  5 | igual |
| Linhas | 4.505 linhas por concentração (2012-04-07 a 2024-08-06), 7 de aquecimento fora da janela | 26 | igual |
| Linhas | período e n das linhas passadas no log |  1 | igual |
| Ajustes (glm) | coeficientes da cross-basis: dif. relativa máx. ≤ 1e-6 | 26 | igual |
| Ajustes (glm) | vcov da cross-basis 16 × 16: dif. relativa máx. ≤ 1e-6 | 26 | igual |
| Ajustes (glm) | coeficientes reduzidos (crossreduce): dif. relativa máx. ≤ 1e-6 | 26 | igual |
| Ajustes (glm) | vcov reduzida 4 × 4: dif. relativa máx. ≤ 1e-6 | 26 | igual |
| Ajustes (glm) | φ (dif. relativa ≤ 1e-6), γ̂ (dif. ≤ 1e-6), EP de γ (dif. relativa ≤ 1e-6), QAIC (dif. relativa ≤ 1e-8) | 26 | igual |
| PACF | lags 1 a 7 (pacf direto nos resíduos do glm; dif. ≤ 1e-6) e as três regras de "fora" | 26 | igual |
| Especificação | nós p10/p75/p90 e cen = p50 iguais aos do CSV de referências (lido à mão); Boundary.knots = range das linhas passadas (dif. ≤ 1e-12) | 26 | igual |
| Dimensões e dias | 16 e 16 × 16; 4 e 4 × 4; 4.498 dias e todos os estratos usados, nenhum removido | 26 | igual |
| Log | as 26 linhas da tabela de especificação (nós, cen, Boundary.knots, p1/p99) | 26 | igual |
| Log | as 26 linhas da tabela de diagnósticos (com os valores do glm) | 26 | igual |
| Log | as 26 linhas da tabela da PACF (com os valores do glm) | 26 | igual |
| Log | resumo nas 26 (φ > 2, PACF nas três regras, p1/p99 dentro) |  5 | igual |
| RDS | 26 concentrações, as do cidade_nucleo(), com tag, commit e SHA-256 do código iguais aos do log | 26 | igual |
| RDS | nenhum vetor com tamanho de série diária (máximo < 1.000 elementos; a vcov 16 × 16 tem 256) |  1 | igual |
| RDS | spec, nós e Boundary.knots da base, arglag (nós e intercepto), lag 0–7, df 4 × 4, cen da reduzida = p50 e RR no cen = 1 | 26 | igual |
| Log | sinal dos lags sinalizados nas três regras (recalculado dos valores do glm) |  1 | igual |

`versao()` no fim: 4443971b.
### Auditoria independente

Transcrita de `logs/auditoria_fase2C_20261010.md`.


Registro achado → reprodução → correção, como manda o `CLAUDE.md` do artigo. Só logs, scripts e resultados de modelo agregados por concentração; nenhuma linha individual.

### Etapa 1: autoauditoria (`00_scripts/35_autoauditoria_fase2C.R`)

- **1ª rodada** (log SHA-256 `aff65474e024016d3cf3ae77464d35a8c6fbc209ef2666ba02ff186f8d913860`, na lixeira): 16 de 18. Ficaram "DIFERENTE":
  - o φ, com tolerância relativa de 1e-8 contra uma diferença glm × gnm de 2,1e-8;
  - os nós, o `cen` e os Boundary.knots, com igualdade exata contra uma diferença de 3,55e-15 (1 ULP do `read.csv` com textos de 17 dígitos).
- **2ª rodada** (log `3b119204cb470d0f75351ab9bb8856a79a7ec19d3665c737ee4bfe3d0c6ed36e`, na lixeira): só imprimiu as diferenças, com o mesmo resultado.
- **Tolerâncias:** passaram a 1e-6 (relativa, φ) e 1e-12 (nós, `cen`, Boundary.knots), depois de ver o resultado. Isso está no desvio 66(a).
- **3ª rodada** (log `c7c6c9678df036b7003802f2f7f4737f6c26a7f1ff51537c3d06ac55a8e1e36e`, na lixeira): 18 de 18. Foi substituída pela 4ª depois da auditoria independente (achados 3 e 4).
- **4ª rodada, a que vale** (`logs/autoauditoria_fase2C_20261010.md`): 22 de 22. Passou a conferir também o conteúdo da RDS (spec, base, `cen` e RR no `cen`, nenhum vetor com tamanho de série), o LAPACK e o sinal dos lags sinalizados, e a gravar o `sessionInfo()` completo.

### Auditoria independente

- **Auditor:** subagente em contexto limpo, só de leitura. Leu:
  - os scripts 32 e 35 e o código da tag;
  - os logs do 32, do 35 e da auditoria da Parte B, e os desvios 51 a 65;
  - a §4 da RESPOSTA da Fase 1 e a especificação;
  - o `referencias_exposicao.csv` (exposição, dado público) e os 4 CSVs de resultado de modelo.

  Não abriu nenhum `.rds`, `.parquet` ou `.dbc`, nem a base. Rodou o nulo simulado com dado sintético e conferências sobre os CSVs, com os scripts `aud7_*` no scratchpad da sessão. Não usou a rede.
- **Veredito do auditor:**
  - a Parte C pode ir para a RESPOSTA e o commit local depois de três correções, nenhuma das quais muda estimativa;
  - o código é o da tag e o BLAS é o de referência;
  - as 26 concentrações deram "ok", com dimensões 16 e 16 × 16 e 4 e 4 × 4;
  - nós e `cen` batem com o arquivo de referências;
  - o log bate com os CSVs, e não há problema de sigilo.
- **Achados:** 8
  - 3 marcados como "corrigir antes da RESPOSTA" (1, 3 e 4), 2 como "para o chat" (2 e 5) e 3 como "nota" (6 a 8).
  - Todos foram reproduzidos por código próprio da sessão (`repro_aud7.R`, sobre os CSVs de resultado) ou pela leitura de código e de metadados.
  - As correções estão no desvio 66, registrado antes de rodar de novo o 32 e o 35.

| Nº | Achado (classificação do auditor) | Reprodução | Correção ou destino |
|---|---|---|---|
| 1 | O texto da PACF no log do 32 afirmava que a sensibilidade "entra na Fase 4" e, logo abaixo, que a regra é decisão do chat; também omitia a calibração do nulo (corrigir antes da RESPOSTA) | Os 70 lags sinalizados pela literal são todos negativos; em São Paulo, a literal escolhe o lag 5, e a recentrada, os lags 1, 2, 6 e 7 | O log do 32 foi gerado de novo, com texto condicional ("entraria na Fase 4; a regra que vale é decisão pendente do chat") e o sinal dos lags sinalizados em cada regra. A calibração do nulo (auditoria da Parte B) vai para a RESPOSTA |
| 2 | A escolha da regra da PACF tem evidência que o chat ainda não viu (para o chat) | A recentrada sinaliza 24 lags, 23 acima do centro e 1 abaixo; com Bonferroni, 13, todos acima. A média nas 26 de PACF − centro é positiva em todos os lags (+0,007 a +0,018; EP médio ≈ 0,003). P(≥ 13 de 26) vai de 0,007 a 0,033, e P(≥ 8 de 26) de 6e-7 a 6e-5, conforme a taxa nula (a da sessão, de 0,31 e 0,03, ou a do auditor, de 0,257 a 0,286 e 0,040 a 0,056) | Para o chat, antes de fixar o gatilho da Fase 4 (desvio 66d). Leitura: há autocorrelação residual positiva e pequena numa parte das concentrações, e a regra literal aponta sinal e lags errados |
| 3 | A autoauditoria afrouxou tolerâncias depois de ver o resultado, sem desvio; o log falava em "1ª rodada", e eram duas (corrigir antes da RESPOSTA) | Na lixeira há dois logs anteriores do 35, de 2.951 bytes cada, ambos de 18:03 | Desvio 66(a), com os SHA-256 e as tolerâncias originais. O texto do 35 fala das duas rodadas |
| 4 | Nenhum código conferia o `cen` efetivo nem o conteúdo da RDS (corrigir antes da RESPOSTA) | O 35 não lia a RDS; os nós e o `cen` do log e do CSV eram cópia da entrada | O 35 lê a RDS e confere, nas 26: a spec, os nós e os Boundary.knots da base, a `arglag`, `lag` e `df`, o `cen` e o RR no `cen` da reduzida, e que nenhum vetor tem tamanho de série. Passa em 26 de 26 |
| 5 | Fallback: o caminho em que o `gnm` devolve NULL não está entre os motivos de fallback, e a função `efetivo()` nunca era usada (para o chat) | Leitura: `MOTIVOS_FALLBACK` não inclui "o gnm não devolveu modelo" | Para o chat, com o 65(a) (desvio 66d). A função `efetivo()` saiu do 32. Não afeta a Parte C, porque as 26 deram "ok" |
| 6 | Algumas comparações do 35 são frouxas: escala pelo maior elemento, o LAPACK não era comparado com o log, e `no_texto` só confere presença (nota) | Leitura | O LAPACK passou a ser comparado. O resto fica como nota (desvio 66e); as conferências do auditor sobre os CSVs não acharam nada |
| 7 | Formato dos CSVs para a Fase 3 (nota) | Leitura | Receita de leitura na RESPOSTA: `colClasses` em `recorte_principal`, números com 17 dígitos entre aspas, coeficientes da cross-basis na ordem do dlnm (v1.l1 a v4.l4) |
| 8 | Rastreabilidade: nenhum log grava o SHA do próprio script, e falta o `sessionInfo()` completo (§8) (nota) | Leitura | A RESPOSTA traz o SHA-256 do 32, do 35 e do 36. O 35 grava `logs/sessionInfo_fase2C_20261010.txt` |

#### Conferido e aprovado pelo auditor (resumo)

- **Código e ambiente:**
  - a tag `ajusta_dlnm-v1.0` aponta para o `caf5022`;
  - os SHA-256 dos 3 arquivos de `R/` são iguais no `git show`, no disco e no log;
  - o BLAS e o LAPACK são os de referência, sem vecLib ativo;
  - dlnm 2.4.10 e gnm 1.1-5.
- **Especificação:**
  - nós e `cen` iguais aos do arquivo de referências (26 linhas de ano inteiro, 4.749 dias), com a ordem p10 < p50 < p75 < p90;
  - `arglag` com nós 0,982 e 2,622.
- **Linhas e Boundary.knots:**
  - de 2012-04-07 a 2024-08-06, 4.505 dias por concentração, e a janela é exatamente data ≥ 2012-04-14;
  - os Boundary.knots vêm do objeto ajustado e contêm os nós e o p1 e o p99 nas 26.
- **Entradas e dimensões:**
  - as 26 concentrações estão nos 4 CSVs, com 20 linhas reduzidas e 272 da cross-basis por concentração;
  - sem NA, com vcov simétricas e positivas-definidas;
  - a redução refeita a partir da cross-basis reproduz os CSVs reduzidos.
- **Log:**
  - as 3 tabelas são iguais aos CSVs;
  - as regras da PACF, recalculadas, dão as mesmas colunas e as contagens 25, 13 e 8.
- **Escopo e sigilo:**
  - C.1 a C.7 e os desvios 59 e 65 estão implementados;
  - o desvio 65 foi gravado antes da rodada;
  - não há resíduo, valor ajustado, série diária nem contagem de eventos no log ou nos CSVs.

### Regeneração (desvio 66b)

O 32 rodou de novo com as mesmas entradas. As 5 saídas saíram byte a byte iguais às da 1ª rodada, com os mesmos SHA-256; só o log mudou.

| Arquivo | 1ª rodada (na lixeira) | Rodada que vale |
|---|---|---|
| `logs/primeira_etapa_fase2_20261010.md` | `196767d71cd6979dd3c11bc0402fef818787cfe99b4c375d25ad487bd1852932` | `5a49d2ab7bc4f7b6c48b3fe167a36b04c0b953df5ffc28e4cebd7b9a571c66b6` |
| `logs/autoauditoria_fase2C_20261010.md` | `c7c6c9678df036b7003802f2f7f4737f6c26a7f1ff51537c3d06ac55a8e1e36e` (3ª rodada do 35) | `bf6892c0664752c5f0562f2ca48fc95f16c00359e8cc5506bdd888ecd8ff7a16` |
| `01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds` | `5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d` | idêntico |
| `01_saidas/fase2/reduzida_coef_vcov_fase2_20261010.csv` | `50f58701005f9cbaf722f5043844f0e6680be5717b011419b2b3b4b688e58c4d` | idêntico |
| `01_saidas/fase2/crossbasis_coef_vcov_fase2_20261010.csv` | `8eed876c0bc0983705305042324c79ab1f0d619a41a97d8139503b73957e4ddd` | idêntico |
| `01_saidas/fase2/pacf_fase2_20261010.csv` | `5ab465ab5b1059896f596842e52c78aa0978090cafb4ebd2ef8ddbe5a7e7908f` | idêntico |
| `01_saidas/fase2/diagnosticos_fase2_20261010.csv` | `0f28e346a39cc242bd42a225cc2c7090d408298d43277aba37e291b0391c02eb` | idêntico |
## 7. Desvios

O desvio 64 é da Parte B (tag com 19/20); o 65, das escolhas da Parte C, registrado antes de rodar; o 66, das correções da auditoria independente da Parte C, registrado antes de rodar de novo o 32 e o 35.

| # | Data | Etapa | Referência | O que divergiu | Causa | Efeito nos resultados | Decisão | Evidência |
|---|---|---|---|---|---|---|---|---|
| 64 | 2026-10-10 | Fase 2, Parte B (registrado antes da tag) | Prompt da Fase 2 v1.1, Parte B, passo 2 ("Rode os testes de novo: n/n"); `logs/auditoria_fase2B_20261010.md` (auditoria final, 10 achados) | **Tag `ajusta_dlnm-v1.0` no `caf5022` com 19/20 testes, e não n/n.** (a) O 37 (`00_scripts/37_testes_tag_fase2B.R`, previsto no desvio 58) deu 19/20 na `ajusta_dlnm()` e 21/21 no `offset.R`, com o mesmo resultado por teste e as mesmas coberturas do log do 31 e o mesmo resultado da Fase 1. A única falha é a do 5b, com a mesma mensagem (desvio 61); com a mesma semente, ela se repete em qualquer rodada, e o n/n do passo 2 nunca fecha. Guilherme decidiu criar a tag assim ("caminho A", 10/10), sem mudar critério, réplicas nem semente depois de ver o resultado. (b) **Escopo da v1.0:** o modelo principal e as sensibilidades que só mudam dados ou colunas (lags, janelas com lacuna, offsets `zw` e `nenhum`, CTS municipal com `group`, umidade, PM2.5, controle negativo). Binomial negativa, resíduos defasados, S3 e a análise em uma etapa exigem mudar a função: v1.1, com tag e desvio antes da Fase 4. (c) O desvio 63 mexeu em `codigo_compartilhado/R/` depois da re-auditoria; a auditoria final (independente) revisou a versão que recebe a tag. (d) **Para o 32 (Parte C), antes de rodar:** a regra da PACF da §2.1 é decisão do chat e fica em quem chama (a função devolve valores, n e limite; num nulo simulado, a regra literal sinaliza todas as réplicas); o fallback só se aplica a falha de convergência, aliasamento na cross-basis ou vcov, e qualquer outra falha para e informa; com `z_w_gama`, γ = NA vira falha (o `gnm` devolve γ aliasado com status "ok" e EP 0); critério explícito de BLAS; os SHA-256 do código saem do `git show` da tag. (e) **Registro corrigido:** a RESPOSTA da Parte A diz PACF "~−0,036 em todos os lags", mas os valores médios vão de −0,032 a −0,037; o desvio 60 dizia que `67cecbd` e `ded4fbd` estavam sem push, e eles já estão no `origin/main`; no 31, o t09a pega o defeito "`z_w_gama` com offset `log_zw`" só por ruído numérico (4,1e-10 > 1e-10), e quem pega de fato são o t01 e o t05. (f) Os dois primeiros logs do 37 foram para a lixeira (linha de commit quebrada; texto "idênticos" forte demais), com os SHA-256 na auditoria final. O `DESCRIPTION` de `codigo_compartilhado/` está desatualizado; fica fora de `R/` e vai num commit posterior | Falha conhecida do 5b (desvio 61), decisão de Guilherme e achados da auditoria final | Nenhum nas estimativas | Guilherme, 10/10 (caminho A: desvio 64, commit local e tag no `caf5022`) | `logs/testes_tag_fase2B_20261010.md`; `logs/auditoria_fase2B_20261010.md`; tag `ajusta_dlnm-v1.0` |
| 65 | 2026-10-10 | Fase 2, Parte C (registrado antes de rodar) | Prompt da Fase 2 v1.1, Parte C (C.4 e C.6); especificação §2.1, §5 (critério 4) e §8; achados 2, 4 e 5 da auditoria final (`logs/auditoria_fase2B_20261010.md`) | **Escolhas do `32_primeira_etapa_principal.R`, antes de rodar.** (a) **Fallback:** só quando a falha é das que o §5, critério 4, cobre: não convergência, coeficiente da cross-basis aliasado, vcov indisponível ou vcov (da cross-basis ou reduzida) não positiva-definida. Qualquer outra falha (erro na cross-basis, no ajuste, em φ/QAIC/PACF ou no `crossreduce`; nenhuma linha de ajuste) não dispara o fallback: a concentração fica como decisão pendente, as outras terminam e o script para. A C.4 manda aplicar o fallback a qualquer "falhou"; a leitura segue o §5. (b) **γ:** com `z_w_gama`, γ̂ NA (aliasado) ou EP não finito vira decisão pendente (o `gnm` devolve γ aliasado com status "ok" e EP 0). (c) **PACF:** o resumo da C.6 e o gatilho da sensibilidade de resíduos defasados (Fase 4) usam a regra literal da §2.1 (algum lag de 1 a 7 fora de ±2/√n). Ao lado, só descritivas e calculadas dos mesmos valores devolvidos pela função, duas colunas: a regra recentrada em −1/(m − 1), com m = dias usados / estratos usados, e a recentrada com Bonferroni nos 7 lags (z = qnorm(1 − 0,05/14)). A escolha da regra para a Fase 4 é do chat. (d) **BLAS:** critério explícito: `basename` do BLAS = `libRblas.0.dylib` e do LAPACK = `libRlapack.dylib` (os de referência do R, §8); se não, para antes de ajustar. (e) **Código:** o SHA-256 de cada arquivo de `codigo_compartilhado/R/` no disco tem de ser igual ao do `git show ajusta_dlnm-v1.0:<arquivo>`, e a tag tem de apontar para o `caf5022`; se não, para. (f) **Saídas** fora do git (desvio 59), em `01_saidas/fase2/`, com o SHA-256 de cada arquivo no log e na RESPOSTA: RDS com a saída completa da função por concentração (sem resíduos, valores ajustados nem série diária) e CSVs dos coeficientes e vcov reduzidos e da cross-basis (formato longo, 17 dígitos), da PACF e dos diagnósticos. (g) O log traz dias e estratos usados e removidos, e não contagens de eventos (já descritas na Fase 1). (h) Diagnóstico do p1 e do p99 (ano inteiro, `referencias_exposicao.csv`) dentro dos Boundary.knots, só reportado (desvio 59). (i) Autoauditoria no 35 e RESPOSTA no 36 (desvio 58) | Achados da auditoria final; o §5 só prevê o fallback para convergência e vcov; a regra literal da PACF dispara em quase todo modelo correto (Parte A) | Nenhum nas estimativas do principal | Decisão da sessão antes de rodar, depois de "PRIMEIRA ETAPA LIBERADA" (10/10); (a) e (c) a revisar pelo chat | `00_scripts/32_primeira_etapa_principal.R`; `logs/primeira_etapa_fase2_20261010.md` |
| 66 | 2026-10-10 | Fase 2, Parte C, auditoria independente (registrado antes de rodar de novo) | `logs/auditoria_fase2C_20261010.md`: 8 achados, reproduzidos | **Correções de registro e de conferência, sem mudar estimativa.** (a) **Tolerâncias do 35, mudadas depois de ver o resultado:** a 1ª rodada (log SHA-256 `aff65474e024016d3cf3ae77464d35a8c6fbc209ef2666ba02ff186f8d913860`) deu 16 de 18. Ficaram "DIFERENTE" o φ (tolerância relativa 1e-8; diferença glm × gnm de 2,1e-8, ruído de convergência da mesma ordem que o dos coeficientes) e os nós, `cen` e Boundary.knots (igualdade exata; diferença de 3,55e-15, 1 ULP do `read.csv` com textos de 17 dígitos). A 2ª rodada (log `3b119204cb470d0f75351ab9bb8856a79a7ec19d3665c737ee4bfe3d0c6ed36e`) só imprimiu as diferenças, com o mesmo resultado. As tolerâncias passaram a 1e-6 (relativa, φ) e 1e-12 (nós, `cen`, Boundary.knots). Os dois logs estão na lixeira. (b) **Log do 32 gerado de novo:** o texto da PACF passa a condicional (pela regra literal, as concentrações sinalizadas teriam a sensibilidade com resíduos defasados na Fase 4; a regra que vale é decisão pendente do chat, desvio 65c) e traz o sinal dos lags sinalizados em cada regra; sai a função `efetivo()`, que nunca foi usada. O 32 roda de novo com as mesmas entradas; log e saídas anteriores vão para a lixeira, com os SHA-256 na auditoria. (c) **35:** passa a ler a RDS e conferir, nas 26, a spec (desfecho, exposição, janela, lag, offset, covariáveis, estrato, `cen` = p50), os nós e os Boundary.knots da base, a `arglag` (nós e intercepto), `lag` e `df`, o `cen` e o RR no `cen` da curva reduzida, e que nenhum vetor da RDS tem tamanho de série diária; compara também o LAPACK com o do log; grava o `sessionInfo()` completo em `logs/sessionInfo_fase2C_<data>.txt` (§8). (d) **Para o chat**, com o 65(a) e o 65(c): o caminho em que o `gnm` devolve NULL ("o gnm não devolveu modelo") não está entre os motivos de fallback do 32 e cairia em "pendente"; a PACF recentrada aponta desvios positivos e a literal só negativos, e as concentrações sinalizadas pela recentrada e pela recentrada com Bonferroni passam do esperado sem autocorrelação. (e) Notas sem mudança: no 35, as comparações relativas usam o maior elemento como escala; formato dos CSVs (números entre aspas, `recorte_principal` lido como inteiro sem `colClasses`, coeficientes da cross-basis na ordem do dlnm, v1.l1 a v4.l4), documentado na RESPOSTA | Achados da auditoria independente da Parte C | Nenhum nas estimativas | Corrigido antes da RESPOSTA; 32 e 35 rodam de novo | `logs/auditoria_fase2C_20261010.md`; `00_scripts/32`, `35` |

## 8. Comandos para reproduzir

Da pasta `artigo1_prematuridade/`, com o `renv` do artigo (R 4.5.1), nesta ordem. Cada script tem trava contra sobrescrita.

```
FASE2_DATA=20261010 Rscript 00_scripts/32_primeira_etapa_principal.R
FASE2_DATA=20261010 Rscript 00_scripts/35_autoauditoria_fase2C.R
FASE2_DATA=20261010 Rscript 00_scripts/36_resposta_fase2C.R
```

**BLAS/LAPACK** (log do 32): `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib`.

**`versao()` no início e no fim de cada script:**

| Log | Script | Início | Fim |
|---|---|---|---|
| `primeira_etapa_fase2_20261010.md` | `00_scripts/32_primeira_etapa_principal.R` | 4443971b | 4443971b |
| `autoauditoria_fase2C_20261010.md` | `00_scripts/35_autoauditoria_fase2C.R` | 4443971b | 4443971b |
| (este retorno) | `00_scripts/36_resposta_fase2C.R` | 4443971b | 4443971b (conferido no fim do script) |

**SHA-256 dos scripts** (no momento de gravar este retorno):

| Arquivo | SHA-256 |
|---|---|
| `artigo1_prematuridade/00_scripts/32_primeira_etapa_principal.R` | `86ef65b89f64bd1b9dfaf883e70741fc844cf8054551af3778b45c851a88cbc2` |
| `artigo1_prematuridade/00_scripts/35_autoauditoria_fase2C.R` | `62f1fa3ad6ecbd78b7dc758f23e281814696c0a0906d3db4bc6b41b20d4aa60e` |
| `artigo1_prematuridade/00_scripts/36_resposta_fase2C.R` | `cf67e19ada1435bfa306955b35539f3c3236bd79ba972d602c8438c4be29a031` |

## 9. `git status`

Saída de `git status --porcelain --untracked-files=all`, tirada antes de gravar este retorno e antes do commit local da Parte C. Os arquivos de outras sessões (Artigos 2 e 3), se houver, só são mostrados; as saídas em `01_saidas/` ficam fora do git:

```
 M artigo1_prematuridade/logs/desvios_especificacao.md
 M artigo2_obito_perinatal/CLAUDE.md
 M artigo2_obito_perinatal/logs/confirmacoes_fase0_20261009.md
 M artigo2_obito_perinatal/logs/desvios_especificacao.md
 M artigo3_pig/00_scripts/14_varredura_sigilo_commit.py
?? artigo1_prematuridade/00_scripts/32_primeira_etapa_principal.R
?? artigo1_prematuridade/00_scripts/35_autoauditoria_fase2C.R
?? artigo1_prematuridade/00_scripts/36_resposta_fase2C.R
?? artigo1_prematuridade/logs/auditoria_fase2C_20261010.md
?? artigo1_prematuridade/logs/autoauditoria_fase2C_20261010.md
?? artigo1_prematuridade/logs/primeira_etapa_fase2_20261010.md
?? artigo1_prematuridade/logs/sessionInfo_fase2C_20261010.txt
?? artigo2_obito_perinatal/00_scripts/15_fluxos_neonatais.R
?? artigo2_obito_perinatal/00_scripts/16_inventario_fase1.R
?? artigo2_obito_perinatal/00_scripts/17_funcoes_wj.R
?? artigo2_obito_perinatal/00_scripts/18_testes_wj.R
?? artigo2_obito_perinatal/00_scripts/19_contagens_wj.R
?? artigo2_obito_perinatal/00_scripts/20_serie_principal.R
?? artigo2_obito_perinatal/00_scripts/21_diagnosticos_offset.R
?? artigo2_obito_perinatal/00_scripts/22_autoauditoria_fase1.py
?? artigo2_obito_perinatal/00_scripts/23_resposta_fase1.R
?? artigo2_obito_perinatal/00_scripts/24_reproduz_auditoria_fase1.R
?? artigo2_obito_perinatal/00_scripts/25_reproduz_confirmacao_fase1.R
?? artigo2_obito_perinatal/RESPOSTA_artigo2_obito_perinatal_FASE1_20261010.md
?? artigo2_obito_perinatal/logs/auditoria_fase1_20261010.md
?? artigo2_obito_perinatal/logs/autoauditoria_python_fase1_20261010.md
?? artigo2_obito_perinatal/logs/confirmacoes_fase1_20261010.md
?? artigo2_obito_perinatal/logs/contagens_wj_fase1_20261010.md
?? artigo2_obito_perinatal/logs/diagnosticos_offset_fase1_20261010.md
?? artigo2_obito_perinatal/logs/fase1_log_20261010.md
?? artigo2_obito_perinatal/logs/fluxos_neonatais_fase1_20261010.md
?? artigo2_obito_perinatal/logs/inventario_fase1_20261010.md
?? artigo2_obito_perinatal/logs/prompt_fase1_20261010.md
?? artigo2_obito_perinatal/logs/reproducao_auditoria_fase1_20261010.md
?? artigo2_obito_perinatal/logs/reproducao_confirmacao_fase1_20261010.md
?? artigo2_obito_perinatal/logs/serie_principal_fase1_20261010.md
?? artigo2_obito_perinatal/logs/sessionInfo_fase1_20261010.txt
?? artigo2_obito_perinatal/logs/testes_wj_fase1_20261010.md
?? artigo3_pig/00_scripts/15_testa_funcoes_pig.R
?? artigo3_pig/00_scripts/16_recodificacao_fluxograma.R
?? artigo3_pig/00_scripts/17_grupos_municipio.R
?? artigo3_pig/00_scripts/18_monta_celulas.R
?? artigo3_pig/00_scripts/19_exposicao_crossbasis.R
?? artigo3_pig/00_scripts/20_r2_identificacao.R
?? artigo3_pig/00_scripts/21_confere_gigs.R
?? artigo3_pig/00_scripts/22_viabilidade.R
?? artigo3_pig/00_scripts/23_teste_ep_escore_z.R
?? artigo3_pig/00_scripts/24_sessioninfo_fase1.R
?? artigo3_pig/00_scripts/25_autoauditoria_fase1.py
?? artigo3_pig/00_scripts/26_reproduz_achados_auditoria_fase1.R
?? artigo3_pig/00_scripts/funcoes_pig.R
?? artigo3_pig/RESPOSTA_artigo3_pig_FASE1_20261010.md
?? artigo3_pig/logs/auditoria_fase1_20261010.md
?? artigo3_pig/logs/autoauditoria_fase1_20261010.md
?? artigo3_pig/logs/celulas_fase1_20261010.md
?? artigo3_pig/logs/exposicao_crossbasis_fase1_20261010.md
?? artigo3_pig/logs/gigs_fase1_20261010.md
?? artigo3_pig/logs/grupos_municipio_fase1_20261010.md
?? artigo3_pig/logs/mapa_sensibilidades_fase1_20261010.md
?? artigo3_pig/logs/prompt_fase1_chat_A3_20261010.md
?? artigo3_pig/logs/r2_identificacao_fase1_20261010.md
?? artigo3_pig/logs/recodificacao_fluxograma_fase1_20261010.md
?? artigo3_pig/logs/reproducao_achados_auditoria_fase1_20261010.md
?? artigo3_pig/logs/sessionInfo_fase1_20261010.txt
?? artigo3_pig/logs/teste_ep_escore_z_20261010.md
?? artigo3_pig/logs/testes_funcoes_pig_20261010.md
?? artigo3_pig/logs/viabilidade_fase1_20261010.md
```

`git log --oneline -4`:

```
92565b9 Fase 2 do Artigo 1, Parte B: testes antes da tag, auditoria final e desvio 64
caf5022 Fase 2 do Artigo 1, Parte A: ajusta_dlnm(), testes sinteticos, diagnostico do offset e dupla auditoria (sem modelo de desfecho real)
90a7b73 Especificacoes de detalhe do Artigo 3 (Guilherme, 10/10/2026), antes de qualquer modelo
ded4fbd Fase 0 do Artigo 2: preparacao, interface, recontagens e dupla auditoria (sem modelo)
```

Commit local da Parte C (scripts, logs, desvios 65 e 66 e este retorno). **Push só depois do [ok]** de Guilherme, com a lista de commits (desvio 60).
