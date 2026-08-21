BX7 MOD — Scripts GSC/CSC

Total de scripts encontrados: 87
- GSC: 59
- CSC: 28
- Já presentes como fonte de texto: 78
- Descompilados a partir de bytecode T6 (magic 0x80GSC): 9

Pastas:
original/
  Cópia byte a byte dos 87 ScriptParseTree extraídos do mod.
compiled_original/
  Somente os 9 arquivos que estavam em bytecode compilado.
decompiled/
  Todos os 87 em forma textual. Os 78 que já eram fonte foram preservados;
  os 9 binários foram reconstruídos a partir de header, exports, imports,
  StringTable fixups, opcodes e referências de animtree.
metadata/
  Manifestos SHA-256 e validação estrutural dos 9 bytecodes.

Validação dos 9 binários:
- Todos os exports foram recuperados.
- Todos os imports referenciados aparecem nos fontes gerados.
- Todas as StringTable fixups não vazias usadas no código foram recuperadas.
- zm_nuked_basic_01.gsc: 272/272 referências de animação do animtree recuperadas.
- Nenhum dos arquivos em decompiled/ mantém o cabeçalho binário 0x80GSC.

Observação:
Descompilação não preserva comentários, nomes temporários eliminados pelo compilador
ou formatação original. O objetivo aqui é reconstruir a lógica e os assets
referenciados a partir do bytecode que estava efetivamente dentro do mod.
