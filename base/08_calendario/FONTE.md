# FONTE — Calendário de feriados (E11)

**Data de acesso:** 2026-10-05 (America/Sao_Paulo). **Script:** `00_scripts/06e_calendario.py`. **Saída:** `06_processados/calendario_2010_2025.parquet`, com 5.510 dias, de 2010-01-01 a 2025-01-31 (md5 811d08a24c18b81d62a0bf52caeebd83).

## 1. Base legal (texto vigente no site do Planalto)

| Data | Feriado | Lei | Página |
|---|---|---|---|
| 1/1, 21/4, 1/5, 7/9, 2/11, 15/11, 25/12 | Confraternização Universal, Tiradentes, Dia do Trabalho, Independência, Finados, Proclamação da República, Natal | Lei 662, de 6/4/1949, art. 1º, com a redação da **Lei 10.607, de 19/12/2002** | https://www.planalto.gov.br/ccivil_03/leis/l0662.htm e https://www.planalto.gov.br/ccivil_03/leis/2002/l10607.htm |
| 12/10 | Nossa Senhora Aparecida | Lei 6.802, de 30/6/1980, art. 1º | https://www.planalto.gov.br/ccivil_03/leis/l6802.htm |
| 20/11 | Dia Nacional de Zumbi e da Consciência Negra | **Lei 14.759, de 21/12/2023** (DOU de 22/12/2023), art. 1º. **Feriado nacional a partir de 2024** | https://www.planalto.gov.br/ccivil_03/_ato2023-2026/2023/lei/l14759.htm |

**Não são feriado nacional por lei federal.** Ficam em colunas próprias, e cada artigo decide se usa:
- **Sexta-Feira da Paixão:** feriado **religioso municipal**. A Lei 9.093, de 12/9/1995, art. 2º, permite até quatro dias de guarda "declarados em lei municipal", "neste incluída a Sexta-Feira da Paixão" (https://www.planalto.gov.br/ccivil_03/leis/l9093.htm). Coluna `sexta_paixao`.
- **Carnaval** (segunda e terça), **Quarta-Feira de Cinzas** e **Corpus Christi:** não há lei federal; são pontos facultativos. Colunas `carnaval`, `quarta_cinzas` e `corpus_christi`.

## 2. Como o script garante a regra

- **Download e registro:** baixa as 5 páginas para `originais/` e registra cada uma no `logs/integridade.csv` (sistema `PLANALTO-lei`).
- **Conferência do texto, que é o que vale como garantia:** o script confere que o texto vigente contém cada data codificada:
  - as 7 da Lei 10.607;
  - "Redação dada pela Lei nº 10.607" na Lei 662;
  - 12 de outubro na Lei 6.802;
  - 20 de novembro na Lei 14.759;
  - "Sexta-Feira da Paixão" e "lei municipal" na Lei 9.093.
  
  Se faltar algum trecho, o script para.
- **O md5 do HTML não é estável:** o servidor do Planalto injeta, a cada requisição, um script de balanceador de carga (`f5_cspm`) com um token diferente. Dois downloads da mesma lei têm o mesmo texto legal, mas md5 diferentes, e às vezes até tamanho diferente, porque o script nem sempre vem (`l9093.htm`: 3.745 bytes num download e 5.304 no outro, em 05/10/2026; correção da auditoria A7). md5 de 05/10/2026: l0662 020b1cdf…; l10607 1164b4f4…; l6802 45ad19af…; l14759 83303d71…; l9093 9cd3b335….
- **Páscoa:** calculada por dois métodos independentes (algoritmo de Meeus/Jones/Butcher e `dateutil.easter`), que concordam nos 16 anos. As datas móveis derivam dela:

  | Data | Deslocamento em relação à Páscoa |
  |---|---|
  | Carnaval (segunda e terça) | −48 e −47 dias |
  | Quarta-Feira de Cinzas | −46 |
  | Sexta-Feira da Paixão | −2 |
  | Corpus Christi | +60 |
  
- **Contagens conferidas:** 8 feriados nacionais por ano em 2010–2023, 9 em 2024 e 1 em jan/2025 (122 no total). Por ano, 2 dias de Carnaval e 1 de cada uma das outras datas móveis.

**Páscoas de 2010 a 2025:**

| Ano | Páscoa | Ano | Páscoa |
|---|---|---|---|
| 2010 | 04/04 | 2018 | 01/04 |
| 2011 | 24/04 | 2019 | 21/04 |
| 2012 | 08/04 | 2020 | 12/04 |
| 2013 | 31/03 | 2021 | 04/04 |
| 2014 | 20/04 | 2022 | 17/04 |
| 2015 | 05/04 | 2023 | 09/04 |
| 2016 | 27/03 | 2024 | 31/03 |
| 2017 | 16/04 | 2025 | 20/04 |

**Leis citadas como "Vide" na página da Lei 662** (conferidas no Planalto em 05/10/2026, auditoria A13): a Lei 7.320/1985, que antecipava feriados para a segunda-feira, foi **revogada pela Lei 8.087/1990**; a Lei 7.466/1986 só excluía o 1º de Maio dessa antecipação. Em 2010–2025, os feriados caem na própria data.

## 3. Colunas

`data`, `ano`, `mes`, `dia_semana` (1 = segunda … 7 = domingo), `fim_de_semana`, `feriado_nacional` (0/1), `feriado_nome`, `base_legal`, `carnaval`, `quarta_cinzas`, `sexta_paixao` e `corpus_christi` (0/1).

## 4. Limitações

- **Feriados estaduais e municipais ficam fora:** datas magnas estaduais e feriados religiosos municipais, como a própria Sexta-Feira da Paixão. Eles afetam o agendamento de partos eletivos, mas exigiriam as leis de 26 UFs e de 277 municípios. Se algum artigo precisar, é uma extensão.
- **Pontes e pontos facultativos de cada ano** (por exemplo, os decretados por portaria federal) não estão incluídos.
