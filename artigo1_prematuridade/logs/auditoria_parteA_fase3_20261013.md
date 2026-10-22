# Fase 3, Parte A: dupla auditoria (A3), 13/10/2026

Registro achado → reprodução → correção, como manda o `CLAUDE.md` do artigo. Só dado sintético, logs agregados e, como atributos, as bases da primeira etapa, a exposição, os percentis, os metapreditores e as vcov reduzidas da Fase 2 (desvio 72d). Nenhuma linha da base, nenhum coeficiente real numa curva e nenhuma saída diária.

## Etapa 1: autoauditoria (`00_scripts/42_autoauditoria_fase3A.R`)

- **Tentativa que não gravou log:** o 42 parou ao chamar `cidade_nucleo()`. Um auxiliar local chamado `ler` mascarava o `ler` do `acesso.R`. O auxiliar passou a se chamar `le_txt`, e a regra de não reutilizar nomes do `acesso.R` ficou registrada.
- **1ª rodada** (log de 13:11, SHA-256 `915f26cd1d99698e5bf69c9ca733000e4feb3b64263bc37a0e6b79773f6ec644`, hoje na lixeira): 38 de 38 conferências iguais, contra o log da 1ª rodada do 41 (SHA-256 `df452fc9dcb1d62e8fb4a4fd7f675202fc685e6fd0fb41be0d9a286a8a9b79da`, hoje na lixeira).
- **2ª rodada** (depois das correções do desvio 74; log de 14:03, SHA-256 `fa1736af35c7919aa668e109cf487086ada6fbf82c355a26d485082121f057bd`, hoje na lixeira): 57 de 57 conferências iguais. O 42 passou a conferir também:
  - o EQM da predição na média dos metapreditores, recalculado com o `mixmeta` chamado direto;
  - os 39 defeitos, com a lista lida do próprio 41 e a regra nova do teste 5 (só roda numa cópia quando nenhum teste rápido cai).
- **3ª rodada** (depois das correções do desvio 75; log de 14:35, `logs/autoauditoria_parteA_fase3_20261013.md`): 70 de 70 conferências iguais. O 42 passou a gravar os SHA-256 dos arquivos auditados (a trava do 43 os procura) e a conferir a regra do teste 5 nos dois sentidos, nos 52 defeitos.

## Auditoria independente

- **Auditor:** subagente em contexto limpo. Leu só:
  - os scripts 40 a 43;
  - o código e os testes de `codigo_compartilhado/` (inclusive a `ajusta_dlnm.R` contra a tag `ajusta_dlnm-v1.0`);
  - os logs agregados do 40 e da 1ª rodada do 41;
  - o prompt da Fase 3, o complemento de 13/10, os desvios 71 a 73 e os documentos normativos.

  Não abriu `.parquet`, `.dbc` nem `.rds`, nem arquivo da base fora de `09_acesso/`, e não leu o log do 42. Rodou só dado sintético, com os scripts `aud9_*` no scratchpad da sessão, fora do repositório.
- **Veredito do auditor:**
  - o `segunda_etapa.R` da 1ª rodada (SHA-256 `aa1c3b61…`) está correto em tudo o que ele conferiu com código próprio e dado sintético;
  - a A0 bate com o CSV de referência, e a `ajusta_dlnm.R` não mudou desde a tag;
  - o furo está na bateria de testes: os 21 defeitos plantados caem por mecanismo legítimo, mas ele plantou mais 15, em pontos que a A3 manda procurar, e nenhum derrubou os testes rápidos;
  - o critério de EQM do teste 5 não é o do prompt e não estava registrado em desvio;
  - recomendou não criar a tag antes de registrar o critério do teste 5 e completar os testes dos achados 2 a 7.
- **Achados:** 15
  - 7 marcados como "corrigir antes da tag" (1 a 7), 2 como "corrigir antes da Parte C" (8 e 9), 1 como "nota ou antes da Parte C" (10) e 5 como "nota" (11 a 15).
  - Todos foram aceitos. Os defeitos dos achados 2 a 12 foram reproduzidos por código próprio da sessão (`repro_aud9.R`, no scratchpad): cada um numa cópia do `segunda_etapa.R` da 1ª rodada, com a bateria rápida inteira. O achado 1 foi reproduzido com 200 réplicas do desenho do teste 5. Os achados 13 a 15 foram conferidos pela leitura do código e do CSV.
  - As correções estão no desvio 74, registrado antes da 2ª rodada.

| Nº | Achado (classificação do auditor) | Reprodução | Correção |
|---|---|---|---|
| 1 | O teste 5 compara o EQM do BLUP com o da parte fixa X_iβ̂ de cada unidade, e o prompt (A2.5) fala em "predição da média"; a troca não estava em desvio. Na réplica do auditor, o EQM da predição na média (0,0915) fica abaixo do BLUP (0,1006), e o critério literal cairia (corrigir antes da tag) | 200 réplicas do desenho do teste 5, com as S_i reais e os mesmos β e Ψ: EQM do BLUP 0,09464; primeira etapa 0,3366; parte fixa 0,1053; predição na média 0,09285. Com inclinações verdadeiras nulas, a predição na média funciona como comparador "oráculo" | O critério implementado fica (BLUP < primeira etapa e BLUP < parte fixa). O EQM da predição na média passa a ser calculado e reportado ao lado, sem critério, no 41 e no 42. A escolha do comparador é do chat do Artigo 1 (desvio 74(a)) |
| 2 | O frio extremo não tem teste, e o 8(b) é circular: o cálculo à mão usa o próprio `componentes_attrdl` (corrigir antes da tag) | "Frio extremo sem o `min(p2,5, TMR)`" e "frio extremo = frio": 0 testes rápidos caem em cada cópia | O t08 escreve os `range` literais da D4(h). Caso novo 8(i), simétrico ao 8(h), com TMR < p2,5: o frio extremo tem de ser igual ao frio. Os dois defeitos entram no 41 |
| 3 | Q/I² (residual e total) e Wald por termo sem teste (corrigir antes da tag) | "Residual × total trocados" e "Wald do termo errado": 0 testes rápidos caem em cada cópia | Teste novo t07c: Q e I² por GLS à mão, residuais e totais, e o Wald de cada termo como forma quadrática. Os dois defeitos entram no 41 |
| 4 | A semente do bootstrap por concentração não tem teste: com `semeia(0)` em todas, t06 e t12 passam, porque só conferem reprodutibilidade com o mesmo i (corrigir antes da tag) | "Bootstrap com `semeia(0)` em todas": 0 testes rápidos caem | Teste novo t06c: `boot_tmr(i = 5)` igual ao sorteio à mão com a semente 20261006, e i = 6 dá sorteios diferentes. O defeito entra no 41 |
| 5 | A predição na média dos metapreditores não é detectável: com inclinações verdadeiras nulas, prever no 1º metapreditor passa no teste 5 (corrigir antes da tag) | "Predição no 1º metapreditor": 0 testes rápidos caem | O t07c confere a predição contra x̄B̂ e a vcov correspondente. O defeito entra no 41 |
| 6 | A vcov do BLUP não tem teste, e o teste 5 não a usa; ela alimenta a `attrdl` principal e o bootstrap por concentração (corrigir antes da tag) | "vcov do BLUP = vcov da predição": 0 testes rápidos caem | O t07c compara BLUP e vcov com o `mixmeta::blup(vcov = TRUE)` chamado direto. O defeito entra no 41 |
| 7 | Os percentis dos IC (TMR e eCI da `attrdl`) e o z do IC da curva não têm teste (corrigir antes da tag) | "IC da TMR pelos percentis 5 e 95" e "z da curva com `qnorm(0,95)`": 0 testes rápidos caem em cada cópia. O eCI da `attrdl` foi conferido pela leitura (mesmo padrão) | O t06 confere o IC contra os quantis 2,5 e 97,5 dos sorteios; o t08, o eCI contra os quantis das simulações; o t03, `rr_li`/`rr_ls` contra `RRlow`/`RRhigh` do `crossreduce`. Os três defeitos entram no 41 |
| 8 | `posicao_no_eixo` e `soma_lags` nunca são chamadas nos testes; as duas alimentam a C4 (corrigir antes da Parte C) | "`xout = valor + 1`" e "`lags = 1:7`": 0 testes rápidos caem em cada cópia | O t10 compara a `soma_lags` com o `crossreduce(type = "overall")` no mesmo valor e centro e testa a `posicao_no_eixo`. Os dois defeitos entram no 41 |
| 9 | A ponte não tem teste, e a `fracao_atribuivel` não amarra a análise aos coeficientes nem confere o `n_aquec` contra o lag da cross-basis (corrigir antes da Parte C) | "Ponte vira *backward*": 0 testes rápidos caem. A aceitação de 16 coeficientes no *forward* e de qualquer `n_aquec` foi conferida pela leitura: o código da 1ª rodada não tinha essas checagens | Código: a `fracao_atribuivel` devolve status de erro no *backward* sem todos os coeficientes da cross-basis, no *forward* com o número de coeficientes da cross-basis e com `n_aquec` diferente do lag máximo. O t08 testa as três recusas e a ponte igual ao principal com os mesmos coeficientes. Três defeitos entram no 41 |
| 10 | O i chega como número solto: `semente()` não valida o i, e o `as.integer` trunca (nota, ou antes da Parte C) | `semente(26.7)` = 20261027 e `semente(27)` = 20261028, sem erro | Código: `semente(i)` recusa i fora de 0 a 26 ou não inteiro. O t11 testa 27, 2,5 e −1. O defeito "semente sem validar o i" entra no 41. A sugestão de receber o código da concentração não foi adotada: o i já sai de `indice_concentracao()` em quem chama |
| 11 | A busca entre p10 e p90 só é testada com curva monótona (nota) | "Busca entre p10 e p50": 0 testes rápidos caem | O t06 ganha uma cúbica com o mínimo da busca entre o p50 e o p90. O defeito entra no 41 |
| 12 | A conferência do SHA-256 da `attrdl` não tem teste (nota) | "Sem conferência do SHA": 0 testes rápidos caem | O t11 testa que um SHA-256 errado dá erro na `carrega_attrdl`. O defeito entra no 41 |
| 13 | Desenho do teste 5: a cobertura da TMR usa i = 0 em todas as réplicas; β e Ψ "declarados antes" existem só no código, que não estava commitado, e o log é gravado depois da rodada (nota) | Confirmado pela leitura do `testa_segunda_etapa_mc.R` | Sem mudança no desenho (a cobertura da TMR é só reportada). β e Ψ não mudaram; os SHA-256 do código e dos testes ficaram no desvio 74 antes da 2ª rodada, e o commit sai com a Parte A |
| 14 | A coluna `percentil` do CSV da A0 tem ruído de ponto flutuante (por exemplo, 7.0000000000000009) (nota) | Confirmado no CSV | Sem mudança. A Parte C casa sempre por `rotulo`, como o 41 já faz |
| 15 | A nula da PACF (C1, item 4) não está nesta versão (nota) | Confirmado pela leitura: a `semeia()` existe, e a nula é da v1.1 da `ajusta_dlnm` | Sem mudança. A v1.1 terá de usar a `semeia()`, como prevê o desvio 73 |

### Conferido e aprovado pelo auditor (resumo)

- `ajusta_dlnm.R`: `git diff ajusta_dlnm-v1.0` vazio; SHA-256 `563dd82b…`, igual ao da tag e ao do log.
- A0: só as colunas de exposição; diferença máxima de 4,97e-14 contra o `referencias_exposicao.csv`; eixo médio igual à média das 26 e estritamente crescente; a média dos p10/p75/p90 é igual aos nós da base combinada.
- Base combinada (D2): nós e fronteiras pela média, com a base sempre por `do.call(onebasis, c(list(x), argvar))` e as fronteiras explícitas.
- `meta_curva`: sequência reml/unstr → reml/diag → ml/diag; falha = `isFALSE(converged)` ou erro; checagem de coeficientes nulos; nomes dos coeficientes bem tratados no Wald e no 42.
- Grade da TMR igual à C3(i); fronteira pelo índice.
- Sementes C1: `kind` explícito; simulações da `attrdl` idênticas à chamada direta com 20261001 + i; curva combinada com i = 0.
- `range` da D4(h) corretos no código; denominador = eventos da janela; `forw`/`back` mapeados certo; datas consecutivas exigidas na `attrdl` e na cross-basis; NA exigido no aquecimento do *backward*.
- Lag–resposta: `crossreduce(type = "var", model.link = "log")`; centro no p50 quando a TMR está na fronteira.
- Sem curva com coeficientes reais e sem saída diária; as S_i reais só como covariâncias.
- Números do Monte Carlo da 1ª rodada coerentes entre si (EP 0,0070; Wilson [0,934; 0,961]; viés relativo −0,92%).
- Desvios 71 a 73 commitados (`026306e`) antes da A0 e dos testes.

## Re-auditoria independente das correções

- **Re-auditor:** outro subagente em contexto limpo. Leu só:
  - o código e os testes corrigidos, a `attrdl` de terceiros (interface), os scripts 41 a 43;
  - as linhas 71 a 74 do log de desvios, o prompt da Fase 3, o complemento de 13/10, o log do 40 e o rascunho deste registro com a tabela dos 15 achados.

  Não abriu `.parquet`, `.dbc`, `.rds` nem `.csv` de `01_saidas/`, não leu os logs do 41 e do 42 e não rodou os scripts 40 a 43. Montou entradas sintéticas equivalentes e rodou só com elas, com os scripts `reaud10/*` no scratchpad, fora do repositório.
- **Veredito do re-auditor:**
  - as correções dos achados 1 a 12 estão no código e nos testes, e cada uma resolve o seu achado;
  - as mudanças de código não alteram nenhuma estimativa em chamada válida e não quebram os três usos da Parte C (principal com BLUP de 4 coeficientes, ponte com os 4 reduzidos, *backward* com os 16);
  - dois problemas pedem ação antes da tag: a trava de SHA do 43, que nunca passaria com o 42 de então, e a bateria, que ainda deixava passar defeitos em pontos que a A3 manda procurar (semente exata da `attrdl`, simulações do *backward*, grade do bootstrap da TMR).
- **Achados:** 13
  - 4 marcados como "corrigir antes da tag" (1 a 4), 2 como "corrigir antes da Parte C" (5 e 6) e 7 como "nota" (7 a 13).
  - Todos foram aceitos. O achado 1 foi reproduzido pela leitura dos logs da 2ª rodada: o do 42 não tinha nenhuma linha de SHA-256, e o do 41 tinha. Os defeitos dos achados 2 a 8 foram reproduzidos por código próprio da sessão (`repro_reaud10.R`, no scratchpad), cada um numa cópia do `segunda_etapa.R`, com a bateria rápida inteira e as **entradas reais** da bateria (bases da Fase 2, exposição, percentis e vcov como covariâncias), e não as sintéticas do re-auditor: os mesmos 13 dos 28 defeitos dele não derrubavam nenhum teste rápido. O veredito do re-auditor diz 12 sobreviventes, mas a lista dele traz 13 (N01 a N10, N14, N15 e N27); valem os 13. Os achados 9 a 13 foram conferidos pela leitura do código e dos scripts.
  - As correções estão no desvio 75, registrado antes da 3ª rodada. Depois delas, os 28 defeitos do re-auditor caem nos testes rápidos (`repro_reaud10_depois.txt`).

| Nº | Achado (classificação do re-auditor) | Reprodução | Correção |
|---|---|---|---|
| 1 | O 43 procura os SHA-256 do código e dos testes no log do 42, que não os gravava; o 43 pararia sempre (corrigir antes da tag) | Log da 2ª rodada do 42: 0 linhas no formato `arquivo`: `sha`; log da 2ª rodada do 41: 1 por arquivo | O 42 grava "Arquivos auditados (SHA-256)" no formato do 41. Na 3ª rodada, o log do 42 tem as 6 linhas |
| 2 | A semente da `attrdl` não é testada no valor exato (C1: 20261001 + i); o 8(f) só confere a independência entre concentrações (corrigir antes da tag) | N01 (`semeia(i − 1)` antes das duas chamadas da `attrdl`): 0 testes rápidos caem | t08(j): simulações com i = 5 iguais às da `attrdl` direta depois de `set.seed(20261006, kind = …)`. Defeito novo no 41 |
| 3 | As simulações do *backward* nunca são testadas (corrigir antes da tag) | N02 (simulações sempre com `dir = "forw"`): 0 testes rápidos caem | O t08(j) faz a mesma conferência no *backward*, com os 16 coeficientes, mais o AN pontual contra a `attrdl` direta e a exigência de simulações diferentes das do *forward*. Defeito novo no 41 |
| 4 | O bootstrap da TMR não fica amarrado à grade da estimativa: os testes só usavam `x_sup` múltiplo de 0,1, e o t06c montava a grade com a própria `grade_tmr` (corrigir antes da tag) | N03 (sorteios numa grade `seq` sem o `x_sup`): 0 testes rápidos caem | t06c: caso com a TMR na fronteira e `x_sup` = 34,97, grade montada à mão, sorteios idênticos e IC contendo a estimativa; a grade do caso anterior também passa a ser montada à mão. Defeito novo no 41 |
| 5 | A lag–resposta sai sem teste de EP e IC, e os lags padrão da `curva_lag` não são testados (corrigir antes da Parte C) | N04 (EP sem covariâncias), N05 e N06 (`qnorm(0,95)` na `curva_lag` e na `soma_lags`) e N09 (lags padrão de 1 em 1): 0 testes rápidos caem em cada cópia | t10: EP e IC da `curva_lag` contra o `crossreduce(type = "var")`, IC da `soma_lags` contra o `crossreduce(type = "overall")` e os 71 lags de 0,1 em 0,1. Quatro defeitos novos no 41 |
| 6 | A recusa de NA nos cases do *forward* não é testada (corrigir antes da Parte C) | N07 (sem a recusa): 0 testes rápidos caem | t08(a) com NA num dia da janela: status de erro com a mensagem. Defeito novo no 41 |
| 7 | A Ψ só é conferida pelo teste 5 (nota) | N10 (Ψ do modelo só com intercepto): 0 testes rápidos caem; o re-auditor viu o teste 5 derrubá-lo pela fórmula do BLUP | t07c confere a Ψ contra a do `mixmeta` direto. Defeito novo no 41 |
| 8 | Outros sobreviventes, de baixo impacto: campo `p50` da `busca_tmr`, `indice_concentracao` sem recusar código fora da ordem, `rule = 2` na `posicao_no_eixo`, limites do IC da AF trocados (nota) | N08, N14, N15 e N27: 0 testes rápidos caem em cada cópia | t06 confere o `p50`; t11, a recusa de código fora da ordem; t10, NA fora do eixo; t08(b), AF e IC da AF contra AN/denominador. Quatro defeitos novos no 41 |
| 9 | O 43 decide a frase sobre a leitura literal com números de 4 algarismos e não trata o empate (nota) | Leitura do 43: com os dois EQM impressos iguais, a frase diria "também passaria" | O 43 trata o empate à parte ("empatam na precisão do log") |
| 10 | Fidelidade do desvio 74: faltavam as mudanças do 42 e do 43 e os SHA deles; "só recusam chamadas erradas" não vale para o `dimnames(Y) <- NULL`; a troca de mecanismo do 8(a) não estava explícita; o cabeçalho do `segunda_etapa.R` estava desatualizado; "β e Ψ não mudam" não era verificável (nota) | Confirmado pela leitura do desvio 74 e do cabeçalho | Errata do 74 no desvio 75(e). Cabeçalho atualizado (desvios 68 a 75, recusas e `n_aquec`), sem mudar o corpo das funções. β e Ψ: a seção "Teste 5: parâmetros declarados" do log da 1ª rodada do 41 (SHA-256 `df452fc9…`, na lixeira) é idêntica à da 2ª rodada, e o Monte Carlo também, salvo a linha nova do EQM e a duração |
| 11 | Testes que podem passar no vazio: duas recusas do t08(a) sem conferir a mensagem; o teste do SHA no t11 só rodava com `attrdl_path` (nota) | Confirmado pela leitura | O t08(a) confere a mensagem das três recusas; o t11 exige o `attrdl_path` |
| 12 | O 42 aceitava uma lista "rápido + teste 5", que é a regra antiga (nota) | Confirmado pela leitura da conferência do 42 | O 42 exige a lista só com os rápidos, quando algum cai, ou só com o teste 5, quando nenhum cai |
| 13 | Informação para o chat: na montagem sintética do re-auditor, o EQM da predição na média (0,02393) também fica abaixo do BLUP (0,02535), a terceira montagem em que isso acontece. Detalhes: o rótulo "parte fixa (predição da média pelos metapreditores)" é ambíguo, e a contagem 13 + 8 + 18 do 41 e do 43 era digitada à mão (nota) | Os números são do re-auditor, com entradas sintéticas; não foram refeitos aqui. O rótulo e a contagem foram confirmados pela leitura | Rótulo novo: "parte fixa X_iβ̂ (predição de cada unidade pelos seus metapreditores)". O 41 confere a contagem de cada grupo pelo primeiro defeito dele, e o 43 lê as contagens do log do 41 e confere a soma. O comparador segue com o chat (desvio 74(a)) |

### Conferido e aprovado pelo re-auditor (resumo)

- As correções dos achados 1 a 12 da auditoria independente existem e funcionam; t03 e t10 conferem contra o `crossreduce`, o t07c refaz Q/I² por GLS e o BLUP pelo `mixmeta::blup` direto, e o t11 testa a semente e o SHA diretamente.
- `semente(0:26)` dá os mesmos valores de antes, e NA, vetor, texto, lógico e valores não inteiros são recusados.
- Com ou sem `dimnames`, coeficientes, vcov, predição, BLUPs e Wald saem idênticos.
- Os três usos da Parte C dão status ok, e, sem as três recusas novas, os resultados seriam idênticos.
- O 42 aceita corretamente a lista do 41 nos dois casos da regra nova, e as regex do 43 casam o número certo no texto montado com o template real do 41.
- Nenhum teste usa coeficiente real nem gera saída diária.

## Limite

As correções do desvio 75 não passaram por uma terceira auditoria independente. Foram conferidas pela sessão: os 28 defeitos do re-auditor caem, os 52 defeitos do 41 caem na 3ª rodada, e a autoauditoria deu 70 de 70.

## Regeneração dos logs

Todos os logs foram regenerados depois das correções; os antigos estão na lixeira do volume, com o SHA-256 anotado.

| Log | 1ª rodada (lixeira) | 2ª rodada, depois do desvio 74 (lixeira) | 3ª rodada, depois do desvio 75 (em vigor) |
|---|---|---|---|
| `logs/testes_segunda_etapa_fase3_20261013.md` (41) | `df452fc9dcb1d62e8fb4a4fd7f675202fc685e6fd0fb41be0d9a286a8a9b79da`: 16/16; 21 defeitos | `ef26a6c60cdef5d74674b76d80858d0051fe054865503f159e481d99dbf76f0a`: 18/18; 39 defeitos | 14:32; 18/18; 52 defeitos |
| `logs/autoauditoria_parteA_fase3_20261013.md` (42) | `915f26cd1d99698e5bf69c9ca733000e4feb3b64263bc37a0e6b79773f6ec644`: 38 de 38 | `fa1736af35c7919aa668e109cf487086ada6fbf82c355a26d485082121f057bd`: 57 de 57 | 14:35; 70 de 70 |

- O log do 40 (`logs/percentis_exposicao_fase3_20261013.md`) e a grade da A0 não mudaram.
- Os números do Monte Carlo do teste 5 são idênticos nas três rodadas, porque os sorteios e a função de ajuste não mudaram: cobertura 0,949, viés relativo −0,92% e EQM do BLUP 9,526e-02. O EQM da predição na média (9,183e-02) só existe a partir da 2ª rodada.
