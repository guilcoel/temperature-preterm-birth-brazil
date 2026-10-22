# Auditoria da Fase 0, Parte B (congelamento no git): Artigo 1

- **Data:** 2026-10-09.
- **Objeto:**
  - o retorno `RESPOSTA_artigo1_prematuridade_FASE0B_20261009.md`, na versão auditada (SHA-256 `57e453d3eeef6aa4e0899077694bccb565ddc567c57d11742225b5418f37593b`, 70.977 bytes);
  - os commits `86069e5` e `ec22aca`;
  - a tag `spec-v2.0.2-congelada-20261009`;
  - o remoto `guilcoel/artigos_perinatais_clima`.
- **Etapa 1, autoauditoria:** os 28 SHA-256 de 64 hex citados no retorno correspondem a arquivos ou objetos reais. Dois são históricos e também conferem: `20fc42e4…`, em `~/Downloads/_antigos/`, e `e85d5ff9…`, o prefixo de 111 bytes do `.gitattributes`. As cercas de bloco estão pareadas (54).
- **Etapa 2, auditoria independente:** um subagente em contexto limpo, só com leitura e com `gh` só por GET. Ele não abriu `.parquet`, `.dbc` nem `.csv`, nem arquivo da base, e não alterou o repositório.
  - **Veredito:** nada bloqueante. Commit, manifesto, tag, remoto privado e segundo commit conferem por comando próprio.
  - **Achados:** 15 (4 para corrigir e 11 notas).
- **Regra:** nenhum achado foi aceito sem reprodução própria. As saídas da reprodução foram tiradas às 2026-10-09T20:45:04Z.

| # | Achado | Gravidade | Reprodução própria | Correção |
|---|---|---|---|---|
| 1 | O `CreateEvent` da tag continua ausente. A consulta da sessão termina antes do atraso máximo documentado pelo GitHub (até 6 h), e o título do `ec22aca` diz "fecha a Parte B" | corrigir | `gh api repos/…/events --jq length` → `0` às 20:45:04Z | Desvio nº 36 (d): o título do `ec22aca` não muda o fato de a B6 estar pendente. A consulta precisa ser refeita depois do fim do laço, dentro dos 90 dias de retenção do feed. A pendência consta do retorno |
| 2 | O `pushed_at` das 19:20:21Z, citado no desvio 35 como prova provisória, foi sobrescrito pelo push da B8.3 | corrigir | `gh api repos/… --jq .pushed_at` → `2026-10-09T20:22:53Z` | Desvio nº 36 (a); adendo no `logs/congelamento_spec.md`; retorno corrigido |
| 3 | A API de atividade guarda um horário do servidor que não é sobrescrito: a criação da `main` em `86069e5` | nota | `gh api repos/…/activity`: `branch_creation`, `refs/heads/main`, `after` `86069e5…`, `2026-10-09T19:20:11Z`; e `push` `86069e5…` → `ec22aca…` às `20:22:53Z`. Com `?ref=refs/tags/spec-v2.0.2-congelada-20261009` → `0`: a API não registra tags | Desvio nº 36 (a); adendo; retorno. A prova provisória passa a ser a criação da `main` às 19:20:11Z (para o commit, não para a tag) |
| 4 | "Atraso da conta inteira" não é uma inferência independente: a única atividade da conta depois das 17:11:52Z foi neste repositório | nota | `gh api users/guilcoel/events`: os três mais recentes são `PushEvent` em outro repositório (13:29:08Z, 16:49:41Z, 17:11:52Z) | Desvio nº 36 (c): "atraso provável, não comprovado"; retorno corrigido |
| 5 | O retorno diz "antes delas o log tinha 7.528 bytes", o que é falso. Os 7.528 bytes são o prefixo do inventário da A1 e terminam na linha 21; antes dos nº 29–31, o log tinha 22.394 bytes | corrigir | `git show 86069e5:…desvios… \| sed -n '1,40p' \| wc -c` → `22394`; `head -c 7528 \| wc -l` → `21` | Retorno corrigido |
| 6 | A linha 5 do cabeçalho do log ainda cita `20fc42e4…`, ao lado da tag que congela `62afa891…`, e diverge do `CLAUDE.md` | corrigir; a decisão é do chat | `git show ec22aca:…desvios… \| sed -n '5,7p'` | Nada mudou, por causa do nº 30 ("o cabeçalho não muda"). A decisão fica com o chat do Artigo 1 e consta do retorno |
| 7 | O desvio 34 descreve a reescrita do `CLAUDE.md` só em parte: fala em "o parágrafo", no singular, e não cita a frase removida. A reescrita foi feita sem [ok] prévio | corrigir | `git diff 86069e5 ec22aca -- artigo1_prematuridade/CLAUDE.md`: 5 linhas trocadas | Desvio nº 36 (b), com a lista completa; ratificação do chat pedida no retorno |
| 8 | No commit congelado, o `CLAUDE.md` e o cabeçalho do log estão desatualizados (`20fc42e4…` e campos em branco). É assim por desenho da v1.2 §3 | nota | `git show 86069e5:artigo1_prematuridade/CLAUDE.md \| sed -n '15p;22p;28,29p'` | Adendo no `logs/congelamento_spec.md`: o que está congelado é só o que está em `spec/` |
| 9 | Contagens com rótulo errado: "Revisão 2" aparece em 8 linhas, mas em 9 ocorrências; "logs `_rerun_`: 21" são 21 arquivos, dos quais 18 são logs | nota | `grep -c` → 8 e `grep -o \| wc -l` → 9; `git ls-tree` → 21 no total e 18 em `/logs/` (os outros três são a RESPOSTA refeita, sua cópia em `spec/` e o PROMPT) | Retorno corrigido |
| 10 | "Linhas 32–35" são os desvios nº 32 a 35, que ficam nas linhas 44 a 47 do arquivo | nota | `grep -n -E '^\| 3[2-5] \|'` → linhas 44–47 | Retorno corrigido (a mensagem do `ec22aca` não muda) |
| 11 | "Push da `main` e da tag às 19:20:21Z": a `main` chegou às 19:20:11Z, e o `pushed_at` das 19:20:21Z é o do push da tag | nota | API de atividade (achado 3) | Retorno corrigido |
| 12 | O [ok] da criação do repositório (B5.3) foi inferido, não citado | nota | Transcrição da sessão | Retorno: registra o que Guilherme enviou (a saída das duas tentativas no MacBook) e as palavras do ok seguinte |
| 13 | O retorno omite a ressalva do chat sobre a auditoria da RESPOSTA refeita (diferença de espaços ou de quebra de linha final) | nota | Liberação v1.2, linha 109 | Retorno corrigido |
| 14 | A tag e os commits não são assinados (`verification.verified = false`, motivo `unsigned`). As datas declaradas pelo cliente não provam nada para terceiros | nota | `gh api repos/…/git/tags/9f923989… --jq .verification` | Registrado. O prompt não exige assinatura; reforça os achados 1 a 3 até sair o DOI |
| 15 | Há 213 arquivos `._*` (AppleDouble) dentro de `.git`, que fazem o `git fsck` reclamar de `bad sha1 file`, sem erro real | nota | `find .git -name '._*' \| wc -l` → `213` | Ruído do exFAT (CLAUDE.md da Forja, §5). Nada apagado; a decisão fica com Guilherme |
