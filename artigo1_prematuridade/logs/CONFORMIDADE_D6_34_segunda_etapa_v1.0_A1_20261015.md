# Conformidade da `segunda_etapa-v1.0` com a D6, 3.1–3.3 (D6, 3.4)

**De:** chat do Artigo 1, por Guilherme · **Data:** 15/10/2026 · **Versão:** 1.1
**Norma:** `spec/decisoes_metodo_20261013_D6_respostas_A2.md` (SHA-256 `e456ad6785f25a102ca940cdd5bfab028eed701678c712d44f6c478d5451ddc5`, conferido), seção 3 e item 2 (errata do teste 3 da D2).

**Código conferido:**
- `codigo_compartilhado/R/segunda_etapa.R` na tag `segunda_etapa-v1.0` (objeto `e12eafbc…`, commit `410dd6d6d3d315004f22fd7197c326de77f3c2f4`). É igual ao de `origin/main` em `f1d3651`.
- Uso no A1: `artigo1_prematuridade/00_scripts/45_segunda_etapa_principal.R` e `40_percentis_exposicao.R` (`origin/main`, `f1d3651`).
- Saídas do A1: `artigo1_prematuridade/logs/segunda_etapa_fase3_20261013.md`.

**Dupla auditoria.**
1. **Conferência do chat do A1:** leitura linha a linha e reprodução própria em dados sintéticos (`repro_conformidade_D6_34_chatA1.R`). O GLS foi montado à mão, com vec por unidade; o quantil tipo 7 saiu pela fórmula; a interpolação, por `findInterval`; a base, por `splines::ns`.
2. **Auditoria independente:** subagente em contexto limpo, sem acesso à conclusão do chat do A1, com script próprio (`auditoria_independente_D6_34.R`).

As duas chegaram aos mesmos vereditos. O único achado a mais da auditoria independente, a nota 6, foi reproduzido. Um segundo auditor revisou este relatório e a mensagem de execução; os achados dele que tocam o relatório (texto e nota 6) estão incorporados nesta v1.1.

**Ambiente das reproduções:** R 4.3.3, mixmeta 1.2.0 e dlnm 2.4.10. O dlnm pede R ≥ 4.4; foi instalado com essa exigência relaxada, sem mudar o código. Os SHA-256 de `qtest.mixmeta.R`, `summary.mixmeta.R`, `crossreduce.R` e `crossbasis.R` são iguais aos da D6, seção 6.

---

## 1. Veredito por regra

| Regra da D6 | Veredito | Onde (arquivo, linha) | Reprodução |
|---|---|---|---|
| **3.1** °C → percentil por interpolação linear no eixo médio de 101 pontos, ordenado por percentil | **Conforme** | `segunda_etapa.R` 156–159 (`approx`, `rule = 1`, `stopifnot` de eixo estritamente crescente); `40` 36 e 52 (p1–p99 mais p2,5 e p97,5; média das 26); `45` 86–87 (ordena por percentil e confere) e 130 | Igual à interpolação à mão (diferença 0). Eixo fora de ordem é **recusado**, não interpolado em silêncio |
| **3.1** TMR combinada na grade x1–x99, então percentil em [1, 99] | **Conforme** | `segunda_etapa.R` 131–136; `45` 128 | x1 → 0,01; x99 → 0,99; fora do eixo → NA |
| **3.1** °C da concentração = `quantile(tmean_ref, pct/100, type = 7)` | **Conforme** | `segunda_etapa.R` 160–164; `45` 93–99 (`tmean_nucleo` de 2012–2024, 4.749 dias, que reproduz a grade da A0 no texto `%.17g`) e 169 | Igual ao quantil tipo 7 pela fórmula (< 1e-12). Na fronteira, p50 (C3(b)) |
| **3.2** Q e I² residuais (GLS de efeitos fixos com a mesma X), 92 gl | **Conforme** | `segunda_etapa.R` 104 e 117; log: 92,92, 92 gl, 1,0% | Q = GLS à mão (diferença relativa < 1e-8); gl 92; I² = max(0, (Q − gl)/Q)·100 |
| **3.2** Modelo só com intercepto, 100 gl, rótulo "sem metapreditores" | **Cálculo conforme; rótulo divergente** | `segunda_etapa.R` 105 e 117 (campo `total`); `45` 184–185 e 210–212; log (curva geral e as duas lag–respostas) | Q e gl 100 = GLS à mão. O rótulo sai "total" |
| **3.2** Q por coeficiente, 23 gl, rótulo "por coeficiente (não univariado)", no suplemento | **Lacuna de relato** | `segunda_etapa.R` 104 guarda só `qtest()$Q[1]`; nada no `45` nem no log | `qtest()$Q[2:5]` = cálculo à mão com a diagonal de S e os coeficientes do GLS multivariado, 23 gl. O número existe no `qtest` do mesmo modelo, mas não é guardado |
| **3.2** Wald por metapreditor, 4 gl | **Conforme** | `segunda_etapa.R` 106–111; log: 4 gl | Forma quadrática à mão (< 1e-10) |
| **3.2** Seleção por expressão regular exata, com `stopifnot(length(ind) == 4)` | **Seleção conforme; guarda ausente** | `segunda_etapa.R` 107: tira o prefixo `yk.` e compara por igualdade exata (certo), sem a guarda; `gl = length(ind)` (l. 110) | Com `media` e `media2` (ou `xmedia`) no modelo, o código pega 4 coeficientes; o `grep` de substring da `fwald` pegaria 8 |
| **3.3** Lag–resposta com os mesmos metapreditores, predição na média, mesma sequência de estabilidade e falha | **Conforme** | `45` 176–180 (mesmo `md`, `meta_curva`, `pred_media` e `stop` na falha); `segunda_etapa.R` 91–102 | Predição = (x̄′ ⊗ I)·β̂, com vcov (< 1e-12); erro forçado em reml/unstr cai em reml/diag |

## 2. Achados

| # | Grav. | Achado | Muda número já reportado pelo A1? | Resolução (decisão de Guilherme, 15/10: v1.0.1 só de testes) |
|---|---|---|---|---|
| 1 | Maior | **Teste 3 da D2 (errata da D6, item 2) não implementado.** O `t03` da tag (`testa_segunda_etapa.R` 48–60) compara a `curva()` com o `crossreduce` **usando a mesma `argvar`**. O `47_autoauditoria_fase3C.R` (l. 55) usa `splines::ns` com `av$knots` e `av$Boundary.knots`, que também saem da `argvar`. Nenhum dos dois é a fonte independente | Não | Teste novo em `codigo_compartilhado/tests/`, parametrizado por análise (`serie_nos`, `probs_nos`, `x_cb`, `fun`, `degree`) |
| 2 | Menor | **Q por coeficiente não guardado** (curva geral e as duas lag–respostas) | Não; só acrescenta saída | No **chamador**: `qtest()` do mesmo `mixmeta` (Y sem nomes de coluna, `unname(Y)`, como na `meta_curva`, l. 81; mesmos S, md, método e Ψ; `coef` `identical()` ao `coef_meta`, conferido), `Q[-1]`, `df[-1]`, `pvalue[-1]` e I² = max(0, (Q − gl)/Q)·100, rotulados "por coeficiente (não univariado)" |
| 3 | Menor | **Rótulo "total"** no lugar de "sem metapreditores" | Não; Q, gl e I² estão certos | Só no relato (tabelas e log). O campo `total` da `meta_curva` fica, porque o A2 o lê (`artigo2_obito_perinatal/00_scripts/50_segunda_etapa.R`, l. 81) |
| 4 | Menor | **Sem guarda do número de coeficientes no Wald** | Não; o log mostra 4 gl e a seleção já é exata | No **chamador**: `stopifnot(all(m$wald$gl == ncol(Y)))` em cada meta-análise, que equivale à guarda porque `gl = length(ind)` (l. 110). No principal, `ncol(Y) = 4`, a letra da D6. Teste novo documenta a seleção exata (par `media`/`xmedia`) |
| 5 | Nota | O Q sem metapreditores depende de o `fit0` convergir com o mesmo método e Ψ (l. 105 e 117), embora seja um GLS fixo. Se o `fit0` falhar, sai "indisponível". Não aconteceu no A1 | Não | Fica como está. Se ocorrer, o chamador calcula o `qtest` com `method = "fixed"` e `bscov = "unstr"`. No mixmeta 1.2.0, `fixed` só aceita `unstr`: com `diag` dá erro |
| 6 | Nota | **Poder do controle negativo do teste 3.** Se `range(x_cb)` coincidir com `range(serie_nos)`, trocar uma pela outra não é detectável | Não | Controle obrigatório: fronteiras p1–p99 (sempre tem poder). No sintético, extremos fora da janela e um 2º controle com `range(serie_nos)`. Nos dados, informativo: em quantas das 26 as amplitudes diferem |

**A independência do teste 3** está na origem dos argumentos: nós recalculados pelo `quantile` da série e fronteiras pela amplitude do `x` passado ao `crossbasis`. Não está no código da spline: o dlnm usa `splines::ns` e `splines::bs`.

**Protótipo do teste 3** nas duas reproduções, em dados sintéticos com a estrutura de datas do A1 (`serie_nos` de 4.749 dias, `x_cb` de 4.505):
- a fonte independente coincide com a `curva()`: diferença máxima de 0 no chat do A1 e de 8,2e-17 no auditor, contra o critério de 1e-8;
- o controle com fronteiras p1–p99 falha, como deve: 4,5e-2 e 3,2e-2;
- a `argvar` do `crossbasis` guarda `Boundary.knots = range(x_cb)` exatamente.

A errata é implementável como está escrita.

## 3. Conclusão

- **Declaração.** A `segunda_etapa-v1.0` é **conforme à D6, 3.1–3.3, em todo cálculo**.
  - As três divergências (rótulo, Q por coeficiente e guarda do Wald) são de relato e de checagem. Elas se resolvem no chamador, sem mudar o `segunda_etapa.R`.
  - Por decisão de Guilherme (15/10/2026), a **`segunda_etapa` v1.0.1 é só de testes**: `git diff 410dd6d..segunda_etapa-v1.0.1 -- codigo_compartilhado/R/segunda_etapa.R` sai vazio, e o commit da tag só acrescenta arquivos em `codigo_compartilhado/tests/` (mais o script e o log de testes do A1).
  - **Aviso para o portão 2 do A2:** `git diff --stat 410dd6d..segunda_etapa-v1.0.1 -- codigo_compartilhado/` também mostra `R/diagnostico_grade_mrt.R` e `R/posthoc_af.R`. Eles vieram de outras tags (`diagnostico_grade_mrt-v1.0`, `posthoc_af-v1.0`) e não são carregados pela `segunda_etapa`. A conferência certa é por arquivo, como acima.
- **Nenhum número muda.** Nenhum achado mexe em RR (inclusive no x99), TMR, percentil da TMR (q_TMR = 0,9378), Q, I² ou Wald já reportados.
- **O que o A1 refaz:**
  - rótulo "sem metapreditores" nas tabelas novas;
  - tabela do Q por coeficiente (curva geral e lag–resposta no p99 e no p1);
  - `gl == 4` conferido nos três Wald;
  - teste 3 nas 26 curvas BLUP.
  - O log antigo não é editado: nele, "total" lê-se "sem metapreditores".
- **Para o A2:** serve a v1.0.1 só de testes. O A2 refaz o próprio relato com as mesmas três receitas do item 2 (Q por coeficiente, rótulo e `gl == ncol(Y)`) e roda o teste 3 por desfecho. Isso vale antes da refação da Fase 3 do A2 (desvio 103).
- **Fase 4 do A1:** o teste 3 roda em cada sensibilidade da tabela da D6, item 2 (lag 0–14 e 0–21, S2, estação quente, `tmean_mun`, Tmax/Tmin/AT).

## 4. Arquivos

| Arquivo | SHA-256 |
|---|---|
| `repro_conformidade_D6_34_chatA1.R` | `9c1648e4536957c00c6558715e38e64c4d2e5fc8da4b2a17c0cd726fdbae0911` |
| `repro_conformidade_D6_34_chatA1_resultado.csv` (nele, "FALSE" em B4, B6 e B9 marca justamente os achados 3, 2 e 4) | `956f6bd9547648906b916bdc83eec5a48512722c759a1035f576a4013fabc76d` |
| `auditoria_independente_D6_34.R` | `76a8c5e34dbd2814bfe7937571434ebaacc7b5dc35df6cbda16cd32125358ba9` |
| `auditoria_independente_D6_34_saida.txt` | `16d13e8b0cce5391a62d5450a7e222c939ea7a03524ba40cbe154291a739007f` |

Os dois scripts rodaram fora da Forja, só com dados sintéticos, e trazem caminhos da sessão do chat. São registro da auditoria, não código a rodar na Forja.
