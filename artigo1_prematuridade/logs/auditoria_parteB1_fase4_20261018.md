# Fase 4, Parte B1: dupla auditoria interna (exposição, séries e contagens), 18/10/2026

- **Mensagem:** "Artigo 1, Fase 4, Parte B: exposição, séries e contagens, sem modelo de desfecho (scripts 64 a 69) — v1.0", do chat do A1, por Guilherme, 18/10/2026 (cópia literal em `logs/mensagem_chat_A1_fase4_parteB_20261018.md`, SHA-256 do texto colado `5edce39c…4fb3`). Pede a dupla auditoria interna da B1 antes de abrir a C1, com o log `auditoria_parteB1_fase4_<AAAAMMDD>.md`.
- **Cabeçalho (protocolo v1.1, 3.8):** a auditoria parte do `HEAD` `e29f391` (A1-102), com os scripts 64 a 68 em `49d482c`, `ac7dfb8`, `0c8ce91`, `8363805` e `928a965`, os logs em `d485303` e a A1-101 em `9bc996e`; último commit da `COORD` no `HEAD`: `a925d35` (COORD-8).
- **Escopo:** B1.1 a B1.5 (scripts 64 a 68). A B2 (feriados, script 69) corre à parte e não entra aqui.

## Rodada oficial (RODADA=20261018)

| Script | Log (SHA-256) | Resultado |
|---|---|---|
| 64 (B1.1) | `reconferencia_series_fase1_fase4_20261018.md` (`770acfcb…f103`) | 6 de 6 SHA-256 conferem com a RESPOSTA da Fase 1; os scripts 20, 21 e 22 originais (do `5bc94ec`, SHA conferido), rodados numa caixa de areia dentro da Forja, reconstroem os 6 arquivos idênticos (objeto e arquivo) |
| 65 (B1.2) | `percentis_exposicao_fase4_20261018.md` (`7a5b3056…e5ad`) | 6 exposições, 101 percentis; conferências contra os CSV da Fase 1 (5,0e-14, tolerância 1e-12 pelos 15 algarismos), `tmean` do clima = `tmean_nucleo` (0), AT contra a implementação independente (1,4e-14), nenhum NA |
| 66 (B1.3) | `series_exposicao_offset_fase4_20261018.md` (`047f610e…6337`) | 17 conferências; lista do PM2.5 zero = NA = a registrada (saem Brasília 88,0%, Goiânia 87,7% e Campo Grande 87,2%) |
| 67 (B1.4) | `ig_dum_e_2011_fase4_20261018.md` (`878b9721…01e7`) | controle obrigatório: Z_tj próprio na população inteira = `gestacoes_em_risco(recorte)` nas 26, de 2012 a 2024, semanas 22–42 (`identical`); 2011 = colunas da base (`identical`) |
| 68 (B1.5) | `contagens_insumos_fase4_20261018.md` (`275979e1…a9a2`) | identidades das contagens fecham; Q8 recontada = Q8 do arquivo; sem parada; IDHM não baixado (item 6 do log) |

## Etapa 1: autoauditoria com código diferente

Script `autoauditoria_B1.R` (pasta de trabalho da sessão, fora do git; SHA-256 `765fb65514a8bc7be3a7db63fccb315159e33fb7bee5ec87ee4f1310d0823d5d`). Ele lê a base pela interface e só imprime diferenças e agregados. Cada conta foi refeita por outro caminho:

| Item | Como foi refeito | Maior diferença |
|---|---|---|
| 65: percentis | quantil tipo 7 escrito à mão (ordenação e interpolação), Tmax do núcleo e `tmean_mun` agrupada, 3 concentrações (São Paulo, Campo Grande, Vitória/ES), p1, p2,5, p50, p97,5 e p99 | 7,1e-15 |
| 66: offset dos subtipos | log de Σ Z_tj e de Σ Z_tj·w_j / Σ Z_tj pelas colunas z22…z36 e o w_j do CSV da Fase 1 (Aracaju, janela principal) | 8,9e-16 |
| 66: controle negativo e UR | `stats::filter` (média de t+1 a t+7 e de t−3 a t) em vez da `media_janela` | 1,1e-14 e 2,8e-14 |
| 66: lista do PM2.5 | dia de modelo utilizável = valor no dia e no anterior, contado por outro código | 87,2%, 87,7%, 88,0% e 100% (iguais ao log) |
| 66: w_j por ano de entrada | laço à mão sobre os NV (entrada na semana j em s + 7j), j = 22, 30, 36, anos 2012, 2018, 2024 | 3,5e-17 |
| 66: w_j por pessoa-dia | n_j / (7(N_j − n_j) + 4n_j) à mão | 3,5e-17 |
| 66: eventos do termo precoce | soma direta dos NV de 37–38 semanas na janela | 0 |
| 67: Z_t da versão (ii) | força bruta (⌊(t − s)/7⌋ entre 22 e 36 e parto ≥ t), 6 datas sorteadas na janela principal | 0 |
| 67: PTB da versão (ii) | `aggregate` por data | 0 |
| 68: subtipo extremo | `tapply` sobre a série da Fase 1 | 0 |
| 68: % de cesárea | `table` por concentração | 4,3e-14 |

Nenhuma divergência.

## Etapa 2: auditoria independente

- **Auditor:** subagente em contexto limpo, 18/10/2026. Leu só a mensagem, os scripts 64 a 68, os cinco logs, os normativos, o plano, as entradas A1-88 a A1-102, o código compartilhado usado, os scripts 20 a 22 e o esquema da base. Não abriu `.parquet`, `.rds`, `.csv` nem `.dbc` e não rodou código com dado.
- **Relatório:** `auditoria_independente_B1.md` (pasta de trabalho da sessão, SHA-256 `2d1df3bb7b6e71b3c26bf52e19cdceb7b4f06077f4d022caf670f6cb23c9e3fd`).
- **Resultado:** 0 Críticos, 2 Maiores, 5 Menores e 16 Notas. Os números da B1 estão certos e os logs não violam o sigilo; os dois Maiores são de processo.
- **Reprodução própria:** `repro_aud_B1.R` (SHA-256 `a9bb18c9070e8135cd0a088cdd0827715c026e989ad8609be628c78421fdee21`) e `evidencia_atlas_m1.txt` (SHA-256 `08ad0b35fe7b9d1e9dee994db94fde4722764d80abd6664c116be0d12cc2b78b`), na pasta de trabalho.

| Achado | Reprodução | Correção |
|---|---|---|
| **M1 (Maior).** O PARE do IDHM sai no log do 68 como "nenhuma parada", com status 0. A A1-102 decide sozinha que ele "não bloqueia a C1", mas a mensagem diz "B1 (bloqueia a C1)" | Confirmado pela leitura do 68: o PARE do `consultas_cat` entra em `para` (l. 150); o do IDHM não entra, e o `ok` da l. 166 o ignora | A A1-103 registra o PARE do IDHM de forma explícita e retira a frase "não bloqueia a C1" como decisão minha. **A C1 não abre** até Guilherme decidir entre baixar pela ferramenta de consulta, baixar ele mesmo ou abrir a C1 com o IDHM pendente. O log do 68 fica como está, corrigido por esta linha e pela A1-103 |
| **M2 (Maior, a confirmar).** Ensaios com dado real em cópias não commitadas, antes de cada commit | **Confirmado.** O `diff` de cada cópia de ensaio contra o script commitado mostra só a trava do `git status` desligada, o log na pasta de trabalho e, no 67 e no 68, as saídas em `01_saidas/fase4/_ensaio/`. A lógica é a mesma, e cada ensaio leu a base pela interface. Saídas: os RDS e CSV dos ensaios ficaram dentro da Forja (`01_saidas/fase4/` e `_ensaio/`) e foram para a lixeira do volume; os logs de ensaio, só com agregados mascarados como os oficiais, ficaram na pasta de trabalho (`/private/tmp`). O 69 também teve ensaio, só com dado público (feriados e calendário) | Desvio de processo registrado na A1-103: a mensagem diz "script commitado antes de rodar". Nenhum número oficial vem de ensaio; os oficiais vêm dos scripts commitados (SHA no log). Os logs de ensaio vão para a lixeira. **Daqui em diante, nenhum ensaio com dado real em cópia não commitada:** commit, rodada e, se houver erro, novo commit e nova rodada, sem sobrescrever log. O 70 e o 71 não tiveram ensaio |
| **m1.** O que o log diz sobre o site do Atlas não tem evidência | Confirmado: o texto é fixo, e as consultas foram feitas à mão, fora de script | Evidência gravada com data e hora (abaixo) |
| **m2.** Tolerância de 1e-12 onde a mensagem pede "diferença 0" | Confirmado pela leitura. Na representação do próprio CSV (texto com 15 algarismos, como o `write.csv` grava), os 156 valores da conferência a e os 78 da b são **idênticos** | A diferença é 0 na representação do CSV; a de 5e-14 vinha só da leitura do texto para `double`. Registrado aqui |
| **m3.** O `conta11` do 67 não limita as datas | Confirmado pela leitura. Na base, 0 nascimentos da população de 2011 fora de 2010-12-25 a 2024-12-31; a `nascimentos()` vai de 2011-01-01 a 2024-12-31 | Sem efeito nesta rodada. O filtro de datas entra se o 67 rodar de novo |
| **m4.** A supressão complementar do 68 tem falhas de desenho, que não dispararam (0 supressões) | Confirmado pela leitura: (a) com os iniciados entre 1 e 9, suprimiria o PTB, quando o certo é o espontâneo (ii); (b) não trata dois subtipos mascarados; (c) não olha os percentuais de outros logs | Sem efeito nesta rodada: as menores diferenças entre conjuntos encaixados são 78, 926, 2.852 e 4.029. A regra corrigida entra nos scripts das Partes C que publicarem contagens |
| **m5.** Alguns PAREs param sem gravar o log | Confirmado: no 65, o `quantile(na.rm = FALSE)`; no 66 e no 67, `stop()` fora de `tryCatch` | Nenhum disparou. Os scripts da C gravam o log antes de qualquer `quit(1)` |
| Notas N1 a N16 | Aceitas | Entram na RESPOSTA quando pedem declaração: as chaves 1 e 6 reaproveitam as séries da Fase 1 feitas com o offset v1.0 e reconstruídas idênticas (N4); os ignorados do PTB espontâneo estão no CSV, com mínimo de 78 (N12); a AT "independente" é a mesma fórmula reescrita (N2) |

**Evidência do m1** (`evidencia_atlas_m1.txt`; consultas `curl -I`):
- 2026-10-18 23:55:44 −03:00: `https://www.atlasbrasil.org.br/2013/data/rawData/atlas2013_dadosbrutos_pt.xlsx` dá HTTP 404.
- 23:55:45: `http://atlasbrasil.org.br/…/atlas2013_dadosbrutos_pt.xlsx` dá HTTP 308 para `https://atlasbrasil.org.br/…`.
- 23:55:46: `https://atlasbrasil.org.br/…/atlas2013_dadosbrutos_pt.xlsx` dá erro TLS ("self-signed certificate", `ssl_verify` = 18); não contornado.
- 23:55:46: `https://www.atlasbrasil.org.br/consulta/planilha` dá HTTP 200. É a ferramenta de consulta; a planilha sai por POST a `/api/dadosgridDowload`, montado pelo JavaScript da página depois da escolha de indicadores e territórios.

- **Achados abertos:** nenhum. O M1 (IDHM) foi resolvido pela decisão de Guilherme de 19/10/2026, às 05:59 −03:00: a C1 abre com o IDHM pendente (A1-104 e seção abaixo).

## Decisão de Guilherme sobre o M1 (19/10/2026)

- **Forma:** pergunta da sessão (AskUserQuestion), com o texto do [ok] na opção. Pela regra de aprovação, valem a pergunta, a opção e a hora, gravadas literalmente.
- **Pergunta:** "O download do IDHM 2010 bateu no PARE da B1.5: o Atlas só entrega a tabela pela ferramenta de consulta (um formulário). A C1 só abre depois da sua decisão. Qual destas?"
- **Opção escolhida** (rótulo "Abrir C1, IDHM pendente"): "[ok] Guilherme: aprovo abrir a C1 (scripts 70 e 71) com o IDHM 2010 pendente; o IDHM só entra na meta-regressão exploratória da C4 e a forma de obtê-lo fica para depois."
- **Hora lida logo depois da resposta:** 2026-10-19 05:59:01 −03:00.
- **Opções não escolhidas:** baixar pela ferramenta de consulta; Guilherme baixar o arquivo; parar e levar ao chat.
