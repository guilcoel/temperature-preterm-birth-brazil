# FONTE — Curvas de referência do PIG (E8; adendo v1.2, D5)

**Atualizado em 2026-10-05.** Regras em `logs/desvios_especificacao.md` (quatro entradas de 05/10 sobre o E8).

Cada nascido vivo da população recebe três classificações, em colunas separadas:
- `pig_ig21`: INTERGROWTH-21st, a principal;
- `pig_pedreira`: Pedreira 2011;
- `pig_oms`: OMS, Kiserud 2017.

## 1. Fontes

| Curva | Referência | O que se usa | Original em `originais/` (md5) |
|---|---|---|---|
| INTERGROWTH-21st | Villar J et al. *Lancet* 2014;384:857–868 ([DOI](https://doi.org/10.1016/S0140-6736(14)60932-6); PMID 25209487), padrão de 33+0 a 42+6. Villar J et al. *Lancet* 2016;387:844–845 ([DOI](https://doi.org/10.1016/S0140-6736(16)00384-6); PMID 26898853), referência de muito pré-termo, de 24+0 a 32+6 | Escore z de peso para IG e sexo, pelo pacote R `gigs` | não se aplica (o pacote traz os coeficientes) |
| OMS | Kiserud T et al. *PLoS Med* 2017;14(1):e1002220 ([DOI](https://doi.org/10.1371/journal.pmed.1002220)) | p10 do peso fetal estimado: Tabela 14 (feminino), Tabela 15 (masculino) e Tabela 11 (sem sexo), semanas 14–40 | `kiserud2017_plosmed.pdf` (745de4e3efbc8d34ef49549c0ade3543); `kiserud2017_S1_File.xlsx` (4a83338744094f6df231c5d938897424); `kiserud2017_plosmed.html`; imagens `kiserud2017_t011/t014/t015.png` |
| Pedreira | Pedreira CE, Pinto FA, Pereira SP, Costa ES. *An Acad Bras Cienc* 2011;83(2):619–25 ([DOI](https://doi.org/10.1590/S0001-37652011005000008); PMID 21625798) | p10 por sexo e semana completa, Table I (p. 622): semanas **22–42**. O resumo fala em 22–43, mas a tabela e os métodos vão até 42 | `pedreira2011_aabc.pdf` (b2b72dfe0856482655a0369626edb0b0), **salvo à mão por Guilherme** em 05/10/2026, porque o SciELO bloqueia download automático; páginas renderizadas em `pedreira2011_paginas/` |

Baixados em 2026-10-05 com autorização de Guilherme.

## 2. Extração do p10 (`00_scripts/07a_referencias_pig.py`), com dupla leitura

- **Leitura 1:** camada de texto do PDF oficial, extraída com o PDFKit do macOS (`osascript`; nenhum pacote novo).
- **Leitura 2:** transcrição **cega** das imagens oficiais das tabelas, feita por outro leitor (um subagente que não viu a leitura 1), em `dupla_leitura/kiserud2017_t0{11,14,15}_leitura2.csv`.
- **OMS, Tabela 11:** também comparada com a aba `efw` do suplemento S1 (Excel), que é leitura de máquina independente.
- **Resultado da OMS:** as leituras batem em **todas** as células. Tabela 11: PDF = imagem = Excel (270 células). Tabelas 14 e 15: PDF = imagem (216 células cada). Os valores crescem com a semana e entre percentis.
- **Saída:** `oms_kiserud2017_p10.csv` (semana, sexo F/M/ambos, p10_g, tabela; 81 linhas).
- **Pedreira.**
  - A Table I é **imagem** no PDF, então as duas leituras são visuais e independentes: Claude e um subagente cego, sobre a página renderizada pelo PDFKit.
  - As 189 células (p3, p5, p10 e p25 por sexo, semanas 22–42) batem.
  - **Incoerências do próprio artigo, apontadas pelas duas leituras e transcritas como publicadas:**
    - p10 feminino de 33 semanas = 1.697 g, com +416 g sobre a 32 e +3 g até a 34 (possível erro de impressão);
    - p3 > p5 no masculino de 34 semanas;
    - salto no p5 feminino de 34 semanas.
  - O primeiro caso fica marcado na coluna `observacao` do `pedreira2011_p10.csv`. Só afeta a sensibilidade de pré-termo, não a população principal (37–42).
  - Saída: `pedreira2011_p10.csv`, 42 linhas.
  - **Terceira leitura (07/10/2026, pedido da coordenação, A5):** p10 de 37 a 42 semanas nos dois sexos, sobre a página renderizada e girada; bate com o CSV (39 semanas: M 2.750 g, F 2.660 g; 40 semanas: M 2.823 g, F 2.728 g).
  - **IG na consulta:** semana completa (`ga_sem`), sem os +3 dias, que valem só para o INTERGROWTH (IG em dias). É a definição do artigo: "interval, in completed weeks, between the first day of the mother's last menstrual period (LMP) and the day of delivery" (p. 620).
  - **Limitação da fonte, não verificada a fundo:** os dados são do SINASC de 2003–2005, e o próprio artigo diz que, nesses anos, a IG vinha em faixas (< 22, 22–27, 28–31, 32–36, 37–41, > 41). A tabela por semana completa sai de "smoothed estimated curves", e o artigo não explica como passou das faixas para as semanas.
  - **Consequência medida (07/10/2026, só agregados):** nos NV únicos a termo de 2012–2024 (coorte fixa 37, peso válido, sexo conhecido), o p10 observado fica 49–117 g acima do de Pedreira de 37 a 41 semanas (39 semanas: +100 g M, +92 g F; 40 semanas: +117 g M, +107 g F). Por isso o PIG por Pedreira fica em 6–7%, e não perto de 10%. Com o p10 interpolado em 7 × IG + 3 dias, o PIG sobe de 6,50% para 7,82% na mesma população: chega a 10,7% na semana 37, mas fica em 6,7–7,4% de 39 a 41 semanas. Os +3 dias explicam só uma parte da diferença. Script da conferência: `00_scripts/testes/conciliacao_coordenacao_20261007.py`, função `a5()`.
- **Proveniência:** horários e md5 de cada leitura em `dupla_leitura/LEIAME.md`.

## 3. INTERGROWTH-21st pelo `gigs`

**Pacote.**
- `gigs` 0.5.2.9000, do r-universe da rOpenSci (commit `fb58fe6596d4b289d5362c5efe00f882984d3186`, empacotado em 2026-09-07). O CRAN não tem o gigs hoje.
- Compilado no R 4.5.3; roda no R 4.5.1. O `sessionInfo()` fica em `logs/sessionInfo_07b_*.txt`.

**Função** (assinatura conferida na documentação oficial, https://docs.ropensci.org/gigs/, em 05/10/2026):
- `value2zscore(y, x, sex, family = "ig_nbs", acronym = "wfga")`;
- `y` = peso em kg e `x` = IG em dias, de 168 a 300 (24+0 a 42+6), conforme `report_units()`; fora da faixa dá NA com aviso;
- o centil é `pnorm(z)`, igual ao `value2centile` (diferença máxima de 1e-16, conferida).

**IG em dias.** O SINASC só tem semanas completas. A principal usa 7 × IG + 3 (meio da semana); as sensibilidades, 7 × IG (`pig_ig21_g0`) e 7 × IG + 6 (`pig_ig21_g6`).

**Cortes.** PIG < p10 (`pig_ig21`) e < p3 (`pig_ig21_p3`). Com `|z| > 5` (`ig21_z_extremo`), o nascido sai da população.

**24–32 semanas.** Usam a referência de muito pré-termo, marcada `ig21_ref_nao_verificada` (E8).

**Conferência do gigs contra a tabela de P10 por dia que o próprio pacote traz (`ig_nbs$wfga`, 2 casas, em kg).**
- A diferença chega a **8 g** em 14 dias de 33–39 semanas (11 no sexo masculino, 3 no feminino), acima do arredondamento de 5 g. A causa não foi verificada.
- **Nenhum desses dias é usado na população principal** (37–42 semanas, 7 × IG + 3), onde a diferença máxima é de 3,2 g.
- Afeta 2 dias da sensibilidade de pré-termo (+3) e 6 dias das sensibilidades +0 e +6.

## 4. Classificação (`07b_pig_classificacao.R`)

**Saída.** `06_processados/pig_classificacao.parquet`: uma linha por nascido vivo único de 24–42 semanas com peso válido, chave `id_nasc`.

**Populações.**
- `pop_pig_principal`: 37–42 semanas, sexo conhecido, `coorte_fixa_37` e `|z| ≤ 5`.
- `pig_sens_pretermo`: 24–36 semanas, sexo conhecido e `|z| ≤ 5`. A coorte e o período ficam para o artigo.

**Sexo.** `SEXO` 1 = M e 2 = F (`01_sinasc/FONTE.md`). Com 0 ou 9, as curvas por sexo ficam NA.

**OMS.**
- A IG em semanas completas é comparada com o p10 da semana inteira da tabela, sem interpolar.
- 41–42 semanas: `pig_oms` = NA (a curva vai até 40).
- `pig_oms_meio_semana`: o p10 é interpolado linearmente em 7 × IG + 3 dias, como no INTERGROWTH. A partir de 40 semanas fica NA, porque a curva termina em 40+0.
  - Motivo: Kiserud ajusta os quantis por polinômio da IG contínua, então o valor da "semana 38" é o de 38+0, e o `pig_oms` subestima o p10 (auditoria do 07, A2).
- `pig_oms_sem_sexo` usa a Tabela 11.
- A Tabela 4 do artigo (peso **ao nascer** por sexo e semana completa) existe, mas o E8 pede a curva de peso fetal.

**Logs agregados** (26 concentrações × ano). Uma linha com qualquer contagem de 1 a 9, publicada ou dedutível por subtração, sai inteira em branco (`suprimido`):
- `logs/pig_resumo_ano.csv`: % de PIG por curva, ano e população, e exclusões;
- `logs/pig_concordancia.csv`: tabelas 2 × 2, concordância e kappa entre as curvas.

**Gerado no projeto em 05/10/2026.** O md5 é igual ao do rascunho; está no `integridade.csv`.
- **Números:** 14.827.644 classificados; população principal de 12.669.440; pré-termo 1.499.619; `|z| > 5` em 16.679; sexo ignorado em 2.676.
- **PIG na população principal, 2012–2024:**

  | Curva | % PIG |
  |---|---:|
  | INTERGROWTH | 8,99 |
  | INTERGROWTH p3 | 2,84 |
  | INTERGROWTH +0 | 6,84 |
  | INTERGROWTH +6 | 11,57 |
  | Pedreira | 6,45 |
  | OMS por sexo | 15,84 |
  | OMS no meio da semana | 18,98 |
  | OMS sem sexo | 16,23 |

- **Concordância INTERGROWTH × OMS:** 92,49%, kappa 0,65.
- **Supressão:** nenhuma linha dos logs foi suprimida.
- **Conferências:**
  - teste sintético em R com 31 casos, que mata os 20 mutantes testados;
  - conferência independente em Python, 15/15, com 0 células diferentes;
  - auditoria independente, achados A1–A12, registrada em `logs/auditoria_20261002.md`.

## 5. Limitações

1. A IG do SINASC tem qualidade variável. `TPMETESTIM` tem muita falta em 2012 e um código não documentado (8) em 2022 (`01_sinasc/FONTE.md`). Isso pesa no PIG, por erro de classificação da IG.
2. A curva da OMS é de **peso fetal estimado** por ultrassom e é aplicada aqui ao peso ao nascer. A diferença de % de PIG em relação ao INTERGROWTH (15,8% a 19,0% contra 9,0%) e a Pedreira (6,5%) deve ser discutida no artigo.
3. Alternativas que revisores podem pedir: Fenton 2013 ou a Tabela 4 de Kiserud 2017 (peso ao nascer). Ficam registradas, mas não foram implementadas.
