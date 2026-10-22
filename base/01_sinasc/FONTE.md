# FONTE — SINASC (Sistema de Informações sobre Nascidos Vivos)

**Data de acesso à documentação:** 2026-10-01 (America/Sao_Paulo)
**Responsável pela base:** Ministério da Saúde, SVSA/DAENT/CGIAE; disseminação pelo DATASUS.

## 1. Onde baixar

| Item | Endereço |
|---|---|
| Microdados por UF, residência (definitivo) | `ftp://ftp.datasus.gov.br/dissemin/publicos/SINASC/1996_/Dados/DNRES/DN{UF}{AAAA}.dbc` |
| Microdados preliminares | `ftp://ftp.datasus.gov.br/dissemin/publicos/SINASC/PRELIM/DNRES/` |
| Portal de dados abertos (CSV nacional + dicionário) | https://dadosabertos.saude.gov.br/dataset/sistema-de-informacao-sobre-nascidos-vivos-sinasc |
| Dicionário oficial ("SINASC – Estrutura", PDF, atualizado 22/02/2024) | https://diaad.s3.sa-east-1.amazonaws.com/sinasc/SINASC+-+Estrutura.pdf |

Os diretórios do FTP são os mesmos usados no código do CliMaterna que já funcionou (`/dissemin/publicos/SINASC/1996_/Dados/DNRES/`) e pelo pacote microdatasus.

## 2. Versão e período

- O portal de dados abertos, em 2026-10-01, rotula **só** 2025 como "preliminar" (31/08/2026) e 2026 como "1ª prévia" (20/07/2026). O arquivo de 2024 (atualizado em 08/05/2026) aparece sem rótulo; é inferência, não afirmação do portal, que seja definitivo.
- A página de "Dados prévios" da CGIAE ainda dizia que 2024 era preliminar. Por causa dessa divergência, o script tenta primeiro o diretório definitivo e só depois o preliminar, e **grava qual dos dois foi usado** (`_STATUS` no parquet e coluna `status` em `logs/integridade.csv`).
- Período baixado: **2011–2024**, com 14 anos × 27 UFs = **378 arquivos**, **todos do diretório definitivo** (download de 02/10/2026; `logs/integridade.csv`). A análise principal é 2012–2024, e 2011 entra só como sensibilidade (adendo v1.3, E18).

## 3. Como baixar (passo a passo)

O pacote **microdatasus** (Saldanha, Bastos e Barcellos, Cad Saúde Pública 2019;35(9):e00032419, [DOI](https://doi.org/10.1590/0102-311X00032419)) baixa estes mesmos arquivos (`fetch_datasus(information_system = "SINASC", year_start, year_end, uf = "all")`) e rotula as categorias (`process_sinasc()`). Ele, porém, lê o .dbc em memória e não guarda o arquivo original, o que impede checksum da fonte. Por isso a base usa `00_scripts/01_download_sinasc.py`, que segue cinco passos:

1. baixa cada `DN{UF}{AAAA}.dbc` do mesmo FTP e guarda o original intocado em `01_sinasc/dbc/`;
2. calcula o MD5;
3. descomprime (`datasus-dbc`), lê o DBF (`dbfread`) e grava o parquet com **todas as colunas como texto**, sem recodificação;
4. registra linhas, colunas, municípios distintos e % de código de município inválido;
5. registra a completude (% vazio) de cada variável-chave.

Se for preciso rotular as categorias no R, `microdatasus::process_sinasc()` pode ser aplicado depois sobre o parquet.

## 4. Variáveis usadas, conferidas no dicionário oficial E no dado

Os nomes abaixo foram conferidos em duas frentes: no PDF oficial e nos parquets do SINASC 2012 e 2022 já existentes no Forja (só o esquema, sem ler linhas). As categorias seguem o dicionário.

| Variável | Descrição (dicionário) | Observação |
|---|---|---|
| `DTNASC` | Data de nascimento, ddmmaaaa | |
| `PESO` | Peso ao nascer em gramas | |
| `SEMAGESTAC` | Número de semanas de gestação | **Só semanas completas**, sem dias |
| `GESTACAO` | Faixas: 1 <22; 2 22–27; 3 28–31; 4 32–36; 5 37–41; 6 ≥42; 9 ignorado | Formato antigo, útil como fallback |
| `TPMETESTIM` | Método de estimativa da IG: 1 exame físico; 2 outro método; 9 ignorado | **No dado de 2022 aparece o código 8**, que não está no dicionário. Em 2012, 78% vazio. Investigar antes de usar como covariável |
| `SEXO` | 1 M; 2 F; 0 I | Alguns anos usam letras (M/F/I); o 06b normaliza |
| `CODMUNRES` | Código IBGE do município de **residência** | **6 dígitos no dado** (sem o dígito verificador), conferido em 2012 |
| `CODMUNNASC` | Município de nascimento (ocorrência) | **Não usar** para exposição |
| `IDADEMAE` | Idade da mãe | |
| `ESCMAE` | Escolaridade em anos: 1 nenhuma; 2 1–3; 3 4–7; 4 8–11; 5 ≥12; 9 ign. | |
| `ESCMAE2010` | 0 sem escolaridade; 1 Fund. I; 2 Fund. II; 3 Médio; 4 Sup. incompleto; 5 Sup. completo; 9 ign. | Preferir esta |
| `RACACORMAE` | Raça/cor da mãe: 1 branca; 2 preta; 3 amarela; 4 parda; 5 indígena | |
| `RACACOR` | Raça/cor do nascido | |
| `QTDFILVIVO` / `QTDFILMORT` | Nº de filhos vivos / perdas fetais e abortos | |
| `QTDGESTANT` | Nº de gestações anteriores | Base para a paridade |
| `QTDPARTNOR` / `QTDPARTCES` | Nº de partos vaginais / cesáreos anteriores | Paridade = soma das duas |
| `PARIDADE` | 1 multípara; 0 nulípara (gerada pelo sistema) | **Ausente de 2011 a 2013** e presente depois. Não é usada (decisão de 02/10/2026: paridade derivada de `QTDPARTNOR + QTDPARTCES`, com `QTDFILVIVO` como sensibilidade) |
| `CONSULTAS` | Pré-natal em faixas: 1 nenhuma; 2 1–3; 3 4–6; 4 ≥7; 9 ign. | |
| `CONSPRENAT` | Nº de consultas de pré-natal (contínuo) | |
| `MESPRENAT` | Mês de início do pré-natal | |
| `GRAVIDEZ` | 1 única; 2 dupla; 3 tripla+; 9 ign. | PIG só em gestação única |
| `PARTO` | 1 vaginal; 2 cesáreo; 9 ign. | |
| `STTRABPART` | "Trabalho de parto induzido? 1– Sim; 2– Não; 3– Não se aplica; 9– Ignorado" | Com `STCESPARTO`, base para o PTB espontâneo |
| `STCESPARTO` | "Cesárea ocorreu antes do trabalho de parto iniciar? 1– Sim; 2– Não; 3– Não se aplica; 9– Ignorado" | idem |
| `TPAPRESENT` | "Tipo de apresentação do RN. 1– Cefálico; 2– Pélvica ou podálica; 3– Transversa; 9– Ignorado" | covariável |
| `TPROBSON` | Grupo de Robson (gerado pelo sistema) | |
| `IDANOMAL` / `CODANOMAL` | Anomalia (1 sim; 2 não; 9 ign.) / CID-10 da anomalia | |
| `DTULTMENST` | Data da última menstruação | Lida pelo 06b, para derivar a `ig_dum_sem` (IG pela DUM; `09_acesso/DICIONARIO.md`), e pelo `testes/descritivo_ig_dum_sem.py`, só para agregados (motivo do NA). **A data bruta não entra em nenhum arquivo da base** (minimização, desde 08/10/2026). No dado de 2011–2024, nos 277 municípios, vem vazia ou com 8 dígitos (perfil de padrões agregado de 08/10/2026) |

## 5. Endereço e setor censitário: limitação e caminho de acesso restrito

**O SINASC público de 2012–2024 não tem nenhuma variável de endereço** (2011 não verificado). O dicionário atual não traz CEP, logradouro, bairro nem setor censitário; o único nível geográfico é o município (`CODMUNRES`, `CODMUNNASC`).

**Achado histórico:** os .dbc de 2008 e 2009 que estão no Forja ainda trazem `CODBAIRES` (bairro de residência) e `CODBAINASC` (bairro de nascimento). Na amostra de SP 2009, `CODBAIRES` estava preenchido em cerca de 63% dos registros. As duas variáveis não aparecem no esquema de 2012 nem no .dbc de 2023, e o dicionário atual não as menciona. Não servem para o período do estudo, mas mostram que o bairro já foi disseminado; vale citar no pedido de acesso restrito. Isso vai como limitação dos artigos: a exposição é atribuída por município de residência, com erro de classificação não diferencial dentro de municípios grandes.

**Caminho para obter dados com endereço (acesso restrito):**

1. **Ministério da Saúde (federal)**: a **Nota Informativa nº 5/2025-DAENT/SVSA/MS** (datada de 23/09/2025 e assinada eletronicamente em 25/09/2025) define o procedimento para pedir dados identificados, pseudonimizados ou anonimizados do SIM e do SINASC para pesquisa. O pedido vai por e-mail para **ngd@saude.gov.br**, com assinatura digital gov.br, e exige: ofício institucional; projeto; Termo de Compromisso de Uso de Dados; plano de análise com as variáveis; Lattes; comprovante de vínculo; **parecer do CEP**; identidade e CPF. O "Termo de Veracidade do TCLE e Adesão dos Participantes" só é exigido quando o solicitante já tem base própria com dados identificáveis (por exemplo, para linkage). A nota diz que campos pessoais e sensíveis são suprimidos antes da entrega, e não especifica se endereço/CEP é liberado: **é preciso pedir explicitamente CEP ou setor censitário geocodificado e justificar no plano de análise.** Fonte: https://www.gov.br/saude/pt-br/centrais-de-conteudo/publicacoes/estudos-e-notas-informativas/2025/nota-informativa-no-5-2025-daent-svsa-ms.pdf
2. **Secretarias estaduais e municipais de saúde**: são gestoras locais do SINASC e guardam a DNV com endereço. Algumas têm fluxo formal (por exemplo, SES-SC/DIVE, "Bancos de Dados Nominais": https://dive.saude.sc.gov.br/tabnet/solicitacao/index.php). Para as RMs, o pedido seria feito a cada capital/SES, com CEP aprovado. Esse caminho é viável para um subestudo (uma ou duas RMs) e pouco viável para todas.
3. **Recomendação**: manter o desenho municipal nos três artigos e, se quiser refinar a exposição, abrir um pedido único à NGD/SVSA para as cidades-núcleo das 26 concentrações urbanas, com o CEP já aprovado.

## 6. Referência de contagens para conferência

A base antiga do CliMaterna (`/Volumes/Forja/CliMaterna/01_data/raw/SINASC/sinasc_AAAA.parquet`, publicada como Torezzan et al., Data in Brief 2025;62:111920, [DOI](https://doi.org/10.1016/j.dib.2025.111920)) tem estas contagens nacionais de linhas, lidas do metadado:

| Ano | Linhas | | Ano | Linhas |
|---|---:|---|---|---:|
| 2012 | 2,905,789 | | 2019 | 2,849,146 |
| 2013 | 2,904,027 | | 2020 | 2,730,145 |
| 2014 | 2,979,259 | | 2021 | 2,677,101 |
| 2015 | 3,017,668 | | 2022 | 2,561,922 |
| 2016 | 2,857,800 | | 2023 | 2,537,576 |
| 2017 | 2,923,535 | | 2024 | 2,389,325 * |
| 2018 | 2,944,932 | | | |

\* Nota de 01/10, superada: suspeitava-se que o arquivo de 2024 do CliMaterna fosse preliminar. No download de 02/10, o 2024 veio do diretório definitivo, e a diferença contra o CliMaterna foi **0**, no total e em cada UF (`logs/aceite_fase1_uf_ano.csv`). O ano de 2011 (2.913.160 nascidos vivos) também bate.

O `99_relatorio_integridade.py` compara automaticamente o total baixado com essas contagens.
