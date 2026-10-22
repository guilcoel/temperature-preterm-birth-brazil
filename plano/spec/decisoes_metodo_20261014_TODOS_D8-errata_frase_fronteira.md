# Decisões de método — 14/10/2026: errata da D8 (frase de fronteira e lag–resposta no p1)

**De:** chat de métodos · **Data:** 14/10/2026 · **Origem:** nota do chat do Artigo 2 (14/10)
**Âmbito:** os três artigos. O item 1 corrige uma frase comum; o item 2 é só do A2.
**Corrige:** `decisoes_metodo_20261014_A2_D8_fronteira_TMM.md`, nome antigo `decisoes_metodo_20261014_D8_respostas_A2.md` (SHA-256 com o `\n` final: `8f56abbc8f0fb68c647c6a69570c21980a2b6028f7ead655f74df2ad8bf71d70`; sem ele: `0c5bb4e7f4beaa3ebf6f5b21e4ee0004ada397271d4ea2ade8b144b8350ae5ea`).

---

## 0. SHA da D8

- **O SHA emitido é `8f56abbc…d70`.** O arquivo termina em `\n`.
- **A cópia do A2 (`0c5bb4e7…5ae5ea`)** é a mesma, sem o `\n` final. O conteúdo é idêntico, como já tinha ocorrido com a D6.
- A diferença vem do caminho de entrega ou de subida, que tira o último `\n`. Daqui em diante, o índice traz **os dois SHA de cada documento**, com e sem o `\n` final. Qualquer um dos dois confere a identidade.

---

## 1. Frase de Methods do item 1.4: opção (i), sem saída nova

**O defeito, confirmado:**
- A §7 manda "reportar os RRs também contra a mediana" e "rodar a busca entre p10 e p90".
- Ela **não** manda RR contra o mínimo buscado entre p10 e p90.
- A frase da D8 descrevia uma saída que o A1 e o A2 não produzem.

**Decisão:** opção **(i)**. A frase passa a descrever o que a §7 pré-especifica. A opção (ii) criaria uma saída *post hoc* no A1 e no A2 sem necessidade.

**Frase corrigida, A1 e A2 (inglês americano; substitui a do item 1.4 da D8):**
> When the pooled minimum-mortality temperature fell at the 1st percentile, the contrast at that percentile equals 1 by construction (conditional on the estimated MMT, whose bootstrap confidence interval is reported) and is shown without a confidence interval; the primary contrast then compares the extremes of the temperature range (99th vs 1st percentile) and cannot be lower than 1. Concentration-specific contrasts at a boundary were handled in the same way. As prespecified sensitivity analyses, relative risks against the median are also reported, together with the minimum searched between the 10th and 90th percentiles (with its bootstrap confidence interval); the handling of degenerate contrasts and of searches that again fell at a boundary (reported with a flag, without further search) was defined post hoc.

- **No A1:** "minimum-risk temperature (MRT)" e o lado da fronteira dele (a borda superior, por concentração).

**A3: a frase muda, por um motivo próprio.**
- A D7, M4(a), aprovou para o PIG, antes de qualquer resultado, colunas com o OR contra o p50 da MM9 **e** contra a MRT buscada entre p10 e p90, com bootstrap. Ali isso é saída **pré-especificada**.
- **O tratamento da busca que cai de novo na borda** (valor com marca, sem nova busca) vem da D8, 1.2(d). No A1 e no A2 ele é *post hoc*; no A3 é pré-especificado, porque a D8 saiu antes de o A3 ver qualquer resultado.
- Frase do A3:
  > …odds ratios against the median of the 9-week moving average and against the minimum searched between its 10th and 90th percentiles (with bootstrap confidence intervals) are also reported (prespecified); the handling of searches that again fell at a boundary (reported with a flag, without further search) was also prespecified.

---

## 2. Item 1.3 (lag–resposta no p1): o A2 tem razão

**As duas imprecisões da D8:**
1. Com o centro da lag–resposta no p1, **só a redução no p1** sai identicamente zero: `value = cen` zera a base centrada (`crossreduce.R`, l. 105–110). A redução no p99 usa `value = p99 ≠ cen` e **não** sai zero.
2. Com vcov nula, o `mixmeta` tende a **falhar** (a S não é positiva-definida), e não a dar Ψ singular.

**Texto corrigido do item 1.3:**
- Se a regra C3(b) não foi aplicada, a meta-análise da lag–resposta **no p1** recebe coeficientes e vcov zerados. A falha esperada é a do `mixmeta`, ou um resultado espúrio se a falha não foi capturada.
- A meta-análise **no p99** não sofre esse defeito. Mas ela fica centrada no p1, e não no p50, o que muda o estimando.
- O A2 confere o que aconteceu de fato na execução de 13/10 e registra as duas meta-análises separadamente, como propôs:
  - p1 como possível artefato;
  - p99 com o centro declarado.
- Se a C3(b) não foi aplicada, as duas são refeitas com o centro no p50, com registro.

---

## 3. Registro no log (A1, A2 e A3)

> - **Errata da D8 (14/10):** `spec/decisoes_metodo_20261014_TODOS_D8-errata_frase_fronteira.md` (SHA-256 ⟨conferido⟩).
>   - Frase de fronteira, opção (i): RR contra a mediana e o mínimo entre p10 e p90 com IC bootstrap, sem RR contra esse mínimo (A1 e A2). No A3, o OR contra o mínimo entre p10 e p90 é pré-especificado (D7, M4(a)).
>   - Item 1.3 corrigido (só o p1 é zerado; o `mixmeta` tende a falhar). **Só no A2:** situação na execução de 13/10: ⟨…⟩.

## 4. Auditoria

| Ponto | Reprodução | Resultado |
|---|---|---|
| SHA da D8 recebida | `head -c -1 D8 \| sha256sum` | `0c5bb4e7…5ae5ea`: confirmado |
| Só a redução com `value = cen` zera | `crossreduce.R` (dlnm 2.4.10), l. 105–110 | Confirmado |
| A §7 não pede RR contra o mínimo entre p10 e p90 | Leitura da §7 da v2.0.2 | Confirmado |
