"""
M36: Render NUTRIA con CYCLES (CPU, headless-safe) para ver los colores.
"""
import bpy
import math
import os
import mathutils

BLEND = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\nutria_cozy.blend"
OUT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\godot-mcp\capturas\36-Fauna\nutria_ciclos"
os.makedirs(OUT, exist_ok=True)

bpy.ops.wm.open_mainfile(filepath=BLEND)
sc = bpy.context.scene
sc.render.engine = "CYCLES"
sc.cycles.device = "CPU"
sc.cycles.samples = 32
sc.render.resolution_x = 640
sc.render.resolution_y = 640
sc.render.image_settings.file_format = "PNG"

target = mathutils.Vector((0, 0, 0.2))

VISTAS = [
    ("perfil_izq", 90),
    ("trescuartos", 45),
]

for nombre, angulo in VISTAS:
    ang = math.radians(angulo)
    offset = mathutils.Vector((math.sin(ang) * 0.8, -math.cos(ang) * 0.8, 0.35))
    sc.camera.location = target + offset
    dirv = target - sc.camera.location
    sc.camera.rotation_euler = dirv.to_track_quat("-Z", "Y").to_euler()
    sc.render.filepath = os.path.join(OUT, f"nutria_{nombre}.png")
    bpy.ops.render.render(write_still=True)
    print(f"RENDER: nutria_{nombre}")

print("=== CYCLES LISTO ===")
