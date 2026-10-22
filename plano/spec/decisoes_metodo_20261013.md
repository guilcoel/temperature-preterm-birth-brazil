# Decisões de método — 13/10/2026 (complemento pós-congelamento)

**De:** chat de métodos (coordenação geral) · **Data:** 13/10/2026 · **Origem:** Fase 2 do Artigo 1 (código compartilhado `ajusta_dlnm()`, testado em dados sintéticos)
**Âmbito:** Artigos 1 e 2 (desenho agudo); consequências para o Artigo 3 na seção 5.

**Relação com os documentos congelados.** Este documento **não altera** a especificação v2.0.2 (SHA-256 `a30398496c2bad285a22a55e3bee67c6df1bbdd6439ad9f0f712c2b964a9ed04`) nem as decisões de 08/10 (SHA-256 `62afa891f123da1e84bc71def238ccbb321681b83872eb2c267eac0e37cf030f`). Cada item abaixo é um desvio, registrado em `logs/desvios_especificacao.md` do artigo **antes** de rodar. Nos pontos que trata, inclusive nos trechos da seção 4, este documento prevalece sobre os dois.

**Git:** entra como arquivo novo em `spec/decisoes_metodo_20261013.md`, num commit comum depois da tag `spec-v2.0.2-congelada-…`. Os arquivos congelados não mudam. O Claude Code confere o SHA-256 da cópia contra o informado pelo chat de métodos na emissão.

---

## Resumo

| # | Seção da v2.0.2 | O que estava | O que passa a valer | Toca o contraste primário? |
|---|---|---|---|---|
| D1 | §7, fração atribuível | `attrdl` *backward* | Principal *forward* com os BLUPs; *backward* com os coeficientes completos da primeira etapa como sensibilidade; ponte *forward* sem BLUP como diagnóstico | Não |
| D2 | §6, estimando combinado | Escala de percentis comum, sem base de predição definida | Nós e `Boundary.knots` = média dos lidos de cada primeira etapa; eixo = média dos percentis; vale também para as sensibilidades com outra `argvar` | **Sim:** completa uma lacuna no caminho do contraste primário combinado; exige o ok explícito de Guilherme |
| D3 | §2.1, autocorrelação residual | Gatilho com PACF fora de ±2/√n | Sensibilidade com resíduos defasados nos lags 1 a 7 em todas as concentrações, sem gatilho; PACF literal e recentrada no suplemento | Não |

---

## D1. Fração atribuível nos agudos (§7)

**Especificação (literal):** "Fração atribuível: `attrdl` *backward*, com componentes calor, frio, calor extremo (> p97,5) e frio extremo (< p2,5). eCI com 1.000 simulações e semente fixa. [...] O MCC 2015 usou a perspectiva *forward*; declarar ao comparar."

**Problema (conferido no código-fonte da `attrdl`):**
- A função trata os coeficientes como reduzidos quando o número deles **difere** do número de colunas da cross-basis (l. 107).
- Com coeficientes reduzidos, ela recusa a perspectiva *backward*: `stop("only dir='forw' allowed for reduced estimates")` (l. 133–134).
- Os BLUPs da §6 são dos coeficientes reduzidos da curva cumulativa geral. A combinação "BLUP + *backward*" que a §7 pede não roda.

**Decisão:**
1. **Principal:** `attrdl(..., dir = "forw")` com os BLUPs reduzidos de cada concentração (`blup` e `vcov` do `mixmeta`).
   - `cen` = TMR BLUP da concentração (§7).
   - `cases` = série diária de eventos da janela principal.
   - Componentes calor, frio, calor extremo e frio extremo pelo argumento `range`.
   - 1.000 simulações.
   - O total soma as concentrações; o eCI soma as simulações de cada concentração (como no `03.attr.R` do MCC 2015).
   - Denominador: total de eventos da série principal.
2. **Sensibilidade:** `dir = "back"` com **todos os coeficientes da cross-basis da primeira etapa** (16 no canônico) e a matriz de covariância correspondente do `gnm`.
   - `cen` = a mesma TMR BLUP do principal.
   - `x` inclui os 7 dias de aquecimento da §1.5, com `cases` = NA nesses dias, para que os 7 primeiros dias da janela tenham as exposições defasadas completas.
   - **Teste:** `vcov(modelo)` igual a `summary(modelo)$cov.scaled`, o que confirma que o φ do quasi-Poisson está na matriz.
3. **Ponte (diagnóstico no suplemento, sem leitura inferencial):** `dir = "forw"` com os coeficientes reduzidos da primeira etapa, sem BLUP.
   - Principal × ponte isola o efeito do encolhimento; ponte × sensibilidade isola o efeito da perspectiva. Sem a ponte, a sensibilidade mistura as duas coisas.
   - Os coeficientes reduzidos não dependem da centragem (`crossreduce.R`, l. 119), então a ponte é legítima com a `cen` comum.
4. **O que é igual nas três análises:** a mesma `cen` (TMR BLUP), os mesmos `range` dos componentes, 1.000 simulações e `set.seed(20261001)` **imediatamente antes de cada chamada** da `attrdl`.
   - A função sorteia internamente (l. 163), e o `03.attr.R` do MCC não reinicia a semente entre total, calor e frio.
   - Reiniciá-la dá os mesmos sorteios dos coeficientes a total, calor e frio, e torna cada número reprodutível isoladamente.
5. **Ponta da série no *forward*:** para o dia t, a `attrdl` usa a média dos eventos de t a t + 7 (l. 87).
   - Nos 7 últimos dias da janela essa média fica NA. A função exclui esses dias do cálculo da AF e a reescala ao total observado, calculado antes com `na.rm` (l. 85 e 146–150).
   - Os eventos depois de 2024-08-06 **não** são usados.
   - O *backward* não perde esses dias. Declarar a diferença.
6. **A frase "O MCC 2015 usou a perspectiva *forward*; declarar ao comparar"** passa a ser: "Ao comparar com outros estudos, declarar a perspectiva usada em cada um." A do Iñiguez 2026 (ref. 2, o comparador principal do Artigo 1) não foi conferida aqui. O chat do Artigo 1 confere antes de escrever a Discussion.

**Por quê:**
- É a única forma de usar os BLUPs na `attrdl` sem reescrevê-la.
- É o que o MCC 2015 faz. O `03.attr.R` diz, literalmente, "NB: THE REDUCED COEFFICIENTS ARE USED HERE" e chama `attrdl(data$tmean,cb,data$death,coef=blup[[i]]$blup, vcov=blup[[i]]$vcov,type="an",dir="forw",cen=mintempcity[i])`.
- A interpretação das duas perspectivas está em Gasparrini & Leone 2014 (ref. 46 da especificação).

**Limitações a declarar:**
- Os coeficientes da primeira etapa não têm encolhimento e são instáveis nas concentrações pequenas. A sensibilidade é lida pelo total, não por concentração.
- Com `cen` = TMR BLUP, a curva sem encolhimento pode ficar abaixo de 1 perto da `cen`, com contribuições negativas.
- O eCI do total trata as concentrações como independentes, embora os BLUPs compartilhem a média combinada (como no MCC 2015).

**Frase para Methods (inglês americano):**
> Attributable numbers and fractions were computed with the forward perspective, which assigns to the exposure on each day the events occurring over the following 0–7 days, using the BLUP-reduced coefficients of each urban concentration, as in the MCC study.<sup>[MCC 2015]</sup> The backward perspective, which requires the full first-stage cross-basis coefficients, was computed as a sensitivity analysis.<sup>[Gasparrini & Leone 2014]</sup>

---

## D2. Base de predição da curva combinada (§6)

**Especificação (literal):** "a curva cumulativa geral prevista pelo `mixmeta` na média dos metapreditores, numa escala de percentis comum, que é a média dos percentis das 26 concentrações (como no MCC)". Para o PIG, a §6 já define os nós; para os agudos, não define nem nós nem fronteiras.

**Lacuna:** os coeficientes combinados só têm sentido numa base concreta. Sem nós e `Boundary.knots` definidos, o código escolhe por omissão.

**Decisão (regra geral, para toda curva combinada):**
- **Função:** a mesma `argvar` da primeira etapa (`fun`, grau, `intercept`).
- **Nós:** média, nas concentrações da meta-análise, dos `attr(cb, "argvar")$knots` de cada primeira etapa.
- **`Boundary.knots`:** média dos `attr(cb, "argvar")$Boundary.knots` de cada primeira etapa.
- **Por que ler do objeto:** é a base em que os coeficientes foram estimados. As fronteiras são a amplitude do `x` passado ao `crossbasis` (janela mais aquecimento), não da série de referência dos percentis. Ler do objeto é válido porque o `crossbasis` guarda na `argvar` os argumentos formais do `ns` e do `bs`, inclusive as fronteiras (`crossbasis.R`, l. 31 e 83–85).
- **Eixo:** média, nas mesmas concentrações, dos percentis p1 a p99 (inteiros), mais p2,5 e p97,5, da série de exposição usada para os nós.
  - No principal, é a `tmean_nucleo` diária de 2012-01-01 a 2024-12-31.
  - x99, x95, x90, x10, x5 e x1 combinados saem desse eixo.
- **TMR combinada:** mínimo da curva numa grade de 0,1 °C entre o x1 e o x99 combinados (a regra da §7), com o percentil correspondente no eixo médio. IC por bootstrap paramétrico sobre a predição do `mixmeta`.
- **Abrangência:** vale para o principal e para toda sensibilidade com outra `argvar` ou outra exposição:
  - S1 (`bs`), S2 (nós p50/p90);
  - estação quente (nós e eixo de novembro a março);
  - `tmean_mun`, Tmax, Tmin e temperatura aparente.
  - O eixo de cada uma sai da série de exposição dela.

**Testes unitários (antes da tag do código):**
1. No principal, a média dos `attr(cb, "argvar")$knots` é igual à média dos quantis p10/p75/p90 da §1.5. Por construção, os nós médios coincidem então com o eixo médio nesses percentis.
2. Em cada concentração, `attr(cb, "argvar")$Boundary.knots` é igual a `range(x)` da série passada ao `crossbasis` (janela mais os 7 dias de aquecimento).
3. As curvas BLUP por concentração, inclusive a busca da TMR da §7, usam `do.call(onebasis, c(list(x = grade), attr(cb, "argvar")))`. Essa predição reproduz o `crossreduce` da primeira etapa nos percentis da concentração.
   - O MCC 2015 passa as fronteiras de forma explícita. No `02.secondstage.R`: "REDEFINE THE FUNCTION USING ALL THE ARGUMENTS (BOUNDARY KNOTS INCLUDED)", com `Bound=range(data$tmean,na.rm=T)`.

**Por que as fronteiras importam (reproduzido duas vezes, com `ns` reimplementado em Python e validado contra a curva verdadeira):**

| Reprodução | RR verdadeiro (p99 × p50) | Com as fronteiras da 1ª etapa | Com as fronteiras padrão da grade p1–p99 |
|---|---|---|---|
| Chat de métodos | 1,476 | 1,480 | 2,260 |
| Auditor independente | 1,587 | 1,601 | 3,763 |

**Limitação a declarar:** a curva combinada supõe que os coeficientes são comparáveis numa escala relativa comum de temperatura, que é a suposição usual do MCC.

**Pendência herdada, não resolvida aqui:**
- O *fallback* da §5, item 4 (ns com nós p50/p90 e lag em estratos 0–1, 2–4 e 5–7), gera 3 coeficientes reduzidos, e não 4.
- Uma concentração em *fallback* não entra no mesmo `mixmeta` nem na mesma base média.
- Se acontecer, é desvio próprio, registrado antes da segunda etapa, com a escolha entre:
  - (a) refazer todas as concentrações com a base do *fallback*;
  - (b) deixar a concentração fora da meta-análise e reportá-la à parte.

**Aprovação:** como completa o caminho do contraste primário combinado (p99 × TMR combinada), o registro no log traz o ok explícito de Guilherme.

---

## D3. Autocorrelação residual (§2.1)

**Especificação (literal):** "PACF dos resíduos de deviance por concentração, no suplemento. Se algum lag de 1 a 7 tiver PACF fora de ±2/√n, a sensibilidade acrescenta de uma vez os resíduos de deviance defasados nesses lags."

**Problema (reproduzido por simulação, duas vezes):**
- O modelo condicional faz os resíduos somarem cerca de zero dentro de cada estrato concentração × ano × mês (m ≈ 30 dias).
- Dois dias no mesmo estrato ficam com correlação −1/(m − 1). A ACF do lag 1 fica em ≈ −1/m ≈ −0,033, mesmo sem autocorrelação nenhuma nos dados.
- Na janela do PTB (n = 4.498 dias, 149 estratos), a PACF nula ficou entre −0,031 e −0,034 nos lags 1 a 7, estável entre os lags. O limite é 2/√n = 0,030.
- **A regra literal dispara em 99,5% a 100% das réplicas sem autocorrelação**: ruído branco gaussiano e Poisson com λ = 0,3, 3 e 80 por dia, nas janelas do PTB e do perinatal, 400 réplicas cada, no chat de métodos e no auditor.

**Decisão:**
1. **Sensibilidade sem gatilho:** em **todas** as concentrações, o modelo principal recebe, de uma vez, os resíduos de deviance do próprio principal defasados nos lags 1 a 7.
   - Dias sem resíduo (antes do início da janela ou em estrato removido por não ter evento) entram com 0, o valor esperado do resíduo. Assim a amostra de ajuste é a mesma do principal.
   - As duas etapas são refeitas. Reportar o RR combinado em p99 e p1 contra a TMR, a TMR combinada e os RRs por concentração.
2. **Suplemento:** por concentração, duas PACF dos resíduos de deviance nos lags 1 a 7, ambas só descritivas; nenhuma decisão depende delas.
   - **Literal**, com ±2/√n.
   - **Recentrada:** a observada menos a média da PACF nula, com a faixa de 2,5% a 97,5% da nula.
   - A nula vem de 1.000 séries de ruído branco gaussiano com os mesmos dias do ajuste, projetadas fora do desenho completo do modelo (estratos não vazios, cross-basis e demais termos) por mínimos quadrados, com `set.seed(20261001)`.
   - A diferença em relação a só tirar a média do estrato é pequena. Foi de até 0,002 na reprodução do chat de métodos e de 0,004 no lag 1 na do auditor. Projetar no desenho completo não custa nada.

**Por que não usar a PACF recentrada como novo gatilho:**
- Mesmo recentrada, a regra testa 7 lags a ±2/√n e disparou em 22% a 31% das réplicas nulas, por multiplicidade.
- Com a regra literal, a sensibilidade rodaria na prática em todas as concentrações e com todos os lags. A decisão formaliza esse resultado e tira do caminho uma escolha que dependeria dos dados.

---

## 4. Trechos da v2.0.2 que mudam por consequência

| Trecho | Texto atual | Passa a ser |
|---|---|---|
| §2.1, último item | Gatilho da PACF | D3 |
| §6, "Estimando combinado" | Escala de percentis comum | Mais a base de predição da D2 |
| §7, "Fração atribuível" | *backward* | D1 (*forward* com BLUPs no principal) |
| §7, "O MCC 2015 usou a perspectiva *forward*; declarar ao comparar." | — | "Ao comparar com outros estudos, declarar a perspectiva usada em cada um." |
| §10.2, linha "Modelo" | "resíduos defasados se houver autocorrelação" | "resíduos defasados nos lags 1 a 7, em todas as concentrações" |
| §10.2, lista fechada | — | **Entram:** a AF *backward* com coeficientes da primeira etapa (sensibilidade) e a AF *forward* sem BLUP (ponte, diagnóstico) |
| §12, item 7 | "attrdl backward, 1.000 sims" | "attrdl forward com BLUPs, 1.000 sims; backward como sensibilidade" |

---

## 5. Consequências para o Artigo 2 e o Artigo 3

| Item | Artigo 2 (óbito perinatal) | Artigo 3 (PIG) |
|---|---|---|
| D1 | Vale igual (mesmo desenho agudo); registrar no log do Artigo 2 antes de rodar | **Esclarecimento, não mudança.** A §7 do PIG (`attrdl(x = matriz s01…s37, dir = "back")`, com `s01`…`s28` na TMR) roda como está escrita, desde que use os **coeficientes da cross-basis completa da primeira etapa**, e não os BLUPs: a l. 133–134 recusa reduzidos no *backward*. A §7 do PIG não pede BLUP; fica explícito. `cen` = TMR BLUP do bloco 28+0–36+6; continua rotulado como exploratório. Registrar no log do Artigo 3 antes de rodar |
| D2 | Vale igual | A §6 do PIG define os nós (média dos p10/p75/p90 **semanais**), mas não os `Boundary.knots`. **Completar** pela regra geral da D2: média dos `attr(cb, "argvar")$Boundary.knots` da primeira etapa (base semanal), **não** a amplitude da MM9. O eixo continua sendo a média dos percentis da MM9 |
| D3 | Vale igual. Com contagens baixas, o resíduo de deviance é discreto, mas o viés da PACF é o mesmo (simulado com λ = 0,3 por dia) | Não se aplica (a §2.1 é só dos agudos) |

---

## 6. Auditoria

### 6.1 Reproduções do chat de métodos (das afirmações do Artigo 1)

| Ponto | Afirmação do Artigo 1 | Reprodução | Resultado |
|---|---|---|---|
| D1 | A `attrdl` *backward* não aceita coeficientes reduzidos (l. 134) | Leitura do `attrdl.R` (© Gasparrini 2015–2017; SHA-256 `d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d` da cópia lida aqui): l. 107, 133–134 | Confirmado |
| D1 | O MCC 2015 usa *forward* com BLUP | Leitura do `03.attr.R` de `gasparrini/2015_gasparrini_Lancet_Rcodedata` (SHA-256 `87b9cef1c1a6e8217c63c89229692e612b2e97e1e78beec369134b441730d334`) | Confirmado, literal |
| D2 | Mesma regra do PIG; nós e fronteiras médios | `ns_boundary.py` | Confirmado. Achado adicional: as fronteiras têm de ser explícitas (tabela da D2); o MCC 2015 faz isso no `02.secondstage.R` (SHA-256 `23f5a5eedc10b1929300c3c99097e4707feac5b2f985a402d63c633fda9b7bba`) |
| D3 | PACF nula ≈ −0,033; limite 0,030 | `pacf_sim.py` | Confirmado: −0,031 a −0,034, disparo literal de 99,5% a 100% |

### 6.2 Auditoria independente (subagente em contexto limpo; nenhum achado aceito sem reprodução)

O auditor confirmou os hashes, as linhas citadas, as citações literais e o viés da PACF com código próprio. Não houve achado crítico.

| # | Grav. | Achado | Reprodução pelo chat de métodos | Correção |
|---|---|---|---|---|
| 1 | Maior | D1 e D3 não atualizavam a §10.2 (linha "Modelo" e lista fechada) e a §12, item 7 | Lidas as l. 598–601 e 665–668 da v2.0.2: dizem "resíduos defasados se houver autocorrelação" e "attrdl backward" | Seção 4 |
| 2 | Maior | A ponte não tinha `cen`, `range` nem sementes definidos; sem eles, a decomposição não vale | Releitura do rascunho: confirmado | D1, item 4 |
| 3 | Maior | A D2 só cobria o principal; as sensibilidades com outra `argvar` ficavam com a mesma lacuna | §1.1 l. 85 e §1.2 (S1, S2) conferidas | D2, "Abrangência"; nós lidos do objeto |
| 4 | Maior (condicional) | O *fallback* gera 3 coeficientes reduzidos, incompatíveis com o `mixmeta` de 4 | §5, item 4 (l. 403) conferido: ns p50/p90 tem 3 colunas | Pendência herdada, na D2; "16" virou "todos os coeficientes" na D1 |
| 5 | Menor | A l. 107 compara com `!=` | Confirmado | D1, "Problema" |
| 6 | Menor | Faltava a l. 85 (`den`) | Confirmado | D1, item 5 |
| 7 | Menor | Citação do MCC era `range(data$tmean)` | Confirmado: `Bound=range(data$tmean,na.rm=T)` | D2, teste 3 |
| 8 | Menor | `onebasis(x =, argvar =)` não roda | Confirmado pelo padrão do `crossreduce.R` l. 92 | `do.call(onebasis, c(list(x = grade), attr(cb, "argvar")))` |
| 9 | Menor | A ACF do lag 1 é −1/m, não −1/(m − 1) | Confirmado: −1/m = −0,0331 e −1/(m − 1) = −0,0343; simulado −0,033 | D3 |
| 10 | Menor | A nula só com a média do estrato difere da nula com o desenho completo | **Reproduzido em parte** (`pacf_fulldesign_own.py`, 1.000 séries): diferença de até 0,0017, perto do erro de Monte Carlo; o auditor achou +0,004 no lag 1 | Nula projetada no desenho completo, 1.000 séries (custo nulo) |
| 11 | Menor | A `attrdl` sorteia internamente; a semente da especificação é 20261001 | Confirmado: l. 163 da `attrdl`; §8, l. 485 | D1, item 4 |
| 12 | Menor | Contribuições negativas no *backward* sem encolhimento | Confirmado por construção: AF = 1 − exp(−β·x) < 0 onde a curva < 1 | D1, limitações |
| 13 | Menor | "A vcov do `gnm` inclui o φ" não é verificável aqui | Aceito (não há R) | D1, teste no item 2 |
| 14 | Menor | A perspectiva do Iñiguez 2026 não foi conferida | Aceito | D1, item 6 |
| 15 | Menor | As fronteiras dependem do `x` exato passado ao `crossbasis` | Confirmado: `crossbasis.R` l. 31 | D2, teste 2 |
| 16 | Menor | A §7 do PIG roda como escrita com os coeficientes da primeira etapa; a l. 68 não é relevante | Confirmado: a §7 do PIG não pede BLUP | Seção 5: "esclarecimento" |

### 6.3 O que não foi verificado

- Não há R neste ambiente. A `attrdl` e o `gnm` não foram executados, só lidos. O `ns` foi reimplementado em Python e validado contra a curva verdadeira, não contra o R.
- Não achei um script público do MCC que construa a curva **combinada** de vários países. A D2 se apoia na frase da §6, na regra já fixada para o PIG e na prática do MCC 2015 por cidade.
- Se a Fase 2 rodou algum modelo de desfecho com dados reais, o registro no log tem de dizer isso.

---

## 7. Scripts do chat de métodos

São simulações de coordenação, com dados sintéticos. As análises dos artigos usam a semente 20261001.

| Arquivo | SHA-256 | O que faz |
|---|---|---|
| `pacf_sim.py` | `495b8cca7874ccc934ea0aec6879e803f228da82cb9aa0d1a476a9d581850d9e` | D3: PACF nula com estratos ano × mês, gaussiano e Poisson; disparo literal e recentrado (semente 20261013) |
| `pacf_fulldesign_own.py` | `c3382b6a1432f2a56963503e8f0c5b0326e91866305407328cedb54a48fbf23e` | D3: nula com só a média do estrato × projetada no desenho completo (semente 20261001) |
| `ns_boundary.py` | `92f8888705ed7aea371fa2e06f9bd08078d8f3366c085120706e8bc50c6b8f01` | D2: efeito dos `Boundary.knots` na curva prevista (semente 20261013) |
