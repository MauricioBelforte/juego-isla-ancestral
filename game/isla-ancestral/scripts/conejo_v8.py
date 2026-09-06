"""
Conejo v8: materiales aclarados + orejas como cubos planos (no loft rotos).
Solo el CUERPO y CABEZA usan loft (redondeado). Verificación de color.
"""
import bpy
import os
import sys
import math
import bmesh
import mathutils
from math import cos, sin, pi

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\36-Fauna"
OUT_CAPTURAS = os.path.join(RAIZ, "capturas", "conejo_v8")
os.makedirs(OUT_CAPTURAS, exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
for _ in range(3):
    for bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.images, bpy.data.lights, bpy.data.cameras, bpy.data.worlds):
        for item in list(bloque):
            if item.users == 0:
                bloque.remove(item)

def MAT_(nombre, r, g, b, rough=0.85):
    m = bpy.data.materials.new("MAT_" + nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (r, g, b, 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    return m

# MATERIALES ACLARADOS (fix del problema negro)
MAT_pello = MAT_("Conejo_Pello", 0.78, 0.58, 0.38, rough=0.85)     # marrón claro
MAT_vientre = MAT_("Conejo_Vientre", 0.95, 0.92, 0.85, rough=0.80)  # crema
MAT_ojos = MAT_("Conejo_Ojos", 0.05, 0.05, 0.05, rough=0.3)
MAT_brillo = MAT_("Conejo_Brillo", 0.98, 0.98, 0.98)
MAT_nariz = MAT_("Conejo_Nariz", 0.88, 0.58, 0.58)
MAT_patas = MAT_("Conejo_Patas", 0.70, 0.50, 0.32)

# ── Helpers bmesh ──
def _vol(caras):
    v = 0.0
    for f in caras:
        co = [vt.co for vt in f.verts]
        for k in range(1, len(co) - 1):
            v += co[0].dot(co[k].cross(co[k + 1]))
    return v / 6.0

def _isla(bm, caras):
    bmesh.ops.recalc_face_normals(bm, faces=caras)
    if _vol(caras) < 0.0:
        bmesh.ops.reverse_faces(bm, faces=caras)

def _obj(nombre, bm, material):
    me = bpy.data.meshes.new("M_" + nombre[3:])
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(nombre, me)
    bpy.context.scene.collection.objects.link(ob)
    ob.data.materials.append(material)
    # shade smooth para el cuerpo redondeado
    bpy.ops.object.select_all(action="DESELECT")
    ob.select_set(True)
    bpy.context.view_layer.objects.active = ob
    bpy.ops.object.shade_smooth()
    return ob

def loft(nombre, anillos, material):
    bm = bmesh.new()
    rings = [[bm.verts.new(v) for v in ring] for ring in anillos]
    N = len(rings[0])
    caras = []
    for k in range(len(rings) - 1):
        for a in range(N):
            b = (a + 1) % N
            caras.append(bm.faces.new((rings[k][a], rings[k][b],
                                       rings[k + 1][b], rings[k + 1][a])))
    for a in range(1, N - 1):
        caras.append(bm.faces.new((rings[0][0], rings[0][a], rings[0][a + 1])))
        caras.append(bm.faces.new((rings[-1][0], rings[-1][a + 1], rings[-1][a])))
    _isla(bm, caras)
    return _obj(nombre, bm, material)

def anillo(cx, cz, ry, rz, N=8):
    return [(cx, ry * cos(2 * pi * a / N), cz + rz * sin(2 * pi * a / N))
            for a in range(N)]

def cubo(nombre, sx, sy, sz, x, y, z, material):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z))
    o = bpy.context.active_object
    o.name = nombre
    o.scale = (sx, sy, sz)
    bpy.ops.object.transform_apply(scale=True)
    o.data.materials.append(material)
    return o

# ═══════════ 1) CUERPO LOFTADO ═══════════
AN_CUERPO = [
    anillo(0, 0.085, 0.030, 0.035),
    anillo(0, 0.060, 0.075, 0.065),
    anillo(0, 0.000, 0.090, 0.075),
    anillo(0, -0.060, 0.085, 0.080),
    anillo(0, -0.100, 0.070, 0.070),
]
loft("SM_Conejo_Cuerpo", AN_CUERPO, MAT_pello)
AN_VIENTRE = [
    anillo(0, 0.060, 0.060, 0.040),
    anillo(0, 0.000, 0.075, 0.050),
    anillo(0, -0.060, 0.070, 0.055),
]
loft("SM_Conejo_Vientre", AN_VIENTRE, MAT_vientre)

# ═══════════ 2) CABEZA LOFTADA ═══════════
AN_CABEZA = [
    anillo(-0.02, 0.215, 0.040, 0.035),
    anillo(-0.02, 0.195, 0.068, 0.065),
    anillo(-0.02, 0.170, 0.075, 0.080),
    anillo(-0.02, 0.150, 0.070, 0.075),
    anillo(-0.02, 0.130, 0.055, 0.060),
]
loft("SM_Conejo_Cabeza", AN_CABEZA, MAT_pello)
# hocico crema
cubo("SM_Conejo_Hocico", 0.07, 0.05, 0.06, 0, -0.125, 0.195, MAT_vientre)
cubo("SM_Conejo_Nariz", 0.03, 0.015, 0.025, 0, -0.155, 0.20, MAT_nariz)

# ═══════════ 3) OREJAS: cubos planos con scale (no loft rotas) ═══════════
# base en z=0.29 (dentro de cabeza top 0.31); alto 0.20
cubo("SM_Conejo_Oreja_I", 0.045, 0.025, 0.20, -0.045, -0.14, 0.38, MAT_pello)
cubo("SM_Conejo_Oreja_D", 0.045, 0.025, 0.20, 0.045, -0.14, 0.38, MAT_pello)
cubo("SM_Conejo_Oreja_I_Int", 0.022, 0.012, 0.15, -0.045, -0.155, 0.38, MAT_vientre)
cubo("SM_Conejo_Oreja_D_Int", 0.022, 0.012, 0.15, 0.045, -0.155, 0.38, MAT_vientre)

# ═══════════ 4) OJOS (esferas suaves) ═══════════
for lado in [-1, 1]:
    l = 'I' if lado < 0 else 'D'
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.018,
        location=(lado * 0.058, -0.148, 0.268), segments=8, ring_count=6)
    ojo = bpy.context.active_object
    ojo.name = f"SM_Conejo_Ojo_{l}"
    ojo.scale = (0.6, 1.0, 1.0)
    bpy.ops.object.transform_apply(scale=True)
    ojo.data.materials.append(MAT_ojos)
    bpy.ops.object.shade_smooth()
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.006,
        location=(lado * 0.055, -0.163, 0.278), segments=6, ring_count=4)
    brillo = bpy.context.active_object
    brillo.name = f"SM_Conejo_Brillo_{l}"
    brillo.data.materials.append(MAT_brillo)
    bpy.ops.object.shade_smooth()

# ═══════════ 5) PATAS ═══════════
for lado in [-1, 1]:
    l = 'I' if lado < 0 else 'D'
    AN_PD = [anillo(lado * 0.055, 0.000, 0.032, 0.032, N=6),
             anillo(lado * 0.055, 0.000, 0.028, 0.028, N=6),
             anillo(lado * 0.055, 0.000, 0.020, 0.020, N=6)]
    loft(f"SM_Conejo_Pata_D_{l}", AN_PD, MAT_patas)
    AN_PT = [anillo(lado * 0.075, 0.000, 0.040, 0.040, N=6),
             anillo(lado * 0.075, 0.000, 0.035, 0.035, N=6),
             anillo(lado * 0.075, 0.000, 0.022, 0.022, N=6)]
    loft(f"SM_Conejo_Pata_T_{l}", AN_PT, MAT_patas)
    cubo(f"SM_Conejo_Pie_T_{l}", 0.055, 0.14, 0.035, lado * 0.075, 0.04, 0.02, MAT_patas)

# ═══════════ 6) COLA ═══════════
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.045, location=(0, 0.17, 0.14),
                                     segments=10, ring_count=8)
cola = bpy.context.active_object
cola.name = "SM_Conejo_Cola"
cola.scale = (0.8, 1.0, 0.9)
bpy.ops.object.transform_apply(scale=True)
cola.data.materials.append(MAT_vientre)
bpy.ops.object.shade_smooth()

# ═══════════ Piso + cámara + luces ═══════════
bpy.ops.mesh.primitive_plane_add(size=1.5, location=(0, 0, 0))
piso = bpy.context.active_object
piso.name = "Piso_Arena"
piso.data.materials.append(MAT_("Arena", 0.72, 0.65, 0.45))

bpy.ops.object.camera_add(location=(0.55, -0.75, 0.45), rotation=(1.134, 0, 0.611))
sc = bpy.context.scene
sc.camera = bpy.context.active_object
bpy.ops.object.light_add(type="SUN", location=(2, -2, 3))
bpy.context.active_object.data.energy = 4.0
bpy.context.active_object.rotation_euler = (0.785, 0, -0.524)
bpy.ops.object.light_add(type="AREA", location=(-1, -1, 1))
l2 = bpy.context.active_object
l2.data.energy = 100
l2.data.size = 2.0
l2.rotation_euler = (1.047, 0, 1.047)

# ═══════════ Render CYCLES (colores correctos) ═══════════
sc.render.engine = "CYCLES"
sc.cycles.device = "CPU"
sc.cycles.samples = 32
sc.render.resolution_x = 640
sc.render.resolution_y = 640
sc.render.image_settings.file_format = "PNG"

target = mathutils.Vector((0, 0, 0.18))
VISTAS = [
    ("00_frente", 0), ("01_trescuartos_izq", 45), ("02_perfil_izq", 90),
    ("03_atras", 180), ("04_trescuartos_der", 315), ("05_perfil_der", 270),
    ("06_cenital", -1),
]
for nombre, angulo in VISTAS:
    if angulo == -1:
        sc.camera.location = target + mathutils.Vector((0.0, 0.0, 0.9))
    else:
        ang = math.radians(angulo)
        offset = mathutils.Vector((math.sin(ang) * 0.65, -math.cos(ang) * 0.65, 0.25))
        sc.camera.location = target + offset
    dirv = target - sc.camera.location
    sc.camera.rotation_euler = dirv.to_track_quat("-Z", "Y").to_euler()
    sc.render.filepath = os.path.join(OUT_CAPTURAS, f"conejo_v8_{nombre}.png")
    bpy.ops.render.render(write_still=True)
    print(f"RENDER: conejo_v8_{nombre}")

BLEND_OUT = os.path.join(RAIZ, "conejo_cozy_v8.blend")
bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
print("GUARDADO:", BLEND_OUT)
GLB_OUT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\36-Fauna_conejo.glb"
bpy.ops.object.select_all(action="DESELECT")
for o in sc.objects:
    if o.type == "MESH":
        o.select_set(True)
bpy.ops.export_scene.gltf(filepath=GLB_OUT, export_format="GLB", use_selection=True)
print("GLB:", GLB_OUT)
print("=== CONEJO V8 COMPLETO ===")
