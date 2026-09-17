import bpy
import sys

# Clean scene
for obj in list(bpy.data.objects):
    bpy.data.objects.remove(obj, do_unlink=True)

SCRIPT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\NPC_SCRIPTS\crear_catalogo_npcs.py"

with open(SCRIPT, 'r', encoding='utf-8') as f:
    content = f.read()

# Parse args from command line
ids = set()
i = 1
while i < len(sys.argv):
    arg = sys.argv[i]
    if arg == "--ids":
        i += 1
        while i < len(sys.argv) and not sys.argv[i].startswith("--"):
            for part in sys.argv[i].split(","):
                ids.add(int(part.strip()))
            i += 1
        continue
    i += 1

if not ids:
    ids = {1}

print(f"Generating NPCs: {sorted(ids)}")
content = content.replace('SOLO_IDS = None', f'SOLO_IDS = {ids}')
content = content.replace('GENERAR_CAPTURAS = True', 'GENERAR_CAPTURAS = False')

exec(compile(content, SCRIPT, 'exec'))
print("BATCH COMPLETE")
