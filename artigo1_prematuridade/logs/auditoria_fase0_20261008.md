# A7: dupla auditoria da Fase 0, Parte A

- **Data:** 2026-10-08.
- **Autoauditoria (A7.1):** `00_scripts/03_autoauditoria_fase0.R`; resultado em `logs/autoauditoria_fase0_20261008.md`.
- **Auditoria independente (A7.2):** subagente em contexto limpo, de cerca de 15:21 a 16:01 (America/Sao_Paulo; 40 minutos), sobre o rascunho do RESPOSTA.
  - **Pôde ler:** os scripts de `00_scripts/` e o `checa_sigilo.sh`; os logs `.md` da fase; os CSV de `01_saidas/fase0/`; os dois documentos normativos; o prompt da fase e os dois documentos do chat; a configuração do repositório; e, da base, só `09_acesso/` (`DICIONARIO.md`, `manifesto.json`, `acesso.R`).
  - **Proibido:** outros arquivos da base; `.parquet` e `.dbc`; funções do `acesso.R` que leem dado; escrever qualquer arquivo; rede.
  - **O que procurou:** os nove pontos da A7.2, ou seja, datas, contagens, `type` dos percentis, colunas, arquivos que o git aceitaria, afirmações sem lastro, linha vermelha e sigilo, itens faltantes e incoerências entre logs.
- **Regra (A7.3):** nenhum achado foi aceito sem reprodução por código próprio. Cada correção foi conferida de novo, pelas conferências C7 a C9 do `03_autoauditoria_fase0.R`, rodado depois das correções.

## Resultado da auditoria independente

- **Achados:** nenhum crítico, 1 maior, 9 menores e 3 cosméticos. Os 13 foram reproduzidos e 12 foram corrigidos. O 10 depende de decisão e foi levado ao RESPOSTA.
- **Números da A5:** o auditor refez, a partir dos CSV, os dias das janelas, os totais, as perdas, os mínimos, as listas abaixo de 1.000 e de 2.000, os percentis (todos com `type = 7`), as leituras (i) e (ii), a MM9, a MM14, o `ecdf` e a regra de 90% do PM2.5. Tudo fecha entre os CSV, os logs e o RESPOSTA.
- **Linha vermelha e sigilo:** nenhum objeto junta desfecho e exposição, e nenhuma contagem de 1 a 9 foi publicada.
- **Git:** 0 commits e índice vazio. O `.gitignore` é idêntico à lista do chat. Nenhum arquivo que o git aceitaria tem extensão de dado ou passa de 5 MB, e os 5 CSV são ignorados.

## Achado → reprodução → correção

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

## Exceções às regras de acesso, declaradas pelo próprio auditor

1. Um `grep` de credenciais em `artigo1_prematuridade/renv/settings.json`, fora da lista permitida. Nada foi achado nem impresso.
2. Ao ler o `09_acesso/acesso.R`, o ambiente carregou sozinho o `CLAUDE.md` da base. O auditor não pediu esse arquivo, e nenhum achado depende dele.
3. `stat` e `wc -c` em `README.md`, `codigo_compartilhado/DESCRIPTION` e `renv/activate.R`, só para tamanho e data.

Nenhuma exceção tocou microdado, `.parquet`, `.dbc` ou função de leitura de dado. **Avaliação:** as três são inócuas e não mudam a validade da auditoria.

## O que o auditor não pôde verificar dentro das regras

- **540.212 e 574.491:** as diferenças do `stcesparto_aj` em 2014 e 2015, que vêm da Q2b da entrega da base.
- **Conteúdo das linhas do `06b`:** foi transcrito no log da A4 pelo `01_interface.R`.
