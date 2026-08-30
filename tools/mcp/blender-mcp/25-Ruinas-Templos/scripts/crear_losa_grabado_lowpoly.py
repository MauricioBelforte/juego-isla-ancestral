# crear_losa_grabado_lowpoly.py — Losa con grabado (M25-Ruinas-Templos)
# Checklist: "Losa con grabado (piso de puzzle)"
#
# Composición: losa plana de piedra (1.2 × 0.8 × 0.10) apoyada en el suelo,
# con un patrón en relieve de glifos (cuadrados + líneas) tallados en la
# cara superior.
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

MAT_losa  = crear_mat('MAT_Losa_Grabado',  (0.55, 0.50, 0.42), rough=0.94)
MAT_talla = crear_mat('MAT_Talla_Grabado', (0.82, 0.68, 0.40), rough=0.76)
MAT_arena = crear_mat('MAT_Arena_Isla',    (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.8, depth=0.24,
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

# ---------- 5) Losa base ----------
W, D, H = 1.20, 0.80, 0.10
losa = agregar('SM_Losa_Base',
               nueva_caja('SM_Losa_Base', 0.0, 0.0, H / 2, W, D, H),
               MAT_losa)

# ---------- 6) Patrón de glifos en relieve sobre la cara superior ----------
# Grilla 3x5 de celdas; cada celda con 50% de prob de tener un cuadrado en relieve.
# Cuadrados con tamaño 0.18 x 0.02 x 0.18 justo arriba de la cara.
rng = random.Random(7)
NCOLS = 3
NROWS = 5
margin_x = 0.10
margin_y = 0.08
cell_w = (W - margin_x * 2) / NCOLS
cell_d = (D - margin_y * 2) / NROWS
for j in range(NROWS):
    for i in range(NCOLS):
        # Algunos vacíos
        if rng.random() < 0.30:
            continue
        cx = -W / 2 + margin_x + (i + 0.5) * cell_w
        cy = -D / 2 + margin_y + (j + 0.5) * cell_d
        # A veces un par de celdas en línea horizontal
        w_actual = cell_w * 0.55
        d_actual = cell_d * 0.55
        agregar('SM_Losa_Glifo_%d_%d' % (j + 1, i + 1),
                nueva_caja('SM_Losa_Glifo_%d_%d' % (j + 1, i + 1),
                           cx, cy, H + 0.01,
                           w_actual, 0.02, d_actual),
                MAT_talla, padre=losa)

# Líneas conectoras entre algunas celdas (relieves finos)
for k in range(4):
    # Posiciones aleatorias
    j1 = rng.randint(0, NROWS - 1)
    i1 = rng.randint(0, NCOLS - 1)
    j2 = j1 + rng.choice((-1, 0, 1))
    i2 = i1 + rng.choice((-1, 0, 1))
    j2 = max(0, min(NROWS - 1, j2))
    i2 = max(0, min(NCOLS - 1, i2))
    if (i1, j1) == (i2, j2):
        continue
    cx = (-W / 2 + margin_x + (i1 + 0.5) * cell_w +
          (-W / 2 + margin_x + (i2 + 0.5) * cell_w)) / 2
    cy = (-D / 2 + margin_y + (j1 + 0.5) * cell_d +
          (-D / 2 + margin_y + (j2 + 0.5) * cell_d)) / 2
    ext_x = abs(i1 - i2) * cell_w * 0.55
    ext_y = abs(j1 - j2) * cell_d * 0.55
    if ext_x > ext_y:
        agregar('SM_Losa_Linea_%d' % (k + 1),
                nueva_caja('SM_Losa_Linea_%d' % (k + 1), cx, cy, H + 0.01,
                           ext_x + cell_w * 0.3, 0.018, 0.04),
                MAT_talla, padre=losa)
    else:
        agregar('SM_Losa_Linea_%d' % (k + 1),
                nueva_caja('SM_Losa_Linea_%d' % (k + 1), cx, cy, H + 0.01,
                           0.04, 0.018, ext_y + cell_d * 0.3),
                MAT_talla, padre=losa)

# ---------- 7) Pequeñas roturas en los bordes ----------
for k in range(4):
    ang = k * math.pi / 2 + 0.3
    rad = 0.50 + rng.uniform(-0.05, 0.05)
    agregar('SM_Losa_Rotura_%d' % (k + 1),
            nueva_caja('SM_Losa_Rotura_%d' % (k + 1),
                       rad * math.cos(ang), rad * math.sin(ang),
                       0.05 + rng.uniform(-0.01, 0.01),
                       rng.uniform(0.08, 0.14), rng.uniform(0.06, 0.10), 0.02),
            MAT_losa, padre=losa)

# ---------- 8) Asentado (E-12) ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Losa')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:
        o.location.z += delta
print('LOSA asento: z_min %.3f -> %.3f (delta %+.3f)'
      % (z_min, Z_APOYO, delta))

# ---------- 9) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.4
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(60), math.radians(8), math.radians(35)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 10) Cámara (vista en picado) ----------
bpy.ops.object.camera_add(location=(1.4, 1.2, 1.1))
cam = bpy.context.object
cam.name = 'CAM_Losa'
blanco = Vector((0.0, 0.0, 0.0))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 11) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '25-Ruinas-Templos',
                          'losa_grabado_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('LOSA GRABADO OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
