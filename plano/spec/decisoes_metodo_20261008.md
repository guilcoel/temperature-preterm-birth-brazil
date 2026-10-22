# Decisões de método de 08/10/2026 e errata da especificação v2.0.2

**Projeto DLNM Perinatal (CliMaterna, FCM/UNICAMP) · Emitido pelo chat de métodos · Revisão 2 (final), 09/10/2026**

**Histórico:** Revisão 0 (08/10, manhã): decisões sem OSF e sem CEP, errata E1–E4. Revisão 1 (08/10, 16h30): seções 7 a 10, a partir da Fase 0A do Artigo 1. Revisão 2, rascunho (08/10): auditoria da Revisão 1 pelo chat do Artigo 1 (rito do hash, RESPOSTA refeita, pendência 4, `ig_dum_sem`, ética, cortes na janela principal, redação, documentos de coordenação) e auditoria independente. **Revisão 2 final (09/10):** campos preenchidos com a base `4443971b` e a Fase 0 refeita; opção B na ética (seção 2); §3.5 redefinida (seção 12); escopo da exceção de sigilo ampliado (seção 6).

**Status: final.** Esta é a versão congelada no git (seção 1.1). Depois do congelamento, nenhum texto deste documento muda; qualquer mudança é desvio registrado em `logs/desvios_especificacao.md`.
Complementa `especificacao_dlnm_canonica_v2_0_2.md`. **Em caso de conflito, vale este documento.** Os arquivos da pasta `spec/` são congelados juntos no git (seção 1.1) antes de qualquer modelo de desfecho, e o hash do commit é citado em Methods.

---

## 1. Sem pré-registro no OSF

Decisão de Guilherme Coelho, em 08/10/2026, para ganhar tempo. O AJOG MFM não exige registro de estudo observacional primário; o pré-registro era regra do projeto.

### 1.1 Congelamento no git (substitui o OSF)

1. **Repositório:** privado, na conta GitHub `guilcoel`, dedicado ao código dos três artigos: `artigos_perinatais_clima` (definido na Fase 0 do Artigo 1; seção 11).
2. **Arquivos congelados**, numa pasta `spec/` do repositório:
   - `especificacao_dlnm_canonica_v2_0_2.md`;
   - este documento, `decisoes_metodo_20261008.md` (Revisão 2 final);
   - a RESPOSTA da Fase 0 refeita sobre a base nova, `RESPOSTA_artigo1_prematuridade_FASE0A_rerun_4443971b_20261009.md`, que traz os valores da seção 9 (inclusive o percentil semanal equivalente da MM14 e o SHA-256 dos CSV de percentis). Ela vem da pasta do Artigo 1 na Forja, e o SHA-256 dela está na seção 11. A RESPOSTA de 08/10, sobre a `7e99bf94`, não é congelada.
   Guilherme baixa a especificação e este documento do Projeto e os coloca na Forja; o Claude Code copia os três arquivos para `spec/` sem alterar nenhum byte e confere: o SHA-256 da RESPOSTA tem de ser igual ao da seção 11, e os da especificação e deste documento, iguais aos informados pelo chat de métodos na emissão da Revisão 2 final. Se algum diferir, não há commit.
   - **Documentos de coordenação:** no mesmo commit, a pasta `docs/coordenacao/` recebe os quatro documentos do chat do Artigo 1 que os logs citam como fonte das decisões. O Claude Code confere cada SHA-256 antes do commit:

     | Documento | SHA-256 |
     |---|---|
     | `PROMPT_artigo1_prematuridade_FASE0_20261008.md` | `549ea53a845c9d8a2a022300b68db4325373b97c703918820899c0e64fac55b3` |
     | `RESPOSTA_chat_A1_ajustes_20261008.md` | `2f08e45173511104874580c5758bc029536bdc05b652f4b171203382a10a21aa` |
     | `RESPOSTA_chat_A1_auditoria_20261008.md` | `cb0422f421a1b6813b9bec0de1f5b1a4b5153147db90b8bc57869d4ec0257d85` |
     | `PROMPT_artigo1_prematuridade_FASE0A_rerun_20261008.md` | `6fc707ab268c94e00f92a470ba80b54bd9bc9785324e21ea3d8f246236f3e93a` |
   **A especificação congelada não é editada:** ela entra no commit exatamente como está no Projeto. Onde este documento muda algo (hash da base, errata, valores observados), vale este documento, por regra de leitura.
3. **Registro:** o Claude Code calcula o SHA-256 de cada arquivo de `spec/` e de `docs/coordenacao/`, grava-os num manifesto no próprio commit, faz o commit, cria uma **tag anotada** `spec-v2.0.2-congelada-AAAAMMDD` e faz o push para o GitHub. O horário do push fica registrado no servidor.
4. **Quando:** depois que esta Revisão 2 final estiver publicada no Projeto e o chat do Artigo 1 confirmar, antes do commit, as conferências que dependem dele (seção 6, condição 4; nota de leitura da seção 11). As confirmações da seção 3, a checagem dos Arranjos (seção 4), a base nova (seção 8) e a Fase 0 refeita (seção 11) já estão feitas.
5. **Regra:** nenhum modelo de desfecho, em nenhum dos três artigos, roda antes dessa tag. Depois dela, qualquer mudança é desvio, registrado em `logs/desvios_especificacao.md` antes de rodar.
6. **Na submissão:** tornar a tag pública ou arquivá-la com DOI (Zenodo ou REDU) e citar o DOI em Methods, porque um repositório privado não é verificável por revisores.

### 1.2 Como ler a especificação depois desta decisão

- Todo "antes do OSF" / "antes do pré-registro" passa a ser **"antes da tag de congelamento"** (§0 linha vermelha, §1.1 AT, §3.2 regra de γ, §5 Arranjos, §6 metapreditores exploratórios, §9.3 item 1, §10.3 pendências 1 e 7, §12).
- "Pré-registrado" e "pré-registro" (§3.3 diagnóstico de identificação, §9.1 item 5, §9.2 sensibilidades-chave) leem-se como **"pré-especificado na versão congelada"**.
- Em Methods: "prespecified analysis plan, version-controlled before any outcome analysis (commit [hash], [date]; archived at [DOI])". **Nunca** "preregistered" nem "registered protocol".
- No guia editorial do Projeto (`orientacoes/AJOG_MFM_orientacoes_editoriais.md`), o checklist A, item 2 ("Pré-registro no OSF"), lê-se "tag de congelamento".
- A referência da fórmula de temperatura aparente (Kalkstein & Valimont, §1.1) não bloqueia a tag, porque a fórmula já está fixada: é verificada antes da redação do eMethods.

## 2. Ética: sem submissão ao CEP

- **Decisão:** dados públicos e desidentificados do SINASC e do SIM (DATASUS), sem submissão ao Sistema CEP/Conep.
- **Base legal:** Resolução CNS nº 674/2022, art. 26, **incisos II** ("Pesquisa que utilize informações de acesso público, nos termos da Lei n° 12.527, de 18 de novembro de 2011") **e III** ("Pesquisa que utilize informações de domínio público"). Publicada no DOU de 06/07/2022, Seção 1, p. 160 (texto conferido em 08/10/2026).
- **Não citar o inciso V** (dados "já disponibilizados de forma agregada"): a base parte de registros individuais desidentificados; só as saídas são agregadas.
- **O que a revista pede:** o guia do AJOG MFM exige "ethics committee approval (or documented exemption ...) and informed consent (or documented waiver of consent), both of which must be documented in the paper", e, quando a lei dispensa a aprovação, explicar o motivo e confirmar a proteção de privacidade.
- **Frase-modelo para Materials and Methods (AE):**

  > This study used publicly available, deidentified data from Brazil's national live birth (SINASC) and mortality (SIM) information systems. In accordance with Brazilian National Health Council Resolution No. 674/2022, article 26, items II and III, research using publicly accessible and public-domain information is exempt from review by the research ethics committee system. The requirement for informed consent was waived because only deidentified, publicly available secondary data were used. Individual-level records were analyzed only on a secure local workstation and were never displayed or shared; all reported outputs are aggregated, with counts below 10 suppressed, in compliance with Brazil's General Data Protection Law.

- **Declaração formal de dispensa: não será obtida (opção B, decisão de Guilherme em 09/10/2026).**
  - **Mudança em relação à especificação** nos pontos que mandavam obter declaração formal de dispensa do CEP da UNICAMP ou da coordenação do PPG quando não houvesse CAAE: §8 (Ética), §10.3 (pendência 2), §12 (item 10) e Anexo A (linha Ética). A frase de Methods se apoia só na resolução (frase-modelo acima, sem acréscimo).
  - **Risco declarado:** o guia do AJOG MFM pede "documented exemption". Se o editor pedir a declaração na revisão, ela é obtida nesse momento; isso não muda o método.
  - A lista de verificação do guia editorial do Projeto (`orientacoes/AJOG_MFM_orientacoes_editoriais.md`, checklist A, primeiro item) lê-se conforme esta decisão.
  - Se já houver CAAE (do doutorado ou do CliMaterna) que cubra estas análises, citá-lo continua permitido e é mais forte.
- As pendências 1 (OSF) e 2 (ética) da §10.3 ficam fechadas.

## 3. Decisões da auditoria B.3 (confirmadas)

**Confirmadas por Guilherme em 08/10/2026, às 14h04**, gravadas literalmente em `logs/confirmacoes_pre_tag.md` (pasta do Artigo 1). Valem como estão na v2.0.2:

1. **Óbito perinatal:** γ = 1 no principal; w_j = risco de óbito perinatal suavizado (Poisson, ns 4 gl) e agrupado nas 26 concentrações.
2. **PIG:** contraste primário no 3º trimestre até 36+6 (`s29`…`s37`, `lag = c(28, 36)`), com exposição sustentada no p99 da MM9 e MRT buscada na MM9.


## 4. Pendência 7 (Arranjos do IBGE): fechada

- **Resultado (Fase 0A do Artigo 1, 08/10/2026):** o IBGE não publicou edição nova. O Censo 2022 divulga as concentrações urbanas com a composição de 2016, e as populações de 2022 das 26 concentrações do estudo batem número por número com o SIDRA (tabela 4709, nível N33).
- **Conferido pelo chat de métodos:** a tabela 4709 do SIDRA, nível "Concentração Urbana", tem 185 unidades em 2022, e 28 passam de 750 mil habitantes. As duas além das 26 do estudo são Ribeirão Preto/SP (861.177) e Jundiaí/SP (843.633).
- **Decisão:** as 26 grandes concentrações são a classificação pré-especificada de 2016 (base Censo 2010). Ribeirão Preto e Jundiaí cruzaram o limiar em 2022 e ficam fora. Isso entra como limitação de generalização (§9.1, item 17), **sem sensibilidade nova**.

## 5. Errata da v2.0.2

| # | Onde | Texto da v2.0.2 | Correção |
|---|---|---|---|
| E1 | Anexo B.3, tabela do auditor, linha 12 | "Termo precoce: w_j de parto 37–38 e γ estimado" | **γ = 1**, pela regra única da §3.2 (EP de γ de 0,29–1,68). Vale o corpo (§3.1) |
| E2 | §3.2, regra única de γ, último item | "Nos três, a alternativa é sensibilidade (no PTB e no perinatal, sensibilidade-chave)" | No perinatal, a sensibilidade-chave nº 5 é **w_j = risco de término com γ estimado** (§9.2). "γ estimado com o w_j principal" é sensibilidade comum (§10.2), não chave |
| E3 | §3.3, secundários do PIG | "ORs por semana" sem nível de exposição | OR de cada semana `s{k}` com exposição no **p99 e no p1 da distribuição semanal** (a da §1.2), contra a MRT do primário |
| E4 | §8, figuras | — | O manuscrito (.docx) vai **sem texto justificado**, como pede o guia da revista; o texto justificado do estilo do grupo vale só para relatórios internos |
| E5 | Toda a §3.4 (códigos, classificação, construção) e pendência 4 da §10.3 | `STTRABPART`, `PARTO` | Na base, os nomes estão em minúsculas: leia-se `sttrabpart`, `stcesparto_aj` e `parto` (verificado na A4 do Artigo 1) |
| E6 | §5, critério 3 e sensibilidade de 2.000 | "≥ 1.000 eventos no período" | Os cortes de 1.000 e de 2.000 eventos aplicam-se à **janela principal** de cada artigo agudo (resultado na seção 9: 26/26 e 23/26). No PIG, a população é a `pop_pig_principal` (partos de 2012-01-04 a 2024-12-27), e os mínimos por curva da §5 já valem |
| E7 | §3.5, definição | "IG pela DUM" | Esclarecimento: IG pela DUM = `ig_dum_sem` = ⌊(`DTNASC` − `DTULTMENST`)/7⌋, em semanas completas (seção 8) |
| E8 | §2.3, regra do PM2.5 secundário | "a perda chegaria a 15,2%" (Campo Grande) | Com o denominador das janelas principais, o teto é de 16,05% a 16,20% (seção 10) |
| E9 | §3.5 (nome, população e desfecho) e todas as menções a "consistência interna da IG" (resumo executivo, §3.1, §3.3 (f), §9.1 item 14, §10.2, §10.3 pendência 4, §12 item 8, Anexo A) | "Consistência interna da IG" | "Sensibilidade restrita aos nascimentos com IG datada pela DUM", com o desfecho em duas versões (`SEMAGESTAC` e `ig_dum_sem`) (seção 12) |
| E10 | §9.1, item 14 | Qualidade da IG no SINASC | Acrescentar a limitação da diferença entre `SEMAGESTAC` e a semana completa pela DUM (seção 12, item 6) |

## 6. Sigilo (reafirmação da §8)

Microdado nunca sai da Forja. Saídas que saem: agregados por concentração × ano (ou mais grosso), com "<10" e supressão complementar, e resultados de modelo (coeficientes, EP, matrizes de covariância, curvas e estimativas). Séries diárias por concentração não saem.

**Exceção registrada (desvio 9 da Fase 0A do Artigo 1):** a coluna "Perda" da tabela A5.2 (pendência 10) conta eventos por concentração nas pontas fora da janela principal. No PTB, são 2012-01-01 a 2012-04-13 e 2024-08-07 a 2024-12-31; no perinatal, as pontas equivalentes. É um agregado de menos de um ano, mais fino que concentração × ano.
- **Aprovada pelo chat de métodos**, por recomendação do chat do Artigo 1, sob quatro condições:
  - vale só para essa tabela descritiva, na RESPOSTA de 08/10 e na RESPOSTA refeita (seção 11). Não se estende a outra saída nem a outro artigo sem novo registro;
  - nenhuma célula de 1 a 9: na Fase 0A, a menor perda diferente de zero foi 40;
  - nenhuma contagem menor que 10 recuperável por subtração, contra os totais anuais ou outras tabelas já publicadas;
  - as duas condições anteriores são conferidas de novo sobre as tabelas da RESPOSTA refeita (A5.2 e A7), pelo chat do Artigo 1, antes do commit de congelamento.
- Se a RESPOSTA refeita tiver célula de 1 a 9, a coluna sai como "<10", com supressão complementar.
- **Situação na RESPOSTA refeita:** a coluna "Perda" é idêntica à de 08/10 (CSV `a5_2_eventos_janelas.csv` igual byte a byte; seção 11). A conferência da A7, que é tabela nova, fica com o chat do Artigo 1 antes do commit (condição 4).
- **Escopo ampliado (Revisão 2 final):** a tabela A7 na janela principal, junto com a A5.1, permite derivar outro agregado de menos de um ano: os NV fora da janela principal nas 26 concentrações somadas (13.791.848 − 13.509.914 = 281.934) e, se a A7 por concentração trouxer os NV da janela, também por concentração. Fica coberto por esta mesma exceção, com as mesmas condições (nenhuma célula de 1 a 9; nenhuma recuperação por subtração), conferidas antes do commit.
- **A A7 por ano cobre só 2013–2023**, por decisão de Guilherme, porque 2012 e 2024 não são anos inteiros na janela principal.

## 7. Distribuição semanal de referência do PIG (decisão)

- **Decisão:** a "distribuição semanal" da §1.2 é a **leitura (i)**: todos os valores `s01`…`s37` de cada `dum_est` único de 2011-04-17 a 2024-03-05, por concentração, empilhados, sem ponderação por pessoa.
- **Vale para:** os nós p10/p75/p90 da `argvar` do PIG (§1.2); os nós da curva combinada (§6, "média dos p10/p75/p90 semanais"); o nível de exposição dos ORs por semana (errata E3); e o "percentil semanal equivalente" do p99 e do p1 da MM9 (§3.3).
- **Extensão à MM14 (decisão nova):** a §3.3 só define para a MM9 a regra "para cada `dum_est` único, sem ponderação por pessoa". Esta revisão estende a mesma regra à MM14 dos trimestres secundários (`s01`…`s14` e `s15`…`s28`) e ao seu percentil semanal equivalente.
- **Leitura descartada (ii):** cada média de 7 dias do calendário contada uma vez (4.959 janelas, com início de 2011-04-17 a 2024-11-12).
- **Por que a (i):**
  - é a leitura literal da §1.2 ("as mesmas que formam `s01`…`s37`"; "todas as datas de início únicas de 2011-04-17 a 2024-03-05");
  - é a mesma regra da MM9 (§3.3: "para cada `dum_est` único ..., sem ponderação por pessoa");
  - tem a estrutura da tabela `expo_semanal` (chave `recorte_principal` + `dum_est`, colunas `s01`…`s37`), com um conjunto por `dum_est` único e sem a ponderação por nascimento que a §1.2 exclui. Não é a distribuição que entra no modelo: a cross-basis é montada sobre células município × `dum_est` × covariáveis, em que os valores se repetem conforme os nascimentos.
- **Contra a (i), declarado:**
  - a (ii) seria a análoga da regra dos agudos e do MCC, em que cada dia do calendário conta uma vez (§1.2, nós da `tmean` diária);
  - a (i) dá peso menor a 504 das 4.959 janelas, as de 2011-04-17 a 2011-12-24 e as de 2024-03-06 a 2024-11-12. São estações e anos específicos, o que explica parte da diferença de até 0,298 °C;
  - nenhuma das duas é a distribuição que a coorte experimentou;
  - o texto "datas de início únicas de 2011-04-17 a 2024-03-05" admitiria uma terceira leitura (só os valores de `s01`), que o parêntese "as mesmas que formam `s01`…`s37`" afasta.
  - **Por que não pesa:** os nós e percentis só precisam cobrir bem a faixa de exposição; a escolha é fixada antes de qualquer desfecho e vale igual para as 26 concentrações.
- **O que muda na prática:** na (i), as janelas do miolo entram 37 vezes e as das pontas, de 1 a 36 vezes. Por isso os percentis diferem até 0,298 °C da (ii), e em 45 dos 130 pares concentração × percentil a diferença passa de 0,05 °C (Fase 0A). O chat de métodos reproduziu o mecanismo com série sintética (pesos de 1 a 37; 4.959 janelas).

## 8. `DTULTMENST` e a sensibilidade da §3.5 (decisão; a §3.5 é redefinida na seção 12)

- **Situação:** `DTULTMENST` não está na base `7e99bf94`, e a §3.5 (usada no PTB e no PIG) depende dela. A §3.5 já previa que isso "exige versão nova da base, a autorizar".
- **Decisão: opção (a), versão nova da base antes da tag**, com uma única coluna derivada nova, `ig_dum_sem`. A data bruta da DUM não entra na base (minimização de dados).
  - `ig_dum_sem` = ⌊(`DTNASC` − `DTULTMENST`)/7⌋, em semanas completas, na mesma escala do `SEMAGESTAC`. O ⌊·⌋ é esclarecimento da §3.5, que dizia só "IG pela DUM" (errata E7);
  - **DUM inválida → NA:** data ausente, data não analisável, data posterior ao parto ou data anterior a parto − 50 semanas, isto é, diferença maior que 350 dias. O corte é aplicado em dias, **antes** do ⌊·⌋: 351 a 356 dias dariam ⌊·⌋ = 50, mas são NA;
  - **regra de uso (§3.5):** DUM plausível quando `ig_dum_sem` vai de 20 a 45 semanas, inclusive; registro concordante quando |`SEMAGESTAC` − `ig_dum_sem`| ≤ 1;
  - **Acesso:** `ig_dum_sem` fica acessível por `nascimentos()`, de onde a §3.5 recalcula Z_t e w_j na população restrita, e por `pig(com_nascimentos = "ig_dum_sem")`, em R e em Python, com junção 1:1 por `id_nasc`, testada nas duas linguagens (seção 11).
- **Pendência 4 da §10.3: fechada.** `sttrabpart`, `stcesparto_aj` e `parto` estão acessíveis por `nascimentos()` (nomes em minúsculas; códigos da §3.4 conferidos na A4 do Artigo 1; errata E5). A DUM fecha com `ig_dum_sem`.
- **Quem faz:** a sessão da base gera a versão nova, com o relatório de integridade (prompt próprio, emitido pelo chat de métodos em 08/10/2026). Em seguida, a Fase 0 do Artigo 1 rodou de novo sobre ela; os números não mudaram, e o resultado está na seção 11.
- **O hash novo substitui `7e99bf94`** em todos os pontos onde ele aparece:
  - na especificação v2.0.2, **por regra de leitura** (o arquivo congelado não é editado): cabeçalho (Âmbito), §8 (tabela, bloco de código com `stopifnot(versao() == ...)` e frase-modelo de Methods), título da §10.1 e §12. Nenhum script copia o `stopifnot` da §8 literalmente; os scripts usam o hash novo;
  - `CLAUDE.md` e `stopifnot(versao())` dos scripts dos três artigos;
  - os prompts de abertura dos três chats e os prompts de execução já emitidos.
- **Registro:**
  - Hash da versão nova da base: **`4443971b`** (commit da base `2ef7f67`), preenchido na Revisão 2 final, antes do congelamento.
  - Relatório da sessão da base: `RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md`, SHA-256 `5374778d7276a8f8f95507fab2981068157b5bedb60177c5715627850d2b6961`. O relatório não é congelado e não deve ser editado, para não mudar esse SHA-256.
- **Opções descartadas:** (b) arquivo lateral fora do hash da base, porque cria um caminho de dados fora do contrato da base que toda sessão futura teria de lembrar; (c) retirar a §3.5, porque ela sustenta a discussão da datação da IG no SINASC (§9.1, item 14), agora redefinida na seção 12.

## 9. Pendência 10 (recontagens e percentis): fechada

**Fonte que vale: a RESPOSTA da Fase 0 refeita sobre a base nova** (`RESPOSTA_artigo1_prematuridade_FASE0A_rerun_4443971b_20261009.md`, congelada em `spec/`; SHA-256 na seção 11). Os valores da Fase 0A de 08/10/2026, sobre a base `7e99bf94`, ficam só como referência. **Os valores que valem substituem os provisórios (de simulação) da §3.3, da §5 e da §10.1.** São contagens e percentis só de exposição, sem cruzar desfecho com clima.

| Item | v2.0.2 (simulação) | Fase 0A, 08/10 (`7e99bf94`; referência) | Fase 0 refeita (vale) |
|---|---|---|---|
| Perda de eventos pela janela principal, PTB | ~2,3% | 1,97% | **1,97%** (27.667 de 1.405.697); média nas 26 de 2,02% (1,77 a 2,30) |
| Perda de eventos pela janela principal, perinatal | ~3,2% | 2,77% | **2,77%** (4.995 de 180.064); média nas 26 de 2,75% (1,53 a 3,27) |
| Concentrações com ≥ 1.000 eventos na janela principal (errata E6) | 26/26 | 26/26 (PTB mínimo 13.393, Sorocaba; perinatal mínimo 1.424, Florianópolis) | **26/26** (PTB mínimo 13.393, Sorocaba; perinatal mínimo 1.424, Florianópolis) |
| Corte de 2.000 no perinatal (janela principal) | 23/26, provisório | 23/26: saem Florianópolis (1.424), Sorocaba (1.464) e Campo Grande (1.884) | **23/26**: saem Florianópolis (1.424), Sorocaba (1.464) e Campo Grande (1.884) |
| p99 da MM9 em percentil semanal (leitura (i)) | ~p93–94 (faixa ~p89–p99) | média p95,3 (p90,6 a p99,0 entre as 26) | **p95,3** (p90,6 a p99,0) |
| p1 da MM9 em percentil semanal (leitura (i)) | ~p6 (p3,1–p9,1) | média p6,0 (p2,4 a p8,2) | **p6,0** (p2,4 a p8,2) |
| p1 e p99 da MM14, 1º e 2º trimestres (°C, por concentração) | — | Tabela A5.4 | 1º trimestre: p1 21,85 °C (14,49 a 27,23) e p99 27,63 °C (23,05 a 31,04). 2º trimestre: p1 21,90 °C (14,52 a 27,23) e p99 27,63 °C (23,05 a 31,04). Médias e faixas entre as 26; por concentração, na seção 6 da RESPOSTA refeita |
| **Percentil semanal equivalente** do p1 e do p99 da MM14, 1º e 2º trimestres (seção 7) | — | calculado no complemento da Fase 0A (`a5_4b_mm14_equivalentes.csv`, SHA-256 `d6584a135feea42e12221c9b370630b213c470e2a1ad96c006dc9455d6dfd7cc`), com os mesmos valores | 1º trimestre: p1 → **p8,5** (p3,8 a p11,8) e p99 → **p93,4** (p88,0 a p97,9). 2º trimestre: p1 → **p9,1** (p3,8 a p12,7) e p99 → **p93,4** (p88,0 a p97,9) |

**Leitura:** o percentil semanal equivalente da MM14 fica mais perto do centro que o da MM9 (p8,5–9,1 contra p6,0; p93,4 contra p95,3), como se espera de uma média de 14 semanas, que suaviza mais os extremos. O "p99 da MM14" também não é calor semanal extremo, como a §3.3 já diz da MM9.

- **Conferido pelo chat de métodos:** 27.667/1.405.697 = 1,968% e 4.995/180.064 = 2,774%; as perdas por concentração dão 2,16% (PTB, Sorocaba), 2,80%, 2,66% e 2,64% (perinatal, Florianópolis, Sorocaba e Campo Grande), coerentes com as perdas totais. A perda observada, menor que a simulada, é compatível com a diferença entre a simulação (concepções uniformes) e a distribuição real de concepções e nascimentos.
- **Não reproduzido aqui:** os percentis da MM9 e da MM14 dependem da base. Eles passam pela dupla auditoria do Claude Code e do chat do Artigo 1, e o SHA-256 dos CSV permite reconferi-los depois do congelamento.
- **Consequência para o texto:** a frase da §3.3 "p99 da MM9 não é calor extremo semanal" continua valendo, agora com o percentil observado de cada concentração.

## 10. PM2.5, variante secundária (registro)

- Pela regra da §2.3 (≥ 90% dos dias de modelo utilizáveis depois da média móvel de lag 0–1), **Campo Grande, Goiânia e Brasília saem só da variante secundária** `pm25_local_zero_na_nucleo`: ficam entre 87,1% e 88,0% nas duas janelas principais.
- Elas continuam na variante principal (`pm25_local_nucleo`), que é a sensibilidade-chave nº 4.
- Conferido: a falta bruta em 2012–2024 é de 7,60% (Campo Grande, 361 de 4.749 dias) e de 6,99% (Goiânia e Brasília, 332 dias; RESPOSTA do questionamento de 07/10, Q10). Com o denominador das janelas principais (4.498 dias no PTB e 4.456 no perinatal) e supondo que todos os dias sem valor caiam dentro da janela, a perda máxima depois da média móvel é de 16,05% a 16,20% em Campo Grande (722 dias de modelo) e de 14,76% a 14,90% em Goiânia e Brasília (664). Os valores observados (perda de 12,0% a 12,9%) ficam abaixo desse teto. Este teto substitui o "15,2%" da §2.3 (errata E8).

## 11. Fase 0 refeita sobre a base nova

| Campo | Valor |
|---|---|
| Hash da base nova (`versao()`) | `4443971b` (commit da base `2ef7f67`) |
| Relatório da sessão da base | `RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md`, SHA-256 `5374778d7276a8f8f95507fab2981068157b5bedb60177c5715627850d2b6961` |
| Linhas e colunas iguais às de `7e99bf94`, exceto `ig_dum_sem` | **Sim.** Os 43 arquivos têm o mesmo número de linhas. As 51 colunas antigas do `nascimentos.parquet` são idênticas (0 linha diferente; mesmo hash por coluna). Os outros 42 arquivos têm o mesmo md5. Só o `nascimentos.parquet` mudou (md5 `92190228…` → `3a78e7dd…`) |
| `ig_dum_sem` em `nascimentos()` e em `pig()` | `nascimentos()` e `pig(com_nascimentos = "ig_dum_sem")`, em R e em Python. Junção 1:1 por `id_nasc`, testada nas duas linguagens. O `pig_classificacao.parquet` não mudou |
| RESPOSTA da Fase 0 refeita | `RESPOSTA_artigo1_prematuridade_FASE0A_rerun_4443971b_20261009.md` |
| SHA-256 da RESPOSTA refeita | `5e82663e1f8387710a1a861c298399a8816fa446ec247804c58f4c88bb6e4ee8` |
| Diferenças em relação à Fase 0A sobre `7e99bf94` (seção 9) | **Nenhuma.** Os 5 CSV das recontagens são idênticos byte a byte. A MM14 é igual à do complemento da Fase 0A, com diferença máxima de 9,9 × 10⁻¹⁴ |
| Declaração formal de dispensa (seção 2) | Opção B (não obter) |

**SHA-256 dos CSV de percentis e recontagens.** Caminhos relativos à raiz do repositório `artigos_perinatais_clima/`; os arquivos ficam fora do git.

| Caminho | SHA-256 | Sustenta |
|---|---|---|
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_1_totais.csv` | `0fe49f86efe2cc3e31c4aa571850b946706a4ef9180d32dc2e979d536ad0642f` | totais 2012–2024 |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_2_eventos_janelas.csv` | `a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5` | eventos e perdas por janela |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_3_percentis_diarios.csv` | `fa3b8fb141c3b4f306d01201a99af51db5c1469bb5a0b43116b58fd678701650` | percentis da `tmean_nucleo` diária |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_4_semanal_mm.csv` | `c054d81c68aba88e1975380a2d9f2e202fb8694b50f55338ff6881b0eaef8ca6` | distribuição semanal (i) e (ii), MM9, MM14 (°C), equivalente da MM9 |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv` | `df239471aeee2a16982c70d1b019105a8ce26615fb2918052bc95049c7a00d63` | MM9 e MM14 (°C) e os percentis semanais equivalentes |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_5_pm25_dias_utilizaveis.csv` | `afd134c5931677193aeee11d962c8c8ad78462d2b85e5ff311dd29f95e0e0752` | PM2.5, dias utilizáveis |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a7_populacao_dum_ano.csv` | `8900d5f94c77a11042890e438af4428f86f72d6343666f2e560bd3ee0a9d8da1` | população da §3.5 por ano (2013–2023) |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv` | `82204b6b25ae61c74b1cfe891789447620662fc7d1966a37e24bd59dde98f64e` | população da §3.5 por concentração |

**Nota de leitura da RESPOSTA refeita.** A RESPOSTA refeita é um retrato de 09/10/2026, anterior a esta Revisão 2 final. Os trechos dela que citam estas decisões "em rascunho", a versão original destas decisões (SHA-256 `20fc42e4…`), campos "a preencher na Parte B" e a ética "em aberto" ficam superados pelos documentos de `spec/`. A conferência da tabela da seção 9 contra a RESPOSTA refeita foi feita pelo chat do Artigo 1 antes da liberação do congelamento (Parte B).

## 12. Sensibilidade da §3.5: redefinição (decisão do chat de métodos, 09/10/2026)

**Achados da Fase 0 refeita (A7 e Tabela 3 do relatório da base), que motivam a mudança:**
- **O critério de concordância quase não exclui ninguém:** |`SEMAGESTAC` − `ig_dum_sem`| ≤ 1 vale em ≥ 99,9% dos registros com DUM, em todos os anos. A restrição real é ter DUM.
- **É uma subpopulação selecionada:** o nível com DUM plausível e concordante mantém 40,25% dos NV e 48,33% dos PTB da população do PTB na janela principal. A proporção de PTB sobe de 10,20% para 12,25%, e em todas as 26 concentrações a fração de PTB mantida é maior que a de NV.
- **A cobertura é desigual:** de 11,26% dos NV (Aracaju) a 79,73% (São Luís), e de 53,67% em 2013 a 33,44% em 2023.
- **De 2013 em diante, há DUM praticamente só nos registros com `TPMETESTIM` = 8.** O significado desse código não está confirmado no dicionário oficial do SINASC. Nenhuma frase de Methods atribui significado ao código 8 sem essa confirmação.
- **O `SEMAGESTAC` não é a semana completa pela DUM:** nos NV únicos comparáveis de 2011–2024 (n = 6.292.441), a igualdade exata entre `SEMAGESTAC` e ⌊dias/7⌋ é de 78,68%; nos demais, a diferença é de ±1 semana. Quando sobram de 4 a 6 dias, 25% a 28% sobem uma semana; quando sobram 0 dias, 38,5% descem uma; nos anos bissextos, a igualdade cai cerca de 6 pontos. O mecanismo não está determinado.
- As 26 concentrações ficam com ≥ 1.000 PTB na subpopulação, pelo `SEMAGESTAC` (versão (i) abaixo): a sensibilidade é viável. A contagem pela versão (ii) é conferida antes de rodá-la.

**Decisões (errata E9 e E10):**
1. **Nome e leitura:** a §3.5 passa a ser **"sensibilidade restrita aos nascimentos com IG datada pela DUM"**, não "consistência interna da IG". Methods declara que a subpopulação tem prevalência de PTB maior e cobertura desigual entre concentrações e anos.
2. **Elegibilidade (igual nas duas versões):** NV únicos residentes nas 26 concentrações com `SEMAGESTAC` de 22 a 42 **e** `ig_dum_sem` de 22 a 42 semanas, inclusive, e |`SEMAGESTAC` − `ig_dum_sem`| ≤ 1. A faixa de 22 a 42 no `ig_dum_sem` (mais estreita que a regra de uso de 20 a 45 da seção 8) garante que nenhum PTB fique fora de Z (semanas 22 a 36) e que nenhuma gestação da coorte fixa nasça depois de 31/12/2024 (s máximo + 7·42 + 3 = 2024-12-27). O critério de concordância continua, por coerência com a §3.5, mas Methods diz que ele quase não exclui ninguém.
   - **Coorte fixa:** cada versão aplica a sua, com as mesmas datas da §5, partindo de **todos** os NV únicos elegíveis, e não da população principal já filtrada pela coorte do `SEMAGESTAC`. Na versão (i), pelo `dum_est` do `SEMAGESTAC`; na (ii), pelo `dum_est` do `ig_dum_sem`. Perto das bordas, as duas versões podem diferir em poucas gestações; declarar. A `nascimentos()` traz os nascimentos fora da coorte (a flag `coorte_fixa_22` é coluna), o que permite essa construção.
   - **Janela principal:** a mesma do artigo (PTB: 2012-04-14 a 2024-08-06), nas duas versões.
   - **γ:** segue a regra do principal (no PTB, estimado; γ = 1 como sensibilidade).
3. **Desfecho em duas versões, na mesma subpopulação:**
   - **(i)** PTB pelo `SEMAGESTAC`, como no principal;
   - **(ii)** PTB por `ig_dum_sem` ≤ 36, em semanas completas. Nesta versão, a IG em todo o desenho é `ig_dum_sem`: `dum_est` = DTNASC − (7 × `ig_dum_sem` + 3), coorte fixa com as mesmas datas da §5, e Z_t e w_j recalculados com `ig_dum_sem`. A versão (ii) testa a sensibilidade do resultado à diferença entre o `SEMAGESTAC` e a semana completa pela DUM.
4. **Z_t e w_j:** recalculados na subpopulação, nas duas versões, como a §3.5 já previa.
5. **PIG:** a mesma elegibilidade, com a população a termo de 37 a 42 semanas. Na versão (ii), tudo usa `ig_dum_sem`: a seleção a termo, o `dum_est`, a `coorte_fixa_37` (as mesmas datas da §5), as exposições `s01`…`s37` (lidas da `expo_semanal` pelo `dum_est` do `ig_dum_sem`) e a IG em dias da curva (7 × IG + 3). A classificação INTERGROWTH é recalculada no artigo, porque o `pig_classificacao.parquet` não mudou: mesmo código e mesma versão do `gigs` (commit fb58fe6), com peso e sexo vindos de `nascimentos()`/`pig()`.
6. **Limitação (§9.1, item 14):** acrescentar que o `SEMAGESTAC` difere da semana completa pela DUM em cerca de 21% dos registros com DUM (±1 semana), o que pode classificar do lado errado parte dos nascimentos perto de 36/37 semanas. **Hipótese declarada:** o padrão por dias restantes e por ano bissexto sugere uma convenção de cálculo de dias, e não um erro ligado ao clima; se for assim, o erro é não diferencial em relação à temperatura diária, e os estratos ano × mês absorvem o efeito do bissexto. O mecanismo não está determinado. Vale para os três artigos (inclusive a coorte a termo e o escore z do PIG).
