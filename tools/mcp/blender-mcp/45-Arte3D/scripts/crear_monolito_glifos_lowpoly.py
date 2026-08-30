# crear_monolito_glifos_lowpoly.py — Monolito con glifos (M45-Arte3D)
# Checklist: "Monolito con glifos"
#
# Composición: prisma de piedra vertical (obelisco) ligeramente erosionado en
# la base, con 3-4 glifos tallados en relieve en la cara frontal. Los glifos
# son hijos del monolito (E-11) para que sigan la rotación de la pieza.
#
# Convenciones:
#   - Todo en una pieza, apoyado en la arena.
#   - Un solo material MAT_Piedra_Monolito con roughness alta (piedra erosionada).
#   - Glifos en MAT_Glifo_Ancestral, color ligeramente más claro.
#   - Cara frontal = +Y (para que la cámara por defecto la vea).
#   - Asentado en z_min=0.045 (E-12).
import bpy
import bmesh
import os
import random
import math
from mathutils import Vector, Euler

# ---------- 1) Limpieza (idempotencia) ----------
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

MAT_piedra = crear_mat('MAT_Piedra_Monolito',  (0.45, 0.42, 0.36), rough=0.95)
MAT_glifo  = crear_mat('MAT_Glifo_Ancestral', (0.82, 0.71, 0.50), rough=0.75)
MAT_arena  = crear_mat('MAT_Arena_Isla',      (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena (NO exportar) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Monolito: prisma rectangular erosionado (E-01, una sola malla) ----------
# 4 estaciones a lo largo de Z (altura), erosionando levemente la base
ALTURA = 1.85
SEG_Z = 6
ANCHO = 0.42   # en X
PROF  = 0.32   # en Y (más fino que ancho)
# vértices por estación: 4 esquinas (prisma rectangular)
rng = random.Random(7)
ruido_z = [[rng.uniform(0.96, 1.04) for _ in range(4)] for _ in range(SEG_Z + 1)]

# vértices del prisma: orden (X+, Y+), (X-, Y+), (X-, Y-), (X+, Y-)
esquinas = [
    ( ANCHO / 2,  PROF / 2),
    (-ANCHO / 2,  PROF / 2),
    (-ANCHO / 2, -PROF / 2),
    ( ANCHO / 2, -PROF / 2),
]

bm = bmesh.new()
anillos = []
for i in range(SEG_Z + 1):
    t = i / SEG_Z
    z = t * ALTURA
    # erosionar levemente la base (t<0.3): achicar un poco y ladear
    erosion_x = 1.0 - 0.04 * max(0, 0.30 - t) / 0.30
    erosion_y = 1.0 - 0.04 * max(0, 0.30 - t) / 0.30
    # leve inclinación hacia atrás (-Y) como monolito asentado
    lean = 0.05 * (1.0 - t)
    verts = []
    for k, (ex, ey) in enumerate(esquinas):
        x = ex * erosion_x * ruido_z[i][k]
        y = ey * erosion_y * ruido_z[i][k] - lean * PROF
        verts.append(bm.verts.new((x, y, z)))
    anillos.append(verts)

# caras laterales (entre anillos)
LADOS = 4
for i in range(SEG_Z):
    for k in range(LADOS):
        k2 = (k + 1) % LADOS
        bm.faces.new((anillos[i][k], anillos[i][k2],
                      anillos[i + 1][k2], anillos[i + 1][k]))

# tapas: inferior y superior
for anillo, invertir in ((anillos[0], True), (anillos[-1], False)):
    centro = bm.verts.new(sum((v.co for v in anillo), Vector()) / LADOS)
    for k in range(LADOS):
        k2 = (k + 1) % LADOS
        if invertir:
            bm.faces.new((centro, anillo[k2], anillo[k]))
        else:
            bm.faces.new((centro, anillo[k], anillo[k2]))

bm.normal_update()
me = bpy.data.meshes.new('SM_Monolito_Cuerpo')
bm.to_mesh(me)

mono = bpy.data.objects.new('SM_Monolito_Cuerpo', me)
escena.collection.objects.link(mono)
mono.data.materials.append(MAT_piedra)
mono.location = (0.0, 0.0, 0.0)

# shade flat
bpy.ops.object.select_all(action='DESELECT')
mono.select_set(True)
bpy.context.view_layer.objects.active = mono
bpy.ops.object.shade_flat()

# AHORA SÍ liberar el bmesh (E-15: nada de tocar bm.verts después de free)
bm.free()

# ---------- 5) Glifos en la cara frontal (+Y), parentados al monolito (E-11) ----------
# La coordenada Y de la cara +Y para una altura z dada se calcula ANALÍTICAMENTE
# con la misma fórmula usada para generar los vértices (no se puede leer el
# bmesh después de bm.free(): E-15 "BMesh data of type BMVert has been removed").
def y_cara_en_z(z):
    t = z / ALTURA
    erosion_y = 1.0 - 0.04 * max(0.0, 0.30 - t) / 0.30
    lean = 0.05 * (1.0 - t)
    return (PROF / 2.0) * erosion_y - lean * PROF

# 3 glifos tallados en relieve (placas finas)
GLIFO_W = 0.18
GLIFO_H = 0.13
GLIFO_E = 0.025   # espesor del relieve
# 3 alturas (t) y 3 anchos de "línea" (1=corto, 2=medio, 3=largo)
glifos = [
    # (z_center, ancho_celdas, alto_celdas, patron: lista de celdas)
    (0.40, 3, 2, [(0,0),(1,0),(2,0),(0,1)]),  # L tumbado
    (0.78, 3, 2, [(0,0),(0,1),(1,1),(2,1)]),  # L espejado
    (1.18, 3, 3, [(0,0),(2,0),(1,1),(0,2),(2,2)]),  # X / cruz
    (1.55, 2, 2, [(0,0),(1,0),(0,1),(1,1)]),  # cuadrado
]

rng_glifo = random.Random(13)

for (zc, ncx, ncy, patron) in glifos:
    cell_w = GLIFO_W / ncx
    cell_h = GLIFO_H / ncy
    for (cx, cy) in patron:
        # centro de la celda
        x_local = -GLIFO_W / 2 + (cx + 0.5) * cell_w
        z_local = zc - GLIFO_H / 2 + (ncy - 1 - cy + 0.5) * cell_h
        # la Y de la cara depende de z (el monolito se inclina): calcularla ahí
        y_local = y_cara_en_z(z_local) + GLIFO_E / 2  # adelante de la cara
        # añadir jitter
        x_local += rng_glifo.uniform(-0.005, 0.005)
        z_local += rng_glifo.uniform(-0.005, 0.005)
        # pequeña caja como celda del glifo
        bpy.ops.mesh.primitive_cube_add(size=1.0,
                                         location=(x_local, y_local, z_local))
        celda = bpy.context.object
        celda.name = 'SM_Glifo'
        celda.scale = (cell_w * 0.9, GLIFO_E, cell_h * 0.9)
        # biselar ligeramente con subdivision surface? no, lo dejamos lowpoly
        celda.data.materials.append(MAT_glifo)
        # parentar al monolito con matrix_parent_inverse identidad (E-11)
        celda.parent = mono
        celda.matrix_parent_inverse = mono.matrix_world.inverted()

# ---------- 6) Piedra rota apoyada al costado ----------
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.16,
                                       location=(0.55, 0.05, 0.10))
roto = bpy.context.object
roto.name = 'SM_Monolito_Roto'
roto.scale = (1.0, 0.8, 0.7)
roto.data.materials.append(MAT_piedra)
bpy.ops.object.select_all(action='DESELECT')
roto.select_set(True)
bpy.context.view_layer.objects.active = roto
bpy.ops.object.shade_flat()

# ---------- 7) Asentado en la base (E-12) ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Monolito')]
# también incluimos los glifos (que ya están parentados, se asientan con el cuerpo)
piezas += [o for o in escena.objects
           if o.type == 'MESH' and o.name.startswith('SM_Glifo')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    o.location.z += delta
print('MONOLITO asento: z_min %.3f -> %.3f (delta %+.3f, n=%d)' % (z_min, Z_APOYO, delta, len(piezas)))

# ---------- 8) Iluminación + mundo ----------
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

# ---------- 9) Cámara (mirando la cara frontal) ----------
bpy.ops.object.camera_add(location=(2.4, 2.4, 1.2))
cam = bpy.context.object
cam.name = 'CAM_Monolito'
# blanco de la mira: centro del monolito (altura media)
blanco = Vector((0.0, 0.0, ALTURA * 0.55))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 10) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '45-Arte3D',
                          'monolito_glifos_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('MONOLITO GLIFOS OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
