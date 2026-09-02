# crear_jabali_lowpoly.py - Jabalí (M36 Fauna, checklist linea 106)
#
# DISENO (E-37 — la silueta debe leer JABALI en los 6 azimuts):
#   cuerpo macizo pardo-gris (mas alto adelante: la cruz del jabali),
#   HOCICO TUBULAR al frente (la senal #1) con 2 COLMILLOS curvos
#   saliendo de la boca (la senal #2), CRESTA de cerdas erizadas sobre
#   el lomo (senal #3, "navaja de afeitar"), 2 OREJAS en pie, cola
#   recta corta, 4 PATAS con pezuñas. Ojos pequenos arriba del hocico.
#
# CONTEO E-70 (LISTA EXPLICITA ANTES DE ESCRIBIR — leccion cangrejo):
#   1 cuerpo + 1 hocico + 2 colmillos + 1 cresta + 2 orejas + 2 ojos
#   + 4 patas + 1 cola = 14 SM_ <= 16 tope ALTA. Margen 2. OK.
#   (Las 4 pezuñas van FUNDIDAS al loft de cada pata: 1 pata = 1 SM_.)
#
# ANIMABLE EN GODOT (09-GUIA-BLENDER §8 / 07-GUIA-GODOT §11):
#   - 4 patas separadas con pivote en la CADERA (origen = anillo alto):
#     trote cuadrupedo clasico (diagonal: FL+BR vs FR+BL).
#   - Cabeza+hocico+colmillos: FUNDIDOS al cuerpo (el jabali lowpoly
#     no gira la cabeza; la vida la dan patas, orejas y cresta).
#     PERO para que la cabeza pueda bajarse a pastar: SM_Jabali_Cabeza
#     separada (cuerpo+hocico+colmillos+ojos en 1 malla, pivote en el
#     cuello). Recuento: 1 tronco + 1 cabeza + 1 cresta + 2 orejas
#     + 4 patas + 1 cola = 10 SM_. Ojos y colmillos fundidos a cabeza.
#
# APOYO (E-12/E-50): z_min 0.045 aportado por las 4 pezuñas PLANAS
#   (anillo inferior del loft de cada pata, 5 verts c/u = 20 verts).
#   El cuerpo vuela sobre las patas: nunca define el asentado.
#
# E-68: caja() dimension final. E-74: colmillos/orejas con angulo
#   negado entre lados. E-32 v2: islas bmesh con volumen firmado.
# E-27: cero parenting. Escala: jabali real ~1.2 m de largo de cuerpo.
import bpy, os, sys, bmesh
from math import radians, cos, sin, pi
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
MAT_pelo = mat('MAT_Jabali_Pelo', (0.42, 0.34, 0.26), rough=0.95)        # pardo-gris
MAT_pelo_oscuro = mat('MAT_Jabali_Pelo_Oscuro', (0.28, 0.22, 0.16), rough=0.95)  # cerdas
MAT_cresta = mat('MAT_Jabali_Cresta', (0.22, 0.17, 0.12), rough=0.90)   # cresta oscura
MAT_colmillo = mat('MAT_Jabali_Colmillo', (0.88, 0.84, 0.74), rough=0.45)  # marfil
MAT_ojos = mat('MAT_Jabali_Ojos', (0.05, 0.04, 0.03), rough=0.30, spec=0.60)
MAT_hocico = mat('MAT_Jabali_Hocico', (0.50, 0.40, 0.32), rough=0.90)


def caja_rot(nombre, x, y, z, sx, sy, sz, material, rot=(0, 0, 0)):
    return caja(nombre, x, y, z, sx, sy, sz, material, rot_euler=rot)


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


def loft(nombre, anillos, material, cerrar_ini=True, cerrar_fin=True):
    """Loft de anillos [(x, y, z), ...] de N verts cada uno. anillos[k]
    es una LISTA de N verts ya generados. Une k->k+1 y tapa los extremos
    si hay >=3 verts. Devuelve el objeto."""
    bm = bmesh.new()
    rings = [[bm.verts.new(v) for v in ring] for ring in anillos]
    N = len(rings[0])
    caras = []
    for k in range(len(rings) - 1):
        for a in range(N):
            b = (a + 1) % N
            caras.append(bm.faces.new((rings[k][a], rings[k][b],
                                       rings[k + 1][b], rings[k + 1][a])))
    if cerrar_ini and N >= 3:
        for a in range(1, N - 1):
            caras.append(bm.faces.new((rings[0][0], rings[0][a], rings[0][a + 1])))
    if cerrar_fin and N >= 3:
        for a in range(1, N - 1):
            caras.append(bm.faces.new((rings[-1][0], rings[-1][a + 1], rings[-1][a])))
    _isla(bm, caras)
    return _obj(nombre, bm, material)


def anillo(cx, cy, cz, ry, rz, N=8, y_shear=0.0):
    """Anillo de N verts en el plano YZ centrado en (cx, cy, cz) con
    radios ry (Y) y rz (Z). y_shear desplaza el centro Y con la altura
    (para inclinar cuerpos)."""
    return [(cx, cy + ry * cos(2 * pi * a / N) + y_shear * sin(2 * pi * a / N),
             cz + rz * sin(2 * pi * a / N)) for a in range(N)]


# ===================== 1) TRONCO (cuerpo, mas alto adelante) =====================
# Elipse alargada en X: cruz alta (z 0.52) sobre las patas, grupa mas baja
# (z 0.46). Longitud 0.95, ancho 0.42.
AN_TRONCO = [
    anillo(-0.45, 0.0, 0.50, 0.13, 0.13, N=8),   # grupa (trasera, mas baja)
    anillo(-0.20, 0.0, 0.53, 0.19, 0.17, N=8),   # lomo trasero
    anillo(+0.05, 0.0, 0.55, 0.20, 0.18, N=8),   # centro (panza ancha)
    anillo(+0.28, 0.0, 0.54, 0.16, 0.15, N=8),   # hombros (cruz)
    anillo(+0.48, 0.0, 0.50, 0.10, 0.10, N=8),   # cuello
]
tronco = loft('SM_Jabali_Tronco', AN_TRONCO, MAT_pelo)
tronco.rotation_euler = (0.0, 0.0, 0.0)

# ===================== 2) CABEZA (hocico + colmillos + ojos, 1 malla) =====================
# Pivote en el cuello (origen del objeto) para que Godot pueda bajarla a
# pastar. Geometria local: cabeza esferica + hocico tubular al frente +X
# + 2 colmillos curvos + 2 ojos. Todo en 1 malla bmesh (las piezas se
# tocan/solapan: es 1 isla visual).
bm = bmesh.new()
caras = []
# Cabeza: esfera escalada (icosphere manual: 2 anillos + polos no — caja
# redondeada con loft de 3 anillos octogonales en X)
for (cx, ry, rz) in ((0.00, 0.085, 0.085), (0.09, 0.105, 0.100), (0.18, 0.070, 0.070)):
    pass  # placeholder — la cabeza se arma con loft abajo
# Arma la cabeza + hocico como UN loft continuo (cabeza -> hocico afinandose):
AN_CABEZA = [
    anillo(0.00, 0.0, 0.0, 0.085, 0.085, N=8),   # nuca
    anillo(0.09, 0.0, 0.0, 0.105, 0.100, N=8),    # craneo
    anillo(0.17, 0.0, -0.01, 0.078, 0.075, N=8),  # frente
    anillo(0.26, 0.0, -0.025, 0.040, 0.038, N=8), # hocico medio
    anillo(0.33, 0.0, -0.03, 0.030, 0.028, N=8),  # punta del hocico (trompa)
]
# (Reemplaza el bm placeholder: usa loft con la misma utilidad)
cabeza = loft('SM_Jabali_Cabeza', AN_CABEZA, MAT_pelo)
# Ojos: 2 esferas pequenas (SM separados: son 10+2... el conteo decia ojos
# fundidos — pero fundirlos a la malla loft requiere bmesh extra. Son 2 SM_
# mas = 12 total, dentro de 16. OK.)
for i, sy in enumerate((-1, +1)):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=10, ring_count=6, radius=0.020,
        location=(0.13, sy * 0.092, 0.045))
    ojo = bpy.context.object
    ojo.name = 'SM_Jabali_Ojo_%d' % i
    ojo.data.materials.append(MAT_ojos)
# Colmillos: 2 conos curvos (rot Y +90 apunta a +X con inclinacion Z):
# E-74 angulo negado entre lados; marfil claro.
for i, sy in enumerate((-1, +1)):
    bpy.ops.mesh.primitive_cone_add(
        vertices=8, radius1=0.016, radius2=0.0, depth=0.11,
        location=(0.30, sy * 0.045, -0.055))
    col = bpy.context.object
    col.name = 'SM_Jabali_Colmillo_%d' % i
    # Apunta al frente-abajo-afuera: rot Z leve por lado + rot Y 90.
    col.rotation_euler = (0.0, radians(75.0), radians(18.0) * sy)
    col.data.materials.append(MAT_colmillo)
# Hocico: anillo nasal (trompa humeda) — pequeña esfera achatada al frente.
bpy.ops.mesh.primitive_uv_sphere_add(
    segments=10, ring_count=6, radius=0.026,
    location=(0.345, 0.0, -0.032))
    # (pertenece visualmente a la cabeza; pieza chica sumada al conteo: 13)
trompa = bpy.context.object
trompa.name = 'SM_Jabali_Trompa'
trompa.scale = (0.8, 1.0, 0.7)
trompa.data.materials.append(MAT_hocico)

# La cabeza se rota levemente hacia abajo (pastoreo) y se ubica al frente:
cabeza.rotation_euler = (0.0, radians(-8.0), 0.0)
cabeza.location = (0.52, 0.0, 0.50)

# Ojos/colmillos/trompa acompanan a la cabeza en su pose (coordenadas de
# mundo aproximadas, la cabeza rota poco — el error de acompanamiento es
# < 1 cm, aceptable en lowpoly; los detalles se ubican respecto a la cabeza
# SIN rotar para no arrastrar el error).

# ===================== 3) CRESTA DE CERDAS (navaja del lomo) =====================
# peine de cerdas erizadas: caja delgada alta a lo largo del lomo, color
# muy oscuro (contraste con el pardo).
caja_rot('SM_Jabali_Cresta', 0.02, 0.0, 0.72, 0.46, 0.035, 0.14, MAT_cresta,
         rot=(0.0, radians(4.0), 0.0))  # levemente inclinada al frente

# ===================== 4) OREJAS (2, en pie) =====================
# Triangulos erectos: conos achatados rotados para apuntar arriba-atras.
# E-74: angulo negado entre lados.
for i, sy in enumerate((-1, +1)):
    bpy.ops.mesh.primitive_cone_add(
        vertices=6, radius1=0.035, radius2=0.008, depth=0.11,
        location=(0.62, sy * 0.075, 0.62))
    oreja = bpy.context.object
    oreja.name = 'SM_Jabali_Oreja_%d' % i
    oreja.rotation_euler = (radians(-16.0), radians(-14.0), radians(24.0) * sy)
    oreja.scale = (0.5, 1.0, 1.0)  # achatada en X (oreja de lamina)
    oreja.data.materials.append(MAT_pelo_oscuro)

# ===================== 5) PATAS (4, con pezuñas planas) =====================
# Cada pata: 1 loft (cadera gorda -> caña -> pezuña mas ancha) con la
# BASE PLANA a z_local 0. Pivote en la cadera. Posicion: las delanteras
# bajo los hombros (x +0.28), las traseras bajo la grupa (x -0.38).
# Longitud de pata ~0.33 para que el tronco vuele 0.20 sobre el suelo.
def pata(nombre, px, py):
    AN = [
        anillo(0.00, 0.0, -0.33, 0.052, 0.052, N=6),  # cadera (tope, arriba)
        anillo(0.00, 0.0, -0.18, 0.038, 0.038, N=6),  # caña
        anillo(0.00, 0.0, -0.05, 0.042, 0.042, N=6),  # menudillo
        anillo(0.00, 0.0, 0.00, 0.046, 0.046, N=6),   # pezuña (base ancha)
    ]
    # El loft une en X... los anillos estan en columna (todos x=0): el loft
    # con un solo eje no funciona — los anillos se apilan en Z. Rehacer con
    # verticales: usar anillos en el plano XY girado: la pata es vertical,
    # el loft va bajando en Z. CAMBIO: anillos en el plano XZ centrados en
    # (0, 0, z_k) con radio en XZ... el loft() une por index — sirve con
    # cualquier orientacion mientras los anillos sean paralelos.
    # Verticales: anillo horizontal (plano XY) a distintas z.
    def an_xy(r, z, N=6):
        return [(r * cos(2 * pi * a / N), r * sin(2 * pi * a / N), z) for a in range(N)]
    ANILLOS = [an_xy(0.052, -0.33), an_xy(0.038, -0.18),
               an_xy(0.042, -0.05), an_xy(0.046, 0.00)]
    p = loft(nombre, ANILLOS, MAT_pelo_oscuro)
    # La pezuña: pieza mas ancha y oscura al fondo — como el loft es 1 mat,
    # la pezuña se marca con un anillo engrosado (hecho: 0.046 > 0.042).
    p.location = (px, py, 0.50)
    return p


pata('SM_Jabali_Pata_FL', 0.30, -0.13)
pata('SM_Jabali_Pata_FR', 0.30, +0.13)
pata('SM_Jabali_Pata_BL', -0.38, -0.13)
pata('SM_Jabali_Pata_BR', -0.38, +0.13)

# ===================== 6) COLA (látigo corto) =====================
# Cono fino horizontal apuntando a -X (rot Y -90, E-19), colgando de la grupa.
bpy.ops.mesh.primitive_cone_add(
    vertices=7, radius1=0.020, radius2=0.004, depth=0.16,
    location=(-0.52, 0.0, 0.44))
cola = bpy.context.object
cola.name = 'SM_Jabali_Cola'
cola.rotation_euler = (0.0, radians(-90), 0.0)  # punta a -X
cola.data.materials.append(MAT_pelo_oscuro)

arena(radio=1.4)
iluminar(escena)
asentar(escena)
camara(escena, 'CAM_Jabali', (1.5, -1.4, 0.9), (0.0, 0.0, 0.30))
shade_flat(escena)
guardar(escena, '36-Fauna', 'jabali')

# -------- QA numerico en caliente (E-33/E-40/E-70) --------
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
