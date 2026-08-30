# crear_arbusto_redondo_lowpoly.py — Arbusto redondo lowpoly (M50-Vegetacion)
# Checklist: "Arbusto redondo lowpoly"
# Misma técnica que la roca: icosfera deformada con bmesh, una sola malla.
# Composición: 3 bolas escalonadas (arbusto principal + 2 lóbulos) y
# un parche de pasto en la base para dar variedad.
#
# Lecciones aplicadas (09-GUIA-BLENDER.md):
#   E-01: bmesh única (no apilar primitivas)
#   E-03: cámara + shading para captura
#   E-04: ruta absoluta al .blend
#   E-05: limpieza sin wm.read_factory_settings
#   §7:   Base_Arena / SOL / Mundo / CAM_* = set de captura, NO se exporta
import bpy
import bmesh
import os
from math import radians, sin, cos, pi
from mathutils import Vector, Euler

# ---------- 1) Limpieza idempotente (E-05) ----------
for _obj in list(bpy.data.objects):
    bpy.data.objects.remove(_obj, do_unlink=True)
for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                bpy.data.cameras, bpy.data.worlds):
    for _dato in list(_bloque):
        if _dato.users == 0:
            _bloque.remove(_dato)
escena = bpy.context.scene

# ---------- 2) Materiales ----------
def crear_mat(nombre, color, rough=0.9, spec=0.08):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    return m

MAT_arbusto = crear_mat('MAT_Arbusto', (0.22, 0.50, 0.20), rough=0.92)
MAT_arbusto_claro = crear_mat('MAT_Arbusto_Claro', (0.34, 0.62, 0.24), rough=0.90)
MAT_arbusto_oscuro = crear_mat('MAT_Arbusto_Oscuro', (0.16, 0.40, 0.16), rough=0.92)
MAT_pasto = crear_mat('MAT_Pasto_Base', (0.30, 0.55, 0.18), rough=0.95)
MAT_arena = crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Set de captura: disco de arena (§7) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.2, depth=0.24,
                                    location=(0, 0, -0.12))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Arbusto principal: icosfera deformada (E-01) ----------
def crear_mata(nombre, radio, subdiv, loc, mat, deform_max=0.10, seed=0):
    me = bpy.data.meshes.new('M_' + nombre)
    ob = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(ob)
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subdiv, radius=radio)
    rng = __import__('random'); rng.seed(seed)
    for v in bm.verts:
        v.co += v.normal * rng.uniform(-deform_max, deform_max)
    bm.to_mesh(me); bm.free()
    ob.location = loc
    ob.data.materials.append(mat)
    return ob

mata_principal = crear_mata('SM_Arbusto_Principal', 0.85, 2,
                            (0.0, 0.0, 0.70), MAT_arbusto,
                            deform_max=0.12, seed=11)
mata_lateral_a = crear_mata('SM_Arbusto_Lateral_A', 0.52, 1,
                            (0.70, 0.30, 0.45), MAT_arbusto_claro,
                            deform_max=0.10, seed=23)
mata_lateral_b = crear_mata('SM_Arbusto_Lateral_B', 0.45, 1,
                            (-0.45, 0.50, 0.40), MAT_arbusto_oscuro,
                            deform_max=0.10, seed=37)

# ---------- 5) Pasto en la base: 6 conitos finos alrededor ----------
def crear_mata_pasto(idx, ang):
    bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=0.05, radius2=0.0,
                                    depth=0.35, location=(1.0 * cos(ang), 1.0 * sin(ang), 0.20))
    p = bpy.context.object
    p.name = f'SM_Pasto_{idx:02d}'
    p.rotation_euler = (radians(75 - idx * 1.5), 0, radians(idx * 53.0))
    p.data.materials.append(MAT_pasto)

for i in range(6):
    crear_mata_pasto(i, i * (2 * pi / 6))

# ---------- 6) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.0
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((radians(52), radians(6), radians(32)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 7) Cámara (E-03) ----------
bpy.ops.object.camera_add(location=(3.6, -4.4, 1.9))
cam = bpy.context.object
cam.name = 'CAM_Arbusto'
dir_mira = Vector((0.05, 0.0, 0.55)) - cam.location
cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
escena.camera = cam

# ---------- 8) Flat shading ----------
for ob in escena.objects: ob.select_set(True)
bpy.context.view_layer.objects.active = mata_principal
bpy.ops.object.shade_flat()

# ---------- 9) Guardar .blend (E-04) ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'arbusto_redondo_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('ARBUSTO OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
