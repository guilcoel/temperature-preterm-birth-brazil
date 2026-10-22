# Fase 4, Parte C1: dupla auditoria (as seis sensibilidades-chave e o critério de concordância), 19/10/2026

- **Mensagem:** "Artigo 1, Fase 4, Parte C1: as seis sensibilidades-chave e o critério de concordância (scripts 70 e 71) — v1.0", do chat do A1, por Guilherme, 18/10/2026 (cópia literal em `logs/mensagem_chat_A1_fase4_parteC1_20261018.md`, SHA-256 do texto colado `6031adc6…7491`). A C1 abriu pelo [ok] de Guilherme de 19/10, às 05:59 (A1-104), com o IDHM pendente.
- **Cabeçalho (protocolo v1.1, 3.8):** scripts 69, 70 e 71 commitados em `be79989`; 70 corrigido em `5f75566` (19/10, 06:01:34); logs do 70 e do 71 em `90e6fe6`; último commit da `COORD` no `HEAD`: `a925d35`. Esta seção foi escrita em 19/10, 06:18 −03:00.

## Rodadas do 70

- **1ª rodada (`RODADA=20261019`, sobre `be79989`):** parou no portão 1, sem rodar nenhum modelo de chave. As 5 tags estavam no remoto, nos commits certos, mas o script não leu a tabela de tags da passagem da Parte A, que está indentada dentro de um item de lista; a regex exigia a linha começando por "|".
  - O log dessa rodada, `logs/c1_chaves_fase4_20261019.md`, não foi commitado e foi para a lixeira. SHA-256: `18f6e85287853afbac7b06bdb4a1f62c59fb4cd2c74e4eb38ba5045935aa4941`.
  - Correção em `5f75566`: a regex aceita espaço no começo da linha. As outras linhas do 70 ficaram iguais.
  - Precedente: a Parte A repetiu a mesma `RODADA` depois de mandar para a lixeira o log superado, com o SHA registrado.
- **2ª rodada (`RODADA=20261019`, sobre `5f75566`):** o portão abriu inteiro e as seis chaves rodaram em 0,3 min. Log `c1_chaves_fase4_20261019.md`, SHA-256 `54686e104674a9ab3ea1ef698f2a084e731ab3587e69b8dbcedc030e5f5b822f`.
  - Portão: tags no remoto; B1 fechada, com o SHA das entradas conferido; o 32 reproduzido com diferença 0 nas 26; `meta_curva` `identical` ao 45; `confere_meta` passa; primário conferido (28,2 °C; q = 0,9378; 1,003 (0,978 a 1,029); 1,020 (0,990 a 1,051)).
  - Chaves: 26 de 26 em todas, sem *fallback*, teste 3 com 26/26 em cada uma.

## Etapa 1: autoauditoria com código diferente (script 71)

Log `autoauditoria_c1_fase4_20261019.md`, SHA-256 `add3aa5fda7a7577edb101eb236e20beac3883c1f302c5d014a2e00a3b1961ba`.

| Item | Maior diferença (relativa ao maior valor absoluto) |
|---|---|
| Chave 3 por `glm` montado à mão (São Paulo; Aracaju): coeficientes; vcov | 2,9e-14 e 2,4e-14; 4,5e-15 e 9,3e-15 |
| Chave 5 com o offset calculado à mão (Belo Horizonte; Campo Grande): coeficientes; vcov | 5,7e-14 e 2,2e-14; 7,8e-13 e 1,8e-13 |
| Chave 1 por `gnm` à mão (Aracaju; Boundary.knots iguais): coeficientes; vcov | 0; 0 |
| TMR e RR da chave 5 por `crosspred` direto | TMR igual (28,4 °C); RR com diferença 0 |

Nenhuma divergência.

## Etapa 2: auditoria independente

- **Auditor:** subagente em contexto limpo. Leu a mensagem, as entradas 101 a 104, os scripts 70 e 71, os dois logs, os normativos, o plano e o código compartilhado. Não abriu `.rds`, `.csv`, `.parquet` nem `.dbc`.
- **Relatório:** `auditoria_independente_C1.md` (pasta de trabalho, SHA-256 `a08fefd8346b54b4218b82307b960237cea4a4448aa7b26ade69086a71ec96fb`).
- **Resultado:** 0 Críticos, 0 Maiores, 4 Menores e 16 Notas. Nenhum achado muda número da tabela do critério.
- **O que conferiu:**
  - o portão (tags ao vivo no remoto, reprodução real do principal, primário lido do RDS do 45);
  - cada chave muda só o que a mensagem diz;
  - o teste 3 com as entradas da D6, 2.2;
  - o p e o I² do Q refeitos a partir do log;
  - os limites do IC da TMR iguais ao x1 e ao x99 do eixo de cada chave;
  - sigilo dos logs.

| Achado | Reprodução | Correção |
|---|---|---|
| **M1.** O *fallback* da D7, M7, tem três defeitos (70, l. 207–215): (a) na chave 2 (lag 0–14), uma falha iria direto ao passo 2, quando a A1-97(c) manda registrar e levar ao chat; (b) qualquer falha dispara o passo 2, não só convergência e vcov (§5, critério 4); (c) no passo 2, uma concentração cujo passo 1 falhou volta à arglag ns | Confirmado na leitura do código. **Não disparou:** as seis chaves saem com "nenhum" e 26 incluídas | Sem efeito nesta rodada. Os scripts da C3, que repetem o fluxo, levam o *fallback* corrigido: passo 1 só para os motivos da §5; na chave sem estratos definidos, registra e para; no passo 2, ns p50/p90 e estratos 0–1, 2–4 e 5–7 |
| **M2.** O RDS do 45 entra sem conferência de SHA-256 | Reproduzido: SHA-256 do arquivo em disco `52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e`, igual ao registrado no log do 45 | Sem efeito: a entrada é a registrada. A conferência entra nos scripts da C3 |
| **M3.** O cabeçalho do 71 diz que confere o SHA das séries, e o código só confere o RDS do 70 | Confirmado. Reproduzido aqui: `serie_ptb_fase4.rds` (`e70190c1…93e0`), `serie_ptb_municipal.rds` (`04dad6b1…cd49`), `wj_ptb_concentracao.csv` (`23e753ba…d756`) e `referencias_exposicao.csv` (`281da260…5467`) têm os SHA dos logs da B1 e da RESPOSTA da Fase 1 | Sem efeito. Fica registrado aqui |
| **M4.** O SHA do log da 1ª rodada do 70 não estava em arquivo commitado | Confirmado: estava só na pasta de trabalho | Registrado na seção "Rodadas do 70", acima |
| N3: o IC do primário e a frase "o IC inclui 1" estão digitados nos cabeçalhos do log | Confirmado; as comparações usam o IC lido do RDS | Sem efeito |
| N9 a N11: o 71 tem alcance menor (nós da chave 1 vindos do 70; o `crosspred` usa a curva do 70; tolerância de 1e-6 folgada) | Confirmado | Declarado. As diferenças obtidas (≤ 7,8e-13) passariam também em 1e-10 |
| N16: as chaves 1 e 6 usam as séries da Fase 1, feitas com o offset v1.0 e reconstruídas idênticas no 64 | — | Declarado na RESPOSTA |
| Demais Notas (robustez, rótulos, formatação) | Aceitas | Sem efeito nesta rodada |

- **Achados abertos:** nenhum.
