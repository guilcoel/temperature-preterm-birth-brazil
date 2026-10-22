# A5: percentil semanal equivalente da MM14 (1º e 2º trimestres), com a MM9 ao lado (Fase 0 refeita)

- **Gerado por:** `00_scripts/08_mm14_equivalente_rerun.R`, em 2026-10-09 08:44:25 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Só exposição:** `expo_semanal("tmean", "nucleo")`, `dum_est` de 2011-04-17 a 2024-03-05 (4.707 por concentração). Nenhum desfecho.
- **Método (o mesmo da MM9 na Fase 0A; decisões §7):** distribuição semanal (i) = todos os `s01`…`s37`, empilhados, sem ponderação; percentis com `quantile(type = 7)`; percentil equivalente = `ecdf` da (i) avaliada no valor, × 100, com uma casa.
  - **Onde está na Fase 0A** (versão arquivada no `.tar`): no `02_recontagens_fase0.R`, linha 132 (`F <- ecdf(emp)`) e linha 141 (`mm9_p99_em_pct_semanal_i = 100 * F(qm[3])`); no `04_mm14_equivalentes_fase0.R`, linha 37 (`Fi <- ecdf(as.vector(m))`) e linhas 42–44 (`100 * Fi(q$t1[1])` …).
  - **Onde está aqui (código diferente):** linha 31 (`pct_i`, `findInterval` sobre a (i) ordenada = nº de valores ≤ x / n), linha 27 (quantil tipo 7 à mão, conferido contra `quantile(type = 7)`: maior diferença 3.552714e-15) e linha 43 (médias móveis por `%*%`).
- **Comparação com o complemento da Fase 0A** (`01_saidas/fase0/a5_4b_mm14_equivalentes.csv`, código do `04`): maior |diferença| em cada uma das 12 colunas numéricas = 5.684342e-14 (tolerância 1e-09).
- **Comparação com a A5.4 refeita** (`a5_4_semanal_mm.csv`, código do `02`): MM9 e MM14 em °C e percentil equivalente da MM9, maior |diferença| = 5.684342e-14.
- **Resultado:** igual nas duas comparações.
- **CSV completo:** `01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv`, fora do git (mesmas colunas do `a5_4b` do complemento).

## Resumo nas 26 concentrações

| Valor da média móvel | Percentil semanal (i): média nas 26 | Mínimo | Máximo |
|---|---|---|---|
| MM14, 1º trimestre, p1 | p8,5 | p3,8 (Aracaju/SE) | p11,8 (Belo Horizonte/MG) |
| MM14, 1º trimestre, p99 | p93,4 | p88,0 (Curitiba/PR) | p97,9 (Recife/PE) |
| MM14, 2º trimestre, p1 | p9,1 | p3,8 (Aracaju/SE) | p12,7 (Teresina/PI) |
| MM14, 2º trimestre, p99 | p93,4 | p88,0 (Curitiba/PR) | p97,9 (Recife/PE) |
| MM9, p1 (ao lado) | p6,0 | p2,4 (Aracaju/SE) | p8,2 (São Paulo/SP) |
| MM9, p99 (ao lado) | p95,3 | p90,6 (São José dos Campos/SP) | p99,0 (Belém/PA) |

## Por concentração (°C e percentil semanal equivalente na leitura (i))

| Concentração | MM14 T1 p1 °C | = p (i) | MM14 T1 p99 °C | = p (i)  | MM14 T2 p1 °C | = p (i)   | MM14 T2 p99 °C | = p (i)    | MM9 p1 = p (i) | MM9 p99 = p (i) |
|---|---|---|---|---|---|---|---|---|---|---|
| São Paulo/SP | 17,40 | 10,8 | 24,78 | 89,7 | 17,48 | 11,3 | 24,78 | 89,7 | 8,2 | 93,3 |
| Rio de Janeiro/RJ | 20,83 | 10,8 | 28,12 | 90,7 | 20,85 | 11,0 | 28,12 | 90,7 | 8,0 | 93,6 |
| Belo Horizonte/MG | 19,93 | 11,8 | 25,72 | 93,1 | 19,93 | 11,8 | 25,72 | 93,1 | 7,1 | 95,1 |
| Brasília/DF | 20,33 | 10,3 | 25,49 | 94,3 | 20,33 | 10,3 | 25,49 | 94,3 | 5,7 | 95,5 |
| Recife/PE | 24,21 | 7,2 | 28,92 | 97,9 | 24,21 | 7,2 | 28,92 | 97,9 | 4,0 | 98,2 |
| Porto Alegre/RS | 14,85 | 9,1 | 26,30 | 90,3 | 14,99 | 9,7 | 26,30 | 90,3 | 7,5 | 93,2 |
| Fortaleza/CE | 26,94 | 8,2 | 29,34 | 96,1 | 27,04 | 11,2 | 29,34 | 96,1 | 6,8 | 98,6 |
| Curitiba/PR | 14,49 | 9,1 | 23,05 | 88,0 | 14,52 | 9,4 | 23,05 | 88,0 | 6,7 | 92,9 |
| Salvador/BA | 23,58 | 4,1 | 28,77 | 96,2 | 23,91 | 8,0 | 28,77 | 96,2 | 4,6 | 96,9 |
| Goiânia/GO | 22,55 | 10,5 | 27,79 | 93,6 | 22,56 | 10,7 | 27,79 | 93,6 | 5,5 | 95,7 |
| Campinas/SP | 18,21 | 9,6 | 25,49 | 89,2 | 18,30 | 10,6 | 25,49 | 89,2 | 7,2 | 92,2 |
| Manaus | 26,95 | 9,8 | 30,38 | 96,9 | 26,95 | 9,8 | 30,38 | 96,9 | 7,4 | 97,7 |
| Belém/PA | 27,23 | 8,4 | 29,32 | 97,4 | 27,23 | 8,4 | 29,32 | 97,4 | 6,1 | 99,0 |
| Vitória/ES | 22,01 | 9,1 | 28,18 | 92,0 | 22,01 | 9,1 | 28,18 | 92,0 | 4,5 | 94,0 |
| Baixada Santista/SP | 19,34 | 9,6 | 26,94 | 90,0 | 19,34 | 9,6 | 26,94 | 90,0 | 6,6 | 92,6 |
| São José dos Campos/SP | 17,10 | 9,4 | 24,38 | 88,5 | 17,20 | 10,4 | 24,38 | 88,5 | 6,4 | 90,6 |
| São Luís/MA | 26,59 | 4,9 | 29,41 | 92,2 | 26,59 | 4,9 | 29,41 | 92,2 | 3,0 | 94,5 |
| Natal/RN | 25,31 | 7,1 | 28,79 | 97,3 | 25,31 | 7,1 | 28,79 | 97,3 | 4,2 | 97,4 |
| Maceió/AL | 24,23 | 6,6 | 28,32 | 96,7 | 24,28 | 7,6 | 28,32 | 96,7 | 5,2 | 97,4 |
| Florianópolis/SC | 16,44 | 6,4 | 26,03 | 90,1 | 16,66 | 7,6 | 26,03 | 90,1 | 5,7 | 93,8 |
| João Pessoa/PB | 24,98 | 4,7 | 28,88 | 96,4 | 24,98 | 4,7 | 28,88 | 96,4 | 3,1 | 96,7 |
| Teresina/PI | 27,08 | 9,8 | 31,04 | 95,6 | 27,17 | 12,7 | 31,04 | 95,6 | 8,0 | 97,7 |
| Aracaju/SE | 24,71 | 3,8 | 28,80 | 95,7 | 24,71 | 3,8 | 28,80 | 95,7 | 2,4 | 96,8 |
| Cuiabá/MT | 24,08 | 9,5 | 30,50 | 96,7 | 24,08 | 9,5 | 30,50 | 96,7 | 7,8 | 97,6 |
| Sorocaba/SP | 17,99 | 9,1 | 25,71 | 90,2 | 18,13 | 10,1 | 25,71 | 90,2 | 7,4 | 92,5 |
| Campo Grande | 20,61 | 10,7 | 27,95 | 93,4 | 20,65 | 10,8 | 27,95 | 93,4 | 7,8 | 95,0 |

`versao()` no fim: 4443971b.
