# REDU: preenchimento do rascunho do dataset do A1, com dupla auditoria (22/10/2026)

**Pedido de Guilherme na sessão (22/10):** "acesse o redu via claude chrome e faça o preenchimento completo e correto com dupla auditoria".

**Respostas dele na sessão:**
- autores: "Núcleo de 5";
- fomento: "FAPESP 2025/10862-7";
- contato: "Guilherme".

**Login:** feito por Guilherme, com a conta institucional. A sessão não digitou senha nem token.

**Resultado:** rascunho criado no REDU (coleção Biomédicas), `doi:10.25824/redu/PWKND6`.
- Estado: **Draft / Unpublished**.
- Sem arquivos.
- **Não enviado para revisão.**
- Papel de Guilherme no dataset: Contributor.

## Fontes lidas

- **Tutorial oficial do REDU** (SBU, outubro de 2025): o título não pode ser o do artigo; o orientador e o docente responsável entram como coautores; afiliação, fomento ("No Funder"/"0000") e declarações de ética são obrigatórios; o contato é o orientador quando os dados são de tese; "É necessário submeter para revisão"; a equipe do SBU valida e publica.
- **FAQ do SBU:** os 7 campos obrigatórios; "Todos os dados do REDU são públicos"; sem acesso restrito.
- **Guia do Dataverse 6.4:**
  - o Private URL, inclusive o anonimizado, exige o papel de curador;
  - o Contributor só pode "Submit for Review".
- **Depósitos anteriores de Guilherme no REDU (BD3FZL e GDB6VG):** afiliações e ORCID dos 5 autores, o fomento FAPESP 2025/10862-7, a escolha de Custom Dataset Terms e as duas declarações de ética.
- **Registro público do ORCID dos 5 autores:** a grafia "Charles, Charles M'poca" é a do ORCID; nos rascunhos anteriores ela varia.
- **Licenças oferecidas pelo REDU:** CC BY-NC 4.0 (padrão), CC BY-NC-ND 4.0, CC BY-SA 4.0 e Custom Dataset Terms. **Não há CC BY 4.0.** Por isso, Custom Dataset Terms, com MIT para o código e CC BY 4.0 para os documentos, que é a escolha de Guilherme.

## Dupla auditoria

1. **Antes de digitar:** subagente independente sobre a tabela (`Entrega/reproducao/REDU_metadados_v2_20261022.md`, fora do git). Veredito: "pode digitar com correções".
   - **Maiores:**
     - contato, pela regra de tese;
     - SHA da spec contra a cópia anonimizada;
     - a Description prometia reprodução direta.
   - **Menores:** período (a coorte de 2011 está na Tabela S2), idioma (também português), fonte de dados (SIM e feriados), termo do modelo ("multivariate random-effects meta-regression"), frase de sigilo, frase dos logs, Notes com as decisões de 08/10.
   - **Notas:** palavra-chave fora do escopo; "nonlinear".
   - **Tratamento:** todos os Menores e Notas e o Maior da Description foram reproduzidos e corrigidos antes de digitar. Os outros dois Maiores ficam com Guilherme (abaixo).
2. **Autoauditoria depois de salvar:** leitura do rascunho por código.
   - **Erro achado:** o Python tinha caído no campo Series, por um clique fora da linha nova. Corrigido: Series vazio; Software com R e Python.
   - **Releitura depois da correção:** 19 trechos esperados presentes por busca exata. A Description (`edbbff32…`, 2.014 caracteres), a Data Source (`ea09372f…`, 427) e os Terms of Use (`d192371a…`, 288) estão iguais à tabela por SHA-256. Status: Draft.
3. **Auditoria independente depois de salvar:** subagente lendo a página do rascunho, só com cliques de aba. Veredito: **conforme**, sem nenhuma diferença campo a campo, e nenhum campo preenchido fora da tabela.
   - As duas Notas que ele não conseguia ver na visualização (e-mail do contato e subcampo Other) já tinham sido conferidas pela sessão no formulário de edição.

## Valores no rascunho

- **Título:** "Prespecified analysis plan, analysis code and aggregated results for short-term ambient temperature and preterm birth in 26 Brazilian urban concentrations, 2012-2024".
- **Autores, nesta ordem:** Coelho G; Charles CM; Coelho CJ (PUC Goiás); Kassada DS; Pacagnella RC. Todos com ORCID; os demais com afiliação UNICAMP.
- **Contato:** Coelho G, guilcoel@unicamp.br.
- **Subject:** Earth and Environmental Sciences; Medicine, Health and Life Sciences.
- **Palavras-chave:** 11.
- **Related Publication:** "Is Supplement To", com o manuscrito "in preparation".
- **Notes:** SHA-256 da spec e das decisões de 08/10.
- **Language:** English; Portuguese.
- **Fomento:** FAPESP 2025/10862-7.
- **Time Period:** 2011-01-01 a 2024-12-31.
- **Data Type, Software (R 4.5.1 e Python 3.12) e Data Source.**
- **Declarações de ética:** as 2.
- **Cobertura:** Brazil; 26 urban concentrations (277 municipalities).
- **Terms:** Custom Dataset Terms (MIT + CC BY 4.0).

## Pendências (não feitas; dependem de Guilherme ou da v2)

- **Enviar para revisão = publicar.** Fica para depois do aceite (A1-143), com [ok] literal. Depois do envio, a edição trava até a publicação.
- **Contato:** se os dados entrarem na tese, o tutorial exige o orientador. Guilherme escolheu "Guilherme" depois de ver a regra; rever antes do envio.
- **Arquivos:**
  - Sobem a versão pública (originais) da v2 do 96, depois de nova auditoria. O tutorial pede zip quando há mais de 5 arquivos e um "Leia-me".
  - Os hashes das Notes valem para os originais da tag.
- **Link anônimo dos revisores:** não sai do REDU, porque o Private URL exige papel de curador. Fica a decidir.
- **Citação:** a Related Publication passa à citação completa com DOI depois do aceite. O artigo deve declarar o mesmo fomento.
- **Manuscrito cego:** não citar o DOI 10.25824/redu/…, porque identifica a Unicamp.
