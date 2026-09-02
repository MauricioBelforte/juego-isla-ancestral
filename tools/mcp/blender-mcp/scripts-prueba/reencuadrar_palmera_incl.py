"""Recomponer cámara palmera inclinada y volver a capturar."""
import sys, json
sys.path.insert(0, r'tools/mcp/blender-mcp/scripts-reutilizables')
from bpy_cliente import blender_command

code = (
    "import bpy\n"
    "from mathutils import Vector\n"
    "cam = bpy.data.objects['CAM_PalmeraIncl']\n"
    "cam.location = (5.5, -7.0, 3.6)\n"
    "top = bpy.data.objects.get('SM_Corona_Incl')\n"
    "tgt = top.matrix_world.to_translation() if top else Vector((1.55, 0.0, 3.8))\n"
    "tgt.z = 0  # apuntar al medio del tronco, no al tope\n"
    "dir_mira = tgt - cam.location\n"
    "cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()\n"
    "bpy.context.scene.camera = cam\n"
    "bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)\n"
    "print('CAM RECOMP obj cam:', list(cam.location), ' tgt:', list(tgt))\n"
)
print(json.dumps(blender_command('execute_code', {'code': code}), ensure_ascii=False)[:400])
