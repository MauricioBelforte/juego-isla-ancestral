# crear_valvula_manivela_lowpoly.py - Valvula con volante (M70-Interacciones)
# v1 2026-08-29 23:40 (log 249)
#
# Diseno: brida octagonal de asiento + cuerpo cilindrico + cuello + cubo +
# VOLANTE de barco (toro horizontal + 5 radios). El volante es horizontal
# (eje Z), como una valvula real: se gira desde arriba.
#
# Reusa el helper toro() del puente de troncos (log 247): anillo CERRADO sin
# tapas coincidentes, a diferencia de tubo().
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
def crear_mat(nombre, color, rough=0.40, spec=0.55, metal=0.85, emis=0.0):
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

MAT_hierro_osc = crear_mat('MAT_Hierro_Valvula', (0.33, 0.34, 0.37))
MAT_hierro_cla = crear_mat('MAT_Acero_Cubo',     (0.52, 0.53, 0.56), rough=0.30)
MAT_bronce     = crear_mat('MAT_Bronce_Volante', (0.74, 0.54, 0.28),
                           rough=0.30, spec=0.65, metal=0.92, emis=0.35)
MAT_arena      = crear_mat('MAT_Arena_Isla',     (0.92, 0.84, 0.63),
                           rough=1.00, spec=0.10, metal=0.0)

I_HOSC, I_HCLA, I_BRO = 0, 1, 2

# ---------- 3) Disco de arena (NO exportar) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.2, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base_disco = bpy.context.object
base_disco.name = 'Base_Arena'
base_disco.data.materials.append(MAT_arena)

# ---------- 4) Parametros ----------
Z_APOYO = 0.045

# Brida de asiento: octagono apenas conico
BRI_Z0, BRI_Z1 = 0.00, 0.08
BRI_R0, BRI_R1 = 0.30, 0.28
BRI_LAD = 8

# Cuerpo: cilindro vertical
CUE_Z0, CUE_Z1 = BRI_Z1, 0.42
CUE_R = 0.15
CUE_LAD = 8

# Cuello: mas fino, sube hasta el cubo
CUE2_Z0, CUE2_Z1 = CUE_Z1, 0.58
CUE2_R = 0.075
CUE2_LAD = 8

# Cubo: atraviesa el plano del volante y lo sostiene
HUB_Z0, HUB_Z1 = CUE2_Z1, 0.68
HUB_R = 0.055
HUB_LAD = 8

# Volante: toro horizontal (eje Z) + radios
VOL_Z   = 0.62                 # plano del volante
VOL_R   = 0.21                 # radio mayor del toro
VOL_TUB = 0.022                # radio del tubo del toro
VOL_SEG = 8
VOL_LAD = 4
N_RADIOS = 5
RAD_SX = (VOL_R - HUB_R) / 2.0 + 0.012   # semilargo del radio
RAD_SY = 0.014
RAD_SZ = 0.018

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
        caras.append(bm.faces.new(list(reversed(a0))))
    if r1 > 1e-6:
        caras.append(bm.faces.new(a1))
    for k in range(lados):
        k2 = (k + 1) % lados
        caras.append(bm.faces.new((a0[k], a0[k2], a1[k2], a1[k])))
    for f in caras:
        f.material_index = mat
    return cerrar_isla(caras)

def toro(centro, eje, R, r, seg, lados, mat):
    """Anillo CERRADO sin tapas coincidentes (log 247)."""
    eje = eje.normalized()
    ref = Vector((0.0, 0.0, 1.0)) if abs(eje.z) < 0.9 else Vector((1.0, 0.0, 0.0))
    e1 = eje.cross(ref).normalized()
    e2 = eje.cross(e1).normalized()
    coronas = []
    for j in range(seg):
        a = 2.0 * math.pi * j / seg
        ur = math.cos(a) * e1 + math.sin(a) * e2
        c = centro + R * ur
        corona = []
        for k in range(lados):
            b = 2.0 * math.pi * k / lados
            corona.append(bm.verts.new(c + r * (math.cos(b) * ur +
                                                math.sin(b) * eje)))
        coronas.append(corona)
    caras = []
    for j in range(seg):
        a0, a1 = coronas[j], coronas[(j + 1) % seg]
        for k in range(lados):
            k2 = (k + 1) % lados
            caras.append(bm.faces.new((a0[k], a0[k2], a1[k2], a1[k])))
    for f in caras:
        f.material_index = mat
    return cerrar_isla(caras)

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

# ---------- 6) Comprobaciones en caliente ----------
assert BRI_Z0 == 0.0, 'BRIDA: el fondo debe estar en z=0'
assert CUE_Z0 == BRI_Z1, 'CUERPO: debe arrancar en el techo de la brida'
assert CUE2_Z0 == CUE_Z1, 'CUELLO: debe arrancar en el tope del cuerpo'
assert HUB_Z0 == CUE2_Z1, 'CUBO: debe arrancar en el tope del cuello'
assert VOL_Z - VOL_TUB > CUE2_Z1, 'VOLANTE: choca con el cuello'
assert VOL_Z + VOL_TUB < HUB_Z1, 'VOLANTE: se sale por arriba del cubo'
assert HUB_Z1 > VOL_Z, 'CUBO: no atraviesa el plano del volante'
assert VOL_R - VOL_TUB > HUB_R, 'VOLANTE: el toro se come al cubo'
assert RAD_SX * 2 > (VOL_R - HUB_R), 'RADIO: no llega del cubo al aro'
assert VOL_R > CUE_R + 0.02, 'VOLANTE: es mas chico que el cuerpo'
print('GEOMETRIA ok: brida r %.2f, cuerpo r %.2f z[%.2f..%.2f], volante R %.2f '
      'tubo %.3f en z %.2f, %d radios de %.3f m, alto total %.2f'
      % (BRI_R0, CUE_R, CUE_Z0, CUE_Z1, VOL_R, VOL_TUB, VOL_Z,
         N_RADIOS, 2 * RAD_SX, HUB_Z1))

# ---------- 7) Construir ----------
cono_revolucion(BRI_Z0, BRI_Z1, BRI_R0, BRI_R1, BRI_LAD, I_HOSC)
cono_revolucion(CUE_Z0, CUE_Z1, CUE_R, CUE_R, CUE_LAD, I_HOSC)
cono_revolucion(CUE2_Z0, CUE2_Z1, CUE2_R, CUE2_R, CUE2_LAD, I_HCLA)
cono_revolucion(HUB_Z0, HUB_Z1, HUB_R, HUB_R, HUB_LAD, I_HCLA)
toro(Vector((0.0, 0.0, VOL_Z)), Vector((0.0, 0.0, 1.0)),
     VOL_R, VOL_TUB, VOL_SEG, VOL_LAD, I_BRO)

for k in range(N_RADIOS):
    a = 2.0 * math.pi * k / N_RADIOS
    ur = Vector((math.cos(a), math.sin(a), 0.0))
    ut = Vector((-math.sin(a), math.cos(a), 0.0))
    centro = Vector((0.0, 0.0, VOL_Z)) + ur * (HUB_R + VOL_R) / 2.0
    caja_vec(centro, ur * RAD_SX, ut * RAD_SY, Vector((0.0, 0.0, RAD_SZ)), I_BRO)

# ---------- 8) Cerrar y crear el objeto ----------
bm.normal_update()
n_tris = sum(len(f.verts) - 2 for f in bm.faces)
me = bpy.data.meshes.new('SM_Valvula_Manivela')
bm.to_mesh(me)
bm.free()

valv = bpy.data.objects.new('SM_Valvula_Manivela', me)
escena.collection.objects.link(valv)
valv.data.materials.append(MAT_hierro_osc)   # slot 0
valv.data.materials.append(MAT_hierro_cla)   # slot 1
valv.data.materials.append(MAT_bronce)       # slot 2

bpy.ops.object.select_all(action='DESELECT')
valv.select_set(True)
bpy.context.view_layer.objects.active = valv
bpy.ops.object.shade_flat()

# ---------- 9) Asentado (E-12) ----------
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Valvula')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:
        o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
print('VALVULA asentada: z_min %.4f -> %.4f (delta %+.4f, piezas=%d)'
      % (z_min, z_fin, delta, len(piezas)))

bb = [valv.matrix_world @ Vector(c) for c in valv.bound_box]
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
cam.name = 'CAM_Valvula'
blanco = Vector((0.0, 0.0, 0.34))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 12) Guardar (E-21) ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '70-Interacciones',
                          'valvula_manivela_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_obj = len([o for o in escena.objects if o.name.startswith('SM_')])
print('VALVULA MANIVELA OK - objetos SM_: %d - tris: %d - materiales: %d'
      % (n_obj, n_tris, len(valv.data.materials)))
