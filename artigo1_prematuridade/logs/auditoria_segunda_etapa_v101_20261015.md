# segunda_etapa v1.0.1 (só de testes) e conferência da D6, 3.4, nos dados do A1: dupla auditoria, 15/10/2026

Registro achado → reprodução → correção, como manda o `CLAUDE.md` do artigo e a seção 4 da mensagem do chat do Artigo 1 de 15/10/2026 (v1.1). A série diária só foi lida e processada dentro da Forja; nenhuma linha, valor diário, data ou coeficiente BLUP por concentração foi impresso ou gravado. Entrada 86.

## Etapa 1: autoauditoria e rodadas

- **Anexos da mensagem:** os 5 conferem com os SHA-256 informados. Ficaram em `logs/conformidade_D6_34/`, dentro da Forja e fora do git, por decisão de Guilherme: a lista branca do `.gitignore` ignora subpastas de `logs/`, e o `checa_sigilo` barra o `.csv`.
- **Testes novos (rodadas sintéticas, antes do 55):** os 4 testes de `testa_segunda_etapa_d6.R` passam. O teste 3 dá diferença 0 contra a `curva()`; os controles dão 3,8e-2 e 1,05e-2 (ns) e 4,2e-2 e 5,2e-3 (bs).
- **Ajustes de código antes da 1ª rodada:**
  - o número de colunas da base passou a sair da fórmula (a `onebasis` com `degree = NULL` daria erro na `ns`);
  - o GLS à mão do `td6_q_por_coeficiente` foi reescrito com a convenção do `qtest` (`X[i, ] ⊗ I_k`).
- **55, 1ª rodada (10:03):**
  - 21/21 testes e 3/3 mutantes;
  - mas o log saiu sem a linha do HEAD: o `git log -1 --format=%h %s` foi passado ao `system2` sem aspas e falhou, e o `sprintf` com `character(0)` sumiu com a linha, em silêncio;
  - correção: `shQuote` e `stopifnot(length(head_s) == 1)`;
  - o log foi para a lixeira (SHA-256 `95f4518ac2c496d019aed4c21a654e21410d3bc093dade6a332d609915bbc9cd`).
  - **Observação:** o 44 tem a mesma linha com o mesmo defeito, e o log dele (`logs/testes_tag_fase3_20261013.md`) também não traz a linha "Commit no disco". Os outros controles do 44 não dependem dela.
- **55, 2ª rodada (10:04, em vigor):** 21/21 testes; 3/3 mutantes; log `logs/testes_v101_20261015.md` (SHA-256 `c638b6470e705a8cb3efee016013fc4b2ffda569af47cead6a58e7112086be4c`). Em seguida vieram o commit `403b0a2` e a tag local `segunda_etapa-v1.0.1`.
- **56 (10:07, depois da tag):**
  - **mesmos números:** a `meta_curva` rodada de novo dá `identical()` com a RDS do 45 nos 21 campos (3 meta-análises × 7);
  - `gl == 4` nos três Wald;
  - Q por coeficiente com 23 gl nos 12;
  - teste 3 nas 26: diferença máxima de 1,3e-15, com o controle p1–p99 acima de 1e-8 em 26 de 26 (mínimo 1,30e-2).
- **Autoauditoria dentro do 56, com código diferente:**
  - Q por coeficiente pelo GLS à mão (vec por unidade): diferença relativa máxima de 8,8e-14 contra o `qtest`, com gl = 23;
  - base `ns` montada com `splines::ns` direto (sem `onebasis` e sem a função do teste 3): diferença máxima de 1,3e-15 contra a `curva()` nas 26.

## Auditoria independente

- **Auditor:** subagente em contexto limpo.
  - Leu a D6, a entrada 86, o relatório de conformidade, a função do teste 3, os testes, o 55, o 56 e os logs dos dois.
  - Leu com R, sem imprimir linhas, as RDS da Fase 2 e do 45 e a série da Fase 1, e a `tmean_nucleo` de 2012–2024 pela interface da base.
  - Não abriu `.parquet` nem `.dbc`, não rodou os scripts 40 a 56 e não escreveu no repositório.
  - Rodou com código próprio (`aud16/*`, no scratchpad).
- **Veredito do auditor:** conforme, com ressalvas, sem achado Crítico nem Maior.
  - Os testes fazem o que a D6 pede (2.2 e 3.2), e a receita do Q por coeficiente é igual à do `mixmeta:::qtest.mixmeta` 1.2.0. Ele rodou a bateria no original: 21/21.
  - Os 3 mutantes do 55 morrem.
  - A tag está íntegra: o diff dos três arquivos de `R/` contra o `410dd6d` sai vazio, e o commit da tag tem 5 arquivos. Os 5 SHA-256 da mensagem da tag e o do log conferem.
  - Ele reproduziu todos os números do log do 56: a `meta_curva` com `identical()` (com os `row.names` do 45), a heterogeneidade, o Q por coeficiente (≤ 2,3e-15) e o teste 3 nas 26 (dif 1,3e-15; controle mínimo 1,30e-2; 2 de 26 com amplitudes diferentes; `dif_nos` 5,0e-14; `dif_fronteiras` 0).
- **Os 5 mutantes do auditor:** sobrevivem 4 (A2, A3, B1 e B2); morre 1 (A1, `.base_x` sem `degree`).
- **Achados:** 7 (2 Menores e 5 Notas), todos aceitos.
  - Reproduzidos por código próprio da sessão (`repro_aud16.R`, no scratchpad): os achados 1, 2, 3 e 4 (os mutantes A2, A3, B1 e B2 não derrubam nenhum dos 4 testes novos; no mutante 1 do 55, o `td6_t3_ns` cai por erro do R e o `td6_t3_bs` pelo critério, com 0,0697).
  - O 5 foi conferido pelo próprio auditor (`x_cb` relido da base, diferença 0); o 6 e o 7, pela leitura do log.
- **Correções pendentes.** As dos achados 1 e 2 mexeriam nos testes depois da tag `segunda_etapa-v1.0.1`: ficam para o chat decidir (por exemplo, uma v1.0.2 só de testes, ou a Parte 0 da Fase 4). As notas não pedem mudança agora.

| Nº | Grav. | Achado | Reprodução | Correção |
|---|---|---|---|---|
| 1 | Menor | Nenhum teste chama a `curva()` com `cen` fora de `x`, o caminho do contraste primário no 45 (`x` = 6 percentis, `cen` = TMR). O mutante A2 (a `curva()` centra no ponto de `x` mais próximo de `cen`) passa nos 21 testes | Código próprio: com o A2, nenhum dos 4 testes novos cai | Pendente: no `td6_t3`, chamar também com `x` = 6 percentis e `cen` fora deles. No 56, o `x` inclui os 6 percentis, e o teste 3 passou nas 26 |
| 2 | Menor | Não há controle com a `argvar` errada: uma regressão que torne a função do teste 3 tautológica (nós ou fronteiras tirados da `argvar`, mutantes B1 e B2) passa 21/21 e ainda mata os 3 mutantes do 55 | Código próprio: com B1 e com B2, nenhum dos 4 testes novos cai | Pendente: exigir dif > 1e-8 com `argvar` errada (nós de `quantile(x_cb)`; fronteiras p1–p99). O auditor mostrou o poder nos dados: diferença mínima de 8,72e-5 nas 26 com nós de `quantile(x_cb)` |
| 3 | Nota | Três das quatro mortes do mutante 1 do 55 são por erro do R (base degenerada num `cen` escalar sem `Boundary.knots`), e o log do 55 não distingue erro de critério | Código próprio: o `td6_t3_ns` cai com "NA/NaN/Inf em chamada de função externa"; o `td6_t3_bs`, pelo critério (0,0697). A variante do auditor sem erro cai pelo critério nos 4 testes (3,8e-2 a 6,5e-2) | Nenhuma: o poder do teste existe. Registrar erro × critério nos próximos logs de mutantes |
| 4 | Nota | Uma regex gulosa no Wald (mutante A3) sobrevive; ela só quebra com metapreditor de nome pontuado. A forma quadrática à mão do `td6_wald_selecao_exata` usa a mesma regex do código | Código próprio: com o A3, nenhum teste novo cai | Nenhuma agora: a guarda `gl == ncol(Y)` do chamador pegaria (gl = 0) |
| 5 | Nota | No 56, o `x_cb` vem da série da Fase 1 (a mesma entrada da cross-basis), não relido da base; a D6 exige releitura só para a `serie_nos` | Conferido pelo auditor: `x_cb` relido da base, diferença 0, e Boundary.knots = `range(x_cb)` exato | Nenhuma no A1; sugestão de reler no A2 e na Fase 4 |
| 6 | Nota | O log do 56 traz I² por coeficiente; a D6, 3.2, pede só o Q por coeficiente, e um I² sobre um Q "não univariado" se interpreta mal | Leitura do log do 56 | Pendente de decisão do chat: retirar o I² por coeficiente do relato |
| 7 | Nota | Formatação do log do 56: notação científica com ponto e números com vírgula; um p com 2 algarismos ("0,64") | Leitura | Cosmético; como nos logs anteriores |

- **Escopo conferido pelo auditor:**
  - o `segunda_etapa.R` tem o mesmo SHA-256 (`1fb4543a…`) no `410dd6d`, na tag e no disco;
  - nenhum commit tocou `spec/`;
  - o log do 56 só tem agregados.
  - O HEAD andou para `a942c99`, commit do A2 só em `artigo2_obito_perinatal/logs/`.
