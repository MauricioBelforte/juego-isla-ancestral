# crear_farola_fuego_lowpoly.py — Farola de fuego (M40-Infraestructura)
# Checklist: "Farola de fuego (poste + brasero)"
#
# Composición: base de piedra, poste de madera, brasero de hierro con
# brasas y llama (emisión cálida).
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
def crear_mat(nombre, color, rough=0.85, spec=0.1, metal=0.0, emission=0.0):
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

MAT_piedra  = crear_mat('MAT_Piedra_Farola',  (0.55, 0.50, 0.43), rough=0.93)
MAT_madera  = crear_mat('MAT_Madera_Farola',  (0.40, 0.26, 0.14), rough=0.86)
MAT_hierro  = crear_mat('MAT_Hierro_Farola',  (0.32, 0.30, 0.28), rough=0.55, metal=0.7)
MAT_brasa   = crear_mat('MAT_Brasa_Farola',   (1.0, 0.50, 0.10), rough=0.45, emission=0.7)
MAT_llama   = crear_mat('MAT_Llama_Farola',   (1.0, 0.78, 0.20), rough=0.20, emission=1.5)
MAT_arena   = crear_mat('MAT_Arena_Isla',     (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.0, depth=0.24,
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

# ---------- 5) Base de piedra ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.20, depth=0.10,
                                    location=(0.0, 0.0, 0.05))
bs = bpy.context.object
bs.name = 'SM_Farola_Base'
bs.data.materials.append(MAT_piedra)
bpy.ops.object.select_all(action='DESELECT')
bs.select_set(True)
bpy.context.view_layer.objects.active = bs
bpy.ops.object.shade_flat()

# ---------- 6) Poste de madera ----------
agregar('SM_Farola_Poste',
        nueva_caja('SM_Farola_Poste', 0.0, 0.0, 0.85,
                   0.10, 0.10, 1.50),
        MAT_madera)

# Refuerzo de hierro en la base del poste
agregar('SM_Farola_Refuerzo',
        nueva_caja('SM_Farola_Refuerzo', 0.0, 0.0, 0.20,
                   0.14, 0.14, 0.08),
        MAT_hierro)

# ---------- 7) Brazo horizontal corto + aro de soporte ----------
agregar('SM_Farola_Brazo',
        nueva_caja('SM_Farola_Brazo', 0.0, 0.18, 1.50,
                   0.06, 0.32, 0.06),
        MAT_madera)

# Aro de soporte del brasero (toroide en la punta del brazo)
bpy.ops.mesh.primitive_torus_add(major_radius=0.08, minor_radius=0.015,
                                 location=(0.0, 0.36, 1.50),
                                 major_segments=12, minor_segments=4)
aro = bpy.context.object
aro.name = 'SM_Farola_Aro'
aro.data.materials.append(MAT_hierro)
bpy.ops.object.select_all(action='DESELECT')
aro.select_set(True)
bpy.context.view_layer.objects.active = aro
bpy.ops.object.shade_flat()

# Cadena corta del aro al brasero
agregar('SM_Farola_Cadena',
        nueva_caja('SM_Farola_Cadena', 0.0, 0.36, 1.42,
                   0.02, 0.02, 0.10),
        MAT_hierro)

# ---------- 8) Brasero (cesta de hierro con borde) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.10, depth=0.06,
                                    location=(0.0, 0.36, 1.32))
br = bpy.context.object
br.name = 'SM_Farola_Brasero'
br.data.materials.append(MAT_hierro)
bpy.ops.object.select_all(action='DESELECT')
br.select_set(True)
bpy.context.view_layer.objects.active = br
bpy.ops.object.shade_flat()

# Brasa dentro del brasero
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.05,
                                      location=(0.0, 0.36, 1.36))
brasa = bpy.context.object
brasa.name = 'SM_Farola_Brasa'
brasa.data.materials.append(MAT_brasa)
bpy.ops.object.select_all(action='DESELECT')
brasa.select_set(True)
bpy.context.view_layer.objects.active = brasa
bpy.ops.object.shade_flat()

# Llama (cono amarillo-naranja con emisión fuerte)
bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.04, radius2=0.0,
                                depth=0.18, location=(0.0, 0.36, 1.45))
llama = bpy.context.object
llama.name = 'SM_Farola_Llama'
llama.data.materials.append(MAT_llama)
bpy.ops.object.select_all(action='DESELECT')
llama.select_set(True)
bpy.context.view_layer.objects.active = llama
bpy.ops.object.shade_flat()

# Pequeñas aspas decorativas (4) en el aro
for k in range(4):
    az = 2 * math.pi * k / 4
    agregar('SM_Farola_Aspa_%d' % (k + 1),
            nueva_caja('SM_Farola_Aspa_%d' % (k + 1),
                       0.10 * math.cos(az), 0.36 + 0.10 * math.sin(az), 1.50,
                       0.05, 0.02, 0.02),
            MAT_hierro)

# ---------- 9) Asentado (E-12) — la base debe estar en 0.045 ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Farola')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:
        o.location.z += delta
print('FAROLA asento: z_min %.3f -> %.3f (delta %+.3f)'
      % (z_min, Z_APOYO, delta))

# ---------- 10) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 2.4   # atardecer para que la llama destaque
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(35), math.radians(15), math.radians(35)), 'XYZ')

# Luz cálida desde la llama
sol2_data = bpy.data.lights.new('LLAMA', type='POINT')
sol2_data.energy = 6.0
sol2_data.color = (1.0, 0.55, 0.20)
sol2_data.shadow_soft_size = 0.30
sol2 = bpy.data.objects.new('LLAMA', sol2_data)
escena.collection.objects.link(sol2)
sol2.location = (0.0, 0.36, 1.50)

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.30, 0.32, 0.45, 1.0)   # anochecer
bg.inputs[1].default_value = 0.30

# ---------- 11) Cámara ----------
bpy.ops.object.camera_add(location=(1.5, 1.5, 1.0))
cam = bpy.context.object
cam.name = 'CAM_Farola'
blanco = Vector((0.0, 0.0, 1.00))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 12) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '40-Infraestructura',
                          'farola_fuego_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('FAROLA FUEGO OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
