# A3.6: consulta da origem da `attrdl` antes do download

- **Data:** 2026-10-08, cerca de 15:15 (America/Sao_Paulo).
- **O que foi feito:** só consulta de metadados pela API do GitHub. O conteúdo do arquivo **não** foi baixado: a API de árvore (`git/trees`) devolve o SHA e o tamanho do blob, sem o conteúdo.
- **Estado:** **download pendente do ok de Guilherme.** Depois do ok, o arquivo vai, sem alterar uma linha, para `codigo_compartilhado/inst/terceiros/attrdl.R`, e a origem fica em `logs/attrdl_origem.md` (caminho, URL, SHA do commit, data e SHA-256).

## Saídas

```
$ gh auth status
  ✓ Logged in to github.com account guilcoel (keyring)
  - Active account: true

$ gh api "repos/gasparrini/2014_gasparrini_BMCmrm_Rcodedata/commits?path=attrdl.R&per_page=5" --jq '.[] | [.sha, .commit.committer.date, (.commit.message|split("\n")[0])] | @tsv'
e629be7809853f390d305d8e73ac4b152a54f092	2022-04-02T12:59:42Z	Fix issue in attrdl with clogit
9fbabb090fad73c0d303b2ac4dbe385fe71a5273	2017-01-25T14:31:29Z	Revision of previous commit
dae1ccb8929fcec5b3ba2c73636577309323c46f	2017-01-25T14:27:40Z	Minor fix in commented out CI approach
173b100a55ec2acf9320b3a58b4e7a6d107e45db	2017-01-24T19:21:15Z	Fix error for computation CI in attrdl
8435f11e0c7f416ed6bb3031f47630a0896188fb	2017-01-11T20:35:33Z	Revise the function attrdl

$ gh api "repos/gasparrini/2014_gasparrini_BMCmrm_Rcodedata/git/trees/e629be7809853f390d305d8e73ac4b152a54f092" --jq '.tree[] | select(.path=="attrdl.R") | [.path, .type, .sha, .size] | @tsv'
attrdl.R	blob	bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a	7411

$ gh api "repos/gasparrini/2014_gasparrini_BMCmrm_Rcodedata" --jq '[.default_branch, .pushed_at] | @tsv'
master	2025-04-16T09:14:56Z
```

## O que será baixado, com o ok

- **Commit:** `e629be7809853f390d305d8e73ac4b152a54f092`, de 2022-04-02, o último que mexeu na `attrdl.R` ("Fix issue in attrdl with clogit").
- **URL fixada no commit:** `https://raw.githubusercontent.com/gasparrini/2014_gasparrini_BMCmrm_Rcodedata/e629be7809853f390d305d8e73ac4b152a54f092/attrdl.R`
- **Tamanho:** 7.411 bytes. **SHA-1 do blob no git:** `bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a`.
- **Conferência depois do download:** `git hash-object` do arquivo baixado tem de dar o SHA-1 do blob acima; o SHA-256 é registrado em `attrdl_origem.md`.

## Atualização: download feito (2026-10-08)

O download foi feito com o ok de Guilherme, pelo `ferramentas/baixa_attrdl.R`. Tamanho e SHA-1 do blob bateram, e o SHA-256 é `d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d`.

A origem não ficou em `logs/attrdl_origem.md`, como dizia a seção acima, e sim em `codigo_compartilhado/inst/terceiros/ORIGEM.md`, a pedido do chat. O repositório de origem não tem licença, e por isso o `attrdl.R` fica fora do git.
