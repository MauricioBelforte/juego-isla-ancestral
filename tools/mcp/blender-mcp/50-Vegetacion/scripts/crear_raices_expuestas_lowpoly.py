# crear_raices_expuestas_lowpoly.py — Raices expuestas para bordes de terreno (M50) — Tier F
# Checklist: "Raices expuestas (para bordes de terreno)"
#
# DECISION DE DISENO:
#   Las raices expuestas son el tipo de asset que va pegado al borde de un
#   barranco o de una meseta: la mitad enterrada en la tierra que se fue, la
#   mitad al aire como garras. No modelamos la tierra que se fue (el scenography
#   del terreno se hace aparte); modelamos la PARTE DE LA RAIZ QUE SE VE.
#   Composicion: 1 nudo central (donde estaba el tronco, ahora cortado) + 5
#   raices radiando hacia afuera en abanico, parcialmente expuestas (la base
#   hundida bajo el nivel del nudo simula que sigue habiendo tierra debajo).
#
# Regla de oro (heredada del bug del arbol frutal, ver §7): toda pieza arranca
# con su cota inferior EXACTAMENTE en z = 0 para que el re-asentado las levante
# parejo. Si una sola raiz tiene la punta hundida y el nudo elevado, el re-
# sentado las sube todas y la raiz queda colgando en el aire.
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
def crear_mat(nombre, color, rough=0.95, spec=0.08):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    return m

MAT_corteza = crear_mat('MAT_Raices_Corteza', (0.34, 0.22, 0.13), rough=0.95)
MAT_corteza2 = crear_mat('MAT_Raices_Corteza_Osc', (0.26, 0.16, 0.10), rough=0.95)
MAT_arena = crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.22,
                                    location=(0, 0, -0.11))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Nudo central: tocón cilindrico ----------
# V1 era una ico-esfera achatada: solo el polo sur tocaba y el assert E-50
# caia. Un tocón cortado es naturalmente cilíndrico, asi que cilindro bajo
# con N=10 vertices en la base -> huella ancha garantizada.
NUDO_R = 0.30
NUDO_H = 0.22
bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=NUDO_R, depth=NUDO_H,
                                    location=(0, 0, NUDO_H / 2))
nudo = bpy.context.object
nudo.name = 'SM_Raices_Nudo'
nudo.data.materials.append(MAT_corteza)

# ---------- 5) 5 raices radiando en abanico ----------
# Cada una es un cono ACOSTADO con la base ancha en el nudo y el apex hacia
# afuera. La base se entierra bajo el nudo (z negativo) para que cuando se
# re-asienta solo aflore la mitad: la sensacion de "raiz que sale de la tierra".
# Misma tecnica de acostar conos del arbol frutal (Ry 90 + Rz angulo) para
# garantizar la cota inferior por construccion.
N_RAIZ = 5
RAIZ_L = 0.85                # largo total
RAIZ_R_BASE = 0.12           # grosor en el nudo
RAIZ_D_INICIO = 0.18         # donde arranca la raiz (en el borde del nudo)
RAIZ_HUNDIMIENTO = 0.06      # cuanto se entierra la base bajo z=0

# El abanico se abre entre -90° y +90° alrededor de +Y (las raices salen "hacia
# el frente" del terreno). Inicio en 15° para que no haya raices alineadas con
# la camara por defecto.
inicio = radians(-75)
paso = radians(150) / (N_RAIZ - 1)

for i in range(N_RAIZ):
    ang = inicio + paso * i
    # centro del cono a lo largo de la direccion, levantado para que su
    # generatriz inferior quede en z = 0
    lx, ly = cos(ang) * (RAIZ_D_INICIO + RAIZ_L / 2), sin(ang) * (RAIZ_D_INICIO + RAIZ_L / 2)
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=RAIZ_R_BASE, radius2=0.0,
                                    depth=RAIZ_L, location=(lx, ly, RAIZ_R_BASE))
    r = bpy.context.object
    r.name = 'SM_Raices_Raiz_%d' % i
    # Misma rotacion que el arbol: Ry(90) acuesta el cono, Rz(ang) lo orienta.
    r.rotation_euler = (0.0, radians(90), ang)
    bpy.context.view_layer.update()
    r.data.materials.append(MAT_corteza2 if i % 2 else MAT_corteza)

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

# E-50: la huella tiene que ser con area. Las 5 raices acostadas tocan el suelo
# por una de sus generatrices (8 vertices cada una en la base del cono -> ~40).
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

# ---------- 8) Camara ----------
bpy.ops.object.camera_add(location=(2.2, -2.6, 1.3))
cam = bpy.context.object
cam.name = 'CAM_RaicesExpuestas'
cam.rotation_euler = (Vector((0, 0, 0.0)) - cam.location).to_track_quat('-Z', 'Y').to_euler()
escena.camera = cam

# ---------- 9) Flat shading ----------
for ob in escena.objects:
    ob.select_set(True)
bpy.context.view_layer.objects.active = nudo
bpy.ops.object.shade_flat()

# ---------- 10) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'raices_expuestas_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
# E-21
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_sm = len([o for o in bpy.data.objects if o.name.startswith('SM_')])
print('RAICES EXPUESTAS OK — SM_: %d — blend: %s' % (n_sm, ruta_blend))