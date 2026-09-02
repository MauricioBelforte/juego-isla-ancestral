# crear_coral_abanico_lowpoly.py — Coral abanico (M45)
# Checklist: "Coral abanico"
#
# DECISION DE DISENO:
#   Abanico de mar: pie corto y angosto que se abre en un abanico PLANO y ancho
#   hacia arriba. Se logra con un cono invertido (radio1 angosto abajo, radio2
#   ancho arriba) APLANADO en Y con scale (1, 0.09, 1) -> una lamina vertical.
#   Dos ramas inclinadas a los lados sugieren la ramificacion del coral.
#   Se apoya sobre una base cilindrica de roca/arena de 12 lados: el abanico es
#   una lamina (casi 0 espesor) y por si solo apoyaria sobre 2 vertices -> E-50.
import bpy
import os
import sys
from math import radians, sin, cos

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar,
                             camara, shade_flat, guardar)

escena = limpiar()

MAT_coral = mat('MAT_Coral_Abanico', (0.95, 0.45, 0.42), rough=0.80)
MAT_coral_osc = mat('MAT_Coral_Osc', (0.78, 0.31, 0.34), rough=0.85)
MAT_roca = mat('MAT_Coral_Roca', (0.46, 0.44, 0.42), rough=1.00)

BASE_ALTO = 0.14

# --- 1) Base: 12 vertices apoyando (E-50) ---
bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.24, depth=BASE_ALTO,
                                    location=(0, 0, BASE_ALTO / 2))
base = bpy.context.object
base.name = 'SM_Coral_Base'
base.data.materials.append(MAT_roca)

# --- 2) Abanico: cono angosto abajo / ancho arriba, aplanado en Y ---
ABANICO_L = 1.10
bpy.ops.mesh.primitive_cone_add(vertices=14, radius1=0.13, radius2=0.85,
                                depth=ABANICO_L,
                                location=(0, 0, BASE_ALTO + ABANICO_L / 2))
abanico = bpy.context.object
abanico.name = 'SM_Coral_Abanico'
abanico.scale = (1.0, 0.09, 1.0)      # lamina vertical
bpy.context.view_layer.update()
abanico.data.materials.append(MAT_coral)

# --- 3) Dos ramas inclinadas a los lados (sugieren ramificacion) ---
RAMA_L = 0.70
RAMA_INC = radians(32)
for i, lado in enumerate((-1, 1)):
    # E-58: alinear el eje +Z del cilindro con la direccion deseada
    # mediante to_track_quat (no trig manual).
    dx = lado * sin(RAMA_INC)
    dz = cos(RAMA_INC)
    bpy.ops.mesh.primitive_cylinder_add(vertices=5, radius=0.035, depth=RAMA_L,
                                        location=(lado * 0.20, 0,
                                                  BASE_ALTO + RAMA_L / 2 * dz))
    r = bpy.context.object
    r.name = 'SM_Coral_Rama_%d' % i
    from mathutils import Vector
    r.rotation_euler = Vector((dx, 0.0, dz)).to_track_quat('Z', 'Y').to_euler()
    bpy.context.view_layer.update()
    r.data.materials.append(MAT_coral_osc if i else MAT_coral)

arena(radio=1.8)
iluminar(escena)
asentar(escena)
camara(escena, 'CAM_CoralAbanico', (1.7, -2.0, 1.0), (0, 0, 0.6))
shade_flat(escena)
guardar(escena, '45-Arte3D', 'coral_abanico')
