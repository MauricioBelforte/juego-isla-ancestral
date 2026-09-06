# crear_cabeza_cuadrada_lowpoly.py — M19 · Cabeza NPC variante C "CUADRADA"
#
# Perfil: ADULTO FORNIDO (pescador, herrero, lenador).
#   La senal de "fornido" es la MANDIBULA: ancha, casi tan ancha como el
#   craneo, con el menton cuadrado. En parametros:
#     * estrechar_x = 0.02  -> la mandibula NO se afina (la redonda usa 0.10,
#       la alargada 0.16). Es literalmente la diferencia entre "cara de nene"
#       y "cara de adulto".
#     * plano_z = 0.12      -> el tercio inferior se achata: menton cuadrado.
#     * craneo ANCHO: R = (0.146, 0.126, 0.150), ratio alto:ancho 1.03.
#     * cuello GRUESO (0.064 vs 0.054 de la redonda): cuello de trabajador.
#   Pelo corto y oscuro, barba de 3 dias (2 cm), cejas RECTAS y gruesas.
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
    'piel':    mat('MAT_CabC_Piel',    (0.78, 0.61, 0.47)),   # curtida: sol
    'cabello': mat('MAT_CabC_Cabello', (0.24, 0.17, 0.12)),   # negro
    'ojos':    mat('MAT_CabC_Ojos',    (0.13, 0.10, 0.08)),
    'boca':    mat('MAT_CabC_Boca',    (0.50, 0.32, 0.31)),
}

# Cuello GRUESO (0.064): es la senal de "fornido" mas barata en triangulos.
# Se ve porque la cabeza ancha deja menos cuello expuesto, asi que hay que
# exagerarlo para que no desaparezca detras de la mandibula.
CUELLO = [
    (-0.020, 0.0, YC(-0.012), 0.064, 0.058),
    ( 0.030, 0.0, YC(-0.013), 0.062, 0.056),
    ( 0.085, 0.0, YC(-0.013), 0.060, 0.055),
    ( 0.140, 0.0, YC(-0.013), 0.062, 0.056),
]

P = {
    'R_CRANEO':  (0.146, 0.126, 0.150),   # ANCHO, poco alto
    'Z_CRANEo':  1.446,
    # (z_umbral, avance_y, estrechar_x, plano_z)
    #   estrechar 0.02 -> mandibula ANCHA (casi no afina)
    #   plano     0.12 -> menton CUADRADO
    'MANDIBULA': (-0.26, 0.10, 0.02, 0.12),
    'NARIZ':     (0.024, 0.030, Vector((0.0, 0.93, -0.34))),   # ancha
    'NARIZ_Y':   YC(0.088),
    'NARIZ_Z':   LC(1.412),
    'OREJA_R':   0.028,
    'OREJA_Y':   YC(-0.016),
    'OREJA_Z':   LC(1.378),
    'OJOS':      (0.032, 0.054, 1.446, 0.102),
    'OJO_CHATO': 0.50,
    # Cejas RECTAS (angulo 2 grados vs 8 de la redonda) y gruesas (0.024):
    # la ceja arqueada lee amable, la recta lee serio/fuerte.
    'CEJAS':     (0.072, 0.024, 0.018, 1.486, 2.0),
    'BOCA':      (0.058, 0.016, 0.016, 1.380),   # boca ancha, recta
    'MEJILLAS':  None,                            # sin colorete
    'CUELLO':    CUELLO,
}

piezas_base = construir_cabeza(escena, P, MATS)

# ===========================================================================
# PELO CORTO — casquete pegado al craneo (sin volumen: pelo de trabajador)
# ===========================================================================
# A diferencia del anciano (entradas) y del joven (flequillo), aca el pelo
# sigue la linea del craneo casi sin sobresalir: rx apenas 4 mm por encima
# del craneo (0.146). El volumen lo da la mandibula, no el pelo.
ANILLOS_PELO = [
    (LC(1.462), 0.0, YC(-0.014), 0.150, 0.120),
    (LC(1.512), 0.0, YC(-0.008), 0.154, 0.126),
    (LC(1.562), 0.0, YC(-0.002), 0.146, 0.122),
    (LC(1.600), 0.0, YC( 0.004), 0.108, 0.094),
    (LC(1.622), 0.0, YC( 0.008), 0.052, 0.046),
]
cabello = loft('SM_Cab_Cabello', ANILLOS_PELO, MATS['cabello'], lados=14,
               tapar_arriba=True, tapar_abajo=False)

# --- Patillas: el pelo corto deja la sien desnuda y se ve el corte. Dos
# cajas finas bajando por delante de las orejas tapan esa costura. ---
patillas = []
for sx in (-1, +1):
    bpy.ops.mesh.primitive_cube_add(size=1.0,
                                    location=(sx * 0.128, YC(-0.030),
                                              LC(1.432)))
    o = bpy.context.object
    o.scale = (0.022, 0.040, 0.062)
    o.rotation_euler = (0.0, sx * radians(-8.0), 0.0)
    o.data.materials.append(MATS['cabello'])
    patillas.append(o)

# ===========================================================================
# BARBA DE 3 DIAS — sombra oscura sobre mandibula y menton
# ===========================================================================
# No es una barba modelada: es un cascaron 2 mm por fuera de la mandibula,
# con el mismo material del pelo. A la distancia de juego lee como sombra de
# barba y cuesta 60 triangulos. Un intento de modelar pelos individuales
# costaria mas que todo el NPC y no se veria.
ANILLOS_BARBA = [
    (LC(1.330), 0.0, YC(0.086), 0.096, 0.072),
    (LC(1.372), 0.0, YC(0.092), 0.122, 0.084),
    (LC(1.412), 0.0, YC(0.090), 0.132, 0.088),
    (LC(1.448), 0.0, YC(0.084), 0.126, 0.086),
]
barba = loft('SM_Cab_Barba', ANILLOS_BARBA, MATS['cabello'], lados=12,
             tapar_arriba=False, tapar_abajo=True)

for o in patillas:
    aplicar(o)
aplicar(barba)
barba = unir('SM_Cab_Barba', [barba] + patillas)

# ===========================================================================
# CIERRE
# ===========================================================================
bpy.context.view_layer.update()
verificar_cabeza(escena, z_ojos_local=LC(P['OJOS'][2]))

marcar_montado()          # E-80
iluminar(escena)
camara(escena, 'CAM_CABEZA_C', (0.50, -0.58, 0.30), (0.0, 0.0, 0.14))
shade_flat(escena)
auditar(escena)
guardar(escena, '19-NPCs', 'cabeza_cuadrada')
