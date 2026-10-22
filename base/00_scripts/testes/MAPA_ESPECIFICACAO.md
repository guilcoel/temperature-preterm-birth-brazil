# Mapa: itens (a)–(q) da especificação × testes

Os itens vêm do `PROMPT_CLAUDE_CODE.md`, fase 2, passo 3 ("teste com dados sintéticos cobrindo..."). Cada caso é citado pelo nome que o teste imprime. Todos os testes listados são sintéticos (não leem microdado) e saem com código 1 se algo falhar.

**Estado em 2026-10-07:** todos passam. `teste_06a` 10/10, `teste_06b` 35/35, `teste_06c` 28/28, `teste_06d` 8/8, `teste_07` 31/31.

| Item | O que a especificação pede | Situação | Onde |
|---|---|---|---|
| (a) | Gemelar excluído do principal e contado à parte | Coberto | `teste_06b`: "(a) NV 1: múltiplo fora da população"; "(a) série: 15/06/2015 … múltiplos=1" |
| (b) | Óbito fetal com SEMAGESTAC 99, GESTACAO vazia e peso 600, só em `obito_fetal_sem_ig` | Coberto | `teste_06b`: "(b) fetal 4: SEMAGESTAC 99, GESTACAO vazia, peso 600 -> 3_peso, só sem IG"; "(b) série: fetal 4 em 21/06 só no sem coorte…". O caso literal entrou em 07/10; antes havia só as partes (fetal 1 com 99, fetal 2 com peso 600). |
| (c) | Óbito neonatal no dia do nascimento (principal) e no do óbito (`_idx_obito`) | Coberto | `teste_06b`: "(c) série: neonatal pelo nascimento (10/06) e pelo óbito (13/06)" |
| (d) | Gestação fora da coorte fixa | Coberto | `teste_06b`: "(d) NV bordas da coorte fixa"; "(d) série: borda da coorte (28/12/2024…)" |
| (e) | Z_tj conferido à mão | Coberto | `teste_06d`: 7 casos à mão (soma, dias s+154 a s+165, município B) e força bruta semana a semana em 3.000 gestações sintéticas. Nos dados reais: `06d_validar_forca_bruta.py` (5 combinações). |
| (f) | Grade de clima estendida, com contagens NA fora do estudo | Coberto | `teste_06c`: "(f) município: grade 2010-12-11 a 2025-01-07…"; "(f) recorte: …" |
| (g) | Óbito neonatal sem SEMAGESTAC, fora do principal, em `obito_neonatal_precoce_sem_ig` só no arquivo sem coorte fixa | Coberto | `teste_06b`: "(g) neonatal 9: sem IG"; "(g) série: neonatal sem IG (10/06) = 1 … só no sem coorte; NA no principal". A asserção da série entrou em 07/10. |
| (h) | Município em RM e RIDE, atribuído só à RM | Não se aplica | A unidade passou a ser as 26 grandes concentrações do IBGE (desvio de 02/10, E13/E15), sem RM nem RIDE. A pertença única é conferida no `04` (`montar_concentracoes` para se um `CD_MUN` se repetir) e no `06b` (para se não houver 277 `CD_MUN6` únicos). |
| (i) | Periferia recebe o `tmean_nucleo` e mantém o próprio `tmean_mun` | Coberto | `teste_06c`: "(i) periferia: *_nucleo = série do núcleo (B) e *_mun = a própria, nas 6 variáveis" |
| (j) | Município instalado depois de 2011, agregado à origem | Não exercitado | E17: há 6 municípios novos na malha (`04_regioes_metropolitanas/municipios_novos_origem.csv`) e nenhum encosta numa concentração, então 0 foram reatribuídos. O código não reatribui: o `06b` para se algum encostar. Se uma malha futura trouxer um caso, a agregação à origem precisa ser escrita e testada. |
| (k) | Nascimento a termo de 41 semanas com `pig_oms` = NA e `pig_ig21`/`pig_pedreira` preenchidos | Coberto | `teste_07`: "(k) 41 semanas a termo: pig_oms (e sem sexo, e meio da semana) NA; pig_ig21 e pig_pedreira preenchidos; na população" |
| (l) | Município só de aglomeração urbana, excluído e contado | Não se aplica | As aglomerações urbanas legais saíram com a troca de unidade (desvio de 02/10). Fora dos 277 municípios não há recorte. |
| (m) | Série do recorte = soma das séries dos municípios, nas contagens e nas gestações em risco | Coberto | `teste_06c`: "(m) contagens do R2 = A + B e do R1 = C, célula a célula…"; "(m) gestações em risco do R2 = A + B por dia e semana" |
| (n) | Município em duas RMs faz o código parar e perguntar | Não se aplica na forma escrita | Sem RMs, o equivalente é um município em duas concentrações. O `04` para nesse caso (mesma conferência do item h). Não há caso sintético: o `04` lê a tabela do IBGE direto, e testá-lo exigiria refatorar o script, o que mudaria a proveniência. |
| (o) | `pm25_nucleo` = NA em dias sem dado, sem virar zero | Coberto | `teste_06c`: "(o) pm25_nucleo = NA no dia sem dado do núcleo…"; "(o) zero entra no _rm_nv…". `teste_06a`: zeros e NA por célula na agregação do CAMS. |
| (p) | NV dentro de `coorte_fixa_22` e fora de `coorte_fixa_37` | **Impossível como escrito**; o caso inverso está coberto | A janela da 22 ([2011-07-31; 2024-03-05]) está contida na da 37 ([2011-04-17; 2024-03-05]). O caso que existe é o inverso, e é o que importa para o PIG: NV a termo que entra na população do PIG e fica fora da série de prematuridade. `teste_06b`: "(p) NV de 37 semanas em 15/01/2012: s = 2011-04-28, dentro da coorte_fixa_37 e fora da coorte_fixa_22"; "(p) série: 15/01/2012 nv_unicos = 0 no principal e 1 no sem coorte". |
| (q) | Óbito com SEMAGESTAC válido, mas fora de 22–42, só no fluxograma | Coberto | `teste_06b`: "(q) fetal 3: IG 45 nem principal nem sem IG" (no SIM, a IG válida vai de 1 a 47); "(q) fluxograma: fetal de IG 45 … em unico_ig_fora_22_42 …". A conferência do fluxograma entrou em 07/10: roda o `logs_agregados` com a supressão desligada e para antes da parte que lê arquivo real. |

## Os casos novos conseguem falhar

Em 2026-10-07, o `teste_06b` rodou contra uma cópia do `06b` com três defeitos plantados:

1. janela da `coorte_fixa_37` igual à da 22;
2. `unico_ig_fora_22_42` com a condição trocada;
3. `obito_neonatal_precoce_sem_ig` deixado preenchido no arquivo principal.

Resultado: 32/35. Falharam exatamente os casos (p), (q) e (g), e nenhum outro. A cópia foi para a lixeira.
