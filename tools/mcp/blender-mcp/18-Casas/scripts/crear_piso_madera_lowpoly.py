# crear_piso_madera_lowpoly.py — Piso de madera (M18-Casas)
# Checklist: "Piso de madera (módulo)"
#
# Misma planta 1x1 celda que las paredes (1.000 m x 1.000 m, M17 RF2), pero
# bajo de altura: 6 cm total visible. Reusa la misma familia de maderas.
#
# Composicion (sin z-fighting: las tablas se apoyan EN las vigas, no comparten
# el mismo cubo):
#   - 3 vigas longitudinales (corren en X, full 1.00 m): 0.10 x 1.00 x 0.04
#     en y = -0.45, 0.0, +0.45.  Z = [0.045..0.085].
#   - 5 tablas transversales (corren en Y, full 1.00 m): 1.00 x 0.18 x 0.02
#     en x = -0.30, -0.15, 0, +0.15, +0.30.  Z = [0.085..0.105].
#     Entre cada par de tablas queda una ranura de 0.02 m que deja ver el
#     lomo de la viga intermedia. Los extremos en X quedan dentro de +-0.39,
#     dejando +-0.11 m de viga visible al borde del cell.
#
# Asentado a z_min = 0.045 (E-12), medido sobre VERTICES REALES (E-24).
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

# Madera oscura para las vigas, madera clara para las tablas (contraste de tono).
MAT_viga   = crear_mat('MAT_Piso_Madera_Viga',   (0.32, 0.22, 0.13), rough=0.88)
MAT_tabla  = crear_mat('MAT_Piso_Madera_Tabla',  (0.58, 0.42, 0.25), rough=0.90)
MAT_arena  = crear_mat('MAT_Arena_Isla',         (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Dimensiones ----------
Z_APOYO   = 0.045
ANCHO     = 1.00
PROFUNDO  = 1.00

# Vigas: corren en X (full 1.00), grosor 0.10 en Y, alto 0.04 en Z
VIGA_X   = 1.00
VIGA_Y   = 0.10
VIGA_Z   = 0.04
VIGA_Y_CENTERS = (-0.45, 0.0, 0.45)        # 3 vigas (I, central, D)

# Tablas: corren en Y (full 1.00), grosor 0.18 en X, alto 0.02 en Z
TABLA_X  = 0.18
TABLA_Y  = 1.00
TABLA_Z  = 0.02
TABLA_X_CENTERS = (-0.30, -0.15, 0.0, 0.15, 0.30)  # 5 tablas

# Asertos geometricos previos (las piezas no se salen del cell 1x1)
for yc in VIGA_Y_CENTERS:
    assert abs(yc) + VIGA_Y / 2.0 <= PROFUNDO / 2.0, 'viga %.3f fuera del cell' % yc
for xc in TABLA_X_CENTERS:
    assert abs(xc) + TABLA_X / 2.0 <= ANCHO / 2.0, 'tabla %.3f fuera del cell' % xc

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

# 5a) Vigas longitudinales en X. Apoyan directo en la arena.
z_viga_centro = Z_APOYO + VIGA_Z / 2.0
for i, yc in enumerate(VIGA_Y_CENTERS):
    nombre = ('SM_Piso_Viga_' + ('I' if i == 0 else 'C' if i == 1 else 'D'))
    piezas.append(caja(nombre, MAT_viga,
                       VIGA_X, VIGA_Y, VIGA_Z, 0.0, yc, z_viga_centro))

# 5b) Tablas transversales en Y. Apoyan sobre el lomo de las vigas.
z_tabla_centro = z_viga_centro + VIGA_Z / 2.0 + TABLA_Z / 2.0
for i, xc in enumerate(TABLA_X_CENTERS):
    piezas.append(caja('SM_Piso_Tabla_%d' % (i + 1), MAT_tabla,
                       TABLA_X, TABLA_Y, TABLA_Z, xc, 0.0, z_tabla_centro))

# ---------- 6) Asentado (E-12) medido sobre VERTICES REALES (E-24) ----------
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
print('PISO asentado: z_min %.4f -> %.4f (delta %+.4f, n=%d)' %
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

# ---------- 8) Camara (encuadre bajo: el piso es chato) ----------
bpy.ops.object.camera_add(location=(1.80, -1.80, 1.30))
cam = bpy.context.object
cam.name = 'CAM_Piso'
blanco = Vector((0.0, 0.0, 0.10))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '18-Casas',
                          'piso_madera_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('PISO MADERA OK — SM_: %d — blend: %s' %
      (len([o for o in bpy.data.objects if o.name.startswith('SM_')]), ruta_blend))