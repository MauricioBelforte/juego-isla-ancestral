# crear_palmera_inclinada_lowpoly.py — Palmera inclinada (M50-Vegetacion)
# Checklist: "Palmera inclinada (variante de inclinación fuerte, playas)"
# Variante de la palmera común con curvatura mucho más marcada y mayor
# inclinación final. Tronco más recto al inicio y doblado en la mitad.
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

# ---------- 2) Materiales (paleta común) ----------
def crear_mat(nombre, color, rough=0.9, spec=0.08):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    return m

MAT_tronco  = crear_mat('MAT_Tronco_PalmeraIncl', (0.43, 0.30, 0.18), rough=0.95)
MAT_hoja    = crear_mat('MAT_Hoja_PalmeraIncl',   (0.10, 0.40, 0.15), rough=0.85)
MAT_coco    = crear_mat('MAT_Coco_PalmeraIncl',   (0.27, 0.16, 0.07), rough=0.90)
MAT_corazon = crear_mat('MAT_Corazon_PalmeraIncl',(0.35, 0.45, 0.15), rough=0.90)
MAT_arena   = crear_mat('MAT_Arena_Isla',         (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=28, radius=2.7, depth=0.3,
                                    location=(0, 0, -0.15))
suelo = bpy.context.object
suelo.name = 'Base_Arena'
suelo.data.materials.append(MAT_arena)

# ---------- 4) Tronco: UNA sola malla bmesh, inclinación marcada (E-01) ----------
# La curvatura es cubic-bezier: x = 0 hasta t=0.3, luego x = CURVA * (t-0.3)^1.3
SEG_L, LADOS = 11, 7
CURVA = 1.55
ALTURA = 3.6

bm = bmesh.new()
anillos = []
for i in range(SEG_L + 1):
    t = i / SEG_L
    # base vertical, luego dobla fuerte
    if t < 0.30:
        x = 0.05 * t
    else:
        tt = (t - 0.30) / 0.70
        x = 0.05 * 0.30 + CURVA * (tt ** 1.3)
    z = 0.08 + t * ALTURA
    r = 0.30 - 0.13 * t
    anillos.append([bm.verts.new((x + r * cos(2 * pi * k / LADOS),
                                  r * sin(2 * pi * k / LADOS), z))
                    for k in range(LADOS)])
for i in range(SEG_L):
    for k in range(LADOS):
        bm.faces.new([anillos[i][k], anillos[i][(k + 1) % LADOS],
                      anillos[i + 1][(k + 1) % LADOS], anillos[i + 1][k]])
bm.faces.new(anillos[0][::-1])
bm.faces.new(anillos[-1])
me = bpy.data.meshes.new('M_Tronco_Inclinado')
bm.to_mesh(me); bm.free()
tronco = bpy.data.objects.new('SM_Tronco_Inclinado', me)
escena.collection.objects.link(tronco)
tronco.data.materials.append(MAT_tronco)

# ---------- 4b) Autocorreccion de apoyo del TRONCO (E-12) ----------
bpy.context.view_layer.update()
z_min = min((tronco.matrix_world @ Vector(c)).z for c in tronco.bound_box)
delta = 0.045 - z_min
tronco.location.z += delta
bpy.context.view_layer.update()
print('TRONCO asento: z_min %.3f -> 0.045 (delta %+.3f)' % (z_min, delta))

# Punto final de la corona (calculado igual que el último anillo)
t_end = 1.0
if t_end < 0.30:
    top_x = 0.05 * t_end
else:
    tt = (t_end - 0.30) / 0.70
    top_x = 0.05 * 0.30 + CURVA * (tt ** 1.3)
top_z = 0.08 + ALTURA + 0.12

# ---------- 5) Corona ----------
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.28,
                                      location=(top_x, 0, top_z))
cora = bpy.context.object
cora.name = 'SM_Corona_Incl'
cora.scale = (1.0, 1.0, 0.7)
cora.data.materials.append(MAT_corazon)

# ---------- 6) Frondas: 7, pero la mitad "cuelgan" hacia el lado de inclinación ----------
def crear_fronda(idx, yaw_deg, pitch_deg, length_factor=1.0):
    bm = bmesh.new()
    N = 6
    largo = (2.5 + (0.25 if idx % 2 else 0.0)) * length_factor
    filas = []
    for j in range(N + 1):
        s = j / N
        x = s * largo
        if s <= 0.0 or s >= 1.0:
            w = 0.03
        else:
            w = 0.38 * (sin(pi * s) ** 0.6)
        # caída más fuerte en frondas del lado de la inclinación
        z = 0.55 - 0.10 * s - 1.30 * (s ** 2) - 0.55 * (s ** 1.5) * (idx % 2)
        filas.append((bm.verts.new((x, -w, z)), bm.verts.new((x, w, z))))
    for j in range(N):
        a1, b1 = filas[j]
        a2, b2 = filas[j + 1]
        bm.faces.new((a1, b1, b2, a2))
    me = bpy.data.meshes.new('m_fronda_incl_%02d' % idx)
    bm.to_mesh(me); bm.free()
    ob = bpy.data.objects.new('SM_Fronda_Incl_%02d' % idx, me)
    escena.collection.objects.link(ob)
    ob.rotation_euler = Euler((0.0, radians(pitch_deg), radians(yaw_deg)), 'XYZ')
    ob.location = (top_x, 0.0, top_z - 0.05)
    ob.data.materials.append(MAT_hoja)
    return ob

K = 7
for i in range(K):
    yaw = i * (360.0 / K) + (8.0 if i % 2 else -5.0)
    pitch = 6.0 + (i % 3) * 5.0
    # Las frondas 0,2,4,6 (las del lado de inclinación) más largas y caídas
    lf = 1.05 if i % 2 == 0 else 0.92
    crear_fronda(i, yaw, pitch, length_factor=lf)

# ---------- 7) Cocos (1-2, no 3, para acentuar la silueta) ----------
for k, (dx, dy) in enumerate([(0.24, 0.10), (-0.10, 0.22)]):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.16,
        location=(top_x + dx, dy, top_z - 0.32))
    coco = bpy.context.object
    coco.name = 'SM_Coco_Incl_%d' % k
    coco.data.materials.append(MAT_coco)

# ---------- 8) Iluminación + mundo + cámara (E-03 / §7) ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.8
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((radians(48), radians(6), radians(28)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

bpy.ops.object.camera_add(location=(7.2, -8.5, 3.0))
cam = bpy.context.object
cam.name = 'CAM_PalmeraIncl'
# Apuntar a un punto intermedio del tronco inclinado (curvatura visible)
dir_mira = Vector((0.8, 0.0, 1.6)) - cam.location
cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
escena.camera = cam

# ---------- 9) Flat shading ----------
for ob in escena.objects: ob.select_set(True)
bpy.context.view_layer.objects.active = tronco
bpy.ops.object.shade_flat()

# ---------- 10) Guardar .blend (E-04) ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'palmera_inclinada_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('PALMERA INCLINADA OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
