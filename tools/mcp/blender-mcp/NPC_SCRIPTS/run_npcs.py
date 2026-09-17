import bpy
import sys
import os

# Clean scene
for obj in list(bpy.data.objects):
    bpy.data.objects.remove(obj, do_unlink=True)
for col in list(bpy.data.collections):
    bpy.data.collections.remove(col)
for grupo in (bpy.data.meshes, bpy.data.materials):
    for bloque in list(grupo):
        if bloque.users == 0:
            grupo.remove(bloque)

SCRIPT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\NPC_SCRIPTS\crear_catalogo_npcs.py"

with open(SCRIPT, 'r', encoding='utf-8') as f:
    content = f.read()

# Parse --ids from command line
ids = set()
args = sys.argv
if "--ids" in args:
    idx = args.index("--ids") + 1
    while idx < len(args) and not args[idx].startswith("--"):
        for part in args[idx].split(","):
            ids.add(int(part.strip()))
        idx += 1

if not ids:
    ids = {1}

print(f"Generating NPCs: {sorted(ids)}")
content = content.replace('SOLO_IDS = None', f'SOLO_IDS = {ids}')
content = content.replace('GENERAR_CAPTURAS = True', 'GENERAR_CAPTURAS = False')

exec(compile(content, SCRIPT, 'exec'))
print("BATCH COMPLETE")