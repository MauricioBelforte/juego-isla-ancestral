# crear_flor_isla_lowpoly.py — Flor de isla coleccionable (M50-Vegetacion)
# Checklist: "Flor de isla (ejemplar coleccionable)"
# Composición: tallo cilíndrico fino + 5 pétalos planos alrededor +
# centro amarillo convexo. Para distinguirla en la escena le doy pétalos
# en color cálido (rosa/coral) y centro amarillo.
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
def crear_mat(nombre, color, rough=0.85, spec=0.10):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    return m

MAT_tallo  = crear_mat('MAT_Tallo_Flor',  (0.20, 0.50, 0.18), rough=0.85)
MAT_petalo = crear_mat('MAT_Petalo_Flor', (0.96, 0.45, 0.55), rough=0.75)  # rosa coral
MAT_centro = crear_mat('MAT_Centro_Flor', (1.00, 0.85, 0.20), rough=0.65)
MAT_hoja   = crear_mat('MAT_Hoja_Flor',   (0.25, 0.55, 0.20), rough=0.85)
MAT_arena  = crear_mat('MAT_Arena_Isla',  (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.22,
                                    location=(0, 0, -0.11))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Tallo: una sola malla bmesh levemente curvada ----------
me = bpy.data.meshes.new('M_Tallo_Flor')
ob = bpy.data.objects.new('SM_Tallo_Flor', me)
escena.collection.objects.link(ob)
bm = bmesh.new()
SEG_L, LADOS = 10, 6
anillos = []
for i in range(SEG_L + 1):
    t = i / SEG_L
    z = t * 1.05
    x = 0.10 * (t ** 1.5)            # curvatura leve
    r = 0.04 - 0.015 * t             # afinado hacia arriba
    anillos.append([bm.verts.new((x + r * cos(2 * pi * k / LADOS),
                                  r * sin(2 * pi * k / LADOS), z))
                    for k in range(LADOS)])
for i in range(SEG_L):
    for k in range(LADOS):
        bm.faces.new([anillos[i][k], anillos[i][(k + 1) % LADOS],
                      anillos[i + 1][(k + 1) % LADOS], anillos[i + 1][k]])
bm.faces.new(anillos[0][::-1])
bm.faces.new(anillos[-1])
bm.to_mesh(me); bm.free()
ob.data.materials.append(MAT_tallo)
top_pos = (0.10, 0.0, 1.05)

# ---------- 5) Hoja al costado (un par) ----------
def crear_hoja(idx, ang, z):
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.08, radius2=0.0,
                                    depth=0.30, location=(0.06 * cos(ang), 0.06 * sin(ang), z))
    h = bpy.context.object
    h.name = f'SM_Hoja_Flor_{idx}'
    h.rotation_euler = (radians(45), 0, radians(ang * 180 / pi))
    h.data.materials.append(MAT_hoja)
crear_hoja(0, 0.0, 0.45)
crear_hoja(1, 1.5, 0.60)

# ---------- 6) Pétalos: 5 conos chatos a 72° alrededor del tope ----------
def crear_petalo(idx, ang):
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.16, radius2=0.0,
                                    depth=0.32, location=(top_pos[0] + cos(ang) * 0.15,
                                                          top_pos[1] + sin(ang) * 0.15,
                                                          top_pos[2] + 0.02))
    p = bpy.context.object
    p.name = f'SM_Petalo_{idx}'
    # orientar el cono hacia afuera del centro y levantarlo un poco
    p.rotation_euler = (radians(75), 0, radians(ang * 180 / pi))
    p.data.materials.append(MAT_petalo)
for i in range(5):
    crear_petalo(i, i * (2 * pi / 5))

# ---------- 7) Centro amarillo: ico-esfera achatada ----------
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.13,
                                      location=(top_pos[0], top_pos[1], top_pos[2] + 0.06))
centro = bpy.context.object
centro.name = 'SM_Centro_Flor'
centro.scale = (1.2, 1.2, 0.65)
bpy.ops.object.select_all(action='DESELECT')
centro.select_set(True)
bpy.context.view_layer.objects.active = centro
bpy.ops.object.transform_apply(scale=True)
centro.data.materials.append(MAT_centro)

# ---------- 8) Iluminación + mundo ----------
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

# ---------- 9) Cámara ----------
bpy.ops.object.camera_add(location=(2.4, -3.0, 1.4))
cam = bpy.context.object
cam.name = 'CAM_FlorIsla'
dir_mira = Vector(top_pos) - cam.location
cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
escena.camera = cam

# ---------- 10) Flat shading ----------
for ob in escena.objects: ob.select_set(True)
bpy.context.view_layer.objects.active = ob
bpy.ops.object.shade_flat()

# ---------- 11) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'flor_isla_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('FLOR ISLA OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
