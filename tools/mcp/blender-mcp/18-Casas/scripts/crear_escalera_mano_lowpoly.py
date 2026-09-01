# crear_escalera_mano_lowpoly.py — Escalera de mano (M18-Casas)
# Checklist: "Escalera de mano"
#
# Escalera de mano recta (no A-frame) de madera, pensada para colocarla apoyada
# contra una pared o un arbol. No es un modulo del grid 1x1: es mobiliario,
# mas estrecha (0.40 m) y de 1.80 m de alto. Sobre la arena (z_min 0.045, E-12).
#
# Composicion: 2 largueros verticales (rieles) + 5 peldanos (travesanos
# horizontales). Total 7 piezas, 84 tris, 2 mats.
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

MAT_larguero = crear_mat('MAT_Escalera_Larguero', (0.46, 0.32, 0.18), rough=0.88)
MAT_peldano  = crear_mat('MAT_Escalera_Peldano',  (0.58, 0.42, 0.24), rough=0.86)
MAT_arena    = crear_mat('MAT_Arena_Isla',       (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Dimensiones del modulo ----------
Z_APOYO = 0.045
ANCHO   = 0.40       # X — ancho entre los dos largueros
ALTO    = 1.80       # Z — alto total
ESC     = 0.04       # seccion cuadrada del larguero y peldano

LARGUERO_X = ANCHO / 2.0     # 0.20 — cada larguero en x = +-0.20
PELDANO_ZS = (0.20, 0.50, 0.85, 1.20, 1.55)    # Z de cada peldano
assert len(PELDANO_ZS) == 5
# Aserto: peldano superior a 1.55 + media seccion (0.02) = 1.57 <= ALTO 1.80
assert PELDANO_ZS[-1] + ESC / 2.0 <= ALTO, \
    'peldano sup %.3f se sale del alto %.2f' % (PELDANO_ZS[-1] + ESC/2.0, ALTO)

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
# 2 largueros verticales: x = +-0.20, van del suelo al tope
piezas.append(caja('SM_Escalera_Larguero_I', MAT_larguero,
                   ESC, ESC, ALTO, -LARGUERO_X, 0.0, Z_APOYO + ALTO / 2))
piezas.append(caja('SM_Escalera_Larguero_D', MAT_larguero,
                   ESC, ESC, ALTO, +LARGUERO_X, 0.0, Z_APOYO + ALTO / 2))
# 5 peldanos horizontales que conectan los largueros
for i, zc in enumerate(PELDANO_ZS):
    piezas.append(caja('SM_Escalera_Peldano_%d' % (i + 1), MAT_peldano,
                       ANCHO, ESC, ESC, 0.0, 0.0, zc))

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
print('ESCALERA asentada: z_min %.4f -> %.4f (delta %+.4f, n=%d)' %
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

# ---------- 8) Camara (escalera alta y estrecha) ----------
bpy.ops.object.camera_add(location=(2.00, -1.80, 1.30))
cam = bpy.context.object
cam.name = 'CAM_Escalera'
blanco = Vector((0.0, 0.0, 0.95))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 38
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '18-Casas',
                          'escalera_mano_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')   # E-21
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('ESCALERA DE MANO OK — SM_: %d — blend: %s' %
      (len([o for o in bpy.data.objects if o.name.startswith('SM_')]), ruta_blend))