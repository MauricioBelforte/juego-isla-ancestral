# crear_puerta_articulada_lowpoly.py — Puerta articulada (M18-Casas)
# Checklist: "Puerta articulada"
#
# Puerta standalone (sin pared adjacente) que el jugador coloca en una abertura.
# Se muestra cerrada, con la articulacion implicita por las 3 bisagras del lado
# izquierdo y la manija del lado derecho. Sobre la arena (z_min 0.045, E-12).
#
# Composicion: 1 panel + 3 tablones horizontales (cara frontal) + 3 bisagras
# (lado izquierdo, sobresalen 2 cm) + 1 manija (lado derecho, a 1 m de altura).
import bpy
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
def crear_mat(nombre, color, rough=0.85, spec=0.12, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_puerta    = crear_mat('MAT_Puerta_Madera',       (0.62, 0.46, 0.28), rough=0.88)
MAT_tablero   = crear_mat('MAT_Puerta_Tablero',      (0.50, 0.36, 0.20), rough=0.90)
MAT_hierro    = crear_mat('MAT_Puerta_Hierro',       (0.30, 0.28, 0.26), rough=0.45, metal=0.85)
MAT_arena     = crear_mat('MAT_Arena_Isla',          (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.2, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Dimensiones del modulo ----------
Z_APOYO = 0.045
ANCHO   = 0.60       # X — ancho de la puerta (abertura estandar)
ESPESOR = 0.04       # Y — grosor de la puerta
ALTO    = 2.00       # Z — alto de la puerta

Z_BASE = Z_APOYO
Z_TOP = Z_BASE + ALTO               # 2.045
Z_CEN = (Z_BASE + Z_TOP) / 2        # 1.045

# Tablones horizontales sobre la cara frontal
TAB_ESP = 0.01      # 1 cm proud (alma del tablero sobresale de la cara)
TAB_ALTO = 0.18     # altura de cada tablero
TAB_YS = (0.45, 1.00, 1.55)        # Z de cada uno (uniformes dentro del alto)

# Bisagras (lado izquierdo, sobresalen 2 cm hacia -X)
BIS_X_PROT = 0.02                  # protrusion hacia el lado izquierdo
BIS_ALTO = 0.16                    # altura de cada bisagra
BIS_ZS = (0.30, 1.00, 1.70)        # Z de cada una

# Manija (lado derecho, a 1 m de altura)
MAN_X = +ANCHO / 2 + 0.025         # 0.325 (sobresale 2.5 cm hacia la derecha)
MAN_Y = 0.0                        # centrada en Y (al ras de la cara frontal +y)
MAN_Z = 1.00                       # 1 m de altura

# Aserto geometrico
assert ANCHO > 2 * BIS_X_PROT, 'puerta demasiado estrecha para las bisagras'

# ---------- 5) Piezas ----------
def caja(nombre, mat, sx, sy, sz, cx, cy, cz):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(cx, cy, cz))
    o = bpy.context.object
    o.name = nombre
    o.scale = (sx, sy, sz)
    o.data.materials.append(mat)
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()
    return o

piezas = []
# Panel de la puerta
piezas.append(caja('SM_Puerta_Panel', MAT_puerta,
                   ANCHO, ESPESOR, ALTO, 0.0, 0.0, Z_CEN))
# 3 tablones horizontales sobre la cara frontal (Y > ESPESOR/2)
# Cada tablero se posiciona a Y = ESPESOR/2 + TAB_ESP/2 = 0.025 para que sobresalga 1 cm
for i, zc in enumerate(TAB_YS):
    piezas.append(caja('SM_Puerta_Tablero_%d' % (i + 1), MAT_tablero,
                       ANCHO, TAB_ESP, TAB_ALTO, 0.0,
                       ESPESOR / 2 + TAB_ESP / 2, zc))
# 3 bisagras en el lado izquierdo
# X: centrada en -ANCHO/2 - BIS_X_PROT/2 = -0.31
# Y: centrada en 0 (al ras del grosor de la puerta)
for i, zc in enumerate(BIS_ZS):
    piezas.append(caja('SM_Puerta_Bisagra_%d' % (i + 1), MAT_hierro,
                       BIS_X_PROT, ESPESOR, BIS_ALTO,
                       -ANCHO / 2 - BIS_X_PROT / 2, 0.0, zc))
# Manija: cubo pequeno en el lado derecho, a 1 m de altura
piezas.append(caja('SM_Puerta_Manija', MAT_hierro,
                   0.05, ESPESOR + TAB_ESP + 0.02, 0.05,
                   MAN_X, MAN_Y, MAN_Z))

# ---------- 6) Asentado (E-12) en vertices reales (E-24) ----------
def zmin_real(o):
    if len(o.data.vertices) == 0:
        return min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
    return min((o.matrix_world @ v.co).z for v in o.data.vertices)

bpy.context.view_layer.update()
z_min = min(zmin_real(o) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    o.location.z += delta
bpy.context.view_layer.update()
z_final = min(zmin_real(o) for o in piezas)
assert abs(z_final - Z_APOYO) < 1e-4, 'asentado no cierra: %.6f' % z_final
print('PUERTA ARTICULADA asentada: z_min %.4f -> %.4f (delta %+.4f, n=%d)' %
      (z_min, z_final, delta, len(piezas)))

# ---------- 7) Iluminacion + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(55), math.radians(8), math.radians(30)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 8) Camara (puerta delgada: angulo 3/4) ----------
bpy.ops.object.camera_add(location=(2.20, -2.30, 1.50))
cam = bpy.context.object
cam.name = 'CAM_Puerta'
blanco = Vector((0.0, 0.0, 1.00))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 38
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '18-Casas',
                          'puerta_articulada_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')   # E-21
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('PUERTA ARTICULADA OK — SM_: %d — blend: %s' %
      (len([o for o in bpy.data.objects if o.name.startswith('SM_')]), ruta_blend))