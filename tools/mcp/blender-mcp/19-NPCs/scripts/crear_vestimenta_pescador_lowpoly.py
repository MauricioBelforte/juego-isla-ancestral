# crear_vestimenta_pescador_lowpoly.py — M19 · Vestimenta de pescador (M19)
#
# Perfil: PESCADOR (mariscador, pescador de costa). Asset MONTADO (E-79):
# se AUTORA en cotas de mundo (z_ref_ropa = 0) y se renderea ENCIMA del
# cuerpo del NPC base. Cuando un NPC viste esta vestimenta, en Godot se
# ocultan los SM_NPC_RopaBase / SM_NPC_Torso del NPC base y se instancia
# este GLB como hijo del nodo raiz.
#
# Componentes:
#   1) Chaqueton de lona encerada  (0.80 a 1.30) — loden, con cuello alto
#   2) Mangas enrolladas al codo   (1.150 a 0.905) — antebrazos al aire
#   3) Cinturon de cuero sobre el chaqueton  (torus en 0.88)
#   4) Hebilla de metal delante del cinturon
#   5) Cadera del pantalon         (0.70 a 0.95, oculto bajo el chaqueton)
#   6) Perneras                    (0.115 a 0.720)
#   7) Botas altas de agua         (0.045 a 0.55) — caucho, rodilla
#
# E-73/E-74: el cinturon es horizontal, PERO va sobre la cintura (costura
#   natural, no perpendicular al pecho). La hebilla es una caja plana en
#   el frente, no un cilindro horizontal que sobresalga.
#
# E-89: cada pieza declara contra que partes del cuerpo se audita. Las
#   botas y perneras solo contra piernas; el chaqueton solo contra torso
#   y deltoides; las mangas solo contra brazos y deltoides.
#
# E-87: tapas OCULTO en chaqueton (cuello), mangas (hombro), cadera
#   (cintura y tiro), perneras (tobillo) y botas (rodilla).
#
# Budget M166 ALTA: <=16 obj / <=6000 tris / <=12 mats. Esta: 7 SM_,
# 5 mats.

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from math import radians
from mathutils import Vector
import bpy, bmesh

from plantilla_asset import limpiar, mat, loft, caja, piezas, polilinea
from montado_util import (maniqui_cuerpo, verificar_ropa, marcar_montado,
                          iluminar, camara, shade_flat, auditar, guardar,
                          aplicar, unir, aplicar_todos_sm,
                          Z_REF_ROPA, BRAZOS, PIERNAS, dx, _interpolar,
                          ANILLOS_TORSO, marcar_ocultos)

escena = limpiar()

MATS = {
    'lona':      mat('MAT_Pesc_Lona',     (0.18, 0.22, 0.16)),    # loden
    'pant':      mat('MAT_Pesc_Pantalon', (0.35, 0.27, 0.19)),    # faena
    'goma':      mat('MAT_Pesc_Goma',     (0.10, 0.08, 0.06)),    # caucho
    'cuero':     mat('MAT_Pesc_Cuero',    (0.25, 0.17, 0.10)),    # cinturon
    'metal':     mat('MAT_Pesc_Metal',    (0.55, 0.50, 0.42)),    # hebilla
}


def centro_de_tapa(punto, tol=0.010):
    """Predicado: el vertice es el CENTRO de la tapa de un tubo cerrado (E-87)."""
    p = Vector(punto)

    def _pred(w):
        return (w - p).length < tol
    return _pred


# ===========================================================================
# 1) CHAQUETON — lona encerada loden (0.80 a 1.30), con cuello alto
# ===========================================================================
# Cada anillo es torso + ~12..20 mm de tela. En el hombro el deltoide
# manda (rx >= 0.224 en z 1.13..1.20). Largo: cadera (hem a 0.80, debajo
# de la cintura 0.96).
ANILLOS_CHAQUETON = [
    (0.800, dx(0.800),  0.000, 0.204, 0.140),   # hem (sobre la cadera)
    (0.860, dx(0.860), -0.005, 0.214, 0.150),
    (0.960, dx(0.960), -0.008, 0.188, 0.135),   # cintura (angosta)
    (1.050, dx(1.050), -0.003, 0.186, 0.132),
    (1.130, dx(1.130),  0.009, 0.224, 0.146),   # sube al hombro
    (1.150, dx(1.150),  0.011, 0.232, 0.146),   # hombro
    (1.175, dx(1.175),  0.013, 0.236, 0.146),
    (1.200, dx(1.200),  0.010, 0.226, 0.144),
    (1.245, dx(1.245), -0.002, 0.152, 0.108),   # trapecio
    (1.275, dx(1.275), -0.008, 0.108, 0.084),   # base del cuello
    (1.300, dx(1.300), -0.012, 0.082, 0.074),   # cuello alto (cerrado)
]
chaqueton = loft('SM_Pesc_Chaqueton', ANILLOS_CHAQUETON, MATS['lona'],
                 lados=14, tapar_arriba=True, tapar_abajo=False)

# ===========================================================================
# 2) MANGAS enrolladas al codo (hombro 1.150 -> codo 0.905)
# ===========================================================================
# Misma estructura que la campesina pero usando solo el segmento
# hombro-codo de BRAZOS y dejando el codo ABIERTO (puño enrollado).
def construir_mangas_codo(prefijo, ts, radios, mat_prenda, lados=8):
    """Mangas del chaqueton: solo hombro -> codo, abiertas abajo."""
    hechas = []
    for lado in ('I', 'D'):
        pts = [BRAZOS[lado][0], BRAZOS[lado][1]]     # hombro, codo
        muestras = polilinea(pts, ts)
        anillos = [(muestras[i][2], muestras[i][0], muestras[i][1],
                    radios[i], radios[i]) for i in range(len(muestras))]
        anillos.reverse()                             # codo -> hombro
        hechas.append(loft(prefijo + '_Brazo_' + lado, anillos,
                           mat_prenda, lados=lados,
                           tapar_arriba=True, tapar_abajo=False))
    return hechas


mangas = construir_mangas_codo(
    'SM_Pesc_Manga', (0.0, 0.5, 1.0),
    (0.095, 0.087, 0.094), MATS['lona'])             # hombro, medio, codo

# ===========================================================================
# 3) CINTURON — torus horizontal a la altura de la cintura del chaqueton
# ===========================================================================
# primitive_torus_add() ya es horizontal (E-85). Va sobre el chaqueton, por
# fuera del hem (el chaqueton en z=0.88 tiene rx ~0.207 -> el cinturon con
# radio interior 0.215 sobresale 8 mm y se VE como cinturon aparte).
bpy.ops.mesh.primitive_torus_add(major_segments=14, minor_segments=6,
                                 major_radius=0.227, minor_radius=0.012,
                                 location=(dx(0.880), -0.005, 0.880))
cinturon = bpy.context.object
cinturon.name = 'SM_Pesc_Cinturon'
cinturon.data.materials.append(MATS['cuero'])

# ===========================================================================
# 4) HEBILLA — caja plana delante del cinturon (+Y)
# ===========================================================================
# E-74: NO un cilindro horizontal sobresaliendo del pecho. Es una caja
# PLANA contra el abdomen: ancho 6 cm, alto 4 cm, grosor 8 mm.
hebilla = caja('SM_Pesc_Hebilla', 0.0, 0.220, 0.880,
               0.060, 0.008, 0.040, MATS['metal'])

# ===========================================================================
# 5) CADERA del pantalon — un solo tubo que envuelve las dos piernas
# ===========================================================================
# Cubre 0.70..0.95. La parte 0.80..0.95 queda BAJO el chaqueton (la
# cintura es invisible). El tiro cierra abajo con un disco (oculto bajo
# las perneras).
ANILLOS_CADERA = [
    (0.700, dx(0.700),  0.000, 0.212, 0.140),
    (0.790, dx(0.790), -0.003, 0.212, 0.140),
    (0.880, dx(0.880), -0.007, 0.198, 0.134),
    (0.950, dx(0.950), -0.008, 0.166, 0.118),
]
cadera = loft('SM_Pesc_Cadera', ANILLOS_CADERA, MATS['pant'], lados=12,
              tapar_arriba=True, tapar_abajo=True)

# ===========================================================================
# 6) PERNERAS — 0.115 a 0.720, arrancan dentro de la cadera
# ===========================================================================
PIERNAS_VEST = {
    'I': [(-0.1013, -0.0020, 0.720), (-0.1005,  0.0000, 0.600),
          (-0.1002,  0.0027, 0.450), (-0.1000,  0.0090, 0.300),
          (-0.1000,  0.0120, 0.115)],
    'D': [( 0.1023,  0.0180, 0.720), ( 0.1020,  0.0220, 0.600),
          ( 0.1006,  0.0354, 0.450), ( 0.1000,  0.0460, 0.300),
          ( 0.1000,  0.0520, 0.115)],
}
R_PERNERA = (0.1087, 0.1037, 0.0926, 0.0820, 0.0680)

perneras = []
for lado in ('I', 'D'):
    pts = PIERNAS_VEST[lado]
    anillos = [(pts[i][2], pts[i][0], pts[i][1],
                R_PERNERA[i], R_PERNERA[i]) for i in range(len(pts))]
    anillos.reverse()
    perneras.append(loft('SM_Pesc_Pernera_' + lado, anillos, MATS['pant'],
                         lados=10, tapar_abajo=True, tapar_arriba=False))

# ===========================================================================
# 7) BOTAS ALTAS — caucho, de la rodilla (0.55) al pie (0.045)
# ===========================================================================
# Cerradas arriba (tapa OCULTO, tapadas por el pantalon) y abajo (suela
# apoyada en la arena). Sigue el eje de la pierna con radio +20..24 mm.
PIERNAS_BOTA = {
    'I': [(-0.1010, -0.0010, 0.550), (-0.1008,  0.0010, 0.450),
          (-0.1003,  0.0050, 0.300), (-0.1000,  0.0090, 0.115),
          (-0.1000,  0.0120, 0.045)],
    'D': [( 0.1017,  0.0170, 0.550), ( 0.1010,  0.0270, 0.450),
          ( 0.1005,  0.0380, 0.300), ( 0.1000,  0.0460, 0.115),
          ( 0.1000,  0.0520, 0.045)],
}
R_BOTA = (0.094, 0.098, 0.092, 0.082, 0.062)

botas = []
for lado in ('I', 'D'):
    pts = PIERNAS_BOTA[lado]
    anillos = [(pts[i][2], pts[i][0], pts[i][1],
                R_BOTA[i], R_BOTA[i]) for i in range(len(pts))]
    anillos.reverse()
    botas.append(loft('SM_Pesc_Bota_' + lado, anillos, MATS['goma'],
                       lados=10, tapar_arriba=True, tapar_abajo=True))

# ===========================================================================
# CIERRE
# ===========================================================================
aplicar_todos_sm()

# E-87: tapas marcadas OCULTO
marcar_ocultos(chaqueton, centro_de_tapa((dx(1.300), -0.012, 1.300)))   # cuello
marcar_ocultos(mangas[0], centro_de_tapa(BRAZOS['I'][0]))              # hombro
marcar_ocultos(mangas[1], centro_de_tapa(BRAZOS['D'][0]))
marcar_ocultos(cadera, centro_de_tapa((dx(0.950), -0.008, 0.950)))     # cintura
marcar_ocultos(cadera, centro_de_tapa((dx(0.700), 0.000, 0.700)))      # tiro
marcar_ocultos(perneras[0], centro_de_tapa(PIERNAS_VEST['I'][-1]))     # tobillo
marcar_ocultos(perneras[1], centro_de_tapa(PIERNAS_VEST['D'][-1]))
marcar_ocultos(botas[0], centro_de_tapa((PIERNAS_BOTA['I'][0][0],
                                         PIERNAS_BOTA['I'][0][1],
                                         PIERNAS_BOTA['I'][0][2])))     # rodilla
marcar_ocultos(botas[1], centro_de_tapa(PIERNAS_BOTA['D'][0]))

# Mangas, perneras y botas se unen para no disparar el presupuesto SM_
mangas = unir('SM_Pesc_Mangas', mangas)
perneras = unir('SM_Pesc_Pantalones', perneras)
botas = unir('SM_Pesc_Botas', botas)

maniqui_cuerpo(escena)
bpy.context.view_layer.update()

# E-89: contra que partes del cuerpo se audita cada pieza
PARTES = {
    'SM_Pesc_Chaqueton':  ('torso', 'deltoides'),
    'SM_Pesc_Mangas':     ('brazos', 'deltoides'),
    'SM_Pesc_Cinturon':   ('torso',),
    'SM_Pesc_Hebilla':    ('torso',),
    'SM_Pesc_Cadera':     ('torso', 'piernas'),
    'SM_Pesc_Pantalones': ('piernas',),
    'SM_Pesc_Botas':      ('piernas',),
}
verificar_ropa(escena, partes=PARTES)

marcar_montado()
iluminar(escena)
camara(escena, 'CAM_PESCADOR', (1.30, 2.20, 1.10), (0.0, 0.0, 0.85))
shade_flat(escena)
auditar(escena)
guardar(escena, '19-NPCs', 'vestimenta_pescador')