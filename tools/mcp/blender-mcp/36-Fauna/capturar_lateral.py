import sys
sys.stdout.reconfigure(encoding='utf-8')
sys.path.insert(0, r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\scripts-reutilizables')
from bpy_cliente import blender_command
import tempfile, os

# Vista lateral completa
code = """
import bpy
for area in bpy.context.screen.areas:
    if area.type == "VIEW_3D":
        for space in area.spaces:
            if space.type == "VIEW_3D":
                region = space.region_3d
                region.view_perspective = "ORTHO"
                bpy.ops.view3d.view_axis(type="RIGHT")
                region.view_distance = 0.5
                region.view_location = (0.0, 0.0, 0.12)
                break
        break
"""

blender_command('execute_code', {'code': code})
import time; time.sleep(1)

screenshot_path = os.path.join(tempfile.gettempdir(), 'nutria_v3_lateral_orto.png')
resp = blender_command('get_viewport_screenshot', {'filepath': screenshot_path})
print(screenshot_path)
