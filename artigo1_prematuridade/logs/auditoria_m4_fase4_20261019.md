# Artigo 1, Fase 4: auditoria em contexto limpo do marco M4 (manuscrito completo e v3 de Methods/Results)

- **Auditor:** subagente em contexto limpo (Claude), 2026-10-20 08:22–08:40 −03:00 (rótulo da rodada: 20261019). As referências foram conferidas por um segundo subagente, sob as mesmas regras de sigilo; os achados dele que entram aqui foram reproduzidos por mim no PubMed (Chersich2020, Iniguez2026, vonElm2007) ou cruzados com a spec.
- **Estado auditado:** `HEAD` = `dbcc2f5` (ramo `main`); `git status --porcelain -- artigo1_prematuridade` vazio. SHA-256 iguais aos dos logs do 90 e do 91: `manuscrito_20261019.md` `ff2cc68f…`, `suplemento_20261019.md` `30e55bba…`, `referencias_m4.csv` `2afc32f6…`, script 90 `76fd001f…`, script 91 `1742e0ba…`. Os `.docx` de `Submissao/` são idênticos aos de `manuscrito/m4/`, e as figuras de `Submissao/figuras/` são idênticas às `figuras/fig0*_v2_20261019.pdf`.
- **Sigilo:** nada foi aberto em `dados_artigos_perinatais_clima/`, nem `.parquet`, `.dbc` ou `serie_*.rds`. Só foram lidos CSV e RDS agregados de `01_saidas/fase3/` e `fase4/`, além de logs, spec, tabelas v4, `.docx` e PDF. O total de nascidos vivos (13.509.914) foi conferido no log `populacao_dum_fase0_rerun_20261009.md` (linha "26 somadas"), porque a outra fonte possível é a série diária. Nada foi gravado fora deste arquivo e do scratchpad; o git só foi usado para leitura.
- **Princípio:** os números foram conferidos contra as saídas e os logs de origem, nunca contra o log do 90.

## 1. O que foi conferido e como (código próprio, no scratchpad `auditoria_m4/`)

| Script (SHA-256, 16 primeiros) | O que faz | Resultado |
|---|---|---|
| `a1_numeros.R` (`53724c94712903df`) | Lê `contagens_insumos_fase4.csv`, `tmr_fase3`, `contrastes_fase3`, `meta_curva_fase3`, `lagresposta_fase3`, `fracao_atribuivel_fase3`, `contribuicoes_negativas_fase3`, `posthoc_item2_fase3`, `posthoc_af_fase3.rds`, `segunda_etapa_principal_fase3.rds`, `criterio_c1_fase4`, `tabela_sensibilidades_fase4_v2`, `tmr_p10p90_fase4`, `contrastes_estacao_quente_fase4`, `pacf_d3_fase4` e `ic_tmr_uma_etapa_16coef_fase4.rds`. Arredonda como o texto e compara | 54 conferências, 0 divergências |
| (mesma sessão R) | Wald dos metapreditores e P1 refeitos a partir de `coef_meta`/`vcov_meta` e da `pred_media` do RDS do 45 | W = 1,857, p = 0,762; média p = 0,1947; amplitude p = 0,3066; Q = 92,9 (92 gl), p = 0,454, I² = 0,99% |
| (R, à parte) | Tabela S3 (208 células) contra as linhas `blup` do `contrastes_fase3`; S4 contra `posthoc_af$resumo` | 208/208 e 7/7 (as 11 "divergências" da primeira passada eram só o `read.csv` convertendo "26.0" em 26) |
| `a1_frases.py` (`33824b39f79c5d04`) | Extrai os blocos citados da spec por número de linha, aplica só as substituições declaradas (log do 90 e A1-128) e procura a frase literal no texto ou no suplemento | 9 de 9 literais e inteiras |
| `a1_regras.py` (`d86c3506d73b5cef`) | Conta palavras (sem títulos de seção e sem chaves de citação), confere título, condensation, short title, Glance, keywords, abstract, subtítulos, glossário, highlights e termos proibidos, e procura marcas de cegamento; compara o `.md` com o `.docx` frase a frase | Contagens iguais às do log do 90; nenhuma frase do `.md` falta no `.docx` |
| `a1_docx.py` (`c14f4afd407995fa`) | Lê o XML dos 4 `.docx` (jc, lnNumType, autoHyphenation, tblBorders, tcBorders, shd, estilo de tabela, metadados, partes) e as fontes e metadados dos 4 PDF (pypdf) | Ver a seção 4 |
| `a1_cit.py` (`712b3ac3962c0caa`) | Ordem dos números sobrescritos no `.docx` e posição do sobrescrito em relação à pontuação | 1–33 no texto e 1–10 no suplemento, em ordem; 5 sobrescritos fora do padrão AMA |
| Também | Tabelas do `.docx` contra os CSV v4, célula a célula; texto das figuras (pypdf); ordem do corpo do `.docx` | 7 tabelas, 0 células diferentes |
| `refs_relatorio.md` (`85bf467d2087be75`, subagente) | 33 PMIDs no PubMed (metadados e abstract), DOIs no Crossref e no doi.org (User-Agent "refcheck/1.0", sem dado pessoal), status HTTP das URLs de dados | 40 chaves, nenhuma referência errada ou inventada |

## 2. Tarefa 1: números (Abstract, Results, Comment, Glance, condensation, Supplementary Methods)

**Todos conferem.** Fonte de cada número, sem divergência de valor nem de arredondamento:

- **População:** 13.509.914 NV e 1.378.030 PTB (log A7; soma do `ptb` de `contagens_insumos` = denominador do 46); 10,20%; "13.5 million"; 4.498 dias (2012-04-14 a 2024-08-06, inclusive); coorte de 2011-07-31 a 2024-03-05 (`autoauditoria_itens_novos_fase0_rerun`); 277 municípios (soma da Tabela 1).
- **TMR e contrastes combinados:** TMR 28,2 °C (p93,8), IC 18,8–29,5 = faixa de busca inteira (`ic_li == x_inf` e `ic_ls == x_sup`); sorteios nas pontas 30,9% e 3,5%; x99 1,003 (0,978–1,029) a 29,5 °C; x1 1,020 (0,990–1,051) a 18,8 °C; secundários de 1,000 a 1,013; nenhum dos seis IC do primário exclui 1.
- **Heterogeneidade:** Q 92,9 (92 gl), P = .45, I² = 1,0%; Wald da média P = .19 (0,1947) e da amplitude P = .31.
- **BLUP:** TMR de 23,1 a 32,3 °C; 10 de 26 no p99, 0 no p1; busca p10–p90 na borda em 7 e IC igual à faixa inteira em 8 (Porto Alegre e Baixada Santista não, por 0,1 °C de grade). O conjunto com TMR ≥ p97,5 é o mesmo das 10 do p99, então "heat and extreme heat coincide" está certo.
- **Lag a lag (4 casas):** 5 de 16 excluem 1 (p1: lags 0, 6 e 7; p99: lags 3 e 7), todos iguais ao texto; os outros 11 incluem 1.
- **AF:** 25.362 (12.026–37.232); 1,84% (0,87–2,70); calor 0,23%; frio 1,61%; backward e componentes da Tabela 2; ponte 2,87% (1,48–3,98); backward 2,89%.
- **Post hoc:** P1 χ² = 1,86, 4 gl, P = .76. P2: mediana 1,67%, p2,5–p97,5 de 0,83% a 3,00%, 0 falhas em 1.000; calor 0,73%, frio 0,79%; RR 1,008 e 1,008; TMR no p99 com mediana 6 (0–18) e no p1 com mediana 6 (0–19).
- **Sensibilidades-chave:** x99 dentro do IC do primário em 6 de 6 e x1 em 5 de 6; a exceção é o lag 0–14 (1,057; 1,019–1,098); nenhuma chave na borda.
- **Demais sensibilidades:** estação quente x99 1,011 (0,976–1,047), e nenhum dos 6 contrastes exclui 1; subtipos sem RR contra a TMR que exclua 1; muito prematuro contra a mediana 1,089 (1,007–1,177); "other 29 sensitivity analyses with an interior pooled MRT" = 37 com curva − 7 na borda − P0. Só o C3-CB2 e o C3-E3 excluem 1 no x1, e nenhum no x99. Nenhuma outra linha da v2 exclui 1, inclusive os lados sem borda e o penalizado. A frase está completa.
- **Supplementary Methods:** dispersão de 0,98 a 1,12 e γ de 0,50 a 1,65 (log da 1ª etapa); 18 concentrações no extremo e as 8 excluídas, com os mesmos nomes e a mesma ordem (`extremo < 1000`); offset do `z_fetal` de cerca de 0,005 (auditoria do M2: 0,0054); autovalores de Ψ 2,7 × 10⁻², 5,5 × 10⁻⁴, 7,7 × 10⁻¹¹ e 8,3 × 10⁻¹⁷; contribuições negativas de −0,034 dentro e −38,7 fora, todas nas 10 concentrações com TMR no p99; menor Δ de −4,151 × 10⁻⁵; PACF fora em 25 de 26 (literal) e 13 de 26 (nula); D3 1,002 (0,980–1,026) e 1,021 (0,990–1,053); uma etapa 27,3 (22,9–29,5), com sorteios de 2,6%/0,8% (uma etapa) e 30,9%/3,5% (primário); exploratórios com P de .29 a .89; versões do `renv.lock` (dlnm 2.4.10, gnm 1.1-5, mixmeta 1.2.0, mgcv 1.9-3, tsModel 0.6-2, MASS 7.3-65, renv 1.2.4); BR-DWGD v3.2.4 a 0,1° e PM2.5 em UTC−3 (spec, l. 69 e 148).

**Afirmações que vão além dos números:** o Abstract repete "none of the pooled cumulative relative risks excluded 1" sem "of the primary analysis" (**Maior 1**); "compatible with at most small associations" (Menor 1); "did not exceed its distribution under no association" (Menor 2). "Close to flat" fica como Nota 2: tem apoio no P1 (P = .76) e nos RR de 1,000 a 1,020.

## 3. Tarefa 2: frases prescritas

| Frase | Onde | Literal e inteira? |
|---|---|---|
| Ética (08/10, §2, l. 54) | Methods | Sim |
| D1 (13/10, l. 66) | Methods | Sim, com "occurring on the same day and the following 7 days" no lugar de "occurring over the following 0–7 days" (Menor do chat; log do 90) |
| Viés da AF (errata da D5, item 4, + resto da D5, item 2, l. 64) | Methods, depois da D1 | Sim |
| D10, 1g | Methods | Sim |
| Errata da D5, item 5 | Comment, Strengths and Limitations | Sim, com a correção 4 ("…cumulative relative risks of the primary analysis…") e "[k] of 1,000 replicates failed and are reported in the Supplementary Methods" → "no replicate failed" (instrução do item 5) |
| Sementes (complemento, C1, l. 59) | Supplementary Methods | Sim |
| Post hoc da D5 (l. 123) | Supplementary Methods | Sim |
| Errata da D8, adaptada | Supplementary Methods | Igual à adaptação do 88 v2, aceita pelo chat no M3. Saem as duas orações que não se aplicam com a TMR combinada interior |
| §8 com o complemento | Supplementary Methods | Igual ao 88 v2 (com mgcv, attrdl, tsModel e MASS intercalados), sem a frase da base e do repositório, que foi trocada pela disponibilidade do chat. Os dois trechos da §8 com o complemento estão literais |

Nenhuma faltou. Ficam no texto principal a ética, a D10 1g e a frase do viés da AF, como manda a correção 5.

## 4. Tarefas 3 e 4: correções v3 do chat e regras da revista

### 4.1 Correções v3 (seção 2 da mensagem do chat)

| Item | Atendido? | Onde e observação |
|---|---|---|
| Maior 1, ética | Sim | Methods, literal |
| Maior 2, disponibilidade | Sim | Methods; "from [ref]" virou "from its public repository" com a citação de Xavier 2022 (A1-128, item 3). Nota 4 |
| Maior 3, Ψ singular | Sim | Frase em Methods; detalhe na Comment e no suplemento |
| Maior 4, contradição | **Parcial** | No Results, sim: frase corrigida, aviso de lag descritivo (16 estimativas) e 4 casas nos 5 lags que excluem 1. **No Abstract, não: Maior 1** |
| Maior 5, orçamento | Sim | Methods 1.163 + Results 513 = 1.676 (≤ 1.700); texto principal 2.954 (≤ 3.000); contagem por seção no log do 90 |
| Maior 6, tabelas do `.docx` | Sim | Sem estilo de tabela; `tblBorders` com top e bottom simples; linha sob o cabeçalho por `tcBorders`; nenhum `left`/`right`/`insideV`/`start`/`end` ativo, nem na tabela nem nas células; nenhum `shd` com cor (7 tabelas) |
| Maior 7, IC da uma etapa | Sim | 16 coeficientes; justificativa corrigida no log do 90; frações na borda (2,6%/0,8% e 30,9%/3,5%) no log e no suplemento; sensibilidade ao Monte Carlo declarada |
| Menores de Methods | Sim, salvo nota | D17 no suplemento e na Comment (Menor 6 sobre a redação); E9 no suplemento; "1,000 Monte Carlo samples"; calor extremo = max(p97,5; TMR) e as 10 coincidentes; CAMS EAC4, SIM e PTB espontâneo no suplemento; "same day and the following 7 days"; MRT e MCC definidos na 1ª menção; nenhum "mothers" (2 × "pregnant individuals") |
| Menores de Results | Sim | x99 da estação quente; frase dos subtipos; errata da D5 literal na Comment, com frase neutra de P1 e P2 no Results |
| Menores do Supplementary | Sim | 8 concentrações e as duas declarações da D12, 4.1; P2 (texto e S4); ponte da D1; PACF da D3; S3 (208 células conferidas) |
| Menor de logs | Sim | RR contra a mediana do lado sem borda no log do 90 (14 valores, inclusive 1,089; 1,007–1,177) |
| Menores de tabelas | Sim, salvo nota | Tab2 com MRT e BLUP e Tab3 com RR, CI, PM2.5, γ e (i), mas a Tab3 não define "ns" nem "df" (Menor 8); IC com travessão também na AF e no AN |

### 4.2 Regras da revista (seção 4)

| Regra | Situação |
|---|---|
| Ordem do manuscrito cego | Conforme: Title → Condensation → Short Title → Glance → Blinded COI → Keywords → Word count → Abstract → texto → Glossary → AI → References → Tables (cada tabela sob o seu título) → Figure legends |
| Título | 12 palavras, sem abreviação, sem conclusão |
| Condensation | 20 palavras e 133 caracteres |
| Short title | 71 caracteres, sem abreviação |
| AJOG at a Glance | 126 palavras com os títulos A/B/C (103 sem eles). Menor 3 (falta a referência do RR) |
| Keywords | 7, em ordem alfabética, sem palavra do título, sem "and"/"of" |
| Word count | "Abstract: 389 words; Main text: 2,954 words": reproduzido |
| Abstract | 389 palavras (383 sem os rótulos), estruturado nos 5 rótulos, nenhuma abreviação ("95% confidence interval" por extenso), percentuais com n/N (10,2% e 1,84%), P na alegação do P1. Maior 1, Menores 1 e 2 |
| Introduction | 346 palavras (cerca de 400: Nota 1), sem resultados próprios |
| Comment | 932 palavras; os seis subtítulos na ordem; "if causal" na carga atribuível; achado nulo com destaque |
| Methods + Results | 1.676 (≤ 1.700) |
| Texto principal | 2.954 (≤ 3.000) |
| Glossário | Os 5 termos pedidos. Menor 13 |
| Declaração de IA | Modelo da Elsevier, mas diz "draft and edit the text", e o chat pediu edição de linguagem. Menor 12, para Guilherme decidir |
| Estilo AMA | Números em ordem de 1ª citação (1–33; suplemento 1–10); 5 sobrescritos depois de dois-pontos ou ponto e vírgula (Menor 4); "Accessed [date to be confirmed]" em 6 referências (Nota 5) |
| "pregnant individuals" | Sim; nenhum "mothers", "women" ou "maternal" |
| Duplo-cego | Sem nomes, UNICAMP, CliMaterna, GitHub, guilcoel nem caminhos no manuscrito, no suplemento, nas legendas, nos highlights, no XML dos `.docx` e no texto das figuras. O e-mail fica só na página de título. Restam o hash do commit e os marcadores do DOI e do repositório (Menor 10). Metadados dos `.docx`: author "python-docx" (Nota 7) |
| Highlights | 4, com 76, 58, 61 e 69 caracteres |
| `.docx`: texto não justificado | Nenhum `jc` both/distribute no documento nem nos estilos |
| `.docx`: numeração de linhas | `<w:lnNumType w:countBy="1" w:restart="continuous"/>` no manuscrito, sem `suppressLineNumbers`; coluna única; espaço duplo no Normal; hifenização desligada |
| Tabelas de três linhas | Conforme (XML; ver Maior 6) |
| Figuras PDF | 4 PDF de 1 página, ArialMT (e Arial-BoldMT na Fig. 4) **embutida** como subconjunto em todas (pypdf). Dispositivo quartz (Nota 8). Abreviações das figuras sem definição nas legendas (Menor 7) |
| Pasta `Submissao/` | Só manuscrito cego, página de título, material suplementar, highlights e as 4 figuras. Há também `.gitkeep` e arquivos AppleDouble `._*` (Nota 6) |
| "first"/"novel"/"unprecedented" | Ausentes como afirmação de novidade (só "first stage" e "first 7 days") |

## 5. Tarefa 5: referências

- **33 PMIDs do texto principal e do suplemento conferidos no PubMed;** 7 sem PMID conferidos por DOI ou URL. Nenhuma referência errada, inventada ou com PMID/DOI de outro artigo. As 40 chaves citadas estão verificadas no CSV; **nenhuma vira [ref]**. Linhas do CSV não citadas: Armstrong2006, Lu2007, Tobias2024 e VicedoCabrera2014.
- **Afirmações sustentadas pelo abstract:** Ohuma2023 (13,4 milhões, 9,9%, sem mudança mensurável), Leal2016 (11,5%), Samuels2022, Bekkar2020, Wang2026, Darrow2009, Strand2011 (inclusive o viés de coorte fixa), Huang2023 (inclusive "removed bias in simulations"), Girgin2026, Darrow2024 (RR 1,02) e Fitch2025 (OR 1,015 e 1,019, que juntos sustentam "about 1% to 2%"), Silveira2025, Chersich2020 nos números (1,05 por °C; 1,16 em ondas de calor; natimorto 1,05) e Iniguez2026 em 1,4%, 250 locais, 13 países e só estação quente.
- **Fitch2025:** a citação (EHP 2026;134(2):184-194, doi:10.1021/ehp.6c00358) é a versão final. O DOI com prefixo 10.1021 resolve no doi.org para a ACS, e o DOI antigo 10.1289/EHP15953 redireciona para ele. O PMID 40392097 é o manuscrito aceito, que o PubMed ainda registra como 2025, com o DOI antigo. Os achados estão na tabela da seção 7 (Menores 14 a 18; Notas 13 e 14).
- **Não conferido nesta auditoria:** o texto completo do Iniguez2026 (ScienceDirect 403; fora do PMC e do Europe PMC), o abstract da versão final do Fitch2025, o apêndice e o código do Gasparrini2015 (escala percentil comum) e o PDF do IBGE2016 (26 concentrações e 277 municípios).

## 6. Tarefa 6: sigilo

- **Nada diário:** nem no texto, nem nas tabelas, nem nas figuras (curvas e forest; texto das figuras conferido).
- **Nenhuma contagem de pessoas de 1 a 9:** as contagens da Tabela 1 vão de 13.393 a 335.025; os números de 1 a 9 no texto são de concentrações, dias ou lags. Os −0,034 e −38,7 "events" e os AN são estimativas, não contagens (D4(d)).
- **Nenhum caminho de microdado** no texto, no suplemento, no XML dos `.docx` ou nos PDF.
- **Fora do texto (Nota 9):** as notas do `referencias_m4.csv` registram que uma consulta ao Crossref em 19/10 levou o e-mail do usuário no User-Agent. O incidente não está no registro de desvios, e o CSV está fora do git.

## 7. Achados

| # | Grav. | Local | Evidência | Correção sugerida |
|---|---|---|---|---|
| Maior 1 | Maior | Abstract, Results | "none of the pooled cumulative relative risks excluded 1" sem "of the primary analysis", a mesma contradição da correção 4 do chat, que não chegou ao Abstract. A chave lag 0–14 (1,057; 1,019–1,098), o lag 0–21 (1,076; 1,025–1,130) e a Tmin (1,036; 1,002–1,071) são RR cumulativos combinados que excluem 1, e a frase seguinte do Abstract fala das sensibilidades | "none of the pooled cumulative relative risks of the primary analysis excluded 1" |
| Menor 1 | Menor | Abstract, Conclusion; Glance C | "the data were compatible with at most small associations": "small" não é definido; o IC do primário admite até +2,9% (calor) e +5,1% (frio); nas sensibilidades de lag mais longo, o frio chega a 1,057 (até 1,098) e 1,076 (até 1,130); e a própria Comment fala em associação tardia com o frio | Quantificar ("the 95% confidence intervals excluded increases larger than 3% for heat and 5% for cold over lags of 0 to 7 days") ou retirar |
| Menor 2 | Menor | Abstract, Results | "this fraction did not exceed its distribution under no association": 1,84% passa a mediana nula (1,67%); o que não passa é o p97,5 (3,00%). A AF sai sem o eCI | "did not exceed the 97.5th percentile of its distribution under no association (median, 1.67%; 97.5th percentile, 3.00%)" e o eCI (0.87%–2.70%) |
| Menor 3 | Menor | Glance B | RR "at the 99th and … at the 1st temperature percentile" sem a referência | Acrescentar "compared with the minimum-risk temperature" |
| Menor 4 | Menor | Methods (DLNM):⁸; samples;²⁸; Comment 2%:¹⁴,¹⁵; simulations;¹²; suplemento values;⁸ | O AMA põe o sobrescrito fora do ponto e da vírgula, mas dentro dos dois-pontos e do ponto e vírgula | Mover o número para antes do ":" e do ";" (5 lugares) |
| Menor 5 | Menor | Methods, plano de análise | "Deviations were recorded… (Supplementary Material)": o suplemento não tem lista de desvios | Incluir uma tabela de desvios no suplemento ou remeter ao repositório |
| Menor 6 | Menor | Suplemento, feriados locais | "compiled from municipal legislation": a tabela v1.1 tem feriados estaduais e distritais (PR, Lei 4.658/1962; decretos de AL; DF, Lei 963/1995; A1-116, A1-117, D17) | "from municipal, state, and district legislation applicable to the core municipality" |
| Menor 7 | Menor | Legendas das Figuras 1–4 | Nas figuras aparecem MRT (1–4), BLUP (3) e CI, DLNM, GA, LMP, PM2.5, SINASC, df, ns, γ e (i)/(ii) (4), sem definição nas legendas (pypdf) | Definir as abreviações em cada legenda |
| Menor 8 | Menor | Nota da Tabela 3 | A linha 3, "ns(time, 99 df)", não tem "ns" nem "df" definidos na nota | Acrescentar "ns, natural spline; df, degrees of freedom" |
| Menor 9 | Menor | Suplemento, Outcome definitions | "Campo Grande" sem "/MS", e as outras 7 com UF; as tabelas usam "Campo Grande/MS" | "Campo Grande/MS" |
| Menor 10 | Menor | Methods, cegamento | Hash do commit (86069e5), "archived at XXXXXXXXXXXXX" e "[repository]" no manuscrito cego. Preenchidos (DOI do REDU com autores, repositório público), identificam os autores | "[blinded for review]" no cego; valores reais na página de título ou na carta |
| Menor 11 | Menor | Comment, Strengths and Limitations | Das limitações da D1, falta a 1ª: coeficientes da 1ª etapa sem encolhimento, instáveis nas concentrações pequenas, e o backward lido pelo total. O chat pede "D1 (limitações)" | Uma oração na limitação do backward |
| Menor 12 | Menor | Declaração de IA | "to draft and edit the text": o chat pediu "código e edição de linguagem" (A1-128, item 8). A política da Elsevier admite IA para linguagem e legibilidade | Guilherme decide entre a redação fiel ao uso e a do chat |
| Menor 13 | Menor | Glossário | "Cumulative relative risk … summed over all lags": o RR cumulativo é o produto dos RR por lag (soma na escala log) | "…accumulated over all lags (the sum of the lag-specific log relative risks)" |
| Menor 14 | Menor | Introduction (Chersich2020) | "In a meta-analysis of 70 studies, the odds of preterm birth…": 70 é o total da revisão; o PTB vem de 47 estudos (PubMed) | "In a systematic review and meta-analysis that included 70 studies…" ou "47 studies of preterm birth" |
| Menor 15 | Menor | Introduction e Methods (Iniguez2026) | O abstract não sustenta "including Brazil" (não lista os países) nem o uso para o peso de risco de parto (só DLNM e quase-Poisson). A spec (l. 45) registra Brasil com 27 localidades e o offset log(Z_t) + γ·log(W_t) | Confirmar no texto completo; no peso, citar também o VicedoCabrera2014 (a quem o Huang2023 atribui o método), que já está no CSV |
| Menor 16 | Menor | Comment (Couto2026) | O abstract (Crossref) põe as curvas em U nas regiões frias **e moderadas**, mais no lag 7; nas quentes, risco com temperaturas moderadamente fora da média, mais no lag 0. O texto simplifica. Formato AMA de preprint: servidor antes de "Preprint posted online" | Ajustar a frase e a ordem da referência |
| Menor 17 | Menor | Referência 15 (Fitch) | 3º autor "Strickland M"; na versão final, "Strickland MJ" | "Strickland MJ" |
| Menor 18 | Menor | Referência 20 (von Elm) | 6 autores individuais (PubMed); o AMA lista os 6, e o CSV usa 3 + et al | Listar os 6 (+ STROBE Initiative) |
| Nota 1 | Nota | Introduction | 346 palavras contra cerca de 400 | Opcional |
| Nota 2 | Nota | Abstract, Results, Comment | "close to flat" tem apoio no P1 (P = .76) e nos RR de 1,000 a 1,020; o Wald pode ser anticonservador (D8), o que reforça o não rejeitar | Manter |
| Nota 3 | Nota | Methods | "DLNM" definido e não usado de novo; "R version 4.5.1³¹" pode ser lido como versão 4.5.131 | Não abreviar; mover a citação para depois de "R" |
| Nota 4 | Nota | Disponibilidade | Faltam o SIM, o CAMS EAC4 e o Atlas, também usados. O "public repository" do BR-DWGD não tem URL, e o Xavier 2022 cobre 1961–2020 (a v3.2.4 vai além) | Acrescentar e citar a versão e o repositório com data de acesso |
| Nota 5 | Nota | Marcadores | [repository], XXXXXXXXXXXXX, COI cego, página de título, 6 "Accessed [date to be confirmed]" (IBGE, SINASC, R, gnm, SIM, Atlas; CAMS sem data), Wang 2026 online first | Preencher antes da submissão |
| Nota 6 | Nota | `Submissao/` | `.gitkeep` e AppleDouble `._*` (o disco não é APFS) | Excluir ao compactar ou enviar |
| Nota 7 | Nota | Metadados dos `.docx` | author "python-docx", comments "generated by python-docx", miniatura do modelo padrão, margens laterais de 1,25 in. Nenhuma identidade | Limpar comments e conferir as margens no guia |
| Nota 8 | Nota | Figuras | Feitas no dispositivo quartz (o script 86 explica: o cairo exige o XQuartz), e a A1-123 fala em `cairo_pdf`; metadado Title "Quartz %d" | Só registro |
| Nota 9 | Nota | `referencias_m4.csv` | Fora do git (`/artigo*/manuscrito/` no .gitignore), com o SHA no log do 91. As notas registram o e-mail do usuário no User-Agent do Crossref em 19/10 | Registrar o incidente no log de desvios |
| Nota 10 | Nota | Results | MRTs remetidas a "Supplementary Tables S2 and S3", mas a S3 não traz MRT | "Supplementary Table S2" |
| Nota 11 | Nota | Suplemento | MRT, CI e BLUP usados sem definição no documento separado | Definir na 1ª menção |
| Nota 12 | Nota | Suplemento | Errata da D8 e §8 adaptadas, iguais ao 88 v2 aceito pelo chat | Só registro |
| Nota 13 | Nota | Methods (Gasparrini2015) | A "common percentile scale" não está no abstract nem no texto principal do MCC 2015; vem do código do MCC (D2) | Só registro |
| Nota 14 | Nota | Introduction | O Girgin2026 é coorte/Cox, não série temporal (a frase vem colada à de séries temporais); "studies" no plural com só o Silveira2025 | Opcional |
| Nota 15 | Nota | Comment (E10) | Sai a oração "os estratos ano × mês absorvem o efeito do bissexto" da E10 | Opcional |

## 8. Contagens

- **Achados:** 0 Críticos, 1 Maior, 18 Menores, 15 Notas.
- **Números:** cerca de 75 afirmações numéricas do texto, do Abstract, da Comment, do Glance, da condensation e do suplemento, mais 208 células da S3 e as 7 linhas da S4: 0 divergências de valor ou de arredondamento. Mais 7 tabelas do `.docx` contra os CSV v4: 0 células diferentes.
- **Frases prescritas:** 9 de 9 literais e inteiras, só com as substituições declaradas.
- **Correções v3:** 7 Maiores (6 atendidas e 1 parcial, a Maior 4, por causa do Abstract) e todas as Menores atendidas, com as ressalvas dos Menores 6 e 8.
- **Regras da revista:** todas as contagens e formatos conferem; achados nos Menores 3, 4, 7, 10 e 12.
- **Referências:** 40 chaves (33 PMIDs e 7 por DOI ou URL), 0 erradas, 0 sem verificação ([ref]); 5 afirmações com ressalva (Menores 14 a 16) e 2 formatos AMA (Menores 17 e 18).
- **Contagem de palavras (reproduzida):** Abstract 389; Introduction 346; Methods 1.163; Results 513; Methods + Results 1.676; Comment 932; texto principal 2.954; Glance 126; condensation 20 palavras e 133 caracteres; short title 71 caracteres; título 12 palavras.
