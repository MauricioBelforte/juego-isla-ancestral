# crear_tablon_madera_lowpoly.py — Tablón de madera (M16-Crafting)
# Checklist: "Tablón de madera (recurso)"
#
# Composición: 3 tablones apilados en una pila, cada uno ligeramente girado
# respecto al de abajo (asimetría manual, no perfectamente alineados). Vetas
# longitudinales con bajorrelieve tenue.
#
# Asentado a z_min=0.045 (E-12).
import bpy
import bmesh
import os
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
def crear_mat(nombre, color, rough=0.85, spec=0.12, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_tablón_a = crear_mat('MAT_Tablon_A', (0.46, 0.31, 0.18), rough=0.88)
MAT_tablón_b = crear_mat('MAT_Tablon_B', (0.40, 0.27, 0.15), rough=0.88)
MAT_tablón_c = crear_mat('MAT_Tablon_C', (0.52, 0.36, 0.22), rough=0.88)
MAT_arena    = crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Tres tablones apilados ----------
# Cada tablón: 1.20 m de largo, 0.18 m de ancho, 0.06 m de alto
LONG = 1.20
ANCHO = 0.18
ALTO = 0.06

tablas = [
    (MAT_tablón_a, 0.03, math.radians(2)),
    (MAT_tablón_b, 0.10, math.radians(-4)),
    (MAT_tablón_c, 0.17, math.radians(6)),
]
for i, (mat, z_center, rot_z) in enumerate(tablas):
    bpy.ops.mesh.primitive_cube_add(size=1.0,
                                     location=(0.0, 0.0, z_center))
    o = bpy.context.object
    o.name = 'SM_Tablon_%d' % (i + 1)
    o.scale = (LONG, ANCHO, ALTO)
    o.rotation_euler = Euler((0.0, 0.0, rot_z), 'XYZ')
    o.data.materials.append(mat)
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()

# ---------- 5) Vetas longitudinales (1 por tablón, sutiles) ----------
# Pequeñas líneas oscuras sobre la cara superior de cada tablón, parentadas (E-11)
# para que sigan cualquier rotación posterior.
for i, (mat, z_center, rot_z) in enumerate(tablas):
    bpy.ops.mesh.primitive_cube_add(size=1.0,
                                     location=(0.0, 0.0, z_center + ALTO / 2 + 0.003))
    veta = bpy.context.object
    veta.name = 'SM_Tablon_Veta_%d' % (i + 1)
    veta.scale = (LONG * 0.85, ANCHO * 0.15, 0.005)
    veta.rotation_euler = Euler((0.0, 0.0, rot_z), 'XYZ')
    veta.data.materials.append(crear_mat('MAT_Veta_%d' % (i + 1),
                                          (mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value[0] * 0.5,
                                           mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value[1] * 0.5,
                                           mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value[2] * 0.5),
                                          rough=0.95))

# ---------- 6) Asentado (E-12) ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and (o.name.startswith('SM_Tablon_') and not o.name.startswith('SM_Tablon_Veta_'))]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    o.location.z += delta
# Las vetas suben con su tablón (están parentadas por transformación, no por parent real)
# Pero como aquí se posicionaron en world, hay que actualizarlas igual:
for veta in escena.objects:
    if veta.name.startswith('SM_Tablon_Veta_'):
        veta.location.z += delta
print('TABLONES asento: z_min %.3f -> %.3f (delta %+.3f, n_tab=%d)' % (z_min, Z_APOYO, delta, len(piezas)))

# ---------- 7) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(55), math.radians(8), math.radians(30)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 8) Cámara ----------
bpy.ops.object.camera_add(location=(1.6, -1.4, 0.7))
cam = bpy.context.object
cam.name = 'CAM_Tablon'
blanco = Vector((0.0, 0.0, 0.12))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '16-Crafting',
                          'tablon_madera_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('TABLON MADERA OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
