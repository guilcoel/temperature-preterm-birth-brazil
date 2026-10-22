# Fase 1, A7.1: autoauditoria

- **Gerado por:** `00_scripts/25_autoauditoria_fase1.R`, em 2026-10-09 21:13:42 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Método:** cada número dos logs da Fase 1 foi recalculado a partir dos arquivos de origem (base, RDS e CSV da fase), com código diferente do que o gerou, e comparado com o valor registrado (`01_saidas/fase1/conferencias_valores.csv`, gravado pelo 23 com os mesmos números do log da A6) ou com o texto dos logs do 20, 21, 22 e 24.
- **Código diferente:** `rowsum`, `aggregate`, `colSums` e `table` no lugar de `tapply`; w_j por `cumsum` de tabela concentração × IG, sem `calcula_wj()`; offset recalculado direto do `gestacoes_em_risco`, sem `monta_offset()`; classificação do espontâneo por códigos combinados e expressões regulares; Z_tj por intervalo de datas [s + 7j, s + 7j + 6] com término ≥ t; calendário contado direto no `calendario()`; média e amplitude direto da `serie_diaria`.
- **Tolerâncias:** contagens, exatas; razões e logaritmos, 1e-12 a 1e-15; médias e percentuais, 1e-9.

## Resultado: 54 de 54 conferências iguais

| Item | Conferência | N | Maior dif. | Resultado |
|---|---|---|---|---|
| A1 | bateria n/n no log do 24 |      1 | — | igual |
| A1 | testes que passam (re-rodados) = total de testes |      1 | 0 | igual |
| A2 | w_j por concentração × semana (cumsum de tabela × CSV do 20) |    390 | 4.86e-17 | igual |
| A2 | NV da população do w_j, nº de linhas e pares com n_j < 10 no log do 20 |      3 | — | igual |
| A2 | linhas da série principal = 26 × 4.721 |      1 | 0 | igual |
| offset | z_t na janela de evento possível (rowsum × RDS) | 122200 | 0 | igual |
| offset | log_w (Σ Z·w / Z, recalculado × RDS) | 122200 | 2.66e-15 | igual |
| offset | log_zw (recalculado × RDS) | 122200 | 2.22e-15 | igual |
| offset | offset NA fora da janela de evento possível |      1 | 0 | igual |
| A6.1 | NA nas 20 colunas de modelo (colSums × valores do 23) |     20 | 0 | igual |
| A6.1 | dias na janela principal: mínimo e máximo entre as 26 (table) = 4.498 |      3 | 0 | igual |
| A6.1 | NA na tmean_nucleo de 2011-12-14 a 2024-11-15 |      1 | 0 | igual |
| A6.3 | dias da janela de evento possível com Z_t ≤ 0 ou offset NA |      1 | 0 | igual |
| A6.3 | dias da janela principal sem alguma semana de 22 a 36 (rowsum) |      1 | 0 | igual |
| A6.2 | PTB na janela principal por concentração (rowsum × valores do 23) |     26 | 0 | igual |
| A6.2 | PTB na janela principal × A5.2 congelada |     26 | 0 | igual |
| A6.2 | os 26 totais e o total das 26 no texto do log da A6 |     27 | — | igual |
| A6.3 | Z_t médio por concentração (aggregate × valores do 23) |     26 | 4.37e-11 | igual |
| A6.3 | DP médio intra-estrato de log_w (aggregate × valores do 23) |     26 | 4.86e-17 | igual |
| A6.3 | DP de Sorocaba e de São Paulo no texto do log |      2 | — | igual |
| A6.3 | Z_t médio e DP das 26 concentrações na tabela do log |     26 | — | igual |
| A6.4 | células comparadas e diferentes (intervalo de datas × base) |      2 | 0 | igual |
| A6.5 | w_j com as 26 somadas (cumsum × valores do 23) |     15 | 4.16e-17 | igual |
| A6.5 | mínimo, mediana e máximo entre as concentrações, só n_j ≥ 10 (apply × valores do 23) |     45 | 4.86e-17 | igual |
| A6.5 | pares com n_j < 10 e concentrações com w_j crescente |      2 | 0 | igual |
| A6.6 | estratos e estratos sem PTB (principal e municipal) |      4 | 0 | igual |
| A6.7 | dias por dia da semana (format(data, "%u")), feriados, carnaval e móveis (calendario() direto × valores do 23) |     10 | 0 | igual |
| A6.8 | média e amplitude p99 − p1 da tmean_nucleo (serie_diaria direto × valores do 23) |     52 | 4.62e-14 | igual |
| A6.8 / A2.6 | 9 valores × 2 períodos × 26 recalculados da serie_diaria × A5.3 refeita |    468 | 4.97e-14 | igual |
| A6.8 / A2.6 | 9 valores × 2 períodos × 26 recalculados da serie_diaria × referencias_exposicao.csv do 20 |    468 | 4.97e-14 | igual |
| A6.8 | média e amplitude das 26 na tabela do log |     26 | — | igual |
| A6.9 | % espontâneo, iniciado e ignorado por ano, 2013–2023 (códigos combinados × valores do 23) |     33 | 4.97e-14 | igual |
| A6.9 | % por concentração, 2013–2023 (códigos combinados × valores do 23) |     78 | 4.97e-14 | igual |
| A6.9 | células mascaradas na tabela por concentração (regra reimplementada × 23) |      1 | 0 | igual |
| A6.9 | % de sttrabpart 9 ou vazio entre todos os NV, por ano (table × valores do 23) |     11 | 5.33e-15 | igual |
| A6.9 / A4 | identidade espontâneo (i) + iniciado + ignorado = ptb (divergências) |      1 | 0 | igual |
| A4 | identidade no log do 22 |      1 | — | igual |
| A6.10 | municípios, dias-município com Z_t > 0 e municípios sem PTB (janela principal) |      3 | 0 | igual |
| A3 | linhas da série municipal no log do 21 |      1 | — | igual |
| A3 | dias-município sem célula nas semanas 22 a 36, de 2012-01-01 a 2024-11-15 (base × log do 21) |      1 | 0 | igual |
| A3 | dias-município de 2011-12-14 a 2011-12-31 (277 × 18 × log do 21) |      1 | 0 | igual |
| A3 | dias-município com z_t_zero no RDS = 2011 + sem célula nas semanas 22–36 + com célula só por z_fetal |      1 | 0 | igual |
| A3 | offset NA exatamente nos dias de Z_t = 0 (todo o período gravado) |      1 | 0 | igual |
| A3 | dias só com z_fetal mascarados no log do 21 |      1 | — | igual |
| A6.7 | rótulo do dia da semana × format(data, "%u"), dia a dia, em todas as linhas da série principal (divergências) |      1 | 0 | igual |
| A6.1 | NA e concentrações com NA, por coluna, na tabela do log |     20 | — | igual |
| A6.1 | NA de PM2.5 (zero = NA) por concentração no log |      1 | — | igual |
| A6.3 | estratos por concentração na janela principal (todas iguais) |      1 | 0 | igual |
| A6.3 | nº de estratos por concentração no texto do log |      1 | — | igual |
| A6.4 | as 5 datas sorteadas no texto do log |      1 | — | igual |
| A6.5 | concentrações com w_j não crescente no texto do log |      1 | — | igual |
| A3 | linha_modelo no log do 21 |      1 | — | igual |
| A1 | testes derrubados por cada defeito (re-rodados) na tabela do log do 24 |      3 | — | igual |
| A6 | SHA-256 do conferencias_valores.csv no log da A6 |      1 | — | igual |

`versao()` no fim: 4443971b.
