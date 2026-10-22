# Fase 3, Parte C: dupla auditoria, 13/10/2026

Registro achado → reprodução → correção, como manda o `CLAUDE.md` do artigo. A série diária só foi lida e processada dentro da Forja; nenhuma linha, valor diário, série diária ou AN/AF diário foi impresso ou gravado. Saem só resultados de modelo e agregados por concentração na janela inteira.

## Etapa 1: autoauditoria (`00_scripts/47_autoauditoria_fase3C.R`)

- **Rodadas de desenvolvimento do 45 e do 46** (gravadas só no scratchpad, antes das oficiais):
  - duas conferências de entrada do 45 falharam por 1 ulp: os CSV `reduzida_coef_vcov` e `crossbasis_coef_vcov` da Fase 2 contra a RDS, e a `tmean_nucleo` de 2012–2024 contra a grade da A0. Os arquivos foram gravados com `sprintf("%.17g")`, e a leitura de texto do R pode errar 1 ulp. As duas passaram a comparar o texto, com o mesmo `sprintf("%.17g")`, em igualdade exata;
  - p-valores e q_TMR com vírgula decimal;
  - a tabela das contribuições negativas ganhou a contagem das concentrações com soma arredondada ≤ −1, ao lado da contagem registrada no desvio 77(e) (qualquer contribuição negativa), que inclui contribuições minúsculas.
- **1ª rodada oficial do 45 e do 46** (21:34), seguida de uma **rodada de desenvolvimento do 47** (só no scratchpad): 32 de 35 conferências iguais. As 3 diferenças vinham de um **erro no 46**:
  - o denominador total somava as 5 linhas de componentes de cada concentração: 6.890.150, isto é, 5 × 1.378.030;
  - a AF das 15 linhas de total (3 análises × 5 componentes) saía dividida por 5; no principal, total 0,37% em vez de 1,84%;
  - AN, eCI dos AN, denominadores por concentração e AF por concentração estavam certos.

  **Correção no 46:** o denominador total passou a somar uma linha por concentração (`den_c`, com `stopifnot(nrow(den_c) == 26)`), e a tabela de denominadores usa a mesma seleção. Saídas e log da 1ª rodada do 46 foram para a lixeira do volume, com SHA-256 anotado (seção "Regeneração dos logs"), e o 46 rodou de novo (21:38).
- **1ª rodada oficial do 47** (21:38): 35 de 35 conferências iguais (log hoje na lixeira).
- **2ª rodada oficial do 47** (21:58, depois das correções da auditoria independente): **42 de 42** (`logs/autoauditoria_parteC_fase3_20261013.md`). Conferências novas: autovalores e posto efetivo de Ψ; proporção de sorteios nas pontas da grade (combinada, São Paulo e Sorocaba); RR contra a mediana nas 10 concentrações com TMR BLUP na fronteira; AF de cada componente igual a AN/denominador em todas as linhas; contribuições negativas de Sorocaba (total, fora e dentro de p1–p99) refeitas à mão. A rodada de desenvolvimento dessa versão deu 41 de 42, por erro da própria conferência do 47 (o filtro dos RR por concentração passou a pegar também as linhas novas contra a mediana); o filtro foi corrigido antes da rodada oficial.
- **3ª rodada oficial do 47** (depois das notas N1 e N3 da re-auditoria; o 45 rodou de novo às 22:08:32 e o 47 às 22:08:35): **42 de 42**. O 45 só mudou o texto do log ("Extensão do IC" e os autovalores de Ψ abaixo do limiar); as 8 saídas dele têm os mesmos SHA-256 de antes, e o 46 não rodou de novo.
- **Limite:** as rodadas de desenvolvimento (32 de 35, 41 de 42 e o SHA-256 igual da RDS do 45) ficaram só no scratchpad da sessão e não são verificáveis por terceiros; o que é verificável são os logs e as saídas em vigor e os arquivos da lixeira, com os SHA-256 abaixo.

## Auditoria independente

- **Auditor:** subagente em contexto limpo. Leu o prompt da Fase 3, as decisões de 13/10 e o complemento, os desvios 71 a 77, o código das tags, os scripts 45 a 47 e os logs em vigor antes das correções da auditoria (45 de 21:34; 46 e 47 de 21:38, já com o denominador corrigido); leu com R, sem imprimir linhas, as saídas da Parte C, a RDS da primeira etapa, o CSV de referências, a grade da A0 e a série da Fase 1; leu a exposição de 2012–2024 só pela `serie_diaria` com as colunas de exposição. Não abriu `.parquet` nem `.dbc` e não escreveu no repositório. Rodou com código próprio (`aud11/*`, no scratchpad).
- **Veredito do auditor:** os números da Parte C estão corretos; refez cada um com código próprio, e todos batem com o que o 45 e o 46 gravaram, dentro de 1e-10 ou menos. O código no disco é o das tags, na árvore e na mensagem de cada uma, e a `attrdl.R` tem o SHA-256 registrado. A correção do denominador total está certa. A RESPOSTA não podia sair por três lacunas de relato (achados 1 a 3); mais três notas de apresentação. Nada muda estimativa nem método.
- **Achados:** 6
  - 3 marcados como "corrigir antes da RESPOSTA" (1 a 3) e 3 como "nota" (4 a 6).
  - Todos foram aceitos e reproduzidos por código próprio da sessão (`repro_aud11.R`, no scratchpad) ou pela leitura do prompt, da especificação e dos scripts.
  - As correções mudam só o relato. O 45, o 46 e o 47 rodaram de novo (21:57 a 21:58); os números já gravados não mudaram.

| Nº | Achado (classificação do auditor) | Reprodução | Correção |
|---|---|---|---|
| 1 | Faltam os RR contra a mediana nas TMR BLUP de fronteira: a especificação (§7: "Se a TMR cair na fronteira, reportar os RRs também contra a mediana") e o prompt (A1.4: "Quem chama reporta as duas"; D4(g)) pedem, e o 45 só calculava contra a TMR. Nas 10 concentrações de fronteira, o RR no p99 sai 1,000 (1,000 a 1,000), porque é a própria TMR (corrigir antes da RESPOSTA) | Leitura do 45: a `busca_tmr` devolve o p50, mas a `curva` só usava `tb$tmr`; TMR na fronteira em 10 de 26 (CSV de TMR) | O 45 calcula, nas concentrações com TMR BLUP na fronteira, os RR nos p99, p95, p90, p10, p5 e p1 contra o p50 da concentração, com IC (nível `blup_mediana` no CSV de contrastes e tabela própria no log). Só reportado: o `cen` da C5 continua sendo a TMR da grade (D4(g)). O 47 confere essas 60 linhas com `splines::ns` |
| 2 | A correção do denominador total do 46 não estava registrada em nenhum log (corrigir antes da RESPOSTA, registro) | Confirmado: só existia o log do 47 com 35 de 35 | Registrada na Etapa 1 deste log, com os números afetados, a correção e os SHA-256 da rodada anterior (seção "Regeneração dos logs"). A RESPOSTA transcreve este log |
| 3 | Falta a AF de cada componente por concentração: o prompt pede "AN e AF de cada componente, com eCI" (C5) e as tabelas completas (D4(d)); por concentração só saía a AF do total (corrigir antes da RESPOSTA, só apresentação) | Leitura do 46: a `tabela_conc` só tinha a AF do total; o CSV já tinha a AF de todas as linhas | O log do 46 ganhou, em cada análise, a tabela "AF por componente (eCI)" das 26 concentrações; o 47 confere AF = AN/denominador em todas as linhas do CSV |
| 4 | A explicação das contribuições negativas do principal estava incompleta: atribuía tudo à resolução de 0,1 °C da grade, e o prompt (C5) já previa a causa principal, os dias fora de p1–p99 (nota) | Código próprio: no principal, as 10 concentrações com dias de RR < 1 contra a TMR BLUP fora de p1–p99 são exatamente as 10 com TMR na fronteira | O 46 separa, no *forward*, a soma das contribuições negativas entre dias fora e dentro de p1–p99 (no principal, −38,7 fora e −0,034 dentro; na ponte, −263,4 fora e −2.483,4 dentro), diz que nas concentrações com TMR no p97,5 ou acima o calor extremo é igual ao calor por construção (D4(h)) e explica a ponte pela limitação da D1 (curva sem encolhimento com o `cen` na TMR BLUP). O *backward* não é separado por faixa (a contribuição do dia t vem de t − 7 a t) |
| 5 | Os IC da TMR cobrem a faixa de busca inteira: o IC da combinada é exatamente de x1 a x99, com 3,5% dos sorteios no x1 e 30,9% no x99; em 18 das 26 concentrações, o IC da TMR BLUP é a grade p1–p99 inteira (nota) | Código próprio: os mesmos 3,5% e 30,9%, e 18 de 26 | O 45 diz isso no log: cobertura do IC da combinada, número de IC BLUP iguais à grade inteira e, por concentração, a porcentagem dos sorteios no p1 e no p99. O 47 confere as proporções com o bootstrap à mão |
| 6 | Ψ está no limite do espaço paramétrico: autovalores 2,657e-02, 5,493e-04, 7,717e-11 e 8,285e-17, posto efetivo 2 (nota) | Código próprio: os mesmos autovalores | O 45 lista os autovalores de Ψ da C1 e das duas meta-análises da lag–resposta, com o posto efetivo (autovalores acima de 1e-8 × o maior; depois da nota N3, os abaixo do limiar só são contados), e declara Ψ singular, só reportado (A1.2: a sequência de estabilidade age só em erro ou não convergência). Na lag–resposta, o posto efetivo é 2 no p99 e 1 no p1 |

### Conferido e aprovado pelo auditor (resumo)

- Código contra as tags: os 4 arquivos de `codigo_compartilhado/R/` e os 7 de testes têm o mesmo SHA-256 no disco, na árvore e na mensagem das duas tags; a `attrdl.R` tem o hash `d34c4c30…`.
- Ordem das 26 igual à do desvio 73; grade da A0 e eixo médio iguais ao `quantile(type = 7)` do auditor; média e amplitude do CSV iguais às calculadas da exposição.
- Base combinada (D2) igual às médias das 26; os nós médios coincidem com o eixo em p10, p75 e p90; as fronteiras de cada concentração são o range das 4.505 linhas.
- C1: REML com Ψ não estruturado; coeficientes, vcov, Ψ, BLUPs, Q e I² (por GLS à mão) e Wald iguais.
- C2: TMR combinada 28,2 °C, q_TMR 0,9378, IC do bootstrap reproduzido; contrastes iguais pelo `crosspred`.
- C3: as 26 TMR BLUP, a fronteira, a busca p10–p90, o percentil, os IC do bootstrap das 26 e os 156 RR iguais.
- C4: centros, coeficientes de lag (pelo `crosspred` por lag), soma dos lags, RR por lag e Q iguais.
- C5, refeita à mão sem a `attrdl` nas 26 concentrações × 3 análises × 5 componentes: AN, eCI e as 1.000 simulações reproduzidos (confirma a semente 20261001 + i); denominadores iguais ao `n$eventos`; totais, aditividade do *forward* e diferenças do *backward* iguais.
- Fidelidade: os trechos conferidos dos logs do 45 e do 46 batem com o texto exato; as 11 saídas têm o SHA-256 dos logs.

## Re-auditoria das correções

- **Re-auditor:** o mesmo auditor independente, retomado com o próprio contexto e com as mesmas regras de sigilo e de escrita. Leu os logs e as saídas novos e, para conferir os SHA-256, só os 18 arquivos agregados desta fase na lixeira do volume. Rodou com código próprio (`aud11/05_*`, `aud11/06_*`).
- **Veredito do re-auditor:** as seis correções estão certas e não mexeram em nenhum número já conferido; 37 conferências novas, todas iguais. O registro da correção do denominador está fiel e completo no essencial: os 18 SHA-256 da tabela abaixo batem com os arquivos da lixeira, e os números da 1ª rodada do 46 batem com o que a Etapa 1 descreve (denominador total 6.890.150 e AF total do principal 0,37% naquela rodada; o resto idêntico ao atual).
- **Achados:** 3 notas, todas aceitas.

| Nº | Nota do re-auditor | Reprodução | Correção |
|---|---|---|---|
| N1 | "Cobertura do IC da TMR combinada", na Parte C, fala da extensão do IC; na Parte A, a mesma expressão é a probabilidade de cobertura nas réplicas (teste 5) | Confirmado pela leitura dos dois logs | O 45 passou a dizer "Extensão do IC da TMR combinada"; o 48 lê o rótulo novo |
| N2 | A frase sobre o que o auditor leu dizia "os logs da 1ª rodada oficial", mas ele leu o 45 de 21:34 e o 46 e o 47 de 21:38, já corrigidos; as rodadas de desenvolvimento não são verificáveis por terceiros | Confirmado pelos horários dos arquivos da lixeira (45 às 21:34:13; 46 com defeito às 21:34:52; 46 corrigido às 21:38:21; 47 às 21:38:34) | Frase corrigida na seção "Auditoria independente"; limite das rodadas de desenvolvimento declarado na Etapa 1 |
| N3 | Os autovalores de Ψ abaixo do limiar são ruído numérico: o menor da lag–resposta no p1 sai 1,590e-19 no log e 1,189e-19 no ajuste do auditor, com Ψ diferindo em no máximo 1,3e-17 | Confirmado pela ordem de grandeza (abaixo de 1e-8 × o maior) | O 45 imprime só os autovalores acima de 1e-8 × o maior e diz quantos ficam abaixo; o posto efetivo não muda (2 na C1, 2 no p99 e 1 no p1). O 47 confere o texto novo |

- **Conferido e aprovado pelo re-auditor (resumo):**
  - as 60 linhas `blup_mediana` (só nas 10 concentrações de fronteira, com `cen` = p50), recalculadas com `crosspred`;
  - as 78 linhas das tabelas de AF por componente;
  - as somas das contribuições negativas, total, fora e dentro de p1–p99, nas 26 concentrações. No principal, as 10 com contribuição negativa fora de p1–p99 são as 10 de fronteira; a TMR fica no p97,5 ou acima nessas mesmas 10, e nelas o calor extremo é idêntico ao calor no AN, no eCI e nas simulações;
  - as proporções de sorteios nas pontas (combinada e 26 concentrações) e os autovalores e o posto de Ψ;
  - o código igual às tags; as entradas e as 11 saídas com os SHA-256 dos logs; as colunas e linhas antigas idênticas;
  - a autoauditoria com 42 de 42.

## Regeneração dos logs

Os logs e as saídas da Parte C foram regenerados depois das correções; os antigos estão na lixeira do volume, com o SHA-256 anotado. A grade da A0 (`percentis_exposicao_fase3_20261013.csv`) não mudou.

| Arquivo | 1ª rodada do 46 (denominador total 5 ×; lixeira) | Rodada antes das correções da auditoria independente (lixeira) |
|---|---|---|
| `logs/segunda_etapa_fase3_20261013.md` | (a mesma do 45, ao lado) | `c45eef090ad3eab23a9ef6c3257265a4d35b572cd147f87304750b1624301151` |
| `logs/fracao_atribuivel_fase3_20261013.md` | `85126c6cb1f199a5c472f172b010f0587337a99ce9c52e6c5aa06e86a206205b` | `d01f6962fd3c5f41e2c32268d5504064658458de566383554528b59ba22b786b` |
| `logs/autoauditoria_parteC_fase3_20261013.md` | (não havia) | `436edf40b492de918809dc8df977b45972bf41543bff5f083e30a924ecde5f00` |
| `01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds` | (a mesma do 45, ao lado) | `dbfe71cfb272b67e1a465401684e805b9411249b44008c1e2c030941f46faf5d` |
| `01_saidas/fase3/meta_curva_fase3_20261013.csv` | (idem) | `6958d5083a2b10d9b3449d56d02315eda9cbc4588aa5773c7e8df3af8edfec76` |
| `01_saidas/fase3/blups_fase3_20261013.csv` | (idem) | `5b38a59e61de47dc18df2ed45106d0d325ae5dc3982d13b0620d3ef3552829c1` |
| `01_saidas/fase3/tmr_fase3_20261013.csv` | (idem) | `6162d7ff261606cae10dd01944f7ccacadc9fba87cbaa2d479ee28e18a14f649` |
| `01_saidas/fase3/contrastes_fase3_20261013.csv` | (idem) | `14367d1c641a3dee1c17ce85261c750f963055bd0233cfd528ba76b50f5e9dcf` |
| `01_saidas/fase3/curva_combinada_fase3_20261013.csv` | (idem) | `4855ffdb50831e23eeffaa3bd25822afa4f5399e90a5df05184485f5b07cd93d` |
| `01_saidas/fase3/lagresposta_fase3_20261013.csv` | (idem) | `6a60db902a2e5b5ba679563000216f8e391e0836dc00aac277895b23b84af212` |
| `01_saidas/fase3/lagresposta_meta_fase3_20261013.csv` | (idem) | `9040effec6722babada664b55505b52175559be4e9cd8e2a58fc2e89515ffeb2` |
| `01_saidas/fase3/fracao_atribuivel_fase3_20261013.csv` | `c1c2488e4f57ac5805c36c88c4ab8cff6090400350f2ccbffb68061de8017150` | `9437e9668c729ffd502a159038d2d557b4d8767d1a046cb86eef13ddb2659a48` |
| `01_saidas/fase3/contribuicoes_negativas_fase3_20261013.csv` | `b89582919f210a3fd5c07da895078a21fcf091ff358a6b2b0467191e583ec589` | `b89582919f210a3fd5c07da895078a21fcf091ff358a6b2b0467191e583ec589` |
| `01_saidas/fase3/fracao_atribuivel_simulacoes_fase3_20261013.rds` | `9a1a02b779d7e1d336826831df940e1ce1c0a009382cd45cd235e225227bd5cd` | `9a1a02b779d7e1d336826831df940e1ce1c0a009382cd45cd235e225227bd5cd` |

- **Rodada antes das notas N1 e N3 da re-auditoria (lixeira):** `logs/segunda_etapa_fase3_20261013.md` `ef74c818abde85e6bababc33433c7774e3b39b0c7a92faad2a3eb3742ef2194c`; `logs/autoauditoria_parteC_fase3_20261013.md` `221d60e147ec0c3405775799510255e3171aef573470f03d6e7e65cee2063ed2`. As 8 saídas do 45 daquela rodada têm os mesmos SHA-256 das em vigor.
- A RDS do 45 da 1ª rodada oficial tem o mesmo SHA-256 da rodada de desenvolvimento, e as simulações e as contribuições negativas do 46 são idênticas nas duas primeiras rodadas: os cálculos são deterministas.
- Os SHA-256 das saídas em vigor estão nos logs do 45 e do 46 e na RESPOSTA.
