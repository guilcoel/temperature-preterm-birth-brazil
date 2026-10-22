# Conferência final da Fase 0 refeita: sigilo exaustivo da A7, quadro-resumo da §9 e conferências finais

- **Gerado por:** `00_scripts/13_conferencia_final_rerun.R`, em 2026-10-09 10:18:27 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Por quê:** responde aos achados 1, 2 e 3 da auditoria independente (`logs/auditoria_fase0_rerun_20261009.md`).
- **Resultado:** 8 de 8 conferências ok.

| Item | Conferência | Esperado | Obtido | Ok |
|---|---|---|---|---|
| 1 | A7, prova exaustiva no modelo ampliado (497 linhas, mais os 724 átomos que valem 0, tratados como conhecidos): uniões de átomos de 1 a 9 (|J| = 338) identificáveis com valor de 1 a 9 | 0 | núcleo de dimensão 28 em 6 bloco(s); a menor união identificável vale ≥ 10; de 1 a 9: 0 | sim |
| 1 | d (PTB, não PTB, NV) somado em todo subconjunto das 14 concentrações com (b) suprimido (16.383 subconjuntos por tipo): identificáveis com valor de 1 a 9 | 0 | identificáveis: ptb_d 0, non_d 0, nv_d 511; furos: 0 | sim |
| 3 | log de desvios: numeração 1 a N sem lacuna, e os primeiros bytes com o SHA-256 inventariado (só acréscimos) | 1–N; sim | 1–28; sim | sim |
| 3 | prova do grep da versão antiga: só CLAUDE.md:13 (nome da ENTREGA; desvio 19) e :42 (histórico) | CLAUDE.md:13 e :42 | CLAUDE.md:13 e CLAUDE.md:42 | sim |
| 3 | logs gerados por script nesta rodada registram a versao() do fim (4443971b) | 11 de 11 | 11 de 11 | sim |
| 3 | SHA-256 dos CSV: os 8 de fase0_rerun/ = log da A6; os 6 de fase0/ = log da Fase 0A | 8 e 6 | 8 e 6 | sim |
| 3 | git: nenhum commit; CSV de fase0_rerun/ e a cópia de reprodução ignorados | 0; todos | 0; 9 de 9 | sim |
| C8 | versao() no início e no fim | 4443971b e 4443971b | 4443971b e 4443971b | sim |

## 1. Sigilo da A7: prova exaustiva

- **Modelo:** o do `12_autoauditoria_itens_novos_rerun.R`: átomos da janela (concentração × 13 trechos × PTB ou não × nível da DUM c, d, e) = 2.028; pontas fora da janela (concentração × 4 trechos × PTB ou não × nível) = 624; NV de 43–44 semanas da coorte por ano × nível = 39. Linhas: as células publicadas da A7 (por concentração, 26 somadas e por ano), a A5.2 do PTB, os totais anuais de NV, PTB e NV de 43–44, a Tabela 1b do RESPOSTA da base (n, comparáveis e concordantes por ano, o % tratado como exato), as conciliações §A3 (NV e PTB por ano em Salvador e Aracaju) e os zeros da Q5. Valores pela recontagem independente do `12` (coorte pelo `dum_est`).
- **Método (o do `10`, no nível de átomo, exato):** toda contagem candidata é uma união de átomos. Conservador: os átomos que valem 0 entram como conhecidos, o que só aumenta o que é identificável; então uma união de 1 a 9 só tem átomos de 1 a 9 (J). Em J, a união é recuperável se e só se x'Hx = 0. O núcleo de H é separado em blocos de suporte disjunto. Bloco de até 18 átomos: todas as uniões enumeradas. Bloco maior: a base é escalonada (RREF), com os NV de 43–44 por ano (sem concentração) como pivôs globais; as 2^g escolhas globais são enumeradas e, fixadas, cada concentração se resolve sozinha (cada escolha dela dá um vetor 0/1 ou é inviável); uma programação dinâmica sobre os valores diz se alguma união 0/1 identificável vale de 1 a 9. A busca cobre **todas** as uniões de átomos de J, inclusive somas sobre qualquer subconjunto de concentrações, trechos e anos.
  - **Núcleo de H em J:** dimensão 28; |J| = 338; 497 linhas mais 724 zeros conhecidos; posto 1023.

| Átomos | Dimensão | Método | Linhas globais | Escolhas viáveis | Menor união identificável | De 1 a 9 |
|---|---|---|---|---|---|---|
| 234 | 23 | RREF + programação dinâmica | 3 | 8 | ≥ 10 | não |
|   9 |  1 | enumeração | — | 1 | ≥ 10 | não |
|   8 |  1 | enumeração | — | 1 | ≥ 10 | não |
|   3 |  1 | enumeração | — | 1 | ≥ 10 | não |
|   6 |  1 | enumeração | — | 1 | ≥ 10 | não |
|   9 |  1 | enumeração | — | 1 | ≥ 10 | não |

- **Teste pedido pelo auditor:** o discordante (d), de PTB, de não PTB e de NV, somado na janela inteira em todo subconjunto não vazio das 14 concentrações com o (b) suprimido (Fortaleza/CE, Curitiba/PR, Campinas/SP, Manaus, Belém/PA, Vitória/ES, São José dos Campos/SP, Maceió/AL, Florianópolis/SC, Teresina/PI, Aracaju/SE, Cuiabá/MT, Sorocaba/SP, Campo Grande).

| Tipo | Subconjuntos | Identificáveis | Com valor de 1 a 9 | Identificáveis e de 1 a 9 |
|---|---|---|---|---|
| ptb_d | 16.383 | 0 | 83 | 0 |
| non_d | 16.383 | 0 | 13 | 0 |
| nv_d | 16.383 | 511 | 5 | 0 |

- **Correção de texto (achado 1):** a frase do log da A7 (`logs/populacao_dum_fase0_rerun_20261009.md`, linha 87) diz que as tabelas externas trazem d e e sempre juntos. Isso vale para as tabelas do modelo do `09`, mas não para a Tabela 1b do RESPOSTA da base, que separa c, d e e por ano, nas 26 somadas (n, comparáveis e % |dif| ≤ 1). A prova completa da A7 é a deste log (com a Tabela 1b), mais as conferências do `12`.

## 2. Quadro-resumo da §9 (pelos itens que o prompt enumera; a Revisão 2 não está na Forja)

| Item | Tabela por concentração | Média nas 26 (faixa) | Fase 0A: média (faixa) | Maior diferença por concentração |
|---|---|---|---|---|
| Perda %, ptb, janela principal (total: 27.667 de 1.405.697; 1,97%) | A5.2 (`a5_2_eventos_janelas.csv`) | 2,02 (de 1,77 a 2,30)% | 2,02 (de 1,77 a 2,30)% | 0 |
| Eventos na janela principal, ptb; abaixo de 1.000: 0; abaixo de 2.000: 0 () | A5.2 | 53.001 (de 13.393 a 335.025) | 53.001 (de 13.393 a 335.025) | 0 |
| Perda %, obito_perinatal, janela principal (total: 4.995 de 180.064; 2,77%) | A5.2 (`a5_2_eventos_janelas.csv`) | 2,75 (de 1,53 a 3,27)% | 2,75 (de 1,53 a 3,27)% | 0 |
| Eventos na janela principal, obito_perinatal; abaixo de 1.000: 0; abaixo de 2.000: 3 (Sorocaba/SP, Florianópolis/SC, Campo Grande) | A5.2 | 6.733 (de 1.424 a 38.421) | 6.733 (de 1.424 a 38.421) | 0 |
| p1 da MM9, em percentil semanal (i) | A5.4 (`a5_4_semanal_mm.csv`) e A5 (`a5_4c…`) | 6,0 (de 2,4 a 8,2) | 6,0 (de 2,4 a 8,2) | 0 |
| p99 da MM9, em percentil semanal (i) | A5.4 e A5 | 95,3 (de 90,6 a 99,0) | 95,3 (de 90,6 a 99,0) | 0 |
| p1 da MM14, 1º trimestre (°C) | A5 (`a5_4c_mm14_mm9_equivalentes.csv`) | 21,85 (de 14,49 a 27,23) °C | 21,85 (de 14,49 a 27,23) °C | 9.9e-14 |
| p1 da MM14, 1º trimestre (percentil semanal (i)) | A5 | 8,5 (de 3,8 a 11,8) | 8,5 (de 3,8 a 11,8) | 0 |
| p99 da MM14, 1º trimestre (°C) | A5 (`a5_4c_mm14_mm9_equivalentes.csv`) | 27,63 (de 23,05 a 31,04) °C | 27,63 (de 23,05 a 31,04) °C | 9.9e-14 |
| p99 da MM14, 1º trimestre (percentil semanal (i)) | A5 | 93,4 (de 88,0 a 97,9) | 93,4 (de 88,0 a 97,9) | 9.9e-14 |
| p1 da MM14, 2º trimestre (°C) | A5 (`a5_4c_mm14_mm9_equivalentes.csv`) | 21,90 (de 14,52 a 27,23) °C | 21,90 (de 14,52 a 27,23) °C | 0 |
| p1 da MM14, 2º trimestre (percentil semanal (i)) | A5 | 9,1 (de 3,8 a 12,7) | 9,1 (de 3,8 a 12,7) | 0 |
| p99 da MM14, 2º trimestre (°C) | A5 (`a5_4c_mm14_mm9_equivalentes.csv`) | 27,63 (de 23,05 a 31,04) °C | 27,63 (de 23,05 a 31,04) °C | 9.9e-14 |
| p99 da MM14, 2º trimestre (percentil semanal (i)) | A5 | 93,4 (de 88,0 a 97,9) | 93,4 (de 88,0 a 97,9) | 9.9e-14 |

- **Diferença para a Fase 0A:** é a maior diferença absoluta, concentração a concentração, entre o CSV desta rodada e o da Fase 0A (o da MM14 é o `a5_4b` do complemento).
- **A7 (informativo para a redação da §3.5):** PTB entre os NV: 10,20% em (a) e 12,25% em (c), nas 26 somadas; por concentração, de 8,65% a 12,68% em (a) e de 10,32% a 16,04% em (c). O nível (c) é uma subpopulação selecionada: tem proporção de PTB maior que a população inteira.
- **Inventário da A1 refeito no fim:** `logs/inventario_fase0A_rerun_conferencia2_20261009.md` (rodado depois deste log e do log da auditoria).

`versao()` no fim: 4443971b.
