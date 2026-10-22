# Decisões de método — 16/10/2026, D15: metapreditores exploratórios (§6)

**De:** chat de métodos · **Data:** 16/10/2026 · **Origem:** pedido do chat do Artigo 3 (15/10), item 5, sem bloqueio
**Âmbito:** os três artigos. Nenhum documento anterior (D1 a D14) definia esses metapreditores; o A1 e o A2 não receberam definição.
**Ler junto com:** §6 da v2.0.2 ("Metapreditores exploratórios, em análise separada e rotulada como tal") e D14 (itens do A3).

**Rótulo:** escolha *post hoc* (lacuna de definição), nos três artigos. Os três já viram o primário. As definições abaixo usam só contagens do SINASC e dados do IBGE e do Atlas, sem temperatura nem desfecho modelado. **Rótulo condicional:** cada artigo declara no log, antes de registrar a D15, se já rodou ou viu alguma meta-regressão exploratória; se viu, a D15 vale para ele como *post hoc* depois dessa saída, e o log diz qual.

---

## Resumo

| Metapreditor | Definição | Fonte e período |
|---|---|---|
| % de cesárea | NV únicos de 22+0 a 42+6 com `parto` = 2 ÷ NV com `parto` ∈ {1, 2}, por concentração | SINASC das 26 concentrações, 2012–2024, um valor por concentração |
| Cobertura de pré-natal | NV únicos de 22+0 a 42+6 com `CONSULTAS` = 4 (7 ou mais consultas) ÷ NV com `CONSULTAS` ∈ {1, 2, 3, 4} (nome da coluna na base conforme o `DICIONARIO.md`) | Idem |
| IDHM | Média do IDHM municipal ponderada pela população do Censo 2010, nos municípios da concentração | Atlas do Desenvolvimento Humano no Brasil, IDHM 2010 (base Censo 2010) |
| Macrorregião | As 5 grandes regiões do IBGE, como no multinível da §6 | IBGE |

---

## 1. % de cesárea e cobertura de pré-natal

- **Fonte:** o próprio SINASC da base, pela interface (`nascimentos()`), nas 26 concentrações, por município de residência da mãe.
- **População (comum aos três artigos):** NV únicos (`GRAVIDEZ` = 1) de 22+0 a 42+6 semanas, residentes na concentração, nascidos de 2012-01-01 a 2024-12-31.
  - É a mesma população para os três artigos, para que o metapreditor seja o mesmo, como os metapreditores principais (§6).
  - Sem coorte fixa: o metapreditor descreve a concentração, não entra no modelo de desfecho, e a coorte fixa só mexe nas bordas.
- **% de cesárea:** `parto` = 2 sobre `parto` ∈ {1, 2}. O ignorado (9 ou vazio) sai do denominador e é reportado por concentração.
  - A coluna está acessível por `nascimentos()`, com nome em minúsculas: a pendência 4 da §10.3 foi fechada em 08/10 (decisões de 08/10, errata E5 e l. 133; códigos da §3.4 conferidos na A4 do Artigo 1).
- **Cobertura de pré-natal:** `CONSULTAS` = 4 ("7 e mais") sobre `CONSULTAS` ∈ {1, 2, 3, 4}. O ignorado sai do denominador e é reportado.
  - Usa-se `CONSULTAS` (faixas: 1 = nenhuma, 2 = 1 a 3, 3 = 4 a 6, 4 = 7 e mais, 9 = ignorado), e não o número de consultas `CONSPRENAT`. É o indicador usual de "7 ou mais consultas". **Os códigos vêm do dicionário do SINASC, não foram conferidos na base:** antes de usar, o Claude Code reporta a distribuição de `CONSULTAS` por ano (só contagens, com o sigilo de sempre) e confirma que os códigos e a completude são estáveis em 2012–2024.
  - Se a coluna não estiver acessível pela interface, o Claude Code para e informa, sem trocar por `CONSPRENAT` (seria versão nova da base, a autorizar).
- **Um valor por concentração:** a proporção agregada de 2012 a 2024 (soma dos numeradores ÷ soma dos denominadores), não a média das proporções anuais.
- **No PIG:** as consultas de pré-natal ficam fora do modelo de desfecho por serem potencial mediador (§3.3). Como metapreditor, a cobertura descreve o sistema de saúde da concentração e entra só na meta-regressão exploratória. Declarar a diferença.

## 2. IDHM

- **Fonte:** IDHM municipal 2010 do Atlas do Desenvolvimento Humano no Brasil (PNUD, Ipea e Fundação João Pinheiro), base Censo 2010.
- **Agregação:** média dos IDHM dos municípios da concentração, ponderada pela população residente do Censo 2010 de cada município.
  - **Declarar:** o IDHM é uma média geométrica de três índices, e a média ponderada dos valores municipais é uma aproximação. O IDHM de uma região metropolitana publicado pelo Atlas é calculado de outro modo e não cobre o recorte das concentrações.
  - Manaus e Campo Grande (município isolado) usam o IDHM do próprio município.
- **Por que 2010, e não uma edição mais recente:**
  - o ano casa com a base das concentrações (Arranjos Populacionais do IBGE, 2ª ed., base Censo 2010; §5);
  - fixar o ano agora tira a escolha da edição de qualquer dependência de resultado;
  - **não confirmei** se já existe IDHM municipal com base no Censo 2022. Se existir, ele não substitui o de 2010 nesta análise, e o texto declara que o IDHM é anterior ao período de estudo.
- A versão do arquivo baixado do Atlas e o seu SHA-256 entram no log.

## 3. Como entram no modelo

- **Um de cada vez** (§6), **somado aos metapreditores principais** (média e amplitude da `tmean_nucleo`), para que o ajuste climático seja o mesmo do principal.
- Contínuos (% de cesárea, cobertura e IDHM), **centrados na média das 26**.
- **Reportar:** o Wald do metapreditor exploratório, com gl = dimensão reduzida da análise (4 no principal; 3 se o passo 2 do *fallback* da D7, M7, tiver disparado), e o Q e o I² residuais com e sem ele (D6, 3.2).
- **Macrorregião:** categórica, com 5 níveis (4 indicadoras × dimensão reduzida = 16 parâmetros a mais no principal; 12 com o passo 2). Com 26 concentrações e 2 na região Norte, a estimativa fica instável. Ela entra mesmo assim, porque está na letra da §6, com a instabilidade declarada.
- **Estabilidade e falha do `mixmeta`:** as regras da §6 (Ψ não estruturada; se não convergir, Ψ diagonal; depois, ML) e da C3, registradas por modelo exploratório. Se nenhuma convergir, o metapreditor é reportado como não estimável.
- **Natureza:** exploratória e rotulada como tal (§6), sem valor de P interpretado como confirmatório.

---

## Registro no log (A1, A2 e A3; antes de rodar a meta-regressão exploratória)

> - **D15 (16/10):** `spec/decisoes_metodo_20261016_TODOS_D15_metapreditores_exploratorios.md` (SHA-256 ⟨conferido⟩). Escolha *post hoc* (lacuna), depois do primário e antes da meta-regressão exploratória.
>   - Meta-regressão exploratória já vista antes deste registro: ⟨nenhuma / listar⟩.
>   - % de cesárea (`parto`) e cobertura de pré-natal (`CONSULTAS` = 4, distribuição por ano conferida): SINASC, NV únicos 22–42, 2012–2024, proporção agregada por concentração, ignorados fora do denominador e reportados.
>   - IDHM 2010 (Atlas, Censo 2010), média municipal ponderada pela população de 2010; arquivo e SHA: ⟨…⟩.
>   - Um de cada vez, somado à média e à amplitude; centrado; Wald (gl = dimensão reduzida) e Q/I² residuais; estabilidade pela §6 e C3. Macrorregião com 4 × a dimensão, instável, declarada.

---

## A. Auditoria

### A.1 Autoauditoria

| Ponto | Conferência | Resultado |
|---|---|---|
| A §6 lista os quatro metapreditores, um de cada vez | Leitura da v2.0.2, §6 | Confirmado |
| Nenhuma decisão anterior os definia | Busca por "IDHM", "cesárea" e "pré-natal" nas D1 a D14 e nas decisões de 08/10 | Nenhuma ocorrência de definição |
| `parto` acessível por `nascimentos()` | Decisões de 08/10 (R2 final), E5 e l. 133 | Pendência 4 fechada em 08/10 |
| O PIG exclui consultas do modelo de desfecho | §3.3, "Consultas de pré-natal não entram" | Confirmado |
| Arranjos do IBGE com base no Censo 2010 | §5 | Confirmado |
| Existência de IDHM municipal com base no Censo 2022 | Duas buscas na web | **Não confirmada nem descartada**; declarada |

### A.2 Auditoria independente

O auditor (subagente em contexto limpo, script próprio `aud_d14_indep.py`, SHA-256 `ae7f0450c1a8ea6d918c30438449bb1c4331ee4de60575444fe1a59334a1b581`, que não abriu o script do autor) leu o pedido, a v2.0.2, as decisões de 08/10 e as D1 a D13, e conferiu as fontes do `mgcv`, do `dlnm`, do `gigs` e do `sandwich`. Nenhum achado crítico; 6 Maiores, 8 Menores e 6 Notas na D14 e na D15. Cada achado foi conferido por mim (código ou leitura das fontes) antes de ser aceito; um foi rejeitado e um aceito em parte.

| Achado | Grav. | Minha conferência | Correção |
|---|---|---|---|
| 1. "Nenhum rodou a meta-regressão exploratória" não foi conferido no A1 e no A2 | Maior | Leitura | Rótulo condicional por artigo |
| 11. A pendência 4 (`PARTO` acessível) estaria aberta | Menor | **Rejeitado:** a pendência 4 foi fechada em 08/10 (decisões de 08/10, E5 e l. 133); nome `parto` em minúsculas | Citação acrescentada e nome corrigido para `parto` |
| 12. "`CONSULTAS` em todos os anos, com o mesmo código" apresentado como verificado | Menor | Os códigos vêm do dicionário, não da base | Distribuição por ano conferida antes de usar |
| 13. gl fixos em 4 e 16; sem regra de estabilidade | Menor | D7, M3.3 ("gl segundo a dimensão"); §6 | gl = dimensão reduzida; §6 e C3 |
| 14. Índice sem a D14 e a D15 | Menor | Leitura | Índice, revisão 6, com as ordens de leitura |

**Não verificado:** a existência de IDHM municipal com base no Censo 2022.
