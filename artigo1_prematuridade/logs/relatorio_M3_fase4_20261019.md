# Relatório do marco M3 (Fase 4: figuras, tabelas e Methods/Results) — A1, 19/10/2026

- **Antes do M3, fecho do M2** (decisões de Guilherme na A1-122):
  - IC da TMR da uma etapa pelos 16 coeficientes, conforme a letra da D11: 22,9–29,5 °C, com o limite superior no x99;
  - contrastes da estação quente no p95, p90, p10 e p5, sem sinal;
  - tabela das sensibilidades v2, sem pendência (IDHM e feriados locais v1.1). Script 85.
- **O que rodou:** scripts 86 a 89 (decisões de apresentação na A1-123; correções da auditoria na A1-124). Versões válidas: figuras v2, tabelas v3, texto v2 e `.docx` v2. As anteriores ficam, com log.
  - **Figuras** (PDF vetorial com Arial embutida, conferida por pypdf; PNG a 300 dpi): fig01, curva combinada; fig02, lag-resposta; fig03, as 26 curvas BLUP; fig04, forest de 44 análises.
  - **Tabelas** (inglês americano, P no estilo AJOG): tab01, as 26 concentrações; tab02, resultados combinados e fração atribuível; tab03, critério da C1; S1, lista fechada, com RR contra a mediana; S2, BLUPs, com a busca p10–p90 e o RR contra a mediana.
  - **Texto:** Methods, com as frases prescritas literais (D1, D5 e errata, complemento, D10 1g, §8) e a D8 adaptada ao A1; Results, com todos os números gerados por código e as afirmações conferidas por `stopifnot`; Supplementary Methods, com o parágrafo post hoc da D5 e as contribuições negativas. `.docx` sem texto justificado.
- **Números centrais:**
  - 13.509.914 NV e 1.378.030 PTB (10,2%);
  - MRT combinada 28,2 °C (p93,8), IC 18,8–29,5;
  - RR no p99 1,003 (0,978–1,029) e no p1 1,020 (0,990–1,051);
  - Q 92,9 (92), I² 1,0%;
  - AF 1,84% (0,87–2,70) "if causal", ou 25.362 PTB;
  - análise post hoc: Wald 1,86 (4 gl), P = 0,76.
- **Auditoria independente do M3:**
  - 882 células e todos os números do Results batem; sigilo limpo;
  - 0 Críticos, 3 Maiores, 7 Menores e 9 Notas, todos reproduzidos e tratados na A1-124.
  - **Maiores:** o resto do item 2 da D5 no Methods; o RR contra a mediana e a busca p10–p90 no Results e nas S1 e S2; o nome e a declaração da E9.
  - **Menores:** P da S1; contagem de 36 análises; lag-resposta no Methods; DLNM penalizado na cross-basis; população da cesárea e do pré-natal; legibilidade das figuras; frase de software.
  - **Notas tratadas:** D10 1b, D1 item 5, γ, número atribuível, lags cujo IC exclui 1, "materially", UF.
- **Pendências do texto, para o chat:**
  1. O parágrafo da errata da D5 foi prescrito para Limitations e está no Results até haver Discussion.
  2. Placeholders: [ref], [MCC 2015], [Gasparrini & Leone 2014], [ethics statement], [repository] e o DOI XXXXXXXXXXXXX (REDU, depois da entrega).
  3. O guia do AJOG MFM não está no repositório; o tamanho mínimo de letra e o formato das figuras ficam a conferir.
  4. Introduction, Discussion e Abstract não fazem parte do M3.
- **Ramo:** 21 commits locais sobre `origin/a1-fase4` = `70731f4`, só em `artigo1_prematuridade/`. O push espera o [ok] de Guilherme.
