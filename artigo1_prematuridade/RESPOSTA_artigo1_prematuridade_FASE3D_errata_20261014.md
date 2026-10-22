# RESPOSTA ao chat do Artigo 1 (prematuridade): Fase 3D, errata da D5 e diagnóstico da grade da MRT

**De:** Claude Code, sessão do Artigo 1 no Mac Mini, via Guilherme · **Data:** 14/10/2026 · **Responde a:** mensagem v1.1 do chat do Artigo 1 (14/10/2026)

**Resumo:** os passos 1 a 7 foram feitos sem parada. A grade da MRT começa no p1 e termina no p99 nas 26 concentrações. As 15 com u_min < −10⁻⁸ são todas classe (a), com o dia do mínimo numa célula vizinha da MRT. Commits locais, sem push; a tag `diagnostico_grade_mrt-v1.0` não foi criada.

## 1. Passos 1 a 3: tag local, errata e entrada 80

- **Tag `posthoc_af-v1.0`** (anotada, local, sem push) no `dc89ae753aeabd806593c7f3cb0dcbca4efc5f17`. Os SHA-256 da mensagem conferiram antes da criação; conferidos de novo agora, os seis listados na mensagem da tag (o `.gitkeep` incluído) batem com `git show dc89ae7:<arquivo>`.
  - Objeto da tag: `d8204b5c359b7699362b5a4d649fa657273e7c3a`.
  - SHA-256 da mensagem como gravada no objeto (`git cat-file tag posthoc_af-v1.0 | sed '1,/^$/d' | shasum -a 256`, 1.773 bytes): `9d14cfc0937dd6926c0dc67fac679b20cbcfd5570e0e6423173dbf90095ded03`.
- **Errata:** `spec/decisoes_metodo_20261014_errata_D5.md`, SHA-256 `9c9fb65d6963ba674a7ff0d75419d5713fdfed94724ff0f6bd9a00c69653814b`. É o informado pelo chat. A cópia de Guilherme tinha uma quebra de linha final a mais (SHA-256 `ea483f46…`, texto idêntico); por decisão dele, a cópia em `spec/` ficou com os bytes do chat.
- **Entrada 80:** registrada antes de rodar, no C1. Nenhum arquivo já existente de `spec/`, `SHA256SUMS` incluído, foi editado.

## 2. Passo 4: diagnóstico da grade da MRT (só leitura)

- **Código:**
  - `codigo_compartilhado/R/diagnostico_grade_mrt.R`, SHA-256 `ad17f502…`;
  - testes em `codigo_compartilhado/tests/testa_diagnostico_grade_mrt.R`, SHA-256 `514cb77a…`;
  - script `00_scripts/53_diagnostico_grade_mrt.R`.
- **O que foi usado:** a `grade_tmr` da tag `segunda_etapa-v1.0`, sem alteração. Nada foi reajustado nem recalculado: MRT, coeficientes BLUP, p1 e p99 vêm da RDS do 45, e o menor Δ_t da RDS do 50. As entradas tiveram o SHA-256 conferido contra os logs do 50 e do 46.
- **Log:** `logs/diagnostico_grade_mrt_fase3_20261014.md`, SHA-256 `79594d69d1f1b679080b10f42528c523360a728ab025a8e2316d4cf35037f01a`.
- **CSV agregado:** `01_saidas/fase3/diagnostico_grade_mrt_fase3_20261014.csv`, fora do git, SHA-256 `c27f652dbacba6807e2b599019f96fc1b6f15448e2581fecadc3ff59567ef3c9`.

### Parte 1: a grade começa no p1 e termina no p99?

- **Código:** `grade_tmr` nas linhas 131–135 de `segunda_etapa.R` da tag: `seq` na linha 133 e o acréscimo do p99 na 134. `busca_tmr` e `boot_tmr` a chamam nas linhas 139 e 145. No 45, as linhas 141, 142 e 145 passam o p1 e o p99 da concentração.
- **Resultado:** primeiro ponto = p1 em 26 de 26; último ponto = p99 em 26 de 26; o p99 foi acrescentado nas 26, porque (p99 − p1)/0,1 não é inteiro em nenhuma. O n da grade é igual ao registrado pelo 45.
- **MRT no p99:** a MRT BLUP é exatamente o último ponto da grade em 10 concentrações, as mesmas com `fronteira = TRUE` no 45, e não cai no primeiro ponto em nenhuma. Nessas 10, g = 0 e o menor Δ_t é positivo.
- **Exemplo detalhado (Porto Alegre):**
  - p1 = 9,4820 e p99 = 30,2114, com (p99 − p1)/0,1 = 207,29;
  - o `seq` termina em 30,1820, a 0,0294 do p99;
  - a `grade_tmr` acrescenta o p99 como 209º ponto, e a MRT é esse ponto.
- **Parada:** não houve.

| Concentração | p1 | p99 | n da grade | Primeiro = p1 | p99 acrescentado | Último = p99 | MRT | MRT no p99 |
|---|---|---|---|---|---|---|---|---|
| São Paulo/SP | 12,58 | 27,64 | 152 | sim | sim | sim | 24,08 | não |
| Rio de Janeiro/RJ | 17,49 | 30,99 | 137 | sim | sim | sim | 23,09 | não |
| Belo Horizonte/MG | 16,90 | 28,27 | 115 | sim | sim | sim | 26,20 | não |
| Brasília/DF | 18,13 | 27,28 | 93 | sim | sim | sim | 26,13 | não |
| Recife/PE | 23,19 | 29,41 | 64 | sim | sim | sim | 28,09 | não |
| Porto Alegre/RS | 9,48 | 30,21 | 209 | sim | sim | sim | 30,21 | sim |
| Fortaleza/CE | 25,41 | 30,48 | 52 | sim | sim | sim | 29,91 | não |
| Curitiba/PR | 8,99 | 26,32 | 175 | sim | sim | sim | 23,39 | não |
| Salvador/BA | 22,65 | 29,73 | 72 | sim | sim | sim | 24,35 | não |
| Goiânia/GO | 19,88 | 30,07 | 103 | sim | sim | sim | 30,07 | sim |
| Campinas/SP | 13,66 | 27,97 | 145 | sim | sim | sim | 27,97 | sim |
| Manaus | 24,91 | 31,66 | 69 | sim | sim | sim | 31,66 | sim |
| Belém/PA | 25,47 | 29,97 | 47 | sim | sim | sim | 29,97 | sim |
| Vitória/ES | 19,66 | 29,97 | 105 | sim | sim | sim | 29,06 | não |
| Baixada Santista/SP | 15,26 | 29,78 | 147 | sim | sim | sim | 29,78 | sim |
| São José dos Campos/SP | 13,18 | 26,49 | 135 | sim | sim | sim | 24,38 | não |
| São Luís/MA | 25,03 | 30,25 | 54 | sim | sim | sim | 26,43 | não |
| Natal/RN | 24,18 | 29,35 | 53 | sim | sim | sim | 25,18 | não |
| Maceió/AL | 23,27 | 29,10 | 60 | sim | sim | sim | 28,37 | não |
| Florianópolis/SC | 12,55 | 28,86 | 165 | sim | sim | sim | 23,55 | não |
| João Pessoa/PB | 23,88 | 29,57 | 58 | sim | sim | sim | 25,08 | não |
| Teresina/PI | 25,39 | 31,91 | 67 | sim | sim | sim | 31,91 | sim |
| Aracaju/SE | 23,86 | 29,92 | 62 | sim | sim | sim | 28,86 | não |
| Cuiabá/MT | 17,23 | 32,29 | 152 | sim | sim | sim | 32,29 | sim |
| Sorocaba/SP | 13,31 | 28,34 | 152 | sim | sim | sim | 28,34 | sim |
| Campo Grande | 12,60 | 30,53 | 181 | sim | sim | sim | 30,53 | sim |

### Parte 2: onde fica o dia de menor contribuição

- **u_min < −10⁻⁸:** exatamente 15 concentrações. O u_min é igual ao menor Δ_t gravado pelo 50 nas 26 (diferença máxima 0; critério ≤ 10⁻¹³).
- **Classe:** as 15 são **(a), vizinha**. Nenhuma é (b), anômala ou "quase empate". A f″ numérica (segunda diferença, passo 10⁻³ °C) dá a mesma classe que a analítica nas 15. Nenhuma célula é parcial nem a última.
- **M:** de 0,00081 a 0,04803 °C⁻². Razões máximas: 0,7575 contra a MRT e 0,7575 contra os extremos da célula; as duas são iguais nas 15, porque a MRT é um dos extremos.
- **Recife:** M = 0,04803 °C⁻². O u_min de Recife (−4,151 × 10⁻⁵) exige 0,0332, então vale M ≥ 0,033.
- **Contribuições negativas:** a soma fora do p1–p99 dá −38,70 no CSV do 46 (dentro, −0,034).
- **Parada:** não houve.

| Concentração | MRT | [a, b] | Distância | u_min | M (°C⁻²) | Cota | Razão MRT | Razão célula | Classe |
|---|---|---|---|---|---|---|---|---|---|
| São Paulo/SP | 24,08 | [24,08; 24,18] | 0 | -1.345e-08 | 0,00256 | 3.203e-06 | 0,0042 | 0,0042 | a, vizinha |
| Rio de Janeiro/RJ | 23,09 | [23,09; 23,19] | 0 | -6.358e-07 | 0,00110 | 1.375e-06 | 0,4625 | 0,4625 | a, vizinha |
| Brasília/DF | 26,13 | [26,13; 26,23] | 0 | -1.481e-05 | 0,01672 | 2.090e-05 | 0,7087 | 0,7087 | a, vizinha |
| Recife/PE | 28,09 | [28,09; 28,19] | 0 | -4.151e-05 | 0,04803 | 6.003e-05 | 0,6915 | 0,6915 | a, vizinha |
| Fortaleza/CE | 29,91 | [29,91; 30,01] | 0 | -7.717e-06 | 0,01577 | 1.971e-05 | 0,3915 | 0,3915 | a, vizinha |
| Curitiba/PR | 23,39 | [23,39; 23,49] | 0 | -6.312e-06 | 0,01432 | 1.790e-05 | 0,3526 | 0,3526 | a, vizinha |
| Salvador/BA | 24,35 | [24,25; 24,35] | 0 | -4.219e-06 | 0,00446 | 5.570e-06 | 0,7575 | 0,7575 | a, vizinha |
| Vitória/ES | 29,06 | [29,06; 29,16] | 0 | -3.475e-06 | 0,00435 | 5.438e-06 | 0,6390 | 0,6390 | a, vizinha |
| São José dos Campos/SP | 24,38 | [24,28; 24,38] | 0 | -2.083e-06 | 0,02209 | 2.762e-05 | 0,0754 | 0,0754 | a, vizinha |
| São Luís/MA | 26,43 | [26,33; 26,43] | 0 | -1.236e-06 | 0,01276 | 1.595e-05 | 0,0775 | 0,0775 | a, vizinha |
| Natal/RN | 25,18 | [25,18; 25,28] | 0 | -6.576e-06 | 0,00958 | 1.197e-05 | 0,5492 | 0,5492 | a, vizinha |
| Maceió/AL | 28,37 | [28,27; 28,37] | 0 | -2.507e-05 | 0,03110 | 3.888e-05 | 0,6449 | 0,6449 | a, vizinha |
| Florianópolis/SC | 23,55 | [23,55; 23,65] | 0 | -4.552e-08 | 0,00081 | 1.017e-06 | 0,0447 | 0,0447 | a, vizinha |
| João Pessoa/PB | 25,08 | [24,98; 25,08] | 0 | -3.357e-07 | 0,00896 | 1.120e-05 | 0,0300 | 0,0300 | a, vizinha |
| Aracaju/SE | 28,86 | [28,86; 28,96] | 0 | -8.368e-06 | 0,02426 | 3.033e-05 | 0,2759 | 0,2759 | a, vizinha |

## 3. Testes e defeitos plantados

- **Testes:** 9 de 9. São os seis cenários pedidos (célula vizinha; célula parcial no p99 com o h real; quase empate declarado; base trocada → anômala; u_min diferente do gravado → parada; grade sem o p99 → (b)), mais a Parte 1, as regras da classe e f/f″ contra `splines::ns`.
- **Defeitos plantados:** 23, e cada um derruba pelo menos um teste:
  - os 5 pedidos (h = 0,1 na célula parcial; grade sem o p99; razão só contra f(MRT); M num ponto; vizinhança com distância ≤ 1);
  - 6 da sessão;
  - 12 da auditoria independente.

## 4. Autoauditoria e auditoria independente

- **Autoauditoria**, dentro do 53, em Recife e no Rio de Janeiro: código próprio com `splines::ns` e os nós e Boundary.knots da `argvar`, sem a `onebasis`. u_min com diferença 0; célula igual; M com diferença relativa ≤ 6,1 × 10⁻¹².
- **Auditoria independente** (subagente em contexto limpo; registro em `logs/auditoria_errataD5_fase3_20261014.md`):
  - reproduziu a Parte 1 nas 26 e a Parte 2 nas 15, com diferenças em precisão de máquina, e M por três caminhos sem o `splineDesign`;
  - fez 7 achados; todos foram aceitos e reproduzidos por código da sessão.

| Nº | Achado | Correção |
|---|---|---|
| 1 | O defeito `xs <- x[i]` não derrubava nenhum teste: nos cenários, os dias fora do p1–p99 ficavam no fim do vetor. Nos dados, a célula mudaria nas 15 (corrigir antes da RESPOSTA) | Dias fora da faixa intercalados nos testes; o defeito entrou no 53 e derruba 5 testes. A função não mudou |
| 2 | A classe (a) aceita razão célula negativa ou menor que a razão MRT (nota) | Conferência descritiva no log: razão célula ≥ razão MRT nas 15. Sugestão ao chat na seção 6 |
| 3 | A trava M > 0 não era exercitada (nota) | Caso com M < 0 no `td8` |
| 4 | A frase "MRT no p99" era circular (nota) | Trocada pela conferência contra a `fronteira` do 45 |
| 5 | CSV com `%.17g` erra 1 ulp na leitura (nota) | Nenhuma: o 53 compara texto |
| 6 | Sigilo residual: u_min com 17 dígitos mais os coeficientes BLUP localizam x* (nota) | Nenhuma no código. O CSV e a RDS ficam fora do git, e o log mostra 4 algarismos. Seção 6 |
| 7 | Outros 15 defeitos sobreviventes, sem efeito no A1 (nota) | Dez entraram com testes novos. Ficam dois, explicados no log: M = máx \|f″\| e `findInterval` sem `rightmost.closed` |

- **Depois das correções:** o 53 rodou de novo. O CSV ficou idêntico; o log antigo foi para a lixeira (SHA-256 `7506a8c8…`).

## 5. Passos 5 a 7 e commits

| Commit | Passo | Conteúdo |
|---|---|---|
| C1 `ebf665e` | 2 e 3 | Errata em `spec/` e entrada 80 |
| C2 `937dbbf` | 4 | Função, testes, 53, logs do diagnóstico e da auditoria |
| C3 `40a7c33` | 5 | Entrada 81 (modelo do item 7 da errata; causa (a) nas 15; frases dos itens 4 e 5; [k] = 0, "…0.83%–3.00%; no replicate failed)"; a ressalva condicional da D5 sai do A1) |
| C4 `47f21d9` | 6 | `docs/coordenacao/SOLICITACAO_prompt_artigo1_prematuridade_FASE4_20261014.md` |
| C5 (este) | 7 | Esta RESPOSTA |

- **Ambiente:** R 4.5.1; dlnm 2.4.10; splines 4.5.1; BLAS e LAPACK de referência; base `4443971b`.
- **Fora dos commits:** os arquivos sem commit do Artigo 2 e do Artigo 3. Os logs do Artigo 2 não foram tocados.

## 6. Para o chat decidir

1. **Tag `diagnostico_grade_mrt-v1.0`:** criar no `937dbbf`, se o chat aprovar.
2. **Reuso no Artigo 2** (auditoria, achados 2 e 7): acrescentar à função, antes do reuso, a checagem "razão célula ≥ razão MRT − tol" como condição de anomalia? Isso muda a regra da classe, que é do chat, então não foi feito aqui. Nos dados do A1, não muda nada.
3. **Sigilo** (achado 6): o u_min saiu com 4 algarismos no log e nesta RESPOSTA. Os coeficientes BLUP por concentração não saem. Se forem para o suplemento, o u_min deve sair com menos precisão.
4. **Push:** entre o C1 e o C2 está o `4bbf0f4`, commit da sessão do Artigo 2, também local. Empurrar o `main` até o C5 empurra o `4bbf0f4` junto. A outra opção, sem rebase, é empurrar só até o `ebf665e` e esperar o ok do Artigo 2. A tag `posthoc_af-v1.0` sobe com o ok de Guilherme.
