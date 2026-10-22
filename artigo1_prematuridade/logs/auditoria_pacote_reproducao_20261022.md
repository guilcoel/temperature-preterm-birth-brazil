# Dupla auditoria do pacote de reprodução v1 do A1 (22/10/2026)

**Objeto.**
- Pacote: `Entrega/reproducao/A1_reproducao_v1_20261022/` e o zip de mesmo nome (420 arquivos; SHA do zip começa por `dc38d61047a439c7`). Os dois ficam fora do git.
- Gerado pelo script 96 v1 (`96a69ba`); log `logs/pacote_reproducao_20261022_v1.md` (`dd981da`). Decisões na A1-156.

**Auditores.** Dois subagentes em contexto limpo, sem rede e sem microdado:
- (a) sigilo e identificação;
- (b) reprodutibilidade e completude.

**Veredito dos dois:** não apto. O sigilo de dados (LGPD) passou nos dois. A falha está na identificação (link anônimo) e na reprodutibilidade.

## Achados reproduzidos pela sessão (22/10, 11:15–11:20)

| # | Nível | Achado | Reprodução | Tratamento |
|---|---|---|---|---|
| 1 | Crítico | A troca "[redacted]" caiu dentro de identificadores Python. `config.py` (l. 39), `98_aceite_fase1.py` e `99_relatorio_integridade.py` não compilam, e 20 arquivos da base importam o `config` | `ast.parse`: SyntaxError nas l. 39, 41 e 26 | v2 do 96 |
| 2 | Crítico | O pacote traz a v1.1 de `ajusta_dlnm`, `offset` e `segunda_etapa` (SHA `2acf2179…`, `2f68965e…`). Os scripts 32 e 45 rodaram com a v1.0 (`563dd82b…`, `55111b2c…`, `1fb4543a…`), que não está no pacote | Logs `primeira_etapa_fase2_20261010.md` e `segunda_etapa_fase3_20261013.md`, l. 7–9; `shasum` no pacote; o 32 diz `TAG <- "ajusta_dlnm-v1.0"` | v2: incluir as versões usadas por script |
| 3 | Crítico (link anônimo) | "Research Data Repository of the University of Campinas" por extenso em 7 arquivos (o 94, o log de desvios e os logs do 94, da v2 à v6) | `grep -rl` → 7 | v2: troca e varredura com o nome por extenso |
| 4 | Crítico (link anônimo) | O `sha256_original` do MANIFEST, as listas de hash do original e o `SHA256SUMS` funcionam como oráculo: dá para confirmar o original pondo nomes candidatos no lugar do marcador | Coluna presente no MANIFEST (cabeçalho). O auditor confirmou 12 de 39 arquivos testáveis com uma lista genérica de nomes | v2: sem hash do original na versão anônima |
| 5 | Crítico (link anônimo) | A base cita a base antiga do grupo com o DOI do artigo (Data in Brief 2025) e "com apoio do projeto [redacted]" | `grep`: `base/README.md:313`, `base/01_sinasc/FONTE.md:84`, `base/03_clima/FONTE.md:23` | v2 |
| 6 | Maior | Logs de auditorias anteriores de anonimização entraram no pacote e descrevem as pistas por extenso | 3 arquivos (`auditoria_m5…`, `reconferencia_pacote…`) | v2: fora da versão anônima |
| 7 | Maior | O `attrdl.R` (exigido pelo 45, 46 e 50) e o `ferramentas/baixa_attrdl.R` não estão no pacote | `inst/terceiros/` só tem o `ORIGEM.md` | v2: incluir o baixador próprio e um passo no README |
| 8 | Maior | Travas que quem está de fora não consegue satisfazer: `versao()=="4443971b"` (md5 de 43 arquivos, um deles derivado da base antiga, que não é pública); tag → commit comparado com "[commit]"; tags que faltam; commit `COORD:` exigido pelo 65–68 e pelo 70; `ls-remote` no 70 | Relatório (b) | v2: modo externo documentado ou patch, e lista completa de tags |
| 9 | Maior | README: variáveis `FASE1/2/3_DATA` (não `RODADA`); faltam o 02 e o 49; o 69 e o 83 não rodam fora; macOS e BLAS de referência exigidos; insumos que não estão no pacote | Relatório (b) | v2 do README |
| 10 | Maior (versão pública) | O plano congelado não é verificável: a spec anonimizada tem outro SHA-256 (`1d2df39d…` contra `a3039849…`) | MANIFEST | Versão para o REDU e o GitHub com os originais da tag |
| — | Menores e Notas | Regex redigida que casa qualquer texto (90, 91, 94, 95); `~/.cdsapirc` virou `<path>`; `DESCRIPTION` com "License: a definir"; variantes do nome do repositório; commits sem troca no MANIFEST; link de artifact privado em 2 arquivos da base; 445 arquivos `._*` na pasta (o zip está limpo) | Relatórios (a) e (b) | v2 |

**Conferido sem achado pelos auditores:**
- MANIFEST: 419 linhas, bytes e SHA do pacote recalculados, 0 divergências.
- Os 14 resultados com SHA igual ao do log de origem.
- Mapa das tabelas S1 a S6.
- `renv.lock` válido.
- Nenhuma contagem de 1 a 9 de desfecho e nenhuma série diária.
- Nenhuma credencial.
- PDFs sem autor nem caminho.

## Conclusão para a v2 (decisão de implementação, a registrar na A1-157)

O pacote único anonimizado não serve aos dois fins.

- **Versão pública:** REDU e GitHub, depois do aceite, com autoria. Leva os originais, sem anonimização, com uma varredura de privacidade própria:
  - nenhum dado;
  - nenhum nome de terceiro fora dos autores;
  - nenhum link privado;
  - nenhuma credencial.
- **Versão anônima:** só para o link dos revisores. Traz documentação e resultados, sem hash do original e sem os logs de montagem e auditoria do pacote.

Nos dois casos, o código precisa rodar fora (achados 1, 2, 7, 8 e 9).

## v2 e v3 (22/10, depois da A1-157)

**v2 (script 96 v2, `acb12f6`; log `b36c1dc`): dois produtos, auditados por dois subagentes independentes.**
- **Público: "apto com correções".**
  - 1 Maior: o 53 rodou com a versão sem tag do commit `937dbbf` de `diagnostico_grade_mrt.R` e do teste, ausentes do pacote.
  - 3 Menores: prompts, pedido e confirmações do chat no pacote; link de relatório privado na base; `SHA256SUMS` sem instrução.
- **Anônimo: "apto com correções".**
  - 1 Crítico: o MD5 do original de 31 arquivos alterados no `manifesto.json` da base, reproduzido 31 de 31.
  - 3 Menores: entradas 146 e 147 e `auditoria_m5b` descrevendo o cegamento; horários UTC de pushes; tamanhos de originais.
- **Tratamento:** todos os achados foram reproduzidos e corrigidos na v3 (A1-159).

**v3 (script 96 v3, `74c19f2`; log `3364200`): auditoria independente das correções.**
- **Público: "apto".** Todos os achados da v2 resolvidos, sem regressão. Notas opcionais:
  - logs de empacotamento listados como logs do 69 e do 83;
  - coluna de versões sem as tabelas de feriados;
  - `--ignore-missing` na conferência do `SHA256SUMS`.
- **Anônimo: "não apto".** O MD5 foi resolvido, mas o oráculo continua por variantes:
  - Crítico N1: o índice das decisões guarda o SHA-256 "sem `\n` final" de 12 originais alterados, além de formas abreviadas. O auditor confirmou um nome por palpite usando só o anônimo;
  - Crítico N2: hashes e tamanhos de versões derivadas dos originais;
  - Menor: a máscara de tamanho corrompeu um número e dois hashes, por falta de fronteira de token.
- **Nota do auditor:** com o GitHub público durante a revisão, o anônimo fica ligável aos autores, por mais que seja limpo (título quase igual; SHA-256 iguais dos arquivos não alterados).

**Decisão de Guilherme (22/10, na sessão), entre as opções apresentadas: "GitHub agora, sem link anônimo".** O produto anônimo deixa de ser gerado (A1-160). Os achados N1 e N2 ficam sem correção porque o produto foi abandonado, e não porque estejam resolvidos. As notas do público entram na v4.
