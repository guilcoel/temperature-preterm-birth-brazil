# Auditoria independente da Fase 0 refeita (base 4443971b): achado → reprodução → correção

- **Quando:** 2026-10-09, das 09h45 às 10h10 (auditor). Reprodução e correções em seguida, até a `conferencia2`.
- **Auditor:** subagente em contexto limpo, só leitura, com as proibições do prompt:
  - nada da base fora de `09_acesso/`, menos o RESPOSTA da base;
  - nenhum `.parquet`, `.dbc` ou `.rds`, e nenhuma linha de microdado;
  - não rodar script do projeto;
  - não escrever contagem de 1 a 9.
- **O que ele leu:**
  - os scripts;
  - os logs `_rerun_`, inclusive o inventário da A1;
  - o log de desvios;
  - os CSV de `01_saidas/fase0_rerun/` e `01_saidas/fase0/`, e o `.tar` da A1;
  - o prompt da rodada;
  - as duas RESPOSTA da Fase 0A;
  - o RESPOSTA da base;
  - o `09_acesso/`.
- **Limitação:** a Revisão 2 das decisões não está na Forja (desvio 17). O auditor auditou contra o prompt.
- **Regra:** nenhum achado aceito sem reprodução por código próprio da sessão principal.

## Resultado do auditor

- **Não achou:** furo de sigilo, CSV da Fase 0A sobrescrito, nem SHA-256 que não bata.
- **Achou:** 1 achado médio, 4 baixos e 5 cosméticos, mais 1 informativo.
- **Verificou por conta própria, sem achado:**
  - a prova do `grep`;
  - os 6 CSV da Fase 0A;
  - as 62 entradas do inventário e as cópias dentro do `.tar`;
  - as linhas 1–21 do log de desvios iguais às do `.tar`;
  - os diffs dos editados contra o `.tar`;
  - o método e as linhas citadas da A5;
  - a A6;
  - a população e a reconciliação da A7;
  - os pares de diferença dos CSV da A7: 300 por concentração, 66 por ano e 1.512 A7 × A5.2, nenhum de 1 a 9;
  - a A7 por ano × a Tabela 1b: só classes, todas ≥ 10;
  - a parte da A8 que sai dos CSV;
  - as travas e a `versao()` dos scripts;
  - a A0;
  - os logs × CSV;
  - o `check-ignore` do git.

## Achado → reprodução → correção

| # | Grav. | Achado | Reprodução (sessão principal) | Correção |
|---|---|---|---|---|
| 1 | Média | A prova de sigilo da A7, como está documentada no `09`, deixa de fora a Tabela 1b do RESPOSTA da base. A linha 87 do log da A7 diz que as tabelas externas trazem d e e sempre juntos. Nem o `09` nem o `12` testam somas sobre um subconjunto qualquer de concentrações | **Reproduzido.** A linha 87 do log da A7 foi lida. A Tabela 1b (RESPOSTA da base, linhas 238–253) separa c, d e e por ano (n, comparáveis e % \|dif\| ≤ 1). Os grupos de candidatos do `09` e do `12` são fixos (cada concentração, cada ano, pontas, 26 somadas, concentração × trecho). A primeira versão da prova exaustiva no nível de átomo parou num bloco de 577 átomos com núcleo de dimensão 28, que não dá para enumerar. O diagnóstico (só estrutura, sem valores) achou 25 dimensões dentro das concentrações e 3 entre concentrações, pela Tabela 1b | **`13_conferencia_final_rerun.R`, seção 1:** prova exata no modelo ampliado (o do `12`, com a Tabela 1b e os NV de 43–44 semanas), com os átomos que valem 0 tratados como conhecidos (conservador). O núcleo de H em J (átomos de 1 a 9) tem dimensão 28, em 6 blocos. O bloco grande foi resolvido por RREF e programação dinâmica; nenhuma união identificável vale de 1 a 9, e a menor vale ≥ 10. O teste pedido (d de PTB, de não PTB e de NV, somado em todo subconjunto das 14 concentrações com (b) suprimido, 16.383 por tipo) não dá nenhum furo. A frase foi corrigida no desvio 22 e no log do `13`. **As tabelas da A7 não mudam** |
| 2 | Baixa | A `conferencia1` e as duas autoauditorias rodaram antes do desvio 21 | **Reproduzido** com `ls -lT`: `12` às 09:42:23, `03` às 09:42:39, `conferencia1` às 09:43:02 e log de desvios às 09:43:59. A `conferencia1` registra 16.735 bytes, e o log tinha 17.489 | As conferências finais foram para o `13`, que rodou depois de todas as linhas de desvio (1–28): numeração, prefixo, `grep`, `versao()` no fim de 11 logs, SHA-256 dos CSV e git. A `conferencia2` roda depois deste log |
| 3 | Baixa | Os logs não trazem todo o material do quadro da §9 (média e faixa das perdas e da MM14 em °C), nem a ordem de execução nem como reproduzir sem apagar | **Reproduzido:** os logs têm só totais e tabelas por concentração | O quadro-resumo da §9 é calculado por código no `13` (seção 2), com média e faixa nas 26, a Fase 0A e a diferença. O RESPOSTA traz a ordem de execução e a reprodução numa cópia fora do git, testada com o `07` (achado 4) |
| 4 | Baixa | As regerações via `trash` contornam a trava, e o texto dos desvios 18 e 20 não fecha ("três saídas"; "pela 3ª vez") | **Reproduzido.** No Lixo do volume (`/Volumes/Forja/.Trashes/501/`) há 7 versões; o SHA-256 e o horário de cada uma estão no desvio 23. Os dois CSV da A7 no Lixo têm o mesmo SHA-256 dos atuais. O `07` atual, rodado numa cópia (`01_saidas/reproducao_07_20261009/`, com `R_LIBS` na biblioteca do `renv` e `--no-init-file`), deu o log da A4 idêntico, menos a linha do horário | Desvio 23, com a lista exata, os horários e os SHA-256. As versões do Lixo não devem ser apagadas antes do congelamento |
| 5 | Baixa | O `README.md` da raiz ainda manda conferir a versão antiga e vai para o git na Parte B | **Reproduzido:** `README.md:7` | Desvio 24: pendência para a B8 (o README está congelado pelo inventário nesta rodada) |
| 6 | Cosmética | A exceção da linha 13 do `CLAUDE.md` é razoável | — | Mantida (desvio 19) |
| 7 | Cosmética | Os números e o texto do desvio 15 não batem com os logs | **Reproduzido:** 5,684342e-14 no log da A5 e 9,9e-14 no da A6. O `diff` do `04` contra o `.tar` mostra também a data fixa, a trava e o nome do log com `_rerun_` | Desvio 25 |
| 8 | Cosmética | A justificativa do desvio 14 é discutível | **Reproduzido:** a soma das partes de 2012 e de 2024 na janela é a linha "26 somadas" menos a soma de 2013 a 2023, com valores grandes | Desvio 26 (a escolha é decisão de Guilherme; essa soma é derivável) |
| 9 | Cosmética | No `02`, a trava do log vem depois da gravação dos CSV | **Reproduzido:** `write.csv` nas linhas 53–176 e trava do log na 260 | Desvio 27: pendência para uma rodada futura (a A4 exige o mesmo código) |
| 10 | Cosmética | Os scripts novos terminam em `_rerun.R`, e o `sessionInfo_rerun` não traz a `versao()` | **Reproduzido:** `ls`; `grep -c versao` no `sessionInfo` dá 0 | Desvio 28 |
| 11 | Informativo | O nível (c) é uma subpopulação selecionada: PTB de 12,25% em (c) contra 10,20% em (a) | **Reproduzido** no `13`, seção 2: nas 26 somadas, 10,20% e 12,25%; por concentração, de 8,65% a 12,68% em (a) e de 10,32% a 16,04% em (c) | Vai para o RESPOSTA, na A7 |

## Exceções às regras declaradas pelo auditor (aceitas)

- Gravou um arquivo temporário no scratchpad da sessão, fora da Forja, só com caminhos e SHA-256 do inventário, para usar o `shasum -c`.
- Usou Python para ler a Tabela 1b do RESPOSTA da base, que é documento permitido. Reportou só classes.
- Rodou `git --no-optional-locks check-ignore` (só leitura), `find -newer` e `ls -lT` (só metadado).

## O que o auditor não pôde verificar dentro das regras

- **Revisão 2 das decisões:** a lista exata do quadro da §9, o texto da aprovação do desvio 9 e a §11.
- **A8:** as fontes F9 a F15 da base, que ficam fora do `09_acesso/`.
- **Provas que dependem de microdado ou da série diária:**
  - as provas por posto do `09`, do `10`, do `12` e do `13`;
  - a recontagem independente do `12`;
  - as conferências C1–C11 do `03`;
  - os totais anuais.
- **A0 da base:** o `git` e o `renv::status()`.
- **As versões no Lixo.**

Essas provas são as conferências por código da sessão principal: `logs/autoauditoria_fase0_rerun_20261009.md` (60 de 60), `logs/autoauditoria_itens_novos_fase0_rerun_20261009.md` (26 de 26) e `logs/conferencia_final_fase0_rerun_20261009.md` (8 de 8).

## Achados da autoauditoria da própria sessão, durante a rodada (antes do auditor)

- **A8:**
  - o valor das uniões identificáveis não era arredondado, e um zero com resíduo de ponto flutuante caiu como "1 a 9";
  - o nome da ENTREGA no script tinha o literal da versão antiga;
  - o log foi gerado de novo (desvios 18, 20 e 23).
- **A7:** a faixa do "% mantido" excluía, sem avisar, as concentrações suprimidas. O log foi gerado de novo, e os CSV saíram com o mesmo SHA-256 (desvios 18 e 23).
- **`07`:** tinha o literal da versão antiga num comentário. Foi reescrito, e o log foi reproduzido numa cópia (desvios 20 e 23).
- **`12`:** duas conferências do próprio script estavam erradas. O log foi gerado de novo (desvio 21).
