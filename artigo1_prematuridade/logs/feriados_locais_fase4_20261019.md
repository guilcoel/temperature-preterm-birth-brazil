# Fase 4, Parte B2: feriados locais dos núcleos (validação e patch para a COORD)

- **Gerado por:** `00_scripts/69_feriados_locais_fase4.R` (SHA-256 `8b4f0ad0b7155bac7d5638a85621a4902621fd1e423ec47c05ddc80304a0aee8`), início em 2026-10-19 11:04:05 -0300, fim em 2026-10-19 11:04:05 -0300. Rodada `20261019`. `versao()` no início e no fim: 4443971b.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `6af48bcddf711bae73088203acc9f29f0ccd0d60` (ramo `main`); último commit da `COORD` no `HEAD`: `63a2342 COORD: COORD-9 (pausa da COORD e novo modo de trabalho do A1, 19/10)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: vazio.
- **Entrada:** `01_saidas/fase4/feriados/feriados_locais_nucleo_2011_2024.csv` (SHA-256 `ef5d99b1bfb1d0a33f44ad057e8b542015ce61aa9da5fb3d73caf117daba2e03`; 1.103 linhas) e `01_saidas/fase4/feriados/README_feriados_locais.md` (SHA-256 `2dc6fac8b4618294911b4dc45fb5a70dd66be60c3f0b36ea28d920dfbea37dcb`).

## Validação

- Esquema, núcleos, datas, esferas, URLs, sobreposição com os feriados nacionais e os móveis do modelo, 24/12, 31/12, 20/11 de 2024 e duplicatas: tudo confere.

## Datas por núcleo (2011–2024)

| Concentração | Cidade-núcleo | Estaduais | Municipais | Total |
|---|---|---|---|---|
| São Paulo/SP | São Paulo | 15 | 30 | 45 |
| Rio de Janeiro/RJ | Rio de Janeiro | 31 | 24 | 55 |
| Belo Horizonte/MG | Belo Horizonte |  0 | 29 | 29 |
| Brasília/DF | Brasília |  0 |  0 |  0 |
| Recife/PE | Recife | 13 | 42 | 55 |
| Porto Alegre/RS | Porto Alegre | 14 | 14 | 28 |
| Fortaleza/CE | Fortaleza | 12 | 33 | 45 |
| Curitiba/PR | Curitiba |  0 | 14 | 14 |
| Salvador/BA | Salvador | 15 | 29 | 44 |
| Goiânia/GO | Goiânia |  0 | 28 | 28 |
| Campinas/SP | Campinas | 15 | 27 | 42 |
| Manaus | Manaus | 27 | 28 | 55 |
| Belém/PA | Belém | 14 | 14 | 28 |
| Vitória/ES | Serra |  5 | 42 | 47 |
| Baixada Santista/SP | Santos | 15 | 40 | 55 |
| São José dos Campos/SP | São José dos Campos | 15 | 26 | 41 |
| São Luís/MA | São Luís | 15 | 42 | 57 |
| Natal/RN | Natal | 14 | 38 | 52 |
| Maceió/AL | Maceió | 42 | 28 | 70 |
| Florianópolis/SC | Florianópolis | 28 | 14 | 42 |
| João Pessoa/PB | João Pessoa | 12 | 34 | 46 |
| Teresina/PI | Teresina | 16 | 29 | 45 |
| Aracaju/SE | Aracaju | 14 | 42 | 56 |
| Cuiabá/MT | Cuiabá | 13 | 27 | 40 |
| Sorocaba/SP | Sorocaba | 15 | 27 | 42 |
| Campo Grande | Campo Grande | 14 | 28 | 42 |

## Verificação do patch num repositório temporário

| Caso | Esperado | Obtido |
|---|---|---|
| tabela real no caminho exato | 0 | 0 |
| cabeçalho errado no caminho exato | 1 | 1 |
| coluna a mais no caminho exato | 1 | 1 |
| .csv em outro caminho | 1 | 1 |

## Patch para a COORD (fora do git)

- `/Users/guilherme/Downloads/patch_feriados_locais_20261019.zip` (SHA-256 `db68a8b69930dbe86ac626e7a4c968095f28b3ca04b61ae8f7e39be4436f34c6`), com a tabela (`ef5d99b1bfb1d0a33f44ad057e8b542015ce61aa9da5fb3d73caf117daba2e03`), o README (`2dc6fac8b4618294911b4dc45fb5a70dd66be60c3f0b36ea28d920dfbea37dcb`), os três diffs, o `LEIAME_PATCH.md` e o `SHA256SUMS`.

- **Resultado:** validação e patch ok.

