# crear_bote_pesca_lowpoly.py — Bote de pesca amarrado (M40-Infraestructura)
# Checklist: "Bote de pesca amarrado"
#
# Composición: pequeño bote de pesca apoyado en la arena. Construcción SIMPLE
# con cajas:
#   - Casco: caja ahusada (más ancha en el centro) acostada, con la proa
#     apuntada hacia +Y (caja pequeña) y popa cuadrada.
#   - 2 bancos (asientos) sobre el casco
#   - 1 remo apoyado en el interior
#   - Vela plegada (cubo fino) sobre los bancos
#   - Poste de amarre clavado en la arena
#   - Cabo enrollado al pie del poste
import bpy
import bmesh
import os
import random
import math
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
def crear_mat(nombre, color, rough=0.85, spec=0.1, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_madera = crear_mat('MAT_Madera_Bote',     (0.40, 0.26, 0.14), rough=0.86)
MAT_madera_osc = crear_mat('MAT_Madera_Bote_Osc', (0.28, 0.18, 0.10), rough=0.88)
MAT_tela   = crear_mat('MAT_Tela_Bote',       (0.88, 0.84, 0.74), rough=0.90)
MAT_cuerda = crear_mat('MAT_Cuerda_Bote',     (0.55, 0.40, 0.20), rough=0.92)
MAT_arena  = crear_mat('MAT_Arena_Isla',      (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Helpers ----------
def nueva_caja(nombre, cx, cy, cz, sx, sy, sz):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x = v.co.x * sx + cx
        v.co.y = v.co.y * sy + cy
        v.co.z = v.co.z * sz + cz
    bm.normal_update()
    me = bpy.data.meshes.new(nombre)
    bm.to_mesh(me)
    bm.free()
    return me

def agregar(nombre, me, material, padre=None):
    o = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(o)
    o.data.materials.append(material)
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()
    if padre is not None:
        o.parent = padre
        o.matrix_parent_inverse = Matrix()
    return o

# ---------- 5) Casco del bote ----------
# Construcción con primitivas (sin bmesh complejo) — más predecible visualmente.
# Casco como caja tumbada (largo en X, ancho en Y, alto en Z), con bordes
# achaflanados usando un cono truncado invertido (canoa).
bpy.ops.mesh.primitive_cube_add(size=1.0,
                                location=(0.0, 0.0, 0.10))
casco = bpy.context.object
casco.name = 'SM_Bote_Casco'
casco.scale = (0.85, 0.42, 0.18)
casco.data.materials.append(MAT_madera)
bpy.ops.object.select_all(action='DESELECT')
casco.select_set(True)
bpy.context.view_layer.objects.active = casco
bpy.ops.object.shade_flat()

# Proa apuntada: cono en +X.
# E-19: rotar sobre Z NO cambia el eje del cono (el cono nace a lo largo de Z),
# así que rotation_euler=(0,0,-90) lo deja apuntando ARRIBA. Para apuntarlo a +X
# hay que rotar sobre Y. Además, tras rotar sobre Y el eje local X cae en -Z
# del mundo, por lo que el factor de escala en X aplasta el cono en altura y
# logra que la sección coincida con la del casco (Y +-0.21, Z 0.10 +-0.09).
bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.21, radius2=0.0,
                                depth=0.30, location=(0.575, 0.0, 0.10))
proa = bpy.context.object
proa.name = 'SM_Bote_Proa'
proa.rotation_euler = (0.0, math.radians(90.0), 0.0)   # eje del cono -> +X
proa.scale = (0.43, 1.0, 1.0)                          # seccion Y 0.21 / Z 0.09
proa.data.materials.append(MAT_madera)
bpy.ops.object.select_all(action='DESELECT')
proa.select_set(True)
bpy.context.view_layer.objects.active = proa
bpy.ops.object.shade_flat()

# Popa: tabla vertical al final en -X
agregar('SM_Bote_Popa',
        nueva_caja('SM_Bote_Popa', -0.44, 0.0, 0.10,
                   0.04, 0.42, 0.18),
        MAT_madera_osc)

# Costillas (3): sobresalen 0.01 a cada lado en Y y 0.02 por arriba, para que
# se lean como refuerzo. El fondo queda en 0.01, igual que el fondo del casco.
for k, x in enumerate((-0.25, 0.0, 0.25)):
    agregar('SM_Bote_Costilla_%d' % (k + 1),
            nueva_caja('SM_Bote_Costilla_%d' % (k + 1), x, 0.0, 0.11,
                       0.03, 0.44, 0.20),
            MAT_madera_osc)

# ---------- 6) 2 bancos (asientos) ----------
for k, x in enumerate((-0.15, 0.18)):
    agregar('SM_Bote_Banco_%d' % (k + 1),
            nueva_caja('SM_Bote_Banco_%d' % (k + 1), x, 0.0, 0.24,
                       0.04, 0.34, 0.05),
            MAT_madera_osc)

# ---------- 7) Vela plegada (cubo fino horizontal) ----------
agregar('SM_Bote_Vela',
        nueva_caja('SM_Bote_Vela', 0.0, 0.0, 0.26,
                   0.40, 0.20, 0.04),
        MAT_tela)

# ---------- 8) Remo apoyado atravesado en el bote ----------
agregar('SM_Bote_Remo',
        nueva_caja('SM_Bote_Remo', 0.10, 0.0, 0.18,
                   0.70, 0.05, 0.03),
        MAT_madera_osc)
# Hoja del remo en un extremo
agregar('SM_Bote_RemoHoja',
        nueva_caja('SM_Bote_RemoHoja', -0.28, 0.0, 0.18,
                   0.12, 0.10, 0.02),
        MAT_madera_osc)

# ---------- 9) Poste de amarre (en la arena, junto al bote) ----------
agregar('SM_Bote_Poste',
        nueva_caja('SM_Bote_Poste', 0.80, 0.0, 0.30,
                   0.10, 0.10, 0.60),
        MAT_madera_osc)

# ---------- 10) Cabo enrollado (toroide en la base del poste) ----------
# El toro apoyado en XZ mide (major + minor) = 0.072 de mitad en Z, así que
# el centro va en 0.072 para que el punto más bajo quede en 0.000, al ras del
# poste. Antes estaba en 0.06 y el cabo se hundía 1.2 cm bajo la arena.
bpy.ops.mesh.primitive_torus_add(major_radius=0.06, minor_radius=0.012,
                                 location=(0.80, 0.0, 0.072),
                                 rotation=(math.radians(90), 0, 0),
                                 major_segments=10, minor_segments=4)
cabo = bpy.context.object
cabo.name = 'SM_Bote_Cabo'
cabo.data.materials.append(MAT_cuerda)
bpy.ops.object.select_all(action='DESELECT')
cabo.select_set(True)
bpy.context.view_layer.objects.active = cabo
bpy.ops.object.shade_flat()

# ---------- 11) Asentado (E-12) — por grupos ----------
# Se asienta por GRUPO y no pieza por pieza: el bote descansa sobre su casco
# (una sola cota para todo el conjunto) y el amarre va aparte sobre la arena.
# Asentar de a una pieza hacía que cada objeto subiera lo suyo y quedaran
# desfasados entre sí.
Z_APOYO = 0.045


def asentar_grupo(nombres, etiqueta):
    bpy.context.view_layer.update()
    obs = [escena.objects[n] for n in nombres if n in escena.objects
           and escena.objects[n].type == 'MESH']
    if not obs:
        print('%s: sin piezas' % etiqueta)
        return
    z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
                for o in obs)
    delta = Z_APOYO - z_min
    for o in obs:
        if o.parent is None:
            o.location.z += delta
    bpy.context.view_layer.update()
    z_fin = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
                for o in obs)
    print('%s asento: z_min %.3f -> %.3f (delta %+.3f, piezas=%d)'
          % (etiqueta, z_min, z_fin, delta, len(obs)))


AMARRE = ('SM_Bote_Poste', 'SM_Bote_Cabo')
asentar_grupo([o.name for o in escena.objects
               if o.name.startswith('SM_Bote_') and o.name not in AMARRE],
              'BOTE')
asentar_grupo(list(AMARRE), 'BOTE amarre')

# ---------- 12) Iluminación + mundo ----------
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

# ---------- 13) Cámara ----------
bpy.ops.object.camera_add(location=(1.6, 1.6, 0.9))
cam = bpy.context.object
cam.name = 'CAM_Bote'
blanco = Vector((0.0, 0.0, 0.20))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 14) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '40-Infraestructura',
                          'bote_pesca_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('BOTE PESCA OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
