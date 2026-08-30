# crear_palmera_lowpoly.py — Genera una palmera low-poly estilizada:
# tronco curvado segmentado, 7 frondas arqueadas, cocos y base de arena.
# ⚠️ Este código se envía vía execute_code del socket BlenderMCP (puerto 9876),
# NO se ejecuta como script standalone.
# Reutilizable: regenera la palmera desde cero (borra la escena actual).

import bpy
import bmesh
import math
import os
from math import radians, sin, cos, pi
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
bpy.ops.mesh.primitive_cylinder_add(vertices=28, radius=2.7, depth=0.3,
                                    location=(0, 0, -0.15))
suelo = bpy.context.object
suelo.name = 'SM_Arena_Base'
suelo.data.materials.append(MAT_arena)

# ---------- 4) Tronco curvado: UNA sola malla con rings interpolados ----------
import bmesh
from mathutils import Vector

SEG_L, RAD_L, LADOS = 9, 7, 7      # rings de altura, lados por ring
CURVA = 0.70
ALTURA = 3.9

bm = bmesh.new()
anillos = []
for i in range(SEG_L + 1):
    t = i / SEG_L
    x = CURVA * (t ** 2)                      # centro: curvatura cuadrática
    z = 0.08 + t * ALTURA
    r = 0.30 - 0.12 * t                       # se afina hacia arriba
    anillo = [bm.verts.new((x + r * cos(2 * pi * k / LADOS),
                            r * sin(2 * pi * k / LADOS), z))
              for k in range(LADOS)]
    anillos.append(anillo)
for i in range(SEG_L):                        # caras laterales
    for k in range(LADOS):
        bm.faces.new([anillos[i][k], anillos[i][(k + 1) % LADOS],
                      anillos[i + 1][(k + 1) % LADOS], anillos[i + 1][k]])
bm.faces.new(anillos[0][::-1])                # tapa inferior
bm.faces.new(anillos[-1])                     # tapa superior
me = bpy.data.meshes.new('M_Tronco')
bm.to_mesh(me); bm.free()
tronco = bpy.data.objects.new('SM_Tronco', me)
bpy.context.collection.objects.link(tronco)
tronco.data.materials.append(MAT_tronco)

top_x = CURVA
top_z = 0.08 + ALTURA + 0.12                  # punto de anclaje de la corona

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
    largo = 2.6 + (0.25 if idx % 2 else 0.0)
    filas = []
    for j in range(N + 1):
        s = j / N
        x = s * largo
        if s <= 0.0:
            w = 0.035
        elif s >= 1.0:
            w = 0.03
        else:
            w = 0.38 * (sin(pi * s) ** 0.6)   # ancho: angosta-ancha-angosta
        z = 0.62 - 0.10 * s - 1.45 * (s ** 2) # sale arriba y cae (parábola)
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

# ---------- 6b) Autocorreccion de apoyo del TRONCO (E-12) ----------
# El tronco es el unico elemento que toca la arena; se baja hasta que su z_min
# mundial sea 0.045 (5 mm empotrado en la arena). NO movemos corona/frondas:
# ya estan ancladas a la copa del tronco via top_x/top_z, y la corona/frondas
# son "del tronco" en composicion.
bpy.context.view_layer.update()
tronco = bpy.data.objects.get('SM_Tronco')
if tronco is not None:
    z_min = min((tronco.matrix_world @ Vector(c)).z for c in tronco.bound_box)
    delta = 0.045 - z_min
    tronco.location.z += delta
    bpy.context.view_layer.update()
    print('TRONCO asento: z_min %.3f -> 0.045 (delta %+.3f)' % (z_min, delta))

# ---------- 7) Cocos ----------
for k, (dx, dy) in enumerate([(0.26, 0.12), (-0.14, 0.26), (-0.12, -0.24)]):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.17,
        location=(top_x + dx, dy, top_z - 0.30))
    coco = bpy.context.object
    coco.name = 'SM_Coco_%d' % k
    coco.data.materials.append(MAT_coco)

# ---------- 8) Luz sol + cielo + cámara ----------
bpy.ops.object.light_add(type='SUN', location=(5, -4, 9))
sol = bpy.context.object
sol.name = 'LGT_Sol'
sol.data.energy = 4.0
sol.rotation_euler = Euler((radians(50), radians(8), radians(30)), 'XYZ')

mundo = bpy.data.worlds.get('World') or bpy.data.worlds.new('World')
mundo.use_nodes = True
nodo_bg = mundo.node_tree.nodes.get('Background')
nodo_bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
nodo_bg.inputs[1].default_value = 1.0

bpy.ops.object.camera_add(location=(6.2, -7.6, 4.3))
cam = bpy.context.object
cam.name = 'CAM_Palmera'
dir_mira = Vector((top_x * 0.6, 0.0, top_z * 0.45)) - cam.location
cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
bpy.context.scene.camera = cam

# ---------- 9) Flat shading en todo ----------
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.shade_flat()

# ---------- 10) Encuadre del viewport (para captura de V5) ----------
# Rendered (EEVEE) + sin overlays + vista alineada a CAM_Palmera
for area in bpy.context.screen.areas:
    if area.type == 'VIEW_3D':
        space = area.spaces.active
        space.shading.type = 'RENDERED'
        space.overlay.show_overlays = False
        for region in area.regions:
            if region.type == 'WINDOW':
                with bpy.context.temp_override(area=area, region=region):
                    bpy.ops.view3d.view_camera()

# ---------- 11) Guardar .blend ----------
# E-04: NO usar os.getcwd() — el cwd de Blender es su carpeta de instalación.
# Ruta absoluta al módulo dentro del proyecto:
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'palmera_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('PALMERA OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
