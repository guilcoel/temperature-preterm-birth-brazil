# Artigo 1: prematuridade. Fase 3, Parte D: análises post hoc da D5 (P1 e P2)

**Para:** chat do Artigo 1 (prematuridade), via Guilherme.

**Data:** 13/10/2026.

**Rótulo:** análises **post hoc, não pré-especificadas**, registradas antes de rodar (entradas 78 e 79; commits `7e071cd` e `e925532`) e **depois de ver os resultados da Fase 3**. Decisão de origem: `spec/decisoes_metodo_20261013_D5_interpretacao_AF.md` (SHA-256 `24f131e8…`). Nenhuma análise especificada muda. Só tabelas, sem leitura causal.

**Código:** `codigo_compartilhado/R/posthoc_af.R` (para a tag `posthoc_af-v1.0`, que só sai depois da aprovação desta RESPOSTA, no commit que rodou), com as funções da tag `segunda_etapa-v1.0` sem alteração.

## 1. Resumo

- **Testes sintéticos (49):** 8/8; cada um dos 15 defeitos plantados (11 do plano e 4 da auditoria independente) derruba pelo menos um teste.
- **Testes do item 2 no principal observado:** (i) pré-condição (base da `attrdl` = base da busca da MRT): sim, nas 26; (ii) contribuições: NÃO em 3 (Rio de Janeiro/RJ, Natal/RN, Aracaju/SE); g máximo 4.157e-05; menor Δ_t -4.151e-05. Diagnóstico com passo de 1e-5 °C: ok em todas as 26 concentrações.
- **P1 (Wald da curva combinada, 4 gl):** W = 1,86; gl = 4; p = 0,762.
- **P2 (referência nula da AF, nulo estrito, descritiva):** falhas 0 de 1.000. AF total observada (principal) 1,84% contra a distribuição nula: mediana 1,67% (p2,5 a p97,5: 0,83% a 3,00%). A AF observada **não passa** o p97,5.
- **Dupla auditoria:** autoauditoria 17 de 17 iguais; auditoria independente com 6 achados (seção 5).
- **Pendência para o chat:** o teste (ii) do item 2, como registrado (passo de 0,001 °C e tolerância de 1e-12), cai por resolução da grade fina nas concentrações listadas. As faltas cabem na cota teórica da grade, f″·h²/8; contra o mínimo contínuo da curva o teste passa nas 26, e com passo de 1e-5 °C também; as bases são iguais (teste (i)). Decidir entre aceitar o (i) como a pré-condição do item 1.4 da D5 ou redefinir o (ii), com g contra o mínimo contínuo ou com tolerância ≥ máx f″·h²/8 (seção 5, achado 1 da auditoria independente).
- **Implementação do teste (ii):** g com a base da busca da MRT e Δ_t com a base que a `attrdl` reconstrói, para que o teste detecte base diferente; leitura fiel da entrada 78(c), segundo o auditor independente (achado 2). Com as bases iguais, as duas leituras dão os mesmos números.
- **Para o chat de métodos (D5, item 1.1 e frase de Methods):** a menor contribuição diária dentro do p1–p99 é −4,15e-05 e fica abaixo de −1e-8 em 15 das 26 concentrações, e não "na ordem de 10⁻⁹"; dentro do p1–p99 o AN soma −0,034, e fora, −38,70 (0,15% do AN total). Sugestão do auditor: qualificar "non-negative by construction" com "up to the 0.1 °C resolution of the MRT search grid", ou dar a magnitude no suplemento (seção 5, achado 4).
- **Sem push e sem tag:** esta RESPOSTA vai para o chat antes.

## 2. Testes sintéticos (`49_testes_posthoc_af.R`)

### O que cada teste confere


- `tp1`: Wald (W, gl e p) contra a conta à mão, com vcov não diagonal.
- `tp2`: a mesma semente dá as mesmas réplicas; as 2 primeiras de um laço de 3 são as de um laço de 2; os sorteios são os de uma sequência à mão com `set.seed(20261001, kind = ...)` uma vez antes do laço; com outro `RNGkind` ativo antes, as réplicas não mudam.
- `tp3`: com um *stub* que faz a sequência inteira do `mixmeta` falhar quando θ*[1, 1] > 0, as falhas são as esperadas, ficam marcadas e sem AF (nem substituídas nem excluídas), e o resumo as conta; os limites do p97,5 com as falhas nos extremos ficam em volta do p97,5 sem elas; uma réplica que cai no Ψ diagonal não é falha.
- `tp4`: média dos sorteios nulos a menos de 4 EP de 0 e covariância a menos de 10% de S_i (4.000 sorteios).
- `tp5`: os dois testes do item 2 (entrada 78(c)): (i) base da `attrdl` igual à base da busca no caso igual e diferente com outros Boundary.knots; (ii) com a MRT da grade de 0,1 °C e a mesma base, folga positiva, Δ_t negativo e o teste passa; com a base da `attrdl` diferente da base da busca, o teste cai; um dia fora do p1–p99 abaixo do mínimo não conta.
- `tp6`: AF total, calor e frio da réplica contra a AF *forward* à mão (sem a `attrdl`), com a MRT da réplica achada à mão; contagem de MRT nas pontas; MRT combinada e RR combinados no x99 e no x1 à mão (`splines::ns`).
- `tp7`: a réplica não consome o gerador nem refaz a semente (`.Random.seed` igual ao de depois dos sorteios).
- `tp8`: quantis do resumo contra a conta à mão; comparação com o p97,5, estrita (AF igual ao p97,5 não passa); sem falhas, os limites coincidem com o p97,5.

### Resultado: 8/8 testes


| Teste | Resultado |
|---|---|
| `tp1_wald_contra_conta_a_mao` | passou |
| `tp2_reprodutibilidade_e_sequencia_de_sorteios` | passou |
| `tp3_falhas_contadas_com_stub` | passou |
| `tp4_sorteios_nulos_com_media_zero` | passou |
| `tp5_testes_do_item_2` | passou |
| `tp6_replica_contra_contas_a_mao` | passou |
| `tp7_isolamento_do_gerador` | passou |
| `tp8_resumo_contra_conta_a_mao` | passou |

### Defeitos plantados (cada um numa cópia de `posthoc_af.R`; a bateria inteira roda em cada cópia)


| Defeito | Trocas | Testes derrubados (dos que passam no original) | Quais |
|---|---|---|---|
| semente refeita dentro do laço | 1 | 2 | tp2_reprodutibilidade_e_sequencia_de_sorteios, tp3_falhas_contadas_com_stub |
| sorteios com média diferente de zero | 1 | 2 | tp2_reprodutibilidade_e_sequencia_de_sorteios, tp4_sorteios_nulos_com_media_zero |
| réplica com falha excluída em silêncio | 1 | 1 | tp3_falhas_contadas_com_stub |
| Wald com gl − 1 | 1 | 1 | tp1_wald_contra_conta_a_mao |
| Wald só com a diagonal da vcov | 1 | 1 | tp1_wald_contra_conta_a_mao |
| AF contra o p50, e não contra a MRT da réplica | 1 | 1 | tp6_replica_contra_contas_a_mao |
| simulações dentro da réplica (consome o gerador) | 1 | 3 | tp2_reprodutibilidade_e_sequencia_de_sorteios, tp6_replica_contra_contas_a_mao, tp7_isolamento_do_gerador |
| RR combinado contra o p50, e não contra a MRT combinada da réplica | 1 | 1 | tp6_replica_contra_contas_a_mao |
| teste das contribuições sem a folga | 1 | 1 | tp5_testes_do_item_2 |
| teste da base comparando a base consigo mesma | 1 | 1 | tp5_testes_do_item_2 |
| busca da MRT sem os Boundary.knots da cross-basis | 1 | 4 | tp2_reprodutibilidade_e_sequencia_de_sorteios, tp3_falhas_contadas_com_stub, tp6_replica_contra_contas_a_mao, tp7_isolamento_do_gerador |
| semente sem o kind explícito | 1 | 1 | tp2_reprodutibilidade_e_sequencia_de_sorteios |
| comparação com o p97,5 não estrita | 1 | 1 | tp8_resumo_contra_conta_a_mao |
| teste das contribuições em todos os dias, e não só no p1–p99 | 1 | 1 | tp5_testes_do_item_2 |
| réplica que caiu no Ψ diagonal contada como falha | 1 | 1 | tp3_falhas_contadas_com_stub |

- **Resultado:** todos os testes passam na versão original e cada um dos 15 defeitos derruba pelo menos um teste.

`versao()` no fim: 4443971b.
## 3. Resultados (`50_posthoc_af.R`)

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

### Testes do item 2 (entrada 78(c)), no principal observado


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

### P1: teste de Wald da curva combinada


- Os 4 coeficientes previstos pelo `mixmeta` na média dos metapreditores (média 24,768 °C; amplitude 10,701 °C), com a vcov da predição: **W = 1,86; gl = 4; p = 0,762** (χ²). O teste não depende da MRT.

### P2: referência nula da AF (nulo estrito; descritiva)


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

## 4. Texto obrigatório e decisão de relato (D5, item 2)

O texto de Methods, Results, Limitations e Supplementary Methods está na D5 (itens 2 e 4) e entra na redação (Fase 6). Para o Limitations e o Results, os números desta Parte D são: o resultado da P1 (seção 3) e se a AF observada passa o p97,5 da referência nula (seção 3). A AF fica fora da conclusão do Abstract.

## 5. Dupla auditoria

### Autoauditoria (`51_autoauditoria_fase3D.R`)

- **Método:** as contas do 50 refeitas com código diferente e comparadas com as saídas (CSV e RDS, com os SHA-256 do log); os números refeitos foram procurados no texto do log com a mesma formatação.
- **Código diferente:** P1 com o `mixmeta` chamado direto e W à mão; testes do item 2 com `splines::ns`; réplicas 1, 2, 500 e 1.000 (fixadas no desvio 79(h)) com a sequência de sorteios regenerada, o `mixmeta` direto, a MRT na grade montada à mão, a AF *forward* à mão (sem a `attrdl`) e os RR combinados à mão; CSV de réplicas conferido contra a RDS no texto `%.17g`; quantis e comparação recalculados dos valores da RDS.
- **Tolerâncias:** 1e-8 a 1e-10, conforme a escala; quantis e textos com igualdade exata.

### Resultado: 17 de 17 conferências iguais


| Item | Conferência | N | Resultado |
|---|---|---|---|
| Entradas | CSV e RDS do 50 com os SHA-256 do log | 3 | igual |
| P1 | W e p (mixmeta direto, predição x̄B̂ e vcov à mão) | 2 | igual |
| P1 | W, gl e p no log do 50 | 1 | igual |
| Item 2 | g e menor Δ_t de São Paulo/SP (splines::ns, à mão) | 2 | igual |
| Item 2 | g e menor Δ_t de Sorocaba/SP (splines::ns, à mão) | 2 | igual |
| Item 2 | contagem de concentrações com o teste (ii) ok e com o diagnóstico de passo 1e-5 ok (CSV × RDS) | 2 | igual |
| P2 | réplica 1 refeita à mão (sorteios regenerados, mixmeta direto, MRT na grade, AF forward e RR combinados à mão) | 1 | igual |
| P2 | réplica 2 refeita à mão (sorteios regenerados, mixmeta direto, MRT na grade, AF forward e RR combinados à mão) | 1 | igual |
| P2 | réplica 500 refeita à mão (sorteios regenerados, mixmeta direto, MRT na grade, AF forward e RR combinados à mão) | 1 | igual |
| P2 | réplica 1000 refeita à mão (sorteios regenerados, mixmeta direto, MRT na grade, AF forward e RR combinados à mão) | 1 | igual |
| P2 | CSV de réplicas igual à tabela da RDS (texto %.17g, igualdade exata; colunas numéricas, falhas e métodos) | 8 | igual |
| P2 | AF observada = AF total do principal no CSV do 46 | 1 | igual |
| P2 | número de réplicas e de falhas | 2 | igual |
| P2 | mediana, p2,5 e p97,5 da AF total nula e a comparação | 4 | igual |
| P2 | AF observada, distribuição nula e comparação no log do 50 | 1 | igual |
| P2 | descritivas (calor, frio, RR no x99 e no x1, MRT no p99 e no p1) | 6 | igual |
| P2 | observado: 10 MRT BLUP no p99 e nenhuma no p1 | 2 | igual |

`versao()` no fim: 4443971b.
### Registro da dupla auditoria

Transcrito de `logs/auditoria_parteD_fase3_20261013.md`.


Registro achado → reprodução → correção, como manda o `CLAUDE.md` do artigo. A série diária só foi lida e processada dentro da Forja; nenhuma linha, valor diário, série diária ou AN/AF diário foi impresso ou gravado. Análises post hoc (entradas 78 e 79), não pré-especificadas.

### Etapa 1: autoauditoria e rodadas de desenvolvimento

- **Testes sintéticos (49), rodadas de desenvolvimento** (só no scratchpad, antes da oficial):
  - o caso do `tp5` esperava que o teste (ii) do item 2 caísse com a MRT fora do mínimo, e não caiu. A análise mostrou que, como especificado na entrada 78(c), a condição Δ_t ≥ −g − 1e-12 equivale a f(x_t) ≥ mín f na grade fina − 1e-12: a folga g cresce junto com a distância da MRT ao mínimo, e o teste não detecta MRT fora do mínimo. O que ele detecta é a base da `attrdl` diferente da base da busca, desde que Δ_t seja calculado com a base que a `attrdl` reconstrói e g com a base da busca. A `testa_contribuicoes` passou a receber as duas `argvar` (nos dados observados elas são idênticas, teste (i)), e o caso do `tp5` passou a exigir que o teste caia com bases diferentes. A entrada 79(f) não dizia qual base usar; isto é implementação;
  - a conferência da versão do MASS comparava texto ("7.3.65" × "7.3-65") e passou a comparar versões de pacote.
- **49 oficial, 1ª rodada:** 8 de 8 testes; cada um dos 11 defeitos plantados derruba pelo menos um teste (log hoje na lixeira). **2ª rodada**, depois do achado 5 da auditoria independente: 8 de 8, com 4 casos novos nos testes, e cada um dos 15 defeitos derruba pelo menos um teste (`logs/testes_posthoc_af_fase3_20261013.md`).
- **50, rodada de desenvolvimento** (só no scratchpad, 4 réplicas): o teste (ii) do item 2 caiu em 3 concentrações (Rio de Janeiro, Natal e Aracaju). Diagnóstico com código próprio da sessão (`diag_item2c.R`, no scratchpad): o menor f(x_t) fica abaixo do mínimo da grade de 0,001 °C em 2,4e-11, 2,6e-10 e 1,3e-9; com passo de 1e-4 °C ou 1e-5 °C, fica acima nas três. Há dias com x_t entre dois pontos da grade fina, mais perto do mínimo da curva; a base da `attrdl` é igual à da busca (teste (i), diferença 0). O critério registrado não mudou: o 50 reporta o teste como está e ganhou um diagnóstico com passo de 1e-5 °C, declarado como acrescentado depois da rodada de desenvolvimento. Um primeiro script de diagnóstico tinha um erro meu (grade fina sem o p99) e mostrou um g negativo falso em três concentrações com a MRT no p99; com o p99 na grade, g = 0 nelas, como na `testa_contribuicoes`.
- **50 oficial, 1ª rodada** (13/10, 23:32 a 23:39): conferências ok; P1; P2 com 1.000 réplicas (6,4 min), sem falhas; teste (ii) do item 2 caindo nas mesmas 3 concentrações, por resolução da grade fina (diagnóstico ok nas 26). **2ª rodada** (13/10, 23:55, a 14/10, 00:02), depois das correções da auditoria, com o mesmo rótulo de rodada `20261013`: os mesmos números; o CSV de réplicas e o do item 2 têm o mesmo SHA-256 da 1ª rodada; a RDS mudou só porque registra o SHA-256 do arquivo de testes.
- **51, 1ª rodada:** 15 de 16 conferências iguais. A diferente eram as descritivas da P2, recalculadas do CSV de réplicas com tolerância 0: o CSV foi gravado com `sprintf("%.17g")`, e a leitura de texto do R pode errar 1 ulp (diferença relativa de 2,1e-16; o mesmo efeito da Parte C). A tolerância não mudou: a conferência passou a recalcular os quantis dos valores da RDS e ganhou uma conferência do CSV contra a RDS no texto `%.17g`, em igualdade exata. Log da 1ª rodada na lixeira do volume (SHA-256 `d73528b76b37943388c810cb56f8afb736c5a50d0f6c7862ffa5f29f116842b0`).
- **51, 2ª rodada:** 17 de 17 (log hoje na lixeira). **3ª rodada**, depois da nova rodada do 50: **17 de 17** (`logs/autoauditoria_parteD_fase3_20261013.md`).
- **Rodadas de desenvolvimento do 50 com dado real (achado 3 da auditoria independente):** duas, às 23:29:30 e às 23:31:55, só no scratchpad (`devD/`), com a P2 reduzida a 4 réplicas. Cada uma calculou os testes do item 2, a P1 e as 4 réplicas. Foram vistos, antes da rodada oficial: o teste (ii) caindo em 3 concentrações; a P1 (W = 1,857; p = 0,762); 4 réplicas nulas, sem falha, com a AF observada acima do p97,5 delas: não. Antes da primeira, o 50 só tinha mudado na formatação dos valores observados e nos caminhos do 45 e do 46. Entre a primeira e a rodada oficial, a única mudança foi o diagnóstico do item 2 (passo de 1e-5 °C), com o critério intacto. Depois da auditoria, o 50 mudou só na trava do 49 (11 → 15 defeitos) e no separador de milhar das contagens. A medida de tempo antes da entrada 79 usou só dado sintético.
- **Limite:** as rodadas de desenvolvimento ficaram só no scratchpad da sessão e não são verificáveis por terceiros.

### Auditoria independente

- **Auditor:** subagente em contexto limpo. Leu a D5, as entradas 73, 77, 78 e 79, o código (`posthoc_af.R`, `segunda_etapa.R` da tag, `attrdl.R`, `testa_posthoc_af.R`), os scripts 49 a 51 e os logs; leu com R, sem imprimir linhas, as saídas da Parte D e da Parte C, a RDS da primeira etapa, os CSV de referência e de percentis e a série da Fase 1. Não abriu `.parquet` nem `.dbc`, não rodou os scripts 40 a 52 e não escreveu no repositório. Rodou com código próprio (`aud12/*`, no scratchpad).
- **Veredito do auditor:** o que foi rodado corresponde à D5 e às entradas 78 e 79, e os números estão certos. Ele refez as 1.000 réplicas da P2 uma a uma (diferença máxima de 3e-16 na AF, 6,7e-16 nos RR e 1,1e-14 na MRT combinada), mais 20 réplicas escolhidas por ele, a P1 (W = 1,856817; p = 0,762073) e os testes do item 2 nas 26; o código da tag está inalterado. A queda do teste (ii) vem da resolução da grade fina, com as bases idênticas. Um ponto a corrigir antes da RESPOSTA (o escopo da rodada de desenvolvimento) e cinco notas.
- **Achados:** 6
  - 1 marcado como "corrigir antes da RESPOSTA" (3) e 5 como "nota" (1, 2, 4, 5 e 6).
  - Todos foram aceitos. Os achados 4 e 5 foram reproduzidos por código próprio da sessão (`repro_aud12.R`, no scratchpad); o 1, pelos diagnósticos da sessão com grades de 1e-4 e 1e-5 °C (`diag_item2c.R`); o 2, o 3 e o 6, pela leitura dos scripts, dos logs e das saídas.

| Nº | Achado (classificação do auditor) | Reprodução | Correção |
|---|---|---|---|
| 1 | O teste (ii), como registrado, mede a resolução da grade fina, e não a igualdade das bases. Em Rio de Janeiro, Natal e Aracaju, as faltas (−2,37e-11, −2,59e-10 e −1,28e-9) cabem na cota teórica da grade de 0,001 °C, f″·h²/8 (1,36e-10, 1,17e-9 e 3,00e-9, pelo auditor); contra o mínimo contínuo, o teste passa nas 26, com menor folga de +9,95e-12 (nota; decisão do chat) | Com passo de 1e-4 °C e de 1e-5 °C, as faltas das três somem (diagnóstico da sessão); as bases são idênticas (teste (i), diferença 0) | Nenhuma no código. A RESPOSTA leva a pendência ao chat, com a cota e o mínimo contínuo ao lado do diagnóstico de 1e-5 °C: aceitar o (i) como a pré-condição do item 1.4 ou redefinir o (ii) (g contra o mínimo contínuo, ou tolerância ≥ máx f″·h²/8) |
| 2 | Calcular g com a base da busca e Δ_t com a base da `attrdl` é uma leitura fiel da entrada 78(c); a entrada 79(f) não diz qual base vai em cada termo (nota) | Com o teste (i) igual a 0, as duas leituras dão números idênticos (o auditor reproduziu g e o menor Δ_t com uma única f, diferença ≤ 2e-21) | Declarado aqui e na RESPOSTA: g com a base da busca, Δ_t com a base que a `attrdl` reconstrói, para que o teste detecte base diferente |
| 3 | A rodada de desenvolvimento do 50 com dado real não tinha o escopo registrado; a entrada 79 diz que, no registro, nada com dado real tinha sido calculado (corrigir antes da RESPOSTA) | Confirmado: as saídas dessas rodadas ficaram só no scratchpad | Registrado na Etapa 1 deste log: horários, o que cada rodada calculou, o que foi visto e as mudanças no 50 depois delas. A entrada 79 continua certa quanto ao momento do registro (antes de qualquer rodada com dado real) |
| 4 | A frase da D5 de que os negativos dentro do p1–p99 ficam "na ordem de 10⁻⁹" não confere com os dados: a menor contribuição diária dentro do p1–p99 é −4,15e-05 e fica abaixo de −1e-8 em 15 das 26 concentrações; a soma dentro do p1–p99 é −0,034 de AN, e fora, −38,70 (0,15% do AN total); o teste original do item 1.4 passaria em só 11 das 26 (nota, para o chat de métodos) | Código próprio: menor Δ_t de −4,151e-05; 15 de 26 abaixo de −1e-8 (CSV do item 2); as somas são as do log do 46 | Nenhuma no código. A RESPOSTA leva a informação ao chat de métodos, com a sugestão do auditor: qualificar a frase de Methods com "up to the 0.1 °C resolution of the MRT search grid", ou dar a magnitude no suplemento |
| 5 | A bateria do 49 deixava passar 4 dos 14 defeitos plantados pelo auditor: semente sem o `kind` explícito; comparação com `>=`; teste (ii) em todos os dias; réplica com Ψ diagonal contada como falha. Nenhum afeta os números desta rodada (nota; acrescentar antes da tag, porque o Artigo 2 reusa o código) | Código próprio: os 4 defeitos não derrubavam nenhum teste | Quatro casos novos nos testes (outro `RNGkind` antes da P2; *stub* que derruba só o Ψ não estruturado; dia fora do p1–p99 abaixo do mínimo; AF igual ao p97,5) e os quatro defeitos no 49, que passou a ter 15. O `posthoc_af.R` não mudou. O 49, o 50 e o 51 rodaram de novo, para o log do 50 registrar o SHA-256 do arquivo de testes em vigor |
| 6 | Formatação do log do 50: notação científica com ponto decimal num texto com vírgula, e "1000 réplicas" sem o separador de milhar (nota) | Confirmado pela leitura | As contagens de réplicas ganharam o separador de milhar. A notação científica fica com ponto decimal, como nos logs das Partes A a C |

#### Conferido e aprovado pelo auditor (resumo)

- `segunda_etapa.R`, `ajusta_dlnm.R` e `offset.R` iguais aos da tag; `posthoc_af.R`, `testa_posthoc_af.R` e `attrdl.R` com os SHA-256 registrados; MASS 7.3-65, igual ao `renv.lock`.
- Entradas com os SHA-256 registrados; Sᵢ = vcov reduzida da primeira etapa; metapreditores do CSV de ano inteiro, iguais aos do 45.
- P1: `mixmeta` REML com Ψ não estruturado e predição na média iguais à do 45; W, gl e p iguais.
- P2: os passos 1 a 7 implementados; as 1.000 réplicas refeitas com os sorteios gerados de antemão, BLUP à mão, grade com `splines::ns`, AF *forward* e RR à mão; 0 falhas; AF nula positiva em 1.000 de 1.000; mediana, p2,5, p97,5, a comparação e as descritivas iguais às do log. Isso também mostra que nada dentro da réplica refaz a semente ou consome o gerador.
- Observado: AF total, de calor e de frio refeitas à mão iguais às do CSV do 46; MRT combinada e RR no x99 e no x1 iguais aos do 45; 10 MRT no p99 e nenhuma no p1.
- Testes do 49 com referências independentes (Wald à mão, AF sem a `attrdl`, quantis à mão); autoauditoria coerente.

### Regeneração dos logs

Os logs e as saídas da Parte D foram regenerados depois das correções; os antigos estão na lixeira do volume, com o SHA-256 anotado.

| Arquivo | Rodada antes das correções da auditoria independente (lixeira) |
|---|---|
| `logs/testes_posthoc_af_fase3_20261013.md` | `e54e66090df32f86528458aa9fe8e9fb33f57594af1f9de07c0eb2d32f135819` |
| `logs/posthoc_af_fase3_20261013.md` | `c84be3a0edc642db8679b9b9b76f26c5dc16eed220e13632fe73e82be2bd9160` |
| `logs/autoauditoria_parteD_fase3_20261013.md` | `3c770b30a00cc24c19be6e5658bc06072722684cb56b6cf83c4a451d5bb4b966` (2ª rodada do 51; a 1ª, `d73528b76b37943388c810cb56f8afb736c5a50d0f6c7862ffa5f29f116842b0`) |
| `01_saidas/fase3/posthoc_p2_replicas_fase3_20261013.csv` | `a53e4b7784b3bd8c3de451ef1dfc290f673f201fc9c671e1efab4af6bfa41e40` (igual ao em vigor) |
| `01_saidas/fase3/posthoc_item2_fase3_20261013.csv` | `1da3e93205b0a5dd9e16bee068f9a66b69ebe953291e01fa81ba3d6038817511` (igual ao em vigor) |
| `01_saidas/fase3/posthoc_af_fase3_20261013.rds` | `9910f2217ae8ec033a3af7a7c6988a759ba1a1be42b6591f79b4c3b60cd0a703` |

- Os SHA-256 das saídas em vigor estão no log do 50 e na RESPOSTA.


## 6. Entradas do log desta parte

As entradas 78 (registro da D5, não é desvio) e 79 (escolhas de implementação) foram registradas em commits próprios antes de rodar.

| # | Data | Etapa | Referência | O que divergiu | Causa | Efeito nos resultados | Decisão | Evidência |
|---|---|---|---|---|---|---|---|---|
| 78 | 2026-10-13 | Fase 3, Parte D, antes de rodar. **Registrada depois de ver os resultados da Fase 3** (AF total do principal de 1,84%, RR combinados com IC incluindo 1, MRT BLUP no p99 em 10 de 26). Artigo 1. **Não é desvio:** nenhuma análise especificada muda | `spec/decisoes_metodo_20261013_D5_interpretacao_AF.md` (D5 do chat de métodos, SHA-256 `24f131e8b3cb45f05efcaa8b59ba97bbaaec5f50f106939a16836b3fd66f668a`, conferido na cópia contra o arquivo baixado; o texto não trouxe o SHA de emissão, e Guilherme confirma pelo arquivo), seção 8, com os itens 1.4, 2 e 4 | **Análises post hoc 78 e decisão de relato — curva combinada, referência nula da AF e Abstract.** (a) **P1:** Wald (4 gl) da curva combinada na média dos metapreditores (D5, item 4, P1): W = β̂′V̂⁻¹β̂, com β̂ e V̂ da predição do `mixmeta`; reportar W, gl e p. (b) **P2:** distribuição da AF sob o nulo estrito (D5, item 4, P2, passos 1 a 7): 1.000 réplicas, semente combinada uma vez antes do laço, com o `kind` explícito; θᵢ* ~ N(0, Sᵢ) pelo `MASS::mvrnorm`; segunda etapa com a mesma sequência de estabilidade; falhas contadas; MRT da réplica; AF *forward* pontual na série completa e consecutiva. Descritiva, com uma única comparação (AF total observada × p97,5 da distribuição nula); o resto sem p. (c) **Teste novo, substituído por decisão do chat do Artigo 1:** o teste do item 1.4 da D5 (menor contribuição diária dentro do p1–p99 ≥ −10⁻⁸) falharia por causa da grade de 0,1 °C da busca da MRT, e não por base diferente: na Fase 3, o principal já somou −0,034 de AN dentro do p1–p99. Passa a valer, em cada concentração: (i) **pré-condição:** a base que a `attrdl` reconstrói de `attr(basis, "argvar")` é igual à usada na busca da MRT, `do.call(onebasis, c(list(x = grade), argvar))`, com diferença ≤ 1e-12; (ii) **contribuições:** f calculada numa grade fina (passo de 0,001 °C) entre o p1 e o p99, com a folga g = f(MRT) − min_fina(f) ≥ 0, e Δ_t = f(x_t) − f(MRT) ≥ −g − 1e-12 em todos os dias com x_t dentro do p1–p99. Reportar o g máximo e o menor Δ_t. (d) **Decisão de relato:** a AF fica fora da conclusão do Abstract; texto obrigatório conforme o item 2 da D5. (e) **O que não muda:** todas as análises especificadas e a AF do principal. (f) **Nota sobre a RESPOSTA FASE3C** (SHA-256 `480691a0b0c5652af1625afcd6ff7fec508d47274ee3d3c4e5cbc3f7bd8f6f03`), aprovada pelo chat do Artigo 1 sem v2: duas falhas de redação, sem efeito em número. Na tabela da auditoria independente, a coluna "Correção" do achado 5 ainda diz "cobertura do IC da combinada", e depois da nota N1 da re-auditoria o termo é "extensão". No fim da autoauditoria, falta a linha em branco depois da linha do `versao()` | Decisão D5 do chat de métodos, pedida pelo chat do Artigo 1 depois da Fase 3; troca do teste do item 1.4 decidida pelo chat do Artigo 1 | Nenhum efeito nas análises especificadas nem na AF do principal. Resultados vistos antes do registro: todos os da Fase 3 (Partes A a C) | Aprovação: Guilherme, 13/10/2026 (mensagem do chat do Artigo 1 com o ok de Guilherme) | `spec/decisoes_metodo_20261013_D5_interpretacao_AF.md`; `RESPOSTA_artigo1_prematuridade_FASE3C_20261013.md`; `logs/fracao_atribuivel_fase3_20261013.md` (−0,034 dentro do p1–p99) |
| 79 | 2026-10-13 | Fase 3, Parte D, antes de rodar (plano aprovado por Guilherme em 13/10/2026). Artigo 1 | `spec/decisoes_metodo_20261013_D5_interpretacao_AF.md` (SHA-256 `24f131e8b3cb45f05efcaa8b59ba97bbaaec5f50f106939a16836b3fd66f668a`), itens 1.4 (com a troca da entrada 78(c)) e 4; entrada 78; mensagem do chat do Artigo 1 de 13/10/2026 (Parte D) | **Escolhas de implementação da Parte D (post hoc P1 e P2), sem mudar o método.** (a) **Código e scripts:** `codigo_compartilhado/R/posthoc_af.R` (`wald_curva`, `sorteia_nulo`, `replica_nula`, `p2_nulo`, `resumo_p2`, `testa_base_mrt`, `testa_contribuicoes`), que usa as funções da tag `segunda_etapa-v1.0` sem alterá-las (SHA-256 conferido contra a tag); testes sintéticos em `codigo_compartilhado/tests/testa_posthoc_af.R`; scripts 49 (testes e defeitos plantados), 50 (conferências, testes do item 2 no principal observado, P1 e P2), 51 (autoauditoria) e 52 (RESPOSTA); logs `_fase3_<data>`, com `parteD` nos de auditoria; saídas em `01_saidas/fase3/`, fora do git, com SHA-256. A tag `posthoc_af-v1.0` só depois de o chat aprovar a RESPOSTA, no commit que rodou. (b) **Falhas da P2 (passo 4):** uma réplica em que a sequência inteira falha não tem AF; ela é contada e listada. A distribuição é calculada sobre as réplicas sem falha, e, para a única comparação, o p97,5 também é informado com as réplicas que falharam postas nos dois extremos (−∞ e +∞), o que limita o efeito das falhas; com zero falhas, as versões coincidem. (c) **Semente e gerador da P2:** `semeia(0)` da tag (`set.seed(20261001, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")`) uma única vez antes do laço; em cada réplica, θᵢ* = `MASS::mvrnorm(1, 0, Sᵢ)` nas 26 concentrações, na ordem travada. Dentro da réplica, nada refaz a semente nem consome o gerador: a P2 não chama `fracao_atribuivel` nem `boot_tmr` (as duas chamam `semeia(i)`); a AF pontual vem da `attrdl` com `sim = FALSE`, com os `range` da `componentes_attrdl`. (d) **Réplica da P2:** `meta_curva` com os metapreditores e a sequência de estabilidade da C1; MRT BLUP pela `busca_tmr` na grade p1–p99 de cada concentração (A0), com a `argvar` da cross-basis (`attr(basis, "argvar")`, a mesma que a `attrdl` usa); AF *forward* pontual nas 4.498 linhas da janela, com a cross-basis da série completa e consecutiva (4.505 linhas), nos componentes total, calor e frio, contra a MRT da réplica; AF total = soma dos AN / soma dos eventos da janela; RR combinados no x99 e no x1 pela `curva` na base combinada (D2) e no eixo médio, contra a MRT combinada da réplica (`busca_tmr` na grade x1–x99); MRT no p99 e no p1 contadas pelo índice da grade. (e) **Comparação e relato:** a AF total observada é a do principal no CSV do 46 (1,84%); a única comparação é "AF observada > p97,5 da distribuição nula". Calor, frio, RR combinados no x99 e no x1 e o número de MRT no p99 e no p1 saem só como distribuições descritivas (mediana e p2,5 a p97,5), ao lado do observado, sem p. (f) **Testes do item 2** (entrada 78(c)), no principal observado, nas 26 concentrações: (i) a base que a `attrdl` reconstrói de `attr(cb, "argvar")` contra a base da busca da MRT (a `argvar` da RDS, usada no 45) na grade p1–p99, com diferença ≤ 1e-12; (ii) a folga g na grade fina de 0,001 °C entre p1 e p99 (o p99 entra se faltar) e Δ_t ≥ −max(g, 0) − 1e-12 nos dias da janela com x_t dentro do p1–p99; g ≥ −1e-12 é aceito como zero numérico. Reportar o g máximo e o menor Δ_t. Nas réplicas da P2, esses testes não rodam. (g) **Testes sintéticos e defeitos:** Wald contra a conta à mão; reprodutibilidade (a mesma semente dá réplicas idênticas; as 2 primeiras de um laço de 3 são iguais às de um laço de 2; os sorteios são os de uma sequência à mão); contagem de falhas com *stub*; média dos sorteios ≈ 0 e covariância ≈ Sᵢ; os dois testes do item 2, com casos que têm de cair; AF da réplica igual à `attrdl` direta e RR combinado contra a MRT combinada da réplica; isolamento do gerador. Uns 10 defeitos plantados, cada um tem de derrubar um teste. (h) **Autoauditoria:** P1 com o `mixmeta` direto; os testes do item 2 à mão em São Paulo e Sorocaba; as réplicas 1, 2, 500 e 1.000, fixadas agora, refeitas com código independente (sequência de sorteios regenerada, `mixmeta` direto, grade e AF à mão); quantis, comparação e contagens recalculados do CSV | Detalhes que a D5 e a mensagem do chat deixam para a implementação; propostas 1 a 4 do plano | Nenhum efeito nas análises especificadas. Resultados vistos antes do registro: os da Fase 3 (Partes A a C); nenhuma réplica nula, P1 ou teste do item 2 com dado real foi calculado (só a medida de tempo de uma réplica com dado sintético) | Plano aprovado por Guilherme, 13/10/2026 | Logs da Parte D: `logs/testes_posthoc_af_fase3_<data>.md`, `logs/posthoc_af_fase3_<data>.md`, `logs/autoauditoria_parteD_fase3_<data>.md` e `logs/auditoria_parteD_fase3_<data>.md` |

## 7. Comandos, ambiente e SHA-256

Da pasta `artigo1_prematuridade/`, com o `renv` do artigo (R 4.5.1), nesta ordem. Cada script tem trava contra sobrescrita.

```
FASE3_DATA=20261013 Rscript 00_scripts/49_testes_posthoc_af.R
FASE3_DATA=20261013 Rscript 00_scripts/50_posthoc_af.R
FASE3_DATA=20261013 Rscript 00_scripts/51_autoauditoria_fase3D.R
FASE3_DATA=20261013 Rscript 00_scripts/52_resposta_fase3D.R
```

**`versao()` no início e no fim de cada script:**

| Log | Script | Início | Fim |
|---|---|---|---|
| `testes_posthoc_af_fase3_20261013.md` | `00_scripts/49_testes_posthoc_af.R` | 4443971b | 4443971b |
| `posthoc_af_fase3_20261013.md` | `00_scripts/50_posthoc_af.R` | 4443971b | 4443971b |
| `autoauditoria_parteD_fase3_20261013.md` | `00_scripts/51_autoauditoria_fase3D.R` | 4443971b | 4443971b |
| (este retorno) | `00_scripts/52_resposta_fase3D.R` | 4443971b | 4443971b (conferido no fim do script) |

**SHA-256 do código, dos scripts e das saídas** (saídas fora do git, em `01_saidas/fase3/`, conferidas contra o log do 50):

| Arquivo | SHA-256 |
|---|---|
| `codigo_compartilhado/R/posthoc_af.R` | `a90096b74237afee576532460def71937083e1d6363e6d1ef8f1e204b1f0af73` |
| `codigo_compartilhado/tests/testa_posthoc_af.R` | `3ec9f2afe5021a1be1d84fb3edaf7976c8ee508b134d95025ff1c109df3affa5` |
| `artigo1_prematuridade/00_scripts/49_testes_posthoc_af.R` | `48b9aed98221701e1ca5b89c42fb06394b44483834fa9416e76516a08f034f70` |
| `artigo1_prematuridade/00_scripts/50_posthoc_af.R` | `e184818e4a74b100d30e691dc05dd4917766cf339883ad0b47be3ba243f701c0` |
| `artigo1_prematuridade/00_scripts/51_autoauditoria_fase3D.R` | `f85b676b5b0f89287eeffe274812accc44ce489d41c98c13734807126f276ef1` |
| `artigo1_prematuridade/00_scripts/52_resposta_fase3D.R` | `717adb271266fda1e1d5498f91cc4134c71f3fa602487793c7792ca99f707523` |
| `artigo1_prematuridade/01_saidas/fase3/posthoc_p2_replicas_fase3_20261013.csv` | `a53e4b7784b3bd8c3de451ef1dfc290f673f201fc9c671e1efab4af6bfa41e40` |
| `artigo1_prematuridade/01_saidas/fase3/posthoc_item2_fase3_20261013.csv` | `1da3e93205b0a5dd9e16bee068f9a66b69ebe953291e01fa81ba3d6038817511` |
| `artigo1_prematuridade/01_saidas/fase3/posthoc_af_fase3_20261013.rds` | `223e09366a445b99bd947d3f59f66fa20d755b019af149bfeb4bac026593d11d` |

## 8. `git status`

Saída de `git status --porcelain --untracked-files=all`, antes de gravar este retorno e antes do commit local da Parte D. Arquivos de outras sessões, se houver, só são mostrados:

```
 M artigo2_obito_perinatal/logs/confirmacoes_fase3_20261013.md
 M artigo2_obito_perinatal/logs/desvios_especificacao.md
 M artigo3_pig/logs/desvios_especificacao.md
?? artigo1_prematuridade/00_scripts/49_testes_posthoc_af.R
?? artigo1_prematuridade/00_scripts/50_posthoc_af.R
?? artigo1_prematuridade/00_scripts/51_autoauditoria_fase3D.R
?? artigo1_prematuridade/00_scripts/52_resposta_fase3D.R
?? artigo1_prematuridade/logs/auditoria_parteD_fase3_20261013.md
?? artigo1_prematuridade/logs/autoauditoria_parteD_fase3_20261013.md
?? artigo1_prematuridade/logs/posthoc_af_fase3_20261013.md
?? artigo1_prematuridade/logs/testes_posthoc_af_fase3_20261013.md
?? artigo2_obito_perinatal/00_scripts/50_segunda_etapa.R
?? artigo2_obito_perinatal/00_scripts/51_testes_b3.R
?? artigo2_obito_perinatal/00_scripts/52_fracao_atribuivel.R
?? artigo2_obito_perinatal/00_scripts/53_autoauditoria.R
?? artigo2_obito_perinatal/00_scripts/54_autoauditoria.py
?? artigo2_obito_perinatal/logs/autoauditoria_python_fase3_20261013.md
?? artigo2_obito_perinatal/logs/autoauditoria_r_fase3_20261013.md
?? artigo2_obito_perinatal/logs/fracao_atribuivel_fase3_20261013.md
?? artigo2_obito_perinatal/logs/plano_fase3_20261013.md
?? artigo2_obito_perinatal/logs/segunda_etapa_fase3_20261013.md
?? artigo2_obito_perinatal/logs/sessionInfo_fase3_20261013.txt
?? artigo2_obito_perinatal/logs/testes_b3_fase3_20261013.md
?? artigo3_pig/00_scripts/44_leitura_conferencia_A0.R
?? artigo3_pig/00_scripts/45_testes_funcao_v2.R
?? artigo3_pig/00_scripts/46_ajustes_bloco_A.R
?? artigo3_pig/00_scripts/47_equivalencia_v2.R
?? artigo3_pig/00_scripts/48_fator_G_positividade_A4.R
?? artigo3_pig/00_scripts/50_segunda_etapa_B1_B5.R
?? artigo3_pig/00_scripts/51_fracao_atribuivel_B6.R
?? artigo3_pig/00_scripts/52_figuras_B8.R
?? artigo3_pig/00_scripts/53_teste_sintetico_segunda_etapa_A5.R
?? artigo3_pig/00_scripts/54_autoauditoria_R.R
?? artigo3_pig/00_scripts/55_autoauditoria_numpy.py
?? artigo3_pig/00_scripts/56_reproducao_revisao_pre_A6.R
?? artigo3_pig/00_scripts/funcoes_ajuste_pig_v2.R
?? artigo3_pig/00_scripts/funcoes_segunda_etapa_pig.R
?? artigo3_pig/logs/equivalencia_v2_fase3_20261013.md
?? artigo3_pig/logs/execucao_46_a3_fase3_20261013_231315.md
?? artigo3_pig/logs/execucao_46_equivalencia_fase3_20261013_231246.md
?? artigo3_pig/logs/leitura_conferencia_A0_fase3_20261013.md
?? artigo3_pig/logs/prompt_fase3_chat_A3_20261013.md
?? artigo3_pig/logs/sessionInfo_44_fase3_20261013.txt
?? artigo3_pig/logs/sessionInfo_45_fase3_20261013.txt
?? artigo3_pig/logs/sessionInfo_47_fase3_20261013.txt
?? artigo3_pig/logs/sessionInfo_53_fase3_20261013.txt
?? artigo3_pig/logs/teste_funcao_v2_fase3_20261013.md
?? artigo3_pig/logs/teste_sintetico_segunda_etapa_fase3_20261013.md
?? codigo_compartilhado/R/posthoc_af.R
?? codigo_compartilhado/tests/testa_posthoc_af.R
```

`git log --oneline -4`:

```
e925532 Fase 3 do Artigo 1, Parte D: desvio 79 (escolhas de implementacao do post hoc P1 e P2), antes de rodar
7e071cd Fase 3 do Artigo 1, Parte D: D5 do chat de metodos em spec/ e entrada 78 (post hoc P1 e P2, antes de rodar)
ec38fc3 Fase 3 do Artigo 1, Parte C: segunda etapa com os dados reais (C1 a C6), fracao atribuivel e dupla auditoria (sem push)
6a77510 Artigo 2, Fase 3, B0: copia do codigo da tag segunda_etapa-v1.0, conferencia da interface e dos insumos (desvios 92 a 94)
```

Commit local da Parte D. **Sem push e sem tag:** a RESPOSTA vai para o chat do Artigo 1 antes; a tag `posthoc_af-v1.0` só depois da aprovação, no commit que rodou.
