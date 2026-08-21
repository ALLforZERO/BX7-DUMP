gb.ff — assets corrigidos no formato do exemplo mod.rar

ESTRUTURA
materials/      -> Material em JSON (schema T6)
xmodel/         -> descrição do XModel em JSON
model_export/   -> geometria do XModel em GLB
techsets/       -> MaterialTechniqueSet em .techset
techniques/     -> técnicas em .tech
shader_bin/     -> bytecode Direct3D em .hlsl.cso
zone_source/    -> lista dos 37 XAssets do FastFile
metadata/       -> validações e lista de imagens externas

CONTAGEM
37 XAssets top-level:
- 20 GfxImage
- 10 Material
- 6 MaterialTechniqueSet
- 1 XModel

Dependências exportadas:
- 150 técnicas .tech
- 159 arquivos .cso
- 156 bytecodes .cso distintos por SHA-256

VALIDAÇÃO
Todos os 159 arquivos .cso deste pacote têm conteúdo
byte a byte encontrado nos DXBC extraídos diretamente de gb.ff.

Os 10 materiais referenciam exatamente os 20 GfxImage declarados por gb.ff
e somente os 6 TechniqueSets declarados por gb.ff.

O XModel gobblegum_machine do exemplo possui 19 joints e 10 surfaces,
coincidindo com a estrutura serializada recuperada de gb.ff.

IMAGENS
Não foram criados DDS falsos. Os 20 GfxImage do gb.ff têm delay-load ativo e
ponteiro de pixels serializado como zero; seus pixels não estão neste FastFile.
Os nomes/dimensões/hash estão em metadata/images_external.txt.
