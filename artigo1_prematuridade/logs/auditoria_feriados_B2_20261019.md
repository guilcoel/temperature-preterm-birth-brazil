# Fase 4, Parte B2: auditoria independente da tabela de feriados locais (por amostra)

- **Quando:** 2026-10-19; registro às 10:53:43 −03:00 (hora lida com `date`), logo depois do relatório do subagente. Tabela auditada: `01_saidas/fase4/feriados/feriados_locais_nucleo_2011_2024.csv` depois da A1-110 (1.116 linhas, SHA-256 `8af8fea3…ef223`).
- **Como:**
  - amostra de 80 linhas sorteada pela sessão com semente 20261001: 50 da rodada 2 e 30 da rodada 1, em 22 núcleos;
  - cada linha conferida pelo subagente na fonte (URL da linha ou ato oficial): existência, data, vigência, esfera e regras do README;
  - checagens por código na tabela inteira;
  - busca de omissões em cinco núcleos (Belém, Recife, São José dos Campos, Curitiba e Goiânia).
  O subagente só leu fontes públicas e não alterou nada na pasta nem no repositório.

## Resultado

| | Confirmada | Com ressalva | Não confirmada | Errada |
|---|---|---|---|---|
| Rodada 2 (50) | 36 | 12 | 2 | 0 |
| Rodada 1 (30) | 27 | 3 | 0 | 0 |
| **Total** | **63** | **15** | **2** | **0** |

- **Checagens por código:**
  - recorrentes completos, com as lacunas explicadas;
  - regras móveis (SC, PE de 2011 a 2017, Penha) 100%;
  - calendário nacional e móvel recalculado pela Páscoa (183 datas) igual ao de apoio;
  - nenhuma data local coincide com ele, nem com 24/12 ou 31/12;
  - antecipações com a data original retirada em 32 de 33; a exceção é João Pessoa, 05/08/2021, já listada como dúvida no README.
- **Omissões:** nenhum feriado observado faltando nos cinco núcleos.

## Achados e tratamento

- **Críticos:** 0.
- **Maior 1, AL, critério incoerente entre o 16/09 e o 30/11:** os decretos anuais trazem os dois como "feriado estadual". A sessão não refez a leitura dos decretos: a decisão não depende dela, porque usa o fato já registrado na rodada 2 (nenhuma lei estadual antes da Lei 9.358/2024 institui o 16/09). Tratamento (A1-112): critério único com o 30/11 do DF; feriado só por decreto do Executivo, sem lei, fica fora pela decisão 5. Saem as 13 datas do 16/09 de 2011 a 2023; a tabela vai a 1.103 linhas (SHA-256 `ef5d99b1bfb1d0a33f44ad057e8b542015ce61aa9da5fb3d73caf117daba2e03`; conferência sem erros, conferida pela sessão).
- **Menor 2, Recife, 06/03 municipal (Lei Orgânica, art. 175):** fica fora (README), sem mudança na tabela.
- **Menor 3, Maceió, 16/09 sem fonte do ano:** sem efeito, porque as datas saíram pela A1-112.
- **Menor 4, Aracaju, URL fora do ar:** registrado no README; a data é confirmada por portaria do MPF-SE.
- **Menor 5, README desatualizado:** corrigido (1.103 linhas, 25 núcleos).
- **Notas:**
  - a dúvida 3 (Rio, Lei 3.572/2003) está resolvida, sem efeito;
  - fontes de Maceió (08/12) e do CE (Data Magna): anotadas no README;
  - **Brasília sem linha:** na junção, a covariável `feriado_local` dela vale 0, e a concentração não é descartada. Conferir no script da análise de feriados locais.
- **Limite:** auditoria por amostra (80 de 1.116); os achados de fonte são do subagente e só entram na tabela quando a decisão não depende deles ou quando a sessão os conferiu.
