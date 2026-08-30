# crear_piedra_afilar_lowpoly.py — Piedra de afilar (M15-Recursos)
# Checklist: "Piedra de afilar"
#
# Composición: bloque de piedra rectangular achatado con la cara superior
# ligeramente cóncava (superficie de afilar). Es el clásico "whetstone"
# de cantimplora. 1 sola malla, apoyada en la arena.
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

MAT_piedra  = crear_mat('MAT_Piedra_Afilar',     (0.52, 0.49, 0.44), rough=0.85)
MAT_piedra_osc = crear_mat('MAT_Piedra_Afilar_Osc', (0.36, 0.34, 0.30), rough=0.90)
MAT_arena   = crear_mat('MAT_Arena_Isla',        (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Piedra de afilar: bloque achatado con cara superior cóncava ----------
# Dimensiones: 0.18 largo, 0.06 ancho, 0.04 alto. La cara superior es levemente
# cóncava (centro hundido 0.005).
LARGO = 0.18
ANCHO = 0.06
ALTO = 0.04
CONCAVIDAD = 0.005

# 4 esquinas inferiores + 4 superiores (con concavidad)
esq_inf = [
    (-LARGO / 2, -ANCHO / 2, 0.0),
    ( LARGO / 2, -ANCHO / 2, 0.0),
    ( LARGO / 2,  ANCHO / 2, 0.0),
    (-LARGO / 2,  ANCHO / 2, 0.0),
]
esq_sup = [
    (-LARGO / 2, -ANCHO / 2, ALTO),
    ( LARGO / 2, -ANCHO / 2, ALTO),
    ( LARGO / 2,  ANCHO / 2, ALTO),
    (-LARGO / 2,  ANCHO / 2, ALTO),
]
centro_sup = (0.0, 0.0, ALTO - CONCAVIDAD)

bm = bmesh.new()
v_inf = [bm.verts.new(c) for c in esq_inf]
v_sup_esq = [bm.verts.new(c) for c in esq_sup]
v_sup_cen = bm.verts.new(centro_sup)

# caras laterales (4)
for i in range(4):
    j = (i + 1) % 4
    bm.faces.new((v_inf[i], v_inf[j], v_sup_esq[j], v_sup_esq[i]))
# cara inferior
bm.faces.new((v_inf[0], v_inf[1], v_inf[2], v_inf[3]))
# cara superior: triangulada con el centro (cóncava)
for i in range(4):
    j = (i + 1) % 4
    bm.faces.new((v_sup_cen, v_sup_esq[i], v_sup_esq[j]))

# leve jitter en los vértices superiores para que no parezca perfecta
rng = random.Random(11)
for v in v_sup_esq:
    v.co = (v.co.x + rng.uniform(-0.001, 0.001),
            v.co.y + rng.uniform(-0.001, 0.001),
            v.co.z + rng.uniform(-0.001, 0.001))

bm.normal_update()
me = bpy.data.meshes.new('SM_Piedra_Afilar')
bm.to_mesh(me)
bm.free()

o = bpy.data.objects.new('SM_Piedra_Afilar', me)
escena.collection.objects.link(o)
o.data.materials.append(MAT_piedra)
# leve rotación para que se vea natural
o.rotation_euler = Euler((0.0, 0.0, math.radians(8)), 'XYZ')
bpy.ops.object.select_all(action='DESELECT')
o.select_set(True)
bpy.context.view_layer.objects.active = o
bpy.ops.object.shade_flat()

# ---------- 5) Viruta de metal al lado (guiño visual: la piedra se usó) ----------
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.20, 0.06, 0.005))
viruta = bpy.context.object
viruta.name = 'SM_Piedra_Afilar_Viruta'
viruta.scale = (0.012, 0.003, 0.002)
viruta.rotation_euler = Euler((0.0, 0.0, math.radians(20)), 'XYZ')
viruta.data.materials.append(MAT_piedra_osc)
bpy.ops.object.select_all(action='DESELECT')
viruta.select_set(True)
bpy.context.view_layer.objects.active = viruta
bpy.ops.object.shade_flat()

# ---------- 6) Asentado (E-12) ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Piedra_Afilar') and 'Viruta' not in o.name]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    o.location.z += delta
print('PIEDRA AFILAR asento: z_min %.3f -> %.3f (delta %+.3f)' % (z_min, Z_APOYO, delta))

# ---------- 7) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(6), math.radians(30)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 8) Cámara (cerca) ----------
bpy.ops.object.camera_add(location=(-0.18, -0.25, 0.18))
cam = bpy.context.object
cam.name = 'CAM_PiedraAfilar'
blanco = Vector((0.0, 0.0, 0.025))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '15-Recursos',
                          'piedra_afilar_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('PIEDRA AFILAR OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
