# Fase 3, Parte D: análises post hoc da D5 (não pré-especificadas)

- **Gerado por:** `00_scripts/50_posthoc_af.R`, em 2026-10-14 00:02:08 -03. Rodada `20261013`. `versao()` no início = 4443971b (o fim está na última linha).
- **Ambiente:** R 4.5.1; dlnm 2.4.10; mixmeta 1.2.0; MASS 7.3.65 (igual ao `renv.lock`). BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib` (referência).
- **Rótulo:** análises post hoc, registradas nas entradas 78 e 79 (commits `7e071cd` e `e925532`) antes de rodar e depois de ver os resultados da Fase 3; decisão de origem `spec/decisoes_metodo_20261013_D5_interpretacao_AF.md` (SHA-256 `24f131e8…`). Nenhuma análise especificada muda.
- **Código (SHA-256):**
  - `codigo_compartilhado/R/posthoc_af.R`: `a90096b74237afee576532460def71937083e1d6363e6d1ef8f1e204b1f0af73`;
  - `codigo_compartilhado/R/segunda_etapa.R`: `1fb4543a3d4f0fd31bbf35571944c37756c33b1a1d11f876d48bd9bdd3aa9abb`;
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009`;
  - `codigo_compartilhado/tests/testa_posthoc_af.R`: `3ec9f2afe5021a1be1d84fb3edaf7976c8ee508b134d95025ff1c109df3affa5`;
  - `segunda_etapa.R` e `ajusta_dlnm.R` iguais aos da tag `segunda_etapa-v1.0`; `posthoc_af.R` igual ao testado no 49; `attrdl.R` conferido.
- **Entradas (SHA-256 conferidos):**
  - `01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds`: `5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d`;
  - `01_saidas/fase1/serie_ptb_principal.rds`: `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917`;
  - `01_saidas/fase1/referencias_exposicao.csv`: `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467`;
  - `01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds`: `52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e`;
  - `01_saidas/fase3/fracao_atribuivel_fase3_20261013.csv`: `9437e9668c729ffd502a159038d2d557b4d8767d1a046cb86eef13ddb2659a48`;
  - a RDS do 45 e o CSV do 46 conferem com os logs deles; os eventos da janela de cada concentração são o `n$eventos` da primeira etapa.

## Testes do item 2 (entrada 78(c)), no principal observado

- **(i) Pré-condição:** a base que a `attrdl` reconstrói de `attr(cb, "argvar")` é igual à base da busca da MRT (a `argvar` da RDS, usada no 45), na grade p1–p99 de cada concentração: sim, nas 26; diferença máxima 0.0e+00 (critério ≤ 1e-12).
- **(ii) Contribuições:** g = f(MRT) − mín f na grade fina de 0,001 °C entre o p1 e o p99 (base da busca), e Δ_t = f(x_t) − f(MRT) nos dias da janela com x_t dentro do p1–p99 (base que a `attrdl` reconstrói); exigido Δ_t ≥ −max(g, 0) − 1e-12: NÃO em 3 (Rio de Janeiro/RJ, Natal/RN, Aracaju/SE). **g máximo:** 4.157e-05; **menor Δ_t:** -4.151e-05.
- Implementação: com as duas bases iguais, a condição (ii) equivale a f(x_t) ≥ mín f na grade fina − 1e-12; ela cai se a base da `attrdl` diferir da base da busca. A folga g mede quanto a MRT da grade de 0,1 °C fica acima do mínimo na grade fina.
- **Diagnóstico** (acrescentado depois da rodada de desenvolvimento, que mostrou a falha; o critério registrado, com o passo de 0,001 °C, não muda): quanto o menor f(x_t) dos dias dentro do p1–p99 fica abaixo do mínimo da grade, com o passo registrado e com um passo 100 vezes menor (1e-5 °C). Com o passo de 1e-5 °C, o menor f(x_t) fica a no máximo 1e-12 abaixo do mínimo da grade em todas as 26 concentrações. Nas concentrações em que o teste (ii) cai, a falha vem da resolução da grade fina: há dias com x_t entre dois pontos da grade de 0,001 °C, mais perto do mínimo da curva, e a base da `attrdl` é igual à da busca (teste (i)). A decisão sobre o critério fica com o chat.

| Concentração | Diferença das bases | g | Menor Δ_t | Dias dentro do p1–p99 | Resultado | Diagnóstico: falta com passo 0,001 | Diagnóstico: falta com passo 1e-5 |
|---|---|---|---|---|---|---|---|
| São Paulo/SP | 0.0e+00 | 1.477e-08 | -1.345e-08 | 4.409 | ok | 1.31e-09 | 1.31e-09 |
| Rio de Janeiro/RJ | 0.0e+00 | 6.358e-07 | -6.358e-07 | 4.407 | FALHOU | -2.37e-11 | 9.95e-12 |
| Belo Horizonte/MG | 0.0e+00 | 0.000e+00 | 4.267e-08 | 4.405 | ok | 4.27e-08 | 4.27e-08 |
| Brasília/DF | 0.0e+00 | 1.486e-05 | -1.481e-05 | 4.408 | ok | 4.72e-08 | 4.83e-08 |
| Recife/PE | 0.0e+00 | 4.157e-05 | -4.151e-05 | 4.404 | ok | 5.83e-08 | 5.94e-08 |
| Porto Alegre/RS | 0.0e+00 | 0.000e+00 | 3.808e-05 | 4.406 | ok | 3.81e-05 | 3.81e-05 |
| Fortaleza/CE | 0.0e+00 | 7.762e-06 | -7.717e-06 | 4.436 | ok | 4.49e-08 | 4.65e-08 |
| Curitiba/PR | 0.0e+00 | 6.350e-06 | -6.312e-06 | 4.407 | ok | 3.79e-08 | 3.83e-08 |
| Salvador/BA | 0.0e+00 | 4.222e-06 | -4.219e-06 | 4.402 | ok | 2.79e-09 | 3.07e-09 |
| Goiânia/GO | 0.0e+00 | 0.000e+00 | 1.192e-04 | 4.416 | ok | 1.19e-04 | 1.19e-04 |
| Campinas/SP | 0.0e+00 | 0.000e+00 | 6.339e-06 | 4.408 | ok | 6.34e-06 | 6.34e-06 |
| Manaus | 0.0e+00 | 0.000e+00 | 1.226e-05 | 4.420 | ok | 1.23e-05 | 1.23e-05 |
| Belém/PA | 0.0e+00 | 0.000e+00 | 8.149e-06 | 4.436 | ok | 8.15e-06 | 8.15e-06 |
| Vitória/ES | 0.0e+00 | 3.487e-06 | -3.475e-06 | 4.402 | ok | 1.21e-08 | 1.22e-08 |
| Baixada Santista/SP | 0.0e+00 | 0.000e+00 | 2.514e-06 | 4.409 | ok | 2.51e-06 | 2.51e-06 |
| São José dos Campos/SP | 0.0e+00 | 2.085e-06 | -2.083e-06 | 4.407 | ok | 1.97e-09 | 2.28e-09 |
| São Luís/MA | 0.0e+00 | 1.284e-06 | -1.236e-06 | 4.404 | ok | 4.81e-08 | 4.84e-08 |
| Natal/RN | 0.0e+00 | 6.576e-06 | -6.576e-06 | 4.403 | FALHOU | -2.59e-10 | 3.49e-10 |
| Maceió/AL | 0.0e+00 | 2.508e-05 | -2.507e-05 | 4.404 | ok | 6.76e-09 | 7.28e-09 |
| Florianópolis/SC | 0.0e+00 | 4.772e-08 | -4.552e-08 | 4.405 | ok | 2.20e-09 | 2.21e-09 |
| João Pessoa/PB | 0.0e+00 | 3.357e-07 | -3.357e-07 | 4.402 | ok | 3.21e-11 | 5.12e-10 |
| Teresina/PI | 0.0e+00 | 0.000e+00 | 5.724e-05 | 4.411 | ok | 5.72e-05 | 5.72e-05 |
| Aracaju/SE | 0.0e+00 | 8.367e-06 | -8.368e-06 | 4.409 | FALHOU | -1.28e-09 | 2.14e-10 |
| Cuiabá/MT | 0.0e+00 | 0.000e+00 | 1.250e-03 | 4.416 | ok | 1.25e-03 | 1.25e-03 |
| Sorocaba/SP | 0.0e+00 | 0.000e+00 | 9.741e-06 | 4.408 | ok | 9.74e-06 | 9.74e-06 |
| Campo Grande | 0.0e+00 | 0.000e+00 | 2.506e-03 | 4.412 | ok | 2.51e-03 | 2.51e-03 |

## P1: teste de Wald da curva combinada

- Os 4 coeficientes previstos pelo `mixmeta` na média dos metapreditores (média 24,768 °C; amplitude 10,701 °C), com a vcov da predição: **W = 1,86; gl = 4; p = 0,762** (χ²). O teste não depende da MRT.

## P2: referência nula da AF (nulo estrito; descritiva)

- **Procedimento** (D5, item 4, passos 1 a 7; entrada 79): `set.seed(20261001, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")` uma vez antes do laço; 1.000 réplicas; em cada uma, θᵢ* ~ N(0, Sᵢ) pelo `MASS::mvrnorm` nas 26 concentrações, na ordem travada, com Sᵢ = vcov reduzida da primeira etapa; segunda etapa com a sequência de estabilidade da C1; MRT BLUP na grade p1–p99; AF *forward* pontual (`attrdl` com `sim = FALSE`) na série completa e consecutiva, contra a MRT da réplica; RR combinados contra a MRT combinada da réplica. Duração: 6,3 min.
- **Falhas** (sequência inteira do `mixmeta` falhou): 0 de 1.000.
- **Método do `mixmeta` nas réplicas:** reml/unstr em 1000.

**Única comparação:** AF total observada (principal) 1,84% contra a distribuição nula: mediana 1,67% (p2,5 a p97,5: 0,83% a 3,00%). A AF observada **não passa** o p97,5.
Sem falhas: a distribuição com e sem as réplicas que falharam é a mesma.

**Distribuições descritivas, sem p** (réplicas sem falha; observado ao lado):

| Quantidade | Observado | Mediana nula | p2,5 a p97,5 nulos |
|---|---|---|---|
| AF de calor | 0,23% | 0,73% | 0,08% a 2,08% |
| AF de frio | 1,61% | 0,79% | 0,11% a 2,19% |
| RR combinado no x99 (contra a MRT combinada) | 1,003 | 1,008 | 1,000 a 1,035 |
| RR combinado no x1 (contra a MRT combinada) | 1,020 | 1,008 | 1,000 a 1,032 |
| Número de MRT BLUP no p99 (de 26) | 10 | 6,0 | 0,0 a 18,0 |
| Número de MRT BLUP no p1 (de 26) | 0 | 6,0 | 0,0 a 19,0 |

- **O que a P2 não é** (D5, item 4): não corrige a AF (nada é subtraído); não testa associação combinada (isso é a P1); supõe coeficientes normais com a vcov estimada, como a própria segunda etapa, e não reajusta o `gnm`. Como o nulo é o estrito, uma AF observada acima da referência indicaria associações específicas de concentração ou heterogeneidade, não uma associação combinada.

## Saídas (fora do git)

- `01_saidas/fase3/posthoc_p2_replicas_fase3_20261013.csv`: `a53e4b7784b3bd8c3de451ef1dfc290f673f201fc9c671e1efab4af6bfa41e40`;
- `01_saidas/fase3/posthoc_item2_fase3_20261013.csv`: `1da3e93205b0a5dd9e16bee068f9a66b69ebe953291e01fa81ba3d6038817511`;
- `01_saidas/fase3/posthoc_af_fase3_20261013.rds`: `223e09366a445b99bd947d3f59f66fa20d755b019af149bfeb4bac026593d11d`;

`versao()` no fim: 4443971b.
