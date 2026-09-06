# crear_martillo_lowpoly.py — Martillo de carpintero (M16-Crafting / M14-Inventario)
# Checklist M16: "Martillo"
#
# Pose: APOYADO EN LA ARENA (mismo patron que el hacha de hierro).
#   - Mango a lo largo de X (empuñadura en -X, ojo en +X).
#   - Cabeza con eje largo en Y: BOCA (cara de golpe, plana) en +Y,
#     UÑA CLAW (dos puntas curvadas para sacar clavos) en -Y.
#
# DIFERENCIAL vs el hacha: la cabeza tiene un MUESCA central en -Y donde se
# bifurca la uña. Sin esa V central la pieza lee como un bloque solido y
# pierde la identidad de martillo de carpintero.
import sys
import os

DIR_MOD = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
DIR_REU = os.path.join(DIR_MOD, 'scripts-reutilizables')
for _p in (DIR_REU,):
    if _p not in sys.path:
        sys.path.insert(0, _p)

import math                                                    # noqa: E402
import bpy                                                     # noqa: E402
from plantilla_asset import limpiar, mat, arena, piezas, zmin_real  # noqa: E402
from herramienta_util import (prisma, recubrimiento,             # noqa: E402
                              cerrar_herramienta)

escena = limpiar()

# ---------- Materiales ----------
MAT_madera = mat('MAT_Martillo_Madera', (0.42, 0.27, 0.16), rough=0.85)
MAT_hierro = mat('MAT_Martillo_Hierro', (0.31, 0.32, 0.35), rough=0.42,
                 spec=0.48)
MAT_acero = mat('MAT_Martillo_Acero', (0.65, 0.66, 0.70), rough=0.22,
                spec=0.70)
MAT_cuero = mat('MAT_Martillo_Cuero', (0.42, 0.28, 0.16), rough=0.92)
MAT_hierro.node_tree.nodes['Principled BSDF'].inputs['Metallic'].default_value = 0.85
MAT_acero.node_tree.nodes['Principled BSDF'].inputs['Metallic'].default_value = 0.95

arena(radio=1.2, profundo=0.22)

# ---------- Geometria base ----------
CABEZA_Z = 0.0
HEAD_X = 0.010
F_PLANO = math.sin(math.radians(60.0))   # 0.866, ver hacha_hierro
GRUESO_CABEZA = 0.038                  # semi-eje Z maximo de la cabeza

# ---------- 1) Mango (eje X) ----------
# Mango PRACTICAMENTE UNIFORME en Z (hz constante = 0.030). Si fuera conico
# como el del hacha (hz 0.034..0.022), solo el maximo toca el suelo y la
# huella se reduce a 1 vert -> falla E-50 (apoyo puntual). Con hz constante
# toda la generatriz inferior es una LINEA HORIZONTAL y 5+ verts tocan.
# El "swell" ergonomico se aplica solo en Y (la mano engrosa el mango
# lateralmente, no verticalmente).
EST_MANGO = [
    (-0.680, 0.025, 0.022),     # extremo (dentro del pomo, se afila)
    (-0.610, 0.033, 0.030),     # arranque de la empuñadura
    (-0.500, 0.037, 0.031),     # maximo (grip swell, solo en Y)
    (-0.380, 0.035, 0.030),
    (-0.230, 0.033, 0.030),
    (-0.080, 0.031, 0.030),
    (+0.020, 0.029, 0.030),
    (+0.058, 0.027, 0.030),     # final dentro del ojo (sin afilar)
]
GRUESO_MANGO = max(s[2] for s in EST_MANGO)     # 0.034
MANGO_Z = CABEZA_Z - GRUESO_CABEZA + GRUESO_MANGO    # alinea fondos (E-12)

mango = prisma('SM_Martillo_Mango', EST_MANGO, eje='X',
               material=MAT_madera, lados=8, fase=0.0, escena=escena)
mango.location = (0.0, 0.0, MANGO_Z)

# ---------- 2) Cabeza (eje Y, lados=6 fase=0 = apoyo PLANO) ----------
# F_PLANO = 0.866: con fase=0 el semi-eje Z EFECTIVO es 0.866*ry, por eso
# divido cada espesor pedido por F_PLANO para que el resultado visual sea
# el deseado. Sin la division el grosor EFECTIVO era 0.866*0.038 = 0.033
# (no 0.038) y la cabeza quedaba 5 mm por encima del apoyo -> no tocaba.
# -Y = lado de la uña (claw), +Y = boca (cara de golpe).
# Cabeza proporcionalmente MAS ANCHA que el hacha.
ESP_CAB = [0.030, 0.038, 0.038, 0.030]     # espesores EFECTIVOS pedidos (m)
HX_CAB  = [0.038, 0.052, 0.054, 0.042]
Y_CAB   = [-0.045, -0.015, 0.020, 0.060]
EST_CABEZA = [(y, hx, e / F_PLANO) for (y, hx, e) in zip(Y_CAB, HX_CAB, ESP_CAB)]
cabeza = prisma('SM_Martillo_Cabeza', EST_CABEZA, eje='Y',
                material=MAT_hierro, lados=6, fase=0.0, escena=escena)
cabeza.location = (HEAD_X, 0.0, CABEZA_Z)

# ---------- 3) Bit de acero de la BOCA (cara de golpe) ----------
# Refuerzo en +Y: la cara de golpe se endurece por temple. Mismo patron
# que el hacha: pieza que SOLAPA la cabeza y la envuelve 1 mm mas gruesa.
EST_BOCA_ACERO = [
    (+0.045, 0.040, 0.030),
    (+0.063, 0.036, 0.022),
]
boca = prisma('SM_Martillo_BocaAcero', EST_BOCA_ACERO, eje='Y',
              material=MAT_acero, lados=4, fase=math.pi / 4.0, escena=escena)
boca.location = (HEAD_X, 0.0, CABEZA_Z)

# ---------- 4) UÑA partida (claw): dos prismas delgados en -Y ----------
# Cada mitad es una cuña que arranca desde la cabeza (y=-0.035) y se
# extiende hasta y=-0.115, curvandose levemente hacia fuera. Una CAJA
# rotada en Z la inclina 12° (izq a -Z, der a +Z) creando la "V" del claw.
# Material: acero (las uñas son acero endurecido para no doblarse).
LONG_UNIA = 0.085        # cuanto sobresale de la cabeza
ANG_UNIA = math.radians(12.0)


def unia(nombre, x_centro, ang_z):
    """Una mitad del claw: prisma delgado que se curva hacia fuera.

    Caja rotada: el eje largo del prisma es Z (local), luego rotamos en Z
    global para abrir la V, y trasladamos para que el nacimiento coincida
    con la cabeza.
    """
    bm = bmesh.new()
    # Vertices de la uña en su frame LOCAL (largo en Z, semiejes en X/Y).
    # Perfil ligeramente curvado: ensancha en el medio (donde se clava el
    # clavo) y se afila en la punta (y=0) y la base (y=LONG_UNIA).
    EST = [
        (0.000,                  0.018, 0.012),     # nacimiento (ancho)
        (LONG_UNIA * 0.30,       0.022, 0.014),     # panza (donde aprieta)
        (LONG_UNIA * 0.65,       0.020, 0.012),
        (LONG_UNIA,              0.010, 0.008),     # punta afilada
    ]
    lados = 5
    anillos = []
    for (t, rx, ry) in EST:
        verts = []
        for k in range(lados):
            ang = 2.0 * math.pi * k / lados
            verts.append(bm.verts.new((rx * math.cos(ang), ry * math.sin(ang),
                                       t)))
        anillos.append(verts)
    # cerrar caras
    n = lados
    for i in range(len(anillos) - 1):
        for k in range(n):
            k2 = (k + 1) % n
            bm.faces.new((anillos[i][k], anillos[i][k2],
                          anillos[i + 1][k2], anillos[i + 1][k]))
    # tapas
    for anillo, invertir in ((anillos[0], True), (anillos[-1], False)):
        c = bm.verts.new(sum((v.co for v in anillo),
                        Vector((0.0, 0.0, 0.0))) / n)
        for k in range(n):
            k2 = (k + 1) % n
            if invertir:
                bm.faces.new((c, anillo[k2], anillo[k]))
            else:
                bm.faces.new((c, anillo[k], anillo[k2]))
    bm.normal_update()
    me = bpy.data.meshes.new(nombre)
    ob = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(ob)
    bm.to_mesh(me)
    bm.free()
    ob.data.materials.append(MAT_acero)
    # Nasen a la cabeza: y_local = -0.035 (donde termina el ojo del martillo).
    # El prisma se construye desde z_local=0 hacia +Z, asi que el inicio queda
    # pegado al plano de la cabeza y la uña sobresale en +Z local.
    ob.location = (HEAD_X + x_centro, 0.0, CABEZA_Z)
    # Rotamos en Z: la uña izquierda va hacia -X (hacia fuera) y la derecha
    # hacia +X. Como estan en el plano XZ local, una rotacion en X las inclina
    # en Z (arriba/abajo). Para abrir en X hay que rotar en Y -> eso las
    # inclina en Z. Mejor: aplicar el offset X al centro de cada uña y
    # dejarlas rectas, separadas por el hueco central.
    return ob


import bmesh                                                   # noqa: E402
from mathutils import Vector                                    # noqa: E402
unia_izq = unia('SM_Martillo_UniaIzq', x_centro=-0.020, ang_z=-ANG_UNIA)
unia_der = unia('SM_Martillo_UniaDer', x_centro=+0.020, ang_z=+ANG_UNIA)
# Inclinacion real: cada uña respecto al eje Z (vertical). Rotamos en X para
# que la izquierda se incline hacia -X (afuera) y la derecha hacia +X.
unia_izq.rotation_euler = (0.0, 0.0, -ANG_UNIA * 2.0)
unia_der.rotation_euler = (0.0, 0.0, +ANG_UNIA * 2.0)
bpy.context.view_layer.update()

# ---------- 5) Casquillo forjado en el ojo (igual patron que el hacha) ----------
casquillo = recubrimiento('SM_Martillo_Casquillo', EST_MANGO, eje='X',
                          ts=(-0.030, 0.000, 0.025, 0.052), espesor=0.003,
                          material=MAT_hierro, lados=8, fase=0.0,
                          escena=escena)
casquillo.location.z = MANGO_Z

# ---------- 6) Empuñadura de cuero ----------
grip = recubrimiento('SM_Martillo_Grip', EST_MANGO, eje='X',
                     ts=(-0.510, -0.450, -0.380, -0.310), espesor=0.002,
                     material=MAT_cuero, lados=8, fase=0.0, escena=escena)
grip.location.z = MANGO_Z

# ---------- 7) Pomo ----------
bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=5, radius=0.034,
                                     location=(-0.688, 0.0, MANGO_Z))
pomo = bpy.context.object
pomo.name = 'SM_Martillo_Pomo'
pomo.scale = (0.90, 1.0, 0.80)
pomo.data.materials.append(MAT_madera)

# ---------- 8) Guard de apoyo real ----------
fondo_cabeza = CABEZA_Z - GRUESO_CABEZA
fondo_mango = MANGO_Z - GRUESO_MANGO
assert abs(fondo_cabeza - fondo_mango) < 1e-6, (
    'cabeza apoya en z=%.4f, mango en z=%.4f' % (fondo_cabeza, fondo_mango))

# ---------- 9) Cierre ----------
cerrar_herramienta(escena, '16-Crafting', 'martillo',
                   loc_cam=(-1.10, -0.95, 0.55), mira_cam=(-0.30, 0.02, 0.06))

# ---------- 10) Reporte ----------
for o in sorted(piezas(escena), key=lambda p: p.name):
    print('   %-26s z %.4f' % (o.name, zmin_real(o)))
print('MARTILLO OK — %d SM_' % len(piezas(escena)))