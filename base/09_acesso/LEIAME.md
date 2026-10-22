# 09_acesso — interface de acesso à base

Ponto de entrada das conversas de cada artigo (prematuridade, óbito perinatal e PIG). A base é só de **construção**: o recorte e as escolhas de método de cada artigo ficam na conversa dele, a partir daqui.

| Arquivo | O que é |
|---|---|
| `acesso.R` | Interface em R (arrow, jsonlite) |
| `acesso.py` | Interface em Python (polars, numpy, pyarrow); mesmos nomes de função e mesmos resultados |
| `manifesto.json` | Versão da base: md5, linhas, colunas, tipos, script de origem e sigilo de cada arquivo; md5 dos scripts; ambiente. Gerado por `00_scripts/08_manifesto.py` |
| `DICIONARIO.md` | Dicionário de dados: todas as colunas de todos os arquivos (a cobertura é testada) |

## Começar uma conversa de artigo

```r
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R")
versao()
```

```python
import sys; sys.path.insert(0, "/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso")
import acesso as A
A.versao()
```

1. Registre a `versao()` no log de análise do artigo. Ela identifica os dados usados: são os 8 primeiros hex do SHA-256 da lista caminho:md5 e só mudam se algum arquivo mudar. A data do manifesto fica em `manifesto()$data_manifesto`.
2. Leia `DICIONARIO.md` e `logs/desvios_especificacao.md`. As decisões de construção e as variantes gravadas como colunas estão lá.
3. Escolha, e registre no artigo, a versão da exposição (`_nucleo`, `_mun` ou `_rm_nv`), a variante de PM2.5, a série (com ou sem coorte fixa) e o período.

## Funções (R e Python)

| Função | Devolve | Sigilo |
|---|---|---|
| `versao()`, `manifesto()` | Identificador da versão; manifesto inteiro | — |
| `verificar(caminhos)` | Recalcula o md5 e compara com o manifesto (a leitura já confere na primeira vez de cada arquivo) | — |
| `serie_diaria(nivel = "recorte" ou "municipio", coorte_fixa = TRUE)` | Série diária de 2010-12-11 a 2025-01-07, com contagens e exposições (06c) | restrito |
| `gestacoes_em_risco(nivel)` | Z_tj por dia e semana gestacional (E7) | restrito |
| `nascimentos(colunas)`, `obitos(colunas)` | Microdado individual (06b) | microdado |
| `pig(colunas, com_nascimentos)` | Classificação do PIG (07b), com colunas do `nascimentos` se pedido (por exemplo, `com_nascimentos = "ig_dum_sem"`, a IG pela DUM da §3.5) | microdado |
| `clima_municipal()`, `pm25_municipal()`, `calendario()` | Clima, PM2.5 e calendário diários | público |
| `expo_semanal(var, versao_expo)` | Matriz s01..s37 gravada (tmean, rh, pm25 × nucleo, rm_nv, mun) | público |
| `matriz_semanal(var, versao_expo)` | Mesma matriz para qualquer variável diária (tmax, tmin, tmean, rh, pr e as quatro de PM2.5), com o cálculo do 06c | público |
| `diaria_recorte(var, versao_expo)` | Série diária por concentração, na cobertura inteira do clima (2010-01-01 a 2025-01-31) | público |
| `ligar_expo_semanal(nasc, var, versao_expo, ajuste_dias = 3)` | Junta s01..s37 a cada nascimento, com s = data − (7 × IG + ajuste); 0 e 6 são as sensibilidades do E8 | herda o do `nasc` |
| `concentracoes()`, `cidade_nucleo()`, `referencias_pig()` | Tabelas de referência | público |
| `pesos_rm_nv()` | Peso do `_rm_nv` (total de NV por município, 2011–2024) | agregado por município |

**A matriz semanal não corta no parto.** Nos pré-termo, ponha NA nas semanas k > IG.

**Ordem e tipos:**
- `ligar_expo_semanal` e `pig(com_nascimentos)` devolvem as linhas na ordem da entrada, nas duas linguagens.
- Nos CSV, as colunas vêm como texto, com vazio = NA.
- **Python:** o `acesso` fixa a pasta de spill do polars em `_tmp/` da Forja ao ser importado, e avisa se o polars já estava carregado. Pelo registro da auditoria C4 (`config.py`), o polars 1.44.2 lê a variável na hora do spill, e a ordem dos imports não importaria. Em 06/10/2026 não consegui reconfirmar: o spill forçado não deixou arquivo visível em nenhuma das duas ordens. Por segurança, importe o `acesso` antes do `polars`.
- **R:** o arrow lê tudo em memória, sem spill.

## Sigilo (LGPD; obrigatório nas conversas dos artigos)

- **Microdado** (`nascimentos`, `obitos`, `pig`): nunca exibir linha, nem em depuração. Nunca copiar para fora da Forja, colar no chat, num commit ou num log, nem enviar a serviço externo.
- **Restrito** (séries por município ou concentração × dia, gestações em risco): só agregados recorte × ano ou mais grossos, com contagem < 10 como "<10". Nada de município × dia na tela. Cuidado com a subtração: se um total e as partes forem publicados, nenhuma parte < 10 pode ser recuperável (ver `07b`, supressão em bloco).
- **Público:** clima, PM2.5, calendário, referências e logs agregados.
- A interface emite um aviso na primeira leitura de cada arquivo não público.

## Atualizar a versão

Depois de qualquer script que regrave dados:
1. de `00_scripts/`, rode `uv run 08_manifesto.py`. Ele confere o md5 contra o `logs/integridade.csv` e para se divergir;
2. rode `testes/teste_dicionario.py`;
3. rode `testes/teste_acesso.py` e depois, da raiz, `Rscript 00_scripts/testes/teste_acesso.R`.

A versão muda quando qualquer arquivo de dados muda e só nesse caso; a data não entra no identificador. O 08 para em dois casos:
- algum arquivo fora de `logs/` sem registro no `logs/integridade.csv`, ou com md5 diferente do registrado;
- falha na **proveniência** (`logs/proveniencia.csv`): arquivo ou log sem registro de geração, diferente do que foi gerado, ou com insumo ou código alterado depois. A proveniência de cada arquivo fica no `manifesto.json`.

## Testes

- **`00_scripts/testes/teste_acesso.py`:** md5 de todos os arquivos; `matriz_semanal` refaz as 9 matrizes do 06c (todas as células); contagem de linhas; ligação com os nascimentos (2.000 sorteios contra a média direta); avisos de sigilo.
- **`00_scripts/testes/teste_acesso.R`:** em R, confere:
  - o md5 dos 5 arquivos que usa;
  - 4 das 9 matrizes do 06c;
  - **R = Python** em duas matrizes que não estão gravadas (`pm25_zero_na` × `rm_nv`, `tmax` × `nucleo`) e no `ligar_expo_semanal`, na mesma entrada, linha a linha e sem reordenar;
  - a ordem de linhas do `ligar_expo_semanal` e do `pig(com_nascimentos)`;
  - CSV com célula vazia = NA.
  - Rodar depois do teste em Python.
- **`00_scripts/testes/teste_dicionario.py`:** toda coluna de todo arquivo do manifesto está no `DICIONARIO.md`, e vice-versa, com o **tipo** do manifesto (CSV = `str (CSV)`) e sem coluna repetida numa seção. Não confere o texto das definições.
- **`00_scripts/testes/teste_proveniencia.py`:** a conferência de proveniência do 08 (sintético): log editado, insumo, código ou grupo bruto alterado, arquivo sem registro.
- **`00_scripts/testes/paridade_ig_dum_sem.py`, depois `paridade_ig_dum_sem.R` (da raiz):** a `ig_dum_sem` por `nascimentos()` e por `pig(com_nascimentos)`, com texto e com lista. R e Python têm de bater na frequência por ano × valor e num checksum que amarra o valor ao `id_nasc`, e a junção pig × nascimentos tem de ser 1:1. Roda na base ou noutra raiz (`DADOS_PERINATAIS_CLIMA_RAIZ`).
