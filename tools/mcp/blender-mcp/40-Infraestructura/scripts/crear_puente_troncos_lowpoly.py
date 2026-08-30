# crear_puente_troncos_lowpoly.py — Puente de troncos (M40-Infraestructura)
# Checklist: "Puente de troncos (arroyos)"
#
# Puente rustico para cruzar arroyos: dos estribos de piedra en las orillas,
# tres vigas longitudinales de tronco apoyadas sobre ellos, una cubierta de
# troncos transversales (tipo "corduroy"), barandilla de postes + pasamanos y
# ataduras de cuerda en los nudos.
#
# Todo en UNA sola malla bmesh y UN solo objeto (E-01): minima cantidad de
# draw calls y cero parenting, con lo que E-27 queda fuera de juego por
# construccion.
#
# El agua del arroyo NO forma parte del asset: la provee el modulo de terreno.
# El asset se disena para apoyarse en las dos orillas mediante los estribos.
#
# Lecciones aplicadas:
#   E-01  una sola malla y un solo objeto, no primitivas apiladas
#   E-12  asentado MEDIDO en caliente (no calculado de la altura nominal)
#   E-21  borrar el .blend@ antes de save_as_mainfile
#   E-23  DECIMATE 0.7 por defecto (0.5 destruye las mallas flat lowpoly)
#   E-28  las piezas del set de captura TAMBIEN se asientan (no flotan)
#   E-32  winding: no deducirlo a mano, MEDIRLO (v2 = volumen con signo)
#   E-33  el presupuesto se mide en triangulos reales, no en caras
#   E-34  no duplicar slots de material al decimar
#   E-35  NUNCA `Mesh.materials.clear()` como paso de "limpieza"
#
# ---------------------------------------------------------------------------
# E-32 v2 — el test de orientacion correcto es el VOLUMEN CON SIGNO
# ---------------------------------------------------------------------------
# V = (1/6) * sum_caras sum_k (v0 . (vk x vk+1)).  V > 0 -> normales afuera.
# Vale para CUALQUIER isla cerrada, convexa o no. Encapsulado en
# `cerrar_isla()`, que se llama una vez por isla.
#
# NUEVO en este asset: helper `toro()` para anillos cerrados (ataduras de
# cuerda alrededor del pasamanos). A diferencia de `tubo()`, NO lleva tapas
# porque la ultima corona se conecta con la primera.
#
# TOLERANCIA 1e-4 (no 1e-9): `mathutils.Vector` guarda float32, asi que el
# ruido sobre una coordenada de ~1 m es del orden de 2e-7. Con 1e-9 los
# asserts fallan SIEMPRE por puro error de redondeo.
# ---------------------------------------------------------------------------
import bpy
import bmesh
import os
import math
from mathutils import Vector, Euler

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

MAT_piedra = crear_mat('MAT_Piedra_Puente', (0.53, 0.52, 0.49), rough=0.95)
MAT_madera = crear_mat('MAT_Madera_Puente', (0.44, 0.31, 0.18), rough=0.88)
MAT_cuerda = crear_mat('MAT_Cuerda_Puente', (0.74, 0.61, 0.38), rough=0.96)
MAT_arena  = crear_mat('MAT_Arena_Isla',    (0.92, 0.84, 0.63), rough=1.00)

# slot 0 = piedra | 1 = madera | 2 = cuerda
I_PIEDRA, I_MADERA, I_CUERDA = 0, 1, 2

# ---------- 3) Disco de arena ----------
# El puente mide ~3.1 m de punta a punta (con las piedras del terraplen),
# asi que la base tiene que ser mas grande que la de los assets chicos.
bpy.ops.mesh.primitive_cylinder_add(vertices=28, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Parametros ----------
# --- vigas longitudinales (3 troncos a lo largo de X) ---
Y_VIGAS   = (-0.42, 0.00, 0.42)
R_VIGA    = 0.080
L_VIGA    = 2.72          # x de -1.36 a +1.36
Z_VIGA    = 0.300         # eje de la viga
LAD_VIGA  = 6

# --- cubierta: troncos transversales a lo largo de Y ---
N_CUB     = 11
X_CUB_0   = -1.15
DX_CUB    = 0.23          # -1.15 .. +1.15
R_CUB     = 0.075
L_CUB     = 1.16          # y de -0.58 a +0.58
Z_CUB     = 0.430
LAD_CUB   = 6

# --- estribos de piedra (apoyo en las dos orillas) ---
X_EST     = 1.24          # |x| del centro
SX_EST    = 0.11          # semieje x -> span 1.13 .. 1.35
SY_EST    = 0.51          # semieje y -> -0.51 .. +0.51
Z_EST_BOT = 0.045         # apoyado en la arena (E-12)
Z_EST_TOP = 0.225

# --- piedras del terraplen (decorativas, tambien apoyadas) ---
# (dx desde el centro del estribo hacia afuera, y, semieje x, semieje y, alto)
PIEDRAS = (
    (0.20, -0.38, 0.10, 0.14, 0.13),
    (0.24,  0.00, 0.12, 0.16, 0.17),
    (0.18,  0.40, 0.09, 0.12, 0.11),
)

# --- barandilla ---
Y_POSTE     = 0.615       # por fuera del extremo de los troncos (0.58)
R_POSTE     = 0.042
Z_POSTE_BOT = 0.045       # enterrado en la arena: nunca flota
Z_POSTE_TOP = 0.980
LAD_POSTE   = 6
X_POSTES    = (-1.00, 0.00, 1.00)

Z_RAIL      = 0.900
R_RAIL      = 0.050
L_RAIL      = 2.30        # x de -1.15 a +1.15
LAD_RAIL    = 6

# --- ataduras de cuerda (anillos cerrados sobre el pasamanos) ---
R_ATADURA   = 0.066       # radio mayor del toro
R_TUBO_AT   = 0.010       # espesor de la soga
SEG_AT      = 6           # segmentos del anillo grande
LAD_AT      = 4           # lados de la seccion de la soga
X_ATADURAS  = (-1.00, 1.00)   # solo en los postes exteriores

# ---------- 5) Helpers de geometria ----------
bm = bmesh.new()
TOL = 1e-4

def volumen_firmado(caras):
    """Volumen con signo de una isla CERRADA (teorema de la divergencia).

    > 0 -> las normales miran hacia afuera. < 0 -> esta dada vuelta.
    Vale para CUALQUIER isla cerrada, convexa o no (E-32 v2).
    """
    v = 0.0
    for f in caras:
        co = [vert.co for vert in f.verts]
        for k in range(1, len(co) - 1):
            v += co[0].dot(co[k].cross(co[k + 1]))
    return v / 6.0

def cerrar_isla(caras):
    """Unifica el winding de una isla y la deja mirando hacia afuera.

    Se llama UNA vez por isla. Cada tronco / caja / anillo es su propia isla.
    """
    bmesh.ops.recalc_face_normals(bm, faces=caras)
    if volumen_firmado(caras) < 0.0:
        bmesh.ops.reverse_faces(bm, faces=caras)
    return caras

def caja_vec(centro, ex, ey, ez, mat):
    """Caja con semiejes arbitrarios. `caja()` es el caso eje-alineado."""
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
    """Caja alineada a los ejes: (centro, semilados, material)."""
    return caja_vec(Vector((cx, cy, cz)),
                    Vector((sx, 0.0, 0.0)),
                    Vector((0.0, sy, 0.0)),
                    Vector((0.0, 0.0, sz)), mat)

def tubo(centros, radio, lados, mat, radios=None):
    """Barre un poligono de `lados` lados por la polilinea `centros`.

    El marco de cada anillo se arma con la tangente local, asi que sirve igual
    para una viga recta que para una soga curva. `radios` permite variar el
    radio por anillo (cono / tronco de cono). Lleva tapa en ambos extremos.
    """
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

def toro(centro, eje, R, r, seg, lados, mat):
    """Toro CERRADO alrededor de `eje`.

    `R` = radio mayor (distancia del centro del tubo al eje), `r` = espesor
    del tubo. A diferencia de `tubo()` NO lleva tapas: la ultima corona se
    conecta con la primera, asi que el anillo queda cerrado y sin caras
    coincidentes (que producirian z-fighting).

    La seccion del tubo vive en el plano generado por {ur, eje}, donde `ur` es
    el radial unitario del anillo grande. Ese plano es perpendicular a la
    tangente de la linea media porque ur . ut = 0 y eje . ut = 0.
    """
    eje = eje.normalized()
    ref = Vector((0.0, 0.0, 1.0)) if abs(eje.z) < 0.9 else Vector((1.0, 0.0, 0.0))
    e1 = eje.cross(ref).normalized()
    e2 = eje.cross(e1).normalized()
    coronas = []
    for j in range(seg):
        a = 2.0 * math.pi * j / seg
        ur = math.cos(a) * e1 + math.sin(a) * e2      # radial unitario
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

# ---------- 6) Comprobaciones geometricas en caliente ----------
# El verso de este asset es "nada flota". Antes de generar un solo vertice,
# verifico las tres relaciones de las que depende el apoyo:
#
#  (a) el vientre de la viga debe QUEDAR POR DEBAJO del lomo del estribo, para
#      que el tronco se hunda unos milimetros en la piedra en vez de apoyarse
#      en el aire;
#  (b) el estribo debe quedar DEBAJO del extremo de la viga, no mas alla;
#  (c) el anillo de cuerda debe pasar holgado alrededor del pasamanos.
vientre_viga = Z_VIGA - R_VIGA                 # 0.220
assert vientre_viga < Z_EST_TOP + TOL, (
    'APOYO: el vientre de la viga (%.4f) no llega al lomo del estribo (%.4f) '
    '-> la viga FLOTARIA' % (vientre_viga, Z_EST_TOP))
hundimiento = Z_EST_TOP - vientre_viga
assert hundimiento < 0.020, (
    'APOYO: la viga se hunde %.4f m en el estribo; mas de 2 cm ya no lee como '
    'apoyada sino como incrustada' % hundimiento)

viga_fin = L_VIGA / 2.0                        # 1.36
est_interior = X_EST - SX_EST                  # 1.13
est_exterior = X_EST + SX_EST                  # 1.35
assert est_interior < viga_fin, (
    'APOYO: la cara interior del estribo (%.4f) queda mas alla del extremo de '
    'la viga (%.4f) -> la viga no llega al estribo' % (est_interior, viga_fin))
assert est_exterior <= viga_fin + TOL, (
    'APOYO: la cara exterior del estribo (%.4f) sobresale del extremo de la '
    'viga (%.4f) -> se veria piedra sin nada encima' % (est_exterior, viga_fin))

assert R_ATADURA - R_TUBO_AT > R_RAIL, (
    'ATADURA: el anillo (interno %.4f) no pasa alrededor del pasamanos '
    '(%.4f)' % (R_ATADURA - R_TUBO_AT, R_RAIL))
assert abs(Y_POSTE) - R_POSTE < L_CUB / 2.0, (
    'BARANDILLA: el poste (cara interna %.4f) no toca el extremo de los '
    'troncos de la cubierta (%.4f)' % (abs(Y_POSTE) - R_POSTE, L_CUB / 2.0))

print('GEOMETRIA ok: hundimiento viga-estribo %.4f m, estribo [%.3f..%.3f] '
      'bajo el extremo de viga %.3f, luz de atadura %.4f m'
      % (hundimiento, est_interior, est_exterior, viga_fin,
         R_ATADURA - R_TUBO_AT - R_RAIL))

# ---------- 7) Estribos de piedra (2) ----------
# Bloque nucleo: es la unica pieza PORTANTE, asi que su lomo va a una cota
# exacta (Z_EST_TOP) en lugar de variarla con ruido. El relieve rustico lo
# aportan las piedras del terraplen, que no soportan nada.
for sx in (-1, +1):
    caja(sx * X_EST, 0.0, (Z_EST_BOT + Z_EST_TOP) / 2.0,
         SX_EST, SY_EST, (Z_EST_TOP - Z_EST_BOT) / 2.0, I_PIEDRA)
    # piedras del terraplen: apoyadas en la arena, detras del nucleo
    for (dx, py, spx, spy, alto) in PIEDRAS:
        caja(sx * (X_EST + dx), py, Z_EST_BOT + alto / 2.0,
             spx, spy, alto / 2.0, I_PIEDRA)

# ---------- 8) Vigas longitudinales (3) ----------
for yv in Y_VIGAS:
    tubo([(-L_VIGA / 2.0, yv, Z_VIGA), (L_VIGA / 2.0, yv, Z_VIGA)],
         R_VIGA, LAD_VIGA, I_MADERA)

# ---------- 9) Cubierta: troncos transversales ----------
# Ligeramente desparejos en radio y en altura para que no parezca una rejilla
# de CAD. La variacion es determinista (sin/cos del indice), no aleatoria.
for i in range(N_CUB):
    xc = X_CUB_0 + i * DX_CUB
    r_i = R_CUB + 0.006 * math.sin(i * 2.3)
    z_i = Z_CUB + 0.005 * math.cos(i * 1.7)
    tubo([(xc, -L_CUB / 2.0, z_i), (xc, L_CUB / 2.0, z_i)],
         r_i, LAD_CUB, I_MADERA)

# ---------- 10) Barandilla: postes + pasamanos ----------
# Los postes ARRANCAN DEL SUELO (Z_POSTE_BOT = Z_APOYO) y no de la cubierta.
# Es la forma mas robusta de garantizar que no floten: su apoyo es la arena,
# no una interseccion calculada con los troncos. Ademas es como se construye
# un puente de troncos de verdad: los postes se hincan en la orilla.
for sx in X_POSTES:
    for sy in (-1, +1):
        tubo([(sx, sy * Y_POSTE, Z_POSTE_BOT), (sx, sy * Y_POSTE, Z_POSTE_TOP)],
             R_POSTE, LAD_POSTE, I_MADERA)

for sy in (-1, +1):
    tubo([(-L_RAIL / 2.0, sy * Y_POSTE, Z_RAIL),
          ( L_RAIL / 2.0, sy * Y_POSTE, Z_RAIL)],
         R_RAIL, LAD_RAIL, I_MADERA)

# ---------- 11) Ataduras de cuerda ----------
# Anillo en el plano YZ (eje X = la direccion del pasamanos), centrado en el
# eje del pasamanos a la altura del poste.
for sx in X_ATADURAS:
    for sy in (-1, +1):
        toro(Vector((sx, sy * Y_POSTE, Z_RAIL)), Vector((1.0, 0.0, 0.0)),
             R_ATADURA, R_TUBO_AT, SEG_AT, LAD_AT, I_CUERDA)

# ---------- 12) Cerrar y crear el objeto ----------
bm.normal_update()
n_tris = sum(len(f.verts) - 2 for f in bm.faces)
me = bpy.data.meshes.new('SM_Puente_Troncos')
bm.to_mesh(me)
bm.free()

puente = bpy.data.objects.new('SM_Puente_Troncos', me)
escena.collection.objects.link(puente)
# E-34/E-35: los slots se asignan UNA sola vez y en el orden correcto.
# Nunca `Mesh.materials.clear()`: resetea a 0 el material_index de todas las
# caras y la malla termina renderizandose con un solo material.
puente.data.materials.append(MAT_piedra)   # slot 0
puente.data.materials.append(MAT_madera)   # slot 1
puente.data.materials.append(MAT_cuerda)   # slot 2

bpy.ops.object.select_all(action='DESELECT')
puente.select_set(True)
bpy.context.view_layer.objects.active = puente
bpy.ops.object.shade_flat()

# ---------- 13) Asentado (E-12) — medido en caliente ----------
# Lo mas bajo son los postes y las piedras, que ya nacen en Z_APOYO. Se mide
# igual y se corrige, nunca se confia en la altura nominal.
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Puente')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:      # solo la raiz; los hijos la siguen solos
        o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
print('PUENTE asentado: z_min %.4f -> %.4f (delta %+.4f, piezas=%d)'
      % (z_min, z_fin, delta, len(piezas)))

# ---------- 14) Iluminacion + mundo (set IDENTICO al resto de los assets) ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.4
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(8), math.radians(35)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 15) Camara ----------
# Solo para el preview del .blend: `capturar_angulos.py` crea su propia camara
# orbital y recalcula la distancia a partir del bounding box del objeto.
bpy.ops.object.camera_add(location=(2.70, -2.70, 1.40))
cam = bpy.context.object
cam.name = 'CAM_Puente'
blanco = Vector((0.0, 0.0, 0.55))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 16) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '40-Infraestructura',
                          'puente_troncos_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
# E-21: si quedo un .blend@ de un crash, save_as_mainfile falla.
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_obj = len([o for o in escena.objects if o.name.startswith('SM_')])
print('PUENTE TRONCOS OK — objetos SM_: %d — tris: %d — materiales: %d — blend: %s'
      % (n_obj, n_tris, len(puente.data.materials), ruta_blend))
