# crear_pared_puerta_lowpoly.py — Pared de madera con puerta (M18-Casas)
# Checklist: "Pared con puerta"
#
# Misma base modular 1x1 celda (1.000 m ancho, M17 RF2) que `pared_madera`,
# con un hueco de puerta + marco + puerta visible. Vano: 0.60 m ancho x 2.00 m
# alto, centrado, arrancando al ras del piso (z=0.045).
#
# Composicion (13 piezas, sin z-fighting: jambas y dintel sobresalen +-0.02 del
# plano del panel; paneles arriba/laterales NO comparten volumen con la puerta):
#   - 2 postes + 2 soleras (identicos a `pared_madera`)
#   - 2 paneles laterales: x [-0.44,-0.32] (I) y [+0.32,+0.44] (D),
#     z [0.185 .. 2.10] (entre VANO_INF y dintel)
#   - 1 panel superior sobre el dintel: x [-0.32,+0.32], z [2.10 .. 2.525]
#   - 1 dintel (lintel): 0.66 x 0.14 x 0.06, z=2.045..2.105
#   - 2 jambas: 0.04 x 0.14 x 2.00, x=+-0.30, z=1.045
#   - 1 puerta: 0.60 x 0.04 x 2.00, x=0, z=1.045 (al ras del piso hasta 2.045)
#   - 1 pomo: pequena esfera en el lado de apertura (+X)
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

# Misma paleta que las paredes anteriores.
MAT_poste     = crear_mat('MAT_Pared_Madera_Poste',     (0.42, 0.28, 0.16), rough=0.88)
MAT_panel     = crear_mat('MAT_Pared_Madera_Panel',     (0.55, 0.40, 0.24), rough=0.90)
# Marco y puerta un tono mas oscuro/distinto para destacar.
MAT_marco     = crear_mat('MAT_Pared_Marco_Puerta',     (0.30, 0.20, 0.12), rough=0.80)
MAT_puerta    = crear_mat('MAT_Pared_Puerta',           (0.48, 0.32, 0.20), rough=0.85)
# Pomo de hierro: gris oscuro, mas metalico.
MAT_pomo      = crear_mat('MAT_Pared_Pomo_Hierro',      (0.18, 0.18, 0.20), rough=0.40, spec=0.60, metal=0.85)
MAT_arena     = crear_mat('MAT_Arena_Isla',             (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Dimensiones del modulo ----------
Z_APOYO       = 0.045
ANCHO         = 1.00
ESPESOR       = 0.16
ALTO          = 2.60

POSTE_ANCHO   = 0.06
POSTE_X       = (ANCHO - POSTE_ANCHO) / 2.0     # 0.47
SOLERA_INF    = 0.14
SOLERA_SUP    = 0.12
PANEL_ESPESOR = 0.10
LUZ           = ANCHO - 2.0 * POSTE_ANCHO        # 0.88

Z_BASE        = Z_APOYO
Z_TOP         = Z_BASE + ALTO
VANO_INF      = Z_BASE + SOLERA_INF              # 0.185
VANO_SUP      = Z_TOP - SOLERA_SUP               # 2.525

# Geometria del vano y de la puerta
PUERTA_X_MIN  = -0.30
PUERTA_X_MAX  = +0.30
PUERTA_Z_MIN  = Z_APOYO                          # arranca al ras del piso
PUERTA_Z_MAX  = 2.045                            # alto 2.00 m
PANEL_LAT_ANCHO = (LUZ / 2.0) - PUERTA_X_MAX     # 0.14
PANEL_SUP_ALTO  = VANO_SUP - PUERTA_Z_MAX         # 0.48
MARCO_ESP      = 0.14

# Asertos geometricos
assert abs(POSTE_X) + POSTE_ANCHO / 2.0 <= ANCHO / 2.0
assert PUERTA_X_MIN > -(LUZ / 2.0) and PUERTA_X_MAX < (LUZ / 2.0)
assert PUERTA_Z_MAX > VANO_INF and PUERTA_Z_MAX < VANO_SUP
for yc in (PUERTA_X_MIN, PUERTA_X_MAX):
    assert abs(yc) + PANEL_LAT_ANCHO <= LUZ / 2.0, 'panel lateral se sale'

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

# 5a) Postes
piezas.append(caja('SM_ParedP_Poste_I', MAT_poste,
                   POSTE_ANCHO, ESPESOR, ALTO, -POSTE_X, 0.0, Z_BASE + ALTO / 2))
piezas.append(caja('SM_ParedP_Poste_D', MAT_poste,
                   POSTE_ANCHO, ESPESOR, ALTO, +POSTE_X, 0.0, Z_BASE + ALTO / 2))

# 5b) Soleras
piezas.append(caja('SM_ParedP_Solera_Inf', MAT_poste,
                   LUZ, ESPESOR, SOLERA_INF, 0.0, 0.0, Z_BASE + SOLERA_INF / 2))
piezas.append(caja('SM_ParedP_Solera_Sup', MAT_poste,
                   LUZ, ESPESOR, SOLERA_SUP, 0.0, 0.0, VANO_SUP + SOLERA_SUP / 2))

# 5c) Paneles laterales (entre poste y jamba). Al ras del dintel por arriba.
PANEL_LAT_ALTO = PUERTA_Z_MAX - VANO_INF          # 1.860
piezas.append(caja('SM_ParedP_Panel_Lat_I', MAT_panel,
                   PANEL_LAT_ANCHO, PANEL_ESPESOR, PANEL_LAT_ALTO,
                   -(PUERTA_X_MIN + PANEL_LAT_ANCHO / 2.0), 0.0,
                   VANO_INF + PANEL_LAT_ALTO / 2))
piezas.append(caja('SM_ParedP_Panel_Lat_D', MAT_panel,
                   PANEL_LAT_ANCHO, PANEL_ESPESOR, PANEL_LAT_ALTO,
                   +(PUERTA_X_MIN + PANEL_LAT_ANCHO / 2.0), 0.0,
                   VANO_INF + PANEL_LAT_ALTO / 2))

# 5d) Panel superior (sobre el dintel)
PANEL_SUP_ANCHO = PUERTA_X_MAX - PUERTA_X_MIN      # 0.60
piezas.append(caja('SM_ParedP_Panel_Sup', MAT_panel,
                   PANEL_SUP_ANCHO, PANEL_ESPESOR, PANEL_SUP_ALTO,
                   0.0, 0.0, PUERTA_Z_MAX + PANEL_SUP_ALTO / 2))

# 5e) Dintel (cubre el borde superior de la puerta)
DINTEL_X = PANEL_SUP_ANCHO + 0.06                  # 0.66
DINTEL_Z = 0.06
piezas.append(caja('SM_ParedP_Dintel', MAT_marco,
                   DINTEL_X, MARCO_ESP, DINTEL_Z,
                   0.0, 0.0, PUERTA_Z_MAX + DINTEL_Z / 2))

# 5f) Jambas (laterales verticales del marco, pegadas a la puerta)
JAMBA_X = 0.04
PUERTA_ALTO = PUERTA_Z_MAX - PUERTA_Z_MIN          # 2.00
for i, xc in enumerate((PUERTA_X_MIN + JAMBA_X / 2.0, PUERTA_X_MAX - JAMBA_X / 2.0)):
    nombre = 'SM_ParedP_Jamba_%s' % ('I' if i == 0 else 'D')
    piezas.append(caja(nombre, MAT_marco,
                       JAMBA_X, MARCO_ESP, PUERTA_ALTO,
                       xc, 0.0, PUERTA_Z_MIN + PUERTA_ALTO / 2))

# 5g) Puerta (al ras del piso, queda "empotrada" en el marco)
PUERTA_GROSOR = 0.04
piezas.append(caja('SM_ParedP_Puerta', MAT_puerta,
                   PANEL_SUP_ANCHO, PUERTA_GROSOR, PUERTA_ALTO,
                   0.0, 0.0, PUERTA_Z_MIN + PUERTA_ALTO / 2))

# 5h) Pomo (esfera pequena en el lado de la jamba D, a 0.90 m de altura)
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.025, segments=8, ring_count=6,
                                      location=(PUERTA_X_MAX - 0.07, PUERTA_GROSOR / 2.0 + 0.01,
                                                Z_APOYO + 0.90))
pomo = bpy.context.object
pomo.name = 'SM_ParedP_Pomo'
pomo.data.materials.append(MAT_pomo)
piezas.append(pomo)

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
print('PARED-PUERTA asentada: z_min %.4f -> %.4f (delta %+.4f, n=%d)' %
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

# ---------- 8) Camara ----------
bpy.ops.object.camera_add(location=(2.30, -3.10, 1.85))
cam = bpy.context.object
cam.name = 'CAM_ParedP'
blanco = Vector((0.0, 0.0, 1.20))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 38
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '18-Casas',
                          'pared_puerta_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('PARED PUERTA OK — SM_: %d — blend: %s' %
      (len([o for o in bpy.data.objects if o.name.startswith('SM_')]), ruta_blend))