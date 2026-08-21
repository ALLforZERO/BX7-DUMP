BX7_MOD_COMPLETE — dump consolidado + GSC/CSC descompilados

CONTEÚDO
fastfiles/
  Dump dos FastFiles mod.ff e gb.ff, incluindo a Zone integral preservada,
  assets extraídos e o dump corrigido do conteúdo GobbleGum.

iwd_native/
  Conteúdo original dos quatro IWDs, preservando IWI e demais arquivos nativos.

textures_dds/
  573 texturas IWI convertidas para DDS.

soundbanks/
  Bancos de áudio SABS/SABL preservados.

root_files/
  Arquivos auxiliares da raiz do mod.

metadata/
  Inventários, hashes, mapeamentos de assets e relatórios do dump completo.

scripts/
  original/           -> os 87 GSC/CSC exatamente como extraídos
  compiled_original/  -> os 9 que estavam em bytecode T6
  decompiled/         -> os 87 em texto (78 preservados + 9 descompilados)
  metadata/           -> validação e SHA-256 por script

SCRIPTING
Foram encontrados 59 GSC + 28 CSC = 87 scripts.
78 já estavam em fonte textual e foram preservados byte a byte.
9 estavam em ScriptParseTree compilado (magic 0x80GSC) e foram reconstruídos
usando header, exports, imports, StringTable fixups, opcodes e animtree.
O aitype zm_nuked_basic_01.gsc teve 272/272 referências de animação recuperadas.

A descompilação recupera a lógica executável, mas não pode recuperar comentários
ou formatação que não existem mais no bytecode compilado.
