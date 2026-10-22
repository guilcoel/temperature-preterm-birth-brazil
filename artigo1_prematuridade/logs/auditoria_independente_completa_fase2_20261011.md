# Fase 2 do Artigo 1: auditoria completa antes da Fase 3, 11/10/2026

Registro achado → reprodução → correção, como manda o `CLAUDE.md` do artigo. Cobre as Partes A, B e C publicadas (commits `caf5022`, `92565b9` e `11ba434`; tag `ajusta_dlnm-v1.0`). Só logs, scripts, dado sintético e resultados de modelo agregados por concentração.

## Etapa 1: autoauditoria por código (`00_scripts/39_auditoria_completa_fase2.R`)

- **Resultado:** 21 de 21 conferências ok. O log é `logs/auditoria_completa_fase2_20261011.md`, com SHA-256 `1bd67cc33a5b74edb7ad0d40204d8482d990f200460e81980ba4d41b3b80a8f5`.
- **Destaques:**
  - os 26 ajustes da Parte C, refeitos com a função lida da própria tag, são idênticos (`identical()`) aos da RDS do 32;
  - as baterias dão de novo 19/20 (só o 5b, com a mesma mensagem) e 21/21;
  - a tag é a mesma no remoto e no local, e `codigo_compartilhado/R/` não mudou desde ela;
  - os SHA-256 citados nas auditorias, nos logs e nas RESPOSTAs batem com os arquivos;
  - os desvios vão de 1 a 66, sem buraco;
  - o ambiente é o do `renv.lock`, com o BLAS de referência;
  - não há padrão proibido nos arquivos da Fase 2.
- **1ª rodada:** deu 19 de 21, com 2 falsos positivos da própria checagem. A explicação e o SHA-256 dessa rodada estão no log.

## Auditoria independente

- **Auditor:** subagente em contexto limpo, só de leitura.
  - Leu os textos de `artigo1_prematuridade/`, de `codigo_compartilhado/` e de `spec/`, a transcrição do prompt e os CSVs de resultado de modelo.
  - Não abriu `.rds`, `.parquet` ou `.dbc`, nem a base.
  - Rodou dado sintético, com os scripts `aud8_*`.
  - Usou um único `git ls-remote`, só de leitura.
- **Veredito do auditor:**
  - as três partes batem entre si;
  - o código publicado é igual no HEAD, na tag e no remoto;
  - a Parte C segue a v2.0.2 e as decisões;
  - as saídas estão completas e sem problema de sigilo;
  - nada precisa ser refeito;
  - duas lacunas de método impedem emitir o prompt da Fase 3 como está (achados 1 e 2);
  - a PACF e o fallback são decisões necessárias antes da Fase 4;
  - o resto é registro.
- **Achados:** 13
  - Classificação: 2 bloqueiam a Fase 3 e são para o chat (1 e 2); 2 são para o chat antes da Fase 4 (3 e 4); 5 são correções de registro (5 a 9); 4 são notas (10 a 13).
  - Todos foram reproduzidos por código próprio da sessão (`repro_aud8.R`, dado sintético; `repro_aud7.R`, CSVs) ou pela leitura de código, logs e git.
  - As correções de registro estão no desvio 67.

| Nº | Achado (classificação do auditor) | Reprodução | Correção ou destino |
|---|---|---|---|
| 1 | A `attrdl` *backward* da §7 não roda com os coeficientes reduzidos (BLUP) (bloqueia a fração atribuível da Fase 3; para o chat) | `attrdl.R`, l. 134: `stop("only dir='forw' allowed for reduced estimates")`. Com dado sintético, a cross-basis e os 4 reduzidos, *back* dá esse erro e *forw* roda (AF 0,0195406); com os 16 coeficientes, *back* roda (AF 0,0198914) | Para o chat, antes da Fase 3: *backward* com os 16 coeficientes da primeira etapa (sem encolhimento), centrados na MRT do BLUP, ou *forward* com os BLUPs, como no MCC 2015 (desvio da §7). Nos dois casos, os eventos do aquecimento entram como NA |
| 2 | A curva combinada dos agudos não tem base de predição definida, e faltam percentis (bloqueia a curva e a MRT combinadas; para o chat) | Na §6, só o PIG tem a base detalhada (nós semanais e eixo da MM9). O `referencias_exposicao.csv` só tem p1, p10, p50, p75, p90, p99, média e amplitude: faltam p5 e p95 (contrastes da §7), p2,5 e p97,5 (componentes extremos da `attrdl`) e a grade da escala comum de percentis | Para o chat, antes da Fase 3: fixar os nós e os Boundary.knots da base de predição combinada (sugestão do auditor: média dos nós e dos Boundary.knots das 26) e gerar os percentis faltantes da exposição de 2012-01-01 a 2024-12-31 (dado público), com script e SHA-256 |
| 3 | Regra da PACF (desvios 65c e 66d) (para o chat, antes da Fase 4) | Dos CSVs: literal 25 de 26 (70 lags, todos negativos); recentrada 13 (23 lags acima do centro e 1 abaixo); recentrada com Bonferroni 8 (13 acima); PACF − centro positiva nos 7 lags, de +0,007 a +0,018 | Para o chat. A decisão vem depois de ver os dados e deve se justificar pela calibração nula das Partes A e B, não pelo número de concentrações sinalizadas. A sensibilidade de resíduos defasados exige a v1.1 |
| 4 | O gatilho do fallback não cobre o caso em que o `gnm` devolve NULL ("Algorithm failed"), que é falha de ajuste (para o chat, antes da Fase 4) | `MOTIVOS_FALLBACK` do 32 não inclui "o gnm não devolveu modelo" (`ajusta_dlnm.R`, l. 145) | Para o chat, com o 65(a): incluir esse caso e decidir como uma curva de fallback (3 coeficientes, outra base) entra no pooling. Fica na lista do desvio 67(j) |
| 5 | O push da Parte B não tinha registro, e o desvio 60 cita uma "RESPOSTA da Parte B" que não existe (corrigir no registro) | Nenhum log da Fase 2 registrava o `ls-remote` do push; não há arquivo de RESPOSTA da Parte B | Desvio 67(a), com os dois pushes, os `ls-remote` e as palavras de cada ok de Guilherme; desvio 67(b) |
| 6 | Os documentos normativos da Fase 2 (prompt v1.1 e liberações) não estavam arquivados (corrigir no registro) | `docs/coordenacao/` só tem documentos da Fase 0; nenhum prompt da Fase 2 em `logs/` | A transcrição do prompt vai para `logs/prompt_fase2_v1_1_transcricao_20261010.md` (SHA-256 `355767dc…`; o original não pôde ser conferido); as liberações, com as palavras exatas, no 67(a) |
| 7 | O código das reproduções das auditorias estava só no scratchpad volátil (corrigir no registro) | Os scripts `repro_aud*` e `aud4_*` a `aud8_*` estavam em `/private/tmp/…` | Copiados para `01_saidas/auditoria_fase2/` (Forja, fora do git), com o manifesto de SHA-256 abaixo; desvio 67(h) |
| 8 | Referências velhas ou soltas (corrigir no registro) | O desvio 61 cita a "2ª rodada do 38"; os desvios 51, 55 e 57 têm `fase2_<data>` (3 ocorrências); o SHA-256 das RESPOSTAs não estava gravado no repositório; o `sessionInfo_fase2C` saiu do 35 | Desvio 67(c) a (f) |
| 9 | `DESCRIPTION` desatualizado e pendências da v1.1 espalhadas; achado novo: covariável em forma de matriz dá erro não capturado (corrigir antes da Fase 4) | `Version: 0.0.0.9000`, `Imports: stats`. Com dado sintético, uma covariável com duas colunas dá "substituto tem 2190 linhas, dados têm 1095", fora do `tryCatch` | `DESCRIPTION` atualizado (67i, fora de `R/`, sem tag nova); lista única da v1.1 no 67(j) |
| 10 | Não dá para provar que os desvios vieram "antes de rodar": entraram no git junto com os resultados (nota) | O log de desvios está nos commits `caf5022` e `11ba434`, com os resultados; o 64 foi commitado às 17:55, e a tag é das 17:56 | Daqui em diante, um commit próprio para os desvios antes de rodar (67k) |
| 11 | Mudanças depois de ver o resultado estão registradas; a troca de Wald por Wilson virou a leitura de "exclui 0,95" para "inclui 0,95" (nota) | Desvios 62(c, e) e 66(a) | O "inclui 0,95" não é argumento; a evidência é EP/DP, média de z e φ (67k) |
| 12 | As versões finais da Parte C saíram depois da auditoria independente dela (nota) | Logs do 32 (`5a49d2ab…`) e do 35 (`bf6892c0…`) e RESPOSTA C | Esta auditoria as cobriu: contagens, sinais, φ, nós, Boundary.knots, vcov e SHA-256 conferidos |
| 13 | Dois arquivos sem rastreio apareceram durante a auditoria (nota) | `00_scripts/39_auditoria_completa_fase2.R` e o log dele | São a autoauditoria desta sessão (Etapa 1); entram no commit desta auditoria |

## Decisões para o chat antes da Fase 3, em ordem de prioridade

1. **Fração atribuível:** `attrdl` *backward* com os 16 coeficientes da primeira etapa, ou *forward* com os BLUPs (achado 1). A §7 pede *backward*.
2. **Base de predição da curva combinada dos agudos** (nós e Boundary.knots) **e percentis faltantes** (p2,5, p5, p95, p97,5 e a grade da escala comum), gerados da exposição de 2012–2024 com script e SHA-256 (achado 2).
3. **Detalhes do bootstrap e da lag–resposta:** número de réplicas e semente do bootstrap da MRT; contra qual MRT se centra a meta-análise `type = "var"` (a combinada ou a BLUP).
4. **Antes da Fase 4:**
   - a regra da PACF (achado 3);
   - o gatilho do fallback e o destino de uma curva de fallback (achado 4);
   - a v1.1 da função, com a lista do 67(j).

## Manifesto das reproduções (`01_saidas/auditoria_fase2/`, fora do git)

```
bb263ece3a408315ab213e23ccae1b40f6c604803a0d28e4cfb4fd536e6fbe42  aud4_base.R
06aeb5a0d6e7829f9ca7be24f132f3d4ca823133e8330adc41703c1d078756b6  aud4_copia_defeito.R
d84bdddb0d70fb3c878ca1cd1711c9c542c2eca120eab9200b39c4b2be66f4d7  aud4_copia_defeito_mc.R
f4fc7b9519e528842b59bf09f83120d2ab19e3d34001555a82b765c74df53d31  aud4_copia_gnmnull.R
fb4de17038198680cdc7e0bfd330f1dad9a2ace916b95971b137f19c38de038e  aud4_defeitos.R
abb413b9b0202d28756d375d46b1d1b80684789c9b2915a00b175eeb28ec6acf  aud4_extra.R
e285711246b6b3c5d768fa1f93c9a44822c002da3e31ac007a932abd925d4bee  aud4_falhas.R
20a7c7fdcc43f532b053763defaacfcc7083162a6a7365b834109828796c9861  aud4_falhas2.R
040ae879360fca047b64d5829b16724c14aec246e01e3020b93717ab9593872d  aud4_falhas3.R
6e53f28ab22b285704ef5957b632039e7f02593e1c9a18df5b8752a9776ccd70  aud4_gnmsrc.R
a3b5f24144c1a55ce7be9f1adb139d2aa1743089f28815e3bd24350e8eb77408  aud4_mc_defeitos.R
2a9e38773a11c49a0ee12ce88ed3ab6a459e76be3944ba93ce3d670a539ac682  aud4_pacf_lacuna.R
7d82b9e367bc4a359a563de8b932e67b10a9acda4dcb30dcbf4cd1bc50dd0ab5  aud4_rapidos.R
c2a96a0631627d67a45318157b58b90436df253defaa2c4fe9a6aa76a5c3cecd  aud5_34regex.R
21ae71c5f6ab3d7ec5e66acc558e48bac31d9d3aabf24504d0b27c929f6e73d5  aud5_34regex.txt
c7e201be86ff0748b4bfdc5904f5b6adbea523393b78c9e5e95c9969aad06f74  aud5_38.R
3f104b750e648f51dc32a6e5df1738469c9dac80916ad4b65272f8b759fe6cdc  aud5_38.txt
43f6d28436674bc4b156ca2e81f39da5c560aa105533ffdbaa0d0bcb8176417b  aud5_comum.R
d4c04190104b6d590158cd791faf608165b4bf2e385d26f3f04a8a809b628407  aud5_defeitos.R
05f2470d115aa2c4b403bc62e4ce843f72bd47066f0360da566988dd76ae5238  aud5_defeitos.txt
4b661d6e441e748fdc766067743a8b72fdfd15655b49a63edc6ad7bbd38cc6ec  aud5_extra.R
96c63ff3e0234b6e71e2bab31d573ac4873a1f44243f3e0bc9e7b2295342d46f  aud5_extra.txt
a476dc053742346934b13a0602a47af3b9a914d82fad12638903769493c0b409  aud5_mc.R
a21ea344c23f52b7afc7bc0d1dc524d64859b276162428f72f8346c8c3a2c4a6  aud5_mc.txt
63f08c814e85e64b0484c33c81bc43af83d207e2d23a32fb94f8e28060e40563  aud5_naoconv.R
97f90f98d76b485a4c2fd47d9ca015e5986beb36618c882296d4cdc9b97dd639  aud5_naoconv.txt
cc452ac5a9b696d4a9a11f0ae53486833c8faa76fa09d00f4063d38b61f6c9c3  aud5_rapidos.R
1776a7beff2fac205fe6849abe0155996b5201ecd0f97c6334043f83e1b9b6aa  aud5_rapidos.txt
effa6e14ade721ab6435624dbdf68d0ed4320e65f85d7f5e206570160a7aad9a  aud5_stubs.R
05c3b35cbf8858b25a7f029f69d8ddcf81eba8e2ecf613c89c4f1c62c60471c0  aud5_stubs.txt
5f48493b98331df57c09d4c7829196567a3499e201c5fe097cead1671c816a09  aud5_tol.R
183a9bf2b4ac68367315f8a482ead18972edee4cd8d2c8e5f4c68edf9c865e24  aud5_tol.txt
6ed462cab66d7c77a344c4ce402cd34452f1a1d579b2191a896b6c718fcbd828  aud5_wilson.R
02412b6dba0509267fb9da5bc44c61efb7a252f7229c3b35f2e8fdf31ab86ae8  aud5_wilson.txt
f2eee5ef4ed64a7b73da10b17533ce959c3c2d7a49a3b193268ac03c01c6b4c5  aud6_alias_gama.R
9be44dad1f4864c5f062785571a40455367dda58fb8900399c6a0c4aceb38b88  aud6_alias_gama.txt
0b34d020c5d5183a235caffede208c2dcaa28953ee306043b94079c29c64bc59  aud6_bateria.R
f4c51e57ad931f9b315ba27da624aca42ede208f7df2d8100f687262be851213  aud6_bateria.txt
7486f9526770fe1eb9353ccac30ed33b5f2c6e90b019ba46d87f89b33dd52a06  aud6_binom.R
f1aa8ffcdbbbb473ace482dae6ea6a854dbf74c9ee354c04bae5372f26edcdbd  aud6_mc.rds
99ef27f8d61acb75f671dd2b15e4cb47bd2b80d3d90c1a81b98969c5c6ac1287  aud6_pacf_regra.R
178dcea5a586a95760ddbb3f1b1728af58840a211f433825118e1481b1d8e80d  aud6_pacf_regra.txt
0b30721495a0944cb3b83d875ddf930ec896351a1e6c1e47b9a0828a8c9e3bd5  aud7_blas.R
1663917c3331a1bff79eb24b3f14cca4ecaa76ac157f863f88df4832181fb9ce  aud7_csv.R
fb393aa8681e0326e80c7160699760f9bab10b9444ce6f01d31e98af0019b917  aud7_csv.txt
4c450ee5b9813705c21dcfbe773da4f1f03aba32df0d4c7685fbe9f3a384f29c  aud7_gnmfit.R
db95e7711c4f0f7b1f7b79dfa686bc7ca0894ea24f04651de95cbd389c336ba2  aud7_log.R
05457194b5000b5b94f9677a55a46e7b2e667ef66490b875c763f15063c39ec3  aud7_log.txt
661fb92b5d0924ee2110386c7ff078796f5cf87f6d71350ac7ae4b2c80539248  aud7_pacf_dir.txt
b2267d80939162054712cfd3c7f4d3a4c9abd9847e6025a5fa76646286ead8de  aud7_sim.R
0212c05b9072c33d1954ed4dfcd934ddc4c3ee05e380943dadca3760e8e5c7ee  aud7_sim.txt
80dcb6e962cefaa4b4c2508f593c9ec174dc0eb56914e05312f40a2a5812122c  aud7_src.R
e5d81a38477c5abe4409bc4760355cd80482e76189b67f74851c1da6dbd07dd2  aud8_attrdl.R
06248a2b91fc12dc37ef7bed90a33defedc7832c5eca2ae4f8b78db6f6fd4228  aud8_csvs.R
4da07496d6488a94f046d9b5641e4fdef791bc08e7086f78e403d1d859e530eb  aud8_gnmsrc.R
31d2c544284b06b864fd4f7cd41e5edab0a159c58cede5aac7e80861a7fc6c84  aud8_hash_disco.txt
64bb93c8b9ff01dbd16c35df0b383ae0405ae9c8cdd2ef3ef2dc90ee42172452  aud8_logA.txt
3399000c5b86470dd789709304f8764a849e28541d422541c2ef50013a3b7d0d  aud8_logC.txt
11ceffd9cba12f5e6eba319db934557ee7c6e1223245f669dfc17d3b744f23da  aud8_transcA.txt
a784f0aa75cfd352469e1daf88de00b5668f2af1cd318e16334d6dffe5571358  aud8_transcC.txt
254573fa87882d0b5cbf74d9354ac3cb4f0391102bed325c962e611d8da23841  auditoria_fase2A_relatorio.md
ddba3eb2700c562256858a9b58eb4c8c186930eae706cfaa5e654b04be0d10ba  repro_aud4.R
f8faf393a30589f2b5ff8ffb52e55315eff0b8ed29f75bb8a821dc3499e8fc0c  repro_aud5.R
01518f6fd66937461bbe56f3b1537e9ce53767ba427e8a3b92af81815244c106  repro_aud5.txt
1d2bd35631b309c03eb7e1ce3579b341490f7ce43daf3b95d82cfe5bdcc06509  repro_aud5_r2.R
0cf0ce1505e52d4ae59d0e2edf1f75deab7e40070ecd6780f1141af980bf9902  repro_aud6.R
328923a17103240da3e5dea9af47a724782d6bf1cbcab77fa4e5806bf96e1e85  repro_aud6.txt
6a9b4580af098550677cbc0d839635cd2098f81b3bc068a8bc13ffb7ab38ed5d  repro_aud7.R
26cd522911441fd80f24f59aeb1862f3f6b3dff304893e9c144a60626af0d396  repro_aud7.txt
bcf942db3d58cfb4f968f7b21a05661f5a6072dfd2f59e99bc9bd90cbf1b6f7d  repro_aud8.R
be0d80856c6a4e089a57f6c679f6d124b0c63e2fe1fb20200f3e19b38193d07d  repro_aud8.txt
```
