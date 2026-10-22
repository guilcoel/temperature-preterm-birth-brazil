# Material suplementar (95 v1) e entrega v5: auditoria independente (21/10/2026)

- **Objeto:** `Entrega/suplemento/A1_material_suplementar_v1_20261021.docx` (script 95) e `Entrega/A1_metodos_resultados_v5_20261021.docx` (script 94 v5).
- **Auditor:** subagente em contexto limpo, sem rede, sem microdado.
- **Resultado:** 0 Crítico, 1 Maior, 4 Menores, 6 Notas.
- **Conferido sem achado:** remissões renumeradas certas nos dois docx, pelo conteúdo; primeira citação no texto principal na ordem S1 a S6; títulos e sumário em ordem; tabelas iguais aos CSVs célula a célula; Figura S1 com o SHA de origem; texto dos Methods igual ao v8, salvo as trocas registradas; frases prescritas literais; 12 referências certas; formato; anonimato; números comuns aos dois documentos iguais.
- **Reprodução pela sessão** (2026-10-21 22:17:55 -0300): `w:tblHeader` = 0 e espaço depois de 10 pt (`w:after="200"`) nas células dos **dois** docx, com colunas de largura igual (o Maior vale também para as Tabelas 1–3 da entrega, que usam a mesma função); "possible-event window" e "intersection window" sem definição no suplemento (definições na especificação: 2012-01-04 a 2024-11-15; interseção das janelas do termo precoce e do principal, 2012-04-28 a 2024-08-06); CONSULTAS sem os códigos (D15: 1, nenhuma; 2, 1–3; 3, 4–6; 4, 7 ou mais; 9, ignorado); linha "Complement" da S1 sem dizer que cobre as regras D4 (complemento: "regras operacionais dos agudos", "regra D4(a)"); três variantes do termo do eixo na entrega ("pooled temperature axis", "pooled axis", "pooled percentile axis").

| # | Nível | Achado | Tratamento (A1-154) |
|---|---|---|---|
| 1 | Maior | Tabelas sem cabeçalho repetido, com 10 pt de espaço depois em cada célula e colunas iguais | 95 v2 e 94 v6: linha de cabeçalho repetida (`tblHeader`), linhas sem quebra (`cantSplit`), espaço zero nas células, larguras proporcionais ao texto; tabelas do suplemento em 8 pt |
| 2 | Menor | Nota da S2 sem t+1 a t+7, série com zeros como ausentes, braços A e B, "possible-event window" e "intersection window" | Definições na nota da S2 (as três primeiras iguais às da legenda da Figura 4) |
| 3 | Menor | Nota da S3 cita CONSULTAS sem os códigos | Códigos na nota |
| 4 | Menor | Linha "Complement" da S1 sem relação com a D4 | Frase na nota da S1 |
| 5 | Menor | Três variantes do termo do eixo na entrega | 94 v6: "pooled axis" no Methods e nas legendas das Figuras 1 e 2, como nas figuras e no Results |
| 6 | Nota | Methods do suplemento repetem valores da S2 e da S6 | Sem mudança (coautor decide) |
| 7 | Nota | Espaço 1,15 e sem numeração de linhas no suplemento | Sem mudança (A1-153) |
| 8 | Nota | Nota "All 26 urban concentrations met…" dentro da Figura S1; sem texto alternativo | Sem mudança (exigiria o 93 v3); fica para o coautor |
| 9 | Nota | df fora da lista de abreviações; R, dlnm e mixmeta sem citação no suplemento; subtítulos internos em texto simples | df entra na lista; o resto fica |
| 10 | Nota | Legenda dos Methods no sumário parafraseia os subtítulos; a A1-153 previa trocas ("pooled temperature axis", "coprimary") que não ocorrem no suplemento v8 | Sumário com os nomes das subseções; o log do 95 v2 registra a ausência |
| 11 | Nota | Datas do modelo (2013) nos metadados; IDs da S2 vindos do português; nome do arquivo interno | Metadados com a data da rodada nos dois docx; IDs e nome do arquivo ficam para a submissão |
