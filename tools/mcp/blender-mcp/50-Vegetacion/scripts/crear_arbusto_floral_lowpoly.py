# crear_arbusto_floral_lowpoly.py — Arbusto floral (M50-Vegetacion)
# Checklist: "Arbusto floral (con flores de color)"
#
# Variante del arbusto redondo (que ya está hecho) pero con flores. Las
# flores son pequeños icospheres de color en la copa.
import bpy
import bmesh
import os
import random
import math
from mathutils import Vector, Euler

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
def crear_mat(nombre, color, rough=0.85, spec=0.15, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_hojas = crear_mat('MAT_ArbustoFloral_Hojas', (0.30, 0.45, 0.22), rough=0.92)
MAT_tallo = crear_mat('MAT_ArbustoFloral_Tallo', (0.32, 0.22, 0.13), rough=0.92)
# 3 colores de flor: rosa, amarillo, blanco
colores_flores = [
    ((0.95, 0.55, 0.65), 'Rosa'),
    ((0.95, 0.85, 0.30), 'Amarillo'),
    ((0.96, 0.94, 0.90), 'Blanco'),
]
mat_flores = [crear_mat('MAT_Flor_%s' % n, c, rough=0.55) for c, n in colores_flores]
MAT_arena = crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Copa del arbusto (icosfera erosionada) ----------
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.55,
                                       location=(0.0, 0.0, 0.55))
copa = bpy.context.object
copa.name = 'SM_ArbustoFloral_Copa'
copa.scale = (1.10, 1.05, 0.85)
# vértices jitter
me = copa.data
rng_g = random.Random(7)
for v in me.vertices:
    v.co = (v.co.x + rng_g.uniform(-0.04, 0.04),
            v.co.y + rng_g.uniform(-0.04, 0.04),
            v.co.z + rng_g.uniform(-0.04, 0.04))
me.update()
copa.data.materials.append(MAT_hojas)
bpy.ops.object.select_all(action='DESELECT')
copa.select_set(True)
bpy.context.view_layer.objects.active = copa
bpy.ops.object.shade_flat()

# ---------- 5) Tronco corto visible abajo ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.07, depth=0.18,
                                     location=(0.0, 0.0, 0.09))
tronco = bpy.context.object
tronco.name = 'SM_ArbustoFloral_Tallo'
tronco.data.materials.append(MAT_tallo)
bpy.ops.object.select_all(action='DESELECT')
tronco.select_set(True)
bpy.context.view_layer.objects.active = tronco
bpy.ops.object.shade_flat()

# ---------- 6) Flores: 14 icospheres de 3 colores, parentadas a la copa (E-11) ----------
N_FLORES = 14
rng = random.Random(33)
for k in range(N_FLORES):
    # Posición sobre la superficie de la copa: muestrear azimut + t
    az = rng.uniform(0, 2 * math.pi)
    t = rng.uniform(0.5, 1.0)  # solo mitad superior
    # Coordenada local sobre la icoesfera achatada (rx=1.10*0.55, ry=1.05*0.55, rz=0.85*0.55)
    rx, ry, rz = 1.10 * 0.55, 1.05 * 0.55, 0.85 * 0.55
    local = (rx * math.cos(az) * t,
             ry * math.sin(az) * t,
             rz * math.cos(t * math.pi / 2) + 0.1)
    # radio de la flor: pequeño
    radio_flor = rng.uniform(0.06, 0.10)
    color_idx = rng.randint(0, len(mat_flores) - 1)

    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=radio_flor,
                                           location=(0.0, 0.0, 0.0))  # se reubica tras emparentar
    flor = bpy.context.object
    flor.name = 'SM_ArbustoFloral_Flor_%d' % (k + 1)
    flor.data.materials.append(mat_flores[color_idx])
    flor.parent = copa
    flor.matrix_parent_inverse = copa.matrix_world.inverted()
    # ahora le damos la posición LOCAL (porque está emparentada con matrix_parent_inverse identidad)
    flor.location = local
    bpy.ops.object.select_all(action='DESELECT')
    flor.select_set(True)
    bpy.context.view_layer.objects.active = flor
    bpy.ops.object.shade_flat()

# ---------- 7) Asentado (E-12) — el tallo, la copa se acomoda sola ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and (o.name.startswith('SM_ArbustoFloral_Tallo')
                                   or o.name.startswith('SM_ArbustoFloral_Copa'))]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    o.location.z += delta
print('ARBUSTO FLORAL asento: z_min %.3f -> %.3f (delta %+.3f)' % (z_min, Z_APOYO, delta))

# ---------- 8) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(48), math.radians(6), math.radians(28)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 9) Cámara ----------
bpy.ops.object.camera_add(location=(1.7, -1.7, 1.0))
cam = bpy.context.object
cam.name = 'CAM_ArbustoFloral'
blanco = Vector((0.0, 0.0, 0.55))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 10) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'arbusto_floral_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('ARBUSTO FLORAL OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
