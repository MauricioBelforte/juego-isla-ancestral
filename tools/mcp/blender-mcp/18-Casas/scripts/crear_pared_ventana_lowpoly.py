# crear_pared_ventana_lowpoly.py — Pared de madera con ventana (M18-Casas)
# Checklist: "Pared con ventana"
#
# Misma base modular 1x1 celda (1.000 m ancho, M17 RF2) que `pared_madera`,
# con un vano de ventana recortado en el panel + marco de madera + vidrio.
#
# Geometria del vano: 0.64 m ancho x 0.92 m alto, centrado.
#   x in [-0.32, +0.32], z in [1.00, 1.92].
# El panel se parte en 4 tiras para que el hueco se vea (no z-fighting):
#   - tira inferior (bajo el alféizar): x [-0.44, +0.44] x z [0.185, 1.000]
#   - tira superior (sobre el dintel):   x [-0.44, +0.44] x z [1.920, 2.525]
#   - tira izquierda (jamba a poste):   x [-0.44, -0.32] x z [1.00, 1.92]
#   - tira derecha (jamba a poste):     x [+0.32, +0.44] x z [1.00, 1.92]
# Las 4 tiras de panel NO se solapan en XY/Z entre si (cada una ocupa una region
# disjunta del plano del panel), asi que no hay z-fighting.
#
# Marco (4 piezas, sobresalen +-0.02 del plano del panel):
#   alfeizar (sill)  0.64 x 0.14 x 0.04   z=1.005
#   dintel  (lintel) 0.64 x 0.14 x 0.06   z=1.915
#   jambas (2)       0.04 x 0.14 x 0.92   x=+-0.30
# Vidrio: una pieza fina 0.56 x 0.02 x 0.84 al ras del plano del panel.
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

# Mismos materiales base que `pared_madera` para que el set se lea coherente.
MAT_poste     = crear_mat('MAT_Pared_Madera_Poste',     (0.42, 0.28, 0.16), rough=0.88)
MAT_panel     = crear_mat('MAT_Pared_Madera_Panel',     (0.55, 0.40, 0.24), rough=0.90)
# Marco un poco mas oscuro para destacar contra las tiras claras del panel.
MAT_marco     = crear_mat('MAT_Pared_Marco_Ventana',    (0.30, 0.20, 0.12), rough=0.80)
# Vidrio: azul claro, baja rugosidad para un look pulido.
MAT_vidrio    = crear_mat('MAT_Pared_Vidrio',           (0.70, 0.85, 0.95), rough=0.20, spec=0.85)
MAT_arena     = crear_mat('MAT_Arena_Isla',             (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Dimensiones del modulo (identicas a `pared_madera`) ----------
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

# Geometria del vano
VANO_X_MIN    = -0.32
VANO_X_MAX    = +0.32
VANO_Z_MIN    = 1.00
VANO_Z_MAX    = 1.92

# Asertos geometricos previos
assert LUZ + 2.0 * POSTE_ANCHO == ANCHO, 'luz + postes != ancho'
assert VANO_X_MIN > -(LUZ / 2.0) and VANO_X_MAX < (LUZ / 2.0), \
    'vano se sale del panel: [%.2f..%.2f] vs luz/2=%.2f' % (VANO_X_MIN, VANO_X_MAX, LUZ / 2.0)
assert VANO_Z_MIN > VANO_INF and VANO_Z_MAX < VANO_SUP, \
    'vano se sale verticalmente del panel'

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

# 5a) Postes (idénticos a `pared_madera`)
piezas.append(caja('SM_ParedV_Poste_I', MAT_poste,
                   POSTE_ANCHO, ESPESOR, ALTO, -POSTE_X, 0.0, Z_BASE + ALTO / 2))
piezas.append(caja('SM_ParedV_Poste_D', MAT_poste,
                   POSTE_ANCHO, ESPESOR, ALTO, +POSTE_X, 0.0, Z_BASE + ALTO / 2))

# 5b) Soleras (identicas)
piezas.append(caja('SM_ParedV_Solera_Inf', MAT_poste,
                   LUZ, ESPESOR, SOLERA_INF, 0.0, 0.0, Z_BASE + SOLERA_INF / 2))
piezas.append(caja('SM_ParedV_Solera_Sup', MAT_poste,
                   LUZ, ESPESOR, SOLERA_SUP, 0.0, 0.0, VANO_SUP + SOLERA_SUP / 2))

# 5c) Panel partido en 4 tiras (region disjuntas del plano del panel)
TIRA_BAJA_ALTO = VANO_Z_MIN - VANO_INF                      # 0.815
TIRA_ALTA_ALTO = VANO_SUP - VANO_Z_MAX                      # 0.605
TIRA_LAT_ANCHO = (LUZ / 2.0) - VANO_X_MAX                   # 0.12
TIRA_LAT_ALTO  = VANO_Z_MAX - VANO_Z_MIN                    # 0.92

piezas.append(caja('SM_ParedV_Panel_Bajo', MAT_panel,
                   LUZ, PANEL_ESPESOR, TIRA_BAJA_ALTO,
                   0.0, 0.0, VANO_INF + TIRA_BAJA_ALTO / 2))
piezas.append(caja('SM_ParedV_Panel_Sobre', MAT_panel,
                   LUZ, PANEL_ESPESOR, TIRA_ALTA_ALTO,
                   0.0, 0.0, VANO_Z_MAX + TIRA_ALTA_ALTO / 2))
piezas.append(caja('SM_ParedV_Panel_I', MAT_panel,
                   TIRA_LAT_ANCHO, PANEL_ESPESOR, TIRA_LAT_ALTO,
                   -(VANO_X_MIN + TIRA_LAT_ANCHO / 2.0), 0.0, VANO_Z_MIN + TIRA_LAT_ALTO / 2))
piezas.append(caja('SM_ParedV_Panel_D', MAT_panel,
                   TIRA_LAT_ANCHO, PANEL_ESPESOR, TIRA_LAT_ALTO,
                   +(VANO_X_MIN + TIRA_LAT_ANCHO / 2.0), 0.0, VANO_Z_MIN + TIRA_LAT_ALTO / 2))

# 5d) Marco de ventana (alfeizar, dintel, 2 jambas). Cada uno sobresale +-0.02 del
# plano del panel (espesor 0.14 vs panel 0.10) para leerse en relieve.
MARCO_ESP = 0.14
VANO_X_ANCHO = VANO_X_MAX - VANO_X_MIN                       # 0.64
VANO_Z_ALTO  = VANO_Z_MAX - VANO_Z_MIN                       # 0.92

piezas.append(caja('SM_ParedV_Alfeizar', MAT_marco,
                   VANO_X_ANCHO, MARCO_ESP, 0.04,
                   0.0, 0.0, VANO_Z_MIN + 0.005))  # pegado al borde inferior del vano
piezas.append(caja('SM_ParedV_Dintel', MAT_marco,
                   VANO_X_ANCHO, MARCO_ESP, 0.06,
                   0.0, 0.0, VANO_Z_MAX - 0.005))  # pegado al borde superior
JAMBA_X = 0.04
piezas.append(caja('SM_ParedV_Jamba_I', MAT_marco,
                   JAMBA_X, MARCO_ESP, VANO_Z_ALTO,
                   VANO_X_MIN + JAMBA_X / 2.0, 0.0, VANO_Z_MIN + VANO_Z_ALTO / 2))
piezas.append(caja('SM_ParedV_Jamba_D', MAT_marco,
                   JAMBA_X, MARCO_ESP, VANO_Z_ALTO,
                   VANO_X_MAX - JAMBA_X / 2.0, 0.0, VANO_Z_MIN + VANO_Z_ALTO / 2))

# 5e) Vidrio: una pieza fina al ras del plano del panel (y=0).
# 0.56 < 0.64 (ancho del vano) -> queda dentro del marco.
# 0.84 < 0.92 (alto del vano) -> queda dentro del marco.
piezas.append(caja('SM_ParedV_Vidrio', MAT_vidrio,
                   0.56, 0.02, 0.84,
                   0.0, 0.0, VANO_Z_MIN + 0.84 / 2.0))

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
print('PARED-VENTANA asentada: z_min %.4f -> %.4f (delta %+.4f, n=%d)' %
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

# ---------- 8) Camara (mismo encuadre que `pared_madera`) ----------
bpy.ops.object.camera_add(location=(2.30, -3.10, 1.85))
cam = bpy.context.object
cam.name = 'CAM_ParedV'
blanco = Vector((0.0, 0.0, 1.30))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 38
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '18-Casas',
                          'pared_ventana_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('PARED VENTANA OK — SM_: %d — blend: %s' %
      (len([o for o in bpy.data.objects if o.name.startswith('SM_')]), ruta_blend))