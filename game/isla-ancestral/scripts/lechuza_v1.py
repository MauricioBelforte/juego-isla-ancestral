"""
M36: LECHUZA voxel cozy (0.5m) — cuerpo redondo, cara plana con disco facial,
ojos grandes, pico, patas cortas. Render CYCLES-CPU + guardado .blend.
"""
import bpy
import math
import os
import mathutils

OUT_DIR = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\godot-mcp\capturas\36-Fauna\lechuza"
os.makedirs(OUT_DIR, exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
for _ in range(3):
    for bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
        for item in list(bloque):
            if item.users == 0:
                bloque.remove(item)

def mat(nombre, r, g, b):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (r, g, b, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.9
    return m

M_PLUMAJE = mat("lechuza_canela", 0.72, 0.55, 0.35)
M_DISCO = mat("disco_facial", 0.92, 0.87, 0.75)
M_ALAS = mat("alas_marron", 0.45, 0.32, 0.20)
M_OJOS = mat("ojos_negro", 0.03, 0.03, 0.03)
M_BRILLO = mat("brillo_blanco", 0.98, 0.98, 0.98)
M_PICO = mat("pico_amarillo", 0.85, 0.65, 0.20)
M_PATAS = mat("patas_amarillo", 0.80, 0.60, 0.25)

def cubo(nombre, sx, sy, sz, x, y, z, material):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z))
    o = bpy.context.active_object
    o.name = nombre
    o.scale = (sx, sy, sz)
    bpy.ops.object.transform_apply(scale=True)
    o.data.materials.append(material)
    return o

# ── Lechuza mirando -Y, altura ~0.5m ──
# cuerpo redondo (huevo vertical): 0.22 ancho x 0.20 largo x 0.30 alto
cubo("cuerpo", 0.22, 0.20, 0.30, 0, 0, 0.18, M_PLUMAJE)
# disco facial (placa crema al frente-arriba del cuerpo)
cubo("disco_facial", 0.20, 0.04, 0.18, 0, -0.115, 0.36, M_DISCO)
# ojos GRANDES (marca de la lechuza)
cubo("ojo_izq", 0.055, 0.02, 0.055, -0.055, -0.14, 0.40, M_OJOS)
cubo("ojo_der", 0.055, 0.02, 0.055, 0.055, -0.14, 0.40, M_OJOS)
cubo("brillo_izq", 0.018, 0.012, 0.018, -0.048, -0.152, 0.415, M_BRILLO)
cubo("brillo_der", 0.018, 0.012, 0.018, 0.048, -0.152, 0.415, M_BRILLO)
# pico triangular (2 cubos apilados, amarillo)
cubo("pico_sup", 0.03, 0.03, 0.03, 0, -0.14, 0.355, M_PICO)
cubo("pico_inf", 0.02, 0.02, 0.02, 0, -0.135, 0.33, M_PICO)
# "cejas" del disco (marcando la cara en V)
cubo("ceja_izq", 0.08, 0.03, 0.02, -0.05, -0.125, 0.445, M_PLUMAJE)
cubo("ceja_der", 0.08, 0.03, 0.02, 0.05, -0.125, 0.445, M_PLUMAJE)
# alas plegadas a los costados
cubo("ala_izq", 0.04, 0.18, 0.24, -0.13, 0.0, 0.18, M_ALAS)
cubo("ala_der", 0.04, 0.18, 0.24, 0.13, 0.0, 0.18, M_ALAS)
# penacho de cabeza (2 cubitos arriba)
cubo("penacho_izq", 0.03, 0.03, 0.04, -0.05, -0.05, 0.35, M_PLUMAJE)
cubo("penacho_der", 0.03, 0.03, 0.04, 0.05, -0.05, 0.35, M_PLUMAJE)
# patas cortas (2)
cubo("pata_izq", 0.05, 0.05, 0.06, -0.06, -0.02, 0.03, M_PATAS)
cubo("pata_der", 0.05, 0.05, 0.06, 0.06, -0.02, 0.03, M_PATAS)

# ── Cámara + luces ──
bpy.ops.object.camera_add(location=(0.6, -0.8, 0.5), rotation=(1.134, 0, 0.611))
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

# ── Render CYCLES-CPU: perfil + 3/4 ──
sc.render.engine = "CYCLES"
sc.cycles.device = "CPU"
sc.cycles.samples = 32
sc.render.resolution_x = 640
sc.render.resolution_y = 640
sc.render.image_settings.file_format = "PNG"

target = mathutils.Vector((0, 0, 0.25))
for nombre, angulo in [("perfil_izq", 90), ("trescuartos", 45), ("frente", 0)]:
    ang = math.radians(angulo)
    offset = mathutils.Vector((math.sin(ang) * 0.7, -math.cos(ang) * 0.7, 0.25))
    sc.camera.location = target + offset
    dirv = target - sc.camera.location
    sc.camera.rotation_euler = dirv.to_track_quat("-Z", "Y").to_euler()
    sc.render.filepath = os.path.join(OUT_DIR, f"lechuza_{nombre}.png")
    bpy.ops.render.render(write_still=True)
    print(f"RENDER: lechuza_{nombre}")

BLEND_OUT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\lechuza_cozy.blend"
bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
print("GUARDADO:", BLEND_OUT)
print("=== LECHUZA V1 LISTA ===")
