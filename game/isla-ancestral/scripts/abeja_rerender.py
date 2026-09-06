"""
M36: ABEJA — re-render con cámara a 0.35m (no dentro del cuerpo).
"""
import bpy
import math
import os
import mathutils

OUT_DIR = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\godot-mcp\capturas\36-Fauna\abeja"

BLEND = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\abeja_cozy.blend"
bpy.ops.wm.open_mainfile(filepath=BLEND)
sc = bpy.context.scene
sc.render.engine = "CYCLES"
sc.cycles.device = "CPU"
sc.cycles.samples = 32

target = mathutils.Vector((0, 0, 0.06))
for nombre, angulo in [("perfil_izq", 90), ("trescuartos", 45), ("frente", 0)]:
    ang = math.radians(angulo)
    offset = mathutils.Vector((math.sin(ang) * 0.35, -math.cos(ang) * 0.35, 0.15))
    sc.camera.location = target + offset
    dirv = target - sc.camera.location
    sc.camera.rotation_euler = dirv.to_track_quat("-Z", "Y").to_euler()
    sc.render.filepath = os.path.join(OUT_DIR, f"abeja_{nombre}_v2.png")
    bpy.ops.render.render(write_still=True)
    print(f"RENDER: abeja_{nombre}_v2")
print("=== LISTO ===")
