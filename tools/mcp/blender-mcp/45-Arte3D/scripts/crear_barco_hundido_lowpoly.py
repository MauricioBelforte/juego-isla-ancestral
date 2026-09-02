# crear_barco_hundido_lowpoly.py — Barco hundido (playa) (M45)
# Checklist: "Barco hundido (playa)"
#
# DECISION DE DISENO:
#   Un naufragio varado en la playa: casco apoyado, proa apuntando al mar, mastil
#   QUEBRADO e inclinado, costillas expuestas donde la madera se fue, y un medano
#   de arena que lo cubre parcialmente por popa (la lectura de "hundido" la da el
#   medano, no una inclinacion del casco).
#
#   Por que el casco NO va inclinado: un casco "tumbado" 30 grados apoya sobre una
#   ARISTA (2 vertices) y cae en el assert E-50 de apoyo puntual. Como ademas la
#   pieza mas baja definiria el asentado (E-24), inclinar el casco levantaria todas
#   las demas piezas y dejaria el mastil colgando. El medano resuelve las dos cosas:
#   da una huella ancha Y cuenta la historia de "enterrado en la arena".
import bpy
import os
import sys
from math import radians, sin, cos

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar,
                             camara, shade_flat, guardar)

escena = limpiar()

MAT_madera = mat('MAT_Barco_Madera', (0.42, 0.28, 0.16))
MAT_madera_osc = mat('MAT_Barco_Madera_Osc', (0.29, 0.18, 0.10))
MAT_arena = mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# --- 1) Casco: caja 2.20 x 0.75 x 0.78 con la base exactamente en z=0 ---
MITAD_ALTO = 0.39          # 0.78 / 2
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, MITAD_ALTO))
casco = bpy.context.object
casco.name = 'SM_Barco_Casco'
casco.scale = (2.20, 0.75, 0.78)
casco.data.materials.append(MAT_madera)

# --- 2) Proa: cono de 4 vertices apuntando a +X ---
# Radio = MITAD_ALTO para que su vertice inferior quede en z=0, IGUAL que el
# casco. Si el radio fuera mayor, la proa seria la pieza mas baja y el asentado
# levantaria TODO el barco, dejando el casco flotando (mismo bug que las raices
# inclinadas del arbol frutal).
PROA_L = 0.85
bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=MITAD_ALTO, radius2=0.0,
                                depth=PROA_L,
                                location=(1.10 + PROA_L / 2, 0, MITAD_ALTO))
proa = bpy.context.object
proa.name = 'SM_Barco_Proa'
proa.rotation_euler = (0.0, radians(90), 0.0)   # Ry(90) manda el apex a +X
bpy.context.view_layer.update()
proa.data.materials.append(MAT_madera_osc)

# --- 3) Mastil QUEBRADO e inclinado ---
# Nace DENTRO del casco (E-60: pieza apoyada sobre otra pieza, no usa Z_APOYO).
MAST_L = 1.60
MAST_INC = radians(28)
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.085, depth=MAST_L,
                                    location=(0.30, 0, MITAD_ALTO + MAST_L / 2 * cos(MAST_INC)))
mastil = bpy.context.object
mastil.name = 'SM_Barco_Mastil'
mastil.rotation_euler = (0.0, MAST_INC, 0.0)
bpy.context.view_layer.update()
mastil.data.materials.append(MAT_madera_osc)

# --- 4) 3 costillas expuestas (la madera del casco se fue y quedan los nervios) ---
for i, x in enumerate((-0.65, 0.05, 0.75)):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(x, 0, 0.55))
    c = bpy.context.object
    c.name = 'SM_Barco_Costilla_%d' % i
    c.scale = (0.07, 0.95, 0.07)
    c.rotation_euler = (radians(90 - 12 * (i - 1)), 0.0, 0.0)
    bpy.context.view_layer.update()
    c.data.materials.append(MAT_madera_osc if i % 2 else MAT_madera)

# --- 5) Medano: entierra la popa y garantiza la huella (E-50) ---
# Cilindro bajo de 12 lados -> 12 vertices apoyando, huella ~1.7 m.
bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.85, depth=0.30,
                                    location=(-1.00, 0, 0.15))
medano = bpy.context.object
medano.name = 'SM_Barco_Medano'
medano.data.materials.append(MAT_arena)

arena(radio=2.6)
iluminar(escena)
asentar(escena)
camara(escena, 'CAM_BarcoHundido', (3.2, -3.8, 1.9), (0, 0, 0.5))
shade_flat(escena)
guardar(escena, '45-Arte3D', 'barco_hundido')
