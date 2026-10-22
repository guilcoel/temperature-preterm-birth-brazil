# Fase 2 do Artigo 1: autoauditoria completa por código (Partes A, B e C publicadas)

- **Gerado por:** `00_scripts/39_auditoria_completa_fase2.R`, em 2026-10-11 09:31:11 -03. Rodada `20261011`. `versao()` no início = 4443971b (o fim está na última linha).
- **Ambiente:** R 4.5.1; dlnm 2.4.10; gnm 1.1.5. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib`.
- **HEAD local:** `65d025be9c6ed75c06bae3af4114ff0725dcce06`. **main remoto** (ls-remote): `11ba434edfaff406a6f8e184f6c2ac1a49919e46`.
- **1ª rodada deste script** (log SHA-256 `f8fff13cf67ed971e151da86137c76b847b28d97e1ddbc5438be33b093fc332d`, na lixeira): 19 de 21, com 2 falsos positivos da própria checagem. (i) Os "scripts que não existem" eram scripts dos Artigos 2 e 3 listados na seção `git status` das RESPOSTAs; a checagem passou a ler só a seção "Comandos para reproduzir". (ii) O "padrão proibido" no log de desvios eram menções ao nome da função `nascimentos()` e da coluna `id_nasc` nos desvios 2, 4, 10 e 45 (Fases 0 e 1), nomes e não dados; a varredura desse arquivo passou a cobrir só as linhas da Fase 2 (51 em diante).
- **Escopo:** git e remoto, tag, baterias de teste, reprodução exata da Parte C, coerência dos SHA-256 citados, desvios, ambiente e sigilo. Só leitura; o único acesso à rede foi um `git ls-remote`.

## Resultado: 21 de 21 conferências ok

| Bloco | Conferência | Resultado | Detalhe |
|---|---|---|---|
| A. git | main remoto é o 11ba434 ou descende dele | ok | main remoto: 11ba434 |
| A. git | tag ajusta_dlnm-v1.0: objeto igual no remoto e no local (344899ab…), apontando para o caf5022 | ok |  |
| A. git | tag do congelamento igual no remoto e no local | ok |  |
| A. git | codigo_compartilhado/R/ no HEAD e no disco = tag | ok |  |
| A. git | os 3 commits da Fase 2 só tocam artigo1_prematuridade/ e codigo_compartilhado/ | ok | 29 arquivos |
| A. git | nenhum arquivo de dado rastreado em artigo1_prematuridade/ ou codigo_compartilhado/ | ok |  |
| A. git | nada pendente em artigo1_prematuridade/ e codigo_compartilhado/ (fora este script) | ok |  |
| B. tag | SHA-256 da mensagem da tag = arquivos de R/ e tests/ no disco | ok | 8 de 8 |
| C. testes | ajusta_dlnm 19/20, só o t05b, com a mensagem "cobertura 0.985 fora de 0,92–0,98" | ok | 19/20 |
| C. testes | offset 21/21 | ok | 21/21 |
| D. Parte C | os 26 ajustes refeitos com a função da tag são idênticos (identical) aos da RDS do 32 | ok | 26 de 26 |
| E. desvios | numeração contínua de 1 ao último, sem repetição | ok | 1 a 66 |
| E. desvios | linhas 51 em diante com as 9 colunas | ok | 16 linhas |
| E. SHA citados | SHA-256 dos logs que valem, citados nas auditorias A, B e C = arquivos atuais | ok | 6 de 6 |
| E. SHA citados | SHA-256 das 5 saídas da Parte C = os do log do 32 | ok |  |
| E. RESPOSTAs | SHA-256 das RESPOSTAs A e C = os informados, e o disco = o commitado (HEAD) | ok |  |
| E. RESPOSTAs | os scripts da seção "Comandos para reproduzir" das RESPOSTAs existem | ok | 4 scripts |
| E. logs | versao() 4443971b no início e no fim dos logs gerados por script na Fase 2 | ok | 7 de 7 |
| F. ambiente | R 4.5.1; dlnm e gnm iguais aos do renv.lock; BLAS/LAPACK de referência | ok | dlnm 2.4.10 (lock 2.4.10); gnm 1.1.5 (lock 1.1-5) |
| G. sigilo | nenhum padrão proibido (id_nasc, microdado, token, senha) nos arquivos commitados da Fase 2 | ok |  |
| G. sigilo | nenhum arquivo commitado da Fase 2 acima de 1 MB | ok | 27 arquivos |

`versao()` no fim: 4443971b.
