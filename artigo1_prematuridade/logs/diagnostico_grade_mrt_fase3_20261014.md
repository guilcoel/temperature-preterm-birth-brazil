# Fase 3: diagnóstico da grade da MRT (errata da D5, item 2; só leitura)

- **Gerado por:** `00_scripts/53_diagnostico_grade_mrt.R`, em 2026-10-14 03:40:03 -03. Rodada `20261014`. `versao()` no início = 4443971b (o fim está na última linha).
- **Ambiente:** R 4.5.1; dlnm 2.4.10; splines 4.5.1. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib` (referência).
- **Rótulo:** diagnóstico descritivo pedido pela errata da D5 (`spec/decisoes_metodo_20261014_errata_D5.md`, SHA-256 `9c9fb65d…`), registrado na entrada 80 antes de rodar. Nada foi reajustado nem recalculado: MRT BLUP, coeficientes BLUP, p1 e p99 vêm da RDS do 45; o menor Δ_t, da RDS do 50.
- **Código (SHA-256):**
  - `codigo_compartilhado/R/diagnostico_grade_mrt.R`: `ad17f502d2aeb6499fef70b8779e207a36d102ad0d8b4f0fb1d537c1bf723bd4`;
  - `codigo_compartilhado/tests/testa_diagnostico_grade_mrt.R`: `514cb77ab2d9d31d55f104c365ae8d57b5d5722dd208215034d8c95eabe02b1e`;
  - `codigo_compartilhado/tests/roda_testes.R`: `40e7b537c500a29bfd852ac67a4fcde3fbd58128321f60fc438826360436768e`;
  - `codigo_compartilhado/R/segunda_etapa.R`: `1fb4543a3d4f0fd31bbf35571944c37756c33b1a1d11f876d48bd9bdd3aa9abb`;
  - `codigo_compartilhado/R/posthoc_af.R`: `a90096b74237afee576532460def71937083e1d6363e6d1ef8f1e204b1f0af73`;
  - todos os arquivos de `codigo_compartilhado/R/` da tag `segunda_etapa-v1.0` iguais aos do disco; `posthoc_af.R` igual ao da tag `posthoc_af-v1.0`; o 45 sem mudança local em relação ao commit.
- **Entradas (SHA-256 conferidos contra o log do 50; o CSV de contribuições negativas, contra o log do 46):**
  - `01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds`: `5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d`;
  - `01_saidas/fase1/serie_ptb_principal.rds`: `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917`;
  - `01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds`: `52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e`;
  - `01_saidas/fase3/posthoc_af_fase3_20261013.rds`: `223e09366a445b99bd947d3f59f66fa20d755b019af149bfeb4bac026593d11d`;
  - `01_saidas/fase3/posthoc_item2_fase3_20261013.csv`: `1da3e93205b0a5dd9e16bee068f9a66b69ebe953291e01fa81ba3d6038817511`;
  - `01_saidas/fase3/contribuicoes_negativas_fase3_20261013.csv`: `4641b22af30316679f035977668651f49e60e874a68747f7e89cd1ba21a2a1d1`;
  - o CSV do item 2 é igual à RDS do 50 no texto `%.17g` (menor Δ_t e g): sim.

## Testes sintéticos e defeitos plantados

- Em todos os cenários, os dias fora do p1–p99 ficam intercalados com os de dentro (no começo e no meio do vetor), para o índice do vetor completo não coincidir com o dos dias de dentro (auditoria independente, achado 1).
- `td1`: mergulho na célula vizinha da MRT, com nó da `argvar` dentro da célula e f″ máxima nesse nó → (a, vizinha); u_min, célula, M, cota e razões (também a razão com o M numérico) contra a conta à mão (`splines::ns` e polinômio cúbico exato de cada trecho).
- `td2`: célula parcial no p99 (h = 0,04 °C) → (a), com a cota do h real; com (p99 − p1)/0,1 inteiro, a última célula é cheia e não é parcial.
- `td3`: quase empate de dois mínimos locais a 80 células um do outro → (a, quase empate de mínimos locais), declarada; razão da célula contra mín(f(a), f(b)), maior que a razão contra f(MRT).
- `td4`: base dos dias diferente da base da busca (nós deslocados em 0,4 °C) → razão > 1 → anômala; célula, M, f(a), f(b) e f(x*), cada um com a sua base, contra a conta à mão.
- `td5`: u_min diferente do gravado em 1e-12 → parada; em 5e-14, segue; MRT a 1e-6 °C de um ponto da grade → anômala.
- `td6`: grade sem o p99, MRT no último ponto do `seq` e curva ainda descendo → (b); o simétrico no p1 (grade sem o p1, curva subindo) → (b); com a `grade_tmr`, MRT no extremo e nenhum negativo (dias fora do p1–p99 não contam).
- `td7`: Parte 1 (n da grade, p99 acrescentado ou não, último ponto = p99, MRT no p99), com (p99 − p1)/0,1 inteiro e não inteiro, com grade sem o p99, sem o p1, com o último ponto a 0,005 °C do p99 e com folga de 5e-9 (o p99 não é acrescentado).
- `td8`: distância em células; vizinha só com distância 0; tolerância 1e-6 nas razões; M = 0 e M < 0 → anômala.
- `td9`: f e f″ da função contra `splines::ns` e o polinômio exato de cada trecho; f″ numérica; f″ fora dos Boundary.knots dá erro.

| Teste | Resultado |
|---|---|
| `td1_celula_vizinha` | passou |
| `td2_celula_parcial_p99` | passou |
| `td3_quase_empate` | passou |
| `td4_base_trocada` | passou |
| `td5_gravado` | passou |
| `td6_grade_sem_p99` | passou |
| `td7_parte1` | passou |
| `td8_distancia_classe` | passou |
| `td9_f_e_f2` | passou |

Defeitos plantados (cada um numa cópia de `diagnostico_grade_mrt.R`, salvo o da grade, plantado na `grade_tmr` da cópia em memória; a bateria inteira roda em cada cópia). Os cinco primeiros são os pedidos pelo chat; os seis seguintes, da sessão; os doze últimos, da auditoria independente:

| Defeito | Testes derrubados (dos que passam no original) | Quais |
|---|---|---|
| h = 0,1 na célula parcial | 1 | td2_celula_parcial_p99 |
| grade sem o p99 (grade_tmr trocada por seq de 0,1 °C, na cópia em memória) | 3 | td2_celula_parcial_p99, td6_grade_sem_p99, td7_parte1 |
| razão da célula só contra f(MRT) | 3 | td3_quase_empate, td4_base_trocada, td8_distancia_classe |
| M num ponto (f″ no dia do mínimo), e não o máximo na célula | 4 | td1_celula_vizinha, td2_celula_parcial_p99, td3_quase_empate, td4_base_trocada |
| vizinhança com distância ≤ 1 | 1 | td8_distancia_classe |
| u_min com a base da busca, e não com a da attrdl | 1 | td4_base_trocada |
| dias fora do p1–p99 incluídos | 2 | td1_celula_vizinha, td6_grade_sem_p99 |
| M sem os nós internos da célula | 1 | td1_celula_vizinha |
| tolerância do u_min gravado frouxa (1e-6) | 1 | td5_gravado |
| tolerância das razões frouxa (1,5) | 1 | td8_distancia_classe |
| classe (b) não detectada | 1 | td6_grade_sem_p99 |
| x* tirado do vetor completo, e não dos dias dentro do p1–p99 | 5 | td1_celula_vizinha, td3_quase_empate, td4_base_trocada, td5_gravado, td6_grade_sem_p99 |
| sem a trava M > 0 | 1 | td8_distancia_classe |
| M com a base da attrdl | 1 | td4_base_trocada |
| f(a) e f(b) com a base da attrdl | 1 | td4_base_trocada |
| f(x*) com a base da busca | 1 | td4_base_trocada |
| classe numérica calculada com o M analítico | 1 | td1_celula_vizinha |
| célula parcial sem a condição de h | 1 | td2_celula_parcial_p99 |
| classe (b) só do lado do p99 | 1 | td6_grade_sem_p99 |
| sem a checagem de MRT fora dos pontos da grade | 1 | td5_gravado |
| primeiro ponto = p1 sempre verdadeiro | 1 | td7_parte1 |
| tolerância de último = p99 em 1e-2 | 1 | td7_parte1 |
| p99 acrescentado com > 0, e não > 1e-8 | 1 | td7_parte1 |

- **Resultado:** 9/9 testes; cada um dos 23 defeitos derruba pelo menos um teste.

## Parte 1: a grade da MRT começa no p1 e termina no p99?

- **Código, na tag `segunda_etapa-v1.0`** (`codigo_compartilhado/R/segunda_etapa.R`): `grade_tmr` nas linhas 131–135: `g <- seq(x_inf, x_sup, by = 0.1)` (linha 133) e `if (x_sup - g[length(g)] > 1e-8) g <- c(g, x_sup)` (linha 134); `busca_tmr` e `boot_tmr` chamam `grade_tmr(x_inf, x_sup)` nas linhas 139 e 145.
- **Chamadas no 45** (`00_scripts/45_segunda_etapa_principal.R`, commit `ec38fc3`): linha 141 (`g <- grade[r, ]`, a linha da concentração na grade de percentis da A0), linha 142 (`busca_tmr(b$coef, av, g[["p1"]], g[["p99"]], …)`) e linha 145 (`grade_tmr(g[["p1"]], g[["p99"]])`): x_inf = p1 e x_sup = p99 da concentração.
- **Primeiro ponto = p1:** 26 de 26. **Último ponto = p99** (|dif| ≤ 1e-8): 26 de 26. **p99 acrescentado** (p99 − último do `seq` > 1e-8): 26 de 26. n da grade e extremos iguais aos registrados pelo 45: sim.
- **MRT no p99:** a MRT BLUP é exatamente o último ponto da grade (o p99) em 10 de 26 (Porto Alegre/RS, Goiânia/GO, Campinas/SP, Manaus, Belém/PA, Baixada Santista/SP, Teresina/PI, Cuiabá/MT, Sorocaba/SP, Campo Grande), as mesmas com `fronteira = TRUE` no 45 (10); nenhuma no primeiro ponto: sim. Nelas, |MRT − p99| = 0.000e+00, g = 0 e menor Δ_t > 0 no 50: sim.
- **Exemplo detalhado (Porto Alegre/RS):** p1 = 9,4820 °C, p99 = 30,2114 °C, (p99 − p1)/0,1 = 207,29 (não inteiro); o `seq` de 0,1 °C termina em 30,1820 °C, a 0,0294 °C do p99, e a `grade_tmr` acrescenta o p99 como 209º ponto; a MRT BLUP é 30,2114 °C, igual ao p99 (|dif| = 0.000e+00), isto é, o último ponto da grade, o acrescentado.

| Concentração | p1 | p99 | (p99 − p1)/0,1 | n da grade | Primeiro = p1 | Último do seq | p99 acrescentado | Último = p99 | MRT | MRT no p99 |
|---|---|---|---|---|---|---|---|---|---|---|
| São Paulo/SP | 12,5807 | 27,6435 | 150,63 | 152 | sim | 27,5807 | sim | sim | 24,0807 | não |
| Rio de Janeiro/RJ | 17,4852 | 30,9915 | 135,06 | 137 | sim | 30,9852 | sim | sim | 23,0852 | não |
| Belo Horizonte/MG | 16,8992 | 28,2699 | 113,71 | 115 | sim | 28,1992 | sim | sim | 26,1992 | não |
| Brasília/DF | 18,1266 | 27,2835 | 91,57 | 93 | sim | 27,2266 | sim | sim | 26,1266 | não |
| Recife/PE | 23,1873 | 29,4055 | 62,18 | 64 | sim | 29,3873 | sim | sim | 28,0873 | não |
| Porto Alegre/RS | 9,4820 | 30,2114 | 207,29 | 209 | sim | 30,1820 | sim | sim | 30,2114 | sim |
| Fortaleza/CE | 25,4113 | 30,4804 | 50,69 | 52 | sim | 30,4113 | sim | sim | 29,9113 | não |
| Curitiba/PR | 8,9891 | 26,3248 | 173,36 | 175 | sim | 26,2891 | sim | sim | 23,3891 | não |
| Salvador/BA | 22,6465 | 29,7339 | 70,87 | 72 | sim | 29,6465 | sim | sim | 24,3465 | não |
| Goiânia/GO | 19,8797 | 30,0694 | 101,90 | 103 | sim | 29,9797 | sim | sim | 30,0694 | sim |
| Campinas/SP | 13,6635 | 27,9660 | 143,02 | 145 | sim | 27,9635 | sim | sim | 27,9660 | sim |
| Manaus | 24,9112 | 31,6618 | 67,51 | 69 | sim | 31,6112 | sim | sim | 31,6618 | sim |
| Belém/PA | 25,4659 | 29,9689 | 45,03 | 47 | sim | 29,9659 | sim | sim | 29,9689 | sim |
| Vitória/ES | 19,6646 | 29,9725 | 103,08 | 105 | sim | 29,9646 | sim | sim | 29,0646 | não |
| Baixada Santista/SP | 15,2617 | 29,7761 | 145,14 | 147 | sim | 29,7617 | sim | sim | 29,7761 | sim |
| São José dos Campos/SP | 13,1819 | 26,4862 | 133,04 | 135 | sim | 26,4819 | sim | sim | 24,3819 | não |
| São Luís/MA | 25,0272 | 30,2480 | 52,21 | 54 | sim | 30,2272 | sim | sim | 26,4272 | não |
| Natal/RN | 24,1850 | 29,3513 | 51,66 | 53 | sim | 29,2850 | sim | sim | 25,1850 | não |
| Maceió/AL | 23,2697 | 29,1045 | 58,35 | 60 | sim | 29,0697 | sim | sim | 28,3697 | não |
| Florianópolis/SC | 12,5454 | 28,8563 | 163,11 | 165 | sim | 28,8454 | sim | sim | 23,5454 | não |
| João Pessoa/PB | 23,8836 | 29,5674 | 56,84 | 58 | sim | 29,4836 | sim | sim | 25,0836 | não |
| Teresina/PI | 25,3857 | 31,9077 | 65,22 | 67 | sim | 31,8857 | sim | sim | 31,9077 | sim |
| Aracaju/SE | 23,8636 | 29,9170 | 60,53 | 62 | sim | 29,8636 | sim | sim | 28,8636 | não |
| Cuiabá/MT | 17,2251 | 32,2911 | 150,66 | 152 | sim | 32,2251 | sim | sim | 32,2911 | sim |
| Sorocaba/SP | 13,3129 | 28,3369 | 150,24 | 152 | sim | 28,3129 | sim | sim | 28,3369 | sim |
| Campo Grande | 12,5985 | 30,5286 | 179,30 | 181 | sim | 30,4985 | sim | sim | 30,5286 | sim |

## Parte 2: onde fica o dia de menor contribuição

- **u_min** = mín[f(x_t) − f(MRT)] nos dias da janela com x_t no p1–p99, com a base que a `attrdl` reconstrói de `attr(cb, "argvar")` sem o `cen` (mesma expressão da `testa_contribuicoes`, `posthoc_af.R` da tag `posthoc_af-v1.0`, linha 108). Igual ao menor Δ_t gravado pelo 50 nas 26: diferença máxima 0.0e+00 (critério ≤ 1e-13).
- **u_min < −1e-8:** 15 de 26. As outras 11: Belo Horizonte/MG (4.267e-08); Porto Alegre/RS (3.808e-05); Goiânia/GO (1.192e-04); Campinas/SP (6.339e-06); Manaus (1.226e-05); Belém/PA (8.149e-06); Baixada Santista/SP (2.514e-06); Teresina/PI (5.724e-05); Cuiabá/MT (1.250e-03); Sorocaba/SP (9.741e-06); Campo Grande (2.506e-03).
- **Célula** [a, b]: pontos da grade da MRT em volta do dia do mínimo (`findInterval`). **Distância:** número de células entre ela e a MRT (0 = a MRT é a ou b). **Parcial:** b = p99 e b − a < 0,1 − 1e-8.
- **M** = máx f″ em [a, b] = máx{f″(a), f″(b), f″ nos nós internos da `argvar` em (a, b)}, analítico (`splines::splineDesign` com `derivs = 2` na construção da `ns`); conferência por segunda diferença central com passo de 1e-3 °C. **Cota** = M·(b − a)²/8. **Razão MRT** = −u_min/cota; **razão célula** = [mín(f(a), f(b)) − f(x*)]/cota.
- **Classes:** a, vizinha em 15. Com a f″ numérica, as mesmas: sim. Distância 0 em 15 de 15; células parciais: 0; última célula: 0.
- **Coerência das razões** (conferência descritiva acrescentada pela auditoria independente, achado 2; não muda a classe da especificação): razão célula ≥ razão MRT − 1e-9 em 15 de 15. Com as bases iguais e a MRT como mínimo da grade, vale sempre; nas 15, as duas razões são iguais (diferença máxima 0.0e+00), porque a MRT é um dos extremos da célula.
- **Faixa de M:** 0,00081 a 0,04803 °C⁻² (numérico: 0,00081 a 0,04803). **Razões máximas:** MRT 0,7575; célula 0,7575.
- **Recife:** u_min = -4.151e-05; célula de 0,10 °C (inteira); M = 0,04803 °C⁻² (numérico 0,04803); o u_min exige M ≥ 8·|u_min|/h² = 0,03321 °C⁻²; M ≥ 0,033 °C⁻² (o limite da errata, com h = 0,1 °C): sim.

| Concentração | MRT | a | b | h | Distância | Última | Parcial | u_min | M (°C⁻²) | M numérico | Cota | Razão MRT | Razão célula | Classe | Classe (f″ numérica) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| São Paulo/SP | 24,0807 | 24,0807 | 24,1807 | 0,10 | 0 | não | não | -1.345e-08 | 0,00256 | 0,00256 | 3.203e-06 | 0,0042 | 0,0042 | a, vizinha | a, vizinha |
| Rio de Janeiro/RJ | 23,0852 | 23,0852 | 23,1852 | 0,10 | 0 | não | não | -6.358e-07 | 0,00110 | 0,00110 | 1.375e-06 | 0,4625 | 0,4625 | a, vizinha | a, vizinha |
| Brasília/DF | 26,1266 | 26,1266 | 26,2266 | 0,10 | 0 | não | não | -1.481e-05 | 0,01672 | 0,01672 | 2.090e-05 | 0,7087 | 0,7087 | a, vizinha | a, vizinha |
| Recife/PE | 28,0873 | 28,0873 | 28,1873 | 0,10 | 0 | não | não | -4.151e-05 | 0,04803 | 0,04803 | 6.003e-05 | 0,6915 | 0,6915 | a, vizinha | a, vizinha |
| Fortaleza/CE | 29,9113 | 29,9113 | 30,0113 | 0,10 | 0 | não | não | -7.717e-06 | 0,01577 | 0,01577 | 1.971e-05 | 0,3915 | 0,3915 | a, vizinha | a, vizinha |
| Curitiba/PR | 23,3891 | 23,3891 | 23,4891 | 0,10 | 0 | não | não | -6.312e-06 | 0,01432 | 0,01432 | 1.790e-05 | 0,3526 | 0,3526 | a, vizinha | a, vizinha |
| Salvador/BA | 24,3465 | 24,2465 | 24,3465 | 0,10 | 0 | não | não | -4.219e-06 | 0,00446 | 0,00446 | 5.570e-06 | 0,7575 | 0,7575 | a, vizinha | a, vizinha |
| Vitória/ES | 29,0646 | 29,0646 | 29,1646 | 0,10 | 0 | não | não | -3.475e-06 | 0,00435 | 0,00435 | 5.438e-06 | 0,6390 | 0,6390 | a, vizinha | a, vizinha |
| São José dos Campos/SP | 24,3819 | 24,2819 | 24,3819 | 0,10 | 0 | não | não | -2.083e-06 | 0,02209 | 0,02209 | 2.762e-05 | 0,0754 | 0,0754 | a, vizinha | a, vizinha |
| São Luís/MA | 26,4272 | 26,3272 | 26,4272 | 0,10 | 0 | não | não | -1.236e-06 | 0,01276 | 0,01276 | 1.595e-05 | 0,0775 | 0,0775 | a, vizinha | a, vizinha |
| Natal/RN | 25,1850 | 25,1850 | 25,2850 | 0,10 | 0 | não | não | -6.576e-06 | 0,00958 | 0,00958 | 1.197e-05 | 0,5492 | 0,5492 | a, vizinha | a, vizinha |
| Maceió/AL | 28,3697 | 28,2697 | 28,3697 | 0,10 | 0 | não | não | -2.507e-05 | 0,03110 | 0,03110 | 3.888e-05 | 0,6449 | 0,6449 | a, vizinha | a, vizinha |
| Florianópolis/SC | 23,5454 | 23,5454 | 23,6454 | 0,10 | 0 | não | não | -4.552e-08 | 0,00081 | 0,00081 | 1.017e-06 | 0,0447 | 0,0447 | a, vizinha | a, vizinha |
| João Pessoa/PB | 25,0836 | 24,9836 | 25,0836 | 0,10 | 0 | não | não | -3.357e-07 | 0,00896 | 0,00896 | 1.120e-05 | 0,0300 | 0,0300 | a, vizinha | a, vizinha |
| Aracaju/SE | 28,8636 | 28,8636 | 28,9636 | 0,10 | 0 | não | não | -8.368e-06 | 0,02426 | 0,02426 | 3.033e-05 | 0,2759 | 0,2759 | a, vizinha | a, vizinha |

## Contribuições negativas ao AN (conferência do CSV do 46, sem imprimir linhas)

- Principal, soma nas 26: fora do p1–p99 -38,70 eventos; dentro, -0,034. Fora = −38,70 com duas casas: sim.

## Autoauditoria (código próprio: `splines::ns` com os nós e os Boundary.knots da `argvar`, grade e célula próprias, f″ pelo polinômio cúbico exato de cada trecho)

- Concentrações: Recife e Rio de Janeiro/RJ (a primeira, na ordem travada, das três em que o teste (ii) do item 2 caiu e que está entre as de u_min < −1e-8).

| Concentração | Dif. u_min | Célula igual | Dif. relativa de M | Resultado |
|---|---|---|---|---|
| Recife/PE | 0.0e+00 | sim | 4.7e-13 | ok |
| Rio de Janeiro/RJ | 0.0e+00 | sim | 6.1e-12 | ok |

## Resultado

**Sem parada.** A grade começa no p1 e termina no p99 nas 26; as 15 concentrações com u_min < −1e-8 são classe (a), todas com o dia do mínimo numa célula vizinha da MRT. Causa dos negativos dentro do p1–p99: resolução da grade de 0,1 °C (errata, item 2, causa (a)).

## Saída (fora do git)

- `01_saidas/fase3/diagnostico_grade_mrt_fase3_20261014.csv`: `c27f652dbacba6807e2b599019f96fc1b6f15448e2581fecadc3ff59567ef3c9` (por concentração; sem data, x_t, contagem ou contribuição do dia do mínimo).

`versao()` no fim: 4443971b.
