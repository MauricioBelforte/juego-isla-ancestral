"""
M36: PEZ voxel cozy (0.3m) — cuerpo alargado con cola triangular, aleta dorsal,
ojo. Render CYCLES-CPU + guardado .blend.
"""
import bpy
import math
import os
import mathutils

OUT_DIR = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\godot-mcp\capturas\36-Fauna\pez"
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
    bsdf.inputs["Roughness"].default_value = 0.5
    return m

M_ESCAMA = mat("pez_escama", 0.30, 0.55, 0.75)   # azul acero
M_VIENTRE = mat("pez_vientre", 0.75, 0.85, 0.90) # blanco azulado
M_ALETA = mat("pez_aleta", 0.20, 0.40, 0.60)     # azul oscuro
M_OJOS = mat("ojos_negro", 0.03, 0.03, 0.03)
M_BRILLO = mat("brillo_blanco", 0.98, 0.98, 0.98)

def cubo(nombre, sx, sy, sz, x, y, z, material):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z))
    o = bpy.context.active_object
    o.name = nombre
    o.scale = (sx, sy, sz)
    bpy.ops.object.transform_apply(scale=True)
    o.data.materials.append(material)
    return o

# ── Pez mirando -Y, largo ~0.3m ──
# cuerpo: 2 cubos que se afinan
cubo("cuerpo_del", 0.10, 0.14, 0.10, 0, -0.075, 0.15, M_ESCAMA)
cubo("cuerpo_atr", 0.08, 0.16, 0.08, 0, 0.075, 0.15, M_ESCAMA)
# vientre claro
cubo("vientre", 0.06, 0.22, 0.04, 0, 0.0, 0.09, M_VIENTRE)
# cola triangular (2 cubos apilados hacia atrás, más chicos)
cubo("cola_base", 0.03, 0.10, 0.08, 0, 0.20, 0.15, M_ALETA)
cubo("cola_punta", 0.02, 0.14, 0.10, 0, 0.30, 0.15, M_ALETA)
# aleta dorsal (1 cubo arriba)
cubo("aleta_dorsal", 0.02, 0.14, 0.06, 0, 0.0, 0.26, M_ALETA)
# aletas laterales (2, abajo)
cubo("aleta_izq", 0.06, 0.05, 0.02, -0.07, -0.06, 0.10, M_ALETA)
cubo("aleta_der", 0.06, 0.05, 0.02, 0.07, -0.06, 0.10, M_ALETA)
# ojo con brillito
cubo("ojo_izq", 0.025, 0.02, 0.025, -0.045, -0.13, 0.19, M_OJOS)
cubo("ojo_der", 0.025, 0.02, 0.025, 0.045, -0.13, 0.19, M_OJOS)
cubo("brillo_izq", 0.010, 0.012, 0.010, -0.045, -0.137, 0.198, M_BRILLO)
cubo("brillo_der", 0.010, 0.012, 0.010, 0.045, -0.137, 0.198, M_BRILLO)
# boca (línea oscura)
cubo("boca", 0.05, 0.015, 0.015, 0, -0.148, 0.115, M_ALETA)

# ── Cámara + luces ──
bpy.ops.object.camera_add(location=(0.25, -0.35, 0.25), rotation=(1.134, 0, 0.611))
sc = bpy.context.scene
sc.camera = bpy.context.active_object
bpy.ops.object.light_add(type="SUN", location=(1, -1, 1.5))
bpy.context.active_object.data.energy = 3.0
bpy.context.active_object.rotation_euler = (0.785, 0, -0.524)
bpy.ops.object.light_add(type="AREA", location=(-0.5, -0.5, 0.5))
l2 = bpy.context.active_object
l2.data.energy = 30
l2.data.size = 0.8
l2.rotation_euler = (1.047, 0, 1.047)

# ── Render CYCLES-CPU ──
sc.render.engine = "CYCLES"
sc.cycles.device = "CPU"
sc.cycles.samples = 32
sc.render.resolution_x = 640
sc.render.resolution_y = 640
sc.render.image_settings.file_format = "PNG"

target = mathutils.Vector((0, 0, 0.15))
for nombre, angulo in [("perfil_izq", 90), ("trescuartos", 45), ("frente", 0)]:
    ang = math.radians(angulo)
    offset = mathutils.Vector((math.sin(ang) * 0.4, -math.cos(ang) * 0.4, 0.15))
    sc.camera.location = target + offset
    dirv = target - sc.camera.location
    sc.camera.rotation_euler = dirv.to_track_quat("-Z", "Y").to_euler()
    sc.render.filepath = os.path.join(OUT_DIR, f"pez_{nombre}.png")
    bpy.ops.render.render(write_still=True)
    print(f"RENDER: pez_{nombre}")

BLEND_OUT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\pez_cozy.blend"
bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
print("GUARDADO:", BLEND_OUT)
print("=== PEZ V1 LISTO ===")
