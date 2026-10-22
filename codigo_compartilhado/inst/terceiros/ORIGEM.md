# Origem dos arquivos de terceiros

## `attrdl.R`

- **O que é:** a função `attrdl()`, de Antonio Gasparrini, para frações e números atribuíveis a partir de um DLNM. Não faz parte do pacote `dlnm`.
- **Repositório de origem:** https://github.com/gasparrini/2014_gasparrini_BMCmrm_Rcodedata. É público e **não tem licença**: `gh api repos/gasparrini/2014_gasparrini_BMCmrm_Rcodedata/license` devolveu HTTP 404, e o campo `license` do repositório é `null`.
- **Commit fixado:** `e629be7809853f390d305d8e73ac4b152a54f092`, de 2022-04-02T12:59:42Z ("Fix issue in attrdl with clogit"). É o último commit que mexeu no arquivo.
- **URL baixada:** https://raw.githubusercontent.com/gasparrini/2014_gasparrini_BMCmrm_Rcodedata/e629be7809853f390d305d8e73ac4b152a54f092/attrdl.R
- **Baixado em:** 2026-10-08, pelo `ferramentas/baixa_attrdl.R`, com o ok de Guilherme. Gravado sem alteração em `codigo_compartilhado/inst/terceiros/attrdl.R`.
- **Conferência:**

  | Item | Esperado (API do GitHub) | Obtido |
  |---|---|---|
  | Tamanho | 7.411 bytes | 7.411 bytes |
  | SHA-1 do blob (`git hash-object --no-filters`) | `bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a` | `bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a` |
  | SHA-256 | — | `d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d` |

- **Fora do git:** como o repositório de origem não tem licença, o `attrdl.R` não é redistribuído. A regra `!/codigo_compartilhado/inst/terceiros/*.R` saiu do `.gitignore`. O caminho reprodutível é `Rscript ferramentas/baixa_attrdl.R`, rodado da raiz de `artigos_perinatais_clima/`: o script baixa o arquivo e confere tamanho, SHA-1 e SHA-256.
- **Simulações:**
  - o padrão da função é `nsim = 5000` (`attrdl.R`, linha 39: `sim=FALSE,nsim=5000`);
  - a especificação v2.0.2, §7, exige "eCI com 1.000 simulações e semente fixa";
  - toda chamada usa `nsim = 1000` explícito, com a semente da especificação, e nunca o padrão.
- **Outras notas da §7:**
  - perspectiva `dir = "back"`;
  - no PIG, a ligação logit é tratada como RR (AF = 1 − exp(−β·x)), o que deve ser declarado.
