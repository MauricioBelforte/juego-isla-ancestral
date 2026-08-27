# crear_palmera_lowpoly.py — Genera una palmera low-poly estilizada:
# tronco curvado segmentado, 7 frondas arqueadas, cocos y base de arena.
# ⚠️ Este código se envía vía execute_code del socket BlenderMCP (puerto 9876),
# NO se ejecuta como script standalone.
# Reutilizable: regenera la palmera desde cero (borra la escena actual).

import bpy
import bmesh
import math
import os
from math import radians, sin, pi
from mathutils import Vector, Euler

# ---------- 1) Limpieza de escena ----------
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

# ---------- 2) Materiales (colores sólidos low-poly) ----------
def crear_mat(nombre, color, rough=0.9, spec=0.08):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    return m

MAT_tronco  = crear_mat('MAT_Tronco_Palmera', (0.45, 0.31, 0.18), rough=0.95)
MAT_hoja    = crear_mat('MAT_Hoja_Palmera',   (0.11, 0.42, 0.16), rough=0.85)
MAT_coco    = crear_mat('MAT_Coco',           (0.27, 0.16, 0.07), rough=0.90)
MAT_arena   = crear_mat('MAT_Arena_Isla',     (0.92, 0.84, 0.63), rough=1.00)
MAT_corazon = crear_mat('MAT_Corazon_Corona', (0.35, 0.45, 0.15), rough=0.90)

# ---------- 3) Suelo: disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=28, radius=3.4, depth=0.3,
                                    location=(0, 0, -0.15))
suelo = bpy.context.object
suelo.name = 'SM_Arena_Base'
suelo.data.materials.append(MAT_arena)

# ---------- 4) Tronco curvado (segmentos apilados, giro 14° c/u) ----------
SEG, ALT_SEG, CURVA = 7, 0.62, 1.05
for i in range(SEG):
    t = i / (SEG - 1)
    r = 0.30 - 0.155 * t                      # se afina hacia arriba
    x = CURVA * (t ** 2)                      # curvatura cuadrática
    z = 0.08 + i * ALT_SEG
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=7, radius=r, depth=ALT_SEG * 1.18,
        location=(x, 0, z), rotation=(0, 0, radians(14 * i)))
    seg = bpy.context.object
    seg.name = 'SM_Tronco_%02d' % i
    seg.data.materials.append(MAT_tronco)

top_x = CURVA
top_z = SEG * ALT_SEG + 0.12                  # punto de anclaje de la corona

# ---------- 5) Corona (corazón) ----------
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.26,
                                      location=(top_x, 0, top_z))
cora = bpy.context.object
cora.name = 'SM_Corona'
cora.scale = (1.0, 1.0, 0.75)
cora.data.materials.append(MAT_corazon)

# ---------- 6) Frondas: tira de quads con ancho sinusoidal y caída ----------
def crear_fronda(idx, yaw_deg, pitch_deg):
    bm = bmesh.new()
    N = 6
    largo = 2.35 + (0.22 if idx % 2 else 0.0)
    filas = []
    for j in range(N + 1):
        s = j / N
        x = s * largo
        if s <= 0.0:
            w = 0.035
        elif s >= 1.0:
            w = 0.03
        else:
            w = 0.36 * (sin(pi * s) ** 0.6)   # ancho: angosta-ancha-angosta
        z = 0.55 - 0.18 * s - 1.05 * (s ** 2) # sale arriba y cae (parábola)
        filas.append((bm.verts.new((x, -w, z)), bm.verts.new((x, w, z))))
    for j in range(N):
        a1, b1 = filas[j]
        a2, b2 = filas[j + 1]
        bm.faces.new((a1, b1, b2, a2))
    me = bpy.data.meshes.new('m_fronda_%02d' % idx)
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new('SM_Fronda_%02d' % idx, me)
    bpy.context.collection.objects.link(ob)
    # Euler XYZ: primero pitch (Y, inclina la hoja) y luego yaw (Z, la reparte)
    ob.rotation_euler = Euler((0.0, radians(pitch_deg), radians(yaw_deg)), 'XYZ')
    ob.location = (top_x, 0.0, top_z - 0.05)
    me.materials.append(MAT_hoja)
    return ob

K = 7
for i in range(K):
    yaw = i * (360.0 / K) + (7.0 if i % 2 else -4.0)   # jitter determinista
    pitch = 8.0 + (i % 3) * 6.0
    crear_fronda(i, yaw, pitch)

# ---------- 7) Cocos ----------
for k, (dx, dy) in enumerate([(0.22, 0.10), (-0.12, 0.22), (-0.10, -0.20)]):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.17,
        location=(top_x + dx, dy, top_z - 0.22))
    coco = bpy.context.object
    coco.name = 'SM_Coco_%d' % k
    coco.data.materials.append(MAT_coco)

# ---------- 8) Luz sol + cielo + cámara ----------
bpy.ops.object.light_add(type='SUN', location=(5, -4, 9))
sol = bpy.context.object
sol.name = 'LGT_Sol'
sol.data.energy = 3.2
sol.rotation_euler = Euler((radians(55), radians(12), radians(35)), 'XYZ')

mundo = bpy.data.worlds['World']
mundo.use_nodes = True
nodo_bg = mundo.node_tree.nodes.get('Background')
nodo_bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
nodo_bg.inputs[1].default_value = 1.0

bpy.ops.object.camera_add(location=(7.8, -6.8, 3.4))
cam = bpy.context.object
cam.name = 'CAM_Palmera'
dir_mira = Vector((top_x * 0.5, 0.0, top_z * 0.55)) - cam.location
cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
bpy.context.scene.camera = cam

# ---------- 9) Flat shading en todo ----------
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.shade_flat()

# ---------- 10) Encuadre del viewport (para captura de V5) ----------
for area in bpy.context.screen.areas:
    if area.type == 'VIEW_3D':
        rv = area.spaces.active.region_3d
        rv.view_perspective = 'ORTHO'
        rv.view_location = (top_x * 0.4, 0.0, top_z * 0.52)
        rv.view_distance = 10.5
        dir_v = Vector((7.0, -6.0, 4.5)).normalized()
        rv.view_rotation = dir_v.to_track_quat('-Z', 'Y').to_quaternion()

# ---------- 11) Guardar .blend ----------
ruta_blend = os.path.abspath(os.path.join(
    os.getcwd(), 'tools/mcp/blender-mcp/trabajos/palmera_lowpoly.blend'))
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('PALMERA OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
