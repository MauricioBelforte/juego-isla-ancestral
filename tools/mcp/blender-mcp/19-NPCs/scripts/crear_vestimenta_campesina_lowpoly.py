# crear_vestimenta_campesina_lowpoly.py — M19 · Vestimenta de campesino/a (M19)
#
# Perfil: CAMPESINO/A (labrador, regador, criador de gallinas). Es un asset
# MONTADO (E-79): la ropa se AUTORA en cotas de mundo (z_ref_ropa = 0) y se
# renderea ENCIMA del cuerpo del NPC base. Cuando un NPC viste esta
# vestimenta, en Godot se ocultan los SM_NPC_RopaBase / SM_NPC_Torso del
# NPC base y se instancia este GLB como hijo del nodo raiz.
#
# Componentes:
#   1) Camisa de lino crudo  (0.92 a 1.295, con cuello abierto)
#   2) Mangas largas hasta la muneca (abrazan el brazo, +18..28 mm)
#   3) Cadera / tiro del pantalon (0.700 a 0.968)  <- pieza unica que
#      envuelve las dos piernas, como los pantalones reales
#   4) Perneras (0.115 a 0.720), arrancan DENTRO de la cadera
#   5) Delantal (cuelga del frente de 0.975 a 0.55)
#   6) Panuelo al cuello (1.160 a 1.295, en +Y, pegado al pecho)
#   7) Cordon de fibra en la cintura
#
# E-73/E-74 (E-74 es "pieza cilindrica horizontal sobre el pecho = pico"):
#   nada sale horizontalmente del pecho. El delantal cuelga VERTICAL, las
#   mangas van a lo largo del brazo, el panuelo va pegado al pecho, el cordon
#   rodea la cintura (costura natural). Verificacion numerica en
#   verificar_ropa.
#
# E-89: cada pieza declara CONTRA QUE PARTES del cuerpo se audita. La ropa de
#   tronco NO se audita contra los brazos: el brazo cuelga por fuera de la
#   prenda y la oculta (y en este rig los brazos van pegados al torso, asi
#   que exigirles clearance es imposible — el propio SM_NPC_RopaBase del NPC
#   base pasa por dentro de los brazos y esta aprobado).
#
# E-87: los vertices centrales de las TAPAS de los tubos (hombro de la manga,
#   tobillo de la pernera, cintura de la cadera) estan sobre el eje del cuerpo
#   y por tanto DENTRO de el por construccion. Se marcan OCULTO y el guard
#   los salta: los tapa otra pieza.
#
# Budget M166 ALTA: <=16 obj / <=6000 tris / <=12 mats. Esta: 7 SM_, 5 mats.

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from math import radians
from mathutils import Vector
import bpy, bmesh

from plantilla_asset import limpiar, mat, loft, caja, piezas, polilinea
from montado_util import (maniqui_cuerpo, verificar_ropa, marcar_montado,
                          iluminar, camara, shade_flat, auditar, guardar,
                          aplicar, unir, aplicar_todos_sm, LC, YC, Z_REF_CABEZA,
                          X_CABEZA, Y_CABEZA, Z_CABEZA, R_CABEZA,
                          Z_REF_ROPA, BRAZOS, PIERNAS, R_BRAZO, R_PIERNA,
                          dx, _interpolar, ANILLOS_TORSO, marcar_ocultos,
                          piezas as _piezas_sm)

escena = limpiar()

# Misma paleta que el NPC base (mismos tonos), mas 1 material extra para el
# panuelo. Total 5 <= ALTA 12.
MATS = {
    'lino':      mat('MAT_Camp_Lino',     (0.92, 0.88, 0.78)),    # crudo
    'pant':      mat('MAT_Camp_Pantalon', (0.46, 0.39, 0.29)),    # faena
    'panuelo':   mat('MAT_Camp_Panuelo',  (0.78, 0.28, 0.32)),    # rojo
    'cuerda':    mat('MAT_Camp_Cuerda',   (0.36, 0.24, 0.16)),    # fibra
}


def frente_torso(z):
    """Cota Y del frente del cuerpo a la altura z (para colgar tela)."""
    return _interpolar(ANILLOS_TORSO, z, 2) + _interpolar(ANILLOS_TORSO, z, 4)


def centro_de_tapa(punto, tol=0.010):
    """Predicado: el vertice es el CENTRO de la tapa de un tubo cerrado.

    E-87: loft() cierra las tapas con un abanico a un vertice central, que
    por construccion esta sobre el eje del cuerpo y por tanto DENTRO de el.
    Se marca OCULTO porque lo tapa otra pieza (la camisa tapa la cintura de
    la cadera, el cuerpo tapa el hombro de la manga y el tobillo).

    Se pasa el PUNTO exacto en vez de "cerca de cualquier eje": con un
    tolerance generico el muneca de la manga derecha (0.123, 0.024, 0.791)
    caia a 25 mm del primer punto de la pierna derecha y se marcaba sin ser
    tapa (falso positivo real, 2026-09-03).
    """
    p = Vector(punto)

    def _pred(w):
        return (w - p).length < tol
    return _pred


# ===========================================================================
# 1) CAMISA — loft sobre el torso, cuello abierto (0.92 a 1.295)
# ===========================================================================
# Cada anillo es torso + 12..20 mm de tela. En el hombro manda el DELTOIDE,
# no el torso: hay que superar su borde exterior (|x| ~0.237) mas 5 mm, o la
# camisa se mete en el hombro (E-84). rx 0.232..0.236 en z 1.13..1.20.
# Abierta arriba: el cuello pasa por el hueco (ver E-87/panuelo).
ANILLOS_CAMISA = [
    (0.920, dx(0.920), -0.008, 0.176, 0.126),   # ruedo (A-line, se abre)
    (0.960, dx(0.960), -0.008, 0.168, 0.122),   # cintura (la mas angosta)
    (1.010, dx(1.010), -0.005, 0.180, 0.132),   # arranca la caja toracica
    (1.090, dx(1.090),  0.004, 0.192, 0.140),   # pecho
    (1.130, dx(1.130),  0.009, 0.220, 0.146),   # sube al hombro
    (1.150, dx(1.150),  0.011, 0.232, 0.146),   # hombro (manga + deltoide)
    (1.175, dx(1.175),  0.013, 0.236, 0.146),   # hombro, maximo
    (1.200, dx(1.200),  0.010, 0.226, 0.144),   # linea de hombros
    (1.245, dx(1.245), -0.002, 0.152, 0.108),   # trapecio
    (1.270, dx(1.270), -0.007, 0.104, 0.082),   # base del cuello
    (1.295, dx(1.295), -0.012, 0.076, 0.068),   # gargantilla (abierta)
]
camisa = loft('SM_Camp_Camisa', ANILLOS_CAMISA, MATS['lino'], lados=14,
              tapar_arriba=False, tapar_abajo=False)

# ===========================================================================
# 2) MANGAS — tubos hombro -> muneca, concentricos al brazo (+18..28 mm)
# ===========================================================================
# Se auditan solo contra ('brazos','deltoides') (E-89): su mitad INTERIOR
# queda dentro del torso por diseno y la oculta el cuerpo (E-86).
def construir_mangas(prefijo, ts, radios, mat_prenda, lados=8):
    """Mangas como polilinea siguiendo los brazos del NPC base. 2 piezas."""
    hechas = []
    for lado in ('I', 'D'):
        muestras = polilinea(BRAZOS[lado], ts)
        # muestras[i] = (x, y, z); anillo local (z, cx, cy, rx, ry) — E-77
        anillos = [(muestras[i][2], muestras[i][0], muestras[i][1],
                    radios[i], radios[i]) for i in range(len(muestras))]
        anillos.reverse()                            # muneca -> hombro
        hechas.append(loft(prefijo + '_Brazo_' + lado, anillos,
                           mat_prenda, lados=lados,
                           tapar_arriba=True, tapar_abajo=False))
    return hechas


mangas = construir_mangas(
    'SM_Camp_Manga', (0.0, 0.28, 0.55, 0.78, 1.0),
    (0.095, 0.084, 0.076, 0.068, 0.062), MATS['lino'])

# ===========================================================================
# 3) CADERA — un solo tubo que envuelve las dos piernas (0.700 a 0.968)
# ===========================================================================
# Es lo que hace que la silueta lea como PANTALON y no como dos chorizos: el
# ancho exterior es continuo con el de las perneras (0.212 vs 0.209), y el
# tiro cierra abajo con un disco que solo se ve desde abajo (la camara
# orbital va a la altura de los ojos, nunca por debajo de z=0.70).
ANILLOS_CADERA = [
    (0.700, dx(0.700),  0.000, 0.212, 0.140),   # tiro (disco inferior)
    (0.790, dx(0.790), -0.003, 0.212, 0.140),   # cadera (maximo del cuerpo)
    (0.880, dx(0.880), -0.007, 0.190, 0.129),
    (0.940, dx(0.940), -0.008, 0.172, 0.122),
    (0.968, dx(0.968), -0.008, 0.160, 0.118),   # cintura, BAJO la camisa
]
cadera = loft('SM_Camp_Cadera', ANILLOS_CADERA, MATS['pant'], lados=12,
              tapar_arriba=True, tapar_abajo=True)

# ===========================================================================
# 4) PERNERAS — dos tubos (0.115 a 0.720), arrancan DENTRO de la cadera
# ===========================================================================
# El anillo superior queda escondido dentro de SM_Camp_Cadera (que baja hasta
# 0.700), asi que no hace falta taparlo. Cerradas abajo (ruedo).
PIERNAS_VEST = {
    'I': [(-0.1013, -0.0020, 0.720), (-0.1005,  0.0000, 0.600),
          (-0.1002,  0.0027, 0.450), (-0.1000,  0.0090, 0.300),
          (-0.1000,  0.0120, 0.115)],
    'D': [( 0.1023,  0.0180, 0.720), ( 0.1020,  0.0220, 0.600),
          ( 0.1006,  0.0354, 0.450), ( 0.1000,  0.0460, 0.300),
          ( 0.1000,  0.0520, 0.115)],
}
# r = radio de la pierna + 22 mm de tela (medido en cada cota).
R_PERNERA = (0.1087, 0.1037, 0.0926, 0.0820, 0.0680)

perneras = []
for lado in ('I', 'D'):
    pts = PIERNAS_VEST[lado]
    anillos = [(pts[i][2], pts[i][0], pts[i][1],
                R_PERNERA[i], R_PERNERA[i]) for i in range(len(pts))]
    anillos.reverse()                             # tobillo -> cadera
    perneras.append(loft('SM_Camp_Pernera_' + lado, anillos, MATS['pant'],
                         lados=10, tapar_arriba=False, tapar_abajo=True))

# ===========================================================================
# 5) DELANTAL — lamina vertical colgando del frente (0.975 a 0.55)
# ===========================================================================
# E-74: NO una lamina horizontal sobre el pecho (lee como pico). Es una
# lamina VERTICAL pegada al frente del cuerpo: cy = frente_torso(z) + 14 mm,
# medio espesor 4 mm -> la cara de atras queda 10 mm fuera de la piel.
# Sigue el perfil real del torso, que no es monotonico (la cadera sobresale
# mas que la cintura).
ANILLOS_DELANTAL = [
    (0.550, dx(0.550), frente_torso(0.550) + 0.014, 0.088, 0.004),
    (0.650, dx(0.650), frente_torso(0.650) + 0.014, 0.090, 0.004),
    (0.750, dx(0.750), frente_torso(0.750) + 0.014, 0.092, 0.004),
    (0.850, dx(0.850), frente_torso(0.850) + 0.014, 0.086, 0.004),
    (0.950, dx(0.950), frente_torso(0.950) + 0.014, 0.078, 0.004),
    (0.975, dx(0.975), frente_torso(0.975) + 0.014, 0.074, 0.004),
]
delantal = loft('SM_Camp_Delantal', ANILLOS_DELANTAL, MATS['lino'], lados=8,
                tapar_arriba=True, tapar_abajo=True)

# ===========================================================================
# 6) PANUELO AL CUELLO — V sobre el pecho, pegado al perfil del torso
# ===========================================================================
# E-74: NO un disco horizontal sobre el pecho. Es una lamina que baja desde
# la nuca (z=1.295, arriba y angosta) hasta el pecho (z=1.160, abajo y ancha)
# siguiendo frente_torso(z) + 14 mm. Lee como panuelo anudado.
ANILLOS_PANUELO = [
    (1.160, dx(1.160), frente_torso(1.160) + 0.014, 0.078, 0.005),
    (1.210, dx(1.210), frente_torso(1.210) + 0.014, 0.070, 0.005),
    (1.255, dx(1.255), frente_torso(1.255) + 0.014, 0.052, 0.005),
    (1.295, dx(1.295), frente_torso(1.295) + 0.014, 0.032, 0.005),
]
panuelo = loft('SM_Camp_Panuelo', ANILLOS_PANUELO, MATS['panuelo'], lados=10,
               tapar_arriba=True, tapar_abajo=True)

# ===========================================================================
# 7) CORDON de la cintura — torus horizontal rodeando la cintura
# ===========================================================================
# primitive_torus_add() ya tiene el agujero en +Z — sin rotacion queda en
# plano XY (horizontal) y envuelve la cintura. Si se rota 90° queda en plano
# XZ y ATRAVIESA el torso (E-85): caso real, 28 % de los vertices adentro.
# Radio interior 0.179 vs camisa 0.169 -> sobresale 1 cm y se VE como soga.
bpy.ops.mesh.primitive_torus_add(major_segments=14, minor_segments=6,
                                 major_radius=0.192, minor_radius=0.013,
                                 location=(dx(0.955), -0.006, 0.955))
cordon = bpy.context.object
cordon.name = 'SM_Camp_Cordon'
# SIN rotacion — el cordon queda horizontal.
cordon.data.materials.append(MATS['cuerda'])

# ===========================================================================
# CIERRE
# ===========================================================================
aplicar_todos_sm()

# E-87: marcar los vertices de TAPA que caen sobre el eje del cuerpo.
# Se hace DESPUES de aplicar() porque el predicado usa coordenadas de mundo.
marcar_ocultos(perneras[0], centro_de_tapa(PIERNAS_VEST['I'][-1]))   # tobillo
marcar_ocultos(perneras[1], centro_de_tapa(PIERNAS_VEST['D'][-1]))   # tobillo
marcar_ocultos(mangas[0], centro_de_tapa(BRAZOS['I'][0]))            # hombro
marcar_ocultos(mangas[1], centro_de_tapa(BRAZOS['D'][0]))            # hombro
marcar_ocultos(cadera, centro_de_tapa((dx(0.968), -0.008, 0.968)))   # cintura

# Mangas y perneras se unen para que el presupuesto de SM_ no se dispare
# (E-70): las 2 mangas valen como 1, las 2 perneras como 1.
mangas = unir('SM_Camp_Mangas', mangas)
perneras = unir('SM_Camp_Pantalones', perneras)

# Maniqui de referencia para la captura y para el guard
maniqui_cuerpo(escena)
bpy.context.view_layer.update()

# E-89: contra que partes del cuerpo se audita cada pieza.
PARTES = {
    'SM_Camp_Camisa':     ('torso', 'deltoides'),
    'SM_Camp_Cordon':     ('torso',),
    'SM_Camp_Delantal':   ('torso', 'piernas'),
    'SM_Camp_Panuelo':    ('torso', 'deltoides'),
    'SM_Camp_Cadera':     ('torso', 'piernas'),
    'SM_Camp_Pantalones': ('piernas',),
    'SM_Camp_Mangas':     ('brazos', 'deltoides'),
}
verificar_ropa(escena, partes=PARTES)

marcar_montado()          # E-80: la ropa NO debe re-asentarse
iluminar(escena)
camara(escena, 'CAM_CAMPESINA', (1.30, 2.20, 1.10), (0.0, 0.0, 0.85))
shade_flat(escena)
auditar(escena)
guardar(escena, '19-NPCs', 'vestimenta_campesina')
