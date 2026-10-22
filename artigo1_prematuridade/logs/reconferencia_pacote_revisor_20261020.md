# Reconferência do pacote anônimo do revisor (Artigo 1), em contexto limpo

- **Data:** 2026-10-20, 11:19 a 11:32 −03:00 (hora lida com `date`).
- **Objeto:** `artigo1_prematuridade/Submissao/pacote_revisor_anonimo.zip`, 939.718 bytes.
- **SHA-256 do zip:** `619a957a0e1b076db86f57d1f28abb501e53f366efb3f5999f58ba1307445f3d`, igual ao esperado (conferido no início e no fim).
- **Extração:** só no scratchpad da sessão (`reconf_pacote/`). Nada foi extraído em `Submissao/`.
- **Escopo:** só leitura. Sem rede, sem git de escrita, sem abrir a pasta de dados. O único arquivo gravado fora do scratchpad é este log.
- **Regra deste log:** nenhum nome de pessoa encontrado é reproduzido aqui. Cada achado traz arquivo, linha e tipo.

## 1. Entradas do zip

- 130 entradas, todas sob `reviewer_package/`. O zip não tem comentário, nenhuma entrada tem *extra field* (uid/gid, carimbos de hora), e todas as datas estão normalizadas em 1980-01-01.
- Nenhum `._*`, `__MACOSX` ou `.DS_Store`. Nenhum `.parquet`, `.dbc`, `.rds`, `.RData`, `.docx`, `.pdf`, `.png` ou figura.
- Um único `.csv`: `codigo_compartilhado/dados_referencia/feriados_locais_nucleo_2011_2024.csv`, a tabela pública de feriados (1.178 linhas e 8 colunas). A coluna `conferido_por` só traz "subagente pesquisa B2…", sem nomes.
- Conteúdo: README do pacote, 83 scripts (`00_scripts/`), o log de desvios, `package_versions.md`, `codigo_compartilhado/` (R/, tests/, DESCRIPTION, ORIGEM.md, dados_referencia/) e 19 documentos de `spec/`.

## 2. Métodos, independentes da lista do script 92

Cada método foi um script próprio, rodado no scratchpad com `python3 -I`:

1. **Papéis.** Linhas com responsável, orientador, colaborador, autor/author, PI, advisor, supervisor, professor/Prof/Dr, aluno, mestrando, doutorando, CRediT, agradecimentos, "aprovado por", "ok de", "pedido de", "mensagem de", e o que vem depois delas.
2. **Sequências de palavras capitalizadas.** Todas as 274 sequências de duas ou mais palavras com inicial maiúscula foram revistas uma a uma.
3. **Nomes próprios candidatos.** As 581 palavras capitalizadas cuja forma minúscula nunca aparece no pacote foram revistas, e cada sobrenome possível foi conferido no contexto.
4. **Prenomes brasileiros comuns.** Busca de cerca de 300 prenomes frequentes, inclusive os que também são palavras comuns.
5. **Tokens em caixa alta.** Os 695 tokens distintos foram revistos (siglas, variáveis, nomes em maiúsculas).
6. **Instituições e vínculos.** Universidade, faculdade, instituto, hospital, departamento, programa, PPG, pós-graduação, mestrado e doutorado; CEP, Conep, CAAE e parecer; CNPq, CAPES e FAP*; bolsa, grant e financiamento; Lattes, ORCID, Zenodo, OSF, figshare e dataverse; siglas de universidades; termos próprios de unidades acadêmicas.
7. **Rastros técnicos.** E-mails, `@usuário`, URLs (agrupadas por domínio), DOIs, caminhos locais (`/Users`, `/Volumes`, `/home`, `~/`, `C:\`), nomes de máquina e de disco, `.local`, *tokens* e chaves, caracteres ocultos (categorias Unicode Cf/Co/Cn e controles) e blocos tipo base64 com 100 ou mais caracteres.
8. **Chats, sessões e ferramentas.** Todas as construções "chat/sessão/projeto/subagente/auditor + complemento".
9. **Contexto dos marcadores.** Contextos únicos de `[redacted]`, `[program]`, `[data repository]`, `[email]`, `[repository]` e `[path]`. Também: marcadores colados a letras (troca parcial de palavra), marcadores ao lado de texto de citação, pronomes e artigos de gênero junto de `[author]`, e `[commit]` fora de contexto de git.
10. **Identificadores hexadecimais que sobraram** (7 a 40 caracteres), separados dos SHA-256 de 64 caracteres.

**Conferência complementar, não usada como método principal:** os padrões de troca e de varredura do próprio `92_pacote_submissao_m5_fase4.py` (linhas 289 a 299) foram aplicados ao pacote extraído e deram **0 ocorrências**. Isso confirma que o Crítico e o Maior da 1ª versão não voltaram.

**Limite:** o hook `block-protected-paths` barrou uma busca que continha o nome de uma pasta protegida da Forja. Ela não foi refeita nem contornada. O prenome de terceiro associado a outra pasta protegida foi buscado e deu 0.

## 3. Achados

| # | Gravidade | Arquivo e linha | Tipo | Correção sugerida |
|---|---|---|---|---|
| 1 | **Menor** | `artigo1_prematuridade/00_scripts/91_docx_m4_fase4.py:313` | **Resto do nome do repositório.** O prefixo sem o sufixo final continua na lista `CEGO` (conferência de cegamento do manuscrito). A regra "repositório" do 92 (linha 297) só troca o nome completo, e a varredura (linha 299) não inclui o prefixo. Isso contradiz o README do pacote ("the repository name by [repository]"). Com o repositório privado, não identifica. Se ele ficar público durante a revisão, uma busca pelo nome leva à conta. | Trocar o item por `[repository]`. No 92, a regra e a varredura devem pegar também o prefixo (radical do nome do repositório). Gerar a v3 do zip. |
| 2 | Nota | `spec/especificacao_dlnm_canonica_v2_0_2.md:5` | Linha de papéis preservada com marcadores. Mostra a estrutura da equipe (responsável, orientador, colaborador) e quantas palavras tem cada nome. Não identifica. | Opcional: trocar a linha inteira por "[author information removed for review]". |
| 3 | Nota | `README_reviewer_package.md:13`; `spec/decisoes_metodo_20261008.md:57` e `spec/especificacao_dlnm_canonica_v2_0_2.md:501` ("PPG" por extenso na sigla); `spec/especificacao_dlnm_canonica_v2_0_2.md:500` e `:607`, `spec/decisoes_metodo_20261008.md:60` (`[program]`) | Pistas de contexto. "Institutional data repository", "degree program", "PPG" e "Orientador" indicam trabalho de pós-graduação numa instituição com repositório de dados próprio. O conjunto estreita o perfil, mas não aponta a instituição. | Opcional: README genérico ("identifying names, institutions and repositories were replaced by bracketed placeholders") e "PPG" → `[program]`. |
| 4 | Nota | `artigo1_prematuridade/00_scripts/34_resposta_fase2A.R:99` ("ajustes dele"); `artigo1_prematuridade/logs/desvios_especificacao.md:125` ("operados por ele"); `artigo1_prematuridade/00_scripts/26_resposta_fase1.R:102` e `desvios_especificacao.md:59` ("ao [author]"); `spec/especificacao_dlnm_canonica_v2_0_2.md:614` ("o [author]"); `spec/decisoes_metodo_20261015_TODOS_D10_concordancia_coordenacao_git.md:96` ("por ele") | Gênero do autor responsável. | Sem ação necessária. Neutralizar, se quiser. |
| 5 | Nota | `desvios_especificacao.md:22` e `00_scripts/06_entrada_rerun.R:5` (commits curtos do repositório da base de dados); `desvios_especificacao.md:47`, `:79`, `:96`, `:97`, `:99`, `:127`, `:131` (SHA-1 de objetos de tag, completos ou prefixos) | Identificadores de git que não foram trocados, porque não são commits do repositório do código ou são objetos de tag. Só ligam a um repositório que fique público. | Por coerência com o README, trocar por `[commit]` na próxima versão. Não bloqueia com os repositórios privados. |
| 6 | Nota | Pacote inteiro: SHA-256 de documentos e dados, nomes de tag, nome do pacote R (`codigo_compartilhado/DESCRIPTION:1`), "Projeto DLNM Perinatal" (`spec/especificacao_dlnm_canonica_v2_0_2.md:3`) | Impressões digitais únicas. Permitem achar qualquer cópia pública do projeto: GitHub público, depósito com autoria no `[data repository]`, suplemento de preprint dos artigos irmãos. | Manter o repositório privado e não depositar até a decisão editorial, como já registra a A1-140 (`desvios_especificacao.md:152`: "manter o repositório privado até o aceite"). O link anônimo deve servir só este zip. |
| 7 | Nota | `desvios_especificacao.md:150` e `:152` | O próprio log de desvios descreve a anonimização e o vazamento da 1ª versão, inclusive as linhas onde estavam os nomes. Ficou ainda o artefato `(com "")`, resto da troca do título acadêmico. | Sem ação: é registro e não identifica. |
| 8 | Nota | `desvios_especificacao.md:62`, `:63`, `:79`; `00_scripts/26_resposta_fase1.R:102`; `00_scripts/62_testes_sens_agudos.R:142` | Modelo de computador (Mac Mini, MacBook). O nome do disco já está como `[redacted]`. Não há *hostname*, usuário nem caminho. | Sem ação. |
| 9 | Nota | `codigo_compartilhado/dados_referencia/README.md:266`, `:301`, `:328`; URLs de universidades no README e no CSV dos feriados | Universidades citadas como **fonte** de feriados (calendários e portarias), não como vínculo. | Sem ação. |
| 10 | Nota | Listas de referências (por exemplo, `spec/especificacao_dlnm_canonica_v2_0_2.md:896–947`) e chaves `@Autor2026` nos scripts 90 e 91 | Autores de artigos citados são públicos. Nenhum coincide com os nomes da equipe; a conferência complementar da seção 2 deu 0. Não há autocitação em primeira pessoa ("our previous", "nosso grupo"). | Sem ação. |

**Sem achado (0 ocorrências):**

- nomes da equipe ou de terceiros privados, por qualquer dos métodos; os nomes próprios que aparecem são de autores de referências públicas, figuras históricas, santos ou lugares;
- e-mails (só o marcador `[email]`);
- caminhos locais, usuários, *hostnames* e nomes de disco;
- *tokens* e chaves (só os padrões de busca do `checa_sigilo`);
- número de CAAE, de parecer, de bolsa ou de financiador (só menções genéricas a CEP e CAAE);
- sigla ou nome da instituição de vínculo, da faculdade ou do programa;
- OSF, DOI ou URL que leve ao projeto (o DOI segue como "XXXXXXXXXXXXX");
- nomes de chat ou de sessão com nome de pessoa (são "chat de métodos", "chat do Artigo 1", "COORD", "A1/A2/A3" e "subagente");
- caracteres ocultos e blocos codificados;
- marcadores colados a letras, que indicariam troca parcial de palavra;
- `[commit]` em contexto que não seja de git.

## 4. Os marcadores deixam pistas por contexto?

- **`[author]`** (372 ocorrências): aparece em contexto de processo (aprovações, decisões, mensagens). As pistas que sobram são o gênero (achado 4) e a estrutura da equipe na linha 5 da especificação (achado 2). Não há nome parcial, inicial, título nem citação.
- **`[redacted]`** (163): faz três papéis. O disco ("na [redacted]", "exFAT da [redacted]"), a conta do GitHub (`repos/[redacted]/…`) e a afiliação do cabeçalho (`([redacted], [redacted]/[redacted])`, formato unidade, instituição/UF). O formato não revela o conteúdo.
- **`[program]`, `[data repository]` e PPG:** o README e o contexto indicam pós-graduação numa instituição com repositório de dados próprio (achado 3). Não apontam qual.
- **`[repository]` e `[path]`:** sem resto de caminho, salvo o prefixo do achado 1. O padrão `dados_[repository]/` só revela que a pasta de dados tem o nome do repositório com o prefixo "dados_".
- **`[commit]`** (1.226): só em contexto de git. Os objetos de tag e os commits da base de dados não foram trocados (achado 5).

## 5. Veredito

**O pacote pode ir a um link anônimo de revisores.** Nenhum método achou nome de pessoa, instituição, programa, cidade de vínculo, e-mail, caminho, usuário ou número de ética ou de bolsa. A única troca recomendada é a Menor do achado 1, de uma linha (`91_docx_m4_fase4.py:313`, mais a regra e a varredura do 92). Ela não identifica enquanto o repositório for privado, mas convém corrigi-la ao gerar a v3 do zip. As Notas 2, 3 e 5 são opcionais. A Nota 6 é condição externa: repositório privado e nenhum depósito com autoria até a decisão.

## 6. Resumo (até 20 linhas)

1. O SHA-256 do zip confere com o esperado. São 130 entradas, sem `._*` nem `__MACOSX`, sem dados além da tabela pública de feriados e sem saídas, figuras ou `.docx`.
2. O zip não tem comentário nem *extra fields*, e as datas estão normalizadas em 1980.
3. Foram 10 métodos independentes da lista do 92: papéis, sequências capitalizadas, nomes próprios candidatos, prenomes, caixa alta, instituições, rastros técnicos, chats e sessões, contexto dos marcadores e hexadecimais que sobraram.
4. **0 Crítico e 0 Maior.**
5. **1 Menor:** `91_docx_m4_fase4.py:313` ainda traz o prefixo do nome do repositório na lista de cegamento. A regra do 92 só troca o nome completo. Trocar por `[repository]` e ampliar regra e varredura.
6. **9 Notas.** Linha de papéis da especificação (l. 5) com estrutura da equipe; pistas de pós-graduação e de repositório institucional; gênero do autor; objetos de tag e commits da base sem troca; impressões digitais únicas (hashes, tags, nome do projeto); o log de desvios descreve a anonimização; modelo de computador; universidades citadas só como fonte de feriados; referências públicas.
7. A conferência complementar com os padrões do próprio 92 deu 0: os nomes da 1ª versão não voltaram.
8. Veredito: **pode ir ao link anônimo**. Corrigir a Menor ao gerar a v3, manter o repositório privado e não depositar no `[data repository]` até a decisão.
9. Rascunhos (listas e contextos) ficaram só no scratchpad da sessão. Nada foi gravado em `Submissao/` nem no git.
