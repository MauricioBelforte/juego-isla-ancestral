"""
M36: ABEJA voxel cozy (0.1m) — cuerpo rayado amarillo/negro, alas blancas
translúcidas, ojos, aguijón. Render CYCLES-CPU + guardado .blend.
Aviso: 0.1m es diminuto — el render se hace con zoom cercano.
"""
import bpy
import math
import os
import mathutils

OUT_DIR = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\godot-mcp\capturas\36-Fauna\abeja"
os.makedirs(OUT_DIR, exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
for _ in range(3):
    for bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
        for item in list(bloque):
            if item.users == 0:
                bloque.remove(item)

def mat(nombre, r, g, b, emissive=0.0, alpha=1.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (r, g, b, alpha)
    bsdf.inputs["Roughness"].default_value = 0.6
    if emissive > 0:
        bsdf.inputs["Emission Color"].default_value = (r, g, b, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emissive
    if alpha < 1.0:
        bsdf.inputs["Alpha"].default_value = alpha
        m.use_backface_culling = False
    return m

M_AMARILLO = mat("abeja_amarillo", 0.95, 0.75, 0.10)
M_NEGRO = mat("abeja_negro", 0.08, 0.06, 0.04)
M_ALA = mat("ala_translucida", 0.85, 0.92, 1.0, 0.3, 0.55)
M_OJOS = mat("ojos_negro", 0.02, 0.02, 0.02)
M_AGUJON = mat("agujon_gris", 0.4, 0.4, 0.4)

def cubo(nombre, sx, sy, sz, x, y, z, material):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z))
    o = bpy.context.active_object
    o.name = nombre
    o.scale = (sx, sy, sz)
    bpy.ops.object.transform_apply(scale=True)
    o.data.materials.append(material)
    return o

# ── Abeja mirando -Y, largo ~0.1m ──
# cuerpo: 3 segmentos rayados (amarillo-negro-amarillo-negro-amarillo)
seg_y = [-0.04, -0.02, 0.0, 0.02, 0.04]
colores = [M_AMARILLO, M_NEGRO, M_AMARILLO, M_NEGRO, M_AMARILLO]
for i, (y, mcol) in enumerate(zip(seg_y, colores)):
    cubo(f"seg_{i}", 0.07, 0.02, 0.06, 0, y, 0.06, mcol)
# cabeza negra al frente
cubo("cabeza", 0.06, 0.03, 0.055, 0, -0.055, 0.06, M_NEGRO)
# ojos (2, apenas distinguibles sobre la cabeza negra — gris oscuro)
cubo("ojo_izq", 0.015, 0.012, 0.015, -0.02, -0.072, 0.068, M_OJOS)
cubo("ojo_der", 0.015, 0.012, 0.015, 0.02, -0.072, 0.068, M_OJOS)
# alas translúcidas (2, arriba, en diagonal)
cubo("ala_izq", 0.025, 0.05, 0.008, -0.035, 0.0, 0.10, M_ALA)
cubo("ala_der", 0.025, 0.05, 0.008, 0.035, 0.0, 0.10, M_ALA)
# aguijón atrás
cubo("agujon", 0.012, 0.025, 0.012, 0, 0.07, 0.06, M_AGUJON)

# ── Cámara MUY cerca (largo 0.1m) + luces ──
bpy.ops.object.camera_add(location=(0.12, -0.14, 0.10), rotation=(1.134, 0, 0.611))
sc = bpy.context.scene
sc.camera = bpy.context.active_object
bpy.ops.object.light_add(type="SUN", location=(0.5, -0.5, 0.8))
bpy.context.active_object.data.energy = 3.0
bpy.context.active_object.rotation_euler = (0.785, 0, -0.524)
bpy.ops.object.light_add(type="AREA", location=(-0.3, -0.3, 0.3))
l2 = bpy.context.active_object
l2.data.energy = 30
l2.data.size = 0.5
l2.rotation_euler = (1.047, 0, 1.047)

# ── Render CYCLES-CPU (para translucidez de alas) ──
sc.render.engine = "CYCLES"
sc.cycles.device = "CPU"
sc.cycles.samples = 32
sc.render.resolution_x = 640
sc.render.resolution_y = 640
sc.render.image_settings.file_format = "PNG"

target = mathutils.Vector((0, 0, 0.06))
for nombre, angulo in [("perfil_izq", 90), ("trescuartos", 45), ("frente", 0)]:
    ang = math.radians(angulo)
    offset = mathutils.Vector((math.sin(ang) * 0.12, -math.cos(ang) * 0.12, 0.05))
    sc.camera.location = target + offset
    dirv = target - sc.camera.location
    sc.camera.rotation_euler = dirv.to_track_quat("-Z", "Y").to_euler()
    sc.render.filepath = os.path.join(OUT_DIR, f"abeja_{nombre}.png")
    bpy.ops.render.render(write_still=True)
    print(f"RENDER: abeja_{nombre}")

BLEND_OUT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\abeja_cozy.blend"
bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
print("GUARDADO:", BLEND_OUT)
print("=== ABEJA V1 LISTA ===")
