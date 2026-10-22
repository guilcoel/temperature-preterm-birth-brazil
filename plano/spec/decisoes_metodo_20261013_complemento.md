# Decisões de método — 13/10/2026, complemento (semente das simulações, série consecutiva e regras operacionais dos agudos)

**De:** chat de métodos (coordenação geral) · **Data:** 13/10/2026 · **Origem:** pedido do chat do Artigo 1 (13/10), depois da auditoria independente do prompt da Fase 3 (v1.1, SHA-256 `953f14d929587851665f6cba0793e2d5b7d36dd5b17bc67d523cfa766a0cb864`)
**Âmbito:** Artigos 1 e 2 (desenho agudo) e o código `codigo_compartilhado/` com a tag `segunda_etapa-v1.0`.

**Relação com os outros documentos.** Este texto complementa `decisoes_metodo_20261013.md` (SHA-256 `7b53150e539e10e43b4f71fe232ad9c2ef2ec2b254f6730f1fbf0ee9e523dc6f`) e **substitui** três pontos:
- D1, item 4: "`set.seed(20261001)` imediatamente antes de cada chamada da `attrdl`";
- D3, item 2: a semente da nula da PACF recentrada;
- regra D4(a) do Artigo 1: a semente do bootstrap da TMR.

Não altera os arquivos congelados. A frase-modelo da §8 (l. 507) tem de ser ajustada, porque cita uma semente única (seção C1). O texto entra como arquivo novo em `spec/decisoes_metodo_20261013_complemento.md`, num commit comum, com o SHA-256 conferido.

---

## C1. Semente das simulações por concentração (corrige a D1, item 4)

**Defeito (reproduzido).** A culpa é da redação da D1, que adotou uma sugestão de auditoria sem medir o efeito entre concentrações.
- A `attrdl` sorteia `X <- matrix(rnorm(length(coef)*nsim), nsim)` e monta `coefsim <- coef + eigen$vectors %*% diag(sqrt(eigen$values), k) %*% t(X)` (l. 161–164).
- Com a mesma semente antes de toda chamada, as 26 concentrações recebem a mesma `X`. As simulações ficam dependentes de um jeito que muda com o sinal dos autovetores, que é arbitrário.
- O eCI do total, que soma as simulações das 26 como no MCC 2015, fica **inválido, em direção imprevisível**.
- O `03.attr.R` do MCC 2015 não chama `set.seed` dentro do laço das cidades (l. 42).

**Simulações (dados sintéticos; mostram o mecanismo, não o tamanho do efeito no estudo):** a razão entre a largura do eCI com a `X` comum e com sorteios independentes variou conforme o padrão de sinais dos autovetores.

| Reprodução | Razão de largura (`X` comum / independente) |
|---|---|
| Chat de métodos | 0,80 a 2,10 |
| Auditor | 0,62 a 1,23 |

O intervalo pode alargar ou **estreitar**; estreitar é o pior caso.

**Decisão (aprova a proposta D4(f) do Artigo 1, com três acréscimos):**
1. **Regra:** imediatamente antes de cada chamada da `attrdl` da concentração *i*:
   `set.seed(20261001 + i, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")`
   - *i* é a posição da concentração na ordem gravada (item 2), de 1 a 26.
   - A semente é a mesma nos cinco componentes (total, calor, frio, calor extremo e frio extremo) e nas três análises (principal, ponte e *backward*).
   - Entre concentrações, os sorteios são independentes. O auditor emulou o gerador do R para as 26 sementes adjacentes: o maior |r| entre os fluxos foi 0,055, compatível com o acaso em 325 pares, e nenhum fluxo se sobrepôs a outro em 20.000 sorteios.
2. ***i* fixo e ordem travada no código:**
   - A ordem das 26 é gravada como vetor literal no código compartilhado e no log, igual nos dois artigos.
   - O código confere `stopifnot(identical(cidade_nucleo(), ordem_gravada))` e nunca ordena com `sort()`: a ordem alfabética muda com o *locale* ("Belém" × "Belo Horizonte").
   - Num subconjunto (corte de 2.000 eventos, PM2.5 etc.), cada concentração mantém o seu *i*.
3. **Gerador explícito:**
   - O `kind` na própria chamada garante o mesmo gerador em execução serial ou paralela.
   - Sem ele, um processo filho com o `RNGkind("L'Ecuyer-CMRG")` da §8 (l. 491) geraria outros números.
   - **Teste:** a execução serial e a paralela dão resultados idênticos.
   - É desvio da §8, registrado na C4.
4. **Regra única para toda simulação feita por concentração, obrigatória antes da tag `segunda_etapa-v1.0`:** a mesma chamada, com 20261001 + *i*, vale também para:
   - o bootstrap da TMR (D4(a));
   - a nula da PACF recentrada (D3).
   Toda simulação da curva combinada usa 20261001, com o mesmo `kind`.
   - O código compartilhado tem uma única versão, que o Artigo 2 herda; por isso a regra não fica como opcional.
   - Como muda a semente da D4(a), já aprovada por Guilherme, entra no mesmo ok.
5. **Aditividade:**
   - No *forward* (principal e ponte), cada dia tem um único valor de exposição, que fica de um lado da TMR. Com os mesmos sorteios, calor + frio = total em cada simulação (diferença ≤ 2 × 10⁻¹², nas duas reproduções). **Teste no código.**
   - No *backward*, **não** há aditividade. A l. 58 troca cada lag pela `cen`, então o preditor linear se soma, mas AF = 1 − e^(−η) não é linear. Num dia com lags dos dois lados da TMR, AF_total = AF_calor + AF_frio − AF_calor·AF_frio.
   - No *backward*, reportar a diferença total − (calor + frio), sem teste de aditividade.

**Frases para Methods (inglês americano):**
> Monte Carlo samples for the empirical confidence intervals were drawn with a concentration-specific seed, so that samples were independent across urban concentrations and shared across the total and the heat, cold, extreme-heat, and extreme-cold components within each concentration.

Na frase-modelo da §8, "all stochastic procedures used a fixed seed (20261001)" passa a: "all stochastic procedures used fixed seeds (20261001 for pooled quantities and 20261001 + i for the i-th urban concentration)."

---

## C2. Série diária completa e consecutiva (vale para a cross-basis, a D3 e a `attrdl`)

**Problema (reproduzido):**
- O `crossbasis` defasa por posição no vetor (`crossbasis.R`, l. 64: `Lag(basisvar[, v], seqlag(lag), group = group)`). A `attrdl` faz o mesmo (`tsModel:::Lag`, l. 65 e 87).
- A §2.1 remove os estratos sem evento **antes do ajuste**. Se qualquer defasagem for calculada sobre o subconjunto já sem esses dias, os lags pulam dias sem erro nem aviso.
- Exemplo: com fevereiro de 2012 removido, o lag 1 de 2012-03-01 devolve 2012-01-31, e não 2012-02-29.
- No Artigo 1 (PTB), provavelmente não há estrato vazio. No Artigo 2 (óbito perinatal) haverá muitos.
- **Isto atinge o contraste primário** se a cross-basis for calculada depois do corte.

**Decisão:**
1. **A cross-basis** é calculada na série diária completa e consecutiva de cada concentração, com os dias de aquecimento da §1.5. Só depois saem as linhas dos estratos sem evento (e os dias de aquecimento) do ajuste.
2. **Os resíduos defasados da D3** são construídos na série completa:
   - o resíduo dos dias fora do ajuste é 0, e a defasagem é feita sobre a série completa;
   - só depois o subconjunto é tirado.
3. **A PACF da D3** (literal e recentrada) é calculada sobre a série completa, com 0 nos dias fora do ajuste. A nula usa a mesma estrutura.
4. **A `attrdl`** recebe `x` e `cases` como série completa e consecutiva da janela:
   - os dias dos estratos removidos entram com a temperatura real e os eventos reais (zero);
   - no *backward*, `x` inclui os 7 dias de aquecimento, com **`cases` = NA nesses 7 dias** (D1, item 2). Se entrarem os eventos reais, o total (`den`, l. 85) passa a incluir dias de fora da janela.
5. **Testes:**
   - em cada concentração, a coluna do lag 1 da exposição é igual à exposição da data − 1, inclusive no primeiro dia depois de um estrato removido;
   - `length(x)` é igual ao número de dias da janela (mais 7 no *backward*), com datas consecutivas;
   - no *backward*, `all(is.na(cases[1:7]))`.
6. **Antes da tag:** o chat do Artigo 1 confere se o código da Fase 2 já calcula a cross-basis na série completa. Se não calcular, a correção é obrigatória e é registrada.

---

## C3. Regras operacionais dos agudos (D4 do Artigo 1): valem para o Artigo 2

| Regra | Conferência | Vale para o Artigo 2? |
|---|---|---|
| **(a)** IC da TMR | Coerente com o "bootstrap paramétrico" da §7. A regra: 1.000 sorteios por Cholesky; percentis 2,5 e 97,5; vcov não positiva-definida dá IC NA, com o motivo; os IC dos RR tratam a TMR como fixa (limitação, como no MCC). A semente segue a C1, item 4 | Sim (TMM) |
| **(b)** Lag–resposta combinada: `crossreduce(type = "var", model.link = "log")` no p99 e no p1, com centro no °C da concentração no percentil da TMR combinada; se a TMR combinada cair em x1 ou x99, o centro passa ao p50 | Conferido no `crossreduce.R` (l. 105–112): com `value` igual a `cen`, a base centrada é zero, e os coeficientes e a vcov saem identicamente 0. A troca vale **para os dois lados** (p99 e p1), para manter um único centro; quando disparar, o estimando passa a ser RR(x × p50) por lag nos dois lados, e o texto declara. A fronteira é detectada pelo **índice** do mínimo na grade (`which.min(...) %in% c(1, length(grade))`), nunca por `==` em °C. Antes do `mixmeta`, o código confere `max(abs(coef)) > 1e-10` | Sim; a fronteira é mais provável no óbito perinatal |
| **(g)** O `cen` da `attrdl` é sempre a TMR da grade p1–p99; a busca entre p10 e p90 e o contraste contra a mediana são só para reportar | Coerente com a §7 | Sim |
| **(h)** Componentes: calor `c(TMR, Inf)`, frio `c(-Inf, TMR)`, calor extremo `c(max(p97,5, TMR), Inf)`, frio extremo `c(-Inf, min(p2,5, TMR))` | Conferido: a `attrdl` troca pela `cen` o que cai fora do `range` (l. 58). **A regra está certa, mas a justificativa muda** (abaixo) | Sim |
| **(i)** Grade da TMR | **Ajustada.** `unique()` não tira duplicatas quase iguais: `seq(20.4, 30.3, 0.1)` termina em 30,299999999999997, e `unique(c(..., 30.3))` mantém os dois pontos (reproduzido). Nova regra: `g <- seq(x_inf, x_sup, by = 0.1); if (x_sup - g[length(g)] > 1e-8) g <- c(g, x_sup)` | Sim |
| **(d)** Sigilo: o número atribuível é estimativa do modelo, arredondada ao inteiro, sem a máscara "<10" | Concordo. Não é contagem de pessoas, e o denominador recuperável (AN/AF = eventos da janela inteira por concentração) é mais grosso que concentração × ano | Sim. Componentes extremos com AN de um dígito continuam sendo estimativa, sem máscara |
| **Falha do `mixmeta`:** erro capturado ou não convergência; Ψ não positiva-definida só é reportada | Coerente com a §6. Implementar como `isFALSE(fit$converged)` ou erro capturado. `!isTRUE(...)` marcaria como falha um ajuste sem o campo `converged` (por exemplo, efeitos fixos); isso não foi conferido sem R | Sim; a sequência (Ψ diagonal, depois ML) é mais provável no perinatal |

**Justificativa corrigida da regra (h):**
- No principal, a `cen` é o mínimo da curva BLUP na grade p1–p99. Os dias abaixo da TMR, dentro dessa faixa, têm RR ≥ 1 (até a resolução da grade) e contribuição **não negativa**.
- Sem o `max` e o `min`, o problema é de **classificação**: com TMR > p97,5, o "calor extremo" incluiria dias do lado frio. Ele deixaria de estar contido no calor e se sobreporia ao frio.
- Contribuições negativas aparecem de fato na ponte e no *backward* e, no principal, só fora do p1–p99. Isso já está nas limitações da D1.

---

## C4. Registro no log de desvios

**Artigo 1:** acrescentar ao final do log, antes da tag `segunda_etapa-v1.0`:

> ### Desvio ⟨n+3⟩ — complemento dos desvios ⟨n⟩ (§7) e ⟨n+2⟩ (§2.1), e da §8: sementes, série consecutiva e regras operacionais
> - **Data do registro:** 13/10/2026, antes de rodar.
> - **Decisão de origem:** `spec/decisoes_metodo_20261013_complemento.md`, C1 a C3 (SHA-256 ⟨conferido⟩).
> - **Sementes:**
>   - toda simulação por concentração (a `attrdl` nos cinco componentes e nas três análises, o bootstrap da TMR e a nula da PACF) usa `set.seed(20261001 + i, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")`;
>   - as simulações da curva combinada usam 20261001, com o mesmo `kind`;
>   - a ordem das 26 fica travada (lista abaixo), e o teste confere que a execução serial é igual à paralela;
>   - muda a §8 (semente única e L'Ecuyer no paralelo).
> - **Ordem das concentrações (i = 1…26):** ⟨lista literal⟩.
> - **Série consecutiva:** a cross-basis, os resíduos defasados e a PACF da D3, e a `x` e os `cases` da `attrdl` são calculados na série diária completa e consecutiva (com aquecimento). Os estratos sem evento saem só do ajuste. No *backward*, `cases` = NA nos 7 dias de aquecimento.
> - **Situação do código da Fase 2 quanto à cross-basis:** ⟨já calculava na série completa / corrigido, com o diff⟩.
> - **Regras operacionais D4 (a), (b), (g), (h), (i), (d) e falha do `mixmeta`:** conforme C3, com a grade (i) ajustada e a fronteira detectada pelo índice.
> - **Aditividade:** testada no *forward*; no *backward*, reportada como diferença.
> - **Toca o contraste primário?** Sim, só pela série consecutiva da cross-basis, que é verificação de implementação, sem mudança de estimando. O resto, não.
> - **Resultados vistos antes do registro:** ⟨nenhum / descrever⟩.
> - **Aprovação:** Guilherme, ⟨data⟩ (inclui a mudança de semente da D4(a)).

**Artigo 2:** na abertura da Fase 2, copiar as entradas de 13/10 e esta, com "Artigo: 2", a mesma ordem das 26 e "TMM" no lugar de "TMR". Na entrada da §7, a linha "igual nas três" passa a remeter à C1.

---

## 5. Auditoria

### 5.1 Reproduções do chat de métodos (pedido do Artigo 1)

| Afirmação do Artigo 1 | Reprodução | Resultado |
|---|---|---|
| A mesma semente dá a mesma `X` às 26 concentrações | `attrdl.R` (SHA-256 `d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d`), l. 161–164; `semente_attrdl.py` e `repro_aud.py` | Confirmado; o eCI do total muda de largura conforme o sinal dos autovetores (0,80 a 2,10 vez) |
| O MCC não reinicia a semente entre cidades | `03.attr.R`: sem `set.seed`; laço na l. 42 | Confirmado |
| A mesma semente preserva a aditividade dentro da concentração | `semente_attrdl.py`, `repro_aud.py` | Confirmado **só no *forward*** (achado do auditor, abaixo) |
| (b) Com o centro igual ao valor, os coeficientes saem 0 | `crossreduce.R`, l. 105–112 | Confirmado |
| (h) O `range` troca pela `cen` o que cai fora | `attrdl.R`, l. 58 | Confirmado; a justificativa foi corrigida |

### 5.2 Auditoria independente (subagente em contexto limpo; nenhum achado aceito sem reprodução)

O auditor confirmou os hashes, as linhas citadas, o defeito e a correção 20261001 + *i*, emulando o gerador do R (validado contra o R real em três sementes). Não houve achado crítico.

| # | Grav. | Achado | Reprodução pelo chat de métodos | Correção |
|---|---|---|---|---|
| 1 | Maior | `set.seed` no processo filho herda o L'Ecuyer da §8 (l. 491) e gera outros números | Lida a §8, l. 485 e 491 | C1, item 3: `kind` explícito; desvio da §8 |
| 2 | Maior | "Calor + frio = total" é falso no *backward* | `repro_aud.py`: diferença de 0,7 num AN de 1.504 no *backward*; 4,6 × 10⁻¹³ no *forward* | C1, item 5 |
| 3 | Maior | A defasagem por posição atinge a cross-basis e a D3, não só a `attrdl` | `crossbasis.R` l. 64; `repro_aud.py`: o lag 1 de 2012-03-01 devolve 2012-01-31 | C2 (nova seção) |
| 4 | Menor | Faltava `cases` = NA no aquecimento do *backward* | D1, item 2, conferido; l. 85 | C2, item 4 |
| 5 | Menor | Duplicata quase igual na grade (i) e detecção da fronteira por `==` | `repro_aud.py`: a grade termina em 30,299999999999997; diferença de 3,6 × 10⁻¹⁵ | C3 (i) e (b) |
| 6 | Menor | A regra (b) muda os dois lados | `crossreduce.R` l. 107–111 | Mantida e declarada (C3 (b)) |
| 7 | Menor | O *locale* pode mudar a ordem de `cidade_nucleo()` | Aceito por construção ("Belém" × "Belo Horizonte" no C e no pt_BR) | C1, item 2 |
| 8 | Menor | A `X` comum pode estreitar o eCI | `repro_aud.py`: razão mínima de 0,80 | C1, "Defeito" |
| 9 | Menor | "RR ≥ 1" só nos pontos da grade | Aceito | C3 (h) |
| 10 | Menor | Inconsistências: cabeçalho, frase da §8, semente opcional, contagem de acréscimos, frase de Methods | Releitura: confirmadas as cinco | Cabeçalho, C1 itens 4 e 5 e frases de Methods |
| 11 | Menor (não verificado) | `!isTRUE(converged)` marcaria os efeitos fixos como falha | Sem R; aceito como precaução | C3, falha do `mixmeta` |

### 5.3 O que não foi verificado

Não há R neste ambiente: nada foi executado em R. As afirmações sobre o código vêm da leitura das fontes e de emulação em Python. O auditor validou o gerador do R contra três sementes conhecidas.

---

## 6. Scripts do chat de métodos

| Arquivo | SHA-256 | O que faz |
|---|---|---|
| `semente_attrdl.py` | `88ecaa11e0d763fb0da9604f43b4a074fb0890ffc66b5ecfc148719991b60367` | C1: `X` comum × independente; aditividade no *forward* |
| `repro_aud.py` | `fb8ce0747814d2ad7cf3d70684e50abd9cda8ab2931d8484247f2729ca3de193` | Reprodução dos achados do auditor: aditividade no *backward*, grade, defasagem por posição, largura do eCI |
