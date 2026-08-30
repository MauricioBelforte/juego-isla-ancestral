# crear_puerta_corrediza_piedra_lowpoly.py - Puerta corrediza de piedra (M70)
# v1 2026-08-29 23:20 (log 249)
#
# Diseno: riel inferior + 2 pilares + dintel + hoja de piedra CORREDIZA.
# La hoja esta deslizada hacia +X, dejando un hueco de 0.72 m del lado -X,
# asi se lee que es corrediza y no una pared ciega.
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
def crear_mat(nombre, color, rough=0.90, spec=0.18, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_piedra_cla = crear_mat('MAT_Piedra_Puerta_Cla', (0.58, 0.56, 0.52))
MAT_piedra_osc = crear_mat('MAT_Piedra_Puerta_Osc', (0.42, 0.41, 0.38))
MAT_hierro     = crear_mat('MAT_Hierro_Riel',      (0.40, 0.41, 0.43),
                           rough=0.40, spec=0.58, metal=0.85)
MAT_arena      = crear_mat('MAT_Arena_Isla',       (0.92, 0.84, 0.63), rough=1.00)

I_CLA, I_OSC, I_HIE = 0, 1, 2

# ---------- 3) Disco de arena (NO exportar) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.2, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base_disco = bpy.context.object
base_disco.name = 'Base_Arena'
base_disco.data.materials.append(MAT_arena)

# ---------- 4) Parametros ----------
Z_APOYO = 0.045

# Riel inferior: la guia por donde corre la hoja
RIEL_SX, RIEL_SY, RIEL_SZ = 1.55, 0.22, 0.045
RIEL_CZ = RIEL_SZ                       # 0.045 -> fondo en z=0

# Pilares: enmarcan el vano
PIL_SX, PIL_SY = 0.15, 0.24
PIL_CX = 1.32                           # centro; cara interna en 1.17
PIL_Z0, PIL_Z1 = 2 * RIEL_SZ, 1.95      # 0.09 .. 1.95
PIL_CZ = (PIL_Z0 + PIL_Z1) / 2.0
PIL_SZ = (PIL_Z1 - PIL_Z0) / 2.0

# Dintel
DIN_SX, DIN_SY = 1.62, 0.26
DIN_Z0, DIN_Z1 = PIL_Z1, 2.27
DIN_CZ = (DIN_Z0 + DIN_Z1) / 2.0
DIN_SZ = (DIN_Z1 - DIN_Z0) / 2.0

# Hoja corrediza: mas angosta que el vano -> queda un hueco visible
VANO_SX = PIL_CX - PIL_SX              # 1.17, cara interna del pilar
HOJA_ANCHO = 1.62                       # de los 2.34 m de vano
HOJA_SX = HOJA_ANCHO / 2.0
HOJA_CX = VANO_SX - HOJA_SX             # 0.36 -> hoja de -0.45 a +1.17
HOJA_SY = 0.11
HOJA_Z0, HOJA_Z1 = 2 * RIEL_SZ, 1.86
HOJA_CZ = (HOJA_Z0 + HOJA_Z1) / 2.0
HOJA_SZ = (HOJA_Z1 - HOJA_Z0) / 2.0

# Costillas de refuerzo en la cara de la hoja (2 listones verticales)
COS_SX, COS_SZ = 0.055, 0.62
COS_SY_OUT = 0.022                      # sobresalen del parametro de la hoja
COS_CZ = 0.95
COS_Y = HOJA_SY + COS_SY_OUT

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

# ---------- 6) Comprobaciones en caliente ----------
assert RIEL_CZ == RIEL_SZ, 'RIEL: el fondo debe estar en z=0'
assert abs(PIL_Z0 - 2 * RIEL_SZ) < TOL, 'PILAR: debe arrancar en el techo del riel'
assert abs(DIN_Z0 - PIL_Z1) < TOL, 'DINTEL: debe apoyar en el tope del pilar'
assert HOJA_ANCHO < 2 * VANO_SX - 0.30, \
    'HOJA: tapa casi todo el vano (ancho %.2f vs vano %.2f) -> no se lee corrediza' % \
    (HOJA_ANCHO, 2 * VANO_SX)
hueco = (HOJA_CX - HOJA_SX) - (-VANO_SX)
assert hueco > 0.40, 'HOJA: el hueco libre es de solo %.3f m' % hueco
assert abs((HOJA_CX + HOJA_SX) - VANO_SX) < TOL, \
    'HOJA: el canto derecho no coincide con la cara interna del pilar'
assert HOJA_Z1 < PIL_Z1, 'HOJA: choca con el dintel'
assert HOJA_Z0 >= 2 * RIEL_SZ - TOL, 'HOJA: arranca por debajo del riel'
assert COS_CZ + COS_SZ < HOJA_Z1, 'COSTILLA: se sale de la hoja por arriba'
assert COS_Y > HOJA_SY, 'COSTILLA: no sobresale de la cara de la hoja'
print('GEOMETRIA ok: vano %.2f m, hoja %.2f m deslizada a +X, hueco libre %.2f m, '
      'alto total %.2f m'
      % (2 * VANO_SX, HOJA_ANCHO, hueco, DIN_Z1))

# ---------- 7) Construir ----------
caja(0.0, 0.0, RIEL_CZ, RIEL_SX, RIEL_SY, RIEL_SZ, I_OSC)
for sx in (-1.0, +1.0):
    caja(sx * PIL_CX, 0.0, PIL_CZ, PIL_SX, PIL_SY, PIL_SZ, I_CLA)
caja(0.0, 0.0, DIN_CZ, DIN_SX, DIN_SY, DIN_SZ, I_CLA)
caja(HOJA_CX, 0.0, HOJA_CZ, HOJA_SX, HOJA_SY, HOJA_SZ, I_CLA)
for sx in (-0.42, +0.42):
    caja(HOJA_CX + sx, COS_Y, COS_CZ, COS_SX, COS_SY_OUT, COS_SZ, I_HIE)

# ---------- 8) Cerrar y crear el objeto ----------
bm.normal_update()
n_tris = sum(len(f.verts) - 2 for f in bm.faces)
me = bpy.data.meshes.new('SM_Puerta_Corrediza_Piedra')
bm.to_mesh(me)
bm.free()

puerta = bpy.data.objects.new('SM_Puerta_Corrediza_Piedra', me)
escena.collection.objects.link(puerta)
puerta.data.materials.append(MAT_piedra_cla)   # slot 0
puerta.data.materials.append(MAT_piedra_osc)   # slot 1
puerta.data.materials.append(MAT_hierro)       # slot 2

bpy.ops.object.select_all(action='DESELECT')
puerta.select_set(True)
bpy.context.view_layer.objects.active = puerta
bpy.ops.object.shade_flat()

# ---------- 9) Asentado (E-12) ----------
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Puerta')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:
        o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
print('PUERTA asentada: z_min %.4f -> %.4f (delta %+.4f, piezas=%d)'
      % (z_min, z_fin, delta, len(piezas)))

bb = [puerta.matrix_world @ Vector(c) for c in puerta.bound_box]
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
bpy.ops.object.camera_add(location=(2.6, -2.6, 1.5))
cam = bpy.context.object
cam.name = 'CAM_Puerta'
blanco = Vector((0.0, 0.0, 1.0))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 38
escena.camera = cam

# ---------- 12) Guardar (E-21) ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '70-Interacciones',
                          'puerta_corrediza_piedra_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_obj = len([o for o in escena.objects if o.name.startswith('SM_')])
print('PUERTA CORREDIZA OK - objetos SM_: %d - tris: %d - materiales: %d'
      % (n_obj, n_tris, len(puerta.data.materials)))
