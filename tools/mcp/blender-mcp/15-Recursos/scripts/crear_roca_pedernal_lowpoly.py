# crear_roca_pedernal_lowpoly.py — Roca de pedernal (M15-Recursos)
# Checklist: "Roca de pedernal"
# Variante de la roca común: icosfera más afilada (subdiv 3, deformación
# mayor en vertical) y color gris azulado más liso.
import bpy
import bmesh
import os
from math import radians
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
def crear_mat(nombre, color, rough=0.6, spec=0.15):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    return m

MAT_pedernal    = crear_mat('MAT_Pedernal',    (0.30, 0.33, 0.40), rough=0.55)  # gris azulado oscuro
MAT_pedernal_c  = crear_mat('MAT_Pedernal_C',  (0.45, 0.50, 0.60), rough=0.50)  # veta clara
MAT_arena       = crear_mat('MAT_Arena_Isla',  (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.2, depth=0.24,
                                    location=(0.1, 0.05, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Roca principal: icosfera deformada (E-01) ----------
me = bpy.data.meshes.new('SM_Roca_Pedernal')
ob = bpy.data.objects.new('SM_Roca_Pedernal', me)
escena.collection.objects.link(ob)
bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=3, radius=1.30)
rng = __import__('random'); rng.seed(13)
for v in bm.verts:
    # deformación más picuda: mayor amplitud y preferentemente vertical
    d = rng.uniform(-0.18, 0.20)
    v.co += v.normal * d
    v.co.z *= 1.30   # más alta
    v.co.x *= 0.85
    v.co.y *= 0.85
bm.to_mesh(me); bm.free()
ob.location = (0.0, 0.0, 0.90)
bpy.ops.object.select_all(action='DESELECT')
ob.select_set(True)
bpy.context.view_layer.objects.active = ob
bpy.ops.object.transform_apply(scale=False)
ob.data.materials.append(MAT_pedernal)

# ---------- 5) Pequeña roca accesoria (composición) ----------
me = bpy.data.meshes.new('SM_Roca_Pedernal_Chica')
ob = bpy.data.objects.new('SM_Roca_Pedernal_Chica', me)
escena.collection.objects.link(ob)
bm2 = bmesh.new()
bmesh.ops.create_icosphere(bm2, subdivisions=1, radius=0.50)
rng.seed(31)
for v in bm2.verts:
    v.co += v.normal * rng.uniform(-0.10, 0.12)
bm2.to_mesh(me); bm2.free()
ob.location = (1.20, 0.55, 0.36)
ob.rotation_euler = (0.3, -0.20, 1.1)
ob.data.materials.append(MAT_pedernal_c)

# ---------- 6) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((radians(55), 0, radians(35)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 7) Cámara ----------
bpy.ops.object.camera_add(location=(3.8, -4.6, 2.0))
cam = bpy.context.object
cam.name = 'CAM_Pedernal'
dir_mira = Vector((0.15, 0.1, 0.55)) - cam.location
cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
escena.camera = cam

# ---------- 8) Flat shading ----------
for ob in escena.objects: ob.select_set(True)
bpy.context.view_layer.objects.active = ob
bpy.ops.object.shade_flat()

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '15-Recursos',
                          'roca_pedernal_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('PEDERNAL OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
