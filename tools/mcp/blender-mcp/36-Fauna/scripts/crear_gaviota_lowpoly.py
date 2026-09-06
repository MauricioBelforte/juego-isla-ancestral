# crear_gaviota_lowpoly.py - Gaviota voladora (M36 Fauna, checklist linea 103)
#
# EL GRAN RETO (usuario, 2026-09-03): "un ave que deberá poder volar".
# Es el PRIMER ASSET VOLADOR del pipeline: el NPC en Godot NO camina por el
# suelo sino que VUELA en circulos con planeo (ver gaviota_npc.gd).
#
# DISENO (E-37 + guia 09 §9 nivel minimo de detalle):
#   Gaviota clasica de isla: cuerpo blanco fusiforme (mas gordo adelante,
#   contraido a la cola), CABEZA BLANCA redonda con PICO AMARILLO corto
#   (la senal #1 de gaviota), ALAS GRIS PERLA larguisimas (1.6x el cuerpo)
#   con PUNTAS NEGRAS (la senal #2, "wingtip" de gaviota adulta), cola
#   corta con少许 feather, patas amarillas plegadas bajo el cuerpo
#   (pegadas al vientre, como planean las aves), ojos negros laterales.
#
# ANIMABLE EN GODOT (09 §8 / 07 §11 — pensado para VUELO):
#   - SM_Gaviota_Ala_L / _R: UNA malla loftada por ala con pivote en el
#     HOMBRO (origen = raiz del ala). Godot las BATE rotando X local
#     (arriba/abajo): el tip negro acompana por parenting EN GODOT (ver
#     abajo). Perfil del ala: hombro grueso -> envergadura afinandose ->
#     borde de fuga (el loft emula las plumas primarias con muescas).
#   - SM_Gaviota_Punta_L / _R: las manchas negras del tip, SEPARADAS para
#     el color. En Godot se re-parentan al ala (1 nodo hijo) para batir
#     juntas — documentado en gaviota_npc.gd.
#   - SM_Gaviota_Cabeza (con pico y ojos fundidos en 1 malla): pivote en
#     el cuello para mirar alrededor en las pausas del planeo.
#   - SM_Gaviota_Cuerpo + SM_Gaviota_Cola + 2 SM_Gaviota_Pata plegadas
#     (rotacion sutil en vuelo, tucking).
#
# CONTEO E-70 (lista explicita): 1 cuerpo(=cabeza, loft continuo con
#   manto multi-material) + 1 pico + 2 ojos + 2 alas + 2 puntas + 1 cola
#   + 2 patas = 11 SM_ <= 16. OK. (v9: barras quitadas, manto pintado.)
#
# APOYO (E-12/E-50): ES UN AVE EN VUELO — el asset NO se asienta en la
#   arena: se captura PLANEANDO con las patas plegadas y el cuerpo a
#   z 0.35 sobre el piso del set (nivel de vuelo). El asentar() se omite
#   para el conjunto; la huella la definen las puntas de ala si rozan.
#   (El z_min del GLB lo usa Godot como ALTURA DE VUELO base, no apoyo.)
#
# E-74 (espejo por negacion), E-32 v2 (islas bmesh con volumen firmado),
# E-27 (cero parenting), E-24 (medir vertices reales).
import bpy, os, sys, bmesh
from math import radians, cos, sin, pi, sqrt
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

# ---------------- Paleta (6 mats) ----------------
MAT_blanco = mat('MAT_Gaviota_Blanco', (0.94, 0.94, 0.92), rough=0.85)        # cuerpo
MAT_gris = mat('MAT_Gaviota_Gris', (0.62, 0.64, 0.66), rough=0.85)            # alas perla
MAT_negro = mat('MAT_Gaviota_Negro', (0.06, 0.06, 0.07), rough=0.70)          # wingtips + ojos
MAT_pico = mat('MAT_Gaviota_Pico', (0.92, 0.72, 0.15), rough=0.50)            # amarillo
MAT_pata = mat('MAT_Gaviota_Pata', (0.85, 0.65, 0.12), rough=0.60)            # patas amarillas
MAT_gris_claro = mat('MAT_Gaviota_Gris_Claro', (0.80, 0.81, 0.82), rough=0.85)  # cola/manto
MAT_manto = mat('MAT_Gaviota_Manto', (0.32, 0.33, 0.36), rough=0.85)         # dorso gris oscuro


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


def loft(nombre, anillos, material, tapa_ini=True, tapa_fin=True):
    """anillos: lista de listas de N verts (x,y,z). Une consecutivos."""
    bm = bmesh.new()
    rings = [[bm.verts.new(v) for v in ring] for ring in anillos]
    N = len(rings[0])
    caras = []
    for k in range(len(rings) - 1):
        for a in range(N):
            b = (a + 1) % N
            caras.append(bm.faces.new((rings[k][a], rings[k][b],
                                       rings[k + 1][b], rings[k + 1][a])))
    if tapa_ini and N >= 3:
        for a in range(1, N - 1):
            caras.append(bm.faces.new((rings[0][0], rings[0][a], rings[0][a + 1])))
    if tapa_fin and N >= 3:
        for a in range(1, N - 1):
            caras.append(bm.faces.new((rings[-1][0], rings[-1][a + 1], rings[-1][a])))
    _isla(bm, caras)
    return _obj(nombre, bm, material)


def anillo(cx, cy, cz, ry, rz, N=8):
    """Anillo eliptico en el plano YZ (seccion transversal, eje del cuerpo X)."""
    return [(cx, cy + ry * cos(2 * pi * a / N), cz + rz * sin(2 * pi * a / N))
            for a in range(N)]


# ===================== 1) CUERPO (fusiforme horizontal) =====================
# Eje del cuerpo a lo largo de X. v5 (feedback usuario: "fusiona el cuello
# con la cabeza en una sola cosa"): el loft ES la cabeza — UNA malla
# continua cola->pecho->cuello->CRANEO que se contrae a la frente. La
# cabeza-deja-de-ser una esfera aparte: anatomia continua imposible de
# separar. El pico toma el relevo en la frente.
AN_CUERPO = [
    anillo(-0.24, 0.0, 0.35, 0.018, 0.018),   # punta de la cola
    anillo(-0.17, 0.0, 0.35, 0.042, 0.040),   # cola
    anillo(-0.04, 0.0, 0.35, 0.080, 0.072),   # abdomen
    anillo(+0.08, 0.0, 0.35, 0.095, 0.085),   # pecho (maximo)
    anillo(+0.14, 0.0, 0.355, 0.075, 0.068),  # hombros: arranque del cuello
    anillo(+0.18, 0.0, 0.368, 0.062, 0.056),  # cuello (tramo UNICO y corto)
    anillo(+0.23, 0.0, 0.38, 0.050, 0.046),   # base del craneo
    anillo(+0.27, 0.0, 0.382, 0.056, 0.052),  # CRANEO (se ensancha: la cabeza)
    anillo(+0.31, 0.0, 0.385, 0.048, 0.045),  # craneo medio (maximo redondez)
    anillo(+0.345, 0.0, 0.378, 0.028, 0.028), # frente (se contrae para el pico)
]
cuerpo_g = loft('SM_Gaviota_Cuerpo', AN_CUERPO, MAT_blanco)
# v9 (feedback usuario: "pinta la parte de arriba del torso de punta de
# ala a la otra punta" — v8 malinterpretó con barras aparte, quitadas):
# MANTO gris oscuro por ASIGNACION DE CARAS: las caras superiores del
# torso (normal.z > 0.35) desde la cola hasta los hombros (x < 0.16, el
# cuello/cabeza siguen blancas) llevan el slot 1 = MAT_manto. Desde
# arriba: punta negra -> ala perla -> DORSO GRIS OSCURO -> ala -> punta.
cuerpo_g.data.materials.append(MAT_manto)
for p in cuerpo_g.data.polygons:
    if p.normal.z > 0.35 and p.center.x < 0.16:
        p.material_index = 1

# ===================== 2) COLA (abanico corto, SOLDADA, NEGRA) =====================
# v11 (feedback usuario: "la colita pintala negra"): mismo negro de las
# puntas — cierra la franja oscura punta-a-punta tambien por atras.
caja('SM_Gaviota_Cola', -0.31, 0.0, 0.35, 0.18, 0.13, 0.018, MAT_negro,
     rot_euler=(0.0, radians(-4.0), 0.0))

# ===================== 3) PICO + OJOS (la cabeza YA ES el cuerpo) =====================
# v6: anclajes CALCULADOS sobre la geometria del loft (v5 quedaban a mano
# de mas: el pico 4 cm ARRIBA de la frente y los ojos FUERA de la elipse).
#   Frente: anillo x 0.345, centro z 0.378, ry 0.028/rz 0.028.
#   Craneo: anillo x 0.31, centro z 0.385, ry 0.048/rz 0.045.
# El pico nace con su TAPA enterrada en el eje de la frente: centro a
# x = 0.345 + (depth/2 - 0.015) hacia +X => la base queda 1.5 cm dentro.
# v7: anclaje del pico con to_track_quat (E-58). En v6 usaba Euler
# (X-10, Y90): el orden XYZ aplica la rot X en el frame ANTES del giro,
# lo que inclinaba el cono 10 grados hacia el COSTADO (de ahi el "pico
# mas abajo a la izquierda" del usuario). Direccion explicita: +X caido.
bpy.ops.mesh.primitive_cone_add(
    vertices=8, radius1=0.022, radius2=0.004, depth=0.10,
    location=(0.38, 0.0, 0.372))
pico = bpy.context.object
pico.name = 'SM_Gaviota_Pico'
_dir_pico = Vector((1.0, 0.0, -0.18)).normalized()
pico.rotation_euler = _dir_pico.to_track_quat('Z', 'Y').to_euler()
pico.data.materials.append(MAT_pico)

# Ojos TANGENTES a la elipse del craneo: punto de superficie con
# t = angulo parametrico ~50 grados (arriba-lateral). Formula elipse:
#   y = ry*cos(t), z = cz + rz*sin(t)
# con ry 0.048, rz 0.045, cz 0.385, t 50 deg -> y ±0.031, z 0.419.
# La esfera del ojo (r 0.011) queda 60% EMBEBIDA en la superficie.
from math import cos as _cos, sin as _sin
_t_ojo = radians(50.0)
for i, sy in enumerate((-1, +1)):
    y_o = 0.048 * _cos(_t_ojo) * sy
    z_o = 0.385 + 0.045 * _sin(_t_ojo)
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=10, ring_count=6, radius=0.011,
        location=(0.315, y_o, z_o))
    ojo = bpy.context.object
    ojo.name = 'SM_Gaviota_Ojo_%d' % i
    ojo.data.materials.append(MAT_negro)

# ===================== 4) ALAS (loft con pivote en el hombro) =====================
# Ala = malla loftada a lo largo de ±Y (hacia el costado de SU lado) desde
# el hombro (origen). Seccion = elipse HORIZONTAL (cuerda en X, espesor en
# Z — perfil aerodinamico). v7: el espejo entre lados es en el PROPIO
# loft (y_local * lado) — cero rotaciones que inviertan la cuerda (la
# rot Z 180 de v6 descentraba la punta negra del ala izquierda).
# Godot bate el ala con rotation.x local (pivote en el hombro).
def ala_ok(nombre, lado):
    bm = bmesh.new()
    N = 8
    PERFIL = [
        # (y_local, espesor, centro_cuerda, semicuerda) — cuerda en X
        (0.000, 0.030, -0.015, 0.045),
        (0.180, 0.026, -0.015, 0.070),
        (0.420, 0.020, -0.020, 0.085),
        (0.660, 0.014, -0.020, 0.070),
        (0.820, 0.006, -0.010, 0.030),
    ]
    rings = []
    for (y, esp, cc, rc) in PERFIL:
        ring = [bm.verts.new((cc + rc * cos(2 * pi * a / N), y * lado,
                              esp * sin(2 * pi * a / N)))
                for a in range(N)]
        rings.append(ring)
    caras = []
    for k in range(len(rings) - 1):
        for a in range(N):
            b = (a + 1) % N
            caras.append(bm.faces.new((rings[k][a], rings[k][b],
                                       rings[k + 1][b], rings[k + 1][a])))
    # tapas: hombro y punta
    for a in range(1, N - 1):
        caras.append(bm.faces.new((rings[0][0], rings[0][a], rings[0][a + 1])))
        caras.append(bm.faces.new((rings[-1][0], rings[-1][a + 1], rings[-1][a])))
    _isla(bm, caras)
    ob = _obj(nombre, bm, MAT_gris)
    # v10 (feedback usuario: "falto pintar la parte de ARRIBA de las alas
    # del gris oscuro"): multi-material en el ala — caras superiores
    # (normal.z > 0.3, el dorso del perfil) en MAT_manto, el resto perla.
    # Desde arriba: manto + alas oscuras continuas; desde abajo: perla.
    ob.data.materials.append(MAT_manto)
    for p in ob.data.polygons:
        if p.normal.z > 0.3:
            p.material_index = 1
    # v8 (feedback usuario: "metelas mas adentro del torso"): el hombro se
    # HUNDE 3 cm dentro del flanco (y ±0.05 < semiancho del torso 0.083)
    # — el ala EMERGE del cuerpo, imposible verla "separada".
    ob.rotation_euler = (0.0, 0.0, 0.0)
    if lado < 0:
        ob.location = (0.12, -0.05, 0.375)
    else:
        ob.location = (0.12, 0.05, 0.375)
    return ob


ala_ok('SM_Gaviota_Ala_L', -1)
ala_ok('SM_Gaviota_Ala_R', +1)

# ===================== 5) PUNTAS DE ALA (mancha negra) =====================
# Cuña negra en el extremo de cada ala (wingtip de gaviota adulta). Va
# SEPARADA para el material; Godot la re-parenta al ala para batir juntas.
# v8: puntas + borde de fuga negro: la linea oscura corre de punta a
# punta (wingtip -> borde de fuga -> torso -> borde de fuga -> wingtip).
for i, sy in enumerate((-1, +1)):
    caja('SM_Gaviota_Punta_%d' % i,
         0.10, sy * (0.05 + 0.80), 0.375,
         0.070, 0.11, 0.018, MAT_negro,
         rot_euler=(0.0, radians(-6.0), 0.0))

# ===================== 6) PATAS (plegadas al vientre) =====================
# Las gaviotas planean con las patas metidas bajo la cola: 2 conos cortos
# amarillos pegados al vientre (z 0.30), apuntando atras-abajo.
for i, sy in enumerate((-1, +1)):
    bpy.ops.mesh.primitive_cone_add(
        vertices=7, radius1=0.014, radius2=0.006, depth=0.09,
        location=(-0.05, sy * 0.045, 0.295))
    pata = bpy.context.object
    pata.name = 'SM_Gaviota_Pata_%d' % i
    from mathutils import Vector as _VP
    dir_p = _VP((-0.85, 0.0, -0.45)).normalized()
    pata.rotation_euler = dir_p.to_track_quat('Z', 'Y').to_euler()
    pata.data.materials.append(MAT_pata)

arena(radio=1.4)
iluminar(escena)
# NOTA: NO se llama asentar() — es un ave EN VUELO: el cuerpo vuela a
# z 0.35 sobre la arena del set. El z_min del GLB (~0.27 con patas) es
# la ALTURA DE VUELO para Godot, no un apoyo.
camara(escena, 'CAM_Gaviota', (1.3, -1.2, 1.0), (0.0, 0.0, 0.45))
shade_flat(escena)
guardar(escena, '36-Fauna', 'gaviota')

# -------- QA en caliente (E-33/E-40/E-70) --------
bpy.context.view_layer.update()
ps = [o for o in escena.objects if o.type == 'MESH' and o.name.startswith('SM_')]
tris = 0
for o in ps:
    o.data.calc_loop_triangles()
    tris += len(o.data.loop_triangles)
print('QA GAVIOTA: %d SM_ · %d tris reales · %d mats' % (
    len(ps), tris, len(set(m.name for o in ps for m in o.data.materials))))
assert len(ps) <= 16, 'E-70: %d objetos exceden el tope ALTA de 16' % len(ps)
assert tris <= 6000, 'presupuesto ALTA de tris excedido (%d)' % tris
