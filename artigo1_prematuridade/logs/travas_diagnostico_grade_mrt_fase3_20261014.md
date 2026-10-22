# Fase 3: travas do diagnóstico da grade da MRT (entrada 82(a); só leitura)

- **Gerado por:** `00_scripts/54_confere_travas_diagnostico.R`, em 2026-10-14 06:19:48 -03. Rodada `20261014`. `versao()` no início = 4443971b (o fim está na última linha).
- **Ambiente:** R 4.5.1; dlnm 2.4.10; splines 4.5.1. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib` (referência).
- **Rótulo:** travas registradas na entrada 82(a) antes de rodar, depois de ver os resultados do 53 (não é desvio). Nada foi reajustado nem recalculado: as entradas são as do 53.
- **Código (SHA-256):**
  - `codigo_compartilhado/R/diagnostico_grade_mrt.R`: `ede7f51d60ef5c433fbe60e0a60cf6469f48fadf6fb4f1f8d1115c00bf8f9948`;
  - `codigo_compartilhado/tests/testa_diagnostico_grade_mrt.R`: `9812e08da0578b0a32e34f53f1a55f457a17c532bba63526d538fd8cfa190ddc`;
  - `codigo_compartilhado/tests/roda_testes.R`: `40e7b537c500a29bfd852ac67a4fcde3fbd58128321f60fc438826360436768e`;
  - `codigo_compartilhado/R/segunda_etapa.R`: `1fb4543a3d4f0fd31bbf35571944c37756c33b1a1d11f876d48bd9bdd3aa9abb`;
  - todos os arquivos de `codigo_compartilhado/R/` da tag `segunda_etapa-v1.0` iguais aos do disco; `posthoc_af.R` igual ao da tag `posthoc_af-v1.0`; o 53, o log dele e o 45 iguais aos do commit `937dbbf`.
- **Entradas (SHA-256 conferidos contra os logs do 50, do 46 e do 53):**
  - `01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds`: `5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d`;
  - `01_saidas/fase1/serie_ptb_principal.rds`: `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917`;
  - `01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds`: `52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e`;
  - `01_saidas/fase3/posthoc_af_fase3_20261013.rds`: `223e09366a445b99bd947d3f59f66fa20d755b019af149bfeb4bac026593d11d`;
  - `01_saidas/fase3/posthoc_item2_fase3_20261013.csv`: `1da3e93205b0a5dd9e16bee068f9a66b69ebe953291e01fa81ba3d6038817511`;
  - `01_saidas/fase3/contribuicoes_negativas_fase3_20261013.csv`: `4641b22af30316679f035977668651f49e60e874a68747f7e89cd1ba21a2a1d1`;
  - `01_saidas/fase3/diagnostico_grade_mrt_fase3_20261014.csv`: `c27f652dbacba6807e2b599019f96fc1b6f15448e2581fecadc3ff59567ef3c9`;

## Travas (entrada 82(a))

- Em `classifica_celula`, para as duas classes (`classe` e `classe_num`), com tol_f = 1e-12·máx(1, máx|f(grade)|) e f(grade) na base da busca:
  1. **coerência das razões:** [mín(f(a), f(b)) − f(x*)] − (−u_min) ≥ −tol_f;
  2. **a MRT é o argmin de f na grade:** f(grade)[k] ≤ mín f(grade) + tol_f, com o k do ponto da grade da MRT;
  3. **h ≤ 0,1 + 1e-8.**
- Cada trava que cai acrescenta o seu motivo em `motivo`, separado por "; "; o resultado de cada uma sai em `trava_coerencia`, `trava_mrt_argmin` e `trava_h`.
- **Entrada 83(a):** a MRT tem de ser exatamente (bit a bit) um ponto da grade (`mrt != grade[k]` dá anômala, "MRT não é ponto da grade"), e não mais a até 1e-8; toda anômala tem motivo ("M ≤ 0 ou não finito", "razão MRT acima de 1 + tol", "razão célula acima de 1 + tol", antes dos das travas).

## Parte A: testes sintéticos e defeitos plantados

- `td10_travas` (novo): um caso por trava, com as outras duas passando e as duas classes anômalas, cada um com o seu motivo: (1) base dos dias com os nós deslocados em −0,005 °C, razões ≤ 1 e f(MRT) da base dos dias acima do da busca; (2) curva em W com o primeiro poço raso e a MRT no vizinho do argmin, abaixo dos extremos da célula do mínimo; (2b) a mesma trava na escala de tol_f, com a MRT passada 1e-10 acima do argmin; (3) grade de 0,12 °C; e os três motivos juntos (grade de 0,12 °C e MRT no outro extremo da célula).
- `td8`: os casos de tolerância das razões passaram a usar razão célula = razão MRT; entraram as três travas na regra da classe, a fronteira da tolerância da coerência (folga de −5e-12 cai; de −5e-13, passa) e o erro numa chamada sem `tol_f` e `mrt_argmin`.
- Da 1ª reauditoria: `td11_borda_f2_sinal` (novo; célula do p1 com f″ de −0,003 a 0,002, M = 0,002); no `td6`, x* exatamente no p99 com a MRT fora do argmin dá anômala, sem erro.
- Da entrada 83(a): no `td5`, a MRT a 5e-9 °C do ponto e a MRT deslocada 1 ulp (`g[k]·(1 + .Machine$double.eps)`, com `mrt != grade[k]` afirmado no teste) e a MRT abaixo do p1 dão anômala, e f(mrt) é idêntico a f(grade)[k]; no `td4`, a trava 2 passa pela base da busca embora o argmin pela base dos dias seja outro, e os motivos de razão aparecem; no `td8`, os motivos de M ≤ 0 e de razão acima de 1 + tol; `td12_motivo_f2_e_tol_f` (novo): passo numérico de 2 °C (analítica (a), numérica anômala, motivo só o da f″), f″ em V na célula com a base dos dias deslocada (analítica anômala por razão, numérica (a), travas passando, motivo "razão célula acima de 1 + tol; f″ analítica e numérica mudam a classe"), e a escala de tol_f com máx|f(grade)| = 10 (folga de −5e-12 passa) e = 0,01 (folga de −5e-13 passa, pelo máx(1, ·)).

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

Defeitos plantados (cada um numa cópia de `diagnostico_grade_mrt.R`, salvo o da grade, plantado na `grade_tmr` da cópia em memória). Cada texto de busca foi revalidado contra a função nova, com exatamente uma ocorrência; mudou só o do 1º (a chamada da `classifica_celula`, agora em duas linhas e com `tol_f` e `mrt_argmin`). Mudaram, contra a função anterior, o 1º (a chamada da `classifica_celula`, em duas linhas) e o "sem a checagem de MRT fora dos pontos da grade" (agora `if (mrt != grade[k]) {`). Os 23 primeiros são os do 53; os 3 seguintes, um por trava removida; os 6 seguintes, da 1ª reauditoria; os 7 últimos, da entrada 83(a):

| Defeito | Testes derrubados (dos que passam no original) | Quais |
|---|---|---|
| h = 0,1 na célula parcial | 2 | td2_celula_parcial_p99, td10_travas |
| grade sem o p99 (grade_tmr trocada por seq de 0,1 °C, na cópia em memória) | 3 | td2_celula_parcial_p99, td6_grade_sem_p99, td7_parte1 |
| razão da célula só contra f(MRT) | 5 | td3_quase_empate, td4_base_trocada, td8_distancia_classe, td10_travas, td12_motivo_f2_e_tol_f |
| M num ponto (f″ no dia do mínimo), e não o máximo na célula | 6 | td1_celula_vizinha, td2_celula_parcial_p99, td3_quase_empate, td4_base_trocada, td10_travas, td11_borda_f2_sinal |
| vizinhança com distância ≤ 1 | 1 | td8_distancia_classe |
| u_min com a base da busca, e não com a da attrdl | 1 | td4_base_trocada |
| dias fora do p1–p99 incluídos | 3 | td1_celula_vizinha, td6_grade_sem_p99, td11_borda_f2_sinal |
| M sem os nós internos da célula | 2 | td1_celula_vizinha, td10_travas |
| tolerância do u_min gravado frouxa (1e-6) | 1 | td5_gravado |
| tolerância das razões frouxa (1,5) | 2 | td8_distancia_classe, td12_motivo_f2_e_tol_f |
| classe (b) não detectada | 1 | td6_grade_sem_p99 |
| x* tirado do vetor completo, e não dos dias dentro do p1–p99 | 9 | td1_celula_vizinha, td2_celula_parcial_p99, td3_quase_empate, td4_base_trocada, td5_gravado, td6_grade_sem_p99, td10_travas, td11_borda_f2_sinal, td12_motivo_f2_e_tol_f |
| sem a trava M > 0 | 1 | td8_distancia_classe |
| M com a base da attrdl | 1 | td4_base_trocada |
| f(a) e f(b) com a base da attrdl | 2 | td4_base_trocada, td12_motivo_f2_e_tol_f |
| f(x*) com a base da busca | 2 | td4_base_trocada, td12_motivo_f2_e_tol_f |
| classe numérica calculada com o M analítico | 2 | td1_celula_vizinha, td12_motivo_f2_e_tol_f |
| célula parcial sem a condição de h | 1 | td2_celula_parcial_p99 |
| classe (b) só do lado do p99 | 1 | td6_grade_sem_p99 |
| sem a checagem de MRT fora dos pontos da grade | 1 | td5_gravado |
| primeiro ponto = p1 sempre verdadeiro | 1 | td7_parte1 |
| tolerância de último = p99 em 1e-2 | 1 | td7_parte1 |
| p99 acrescentado com > 0, e não > 1e-8 | 1 | td7_parte1 |
| sem a trava de coerência das razões | 3 | td6_grade_sem_p99, td8_distancia_classe, td10_travas |
| sem a trava da MRT como argmin de f na grade | 2 | td6_grade_sem_p99, td10_travas |
| sem a trava h ≤ 0,1 + 1e-8 | 2 | td8_distancia_classe, td10_travas |
| M = máx|f″|, e não máx f″ | 1 | td11_borda_f2_sinal |
| tolerância da coerência em 1e-6, e não tol_f | 1 | td8_distancia_classe |
| tolerância do argmin em 1e-6, e não tol_f | 1 | td10_travas |
| ponto k da MRT por findInterval, e não pelo ponto mais próximo | 1 | td5_gravado |
| célula por findInterval sem rightmost.closed e sem o min | 1 | td6_grade_sem_p99 |
| tol_f e mrt_argmin com valor padrão (trava 2 pulada numa chamada direta) | 1 | td8_distancia_classe |
| MRT na grade com tolerância de 1e-8, e não igualdade exata | 1 | td5_gravado |
| f(grade) da trava 2 na base da attrdl | 2 | td4_base_trocada, td10_travas |
| motivo da f″ numérica omitido | 1 | td12_motivo_f2_e_tol_f |
| motivo da f″ numérica sobrescrevendo os outros | 1 | td12_motivo_f2_e_tol_f |
| tol_f fixo em 1e-12 | 1 | td12_motivo_f2_e_tol_f |
| tol_f sem o máx(1, ·) | 1 | td12_motivo_f2_e_tol_f |
| anômala sem trava sem motivo (M ≤ 0 ou razão acima de 1 + tol) | 4 | td4_base_trocada, td8_distancia_classe, td10_travas, td12_motivo_f2_e_tol_f |

- **Resultado:** 12/12 testes; cada um dos 39 defeitos derruba pelo menos um teste.
- **M = máx|f″| e `findInterval` sem `rightmost.closed`,** antes sobreviventes justificados, caem desde a 1ª reauditoria: o `td11` (célula da borda) e o `td6` (x* no p99).
- **f″ > 0 em toda a célula do mínimo** em 15 das 15 concentrações da Parte 2.
- **Mutante equivalente:** a trava 2 com f(mrt) em vez de f(grade)[k]. Com a MRT exatamente no ponto da grade (entrada 83(a)), f(mrt) é idêntico a f(grade)[k]: conferido num teste (`td5`) e nas concentrações da Parte 2 (15 de 15). A justificativa anterior ("a trava 1 também cai") era falsa num quase empate, onde só a trava do argmin cai (entrada 83(b)).
- **Sobrevivente justificado:** sem a checagem razão MRT ≤ 1 + tol, redundante com a coerência (razão célula ≥ razão MRT − tol_f/cota) e com razão célula ≤ 1 + tol.

## Parte B: a função com as travas nas 26, comparada com o CSV do 53

- **CSV do 53:** `01_saidas/fase3/diagnostico_grade_mrt_fase3_20261014.csv` (SHA-256 `c27f652d…`), 26 linhas e 35 colunas. O `out` foi reconstruído como no 53 e convertido em texto como o 53 grava (números em `%.17g`, NA = "", lógicos TRUE/FALSE), em memória.
- **Colunas iguais:** 35 de 35. Colunas novas, à parte: `trava_coerencia`, `trava_mrt_argmin`, `trava_h`.

| Coluna | Resultado | Linhas diferentes |
|---|---|---|
| recorte_principal | igual | 0 |
| concentracao | igual | 0 |
| p1 | igual | 0 |
| p99 | igual | 0 |
| mrt | igual | 0 |
| n_grade | igual | 0 |
| primeiro | igual | 0 |
| primeiro_eh_p1 | igual | 0 |
| ultimo_seq | igual | 0 |
| p99_acrescentado | igual | 0 |
| ultimo | igual | 0 |
| ultimo_eh_p99 | igual | 0 |
| mrt_no_p99 | igual | 0 |
| dif_mrt_p99 | igual | 0 |
| n_grade_45 | igual | 0 |
| x_inf_45 | igual | 0 |
| n_dentro | igual | 0 |
| u_min | igual | 0 |
| dif_gravado | igual | 0 |
| a | igual | 0 |
| b | igual | 0 |
| h | igual | 0 |
| distancia | igual | 0 |
| ultima | igual | 0 |
| parcial | igual | 0 |
| M | igual | 0 |
| M_num | igual | 0 |
| cota | igual | 0 |
| razao_mrt | igual | 0 |
| razao_celula | igual | 0 |
| razao_mrt_num | igual | 0 |
| razao_celula_num | igual | 0 |
| classe | igual | 0 |
| classe_num | igual | 0 |
| motivo | igual | 0 |

- **Travas nas 15 concentrações com u_min < −1e-8:** coerência 15, argmin 15, h 15 (passam); nas outras 11, as travas não se aplicam (fora da Parte 2).

| Concentração | Parte 2 | Classe | Classe (f″ numérica) | Coerência | MRT = argmin | h ≤ 0,1 |
|---|---|---|---|---|---|---|
| São Paulo/SP | sim | a, vizinha | a, vizinha | sim | sim | sim |
| Rio de Janeiro/RJ | sim | a, vizinha | a, vizinha | sim | sim | sim |
| Belo Horizonte/MG | não | — | — | — | — | — |
| Brasília/DF | sim | a, vizinha | a, vizinha | sim | sim | sim |
| Recife/PE | sim | a, vizinha | a, vizinha | sim | sim | sim |
| Porto Alegre/RS | não | — | — | — | — | — |
| Fortaleza/CE | sim | a, vizinha | a, vizinha | sim | sim | sim |
| Curitiba/PR | sim | a, vizinha | a, vizinha | sim | sim | sim |
| Salvador/BA | sim | a, vizinha | a, vizinha | sim | sim | sim |
| Goiânia/GO | não | — | — | — | — | — |
| Campinas/SP | não | — | — | — | — | — |
| Manaus | não | — | — | — | — | — |
| Belém/PA | não | — | — | — | — | — |
| Vitória/ES | sim | a, vizinha | a, vizinha | sim | sim | sim |
| Baixada Santista/SP | não | — | — | — | — | — |
| São José dos Campos/SP | sim | a, vizinha | a, vizinha | sim | sim | sim |
| São Luís/MA | sim | a, vizinha | a, vizinha | sim | sim | sim |
| Natal/RN | sim | a, vizinha | a, vizinha | sim | sim | sim |
| Maceió/AL | sim | a, vizinha | a, vizinha | sim | sim | sim |
| Florianópolis/SC | sim | a, vizinha | a, vizinha | sim | sim | sim |
| João Pessoa/PB | sim | a, vizinha | a, vizinha | sim | sim | sim |
| Teresina/PI | não | — | — | — | — | — |
| Aracaju/SE | sim | a, vizinha | a, vizinha | sim | sim | sim |
| Cuiabá/MT | não | — | — | — | — | — |
| Sorocaba/SP | não | — | — | — | — | — |
| Campo Grande | não | — | — | — | — | — |

## Resultado

**Sem parada.** Com as travas, nenhum valor nem classe do 53 muda (35 de 35 colunas iguais, como texto); nas 15 concentrações da Parte 2, as três travas passam.

`versao()` no fim: 4443971b.
