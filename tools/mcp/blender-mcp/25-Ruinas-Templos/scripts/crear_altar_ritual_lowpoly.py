# crear_altar_ritual_lowpoly.py — Altar ritual central (M25-Ruinas-Templos)
# Checklist: "Altar ritual central"
#
# Composición: plataforma escalonada (2 escalones) + mesa-altar con 4 pilares
# en las esquinas y tapa circular + cuenco de ofrenda con brasas.
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
def crear_mat(nombre, color, rough=0.9, spec=0.1, metal=0.0, emission=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    if emission > 0.0:
        bsdf.inputs['Emission Color'].default_value = (*color, 1.0)
        bsdf.inputs['Emission Strength'].default_value = emission
    return m

MAT_piedra  = crear_mat('MAT_Piedra_Altar',  (0.55, 0.50, 0.42), rough=0.94)
MAT_piedra2 = crear_mat('MAT_Piedra_Altar_Osc', (0.42, 0.37, 0.31), rough=0.95)
MAT_talla   = crear_mat('MAT_Talla_Altar',   (0.80, 0.66, 0.40), rough=0.78)
MAT_brasa   = crear_mat('MAT_Brasa_Altar',   (1.0, 0.45, 0.10), rough=0.4, emission=0.6)
MAT_arena   = crear_mat('MAT_Arena_Isla',    (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.6, depth=0.24,
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

# ---------- 5) Escalón inferior ----------
agregar('SM_Altar_EscalonInf',
        nueva_caja('SM_Altar_EscalonInf', 0.0, 0.0, 0.06,
                   1.20, 0.90, 0.12),
        MAT_piedra2)

# ---------- 6) Escalón superior ----------
agregar('SM_Altar_EscalonSup',
        nueva_caja('SM_Altar_EscalonSup', 0.0, 0.0, 0.20,
                   1.00, 0.75, 0.16),
        MAT_piedra)

# ---------- 7) Mesa-altar ----------
agregar('SM_Altar_Mesa',
        nueva_caja('SM_Altar_Mesa', 0.0, 0.0, 0.36,
                   0.86, 0.62, 0.10),
        MAT_piedra2)

# ---------- 8) 4 pilares en las esquinas ----------
for sx in (-1, 1):
    for sy in (-1, 1):
        agregar('SM_Altar_Pilar_%s%s' % ('I' if sx<0 else 'D', 'F' if sy<0 else 'T'),
                nueva_caja('SM_Altar_Pilar_%s%s' % ('I' if sx<0 else 'D', 'F' if sy<0 else 'T'),
                           sx * 0.36, sy * 0.26, 0.50,
                           0.08, 0.08, 0.22),
                MAT_piedra)

# ---------- 9) Tapa circular (cilindro) sobre los pilares ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=0.50, depth=0.06,
                                    location=(0.0, 0.0, 0.66))
tapa = bpy.context.object
tapa.name = 'SM_Altar_Tapa'
tapa.data.materials.append(MAT_piedra2)
bpy.ops.object.select_all(action='DESELECT')
tapa.select_set(True)
bpy.context.view_layer.objects.active = tapa
bpy.ops.object.shade_flat()

# Banda dorada en el borde de la tapa
bpy.ops.mesh.primitive_torus_add(major_radius=0.50, minor_radius=0.018,
                                 location=(0.0, 0.0, 0.66),
                                 major_segments=24, minor_segments=6)
banda = bpy.context.object
banda.name = 'SM_Altar_Banda'
banda.data.materials.append(MAT_talla)
bpy.ops.object.select_all(action='DESELECT')
banda.select_set(True)
bpy.context.view_layer.objects.active = banda
bpy.ops.object.shade_flat()

# ---------- 10) Cuenco de ofrenda con brasas (sobre la mesa) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=0.12, depth=0.05,
                                    location=(0.0, 0.0, 0.44))
cuenco = bpy.context.object
cuenco.name = 'SM_Altar_Cuenco'
cuenco.data.materials.append(MAT_piedra2)
bpy.ops.object.select_all(action='DESELECT')
cuenco.select_set(True)
bpy.context.view_layer.objects.active = cuenco
bpy.ops.object.shade_flat()

# Brasas (esfera) dentro del cuenco
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.06,
                                      location=(0.0, 0.0, 0.49))
brasa = bpy.context.object
brasa.name = 'SM_Altar_Brasa'
brasa.data.materials.append(MAT_brasa)
bpy.ops.object.select_all(action='DESELECT')
brasa.select_set(True)
bpy.context.view_layer.objects.active = brasa
bpy.ops.object.shade_flat()

# ---------- 11) Asentado (E-12) ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Altar')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:
        o.location.z += delta
print('ALTAR asento: z_min %.3f -> %.3f (delta %+.3f)'
      % (z_min, Z_APOYO, delta))

# ---------- 12) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.0
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(8), math.radians(35)), 'XYZ')

# Luz cálida desde el brasero
sol2_data = bpy.data.lights.new('BRASA', type='POINT')
sol2_data.energy = 1.5
sol2_data.color = (1.0, 0.55, 0.20)
sol2_data.shadow_soft_size = 0.10
sol2 = bpy.data.objects.new('BRASA', sol2_data)
escena.collection.objects.link(sol2)
sol2.location = (0.0, 0.0, 0.55)

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.45, 0.40, 0.50, 1.0)   # atardecer
bg.inputs[1].default_value = 0.45

# ---------- 13) Cámara ----------
bpy.ops.object.camera_add(location=(1.8, 1.6, 0.9))
cam = bpy.context.object
cam.name = 'CAM_Altar'
blanco = Vector((0.0, 0.0, 0.50))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 14) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '25-Ruinas-Templos',
                          'altar_ritual_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('ALTAR RITUAL OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
