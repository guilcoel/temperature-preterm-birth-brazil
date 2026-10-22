# A7: população da sensibilidade da §3.5 (IG pela DUM), Fase 0 refeita

- **Gerado por:** `00_scripts/09_populacao_dum_rerun.R`, em 2026-10-09 08:58:06 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Descritivo, sem exposição:** contagens de NV e PTB por concentração e por ano, por disponibilidade e concordância da DUM. Nenhum desfecho cruzado com temperatura, PM2.5, estação, mês ou macrorregião.
- **População (a do PTB):** `pop_ptb` (único, `ga_sem` de 22 a 42) e `coorte_fixa_22`, residentes nas 26 concentrações (277 municípios), com parto na janela principal, de 2012-04-14 a 2024-08-06. Lida por `nascimentos()`; agregada em memória.
  - **Conferências da definição (contagem de divergências):** `pop_ptb` × (`unico` e `ga_sem` de 22 a 42) = 0; `ptb` × (`pop_ptb` e `ga_sem` ≤ 36) = 0; município fora das 26 = 0; `ga_sem` NA na população = 0.
- **IG usada (papel do `SEMAGESTAC` na regra de concordância):** `ga_sem`, a coluna que a definição do `ptb` usa (`06b_desfechos.py`: `ptb = pop_ptb & ga_sem <= 36`). Pelo `DICIONARIO.md` (linha 80), o `SEMAGESTAC` está no `ga_sem` (só 22–44) e no `semagestac_bruto` (texto); como a população já é de 22 a 42 semanas, a perda dos SEMAGESTAC 20, 21 e 45 que o `ga_sem` causaria não afeta esta população.
- **Níveis:** **(a)** todos; **(b)** DUM plausível, `ig_dum_sem` de 20 a 45, inclusive; **(c)** (b) e |`ga_sem` − `ig_dum_sem`| ≤ 1. Percentual mantido = nível / (a).
- **Por ano:** só de 2013 a 2023, com as 26 concentrações somadas (decisão de Guilherme, 09/10/2026: 2012 e 2024 não são anos inteiros na janela principal). Nenhuma contagem por concentração × ano sai.
- **CSV (fora do git, já mascarados):** `01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv` e `01_saidas/fase0_rerun/a7_populacao_dum_ano.csv`.

## Reconciliação

| Conferência | Resultado |
|---|---|
| (a) por concentração, NV = soma de `nv_unicos` da série diária na janela principal | bate |
| (a) por concentração, PTB = soma de `ptb` da série diária na janela principal | bate |
| (a) PTB por concentração = "Na janela" da A5.2 refeita (`a5_2_eventos_janelas.csv`, PTB, principal) | bate |
| Cada concentração × período (26 × 13), NV, = série diária (interno; não sai) | bate |
| Cada concentração × período (26 × 13), PTB, = série diária (interno; não sai) | bate |
| (a) por ano, 2013–2023, NV e PTB = série diária | bate |
| (a) por ano, 2013–2023, NV e PTB = `logs/totais_anuais.csv` da base (`versao` = principal) | bate |

## 1. Por concentração, janela principal inteira

| Concentração | NV (a) | NV (b) | % (b) | NV (c) | % (c) | PTB (a) | PTB (b) | % (b)  | PTB (c) | % (c)  |
|---|---|---|---|---|---|---|---|---|---|---|
| São Paulo/SP | 3.405.716 | 1.314.991 | 38,61 | 1.314.647 | 38,60 | 335.025 | 153.987 | 45,96 | 153.793 | 45,90 |
| Rio de Janeiro/RJ | 1.804.615 | 586.754 | 32,51 | 586.578 | 32,50 | 182.818 | 76.404 | 41,79 | 76.328 | 41,75 |
| Belo Horizonte/MG | 753.290 | 270.301 | 35,88 | 270.248 | 35,88 | 74.772 | 30.447 | 40,72 | 30.426 | 40,69 |
| Brasília/DF | 651.657 | 449.967 | 69,05 | 449.696 | 69,01 | 68.110 | 52.316 | 76,81 | 52.217 | 76,67 |
| Recife/PE | 619.222 | 353.373 | 57,07 | 353.286 | 57,05 | 66.373 | 40.698 | 61,32 | 40.661 | 61,26 |
| Fortaleza/CE | 545.006 | supr. | — | 307.251 | 56,38 | 62.530 | supr. | — | 38.349 | 61,33 |
| Porto Alegre/RS | 570.119 | 92.028 | 16,14 | 92.004 | 16,14 | 58.605 | 12.163 | 20,75 | 12.150 | 20,73 |
| Salvador/BA | 517.387 | 164.392 | 31,77 | 164.354 | 31,77 | 49.778 | 18.328 | 36,82 | 18.314 | 36,79 |
| Curitiba/PR | 520.743 | 66.700 | 12,81 | 66.686 | 12,81 | 45.773 | supr. | — | 10.002 | 21,85 |
| Manaus | 448.303 | 108.900 | 24,29 | 108.871 | 24,29 | 45.564 | supr. | — | 15.298 | 33,57 |
| Goiânia/GO | 402.086 | 192.331 | 47,83 | 192.285 | 47,82 | 42.244 | 23.755 | 56,23 | 23.742 | 56,20 |
| Belém/PA | 327.348 | 201.937 | 61,69 | 201.905 | 61,68 | 41.518 | supr. | — | 32.384 | 78,00 |
| Campinas/SP | 310.733 | 107.635 | 34,64 | 107.618 | 34,63 | 33.354 | supr. | — | 13.362 | 40,06 |
| São Luís/MA | 241.811 | 192.870 | 79,76 | 192.789 | 79,73 | 29.093 | 23.893 | 82,13 | 23.855 | 82,00 |
| Vitória/ES | 301.410 | supr. | — | 76.035 | 25,23 | 27.150 | supr. | — | 10.368 | 38,19 |
| São José dos Campos/SP | 234.971 | 150.220 | 63,93 | 150.195 | 63,92 | 26.377 | supr. | — | 18.448 | 69,94 |
| Natal/RN | 204.098 | 126.082 | 61,78 | 126.048 | 61,76 | 25.665 | 16.924 | 65,94 | 16.902 | 65,86 |
| Baixada Santista/SP | 250.371 | 114.256 | 45,63 | 114.225 | 45,62 | 25.520 | 13.463 | 52,75 | 13.442 | 52,67 |
| Maceió/AL | 206.963 | 136.138 | 65,78 | 136.126 | 65,77 | 22.492 | supr. | — | 15.915 | 70,76 |
| Teresina/PI | 182.983 | supr. | — | 101.335 | 55,38 | 20.111 | supr. | — | 12.702 | 63,16 |
| João Pessoa/PB | 197.481 | 140.882 | 71,34 | 140.838 | 71,32 | 19.500 | 15.499 | 79,48 | 15.483 | 79,40 |
| Cuiabá/MT | 174.798 | 42.899 | 24,54 | 42.879 | 24,53 | 16.986 | supr. | — | 5.210 | 30,67 |
| Aracaju/SE | 177.102 | supr. | — | 19.949 | 11,26 | 16.618 | supr. | — | 2.690 | 16,19 |
| Campo Grande | 160.347 | 32.365 | 20,18 | 32.352 | 20,18 | 14.718 | supr. | — | 4.209 | 28,60 |
| Florianópolis/SC | 161.160 | 54.535 | 33,84 | 54.509 | 33,82 | 13.943 | supr. | — | 5.628 | 40,36 |
| Sorocaba/SP | 140.194 | supr. | — | 35.683 | 25,45 | 13.393 | supr. | — | 4.155 | 31,02 |
| **26 somadas** | 13.509.914 | supr. | — | 5.438.392 | 40,25 | 1.378.030 | supr. | — | 666.033 | 48,33 |

- **Percentual mantido em (b):** NV de 12,81% a 79,76% (nas 21 concentrações com a célula publicada; as outras 5 estão suprimidas); PTB de 20,75% a 82,13% (nas 12 concentrações com a célula publicada; as outras 14 estão suprimidas).
- **Percentual mantido em (c):** NV de 11,26% a 79,73% (26 concentrações); PTB de 16,19% a 82,00% (26 concentrações).
- **Concentrações com 1.000 PTB ou mais em (c):** 26 de 26.

## 2. Por ano, 26 concentrações somadas (2013–2023)

| Ano | NV (a) | NV (c) | % (c) | PTB (a) | PTB (c) | % (c)  |
|---|---|---|---|---|---|---|
| 2013 | 1.161.229 | 623.264 | 53,67 | 124.103 | 77.587 | 62,52 |
| 2014 | 1.202.373 | 563.433 | 46,86 | 122.514 | 68.857 | 56,20 |
| 2015 | 1.220.864 | 499.924 | 40,95 | 118.949 | 58.973 | 49,58 |
| 2016 | 1.155.936 | 436.212 | 37,74 | 114.465 | 55.168 | 48,20 |
| 2017 | 1.173.675 | 438.043 | 37,32 | 114.113 | 51.538 | 45,16 |
| 2018 | 1.162.650 | 446.496 | 38,40 | 113.704 | 51.263 | 45,08 |
| 2019 | 1.115.281 | 412.798 | 37,01 | 109.389 | 48.223 | 44,08 |
| 2020 | 1.055.816 | 378.186 | 35,82 | 105.638 | 46.183 | 43,72 |
| 2021 | 1.013.177 | 355.208 | 35,06 | 101.787 | 41.728 | 41,00 |
| 2022 | 972.576 | 331.596 | 34,09 | 101.396 | 41.104 | 40,54 |
| 2023 | 956.105 | 319.693 | 33,44 | 100.718 | 39.658 | 39,38 |

## Sigilo

- **Regra:** contagem de 1 a 9 = "<10"; supressão complementar ("supr.") quando uma diferença entre níveis, ou entre NV e PTB, de 1 a 9 ficaria recuperável. O (a) do PTB por concentração já é público ("Na janela" da A5.2), e o (a) por ano também (totais anuais da base); por isso, quando uma diferença é pequena, sai o (b) ou o (c), nunca o (a) do PTB. O "%" sai "—" quando a célula dele está suprimida.
- **Supressões aplicadas:** 19 célula(s) na tabela por concentração (`nv_b` em 5, `ptb_b` em 14); 0 na tabela por ano. Na linha "26 somadas", a coluna que tem célula suprimida acima também sai "supr.": `nv_b`, `ptb_b`.
- **Por que só o (b) sai:** a concordância passa de 99,9%, então a diferença (b) − (c), DUM plausível e discordante, é a que fica pequena. As diferenças (a) − (b) e (a) − (c), de NV e de PTB, são ≥ 10 em todas as linhas das duas tabelas (conferido no código).
- **Prova (identificabilidade linear, por posto):**
  - **Átomos:** contagens de concentração (26) × período (13: a parte de 2012 na janela, 2013 a 2023, a parte de 2024 na janela) × PTB ou não PTB × nível da DUM (c; plausível e discordante; sem DUM plausível) = 2.028; mais as pontas fora da janela, por concentração × PTB ou não PTB × 4 trechos (2012-01-01..03, 2012-01-04..04-13, 2024-08-07..11-15, 2024-11-16..12-31) = 208.
  - **Tabelas publicadas no modelo (341 linhas, posto 236):** as duas desta A7 (só as células publicadas); a A5.2 do PTB (total 2012–2024, na janela e perda, nas janelas principal e de evento possível), que é também a da Fase 0A, do complemento, da ENTREGA §6 e do `criterios_inclusao_recorte.csv`; e os totais anuais das 26 (NV e PTB, 2012 a 2024), que são os da ENTREGA §5 e do `totais_anuais.csv`.
  - **Tabelas por subtipo** (PTB extremo, muito e moderado-tardio, nos totais anuais): todas as outras tabelas do modelo tratam os três subtipos do mesmo jeito, e os candidatos abaixo também; por simetria, as linhas por subtipo não identificam nada que a linha do PTB já não identifique.
  - **Candidatos:** 405 grupos de células (cada concentração na janela inteira; cada ano de 2013 a 2023; as partes de 2012 e de 2024 na janela, separadas e juntas; as 26 somadas; cada concentração nas duas partes; e cada concentração × período, que não é publicada) × as 63 combinações não vazias (das 64) dos 6 átomos (PTB e não PTB × 3 níveis) = 25.515 somas.
  - **Resultado:** 611 somas têm valor de 1 a 9; identificáveis entre elas: **0**. Controles: toda célula publicada é identificável (sim); nenhuma célula suprimida é (sim); 1.233 somas candidatas são identificáveis no total, o que mostra que o teste distingue.
  - **Combinações entre concentrações:** só as linhas do nível (b) por concentração separam o discordante (d) do sem DUM plausível (e); as linhas por ano, a linha "26 somadas" publicada e as tabelas externas trazem d e e sempre juntos. Assim, nenhuma soma de átomos de várias concentrações isola um d além do que a linha de cada concentração já isola, e as linhas por concentração estão todas entre os candidatos.

`versao()` no fim: 4443971b.
