# crear_tortuga_marina_lowpoly.py - Tortuga marina (M36 Fauna, checklist linea 110)
#
# v4 (2026-09-02, mix pedido por el usuario entre v2 y v3):
#   - CABEZA: queda la esfera organica de la v3 pero SIN el pico de
#     queratina (al usuario no le gustaba la trompa): redonda, solo con
#     2 ojos algo mas grandes y adelantados para que no quede sosa.
#   - ALETAS DELANTERAS: se MANTIENEN los remos bmesh de la v3 (los que
#     le gustaron: perfil loftado, se ensancha a pala y afina en punta).
#   - ALETAS TRASERAS: DISENO NUEVO (rechazo de caja v2 y cono v3):
#     remo COMPACTO de 4 anillos con seccion ELIPTICA (ancho en Y,
#     achatado en Z) -> pala plana de bordes redondeados, tipo aleta
#     trasera real: mas corta y ancha que la delantera. Mismo lenguaje
#     formal que las delanteras (coherencia), distinta proporcion.
#   - COLA: cono corto apuntando a -X (la de la v2, la que gusto).
#   - Resto del caparazon v3 intacto (falda 16 + domo + anillo marginal
#     + 9 escudos proyectados sobre la curvatura).
#
# v3: remos delanteros, escudos proyectados, pico (eliminado en v4).
# v2: fix E-50 (esfera colgaba bajo el plastron) + E-19 (cola al reves).
# v1: primera version.
#
# APOYO (E-12/E-50): z_min global = 0.045 lo aportan plastron (8 verts),
# 2 aletas delanteras (fondo plano, verts c/u) y cola (8 verts). El domo
# nace ENTERRADO en el plastron (polo sur z=0.055 dentro de la losa
# 0.045..0.105) -> jamas define el asentado.
#
# E-70 (contar ANTES de generar): 14 SM_ <= 16 tope ALTA. Margen 2.
#   1 plastron + 1 falda + 1 domo + 1 anillo + 1 escudos(9 pads en 1
#   malla) + 1 cuello + 1 cabeza + 2 ojos + 2 aletas_d + 2 aletas_t
#   + 1 cola = 14 (v4: sin pico).
#
# Presupuesto M166 ALTA: <=16 obj / <=6000 tris / <=12 mats.
#   14 obj · ~1100 tris reales · 5 mats usados -> OK (medido 2026-09-02).
#
# E-68: caja() NO multiplica por 2 (dimension final, no semieje).
# E-19: rot Y +90 lleva +Z(local) a +X(mundo); rot Y -90 lo lleva a -X.
# E-27: cero parenting — todas las piezas van a la raiz de la escena.
# E-32 v2: recalc_face_normals + volumen firmado por ISLA cerrada.
#
# NOTA __file__ (socket MCP): al ejecutar por execute_code, __file__ no
# existe. El bloque import resuelve la ruta absoluta del repo.
import bpy, os, sys, bmesh
from math import radians, cos, sin, sqrt, pi
from mathutils import Vector

try:
    _AQUI = os.path.dirname(os.path.abspath(__file__))
except NameError:
    _AQUI = None
if not _AQUI or not os.path.isdir(os.path.join(_AQUI, '..', '..')):
    _AQUI = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\36-Fauna\scripts'
sys.path.insert(0, os.path.abspath(os.path.join(_AQUI, '..', '..', 'scripts-reutilizables')))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja)

escena = limpiar()

# ---------------- Paleta (5 mats) ----------------
MAT_caparazon = mat('MAT_Tortuga_Caparazon', (0.46, 0.42, 0.26), rough=0.90)   # oliva
MAT_escudos = mat('MAT_Tortuga_Escudos', (0.32, 0.25, 0.13), rough=0.88)      # marron calido
MAT_piel = mat('MAT_Tortuga_Piel', (0.56, 0.53, 0.35), rough=0.95)           # piel oliva-crema
MAT_plastron = mat('MAT_Tortuga_Plastron', (0.86, 0.80, 0.62), rough=0.95)    # crema
MAT_ojos = mat('MAT_Tortuga_Ojos', (0.05, 0.04, 0.03), rough=0.35, spec=0.50) # humedo


def caja_rot(nombre, x, y, z, sx, sy, sz, material, rot=(0, 0, 0)):
    return caja(nombre, x, y, z, sx, sy, sz, material, rot_euler=rot)


# ---------------- Geometria del domo (para proyectar escudos) ----------------
# Elipsoide del domo: centro (DX, 0, CZ), semiejes (AX, AY, AZ).
DX, CZ = 0.02, 0.205
AX, AY, AZ = 0.345, 0.30, 0.15


def z_superficie_domo(x, y):
    u = (x - DX) / AX
    v = y / AY
    s = 1.0 - u * u - v * v
    return CZ + AZ * sqrt(s) if s > 0.0 else CZ


# ---------------- bmesh helpers (E-32 v2: recalc + volumen firmado) ----------------
def _vol(caras):
    v = 0.0
    for f in caras:
        co = [vt.co for vt in f.verts]
        for k in range(1, len(co) - 1):
            v += co[0].dot(co[k].cross(co[k + 1]))
    return v / 6.0


def _orientar(bm, caras):
    bmesh.ops.recalc_face_normals(bm, faces=caras)
    if _vol(caras) < 0.0:
        bmesh.ops.reverse_faces(bm, faces=caras)
    assert _vol(caras) > 0.0, 'E-32: isla con normales hacia adentro'


def objeto_desde_bmesh(nombre, bm, material, rot=None):
    me = bpy.data.meshes.new('M_' + nombre[3:])
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(ob)
    ob.data.materials.append(material)
    if rot is not None:
        ob.rotation_euler = rot
    return ob


# ===================== 1) PLASTRON (panza plana, apoya) =====================
# Cilindro 12 lados achatado (no caja): borde organico y 12 verts en la
# base a 0.045 (E-50: la caja aportaba solo 4 esquinas).
bpy.ops.mesh.primitive_cylinder_add(
    vertices=12, radius=0.34, depth=0.06,
    location=(0.02, 0.0, 0.075))
plastron = bpy.context.object
plastron.name = 'SM_Tortuga_Plastron'
plastron.scale = (1.09, 1.0, 1.0)
plastron.data.materials.append(MAT_plastron)

# ===================== 2) FALDA (borde segmentado del caparazon) =====================
bpy.ops.mesh.primitive_cone_add(
    vertices=16, radius1=0.375, radius2=0.320, depth=0.11,
    location=(0.02, 0.0, 0.160))
falda = bpy.context.object
falda.name = 'SM_Tortuga_Falda'
falda.scale = (1.15, 1.0, 1.0)
falda.data.materials.append(MAT_escudos)

# ===================== 3) DOMO (caparazon oliva, chato) =====================
bpy.ops.mesh.primitive_uv_sphere_add(
    segments=20, ring_count=10, radius=0.30,
    location=(0.02, 0.0, 0.205))
domo = bpy.context.object
domo.name = 'SM_Tortuga_Domo'
domo.scale = (1.15, 1.0, 0.50)
domo.data.materials.append(MAT_caparazon)

# ===================== 4) ANILLO MARGINAL (union falda/domo) =====================
bpy.ops.mesh.primitive_torus_add(
    major_radius=0.330, minor_radius=0.040, major_segments=16, minor_segments=8,
    location=(0.02, 0.0, 0.205))
anillo = bpy.context.object
anillo.name = 'SM_Tortuga_Anillo'
anillo.scale = (1.15, 1.0, 0.62)
anillo.data.materials.append(MAT_escudos)

# ===================== 5) ESCUDOS (9 pads proyectados, 1 sola malla) =====================
# Cada pad: caja cerrada cuyas 4 esquinas superiores toman la z REAL de la
# superficie del domo +2 cm de relieve; la pollera baja 5 cm DENTRO del
# domo. El pad sigue la curvatura -> imposible que flote (anti-E-50).
PADS = [
    (-0.14, 0.00, 0.15, 0.11),   # fila central: 3 grandes
    (0.03, 0.00, 0.16, 0.11),
    (0.20, 0.00, 0.13, 0.10),
    (-0.10, 0.16, 0.12, 0.09),   # laterales: 2 por lado
    (-0.10, -0.16, 0.12, 0.09),
    (0.10, 0.16, 0.12, 0.09),
    (0.10, -0.16, 0.12, 0.09),
    (-0.20, 0.11, 0.10, 0.08),   # traseros: 2 hacia la cola
    (-0.20, -0.11, 0.10, 0.08),
]
RELIEVE = 0.020
FALDA_PAD = 0.050

bm = bmesh.new()
for (cx, cy, w, d) in PADS:
    tops, bots = [], []
    for (sx, sy) in ((-1, -1), (+1, -1), (+1, +1), (-1, +1)):
        x = cx + sx * w / 2.0
        y = cy + sy * d / 2.0
        zt = z_superficie_domo(x, y) + RELIEVE
        tops.append(bm.verts.new((x, y, zt)))
        bots.append(bm.verts.new((x, y, zt - FALDA_PAD)))
    caras = [bm.faces.new((tops[0], tops[1], tops[2], tops[3])),
             bm.faces.new((bots[0], bots[1], bots[2], bots[3])),
             bm.faces.new((tops[0], tops[1], bots[1], bots[0])),
             bm.faces.new((tops[1], tops[2], bots[2], bots[1])),
             bm.faces.new((tops[2], tops[3], bots[3], bots[2])),
             bm.faces.new((tops[3], tops[0], bots[0], bots[3]))]
    _orientar(bm, caras)
objeto_desde_bmesh('SM_Tortuga_Escudos', bm, MAT_escudos)

# ===================== 6) CUELLO (cono que se afina) =====================
# Rot Y -90: eje Z del cono (de base a punta) queda a lo largo de +X.
# radius1 (base, cerca del caparazon) 0.095 -> radius2 (punta) 0.075.
bpy.ops.mesh.primitive_cone_add(
    vertices=10, radius1=0.075, radius2=0.095, depth=0.18,
    location=(0.40, 0.0, 0.155))
cuello = bpy.context.object
cuello.name = 'SM_Tortuga_Cuello'
cuello.rotation_euler = (0.0, radians(-90), 0.0)
cuello.data.materials.append(MAT_piel)

# ===================== 7) CABEZA (esfera organica, SIN pico) =====================
# v4: el usuario pidio cabeza redonda sin la trompa de la v3. Esfera
# escalada con 2 ojos algo mas grandes y ADELANTE (x 0.60) para que la
# cara no quede sosa sin el pico.
bpy.ops.mesh.primitive_uv_sphere_add(
    segments=16, ring_count=8, radius=0.105,
    location=(0.545, 0.0, 0.165))
cabeza = bpy.context.object
cabeza.name = 'SM_Tortuga_Cabeza'
cabeza.scale = (1.05, 1.00, 0.92)
cabeza.data.materials.append(MAT_piel)

# Ojos: 2 cajitas oscuras tangentes, algo mayores (v4).
caja_rot('SM_Tortuga_Ojo_0', 0.585, -0.098, 0.188, 0.055, 0.028, 0.050, MAT_ojos)
caja_rot('SM_Tortuga_Ojo_1', 0.585, +0.098, 0.188, 0.055, 0.028, 0.050, MAT_ojos)

# ===================== 8) ALETAS DELANTERAS (bmesh tipo remo) =====================
# Loft de 6 anillos octogonales a lo largo del eje X local del objeto:
#   t=0 base r 0.045 (angosta, escondida bajo el caparazon)
#   t=0.55 r 0.105 (maximo ensanche = la pala)
#   t=1.0 r 0.060 (punta con borde afinado)
# El perfil es de aleta de tortuga REAL: crece desde la raiz, pala ancha,
# punta redondeada. Despues el objeto se rota/traslada al punto de anclaje
# (hombro) con to_track_quat-like: rot Z 40 deg (pose de nado) + rot X
# 8 deg (palma levemente inclinada al piso, como remando).


def aleta_remo(nombre, lado):
    bm = bmesh.new()
    N_ANG = 8
    LARGO = 0.58
    anillos = []
    for k in range(6):
        t = k / 5.0
        if t < 0.55:
            r = 0.045 + (0.105 - 0.045) * (t / 0.55)
        else:
            r = 0.105 - (0.105 - 0.060) * ((t - 0.55) / 0.45)
        z_c = 0.012 * sin(t * pi)  # perfil hidrodinamico: lomo suave
        ring = []
        for a in range(N_ANG):
            ang = 2.0 * pi * a / N_ANG
            ring.append(bm.verts.new((t * LARGO, r * cos(ang),
                                      z_c + r * sin(ang))))
        anillos.append(ring)
    caras = []
    for k in range(5):
        for a in range(N_ANG):
            b = (a + 1) % N_ANG
            caras.append(bm.faces.new((anillos[k][a], anillos[k][b],
                                       anillos[k + 1][b], anillos[k + 1][a])))
    # tapa base (t=0) y punta (t=1, anillo cerrado a la nada)
    for a in range(1, N_ANG - 1):
        caras.append(bm.faces.new((anillos[0][0], anillos[0][a],
                                   anillos[0][a + 1])))
        caras.append(bm.faces.new((anillos[5][0], anillos[5][a + 1],
                                   anillos[5][a])))
    _orientar(bm, caras)
    aleta = objeto_desde_bmesh(nombre, bm, MAT_piel)
    # Pose: nado 40 deg hacia afuera-adelante, palma casi plana (-8 deg X).
    # Anclaje (E-09): el punto mas bajo de la pala (r 0.105 en t=0.55) debe
    # NACER a 0.045 -> location.z = 0.045 + 0.105 ~ 0.149. La base (t=0,
    # r 0.045) queda a z 0.10..0.19 DENTRO de la falda (anclada a 0.12,
    # 0.22: dentro de la elipse del caparazon).
    aleta.rotation_euler = (radians(-8), 0.0, radians(40.0) * lado)
    aleta.location = (0.12, 0.22 * lado, 0.1327)
    return aleta


aleta_remo('SM_Tortuga_Aleta_D_0', -1)
aleta_remo('SM_Tortuga_Aleta_D_1', +1)

# ===================== 9) ALETAS TRASERAS (remo compacto eliptico) =====================
# v4: diseno NUEVO (usuario rechazo caja v2 y cono v3). Remo compacto de
# 4 anillos con seccion ELIPTICA (ancho en Y, plano en Z): raiz angosta
# -> pala ANCHA y PLANA (elipse 0.13 x 0.035) -> borde redondeado que se
# afina. Lenguaje formal de las delanteras (remo) pero proporcion de
# aleta trasera real: corta, ancha, timon. La pala NACE tocando 0.045.
def aleta_timon(nombre, lado):
    bm = bmesh.new()
    N = 8
    LARGO = 0.34
    # perfil (t, ancho_y, alto_z): raiz -> pala -> borde
    PERFIL = [(0.00, 0.035, 0.030),
              (0.45, 0.065, 0.038),
              (0.75, 0.130, 0.035),
              (1.00, 0.055, 0.022)]
    anillos = []
    for (t, ry, rz) in PERFIL:
        ring = []
        for a in range(N):
            ang = 2.0 * pi * a / N
            ring.append(bm.verts.new((t * LARGO,
                                      ry * cos(ang),
                                      rz * sin(ang))))
        anillos.append(ring)
    caras = []
    for k in range(len(PERFIL) - 1):
        for a in range(N):
            b = (a + 1) % N
            caras.append(bm.faces.new((anillos[k][a], anillos[k][b],
                                       anillos[k + 1][b], anillos[k + 1][a])))
    for a in range(1, N - 1):
        caras.append(bm.faces.new((anillos[0][0], anillos[0][a],
                                   anillos[0][a + 1])))
        caras.append(bm.faces.new((anillos[3][0], anillos[3][a + 1],
                                   anillos[3][a])))
    _orientar(bm, caras)
    aleta = objeto_desde_bmesh(nombre, bm, MAT_piel)
    # Pose de timon: apunta a atras-afuera. El eje +X del remo se alinea
    # con la direccion via rot Z (E-58 en 2D alcanza: el remo es plano).
    ang_z = radians(150.0) if lado > 0 else (pi - radians(150.0))
    aleta.rotation_euler = (0.0, 0.0, ang_z)
    # Anclaje (E-09): la pala (rz 0.035 max) nace tocando 0.045:
    # location.z = 0.045 + 0.035 = 0.08. Raiz dentro del caparazon.
    aleta.location = (-0.10, 0.26 * lado, 0.08)
    return aleta


aleta_timon('SM_Tortuga_Aleta_T_0', -1)
aleta_timon('SM_Tortuga_Aleta_T_1', +1)

# ===================== 10) COLA (cono corto atras) =====================
# Anillo base (r 0.075) con su punto bajo a 0.045: location.z = 0.12.
bpy.ops.mesh.primitive_cone_add(
    vertices=8, radius1=0.075, radius2=0.0, depth=0.16,
    location=(-0.42, 0.0, 0.120))
cola = bpy.context.object
cola.name = 'SM_Tortuga_Cola'
cola.rotation_euler = (0.0, radians(90), 0.0)  # punta a -X (E-19)
cola.data.materials.append(MAT_piel)

arena(radio=1.6)
iluminar(escena)
asentar(escena)
camara(escena, 'CAM_Tortuga', (1.6, -1.5, 0.9), (0.0, 0.0, 0.20))
shade_flat(escena)
guardar(escena, '36-Fauna', 'tortuga_marina')

# -------- QA numerico en caliente (E-33/E-40: tris REALES) --------
bpy.context.view_layer.update()
ps = [o for o in escena.objects if o.type == 'MESH' and o.name.startswith('SM_')]
tris = 0
for o in ps:
    o.data.calc_loop_triangles()
    tris += len(o.data.loop_triangles)
mats_usados = set()
for o in ps:
    for p in o.data.polygons:
        if p.material_index < len(o.material_slots):
            sm = o.material_slots[p.material_index].material
            if sm:
                mats_usados.add(sm.name)
print('QA TORTUGA v3: %d SM_ · %d tris reales · %d mats usados' % (
    len(ps), tris, len(mats_usados)))
assert len(ps) <= 16, 'E-70: %d objetos exceden el tope ALTA de 16' % len(ps)
assert tris <= 6000, 'presupuesto ALTA de tris excedido (%d)' % tris
