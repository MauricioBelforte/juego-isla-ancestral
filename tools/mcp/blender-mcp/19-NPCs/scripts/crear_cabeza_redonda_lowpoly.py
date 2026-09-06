# crear_cabeza_redonda_lowpoly.py — M19 · Cabeza NPC variante A "REDONDA"
#
# Perfil: JOVEN ALEGRE (campesino aprendiz, muchacha del pueblo).
#   Craneo ancho y poco alto (ratio ancho:alto 1.00) -> cara de nene, la
#   variante mas "cozy" de las tres. Mandibula suave sin angulos, mejillas
#   llenas con colorete, ojos GRANDES (r 0.036 vs 0.032 del base), nariz
#   chica respingona. Pelo con flequillo tupido + coleta baja atras.
#
# ES UN ASSET MONTADO (E-79/E-80): no toca el suelo, no usa asentar().
#   Origen local = base del cuello del NPC base (z_abs 1.290).
#   En Godot se instancia como hijo del hueso/nodo de cuello-cabeza.
#
# Frame local (montado_util):
#   LC(z_abs) = z_abs - 1.290   ·   YC(y_abs) = y_abs + 0.006
#   Centro del craneo: z_abs 1.440 -> local 0.150
#
# Budget M166 §3.3 ALTA: <=16 obj / <=6000 tris / <=12 mats.
#   Esta cabeza: 7 SM_ (cabeza, cuello, cabello, coleta, ojos, cejas, boca).

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from math import radians, pi
from mathutils import Vector
import bpy

from plantilla_asset import limpiar, mat, loft, piezas
from montado_util import (construir_cabeza, verificar_cabeza, marcar_montado,
                          iluminar, camara, shade_flat, auditar, guardar,
                          aplicar, unir, aplicar_todos_sm, LC, YC)

escena = limpiar()

MATS = {
    'piel':    mat('MAT_CabA_Piel',    (0.85, 0.69, 0.55)),   # mas clara: joven
    'cabello': mat('MAT_CabA_Cabello', (0.35, 0.22, 0.13)),   # castano
    'ojos':    mat('MAT_CabA_Ojos',    (0.16, 0.13, 0.10)),
    'boca':    mat('MAT_CabA_Boca',    (0.58, 0.34, 0.32)),
    'cinta':   mat('MAT_CabA_Cinta',   (0.86, 0.42, 0.45)),   # coleta rosa
}

# ===========================================================================
# PARAMETROS DE LA VARIANTE "REDONDA"
# ===========================================================================
# Cuello mas FINO que el del anciano (0.048 vs 0.058): el grosor del cuello
# es una de las senales de edad mas fuertes en una silueta lowpoly.
# Los anillos van de z_local -0.020 (por debajo del punto de montaje, para
# que no quede hueco con el torso) hasta 0.110.
CUELLO = [
    (-0.020, 0.0, YC(-0.012), 0.054, 0.050),
    ( 0.030, 0.0, YC(-0.013), 0.050, 0.047),
    ( 0.080, 0.0, YC(-0.013), 0.048, 0.045),
    ( 0.130, 0.0, YC(-0.013), 0.050, 0.047),
]

P = {
    'R_CRANEO':  (0.142, 0.128, 0.142),   # ancho y poco alto: cara de nene
    'Z_CRANEo':  1.440,
    # (z_umbral, avance_y, estrechar_x, plano_z) — mandibula SUAVE:
    # avance 0.09 (menton apenas adelantado), estrechar 0.10 (casi no afina).
    'MANDIBULA': (-0.30, 0.09, 0.10, 0.05),
    'NARIZ':     (0.021, 0.026, Vector((0.0, 0.94, -0.30))),   # chica
    'NARIZ_Y':   YC(0.086),
    'NARIZ_Z':   LC(1.418),
    'OREJA_R':   0.025,
    'OREJA_Y':   YC(-0.016),
    'OREJA_Z':   LC(1.372),
    'OJOS':      (0.036, 0.052, 1.443, 0.104),   # GRANDES
    'OJO_CHATO': 0.52,
    'CEJAS':     (0.062, 0.016, 0.014, 1.483, 8.0),
    'BOCA':      (0.056, 0.018, 0.014, 1.398),
    'MEJILLAS':  (0.016, 0.084, 1.418, 0.086),   # colorete: cara llena
    'CUELLO':    CUELLO,
}

piezas_base = construir_cabeza(escena, P, MATS)

# ===========================================================================
# PELO — flequillo tupido + casquete + coleta baja
# ===========================================================================
# El casquete baja mas adelante que en el NPC base (cy 0.030 vs -0.040) para
# dar el flequillo: la frente queda cubierta hasta z_abs 1.468, o sea 1.5 cm
# POR ENCIMA de las cejas (1.483 - 0.008 = 1.475). Ajustado para que el
# flequillo ROCE las cejas sin taparlas — ese es el look "joven".
ANILLOS_PELO = [
    (LC(1.468), 0.0, YC(0.030), 0.150, 0.108),   # flequillo: baja y adelante
    (LC(1.520), 0.0, YC(0.020), 0.156, 0.118),
    (LC(1.572), 0.0, YC(0.010), 0.146, 0.114),
    (LC(1.612), 0.0, YC(0.000), 0.112, 0.098),
    (LC(1.638), 0.0, YC(-0.006), 0.052, 0.044),
]
cabello = loft('SM_Cab_Cabello', ANILLOS_PELO, MATS['cabello'], lados=14,
               tapar_arriba=True, tapar_abajo=False)

# --- Coleta baja: cono grueso cayendo por la nuca + cinta ---
# Parte de la nuca (y_local negativo, z_local ~0.20) y cae hacia atras-abajo.
# E-58: to_track_quat('Z','Y') alinea el eje +Z nativo del cono.
DIR_COLETA = Vector((0.0, -0.72, -0.69)).normalized()
H_COLETA = 0.150
BASE_COLETA = (0.0, YC(-0.118), LC(1.560))
bpy.ops.mesh.primitive_cone_add(
    vertices=7, radius1=0.052, radius2=0.020, depth=H_COLETA,
    location=tuple(BASE_COLETA[k] + DIR_COLETA[k] * H_COLETA / 2.0
                   for k in range(3)))
coleta = bpy.context.object
coleta.name = 'SM_Cab_Coleta'
coleta.rotation_euler = DIR_COLETA.to_track_quat('Z', 'Y').to_euler()
coleta.data.materials.append(MATS['cabello'])

# Cinta: toroide fino rodeando la base de la coleta. Un torus de 8x6 lados
# cuesta 96 tris y es la pieza que hace que la coleta lea como "atada".
bpy.ops.mesh.primitive_torus_add(
    major_segments=10, minor_segments=6, major_radius=0.046, minor_radius=0.011,
    location=tuple(BASE_COLETA[k] + DIR_COLETA[k] * 0.030 for k in range(3)))
cinta = bpy.context.object
cinta.name = 'SM_Cab_Cinta'
cinta.rotation_euler = DIR_COLETA.to_track_quat('Z', 'Y').to_euler()
cinta.data.materials.append(MATS['cinta'])

# E-75: aplicar antes de unir la cinta a la coleta (la coleta tiene escala
# unitaria pero rotacion propia; aplicar evita sorpresas al unir).
aplicar(coleta)
aplicar(cinta)
coleta = unir('SM_Cab_Coleta', [coleta, cinta])

# ===========================================================================
# CIERRE
# ===========================================================================
bpy.context.view_layer.update()
verificar_cabeza(escena, z_ojos_local=LC(P['OJOS'][2]))

marcar_montado()          # E-80: generar_variante.py NO debe re-asentar
iluminar(escena)
# Camara de 3/4 frontal: se ve la cara, el flequillo y la coleta.
camara(escena, 'CAM_CABEZA_A', (0.52, -0.60, 0.34), (0.0, 0.0, 0.15))
shade_flat(escena)
auditar(escena)
guardar(escena, '19-NPCs', 'cabeza_redonda')
