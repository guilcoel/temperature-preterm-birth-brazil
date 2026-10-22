# Inventário do estado da Fase 0A (base 7e99bf94), antes da Fase 0 refeita (base 4443971b)

- **Gerado por:** `ferramentas/arquiva_fase0A_rerun.sh inventario`, em 2026-10-09 08:32:35 -03, da raiz `/Volumes/Forja/Doc/artigos_perinatais_clima`. Rodada `FASE0_RERUN_DATA=20261009`.
- **Antes de qualquer edição ou execução** da rodada (A1 antes da A0; nenhum R nem renv rodou antes).
- **Versão da base** (campo `versao` do `09_acesso/manifesto.json`, o que `versao()` devolve): início 4443971b, fim 4443971b.
- **Escopo:** o do prompt (`00_scripts/`, `logs/`, `01_saidas/fase0/`, `CLAUDE.md` e as duas RESPOSTA do artigo) mais o que também é registro ou configuração da Fase 0A (renv, `logs/`, `docs/`, `ferramentas/` e `codigo_compartilhado/` da raiz, `spec/`, `.gitignore`, `.gitattributes`, `README.md`). Fora: `._*`, `.DS_Store` e este arquivador.
- **Arquivos:** 62.
- **Arquivo (fora do git):** `artigo1_prematuridade/01_saidas/arquivo_fase0A_7e99bf94.tar`, 763904 bytes, SHA-256 `c31dbc440f2a2d9a24bd0c35f03f645b6fa050b11ff3169bcc9acee79889efce`. Feito com `tar --no-xattrs --no-mac-metadata -cf … -T <lista>` (código de saída 0).
- **Conferência do arquivo:** lista do tar × inventário: 0 linha(s) diferente(s); SHA-256 de cada arquivo dentro do tar (`tar -xOf`) × disco: 0 diferente(s). O SHA do próprio tar não se reproduz em outra rodada (depende de `mtime`); vale o desta linha.
- **Na conferência do fim** (`conferir`), ficam fora do SHA idêntico só os editados de propósito: artigo1_prematuridade/00_scripts/00_ambiente.R, artigo1_prematuridade/00_scripts/00_dependencias.R, artigo1_prematuridade/00_scripts/01_interface.R, artigo1_prematuridade/00_scripts/02_recontagens_fase0.R, artigo1_prematuridade/00_scripts/03_autoauditoria_fase0.R, artigo1_prematuridade/00_scripts/04_mm14_equivalentes_fase0.R, artigo1_prematuridade/CLAUDE.md. O log de desvios (`artigo1_prematuridade/logs/desvios_especificacao.md`) só recebe linhas novas: os primeiros N bytes têm de ter o SHA deste inventário.

| Arquivo | Bytes | SHA-256 |
|---|---|---|
| `.gitattributes` | 111 | `e85d5ff935886a85891b96895bc7136ddb7a9f991edb0596c44326e03218fcfe` |
| `.gitignore` | 851 | `ffd0f780126a1e2b1de15b094ce8b87a39386aeafa60bcf293deca2f456aa316` |
| `README.md` | 1422 | `3c9922c46cc6c667695041597068ac523f41ee655acc96304149b87d82c7864d` |
| `artigo1_prematuridade/.Renviron` | 33 | `388d393cad64b15d9d9bc3a456c13c73add3b517ea19936d09d9474a30e996f6` |
| `artigo1_prematuridade/.Rprofile` | 26 | `3f9d62fc3f1bf5888a09816101b705f9844ef4cd44ee5ad157f4168dac4af4d4` |
| `artigo1_prematuridade/00_scripts/.gitkeep` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `artigo1_prematuridade/00_scripts/00_ambiente.R` | 4695 | `ee38114d882effdb9c85816246127dd316c18bb6f31323c254d93e11e6d8a570` |
| `artigo1_prematuridade/00_scripts/00_dependencias.R` | 1455 | `f7d3dfd2002dd4dd1a7703e265362c85459699c7cd52ba12587c8cd90bf1d41c` |
| `artigo1_prematuridade/00_scripts/01_interface.R` | 8393 | `ec201c9a1f9816f6a641a6aaf056e3f4b875686fc0940c381fe1207c21a65ae8` |
| `artigo1_prematuridade/00_scripts/02_recontagens_fase0.R` | 21444 | `bca25e061ea534d885a6b52559fe982ac446568f6f726c6a9ba7b1f6aa29dfb4` |
| `artigo1_prematuridade/00_scripts/03_autoauditoria_fase0.R` | 27364 | `c046a65ba577ae8becdb82c05cdb6e2785048aa2e2d4bd30aacaf1b81b2b0e90` |
| `artigo1_prematuridade/00_scripts/04_mm14_equivalentes_fase0.R` | 5934 | `0223f09c095da29a3d129683db5f6f484bc0ef8c3fb295a170dfaae056deae6f` |
| `artigo1_prematuridade/00_scripts/05_saidas_complemento_fase0A.sh` | 10300 | `44086f11a16bc0200cb5efa92e8ac58754aed489ac8da9ead2984ff3bc3fb02a` |
| `artigo1_prematuridade/01_saidas/fase0/a5_1_totais.csv` | 205 | `0fe49f86efe2cc3e31c4aa571850b946706a4ef9180d32dc2e979d536ad0642f` |
| `artigo1_prematuridade/01_saidas/fase0/a5_2_eventos_janelas.csv` | 11454 | `a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5` |
| `artigo1_prematuridade/01_saidas/fase0/a5_3_percentis_diarios.csv` | 16223 | `fa3b8fb141c3b4f306d01201a99af51db5c1469bb5a0b43116b58fd678701650` |
| `artigo1_prematuridade/01_saidas/fase0/a5_4_semanal_mm.csv` | 13181 | `c054d81c68aba88e1975380a2d9f2e202fb8694b50f55338ff6881b0eaef8ca6` |
| `artigo1_prematuridade/01_saidas/fase0/a5_4b_mm14_equivalentes.csv` | 6246 | `d6584a135feea42e12221c9b370630b213c470e2a1ad96c006dc9455d6dfd7cc` |
| `artigo1_prematuridade/01_saidas/fase0/a5_5_pm25_dias_utilizaveis.csv` | 6045 | `afd134c5931677193aeee11d962c8c8ad78462d2b85e5ff311dd29f95e0e0752` |
| `artigo1_prematuridade/CLAUDE.md` | 8168 | `a2f8841b74aaf37717b2cee005a148b84690398626ba88b8892c2e928dbb21c3` |
| `artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_20261008.md` | 79741 | `b7e310d65f844dd25c1c440f38e1ba1e7d0cc065843fb4a3f670526caad4cf4e` |
| `artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_complemento_20261008.md` | 38720 | `e5f7517a5af5b7a8fb530249977aa172e5ea1ac2787aaf62cdff79f539c42a74` |
| `artigo1_prematuridade/logs/.gitkeep` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `artigo1_prematuridade/logs/ambiente_fase0_20261008.md` | 1526 | `df6399bc3a0af6cb776a8bb114c47582c4b5b89b1d7f30bd581f498b4b580b75` |
| `artigo1_prematuridade/logs/attrdl_consulta_20261008.md` | 2802 | `2a62e949fa44b5fb3be2e03a9e0e8f22847203ad80e7ba3276c46c7c26a871c5` |
| `artigo1_prematuridade/logs/auditoria_complemento_fase0A_20261008.md` | 7995 | `3c1dc0880861043bf3f850099559a6a2c261d5d59763fc342d60deda4ab8cd9e` |
| `artigo1_prematuridade/logs/auditoria_fase0_20261008.md` | 8798 | `fbcd2b0db10f15f626b82cc139ca43569b1624d9f61e45d1ecf226cd1d82d922` |
| `artigo1_prematuridade/logs/autoauditoria_fase0_20261008.md` | 5916 | `35b481b47a7a7c725f26e0df0e815d94dc0d05e68f35f9a71f141b867b9865d4` |
| `artigo1_prematuridade/logs/autoauditoria_fase0_complemento_20261008.md` | 7256 | `df2e90dd79fc989203d31824822651522e7c27713d4b21ed5c9b2c8d1d44ff8a` |
| `artigo1_prematuridade/logs/complemento_fase0A_saidas_20261008.md` | 21539 | `3f70464073a24da14cd147effda88e43013e31e23b24f82f0d4668f630b047ee` |
| `artigo1_prematuridade/logs/csv_sha256_fase0_20261008.md` | 2549 | `50085e0f24901cdf7212dffcdd2f352f22df0167a43e46c7568a7da24fa67a9b` |
| `artigo1_prematuridade/logs/desvios_especificacao.md` | 7528 | `fe34ef324a02785d5314ec30056e2a76bcedc01d756a682f1c08309bd4a53665` |
| `artigo1_prematuridade/logs/interface_conclusoes_fase0_20261008.md` | 4154 | `a15dc2a065d8c649f2519a4aca622f3121b8fbab39de56216f478319acd4f23e` |
| `artigo1_prematuridade/logs/interface_fase0_20261008.md` | 9233 | `f708ae3f12fa4c7d89a876f9b425fa4d592a03af023c803ed6b6c41597e9d1f2` |
| `artigo1_prematuridade/logs/mm14_fase0_20261008.md` | 3555 | `412f88e6ce651011bbf407fd887f4c78d67fde5dca6ab17c3d2d92d28c3dd254` |
| `artigo1_prematuridade/logs/recontagens_fase0_20261008.md` | 33049 | `d9fafc89b7708b3bb87dc8f351eb32db0ae6d1871c022d7c6c6d872695c7f898` |
| `artigo1_prematuridade/logs/renv_fase0_20261008.md` | 6800 | `4d2379355a518cd04eea63e2dc1962abb290a246e5f6633b1dc90f16e53b8734` |
| `artigo1_prematuridade/logs/sessionInfo_20261008.txt` | 3240 | `dcf2e01f6bc7a873a95bf41729752c6a0c98d528f1d3c70d61d3c4e82576cfdc` |
| `artigo1_prematuridade/renv.lock` | 78514 | `3d38576f30f334fe2a0e5a195fc0420b60bdbd2c79366931267b74c14801a4d0` |
| `artigo1_prematuridade/renv/.gitignore` | 56 | `2c31e978189a98022566bd6084936f5608222b2bb9230b8d189b5a1c97a2c2da` |
| `artigo1_prematuridade/renv/activate.R` | 39946 | `bcfe1e7dac9c9e93228836b7459d8bd207c08c6f883a91ce757eba1a3521d6e5` |
| `artigo1_prematuridade/renv/settings.json` | 498 | `eb91e8bb720adfddef2180a30a377f2f790742008218aea65002b8e89bb143b8` |
| `codigo_compartilhado/DESCRIPTION` | 330 | `ddc2c41889f1b64182892946cfcdd60802318acb1b5f552305cd9789b5afe8fe` |
| `codigo_compartilhado/R/.gitkeep` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `codigo_compartilhado/inst/terceiros/.gitkeep` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `codigo_compartilhado/inst/terceiros/ORIGEM.md` | 2117 | `6d71e3a489b3b3f706a2511904a6228691cd84ef93d59b5eba50ca9381f2066d` |
| `codigo_compartilhado/inst/terceiros/attrdl.R` | 7411 | `d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d` |
| `codigo_compartilhado/tests/.gitkeep` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `docs/coordenacao/RESPOSTA_chat_A1_ajustes_20261008.md` | 6931 | `2f08e45173511104874580c5758bc029536bdc05b652f4b171203382a10a21aa` |
| `docs/coordenacao/RESPOSTA_chat_A1_auditoria_20261008.md` | 5289 | `cb0422f421a1b6813b9bec0de1f5b1a4b5153147db90b8bc57869d4ec0257d85` |
| `ferramentas/baixa_attrdl.R` | 2777 | `993df5e23f4901679811031d7638179e78eae3fb6420851176a38a185e653341` |
| `ferramentas/checa_sigilo.sh` | 3551 | `465444a869886583c38b1c51a33d0fff81442248b5f5d4768ec69bb30c3688cc` |
| `ferramentas/testa_checa_sigilo.sh` | 4933 | `88952ca0af39df39112def8e7e3c31a7fa1b8709841d508a732757c2955819a1` |
| `logs/_entrada_chat/RESPOSTA_chat_A1_ajustes_20261008.md` | 6931 | `2f08e45173511104874580c5758bc029536bdc05b652f4b171203382a10a21aa` |
| `logs/_entrada_chat/RESPOSTA_chat_A1_auditoria_20261008.md` | 5289 | `cb0422f421a1b6813b9bec0de1f5b1a4b5153147db90b8bc57869d4ec0257d85` |
| `logs/_entrada_spec/decisoes_metodo_20261008.md` | 6957 | `20fc42e42d3aa6a25c707d3c2c450c9480537c86e13cd917d6c5441034f5db3e` |
| `logs/_entrada_spec/especificacao_dlnm_canonica_v2_0_2.md` | 111272 | `a30398496c2bad285a22a55e3bee67c6df1bbdd6439ad9f0f712c2b964a9ed04` |
| `logs/a1_estrutura_git_20261008.md` | 5611 | `0038c1c47d17cee314dc0a17686739f535ae34d396d30144a027e2d728071ef8` |
| `logs/a1_evidencias_20261008.md` | 19097 | `0fd35755294cb6f2d8b48269cbe8d7f9025195662849088fc3c0d3b67ee6a509` |
| `logs/checagem_arranjos_ibge_20261008.md` | 5978 | `4dde716f16309505254cd26193ce460219c0c58a011c6f4e9087527a9574bd31` |
| `logs/confirmacoes_pre_tag.md` | 1387 | `4aef96ca83a0dfc421cbe914cdb6708e354302111987df43b0ed9df03954d2d9` |
| `logs/manutencao_git_20261008.md` | 3554 | `affb73c3e6136328612b40847ce26ac33472a614e42c898ba24365b076e6660d` |
