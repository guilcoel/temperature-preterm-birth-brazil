# Fase 4, Parte B2: feriados locais v1.1 (D17; validação e patch para a COORD)

- **Gerado por:** `00_scripts/83_feriados_locais_v11_fase4.R` (SHA-256 `34fa72348cf1eb9974d461fdd575a2785fe38103f338cc49c80d4bf3bda0571f`), início em 2026-10-19 15:16:35 -0300, fim em 2026-10-19 15:16:36 -0300. Rodada `20261019_c`. `versao()` no início e no fim: 4443971b.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `89276b7401f446d9caed7bd66c1382b8c724a4de` (ramo `main`); último commit da `COORD` no `HEAD`: `def7706 COORD: COORD-14 (D17 e indice rev. 8 em spec/ no 0777184)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: vazio.
- **Entrada:** `01_saidas/fase4/feriados/feriados_locais_nucleo_2011_2024.csv` (SHA-256 `4a3d4f15bc51125c892cfb2acf55d542d7146b02161c1a7a2b151f64183a5fca`; 1.178 linhas, 26 núcleos) e `01_saidas/fase4/feriados/README_feriados_locais.md` (SHA-256 `d0efb9009966ab5f27e96642411cf897bcda37cdbdca1dfb805da34cfc76528d`). **v1.0:** tag `feriados_locais-v1.0` (`2ab924d`), tabela `ef5d99b1bfb1d0a33f44ad057e8b542015ce61aa9da5fb3d73caf117daba2e03` (1.103 linhas).

## Validação

- Esquema, núcleos, datas, esferas, URLs, sobreposição com os feriados nacionais e os móveis do modelo, 24/12, 31/12, 20/11 de 2024, duplicatas e as datas citadas na D17: tudo confere.
- **D17, 2c:** DF 30/11 em 2011–2024; AL 30/11 em 2018–2024; AL 16/09 em 2011, 2012, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024 (de 2011 a 2023, só nos anos com o decreto achado; os ausentes estão no README).

## Diferença contra a v1.0 (por concentração × data)

- **Novas:** 77. **Removidas:** 2. **Alteradas** (nome, esfera, ato ou URL): 14.

| Concentração | v1.0 | Novas | Removidas | Alteradas | v1.1 |
|---|---|---|---|---|---|
| Brasília/DF |  0 | 14 | 0 |  0 | 14 |
| Recife/PE | 55 |  5 | 0 |  0 | 60 |
| Curitiba/PR | 14 |  4 | 0 |  0 | 18 |
| Goiânia/GO | 28 | 28 | 0 | 14 | 56 |
| São Luís/MA | 57 |  4 | 2 |  0 | 59 |
| Maceió/AL | 70 | 22 | 0 |  0 | 92 |

## Datas por núcleo (2011–2024), v1.1

| Concentração | Cidade-núcleo | Estaduais | Municipais | Total |
|---|---|---|---|---|
| São Paulo/SP | São Paulo | 15 | 30 | 45 |
| Rio de Janeiro/RJ | Rio de Janeiro | 31 | 24 | 55 |
| Belo Horizonte/MG | Belo Horizonte |  0 | 29 | 29 |
| Brasília/DF | Brasília | 14 |  0 | 14 |
| Recife/PE | Recife | 13 | 47 | 60 |
| Porto Alegre/RS | Porto Alegre | 14 | 14 | 28 |
| Fortaleza/CE | Fortaleza | 12 | 33 | 45 |
| Curitiba/PR | Curitiba |  3 | 15 | 18 |
| Salvador/BA | Salvador | 15 | 29 | 44 |
| Goiânia/GO | Goiânia | 42 | 14 | 56 |
| Campinas/SP | Campinas | 15 | 27 | 42 |
| Manaus | Manaus | 27 | 28 | 55 |
| Belém/PA | Belém | 14 | 14 | 28 |
| Vitória/ES | Serra |  5 | 42 | 47 |
| Baixada Santista/SP | Santos | 15 | 40 | 55 |
| São José dos Campos/SP | São José dos Campos | 15 | 26 | 41 |
| São Luís/MA | São Luís | 17 | 42 | 59 |
| Natal/RN | Natal | 14 | 38 | 52 |
| Maceió/AL | Maceió | 60 | 32 | 92 |
| Florianópolis/SC | Florianópolis | 28 | 14 | 42 |
| João Pessoa/PB | João Pessoa | 12 | 34 | 46 |
| Teresina/PI | Teresina | 16 | 29 | 45 |
| Aracaju/SE | Aracaju | 14 | 42 | 56 |
| Cuiabá/MT | Cuiabá | 13 | 27 | 40 |
| Sorocaba/SP | Sorocaba | 15 | 27 | 42 |
| Campo Grande | Campo Grande | 14 | 28 | 42 |

## Verificação com o `checa_sigilo.sh` do `HEAD` num repositório temporário

| Caso | Esperado | Obtido |
|---|---|---|
| tabela v1.1 no caminho exato | 0 | 0 |
| cabeçalho errado no caminho exato | 1 | 1 |
| coluna a mais no caminho exato | 1 | 1 |
| .csv em outro caminho | 1 | 1 |

## Patch para a COORD (fora do git)

- `/Users/guilherme/Downloads/patch_feriados_locais_v1.1_20261019_c.zip` (SHA-256 `6eaadec7c2a34d59d1c41a391121ddc502801c90d88ae539f59fd525fa735f0a`), com a tabela (`4a3d4f15bc51125c892cfb2acf55d542d7146b02161c1a7a2b151f64183a5fca`), o README (`d0efb9009966ab5f27e96642411cf897bcda37cdbdca1dfb805da34cfc76528d`), o `LEIAME_PATCH.md` e o `SHA256SUMS`.

- **Resultado:** validação e patch ok.

