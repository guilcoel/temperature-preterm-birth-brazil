# Decisões de método — 15/10/2026, D10: critério de concordância (§9.2) e coordenação do repositório

**De:** chat de métodos · **Data:** 15/10/2026 · **Origem:** consulta do chat do Artigo 1, v1.1 (15/10), seções 1 e 7, sobre a solicitação v3 do Claude Code (SHA-256 `6e5a93ac219954ae6fcd2782124fb306cc7ff072295bb33414d46d84958f2b28`)
**Âmbito:** os três artigos.
**Ler junto com:** D11 (`…_AGUDOS_D11_…`, sensibilidades dos agudos) e D12 (`…_A1_D12_…`, itens só do A1).

**Rótulos:**
- **A1 e A2:** as decisões são tomadas depois dos resultados das Fases 2 e 3 (no A1: RR combinado no x99 de 1,003, IC de 0,978 a 1,029; no x1 de 1,020, IC de 0,990 a 1,051; TMR combinada de 28,2 °C). Cada item diz se é **esclarecimento de letra** ou **escolha *post hoc***.
- **A3:** o item 1 vale como **pré-especificado** só se o log do A3 declarar, antes de registrar esta D10, que nenhum resultado da Fase 4 foi visto. Se algum tiver sido visto, valem os rótulos do A1.

---

## Resumo

| # | Pergunta | Decisão | Rótulo (A1, A2) |
|---|---|---|---|
| 1a | Contra qual TMR/TMM se avalia a sensibilidade? | **A TMR/TMM combinada da própria sensibilidade** (proposta do A1), com uma consequência a declarar | Esclarecimento de letra |
| 1b | "Mesma direção" com o IC do primário cruzando 1 | **Leitura literal** (sinal do log RR pontual), com a declaração de que, com TMR própria, a direção é ≥ 1 por construção | Esclarecimento de letra |
| 1c | x99 e x1 | **Separados:** x99 contra o IC do x99 e x1 contra o IC do x1, sem veredito único | Esclarecimento de letra |
| 1d | TMR/TMM combinada da sensibilidade na borda | **"Não avaliável"** naquele contraste, com o RR contra a mediana ao lado, como descritivo | Escolha *post hoc* (segue a D8, 1.2(b)) |
| 1e | *Fallback* numa chave | **Passo 1:** critério normal. **Passo 2:** critério reportado, com a chave marcada "confundida" | Esclarecimento de letra (D7, M7.3) |
| 7 | Um `git worktree` por artigo e um branch `comum` | **De acordo, com seis condições** (seção 2). A decisão sobre a estrutura é de Guilherme | Não é método |

---

## 1. Critério de concordância (§9.2, l. 548)

> "Um resultado é robusto se, em cada sensibilidade-chave, a estimativa tem a mesma direção e cai dentro do IC de 95% do primário."

### 1a. TMR/TMM da própria sensibilidade

- **Decisão: aprovada a proposta.** O estimando da §6 é "p99 contra a TMR combinada". Cada sensibilidade-chave refaz a análise inteira, e a estimativa comparável é o mesmo estimando refeito nela, com a TMR combinada dela.
  - Só essa leitura serve a todas as chaves. A chave 1 (`tmean_mun`) tem outra exposição e outro eixo (D2, "Abrangência"), e ali "a TMR do primário em °C" não é o mesmo ponto da distribuição.
- **O °C e o percentil da TMR de cada sensibilidade** entram na tabela do critério, ao lado do RR, para o leitor ver quanto a referência se moveu.
- **Consequência a declarar (reproduzida, seção A):** contra o mínimo da própria curva combinada, o RR no x99 e no x1 é ≥ 1 por construção (D5, 1.2), **desde que x1 e x99 sejam pontos da grade da busca**, como manda a C3(i). Sem o x99 na grade, o contraste pode ficar abaixo de 1. Daí os itens 1b e 1d.

### 1b. "Mesma direção"

- **Decisão: leitura literal**, pelo sinal do log RR pontual. Nenhuma mudança de critério.
- **Declaração obrigatória (Methods e suplemento):**
  - com a TMR própria, a estimativa de cada sensibilidade é ≥ 1 por construção, e o primário do A1 também (1,003 no x99; 1,020 no x1);
  - logo, a condição de direção é sempre satisfeita, salvo o caso exato de 1 (item 1d), e o critério se reduz, na prática, a cair no IC do primário;
  - como o IC do primário inclui 1 nos dois contrastes, o critério é **pouco informativo** neste artigo: ele detecta uma sensibilidade com efeito **maior** que o limite superior do IC, mas não distingue "robusto" de "nulo".
- **Âncora de associação:** continua sendo o P1 da D5 (Wald da curva combinada), não o critério de concordância.

### 1c. x99 e x1 separados

- **Decisão: aprovada.** O x99 (primário) é comparado ao IC do x99 do primário, e o x1 (coprimário) ao IC do x1.
- O texto reporta os dois vereditos lado a lado, sem combiná-los num "robusto" único.

### 1d. TMR combinada da sensibilidade na borda

- **Decisão: aprovada.** Se a TMR combinada da sensibilidade cair em x1 ou x99, o contraste daquele lado vale 1 por construção (D8, 1.2(b)) e fica **"não avaliável"** no critério.
  - Isso evita uma concordância trivial: o 1 sempre cai num IC que inclui 1.
  - O outro lado continua avaliável.
  - Ao lado vai o RR contra a mediana daquela sensibilidade (D8, 1.2(c)), como **descritivo**, fora do critério.
- **A alternativa (avaliar contra a busca entre p10 e p90) é rejeitada:** trocaria o estimando só nas sensibilidades em que a TMR caiu na borda.
- A borda é detectada pelo índice do mínimo na grade (C3(b)), nunca por `==` em °C.

### 1e. *Fallback* numa sensibilidade-chave

- **Decisão: aprovada.**
  - **Passo 1** (só a `arglag`, por concentração): o critério se aplica normalmente, porque a dimensão reduzida e o estimando não mudam (D7, M7.1).
  - **Passo 2** (`argvar` ns p50/p90 nas 26): o critério é reportado, mas a chave é marcada "confundida", porque passa a diferir do principal em duas coisas (D7, M7.3).
- Quando dispara, o *fallback* é registrado como desvio (D7, M7.4).

### 1f. Âmbito por artigo

| Artigo | Como aplicar |
|---|---|
| **A1** | Como acima, com "TMR" |
| **A2** | Como acima, com "TMM". **O x1 do primário já está na borda** (TMM combinada em x1; D8, 1.1): o coprimário vale 1 por construção e não tem IC. Por isso o x1 fica "não avaliável" em todas as chaves do A2, e o critério do A2 se aplica só ao x99 (que, no primário, compara x99 com x1; D8, 1.2(a)). **Declarar:** numa chave em que a TMM da sensibilidade fique no interior, o contraste dela é x99 contra essa TMM, maior ou igual ao seu próprio x99 contra x1; a comparação com o primário mistura então o deslocamento da referência com o efeito. A tabela de °C e percentil da TMM de cada chave (item 1a) mostra o deslocamento |
| **A3** | Como acima, com "OR" e a TMR na MM9. A D7, M4(a), já pré-especificou o tratamento da borda. Rótulo pré-especificado, sob a condição do cabeçalho |

### 1g. Frase para Methods (inglês americano; A1, adaptar "MRT/MMT" e "RR/OR")

> A result was considered robust if, in each key sensitivity analysis, the estimate had the same direction as the primary estimate and fell within its 95% confidence interval. Each sensitivity analysis re-estimated its own pooled minimum-risk temperature; because a contrast against the minimum of the same pooled curve cannot be lower than 1, the direction condition was always met, and the criterion reduced to inclusion in the primary confidence interval. The 99th and 1st percentile contrasts were assessed separately. A contrast was deemed not assessable when the pooled minimum-risk temperature of the sensitivity analysis fell at that percentile. These operational rules were defined after the primary results were known.

**Frase do A2:** a de cima, com "minimum-mortality temperature", e com esta oração logo antes da última:
> Because the pooled minimum-mortality temperature of the primary analysis fell at the 1st percentile, the 1st percentile contrast was not assessable in any key sensitivity analysis, and the criterion was applied to the 99th percentile contrast only.

---

## 2. Coordenação do repositório (seção 7 da consulta)

**Natureza:** é infraestrutura, não método. A decisão é de Guilherme. O chat de métodos opina só no que toca a rastreabilidade das decisões e do código compartilhado.

**Parecer: de acordo com a estrutura proposta** (um `git worktree` por artigo, cada um no seu branch; um branch `comum` aberto num único worktree; `merge --no-ff`, sem rebase; o `main` recebe merges com o ok de Guilherme). **Seis condições:**

1. **`spec/` e as decisões só entram pelo `comum`.** Nenhum branch de artigo commita em `spec/`, `codigo_compartilhado/`, `docs/`, `logs/` da raiz ou `ferramentas/`.
2. **Tags do código compartilhado só em commits do `comum`, daqui em diante.** As tags que já existem (`segunda_etapa-v1.0`, `diagnostico_grade_mrt-v1.0`) ficam onde estão, pela condição 3; a próxima, por exemplo `feriados_locais-v1.0` (D11, 3.3), já nasce no `comum`. Antes de rodar, cada artigo registra no log o SHA do commit do `comum` que incorporou por merge. É assim que se sabe quais decisões estavam em vigor.
3. **Nunca rebase, nunca `push --force`, nunca reescrever tag.** Um commit já citado num log não pode mudar de hash.
4. **Cada saída registra `git rev-parse HEAD`, o branch e o worktree** no cabeçalho do log da etapa, além do `sessionInfo()` que já se grava.
5. **Uma sessão por artigo de cada vez.** O symlink de `01_saidas/` deixa o checkout principal (scripts ≤ 54) e o worktree (scripts 60+) escreverem na mesma pasta; duas sessões simultâneas do mesmo artigo ficam proibidas.
   - Se a biblioteca do `renv` for compartilhada entre artigos, uma atualização num artigo muda os outros. Mantém-se um `renv.lock` por artigo (pendência 6 da §10.3), e toda mudança na biblioteca vira linha de log nos três.
6. **Dono do `comum`: Guilherme.** Os commits no `comum` são feitos por uma única sessão de coordenação, aberta por ele.
   - As sessões de artigo não commitam no `comum`. Quando precisam mudar algo ali, entregam o patch e a justificativa.
   - As decisões do chat de métodos entram no `comum` com os dois SHA do índice.

**Push dos commits já intercalados.** O push do `main` ou o da tag `diagnostico_grade_mrt-v1.0` publica do mesmo jeito todos os ancestrais do commit publicado, inclusive os cinco commits intercalados de outras sessões:
- Artigo 2: `4bbf0f4`, `2c926fd` e `a85c388`;
- D7: `2dbfc3e`;
- Artigo 3: `42a8ef8`;
- e, se ficarem antes do último commit do A1 a publicar, também os dois do Artigo 3 feitos depois do fecho (`0cc972f` e `dabedf2`).

Por isso, o ok de cada dono vale para qualquer um dos dois pushes. O histórico já publicado fica como está; a estrutura nova vale daqui em diante.

---

## 3. Registro no log (A1, A2 e A3; commit próprio, antes de rodar)

> - **D10 (15/10):** `spec/decisoes_metodo_20261015_TODOS_D10_concordancia_coordenacao_git.md` (SHA-256 ⟨conferido⟩).
>   - Critério de concordância: TMR/TMM própria da sensibilidade; direção literal, ≥ 1 por construção, declarada; x99 e x1 separados; contraste na borda "não avaliável", com o RR contra a mediana como descritivo; *fallback* passo 1 normal, passo 2 "confundida".
>   - **Rótulo:** ⟨A1/A2: esclarecimento de letra (1a, 1b, 1c, 1e) e escolha *post hoc* (1d), depois de ver os resultados das Fases 2 e 3 | A3: pré-especificado; nenhum resultado da Fase 4 visto⟩.
>   - **Só no A2:** x1 "não avaliável" em todas as chaves (TMM combinada do primário em x1).
>   - Coordenação do repositório: ⟨adotada / não adotada⟩ por Guilherme em ⟨data⟩.

---

## A. Auditoria

### A.1 Autoauditoria (reprodução própria)

| Ponto | Reprodução | Resultado |
|---|---|---|
| Contraste contra o mínimo da própria curva é ≥ 1 | `repro_d10_d12.py`, item 2: 10.000 curvas arbitrárias, grade de 1.001 pontos com as duas pontas | 0 violações: confirmado |
| … mas só com x99 na grade (achado 19 do auditor) | `repro_achado19.py`: grade de 0,1 sem o ponto final | x99 abaixo do mínimo em 4.437 de 10.000: confirmado; C3(i) citada no item 1a |
| A §9.2 e a §6 definem o estimando como "p99 vs TMR combinada" | Leitura da v2.0.2, l. 418–421 e 538–548 | Confirmado |
| O x1 do A2 está na borda | D8, 1.1 (TMM combinada em x1) | Confirmado |
| Push de uma tag publica os ancestrais | `commits.txt` do pacote do A1: os cinco commits estão antes do `c7ce6a5` na mesma linha | Confirmado |

### A.2 Auditoria independente

O auditor (subagente em contexto limpo) leu a consulta, a especificação v2.0.2, as decisões D1 a D9 e os três rascunhos, e reproduziu os números com scripts próprios (`aud_logknots_dias.py`, `aud_wj_ano.py`, `aud_meta_minimo.py`, `aud_ps_lag.py`). Não achou nenhum erro crítico; achou 3 Maiores, 8 Menores e 11 Notas nos três documentos. Cada achado abaixo foi reproduzido por mim antes de ser aceito.

| Achado | Gravidade | Reprodução própria | Correção |
|---|---|---|---|
| 7. A condição 2 dava como exemplo uma tag que já existe fora do `comum`, contra a condição 3 | Menor | `tag_diagnostico.txt`: a tag está no `c7ce6a5`, na linha do `main` | "Daqui em diante"; as tags existentes ficam onde estão; o exemplo virou `feriados_locais-v1.0` |
| 8. Faltavam `0cc972f` e `dabedf2`; "e não só do `main`" sugeria diferença entre os dois pushes | Menor | Consulta, §7: os dois commits do A3 depois do fecho | Os dois incluídos, condicionados a serem ancestrais; frase trocada |
| 9. Nomes e SHA em aberto; sem índice novo | Menor | Leitura | Índice, revisão 4, com os dois SHA de D10, D11 e D12 e os SHA dos scripts |
| 19. O "≥ 1 por construção" exige x1 e x99 na grade | Nota | `repro_achado19.py`: sem o x99 na grade, 4.437 violações em 10.000 (auditor: 4.796) | C3(i) citada no item 1a |
| 20. No A2, o contraste de uma chave com TMM interior mistura deslocamento de referência e efeito; faltava a frase do A2 | Nota | Por construção: f(x99) − f(TMM) ≥ f(x99) − f(x1) quando a TMM é o mínimo | Linha no item 1f e frase do A2 no 1g |

| Script | SHA-256 |
|---|---|
| `repro_d10_d12.py` (chat de métodos) | `2f824b94a7842e6c5b8b557fccfdd2ee5830f7ab15492c8fc09247a92ab5a204` |
| `wj_ano_proprio.py` (chat de métodos) | `9e2436e7b13254eb905c6b340c1375fc144e1951fff109d37b76a019915cd784` |
| `repro_achado19.py` (chat de métodos) | `e0592eb8e4f19a747b923dd5c78322b6290c6eac8fd28a83051500fdfde828f5` |
| `aud_logknots_dias.py` (auditor) | `922e674ad6e84c6784a1c9bd8f708bb5555e245d544eb684dee19391e3425eaf` |
| `aud_meta_minimo.py` (auditor) | `e9c9caf136500bbc037a18b3a7db203a8ec7947694d50cdf9a3224eebb93b740` |
| `aud_ps_lag.py` (auditor) | `1b98ad9f4bddc5b464a51cf598908ff6702d0ac7a23fb3190e8e4a19a543d9cf` |
| `aud_wj_ano.py` (auditor) | `e415c382052d2d4f1ec4ffbd0bb52b76d21e7d6a95c29ee2887923b212fdab45` |

Fontes de código consultadas (SHA-256): `smooth.construct.cb.smooth.spec.R` (dlnm 2.4.10) `b30e84b3…c2a6`; `getvcov.R` (dlnm 2.4.10) `405c5683…978b`; `smooth.r` (mgcv 1.9-4) `d035ade8…5d4d`; `mgcv.r` (mgcv 1.9-4) `f2c782d2…120`; `gam.Rd` (mgcv 1.9-4) `f6594671…ba7c`.

**O que não foi verificado:** não há R neste ambiente; nada foi executado em R. As afirmações sobre código vêm da leitura das fontes e de emulação em Python. A versão do `mgcv` na Forja é conferida na Parte 0.
