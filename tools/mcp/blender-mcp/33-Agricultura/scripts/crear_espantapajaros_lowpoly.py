# crear_espantapajaros_lowpoly.py - Espantapajaros de campos (M33)
#
# DISENO: espantapajaros clasico con sombrero mexicano, DOS BRAZOS SEPARADOS
# que nacen en cada hombro y bajan en diagonal, y camisa rellena de paja. Es el
# "facil" del par de la tarea #56 pero tiene su truco: la silueta debe LEER
# como espantapajaros desde todos los azimuts (E-37), no como "un palo con
# cajas".
#
# E-73 (2026-09-02, feedback del usuario): NADA debe atravesar el pecho.
#   La v1 tenia un unico palo horizontal (SM_Espanta_Brazo, 1.30 x 0.07 x 0.07
#   a z=1.65) cruzando el cuerpo de lado a lado. El usuario lo rechazo de plano:
#   "ese tronco que tiene en el pecho atravesado quitaselo, parece la pinga".
#   Un travesano recto a la altura del pecho lee como falo, no como bracito.
#   Solucion: DOS brazos independientes. Cada uno nace DENTRO del cuerpo
#   (x = +-0.16 < semiancho 0.19) a la altura del hombro y baja en diagonal
#   ~40 grados hacia afuera. El pecho queda limpio y la silueta sigue siendo
#   la "cruz" del espantapajaros.
#   REGLA GENERAL: si una pieza larga y delgada queda HORIZONTAL a la altura
#   de la cadera/torax, mirala con desconfianza. Rompela en dos y angulala.
#
# E-37: las piezas no deben sugerir otra cosa. Senales que lo MATAN:
#   - Sin sombrero  -> lee como "poste con caja"
#   - Sin ojos      -> lee como "poste con camisas"
#   - Sin paja      -> lee como "mueco de feria"
# Por eso hay sombrero (Copa+Ala), 2 ojos, boca, y 2 mechones de paja.
#
# Apoyo (E-50): la base de tierra (cilindro de 12 lados a r=0.40) aporta
# 12 verts en la base, y el poste aporta 1-2 mas -> 13-14 >= 8.
# Huella 0.80 x 0.80, min 0.80 > 0.30.
#
# E-70 (contar ANTES de generar): 16 SM_. Tope ALTA <= 16 -> ESTAMOS EN EL
#   TECHO, no entra ni una pieza mas.
#   1 base + 1 poste + 2 brazos + 2 manos + 1 cuerpo + 1 cabeza + 1 cuerda
#   + 1 sombrero copa + 1 sombrero ala + 2 ojos + 1 boca + 2 pajas = 16.
#   MEDIA/BAJA NO suben: generar_variante.py fusiona por LISTA DE MATERIALES,
#   y los 2 brazos comparten MAT_madera con el poste -> siguen siendo 1 objeto
#   fusionado. MEDIA se queda en 7 obj, BAJA en 6.
#
# Tabla de piezas:
#   1)  Base_Tierra     cil 12 lados r=0.40 h=0.08   z=0.085
#   2)  Poste           cil  8 lados r=0.05 h=2.30   z=1.195
#   3-4) Brazos x2      caja 0.50 x 0.07 x 0.07      hombro (+-0.16, 1.62)
#                                                    -> mano (+-0.543, 1.299)
#                       rot Y = 40 grados (el +X) y 140 grados (el -X)
#   5-6) Manos x2       caja 0.17 x 0.20 x 0.17      x=+-0.58 z=1.28
#   7)  Cuerpo (camisa) caja 0.38 x 0.26 x 0.65      z=1.40
#   8)  Cabeza (saco)   caja 0.24 x 0.22 x 0.24      z=1.85
#   9)  Cuerda (atadura) cil 8 lados r=0.13 h=0.04   z=1.95
#   10) Sombrero Copa   cil 8 lados r=0.14 h=0.20    z=2.07
#   11) Sombrero Ala    cil 12 lados r=0.32 h=0.04   z=2.00
#   12-13) Ojos x2      caja 0.06 x 0.02 x 0.04      y=+0.115 x=+-0.05 z=1.86
#   14) Boca            caja 0.08 x 0.02 x 0.03      y=+0.115 x=0 z=1.79
#   15-16) Pajas x2     cil 6 lados r=0.10 h=0.20    eje en Y, y=+-0.23 z=1.40
#
# Presupuesto M166 ALTA: <=16 obj / <=6000 tris / <=12 mats.
#   16 obj · ~282 tris · 7 mats -> OK (objetos en el techo exacto).
#
# E-68: caja() NO multiplica por 2.
import bpy, os, sys
from math import radians, cos, sin, pi
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja)

escena = limpiar()

MAT_paja = mat('MAT_Espanta_Paja', (0.78, 0.65, 0.40))
MAT_madera = mat('MAT_Espanta_Madera', (0.48, 0.34, 0.20))
MAT_trapo = mat('MAT_Espanta_Trapo', (0.36, 0.28, 0.18))
MAT_cara = mat('MAT_Espanta_Cara', (0.82, 0.70, 0.55))
MAT_rasgos = mat('MAT_Espanta_Rasgos', (0.18, 0.13, 0.10))
MAT_cuerda = mat('MAT_Espanta_Cuerda', (0.45, 0.32, 0.20))
MAT_tierra = mat('MAT_Espanta_Tierra', (0.32, 0.22, 0.12))


def cil_y(nombre, x, y, z, radio, largo, lados, material):
    """Cilindro con el EJE a lo largo de Y (E-58)."""
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=lados, radius=radio, depth=largo, location=(x, y, z))
    o = bpy.context.object
    o.name = nombre
    o.rotation_euler = (radians(90.0), 0.0, 0.0)
    o.data.materials.append(material)
    return o


# --- 1) Base de tierra (E-50: 12 verts en el suelo) ---
bpy.ops.mesh.primitive_cylinder_add(
    vertices=12, radius=0.40, depth=0.08, location=(0.0, 0.0, 0.085))
bpy.context.object.name = 'SM_Espanta_Base_Tierra'
bpy.context.object.data.materials.append(MAT_tierra)

# --- 2) Poste vertical (palo) ---
bpy.ops.mesh.primitive_cylinder_add(
    vertices=8, radius=0.05, depth=2.30, location=(0.0, 0.0, 0.045 + 1.15))
bpy.context.object.name = 'SM_Espanta_Poste'
bpy.context.object.data.materials.append(MAT_madera)

# --- 3-4) Brazos: DOS palos separados, uno por hombro, que BAJAN en diagonal ---
# E-73: nada cruza el pecho. Cada brazo nace DENTRO del cuerpo (x=+-0.16, por
# debajo del semiancho 0.19 del torso) a la altura del hombro y se abre hacia
# afuera y hacia abajo 40 grados. El pecho queda despejado.
ANG_BRAZO = radians(40.0)      # inclinacion respecto de la horizontal
L_BRAZO = 0.50                 # largo del palo
G_BRAZO = 0.07                 # espesor
X_HOMBRO = 0.16                # adentro del torso -> el brazo "nace" de el
Z_HOMBRO = 1.62                # altura del hombro (torso llega a 1.725)
X_MANO = X_HOMBRO + L_BRAZO * cos(ANG_BRAZO)   # 0.543
Z_MANO = Z_HOMBRO - L_BRAZO * sin(ANG_BRAZO)   # 1.299
X_BRAZO = (X_HOMBRO + X_MANO) / 2.0            # centro del palo
Z_BRAZO = (Z_HOMBRO + Z_MANO) / 2.0

for i, sx in enumerate((-1, +1)):
    # Rotando sobre Y por b, el eje local +X del cubo apunta a
    # (cos b, 0, -sin b). Con b = ANG_BRAZO el extremo +X BAJA; con
    # b = 180 - ANG_BRAZO el extremo apunta a -X y tambien baja.
    rot_y = (pi - ANG_BRAZO) if sx < 0 else ANG_BRAZO
    caja('SM_Espanta_Brazo_%d' % i, sx * X_BRAZO, 0.0, Z_BRAZO,
         L_BRAZO, G_BRAZO, G_BRAZO, MAT_madera, rot_euler=(0.0, rot_y, 0.0))

# --- 5-6) Manos (paja asomando de la punta de cada brazo) ---
for i, sx in enumerate((-1, +1)):
    caja('SM_Espanta_Mano_%d' % i, sx * 0.58, 0.0, 1.28, 0.17, 0.20, 0.17, MAT_paja)

# --- 7) Cuerpo (la camisa, ancha y rellena) ---
# El torso mide 0.38 en X -> semiancho 0.19. El hombro del brazo entra en
# x=0.16, o sea 3 cm ADENTRO de la superficie: el brazo nunca flota (E-24).
caja('SM_Espanta_Cuerpo', 0.0, 0.0, 1.40, 0.38, 0.26, 0.65, MAT_paja)

# --- 8) Cabeza (el saco) ---
caja('SM_Espanta_Cabeza', 0.0, 0.0, 1.85, 0.24, 0.22, 0.24, MAT_cara)

# --- 9) Cuerda (atadura del cuello) ---
bpy.ops.mesh.primitive_cylinder_add(
    vertices=8, radius=0.13, depth=0.04, location=(0.0, 0.0, 1.95))
bpy.context.object.name = 'SM_Espanta_Cuerda'
bpy.context.object.data.materials.append(MAT_cuerda)

# --- 10-11) Sombrero (Copa + Ala) ---
bpy.ops.mesh.primitive_cylinder_add(
    vertices=8, radius=0.14, depth=0.20, location=(0.0, 0.0, 2.07))
bpy.context.object.name = 'SM_Espanta_Sombrero_Copa'
bpy.context.object.data.materials.append(MAT_trapo)
bpy.ops.mesh.primitive_cylinder_add(
    vertices=12, radius=0.32, depth=0.04, location=(0.0, 0.0, 2.00))
bpy.context.object.name = 'SM_Espanta_Sombrero_Ala'
bpy.context.object.data.materials.append(MAT_trapo)

# --- 12-13) Ojos (en la cara frontal +Y) ---
for i, sx in enumerate((-1, +1)):
    caja('SM_Espanta_Ojo_%d' % i, sx * 0.05, 0.115, 1.86, 0.06, 0.02, 0.04, MAT_rasgos)

# --- 14) Boca ---
caja('SM_Espanta_Boca', 0.0, 0.115, 1.79, 0.08, 0.02, 0.03, MAT_rasgos)

# --- 15-16) Pajas de los costados (cilindros con eje en Y) ---
cil_y('SM_Espanta_Paja_0', 0.0, -0.23, 1.40, 0.10, 0.20, 6, MAT_paja)
cil_y('SM_Espanta_Paja_1', 0.0, +0.23, 1.40, 0.10, 0.20, 6, MAT_paja)

arena(radio=2.0)
iluminar(escena)
asentar(escena)
camara(escena, 'CAM_Espanta', (2.6, -2.4, 1.4), (0.0, 0.0, 1.10))
shade_flat(escena)
guardar(escena, '33-Agricultura', 'espantapajaros')