# Fase 4, M5b: fluxograma de seleção (Figura S1) e dados ausentes (Tabela S6)

- **Gerado por:** `00_scripts/93_selecao_ausentes_m5b.R` (SHA-256 `e88ba5ffe90689e2660a3df312945ce77c796a584b613e8a27111c359a8a050d`), início em 2026-10-20 12:06:56 -0300, fim em 2026-10-20 12:07:13 -0300. Rodada `20261020`. `versao()`: 4443971b.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `b60ef124a0422508a60a54b877dc075e61c714b9` (ramo `main`); último commit da `COORD` no `HEAD`: `b03d6c7 COORD: COORD-16 (push de 000aad4..6523bc0 ao a1-fase4 e tag feriados_locais-v1.1 no bc586c0)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: vazio.
- **Entradas:** `01_saidas/fase4/serie_ptb_fase4.rds` (SHA-256 `e70190c1bf7c0fa5ba9c9f1e3cacb46f1ef8d647fc04a8606d181f7c819793e0`, igual ao registrado); `nascimentos()` da base `4443971b` (microdado; só contado); `logs/fluxograma_exclusoes.csv` da base (MD5 `28440d0d6207901807436c3fee481406`, igual ao da entrega da base).
- **Ordem das etapas:** a do código da base (`00_scripts/06b_desfechos.py`, `derivadas` e `logs_agregados`): gestação não única (`grav_cat` múltipla ou ignorada) → IG ausente, < 22 ou ≥ 45 (`ig_cat`) → IG de 43 a 44 → população da prematuridade (`pop_ptb`: única com IG de 22 a 42) → coorte fixa (`coorte_fixa_22`). A janela é pela data de nascimento (2012-04-14 a 2024-08-06). O critério de ≥ 90% de IG e peso válidos é por concentração e não exclui nascimentos.
- **Conferências:** a população da base é igual à reconstruída pelas categorias (`identical`); as partições de 2013 a 2023, por ano, são iguais às do fluxograma da base (iguais); a chegada é igual aos totais da série do principal (13.509.914 NV e 1.378.030 PTB): fecha.

## Contagens por etapa (totais nacionais; 26 concentrações somadas)

| Etapa | n |
|---|---|
| NV de residentes dos 277 municípios na janela | 14.176.621 |
| gestação múltipla | 328.770 |
| gestação ignorada (GRAVIDEZ) | 11.024 |
| NV únicos | 13.836.827 |
| IG ausente, < 22 ou ≥ 45 | 209.670 |
|   IG ausente | 192.122 |
|   IG < 22 | 6.326 |
|   IG ≥ 45 | 11.222 |
| IG de 43 a 44 | 70.145 |
| NV únicos de 22 a 42 semanas | 13.557.012 |
| início fora da coorte fixa | 47.098 |
| população analítica (NV) | 13.509.914 |
| população analítica (PTB) | 1.378.030 |

- **Critério de inclusão, recontado na janela para registro:** IG válida em pelo menos 93,11% dos NV de cada concentração; peso válido em pelo menos 99,98%; os dois juntos em pelo menos 93,10% (a menor, Fortaleza/CE). A conferência prespecificada é a da especificação (todas passam; a menor, Fortaleza, 93,08%).

## Tabela S6 (população analítica)

| Variable | Use | Denominator | Missing or unknown, n (%) |
|---|---|---|---|
| Gestational age (SEMAGESTAC) | Outcome; Table 1 | 13,509,914 | 0 |
| Mode of delivery (PARTO) | Table 1 | 13,509,914 | 5,259 (<0.1%) |
| Prenatal visits (CONSULTAS) | Table 1 | 13,509,914 | 96,540 (0.7%) |
| Daily mean temperature of the core city (concentration-days) | Exposure; Table 1 | 116,948 | 0 |
| Birth weight (PESO; missing or outside 200–7,000 g) | Inclusion criterion | 13,509,914 | 562 (<0.1%) |
| Labor induction (STTRABPART) | Spontaneous preterm birth | 13,509,914 | 523,529 (3.9%) |
| Cesarean before the onset of labor (STCESPARTO; cesarean deliveries) | Spontaneous preterm birth | 7,370,207 | 531,601 (7.2%) |
| Date of the last menstrual period (DTULTMENST; missing or invalid) | Internal consistency of gestational age | 13,509,914 | 8,070,020 (59.7%) |

- **Sigilo:** só totais nacionais; 1 a 9 como "<10"; a decomposição da IG fora de 22 a 44 só aparece se as três partes tiverem pelo menos 10 (supressão complementar); nada diário nem por concentração.

## Saídas (fora do git)

- `figuras/figS1_fluxograma_v2_20261020.pdf`: `82ff1444dd98893e40cebb88b6cf65d123ae2e4d02494a3940d02c121d408798`;
- `figuras/figS1_fluxograma_v2_20261020.png`: `896903f3a87f79e3f7381a80d5396ffdf1fecb5261d4571b020758ad01e74fed`;
- `tabelas/tabS6_ausentes_v2_20261020.csv`: `a308f40fbe7437ca4d32d3a654bb41afe1a457560e4cbe9f4c483d8164c1961c`;
- `tabelas/figS1_contagens_v2_20261020.csv`: `6945c2ff32030f7840c2fae8be2775919bcb06bb6fb2fdb2b11584ad18160c94`;

- **Saídas da v1 (mesmas contagens; percentual "(0.0%)" em contagem não nula), na lixeira:**
  - `figuras/figS1_fluxograma_v1_20261020.pdf`: `73334a7ff6e587457d6d7c34234bff8eac881f6039ebbff0fd915bc7a6206314`;
  - `figuras/figS1_fluxograma_v1_20261020.png`: `896903f3a87f79e3f7381a80d5396ffdf1fecb5261d4571b020758ad01e74fed`;
  - `tabelas/tabS6_ausentes_v1_20261020.csv`: `21b919bb478ad2fd6a8fa946f03903522e279e324d5f2ef88b2c791ae3ac0f5f`;
  - `tabelas/figS1_contagens_v1_20261020.csv`: `6945c2ff32030f7840c2fae8be2775919bcb06bb6fb2fdb2b11584ad18160c94`;

- **Resultado:** ok.

