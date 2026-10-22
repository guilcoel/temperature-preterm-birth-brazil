# Fase 2, Parte A: dupla auditoria (A3), 10/10/2026

Registro achado → reprodução → correção, como manda o `CLAUDE.md` do artigo. Só dado sintético e logs agregados; nenhuma linha da base.

## Etapa 1: autoauditoria (`00_scripts/33_autoauditoria_fase2A.R`)

- **1ª rodada** (log de 11:42, SHA-256 `bdcfe46fd547c7ce42f10435f01ccc30887f11c7c551924921efb992dc2350d9`, hoje na lixeira): 16 de 18 conferências iguais. As 2 diferenças eram erros do próprio 33, não dos logs conferidos:
  - a conferência de n/n exigia todos os testes passando, quando o 5b falha (desvio 61);
  - o nome do defeito "φ com n − length(coef)", com parênteses, era lido como expressão regular.
  Os dois foram corrigidos antes da 2ª rodada.
- **2ª rodada** (depois das correções do desvio 62; log de 12:26, SHA-256 `5cb62c33fd7e55911a9f91b722c33cbf53fe2c95ee73bf3c510f40fdec6b23d7`, hoje na lixeira): 31 de 31 conferências iguais. O 33 passou a conferir também:
  - o log do 38: as 1.000 réplicas do 5b, refeitas com `glm`;
  - a chance de cobertura acima de 0,98, por soma de `dbinom`;
  - o ruído branco do teste 9, com `acf(type = "partial")`;
  - os testes rápidos de cada um dos 16 defeitos.
- **3ª rodada** (depois das correções do desvio 63): 44 de 44 conferências iguais (`logs/autoauditoria_fase2A_20261010.md`). O 33 passou a conferir também:
  - o SHA-256 da função e dos testes contra o log do 31;
  - os 28 defeitos, com a lista lida do próprio 31.

## Etapa 2: auditoria independente

- **Auditor:** subagente em contexto limpo. Leu só:
  - os scripts 30, 31, 33 e 38;
  - o código e os testes de `codigo_compartilhado/`;
  - os logs agregados da 1ª rodada;
  - a transcrição do prompt da Fase 2 e os documentos normativos.

  Não abriu `.parquet` nem `.dbc`, nem arquivo da base fora de `09_acesso/`. Rodou só dado sintético, com os scripts `aud4_*` no scratchpad da sessão, fora do repositório.
- **Veredito do auditor:**
  - nenhum achado bloqueia os números da Parte C;
  - o código está matematicamente certo em tudo o que ele conferiu;
  - os achados 1 e 2 mudam `codigo_compartilhado/R/` e, se aceitos, entram antes da tag `ajusta_dlnm-v1.0`.
- **Achados:** 12
  - 6 marcados como "corrigir" (1 a 6) e 6 como "nota" (7 a 12).
  - Todos foram aceitos e reproduzidos por código próprio da sessão (`repro_aud4.R`, dado sintético) ou pela leitura do log e do script da 1ª rodada. O 11 foi reproduzido só em parte.
  - As correções estão no desvio 62, registrado antes da nova rodada.

| Nº | Achado (classificação do auditor) | Reprodução | Correção |
|---|---|---|---|
| 1 | A PACF atravessa lacunas da janela: a grade era `rd[janela]`, e os dias de cada lado de um buraco ficavam vizinhos. Pesa nas sensibilidades da Fase 4 que excluem semanas ou anos (corrigir) | 4 anos sintéticos, com 22/12 a 06/01 fora da janela: a função usava n = 1.396 dias, contra 1.460 na grade da 1ª à última data da janela | Grade por unidade da 1ª à última data da janela, com NA nos dias fora da janela ou do ajuste. Teste novo t09c (janela com lacuna) e defeito novo "grade da PACF só com os dias da janela" |
| 2 | Dois erros não capturados: `gnm` que devolve `NULL` e vcov com `Inf` no `eigen()` (corrigir) | `.autovalor_min()` com `Inf` dá erro "valores infinitos ou faltantes em 'x'". Com um stub de `gnm` que devolve `NULL`, o erro "Argumento não-numérico para função matemática" escapa da função | `is.null(m)` vira falha. `.autovalor_min()` devolve NA se houver valor não finito. `vcov`, φ, QAIC e PACF ficam dentro de `tryCatch`. Teste novo t08c, com stubs |
| 3 | A bateria não detecta vcov sem φ: o gerador é Poisson e o t01 não comparava a vcov (corrigir) | Numa cópia com `vcov(m, dispersion = 1)`, nenhum teste rápido falha. A parte de Monte Carlo do achado não foi refeita | O t01 usa binomial negativa (tamanho 5, φ ≈ 7) e compara `vcov_cb` com a do `glm` quasi-Poisson convergido a fundo (`epsilon` 1e-12; tolerância relativa 1e-6), além de `ep_gama` e QAIC. O defeito "vcov sem φ" entra no 31 |
| 4 | Ramos e saídas sem teste que os derrube: limite da PACF, convergência, vcov positiva-definida 16 × 16 e reduzida, `ep_gama`, QAIC, Boundary.knots (corrigir; nota nos três últimos) | Os 6 primeiros defeitos, cada um numa cópia, passam nos testes rápidos (0 falhas cada). Boundary.knots: na conferência da correção, o t03 também não separava os casos, porque os extremos raramente caem nos 7 dias de aquecimento | O t09a confere `limite` e `fora`. O t08c testa não convergência, vcov não positiva-definida (16 × 16 e reduzida), `Inf` e `gnm` nulo. O t01 confere `ep_gama` e QAIC. O t03 põe um extremo de temperatura no aquecimento e confere os Boundary.knots. Os 9 defeitos novos entram na tabela do 31 |
| 5 | A tabela de defeitos do 31 contava o t05b, que já falha no original, e o critério "≥ 1 teste" ficava vazio (corrigir) | No log da 1ª rodada (SHA-256 `64441aa0…`), o t05b aparece entre os testes derrubados de todos os 7 defeitos | Um defeito conta só se derrubar um teste que passa no original. O t05b sai marcado como "falha também no original" |
| 6 | O 33 não conferia os números do 38 (corrigir) | O 33 da 1ª rodada só lia os logs do 30 e do 31 | O 33 refaz com `glm` as 1.000 réplicas do 5b (mesma sequência) e confere as 4 linhas da tabela do 38 e a chance de cobertura acima de 0,98 |
| 7 | O 38 superestima a certeza: a chance de "1% a 2%" é otimista, o IC de 1.000 réplicas exclui 0,95 e os textos eram fixos (nota) | `pbinom`: P(≥ 197 de 200) = 0,0090 com cobertura verdadeira de 0,95 e 0,0598 com 0,963. Os textos do 38 eram escritos à mão, sem `stopifnot` | O 38 gera os textos a partir dos números, confere a reprodução contra o log do 31, calcula a chance por `pbinom` e usa o IC de Wilson. O desvio 61 passa a dar a faixa de ~1% a ~6% e chama o conservadorismo de limítrofe |
| 8 | IC de Wald da cobertura passa de 1; a fração do ruído branco não tinha IC (nota) | No log da 1ª rodada, o IC do 5b era [0,968; 1,002]. O Wilson de 197/200 dá 0,957–0,995 | IC de Wilson na cobertura (`.mc_resumo`) e na fração do ruído branco do teste 9 |
| 9 | "Erro de aproximação da base = 0,00082" subestima o erro de especificação (nota, para o eMethods) | No log da 1ª rodada, o cenário da dobradiça tem viés de 0,0099 (EP 0,0024) contra o verdadeiro da dobradiça, com cobertura de 0,935 | O 31 passa a dizer que o número relevante é o viés observado da dobradiça. A distância entre os verdadeiros mede só a aproximação no p99 |
| 10 | `complete.cases` não pega `log_z` = −Inf; com `offset = "nenhum"`, o conjunto de linhas pode mudar; aliasamento fora da cross-basis não aparece em lugar nenhum (nota) | `complete.cases(data.frame(a = -Inf))` dá `TRUE` | As colunas de offset exigem valor finito. O aliasamento fora da cross-basis entra nos avisos, sem mudar o status, como manda o prompt. O conjunto de linhas entre offsets fica registrado para a Fase 4: nas comparações entre offsets, quem chama passa o mesmo conjunto de linhas. Sem mudança no código |
| 11 | A `spec_agudo` não exige intercepto na `arglag` (nota) | Em parte: a spec sem `intercept` passa calada, mas a cross-basis sai com 16 parâmetros, e não com 12, porque o dlnm já usa `intercept = TRUE` por padrão no ns da `arglag` | Sem `intercept`, a `spec_agudo` grava TRUE; com `intercept = FALSE`, dá erro. Teste novo t15 |
| 12 | Unidade com n ≤ 8 sai com `fora = ""`, que se lê como "dentro da faixa" (nota) | `.pacf_por_unidade()` com 5 valores e 3 NA devolve `fora = ""` | Com n ≤ 8, valores, limite e `fora` saem NA. Teste t15 |

### Conferido e aprovado pelo auditor (resumo)

- **Cross-basis:** é montada na série inteira recebida, com os Boundary.knots no range de todas as linhas. A cross-basis reconstruída a partir da `base` devolvida é idêntica. Com `group`, o lag não atravessa unidades.
- **Modelo:** γ é o coeficiente de `log_w`, com offset `log_z`. φ é Pearson / `df.residual`, igual ao do `glm`. O QAIC segue o desvio 56. Os coeficientes e a vcov reduzidos não dependem do `cen`. O fallback tem 9 e 3 coeficientes.
- **Monte Carlo:** o verdadeiro do teste 5 confere por θ e pelo `crossreduce`. O teste 7 pega o defeito "offset trocado no `zw`".
- **Sigilo:** nenhuma saída traz série, resíduo ou valor ajustado.
- **PACF negativa (~−1/(m − 1)) num modelo correto:** a observação do log do 31 confere. Ela vem do tamanho do estrato, não da contagem, e também mascara autocorrelação positiva real de magnitude parecida. A leitura da regra da §2.1 fica com o chat, antes da Parte C.

## Etapa 3: re-auditoria das correções

- **Auditor:** outro subagente em contexto limpo, com as mesmas restrições da Etapa 2. Não leu o log da autoauditoria, que estava em produção. Os scripts dele (`aud5_*`) ficaram no scratchpad da sessão, fora do repositório.
- **Veredito do auditor:**
  - as 12 correções da Etapa 2 estão certas;
  - a função devolve `status = "falhou"` sem lançar erro em todos os caminhos de erro, inclusive os que a bateria ainda não cobria;
  - os números dos logs do 31 e do 38 (2ª rodada) foram reproduzidos;
  - os furos estão nos testes e nas travas dos scripts.
- **Achados:** 12
  - 4 marcados como "corrigir" (1 a 4) e 8 como "nota" (5 a 12).
  - Todos foram aceitos e reproduzidos por código próprio da sessão (`repro_aud5.R`, dado sintético) ou pela leitura do código e do log.
  - As correções estão no desvio 63, registrado antes da 3ª rodada.

| Nº | Achado (classificação do auditor) | Reprodução | Correção |
|---|---|---|---|
| 1 | O t08c não cobria erro no `crossreduce`, erro na `vcov()` nem erro no bloco φ/QAIC/PACF (corrigir) | Cópias sem o `tryCatch` do bloco φ/QAIC/PACF, sem o ramo "vcov indisponível" ou sem o `tryCatch` do `crossreduce`: 15/15 testes rápidos passam em cada uma. Na cópia sem o `tryCatch` do `crossreduce`, com um `crossreduce` que dá erro, sai "ERRO NÃO CAPTURADO". Na cópia sem o ramo, com uma `vcov` que dá erro, a função devolve "ok" com `vcov_cb` nula | O t08c ganha stubs de erro na `vcov`, nos resíduos e no `crossreduce`, cada um conferindo status e mensagem. Os 3 defeitos entram no 31 |
| 2 | Nenhum teste com offset NA ou −Inf na janela; a regressão seria silenciosa (corrigir) | Cópia sem o filtro `is.finite`: 15/15 passam. Com `log_z` NA em 11 dias, essa cópia devolve "ok" com 730 de 730 dias usados, e o aviso "número de itens a substituir não é um múltiplo" escapa (resíduos reciclados, PACF e QAIC errados). Com um −Inf entre eles, o `gnm` dá erro e a função devolve "falhou". O original usa 719 dias | Teste novo t16 (`log_z` NA e −Inf em 13 dias da janela, mais um estrato sem evento), que confere contagens e coeficientes. Defeito "offset não finito dentro do ajuste" no 31. A defesa extra sugerida (comparar o número de resíduos com o de linhas) não entrou: com o filtro e o t16, não sobra caminho em que o `gnm` descarte linhas |
| 3 | No 31, a falha conhecida do 5b era reconhecida só pelo nome do teste (corrigir) | Leitura: `ok` usava `all(falhas_orig %in% FALHA_CONHECIDA)`, só com o nome | Nome e mensagem exata ("cobertura 0.985 fora de 0,92–0,98"); qualquer outra falha do t05b vira "FALHA NOVA" |
| 4 | O 34 não conferia o SHA do código contra o testado, e o 33 não registrava SHA (corrigir) | Leitura: nenhum `stopifnot` de SHA no 34 | O 34 para se o SHA da função e dos testes diferir do testado no 31, do diagnosticado no 38 ou do auditado no 33. O 33 grava e confere os SHA |
| 5 | γ̂ e offset trocado só eram pegos pelo Monte Carlo (nota) | γ̂ do coeficiente errado e `zw` com offset `log_z`: 15/15 passam. `z_w_gama` com offset `log_zw`: só o t09a falha, por ruído numérico (4,1e-10 > 1e-10) | O t01 confere o γ̂ contra o `glm`. Os 3 defeitos entram no 31; `zw` com offset `log_z` continua pego só pelo t07 (Monte Carlo) |
| 6 | O defeito "vcov sem φ" derrubava o t08c por artefato (nota) | 13/15 passam: t01 e t08c falham, este com "alvo do stub não encontrado" | O stub da `vcov` troca só `stats::vcov(` (a 1ª ocorrência, a do `gnm`) e repassa os argumentos |
| 7 | O 38 tinha textos escritos à mão, e a trava de reprodução era grossa (nota) | Leitura: "(o mesmo do 31)" e "acima do teto" sem conferência | O 38 confere o SHA da função contra o log do 31, o viés e o EP de MC do 5b contra a linha do 31, e que a cobertura do 31 passa de 0,98 |
| 8 | O desvio 62(a) tratava como ordem do prompt o que é leitura da A1.4; o `gnm` com `eliminate` não marca aliasamento com os estratos (nota) | `log_w` constante: "ok", EP de γ de 8,65e9. `log_w` constante dentro de cada estrato: "ok", EP de 2,47e9 | O 62(a) passa a dizer "leitura da A1.4". O cabeçalho da função e a RESPOSTA documentam o comportamento do `gnm`, sem mudar o status |
| 9 | O 34 tinha textos fixos e faltavam travas (nota) | Leitura: números de desvio e origem dos defeitos fixos no texto; o 38 conferido só pela ausência de "NÃO descarta"; nada conferia que a única falha é a do t05b | Os textos saem dos logs. O 38 é conferido pela conclusão positiva; o 34 exige que a única falha seja a do t05b, com cobertura acima de 0,98, e lê o número de achados de cada etapa na seção certa. A conferência de números do 34 continua sem pegar inteiros (nota aceita) |
| 10 | As contagens de controle não tinham teste (nota) | Linhas por unidade e estratos usados contados antes de tirar os vazios, e dias removidos contados fora das linhas de ajuste: 15/15 passam em cada cópia | O t16 confere todas as contagens. Os 3 defeitos entram no 31 |
| 11 | O log do 31 omitia a binomial negativa do teste 1 e trazia `<data>` literal (nota) | Leitura: `<data>` presente; a binomial negativa não aparece | O log declara a binomial negativa e traz a data real |
| 12 | Dois casos patológicos (nota) | Dias alternados: n = 50, os 7 lags NA, `fora` = "". Variância de `log_w` negativa (stub): "ok", EP de γ NaN, e o aviso "NaNs produzidos" escapa | `fora` = NA se algum lag sair NA. Com variância não finita ou negativa, EP de γ = NA, com aviso, sem aviso escapando. Testes no t15 e no t08c, e os 2 defeitos no 31 |

### Conferido e aprovado pelo re-auditor (resumo)

- **Correções da Etapa 2:**
  - a grade da PACF tem NA nas lacunas;
  - `gnm` nulo, `Inf` na vcov e erro no bloco φ/QAIC/PACF dão "falhou";
  - o t01 com binomial negativa (φ = 6,90) separa a vcov sem φ, com diferença de 0,855 contra uma tolerância de 1e-6, e precisa do `epsilon` de 1e-12;
  - os 16 defeitos são plausíveis e são pegos;
  - o 33 confere o 38;
  - a conta `pbinom(196, 200, p, lower.tail = FALSE)` está certa;
  - a fórmula de Wilson bate com o `prop.test`;
  - o texto da dobradiça está certo;
  - os testes de intercepto e de unidade pequena passam.
- **Números:** o Monte Carlo original e as 1.000 réplicas do 38 foram reproduzidos exatamente.
- **Desvios 61 e 62:** batem com o código e os logs, salvo a frase do 62(a) (achado 8).

## Regeneração dos logs

Os logs da 1ª e da 2ª rodadas foram para `/Volumes/Forja/.Trashes/501/` (recuperáveis; os da 2ª ganharam o sufixo de hora `12-34-46`). Depois de cada leva de correções, os scripts 31, 38 e 33 rodaram de novo, nesta ordem. O log do 30 (diagnóstico do offset) não mudou, porque nem o script nem os dados dele foram tocados. Nas três rodadas, as estimativas de Monte Carlo são idênticas: nenhuma correção mexeu no caminho das estimativas.

| Log | 1ª rodada (na lixeira) | 2ª rodada (na lixeira) | 3ª rodada (a que vale) |
|---|---|---|---|
| `testes_ajusta_dlnm_fase2_20261010.md` | `64441aa02d5049efdc769ddf27c5235fe1e1bb7226a14fcf25f6a6510b3883f9` | `8667319ec9333aaef6bf13026b3e73540e237ed5c7c8664cd3dfb58a864c3d33` | `89589e834353b3cd942c329882e904a5abdc4c0d66198831d87620088d4f8afa` |
| `diagnostico_t05b_fase2_20261010.md` | `415e8cf4dcb24348faa0e1e848db6085fcff181a8bad4479c586bbb1807da2e2` | `19f7bcf84ddcd3df7f0c88c2d5b30ab64c354ccda64a21705f1a4712c7aee33c` | `88222e6e15ced23f427dec163f93473fa663e76d7e84ee3f281abc087f30fc38` |
| `autoauditoria_fase2A_20261010.md` | `bdcfe46fd547c7ce42f10435f01ccc30887f11c7c551924921efb992dc2350d9` | `5cb62c33fd7e55911a9f91b722c33cbf53fe2c95ee73bf3c510f40fdec6b23d7` | `4ec5ec9f2aeef5382b3c5e5153fa80254c86acd4cba5b1e8563559d3c28bc8fd` |
