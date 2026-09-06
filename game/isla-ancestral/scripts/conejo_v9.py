"""
Conejo v9 — reconstruido CON plantilla_asset.py (iluminar/shade_flat/arena/asentar).
Cuerpo y cabeza loftados con bmesh, detalles con cubos. Export GLB.
"""
import bpy
import os
import sys
import math
import bmesh
import mathutils
from math import cos, sin, pi

RAIZ_FAUNA = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\36-Fauna"
OUT_CAPTURAS = os.path.join(RAIZ_FAUNA, "capturas", "conejo_v9")
os.makedirs(OUT_CAPTURAS, exist_ok=True)
sys.path.insert(0, os.path.abspath(os.path.join(
    r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\36-Fauna\scripts",
    '..', '..', 'scripts-reutilizables')))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar,
                             camara, shade_flat, guardar, RAIZ)

escena = limpiar()

# ── Materiales ──
MAT_pello = mat('MAT_Conejo_Pello', (0.78, 0.58, 0.38), rough=0.85)
MAT_vientre = mat('MAT_Conejo_Vientre', (0.95, 0.92, 0.85), rough=0.80)
MAT_ojos = mat('MAT_Conejo_Ojos', (0.05, 0.05, 0.05), rough=0.3)
MAT_brillo = mat('MAT_Conejo_Brillo', (0.98, 0.98, 0.98))
MAT_nariz = mat('MAT_Conejo_Nariz', (0.88, 0.58, 0.58))
MAT_patas = mat('MAT_Conejo_Patas', (0.70, 0.50, 0.32))

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
    me = bpy.data.meshes.new('M_' + nombre[3:])
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(ob)
    ob.data.materials.append(material)
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

# ═══════════ 1) CUERPO + VIENTRE (loft) ═══════════
AN_CUERPO = [
    anillo(0, 0.085, 0.030, 0.035),
    anillo(0, 0.060, 0.075, 0.065),
    anillo(0, 0.000, 0.090, 0.075),
    anillo(0, -0.060, 0.085, 0.080),
    anillo(0, -0.100, 0.070, 0.070),
]
loft('SM_Conejo_Cuerpo', AN_CUERPO, MAT_pello)
AN_VIENTRE = [
    anillo(0, 0.060, 0.060, 0.040),
    anillo(0, 0.000, 0.075, 0.050),
    anillo(0, -0.060, 0.070, 0.055),
]
loft('SM_Conejo_Vientre', AN_VIENTRE, MAT_vientre)

# ═══════════ 2) CABEZA (loft) + hocico + nariz ═══════════
AN_CABEZA = [
    anillo(-0.02, 0.215, 0.040, 0.035),
    anillo(-0.02, 0.195, 0.068, 0.065),
    anillo(-0.02, 0.170, 0.075, 0.080),
    anillo(-0.02, 0.150, 0.070, 0.075),
    anillo(-0.02, 0.130, 0.055, 0.060),
]
loft('SM_Conejo_Cabeza', AN_CABEZA, MAT_pello)
cubo('SM_Conejo_Hocico', 0.07, 0.05, 0.06, 0, -0.125, 0.195, MAT_vientre)
cubo('SM_Conejo_Nariz', 0.03, 0.015, 0.025, 0, -0.155, 0.20, MAT_nariz)

# ═══════════ 3) OREJAS (cubos, conectadas) ═══════════
cubo('SM_Conejo_Oreja_I', 0.045, 0.025, 0.20, -0.045, -0.14, 0.38, MAT_pello)
cubo('SM_Conejo_Oreja_D', 0.045, 0.025, 0.20, 0.045, -0.14, 0.38, MAT_pello)
cubo('SM_Conejo_Oreja_I_Int', 0.022, 0.012, 0.15, -0.045, -0.155, 0.38, MAT_vientre)
cubo('SM_Conejo_Oreja_D_Int', 0.022, 0.012, 0.15, 0.045, -0.155, 0.38, MAT_vientre)

# ═══════════ 4) OJOS + brillito (esferas smooth) ═══════════
for lado in [-1, 1]:
    l = 'I' if lado < 0 else 'D'
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.018,
        location=(lado * 0.058, -0.148, 0.268), segments=8, ring_count=6)
    ojo = bpy.context.active_object
    ojo.name = f'SM_Conejo_Ojo_{l}'
    ojo.scale = (0.6, 1.0, 1.0)
    bpy.ops.object.transform_apply(scale=True)
    ojo.data.materials.append(MAT_ojos)
    bpy.ops.object.shade_smooth()
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.006,
        location=(lado * 0.055, -0.163, 0.278), segments=6, ring_count=4)
    brillo = bpy.context.active_object
    brillo.name = f'SM_Conejo_Brillo_{l}'
    brillo.data.materials.append(MAT_brillo)
    bpy.ops.object.shade_smooth()

# ═══════════ 5) PATAS + PIES ═══════════
for lado in [-1, 1]:
    l = 'I' if lado < 0 else 'D'
    AN_PD = [anillo(lado * 0.055, 0.000, 0.032, 0.032, N=6),
             anillo(lado * 0.055, 0.000, 0.028, 0.028, N=6),
             anillo(lado * 0.055, 0.000, 0.020, 0.020, N=6)]
    loft(f'SM_Conejo_Pata_D_{l}', AN_PD, MAT_patas)
    AN_PT = [anillo(lado * 0.075, 0.000, 0.040, 0.040, N=6),
             anillo(lado * 0.075, 0.000, 0.035, 0.035, N=6),
             anillo(lado * 0.075, 0.000, 0.022, 0.022, N=6)]
    loft(f'SM_Conejo_Pata_T_{l}', AN_PT, MAT_patas)
    cubo(f'SM_Conejo_Pie_T_{l}', 0.055, 0.14, 0.035, lado * 0.075, 0.04, 0.02, MAT_patas)

# ═══════════ 6) COLA (esfera) ═══════════
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.045, location=(0, 0.17, 0.14),
                                     segments=10, ring_count=8)
cola = bpy.context.active_object
cola.name = 'SM_Conejo_Cola'
cola.scale = (0.8, 1.0, 0.9)
bpy.ops.object.transform_apply(scale=True)
cola.data.materials.append(MAT_vientre)
bpy.ops.object.shade_smooth()

# ═══════════ ORDEN CANÓNICO: arena, iluminar, asentar, camara, shade_flat, guardar ═══════════
arena(radio=1.0)
iluminar(escena)
asentar(escena)
camara(escena, 'CAM_Conejo', loc=(0.85, -1.1, 0.6), mira=(0, 0, 0.2))
# OJO: los ojos esféricos van smooth, el resto flat — shade_flat aplicado solo a lo loftado
for ob in escena.objects:
    if ob.type == 'MESH' and ('Cuerpo' in ob.name or 'Cabeza' in ob.name
                              or 'Vientre' in ob.name or 'Pata' in ob.name):
        pass  # mantener smooth en lofted
bpy.ops.object.select_all(action="DESELECT")
for ob in escena.objects:
    if ob.type == 'MESH' and ('Hocico' in ob.name or 'Oreja' in ob.name or 'Nariz' in ob.name
                              or 'Pie' in ob.name or 'Piso' in ob.name or 'Arena' in ob.name):
        ob.select_set(True)
        bpy.context.view_layer.objects.active = ob
bpy.ops.object.shade_flat()

sc.render.engine = 'CYCLES'
sc.cycles.device = 'CPU'
sc.cycles.samples = 32
sc.render.resolution_x = 640
sc.render.resolution_y = 640
sc.render.image_settings.file_format = 'PNG'

target = mathutils.Vector((0, 0, 0.18))
VISTAS = [
    ('00_frente', 0), ('01_trescuartos_izq', 45), ('02_perfil_izq', 90),
    ('03_atras', 180), ('04_trescuartos_der', 315), ('05_perfil_der', 270),
    ('06_cenital', -1),
]
for nombre, angulo in VISTAS:
    if angulo == -1:
        sc.camera.location = target + mathutils.Vector((0.0, 0.0, 0.9))
    else:
        ang = math.radians(angulo)
        offset = mathutils.Vector((math.sin(ang) * 0.65, -math.cos(ang) * 0.65, 0.25))
        sc.camera.location = target + offset
    dirv = target - sc.camera.location
    sc.camera.rotation_euler = dirv.to_track_quat('-Z', 'Y').to_euler()
    sc.render.filepath = os.path.join(OUT_CAPTURAS, f'conejo_v9_{nombre}.png')
    bpy.ops.render.render(write_still=True)
    print(f'RENDER: conejo_v9_{nombre}')

BLEND_OUT = os.path.join(RAIZ_FAUNA, 'conejo_cozy_v9.blend')
bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
print('GUARDADO:', BLEND_OUT)
bpy.ops.object.select_all(action='DESELECT')
for o in escena.objects:
    if o.type == 'MESH':
        o.select_set(True)
GLB_OUT = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\36-Fauna_conejo.glb'
bpy.ops.export_scene.gltf(filepath=GLB_OUT, export_format='GLB', use_selection=True)
print('GLB:', GLB_OUT)
print('=== CONEJO V9 CON PLANTILLA COMPLETO ===')
