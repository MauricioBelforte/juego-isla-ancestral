# crear_cofre_pequeno_lowpoly.py - Cofre pequeno de madera (M70 / M25)
# v1 2026-08-29 23:30 (log 249)
#
# Variante CHICA del cofre ancestral de M25 (33 piezas / 7 mats). Esta es la
# version de un solo cuerpo para M70: cuerpo de madera + tapa de media cana
# (barril) + 2 bandas de hierro + cierre de bronce. 3 materiales, 1 objeto.
#
# Todo en UNA sola malla bmesh y UN solo objeto (E-01). E-27 fuera de juego.
import bpy
import bmesh
import os
import math
from mathutils import Vector, Euler

# ---------- 1) Limpieza (E-14) ----------
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

MAT_madera = crear_mat('MAT_Madera_Cofre_Peq', (0.44, 0.28, 0.15), rough=0.88)
MAT_hierro = crear_mat('MAT_Hierro_Cofre_Peq', (0.36, 0.37, 0.40),
                       rough=0.38, spec=0.58, metal=0.86)
MAT_bronce = crear_mat('MAT_Bronce_Cierre',   (0.74, 0.54, 0.28),
                       rough=0.30, spec=0.65, metal=0.92, emis=0.35)
MAT_arena  = crear_mat('MAT_Arena_Isla',      (0.92, 0.84, 0.63), rough=1.00)

I_MAD, I_HIE, I_BRO = 0, 1, 2

# ---------- 3) Disco de arena (NO exportar) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.2, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base_disco = bpy.context.object
base_disco.name = 'Base_Arena'
base_disco.data.materials.append(MAT_arena)

# ---------- 4) Parametros ----------
Z_APOYO = 0.045

# Cuerpo: caja de madera apoyada directo en la arena
CUER_SX, CUER_SY, CUER_SZ = 0.31, 0.20, 0.15
CUER_CZ = CUER_SZ                       # 0.15 -> fondo z=0, techo z=0.30

# Tapa: media cana (barril) a lo largo de X, apoyada en el techo del cuerpo
TAPA_R   = CUER_SY                      # 0.20, coincide con el ancho del cuerpo
TAPA_Z0  = 2 * CUER_SZ                  # 0.30, plano de arranque
TAPA_LAD = 6                            # segmentos del semicirculo

# Bandas de hierro: 2 listones verticales en el cuerpo
BAN_SX, BAN_SY, BAN_SZ = 0.030, CUER_SY + 0.006, 0.115
BAN_CZ = 0.15
BAN_X  = (-0.17, 0.17)

# Cierre de bronce: en la cara frontal (+Y), a caballo entre cuerpo y tapa
CIE_SX, CIE_SY, CIE_SZ = 0.055, 0.030, 0.055
CIE_CY = CUER_SY + CIE_SY
CIE_CZ = 2 * CUER_SZ                    # 0.30, justo en la union

# ---------- 5) Helpers ----------
bm = bmesh.new()
TOL = 1e-4

def volumen_firmado(caras):
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

def caja_vec(centro, ex, ey, ez, mat):
    v = []
    for sz in (-1, 1):
        for sy in (-1, 1):
            for sx in (-1, 1):
                v.append(bm.verts.new(centro + sx * ex + sy * ey + sz * ez))
    caras = [
        bm.faces.new((v[0], v[1], v[3], v[2])),
        bm.faces.new((v[4], v[6], v[7], v[5])),
        bm.faces.new((v[0], v[4], v[5], v[1])),
        bm.faces.new((v[2], v[3], v[7], v[6])),
        bm.faces.new((v[0], v[2], v[6], v[4])),
        bm.faces.new((v[1], v[5], v[7], v[3])),
    ]
    for f in caras:
        f.material_index = mat
    return cerrar_isla(caras)

def caja(cx, cy, cz, sx, sy, sz, mat):
    return caja_vec(Vector((cx, cy, cz)),
                    Vector((sx, 0.0, 0.0)),
                    Vector((0.0, sy, 0.0)),
                    Vector((0.0, 0.0, sz)), mat)

def media_cana(x0, x1, cy, cz, radio, lados, mat):
    """Tapa de barril: semicilindro cerrado a lo largo de X.
    cz = altura del plano de arranque (el fondo plano de la tapa)."""
    anillos = []
    for x in (x0, x1):
        anillo = []
        for k in range(lados + 1):
            a = math.pi * k / lados           # 0 (+Y) -> pi (-Y) por arriba
            anillo.append(bm.verts.new(Vector((x,
                                               cy + radio * math.cos(a),
                                               cz + radio * math.sin(a)))))
        anillos.append(anillo)
    a0, a1 = anillos
    caras = []
    for k in range(lados):                    # arco
        caras.append(bm.faces.new((a0[k], a0[k + 1], a1[k + 1], a1[k])))
    caras.append(bm.faces.new((a0[0], a0[lados], a1[lados], a1[0])))   # fondo plano
    caras.append(bm.faces.new(list(a0)))                                # tapa x0
    caras.append(bm.faces.new(list(reversed(a1))))                     # tapa x1
    for f in caras:
        f.material_index = mat
    return cerrar_isla(caras)

# ---------- 6) Comprobaciones en caliente ----------
assert CUER_CZ == CUER_SZ, 'CUERPO: el fondo debe estar en z=0'
assert abs(TAPA_Z0 - 2 * CUER_SZ) < TOL, 'TAPA: debe arrancar en el techo del cuerpo'
assert abs(TAPA_R - CUER_SY) < TOL, \
    'TAPA: el radio debe coincidir con el ancho del cuerpo (si no, vuela)'
for bx in BAN_X:
    assert abs(bx) + BAN_SX < CUER_SX, \
        'BANDA: x=%.3f se sale del cuerpo (%.3f)' % (bx, CUER_SX)
assert BAN_CZ - BAN_SZ > 0.0, 'BANDA: atraviesa el fondo del cuerpo'
assert BAN_CZ + BAN_SZ < 2 * CUER_SZ + TOL, 'BANDA: se mete en la tapa'
assert CIE_CY > CUER_SY, 'CIERRE: no sobresale de la cara frontal'
assert CIE_CZ - CIE_SZ < TAPA_Z0, 'CIERRE: debe cabalgar cuerpo y tapa'
assert CIE_CZ + CIE_SZ > TAPA_Z0, 'CIERRE: no llega a la tapa'
print('GEOMETRIA ok: cuerpo %.2fx%.2fx%.2f, tapa barril r=%.2f (alto total %.2f), '
      '%d bandas, cierre en y=%.3f'
      % (2 * CUER_SX, 2 * CUER_SY, 2 * CUER_SZ, TAPA_R,
         TAPA_Z0 + TAPA_R, len(BAN_X), CIE_CY))

# ---------- 7) Construir ----------
caja(0.0, 0.0, CUER_CZ, CUER_SX, CUER_SY, CUER_SZ, I_MAD)
media_cana(-CUER_SX, CUER_SX, 0.0, TAPA_Z0, TAPA_R, TAPA_LAD, I_MAD)
for bx in BAN_X:
    caja(bx, 0.0, BAN_CZ, BAN_SX, BAN_SY, BAN_SZ, I_HIE)
caja(0.0, CIE_CY, CIE_CZ, CIE_SX, CIE_SY, CIE_SZ, I_BRO)

# ---------- 8) Cerrar y crear el objeto ----------
bm.normal_update()
n_tris = sum(len(f.verts) - 2 for f in bm.faces)
me = bpy.data.meshes.new('SM_Cofre_Pequeno')
bm.to_mesh(me)
bm.free()

cofre = bpy.data.objects.new('SM_Cofre_Pequeno', me)
escena.collection.objects.link(cofre)
cofre.data.materials.append(MAT_madera)   # slot 0
cofre.data.materials.append(MAT_hierro)   # slot 1
cofre.data.materials.append(MAT_bronce)   # slot 2

bpy.ops.object.select_all(action='DESELECT')
cofre.select_set(True)
bpy.context.view_layer.objects.active = cofre
bpy.ops.object.shade_flat()

# ---------- 9) Asentado (E-12) ----------
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Cofre')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:
        o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
print('COFRE asentado: z_min %.4f -> %.4f (delta %+.4f, piezas=%d)'
      % (z_min, z_fin, delta, len(piezas)))

bb = [cofre.matrix_world @ Vector(c) for c in cofre.bound_box]
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
bpy.ops.object.camera_add(location=(0.95, -0.95, 0.60))
cam = bpy.context.object
cam.name = 'CAM_Cofre'
blanco = Vector((0.0, 0.0, 0.24))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 40
escena.camera = cam

# ---------- 12) Guardar (E-21) ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '70-Interacciones',
                          'cofre_pequeno_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_obj = len([o for o in escena.objects if o.name.startswith('SM_')])
print('COFRE PEQUENO OK - objetos SM_: %d - tris: %d - materiales: %d'
      % (n_obj, n_tris, len(cofre.data.materials)))
