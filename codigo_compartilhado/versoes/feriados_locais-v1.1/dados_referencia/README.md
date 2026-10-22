# Feriados locais (estaduais e municipais) das cidades-núcleo, 2011–2024

Pesquisa B2: rodada 1 em 2026-10-18/19; rodada 2 em 2026-10-19; rodada 3 (D17, versão v1.1) em 2026-10-19. A tabela `feriados_locais_nucleo_2011_2024.csv` traz uma linha por data efetiva de feriado local, com 8 colunas, para alimentar a covariável `feriado_local`.

## Situação depois da rodada 3 (v1.1)

- **Tabela:** 1.178 linhas e **26 núcleos** (v1.0: 1.103 linhas e 25 núcleos). Brasília passa a ter feriado local: o 30/11 (Lei distrital 963/1995), 14 linhas. A conferência (`_confere_csv.py`) deu "sem erros". SHA-256 do CSV v1.1: `4a3d4f15bc51125c892cfb2acf55d542d7146b02161c1a7a2b151f64183a5fca` (o gerador é determinístico). Chegou-se a ela pela rodada 3 (1.172), pelas decisões da A1-116 (1.176) e pelas correções da auditoria independente da v1.1 (A1-117: duas datas do Dia do Servidor no MA; ver as duas últimas seções).
- **Critério:** D17, item 2 (`spec/decisoes_metodo_20261019_AGUDOS_D17_errata-D16_feriados_locais.md`). A linha divide **feriado** de **ponto facultativo**, e não lei de decreto. O que mudou está na seção "Rodada 3 (D17, critério feriado × ponto facultativo)", no fim; a diferença linha a linha contra a v1.0 está em `_rodada3_diff_v1.0.csv`, e os achados com URL e trecho literal em `_rodada3_achados_D17.md`.
- **Linhas da rodada 3:** 91 linhas têm `conferido_por` = "subagente pesquisa B2 rodada 3 (D17), 2026-10-19" (77 novas e 14 alteradas contra a v1.0; 2 saíram). As demais mantêm o valor da rodada 1 ou da rodada 2. O `_confere_csv.py` aceita os três valores; foi a única mudança no script.
- **Cobertura:** estaduais e municipais pesquisados nos 26 núcleos (rodadas 1 e 2); na rodada 3, revisão pelo critério novo dos casos do 2c, da seção "Fora da tabela", das antecipações de 2020–21 e dos eventos do Rio.
- **O que ainda pede atenção:** "Não confirmados" na seção da rodada 3, "Fontes secundárias" e "Dúvidas que sobraram".

## Arquivos desta pasta

| Arquivo | O que é |
|---|---|
| `feriados_locais_nucleo_2011_2024.csv` | a tabela, v1.1 (1.178 linhas, depois das A1-116 e A1-117) |
| `feriados_locais_nucleo_2011_2024_v1.0.csv`, `README_feriados_locais_v1.0.md`, `_gera_feriados_locais_v1.0.py` | cópias intocadas da v1.0 (1.103 linhas; SHA-256 do CSV `ef5d99b1bfb1d0a33f44ad057e8b542015ce61aa9da5fb3d73caf117daba2e03`). Atenção: `_gera_feriados_locais_v1.0.py` grava no mesmo `feriados_locais_nucleo_2011_2024.csv`; rodá-lo sobrescreve a v1.1 (refazer com `_gera_feriados_locais.py`) |
| `feriados_locais_nucleo_2011_2024_rodada1.csv`, `_rodada2.csv`, `_A1-110.csv` | cópias das versões intermediárias (986, 1.130 e 1.116 linhas) |
| `README_feriados_locais.md` | este documento |
| `_gera_feriados_locais.py` | as regras (feriado, ato, URL, vigência). Regenera o CSV a partir do arquivo de apoio e imprime as datas retiradas por coincidência e as concorrências |
| `_confere_csv.py` | confere colunas, ordem, datas, duplicatas, coincidência com nacional/móvel, 24/12 e 31/12 |
| `_aux_fetch.py` | leitura de páginas e PDFs públicos usada na pesquisa (não grava nada) |
| `_rodada2_achados_G1_municipais.md` a `_rodada2_achados_G5_pandemia.md` | notas da rodada 2, com URL e trecho literal de cada achado (G1 municipais; G2 fontes; G3 plano B; G4 eventos; G5 pandemia) |
| `_rodada3_achados_D17.md` | notas da rodada 3 (D17): cada achado com URL e trecho literal, e cada exclusão com o motivo |
| `_rodada3_diff_v1.0.csv` | diferença da v1.1 contra a v1.0: `tipo` (nova, removida, alterada), as 8 colunas (valores novos; nas removidas, os da v1.0) e, nas alteradas, os valores antigos em `antigo_*` |
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
3. **24/12 e 31/12:** nunca entram na tabela. O indicador `feriado_local` os acrescenta em todos os núcleos (D11; D17, 2.0, item 2).
4. **Mesma data, estadual e municipal:** uma linha só, com esfera `estadual`. Concorrências:
   - 20/11/2023 em São Paulo, Campinas, Santos e Sorocaba;
   - 05/08 de 2016 a 2024, exceto 2021, em João Pessoa;
   - 20/11 em Manaus (municipal pela Lei 188/2007, coberto pela estadual);
   - 05/09 em Manaus (também na Lei Orgânica, art. 437, I);
   - 29/06 em Maceió (São Pedro estadual e Floriano Peixoto municipal);
   - 26/05/2020 em Salvador;
   - Rio de Janeiro: 23/04 (exceto 2021) e 20/11 de 2011 a 2023, que a Lei municipal 5.146/2010, art. 8º, também faz feriados;
   - Cuiabá: 20/11, que os decretos anuais da Prefeitura também listam como feriado municipal;
   - rodada 3: Goiânia, 24/10 de 2011 a 2024 (estadual do estatuto e aniversário municipal); Recife, 06/03/2011 e 06/03/2016 (Data Magna estadual no 1º domingo de março e 06/03 municipal da Lei Orgânica).
5. **Ponto facultativo, recesso, data comemorativa, feriado de categoria e ato interno de tribunal:** ficam fora (lista no fim). **Mudou na rodada 3 (D17, 2.0):** feriado de lei de alcance restrito à administração pública local entra (presumido observado, salvo prova em contrário no calendário oficial do ente), e também o decreto que declara feriado, com ou sem lei que o autorize.
6. **Antecipações e transferências (pandemia e outras):**
   - Quando lei, medida provisória ou decreto **que declara feriado** mudou a data num ano, entra a data efetiva e sai a original daquele ano (D17, 2b). O nome diz "antecipado", "transferido" ou "adiado".
   - Quando o ato antecipa vários feriados para um bloco de dias sem dizer qual vai para qual dia, as datas novas entram como bloco e todas as originais daquele ano saem (Sorocaba 2021, Campo Grande 2021, São Paulo 2021).
   - **Mudou na rodada 3:** a transferência por decreto sem lei entra quando o decreto declara feriado (MA 2015 e 2016, Maceió 2021 e 2022, GO de 2012 a 2024, Curitiba 2012). Atos internos de tribunal seguem fora (TJPI 2022, TRE-PI 2023, TRE-AL 2022, TRE-PR 2021).
7. **Fim de semana:** feriado em sábado ou domingo entra (a covariável é por data). Isso inclui a Data Magna de PE de 2011 a 2017, que era o 1º domingo de março.
8. **DF:** leis distritais tratadas como esfera `estadual`, porque o DF não tem municípios.
9. **Datas móveis calculadas:**
   - **N. Sra. da Penha (ES):** Páscoa + 8 dias (Lei ES 11.010/2019). Páscoa pelo algoritmo de Meeus, conferido contra as 14 Sextas da Paixão do arquivo de apoio.
   - **Data Magna de PE de 2011 a 2017:** 1º domingo de março.
   - **SC, 11/08 e 25/11:** transferidos para o domingo seguinte quando caem de segunda a sexta. Ver dúvidas.
10. **Meio feriado sai da tabela (decisão da sessão principal, rodada 2).** Feriado de só parte do dia não entra. Lista em "Fora da tabela". Na rodada 1 tinha entrado Fortaleza, 24/06/2014 (a partir das 12h); saiu.
11. **Corpus Christi, ou outro móvel ou nacional do modelo, antecipado localmente (rodada 2; ratificada com alteração pela D17, 2b):** a data antecipada entra como feriado local, se não coincidir com nacional ou móvel. A data original continua marcada em `moveis` (ou `feriado_nacional`) no modelo, que não muda por concentração; a tabela local não mexe nela. Quando o antecipado é feriado **local**, a data original sai da tabela naquele ano. Os casos estão em "Antecipações de feriados que estão no modelo".
12. **Feriados de eventos (rodada 2; D17, 2d):** entra o dia declarado feriado por lei ou decreto municipal ou estadual. Ponto facultativo, expediente reduzido, "feriado escolar" e meio feriado ficam fora. Os atos do Rio (JMJ, Copa, Olimpíadas, G20) excluem do feriado o comércio de rua, bares, restaurantes, shoppings e hotéis, e alguns órgãos. Mesmo assim, são de dia inteiro e declaram feriado no município, por isso entraram. Na rodada 3 conferi o texto de cada ato: as 10 datas dizem "feriado" (nenhuma é ponto facultativo).

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

- **Dia do Evangélico, 30/11:** Lei distrital 963/1995. Vigência 2011–2024. Fonte P (SINJ-DF). **Na tabela desde a rodada 3 (D17, 2c)**: saiu na v1.0 (A1-110) e voltou, porque lei de alcance restrito à administração distrital entra. Os calendários anuais do GDF de 2011, 2012, 2014, 2015, 2019, 2020, 2021, 2023 e 2024 a listam como "feriado local".
- **Fora:**
  - 21/04, 12/10, Sexta da Paixão e Corpus Christi (Lei 72/1989): coincidem com nacional ou móvel. Os decretos anuais do GDF tratam Corpus Christi como ponto facultativo.
  - 20/11 sem lei distrital (ponto facultativo de 2020 a 2023).
  - Copa das Confederações: o único jogo foi num sábado (15/06/2013), sem ato. Copa de 2014: o Decreto DF 35.163/2014 (red. 35.437/2014) deu expediente até 12h e ponto facultativo.
- **Pandemia (rodadas 2 e 3):** sem antecipação; 30/11/2020 e 30/11/2021 mantidos.
- **Alcance da Lei 963/1995:** feriado da administração direta, indireta e fundacional do DF (TJDFT, 2020); não vale para órgãos federais. Resolvido pela D17, 2c.
- **Contagem:** 14 datas (v1.0: 0).

### 2611606 Recife/PE

| Feriado | Data | Ato | Vigência | Fonte |
|---|---|---|---|---|
| Data Magna de PE | 1º domingo de março | Lei estadual 13.386/2007, red. Lei 13.835/2009 | 2011–2017 | P (ALEPE) |
| Data Magna de PE | 06/03 | Lei 16.059/2017, consolidada na Lei 16.241/2017, art. 49 | 2018–2024 (2019 saiu: Cinzas) | P (ALEPE) |
| São João | 24/06 | Lei municipal 9.777/1967 | 2011–2024 | P (portal da Prefeitura) |
| N. Sra. do Carmo | 16/07 | idem | 2011–2024 | P |
| N. Sra. da Conceição | 08/12 | idem | 2011–2024 | P |

| Revolução Republicana de 1817 (municipal) | 06/03 | **rodada 3:** Lei Orgânica do Recife, art. 175 ("É feriado municipal a data de 06 de março") | 2011–2017 (2011 e 2016 coincidem com a Data Magna estadual do 1º domingo de março: fica a estadual) | P (PDF da LOM na Câmara) |

- **06/03 municipal, rodada 3 (D17, 2.0; T2):** fora na v1.0 (A1-112); entra de 2011 a 2017 porque não achei prova em contrário no calendário oficial da Prefeitura daqueles anos. Na prática entram cinco dias úteis: 06/03 de 2012, 2013, 2014, 2015 e 2017. Calendários de tribunal (TRT-6, TJPE) não contam como prova. Indício contrário, sem ano: a página atual "Feriados Municipais" da Prefeitura diz que o Recife tem quatro feriados, pela Lei 9.777/1967 (https://www2.recife.pe.gov.br/servico/feriados-municipais); como desde 2018 o 06/03 é estadual, a página atual não prova o que valia de 2011 a 2017.
- Não há 20/11 (a Lei 16.809/2002 do Recife só cria data comemorativa). Não achei antecipação em 2020–21 (a busca de atos de PE e do Recife na pandemia ficou parcial).
- **Eventos (rodada 2):** os jogos foram na Arena Pernambuco, em São Lourenço da Mata. Copa das Confederações: sem ato de feriado do Recife ou de PE. Copa de 2014: ponto facultativo a partir das 12h (Recife) e ponto facultativo estadual (Decreto PE 40.755/2014, só em resultado de busca). Nada entrou.
- **Contagem:** 60 datas (v1.0: 55).

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
- **19/12 do PR, 2011–2013: entra (revisto na A1-116, pela presunção da D17, 2.0; ver a última seção). Texto da rodada 3:**
  - A Lei 4.658/1962 diz "Fica consagrada a data de 19 de Dezembro como feriado estadual" (P, legislacao.pr.gov.br); a Lei 18.384/2014 a revogou e diz que a data não é feriado civil.
  - A tarefa da rodada 3 manda incluir só se o calendário oficial do Paraná daqueles anos a tratava como feriado. Não achei o calendário (o Estado fixava pontos facultativos por circular da Casa Civil), nem ato contrário. A linha está comentada no gerador; pela presunção da D17, 2.0, entrariam 3 datas.
- **Rodada 3, Curitiba 2012:** entra 21/12/2012. O Decreto municipal 1835/2012 "determina o feriado de Emancipação Política do Paraná, no dia 19 de dezembro", que em 2012 foi "comemorado no dia 21 nos órgãos públicos do município" (Detran-PR, 20/12/2012, OS; texto do decreto não aberto).
- **Copa de 2014 (rodada 2):** sem feriado. O Decreto 451/2014 deu expediente das 8h às 12h em 16, 23 e 26/06 e ponto facultativo em 20/06.
- **Pandemia (rodada 2):** sem antecipação. Em 23/03/2021 a Prefeitura disse que não anteciparia; o 08/09/2021 aparece como feriado no calendário do CHC-UFPR.
- **Contagem:** 18 datas (v1.0: 14).

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
- **Rodada 3 (D17, 2.0): feriados estaduais do estatuto dos servidores entram.** Lei 10.460/1988, art. 346, II, a–c, e Lei 20.756/2020, art. 269, II, a–c ("não haverá expediente em nenhuma repartição ou serviço do Estado, nos seguintes feriados"): 26/07 (fundação da Cidade de Goiás), 24/10 (pedra fundamental de Goiânia) e 28/10 (servidor público). O 26/07 e o 28/10 entram na data efetiva de cada ano, pelo decreto de transferência do Governador (todos dizem "feriado"; 2012 e 2014–2024); a data original sai. O 24/10 nunca foi transferido e coincide com o municipal: as 14 linhas de 24/10 passam a ser `estadual`. Tabela de datas em `_rodada3_achados_D17.md`. Fonte P (base da Casa Civil de GO).
- **Fora:**
  - 16/10/2017: antecipação do 24/10 só no Sistema Estadual de Educação (Lei 19.850/2017), alcance setorial.
  - Pontos facultativos do Estado e de Goiânia (ex.: 25/10/2013, 03/11/2017, 03/11/2023; 23/05/2011, 25/05/2012, 23/05/2022).
  - Dia do Servidor municipal: ponto facultativo pela LC 011/1992, art. 254, p.ú.; os três decretos que o chamam de "feriado" (2021, 2022, 2024) caem nas datas já marcadas pelo Estado.
  - 30/10 (Dia dos Comerciários, mesma Lei 701/1956): feriado de categoria.
- **Contagem:** 56 datas (v1.0: 28).

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
| Adesão do MA à Independência | 28/07 | Lei estadual 2.457/1964 | 2011–2024, exceto 2015, 2016 e 2020 | OS (TRF1-SJMA) |
| 28 de julho de 2015 antecipado | 27/07/2015 | **rodada 3:** Decreto estadual 30.629/2015, art. 1º, X ("Antecipação do Feriado Estadual do dia 28 de Julho") | 2015 | P (compilação de decretos da PGE-MA) |
| 28 de julho de 2016 adiado | 29/07/2016 | **rodada 3:** Decreto estadual 31.473/2016, art. 1º, XI ("postergação do Feriado Estadual do dia 28 de Julho") | 2016 | P (PGE-MA) |
| 28 de julho de 2020 antecipado | 15/05/2020 | Medida Provisória estadual 313/2020 ("exclusivamente" em 2020) | 2020 | OS (TJMA) |
| Consciência Negra | 20/11 | Lei estadual 10.747/2017 | só 2018 (ADI procedente no TJMA em 2019) | OS (notícia do TJMA) |
| São Pedro | 29/06 | Lei municipal 3.432/1996 | 2011–2024 | OS (TRF1-SJMA) |
| Fundação de São Luís / Natividade | 08/09 | idem | 2011–2024 | OS |
| N. Sra. da Conceição | 08/12 | idem | 2011–2024 | **OS (UFMA, 07/12/2020: "feriado municipal [...] Lei Ordinária 3432/1996"), trocada na rodada 2** |

- Os decretos anuais de calendário da Prefeitura (2025 e 2026, no DOM) também listam o 08/12 como feriado municipal.
- A Portaria PRESI 952/2022 do TRF1 (OS) diz que a Lei 3.432 define o 08/12 como feriado municipal, mas a data "06 de fevereiro de 2006". As outras fontes dizem 06/02/1996, e em 2006 as leis de São Luís estavam na faixa dos 4.600; deve ser erro de digitação.
- O texto da Lei 3.432/1996 não foi aberto.
- **Rodada 3:** saem 28/07/2015 e 28/07/2016 (dias normais nas repartições estaduais; O Imparcial, 2015 e 2016) e entram 27/07/2015 e 29/07/2016. Nos calendários de 2017, 2018, 2021 e 2022 o 28/07 ficou na data; 2011, 2013, 2014 e 2023 não foram conferidos ano a ano. Em 2015 a Prefeitura deu só ponto facultativo no 27/07 (fora); em 2016 também transferiu para 29/07 (mesma data da linha estadual). O Dia do Servidor estadual aparece nos calendários como "Comemoração alusiva ao Dia do Servidor Público", sem a palavra feriado: fora.

**Contagem:** 59 datas (v1.0: 57; duas saíram e quatro entraram).

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
| Emancipação Política de AL | 16/09 | **rodada 3:** decreto anual do Governador de cada ano, que a declara "feriado estadual" | 2011, 2012 e 2014–2023 (2014 pelo Decreto municipal de Maceió 7.595/2013, A1-116; 2013 fora: nenhum ato achado) | S (texto ou lista do decreto em LegisWeb, NormasBrasil ou imprensa) |
| Emancipação Política de AL | 16/09 | Lei estadual 9.358/2024 | 2024 | P |
| Dia Estadual do Evangélico | 30/11 | **rodada 3:** decreto anual do Governador (Lei 7.530/2013); 29/11/2021 e 01/12/2023 pelo parágrafo único da lei, aplicado pelo Governo | 2018–2024 | S; OS para 2023 |
| Dia Estadual do Evangélico mantido no 30/11/2023 | 30/11/2023 | **rodada 3:** Decreto municipal 9.359/2022, art. 1º, XX (a Prefeitura manteve o feriado; o Estado o passou para 01/12) | 2023 | S |
| Marechal Floriano Peixoto antecipado | 28/06/2021 e 27/06/2022 | **rodada 3:** decretos municipais publicados no DOM de 23/06/2021 e 23/06/2022 (textos não abertos) | 2021, 2022 | S |
| Zumbi dos Palmares | 20/11 | Lei estadual 5.724, de 01/08/1995 | 2011–2023 | **OS (JFAL), trocada na rodada 2** |
| N. Sra. dos Prazeres | 27/08 | Lei municipal 1.391, de 16/05/1967 | 2011–2024 | **OS (JFAL), trocada na rodada 2** |
| N. Sra. da Conceição | 08/12 | Lei municipal 1.391/1967 | 2011–2024 | **OS (Decreto municipal 10.234/2025, no DOM de Maceió, que cita a lei), trocada na rodada 2** |

- **16/09 de 2011 a 2023:** nenhuma das leis que os decretos anuais citam trata da data (rodada 2). Na v1.0 as 13 datas saíram (A1-112). **Rodada 3 (D17, 2c):** entram os 11 anos em que achei o decreto anual que a declara "feriado estadual"; 2013 e 2014 ficaram fora na rodada 3 (decreto estadual não achado). Para 2014 há o Decreto municipal de Maceió 7.595/2013, que lista o 16/09 como "(feriado estadual)"; ficou fora porque a tarefa pedia o decreto estadual. **Revisto na A1-116: 2014 entra pelo decreto municipal (decreto do município-núcleo que declara feriado basta, D17, 2.0); 2013 segue fora, sem ato.**
- **30/11 (Dia Estadual do Evangélico), rodada 3:** entra de 2018 a 2024 pelos decretos anuais (os de 2015 a 2017 não o listam). Em 2021 o Governo o antecipou para a segunda, 29/11, e em 2023 o adiou para a sexta, 01/12, pelo parágrafo único da Lei 7.530/2013. Em 2023 a Prefeitura manteve o feriado no 30/11 e deu ponto facultativo no 01/12: entram as duas datas. Em 2021 não achei o que a Prefeitura fez; o 30/11/2021 fica fora (não confirmado).
- **29/06 municipal (Marechal Floriano Peixoto), rodada 3:** antecipado por decreto municipal para 28/06/2021 e 27/06/2022 (entram). O 29/06 continua na tabela pelo São Pedro estadual, mantido nos dois anos.
- Os textos da Lei 5.724/1995 (não está no SAPL da ALE-AL) e da Lei municipal 1.391/1967 (a Câmara não tem SAPL acessível) não foram abertos.

**Contagem:** 92 datas (v1.0: 70).

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

- **Manaus, Carnaval de 2021:** a terça de Carnaval (16/02/2021) foi suspensa pelo Decreto 5.023/2021, com base na Lei 2.660/2020 (Portal Amazônia, S; rodada 3). Não conferido no DOM.
- **Goiás e Goiânia, Carnaval de 2021 (rodada 3):** a terça de Carnaval de 2021 foi suspensa pela Lei GO 20.967/2021 ("Fica suspenso, no ano de 2021, de forma excepcional, o feriado de terça-feira de Carnaval", P) e pela Lei municipal de Goiânia 10.599/2021 (P).
- **Pela D17, 2b, o Corpus Christi e outro feriado nacional ou móvel antecipado seguem com a data original em `moveis` (ou `feriado_nacional`) no modelo;** a tabela local só acrescenta a data nova. Corrigir o calendário nacional e móvel do modelo é decisão de método.

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
| Maceió/AL | 16/09 de 2011, 2012 e 2014–2023 (2014 pelo decreto municipal); Dia do Evangélico de 2018 a 2024, com 29/11/2021 e 01/12/2023 (rodada 3, A1-116 e A1-117) | texto do decreto anual em LegisWeb ou NormasBrasil; em 2018, 2019 e 2021, lista do decreto reproduzida pela imprensa (TNH1; a de 2019 é texto da Agência Alagoas) | o DOE-AL atual é aplicação JavaScript e não abriu; números completados na A1-117: 2018 com o texto do Decreto 56.880/2017 (LegisWeb), 2019 Decreto 62.819/2018 (Portaria JFAL 476), 2021 Decreto 72.527/2020 com fonte primária no DOE-AL de 04/01/2021 |
| Maceió/AL | 29/11/2021; 30/11/2023 (municipal); 28/06/2021; 27/06/2022 (rodada 3) | Cadaminuto; TNH1 e NormasBrasil (Decreto municipal 9.359/2022); COAD; TNH1 | DOM de Maceió não localizado on-line; textos dos decretos de 2021 e 2022 não abertos |
| Curitiba | 21/12/2012 (rodada 3) | notícia do Detran-PR (OS) que cita o Decreto municipal 1835/2012 | texto do decreto não aberto |
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

### Outros fora (revistos na rodada 3 pelo critério da D17)

Na rodada 3 saíram desta lista, e entraram na tabela: GO (26/07, 24/10 e 28/10, estatuto dos servidores); AL, 30/11 (2018–2024); MA, 2015 (27/07; e 2016, 29/07); Maceió, 28/06/2021 e 27/06/2022; Recife, 06/03 municipal (2011–2017); DF, 30/11. Detalhe na seção "Rodada 3".

- **PR, 19/12, 2011–2013: revisto na A1-116, entra (ver a última seção).** Texto da rodada 3: fora, não confirmado. A Lei 4.658/1962 diz "feriado estadual"; o TRT-9 (5ª Turma, 24/11/2015) negou caráter de feriado civil, e a Lei 18.384/2014 a revogou ("não se constituindo em feriado civil"). A tarefa manda incluir só se o calendário oficial do Paraná daqueles anos a tratava como feriado: não achado. Pela presunção da D17, 2.0, entrariam 2011-12-19, 2012-12-19 e 2013-12-19 (linha comentada no gerador). Em Curitiba, 2012, o feriado foi transferido por decreto municipal para 21/12, que entrou.
- **AL, 30/11 de 2011 a 2017:** a D17, 2c, manda deixar fora; os decretos anuais de 2015 a 2017 não o listam.
- **AL, 16/09 de 2013 e 2014:** decreto estadual não achado. 2014 revisto na A1-116: entra pelo Decreto municipal de Maceió 7.595/2013 (ver a última seção); 2013 segue fora.
- **Maceió, 30/11/2021:** não achei se a Prefeitura seguiu a antecipação estadual para 29/11; fica fora (não confirmado).
- **20/11 sem eficácia:**
  - MS (Lei 3.958/2010): declarada inconstitucional pelo Órgão Especial do TJMS em 19/10/2011 (ADI 2010.035531-5), antes do primeiro 20/11 do período: fora em 2011–2023.
  - Florianópolis (Lei 8.046/2009): efeitos suspensos pela ADI 2010.073591-5 do TJSC (consolidação da Câmara); data da liminar e desfecho não confirmados; fora em 2011–2023.
  - São Luís, municipal: a "Lei Municipal 309/2013" foi declarada inconstitucional na ADI 54.567/2013 do TJMA; fora em 2015–2023 (portaria da SJMA de 2015 sem a data); 2013 e 2014 não confirmados, fora.
  - MA, estadual (Lei 10.747/2017): entra só 2018; ADI procedente em 09/10/2019, antes do 20/11/2019; sem lei nova até 2023.
- **Pontos facultativos (todos fora):** DF, 20/11 de 2020 a 2023 (Decretos 40.440/2020, 41.716/2021 e 44.145/2023: "(ponto facultativo)"); Cuiabá, 08/12/2011 (Lei 4.672/2004); Belém, 12/01, Círio e Recírio; Dia do Servidor (28/10) fora de GO (em AL é ponto facultativo; no MA, "comemoração", sem a palavra feriado); Quinta-feira Santa; pontes; Carnaval e Cinzas em vários estados; PI em 19/03, 29/03 e 01/04/2021; MG em 01/04/2021; São Luís, 27/07/2015 (municipal); SP, 22/05/2020 (suspensão de expediente estadual); MS, 16/06/2017 (ponto facultativo estadual ligado ao 13/06, que segue como feriado municipal em Campo Grande); 24 e 31/12 (entram pelo indicador, não pela tabela).
- **GO, 16/10/2017:** antecipação do 24/10 só no Sistema Estadual de Educação (Lei 19.850/2017): alcance setorial.
- **Atos internos de tribunal (fora):** Dia do Piauí de 2022 para 21/10 (TJPI); 16/08/2023 para 14/08 (TRE-PI); 30/11/2022 para 02/12 (TRE-AL); 11/08 e 08/12 para 29–30/03/2021 (TRE-PR). Mantidas as datas do ente.
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
| Vitória (só se a covariável for de Vitória) | antecipação de 2021 (30/03 a 01/04) | PL 57/2021 aprovado pela Câmara de Vitória; número da lei não achado; fonte S. A tabela segue com a Serra |

Rodada 3: o 30/11 de AL entrou de 2018 a 2024 pelos decretos anuais (D17, 2c), e o 16/09 de AL de 2011 a 2023 entrou nos 11 anos com decreto achado. A promulgação do art. 2º da Lei 7.530/2013 segue não achada; o Governo de AL cita um parágrafo único dela.

## Dúvidas que sobraram

1. **SC, sábado:** quando 11/08 ou 25/11 cai num sábado (11/08 em 2012 e 2018; 25/11 em 2017 e 2023), mantive o sábado. Se "dia útil da semana" incluir o sábado, a data passa para o domingo seguinte.
2. **DF, alcance da Lei 963/1995 (30/11): resolvida pela D17, 2c.** Lei de alcance restrito à administração distrital entra; as 14 datas estão na v1.1.
3. **Rio, Lei municipal 3.572/2003 ("Antecipa a comemoração dos feriados municipais", em vigor):** o texto não foi aberto. A Lei 5.146/2010, posterior, diz que o 20/01 é "insuscetível de transferência". Não sei se a 3.572 desloca outros feriados municipais para segunda-feira.
4. **Natal, 20/11 municipal (2014–2023):** o calendário de 2021 da Prefeitura não lista 20/11/2021, um sábado. Não achei contestação judicial da Lei 6.458/2014, e mantive as datas.
5. **João Pessoa, 05/08/2021:** o estado antecipou o seu 05/08 para 01/04/2021, mas o feriado municipal (Lei 8.805/1999) foi mantido na tabela. A Lei municipal 14.224/2021 permitiu ao Executivo cancelar feriados na pandemia; nenhum ato foi achado. É o caso parecido com o do Rio em 23/04/2021, onde houve evidência de que o município seguiu a antecipação; em JP não achei evidência.
6. **AL, 16/09 de 2011 a 2023: resolvida pela D17, 2c** (entra no ano com decreto que a declara feriado; 2013 fora; 2014 entra pelo decreto municipal de Maceió, A1-116). Uma liminar do TRT-19 (2020, um único mandado de segurança) afastou 24 e 29/06 para fins trabalhistas; decisão judicial que não muda o critério; mantive as datas.
7. **Campinas, 08/12:** o número da lei diverge entre fontes oficiais (3.902/1970 ou 173/1949). A data é a mesma.
8. **Goiânia, Lei 701/1956:** data da lei divergente entre páginas da Prefeitura (03/09 ou 30/08/1956); texto não aberto.
9. **Cuiabá, 08/12:** desfecho final da ADI de 2012 não localizado; a lei está "Em Vigor" na Câmara e a data é observada.
10. **Florianópolis, 20/11:** desfecho final da ADI 2010.073591-5 não localizado. Fica fora pela anotação de suspensão.
11. **Atos com texto não aberto, citados por órgão público:** Belém (Lei 6.306/1967), Campo Grande (Leis 3.901/2001 e 1.019/1967), Teresina (Leis 5.510/2020, 5.523/2020, 7.490/2021 e 7.491/2021), Aracaju (Lei SE 8.679/2020), BH (Decreto 15.247/2013), São Luís (Lei 3.432/1996), Maceió (Leis 5.724/1995 e 1.391/1967), Goiânia (Lei 701/1956).
12. **Feriados de evento com exclusões setoriais (Rio):** os atos da JMJ, da Copa de 2014, das Olimpíadas e do G20 mantêm abertos o comércio de rua, bares, restaurantes, shoppings, hotéis e serviços essenciais. Entraram pela decisão 12 e pela D17, 2d (todos declaram feriado). Se a covariável dever captar só fechamento geral, essas 10 datas do Rio são as candidatas a sair.
13. **João Pessoa, 24/06/2021 (São João municipal; rodada 3):** o Jornal da Paraíba (18/06/2021) diz que o prefeito "editou uma Medida Provisória cancelando a folga"; a MP não foi achada. A linha fica (lei municipal presumida observada). Se a MP for achada, o 24/06/2021 sai.
14. **Manaus, 2º semestre de 2020 (rodada 3):** a Lei 2.660/2020 pode ter suspendido feriados municipais durante a calamidade; texto não achado. O 24/10/2020 caiu num sábado e o 08/12/2020 foi mantido (rodada 2). Linhas mantidas.
15. **Maceió, 2023 (rodada 3):** entram 30/11/2023 (municipal: a Prefeitura manteve o feriado) e 01/12/2023 (estadual: o Governo o adiou). Se a covariável dever seguir só o Estado, sai o 30/11/2023.

## Contagem de datas por núcleo (v1.1: 1.178 no total)

Rodada 2 = fim da rodada 2 (1.130); v1.0 = depois das decisões A1-110 e A1-112 (1.103); v1.1 = depois da rodada 3 (D17) e das A1-116 e A1-117. Estaduais e municipais, na v1.1. Tabela gerada dos três CSVs.

| CD_RECORTE | Núcleo | Rodada 2 | v1.0 | v1.1 | v1.1 − v1.0 | Estaduais | Municipais |
|---|---|---|---|---|---|---|---|
| 1302603 | Manaus | 55 | 55 | 55 | +0 | 27 | 28 |
| 1501402 | Belém | 28 | 28 | 28 | +0 | 14 | 14 |
| 2111300 | São Luís | 57 | 57 | 59 | +2 | 17 | 42 |
| 2211001 | Teresina | 45 | 45 | 45 | +0 | 16 | 29 |
| 2304400 | Fortaleza | 45 | 45 | 45 | +0 | 12 | 33 |
| 2408102 | Natal | 52 | 52 | 52 | +0 | 14 | 38 |
| 2507507 | João Pessoa | 46 | 46 | 46 | +0 | 12 | 34 |
| 2611606 | Recife | 55 | 55 | 60 | +5 | 13 | 47 |
| 2704302 | Maceió | 83 | 70 | 92 | +22 | 60 | 32 |
| 2800308 | Aracaju | 56 | 56 | 56 | +0 | 14 | 42 |
| 2927408 | Salvador | 44 | 44 | 44 | +0 | 15 | 29 |
| 3106200 | Belo Horizonte | 29 | 29 | 29 | +0 | 0 | 29 |
| 3205309 | Serra | 47 | 47 | 47 | +0 | 5 | 42 |
| 3304557 | Rio de Janeiro | 55 | 55 | 55 | +0 | 31 | 24 |
| 3509502 | Campinas | 42 | 42 | 42 | +0 | 15 | 27 |
| 3548500 | Santos | 55 | 55 | 55 | +0 | 15 | 40 |
| 3549904 | São José dos Campos | 41 | 41 | 41 | +0 | 15 | 26 |
| 3550308 | São Paulo | 45 | 45 | 45 | +0 | 15 | 30 |
| 3552205 | Sorocaba | 42 | 42 | 42 | +0 | 15 | 27 |
| 4106902 | Curitiba | 14 | 14 | 18 | +4 | 3 | 15 |
| 4205407 | Florianópolis | 42 | 42 | 42 | +0 | 28 | 14 |
| 4314902 | Porto Alegre | 28 | 28 | 28 | +0 | 14 | 14 |
| 5002704 | Campo Grande | 42 | 42 | 42 | +0 | 14 | 28 |
| 5103403 | Cuiabá | 40 | 40 | 40 | +0 | 13 | 27 |
| 5208707 | Goiânia | 28 | 28 | 56 | +28 | 42 | 14 |
| 5300108 | Brasília | 14 | 0 | 14 | +14 | 14 | 0 |
| | **Total** | **1130** | **1103** | **1178** | **+75** | **453** | **725** |

## Decisões da sessão principal sobre as dúvidas (19/10/2026, A1-110)

> Histórico da v1.0. Os itens sobre DF 30/11, AL 16/09, AL 30/11 e Recife 06/03 foram revistos pela D17 na rodada 3 (seção "Rodada 3", no fim).

- **DF, 30/11 (Lei 963/1995): sai** pela decisão 5. O TJDFT lê a lei como feriado só da administração distrital, com o comércio aberto. As 14 datas saem, e Brasília fica sem feriado local, porque os demais feriados distritais coincidem com nacionais ou móveis. A tabela passa de 1.130 para 1.116 linhas. A cópia da rodada 2, antes da mudança, está em `feriados_locais_nucleo_2011_2024_rodada2.csv` (SHA-256 `57757b48b04f308bd5b8ce3ebca6bd7a6fd25316da3a18fbc4322896f077e01d`). A linha está comentada no gerador.
- **AL, 16/09 de 2011 a 2023: fica (decisão revista na A1-112; ver abaixo).** A data foi declarada feriado estadual pelos decretos anuais do governo e observada como tal. A decisão 12 aceita decreto que declara feriado; a decisão 6 trata de transferência, não de criação. Limitação: não há lei estadual antes da Lei 9.358/2024.
- **Rio, feriados de eventos (JMJ, Copa, Olimpíadas, G20): ficam.** São de dia inteiro e declaram feriado no município. A exclusão de setores do comércio não os torna meio feriado. Limitação: o fechamento é parcial.
- **Florianópolis, 20/11: fora**, enquanto o desfecho da ADI 2010.073591-5 não for achado.
- **Maceió, 30/11: fora**, sem a promulgação depois da derrubada do veto.
- **Vitória × Serra:** a covariável é a da cidade-núcleo (Serra). As antecipações de Vitória não entram.
- **Demais dúvidas (SC no sábado; Rio, Lei 3.572/2003; Natal, 20/11; João Pessoa, 05/08/2021; Campinas; Goiânia; Cuiabá, 08/12):** ficam como a rodada 2 deixou.

## Auditoria por amostra e decisões finais (19/10/2026, A1-112)

> Histórico da v1.0. Os itens sobre DF 30/11, AL 16/09, AL 30/11 e Recife 06/03 foram revistos pela D17 na rodada 3 (seção "Rodada 3", no fim).

- **Auditoria independente** (amostra de 80 linhas sorteada com semente 20261001: 50 da rodada 2 e 30 da rodada 1; checagens por código na tabela inteira; busca de omissões em Belém, Recife, São José dos Campos, Curitiba e Goiânia). Resultado: 63 linhas confirmadas, 15 confirmadas com ressalva, 2 não confirmadas (Maceió, 16/09 de 2016 e de 2019) e 0 erradas. As checagens por código passaram. Nenhuma omissão de feriado observado.
- **AL, 16/09 de 2011 a 2023: sai** (revê a A1-110, item 2). A auditoria achou o critério incoerente: os decretos anuais listam o 16/09 e o 30/11 lado a lado como "feriado estadual", e só um tinha ficado. Critério único, o mesmo do 30/11 do DF: feriado criado só por decreto do Executivo, sem lei, vale só para o serviço público e fica fora pela decisão 5. Saem as 13 datas de 2011 a 2023. Fica o de 2024, da Lei 9.358, de 26/08/2024. O 30/11 de AL continua fora. A tabela passa de 1.116 para 1.103 linhas. A cópia anterior está em `feriados_locais_nucleo_2011_2024_A1-110.csv` (SHA-256 `8af8fea3054c69139dcc8f83269f8a53e8c57aefd81041184eda4dfc7afef223`). O bloco está comentado no gerador.
- **Recife, 06/03 municipal (Lei Orgânica, art. 175): fora.** De 2011 a 2017 seriam cinco dias úteis. Contra a inclusão: o TRT da 6ª Região diz que Recife tem 4 feriados municipais; o TJPE não lista a data; a Lei 9.093/1995 não admite feriado civil municipal. De 2018 em diante, o 06/03 já entra como Data Magna estadual.
- **Rio, Lei 3.572/2003 (dúvida 3): resolvida sem efeito.** O art. 1º só passa para o domingo os feriados municipais criados depois dela e exclui os já existentes.
- **Fontes:** as 42 linhas de Aracaju apontam para um endereço da Câmara fora do ar (erro 503), mas uma portaria do MPF-SE de 2023 confirma o 17/03. O 08/12 de Maceió pode vir do Decreto 5.164/1993, não da Lei 1.391/1967 (a data não muda). A Data Magna do CE vem da Lei 9.093/1995, art. 1º, II, e não da EC 73/2011, que só a declara data magna.

## Rodada 3 (D17, critério feriado × ponto facultativo)

19/10/2026. Gera a **v1.1**. Critério: D17, item 2 (2.0 a 2f), `spec/decisoes_metodo_20261019_AGUDOS_D17_errata-D16_feriados_locais.md`. A linha agora divide **feriado** de **ponto facultativo**:
- **entra** a data que, naquele ano, foi feriado do estado, do DF ou do município-núcleo, por lei (inclusive de alcance restrito à administração pública local, presumida observada salvo prova em contrário no calendário oficial do ente) ou por decreto que a declare feriado, com ou sem lei autorizativa;
- **fica fora** a data que foi só ponto facultativo, o meio feriado, o feriado só de categoria, o ato interno de tribunal e a data dos anos em que o ato não teve eficácia (liminar, inconstitucionalidade, revogação);
- **antecipação (2b):** entra a data nova quando o ato declara feriado; a data original do feriado **local** antecipado sai naquele ano.

Contexto legal, sem juízo de compatibilidade de cada lei: Lei 9.093/1995, art. 1º, I a III (feriados civis: os de lei federal; a data magna do estado, em lei estadual; o centenário do município, em lei municipal) e art. 2º (religiosos: "dias de guarda, declarados em lei municipal", até quatro, contando a Sexta-Feira da Paixão). O DF acumula as competências estadual e municipal (CF, art. 32, § 1º).

### Resumo das mudanças (v1.0 → v1.1: 1.103 → 1.178 linhas; 25 → 26 núcleos; 1.172 no fim da rodada 3, antes das A1-116 e A1-117)

| Tarefa | Entraram | Saíram | Mudaram | O quê |
|---|---|---|---|---|
| T1 (casos do 2c) | 33 | 0 | 0 | DF, 30/11 de 2011–2024 (14); AL, 16/09 de 2011, 2012 e 2015–2023 (11); AL, 30/11 de 2018–2024 (7, com 29/11/2021 e 01/12/2023 no lugar do 30/11) e Maceió, 30/11/2023 municipal (1) |
| T2 (seção "Fora da tabela") | 38 | 2 | 14 | GO, 26/07 e 28/10 nas datas efetivas (28) e 24/10 passando de municipal a estadual (14 alteradas); Maceió, 28/06/2021 e 27/06/2022 (2); MA, 27/07/2015 e 29/07/2016 (2), saindo 28/07/2015 e 28/07/2016; Recife, 06/03 municipal de 2012–2015 e 2017 (5); Curitiba, 21/12/2012 (1) |
| T3 (antecipações de 2020–21) | 0 | 0 | 0 | todos os atos que declararam feriado já estavam na tabela |
| T4 (eventos do Rio) | 0 | 0 | 0 | as 10 datas declaram "feriado" no texto do ato; ficam |
| **Subtotal da rodada 3** | **71** | **2** | **14** | |
| A1-116 (letra da D17) | 4 | 0 | 0 | PR, 19/12 de 2011–2013 (3); AL, 16/09/2014 pelo Decreto municipal de Maceió 7.595/2013 (1) |
| A1-117 (auditoria da v1.1) | 2 | 0 | 0 | MA, Dia do Servidor: 31/10/2011 e 30/10/2015 |
| **Total da v1.1 contra a v1.0** | **77** | **2** | **14** | 1.103 + 77 − 2 = 1.178 |

### Datas excluídas na rodada 3 e motivo

| Núcleo | Data(s) | Motivo |
|---|---|---|
| São Luís (MA) | 28/07/2015 e 28/07/2016 | feriado estadual antecipado para 27/07/2015 e adiado para 29/07/2016 pelo calendário do Governo (D17, 2b) |
| Maceió (AL) | 30/11/2021 (estadual) | antecipado para 29/11/2021 pelo Governo (parágrafo único da Lei 7.530/2013); se a Prefeitura o manteve, não achei |
| Maceió (AL) | 30/11/2023 (estadual) | adiado para 01/12/2023 pelo Governo; o 30/11/2023 ficou como municipal (a Prefeitura manteve) |
| Goiânia (GO) | 26/07 de 2012, 2016–2018, 2022–2024; 28/10 de 2014–2016, 2019–2022 e 2024 | feriados do estatuto transferidos por decreto do Governador (nunca entraram como estaduais; registradas aqui porque a data original não é feriado nesses anos) |
| Curitiba (PR) | 19/12/2012 | o decreto municipal levou o feriado para 21/12 nos órgãos do município |

Itens que seguem fora, com o motivo, estão em "Fora da tabela" (pontos facultativos; 20/11 sem eficácia em MS, Florianópolis, São Luís e no MA de 2019 em diante; feriados de categoria; atos de tribunal; meios feriados).

### Não confirmados (fora da tabela)

- **AL, 16/09/2013 e 16/09/2014:** decreto estadual anual não achado. Em 2014, o Decreto municipal de Maceió 7.595/2013 lista o 16/09 como "(feriado estadual)"; a tarefa pedia o decreto estadual (linha comentada no gerador).
- **PR, 19/12 de 2011–2013:** calendário oficial do Estado não achado; nenhum ato contrário (linha comentada no gerador).
- **Maceió, 30/11/2021 (municipal):** não achei se a Prefeitura seguiu a antecipação estadual.
- **Florianópolis, 20/11:** data da liminar e desfecho da ADI 2010.073591-5 não achados.
- **São Luís, 20/11 municipal de 2013 e 2014:** data da decisão do TJMA não achada.
- **João Pessoa, 24/06/2021:** possível cancelamento por medida provisória municipal (notícia), ato não achado; a linha fica.
- **Manaus, feriados municipais do 2º semestre de 2020:** possível suspensão pela Lei 2.660/2020, texto não achado; as linhas ficam.
- **MA, 28/07 de 2011, 2013, 2014 e 2023:** calendário anual não conferido (o 28/07 fica pela lei).
- **DF, calendários de 2013, 2016, 2017, 2018 e 2022:** não achados; o 30/11 fica pela lei (presunção da D17).

### Antecipação de feriado nacional ou móvel (D17, 2b)

O Corpus Christi, e outro feriado nacional ou móvel antecipado localmente (Tiradentes e N. Sra. Aparecida em 2021, por exemplo), **segue com a data original em `moveis` (ou `feriado_nacional`) no modelo**, que não muda por concentração. A tabela local só acrescenta a data nova. Os casos estão em "Antecipações de feriados que estão no modelo"; quase todos são de 2020–21.

### 24/12 e 31/12

Entram sempre pelo indicador `feriado_local` (letra da D11: "mais 24/12 e 31/12"; D17, 2.0, item 2), e **não pela tabela**. A tabela não tem nenhuma linha nessas datas (o `_confere_csv.py` confere).

### Limitação (D17, 2e; letra da D11)

A tabela traz só os feriados do **município-núcleo** (e do estado ou do DF). Mães residentes em outros municípios da concentração podem ter tido outro calendário municipal (por exemplo, Vitória × Serra, Niterói × Rio, Guarulhos × São Paulo). Vai como limitação no README e em Methods.

Outras limitações desta rodada:
- Feriados de lei de alcance restrito à administração (DF, 30/11; GO, estatuto) entram presumidos observados: o comércio pode ter aberto.
- O Dia do Servidor (28/10) entrou só em Goiânia, onde o estatuto o chama de feriado. Os estatutos de servidores das outras UFs não foram varridos; nos calendários vistos, AL o trata como ponto facultativo e o MA como "comemoração", sem a palavra feriado.
- Fontes secundárias (S) sustentam 20 das 71 linhas novas (todas de AL e Maceió) e fontes oficiais secundárias (OS) outras 2 (Maceió, 01/12/2023; Curitiba, 21/12/2012); o DOE-AL e o DOM de Maceió não abriram on-line. As outras 49 têm fonte P.

### Decisões de implementação da rodada 3

1. **AL, 30/11 de 2021 e 2023:** a data efetiva segue o parágrafo único da Lei 7.530/2013 aplicado pelo Governo (29/11/2021; 01/12/2023). Em 2023 a Prefeitura de Maceió manteve o 30/11 e entrou também essa data (municipal), porque foi feriado do município-núcleo.
2. **GO, 24/10:** com o feriado estadual do estatuto, as 14 linhas viram `estadual` (regra de concorrência), mantendo no `ato_normativo` a Lei municipal 6.968/1991.
3. **GO, Lei 20.756/2020:** citada a partir das datas posteriores a 27/07/2020 (vigor 180 dias após a publicação de 29/01/2020; conta minha); antes, a Lei 10.460/1988. O texto dos dois artigos é igual.
4. **Recife, 06/03:** regra de 2011 a 2017; em 2011 e 2016 o 06/03 foi o 1º domingo de março e a linha estadual fica (concorrência).
5. **Curitiba, 21/12/2012:** entrou como municipal pelo decreto que declara o feriado transferido nos órgãos do município, embora o 19/12 estadual de 2012 fique como não confirmado.
6. **AL, 16/09/2014 e PR, 19/12:** deixados fora pela regra da tarefa, com a linha pronta e comentada no gerador.

### Fontes principais da rodada 3

As URLs e os trechos literais estão em `_rodada3_achados_D17.md`. Fontes P abertas nesta rodada: SINJ-DF (Lei 963/1995 e Decretos 40.440/2020, 44.145/2023, 45.425/2024); Casa Civil de GO (Leis 10.460/1988 e 20.756/2020 e os 15 decretos de transferência); PGE-MA (Decretos 30.629/2015 e 31.473/2016); Câmara do Recife (Lei Orgânica, art. 175); Câmara do Rio (Leis 5.591/2013 e 8.314/2024); DO Rio (Decretos 38.864/2014, 41.867/2016, 42.073/2016 e 48.644/2021); SAPL da ALE-AL (Lei 7.530/2013); legislacao.pr.gov.br (Leis 4.658/1962 e 18.384/2014).

## Decisões da sessão principal sobre a rodada 3 (19/10/2026, A1-116)

A tarefa da rodada 3 pediu mais que a D17 em dois casos. A sessão principal aplicou a letra da D17, 2.0, item 1:
- **PR, 19/12 de 2011 a 2013: entra (3 linhas, esfera estadual).** A Lei 4.658/1962 ("feriado estadual") esteve em vigor até a Lei 18.384/2014. A D17 presume observada a lei em vigor, salvo prova em contrário no calendário oficial do ente, e nenhuma foi achada. Corrobora o Decreto municipal de Curitiba 1835/2012, que fala do "feriado de Emancipação Política do Paraná, no dia 19 de dezembro". Em 2012 ficam o 19/12 (estadual, por lei) e o 21/12 (municipal, Decreto 1835/2012, nos órgãos do município).
- **AL, 16/09/2014: entra (1 linha, esfera municipal).** O Decreto municipal de Maceió 7.595, de 27/12/2013, art. 1º, XIV, declara a data feriado no núcleo, e decreto do município-núcleo que declara feriado basta (D17, 2.0, item 1). O decreto estadual de 2014 segue não achado. 2013 continua fora: nenhum ato achado.
- **Tabela depois disso:** 1.176 linhas e 26 núcleos (depois, com a A1-117: 1.178) (SHA-256 `56fa20ff5d6c4440ad41030d0a97f3386b2480b909014cf78717ac68cc15760c`); conferência sem erros. A cópia de antes destas duas decisões está em `_v11_rodada3_antes_A1-116.csv`.

## Auditoria independente da v1.1 e correções (19/10/2026, A1-117)

- **Auditoria** (subagente em contexto limpo; todas as 91 linhas da diferença v1.0 → v1.1 de então, conferidas na fonte; checagens por código na tabela inteira; busca de antecipações de 2020–21 em Recife e Curitiba): 71 confirmadas, 20 confirmadas com ressalva (fonte fraca ou número de ato faltando), 0 não confirmadas, 0 erradas. Nenhum achado Crítico ou Maior. Nenhuma omissão de 2020–21 em Recife ou Curitiba.
- **Correções feitas:**
  - **Atos de AL:** 2018 passa a citar o texto do Decreto 56.880/2017 no LegisWeb; 2019, o número do ato (Decreto 62.819, de 27/12/2018, pela Portaria JFAL 476); 2021, o Decreto 72.527, de 30/12/2020, com fonte primária no DOE-AL de 04/01/2021, cujo texto a sessão conferiu.
  - **DF:** o ato cita o texto literal da Lei 963/1995 ("no âmbito do Distrito Federal"); o alcance restrito à administração distrital fica como leitura do TJDFT e do TRF1.
  - **MA, Dia do Servidor Público:** a pesquisa dos atos anuais de 2011 a 2024 achou o feriado declarado só em dois anos, cujo texto a sessão conferiu. Entram 31/10/2011 (ato da Governadora, DOE-MA de 24/10/2011, "a celebração do feriado consagrado ao servidor público") e 30/10/2015 (Decreto 30.629/2015, XIII, "Postergação do Feriado do dia 28 de outubro"). Ficam fora: 2012 (nada achado); 2013, 2020, 2023 e 2024 (ponto facultativo); 2014, 2021 e 2022 (adiamento só "das comemorações"); 2016 a 2019 (inciso sem rótulo).
  - **Diferença contra a v1.0:** `_rodada3_diff_v1.0.csv` foi gerada de novo: 77 novas, 14 alteradas, 2 removidas.
- **Notas que ficam como limitação:**
  - **GO:** os Decretos 8.470/2015, 8.694/2016 e 9.961/2021 excluem as "unidades de saúde" das transferências do estatuto. Nesses dias, a rede estadual de saúde pode ter funcionado normalmente.
  - **AL:** a Lei 5.724/1995, citada nos decretos anuais, trata do 20/11 (Zumbi), não do 16/09. Não há lei do 16/09 antes da 9.358/2024, e o 16/09/2013 fica fora, sem ato.
  - **AL, transferências do 30/11 (29/11/2021 e 01/12/2023):** a base é o parágrafo único da Lei 7.530/2013, na parte vetada; a promulgação depois da derrubada do veto não foi achada. As datas entram porque o Governo as declarou feriado.
  - **Recife, 06/03:** uma lista do TJPE de dezembro de 2013 traz o 06/03 entre os feriados do Recife, o que corrige o "TJPE não lista" da A1-112.
  - **MA, 20/11:** os decretos anuais de 2018 e 2019 o rotulam "Feriado Estadual". O de 2019 fica fora porque a ADI foi julgada procedente em outubro de 2019.
