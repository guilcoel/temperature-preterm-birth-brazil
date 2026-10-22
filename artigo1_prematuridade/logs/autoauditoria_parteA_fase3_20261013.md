# Fase 3, A3.1: autoauditoria da Parte A

- **Gerado por:** `00_scripts/42_autoauditoria_fase3A.R`, em 2026-10-13 14:35:43 -03. Rodada `20261013`. `versao()` no início = 4443971b (o fim está na última linha).
- **BLAS/LAPACK:** `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib`.
- **Arquivos auditados (SHA-256):**
  - `codigo_compartilhado/R/segunda_etapa.R`: `1fb4543a3d4f0fd31bbf35571944c37756c33b1a1d11f876d48bd9bdd3aa9abb`;
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009`;
  - `codigo_compartilhado/tests/testa_segunda_etapa.R`: `d10194168b8982127f4c9a050217fe97d7bf54f1800e6d521d86cdef1a5c0605`;
  - `codigo_compartilhado/tests/testa_segunda_etapa_mc.R`: `c3ae1fcd00928fe762e439c1e2f01d8ea5d913403aeb6b4827337dc0a8c54aaf`;
  - `codigo_compartilhado/tests/roda_testes.R`: `40e7b537c500a29bfd852ac67a4fcde3fbd58128321f60fc438826360436768e`;
  - `codigo_compartilhado/inst/terceiros/attrdl.R`: `d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d`;
- **Método:** cada número dos logs do 40 e do 41 foi recalculado com código diferente e procurado no texto com a mesma formatação.
- **Código diferente:** quantil tipo 7 à mão (A0); as 1.000 réplicas do teste 5 com os mesmos sorteios, ajustadas com o `mixmeta` chamado direto (sem `meta_curva`), β por `lm.fit`, base pelo `splines::ns`, BLUP pela fórmula e bootstrap da TMR com a base do `splines::ns`; teste 6 com o polinômio avaliado à mão; teste 8 com a fração atribuível *forward* e *backward* calculadas à mão, sem a `attrdl`, com os mesmos sorteios; testes rápidos de cada defeito rodados de novo.
- **Limite:** a diferença BLUP × fórmula do log do 41 é conferida só como ≤ 1e-8, porque o valor exato depende do código; o teste 5 de cada defeito não roda de novo (os testes de Monte Carlo listados no 41 são aceitos como estão; pela regra do desvio 74, o 41 só roda o teste 5 numa cópia quando nenhum teste rápido cai).

## Resultado: 70 de 70 conferências iguais

| Item | Conferência | N | Resultado |
|---|---|---|---|
| Ordem | cidade_nucleo() = ordem gravada (vetor literal escrito de novo aqui) |   26 | igual |
| A0 | grade 26 × 101 (quantil tipo 7 à mão) = CSV da A0 (≤ 1e-12) | 2626 | igual |
| A0 | eixo médio (média à mão) = linhas do eixo no CSV (≤ 1e-12) |  101 | igual |
| A0 | eixo médio nos percentis-chave e SHA-256 do CSV no log do 40 |   10 | igual |
| A0 | as 101 linhas da grade completa no log do 40 |  101 | igual |
| Teste 2 | maior |Boundary.knots − range| (pmin/pmax à mão) |    1 | igual |
| Teste 5 | base combinada, β, log RR verdadeiro, DP de Ψ, cen e TMR verdadeira (declarados) |    6 | igual |
| Teste 5 | cobertura, EP e IC de Wilson (mixmeta direto; Wilson pelo prop.test) |    1 | igual |
| Teste 5 | viés, EP, IC, viés relativo, EP médio e DP das estimativas |    1 | igual |
| Teste 5 | EQM do BLUP (fórmula à mão), da primeira etapa e da parte fixa |    1 | igual |
| Teste 5 | EQM da predição na média dos metapreditores (só reportado; desvio 74) |    1 | igual |
| Teste 5 | cobertura da TMR (bootstrap com splines::ns) e métodos do mixmeta |    2 | igual |
| Teste 5 | diferença BLUP × fórmula à mão no log ≤ 1e-8 |    1 | igual |
| Teste 6 | DP das TMR sorteadas, EP delta e largura do IC (polinômio à mão) |    1 | igual |
| Teste 8 | correlação entre as simulações das concentrações 1 e 2 (AF forward à mão, mesmos sorteios da attrdl) |    1 | igual |
| Teste 8 | backward: total − (calor + frio) (backward à mão) |    1 | igual |
| SHA-256 | código e testes iguais aos do log do 41 |    6 | igual |
| A2 | testes que passam / total no log do 41 = recalculado (rápidos re-rodados + critérios do teste 5 refeitos) |    2 | igual |
| Defeitos | "Boundary.knots omitidos na base de predição": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    2 | igual |
| Defeitos | "nós da base combinada pela mediana": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "cen ignorado na curva": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    2 | igual |
| Defeitos | "BLUP trocado pela predição da média": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "bootstrap sem a vcov (sorteios iguais ao ponto)": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    2 | igual |
| Defeitos | "grade da TMR sem o x_sup": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    2 | igual |
| Defeitos | "semente única para todas as concentrações": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    3 | igual |
| Defeitos | "set.seed só uma vez antes dos componentes": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "calor e frio com o range trocado": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "calor extremo sem o max(p97,5, TMR)": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "denominador com os eventos do aquecimento": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "sequência de estabilidade pulando o diag": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "centro da reduz_var ignorado": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "ordem das concentrações sem trava": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "grade da TMR com unique() (quase-duplicata)": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "fronteira da TMR por == em °C": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "sem a checagem de coeficientes nulos antes do mixmeta": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "set.seed sem o kind explícito": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    2 | igual |
| Defeitos | "attrdl sem a checagem de datas consecutivas": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "cross-basis aceitando série não consecutiva": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "falha do mixmeta com !isTRUE(converged)": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "Q/I² residual e total trocados": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "Wald do termo errado": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "bootstrap com a semente da curva combinada em todas as concentrações": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "frio extremo sem o min(p2,5, TMR)": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "frio extremo igual ao frio": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "predição no primeiro conjunto de metapreditores, e não na média": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "vcov do BLUP trocada pela vcov da predição": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "IC da TMR pelos percentis 5 e 95": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "IC da curva com qnorm(0,95)": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "posição no eixo deslocada": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "soma dos lags só de 1 a 7": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "ponte calculada como backward": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "busca da fronteira entre p10 e p50": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "sem conferência do SHA-256 da attrdl": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "semente sem validar o i": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "eCI da attrdl pelos percentis 5 e 95": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "fração atribuível sem conferir o aquecimento contra o lag": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "fração atribuível sem conferir o número de coeficientes": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "semente da attrdl com o índice deslocado": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "simulações da attrdl sempre forward": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "bootstrap da TMR numa grade sem o x_sup": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "EP da curva por lag sem as covariâncias": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "IC da curva por lag com qnorm(0,95)": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "IC da soma dos lags com qnorm(0,95)": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "forward aceitando NA nos cases": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "busca da TMR devolvendo o p10 no campo p50": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "curva por lag com lags padrão de 1 em 1": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "Ψ devolvido do modelo só com intercepto": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "índice da concentração sem recusar código fora da ordem": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "posição no eixo extrapolando (rule = 2)": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |
| Defeitos | "IC da AF com os limites trocados": lista do log = os rápidos que falham (re-rodados) ou, se nenhum cai, só o teste 5 |    1 | igual |

`versao()` no fim: 4443971b.
