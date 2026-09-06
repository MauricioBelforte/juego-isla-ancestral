import sys
sys.stdout.reconfigure(encoding='utf-8')
sys.path.insert(0, r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\scripts-reutilizables')
from bpy_cliente import blender_command
import tempfile, os

code = """
import bpy
for obj in bpy.data.objects:
    if obj.name.startswith("REF_"):
        obj.hide_viewport = True
        obj.hide_render = True

min_y = min_z = float("inf")
max_y = max_z = float("-inf")
for obj in bpy.data.objects:
    if obj.name.startswith("SM_Nutria") and obj.type == "MESH":
        for v in obj.data.vertices:
            world_co = obj.matrix_world @ v.co
            min_y = min(min_y, world_co.y)
            max_y = max(max_y, world_co.y)
            min_z = min(min_z, world_co.z)
            max_z = max(max_z, world_co.z)

center_y = (min_y + max_y) / 2
center_z = (min_z + max_z) / 2
size = max(max_y - min_y, max_z - min_z)

for area in bpy.context.screen.areas:
    if area.type == "VIEW_3D":
        for space in area.spaces:
            if space.type == "VIEW_3D":
                space.region_3d.view_perspective = "PERSP"
                bpy.ops.view3d.view_axis(type="RIGHT")
                space.region_3d.view_distance = size * 1.5
                space.region_3d.view_location = (0.0, center_y, center_z)
                break
        break
"""

blender_command('execute_code', {'code': code})
import time; time.sleep(1)

screenshot_path = os.path.join(tempfile.gettempdir(), 'nutria_v3_enfocada.png')
resp = blender_command('get_viewport_screenshot', {'filepath': screenshot_path})
print(screenshot_path)
