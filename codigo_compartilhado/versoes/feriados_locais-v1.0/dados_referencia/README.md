# Feriados locais (estaduais e municipais) das cidades-núcleo, 2011–2024

Pesquisa B2: rodada 1 em 2026-10-18/19; rodada 2 em 2026-10-19. A tabela `feriados_locais_nucleo_2011_2024.csv` traz uma linha por data efetiva de feriado local, com 8 colunas, para alimentar a covariável `feriado_local`.

## Situação depois da rodada 2

- **Tabela:** 1.103 linhas e 25 núcleos depois das decisões A1-110 e A1-112 (eram 1.130 e 26/26 ao fim da rodada 2; 986 na rodada 1). Brasília não tem linha: na junção, a covariável dela vale 0 em todos os dias (não descartar a concentração). A conferência (`_confere_csv.py`) deu "sem erros".
- **Cobertura:** estaduais e municipais pesquisados nos 26 núcleos. A rodada 2 fechou os municipais de Florianópolis, Belém, Campo Grande e Cuiabá e os quatro atos do plano B (Goiânia, Cuiabá, Teresina e Manaus). Também pesquisou as antecipações da pandemia nos núcleos que faltavam e os feriados de eventos nas cidades-sede.
- **Linhas da rodada 2:** 278 linhas têm `conferido_por` = "subagente pesquisa B2 rodada 2, 2026-10-19". São as linhas novas e as que ganharam fonte nova. As demais seguem com o valor da rodada 1. O `_confere_csv.py` aceita os dois valores; foi a única mudança no script.
- **O que ainda pede atenção:** a seção "Fontes secundárias" e a seção "Dúvidas que sobraram", no fim.

## Arquivos desta pasta

| Arquivo | O que é |
|---|---|
| `feriados_locais_nucleo_2011_2024.csv` | a tabela (1.130 linhas) |
| `feriados_locais_nucleo_2011_2024_rodada1.csv` | cópia da tabela da rodada 1 (986 linhas), feita antes de qualquer mudança |
| `README_feriados_locais.md` | este documento |
| `_gera_feriados_locais.py` | as regras (feriado, ato, URL, vigência). Regenera o CSV a partir do arquivo de apoio e imprime as datas retiradas por coincidência e as concorrências |
| `_confere_csv.py` | confere colunas, ordem, datas, duplicatas, coincidência com nacional/móvel, 24/12 e 31/12 |
| `_aux_fetch.py` | leitura de páginas e PDFs públicos usada na pesquisa (não grava nada) |
| `_rodada2_achados_G1_municipais.md` a `_rodada2_achados_G5_pandemia.md` | notas da rodada 2, com URL e trecho literal de cada achado (G1 municipais; G2 fontes; G3 plano B; G4 eventos; G5 pandemia) |
| `calendario_nacional_moveis_2011_2024.csv` | arquivo de apoio: feriados nacionais e móveis do modelo |

`python3 -I _gera_feriados_locais.py` refaz o CSV; `python3 -I _confere_csv.py` confere.

## Decisões de borda (valem para todos os núcleos)

1. **Coincidência com nacional ou móvel:** a data local sai quando, naquele ano, é feriado nacional, Carnaval (seg/ter), Quarta de Cinzas, Sexta da Paixão ou Corpus Christi. A conferência é data a data contra `calendario_nacional_moveis_2011_2024.csv`. Saíram três datas:
   - Fortaleza, 2016-03-25 (Data Magna do CE caiu na Sexta da Paixão);
   - Recife, 2019-03-06 (Data Magna de PE caiu na Quarta de Cinzas);
   - Santos, 2024-11-20 (nacional).

   Feriados locais que são sempre nacionais ou móveis nem foram codificados:
   - Sexta-feira Santa e/ou Corpus Christi municipais (SP, Campinas, Santos, SJC, Sorocaba, BH, POA, Curitiba, Salvador, Fortaleza, Recife, Natal, Maceió, Manaus, Serra, São Luís, JP, Aracaju; na rodada 2, Florianópolis, Cuiabá e Teresina com os dois, Belém e Campo Grande só com Corpus Christi);
   - 2/11 (SP, SJC, POA, Florianópolis, Belém, Teresina);
   - Terça de Carnaval estadual do RJ (Lei 5.243/2008, texto não aberto);
   - Carnaval e Cinzas de Manaus (Lei 448/1998);
   - 21/04, 12/10, Sexta da Paixão e Corpus Christi do DF (Lei distrital 72/1989);
   - Corpus Christi estadual do MA (Lei 11.539/2021).
2. **20/11:** entra, de 2011 a 2023, só nos anos com lei estadual ou municipal em vigor. Em 2024 é nacional (Lei 14.759/2023, conferida no Planalto) e sai.
3. **24/12 e 31/12:** nunca entram.
4. **Mesma data, estadual e municipal:** uma linha só, com esfera `estadual`. Concorrências:
   - 20/11/2023 em São Paulo, Campinas, Santos e Sorocaba;
   - 05/08 de 2016 a 2024, exceto 2021, em João Pessoa;
   - 20/11 em Manaus (municipal pela Lei 188/2007, coberto pela estadual);
   - 05/09 em Manaus (também na Lei Orgânica, art. 437, I);
   - 29/06 em Maceió (São Pedro estadual e Floriano Peixoto municipal);
   - 26/05/2020 em Salvador;
   - Rio de Janeiro: 23/04 (exceto 2021) e 20/11 de 2011 a 2023, que a Lei municipal 5.146/2010, art. 8º, também faz feriados;
   - Cuiabá: 20/11, que os decretos anuais da Prefeitura também listam como feriado municipal.
5. **Ponto facultativo, recesso, data comemorativa e "feriado" só do serviço público:** ficam fora (lista no fim).
6. **Antecipações e transferências (pandemia e outras):**
   - Quando lei, medida provisória, ou decreto autorizado por lei mudou a data num ano, entra a data efetiva e sai a original daquele ano. O nome diz "antecipado" ou "transferido".
   - Quando o ato antecipa vários feriados para um bloco de dias sem dizer qual vai para qual dia, as datas novas entram como bloco e todas as originais daquele ano saem (Sorocaba 2021, Campo Grande 2021, São Paulo 2021).
   - Transferência só por decreto administrativo de um ano, sem lei: não entra, e a data de lei fica (MA 2015, Maceió 2021, TJPI 2022, TRE-PI 2023).
7. **Fim de semana:** feriado em sábado ou domingo entra (a covariável é por data). Isso inclui a Data Magna de PE de 2011 a 2017, que era o 1º domingo de março.
8. **DF:** leis distritais tratadas como esfera `estadual`, porque o DF não tem municípios.
9. **Datas móveis calculadas:**
   - **N. Sra. da Penha (ES):** Páscoa + 8 dias (Lei ES 11.010/2019). Páscoa pelo algoritmo de Meeus, conferido contra as 14 Sextas da Paixão do arquivo de apoio.
   - **Data Magna de PE de 2011 a 2017:** 1º domingo de março.
   - **SC, 11/08 e 25/11:** transferidos para o domingo seguinte quando caem de segunda a sexta. Ver dúvidas.
10. **Meio feriado sai da tabela (decisão da sessão principal, rodada 2).** Feriado de só parte do dia não entra. Lista em "Fora da tabela". Na rodada 1 tinha entrado Fortaleza, 24/06/2014 (a partir das 12h); saiu.
11. **Corpus Christi, ou outro móvel ou nacional do modelo, antecipado localmente (decisão da sessão principal, rodada 2):** a data antecipada entra como feriado local, se não coincidir com nacional ou móvel. A data original continua no calendário do modelo; a tabela local não mexe nela. Os casos estão em "Antecipações de feriados que estão no modelo".
12. **Feriados de eventos (rodada 2):** entra o dia declarado feriado por lei ou decreto municipal ou estadual. Ponto facultativo, expediente reduzido, "feriado escolar" e meio feriado ficam fora. Os atos do Rio (JMJ, Copa, Olimpíadas, G20) excluem do feriado o comércio de rua, bares, restaurantes, shoppings e hotéis, e alguns órgãos. Mesmo assim, são de dia inteiro e declaram feriado no município, por isso entraram.

## Tipos de fonte

- **P:** primária oficial (texto do ato em site oficial).
- **OS:** oficial secundária (órgão público que cita o ato: calendário de tribunal, decreto anual, notícia oficial).
- **S:** secundária não oficial (portal privado, imprensa, Wikipédia).

As URLs estão no CSV, linha a linha. Abaixo, o essencial por núcleo; os trechos literais da rodada 2 estão nos arquivos `_rodada2_achados_*.md`.

## Por núcleo

### São Paulo (UF): regras que valem para os 5 núcleos paulistas

| Feriado | Data | Ato | Vigência | Fonte |
|---|---|---|---|---|
| Revolução Constitucionalista (Data Magna) | 09/07 | Lei estadual 9.497/1997 | 2011–2024, exceto 2020 | OS (estudo da Alesp) |
| 9 de julho de 2020 transferido | 25/05/2020 | Lei estadual 17.264/2020 | 2020 | OS (ato do TCE-SP) |
| Dia Estadual da Consciência Negra | 20/11 | Lei estadual 17.746/2023 (vigor na publicação, 13/09/2023) | 2023 | OS (notícia oficial da Alesp) |

O repositório de leis da Alesp respondeu 503 durante toda a rodada 1; por isso as fontes são páginas oficiais que citam os atos.

### 3550308 São Paulo/SP

- **Aniversário da cidade, 25/01:** Lei municipal 7.008/1967, art. 1º, na redação da Lei 13.707/2004. Vigência 2011–2024, exceto 2022 (antecipado). Fonte P (Câmara).
- **Consciência Negra, 20/11:** Lei 13.707/2004; o STF a validou na ADPF 634, em 30/11/2022. Entra de 2011 a 2019. Em 2023 entra pela linha estadual. Em 2020–2022 foi antecipado; em 2024 é nacional.
- **Antecipações:**
  - 2020: Decreto 59.450/2020, autorizado pela Lei 17.341/2020. Corpus Christi foi para 20/05/2020 e a Consciência Negra para 21/05/2020 (P).
  - 2021: Decreto 60.131/2021. Corpus Christi e Consciência Negra de 2021, e aniversário, Corpus Christi e Consciência Negra de 2022, foram para 26, 29, 30 e 31/03 e 01/04/2021 (P).
  - Os Decretos 60.489/2021 e 61.006/2022 confirmam que as datas originais não foram feriado.
  - 22/05/2020 foi ponto facultativo e ficou fora.
- **Rodada 2, Copa de 2014:** 12/06/2014 (abertura na Arena Corinthians), Lei municipal 15.996/2014, art. 1º; a Lei 16.009/2014 tirou a exceção do comércio. Fonte P. Nos outros jogos em SP, a lei só suspende regras de trânsito; 19/06/2014 era Corpus Christi.
- **Contagem:** 45 datas.

### 3509502 Campinas/SP

- **Imaculada Conceição, 08/12:** Lei municipal 3.902/1970. O TRT-15 cita também a Lei 173/1949. Vigência 2011–2024.
- **Consciência Negra, 20/11:** Lei 11.128/2002. Entra em 2011–2019, 2021 e 2022; 2023 vai pela linha estadual; 2020 foi antecipado.
- **Antecipação de 2020:** Corpus Christi para 26/05/2020 e Consciência Negra para 27/05/2020, por lei oriunda do PL 117/2020. O número da lei não foi localizado; a fonte é a Portaria GP-CR 02/2020 do TRT-15.
- **Fontes:** OS (calendários do TRT-15); a Biblioteca Jurídica de Campinas não abriu o texto.
- **Contagem:** 42 datas.

### 3548500 Baixada Santista/SP (Santos)

- **Feriados:** 26/01 (Dia da Cidade), 08/09 (N. Sra. do Monte Serrat) e 20/11.
- **Ato:** Lei Orgânica, art. 245, com redação das Emendas 1/1991, 49/2006 e 53/2008. Fonte P (portal de legislação da Prefeitura).
- **Vigência do 20/11:** 2011–2022; 2023 vai pela linha estadual; 2024 saiu.
- **Pandemia:** não achei antecipação. Santos não está entre as comarcas que anteciparam Corpus Christi em 2020 (Comunicado TJSP 89/2020).
- **Contagem:** 55 datas.

### 3549904 São José dos Campos/SP

- **Aniversário, 27/07:** Lei municipal 1.324/1967. Vigência 2011–2024.
- **São José, 19/03:** Lei 8.821/2012, de 27/11/2012, "insuscetível de transferência". Vigência 2013–2024.
- **Fonte:** P (portal da Prefeitura). O PDF da Lei 1.324/1967 é digitalizado e o OCR lê "21 de julho"; os calendários do TRT-15 dão 27/07 para a mesma lei, e 27/07 é a data de fundação.
- **Fora:** não há 20/11 municipal. Não achei antecipação.
- **Contagem:** 41 datas.

### 3552205 Sorocaba/SP

- **Aniversário / N. Sra. da Ponte, 15/08:** Lei municipal 1.453/1967 (o TRT-15 de 2013 cita a Lei 2.616). Entra em 2011–2020, 2023 e 2024.
- **Consciência Negra, 20/11:** Lei 8.120/2007. Entra em 2011–2020; 2023 vai pela linha estadual.
- **Antecipação de 2021 (fonte trocada na rodada 2: agora P, Jornal do Município):** 31/03 e 01, 03, 05 e 06/04/2021 receberam, em bloco, Corpus Christi, aniversário e Consciência Negra de 2021 e aniversário e Consciência Negra de 2022.
  - Lei 12.288, de 29/03/2021 (JM 2.713), art. 2º, autorizou a antecipação por decreto.
  - Decreto 26.164, de 30/03/2021 (JM 2.714). A redação original incluía 04/04, retirado pelo Decreto 26.167/2021.
  - Decreto 26.394, de 04/10/2021, publicado no JM 2.858 de 05/11/2021. Deu a redação final e trocou o Corpus Christi de 2022 pela Consciência Negra de 2022. A rodada 1 datou esse decreto de 05/11/2021, que é a data da publicação.
  - Conflito: o calendário do TRT-15 para 2022 ainda lista 15/08/2022; segui o decreto.
- **Contagem:** 42 datas.

### 3304557 Rio de Janeiro/RJ

| Feriado | Data | Ato | Vigência | Fonte |
|---|---|---|---|---|
| Zumbi / Consciência Negra | 20/11 | Lei estadual 4.007/2002 (e Lei municipal 5.146/2010, art. 8º, IV) | 2011–2023 | P (ALERJ) |
| São Jorge | 23/04 | Lei estadual 5.198/2008 (STF, ADI 4.092: constitucional) e Lei municipal 5.146/2010, art. 8º, II | 2011–2024, exceto 2021 | S (Migalhas) para a estadual; P (Câmara) para a municipal |
| São Sebastião | 20/01 | Lei municipal 5.146/2010, art. 8º, I ("insuscetível de transferência") | 2011–2024 | **P (Câmara), trocada na rodada 2** |
| Feriados excepcionais (pandemia) | 26/03, 31/03 e 01/04/2021 | Lei estadual 9.224/2021, art. 1º | 2021 | P (DOERJ) |
| Tiradentes de 2021 antecipado | 29/03/2021 | Lei estadual 9.224/2021, art. 2º | 2021 | P |
| São Jorge de 2021 antecipado | 30/03/2021 | Lei estadual 9.224/2021, art. 2º | 2021 | P |
| JMJ 2013 | 25 e 26/07/2013 | Lei municipal 5.591/2013, art. 1º | 2013 | P (Câmara) |
| Copa de 2014 (Maracanã) | 25/06 e 04/07/2014 | Decreto 38.864/2014, art. 1º ("em horário integral"), com base na Lei 5.591/2013, art. 3º. Antes, o Decreto 38.365/2014 dava 04/07 inteiro e 25/06 só a partir das 12h, e o 38.838/2014 ampliou o 25/06 | 2014 | P (DO Rio de 24/06/2014); OS (notícias da Prefeitura) |
| Olimpíadas de 2016 | 05, 18 e 22/08/2016 | Decreto 41.867/2016, art. 1º, com base na Lei 5.924/2015, art. 3º | 2016 | P (DO Rio de 22/06/2016); OS (Nota AGU/PFE-INPI 203/2016) |
| Olimpíadas de 2016 (tocha) | 04/08/2016 | Decreto 42.073/2016, art. 1º, mesma base | 2016 | P (DO Rio de 03/08/2016) |
| Cúpula do G20 | 18 e 19/11/2024 | Lei municipal 8.314/2024, art. 1º (regulamentada pelo Decreto 55.200/2024) | 2024 | P (Câmara) |

- **20/01:** os calendários do TJRJ de 2020 a 2024 atribuem o feriado à Lei Orgânica do Município, art. 26 (texto não aberto). A data é a mesma.
- **23/04/2021 saiu, inclusive como municipal.** A Lei RJ 9.224/2021 levou São Jorge para 30/03/2021. A Lei municipal 5.146/2010 também faz o 23/04 feriado, mas há duas evidências de que o município seguiu a antecipação. A Resolução da Secretaria Municipal de Saúde de 19/04/2021 (DO Rio) trata 21 e 23/04/2021 como antecipados pela lei estadual, com feriado só para as unidades excluídas. E o TJRJ teve prazos vencendo em 23/04/2021.
- **Pandemia, município:** a base de leis da Câmara não tem lei de feriado de 2020 ou 2021.
- **Fora (eventos):**
  - Rio+20: a Lei 5.408/2012 criou só "feriados escolares" em 20–22/06/2012, e o Decreto 35.655/2012 deu ponto facultativo.
  - Copa das Confederações: em 20/06/2013, o Decreto 37.275/2013 deu feriado escolar parcial e ponto facultativo.
  - Meios feriados: JMJ, 23/07/2013 (a partir das 16h) e 29/07/2013 (até 12h); Copa, 18/06/2014 (a partir das 12h).
  - Paralimpíadas: nenhum feriado; 07/09/2016 é nacional.
  - Estado do RJ: ponto facultativo no G20 (Decreto 49.354/2024) e na Rio+20.
- **Contagem:** 55 datas.

### 3106200 Belo Horizonte/MG

- **Feriados:** 15/08 (Assunção de N. Sra.) e 08/12 (Imaculada Conceição), pela Lei municipal 1.327/1967. Vigência 2011–2024. Fonte OS (ato do TJMG de 2024 que cita a lei).
- **Rodada 2, Copa das Confederações:** 26/06/2013 (semifinal no Mineirão), Decreto municipal 15.247/2013. Fonte OS (comunicado do TRT-3); o texto no DOM não foi aberto. O estado de MG deu ponto facultativo.
- **Fora:**
  - MG não tem feriado estadual próprio: a Data Magna, 21/04, já é nacional.
  - Não há 20/11 antes de 2024.
  - O aniversário (12/12) não aparece como feriado.
  - Copa de 2014: só expediente reduzido (município) e ponto facultativo a partir das 12h (Decreto NE 163/2014 de MG).
- **Pandemia (rodada 2):** sem antecipação. O TJMG manteve o 15/08/2021; 08/12/2020 foi feriado normal.
- **Contagem:** 29 datas.

### 3205309 Vitória/ES (núcleo: Serra)

- **N. Sra. da Penha (Data Magna do ES):** Páscoa + 8 dias, pela Lei estadual 11.010/2019 (DO de 04/07/2019). Entra em 2020–2024. Fonte P (ALES).
- **Municipais da Serra:** 29/06 (São Pedro), 08/12 (N. Sra. da Conceição) e 26/12 (Dia do Serrano/São Benedito). Ato: Lei municipal 228/1967, consolidada pela Lei 4.950/2019. Vigência 2011–2024. Fonte OS (lista do TJES de 2024; calendários da Prefeitura).
- **Fora:** não há 20/11.
- **Pandemia (rodada 2):** sem antecipação achada, nem da Penha estadual (2020-04-20 e 2021-04-12 mantidas) nem dos municipais da Serra. O portal de legislação da Serra deu 503.
- **Atenção:** o código 3205309 é o do IBGE para Vitória. Se a covariável for de Vitória, e não da Serra, os feriados municipais são outros. Em 2021, Vitória antecipou Penha municipal, Corpus Christi e N. Sra. da Vitória para 30 e 31/03 e 01/04 (PL 57/2021; número da lei não achado; fonte S).
- **Contagem:** 47 datas.

### 5300108 Brasília/DF (esfera distrital = estadual)

- **Dia do Evangélico, 30/11:** Lei distrital 963/1995. Vigência 2011–2024. Fonte P (SINJ-DF).
- **Fora:**
  - 21/04, 12/10, Sexta da Paixão e Corpus Christi (Lei 72/1989): coincidem com nacional ou móvel. Os decretos anuais do GDF tratam Corpus Christi como ponto facultativo.
  - 20/11 sem lei distrital (ponto facultativo de 2020 a 2023).
  - Copa das Confederações: o único jogo foi num sábado (15/06/2013), sem ato. Copa de 2014: o Decreto DF 35.163/2014 (red. 35.437/2014) deu expediente até 12h e ponto facultativo.
- **Pandemia (rodada 2):** sem antecipação; 30/11/2020 e 30/11/2021 mantidos.
- **Alcance da Lei 963/1995:** ver dúvidas.
- **Contagem:** 14 datas.

### 2611606 Recife/PE

| Feriado | Data | Ato | Vigência | Fonte |
|---|---|---|---|---|
| Data Magna de PE | 1º domingo de março | Lei estadual 13.386/2007, red. Lei 13.835/2009 | 2011–2017 | P (ALEPE) |
| Data Magna de PE | 06/03 | Lei 16.059/2017, consolidada na Lei 16.241/2017, art. 49 | 2018–2024 (2019 saiu: Cinzas) | P (ALEPE) |
| São João | 24/06 | Lei municipal 9.777/1967 | 2011–2024 | P (portal da Prefeitura) |
| N. Sra. do Carmo | 16/07 | idem | 2011–2024 | P |
| N. Sra. da Conceição | 08/12 | idem | 2011–2024 | P |

- Não há 20/11 (a Lei 16.809/2002 do Recife só cria data comemorativa). Não achei antecipação.
- **Eventos (rodada 2):** os jogos foram na Arena Pernambuco, em São Lourenço da Mata. Copa das Confederações: sem ato de feriado do Recife ou de PE. Copa de 2014: ponto facultativo a partir das 12h (Recife) e ponto facultativo estadual (Decreto PE 40.755/2014, só em resultado de busca). Nada entrou.
- **Contagem:** 55 datas.

### 2927408 Salvador/BA

| Feriado | Data | Ato | Vigência | Fonte |
|---|---|---|---|---|
| Dois de Julho | 02/07 | Constituição da Bahia, art. 6º, § 3º | 2011–2024, exceto 2020 | P (Legisla Bahia) |
| Dois de Julho de 2020 | 25/05/2020 | Lei estadual 14.267/2020 | 2020 | P |
| São João de 2020 | 26/05/2020 | Lei estadual 14.267/2020 (e Decreto municipal 32.431/2020) | 2020 | P |
| São João | 24/06 | Lei municipal 1.997/1967 | 2011–2024, exceto 2020 | OS (TRF1-SJBA) |
| N. Sra. da Conceição da Praia | 08/12 | idem | 2011–2024, exceto 2020 | OS |
| Conceição da Praia de 2020 | 27/05/2020 | Decreto municipal 32.431/2020, art. 1º (Lei municipal 9.528/2020, art. 1º) | 2020 | **P (DOM Salvador 7.663, trocada na rodada 2)** |
| Copa das Confederações (Fonte Nova) | 20 e 22/06/2013 | Decreto municipal 24.009/2013 | 2013 | S (COAD) |

- Não há 20/11.
- **Copa de 2014:** sem feriado; só ponto facultativo (16 e 25/06) e expediente reduzido.
- **Contagem:** 44 datas.

### 2304400 Fortaleza/CE

| Feriado | Data | Ato | Vigência | Fonte |
|---|---|---|---|---|
| Data Magna do CE | 25/03 | Constituição do CE, art. 18, p.ú. (EC 73/2011, DOE de 06/12/2011) | 2012–2024 (2016 saiu: Sexta da Paixão) | P (DOE-CE) |
| São José | 19/03 | Lei municipal 8.796/2003 | 2011–2024 | P (SAPL da Câmara) |
| N. Sra. da Assunção | 15/08 | idem | 2011–2024, exceto 2020 | P |
| Corpus Christi e Assunção de 2020 antecipados | 27/05/2020 e 28/05/2020 | Lei municipal 11.005/2020 | 2020 | OS (Portaria TRT7 105/2020) |
| Copa das Confederações | 19/06/2013 e 27/06/2013 | Lei municipal 10.062/2013 | 2013 | P |
| Copa de 2014, jogos do Brasil | 17/06/2014 e 04/07/2014 | Lei municipal 10.216/2014, art. 1º | 2014 | P (lei); datas dos jogos: S (Wikipédia, Castelão) |

- A Lei 10.216/2014 só vale para dias úteis (seg–sex), por isso os jogos de 14/06, 21/06 e 29/06 ficaram fora.
- **Saiu na rodada 2:** 24/06/2014, feriado só a partir das 12h (Lei 10.216/2014, art. 2º), pela decisão 10.
- A consulta à base da Câmara por "feriado" não mostra lei de 20/11.
- **Contagem:** 45 datas.

### 4314902 Porto Alegre/RS

- **Revolução Farroupilha, 20/09:** Constituição do RS, art. 6º, parágrafo único (EC 11/1995). Vigência 2011–2024. Fonte P (ALERGS).
- **N. Sra. dos Navegantes, 02/02 ("e Iemanjá" desde 2023):** Lei municipal 3.033/1967, com redação da Lei 4.453/1978 e da Lei 13.591/2023. Vigência 2011–2024. Fonte P.
- **20/11 não entra:**
  - A Lei 11.971/2015 vigorou de 17/12/2015 até a ADI procedente no TJRS (07/11/2016), e nenhum 20/11 caiu nesse intervalo.
  - A Lei 9.252/2003 já tinha sido invalidada antes de 2011.
- **Copa de 2014 (rodada 2):** sem feriado; ponto facultativo para servidores.
- **Pandemia:** nada achado.
- **Contagem:** 28 datas.

### 4106902 Curitiba/PR

- **N. Sra. da Luz dos Pinhais, 08/09:** Lei municipal 3.015/1967. Vigência 2011–2024. Fonte OS (Decretos municipais 95/2024 e 190/2022).
- **19/12 do PR, fora (ver "Fora da tabela"):**
  - A Lei 4.658/1962 falava em "feriado estadual", mas o TRT-9 negou caráter de feriado civil, porque a data não é data magna (Lei 9.093/1995).
  - A Lei 18.384/2014 revogou a lei de 1962.
- **Copa de 2014 (rodada 2):** sem feriado. O Decreto 451/2014 deu expediente das 8h às 12h em 16, 23 e 26/06 e ponto facultativo em 20/06.
- **Pandemia (rodada 2):** sem antecipação. Em 23/03/2021 a Prefeitura disse que não anteciparia; o 08/09/2021 aparece como feriado no calendário do CHC-UFPR.
- **Contagem:** 14 datas.

### 4205407 Florianópolis/SC

- **11/08 (Dia do Estado) e 25/11 (Santa Catarina de Alexandria):** Lei estadual 10.306/1996, com redação das Leis 12.906/2004 e 13.408/2005, mantidas na consolidação da Lei 17.335/2017. Fonte P (ALESC).
- **Regra de data:** a lei diz que, quando a data coincidir "com dias úteis da semana", o feriado vai para o domingo seguinte. Adotei: de segunda a sexta, vai para o domingo seguinte; sábado e domingo ficam no próprio dia.
- **Rodada 2, municipal:** 23/03 (aniversário de emancipação política), Lei municipal 832/1967, art. 2º, b, na redação da Lei 3.247/1989. Vigência 2011–2024. Fonte P (texto e consolidação na base da Câmara, que tem "caráter meramente informativo"). O TRT-12 confirma que não há expediente na data.
- **Fora:**
  - 20/11 municipal (Lei 8.046/2009): a consolidação da Câmara registra que a Ação Direta de Inconstitucionalidade 2010.073591-5 "suspende os efeitos" da lei. Não achei a decisão final.
  - 15/08 e 08/12 constavam da redação de 1967 e saíram antes de 2011 (Leis 1.463/1976 e 3.247/1989).
- **Pandemia (rodada 2):** sem antecipação, estadual ou municipal.
- **Contagem:** 42 datas.

### 5208707 Goiânia/GO

- **Aniversário de Goiânia, 24/10:** Lei municipal 6.968/1991. Vigência 2011–2024. Fonte P (Sileg da Prefeitura).
- **Rodada 2, N. Sra. Auxiliadora, 24/05:** Lei municipal 701/1956. Vigência 2011–2024. Fonte OS (página da Prefeitura que lista os feriados com a lei; calendários da JF-GO de 2012 a 2022 e do TJGO de 2024). O texto da lei não foi aberto (o Sileg não tem a lei), e a data dela diverge entre páginas da Prefeitura (03/09/1956 ou 30/08/1956). A "lei de 1956 manuscrita" da imprensa é essa.
- **Fora:**
  - Feriados "estaduais" de GO (26/07, 24/10 e 28/10): estão no estatuto dos servidores (Lei 10.460/1988, art. 346; Lei 20.756/2020, art. 269), valem só para as repartições do Estado e foram transferidos por decreto em vários anos.
  - 30/10 (Dia dos Comerciários, mesma Lei 701/1956): feriado de categoria.
- **Contagem:** 28 datas.

### 1302603 Manaus/AM

| Feriado | Data | Ato | Vigência | Fonte |
|---|---|---|---|---|
| Elevação do Amazonas a Província | 05/09 | Lei Promulgada estadual 25/1977 (e Lei Orgânica de Manaus, art. 437, I) | 2011–2024 | P (ementa no SAPL da ALEAM) |
| Consciência Negra | 20/11 | Lei Promulgada estadual 84/2010 (e Lei municipal 188/2007) | 2011–2023 | P |
| N. Sra. da Conceição | 08/12 | Lei municipal 496/1999 | 2011–2024 | P (SAPL da Câmara) |
| Elevação de Manaus a Cidade (aniversário) | 24/10 | **Lei Orgânica de Manaus, art. 437, II (regulamentado pela Lei 101/1991); rodada 2** | 2011–2024 | P (SAPL da Câmara) |

- **2020–2021 (rodada 2):** a suspensão da Lei 2.660/2020 dependia do fim do decreto de calamidade, e não alcançou 2020. 08/12/2020 e 08/12/2021 foram mantidos (2021 confirmado por portaria da UFAM). Não achei ato que suspendesse o 24/10 em 2020 ou 2021. A Quarta de Cinzas de 2021 foi suspensa (ver "Antecipações de feriados que estão no modelo").
- **Copa de 2014:** ponto facultativo nos dias de jogo; nada entrou.
- **Contagem:** 55 datas.

### 1501402 Belém/PA

- **Adesão do Pará à Independência, 15/08:** Lei estadual 5.999/1996. Vigência 2011–2024. Fonte P (banco de leis da ALEPA). Os decretos estaduais de 2020 e 2021 mantêm o 15/08.
- **Rodada 2, N. Sra. da Conceição, 08/12:** Lei municipal 6.306/1967. Vigência 2011–2024. Fonte OS (Portarias SJPA-Diref 15/2023 e 11/2024; Decreto estadual PA 1.445/2015 cita a lei). O texto da lei não foi aberto.
- **Fora:**
  - 12/01 (aniversário da cidade): ponto facultativo, não feriado. As portarias da SJPA não o listam, e a Lei Orgânica não o institui.
  - Círio (sempre domingo) e segunda-feira do Recírio: ponto facultativo.
  - 20/11: sem lei municipal.
  - COP30 (06 e 07/11/2025, Lei 10.212/2025): fora do período.
- **Pandemia:** sem antecipação (Portaria SJPA de 2021).
- **Contagem:** 28 datas.

### 2111300 São Luís/MA

| Feriado | Data | Ato | Vigência | Fonte |
|---|---|---|---|---|
| Adesão do MA à Independência | 28/07 | Lei estadual 2.457/1964 | 2011–2024, exceto 2020 | OS (TRF1-SJMA) |
| 28 de julho de 2020 antecipado | 15/05/2020 | Medida Provisória estadual 313/2020 ("exclusivamente" em 2020) | 2020 | OS (TJMA) |
| Consciência Negra | 20/11 | Lei estadual 10.747/2017 | só 2018 (ADI procedente no TJMA em 2019) | OS (notícia do TJMA) |
| São Pedro | 29/06 | Lei municipal 3.432/1996 | 2011–2024 | OS (TRF1-SJMA) |
| Fundação de São Luís / Natividade | 08/09 | idem | 2011–2024 | OS |
| N. Sra. da Conceição | 08/12 | idem | 2011–2024 | **OS (UFMA, 07/12/2020: "feriado municipal [...] Lei Ordinária 3432/1996"), trocada na rodada 2** |

- Os decretos anuais de calendário da Prefeitura (2025 e 2026, no DOM) também listam o 08/12 como feriado municipal.
- A Portaria PRESI 952/2022 do TRF1 (OS) diz que a Lei 3.432 define o 08/12 como feriado municipal, mas a data "06 de fevereiro de 2006". As outras fontes dizem 06/02/1996, e em 2006 as leis de São Luís estavam na faixa dos 4.600; deve ser erro de digitação.
- O texto da Lei 3.432/1996 não foi aberto.

**Contagem:** 57 datas.

### 2211001 Teresina/PI

| Feriado | Data | Ato | Vigência | Fonte |
|---|---|---|---|---|
| Dia do Piauí | 19/10 | Lei estadual 176/1937 | 2011–2024, exceto 2020 e 2021 | OS (Decreto PI 22.663/2024) |
| Dia do Piauí de 2020 antecipado | 15/05/2020 | Lei estadual 7.371/2020 | 2020 | **OS (TJPI, Portaria 1.020/2020), trocada na rodada 2** |
| Dia do Piauí de 2021 antecipado | 18/03/2021 | Lei estadual 7.490/2021 | 2021 | OS (TJPI); rodada 2 |
| N. Sra. Aparecida de 2021 antecipada | 26/03/2021 | Lei estadual 7.491/2021 | 2021 | OS (TJPI); rodada 2 |
| Corpus Christi de 2021 antecipado | 30/03/2021 | Lei estadual 7.491/2021 | 2021 | OS (TJPI); rodada 2 |
| N. Sra. da Conceição | 08/12 | Lei municipal 2.275/1994, art. 1º, § 1º (red. Lei 2.847/1999) | 2011–2024, exceto 2020 | OS (compilação de leis no site da SJPI); trocada na rodada 2 |
| Conceição de 2020 antecipada | 22/05/2020 | Lei municipal 5.519/2020 | 2020 | OS (TJPI); trocada na rodada 2 |
| Aniversário de Teresina | 16/08 | Lei municipal 2.275/1994, art. 1º, § 1º (red. Lei 2.847/1999) | 2011–2019 e 2022–2024 | OS (compilação no site da SJPI); rodada 2 |
| Aniversário de 2020 antecipado | 17/04/2020 | Lei municipal 5.510/2020 | 2020 | OS (TJPI); rodada 2 |
| Corpus Christi de 2020 antecipado | 29/05/2020 | Lei municipal 5.523/2020 | 2020 | OS (TJPI); rodada 2 |
| Aniversário de Teresina de 2021 antecipado | 31/03/2021 | Lei municipal 5.573/2021 | 2021 | OS (portaria do MPF) |

- **Saiu na rodada 2:** 19/10/2021 (o Dia do Piauí de 2021 foi para 18/03/2021).
- **Fora:** pontos facultativos estaduais de 19/03, 29/03 e 01/04/2021. Também as transferências só internas: Dia do Piauí de 2022 para 21/10 no TJPI e 16/08/2023 para 14/08 no TRE-PI.
- O texto das Leis 5.510/2020, 5.523/2020, 7.490/2021 e 7.491/2021 não foi aberto; a fonte é o TJPI, que cita cada lei.
- **Contagem:** 45 datas.

### 2704302 Maceió/AL

| Feriado | Data | Ato | Vigência | Fonte |
|---|---|---|---|---|
| São João | 24/06 | Lei estadual 5.508/1993 | 2011–2024 | P (SAPL da ALE-AL) |
| São Pedro | 29/06 | Lei estadual 5.509/1993 | 2011–2024 | P |
| Emancipação Política de AL | 16/09 | decretos estaduais anuais de feriados; **lei instituidora não localizada** | 2011–2023 | OS (notícia oficial da Prefeitura com a lista de 2023); anos anteriores só em decretos vistos em portal privado |
| Emancipação Política de AL | 16/09 | Lei estadual 9.358/2024 | 2024 | P |
| Zumbi dos Palmares | 20/11 | Lei estadual 5.724, de 01/08/1995 | 2011–2023 | **OS (JFAL), trocada na rodada 2** |
| N. Sra. dos Prazeres | 27/08 | Lei municipal 1.391, de 16/05/1967 | 2011–2024 | **OS (JFAL), trocada na rodada 2** |
| N. Sra. da Conceição | 08/12 | Lei municipal 1.391/1967 | 2011–2024 | **OS (Decreto municipal 10.234/2025, no DOM de Maceió, que cita a lei), trocada na rodada 2** |

- **16/09 de 2011 a 2023 (rodada 2):** nenhuma das leis que os decretos anuais citam trata da data. A 5.247/1991 é o regime jurídico dos servidores e só traz o 28/10; a 5.508 e a 5.509/1993 são o 24/06 e o 29/06; a 5.724/1995 é o 20/11. A Constituição de AL também não traz o feriado. A data aparece como "feriado estadual" nos decretos anuais e foi formalizada pela Lei 9.358/2024. **Mantive as 13 datas**, mas é caso de decisão (ver dúvidas): pela regra, sem lei não entraria.
- Os textos da Lei 5.724/1995 (não está no SAPL da ALE-AL) e da Lei municipal 1.391/1967 (a Câmara não tem SAPL acessível) não foram abertos.
- **Fora:** 30/11 (Dia Estadual do Evangélico). Os decretos municipais de 2023 e de 2026 o listam como "feriado estadual" pela Lei 7.530/2013, mas o art. 2º da lei, que criava o feriado, foi vetado, e não achei a promulgação depois da derrubada do veto.

**Contagem:** 83 datas.

### 2800308 Aracaju/SE

| Feriado | Data | Ato | Vigência | Fonte |
|---|---|---|---|---|
| Emancipação Política de SE | 08/07 | Constituição de SE, art. 269 (redação da EC 20/2000) | 2011–2024, exceto 2020 | **P (Constituição no portal do Governo de SE), trocada na rodada 2** |
| Emancipação de 2020 antecipada | 22/05/2020 | Lei estadual 8.679/2020 | 2020 | OS (portaria da JFSE de 21/09/2020, cópia hospedada no site da OAB-SE); rodada 2 |
| Aniversário de Aracaju | 17/03 | Lei municipal 1.358/1988 (red. Leis 2.899/2001 e 3.805/2009) | 2011–2024 | P (ementa no SAPL da Câmara) |
| N. Sra. da Conceição | 08/12 | idem | 2011–2024 | P (ementa) |
| São João | 24/06 | Lei municipal 3.805/2009 | 2011–2024, exceto 2020 | P (ementa) |
| São João de 2020 antecipado | 25/05/2020 | Lei municipal 5.310/2020 | 2020 | P (ementa) |

- **Saiu na rodada 2:** 08/07/2020.
- O texto da Lei SE 8.679/2020 não foi aberto; a portaria da JFSE a cita como base da antecipação.
- O SAPL antigo da Câmara (IP 190.15.122.10) foi aberto por um subagente na rodada 1 e deu 503 na minha conferência.
- **Contagem:** 56 datas.

### 2507507 João Pessoa/PB

| Feriado | Data | Ato | Vigência | Fonte |
|---|---|---|---|---|
| Fundação do Estado (Data Magna) | 05/08 | Lei estadual 10.601/2015 (pub. 17/12/2015) | 2016–2024, exceto 2021 | P (SAPL da ALPB) |
| Feriado excepcional; 21/04, Corpus Christi e 05/08 de 2021 antecipados | 29/03, 30/03, 31/03 e 01/04/2021 | Lei estadual 11.952/2021 (MP 295, de 24/03/2021) | 2021 | P |
| São João | 24/06 | Lei municipal 8.805/1999 (altera a Lei 796/1967) | 2011–2024 | P (SAPL da Câmara) |
| N. Sra. das Neves | 05/08 | idem | 2011–2024 (estadual a partir de 2016) | P |
| N. Sra. da Conceição | 08/12 | idem | 2011–2024 | P |

O 20/11 em JP é só data comemorativa (Leis 6.312/1989 e 9.895/2002). A PB não teve 20/11 estadual até 2025. **Contagem:** 46 datas.

### 2408102 Natal/RN

| Feriado | Data | Ato | Vigência | Fonte |
|---|---|---|---|---|
| Mártires de Cunhaú e Uruaçu | 03/10 | Lei estadual 8.913/2006, art. 1º (DOE de 07/12/2006) | 2011–2024, exceto 2020 | **P (ALRN), trocada na rodada 2** |
| Mártires de 2020 antecipado | 12/06/2020 | Decreto estadual 29.752/2020, art. 1º, autorizado pela Lei estadual 10.729/2020, art. 1º | 2020 | P (DOE-RN de 11/06/2020); rodada 2 |
| Santos Reis | 06/01 | Lei municipal 1.617/1967, art. 1º, a | 2011–2024 | P (SAPL da Câmara) |
| N. Sra. da Apresentação | 21/11 | idem, art. 1º, d | 2011–2024 | P |
| Consciência Negra | 20/11 | Lei municipal 6.458/2014 (DOM de 29/04/2014) | 2014–2023 | P |

- **Saiu na rodada 2:** 03/10/2020.
- A Lei 10.729/2020 permitia antecipar "anualmente"; não achei antecipação em 2021, e o calendário de 2021 da Prefeitura de Natal mantém 03/10.
- **Copa de 2014:** ponto facultativo; o SAPL não tem lei de feriado em dia de jogo.
- **Contagem:** 52 datas.

### 5103403 Cuiabá/MT

- **Consciência Negra, 20/11:** Lei estadual 7.879/2002. Vigência 2011–2023. Fonte P (ALMT).
- **Rodada 2, Fundação de Cuiabá, 08/04:** Lei municipal 1.077/1968, art. 1º. Vigência 2011–2024. Fonte P (base de legislação da Câmara).
- **Rodada 2, Imaculada Conceição, 08/12:** Lei municipal 5.576/2012, art. 1º, de 24/08/2012, em vigor na publicação. Vigência 2012–2024. Fonte P (texto promulgado, no site da Prefeitura).
  - Histórico: o 08/12 era feriado pela Lei 1.077/1968. A Lei 4.672/2004 (GM 714, 03/12/2004) o transformou em ponto facultativo, e a Lei 5.576/2012 o devolveu. Por isso 08/12/2011 fica fora.
  - A CDL entrou com ADI no TJMT em 2012, que negou a liminar (resultado de busca; a notícia do TJMT deu erro 500). A Câmara registra a lei como "Em Vigor", e os decretos anuais da Prefeitura (2015, 2021, 2023) listam o 08/12 como feriado municipal.
- **Fora:** Corpus Christi e Sexta da Paixão (Lei 1.077/1968): móveis. Copa de 2014: ponto facultativo e expediente reduzido (Decreto MT 2.057/2013).
- **Pandemia:** sem antecipação achada; o decreto de calendário de 2021 mantém 08/04.
- **Contagem:** 40 datas.

### 5002704 Campo Grande/MS

- **Criação do Estado, 11/10:** Lei estadual 10/1979. Vigência 2011–2024. Fonte P (base de legislação do governo de MS).
- **20/11 estadual fora:** a Lei 3.958/2010 foi declarada inconstitucional pelo TJMS (ADI 2010.035531-5) e revogada em 2017; a data da decisão não foi localizada.
- **Rodada 2, municipais** (fonte OS, calendário do TRT-24, que cita as leis; textos não abertos):
  - Santo Antônio (padroeiro), 13/06: Lei municipal 3.901/2001.
  - Aniversário de Campo Grande, 26/08: Lei municipal 1.019/1967.
  - Vigência dos dois: 2011–2020, 2023 e 2024.
- **Rodada 2, antecipação de 2021:** 22, 23, 24 e 25/03/2021 receberam, em bloco, 13/06 e 26/08 de 2021 e de 2022.
  - Ato: Decreto municipal 14.683/2021, art. 3º, autorizado pela Lei municipal 6.568/2021, art. 1º.
  - Fonte S: cópia do DIOGRANDE extra 6.240, de 19/03/2021, num site privado; o DIOGRANDE oficial deu erro 500.
  - Saem 13/06 e 26/08 de 2021 e de 2022. A Agência Brasil e o Campo Grande News confirmam que o 13/06/2022 foi dia normal.
- **Fora:** 20/11 municipal (sem lei achada). As "transferências" do 13/06 pelo Governo de MS (por exemplo, em 2017) valem só para os órgãos estaduais.
- **Contagem:** 42 datas.

## Antecipações de feriados que estão no modelo

Nestes núcleos e anos, uma lei local (ou decreto autorizado por lei) antecipou um feriado nacional ou móvel que o calendário do modelo marca. A data antecipada está na tabela local (decisão 11). A data original continua no modelo, mas localmente não foi feriado.

| Núcleo | Data do modelo que localmente não foi feriado | Data local que entrou | Ato |
|---|---|---|---|
| São Paulo | Corpus Christi 2020 (11/06/2020) | 20/05/2020 | Decreto 59.450/2020 (Lei 17.341/2020) |
| São Paulo | Corpus Christi 2021 (03/06/2021) e 2022 (16/06/2022) | bloco de 26/03 a 01/04/2021 | Decreto 60.131/2021 (Lei 17.341/2020) |
| Campinas | Corpus Christi 2020 | 26/05/2020 | lei oriunda do PL 117/2020 |
| Sorocaba | Corpus Christi 2021 | bloco de 31/03 a 06/04/2021 | Decreto 26.164/2021, red. 26.394/2021 (Lei 12.288/2021) |
| Fortaleza | Corpus Christi 2020 | 27/05/2020 | Lei 11.005/2020 |
| João Pessoa (PB) | Tiradentes 2021 (21/04) e Corpus Christi 2021 | 30/03 e 31/03/2021 | Lei PB 11.952/2021 |
| Rio de Janeiro (RJ) | Tiradentes 2021 (21/04) | 29/03/2021 | Lei RJ 9.224/2021, art. 2º (rodada 2) |
| Teresina | Corpus Christi 2020 (11/06/2020) | 29/05/2020 | Lei municipal 5.523/2020 (rodada 2) |
| Teresina (PI) | N. Sra. Aparecida 2021 (12/10) e Corpus Christi 2021 (03/06) | 26/03 e 30/03/2021 | Lei PI 7.491/2021 (rodada 2) |
| Manaus | Quarta de Cinzas 2021 (17/02/2021), suspensa, sem data nova | — | Decreto 5.025/2021, autorizado pela Lei 2.660/2020 (rodada 2) |

- **Manaus, Carnaval de 2021:** suspenso pelo Decreto 5.023/2021, segundo resultado de busca. Não conferido.
- **Corrigir o calendário nacional e móvel do modelo é decisão de método.** A tabela local não mexe nele.

## Fontes secundárias (S) que ficaram

Na rodada 2, a fonte oficial (P ou OS) substituiu a secundária em todos os itens da lista da rodada 1:

- P: Rio 20/01; Aracaju 08/07; Natal 03/10; Sorocaba 2021; Salvador, Conceição da Praia de 2020.
- OS: Teresina 08/12, 22/05/2020 e 15/05/2020; Maceió 20/11, 27/08 e 08/12; São Luís 08/12.

Ficaram com fonte secundária, por não haver fonte oficial acessível:

| Núcleo | Datas | Fonte | Observação |
|---|---|---|---|
| Rio de Janeiro | 23/04 estadual (Lei RJ 5.198/2008) | Migalhas | não estava na lista; coberto também pela Lei municipal 5.146/2010, art. 8º, II (P) |
| Salvador | 20 e 22/06/2013 (Copa das Confederações) | COAD | Decreto 24.009/2013; o DOM de 18/06/2013 não foi aberto (linha nova da rodada 2) |
| Campo Grande | 22 a 25/03/2021 | cópia do DIOGRANDE em site privado | o documento é o diário oficial; o site oficial deu erro 500 (linha nova da rodada 2) |
| Maceió/AL | 16/09 de 2011 a 2022 | decretos estaduais anuais vistos só em portal privado | a URL do CSV é OS (lista oficial de 2023); o problema maior é a falta de lei (ver dúvidas) |
| Fortaleza | datas dos jogos de 2014 | Wikipédia | o ato (Lei 10.216/2014) é P |

Fontes oficiais que são cópias ou compilações, e não o diário oficial: Florianópolis 23/03 (consolidação da Câmara, de "caráter meramente informativo"); Teresina 08/12 e 16/08 (compilação de leis hospedada pela SJPI); Aracaju 22/05/2020 (portaria da JFSE, cópia no site da OAB-SE).

## Fora da tabela

### Meios feriados (decisão 10)

| Núcleo | Data | Ato |
|---|---|---|
| Fortaleza | 24/06/2014, a partir das 12h | Lei municipal 10.216/2014, art. 2º |
| Rio de Janeiro | 23/07/2013, a partir das 16h; 29/07/2013, até 12h (JMJ) | Lei municipal 5.591/2013, art. 1º |
| Rio de Janeiro | 18/06/2014, a partir das 12h (Copa) | Decreto Rio 38.365/2014 |

### Eventos: ponto facultativo, expediente reduzido ou feriado só escolar

- **Rio:**
  - Rio+20, 20–22/06/2012: "feriados escolares" pela Lei 5.408/2012 e ponto facultativo pelo Decreto 35.655/2012.
  - Copa das Confederações, 20/06/2013: feriado escolar parcial e ponto facultativo (Decreto 37.275/2013).
  - Estado do RJ: ponto facultativo na Rio+20 e no G20.
- **Brasília:** Copa de 2014, expediente até 12h e ponto facultativo (Decretos DF 35.163 e 35.437/2014).
- **BH:** Copa de 2014, expediente reduzido; MG, ponto facultativo.
- **Recife e PE:** Copa de 2014, ponto facultativo.
- **Salvador:** Copa de 2014, ponto facultativo e expediente reduzido.
- **Natal, Manaus, Cuiabá (e MT), Curitiba e Porto Alegre:** Copa de 2014, ponto facultativo ou expediente reduzido.

### Outros fora por decisão de borda (ambíguos ou não são feriado de lei geral)

- **PR, 19/12, 2011–2013:**
  - A Lei 4.658/1962 dizia "feriado estadual", mas o TRT-9 (5ª Turma, 24/11/2015) negou caráter de feriado civil, porque a data não é data magna (Lei 9.093/1995, art. 1º, II).
  - A Lei 18.384/2014 revogou a de 1962 antes de 19/12/2014; desde então a data é ponto facultativo.
  - Se preferir seguir a letra da lei, acrescente 2011-12-19, 2012-12-19 e 2013-12-19 em Curitiba.
- **GO:** 26/07, 24/10 e 28/10 são feriados do serviço público estadual (estatuto), com transferências por decreto (2012, 2014–2024).
- **AL, 30/11 (Dia do Evangélico):**
  - O art. 2º da Lei 7.530/2013, que criava o feriado, foi vetado. O veto foi derrubado em 2014, mas não achei a promulgação.
  - Os decretos estaduais listam a data desde 2018, para o serviço público. O comércio abre.
- **DF, 20/11:** ponto facultativo por decreto (2020–2023), sem lei.
- **MS, 20/11 (Lei 3.958/2010):** declarada inconstitucional.
- **Florianópolis, 20/11 (Lei 8.046/2009):** efeitos suspensos pela ADI 2010.073591-5 (rodada 2).
- **Cuiabá, 08/12/2011:** ponto facultativo pela Lei 4.672/2004 (rodada 2).
- **Belém:** 12/01, Círio e Recírio são ponto facultativo (rodada 2).
- **São Luís, 20/11:** a Lei municipal "309/2013" foi declarada inconstitucional na ADI 54.567/2013 do TJMA; vigência desconhecida.
- **MA, 20/11/2019:** suspenso; ADI procedente em outubro de 2019.
- **MA, 2015:** decreto administrativo "antecipou" o 28/07 para 27/07/2015, só para o serviço público. Mantive 28/07/2015.
- **Maceió, 2021:** o 29/06 municipal foi transferido por decreto para 28/06/2021; o 29/06 estadual (São Pedro) foi mantido. 28/06/2021 ficou fora. Em 2022, a transferência para 27/06 só apareceu em resultado de busca.
- **PI e Teresina, atos internos:** Dia do Piauí de 2022 para 21/10 (TJPI) e 16/08/2023 para 14/08 (TRE-PI). Mantidas as datas de lei.
- **Pontos facultativos (todos fora):** Dia do Servidor (28/10), Quinta-feira Santa, Recírio (PA), pontes, Carnaval e Cinzas em vários estados, 24 e 31/12; PI em 19/03, 29/03 e 01/04/2021.
- **Feriados de categoria (fora):**
  - Natal: 06/09, Dia do Alfaiate, Lei 3.958/1990;
  - Fortaleza: 28/10 para o comércio, Lei 6.225/1987;
  - Aracaju: 28/08, bancário;
  - Goiânia: 30/10, Dia dos Comerciários;
  - PB: bancários.

## Plano B: o que continua sem ato

Os quatro casos do plano B da rodada 1 (Goiânia 24/05, Cuiabá 08/04 e 08/12, Teresina 16/08 e Manaus 24/10) tiveram o ato achado e entraram. Continuam sem ato localizável, e fora da tabela:

| Núcleo | Data / feriado | O que achei |
|---|---|---|
| Maceió (AL) | 30/11, Dia Estadual do Evangélico | Os decretos de feriados de Maceió (2023 e 2026) o listam como "feriado estadual" pela Lei 7.530/2013. O art. 2º, que criava o feriado, foi vetado. O veto foi derrubado em 2014, mas a promulgação não foi achada (nem no SAPL da ALE-AL) |
| Vitória (só se a covariável for de Vitória) | antecipação de 2021 (30/03 a 01/04) | PL 57/2021 aprovado pela Câmara de Vitória; número da lei não achado; fonte S. A tabela segue com a Serra |

Na tabela, mas sem lei instituidora achada: AL, 16/09 de 2011 a 2023 (13 datas em Maceió; ver dúvida 6).

## Dúvidas que sobraram

1. **SC, sábado:** quando 11/08 ou 25/11 cai num sábado (11/08 em 2012 e 2018; 25/11 em 2017 e 2023), mantive o sábado. Se "dia útil da semana" incluir o sábado, a data passa para o domingo seguinte.
2. **DF, alcance da Lei 963/1995 (30/11):**
   - O SINJ traz "feriado no âmbito do Distrito Federal".
   - O TJDFT (notícia de 26/11/2020) diz que a lei instituiu feriado só "no âmbito da Administração direta, indireta, autárquica e fundacional do Distrito Federal", e que o comércio abre.
   - Mantive as 14 datas. Pela decisão 5, sairiam se a leitura do TJDFT prevalecer.
3. **Rio, Lei municipal 3.572/2003 ("Antecipa a comemoração dos feriados municipais", em vigor):** o texto não foi aberto. A Lei 5.146/2010, posterior, diz que o 20/01 é "insuscetível de transferência". Não sei se a 3.572 desloca outros feriados municipais para segunda-feira.
4. **Natal, 20/11 municipal (2014–2023):** o calendário de 2021 da Prefeitura não lista 20/11/2021, um sábado. Não achei contestação judicial da Lei 6.458/2014, e mantive as datas.
5. **João Pessoa, 05/08/2021:** o estado antecipou o seu 05/08 para 01/04/2021, mas o feriado municipal (Lei 8.805/1999) foi mantido na tabela. A Lei municipal 14.224/2021 permitiu ao Executivo cancelar feriados na pandemia; nenhum ato foi achado. É o caso parecido com o do Rio em 23/04/2021, onde houve evidência de que o município seguiu a antecipação; em JP não achei evidência.
6. **AL, 16/09 de 2011 a 2023 (decisão pendente):** a rodada 2 confirmou que nenhuma lei estadual anterior a 2024 institui a data; ela vem dos decretos anuais de feriados do governo. A Lei 9.358/2024 formalizou a data como feriado pela Lei 9.093/1995. Mantive as 13 datas, porque a data era observada como feriado estadual e o pedido manda manter quando falta fonte oficial. Pela decisão 5 e pela exigência de lei, sairiam. Além disso, uma liminar do TRT-19 (2020, um único mandado de segurança) afastou 24 e 29/06 para fins trabalhistas; mantive as datas.
7. **Campinas, 08/12:** o número da lei diverge entre fontes oficiais (3.902/1970 ou 173/1949). A data é a mesma.
8. **Goiânia, Lei 701/1956:** data da lei divergente entre páginas da Prefeitura (03/09 ou 30/08/1956); texto não aberto.
9. **Cuiabá, 08/12:** desfecho final da ADI de 2012 não localizado; a lei está "Em Vigor" na Câmara e a data é observada.
10. **Florianópolis, 20/11:** desfecho final da ADI 2010.073591-5 não localizado. Fica fora pela anotação de suspensão.
11. **Atos com texto não aberto, citados por órgão público:** Belém (Lei 6.306/1967), Campo Grande (Leis 3.901/2001 e 1.019/1967), Teresina (Leis 5.510/2020, 5.523/2020, 7.490/2021 e 7.491/2021), Aracaju (Lei SE 8.679/2020), BH (Decreto 15.247/2013), São Luís (Lei 3.432/1996), Maceió (Leis 5.724/1995 e 1.391/1967), Goiânia (Lei 701/1956).
12. **Feriados de evento com exclusões setoriais (Rio):** os atos da JMJ, da Copa de 2014, das Olimpíadas e do G20 mantêm abertos o comércio de rua, bares, restaurantes, shoppings, hotéis e serviços essenciais. Entraram pela decisão 12. Se a covariável dever captar só fechamento geral, essas 10 datas do Rio são as candidatas a sair.

## Contagem de datas por núcleo (1.130 no total)

| CD_RECORTE | Núcleo | Rodada 1 | Rodada 2 | Diferença | Estaduais | Municipais |
|---|---|---|---|---|---|---|
| 1302603 | Manaus | 41 | 55 | +14 | 27 | 28 |
| 1501402 | Belém | 14 | 28 | +14 | 14 | 14 |
| 2111300 | São Luís | 57 | 57 | +0 | 15 | 42 |
| 2211001 | Teresina | 29 | 45 | +16 | 16 | 29 |
| 2304400 | Fortaleza | 46 | 45 | -1 | 12 | 33 |
| 2408102 | Natal | 52 | 52 | +0 | 14 | 38 |
| 2507507 | João Pessoa | 46 | 46 | +0 | 12 | 34 |
| 2611606 | Recife | 55 | 55 | +0 | 13 | 42 |
| 2704302 | Maceió | 83 | 83 | +0 | 55 | 28 |
| 2800308 | Aracaju | 56 | 56 | +0 | 14 | 42 |
| 2927408 | Salvador | 42 | 44 | +2 | 15 | 29 |
| 3106200 | Belo Horizonte | 28 | 29 | +1 | 0 | 29 |
| 3205309 | Serra | 47 | 47 | +0 | 5 | 42 |
| 3304557 | Rio de Janeiro | 41 | 55 | +14 | 31 | 24 |
| 3509502 | Campinas | 42 | 42 | +0 | 15 | 27 |
| 3548500 | Santos | 55 | 55 | +0 | 15 | 40 |
| 3549904 | São José dos Campos | 41 | 41 | +0 | 15 | 26 |
| 3550308 | São Paulo | 44 | 45 | +1 | 15 | 30 |
| 3552205 | Sorocaba | 42 | 42 | +0 | 15 | 27 |
| 4106902 | Curitiba | 14 | 14 | +0 | 0 | 14 |
| 4205407 | Florianópolis | 28 | 42 | +14 | 28 | 14 |
| 4314902 | Porto Alegre | 28 | 28 | +0 | 14 | 14 |
| 5002704 | Campo Grande | 14 | 42 | +28 | 14 | 28 |
| 5103403 | Cuiabá | 13 | 40 | +27 | 13 | 27 |
| 5208707 | Goiânia | 14 | 28 | +14 | 0 | 28 |
| 5300108 | Brasília | 14 | 14 | +0 | 14 | 0 |
| | **Total** | **986** | **1130** | **+144** | **401** | **729** |

## Decisões da sessão principal sobre as dúvidas (19/10/2026, A1-110)

- **DF, 30/11 (Lei 963/1995): sai** pela decisão 5. O TJDFT lê a lei como feriado só da administração distrital, com o comércio aberto. As 14 datas saem, e Brasília fica sem feriado local, porque os demais feriados distritais coincidem com nacionais ou móveis. A tabela passa de 1.130 para 1.116 linhas. A cópia da rodada 2, antes da mudança, está em `feriados_locais_nucleo_2011_2024_rodada2.csv` (SHA-256 `57757b48b04f308bd5b8ce3ebca6bd7a6fd25316da3a18fbc4322896f077e01d`). A linha está comentada no gerador.
- **AL, 16/09 de 2011 a 2023: fica (decisão revista na A1-112; ver abaixo).** A data foi declarada feriado estadual pelos decretos anuais do governo e observada como tal. A decisão 12 aceita decreto que declara feriado; a decisão 6 trata de transferência, não de criação. Limitação: não há lei estadual antes da Lei 9.358/2024.
- **Rio, feriados de eventos (JMJ, Copa, Olimpíadas, G20): ficam.** São de dia inteiro e declaram feriado no município. A exclusão de setores do comércio não os torna meio feriado. Limitação: o fechamento é parcial.
- **Florianópolis, 20/11: fora**, enquanto o desfecho da ADI 2010.073591-5 não for achado.
- **Maceió, 30/11: fora**, sem a promulgação depois da derrubada do veto.
- **Vitória × Serra:** a covariável é a da cidade-núcleo (Serra). As antecipações de Vitória não entram.
- **Demais dúvidas (SC no sábado; Rio, Lei 3.572/2003; Natal, 20/11; João Pessoa, 05/08/2021; Campinas; Goiânia; Cuiabá, 08/12):** ficam como a rodada 2 deixou.

## Auditoria por amostra e decisões finais (19/10/2026, A1-112)

- **Auditoria independente** (amostra de 80 linhas sorteada com semente 20261001: 50 da rodada 2 e 30 da rodada 1; checagens por código na tabela inteira; busca de omissões em Belém, Recife, São José dos Campos, Curitiba e Goiânia). Resultado: 63 linhas confirmadas, 15 confirmadas com ressalva, 2 não confirmadas (Maceió, 16/09 de 2016 e de 2019) e 0 erradas. As checagens por código passaram. Nenhuma omissão de feriado observado.
- **AL, 16/09 de 2011 a 2023: sai** (revê a A1-110, item 2). A auditoria achou o critério incoerente: os decretos anuais listam o 16/09 e o 30/11 lado a lado como "feriado estadual", e só um tinha ficado. Critério único, o mesmo do 30/11 do DF: feriado criado só por decreto do Executivo, sem lei, vale só para o serviço público e fica fora pela decisão 5. Saem as 13 datas de 2011 a 2023. Fica o de 2024, da Lei 9.358, de 26/08/2024. O 30/11 de AL continua fora. A tabela passa de 1.116 para 1.103 linhas. A cópia anterior está em `feriados_locais_nucleo_2011_2024_A1-110.csv` (SHA-256 `8af8fea3054c69139dcc8f83269f8a53e8c57aefd81041184eda4dfc7afef223`). O bloco está comentado no gerador.
- **Recife, 06/03 municipal (Lei Orgânica, art. 175): fora.** De 2011 a 2017 seriam cinco dias úteis. Contra a inclusão: o TRT da 6ª Região diz que Recife tem 4 feriados municipais; o TJPE não lista a data; a Lei 9.093/1995 não admite feriado civil municipal. De 2018 em diante, o 06/03 já entra como Data Magna estadual.
- **Rio, Lei 3.572/2003 (dúvida 3): resolvida sem efeito.** O art. 1º só passa para o domingo os feriados municipais criados depois dela e exclui os já existentes.
- **Fontes:** as 42 linhas de Aracaju apontam para um endereço da Câmara fora do ar (erro 503), mas uma portaria do MPF-SE de 2023 confirma o 17/03. O 08/12 de Maceió pode vir do Decreto 5.164/1993, não da Lei 1.391/1967 (a data não muda). A Data Magna do CE vem da Lei 9.093/1995, art. 1º, II, e não da EC 73/2011, que só a declara data magna.
