# crear_cabeza_alargada_lowpoly.py — M19 · Cabeza NPC variante B "ALARGADA"
#
# Perfil: ANCIANO SABIO (guardian del templo, abuelo del pueblo).
#   La senal de edad en lowpoly NO son las arrugas (no se ven a 6 m): es la
#   PROPORCION y el volumen de la barba.
#     * craneo ESTRECHO y ALTO: R = (0.118, 0.112, 0.166) — ratio alto:ancho
#       1.41 vs 1.00 de la variante redonda. Es el contraste que hace que las
#       dos cabezas se lean como personas distintas.
#     * craneo subido a z_abs 1.452: con rz=0.166 la base quedaria en 1.286,
#       apenas 4 mm sobre el cuello del cuerpo. A 1.440 (como el base) la
#       mandibula se clavaria en los hombros.
#     * BARBA LARGA colgando 12 cm por delante del cuello — va en +Y, donde
#       el torso no llega (verificacion abajo), asi que puede bajar a z 1.28.
#     * entradas: el pelo arranca mas atras y mas arriba (frente despejada).
#     * ojos chicos (r 0.030), cejas POBLADAS y gruesas (0.022 de alto).
#
# ASSET MONTADO (E-79/E-80). Origen local = base del cuello (z_abs 1.290).
#   LC(z_abs) = z_abs - 1.290   ·   YC(y_abs) = y_abs + 0.006
#
# Budget M166 ALTA: <=16 obj / <=6000 tris / <=12 mats. Esta: 7 SM_.

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from math import radians
from mathutils import Vector
import bpy

from plantilla_asset import limpiar, mat, loft, piezas
from montado_util import (construir_cabeza, verificar_cabeza, marcar_montado,
                          iluminar, camara, shade_flat, auditar, guardar,
                          aplicar, unir, aplicar_todos_sm, LC, YC)

escena = limpiar()

MATS = {
    'piel':    mat('MAT_CabB_Piel',    (0.80, 0.66, 0.54)),   # mas apagada
    'cabello': mat('MAT_CabB_Cabello', (0.86, 0.86, 0.82)),   # BLANCO
    'ojos':    mat('MAT_CabB_Ojos',    (0.15, 0.12, 0.10)),
    'boca':    mat('MAT_CabB_Boca',    (0.52, 0.35, 0.34)),
}

# Cuello MAS GRUESO que el de la variante redonda (0.060 vs 0.054). El cuello
# del anciano es mas nudoso: se ve el relieve porque la cabeza estrecha deja
# mas cuello expuesto.
CUELLO = [
    (-0.020, 0.0, YC(-0.012), 0.060, 0.054),
    ( 0.030, 0.0, YC(-0.013), 0.056, 0.051),
    ( 0.085, 0.0, YC(-0.013), 0.054, 0.049),
    ( 0.140, 0.0, YC(-0.013), 0.056, 0.051),
]

P = {
    'R_CRANEO':  (0.118, 0.112, 0.166),   # ESTRECHO y ALTO
    'Z_CRANEo':  1.452,
    # mandibula: avance 0.11 (menton marcado), estrechar 0.16 (se afina mucho:
    # la cara del anciano es un ovalo que termina en punta), plano 0.07.
    'MANDIBULA': (-0.28, 0.11, 0.16, 0.07),
    'NARIZ':     (0.022, 0.036, Vector((0.0, 0.92, -0.36))),   # mas larga
    'NARIZ_Y':   YC(0.080),
    'NARIZ_Z':   LC(1.414),
    'OREJA_R':   0.027,
    'OREJA_Y':   YC(-0.018),
    'OREJA_Z':   LC(1.384),
    'OJOS':      (0.030, 0.048, 1.452, 0.098),   # CHICOS
    'OJO_CHATO': 0.48,
    'CEJAS':     (0.068, 0.022, 0.020, 1.492, 6.0),   # POBLADAS (0.022 alto)
    'BOCA':      (0.052, 0.016, 0.014, 1.372),
    'MEJILLAS':  None,          # sin colorete: la barba ya da volumen
    'CUELLO':    CUELLO,
}

piezas_base = construir_cabeza(escena, P, MATS)

# ===========================================================================
# PELO — casquete con ENTRADAS (frente despejada, pelo ralo arriba)
# ===========================================================================
# Las entradas se logran con el anillo inferior RETRAIDO (cy muy negativo) y
# MAS ANGOSTO que el craneo: asi el pelo nace detras de la frente y deja ver
# la frente arrugada. Es la silueta de "anciano" sin una sola arruga modelada.
ANILLOS_PELO = [
    (LC(1.500), 0.0, YC(-0.030), 0.124, 0.084),   #arranca atras (entradas)
    (LC(1.552), 0.0, YC(-0.018), 0.132, 0.098),
    (LC(1.602), 0.0, YC(-0.006), 0.116, 0.094),
    (LC(1.636), 0.0, YC( 0.002), 0.060, 0.050),
]
cabello = loft('SM_Cab_Cabello', ANILLOS_PELO, MATS['cabello'], lados=14,
               tapar_arriba=True, tapar_abajo=False)

# --- Pelo de la NUCA: el casquete solo cubre arriba, pero el anciano tiene
# pelo hasta la nuca. Un segundo loft mas bajo y atras rellena ese hueco.
ANILLOS_NUCA = [
    (LC(1.330), 0.0, YC(-0.108), 0.088, 0.062),
    (LC(1.400), 0.0, YC(-0.112), 0.104, 0.072),
    (LC(1.470), 0.0, YC(-0.104), 0.112, 0.080),
    (LC(1.510), 0.0, YC(-0.080), 0.108, 0.078),
]
nuca = loft('SM_Cab_Nuca', ANILLOS_NUCA, MATS['cabello'], lados=12,
            tapar_arriba=False, tapar_abajo=True)

# ===========================================================================
# BARBA — loft que cuelga 12 cm por DELANTE del cuello
# ===========================================================================
# Verificacion de que NO choca con el torso (hecha sobre el cuerpo base v5):
#   a z=1.290 el cuello del cuerpo tiene cy=-0.012, ry=0.058 -> frente y=0.046
#   a z=1.245 la ultima seccion del trapecio tiene cy=-0.002, ry=0.092 -> 0.090
#   a z=1.165 el pecho tiene cy=+0.012, ry=0.132 -> frente y=0.144
# La barba termina en (y=0.112, z=1.292). En z=1.292 el cuerpo ya es cuello
# (frente y=0.046), asi que sobran 6.6 cm. No hay colision.
# La punta de la barba NO podria bajar a z=1.20: ahi el pecho llega a y=0.144
# y la barba quedaria DENTRO del pecho.
ANILLOS_BARBA = [
    (LC(1.292), 0.0, YC(0.112), 0.028, 0.024),   # punta (abajo-adelante)
    (LC(1.330), 0.0, YC(0.104), 0.044, 0.036),
    (LC(1.372), 0.0, YC(0.090), 0.056, 0.044),
    (LC(1.410), 0.0, YC(0.076), 0.062, 0.050),   # arranca bajo el menton
]
barba = loft('SM_Cab_Barba', ANILLOS_BARBA, MATS['cabello'], lados=12,
             tapar_arriba=False, tapar_abajo=True)

# --- Bigote: dos cajas anguladas bajo la nariz (el detalle que hace que la
# barba lea como "barba" y no como "papada") ---
bigote = []
for sx in (-1, +1):
    bpy.ops.mesh.primitive_cube_add(size=1.0,
                                    location=(sx * 0.028, YC(0.086),
                                              LC(1.394)))
    o = bpy.context.object
    o.scale = (0.048, 0.016, 0.016)
    o.rotation_euler = (0.0, sx * radians(-14.0), 0.0)
    o.data.materials.append(MATS['cabello'])
    bigote.append(o)

aplicar(barba)
for o in bigote:
    aplicar(o)
barba = unir('SM_Cab_Barba', [barba] + bigote)

# ===========================================================================
# CIERRE
# ===========================================================================
bpy.context.view_layer.update()
verificar_cabeza(escena, z_ojos_local=LC(P['OJOS'][2]))

marcar_montado()          # E-80
iluminar(escena)
# 3/4 frontal bajo: se ve la barba colgando y las entradas.
camara(escena, 'CAM_CABEZA_B', (0.48, -0.62, 0.22), (0.0, 0.0, 0.10))
shade_flat(escena)
auditar(escena)
guardar(escena, '19-NPCs', 'cabeza_alargada')
