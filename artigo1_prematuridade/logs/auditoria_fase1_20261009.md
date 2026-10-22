# Auditoria da Fase 1 (séries, offset e funções compartilhadas): Artigo 1

- **Data:** 2026-10-09.
- **Objeto:** scripts `20` a `25`, `codigo_compartilhado/` (`R/offset.R`, `tests/`, `DESCRIPTION`), logs `_fase1_20261009` e desvios 37 a 46.
- **Regra:** nenhum achado aceito sem reprodução por código próprio. Saídas da reprodução, tiradas às 2026-10-09 ~20:05 -0300 sobre as versões da primeira rodada, antes de qualquer correção.

## Etapa 1: autoauditoria (`25_autoauditoria_fase1.R`)

- **Primeira rodada (19:37):** 29 de 30 iguais. A 30ª tinha uma expectativa errada sobre os dias de Z_t = 0 da série municipal: faltava a parcela de dias com célula só por `z_fetal`. O log foi regerado (desvio 46). O texto original do nº 46 trazia uma contagem de 1 a 9 e foi mascarado antes do commit (desvio 47).
- **Segunda rodada (19:41):** 33 de 33.
- **Rodada final (20:18), depois das correções desta auditoria:** **44 de 44 iguais** (`logs/autoauditoria_fase1_20261009.md`).
- **Código diferente do que gerou cada número:**
  - `rowsum`, `aggregate`, `colSums` e `table`;
  - w_j por `cumsum` de tabela;
  - offset recalculado sem `monta_offset()`;
  - espontâneo por códigos combinados;
  - Z_tj por intervalo de datas;
  - A5.3 recalculada direto da `serie_diaria`;
  - dia da semana por `format(data, "%u")`.

## Etapa 2: auditoria independente

- **Quem auditou:** subagente em contexto limpo.
- **O que leu:**
  - os scripts 20 a 25;
  - o código e os testes compartilhados;
  - os logs `_fase1_` e o log de desvios;
  - a transcrição do prompt da Fase 1;
  - as seções pedidas da especificação e das decisões, em `spec/`;
  - a RESPOSTA refeita da Fase 0, em `spec/`;
  - `09_acesso/` da base.
- **Proibições respeitadas:**
  - não abriu `.parquet`, `.rds`, `.dbc` nem os CSV de `01_saidas/`;
  - não rodou script que lê a base;
  - só rodou R com dado sintético;
  - não alterou o repositório.
- **Veredito:** os conjuntos analíticos estão corretos onde importa: janelas, w_j, W_t, offset, estratos, calendário, classificação do espontâneo e totais da A5.2.
- **Achados:** 12. Um bloqueante de sigilo, 4 para corrigir e 7 notas.

| # | Achado | Gravidade | Reprodução própria | Correção |
|---|---|---|---|---|
| 1 | O desvio 46 publicava, sem "<10", uma contagem de 1 a 9 (dias-município com célula só por `z_fetal`) e os dois totais que a derivam. O 25 imprimia a mesma contagem no stdout | bloqueante (sigilo) | Leitura da linha do nº 46 e da linha 200 do 25 | O nº 46 foi mascarado antes do commit ("<10", sem os totais), e o 25 não imprime mais o número; registrado no desvio 47. A contagem saiu também numa mensagem da sessão ao Guilherme e no stdout; isso não tem volta e fica registrado no desvio 47 |
| 2 | A comparação com a A5.3, que é critério de parada, passaria calada se faltasse uma coluna no CSV: `NULL` → `max(abs(...))` = −Inf → `all(<= 1e-12)` dá TRUE. O 25 não refazia a A5.3 | corrigir | Sintético: com coluna ausente, `max|dif|` = `-Inf` e `all(d <= 1e-12)` = `TRUE`. Nesta rodada, as 9 colunas existem na A5.3 (`TRUE`), ou seja, a falha não ocorreu | O 20 e o 23 conferem que as colunas existem e que não há NA, e o 20 registra a diferença por coluna. O 25 recalcula os 9 valores × 2 períodos × 26 direto da `serie_diaria` e compara com a A5.3 e com o CSV do 20 (desvio 48 (c) e (e)) |
| 3 | `monta_offset()` com `periodo = NULL`, que era o padrão, deixava sumir um dia ausente de uma entrada esparsa, sem erro e sem `z_t_zero` | corrigir | Sintético na versão da primeira rodada: valor padrão `NULL`; 4 linhas devolvidas para 5 dias, e o dia ausente sumiu | `periodo` passou a ser obrigatório; com `NULL`, a função para se faltar dia na grade de uma unidade. Testes novos: "dia ausente com NULL" e "Z_tj NA". Agora são 17/17 (desvio 48 (a)). A série da A3 não muda, porque o 21 já completava a grade |
| 4 | Afirmações fixas nos logs: "nesta rodada, nenhum par ficou de fora" (23); "os demais têm Z_t = 0" quando não havia demais (21); os NA declarados no 20 e no 21 não eram conferidos por código; o 25 tinha expectativas escritas à mão (15 e "n_j < 10: 0") | corrigir | `grep` das linhas no 21 (128) e no 23 (154) | Os textos passaram a depender do dado. O 20 e o 21 conferem por código cada NA declarado. O 25 deriva as expectativas do valor recalculado (desvio 48 (c) e (e)) |
| 5 | Lacunas do 25: faltavam 12 das 20 colunas da A6.1, os 4.498 dias, o `viol_je`, os dias incompletos, a A5.3 e os rótulos do dia da semana; o mínimo, a mediana e o máximo saíam sem o filtro do nº 40; e o 25 comparava células < 10 com células mascaradas (com uma célula < 10, o 23 mascara 2) | corrigir | Sintético: com x = (5, 100, 200), o 23 mascara 2 e o 25 contava 1 | O 25 ganhou as conferências que faltavam, o filtro do nº 40, a máscara reimplementada e mais trechos de texto conferidos. O 23 autotesta a máscara com dado sintético (desvio 48 (d) e (e)) |
| 6 | DP intra-estrato de `log_w` fora da previsão: São Paulo 0,0155 contra cerca de 0,007, e Sorocaba 0,0265 contra cerca de 0,022. Se fosse só ruído de composição, a razão Sorocaba/São Paulo seria cerca de √(78.150/3.228) = 4,92; a especificação prevê 3,14; o observado é 1,71. Há um componente que não cai com o tamanho | nota | Contas sobre o log da A6: 4,92; 3,14; 1,71 | Registrado na RESPOSTA, com as hipóteses do auditor: quedas de nascimentos em feriados herdadas por s; preferência de registro da IG variando no tempo; forma real da sazonalidade das concepções. O dia da semana dos partos se anula nas semanas completas. É uma checagem de plausibilidade, sem critério de parada. Sugestão para o chat: diagnóstico agregado antes da Fase 2 |
| 7 | A conferência do calendário era circular: `as.integer(fator)` devolve os códigos com que o fator foi montado | nota | `calendario()$dia_semana` = `format(data, "%u")` em todos os dias: `TRUE` (os rótulos estavam certos) | O 23 e o 25 conferem contra `format(data, "%u")` (desvio 48 (d)) |
| 8 | De 2011-12-14 a 2011-12-31, Z_t = 0 é conhecido (coorte fixa), mas tinha sido gravado como NA, com `z_t_zero` NA. Na A3, há offset de 2012-01-01 a 03 (evento impossível) | nota | Principal: 468 linhas de 2011, todas com `z_t` e `z_t_zero` NA. Municipal: há offset não NA em dias-município de 2012-01-01 a 03 (contagem omitida: agregado mais fino que concentração × ano; reauditoria, novo 9) | `z_t` = 0 e `z_t_zero` = TRUE nesses dias, na A2 e na A3 (desvio 48 (b), que substitui a última frase do nº 44 (d)). O offset da A3 fora da janela de evento possível ficou, como nota: o prompt pede `periodo = NULL`, e a `linha_modelo` governa o ajuste (desvio 48 (f)) |
| 9 | A identidade da A4 fecha por construção da classificação (ignorado = resto): ela testa que o PTB do `nascimentos()` é igual ao da `serie_diaria`, dia a dia | nota | Leitura do 22 (linhas 40 e 54–55) | O log do 22 passou a explicar o que a identidade testa |
| 10 | Padrão frouxo em dois testes: `"1 dia(s)"` com `fixed = TRUE` aceita "11 dia(s)" | nota | `grepl("1 dia(s)", "11 dia(s)", fixed = TRUE)` = `TRUE` | Padrões ancorados com o prefixo `monta_offset: ` (desvio 48 (a)) |
| 11 | Ano do arquivo contra ano do parto na A6.9, sem registro | nota | Leitura do 23: Q2a por `nb2$ano` (arquivo), séries por `format(esp$data, "%Y")` | Registrado no desvio 48 (d) e no texto do log da A6 |
| 12 | Afastamentos pequenos sem registro: o padrão do `periodo`, a A6.1 só somada nas 26, o arquivo extra `conferencias_valores.csv`; e a `DESCRIPTION` sem `Imports: stats` | nota | Leitura: `formals` mostra o valor padrão `NULL`; a `DESCRIPTION` não tinha `Imports` | O padrão foi tirado; a A6.1 mostra quantas concentrações têm NA em cada coluna; o arquivo extra foi registrado; a `DESCRIPTION` declara `Imports: stats` (desvio 48) |

## Regeneração da cadeia (desvio 48)

**Artefatos da primeira rodada enviados para `/Volumes/Forja/.Trashes/501/`, com SHA-256 e horário:**

| Arquivo | SHA-256 | Gravado |
|---|---|---|
| `01_saidas/fase1/conferencias_valores.csv` | `f2912b6f08a15977fba35b1e442d6d9813fac7fb39ecacc393da153dc64f8c1b` | 19:33:21 |
| `01_saidas/fase1/nos_tmean_mun_concentracao.csv` | `93c2e43244b3b2ecd5db7b690073f62dbb249f5a21a6c46671e0e328d90565be` | 19:28:04 |
| `01_saidas/fase1/referencias_exposicao.csv` | `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467` | 19:25:15 |
| `01_saidas/fase1/serie_ptb_espontaneo.rds` | `66483e7953e4fca6dae76031016cc424924ad6cc63115293073f40bae4cd9a57` | 19:29:41 |
| `01_saidas/fase1/serie_ptb_municipal.rds` | `786239730ecc1a9df9034cae5bd12d34fff45463158b185c8db93f3f3a5117bd` | 19:28:04 |
| `01_saidas/fase1/serie_ptb_principal.rds` | `67f022b47daa75b8e9c8375220d7fc58dcfac95914d5e46557c6d2777d68e983` | 19:25:15 |
| `01_saidas/fase1/wj_ptb_concentracao.csv` | `23e753ba36743c7eae2a577b9c3f1aa11d2c60803dde95ac47b30b6aea756cd3` | 19:25:12 |
| `logs/testes_compartilhado_fase1_20261009.md` | `8e43cb831dc0f66d72bae69eb6bc3e5a202232f02909e22318f1b8cdaa367f38` | 19:22:41 |
| `logs/serie_principal_fase1_20261009.md` | `12ab6be4000bef62318ece0ee888a9d8c6460cd639c3cf7942d0e26bb2c7c26d` | 19:25:15 |
| `logs/serie_municipal_fase1_20261009.md` | `f2fb7f3642c3d3918976f30247ddf3ada75cad1d9451206bc2643b969b513aa5` | 19:28:04 |
| `logs/ptb_espontaneo_fase1_20261009.md` | `bb464cc796d395ffbf199dd2556374f635afab3572abd3557c3565a2489113c6` | 19:29:41 |
| `logs/conferencias_fase1_20261009.md` | `7e042f565701b31a915949b6a583afff723ce90df2f55eb80abe2172df1a9594` | 19:33:21 |
| `logs/autoauditoria_fase1_20261009.md` | `fa3f50acffec9aabe0e86d7d71bd79e5f617c3287ff33b62fc015902ceed9fda` | 19:41:57 |

A primeira versão do log da autoauditoria (19:37:40, `350ab0af…`) já tinha ido para o Lixo antes (desvio 46).

**Nova rodada:** 24 às 20:16:50, 20 às 20:16:52, 21 às 20:17:01, 22 às 20:17:43, 23 às 20:17:48 e 25 às 20:18:42. Todos terminaram com código 0, `versao()` = 4443971b no início e no fim, e o 23 terminou sem nenhuma falha.

**Comparação entre a primeira rodada e a nova (por código):**
- `wj_ptb_concentracao.csv`, `referencias_exposicao.csv`, `nos_tmean_mun_concentracao.csv` e `conferencias_valores.csv` são **idênticos byte a byte**.
- Nos três RDS (principal, municipal e espontâneo), as únicas colunas diferentes são `z_t` e `z_t_zero`, e **só de 2011-12-14 a 2011-12-31**. Era NA, passou a ser 0 e TRUE (desvio 48 (b)). Todas as outras colunas são idênticas.
- Os números das conferências da A6 não mudaram. Mudaram só a apresentação da A6.1 (coluna de concentrações com NA) e os textos.

## Reauditoria (independente, depois das correções; desvios 49 e 50)

- **Quem reauditou:** um subagente novo, em contexto limpo, com as mesmas proibições:
  - não abriu `.parquet`, `.rds`, `.dbc` nem os CSV de `01_saidas/`;
  - não rodou script que lê a base;
  - só rodou R com dado sintético;
  - não alterou o repositório.
- **Tentativa anterior:** foi interrompida quando a sessão reiniciou e não deixou relatório; ficaram só os arquivos de trabalho dela, no scratchpad.
- **O que leu:**
  - o log desta auditoria e os desvios 37 a 48;
  - os scripts 20 a 26;
  - o código e os testes compartilhados;
  - os logs `_fase1_`;
  - a transcrição do prompt.
- **Veredito:** as correções não criaram erro nos dados.
- **Achados da primeira auditoria:** 10 resolvidos e 2 parcialmente. O 4 voltava a aparecer no script 26, e o 5 ainda tinha lacunas na autoauditoria. Os dois foram tratados no desvio 49.
- **Achados novos:** 12. Nenhum bloqueante: 5 para corrigir e 7 notas. Todos foram reproduzidos por código próprio e tratados no desvio 49.

| # | Achado novo | Gravidade | Reprodução própria | Correção |
|---|---|---|---|---|
| 1 | Sigilo latente: a coluna "Maior dif." do 25 gravava a diferença exata em conferência de contagem; o 26 transcreveria a tabela sem conferir se o 25 deu n/n; o `stop` do 22 imprimia contagens de PTB | corrigir | Com o `confere()` do 25 e números sintéticos (1.007 contra 1.000), a coluna gravou a diferença exata (7) | Nas contagens, o 25 grava só "0" ou "diferente", e o `no_texto` não grava mais o trecho ausente. O 22 mascara de 1 a 9 como "<10" e não imprime a contagem de PTB. O 26 para se o 25 não der n/n ou se o log da A6 tiver FALHA |
| 2 | O 26 tinha a lista de desvios fixa (40 a 48), e a seção da reauditoria era opcional | corrigir | Leitura: `vapply(40:48, …)` e um `if (length(grep("^## Reauditoria" …)))` | Lista a partir do nº 40, sem número fixo e conferida em sequência; seção da reauditoria obrigatória (`stopifnot`) |
| 3 | Textos fixos no 26: "todas as obrigatórias passaram", as três concentrações escolhidas à mão, "acima" e as razões 4,92, 3,14 e 1,71 | corrigir | Leitura das linhas 46, 79, 83 e 111 do 26 | O texto vem do log da A6 (o script para se faltar a frase); as três maiores % de ignorado são calculadas; "acima"/"abaixo"/"perto" depende do valor; as razões são calculadas dos valores |
| 4 | A conferência final do 26 era fraca: ignorava "n/n" e "n de n" e buscava por substring ("20,9" casava com "20,95") | nota | `grepl("20,9", "20,95", fixed = TRUE)` = `TRUE` | Tokens "n/n" e "n de n" incluídos; busca com limite de número (`(?<![0-9.,])…(?![0-9]\|,[0-9])`); lista de exclusões retirada |
| 5 | Faltavam testes para garantias declaradas: o `periodo` sem valor padrão, a trava de Σ Z·w = 0 e o `z_t_zero` só onde Z_t = 0 | corrigir | Os 3 defeitos plantados (padrão `NULL`, `if (FALSE) stop(`, `z_t_zero <- !ok`) não derrubavam nenhum teste | 4 testes novos (`periodo_sem_valor_padrao`, `erro_soma_zw_zero`, `z_t_zero_so_onde_z_e_zero`, `erro_entradas_invalidas`). A bateria tem 21 testes, e cada um desses defeitos agora derruba 1 |
| 6 | Com `periodo = NULL`, a checagem da grade só vê buraco interno; entradas inválidas (`periodo` invertido ou de tamanho 1, w_j negativo) davam erro cru ou passavam | nota | Sintético: sem o primeiro dia da unidade, a função passa sem erro (4 linhas) | Validação de `periodo` e de w_j negativo. A documentação diz que garantir o intervalo da grade é de quem chama; a A3 monta a grade inteira e confere o nº de linhas |
| 7 | No 25, o dia da semana era conferido só por contagens, e o vetor delas é palíndromo | nota | `identical(x, rev(x))` = `TRUE` com 643/643/642/642/642/643/643 | O 25 confere o rótulo dia a dia contra `format(data, "%u")` em todas as linhas da série principal |
| 8 | Números sem autoauditoria: concentrações com NA da A6.1, NA de PM2.5 por concentração, estratos por concentração, as 5 datas, a lista de w_j não crescente, a `linha_modelo` do 21 e os testes derrubados por cada defeito | nota | Leitura do 25 | O 25 confere todos esses números (54 conferências) |
| 9 | O log desta auditoria trazia uma contagem de dias-município de 2012-01-01 a 03, mais fina que concentração × ano | corrigir | Leitura da linha do achado 8 | O número foi retirado do texto antes do commit |
| 10 | O desvio 48 (c) diz que o 23 registra a diferença por coluna, mas ele registrava só a maior | nota | Leitura do 23 | O 23 registra a diferença por coluna |
| 11 | "Sem célula" queria dizer "sem célula nas semanas 22 a 36" | nota | Leitura do 21 e do 25 | Redação corrigida no 21 e no 25 |
| 12 | Nenhum log registrava o SHA-256 do `conferencias_valores.csv`, e o `git status` do retorno é tirado antes de gravá-lo | nota | Leitura | O 23 grava o CSV antes do log e registra o SHA-256; o 25 o confere; o retorno diz que o `git status` é anterior a ele |

**Incidente (desvio 50):**
- **O que aconteceu:** para comparar a 2ª rodada com a 3ª, a sessão copiou os 3 RDS e os 4 CSV da 2ª rodada para o scratchpad (`/private/tmp`, disco interno do Mac Mini).
- **Correção:** menos de um minuto depois, moveu as cópias de volta para dentro da Forja (`01_saidas/rodada2_comparacao_fase1/`, fora do git) e conferiu que não sobrou nenhum `.rds` desta sessão em `/private/tmp`. Depois da comparação, as cópias foram para o Lixo da Forja.
- **O que não aconteceu:** nada foi enviado a serviço externo, nem entrou em git, chat ou log.

**Regeneração da cadeia (3ª rodada, desvio 49).** Artefatos da 2ª rodada enviados para `/Volumes/Forja/.Trashes/501/`, com SHA-256 e horário:

| Arquivo | SHA-256 | Gravado |
|---|---|---|
| `01_saidas/fase1/conferencias_valores.csv` | `f2912b6f08a15977fba35b1e442d6d9813fac7fb39ecacc393da153dc64f8c1b` | 20:17:55 |
| `01_saidas/fase1/nos_tmean_mun_concentracao.csv` | `93c2e43244b3b2ecd5db7b690073f62dbb249f5a21a6c46671e0e328d90565be` | 20:17:43 |
| `01_saidas/fase1/referencias_exposicao.csv` | `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467` | 20:17:01 |
| `01_saidas/fase1/serie_ptb_espontaneo.rds` | `654ecbf5cda28dc066709d99238a11370c1205da0f08183152fb326df9a99af7` | 20:17:48 |
| `01_saidas/fase1/serie_ptb_municipal.rds` | `04dad6b1b54472802594ef3ed44adcf327c02e0cd7ed88dd90af63b86770cd49` | 20:17:43 |
| `01_saidas/fase1/serie_ptb_principal.rds` | `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917` | 20:17:01 |
| `01_saidas/fase1/wj_ptb_concentracao.csv` | `23e753ba36743c7eae2a577b9c3f1aa11d2c60803dde95ac47b30b6aea756cd3` | 20:16:58 |
| `logs/testes_compartilhado_fase1_20261009.md` | `b06d5f41bc386bbe844490fbbf16e6a46ffa87b798a1467e056dbbd5fe2156e9` | 20:16:52 |
| `logs/serie_principal_fase1_20261009.md` | `14a0fd9a389246b4afda4396c186d786e5fe1b78bde88e200e529a5e80ade856` | 20:17:01 |
| `logs/serie_municipal_fase1_20261009.md` | `466db72f89e5ad483d1a02bb37d6ccf50f6f8999839d3c361e75cfff047826e4` | 20:17:43 |
| `logs/ptb_espontaneo_fase1_20261009.md` | `4fb1e8751888014639ce83cc340b5d403403464b9c2a736bb773406346633990` | 20:17:48 |
| `logs/conferencias_fase1_20261009.md` | `f3f31f6f3880f148f67ae1f0e8e322e77c5cae223b9295a8b00fb8ca4ad65368` | 20:17:55 |
| `logs/autoauditoria_fase1_20261009.md` | `d43f34470b541c4d178286510a2300474785330ffc5ac7ba294e9c3a85cea0da` | 20:19:21 |

**3ª rodada:**
- **Horários de início:** 24 às 21:11:57, 20 às 21:11:59, 21 às 21:12:09, 22 às 21:12:51, 23 às 21:12:56 e 25 às 21:13:03.
- **Resultado:**
  - todos terminaram com código 0, com `versao()` = 4443971b no início e no fim;
  - bateria de testes: 21/21;
  - o 23 terminou sem nenhuma falha;
  - autoauditoria: 54 de 54.
- **Comparação entre a 2ª e a 3ª rodada:** os 3 RDS e os 4 CSV (`serie_ptb_principal.rds`, `serie_ptb_municipal.rds`, `serie_ptb_espontaneo.rds`, `wj_ptb_concentracao.csv`, `referencias_exposicao.csv`, `nos_tmean_mun_concentracao.csv` e `conferencias_valores.csv`) são **idênticos byte a byte**. As correções da reauditoria mudaram só conferências, textos e testes, não os dados.
