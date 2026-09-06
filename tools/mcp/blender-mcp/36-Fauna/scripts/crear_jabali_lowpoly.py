# crear_jabali_lowpoly.py - Jabalí (M36 Fauna, checklist linea 106)
#
# v5 (2026-09-02, usuario: "muy rigida, que se parezca mas a un jabali"):
#   - SILUETA EN CUJA (lo que faltaba): masa frontal pesada + grupa
#     estrecha. 7 anillos asimetricos: la linea del lomo SE HUNDE a
#     media espalda y SUBE en la cruz (hump), el vientre cae.
#   - CABEZA GRANDE en cuna (~1/3 del cuerpo, como el jabali real):
#     craneo alto -> perfil CONCAVO (frente) -> hocico largo, rotada
#     -12 grados en actitud de husmeo. Nuca enterrada en el cuello.
#   - CRESTA LOFTADA DE ROMBOS que SIGUE la curva del lomo (v4 era una
#     caja recta): crece desde la grupa, maximo sobre los hombros,
#     muere sobre la cabeza — mohawk barrido hacia atras.
#   - PATAS: delanteras y traseras DE DISTINTA LONGITUD (traseras mas
#     largas -> grupa elevada, pose tipica). Canna mas fina.
#   - Cola con mechon, orejas en hoja, ojos altos (junto a la cresta).
#
# CONTEO E-70 (lista explicita): 1 tronco + 1 cabeza + 1 cresta
#   + 2 orejas + 2 ojos + 2 colmillos + 1 trompa + 4 patas + 1 cola
#   = 15 SM_ <= 16. OK.
#
# APOYO (E-50): 4 pezuñas (anillo 6 verts c/u, base a z 0.045 exacto
#   por construccion). 24 verts de huella. El resto vuela.
#
# E-74 (espejos: negar angulo), E-32 v2 (islas con volumen firmado),
# E-27 (cero parenting), E-24 (asentar mide vertices reales).
import bpy, os, sys, bmesh
from math import radians, cos, sin, pi

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

# ---------------- Paleta ----------------
MAT_pelo = mat('MAT_Jabali_Pelo', (0.48, 0.38, 0.28), rough=0.95)          # pardo calido
MAT_pelo_oscuro = mat('MAT_Jabali_Pelo_Oscuro', (0.30, 0.24, 0.18), rough=0.95)  # patas/oscuro
MAT_cresta = mat('MAT_Jabali_Cresta', (0.16, 0.12, 0.09), rough=0.90)     # cerda casi negra
MAT_colmillo = mat('MAT_Jabali_Colmillo', (0.90, 0.86, 0.76), rough=0.40) # marfil pulido
MAT_ojos = mat('MAT_Jabali_Ojos', (0.05, 0.04, 0.03), rough=0.30, spec=0.60)
MAT_hocico = mat('MAT_Jabali_Hocico', (0.52, 0.42, 0.34), rough=0.85)


# ---------------- bmesh helpers (E-32 v2) ----------------
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
    """anillos: lista de listas de verts (x,y,z) — todos con igual N.
    Une consecutivos y tapa extremos con abanico."""
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
    """Anillo eliptico en el plano YZ (seccion transversal del cuerpo)."""
    return [(cx, ry * cos(2 * pi * a / N), cz + rz * sin(2 * pi * a / N))
            for a in range(N)]


def rombo(cx, cz_base, w, h):
    """Seccion diamante de 4 verts para la cresta (pico arriba/abajo)."""
    return [(cx, 0.0, cz_base - h * 0.35), (cx, +w, cz_base),
            (cx, 0.0, cz_base + h), (cx, -w, cz_base)]


# ===================== 1) TRONCO (cuña: pesado adelante) =====================
# (x, cz, ry, rz): cz alto = lomo elevado. La espalda se HUNDE en el
# medio (x -0.15, cz 0.50) y remonta en la cruz (x +0.28, cz 0.525).
AN_TRONCO = [
    anillo(-0.47, 0.508, 0.012, 0.020),  # punta (justo detras de la grupa)
    anillo(-0.455, 0.508, 0.045, 0.060),  # contraccion inmediata
    anillo(-0.43, 0.510, 0.090, 0.100),  # esfera trasera chica
    anillo(-0.38, 0.515, 0.150, 0.135),  # grupa (estrecha, elevada)
    anillo(-0.15, 0.500, 0.185, 0.150),   # media espalda: el HUNDIMIENTO
    anillo(+0.05, 0.495, 0.205, 0.165),   # vientre (maximo ancho, bajo)
    anillo(+0.28, 0.525, 0.200, 0.180),   # CRUZ: hombros masivos y altos
    anillo(+0.42, 0.520, 0.160, 0.160),   # pecho
    anillo(+0.55, 0.505, 0.115, 0.115),   # cuello (inserta cabeza)
]
# v11: TRASERO CORTO a pedido del usuario — la punta queda a -0.47, SOLO
# 9 cm detras del anillo de la grupa (-0.38). El rabo del jabali es una
# esfera compacta pegada a la grupa (v10 sobresalia 22 cm).
loft('SM_Jabali_Tronco', AN_TRONCO, MAT_pelo)

# ===================== 2) CABEZA GRANDE (cuna + hocico) =====================
# v8: AGRANDADA a pedido del usuario — el cuello del tronco mide r 0.115
# y el craneo de la v7 era 0.105 (mas chico que el cuello: se leia
# "cabeza de gato en cuerpo de jabali"). Ahora el craneo es r 0.135x0.130,
# claramente MAS ANCHO que el cuello, con hocico proporcional.
# Loft local +X: nuca enterrada -> craneo alto -> perfil CONCAVO -> hocico.
AN_CABEZA = [
    anillo(-0.13, 0.00, 0.100, 0.100),   # nuca (r = cuello 0.115, enterrada)
    anillo(-0.02, +0.005, 0.135, 0.130),  # craneo ANCHO (domina al cuello)
    anillo(+0.10, 0.000, 0.130, 0.125),  # craneo alto
    anillo(+0.20, -0.010, 0.085, 0.080),  # frente (quiebre concavo)
    anillo(+0.30, -0.030, 0.058, 0.055),  # hocico medio
    anillo(+0.40, -0.035, 0.044, 0.042),  # punta
]
cabeza = loft('SM_Jabali_Cabeza', AN_CABEZA, MAT_pelo)
# v7: cabeza MAS ALTA y husmeo SUAVE. El eje del cuello del tronco esta
# en cz 0.505: el centro del craneo va a 0.50 (v6: 0.46, colgaba bajo el
# cuello) y el pitch baja de 12 a 8 grados — la punta del hocico queda
# a z ~0.36 (oliendo el piso sin arrastrarse).
cabeza.rotation_euler = (0.0, radians(8.0), 0.0)
cabeza.location = (0.56, 0.0, 0.50)

# ---- v6: TODOS los detalles de la cabeza en coords de MUNDO calculadas
# con matrix_world de la cabeza YA rotada (nunca a mano — leccion v5).
bpy.context.view_layer.update()
MW = cabeza.matrix_world
from mathutils import Vector as _V
_Vec = _V  # alias para las direcciones to_track_quat (colmillos y orejas)


def punto_cabeza(lx, ly, lz):
    return MW @ _V((lx, ly, lz))


# Sanity check del signo: la punta del hocico debe quedar DEBAJO del
# centro del craneo (husmeo). Si falla, el signo vuelve a estar invertido.
_punta = punto_cabeza(0.36, 0.0, -0.03)
_craneo = punto_cabeza(0.09, 0.0, 0.0)
assert _punta.z < _craneo.z, 'v6: el hocico apunta ARRIBA — signo de rot Y invertido de nuevo'

# Ojos: sobre el craneo, altos (junto a la cresta), levemente hacia adelante
for i, sy in enumerate((-1, +1)):
    p = punto_cabeza(0.05, sy * 0.098, 0.062)
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=10, ring_count=6, radius=0.019, location=p)
    ojo = bpy.context.object
    ojo.name = 'SM_Jabali_Ojo_%d' % i
    ojo.data.materials.append(MAT_ojos)

# Colmillos: v9 — anclaje REAL sobre la superficie. El bug restante de la
# v8: el cono mide 14 cm y su TAPA DE BASE queda a center - (depth/2)*dir;
# con dir apuntando arriba, esa tapa cae 5.4 cm DEBAJO del centro -> la
# base quedaba colgando en el aire bajo la mandibula aunque el centro
# estuviera "dentro" del hocico. Fix: la BASE se planta sobre la cara
# inferior del hocico (superficie local z = -0.075 del anillo x=0.30) y
# el cono se crea con el CENTRO desplazado +dir*(depth/2) desde esa base
# -> la tapa queda ENTERRADA 1 cm en la boca y la punta sube afuera.
for i, sy in enumerate((-1, +1)):
    base = punto_cabeza(0.30, sy * 0.042, -0.072)   # sobre la mandibula
    direccion = _Vec((0.55, 0.28 * sy, 0.75)).normalized()
    centro = base + direccion * (0.14 / 2.0 - 0.012)  # tapa 1.2 cm dentro
    bpy.ops.mesh.primitive_cone_add(
        vertices=8, radius1=0.017, radius2=0.0, depth=0.14, location=centro)
    col = bpy.context.object
    col.name = 'SM_Jabali_Colmillo_%d' % i
    col.rotation_euler = direccion.to_track_quat('Z', 'Y').to_euler()
    col.data.materials.append(MAT_colmillo)

# Trompa: en la punta misma del hocico
p = punto_cabeza(0.365, 0.0, -0.032)
bpy.ops.mesh.primitive_uv_sphere_add(
    segments=10, ring_count=6, radius=0.027, location=p)
trompa = bpy.context.object
trompa.name = 'SM_Jabali_Trompa'
trompa.scale = (0.7, 1.0, 0.8)
trompa.data.materials.append(MAT_hocico)

# Orejas: v7 con to_track_quat (E-58) — direccion EXPLICITA arriba-atras-
# afuera, sin rotaciones compuestas a mano (v6 las ponia raras: quedaban
# volcadas hacia adelante por heredar la rotacion mental del husmeo).
# Nacen del tope posterior del craneo, senalales de jabali alerta.
for i, sy in enumerate((-1, +1)):
    p = punto_cabeza(-0.05, sy * 0.088, 0.096)
    bpy.ops.mesh.primitive_cone_add(
        vertices=6, radius1=0.038, radius2=0.006, depth=0.13, location=p)
    oreja = bpy.context.object
    oreja.name = 'SM_Jabali_Oreja_%d' % i
    direccion = _Vec((-0.35, 0.18 * sy, 1.0)).normalized()
    oreja.rotation_euler = direccion.to_track_quat('Z', 'Y').to_euler()
    oreja.scale = (0.45, 1.0, 1.0)  # lamina
    oreja.data.materials.append(MAT_pelo_oscuro)

# ===================== 3) CRESTA (rombos que siguen el lomo) =====================
# Linea del lomo medida de AN_TRONCO (cz + rz): grupa 0.65, hundimiento
# 0.65, vientre 0.66, cruz 0.705. La cresta crece hacia adelante.
AN_CRESTA = [
    rombo(-0.30, 0.640, 0.016, 0.050),   # nace en la grupa (chica)
    rombo(-0.10, 0.645, 0.018, 0.080),   # media espalda
    rombo(+0.10, 0.650, 0.018, 0.105),   # sube
    rombo(+0.28, 0.690, 0.016, 0.130),   # MAXIMO sobre la cruz
    rombo(+0.42, 0.665, 0.014, 0.055),   # muere hacia la cabeza
]
loft('SM_Jabali_Cresta', AN_CRESTA, MAT_cresta)

# ===================== 4) PATAS (delanteras cortas, traseras largas) =====================
# Origin en la CADERA (pivote Godot). Pezuña engrosada al piso (z 0.045
# exacto). Traseras mas largas -> grupa elevada (pose del jabali real).
def pata(nombre, px, py, largo, cadera_z):
    def an_xy(r, z, N=6):
        return [(r * cos(2 * pi * a / N), r * sin(2 * pi * a / N), z) for a in range(N)]
    ANILLOS = [an_xy(0.048, 0.00),        # cadera (origen/pivote)
               an_xy(0.030, -largo * 0.33),  # canna fina
               an_xy(0.034, -largo * 0.75),  # menudillo
               an_xy(0.042, -largo)]         # pezuña engrosada, base plana
    p = loft(nombre, ANILLOS, MAT_pelo_oscuro)
    p.location = (px, py, cadera_z)
    return p


pata('SM_Jabali_Pata_FL', 0.32, -0.12, 0.42, 0.465)   # delantera izq
pata('SM_Jabali_Pata_FR', 0.32, +0.12, 0.42, 0.465)
pata('SM_Jabali_Pata_BL', -0.36, -0.11, 0.46, 0.505)  # trasera MAS LARGA
pata('SM_Jabali_Pata_BR', -0.36, +0.11, 0.46, 0.505)

# ===================== 8) COLA (larga, caida natural, 1 malla) =====================
# v12b (E-70: los 2 conos sumaban 17 SM_): UNA sola malla bmesh — loft de
# 5 anillos decagonales siguiendo la curva de caida, del nacimiento en la
# grupa alta hasta la punta. Pivote en el origen (la base, para que Godot
# pueda menearla rotando desde ahi).
from mathutils import Vector as _VCol
base_cola = _VCol((-0.40, 0.0, 0.615))
dir1 = _VCol((-0.85, 0.0, -0.45)).normalized()
dir2 = _VCol((-0.25, 0.0, -0.95)).normalized()
# Puntos de la linea central (base -> codo -> punta), radios decrecientes
PTOS = [base_cola,
        base_cola + dir1 * 0.055,
        base_cola + dir1 * 0.10,          # codo
        base_cola + dir1 * 0.10 + dir2 * 0.06,
        base_cola + dir1 * 0.10 + dir2 * 0.115]  # punta (~21 cm total)
RADIOS = [0.016, 0.014, 0.011, 0.008, 0.003]
# Anillos perpendiculares al tramo: eje de referencia Y (la curva vive en XZ)
bm_cola = bmesh.new()
caras_cola = []
rings_cola = []
for k, (p, r) in enumerate(zip(PTOS, RADIOS)):
    if k == 0:
        tang = (PTOS[1] - PTOS[0]).normalized()
    elif k == len(PTOS) - 1:
        tang = (PTOS[k] - PTOS[k - 1]).normalized()
    else:
        tang = (PTOS[k + 1] - PTOS[k - 1]).normalized()
    # Base ortonormal: y fijo (0,1,0), n = tang x y (en XZ)
    n1 = tang.cross(_VCol((0, 1, 0))).normalized()
    n2 = tang.cross(n1).normalized()
    ring = [bm_cola.verts.new(tuple(p + n1 * r * cos(2 * pi * a / 10)
                                    + n2 * r * sin(2 * pi * a / 10)))
            for a in range(10)]
    rings_cola.append(ring)
for k in range(len(rings_cola) - 1):
    for a in range(10):
        b = (a + 1) % 10
        caras_cola.append(bm_cola.faces.new((rings_cola[k][a], rings_cola[k][b],
                                            rings_cola[k + 1][b], rings_cola[k + 1][a])))
# tapa base (dentro de la grupa) y punta (casi punto)
for a in range(1, 9):
    caras_cola.append(bm_cola.faces.new((rings_cola[0][0], rings_cola[0][a], rings_cola[0][a + 1])))
    caras_cola.append(bm_cola.faces.new((rings_cola[4][0], rings_cola[4][a + 1], rings_cola[4][a])))
_isla(bm_cola, caras_cola)
cola = _obj('SM_Jabali_Cola', bm_cola, MAT_pelo_oscuro)
# El objeto se creo con los verts ya en su lugar de mundo: pivote 0.
# Para que Godot pueda menearla desde la base, el origen queda en 0 y los
# verts van tal cual (alternativa simple: pivot en el centro de la isla).
# Mechon en la punta (matematico)
p_mechon = PTOS[4] + dir2 * 0.006
bpy.ops.mesh.primitive_uv_sphere_add(
    segments=8, ring_count=5, radius=0.020, location=tuple(p_mechon))
mechon = bpy.context.object
mechon.name = 'SM_Jabali_Cola_Mechon'
mechon.scale = (1.3, 1.0, 1.0)
mechon.data.materials.append(MAT_cresta)

arena(radio=1.4)
iluminar(escena)
asentar(escena)
camara(escena, 'CAM_Jabali', (1.6, -1.5, 0.95), (0.0, 0.0, 0.35))
shade_flat(escena)
guardar(escena, '36-Fauna', 'jabali')

# -------- QA en caliente (E-33/E-40/E-70) --------
bpy.context.view_layer.update()
ps = [o for o in escena.objects if o.type == 'MESH' and o.name.startswith('SM_')]
tris = 0
for o in ps:
    o.data.calc_loop_triangles()
    tris += len(o.data.loop_triangles)
print('QA JABALI: %d SM_ · %d tris reales · %d mats' % (
    len(ps), tris, len(set(m.name for o in ps for m in o.data.materials))))
assert len(ps) <= 16, 'E-70: %d objetos exceden el tope ALTA de 16' % len(ps)
assert tris <= 6000, 'presupuesto ALTA de tris excedido (%d)' % tris
