# CAMINHOS — dados_artigos_perinatais_clima

Para reaproveitar em sessões futuras (Claude Code, R, Python). Registrado em 2026-10-01.

| O quê | Caminho completo |
|---|---|
| **Raiz da base** | `/Volumes/Forja/Doc/dados_artigos_perinatais_clima` |
| Scripts | `/Volumes/Forja/Doc/dados_artigos_perinatais_clima/00_scripts` |
| SINASC | `/Volumes/Forja/Doc/dados_artigos_perinatais_clima/01_sinasc` |
| SIM (DO + DOFET em `_dofet/`) | `/Volumes/Forja/Doc/dados_artigos_perinatais_clima/02_sim` |
| Clima BR-DWGD | `/Volumes/Forja/Doc/dados_artigos_perinatais_clima/03_clima` |
| Regiões metropolitanas | `/Volumes/Forja/Doc/dados_artigos_perinatais_clima/04_regioes_metropolitanas` |
| Shapefiles | `/Volumes/Forja/Doc/dados_artigos_perinatais_clima/05_shapefiles` |
| Processados (microdado; não sai da Forja) | `/Volumes/Forja/Doc/dados_artigos_perinatais_clima/06_processados` |
| Referência PIG | `/Volumes/Forja/Doc/dados_artigos_perinatais_clima/07_pig_referencia` |
| Logs e integridade | `/Volumes/Forja/Doc/dados_artigos_perinatais_clima/logs` |
| Base antiga (só conferência de contagens) | `/Volumes/Forja/CliMaterna/01_data/raw` |

Observações:
- A pasta no disco chama-se **`Doc`** (D maiúsculo). O volume não é APFS; nomes são insensíveis a maiúsculas, mas use a grafia exata.
- No R: `raiz <- "/Volumes/Forja/Doc/dados_artigos_perinatais_clima"`.
- No Python: `from config import ROOT` (resolve a partir de `00_scripts/config.py`).
