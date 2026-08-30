# crear_palanca_madera_lowpoly.py - Palanca de madera (M70-Interacciones)
# v3 2026-08-29: diseno de HORQUILLA (dos montantes + perno transversal).
#
# HISTORIAL DE BUGS
#   v1: el brazo cilindrico se creaba en el mismo (0,0,0.21) que el cono del
#       pivote -> el brazo ATRAVESABA el pivote. Parecia "un palo clavado en
#       una caja con una pelota en la punta". El "fix" del log 233 solo giro
#       el .blend a mano de 35 a 81.1 grados; nunca arreglo el problema.
#   v2: brazo apoyado SOBRE un poste unico. Geometricamente correcto pero
#       todavia ambiguo: un poste con una barra encima no se lee como palanca.
#   v3: HORQUILLA. Dos montantes verticales, el brazo ENTRA entre ellos y un
#       perno de hierro lo atraviesa de lado a lado. Es la forma clasica de
#       una palanca de pozo / bomba y se reconoce de inmediato.
#
# Todo en UNA sola malla bmesh y UN solo objeto (E-01): E-27 queda fuera de
# juego por construccion, y el brazo nunca puede despegarse de la horquilla
# porque son caras del mismo mesh.
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
def crear_mat(nombre, color, rough=0.85, spec=0.20, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_madera_osc = crear_mat('MAT_Madera_Pal_Osc', (0.30, 0.19, 0.12), rough=0.90)
MAT_madera_cla = crear_mat('MAT_Madera_Pal_Cla', (0.55, 0.38, 0.22), rough=0.82)
MAT_hierro     = crear_mat('MAT_Hierro_Perno',   (0.38, 0.39, 0.42), rough=0.38, spec=0.60, metal=0.90)
MAT_arena      = crear_mat('MAT_Arena_Isla',     (0.92, 0.84, 0.63), rough=1.00)

# slot 0 = madera oscura | 1 = madera clara | 2 = hierro
I_OSC, I_CLA, I_HIE = 0, 1, 2

# ---------- 3) Disco de arena (NO exportar) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.2, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base_disco = bpy.context.object
base_disco.name = 'Base_Arena'
base_disco.data.materials.append(MAT_arena)

# ---------- 4) Parametros ----------
Z_APOYO = 0.045

# Base: bloque de madera apoyado en la arena. Fondo en z=0 para que el
# asentado E-12 (z_min = 0.045) lo entierre 4.5 cm en la arena.
BASE_SX, BASE_SY, BASE_SZ = 0.24, 0.17, 0.07
BASE_CZ = BASE_SZ                       # fondo z=0, techo z=0.14
BASE_TOP = 2.0 * BASE_SZ                # 0.14

# Brazo: caja larga e INCLINADA. Su eje pasa por el fulcro.
ANG_TILT = math.radians(10.0)           # posicion "off": lado del pomo arriba
BRAZ_SEMILARGO = 0.55                   # brazo total = 1.10 m
BRAZ_SEMIANCHO = 0.055                  # ancho total = 0.11 m
BRAZ_SEMIALTO  = 0.07                   # alto total = 0.14 m
Z_FULCRO = 0.36                         # altura del eje de giro
CAIDA_VERT = BRAZ_SEMIALTO * math.cos(ANG_TILT)   # 0.0689 (no 0.07: esta inclinado)
SUBE_VERT  = BRAZ_SEMIALTO * math.cos(ANG_TILT)
BRAZ_CX, BRAZ_CY, BRAZ_CZ = 0.0, 0.0, Z_FULCRO

# Montantes de la horquilla: dos tablas verticales, una a cada lado del brazo.
HOLGURA = 0.012                          # luz entre brazo y montante
MON_SX = 0.050                           # largo (en X) del montante
MON_SY = 0.028                           # espesor (en Y)
MON_Y  = BRAZ_SEMIANCHO + HOLGURA + MON_SY        # 0.095
MON_Z_BOT = BASE_TOP                     # 0.14
MON_Z_TOP = 0.40                         # apenas por encima del lomo del brazo
MON_CZ = (MON_Z_BOT + MON_Z_TOP) / 2.0   # 0.27
MON_SZ = (MON_Z_TOP - MON_Z_BOT) / 2.0   # 0.13

# Perno: cilindro horizontal en Y que atraviesa montante-brazo-montante.
PER_R    = 0.020
PER_SEMI = MON_Y + MON_SY + 0.020        # 0.143 (sobresale 2 cm de cada cara)
PER_LAD  = 8
PER_Z    = Z_FULCRO                      # 0.36

# Pomo: icosfera en la punta del lado largo.
POMO_R   = 0.115
POMO_SUB = 1
POMO_X   = BRAZ_CX + BRAZ_SEMILARGO * math.cos(ANG_TILT)   # 0.5416
POMO_Y   = BRAZ_CY
POMO_Z   = BRAZ_CZ + BRAZ_SEMILARGO * math.sin(ANG_TILT)   # 0.4555

# ---------- 5) Helpers de geometria ----------
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

def caja_vec(centro, ex, ey, ez, mat):
    """Caja con semiejes arbitrarios (sirve para el brazo inclinado)."""
    v = []
    for sz in (-1, 1):
        for sy in (-1, 1):
            for sx in (-1, 1):
                v.append(bm.verts.new(centro + sx * ex + sy * ey + sz * ez))
    caras = [
        bm.faces.new((v[0], v[1], v[3], v[2])),   # -ez
        bm.faces.new((v[4], v[6], v[7], v[5])),   # +ez
        bm.faces.new((v[0], v[4], v[5], v[1])),   # -ey
        bm.faces.new((v[2], v[3], v[7], v[6])),   # +ey
        bm.faces.new((v[0], v[2], v[6], v[4])),   # -ex
        bm.faces.new((v[1], v[5], v[7], v[3])),   # +ex
    ]
    for f in caras:
        f.material_index = mat
    return cerrar_isla(caras)

def caja(cx, cy, cz, sx, sy, sz, mat):
    return caja_vec(Vector((cx, cy, cz)),
                    Vector((sx, 0.0, 0.0)),
                    Vector((0.0, sy, 0.0)),
                    Vector((0.0, 0.0, sz)), mat)

def tubo(centros, radio, lados, mat, radios=None):
    if radios is None:
        radios = [radio] * len(centros)
    anillos = []
    n = len(centros)
    for i in range(n):
        c = Vector(centros[i])
        if n < 2:
            t = Vector((1.0, 0.0, 0.0))
        elif i == 0:
            t = Vector(centros[1]) - c
        elif i == n - 1:
            t = c - Vector(centros[n - 2])
        else:
            t = Vector(centros[i + 1]) - Vector(centros[i - 1])
        if t.length < 1e-9:
            t = Vector((1.0, 0.0, 0.0))
        t.normalize()
        ref = Vector((0.0, 0.0, 1.0)) if abs(t.z) < 0.9 else Vector((1.0, 0.0, 0.0))
        e1 = t.cross(ref).normalized()
        e2 = t.cross(e1).normalized()
        anillo = []
        for k in range(lados):
            a = 2.0 * math.pi * k / lados
            anillo.append(bm.verts.new(c + radios[i] * (math.cos(a) * e1 +
                                                        math.sin(a) * e2)))
        anillos.append(anillo)
    caras = [bm.faces.new(anillos[0]),
             bm.faces.new(list(reversed(anillos[-1])))]
    for i in range(n - 1):
        a0, a1 = anillos[i], anillos[i + 1]
        for k in range(lados):
            k2 = (k + 1) % lados
            caras.append(bm.faces.new((a0[k], a0[k2], a1[k2], a1[k])))
    for f in caras:
        f.material_index = mat
    return cerrar_isla(caras)

# ---------- 6) Comprobaciones geometricas en caliente ----------
# (a) la base apoya en la arena
assert abs(BASE_CZ - BASE_SZ) < TOL, 'BASE: el fondo no esta en z=0'

# (b) los montantes arrancan en el techo de la base
assert abs(MON_Z_BOT - BASE_TOP) < TOL, \
    'MONTANTE: arranca en %.3f pero el techo de la base esta en %.3f' % (MON_Z_BOT, BASE_TOP)

# (c) HOLGURA real entre el brazo y la cara interna del montante
cara_int_mon = MON_Y - MON_SY                     # 0.067
assert cara_int_mon > BRAZ_SEMIANCHO + 1e-3, \
    'MONTANTE: la cara interna (%.4f) roza el brazo (%.4f)' % (cara_int_mon, BRAZ_SEMIANCHO)
holgura_real = cara_int_mon - BRAZ_SEMIANCHO

# (d) el perno esta dentro del alto del montante (no asoma por arriba)
assert PER_Z + PER_R < MON_Z_TOP + TOL, \
    'PERNO: asoma por encima del montante (%.4f vs %.4f)' % (PER_Z + PER_R, MON_Z_TOP)
assert PER_Z - PER_R > MON_Z_BOT, 'PERNO: queda por debajo del arranque del montante'

# (e) el perno sobresale de las caras externas de los montantes
cara_ext_mon = MON_Y + MON_SY                     # 0.123
assert PER_SEMI > cara_ext_mon, \
    'PERNO: no sobresale de la cara externa (%.4f vs %.4f)' % (PER_SEMI, cara_ext_mon)

# (f) el perno queda DENTRO del brazo (lo atraviesa, no flota al lado)
assert PER_Z + PER_R < BRAZ_CZ + SUBE_VERT + TOL, 'PERNO: asoma por el lomo del brazo'
assert PER_Z - PER_R > BRAZ_CZ - CAIDA_VERT - TOL, 'PERNO: asoma por el vientre del brazo'

# (g) el brazo cabe dentro de la horquilla: su lomo no tapa los montantes
lomo_brazo = BRAZ_CZ + SUBE_VERT                 # 0.4289
assert lomo_brazo > MON_Z_TOP, \
    'BRAZO: queda enteramente tapado por los montantes (lomo %.4f vs tope %.4f)' % \
    (lomo_brazo, MON_Z_TOP)

# (h) el lado corto NO toca la base: tiene que quedar aire para poder bajarlo
extremo_corto_z = BRAZ_CZ - BRAZ_SEMILARGO * math.sin(ANG_TILT)
fondo_corto = extremo_corto_z - CAIDA_VERT
assert fondo_corto > BASE_TOP + 0.03, \
    'BRAZO: el lado corto casi toca la base (fondo %.4f, techo base %.4f)' % \
    (fondo_corto, BASE_TOP)

# (i) el pomo esta en la punta del lado largo
assert abs((POMO_X - BRAZ_CX) - BRAZ_SEMILARGO * math.cos(ANG_TILT)) < TOL, 'POMO: X mal'
assert abs((POMO_Z - BRAZ_CZ) - BRAZ_SEMILARGO * math.sin(ANG_TILT)) < TOL, 'POMO: Z mal'
# (j) el pomo NO toca los montantes. CUIDADO (bug propio v3.0): comparar solo
#     Z da falso positivo - el pomo esta a ~0.49 m en X de la horquilla, asi
#     que hay que medir la distancia real punto-esfera/caja, no un eje suelto.
def dist_punto_caja(p, cx, cy, cz, hx, hy, hz):
    dx = max(abs(p.x - cx) - hx, 0.0)
    dy = max(abs(p.y - cy) - hy, 0.0)
    dz = max(abs(p.z - cz) - hz, 0.0)
    return math.sqrt(dx * dx + dy * dy + dz * dz)

pomo_c = Vector((POMO_X, POMO_Y, POMO_Z))
d_mon = dist_punto_caja(pomo_c, 0.0, MON_Y, MON_CZ, MON_SX, MON_SY, MON_SZ)
assert d_mon > POMO_R + 0.02, \
    'POMO: toca el montante (dist %.4f vs radio %.4f)' % (d_mon, POMO_R)
d_base = dist_punto_caja(pomo_c, 0.0, 0.0, BASE_CZ, BASE_SX, BASE_SY, BASE_SZ)
assert d_base > POMO_R + 0.02, \
    'POMO: toca la base (dist %.4f vs radio %.4f)' % (d_base, POMO_R)

print('GEOMETRIA ok: horquilla y=+/-%.3f, holgura brazo %.4f m, perno z %.3f, '
      'lado corto a z %.3f (techo base %.3f)'
      % (MON_Y, holgura_real, PER_Z, fondo_corto, BASE_TOP))

# ---------- 7) Construir (orden: base -> montantes -> brazo -> pomo -> perno) ----------
caja(0.0, 0.0, BASE_CZ, BASE_SX, BASE_SY, BASE_SZ, I_OSC)

for sy in (-1.0, +1.0):
    caja(0.0, sy * MON_Y, MON_CZ, MON_SX, MON_SY, MON_SZ, I_OSC)

ex = Vector((math.cos(ANG_TILT), 0.0, math.sin(ANG_TILT))) * BRAZ_SEMILARGO
ey = Vector((0.0, 1.0, 0.0)) * BRAZ_SEMIANCHO
ez = Vector((-math.sin(ANG_TILT), 0.0, math.cos(ANG_TILT))) * BRAZ_SEMIALTO
assert abs(ex.dot(ey)) < TOL, 'BRAZO: ex y ey no son perpendiculares'
assert abs(ex.dot(ez)) < TOL, 'BRAZO: ex y ez no son perpendiculares'
assert abs(ey.dot(ez)) < TOL, 'BRAZO: ey y ez no son perpendiculares'
caja_vec(Vector((BRAZ_CX, BRAZ_CY, BRAZ_CZ)), ex, ey, ez, I_CLA)

n_faces_antes = len(bm.faces)
bmesh.ops.create_icosphere(bm, subdivisions=POMO_SUB, radius=POMO_R,
                            matrix=Matrix.Translation(Vector((POMO_X, POMO_Y, POMO_Z))),
                            calc_uvs=False)
nuevas_caras = list(bm.faces)[n_faces_antes:]
for f in nuevas_caras:
    f.material_index = I_CLA
cerrar_isla(nuevas_caras)
print('POMO: %d caras (subdivisions=%d)' % (len(nuevas_caras), POMO_SUB))

tubo([(0.0, -PER_SEMI, PER_Z), (0.0, +PER_SEMI, PER_Z)], PER_R, PER_LAD, I_HIE)

# ---------- 8) Cerrar y crear el objeto ----------
bm.normal_update()
n_tris = sum(len(f.verts) - 2 for f in bm.faces)
me = bpy.data.meshes.new('SM_Palanca_Madera')
bm.to_mesh(me)
bm.free()

palanca = bpy.data.objects.new('SM_Palanca_Madera', me)
escena.collection.objects.link(palanca)
palanca.data.materials.append(MAT_madera_osc)   # slot 0
palanca.data.materials.append(MAT_madera_cla)   # slot 1
palanca.data.materials.append(MAT_hierro)       # slot 2

bpy.ops.object.select_all(action='DESELECT')
palanca.select_set(True)
bpy.context.view_layer.objects.active = palanca
bpy.ops.object.shade_flat()

# ---------- 9) Asentado (E-12) - medido en caliente ----------
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Palanca')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:
        o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
print('PALANCA asentada: z_min %.4f -> %.4f (delta %+.4f, piezas=%d)'
      % (z_min, z_fin, delta, len(piezas)))

bb = [palanca.matrix_world @ Vector(c) for c in palanca.bound_box]
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
bpy.ops.object.camera_add(location=(1.35, -1.35, 0.85))
cam = bpy.context.object
cam.name = 'CAM_Palanca'
blanco = Vector((0.0, 0.0, 0.30))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 40
escena.camera = cam

# ---------- 12) Guardar .blend (E-21: borrar el @ antes de guardar) ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '70-Interacciones',
                          'palanca_madera_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_obj = len([o for o in escena.objects if o.name.startswith('SM_')])
print('PALANCA MADERA OK - objetos SM_: %d - tris: %d - materiales: %d'
      % (n_obj, n_tris, len(palanca.data.materials)))
