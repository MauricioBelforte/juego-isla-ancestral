# crear_machete_lowpoly.py — Machete (M16-Crafting / M14-Inventario)
# Checklist M16: "Machete"
#
# Pose: APOYADO EN LA ARENA. Mango a lo largo de X (empuñadura corta en -X,
# ~16 cm); HOJA larga (~52 cm) extendiendose hacia +X con la panza (belly)
# mas ancha hacia el centro y el filo afilándose hasta la punta.
#
# DIFERENCIAL vs el hacha/azada/martillo:
#   - La hoja es UNA pieza delgada de acero (lados=4 fase=pi/4 = seccion
#     romboidal: lomo grueso, filo fino). No tiene "cabeza" volumetrica.
#   - La UNION entre mango y hoja es una GUARDA (bolster) metalica plana que
#     ademas protege la mano del filo cuando se corta leña.
#   - El mango se asegura con 2 remaches (rivets) que atraviesan el lomo de
#     la hoja: el "tang" esta dentro del mango. Sin remaches la union parece
#     pegada con cola.
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
from herramienta_util import prisma, cerrar_herramienta          # noqa: E402

escena = limpiar()

# ---------- Materiales ----------
MAT_madera  = mat('MAT_Machete_Madera',  (0.42, 0.27, 0.16), rough=0.85)
MAT_acero   = mat('MAT_Machete_Acero',   (0.68, 0.70, 0.74), rough=0.20,
                  spec=0.70)
MAT_bronce  = mat('MAT_Machete_Bronce',  (0.62, 0.48, 0.22), rough=0.35,
                  spec=0.55)
MAT_acero.node_tree.nodes['Principled BSDF'].inputs['Metallic'].default_value = 0.95
MAT_bronce.node_tree.nodes['Principled BSDF'].inputs['Metallic'].default_value = 0.80

arena(radio=1.2, profundo=0.22)

# ---------- Geometria base ----------
MANGO_Z = 0.0
ESP_MANGO = 0.018            # semi-eje Z uniforme del mango (3.6 cm diam)
F_PLANO4 = math.sin(math.radians(45.0))    # 0.707, seccion romboidal

# ---------- 1) Mango (eje X) ----------
EST_MANGO = [
    (-0.180, 0.022, 0.018),     # pomo (extremo -X)
    (-0.130, 0.026, ESP_MANGO),
    (-0.060, 0.028, ESP_MANGO),     # grip swell
    (-0.020, 0.025, ESP_MANGO),
    (+0.000, 0.024, ESP_MANGO),     # nacimiento dentro de la guarda
]
mango = prisma('SM_Machete_Mango', EST_MANGO, eje='X',
               material=MAT_madera, lados=8, fase=0.0, escena=escena)
mango.location = (0.0, 0.0, MANGO_Z)

# ---------- 2) Guarda (bolster) ----------
# Placa metalica cuadrada que protege la mano del filo y une mango y hoja.
# Es MAS GRUESA que el mango (sz = 0.040 vs 0.036), por eso se convierte en
# el apoyo y aporta fp_y: su y=±0.015 contribuye a ensanchar la huella de
# un objeto que de otra forma seria una linea (E-91).
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.005, 0.0, MANGO_Z))
guarda = bpy.context.object
guarda.name = 'SM_Machete_Guarda'
guarda.scale = (0.015, 0.030, 0.020)   # 1.5 cm en X, 3 cm en Y, 4 cm en Z
guarda.data.materials.append(MAT_bronce)

# ---------- 3) Hoja (eje X, lados=4 fase=pi/4 = rombo) ----------
# Seccion romboidal: lomo arriba (sin=+1), filo abajo (sin=-1). El grosor
# real es 0.707*ry. La hoja debe ir MAS BAJA que el mango para que su lomo
# (no el filo) toque a la par del fondo del mango: z_blade = -0.0145.
# Sin ese offset, el lomo de la hoja (en -ry=-0.0035) quedaba 15 mm por
# encima del fondo del mango (-0.018) -> la hoja flotaba.
Z_HOJA = MANGO_Z - 0.0145
ESP_HOJA = [0.002, 0.005, 0.005, 0.003, 0.001]   # semiejes Z EFECTIVOS
HX_HOJA  = [0.012, 0.030, 0.045, 0.025, 0.005]   # semiejes Y (media-anchura)
X_HOJA   = [0.005, 0.150, 0.350, 0.480, 0.520]   # posicion a lo largo de X
EST_HOJA = [(t, hx, e / F_PLANO4) for (t, hx, e) in zip(X_HOJA, HX_HOJA, ESP_HOJA)]
hoja = prisma('SM_Machete_Hoja', EST_HOJA, eje='X',
              material=MAT_acero, lados=4, fase=math.pi / 4.0,
              escena=escena)
hoja.location = (0.0, 0.0, Z_HOJA)

# ---------- 4) Remaches (rivets) en el lomo de la hoja ----------
# 2 pequeñas semiesferas achatadas sobre el LOMO de la hoja (no sobre el
# filo). Cada una ~1 cm de diametro, ~3 mm de altura. Material bronce para
# contraste. Se unen en 1 solo SM_ para no gastar el presupuesto (E-70).
# El remache sobresale 2 mm sobre el lomo del mango.
bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=4, radius=0.006,
                                     location=(-0.075, 0.0, MANGO_Z + 0.020))
bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=4, radius=0.006,
                                     location=(-0.120, 0.0, MANGO_Z + 0.020))
remaches = [bpy.context.object]
# Recupero los 2 objetos sphere recien creados: el segundo `add` deja al
# primero en escena, el segundo pasa a ser active. Itero seleccionando
# todos los SM_ sin nombre.
sel = [o for o in escena.objects if o.name.startswith('Sphere')]
remaches = sel[-2:]                     # los 2 ultimos
for o in remaches:
    o.scale = (1.0, 1.0, 0.50)
    o.data.materials.append(MAT_bronce)
bpy.ops.object.select_all(action='DESELECT')
for o in remaches:
    o.select_set(True)
bpy.context.view_layer.objects.active = remaches[0]
bpy.ops.object.join()
remache_unido = bpy.context.object
remache_unido.name = 'SM_Machete_Remaches'

# ---------- 5) Pomo ----------
bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=5, radius=0.022,
                                     location=(-0.188, 0.0, MANGO_Z))
pomo = bpy.context.object
pomo.name = 'SM_Machete_Pomo'
pomo.scale = (0.90, 1.0, 0.80)
pomo.data.materials.append(MAT_madera)

# ---------- 6) Cierre ----------
cerrar_herramienta(escena, '16-Crafting', 'machete',
                   loc_cam=(-0.70, -0.90, 0.35), mira_cam=(0.18, 0.0, 0.02))

# ---------- 7) Reporte ----------
for o in sorted(piezas(escena), key=lambda p: p.name):
    print('   %-22s z %.4f' % (o.name, zmin_real(o)))
print('MACHETE OK — %d SM_' % len(piezas(escena)))