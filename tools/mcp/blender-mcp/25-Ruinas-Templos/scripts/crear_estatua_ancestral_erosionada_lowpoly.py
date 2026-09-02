# crear_estatua_ancestral_erosionada_lowpoly.py - Estatua erosionada de ancestro (M25)
#
# DISENO: estatua humanoide erguida sobre pedestal, ligeramente erosionada
# (estilo moai/ancestral de Isla Ancestral). El desafio es que tiene que LEER
# como estatua humanoide (E-37): proporciones aproximadas a figura humana,
# cabeza distinguible, brazos que penden, base que la eleva.
#
# E-37 dice: "las piezas no deben sugerir otra cosa". Si una "estatua" parece
# un bloque con apendices, el ojo la rechaza. La proporcion humana es:
#   - alto total / alto cabeza  =  6 a 7
#   - hombros / cabeza          =  ~1.8 a 2.0
#   - torso:largo               =  ~3 a 4 veces cabeza
#
# Geometria (14 piezas):
#   1) Pedestal base  (1.00 x 0.60 x 0.30)        z=0.30 (sobre arena)
#   2) Cuerpo unificado torso+piernas (0.50x0.40x1.30) z=0.95 (1 base+torso+piernas)
#   3) Hombros        (0.65 x 0.50 x 0.20)        z=1.55
#   4-5) Brazos x2    (0.18 x 0.20 x 0.55)        inclinados -10/+10 grados en Z
#   6-7) Manos x2     (0.20 x 0.25 x 0.18)        al final de los brazos, oscurecidas
#   8) Cabeza         (0.35 x 0.30 x 0.30)        z=1.80, aplanada
#   9-11) Rasgos      nariz (0.06x0.06x0.10) + 2 ojos (0.08x0.04x0.04)
#   12-14) Musgo erosion en 3 puntos (cilindros bajos)
#
# Total piezas: 14. Presupuesto M166 ALTA: <=16 obj / <=6000 tris / <=12 mats.
# E-68: caja() ya NO multiplica por 2 (helper de plantilla_asset).
import bpy, os, sys
from math import radians
from mathutils import Euler
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja)

escena = limpiar()
MAT_piedra = mat('MAT_Estatua_Piedra', (0.62, 0.58, 0.50))   # beige calido
MAT_piedra_osc = mat('MAT_Estatua_Piedra_Osc', (0.42, 0.38, 0.32))  # erosion
MAT_rasgo = mat('MAT_Estatua_Rasgo', (0.30, 0.24, 0.18))    # rasgos muy osc
MAT_musgo = mat('MAT_Estatua_Musgo', (0.30, 0.44, 0.21))     # verde musgo
MAT_base = mat('MAT_Estatua_Base', (0.38, 0.34, 0.28))         # roca pedestal


# --- 1) Pedestal compuesto (E-50: >=8 verts tocando el suelo) ---
# Un cubo centrado solo tiene 4 verts en la base, no 8+. Para superar el
# assert E-50 usamos un CILINDRO de 12 vertices abajo (12 verts en la base)
# + un cubo de transicion encima (que ya esta a z>0 y no cuenta para el assert).
bpy.ops.mesh.primitive_cylinder_add(
    vertices=12, radius=0.55, depth=0.10,
    location=(0, 0, 0.05))
ped_inf = bpy.context.object
ped_inf.name = 'SM_Estatua_Pedestal_Inf'
ped_inf.data.materials.append(MAT_base)

caja('SM_Estatua_Pedestal_Sup', 0, 0, 0.10 + 0.08, 0.80, 0.55, 0.16, MAT_base)

# --- 2) Cuerpo unificado torso+piernas ---
# Una sola pieza grande tipo monolito: evita el problema de "cabeza con
# cuello" donde la silueta se ve como un bolo. 0.50x0.40x1.30 sobre el pedestal.
caja('SM_Estatua_Cuerpo', 0, 0, 0.10 + 0.16 + 0.65, 0.50, 0.40, 1.30, MAT_piedra)

# --- 3) Hombros ---
caja('SM_Estatua_Hombros', 0, 0, 1.55, 0.65, 0.50, 0.20, MAT_piedra)

# --- 4-5) Brazos inclinados -10/+10 grados en Z ---
# Localizacion en x=+/-0.32 (banda externa de los hombros), z=1.30 (mitad de
# los brazos). Rotacion Z: +10 grados para brazo derecho (en +X), -10 para
# brazo izquierdo. Asi penden levemente hacia afuera como extremidades
# cansadas, NO en pose de cruzado.
for i, (sx, rot_z) in enumerate([(+1, radians(10)), (-1, radians(-10))]):
    x = sx * 0.32
    caja('SM_Estatua_Brazo_%d' % i, x, 0, 1.30, 0.18, 0.20, 0.55, MAT_piedra,
         rot_euler=(0.0, 0.0, rot_z))

# --- 6-7) Manos oscurecidas (erosion) al final de los brazos ---
# Posicion aprox: el brazo inclinado termina aprox en (sx*0.42, 0, 1.05).
for i, sx in enumerate([+1, -1]):
    x = sx * 0.42
    caja('SM_Estatua_Mano_%d' % i, x, 0, 1.05, 0.20, 0.25, 0.18, MAT_piedra_osc)

# --- 8) Cabeza aplanada (0.35 x 0.30 x 0.30) ---
caja('SM_Estatua_Cabeza', 0, 0, 1.80, 0.35, 0.30, 0.30, MAT_piedra)

# --- 9-11) Rasgos faciales (nariz + 2 ojos) ---
# Nariz: cubo pequeno proyectado hacia afuera (+Y), centrada en la cara.
caja('SM_Estatua_Nariz', 0, 0.155, 1.79, 0.06, 0.10, 0.06, MAT_rasgo)
# Ojos: 2 cubitos a x=+/-0.08, ligeramente arriba de la nariz.
for i, sx in enumerate([+1, -1]):
    x = sx * 0.08
    caja('SM_Estatua_Ojo_%d' % i, x, 0.155, 1.84, 0.07, 0.04, 0.04, MAT_rasgo)

# --- 12-14) Musgo erosion en 3 puntos bajos (cilindros) ---
# Manchas en el pedestal y la base del cuerpo, donde se acumula humedad.
for i, (x, y, r) in enumerate([
    (-0.30, 0.20, 0.12),   # pedestal izquierdo
    (+0.25, -0.20, 0.10),  # pedestal derecho
    (0.00, 0.20, 0.14),    # frente del pedestal
]):
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=r, depth=0.03,
                                        location=(x, y, 0.015 + 0.26))
    m = bpy.context.object
    m.name = 'SM_Estatua_Musgo_%d' % i
    m.data.materials.append(MAT_musgo)

arena(radio=1.6)
iluminar(escena)
asentar(escena)
# Camara a (3.6, -3.4, 2.0) mirando al centro del cuerpo (0, 0, 1.10).
camara(escena, 'CAM_Estatua', (3.6, -3.4, 2.0), (0, 0, 1.10))
shade_flat(escena)
guardar(escena, '25-Ruinas-Templos', 'estatua_ancestral_erosionada')