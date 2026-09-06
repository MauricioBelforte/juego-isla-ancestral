import sys
sys.stdout.reconfigure(encoding='utf-8')
sys.path.insert(0, r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\scripts-reutilizables')
from bpy_cliente import blender_command

code = '''
import bpy
path = r"D:\\Escritorio\\PORTFOLIO\\Proyectos para GitHub\\PROYECTOS OPENCODE\\juego-isla-ancestral\\tools\\mcp\\blender-mcp\\36-Fauna\\nutria_ribera_v2_alta.blend"
bpy.ops.wm.save_as_mainfile(filepath=path)
print("Guardado: " + path)
'''
resp = blender_command('execute_code', {'code': code})
print(resp.get('status'))
print(str(resp.get('result', ''))[:500])
