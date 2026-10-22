# Decisões de método — 15/10/2026, D13: esclarecimentos da D10 e da D11 (nota do Artigo 2)

**De:** chat de métodos · **Data:** 15/10/2026 · **Origem:** nota do chat do Artigo 2 (15/10), que não bloqueia, sobre a D10 (`d1863f5f…eb9f`), a D11 (`c7a1f8c9…6812`) e o índice rev. 4 (`95e6eb6a…f8ac`)
**Âmbito:** Artigos 1 e 2. Os itens 1, 2, 4 e 5 são do A2. O item 3 vale também para o A1.
**Natureza:** esclarecimentos. Nenhum modelo novo; uma saída descritiva nova (item 2, *post hoc*).
**Rótulo:** os mesmos da D10 e da D11, salvo onde o item diz outro.

---

## Resumo

| # | Pergunta do A2 | Resposta |
|---|---|---|
| 1 | A D11, 5.1, cria sensibilidades de lag novas no A2? | **Não.** Confirmado: o A2 roda só o 0–14 |
| 2 | Chave do A2 com TMM em x99; x1 contra TMM interior | **Aprovado**, com uma linha descritiva a mais (o RR x99 × x1 de cada chave) e a declaração de que TMM em x99 dá x99 × x1 ≤ 1 por construção |
| 3 | TMM da uma etapa na borda | **Em parte:** D8, 1.2(a) e (b), com o RR contra a mediana como descritivo; **sem** a busca entre p10 e p90, como na D10, 1d, e na D11, item 6 |
| 4 | Offset do A2 na S3 e na uma etapa | **Confirmado:** `log Σ_j Z_tj·w_j^PD`, escrito por extenso. Com γ = 1, as duas leituras são idênticas |
| 5 | "Declaração obrigatória" da D10, 1b, com os números do A2 | **Registrado.** Está correto |

---

## 1. Lags (D11, 5.1): a D11 só fixa a forma

- **Confirmado.** A D11, 5.1, fixa a `arglag` (`logknots(L, 2)`, 4 gl) dos lags que **cada artigo já tem** na §10.2. Ela não cria sensibilidades.
- **No A2:** só o 0–14 (§1.4 e §10.2, linha "Cross-basis"), com `logknots(14, 2)` (nós 1,237 e 4,162).
- **No A1:** 0–4, 0–14 e 0–21.

## 2. Critério de concordância no A2 (D10, 1d e 1f)

**Aprovada a proposta do A2:**
- **Chave com TMM combinada em x99:**
  - o x99 vale 1 por construção, e o x1 já é "não avaliável" no A2 (D10, 1f);
  - a chave é reportada como **"nenhum contraste avaliável"**, com o RR contra a mediana dela como descritivo (D8, 1.2(c)).
- **Chave com TMM interior:** o x1 contra essa TMM é só descritivo, porque não tem par no primário. O x1 do primário vale 1 por construção.

**Acréscimo descritivo (*post hoc*):** em toda chave do A2, reportar também o **RR x99 × x1** daquela chave, com IC.
- **Por quê:** no A2, o primário é, de fato, x99 × x1 (TMM em x1; D8, 1.2(a)). O RR x99 × x1 da chave compara o mesmo par de percentis, sem o deslocamento da referência apontado na D10, 1f.
- **Desigualdade (reproduzida, `repro_d13.py`):** o x99 contra a TMM da chave é sempre ≥ ao x99 × x1 da chave, por construção, **desde que o x1 seja ponto da grade** (C3(i)). Sem o x1 na grade, a desigualdade falha (`repro_d13_achados.py`: 6.525 violações em 20.000).
- **Como calcular:** contraste de dois percentis fixos, sem TMM. `crosspred` da curva combinada da chave no x99, com `cen` = °C do x1 do eixo da chave (na chave 1, o eixo próprio; D2), e IC de Wald pela vcov do `mixmeta`, sem bootstrap. Quando a TMM da chave estiver em x1, ele é idêntico ao contraste do critério, e a tabela diz isso.
- **Fica fora do critério**, que não muda depois de ver o primário. Entra na tabela do suplemento, ao lado do veredito.

**TMM da chave em x99: discordância por construção, a declarar.**
- Com a TMM em x99, a curva da chave tem o mínimo no x99. Então o x99 × x1 dela é **≤ 1 por construção**, na direção oposta à do primário do A2 (x99 × x1 ≥ 1 por construção). Reproduzido: 8.599 de 8.599 curvas com TMM em x99 (`repro_d13_achados.py`).
- O rótulo "nenhum contraste avaliável" vale para o critério formal. **Ao lado, o texto declara a discordância qualitativa:** a chave inverteu a forma da curva. Isso não fica escondido atrás do "não avaliável".
- **Oração para a frase do A2 da D10, 1g** (acrescentar depois da oração do x1):
  > A key sensitivity analysis whose pooled minimum-mortality temperature fell at the 99th percentile was reported as having no assessable contrast, and as qualitatively discordant, because its 99th versus 1st percentile contrast is then below 1 by construction.

## 3. TMM/TMR da uma etapa na borda (D11, 5.3): D8, 1.2(a) e (b), sem busca extra

**Resposta: em parte.** A proposta do A2 era aplicar a D8, item 1, inteira. Aplica-se só uma parte, nos dois artigos:
- **(a) Leitura do lado:** se a TMM da uma etapa estiver em x1, o x99 contra ela é x99 × x1, ≥ 1 por construção. Se estiver em x99, o degenerado é o próprio x99.
- **(b) Contraste na borda:** vale "1 por construção", sem IC e sem P, condicional à TMM estimada, com remissão ao IC bootstrap da TMM (D11, 5.3). Isso também evita reportar um IC degenerado: a vcov com a TMM fixa daria variância 0 nesse ponto.
- **RR contra a mediana:** reportado como **descritivo**, como na D10, 1d.
- **Sem a busca entre p10 e p90 (D8, 1.2(c)) e, portanto, sem o (d):**
  - a D8, 1.2(c), estende a busca à combinada **do primário**, pela linha "TMR" da §10.2;
  - na uma etapa, que é sensibilidade e não chave, seria uma sensibilidade dentro de outra;
  - a D10, 1d, já rejeitou essa busca nas chaves na borda, e a D11, item 6, adotou "sem busca extra" na estação quente. A uma etapa segue a mesma regra.
- **Detecção:** pelo índice do mínimo na grade (C3(b)).
- **Rótulos:** (a) é interpretação; (b) e o RR descritivo são *post hoc* no A1 e no A2.

## 4. Offset do A2 na S3 e na uma etapa (D11, 5.2 e 5.3)

- **Confirmado.** No A2, o offset é o do principal, escrito por extenso: **`offset(log Σ_j Z_tj·w_j^PD)`**, com j = 22…42 e o w_j por pessoa-dia (D6, 1.2, item 1).
  - Na uma etapa: `log Σ_j Z_ctj·w_j^PD` por concentração c, com o mesmo w_j^PD agrupado.
- **Não há ambiguidade de conteúdo:**
  - com γ = 1, log Z_t + log W_t = log Z_t + log(Σ_j Z_tj·w_j / Z_t) = log Σ_j Z_tj·w_j;
  - as duas leituras dão o mesmo offset (reproduzido: diferença máxima de 1,3 × 10⁻¹⁵).
  - A forma por extenso fica como a canônica no código do A2, porque evita calcular W_t à parte.
- **A identidade exige o mesmo conjunto de semanas** (j = 22…42) em Z_t e em W_t. Com conjuntos diferentes, a diferença deixa de ser constante (`repro_d13_achados.py`: DP de 0,082 com Z_t em 22–36). Uma mudança dos pesos por uma constante só desloca o offset por uma constante, absorvida pelos estratos.
- **Correção de letra da D11, no A2:**
  - 5.2 e 5.3: onde se lê "`offset(log Z_t)` […] no A2, γ = 1 dentro do offset" e "offset `log Z_ct`; […] no A2, γ = 1 dentro do offset", leia-se `offset(log Σ_j Z_tj·w_j^PD)` (por concentração c na uma etapa);
  - 3.2: "o offset não muda: Z_t e W_t dos outros dias continuam os do principal" vale, no A2, como "o offset dos outros dias continua o do principal";
  - registro da D11: as linhas da S3 e da uma etapa leem-se com o offset por extenso.
- **A1:** nada muda. O A1 segue com log Z_t + γ·log W_t, γ estimado e w_j por gestação (D6, 1.5).

## 5. "Declaração obrigatória" da D10, 1b, no A2

- **Registrado e correto.** Os números da D10, 1b, são do A1.
- **No A2:**
  - a declaração usa os números do A2;
  - a frase de que, com TMM própria, a direção é ≥ 1 por construção vale sempre;
  - a conclusão "pouco informativo" só entra se o IC do x99 × x1 do primário do A2 incluir 1. Como o A2 já viu esse resultado, o log diz qual ramo vale;
  - a declaração mantém a ressalva da D10, 1f, sobre o deslocamento da referência nas chaves com TMM interior.

---

## Registro no log do A2 (commit próprio, antes de rodar)

> - **D13 (15/10):** `spec/decisoes_metodo_20261015_AGUDOS_D13_esclarecimentos_D10-D11_nota_A2.md` (SHA-256 ⟨conferido⟩).
>   - Lag: só 0–14, `logknots(14, 2)`.
>   - Critério: chave com TMM em x99 = "nenhum contraste avaliável" e discordância qualitativa declarada (x99 × x1 ≤ 1 por construção); RR contra a mediana descritivo; x1 contra TMM interior descritivo; RR x99 × x1 de cada chave (Wald, `cen` = x1 da chave) como descritivo (*post hoc*).
>   - Uma etapa na borda: D8, 1.2(a) e (b), RR contra a mediana descritivo, sem busca entre p10 e p90 (*post hoc*).
>   - Offset da S3 e da uma etapa: `log Σ_j Z_tj·w_j^PD`.
>   - Declaração da D10, 1b, com os números do A2; ramo de "pouco informativo": ⟨vale / não vale⟩.

**No log do A1:** uma linha remetendo ao item 3 (uma etapa na borda: D8, 1.2(a) e (b), RR contra a mediana descritivo, sem busca entre p10 e p90; *post hoc*).

---

## A. Auditoria

### A.1 Autoauditoria (reprodução própria)

| Ponto | Reprodução | Resultado |
|---|---|---|
| log Z_t + log W_t = log Σ_j Z_tj·w_j com γ = 1 | `repro_d13.py`, item 4: 1.000 dias × 21 semanas, Z e w aleatórios | Diferença máxima de 1,3 × 10⁻¹⁵: confirmado |
| Com TMM interior, x99 contra a TMM ≥ x99 × x1 | `repro_d13.py`, item 2: 10.000 curvas, 2.418 com TMM interior, x1 na grade | 2.418 de 2.418: confirmado |
| O offset principal do A2 é por pessoa-dia | D6, 1.2, item 1 (l. 55) | Confirmado |
| A §10.2 do A2 tem só o 0–14 | Linha "Cross-basis" da §10.2 da v2.0.2 | Confirmado |

### A.2 Auditoria independente

O auditor (subagente em contexto limpo, script próprio `aud_d13.py`) não achou nenhum erro crítico; achou 2 Maiores, 3 Menores e 5 Notas. Cada achado foi reproduzido por mim antes de ser aceito.

| Achado | Gravidade | Reprodução própria | Correção |
|---|---|---|---|
| 1. Na uma etapa, a busca entre p10 e p90 seria *post hoc* (não pré-especificada) e contradiria a D10, 1d, e a D11, item 6 | Maior | D8, 1.2(c): a extensão é à combinada do primário pela §10.2; D10, 1d, rejeita a busca nas chaves; D11, 6: "sem busca extra" | Item 3 refeito: só (a) e (b), RR contra a mediana descritivo, sem busca |
| 2. TMM da chave em x99 dá x99 × x1 ≤ 1 por construção; "não avaliável" esconderia a discordância | Maior | `repro_d13_achados.py`: 8.599 de 8.599 curvas | Discordância qualitativa declarada; oração para a frase do A2 |
| 3. A desigualdade do item 2 exige o x1 na grade (C3(i)) | Menor | `repro_d13_achados.py`: sem o x1 na grade, 6.525 violações em 20.000 | Condição escrita |
| 4. Faltava dizer como se calcula o IC do x99 × x1 | Menor | Contraste de dois percentis fixos: Wald pela vcov do `mixmeta` | `crosspred` com `cen` = x1 da chave, sem bootstrap |
| 5. A correção de letra da D11 só citava a 5.2 | Menor | D11, 3.2, 5.3 e registro: confirmados | Correção estendida |
| 6. A identidade exige o mesmo j em Z_t e W_t | Nota | `repro_d13_achados.py`: com Z_t em 22–36, DP de 0,082 | Condição escrita |
| 7. "Nenhuma análise nova" contrariava a saída descritiva nova | Nota | Leitura | Cabeçalho corrigido |
| 8. O A2 já viu o primário; o ramo de "pouco informativo" deve ser dito | Nota | Leitura | O log do A2 diz qual ramo vale; ressalva da D10, 1f, mantida |
| 9. Índice sem a D13; marcador ⟨AUDIT⟩ | Nota | Leitura | Índice, revisão 5 |
| 10. Efeito no A1: só o item 3 | Nota | D6, 1.5: o A1 segue com γ estimado e w_j por gestação | Linha do log do A1 com o rótulo corrigido; nota no item 4 |

| Script | SHA-256 |
|---|---|
| `repro_d13.py` | `16a8e8e5db3fee41bff60b4a807bb02ac1db36f9f676d2d8f7dda5a15cef4da6` |
| `repro_d13_achados.py` | `3d49a552de619697ce545af6c1b7c6cf4465efa0a9294df64e8f0d57dc9cc647` |
| `aud_d13.py` (auditor) | `e6f7e13963e59904b99c1f75213f32f157b1b425dd061706021e270e0949b48a` |

**Não verificado:** não há R neste ambiente; nada foi executado em R. Os números do A2 nos dados reais não foram vistos aqui.
