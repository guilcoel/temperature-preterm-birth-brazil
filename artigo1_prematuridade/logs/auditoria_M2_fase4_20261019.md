# Fase 4, marco M2 (C3 e C4): auditoria independente por outra via

- **Quando:** 2026-10-19, terminada às 09:33:53 −03:00 (hora de gravação do relatório do subagente). Novo modo de trabalho (A1-105), item 3; mensagem "C2, C3 e C4 em lote", seção "Saída final": pelo menos 6 análises (uma por grupo da C3, mais a uma etapa e a S3) e o sigilo.
- **Como:** código do subagente escrito do zero, só com dlnm (`crossbasis`), gnm, mixmeta, mgcv e splines, sem carregar `ajusta_dlnm`, `segunda_etapa`, `sens_agudos` nem `fluxo_c`. Redução overall à mão; base combinada por `splines::ns`; percentil da uma etapa à mão (conferido contra `approx`); log RR da S3 pela `lpmatrix` (conferido contra o `crosspred`). Insumos de exposição pela interface `09_acesso` (só exposição), iguais aos do A1 até 5e-14; séries RDS lidas dentro da Forja, só agregados impressos; nada gravado no repositório.
- **Controle positivo:** reproduz a 1ª etapa do 32 e a combinada da Fase 3 (28,2 °C; x99 1,003; x1 1,020).

## Resultado (10 análises; máx. diferença 8e-10)

| Análise | Conferido | Máx. dif. | Veredito |
|---|---|---|---|
| C3-E2 Tmax | TMR 35,1 (98,1), IC 22,0–35,7; x99 1,000 (0,988–1,013); x1 1,009 (0,972–1,047); φ; Q | 8e-10 | bate |
| C3-P1 PM2.5 | TMR 27,7 (89,6); N 23 (lista igual); x99 1,015; x1 1,025 | 2e-14 | bate |
| C3-CB4 S2 | TMR 29,5, borda x99 (índice 109 de 109); x99 = 1; contra a mediana 0,991 (0,958–1,025); x1 1,019 | 1e-11 | bate; lógica de borda certa |
| C3-T6 estação quente | TMR 26,1 (46,1 no eixo de nov–mar), índice 43 de 45; IC 21,9–26,2 | 1e-13 | bate |
| C3-D1 `z_fetal` | TMR 28,2 (93,8); x99 1,003; x1 1,020 | 2e-12 | bate |
| C3-O1 extremo | N 18 (lista igual); TMR 27,5 (87,4); x99 1,081 (0,939–1,244); x1 1,039 | 4e-10 | bate |
| C4-UMA | TMR 27,3 (85,1), IC 22,8–27,9; x99 1,019; x1 1,020; φ 1,028; 116.948 dias; 3.874 estratos | 1e-15 | bate (Menor 1) |
| C4-S3 | as 26 concentrações; meta p99 0,998 (0,993–1,002), p1 1,014 (0,989–1,041) | 2e-10 | bate |
| C4-FIX | TMR 27,7 (89,6); x99 1,009; x1 1,012 | 6e-15 | bate |

## Achados (0 Críticos, 0 Maiores, 2 Menores, 5 Notas), todos reproduzidos pela sessão com código próprio

- **Menor 1, IC da TMR da uma etapa.**
  - **O que a letra pede:** a D11, 5.3, manda sortear "1.000 sorteios por Cholesky dos coeficientes da cross-basis".
  - **O que o 78 fez:** a `curva_uma_etapa` sorteia os 4 coeficientes reduzidos (overall), escolha declarada na auditoria da Parte A, Nota 6, como equivalente em distribuição. O IC saiu 22,8 a 27,9.
  - **Reprodução da sessão** (`scratchpad/rep_m2_menor1.R`): a redução à mão dos 16 coeficientes é igual à reduzida salva (dif. 0).
    - Com os 16 coeficientes, semente 20261001 e 1.000 sorteios: 22,9 a 29,5.
    - Com os 4: 22,8 a 27,9 (igual ao log).
    - Com 200.000 sorteios: 22,9 a 29,5, com 3,1% das TMR sorteadas no x99.
  - **Leitura:** o limite superior é instável no Monte Carlo e, na distribuição, fica no x99 (censurado).
  - **Decisão:** do chat, na PARADA do M2. Recomendação: seguir a letra da D11 (16 coeficientes) com um script que só lê o RDS do 78, sem reajuste, e declarar o limite superior censurado no x99.
- **Menor 2, estação quente incompleta.** A D11, item 6, pede os contrastes p99, p95, p90, p10, p5 e p1 de nov–mar contra a TMR; o fluxo comum gravou só o x99 e o x1. Reproduzido: a curva da T6 no RDS do 74 tem 2 linhas. Dá para calcular do RDS do 74 sem reajuste; vai para o M3.
- **Nota 1 (texto):** na T6, o limite superior do IC (26,2) é o x50 de nov–mar, ou seja, censurado pela grade; o percentil 46,1 é do eixo de nov–mar; o x1 de nov–mar não é coprimário.
- **Nota 2 (D16):** a D16 diz que o DP intra-mês de log Z_fetal − log Z é "da ordem de 10⁻⁵". Reproduzido na janela principal: nível médio 0,0054 (bate com "+0,005"); DP intra-estrato com mediana 2,7e-4 (p10–p90 de 1,3e-4 a 5,3e-4) nos 3.874 estratos. Corrigir a frase se ela for para os Methods (a D16 é documento da `spec/`: correção pela COORD).
- **Nota 3 (registro):** a A1-107 diz 09:01 no cabeçalho, mas foi commitada às 09:00:09 (`5ff5712`), antes de o 74 começar. O commit prova a ordem; a hora escrita está errada (A1-111).
- **Nota 4 (cosmético):**
  - o log do 78 chama de "estratos eliminados" os 3.874 estratos absorvidos pelo `eliminate` (removidos por vazios: 0);
  - o título "τ² e I²" do log do 79 traz τ² e Q, sem I²;
  - o 79 usa 1,96 no lugar de `qnorm(0,975)` (dif. até 1e-7).
- **Nota 5 (limite):** independência de código, não de pacote. Fora do escopo: teste 3, PACF, as outras 25 análises da C3, o multinível e os exploratórios do 77, a tabela do 80 linha a linha.

## Sigilo

Logs de `0046438` a `a59d7fb` (inclusive A1-108 a A1-110 e o relatório do M1):
- nenhuma contagem de 1 a 9 sem máscara;
- nenhuma diferença menor que 10 recuperável;
- nenhum dado diário (só limites de janela do protocolo);
- nenhuma linha individual, token ou caminho de credencial.

A única contagem de evento é o mínimo de PTB na janela principal (13.393, de uma concentração na janela inteira).

- **Correções feitas nesta etapa:** nenhuma (as duas Menores esperam a decisão do chat ou o M3).
