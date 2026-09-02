# crear_carretilla_minero_lowpoly.py - Carretilla de minero (M35)
#
# DISENO: carretilla de UNA rueda delantera + 2 patas traseras + batea de
# madera (cajon abierto) cargada con mineral. Es el asset "dificil" de M35
# por dos motivos:
#
#   1) La BATEA es un TRONCO DE PIRAMIDE: los laterales se ABREN hacia arriba
#      (abertura ~16.7 grados). Un cajon de paredes verticales lee como caja,
#      no como carretilla.
#   2) El APOYO es un TRIPODE (rueda delantera + 2 patas traseras), no una
#      base plana. E-50 exige >=8 verts tocando y min(fp_x, fp_y) > 0.30.
#      Las 2 patas (cajas) aportan 4 verts c/u = 8, y la rueda suma 1-2 mas
#      dentro de la tolerancia de 5 mm -> 9-10. Huella 1.51 x 0.60.
#
# E-70 (contar ANTES de generar): 15 SM_. Tope ALTA <= 16.
#   1 rueda + 1 eje + 2 largueros + 5 batea + 2 patas + 2 mangos + 2 mineral
#   = 1+1+2+5+2+2+2 = 15.
#
# Tabla de piezas:
#   1)   Rueda         cil 14 lados r=0.24 w=0.09   x=+0.75 z=0.285  (eje en Y)
#   2)   Eje           cil  8 lados r=0.035 w=0.60  x=+0.75 z=0.285  (eje en Y)
#   3-4) Largueros x2  caja 1.53 x 0.07 x 0.09      y=+-0.26 z=0.30
#   5)   Batea_Fondo   caja 1.00 x 0.64 x 0.06      z=0.375
#   6-7) Batea_Lat x2  caja 1.00 x 0.05 x 0.30      abiertos +-16.7 en X, z=0.555
#   8)   Batea_Front   caja 0.05 x 0.73 x 0.30      x=+0.50, +14 en Y, z=0.555
#   9)   Batea_Tras    caja 0.05 x 0.73 x 0.30      x=-0.50, z=0.555
#   10-11) Patas x2    caja 0.08 x 0.08 x 0.255     x=-0.72 y=+-0.26 z=0.1725
#   12-13) Mangos x2   caja 0.457 x 0.09 x 0.09     de (-0.78,0.30) a (-1.20,0.48)
#   14-15) Mineral x2  cil 6 lados, apoyados en el piso de la batea (z=0.405)
#
# Presupuesto M166 ALTA: <=16 obj / <=6000 tris / <=12 mats.
#   15 obj · ~300 tris · 4 mats -> OK.
#
# E-68: caja() NO multiplica por 2 (helper de plantilla_asset). Los sx/sy/sz
# de abajo son las DIMENSIONES FINALES del cubo, no semidimensiones.
#
# E-60: las piezas apoyadas sobre OTRAS piezas NO usan Z_APOYO. Aqui el piso
# de la batea (z=0.345) se apoya en el lomo de los largueros (z=0.345) y el
# mineral (z=0.405) se apoya en la cara superior del piso de la batea.
import bpy, os, sys
from math import radians, sqrt, atan2
from mathutils import Vector
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja)

escena = limpiar()

MAT_madera = mat('MAT_Carre_Madera', (0.55, 0.38, 0.22))
MAT_madera_osc = mat('MAT_Carre_Madera_Osc', (0.36, 0.24, 0.14))
MAT_hierro = mat('MAT_Carre_Hierro', (0.30, 0.30, 0.34), rough=0.55, spec=0.30)
MAT_mineral = mat('MAT_Carre_Mineral', (0.42, 0.46, 0.52), rough=0.70, spec=0.25)


def cil_eje_y(nombre, x, y, z, radio, largo, lados, material):
    """Cilindro con el EJE a lo largo de Y (rueda, eje, travesanos).

    primitive_cylinder_add crea el cilindro a lo largo de Z local (E-58).
    Rotar +90 sobre X manda el eje local +Z a -Y, asi que la rueda queda
    "de pie" (plano de rodadura XZ) y su ancho va por Y.
    """
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=lados, radius=radio, depth=largo, location=(x, y, z))
    o = bpy.context.object
    o.name = nombre
    o.rotation_euler = (radians(90.0), 0.0, 0.0)
    o.data.materials.append(material)
    return o


# --- Constantes de diseno ---
Z_SUELO = 0.045          # E-12: las 3 patas del tripode tocan aqui
R_RUEDA = 0.24
X_RUEDA = 0.75           # adelantada para que no atraviese el frente de la batea
Z_EJE = Z_SUELO + R_RUEDA          # 0.285
Y_RAIL = 0.26
Z_RAIL = 0.30
S_RAIL = 0.09            # alto del larguero -> lomo en 0.345
X_RAIL_A, X_RAIL_B = -0.78, X_RUEDA
L_RAIL = X_RAIL_B - X_RAIL_A                      # 1.53
X_RAIL_C = (X_RAIL_A + X_RAIL_B) / 2.0            # -0.015

# Batea: el piso APOYA sobre el lomo de los largueros (E-60, no usa Z_APOYO).
Z_PISO = S_RAIL / 2.0 + Z_RAIL + 0.03             # 0.375 -> cara sup en 0.405
S_PISO = 0.06
Z_CARASUP_PISO = Z_PISO + S_PISO / 2.0            # 0.405
H_LAT = 0.30
Z_LAT = Z_CARASUP_PISO + H_LAT / 2.0              # 0.555
SEMI_Y_BAJO = 0.32       # mitad del ancho del piso
ABERTURA = 0.09          # cuanto se abre cada lateral hacia arriba
SEMI_Y_ALTO = SEMI_Y_BAJO + ABERTURA              # 0.41
Y_LAT = (SEMI_Y_BAJO + SEMI_Y_ALTO) / 2.0         # 0.365
ANG_LAT = atan2(ABERTURA, H_LAT)                  # ~16.7 grados
INCLIN_FRONT = radians(14.0)


# --- 1) Rueda: cilindro de 14 lados con el eje en Y ---
# El punto mas bajo queda en Z_SUELO porque el centro esta en Z_EJE y el
# radio es R_RUEDA (0.285 - 0.24 = 0.045).
cil_eje_y('SM_Carre_Rueda', X_RUEDA, 0.0, Z_EJE, R_RUEDA, 0.09, 14, MAT_hierro)

# --- 2) Eje: atraviesa los dos largueros (y = +-0.26) de lado a lado ---
cil_eje_y('SM_Carre_Eje', X_RUEDA, 0.0, Z_EJE, 0.035, 0.60, 8, MAT_hierro)

# --- 3-4) Largueros: vigas longitudinales horizontales ---
# Van del eje (adelante) hasta el arranque de los mangos (atras). Son los que
# soportan el piso de la batea: su lomo (z=0.345) es la cota de apoyo (E-60).
for i, sy in enumerate((-1, +1)):
    caja('SM_Carre_Larguero_%d' % i, X_RAIL_C, sy * Y_RAIL, Z_RAIL,
         L_RAIL, 0.07, S_RAIL, MAT_madera_osc)

# --- 5) Piso de la batea ---
caja('SM_Carre_Batea_Fondo', 0.0, 0.0, Z_PISO, 1.00, SEMI_Y_BAJO * 2, S_PISO,
     MAT_madera)

# --- 6-7) Laterales abiertos (tronco de piramide) ---
# Rotacion sobre X: el eje local +Z va a (0, -sin a, cos a). Con a > 0 la
# cara superior se inclina hacia -Y, que es lo que necesita el lateral
# IZQUIERDO (y negativo). El derecho usa a < 0.
for i, sy in enumerate((-1, +1)):
    caja('SM_Carre_Batea_Lat_%d' % i, 0.0, sy * Y_LAT, Z_LAT,
         1.00, 0.05, H_LAT, MAT_madera,
         rot_euler=(sy * -ANG_LAT, 0.0, 0.0))

# --- 8) Frente inclinado (tabla delantera, se recuesta hacia adelante) ---
# Rotacion sobre Y: el eje local +Z va a (sin b, 0, cos b). Con b > 0 la cara
# superior se inclina hacia +X = "se recuesta hacia adelante".
caja('SM_Carre_Batea_Front', 0.50, 0.0, Z_LAT, 0.05, 0.73, H_LAT, MAT_madera,
     rot_euler=(0.0, INCLIN_FRONT, 0.0))

# --- 9) Trasera (tabla vertical, la que empuja la carga) ---
caja('SM_Carre_Batea_Tras', -0.50, 0.0, Z_LAT, 0.05, 0.73, H_LAT, MAT_madera)

# --- 10-11) Patas: del larguero al suelo, detras de la batea ---
# Son las que mas verts aportan al assert E-50 (4 cada una).
X_PATA = -0.72
H_PATA = Z_RAIL - S_RAIL / 2.0 - Z_SUELO          # 0.255
for i, sy in enumerate((-1, +1)):
    caja('SM_Carre_Pata_%d' % i, X_PATA, sy * Y_RAIL,
         Z_SUELO + H_PATA / 2.0, 0.08, 0.08, H_PATA, MAT_madera_osc)

# --- 12-13) Mangos: suben desde el larguero hacia atras ---
# Van de (-0.78, z=0.30) a (-1.20, z=0.48): los agarra el minero.
p_lo = Vector((-0.78, 0.0, 0.30))
p_hi = Vector((-1.20, 0.0, 0.48))
d = p_hi - p_lo
L_MANGO = d.length                                # 0.457
# Rotacion sobre Y con b>0 manda el eje local +X a (cos b, 0, -sin b).
# Queremos alinear +X con la direccion del mango.
ANG_MANGO = atan2(d.z, d.x) * -1.0                # +23.2 grados
for i, sy in enumerate((-1, +1)):
    caja('SM_Carre_Mango_%d' % i, (p_lo.x + p_hi.x) / 2.0, sy * Y_RAIL,
         (p_lo.z + p_hi.z) / 2.0, L_MANGO, 0.09, 0.09, MAT_madera_osc,
         rot_euler=(0.0, ANG_MANGO, 0.0))

# --- 14-15) Mineral: 2 tepes apoyados en la cara superior del piso (E-60) ---
for i, (x, y, r, h) in enumerate([
    (-0.18, 0.08, 0.15, 0.32),   # tepe grande, asoma sobre el borde
    (0.16, -0.14, 0.12, 0.24),   # tepe chico
]):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=6, radius=r, depth=h,
        location=(x, y, Z_CARASUP_PISO + h / 2.0))
    m = bpy.context.object
    m.name = 'SM_Carre_Mineral_%d' % i
    m.data.materials.append(MAT_mineral)

arena(radio=2.2)
iluminar(escena)
asentar(escena)
# Camara: el asset mide ~2.4 m de largo (x -1.20..0.99), ~0.8 de ancho.
camara(escena, 'CAM_Carretilla', (2.9, -2.6, 1.7), (0.0, 0.0, 0.45))
shade_flat(escena)
guardar(escena, '35-Mineria', 'carretilla_minero')
