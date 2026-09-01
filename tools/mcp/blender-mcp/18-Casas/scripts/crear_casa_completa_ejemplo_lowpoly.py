# crear_casa_completa_ejemplo_lowpoly.py — Casa completa de ejemplo (M18-Casas)
# Checklist: "Casa completa ejemplo (composición, referencia visual)"
#
# Pieza de REFERENCIA VISUAL que muestra como se ensamblan los modulos de M18
# en una casa de 1x1 celda. No es para colocar en el juego: sirve para validar
# que el sistema modular cierra y para dar un objetivo visual al artista.
#
# Composicion (14 piezas, presupuesto M166 ALTA):
#   - Zocalo de piedra: 4 bloques perimetrales (1.00 x 1.00 x 0.30)
#   - Piso de madera interior: 1 losa (0.84 x 0.84 x 0.04) sobre el zocalo
#   - 4 paredes de madera: cajas simples (1.00 x 0.16 x 2.60) una por lado
#   - Techo a dos aguas simplificado: 1 cumbrero + 2 correas + 2 tableros
#
# z_min 0.045 (E-12), medido sobre vertices reales (E-24).
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

MAT_piedra      = crear_mat('MAT_Casa_Piedra',      (0.62, 0.60, 0.56), rough=0.95)
MAT_pared       = crear_mat('MAT_Casa_Pared',       (0.55, 0.40, 0.24), rough=0.90)
MAT_piso        = crear_mat('MAT_Casa_Piso',        (0.46, 0.32, 0.18), rough=0.88)
MAT_madera_osc  = crear_mat('MAT_Casa_MaderaOsc',   (0.30, 0.20, 0.10), rough=0.86)
MAT_madera_med  = crear_mat('MAT_Casa_MaderaMed',   (0.42, 0.28, 0.16), rough=0.88)
MAT_tablero     = crear_mat('MAT_Casa_Tablero',     (0.58, 0.44, 0.26), rough=0.90)
MAT_arena       = crear_mat('MAT_Arena_Isla',       (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.5, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Dimensiones del modulo ----------
Z_APOYO  = 0.045
ANCHO    = 1.00       # X
PROFUNDO = 1.00       # Y
GROSOR   = 0.08       # grosor de las paredes del zocalo
ALTO_ZOC = 0.30       # alto del zocalo

LUZ_INT   = ANCHO - 2 * GROSOR       # 0.84
LUZ_INT_Y = PROFUNDO - 2 * GROSOR    # 0.84
ALTO_PARED = 2.60                     # alto de las paredes de madera
ESPESOR_PARED = 0.16                  # grosor de las paredes de madera
ALTO_PISO = 0.04                      # grosor del piso interior

# Cota superior de cada elemento
Z_TOP_ZOC = Z_APOYO + ALTO_ZOC                        # 0.345
Z_TOP_PISO = Z_TOP_ZOC + ALTO_PISO                    # 0.385
Z_BASE_PARED = Z_TOP_ZOC                              # las paredes arrancan sobre el zocalo
Z_TOP_PARED = Z_BASE_PARED + ALTO_PARED               # 2.945

# Techo: se apoya sobre el tope de las paredes
ALERO_Z = Z_TOP_PARED + 0.02          # centro de las correas (2.965)
PENDIENTE_X = 0.50
PENDIENTE_Z = 0.80
PENDIENTE_L = math.sqrt(PENDIENTE_X**2 + PENDIENTE_Z**2)
CUMBRERO_Z = ALERO_Z + PENDIENTE_Z    # 3.765

assert LUZ_INT > 0, 'luz interior negativa'

# ---------- 5) Piezas ----------
def caja(nombre, mat, sx, sy, sz, cx, cy, cz, rot_euler=None):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(cx, cy, cz))
    o = bpy.context.object
    o.name = nombre
    o.scale = (sx, sy, sz)
    if rot_euler is not None:
        o.rotation_euler = rot_euler
    o.data.materials.append(mat)
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()
    return o

def track_to_euler(direction, axis, up='Z'):
    return direction.to_track_quat(axis, up).to_euler()

piezas = []

# --- Zocalo de piedra: 4 bloques perimetrales ---
Z_CEN_ZOC = Z_APOYO + ALTO_ZOC / 2
piezas.append(caja('SM_Casa_Zocalo_N', MAT_piedra, ANCHO, GROSOR, ALTO_ZOC,
                   0.0, PROFUNDO / 2 - GROSOR / 2, Z_CEN_ZOC))
piezas.append(caja('SM_Casa_Zocalo_S', MAT_piedra, ANCHO, GROSOR, ALTO_ZOC,
                   0.0, -PROFUNDO / 2 + GROSOR / 2, Z_CEN_ZOC))
piezas.append(caja('SM_Casa_Zocalo_E', MAT_piedra, GROSOR, LUZ_INT_Y, ALTO_ZOC,
                   ANCHO / 2 - GROSOR / 2, 0.0, Z_CEN_ZOC))
piezas.append(caja('SM_Casa_Zocalo_W', MAT_piedra, GROSOR, LUZ_INT_Y, ALTO_ZOC,
                   -ANCHO / 2 + GROSOR / 2, 0.0, Z_CEN_ZOC))

# --- Piso interior: 1 losa apoyada sobre el zocalo ---
piezas.append(caja('SM_Casa_Piso', MAT_piso,
                   LUZ_INT, LUZ_INT_Y, ALTO_PISO,
                   0.0, 0.0, Z_TOP_ZOC + ALTO_PISO / 2))

# --- 4 paredes de madera: cajas simples, una por lado ---
Z_CEN_PARED = Z_BASE_PARED + ALTO_PARED / 2
# Norte y sur: ancho completo en X, grosor en Y
piezas.append(caja('SM_Casa_Pared_N', MAT_pared,
                   ANCHO, ESPESOR_PARED, ALTO_PARED,
                   0.0, PROFUNDO / 2 - ESPESOR_PARED / 2, Z_CEN_PARED))
piezas.append(caja('SM_Casa_Pared_S', MAT_pared,
                   ANCHO, ESPESOR_PARED, ALTO_PARED,
                   0.0, -PROFUNDO / 2 + ESPESOR_PARED / 2, Z_CEN_PARED))
# Este y oeste: grosor en X, ancho en Y (entre las paredes N y S)
LUZ_Y = PROFUNDO - 2 * ESPESOR_PARED    # 0.68
piezas.append(caja('SM_Casa_Pared_E', MAT_pared,
                   ESPESOR_PARED, LUZ_Y, ALTO_PARED,
                   ANCHO / 2 - ESPESOR_PARED / 2, 0.0, Z_CEN_PARED))
piezas.append(caja('SM_Casa_Pared_W', MAT_pared,
                   ESPESOR_PARED, LUZ_Y, ALTO_PARED,
                   -ANCHO / 2 + ESPESOR_PARED / 2, 0.0, Z_CEN_PARED))

# --- Techo a dos aguas simplificado ---
ESC = 0.04
# Cumbrero (viga longitudinal sobre el eje central)
piezas.append(caja('SM_Casa_Cumbrero', MAT_madera_osc,
                   ESC, PROFUNDO, ESC, 0.0, 0.0, CUMBRERO_Z))
# 2 correas (aleros) longitudinales
piezas.append(caja('SM_Casa_Correa_D', MAT_madera_med,
                   ESC, PROFUNDO, ESC, +PENDIENTE_X, 0.0, ALERO_Z))
piezas.append(caja('SM_Casa_Correa_I', MAT_madera_med,
                   ESC, PROFUNDO, ESC, -PENDIENTE_X, 0.0, ALERO_Z))
# 2 tableros de pendiente
dir_d = Vector((-PENDIENTE_X, 0.0, PENDIENTE_Z))
dir_i = Vector((+PENDIENTE_X, 0.0, PENDIENTE_Z))
rot_tab_d = track_to_euler(dir_d, axis='X', up='Z')
rot_tab_i = track_to_euler(dir_i, axis='X', up='Z')
piezas.append(caja('SM_Casa_Tablero_D', MAT_tablero,
                   PENDIENTE_L, PROFUNDO, 0.02,
                   +PENDIENTE_X / 2, 0.0, (ALERO_Z + CUMBRERO_Z) / 2,
                   rot_euler=rot_tab_d))
piezas.append(caja('SM_Casa_Tablero_I', MAT_tablero,
                   PENDIENTE_L, PROFUNDO, 0.02,
                   -PENDIENTE_X / 2, 0.0, (ALERO_Z + CUMBRERO_Z) / 2,
                   rot_euler=rot_tab_i))

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
print('CASA COMPLETA asentada: z_min %.4f -> %.4f (delta %+.4f, n=%d)' %
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

# ---------- 8) Camara (casa completa: vista 3/4 desde arriba) ----------
bpy.ops.object.camera_add(location=(3.80, -4.40, 2.90))
cam = bpy.context.object
cam.name = 'CAM_Casa'
blanco = Vector((0.0, 0.0, 1.70))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 38
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '18-Casas',
                          'casa_completa_ejemplo_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')   # E-21
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('CASA COMPLETA OK — SM_: %d — blend: %s' %
      (len([o for o in bpy.data.objects if o.name.startswith('SM_')]), ruta_blend))