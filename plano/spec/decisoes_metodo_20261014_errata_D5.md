# Decisões de método — 14/10/2026: errata da D5 (contribuições negativas dentro do p1–p99) e texto final com os resultados post hoc do Artigo 1

**De:** chat de métodos · **Data:** 14/10/2026 · **Origem:** nota do chat do Artigo 1 (14/10), com dados da Fase 3D
**Âmbito:** Artigos 1 e 2. **Nenhuma análise muda**, salvo se a verificação do item 2 achar um defeito de código.
**Corrige:** `decisoes_metodo_20261013_D5_interpretacao_AF.md`, itens 1.1, 1.2, 1.4, 2, 8 e 9. Entra como arquivo novo em `spec/`.

---

## 1. O erro na D5

- A D5 dizia que os negativos dentro do p1–p99 "ficam na ordem de 10⁻⁹" (item 1.1) e fixava um teste com limiar de −10⁻⁸ (item 1.4). Os dois vinham da simulação do auditor, não dos dados. **O erro de especificação é da D5.**
- **Nos dados do A1:**
  - o menor log RR diário contra a MRT dentro do p1–p99 é de −4,15 × 10⁻⁵, abaixo de −10⁻⁸ em 15 de 26 concentrações;
  - no AN, os negativos somam −0,034 evento dentro do p1–p99 (0,00013% do AN de 25.362) e −38,70 fora dessa faixa (0,15%).
- **A pré-condição do item 1.4 está verificada:** a busca da MRT e a `attrdl` usam a mesma base, com diferença 0 nas 26 concentrações.

## 2. A causa: duas possíveis, a identificar antes de fechar o texto (bloqueia só a frase de Methods)

| Causa | Mecanismo | Tamanho | Como distinguir |
|---|---|---|---|
| **(a) Resolução da grade** | Entre dois pontos da grade, a curva desce abaixo do mínimo da grade | No máximo (máx f″ na célula)·h²/8, com h = 0,1 °C | O dia de menor contribuição fica numa célula vizinha da MRT, com os dois extremos na grade |
| **(b) p1 ou p99 fora da grade** | Se a grade for `seq(p1, p99, 0.1)` sem o p99, a última célula parcial fica sem o extremo. Com a MRT no p99 (10 de 26 concentrações), a curva continua descendo e gera descida de **1ª ordem**, f′·δ | Exemplo: p1 = 14,37, p99 = 31,82, δ = 0,05 °C, f′ = −0,003 dá −1,5 × 10⁻⁴ | O dia de menor contribuição fica entre o último ponto do `seq` e o p99 |

**Reproduzido** (`grade_mrt.py`):
- (a) A razão entre a descida e f″·h²/8 teve máximo de 0,9999 em 20.000 curvas quadráticas. O auditor mostrou que, em splines com nó dentro da célula, o limite vale com o **máximo** de f″ na célula (razão de 0,955), e não com o f″ num ponto (razão de até 1,46).
- (b) No exemplo acima, sem o p99 na grade, a descida foi de −1,50 × 10⁻⁴. Com o p99 incluído pela regra C3(i) do complemento, foi 0.

**O que o A1 confere e informa (só leitura, sem rodar análise):**
1. Se a grade da MRT segue a C3(i), com p1 e p99 incluídos. Verificar no código e numa concentração com `(p99 − p1)/0,1` não inteiro.
2. Em cada uma das 15 concentrações com negativos, onde fica o dia de menor contribuição: na célula da MRT ou vizinha (causa a) ou na última célula parcial (causa b). Informar também o máx f″ local da curva BLUP nessa célula.

**Desfecho:**
- **Causa (a):** vale a frase de Methods do item 4. Os −4,15 × 10⁻⁵ exigem máx f″ ≥ 0,033 por °C² na célula. É um limite inferior, que o A1 confirma com o f″ dos BLUPs; a errata não afirma que é "plausível".
- **Causa (b):** é defeito de código contra a C3(i). A grade é corrigida, a MRT e o que dela depende são recalculados, e tudo é registrado como correção de implementação. Só então se fecha o texto.

## 3. Correções na D5

| Item da D5 | Texto antigo | Passa a ser |
|---|---|---|
| 1.1 | "os negativos ficam na ordem de 10⁻⁹" e "−9,5 × 10⁻⁵ contra uma AF de 3,3%" (valor simulado) | "até a resolução da grade: no máximo (máx f″ na célula)·h²/8. Nos dados do A1, o menor log RR diário contra a MRT foi −4,15 × 10⁻⁵, e os negativos somaram −0,034 evento dentro do p1–p99 e −38,70 fora (0,15% do AN)" |
| 1.2 | "os RR contra a MRT [...] são ≥ 1 por construção" | Acrescentar: "nos pontos da grade; fora deles, até a mesma resolução" |
| 1.4 e 8 (teste) | "a menor contribuição diária dentro do p1–p99 é ≥ −10⁻⁸" | **Retirado.** O teste é a igualdade das bases (já feita: diferença 0). A menor contribuição e as somas de negativos dentro e fora do p1–p99 viram diagnóstico descritivo, no suplemento |
| 2, Limitations | "Its point estimate is non-negative by construction when the reference is the estimated MRT" | "Its point estimate is biased upward when the reference is the estimated MRT" |
| 9.1 (linha 1) e 9.2 (achado 4) | "item 1.4" e "teste novo" | Remissão a esta errata |
| Escalas | "contribuição" ora em log RR, ora em 1 − e^(−u) | No suplemento: u = log RR diário contra a MRT; contribuição = (1 − e^(−u)) × eventos |

## 4. Frase de Methods (D5, item 2): aprovada com ajuste, depois da verificação do item 2

> Because the reference temperature was the minimum of each estimated exposure–response curve within the 1st–99th percentile range, daily contributions within that range are non-negative by construction, up to the 0.1 °C resolution of the MRT search grid (negative contributions within that range were negligible; Supplementary Methods), and the attributable fraction is expected to be positive (biased upward) even in the absence of an association; for the same reason, and to the same grid resolution, relative risks against the MRT are not lower than 1, and their confidence intervals, like the empirical confidence intervals of the attributable fraction, are conditional on the estimated MRT. [restante da D5, item 2, sem mudança]

- **Ajuste em relação à proposta do A1:** "and to the same grid resolution" estende a ressalva aos RR.
- **No suplemento:**
  - o menor u dentro do p1–p99;
  - as somas das contribuições negativas dentro e fora do p1–p99 (em eventos);
  - onde ocorreu o mínimo (item 2).

## 5. Frase de Limitations com os resultados post hoc do Artigo 1

- **P1, conferido:** χ²(4) com W = 1,86 dá p = 0,7615. O 0,762 informado é coerente com W entre 1,855 e 1,857.
- **Formato:** o de P segue o guia do AJOG MFM no Projeto.

> The attributable fraction should not be read as evidence of an association. Its point estimate is biased upward when the reference is the estimated MRT, and its empirical confidence interval does not incorporate the uncertainty of the MRT or the dependence between BLUPs. In this study, none of the pooled relative risks excluded the null, the pooled MRT was imprecisely estimated (its 95% CI spanned the entire search range), and the MRT fell at the 99th percentile in 10 of 26 urban concentrations. In post hoc analyses, a test of the pooled exposure–response curve did not reject a flat curve (Wald χ² = 1.86, 4 df; P = .76), and the observed attributable fraction (1.84%) did not exceed the 97.5th percentile of its distribution under no association in any urban concentration (median, 1.67%; 2.5th–97.5th percentiles, 0.83%–3.00%; [k] of 1,000 replicates failed and are reported in the Supplementary Methods).

- **[k]:** o número de réplicas de P2 com falha no `mixmeta` (D5, item 4, passo 4). Se for 0, escrever "no replicate failed".
- **A ressalva condicional da D5** ("which, if exceeded, indicates…") sai do texto do A1, porque a AF não passou o p97,5.

## 6. Artigo 2

- **Vale a mesma estrutura,** com MMT (terminologia da §7 para o óbito perinatal). As frases são escritas **com os números do próprio A2:**
  - "negligible" só se o diagnóstico do A2 mostrar isso;
  - a verificação do item 2 (p1/p99 na grade e localização do mínimo) é feita também no A2;
  - se a AF do A2 **passar** o p97,5, a frase condicional da D5 vira afirmação: "…exceeded the 97.5th percentile…, which indicates concentration-specific associations or heterogeneity rather than a pooled association";
  - a regra de fronteira da §7 é avaliada com a TMM do próprio A2.
- **Teste:** igualdade das bases. A menor contribuição fica só como diagnóstico descritivo.

## 7. Registro no log

**A1 e A2:**

> - **Errata da D5 (14/10):** `spec/decisoes_metodo_20261014_errata_D5.md` (SHA-256 ⟨conferido⟩).
>   - O teste de contribuições ≥ −10⁻⁸ foi retirado (falho; erro de especificação da D5). A igualdade das bases foi verificada: diferença 0 nas 26.
>   - Causa dos negativos dentro do p1–p99: ⟨resolução da grade (a) / p99 fora da grade (b), com correção⟩. Localização do mínimo e máx f″ local: ⟨valores⟩.
>   - Diagnóstico descritivo no suplemento; frases de Methods e Limitations conforme os itens 4 e 5.

## 8. Auditoria

| Ponto | Reprodução | Resultado |
|---|---|---|
| Descida entre pontos da grade ≤ f″·h²/8 | `grade_mrt.py` (20.000 curvas quadráticas) | Confirmado (razão máxima de 0,9999) |
| f″ implicado por −4,15 × 10⁻⁵ | 4,15 × 10⁻⁵ × 8 / 0,1² | ≥ 0,033 por °C² (limite inferior) |
| P1 | `scipy.stats.chi2.sf(1.86, 4)` | 0,7615 |
| Descida de 1ª ordem sem o p99 na grade | `grade_mrt.py` (exemplo p1 = 14,37, p99 = 31,82) | −1,50 × 10⁻⁴ sem a regra C3(i); 0 com ela |

### Auditoria independente (subagente em contexto limpo; nenhum achado aceito sem reprodução)

| # | Grav. | Achado | Reprodução pelo chat de métodos | Correção |
|---|---|---|---|---|
| 1 | Crítico | A causa não estava identificada: o p99 fora da grade daria descida de 1ª ordem nas 10 concentrações com MRT no p99 | `grade_mrt.py`: −1,5 × 10⁻⁴ sem o p99; 0 com a C3(i) | Item 2: verificação obrigatória e desfecho condicional |
| 2 | Maior | O limite usa o **máximo** de f″ na célula | Aceito, pelo resultado do auditor em splines (0,955 contra 1,46) | Itens 2 e 3 |
| 3 | Maior | O f″ de 0,033 é limite inferior; "plausível" não foi verificado | Conta refeita | Item 2 ("o A1 confirma com os BLUPs") |
| 4 | Maior | A Limitations da D5 ainda dizia "non-negative by construction" | Releitura da D5, item 2 | Item 3 e frase do item 5 |
| 5 | Maior | O parêntese não cobria os RR | Releitura | "and to the same grid resolution" (item 4) |
| 6 | Menor | A correção da D5 estava incompleta (9.1, 9.2, valor simulado, cabeçalho) | Releitura | Item 3; cabeçalho |
| 7 | Menor | Confusão entre as escalas de log RR e de contribuição | Releitura | Item 3, linha "Escalas" |
| 8 | Menor | Faltavam as falhas de P2 na frase | D5, item 4, passo 4 | "[k] of 1,000 replicates" |
| 9 | Menor | As frases do A2 não podem ser pré-escritas | Aceito | Item 6 |

| Arquivo | SHA-256 |
|---|---|
| `grade_mrt.py` | `c6308b76b4e5ee40dfdfe2f980bd32e5cb5d839772d9bf0af17752a3e828791a` |