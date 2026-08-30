# crear_lingote_metal_lowpoly.py — Lingote de metal (M16-Crafting)
# Checklist: "Lingote de cobre/hierro/oro"
#
# Composición: un lingote trapezoidal (lingote clásico de fundición) en cobre.
# La parte superior es más angosta que la base, con marcas de fundición en
# relieve. Material metálico con roughness bajo.
#
# Por ahora hago la variante cobre (la más distintiva visualmente). El usuario
# puede duplicar el script y cambiar el material para hierro/oro.
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
def crear_mat(nombre, color, rough=0.30, spec=0.55, metal=0.95):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_cobre = crear_mat('MAT_Lingote_Cobre',  (0.78, 0.42, 0.20), rough=0.35, spec=0.65, metal=0.95)
MAT_marca = crear_mat('MAT_Lingote_Marca',  (0.55, 0.28, 0.13), rough=0.55, spec=0.40, metal=0.85)
MAT_arena = crear_mat('MAT_Arena_Isla',    (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Lingote trapezoidal (E-01: una sola malla bmesh) ----------
# Dimensiones: 0.34 largo, 0.12 ancho, 0.06 alto. Top más estrecho (0.09).
LARGO = 0.34
ANCHO_BOTTOM = 0.12
ANCHO_TOP = 0.09
ALTO = 0.06

# Construimos el prisma trapezoidal con bmesh
bm = bmesh.new()

# 4 esquinas inferiores
esq_inf = [
    (-LARGO / 2,  ANCHO_BOTTOM / 2, 0.0),   # +X+Y abajo
    (-LARGO / 2, -ANCHO_BOTTOM / 2, 0.0),   # +X-Y abajo
    ( LARGO / 2, -ANCHO_BOTTOM / 2, 0.0),   # -X-Y abajo
    ( LARGO / 2,  ANCHO_BOTTOM / 2, 0.0),   # -X+Y abajo
]
esq_sup = [
    (-LARGO / 2,  ANCHO_TOP / 2, ALTO),     # +X+Y arriba
    (-LARGO / 2, -ANCHO_TOP / 2, ALTO),
    ( LARGO / 2, -ANCHO_TOP / 2, ALTO),
    ( LARGO / 2,  ANCHO_TOP / 2, ALTO),
]

# vértices
v_inf = [bm.verts.new(c) for c in esq_inf]
v_sup = [bm.verts.new(c) for c in esq_sup]

# caras laterales (4) entre inferior y superior
for i in range(4):
    j = (i + 1) % 4
    bm.faces.new((v_inf[i], v_inf[j], v_sup[j], v_sup[i]))
# tapa inferior (mirando hacia abajo, normales hacia -Z)
bm.faces.new((v_inf[0], v_inf[1], v_inf[2], v_inf[3]))
# tapa superior (hacia arriba)
bm.faces.new((v_sup[3], v_sup[2], v_sup[1], v_sup[0]))

bm.normal_update()
me = bpy.data.meshes.new('SM_Lingote_Cuerpo')
bm.to_mesh(me)
bm.free()

o = bpy.data.objects.new('SM_Lingote_Cuerpo', me)
escena.collection.objects.link(o)
o.data.materials.append(MAT_cobre)
bpy.ops.object.select_all(action='DESELECT')
o.select_set(True)
bpy.context.view_layer.objects.active = o
bpy.ops.object.shade_flat()

# ---------- 5) Marcas de fundición en la cara superior (3 hendiduras) ----------
marcas_y = ANCHO_TOP * 0.6  # no llega a los bordes
for k, x_offset in enumerate([-LARGO * 0.25, 0.0, LARGO * 0.25]):
    bpy.ops.mesh.primitive_cube_add(size=1.0,
                                     location=(x_offset, 0.0, ALTO + 0.002))
    m = bpy.context.object
    m.name = 'SM_Lingote_Marca_%d' % (k + 1)
    m.scale = (0.012, marcas_y, 0.004)
    m.data.materials.append(MAT_marca)
    # parentar al cuerpo del lingote (E-11)
    m.parent = o
    m.matrix_parent_inverse = o.matrix_world.inverted()

# ---------- 6) Asentado (E-12) ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
# Asentar solo el cuerpo (las marcas van pegadas arriba)
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Lingote_Cuerpo')]
z_min = min(min((ob.matrix_world @ Vector(c)).z for c in ob.bound_box) for ob in piezas)
delta = Z_APOYO - z_min
for ob in piezas:
    ob.location.z += delta
print('LINGOTE asento: z_min %.3f -> %.3f (delta %+.3f)' % (z_min, Z_APOYO, delta))

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

# ---------- 8) Cámara (cerca, el objeto es pequeño) ----------
bpy.ops.object.camera_add(location=(-0.40, -0.55, 0.30))
cam = bpy.context.object
cam.name = 'CAM_Lingote'
blanco = Vector((0.0, 0.0, ALTO / 2))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '16-Crafting',
                          'lingote_metal_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('LINGOTE METAL OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
