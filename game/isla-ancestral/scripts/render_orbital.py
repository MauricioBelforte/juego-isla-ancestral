"""
Render orbital — ahora apunta al workspace correcto:
tools/mcp/blender-mcp/36-Fauna/capturas/
(Uso: blender --background --python render_orbital.py <archivo.blend> <carpeta_salida>)
"""
import bpy
import math
import os
import sys
import mathutils

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
BLEND = argv[0] if len(argv) > 0 else r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\36-Fauna\conejo_cozy.blend"
NOMBRE = argv[1] if len(argv) > 1 else "objeto"
OUT = argv[2] if len(argv) > 2 else r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\36-Fauna\capturas"
OUT = os.path.join(OUT, NOMBRE)
os.makedirs(OUT, exist_ok=True)

bpy.ops.wm.open_mainfile(filepath=BLEND)
sc = bpy.context.scene
sc.render.engine = "BLENDER_EEVEE_NEXT"
sc.render.resolution_x = 640
sc.render.resolution_y = 640
sc.render.image_settings.file_format = "PNG"

# centro = bounding box de todos los meshes
meshes = [o for o in sc.objects if o.type == "MESH"]
xs = [v for o in meshes for v in [o.matrix_world.translation.x]]
ys = [v for o in meshes for v in [o.matrix_world.translation.y]]
zs = [v for o in meshes for v in [o.matrix_world.translation.z]]
target = mathutils.Vector((sum(xs)/len(xs), sum(ys)/len(ys), sum(zs)/len(zs)))

# tamaño del objeto para calcular distancia de cámara
def altura_max():
    zmin = 999
    zmax = -999
    for o in meshes:
        for corner in o.bound_box:
            wc = o.matrix_world @ mathutils.Vector(corner)
            zmin = min(zmin, wc.z)
            zmax = max(zmax, wc.z)
    return abs(zmax - zmin)

alto = altura_max()
dist = max(0.9, alto * 3.0)

VISTAS = [
    ("00_frente", 0), ("01_trescuartos_izq", 45), ("02_perfil_izq", 90),
    ("03_atras", 180), ("04_trescuartos_der", 315), ("05_perfil_der", 270),
    ("06_cenital", -1),
]

for nombre, angulo in VISTAS:
    if angulo == -1:
        sc.camera.location = target + mathutils.Vector((0.0, 0.0, dist))
    else:
        ang = math.radians(angulo)
        offset = mathutils.Vector((math.sin(ang) * dist, -math.cos(ang) * dist, alto * 0.6))
        sc.camera.location = target + offset
    dirv = target - sc.camera.location
    quat = dirv.to_track_quat("-Z", "Y")
    sc.camera.rotation_euler = quat.to_euler()
    sc.camera.data.clip_end = 100.0
    sc.render.filepath = os.path.join(OUT, f"{NOMBRE}_{nombre}.png")
    bpy.ops.render.render(write_still=True)
    print(f"RENDER: {NOMBRE}_{nombre}")

print(f"=== 7 VISTAS EN: {OUT} ===")
