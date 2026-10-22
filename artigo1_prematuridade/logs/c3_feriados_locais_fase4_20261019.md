# Fase 4, Parte C3: sensibilidade dos feriados locais (tabela v1.1)

- **Gerado por:** `00_scripts/84_c3_feriados_locais_fase4.R` (SHA-256 `b06dc7d8ce387a560dad768a54f2be266dce56c5f58301e4a9cd2298936a2278`) e o módulo `00_scripts/fluxo_c_fase4.R` (`d2f563aeb3c1819b076ab6b1447ca3fc217801b59268a59a2be23f8bf77ebda5`), início em 2026-10-19 16:06:03 -0300, fim em 2026-10-19 16:06:06 -0300. Rodada `20261019`. `versao()`: 4443971b.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `1f205be851eb90b88fcbeb278f483a7a32af2713` (ramo `main`); último commit da `COORD` no `HEAD`: `b03d6c7 COORD: COORD-16 (push de 000aad4..6523bc0 ao a1-fase4 e tag feriados_locais-v1.1 no bc586c0)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: vazio.
- **Código (igual ao das tags):**
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `2acf21797f576a5a5c34a4cdab081a8bec2d09473d9993759e4d3409935eb68b` (`ajusta_dlnm-v1.1`);
  - `codigo_compartilhado/R/segunda_etapa.R`: `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7` (`segunda_etapa-v1.1`);
  - `codigo_compartilhado/R/sens_agudos.R`: `22baa6ea8e952654a5aca25220d1b3b18130ec36862e12d0a6701b184e201dbc` (`sens_agudos-v1.0`);
  - `codigo_compartilhado/tests/teste3_fonte_independente.R`: `547389f5c256edf1bebf9e7542fb32c70997808cf39d4191a3ce1197871ee2f3` (`segunda_etapa-v1.1`);
- **Tabela de feriados locais:** tag `feriados_locais-v1.1` (commit `bc586c0`), `codigo_compartilhado/dados_referencia/feriados_locais_nucleo_2011_2024.csv`, SHA-256 `4a3d4f15bc51125c892cfb2acf55d542d7146b02161c1a7a2b151f64183a5fca`, 1.178 linhas, 26 núcleos.
- **Entradas (SHA-256 = registrados):**
  - `01_saidas/fase4/serie_ptb_fase4.rds`: `e70190c1bf7c0fa5ba9c9f1e3cacb46f1ef8d647fc04a8606d181f7c819793e0`;
  - `01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds`: `5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d`;
  - `01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds`: `52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e`;
  - `01_saidas/fase1/referencias_exposicao.csv`: `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467`;
- **Decisões de implementação:** no cabeçalho do script e na A1-119.

## Indicador (dias da janela principal; contagem de calendário, sem desfecho)

| Concentração | Dias com o indicador | Da tabela | 24/12 e 31/12 |
|---|---|---|---|
| São Paulo/SP |  65 | 41 | 24 |
| Rio de Janeiro/RJ |  73 | 49 | 24 |
| Belo Horizonte/MG |  49 | 25 | 24 |
| Brasília/DF |  36 | 12 | 24 |
| Recife/PE |  77 | 53 | 24 |
| Porto Alegre/RS |  48 | 24 | 24 |
| Fortaleza/CE |  64 | 40 | 24 |
| Curitiba/PR |  39 | 15 | 24 |
| Salvador/BA |  64 | 40 | 24 |
| Goiânia/GO |  74 | 50 | 24 |
| Campinas/SP |  62 | 38 | 24 |
| Manaus |  72 | 48 | 24 |
| Belém/PA |  48 | 24 | 24 |
| Vitória/ES |  66 | 42 | 24 |
| Baixada Santista/SP |  73 | 49 | 24 |
| São José dos Campos/SP |  63 | 39 | 24 |
| São Luís/MA |  76 | 52 | 24 |
| Natal/RN |  70 | 46 | 24 |
| Maceió/AL | 106 | 82 | 24 |
| Florianópolis/SC |  60 | 36 | 24 |
| João Pessoa/PB |  66 | 42 | 24 |
| Teresina/PI |  63 | 39 | 24 |
| Aracaju/SE |  74 | 50 | 24 |
| Cuiabá/MT |  60 | 36 | 24 |
| Sorocaba/SP |  62 | 38 | 24 |
| Campo Grande |  61 | 37 | 24 |

- Nenhuma data do indicador coincide com `feriado_nacional`, `carnaval` ou `moveis`.

## Resultado (sensibilidade descritiva; sem critério de concordância)

| Análise | TMR °C (percentil) | IC da TMR | RR x99 (IC) | RR x1 (IC) | N | Fallback | φ (mín.; med.; máx.) | Teste 3 | Q (gl); I² |
|---|---|---|---|---|---|---|---|---|---|
| Calendário: feriados locais (tabela v1.1, mais 24/12 e 31/12; D11, 3.3; D17) | 28,1 (93,1) | 18,8 a 29,5 | 1,004 (0,978 a 1,031) | 1,020 (0,991 a 1,051) | 26 | nenhum | 0,979; 1,009; 1,117 | 26/26 | 94,3 (92); 2,4% |

- **Principal (Fase 3), para comparação:** TMR 28,2 °C (percentil 93,8); RR x99 1,003 (0,978 a 1,029); RR x1 1,020 (0,990 a 1,051).
- Nenhuma concentração saiu por falha de ajuste.

## Saídas (fora do git)

- `01_saidas/fase4/c3_feriados_locais_fase4_20261019.rds`: `66037e88eefdc64f229dae7b166ed852b0b2d4add702c41f5773321073015772`;
- `01_saidas/fase4/c3_feriados_locais_fase4_20261019.csv`: `443532cc1eae8d6e5841fd8e996ae4ed0854114a4c89c94c3a003080b5c8cb6b`;

- **Resultado:** ok; tempo 0.1 min.

