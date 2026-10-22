# Base perinatal × clima: `ig_dum_sem` (versão `7e99bf94` → `4443971b`)

Data: 08/10/2026. Pasta: `/Volumes/Forja/Doc/dados_artigos_perinatais_clima`. Este arquivo tem só agregados. Toda contagem de 1 a 9 aparece como "<10", com supressão complementar ("supr.").

## 1. Resumo

- **A versão nova é a `4443971b`.** O `nascimentos.parquet` ganhou a coluna `ig_dum_sem` (int16, a última), calculada como ⌊(DTNASC − DTULTMENST)/7⌋ em dias de calendário. É NA quando a DUM está ausente, não é analisável, é posterior ao parto ou é anterior a parto − 350 dias; o corte é feito antes do ⌊·⌋. A data bruta da DUM não entra em nenhum arquivo. `versao()` dá `4443971b` em R e em Python, o mesmo valor previsto antes da troca.
- **Nada mais mudou de conteúdo.** Os 43 arquivos têm o mesmo nº de linhas. As 51 colunas antigas do `nascimentos` ficaram idênticas: 0 linha diferente e o mesmo hash por coluna. Os outros 42 arquivos têm o md5 da `7e99bf94`, inclusive os 28 que foram regravados: 8 do 06b; 19 do 06c, do 06d e do 07b; e o CSV da validação do 06d. O 99 só muda o "Gerado por" e o md5 do `nascimentos`.
- **A coluna é acessível nos três caminhos:** `nascimentos()`, em R e em Python; `pig(com_nascimentos = "ig_dum_sem")`, nas duas linguagens; e a junção 1:1 por `id_nasc`, testada. O `pig_classificacao.parquet` não mudou. A paridade R × Python bate em dado sintético e em dado real: frequência por ano × valor e um checksum que amarra o valor ao `id_nasc`.
- **Descritivo e Q2d.** Com código 8, a igualdade exata é de 79,13% (2012–2024), contra 79,1% em 07/10: compatível. **A premissa da cobertura não se confirma:** de 2013 a 2024, a cobertura da `ig_dum_sem` é igual à fração do código 8, e não maior, porque a DUM nos registros em branco é de 2011–2012. Por decisão sua, isso fica registrado como achado. Também apareceu um padrão exploratório: o `SEMAGESTAC` não é ⌊dias/7⌋ puro, e a igualdade exata cai nos anos bissextos. A concordância de ±1 semana fica em 99,9% ou mais em todos os anos.
- **Dupla auditoria.** A autoauditoria achou 4 defeitos meus e a auditoria independente achou 14. Todos foram reproduzidos com código próprio antes de aceitos. 17 foram corrigidos; o achado 4 da auditoria (premissa da cobertura) ficou como achado, por decisão sua. **Próximo passo: a Fase 0 do Artigo 1 tem de rodar de novo sobre a base `4443971b`.**

## 2. Versão: antes e depois

| | Versão | Conferida em |
|---|---|---|
| Antes | `7e99bf94` | `versao()` em R e em Python no início da sessão; recalculada a partir do disco (43/43 md5 = manifesto) |
| Depois | **`4443971b`** | `versao()` em R e em Python; recalculada a partir do disco; igual à prevista na fase `pre` |

**Como `versao()` é calculado.** Não usa commit nem data. É um identificador de conteúdo, gerado pelo `00_scripts/08_manifesto.py`:
1. a lista é dos 43 arquivos de dados do `09_acesso/manifesto.json` (25 do `06_processados/`, 4 CSVs do `04`, 2 CSVs do `07` e 12 logs agregados);
2. cada linha é "caminho:md5", com o md5 do arquivo inteiro;
3. as linhas são ordenadas pelo caminho e unidas com quebra de linha;
4. calcula-se o SHA-256 do texto;
5. a versão são os 8 primeiros caracteres hexadecimais.

A data do manifesto e o md5 dos scripts ficam gravados em campos à parte, fora da conta.

**A conta não é circular.** Nenhum dos 43 arquivos contém o identificador. Ele só aparece em arquivos de fora da lista: o próprio `manifesto.json`, o README, os FONTE, o DICIONARIO, este arquivo e o relatório do 97. A prova está nos dois sentidos: o `nao_regressao_ig_dum_sem.py` recalcula a versão só a partir do md5 dos arquivos no disco, sem ler o `manifesto.json`, e obtém `4443971b` (e `7e99bf94` a partir da lista do commit `9f1957b`).

**Preservação da `7e99bf94`**, pelo mecanismo que a base já usa, por sua decisão:
- o commit `9f1957b` guarda o código e o manifesto da versão;
- o `integridade.csv` e o `proveniencia.csv` só recebem acréscimo;
- os brutos ficaram intactos;
- a regeneração é determinística: o 06b deu o md5 `92190228…` em 4 execuções anteriores, e o 06b, o 06c, o 06d e o 07b, regerados hoje, deram os md5 da 7e99bf94.

O conteúdo da `7e99bf94` está inteiro na `4443971b`: são as mesmas 51 colunas, byte a byte, sem a `ig_dum_sem`.

## 3. Diff resumido e acesso

**Código**
| Arquivo | O que mudou |
|---|---|
| `00_scripts/06b_desfechos.py` | `DUM_MAX_DIAS = 350`. `data_dum()`: aceita só 8 dígitos ddmmaaaa de uma data que existe, sem `zfill`. `dias_dum()`. `ig_pela_dum()`: ⌊dias/7⌋ com 0 ≤ dias ≤ 350, Int16. `motivo_na_ig_dum()`: só para logs agregados, não vai para arquivo. `DTULTMENST` entra em `SIN_COLS` (leitura). `ig_dum_sem` entra em `derivar_nascimentos()`, no fim de `NASC_SAIDA` e no `select` de `nascimentos_ano()`. Docstring |
| `09_acesso/acesso.py` | `ler()` e `pig()` aceitam um nome só (`com_nascimentos = "ig_dum_sem"`), como o R já aceitava (auditoria, achado 2) |

**Não mudaram:** `acesso.R`, `07b`, `06c`, `06d`, `config.py`, `utils.py`, `08`, `99`.

**Testes novos** (`00_scripts/testes/`):
- `teste_ig_dum_sem_sintetico.py`;
- `mutantes_ig_dum_sem.py`;
- `paridade_ig_dum_sem.py` e `.R`;
- `nao_regressao_ig_dum_sem.py` (fases `pre`, `regen` e `pos`);
- `descritivo_ig_dum_sem.py`;
- `autoauditoria_ig_dum_sem.py`.

**Documentação:**
- `09_acesso/DICIONARIO.md`: coluna nova, com tipo, definição, NA e regra de uso; nota no PIG;
- `09_acesso/LEIAME.md`;
- `01_sinasc/FONTE.md` e `06_processados/FONTE.md`;
- `README.md`: estado e versão;
- `CLAUDE.md`: testes;
- `logs/LEIAME_logs.md`;
- `logs/desvios_especificacao.md`: duas entradas de 08/10, uma registrada antes de rodar e outra depois da auditoria.

A base não tem changelog próprio; o histórico fica no git, nos desvios e na tabela de estado do README.

**Dados:** só o `06_processados/nascimentos.parquet` mudou (md5 `92190228…` → `3a78e7dd…`).

**Onde a `ig_dum_sem` fica acessível**
| Caminho | R | Python |
|---|---|---|
| `nascimentos()` | `nascimentos(c("id_nasc", "ig_dum_sem"))` | `A.nascimentos(["id_nasc", "ig_dum_sem"])` |
| `pig()` | `pig(com_nascimentos = "ig_dum_sem")` | `A.pig(com_nascimentos="ig_dum_sem")` |
| Chave de junção | `id_nasc`: único no `nascimentos` (16.116.860) e no PIG (14.827.644), e todo `id_nasc` do PIG está no `nascimentos`. `pig(com_nascimentos)` mantém o nº de linhas e a ordem do PIG. Testado em R e em Python | idem |

## 4. Testes

| Teste | Resultado | Log |
|---|---|---|
| Sintético (`teste_ig_dum_sem_sintetico.py`): 280/286/287/6 dias; dia do parto; 1 e 7 dias depois; 349/350/351/356/357 dias; 29/02 (287 dias corridos → 41, contra 286 → 40 sem ano bissexto); vazia, nula, só espaços, letras, barras, 7 e 9 dígitos; 31/02, 29/02 de 2015, dia 00 e 32, mês 00 e 13; parto sem data; conta independente em `datetime`; caminho completo com múltiplo, gravidez ignorada, SEMAGESTAC 99, vazio ou diferente da DUM, ano 2011 e DTNASC nula; lista fixa das 52 colunas; interface Python com texto e com lista | **42/42** | `teste_ig_dum_sem_sintetico_20261008_201246.log` |
| **Defeitos plantados** (`mutantes_ig_dum_sem.py`): arredondar em vez de truncar; cortar depois do piso; aceitar DUM posterior; corte em 351; `zfill` em 7 dígitos; DUM bruta na saída; filtrar por único; condicionar ao SEMAGESTAC; DUM bruta com outro nome nas duas listas | **9/9 mortos**; o 06b sem mutação passa. "Arredondar" derruba 8 casos (286 → 40, 349 → 49, 6 → 0…) | `mutantes_ig_dum_sem_20261008_201247.log` |
| Paridade R × Python, base sintética | Python 6/6; R 7/7 (19 células, checksum) | `paridade_ig_dum_sem_{py,R}_*` |
| Paridade R × Python, dado real, raiz de conferência antes da troca | Python 6/6; R 7/7 (830 células, dif. 0; checksum igual) | idem, 20:05 |
| Paridade R × Python, base real depois da troca | Python 6/6; R 7/7 (830 células, dif. 0; checksum igual) | `paridade_ig_dum_sem_py_20261008_201224.log`, `…_R_20261008_201246.log` |
| A paridade consegue falhar | Com 1 célula adulterada em +1 na saída do Python, o R saiu com 1 | registrado nesta sessão |
| Teste antigo do 06b (`teste_06b_sintetico.py`) | 35/35 | — |
| `teste_dicionario.py` | 31/31 (antes da troca, 30/31, como esperado: sobrava a `ig_dum_sem`) | `logs/teste_dicionario_20261008.txt` |
| `teste_proveniencia.py` | 10/10 | — |
| `teste_acesso.py` e `teste_acesso.R` | 22/22 e 18/18 | — |
| Autoauditoria embutida no descritivo: arquivo × 06b sobre o bruto; arquivo × conta independente em pandas; NA ⇔ motivo; TPMETESTIM × `metodo_ig`; ids | 0 divergência nas 6 checagens; a partição de n fecha | `descritivo_ig_dum_sem_20261008_201251.log` |
| Recontagem independente (`autoauditoria_ig_dum_sem.py`) | **349/349** números e máscaras | `autoauditoria_ig_dum_sem_20261008_201303.log` |

## 5. Não regressão

| Fase | Quando | Resultado | Log |
|---|---|---|---|
| `pre` | antes da troca, rascunho do 06b × ativos | **16/16** | `nao_regressao_ig_dum_sem_pre_20261008_200229.log` |
| `regen` | antes da troca: 06d e 06c `--rascunho`; 07b `--rascunho` na raiz de conferência, **lendo o `nascimentos` novo** | **21/21**: as 19 saídas do 06c, do 06d e do 07b com o md5 da 7e99bf94; a validação do 06d deu 5/5 com diferença 0 | `nao_regressao_ig_dum_sem_regen_20261008_200451.log` |
| `pos` | depois da troca, do 99 e do 08 | **12/12** | `nao_regressao_ig_dum_sem_pos_20261008_201013.log` |

**Linhas e hash por arquivo** (manifestos `7e99bf94`, do commit `9f1957b`, e `4443971b`). Os 43 arquivos têm o mesmo nº de linhas, e só o `nascimentos` mudou de md5:

| Arquivo | Linhas (7e99bf94 = 4443971b) | md5 7e99bf94 | md5 4443971b | Igual |
|---|---:|---|---|:---:|
| `04_regioes_metropolitanas/cidade_nucleo.csv` | 26 = | `7da35560a5b6e5be0745561dbf2c7e58` | `7da35560a5b6e5be0745561dbf2c7e58` | sim |
| `04_regioes_metropolitanas/concentracoes_urbanas_municipios.csv` | 277 = | `c118857dbc825f182735f847e927a8d7` | `c118857dbc825f182735f847e927a8d7` | sim |
| `04_regioes_metropolitanas/municipios_novos_origem.csv` | 6 = | `1468fb4728dc2eeb274672f93564a676` | `1468fb4728dc2eeb274672f93564a676` | sim |
| `04_regioes_metropolitanas/populacao_censo2022.csv` | 5.570 = | `5c6c35238f22f7f821354a5611b8fb75` | `5c6c35238f22f7f821354a5611b8fb75` | sim |
| `06_processados/calendario_2010_2025.parquet` | 5.510 = | `5c719b2b2d97757ac0bbeac8e59c8dbf` | `5c719b2b2d97757ac0bbeac8e59c8dbf` | sim |
| `06_processados/clima_municipio_diario_2010_2025.parquet` | 1.526.270 = | `4c7cbe6c14652cb19b609f42134f8b32` | `4c7cbe6c14652cb19b609f42134f8b32` | sim |
| `06_processados/clima_pesos_municipio.parquet` | 2.448 = | `737f7d88e41ddc942a7809db42fc7c1d` | `737f7d88e41ddc942a7809db42fc7c1d` | sim |
| `06_processados/expo_semanal_pm25_mun.parquet` | 1.517.683 = | `c612949724373b9634fb6b30b53cc095` | `c612949724373b9634fb6b30b53cc095` | sim |
| `06_processados/expo_semanal_pm25_nucleo.parquet` | 142.454 = | `595ce3b19f96860e8ce01aaa49a1fc9c` | `595ce3b19f96860e8ce01aaa49a1fc9c` | sim |
| `06_processados/expo_semanal_pm25_rm_nv.parquet` | 142.454 = | `68a6676c175351d7bca54d08593a6561` | `68a6676c175351d7bca54d08593a6561` | sim |
| `06_processados/expo_semanal_rh_mun.parquet` | 1.517.683 = | `9ece1477e308a5536b2b47748e5700d5` | `9ece1477e308a5536b2b47748e5700d5` | sim |
| `06_processados/expo_semanal_rh_nucleo.parquet` | 142.454 = | `ca736aace4c2ecfd0f3e36cec9c2be03` | `ca736aace4c2ecfd0f3e36cec9c2be03` | sim |
| `06_processados/expo_semanal_rh_rm_nv.parquet` | 142.454 = | `c48908797ffbeb62a5463fb0ac4ffe65` | `c48908797ffbeb62a5463fb0ac4ffe65` | sim |
| `06_processados/expo_semanal_tmean_mun.parquet` | 1.517.683 = | `09284c63d55e6c36ec1aa23067c6e7a1` | `09284c63d55e6c36ec1aa23067c6e7a1` | sim |
| `06_processados/expo_semanal_tmean_nucleo.parquet` | 142.454 = | `8d202ead98c31964aec47109db3b5547` | `8d202ead98c31964aec47109db3b5547` | sim |
| `06_processados/expo_semanal_tmean_rm_nv.parquet` | 142.454 = | `bf4b8562641954f2020226ef443396e8` | `bf4b8562641954f2020226ef443396e8` | sim |
| `06_processados/gestacoes_em_risco.parquet` | 24.290.331 = | `14fd418d61376c0cbfa1dbb6c11a16ed` | `14fd418d61376c0cbfa1dbb6c11a16ed` | sim |
| `06_processados/gestacoes_em_risco_recorte.parquet` | 2.500.825 = | `9a371ebc788349c251da4c61a15198af` | `9a371ebc788349c251da4c61a15198af` | sim |
| `06_processados/nascimentos.parquet` | 16.116.860 = | `92190228a02b031a7e510fa1cf0f9bf3` | `3a78e7ddcfd1f3c4f86e910087347698` | **não** |
| `06_processados/obitos_perinatais.parquet` | 259.909 = | `3fc57216d26cbd236d6acc0bbd7bdd08` | `3fc57216d26cbd236d6acc0bbd7bdd08` | sim |
| `06_processados/pig_classificacao.parquet` | 14.827.644 = | `7aeecfc1a67fc675b22bc59bc83b3a36` | `7aeecfc1a67fc675b22bc59bc83b3a36` | sim |
| `06_processados/pm25_municipio_diario_2010_2025.parquet` | 1.526.270 = | `7d6ba7f4134e1163e2bda64e1aec174f` | `7d6ba7f4134e1163e2bda64e1aec174f` | sim |
| `06_processados/pm25_pesos_municipio.parquet` | 491 = | `2ef2dc5025c9769fbb2815d6a45da628` | `2ef2dc5025c9769fbb2815d6a45da628` | sim |
| `06_processados/serie_diaria_municipio.parquet` | 1.416.578 = | `1f0ded6fdb15b11c184191d0a6690025` | `1f0ded6fdb15b11c184191d0a6690025` | sim |
| `06_processados/serie_diaria_municipio_clima.parquet` | 1.424.334 = | `c4793a0ca548c7084bc5f5fdef510ea9` | `c4793a0ca548c7084bc5f5fdef510ea9` | sim |
| `06_processados/serie_diaria_municipio_clima_sem_coorte_fixa.parquet` | 1.424.334 = | `4ef14b17aab4a05653c2e779b0379c10` | `4ef14b17aab4a05653c2e779b0379c10` | sim |
| `06_processados/serie_diaria_municipio_sem_coorte_fixa.parquet` | 1.416.578 = | `74cfbb511ec7ebcdea21686e4a74ca90` | `74cfbb511ec7ebcdea21686e4a74ca90` | sim |
| `06_processados/serie_diaria_recorte.parquet` | 133.692 = | `f36cb6649c3b8c9936fe7705059088a8` | `f36cb6649c3b8c9936fe7705059088a8` | sim |
| `06_processados/serie_diaria_recorte_sem_coorte_fixa.parquet` | 133.692 = | `26b4e3ff71a57b578ad10cbbc239f7ef` | `26b4e3ff71a57b578ad10cbbc239f7ef` | sim |
| `07_pig_referencia/oms_kiserud2017_p10.csv` | 81 = | `44d8d12044826f984a9d821e221dffa6` | `44d8d12044826f984a9d821e221dffa6` | sim |
| `07_pig_referencia/pedreira2011_p10.csv` | 42 = | `2a82b376a80a63799f4c89bef8dc794a` | `2a82b376a80a63799f4c89bef8dc794a` | sim |
| `logs/aceite_fase1_uf_ano.csv` | 1.188 = | `7821feb1650bfa3d3f8332dc6f7a13a6` | `7821feb1650bfa3d3f8332dc6f7a13a6` | sim |
| `logs/codigos_residencia_fora_ibge.csv` | 0 = | `188ece400ae47d9aa726976b4ec1d166` | `188ece400ae47d9aa726976b4ec1d166` | sim |
| `logs/criterios_inclusao_recorte.csv` | 52 = | `f8e7002508902588eaa622e707042a3c` | `f8e7002508902588eaa622e707042a3c` | sim |
| `logs/dias_faltantes_clima.csv` | 1.108 = | `417b0441595c2e56f55233b694cacd51` | `417b0441595c2e56f55233b694cacd51` | sim |
| `logs/dias_faltantes_pm25.csv` | 312 = | `8e9aae33f591166ae09501e83bda151f` | `8e9aae33f591166ae09501e83bda151f` | sim |
| `logs/fluxograma_exclusoes.csv` | 42 = | `28440d0d6207901807436c3fee481406` | `28440d0d6207901807436c3fee481406` | sim |
| `logs/obitos_por_criterio.csv` | 28 = | `d98dba7cef34fc4090077e2e9b41bc59` | `d98dba7cef34fc4090077e2e9b41bc59` | sim |
| `logs/pig_concordancia.csv` | 70 = | `70be12267fc4e5ebe3893d6c7c5c4537` | `70be12267fc4e5ebe3893d6c7c5c4537` | sim |
| `logs/pig_resumo_ano.csv` | 27 = | `89cc29a324b486eaecfd584a6e504081` | `89cc29a324b486eaecfd584a6e504081` | sim |
| `logs/totais_anuais.csv` | 28 = | `f5f9c998c7e1a40b174021b9d941408d` | `f5f9c998c7e1a40b174021b9d941408d` | sim |
| `logs/validacao_06d_forca_bruta.csv` | 5 = | `f5abbd8a57958b5328591f9a32123392` | `f5abbd8a57958b5328591f9a32123392` | sim |
| `logs/validacao_e5_datas.csv` | 14 = | `a3f47695787c5f29b560faaf10c04c95` | `a3f47695787c5f29b560faaf10c04c95` | sim |

**Hash por coluna do `nascimentos.parquet`.** Rascunho, que depois virou o arquivo ativo com md5 idêntico, × `7e99bf94`. As 51 colunas antigas aparecem na mesma ordem, com o mesmo tipo, e uma só coluna a mais, `ig_dum_sem` (int16), no fim. O hash é o SHA-256 do hash por linha do polars, com 16 caracteres. "Linhas diferentes" usa `ne_missing`, que trata NA = NA como igual.

| Coluna | Linhas diferentes | NA (antes × depois) | Hash da coluna (antes × depois) |
|---|---:|---|---|
| `id_nasc` | 0 | 0 × 0 | `6e3f8db78fb90bca` × `6e3f8db78fb90bca` |
| `CD_MUN6` | 0 | 0 × 0 | `c5c5e5211163698a` × `c5c5e5211163698a` |
| `data` | 0 | 0 × 0 | `201d822472a7a466` × `201d822472a7a466` |
| `ano` | 0 | 0 × 0 | `1b06f380fa07eb12` × `1b06f380fa07eb12` |
| `ga_sem` | 0 | 826.133 × 826.133 | `876cda14c1c57abe` × `876cda14c1c57abe` |
| `semagestac_bruto` | 0 | 804.561 × 804.561 | `dd4cfbc650c8b457` × `dd4cfbc650c8b457` |
| `ig_cat` | 0 | 0 × 0 | `ba26bda101ae3ec7` × `ba26bda101ae3ec7` |
| `gestacao_cat` | 0 | 231.015 × 231.015 | `32490ab154b30a5c` × `32490ab154b30a5c` |
| `metodo_ig` | 0 | 2.246.799 × 2.246.799 | `17dda0a4cc699223` × `17dda0a4cc699223` |
| `dum_est` | 0 | 826.133 × 826.133 | `939539fa18ee8e73` × `939539fa18ee8e73` |
| `unico` | 0 | 0 × 0 | `0e52251347843a94` × `0e52251347843a94` |
| `gravidez` | 0 | 14.199 × 14.199 | `e9c7a8396a177c5c` × `e9c7a8396a177c5c` |
| `grav_cat` | 0 | 0 × 0 | `cedf53dfd5a409f1` × `cedf53dfd5a409f1` |
| `pop_ptb` | 0 | 0 × 0 | `d5a39cd0ed1ebb8d` × `d5a39cd0ed1ebb8d` |
| `ptb` | 0 | 0 × 0 | `5b96054c8bea661f` × `5b96054c8bea661f` |
| `ptb_extremo` | 0 | 0 × 0 | `50a25f18b1bf87f2` × `50a25f18b1bf87f2` |
| `ptb_muito` | 0 | 0 × 0 | `1920d032fcb49994` × `1920d032fcb49994` |
| `ptb_moderado_tardio` | 0 | 0 × 0 | `93e4839a3eee16b1` × `93e4839a3eee16b1` |
| `ig_43_44` | 0 | 0 × 0 | `715131917d29b5a5` × `715131917d29b5a5` |
| `coorte_fixa_22` | 0 | 0 × 0 | `63f6bc5bf47e1a77` × `63f6bc5bf47e1a77` |
| `coorte_fixa_37` | 0 | 0 × 0 | `9a0024612c144bf3` × `9a0024612c144bf3` |
| `periodo_principal` | 0 | 0 × 0 | `ae9f6f8ae726be7b` × `ae9f6f8ae726be7b` |
| `periodo_sens2011` | 0 | 0 × 0 | `730a48e92fd652e6` × `730a48e92fd652e6` |
| `nv_gestacao_sens2011` | 0 | 0 × 0 | `543d337ced690a64` × `543d337ced690a64` |
| `ptb_gestacao_sens2011` | 0 | 0 × 0 | `00e35c9ff68889c4` × `00e35c9ff68889c4` |
| `peso_g` | 0 | 1.246 × 1.246 | `5e91833b023071ce` × `5e91833b023071ce` |
| `sexo` | 0 | 0 × 0 | `545948dd2b2911e5` × `545948dd2b2911e5` |
| `idade_mae` | 0 | 346 × 346 | `ac3aba0c6b6db79d` × `ac3aba0c6b6db79d` |
| `escmae2010` | 0 | 1.344.863 × 1.344.863 | `bb46d87ec62491e6` × `bb46d87ec62491e6` |
| `escmae` | 0 | 84.543 × 84.543 | `1f9c94bfb1e7bf3f` × `1f9c94bfb1e7bf3f` |
| `raca_mae` | 0 | 1.153.026 × 1.153.026 | `2390f8b20df23e1d` × `2390f8b20df23e1d` |
| `estciv_mae` | 0 | 73.926 × 73.926 | `f6733ce1592a2896` × `f6733ce1592a2896` |
| `n_gest_ant` | 0 | 1.091.104 × 1.091.104 | `124fca4633d33dcb` × `124fca4633d33dcb` |
| `n_part_vag` | 0 | 1.349.762 × 1.349.762 | `ab12695949447007` × `ab12695949447007` |
| `n_part_ces` | 0 | 1.399.536 × 1.399.536 | `1875255a4ae35c9d` × `1875255a4ae35c9d` |
| `paridade` | 0 | 1.595.877 × 1.595.877 | `824f0f2c20536270` × `824f0f2c20536270` |
| `paridade_filvivo` | 0 | 626.679 × 626.679 | `8be06206de5e00cc` × `8be06206de5e00cc` |
| `n_fil_mort` | 0 | 954.063 × 954.063 | `66a89b3043dbe824` × `66a89b3043dbe824` |
| `flag_paridade_incoerente` | 0 | 0 × 0 | `30138e2bf953c75c` × `30138e2bf953c75c` |
| `n_consultas` | 0 | 920.364 × 920.364 | `1b7543b3c983871d` × `1b7543b3c983871d` |
| `consultas_cat` | 0 | 3.512 × 3.512 | `790ffd5650a08770` × `790ffd5650a08770` |
| `parto` | 0 | 11.244 × 11.244 | `e473d9e05a4bb2cc` × `e473d9e05a4bb2cc` |
| `sttrabpart` | 0 | 777.553 × 777.553 | `462c84165887328e` × `462c84165887328e` |
| `stcesparto` | 0 | 1.651.622 × 1.651.622 | `e1ab1f4981f54331` × `e1ab1f4981f54331` |
| `stcesparto_aj` | 0 | 536.919 × 536.919 | `a3c6c270d90da1a9` × `a3c6c270d90da1a9` |
| `apresentacao` | 0 | 673.480 × 673.480 | `6dccc099e2377da3` × `6dccc099e2377da3` |
| `robson` | 0 | 1.727.940 × 1.727.940 | `471215a87eac527a` × `471215a87eac527a` |
| `idanomal` | 0 | 149.478 × 149.478 | `19a690a8af0b48bd` × `19a690a8af0b48bd` |
| `codanomal` | 0 | 15.949.262 × 15.949.262 | `810e9e123b30d13a` × `810e9e123b30d13a` |
| `uf_arquivo` | 0 | 0 × 0 | `8574ddf60b0e7346` × `8574ddf60b0e7346` |
| `status_arquivo` | 0 | 0 × 0 | `3cc10bb3f1d8875d` × `3cc10bb3f1d8875d` |

**Arquivos que incluem colunas do `nascimentos`:** nenhum arquivo de dados as copia. O PIG liga pelo `id_nasc`, e o `pig_classificacao.parquet` saiu idêntico.

**99_relatorio_integridade.** O bloco automático do README novo foi comparado com o da `7e99bf94` (commit `9f1957b`), como multiconjunto de linhas. Só mudaram duas linhas:
- o "Gerado por …";
- a linha do `nascimentos.parquet`, que trocou o md5 `92190228…` por `3a78e7dd…`.

As 42 linhas DATASUS × ano, as checagens automáticas e as outras linhas de arquivo são idênticas. A ordem das linhas pode mudar, porque os scripts regravados registram de novo no `integridade.csv`. O 99 simulado antes da troca deu o mesmo resultado (`README novo × simulado`: só o "Gerado por").

## 6. Descritivo de qualidade da `ig_dum_sem` (item 6)

Fonte: `logs/descritivo_ig_dum_sem_20261008.csv`, `…_q2d_…` e `…_bissexto_…`. NV residentes nos 277 municípios das 26 concentrações. Nada é cruzado com clima nem com desfecho além da própria IG. "SEMAGESTAC" = `ga_sem` (IG válida da base, 22–44), conforme o desvio de 08/10, item 5. Comparáveis = `ig_dum_sem` de 20 a 45 **e** `ga_sem` não NA. "<10" = contagem de 1 a 9; "supr." = supressão complementar (a mínima). As contagens são tratadas como recuperáveis mesmo quando só sai o %, o que é conservador.

**Tabela 1a. NV únicos, por ano (%)**
| Ano | n | % não NA | % NA: ausente | % NA: não analisável | % NA: parto sem data | % NA: posterior ao parto | % NA: anterior a 50 sem. | % 20–45 | n comparáveis | % \|dif\| ≤ 1 | % iguais |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2011 | 1.196.192 | 36,34 | 63,65 | 0,00 | 0,00 | 0,01 | 0,00 | 36,32 | 432.822 | 99,92 | 78,96 |
| 2012 | 1.206.665 | 58,11 | 41,89 | 0,00 | 0,00 | 0,00 | 0,00 | 58,07 | 698.870 | 99,95 | 75,11 |
| 2013 | 1.207.598 | 52,57 | 47,43 | 0,00 | 0,00 | <10 | supr. | 52,54 | 632.989 | 99,96 | 80,77 |
| 2014 | 1.233.564 | 46,48 | 53,52 | 0,00 | 0,00 | 0,00 | 0,00 | 46,46 | 571.806 | 99,97 | 80,74 |
| 2015 | 1.251.125 | 40,62 | 59,38 | 0,00 | 0,00 | <10 | <10 | 40,60 | 506.852 | 99,96 | 80,54 |
| 2016 | 1.177.587 | 37,58 | 62,41 | 0,00 | 0,00 | <10 | <10 | 37,56 | 441.595 | 99,97 | 74,73 |
| 2017 | 1.193.247 | 37,26 | 62,74 | 0,00 | 0,00 | <10 | <10 | 37,25 | 443.559 | 99,97 | 80,54 |
| 2018 | 1.179.210 | 38,38 | 61,62 | 0,00 | 0,00 | <10 | <10 | 38,37 | 451.625 | 99,97 | 80,69 |
| 2019 | 1.131.575 | 36,97 | 63,03 | 0,00 | 0,00 | <10 | <10 | 36,95 | 417.446 | 99,97 | 80,45 |
| 2020 | 1.071.687 | 35,73 | 64,27 | 0,00 | 0,00 | <10 | <10 | 35,71 | 382.133 | 99,98 | 74,07 |
| 2021 | 1.027.961 | 35,02 | 64,98 | 0,00 | 0,00 | <10 | <10 | 35,01 | 359.180 | 99,97 | 80,14 |
| 2022 | 982.474 | 34,21 | 65,79 | 0,00 | 0,00 | supr. | <10 | 34,20 | 335.373 | 99,98 | 80,28 |
| 2023 | 965.027 | 33,55 | 66,45 | 0,00 | 0,00 | supr. | <10 | 33,54 | 323.066 | 99,98 | 80,08 |
| 2024 | 905.977 | 32,64 | supr. | 0,00 | 0,00 | <10 | 0,00 | 32,63 | 295.125 | 99,99 | 73,50 |

Em 2011–2024 somados, há **0** registros "não analisável" e **0** "parto sem data" (contagem exata no log). "Posterior ao parto" e "anterior a 50 semanas" ficam em no máximo 0,01% ao ano. As DUMs que existem no calendário mas têm ano absurdo (fora de 1900–2025) são <10 no período; caem em "anterior" ou "posterior", e não em "não analisável", e o valor é NA do mesmo jeito.

**Tabela 1b. NV únicos na `coorte_fixa_22` (2012–2024), por ano (%)**
| Ano | n | % não NA | % NA: ausente | % NA: não analisável | % NA: parto sem data | % NA: posterior | % NA: anterior | % 20–45 | n comparáveis | % \|dif\| ≤ 1 | % iguais |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2012 | 774.675 | 59,94 | 40,05 | 0,00 | 0,00 | 0,00 | 0,00 | 59,94 | 464.348 | 99,96 | 76,92 |
| 2013 | 1.170.988 | supr. | 45,94 | 0,00 | 0,00 | <10 | <10 | 54,06 | 632.989 | 99,96 | 80,77 |
| 2014 | 1.210.681 | supr. | 52,77 | 0,00 | 0,00 | 0,00 | supr. | 47,23 | 571.806 | 99,97 | 80,74 |
| 2015 | 1.227.756 | 41,28 | 58,72 | 0,00 | 0,00 | <10 | <10 | 41,28 | 506.852 | 99,96 | 80,54 |
| 2016 | 1.161.322 | supr. | 61,97 | 0,00 | 0,00 | <10 | <10 | 38,03 | 441.595 | 99,97 | 74,73 |
| 2017 | 1.179.221 | supr. | 62,38 | 0,00 | 0,00 | <10 | <10 | 37,61 | 443.559 | 99,97 | 80,54 |
| 2018 | 1.167.816 | supr. | 61,33 | 0,00 | 0,00 | <10 | <10 | 38,67 | 451.625 | 99,97 | 80,69 |
| 2019 | 1.119.913 | supr. | 62,72 | 0,00 | 0,00 | <10 | 0,00 | 37,27 | 417.446 | 99,97 | 80,45 |
| 2020 | 1.059.784 | supr. | 63,94 | 0,00 | 0,00 | <10 | <10 | 36,06 | 382.133 | 99,98 | 74,07 |
| 2021 | 1.017.165 | supr. | 64,69 | 0,00 | 0,00 | <10 | 0,00 | 35,31 | 359.180 | 99,97 | 80,14 |
| 2022 | 976.371 | supr. | 65,65 | 0,00 | 0,00 | 0,00 | <10 | 34,35 | 335.373 | 99,98 | 80,28 |
| 2023 | 959.512 | supr. | 66,33 | 0,00 | 0,00 | 0,00 | <10 | 33,67 | 323.066 | 99,98 | 80,08 |
| 2024 | 836.669 | supr. | 67,07 | 0,00 | 0,00 | <10 | 0,00 | 32,93 | 275.526 | 99,99 | 74,25 |

Na coorte, o "% não NA" sai "supr." quando há de 1 a 9 registros com `ig_dum_sem` fora de 20–45: é a escolha de supressão mínima. Nesses anos, o % não NA difere do % de 20–45 publicado em menos de 10 registros. De 2013 a 2023, os comparáveis da coorte são os mesmos dos NV únicos, porque todo NV com `ga_sem` válido desses anos tem s na janela da coorte.

**Tabela 2a. Só TPMETESTIM = 8, lido do bruto: % de iguais entre os comparáveis**
| Ano | Todos os NV (população do Q2d): n cód. 8 | comparáveis | % iguais | NV únicos: n cód. 8 | comparáveis | % iguais |
|---|---:|---:|---:|---:|---:|---:|
| 2012 | 0 | 0 | — | 0 | 0 | — |
| 2013 | 650.302 | 648.383 | 80,74 | 634.852 | 632.989 | 80,77 |
| 2014 | 587.482 | 585.824 | 80,69 | 573.421 | 571.806 | 80,74 |
| 2015 | 520.585 | 519.193 | 80,50 | 508.200 | 506.852 | 80,54 |
| 2016 | 453.391 | 452.334 | 74,79 | 442.600 | 441.595 | 74,73 |
| 2017 | 455.497 | 454.405 | 80,51 | 444.605 | 443.559 | 80,54 |
| 2018 | 464.088 | 463.066 | 80,69 | 452.632 | 451.625 | 80,69 |
| 2019 | 428.715 | 427.792 | 80,40 | 418.329 | 417.446 | 80,45 |
| 2020 | 392.108 | 391.328 | 74,12 | 382.883 | 382.133 | 74,07 |
| 2021 | 368.804 | 367.941 | 80,10 | 360.009 | 359.180 | 80,14 |
| 2022 | 344.932 | 344.156 | 80,23 | 336.119 | 335.373 | 80,28 |
| 2023 | 332.113 | 331.351 | 80,05 | 323.794 | 323.066 | 80,08 |
| 2024 | 303.529 | 302.922 | 73,56 | 295.713 | 295.125 | 73,50 |
| **2012–2024** | 5.301.546 | 5.288.695 | **79,13** | 5.173.157 | 5.160.749 | 79,15 |

**Comparação com o Q2d de 07/10.**
- **Igualdade no código 8:** 79,13% agora × 79,1% no Q2d, uma diferença de 0,03 ponto. **Compatível** (≤ 1 ponto). O n do código 8 (5.301.546) e o n comparável (5.288.695) são os mesmos do Q2d.
- **Fração do código 8 em todos os NV:** 52,58% em 2013 e 32,67% em 2024, iguais ao Q2.
- **TPMETESTIM:** o pedido dizia que ele não entra na base, mas **entra**, como `metodo_ig`. O descritivo leu do bruto, como pedido, e conferiu: 0 divergência com o `metodo_ig`.

**Tabela 2b. Cobertura, todos os NV (%)**
| Ano | % código 8 | % `ig_dum_sem` não NA | Cobertura > código 8? | % não NA no código 8 | % não NA fora do código 8 | % não NA nos em branco |
|---|---:|---:|:---:|---:|---:|---:|
| 2011 | 0,00 | 36,34 | sim | — | 36,34 | 41,85 |
| 2012 | 0,00 | 58,12 | sim | — | 58,12 | 84,55 |
| 2013 | 52,58 | 52,58 | não | 100,00 | 0,00 | 0,00 |
| 2014 | 46,50 | 46,49 | não | 99,99 | 0,00 | 0,00 |
| 2015 | 40,63 | 40,62 | não | 100,00 | <10 | <10 |
| 2016 | 37,61 | 37,61 | não | compl.<10 | 0,00 | 0,00 |
| 2017 | 37,27 | 37,27 | não | 100,00 | 0,00 | 0,00 |
| 2018 | 38,39 | 38,39 | sim | compl.<10 | <10 | <10 |
| 2019 | 36,97 | 36,97 | não | compl.<10 | <10 | <10 |
| 2020 | 35,71 | 35,71 | não | 100,00 | 0,00 | 0,00 |
| 2021 | 35,01 | 35,01 | não | compl.<10 | <10 | <10 |
| 2022 | 34,23 | 34,23 | não | 100,00 | 0,00 | 0,00 |
| 2023 | 33,56 | 33,56 | não | 100,00 | <10 | <10 |
| 2024 | 32,67 | 32,67 | não | compl.<10 | <10 | <10 |

"compl.<10" = de 1 a 9 registros do código 8 **sem** `ig_dum_sem` (o % fica perto de 100).

**A expectativa do pedido não se confirma.** O pedido dizia que "a cobertura geral deve passar a fração do código 8, porque há DUM também nos brancos". Isso só vale em 2011 e 2012, quando ainda não existia código 8 e a DUM estava em 41,85% e 84,55% dos brancos, e em 2018, por menos de 10 registros. De 2013 a 2024, a DUM está praticamente só no código 8. O "DUM nos brancos" do Q2d (60,72% dos brancos) vem de 2012, porque o Q2d somou 2012–2024. Por decisão sua, isso fica registrado como achado (desvio pós-rodada de 08/10, item 1). A base não muda por isso.

**Tabela 3 (exploratória, só IG). `SEMAGESTAC − ig_dum_sem` nos NV únicos comparáveis, 2011–2024, por resto de (DTNASC − DUM) ÷ 7 e por o intervalo conter um 29/02 (%)**
| 29/02 no intervalo | Resto dos dias ÷ 7 | n comparáveis | −1 | 0 | +1 | outro |
|---|---:|---:|---:|---:|---:|---:|
| não | 0 | 783.434 | 38,53 | 61,42 | 0,01 | 0,03 |
| não | 1 | 728.611 | 19,96 | 79,99 | 0,01 | 0,03 |
| não | 2 | 697.681 | 9,35 | 90,60 | 0,02 | 0,03 |
| não | 3 | 682.707 | 0,02 | 99,92 | 0,02 | 0,03 |
| não | 4 | 674.574 | 0,00 | 74,80 | 25,15 | 0,04 |
| não | 5 | 675.211 | 0,01 | 74,52 | 25,44 | 0,04 |
| não | 6 | 688.122 | 0,00 | 71,59 | 28,36 | 0,04 |
| sim | 0 | 213.051 | 75,36 | 24,61 | 0,01 | 0,03 |
| sim | 1 | 206.332 | 26,61 | 73,36 | 0,01 | 0,03 |
| sim | 2 | 193.115 | 0,25 | 99,70 | 0,02 | 0,03 |
| sim | 3 | 188.095 | 0,01 | 99,96 | 0,01 | 0,02 |
| sim | 4 | 186.290 | 0,01 | 99,95 | 0,02 | 0,03 |
| sim | 5 | 186.278 | 0,01 | 80,65 | 19,31 | 0,03 |
| sim | 6 | 188.940 | 0,01 | 80,27 | 19,68 | 0,04 |

**Leitura, que é inferência do dado e não do dicionário:**
- O `SEMAGESTAC` do sistema **não** é ⌊dias/7⌋ puro em dias de calendário. A igualdade exata depende do resto dos dias ÷ 7: é de 99,9% com resto 3 e de 61% com resto 0. Quando o intervalo contém um 29/02, o padrão se desloca. Por isso a igualdade exata cai em cerca de 6 pontos nos anos bissextos (2012, 2016, 2020 e 2024).
- O mecanismo não está determinado: pode ser arredondamento numa parte dos registros, conta de 365 dias, ou outro.
- A diferença fica quase toda em ±1 semana, então a regra de uso da §3.5 (\|dif\| ≤ 1) absorve isso.
- O `ig_dum_sem` segue a definição pedida, com dias corridos, e os testes do 29/02 provam isso.

## 7. Dupla auditoria: achado → reprodução → correção

**Autoauditoria** (feita por mim, antes da auditoria independente)
| # | Achado | Reprodução | Correção |
|---|---|---|---|
| A1 | Supressão em cascata: escolhia sempre a menor parte e apagava o % de 20–45 e a concordância da coorte | Saída da 1ª rodada do descritivo | Complemento que deixa o mínimo de células escondidas |
| A2 | Contagens da tabela 2a gravadas como `650302.0` (o `concat` virou float) | `autoauditoria_ig_dum_sem.py`: 56 falhas de formato | Contagens gravadas como texto inteiro → 292/292 |
| A3 | "% iguais" virou formatação `%i` no `logging` | Erro de log na 1ª rodada | Escape `%%` |
| A4 | A checagem nova do "supr." acusava um caso justificado por célula não publicada | 2014, coorte: fora de 20–45 com 1 a 9 registros | A checagem passa a considerar as células derivadas → 349/349 |

**Auditoria independente** (subagente em contexto limpo, sem acesso a microdado, que recebeu o bloco `<especificacao>` inteiro)
| # | Grav. | Achado | Reprodução (código próprio) | Correção |
|---|---|---|---|---|
| 1 | Alta | Os documentos descreviam o estado depois da troca antes de ela ocorrer | `teste_dicionario` 30/31; README com "vigente `4443971b`" | Marcados como "pendente" até a troca; depois dela, finalizados |
| 2 | Média | `pig(com_nascimentos="ig_dum_sem")` com texto dava erro em Python | Base sintética: `ColumnNotFoundError`; o R funciona | `acesso.py` aceita um nome só; casos no sintético e na paridade (R e Python) |
| 3 | Média | A fase `pre` não provava que regerar o 06c, o 06d e o 07b sai idêntico; a `pos` pulava conferência em silêncio | Código (linhas 134, 204 e 219) | Fase `regen`, 21/21; a `pos` falha sem o `previsto.json` ou o 99 simulado |
| 4 | Média | Critério de cobertura × código 8 não atendido | CSV: não passa em 11 de 12 anos de 2013–2024 | Desvio pós-rodada; levado a você e aceito como achado |
| 5 | Média | Testes sem log; docstring citava um `.R` inexistente | 0 logs; arquivo ausente | Todos gravam em `logs/` com o md5 do 06b; docstring corrigida |
| 6 | Baixa | Supressão só dentro da linha; o total 2012–2024 permitia recuperar um ano | Sintético: ano A = 1.520 − 1.020 | O total herda as máscaras dos anos; conferido no sintético |
| 7 | Baixa | % não NA da coorte "supr." em muitos anos | 11 de 13 anos (o auditor contou 10) | Mantido (supressão mínima) e documentado |
| 8 | Baixa | "<10" ambíguo nas tabelas 2b e 3 | 2016: 99,998% aparecia como "<10" | Marcador "compl.<10" |
| 9 | Baixa | Lacunas no sintético; mutantes de "outro filtro" sobreviveriam | 2 mutantes vivos | Casos novos, lista fixa das 52 colunas, 3 mutantes novos → 9/9 |
| 10 | Baixa | Regra de uso escrita com `ga_sem`, e não com `SEMAGESTAC` | `DICIONARIO.md` | Regra como na §3.5, com nota sobre `semagestac_bruto` e `ga_sem` |
| 11 | Baixa | A autoauditoria prometia mais do que fazia | `pass` no "supr." | Confere as 5 colunas da 2b e o "supr."; o texto diz o que não confere |
| 12 | Baixa | Referências desatualizadas | "Lida só pelo 06b"; LEIAME sem a paridade | Corrigidas |
| 13 | Baixa | O "0" dos motivos não era verificável; ano absurdo cai em "anterior/posterior" | Sintético: 0000 → "anterior"; no dado, 0 e 0 exatos | Contagem exata no log; comportamento documentado |
| 14 | Baixa | Agregado sem máscara e duas cópias do microdado em `_tmp/` | 5 pastas | Marcado como restrito; cópias no `trash` depois da troca |

**Um deslize meu na conversa.** Ao reproduzir o achado 13, escrevi no chat a contagem exata de DUMs com ano absurdo, que é menor que 10, em vez de "<10". É um agregado de 2011–2024 nas 26 concentrações, sem nenhum outro atributo, mas fere a regra. Nos arquivos e neste retorno, ela aparece só como "<10".

## 8. Comandos para reproduzir

Ambiente, de `00_scripts/`:

```bash
cd /Volumes/Forja/Doc/dados_artigos_perinatais_clima/00_scripts
```

```bash
export UV_PROJECT_ENVIRONMENT=$HOME/.venvs/dados_perinatais_clima
```

Testes sem dado real:

```bash
PYTHONPATH=. uv run python testes/teste_ig_dum_sem_sintetico.py
```

```bash
PYTHONPATH=. uv run python testes/mutantes_ig_dum_sem.py
```

```bash
PYTHONPATH=. uv run python testes/teste_06b_sintetico.py
```

**Conferência antes de uma troca.** Só faz sentido com a versão anterior ativa. Para refazer a partir da 7e99bf94, restaure-a com o 06b do commit `9f1957b` e rode de novo o 06b (com os brutos e o ambiente do `uv.lock`, ela sai idêntica).

```bash
uv run 06b_desfechos.py --rascunho
```

```bash
PYTHONPATH=. uv run python testes/nao_regressao_ig_dum_sem.py pre
```

```bash
uv run 06d_gestacoes_em_risco.py --rascunho
```

```bash
uv run 06d_validar_forca_bruta.py --rascunho
```

```bash
uv run 06c_exposicao.py --rascunho
```

```bash
cd ../_tmp/raiz_ig_dum_sem
```

```bash
Rscript ../../07_pig_referencia/07b_pig_classificacao.R --rascunho
```

```bash
cd ../../00_scripts
```

```bash
PYTHONPATH=. uv run python testes/nao_regressao_ig_dum_sem.py regen
```

```bash
DADOS_PERINATAIS_CLIMA_RAIZ=../_tmp/raiz_ig_dum_sem PYTHONPATH=. uv run python testes/paridade_ig_dum_sem.py
```

```bash
ORIGEM=../_tmp/rascunho_06b PYTHONPATH=. uv run python testes/descritivo_ig_dum_sem.py
```

```bash
ORIGEM=../_tmp/rascunho_06b DATA=20261008 PYTHONPATH=. uv run python testes/autoauditoria_ig_dum_sem.py
```

Troca e conferência depois dela (de `00_scripts/`; o 07b roda da raiz):

```bash
uv run 06b_desfechos.py
```

```bash
uv run 06d_gestacoes_em_risco.py
```

```bash
uv run 06d_validar_forca_bruta.py
```

```bash
uv run 06c_exposicao.py
```

```bash
cd ..
```

```bash
Rscript 07_pig_referencia/07b_pig_classificacao.R
```

```bash
cd 00_scripts
```

```bash
uv run 99_relatorio_integridade.py
```

```bash
uv run 08_manifesto.py
```

```bash
PYTHONPATH=. uv run python testes/nao_regressao_ig_dum_sem.py pos
```

```bash
PYTHONPATH=. uv run python testes/teste_dicionario.py
```

```bash
PYTHONPATH=. uv run python testes/teste_acesso.py
```

```bash
PYTHONPATH=. uv run python testes/paridade_ig_dum_sem.py
```

```bash
PYTHONPATH=. uv run python testes/descritivo_ig_dum_sem.py
```

```bash
DATA=20261008 PYTHONPATH=. uv run python testes/autoauditoria_ig_dum_sem.py
```

```bash
uv run 97_relatorio_entrega.py
```

```bash
cd ..
```

```bash
Rscript 00_scripts/testes/teste_acesso.R
```

```bash
Rscript 00_scripts/testes/paridade_ig_dum_sem.R
```

O R da paridade lê o CSV que o `paridade_ig_dum_sem.py` gravou com a mesma raiz. Para a raiz de conferência, use a mesma `DADOS_PERINATAIS_CLIMA_RAIZ` nos dois.

## 9. SHA-256 deste arquivo

Não cabe aqui: vai na mensagem final da sessão.

---

**Próximo passo:** a **Fase 0 do Artigo 1** (prematuridade) precisa rodar de novo sobre a base nova. Ela deve registrar `versao()` = `4443971b` no log de análise. As análises que citaram a `7e99bf94` continuam reproduzíveis: o conteúdo daquela versão está inteiro na nova (as mesmas 51 colunas, byte a byte) e pode ser regenerado pelo commit `9f1957b`.
