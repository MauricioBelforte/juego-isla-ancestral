# crear_concha_mar_lowpoly.py — Concha de mar (M45-Arte3D)
# Checklist: "Concha de mar"
#
# Concha marina estilizada: forma cónica con 5 nervaduras longitudinales
# (giro tipo caracola). Una sola malla bmesh con costillas en relieve
# simuladas por desplazamiento de vértices. Color crema-rosado.
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
def crear_mat(nombre, color, rough=0.85, spec=0.20, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_concha = crear_mat('MAT_Concha_Mar',  (0.92, 0.78, 0.72), rough=0.78)
MAT_interior = crear_mat('MAT_Concha_Interior', (0.96, 0.82, 0.75), rough=0.85)
MAT_arena = crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Concha: espiral logarítmica con 5 vueltas ----------
# Cada "vuelta" es un anillo de vértices. La concha crece en radio.
# 5 vueltas * 12 segmentos por vuelta = 60 segmentos.
N_SEG = 60
LADOS = 5   # 5 costillas a lo largo (rotación por vuelta)
# parámetros
LARGO_MAX = 0.30
GROWTH = 0.05  # cuánto crece el radio por unidad de longitud
PHI = math.pi * (3.0 - math.sqrt(5.0))  # golden angle para distribución

# espiral 2D en XZ; el cono va creciendo en X y Z
rng = random.Random(7)

bm = bmesh.new()
anillos = []
for i in range(N_SEG + 1):
    t = i / N_SEG
    # ángulo a lo largo de la espiral
    ang_esp = t * math.pi * 2 * 2.5  # 2.5 vueltas
    # posición del eje de la concha (la concha crece hacia +X y rota en YZ)
    pos_x = t * LARGO_MAX
    # radio de la concha (achatada: crece en Y, decrece en Z a medida que avanza)
    radio_base = 0.04 + t * 0.18
    # achatada: en Y un poco más que en Z
    radio_y = radio_base
    radio_z = radio_base * 0.65
    verts = []
    for k in range(LADOS):
        ang = 2 * math.pi * k / LADOS + ang_esp
        # pequeño jitter para textura orgánica
        jr = 1.0 + rng.uniform(-0.05, 0.05)
        x = pos_x + 0.0
        y = radio_y * math.cos(ang) * jr
        z = radio_z * math.sin(ang) * jr
        verts.append(bm.verts.new((x, y, z)))
    anillos.append(verts)

# caras laterales
for i in range(N_SEG):
    for k in range(LADOS):
        k2 = (k + 1) % LADOS
        bm.faces.new((anillos[i][k], anillos[i][k2],
                      anillos[i + 1][k2], anillos[i + 1][k]))

# tapa inicial (la punta de la concha, en i=0): triangulada al centro
centro_ini = bm.verts.new(sum((v.co for v in anillos[0]), Vector()) / LADOS)
for k in range(LADOS):
    k2 = (k + 1) % LADOS
    bm.faces.new((centro_ini, anillos[0][k2], anillos[0][k]))

# tapa final (la boca de la concha, en i=N_SEG): abierta
# dejamos la boca abierta (sin cara final), como una concha real.

bm.normal_update()
me = bpy.data.meshes.new('SM_Concha_Mar')
bm.to_mesh(me)
bm.free()

o = bpy.data.objects.new('SM_Concha_Mar', me)
escena.collection.objects.link(o)
o.data.materials.append(MAT_concha)
# acostar la concha con la boca mirando hacia +X
o.rotation_euler = Euler((0.0, 0.0, math.radians(-90)), 'XYZ')
bpy.ops.object.select_all(action='DESELECT')
o.select_set(True)
bpy.context.view_layer.objects.active = o
bpy.ops.object.shade_flat()

# ---------- 5) Interior de la concha (visible por la boca) ----------
# Un disco pequeño en la posición de la boca, un poco más adentro
bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.04, depth=0.005,
                                     location=(LARGO_MAX + 0.01, 0.0, 0.0))
interior = bpy.context.object
interior.name = 'SM_Concha_Interior'
interior.rotation_euler = Euler((0.0, math.radians(90), 0.0), 'XYZ')
interior.data.materials.append(MAT_interior)
bpy.ops.object.select_all(action='DESELECT')
interior.select_set(True)
bpy.context.view_layer.objects.active = interior
bpy.ops.object.shade_flat()

# ---------- 6) Asentado (E-12) — la concha se apoya de costado en la arena ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name == 'SM_Concha_Mar']
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    o.location.z += delta
print('CONCHA asento: z_min %.3f -> %.3f (delta %+.3f)' % (z_min, Z_APOYO, delta))

# ---------- 7) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(6), math.radians(28)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 8) Cámara (lateral) ----------
bpy.ops.object.camera_add(location=(0.0, -0.55, 0.25))
cam = bpy.context.object
cam.name = 'CAM_Concha'
blanco = Vector((0.15, 0.0, 0.0))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '45-Arte3D',
                          'concha_mar_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('CONCHA MAR OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
