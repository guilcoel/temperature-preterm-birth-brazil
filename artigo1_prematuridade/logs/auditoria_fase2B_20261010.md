# Fase 2, Parte B: auditoria final antes da tag `ajusta_dlnm-v1.0`, 10/10/2026

Registro achado → reprodução → correção, como manda o `CLAUDE.md` do artigo. Só dado sintético e logs agregados; nenhuma linha da base.

## Auditoria independente

- **Auditor:** subagente em contexto limpo, só de leitura no repositório. Leu:
  - o código e os testes de `codigo_compartilhado/` no `caf5022`;
  - o script 37 e o log dele;
  - a mensagem de tag proposta;
  - a transcrição do prompt da Fase 2 (Partes B e C);
  - as duas auditorias anteriores;
  - os trechos da especificação sobre o modelo agudo.

  Rodou só dado sintético, com os scripts `aud6_*` no scratchpad da sessão, fora do repositório.
- **Desvio do auditor, declarado por ele:** rodou uma vez `git ls-remote --tags origin`. O comando é só de leitura, mas acessa a rede, o que o prompt dele proibia. Nada foi escrito.
- **Veredito do auditor:**
  - o código está pronto para a tag: o conteúdo de `codigo_compartilhado/R/` no `caf5022` é byte a byte o testado no 31 e retestado no 37, com SHA-256 igual entre os blobs do git, o disco, os logs e a mensagem;
  - as baterias, refeitas por ele, deram 19/20 e 21/21;
  - nada na Parte C nem na Fase 3 exige mudar a função;
  - faltava o processo: desvio 64, commit do 37 e decisão de Guilherme sobre o n/n.
- **Achados:** 10
  - 1 marcado como "bloqueia a tag", 2 como "corrigir antes da Parte C" e 7 como "nota".
  - Os achados 2 e 4 foram reproduzidos por código próprio da sessão (`repro_aud6.R`, dado sintético); os demais, por leitura de código, log e `git`.
  - A decisão de Guilherme sobre o 5b ("caminho A", 10/10) e as correções estão no desvio 64, registrado antes da tag.

| Nº | Achado (classificação do auditor) | Reprodução | Correção ou destino |
|---|---|---|---|
| 1 | A mensagem da tag citava o desvio 64, que não existia, e o 37 e o log dele estavam sem commit (bloqueia a tag) | O log de desvios terminava no 63; `git status` mostrava os dois arquivos não rastreados | Desvio 64 registrado e commit local do 37, do log, dos desvios e desta auditoria antes da tag. A tag vai no hash completo do `caf5022`, nunca no HEAD |
| 2 | A regra da PACF da §2.1 dispara sempre num modelo correto; a decisão é do chat e a implementação cabe em quem chama (corrigir antes da Parte C) | 100 réplicas sem efeito, de 4.500 dias. A regra literal (±2/√n) sinaliza 100. Recentrada em −1/(m − 1), com m = dias usados / estratos usados ≈ 30,2, sinaliza 31. Recentrada e com Bonferroni nos 7 lags, sinaliza 3. O auditor obteve 100, 25 e 5; a diferença vem de detalhes da simulação. Com ruído branco perfeito, a multiplicidade da regra já dá 1 − 0,9545^7 = 0,278 | Para o chat, antes da Parte C. O 32 grava o `fora` literal e uma coluna com a regra escolhida, e a escolha vira desvio. A função não muda |
| 3 | A Fase 4 vai exigir uma v1.1: a família é fixa e os resíduos não saem da função (nota) | Leitura do código: `family = stats::quasipoisson` e nenhum resíduo na saída (A1.7) | Escopo da v1.0 declarado no desvio 64. Binomial negativa, resíduos defasados, S3 e a análise em uma etapa ficam para a v1.1, com tag e desvio antes da Fase 4 |
| 4 | γ aliasado sai com status "ok", γ = NA e EP = 0; é inalcançável no principal (nota) | Com uma covariável idêntica a `log_w`: status "ok", γ NA, EP 0, e o aviso "coeficiente aliasado fora da cross-basis: log_w" | No 32, com `z_w_gama`, γ = NA vira falha. Na v1.1, EP = NA quando γ for NA |
| 5 | Erro em φ, QAIC ou PACF também dá "falhou", mas o fallback do §5, critério 4, só cobre convergência e vcov (corrigir antes da Parte C) | Leitura do código | No 32, o fallback só entra para falha de convergência, aliasamento na cross-basis ou vcov; qualquer outra falha para e informa. Critério explícito de BLAS. SHA-256 lidos do `git show` da tag |
| 6 | O 37 compara só parte dos números, e "idênticos" era forte demais (nota) | Leitura: o 37 compara o resultado de cada teste, três coberturas e o viés do `nenhum`. Na reprodução do auditor, os demais números (viés do 5 e do 5b, γ̂, diferença do t07) batem com o log do 31 | O texto passou a dizer "mesmo resultado por teste e mesmas coberturas". O 37 confere que o HEAD é o `caf5022` e que `codigo_compartilhado/` é igual a ele, e rodou de novo |
| 7 | A mensagem da tag tinha hash curto, caminho do 37 sem o prefixo do artigo e nenhum SHA dos testes (nota) | Leitura | A mensagem traz o hash completo, o caminho completo, os SHA-256 dos 5 arquivos de testes e os números das 1.000 réplicas |
| 8 | A versão final de `R/` não tinha passado por auditor independente: o desvio 63 mexeu nela depois da re-auditoria (nota) | O `ajusta_dlnm.R` foi gravado às 12:30, depois dos scripts do re-auditor (desde 12:17). O auditor leu o arquivo inteiro e julgou certas as mudanças do 63(a) | Registrado no desvio 64: esta auditoria revisou a versão que recebe a tag |
| 9 | O `DESCRIPTION` de `codigo_compartilhado/` está desatualizado (nota) | `Version: 0.0.0.9000`; `Imports: stats` | Fica fora de `R/`, então não afeta a tag; vai num commit posterior |
| 10 | Pequenas inconsistências na RESPOSTA da Parte A e nos desvios (nota) | No log do 31, a PACF média vai de −0,032 a −0,037, e a RESPOSTA diz "~−0,036 em todos os lags". O `ded4fbd` já está no `origin/main`, ao contrário do que diz o desvio 60. O t09a pega "`z_w_gama` com offset `log_zw`" só por ruído numérico (4,1e-10 > 1e-10) | Corrigido no registro (desvio 64), sem editar a RESPOSTA já commitada |

### Respostas do auditor às perguntas do prompt (resumo)

- **Conteúdo de `R/`:** SHA-256 por `git show caf5022`:
  - `ajusta_dlnm.R`: `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009`;
  - `offset.R`: `55111b2cc510d7b1c7b78b7f84e99997c5202825e0353da70bab0b4bea290bae`;
  - `.gitkeep` (vazio): `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.

  Os três são iguais aos do disco, aos dos logs e aos da mensagem.
- **Parte C:** nada exige mudar `R/`.
  - As saídas da C.5 e da C.6 existem todas.
  - A cross-basis reconstruída a partir dos atributos devolvidos é idêntica à original, e é o que a Fase 3 usa para MRT, `type = "var"` e `attrdl`.
  - Os Boundary.knots podem ser fixados pela `argvar`, sem mudar código.
- **5b, opções:**

  | Opção | Avaliação do auditor |
  |---|---|
  | Tag com 19/20 e desvio | A de maior rigor: nenhum critério muda depois do resultado |
  | Mudar o critério | Post hoc. Até "IC de Wilson contém 0,95" falharia com 200 réplicas, porque o IC é [0,957; 0,995] |
  | Oficializar as 1.000 réplicas | Parada opcional depois de ver o resultado |
  | IC diferente | Pior: o IC já é largo demais |
  | Trocar a semente | Vedado |

  Com três janelas de 0,92 a 0,98 e cobertura verdadeira de 0,95, a chance de pelo menos uma falhar por acaso é de 9,5%.
- **Push:** o risco é real.
  - Alguma sessão já fez push do `main` levando commits de outras, e qualquer push de outra sessão levaria o `caf5022`.
  - O que reduz o risco: tag logo e pelo hash completo, e recusar os pushes de outras sessões enquanto o `caf5022` estiver à frente sem tag.
  - `push.followTags` não está configurado, então o push de outra sessão não leva a tag.

## Regeneração do log do 37

| Rodada | SHA-256 | Destino | Motivo |
|---|---|---|---|
| 1ª | `7a6e44761b3954b2bdcc4173bb0781a7878d62d5cb4f4ae78016439501591af4` | `/Volumes/Forja/.Trashes/501/` | Linha do commit quebrada (formato do `git log` sem aspas) |
| 2ª | `0aafa06f8e17c7c5dac793957f0d083c684184eeefa082e3d3ecd7dbc27d82bf` | `/Volumes/Forja/.Trashes/501/` | "Idênticos" forte demais e sem a trava de HEAD (achado 6) |
| 3ª (a que vale) | `7c3f87b23b6af2d6784793b3f05e38ccce16dc54398bdf0ae8efe60260a43324` | `logs/testes_tag_fase2B_20261010.md` | — |
