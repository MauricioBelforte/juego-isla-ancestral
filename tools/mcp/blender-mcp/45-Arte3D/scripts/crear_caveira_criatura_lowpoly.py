# crear_caveira_criatura_lowpoly.py — Caveira de criatura marina (playa) (M45)
# Checklist: "Caveira de criatura marina (playa)"
#
# DECISION DE DISENO:
#   Craneo alargado de criatura marina (ballena/delfin) varado en la arena:
#   craneo cilindrico ACOSTADO, hocico conico hacia +X, mandibula separada y
#   hundida en la arena, cuencas oculares oscuras y 4 dientes conicos.
#   Va medio enterrado sobre una base de arena que ES parte del asset.
#
#   Por que cilindros ACOSTADOS y no ico-esferas: una ico-esfera achatada apoya
#   sobre UN SOLO vertice (polo sur) y el assert E-50 la rechaza (ya paso con
#   musgo_roca y raices_expuestas). Un cilindro acostado apoya por su generatriz
#   inferior y, sobre todo, la base de 12 lados aporta 12 vertices reales.
import bpy
import os
import sys
from math import radians

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar,
                             camara, shade_flat, guardar)

escena = limpiar()

MAT_hueso = mat('MAT_Caveira_Hueso', (0.88, 0.86, 0.78), rough=0.85)
MAT_hueso_osc = mat('MAT_Caveira_Hueso_Osc', (0.70, 0.67, 0.58), rough=0.90)
MAT_cuenca = mat('MAT_Caveira_Cuenca', (0.09, 0.08, 0.08), rough=1.00)
MAT_arena = mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

BASE_ALTO = 0.16
BASE_TOP = BASE_ALTO

# --- 1) Base de arena: 12 vertices apoyando, sostiene todo (E-50) ---
bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.60, depth=BASE_ALTO,
                                    location=(0, 0, BASE_ALTO / 2))
base = bpy.context.object
base.name = 'SM_Caveira_Base'
base.data.materials.append(MAT_arena)

# --- 2) Craneo: cilindro de 8 lados ACOSTADO a lo largo de X ---
CRANEO_R = 0.34
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=CRANEO_R, depth=0.70,
                                    location=(-0.15, 0, BASE_TOP + CRANEO_R))
craneo = bpy.context.object
craneo.name = 'SM_Caveira_Craneo'
craneo.rotation_euler = (0.0, radians(90), 0.0)
bpy.context.view_layer.update()
craneo.data.materials.append(MAT_hueso)

# --- 3) Hocico: cono de 6 lados hacia +X, apoyado sobre la base ---
HOCICO_R = 0.26
HOCICO_L = 0.75
bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=HOCICO_R, radius2=0.10,
                                depth=HOCICO_L,
                                location=(0.20 + HOCICO_L / 2, 0, BASE_TOP + HOCICO_R))
hocico = bpy.context.object
hocico.name = 'SM_Caveira_Hocico'
hocico.rotation_euler = (0.0, radians(90), 0.0)
bpy.context.view_layer.update()
hocico.data.materials.append(MAT_hueso)

# --- 4) Mandibula: cilindro de 6 lados, mas baja y mas adelante ---
MAND_R = 0.16
bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=MAND_R, depth=0.60,
                                    location=(0.55, 0, BASE_TOP + MAND_R))
mand = bpy.context.object
mand.name = 'SM_Caveira_Mandibula'
mand.rotation_euler = (0.0, radians(90), 0.0)
bpy.context.view_layer.update()
mand.data.materials.append(MAT_hueso_osc)

# --- 5) Cuencas oculares: 2 ico-esferas bajas HUNDIDAS en el craneo ---
for i, lado in enumerate((-1, 1)):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=0, radius=0.11,
                                          location=(-0.15, lado * 0.27, BASE_TOP + 0.44))
    o = bpy.context.object
    o.name = 'SM_Caveira_Cuenca_%d' % i
    o.scale = (1.0, 0.45, 1.0)
    o.data.materials.append(MAT_cuenca)

# --- 6) Dientes: 4 conos de 4 lados sobre la mandibula ---
for i in range(4):
    x = 0.34 + i * 0.14
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.045, radius2=0.0,
                                    depth=0.13,
                                    location=(x, 0.13, BASE_TOP + 0.30))
    d = bpy.context.object
    d.name = 'SM_Caveira_Diente_%d' % i
    d.data.materials.append(MAT_hueso)

arena(radio=2.0)
iluminar(escena)
asentar(escena)
camara(escena, 'CAM_CaveiraCriatura', (1.9, -2.2, 1.1), (0.1, 0, 0.3))
shade_flat(escena)
guardar(escena, '45-Arte3D', 'caveira_criatura')
