# Decisões de método — 19/10/2026, D17: errata da D16 (linha 57) e regras da tabela de feriados locais

**De:** chat de métodos · **Data:** 19/10/2026 · **Origem:** pedido da COORD (19/10), encaminhando o A1 (A1-107, item 10; A1-110; A1-112)
**Âmbito:** Artigos 1 e 2. O item 1 corrige uma frase que só vale para o A1 (D16, item 3). O item 2 vale para os dois, porque a tabela é comum aos agudos (D11, 3.3).
**Corrige:** `decisoes_metodo_20261016_AGUDOS_D16_ns_tempo_nula_pacf_zfetal.md` (SHA-256 com o `\n` final: `2e681460c63469817737fd010eef364e8a0c448497080f4fb59a07311c0ef6ff`; sem ele: `8a816bb80ca9ba801d8f8213752102dcfe2b447dc20de6c5e827c6efeb3276e7`). A D16 não é reeditada.
**Rótulo:**
- **Item 1:** correção de texto, sem análise nova.
- **Item 2:** regras de construção da tabela, decididas sem nenhum resultado da sensibilidade de feriados locais. Onde a D17 altera uma regra do A1, ela diz isso. As alterações são *post hoc* em relação ao primário, mas não usam resultado nenhum.

---

## Resumo

| # | Item | Decisão |
|---|---|---|
| 1 | D16, l. 57: DP do acréscimo de `z_fetal` em log Z_t | **Frase corrigida:** o DP intra-estrato é da ordem de 10⁻⁴, e não de 10⁻⁵. A unidade é o **estrato** (concentração × ano × mês) |
| 2 | Critério da tabela | **Alterado:** a linha divide **feriado** de **ponto facultativo**, e não lei de decreto. Entra a data que foi feriado do ente naquele ano, por lei ou por decreto que a declare feriado. Ponto facultativo fica fora, menos 24/12 e 31/12, que entram pela letra da D11 |
| 2a | Meio feriado fica fora | **Ratificada** |
| 2b | Corpus Christi antecipado entra como local | **Ratificada, com alteração:** entra a data nova; a data original do feriado antecipado sai da tabela local naquele ano |
| 2c | "Só por decreto, sem lei, fica fora" (DF 30/11; AL 30/11; AL 16/09 de 2011 a 2023) | **Substituída pelo critério 2.** As três datas foram revistas: DF 30/11 entra em 2011–2024; AL 30/11 entra de 2018 em diante; AL 16/09 entra em 2011–2024 |
| 2d | Eventos do Rio ficam dentro | **Ratificada, com alteração:** entram os que foram declarados feriado; os que foram só ponto facultativo saem |

**Consequência:** a tabela muda, e sai a `feriados_locais-v1.1`. Até ela existir, o A1 pode seguir com a v1.0 em tudo que não depende da sensibilidade de feriados locais, que fica para depois da v1.1.

---

## 1. Errata da D16, item 3 (linha 57)

**Texto da D16:**
> Incluir `z_fetal` muda log Z_t em cerca de +0,005 de nível, com DP intra-mês da ordem de 10⁻⁵ (auditor).

**O que estava errado:** o 10⁻⁵ saiu de uma simulação com Z **liso** (contagens esperadas, só com a sazonalidade das concepções). Ela deixava de fora o ruído de contagem dos óbitos fetais em Z_tj, que domina a variação dentro do estrato.

**Medida do A1 na janela principal, nos 3.874 estratos:**
- nível médio de +0,0054 (confere com a D16);
- DP intra-estrato com mediana de 2,7 × 10⁻⁴ (p10–p90 de 1,3 × 10⁻⁴ a 5,3 × 10⁻⁴).

**Reproduzido** (concepções Poisson diárias, óbitos fetais em cerca de 0,6% dos NV):

| Fonte | 25 NV/dia | 700 NV/dia | Z liso |
|---|---|---|---|
| `repro_d17.py` (chat de métodos) | 3,8 × 10⁻⁴ | 7,3 × 10⁻⁵ | 0 (sem sazonalidade) |
| Auditor independente (script próprio) | 3,9 × 10⁻⁴ (p10–p90 de 2,4 a 6,7 × 10⁻⁴) | 7,9 × 10⁻⁵ | 2,9 × 10⁻⁶ (com sazonalidade de 5%) |

- Os dois cercam o valor do A1. O DP cai com cerca de N^(−1/2).
- **Decomposição (auditor, 25 NV/dia):** só com ruído nos óbitos fetais, 3,65 × 10⁻⁴; só com ruído nos NV, 2,4 × 10⁻⁵. Ou seja, a variação vem dos óbitos fetais.

**Frase corrigida (substitui a da D16, l. 57):**
> Incluir `z_fetal` muda log Z_t em cerca de +0,005 de nível. A variação dentro do estrato (concentração × ano × mês), que é a que o modelo condicional enxerga, tem DP mediano de 2,7 × 10⁻⁴ (p10–p90 de 1,3 × 10⁻⁴ a 5,3 × 10⁻⁴; medida do A1 na janela principal). Ela vem sobretudo do ruído de contagem dos óbitos fetais em Z_tj. A faixa reflete o tamanho da concentração e a variação entre meses.

**Unidade:** o **estrato**. Numa concentração, "intra-mês" e "intra-estrato" são a mesma coisa, porque o estrato é concentração × ano × mês. "Intra-estrato" fica como termo canônico.

**Nada muda:**
- a decisão do item 3 da D16 (w_j do principal) continua. A comparação com o recálculo do w_j (3,5 × 10⁻⁶) é entre duas formas de w_j com o **mesmo** Z, e o ruído de contagem cai igual nas duas;
- "a sensibilidade quase reproduz o principal" continua valendo. Um DP de cerca de 10⁻⁴ no log do offset fica três ordens de grandeza abaixo do ruído diário do desfecho: com 3 PTB por dia, o DP do log da contagem é da ordem de 1/√3 ≈ 0,6. Se esse ruído não se correlaciona com a temperatura, o efeito esperado nas estimativas é desprezível;
- o nível simulado (+0,0035 a +0,0043) depende da fração suposta de óbitos fetais. O +0,0054 do A1 é compatível com uma fração real perto de 0,75% (auditor).

---

## 2. Regras da tabela de feriados locais (`feriados_locais-v1.0`, commit `2ab924d`)

**A tabela v1.0:** SHA-256 `ef5d99b1bfb1d0a33f44ad057e8b542015ce61aa9da5fb3d73caf117daba2e03`, 1.103 linhas e 25 núcleos (Brasília sem feriado local). Eu não li a tabela. O que segue trata das regras e das datas citadas no pedido.

### 2.0 Critério: feriado × ponto facultativo, e não lei × decreto

**O objetivo da sensibilidade é comportamental:** captar os dias em que os serviços, e com eles o agendamento de partos, funcionaram como feriado (D11, 3.1 e 3.3). A validade jurídica do ato não é o que interessa. A auditoria mostrou que a linha "lei × decreto" erra nos dois sentidos:
- AL 16/09, de 2011 a 2023, foi observado como "feriado estadual" por decreto anual, e ficaria fora;
- AL 30/11, de 2014 a 2017, tinha lei, mas não estava no calendário oficial do estado, e entraria.

**Critério (substitui a regra 2c do A1 e o da primeira versão desta D17):**
1. **Entra** a data que, naquele ano, foi **feriado** do estado, do DF ou do município-núcleo:
   - **por lei**, estadual, distrital ou municipal, inclusive a de alcance restrito à administração pública local. Presume-se observada, salvo prova em contrário no calendário oficial do ente;
   - **ou por decreto que a declare feriado**, com ou sem autorização legal específica. Por exemplo, os decretos anuais de feriados de Alagoas e o Decreto municipal de SP 59.450/2020, editado com a autorização da Lei 17.341/2020.
2. **Fica fora** a data que foi só **ponto facultativo**. Exceção: **24/12 e 31/12 entram sempre**, pela letra da D11 (§4 da v2.0.2: "mais 24/12 e 31/12").
3. **Fica fora** nos anos em que a lei ou o decreto **não teve eficácia**: suspensão por liminar, inconstitucionalidade declarada ou revogação.
4. **Fonte de cada linha:** o ato que a sustenta (lei ou decreto, número, ano, URL) e, quando houver, o calendário oficial do ano. O `README` lista as datas excluídas e o motivo.

**Fundamento legal citado no `README` (só como contexto, sem julgar a compatibilidade de cada lei):** Lei nº 9.093/1995. O art. 1º, I a III, trata dos feriados civis (lei federal; data magna do estado em lei estadual; centenário do município em lei municipal). O art. 2º trata dos feriados religiosos ("dias de guarda, declarados em lei municipal", até quatro, contando a Sexta-Feira da Paixão). O DF acumula as competências estadual e municipal (CF, art. 32, §1º).

### 2a. Meio feriado fica fora: ratificada

O indicador é binário (D11, 3.3), meio expediente não tem o mesmo efeito, e a regra é conservadora. O `README` lista as datas que saíram por isso.

### 2b. Feriado antecipado: ratificada, com alteração

- **Entra a data nova** quando o ato que antecipa declara feriado (critério 2.0, item 1).
- **A data original do feriado local antecipado sai da tabela naquele ano.** Exemplo: em SP, em 2020, o Decreto 59.450/2020, com a autorização da Lei 17.341/2020, art. 3º, antecipou Corpus Christi e Consciência Negra para 20 e 21/05/2020. Logo:
  - 20 e 21/05/2020 entram;
  - 20/11/2020 sai da tabela local de SP;
  - 22/05/2020 foi ponto facultativo e fica fora.
- **Corpus Christi:** a data original continua marcada em `moveis`, indicador nacional do modelo principal que não muda por concentração. Declarar no `README`. O caso cai quase todo em 2020–21.
- **O A1 confere** as antecipações estaduais e municipais de 2020–21 nos 25 núcleos (inclusive o RJ) pelo mesmo critério.

### 2c. As três datas citadas: revistas

| Data | Ato encontrado | Na tabela |
|---|---|---|
| **DF, 30/11** (Dia do Evangélico) | **Lei Distrital nº 963, de 04/12/1995**: feriado da administração direta, indireta e fundacional do DF. Não vale para órgãos federais (TRF1; TJDFT, 2020), mas a rede de saúde do DF é distrital | **Entra em 2011–2024.** Com isso, "Brasília sem feriado local" deixa de valer |
| **AL, 30/11** (Dia do Evangélico) | **Lei estadual nº 7.530, de 08/08/2013**: o art. 1º institui o Dia Estadual do Evangélico; o art. 2º está "(VETADO)" no texto do SAPL. A Assembleia derrubou o veto em 26/03/2014, mas o ato de promulgação não foi achado. O estado passou a observar a data **a partir de 2018**, por decreto de dezembro de 2017 | **Entra de 2018 a 2024**; fica fora em 2011–2017 (não estava no calendário oficial) |
| **AL, 16/09** (Emancipação Política) | Decretos anuais do governo, que a chamam de "feriado estadual"; desde 2024, a **Lei estadual nº 9.358, de 26/08/2024**. Não achei lei anterior: a Lei 5.724 citada nos decretos e o ADCT da Constituição estadual não foram conferidos | **Entra em 2011–2024**, se o decreto de cada ano a declarar feriado (o A1 confere ano a ano) |

### 2d. Feriados por evento no Rio: ratificada, com alteração

Entram os dias de eventos que o estado ou o município do Rio **declarou feriado**, por lei ou decreto. Os que foram só ponto facultativo ficam fora. O A1 confere o ato de cada um.

### 2e. Lacunas fechadas

- **20/11 antes de 2024:** entra no núcleo e no ano em que foi feriado local com eficácia. Se a lei local estiver suspensa por decisão judicial naquele ano, fica fora (critério 2.0, item 3). Desde 2024 é nacional e fica só em `feriado_nacional`.
- **Feriado com data móvel por lei de evento:** entra a data efetiva do ano.
- **Limitação a declarar (letra da D11):** só os feriados do município-núcleo. Mães residentes em outros municípios da concentração podem ter tido outro calendário. Isso vai como limitação no `README` e em Methods.

### 2f. O que o A1 faz

1. Refaz a tabela pelo critério 2.0, com as datas do 2c e os casos do 2b e do 2d. Para os municípios-núcleo, confere se algum feriado municipal saiu da v1.0 só por ser decreto.
2. Auditoria independente das linhas novas ou alteradas antes da tag (D11, 3.3).
3. A coordenação commita no `comum` e põe a tag `feriados_locais-v1.1`. Os logs do A1 e do A2 passam a citar a v1.1 e o SHA dela.

---

## Registro no log (A1 e A2; commit próprio)

> - **D17 (19/10):** `spec/decisoes_metodo_20261019_AGUDOS_D17_errata-D16_feriados_locais.md` (SHA-256 ⟨conferido⟩).
>   - Errata da D16, l. 57: DP intra-estrato do acréscimo de `z_fetal` em log Z_t da ordem de 10⁻⁴ (mediana de 2,7 × 10⁻⁴), e não de 10⁻⁵; unidade: estrato. Nenhuma análise muda.
>   - Feriados locais: critério feriado × ponto facultativo (lei ou decreto que declare feriado; ponto facultativo fora, menos 24/12 e 31/12; sem eficácia, fora). DF 30/11 em 2011–2024; AL 30/11 em 2018–2024; AL 16/09 em 2011–2024, conferido ano a ano; SP 2020 antecipado (20 e 21/05 entram, 20/11 sai). *Post hoc* em relação ao primário; nenhum resultado da sensibilidade de feriados visto. Tag em uso: ⟨`feriados_locais-v1.1`, SHA⟩.

---

## A. Auditoria

### A.1 Autoauditoria

| Ponto | Conferência | Resultado |
|---|---|---|
| DP intra-estrato com ruído de contagem | `repro_d17.py` | 7,3 × 10⁻⁵ (700 NV/dia) a 3,8 × 10⁻⁴ (25 NV/dia); 0 com Z liso sem sazonalidade |
| DF 30/11 | TJDFT (nota de 2020) e TRF1 (Lex) citam a Lei Distrital 963/1995 | Confirmado |
| AL 30/11 | SAPL-AL, Lei 7.530/2013 (texto: art. 1º institui o dia; art. 2º "(VETADO)"); Tribuna do Sertão (veto derrubado em 26/03/2014); TNH1 (observância desde 2018, decreto de dez/2017) | Confirmado; promulgação do art. 2º não achada |
| AL 16/09 | SAPL-AL, Lei 9.358/2024 (ementa: "feriado estadual da Emancipação Política… dia 16 de setembro") | Confirmado para 2024; antes, só decretos |
| SP 2020 | AASP: Lei 17.341/2020, art. 3º ("Fica autorizado o Poder Executivo a antecipar feriado municipal, por decreto"); Decreto 59.450/2020, art. 1º (antecipação para 20 e 21/05/2020) e art. 2º (ponto facultativo) | Confirmado. Que o 20/11/2020 deixou de ser feriado em SP é inferência da antecipação |

### A.2 Auditoria independente

O auditor (subagente em contexto limpo; scripts próprios `sim_zfetal_indep.py` e `decomp_ruido.py`; não abriu o meu script) não achou nenhum erro crítico; achou 5 Maiores, 6 Menores e 2 Notas. Cada achado foi conferido por mim (código ou leitura das fontes) antes de ser aceito.

| Achado | Grav. | Minha conferência | Correção |
|---|---|---|---|
| 1. AL 30/11: a lei é a 7.530/2013, não "de 2014"; observância só desde 2018 | Maior | SAPL (texto da lei) e TNH1 | Data e ato corrigidos; entra de 2018 em diante |
| 2. AL 16/09: Lei 9.358/2024 existe | Maior | SAPL (ementa) | 2024 por lei; 2011–2023 pelos decretos que a declaram feriado |
| 3. O critério lei × decreto mede validade jurídica, mas o objetivo é comportamental, e erra nos dois sentidos | Maior | AL 16/09 (decretos) e AL 30/11 (lei sem observância), conferidos acima | **Critério trocado** para feriado × ponto facultativo (2.0) |
| 4. 24/12 e 31/12 são ponto facultativo, mas a D11 manda incluir | Maior | §4 da v2.0.2; D11, 3.3 | Exceção explícita |
| 5. SP 2020: a antecipação foi por decreto com autorização legal | Maior | AASP | Coberto pelo critério 2.0; a data original sai |
| 6. Na Lei 9.093/1995, o religioso está no art. 2º | Menor | Texto citado pelo auditor (Planalto) | Citação corrigida; critério sem juízo de compatibilidade |
| 7. 2b e 2d eram alterações, não ratificações | Menor | Leitura | Rótulos trocados |
| 8. Faltavam regras para suspensão judicial, antecipação do 20/11 e data móvel | Menor | — | Critério 2.0, item 3, e 2e |
| 9. DF: data da lei e vigência no período inteiro | Menor | TJDFT; TRF1 | 04/12/1995; 2011–2024 |
| 10. "A sensibilidade fica mais fraca" estava exagerado | Menor | 1/√3 ≈ 0,58, contra 10⁻⁴ no offset | "Quase reproduz" mantido, com a magnitude |
| 11. A faixa p10–p90 não vem só do tamanho da concentração | Menor | p10–p90 entre meses de 2,4 a 6,7 × 10⁻⁴ a 25 NV/dia (auditor) | Redação corrigida |
| 12. O nível simulado depende da fração de óbitos fetais | Nota | 0,6% → +0,0035 a +0,0043; 0,8% → +0,0058 (auditor) | Nota acrescentada |
| 13. Só os feriados do núcleo | Nota | Letra da D11 | Limitação declarada |

| Script | SHA-256 |
|---|---|
| `repro_d17.py` (chat de métodos) | `5625496e9a676f4c90bf9d4e302c77d3366320973f1d406c4d484bc8908a4467` |
| `sim_zfetal_indep.py` (auditor) | `ebd43e2bfd31bdc607b26f702d8c79dec02a74462db95802fd235754775b73fb` |
| `decomp_ruido.py` (auditor) | `16b5261f869bce312aa10fb71957d6fc3805b5a0651e922be222bcdd4c446164` |

**Fontes da web consultadas:**
- TJDFT, 2020: https://www.tjdft.jus.br/institucional/imprensa/noticias/2020/novembro/tjdft-tem-funcionamento-normal-no-dia-do-evangelico
- Lex/TRF1: https://www.lex.com.br/feriado-do-dia-do-evangelico-instituido-por-lei-distrital-nao-se-aplica-a-orgaos-publicos-federais-com-sede-no-df/
- SAPL-AL, Lei 7.530/2013: https://sapl.al.al.leg.br/media/sapl/public/normajuridica/2013/561/561_texto_integral.pdf
- Tribuna do Sertão, 26/03/2014: https://www.tribunadosertao.com.br/politica/2014/03/26/152636-vitoria-assembleia-derruba-veto-governamental-contra-a-instituicao-do-dia-do-evangelico
- TNH1, 2018: https://www.tnh1.com.br/noticia/nid/alagoas-tera-novo-feriado-em-novembro-confira/
- SAPL-AL, Lei 9.358/2024: https://sapl.al.al.leg.br/norma/3117?display
- AASP, SP 2020: https://www.aasp.org.br/?p=42625
- Lei 9.093/1995 (Planalto, via auditor): https://www.planalto.gov.br/ccivil_03/leis/l9093.htm

**Não verificado:** a tabela v1.0 não foi lida aqui; o ato de promulgação do art. 2º da Lei 7.530/2013 não foi achado; a Lei estadual 5.724 e o ADCT da Constituição de Alagoas não foram lidos.
