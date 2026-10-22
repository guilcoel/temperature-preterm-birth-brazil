# Entradas para `logs/desvios_especificacao.md` — 13/10/2026

**Como usar:**
- O chat do Artigo 1 manda o Claude Code acrescentar as três entradas ao **final** do log do Artigo 1, **antes** de rodar qualquer coisa que dependa delas.
- A numeração segue o que já existe no log (⟨n⟩, ⟨n+1⟩, ⟨n+2⟩).
- Os campos ⟨…⟩ são preenchidos antes do commit.
- O log do Artigo 2 recebe as mesmas três entradas na abertura da sua Fase 2, com "Artigo: 2".
- O Artigo 3 recebe só a entrada do fim deste arquivo, quando chegar a vez dele.

**Antes do commit,** o Claude Code confere o SHA-256 de `spec/decisoes_metodo_20261013.md` contra o valor informado pelo chat de métodos. Se diferir, não há commit.

---

### Desvio ⟨n⟩ — §7: perspectiva e coeficientes da fração atribuível

- **Data do registro:** 13/10/2026, antes de rodar.
- **Artigo:** 1 (vale igual para o 2).
- **Decisão de origem:** `spec/decisoes_metodo_20261013.md`, D1 e seção 4 (SHA-256 ⟨conferido⟩).
- **Especificação (literal):** "Fração atribuível: `attrdl` *backward* [...] O MCC 2015 usou a perspectiva *forward*; declarar ao comparar." Também a §10.2 (lista fechada) e a §12, item 7.
- **Motivo:** a `attrdl` recusa a perspectiva *backward* com coeficientes reduzidos (`attrdl.R`, l. 133–134, SHA-256 ⟨do script usado⟩), e os BLUPs da §6 são reduzidos.
- **O que passa a valer:**
  - **principal:** *forward*, com os BLUPs reduzidos e os eventos da janela principal;
  - **sensibilidade:** *backward*, com todos os coeficientes da cross-basis da primeira etapa e a vcov do `gnm`; `x` com os 7 dias de aquecimento e `cases` = NA nesses dias;
  - **ponte (diagnóstico):** *forward*, com os coeficientes reduzidos da primeira etapa, sem BLUP;
  - **igual nas três:** `cen` = TMR BLUP, mesmos `range`, 1.000 simulações e `set.seed(20261001)` imediatamente antes de cada chamada;
  - **ponta da série:** no *forward*, os 7 últimos dias da janela ficam fora da AF (a `attrdl` reescala ao total); os eventos depois de 2024-08-06 não entram;
  - **lista fechada da §10.2:** entram a sensibilidade *backward* e a ponte.
- **Toca o contraste primário?** Não.
- **Resultados vistos antes do registro:** ⟨nenhum modelo de desfecho com dados reais / descrever o que rodou⟩.
- **Aprovação:** Guilherme, ⟨data⟩.

### Desvio ⟨n+1⟩ — §6: base de predição das curvas combinadas

- **Data do registro:** 13/10/2026, antes de rodar.
- **Artigo:** 1 (vale igual para o 2).
- **Decisão de origem:** `spec/decisoes_metodo_20261013.md`, D2.
- **Especificação (literal):** "a curva cumulativa geral prevista pelo `mixmeta` na média dos metapreditores, numa escala de percentis comum, que é a média dos percentis das 26 concentrações (como no MCC)".
- **Motivo:** a §6 não define a base em que os coeficientes combinados são avaliados. É uma lacuna: para o PIG, os nós já estavam definidos.
- **O que passa a valer:**
  - a mesma `argvar` da primeira etapa;
  - **nós** = média dos `attr(cb, "argvar")$knots` de cada primeira etapa;
  - **`Boundary.knots`** = média dos `attr(cb, "argvar")$Boundary.knots`;
  - **eixo** = média dos percentis p1 a p99, mais p2,5 e p97,5, da série de exposição;
  - **TMR combinada:** grade de 0,1 °C entre o x1 e o x99 combinados;
  - **abrangência:** o principal e toda sensibilidade com outra `argvar` ou outra exposição.
- **Testes unitários antes da tag do código:**
  - os nós médios são iguais à média dos quantis da §1.5;
  - os `Boundary.knots` são iguais a `range(x)` da janela mais o aquecimento;
  - as curvas BLUP usam `do.call(onebasis, c(list(x = grade), attr(cb, "argvar")))` e reproduzem o `crossreduce` da primeira etapa.
- **Pendência herdada:** uma concentração em *fallback* (§5, item 4) tem 3 coeficientes reduzidos. Se acontecer, é desvio próprio antes da segunda etapa.
- **Toca o contraste primário?** **Sim.** Completa a definição do contraste combinado (p99 × TMR combinada), sem mudar o estimando.
- **Resultados vistos antes do registro:** ⟨nenhuma curva combinada com dados reais / descrever⟩.
- **Aprovação explícita:** Guilherme, ⟨data⟩.

### Desvio ⟨n+2⟩ — §2.1: autocorrelação residual sem gatilho

- **Data do registro:** 13/10/2026, antes de rodar.
- **Artigo:** 1 (vale igual para o 2).
- **Decisão de origem:** `spec/decisoes_metodo_20261013.md`, D3 e seção 4.
- **Especificação (literal):** "Se algum lag de 1 a 7 tiver PACF fora de ±2/√n, a sensibilidade acrescenta de uma vez os resíduos de deviance defasados nesses lags." Também a §10.2, linha "Modelo".
- **Motivo:**
  - Com os estratos concentração × ano × mês, a PACF nula dos resíduos fica em ≈ −1/m ≈ −0,033 nos lags 1 a 7, e o limite é 0,030.
  - A regra dispara em 99,5% a 100% das séries sem autocorrelação. Isso foi simulado pelo chat de métodos e pelo auditor independente.
- **O que passa a valer:**
  - **sensibilidade em todas as concentrações:** os resíduos de deviance do principal, defasados nos lags 1 a 7, entram de uma vez; 0 nos dias sem resíduo; mesma amostra; as duas etapas são refeitas;
  - **suplemento:** PACF literal (±2/√n) e PACF recentrada. A recentrada desconta a média de 1.000 séries nulas projetadas fora do desenho completo, com `set.seed(20261001)` e a faixa nula de 2,5% a 97,5%. As duas são só descritivas.
- **Toca o contraste primário?** Não.
- **Resultados vistos antes do registro:** a PACF dos resíduos reais já foi vista? ⟨sim/não⟩. A mudança não depende disso: ela torna a sensibilidade incondicional.
- **Aprovação:** Guilherme, ⟨data⟩.

---

### Para o log do Artigo 3, quando chegar a vez dele — Desvio ⟨m⟩ — §7 e §6 do PIG (esclarecimento e lacuna)

- **Decisão de origem:** `spec/decisoes_metodo_20261013.md`, D2 e seção 5.
- **Especificação (literal, §7):** "`attrdl(x = matriz s01…s37, dir = "back", cen = TMR, ...)`, com as colunas `s01`…`s28` substituídas pela TMR."
- **Esclarecimento (§7):**
  - A chamada roda como está escrita, desde que use **todos os coeficientes da cross-basis da primeira etapa**. Os BLUPs reduzidos do bloco 28+0–36+6 não servem, porque a `attrdl` recusa reduzidos no *backward* (l. 133–134).
  - `cen` = TMR BLUP do bloco; `set.seed(20261001)` antes de cada chamada.
  - O número atribuível continua rotulado como exploratório.
- **Lacuna (§6):** os `Boundary.knots` da base combinada passam a ser a média dos `attr(cb, "argvar")$Boundary.knots` da primeira etapa (base semanal), **não** a amplitude da MM9. O eixo continua sendo a média dos percentis da MM9.
- **Toca o contraste primário?**
  - O número atribuível, não.
  - As fronteiras da base combinada, sim: completam o contraste combinado e exigem o ok explícito de Guilherme.
