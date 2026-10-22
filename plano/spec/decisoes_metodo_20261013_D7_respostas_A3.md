# Decisões de método — 13/10/2026, D7: respostas ao Artigo 3 (PIG) antes da Fase 3

**De:** chat de métodos (coordenação geral) · **Data:** 13–14/10/2026 · **Origem:** pedido do chat do Artigo 3 (13/10). A 1ª etapa rodou às cegas: 104 ajustes, C5 em 104 de 104, **nenhuma estimativa vista**.
**Âmbito:** Artigo 3. O M7 vale para os três artigos.

**Relação com os outros documentos.**
- Complementa a especificação v2.0.2 (tag `spec-v2.0.2-congelada-20261009`), as decisões de 08/10 e de 13/10, o complemento, a D5 e a D6.
- Estende ao Artigo 3, com as adaptações abaixo, o complemento (C1, C3) e a D1.
- Corrige uma frase da D5 (item 6).
- Entra como arquivo novo em `spec/`. Os registros do Artigo 3 vão num commit próprio, antes de rodar, com a declaração "nenhum resultado visto".

---

## Resumo

| # | Pedido | Decisão | Bloqueia |
|---|---|---|---|
| M1 | Sanduíche agrupada como `vcov` principal | **Principal: sanduíche HC0 agrupada por ano × mês de `dum_est`, com G/(G − 1)** (decisão de Guilherme, 13/10). A proteção contra fator comum lento é **parcial**. Sensibilidades: por ano × trimestre (nova), por `dum_est` e `vcov` do modelo; mais um diagnóstico de autocorrelação dos resíduos | Fase 3 (reajuste às cegas) |
| M2 | INTERGROWTH +0/+6 | **Aprovado:** só a classificação muda | — |
| M3 | Estender C1, C3 e D1 ao PIG | **Aprovado,** com (i) e (ii) definidos e a frase da D5 corrigida. O P1 da D5 entra no PIG **pré-especificado** | — |
| M4 | MRT na fronteira e conversão | **(a) e (c) aprovados. (b) ajustado:** `quantile(..., type = 7)` nos dois eixos. **(d) completado** com o centro de cada nível | — |
| M5 | Código compartilhado no PIG | **Aprovado,** com quatro condições | — |
| M6 | Decisões da Fase 4 | **As seis confirmadas;** o item 6 ganha teste unitário | Só a Fase 4 |
| M7 | *Fallback* e dimensão da 2ª etapa | **Aprovado em dois passos, para os três artigos:** primeiro só a `arglag`, por concentração; depois a `argvar`, nas 26 | — |

---

## M1. EP da 1ª etapa do PIG: sanduíche agrupada por ano × mês de `dum_est`

### M1.1 O problema e a evidência

- A §2.2 garante que as células reproduzem as estimativas e os EP do modelo **individual** com binomial independente. Ela não trata da dependência entre nascimentos.
- **Exposição compartilhada, por si só, não viola a independência.** O que viola é um fator não medido comum, como choques de calendário ou epidemias, que fique fora dos efeitos fixos aditivos de ano e mês.
- **A sobreposição das janelas `s01`…`s37` não cria correlação, mas amplifica o efeito dela no EP.** Ela faz a MM9 ser fortemente autocorrelacionada entre `dum_est` vizinhos.

**Simulações** (efeito verdadeiro nulo; cobertura do IC 95% do coeficiente da MM9; efeitos fixos aditivos de ano e mês):

| Fator comum | Fonte | Modelo | Por `dum_est` | Por ano × mês | Por ano × trimestre | HAC de 120 dias |
|---|---|---|---|---|---|---|
| Nenhum | Auditor (1.000 réplicas) | 0,950 | 0,948 | 0,937 | 0,934 | 0,923 |
| Só no dia (iid) | Auditor | 0,940 | 0,948 | 0,938 | 0,928 | 0,923 |
| AR(1), φ = 0,97 | Auditor | 0,711 | 0,730 | **0,867** | 0,903 | 0,890 |
| AR(1), φ = 0,97, sem componente interanual na temperatura | Chat de métodos (150 réplicas) | 0,77 | 0,78 | **0,92** | — | — |
| AR(1), φ = 0,995 | Auditor | 0,738 | 0,744 | **0,834** | 0,889 | 0,872 |
| AR(1), φ = 0,995, com componente interanual | Chat de métodos, `repro_aud8.py` (150 réplicas) | — | 0,673 | **0,747** | — | — |
| Choque na data do parto (média móvel de 42 dias) | Auditor | 0,727 | 0,746 | **0,865** | 0,900 | 0,885 |
| Choque mensal com AR entre meses (ρ = 0,8) | Auditor | 0,734 | 0,738 | **0,845** | 0,894 | 0,882 |
| Qualquer um dos acima, com **ano × mês interagidos** como efeitos fixos (chave 3) | Auditor (250 réplicas) | — | — | **0,932 a 0,956** | — | — |

**Leitura:**
- O agrupamento por ano × mês é sempre melhor que o por `dum_est`, mas a cobertura é **parcial** quando a correlação atravessa a fronteira do mês (0,75 a 0,87).
- O agrupamento por ano × trimestre protege mais (cerca de 0,89 a 0,90), com só 52 grupos.
- **A proteção real contra fator comum lento é a sensibilidade-chave 3** (ano × mês interagidos), que absorve o fator no nível do mês.
- **Limitações:** uma concentração sintética, exposição linear, sem covariáveis. A simulação do chat de métodos usa a CR1 do statsmodels (G/(G − 1)·(N − 1)/(N − K)), que difere da HC0 com G/(G − 1) em cerca de 0,5% na variância. As simulações mostram direção, não tamanho.

### M1.2 Decisão

1. **`vcov` principal da 1ª etapa (as quatro curvas):** sanduíche **HC0** agrupada por **ano × mês de `dum_est`** (cerca de 156 grupos), com G/(G − 1):
   `sandwich::vcovCL(m, cluster = ~ ano_mes_dum_est, type = "HC0", cadjust = TRUE)`
   - **`type = "HC0"` explícito é obrigatório.** O padrão da `vcovCL` para `glm` é HC1, e o fator (n − 1)/(n − k) quebra a equivalência entre células e modelo individual. O auditor achou 1,0020 no individual contra 1,0101 nas células. Com HC0 e G/(G − 1), a `vcov` em células coincide com a individual até 2 × 10⁻⁸ quando o grupo contém células inteiras.
   - Ela alimenta a S do `mixmeta` e, a partir daí, Ψ, BLUP, MRT, OR, bootstrap da MRT, eCI da `attrdl` e o P1 (M3.3).
2. **Sensibilidades (entram na lista fechada da §10.2, grupo "Modelo"):**
   - sanduíche HC0 por **ano × trimestre** de `dum_est` (cerca de 52 grupos), com G/(G − 1), pela proteção maior contra correlação que atravessa meses;
   - sanduíche HC0 por `dum_est`, com G/(G − 1) (já gravada às cegas na Fase 2, D-F2.9, sem o fator);
   - `vcov` do modelo (binomial).
3. **Diagnóstico pré-especificado (suplemento, descritivo):**
   - ACF dos resíduos de Pearson do principal, somados por `dum_est` e padronizados, nos lags de 1 a 90 dias, por concentração;
   - mais a razão entre o EP agrupado por ano × trimestre e o por ano × mês.
   - Nenhuma decisão depende deles. Servem para o leitor julgar quanto a cobertura parcial pesa.
4. **Reajuste às cegas:** os 104 modelos são reajustados (ou os escores regravados) só para obter as novas `vcov`, sem abrir coeficientes.
   - **Teste:** os coeficientes coincidem com os da Fase 2 até 1e-10, e o grupo é o ano × mês (ou o ano × trimestre) do `dum_est` da célula.
5. **A sensibilidade-chave 3** (ano × mês interagidos como efeitos fixos) continua, com a mesma sanduíche por ano × mês. O texto diz que ela é a verificação principal contra fator comum lento.
6. **Toca o contraste primário:** muda o IC e, pela S, Ψ, os BLUP e a MRT. É desvio da §2.2 e da §6, registrado antes de qualquer estimativa.

**Frase para Methods (inglês americano):**
> Births sharing calendar periods may share unmeasured time-varying factors, and the overlapping exposure windows of neighboring start dates amplify the effect of such residual correlation on standard errors. First-stage variance–covariance matrices were therefore estimated with a cluster-robust (sandwich, HC0) estimator clustered by year-month of estimated pregnancy start (156 clusters), with the small-sample factor G/(G − 1). Because this clustering only partially protects against residual correlation extending across months, we report sensitivity analyses clustering by year-quarter, by start date, and with model-based variances, the residual autocorrelation function, and a model with interacted year-by-month fixed effects.

**Opção, se Guilherme preferir mais proteção no principal:** passar o principal para ano × trimestre e manter ano × mês como sensibilidade. É troca de 0,85 por 0,90 de cobertura nos cenários lentos, ao custo de 52 grupos. A decisão registrada continua ano × mês, salvo nova ordem antes do reajuste.

---

## M2. Curvas INTERGROWTH +0 e +6 dias: só a classificação

- **Decisão:** aprovado como proposto.
  - `pig_ig21_g0` e `pig_ig21_g6` mudam só a IG em dias da classificação (7·IG + 0 e 7·IG + 6), pelas colunas `c_ig21_g0` e `c_ig21_g6`.
  - Exposição, `dum_est` e coorte fixa ficam os do principal (+3).
- **Por quê:**
  - A §10.2 põe "+0/+6 dias" na linha **Desfecho**.
  - A pergunta da sensibilidade é a incerteza da IG dentro da semana para o escore z.
  - Deslocar também a exposição misturaria duas fontes de variação.
- **Declarar em Methods:** o alinhamento da exposição (+3 dias) é o mesmo em todas as curvas.

---

## M3. Complemento (C1, C3) e D1 estendidos ao Artigo 3

### M3.1 O que se estende

| Regra | No PIG |
|---|---|
| **C1 (sementes)** | `set.seed(20261001 + i, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")` imediatamente antes de cada simulação por concentração (`attrdl` e bootstrap da MRT), na mesma ordem gravada das 26; 20261001 nas quantidades combinadas |
| **C3 (a)** | IC da MRT por bootstrap paramétrico (Cholesky, 1.000 sorteios) na grade da MM9, com a S da `vcov` principal (M1) |
| **C3 (g)** | `cen` da `attrdl` = MRT da grade p1–p99 da MM9 |
| **C3 (h)** | Componentes com `max`/`min` em relação à MRT, pelo ponto (i) abaixo |
| **C3 (i)** | Grade com o último ponto incluído só se `x_sup − último > 1e-8`; fronteira detectada pelo índice |
| **C3 (d)** | AN arredondado ao inteiro, sem máscara. O denominador recuperável (casos `pig_ig21` da concentração no período inteiro, ≥ 11.050) é mais grosso que concentração × ano |
| **Falha do `mixmeta`** | A mesma definição (erro capturado ou `isFALSE(converged)`) |
| **C2 (série consecutiva)** | Não se aplica: a cross-basis do PIG recebe a matriz `s01`…`s37` por célula, sem defasagem por posição |
| **D6, item 2** | Os testes novos se aplicam, com a linha do PIG da tabela do teste 3 |

### M3.2 D1 no PIG: as duas definições

- **(i) Componentes extremos.**
  - O p97,5 e o p2,5 vêm da **distribuição semanal pela leitura (i)** da concentração.
  - Com `x` em matriz, o `range` da `attrdl` age elemento a elemento (l. 58), sobre os valores semanais de `s29`…`s37`. As colunas `s01`…`s28` ficam na MRT e não contribuem.
  - Calor extremo = semanas acima de `max(p97,5 semanal, MRT)`; o frio é simétrico.
- **(ii) Contribuições negativas.**
  - Pode haver contribuição negativa dentro do p1–p99, por duas razões:
    - os coeficientes da 1ª etapa (sem BLUP) não têm o mínimo na `cen` da curva BLUP;
    - mesmo com coeficientes BLUP, a MRT minimiza a curva **cumulativa** com exposição constante, não cada semana. Com semanas variando no *backward*, a soma ponderada pode ficar abaixo da referência.
  - A justificativa da C3(h) dos agudos ("RR ≥ 1 dentro do p1–p99") **não se transpõe**.
  - Declarar em Methods e reportar os componentes como saírem, com o total.
  - **No *backward* não há aditividade** (complemento, C1, item 5): reportar a diferença total − (calor + frio).

### M3.3 Correção da D5 (item 6) e P1 no PIG

- **A D5 disse que o número atribuível do PIG "tem a mesma propriedade" da AF dos agudos. Não tem:** ele pode ter contribuições negativas, e o sentido do viés sob efeito nulo não foi verificado.
- **O texto da D5, item 2, entra adaptado no PIG:**
  > The attributable number may include negative contributions and may be biased upward, because the reference is the minimum of the estimated BLUP curve; odds ratios against the MRT searched within the 1st–99th percentiles of the 9-week moving average are not lower than 1 by construction, and their confidence intervals are conditional on the estimated MRT.
- **P1 da D5 no PIG, pré-especificado** (o A3 ainda não viu resultados, então aqui não é post hoc):
  - Wald da curva cumulativa combinada do bloco 28+0–36+6, prevista na média dos metapreditores, com a S da `vcov` principal;
  - os gl seguem a dimensão: 4 no principal, 3 no *fallback* de `argvar` e 5 na S1 (`bs` de grau 2);
  - vai para o **suplemento**, fora do critério de concordância da §9.2, como nos agudos.
- **P2 não entra:** o número atribuível já é exploratório.

---

## M4. MRT na fronteira e conversão da MRT combinada

- **(a) Aprovado.**
  - A referência de todos os contrastes é sempre a MRT p1–p99 (combinada ou da concentração).
  - Na fronteira (índice 1 ou último), cada tabela ganha duas colunas: contra o p50 da MM9 e contra a MRT buscada entre p10 e p90, com bootstrap.
  - Vale por curva, bloco e `vcov`.
  - OR degenerado (valor = `cen`): sai como 1, com IC NA e o motivo.
- **(b) Ajustado:** a mesma convenção da D6, 3(a), dos agudos. É uma convenção única para os três artigos, não uma regra "mais exata".
  - **Eixo combinado da MM9:** média, nas 26, de `quantile(MM9_conc, probs, type = 7)`. MM9_conc é a série das MM9 de cada `dum_est` único, de 2011-04-17 a 2024-03-05 (§3.3).
  - q = posição da MRT combinada nesse eixo, por `approx` (eixo ordenado).
  - °C da concentração = `quantile(MM9_conc, q/100, type = 7)`.
- **(c) Aprovado.**
  - ORs por semana (E3): `crossreduce(type = "var", model.link = "logit")` no p99 e no p1 **semanais** (leitura i), centrado no °C de (b).
  - Na fronteira da MRT combinada, o centro passa ao p50 da MM9 da concentração, nos dois lados. O texto declara a troca de estimando.
- **(d) Completado** ("centrados na mesma TMR", §3.3, em °C):
  - na concentração, o centro é a MRT BLUP da concentração (do primário);
  - na curva combinada de cada trimestre, o centro é a MRT combinada do primário em °C, com a curva no eixo médio da sua MM14 e a base de predição da D2 (nós e fronteiras médios lidos de cada 1ª etapa).

---

## M5. Código compartilhado (`segunda_etapa-v1.0`) no PIG

**Aprovado, com quatro condições:**
1. O código da tag é usado em tudo o que ele cobre por argumento, sem modificação: `model.link = "logit"`, subperíodo de lag, base de predição, `vcov` passada de fora.
2. Onde ele não cobre, entra função própria do A3, com o mesmo algoritmo, testes unitários com controle negativo e **auditoria independente** antes do uso.
3. Os desvios 71–77 (A1) e 81–91 (A2) entram no log do A3 **um a um**, marcados "aplica", "não aplica" ou "adaptado", com uma linha de motivo. Os que mudarem estimando ou escala param e vêm ao chat de métodos.
4. Se existir a `v1.0.1` (testes da D6), é ela que se usa. A conferência da D6, 3.4, vale também para o A3.

---

## M6. Decisões da Fase 4: confirmadas

| # | Decisão | Confirmação |
|---|---|---|
| 1 | DLM linear de UR e PM2.5: `argvar = "lin"` × `arglag` ns 4 gl com intercepto, somado ao modelo da `tmean` | **Confirmada.** O PM2.5 só onde a §2.3 permite |
| 2 | Sensibilidades da §10.2 só na `pig_ig21`; Pedreira e OMS 37–40 são a chave 6; a OMS meio de semana é sempre reportada, mas não é chave | **Confirmada** (§9.2, item 6; §3.3) |
| 3 | `bs` de grau 2 com nós p10/p75/p90 da leitura (i) | **Confirmada** (§1.2, S1) |
| 4 | "Sem 2020–21": exclui `dum_est` de 2019-04-18 a 2021-12-31 | **Confirmada.** `s37` termina em `dum_est` + 258 dias; 2020-01-01 − 258 dias = **2019-04-18** (conferido por mim e pelo auditor). O auditor notou que os partos que ficam na base, de `dum_est` até 2019-04-17, ocorrem até `dum_est` + 297, ou seja, até 2020-02-08, antes do primeiro caso de covid no Brasil |
| 5 | Pré-termo e uma etapa: exposição na escala de percentis da leitura (i) de cada concentração, com cross-basis comum | **Confirmada** (§6) |
| 6 | Trimestres conjuntos: `arglag = list(fun = "strata", breaks = c(14, 28), intercept = TRUE)`, 12 colunas | **Confirmada,** com teste: estratos de lag 0–13, 14–27 e 28–36, e o terceiro coincide com o bloco primário. **Teste unitário obrigatório:** `onebasis(0:36, fun = "strata", breaks = c(14, 28), intercept = TRUE)` tem de dar 3 colunas, com as linhas 0–13, 14–27 e 28–36 nas colunas 1, 2 e 3. A semântica dos `breaks` vem de memória (intervalos fechados à esquerda), não foi conferida no código |

---

## M7. *Fallback* e dimensão da 2ª etapa (os três artigos): dois passos

**Problema:**
- A §3.3 e a §5 aplicam o *fallback* por concentração, mas o `mixmeta` exige a mesma dimensão nas 26.
- A dimensão reduzida vem só da `argvar` (`crossreduce.R`, l. 89–91). Trocar só a `arglag` mantém os 4 coeficientes reduzidos.

**Decisão:**
1. **Passo 1, por concentração, como a §3.3 e a §5:** a concentração que não convergir troca **só a `arglag`**. No PIG, ns de 3 gl; nos agudos, estratos 0–1, 2–4 e 5–7. A dimensão reduzida continua 4, e a concentração fica na mesma meta-análise.
2. **Passo 2, nas 26:** se o passo 1 não bastar, a `argvar` vira ns com nós p50/p90 **nas 26** concentrações daquela análise (3 coeficientes reduzidos).
   - Declarar que, nessa análise, o principal coincide com a S2.
   - Se ainda falhar numa concentração, ela sai da 2ª etapa dessa análise (§5, critério 4), e o texto diz qual e por quê.
3. **Vale por análise:** principal, cada sensibilidade (inclusive a chave 3 do PIG) e cada curva.
   - Se o passo 2 disparar numa sensibilidade-chave, ela passa a diferir do principal em duas coisas, e o critério de concordância da §9.2 fica confundido. Declarar.
4. **Dependência dos dados:** a convergência não depende da estimativa do efeito, mas depende dos dados do desfecho. Por isso o *fallback* é registrado como desvio quando dispara.
5. **Fecha a pendência herdada da D2** (opção (a), refinada pelo passo 1).
6. **A1 e A2:** se as 26 convergiram nas análises já feitas, nada muda.

---

## Registro no log do Artigo 3 (commit próprio, antes de rodar)

> ### Desvios ⟨n⟩ a ⟨n+6⟩ — respostas do chat de métodos (D7)
> - **Data do registro:** ⟨data⟩. **Nenhum resultado visto** (só C5 e diagnósticos).
> - **Decisão de origem:** `spec/decisoes_metodo_20261013_D7_respostas_A3.md` (SHA-256 ⟨conferido⟩).
> - **M1:**
>   - `vcov` principal = sanduíche **HC0** por ano × mês de `dum_est`, com G/(G − 1) (`type = "HC0"` explícito);
>   - sensibilidades: por ano × trimestre, por `dum_est` e do modelo (entram na lista fechada);
>   - diagnóstico de ACF dos resíduos (lags 1–90) e razão de EP trimestre/mês, descritivos;
>   - reajuste às cegas com teste de coeficientes idênticos;
>   - frase de Methods com a cobertura parcial;
>   - desvio da §2.2 e da §6; **toca o primário (IC, Ψ, BLUP, MRT)**;
>   - aprovação de Guilherme em 13/10.
> - **M2:** +0/+6 só na classificação; Methods declara o alinhamento +3 em todas as curvas.
> - **M3:**
>   - C1, C3 e D1 estendidos;
>   - extremos pela distribuição semanal (leitura i);
>   - contribuições negativas declaradas;
>   - diferença total − (calor + frio) reportada;
>   - texto da D5 adaptado (M3.3);
>   - P1 (Wald) pré-especificado, no suplemento.
> - **M4:**
>   - (a) e (c) como propostos;
>   - (b) com `quantile(..., type = 7)` no eixo combinado e na concentração;
>   - (d) com o centro na MRT BLUP da concentração e, na combinada, a MRT combinada em °C com a base da D2.
> - **M5:** condições 1–4; tabela dos desvios 71–77 e 81–91.
> - **M6:** itens 1–6 confirmados; teste unitário dos estratos do item 6.
> - **M7:** *fallback* em dois passos (`arglag` por concentração; `argvar` nas 26).
> - **Aprovação:** Guilherme, ⟨data⟩.

**Log do A1 e do A2:** uma linha remetendo ao M7 (*fallback* em dois passos).

---

## Auditoria

### Reproduções do chat de métodos

| Ponto | Reprodução | Resultado |
|---|---|---|
| M1: risco do agrupamento por `dum_est` com fator comum lento | `sanduiche_pig.py` | Cobertura de 0,78 por `dum_est` contra 0,92 por ano × mês (φ = 0,97, sem componente interanual) |
| M1: fator G/(G − 1) com G = 156 | Conta | 1,0065 (EP × 1,0032) |
| M6.4: data | Python (`datetime`) | 2019-04-18 |
| M3 (i): `range` elemento a elemento numa matriz | `attrdl.R`, l. 58 | Confirmado |

### Auditoria independente (subagente em contexto limpo; nenhum achado aceito sem reprodução)

O auditor confirmou com simulação própria (1.000 réplicas) que o agrupamento por ano × mês supera o por `dum_est`. Confirmou também, por código, a equivalência entre a sanduíche HC0 em células e a individual, a janela de 196 a 258 dias, a data de 2019-04-18 e o `range` elemento a elemento. Não houve achado crítico.

| # | Grav. | Achado | Reprodução pelo chat de métodos | Correção |
|---|---|---|---|---|
| 1 | Maior | O ano × mês cobre só parcialmente quando a correlação atravessa o mês (0,83 a 0,87); o 0,92 dependia da temperatura sem componente interanual | `repro_aud8.py`: φ = 0,995 com componente interanual, cobertura de 0,747 (ano × mês) e 0,673 (`dum_est`) | M1.1 reescrito; ano × trimestre como sensibilidade; diagnóstico de ACF; chave 3 nomeada como defesa principal; opção registrada |
| 2 | Maior | A frase de Methods atribuía a correlação à sobreposição das janelas; "calendar month" era ambíguo | Releitura | Frase reescrita ("year-month ... 156 clusters"; a sobreposição amplifica) |
| 3 | Maior | O M7 contrariava o *fallback* por concentração da §3.3 e da §5; "não depende de resultado" estava forte demais; a chave 3 ficaria confundida | `crossreduce.R`, l. 89–91: a dimensão vem da `argvar` | M7 em dois passos; dependência dos dados declarada; confundimento declarado |
| 4 | Maior | O registro dizia "(d) como proposto" e omitia itens | Releitura | Registro corrigido e completado |
| 5 | Menor | "Tende a viés positivo" não foi verificado; a razão das contribuições negativas estava incompleta | Aceito: a MRT minimiza a curva cumulativa, não cada semana | M3.2 (ii) e M3.3 ("may be biased upward") |
| 6 | Menor | A simulação usa a CR1 do statsmodels, não HC0 + G/(G − 1) | Aceito (~0,5% na variância) | Limitação declarada no M1.1 |
| 7 | Menor | Faltavam o lugar do P1, a exclusão da concordância e os gl conforme a dimensão | Aceito | M3.3 |
| 8 | Menor | O M4 (b) chamava a regra de "exata"; o eixo combinado também precisa de `type = 7` | Aceito | M4 (b) |
| — | Achado do auditor sem correção a fazer | HC1 quebra a equivalência entre células e modelo individual | Aceito pela teoria do fator (n − 1)/(n − k), que depende de n e difere entre células e indivíduos | `type = "HC0"` explícito no M1.2 |

## Scripts

| Arquivo | SHA-256 | O que faz |
|---|---|---|
| `sanduiche_pig.py` | `1b2e8f074f7fd3f5a6142a84b2feef4b434dca5c72b7cb61f1202c8f35492220` | M1: cobertura com `vcov` do modelo × sanduíche por `dum_est` × por ano × mês (semente 20261001) |
| `repro_aud8.py` | `53a416ce1bf7522b187cafb24402e34e139fe5e4ac80e62407a554e16ea02a51` | M1: fator lento que atravessa meses, com componente interanual (semente 20261002) |