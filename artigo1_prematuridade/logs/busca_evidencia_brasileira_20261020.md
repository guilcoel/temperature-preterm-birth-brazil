# Busca registrada: evidência brasileira sobre temperatura ambiente e parto prematuro

- Data: 20/10/2026, entre 09:13 e 09:25 (BRT, -03), pela data do sistema.
- Executor: subagente da sessão do A1 (Claude Code). Não é revisão sistemática; é busca documentada para apoiar uma frase da Introduction do tipo "Brazilian evidence includes …", sem sugerir que a lista seja completa.
- Ferramentas: PubMed (MCP `search_articles`, `get_article_metadata`, `lookup_article_by_citation`) e WebFetch. Nada de curl/wget, git ou dados do projeto.
- Os achados vêm do abstract no PubMed ou, quando indicado, do texto completo de fato aberto. Nada foi preenchido de memória.
- Rascunhos (JSON do PubMed, texto extraído do PDF do Couto): `/private/tmp/claude-501/-Volumes-Forja-Doc-artigos-perinatais-clima/6d4610c5-e0df-431e-85f7-7b8046d5add8/scratchpad/busca_br/`.

---

## 1. Registro por base

### 1.1 PubMed

Triagem: os títulos de **todos** os registros retornados foram obtidos via `get_article_metadata` e lidos. Abriu-se o abstract quando o título sugeria exposição a temperatura, calor, frio, seca ou clima e desfecho de nascimento.

| # | Consulta exata | N | Triados | Relevantes / relacionados |
|---|---|---|---|---|
| P1 | `(temperature OR heat OR heatwave OR "heat wave" OR cold) AND ("preterm birth" OR "premature birth" OR prematurity OR "preterm delivery") AND (Brazil OR Brazilian)` | **111** (confirma a contagem da sessão principal) | 111 títulos; 6 abstracts | Iñiguez 2026; Ribeiro-Silva 2025 (protocolo). Excluídos após o abstract: Zhang 2024 (a exposição é PM2.5 de queimadas, não temperatura), Veras & Saldiva 2024 (revisão geral, sem dado brasileiro no abstract), Meherali 2024 e Hartinger 2024 (sem dado brasileiro de PTB). A maioria dos 111 é ruído: hipotermia neonatal, odontologia, heat shock proteins, materiais etc. |
| P2 | `("ambient temperature" OR heat OR heatwave) AND (preterm OR premature) AND ("Sao Paulo" OR "Rio de Janeiro" OR "Belo Horizonte" OR Salvador OR Fortaleza OR Recife OR Manaus OR Curitiba OR "Porto Alegre")` | **35** | 35 títulos (33 já em P1); 2 abstracts novos | **Libonati 2022** (não aparece em P1); Meherali 2024 (PLOS Glob Public Health, mapa global, excluído) |
| P3 (suplementar) | `(temperature OR heat OR heatwave OR heatwaves OR "heat waves" OR cold OR drought) AND (preterm OR premature OR prematurity OR "gestational age" OR "gestational length") AND (Brazil OR Brazilian)` | **148** | 37 títulos novos em relação a P1; 4 abstracts | **Rocha 2026** (seca); Bakhtsiyarava 2022 (relacionado: peso ao nascer a termo) |
| P4 (suplementar, plurais) | `("preterm births" OR "preterm deliveries" OR "premature births" OR "preterm labor" OR "preterm labour") AND (temperature OR heat OR heatwave OR heatwaves OR drought) AND (Brazil OR Brazilian)` | **4** | 4 | Iñiguez 2026, Libonati 2022 (as outras duas não são pertinentes) |
| P5 (suplementar) | `(temperature OR heat OR heatwave OR heatwaves OR climate) AND (preterm OR prematurity OR "gestational age" OR "birth outcomes") AND (SINASC OR "Live Birth Information System" OR "Live Births Information System")` | **2** | 2 | Del Carretto 2025 (relacionado: Apgar) |
| P6 (suplementar) | `("El Nino" OR "extreme weather" OR "extreme events" OR flood OR floods OR rainfall OR "climate change" OR "climate variability") AND (preterm OR prematurity OR "birth outcomes") AND (Brazil OR Brazilian OR Amazon OR Amazonia)` | **34** | 34 títulos (19 novos); 3 abstracts | Feldens 2025 e Requia 2022 (relacionados: peso ao nascer) |
| P7 (suplementar) | `(temperature OR heat OR heatwave OR heatwaves OR "extreme heat") AND ("birth outcomes" OR "pregnancy outcomes" OR "adverse birth" OR "perinatal outcomes") AND (Brazil OR Brazilian)` | **18** | 18 títulos (11 novos) | Requia & Papatheodorou 2024 (relacionado: anomalias congênitas) |
| P8 (suplementar) | `(temperature OR heat OR heatwave OR heatwaves) AND (preterm OR prematurity) AND ("Latin America" OR "South America" OR "Latin American" OR "low- and middle-income")` | **53** | 53 títulos; abstracts das 3 revisões de LMIC | nenhum estudo brasileiro novo; as revisões de LMIC (PMID 40953917, 39500870) não citam o Brasil no abstract |
| P9 (suplementar, autores) | `(Requia WJ[Author] OR Paixao ES[Author] OR Saldiva PHN[Author] OR Hacon S[Author] OR Barreto ML[Author] OR Gouveia N[Author]) AND (temperature OR heat OR heatwave) AND (preterm OR gestational OR birth)` | **9** | 9 | nada novo sobre PTB (Lancet Planet Health 2026 é sobre estado nutricional infantil) |
| P10 (estudo primário citado por Libonati) | `(Libonati R[Author] OR Geirinhas JL[Author] OR Monteiro Dos Santos D[Author] OR Rodrigues AP[Author] OR Trigo RM[Author]) AND (preterm OR premature OR birth OR births)` | **16** | 16 | nenhum estudo de calor e parto prematuro |

**Furo na consulta P1 (importa para o registro do método):** o PubMed não expande plurais em frase entre aspas. `"preterm birth"` não captura "preterm births". Por isso P1 perdeu Libonati 2022, cujo abstract diz "preterm births". P2 o recuperou pelas afiliações no Rio de Janeiro, e P3/P4 o recuperaram pelos termos sem aspas e pelos plurais. Recomendo que a frase do manuscrito não dependa da contagem de P1 isolada.

**Observação:** Iñiguez 2026 entra em P1 sem que o abstract cite o Brasil. A recuperação provavelmente vem da afiliação de um coautor (Requia WJ, FGV, Brasília). Por isso a recuperação não prova que o Brasil está entre os 13 países (ver 2.1).

### 1.2 SciELO

| Consulta / URL | Data e hora | Resultado |
|---|---|---|
| `https://search.scielo.org/?q=%28temperatura+OR+calor+OR+%22onda+de+calor%22%29+AND+%28prematuridade+OR+%22parto+prematuro%22+OR+%22nascimento+prematuro%22%29&lang=pt&count=50&from=0&output=site&sort=&format=summary&fb=&page=1` | 20/10/2026 ~09:20 | **HTTP 403. Não acessível em 20/10/2026.** |
| mesma consulta, sem codificação (`?q=(temperatura OR calor OR "onda de calor") AND (...)&lang=pt`) | idem | HTTP 403 |
| `https://search.scielo.org/?q=%28temperature+OR+heat+OR+heatwave+OR+%22heat+wave%22%29+AND+%28%22preterm+birth%22+OR+prematurity+OR+%22premature+birth%22%29&lang=en` | idem | HTTP 403 |

Número de resultados: não obtido. Nenhum contorno foi tentado.

### 1.3 LILACS/BVS

| Consulta / URL | Data e hora | Resultado |
|---|---|---|
| `https://pesquisa.bvsalud.org/portal/?q=%28temperatura+OR+calor+OR+%22onda+de+calor%22%29+AND+%28prematuridade+OR+%22parto+prematuro%22+OR+%22nascimento+prematuro%22%29` | 20/10/2026 ~09:20 | **HTTP 403. Não acessível em 20/10/2026.** |
| `https://pesquisa.bvsalud.org/portal/?q=%28temperature+OR+heat+OR+heatwave+OR+%22heat+wave%22%29+AND+%28%22preterm+birth%22+OR+prematurity+OR+%22premature+birth%22%29+AND+%28Brazil+OR+Brasil%29` | idem | HTTP 403 |

Número de resultados: não obtido.

### 1.4 medRxiv

| Consulta / URL | Data e hora | Resultado |
|---|---|---|
| `https://www.medrxiv.org/search/temperature%20preterm%20Brazil` | 20/10/2026 ~09:21 | **HTTP 403. Não acessível em 20/10/2026.** |
| `https://api.crossref.org/works?query.bibliographic=temperature+heat+preterm+birth+Brazil&filter=prefix:10.1101&rows=20` | ~09:21 | total-results **158**; os itens visíveis são todos artigos de periódicos da CSHL (Genes Dev, Genome Res etc.); nenhum preprint |
| `https://api.crossref.org/works?query.bibliographic=temperature+heat+preterm+birth+Brazil&filter=prefix:10.1101,type:posted-content&rows=20&select=DOI,title,author,posted,group-title` | ~09:22 | total-results **1**, irrelevante (Benlarbi 2024, Omicron) |
| `https://api.crossref.org/works?query.bibliographic=preterm+birth+temperature&filter=prefix:10.1101,type:posted-content&rows=20&...` | ~09:23 | HTTP 429 (limite de requisições); não houve nova tentativa |
| `https://api.crossref.org/works?query.bibliographic=ambient+temperature+heat+preterm+birth+Brazil&filter=prefix:10.1101,type:posted-content&rows=20&...` | ~09:24 | total-results **1** (o mesmo item irrelevante) |
| `https://api.crossref.org/works?query.bibliographic=preterm+birth+heat+temperature+Brazil&filter=prefix:10.1101&rows=20&select=DOI,title,author,posted,type` | ~09:24 | total-results **158**; 20 de 20 itens são `journal-article` |

Conclusão: por essas vias, o medRxiv **não ficou efetivamente pesquisável** em 20/10/2026. A busca do site devolve 403, e a busca do Crossref no prefixo 10.1101 não devolveu preprints do medRxiv. Fica como lacuna da busca.

### 1.5 Research Square (Crossref, prefixo 10.21203)

| Consulta / URL | Data e hora | N (total-results) | Triados | Relevantes |
|---|---|---|---|---|
| `https://api.crossref.org/works?query.bibliographic=temperature+heat+preterm+birth+Brazil&filter=prefix:10.21203,type:posted-content&rows=20&select=DOI,title,author,posted,group-title` | ~09:22 | 9447 | 20 primeiros títulos | nenhum preprint brasileiro sobre temperatura e PTB (aparecem Fano-Sizgorich 2022, Peru; Sanaullah 2026, revisão sistemática global) |
| `https://api.crossref.org/works?query.bibliographic=ambient+temperature+heat+preterm+birth+Brazilian&filter=prefix:10.21203,type:posted-content&rows=20&select=DOI,title,author,posted` | ~09:23 | 9075 | 20 primeiros títulos | **Couto 2026** (posição 2); Min 2023 (case-crossover nacional sem país no título, não identificado como brasileiro) |

Os totais do Crossref são de busca por relevância com semântica OR. Não medem quantos preprints são de fato pertinentes. Por isso só os 20 primeiros de cada consulta foram triados por título.

### 1.6 Fontes auxiliares (WebFetch)

- Europe PMC REST: metadados e acesso aberto de PMID 36052446, 41019574 e 42139755; lista de referências de 36052446; texto completo de PMC12461186.
- Crossref: metadados de 10.12688/wellcomeopenres.23909.2 e 10.21203/rs.3.rs-10756305/v1.
- Research Square: API (`/api/article/rs-10756305/v1`) e PDF do preprint, cujo texto foi extraído localmente com PyMuPDF (14 páginas; SHA-256 do PDF `f38e501d…6d0ad7`).
- Não acessíveis em 20/10/2026 (HTTP 403): página Wiley de Libonati 2022, ScienceDirect de Iñiguez 2026, página HTML da Wellcome Open Research (renderizou vazia; usei o PMC).

---

## 2. Estudos relevantes (desfecho: prematuridade)

| Chave | Citação (AMA) | PMID | DOI | Desenho | População/local | Exposição | Desfecho | Achado principal (fonte) |
|---|---|---|---|---|---|---|---|---|
| Iniguez2026 | Iñiguez C, Salvador C, Agay-Shay K, et al. The burden of premature births attributed to heat across 13 countries. *Environ Int*. 2026;212:110286. doi:10.1016/j.envint.2026.110286 | 42139755 | 10.1016/j.envint.2026.110286 | Série temporal multicêntrica (rede MCC), DLNM com quasi-Poisson, fração atribuível | 36,6 milhões de nascimentos na estação quente, 250 locais, 13 países. **O abstract não lista os países.** | Calor (estação quente) | PTB e subcategorias por idade gestacional | 1,4% (IC 95% 1,3–1,5) dos PTB atribuíveis ao calor, ou 855 PTB por milhão de nascimentos; carga nacional de 628 a 1.347 por milhão; maior risco no PTB tardio (abstract). **Inclusão do Brasil não confirmada na fonte primária** (texto completo com 403). O preprint Couto 2026 (Discussion) diz que esse estudo avaliou só as capitais brasileiras; é informação de segunda mão. |
| Rocha2026 | Rocha ADS, Dantas LG, Ferreira AJF, et al. Association between drought and adverse birth outcomes: a nationwide cohort study with 29.8 million live births in Brazil. *Lancet Reg Health Am*. 2026;62:101570. doi:10.1016/j.lana.2026.101570 | 42502500 (PMC13400957) | 10.1016/j.lana.2026.101570 | Coorte nacional, regressão logística | Brasil, 2001–2020, cerca de 29,8 milhões de nascidos vivos (8,0% pré-termo) | Seca (SPEI em 3, 6 e 9 meses). **Não é temperatura.** | PTB, BPN a termo, PIG | Seca associada a mais chance de PTB (OR ≈1,02 em todas as janelas). Dose-resposta no SPEI-6: moderada OR 1,01 (1,01–1,02), severa 1,03 (1,03–1,04), extrema 1,05 (1,03–1,06) (abstract) |
| Libonati2022 | Libonati R, Geirinhas JL, Silva PS, et al. Drought-heatwave nexus in Brazil and related impacts on health and fires: a comprehensive review. *Ann N Y Acad Sci*. 2022;1517(1):44-62. doi:10.1111/nyas.14887 | 36052446 | 10.1111/nyas.14887 | Revisão (com análise própria, ao que tudo indica) | Brasil; para PTB, o Sudeste durante secas recordes | Ondas de calor compostas com seca | Mortalidade e partos prematuros | O abstract afirma que os autores mostram que ondas de calor aumentaram a mortalidade e os partos prematuros durante as secas recordes no Sudeste. **O abstract não traz números**, e o texto completo não foi acessível (ver 3.1) |
| Couto2026 (preprint) | Couto LO, Jacobson LV, Caumo S, et al. Short-term effects of ambient temperature on preterm birth and effect modification by relative humidity across Brazilian regions: a nationwide time-series study. *Research Square*. Preprint postado em 1º de setembro de 2026. doi:10.21203/rs.3.rs-10756305/v1 | — | 10.21203/rs.3.rs-10756305/v1 | Série temporal por região, GAM binomial negativo com DLNM (lag 0–7) | Brasil, 27 UF, 2003–2023, 39.815.229 nascidos vivos únicos elegíveis (7,85% pré-termo) | Temperatura média diária (ERA5-Land); umidade relativa como modificadora | PTB de 28 a 36 semanas | Curvas em U no Sudeste e no Sul. Calor: RR 1,13 (1,07–1,18) a 32 °C no SE e 1,24 (1,17–1,32) a 31 °C no S. Frio: RR 1,14 (1,09–1,21) a 10 °C no SE e 1,16 (1,10–1,22) a 3 °C no S. Fração atribuível: SE 1,43%, S 2,42%, N 1,46%, NE 0,54% (texto completo). **Sem revisão por pares**; segundo a API do Research Square, está em avaliação na BMC Pregnancy and Childbirth |
| RibeiroSilva2025 (protocolo) | Ribeiro-Silva RC, Pepper M, Ribas de Farias Costa P, et al. Impact of heat on birth outcomes and child nutrition: study protocol using the CIDACS Birth Cohort. *Wellcome Open Res*. 2025;10:169. doi:10.12688/wellcomeopenres.23909.2 | 41019574 (PMC12461186) | 10.12688/wellcomeopenres.23909.2 | Protocolo (case-crossover, tempo até o evento, DLNM) | Coorte de Nascimentos do CIDACS (28.631.394 nascidos vivos, 2001–2018) | Altas temperaturas e ondas de calor | BPN, PIG, GIG, PTB, crescimento, aleitamento | **Sem resultados.** Só descreve o plano (ver 3.2) |

### 2.1 Relacionados (Brasil, temperatura, mas o desfecho não é PTB)

Não sustentam uma frase sobre prematuridade, mas podem sustentar uma frase sobre "related birth outcomes".

| Chave | Citação (AMA) | PMID | Achado (abstract) |
|---|---|---|---|
| Requia2022 | Requia WJ, Koutrakis P, Papatheodorou S. The association of maternal exposure to ambient temperature with low birth weight in term pregnancies varies by location: in Brazil, positive associations may occur only in the Amazon region. *Environ Res*. 2022;214(pt 2):113923. doi:10.1016/j.envres.2022.113923 | 35863440 | Caso-controle nacional, 2001–2018: só a região Norte teve associação positiva com BPN a termo, +5,16% (3,60–6,74) na chance por 1 °C de temperatura aparente no 2º trimestre |
| Bakhtsiyarava2022 | Bakhtsiyarava M, Ortigoza A, Sánchez BN, et al. Ambient temperature and term birthweight in Latin American cities. *Environ Int*. 2022;167:107412. doi:10.1016/j.envint.2022.107412 | 35870377 | Cerca de 15 milhões de nascimentos a termo urbanos (Brasil, Chile, México; SALURBAL): temperaturas mais altas na gestação associadas a menor peso, sobretudo no México e no Brasil (sem número no abstract) |
| Feldens2025 | Feldens TK, de Oliveira VR. Climate change and birth outcomes - evidence from Brazil. *Econ Hum Biol*. 2025;60:101565. doi:10.1016/j.ehb.2025.101565 | 41443008 | Cerca de 45 milhões de observações, 2000–2020: dias mais quentes e choques térmicos (inclusive frio) reduzem o peso ao nascer; 3º trimestre mais sensível (sem número no abstract) |
| DelCarretto2025 | Del Carretto M, Godin A, Neves D, et al. Short-term ambient heat exposure and low APGAR score in newborns: a time-stratified case-crossover analysis in São Paulo state, Brazil (2013-2019). *PLOS Glob Public Health*. 2025;5(9):e0004557. doi:10.1371/journal.pgph.0004557 | 40911592 | Calor no P95 (26,1 °C) vs P50 (20,9 °C) no lag 0–1: OR 1,08 (1,02–1,14) para Apgar de 5 min ≤7 |
| RequiaPapatheodorou2024 | Requia WJ, Papatheodorou S. Maternal exposure to ambient temperature and birth defects in Brazil: a nationwide case-control study of over 11 million newborns. *Int J Biometeorol*. 2024;68(11):2297-2305. doi:10.1007/s00484-024-02746-x | 39105774 | Temperatura mais alta no 1º trimestre associada a algumas categorias de anomalias (por exemplo, sistema digestivo OR 1,12 [1,06–1,19]) |

### 2.2 Excluídos após o abstract (motivo)

- Zhang Y, Huang W, Xu R, et al. *J Hazard Mater*. 2024;480:136290. doi:10.1016/j.jhazmat.2024.136290 (PMID 39476695). A exposição é PM2.5 de queimadas (HR 1,047 por 10 µg/m³ para PTB, 22,2 milhões de nascimentos). A temperatura aparece só como modificadora: associação mais forte em municípios quentes.
- Veras MM, Saldiva PHN. *J Pediatr (Rio J)*. 2024;101(suppl 1):S48-S55. doi:10.1016/j.jped.2024.10.006 (PMID 39581563). Revisão de revisões sistemáticas, sem dado brasileiro específico no abstract. O ano de volume impresso deve ser conferido.
- Meherali 2024 (BMJ Paediatr Open, PMID 39401971; PLOS Glob Public Health, PMID 39159145), Arunda 2024 (PMID 40018556), Hartinger 2024 (PMID 38800647) e as revisões de LMIC (PMID 40953917, 39500870): globais ou regionais, sem dado brasileiro de PTB no abstract.

---

## 3. Verificações específicas

### 3.1 Libonati R, et al. 2022

- PubMed: PMID **36052446**; DOI **10.1111/nyas.14887**; *Ann N Y Acad Sci*. 2022;1517(1):44-62. Tipo: Review. Ano, volume, páginas e DOI conferem com o pedido.
- Título: "Drought-heatwave nexus in Brazil and related impacts on health and fires: A comprehensive review."
- Autores (13): Libonati R, Geirinhas JL, Silva PS, Monteiro Dos Santos D, Rodrigues JA, Russo A, Peres LF, Narcizo L, Gomes MER, Rodrigues AP, DaCamara CC, Pereira JMC, Trigo RM.
- **O abstract fala de partos prematuros:** afirma que ondas de calor aumentaram a mortalidade e os partos prematuros durante secas recordes no Sudeste do Brasil. O verbo está na primeira pessoa ("we show"), o que sugere análise feita pelos próprios autores na revisão, e não citação de estudo primário.
- Texto completo: **não acessível em 20/10/2026** (Wiley com HTTP 403; Europe PMC indica que exige assinatura e que não há PMC).
- Busca do estudo primário:
  - a lista de referências depositada no Europe PMC (202 entradas) não tem, pelo título, nenhum estudo brasileiro de calor e parto prematuro. As únicas referências brasileiras sobre nascimento são Requia 2021 (fumaça de queimadas e PTB, PMID 34891058) e Requia 2021 (queimadas e anomalias, PMID 34504295). Várias entradas aparecem sem título ("AUTHOR UNKNOWN"), então a verificação não é exaustiva;
  - P10 (autores do grupo) e P4 (plurais) não acharam estudo primário no PubMed.
- Conclusão: o achado sobre PTB **não tem estudo primário rastreável** nas fontes acessíveis. Tudo indica que é análise interna da revisão, sem números no abstract. Se citado, deve ser como "a review reported…", não como estudo primário.

### 3.2 Ribeiro-Silva RC, et al. 2025 (protocolo do CIDACS)

- PubMed: PMID **41019574**; PMC **PMC12461186**; DOI **10.12688/wellcomeopenres.23909.2**; *Wellcome Open Res*. 2025;10:169.
- Título: "Impact of Heat on Birth Outcomes and Child Nutrition: Study Protocol using the CIDACS Birth Cohort."
- Autores (18): Ribeiro-Silva RC, Pepper M, Ribas de Farias Costa P, Rodrigues Cortes T, Sacramento L, Ribeiro LH, Passos Luz L, Ranzani OT, Smeeth L, Brickley EB, Dos Santos Rocha A, Pescarini JM, Falcão I, Rebouças P, Delgado D, Silveira I, Paixão ES, Barreto M.
- Versão: **versão 2**, publicada em 28/08/2025 (Crossref: has-version 10.12688/wellcomeopenres.23909.1). Status de revisão no texto do PMC: "1 approved, 2 approved with reservations". Licença CC BY 4.0. Segundo a seção de alterações, a v2 ampliou a justificativa do GIG, a cobertura do SISVAN, a estratégia de linkage, o detalhe analítico e as limitações.
- O que propõe (texto completo no PMC): fonte na Coorte de Nascimentos do CIDACS (CadÚnico, SINASC e SISVAN; 28.631.394 nascidos vivos de 2001 a 2018). Temperatura do ERA5-Land e do BR-DWGD. Onda de calor pela definição do Lancet Countdown: 2 ou mais dias seguidos com mínima e máxima acima do P95 municipal; sensibilidade com P90/P99 e 3 a 4 dias. Desenho principal: case-crossover estratificado no tempo com Poisson condicional (quasi-likelihood), mais análise de tempo até o evento com idade gestacional como escala de tempo e DLNM. Esquema em dois estágios (município, depois agrupamento regional). Lags de 0–2 dias e de 0–4 semanas.
- Detalhes adicionais: o protocolo não define PTB de forma explícita, só lista categorias de idade gestacional. **Não há resultados.** Serve para citar como trabalho em andamento, não como evidência.

### 3.3 Couto LO, et al. 2026 (preprint do Research Square)

- DOI **10.21203/rs.3.rs-10756305/v1**; postado em **01/09/2026**; v1; CC BY 4.0. Autores (6): Lucas de Oliveira do Couto (Fiocruz), Ludmilla Viana Jacobson (UFF), Sofia Caumo (Fiocruz), Flavio Manoel Rodrigues da Silva Júnior (UFAL), Michele Rocha El Kadri (ILMD/Fiocruz-AM), Sandra Hacon (Fiocruz). A forma AMA do sobrenome ("Couto LO" ou "do Couto LO") fica para decisão; usei "Couto LO", como no pedido.
- **Texto completo aberto de fato:** PDF de 14 páginas baixado via API do Research Square, com texto extraído localmente.
- **Denominador/offset:** registros individuais do SINASC agregados por data de nascimento e UF, gerando contagens diárias do total de nascimentos elegíveis e dos pré-termo. O modelo usa o log do total diário de nascimentos como offset. Citação literal dos Métodos, na legenda da equação: "is the offset term (logarithm of total daily births)."
- **O que diz o abstract:** que os modelos usaram os nascidos vivos diários como offset do modelo.
- Elegibilidade (Métodos): nascidos vivos únicos, sem anomalia congênita, com informação completa e plausível, município de ocorrência igual ao de residência; **excluídos os <28 semanas**. Logo, o denominador é o total diário de nascidos vivos elegíveis (a termo mais pré-termo de 28 a 36 semanas) por UF. **Não são gestações em risco.**
- Outros detalhes do modelo: unidade de análise UF-dia; um modelo por região (UFs analisadas em conjunto, com efeito fixo de UF); binomial negativa (GAM, `mgcv`); cross-basis com ns de 3 gl na exposição e ns de 2 gl no lag 0–7, agrupada por UF; s(tempo, k=30), dia da semana, s(umidade, k=5); centrado na temperatura média regional; temperatura média diária do ERA5-Land (Saldanha et al. 2024) agregada da média municipal para a UF.
- **Conclusão:** a caracterização "denominador de nascidos vivos diários" **está no texto completo** (Métodos e equação) e também no abstract. Precisão para o manuscrito: é o total diário de nascidos vivos *elegíveis* por UF, com exclusão de <28 semanas, múltiplos e anomalias, e com restrição a residentes.

---

## 4. Conclusão

1. **PubMed (20/10/2026): nenhum estudo primário revisado por pares, só do Brasil, sobre temperatura ambiente de curto prazo e parto prematuro apareceu nas buscas P1 a P10.** A evidência brasileira específica de PTB se resume a:
   - Rocha2026: seca e PTB, nacional, revisado por pares;
   - Libonati2022: revisão com afirmação sobre ondas de calor e PTB no Sudeste, sem números nem estudo primário rastreável;
   - Couto2026: série temporal nacional, só como preprint;
   - Iniguez2026: multicêntrico, com inclusão do Brasil por confirmar na fonte primária;
   - RibeiroSilva2025: protocolo, sem resultados.
2. Para sustentar "Brazilian evidence includes …", sem sugerir lista completa, os candidatos defensáveis são:
   - **Rocha2026** (seca e PTB);
   - **Libonati2022** (como revisão);
   - **Iniguez2026**, só depois de confirmar no texto completo que o Brasil (capitais) está entre os 13 países;
   - **Couto2026**, explicitamente marcado como preprint.
   - Opcionalmente, uma oração separada para desfechos relacionados (peso ao nascer: Requia2022, Bakhtsiyarava2022, Feldens2025; Apgar: DelCarretto2025) e para o protocolo em andamento (RibeiroSilva2025).
   - Rascunho possível, a ajustar com o chat: "Brazilian evidence includes a nationwide cohort linking drought to preterm birth [Rocha2026], a review reporting heatwave-related increases in preterm births during droughts in southeastern Brazil [Libonati2022], and a recent nationwide time-series preprint [Couto2026]; Brazilian capitals were also included in a 13-country analysis [Iniguez2026, a confirmar]."
3. **Couto:** a caracterização "denominador de nascidos vivos diários" está **confirmada no texto completo**: offset igual ao log do total diário de nascimentos elegíveis por UF, e não gestações em risco.
4. Lacunas desta busca: SciELO, LILACS/BVS e medRxiv não acessíveis ou não pesquisáveis em 20/10/2026; texto completo de Libonati 2022 e de Iñiguez 2026 inacessível (403); a triagem do Research Square se limitou aos 20 primeiros por consulta.

Fonte dos metadados e abstracts: PubMed (NLM), via MCP. DOIs listados acima.
