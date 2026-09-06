"""
M154/M36: Renders DE CERCA del conejo para verificar uniones/separaciones.
Zoom 0.5m del objeto — se ven los cortes entre cubos.
"""
import bpy
import math
import os
import mathutils

BLEND = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\conejo_cozy.blend"
OUT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\godot-mcp\capturas\36-Fauna\conejo_cerca"
os.makedirs(OUT, exist_ok=True)

bpy.ops.wm.open_mainfile(filepath=BLEND)
sc = bpy.context.scene
sc.render.engine = "BLENDER_EEVEE_NEXT"
sc.render.resolution_x = 640
sc.render.resolution_y = 640
sc.render.image_settings.file_format = "PNG"

target = mathutils.Vector((0, 0, 0.2))

VISTAS = [
    ("cerca_cabeza_orejas", 25, 0.55, 0.35),   # de cerca: zona orejas
    ("cerca_cara_ojos", 0, 0.5, 0.3),          # de frente: ojos/brillito
    ("cerca_cuerpo_patas", 60, 0.6, 0.15),     # patas y vientre
    ("cerca_cola_atras", 180, 0.6, 0.2),       # cola
]

for nombre, ang, dist, alt in VISTAS:
    a = math.radians(ang)
    offset = mathutils.Vector((math.sin(a) * dist, -math.cos(a) * dist, alt))
    sc.camera.location = target + offset
    dirv = target - sc.camera.location
    sc.camera.rotation_euler = dirv.to_track_quat("-Z", "Y").to_euler()
    sc.render.filepath = os.path.join(OUT, f"conejo_{nombre}.png")
    bpy.ops.render.render(write_still=True)
    print(f"RENDER: {nombre}")

print("=== 4 RENDERS DE CERCA LISTOS ===")
