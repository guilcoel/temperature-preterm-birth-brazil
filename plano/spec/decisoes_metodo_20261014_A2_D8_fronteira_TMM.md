# Decisões de método — 14/10/2026, D8: respostas ao Artigo 2 (contraste degenerado, D5 no A2, letra da D6)

**De:** chat de métodos · **Data:** 14/10/2026 · **Origem:** pedido do chat do Artigo 2 (14/10)
**Rótulo:** os itens 1 e 2 respondem a pontos *post hoc*, porque as estimativas do A2 já foram vistas por Guilherme e pelo executor (desvios 97 a 102). O item 3 não é *post hoc*.
**Âmbito:** Artigo 2. O item 1 vale igual para os Artigos 1 e 3 (regra única de fronteira).

---

## 0. Conferência de documentos (encerrada)

| Documento | SHA-256 emitido |
|---|---|
| D5, `decisoes_metodo_20261013_D5_interpretacao_AF.md` | `24f131e8b3cb45f05efcaa8b59ba97bbaaec5f50f106939a16836b3fd66f668a` |
| Errata da D5, `decisoes_metodo_20261014_errata_D5.md` | `ea483f464050fedcf5cd878e11948810727134655168ba433616fd43d58e334b` |
| D6, `decisoes_metodo_20261013_D6_respostas_A2.md` | `e456ad6785f25a102ca940cdd5bfab028eed701678c712d44f6c478d5451ddc5` |
| D7, `decisoes_metodo_20261013_D7_respostas_A3.md` | `10c4e9928ba5d9c0d6cc3755f310d64087ac8e41834571c6ad4803d4d47899eb` |

- **A D6 "como recebida" pelo A2** (`a324204a…7669`) é a emitida **sem o `\n` final**. Removido esse byte, o SHA bate exatamente; conferido.
- **O conteúdo é idêntico.** O registro do A2 cita os dois SHA e a causa da diferença.

---

## 1. Contraste degenerado com a TMM na fronteira (*post hoc* no A2; regra única para os três artigos)

### 1.1 Leitura, separando os dois lados

- **Curva combinada, TMM em x1 (borda inferior; caso do A2):**
  - o coprimário x1 contra a TMM vale 1 por construção, com EP 0, **com a TMM fixa**;
  - o primário passa a ser x99 contra x1: compara os extremos da faixa, não o calor contra uma temperatura ótima central;
  - como x1 é o mínimo, o primário também **nunca fica abaixo de 1** por construção (D5, item 1.2).
- **Curva combinada, TMM em x99 (borda superior):** o degenerado é o próprio primário, x99 contra a TMM. Hoje isso não ocorre em nenhuma combinada.
- **Por concentração:** os contrastes são descritivos (§9.2). Na borda superior, o x99 contra a TMM vale 1 (é o caso do A1, em 10 de 26); na inferior, o x1 contra a TMM vale 1.
- **O "1" é condicional à TMM estimada.** A incerteza da TMM fica no IC bootstrap da TMM, que é pré-especificado (§7; §9.1, item 8) e é reportado.
- **Ψ numericamente singular e as fronteiras por concentração:**
  - Ψ singular não é Ψ = 0, e com metapreditores o BLUP não tende à curva combinada. Quando Ψ → 0, ele tende ao valor ajustado da meta-regressão, X_iβ̂ (média e amplitude da temperatura, §6).
  - Com Ψ singular, os BLUPs ficam presos numa família de poucos parâmetros. Por isso **as 21 fronteiras por concentração dependem entre si** e não são 21 evidências independentes. Declarar.

### 1.2 Decisão (regra única para A1, A2 e A3)

| # | Proposta do A2 | Decisão | Rótulo e origem |
|---|---|---|---|
| (a) | O primário fica como pré-especificado e o texto declara a equivalência | **Aprovado,** com o lado explicitado: com a TMM combinada em x1, o primário é x99 contra x1, mede os extremos e é ≥ 1 por construção | Interpretação da §6, sem mudança de análise |
| (b) | Contraste degenerado reportado como "1 por construção", sem IC e sem P; nada é promovido | **Aprovado.** O texto diz que o "1" é condicional à TMM estimada e remete ao IC bootstrap da TMM. É a mesma regra da D7, M4(a) | **Post hoc** no A2 e no A1; pré-especificado no A3 (que não viu resultados) |
| (c) | Regra de fronteira também na combinada: RR contra a mediana e busca entre p10 e p90 | **Aprovado,** como **sensibilidade pré-especificada**: a §10.2 lista "TMR: busca entre p10 e p90; RR contra a mediana" sem restringir à concentração. A §7 traz a mesma regra, condicional, para a concentração. A busca entre p10 e p90 tem bootstrap (§7; D7, M4(a)) | **Pré-especificado** (§10.2; prompts da Fase 3 do A2) |
| (d) | Busca entre p10 e p90 também na borda: valor com marca, sem nova busca | **Aprovado,** sem buscas em cascata | **Post hoc** (lacuna da especificação) |

**Relato:**
- Em Results, ao lado do primário, entra o RR em x99 contra a mediana. É uma **sensibilidade** pré-especificada (§10.2), mostrada para dar um contraste de calor contra uma referência central.
- O **P1 da D5** (Wald da curva combinada, independente da TMM) é a âncora inferencial sobre associação. Com Ψ na fronteira do REML, a V̂ pode estar subestimada e o teste, anticonservador; declarar.

### 1.3 Lag–resposta combinada com a TMM em x1: conferir a regra C3(b)

- A C3(b) do complemento manda: "se a TMR combinada cair em x1 ou x99, o centro passa ao p50" de cada concentração, **nos dois lados**.
- **Se o código não aplicou a regra,** o centro da lag–resposta no p1 coincide com o próprio p1 nas 26 concentrações. A redução sai com coeficientes e vcov iguais a zero, e a "Ψ singular" das duas meta-análises da lag–resposta seria artefato.
- **O A2 confere no código e no log da execução de 13/10** se a regra foi aplicada.
  - Se não foi: é defeito de implementação contra a C3(b). A lag–resposta é refeita com o centro no p50 e a troca de estimando declarada (RR(x × p50) por lag), com registro.
  - O teste do complemento (`max(abs(coef)) > 1e-10` antes do `mixmeta`) teria de ter falhado; informar.

### 1.4 Frase para Methods (inglês americano)

> When the pooled minimum-mortality temperature fell at the 1st percentile, the contrast at that percentile equals 1 by construction (conditional on the estimated MMT, whose bootstrap confidence interval is reported) and is shown without a confidence interval; the primary contrast then compares the extremes of the temperature range (99th vs 1st percentile) and cannot be lower than 1. Concentration-specific contrasts at a boundary were handled in the same way. As prespecified sensitivity analyses, relative risks against the median and the minimum searched between the 10th and 90th percentiles (with bootstrap confidence intervals) are also reported; the handling of degenerate contrasts and of searches that again fell at a boundary (reported with a flag, without further search) was defined post hoc.

**Adaptações:**
- **A1:** "minimum-risk temperature"; o caso é a borda **superior** em 10 de 26 concentrações (o x99 contra a TMR delas vale 1). A combinada só entra se cair na borda.
- **A3:** já coberto pela D7, M4(a), com o rótulo de pré-especificado.

### 1.5 Registro no log do A2

> ### Desvio ⟨n⟩ — contraste degenerado com a TMM na fronteira (D8, item 1)
> - **Rótulo:** *post hoc* (estimativas vistas em 13/10, desvios 97–102), salvo (c), pré-especificado (§10.2 e prompts da Fase 3).
> - **Decisão de origem:** `spec/decisoes_metodo_20261014_D8_respostas_A2.md` (SHA-256 ⟨conferido⟩).
> - **(a)** O primário como pré-especificado: com a TMM combinada em x1, equivale a x99 contra x1, mede os extremos e é ≥ 1 por construção.
> - **(b)** O degenerado sai como "1 por construção, condicional à TMM", sem IC e sem P; o IC bootstrap da TMM é reportado.
> - **(c)** RR contra a mediana e busca entre p10 e p90 (com bootstrap) também na combinada, como sensibilidades.
> - **(d)** Busca na borda: valor com marca, sem nova busca.
> - **C3(b) na lag–resposta:** ⟨aplicada / não aplicada, com a correção⟩.
> - Ψ singular e dependência entre as fronteiras declaradas; P1 como âncora, possivelmente anticonservador.
> - Contagem das TMM por concentração: ⟨n⟩ na borda inferior e ⟨n⟩ na superior.
> - **Toca o contraste primário?** Só no relato; o estimando não muda.
> - **Aprovação:** Guilherme, ⟨data⟩.

**A1 e A3:** uma linha remetendo a este item, com o rótulo próprio de cada um.

---

## 2. D5 no Artigo 2

- **Nome e SHA:** é a `decisoes_metodo_20261013_D5_interpretacao_AF.md` (`24f131e8…668a`), a mesma que a D6 cita, junto com a **errata de 14/10** (`ea483f46…334b`).
- **Alcance:** valem para o A2. **P1 e P2 são *post hoc* no A2.** As frases são escritas com os números do próprio A2 (errata, item 6), com MMT.
- **Direção da `attrdl`:** a da D1. Principal *forward* com BLUPs, *backward* com os coeficientes da 1ª etapa como sensibilidade, e a ponte. Declarar no A2.
  - A não negatividade dentro do p1–p99 vale só no *forward* com BLUPs.

### 2.1 Componentes com a TMM na borda: o que a D5 não cobria

- **Os componentes usam a TMM BLUP de cada concentração** (`cen`, C3(g)), e não a combinada.
  - O frio fica "quase vazio" só onde a TMM **da própria concentração** caiu no p1.
  - Nas concentrações com a TMM na borda superior, o frio contém quase todos os dias, e o calor fica só com os dias acima do p99.
  - O frio agregado nas 26 é, portanto, uma mistura.
- **Numa concentração com a TMM no p1:**
  - o frio, `c(-Inf, TMM)`, contém só os dias abaixo do p1;
  - como a curva sobe a partir do p1, nesses dias ela tende a ficar abaixo da referência, e as contribuições **tendem a ser negativas**;
  - o frio extremo, `c(-Inf, min(p2,5, TMM))`, **coincide** com o frio, porque min(p2,5, p1) = p1.
- **Simetricamente,** numa concentração com a TMM no p99, o calor e o calor extremo contêm só os dias acima do p99.

**Decisão:**
- Os componentes são reportados como saírem.
- O suplemento traz, por concentração, a marca de borda da TMM e o número de dias de cada componente.
- No agregado, informar quantas concentrações estão em cada borda.
- A Discussion não interpreta como efeito do frio (ou do calor) um componente formado só por dias além do percentil da borda.

**Frase para Methods ou Results (inglês americano):**
> Attributable components were computed against each concentration's own MMT. Where that MMT was at the 1st (99th) percentile, the cold (heat) and extreme-cold (extreme-heat) components coincided and contained by construction only days beyond that percentile, with contributions that tend to be negative; they are not interpretable as cold (heat) effects. The number of concentrations at each boundary is reported.

---

## 3. Letra da D6, item 1.2.2: o A2 tem razão

- **O erro:** "w_j^PD / w_j^g = 7/(7 − 3h_j)" está errado por um fator 7. O w_j^PD é por gestação-dia e o w_j^g é por gestação; a razão é N_j/PD_j = 1/(7 − 3h_j).
- **Correção:** o teste fica **"7·w_j^PD / w_j^g = 7/(7 − 3h_j)"**, igual ao fator do item 1.1 (7N_j/PD_j), que estava certo. O A2 já implementa assim.
- **Reproduzido** com aritmética exata (`fractions.Fraction`), em três casos meus e quatro do auditor. O erro foi de redação da D6 e não muda análise nenhuma.

---

## 4. Auditoria

| Ponto | Reprodução | Resultado |
|---|---|---|
| Item 3: razão dos pesos | `fractions.Fraction` | 1/(7 − 3h) e 7/(7 − 3h): confirmado |
| Item 0: SHA da D6 recebida | `head -c -1 D6 \| sha256sum` | `a324204a…7669`: é a D6 sem o `\n` final |
| Item 1.3: regra do centro na fronteira | Complemento, C3(b) (linha da tabela) | A regra existe; falta conferir se foi aplicada |

### Auditoria independente (subagente em contexto limpo; nenhum achado aceito sem reprodução)

| # | Grav. | Achado | Reprodução pelo chat de métodos | Correção |
|---|---|---|---|---|
| 1 | Crítico | Os componentes usam a TMM de cada concentração, não a combinada | C3(g) e D1: `cen` = TMR BLUP da concentração | Item 2.1 reescrito; marca e contagem por concentração |
| 2 | Maior | Ψ singular não leva o BLUP à curva combinada, e sim a X_iβ̂ | Teoria do BLUP com metapreditores (§6) | Item 1.1 reescrito |
| 3 | Maior | A frase de Methods não separava os lados | Releitura (§9.2: o primário é só da combinada) | Itens 1.1 e 1.4 |
| 4 | Maior | Faltavam o bootstrap da TMM e o "≥ 1 por construção" do primário | §7; §9.1, item 8; D5, item 1.2 | Itens 1.1, 1.2(b) e 1.4 |
| 5 | Maior | Lag–resposta degenerada no p1 se a C3(b) não foi aplicada | C3(b) existe no complemento; conferido | Item 1.3: conferência e correção condicional |
| 6 | Maior | O frio abaixo do p1 tende a ser negativo, e o frio extremo coincide com o frio | min(p2,5, p1) = p1; a curva sobe a partir do p1 | Item 2.1 |
| 7 | Menor | A direção da `attrdl` não estava declarada | D1 | Item 2 |
| 8 | Menor | A origem e o rótulo de (c) estavam errados | §10.2: é sensibilidade | Item 1.2(c) |
| 9 | Menor | A frase de Methods marcava só (d) como *post hoc* | Releitura | Item 1.4 |
| 10 | Menor | P1 como âncora, possivelmente anticonservador | Aceito | Item 1.2 |
| 11 | Menor | A hipótese de CRLF estava errada | `head -c -1`: confirmado | Item 0 encerrado |
