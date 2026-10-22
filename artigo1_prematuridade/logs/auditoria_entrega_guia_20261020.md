# Entrega principal do A1: auditoria completa contra o guia do AJOG MFM (20/10/2026)

- **Objeto:** `Entrega/A1_metodos_resultados_v2_20261020.docx` e `Entrega/figuras/Figure_1–4.pdf` (script 94 v2; A1-149 e A1-150).
- **Auditores:** dois subagentes em contexto limpo, sem rede, sem abrir `.rds`, `.parquet`, `.dbc` nem a base: (A) conformidade com o guia (PDF de 20/10, 36 p., lido inteiro); (B) conteúdo, números e estilo. Mais a autoauditoria da sessão (corpo de letra medido nos PDFs; formatação do `.docx`).
- **Resultado A:** a entrega segue o guia em formato do arquivo, tabelas de três linhas, figuras vetoriais com fonte embutida, referências com DOI e data de acesso, ética e ordem de citação. Achados: 1 "Crítico" (nome do REDU e da Unicamp no texto: reclassificado como Nota, porque a entrega é texto de trabalho sem cegamento por decisão de Guilherme, A1-150; volta a ser cego no arquivo anônimo da submissão), 2 Maiores (Fig. 4 com rótulos de 5,7 pt e 267 mm de altura; Fig. 3 com 26 gráficos num arquivo, defendida pela exceção de imagens para comparação), Menores e Notas abaixo.
- **Resultado B:** nenhum Crítico nem Maior; Tabelas 1–3 iguais aos CSVs (352 células); cerca de 280 números rastreados; 25 referências conferidas; frases prescritas literais; 6 Menores e 11 Notas.
- **Reprodução pela sessão** (2026-10-20 20:04:59 -0300): corpos de letra (Fig. 1: 9,0–10,2 pt; Fig. 2: 9,6–10,2; Fig. 3: 6,3–6,7; Fig. 4: 5,7–7,4), legendas sem as siglas (UF na Fig. 3; wk, p10–p90, t+1 a t+7 e símbolos na Fig. 4), refs. de dados sem ano (SINASC, SIM, BR-DWGD, Atlas), CAMS e DATASUS sem expansão, Results §3 e §5 repetindo a Tabela 2, remissão da faixa dos contrastes secundários à S3 (a faixa é da Tabela 2), "the other 29" (são as 29 não-chave com TMR interior, inclusive estação quente e subtipos: conferido na S2), nota da Tabela 3 com "lags 0–7" para a análise de lag 0–14, γ = 1 nos subtipos extremo e muito prematuro sem menção no Methods (regra única da D12, EP ≥ 1), "[eCI]" nos rótulos da Tabela 2 contra parênteses nos valores, sem número de página, títulos em azul, PNG com fundo transparente. "re-estimated" e "non-negative" estão em frases prescritas (D10 e D5) e ficam.

## Tratamento (script 86 v3 e script 94 v3; A1-151)

| # | Origem | Achado | Tratamento |
|---|---|---|---|
| 1 | A, sessão | Fig. 4: rótulos de 5,7 pt; 178 × 267 mm; nota interna que repete a legenda | 86 v3: 190 × 229 mm, corpo mínimo ≥ 7 pt (medido no PDF por código), sem a nota interna |
| 2 | A, sessão | Fig. 3: 6,3 pt; 26 gráficos num arquivo | 86 v3: 190 × 229 mm, corpo ≥ 7 pt; segue num arquivo pela exceção de comparação (p. 28) |
| 3 | A | Larguras fora das do guia (90 e 190 mm) | 86 v3: as quatro com 190 mm (página inteira) |
| 4 | A | PNG com fundo transparente | 86 v3: fundo branco |
| 5 | A, B | Legendas sem siglas e símbolos (Figs. 3 e 4) | 94 v3: siglas de UF na Fig. 3; wk, p10–p90, t+1 a t+7, arm A/B, série com zeros como ausentes, quadrados cheios e linha contínua em 1 na Fig. 4 |
| 6 | B | Remissão errada da faixa dos contrastes secundários | 94 v3: "(Table 2; concentration-specific contrasts in Supplementary Table S3)" |
| 7 | B | "the other 29" ambíguo | 94 v3: "the 29 nonkey sensitivity analyses with an interior pooled MRT (including those above)" |
| 8 | B | γ = 1 nos subtipos extremo e muito prematuro ausente do Methods | 94 v3: frase no Methods (regra prespecificada, EP aproximado ≥ 1) e o corte de 1.000 eventos por subtipo |
| 9 | B | Nota da Tabela 3: "lags 0–7" para a análise de lag 0–14 | 94 v3: "(0–14 in the lag 0–14 analysis)" |
| 10 | A, B | CAMS e DATASUS sem expansão; CAMS sem ligação ao PM2.5 | 94 v3: expansão no primeiro uso; CAMS como fonte do PM2.5 na análise-chave |
| 11 | A | Results repete a Tabela 2 (heterogeneidade e Wald; componentes da fração atribuível) | 94 v3: esses valores ficam só na Tabela 2; o texto mantém o total atribuível |
| 12 | B | "[eCI]" nos rótulos da Tabela 2 | 94 v3: "(eCI)" |
| 13 | B | "co-primary"; "common percentile scale" × "pooled axis" | 94 v3: "coprimary"; "pooled temperature axis" |
| 14 | B | "full log available with the analysis code" (repositório privado) | 94 v3: "full log kept with the analysis code" |
| 15 | B | Nota da Tabela 1 não explica Serra como núcleo de Vitória | 94 v3: frase na nota |
| 16 | A | Versões do dlnm e do mixmeta só no suplemento | 94 v3: versões no Methods (as da frase prescrita do suplemento) |
| 17 | B | Ref. do gnm: DOI antes do acesso e da URL | 94 v3: acesso antes do DOI, sem a URL |
| 18 | A, B | Refs. de dados sem ano | 94 v3: anos dos dados no SINASC e no SIM (2011–2024); BR-DWGD e Atlas ficam sem ano (não há ano registrado) |
| 19 | B | P sem itálico | 94 v3: P em itálico (AMA) |
| 20 | A | Sem número de página; títulos em azul; nota interna "Word count" | 94 v3: número de página no rodapé; títulos em preto; a nota sai (a contagem fica no log) |

## Sem mudança (para o coautor ou para a submissão)

- REDU e Unicamp no texto (decisão A1-150): voltar ao texto cego no arquivo anônimo da submissão.
- Resultados descritivos no Methods (10 concentrações no p99, posto efetivo, contribuições negativas): o coautor decide.
- Valores lag-específicos com 4 casas (dois limites a menos de 0,0005 de 1): mantidos, para mostrar que excluem 1.
- Contrastes secundários da estação quente só em `01_saidas/`: levar à S2 se o coautor quiser.
- Tabela S6 sem citação no texto principal (a ordem das tabelas suplementares é decisão do suplemento, que é secundário).
- Coluna "Same direction" da Tabela 3 (critério prescrito da D10); fascículo da ref. 18; "re-estimated" e "non-negative" (frases prescritas).
- Methods + Results acima de 1.705 palavras: o limite da revista é de 3.000 para o texto principal inteiro; 1.705 era meta do chat.
- O CSV de referências difere do texto em 7 itens corrigidos no script (DOIs iguais); `artigo1_prematuridade/CLAUDE.md` ainda fala em "DOI na submissão" (superado pela A1-143): para Guilherme.
