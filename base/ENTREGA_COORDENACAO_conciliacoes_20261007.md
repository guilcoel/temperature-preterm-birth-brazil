# Conciliações A1, A2, A3 e A5: base `7e99bf94` (07/10/2026)

Resposta do Claude Code às perguntas da coordenação sobre a entrega da base. Só agregados: Brasil × ano ou concentração × ano, com contagem menor que 10 escrita como "<10". A mensagem não trazia um A4.

## Resumo

- **A1: não há erro no dado; o rótulo era ambíguo.** Os 7.704 NV de diferença são 1.486 com sexo ignorado e 6.218 com |z| > 5, que o 07b exclui depois da contagem do critério de inclusão. Corrigi o rótulo da coluna no relatório e a documentação dos logs.
- **A2: os 16,4% / 13,0% → 6,0% não eram da base, e citei esses números por engano.** Eles vêm do Brasil inteiro, com todos os registros, e contam como "sem IG nenhuma" quem não tem nem `SEMAGESTAC` nem `GESTACAO`. Na base, a fração de óbitos sem IG cai de 12,7% (neonatais) e 9,6% (fetais) em 2012 para 2,2% e 3,6% em 2024. Corrigi o relatório, a entrega e a pendência P-SIM.
- **A3: Salvador e Aracaju não são artefato de IG nem de município ignorado.** As duas têm óbito fetal e neonatal bem acima da mediana das 26 e % de prematuros um pouco abaixo. Em Aracaju, a IG mais completa leva cerca de 5% a mais de óbitos ao principal, o que explica só uma parte pequena da razão alta.
- **A5: a consulta usa a semana completa, que é a definição do próprio artigo, e a transcrição está confirmada.** O PIG por Pedreira fica em 6–7% porque o p10 dela fica 49–117 g abaixo do p10 observado a termo. A fonte é o SINASC de 2003–2005, quando a IG vinha em faixas.
- **Nenhum dado mudou, e a base continua na versão `7e99bf94`.**

## A1. População do PIG

| Passo | NV |
|---|---:|
| `populacao_pig_principal` no `criterios_inclusao_recorte.csv`, soma das 26 | 12.677.144 |
| − sexo ignorado (07b) | 1.486 |
| − \|z\| > 5 (07b) | 6.218 |
| = população final do PIG (`pig_resumo_ano.csv`, 2012–2024) | **12.669.440** |

**Os outros filtros são os mesmos nas duas contagens:** período 2012–2024, NV único, IG de 37–42 semanas, `coorte_fixa_37` e peso válido (200–7.000 g). A coluna do critério de inclusão é calculada no 06b, antes da classificação do PIG.

**O que mudei:**
- a legenda da coluna no relatório;
- a definição em `logs/LEIAME_logs.md`.

Nenhum dado mudou.

## A2. Óbitos sem IG: numerador e denominador

**Na base**, as duas contagens vêm da série sem coorte fixa (26 concentrações):
- **numerador:** `obito_*_sem_ig`, isto é, óbito único, sem IG válida e com data-índice. O fetal entra pela faixa `GESTACAO` 2–6 ou pelo peso ≥ 500 g;
- **denominador:** o numerador mais o principal (único, IG de 22–42).

| Ano | Fetal sem IG | Fetal principal | % fetal sem IG | Neonatal sem IG | Neonatal principal | % neonatal sem IG |
|---|---:|---:|---:|---:|---:|---:|
| 2012 | 1.007 | 9.530 | 9,56 | 764 | 5.233 | 12,74 |
| 2013 | 788 | 9.605 | 7,58 | 441 | 5.513 | 7,41 |
| 2014 | 627 | 10.019 | 5,89 | 363 | 5.724 | 5,96 |
| 2015 | 610 | 10.388 | 5,55 | 348 | 5.721 | 5,73 |
| 2016 | 559 | 9.540 | 5,54 | 292 | 5.400 | 5,13 |
| 2017 | 540 | 9.706 | 5,27 | 253 | 5.516 | 4,39 |
| 2018 | 471 | 9.718 | 4,62 | 201 | 5.297 | 3,66 |
| 2019 | 367 | 9.119 | 3,87 | 161 | 5.194 | 3,01 |
| 2020 | 442 | 9.251 | 4,56 | 183 | 4.819 | 3,66 |
| 2021 | 387 | 9.004 | 4,12 | 135 | 4.558 | 2,88 |
| 2022 | 322 | 8.236 | 3,76 | 134 | 4.453 | 2,92 |
| 2023 | 304 | 7.908 | 3,70 | 101 | 4.499 | 2,20 |
| 2024 | 269 | 7.147 | 3,63 | 92 | 4.138 | 2,17 |

**Ficam fora do numerador e do denominador:**
- as gestações múltiplas;
- os óbitos com IG válida, mas fora de 22–42 semanas;
- os óbitos fetais sem IG que não entram nem pela faixa nem pelo peso;
- os neonatais sem `DTNASC` ou com `IDADE` inválida.

Em 2024, os neonatais também não incluem os nascidos de 25 a 31/12, por causa da censura.

**De onde vinham 16,4% / 13,0% → 6,0%:** são do SIM bruto do Brasil inteiro, com todos os óbitos fetais do DOFET e todos os neonatais precoces do DO, de qualquer `GRAVIDEZ`. O numerador conta quem não tem `SEMAGESTAC` nem `GESTACAO`:

| Ano | Tipo | Sem IG nenhuma | Todos os registros | % |
|---|---|---:|---:|---:|
| 2012 | neonatal precoce | 3.370 | 20.568 | 16,4 |
| 2012 | fetal | 4.197 | 32.229 | 13,0 |
| 2024 | neonatal precoce | 902 | 14.933 | 6,0 |
| 2024 | fetal | 1.455 | 24.364 | 6,0 |

**A conclusão qualitativa se mantém, com magnitude diferente.** A exclusão por falta de IG cai no tempo, sobretudo até 2015, e isso cria uma alta artificial na série principal. Na base, a queda é de cerca de 6 pontos nos fetais e de 10,5 pontos nos neonatais.

O script `00_scripts/testes/conciliacao_coordenacao_20261007.py` refaz as duas tabelas, e o resultado reproduz os números antigos exatamente.

## A3. Salvador e Aracaju

**Razão óbito perinatal / prematuro, 2012–2024:** varia de 0,081 a 0,197 entre as 26, com mediana de 0,127. As cinco maiores:

| Concentração | Razão |
|---|---:|
| Salvador | 0,197 |
| Aracaju | 0,182 |
| Rio de Janeiro | 0,156 |
| Manaus | 0,153 |
| João Pessoa | 0,141 |

**Como ler as tabelas:**
- "med" é a mediana das 26 concentrações no mesmo ano;
- fetal ‰ = óbito fetal principal ÷ (NV únicos + óbito fetal principal) × 1.000;
- neonatal ‰ = neonatal principal ÷ NV únicos × 1.000;
- % IG = proporção de óbitos dos residentes, de qualquer `GRAVIDEZ`, com `SEMAGESTAC` válido.

**Município de residência ignorado:** o óbito com município ignorado não tem município, então não pode ser atribuído a uma concentração. Por isso a tabela mostra o % do DOFET na UF do núcleo, tirado do aceite da fase 1.

**Salvador (UF: BA)**

| Ano | Óbito fetal | Neonatal precoce | Prematuros | Razão (med) | % PTB (med) | Fetal ‰ (med) | Neonatal ‰ (med) | % IG fetal (med) | % IG neonatal (med) | % município ignorado, DOFET BA (med) |
|---|---:|---:|---:|---|---|---|---|---|---|---|
| 2012 | 461 | 239 | 3.456 | 0,203 (0,126) | 11,81 (12,34) | 15,5 (9,7) | 8,2 (5,9) | 88,3 (85,8) | 83,8 (85,5) | 2,65 (1,06) |
| 2013 | 567 | 322 | 4.556 | 0,195 (0,123) | 10,32 (10,79) | 12,7 (8,2) | 7,3 (4,7) | 90,6 (90,5) | 83,8 (90,9) | 2,92 (1,09) |
| 2014 | 541 | 307 | 4.273 | 0,198 (0,129) | 9,33 (10,26) | 11,7 (8,0) | 6,7 (5,0) | 89,0 (91,0) | 90,5 (91,8) | 2,12 (0,96) |
| 2015 | 638 | 311 | 4.321 | 0,220 (0,131) | 9,34 (9,86) | 13,6 (8,2) | 6,7 (4,9) | 92,7 (91,7) | 91,5 (92,1) | 1,31 (0,91) |
| 2016 | 534 | 340 | 3.961 | 0,221 (0,127) | 8,90 (9,95) | 11,9 (7,9) | 7,6 (4,8) | 90,8 (91,4) | 90,3 (93,1) | 1,02 (1,04) |
| 2017 | 543 | 299 | 4.316 | 0,195 (0,127) | 9,40 (9,83) | 11,7 (7,9) | 6,5 (5,0) | 92,8 (93,1) | 91,9 (93,7) | 1,28 (0,99) |
| 2018 | 552 | 324 | 4.247 | 0,206 (0,126) | 9,26 (9,69) | 11,9 (8,0) | 7,1 (4,6) | 94,7 (93,7) | 93,7 (94,0) | 1,62 (0,96) |
| 2019 | 459 | 303 | 4.152 | 0,184 (0,125) | 9,48 (9,90) | 10,4 (7,8) | 6,9 (4,5) | 94,5 (94,0) | 95,0 (94,8) | 1,48 (1,02) |
| 2020 | 486 | 281 | 3.900 | 0,197 (0,128) | 9,56 (9,99) | 11,8 (8,8) | 6,9 (4,4) | 92,1 (93,6) | 93,8 (93,3) | 1,02 (0,96) |
| 2021 | 517 | 246 | 3.507 | 0,218 (0,126) | 9,07 (10,22) | 13,2 (8,5) | 6,4 (4,6) | 94,3 (93,9) | 95,1 (94,5) | 0,83 (0,83) |
| 2022 | 410 | 278 | 3.657 | 0,188 (0,124) | 9,91 (10,56) | 11,0 (8,8) | 7,5 (4,5) | 95,5 (94,9) | 95,9 (95,5) | 0,98 (0,90) |
| 2023 | 411 | 232 | 3.542 | 0,182 (0,122) | 10,10 (10,64) | 11,6 (8,0) | 6,6 (5,0) | 95,4 (94,8) | 97,1 (97,0) | 0,65 (0,93) |
| 2024 | 261 | 141 | 2.827 | 0,142 (0,099) | 9,33 (10,10) | 8,5 (6,4) | 4,7 (4,1) | 90,5 (94,0) | 94,0 (96,0) | 0,68 (0,95) |

**Aracaju (UF: SE)**

| Ano | Óbito fetal | Neonatal precoce | Prematuros | Razão (med) | % PTB (med) | Fetal ‰ (med) | Neonatal ‰ (med) | % IG fetal (med) | % IG neonatal (med) | % município ignorado, DOFET SE (med) |
|---|---:|---:|---:|---|---|---|---|---|---|---|
| 2012 | 157 | 87 | 1.066 | 0,229 (0,126) | 10,54 (12,34) | 15,3 (9,7) | 8,6 (5,9) | 97,3 (85,8) | 98,7 (85,5) | < 10 óbitos (1,06) |
| 2013 | 155 | 100 | 1.473 | 0,173 (0,123) | 9,66 (10,79) | 10,1 (8,2) | 6,6 (4,7) | 93,8 (90,5) | 97,2 (90,9) | < 10 óbitos (1,09) |
| 2014 | 154 | 108 | 1.405 | 0,186 (0,129) | 9,04 (10,26) | 9,8 (8,0) | 6,9 (5,0) | 91,1 (91,0) | 97,9 (91,8) | < 10 óbitos (0,96) |
| 2015 | 182 | 101 | 1.486 | 0,190 (0,131) | 9,23 (9,86) | 11,2 (8,2) | 6,3 (4,9) | 99,5 (91,7) | 96,5 (92,1) | < 10 óbitos (0,91) |
| 2016 | 152 | 89 | 1.375 | 0,175 (0,127) | 9,30 (9,95) | 10,2 (7,9) | 6,0 (4,8) | 96,0 (91,4) | 98,4 (93,1) | < 10 óbitos (1,04) |
| 2017 | 151 | 109 | 1.441 | 0,180 (0,127) | 9,42 (9,83) | 9,8 (7,9) | 7,1 (5,0) | 96,4 (93,1) | 100,0 (93,7) | < 10 óbitos (0,99) |
| 2018 | 150 | 110 | 1.491 | 0,174 (0,126) | 9,61 (9,69) | 9,6 (8,0) | 7,1 (4,6) | 98,9 (93,7) | 98,8 (94,0) | < 10 óbitos (0,96) |
| 2019 | 121 | 94 | 1.273 | 0,169 (0,125) | 8,78 (9,90) | 8,3 (7,8) | 6,5 (4,5) | 97,3 (94,0) | 100,0 (94,8) | < 10 óbitos (1,02) |
| 2020 | 151 | 98 | 1.257 | 0,198 (0,128) | 8,91 (9,99) | 10,6 (8,8) | 6,9 (4,4) | 97,0 (93,6) | 100,0 (93,3) | < 10 óbitos (0,96) |
| 2021 | 140 | 86 | 1.141 | 0,198 (0,126) | 8,52 (10,22) | 10,3 (8,5) | 6,4 (4,6) | 98,8 (93,9) | 99,1 (94,5) | < 10 óbitos (0,83) |
| 2022 | 137 | 85 | 1.151 | 0,193 (0,124) | 9,26 (10,56) | 10,9 (8,8) | 6,8 (4,5) | 97,6 (94,9) | 98,3 (95,5) | < 10 óbitos (0,90) |
| 2023 | 134 | 96 | 1.345 | 0,171 (0,122) | 10,70 (10,64) | 10,5 (8,0) | 7,6 (5,0) | 97,5 (94,8) | 100,0 (97,0) | < 10 óbitos (0,93) |
| 2024 | 83 | 50 | 1.056 | 0,126 (0,099) | 9,31 (10,10) | 7,3 (6,4) | 4,4 (4,1) | 97,4 (94,0) | 98,8 (96,0) | < 10 óbitos (0,95) |

**Notas às tabelas:**
- Em Sergipe, o DOFET tem menos de 10 óbitos por ano com município ignorado, e o aceite mascara esse número.
- Na mediana do % de município ignorado, as UFs mascaradas entram pelo limite superior (9 ÷ n), então essa mediana está superestimada.

**Leitura:**
- **Salvador:**
  - o óbito fetal fica 1,25 a 1,66 vez a mediana, e o neonatal precoce 1,15 a 1,67 vez;
  - o % de prematuros fica 0,4 a 1,2 ponto abaixo da mediana;
  - a completude da IG fica perto da mediana; nos neonatais, chega a ficar abaixo (7 pontos em 2013), o que puxaria a razão para baixo.
  - O município ignorado na BA fica acima da mediana até 2018 (2,65% em 2012). Ele **subconta** os óbitos de Salvador, então, se pesa em algum sentido, é para baixar a razão, não para subir.
  - A razão alta reflete mortalidade perinatal mais alta, não artefato.
- **Aracaju:**
  - o óbito fetal fica 1,06 a 1,58 vez a mediana, e o neonatal 1,07 a 1,57 vez;
  - o % de prematuros fica abaixo da mediana em 12 dos 13 anos.
  - A IG é bem mais completa que a mediana: 91–99,5% nos fetais e 96,5–100% nos neonatais, contra 86–97% na mediana. Por isso uma fração maior de óbitos entra no principal.
  - Com a completude da mediana, o principal seria cerca de 4–5% menor (de 0 a 13%, conforme o ano e o tipo), e a razão ficaria perto de 0,17, ainda bem acima de 0,127. É uma aproximação: supõe que os óbitos sem IG se distribuem como os com IG.
- **Para o artigo 2:** a diferença de nível entre concentrações não enviesa a série temporal de cada uma. O que pesa é a completude da IG mudando no tempo (A2), e esse é o ponto a modelar ou testar em sensibilidade com as colunas `*_sem_ig`.

## A5. Pedreira 2011

**IG usada na consulta:**
- a semana completa (`ga_sem`), comparada com o p10 da semana completa, sem os +3 dias;
- os +3 dias valem só para o INTERGROWTH-21st, que usa a IG em dias.

É a definição do próprio artigo: a idade gestacional é o "interval, in completed weeks, between the first day of the mother's last menstrual period" (p. 620).

**Terceira leitura do p10 (Table I, p. 622):** feita na página renderizada pelo PDFKit e girada. Bate com o `pedreira2011_p10.csv` em todas as células de 37 a 42 semanas.

| Semana | Masculino (g) | Feminino (g) |
|---|---:|---:|
| 37 | 2.436 | 2.361 |
| 38 | 2.628 | 2.545 |
| **39** | **2.750** | **2.660** |
| **40** | **2.823** | **2.728** |
| 41 | 2.878 | 2.780 |
| 42 | 2.900 | 2.800 |

**Por que o PIG por Pedreira fica em 6–7%:**

A tabela abaixo compara o p10 observado com o de Pedreira, em NV únicos de 37–42 semanas de 2012–2024, com `coorte_fixa_37`, peso válido e sexo conhecido. A população é a de antes do filtro |z| ≤ 5, que tira 6.218 NV de 12,7 milhões.

| Semana | n (F) | p10 observado F | p10 Pedreira F | Diferença F | n (M) | p10 observado M | p10 Pedreira M | Diferença M |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 37 | 642.644 | 2.410 | 2.361 | +49 | 709.211 | 2.510 | 2.436 | +74 |
| 38 | 1.496.530 | 2.630 | 2.545 | +85 | 1.576.347 | 2.724 | 2.628 | +96 |
| 39 | 2.136.296 | 2.752 | 2.660 | +92 | 2.187.751 | 2.850 | 2.750 | +100 |
| 40 | 1.401.089 | 2.835 | 2.728 | +107 | 1.439.812 | 2.940 | 2.823 | +117 |
| 41 | 454.987 | 2.850 | 2.780 | +70 | 465.508 | 2.962 | 2.878 | +84 |
| 42 | 82.385 | 2.770 | 2.800 | −30 | 83.098 | 2.865 | 2.900 | −35 |

- **Onde está a diferença:** o p10 de Pedreira fica 49–117 g abaixo do observado de 37 a 41 semanas, onde estão 98–99% dos nascimentos a termo. Com o limite mais baixo, menos NV caem abaixo dele.
- **Os +3 dias explicam só uma parte.** Interpolar o p10 de Pedreira em 7 × IG + 3 dias sobe o limite em 3/7 do incremento semanal: 79–82 g na semana 37, 49–52 g na 38, 29–31 g na 39, 22–24 g na 40 e 9 g na 41. Na mesma população:

  | Semana | n | % PIG, semana completa | % PIG, +3 dias |
  |---|---:|---:|---:|
  | 37 | 1.351.855 | 7,80 | 10,73 |
  | 38 | 3.072.877 | 6,55 | 8,40 |
  | 39 | 4.324.047 | 6,15 | 7,23 |
  | 40 | 2.840.901 | 5,90 | 6,66 |
  | 41 | 920.495 | 7,05 | 7,37 |
  | 42 | 165.483 | 11,29 | 11,29 (sem a semana 43 para interpolar) |
  | **Total** | 12.675.658 | **6,50** | **7,82** |

  Mesmo com os +3 dias, Pedreira fica abaixo do INTERGROWTH-21st (8,99% na população principal). A população desta tabela é a de antes do filtro |z| ≤ 5, por isso o total de 6,50% difere pouco do 6,45% da população principal.
- **Limitação da fonte:**
  - os dados são do SINASC de 2003–2005, e o artigo diz que, nesses anos, a IG vinha em faixas (< 22, 22–27, 28–31, 32–36, 37–41, > 41);
  - a tabela por semana sai de curvas suavizadas, e o artigo não explica como passou das faixas para as semanas;
  - as causas da diferença não estão verificadas: essa construção, a mudança do peso ao nascer entre 2003–2005 e 2012–2024, ou a forma de datar a gestação.
- **Recomendação para o artigo 3:** declarar essa limitação e tratar Pedreira como sensibilidade. A escolha da curva principal é do artigo.

## O que mudou

- **Dados:** nada. A versão segue `7e99bf94`, e a interface passou em 22/22 (Python) e 18/18 (R) hoje.
- **Relatório:** https://claude.ai/artifact/6Q22dPqyGw4zpidfiU58Ls, versão 4. Corrigi a legenda da população do PIG, a pendência dos óbitos sem IG e a nota de Pedreira.
- **Documentos da base:**
  - `ENTREGA_COORDENACAO_7e99bf94_20261007.md`, seção 8: números de óbitos sem IG corrigidos e nota de Pedreira acrescentada;
  - `logs/pendencias_especificacao.md` (P-SIM): escopo dos 16,4%;
  - `logs/LEIAME_logs.md`: definição da coluna do PIG;
  - `07_pig_referencia/FONTE.md`: terceira leitura, IG da consulta e limitação de Pedreira.
- **Novo script:** `00_scripts/testes/conciliacao_coordenacao_20261007.py`, que refaz o A2, o A3 e o A5 e imprime só agregados.
