# crear_muelle_madera_lowpoly.py — Muelle de madera (M40-Infraestructura)
# Checklist: "Muelle de madera (tablas + pilotes)"
#
# Composición: 6 pilotes verticales clavados en la arena, con una cubierta
# horizontal de 5 tablas longitudinales. Detalles: barandilla con 3 postes
# cortos + pasamanos + 2 argollas de amarre.
import bpy
import bmesh
import os
import random
import math
from mathutils import Vector, Euler, Matrix

# ---------- 1) Limpieza ----------
for _obj in list(bpy.data.objects):
    bpy.data.objects.remove(_obj, do_unlink=True)
for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                bpy.data.cameras, bpy.data.worlds):
    for _dato in list(_bloque):
        if _dato.users == 0:
            _bloque.remove(_dato)
escena = bpy.context.scene

# ---------- 2) Materiales ----------
def crear_mat(nombre, color, rough=0.85, spec=0.1, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_madera = crear_mat('MAT_Madera_Muelle',     (0.42, 0.28, 0.16), rough=0.86)
MAT_madera_osc = crear_mat('MAT_Madera_Muelle_Osc', (0.30, 0.20, 0.11), rough=0.88)
MAT_hierro = crear_mat('MAT_Hierro_Muelle',     (0.32, 0.30, 0.28), rough=0.55, metal=0.6)
MAT_arena  = crear_mat('MAT_Arena_Isla',        (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena (más grande para que entren los pilotes) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.4, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Helpers ----------
def nueva_caja(nombre, cx, cy, cz, sx, sy, sz):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x = v.co.x * sx + cx
        v.co.y = v.co.y * sy + cy
        v.co.z = v.co.z * sz + cz
    bm.normal_update()
    me = bpy.data.meshes.new(nombre)
    bm.to_mesh(me)
    bm.free()
    return me

def agregar(nombre, me, material, padre=None):
    o = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(o)
    o.data.materials.append(material)
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()
    if padre is not None:
        o.parent = padre
        o.matrix_parent_inverse = Matrix()
    return o

# ---------- 5) Pilotes (6) en 2 filas de 3 ----------
# Los pilotes van desde la arena hasta 0.55 (parte superior de la cubierta)
PILOT_H = 0.85
PILOT_W = 0.16
posiciones = [
    (-0.90, -0.50), (-0.90, 0.0), (-0.90, 0.50),
    ( 0.90, -0.50), ( 0.90, 0.0), ( 0.90, 0.50),
]
for k, (x, y) in enumerate(posiciones):
    agregar('SM_Muelle_Pilote_%d' % (k + 1),
            nueva_caja('SM_Muelle_Pilote_%d' % (k + 1), x, y, PILOT_H / 2,
                       PILOT_W, PILOT_W, PILOT_H),
            MAT_madera_osc)

# ---------- 6) Vigas longitudinales (2) sobre los pilotes ----------
agregar('SM_Muelle_Viga_Trasera',
        nueva_caja('SM_Muelle_Viga_Trasera', 0.0, 0.50, PILOT_H - 0.04,
                   1.95, 0.12, 0.12),
        MAT_madera)
agregar('SM_Muelle_Viga_Delantera',
        nueva_caja('SM_Muelle_Viga_Delantera', 0.0, -0.50, PILOT_H - 0.04,
                   1.95, 0.12, 0.12),
        MAT_madera)

# ---------- 7) Tablas de cubierta (5 longitudinales) ----------
TABLA_W = 0.30
TABLA_E = 0.06
TABLA_L = 1.85
Y_START = -0.60
for k in range(5):
    cy = Y_START + k * 0.30
    agregar('SM_Muelle_Tabla_%d' % (k + 1),
            nueva_caja('SM_Muelle_Tabla_%d' % (k + 1), 0.0, cy, PILOT_H + 0.05,
                       TABLA_L, TABLA_W, TABLA_E),
            MAT_madera)

# ---------- 8) Barandilla: 3 postes cortos + pasamanos ----------
# Solo en el lado opuesto a la arena (el lado +X del muelle, "al mar")
# Pero para catalog render: la baranda está en el borde de ataque (-X)
# 3 postes cortos
for k, y in enumerate((-0.30, 0.0, 0.30)):
    agregar('SM_Muelle_PosteB_%d' % (k + 1),
            nueva_caja('SM_Muelle_PosteB_%d' % (k + 1), -0.90, y, PILOT_H + 0.32,
                       0.06, 0.06, 0.50),
            MAT_madera_osc)
# Pasamanos horizontal
agregar('SM_Muelle_Pasamanos',
        nueva_caja('SM_Muelle_Pasamanos', -0.90, 0.0, PILOT_H + 0.55,
                   0.08, 0.66, 0.05),
        MAT_madera)

# ---------- 9) 2 argollas de amarre (toroides de hierro) ----------
for k, x in enumerate((0.50, -0.50)):
    bpy.ops.mesh.primitive_torus_add(major_radius=0.05, minor_radius=0.012,
                                     location=(x, 0.50, PILOT_H + 0.10),
                                     major_segments=10, minor_segments=4,
                                     rotation=(math.radians(90), 0, 0))
    arg = bpy.context.object
    arg.name = 'SM_Muelle_Argolla_%d' % (k + 1)
    arg.data.materials.append(MAT_hierro)
    bpy.ops.object.select_all(action='DESELECT')
    arg.select_set(True)
    bpy.context.view_layer.objects.active = arg
    bpy.ops.object.shade_flat()

# ---------- 10) Asentado (E-12) — solo los pilotes (cubierta sigue) ----------
Z_APOYO = 0.045


def asentar_grupo(prefijos, etiqueta):
    bpy.context.view_layer.update()
    piezas = [o for o in escena.objects
              if o.type == 'MESH' and any(o.name.startswith(p) for p in prefijos)]
    if not piezas:
        return
    z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
                for o in piezas)
    delta = Z_APOYO - z_min
    for o in piezas:
        if o.parent is None:
            o.location.z += delta
    print('%s asento: z_min %.3f -> %.3f (delta %+.3f)'
          % (etiqueta, z_min, Z_APOYO, delta))


# Los pilotes (raíz) deben estar en 0.045. Pero el resto de la estructura
# (vigas, tablas, barandilla, argollas) está pegada A los pilotes y a la
# misma altura. Asentamos todo junto para evitar gaps.
asentar_grupo(['SM_Muelle_Pilote', 'SM_Muelle_Viga', 'SM_Muelle_Tabla',
               'SM_Muelle_PosteB', 'SM_Muelle_Pasamanos', 'SM_Muelle_Argolla'],
              'MUELLE completo')

# ---------- 11) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.4
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(8), math.radians(35)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 12) Cámara ----------
bpy.ops.object.camera_add(location=(2.6, 2.6, 1.4))
cam = bpy.context.object
cam.name = 'CAM_Muelle'
blanco = Vector((0.0, 0.0, 0.60))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 13) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '40-Infraestructura',
                          'muelle_madera_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('MUELLE MADERA OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
