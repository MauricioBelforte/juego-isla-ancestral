# crear_azada_lowpoly.py — Azada (M16-Crafting / M14-Inventario)
# Checklist M16: "Azada"
#
# Pose: APOYADA EN LA ARENA, mango largo a lo largo de X (1.0 m de empuñadura),
#   hoja trapezoidal al final (+X) perpendicular al mango. La azada REAL se
#   usa con el filo hacia abajo y se entierra en la tierra; aqui el filo
#   queda mirando hacia ARRIBA (la azada esta tirada en la playa con la
#   boca hacia arriba, esperando al agricultor).
#
# DIFERENCIAL vs el hacha:
#   - Mango MAS LARGO (~1.0 m vs ~0.7 m) y MAS FINO (4 cm vs 4.5 cm diametro).
#   - La "cabeza" no tiene un grosor definido: es una PLACA trapezoidal
#     extendida hacia delante (+X), mas fina que el hacha.
#   - Sin uña ni bit de acero lateral: el nervio central es el unico refuerzo.
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
from herramienta_util import prisma, recubrimiento, cerrar_herramienta  # noqa: E402

escena = limpiar()

# ---------- Materiales ----------
MAT_madera   = mat('MAT_Azada_Madera',    (0.43, 0.28, 0.17), rough=0.85)
MAT_hierro   = mat('MAT_Azada_Hierro',    (0.30, 0.31, 0.34), rough=0.45,
                   spec=0.45)
MAT_cuero    = mat('MAT_Azada_Cuero',     (0.42, 0.28, 0.16), rough=0.92)
MAT_hierro.node_tree.nodes['Principled BSDF'].inputs['Metallic'].default_value = 0.85

arena(radio=1.4, profundo=0.22)

# ---------- Geometria base ----------
MANGO_Z = 0.0            # plano medio del mango
ESP_MANGO = 0.024        # semi-eje Z uniforme del mango (4.8 cm diametro)
ESP_HOJA  = 0.024        # grosor EFECTIVO de la hoja (mismo que el mango)
F_PLANO6  = math.sin(math.radians(60.0))    # 0.866

# ---------- 1) Mango (eje X) ----------
# Mango largo y fino; uniforme en Z para que toda la generatriz toque el
# suelo (mismo motivo que en el martillo: si fuera conico, solo el maximo
# tocaria -> falla E-50). El "swell" del grip se aplica SOLO en Y.
EST_MANGO = [
    (-1.020, 0.024, 0.020),     # extremo (dentro del pomo)
    (-0.950, 0.028, ESP_MANGO),
    (-0.780, 0.030, ESP_MANGO),     # grip swell (solo Y)
    (-0.500, 0.028, ESP_MANGO),
    (-0.200, 0.026, ESP_MANGO),
    (+0.050, 0.024, ESP_MANGO),
    (+0.085, 0.022, ESP_MANGO),     # final dentro del cuello
]
mango = prisma('SM_Azada_Mango', EST_MANGO, eje='X',
               material=MAT_madera, lados=8, fase=0.0, escena=escena)
mango.location = (0.0, 0.0, MANGO_Z)

# ---------- 2) Hoja trapezoidal (eje X, lados=6 fase=0) ----------
# lados=6 fase=0 es CLAVE: el fondo tiene 2 verts al mismo z (-0.866*ry) en
# y=±0.5*rx, asi la hoja aporta un par de cms a fp_y. Con lados=4 los 4 verts
# de fondo caian todos en y=0 (un solo vertice en la base del diamante) y
# fp_y quedaba en 0.00, fallando E-91.
# El semi-eje Z pedido es ESP_HOJA=0.024; como el efectivo es 0.866*ry,
# pasamos ry = ESP_HOJA/F_PLANO6 = 0.0277.
EST_HOJA = [
    (+0.085, 0.060, ESP_HOJA / F_PLANO6),     # cuello (Y=12cm)
    (+0.200, 0.100, ESP_HOJA / F_PLANO6),
    (+0.325, 0.130, ESP_HOJA / F_PLANO6),     # filo (Y=26cm)
]
hoja = prisma('SM_Azada_Hoja', EST_HOJA, eje='X',
              material=MAT_hierro, lados=6, fase=0.0, escena=escena)
hoja.location = (0.0, 0.0, MANGO_Z)

# ---------- 3) Cuello (union mango -> hoja) ----------
# Caja pequena donde el mango se mete en la hoja. Hierro forjado. La hago
# solo 2 mm mas gruesa que el mango para que NO se convierta en el apoyo
# (con +5 mm el cuello quedaba 8 mm por debajo y levantaba la hoja).
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.075, 0.0, MANGO_Z))
cuello = bpy.context.object
cuello.name = 'SM_Azada_Cuello'
cuello.scale = (0.045, 0.075, ESP_MANGO + 0.002)
cuello.data.materials.append(MAT_hierro)

# ---------- 4) Nervio central de la hoja ----------
# Refuerzo vertical (en Y) que recorre la mitad delantera de la hoja, para
# que NO se lea como una simple placa. Sale 3 mm por delante de la cara
# anterior de la hoja (la que mira a la camara) y se hunde 5 mm en el cuello
# (zona donde se une con el mango).
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.205, 0.0, MANGO_Z + 0.025))
nervio = bpy.context.object
nervio.name = 'SM_Azada_Nervio'
nervio.scale = (0.180, 0.012, 0.008)   # 18 cm largo en X, 12 mm en Y, 8 mm en Z
nervio.data.materials.append(MAT_hierro)

# ---------- 5) Casquillo en el ojo (mismo patron que el hacha) ----------
casquillo = recubrimiento('SM_Azada_Casquillo', EST_MANGO, eje='X',
                          ts=(0.020, 0.045, 0.075), espesor=0.002,
                          material=MAT_hierro, lados=8, fase=0.0,
                          escena=escena)
casquillo.location.z = MANGO_Z

# ---------- 6) Empuñadura de cuero ----------
grip = recubrimiento('SM_Azada_Grip', EST_MANGO, eje='X',
                     ts=(-0.880, -0.820, -0.700, -0.500), espesor=0.002,
                     material=MAT_cuero, lados=8, fase=0.0, escena=escena)
grip.location.z = MANGO_Z

# ---------- 7) Pomo ----------
bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=5, radius=0.028,
                                     location=(-1.028, 0.0, MANGO_Z))
pomo = bpy.context.object
pomo.name = 'SM_Azada_Pomo'
pomo.scale = (0.90, 1.0, 0.80)
pomo.data.materials.append(MAT_madera)

# ---------- 8) Cierre ----------
cerrar_herramienta(escena, '16-Crafting', 'azada',
                   loc_cam=(-1.50, -1.30, 0.55), mira_cam=(-0.20, 0.0, 0.05))

# ---------- 9) Reporte ----------
for o in sorted(piezas(escena), key=lambda p: p.name):
    print('   %-22s z %.4f' % (o.name, zmin_real(o)))
print('AZADA OK — %d SM_' % len(piezas(escena)))