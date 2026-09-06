"""
M154/M36: Render ORBITAL de 6 vistas para análisis con visión (patrón Hy4).
Gira la cámara alrededor del objeto y renderiza: frente, 3/4 izq, perfil izq,
atrás, 3/4 der, perfil der + vista cenital = 7 imágenes.
Abre el .blend aprobado y renderiza sin modificar el diseño.
"""
import bpy
import math
import os
import mathutils

BLEND = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\conejo_cozy.blend"
OUT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\godot-mcp\capturas\36-Fauna\conejo_orbital"
os.makedirs(OUT, exist_ok=True)

bpy.ops.wm.open_mainfile(filepath=BLEND)
sc = bpy.context.scene

# EEVEE_NEXT para colores de materiales (Blender 4.2)
sc.render.engine = "BLENDER_EEVEE_NEXT"
sc.render.resolution_x = 640
sc.render.resolution_y = 640
sc.render.image_settings.file_format = "PNG"

# Centro del conejo (aprox: cuerpo+orejas)
target = mathutils.Vector((0, 0, 0.25))

VISTAS = [
    ("00_frente", 0),
    ("01_trescuartos_izq", 45),
    ("02_perfil_izq", 90),
    ("03_atras", 180),
    ("04_trescuartos_der", 315),
    ("05_perfil_der", 270),
    ("06_cenital", -1),  # especial: desde arriba
]

for nombre, angulo in VISTAS:
    if angulo == -1:
        sc.camera.location = target + mathutils.Vector((0.0, 0.0, 1.2))
    else:
        ang = math.radians(angulo)
        offset = mathutils.Vector((math.sin(ang) * 0.9, -math.cos(ang) * 0.9, 0.3))
        sc.camera.location = target + offset
    direccion = target - sc.camera.location
    quat = direccion.to_track_quat("-Z", "Y")
    sc.camera.rotation_euler = quat.to_euler()
    sc.render.filepath = os.path.join(OUT, f"conejo_{nombre}.png")
    bpy.ops.render.render(write_still=True)
    print(f"RENDER: conejo_{nombre}.png")

print(f"=== 7 VISTAS ORBITALES GUARDADAS EN: {OUT} ===")
