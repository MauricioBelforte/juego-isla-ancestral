"""
M36/M45: Diseño procedural de CONEJO en estilo voxel cozy (Blender 4.2 bpy).
Renderiza 3 vistas (frente, 3/4, perfil) a PNG para análisis con visión.
Ejecutar: blender --background --python conejo_v1.py
Escala objetivo (escalas.json): conejo = 0.3m de alto.
"""
import bpy
import math
import os

OUT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\godot-mcp\capturas\36-Fauna"
os.makedirs(OUT, exist_ok=True)

# ── Limpieza total ──
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
for _ in range(3):
    for bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
        for item in list(bloque):
            if item.users == 0:
                bloque.remove(item)

# ── Materiales ──
def mat(nombre, r, g, b):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (r, g, b, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.9
    return m

M_PELLO = mat("pello_marron", 0.55, 0.38, 0.24)     # marrón conejo
M_VIENTRE = mat("vientre_crema", 0.92, 0.88, 0.80)  # crema
M_OJOS = mat("ojos_negro", 0.05, 0.05, 0.05)        # negro
M_NARIZ = mat("nariz_rosa", 0.85, 0.55, 0.55)       # rosa

# ── Helper: cubo voxel con material ──
def cubo(nombre, sx, sy, sz, x, y, z, material):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z))
    o = bpy.context.active_object
    o.name = nombre
    o.scale = (sx, sy, sz)
    bpy.ops.object.transform_apply(scale=True)
    o.data.materials.append(material)
    return o

# ── Conejo (mirando hacia -Y) — altura total ~0.3m ──
# cuerpo: 0.28 largo x 0.18 ancho x 0.16 alto, centro en z=0.13
cubo("cuerpo", 0.18, 0.28, 0.16, 0, 0.02, 0.13, M_PELLO)
# vientre (franja crema inferior)
cubo("vientre", 0.14, 0.20, 0.05, 0, 0.00, 0.045, M_VIENTRE)
# cabeza: 0.16³ delante-arriba
cubo("cabeza", 0.15, 0.15, 0.14, 0, -0.19, 0.24, M_PELLO)
# hocico (crema, chico al frente de la cabeza)
cubo("hocico", 0.09, 0.06, 0.08, 0, -0.28, 0.21, M_VIENTRE)
# nariz rosa
cubo("nariz", 0.04, 0.02, 0.03, 0, -0.315, 0.225, M_NARIZ)
# orejas largas (2) hacia arriba, levemente inclinadas hacia atrás
cubo("oreja_izq", 0.05, 0.03, 0.22, -0.05, -0.14, 0.44, M_PELLO)
cubo("oreja_der", 0.05, 0.03, 0.22, 0.05, -0.14, 0.44, M_PELLO)
# interior de orejas (crema, chico)
cubo("oreja_int_izq", 0.025, 0.015, 0.16, -0.05, -0.155, 0.44, M_VIENTRE)
cubo("oreja_int_der", 0.025, 0.015, 0.16, 0.05, -0.155, 0.44, M_VIENTRE)
# ojos (2, negros, a los costados de la cabeza)
cubo("ojo_izq", 0.03, 0.02, 0.03, -0.055, -0.245, 0.27, M_OJOS)
cubo("ojo_der", 0.03, 0.02, 0.03, 0.055, -0.245, 0.27, M_OJOS)
# patas delanteras (2)
cubo("pata_di", 0.07, 0.07, 0.10, -0.055, -0.12, 0.05, M_PELLO)
cubo("pata_dd", 0.07, 0.07, 0.10, 0.055, -0.12, 0.05, M_PELLO)
# patas traseras (2, más grandes, la zanca del conejo)
cubo("pata_ti", 0.08, 0.12, 0.10, -0.07, 0.10, 0.05, M_PELLO)
cubo("pata_td", 0.08, 0.12, 0.10, 0.07, 0.10, 0.05, M_PELLO)
# cola (pompón blanco)
cubo("cola", 0.10, 0.10, 0.10, 0, 0.19, 0.15, M_VIENTRE)

# ── Cámara + luz ──
bpy.ops.object.camera_add(location=(0.55, -0.75, 0.45), rotation=(math.radians(65), 0, math.radians(35)))
bpy.context.scene.camera = bpy.context.active_object

bpy.ops.object.light_add(type="SUN", location=(2, -2, 3))
sol = bpy.context.active_object
sol.data.energy = 3.0
sol.rotation_euler = (math.radians(45), 0, math.radians(-30))

bpy.ops.object.light_add(type="AREA", location=(-1, -1, 1))
relleno = bpy.context.active_object
relleno.data.energy = 50
relleno.data.size = 2.0
relleno.rotation_euler = (math.radians(60), 0, math.radians(60))

# ── Render settings (Workbench: headless-safe) ──
sc = bpy.context.scene
sc.render.engine = "BLENDER_EEVEE"
sc.render.eevee.taa_render_samples = 16
sc.render.resolution_x = 640
sc.render.resolution_y = 640
sc.render.image_settings.file_format = "PNG"

# ── 3 vistas: orbitar cámara ──
import mathutils
orig = sc.camera.location.copy()
target = mathutils.Vector((0, 0, 0.2))

def render_vista(nombre, angulo_grados, dist=0.9, altura=0.45):
    ang = math.radians(angulo_grados)
    offset = mathutils.Vector((math.sin(ang) * dist, -math.cos(ang) * dist, altura))
    sc.camera.location = target + offset
    # mirar al centro
    direccion = target - sc.camera.location
    sc.camera.rotation_euler = direccion.to_track_quat("-Z", "Y").to_euler()
    sc.render.filepath = os.path.join(OUT, nombre)
    bpy.ops.render.render(write_still=True)
    print("render:", sc.render.filepath)

render_vista("conejo_frente.png", 0)
render_vista("conejo_34.png", 35)
render_vista("conejo_perfil.png", 90)
print("=== CONEJO V1 RENDERIZADO ===")
