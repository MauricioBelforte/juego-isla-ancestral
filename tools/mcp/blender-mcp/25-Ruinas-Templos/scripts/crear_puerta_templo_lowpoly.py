# crear_puerta_templo_lowpoly.py — Puerta de templo (M25-Ruinas-Templos)
# Checklist: "Puerta de templo (doble hoja de piedra)"
#
# Composición: marco de piedra (2 jambas + dintel) + 2 hojas de piedra
# (cada una con paneles en relieve) + glifo central sobre el dintel.
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
def crear_mat(nombre, color, rough=0.9, spec=0.1, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_marco = crear_mat('MAT_Marco_Puerta',   (0.50, 0.45, 0.38), rough=0.94)
MAT_hoja  = crear_mat('MAT_Hoja_Puerta',    (0.45, 0.40, 0.34), rough=0.92)
MAT_talla = crear_mat('MAT_Talla_Puerta',   (0.82, 0.68, 0.40), rough=0.78)
MAT_arena = crear_mat('MAT_Arena_Isla',     (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
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

# ---------- 5) Marco: 2 jambas + dintel + umbral ----------
JAMBA_W = 0.20
ANCHO_TOTAL = 1.40
ALTO_TOTAL = 2.30
PROF = 0.18

# Jamba izquierda
agregar('SM_Puerta_Jamba_I',
        nueva_caja('SM_Puerta_Jamba_I', -ANCHO_TOTAL / 2 - JAMBA_W / 2, 0.0, ALTO_TOTAL / 2,
                   JAMBA_W, PROF, ALTO_TOTAL),
        MAT_marco)
# Jamba derecha
agregar('SM_Puerta_Jamba_D',
        nueva_caja('SM_Puerta_Jamba_D', ANCHO_TOTAL / 2 + JAMBA_W / 2, 0.0, ALTO_TOTAL / 2,
                   JAMBA_W, PROF, ALTO_TOTAL),
        MAT_marco)
# Dintel
agregar('SM_Puerta_Dintel',
        nueva_caja('SM_Puerta_Dintel', 0.0, 0.0, ALTO_TOTAL + 0.16,
                   ANCHO_TOTAL + JAMBA_W * 2, PROF, 0.32),
        MAT_marco)
# Umbral
agregar('SM_Puerta_Umbral',
        nueva_caja('SM_Puerta_Umbral', 0.0, 0.0, 0.04,
                   ANCHO_TOTAL + JAMBA_W * 2, PROF, 0.08),
        MAT_marco)

# ---------- 6) 2 hojas de piedra ----------
HOJA_W = ANCHO_TOTAL / 2 - 0.02
HOJA_H = ALTO_TOTAL - 0.05
for k, sx in enumerate((-1, 1)):
    hoja = agregar('SM_Puerta_Hoja_%s' % ('I' if sx<0 else 'D'),
                   nueva_caja('SM_Puerta_Hoja_%s' % ('I' if sx<0 else 'D'),
                              sx * (ANCHO_TOTAL / 4), 0.0, 0.08 + HOJA_H / 2,
                              HOJA_W, PROF * 0.85, HOJA_H),
                   MAT_hoja)
    # 3 paneles en relieve en cada hoja
    for j in range(3):
        py = 0.04 + j * 0.55
        agregar('SM_Puerta_Hoja_%s_Panel_%d' % ('I' if sx<0 else 'D', j + 1),
                nueva_caja('SM_Puerta_Hoja_%s_Panel_%d' % ('I' if sx<0 else 'D', j + 1),
                           0.0, 0.0, py, HOJA_W * 0.78, PROF + 0.001, 0.30),
                MAT_talla, padre=hoja)

# ---------- 7) Glifo central sobre el dintel ----------
# 3 paneles pequeños en hilera sobre el dintel
for k in range(3):
    px = (k - 1) * 0.30
    agregar('SM_Puerta_Glifo_%d' % (k + 1),
            nueva_caja('SM_Puerta_Glifo_%d' % (k + 1), px, 0.0, ALTO_TOTAL + 0.36,
                       0.22, PROF + 0.001, 0.22),
            MAT_talla)

# ---------- 8) Asentado (E-12) ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Puerta')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:
        o.location.z += delta
print('PUERTA TEMPLO asento: z_min %.3f -> %.3f (delta %+.3f)'
      % (z_min, Z_APOYO, delta))

# ---------- 9) Iluminación + mundo ----------
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

# ---------- 10) Cámara ----------
bpy.ops.object.camera_add(location=(0.0, -2.5, 1.4))
cam = bpy.context.object
cam.name = 'CAM_Puerta'
blanco = Vector((0.0, 0.0, 1.20))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 50
escena.camera = cam

# ---------- 11) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '25-Ruinas-Templos',
                          'puerta_templo_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('PUERTA TEMPLO OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
