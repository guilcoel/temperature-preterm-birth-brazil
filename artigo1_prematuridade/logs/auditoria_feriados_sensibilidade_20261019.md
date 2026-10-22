# Fase 4, Parte C3: auditoria independente da sensibilidade dos feriados locais (script 84)

- **Quando:** 2026-10-19; registro às 2026-10-19 16:13:18 -0300 (hora lida com `date`). Novo modo de trabalho (A1-105), item 3: um subagente em contexto limpo reproduz por outra via os números-chave, sem mutantes.
- **Como:** o subagente escreveu código próprio do zero e não chamou `ajusta_dlnm`, `segunda_etapa`, `sens_agudos` nem `fluxo_c`.
  - A cross-basis foi montada à mão com `splines::ns` (igual ao `dlnm::crossbasis` até 6,7e-16), e a redução overall também.
  - O ajuste usa `gnm` quasi-Poisson com `eliminate`, com φ calculado à mão.
  - Da 2ª etapa, só o REML é do `mixmeta`; predição, Q, I², TMR, bootstrap e RR foram calculados à mão.
  - Insumos: a tabela da tag `feriados_locais-v1.1` (SHA conferido), exposição e calendário pela interface `09_acesso`, e `ptb`, `log_z` e `log_w` da série do A1. Só agregados; nada gravado no repositório.
- **Controle positivo:** sem o indicador, reproduz o principal (TMR 28,174 °C; x99 1,003141; x1 1,020162) e os coeficientes da Fase 2 (dif. 1,9e-13).

## Resultado

| Item | Reprodução | Log | Veredito |
|---|---|---|---|
| Dias com o indicador | 1.671 = 1.047 da tabela + 26 × 24 (24/12 e 31/12), igual em cada concentração | igual | bate |
| Sobreposição com `feriado_nacional`, `carnaval` ou `moveis` | 0 (também na tabela inteira, 2011–2024) | 0 | bate |
| TMR | 28,074 °C (percentil 93,07) | 28,1 (93,1) | bate (3,6e-15) |
| IC da TMR | 18,774 a 29,475 | 18,8 a 29,5 | bate |
| RR x99 | 1,004076 (0,977858 a 1,030996) | 1,004 (0,978 a 1,031) | bate |
| RR x1 | 1,020323 (0,990535 a 1,051006) | 1,020 (0,991 a 1,051) | bate |
| φ; Q (gl); I² | 0,9788; 1,0088; 1,1169; 94,276 (92); 2,414% | iguais | bate (≤ 1,5e-14) |
| Coeficientes e variâncias da 1ª etapa | — | RDS do 84 | bate (4,3e-13; 1,2e-12) |

## Achados

**Críticos, Maiores e Menores:** nenhum.

**Notas:**
- **Nota 1 (texto, M3):** o IC da TMR é a grade inteira (x1 = 18,77436 e x99 = 29,47515 do eixo do principal, conferidos pela sessão no RDS do 45). Segundo o auditor, 3,2% dos sorteios caem em x1 e 28,5% em x99. O IC é censurado pelas bordas, como no principal. Vai junto com os outros IC censurados (73, T6, uma etapa).
- **Nota 2:** a TMR desce exatamente um passo da grade, de 28,174 para 28,074; os RR mudam na 3ª casa. Conferida pela sessão nos logs.
- **Nota 3 (informativa, não reproduzida pela sessão):** o RR do `feriado_local` por concentração tem mediana 0,933 (0,874 a 1,036), com IC abaixo de 1 em 7 das 26 e acima em nenhuma. O RDS do 84 não guarda esse coeficiente; a nota não muda nada da análise.
- **Nota 4:** um dia do indicador cai no aquecimento: Cuiabá, 08/04/2012, aniversário da cidade (conferido pela sessão na tabela da tag). Ele fica fora das linhas de ajuste, pela regra do script.

**Limites:** o teste 3 e o Wald dos metapreditores não foram reproduzidos; o fallback não foi exercitado, porque nenhuma concentração falhou; o REML do `mixmeta` foi usado pronto; o bootstrap usa a semente prescrita, mas com outra semente e 10.000 sorteios o IC sai igual. **Correções:** nenhuma.
