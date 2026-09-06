# crear_frasco_agua_lowpoly.py — Frasco de agua (M16-Crafting / M14-Inventario)
# Checklist M16: "Frasco de agua"
#
# DISENO: frasco de vidrio panzudo de cuello corto, con AGUA adentro, tapon de
# corcho y una cuerda atada al cuello. 4 piezas:
#   SM_Frasco_Vidrio  — cuerpo translucido (panza Ø 0.18, alto 0.212)
#   SM_Frasco_Agua    — el agua, una malla INDEPENDIENTE apenas mas chica
#   SM_Frasco_Corcho  — tapon parcialmente insertado
#   SM_Frasco_Cuerda  — toroide en el cuello (E-85: el torus ya nace horizontal)
#
# POR QUE el agua es otra malla y no un material del vidrio: con un solo
# cuerpo translucido no hay manera de marcar el nivel del liquido. La malla de
# agua arranca 14 mm por encima del fondo del vidrio, asi que sus vertices NO
# entran en la cuenta de apoyo (tol = 5 mm, E-91) y la huella la define solo el
# vidrio, que es lo que de verdad toca la arena.
#
# TRANSPARENCIA: el vidrio va con blend_method BLEND y alpha 0.45. Si el
# exportador glTF o Godot ignoran el alpha, el peor caso es un frasco opaco
# celeste: el asset sigue siendo valido, solo pierde el agua a la vista.
#
# E-91: objeto PEQUEÑO (0.18 m de panza). `asentar()` exigiria min(fp) > 0.30,
# el doble del diametro del frasco. Se usa `asentar_herramienta()`.
import sys
import os

DIR_MOD = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
DIR_REU = os.path.join(DIR_MOD, 'scripts-reutilizables')
if DIR_REU not in sys.path:
    sys.path.insert(0, DIR_REU)

import bpy                                                     # noqa: E402
from plantilla_asset import limpiar, mat, arena, loft, piezas, zmin_real  # noqa: E402
from herramienta_util import cerrar_herramienta                # noqa: E402

escena = limpiar()

# ---------- Materiales ----------
MAT_vidrio = mat('MAT_Frasco_Vidrio', (0.74, 0.88, 0.92), rough=0.06, spec=0.95)
MAT_agua = mat('MAT_Frasco_Agua', (0.16, 0.46, 0.62), rough=0.10, spec=0.80)
MAT_corcho = mat('MAT_Frasco_Corcho', (0.62, 0.44, 0.26), rough=0.90)
MAT_cuerda = mat('MAT_Frasco_Cuerda', (0.76, 0.66, 0.44), rough=0.95)

# Vidrio translucido (unico material con alpha del lote).
MAT_vidrio.blend_method = 'BLEND'
_bsdf = MAT_vidrio.node_tree.nodes['Principled BSDF']
_bsdf.inputs['Alpha'].default_value = 0.45

arena(radio=1.2, profundo=0.22)

# ---------- 1) Vidrio ----------
# Cerrado ARRIBA (tapar_arriba=True): el corcho entra "a presion" en la boca,
# no hay un hueco por el que se vean las contracaras del vidrio.
ANILLOS_VIDRIO = [
    (0.000, 0.0, 0.0, 0.062, 0.062),   # base -> apoyo Ø 0.124
    (0.012, 0.0, 0.0, 0.072, 0.072),   # arranque de la panza
    (0.075, 0.0, 0.0, 0.090, 0.090),   # panza (maximo)
    (0.150, 0.0, 0.0, 0.086, 0.086),   # hombro
    (0.190, 0.0, 0.0, 0.058, 0.058),   # cuello
    (0.212, 0.0, 0.0, 0.064, 0.064),   # boca (labio abierto)
]
vidrio = loft('SM_Frasco_Vidrio', ANILLOS_VIDRIO, material=MAT_vidrio,
              lados=12, tapar_arriba=True, tapar_abajo=True)

# ---------- 2) Agua ----------
# Pared ~8 mm por dentro del vidrio en cada altura para que se vea el espesor.
# Arranca en z=0.014 (14 mm sobre el fondo del vidrio) para quedar fuera del
# radio de tolerancia del guard de apoyo (tol = 5 mm).
ANILLOS_AGUA = [
    (0.014, 0.0, 0.0, 0.058, 0.058),
    (0.070, 0.0, 0.0, 0.080, 0.080),
    (0.145, 0.0, 0.0, 0.076, 0.076),   # superficie del agua
]
agua = loft('SM_Frasco_Agua', ANILLOS_AGUA, material=MAT_agua,
            lados=12, tapar_arriba=True, tapar_abajo=True)

# ---------- 3) Corcho ----------
ANILLOS_CORCHO = [
    (0.205, 0.0, 0.0, 0.050, 0.050),   # mitad inferior DENTRO de la boca
    (0.232, 0.0, 0.0, 0.054, 0.054),   # asoma
    (0.262, 0.0, 0.0, 0.046, 0.046),   # copa achatada arriba
]
corcho = loft('SM_Frasco_Corcho', ANILLOS_CORCHO, material=MAT_corcho,
              lados=10, tapar_arriba=True, tapar_abajo=True)

# ---------- 4) Cuerda en el cuello ----------
# E-85: primitive_torus_add ya genera el toroide en el plano XY (horizontal).
# NO rotarlo: rotarlo lo deja vertical y aparece de canto alrededor del cuello.
bpy.ops.mesh.primitive_torus_add(major_segments=12, minor_segments=6,
                                 major_radius=0.060, minor_radius=0.006,
                                 location=(0.0, 0.0, 0.196))
cuerda = bpy.context.object
cuerda.name = 'SM_Frasco_Cuerda'
cuerda.data.materials.append(MAT_cuerda)

# ---------- Cierre ----------
cerrar_herramienta(escena, '16-Crafting', 'frasco_agua',
                   loc_cam=(-0.46, -0.62, 0.28), mira_cam=(0.0, 0.0, 0.13))

for o in sorted(piezas(escena), key=lambda p: p.name):
    print('   %-22s z %.4f' % (o.name, zmin_real(o)))
print('FRASCO DE AGUA OK — %d SM_' % len(piezas(escena)))
