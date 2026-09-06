# crear_npc_sentado_lowpoly.py — M19 · NPC sentado (pose para diálogo)
#
# Perfil: ANCIANO SABIO EN MEDITACION. Sentado sobre una piedra de rio,
# piernas cruzadas, manos apoyadas sobre las rodillas, mirada al frente.
# Pose estatica (no animada): pensada para escenas de dialogo donde el
# NPC esta en su "trono" natural.
#
# Asset STANDALONE (no es montado): tiene su propio cuerpo en pose sentada
# + piedra que lo sostiene. En Godot se instancia como nodo raiz de la
# entidad (no como hijo del NPC base).
#
# Componentes:
#   1) SM_Sent_Piedra  — piedra aplanada sobre la arena (apoyo, E-12)
#   2) SM_Sent_Tronco  — tronco ligeramente curvado, piel (sentado)
#   3) SM_Sent_Cadera  — cubre la zona de la pelvis sentada
#   4) SM_Sent_Piernas — piernas cruzadas al frente (X-over)
#   5) SM_Sent_Brazos  — brazos apoyados sobre las rodillas
#   6) SM_Sent_Cuello  — cuello que une con la cabeza
#   7) SM_Sent_Cabeza  — craneo (variante "anciano": alargada)
#   8) SM_Sent_Cabello — pelo blanco corto + barba
#   9) SM_Sent_Ojos    — ojos (estan dentro de la cabeza)
#  10) SM_Sent_Capona  — pequeno casquete sobre la cabeza
#
# Budget M166 ALTA: <=16 obj / <=6000 tris / <=12 mats.
# Estimado: ~10 SM_, ~2500 tris, ~5 mats.

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from math import radians, pi, cos, sin
from mathutils import Vector
import bpy, bmesh

from plantilla_asset import (limpiar, mat, loft, caja, piezas, polilinea,
                            asentar, zmin_real)
from montado_util import (iluminar, camara, shade_flat, auditar, guardar,
                          aplicar, unir, aplicar_todos_sm,
                          construir_cabeza, marcar_montado,
                          BRAZOS, PIERNAS, dx, _interpolar,
                          ANILLOS_TORSO,
                          LC, YC)

escena = limpiar()

MATS = {
    'piel':    mat('MAT_Sent_Piel',    (0.82, 0.65, 0.52)),
    'cabello': mat('MAT_Sent_Cabello', (0.78, 0.74, 0.66)),   # canoso (anciano)
    'pelo':    mat('MAT_Sent_Pelo',    (0.78, 0.74, 0.66)),   # alias de cabello
    'ojos':    mat('MAT_Sent_Ojos',    (0.15, 0.12, 0.09)),
    'boca':    mat('MAT_Sent_Boca',    (0.58, 0.36, 0.30)),
    'piedra':  mat('MAT_Sent_Piedra',  (0.45, 0.42, 0.38)),
    'lino':    mat('MAT_Sent_Lino',    (0.62, 0.55, 0.42)),   # tunic del sabio
    'cordon':  mat('MAT_Sent_Cordon',   (0.45, 0.38, 0.24)),   # cordon amarillo
}

# ===========================================================================
# 1) PIEDRA — apoyo donde se sienta el NPC (E-12, E-50)
# ===========================================================================
# Piedra aplanada: 60 cm de diametro, 18 cm de alto. Top en z=0.18. La
# piedra es la que se asienta sobre la arena; el NPC va sobre la piedra.
bpy.ops.mesh.primitive_cylinder_add(vertices=18, radius=0.32, depth=0.18,
                                     location=(dx(0.09), 0.0, 0.09))
piedra = bpy.context.object
piedra.name = 'SM_Sent_Piedra'
piedra.data.materials.append(MATS['piedra'])
aplicar(piedra)
# La piedra esta EXENTRICA (lado izq del eje), pero apoyada en arena. El
# centro de masa esta en x=dx(0.09)≈-0.018, la huella es un disco de 64cm
# de diametro, pasa E-50 (>8 verts tocando, footprint>30cm).

# ===========================================================================
# 2) TRONCO — ligeramente curvado, posicion sentado
# ===========================================================================
# Posicion sentado: cadera en z=0.30 (sobre la piedra), tronco erecto
# desde la cadera hasta los hombros en z=0.95. Sin piernas visibles (estan
# dobladas, las modelamos aparte).
ANILLOS_TRONCO = [
    (0.300, dx(0.300),  0.000, 0.230, 0.180),   # cadera (sobre la piedra)
    (0.450, dx(0.450), -0.005, 0.215, 0.165),   # cadera baja
    (0.600, dx(0.600), -0.005, 0.198, 0.150),   # cintura
    (0.750, dx(0.750), -0.003, 0.215, 0.158),   # pecho bajo
    (0.900, dx(0.900),  0.005, 0.220, 0.155),   # pecho
    (1.000, dx(1.000),  0.000, 0.165, 0.130),   # hombro
    (1.050, dx(1.050), -0.005, 0.110, 0.090),   # cuello bajo
    (1.100, dx(1.100), -0.010, 0.075, 0.065),   # cuello
]
tronco = loft('SM_Sent_Tronco', ANILLOS_TRONCO, MATS['piel'],
              lados=14, tapar_arriba=False, tapar_abajo=True)

# ===========================================================================
# 3) CADERA — cubre la pelvis sentada (mas pequena que el tronco)
# ===========================================================================
ANILLOS_CADERA_SENT = [
    (0.280, dx(0.280),  0.000, 0.220, 0.170),
    (0.400, dx(0.400), -0.003, 0.205, 0.160),
    (0.500, dx(0.500), -0.005, 0.190, 0.150),
]
cadera = loft('SM_Sent_Cadera', ANILLOS_CADERA_SENT, MATS['piel'],
              lados=12, tapar_arriba=False, tapar_abajo=True)

# ===========================================================================
# 3) TUNICA — lino claro sobre el tronco, hasta donde arrancan las piernas
# ===========================================================================
# No es la pieza premium de la túnica del anciano (esa esta aparte). Es
# un DELANTAL/FAJA amplia que cuelga sobre las piernas cruzadas, leyendo
# como "monje en ropaje". Cubre el tronco desde los hombros hasta el regazo.
ANILLOS_TUNICA_SENT = [
    (0.180, dx(0.180),  0.000, 0.270, 0.220),   # base sobre el regazo
    (0.300, dx(0.300), -0.005, 0.260, 0.200),   # cadera
    (0.450, dx(0.450), -0.005, 0.245, 0.185),   # cadera baja
    (0.600, dx(0.600), -0.005, 0.225, 0.170),   # cintura
    (0.750, dx(0.750), -0.003, 0.240, 0.178),   # pecho bajo
    (0.900, dx(0.900),  0.005, 0.245, 0.175),   # pecho
    (1.000, dx(1.000),  0.000, 0.190, 0.150),   # hombro
]
tunica = loft('SM_Sent_Tunica', ANILLOS_TUNICA_SENT, MATS['lino'],
              lados=14, tapar_arriba=False, tapar_abajo=True)

# Cordon a la cintura (torus horizontal a z=0.60)
bpy.ops.mesh.primitive_torus_add(major_segments=12, minor_segments=5,
                                 major_radius=0.235, minor_radius=0.008,
                                 location=(dx(0.600), 0.0, 0.600))
cordon = bpy.context.object
cordon.name = 'SM_Sent_Cordon'
cordon.data.materials.append(MATS['cordon'])

# ===========================================================================
# 4) PIERNAS CRUZADAS — 2 tubos al frente, cruzados al nivel del tobillo
# ===========================================================================
# Posicion: cada pierna sale de la cadera (z=0.30) hacia el frente (+Y).
# Al nivel de la rodilla (z=0.18) se cruzan: la I va al lado D y la D al I.
# Longitud: 50 cm. Quedan HORIZONTALES sobre la piedra (no cuelgan).
PIERNA_SENT_I = [                                    # sale izq, va al lado der
    (-0.115, -0.005, 0.300),
    (-0.110,  0.080, 0.200),
    (-0.050,  0.180, 0.180),
    ( 0.040,  0.270, 0.175),
    ( 0.110,  0.320, 0.175),
]
PIERNA_SENT_D = [                                    # sale der, va al lado izq
    ( 0.115,  0.005, 0.300),
    ( 0.110,  0.090, 0.210),
    ( 0.050,  0.190, 0.190),
    (-0.040,  0.280, 0.185),
    (-0.110,  0.330, 0.185),
]
# Radios: cadera 0.10 -> rodilla 0.085 -> tobillo 0.060 (afinadas)
R_PIERNA_SENT = (0.105, 0.095, 0.080, 0.068, 0.055)

piernas = []
for lado, pts in (('I', PIERNA_SENT_I), ('D', PIERNA_SENT_D)):
    anillos = [(p[2], p[0], p[1], R_PIERNA_SENT[i], R_PIERNA_SENT[i])
               for i, p in enumerate(pts)]
    anillos.reverse()                                # tobillo -> cadera
    piernas.append(loft('SM_Sent_Pierna_' + lado, anillos,
                        MATS['piel'], lados=10,
                        tapar_arriba=True, tapar_abajo=False))

piernas = unir('SM_Sent_Piernas', piernas)

# ===========================================================================
# 5) BRAZOS — apoyados sobre las rodillas, codos en y=0.18
# ===========================================================================
# Los brazos salen del hombro (x=±0.18, z=1.00), bajan al codo en y=0.18,
# z=0.50 (apoyado sobre la rodilla), y la muneca llega a la rodilla.
BRAZO_SENT_I = [
    (-0.180, -0.005, 1.000),
    (-0.200,  0.060, 0.800),
    (-0.180,  0.150, 0.500),
    (-0.110,  0.220, 0.250),
    (-0.080,  0.250, 0.180),
]
BRAZO_SENT_D = [
    ( 0.180,  0.005, 1.000),
    ( 0.200,  0.070, 0.800),
    ( 0.180,  0.160, 0.500),
    ( 0.110,  0.230, 0.250),
    ( 0.080,  0.260, 0.180),
]
R_BRAZO_SENT = (0.058, 0.052, 0.046, 0.040, 0.036)

brazos = []
for lado, pts in (('I', BRAZO_SENT_I), ('D', BRAZO_SENT_D)):
    anillos = [(p[2], p[0], p[1], R_BRAZO_SENT[i], R_BRAZO_SENT[i])
               for i, p in enumerate(pts)]
    anillos.reverse()                                # muneca -> hombro
    brazos.append(loft('SM_Sent_Brazo_' + lado, anillos,
                       MATS['piel'], lados=8,
                       tapar_arriba=True, tapar_abajo=False))

brazos = unir('SM_Sent_Brazos', brazos)

# ===========================================================================
# 6) CABEZA — variante "anciano alargado" en posicion sentada (z_ref=1.10)
# ===========================================================================
# construir_cabeza() usa el frame local (z_local=0 -> z_abs=1.290, pero
# aqui el cuello esta en z_abs=1.10). Creamos un Empty que compensa el
# offset de modo que LC() devuelva la altura absoluta correcta.
# Truco: temporalmente cambiamos Z_REF_CABEZA para esta cabeza.

from montado_util import Z_REF_CABEZA
import montado_util
montado_util.Z_REF_CABEZA = 1.100             # el cuello esta en z=1.10

CUELLO_SENT = [
    (-0.020, 0.0, YC(-0.012), 0.062, 0.058),     # cuello del anciano (mas grueso)
    ( 0.030, 0.0, YC(-0.013), 0.058, 0.054),
    ( 0.080, 0.0, YC(-0.013), 0.056, 0.052),
    ( 0.130, 0.0, YC(-0.013), 0.060, 0.054),
]
P = {
    'R_CRANEO':  (0.140, 0.130, 0.155),    # alargado (anciano)
    'Z_CRANEo':  1.250,                     # clave CON 'o' minuscula (montado_util)
    'MANDIBULA': (-0.30, 0.07, 0.13, 0.05),
    'NARIZ':     (0.020, 0.026, Vector((0.0, 0.94, -0.30))),
    'NARIZ_Y':   YC(0.086),
    'NARIZ_Z':   LC(1.228),
    'OREJA_R':   0.026,
    'OREJA_Y':   YC(-0.016),
    'OREJA_Z':   LC(1.182),
    'OJOS':      (0.034, 0.052, 1.253, 0.104),
    'OJO_CHATO': 0.55,
    'CEJAS':     (0.064, 0.018, 0.014, 1.293, 8.0),
    'BOCA':      (0.054, 0.018, 0.014, 1.208),
    'MEJILLAS':  (0.012, 0.080, 1.228, 0.082),
    'CUELLO':    CUELLO_SENT,
}
piezas_cabeza = construir_cabeza(escena, P, MATS)

# E-90 (2026-09-04, NPC sentado M19): construir_cabeza() devuelve la cabeza
# en el FRAME LOCAL del punto de montaje (z_local 0 = base del cuello). En un
# asset MONTADO eso esta bien: el padre aporta el offset al instanciarlo. Pero
# el NPC sentado es STANDALONE (no hay padre que lo traslade), asi que hay que
# subir las piezas a mano +Z_REF_CABEZA. Sin esto la cabeza nacia en
# z -0.02..0.50 (a la altura de la cadera) y solo el pelo —autorado en cotas
# absolutas— aparecia arriba: la silueta quedaba descabezada y el guard de
# asentado reportaba z_min -0.020 en vez de 0.045.
OFFSET_CABEZA = 1.100                       # = montado_util.Z_REF_CABEZA
for _k, p in piezas_cabeza.items():
    p.location.z += OFFSET_CABEZA
    if p.name.startswith('SM_Cab_'):
        p.name = 'SM_Sent_' + p.name[len('SM_Cab_'):]
bpy.context.view_layer.update()

# Guard E-90: la cabeza ya ubicada DEBE quedar por encima del tronco. Si el
# offset no se aplico, el craneo cae a la altura de la cadera y la silueta
# queda descabezada sin tirar ningun error (fallo silencioso real).
_z_cab = min((piezas_cabeza['cabeza'].matrix_world @ v.co).z
             for v in piezas_cabeza['cabeza'].data.vertices)
assert _z_cab > 1.05, (
    'E-90: la cabeza arranca en z=%.4f, por debajo del cuello (1.10). '
    'Falta el OFFSET_CABEZA que pasa el frame local de montaje a mundo.'
    % _z_cab)
print('CABEZA ubicada: z_min %.4f (offset +%.3f aplicado)'
      % (_z_cab, OFFSET_CABEZA))

# ===========================================================================
# 7) PELO + BARBA — pelo blanco del sabio
# ===========================================================================
# Casquete de pelo encima del craneo + barba colgando bajo el menton.
# Usamos bmesh directo.
def construir_pelo_anciano(nombre='SM_Sent_Cabello', material=None):
    bm = bmesh.new()
    # Casquete sobre el craneo: media esfera superior
    APEX = pi / 2.0                                    # +Y (frente)
    cfg = [
        (1.240, 0.140, 2.0 * pi / 3,   12),   # base (no cubre la cara)
        (1.290, 0.135, 2.0 * pi / 3,   10),
        (1.330, 0.115, pi / 2,         8),
        (1.360, 0.080, pi / 3,         6),
        (1.380, 0.040, pi / 6,         4),
    ]
    capas = []
    for (z, r, alpha, n) in cfg:
        capa = []
        # Apex = +Y (3*pi/2 NO, +Y es pi/2). Pero la cara esta en +Y, no
        # queremos pelo en y > 0.05. Lo centramos en -Y (atras, 3pi/2) para
        # que el pelo arranque desde el craneo y NO llegue a la frente.
        APEX_HALLO = 3.0 * pi / 2.0
        for i in range(n):
            tfrac = i / (n - 1) if n > 1 else 0.0
            a = APEX_HALLO - alpha + 2.0 * alpha * tfrac
            capa.append(bm.verts.new((r * cos(a), r * sin(a), z)))
        capas.append(capa)
    for k in range(len(capas) - 1):
        a, b = capas[k], capas[k + 1]
        n_comun = min(len(a), len(b))
        for i in range(n_comun - 1):
            bm.faces.new((a[i], a[i + 1], b[i + 1], b[i]))
        if len(b) < len(a):
            bm.faces.new((a[n_comun - 1], a[n_comun], b[-1], b[0]))
    v_c = bm.verts.new(
        (0.0,
         sum(v.co.y for v in capas[-1]) / len(capas[-1]),
         sum(v.co.z for v in capas[-1]) / len(capas[-1])))
    for i in range(len(capas[-1]) - 1):
        bm.faces.new((v_c, capas[-1][i], capas[-1][i + 1]))
    bm.normal_update()
    malla = bpy.data.meshes.new(nombre)
    bm.to_mesh(malla)
    bm.free()
    o = bpy.data.objects.new(nombre, malla)
    bpy.context.scene.collection.objects.link(o)
    o.data.materials.append(material)
    return o


pelo = construir_pelo_anciano('SM_Sent_Cabello', MATS['pelo'])

# Barba: prisma colgante bajo la mandibula
# Posicion: menton en (dx(1.21), 0.075, 1.21), barba hasta z=1.08 (13cm)
ANILLOS_BARBA = [
    (1.080, dx(1.080),  0.080, 0.058, 0.020),   # punta
    (1.100, dx(1.100),  0.080, 0.072, 0.030),
    (1.140, dx(1.140),  0.075, 0.080, 0.040),
    (1.180, dx(1.180),  0.060, 0.075, 0.045),   # arranque (siguiendo menton)
]
barba = loft('SM_Sent_Barba', ANILLOS_BARBA, MATS['pelo'],
             lados=10, tapar_arriba=True, tapar_abajo=False)

# Ceja/bigote opcional — nos ahorramos, ya esta la barba

# ===========================================================================
# CIERRE
# ===========================================================================
aplicar_todos_sm()

# El NPC esta SOBRE la piedra (z=0.18). El guard E-12/E-50 aplica: la
# piedra es el apoyo, NO la arena. Pero el GUARD DE PIE (asentar) esta
# pensado para assets de pie. Para sentado, hacemos un asentar MANUAL
# que asegure que la piedra este en Z_APOYO sobre la arena.

# Piedra: asentar
bpy.context.view_layer.update()
z_piedra = zmin_real(piedra)
delta = 0.045 - z_piedra
piedra.location.z += delta
bpy.context.view_layer.update()
print('ASENTADO PIEDRA: z %.4f -> %.4f' % (z_piedra, zmin_real(piedra)))
print('Piedra diametro ~%.0f cm, alto 18 cm' % (0.32 * 2 * 100))

iluminar(escena)
camara(escena, 'CAM_SENTADO', (1.30, 2.00, 1.10), (0.0, 0.0, 0.65))
shade_flat(escena)
auditar(escena)
guardar(escena, '19-NPCs', 'npc_sentado')