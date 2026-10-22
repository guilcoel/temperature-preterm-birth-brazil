# A8: reconferência das condições do desvio 9 (coluna "Perda" da A5.2), Fase 0 refeita

- **Gerado por:** `00_scripts/10_desvio9_rerun.R`, em 2026-10-09 09:35:50 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Só agregados:** séries diárias por concentração (`serie_diaria(nivel = "recorte", coorte_fixa = TRUE)`) e as tabelas publicadas. Nenhum microdado; nenhuma exposição.
- **Condições (decisões §6, pelo prompt da Fase 0 refeita):** vale só para a coluna "Perda" da A5.2, na RESPOSTA de 08/10 e na refeita; nenhuma célula de 1 a 9; nenhuma contagem menor que 10 recuperável por subtração contra outra tabela; reconferido aqui.

## Resultado

As quatro condições do desvio 9 se mantêm na Fase 0 refeita: a coluna "Perda" da A5.2 não tem célula de 1 a 9 (a menor perda diferente de zero é 40, Sorocaba/SP, obito_perinatal, janela principal; as perdas da janela de evento possível são 0 por desenho), e nenhuma combinação das 16 fontes listadas isola contagem menor que 10 dentro das pontas fora da janela, nem separa a ponta de 2012 da de 2024, por concentração ou nas 26 somadas.

## 1. Coluna "Perda" da A5.2 refeita

- **Fonte:** `01_saidas/fase0_rerun/a5_2_eventos_janelas.csv`; SHA-256 igual ao da Fase 0A (`01_saidas/fase0/a5_2_eventos_janelas.csv`): sim.
- **Células de 1 a 9:** 0 (esperado 0). **Menor perda diferente de zero:** 40 (Sorocaba/SP, obito_perinatal, janela principal); na Fase 0A, 40.

| Desfecho | Janela | Concentrações | Células de 1 a 9 | Células = 0 | Menor perda ≠ 0 | Onde |
|---|---|---|---|---|---|---|
| obito_perinatal | evento possível | 26 | 0 | 26 | — | — |
| obito_perinatal | principal | 26 | 0 |  0 | 40 | Sorocaba/SP |
| ptb | evento possível | 26 | 0 | 26 | — | — |
| ptb | principal | 26 | 0 |  0 | 295 | Sorocaba/SP |

- **Perdas = 0 na janela de evento possível:** são zeros por desenho da coorte fixa (Q5 da base: nenhum PTB ou NV antes de 2012-01-04, nenhum PTB depois de 2024-11-15; o perinatal depois de 2024-12-24 é NA por censura). Zero não é contagem de 1 a 9.

## 2. Fontes (todas as tabelas publicadas na Forja com contagens de PTB ou de óbito perinatal da mesma população, por concentração ou das 26 somadas)

| Nº | Arquivo | SHA-256 | Conteúdo | Na prova |
|---|---|---|---|---|
| F1 | `artigos_perinatais_clima/artigo1_prematuridade/01_saidas/fase0_rerun/a5_2_eventos_janelas.csv` | `a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5` | A5.2 refeita: PTB e perinatal por concentração; total 2012–2024, na janela e perda, nas janelas principal e de evento possível | no modelo |
| F2 | `artigos_perinatais_clima/artigo1_prematuridade/logs/recontagens_fase0_rerun_20261009.md` | `032202306922b3ec9f3619f63429bed2fd22a89c8ce389d4afd68d30bb689fbf` | as mesmas tabelas da A5.2 refeita, em markdown (vão para o RESPOSTA refeito) | = F1 |
| F3 | `artigos_perinatais_clima/artigo1_prematuridade/01_saidas/fase0/a5_2_eventos_janelas.csv` | `a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5` | A5.2 da Fase 0A | = F1 (SHA-256 igual) |
| F4 | `artigos_perinatais_clima/artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_20261008.md` | `b7e310d65f844dd25c1c440f38e1ba1e7d0cc065843fb4a3f670526caad4cf4e` | RESPOSTA da Fase 0A: A5.2 publicada | = F1 |
| F5 | `artigos_perinatais_clima/artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_complemento_20261008.md` | `e5f7517a5af5b7a8fb530249977aa172e5ea1ac2787aaf62cdff79f539c42a74` | complemento: nenhuma tabela de contagem de PTB ou de óbito por concentração (só a menor perda, que está em F1) | nada novo |
| F6 | `artigos_perinatais_clima/artigo1_prematuridade/01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv` | `82204b6b25ae61c74b1cfe891789447620662fc7d1966a37e24bd59dde98f64e` | A7 refeita: NV e PTB por concentração na janela principal, por nível da DUM (mascarada) | no modelo (células publicadas) |
| F7 | `artigos_perinatais_clima/artigo1_prematuridade/01_saidas/fase0_rerun/a7_populacao_dum_ano.csv` | `8900d5f94c77a11042890e438af4428f86f72d6343666f2e560bd3ee0a9d8da1` | A7 refeita: NV e PTB por ano, 2013–2023, 26 somadas (mascarada) | no modelo (células publicadas) |
| F8 | `artigos_perinatais_clima/artigo1_prematuridade/logs/populacao_dum_fase0_rerun_20261009.md` | `ec1bb81b5e5fa8d3bcb83cc489565e736b855e4ec157d6dbf1ac830ba63cad0a` | as tabelas da A7 em markdown, mais a linha das 26 somadas | no modelo (linha das 26 somadas) |
| F9 | `dados_artigos_perinatais_clima/ENTREGA_COORDENACAO_7e99bf94_20261007.md` | `a0a54b5ee8f0b0eeaf4654a897ea5f581e10dd8e902053750d7b1f888baa9549` | §5: por ano, 26 somadas (NV, PTB, óbito fetal, neonatal precoce, perinatal); §6: por concentração, PTB e perinatal 2012–2024 | no modelo; conferido contra a série |
| F10 | `dados_artigos_perinatais_clima/logs/relatorio_entrega_20261007.html` | `db3573c342f74d29203b23db85c50581ba45774a3a7eb82b5068d1a28e3369d4` | as tabelas da ENTREGA, mais, por ano e 26 somadas, os subtipos do PTB e as variantes do perinatal (sem coorte, sem IG, indexado no óbito, até 24 h, sem anomalia) | no modelo ou por argumento (seção 4); conferido |
| F11 | `dados_artigos_perinatais_clima/logs/relatorio_entrega_20261008.html` | `d14b282208598b7d73f49a6d5043f43666bcb073b0383e86348e6b1e726e9795` | igual ao F10, regerado na troca de versão | = F10; conferido |
| F12 | `dados_artigos_perinatais_clima/logs/totais_anuais.csv` | `fb7b1c63b6a82f81240c1287bd715f576b9f60c96b90452f76fdd4c0b5986c86` | por ano, 26 somadas, todas as contagens da série (com e sem coorte fixa) | no modelo ou por argumento; conferido |
| F13 | `dados_artigos_perinatais_clima/logs/criterios_inclusao_recorte.csv` | `e18c2125d607b3aec138bf0a169c7fcf7e503b2aed6a809d4924a5d2679c095a` | por concentração: eventos_periodo_principal de PTB e perinatal (= total 2012–2024) | no modelo; conferido |
| F14 | `dados_artigos_perinatais_clima/ENTREGA_COORDENACAO_conciliacoes_20261007.md` | `a73ce6f1e6033e1b1f1fdd21905421fdabe7ea967298506a1857a202efb4a512` | §A3: Salvador e Aracaju por ano, 2012–2024 (óbito fetal, neonatal precoce, PTB e % PTB, que dá o NV); §A2: por ano, 26 somadas, fetal e neonatal principais e sem IG | §A3 no modelo, com o NV tratado como exato (conservador); §A2 = F12 ou por argumento; conferido |
| F15 | `dados_artigos_perinatais_clima/RESPOSTA_QUESTIONAMENTO_20261007.md` | `16fe31e9af56e3e950e2bf11f795b19fedd4552c9983798b5eac4227385d011e` | Q5: zeros nas bordas (0 PTB e 0 NV antes de 2012-01-04; 0 PTB depois de 2024-11-15); Q6: 0 neonatal da coorte nascido de 25 a 31/12/2024; Q8 e Q11: por semana de IG, 2012–2024, 26 somadas; Q9b: PTB por `GESTACAO`, 2012 e 2013, 26 somadas | zeros no modelo; o resto por argumento |
| F16 | `dados_artigos_perinatais_clima/RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md` | `5374778d7276a8f8f95507fab2981068157b5bedb60177c5715627850d2b6961` | §6: NV por ano e por disponibilidade da DUM; nenhuma contagem de PTB nem de óbito | fora do desfecho (a A7 trata dela no `12_…`) |

## 3. Conferência: os números publicados que entram na prova = série nos trechos do modelo

| Conferência | Resultado |
|---|---|
| A5.2 refeita (F1), ptb, janela principal: total, na janela e perda = série nos trechos do modelo | bate |
| A5.2 refeita (F1), ptb, janela evento possível: total, na janela e perda = série nos trechos do modelo | bate |
| A5.2 refeita (F1), obito_perinatal, janela principal: total, na janela e perda = série nos trechos do modelo | bate |
| A5.2 refeita (F1), obito_perinatal, janela evento possível: total, na janela e perda = série nos trechos do modelo | bate |
| Totais anuais (F12), 2012–2024: NV, PTB, extremo, muito, moderado-tardio, fetal, neonatal, perinatal, até 24 h, perinatal 24 h, sem anomalia = série nos trechos do modelo | bate |
| ENTREGA §5 (F9): NV, PTB, fetal, neonatal, perinatal por ano = totais anuais | bate |
| ENTREGA §6 (F9): PTB e perinatal 2012–2024 por concentração = total da A5.2 | bate |
| criterios_inclusao_recorte.csv (F13): eventos_periodo_principal = total da A5.2, PTB e perinatal | bate |
| Relatório relatorio_entrega_20261007.html (F10): por concentração (PTB e perinatal 2012–2024) = A5.2; por ano (NV, PTB, 3 subtipos, fetal, neonatal, perinatal) e variantes (indexado no óbito, até 24 h, sem anomalia) = totais anuais | bate |
| Relatório relatorio_entrega_20261008.html (F11): por concentração (PTB e perinatal 2012–2024) = A5.2; por ano (NV, PTB, 3 subtipos, fetal, neonatal, perinatal) e variantes (indexado no óbito, até 24 h, sem anomalia) = totais anuais | bate |
| Conciliações §A3 (F14), Salvador: óbito fetal, neonatal precoce e PTB por ano, 2012–2024 = série nos trechos do modelo | bate |
| Conciliações §A3 (F14), Aracaju: óbito fetal, neonatal precoce e PTB por ano, 2012–2024 = série nos trechos do modelo | bate |
| Q5 (F15): 0 PTB e 0 NV de 2012-01-01 a 2012-01-03; 0 PTB de 2024-11-16 a 2024-12-31 (na série) | bate |
| Q6 (F15): neonatal precoce de 2024-12-25 a 2024-12-31 é NA nas 26 (censura); a Q6 publica que é 0 no SIM de 2024 | bate |

## 4. Prova por código

- **Trechos do calendário (1 a 17), por desfecho:** PTB: 2012-01-01..01-03 (q1), 2012-01-04..04-13 (q2), 2012-04-14..12-31 (parte de 2012 na janela), 2013 a 2023, 2024-01-01..08-06 (parte de 2024 na janela), 2024-08-07..11-15 (q3), 2024-11-16..12-31 (q4). Perinatal: q2 = 2012-01-04..05-25, parte de 2012 na janela a partir de 2012-05-26, q3 = 2024-08-07..12-24, q4 = 2024-12-25..12-31 (censura). As **pontas** são q1, q2, q3 e q4.
- **Átomos:** PTB: concentração (26) × trecho (17) × subtipo (extremo, muito, moderado-tardio, não PTB) × nível da DUM da A7 (3) = 5.304. Perinatal: concentração × trecho × tipo (fetal ou neonatal ≤ 24 h ou > 24 h, com ou sem anomalia; 6) = 2.652. Cada tabela publicada é uma soma de átomos com coeficiente 1.
- **Contagem candidata:** qualquer união de parcelas (PTB: concentração × trecho × subtipo; perinatal: concentração × trecho × tipo), em qualquer combinação de concentrações e trechos, inclusive as pontas, uma de cada vez ou juntas. Só pode valer de 1 a 9 se cada parcela dela valer no máximo 9; essas formam J (perinatal: pelo limite que as margens publicadas dão a cada tipo).
- **Método:** uma união é recuperável por subtração (combinação linear das tabelas) se, e só se, o indicador dela está no espaço das linhas publicadas. Em J, isso é x'Hx = 0, com H = diag(nº de átomos da parcela) − (TᵀQ)(TᵀQ)ᵀ, onde Q é uma base ortonormal do espaço das linhas. O núcleo de H é separado em blocos de suporte disjunto (o projetor é bloco-diagonal), e cada bloco é enumerado inteiro (até 18 parcelas) ou, se tem dimensão 1, testado pela união do bloco. Assim, a busca cobre **todas** as uniões de parcelas de J, não só uma lista de exemplos. **Não negatividade:** uma soma publicada ou identificável que vale 0 zera cada átomo dela, e o zero entra como linha conhecida; o passo se repete até não aparecer zero novo.

- **PTB:** 484 linhas publicadas no modelo; átomos com zero conhecido (somas publicadas = 0, zeros da Q5/Q6 e fechamento): 546, cada um como linha própria; posto do sistema com os zeros: 832.
  - **Parcelas que podem valer de 1 a 9 (J):** 46; núcleo de H em J: dimensão 0, em 0 bloco(s).
  - **Uniões identificáveis dentro de J:** 0; por valor: —. **Com valor de 1 a 9: 0.**
  - passo 1: 1030 linhas, posto 832, |J| = 46, núcleo 0, uniões identificáveis 0 (valor 0: 0), átomos novos com zero: 0

- **Perinatal:** 286 linhas publicadas no modelo; átomos com zero conhecido (somas publicadas = 0, zeros da Q5/Q6 e fechamento): 312, cada um como linha própria; posto do sistema com os zeros: 465.
  - **Parcelas que podem valer de 1 a 9 (J):** 156; núcleo de H em J: dimensão 0, em 0 bloco(s).
  - **Uniões identificáveis dentro de J:** 0; por valor: —. **Com valor de 1 a 9: 0.**
  - passo 1: 546 linhas, posto 416, |J| = 208, núcleo 3, uniões identificáveis 3 (valor 0: 3), átomos novos com zero: 52
  - passo 2: 598 linhas, posto 465, |J| = 156, núcleo 0, uniões identificáveis 0 (valor 0: 0), átomos novos com zero: 0

- **Separar a ponta de 2012 da de 2024 (exemplo do prompt):** a ponta de 2012 (q1 + q2) ou a de 2024 (q3 + q4), sozinha, é identificável em 0 de 108 casos (26 concentrações + as 26 somadas, × 2 pontas, × 2 desfechos). Controle: a perda principal de cada concentração (q1 + q2 + q3 + q4), que é publicada, é identificável nos dois desfechos: sim.

### Tabelas que não entram no modelo, e por quê

- **Outra população, com átomos próprios** (sem coorte fixa; óbitos sem IG; NV múltiplos; NV de 43–44 semanas; PIG, que soma NV a termo da coorte de 37 semanas com peso válido; 2011 de sensibilidade): cada uma soma átomos que só aparecem nas tabelas dessa mesma população (por concentração, por ano ou as duas). Numa combinação que identifique só átomos da população principal, esses átomos têm de se cancelar; quando a população tem tabela por concentração e por ano, o único cancelamento é a identidade soma das concentrações = soma dos anos, que não diz nada da população principal. Então essas tabelas não acrescentam nada. (Os NV de 43–44 semanas aparecem também na Tabela 1b do RESPOSTA da base, que o `12_…` trata.)
- **Indexado no óbito** (`*_idx_obito`, por ano, 26 somadas): difere do indexado na data-índice só pelos óbitos neonatais que atravessam a virada do ano (fluxo para o ano seguinte, átomo exclusivo desse par de colunas). A cadeia identifica cada fluxo anual; classe de cada um, sem exibir valor: 2012: ≥ 10; 2013: ≥ 10; 2014: ≥ 10; 2015: ≥ 10; 2016: ≥ 10; 2017: ≥ 10; 2018: ≥ 10; 2019: ≥ 10; 2020: ≥ 10; 2021: ≥ 10; 2022: ≥ 10; 2023: ≥ 10; 2024: 0. Nenhum fluxo cai nas pontas: o de 2011 para 2012 é 0 (coorte fixa) e o de 2024 para 2025 é 0 (Q6).
- **Por semana de IG** (Q8 e Q11, 2012–2024, 26 somadas) e **PTB por `GESTACAO`** (Q9b, 2012 e 2013, 26 somadas): publicam todas as categorias de uma variável que nenhuma outra tabela usa. O espaço das linhas fica invariante a permutar essas categorias, e as contagens candidatas somam a variável; pela média sobre as permutações (operador de Reynolds), essas tabelas só identificam o que a margem delas já identifica, e a margem (totais de 2012–2024 ou do ano) está no modelo.
- **RESPOSTA da base (`ig_dum_sem`), §6:** NV por ano e por disponibilidade da DUM; nenhuma contagem de PTB nem de óbito. A relação dela com a A7 é conferida no `12_autoauditoria_itens_novos_rerun.R`.

`versao()` no fim: 4443971b.
