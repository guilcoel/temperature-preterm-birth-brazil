# Fase 2, Parte C: primeira etapa do modelo principal nas 26 concentrações

- **Gerado por:** `00_scripts/32_primeira_etapa_principal.R`, em 2026-10-10 18:20:03 -03. Rodada `20261010`. `versao()` no início = 4443971b (o fim está na última linha).
- **Ambiente:** R 4.5.1; dlnm 2.4.10; gnm 1.1.5. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib` — de referência (§8; critério do desvio 65d). Semente 20261001, em série.
- **Código:** tag `ajusta_dlnm-v1.0` (objeto `344899ab4a8673f1ad9e7a8bdf53c4e17e51cd76`), commit `caf5022f9a655877d8e3931dd3d02d7dce429fe5`. SHA-256 no disco = SHA-256 na tag:
  - `codigo_compartilhado/R/.gitkeep`: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`;
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009`;
  - `codigo_compartilhado/R/offset.R`: `55111b2cc510d7b1c7b78b7f84e99997c5202825e0353da70bab0b4bea290bae`;
- **Entradas:** `01_saidas/fase1/serie_ptb_principal.rds` (SHA-256 `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917`) e `01_saidas/fase1/referencias_exposicao.csv` (SHA-256 `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467`).
- **Por que o CSV:** o código canônico da §1.5 calcula os percentis de `tmean_ref` de 2012-01-01 a 2024-12-31, mas a RDS termina em 2024-11-15, e os percentis não podem ser recalculados dela. O CSV foi feito com o código canônico (a conferência da Fase 1 deu diferença 0). Nós p10/p75/p90 e `cen` = p50 vêm das linhas de ano inteiro.
- **Linhas passadas à função**, por concentração: 2012-04-07 a 2024-08-06 (4.505 dias: os 7 de aquecimento, de 2012-04-07 a 2012-04-13, mais a janela principal de 4.498 dias), nada além (§1.5). Os Boundary.knots saem do range de `tmean_nucleo` nesse conjunto.
- **Especificação:** `ptb` ~ cross-basis (ns com nós p10/p75/p90 × ns com intercepto e nós `logknots(7, nk = 2)` = 0,982 e 2,622; lag 0–7) + `dia_semana` + `feriado_nacional` + `carnaval` + `moveis` + γ·`log_w`, offset `log_z`, `eliminate` = estrato (concentração × ano × mês), quasi-Poisson. Fallback (só para as falhas do §5, critério 4; desvio 65a): ns p50/p90 e lag em estratos 0–1, 2–4 e 5–7.

## Resumo nas 26 (C.6)

- **Status:** 26 de 26 com `status = "ok"` no principal; fallback em 0; não estimáveis 0; decisões pendentes 0.
- **φ > 2:** 0 de 26 (0,0%). Não passa de 25%: a binomial negativa não é acionada pela regra da §2.1.
- **PACF, regra literal da §2.1** (algum lag de 1 a 7 fora de ±2/√n): 25 de 26. Pela §2.1, nessas a sensibilidade com resíduos defasados entraria na Fase 4; a regra que vale é decisão pendente do chat (desvio 65c).
- **PACF, só descritivo (desvio 65c):** recentrada em −1/(m − 1): 13 de 26; recentrada com Bonferroni nos 7 lags: 8 de 26. A regra que vale para a Fase 4 é decisão do chat.
- **Sinal dos lags sinalizados** (lags de todas as concentrações): literal 70 (70 negativos, 0 positivos); recentrada 24 (23 acima do centro, 1 abaixo); recentrada com Bonferroni 13 (13 acima, 0 abaixo). Num modelo correto, a PACF fica em torno do centro −1/(m − 1), abaixo de 0.
- **p1 e p99 (ano inteiro) dentro dos Boundary.knots:** 26 de 26 (só reportado; desvio 59).

## Especificação usada e Boundary.knots, por concentração

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

## Diagnósticos por concentração (principal)

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

## PACF dos resíduos de deviance, lags 1 a 7 (principal)

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

## Saídas (fora do git; desvio 59)

- `01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds`: `5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d`;
- `01_saidas/fase2/reduzida_coef_vcov_fase2_20261010.csv`: `50f58701005f9cbaf722f5043844f0e6680be5717b011419b2b3b4b688e58c4d`;
- `01_saidas/fase2/crossbasis_coef_vcov_fase2_20261010.csv`: `8eed876c0bc0983705305042324c79ab1f0d619a41a97d8139503b73957e4ddd`;
- `01_saidas/fase2/pacf_fase2_20261010.csv`: `5ab465ab5b1059896f596842e52c78aa0978090cafb4ebd2ef8ddbe5a7e7908f`;
- `01_saidas/fase2/diagnosticos_fase2_20261010.csv`: `0f28e346a39cc242bd42a225cc2c7090d408298d43277aba37e291b0391c02eb`;
- Conteúdo: a RDS tem a saída completa da função por concentração (coeficientes e vcov da cross-basis e reduzidos, com a dimensão; atributos da base; γ̂, φ, QAIC, PACF e diagnósticos), sem resíduos, valores ajustados nem série diária; os CSVs têm os coeficientes e as vcov (formato longo, 17 dígitos), a PACF e os diagnósticos.

**Ainda não** (Fase 3): RR, curva, MRT e contraste.

`versao()` no fim: 4443971b.
