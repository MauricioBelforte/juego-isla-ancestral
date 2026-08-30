# crear_nido_cocos_lowpoly.py — Nido de cocos (M15-Recursos)
# Checklist: "Nido de cocos (suma de cocos)"
# Composición: montón de 7 cocos apilados sobre un lecho de hojas de palmera.
# Cada coco = icosphere subdiv 2 achatada + fibra (3 "ojos" oscuros).
import bpy
import bmesh
import os
import random
from math import radians, sin, cos, pi
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
def crear_mat(nombre, color, rough=0.8, spec=0.15, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    b.inputs['Metallic'].default_value = metal
    return m

MAT_coco    = crear_mat('MAT_Coco_Fibra',  (0.42, 0.28, 0.15), rough=0.92)
MAT_coco_b  = crear_mat('MAT_Coco_Oscuro', (0.30, 0.20, 0.10), rough=0.92)
MAT_ojo     = crear_mat('MAT_Coco_Ojos',   (0.16, 0.11, 0.07), rough=0.85)
MAT_hoja    = crear_mat('MAT_Hoja_Palmera',(0.24, 0.42, 0.16), rough=0.85)
MAT_seca    = crear_mat('MAT_Hoja_Seca',   (0.46, 0.38, 0.18), rough=0.90)
MAT_arena   = crear_mat('MAT_Arena_Isla',  (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.9, depth=0.22,
                                    location=(0, 0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Semillas aleatorias SEPARADAS ----------
# IMPORTANTE: hojas y cocos tienen RNG propio. Si compartieran la secuencia,
# cualquier cambio en las hojas alteraria la geometria de los cocos (y por
# tanto su semieje vertical), volviendo inestable el apoyo calculado.
rng_hojas = random.Random(11)
rng_cocos = random.Random(23)

# ---------- 4b) Lecho: DISCO base + anillo radial de hojas ----------
# REGLA (E-12): el elemento de apoyo debe cubrir TODA la planta de lo que
# sostiene. La version anterior usaba un abanico de 5 tiras de solo 0.14 de
# ancho cubriendo +-70 deg: 3 de los 6 cocos inferiores quedaban colgando
# sobre arena desnuda y se veian flotando al girar la camara.
# Ahora: un DISCO continuo garantiza la cobertura, y las hojas pasan a ser un
# anillo perimetral decorativo (que ademas es como se ve un nido real).
#
# Disco: radio 0.85 > radio maximo de los cocos (0.43), asi que cubre todo.
bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.85, depth=0.07,
                                    location=(0.0, 0.0, 0.055))
o = bpy.context.object
o.name = 'SM_Nido_Base'
o.rotation_euler = Euler((0.0, 0.0, radians(11)), 'XYZ')  # que no alinee con la arena
o.data.materials.append(MAT_seca)
bpy.ops.object.select_all(action='DESELECT')
o.select_set(True)
bpy.context.view_layer.objects.active = o
bpy.ops.object.shade_flat()
# Disco: z de 0.020 a 0.090. Arena: tope en 0.050 -> empotrado 3 cm.

# Anillo de 8 hojas radiales. NO llegan al centro (radio 0.305..0.855), asi que
# no se solapan entre si -> sin z-fighting. Su base (0.085) queda por debajo
# del tope del disco (0.090) -> apoyadas, sin hueco.
for i in range(8):
    ang = radians(i * 45 + 6)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.0, 0.0, 0.115))
    h = bpy.context.object
    h.name = 'SM_Hoja_Nido_%d' % i
    h.scale = (0.55, 0.30, 0.06)
    h.rotation_euler = Euler((0.0, 0.0, ang), 'XYZ')
    h.location = (0.58 * cos(ang), 0.58 * sin(ang), 0.115)
    h.data.materials.append(MAT_hoja)

# ---------- 5) Cocos ----------
R = 0.23

# posiciones: anillo inferior de 6 + 2 arriba (pirámide achatada).
# La Z de estas alturas es PROVISIONAL: al final del bloque se mide el bounding
# box real y se corre el monton entero para que apoye exactly en Z_APOYO.
posiciones = [
    # capa inferior
    (0.00,  0.00, R * 1.30),
    (0.42,  0.10, R * 1.30),
    (0.16,  0.40, R * 1.30),
    (-0.30, 0.28, R * 1.30),
    (-0.38, -0.14, R * 1.30),
    (0.10, -0.38, R * 1.30),
    # capa superior
    (0.06,  0.06, R * 2.65),
    (-0.14, -0.06, R * 2.55),
]

def crear_coco(idx, pos, radio):
    me = bpy.data.meshes.new('M_Coco_%d' % idx)
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=2, radius=radio)
    for v in bm.verts:
        v.co.z *= 0.84                       # achatado vertical
        v.co += v.normal * rng_cocos.uniform(-0.012, 0.012)  # irregular, fibroso
    bm.to_mesh(me); bm.free()
    ob = bpy.data.objects.new('SM_Coco_%d' % idx, me)
    escena.collection.objects.link(ob)
    ob.location = pos
    ob.rotation_euler = Euler((radians(rng_cocos.uniform(-14, 14)),
                               radians(rng_cocos.uniform(-14, 14)),
                               radians(rng_cocos.uniform(0, 360))), 'XYZ')
    ob.data.materials.append(MAT_coco if idx % 2 == 0 else MAT_coco_b)
    bpy.ops.object.select_all(action='DESELECT')
    ob.select_set(True)
    bpy.context.view_layer.objects.active = ob
    bpy.ops.object.shade_flat()

    # 3 "ojos" del coco (poros de germinacion) — HIJOS del coco, en coords
    # LOCALES. Antes se colocaban en coords de mundo con desplazamiento
    # radio*0.55, que queda POR DEBAJO de la superficie (semieje vertical
    # efectivo ~0.22): quedaban enterrados dentro de la malla, invisibles.
    # Con parent + matrix_parent_inverse identidad, mundo = M_coco @ local,
    # asi que siguen la rotacion del coco y se mueven con el al corregir.
    for j in range(3):
        ang = radians(120 * j + rng_cocos.uniform(-15, 15))
        bpy.ops.mesh.primitive_uv_sphere_add(segments=6, ring_count=4,
                                             radius=radio * 0.20,
                                             location=(0.0, 0.0, 0.0))
        oj = bpy.context.object
        oj.name = 'SM_CocoOjo_%d_%d' % (idx, j)
        oj.parent = ob
        oj.matrix_parent_inverse = Matrix()   # identidad -> mundo = M_coco @ local
        oj.location = (radio * 0.33 * cos(ang),
                       radio * 0.33 * sin(ang),
                       radio * 0.80)          # sobre la superficie del coco
        oj.rotation_euler = (0.0, 0.0, 0.0)
        oj.scale = (1.0, 1.0, 0.5)
        oj.data.materials.append(MAT_ojo)
    return ob

for i, p in enumerate(posiciones):
    crear_coco(i, p, R)

# ---------- 5b) Autocorreccion de apoyo (E-09 + E-12) ----------
# El semieje vertical efectivo del coco NO es calculable de forma fiable
# (ruido fibroso + rotacion aleatoria), asi que se MIDE y se corre el monton.
# Objetivo: el punto mas bajo de los cocos debe quedar EN o POR DEBAJO del tope
# de la arena (0.050), no por encima. 0.045 = 5 mm hundido en la base -> el
# monton queda asentado, nunca flotando, se mire desde donde se mire.
bpy.context.view_layer.update()
cocos = [o for o in escena.objects if o.name.startswith('SM_Coco_')]
z_min_cocos = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
                  for o in cocos)
Z_APOYO = 0.045          # 5 mm por debajo del tope de la arena (0.050)
delta = Z_APOYO - z_min_cocos
for o in cocos:
    o.location.z += delta
print('apoyo corregido: z_min %.3f -> %.3f (delta %+.3f)' % (z_min_cocos, Z_APOYO, delta))

# ---------- 6) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.4
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((radians(52), radians(6), radians(32)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 7) Cámara ----------
bpy.ops.object.camera_add(location=(2.1, -2.5, 1.55))
cam = bpy.context.object
cam.name = 'CAM_NidoCocos'
# El cluster ahora va de z=0.067 a z=0.917. Centro ~0.49; apuntar a 0.45
# con la camara mas alta y alejada para que el disco de arena no domine.
dir_mira = Vector((0.0, 0.0, 0.45)) - cam.location
cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 8) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '15-Recursos',
                          'nido_cocos_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('NIDO COCOS OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
