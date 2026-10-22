# Decisões de método — 16/10/2026, D16: gl de ns(tempo), nula da PACF e `z_fetal` em Z

**De:** chat de métodos · **Data:** 16/10/2026 · **Origem:** consulta do chat do Artigo 1 (16/10) sobre o plano da Fase 4 (`artigo1_prematuridade/PLANO_FASE4_20261016.md`, SHA-256 `0c552a494bc728e28cc214857c1e2858dae88c7373bf81a406268d3f17506896`), P3, P4 e P6
**Âmbito:** Artigos 1 e 2 nos itens 1 e 2; só o Artigo 1 no item 3 (no A2, Z já inclui `z_fetal`, §3.2).
**Rótulo:** depois dos resultados das Fases 2 e 3 do A1 (RR no x99 de 1,003, IC de 0,978 a 1,029; no x1 de 1,020, IC de 0,990 a 1,051; TMR combinada de 28,2 °C) e antes de qualquer saída da Fase 4. No A2, depois das Fases 2 e 3 dele. Nenhuma escolha usa esses resultados.

---

## Resumo

| # | Pergunta | Decisão | Rótulo |
|---|---|---|---|
| 1 (P4) | gl totais de ns(tempo, 6/8/10 gl/ano) | **(a) Proporcional à duração da janela:** `round(gl × n_dias / 365,25)`. A1: 74, 99 e 123. A2: 73, 98 e 122 | Esclarecimento de letra |
| 2 (P3) | Nula da PACF: MQO ou MQ ponderados? | **Ponderados**, com os pesos de trabalho finais de cada concentração | Esclarecimento de implementação |
| 3 (P6) | `z_fetal` em Z: com qual w_j? | **w_j do principal** (proposta do A1): `z_fetal` entra em Z_t e no Z_tj de W_t; o w_j não muda | Esclarecimento de letra |
| — | Nota sobre a busca entre p10 e p90 na combinada | **Leitura do A1 correta** (D8, 1.2(c), confirmada pela 1.4), com uma conferência no texto do OSF | — |

---

## 1. P4: gl de ns(tempo): proporcional à duração

- **Decisão: (a).** gl total = `round(gl_ano × n_dias / 365,25)`, com n_dias = dias da janela de ajuste da sensibilidade.

  | Artigo | Janela | Dias | 6 gl/ano | 8 gl/ano | 10 gl/ano |
  |---|---|---|---|---|---|
  | A1 | 2012-04-14 a 2024-08-06 | 4.498 | 74 (73,889) | **99** (98,519) | 123 (123,149) |
  | A2 | 2012-05-26 a 2024-08-06 | 4.456 | 73 (73,199) | **98** (97,599) | 122 (121,999) |

- **Por quê:** a letra da §4 é "8 gl/ano". A (a) dá exatamente isso por ano de dado. A (b), o código do MCC 2015 (`ns(date, df = dfseas*length(unique(year)))`, `00.prepdata.R`, l. 70), daria gl de ano inteiro aos dois anos parciais (2012 e 2024): 13 anos civis tocados, contra 12,31 anos de dado. Com séries de anos completos, como as do MCC, as duas coincidem. Declarar a diferença em Methods.
- **Resto do modelo (como o A1 propôs):** quasi-Poisson **não condicional**, sem estratos, com os nós do `ns` nos quantis da data numérica dos dias da janela (padrão do `ns`); dia da semana, feriados, offset log Z_t e γ·log W_t (no A2, `log Σ_j Z_tj·w_j^PD`, D13, item 4).
- **Linhas do ajuste:** todos os n_dias da janela principal, consecutivos, inclusive os dias com zero evento (sem estratos, um dia sem evento informa; a remoção de estratos vazios da §2.1 não se aplica). O `ns` é calculado só sobre essas linhas, sem os dias de aquecimento da cross-basis.
- **Alcance:** a regra vale para a sensibilidade ns(tempo) sozinha, na janela principal consecutiva. A §10.2 não a combina com outras sensibilidades que tiram dias (por exemplo, sem 2020–21).
- **`round`:** arredondamento usual (nenhum dos seis valores cai em ,5).
- **Rótulo:** esclarecimento de letra.

## 2. P3: nula da PACF projetada por mínimos quadrados ponderados

- **Decisão: aprovada a proposta.** As 1.000 séries de ruído branco da D3, item 2, são projetadas fora do desenho completo com a projeção **ponderada** I − W^{1/2}X(X′WX)^{−1}X′W^{1/2}, usando os pesos de trabalho finais (W = μ̂) do modelo de cada concentração.
- **Por quê:** no quasi-Poisson com ligação log (canônica), o escore é X′(y − μ̂) = X′W^{1/2}r_P = 0, **exatamente** na convergência: os resíduos de Pearson ajustados estão no complemento ortogonal de W^{1/2}X. O que vale só em primeira ordem é r_P ≈ (I − H_W)ε, e a PACF da D3 é dos resíduos de **deviance**, que se aproximam dos de Pearson em primeira ordem. É essa projeção que a nula deve imitar. "Mínimos quadrados" na D3 inclui os ponderados; o custo é o mesmo.
- **Fonte de W, com teste:** W são os **pesos de trabalho** do ajuste final (`fit$weights`, ou `weights(fit, type = "working")`), e não os pesos *a priori* (que valem 1 e reproduziriam a projeção por MQO). Teste: max|W − μ̂|/μ̂ < 1e-8.
- **Teste da projeção:** max|X′W^{1/2}e*| ≈ 0 (tolerância numérica) nas séries projetadas. É identidade algébrica: confere a implementação, não a qualidade da nula. **Controle negativo:** a projeção por MQO tem de **falhar** nesse teste quando os pesos não são constantes; ele pega o erro de usar os pesos *a priori*.
- **Semente:** a do complemento, C1, item 4 (`20261001 + i`, com o `kind` explícito).
- **Natureza:** a PACF e a sua nula são descritivas; nenhuma decisão depende delas (D3). A diferença entre as duas nulas é desprezível (seção A).
- **Rótulo:** esclarecimento de implementação.

## 3. P6: `z_fetal` em Z, com o w_j do principal

- **Decisão: aprovada a proposta do A1.** Na sensibilidade "`z_nv` + `z_fetal` em Z", Z_tj = `z_nv` + `z_fetal`, tanto em Z_t quanto em W_t = Σ_j Z_tj·w_j / Z_t. O **w_j é o do principal** (risco condicional de parto na semana j, a partir dos NV da coorte fixa, por concentração, no período inteiro; §3.1, l. 178). γ estimado, como no principal.
  - Os óbitos de `z_fetal` são os do `obito_fetal_principal` (gestação única, `SEMAGESTAC` de 22 a 42, coorte fixa 22).
- **Por quê, pela letra:**
  - a §3.1 define o w_j "a partir dos NV da coorte fixa" (l. 178);
  - quando a especificação quer o recálculo do w_j, ela diz: "consistência interna da IG (Z_t e w_j recalculados)" (§10.2, l. 597). Para esta sensibilidade, diz só "`z_fetal` em Z" (l. 197 e 596). A sensibilidade muda o conjunto em risco, não a definição do risco.
- **A alternativa (w_j recalculado sobre NV + óbitos fetais) é equivalente na prática:**
  - a forma do w_j muda menos de 0,6% entre as semanas 22 e 36 (seção A: 0,53% com riscos supostos; 0,57% com as contagens reais da Q8/Q11, pelo auditor);
  - a diferença entre as duas no log W_t é quase só de nível, que se cancela nos estratos (auditor: −0,0035 de nível e DP intra-mês de 3,5 × 10⁻⁶).
  - A primeira versão desta D16 escolhia o recálculo, por coerência com o conjunto em risco. O auditor mostrou que a letra favorece o w_j do principal, e o efeito é nulo na prática; fica a letra.
- **Declarar:** por construção, esta sensibilidade quase reproduz o principal. Incluir `z_fetal` muda log Z_t em cerca de +0,005 de nível, com DP intra-mês da ordem de 10⁻⁵ (auditor). O que ela pode mostrar vem da sazonalidade e do ruído próprios dos óbitos fetais em Z, não do w_j.
- **Rótulo:** esclarecimento de letra.

## 4. Nota sobre a busca entre p10 e p90 na curva combinada do A1

- **A leitura do A1 está correta.** A origem é a D8, 1.2(c): a regra de fronteira (RR contra a mediana e busca entre p10 e p90) vale **também** para a combinada, e a justificativa ali ("a §10.2 lista … sem restringir à concentração") trata do alcance (concentração × combinada), não da condição. A condição é a da §7 (l. 447, "Se a TMR cair na fronteira…"), confirmada pela adaptação da D8, 1.4, ao A1 ("A combinada só entra se cair na borda"). A TMR combinada do A1 é interior (q = 0,9378); fica só o IC bootstrap da busca nas 10 concentrações com TMR BLUP no p99.
- **Conferência do OSF:** a §10.2 lista "TMR: busca entre p10 e p90; RR contra a mediana" sem repetir a condição. O Claude Code confere o texto publicado no OSF e registra no log:
  - se o OSF trouxer a condição de borda, vale o parágrafo acima;
  - se listar as duas saídas **sem condição**, elas são reportadas como descritivas **na combinada e nas 26 concentrações** (não só nas 10 com TMR BLUP no p99), para não parecer que uma sensibilidade pré-registrada foi retirada depois do primário. Como a TMR combinada está em q = 0,9378, acima de 0,90, a busca entre p10 e p90 na combinada tende a cair na borda p90; nesse caso, sai com a marca de borda e sem nova busca (D8, 1.2(d)).

---

## Registro no log (antes da C1 no A1; antes da sensibilidade correspondente no A2)

> - **D16 (16/10):** `spec/decisoes_metodo_20261016_AGUDOS_D16_ns_tempo_nula_pacf_zfetal.md` (SHA-256 ⟨conferido⟩). Depois das Fases 2 e 3, antes de qualquer saída da Fase 4.
>   - P4: ns(tempo) com `round(gl × n_dias / 365,25)`: A1 74/99/123; A2 73/98/122; todos os dias da janela consecutiva, sem aquecimento. Esclarecimento de letra.
>   - P3: nula da PACF projetada por MQ ponderados (pesos de trabalho finais, `fit$weights`, com o teste de W), com teste da projeção e controle negativo. Esclarecimento de implementação.
>   - P6 (só A1): `z_fetal` em Z_t e no Z_tj de W_t, com o w_j do principal (NV); recálculo equivalente na prática (declarado). Esclarecimento de letra.
>   - Combinada: busca entre p10 e p90 e RR contra a mediana só na borda (D8, 1.2(c) e 1.4); texto do OSF conferido: ⟨condicional / sem condição → descritivos na combinada e nas 26, com marca de borda⟩.

---

## A. Auditoria

### A.1 Autoauditoria (reprodução própria, `repro_d16.py`)

| Ponto | Reprodução | Resultado |
|---|---|---|
| gl totais | 6, 8 e 10 × n_dias/365,25 | A1: 73,889 / 98,519 / 123,149; A2: 73,199 / 97,599 / 121,999 |
| Anos civis tocados pela janela do A1 | Python (`datetime`) | 13 |
| MCC 2015 usa gl × anos civis | `00.prepdata.R`, l. 70 | Confirmado |
| Identidade do escore X′W^{1/2}r_P = 0 | Poisson com estratos ano × mês, dia da semana (sáb. −35%, dom. −45%) e temperatura; IRLS próprio | Mediana de 1,4 × 10⁻¹⁰ e 3,8 × 10⁻¹⁰ |
| Nulas MQO × ponderada × viés verdadeiro (200 réplicas; 1.000 séries por nula) | 3 eventos/dia | Diferença entre nulas ≤ 0,0004; distância ao verdadeiro: MQO 0,0034, ponderada 0,0030 |
| Idem | 40 eventos/dia | Diferença ≤ 0,0004; distância: MQO 0,0018, ponderada 0,0019. Limite 2/√n = 0,030 |
| Forma do w_j com óbitos fetais | Coorte com riscos competitivos; óbito fetal suposto de 0,0004/semana (22–36) e 0,0006 (37–42) | Razão w_rec/w_NV de 0,9925 a 0,9978 nas semanas 22–36 (amplitude de 0,53%). Com as contagens reais da Q8/Q11 (auditor): 0,99167 a 0,99737 (0,57%) |

Os números do A1 e do auditor dele (diferença entre as nulas de 0,0005 a 0,0007) são reproduzidos na ordem de grandeza.

### A.2 Auditoria independente

O auditor (subagente em contexto limpo, scripts próprios `a16_gl.py`, `a16_pacf.py` e `a16_wj.py`; não abriu o script do autor) não achou nenhum erro crítico; achou 6 Menores e 8 Notas. Cada achado foi conferido por mim (leitura das linhas citadas ou código) antes de ser aceito. A simulação dele foi encerrada a pedido: os cenários de 3 e 40 eventos/dia têm 400 réplicas; os de pesos extremos, só 20 (imprecisos); o de 0,3 evento/dia não foi reproduzido.

| Achado | Grav. | Minha conferência | Correção |
|---|---|---|---|
| 1. P6: a citação da §3.1 omitia "a partir dos NV da coorte fixa"; a §10.2 diz "Z_t e w_j recalculados" quando quer o recálculo (l. 597), e não diz isso aqui (l. 197 e 596) | Menor | Linhas 178, 197, 596 e 597 da v2.0.2: confirmado | **Decisão do P6 revertida para a proposta do A1** (w_j do principal); rótulo de letra com a citação inteira |
| 2. Mérito do P6: as duas opções são equivalentes na prática | Nota | Minha forma do w_j (0,53%) bate com a dele com dados reais (0,57%) | Equivalência declarada |
| 3. "Z e W recalculados" da solicitação v3 não distingue as opções | Menor | Álgebra: W_t muda nas duas, pelo Z_tj | Argumento retirado |
| 4. A §3.2 citada foi emendada pela D6 (PD_j) | Nota | D6, 1.2, item 2 | Argumento retirado junto com a decisão |
| 5. Amarrar os óbitos do `z_fetal` | Nota | D6, 1.5; §3.2 | `obito_fetal_principal` citado |
| 6. Usar a Q8/Q11 em vez de riscos supostos | Nota | Resultado do auditor na mesma ordem | Número real acrescentado |
| 7. ns(tempo): quais dias entram | Menor | §2.1, l. 134: a remoção de estratos vazios pressupõe estratos | Todos os dias da janela consecutiva, sem aquecimento |
| 8. A regra do gl só vale na janela consecutiva | Nota | Com lacuna de 2020–21, o "gl por ano" perde o sentido | Alcance escrito |
| 9. A ortogonalidade é exata; a aproximação é r_P ≈ (I − H_W)ε e deviance ≈ Pearson | Nota | IRLS próprio: 1,4 × 10⁻¹⁰ (auditor: 1,5–2,2 × 10⁻¹²) | Redação corrigida |
| 10. O teste da projeção é identidade; falta conferir a fonte de W | Menor | Por construção | W = pesos de trabalho, com teste |
| 11. Diferença das nulas desprezível com pesos realistas | Nota | Minha diferença ≤ 0,0004; a dele ≤ 0,0008 | Sem correção |
| 12. A origem da regra na combinada é a D8, 1.2(c) | Menor | D8, l. 44 e 64 | Citação corrigida |
| 13. Conferência do OSF só cobria a combinada; busca na combinada tende à borda p90 | Menor | §10.2, l. 599; D8, 1.2(d) | Estendida às 26; marca de borda sem nova busca |
| 14. Citações conferidas; marcador ⟨AUDIT⟩ | Nota | — | Seção preenchida |

| Script | SHA-256 |
|---|---|
| `repro_d16.py` | `e6d5b71807c6261e4e76f4636740c923a181068d80cee8bd562500e6f0df2b02` |
| `a16_gl.py` (auditor) | `17868842083f17cc3f988dcdcb27fc32f6b16138cb84f6a72e6162f233fb1d35` |
| `a16_pacf.py` (auditor) | `3f3d060f67f8325a9d71942e0b694872a2f53535f4ea91e9cbd61302efcf73e6` |
| `a16_wj.py` (auditor) | `e6cccfa2bfd2f5e71cae9e41e1fd6d95da8869f4968dfd4a6846e56759d70e2b` |

**Não verificado:** não há R neste ambiente; nada foi executado em R. O SHA do plano da Fase 4 não foi conferido (o arquivo não está aqui). O texto do OSF não foi lido.
