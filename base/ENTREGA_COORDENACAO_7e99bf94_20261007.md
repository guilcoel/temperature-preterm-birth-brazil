# Entrega da base perinatal × clima — versão `7e99bf94`

- **De:** Claude Code, na pasta `/Volumes/Forja/Doc/dados_artigos_perinatais_clima` (SSD Forja)
- **Para:** chat coordenador do projeto de condução e conhecimento do projeto (PK)
- **Data:** 07/10/2026
- **Base:** versão `7e99bf94`, manifesto de 06/10/2026
- **Relatório com as tabelas completas:** https://claude.ai/artifact/6Q22dPqyGw4zpidfiU58Ls (privado; só agregados)

Esta é a resposta ao bloco `<entrega_final>` do `PROMPT_CLAUDE_CODE.md` (v5). Tudo aqui é agregado: concentração × período, ou o conjunto das 26 concentrações × ano. Nenhuma linha de microdado.

---

## Parte 1 — Mensagem à coordenação

### Resumo

- **A base está pronta para os artigos.** Ela está construída, passou por dupla auditoria em cada etapa e tem versão fixa, `7e99bf94`. Os três artigos leem a mesma base pela interface `09_acesso/`.
- **Os downloads estão completos e são todos definitivos.** As contagens batem com o CliMaterna e com o TabNet em todas as 1.188 células UF × ano. Houve uma violação do critério de aceite: município de residência ignorado acima de 1% no SIM, sobretudo no óbito fetal do RJ. Ela foi aceita com ressalva e entra como limitação.
- **Totais de 2012–2024 nas 26 concentrações:**
  - 13.791.848 NV únicos de 22–42 semanas na coorte fixa;
  - 1.405.697 prematuros (10,19%);
  - 180.064 óbitos perinatais (12,9 por mil);
  - 12.669.440 NV a termo na população do PIG.
- **Corte de eventos:** as 26 concentrações passam no corte de 1.000 eventos nos dois desfechos. No corte de 2.000, três ficam fora no óbito perinatal.
- **Nenhuma decisão de construção ficou pendente.** As escolhas de método foram gravadas como colunas, e cada artigo decide as suas.

### O que peço à coordenação

1. **Corrigir o item (p) da lista de testes, se ela também estiver no texto canônico da especificação.**
   - O item pede "um nascido vivo dentro de `coorte_fixa_22` e fora de `coorte_fixa_37`", o que é impossível. A janela da 22 ([2011-07-31; 2024-03-05]) está inteira dentro da janela da 37 ([2011-04-17; 2024-03-05]).
   - O caso que existe é o inverso: um NV a termo que entra no PIG e fica fora da série de prematuridade. O teste cobre esse caso.
   - O erro está no `PROMPT_CLAUDE_CODE.md` e já foi registrado nos desvios. Os dados não mudam.
2. **Abrir o artigo 1 (prematuridade)** numa conversa própria, com o Claude Code aberto numa pasta própria (proposta: `/Volumes/Forja/Doc/artigo_ptb_clima/`). Posso preparar a pasta, um `CLAUDE.md` com as regras de sigilo e o caminho da base, e o prompt de abertura.
3. **Levar à conversa do artigo 1 as decisões de método** que a base deixou em aberto (seção 9).

A ordem dos artigos está decidida: prematuridade, depois óbito perinatal, depois PIG.

---

## Parte 2 — Conhecimento do projeto

### 1. Identificação

| Item | Valor |
|---|---|
| Base | `dados_artigos_perinatais_clima`: repositório de dados comum aos três artigos DLNM perinatal × clima (prematuridade, óbito perinatal, PIG). Alvo: AJOG MFM (inglês americano) |
| Caminho | `/Volumes/Forja/Doc/dados_artigos_perinatais_clima` (SSD externo Forja, exFAT, não APFS) |
| Versão | `7e99bf94` = 8 primeiros hex do SHA-256 da lista ordenada caminho:md5 dos arquivos de dados. Só muda se um arquivo de dados mudar |
| Manifesto | `09_acesso/manifesto.json` (06/10/2026): md5, linhas, colunas, tipos, script de origem, sigilo e proveniência de cada arquivo |
| Ambiente | Python 3.12.7 via `uv` (polars 1.44.2, pandas 3.0.6, pyarrow 25.0.1); R 4.5.1; semente 20261001 |
| Código | Git local na raiz da pasta, sem remoto. Lista branca: só código, testes, `FONTE.md`, `09_acesso/` e documentação; dados, PDFs e logs ficam fora |
| Especificação | Especificação canônica de DLNM v1.0 (01/10/2026), com os adendos v1.1 a v1.3. Os requisitos para a base estão no `PROMPT_CLAUDE_CODE.md` (v5); os desvios, em `logs/desvios_especificacao.md` |

### 2. Escopo

- **Desfechos:** 2011–2024. A análise principal é 2012–2024; 2011 entra só como sensibilidade (E18), porque o `SEMAGESTAC` estava preenchido em 54% do SINASC de 2011 e não existe no SIM de 2011.
- **Clima e PM2.5:** de 2010-01-01 a 2025-01-31. O início cobre os lags e a janela gestacional; o fim cobre o controle negativo com temperatura futura (até +7 dias).
- **Unidade de análise:** as 26 grandes concentrações urbanas do IBGE.
  - Fonte: *Arranjos Populacionais e Concentrações Urbanas do Brasil*, 2ª ed. (2016), composição `CodGrandeConcUrb_ConsidAnalise`.
  - São 24 arranjos e 2 municípios isolados (Manaus e Campo Grande), com 277 municípios, cada um numa só concentração.
  - Somam 41,2% da população de 2022 e 41,0% dos NV de 2012–2024.
  - Porto Alegre entra pela 2ª integração (29 municípios) e São José dos Campos pela 1ª (10).
- **Cidade-núcleo:** o maior município no Censo 2022 (E15). Coincide com a sede do IBGE em 25 das 26 concentrações; em Vitória/ES, o núcleo é Serra.
- **Residência:** `CODMUNRES`, com 6 dígitos.

### 3. O que foi baixado (item 1 da entrega)

| Fonte | Conteúdo | Cobertura | Arquivos | Versão e status |
|---|---|---|---|---|
| SINASC (DATASUS) | Nascidos vivos | 2011–2024, 27 UFs | 378 | definitivo em todos |
| SIM-DO (DATASUS) | Óbitos não fetais | 2011–2024, 27 UFs | 378 | definitivo em todos |
| SIM-DOFET (DATASUS) | Óbitos fetais | 2011–2024, nacional | 14 | definitivo em todos |
| BR-DWGD (UFES/UTexas) | Tmax, Tmin, UR e chuva; grade de 0,1° | 2001–2025 (usado de 2010-01-01 a 2025-01-31) | 4 NetCDF | v_3.2.4 (a versão está só no nome do arquivo); 0 dia faltando |
| CAMS EAC4 (ECMWF, via ADS) | PM2.5 a cada 3 h; grade de 0,75° | 2010-01-01 a 2025-01-31 | 16 | reanálise; 0 dia faltando |
| IBGE | Malha municipal 2024; Censo 2022 (SIDRA 4709); Arranjos Populacionais, 2ª ed. | — | — | oficial |
| Planalto | Leis dos feriados nacionais | 2010–2025 | 5 leis | 122 feriados conferidos no texto |
| Curvas de peso | OMS (Kiserud 2017), Pedreira 2011, INTERGROWTH-21st (pacote `gigs` 0.5.2.9000, r-universe) | 22–42 semanas | — | p10 extraído com dupla leitura |

Nenhum arquivo é preliminar, está ausente ou teve falha. Os checksums estão em `logs/integridade.csv`.

### 4. Critério de aceite: violações e resolução (item 2)

- **Contagens por UF × ano:** diferença 0 em todas as 1.188 células.
  - SINASC × CliMaterna: 378 células.
  - SIM-DO × CliMaterna: 324; SIM-DO × TabNet: 81.
  - DOFET × CliMaterna: 324; DOFET × TabNet: 81.
  - O script `98_aceite_fase1.py` refaz tudo e termina em "ACEITE: OK".
- **Status e UFs:** os 770 arquivos são definitivos, há 27 UFs em todos os anos, e a UF do arquivo é igual à do `CODMUNRES` em 100% dos registros.
- **Município de residência inválido < 1%: violado no SIM. Aceito com ressalva.**
  - SIM-DO: 4 células, todas no RJ, em 2011–2014 (1,12% a 1,32%).
  - DOFET: 34 células UF × ano. No RJ, a proporção cai de 9,40% (2011) para 1,05% (2023).
  - São óbitos com a UF conhecida e o município ignorado, que não entram em nenhuma concentração.
  - Consequência: o óbito fetal do RJ fica subcontado de forma decrescente no tempo, cerca de 6% em 2012 e cerca de 1% desde 2020. Isso precisa ser declarado como limitação.
- **Variáveis ausentes:**
  - o `SEMAGESTAC` não existe no SIM de 2011;
  - o `TPROBSON` falta no SINASC de 2013, sem explicação, mas não é usado.
- **Emenda de séries 2011 → 2012:**
  - `SEMAGESTAC` preenchido no SINASC: 54,0% em 2011, 91,8% em 2012 e 97–99% depois.
  - Nos 277 municípios, a fração mensal com IG válida em 2011 sobe de 25,0% (janeiro) para 84,9% (dezembro). Usar o `SEMAGESTAC` de 2011 criaria sazonalidade espúria.
  - Resolução (adendo v1.3): análise principal em 2012–2024, e 2011 só pela faixa `GESTACAO` (E18), com as colunas de IG em NA.

### 5. Totais por ano (item 3)

Série com coorte fixa nas 26 concentrações (277 municípios). O ‰ perinatal é óbito perinatal ÷ (NV únicos + óbito fetal) × 1.000. O PIG conta os NV a termo da população principal.

| Ano | NV únicos 22–42 | Prematuros | % PTB | Óbito fetal | Neonatal precoce | Óbito perinatal | ‰ perinatal | PIG: n a termo | % PIG IG-21 | % PIG Pedreira | % PIG OMS |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2012* | 768.344 | 94.944 | 12,36 | 7.666 | 4.326 | 11.992 | 15,5 | 964.196 | 9,66 | 6,96 | 16,09 |
| 2013 | 1.161.229 | 124.103 | 10,69 | 9.605 | 5.513 | 15.118 | 12,9 | 1.036.510 | 9,65 | 6,92 | 16,37 |
| 2014 | 1.202.373 | 122.514 | 10,19 | 10.019 | 5.724 | 15.743 | 13,0 | 1.079.264 | 9,36 | 6,69 | 16,08 |
| 2015 | 1.220.864 | 118.949 | 9,74 | 10.388 | 5.721 | 16.109 | 13,1 | 1.101.302 | 9,37 | 6,70 | 16,29 |
| 2016 | 1.155.936 | 114.465 | 9,90 | 9.540 | 5.400 | 14.940 | 12,8 | 1.040.666 | 8,99 | 6,46 | 15,89 |
| 2017 | 1.173.675 | 114.113 | 9,72 | 9.706 | 5.516 | 15.222 | 12,9 | 1.058.851 | 8,78 | 6,26 | 15,74 |
| 2018 | 1.162.650 | 113.704 | 9,78 | 9.718 | 5.297 | 15.015 | 12,8 | 1.048.308 | 8,64 | 6,17 | 15,45 |
| 2019 | 1.115.281 | 109.389 | 9,81 | 9.119 | 5.194 | 14.313 | 12,7 | 1.005.241 | 8,73 | 6,25 | 15,68 |
| 2020 | 1.055.816 | 105.638 | 10,01 | 9.251 | 4.819 | 14.070 | 13,2 | 949.562 | 8,24 | 5,92 | 14,86 |
| 2021 | 1.013.177 | 101.787 | 10,05 | 9.004 | 4.558 | 13.562 | 13,3 | 910.815 | 8,72 | 6,26 | 15,60 |
| 2022 | 972.576 | 101.396 | 10,43 | 8.236 | 4.453 | 12.689 | 12,9 | 870.520 | 9,18 | 6,62 | 16,33 |
| 2023 | 956.105 | 100.718 | 10,53 | 7.908 | 4.499 | 12.407 | 12,9 | 854.861 | 8,90 | 6,45 | 16,06 |
| 2024* | 833.822 | 83.977 | 10,07 | 5.629 | 3.255 | 8.884 | 10,6 | 749.344 | 8,47 | 6,14 | 15,39 |

\* **2012 e 2024 são as bordas da coorte fixa.** Nesses anos, as proporções não são comparáveis às dos outros, e os modelos devem usar a coorte fixa como foi desenhada, não a contagem por ano civil. Em 2024, as colunas neonatais também estão em NA a partir de 25/12 (censura de dezembro).

- **Totais de 2012–2024:**
  - com coorte fixa: 13.791.848 NV únicos, 1.405.697 prematuros e 180.064 óbitos perinatais;
  - sem coorte fixa: 14.221.644 NV únicos, 1.454.862 prematuros e 185.115 óbitos perinatais.
- **PIG, 2012–2024 (12.669.440 NV a termo):** 8,99% de PIG pela curva INTERGROWTH-21st e 6,45% pela de Pedreira (817.753 ÷ 12.669.440 = 6,4545%; a versão anterior trazia 6,46%, média dos % anuais arredondados). Pela OMS, são 15,84% dos 11.584.185 classificáveis; a curva termina em 40 semanas, então 41 e 42 semanas ficam sem classificação.
- **Sensibilidade de 2011 (E18):** 107.645 prematuros entre 1.165.210 NV únicos dos códigos 2–6 de `GESTACAO` (9,24%), sem coorte fixa.
- **Outras sensibilidades:** estão no relatório.
  - Série sem coorte fixa.
  - Óbitos `_sem_ig`.
  - Óbito perinatal indexado no óbito, até 24 h e sem anomalia.
  - PIG de pré-termo (24–36 semanas).

### 6. Concentrações, critério de eventos e cidades-núcleo (itens 4 e 6)

Eventos na série com coorte fixa, no período principal. O † marca as concentrações abaixo de 2.000 óbitos perinatais.

| Concentração | Cidade-núcleo | Municípios | Pop. 2022 | Prematuros 2012–2024 | Óbitos perinatais 2012–2024 | % NV com IG e peso válidos |
|---|---|---:|---:|---:|---:|---:|
| São Paulo/SP | São Paulo | 37 | 20.673.280 | 341.498 | 39.575 | 99,55 |
| Rio de Janeiro/RJ | Rio de Janeiro | 21 | 11.760.550 | 186.425 | 29.074 | 98,82 |
| Belo Horizonte/MG | Belo Horizonte | 23 | 4.963.704 | 76.178 | 9.750 | 99,23 |
| Brasília/DF | Brasília | 9 | 3.858.760 | 69.528 | 8.651 | 98,78 |
| Recife/PE | Recife | 15 | 3.783.639 | 67.692 | 8.273 | 98,2 |
| Porto Alegre/RS | Porto Alegre | 29 | 3.679.298 | 59.816 | 6.116 | 99,7 |
| Fortaleza/CE | Fortaleza | 8 | 3.424.978 | 63.755 | 7.335 | 93,08 |
| Curitiba/PR | Curitiba | 18 | 3.382.210 | 46.849 | 5.531 | 98,78 |
| Salvador/BA | Salvador | 10 | 3.320.568 | 50.715 | 10.003 | 95,57 |
| Goiânia/GO | Goiânia | 15 | 2.481.043 | 43.134 | 5.211 | 96,69 |
| Campinas/SP | Campinas | 8 | 2.093.118 | 34.060 | 2.747 | 99,41 |
| Manaus | Manaus | 1 | 2.063.689 | 46.561 | 7.136 | 97,18 |
| Belém/PA | Belém | 4 | 1.957.533 | 42.298 | 5.398 | 95,38 |
| Vitória/ES | Serra (sede IBGE: Vitória) | 6 | 1.756.172 | 27.730 | 3.806 | 99,46 |
| Baixada Santista/SP | Santos | 7 | 1.672.991 | 26.012 | 3.305 | 99,44 |
| São José dos Campos/SP | São José dos Campos | 10 | 1.589.875 | 26.851 | 2.408 | 96,96 |
| São Luís/MA | São Luís | 4 | 1.458.836 | 29.709 | 4.066 | 96,19 |
| Natal/RN | Natal | 5 | 1.263.738 | 26.181 | 2.716 | 96,8 |
| Maceió/AL | Maceió | 9 | 1.194.596 | 22.986 | 3.007 | 97,95 |
| Florianópolis/SC | Florianópolis | 10 | 1.183.874 | 14.256 | 1.465 † | 99,24 |
| João Pessoa/PB | João Pessoa | 6 | 1.173.268 | 19.948 | 2.814 | 98,91 |
| Teresina/PI | Teresina | 2 | 1.040.765 | 20.496 | 2.746 | 96,3 |
| Aracaju/SE | Aracaju | 12 | 1.019.011 | 16.960 | 3.080 | 99,4 |
| Cuiabá/MT | Cuiabá | 2 | 950.955 | 17.328 | 2.412 | 98,9 |
| Sorocaba/SP | Sorocaba | 5 | 945.097 | 13.688 | 1.504 † | 99,35 |
| Campo Grande | Campo Grande | 1 | 898.100 | 15.043 | 1.935 † | 99,88 |

- **Cortes de eventos:**
  - 500 e 1.000 eventos: as 26 passam, nos dois desfechos.
  - 2.000 eventos: as 26 passam na prematuridade e 23 no óbito perinatal.
- **Completude de IG e peso:** passa de 90% em todas; a menor é a de Fortaleza, 93,08%.
- **Temperatura:** nenhum núcleo tem dia sem `tmean`.
- **Cidade-núcleo, caso inesperado:** em Vitória/ES, o núcleo é Serra (520.653 habitantes em 2022), e não a sede do IBGE, Vitória (322.869). Vale a regra do E15, decidida em 03/10/2026. O IBGE marca mais de um núcleo também na Baixada Santista, em Porto Alegre e em São José dos Campos; nessas três, o maior município coincide com a sede.

### 7. Cobertura do PM2.5 e completude das variáveis do PTB espontâneo (item 7)

**PM2.5:** vem do CAMS EAC4 nas 26 concentrações e não foi validado contra estações de superfície (decisão de 06/10/2026).

| Variante | Núcleos com algum dia sem valor | Máximo de dias sem valor em 2012–2024 |
|---|---|---|
| `pm25` (dia UTC, zeros como estão) e `pm25_local` (dia local) | 0 de 26 | 0 |
| `pm25_zero_na` e `pm25_local_zero_na` (zero vira NA; exige 6 de 8 horários) | 21 de 26 | 361 de 4.749 (Campo Grande) |

- As maiores lacunas do `pm25_zero_na` são Campo Grande (361 dias), Goiânia e Brasília (332 cada) e Teresina (179). Cinco núcleos não têm nenhuma: São Paulo, Rio de Janeiro, Campinas, Baixada Santista e João Pessoa.
- Entre 2,0% e 3,3% dos valores do CAMS, a depender do ano, são exatamente zero. Eles aparecem quase só entre 12 e 21 UTC, em episódios de concentração baixa.

**Completude das variáveis do PTB espontâneo** (Brasil, % preenchido; o código 9 conta como preenchido):

| Variável | 2011 | 2012 | 2013 | 2014 | 2015 | 2016 | 2017–2024 |
|---|---:|---:|---:|---:|---:|---:|---:|
| `STCESPARTO` | 73,5 | 95,1 | 97,1 | **54,8** | **53,4** | 98,2 | 98,3–99,2 |
| `STTRABPART` | **55,2** | 93,4 | 96,3 | 97,2 | 97,2 | 97,9 | 98,1–99,1 |
| `TPMETESTIM` | **9,2** | **22,0** | 89,4 | 91,0 | 97,4 | 98,0 | 98,2–99,3 |
| `OBITOPARTO` (DOFET) | 95,2 | 95,0 | 95,3 | 95,7 | 96,0 | 96,5 | 96,7–97,4 |

- **`STCESPARTO`, queda de 2014–2015:** ela está toda no parto vaginal, em que o campo veio vazio em vez de "3 – não se aplica" (1.275.433 de 1.277.175 em 2014). A base guarda o valor bruto e a coluna `stcesparto_aj`, que trata o vazio como 3 no parto vaginal. Nas cesáreas não há quebra.
- **`STTRABPART`:** não tem código 3. O vazio cai de 44,8% em 2011 para menos de 1% em 2023–2024.

### 8. Pendências e limitações a declarar (item 5)

- **Tendência artificial no óbito perinatal principal.**
  - Na base (26 concentrações, arquivo sem coorte fixa), a fração de óbitos únicos sem IG, `*_sem_ig` ÷ (principal + `*_sem_ig`), cai de 12,7% (neonatais) e 9,6% (fetais) em 2012 para 2,2% e 3,6% em 2024.
  - Como eles saem do principal, a série principal ganha uma alta que não é real.
  - As colunas `*_sem_ig`, no arquivo sem coorte fixa, medem o efeito.
  - *Correção de 07/10/2026:* a versão anterior citava 16,4% e 13,0% → 6,0%. Esses números são do Brasil inteiro, com todos os registros, sem `SEMAGESTAC` e sem `GESTACAO`; não são da base.
- **Óbito fetal subcontado no RJ** por município ignorado, de forma decrescente no tempo (seção 4).
- **Zeros exatos no PM2.5 do CAMS:** não foi verificado se vêm do EAC4 ou da conversão feita pela ADS. A base guarda as variantes com e sem zero.
- **Grade do CAMS:** é grossa (0,75°), e o viés muda de sinal conforme o lugar. Na literatura, há superestimativa em São Paulo (Paiva et al. 2025) e subestimativa em Salvador (Jacobson et al. 2024).
- **Arranjos Populacionais:** não foi verificado se o IBGE publicou uma edição com o Censo 2022. A composição usada é a da 2ª edição (2016), com o Censo 2010.
- **Pedreira 2011:**
  - o p10 feminino de 33 semanas (1.697 g) parece erro de impressão; foi transcrito como publicado e só afeta a sensibilidade de pré-termo.
  - **A curva é baixa para a nossa população a termo.** O p10 observado em 2012–2024 fica 49–117 g acima do de Pedreira entre 37 e 41 semanas, e por isso o PIG sai em 6–7%. A fonte é o SINASC de 2003–2005, quando a IG vinha em faixas; o artigo não explica como chegou à tabela por semana. A transcrição foi confirmada numa terceira leitura (07/10/2026).
- **INTERGROWTH-21st de 24 a 32 semanas:** usa a referência de muito pré-termo (Villar 2016), marcada como não verificada (E8).
- **Item (p) da especificação:** ver o pedido 1 da Parte 1.

### 9. Decisões (item 8)

**Resolvidas na construção:**
- **Desempates de pertença:** nenhum. Cada um dos 277 municípios está numa só concentração, e o `04` para se algum se repetir.
- **Municípios novos com mais de uma origem:** nenhum. Há 6 instalados depois de 2010, e nenhum encosta numa concentração (E17).
- **Arremates de 07/10/2026:**
  - `_tmp/` limpa (1,2 GB para a lixeira);
  - repositório git criado;
  - matrizes semanais mantidas em Float64. A conversão para Float32 mudaria a versão da base sem ganho de análise.

**Em aberto, para cada artigo** (a base gravou as variantes como colunas):
- **Exposição principal:** `_nucleo` (série da cidade-núcleo), `_mun` (série do próprio município) ou `_rm_nv` (média ponderada por NV).
- **PM2.5:** se entra e com qual variante (`pm25`, `pm25_zero_na`, `pm25_local`, `pm25_local_zero_na`).
- **Lags:** estrutura e defasagem máxima.
- **Denominador:** como usar a coorte fixa e as gestações em risco (E6/E7). O W_t e o γ são calculados no R de cada artigo.
- **Prematuridade espontânea:** se separa e como (`STTRABPART`, `stcesparto_aj`, `PARTO`).
- **2011:** como entra a sensibilidade do E18.
- **Corte de inclusão das concentrações:** 500, 1.000 ou 2.000 eventos.
- **Óbito perinatal:** como tratar a tendência dos sem IG; indexar pelo nascimento ou pelo óbito.
- **PIG:**
  - OMS comparada com a semana inteira ou no meio da semana (`pig_oms_meio_semana`);
  - ajuste de dias do INTERGROWTH (+3 no principal; +0 e +6 como sensibilidades);
  - coorte e período da sensibilidade de pré-termo.

### 10. Definições operacionais

**Idade gestacional e populações**
- **IG:** `SEMAGESTAC`, em semanas completas.
  - SINASC: válida de 22 a 44, com 43–44 à parte; abaixo de 22 e a partir de 45, inválida; vazio, 9 e 99 contam como ausente.
  - SIM: de 1 a 47, com 9 e 99 = ignorado.
- **Início da gestação:** `dum_est` = data do parto − (7 × IG + 3) dias.
- **Gestação única:** `GRAVIDEZ` = 1.
- **Prematuridade:**
  - população: NV único de 22–42 semanas;
  - desfecho: 22–36 semanas, dividido em extremo (22–27), muito (28–31) e moderado/tardio (32–36).
- **Coortes fixas:**
  - `coorte_fixa_22`: `dum_est` de 2011-07-31 a 2024-03-05;
  - `coorte_fixa_37`: `dum_est` de 2011-04-17 a 2024-03-05.
  - A série principal usa só a coorte fixa; um arquivo à parte traz a série sem ela.

**Óbitos**
- **Óbito fetal:** DOFET com `TIPOBITO` 1. O critério é hierárquico: `SEMAGESTAC` ≥ 22; se não houver, `GESTACAO` 2–6; se não houver, peso ≥ 500 g.
  - Principal: único, pelo critério de `SEMAGESTAC`, com IG de 22–42.
  - `obito_fetal_sem_ig`: único sem IG válida que entra pela faixa ou pelo peso. Só existe no arquivo sem coorte fixa.
- **Óbito neonatal precoce:** DO com `TIPOBITO` 2 e `IDADE` em minutos (0xx), em horas (1xx) ou até 6 dias (200–206).
  - Principal: único, com IG de 22–42 e `DTNASC` preenchida.
  - `_sem_ig`: único sem IG válida.
- **Data-índice:**
  - óbito fetal: `DTOBITO`;
  - óbito neonatal: `DTNASC` do registro de óbito;
  - as colunas `_idx_obito` contam os mesmos óbitos pela `DTOBITO`.
- **Óbito perinatal e variantes:**
  - `obito_perinatal` = fetal principal + neonatal principal;
  - `obito_ate24h`: neonatal principal com `IDADE` 0xx, 1xx ou 200;
  - `obito_perinatal_24h` = fetal principal + `obito_ate24h`;
  - `_sem_anomalia`: `CAUSABAS` fora do capítulo Q.
- **Censura de dez/2024:** as colunas neonatais indexadas no nascimento ficam em NA a partir de 25/12/2024, porque o DO 2025 não foi baixado.
- **2011:** as colunas que dependem de IG ficam em NA. Só ficam preenchidas `ptb_gestacao_sens2011` (`GESTACAO` 2–4) e `nv_gestacao_sens2011` (`GESTACAO` 2–6, incluindo quem tem 43 semanas ou mais).

**Gestações em risco e exposições**
- **Gestações em risco (E7):** Z_tj por município, dia (2012–2024) e semana gestacional (22–42), separado em `z_nv` e `z_fetal`. Entram NV únicos e óbitos fetais principais da `coorte_fixa_22`.
- **Exposições diárias:**
  - variáveis: `tmean` = (Tmax + Tmin) / 2, do BR-DWGD; `rh`; e as quatro variantes de PM2.5, todas ponderadas pela área do município;
  - versão `_nucleo`: a série da cidade-núcleo, a mesma para todo o recorte;
  - versão `_mun`: a série do próprio município;
  - versão `_rm_nv`: média dos municípios do recorte, ponderada pelo total de NV de 2011–2024 (peso fixo) e renormalizada nos dias em que falta dado.
- **Variantes do PM2.5:**
  - `pm25`: dia UTC, com os zeros mantidos;
  - `pm25_zero_na`: zero vira NA, e o dia exige 6 de 8 horários;
  - `pm25_local` e `pm25_local_zero_na`: as mesmas regras no dia local aproximado (UTC−3).
- **Matriz semanal:**
  - colunas `s01`…`s37` por `dum_est` (de 2010-01-01 a 2024-12-31); `s{k}` é a média dos dias 7(k−1) a 7k−1, e fica NA se faltar algum dia;
  - **a matriz não corta no parto:** nos pré-termo, ponha NA nas semanas k > IG;
  - gravada para `tmean`, `rh` e `pm25` nas três versões; as outras variáveis saem pela função `matriz_semanal()`.

**PIG, covariáveis e calendário**
- **PIG:**
  - população principal: NV único de 37–42 semanas, peso de 200 a 7.000 g, sexo conhecido, `coorte_fixa_37` e |z| ≤ 5;
  - INTERGROWTH-21st: `gigs`, com IG em dias = 7 × IG + 3 (+0 e +6 como sensibilidades), com p10 e p3;
  - Pedreira 2011: de 24 a 42 semanas;
  - OMS (Kiserud 2017): por sexo, até 40 semanas, com colunas à parte para o meio da semana e para a curva sem sexo;
  - sensibilidade de pré-termo: 24–36 semanas, sem coorte.
- **Paridade:**
  - principal: `QTDPARTNOR` + `QTDPARTCES` (partos anteriores);
  - sensibilidade: `QTDFILVIVO`;
  - a `PARIDADE` do sistema não é usada.
- **Calendário:** `feriado_nacional` só com o que a lei federal declara. Carnaval, Quarta de Cinzas, Sexta-Feira da Paixão e Corpus Christi ficam em colunas próprias. Feriados estaduais e municipais ficam fora.

### 11. Como os artigos acessam a base

**Para começar:**

```r
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R")
versao()
```

```python
import sys; sys.path.insert(0, "/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso")
import acesso as A
A.versao()
```

**Em seguida:**
1. Registre a `versao()` no log de análise do artigo.
2. Leia o `09_acesso/DICIONARIO.md` e o `logs/desvios_especificacao.md`.
3. Escolha e registre:
   - a versão da exposição;
   - a variante de PM2.5;
   - a série, com ou sem coorte fixa;
   - o período.

**Funções principais**, com os mesmos nomes e os mesmos resultados em R e em Python:
- **Séries e denominador:** `serie_diaria(nivel, coorte_fixa)` e `gestacoes_em_risco(nivel)`.
- **Microdado:** `nascimentos()`, `obitos()` e `pig()`.
- **Clima, PM2.5 e calendário:** `clima_municipal()`, `pm25_municipal()` e `calendario()`.
- **Exposições:** `expo_semanal()`, `matriz_semanal()`, `diaria_recorte()` e `ligar_expo_semanal(nasc, var, versao_expo, ajuste_dias = 3)`.
- **Referências:** `concentracoes()`, `cidade_nucleo()` e `referencias_pig()`.

**Sigilo (LGPD), obrigatório nas conversas dos artigos:**
- **Microdado** (`nascimentos`, `obitos` e `pig`):
  - nunca exibir uma linha, nem em depuração;
  - nunca copiar para fora da Forja, colar no chat, num commit ou num log;
  - nunca enviar a serviço externo.
- **Restrito** (séries por município ou concentração × dia e gestações em risco):
  - só sai agregado por recorte × ano, ou mais grosso, com contagem menor que 10 escrita como "<10";
  - se um total e suas partes forem publicados juntos, nenhuma parte menor que 10 pode ser recuperável por subtração.
- **Público:** clima, PM2.5, calendário, referências e logs agregados.

### 12. Garantia de qualidade

- **Dupla auditoria em cada etapa.** Primeiro, uma autoauditoria. Depois, um subagente em contexto limpo audita com acesso só aos logs agregados e ao código. Nenhum achado é aceito sem ser reproduzido com código próprio.
- **Testes sintéticos, sem dado real, rodados em 07/10/2026:** 06a 10/10, 06b 35/35, 06c 28/28, 06d 8/8 e PIG 31/31.
  - O arquivo `00_scripts/testes/MAPA_ESPECIFICACAO.md` liga cada item (a)–(q) da especificação ao caso que o cobre.
  - Os casos novos do 06b provaram que conseguem falhar: com três defeitos plantados numa cópia do script, falharam exatamente os casos correspondentes.
- **Interface, dicionário e proveniência, rodados em 07/10/2026:**
  - **interface em Python, 22/22:** recalcula o md5 de todos os arquivos contra o manifesto, então a base está íntegra na versão `7e99bf94`; refaz as 9 matrizes semanais e confere a ligação com os nascimentos;
  - **interface em R, 18/18:** confere que o R dá o mesmo resultado que o Python, linha a linha;
  - **dicionário:** documenta as colunas dos 31 arquivos do manifesto, com o tipo de cada uma;
  - **proveniência:** passa em 10 de 10 casos.
- **Proveniência:** cada saída registra o md5 dela, dos insumos e do código. O `08_manifesto.py` para se um arquivo mudou por fora ou se um insumo mudou depois da geração.
- **Aceite reproduzível:** o `98_aceite_fase1.py` refaz o confronto UF × ano com o CliMaterna e o TabNet.

### 13. Principais desvios da especificação

O registro completo, com as justificativas, está em `logs/desvios_especificacao.md`.

- **02/10/2026:**
  - análise principal em 2012–2024 e 2011 só como sensibilidade pela faixa `GESTACAO` (adendo v1.3; E18);
  - unidade de análise: as 26 grandes concentrações urbanas do IBGE, no lugar das RMs/RIDEs e do corte de 1 milhão de habitantes;
  - PM2.5 do CAMS EAC4 baixado direto da ADS, no lugar do SISAM;
  - paridade pelos partos anteriores.
- **03/10/2026:** cidade-núcleo = maior município no Censo 2022 (Serra, em Vitória).
- **05/10/2026:**
  - temperatura, umidade e PM2.5 com o mesmo tratamento, e as três versões da exposição gravadas como colunas;
  - gestações em risco calculadas em Python (`06d`), no lugar do `04_series_offset.R`;
  - 2011 com as colunas de IG em NA, e censura a partir de 25/12/2024;
  - arquivos sem o sufixo `_rm`; as janelas fixas do 06c antigo saíram, porque derivam da matriz semanal;
  - PIG em dois scripts (`07a`, com o p10 por dupla leitura, e `07b`, com as três curvas); `gigs` do r-universe; Pedreira usada de 24 a 42 semanas.
- **06/10/2026:** PM2.5 sem validação contra estações de superfície.
- **07/10/2026:** no teste sintético, os itens (h), (l) e (n) não se aplicam (pressupõem RMs), o (j) não é exercitado (nenhum município novo encosta numa concentração), e o (p) é impossível como escrito.
