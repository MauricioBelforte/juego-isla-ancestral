# -*- coding: utf-8 -*-
# Conejo v11: FIX DEL BUG PLANO — los anillos deben variar en Y (adelante-atrás)
# y ser perpendiculares al eje Y (plano XZ). Los del v10 eran YZ con cx=0 (plano).
import bpy
import os
import sys
import math
import bmesh
import mathutils
from math import cos, sin, pi

RAIZ_FAUNA = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\36-Fauna"
OUT_CAPTURAS = os.path.join(RAIZ_FAUNA, "capturas", "conejo_v11")
os.makedirs(OUT_CAPTURAS, exist_ok=True)
sys.path.insert(0, os.path.abspath(os.path.join(
    r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\36-Fauna\scripts",
    '..', '..', 'scripts-reutilizables')))
from plantilla_asset import (limpiar, mat, arena, iluminar, camara, shade_flat, RAIZ)

escena = limpiar()

MAT_pello = mat('MAT_Conejo_Pello', (0.78, 0.58, 0.38), rough=0.85)
MAT_vientre = mat('MAT_Conejo_Vientre', (0.95, 0.92, 0.85), rough=0.80)
MAT_ojos = mat('MAT_Conejo_Ojos', (0.05, 0.05, 0.05), rough=0.3)
MAT_brillo = mat('MAT_Conejo_Brillo', (0.98, 0.98, 0.98))
MAT_nariz = mat('MAT_Conejo_Nariz', (0.88, 0.58, 0.58))
MAT_patas = mat('MAT_Conejo_Patas', (0.70, 0.50, 0.32))

# ── Helpers ──
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

## ── FIX CLAVE: anillo en plano XZ (perpendicular a Y, el eje del cuerpo) ──
## El cuerpo del conejo se extiende a lo largo de Y (adelante-atrás).
## Los anillos deben ser PERPENDICULARES a Y (plano XZ) a distintas alturas Y.
def anillo_y(cy, cz, rx, rz, N=8):
    """Anillo elíptico en plano XZ a altura Y=cy. El eje del tubo es Y."""
    return [(rx * cos(2 * pi * a / N), cy, cz + rz * sin(2 * pi * a / N))
            for a in range(N)]

def cubo(nombre, sx, sy, sz, x, y, z, material):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z))
    o = bpy.context.active_object
    o.name = nombre
    o.scale = (sx, sy, sz)
    bpy.ops.object.transform_apply(scale=True)
    o.data.materials.append(material)
    return o

# ═══════════ 1) CUERPO LOFTADO a lo largo de Y (adelante-atrás) ═══════════
# cy VARÍA: +0.14 (grupa atrás) → -0.13 (cuello adelante)
# rx, rz = radios X y Z de cada anillo
AN_CUERPO = [
    anillo_y(0.14, 0.085, 0.030, 0.035),   # punta grupa
    anillo_y(0.11, 0.060, 0.075, 0.065),   # grupa máxima
    anillo_y(0.00, 0.000, 0.090, 0.075),   # centro (vientre)
    anillo_y(-0.08, -0.060, 0.085, 0.080), # pecho
    anillo_y(-0.13, -0.100, 0.070, 0.070), # cuello (adelante)
]
loft('SM_Conejo_Cuerpo', AN_CUERPO, MAT_pello)

# vientre canela (franja inferior)
AN_VIENTRE = [
    anillo_y(0.08, 0.060, 0.060, 0.040),
    anillo_y(0.00, 0.000, 0.075, 0.050),
    anillo_y(-0.08, -0.060, 0.070, 0.055),
]
loft('SM_Conejo_Vientre', AN_VIENTRE, MAT_vientre)

# ═══════════ 2) CABEZA LOFTADA a lo largo de Y ═══════════
# cabeza: de y=-0.15 (nuca) a y=-0.28 (hocico), centrada en x=0, z=0.26
AN_CABEZA = [
    anillo_y(-0.15, 0.265, 0.045, 0.040),   # nuca (se hunde en cuello)
    anillo_y(-0.19, 0.268, 0.070, 0.068),   # cráneo
    anillo_y(-0.23, 0.270, 0.075, 0.075),   # frente
    anillo_y(-0.26, 0.265, 0.065, 0.065),   # cara
    anillo_y(-0.28, 0.258, 0.045, 0.050),   # hocico base
]
loft('SM_Conejo_Cabeza', AN_CABEZA, MAT_pello)

# hocico crema (proyección adelante-abajo)
cubo('SM_Conejo_Hocico', 0.07, 0.05, 0.06, 0, -0.33, 0.20, MAT_vientre)
# nariz rosa
cubo('SM_Conejo_Nariz', 0.03, 0.015, 0.025, 0, -0.36, 0.20, MAT_nariz)

# ═══════════ 3) OREJAS (cubos planos, conectadas a la cabeza) ═══════════
# cabeza top ~0.35; orejas de 0.33 a 0.53 (conectadas)
cubo('SM_Conejo_Oreja_I', 0.045, 0.025, 0.20, -0.045, -0.20, 0.43, MAT_pello)
cubo('SM_Conejo_Oreja_D', 0.045, 0.025, 0.20, 0.045, -0.20, 0.43, MAT_pello)
cubo('SM_Conejo_Oreja_I_Int', 0.022, 0.012, 0.15, -0.045, -0.215, 0.43, MAT_vientre)
cubo('SM_Conejo_Oreja_D_Int', 0.022, 0.012, 0.15, 0.045, -0.215, 0.43, MAT_vientre)

# ═══════════ 4) OJOS + BRILLO (esferas, en los lados de la cabeza) ═══════════
for lado in [-1, 1]:
    l = 'I' if lado < 0 else 'D'
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.018,
        location=(lado * 0.058, -0.26, 0.30), segments=8, ring_count=6)
    ojo = bpy.context.active_object
    ojo.name = f'SM_Conejo_Ojo_{l}'
    ojo.scale = (0.6, 1.0, 1.0)
    bpy.ops.object.transform_apply(scale=True)
    ojo.data.materials.append(MAT_ojos)
    bpy.ops.object.shade_smooth()
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.006,
        location=(lado * 0.055, -0.272, 0.31), segments=6, ring_count=4)
    brillo = bpy.context.active_object
    brillo.name = f'SM_Conejo_Brillo_{l}'
    brillo.data.materials.append(MAT_brillo)
    bpy.ops.object.shade_smooth()

# ═══════════ 5) PATAS (cubos simples — probado, se ven bien) ═══════════
for lado in [-1, 1]:
    l = 'I' if lado < 0 else 'D'
    cubo(f'SM_Conejo_Pata_D_{l}', 0.06, 0.06, 0.10, lado * 0.055, -0.10, 0.05, MAT_patas)
    cubo(f'SM_Conejo_Pata_T_{l}', 0.07, 0.07, 0.10, lado * 0.075, 0.10, 0.05, MAT_patas)
    cubo(f'SM_Conejo_Pie_T_{l}', 0.055, 0.14, 0.035, lado * 0.075, 0.04, 0.02, MAT_patas)

# ═══════════ 6) COLA (esfera crema) ═══════════
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.045, location=(0, 0.17, 0.14),
                                     segments=10, ring_count=8)
cola = bpy.context.active_object
cola.name = 'SM_Conejo_Cola'
cola.scale = (0.8, 1.0, 0.9)
bpy.ops.object.transform_apply(scale=True)
cola.data.materials.append(MAT_vientre)
bpy.ops.object.shade_smooth()

# ═══════════ ARENA + ILUMINAR + ASENTAR + CÁMARA + RENDER ═══════════
arena(radio=1.0)
iluminar(escena)
# Asentado manual
bpy.context.view_layer.update()
ps = [o for o in escena.objects if o.type == 'MESH' and o.name.startswith('SM_')]
z_ini = min((o.matrix_world @ v.co).z for o in ps for v in o.data.vertices)
delta = 0.045 - z_ini
for o in ps:
    o.location.z += delta
bpy.context.view_layer.update()
z_fin = min((o.matrix_world @ v.co).z for o in ps for v in o.data.vertices)
print('ASENTADO: z_min %.4f -> %.4f' % (z_ini, z_fin))
camara(escena, 'CAM_Conejo', loc=(0.85, -1.1, 0.6), mira=(0, 0, 0.2))
# flat en cubos, smooth en lofts/esferas
for ob in escena.objects:
    if ob.type == 'MESH' and any(k in ob.name for k in ['Hocico', 'Oreja', 'Nariz', 'Pie', 'Base']):
        bpy.ops.object.select_all(action='DESELECT')
        ob.select_set(True)
        bpy.context.view_layer.objects.active = ob
        bpy.ops.object.shade_flat()

sc = escena
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
    sc.render.filepath = os.path.join(OUT_CAPTURAS, f'conejo_v11_{nombre}.png')
    bpy.ops.render.render(write_still=True)
    print(f'RENDER: conejo_v11_{nombre}')

BLEND_OUT = os.path.join(RAIZ_FAUNA, 'conejo_cozy_v11.blend')
bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
print('GUARDADO:', BLEND_OUT)
bpy.ops.object.select_all(action='DESELECT')
for o in escena.objects:
    if o.type == 'MESH':
        o.select_set(True)
GLB_OUT = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\36-Fauna_conejo.glb'
bpy.ops.export_scene.gltf(filepath=GLB_OUT, export_format='GLB', use_selection=True)
print('GLB:', GLB_OUT)
print('=== CONEJO V11 (3D REAL) ===')
