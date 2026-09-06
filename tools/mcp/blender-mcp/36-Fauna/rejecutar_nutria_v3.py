import sys
sys.stdout.reconfigure(encoding='utf-8')
sys.path.insert(0, r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\scripts-reutilizables')
from bpy_cliente import blender_command

# Limpiar TODO
blender_command('execute_code', {'code': 'import bpy; bpy.ops.object.select_all(action="SELECT"); bpy.ops.object.delete(); [bpy.data.objects.remove(o, do_unlink=True) for o in list(bpy.data.objects)]'})
import time; time.sleep(1)

# Leer y ejecutar script v3
with open(r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\36-Fauna\nutria_ribera_v3.py', 'r', encoding='utf-8') as f:
    code = f.read()

resp = blender_command('execute_code', {'code': code})
print('Script v3 ejecutado')
print(str(resp.get('result', ''))[:500])
