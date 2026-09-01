# crear_pared_madera_lowpoly.py — Pared de madera, módulo base (M18-Casas)
# Checklist: "Pared de madera (módulo base)"
#
# Pieza modular de la rejilla voxel de 1 m (M17 RF2): ocupa exactamente 1x1 celda
# de planta. Ancho 1.00 (X) x espesor 0.16 (Y) x alto 2.60 (Z).
#
# Los postes de los extremos son MEDIOS postes (0.06 de ancho, centrados en
# x = +-0.47). Al colocar dos paredes contiguas, los dos medios postes se
# reconstruyen en un poste entero de 0.12 — es lo que permite alinear N modulos
# sin que la junta se lea como un poste doble.
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

MAT_poste     = crear_mat('MAT_Pared_Madera_Poste',     (0.42, 0.28, 0.16), rough=0.88)
MAT_panel     = crear_mat('MAT_Pared_Madera_Panel',     (0.55, 0.40, 0.24), rough=0.90)
MAT_travesano = crear_mat('MAT_Pared_Madera_Travesano', (0.34, 0.22, 0.12), rough=0.86)
MAT_arena     = crear_mat('MAT_Arena_Isla',             (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Dimensiones del modulo ----------
Z_APOYO       = 0.045          # E-12: 5 mm hundido en la arena
ANCHO         = 1.00           # X — una celda de la rejilla (M17 RF2)
ESPESOR       = 0.16           # Y
ALTO          = 2.60           # Z

POSTE_ANCHO   = 0.06           # medio poste; dos contiguos = 0.12
POSTE_X       = (ANCHO - POSTE_ANCHO) / 2.0     # 0.47
SOLERA_INF    = 0.14
SOLERA_SUP    = 0.12
PANEL_ESPESOR = 0.10           # retranqueado 0.03 por cara respecto al poste
TRAVESANO_ESP = 0.12           # sobresale 0.01 por cara respecto al panel
TRAVESANO_AL  = 0.10

Z_BASE        = Z_APOYO
Z_TOP         = Z_BASE + ALTO
VANO_INF      = Z_BASE + SOLERA_INF              # 0.185
VANO_SUP      = Z_TOP - SOLERA_SUP               # 2.525
VANO_ALTO     = VANO_SUP - VANO_INF              # 2.34
LUZ           = ANCHO - 2.0 * POSTE_ANCHO        # 0.88 — luz entre postes

# Aserto geometrico previo: la luz mas los dos postes cierra el ancho exacto.
assert abs(LUZ + 2.0 * POSTE_ANCHO - ANCHO) < 1e-6, 'luz + postes != ancho'

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
# Postes (medios postes en los extremos, altura completa)
piezas.append(caja('SM_Pared_Poste_I', MAT_poste,
                   POSTE_ANCHO, ESPESOR, ALTO, -POSTE_X, 0.0, Z_BASE + ALTO / 2))
piezas.append(caja('SM_Pared_Poste_D', MAT_poste,
                   POSTE_ANCHO, ESPESOR, ALTO, +POSTE_X, 0.0, Z_BASE + ALTO / 2))
# Soleras inferior y superior (ocupan la luz entre postes)
piezas.append(caja('SM_Pared_Solera_Inf', MAT_poste,
                   LUZ, ESPESOR, SOLERA_INF, 0.0, 0.0, Z_BASE + SOLERA_INF / 2))
piezas.append(caja('SM_Pared_Solera_Sup', MAT_poste,
                   LUZ, ESPESOR, SOLERA_SUP, 0.0, 0.0, VANO_SUP + SOLERA_SUP / 2))
# Panel de relleno (retranqueado en Y para que el entramado se lea en relieve)
piezas.append(caja('SM_Pared_Panel', MAT_panel,
                   LUZ, PANEL_ESPESOR, VANO_ALTO, 0.0, 0.0, VANO_INF + VANO_ALTO / 2))
# Dos travesanos horizontales: rompen el panel y refuerzan la lectura de madera
for i, zc in enumerate((0.80, 1.70)):
    piezas.append(caja('SM_Pared_Travesano_%d' % (i + 1), MAT_travesano,
                       LUZ, TRAVESANO_ESP, TRAVESANO_AL, 0.0, 0.0, zc))

# ---------- 6) Asentado (E-12) medido sobre VERTICES REALES (E-24) ----------
def zmin_real(o):
    """E-24: minimo sobre vertices reales en mundo. `bound_box` da esquinas AABB
    vacias en piezas giradas y produce un falso hundido (caso roca_comun)."""
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

# Aserto fuerte (E-09/E-12): si el asentado no cierra, el script falla.
assert abs(z_final - Z_APOYO) < 1e-4, 'asentado no cierra: %.6f' % z_final
print('PARED asentada: z_min %.4f -> %.4f (delta %+.4f, n=%d)' %
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

# ---------- 8) Camara (encuadre para una pieza de 2.60 m de alto) ----------
bpy.ops.object.camera_add(location=(2.30, -3.10, 1.85))
cam = bpy.context.object
cam.name = 'CAM_Pared'
blanco = Vector((0.0, 0.0, 1.30))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 38
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '18-Casas',
                          'pared_madera_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('PARED MADERA OK — SM_: %d — blend: %s' %
      (len([o for o in bpy.data.objects if o.name.startswith('SM_')]), ruta_blend))
