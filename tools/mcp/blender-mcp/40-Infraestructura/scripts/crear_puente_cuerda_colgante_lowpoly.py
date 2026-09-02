# crear_puente_cuerda_colgante_lowpoly.py - Puente de cuerda colgante (M40)
#
# DISENO: puente colgante de tablas. El desafio es la CATENARIA: los cables
# principales cuelgan formando una curva, y las barandillas penden de ellos.
# Si el cable se ve recto, parece un puente rigido con postes. Si el sag es
# exagerado, parece una hamaca.
#
# La catenaria pura es cosh(x). Para un puente con tablero (carga uniforme
# distribuida a lo largo del vano, no del cable), la curva real es una
# PARABOLA. Aproximamos con parabola porque es mas simple y es la correcta
# para este caso:
#     z(x) = z_centro + (x / half_span)^2 * (z_poste - z_centro)
#
# Segmentacion del cable: en lugar de un objeto curvo (difícil en bpy sin
# curvas de Bezier + convert), usamos N segmentos de cilindro cortos, cada
# uno rotado para alinearse con la tangente local de la parabola. Cada
# segmento es un cilindro; la rotacion se calcula con to_track_quat (E-58).
#   6 segmentos (3 por lado) dan una curva suave sin exceder el presupuesto.
#
# Geometria (15 piezas):
#   1-2)   Bases de poste   2 cubos 0.45x0.45x0.12 (E-50: footprint 4.65x0.45)
#   3-4)   Postes           2 cubos 0.18x0.18x1.90 sobre las bases
#   5-10)  Cable principal  6 segmentos de cilindro (3 por lado)
#   11-13) Tablero          3 tablas de madera
#   14-15) Barandillas      2 cuerdas verticales colgando del cable
#
# Total: 15 obj. Presupuesto M166 ALTA: <=16 obj / <=6000 tris / <=12 mats.
# E-68: el helper caja() ya NO multiplica por 2 (dimensiones finales).
import bpy, os, sys
from math import sqrt, atan2
from mathutils import Vector
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja)

escena = limpiar()
MAT_madera = mat('MAT_Puente_Madera', (0.55, 0.40, 0.24))       # tablas
MAT_madera_osc = mat('MAT_Puente_Madera_Osc', (0.36, 0.26, 0.15))  # postes
MAT_cuerda = mat('MAT_Puente_Cuerda', (0.48, 0.42, 0.30))       # cables
MAT_piedra = mat('MAT_Puente_Piedra', (0.40, 0.36, 0.31))       # bases

# --- Constantes ---
HALF_SPAN = 2.20        # |x| de los postes (puente de 4.4 m de largo)
Z_BASE = 0.12           # alto de la base del poste
Z_POSTE_TOP = 1.90      # cota de la cima del poste (arrancan los cables)
Z_CENTRO = 0.95         # cota del cable en el centro (sag de 0.95 m)
SEMI_ANCHO = 0.50       # semiancho del tablero (y de -0.50 a +0.50)
Z_TABLERO = 0.32        # cota del tablero (suelo del puente, 32 cm)
RADIO_CABLE = 0.035     # radio de los cables (3.5 cm)
RADIO_BARAND = 0.025    # radio de las barandillas (2.5 cm)


# --- Catenaria (parabola real para carga uniforme) ---
def z_cable(x):
    """Cota del cable principal en la posicion x."""
    return Z_CENTRO + (x / HALF_SPAN) ** 2 * (Z_POSTE_TOP - Z_CENTRO)


def segmento_cable(nombre, p0, p1, radio, material):
    """Crea un cilindro que va de p0 a p1 (Vector 3D) con el radio dado.

    El cilindro por defecto tiene su eje a lo largo de Z. Lo rotamos con
    to_track_quat('Z', 'Y') para que el eje Z local apunte en la direccion
    p1 - p0 (E-58). La longitud del cilindro es |p1 - p0|.
    """
    direccion = p1 - p0
    largo = direccion.length
    centro = (p0 + p1) / 2.0
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=6, radius=radio, depth=largo, location=centro)
    o = bpy.context.object
    o.name = nombre
    o.rotation_euler = direccion.to_track_quat('Z', 'Y').to_euler()
    o.data.materials.append(material)
    return o


# --- 1-2) Bases de poste y 3-4) postes ---
# E-50: un cubo centrado tiene solo 4 verts en su base. Dos bases dan 8.
#   footprint = 4.65 x 0.45 -> min(fp_x, fp_y) = 0.45 > 0.30. OK.
for i, sx in enumerate((-1, 1)):
    px = sx * HALF_SPAN
    caja('SM_Puente_Base_%d' % i, px, 0, Z_BASE / 2,
         0.45, 0.45, Z_BASE, MAT_piedra)
    caja('SM_Puente_Poste_%d' % i, px, 0, Z_BASE + (Z_POSTE_TOP - Z_BASE) / 2,
         0.18, 0.18, Z_POSTE_TOP - Z_BASE, MAT_madera_osc)

# --- 5-10) Cable principal: 6 segmentos (3 por lado) ---
# Puntos de la parabola: x = -2.20, -0.73, +0.73, +2.20 (4 puntos -> 3
# segmentos por lado -> 6 en total). Con 3 segmentos la parabola se lee
# suficientemente curva para lowpoly. Con 6 por lado (v1) salian 21 objetos
# y se EXCEDIA el presupuesto ALTA de <=16.
# El cable cuelga en y = +/- SEMI_ANCHO (a cada lado del tablero, no en el
# centro del tablero).
xs = [-HALF_SPAN + (HALF_SPAN * 2) * k / 3.0 for k in range(4)]
for lado, y in enumerate((-SEMI_ANCHO, SEMI_ANCHO)):
    for k in range(3):
        p0 = Vector((xs[k], y, z_cable(xs[k])))
        p1 = Vector((xs[k + 1], y, z_cable(xs[k + 1])))
        segmento_cable('SM_Puente_Cable_%d_%d' % (lado, k),
                       p0, p1, RADIO_CABLE, MAT_cuerda)

# --- 11-13) Tablero: 3 tablas a lo ancho del puente ---
# Cada tabla: 0.30 de ancho (en x) x 1.00 de largo (en y) x 0.06 de espesor.
# Distribuidas en x = -1.2, 0, +1.2. Van de y=-0.50 a y=+0.50.
for i, x in enumerate((-1.2, 0.0, 1.2)):
    caja('SM_Puente_Tabla_%d' % i, x, 0, Z_TABLERO,
         0.30, SEMI_ANCHO * 2, 0.06, MAT_madera)

# --- 14-15) Barandillas: 2 cuerdas verticales colgando del cable ---
# Van desde el cable (z_cable(x)) hasta el tablero (Z_TABLERO). Ubicadas en
# x = -1.10 y x = +1.10, una a cada lado (y = -0.50 / +0.50).
for i, (x, y) in enumerate(((-1.10, -SEMI_ANCHO), (1.10, SEMI_ANCHO))):
    zc = z_cable(x)
    p0 = Vector((x, y, zc))
    p1 = Vector((x, y, Z_TABLERO))
    segmento_cable('SM_Puente_Barandilla_%d' % i,
                   p0, p1, RADIO_BARAND, MAT_cuerda)

arena(radio=3.2)
iluminar(escena)
asentar(escena)
# Camara a (4.4, -3.8, 2.2) mirando al centro del puente (0, 0, 1.0).
camara(escena, 'CAM_Puente', (4.4, -3.8, 2.2), (0, 0, 1.0))
shade_flat(escena)
guardar(escena, '40-Infraestructura', 'puente_cuerda_colgante')
