# crear_hacha_hierro_lowpoly.py — Hacha de hierro (M16-Crafting / M14-Inventario)
# Checklist M16: "Hacha de hierro"
#
# Pose: APOYADA EN LA ARENA (herramienta soltada en el suelo), igual que
#   `crear_hacha_piedra_lowpoly.py`, que es el patron del modulo.
#     - Mango a lo largo de X: empuñadura en -X, ojo en +X.
#     - Cabeza con eje largo en Y (PERPENDICULAR al mango), del poll (-Y) al
#       filo (+Y). El filo corre PARALELO al mango (regla del hacha real).
#     - El mango NO sobresale por delante del ojo: termina DENTRO (assert).
#
# DIFERENCIAL vs el hacha de PIEDRA (no es un recolor):
#   1. Cabeza de hierro FORJADA mas gruesa en el ojo (halfZ 0.040 vs 0.037) y
#      con el filo mas abierto (halfX 0.120 vs 0.125 pero con garganta mas
#      larga: 0.105 vs 0.10) — silueta de hacha de leñador, no de mano.
#   2. BIT DE ACERO soldado (pieza aparte, material metalico brillante) en el
#      tercio del filo: se ve la linea de soldadura.
#   3. CASQUILLO forjado donde el mango entra en el ojo (el hacha de piedra
#      usaba atadura de cuero; la de hierro se asegura con casquillo).
#   4. Sin anillas de cuero: empuñadura de cuero cosida en vez de cordel.
#
# APOYO REAL (no flotante): el mango es MAS FINO que la cabeza, asi que si
# ambos se centran en el mismo z el mango queda en el aire. Se calcula
# MANGO_Z para que la generatriz inferior del mango coincida con la cara
# inferior de la cabeza. Hay un assert que lo verifica.
import sys
import os

DIR_MOD = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
DIR_REU = os.path.join(DIR_MOD, 'scripts-reutilizables')
for _p in (DIR_REU, os.path.join(DIR_MOD, '19-NPCs', 'scripts')):
    if _p not in sys.path:
        sys.path.insert(0, _p)

import math                                                    # noqa: E402
import bpy                                                     # noqa: E402
from plantilla_asset import (limpiar, mat, arena, piezas,       # noqa: E402
                             zmin_real)
from herramienta_util import (prisma, recubrimiento,             # noqa: E402
                              cerrar_herramienta)

escena = limpiar()

# ---------- Materiales ----------
MAT_madera = mat('MAT_HachaHierro_Madera', (0.40, 0.26, 0.15), rough=0.85)
MAT_hierro = mat('MAT_HachaHierro_Hierro', (0.29, 0.30, 0.33), rough=0.45,
                 spec=0.45)
MAT_acero = mat('MAT_HachaHierro_Acero', (0.62, 0.64, 0.68), rough=0.20,
                spec=0.70)
MAT_cuero = mat('MAT_HachaHierro_Cuero', (0.42, 0.28, 0.16), rough=0.92)
# `mat()` no expone metallic (plantilla_asset lo fija): lo subo a mano.
MAT_hierro.node_tree.nodes['Principled BSDF'].inputs['Metallic'].default_value = 0.85
MAT_acero.node_tree.nodes['Principled BSDF'].inputs['Metallic'].default_value = 0.95

arena(radio=1.2, profundo=0.22)

# ---------- Geometria base ----------
CABEZA_Z = 0.0                  # plano medio de la cabeza (se asienta despues)
HEAD_X = 0.010                  # centro de la cabeza en X
GRUESO_CABEZA = 0.040           # semi-eje Z maximo de la cabeza (en el ojo)

# ---------- 1) Mango (eje X) ----------
# estaciones: (x, semi-eje en Y, semi-eje en Z). lados=8 con fase=0 deja un
# vertice exactamente a 270 deg (abajo) -> generatriz de apoyo limpia.
EST_MANGO = [
    (-0.640, 0.024, 0.020),     # extremo de la empuñadura (dentro del pomo)
    (-0.600, 0.033, 0.028),     # engrosamiento trasero
    (-0.470, 0.035, 0.030),     # maximo: donde apoya la mano de atras
    (-0.330, 0.031, 0.026),
    (-0.150, 0.029, 0.025),
    (+0.020, 0.027, 0.023),
    (+0.052, 0.025, 0.021),     # dentro del ojo
]
GRUESO_MANGO = max(s[2] for s in EST_MANGO)     # 0.030
# El mango es mas fino que la cabeza -> hay que BAJARLO para que su generatriz
# inferior coincida con la cara inferior de la cabeza. Sin esto el mango
# flota 10 mm sobre la arena (E-12).
MANGO_Z = CABEZA_Z - GRUESO_CABEZA + GRUESO_MANGO

mango = prisma('SM_HachaHierro_Mango', EST_MANGO, eje='X',
               material=MAT_madera, lados=8, fase=0.0, escena=escena)
mango.location.z = MANGO_Z
mango.location.x = 0.0

# El mango NO debe asomar por delante del ojo: la cabeza cubre hasta
# HEAD_X + semiX_en_el_ojo. semiX en el ojo = 0.050.
X_OJO_MAX = HEAD_X + 0.050
assert EST_MANGO[-1][0] <= X_OJO_MAX + 1e-6, (
    'el mango llega a x=%.3f pero el ojo solo cubre hasta x=%.3f: '
    'asomaria por delante de la cabeza' % (EST_MANGO[-1][0], X_OJO_MAX))

# ---------- 2) Cabeza de hierro (eje Y) ----------
# FASE 0, no pi/6: con lados=6 y fase=0 los angulos son 0,60,...,300, asi que
# los vertices 240 y 300 comparten el mismo z (-0.866*ry) -> la seccion tiene
# una CARA INFERIOR PLANA y la cabeza apoya sobre ella. Con fase=pi/6 el
# vertice mas bajo quedaba SOLO en 270 (seccion apoyada en punta): la huella
# se reducia a una arista y la cabeza se veia clavada en la arena.
# Contrapartida: el espesor EFECTIVO es 0.866*ry, no ry. Por eso las ry de
# abajo estan divididas por F_PLANO — las comento como espesor real.
F_PLANO = math.sin(math.radians(60.0))   # 0.8660
ESP = [0.028, 0.040, 0.040, 0.030, 0.020]        # espesores EFECTIVOS (m)
YS = [-0.085, -0.035, 0.010, 0.060, 0.105]
HXS = [0.036, 0.045, 0.050, 0.068, 0.088]
EST_CABEZA = [(y, hx, e / F_PLANO) for (y, hx, e) in zip(YS, HXS, ESP)]
cabeza = prisma('SM_HachaHierro_Cabeza', EST_CABEZA, eje='Y',
                material=MAT_hierro, lados=6, fase=0.0, escena=escena)
cabeza.location = (HEAD_X, 0.0, CABEZA_Z)

# ---------- 3) Bit de acero soldado (tercio del filo) ----------
# lados=4 + fase=45 deg = seccion romboidal (lomo grueso, filo fino).
# Arranca 5 mm ANTES de donde termina el hierro (0.100 vs 0.105) para que se
# SOLAPEN y no quede un huevo; el acero es 1 mm mas grueso que el hierro en
# cada estacion para envolverlo y evitar z-fighting.
EST_ACERO = [
    (+0.100, 0.088, 0.021),
    (+0.130, 0.104, 0.013),
    (+0.158, 0.120, 0.005),     # filo
]
acero = prisma('SM_HachaHierro_FiloAcero', EST_ACERO, eje='Y',
               material=MAT_acero, lados=4, fase=math.pi / 4.0, escena=escena)
acero.location = (HEAD_X, 0.0, CABEZA_Z)

# ---------- 4) Casquillo forjado (mango -> ojo) ----------
# lados=8 (NO 6): con lados=8 el vertice mas bajo cae exactamente a 270 deg
# y el semi-eje Z efectivo es el declarado. Con lados=6 + fase=pi/6 el fondo
# bajaba hasta -ry y el casquillo se convertia en el apoyo de todo el grupo,
# levantando la cabeza 3 mm sobre la arena. Recubriendo el perfil real del
# mango queda centrado y parejo.
casquillo = recubrimiento('SM_HachaHierro_Casquillo', EST_MANGO, eje='X',
                          ts=(-0.035, -0.005, 0.030, 0.055), espesor=0.003,
                          material=MAT_hierro, lados=8, fase=0.0,
                          escena=escena)
casquillo.location.z = MANGO_Z

# ---------- 5) Empuñadura de cuero cosida ----------
# `recubrimiento` muestrea el perfil REAL del mango asi la funda lo envuelve
# parejo; escrita "a ojo" quedaba por dentro en los tramos donde el mango
# engorda y desaparecia. Sobresale 2 mm: se ve, pero no llega a ser el apoyo
# (eso levantaria el mango).
grip = recubrimiento('SM_HachaHierro_Grip', EST_MANGO, eje='X',
                     ts=(-0.512, -0.450, -0.380, -0.288), espesor=0.002,
                     material=MAT_cuero, lados=8, fase=0.0, escena=escena)
grip.location.z = MANGO_Z

# ---------- 6) Pomo (remate de la empuñadura) ----------
# Radio 0.034 achatado -> su punto mas bajo (0.027) queda POR ENCIMA del
# semi-eje maximo del mango (0.030): no se convierte en el apoyo.
bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=5, radius=0.034,
                                     location=(-0.648, 0.0, MANGO_Z))
pomo = bpy.context.object
pomo.name = 'SM_HachaHierro_Pomo'
pomo.scale = (0.90, 1.0, 0.80)
pomo.data.materials.append(MAT_madera)

# ---------- 7) Guard de apoyo real ----------
bpy.context.view_layer.update()
fondo_cabeza = CABEZA_Z - GRUESO_CABEZA
fondo_mango = MANGO_Z - GRUESO_MANGO
assert abs(fondo_cabeza - fondo_mango) < 1e-6, (
    'APOYO FALSO: la cabeza apoya en z=%.4f y el mango en z=%.4f '
    '(diferencia %.4f m). Si el mango queda mas alto FLOTA sobre la arena.'
    % (fondo_cabeza, fondo_mango, fondo_cabeza - fondo_mango))

# ---------- 8) Cierre ----------
cerrar_herramienta(escena, '16-Crafting', 'hacha_hierro',
                   loc_cam=(-1.05, -0.95, 0.62), mira_cam=(-0.25, 0.03, 0.07))

# ---------- 9) Reporte de apoyo ----------
for o in sorted(piezas(escena), key=lambda p: p.name):
    print('   %-28s z %.4f' % (o.name, zmin_real(o)))
print('HACHA HIERRO OK — %d SM_' % len(piezas(escena)))
