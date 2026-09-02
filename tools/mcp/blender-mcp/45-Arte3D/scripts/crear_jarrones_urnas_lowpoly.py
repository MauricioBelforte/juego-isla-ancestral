# crear_jarrones_urnas_lowpoly.py — Jarrones/urnas decorativas, 3 variantes (M45)
# Checklist: "Jarrones/urnas decorativas (3 variantes)"
#
# DECISION DE DISENO:
#   El checklist pide 3 VARIANTES. Se modelan como 3 vasijas en un solo .blend
#   (un unico asset `jarrones_urnas`), no como 3 assets separados: comparten
#   materiales, se mergean juntos en MEDIA/BAJA (M166) y asi el prop de
#   ambientacion se puede soltar de una sola vez en la escena.
#     A) Anfora alta con cuello y 2 asas   (x = -0.55)
#     B) Urna ancha de boca grande         (x = +0.15)
#     C) Cuenco bajo                       (x = +0.85)
#
#   Cada vasija apoya sobre un cilindro de 12 lados -> 36 vertices tocando el
#   suelo en total. Ninguna ico-esfera: apoyarian sobre un solo vertice (E-50).
import bpy
import os
import sys
from math import radians
from mathutils import Vector

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar,
                             camara, shade_flat, guardar)

escena = limpiar()

MAT_barro = mat('MAT_Jarrones_Barro', (0.72, 0.38, 0.24), rough=0.90)
MAT_barro_osc = mat('MAT_Jarrones_Barro_Osc', (0.53, 0.26, 0.17), rough=0.92)
MAT_barro_claro = mat('MAT_Jarrones_Barro_Claro', (0.83, 0.59, 0.43), rough=0.88)


def cil(nombre, verts, radio, alto, x, z_base, material):
    """Cilindro con su cota inferior EXACTAMENTE en z_base (E-24 por construccion)."""
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radio, depth=alto,
                                        location=(x, 0, z_base + alto / 2))
    o = bpy.context.object
    o.name = nombre
    o.data.materials.append(material)
    return o


def cono(nombre, verts, r1, r2, alto, x, z_base, material):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2,
                                    depth=alto, location=(x, 0, z_base + alto / 2))
    o = bpy.context.object
    o.name = nombre
    o.data.materials.append(material)
    return o


# ---------- A) Anfora alta (x = -0.55) ----------
XA = -0.55
z = 0.0
z = 0.42; cil('SM_Jarron_Anfora_Cuerpo', 12, 0.26, 0.42, XA, 0.0, MAT_barro)
z = 0.42 + 0.22
cono('SM_Jarron_Anfora_Hombro', 12, 0.26, 0.11, 0.22, XA, 0.42, MAT_barro)
z = 0.64 + 0.20
cil('SM_Jarron_Anfora_Cuello', 10, 0.10, 0.20, XA, 0.64, MAT_barro_osc)
z = 0.84 + 0.06
cil('SM_Jarron_Anfora_Boca', 12, 0.14, 0.06, XA, 0.84, MAT_barro_claro)
# 2 asas: torus chicos a los lados del cuello
for i, lado in enumerate((-1, 1)):
    bpy.ops.mesh.primitive_torus_add(major_radius=0.09, minor_radius=0.028,
                                     major_segments=8, minor_segments=5,
                                     location=(XA, lado * 0.135, 0.74))
    a = bpy.context.object
    a.name = 'SM_Jarron_Anfora_Asa_%d' % i
    a.rotation_euler = (radians(90), 0.0, 0.0)
    bpy.context.view_layer.update()
    a.data.materials.append(MAT_barro_osc)

# ---------- B) Urna ancha (x = +0.15) ----------
XB = 0.15
cil('SM_Jarron_Urna_Cuerpo', 12, 0.30, 0.34, XB, 0.0, MAT_barro_claro)
cil('SM_Jarron_Urna_Boca', 12, 0.33, 0.06, XB, 0.34, MAT_barro)

# ---------- C) Cuenco bajo (x = +0.85) ----------
XC = 0.85
cil('SM_Jarron_Cuenco_Cuerpo', 12, 0.22, 0.18, XC, 0.0, MAT_barro_osc)
cil('SM_Jarron_Cuenco_Boca', 12, 0.24, 0.04, XC, 0.18, MAT_barro_claro)

bpy.context.view_layer.update()

arena(radio=2.0)
iluminar(escena)
asentar(escena)
camara(escena, 'CAM_JarronesUrnas', (1.9, -2.3, 1.2), (0.15, 0, 0.35))
shade_flat(escena)
guardar(escena, '45-Arte3D', 'jarrones_urnas')
