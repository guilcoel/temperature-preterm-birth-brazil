# Dupla auditoria do plano da Fase 0 refeita (base 4443971b), antes de executar

- **Quando:** de 2026-10-08, 22h, a 2026-10-09, 08h30, antes de qualquer passo da Parte A. Gravado depois da A1, para não entrar no inventário da Fase 0A.
- **Pedido de Guilherme:** "avalie criticamente com dupla auditoria estes passos" (o plano devolvido antes da execução).
- **Autoauditoria:** cada premissa do plano conferida com código, só lendo arquivos, mais dois testes sintéticos de `tar` (um no disco interno, um na Forja), em pastas temporárias que foram para o `trash`.
- **Auditoria independente:** subagente em contexto limpo, sem acesso à base fora de `09_acesso/` e do `RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md`. Não podia rodar script do projeto, ler `.parquet`, `.dbc`, `.rds` ou `.tar`, nem imprimir contagem de 1 a 9.
- **Regra:** nenhum achado aceito sem reprodução por código próprio, ou leitura direta do arquivo quando o achado é de desenho.

## Autoauditoria: achado → reprodução → correção

| # | Achado | Reprodução | Correção adotada |
|---|---|---|---|
| S1 | Datas misturadas: os nomes usam `Sys.Date()`, e a rodada passaria da meia-noite | `date`: 22h02; a data do sistema virou para 2026-10-09 durante a auditoria | Constante `FASE0_RERUN_DATA` (= `20261009`) em todo script; o script para se ela faltar |
| S2 | `._*` (AppleDouble do exFAT) no inventário e no `.tar` | `find`: 8 (`00_scripts`) + 16 (`logs`) + 6 (`fase0`). Teste na Forja: com `COPYFILE_DISABLE=1`, o `tar` inclui o `._*` e sai com erro ("Truncated input file") | Lista explícita sem `._*` e `.DS_Store`; `tar --no-xattrs --no-mac-metadata -T lista`; código 0; `tar -xOf \| shasum` = inventário (testado na Forja: código 0, SHA igual) |
| S3 | O script da A1 dentro de `00_scripts/` entraria no próprio inventário e no `.tar` | Desenho: o inventário cobre `00_scripts/` | Arquivador em `ferramentas/arquiva_fase0A_rerun.sh`, excluído pelo nome |
| S4 | A8 só com PTB | Desvio 9: a coluna "Perda" tem PTB e perinatal; a menor perda (40) é do perinatal | A8 nos dois desfechos |
| S5 | O `05_saidas_complemento_fase0A.sh` lê `fase0/` × regra "todo script passa a ler `fase0_rerun/`" | `grep`; o `05` não tem o literal do hash, e editá-lo quebraria a conferência final | O `05` fica intacto e nunca roda; isso vai declarado no RESPOSTA |
| S6 | A supressão pela "menor parte" pode deixar recuperável uma **soma** menor que 10 | Sintético: 3 + 5 = 8 = total − resto | Na A7, a soma das células escondidas de cada identidade é ≥ 10 |
| S7 | Registros e configuração da Fase 0A fora do inventário | `ls`: `logs/` da raiz, `docs/coordenacao/`, `renv.lock`, `.Rprofile`, `.Renviron` | Inventário maior que o pedido (= achado 16) |

## Auditoria independente: achado → reprodução → correção

| # | Grav. | Achado | Reprodução | Correção adotada |
|---|---|---|---|---|
| 1 | Alta | Script da A1 dentro de `00_scripts/` contamina inventário e `.tar`; nome do `.tar` com o literal | = S3 | = S3. O nome do `.tar` fica no arquivador, fora do escopo do `grep` da A2 |
| 2 | Alta | Proteção contra sobrescrita só por renomeação manual; virada de data; o `05` como armadilha | 7 logs da Fase 0A seriam sobrescritos (mesmos nomes de 2026-10-08). Já aconteceu: auditoria do complemento, achado 3 (o `03` sobrescreveu o log da Parte A às 17:39). Linha 13 do `05` | Trava `stopifnot(!file.exists())` antes de toda gravação; constante de data (S1); o `05` nunca roda |
| 3 | Alta | A8 sem o perinatal; fontes incompletas; pontas de 2012 e 2024 só somadas | = S4 | Fontes numeradas, com SHA-256; prova por identificabilidade linear de cada ponta |
| 4 | Alta | A7: o (a) do PTB já é público (o "Na janela" da A5.2), e o "% mantido" revela a diferença mascarada | Sintético: (a) = 14.000 e % = 99,95 → diferença 7, única | O (a) do PTB entra como célula publicada; "% mantido" vira "—" quando há máscara; prova por código |
| 5 | Média | CSV sem máscara da A7 legíveis pelo auditor | Log do complemento: o auditor "pôde ler … os CSV agregados" | Só gravar CSV já mascarados |
| 6 | Média | Reutilizar o `04` descumpre o prompt ("script novo"); falta a MM9 por concentração; comparar com o mesmo código é repetição | Linhas 73–78 do `04` (só MM14); linhas 87 e 90–91 do `05` | Script novo para a A5, com a MM9 ao lado e código diferente. O `04` muda só hash e caminhos, e não roda |
| 7 | Média | As linhas do `06b` mudaram; o C9 não pega "padrão não encontrado" | Reproduzido em parte: os 8 padrões casam 1 vez cada, nas linhas 177–242 (antes, 142–206); o arquivo de conclusões cita as antigas | C9 confere "não encontrado" = 0; o log da A3 avisa sobre as linhas |
| 8 | Média | Edições além do hash sem prova; desvios "só linhas novas" sem prova | Desenho do plano | Conferências novas em scripts novos; `diff` de cada editado contra a cópia no `.tar`; SHA dos primeiros N bytes do log de desvios |
| 9 | Média | Método do `.tar` e conferência ausentes | = S2 | = S2 |
| 10 | Média | Linhas 2012 e 2024 da A7 por ano têm menos de um ano (decisões §6) | §6 (em disco): "concentração × ano (ou mais grosso)" | **Decisão de Guilherme (09/10):** por ano, só de 2013 a 2023 |
| 11 | Média | O `CLAUDE.md` citaria a §8, a E5 e a E6 com o SHA da versão original | `grep` de títulos: só §1–§6 e E1–E4 | "Revisão 2 (rascunho, não recebida; SHA pendente)" |
| 12 | Média | Arquivador `.sh` sem `versao()` | Desenho | Scripts novos em R, com `stopifnot` no início e no fim; o arquivador confere o `versao` do `manifesto.json` (declarado) |
| 13 | Baixa | `git status --short` esconde arquivos | 10 linhas × 54 com `--untracked-files=all` | Usar `--untracked-files=all` |
| 14 | Baixa | Números fixos no `03` | Linhas 54, 254, 262, 310, 314 e 317 | Atualizar as contagens |
| 15 | Baixa | `07` rodando duas vezes apaga a prova; `--conferir` só no fim; renv antes do inventário | Desenho; o prompt põe a A0 (que roda R) antes da A1 ("antes de qualquer execução") | Nome próprio por rodada; conferência antes e depois da A10; **A1 antes da A0** (decisão delegada por Guilherme) |
| 16 | Baixa | Alcance do inventário | = S7 | = S7 |
| 17 | Baixa | CSV em `fase0_rerun/` e o `.tar` sem `_rerun_` no nome | Texto do prompt | Leitura declarada: a pasta marca a rodada; o nome do `.tar` vem do prompt |
| 18 | Baixa | O `02` de hoje não é o que gerou o log da Fase 0A | `02` às 18h29; log e CSV às 16h09 | Diferenças de texto no log são esperadas; os CSV são a prova. Reconciliação falha → parar. O `10` roda de novo depois da A10 |
| 19 | Baixa | `README` da raiz com `7e99bf94`; o hook não barra `.tar` | Linha 7; 0 ocorrências de "tar" no hook | Só apontar no RESPOSTA |
| 20 | Baixa | A falta da Revisão 2 não precisa bloquear a A10 | — | Aceito em parte: a A10 roda contra o prompt, com a limitação registrada |

## Decisões de Guilherme (2026-10-09)

1. **A7 por ano:** só os anos inteiros, de 2013 a 2023 ("se não temos dados para a janela 2012–2024, vamos de 2013–2023 mesmo").
2. **Ordem (A1 antes da A0) e inventário maior que o pedido:** decisão delegada à sessão ("você consegue resolver isso melhor do que eu"). Adotados.
3. **Revisão 2:** "leia o arquivo e siga". O único arquivo de decisões disponível (`~/Downloads/decisoes_metodo_20261008.md`) tem o SHA-256 da versão original (`20fc42e4…`) e não contém "Revisão 2". Sigo com a limitação registrada; o quadro-resumo da §9 sai pelos itens que o prompt enumera.
