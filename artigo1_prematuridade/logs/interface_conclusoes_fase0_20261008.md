# A4: conclusões sobre a interface (escritas à mão)

- **O que é:** a leitura, feita à mão, das evidências de `logs/interface_fase0_20261008.md`, que é gerado por `00_scripts/01_interface.R`.
- **Por que um arquivo separado:** antes, estas seções ficavam no fim do log gerado e se perderiam se o script rodasse de novo (achado 7 da auditoria independente). O texto foi movido sem alteração, salvo a nota sobre as linhas do `06b`, abaixo.
- **Fontes:** o esquema do `manifesto.json`, o `09_acesso/DICIONARIO.md`, as linhas do código de construção transcritas no log gerado e as frequências já publicadas em `RESPOSTA_QUESTIONAMENTO_20261007.md` (Q2), da entrega da base.
- **Linhas do `06b_desfechos.py` citadas:** 142 (`SEMAGESTAC` limpo), 143 (faixa de 22 a 44), 144 (`unico`), 161 (`stcesparto_aj`), 166 (`pop_ptb`), 169 (`ptb`), 197 (`metodo_ig`) e 206 (`parto`, `sttrabpart` e `stcesparto`). A linha 287 também tem `PARTO` → `parto`, mas é do bloco de óbitos, não do de nascimentos.

## Conclusão sobre os códigos (itens (a)–(g) do chat)

Fontes: o código de construção citado acima, o esquema do `manifesto.json`, o `09_acesso/DICIONARIO.md` e as frequências já publicadas em `RESPOSTA_QUESTIONAMENTO_20261007.md` (Q2), da entrega da base. **Não rodei nenhuma tabela de frequência nova.**

| Item | Pergunta | Resposta | Fonte |
|---|---|---|---|
| (a) | `sttrabpart` e `parto` guardam os valores brutos 1/2/9, sem rótulo nem fator? | **Sim.** São cópias diretas das colunas do DBF (`.alias`), sem recodificação. Valores observados: `sttrabpart` 1, 2, 9 e vazio; `parto` 1, 2, 9 e vazio | 06b, linha 206; DICIONARIO; RESPOSTA Q2a e Q2c |
| (b) | Inteiros ou texto? | **Texto** (`large_string`), assim como `stcesparto`, `stcesparto_aj`, `metodo_ig` e `gestacao_cat`. Compare com `"1"`, não com `1` | manifesto.json |
| (c) | Como aparece o vazio? | **NA (nulo), nunca "".** O conversor tira os espaços e grava o branco como `None` | utils.py, linha 194; 06b, linha 161 (`is_null()`) |
| (d) | `stcesparto_aj` só difere do bruto em 2014–2015, no parto vaginal? | **Sim.** Por construção, ele só muda quando `PARTO` = "1" e `STCESPARTO` é nulo. Na contagem registro a registro (Q2b), as diferenças são 540.212 em 2014, 574.491 em 2015 e 0 nos outros anos | 06b, linha 161; RESPOSTA Q2b |
| (e) | `metodo_ig` guarda os códigos brutos do `TPMETESTIM`, inclusive o 8 e o branco? | **Sim.** É cópia direta (`.alias`). Códigos observados: 1, 2, 8 (de 2013 em diante), 9 e vazio (NA). O 8 não está no dicionário de 12/2019 | 06b, linha 197; RESPOSTA Q2d |
| (f) | `ga_sem` é o `SEMAGESTAC` limpo e é a IG que define `ptb`? | **Sim.** `SEMAGESTAC` sem espaços, convertido para inteiro, válido de 22 a 44 e NA fora disso (9 e 99 viram NA). `ptb` = `pop_ptb` e `ga_sem` ≤ 36, com `pop_ptb` = `unico` e `ga_sem` de 22 a 42 | 06b, linhas 142–143, 166 e 169 |
| (g) | `unico` equivale a `GRAVIDEZ = 1`? | **Sim.** `unico` = (`GRAVIDEZ` == "1"), com NA tratado como FALSE | 06b, linha 144 |

**Mapeamento SINASC → base** (registrado também no `CLAUDE.md`):

| SINASC | Base |
|---|---|
| `STTRABPART` | `sttrabpart` |
| `STCESPARTO` | `stcesparto` (bruto) e `stcesparto_aj` (ajustado) |
| `PARTO` | `parto` |
| `TPMETESTIM` | `metodo_ig` |
| `SEMAGESTAC` limpo | `ga_sem` |
| `GRAVIDEZ` = 1 | `unico` |
| `DTULTMENST` | **ausente** |

## Situação das sensibilidades

- **PTB espontâneo (§3.4): códigos confirmados** pelos itens (a)–(d). As colunas estão acessíveis por `nascimentos()` com os nomes da base, e a série é montada no artigo, sem versão nova da base.
- **Consistência interna da IG (§3.5): bloqueada.** `DTULTMENST` não está na base. Criar a coluna muda a `versao()` dos três artigos (a especificação cita `7e99bf94`). A decisão vai ao chat de métodos **antes da tag**. Isso não bloqueia a tag.
- **Calendário:** não está na série diária. Está em `calendario()`, com as seis colunas pedidas, e entra pela coluna `data`.
- **Termo precoce (37–38 semanas):** não há coluna na série diária. Ela será montada no artigo, na Fase 4, como o prompt prevê.
