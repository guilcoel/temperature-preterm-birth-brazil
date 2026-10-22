# Fase 4, Parte A: diagnostico_grade_mrt v1.0.1 — só testes e mensagens (dado sintético)

- **Gerado por:** `00_scripts/63_testes_diagnostico_v101.R` (SHA-256 `90edc0bb8c488e1b548e732fbb1fd872a421876d1551281a8bee222c0ab6f60b`), início em 2026-10-17 08:44:09 -0300, fim em 2026-10-17 08:44:14 -0300. Rodada `20261017`.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `b0533a02740be2cb0cb787093db79b26d7152708` (ramo `main`); último commit da `COORD` no `HEAD`: `257fdb0 COORD: COORD-6 (D16 e indice rev. 7)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: `?? artigo1_prematuridade/logs/testes_ajusta_offset_v11_fase4_20261017.md`; `?? artigo1_prematuridade/logs/testes_segunda_etapa_v11_fase4_20261017.md`; `?? artigo1_prematuridade/logs/testes_sens_agudos_fase4_20261017.md`.
- **Ambiente:** R 4.5.1; dlnm 2.4.10; splines 4.5.1. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib` (referência). Semente 20261001. Não toca a base; a Parte B do 54 (26 concentrações) não roda.
- **Rótulo:** travas da entrada 82(a), registrada antes de rodar; a MRT como ponto exato da grade e os motivos das anômalas são **alteração post hoc (entrada 83(a)), depois de ver os resultados do 53 e do 54** (Menor 5). A v1.0.1 não muda nenhuma função.
- **Código, testes e o 54 (SHA-256; todos commitados e limpos antes de rodar; o 54 e o log dele não são alterados):**
  - `codigo_compartilhado/R/diagnostico_grade_mrt.R`: `b263bdf6453a950a4fc544860baf3b989f190e432740a1c89065b15e7b2f9731`;
  - `codigo_compartilhado/tests/roda_testes_fase4.R`: `b176d9e1fd46f7d87a81d2bad3604f08a8178662c6a24dfc18c828a27ec9a509`;
  - `codigo_compartilhado/tests/testa_diagnostico_grade_mrt.R`: `79ae78350e2eaee7e9dabee2a2ddd34a28be2eeba9d792b0dfb86afae15f7d32`;
  - `artigo1_prematuridade/00_scripts/54_confere_travas_diagnostico.R`: `d840813d33fa9b2f4edf38550eca779dd7c562951fc77e40e91107cc90444e0d`;
  - `artigo1_prematuridade/logs/travas_diagnostico_grade_mrt_fase3_20261014.md`: `2f1ea7d701919b661a029695f45aa5aebfed16af9beb89449d0cc9e07f457739`;
  - `artigo1_prematuridade/00_scripts/63_testes_diagnostico_v101.R`: `90edc0bb8c488e1b548e732fbb1fd872a421876d1551281a8bee222c0ab6f60b`;
- **Nenhuma classe nem valor do 53 muda:** o corpo de cada função da v1.0.1 é idêntico, por `deparse`, ao da tag `diagnostico_grade_mrt-v1.0` (`c7ce6a5`): sim. A grade é a `grade_tmr` da tag `segunda_etapa-v1.0.1`, lida por `git show`.

## Resultado: 15/15 testes

- Novos ou alterados na v1.0.1: `td5` (asserções de `classe_num` nos caminhos "MRT não é ponto da grade" e "parada"; Menor 2); `td7` (p99 a 0,005 °C do último ponto do seq e MRT no penúltimo; Nota 9); `td13_tol_f_frouxo` (folga da coerência em −5e-12 com máx|f(grade)| < 1, entre −10·tol_f e −tol_f: anômala; Menor 1); `td14_cota_pequena` (M = 1e-6, h = 0,1, razão MRT = 1,0001, razão célula = 1: anômala só pela checagem da razão MRT; Menor 3); `td15_M_nao_finito` (M = Inf e NaN: motivo "M ≤ 0 ou não finito"; Nota 8).

| Teste | Resultado |
|---|---|
| `td1_celula_vizinha` | passou |
| `td2_celula_parcial_p99` | passou |
| `td3_quase_empate` | passou |
| `td4_base_trocada` | passou |
| `td5_gravado` | passou |
| `td6_grade_sem_p99` | passou |
| `td7_parte1` | passou |
| `td8_distancia_classe` | passou |
| `td10_travas` | passou |
| `td11_borda_f2_sinal` | passou |
| `td12_motivo_f2_e_tol_f` | passou |
| `td9_f_e_f2` | passou |
| `td13_tol_f_frouxo` | passou |
| `td14_cota_pequena` | passou |
| `td15_M_nao_finito` | passou |

## Defeitos plantados (45: os 39 do 54 e 6 da reauditoria; cada um numa cópia da função, salvo o da grade, plantado na `grade_tmr` da cópia em memória)

- Os textos de busca dos 39 do 54 são os mesmos e foram revalidados contra a função (exatamente uma ocorrência cada); a função não mudou desde o 54. (Este texto corrige o do log do 54, que dizia, ao mesmo tempo, que mudara só o do 1º e que mudaram o 1º e o "sem a checagem": Menor 4.)

| Defeito | Testes derrubados | Por critério | Por erro | Quais |
|---|---|---|---|---|
| h = 0,1 na célula parcial | 2 | 2 | 0 | td2_celula_parcial_p99, td10_travas |
| grade sem o p99 (grade_tmr trocada por seq de 0,1 °C, na cópia em memória) | 3 | 3 | 0 | td2_celula_parcial_p99, td6_grade_sem_p99, td7_parte1 |
| razão da célula só contra f(MRT) | 6 | 6 | 0 | td3_quase_empate, td4_base_trocada, td8_distancia_classe, td10_travas, td12_motivo_f2_e_tol_f, td14_cota_pequena |
| M num ponto (f″ no dia do mínimo), e não o máximo na célula | 6 | 6 | 0 | td1_celula_vizinha, td2_celula_parcial_p99, td3_quase_empate, td4_base_trocada, td10_travas, td11_borda_f2_sinal |
| vizinhança com distância ≤ 1 | 1 | 1 | 0 | td8_distancia_classe |
| u_min com a base da busca, e não com a da attrdl | 2 | 2 | 0 | td4_base_trocada, td13_tol_f_frouxo |
| dias fora do p1–p99 incluídos | 3 | 3 | 0 | td1_celula_vizinha, td6_grade_sem_p99, td11_borda_f2_sinal |
| M sem os nós internos da célula | 2 | 2 | 0 | td1_celula_vizinha, td10_travas |
| tolerância do u_min gravado frouxa (1e-6) | 1 | 1 | 0 | td5_gravado |
| tolerância das razões frouxa (1,5) | 3 | 3 | 0 | td8_distancia_classe, td12_motivo_f2_e_tol_f, td14_cota_pequena |
| classe (b) não detectada | 1 | 1 | 0 | td6_grade_sem_p99 |
| x* tirado do vetor completo, e não dos dias dentro do p1–p99 | 9 | 9 | 0 | td1_celula_vizinha, td2_celula_parcial_p99, td3_quase_empate, td4_base_trocada, td5_gravado, td6_grade_sem_p99, td10_travas, td11_borda_f2_sinal, td12_motivo_f2_e_tol_f |
| sem a trava M > 0 | 1 | 1 | 0 | td8_distancia_classe |
| M com a base da attrdl | 1 | 1 | 0 | td4_base_trocada |
| f(a) e f(b) com a base da attrdl | 3 | 3 | 0 | td4_base_trocada, td12_motivo_f2_e_tol_f, td13_tol_f_frouxo |
| f(x*) com a base da busca | 2 | 2 | 0 | td4_base_trocada, td12_motivo_f2_e_tol_f |
| classe numérica calculada com o M analítico | 2 | 2 | 0 | td1_celula_vizinha, td12_motivo_f2_e_tol_f |
| célula parcial sem a condição de h | 1 | 1 | 0 | td2_celula_parcial_p99 |
| classe (b) só do lado do p99 | 1 | 0 | 1 | td6_grade_sem_p99 |
| sem a checagem de MRT fora dos pontos da grade | 1 | 1 | 0 | td5_gravado |
| primeiro ponto = p1 sempre verdadeiro | 1 | 1 | 0 | td7_parte1 |
| tolerância de último = p99 em 1e-2 | 1 | 1 | 0 | td7_parte1 |
| p99 acrescentado com > 0, e não > 1e-8 | 1 | 1 | 0 | td7_parte1 |
| sem a trava de coerência das razões | 4 | 4 | 0 | td6_grade_sem_p99, td8_distancia_classe, td10_travas, td13_tol_f_frouxo |
| sem a trava da MRT como argmin de f na grade | 2 | 2 | 0 | td6_grade_sem_p99, td10_travas |
| sem a trava h ≤ 0,1 + 1e-8 | 2 | 2 | 0 | td8_distancia_classe, td10_travas |
| M = máx|f″|, e não máx f″ | 1 | 1 | 0 | td11_borda_f2_sinal |
| tolerância da coerência em 1e-6, e não tol_f | 2 | 2 | 0 | td8_distancia_classe, td13_tol_f_frouxo |
| tolerância do argmin em 1e-6, e não tol_f | 1 | 1 | 0 | td10_travas |
| ponto k da MRT por findInterval, e não pelo ponto mais próximo | 1 | 0 | 1 | td5_gravado |
| célula por findInterval sem rightmost.closed e sem o min | 1 | 0 | 1 | td6_grade_sem_p99 |
| tol_f e mrt_argmin com valor padrão (trava 2 pulada numa chamada direta) | 1 | 1 | 0 | td8_distancia_classe |
| MRT na grade com tolerância de 1e-8, e não igualdade exata | 1 | 1 | 0 | td5_gravado |
| f(grade) da trava 2 na base da attrdl | 2 | 2 | 0 | td4_base_trocada, td10_travas |
| motivo da f″ numérica omitido | 1 | 1 | 0 | td12_motivo_f2_e_tol_f |
| motivo da f″ numérica sobrescrevendo os outros | 1 | 1 | 0 | td12_motivo_f2_e_tol_f |
| tol_f fixo em 1e-12 | 1 | 1 | 0 | td12_motivo_f2_e_tol_f |
| tol_f sem o máx(1, ·) | 1 | 1 | 0 | td12_motivo_f2_e_tol_f |
| anômala sem trava sem motivo (M ≤ 0 ou razão acima de 1 + tol) | 6 | 6 | 0 | td4_base_trocada, td8_distancia_classe, td10_travas, td12_motivo_f2_e_tol_f, td14_cota_pequena, td15_M_nao_finito |
| Menor 1: tol_f 10× mais frouxo | 1 | 1 | 0 | td13_tol_f_frouxo |
| Menor 2 (A3): só a classe analítica no caminho "MRT não é ponto da grade" | 1 | 1 | 0 | td5_gravado |
| Menor 2 (X3): só a classe analítica na parada | 1 | 1 | 0 | td5_gravado |
| Menor 3: sem a checagem razão MRT ≤ 1 + tol (antes sobrevivente) | 1 | 1 | 0 | td14_cota_pequena |
| Nota 8 (A2): M não finito sem is.finite no motivo | 1 | 1 | 0 | td15_M_nao_finito |
| Nota 9 (A5): mrt_no_p99 com tolerância de 1e-2 | 1 | 1 | 0 | td7_parte1 |

## Mutantes equivalentes ou quase equivalentes (não contam como defeito; registro das Notas 6 e 7)

| Defeito | Testes derrubados | Por critério | Por erro | Quais |
|---|---|---|---|---|
| trava 2 com f(mrt), e não f(grade)[k] (equivalente com a MRT exatamente no ponto da grade, f(mrt) pela base da busca; Nota 6) | 0 | 0 | 0 | nenhum |
| X4: k por max(1L, findInterval(...)) (quase equivalente sob igualdade exata; Nota 7) | 0 | 0 | 0 | nenhum |

- A trava 2 com f(mrt) é equivalente porque a MRT é exatamente um ponto da grade e f(mrt) é calculado **pela base da busca** (com a base da attrdl não seria; Nota 6). O X4 só cai, se cair, por erro no caso da MRT abaixo do p1; sob igualdade exata é equivalente (Nota 7).

- **Resultado:** 15/15 testes; cada um dos 45 defeitos derruba pelo menos um teste (inclusive o antes sobrevivente "sem a checagem razão MRT ≤ 1 + tol"); nenhuma função mudou.

