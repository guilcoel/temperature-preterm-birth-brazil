# Congelamento da especificação: tag `spec-v2.0.2-congelada-20261009`

- **Gravado em:** 2026-10-09 17:20 -0300, na Fase 0 do Artigo 1, Parte B, passo B7.
- **Cópia:** `artigo1_prematuridade/logs/congelamento_spec.md`, idêntica a este arquivo.

## Identificação

| Item | Valor |
|---|---|
| Repositório | `guilcoel/artigos_perinatais_clima`, privado (`https://github.com/guilcoel/artigos_perinatais_clima`), criado em 2026-10-09T19:19:36Z |
| Commit congelado (hash completo) | `86069e5a8d1d67d0b8e02c9a45d533f91644fcc4` (2026-10-09 16:07:32 -0300) |
| Árvore do commit | `18feda4a8425d39c84f132ced58688b3352be6f0` |
| Tag | `spec-v2.0.2-congelada-20261009`, anotada |
| Hash do objeto da tag | `9f92398978db61ca1006dcf5d1195a4adc6bd94c` (tagger 2026-10-09 16:16:11 -0300) |
| Versão da base | `4443971b`: `versao()` conferida em 2026-10-09 17:19 -0300, com R 4.5.1 |
| Prova durável | DOI (Zenodo ou REDU) na submissão, conforme as decisões de método, §1.1, item 6. O GitHub é só a prova de horário provisória |

## Manifesto (`spec/SHA256SUMS`, 853 bytes, SHA-256 `4e3fb5313b5481f0ce8f51c8904184cd25ba52d212243af781cfb39d7db4ee45`)

```
5e82663e1f8387710a1a861c298399a8816fa446ec247804c58f4c88bb6e4ee8  spec/RESPOSTA_artigo1_prematuridade_FASE0A_rerun_4443971b_20261009.md
62afa891f123da1e84bc71def238ccbb321681b83872eb2c267eac0e37cf030f  spec/decisoes_metodo_20261008.md
a30398496c2bad285a22a55e3bee67c6df1bbdd6439ad9f0f712c2b964a9ed04  spec/especificacao_dlnm_canonica_v2_0_2.md
6fc707ab268c94e00f92a470ba80b54bd9bc9785324e21ea3d8f246236f3e93a  docs/coordenacao/PROMPT_artigo1_prematuridade_FASE0A_rerun_20261008.md
549ea53a845c9d8a2a022300b68db4325373b97c703918820899c0e64fac55b3  docs/coordenacao/PROMPT_artigo1_prematuridade_FASE0_20261008.md
2f08e45173511104874580c5758bc029536bdc05b652f4b171203382a10a21aa  docs/coordenacao/RESPOSTA_chat_A1_ajustes_20261008.md
cb0422f421a1b6813b9bec0de1f5b1a4b5153147db90b8bc57869d4ec0257d85  docs/coordenacao/RESPOSTA_chat_A1_auditoria_20261008.md
```

- **B3.4:** os 7 SHA-256 foram recalculados sobre o conteúdo do commit (`git show HEAD:<caminho> | shasum -a 256`) e batem com o manifesto.
- **Mensagem da tag:** uma linha de título e, depois de uma linha em branco, o conteúdo exato do `spec/SHA256SUMS`, conferido com `cmp`.

## Confirmações do chat do Artigo 1 antes do commit

As decisões de método exigem, na §1.1, item 4, confirmações antes do commit. Elas estão em `artigo1_prematuridade/logs/confirmacoes_chat_A1_pre_commit_20261009.md`, gravado em 2026-10-09 16:03:39 -0300, com SHA-256 `363f987ca9c90ad568b87e348ad6d305eff2e9522827ec703df24961cf8bcfb9`. O arquivo cobre:
- a §6, condição 4: reconferência das tabelas A5.2 e A7;
- a nota de leitura da §11: conferência da tabela da §9 e dos campos da §11.

O arquivo entrou no commit congelado, como blob `f812b31719476f54526c9dab486e5942fcfd4d91`, e o SHA-256 no commit é igual ao do disco.

## Push (B5)

```
== B5.4: git push -u origin main
2026-10-09 16:20:09 -0300
To https://github.com/guilcoel/artigos_perinatais_clima.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
código: 0

== B5.5: git push origin spec-v2.0.2-congelada-20261009
2026-10-09 16:20:20 -0300
To https://github.com/guilcoel/artigos_perinatais_clima.git
 * [new tag]         spec-v2.0.2-congelada-20261009 -> spec-v2.0.2-congelada-20261009
código: 0
```

## Prova do horário (B6): as três saídas

As consultas foram feitas logo depois do push da tag, antes de qualquer outro push.

### 1. `git ls-remote --tags origin`

```
9f92398978db61ca1006dcf5d1195a4adc6bd94c	refs/tags/spec-v2.0.2-congelada-20261009
86069e5a8d1d67d0b8e02c9a45d533f91644fcc4	refs/tags/spec-v2.0.2-congelada-20261009^{}
```

O `git ls-remote origin` também mostra `refs/heads/main` e `HEAD` em `86069e5a8d1d67d0b8e02c9a45d533f91644fcc4`, iguais aos locais.

### 2. `gh api repos/guilcoel/artigos_perinatais_clima` → `pushed_at`

```
{"created_at":"2026-10-09T19:19:36Z","default_branch":"main","full_name":"guilcoel/artigos_perinatais_clima","private":true,"pushed_at":"2026-10-09T19:20:21Z","size":0,"updated_at":"2026-10-09T19:20:15Z","visibility":"private"}
```

O `pushed_at` (2026-10-09T19:20:21Z = 16:20:21 -0300) é o horário do push da tag, que foi o último push antes desta consulta.

### 3. `gh api repos/guilcoel/artigos_perinatais_clima/events` → `CreateEvent` com `ref_type = tag`: **pendente**

| Consulta (UTC) | Resultado |
|---|---|
| 2026-10-09T19:20:33Z | 0 eventos |
| 2026-10-09T19:21:13Z | 0 eventos |
| de 2026-10-09T19:21:30Z a 19:41:51Z | 0 eventos (consulta a cada 30 s, 40 tentativas) |
| 2026-10-09T20:17:30Z | 0 eventos (HTTP 200; `X-Poll-Interval: 60`). O feed da conta inteira (`users/guilcoel/events`) não tem nenhum evento depois de 2026-10-09T17:11:52Z, o que indica atraso do GitHub, não falha deste repositório |

**Decisão de Guilherme, em 09/10:** registrar o evento como pendente e seguir com a B7 e a B8. A consulta continua a cada 60 s. Quando o `CreateEvent` aparecer, a saída entra como linha nova neste log e no log de desvios, num commit posterior. O `pushed_at` acima já foi capturado antes de qualquer outro push (desvio nº 35).

### Complemento: objetos no servidor, conferidos contra os locais

```
-- gh api repos/guilcoel/artigos_perinatais_clima/git/ref/tags/spec-v2.0.2-congelada-20261009
{"object_sha":"9f92398978db61ca1006dcf5d1195a4adc6bd94c","object_type":"tag","ref":"refs/tags/spec-v2.0.2-congelada-20261009"}
-- gh api repos/guilcoel/artigos_perinatais_clima/git/tags/9f92398978db61ca1006dcf5d1195a4adc6bd94c
{"object_sha":"86069e5a8d1d67d0b8e02c9a45d533f91644fcc4","object_type":"commit","sha":"9f92398978db61ca1006dcf5d1195a4adc6bd94c","tag":"spec-v2.0.2-congelada-20261009","tagger_date":"2026-10-09T19:16:11Z"}
-- gh api repos/guilcoel/artigos_perinatais_clima/commits/main
{"author_date":"2026-10-09T19:07:32Z","committer_date":"2026-10-09T19:07:32Z","files":90,"sha":"86069e5a8d1d67d0b8e02c9a45d533f91644fcc4","tree":"18feda4a8425d39c84f132ced58688b3352be6f0"}
local tree: 18feda4a8425d39c84f132ced58688b3352be6f0
-- spec/SHA256SUMS no servidor (ref = tag)
4e3fb5313b5481f0ce8f51c8904184cd25ba52d212243af781cfb39d7db4ee45
local: 4e3fb5313b5481f0ce8f51c8904184cd25ba52d212243af781cfb39d7db4ee45
```

Mensagem da tag no servidor: 952 caracteres, idêntica à local. O byte a mais na saída é a quebra de linha que o `--jq` acrescenta.

## Adendo de 2026-10-09 (auditoria independente da Parte B; desvio nº 36)

- **O `pushed_at` foi sobrescrito.** O push da B8.3 (`86069e5..ec22aca`) levou o `pushed_at` para 2026-10-09T20:22:53Z. O valor de 19:20:21Z, registrado acima na B6, só continua neste log.
- **Prova de horário do servidor que não é sobrescrita: a API de atividade.** Ela vale para o commit congelado, não para a tag.

  ```
  gh api repos/guilcoel/artigos_perinatais_clima/activity  (consulta de 2026-10-09T20:45:04Z)
  {"activity_type":"push","actor":"guilcoel","after":"ec22acae2802f9db14c83215c4196c56dde27a95","before":"86069e5a8d1d67d0b8e02c9a45d533f91644fcc4","ref":"refs/heads/main","timestamp":"2026-10-09T20:22:53Z"}
  {"activity_type":"branch_creation","actor":"guilcoel","after":"86069e5a8d1d67d0b8e02c9a45d533f91644fcc4","before":"0000000000000000000000000000000000000000","ref":"refs/heads/main","timestamp":"2026-10-09T19:20:11Z"}
  gh api "repos/guilcoel/artigos_perinatais_clima/activity?ref=refs/tags/spec-v2.0.2-congelada-20261009" --jq length
  0
  ```

- **O `CreateEvent` da tag continua pendente:** 0 eventos às 20:45:04Z. Comparar com o feed da conta (`users/guilcoel/events`) não prova atraso geral, porque a única atividade da conta depois das 17:11:52Z foi neste repositório. O atraso é provável, não comprovado.
- **Tag e commits não são assinados** (`verification.verified = false`, motivo `unsigned`). As datas do tagger e do committer são declaradas pelo cliente. Até sair o DOI, só os registros do servidor provam o horário para terceiros.
- **No commit congelado, `CLAUDE.md` e cabeçalho do log estão desatualizados.** O `artigo1_prematuridade/CLAUDE.md` e o cabeçalho de `artigo1_prematuridade/logs/desvios_especificacao.md` ainda citam as decisões `20fc42e4…` e trazem a tag e o hash em branco. É assim por desenho: a liberação v1.2, §3, proibiu mudar arquivos do inventário antes do commit. **O que está congelado é só o que está em `spec/`** (B3.2), com o manifesto `spec/SHA256SUMS`. Os dois arquivos foram atualizados no commit seguinte, `ec22acae2802f9db14c83215c4196c56dde27a95`.

## Encerramento do `CreateEvent` (2026-10-09; desvios nº 35 e 38)

- A API de eventos do GitHub não lista nada deste repositório, nem os pushes da `main`. Todas as consultas deram 0 eventos; a última foi às 2026-10-09T21:40:32Z. A consulta em segundo plano foi encerrada às 21:40Z, por decisão do chat do Artigo 1.
- **A prova de horário no servidor é o `branch_creation`** de `refs/heads/main` em `86069e5a8d1d67d0b8e02c9a45d533f91644fcc4`, às 2026-10-09T19:20:11Z, no log de atividade (`GET /repos/guilcoel/artigos_perinatais_clima/activity`). A prova durável continua sendo o DOI na submissão.
