# crear_ancla_naufragio_lowpoly.py — Ancla de naufragio (M45)
# Checklist: "Ancla de naufragio"
#
# DECISION DE DISENO:
#   Ancla de hierro oxidado TENDIDA y plana sobre la arena, medio enterrada:
#   cana (mastil del ancla) a lo largo de X, cepo (travesano perpendicular) en el
#   extremo -X, anillo de amarre mas alla, y dos brazos que se abren en Y en el
#   extremo +X con sus uñas conicas.
#
#   CLAVE DE APOYO: el ancla va ACOSTADA y TODA al mismo nivel (cada pieza con su
#   cota inferior en z=0), no apoyada sobre un medano. Motivo: los brazos llegan
#   hasta x=1.65, mucho mas alla del medano, y si el ancla se apoyara sobre el
#   medano los brazos quedarian colgando 24 cm sobre la arena (E-60 mal aplicado).
#   El medano es bajo (0.18) y solo ENTIERRA el medio de la cana: la pieza mas
#   baja sigue siendo la cana, asi que el asentado no descalibra nada.
import bpy
import os
import sys
from math import radians, sin, cos
from mathutils import Vector

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar,
                             camara, shade_flat, guardar)

escena = limpiar()

MAT_hierro = mat('MAT_Ancla_Hierro', (0.46, 0.26, 0.16), rough=0.95, spec=0.25)
MAT_hierro_osc = mat('MAT_Ancla_Hierro_Osc', (0.30, 0.18, 0.12), rough=0.98, spec=0.20)
MAT_arena = mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# --- 1) Cana (mastil del ancla): acostada a lo largo de X ---
CANA_R = 0.10
CANA_L = 1.90
bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=CANA_R, depth=CANA_L,
                                    location=(0.0, 0, CANA_R))
cana = bpy.context.object
cana.name = 'SM_Ancla_Cana'
cana.rotation_euler = (0.0, radians(90), 0.0)
bpy.context.view_layer.update()
cana.data.materials.append(MAT_hierro)

# --- 2) Cepo (travesano): perpendicular a la cana, a lo largo de Y ---
CEPO_R = 0.07
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=CEPO_R, depth=1.00,
                                    location=(-0.70, 0, CEPO_R))
cepo = bpy.context.object
cepo.name = 'SM_Ancla_Cepo'
cepo.rotation_euler = (radians(90), 0.0, 0.0)   # Rx(90) manda el eje +Z a +Y
bpy.context.view_layer.update()
cepo.data.materials.append(MAT_hierro_osc)

# --- 3) Anillo de amarre: torusVertical en el extremo -X ---
ANILLO_R = 0.18
bpy.ops.mesh.primitive_torus_add(major_radius=ANILLO_R, minor_radius=0.05,
                                 major_segments=8, minor_segments=5,
                                 location=(-1.05, 0, ANILLO_R + 0.05))
anillo = bpy.context.object
anillo.name = 'SM_Ancla_Anillo'
anillo.rotation_euler = (radians(90), 0.0, 0.0)   # anillo PARADO (plano XZ)
bpy.context.view_layer.update()
anillo.data.materials.append(MAT_hierro_osc)

# --- 4) Dos brazos abiertos en Y, en el plano horizontal ---
BRAZO_L = 0.90
BRAZO_R = 0.075
BRAZO_ANG = radians(35)
BRAZO_ORIGEN_X = 0.85
for i, lado in enumerate((-1, 1)):
    dx, dy = cos(BRAZO_ANG), lado * sin(BRAZO_ANG)
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=8, radius=BRAZO_R, depth=BRAZO_L,
        location=(BRAZO_ORIGEN_X + dx * BRAZO_L / 2, dy * BRAZO_L / 2, BRAZO_R))
    b = bpy.context.object
    b.name = 'SM_Ancla_Brazo_%d' % i
    # E-58: to_track_quat alinea el eje +Z del cilindro con la direccion del brazo
    b.rotation_euler = Vector((dx, dy, 0.0)).to_track_quat('Z', 'Y').to_euler()
    bpy.context.view_layer.update()
    b.data.materials.append(MAT_hierro)

    # Uña: cono en la punta del brazo, misma direccion, apoyado en z=0
    UNA_R = 0.13
    UNA_L = 0.26
    bpy.ops.mesh.primitive_cone_add(
        vertices=4, radius1=UNA_R, radius2=0.0, depth=UNA_L,
        location=(BRAZO_ORIGEN_X + dx * (BRAZO_L + UNA_L / 2),
                  dy * (BRAZO_L + UNA_L / 2), UNA_R))
    u = bpy.context.object
    u.name = 'SM_Ancla_Una_%d' % i
    u.rotation_euler = Vector((dx, dy, 0.0)).to_track_quat('Z', 'Y').to_euler()
    bpy.context.view_layer.update()
    u.data.materials.append(MAT_hierro_osc)

# --- 5) Medano bajo: ENTIERRA el medio, no sostiene (ver cabecera) ---
bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.55, depth=0.18,
                                    location=(0.10, 0, 0.09))
medano = bpy.context.object
medano.name = 'SM_Ancla_Medano'
medano.data.materials.append(MAT_arena)

arena(radio=2.6)
iluminar(escena)
asentar(escena)
camara(escena, 'CAM_AnclaNaufragio', (2.6, -3.1, 1.6), (0.1, 0, 0.2))
shade_flat(escena)
guardar(escena, '45-Arte3D', 'ancla_naufragio')
