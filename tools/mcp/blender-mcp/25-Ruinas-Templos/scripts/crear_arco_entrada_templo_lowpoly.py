# crear_arco_entrada_templo_lowpoly.py - Arco de entrada de templo (M25)
#
# DISENO: arco de medio punto. El desafio es que tiene un VANO (span):
# dos apoyos separados en X unidos por una semicircunferencia arriba.
# Si el vano no se lee, parece dos columnas pegadas. Si las dovelas no
# cierran, parece un arco roto.
#
# Geometria:
#   - Semicircunferencia de radio R=0.90 centrada en (0, 0, SPRING).
#   - 7 dovelas (voussoirs) a 180/7 grados cada una, caja radial.
#   - Cada dovela: eje local +Z apunta al exterior (radial), Y = profundidad.
#     Rotacion sobre Y: alpha = 90 - theta  (local Z = (sin a, 0, cos a)
#     debe igualar el radial (cos t, 0, sin t) -> a = 90 - t).
#   - Cuerda del arco para que las dovelas se toquen:
#     chord = 2*R*sin(delta/2), delta = 180/7 = 25.714 grados -> 0.4005
#   - Rotacion sobre Y: local +Z' = (-sin a, 0, cos a). Para igualar al radial
#     (cos t, 0, sin t): -sin a = cos t, cos a = sin t  =>  a = t - 90.
#     (E-58: to_track_quat vendria bien, pero aca la rotacion es 1D.)
import bpy, os, sys
from math import radians, cos, sin, pi
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja)

escena = limpiar()
MAT_piedra = mat('MAT_Arco_Piedra', (0.62, 0.60, 0.55))
MAT_osc = mat('MAT_Arco_Piedra_Osc', (0.42, 0.40, 0.36))
MAT_musgo = mat('MAT_Arco_Musgo', (0.30, 0.44, 0.21))

# --- Constantes del arco ---
R = 0.90        # radio a la linea media de las dovelas
N_DOVELAS = 7
PX = 0.90       # |x| de los pilares (coincide con R: el arco arranca de ahi)
SEMI_Y = 0.225  # semiprofundidad de pilares
SPRING = 2.64   # cota de arranque del arco (top del capitel)

# --- 1) Basas (z 0 -> 0.12) y pilares (0.12 -> 2.48) y capiteles (2.48 -> 2.64).
# E-68: el helper caja() (plantilla_asset.py) ya NO multiplica por 2. Las
# dimensiones aqui son las finales del cubo (sx*sy*sz en metros), no la mitad.
for i, sx in enumerate((-1, 1)):
    px = sx * PX
    caja('SM_Arco_Basa_%d' % i, px, 0, 0.06, 0.64, 0.64, 0.12, MAT_osc)
    caja('SM_Arco_Pilar_%d' % i, px, 0, 1.30, 0.45, SEMI_Y * 2, 2.36, MAT_piedra)
    caja('SM_Arco_Capitel_%d' % i, px, 0, 2.56, 0.60, 0.60, 0.16, MAT_piedra)

# --- 2) Dovelas: 7 cajas radiales equiespaciadas de springer a springer.
# delta = pi/(N-1) (no pi/N), para que la primera y la ultima caigan
# EXACTAMENTE sobre los springers de los pilares (theta=0 y theta=pi).
# La dovela 0 (theta=0) se entierra ~6cm en el pilar por construccion
# (overlap geometrico = sustento). La central (i=3, theta=pi/2) oficia de clave.
#
# ATENCION E-68 (cube_add con size=1): primitive_cube_add(size=1, scale=s)
# produce un cubo de sx*sy*sz, NO de 2*sx*2*sy*2*sz. Por eso aca NO se divide
# por 2: ANCHO_D ya es la dimension tangencial final de la dovela, y RADIAL
# ya es la dimension radial final. Si se divide por 2 (como en v3), las
# dovelas quedan a la mitad de ancho -> gaps de 25cm entre dovelas.
#
# ANCHO_D = chord * 1.04 (no 0.96) -> 4% de overlap para absorber el wedge
# gap de las dovelas rectangulares en arco circular (las caras laterales
# no son radiales puras).
delta = pi / (N_DOVELAS - 1)                  # 180/6 = 30 grados
chord = 2 * R * sin(delta / 2.0)              # 0.466
ANCHO_D = chord * 1.04                        # ~0.485, overlap 4% absorbe wedge
RADIAL = 0.30                                 # espesor radial de la dovela

for i in range(N_DOVELAS):
    theta = delta * i                         # 0, 30, 60, 90, 120, 150, 180
    x = R * cos(theta)
    z = SPRING + R * sin(theta)
    alpha = theta - radians(90.0)             # rotacion sobre Y (ver docstring)
    if i == N_DOVELAS // 2:
        sx, sy, sz = ANCHO_D * 1.20, SEMI_Y * 1.10, RADIAL * 1.25
        mat_i = MAT_osc
    else:
        sx, sy, sz = ANCHO_D, SEMI_Y, RADIAL
        mat_i = MAT_piedra if (i % 2) else MAT_osc
    caja('SM_Arco_Dov_%d' % i, x, 0, z, sx, sy, sz, mat_i,
         rot_euler=(0.0, alpha, 0.0))

# --- 4) Musgo en las basas (manchas bajas, se ve erosion) ---
for i, sx in enumerate((-1, 1)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.19, depth=0.05,
                                        location=(sx * PX, 0, 0.025))
    m = bpy.context.object
    m.name = 'SM_Arco_Musgo_%d' % i
    m.data.materials.append(MAT_musgo)

arena(radio=1.8)
iluminar(escena)
asentar(escena)
camara(escena, 'CAM_Arco', (4.6, -4.4, 2.7), (0, 0, 2.0))
shade_flat(escena)
guardar(escena, '25-Ruinas-Templos', 'arco_entrada_templo')
