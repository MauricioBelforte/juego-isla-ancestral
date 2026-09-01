# crear_techo_dos_aguas_lowpoly.py — Techo a dos aguas, módulo base (M18-Casas)
# Checklist: "Techo a dos aguas (módulo)"
#
# Pieza modular de la rejilla voxel de 1 m (M17 RF2): ocupa la 1x1 celda sobre
# las paredes. Empotrado sobre el tope de los postes (z = 2.645): el cumbrero
# sube 0.80 m sobre los aleros, corrida 0.50 m en X. Estructura: 1 cumbrero +
# 2 correas + 4 cabios por vertiente + 2 tableros de pendiente. Sin fachada en
# las cabezas (la pared cierra el gable en composición con la casa).
#
# A diferencia del resto, este modulo NO se asienta sobre la arena: se apoya
# sobre las paredes. Su z_min debe caer dentro del rango del poste superior
# (2.62..2.66), no en 0.045. La verificacion geometrica se hace con assert y se
# imprime, pero no se reasienta (E-09/E-12 solo aplican a objetos sobre arena).
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

MAT_madera_osc = crear_mat('MAT_Techo_Madera_Osc', (0.30, 0.20, 0.10), rough=0.86)
MAT_madera_med = crear_mat('MAT_Techo_Madera_Med', (0.42, 0.28, 0.16), rough=0.88)
MAT_tablero    = crear_mat('MAT_Techo_Tablero',    (0.55, 0.40, 0.24), rough=0.90)
MAT_arena      = crear_mat('MAT_Arena_Isla',       (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Dimensiones del modulo ----------
# Encaja exactamente en la celda 1x1 sobre el tope de los postes de la pared.
ANCHO   = 1.00        # X — ancho entre aleros (la celda)
PROFUNDO = 1.00       # Y — profundidad del techo
ALTO_PARED = 2.645    # Z — tope del poste superior de la pared
ESC_MADERA = 0.04     # seccion cuadrada de cumbrero, correas y cabios
TABLERO_ESP = 0.02    # espesor del tablero de pendiente

ALERO_Z = ALTO_PARED + ESC_MADERA / 2.0   # 2.665 — centro de las correas
PENDIENTE_X = 0.50                       # corrida en X (alero -> cumbrero)
PENDIENTE_Z = 0.80                       # altura en Z (alero -> cumbrero)
PENDIENTE_L = math.sqrt(PENDIENTE_X**2 + PENDIENTE_Z**2)   # ~0.943 m
CUMBRERO_Z = ALERO_Z + PENDIENTE_Z       # 3.465 — centro del cumbrero

# 4 cabios por vertiente, separados ~0.28 m en Y
CABIO_YS = (-0.42, -0.14, 0.14, 0.42)
assert len(CABIO_YS) == 4
# Asertos geometricos
assert abs(PENDIENTE_X * 2 - ANCHO) < 1e-6, 'ancho != 2*PENDIENTE_X'
assert PENDIENTE_L > 0 and PENDIENTE_L < 1.0, 'pendiente fuera de rango'

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
    """Quaternion que alinea el eje local `axis` con `direction`, manteniendo el
    eje local `up` lo mas cerca posible de su direccion por defecto."""
    return direction.to_track_quat(axis, up).to_euler()

piezas = []

# Cumbrero: viga longitudinal sobre el eje central (X=0), a la altura del cumbrero
piezas.append(caja('SM_Techo_Cumbrero', MAT_madera_osc,
                   ESC_MADERA, ANCHO, ESC_MADERA,
                   0.0, 0.0, CUMBRERO_Z))

# 2 correas (aleros), longitudinales en Y, una a cada lado en X
piezas.append(caja('SM_Techo_Correa_D', MAT_madera_med,
                   ESC_MADERA, ANCHO, ESC_MADERA,
                   +PENDIENTE_X, 0.0, ALERO_Z))
piezas.append(caja('SM_Techo_Correa_I', MAT_madera_med,
                   ESC_MADERA, ANCHO, ESC_MADERA,
                   -PENDIENTE_X, 0.0, ALERO_Z))

# 4 cabios por vertiente (8 en total): van del alero al cumbrero sobre cada plano
# de pendiente. Local "Y" del cubo se alinea con el vector alero->cumbrera.
dir_d = Vector((-PENDIENTE_X, 0.0, PENDIENTE_Z))   # vertiente +X
dir_i = Vector((+PENDIENTE_X, 0.0, PENDIENTE_Z))   # vertiente -X
rot_d = track_to_euler(dir_d, axis='Y', up='Z')
rot_i = track_to_euler(dir_i, axis='Y', up='Z')
for yi, yc in enumerate(CABIO_YS):
    piezas.append(caja('SM_Techo_Cabio_D_%d' % (yi + 1), MAT_madera_med,
                       ESC_MADERA, PENDIENTE_L, ESC_MADERA,
                       +PENDIENTE_X / 2, yc, (ALERO_Z + CUMBRERO_Z) / 2,
                       rot_euler=rot_d))
    piezas.append(caja('SM_Techo_Cabio_I_%d' % (yi + 1), MAT_madera_med,
                       ESC_MADERA, PENDIENTE_L, ESC_MADERA,
                       -PENDIENTE_X / 2, yc, (ALERO_Z + CUMBRERO_Z) / 2,
                       rot_euler=rot_i))

# 2 tableros de pendiente (planks finos que cubren cada vertiente).
# Local "X" del cubo se alinea con el vector alero->cumbrera (a lo largo).
# Local "Z" del cubo (espesor) se alinea con la normal del plano de pendiente.
rot_tablero_d = track_to_euler(dir_d, axis='X', up='Z')
rot_tablero_i = track_to_euler(dir_i, axis='X', up='Z')
piezas.append(caja('SM_Techo_Tablero_D', MAT_tablero,
                   PENDIENTE_L, ANCHO, TABLERO_ESP,
                   +PENDIENTE_X / 2, 0.0, (ALERO_Z + CUMBRERO_Z) / 2,
                   rot_euler=rot_tablero_d))
piezas.append(caja('SM_Techo_Tablero_I', MAT_tablero,
                   PENDIENTE_L, ANCHO, TABLERO_ESP,
                   -PENDIENTE_X / 2, 0.0, (ALERO_Z + CUMBRERO_Z) / 2,
                   rot_euler=rot_tablero_i))

# ---------- 6) Verificacion geometrica ----------
# El techo NO se asienta sobre la arena (E-09/E-12 solo alli). Se apoya sobre
# las paredes, asi que su punto mas bajo cae dentro del rango del poste
# superior (entre 2.62 y 2.66). Medimos en vertices reales (E-24).
def zmin_real(o):
    if len(o.data.vertices) == 0:
        return min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
    return min((o.matrix_world @ v.co).z for v in o.data.vertices)

bpy.context.view_layer.update()
z_min = min(zmin_real(o) for o in piezas)
z_max = max((max((o.matrix_world @ v.co).z for v in o.data.vertices))
            for o in piezas if len(o.data.vertices) > 0)
print('TECHO DOS AGUAS: z_min %.4f  z_max %.4f  (esperado alero ~2.645, cumbrero ~3.465)'
      % (z_min, z_max))
assert 2.62 < z_min < 2.66, \
    'z_min %.4f fuera del rango esperado del alero [2.62, 2.66]' % z_min
# z_max = cumbrero cara superior = CUMBRERO_Z + ESC_MADERA/2 = 3.485
assert 3.44 < z_max < 3.50, \
    'z_max %.4f fuera del rango esperado del cumbrero [3.44, 3.50]' % z_max

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

# ---------- 8) Camara (encuadre: pieza a 3 m de elevacion) ----------
bpy.ops.object.camera_add(location=(2.70, -3.50, 3.30))
cam = bpy.context.object
cam.name = 'CAM_Techo'
blanco = Vector((0.0, 0.0, 3.05))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 38
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '18-Casas',
                          'techo_dos_aguas_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')   # E-21: save_as_mainfile falla si existe "@"
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('TECHO DOS AGUAS OK — SM_: %d — blend: %s' %
      (len([o for o in bpy.data.objects if o.name.startswith('SM_')]), ruta_blend))