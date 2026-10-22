# Fase 4, M4 v3: auditoria interna (contexto limpo)

- **Data:** 2026-10-20 (pelo `date`: 09:39:45 -0300 no meio da auditoria; log gravado às 09:42:19 -0300).
- **Executor:** subagente em contexto limpo. Leu só scripts, logs, saídas agregadas (`01_saidas/fase4/*.csv`), o texto v2 e v3, os `.docx` e `../spec/`. Não abriu `.parquet`, `.dbc`, `serie_*.rds` nem nada da base, salvo as colunas `data_hora`, `sistema` e `url` de `dados_artigos_perinatais_clima/logs/integridade.csv`.
- **Rede:** só o MCP do PubMed. Nada de curl, wget ou WebFetch.
- **HEAD:** `d35218d` (ramo `main`). Nada foi escrito no git.
- **Entradas conferidas por SHA-256 (iguais aos registrados no log do 90, na A1-132 e na A1-133):**
  - `manuscrito/m4/manuscrito_v3_20261019.md`: `1ac48986…7c11`;
  - `manuscrito/m4/suplemento_v3_20261019.md`: `0cd4b301…a194`;
  - `manuscrito/m4/tabS5_decisoes_v3_20261019.csv`: `24659cdb…e1e7`;
  - `logs/busca_evidencia_brasileira_20261020.md`: `013cbc94…3198`;
  - `logs/mensagem_chat_A1_auditoria_M4_v3_20261020.md`: `e6dd6250…764f`.
  - Os `.docx` de `Submissao/` são idênticos byte a byte aos `manuscrito/m4/*_v3_20261019.docx`.
- **Rascunhos (scratchpad `auditoria_m4v3/`):** `contagem.py` (`6af8d9b6…7dd3`), `diff_manuscrito_v2_v3.txt` (`fba4f218…afba7`), `diff_suplemento_v2_v3.txt` (`171a8ea2…7912`).

## 1. Veredito

- **Nenhum achado Crítico ou Maior. Nenhum número do texto está errado.** Os números novos e os que mudaram de lugar conferem com as saídas:
  - 1,029 e 1,051 = `rr99_ls` e `rr01_ls` do P0;
  - 47 = 41 linhas da tabela de sensibilidades (44, menos P0, NB e N2000) mais as 6 chaves (a chave 4 é diferente da C3-P1);
  - 16 = 8 lags × 2 percentis.
- **As 8 correções do chat foram feitas.** Os itens 1, 2, 4, 5, 6 e 7 foram cumpridos.
  - O item 3 foi cumprido no Abstract, mas não no Glance C (decisão A1-133(e)).
  - O item 8 foi cumprido, menos o BR-DWGD.
- **11 Menores e 15 Notas,** de redação, rótulo e documentação.
- **Regras cumpridas:**
  - contagens reproduzidas;
  - Glance com 128 palavras;
  - Abstract sem abreviação;
  - duplo-cego limpo (texto e metadados dos `.docx`);
  - nenhum "first", "novel" ou "unprecedented" de novidade;
  - `.docx` sem texto justificado.

## 2. Tabela de achados

| # | Grav. | Local | Evidência | Correção sugerida |
|---|---|---|---|---|
| 1 | Menor | Tabela S5, escopo; Methods, "Deviations were recorded … (Supplementary Table S5; full log …)" | O Methods remete à S5 como lista de desvios, mas a S5 só traz as decisões posteriores ao primário. A D1 (AF principal *forward*, e não o *backward* da §7 do plano) e a D2 (base da curva combinada, que "toca o contraste primário", A1-69) ficam fora. A nota da S5 diz que elas estão "no log completo", que o revisor não vê (repositório cego). A D3 entra, mas é do mesmo documento e da mesma data da D1 e da D2, registrada antes da segunda etapa (A1-70). O critério "depois do primário" não separa a D3 da D1 e da D2 | Marcador para o chat. Opção (a): acrescentar duas linhas à S5, D1 e D2, com "decided before the pooled results; first-stage fits seen", e retitular a S5 como "Decisions taken after the analysis plan was frozen". Opção (b): manter a S5 e, no Methods, dizer que o plano previa a perspectiva *backward*. Nenhuma das duas mexe no texto principal além de ~10 palavras |
| 2 | Menor | Tabela S5, D8 | O rótulo único "Post hoc" cobre o item 1.2(c) da D8, que é **pré-especificado** (§7 e §10.2: RR contra a mediana e busca entre p10 e p90). Pela D8, (b) e (d) são *post hoc* e (a) é interpretação. "MRT at the grid boundary" deveria ser a borda da faixa de busca (p1 ou p99) | "Interpretation (a); post hoc (b, d); prespecified sensitivity analyses (c)". Trocar "grid boundary" por "boundary of the search range" |
| 3 | Menor | Tabela S5, D9 | O rótulo diz "Prespecified". O cabeçalho da D9 dá esse rótulo para o A3. Neste artigo, a própria linha diz "no effect on this article", e a D14, equivalente, está como "Not applicable" | "Not applicable (prespecified for another analysis)" |
| 4 | Menor | Tabela S5, D11 | "strata by day of week" não é item da D11: os estratos com dia da semana já estavam na §10.2 da especificação. A D11 trata do Natal, de 2020–21, dos feriados locais, da `arglag`, da S3, da uma etapa, de φ e da estação quente. Falta o item 2 (*fallback* como regra) | Tirar "strata by day of week" e acrescentar "fallback rule". A coluna de uso de resultado mistura "a decisão usou resultado" com "a análise usa a MRT do primário como insumo". Basta deixar claro: "No for the decisions; the penalized DLNM uses the primary pooled MRT as input" |
| 5 | Menor | Tabela S5, D12 | O rótulo "Post hoc choice (offset) and clarification (coefficient rule)" omite que o 4.2 (w_j por ano de entrada) e o 4.3 (braço de 2011) também são escolhas *post hoc*. O corte de 1.000 por subtipo é "escolha (extensão do critério)" | "Post hoc choices (offset, exclusion rule, year-of-entry weights, 2011 arm); clarification (coefficient rule)" |
| 6 | Menor | Tabela S5, D13, item 3 | O rótulo "Clarification; descriptive RR post hoc" não bate com a D13, §3, "Rótulos": "(a) é interpretação; (b) e o RR descritivo são *post hoc* no A1 e no A2". O "contrast equal to 1 without CI" é o (b), logo *post hoc* | "Interpretation (side); boundary contrast and descriptive RR post hoc" |
| 7 | Menor | Referências; item 8 do chat | O chat manda tirar a data de acesso do log de download do BR-DWGD. O `integridade.csv` tem BR-DWGD baixado do Google Drive em **2026-10-02** (10 registros, BR-DWGD e BR-DWGD-zip). A A1-132(9) decidiu "citado pelo artigo (DOI), sem data de acesso", o que contraria o pedido. A frase "BR-DWGD, CAMS, and human development index data from their public repositories [Xavier2022; …]" cita um artigo, não um repositório | Acrescentar a referência do conjunto de dados (BR-DWGD v3.2.4 [dataset], repositório dos autores, "Accessed October 2, 2026") ou levar ao chat a decisão de não citar o conjunto |
| 8 | Menor | Glance C; item 3 do chat | O chat pediu a forma "compatible with … up to … (upper 95% confidence limits)" na Conclusion do Abstract **e** no Glance C. O Glance C ficou sem limites e ganhou "in a design that accounts for the pregnancies at risk" (A1-133(e)). O exagero sumiu, mas a instrução não foi cumprida à letra. A oração nova aparece como o que o estudo "acrescenta", enquanto a Comment diz que os estudos dos EUA também consideraram as gestações em risco | Marcador para o chat: ratificar a A1-133(e) ou usar a forma prescrita. Se ficar, trocar por "in Brazil, with a design that accounts for …" para não sugerir contraste com os EUA |
| 9 | Menor | Busca, `logs/busca_evidencia_brasileira_20261020.md`, seção 4 | O chat pediu termos em inglês e português. Os termos em português só foram usados no SciELO e no LILACS, que deram 403; no PubMed, todas as consultas foram em inglês. O log não diz isso como lacuna. Reproduzi no PubMed `(temperatura OR calor OR "onda de calor") AND (prematuridade OR "parto prematuro" OR "nascimento prematuro" OR "pre-termo")` em 20/10/2026: **0** resultados | Acrescentar às lacunas: "termos em português efetivamente pesquisados só no PubMed (0 resultados, conferido pela auditoria); SciELO e LILACS inacessíveis". Também: só 9 capitais em P2 (não as 26 sedes) |
| 10 | Menor | Strengths and Limitations, "this probably nondifferential misclassification would bias associations toward the null" | O chat escreveu "tende a atenuar". Com exposição por área, o erro é sobretudo de tipo Berkson: perde precisão e não garante viés para o nulo, sobretudo numa curva não linear. A afirmação é mais forte que a evidência | "…which would mainly reduce precision and tend to attenuate associations." Mesmo número de palavras, ±2 |
| 11 | Menor | Referência 15 (Fitch) | No PubMed, o PMID 40392097 traz DOI **10.1289/EHP15953**, *epub* em 20/05/2025, sem volume nem páginas. O texto traz 2026;134(2):184-194, doi:10.1021/ehp.6c00358. O CSV diz que foi conferido no doi.org e no Crossref; não pude conferir (rede só PubMed). O título no PubMed diz "…Impacts Dataset", e a referência diz "…Impacts Data Set". Vem da v2 | Não conferido. Conferir se o 10.1021 é a versão de registro do mesmo artigo. Se não for, usar o DOI do PubMed. Ver também "Strickland M" (PubMed) contra "Strickland MJ" |
| 12 | Nota | Comment, "Like those studies, we accounted for the ongoing pregnancies at risk" | No Darrow 2024, o offset de gestações em risco é a análise principal (abstract: "offset by pregnancies at risk"). No Fitch, o principal é um case-crossover; o ajuste pelo conjunto em risco é análise adicional (abstract: "We also calculated ORs adjusting for temporal changes in the pregnancy risk set"). A frase é defensável, mas generaliza | Se houver folga: "Like those studies (in a main or additional analysis), …" |
| 13 | Nota | Introduction, "Brazilian evidence includes …" | O conteúdo confere com os abstracts do PubMed: Libonati, "we show that HWs were responsible for increasing … preterm births"; Rocha, OR ≈ 1,02 com a seca; Ribeiro-Silva, protocolo sem resultado. Mas a lista mistura seca (não é temperatura) e um protocolo (não é evidência) sob "evidence" sobre temperatura. Não sugere completude | "Brazilian evidence on climate and preterm birth includes …" (+3 palavras) |
| 14 | Nota | Tabela S5, D3 | "Used results: No (simulation only)". A A1-70 registra que a PACF dos resíduos reais da primeira etapa foi vista antes da decisão (25 de 26 sinalizadas), embora a decisão não dependa disso. A D3 foi tomada antes dos resultados combinados | "No (decided by simulation; first-stage residual autocorrelation had been seen)" |
| 15 | Nota | Strengths and Limitations, "The results apply to live births in large urban areas, not to non-urban populations" | Mais categórico que "a generalização fica limitada" (chat) | "…and may not apply to non-urban populations" |
| 16 | Nota | Strengths and Limitations, "The fetal-death analysis nearly reproduces …" | Ambíguo: dá para ler como análise com óbito fetal como desfecho. A v2 dizia "the analysis that added fetal deaths to the pregnancies at risk" | "The analysis adding fetal deaths to the pregnancies at risk …" |
| 17 | Nota | Comment, "Differences in the exposure contrast and setting may contribute:" | Contribuir para quê? A v2 dizia "to these contrasts". Fica pendurado depois da frase do Iñiguez | "…may contribute to these differences:" (+3) |
| 18 | Nota | Research Implications | Mudança não pedida: caiu "and the seasonality of conceptions". Foi compensação fora das seções que o chat indicou (Strengths ou Results in the Context). O sentido estreita pouco (o W_t cobre a sazonalidade), mas a recomendação perde um dos dois vieses centrais do artigo | Repor, se houver folga, ou registrar como compensação |
| 19 | Nota | Strengths and Limitations, "the pattern suggests a calculation convention, nondifferential with respect to daily temperature" | Na v2: "which would be nondifferential" (condicional). Na v3, a aposição lê como afirmação | "…convention, which would be nondifferential …" (+2) |
| 20 | Nota | Limitations, "47 sensitivity and exploratory analyses" | Correto, mas o número não aparece em lugar nenhum e não se reconstrói fácil pela Tabela S1 (44 linhas, com o primário, a NB não disparada e o corte de 2.000) mais a Tabela 3 (6 chaves). O chat citou 44 | Nota de rodapé da S1: "41 analyses in addition to the primary and the 6 key analyses (Table 3)" |
| 21 | Nota | Contagens | Abstract com 400 palavras exatas (394 sem os rótulos) e Comment com 907 (piso de 900). Qualquer edição das Notas acima pode romper um dos dois | Contar de novo depois de qualquer ajuste |
| 22 | Nota | Datas de acesso, URLs | As datas conferem, mas o URL citado não é o acessado. SINASC e SIM foram baixados de `ftp.datasus.gov.br`; a referência cita `dadosabertos.saude.gov.br`. O IBGE foi baixado do `geoftp.ibge.gov.br` (base de dados, 2ª ed.); a referência cita o PDF do livro | Citar o caminho do FTP do DATASUS e a base do geoftp, ou aceitar como convenção |
| 23 | Nota | Referências de R e do gnm, "Accessed October 8, 2026" | Segue a regra do chat ("se faltar alguma, use a data de congelamento da base 4443971b, com nota no log") e está anotado na A1-132(9). É uma convenção, não uma data de acesso observada. Fica a inconsistência com o item 7: o fallback foi usado onde não há log (R e gnm), e o BR-DWGD, que tem log, ficou sem data | Nada a corrigir além do achado 7 |
| 24 | Nota | Ordem de citação (vem da v2, salvo a S5) | No texto principal, a S5 é citada antes da S1, e a Figura 3 (Results, §3) antes da Figura 2 (§4). A Tabela S3 não é citada em lugar nenhum, nem no texto nem no suplemento | Renumerar (S5 → S1 etc.) ou reordenar as citações; citar a S3 |
| 25 | Nota | Conclusion do Abstract, "a delayed association with cold could not be excluded" | Vem da v2. Os Results do Abstract não mostram a base dessa frase (lags 6 e 7, lag 0–14 e 0–21) | Opcional. Exigiria palavras, e o Abstract está em 400 |
| 26 | Nota | Busca, uso do WebFetch para Crossref e Research Square | O chat mandou User-Agent genérico em toda consulta externa. O log não registra o cabeçalho usado | Não conferido. Registrar, se souber |

## 3. Diff v2 → v3 (frase a frase) e aderência ao chat

**Manuscrito** (13 trechos; Results e Methods intocados, salvo 1 frase do Methods):

| # | Local | Antes (v2) | Depois (v3) | Item do chat | Atende? |
|---|---|---|---|---|---|
| 1 | Glance C | "In Brazil, … relative risks above 1.029 for heat and 1.051 for cold were excluded." | "In large Brazilian cities, … not clearly associated …, in a design that accounts for the pregnancies at risk." | 3 | Em parte (achado 8) |
| 2 | Contagem | 432 / 2,972 | 400 / 2,962 | — | Mecânico; confere |
| 3 | Abstract, Background | 2 frases ("Exposure to high and low …"; "Brazil spans … at scale.") | 1 frase ("High and low ambient temperatures have been …") | 6 (compensação) | Sim. Perde a justificativa "por que o Brasil" no Abstract (aceitável) |
| 4 | Abstract, Study Design | "(277 municipalities)"; "the number of ongoing pregnancies … as an offset"; "daily mean temperature of the core city" | sem "(277 …)"; "ongoing pregnancies … as the offset"; "core-city daily mean temperature" | 6 | Sim; sentido igual |
| 5 | Abstract, Results | "the minimum-risk temperature (28.2 °C) was imprecisely estimated (95% …" | "…was imprecisely estimated (28.2 °C; 95% …" | 6 | Sim; sentido igual |
| 6 | Abstract, Conclusion | "the 95% confidence intervals excluded cumulative relative risks above 1.029 for heat and 1.051 for cold, although …" | "the data were compatible with cumulative relative risks of up to 1.029 at the 99th temperature percentile and up to 1.051 at the 1st percentile (upper 95% confidence limits), and …" | 3 | Sim, literal do chat; sem abreviação |
| 7 | Introduction, último §, frases 1–2 | "…span equatorial cities with little seasonal variation and subtropical cities with cool winters, which allows …"; "Brazilian evidence has come from [Silveira2025] and from a nationwide preprint … rather than ongoing pregnancies, as the denominator [Couto2026]." | "…range from equatorial to subtropical climates."; "Brazilian evidence includes a review … [Libonati2022], a nationwide cohort … drought … [Rocha2026], a nationwide preprint that used daily live births as the offset and found U-shaped curves in cold and moderate regions and higher risk at lag 0 in warm regions [Couto2026], and an ongoing study … [RibeiroSilva2025]." | 1 (+ compensação na 1ª frase) | Sim. O Silveira 2025 saiu (não pedido; não é PTB; A1-133(a)). A caracterização do Couto confere com o texto completo ("is the offset term (logarithm of total daily births)") e com o abstract ("colder and moderate temperature regions … U-shaped"; "most evident at lag 0" nas regiões quentes) |
| 8 | Methods, Study design | "(deviation log available with the analysis code)" | "(Supplementary Table S5; full log available with the analysis code)" | 7 | Sim (ver achado 1) |
| 9 | Comment, Results in Context | frase do Couto; "Differences in design may contribute to these contrasts: we modeled …, an approach that removed bias in simulations; contrasted whole-year temperature extremes …; and assigned core-city temperature …"; "…; this was not a prespecified hypothesis and should be examined in other populations." | sem a frase do Couto (foi para a Introduction); "Differences in the exposure contrast and setting may contribute: the US studies compared heat-wave days, defined by local thresholds in the warm season, with other days, whereas we contrasted extreme percentiles of the whole-year distribution with an estimated MRT, in tropical and subtropical climates, with core-city temperature as the exposure. Like those studies, we accounted for the ongoing pregnancies at risk, here with their weighted probability of delivery."; "…, which was not a prespecified hypothesis." | 2 (+ compensação) | Sim. As 4 diferenças do chat estão lá; sem contrapor aos EUA. O Darrow confere no abstract (estação quente de maio a setembro, p97,5 local, offset de gestações em risco), e o Fitch também (maio a setembro, p97,5 local; conjunto em risco em análise adicional, achado 12). "should be examined in other populations" caiu (compensação) |
| 10 | Clinical Implications | "do not support short-term ambient temperature as an important trigger …, nor temperature-based changes in obstetric care aimed at preventing preterm birth." | "do not provide evidence that short-term ambient temperature is an important trigger … and, on their own, do not justify temperature-based changes in obstetric care." | 5 | Sim, literal do chat |
| 11 | Research Implications | "…account for the pregnancies at risk and the seasonality of conceptions, report …" | "…account for the pregnancies at risk, report …" | — | Compensação não pedida, fora das seções indicadas (achado 18) |
| 12 | Strengths | "This study used a national registry with 13.5 million births in 26 urban concentrations spanning …, …, and post hoc analyses of the analytic pipeline under no association." | "Strengths include a national registry of 13.5 million births across …, …, and a prespecified analysis plan with a closed list of sensitivity analyses." | 4 (compensação) | Sim. Caem as análises post hoc nulas como força, o que é aceitável: elas seguem no 2º § |
| 13 | Limitations, 3º § | (a) "common relative scale, so a given percentile corresponds to different absolute temperatures …; … does not correspond to cold"; (b) "near 36 and 37 weeks"; (c) "a calculation convention, which would be nondifferential"; (d) "Exposure was assigned from the core city, although the municipal case time series gave similar results, and local holidays …"; (e) "By construction, the analysis that added fetal deaths …; the municipal human development index is a population-weighted approximation from 2010, before the study period; … different quantities from the primary model; and the upper limit of the CI …" | (a) "uses a common percentile scale, and … the 1st percentile is not cold in absolute terms"; (b) "near 37 weeks"; (c) "a calculation convention, nondifferential with respect to daily temperature"; (d) **novas:** "Exposure was outdoor core-city (or municipal) temperature assigned by residence at birth, without individual, indoor, or mobility data; this probably nondifferential misclassification would bias associations toward the null. With 47 sensitivity and exploratory analyses and 16 lag-specific estimates, the few CIs that excluded 1 should be read in light of multiple comparisons. The results apply to live births in large urban areas, not to non-urban populations, and local holidays were available only for the core municipality."; (e) "The fetal-death analysis nearly reproduces … by construction, the human development index is an approximation from 2010, … different quantities, and the upper CI limit …" | 4 (+ compensação) | Sim, as 3 ameaças estão lá. Ressalvas nos achados 10, 15, 16 e 19. "municipal case time series gave similar results" caiu (o dado segue nos Results) |

**Suplemento (md):** um parágrafo novo ("The analysis plan was version-controlled before any outcome analysis. Decisions taken after the primary results were known, … are listed in Supplementary Table S5."), mais a Tabela S5, com nota, no `.docx`. Item 7: atende (achados 1 a 6 e 14).

**Referências (`.docx`):**
- Saiu Silveira 2025; entraram Libonati 2022, Rocha 2026 e Ribeiro-Silva 2025; total de 37 → 39.
- Todos os "Accessed [date to be confirmed]" foram preenchidos.
- O CAMS ganhou data.
- Item 8: atende, salvo o achado 7.

**Página de título:** só a contagem. **Highlights e legendas:** iguais à v2.

## 4. Verificações (código próprio)

### 4.1 Frases novas contra as fontes (PubMed, 20/10/2026)

Os metadados e abstracts saíram do PubMed (NLM) pelo MCP.

- **Libonati 2022:** PMID 36052446, doi:10.1111/nyas.14887; *Ann N Y Acad Sci* 1517(1):44-62; tipo Review. O abstract sustenta "a review reporting more preterm births during heat waves in record-breaking droughts in southeastern Brazil". **Confere.**
- **Rocha 2026:** PMID 42502500, doi:10.1016/j.lana.2026.101570; *Lancet Reg Health Am* 62:101570. O abstract traz a coorte de 2001–2020, ~29,8 milhões de nascidos vivos, OR ≈ 1,02 para PTB em todas as janelas de seca. **Confere** com "a nationwide cohort in which drought was associated with preterm birth".
- **Ribeiro-Silva 2025:** PMID 41019574, doi:10.12688/wellcomeopenres.23909.2; *Wellcome Open Res* 10:169. Protocolo; o PTB está entre os desfechos. **Confere** com "an ongoing study of heat and birth outcomes".
- **Darrow 2024:** PMID 38787560, doi:10.1001/jamanetworkopen.2024.12055. Abstract: "restricted to the warm season (May to September) … offset by pregnancies at risk"; RR de 1,02 (1,00–1,03). **Confere.**
- **Fitch:** PMID 40392097, doi:10.1289/EHP15953 no PubMed. Abstract: maio a setembro, "local 97.5%ile"; ORs de 1,015 e 1,019; ajuste pelo conjunto em risco como análise adicional. Ver os achados 11 e 12.
- **Couto 2026:** é preprint; li o texto extraído pela busca (`scratchpad/busca_br/couto_texto.txt`). O offset é "logarithm of total daily births" (Métodos, l. 141). O abstract (l. 39–41) traz as curvas em U nas regiões frias e moderadas, com associação no lag 7, e o lag 0 nas regiões quentes. **Confere.**
- **Conclusion do Abstract e Glance:** os números conferem (achado 8 para o Glance C).
- **"47 sensitivity and exploratory analyses":**
  - `tabela_sensibilidades_fase4_v2.csv` tem 44 linhas;
  - saem P0, C3-NB ("não se aplica") e C3-N2000 ("idêntico ao principal"), o que deixa 41;
  - `criterio_c1_fase4_20261019.csv` tem 6 chaves; a chave 4 (`pm25_local_nucleo`, 26 concentrações) é distinta da C3-P1 (`pm25_local_zero_na_nucleo`, 23);
  - total de 47. **Confere** com a A1-133(d).
- **"16 lag-specific estimates":** confere.
- **Clinical Implications:** literal do chat.

### 4.2 Busca documentada

- **O log tem:** bases, consultas exatas, data e hora, N, triagem e relevantes; o furo dos plurais entre aspas; e as lacunas (403 no SciELO, no LILACS/BVS, no medRxiv e no Wiley; Research Square só pelo Crossref, com os 20 primeiros de cada consulta).
- **Reproduzi no PubMed:** P1 = **111** e P3 = **148**, iguais aos do log.
- **A frase da Introduction é coerente com a busca.** A busca não achou estudo primário revisado por pares sobre temperatura de curto prazo e PTB só do Brasil, e o texto não alega lacuna. "Includes" não sugere lista completa.
- **Faltam no log:** a lacuna dos termos em português (achado 9) e o User-Agent (achado 26).

### 4.3 Tabela S5 contra os documentos de decisão

| Decisão | O que foi decidido | Rótulo | Uso de resultado |
|---|---|---|---|
| D3 | Ok | Ok (*post hoc*, regra defeituosa) | Ver achado 14 |
| D5 + errata | Ok | Ok | Ok ("Yes") |
| D8 + errata | Ok ("grid boundary", achado 2) | **Achado 2** | Ok |
| D9 | Ok | **Achado 3** | Ok |
| D10 | Ok (1a–1e) | Ok (4 esclarecimentos + 1d *post hoc*) | Ok |
| D11 | **Achado 4** | Ok ("by item") | Ok (exceção declarada da S3) |
| D12 | Ok | **Achado 5** | Ok |
| D13 (3) | Ok | **Achado 6** | Ok |
| D14 | Ok | Ok | Ok |
| D15 | Ok | Ok | Ok |
| D16 | Ok | Ok | Ok |
| D17 | Ok | Ok | Ok |

As datas das linhas conferem com os cabeçalhos. Os documentos D1–D3, D5, errata da D5, D8, errata da D8, D9 a D17 foram lidos em `../spec/`.

### 4.4 Datas de acesso

Do `integridade.csv` só li `data_hora`, `sistema` e `url`. Última baixada real, sem contar "(cache local)":

| Sistema | Último download | Texto | Confere? |
|---|---|---|---|
| SINASC | 2026-10-02: 377 do FTP em 02/10 e 1 em 01/10; o registro de 03/10 é "(cache local)" | October 2, 2026 | Sim |
| SIM (DO, DOFET) | 2026-10-02 | October 2, 2026 | Sim |
| CAMS-EAC4 | 2026-10-05 | October 5, 2026 | Sim |
| IBGE-ARRANJOS | 2026-10-06 | October 6, 2026 | Sim (URL: achado 22) |
| BR-DWGD | 2026-10-02 (Google Drive) | sem data | **Não** (achado 7) |
| Atlas (IDHM) | 19/10/2026 (`logs/idhm_atlas_fase4_20261019.md`) | October 19, 2026 | Sim |
| R 4.5.1 e gnm 1.1-5 | sem log | October 8, 2026 (congelamento da 4443971b) | Sim, pela regra do chat e com nota na A1-132(9) (achado 23) |

### 4.5 Regras

| Regra | Medido (`contagem.py`, sem títulos e sem chaves de citação) | Limite | Ok? |
|---|---|---|---|
| Abstract | 400 (394 sem rótulos) | ≤ 400 desejável | Sim |
| Methods + Results | 1.178 + 511 = 1.689 | ≤ 1.700 | Sim |
| Comment | 907 | 900–1.100 | Sim |
| Texto principal | 366 + 1.178 + 511 + 907 = 2.962 | ≤ 3.000 | Sim |
| Glance | 105 (128 com os títulos A–C) | ≤ 130 | Sim |

- **Abstract:** nenhum token em maiúsculas além do símbolo P.
- **Duplo-cego:** sem nomes, instituição, GitHub ou caminhos no md e no `.docx`; `dc:creator` e `lastModifiedBy` vazios.
- **Termos proibidos:** "first" só como "first stage"; sem "novel", "unprecedented", "preregistered", "registered protocol" ou "mothers".
- **Coerência entre formatos:** as 10 frases novas são idênticas no md e no `.docx`.

## 5. Não conferido

- O DOI 10.1021/ehp.6c00358, o volume e as páginas do Fitch (achado 11).
- O texto completo de Libonati e Iñiguez (403 na busca).
- O User-Agent das consultas por WebFetch.
- SciELO, LILACS e medRxiv (fora do escopo de rede desta auditoria).

## 6. Marcadores para Guilherme e o chat

1. **Escopo da S5:** incluir a D1 e a D2, ou declarar a troca *backward* → *forward* no Methods (achado 1).
2. **Glance C:** ratificar a A1-133(e) ou usar a forma prescrita (achado 8).
3. **BR-DWGD:** referência do conjunto de dados com "Accessed October 2, 2026", ou decisão de não citar (achado 7).
4. **Fitch:** qual DOI vale (achado 11).
5. **Rótulos da S5** (achados 2 a 6) e frases de Limitations (10, 15, 16, 19). São correções de texto, sem número; depois de qualquer ajuste, recontar o Abstract (400) e a Comment (907).

- **Resultado:** ok, com ressalvas (0 Crítico, 0 Maior, 11 Menores, 15 Notas).
