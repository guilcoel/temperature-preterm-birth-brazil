# Fase 4, Parte B1.5: contagens e insumos dos metapreditores

- **Gerado por:** `00_scripts/68_contagens_insumos_fase4.R` (SHA-256 `7968ce3555128f1c10025d36a93910ad9d86cc72894e9a3eb34d92b075151642`), início em 2026-10-18 21:34:18 -0300, fim em 2026-10-18 21:34:52 -0300. Rodada `20261018`. `versao()` no início: 4443971b; no fim: 4443971b.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `928a965df33ed10311f0f9afe625d2460ca9e448` (ramo `main`); último commit da `COORD` no `HEAD`: `a925d35 COORD: COORD-8 (tags da Fase 4, Parte A do A1)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: `?? artigo1_prematuridade/logs/ig_dum_e_2011_fase4_20261018.md`; `?? artigo1_prematuridade/logs/percentis_exposicao_fase4_20261018.md`; `?? artigo1_prematuridade/logs/reconferencia_series_fase1_fase4_20261018.md`; `?? artigo1_prematuridade/logs/series_exposicao_offset_fase4_20261018.md`.
- **Código (igual ao das tags):** `offset.R` `b2aac93b4681c26d74427172bcdd3adb62fbf8cd75bea97910153892e12ed398` (`offset-v1.1`); `segunda_etapa.R` `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7` (`segunda_etapa-v1.1`; só a ordem das 26).
- **Entradas (SHA-256):**
  - `01_saidas/fase1/serie_ptb_principal.rds`: `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917`;
  - `01_saidas/fase1/serie_ptb_espontaneo.rds`: `654ecbf5cda28dc066709d99238a11370c1205da0f08183152fb326df9a99af7`;
  - `01_saidas/fase4/serie_ig_dum_fase4.rds`: `d001ef8eb884bcfda5f41434be19cad49b89e4251444fae21d612f36dd5e3e6b`;
  - `01_saidas/fase4/serie_termo_precoce_fase4.rds`: `e54408d7c7d084c6ddfaab864f578e52da809c122f3ee76f614b41af253ec369`;

## Conferências

| Conferência | Confere |
|---|---|
| Identidades: extremo + muito + moderado-tardio = PTB; espontâneo (i) + ignorado = (ii); (ii) + iniciado = PTB; §3.5 (i) ≤ PTB; termo na interseção ≤ na janela | sim |
| SHA-256 do `RESPOSTA_QUESTIONAMENTO_20261007.md` = registrado (`16fe31e9…011e`) | sim |
| Q8 lida do arquivo: semanas 22–42, total 13.791.848 | sim |
| Q8 recontada pela interface (população do principal, nascidos em 2012–2024) = Q8 do arquivo | sim |
| Referência do PTB na calibração (EP de 0,07 a 0,14, ±10%; γ estimado) | sim |
| População da D15 = definição explícita | sim |
| Macrorregiões = (2, 9, 8, 3, 4), como a §6 | sim |

## 1. Eventos por concentração

- Janela principal (2012-04-14 a 2024-08-06), salvo o termo precoce: na janela dele (2012-04-28 a 2024-11-19) e na interseção (2012-04-28 a 2024-08-06). "<10": contagem de 1 a 9; "s.c.": supressão complementar. Sem linha de total.
- Supressões complementares aplicadas: 0.

| Concentração | PTB | Extremo | Muito | Moderado-tardio | Espontâneo (i) | Espontâneo (ii) | §3.5 (i) | §3.5 (ii) | Termo precoce, janela | Termo precoce, interseção |
|---|---|---|---|---|---|---|---|---|---|---|
| São Paulo/SP | 335.025 | 16.139 | 29.462 | 289.424 | 142.917 | 148.184 | 153.698 | 152.953 | 1.123.490 | 1.103.310 |
| Rio de Janeiro/RJ | 182.818 | 8.724 | 17.660 | 156.434 | 88.333 | 100.892 | 76.267 | 76.545 | 581.120 | 570.547 |
| Belo Horizonte/MG | 74.772 | 3.857 | 7.342 | 63.573 | 33.265 | 34.377 | 30.401 | 30.143 | 248.621 | 243.982 |
| Brasília/DF | 68.110 | 3.287 | 6.266 | 58.557 | 31.620 | 42.545 | 52.175 | 52.266 | 207.734 | 203.494 |
| Recife/PE | 66.373 | 2.953 | 5.782 | 57.638 | 38.850 | 40.211 | 40.623 | 40.565 | 203.274 | 199.353 |
| Porto Alegre/RS | 58.605 | 2.425 | 4.788 | 51.392 | 23.479 | 24.450 | 12.144 | 12.215 | 184.289 | 180.853 |
| Fortaleza/CE | 62.530 | 3.023 | 5.933 | 53.574 | 30.441 | 38.659 | 38.318 | 38.590 | 163.130 | 159.220 |
| Curitiba/PR | 45.773 | 2.252 | 4.424 | 39.097 | 18.282 | 25.463 | 9.995 | 10.008 | 179.266 | 175.772 |
| Salvador/BA | 49.778 | 3.211 | 5.189 | 41.378 | 24.841 | 29.254 | 18.280 | 18.382 | 135.977 | 133.233 |
| Goiânia/GO | 42.244 | 1.755 | 3.654 | 36.835 | 21.826 | 30.631 | 23.726 | 23.880 | 142.670 | 139.212 |
| Campinas/SP | 33.354 | 1.609 | 3.314 | 28.431 | 19.341 | 20.603 | 13.355 | 13.311 | 103.139 | 101.149 |
| Manaus | 45.564 | 2.245 | 4.924 | 38.395 | 33.216 | 37.938 | 15.285 | 15.530 | 103.842 | 101.739 |
| Belém/PA | 41.518 | 1.750 | 3.656 | 36.112 | 27.758 | 29.516 | 32.368 | 32.677 | 115.339 | 113.112 |
| Vitória/ES | 27.150 | 1.268 | 2.635 | 23.247 | 13.027 | 14.136 | 10.363 | 10.402 | 74.167 | 72.369 |
| Baixada Santista/SP | 25.520 | 1.048 | 2.275 | 22.197 | 11.601 | 12.358 | 13.434 | 13.230 | 79.611 | 78.022 |
| São José dos Campos/SP | 26.377 | 1.132 | 2.246 | 22.999 | 10.634 | 12.126 | 18.435 | 18.483 | 87.999 | 86.331 |
| São Luís/MA | 29.093 | 1.344 | 2.563 | 25.186 | 17.800 | 21.495 | 23.823 | 24.074 | 71.950 | 70.369 |
| Natal/RN | 25.665 | 1.206 | 2.468 | 21.991 | 12.037 | 14.194 | 16.889 | 16.885 | 66.681 | 65.159 |
| Maceió/AL | 22.492 | 909 | 1.826 | 19.757 | 14.579 | 15.847 | 15.908 | 15.953 | 59.348 | 58.089 |
| Florianópolis/SC | 13.943 | 611 | 1.204 | 12.128 | 7.636 | 8.091 | 5.624 | 5.675 | 43.313 | 42.261 |
| João Pessoa/PB | 19.500 | 808 | 1.597 | 17.095 | 12.093 | 13.085 | 15.471 | 15.574 | 59.134 | 57.755 |
| Teresina/PI | 20.111 | 871 | 1.725 | 17.515 | 15.981 | 17.259 | 12.694 | 12.760 | 52.965 | 51.795 |
| Aracaju/SE | 16.618 | 832 | 1.361 | 14.425 | 6.212 | 6.295 | 2.684 | 2.712 | 46.118 | 45.192 |
| Cuiabá/MT | 16.986 | 705 | 1.424 | 14.857 | 8.202 | 8.574 | 5.209 | 5.328 | 62.620 | 61.278 |
| Sorocaba/SP | 13.393 | 575 | 1.101 | 11.717 | 6.203 | 6.362 | 4.153 | 4.127 | 48.974 | 47.932 |
| Campo Grande | 14.718 | 664 | 1.280 | 12.774 | 10.393 | 10.471 | 4.204 | 4.208 | 51.249 | 50.213 |

## 2. Listas da regra de < 1.000 eventos (janela principal)

| Desfecho | Concentrações com < 1.000 (saem da meta-análise desse desfecho) | Entram |
|---|---|---|
| Subtipo extremo (D12, 4.1) | Maceió/AL, Florianópolis/SC, João Pessoa/PB, Teresina/PI, Aracaju/SE, Cuiabá/MT, Sorocaba/SP, Campo Grande | 18 |
| Subtipo muito (D12, 4.1) | nenhuma | 26 |
| Subtipo moderado-tardio (D12, 4.1) | nenhuma | 26 |
| §3.5, versão (i) (A1-98) | nenhuma | 26 |
| §3.5, versão (ii) (A1-98) | nenhuma | 26 |

- **PTB espontâneo (i):** concentrações com < 1.000 eventos: nenhuma.

## 3. Regra única de γ (§3.2; D12, 4.1; A1-89), com a Q8

| Desfecho | Semanas | Pesos | Eventos (Q8) | EP, cosseno | EP, pico | γ |
|---|---|---|---|---|---|---|
| Subtipo extremo | 22–27 | por gestação | 66.699 | 4,598 | 1,617 | γ = 1 |
| Subtipo muito | 28–31 | por gestação | 128.951 | 6,808 | 1,360 | γ = 1 |
| Subtipo moderado-tardio | 32–36 | por gestação | 1.210.047 | 0,735 | 0,175 | estimado |
| Termo precoce (pessoa-dia) | 37–38 | por pessoa-dia | 4.307.836 | 1,585 | 0,266 | γ = 1 |
| PTB (referência da calibração) | 22–36 | por gestação | 1.405.697 | 0,141 | 0,070 | estimado |

- γ = 1 quando o EP aproximado é ≥ 1 em algum dos dois cenários; senão, γ estimado (`decide_gama` do offset v1.1).

## 4. `consultas_cat` por ano (população da D15)

| Ano | NV | 1 (nenhuma), % | 2 (1–3), % | 3 (4–6), % | 4 (7 ou mais), % | 9 ou vazio, % | Código fora de {1, 2, 3, 4, 9} | 4 entre os válidos, % |
|---|---|---|---|---|---|---|---|---|
| 2012 | 1.134.128 | 2,14 | 6,64 | 25,51 | 64,66 | 1,06 | 0 | 65,35 |
| 2013 | 1.161.229 | 2,05 | 6,60 | 24,92 | 65,37 | 1,06 | 0 | 66,07 |
| 2014 | 1.202.373 | 1,98 | 6,36 | 24,41 | 66,35 | 0,90 | 0 | 66,95 |
| 2015 | 1.220.864 | 1,92 | 6,04 | 23,61 | 67,70 | 0,73 | 0 | 68,20 |
| 2016 | 1.155.936 | 1,88 | 5,86 | 22,61 | 68,97 | 0,68 | 0 | 69,45 |
| 2017 | 1.173.675 | 1,81 | 5,67 | 21,32 | 70,64 | 0,56 | 0 | 71,04 |
| 2018 | 1.162.650 | 1,60 | 5,71 | 20,93 | 71,21 | 0,56 | 0 | 71,61 |
| 2019 | 1.115.281 | 1,47 | 5,57 | 20,16 | 72,21 | 0,58 | 0 | 72,64 |
| 2020 | 1.055.816 | 1,61 | 6,30 | 20,45 | 70,89 | 0,75 | 0 | 71,43 |
| 2021 | 1.013.177 | 1,55 | 5,71 | 18,92 | 73,10 | 0,73 | 0 | 73,64 |
| 2022 | 972.576 | 1,45 | 5,49 | 18,50 | 73,73 | 0,83 | 0 | 74,34 |
| 2023 | 956.105 | 1,43 | 4,99 | 17,17 | 75,99 | 0,41 | 0 | 76,30 |
| 2024 | 897.834 | 1,41 | 4,60 | 15,80 | 77,81 | 0,38 | 0 | 78,10 |

| Critério | Atende |
|---|---|
| (a) códigos 1–4 presentes em todo ano; nenhum fora de {1, 2, 3, 4, 9} | sim |
| (b) ignorado ≤ 10% em todo ano | sim |
| (c) variação do % de ignorado entre anos ≤ 5 pontos | sim |
| (d) variação do % do código 4 entre os válidos ≤ 10 pontos | sim |

- **Resultado:** códigos e completude estáveis; a cobertura de pré-natal é calculada.

## 5. Insumos dos metapreditores (D15; população da D15, um valor por concentração)

| Concentração | % cesárea | Parto ignorado | % com 7 ou mais consultas | Consultas ignoradas | Macrorregião |
|---|---|---|---|---|---|
| São Paulo/SP | 52,3 | 423 | 77,0 | 10.578 | Sudeste |
| Rio de Janeiro/RJ | 55,5 | 618 | 71,3 | 28.717 | Sudeste |
| Belo Horizonte/MG | 46,0 | 123 | 76,2 | 2.325 | Sudeste |
| Brasília/DF | 51,9 | 475 | 70,1 | 5.767 | Centro-Oeste |
| Recife/PE | 50,6 | 541 | 62,3 | 8.532 | Nordeste |
| Porto Alegre/RS | 51,6 | 61 | 74,5 | 1.406 | Sul |
| Fortaleza/CE | 64,1 | 673 | 65,6 | 2.877 | Nordeste |
| Curitiba/PR | 56,4 | 206 | 84,6 | 2.206 | Sul |
| Salvador/BA | 48,2 | 531 | 59,7 | 9.156 | Nordeste |
| Goiânia/GO | 69,5 | 469 | 70,7 | 2.451 | Centro-Oeste |
| Campinas/SP | 63,7 | 64 | 82,2 | 3.423 | Sudeste |
| Manaus | 48,9 | 111 | 50,1 | 5.151 | Norte |
| Belém/PA | 64,6 | 121 | 56,2 | 1.165 | Norte |
| Vitória/ES | 59,4 | 51 | 68,2 | 1.182 | Sudeste |
| Baixada Santista/SP | 54,9 | 87 | 77,6 | 553 | Sudeste |
| São José dos Campos/SP | 63,0 | 91 | 80,9 | 1.519 | Sudeste |
| São Luís/MA | 54,7 | 310 | 50,9 | 1.102 | Nordeste |
| Natal/RN | 60,9 | 154 | 65,4 | 3.015 | Nordeste |
| Maceió/AL | 60,5 | 77 | 55,1 | 2.244 | Nordeste |
| Florianópolis/SC | 49,5 | 240 | 74,2 | 1.880 | Sul |
| João Pessoa/PB | 57,8 | 73 | 63,7 | 3.072 | Nordeste |
| Teresina/PI | 60,6 | 126 | 59,6 | 2.012 | Nordeste |
| Aracaju/SE | 47,2 | <10 | 58,5 | 236 | Nordeste |
| Cuiabá/MT | 55,6 | 44 | 69,1 | 594 | Centro-Oeste |
| Sorocaba/SP | 55,4 | <10 | 86,5 | 763 | Sudeste |
| Campo Grande | 61,0 | 0 | 68,0 | 216 | Centro-Oeste |

- **Macrorregiões:** Norte 2; Nordeste 9; Sudeste 8; Sul 3; Centro-Oeste 4.

## 6. IDHM 2010: não baixado (PARE do item B1.5)

- O site do Atlas (`www.atlasbrasil.org.br`) não tem arquivo estático da tabela municipal do IDHM 2010: o caminho antigo dos dados brutos (`/2013/data/rawData/atlas2013_dadosbrutos_pt.xlsx`) dá 404 no `www`; o domínio sem `www` responde com certificado autoassinado (não contornado); a tabela só sai pela ferramenta de consulta (`/consulta/planilha`), que monta a planilha por POST à API do próprio site (`/api/dadosgridDowload`) depois de escolher indicadores e territórios, ou seja, um formulário.
- Pela mensagem ("se o download exigir conta, formulário ou outro domínio, PARE e informe"), nada foi baixado. O IDHM só entra na meta-regressão exploratória da C4 e não bloqueia a C1. Decisão para Guilherme e o chat.

## Saídas (fora do git; contagens sem máscara, só para uso interno)

- `01_saidas/fase4/contagens_insumos_fase4.csv`: `a7e1f60a46574c2cc60b1436406b5bc245228c8a33ea58bbe14f7a5117c946c3`;
- `01_saidas/fase4/consultas_cat_por_ano_fase4.csv`: `2f9c8cc8ad8d9cef2278ac1b5dd61e48f2ad8f64e0968e1fe1b2d5a630d22b52`;

- **Resultado:** todas as conferências passam; nenhuma parada. Tempo: 34 s.

