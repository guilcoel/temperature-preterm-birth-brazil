# Fase 3: reauditoria da versão final do diagnóstico da grade da MRT (entrada 83(a)), 14/10/2026

Registro achado → reprodução → correção, como manda o `CLAUDE.md` do artigo e a seção 1.5 do parecer do chat do Artigo 1 de 14/10/2026 (sobre a RESPOSTA das travas). Só leitura: nada foi reajustado nem recalculado; nenhuma linha diária, data, x_t do dia do mínimo, contagem diária, u_min com mais de 4 algarismos ou coeficiente BLUP foi impresso ou gravado.

## Reauditoria em contexto limpo

- **Auditor:** subagente em contexto limpo, depois da rodada do 54 de 14/10, 06:19:48, e antes do C12.
  - Leu a entrada 83 e o diff da função, dos testes e do 54 contra o `3cc0dea`.
  - Leu com R, sem imprimir linhas, as RDS e o CSV das entradas do 54.
  - Não rodou os scripts 40 a 54, não chamou `cidade_nucleo()` e não escreveu no repositório.
  - Rodou com código próprio (`aud15/*`, no scratchpad).
- **Versão auditada (a final, que vai no C12):**
  - `codigo_compartilhado/R/diagnostico_grade_mrt.R`: `ede7f51d60ef5c433fbe60e0a60cf6469f48fadf6fb4f1f8d1115c00bf8f9948`;
  - `codigo_compartilhado/tests/testa_diagnostico_grade_mrt.R`: `9812e08da0578b0a32e34f53f1a55f457a17c532bba63526d538fd8cfa190ddc`;
  - `artigo1_prematuridade/00_scripts/54_confere_travas_diagnostico.R`: `d840813d33fa9b2f4edf38550eca779dd7c562951fc77e40e91107cc90444e0d`;
  - log do 54: `2f1ea7d701919b661a029695f45aa5aebfed16af9beb89449d0cc9e07f457739`.
- **Veredito do auditor:** nenhum achado Crítico nem Maior, então a regra de parada da 83(a5) não dispara.
  - Só entrou a 83(a). Em 200.000 sorteios, a `classifica_celula` do `3cc0dea` e a atual dão 0 classes diferentes, 0 anômalas sem motivo e 0 classes (a) com motivo.
  - A bateria dá 12/12. Os 39 textos de busca têm exatamente uma ocorrência e cada defeito derruba pelo menos um teste, com os mesmos testes da tabela do log.
  - A "trava 2 com f(mrt)" é mutante equivalente, com o f(mrt) calculado pela base da busca.
  - A Parte B, refeita de forma independente (sem `cidade_nucleo()`, por isso sem a coluna `concentracao`), dá 34/34 colunas iguais ao CSV `c27f652d…`; a MRT é bit a bit o ponto da grade nas 26; e f(mrt) é idêntico a f(grade)[k] nas 26.
  - Os cenários dos testes novos são legítimos. Ele confirmou que, com uma trava caindo, as duas classes ficam anômalas e o motivo da f″ não aparece.
- **Os 5 defeitos do auditor:** 4 sobrevivem (A1, A2, A3 e A5) e 1 cai (A4); além deles, X1 a X4. Nenhum muda os dados do A1 (34/34 em todos).
- **Achados:** 10 (5 Menores e 5 Notas), todos aceitos.
  - Reproduzidos por código próprio da sessão (`repro_aud15.R`, no scratchpad): os achados 1, 2, 3, 6, 7, 8 e 9.
  - Pela leitura do log e do código: os achados 4, 5 e 10.
- **Correções em aberto.** O parecer manda não rodar o 54 de novo sem instrução do chat (seção 1.5). Por isso, **nenhuma correção foi feita** na função, nos testes ou no 54 depois desta reauditoria. As correções propostas vão ao chat na RESPOSTA. Nenhum achado muda resultado do A1.

| Nº | Grav. | Achado | Reprodução | Correção proposta (pendente) |
|---|---|---|---|---|
| 1 | Menor | A bateria não detecta tol_f mais frouxo que o devido (os testes da 83(a3) só cobrem o tol_f apertado demais). Com 1e-11·máx(1, ·), 3e-11 ou 1e-10, nenhum teste cai | Código próprio: o defeito com 1e-11 passa nos 12 testes. No cenário do `td1` (máx\|f(grade)\| = 0,678), com a folga da coerência em −5e-12, o original dá anômala e o defeito dá "a, vizinha" | Caso de fronteira com folga entre −tol_f e −10·tol_f, que tem de dar anômala; defeito "tol_f 10×" no 54. No A1, a folga é 0 exato nas 15 |
| 2 | Menor | No caminho da 83(a1) ("MRT não é ponto da grade"), nenhum teste confere a `classe_num` (idem na "parada") | Código próprio: os defeitos que só marcam `out$classe` (A3, no caminho da (a1); X3, na parada) passam nos 12 testes | Asserções de `classe_num` no `td5` |
| 3 | Menor | A justificativa do sobrevivente "sem a checagem razão MRT ≤ 1 + tol" ("redundante") é inexata: só vale a menos de tol_f/cota, que pode passar de tol | Código próprio: com M = 1e-6, h = 0,1, razão MRT = 1,0001 e razão célula = 1, o original dá anômala; o mutante dá "a, vizinha" com o motivo "razão MRT acima de 1 + tol" (incoerente com a 83(a2)). No A1, a maior razão MRT é 0,76 | Caso de teste com cota pequena; o defeito sai da lista de sobreviventes e entra no 54 |
| 4 | Menor | O texto fixo do log do 54 se contradiz: mantém "mudou só o do 1º" e acrescenta "mudaram o 1º e o 'sem a checagem'" | Leitura: contra o 53, mudaram os dois; contra o `3cc0dea`, só o da checagem | Corrigir o texto fixo no 54 (exige nova rodada) |
| 5 | Menor | O log do 54 não diz que a 83(a) é alteração post hoc: o título e o rótulo citam só a 82(a) "antes de rodar" | Leitura do log | Rótulo "alteração post hoc (entrada 83(a)), depois de ver os resultados do 53 e do 54" no 54 (exige nova rodada) |
| 6 | Nota | A equivalência da "trava 2 com f(mrt)" depende da base: com o f(mrt) da base da `attrdl` não é equivalente. O log e a entrada não dizem qual base. A igualdade bit a bit também depende da BLAS de referência, que o 54 exige e a função não | Código próprio: com a base da `attrdl` (A4), o defeito cai (2 testes); com a base da busca, sobrevive | Dizer "f(mrt) pela base da busca" no log e na RESPOSTA |
| 7 | Nota | O defeito 30 ("k por `findInterval`") ficou quase equivalente com a 83(a1): só cai por erro no caso da MRT abaixo do p1 | Código próprio: a variante `max(1L, findInterval(...))` (X4) passa nos 12 testes, e sob igualdade exata é equivalente | Registrar como quase equivalente |
| 8 | Nota | O `motivo` só explica a `classe`: os motivos da numérica se perdem quando as duas são anômalas por razões diferentes. O `td8` só testa M = 0 | Código próprio: `m_ok` sem `is.finite` (A2) passa nos 12 testes (com M = Inf, anômala sem motivo; inalcançável na prática) | Caso com M não finito; decidir se a numérica ganha motivo próprio |
| 9 | Nota | O `td7` não testa \|MRT − p99\| entre 1e-8 e 1e-2 (lacuna antiga) | Código próprio: a tolerância de `mrt_no_p99` em 1e-2 (A5) passa nos 12 testes | Caso com o p99 a 0,005 do último ponto do seq e a MRT no penúltimo |
| 10 | Nota | Redação e registro: `fmrt_igual` entra em `travas_ok`, e uma falha dele sairia como "alguma trava cai"; o log não grava o SHA-256 do próprio 54; o cabeçalho do 54 diz "3 um por trava removida"; o comentário do d3 no `td5` ainda cita "tolerância de 1e-8"; a função segue "versão 1.0" depois de mudar de comportamento | Leitura do código e do log | Correções de texto junto com as do 4 e do 5. A "versão 1.0" é a da primeira tag desta função |

- **Limite:** os achados acima ficam abertos até a instrução do chat. A tag `diagnostico_grade_mrt-v1.0` vai na versão auditada aqui, com esses achados conhecidos e registrados.
