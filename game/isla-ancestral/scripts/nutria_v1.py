"""
M36: NUTRIA voxel cozy (0.7m) — cuerpo alargado, cabeza redonda, patas cortas,
bigotes, cola gruesa horizontal. Render orbital 7 vistas + guardado .blend.
Ejecutar: blender --background --python nutria_v1.py
"""
import bpy
import math
import os
import mathutils

OUT_DIR = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\godot-mcp\capturas\36-Fauna\nutria"
os.makedirs(OUT_DIR, exist_ok=True)

# ── Limpieza ──
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
for _ in range(3):
    for bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
        for item in list(bloque):
            if item.users == 0:
                bloque.remove(item)

# ── Materiales (colores de nutria: marrón oscuro/cacao, vientre canela) ──
def mat(nombre, r, g, b):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (r, g, b, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.9
    return m

M_PELLO = mat("nutria_marron_oscuro", 0.35, 0.22, 0.13)
M_VIENTRE = mat("nutria_canela", 0.72, 0.52, 0.35)
M_OJOS = mat("ojos_negro", 0.03, 0.03, 0.03)
M_BRILLO = mat("brillo_blanco", 0.98, 0.98, 0.98)
M_BIGOTE = mat("bigote_gris", 0.8, 0.8, 0.8)
M_PATA = mat("nutria_patas", 0.28, 0.17, 0.10)

def cubo(nombre, sx, sy, sz, x, y, z, material):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z))
    o = bpy.context.active_object
    o.name = nombre
    o.scale = (sx, sy, sz)
    bpy.ops.object.transform_apply(scale=True)
    o.data.materials.append(material)
    return o

# ── Nutria mirando -Y, altura ~0.7m ──
# cuerpo alargado horizontal: 0.20 ancho x 0.45 largo x 0.18 alto, centro z=0.20
cubo("cuerpo", 0.20, 0.45, 0.18, 0, 0, 0.20, M_PELLO)
# vientre canela (franja inferior)
cubo("vientre", 0.16, 0.36, 0.06, 0, -0.01, 0.13, M_VIENTRE)
# cabeza redonda (cubo grande) al frente-arriba
cubo("cabeza", 0.18, 0.17, 0.16, 0, -0.28, 0.32, M_PELLO)
# hocico crema
cubo("hocico", 0.10, 0.08, 0.08, 0, -0.38, 0.28, M_VIENTRE)
# nariz negra
cubo("nariz", 0.04, 0.02, 0.03, 0, -0.425, 0.30, M_OJOS)
# ojos con brillito
cubo("ojo_izq", 0.035, 0.02, 0.035, -0.055, -0.365, 0.355, M_OJOS)
cubo("ojo_der", 0.035, 0.02, 0.035, 0.055, -0.365, 0.355, M_OJOS)
cubo("brillo_izq", 0.014, 0.012, 0.014, -0.055, -0.378, 0.367, M_BRILLO)
cubo("brillo_der", 0.014, 0.012, 0.014, 0.055, -0.378, 0.367, M_BRILLO)
# bigotes (4, gris, finos, a los costados del hocico)
cubo("bigote_ai", 0.01, 0.12, 0.01, -0.07, -0.34, 0.29, M_BIGOTE)
cubo("bigote_ad", 0.01, 0.12, 0.01, 0.07, -0.34, 0.29, M_BIGOTE)
cubo("bigote_bi", 0.01, 0.10, 0.01, -0.07, -0.36, 0.26, M_BIGOTE)
cubo("bigote_bd", 0.01, 0.10, 0.01, 0.07, -0.36, 0.26, M_BIGOTE)
# orejas chiquitas
cubo("oreja_izq", 0.04, 0.03, 0.05, -0.07, -0.24, 0.42, M_PELLO)
cubo("oreja_der", 0.04, 0.03, 0.05, 0.07, -0.24, 0.42, M_PELLO)
# patas cortas (4)
cubo("pata_di", 0.08, 0.08, 0.12, -0.07, -0.14, 0.06, M_PATA)
cubo("pata_dd", 0.08, 0.08, 0.12, 0.07, -0.14, 0.06, M_PATA)
cubo("pata_ti", 0.08, 0.08, 0.12, -0.07, 0.14, 0.06, M_PATA)
cubo("pata_td", 0.08, 0.08, 0.12, 0.07, 0.14, 0.06, M_PATA)
# cola gruesa horizontal hacia atrás
cubo("cola", 0.10, 0.22, 0.10, 0, 0.32, 0.15, M_PELLO)

# ── Cámara + luces ──
bpy.ops.object.camera_add(location=(0.7, -0.9, 0.55), rotation=(1.134, 0, 0.611))
sc = bpy.context.scene
sc.camera = bpy.context.active_object
bpy.ops.object.light_add(type="SUN", location=(2, -2, 3))
bpy.context.active_object.data.energy = 3.0
bpy.context.active_object.rotation_euler = (0.785, 0, -0.524)
bpy.ops.object.light_add(type="AREA", location=(-1, -1, 1))
l2 = bpy.context.active_object
l2.data.energy = 50
l2.data.size = 2.0
l2.rotation_euler = (1.047, 0, 1.047)

# ── Render orbital 7 vistas ──
sc.render.engine = "BLENDER_EEVEE_NEXT"
sc.render.resolution_x = 640
sc.render.resolution_y = 640
sc.render.image_settings.file_format = "PNG"

target = mathutils.Vector((0, 0, 0.2))
VISTAS = [
    ("00_frente", 0), ("01_trescuartos_izq", 45), ("02_perfil_izq", 90),
    ("03_atras", 180), ("04_trescuartos_der", 315), ("05_perfil_der", 270),
]
for nombre, angulo in VISTAS:
    ang = math.radians(angulo)
    offset = mathutils.Vector((math.sin(ang) * 0.8, -math.cos(ang) * 0.8, 0.35))
    sc.camera.location = target + offset
    dirv = target - sc.camera.location
    sc.camera.rotation_euler = dirv.to_track_quat("-Z", "Y").to_euler()
    sc.render.filepath = os.path.join(OUT_DIR, f"nutria_{nombre}.png")
    bpy.ops.render.render(write_still=True)
    print(f"RENDER: nutria_{nombre}")

# ── Guardar .blend ──
BLEND_OUT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\nutria_cozy.blend"
bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
print("GUARDADO:", BLEND_OUT)
print("=== NUTRIA V1 LISTA ===")
