# crear_boton_piso_lowpoly.py - Boton de piso / placa de presion (M70-Interacciones)
# v1 2026-08-29 23:10 (log 249)
#
# Diseno: una base octogonal de piedra hundida en la arena, con una placa
# metalica INSERTA encima (10 cm mas chica, asi se lee como "placa que se
# hunde") y 4 pernos de bronce en los vertices de la placa.
#
# Todo en UNA sola malla bmesh y UN solo objeto (E-01). E-27 queda fuera de
# juego por construccion.
import bpy
import bmesh
import os
import math
from mathutils import Vector, Euler, Matrix

# ---------- 1) Limpieza (E-14: NUNCA wm.read_factory_settings por socket) ----------
for _obj in list(bpy.data.objects):
    bpy.data.objects.remove(_obj, do_unlink=True)
for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                bpy.data.cameras, bpy.data.worlds):
    for _dato in list(_bloque):
        if _dato.users == 0:
            _bloque.remove(_dato)
escena = bpy.context.scene

# ---------- 2) Materiales ----------
def crear_mat(nombre, color, rough=0.85, spec=0.20, metal=0.0, emis=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    if emis > 0.0:
        bsdf.inputs['Emission Strength'].default_value = emis
        bsdf.inputs['Emission Color'].default_value = (*color, 1.0)
    return m

MAT_piedra = crear_mat('MAT_Piedra_Boton', (0.54, 0.52, 0.48), rough=0.95)
MAT_hierro = crear_mat('MAT_Hierro_Placa', (0.43, 0.44, 0.46), rough=0.35,
                       spec=0.60, metal=0.88)
MAT_bronce = crear_mat('MAT_Bronce_Perno', (0.74, 0.54, 0.28), rough=0.30,
                       spec=0.65, metal=0.92, emis=0.35)
MAT_arena  = crear_mat('MAT_Arena_Isla',   (0.92, 0.84, 0.63), rough=1.00)

I_PIEDRA, I_HIERRO, I_BRONCE = 0, 1, 2

# ---------- 3) Disco de arena (NO exportar) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.2, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base_disco = bpy.context.object
base_disco.name = 'Base_Arena'
base_disco.data.materials.append(MAT_arena)

# ---------- 4) Parametros ----------
Z_APOYO = 0.045

# Base de piedra: tronco octogonal apenas conico (mas ancho abajo)
PIE_Z0, PIE_Z1 = 0.00, 0.10
PIE_R0, PIE_R1 = 0.52, 0.50
PIE_LAD = 8

# Placa metalica: mas chica que la piedra -> se lee como inserta en un rebaje
PLA_Z0, PLA_Z1 = PIE_Z1, 0.17
PLA_R0, PLA_R1 = 0.40, 0.36
PLA_LAD = 8

# Pernos de bronce: 4, sobre la placa, a 45/135/225/315 grados
PER_R    = 0.024
PER_H    = 0.022
PER_LAD  = 6
PER_RADIO_POS = 0.26          # distancia al centro sobre la placa
PER_ANGULOS = (45.0, 135.0, 225.0, 315.0)

# ---------- 5) Helpers ----------
bm = bmesh.new()
TOL = 1e-4

def volumen_firmado(caras):
    """Volumen con signo de una isla CERRADA (E-32 v2)."""
    v = 0.0
    for f in caras:
        co = [vert.co for vert in f.verts]
        for k in range(1, len(co) - 1):
            v += co[0].dot(co[k].cross(co[k + 1]))
    return v / 6.0

def cerrar_isla(caras):
    bmesh.ops.recalc_face_normals(bm, faces=caras)
    if volumen_firmado(caras) < 0.0:
        bmesh.ops.reverse_faces(bm, faces=caras)
    return caras

def cono_revolucion(z0, z1, r0, r1, lados, mat):
    """Tronco de cono (o cilindro si r0 == r1) con tapas, eje Z."""
    anillos = []
    for (z, r) in ((z0, r0), (z1, r1)):
        anillo = []
        for k in range(lados):
            a = 2.0 * math.pi * k / lados
            anillo.append(bm.verts.new(Vector((r * math.cos(a),
                                               r * math.sin(a), z))))
        anillos.append(anillo)
    a0, a1 = anillos
    caras = []
    if r0 > 1e-6:
        caras.append(bm.faces.new(list(reversed(a0))))   # tapa inferior, -Z
    if r1 > 1e-6:
        caras.append(bm.faces.new(a1))                   # tapa superior, +Z
    for k in range(lados):
        k2 = (k + 1) % lados
        caras.append(bm.faces.new((a0[k], a0[k2], a1[k2], a1[k])))
    for f in caras:
        f.material_index = mat
    return cerrar_isla(caras)

# ---------- 6) Comprobaciones en caliente ----------
assert PIE_Z0 == 0.0, 'PIE: el fondo debe estar en z=0'
assert PLA_Z0 == PIE_Z1, 'PLACA: debe arrancar en el techo de la piedra'
assert PLA_R0 < PIE_R1 - 0.05, \
    'PLACA: no esta insertada (r placa %.3f vs r piedra %.3f)' % (PLA_R0, PIE_R1)
assert PLA_Z1 > PLA_Z0, 'PLACA: altura invalida'
assert PER_RADIO_POS + PER_R < PLA_R1, \
    'PERNO: se cae de la placa (%.3f + %.3f vs r sup %.3f)' % \
    (PER_RADIO_POS, PER_R, PLA_R1)
print('GEOMETRIA ok: piedra r %.2f->%.2f z[%.2f..%.2f], placa r %.2f->%.2f '
      'z[%.2f..%.2f], rebaje %.3f m'
      % (PIE_R0, PIE_R1, PIE_Z0, PIE_Z1, PLA_R0, PLA_R1, PLA_Z0, PLA_Z1,
         PIE_R1 - PLA_R0))

# ---------- 7) Construir ----------
cono_revolucion(PIE_Z0, PIE_Z1, PIE_R0, PIE_R1, PIE_LAD, I_PIEDRA)
cono_revolucion(PLA_Z0, PLA_Z1, PLA_R0, PLA_R1, PLA_LAD, I_HIERRO)

for ang in PER_ANGULOS:
    a = math.radians(ang)
    cx = PER_RADIO_POS * math.cos(a)
    cy = PER_RADIO_POS * math.sin(a)
    # perno = cilindro corto apoyado sobre la cara superior de la placa
    cono_revolucion(PLA_Z1, PLA_Z1 + PER_H, PER_R, PER_R * 0.82,
                    PER_LAD, I_BRONCE)
    # recolocar el ultimo anillo creado (el perno) a su posicion
    # -> lo hacemos moviendo los vertices recien creados
    n = len(bm.verts)
    # los ultimos 2*PER_LAD vertices son los del perno
    for v in list(bm.verts)[-2 * PER_LAD:]:
        v.co.x += cx
        v.co.y += cy
    del n

# ---------- 8) Cerrar y crear el objeto ----------
bm.normal_update()
n_tris = sum(len(f.verts) - 2 for f in bm.faces)
me = bpy.data.meshes.new('SM_Boton_Piso')
bm.to_mesh(me)
bm.free()

boton = bpy.data.objects.new('SM_Boton_Piso', me)
escena.collection.objects.link(boton)
boton.data.materials.append(MAT_piedra)   # slot 0
boton.data.materials.append(MAT_hierro)   # slot 1
boton.data.materials.append(MAT_bronce)   # slot 2

bpy.ops.object.select_all(action='DESELECT')
boton.select_set(True)
bpy.context.view_layer.objects.active = boton
bpy.ops.object.shade_flat()

# ---------- 9) Asentado (E-12) ----------
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Boton')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:
        o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
print('BOTON asentado: z_min %.4f -> %.4f (delta %+.4f, piezas=%d)'
      % (z_min, z_fin, delta, len(piezas)))

bb = [boton.matrix_world @ Vector(c) for c in boton.bound_box]
print('BBOX x[%.3f..%.3f] y[%.3f..%.3f] z[%.3f..%.3f]'
      % (min(v.x for v in bb), max(v.x for v in bb),
         min(v.y for v in bb), max(v.y for v in bb),
         min(v.z for v in bb), max(v.z for v in bb)))

# ---------- 10) Iluminacion + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(6), math.radians(30)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 11) Camara ----------
bpy.ops.object.camera_add(location=(1.05, -1.05, 0.62))
cam = bpy.context.object
cam.name = 'CAM_Boton'
blanco = Vector((0.0, 0.0, 0.09))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 40
escena.camera = cam

# ---------- 12) Guardar (E-21: borrar el @ antes de guardar) ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '70-Interacciones',
                          'boton_piso_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_obj = len([o for o in escena.objects if o.name.startswith('SM_')])
print('BOTON PISO OK - objetos SM_: %d - tris: %d - materiales: %d'
      % (n_obj, n_tris, len(boton.data.materials)))
