# Decisões de método — 15/10/2026, D11: sensibilidades dos agudos (modelo, calendário, cross-basis, uma etapa, estação quente)

**De:** chat de métodos · **Data:** 15/10/2026 · **Origem:** consulta do chat do Artigo 1, v1.1 (15/10), seções 0, 2, 3, 5 e 6, sobre a solicitação v3 do Claude Code (SHA-256 `6e5a93ac219954ae6fcd2782124fb306cc7ff072295bb33414d46d84958f2b28`)
**Âmbito:** Artigos 1 e 2. Não se aplica ao A3, que tem decisões próprias: D7, M6.4 (sem 2020–21) e M6.5 (uma etapa); §3.3 (*fallback*).
**Ler junto com:** D10 (`…_TODOS_D10_…`) e D12 (`…_A1_D12_…`). A numeração dos itens segue a da consulta: as seções 1 e 7 estão na D10, e a 4, na D12.

**Rótulo:** todas as decisões são tomadas depois dos resultados das Fases 2 e 3 do A1 (ver o cabeçalho da D10) e das Fases 2 e 3 do A2. Cada item diz se é **esclarecimento de letra** ou **escolha *post hoc***. Nenhuma escolha foi feita para mover esses resultados, e a direção do efeito de cada escolha não é previsível a partir deles. **Exceção declarada:** na S3 (item 5.2), a referência comum é a TMR/TMM combinada do primário, ou seja, um resultado da Fase 3 entra como insumo da análise.

---

## Resumo

| # | Item | Decisão | Rótulo |
|---|---|---|---|
| 0 | Itens que o A1 deu como já respondidos | **Confirmados**, com um acréscimo no corte de 2.000 | — |
| 2 | *Fallback* na linha "Modelo" da §10.2 | **Regra, sem análise própria** (alternativa do A1). A proposta de rodar o passo 1 nas 26 é rejeitada | Esclarecimento de letra |
| 3.1 | Natal e Ano-Novo | **24/12 a 01/01, inclusive** (9 dias por período), só do ajuste | Esclarecimento de letra; os limites exatos são escolha |
| 3.2 | "Sem 2020–21" | **Dias de evento de 01/01/2020 a 31/12/2021 fora do ajuste**; cross-basis na série contínua | Esclarecimento de letra; a operacionalização pela data do evento é escolha |
| 3.3 | Feriados locais | **Tabela comum aos agudos**, preparada pelo A1, auditada uma vez e commitada pela coordenação em `codigo_compartilhado/dados_referencia/`; plano B **por data** | Esclarecimento de letra; plano B *post hoc* |
| 5.1 | `arglag` dos lags 0–4, 0–14 e 0–21 | **ns com intercepto e `logknots(L, nk = 2)`**, sempre 4 gl (proposta do A1) | Escolha *post hoc* (lacuna) |
| 5.2 | DLNM penalizado (S3) | **Proposta do A1, com `k`, base e penalidades fixados aqui**; no A2, o p1 não é estimável | Escolha *post hoc* (lacuna) |
| 5.3 | Uma etapa | **Proposta do A1, com a transformação em percentis fixada aqui** | Esclarecimento de letra |
| 5.4 | φ > 2 | **Só no principal**; nas sensibilidades, φ é só reportado; **sem regra própria** para a case time series municipal | Esclarecimento de letra |
| 6 | Estação quente | **TMR combinada em x1–x50 do eixo de nov–mar**; todos os percentis da §7 reportados; o x1 **não** é coprimário; borda sem busca extra | Esclarecimento de letra |

---

## 0. Confirmações (itens que o A1 deu como já respondidos)

| Item | Documento vigente | Confirmação |
|---|---|---|
| Semente da nula da PACF | Complemento, C1, item 4 (substitui a D3, item 2) | **Confirmado:** `20261001 + i`, com o `kind` explícito |
| Eixo próprio na chave 1 e eixo de nov–mar | D2, "Abrangência"; §1.1, l. 85 | **Confirmado** |
| TMR BLUP de nov–mar no p1–p50 | §7, l. 448 | **Confirmado** |
| Boundary.knots = `range` do `x` passado | D2, teste 2; D6, 2.2 (tabela de `x_cb`) | **Confirmado** |
| Item 10 da lista A | Solicitação v3 | Nada em aberto |
| Corte de 2.000 | §5, l. 404 | **Confirmado no A1:** uma linha no suplemento, "identical to the primary analysis; no urban concentration excluded". **No A2:** recontar na janela principal antes de rodar (§5, "Contagem na janela principal") e reportar quem saiu; a lista provisória da §5 é do período inteiro |

---

## 2. *Fallback* na linha "Modelo" da §10.2: regra, sem análise própria

- **Leitura:** a linha, como redigida pela D3 (D1-D3, seção 4), tem dois itens **condicionais** e um que roda sempre:
  - "binomial negativa **se** φ > 2": condicional;
  - "resíduos defasados nos lags 1 a 7, em todas as concentrações": **roda sempre** (D3). **A D11 não altera a D3;**
  - o *fallback*, que a §5 (critério 4) dispara **se** a convergência falhar: condicional.
  - Os dois condicionais estão na lista fechada porque, quando disparam, o resultado é reportado como sensibilidade.
- **Decisão:** o *fallback* é regra de convergência, nos dois passos da D7, M7. No A1, as 26 convergiram nas análises já feitas, e a linha não tem aplicação no principal. Ela volta a valer em cada sensibilidade em que alguma concentração não convergir (D7, M7.3).
- **Por que a proposta de rodar o passo 1 nas 26 fica de fora:**
  - seria uma sensibilidade nova, *post hoc*, criada depois de ver o primário;
  - a forma da lag–resposta já é testada pelas sensibilidades de lag (0–4, 0–14 e 0–21) e pelo DLNM penalizado (S3).
- **No A2:** o mesmo.

---

## 3. Calendário

### 3.1 Semana de Natal e Ano-Novo

- **Decisão: aprovada a proposta.** Saem do ajuste os dias de **24/12 a 01/01, inclusive**, em todos os períodos da janela principal.
  - São **12 períodos × 9 dias = 108 dias** (2,40% da janela do A1; 108 de 4.456 dias no A2). Conferido com código (seção A).
  - A série de exposição continua inteira (complemento, C2): a cross-basis e os lags são calculados na série consecutiva, e os dias saem só do ajuste.
  - Nenhum estrato fica vazio por isso: dezembro perde 8 dias, e janeiro perde 1.
- **Por que 24/12 entra:** a véspera de Natal é ponto facultativo e mexe com o agendamento de cesáreas, que é a razão desta sensibilidade. "Semana" é lida como o período festivo entre as duas datas, com as vésperas.
- **Rótulo:** esclarecimento de letra (§4, l. 380: "excluir a semana de Natal e Ano-Novo"; a §10.2 só abrevia). Os limites exatos (24/12 e 01/01) são escolha, feita sem nenhuma relação com os resultados.

### 3.2 "Sem 2020–21" nos agudos

- **Leitura:** a §4 (l. 381) põe "Excluir 2020–2021 (pandemia)" na coluna de sensibilidade, comum aos desenhos, e a §10.2 lista "sem 2020–21" no PTB e no óbito perinatal ("Idem"). A sensibilidade é **pré-especificada nos agudos**; só a operacionalização faltava.
- **Decisão: aprovada a proposta.** Saem do ajuste os **dias de evento de 01/01/2020 a 31/12/2021** (731 dias; 16,25% da janela do A1).
  - A cross-basis continua na série contínua (C2).
  - Os estratos de 2020 e 2021 caem por inteiro.
  - O offset não muda: Z_t e W_t dos outros dias continuam os do principal.
- **Diferença em relação ao PIG (declarar):**
  - no PIG, a D7, M6.4, recua pela janela de exposição (`dum_est` desde 2019-04-18), porque a exposição de 37 semanas atravessaria a pandemia;
  - nos agudos, o que se quer afastar é o choque nos **eventos**, como acesso ao parto, cesáreas e notificação, e não a exposição de 7 dias. Por isso a exclusão é pela data do evento.
- **Rótulo:** esclarecimento de letra; a operacionalização pela data do evento é escolha.

### 3.3 Feriados locais

- **Decisão: aprovada a proposta, com a tabela comum aos agudos.**
  - **Onde fica:** `codigo_compartilhado/dados_referencia/feriados_locais_nucleo_2011_2024.csv`, com um `README` que cita as fontes, no branch `comum` (D10, seção 2).
  - **Colunas:** concentração; cidade-núcleo; data; nome; esfera (estadual ou municipal); ato normativo (número e ano da lei); URL da fonte; quem conferiu.
  - **Quem faz:**
    - o A1 prepara a tabela e o `README` e entrega como patch (D10, condição 6);
    - a auditoria independente (subagente em contexto limpo, conferindo cada data contra o ato normativo) é feita **antes** da tag;
    - a sessão de coordenação commita no `comum` e põe a tag `feriados_locais-v1.0`;
    - o SHA-256 da tabela entra nos logs do A1 e do A2, e o A2 usa a mesma tag.
  - **Modelo:** um **único indicador binário** `feriado_local` (feriado estadual ou municipal do núcleo, mais 24/12 e 31/12), somado ao modelo principal, como diz a letra da §4 (l. 383).
- **Cuidados de construção:**
  - **20/11:** antes de 2024, era feriado só onde havia lei estadual ou municipal, e entra na tabela local nesses casos; desde 2024, é nacional e já está em `feriado_nacional`, então não entra de novo;
  - datas que coincidem com feriado nacional ou móvel, já no modelo, não são contadas duas vezes;
  - feriados criados ou revogados no período entram só nos anos em que vigoraram.
- **Plano B, por data, e não para a tabela inteira:**
  - uma data sem ato normativo localizável sai da tabela e é listada no `README`;
  - se a fonte municipal de um núcleo não puder ser conferida, esse núcleo fica só com os feriados estaduais, mais 24/12 e 31/12, com registro;
  - tudo isso antes de rodar a sensibilidade. A regra de recuar para só 24/12 e 31/12 em todos os núcleos fica de fora: jogaria fora as datas verificáveis.
- **Rótulo:** esclarecimento de letra; o plano B é escolha *post hoc*.

---

## 5. Cross-basis e modelo

### 5.1 `arglag` dos lags 0–4, 0–14 e 0–21

- **Decisão: aprovada a proposta:** `arglag = list(fun = "ns", knots = logknots(L, nk = 2), intercept = TRUE)`, com L = 4, 14 ou 21, sempre com 4 gl. A cross-basis continua com 16 parâmetros e 4 coeficientes reduzidos.
- **Por que nk = 2 em todos:** a única coisa que muda entre as sensibilidades de lag é a janela. Com nk = 3 no 0–21, como no MCC 2015 (`lagnk <- 3` no `00.prepdata.R`, conferido), mudariam juntos a janela e a flexibilidade.
- **Nós (fórmula do `logknots.R`, dlnm 2.4.10, conferida):**

  | L | Nós internos | Valores de lag |
  |---|---|---|
  | 4 | 0,815; 1,806 | 5 |
  | 7 (principal) | 0,982; 2,622 | 8 |
  | 14 | 1,237; 4,162 | 15 |
  | 21 | 1,416; 5,454 | 22 |

- **Declarar:** no 0–4, há 4 gl para 5 valores de lag. A lag–resposta fica quase sem restrição, e o efeito acumulado de 0–4 vale como estimativa quase livre.
- **Aquecimento:** L dias antes do primeiro dia de ajuste (§1.5); a grade desde 2010-12-11 cobre o 0–21.
- **Rótulo:** escolha *post hoc*. A §1.3 só define o 0–7, e a §1.4 diz que lags e nós são fixados *a priori*.

### 5.2 DLNM penalizado (S3)

- **Decisão: aprovada a proposta, com os parâmetros fixados aqui, antes de rodar:**
  - **1ª etapa:** `mgcv::gam`, com o termo `s(Q, Lmat, bs = "cb", k = c(10, 8), xt = list(bs = "ps"))`.
    - `Q` é a matriz de `tmean_nucleo` nos lags 0–7, na série consecutiva com aquecimento (C2); `Lmat` é a matriz de lags 0:7 com as mesmas dimensões.
    - Base P-spline cúbica nas duas dimensões, com penalidade de diferença de 2ª ordem. O construtor `cb` fixa `bs = "ps"` como padrão e passa `m` vazio (`smooth.construct.cb.smooth.spec.R`, l. 31–34 e 37–38); a ordem cúbica e a penalidade de 2ª ordem vêm do `ps` do `mgcv` (`smooth.r`, l. 1764–1766: `m[is.na(m)] <- 2`).
    - Sem penalidades adicionais na lag (`addSlag`).
    - A exposição perde uma coluna pela restrição de identificabilidade, e a lag não. A dimensão fica em 9 × 8 = 72.
    - Os nós da P-spline são equiespaçados no `range` de `Q`, como a P-spline exige, e não nos p10/p75/p90. Declarar.
  - **`k = 8` na lag** é o máximo com 8 valores de lag. No construtor `ps` do `mgcv`, um k maior que o número de valores únicos só gera aviso (`smooth.r`, l. 1793); com k = 8, há 6 nós de xl a xu (4 interiores; `nk = k − m[1]`, l. 1769–1770), e a base da lag tem posto 8, ou seja, fica saturada sem a penalidade.
  - **Resto do modelo:** o do principal. `factor(estrato)` como efeito fixo, com os estratos vazios removidos; dia da semana e feriados; `offset(log Z_t)`; no A1, γ·log(W_t) como termo paramétrico; no A2, γ = 1 dentro do offset.
  - **Ajuste:** `family = quasipoisson`, `method = "REML"`. Pela documentação do `mgcv` (`gam.Rd`, l. 49–50, conferida), família *quasi* com REML usa **quase-verossimilhança estendida**. Declarar.
    - Com λ fixo, os estratos como efeito fixo dão as mesmas estimativas pontuais da Poisson condicional. A REML de λ, porém, não é a condicional exata.
  - **Variância:** a posterior bayesiana padrão do `gam` (`Vp`). Conferido: o `crosspred` chama o `getvcov` (`crosspred.R`, l. 66), que chama `vcov(model)` (`getvcov.R`, dlnm 2.4.10), e o `vcov.gam` devolve `Vp` com os argumentos padrão (`mgcv.r`, l. 4396–4402). Declarar.
  - **Software:** o `mgcv` entra no `renv.lock` de cada artigo e na frase-modelo de software (§8), com a versão conferida na Parte 0.
  - **Teste (substitui, na S3, os testes 2 e 3 da D2 e da D6, que não se aplicam à P-spline):** o log RR do `crosspred` no p99 contra a referência coincide, até 1e-8, com a diferença das predições lineares do `predict.gam(type = "lpmatrix")` nos dois pontos, com o resto do preditor fixo. **Controle negativo:** com a referência trocada pela mediana, o teste tem de falhar.
  - **2ª etapa:** meta-análise **univariada** (`mixmeta`, REML), separada para o log RR no p99 e no p1 de cada concentração.
    - A referência é **comum**: o °C, em cada concentração, do percentil da TMR combinada do **primário** (D6, 3.1: `approx` no eixo médio, depois `quantile(tmean_ref, pct/100, type = 7)`).
    - Usa os mesmos metapreditores do principal (média e amplitude), e o combinado é a previsão na média deles.
- **Por que não contra o mínimo da própria curva (reproduzido, seção 8):** sob a nula, o log RR de cada concentração contra o mínimo da sua curva é ≥ 0 por construção, e o combinado sai positivo em 100% das réplicas.
- **Estimando diferente, a declarar:** a S3 não tem curva combinada nem TMR própria. O RR é contra a TMR do primário, fixa (um resultado da Fase 3 usado como insumo), e pode ficar abaixo de 1. A S3 não é sensibilidade-chave, então o critério da D10 não se aplica a ela.
- **No A2, o p1 não é estimável:** a TMM combinada do primário está em x1 (D8, 1.1), então a referência comum é o p1 de cada concentração. O contraste no p1 sai com log RR = 0 e variância 0 nas 26 (`value = cen` zera a base centrada; `crossreduce.R`, l. 105–110), e o `mixmeta` univariado falharia. No A2, a S3 reporta só o p99 contra o p1 (o mesmo par do primário do A2) e declara o p1 "não estimável por construção".
- **Falha de convergência na S3:** o *fallback* da D7, M7, não se aplica (não há `arglag` em estratos nem ns p50/p90 numa P-spline). A concentração em que o `gam` não convergir sai da 2ª etapa da S3, com registro e com o texto dizendo qual e por quê.
- **A alternativa (meta-análise multivariada numa grade de percentis) fica de fora:** com 26 concentrações, uma Ψ não estruturada na grade não se sustenta.
- **Rótulo:** escolha *post hoc* (lacuna: a §1.2 só nomeia o método).

### 5.3 Uma etapa

- **Decisão: aprovada a proposta, com a transformação fixada.**
  - **Percentil de cada dia, por concentração c:** `pct = approx(x = quantile(tmean_ref_c, probs = seq(0, 1, 0.001), type = 7), y = seq(0, 100, 0.1), xout = tmean, rule = 2, ties = mean)$y`, com `tmean_ref_c` de 2012-01-01 a 2024-12-31 (§1.2).
    - Os dias de aquecimento fora do `range` de referência ficam em 0 ou 100 (`rule = 2`). Declarar.
  - **Cross-basis comum** no percentil: as 26 séries consecutivas, cada uma com os seus 7 dias de aquecimento (C2), empilhadas e passadas a um único `crossbasis` com **`group = concentração`**, para que os lags não atravessem de uma concentração para outra (`crossbasis.R`, l. 55 e 64). `argvar` ns com nós em 10, 75 e 90 e Boundary.knots = `range(pct)` do `x` empilhado (D6, 2.2); `arglag` do principal.
  - **Modelo único:**
    - quasi-Poisson condicional (`gnm`), `eliminate` = concentração × ano × mês, sem estratos vazios;
    - offset `log Z_ct`; no A1, γ_c·log(W_ct) com um γ por concentração (26 coeficientes); no A2, γ = 1 dentro do offset;
    - dia da semana e feriados comuns;
    - φ único.
  - **Curva e TMR:**
    - curva em percentil, mapeada para °C pelo eixo médio da D2;
    - TMR combinada na grade de 0,1 °C entre x1 e x99 do eixo médio, convertida em percentil por `approx` (D6, 3.1), com a grade da C3(i) e a borda pelo índice (C3(b));
    - IC da TMR por bootstrap paramétrico (C3(a)): 1.000 sorteios por Cholesky dos coeficientes da cross-basis, semente 20261001, porque é quantidade combinada (C1);
    - RR no x99 e no x1 contra a TMR, com IC da vcov do modelo e a TMR tratada como fixa.
  - **Declarar:**
    - a curva da uma etapa é uma curva média, sem metapreditores e sem heterogeneidade entre concentrações;
    - φ e o padrão de dia da semana são comuns;
    - por isso ela não é o mesmo estimando da curva do `mixmeta` na média dos metapreditores.
  - **Falha de convergência:** o *fallback* da D7, M7, foi desenhado para a 1ª etapa por concentração e não se aplica ao modelo único. Se o modelo único não convergir, a falha é reportada, sem *fallback* e sem estimativa.
- **Rótulo:** esclarecimento de letra (§6, l. 431–433; D2; C3).

### 5.4 φ > 2

- **Decisão: aprovada.** A regra da §2.1 (l. 135) vale **só para o principal**: se φ > 2 em mais de 25% das concentrações do principal, roda-se a binomial negativa como sensibilidade. Nas outras sensibilidades, φ é só reportado (mínimo, mediana e máximo nas 26).
  - **Por quê:** a regra está na descrição do modelo principal. Aplicá-la em cascata a cada sensibilidade multiplicaria as análises. Em toda análise, o quasi-Poisson já escala os EP por φ.
- **Case time series municipal: sem regra própria.** Com mais estratos e contagens menores, o φ de Pearson fica mais variável, mas o quasi-Poisson continua escalando os EP. O φ é reportado com os estratos vazios removidos (§2.1).
- **Situação do A1:** φ ≤ 1,12 nas 26, e a binomial negativa não dispara.
- **Rótulo:** esclarecimento de letra.

---

## 6. Estação quente

- **Decisão: aprovada a proposta.**
  - TMR combinada na grade entre x1 e x50 do eixo médio de nov–mar (§7, l. 448, aplicada também à combinada).
  - Contrastes de todos os percentis da §7 (p99, p95, p90, p10, p5 e p1 de nov–mar) contra essa TMR.
  - Cross-basis na série contínua do ano inteiro (C2), com os nós internos de nov–mar (§1.1, l. 85) e Boundary.knots = `range` do `x` passado, que inclui o inverno (D2, teste 2). Os dias fora de nov–mar saem só do ajuste.
- **O x1 de nov–mar não é coprimário.** A estação quente não é sensibilidade-chave, então não tem primário nem coprimário: todos os percentis vão para o suplemento.
  - O texto destaca o x99 contra a TMR, que é o contraste comparável ao do MCC.
  - O x1 de nov–mar é um dia ameno de verão, não frio, e não é lido como efeito do frio.
- **TMR na borda da busca (x1 ou x50 de nov–mar), na combinada ou na BLUP:**
  - a borda é detectada pelo índice do mínimo na grade x1–x50 (C3(b));
  - o contraste daquele ponto vale 1 por construção e é reportado como tal (D8, 1.2(b));
  - **não há busca extra:** a regra da §7 (RR contra a mediana e busca entre p10 e p90) não se transpõe ao verão, porque a mediana de nov–mar é a própria borda x50, e a faixa p10–p90 sai do limite p1–p50. A TMR na borda é reportada com marca.
  - Rótulo: escolha *post hoc* (lacuna).
- **Rótulo:** esclarecimento de letra, salvo a regra de borda.

---

## Registro no log (A1 e A2; commit próprio, antes de rodar)

> - **D11 (15/10):** `spec/decisoes_metodo_20261015_AGUDOS_D11_sensibilidades_calendario_cb_modelo.md` (SHA-256 ⟨conferido⟩). Decidido depois de ver os resultados das Fases 2 e 3 deste artigo: ⟨listar⟩.
>   - *Fallback* da §10.2: regra de convergência (D7, M7), sem análise própria; resíduos defasados da D3 seguem em todas as concentrações. Esclarecimento de letra.
>   - Natal e Ano-Novo: 24/12 a 01/01, só do ajuste (108 dias). Esclarecimento de letra; limites escolhidos.
>   - Sem 2020–21: dias de evento de 2020-01-01 a 2021-12-31 fora do ajuste; cross-basis contínua. Esclarecimento de letra; operacionalização escolhida.
>   - Feriados locais: tabela comum `codigo_compartilhado/dados_referencia/feriados_locais_nucleo_2011_2024.csv`, tag `feriados_locais-v1.0` (SHA ⟨…⟩), indicador único; plano B por data (*post hoc*).
>   - Lags 0–4, 0–14 e 0–21: `logknots(L, 2)`, 4 gl. Escolha *post hoc*.
>   - S3 penalizado: `s(Q, Lmat, bs = "cb", k = c(10, 8), xt = list(bs = "ps"))`, quasipoisson com REML (EQL), `Vp`; 2ª etapa univariada contra o percentil da TMR/TMM do primário (resultado da Fase 3 usado como insumo); sem *fallback*; teste contra o `predict.gam`. Escolha *post hoc*. **Só no A2:** p1 não estimável.
>   - Uma etapa: percentil por `approx` em 1.001 quantis; cross-basis comum com `group = concentração`; sem *fallback*; γ por concentração (A1) ou γ = 1 (A2); TMR na grade de 0,1 °C; bootstrap com semente 20261001. Esclarecimento de letra.
>   - φ > 2: só no principal; sem regra própria na case time series municipal.
>   - Estação quente: TMR combinada em x1–x50 de nov–mar; todos os percentis no suplemento; x1 não é coprimário; TMR na borda com marca, sem busca extra (*post hoc*).
>   - **Só no A2:** recontagem do corte de 2.000 na janela principal antes de rodar.

---

## A. Auditoria

### A.1 Autoauditoria (reprodução própria)

| Ponto | Reprodução | Resultado |
|---|---|---|
| Nós de `logknots(L, 2)` e `logknots(21, 3)` | `repro_d10_d12.py`, item 1, pela fórmula do `logknots.R` (dlnm 2.4.10) | Tabela do item 5.1 |
| MCC 2015 usa `lagnk <- 3` com lag 21 | `00.prepdata.R`, l. 58–59 | Confirmado |
| Dias de Natal e de 2020–21 nas janelas principais | `repro_d10_d12.py`, item 4 | A1: 108 de 4.498 (2,40%) e 731 (16,25%). A2: 108 e 731 de 4.456 |
| Combinado contra o mínimo próprio enviesado sob a nula | `repro_d10_d12.py`, item 3: 26 curvas ruidosas, curva verdadeira plana, 2.000 réplicas | Log RR combinado médio de 0,012; > 0 em 100% das réplicas |
| Construtor `cb`: P-spline nas duas margens, restrição só na exposição | `smooth.construct.cb.smooth.spec.R` (cran/dlnm, tag 2.4.10) | Confirmado |
| *Quasi* + REML usa quase-verossimilhança estendida | `gam.Rd` do `mgcv` 1.9-4, l. 49–50 | Confirmado |
| k = 8 na lag é aceito pela P-spline | `smooth.r` do `mgcv` 1.9-4: `ps`, l. 1769–1770 (`nk = k − 2` > 0) e l. 1793 (só aviso se k > valores únicos) | Confirmado. A versão do `renv` de cada artigo é conferida na Parte 0 |

### A.2 Auditoria independente

O auditor (subagente em contexto limpo) leu a consulta, a especificação v2.0.2, as decisões D1 a D9 e os três rascunhos, e reproduziu os números com scripts próprios (`aud_logknots_dias.py`, `aud_wj_ano.py`, `aud_meta_minimo.py`, `aud_ps_lag.py`). Não achou nenhum erro crítico; achou 3 Maiores, 8 Menores e 11 Notas nos três documentos. Cada achado abaixo foi reproduzido por mim antes de ser aceito.

| Achado | Gravidade | Reprodução própria | Correção |
|---|---|---|---|
| 1. O item 2 tratava os resíduos defasados como condicionais, contra a D3, que os roda em todas as concentrações | Maior | D1-D3, tabela (l. 18) e seção 4 (l. 151): a linha da §10.2 passou a "resíduos defasados nos lags 1 a 7, em todas as concentrações" | Item 2 reescrito; "a D11 não altera a D3" |
| 2. No A2, a S3 tem o contraste do p1 degenerado, porque a referência comum é o p1 | Maior | `crossreduce.R`, l. 105–110: `value = cen` zera a base centrada; a TMM do A2 está em x1 (D8, 1.1) | p1 "não estimável por construção" no A2; só p99 contra p1 |
| 4. Sem regra para a TMR de nov–mar na borda | Menor | §7, l. 447–448: a mediana de nov–mar é a borda x50, e a faixa p10–p90 sai do limite p1–p50 | Borda por índice; contraste = 1 com marca; sem busca extra (*post hoc*) |
| 5. A frase geral do rótulo ("nenhum item usa resultados") contradiz a S3 | Menor | Item 5.2: a referência é a TMR/TMM combinada do primário | Exceção declarada no cabeçalho e no item 5.2 |
| 10. Sem regra de falha de convergência na S3 e na uma etapa | Menor | D7, M7: os passos 1 e 2 pressupõem a 1ª etapa paramétrica por concentração | S3: a concentração sai da 2ª etapa; uma etapa: falha reportada, sem *fallback* |
| 11. A uma etapa não dizia `group = concentração` | Menor | `crossbasis.R`, l. 55 e 64: com `group`, o `Lag` não atravessa os grupos | Séries empilhadas com `group = concentração` |
| 13. "Pela data do evento" era escolha, não só letra | Nota | D7, M6.4: o PIG escolheu a janela de exposição | Rótulo igualado ao do item 3.1 |
| 14. "6 nós interiores" estava impreciso | Nota | `smooth.r`, l. 1769 e 1782–1783: 6 nós de xl a xu, 4 interiores; posto 8 (auditor) | Texto corrigido |
| 15. A fonte da penalidade de 2ª ordem estava incompleta | Nota | `smooth.r`, l. 1764–1766 (`m[is.na(m)] <- 2`) | Citação acrescentada |
| 16. "`Vp` é o que o `crosspred` usa" não era verificável | Nota | **Resolvido aqui:** `getvcov.R` (dlnm 2.4.10) chama `vcov(model)`; `vcov.gam` devolve `Vp` por padrão (`mgcv.r`, l. 4396–4402) | Cadeia de chamadas citada |
| 17. `mgcv` fora do `renv` e sem teste substituto na S3 | Nota | §8 e D6, 2.2: os testes 2 e 3 pressupõem `ns`/`bs` | `mgcv` no `renv.lock` e na frase de software; teste contra o `predict.gam`, com controle negativo |
| 21. O A1 "constrói e põe a tag", contra a D10, condição 6 | Nota | Leitura cruzada com a D10 | A1 entrega o patch; auditoria antes da tag; a coordenação commita e põe a tag |
| 22. Numeração: a §7 do registro colidia com a §7 da consulta | Nota | Leitura | Registro sem número; auditoria como seção A |

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
