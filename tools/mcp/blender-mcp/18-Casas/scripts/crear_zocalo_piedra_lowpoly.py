# crear_zocalo_piedra_lowpoly.py — Zocalo / fundamento de piedra (M18-Casas)
# Checklist: "Zocalo/fundamento de piedra"
#
# Cimiento cuadrado de 1x1 celda sobre el que el jugador apoya una casa.
# Compuesto por 4 bloques perimetrales (anillo) de piedra, que dejan un hueco
# interior de 0.84 x 0.84 m para el suelo de la casa. z_min 0.045 (E-12).
#
# Material: piedra gris con juntas visibles (color ligeramente mas oscuro en
# los bordes para sugerir mortero).
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

MAT_piedra     = crear_mat('MAT_Zocalo_Piedra',     (0.62, 0.60, 0.56), rough=0.95)
MAT_piedra_jnt = crear_mat('MAT_Zocalo_PiedraJunta',(0.42, 0.40, 0.36), rough=0.95)
MAT_arena      = crear_mat('MAT_Arena_Isla',         (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Dimensiones del modulo ----------
Z_APOYO  = 0.045
ANCHO    = 1.00           # X — ancho total (1 celda)
PROFUNDO = 1.00           # Y
ALTO     = 0.30           # Z — alto del cimiento

GROSOR   = 0.08           # grosor de cada pared perimetral
LUZ_INT  = ANCHO - 2 * GROSOR      # 0.84 — hueco interior en X
LUZ_INT_Y = PROFUNDO - 2 * GROSOR   # 0.84 — hueco interior en Y

# Aserto geometrico: el hueco interior es positivo y cuadrado
assert LUZ_INT > 0 and abs(LUZ_INT - LUZ_INT_Y) < 1e-6, \
    'luz interior %.3f x %.3f no es cuadrado positivo' % (LUZ_INT, LUZ_INT_Y)

# Cada pared perimetral:
# Norte/Sur: ancho 1.00 en X, grosor 0.08 en Y, alto 0.30 en Z
# Este/Oeste: grosor 0.08 en X, ancho 0.84 en Y, alto 0.30 en Z

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

Z_CEN = Z_APOYO + ALTO / 2
# Z_CEN para las esquinas: tienen ALTO + 0.02 de alto extra (sobresalen 2 cm por
# arriba), pero comparten z_min = 0.045 con las paredes. Por eso su Z_CEN es
# 0.01 mas alto que el de las paredes.
Z_CEN_ESQ = Z_APOYO + (ALTO + 0.02) / 2
piezas = []
# Pared norte (Y > 0): ancho completo en X, pegada al borde norte
piezas.append(caja('SM_Zocalo_Pared_N', MAT_piedra,
                   ANCHO, GROSOR, ALTO, 0.0,
                   PROFUNDO / 2 - GROSOR / 2, Z_CEN))
# Pared sur (Y < 0): simetrica
piezas.append(caja('SM_Zocalo_Pared_S', MAT_piedra,
                   ANCHO, GROSOR, ALTO, 0.0,
                   -PROFUNDO / 2 + GROSOR / 2, Z_CEN))
# Pared este (X > 0): solo ocupa la luz interior en Y (entre las otras 2 paredes)
piezas.append(caja('SM_Zocalo_Pared_E', MAT_piedra,
                   GROSOR, LUZ_INT_Y, ALTO,
                   ANCHO / 2 - GROSOR / 2, 0.0, Z_CEN))
# Pared oeste (X < 0): simetrica
piezas.append(caja('SM_Zocalo_Pared_W', MAT_piedra,
                   GROSOR, LUZ_INT_Y, ALTO,
                   -ANCHO / 2 + GROSOR / 2, 0.0, Z_CEN))
# 4 bloques esquina (mas oscuros) que tapan los empalmes y daran lectura de juntas
# Esquina NE, NO, SE, SO — alto +2cm para que asomen por encima del anillo
for sx, sy in ((+1, +1), (-1, +1), (+1, -1), (-1, -1)):
    piezas.append(caja('SM_Zocalo_Esquina_%s%s' % (
                       'I' if sx < 0 else 'D', 'F' if sy < 0 else 'T'),
                       MAT_piedra_jnt,
                       GROSOR, GROSOR, ALTO + 0.02,
                       sx * (ANCHO / 2 - GROSOR / 2),
                       sy * (PROFUNDO / 2 - GROSOR / 2),
                       Z_CEN_ESQ))

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
print('ZOCALO asentado: z_min %.4f -> %.4f (delta %+.4f, n=%d)' %
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

# ---------- 8) Camara (cimiento bajo: vista 3/4) ----------
bpy.ops.object.camera_add(location=(1.90, -2.20, 1.10))
cam = bpy.context.object
cam.name = 'CAM_Zocalo'
blanco = Vector((0.0, 0.0, 0.20))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 38
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '18-Casas',
                          'zocalo_piedra_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')   # E-21
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('ZOCALO DE PIEDRA OK — SM_: %d — blend: %s' %
      (len([o for o in bpy.data.objects if o.name.startswith('SM_')]), ruta_blend))