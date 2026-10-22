# Decisões de método — 13/10/2026, D6: respostas ao Artigo 2 (offset por pessoa-dia, testes sem poder, curva combinada, γ)

**De:** chat de métodos (coordenação geral) · **Data:** 13/10/2026 · **Origem:** pedido do chat do Artigo 2 (13/10; Fase 2 no commit `9cf52fc`, base `4443971b`)
**Âmbito:** Artigos 1 e 2; o item 2 vale também para o Artigo 3.

**Relação com os outros documentos.**
- Complementa as decisões de 13/10 (`7b53150e…dc6f`), o complemento e a D5.
- **Ratifica um desvio** da especificação congelada na tag `spec-v2.0.2-congelada-20261009`: o desvio 50 do A2.
- Corrige a letra de dois testes: D1, item 2, e D2, teste 3.
- Fecha três lacunas de relato da curva combinada.
- Entra como arquivo novo em `spec/`.

**SHA-256 do complemento de 13/10** (para o campo do pedido): `189d9b2db6462d56cc2a7d2c35e75e3a4532a1c666c03632063fb408d5ff0936`.

---

## Resumo

| # | Pedido | Decisão | Bloqueia? |
|---|---|---|---|
| 1 | Ratificar o offset por pessoa-dia (desvio 50 do A2) e a frase de Methods | **Ratificado**, com duas emendas antes da Fase 3: a fórmula do w_j passa a dividir por PD_j (1.2, item 2), e as frases da §3.2 que dependem de "w_j quase plano" são revistas (1.2, item 4). A frase de Methods foi revisada | Liberado depois das duas emendas |
| 2 | Errata dos testes da D1 (item 2) e da D2 (teste 3) | **Aprovada**, com texto, controles negativos e versão por desfecho (item 2) | Não |
| 3 | Lacunas da curva combinada: (a) °C ↔ percentil; (b) Q, I² e Wald; (c) lag–resposta | **Aprovadas.** A (b) foi conferida no código-fonte do `mixmeta`. A conformidade da `segunda_etapa-v1.0` é conferida com auditoria independente (3.4) | Liberado depois da 3.4 |
| 4 | Regra única de γ sem o cenário de pico estreito | **Ok.** O pico estreito existe no script da coordenação e só **reduz** o EP; quem decide é o cosseno (2,32 ≥ 1) | Não |

---

## 1. Offset por pessoa-dia (desvio 50 do A2): ratificado

### 1.1 O defeito (reproduzido)

- **A pertença em Z_tj.** Pela §3.1, a gestação de início s está em Z_tj quando ⌊(t − s)/7⌋ = j **e** o término é ≥ t.
- **Por que 4 dias.** Com s = parto − (7·IG + 3), o parto cai no deslocamento 3 da semana IG. A gestação que termina na semana j fica em Z_tj 4 dos 7 dias; a que continua fica os 7.
- **O peso coerente com o offset diário é o risco por pessoa-dia:**
  - PD_j = 7·(N_j − T_j) + 4·T_j, com T_j = NV_j + F_j;
  - w_j^PD = D_j / PD_j.
  - Em relação ao peso por gestação (D_j / N_j), o fator é 7N_j / PD_j = 7/(7 − 3h_j), com h_j = T_j / N_j.
- **A soma fica exata, menos um termo de segunda ordem.** Com n_s constante dentro da semana, Σ_j Z_tj·w_j^PD é exatamente proporcional ao número esperado de óbitos no dia t. Sobra um termo de segunda ordem: o término fica centrado em 1,5 dia da pertença, e não em 3 (auditor).
- **Reproduções** (determinísticas, com concepções sazonais em cosseno de 10%):

| Fonte | Risco de óbito | DP intra-mês de log E_t − offset: por gestação / por pessoa-dia / só log Z_t | Razão máx/mín do w_j: gestação → pessoa-dia |
|---|---|---|---|
| A2 (pedido) | Dados | 0,00042 / 0,00002 / 0,00104 | 5,33 → 9,87 (dados) |
| Auditor | Forma da §3.2 | 0,00040 / 0,000016 / 0,00102 | 4,57 → 8,00 |
| Chat de métodos, `dp_logW.py` | Forma da §3.2 | — | 5,61 → 9,82 |
| Chat de métodos, `offset_pd.py` | Extremo (razão de 899), só mecanismo | 0,00051 / 0,00010 / 0,00946 | — |

- **Conferências:**
  - a álgebra do fator confere;
  - nas semanas 37 a 42, o fator vai de cerca de 1,05 a 1,75, e chega exatamente a 1,75 quando h_42 = 1;
  - o fator 7/(7 − 3h_j) vale para os pesos **brutos**; depois da suavização, a razão observada (9,87) pode passar o teto bruto (5,33 × 1,75 = 9,33).

### 1.2 Decisão

1. **Principal do A2:** offset log Σ_j Z_tj·w_j^PD, com γ = 1.
   - Ficam ratificadas a regra de γ refeita (EP de 2,32 ≥ 1, logo γ = 1), a sensibilidade-chave nº 5 (término por pessoa-dia, por concentração, γ estimado) e as versões por gestação como sensibilidades comuns.
2. **Emenda à fórmula da §3.2 (l. 220).** Fica `obitos_j ~ ns(j, df = 4) + offset(log(PD_j))` e **w_j^PD = valor ajustado ÷ PD_j**, e não "÷ N_j".
   - Lida ao pé da letra, a divisão por N_j voltaria ao peso por gestação e desfaria o desvio 50 em silêncio.
   - **Teste:** nos pesos brutos, w_j^PD / w_j^g = 7/(7 − 3h_j). O A2 confere no código da Fase 2 que a divisão é por PD_j.
3. **O estimando não muda.** Muda a especificação do offset no contraste primário; é desvio da v2.0.2, declarado como tal.
   - **Por que ratificar:** é a forma do número esperado (Huang) com a pertença que a própria base define, adotada antes de qualquer modelo de desfecho.
   - O fato de as primeiras etapas já terem rodado com esse offset **não** é o motivo.
4. **Frases da §3.2 que dependiam de "w_j quase plano":**

| Frase | Decisão |
|---|---|
| "Na prática, o principal equivale ao offset de gestações em risco" | **Cai** |
| "O risco de óbito varia pouco" (de 0,57 a 0,82 por mil) | **Cai** como argumento. O w_j^PD varia cerca de 10 vezes |
| "Mudar γ entre 0 e 2 altera o offset intra-estrato em valores da ordem de 10⁻³ pelo componente sazonal [...] e até ~10⁻² pelo ruído" | **Re-verificar nos dados.** O A2 reporta o DP intra-mês de log W_t^PD por concentração. Nas simulações, o componente sazonal sobe de 1,3 vez (chat de métodos: 0,0013 → 0,0018) a 1,6 vez (auditor). Continua na ordem de 10⁻³, mas o número do texto sai dos dados |
| `_24h`: "recalcular w_j para óbitos ≤ 24 h mudaria o offset em ~10⁻³" | **Cai.** O `obito_perinatal_24h` usa o w_j^PD recalculado com os óbitos ≤ 24 h, pela mesma suavização |

### 1.3 O que o chat de métodos não reproduziu

Os números nos dados reais (χ²/gl = 55,566; razão de 9,87; correlação de 0,65 a 0,93) dependem da base. Valem os do A2, auditados lá.

### 1.4 Frase de Methods (inglês americano), revisada

> The daily offset was the logarithm of a quantity proportional to the expected number of perinatal deaths given the gestational-week composition of ongoing pregnancies, log Σ_j Z_tj·w_j (γ fixed at 1), where w_j is the smoothed risk of perinatal death per pregnancy-day in gestational week j. Risks were expressed per pregnancy-day rather than per pregnancy because, under the dating convention used to define pregnancy start, a pregnancy ending in week j contributes 4 of the 7 days of that week to the pregnancies at risk (eMethods). Because w_j varied about 10-fold across weeks 22 to 42, the offset did not reduce to the log number of pregnancies at risk: within strata, their correlation ranged from 0.65 to 0.93 across urban concentrations (eTable X). Per-pregnancy weights were used in sensitivity analyses.

**O eMethods traz:**
- a fórmula de PD_j;
- o fator 7/(7 − 3h_j), bruto e depois da suavização;
- que até 1,75 vez da variação de cerca de 10 vezes vem da conversão para pessoa-dia, perto do termo.

### 1.5 Consequência para o Artigo 1

- **PTB (principal).** O fator é de 1,00017 (semana 22) a 1,0187 (semana 36): o auditor reproduziu com os w_j da especificação. Com γ estimado, a diferença é absorvida (inclinação de log W^PD sobre log W de 1,003; DP do resíduo ≤ 1,6 × 10⁻⁵). **Só declarar** no eMethods.
- **Termo precoce (37–38, sensibilidade comparativa, γ = 1).** O fator é de cerca de 1,05 e 1,14 (auditor, com IG de forma brasileira), mas o efeito no offset é desprezível: DP do resíduo de 6,5 × 10⁻⁵ contra 4,3 × 10⁻⁵.
  - Se ainda não rodou: pode usar pessoa-dia, coerente com o A2. Nesse caso, refazer a regra de γ (EP de cerca de 1,58, ainda ≥ 1, γ = 1).
  - Se já rodou: declarar o fator e manter.

### 1.6 Registro no log

**A2** (o desvio 50 já existe; acrescentar):

> - **Ratificação e emendas:** `spec/decisoes_metodo_20261013_D6_respostas_A2.md`, item 1 (SHA-256 ⟨conferido⟩).
>   - w_j^PD = ajustado ÷ PD_j; teste da razão 7/(7 − 3h_j) nos pesos brutos: ⟨resultado⟩.
>   - Caem as frases "na prática equivale ao offset de gestações em risco", "o risco de óbito varia pouco" e a do `_24h`; o `_24h` usa o w_j^PD recalculado.
>   - DP intra-mês de log W_t^PD por concentração reportado; frase sobre γ entre 0 e 2: ⟨valores⟩.
>   - Frase de Methods conforme o item 1.4.

**A1** (entrada nova):

> ### Desvio ⟨n⟩ — §3.1: declaração do peso por pessoa-dia
> - **Origem:** D6, item 1.5.
> - **PTB:** fator 7/(7 − 3h_j) de 1,0002 a 1,019 nas semanas 22–36; declarado no eMethods, sem refazer (γ estimado).
> - **Termo precoce:** ⟨pessoa-dia, com γ refeito / fator declarado⟩.
> - **Toca o contraste primário?** Não.
> - **Aprovação:** Guilherme, ⟨data⟩.

---

## 2. Errata dos testes sem poder (D1, item 2; D2, teste 3)

### 2.1 O defeito (conferido no código-fonte)

- **gnm 1.1-5:**
  - `summary.gnm` tira `cov.scaled` do próprio `vcov(object, dispersion = dispersion, ...)` (l. 27) e guarda a dispersão do `vcov` (l. 85);
  - `vcov.gnm` estima a dispersão como `sum(weights * residuals^2) / df.residual` (l. 28–29) e devolve dispersão × `cov.unscaled` (l. 76);
  - o teste `vcov(m) == summary(m)$cov.scaled` é tautológico.
- **dlnm 2.4.10:** o `crossreduce` reconstrói a base com a mesma `attr(cb, "argvar")` (l. 92–110).
  - Confirmei que a cópia lida é igual, salvo o fim de linha, ao `crossreduce.R` do espelho `cran/dlnm`, tag 2.4.10.
- O A2 reproduziu o mesmo nos scripts `40` e `47`.

### 2.2 Texto da errata

**D1, item 2 (teste), passa a ser:**
> Teste da dispersão:
> (i) `phi_P <- sum(residuals(m, type = "pearson")^2) / df.residual(m)`, calculado à parte, coincide com `summary(m)$dispersion`, com tolerância relativa de 1e-6;
> (ii) os estratos sem evento foram removidos: `all(tapply(y, estrato, sum) > 0)`, e `df.residual(m) == n − n_estratos − p`.
> **Controle negativo:** o mesmo modelo com `family = poisson`, em dados sintéticos com superdispersão (φ verdadeiro ≈ 2), tem de **falhar** em (i), porque na Poisson a dispersão é fixada em 1. Uma cópia com os estratos vazios mantidos tem de **falhar** em (ii).
>
> A comparação `vcov(m)` = φ·`vcov(m, dispersion = 1)` foi retirada: pelo `vcov.gnm` (l. 76) e pelo `summary.gnm` (l. 85), ela vale se e só se (i) vale.

**D2, teste 3, passa a ser (versão por desfecho):**
> A curva BLUP de cada concentração é prevista também com uma base de **fonte independente** da `argvar`, centrada na mesma `cen` (`crossreduce`, l. 93–95):
> `splines::ns(x, knots = quantile(serie_nos, probs_nos, type = 7), Boundary.knots = range(x_cb), intercept = FALSE)`, e, na S1, `splines::bs(..., degree = 2)`, com os mesmos argumentos.
>
> | Análise | `serie_nos` (relida da base) | `probs_nos` | `x_cb` |
> |---|---|---|---|
> | Agudos, principal | `tmean_nucleo` diária de 2012-01-01 a 2024-12-31 | p10/p75/p90 | Série da janela mais L dias de aquecimento (L = 7) |
> | Agudos, lag 0–14 e 0–21 | Idem | Idem | Janela mais L = 14 ou 21 dias |
> | Agudos, S2 / estação quente / `tmean_mun` / Tmax, Tmin, AT | A série de exposição da sensibilidade (estação quente: só novembro a março) | p50/p90 (S2) ou p10/p75/p90 | Janela mais L dias da mesma série |
> | PIG | Médias de 7 dias alinhadas em `dum_est`, datas únicas de 2011-04-17 a 2024-03-05 (§1.2) | p10/p75/p90 | Todos os valores da matriz `s01`…`s37` passada ao `crossbasis` (`crossbasis.R`, l. 31: `as.numeric(x)`) |
>
> As duas predições coincidem até 1e-8.
> **Controle negativo:** com os `Boundary.knots` trocados (por exemplo, pela amplitude da grade p1–p99), o teste tem de **falhar**.
>
> **Decisão registrada:** os `Boundary.knots` de toda cross-basis são a amplitude do `x` efetivamente passado ao `crossbasis`. É o comportamento padrão do dlnm, que a §1.5 deixava implícito.

**Os outros testes:**
- Os testes 1 e 2 da D2 já comparam com fonte independente e continuam.
- O teste da D5 (menor contribuição diária ≥ −10⁻⁸) confere que a busca da MRT e a `attrdl` usam **a mesma** base, não que ela está certa. Isso é o papel do novo teste 3. Os dois ficam.

**Alcance:**
- Vale para A1, A2, A3 e para o `codigo_compartilhado/`.
- Os testes entram antes do uso pelo A2. Se a `segunda_etapa-v1.0` já tem tag, entram numa versão `v1.0.1`, só de testes.

---

## 3. Lacunas da curva combinada (A1 e A2)

### 3.1 (a) °C ↔ percentil: aprovado

- **Percentil da TMR/TMM combinada:** interpolação linear do °C no eixo médio (101 pontos: p1 a p99, mais p2,5 e p97,5), **ordenado por percentil** antes de interpolar.
  - Use `approx`, que ordena sozinho. Com `findInterval` ou `np.interp`, ordene antes.
  - A TMR/TMM combinada sai da grade entre o x1 e o x99 combinados, então o percentil fica em [1, 99].
- **°C da concentração nesse percentil:** `quantile(tmean_ref, pct/100, type = 7)`.
- **Toca:** o rótulo de percentil e o centro da lag–resposta (C3(b)). **Não toca** o RR em x99.

### 3.2 (b) Q, I² e Wald: aprovado e conferido no código-fonte

- **O que o código faz (`mixmeta` 1.2.0):**
  - o `summary.mixmeta` (l. 56–57) usa o `qtest`, que refaz o GLS de efeitos fixos com **a mesma matriz X**, incluindo os metapreditores (`qtest`, l. 43);
  - o I² é `pmax((Q − df)/Q·100, 0)`;
  - logo, o Q e o I² do modelo com metapreditores são **residuais**.
- **Graus de liberdade:**
  - global multivariado: `nall − fixed` = 104 − 12 = **92** com os dois metapreditores;
  - modelo só com intercepto: 100.
- **Reportar:**
  - Q e I² globais residuais (modelo com metapreditores);
  - Q e I² do modelo só com intercepto, rotulados "sem metapreditores";
  - no suplemento, os Q por coeficiente. Estes usam só a diagonal de S e os coeficientes do GLS multivariado, com 23 gl, e são rotulados "por coeficiente (não univariado)".
- **Wald dos metapreditores:** um por metapreditor, com **4 gl**, como a `fwald` do MCC 2015 (`02.secondstage.R`, l. 35–46). Na implementação, os coeficientes são selecionados por expressão regular exata, com `stopifnot(length(ind) == 4)`: a `fwald` original usa `grep` de substring.
- **Toca:** só o que se reporta.

### 3.3 (c) Lag–resposta combinada: aprovado

Os mesmos metapreditores, com predição na média e a mesma sequência de estabilidade e de falha da §6.

### 3.4 Conformidade da `segunda_etapa-v1.0`

O chat do A1 confere as três regras contra a `segunda_etapa-v1.0`, citando a linha de cada uma, **com auditoria independente** (subagente em contexto limpo), conforme a regra do projeto.
- **Se coincidir:** o A2 segue.
- **Se divergir:**
  - o código é corrigido (`v1.0.1`) antes da Fase 3 do A2;
  - o A1 refaz só as saídas afetadas (rótulo de percentil, Q e I², lag–resposta), com registro;
  - nenhuma dessas saídas mexe no RR em x99.

---

## 4. Regra única de γ: ok, sem trabalho novo

- **A letra da §3.2:** γ = 1 quando o EP aproximado "é ≥ 1 em algum dos dois cenários".
- **O pico estreito está parametrizado,** só que no script da coordenação, e não no texto da especificação. Em `repro_b3_extra.py` (SHA-256 `e9ec3f17…85f0`), as concepções seguem:
  `1 + 0,10·sin(2πs/365,25) + 0,05·sin(4πs/365,25) + 0,08·exp(−½·((s mod 365,25 − 75)/6)²)`
  - O Anexo B.3 (C3) traz o resultado para o termo precoce: EP de 0,29 (pico estreito) contra 1,68 (cosseno).
- **Nos cálculos feitos, o pico estreito só reduziu o EP,** porque acrescenta variação intra-mês a log W_t (termo precoce: 0,29 contra 1,68; simulação do auditor no perinatal). Então, na prática, quem decide é o cosseno.
  - No A2, o cosseno dá EP = 2,32 com o offset por pessoa-dia, logo γ = 1.
  - O cenário do pico pode ser rodado com a fórmula acima, só para o eMethods.
- **EP com o Z observado (1,54 a 4,46):** descrever no eMethods. Não entra na regra, que usa Z liso.
- **Registro:** o desvio 57 do A2 cobre; acrescentar a remissão a este item.

---

## 5. Auditoria

### 5.1 Reproduções do chat de métodos

| Afirmação do A2 | Reprodução | Resultado |
|---|---|---|
| 4 de 7 dias; fator 7/(7 − 3h_j), de 1,05 a 1,75 nas semanas 37–42 | Álgebra; `offset_pd.py` | Confirmado |
| Pessoa-dia < gestação < só Z_t no DP intra-mês; razão do w_j ≈ 5,3 → 9,9 | `offset_pd.py` (mecanismo); `dp_logW.py` (forma da §3.2: razão de 5,61 → 9,82) | Confirmado |
| `summary.gnm` tira `cov.scaled` do `vcov` | `summary.gnm.R`, l. 27 e 85; `vcov.gnm.R`, l. 20–31 e 76 | Confirmado |
| O `crossreduce` usa a mesma `argvar` | `crossreduce.R` (igual ao da 2.4.10), l. 92–110 | Confirmado |
| O comportamento do `summary.mixmeta` não estava conferido | `summary.mixmeta.R`, `qtest.mixmeta.R` | Conferido: Q e I² residuais |
| O pico estreito não está parametrizado | `repro_b3_extra.py`; Anexo B.3, C3 | **Em parte:** falta no texto da especificação, mas está no script; não muda nada |

### 5.2 Auditoria independente (subagente em contexto limpo; nenhum achado aceito sem reprodução)

O auditor confirmou o peso por pessoa-dia por derivação e com simulação própria, que reproduziu os números do A2. Também confirmou os SHA e as linhas citadas. Não houve achado crítico.

| # | Grav. | Achado | Reprodução pelo chat de métodos | Correção |
|---|---|---|---|---|
| 1 | Maior | A §3.2 (l. 220) mantinha "w_j = ajustado ÷ N_j", o que desfaria o desvio 50 | Lida a l. 220; álgebra | 1.2, item 2 |
| 2 | Maior | Outras frases dependiam de "w_j quase plano" (γ entre 0 e 2; `_24h`) | `dp_logW.py`: o DP sazonal de log W_t sobe 1,3 vez (o auditor achou 1,6 vez) | 1.2, item 4 |
| 3 | Maior | O novo teste 3 não servia ao PIG nem às sensibilidades de lag; fronteira implícita | §1.2, §1.5; `crossbasis.R`, l. 31 | Teste por desfecho; fronteira registrada como decisão |
| 4 | Menor | No teste da D1, (ii) era redundante e nada detectava estratos vazios | `vcov.gnm`, l. 76; `summary.gnm`, l. 85 | Novo (ii) para os estratos e gl; tolerância relativa |
| 5 | Menor | `offset_pd.py` usa um risco extremo (razão de 899) | Rodado: confirmado | Reprodução principal trocada por `dp_logW.py`; `offset_pd.py` fica só como mecanismo |
| 6 | Menor | O fator 7/(7 − 3h) vale para os pesos brutos | Álgebra | 1.1 e eMethods |
| 7 | Menor | Termo precoce: o fator foi de 1,05 e 1,14 com IG de forma brasileira; efeito desprezível | Aceito; meu exemplo deu 1,05 e 1,11 | 1.5 |
| 8 | Menor | O pico estreito existe e só reduz o EP; a frase "só importaria se o cosseno < 1" estava errada | `repro_b3_extra.py`; Anexo B.3, C3 | Item 4 reescrito |
| 9 | Menor | "Expected number" só vale até uma constante | Aceito: o nível se cancela nos estratos | "proportional to the expected number" |
| 10 | Menor | gl do Q e rótulo dos Q por coeficiente | `qtest.mixmeta.R` | 3.2 |
| 11 | Menor | A `fwald` usa `grep` de substring | `02.secondstage.R`, l. 36 | Regex exata e `length(ind) == 4` |
| 12 | Menor | O eixo precisa estar ordenado para interpolar | Aceito | 3.1 |
| 13 | Menor | O A1 conferindo o próprio código não é auditoria independente | Regra do projeto | 3.4 |
| 14 | Menor | Faltavam SHA de fontes; a versão do `crossreduce` não estava comprovada | Comparado com o espelho `cran/dlnm` 2.4.10: idêntico salvo o fim de linha | Seção 6 |

---

## 6. Scripts e fontes

| Arquivo | SHA-256 | O que é |
|---|---|---|
| `dp_logW.py` | `bf264005cc4a211f1bbe92cd3907b061a825bf0b8d67e75aa8e4b77f7466b31e` | Item 1: razão do w_j e DP de log W_t com a forma de risco da §3.2 |
| `offset_pd.py` | `40f2389201cf7465448b14b70646145be37c0ab9facb97540bedaa39e1e43940` | Item 1: mecanismo (risco extremo) |
| `repro_b3_extra.py` | `e9ec3f171eaa4c6ddeeeb446bb5ffb0e0a12a46a6233c8b13f0d33fef68b85f0` | Item 4: cenários cosseno e pico estreito (3ª auditoria, 07/10) |
| `summary.gnm.R` / `vcov.gnm.R` (gnm 1.1-5) | `cc0123c2bce8a461cf461760e60994ae1a1ba42f8e101c3f26fd0623e4f99afc` / `369fed8e9b6e184359843d3ae42d436ce7265fd70001a0187304bee8b524750e` | Item 2 |
| `crossreduce.R` / `crossbasis.R` (dlnm 2.4.10, espelho `cran/dlnm`) | `e736cdfa415bc474868a2a9a9e73bd097055ed5133a2b09cd40cd4894f4a7616` / `7ca061f3c8b27f6f5e1d52f1ded3ee816afa065e941a2cca1acd9c6ad2b858a1` | Item 2. A cópia local com fim de linha CRLF tem SHA `0580eb60…66ed`, com o mesmo conteúdo |
| `summary.mixmeta.R` / `qtest.mixmeta.R` / `print.summary.mixmeta.R` (mixmeta 1.2.0) | `8516567d6fb99583c5589b5f58ab66b48e6297eac72c5cda4887467ff7eca596` / `3395fb81596bd6526a95ec021b7fdee2ee5e0ce2c2c0ef7d4e05871dde05f959` / `45582e77835716e000a2733985186a39957f07b45013d4afbdb1ced87f0492fc` | Item 3(b) |
| `02.secondstage.R` (MCC 2015) | `23f5a5eedc10b1929300c3c99097e4707feac5b2f985a402d63c633fda9b7bba` | Item 3(b): `fwald` |
