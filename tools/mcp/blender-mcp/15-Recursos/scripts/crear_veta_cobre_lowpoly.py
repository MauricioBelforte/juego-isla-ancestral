# crear_veta_cobre_lowpoly.py — Veta de cobre (M15-Recursos)
# Checklist: "Veta de cobre (roca con cristales naranjas)"
# Composición: roca gris base + 6 prismas hexagonales cobre emergiendo.
# v2: cristales más largos, base enterrada en la roca, mejor framing.
import bpy
import bmesh
import os
from math import radians, sin, cos, pi
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
def crear_mat(nombre, color, rough=0.7, spec=0.15, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    b.inputs['Metallic'].default_value = metal
    return m

MAT_roca    = crear_mat('MAT_Roca_Cobre',   (0.42, 0.38, 0.34), rough=0.85)
MAT_cobre   = crear_mat('MAT_Cristal_Cobre',(0.88, 0.45, 0.18), rough=0.30, metal=0.55)
MAT_cobre_b = crear_mat('MAT_Cristal_Cobre_Oscuro', (0.62, 0.30, 0.12), rough=0.35, metal=0.55)
MAT_arena   = crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.8, depth=0.22,
                                    location=(0, 0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Roca base (achatada, más ancha) ----------
me = bpy.data.meshes.new('SM_Roca_VetaCobre')
ob = bpy.data.objects.new('SM_Roca_VetaCobre', me)
escena.collection.objects.link(ob)
bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=2, radius=1.00)
rng = __import__('random'); rng.seed(41)
for v in bm.verts:
    v.co += v.normal * rng.uniform(-0.10, 0.14)
bm.to_mesh(me); bm.free()
ob.location = (0.0, 0.0, 0.55)
ob.scale = (1.35, 1.20, 0.55)
bpy.ops.object.select_all(action='DESELECT')
ob.select_set(True)
bpy.context.view_layer.objects.active = ob
bpy.ops.object.transform_apply(scale=True)
bpy.ops.object.shade_flat()
ob.data.materials.append(MAT_roca)

# La cima de la roca está en z ~ 0.55 + (1.00*0.55) = 1.10
# Para que el cristal asome ~70%, su base debe estar cerca de 1.05 y largo ~1.10

# ---------- 5) Cristales: prismas hexagonales bmesh ----------
def crear_cristal(idx, base_pos, largo, radio, mat, tilt_x, yaw_z):
    SEG_L, LADOS = 4, 6
    bm = bmesh.new()
    anillos = []
    for i in range(SEG_L + 1):
        t = i / SEG_L
        z = t * largo
        r = radio * (1.0 - 0.80 * t)  # punta al final
        anillo = []
        for k in range(LADOS):
            angulo = 2 * pi * k / LADOS + 0.15  # desfase para que no se alineen feo
            anillo.append(bm.verts.new((r * cos(angulo), r * sin(angulo), z)))
        anillos.append(anillo)
    for i in range(SEG_L):
        for k in range(LADOS):
            k_next = (k + 1) % LADOS
            bm.faces.new([anillos[i][k], anillos[i][k_next],
                          anillos[i + 1][k_next], anillos[i + 1][k]])
    bm.faces.new(anillos[0][::-1])  # base cerrada
    me = bpy.data.meshes.new(f'M_Cristal_{idx}')
    bm.to_mesh(me); bm.free()
    ob = bpy.data.objects.new(f'SM_Cristal_{idx}', me)
    escena.collection.objects.link(ob)
    ob.location = base_pos
    ob.rotation_euler = Euler((radians(tilt_x), 0, radians(yaw_z)), 'XYZ')
    bpy.ops.object.select_all(action='DESELECT')
    ob.select_set(True)
    bpy.context.view_layer.objects.active = ob
    bpy.ops.object.shade_flat()
    ob.data.materials.append(mat)

# 6 cristales: largo 1.10-1.30, base z enterrada en la roca (~0.85-0.95),
# radio 0.18-0.24 (más anchos que v1), tilts moderados
cristales = [
    # x,    y,    z_base, largo, radio, mat,         tilt_x, yaw_z
    ( 0.10, -0.10, 0.95,  1.20, 0.22, MAT_cobre,   18,  15),
    ( 0.35,  0.18, 0.90,  1.10, 0.18, MAT_cobre_b, 12,  95),
    (-0.25,  0.32, 0.88,  1.05, 0.20, MAT_cobre,   25, -45),
    (-0.40, -0.20, 0.82,  0.95, 0.18, MAT_cobre_b, 28, 200),
    ( 0.18,  0.42, 0.78,  0.85, 0.16, MAT_cobre,   32,  55),
    ( 0.42, -0.32, 0.72,  0.75, 0.15, MAT_cobre_b, 35, 285),
]
for i, c in enumerate(cristales):
    crear_cristal(i, c[:3], c[3], c[4], c[5], c[6], c[7])

# ---------- 6) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.4
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((radians(52), radians(6), radians(32)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 7) Cámara (más cerca) ----------
bpy.ops.object.camera_add(location=(2.6, -2.8, 1.6))
cam = bpy.context.object
cam.name = 'CAM_VetaCobre'
dir_mira = Vector((0.05, 0.0, 1.1)) - cam.location
cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
escena.camera = cam
cam.data.lens = 45

# ---------- 8) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '15-Recursos',
                          'veta_cobre_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('VETA COBRE v2 OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
