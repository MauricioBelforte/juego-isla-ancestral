# crear_ventana_marco_lowpoly.py — Ventana con marco (M18-Casas)
# Checklist: "Ventana con marco"
#
# Ventana standalone que el jugador coloca en un hueco de pared. Se muestra
# cerrada, con marco (jambas + dintel + repisa) y 2 hojas de vidrio (hoja
# izquierda y derecha) con sus travesanos verticales. Sobre la arena
# (z_min 0.045, E-12).
#
# Composicion: 1 repisa + 2 jambas + 1 dintel + 1 travesano central (parteluz)
# + 2 cristales + 2 manijas. Total 10 piezas.
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
def crear_mat(nombre, color, rough=0.85, spec=0.12, metal=0.0, alpha=1.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    if alpha < 1.0:
        m.blend_method = 'BLEND'
        bsdf.inputs['Alpha'].default_value = alpha
    return m

MAT_marco     = crear_mat('MAT_Ventana_Marco',     (0.44, 0.30, 0.18), rough=0.86)
MAT_marco_cl  = crear_mat('MAT_Ventana_MarcoClaro',(0.58, 0.42, 0.26), rough=0.88)
MAT_cristal   = crear_mat('MAT_Ventana_Cristal',   (0.70, 0.85, 0.92), rough=0.10,
                          spec=0.90, alpha=0.55)
MAT_hierro    = crear_mat('MAT_Ventana_Hierro',    (0.30, 0.28, 0.26), rough=0.45, metal=0.85)
MAT_arena     = crear_mat('MAT_Arena_Isla',        (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.2, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Dimensiones del modulo ----------
Z_APOYO = 0.045
ANCHO   = 1.00       # X — ancho total del modulo (1 celda)
ESPESOR = 0.10       # Y — grosor del marco
ALTO    = 1.10       # Z — alto total de la ventana

Z_BASE = Z_APOYO
Z_TOP = Z_BASE + ALTO           # 1.145
Z_CEN = (Z_BASE + Z_TOP) / 2    # 0.595

# Hueco (abertura interior de la ventana)
HUECO_ANCHO = 0.80              # X — ancho del hueco
HUECO_ALTO = 0.80               # Z — alto del hueco
HUECO_Z_INF = 0.16              # Z — repisa inferior (16 cm del suelo)
HUECO_Z_SUP = HUECO_Z_INF + HUECO_ALTO   # 0.96

# Marco
MARCO_GROSOR = 0.05             # ancho de las jambas y el dintel
DINTEL_ALTO = 0.08              # alto del dintel superior
REPISA_ALTO = 0.06              # alto de la repisa inferior

# Parteluz (travesano vertical central que divide las 2 hojas)
PARTELUZ_ANCHO = 0.03

# Cristales
CRISTAL_ESP = 0.02              # grosor del vidrio (en Y)
CRISTAL_ANCHO = (HUECO_ANCHO - PARTELUZ_ANCHO) / 2.0   # 0.385 cada hoja
CRISTAL_ALTO = HUECO_ALTO       # 0.80

# Aserto geometrico: las 2 hojas + parteluz cierran el ancho del hueco
assert abs(CRISTAL_ANCHO * 2 + PARTELUZ_ANCHO - HUECO_ANCHO) < 1e-6, \
    'cristales + parteluz != hueco'
assert HUECO_Z_SUP + DINTEL_ALTO <= ALTO, 'dintel se sale del alto de la ventana'

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
# Repisa inferior (0.16 cm del suelo)
piezas.append(caja('SM_Ventana_Repisa', MAT_marco,
                   ANCHO, ESPESOR, REPISA_ALTO, 0.0, 0.0,
                   Z_BASE + REPISA_ALTO / 2))
# 2 jambas laterales
JAMBA_X = ANCHO / 2 - MARCO_GROSOR / 2          # 0.475
piezas.append(caja('SM_Ventana_Jamba_I', MAT_marco,
                   MARCO_GROSOR, ESPESOR, ALTO, -JAMBA_X, 0.0, Z_CEN))
piezas.append(caja('SM_Ventana_Jamba_D', MAT_marco,
                   MARCO_GROSOR, ESPESOR, ALTO, +JAMBA_X, 0.0, Z_CEN))
# Dintel superior
DINTEL_Z = HUECO_Z_SUP + DINTEL_ALTO / 2        # 1.00
piezas.append(caja('SM_Ventana_Dintel', MAT_marco_cl,
                   ANCHO, ESPESOR + 0.02, DINTEL_ALTO, 0.0, 0.0, DINTEL_Z))
# Parteluz (travesano vertical central)
piezas.append(caja('SM_Ventana_Parteluz', MAT_marco_cl,
                   PARTELUZ_ANCHO, ESPESOR, HUECO_ALTO, 0.0, 0.0,
                   HUECO_Z_INF + HUECO_ALTO / 2))
# 2 cristales (hojas izquierda y derecha)
for i, signo in enumerate((-1, +1)):
    cx = signo * (PARTELUZ_ANCHO + CRISTAL_ANCHO) / 2.0   # +-0.2075
    piezas.append(caja('SM_Ventana_Cristal_%d' % (i + 1), MAT_cristal,
                       CRISTAL_ANCHO, CRISTAL_ESP, CRISTAL_ALTO,
                       cx, 0.0, HUECO_Z_INF + HUECO_ALTO / 2))
# 2 manijas (una por hoja, en el borde interior, a 0.5 m de altura)
MANIJA_ALTO = 0.08
MANIJA_ANCHO = 0.04
MANIJA_PROT = 0.02              # sobresale 2 cm hacia +Y (hacia el espectador)
for i, signo in enumerate((-1, +1)):
    cx = signo * (PARTELUZ_ANCHO / 2 + MANIJA_ANCHO / 2)   # +-0.035
    piezas.append(caja('SM_Ventana_Manija_%d' % (i + 1), MAT_hierro,
                       MANIJA_ANCHO, MANIJA_PROT, MANIJA_ALTO,
                       cx, ESPESOR / 2 + MANIJA_PROT / 2, 0.50))

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
print('VENTANA CON MARCO asentada: z_min %.4f -> %.4f (delta %+.4f, n=%d)' %
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

# ---------- 8) Camara (ventana baja y ancha: angulo 3/4) ----------
bpy.ops.object.camera_add(location=(1.80, -1.90, 1.00))
cam = bpy.context.object
cam.name = 'CAM_Ventana'
blanco = Vector((0.0, 0.0, 0.60))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 38
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '18-Casas',
                          'ventana_marco_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')   # E-21
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('VENTANA CON MARCO OK — SM_: %d — blend: %s' %
      (len([o for o in bpy.data.objects if o.name.startswith('SM_')]), ruta_blend))