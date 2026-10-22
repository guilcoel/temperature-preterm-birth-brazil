# RESPOSTA: Artigo 1 (prematuridade), Fase 0, Parte A

- **De:** Claude Code, na Forja. **Para:** chat do Artigo 1. **Data:** 08/10/2026.
- **Base:** `versao()` = `7e99bf94` no início e no fim de cada script. O git da base segue no commit `9f1957b`, sem alteração.
- **Estado:** Parte A concluída (A1 a A7), com uma pendência: o download da `attrdl` (A3.6), que espera o ok de Guilherme. **A Parte B não começou**, e não há nenhum commit no repositório novo.
- **Tabelas completas:** todas vêm dos logs desta fase, incluídas por cópia mecânica (sem redigitar).

## 1. Resumo

- **Totais e contagens fecham.**
  - Os três totais batem exatamente: 13.791.848 NV, 1.405.697 PTB e 180.064 óbitos perinatais.
  - Na janela principal, ninguém fica abaixo de 1.000 eventos.
  - No perinatal, Florianópolis (1.424), Sorocaba (1.464) e Campo Grande (1.884) ficam abaixo de 2.000: 23/26 passam de 2.000.
  - As perdas das janelas principais são 1,97% (PTB) e 2,77% (perinatal), abaixo da simulação da especificação (2,26% e 3,17%).
- **⚑ Duas decisões para o chat de métodos, antes da tag:**
  - **(a) A regra da distribuição semanal (§1.2).** As leituras (i) e (ii) diferem em até 0,298 °C, e 45 dos 130 pares concentração × percentil passam de 0,05 °C. A diferença vem do peso das janelas das pontas do período.
  - **(b) O `DTULTMENST` não está na base.** As opções são uma versão nova da base, que muda a `versao()` dos três artigos, ou deixar fora a sensibilidade de consistência interna da IG (§3.5). Isso não bloqueia a tag (desvio 2).
- **PM2.5 (variante secundária):** Campo Grande, Goiânia e Brasília ficam abaixo de 90% dos dias de modelo utilizáveis (de 87,1% a 88,0%). As outras 23 passam.
- **Ambiente e desvios:** as versões da §8 conferem, e o BLAS é o de referência. Há seis desvios registrados. Nenhum muda a análise principal; o desvio 2 bloqueia a sensibilidade da §3.5.
- **Dupla auditoria:** a autoauditoria por código passou em 48 de 48 conferências, por caminhos independentes da A5. A auditoria independente: nenhum achado crítico; 1 maior, 9 menores e 3 cosméticos, todos reproduzidos por código; 12 corrigidos, e 1 (rastreabilidade do prompt e dos documentos do chat) virou o pedido 4.

**Pedidos a Guilherme:**

1. **Ok para baixar a `attrdl` (A3.6).** URL fixada no commit `e629be7`, 7.411 bytes (§4).
2. **Origem da reinstalação do `gigs`.** Ele foi recompilado hoje às 11:57, a partir do GitHub, no mesmo commit `fb58fe6`, e não achei o comando nesta sessão (desvio 6). Foi você?
3. **O `PROMPT_artigo1_prematuridade_FASE0_20261008.md` não estava em `~/Downloads`.** Por isso ele não está em `logs/_entrada_chat/`. Para a auditoria independente, usei o texto que você colou no chat, extraído literalmente da sessão para uma cópia de trabalho efêmera, fora do projeto (SHA-256 `549ea53a…55b3`). Pode pôr o arquivo em `~/Downloads`?
4. **Para o chat (achado 10 da auditoria):** o prompt e os documentos do chat (`logs/_entrada_chat/`) devem entrar no repositório antes da tag, por exemplo em `logs/chat/`? Hoje ficam fora do git, e os logs citam esses documentos como fonte de decisões (IBGE, desvio 5).

## 2. Item zero

**0.1. Resposta literal de Guilherme** (registro em `logs/confirmacoes_pre_tag.md`, 2026-10-08 14:04):

> Sim, confirmo os dois itens como estão na v2.0.2.

**0.2. Arranjos Populacionais do IBGE: SEM EDIÇÃO NOVA.** É a decisão do chat (`RESPOSTA_chat_A1_auditoria_20261008.md`, §3), e a tag não fica bloqueada pela pendência 7. Detalhe em `logs/checagem_arranjos_ibge_20261008.md`.

- **Nota 1:** não há edição nova da publicação. A página oficial só tem a 2ª edição, de 2016. A "atualização 2021" é uma camada geográfica, sem descrição de mudança de composição.
- **Nota 2:** o Censo 2022 tabula as concentrações com a composição de 2016. Reproduzi pelo SIDRA: 185 concentrações no nível N33, e a população de 2022 das 26 do estudo é idêntica, nas 26, à da base.
- **Nota 3 (para o Methods):** 28 concentrações passam de 750 mil habitantes em 2022. As duas a mais são Ribeirão Preto (861.177) e Jundiaí (843.633). As 26 do estudo são a classificação pré-especificada de 2016; declarar como limitação de generalização e checar de novo na submissão.
- **URLs:**
  - SIDRA: https://apisidra.ibge.gov.br/values/t/4709/n33/all/v/93/p/2022
  - Página oficial: https://www.ibge.gov.br/geociencias/organizacao-do-territorio/divisao-regional/15782-arranjos-populacionais-e-concentracoes-urbanas-do-brasil.html

## 3. Pastas, `.gitignore` e `checa_sigilo.sh`

**Pastas criadas** em `/Volumes/Forja/Doc/artigos_perinatais_clima/`:

- `logs/` (com `_entrada_spec/` e `_entrada_chat/`, fora do git), `spec/` e `ferramentas/`;
- `codigo_compartilhado/` com `R/`, `tests/`, `inst/terceiros/` e um `DESCRIPTION` de esqueleto;
- `artigo1_prematuridade/`, `artigo2_obito_perinatal/` e `artigo3_pig/`, cada um com `00_scripts/`, `01_saidas/`, `logs/`, `tabelas/`, `figuras/`, `manuscrito/` e `Submissao/`, todas com `.gitkeep`.

**Git:** `init -b main`, todo comando com `-C`, `core.fileMode=false`, `core.symlinks=false` e `core.ignorecase=true`. Identidade só no repositório (`Guilherme Coelho`, `guilcoel@unicamp.br`), confirmada por Guilherme.

**`.gitignore` mais restrito que o do prompt** (ajuste 2.3 do chat). O prompt liberava `spec/**`, `ferramentas/**`, `codigo_compartilhado/**` e `00_scripts/**`. A lista atual libera só:

- em `spec/`, `*.md` e `SHA256SUMS`;
- em `ferramentas/`, `*.sh`;
- em `codigo_compartilhado/`, `DESCRIPTION`, `NAMESPACE`, `*.md`, `R/*.R`, `tests/**/*.R` e `inst/terceiros/*.R` e `*.md`;
- em `00_scripts/`, `*.R`, `*.py`, `*.sh` e `*.md`.

Saídas do `git check-ignore -v -n` (de `logs/a1_evidencias_20261008.md`, §3):

**Teste caminho por caminho.** Uma linha `!` na saída quer dizer que o arquivo **entra**; as demais, que fica **fora**.

```
$ git -C <raiz> check-ignore -v -n <28 caminhos que devem entrar>
.gitignore:3:!/.gitignore	.gitignore
.gitignore:4:!/.gitattributes	.gitattributes
.gitignore:5:!/README.md	README.md
.gitignore:6:!/spec/*.md	spec/especificacao_dlnm_canonica_v2_0_2.md
.gitignore:7:!/spec/SHA256SUMS	spec/SHA256SUMS
.gitignore:8:!/logs/*.md	logs/confirmacoes_pre_tag.md
.gitignore:9:!/ferramentas/*.sh	ferramentas/checa_sigilo.sh
.gitignore:10:!/codigo_compartilhado/DESCRIPTION	codigo_compartilhado/DESCRIPTION
.gitignore:11:!/codigo_compartilhado/NAMESPACE	codigo_compartilhado/NAMESPACE
.gitignore:12:!/codigo_compartilhado/*.md	codigo_compartilhado/README.md
.gitignore:13:!/codigo_compartilhado/R/*.R	codigo_compartilhado/R/ajusta_dlnm.R
.gitignore:14:!/codigo_compartilhado/tests/**/*.R	codigo_compartilhado/tests/testthat/test_x.R
.gitignore:15:!/codigo_compartilhado/inst/terceiros/*.R	codigo_compartilhado/inst/terceiros/attrdl.R
.gitignore:16:!/codigo_compartilhado/inst/terceiros/*.md	codigo_compartilhado/inst/terceiros/ORIGEM.md
.gitignore:17:!**/.gitkeep	artigo2_obito_perinatal/00_scripts/.gitkeep
.gitignore:18:!/artigo*/CLAUDE.md	artigo1_prematuridade/CLAUDE.md
.gitignore:19:!/artigo*/RESPOSTA_*.md	artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_20261008.md
.gitignore:20:!/artigo*/.Rprofile	artigo1_prematuridade/.Rprofile
.gitignore:21:!/artigo*/.Renviron	artigo1_prematuridade/.Renviron
.gitignore:22:!/artigo*/renv.lock	artigo1_prematuridade/renv.lock
.gitignore:23:!/artigo*/renv/activate.R	artigo1_prematuridade/renv/activate.R
.gitignore:24:!/artigo*/renv/settings.json	artigo1_prematuridade/renv/settings.json
.gitignore:25:!/artigo*/00_scripts/*.R	artigo1_prematuridade/00_scripts/01_recontagens.R
.gitignore:26:!/artigo*/00_scripts/*.py	artigo1_prematuridade/00_scripts/aux.py
.gitignore:27:!/artigo*/00_scripts/*.sh	artigo1_prematuridade/00_scripts/roda.sh
.gitignore:28:!/artigo*/00_scripts/*.md	artigo1_prematuridade/00_scripts/LEIAME.md
.gitignore:29:!/artigo*/logs/*.md	artigo1_prematuridade/logs/recontagens.md
.gitignore:30:!/artigo*/logs/sessionInfo_*.txt	artigo1_prematuridade/logs/sessionInfo_20261008.txt

$ git -C <raiz> check-ignore -v -n <27 caminhos que devem ficar fora>
.gitignore:1:*	artigo1_prematuridade/00_scripts/x.dbc
.gitignore:1:*	artigo1_prematuridade/00_scripts/x.tsv
.gitignore:1:*	artigo1_prematuridade/00_scripts/x.rds
.gitignore:1:*	artigo1_prematuridade/00_scripts/x.RData
.gitignore:1:*	artigo1_prematuridade/00_scripts/x.feather
.gitignore:1:*	artigo1_prematuridade/00_scripts/X.CSV
.gitignore:1:*	artigo1_prematuridade/00_scripts/x.csv
.gitignore:1:*	artigo1_prematuridade/00_scripts/dump.txt
.gitignore:1:*	artigo1_prematuridade/00_scripts/out.xlsx
.gitignore:1:*	artigo1_prematuridade/00_scripts/x.json
.gitignore:1:*	artigo1_prematuridade/00_scripts/x.parquet
.gitignore:1:*	logs/x.txt
.gitignore:1:*	artigo1_prematuridade/logs/x.txt
.gitignore:31:/artigo*/01_saidas/	artigo1_prematuridade/01_saidas/fase0/nota.md
.gitignore:31:/artigo*/01_saidas/	artigo1_prematuridade/01_saidas/.gitkeep
.gitignore:32:/artigo*/tabelas/	artigo1_prematuridade/tabelas/t.docx
.gitignore:33:/artigo*/figuras/	artigo1_prematuridade/figuras/f.pdf
.gitignore:34:/artigo*/manuscrito/	artigo1_prematuridade/manuscrito/m.docx
.gitignore:35:/artigo*/Submissao/	artigo1_prematuridade/Submissao/c.pdf
.gitignore:36:/artigo*/renv/library/	artigo1_prematuridade/renv/library/R-4.5/dlnm/DESCRIPTION
.gitignore:37:/artigo*/renv/staging/	artigo1_prematuridade/renv/staging/x
.gitignore:38:._*	artigo1_prematuridade/._x.R
.gitignore:39:.DS_Store	.DS_Store
.gitignore:1:*	spec/x.csv
.gitignore:1:*	codigo_compartilhado/inst/dados.json
.gitignore:1:*	ferramentas/x.py
.gitignore:1:*	solto.R
```

**Por que 28 e 27, e não 23 e 24 como no teste do chat.** Não tenho a lista de caminhos do chat, então não dá para fazer a diferença item a item. O critério que usei foi este:

- **Os 28 que entram:** um caminho para cada regra `!` do `.gitignore`, sem contar `!*/`. São 28 regras de liberação, inclusive `NAMESPACE`, `codigo_compartilhado/*.md`, `tests/**/*.R`, `inst/terceiros/*.md`, `.gitkeep` e os `.py`, `.sh` e `.md` de `00_scripts/`.
- **Os 27 que ficam fora:**
  - cada extensão que o chat pediu: `.dbc`, `.tsv`, `.rds`, `.RData`, `.feather` e `.CSV`;
  - `x.csv` e `x.parquet`;
  - os três que o chat reproduziu: `dump.txt`, `out.xlsx` e `x.json`;
  - `logs/x.txt`, na raiz e no artigo;
  - um `.md` e o `.gitkeep` em `01_saidas/`;
  - um arquivo em cada pasta excluída (`tabelas/`, `figuras/`, `manuscrito/`, `Submissao/`, `renv/library/` e `renv/staging/`);
  - `._x.R` e `.DS_Store`;
  - quatro casos de borda: `spec/x.csv`, `codigo_compartilhado/inst/dados.json`, `ferramentas/x.py` e um `solto.R` na raiz.

**`checa_sigilo.sh` e hook.** O hook é `.git/hooks/pre-commit`, com `exec sh ferramentas/checa_sigilo.sh`, sem link simbólico e com permissão `-rwx`. O script lê o índice com `--diff-filter=ACMR`, barra 21 extensões de dado sem diferenciar maiúsculas e blobs acima de 5 MB, e tem uma exceção só, para `^artigo[^/]*/renv/settings\.json$`. Conteúdo integral e saída bruta em `logs/a1_evidencias_20261008.md`, §4 a §6. Resultado dos testes:

| Caso | Script (`sh`) | `git commit` |
|---|---|---|
| 0. Índice vazio | 0 | 1: "nothing added to commit". O hook rodou antes e deu ok; nenhum commit |
| 1. `.csv` fictício | 1 | 1 |
| 2. Arquivo de 6 MB | 1 | 1 |
| 3. `.json` qualquer | 1 | 1 |
| 4. `artigo1_prematuridade/renv/settings.json` | 0 | não rodado; o hook direto (`sh .git/hooks/pre-commit`) deu 0 |
| 5. `x/renv/settings.json` (negativo) | 1 | 1 |
| 6. `artigo1_prematuridade/00_scripts/settings.json` (negativo) | 1 | 1 |

## 4. Ambiente

De `artigo1_prematuridade/logs/ambiente_fase0_20261008.md` (gerado por `00_scripts/00_ambiente.R`):

| Pacote | Versão esperada (§8) | Versão encontrada | Confere | Compilado em |
|---|---|---|---|---|
| R | 4.5.1 | 4.5.1 | sim | — |
| dlnm | 2.4.10 | 2.4.10 | sim | R 4.5.0 |
| gnm | 1.1.5 | 1.1.5 | sim | R 4.5.0 |
| mixmeta | 1.2.0 | 1.2.0 | sim | R 4.5.0 |
| mvmeta | 1.0.3 | 1.0.3 | sim | R 4.5.0 |
| renv | 1.2.4 | 1.2.4 | sim | R 4.5.2 |
| gigs | 0.5.2.9000 | 0.5.2.9000 | sim | R 4.5.1 |
| arrow | 21.0.0.1 | 21.0.0.1 | sim | R 4.5.0 |
| tsModel | — | 0.6.2 | — | R 4.5.0 |
| dplyr | — | 1.2.1 | — | R 4.5.2 |
| jsonlite | — | 2.0.0 | — | R 4.5.0 |
| splines | — | 4.5.1 | — | R 4.5.1 |
| tools | — | 4.5.1 | — | R 4.5.1 |

- **`gigs` RemoteSha:** `fb58fe6596d4b289d5362c5efe00f882984d3186` (confere com `fb58fe6596d4b289d5362c5efe00f882984d3186`: sim).
- **BLAS:** `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` (BLAS de referência do R: sim).
- **LAPACK:** `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib`, versão 3.12.1.
- **Dependências do `acesso.R` (`renv::dependencies`):** arrow, dplyr, jsonlite, tools.

`versao()` no fim: 7e99bf94.

Saídas brutas do `gh` e do `renv`, com os horários: `artigo1_prematuridade/logs/renv_fase0_20261008.md`.

- **`gh auth status`:** primeiro comando da A3, às 14:32. Logado como `guilcoel`; o token não foi impresso.
- **`renv`:**
  - `renv::init(bare = TRUE)`;
  - `renv::hydrate()` com os repositórios apontados para um endereço falso, para não baixar nada; copiou 39 pacotes;
  - `renv::snapshot()`.
  - O `renv.lock` tem 40 pacotes (os 39 mais o próprio `renv`) e R 4.5.1. A biblioteca do projeto tem 4,3 GB e 0 links, porque os pacotes são copiados (desvio 1).
- **`.Renviron`:** só `RENV_CONFIG_CACHE_SYMLINKS=FALSE`. Nenhum token.
- **Binários compilados em R mais novo que o 4.5.1:** `dplyr` 1.2.1 e `renv` 1.2.4, em R 4.5.2. O R avisa ao carregar o `dplyr`. A §8 não fixa o R de compilação desses pacotes; fica só registrado.
- **`gigs`:** versão e `RemoteSha` conferem, mas o binário foi recompilado hoje, da fonte do GitHub, em R 4.5.1. A §8 descreve o binário do r-universe compilado em R 4.5.3 (desvio 6).
- **`tsModel`:** 0.6.2, já instalado e travado no `renv.lock` (A3.3).
- **Dependências do `acesso.R`:** arrow, dplyr, jsonlite e tools. As três primeiras estão no `renv.lock`; o `tools` é pacote base do R.
- **`attrdl` (A3.6): download pendente do ok de Guilherme.** Só consultei os metadados pela API do GitHub, sem baixar o conteúdo (`artigo1_prematuridade/logs/attrdl_consulta_20261008.md`):
  - **Commit:** `e629be7809853f390d305d8e73ac4b152a54f092`, de 2022-04-02, o último que mexeu no arquivo ("Fix issue in attrdl with clogit").
  - **URL:** `https://raw.githubusercontent.com/gasparrini/2014_gasparrini_BMCmrm_Rcodedata/e629be7809853f390d305d8e73ac4b152a54f092/attrdl.R`
  - **Tamanho:** 7.411 bytes. SHA-1 do blob no git: `bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a`.
  - **SHA-256:** só depois do download, em `logs/attrdl_origem.md`, junto com a conferência do `git hash-object` contra o SHA-1 do blob.

## 5. Interface (A4)

De `artigo1_prematuridade/logs/interface_fase0_20261008.md` (gerado por `00_scripts/01_interface.R`, só pelo esquema do `manifesto.json`):

| Função | Arquivo | Coluna | Presente | Tipo | Nota |
|---|---|---|---|---|---|
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `recorte_principal` | sim | `large_string` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `data` | sim | `date32[day]` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `nv_unicos` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb_extremo` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb_muito` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb_moderado_tardio` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `obito_perinatal` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `tmean_nucleo` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `tmean_rm_nv` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `rh_nucleo` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `pm25_local_nucleo` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `pm25_local_zero_na_nucleo` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `dia_semana` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `feriado_nacional` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `carnaval` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `quarta_cinzas` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `sexta_paixao` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `corpus_christi` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `nv_termo_precoce` | não | `—` | termo precoce / NV por semana: nomes procurados |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb_37_38` | não | `—` | termo precoce / NV por semana: nomes procurados |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `nv_semana` | não | `—` | termo precoce / NV por semana: nomes procurados |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `CD_MUN6` | sim | `large_string` |  |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `data` | sim | `date32[day]` |  |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `ptb` | sim | `int32` |  |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `tmean_mun` | sim | `double` |  |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `tmean_nucleo` | sim | `double` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `recorte_principal` | sim | `large_string` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `data` | sim | `date32[day]` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `semana` | sim | `int16` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `z_nv` | sim | `int32` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `z_fetal` | sim | `int32` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `CD_MUN6` | sim | `large_string` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `data` | sim | `date32[day]` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `semana` | sim | `int16` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `z_nv` | sim | `int32` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `z_fetal` | sim | `int32` |  |
| `expo_semanal("tmean", "nucleo")` | `expo_semanal_tmean_nucleo.parquet` | `recorte_principal` | sim | `large_string` |  |
| `expo_semanal("tmean", "nucleo")` | `expo_semanal_tmean_nucleo.parquet` | `dum_est` | sim | `date32[day]` |  |
| `nascimentos()` | `nascimentos.parquet` | `STTRABPART` | não | `—` |  |
| `nascimentos()` | `nascimentos.parquet` | `sttrabpart` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `stcesparto` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `stcesparto_aj` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `PARTO` | não | `—` |  |
| `nascimentos()` | `nascimentos.parquet` | `parto` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `DTULTMENST` | não | `—` |  |
| `nascimentos()` | `nascimentos.parquet` | `TPMETESTIM` | não | `—` |  |
| `nascimentos()` | `nascimentos.parquet` | `metodo_ig` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `gestacao_cat` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `ga_sem` | sim | `int16` |  |
| `nascimentos()` | `nascimentos.parquet` | `dum_est` | sim | `date32[day]` |  |
| `nascimentos()` | `nascimentos.parquet` | `CD_MUN6` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `data` | sim | `date32[day]` |  |
| `nascimentos()` | `nascimentos.parquet` | `unico` | sim | `bool` |  |
| `nascimentos()` | `nascimentos.parquet` | `coorte_fixa_22` | sim | `bool` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `data` | sim | `date32[day]` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `dia_semana` | sim | `int32` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `feriado_nacional` | sim | `int64` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `carnaval` | sim | `int64` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `quarta_cinzas` | sim | `int64` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `sexta_paixao` | sim | `int64` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `corpus_christi` | sim | `int64` |  |
| `expo_semanal("tmean", "nucleo")` | `expo_semanal_tmean_nucleo.parquet` | `s01 … s37` | sim (37 de 37) | `double` |  |

**Referências públicas:** 277 municípios em 26 concentrações, com um núcleo por concentração.

**Códigos para o PTB espontâneo (itens (a)–(g) do chat).** As linhas do código da base estão transcritas no log gerado. A leitura, escrita à mão, está em `artigo1_prematuridade/logs/interface_conclusoes_fase0_20261008.md`:

| Item | Pergunta | Resposta | Fonte |
|---|---|---|---|
| (a) | `sttrabpart` e `parto` guardam os valores brutos 1/2/9, sem rótulo nem fator? | **Sim.** São cópias diretas das colunas do DBF (`.alias`), sem recodificação. Valores observados: `sttrabpart` 1, 2, 9 e vazio; `parto` 1, 2, 9 e vazio | 06b, linha 206; DICIONARIO; RESPOSTA Q2a e Q2c |
| (b) | Inteiros ou texto? | **Texto** (`large_string`), assim como `stcesparto`, `stcesparto_aj`, `metodo_ig` e `gestacao_cat`. Compare com `"1"`, não com `1` | manifesto.json |
| (c) | Como aparece o vazio? | **NA (nulo), nunca "".** O conversor tira os espaços e grava o branco como `None` | utils.py, linha 194; 06b, linha 161 (`is_null()`) |
| (d) | `stcesparto_aj` só difere do bruto em 2014–2015, no parto vaginal? | **Sim.** Por construção, ele só muda quando `PARTO` = "1" e `STCESPARTO` é nulo. Na contagem registro a registro (Q2b), as diferenças são 540.212 em 2014, 574.491 em 2015 e 0 nos outros anos | 06b, linha 161; RESPOSTA Q2b |
| (e) | `metodo_ig` guarda os códigos brutos do `TPMETESTIM`, inclusive o 8 e o branco? | **Sim.** É cópia direta (`.alias`). Códigos observados: 1, 2, 8 (de 2013 em diante), 9 e vazio (NA). O 8 não está no dicionário de 12/2019 | 06b, linha 197; RESPOSTA Q2d |
| (f) | `ga_sem` é o `SEMAGESTAC` limpo e é a IG que define `ptb`? | **Sim.** `SEMAGESTAC` sem espaços, convertido para inteiro, válido de 22 a 44 e NA fora disso (9 e 99 viram NA). `ptb` = `pop_ptb` e `ga_sem` ≤ 36, com `pop_ptb` = `unico` e `ga_sem` de 22 a 42 | 06b, linhas 142–143, 166 e 169 |
| (g) | `unico` equivale a `GRAVIDEZ = 1`? | **Sim.** `unico` = (`GRAVIDEZ` == "1"), com NA tratado como FALSE | 06b, linha 144 |

- **PTB espontâneo (§3.4):** códigos confirmados. A série é montada no artigo, sem versão nova da base.
- **Consistência interna da IG (§3.5):** bloqueada pelo `DTULTMENST` (desvio 2; decisão ⚑ (b)).
- **Calendário e termo precoce:** desvios 3 e 4.

## 6. Recontagens e percentis (A5)

De `artigo1_prematuridade/logs/recontagens_fase0_20261008.md` (gerado por `00_scripts/02_recontagens_fase0.R`). Os CSV completos estão em `artigo1_prematuridade/01_saidas/fase0/`, fora do git.

- **Linha vermelha:** nenhum desfecho cruzado com exposição. As contagens leem só colunas de desfecho; os percentis, só colunas de exposição.
- **Sigilo:** só agregados por concentração × janela inteira. Nenhuma contagem de 1 a 9 apareceu, então não houve máscara nem supressão complementar.

### A5.1 Totais conhecidos (série com coorte fixa, 2012-01-01 a 2024-12-31, 26 concentrações)

| Coluna | Soma | Esperado | Confere | Dias com NA | Datas com NA |
|---|---|---|---|---|---|
| nv_unicos | 13.791.848 | 13.791.848 | sim | 0 | — |
| ptb | 1.405.697 | 1.405.697 | sim | 0 | — |
| obito_perinatal | 180.064 | 180.064 | sim | 7 | 2024-12-25 a 2024-12-31 |

As somas usam `na.rm = TRUE`. Os dias com NA são os da censura neonatal de dezembro de 2024, só no `obito_perinatal`.

### A5.2 Eventos por concentração nas janelas

- **Dias com valor do desfecho:** dias da janela sem NA na coluna do desfecho, não dias de modelo.
- **Janela de evento possível do perinatal:** a especificação (§3.2) usa só os dias com Z_t > 0. Essa restrição entra no modelo, na Fase 2, e não está aplicada aqui. Por construção da coorte fixa, não se espera evento em dia com Z_t = 0; a Fase 2 confere.

#### obito_perinatal, janela evento possível (2012-01-04 a 2024-12-24; 4739 dias)

| Concentração | Total 2012–2024 | Na janela | Perda | Perda % | Dias com valor do desfecho |
|---|---|---|---|---|---|
| São Paulo/SP | 39.575 | 39.575 | 0 | 0,00 | 4739/4739 |
| Rio de Janeiro/RJ | 29.074 | 29.074 | 0 | 0,00 | 4739/4739 |
| Salvador/BA | 10.003 | 10.003 | 0 | 0,00 | 4739/4739 |
| Belo Horizonte/MG | 9.750 | 9.750 | 0 | 0,00 | 4739/4739 |
| Brasília/DF | 8.651 | 8.651 | 0 | 0,00 | 4739/4739 |
| Recife/PE | 8.273 | 8.273 | 0 | 0,00 | 4739/4739 |
| Fortaleza/CE | 7.335 | 7.335 | 0 | 0,00 | 4739/4739 |
| Manaus | 7.136 | 7.136 | 0 | 0,00 | 4739/4739 |
| Porto Alegre/RS | 6.116 | 6.116 | 0 | 0,00 | 4739/4739 |
| Curitiba/PR | 5.531 | 5.531 | 0 | 0,00 | 4739/4739 |
| Belém/PA | 5.398 | 5.398 | 0 | 0,00 | 4739/4739 |
| Goiânia/GO | 5.211 | 5.211 | 0 | 0,00 | 4739/4739 |
| São Luís/MA | 4.066 | 4.066 | 0 | 0,00 | 4739/4739 |
| Vitória/ES | 3.806 | 3.806 | 0 | 0,00 | 4739/4739 |
| Baixada Santista/SP | 3.305 | 3.305 | 0 | 0,00 | 4739/4739 |
| Aracaju/SE | 3.080 | 3.080 | 0 | 0,00 | 4739/4739 |
| Maceió/AL | 3.007 | 3.007 | 0 | 0,00 | 4739/4739 |
| João Pessoa/PB | 2.814 | 2.814 | 0 | 0,00 | 4739/4739 |
| Campinas/SP | 2.747 | 2.747 | 0 | 0,00 | 4739/4739 |
| Teresina/PI | 2.746 | 2.746 | 0 | 0,00 | 4739/4739 |
| Natal/RN | 2.716 | 2.716 | 0 | 0,00 | 4739/4739 |
| Cuiabá/MT | 2.412 | 2.412 | 0 | 0,00 | 4739/4739 |
| São José dos Campos/SP | 2.408 | 2.408 | 0 | 0,00 | 4739/4739 |
| Campo Grande | 1.935 | 1.935 | 0 | 0,00 | 4739/4739 |
| Sorocaba/SP | 1.504 | 1.504 | 0 | 0,00 | 4739/4739 |
| Florianópolis/SC | 1.465 | 1.465 | 0 | 0,00 | 4739/4739 |

#### obito_perinatal, janela principal (2012-05-26 a 2024-08-06; 4456 dias)

| Concentração | Total 2012–2024 | Na janela | Perda | Perda % | Dias com valor do desfecho |
|---|---|---|---|---|---|
| São Paulo/SP | 39.575 | 38.421 | 1.154 | 2,92 | 4456/4456 |
| Rio de Janeiro/RJ | 29.074 | 28.286 | 788 | 2,71 | 4456/4456 |
| Salvador/BA | 10.003 | 9.723 | 280 | 2,80 | 4456/4456 |
| Belo Horizonte/MG | 9.750 | 9.491 | 259 | 2,66 | 4456/4456 |
| Brasília/DF | 8.651 | 8.431 | 220 | 2,54 | 4456/4456 |
| Recife/PE | 8.273 | 8.049 | 224 | 2,71 | 4456/4456 |
| Fortaleza/CE | 7.335 | 7.142 | 193 | 2,63 | 4456/4456 |
| Manaus | 7.136 | 6.925 | 211 | 2,96 | 4456/4456 |
| Porto Alegre/RS | 6.116 | 5.938 | 178 | 2,91 | 4456/4456 |
| Curitiba/PR | 5.531 | 5.364 | 167 | 3,02 | 4456/4456 |
| Belém/PA | 5.398 | 5.254 | 144 | 2,67 | 4456/4456 |
| Goiânia/GO | 5.211 | 5.068 | 143 | 2,74 | 4456/4456 |
| São Luís/MA | 4.066 | 3.970 | 96 | 2,36 | 4456/4456 |
| Vitória/ES | 3.806 | 3.697 | 109 | 2,86 | 4456/4456 |
| Baixada Santista/SP | 3.305 | 3.218 | 87 | 2,63 | 4456/4456 |
| Aracaju/SE | 3.080 | 2.981 | 99 | 3,21 | 4456/4456 |
| Maceió/AL | 3.007 | 2.921 | 86 | 2,86 | 4456/4456 |
| João Pessoa/PB | 2.814 | 2.722 | 92 | 3,27 | 4456/4456 |
| Campinas/SP | 2.747 | 2.669 | 78 | 2,84 | 4456/4456 |
| Teresina/PI | 2.746 | 2.704 | 42 | 1,53 | 4456/4456 |
| Natal/RN | 2.716 | 2.637 | 79 | 2,91 | 4456/4456 |
| Cuiabá/MT | 2.412 | 2.342 | 70 | 2,90 | 4456/4456 |
| São José dos Campos/SP | 2.408 | 2.344 | 64 | 2,66 | 4456/4456 |
| Campo Grande | 1.935 | 1.884 | 51 | 2,64 | 4456/4456 |
| Sorocaba/SP | 1.504 | 1.464 | 40 | 2,66 | 4456/4456 |
| Florianópolis/SC | 1.465 | 1.424 | 41 | 2,80 | 4456/4456 |

#### ptb, janela evento possível (2012-01-04 a 2024-11-15; 4700 dias)

| Concentração | Total 2012–2024 | Na janela | Perda | Perda % | Dias com valor do desfecho |
|---|---|---|---|---|---|
| São Paulo/SP | 341.498 | 341.498 | 0 | 0,00 | 4700/4700 |
| Rio de Janeiro/RJ | 186.425 | 186.425 | 0 | 0,00 | 4700/4700 |
| Belo Horizonte/MG | 76.178 | 76.178 | 0 | 0,00 | 4700/4700 |
| Brasília/DF | 69.528 | 69.528 | 0 | 0,00 | 4700/4700 |
| Recife/PE | 67.692 | 67.692 | 0 | 0,00 | 4700/4700 |
| Fortaleza/CE | 63.755 | 63.755 | 0 | 0,00 | 4700/4700 |
| Porto Alegre/RS | 59.816 | 59.816 | 0 | 0,00 | 4700/4700 |
| Salvador/BA | 50.715 | 50.715 | 0 | 0,00 | 4700/4700 |
| Curitiba/PR | 46.849 | 46.849 | 0 | 0,00 | 4700/4700 |
| Manaus | 46.561 | 46.561 | 0 | 0,00 | 4700/4700 |
| Goiânia/GO | 43.134 | 43.134 | 0 | 0,00 | 4700/4700 |
| Belém/PA | 42.298 | 42.298 | 0 | 0,00 | 4700/4700 |
| Campinas/SP | 34.060 | 34.060 | 0 | 0,00 | 4700/4700 |
| São Luís/MA | 29.709 | 29.709 | 0 | 0,00 | 4700/4700 |
| Vitória/ES | 27.730 | 27.730 | 0 | 0,00 | 4700/4700 |
| São José dos Campos/SP | 26.851 | 26.851 | 0 | 0,00 | 4700/4700 |
| Natal/RN | 26.181 | 26.181 | 0 | 0,00 | 4700/4700 |
| Baixada Santista/SP | 26.012 | 26.012 | 0 | 0,00 | 4700/4700 |
| Maceió/AL | 22.986 | 22.986 | 0 | 0,00 | 4700/4700 |
| Teresina/PI | 20.496 | 20.496 | 0 | 0,00 | 4700/4700 |
| João Pessoa/PB | 19.948 | 19.948 | 0 | 0,00 | 4700/4700 |
| Cuiabá/MT | 17.328 | 17.328 | 0 | 0,00 | 4700/4700 |
| Aracaju/SE | 16.960 | 16.960 | 0 | 0,00 | 4700/4700 |
| Campo Grande | 15.043 | 15.043 | 0 | 0,00 | 4700/4700 |
| Florianópolis/SC | 14.256 | 14.256 | 0 | 0,00 | 4700/4700 |
| Sorocaba/SP | 13.688 | 13.688 | 0 | 0,00 | 4700/4700 |

#### ptb, janela principal (2012-04-14 a 2024-08-06; 4498 dias)

| Concentração | Total 2012–2024 | Na janela | Perda | Perda % | Dias com valor do desfecho |
|---|---|---|---|---|---|
| São Paulo/SP | 341.498 | 335.025 | 6.473 | 1,90 | 4498/4498 |
| Rio de Janeiro/RJ | 186.425 | 182.818 | 3.607 | 1,93 | 4498/4498 |
| Belo Horizonte/MG | 76.178 | 74.772 | 1.406 | 1,85 | 4498/4498 |
| Brasília/DF | 69.528 | 68.110 | 1.418 | 2,04 | 4498/4498 |
| Recife/PE | 67.692 | 66.373 | 1.319 | 1,95 | 4498/4498 |
| Fortaleza/CE | 63.755 | 62.530 | 1.225 | 1,92 | 4498/4498 |
| Porto Alegre/RS | 59.816 | 58.605 | 1.211 | 2,02 | 4498/4498 |
| Salvador/BA | 50.715 | 49.778 | 937 | 1,85 | 4498/4498 |
| Curitiba/PR | 46.849 | 45.773 | 1.076 | 2,30 | 4498/4498 |
| Manaus | 46.561 | 45.564 | 997 | 2,14 | 4498/4498 |
| Goiânia/GO | 43.134 | 42.244 | 890 | 2,06 | 4498/4498 |
| Belém/PA | 42.298 | 41.518 | 780 | 1,84 | 4498/4498 |
| Campinas/SP | 34.060 | 33.354 | 706 | 2,07 | 4498/4498 |
| São Luís/MA | 29.709 | 29.093 | 616 | 2,07 | 4498/4498 |
| Vitória/ES | 27.730 | 27.150 | 580 | 2,09 | 4498/4498 |
| São José dos Campos/SP | 26.851 | 26.377 | 474 | 1,77 | 4498/4498 |
| Natal/RN | 26.181 | 25.665 | 516 | 1,97 | 4498/4498 |
| Baixada Santista/SP | 26.012 | 25.520 | 492 | 1,89 | 4498/4498 |
| Maceió/AL | 22.986 | 22.492 | 494 | 2,15 | 4498/4498 |
| Teresina/PI | 20.496 | 20.111 | 385 | 1,88 | 4498/4498 |
| João Pessoa/PB | 19.948 | 19.500 | 448 | 2,25 | 4498/4498 |
| Cuiabá/MT | 17.328 | 16.986 | 342 | 1,97 | 4498/4498 |
| Aracaju/SE | 16.960 | 16.618 | 342 | 2,02 | 4498/4498 |
| Campo Grande | 15.043 | 14.718 | 325 | 2,16 | 4498/4498 |
| Florianópolis/SC | 14.256 | 13.943 | 313 | 2,20 | 4498/4498 |
| Sorocaba/SP | 13.688 | 13.393 | 295 | 2,16 | 4498/4498 |

#### Resumo da A5.2

| Desfecho | Janela | Total | Na janela | Perda | Perda % | Mínimo | < 1.000 | < 2.000 |
|---|---|---|---|---|---|---|---|---|
| obito_perinatal | evento possível | 180.064 | 180.064 | 0 | 0,00 | 1.465 (Florianópolis/SC) | nenhuma | Sorocaba/SP, Florianópolis/SC, Campo Grande |
| obito_perinatal | principal | 180.064 | 175.069 | 4.995 | 2,77 | 1.424 (Florianópolis/SC) | nenhuma | Sorocaba/SP, Florianópolis/SC, Campo Grande |
| ptb | evento possível | 1.405.697 | 1.405.697 | 0 | 0,00 | 13.688 (Sorocaba/SP) | nenhuma | nenhuma |
| ptb | principal | 1.405.697 | 1.378.030 | 27.667 | 1,97 | 13.393 (Sorocaba/SP) | nenhuma | nenhuma |

- **PTB fora da janela de evento possível** (antes de 2012-01-04 ou depois de 2024-11-15), em 2012–2024: 0.
- **Referência da especificação (§5 e 3ª auditoria, por simulação com concepções uniformes):** perda de cerca de 2,3% no PTB (2,26%) e 3,2% no perinatal (3,17%); perinatal na janela principal com Florianópolis em cerca de 1.418–1.420, Sorocaba 1.456 e Campo Grande 1.874.

### A5.3 Percentis da `tmean_nucleo` diária (°C; `quantile(type = 7)`)

#### ano inteiro 2012–2024 (4749 dias por concentração)

| Concentração | Dias | Sem valor | Média | Mín. | Máx. | p1 | p2,5 | p5 | p10 | p25 | p50 | p75 | p90 | p95 | p97,5 | p99 | p99 − p1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Manaus | 4749 | 0 | 28,22 | 22,70 | 33,31 | 24,91 | 25,41 | 25,89 | 26,46 | 27,36 | 28,24 | 29,09 | 29,96 | 30,49 | 31,02 | 31,66 | 6,75 |
| Belém/PA | 4749 | 0 | 28,21 | 23,77 | 30,74 | 25,47 | 26,19 | 26,65 | 27,12 | 27,76 | 28,29 | 28,78 | 29,18 | 29,45 | 29,68 | 29,97 | 4,50 |
| São Luís/MA | 4749 | 0 | 28,15 | 23,71 | 31,00 | 25,03 | 25,63 | 26,20 | 26,73 | 27,51 | 28,20 | 28,95 | 29,49 | 29,77 | 30,01 | 30,25 | 5,22 |
| Teresina/PI | 4749 | 0 | 28,52 | 24,07 | 33,06 | 25,39 | 25,93 | 26,42 | 26,82 | 27,45 | 28,22 | 29,61 | 30,82 | 31,24 | 31,56 | 31,91 | 6,52 |
| Fortaleza/CE | 4749 | 0 | 28,04 | 23,89 | 31,78 | 25,41 | 25,94 | 26,39 | 26,80 | 27,42 | 28,03 | 28,69 | 29,27 | 29,63 | 29,97 | 30,48 | 5,07 |
| Natal/RN | 4749 | 0 | 27,05 | 22,85 | 30,18 | 24,18 | 24,66 | 25,00 | 25,32 | 26,06 | 27,21 | 28,00 | 28,57 | 28,86 | 29,10 | 29,35 | 5,17 |
| João Pessoa/PB | 4749 | 0 | 27,09 | 22,20 | 30,51 | 23,88 | 24,31 | 24,72 | 25,14 | 26,06 | 27,30 | 28,17 | 28,76 | 29,07 | 29,33 | 29,57 | 5,68 |
| Recife/PE | 4749 | 0 | 26,40 | 22,00 | 30,27 | 23,19 | 23,53 | 23,88 | 24,32 | 25,29 | 26,47 | 27,53 | 28,38 | 28,82 | 29,12 | 29,41 | 6,22 |
| Maceió/AL | 4749 | 0 | 26,26 | 22,03 | 30,55 | 23,27 | 23,64 | 23,92 | 24,33 | 25,15 | 26,41 | 27,34 | 27,96 | 28,34 | 28,72 | 29,10 | 5,83 |
| Aracaju/SE | 4749 | 0 | 27,00 | 22,68 | 31,51 | 23,86 | 24,26 | 24,60 | 25,04 | 25,97 | 27,14 | 28,07 | 28,69 | 29,05 | 29,37 | 29,92 | 6,05 |
| Salvador/BA | 4749 | 0 | 26,29 | 21,39 | 30,95 | 22,65 | 23,05 | 23,49 | 23,99 | 24,93 | 26,36 | 27,65 | 28,47 | 28,93 | 29,26 | 29,73 | 7,09 |
| Belo Horizonte/MG | 4749 | 0 | 22,80 | 12,43 | 31,30 | 16,90 | 17,75 | 18,49 | 19,42 | 21,03 | 22,98 | 24,68 | 25,83 | 26,60 | 27,26 | 28,27 | 11,37 |
| Vitória/ES | 4749 | 0 | 25,16 | 17,72 | 31,40 | 19,66 | 20,29 | 20,91 | 21,71 | 23,16 | 25,28 | 27,23 | 28,43 | 28,97 | 29,42 | 29,97 | 10,31 |
| Rio de Janeiro/RJ | 4749 | 0 | 24,28 | 14,89 | 33,47 | 17,49 | 18,37 | 19,10 | 20,12 | 21,97 | 24,18 | 26,69 | 28,65 | 29,59 | 30,27 | 30,99 | 13,51 |
| Campinas/SP | 4749 | 0 | 22,14 | 8,86 | 30,45 | 13,66 | 15,23 | 16,60 | 17,87 | 19,81 | 22,46 | 24,72 | 26,06 | 26,72 | 27,26 | 27,97 | 14,30 |
| Baixada Santista/SP | 4749 | 0 | 23,07 | 9,88 | 32,68 | 15,26 | 16,64 | 17,52 | 18,74 | 20,73 | 23,13 | 25,49 | 27,47 | 28,41 | 29,07 | 29,78 | 14,51 |
| São José dos Campos/SP | 4749 | 0 | 21,11 | 9,63 | 28,51 | 13,18 | 14,67 | 15,80 | 16,92 | 18,70 | 21,53 | 23,66 | 24,92 | 25,51 | 26,04 | 26,49 | 13,30 |
| São Paulo/SP | 4749 | 0 | 21,16 | 6,86 | 30,18 | 12,58 | 14,16 | 15,15 | 16,59 | 18,79 | 21,33 | 23,85 | 25,48 | 26,27 | 26,89 | 27,64 | 15,06 |
| Sorocaba/SP | 4749 | 0 | 22,10 | 8,38 | 31,05 | 13,31 | 14,89 | 16,38 | 17,72 | 19,68 | 22,44 | 24,73 | 26,18 | 26,96 | 27,65 | 28,34 | 15,02 |
| Curitiba/PR | 4749 | 0 | 19,07 | 3,22 | 27,98 | 8,99 | 10,77 | 12,25 | 13,78 | 16,43 | 19,28 | 22,14 | 24,02 | 24,85 | 25,57 | 26,32 | 17,34 |
| Florianópolis/SC | 4749 | 0 | 21,59 | 8,69 | 32,56 | 12,55 | 13,88 | 14,92 | 16,54 | 18,97 | 21,80 | 24,45 | 26,39 | 27,36 | 28,08 | 28,86 | 16,31 |
| Porto Alegre/RS | 4749 | 0 | 20,95 | 6,83 | 33,54 | 9,48 | 10,96 | 12,28 | 14,12 | 17,66 | 21,40 | 24,61 | 26,94 | 28,12 | 29,19 | 30,21 | 20,73 |
| Campo Grande | 4749 | 0 | 24,57 | 7,98 | 32,58 | 12,60 | 15,05 | 17,41 | 19,88 | 22,98 | 25,33 | 26,98 | 28,19 | 28,93 | 29,56 | 30,53 | 17,93 |
| Cuiabá/MT | 4749 | 0 | 26,88 | 11,32 | 34,71 | 17,23 | 19,40 | 21,61 | 23,99 | 25,74 | 27,15 | 28,46 | 29,75 | 30,71 | 31,59 | 32,29 | 15,07 |
| Goiânia/GO | 4749 | 0 | 25,05 | 13,69 | 32,30 | 19,88 | 20,84 | 21,53 | 22,25 | 23,61 | 25,19 | 26,43 | 27,63 | 28,55 | 29,28 | 30,07 | 10,19 |
| Brasília/DF | 4749 | 0 | 22,79 | 12,37 | 29,17 | 18,13 | 18,84 | 19,39 | 20,14 | 21,48 | 22,97 | 24,07 | 25,15 | 25,99 | 26,68 | 27,28 | 9,16 |

#### novembro a março (1967 dias por concentração)

| Concentração | Dias | Sem valor | Média | Mín. | Máx. | p1 | p2,5 | p5 | p10 | p25 | p50 | p75 | p90 | p95 | p97,5 | p99 | p99 − p1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Manaus | 1967 | 0 | 27,86 | 23,99 | 32,04 | 24,73 | 25,03 | 25,47 | 26,09 | 26,99 | 27,86 | 28,78 | 29,56 | 30,08 | 30,48 | 30,91 | 6,18 |
| Belém/PA | 1967 | 0 | 28,00 | 23,77 | 30,74 | 25,09 | 25,56 | 26,17 | 26,67 | 27,43 | 28,15 | 28,72 | 29,13 | 29,37 | 29,67 | 29,92 | 4,83 |
| São Luís/MA | 1967 | 0 | 28,13 | 23,72 | 30,96 | 24,72 | 25,19 | 25,64 | 26,31 | 27,21 | 28,30 | 29,20 | 29,73 | 29,99 | 30,14 | 30,32 | 5,60 |
| Teresina/PI | 1967 | 0 | 28,59 | 24,07 | 33,06 | 25,07 | 25,70 | 26,15 | 26,71 | 27,42 | 28,33 | 29,75 | 30,95 | 31,37 | 31,72 | 32,08 | 7,01 |
| Fortaleza/CE | 1967 | 0 | 28,35 | 23,89 | 31,57 | 25,33 | 25,76 | 26,20 | 26,88 | 27,75 | 28,49 | 29,08 | 29,60 | 29,86 | 30,29 | 30,72 | 5,39 |
| Natal/RN | 1967 | 0 | 27,94 | 23,50 | 30,18 | 25,63 | 26,11 | 26,59 | 26,96 | 27,48 | 28,01 | 28,47 | 28,88 | 29,12 | 29,34 | 29,55 | 3,93 |
| João Pessoa/PB | 1967 | 0 | 28,11 | 24,14 | 30,51 | 25,66 | 26,10 | 26,56 | 27,04 | 27,65 | 28,18 | 28,67 | 29,11 | 29,38 | 29,56 | 29,88 | 4,22 |
| Recife/PE | 1967 | 0 | 27,47 | 23,63 | 30,27 | 24,97 | 25,48 | 25,81 | 26,18 | 26,77 | 27,46 | 28,19 | 28,86 | 29,17 | 29,38 | 29,69 | 4,72 |
| Maceió/AL | 1967 | 0 | 27,31 | 24,11 | 30,55 | 25,02 | 25,56 | 25,95 | 26,28 | 26,76 | 27,32 | 27,84 | 28,36 | 28,75 | 29,06 | 29,54 | 4,52 |
| Aracaju/SE | 1967 | 0 | 28,01 | 24,50 | 31,51 | 25,64 | 26,14 | 26,54 | 26,91 | 27,46 | 28,03 | 28,56 | 29,08 | 29,40 | 29,79 | 30,32 | 4,68 |
| Salvador/BA | 1967 | 0 | 27,62 | 22,10 | 30,95 | 24,32 | 25,15 | 25,59 | 26,19 | 26,96 | 27,69 | 28,37 | 28,98 | 29,31 | 29,70 | 30,10 | 5,78 |
| Belo Horizonte/MG | 1967 | 0 | 24,11 | 15,73 | 31,30 | 19,50 | 20,31 | 20,99 | 21,78 | 22,99 | 24,28 | 25,29 | 26,21 | 26,74 | 27,20 | 27,88 | 8,37 |
| Vitória/ES | 1967 | 0 | 26,91 | 18,64 | 31,40 | 21,82 | 22,49 | 23,23 | 24,23 | 25,82 | 27,19 | 28,27 | 29,04 | 29,50 | 29,95 | 30,43 | 8,61 |
| Rio de Janeiro/RJ | 1967 | 0 | 26,41 | 18,46 | 33,47 | 20,37 | 21,14 | 21,84 | 22,78 | 24,55 | 26,60 | 28,42 | 29,71 | 30,39 | 30,90 | 31,39 | 11,02 |
| Campinas/SP | 1967 | 0 | 24,32 | 15,88 | 29,82 | 18,95 | 19,80 | 20,77 | 21,66 | 23,04 | 24,55 | 25,69 | 26,64 | 27,18 | 27,72 | 28,35 | 9,40 |
| Baixada Santista/SP | 1967 | 0 | 25,33 | 15,37 | 31,75 | 19,14 | 20,06 | 20,91 | 21,99 | 23,71 | 25,46 | 27,11 | 28,46 | 29,07 | 29,64 | 30,03 | 10,89 |
| São José dos Campos/SP | 1967 | 0 | 23,38 | 13,80 | 28,04 | 18,29 | 19,31 | 20,10 | 20,97 | 22,31 | 23,60 | 24,70 | 25,51 | 26,03 | 26,34 | 26,72 | 8,43 |
| São Paulo/SP | 1967 | 0 | 23,32 | 13,00 | 30,18 | 16,62 | 17,67 | 18,73 | 19,90 | 21,77 | 23,65 | 25,07 | 26,27 | 26,86 | 27,40 | 28,32 | 11,70 |
| Sorocaba/SP | 1967 | 0 | 24,41 | 15,52 | 30,25 | 18,69 | 19,82 | 20,72 | 21,66 | 23,10 | 24,59 | 25,83 | 26,91 | 27,54 | 28,08 | 28,66 | 9,97 |
| Curitiba/PR | 1967 | 0 | 21,74 | 9,99 | 27,98 | 15,10 | 16,07 | 17,01 | 18,03 | 20,04 | 22,05 | 23,71 | 24,94 | 25,64 | 26,26 | 26,83 | 11,74 |
| Florianópolis/SC | 1967 | 0 | 24,58 | 16,35 | 32,56 | 18,79 | 19,90 | 20,72 | 21,57 | 23,00 | 24,68 | 26,24 | 27,54 | 28,22 | 28,79 | 29,54 | 10,74 |
| Porto Alegre/RS | 1967 | 0 | 24,79 | 14,79 | 33,54 | 18,06 | 19,04 | 19,93 | 21,08 | 22,91 | 24,86 | 26,79 | 28,38 | 29,40 | 30,13 | 31,02 | 12,96 |
| Campo Grande | 1967 | 0 | 26,38 | 15,51 | 32,58 | 21,98 | 22,76 | 23,49 | 24,29 | 25,41 | 26,47 | 27,48 | 28,35 | 28,89 | 29,39 | 30,20 | 8,22 |
| Cuiabá/MT | 1967 | 0 | 27,51 | 15,42 | 33,08 | 23,71 | 24,47 | 25,18 | 25,67 | 26,57 | 27,56 | 28,45 | 29,26 | 29,77 | 30,52 | 31,37 | 7,66 |
| Goiânia/GO | 1967 | 0 | 25,60 | 20,63 | 31,33 | 21,71 | 22,45 | 23,03 | 23,80 | 24,72 | 25,67 | 26,52 | 27,33 | 27,90 | 28,37 | 28,93 | 7,22 |
| Brasília/DF | 1967 | 0 | 23,42 | 18,40 | 28,63 | 20,20 | 20,75 | 21,34 | 21,95 | 22,70 | 23,45 | 24,20 | 24,89 | 25,37 | 25,86 | 26,45 | 6,25 |

### A5.4 Exposição semanal e médias móveis (`expo_semanal("tmean", "nucleo")`, `dum_est` de 2011-04-17 a 2024-03-05)

Leitura (i): todos os valores `s01`…`s37` empilhados, sem ponderação por pessoa. Leitura (ii): cada janela de 7 dias de calendário uma vez. Diferença = (i) − (ii), em °C.

| Concentração | dum_est | Janelas (ii) | (i) p1 | (i) p10 | (i) p75 | (i) p90 | (i) p99 | (ii) p1 | (ii) p10 | (ii) p75 | (ii) p90 | (ii) p99 | dif. p1 | dif. p10 | dif. p75 | dif. p90 | dif. p99 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Manaus | 4707 | 4959 | 26,254 | 26,961 | 28,779 | 29,527 | 31,200 | 26,268 | 26,989 | 28,830 | 29,591 | 31,248 | -0,014 | -0,028 | -0,051 | -0,064 | -0,048 |
| Belém/PA | 4707 | 4959 | 26,569 | 27,300 | 28,655 | 28,945 | 29,547 | 26,585 | 27,321 | 28,673 | 28,993 | 29,810 | -0,016 | -0,022 | -0,018 | -0,048 | -0,263 |
| São Luís/MA | 4707 | 4959 | 25,999 | 26,949 | 28,850 | 29,302 | 29,990 | 26,025 | 26,955 | 28,841 | 29,272 | 29,984 | -0,027 | -0,006 | 0,009 | 0,031 | 0,006 |
| Teresina/PI | 4707 | 4959 | 26,389 | 27,088 | 29,453 | 30,591 | 31,548 | 26,395 | 27,072 | 29,452 | 30,618 | 31,574 | -0,006 | 0,016 | 0,001 | -0,027 | -0,026 |
| Fortaleza/CE | 4707 | 4959 | 26,437 | 27,007 | 28,474 | 29,005 | 29,860 | 26,418 | 26,988 | 28,490 | 29,044 | 30,158 | 0,019 | 0,019 | -0,016 | -0,039 | -0,298 |
| Natal/RN | 4707 | 4959 | 24,722 | 25,439 | 27,885 | 28,356 | 29,135 | 24,719 | 25,432 | 27,863 | 28,338 | 29,124 | 0,003 | 0,007 | 0,022 | 0,018 | 0,011 |
| João Pessoa/PB | 4707 | 4959 | 24,427 | 25,287 | 28,064 | 28,491 | 29,265 | 24,423 | 25,303 | 28,042 | 28,476 | 29,239 | 0,003 | -0,015 | 0,022 | 0,015 | 0,026 |
| Recife/PE | 4707 | 4959 | 23,659 | 24,372 | 27,360 | 28,108 | 29,258 | 23,669 | 24,355 | 27,353 | 28,089 | 29,232 | -0,009 | 0,017 | 0,007 | 0,020 | 0,027 |
| Maceió/AL | 4707 | 4959 | 23,798 | 24,417 | 27,256 | 27,823 | 28,705 | 23,771 | 24,394 | 27,224 | 27,804 | 28,691 | 0,026 | 0,023 | 0,032 | 0,019 | 0,014 |
| Aracaju/SE | 4707 | 4959 | 24,344 | 25,200 | 27,946 | 28,489 | 29,455 | 24,345 | 25,188 | 27,920 | 28,469 | 29,436 | 0,000 | 0,012 | 0,027 | 0,019 | 0,020 |
| Salvador/BA | 4707 | 4959 | 23,221 | 24,042 | 27,502 | 28,255 | 29,435 | 23,183 | 23,975 | 27,456 | 28,229 | 29,419 | 0,037 | 0,067 | 0,046 | 0,026 | 0,015 |
| Belo Horizonte/MG | 4707 | 4959 | 17,875 | 19,755 | 24,427 | 25,415 | 27,222 | 17,891 | 19,736 | 24,394 | 25,400 | 27,176 | -0,017 | 0,019 | 0,033 | 0,015 | 0,045 |
| Vitória/ES | 4707 | 4959 | 20,776 | 22,099 | 27,027 | 28,002 | 29,244 | 20,784 | 22,093 | 26,929 | 27,956 | 29,198 | -0,008 | 0,006 | 0,098 | 0,046 | 0,046 |
| Rio de Janeiro/RJ | 4707 | 4959 | 18,844 | 20,751 | 26,254 | 28,053 | 30,005 | 18,834 | 20,695 | 26,155 | 27,962 | 29,988 | 0,010 | 0,056 | 0,099 | 0,091 | 0,017 |
| Campinas/SP | 4707 | 4959 | 15,589 | 18,239 | 24,350 | 25,570 | 27,162 | 15,507 | 18,193 | 24,290 | 25,516 | 27,127 | 0,082 | 0,046 | 0,060 | 0,054 | 0,035 |
| Baixada Santista/SP | 4707 | 4959 | 17,165 | 19,379 | 25,272 | 26,937 | 28,994 | 17,089 | 19,306 | 25,194 | 26,864 | 28,977 | 0,076 | 0,073 | 0,078 | 0,072 | 0,017 |
| São José dos Campos/SP | 4707 | 4959 | 14,785 | 17,154 | 23,364 | 24,534 | 25,935 | 14,694 | 17,110 | 23,296 | 24,475 | 25,908 | 0,091 | 0,044 | 0,069 | 0,059 | 0,027 |
| São Paulo/SP | 4707 | 4959 | 14,899 | 17,276 | 23,399 | 24,827 | 26,631 | 14,778 | 17,219 | 23,299 | 24,768 | 26,581 | 0,120 | 0,057 | 0,100 | 0,059 | 0,051 |
| Sorocaba/SP | 4707 | 4959 | 15,396 | 18,098 | 24,424 | 25,680 | 27,291 | 15,313 | 18,027 | 24,353 | 25,635 | 27,265 | 0,082 | 0,071 | 0,071 | 0,045 | 0,026 |
| Curitiba/PR | 4707 | 4959 | 11,559 | 14,669 | 21,653 | 23,252 | 25,299 | 11,514 | 14,550 | 21,581 | 23,194 | 25,263 | 0,045 | 0,119 | 0,073 | 0,058 | 0,036 |
| Florianópolis/SC | 4707 | 4959 | 14,164 | 17,059 | 24,336 | 26,020 | 27,995 | 13,948 | 16,927 | 24,205 | 25,951 | 27,908 | 0,216 | 0,132 | 0,131 | 0,069 | 0,086 |
| Porto Alegre/RS | 4707 | 4959 | 11,465 | 15,042 | 24,540 | 26,264 | 28,834 | 11,292 | 14,917 | 24,387 | 26,180 | 28,795 | 0,173 | 0,125 | 0,153 | 0,084 | 0,039 |
| Campo Grande | 4707 | 4959 | 16,068 | 20,503 | 26,612 | 27,570 | 29,583 | 16,021 | 20,364 | 26,596 | 27,561 | 29,519 | 0,047 | 0,139 | 0,017 | 0,009 | 0,064 |
| Cuiabá/MT | 4707 | 4959 | 20,290 | 24,161 | 28,107 | 29,172 | 31,482 | 20,270 | 24,080 | 28,130 | 29,221 | 31,691 | 0,021 | 0,080 | -0,023 | -0,049 | -0,209 |
| Goiânia/GO | 4707 | 4959 | 20,628 | 22,478 | 26,212 | 27,222 | 29,341 | 20,674 | 22,434 | 26,201 | 27,222 | 29,512 | -0,046 | 0,044 | 0,010 | 0,000 | -0,170 |
| Brasília/DF | 4707 | 4959 | 18,667 | 20,302 | 23,871 | 24,841 | 26,611 | 18,712 | 20,281 | 23,861 | 24,829 | 26,664 | -0,046 | 0,021 | 0,010 | 0,012 | -0,053 |

- **Maior |diferença|:** 0,298 °C. Pares concentração × percentil acima de 0,05 °C: 45 de 130, em 18 concentrações (Campinas/SP, Baixada Santista/SP, São José dos Campos/SP, São Paulo/SP, Sorocaba/SP, Florianópolis/SC, Porto Alegre/RS, Salvador/BA, Rio de Janeiro/RJ, Curitiba/PR, Campo Grande, Cuiabá/MT, Manaus, Vitória/ES, Belém/PA, Fortaleza/CE, Goiânia/GO, Brasília/DF).
- **⚑ Sinalização:** a diferença passa de 0,05 °C. A regra da distribuição semanal (§1.2), leitura (i) ou (ii), tem de ser fixada pelo chat de métodos antes da tag.
- **Por que diferem:** na leitura (i), cada janela entra tantas vezes quantos `dum_est` a contêm, de 1 a 37 vezes. Só as janelas que começam de 2011-12-25 a 2024-03-05 entram 37 vezes; as das pontas (começo de 2011-04-17 a 2011-12-24 e de 2024-03-06 a 2024-11-12) entram menos. A (ii) dá peso igual às 4.959 janelas.
- **Consistência:** a mesma janela de calendário tem o mesmo valor em todas as linhas (maior diferença: 0 °C).

#### MM9 (`s29`…`s37`) e MM14 (1º trimestre `s01`…`s14`; 2º trimestre `s15`…`s28`), em °C

| Concentração | MM9 p1 | MM9 p50 | MM9 p99 | 1º tri p1 | 1º tri p99 | 2º tri p1 | 2º tri p99 | p99 da MM9 = percentil semanal (i) | p1 da MM9 = percentil semanal (i) |
|---|---|---|---|---|---|---|---|---|---|
| Manaus | 26,82 | 28,12 | 30,61 | 26,95 | 30,38 | 26,95 | 30,38 | 97,7 | 7,4 |
| Belém/PA | 27,11 | 28,23 | 29,54 | 27,23 | 29,32 | 27,23 | 29,32 | 99,0 | 6,1 |
| São Luís/MA | 26,38 | 28,09 | 29,54 | 26,59 | 29,41 | 26,59 | 29,41 | 94,5 | 3,0 |
| Teresina/PI | 27,01 | 28,07 | 31,28 | 27,08 | 31,04 | 27,17 | 31,04 | 97,7 | 8,0 |
| Fortaleza/CE | 26,89 | 27,92 | 29,71 | 26,94 | 29,34 | 27,04 | 29,34 | 98,6 | 6,8 |
| Natal/RN | 25,13 | 27,29 | 28,80 | 25,31 | 28,79 | 25,31 | 28,79 | 97,4 | 4,2 |
| João Pessoa/PB | 24,85 | 27,36 | 28,90 | 24,98 | 28,88 | 24,98 | 28,88 | 96,7 | 3,1 |
| Recife/PE | 24,00 | 26,51 | 28,99 | 24,21 | 28,92 | 24,21 | 28,92 | 98,2 | 4,0 |
| Maceió/AL | 24,13 | 26,47 | 28,42 | 24,23 | 28,32 | 24,28 | 28,32 | 97,4 | 5,2 |
| Aracaju/SE | 24,55 | 27,15 | 28,94 | 24,71 | 28,80 | 24,71 | 28,80 | 96,8 | 2,4 |
| Salvador/BA | 23,63 | 26,42 | 28,89 | 23,58 | 28,77 | 23,91 | 28,77 | 96,9 | 4,6 |
| Belo Horizonte/MG | 19,41 | 23,19 | 26,04 | 19,93 | 25,72 | 19,93 | 25,72 | 95,1 | 7,1 |
| Vitória/ES | 21,49 | 25,01 | 28,35 | 22,01 | 28,18 | 22,01 | 28,18 | 94,0 | 4,5 |
| Rio de Janeiro/RJ | 20,53 | 24,13 | 28,56 | 20,83 | 28,12 | 20,85 | 28,12 | 93,6 | 8,0 |
| Campinas/SP | 17,82 | 22,66 | 25,82 | 18,21 | 25,49 | 18,30 | 25,49 | 92,2 | 7,2 |
| Baixada Santista/SP | 18,85 | 23,03 | 27,35 | 19,34 | 26,94 | 19,34 | 26,94 | 92,6 | 6,6 |
| São José dos Campos/SP | 16,65 | 21,65 | 24,59 | 17,10 | 24,38 | 17,20 | 24,38 | 90,6 | 6,4 |
| São Paulo/SP | 17,02 | 21,41 | 25,22 | 17,40 | 24,78 | 17,48 | 24,78 | 93,3 | 8,2 |
| Sorocaba/SP | 17,76 | 22,61 | 25,96 | 17,99 | 25,71 | 18,13 | 25,71 | 92,5 | 7,4 |
| Curitiba/PR | 14,04 | 19,26 | 23,64 | 14,49 | 23,05 | 14,52 | 23,05 | 92,9 | 6,7 |
| Florianópolis/SC | 16,27 | 21,50 | 26,54 | 16,44 | 26,03 | 16,66 | 26,03 | 93,8 | 5,7 |
| Porto Alegre/RS | 14,48 | 20,89 | 26,82 | 14,85 | 26,30 | 14,99 | 26,30 | 93,2 | 7,5 |
| Campo Grande | 20,00 | 25,38 | 28,17 | 20,61 | 27,95 | 20,65 | 27,95 | 95,0 | 7,8 |
| Cuiabá/MT | 23,70 | 27,05 | 30,78 | 24,08 | 30,50 | 24,08 | 30,50 | 97,6 | 7,8 |
| Goiânia/GO | 22,02 | 25,28 | 28,22 | 22,55 | 27,79 | 22,56 | 27,79 | 95,7 | 5,5 |
| Brasília/DF | 19,82 | 23,06 | 25,73 | 20,33 | 25,49 | 20,33 | 25,49 | 95,5 | 5,7 |

- **Percentil semanal (i) equivalente ao p99 da MM9:** média p95,3, de p90,6 a p99,0. **Ao p1 da MM9:** média p6,0, de p2,4 a p8,2.
- **Referência da especificação (§3.3, por simulação):** p99 da MM9 perto do p93–94 (cerca de p89 a p99); p1 perto do p6 (p3,1 a p9,1).
- **MM14:** o p99 é igual nos dois trimestres em 26 de 26 concentrações, e o p1 em 12. É esperado: a MM14 do 2º trimestre de um `dum_est` é a do 1º trimestre do `dum_est` 98 dias depois (maior diferença conferida: 0 °C), então as duas distribuições só diferem nas pontas.

### A5.5 Dias de modelo utilizáveis do `pm25_local_zero_na_nucleo` (média móvel de lag 0–1)

| Concentração | Janela | Dias | Sem valor (brutos) | Utilizáveis | % | ≥ 90% | Sem valor em 2012–2024 |
|---|---|---|---|---|---|---|---|
| Campo Grande | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 | 342 | 3883 | 87,14 | NÃO passa | 361/4749 |
| Goiânia/GO | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 | 323 | 3906 | 87,66 | NÃO passa | 332/4749 |
| Brasília/DF | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 | 322 | 3915 | 87,86 | NÃO passa | 332/4749 |
| Teresina/PI | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 | 178 | 4147 | 93,07 | passa | 179/4749 |
| Belo Horizonte/MG | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  80 | 4304 | 96,59 | passa | 82/4749 |
| Vitória/ES | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  74 | 4313 | 96,79 | passa | 84/4749 |
| Cuiabá/MT | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  77 | 4317 | 96,88 | passa | 82/4749 |
| Curitiba/PR | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  72 | 4318 | 96,90 | passa | 78/4749 |
| Porto Alegre/RS | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  48 | 4362 | 97,89 | passa | 57/4749 |
| Natal/RN | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  20 | 4416 | 99,10 | passa | 21/4749 |
| Salvador/BA | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  15 | 4427 | 99,35 | passa | 15/4749 |
| São José dos Campos/SP | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  13 | 4430 | 99,42 | passa | 15/4749 |
| Aracaju/SE | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  10 | 4436 | 99,55 | passa | 10/4749 |
| Maceió/AL | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   9 | 4438 | 99,60 | passa | 9/4749 |
| Sorocaba/SP | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   4 | 4448 | 99,82 | passa | 6/4749 |
| Florianópolis/SC | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   3 | 4450 | 99,87 | passa | 5/4749 |
| Manaus | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   3 | 4451 | 99,89 | passa | 3/4749 |
| Belém/PA | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   2 | 4452 | 99,91 | passa | 2/4749 |
| São Luís/MA | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   1 | 4454 | 99,96 | passa | 1/4749 |
| Fortaleza/CE | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   1 | 4454 | 99,96 | passa | 1/4749 |
| Recife/PE | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   1 | 4454 | 99,96 | passa | 1/4749 |
| João Pessoa/PB | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   0 | 4456 | 100,00 | passa | 0/4749 |
| Rio de Janeiro/RJ | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   0 | 4456 | 100,00 | passa | 0/4749 |
| Campinas/SP | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   0 | 4456 | 100,00 | passa | 0/4749 |
| Baixada Santista/SP | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   0 | 4456 | 100,00 | passa | 0/4749 |
| São Paulo/SP | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   0 | 4456 | 100,00 | passa | 0/4749 |
| Campo Grande | ptb principal (2012-04-14 a 2024-08-06) | 4498 | 343 | 3923 | 87,22 | NÃO passa | 361/4749 |
| Goiânia/GO | ptb principal (2012-04-14 a 2024-08-06) | 4498 | 324 | 3946 | 87,73 | NÃO passa | 332/4749 |
| Brasília/DF | ptb principal (2012-04-14 a 2024-08-06) | 4498 | 322 | 3957 | 87,97 | NÃO passa | 332/4749 |
| Teresina/PI | ptb principal (2012-04-14 a 2024-08-06) | 4498 | 179 | 4187 | 93,09 | passa | 179/4749 |
| Belo Horizonte/MG | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  80 | 4346 | 96,62 | passa | 82/4749 |
| Vitória/ES | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  74 | 4355 | 96,82 | passa | 84/4749 |
| Cuiabá/MT | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  79 | 4355 | 96,82 | passa | 82/4749 |
| Curitiba/PR | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  72 | 4360 | 96,93 | passa | 78/4749 |
| Porto Alegre/RS | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  48 | 4404 | 97,91 | passa | 57/4749 |
| Natal/RN | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  21 | 4456 | 99,07 | passa | 21/4749 |
| Salvador/BA | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  15 | 4469 | 99,36 | passa | 15/4749 |
| São José dos Campos/SP | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  13 | 4472 | 99,42 | passa | 15/4749 |
| Aracaju/SE | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  10 | 4478 | 99,56 | passa | 10/4749 |
| Maceió/AL | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   9 | 4480 | 99,60 | passa | 9/4749 |
| Sorocaba/SP | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   4 | 4490 | 99,82 | passa | 6/4749 |
| Florianópolis/SC | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   3 | 4492 | 99,87 | passa | 5/4749 |
| Manaus | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   3 | 4493 | 99,89 | passa | 3/4749 |
| Belém/PA | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   2 | 4494 | 99,91 | passa | 2/4749 |
| São Luís/MA | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   1 | 4496 | 99,96 | passa | 1/4749 |
| Fortaleza/CE | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   1 | 4496 | 99,96 | passa | 1/4749 |
| Recife/PE | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   1 | 4496 | 99,96 | passa | 1/4749 |
| João Pessoa/PB | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   0 | 4498 | 100,00 | passa | 0/4749 |
| Rio de Janeiro/RJ | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   0 | 4498 | 100,00 | passa | 0/4749 |
| Campinas/SP | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   0 | 4498 | 100,00 | passa | 0/4749 |
| Baixada Santista/SP | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   0 | 4498 | 100,00 | passa | 0/4749 |
| São Paulo/SP | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   0 | 4498 | 100,00 | passa | 0/4749 |

- **Não passam (≥ 90%):** Campo Grande, Goiânia/GO, Brasília/DF.
- **Conferência com a §2.3:** Campo Grande tem 361/4749 dias sem valor em 2012–2024; a especificação cita 361/4.749.

`versao()` no fim: 7e99bf94.

## 7. Dupla auditoria

### 7.1 Autoauditoria por código

`00_scripts/03_autoauditoria_fase0.R` refaz cada número da A5 por um caminho diferente e compara com os CSV:

- **Contagens:** série municipal somada por concentração pelo `concentracoes()`.
- **Temperatura e PM2.5:** `diaria_recorte(var, "nucleo")`, o clima municipal da cidade-núcleo.
- **Semanas:** médias de 7 dias recalculadas da temperatura diária.
- **Janelas:** `seq()` de datas.
- **Git (C7):** o que entraria num `git add`.
- **Regras de script e log (C9):** acrescentadas depois da auditoria independente, para conferir as correções.

| Item | Conferência | Esperado | Obtido | Ok |
|---|---|---|---|---|
| C1 | dias da janela PTB principal | 4498 | 4498 | sim |
| C1 | dias da janela perinatal principal | 4456 | 4456 | sim |
| C1 | dias da janela termo precoce (regra do principal) | 4589 | 4589 | sim |
| C1 | dias da janela 2012–2024 | 4749 | 4749 | sim |
| C1 | dias de novembro a março em 2012–2024 | 1967 | 1967 | sim |
| C1 | dias_janela do CSV da A5.2 = seq() das datas (4 janelas) | 4 de 4 | 4 de 4 | sim |
| C2 | municípios da série municipal, todos mapeados no concentracoes() | 277 | 277 | sim |
| C2 | total de nv_unicos em 2012–2024, pela série municipal | 13791848 | 13791848 | sim |
| C2 | dias com NA em nv_unicos | 0 | 0 | sim |
| C2 | total de ptb em 2012–2024, pela série municipal | 1405697 | 1405697 | sim |
| C2 | dias com NA em ptb | 0 | 0 | sim |
| C2 | total de obito_perinatal em 2012–2024, pela série municipal | 180064 | 180064 | sim |
| C2 | dias com NA em obito_perinatal | 7 | 7 (2024-12-25 a 2024-12-31) | sim |
| C3 | ptb, janela principal: eventos e total por concentração (26), série municipal × CSV | diferença 0 | eventos 0; total 0 | sim |
| C3 | ptb, janela principal: perda total % | 1.9682 | 1.9682 | sim |
| C3 | ptb, janela evento possível: eventos e total por concentração (26), série municipal × CSV | diferença 0 | eventos 0; total 0 | sim |
| C3 | ptb, janela evento possível: perda total % | 0.0000 | 0.0000 | sim |
| C3 | obito_perinatal, janela principal: eventos e total por concentração (26), série municipal × CSV | diferença 0 | eventos 0; total 0 | sim |
| C3 | obito_perinatal, janela principal: perda total % | 2.7740 | 2.7740 | sim |
| C3 | obito_perinatal, janela evento possível: eventos e total por concentração (26), série municipal × CSV | diferença 0 | eventos 0; total 0 | sim |
| C3 | obito_perinatal, janela evento possível: perda total % | 0.0000 | 0.0000 | sim |
| C3 | PTB fora da janela de evento possível, série municipal | 0 | 0 | sim |
| C3 | contagens de 1 a 9 na A5.2 (exigiriam máscara ou supressão) | 0 | 0 | sim |
| C3 | perinatal, janela principal, abaixo de 2.000 | Campo Grande, Florianópolis/SC, Sorocaba/SP | Campo Grande, Florianópolis/SC, Sorocaba/SP | sim |
| C3 | abaixo de 1.000 na janela principal (PTB e perinatal) |  |  | sim |
| C4 | tmean diária: diaria_recorte() × coluna tmean_nucleo da série (2012–2024) | 26 × 4.749 dias iguais | 123474 dias casados; diferença máxima 0e+00 | sim |
| C4 | ano inteiro 2012–2024: n, NA, média, mín., máx., 11 percentis (type 7) e p99 − p1, 26 concentrações | diferença < 1e-08 | 5.15e-14 (n e NA: 0) | sim |
| C4 | ano inteiro 2012–2024: sensibilidade da conferência (type 6 contra o CSV) | diferença > 0 | 1.05e-01 | sim |
| C4 | novembro a março: n, NA, média, mín., máx., 11 percentis (type 7) e p99 − p1, 26 concentrações | diferença < 1e-08 | 4.97e-14 (n e NA: 0) | sim |
| C4 | novembro a março: sensibilidade da conferência (type 6 contra o CSV) | diferença > 0 | 1.51e-01 | sim |
| C5 | expo_semanal: dum_est de 2011-04-17 a 2024-03-05, todos os dias, por concentração | 26 de 26 | 26 de 26 | sim |
| C5 | s01…s37 do expo_semanal × médias de 7 dias recalculadas da tmean diária da cidade-núcleo | < 1e-08 | 1.09e-11 | sim |
| C5 | A5.4 inteira (leituras (i) e (ii), diferenças, MM9, ecdf, MM14, contagens) recalculada × CSV | < 1e-08 | 9.27e-12 | sim |
| C6 | PM2.5 diário: diaria_recorte() × coluna da série (2012–2024) | mesmos NA e valores iguais | 123474 dias casados; NA iguais: TRUE; diferença máxima 0e+00 | sim |
| C6 | dias de modelo utilizáveis, dias da janela e dias sem valor (26 × 2 janelas) × CSV | diferença 0 | 0 | sim |
| C6 | Campo Grande, dias sem valor em 2012–2024 (especificação §2.3) | 361 | 361 | sim |
| C6 | concentrações abaixo de 90% | Brasília/DF, Campo Grande, Goiânia/GO | Brasília/DF, Campo Grande, Goiânia/GO | sim |
| C7 | arquivos que o git aceitaria com extensão de dado (fora a exceção do renv/settings.json) | 0 | 0 | sim |
| C7 | arquivos que o git aceitaria com mais de 5 MB | 0 | 0 | sim |
| C7 | scripts, logs e configuração da Fase 0 que devem entrar no git (19) | todos | todos | sim |
| C9 | todo script de 00_scripts/ confere versao() no início e no fim e fixa a semente | 5 de 5 | 5 de 5  | sim |
| C9 | logs gerados registram a versao() do fim | 3 de 3 | 3 de 3 | sim |
| C9 | "-0,000" no log da A5 | 0 | 0 | sim |
| C9 | padrões de evidência da A4 que casam com mais de uma linha do código da base | 0 | 0 | sim |
| C7 | CSV de 01_saidas/fase0 ignorados pelo git | 5 de 5 | 5 de 5 | sim |
| C7 | commits no repositório (Parte A não faz commit) | 0 | 0 | sim |
| C8 | versao() no início | 7e99bf94 | 7e99bf94 | sim |
| C8 | versao() no fim | 7e99bf94 | 7e99bf94 | sim |

### 7.2 Auditoria independente e tabela achado → reprodução → correção

De `artigo1_prematuridade/logs/auditoria_fase0_20261008.md`. A auditoria rodou num subagente em contexto limpo, sobre o rascunho deste RESPOSTA, com as regras de acesso do prompt.

### Resultado da auditoria independente

- **Achados:** nenhum crítico, 1 maior, 9 menores e 3 cosméticos. Os 13 foram reproduzidos e 12 foram corrigidos. O 10 depende de decisão e foi levado ao RESPOSTA.
- **Números da A5:** o auditor refez, a partir dos CSV, os dias das janelas, os totais, as perdas, os mínimos, as listas abaixo de 1.000 e de 2.000, os percentis (todos com `type = 7`), as leituras (i) e (ii), a MM9, a MM14, o `ecdf` e a regra de 90% do PM2.5. Tudo fecha entre os CSV, os logs e o RESPOSTA.
- **Linha vermelha e sigilo:** nenhum objeto junta desfecho e exposição, e nenhuma contagem de 1 a 9 foi publicada.
- **Git:** 0 commits e índice vazio. O `.gitignore` é idêntico à lista do chat. Nenhum arquivo que o git aceitaria tem extensão de dado ou passa de 5 MB, e os 5 CSV são ignorados.

### Achado → reprodução → correção

| # | Severidade | Achado | Reprodução (código próprio) | Correção |
|---|---|---|---|---|
| 1 | Maior | O RESPOSTA não dizia que a decisão sobre o `DTULTMENST` vai ao chat de métodos **antes da tag**. O desvio 2 dizia "a autorizar por Guilherme". | `grep -n -i 'chat de m'` no rascunho: 2 linhas, ambas sobre a regra semanal. Os ajustes do chat, linha 115, dizem: "A decisão vai ao chat de métodos **antes da tag**". | O desvio 2 passou a dizer "a decisão vai ao chat de métodos antes da tag". O RESPOSTA leva o item como segunda decisão ⚑ para o chat. O `CLAUDE.md` do artigo remete ao desvio 2. |
| 2 | Menor | A7.2 e A7.3 estavam pendentes no rascunho, e não existia este log. | `ls logs/`: sem `auditoria_fase0_20261008.md`. A §7.2 do rascunho dizia "Em andamento". | Este log foi criado, e o RESPOSTA foi remontado com a tabela. |
| 3 | Menor | O RESPOSTA dizia que nenhum desvio tinha efeito nos resultados, mas o desvio 2 bloqueia uma sensibilidade pré-especificada (§3.5). | Leitura lado a lado do resumo do rascunho e da linha do desvio 2. | Texto novo: "nenhum muda a análise principal; o desvio 2 bloqueia a sensibilidade da §3.5". |
| 4 | Menor | Falha latente de sigilo: as margens do "Resumo da A5.2" saíam sem máscara. Se uma concentração tivesse parte suprimida, a célula seria recuperada pela margem. | Leitura do `02_recontagens_fase0.R`: o `resumo52` usava `br()` direto nas somas. Sem efeito hoje, porque não há contagem de 1 a 9 (C3). | Quando alguma concentração do grupo tem parte suprimida ou total mascarado, as margens saem "supr.", e o mínimo passa por `masc()`. |
| 5 | Menor | O `00_dependencias.R` não conferia a `versao()` nem fixava a semente. | Leitura da versão anterior, de 21 linhas, sem `source`, `versao()` nem `set.seed`. | O script ganhou semente e `versao()` no início e no fim. A C9 confere essa regra em todo script de `00_scripts/` (5 de 5). |
| 6 | Menor | O "fim = 7e99bf94" do `00_ambiente`, do `01_interface` e do `02` não ficava em log. O log era gravado antes do `stopifnot` final. | Leitura dos três scripts: `writeLines` vinha antes do `stopifnot` final. | Os três scripts agora gravam o log depois da conferência final, com a linha "`versao()` no fim: 7e99bf94", e o início vem de `v_ini`. A C9 confere os 3 logs. |
| 7 | Menor | O log da A4 tinha seções escritas à mão no fim de um arquivo gerado, que se perderiam ao rodar o script de novo. A linha 206 aparecia duas vezes, a 287 era de outro bloco, e as linhas 142 e 166 não estavam transcritas. | Comparação do `01_interface.R` com o log. Ao rodar de novo, o padrão do `SEMAGESTAC` casou com as linhas 142 e 221, esta do bloco dos óbitos. | A leitura foi movida, sem alteração do texto, para `logs/interface_conclusoes_fase0_20261008.md`. A busca no `06b` ficou restrita ao bloco dos nascimentos. São 9 padrões, cada um com 1 linha, inclusive a 142 e a 166. A C9 confere que nenhum padrão casa com mais de uma linha. |
| 8 | Menor | Faltava saída bruta em log para o `renv` (`init`, `hydrate`, `snapshot`), os 4,3 GB, os 0 links, a recompilação do `gigs` às 11:57 e o aviso do `dplyr`. O `gh auth status` só aparecia às 15:15. | `grep` desses termos nos logs: só o texto dos desvios. No registro da sessão, o `gh auth status` rodou às 14:32:52, antes do `renv::init` (14:34:57); só não tinha ido para log. | Novo `logs/renv_fase0_20261008.md`, com as saídas da sessão (`gh auth status` com o token mascarado, `init`, `hydrate` integral e `snapshot`) e as conferências refeitas (`du`, links, pacotes, `DESCRIPTION` do `gigs`, `dplyr` e `renv`, aviso ao carregar o `dplyr`). |
| 9 | Menor | "Dias com dado 4739/4739" no perinatal de evento possível podia ser lido como dias de modelo. A §3.2 restringe essa janela aos dias com Z_t > 0. | Especificação, linha 240: "de 2012-01-04 a 2024-12-24, nos dias com Z_t > 0". O `02` contava dias sem NA no desfecho. | A coluna virou "Dias com valor do desfecho", com nota: a restrição Z_t > 0 entra no modelo, na Fase 2, que também confere se há evento em dia com Z_t = 0 (não se espera nenhum). As contagens de eventos não mudam. |
| 10 | Menor | Rastreabilidade: o prompt auditado está só numa cópia de trabalho efêmera (`/private/tmp`), e os documentos do chat em `logs/_entrada_chat/` ficam fora do git. | `shasum -a 256` da cópia: `549ea53a…55b3`, conferido também pelo auditor. `git status --ignored`: `!! logs/_entrada_chat/`. | **Sem correção nesta fase: depende de decisão.** O RESPOSTA pergunta se o prompt e os documentos do chat devem entrar no repositório antes da tag, por exemplo em `logs/chat/`, e pede o arquivo do prompt. |
| 11 | Cosmético | O RESPOSTA dizia que as dependências do `acesso.R` estavam "todas no `renv.lock`". O `tools` é pacote base e não está no lock. | `python3 -I`: `'tools' in Packages` → False (o `splines` também não), e `arrow`, `dplyr` e `jsonlite` estão. | Texto novo: `arrow`, `dplyr` e `jsonlite` estão no `renv.lock`; `tools` é pacote base do R. |
| 12 | Cosmético | Os horários "14:3x" do `checagem_arranjos_ibge` e do `a1_evidencias` não batiam com os arquivos. | Registro da sessão: a consulta ao SIDRA rodou às 14:25:50 e os testes do hook às 14:25:37. O `testes_hook.txt` foi gravado às 14:25:41. | Os dois logs dizem agora 14:25, com nota de correção que cita este achado. |
| 13 | Cosmético | A §9 do rascunho não listava o próprio RESPOSTA, e a tabela da A5.4 tinha "-0,000". | O rascunho foi montado antes de o arquivo existir. No log da primeira rodada havia "-0,000" em Aracaju (dif. p1) e Goiânia (dif. p90). | O `br()` arredonda e zera o sinal do zero, e a C9 confere que não há "-0,000" no log. O RESPOSTA final foi montado com o arquivo já existente, e por isso aparece na §9. |

### Exceções às regras de acesso, declaradas pelo próprio auditor

1. Um `grep` de credenciais em `artigo1_prematuridade/renv/settings.json`, fora da lista permitida. Nada foi achado nem impresso.
2. Ao ler o `09_acesso/acesso.R`, o ambiente carregou sozinho o `CLAUDE.md` da base. O auditor não pediu esse arquivo, e nenhum achado depende dele.
3. `stat` e `wc -c` em `README.md`, `codigo_compartilhado/DESCRIPTION` e `renv/activate.R`, só para tamanho e data.

Nenhuma exceção tocou microdado, `.parquet`, `.dbc` ou função de leitura de dado. **Avaliação:** as três são inócuas e não mudam a validade da auditoria.

### O que o auditor não pôde verificar dentro das regras

- **540.212 e 574.491:** as diferenças do `stcesparto_aj` em 2014 e 2015, que vêm da Q2b da entrega da base.
- **Conteúdo das linhas do `06b`:** foi transcrito no log da A4 pelo `01_interface.R`.

## 8. Desvios registrados

De `artigo1_prematuridade/logs/desvios_especificacao.md` (tag e hash a preencher na Parte B):

| # | Data | Etapa | Referência | O que divergiu | Causa | Efeito nos resultados | Decisão | Evidência |
|---|---|---|---|---|---|---|---|---|
| 1 | 2026-10-08 | A3, ambiente | Especificação §8 (`renv.lock` por artigo); o cache padrão do `renv` usa links simbólicos | `renv` sem links simbólicos: `RENV_CONFIG_CACHE_SYMLINKS=FALSE` no `.Renviron`. Os 40 pacotes do `renv.lock` estão copiados em `renv/library/` (4,3 GB; 0 links) | O exFAT da Forja não tem link simbólico confiável (CLAUDE.md da raiz, §5) | Nenhum: as versões são as da §8, conferidas por `00_scripts/00_ambiente.R` | Previsto no prompt (A6) e no ajuste 2.7 do chat | `.Renviron`, `renv.lock`, `logs/renv_fase0_20261008.md` |
| 2 | 2026-10-08 | A4, interface | Especificação §3.5 e §10.3, pendência 4 | `DTULTMENST` não está em `nascimentos()` (esquema do `manifesto.json`) | A base `7e99bf94` não exporta a DUM | A sensibilidade de consistência interna da IG (§3.5) fica bloqueada. O PTB espontâneo (§3.4) não é afetado: `sttrabpart`, `stcesparto_aj` e `parto` existem | Registrar e seguir. **A decisão vai ao chat de métodos antes da tag** (ajustes do chat): versão nova da base, que muda a `versao()` dos três artigos, ou a §3.5 fica fora. Não bloqueia a tag (prompt, A4) | `logs/interface_fase0_20261008.md`, `logs/interface_conclusoes_fase0_20261008.md` |
| 3 | 2026-10-08 | A4, interface | Prompt da Fase 0, A4 (calendário esperado na `serie_diaria`); especificação §3.1 e §4 | `dia_semana`, `feriado_nacional`, `carnaval`, `quarta_cinzas`, `sexta_paixao` e `corpus_christi` não estão na `serie_diaria` (39 colunas no esquema); estão em `calendario()` | Desenho da base | Nenhum no método: o calendário entra no modelo pela junção por `data` | Juntar por `data` na Fase 2 (CLAUDE.md do artigo) | `logs/interface_fase0_20261008.md` |
| 4 | 2026-10-08 | A4, interface | Prompt da Fase 0, A4; especificação §3.1 e §9.1, item 4 (termo precoce de 37–38 semanas como desfecho comparativo descritivo) | Não há coluna de termo precoce nem de NV por semana na `serie_diaria` (nenhuma das 39 colunas do esquema) | Desenho da base | A série de termo precoce será montada no artigo a partir de `nascimentos()` | Montar na Fase 4 (prompt, A4) | `logs/interface_fase0_20261008.md` |
| 5 | 2026-10-08 | A1, estrutura | Ajuste 2.6 do chat (`.gitkeep` em cada subpasta) | Os `.gitkeep` de `01_saidas/`, `tabelas/`, `figuras/`, `manuscrito/` e `Submissao/`, nos três artigos, existem no disco mas não entram no git, porque as pastas inteiras estão excluídas | Excluir a pasta inteira é a proteção mais forte contra vazamento de saídas | Nenhum: todo script que grava nessas pastas as cria com `dir.create(..., recursive = TRUE)` | Desvio menor, aceito pelo chat (auditoria da A1, §2) | `logs/a1_evidencias_20261008.md` (saídas do `git check-ignore`) |
| 6 | 2026-10-08 | A3, ambiente | Especificação §8: `gigs` 0.5.2.9000 do r-universe, binário compilado em R 4.5.3; "se reinstalar, fixar o commit fb58fe6" | O `gigs` instalado foi recompilado da fonte do GitHub (`lshtm-gigs/gigs`, `RemoteSha` `fb58fe6596d4b289d5362c5efe00f882984d3186`), em R 4.5.1, em 2026-10-08 às 11:57 (horário de Brasília), antes da criação do `renv` | Origem não identificada: não há comando de instalação nesta sessão nesse dia. A pergunta foi para Guilherme no RESPOSTA | Nenhum esperado: mesma versão e mesmo commit. O Artigo 1 não usa o `gigs`, e as classes do PIG já vêm da base. O `renv.lock` registra a fonte GitHub com o SHA, o que permite reinstalar | Registrar; confirmar a origem com Guilherme | `logs/ambiente_fase0_20261008.md`, `logs/renv_fase0_20261008.md` (campos `Packaged` e `Built` do `DESCRIPTION` do `gigs`) |

**Não é desvio:** o BLAS é o de referência (`libRblas`), e todas as versões da §8 conferem.

## 9. `git status` e `git ls-files`

```
$ git -C /Volumes/Forja/Doc/artigos_perinatais_clima status --short --untracked-files=all   (sem os ._* do exFAT)
?? .gitattributes
?? .gitignore
?? README.md
?? artigo1_prematuridade/.Renviron
?? artigo1_prematuridade/.Rprofile
?? artigo1_prematuridade/00_scripts/.gitkeep
?? artigo1_prematuridade/00_scripts/00_ambiente.R
?? artigo1_prematuridade/00_scripts/00_dependencias.R
?? artigo1_prematuridade/00_scripts/01_interface.R
?? artigo1_prematuridade/00_scripts/02_recontagens_fase0.R
?? artigo1_prematuridade/00_scripts/03_autoauditoria_fase0.R
?? artigo1_prematuridade/CLAUDE.md
?? artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_20261008.md
?? artigo1_prematuridade/logs/.gitkeep
?? artigo1_prematuridade/logs/ambiente_fase0_20261008.md
?? artigo1_prematuridade/logs/attrdl_consulta_20261008.md
?? artigo1_prematuridade/logs/auditoria_fase0_20261008.md
?? artigo1_prematuridade/logs/autoauditoria_fase0_20261008.md
?? artigo1_prematuridade/logs/desvios_especificacao.md
?? artigo1_prematuridade/logs/interface_conclusoes_fase0_20261008.md
?? artigo1_prematuridade/logs/interface_fase0_20261008.md
?? artigo1_prematuridade/logs/recontagens_fase0_20261008.md
?? artigo1_prematuridade/logs/renv_fase0_20261008.md
?? artigo1_prematuridade/logs/sessionInfo_20261008.txt
?? artigo1_prematuridade/renv.lock
?? artigo1_prematuridade/renv/activate.R
?? artigo1_prematuridade/renv/settings.json
?? artigo2_obito_perinatal/00_scripts/.gitkeep
?? artigo2_obito_perinatal/logs/.gitkeep
?? artigo3_pig/00_scripts/.gitkeep
?? artigo3_pig/logs/.gitkeep
?? codigo_compartilhado/DESCRIPTION
?? codigo_compartilhado/R/.gitkeep
?? codigo_compartilhado/inst/terceiros/.gitkeep
?? codigo_compartilhado/tests/.gitkeep
?? ferramentas/checa_sigilo.sh
?? logs/a1_estrutura_git_20261008.md
?? logs/a1_evidencias_20261008.md
?? logs/checagem_arranjos_ibge_20261008.md
?? logs/confirmacoes_pre_tag.md

$ git -C /Volumes/Forja/Doc/artigos_perinatais_clima ls-files
(vazio: nada preparado nem versionado)

$ git -C /Volumes/Forja/Doc/artigos_perinatais_clima rev-list --all --count
0
```

Nenhum commit, índice vazio e a especificação ainda fora de `spec/`: o commit da spec é da Parte B.

## 10. Scripts criados e como rodar

Todos os scripts R rodam a partir de `artigo1_prematuridade/`, com o `renv` do artigo ativo pelo `.Rprofile`.

| Script | Tarefa | Comando | Grava |
|---|---|---|---|
| `00_scripts/00_ambiente.R` | A3: versões, BLAS, `sessionInfo` | `Rscript 00_scripts/00_ambiente.R` | `logs/sessionInfo_20261008.txt`, `logs/ambiente_fase0_20261008.md` |
| `00_scripts/00_dependencias.R` | A3.5: carrega os pacotes, para o `renv` travar | `Rscript 00_scripts/00_dependencias.R` | nada |
| `00_scripts/01_interface.R` | A4: interface, só pelo esquema e pelo código da base | `Rscript 00_scripts/01_interface.R` | `logs/interface_fase0_20261008.md` |
| `00_scripts/02_recontagens_fase0.R` | A5: recontagens e percentis | `Rscript 00_scripts/02_recontagens_fase0.R` | `01_saidas/fase0/a5_*.csv` (fora do git), `logs/recontagens_fase0_20261008.md` |
| `00_scripts/03_autoauditoria_fase0.R` | A7.1: autoauditoria | `Rscript 00_scripts/03_autoauditoria_fase0.R` | `logs/autoauditoria_fase0_20261008.md` |
| `ferramentas/checa_sigilo.sh` | Hook de pre-commit | da raiz do repositório: `sh ferramentas/checa_sigilo.sh` | nada |

**Logs escritos à mão (não gerados por script):**

- na raiz: `a1_estrutura_git_20261008.md`, `a1_evidencias_20261008.md`, `confirmacoes_pre_tag.md` e `checagem_arranjos_ibge_20261008.md`;
- no artigo: `interface_conclusoes_fase0_20261008.md`, `desvios_especificacao.md`, `renv_fase0_20261008.md`, `attrdl_consulta_20261008.md` e `auditoria_fase0_20261008.md`.

Todos foram montados a partir de saídas de comandos.

## 11. `versao()` antes e depois

Todos os scripts param se a `versao()` for diferente de `7e99bf94`, no início e no fim. Os três que gravam log também registram o início e o fim no log; a regra é conferida pela C9.

| Script | Início | Fim | Onde fica o registro |
|---|---|---|---|
| `00_ambiente.R` | 7e99bf94 | 7e99bf94 | `logs/ambiente_fase0_20261008.md` |
| `00_dependencias.R` | 7e99bf94 | 7e99bf94 | só no console (não grava log) |
| `01_interface.R` | 7e99bf94 | 7e99bf94 | `logs/interface_fase0_20261008.md` |
| `02_recontagens_fase0.R` | 7e99bf94 | 7e99bf94 | `logs/recontagens_fase0_20261008.md` |
| `03_autoauditoria_fase0.R` | 7e99bf94 | 7e99bf94 | `logs/autoauditoria_fase0_20261008.md` (C8) |

O git da base (`dados_artigos_perinatais_clima`) segue no commit `9f1957bcb8b71fd08a48a873cf659296b9eaa95b`, com `git status` limpo: nada foi escrito na base.

**Parei aqui. A Parte B só começa quando Guilherme escrever "PARTE B LIBERADA".**
