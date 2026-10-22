# Fase 2, Parte C: dupla auditoria da primeira etapa, 10/10/2026

Registro achado → reprodução → correção, como manda o `CLAUDE.md` do artigo. Só logs, scripts e resultados de modelo agregados por concentração; nenhuma linha individual.

## Etapa 1: autoauditoria (`00_scripts/35_autoauditoria_fase2C.R`)

- **1ª rodada** (log SHA-256 `aff65474e024016d3cf3ae77464d35a8c6fbc209ef2666ba02ff186f8d913860`, na lixeira): 16 de 18. Ficaram "DIFERENTE":
  - o φ, com tolerância relativa de 1e-8 contra uma diferença glm × gnm de 2,1e-8;
  - os nós, o `cen` e os Boundary.knots, com igualdade exata contra uma diferença de 3,55e-15 (1 ULP do `read.csv` com textos de 17 dígitos).
- **2ª rodada** (log `3b119204cb470d0f75351ab9bb8856a79a7ec19d3665c737ee4bfe3d0c6ed36e`, na lixeira): só imprimiu as diferenças, com o mesmo resultado.
- **Tolerâncias:** passaram a 1e-6 (relativa, φ) e 1e-12 (nós, `cen`, Boundary.knots), depois de ver o resultado. Isso está no desvio 66(a).
- **3ª rodada** (log `c7c6c9678df036b7003802f2f7f4737f6c26a7f1ff51537c3d06ac55a8e1e36e`, na lixeira): 18 de 18. Foi substituída pela 4ª depois da auditoria independente (achados 3 e 4).
- **4ª rodada, a que vale** (`logs/autoauditoria_fase2C_20261010.md`): 22 de 22. Passou a conferir também o conteúdo da RDS (spec, base, `cen` e RR no `cen`, nenhum vetor com tamanho de série), o LAPACK e o sinal dos lags sinalizados, e a gravar o `sessionInfo()` completo.

## Auditoria independente

- **Auditor:** subagente em contexto limpo, só de leitura. Leu:
  - os scripts 32 e 35 e o código da tag;
  - os logs do 32, do 35 e da auditoria da Parte B, e os desvios 51 a 65;
  - a §4 da RESPOSTA da Fase 1 e a especificação;
  - o `referencias_exposicao.csv` (exposição, dado público) e os 4 CSVs de resultado de modelo.

  Não abriu nenhum `.rds`, `.parquet` ou `.dbc`, nem a base. Rodou o nulo simulado com dado sintético e conferências sobre os CSVs, com os scripts `aud7_*` no scratchpad da sessão. Não usou a rede.
- **Veredito do auditor:**
  - a Parte C pode ir para a RESPOSTA e o commit local depois de três correções, nenhuma das quais muda estimativa;
  - o código é o da tag e o BLAS é o de referência;
  - as 26 concentrações deram "ok", com dimensões 16 e 16 × 16 e 4 e 4 × 4;
  - nós e `cen` batem com o arquivo de referências;
  - o log bate com os CSVs, e não há problema de sigilo.
- **Achados:** 8
  - 3 marcados como "corrigir antes da RESPOSTA" (1, 3 e 4), 2 como "para o chat" (2 e 5) e 3 como "nota" (6 a 8).
  - Todos foram reproduzidos por código próprio da sessão (`repro_aud7.R`, sobre os CSVs de resultado) ou pela leitura de código e de metadados.
  - As correções estão no desvio 66, registrado antes de rodar de novo o 32 e o 35.

| Nº | Achado (classificação do auditor) | Reprodução | Correção ou destino |
|---|---|---|---|
| 1 | O texto da PACF no log do 32 afirmava que a sensibilidade "entra na Fase 4" e, logo abaixo, que a regra é decisão do chat; também omitia a calibração do nulo (corrigir antes da RESPOSTA) | Os 70 lags sinalizados pela literal são todos negativos; em São Paulo, a literal escolhe o lag 5, e a recentrada, os lags 1, 2, 6 e 7 | O log do 32 foi gerado de novo, com texto condicional ("entraria na Fase 4; a regra que vale é decisão pendente do chat") e o sinal dos lags sinalizados em cada regra. A calibração do nulo (auditoria da Parte B) vai para a RESPOSTA |
| 2 | A escolha da regra da PACF tem evidência que o chat ainda não viu (para o chat) | A recentrada sinaliza 24 lags, 23 acima do centro e 1 abaixo; com Bonferroni, 13, todos acima. A média nas 26 de PACF − centro é positiva em todos os lags (+0,007 a +0,018; EP médio ≈ 0,003). P(≥ 13 de 26) vai de 0,007 a 0,033, e P(≥ 8 de 26) de 6e-7 a 6e-5, conforme a taxa nula (a da sessão, de 0,31 e 0,03, ou a do auditor, de 0,257 a 0,286 e 0,040 a 0,056) | Para o chat, antes de fixar o gatilho da Fase 4 (desvio 66d). Leitura: há autocorrelação residual positiva e pequena numa parte das concentrações, e a regra literal aponta sinal e lags errados |
| 3 | A autoauditoria afrouxou tolerâncias depois de ver o resultado, sem desvio; o log falava em "1ª rodada", e eram duas (corrigir antes da RESPOSTA) | Na lixeira há dois logs anteriores do 35, de 2.951 bytes cada, ambos de 18:03 | Desvio 66(a), com os SHA-256 e as tolerâncias originais. O texto do 35 fala das duas rodadas |
| 4 | Nenhum código conferia o `cen` efetivo nem o conteúdo da RDS (corrigir antes da RESPOSTA) | O 35 não lia a RDS; os nós e o `cen` do log e do CSV eram cópia da entrada | O 35 lê a RDS e confere, nas 26: a spec, os nós e os Boundary.knots da base, a `arglag`, `lag` e `df`, o `cen` e o RR no `cen` da reduzida, e que nenhum vetor tem tamanho de série. Passa em 26 de 26 |
| 5 | Fallback: o caminho em que o `gnm` devolve NULL não está entre os motivos de fallback, e a função `efetivo()` nunca era usada (para o chat) | Leitura: `MOTIVOS_FALLBACK` não inclui "o gnm não devolveu modelo" | Para o chat, com o 65(a) (desvio 66d). A função `efetivo()` saiu do 32. Não afeta a Parte C, porque as 26 deram "ok" |
| 6 | Algumas comparações do 35 são frouxas: escala pelo maior elemento, o LAPACK não era comparado com o log, e `no_texto` só confere presença (nota) | Leitura | O LAPACK passou a ser comparado. O resto fica como nota (desvio 66e); as conferências do auditor sobre os CSVs não acharam nada |
| 7 | Formato dos CSVs para a Fase 3 (nota) | Leitura | Receita de leitura na RESPOSTA: `colClasses` em `recorte_principal`, números com 17 dígitos entre aspas, coeficientes da cross-basis na ordem do dlnm (v1.l1 a v4.l4) |
| 8 | Rastreabilidade: nenhum log grava o SHA do próprio script, e falta o `sessionInfo()` completo (§8) (nota) | Leitura | A RESPOSTA traz o SHA-256 do 32, do 35 e do 36. O 35 grava `logs/sessionInfo_fase2C_20261010.txt` |

### Conferido e aprovado pelo auditor (resumo)

- **Código e ambiente:**
  - a tag `ajusta_dlnm-v1.0` aponta para o `caf5022`;
  - os SHA-256 dos 3 arquivos de `R/` são iguais no `git show`, no disco e no log;
  - o BLAS e o LAPACK são os de referência, sem vecLib ativo;
  - dlnm 2.4.10 e gnm 1.1-5.
- **Especificação:**
  - nós e `cen` iguais aos do arquivo de referências (26 linhas de ano inteiro, 4.749 dias), com a ordem p10 < p50 < p75 < p90;
  - `arglag` com nós 0,982 e 2,622.
- **Linhas e Boundary.knots:**
  - de 2012-04-07 a 2024-08-06, 4.505 dias por concentração, e a janela é exatamente data ≥ 2012-04-14;
  - os Boundary.knots vêm do objeto ajustado e contêm os nós e o p1 e o p99 nas 26.
- **Entradas e dimensões:**
  - as 26 concentrações estão nos 4 CSVs, com 20 linhas reduzidas e 272 da cross-basis por concentração;
  - sem NA, com vcov simétricas e positivas-definidas;
  - a redução refeita a partir da cross-basis reproduz os CSVs reduzidos.
- **Log:**
  - as 3 tabelas são iguais aos CSVs;
  - as regras da PACF, recalculadas, dão as mesmas colunas e as contagens 25, 13 e 8.
- **Escopo e sigilo:**
  - C.1 a C.7 e os desvios 59 e 65 estão implementados;
  - o desvio 65 foi gravado antes da rodada;
  - não há resíduo, valor ajustado, série diária nem contagem de eventos no log ou nos CSVs.

## Regeneração (desvio 66b)

O 32 rodou de novo com as mesmas entradas. As 5 saídas saíram byte a byte iguais às da 1ª rodada, com os mesmos SHA-256; só o log mudou.

| Arquivo | 1ª rodada (na lixeira) | Rodada que vale |
|---|---|---|
| `logs/primeira_etapa_fase2_20261010.md` | `196767d71cd6979dd3c11bc0402fef818787cfe99b4c375d25ad487bd1852932` | `5a49d2ab7bc4f7b6c48b3fe167a36b04c0b953df5ffc28e4cebd7b9a571c66b6` |
| `logs/autoauditoria_fase2C_20261010.md` | `c7c6c9678df036b7003802f2f7f4737f6c26a7f1ff51537c3d06ac55a8e1e36e` (3ª rodada do 35) | `bf6892c0664752c5f0562f2ca48fc95f16c00359e8cc5506bdd888ecd8ff7a16` |
| `01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds` | `5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d` | idêntico |
| `01_saidas/fase2/reduzida_coef_vcov_fase2_20261010.csv` | `50f58701005f9cbaf722f5043844f0e6680be5717b011419b2b3b4b688e58c4d` | idêntico |
| `01_saidas/fase2/crossbasis_coef_vcov_fase2_20261010.csv` | `8eed876c0bc0983705305042324c79ab1f0d619a41a97d8139503b73957e4ddd` | idêntico |
| `01_saidas/fase2/pacf_fase2_20261010.csv` | `5ab465ab5b1059896f596842e52c78aa0978090cafb4ebd2ef8ddbe5a7e7908f` | idêntico |
| `01_saidas/fase2/diagnosticos_fase2_20261010.csv` | `0f28e346a39cc242bd42a225cc2c7090d408298d43277aba37e291b0391c02eb` | idêntico |
