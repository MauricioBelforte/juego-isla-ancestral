# crear_musgo_roca_lowpoly.py — Placa decorativa de musgo sobre roca (M50-Vegetacion) — Tier F
# Checklist: "Musgo en roca (placa decorativa)"
#
# Composicion: una roca baja achatada (ovoide) parcialmente enterrada con 8
# mechones de musgo verde en la superficie superior. Pieza decorativa de
# detalle: NO es un asset interactuable, es el tipo de cosa que se pega al
# borde de un camino, debajo de un tronco o en la base de una pared para
# romper la monotonía del suelo.
#
# Regla de oro (aprendida del bug del arbol frutal, ver §9): toda pieza que
# toque el suelo arranca con z_min exactamente en 0 para que el re-asentado las
# levante parejo. Cualquier rotacion que hunda una pieza bajo 0 hace que el
# delta se mida contra ESA pieza y deja flotando al resto.
import bpy
import os
from math import radians, cos, sin, pi, atan2
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

MAT_roca    = crear_mat('MAT_MusgoRoca_Piedra',  (0.46, 0.43, 0.39), rough=0.95)
MAT_musgo1  = crear_mat('MAT_MusgoRoca_Verde',   (0.22, 0.52, 0.18), rough=0.90)
MAT_musgo2  = crear_mat('MAT_MusgoRoca_VerdeOs', (0.18, 0.40, 0.14), rough=0.90)
MAT_musgo3  = crear_mat('MAT_MusgoRoca_Claro',   (0.36, 0.62, 0.22), rough=0.90)
MAT_arena   = crear_mat('MAT_Arena_Isla',        (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.22,
                                    location=(0, 0, -0.11))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Roca: losa de piedra baja ----------
# Version 1 era una ico-esfera achatada: solo el polo sur tocaba el suelo y el
# assert E-50 la rechazo (1 vertice, footprint 0x0). El cilindro bajo tiene
# 12 vertices en la base -> huella solida garantizada, y ademas su silueta de
# "losa de piedra" encaja con el descriptor "placa decorativa".
ROCA_R = 0.50
ROCA_H = 0.35
bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=ROCA_R, depth=ROCA_H,
                                    location=(0, 0, ROCA_H / 2))
roca = bpy.context.object
roca.name = 'SM_MusgoRoca_Piedra'
roca.data.materials.append(MAT_roca)

# Tope de la losa (donde iran los mechones)
TOP_LOSA = ROCA_H                              # 0.35

# Pequeño ruido en los vertices SUPERIORES para que la losa no se vea como un
# cilindro perfecto de fabrica. Los inferiores NO se tocan: queremos la huella
# limpia.
import random
random.seed(7)
bpy.context.view_layer.update()
for v in roca.data.vertices:
    co = v.co
    if co.z > ROCA_H / 2 - 0.001:              # solo los de arriba
        ang = atan2(co.y, co.x)
        dr = (random.random() - 0.5) * 0.06
        v.co.x += cos(ang) * dr
        v.co.y += sin(ang) * dr
        v.co.z += (random.random() - 0.5) * 0.04
roca.data.update()

# ---------- 5) 8 mechones de musgo sobre la losa ----------
# Cada uno es una ico-esfera chiquita con escala Y/Z aplanada para que se lea
# como una mata, no como una pelota.
MECHON_R = 0.13
MECHON_SCALE_YZ = 0.55

# (x, y, mat_idx) — radio menor cerca del centro para que algunos mechones
# queden apiñados sobre la roca y no en el borde.
mechones = [
    # centro
    ( 0.00,  0.00, MAT_musgo2),
    ( 0.08, -0.05, MAT_musgo3),
    # anillo medio
    ( 0.32,  0.10, MAT_musgo1),
    (-0.28,  0.18, MAT_musgo2),
    ( 0.18, -0.30, MAT_musgo1),
    (-0.20, -0.22, MAT_musgo3),
    # borde (un poco mas afuera, mas chicos para que no se vea la base)
    ( 0.42, -0.22, MAT_musgo1),
    (-0.38,  0.32, MAT_musgo2),
]
for i, (x, y, mat) in enumerate(mechones):
    # posicion sobre la tapa de la roca (proyeccion simple, asumiendo roca
    # casi plana arriba): z = tapa, ajustada a la curvatura de la ico-esfera.
    r_xy = (x * x + y * y) ** 0.5
    # factor de curvatura de la ico-esfera: altura sobre la tapa a distancia r
    # ~= sqrt(R^2 - r^2) pero escalada por SZ. Aproximacion lineal OK a esta
    # escala.
    h = TOP_LOSA + (r_xy * -0.10)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=MECHON_R,
                                          location=(x, y, h))
    m = bpy.context.object
    m.name = 'SM_MusgoRoca_Mechon_%d' % i
    m.scale = (1.0, MECHON_SCALE_YZ, MECHON_SCALE_YZ)
    bpy.context.view_layer.update()
    bpy.ops.object.select_all(action='DESELECT')
    m.select_set(True)
    bpy.context.view_layer.objects.active = m
    bpy.ops.object.transform_apply(scale=True)
    m.data.materials.append(mat)

# ---------- 6) Iluminacion + mundo ----------
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

# ---------- 7) Asentado (E-12 + E-24) + huella E-50 ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()

def zmin_real(o):
    if len(o.data.vertices) == 0:
        return min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
    return min((o.matrix_world @ v.co).z for v in o.data.vertices)

piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_')]
z_ini = min(zmin_real(o) for o in piezas)
delta = Z_APOYO - z_ini
for o in piezas:
    if o.parent is None:
        o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(zmin_real(o) for o in piezas)
print('ASENTADO: z_min %.4f -> %.4f (delta %+.4f)' % (z_ini, z_fin, delta))

assert abs(z_fin - Z_APOYO) < 1e-4, 'z_min %.4f != Z_APOYO %.4f' % (z_fin, Z_APOYO)

# E-50: huella con area, no apoyo puntual. Una mata decorativa en punta de
# piedra flotante NO se aprueba.
TOL = 0.005
pts = []
for o in piezas:
    for v in o.data.vertices:
        w = o.matrix_world @ v.co
        if abs(w.z - Z_APOYO) < TOL:
            pts.append(w)
xs = [p.x for p in pts]
ys = [p.y for p in pts]
fp_x = max(xs) - min(xs) if xs else 0.0
fp_y = max(ys) - min(ys) if ys else 0.0
print('HUELLA: toca=%d  footprint=%.2f x %.2f' % (len(pts), fp_x, fp_y))
assert len(pts) >= 8, 'apoyo puntual: solo %d verts tocan (E-50)' % len(pts)
assert min(fp_x, fp_y) > 0.30, \
    'huella demasiada chica %.2fx%.2f (E-50)' % (fp_x, fp_y)

# ---------- 8) Camara ----------
bpy.ops.object.camera_add(location=(1.8, -2.2, 1.1))
cam = bpy.context.object
cam.name = 'CAM_MusgoRoca'
cam.rotation_euler = (Vector((0, 0, 0.15)) - cam.location).to_track_quat('-Z', 'Y').to_euler()
escena.camera = cam

# ---------- 9) Flat shading ----------
for ob in escena.objects:
    ob.select_set(True)
bpy.context.view_layer.objects.active = roca
bpy.ops.object.shade_flat()

# ---------- 10) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'musgo_roca_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
# E-21
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_sm = len([o for o in bpy.data.objects if o.name.startswith('SM_')])
print('MUSGO ROCA OK — SM_: %d — blend: %s' % (n_sm, ruta_blend))