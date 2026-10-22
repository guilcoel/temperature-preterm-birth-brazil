# Decisões de método — 13/10/2026, D5: interpretação da fração atribuível com a MRT estimada

**De:** chat de métodos (coordenação geral) · **Data:** 13/10/2026 · **Origem:** Fase 3 do Artigo 1 (concluída e auditada em 13/10)
**Âmbito:** Artigos 1 e 2 (desenho agudo); para o Artigo 3, ver o item 6.

**Relação com os outros documentos.**
- Complementa `decisoes_metodo_20261013.md` (D1) e `decisoes_metodo_20261013_complemento.md`.
- **Não muda nenhuma análise especificada.** Acrescenta três coisas:
  - texto obrigatório de Methods, Results e Limitations;
  - uma decisão de relato (a AF fora da conclusão do Abstract);
  - duas análises post hoc rotuladas como tal.
- Entra como arquivo novo em `spec/`, num commit comum.

---

## Resumo

| Pedido do Artigo 1 | Decisão |
|---|---|
| (a) Declarar que a AF com `cen` na MRT estimada é não negativa por construção e que o eCI não incorpora a incerteza da MRT nem a dependência entre os BLUPs | **Aprovado**, com acréscimos: (i) os RR contra a MRT buscada no p1–p99 também são ≥ 1 por construção, e os IC deles são condicionais à MRT; (ii) a frase tem uma pré-condição de código (item 1.4); (iii) a regra de fronteira da §7, que é pré-especificada, foi disparada e entra em Results |
| (b) Não ler a AF como evidência de associação quando os RR combinados incluem 1 | **Aprovado.** Decisão de relato: a AF fica fora da conclusão do Abstract |
| Post hoc com a MRT sorteada dentro de cada simulação | **Rejeitado:** não corrige o viés e o agrava (prova no item 3) |
| Outra análise post hoc? | **Sim, duas, no suplemento, iguais nos Artigos 1 e 2:** (P1) teste de Wald da curva combinada, a afirmação inferencial sobre associação; (P2) referência nula da AF, descritiva, sob o nulo estrito (item 4) |

---

## 1. O mecanismo (reproduzido)

1. **A AF tende a ser positiva sob efeito nulo.**
   - A `cen` é o mínimo da curva BLUP na grade p1–p99. Então f(x) − f(MRT) ≥ 0 em todos os dias dentro dessa faixa, até a resolução da grade: os negativos ficam na ordem de 10⁻⁹. Cada contribuição diária 1 − e^−(f(x) − f(MRT)) é, portanto, ≥ 0.
   - Fora do p1–p99 pode haver contribuição negativa, mas é desprezível (na simulação do auditor, −9,5 × 10⁻⁵ contra uma AF de 3,3%).
   - Resultado: a AF é viesada para cima sob efeito nulo.
2. **Os RR contra a MRT buscada no p1–p99 também são ≥ 1 por construção.**
   - Isso vale para o x99 (1,003) e o x1 (1,020) contra a MRT combinada. O ponto não informa a direção.
   - Os IC desses RR também tratam a MRT como fixa, e por isso são anticonservadores. Um IC que inclui 1 não é evidência de associação; um IC que excluísse 1 também não estaria calibrado.
   - Os RR da regra de fronteira (contra a mediana; busca entre p10 e p90) não têm essa propriedade e podem ser < 1.
3. **O eCI da AF é condicional.** Ele sorteia os coeficientes em torno do BLUP com a MRT fixa e soma as concentrações como independentes.
   - Sob efeito nulo, o eCI excluiu o zero em **40 de 40 réplicas** (chat de métodos, 1ª etapa sem encolhimento).
   - O auditor achou 100 em 100 (1ª etapa) e 96 em 100 com REML + BLUP somados como independentes.
   - A soma independente estreita o eCI: com Ψ = 0, a exclusão foi de 89% com sorteios independentes contra 16% com um sorteio comum.
   - A dependência entre os BLUPs é, portanto, um fator dominante, não um detalhe.
4. **Pré-condição da frase "por construção".** A busca da MRT e a `attrdl` têm de usar a **mesma base**: mesmos nós e mesmos `Boundary.knots`.
   - A `attrdl` reconstrói a base com `attr(basis, "argvar")` (l. 124). Passando a ela o `cb` da própria primeira etapa e buscando a MRT com `do.call(onebasis, c(list(x = grade), attr(cb, "argvar")))` (D2, teste 3), as bases coincidem.
   - **Teste a acrescentar:** em cada concentração, a menor contribuição diária dentro do p1–p99 é ≥ −10⁻⁸.

**Simulações** (`af_nula.py` e `repro_aud6.py`, semente 20261001). O pipeline é simplificado e **só ilustrativo**:
- 26 concentrações sintéticas, de 3 a 60 PTB por dia, estratos ano × mês, curva `ns` com nós p10/p75/p90, efeito verdadeiro nulo;
- o encolhimento é aproximado nos dois extremos;
- há um fator × 4 na variância, aproximação arbitrária da perda por lag, que dobra as magnitudes.

Os números **não** estimam o que aconteceria nos dados do estudo, e não devem ser comparados com os 1,84% observados.

| Situação sob efeito nulo (300 réplicas) | AF total, mediana (p2,5 a p97,5) | AF mínima |
|---|---|---|
| Sem encolhimento (1ª etapa) | 3,31% (2,54 a 4,19) | 2,39% |
| Encolhimento total (Ψ = 0; a mesma média nas 26) | 0,63% (0,17 a 1,84) | 0,10% |
| REML + BLUP (auditor) | mediana de 1,0% a 1,1% com o × 4; 0,57% sem ele | > 0 |

**Em 100% das réplicas, a AF foi positiva.**

## 2. Texto obrigatório (inglês americano; os dois artigos agudos)

**Methods, Statistical analysis** (depois da frase da D1 sobre a AF):
> Because the reference temperature was the minimum of each estimated exposure–response curve within the 1st–99th percentile range, daily contributions within that range are non-negative by construction, and the attributable fraction is expected to be positive (biased upward) even in the absence of an association; for the same reason, relative risks against the MRT are not lower than 1, and their confidence intervals, like the empirical confidence intervals of the attributable fraction, are conditional on the estimated MRT. The empirical confidence intervals also treated urban concentrations as independent, although BLUPs share the pooled mean, which narrows them. As post hoc analyses, we tested the pooled exposure–response curve against a flat curve and estimated the distribution of the attributable fraction under no association in any urban concentration (Supplementary Methods).

**Results:** reportar a regra de fronteira da §7, que é pré-especificada:
- a MRT BLUP caiu no p99 em 10 de 26 concentrações;
- por isso entram os RR contra a mediana e a busca entre p10 e p90;
- ao lado da AF, entram o teste P1 e a referência P2.

**Limitations:**
> The attributable fraction should not be read as evidence of an association. Its point estimate is non-negative by construction when the reference is the estimated MRT, and its empirical confidence interval does not incorporate the uncertainty of the MRT or the dependence between BLUPs. In this study, none of the pooled relative risks excluded the null, the pooled MRT was imprecisely estimated (its 95% CI spanned the entire search range), and the MRT fell at the 99th percentile in 10 of 26 urban concentrations. The post hoc test of the pooled curve [P1 result]; the attributable fraction [exceeded / did not exceed] the 97.5th percentile of its distribution under no association in any urban concentration, which, if exceeded, indicates concentration-specific associations or heterogeneity rather than a pooled association.

**Discussion (decisão (b), em português, para o chat do artigo):**
- A evidência sobre associação vem dos RR combinados e do teste P1, nunca da AF.
- A AF é apresentada como "if causal", em Results e no suplemento, com a referência P2 ao lado.

**Abstract (decisão de relato):**
- A AF não entra na conclusão.
- Se entrar em Results, vem junto com os RR combinados e seus IC e com o rótulo "if causal".

## 3. Por que a MRT sorteada dentro de cada simulação não serve (prova)

- Para o mesmo sorteio s, o mínimo da curva sorteada na grade satisfaz min f_s ≤ f_s(MRT₀), em que MRT₀ é a MRT fixa.
- Logo f_s(x) − min f_s ≥ f_s(x) − f_s(MRT₀) em todo dia x. Como 1 − e^(−u) é crescente, cada contribuição diária re-sorteada é ≥ a de MRT fixa.
- Então **AF re-sorteada ≥ AF fixa em cada sorteio**, e todas são ≥ 0 dentro do p1–p99. O intervalo se afasta do zero.
- Na réplica nula ilustrativa: eCI com MRT fixa de 2,25% a 4,04%; com a MRT re-sorteada, de 3,57% a 5,13%. O auditor achou 0 violações da desigualdade em 2.000 sorteios.

## 4. Análises post hoc aprovadas (Artigos 1 e 2, suplemento)

### P1. Teste de Wald da curva combinada: a afirmação inferencial sobre associação

- **Hipótese:** curva cumulativa combinada plana. São os 4 coeficientes combinados, previstos pelo `mixmeta` na média dos metapreditores (o estimando da §6), todos iguais a 0.
- **Estatística:** W = β̂′ V̂⁻¹ β̂, com β̂ e V̂ do `predict(mixmeta, newdata = média dos metapreditores, vcov = TRUE)`. W ~ χ²(4).
- **Vantagens:** é analítico e sem semente, e **não depende da MRT**. Responde diretamente à pergunta da decisão (b).
- **Reportar:** W, gl e p.
- Na simulação, com curvas heterogêneas de média combinada zero, ele rejeitou em 7% (auditor: 12%), perto do nominal.

### P2. Referência nula da AF: descritiva, sob o nulo estrito

- **Pergunta:** que AF total o pipeline inteiro produz quando **nenhuma concentração** tem associação?
- **Atenção ao que este nulo é:** é o nulo **estrito**, e não o de curva combinada plana. Com curvas heterogêneas de média zero, a AF observada passa o p97,5 do nulo estrito com frequência (35% na simulação do chat de métodos; 66% na do auditor). Por isso P2 é descritiva, e a evidência de associação combinada vem de P1.
- **Procedimento:**
  1. `set.seed(20261001, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")` uma vez antes do laço (simulação combinada; complemento, C1, item 4).
  2. Para r = 1 a 1.000: em cada concentração *i*, na ordem gravada, sortear θᵢ* ~ N(**0**, Sᵢ).
     - Sᵢ é a vcov reduzida da primeira etapa, já com a dispersão.
     - O gerador é `MASS::mvrnorm` (versão registrada no `renv.lock`).
  3. Refazer a segunda etapa como especificada: `mixmeta` com os mesmos metapreditores, a mesma sequência de estabilidade e a mesma definição de falha. Depois os BLUPs.
  4. **Falhas:** a réplica em que a sequência inteira falhar é contada e reportada, sem ser substituída nem excluída em silêncio. A distribuição é apresentada com e sem essas réplicas.
  5. Buscar a MRT BLUP de cada concentração na grade p1–p99 (regra (i) do complemento).
  6. Calcular a AF *forward* pontual (sem simulações internas), com a série completa e consecutiva.
     - Calor e frio são definidos em relação à MRT **da réplica**.
     - O RR combinado é previsto na média dos metapreditores, contra a MRT combinada da réplica.
  7. **Reportar:**
     - a AF total: mediana e p2,5 a p97,5 da distribuição nula, e se a AF observada passa o p97,5. É **a única comparação**, sem nenhum outro p;
     - como distribuições descritivas, sem p: calor, frio, RR combinados no x99 e no x1, e o número de MRT no p99 e no p1 (observado: 10 de 26 no p99).
- **O que P2 não é:**
  - Não corrige a AF: nada é subtraído.
  - Não testa associação combinada.
  - Supõe coeficientes normais com a vcov estimada, como a própria segunda etapa, e não reajusta o `gnm`. Declarar.

**Frase para o Supplementary Methods (inglês americano):**
> Post hoc analyses (not prespecified). First, we tested whether the pooled cumulative exposure–response curve, predicted at the mean of the meta-predictors, was flat, with a Wald test of its four coefficients (χ², 4 df); this test does not depend on the estimated MRT. Second, to describe the attributable fraction produced by the analytic pipeline when no urban concentration has any association, we drew first-stage reduced coefficients from multivariate normal distributions with mean zero and the estimated first-stage covariance matrices, and repeated the second-stage meta-analysis, the MRT search, and the forward attributable-fraction computation (1,000 replicates; failed replicates were counted and reported). We report the median and 2.5th–97.5th percentiles of this distribution. Because this reference assumes no association in any concentration, an observed attributable fraction above it indicates concentration-specific associations or heterogeneity, not a pooled association.

## 5. Multiplicidade

Por artigo, entram duas análises post hoc e uma única comparação inferencial nova (P1). P2 é descritiva, com uma única comparação (AF total × p97,5). Nos dois artigos, as duas ficam fora do conjunto de sensibilidades pré-especificadas (§10.2) e do critério de concordância da §9.2.

## 6. Abrangência

- **Artigo 2:** vale igual. Com menos eventos, os erros-padrão são maiores, e a AF nula tende a ser maior (no modelo de brinquedo do auditor, com 0,15 vez os eventos, a mediana sob REML foi de 2,89%, contra 1,13%).
- **Artigo 3 (PIG):** a TMR do PIG também é o mínimo da curva BLUP, então o número atribuível exploratório tem a mesma propriedade. O texto do item 2 entra adaptado. P1 e P2 ficam para decisão na vez do Artigo 3.

## 7. Literatura (busca no PubMed em 13/10/2026)

**Strings usadas:**
1. `minimum mortality temperature uncertainty bootstrap Tobias Armstrong Gasparrini` (0 resultados);
2. `attributable fraction temperature minimum mortality temperature bias overestimation simulation` (0);
3. `Tobías A[Author] AND minimum mortality temperature[Title]` (4);
4. `"attributable" AND "minimum mortality temperature" AND (uncertainty OR bias OR null)` (1);
5. `(attributable risk OR attributable fraction) AND distributed lag non-linear AND (simulation study) AND temperature AND (bias OR coverage)` (0).

**Verificada:** Tobías A, Armstrong B, Gasparrini A. Investigating uncertainty in the minimum mortality temperature: methods and application to 52 Spanish cities. *Epidemiology*. 2017;28(1):72–76. [doi:10.1097/EDE.0000000000000567](https://doi.org/10.1097/EDE.0000000000000567).
- Propõe o IC da MMT por bootstrap paramétrico aproximado.
- Pode ser citada na frase sobre a incerteza da MRT.
- Não trata do viés da AF.

**Não localizei** um artigo que descreva a positividade da AF com a MRT estimada sob efeito nulo, nem a calibração nula.
- Isso **não** quer dizer que não exista. O texto descreve a propriedade sem citação e sem afirmar novidade.
- Se um revisor pedir referência, fazer uma busca mais ampla (Web of Science e literatura de métodos) antes de citar.

## 8. Registro no log (Artigos 1 e 2)

Não é desvio, porque nenhuma análise especificada muda. Entra no log, antes de rodar:

> ### Análises post hoc ⟨n⟩ e decisão de relato — curva combinada, referência nula da AF e Abstract
> - **Data do registro:** 13/10/2026, **depois** de ver os resultados da Fase 3 (AF de 1,84%, RR combinados com IC incluindo 1, MRT no p99 em 10 de 26).
> - **Decisão de origem:** `spec/decisoes_metodo_20261013_D5_interpretacao_AF.md` (SHA-256 ⟨conferido⟩).
> - **P1:** Wald (4 gl) da curva combinada na média dos metapreditores.
> - **P2:** distribuição da AF sob o nulo estrito: 1.000 réplicas, semente combinada, falhas contadas; descritiva, com uma única comparação (AF total × p97,5).
> - **Teste novo:** a menor contribuição diária dentro do p1–p99 é ≥ −10⁻⁸ em cada concentração (mesma base na busca da MRT e na `attrdl`).
> - **Decisão de relato:** a AF fica fora da conclusão do Abstract; texto obrigatório conforme o item 2.
> - **O que não muda:** todas as análises especificadas e a AF do principal.
> - **Aprovação:** Guilherme, ⟨data⟩.

## 9. Auditoria

### 9.1 Reproduções do chat de métodos (afirmações do Artigo 1)

| Afirmação | Reprodução | Resultado |
|---|---|---|
| (1) Contribuições ≥ 0 dentro do p1–p99; AN positivo sob efeito nulo | Construção (`cen` = argmin na grade); `af_nula.py`: AF > 0 em 300 de 300 réplicas nulas | Confirmado, até a resolução da grade e com a mesma base (item 1.4) |
| (2) O eCI trata a MRT como fixa e as concentrações como independentes | `attrdl.R`, l. 159–172; `repro_aud6.py`: exclui o zero em 40 de 40 réplicas nulas | Confirmado; o efeito é grande |
| A MRT sorteada em cada simulação seria uma alternativa | Prova (item 3) e `af_nula.py` | **Rejeitado** |

### 9.2 Auditoria independente (subagente em contexto limpo; nenhum achado aceito sem reprodução)

O auditor validou o `ns` reimplementado contra uma base natural independente e reproduziu exatamente os números do `af_nula.py`. Não houve achado crítico. As decisões (a), (b) e a rejeição foram confirmadas.

| # | Grav. | Achado | Reprodução pelo chat de métodos | Correção |
|---|---|---|---|---|
| 1 | Maior | A referência nula testa o nulo **estrito**, não a curva combinada plana; a frase "larger than the null reference" contradizia (b) | `repro_aud6.py`: com média combinada zero e heterogeneidade, a AF passou o p97,5 nulo em 35%; o Wald (4 gl) da média, em 7% | P1 (Wald) como afirmação inferencial; P2 descritiva, com o nulo estrito declarado; textos reescritos |
| 2 | Maior | A ilustração do eCI usava uma única réplica | `repro_aud6.py`: 40 de 40 réplicas nulas com o eCI excluindo o zero | Item 1.3 com taxas; a soma independente nomeada como fator dominante |
| 3 | Maior | P2 estava subespecificada: falhas, onde se prevê o RR, calor e frio, gerador, multiplicidade | Releitura: confirmado | Item 4, P2, passos 2 a 7; item 5 |
| 4 | Maior | "Por construção" exige a mesma base na busca da MRT e na `attrdl` | `attrdl.R`, l. 124; demonstrado na D2 (fronteiras) | Item 1.4 e teste novo |
| 5 | Menor | "is positive" era determinístico demais | Aceito: os negativos fora do p1–p99 existem | "expected to be positive (biased upward)" |
| 6 | Menor | O "RR ≥ 1" vale só para a MRT buscada no p1–p99; os IC dos RR também são condicionais | Lógica direta, conferida | Item 1.2 e texto de Methods |
| 7 | Menor | "MRT not identified" era impreciso | Aceito | "imprecisely estimated; 95% CI spanned the entire search range" |
| 8 | Menor | O item 3 pode ser provado | Prova escrita e conferida | Item 3 |
| 9 | Menor | Limitações do `af_nula.py` (× 4, 500 sorteios, mesma μ nas 26, p97,5 de 1,84% coincidente) | Releitura do script: confirmado | Ressalvas no item 1; aviso contra comparar com o observado |
| 10 | Menor | "AF nula maior no Artigo 2" | Aceito (o auditor mostrou no modelo de brinquedo) | Mantido "tende a" |
| 11 | Menor | Faltavam as strings de busca; a mudança no Abstract é decisão de relato | Aceito | Itens 7 e 8 |

---

## 10. Scripts do chat de métodos

| Arquivo | SHA-256 | O que faz |
|---|---|---|
| `af_nula.py` | `f8ed94645a4da7a6702364890fc8a48a684c8b12150a09193597f224d2b76af4` | AF sob efeito nulo; eCI com a MRT fixa × re-sorteada (semente 20261001; ilustrativo) |
| `_ns.py` | `92f8888705ed7aea371fa2e06f9bd08078d8f3366c085120706e8bc50c6b8f01` | Reimplementação do `splines::ns` (é o `ns_boundary.py` da D2) |
| `repro_aud6.py` | `2c81312729e945571999c417f9670da7052b6a7f8099544095026fac953e4263` | Nulo estrito × média combinada zero; taxa de exclusão do zero pelo eCI |
