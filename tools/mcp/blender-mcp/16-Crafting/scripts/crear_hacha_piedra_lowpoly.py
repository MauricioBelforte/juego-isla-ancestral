# crear_hacha_piedra_lowpoly.py — Hacha de piedra (M16-Crafting / M14-Inventario)
# Checklist: "Hacha de piedra"
#
# Pose: APOYADA EN LA ARENA (herramienta soltada en el suelo).
#   - Mango a lo largo de X (horizontal), desde la empuñadura (-X) hasta el ojo (+X).
#   - Cabeza con eje largo en Y (perpendicular al mango), desde el poll (-Y) hasta el filo (+Y).
#   - El filo corre PARALELO al mango (regla del hacha real: eje del filo // eje del mango).
#   - El espesor (dirección de golpe) va en Z y se afina de 0.075 en el ojo a 0.018 en el filo.
#   - Toda la pieza queda acostada: la mejilla de la cabeza apoya en la arena.
import bpy
import bmesh
import os
import math
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


# ---------- 1bis) Helper: prisma de anillos (E-01) ----------
# anillos: lista de listas de BMVert, todos con la misma cantidad de vértices,
# ordenados en el mismo sentido. Construye las caras laterales + tapas por
# abanico a un vértice central (el sentido de la tapa se invierte en el
# extremo inicial para que las normales queden hacia afuera).
def cerrar_prisma(bm, anillos):
    n = len(anillos[0])
    for i in range(len(anillos) - 1):
        for k in range(n):
            k2 = (k + 1) % n
            bm.faces.new((anillos[i][k], anillos[i][k2],
                          anillos[i + 1][k2], anillos[i + 1][k]))
    for anillo, invertir in ((anillos[0], True), (anillos[-1], False)):
        centro = bm.verts.new(sum((v.co for v in anillo), Vector()) / n)
        for k in range(n):
            k2 = (k + 1) % n
            if invertir:
                bm.faces.new((centro, anillo[k2], anillo[k]))
            else:
                bm.faces.new((centro, anillo[k], anillo[k2]))
    bm.normal_update()


# ---------- 2) Materiales ----------
def crear_mat(nombre, color, rough=0.6, spec=0.15, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    b.inputs['Metallic'].default_value = metal
    return m

MAT_madera = crear_mat('MAT_Madera_Hacha',  (0.44, 0.29, 0.17), rough=0.85)  # mango
MAT_piedra = crear_mat('MAT_Piedra_Hacha',  (0.38, 0.39, 0.41), rough=0.75)  # cabeza
MAT_cuero  = crear_mat('MAT_Cuero_Hacha',   (0.58, 0.44, 0.26), rough=0.90)  # atadura
MAT_arena  = crear_mat('MAT_Arena_Isla',    (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena (NO exportar) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.1, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Cabeza: prisma hexagonal a lo largo de Y (E-01, una sola malla) ----------
# Estaciones (y, semi-eje X = largo del filo, semi-eje Z = espesor)
ESTACIONES = [
    (-0.09, 0.045, 0.026),   # poll (culata)
    (-0.01, 0.050, 0.037),   # ojo (donde pasa el mango) — máximo espesor
    ( 0.10, 0.072, 0.030),   # garganta
    ( 0.30, 0.125, 0.009),   # filo — ancho y muy fino
]
LADOS = 6
HEAD_Z = 0.048          # plano medio de la cabeza
ANGULOS = [2 * math.pi * k / LADOS for k in range(LADOS)]

me = bpy.data.meshes.new('SM_Hacha_Cabeza')
ob = bpy.data.objects.new('SM_Hacha_Cabeza', me)
escena.collection.objects.link(ob)
bm = bmesh.new()
anillos = []
for (y, hx, hz) in ESTACIONES:
    verts = []
    for a in ANGULOS:
        verts.append(bm.verts.new((hx * math.cos(a), y, HEAD_Z + hz * math.sin(a))))
    anillos.append(verts)
cerrar_prisma(bm, anillos)
bm.to_mesh(me)
bm.free()
ob.data.materials.append(MAT_piedra)

# ---------- 5) Mango: tubo a lo largo de X (E-01, una sola malla) ----------
X_BUTT, X_EYE = -0.62, 0.02
SEG_L, LADOS_M = 10, 8
ACH_Z = 0.85            # achatado vertical: apoya mejor y parece tallado a mano
me = bpy.data.meshes.new('SM_Hacha_Mango')
ob = bpy.data.objects.new('SM_Hacha_Mango', me)
escena.collection.objects.link(ob)
bm = bmesh.new()
anillos = []
for i in range(SEG_L + 1):
    t = i / SEG_L
    x = X_BUTT + (X_EYE - X_BUTT) * t
    r = 0.040 + 0.016 * (1.0 - t) ** 1.6      # más grueso en la empuñadura
    verts = []
    for k in range(LADOS_M):
        a = 2 * math.pi * k / LADOS_M
        verts.append(bm.verts.new((x, r * 0.92 * math.cos(a),
                                   HEAD_Z + r * ACH_Z * math.sin(a))))
    anillos.append(verts)
cerrar_prisma(bm, anillos)
bm.to_mesh(me)
bm.free()
ob.data.materials.append(MAT_madera)

# ---------- 6) Pomo (remate de la empuñadura) ----------
bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=5, radius=0.052,
                                     location=(X_BUTT - 0.005, 0.0, HEAD_Z))
pomo = bpy.context.object
pomo.name = 'SM_Hacha_Pomo'
pomo.scale = (0.85, 1.0, 0.85)
pomo.data.materials.append(MAT_madera)

# ---------- 7) Atadura de cuero + 2 anillas (E-11: detalles sueltos, sin parenear
#                 porque el mango NO se rota; son piezas del grupo del hacha) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.055, depth=0.085,
                                    location=(-0.05, 0.0, HEAD_Z),
                                    rotation=(0, math.pi / 2, 0))
cuerda = bpy.context.object
cuerda.name = 'SM_Hacha_Cuerda'
cuerda.scale = (1.0, 0.88, 1.0)
cuerda.data.materials.append(MAT_cuero)

for i, x in enumerate((-0.005, -0.098)):
    bpy.ops.mesh.primitive_torus_add(major_radius=0.050, minor_radius=0.011,
                                     major_segments=10, minor_segments=5,
                                     location=(x, 0.0, HEAD_Z),
                                     rotation=(0, math.pi / 2, 0))
    anilla = bpy.context.object
    anilla.name = 'SM_Hacha_Anilla_%d' % i
    anilla.data.materials.append(MAT_cuero)

# ---------- 8) Autocorrección de apoyo (E-12): z_min del grupo a Z_APOYO ----------
Z_APOYO = 0.045          # 5 mm hundido en la arena (tope arena = 0.050)
bpy.context.view_layer.update()
piezas = [o for o in escena.objects if o.type == 'MESH' and o.name.startswith('SM_Hacha_')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    o.location.z += delta
print('HACHA asentada: z_min %.3f -> %.3f (delta %+.3f)' % (z_min, Z_APOYO, delta))

# ---------- 9) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(55), 0, math.radians(35)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 10) Cámara (cerca: el objeto mide ~0.9) ----------
bpy.ops.object.camera_add(location=(-0.95, -1.45, 0.95))
cam = bpy.context.object
cam.name = 'CAM_Hacha'
dir_mira = Vector((-0.24, 0.10, 0.06)) - cam.location
cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 11) Flat shading ----------
for o in escena.objects:
    o.select_set(True)
bpy.context.view_layer.objects.active = ob
bpy.ops.object.shade_flat()

# ---------- 12) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '16-Crafting',
                          'hacha_piedra_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('HACHA PIEDRA OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
