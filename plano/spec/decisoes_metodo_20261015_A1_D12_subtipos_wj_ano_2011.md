# Decisões de método — 15/10/2026, D12: subtipos de PTB, "w_j por ano" e braço A de 2011

**De:** chat de métodos · **Data:** 15/10/2026 · **Origem:** consulta do chat do Artigo 1, v1.1 (15/10), seção 4, sobre a solicitação v3 do Claude Code (SHA-256 `6e5a93ac219954ae6fcd2782124fb306cc7ff072295bb33414d46d84958f2b28`)
**Âmbito:** só Artigo 1. O item 4.2 não se aplica ao A2, cujo w_j é agrupado e suavizado (§3.2).
**Ler junto com:** D10 (`…_TODOS_D10_…`) e D11 (`…_AGUDOS_D11_…`). A numeração dos itens segue a da consulta.

**Rótulo:** as decisões são tomadas depois dos resultados das Fases 2 e 3 do A1 (ver o cabeçalho da D10). Nenhum item usa esses resultados. O 4.1 e o 4.3 usam só contagens e exposição; o 4.2 corrige um viés de construção demonstrado em simulação sem efeito.

---

## Resumo

| # | Item | Decisão | Rótulo |
|---|---|---|---|
| 4.1 | Offset dos subtipos | **Z_t e W_t restritos às semanas do subtipo**, com o w_j do principal e a janela do principal; γ pela regra única, por subtipo, antes de rodar | Escolha *post hoc* (lacuna) para o offset; esclarecimento de letra para o γ |
| 4.1 | Subtipo com < 1.000 eventos numa concentração | **A concentração sai da meta-análise daquele subtipo** (§5, critério 3, estendido ao subtipo), e não passa pelo *fallback* | Escolha (extensão do critério por desfecho) |
| 4.2 | "w_j por ano" | **Por ano de entrada na semana j** (proposta do A1) | Escolha *post hoc* (lacuna da letra; viés demonstrado) |
| 4.3 | Braço A de 2011 | **Proposta do A1:** nós e eixo do principal nos dois braços; Boundary.knots do próprio `x` de cada braço (D6, 2.2), sem exceção | Escolha *post hoc* |

---

## 4.1 Subtipos (§3.1, l. 169)

**Subtipos** (RESPOSTA da Fase 1, l. 98–100): extremo, de 22 a 27 semanas (≤ 27 na população de 22+0 a 42+6); muito, de 28 a 31; moderado-tardio, de 32 a 36.

**Decisão: aprovada a proposta.**
- **Offset:**
  - Z_t^sub = Σ_{j ∈ sub} Z_tj;
  - W_t^sub = Σ_{j ∈ sub} Z_tj·w_j / Z_t^sub, com o **mesmo w_j do principal** (risco condicional de parto na semana j, por concentração, no período inteiro; §3.1). O risco na semana j não depende do subtipo.
  - Um parto do subtipo no dia t só pode vir de uma gestação que está numa semana do subtipo. Por isso o conjunto em risco é restrito a essas semanas.
  - A alternativa (Z_t de 22 a 36 nos três) poria no denominador gestações que não podem ter aquele evento.
- **Janela:** a do principal (2012-04-14 a 2024-08-06), nos três subtipos. Nela, Z_tj é completo em todas as semanas de 22 a 36, logo também nas de cada subtipo.
- **γ:** pela **regra única** da §3.2, por subtipo, calculada antes de rodar, só com contagens por IG (Q8) e nos dois cenários de sazonalidade. Se o EP aproximado for ≥ 1, γ = 1. O EP de cada subtipo e o γ resultante entram no log antes de rodar.
- **Série nova:** Z_tj por semana (j = 22…36), por concentração, entra na lista A5.
- **Contagem descritiva antes de rodar:** eventos de cada subtipo por concentração, na janela principal, só contagens (sem clima). O sigilo segue a regra de sempre: "<10", com supressão complementar.

**Concentração com < 1.000 eventos de um subtipo: sai da meta-análise desse subtipo.**
- O critério 3 da §5 (≥ 1.000 eventos; cerca de 60 por parâmetro da cross-basis de 16) é aplicado pela §5 separadamente ao PTB, ao óbito perinatal e às curvas do PIG, e a sensibilidade de 2.000 também é por desfecho. A letra não lista os subtipos; estendê-lo a cada subtipo segue a mesma razão (eventos por parâmetro de cada modelo).
- O *fallback* (critério 4) é regra de convergência, não de contagem. Ele só entra se uma concentração incluída não convergir.
- O texto lista, por subtipo, as concentrações que ficaram fora e quantas entraram na meta-análise.
- **Declarar:**
  - com menos concentrações, a curva combinada do subtipo extremo pode cobrir um conjunto diferente de climas;
  - os metapreditores são os mesmos, avaliados na média das concentrações incluídas.

**Rótulo:** escolha *post hoc* para a restrição do offset (lacuna: a §3.1 só define Z_t de 22 a 36 para o `ptb`); esclarecimento de letra para o γ (a regra única vale para "todos os modelos agudos com offset"); escolha, por extensão do critério por desfecho, para o corte de 1.000 nos subtipos.

---

## 4.2 "w_j por ano" (§3.1, l. 198): por ano de entrada na semana j

**Defeito, reproduzido com código próprio** (seção A: `wj_ano_proprio.py`; concepções uniformes na coorte fixa 22, sem efeito nenhum, término na semana k em s + 7k + 3; distribuição de IG construída a partir de riscos log-lineares de w_22 = 0,0004 a w_36 = 0,0428, como na §3.1, e riscos a termo de 0,08, 0,25, 0,45, 0,55, 0,70 e 1,0 nas semanas 37 a 42, com E[IG] = 38,41):

| Ano | w_22, por ano de nascimento | w_36, por ano de nascimento | Por ano de entrada (as duas semanas) |
|---|---|---|---|
| 2012 | 1,463 × o verdadeiro | 1,088 × | 1,000 × |
| 2013–2023 | 1,000 × | 1,000 × | 1,000 × |
| 2024 | 0,659 × | 0,937 × | 1,000 × |

- Os números do auditor do A1 (1,46 e 1,08 em 2012; 0,66 e 0,94 em 2024) são reproduzidos.
- **As razões dependem de médias da IG**, e não dos riscos semana a semana: a do w_22, de E[IG]; a do w_36, de E[IG | IG ≥ 36]. Na forma fechada do auditor independente, a razão de 2012 no w_22 é 363 / (363 − 7·(E[IG] − 22)), o que dá 1,4628 com E[IG] = 38,41 (conferido). Com a IG real do Q8, os valores exatos seguem essas médias; o mecanismo e a direção não mudam.
- **Mecanismo:** por ano de nascimento, o numerador (partos na semana j no ano y) e o denominador (partos com IG ≥ j no ano y) vêm de conjuntos diferentes de inícios s. Nas bordas da coorte fixa, os partos a termo só aparecem a partir de maio de 2012, enquanto os de 22 semanas começam em janeiro. O denominador fica truncado e o w_22 é inflado.

**Decisão: aprovada a proposta.**
- **Definição:** para a concentração c, o ano y e a semana j:
  - N_cyj = gestações da coorte fixa 22 (NV) que **entram na semana j** (data s + 7j) no ano y, ou seja, com IG ≥ j;
  - D_cyj = as que, entre elas, têm o parto na semana j (IG = j);
  - w_j(c, y) = D_cyj / N_cyj, sem suavização (a letra diz "w_j por concentração × ano").
  - O s vem da definição da base: s = parto − (7·IG + 3).
- **Aplicação:** w_j(c, y) entra no W_t dos dias t do ano y, com γ estimado como no principal.
- **Coerência com a coorte (conferida):**
  - a primeira entrada possível na semana 22 é 2011-07-31 + 154 dias = **2012-01-01**, então não há "ano 2011";
  - em 2024, as entradas na semana 36 vão até 2024-11-12, e o parto nessa semana cai em 2024-11-15 (a semana vai até 2024-11-18);
  - todos os desfechos da coorte saem até s máximo + 297 = 2024-12-27, dentro da base.
- **Declarar:**
  - no começo de janeiro, Z_tj inclui gestações que entraram na semana j até 6 dias antes, ainda em dezembro; o w_j aplicado é o do ano de t;
  - com contagens anuais por concentração, o w_j das semanas 22–24 é ruidoso (w de cerca de 0,0004); o ruído entra em log(W_t) e é parcialmente absorvido por γ;
  - se alguma combinação c × y × j tiver N = 0, o termo sai da soma. W_t continua positivo, porque as outras semanas contribuem.
- **A alternativa (ano de nascimento com 2012 e 2024 agrupados aos vizinhos) fica de fora:** corrige a borda por aproximação e mistura anos, quando a definição por entrada é exata por construção.
- **Rótulo:** escolha *post hoc*. A letra não define "ano", e a escolha corrige um viés de construção demonstrado sem dados de desfecho.

---

## 4.3 Braço A de 2011 (§3.6): proposta do A1, sem exceção à D6, 2.2

**Decisão: aprovada a proposta.**
- **Nós internos:** os do principal (p10, p75 e p90 da `tmean_nucleo` de 2012-01-01 a 2024-12-31; §1.2), **nos dois braços**.
- **Eixo:** o do principal (D2), nos dois braços.
- **Boundary.knots:** o `range` do `x` efetivamente passado ao `crossbasis` em cada braço, pela regra geral da D6, 2.2 ("toda cross-basis"). No braço A, isso inclui 2011 e o aquecimento desde 2010-12-25. Os testes 2 da D2 e 3 da D6 valem sem adaptação, com `x_cb` = a série de cada braço.
- **Declarar:** as fronteiras diferem entre os braços **porque o período difere**: o `range` de 2011–2024 contém o de 2012–2024. A comparação "muda só o período" inclui essa consequência do período.
- **Por que não fronteiras comuns:** foi a primeira versão desta decisão. O auditor independente mostrou que ela abriria uma exceção não declarada à D6, 2.2, e exigiria adaptar dois testes. O ganho seria pequeno, porque os nós internos e o eixo já são comuns.
- **Rótulo:** escolha *post hoc*, sem relação com resultados.

---

## Registro no log do A1 (commit próprio, antes de rodar)

> - **D12 (15/10):** `spec/decisoes_metodo_20261015_A1_D12_subtipos_wj_ano_2011.md` (SHA-256 ⟨conferido⟩). Decidido depois de ver os resultados das Fases 2 e 3: ⟨listar⟩.
>   - Subtipos: Z_t e W_t nas semanas do subtipo, com o w_j e a janela do principal; γ pela regra única, por subtipo: ⟨EP e γ de cada subtipo⟩. < 1.000 eventos: a concentração sai da meta-análise do subtipo: ⟨lista por subtipo⟩. Z_tj por semana na A5.
>   - w_j por ano: por ano de entrada na semana j, sem suavização; viés da definição por ano de nascimento reproduzido (`wj_ano.py` do auditor do A1 e `wj_ano_proprio.py` do chat de métodos).
>   - 2011: nós e eixo do principal nos dois braços; Boundary.knots de cada braço pela D6, 2.2; testes sem adaptação.
>   - Rótulos: escolha *post hoc* (offset dos subtipos, w_j por ano, 2011); esclarecimento de letra (γ nos subtipos); escolha por extensão (corte de 1.000 nos subtipos).

---

## A. Auditoria

### A.1 Autoauditoria (reprodução própria)

| Ponto | Reprodução | Resultado |
|---|---|---|
| Viés de borda do w_j por ano de nascimento | `wj_ano_proprio.py`: concepções uniformes, riscos com w_22 = 0,0004 e w_36 = 0,0428 (§3.1) | 2012: 1,463 e 1,088; 2024: 0,659 e 0,937; anos de meio com erro ≤ 6 × 10⁻¹⁶. Bate com o auditor do A1 |
| Definição por ano de entrada sem viés | Mesmo script | 1,000 em todos os anos e semanas |
| Primeira entrada na semana 22 | Python (`datetime`) | 2011-07-31 + 154 = 2012-01-01 |
| O critério 3 da §5 é por desfecho | Leitura da §5, l. 399–404 | Mínimos listados por desfecho (PTB, perinatal, PIG); os subtipos não estão na letra: rótulo de extensão |
| Data do fim da semana 36 em 2024 (achado 6 do auditor) | Python (`datetime`): 2024-03-05 + 252, + 255, + 258 e + 297 | 2024-11-12, 2024-11-15, 2024-11-18 e 2024-12-27: corrigido no item 4.2 |
| Forma fechada da razão de 2012 (achado 18) | `E[IG]` da distribuição usada | 38,406 → 1,4628, igual à simulação |

### A.2 Auditoria independente

O auditor (subagente em contexto limpo) leu a consulta, a especificação v2.0.2, as decisões D1 a D9 e os três rascunhos, e reproduziu os números com scripts próprios (`aud_logknots_dias.py`, `aud_wj_ano.py`, `aud_meta_minimo.py`, `aud_ps_lag.py`). Não achou nenhum erro crítico; achou 3 Maiores, 8 Menores e 11 Notas nos três documentos. Cada achado abaixo foi reproduzido por mim antes de ser aceito.

| Achado | Gravidade | Reprodução própria | Correção |
|---|---|---|---|
| 3. As fronteiras do braço A passadas aos dois braços abriam uma exceção não citada à D6, 2.2 ("toda cross-basis"), e o teste 3 da D6 falharia no braço B | Maior | D6, 2.2: "os `Boundary.knots` de toda cross-basis são a amplitude do `x` efetivamente passado" | **Revertido para a proposta do A1:** fronteiras de cada braço pela D6, 2.2; testes sem adaptação; diferença declarada como consequência do período |
| 6. "Observado até 2024-11-19" estava errado | Menor | 2024-03-05 + 255 = 2024-11-15; + 258 = 2024-11-18; + 297 = 2024-12-27 | Datas corrigidas |
| 12. O corte de 1.000 nos subtipos é extensão, não letra | Nota | §5, l. 399–402: mínimos só de PTB, perinatal e PIG | Rótulo "escolha (extensão por desfecho)" |
| 18. Faltava declarar a distribuição de IG; as razões dependem só de E[IG] | Nota | Forma fechada 363 / (363 − 7·(E[IG] − 22)) com E[IG] = 38,406: 1,4628, igual à simulação | Distribuição e forma fechada declaradas |
| 22. A seção "4. Auditoria" colidia com os itens 4.1 e 4.2 | Nota | Leitura | Auditoria como seção A |

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
