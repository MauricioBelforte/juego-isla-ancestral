# crear_estrella_mar_lowpoly.py — Estrella de mar (M45-Arte3D)
# Checklist: "Estrella de mar"
#
# Estrella de mar de 5 puntas, malla CERRADA (no abierta):
#   - Contorno 2D de 25 vertices (5 brazos x 5 puntos: valle, hombro,
#     punta-izq, punta-der, hombro) -> base PLANA en z=0 (apoya completo).
#   - Anillo superior inset 0.62 y mas bajo -> forma de domo achatado.
#   - Tapas superior e inferior por fan + pared lateral de quads.
# Los puntos decorativos van EMPARENTADOS al cuerpo (E-11) para que no
# floten al asentar.
import bpy
import bmesh
import os
import random
import math
from mathutils import Vector, Euler

random.seed(4512)

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
def crear_mat(nombre, color, rough=0.7, spec=0.25, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_cuerpo = crear_mat('MAT_EstrellaMar', (0.95, 0.45, 0.18), rough=0.70)
MAT_textura = crear_mat('MAT_EstrellaMar_Txt', (0.78, 0.30, 0.12), rough=0.80)
MAT_arena = crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Geometria ----------
N_PUNTAS = 5
ALTO = 0.040          # altura total del cuerpo
Z_ANILLO_TOP = ALTO * 0.72
K_INSET = 0.62        # cuanto se mete el anillo superior hacia el centro
R_PUNTA = 0.25
R_HOMBRO = 0.150
R_VALLE = 0.100
N_BULTOS = 5

# Contorno: (angulo_relativo_al_brazo, radio, jitter)
PLANTILLA = [
    (-0.40, R_VALLE, 0.06),
    (-0.22, R_HOMBRO, 0.05),
    (-0.07, R_PUNTA, 0.03),
    (+0.07, R_PUNTA, 0.03),
    (+0.22, R_HOMBRO, 0.05),
]
PASO = 2.0 * math.pi / N_PUNTAS  # 72 deg

contorno = []  # lista de (angulo, radio) en orden CCW creciente
for k in range(N_PUNTAS):
    ang_brazo = k * PASO
    for frac, radio, jitter in PLANTILLA:
        ang = ang_brazo + frac * PASO
        r = radio * (1.0 + random.uniform(-jitter, jitter))
        contorno.append((ang, r))
N = len(contorno)


def z_superior_en(r, r_top):
    """Altura de la superficie superior a radio r (0=centro, r_top=borde)."""
    f = 0.0 if r_top <= 1e-6 else min(1.0, r / r_top)
    return ALTO + (Z_ANILLO_TOP - ALTO) * f


bm = bmesh.new()

# --- anillo inferior (z = 0, apoyo plano completo) ---
anillo_bot = [bm.verts.new((r * math.cos(a), r * math.sin(a), 0.0))
              for (a, r) in contorno]
centro_bot = bm.verts.new((0.0, 0.0, 0.0))

# --- anillo superior (inset y mas bajo) ---
anillo_top = [bm.verts.new((r * K_INSET * math.cos(a),
                            r * K_INSET * math.sin(a),
                            Z_ANILLO_TOP))
              for (a, r) in contorno]
centro_top = bm.verts.new((0.0, 0.0, ALTO))

# --- tapa inferior (normal -Z) ---
for i in range(N):
    j = (i + 1) % N
    bm.faces.new((centro_bot, anillo_bot[j], anillo_bot[i]))

# --- pared lateral (normal hacia fuera) ---
for i in range(N):
    j = (i + 1) % N
    bm.faces.new((anillo_bot[i], anillo_bot[j], anillo_top[j], anillo_top[i]))

# --- tapa superior (normal +Z) ---
for i in range(N):
    j = (i + 1) % N
    bm.faces.new((centro_top, anillo_top[i], anillo_top[j]))

bm.normal_update()
me = bpy.data.meshes.new('SM_Estrella_Mar')
bm.to_mesh(me)
bm.free()

cuerpo = bpy.data.objects.new('SM_Estrella_Mar', me)
escena.collection.objects.link(cuerpo)
cuerpo.data.materials.append(MAT_cuerpo)
bpy.context.view_layer.objects.active = cuerpo
cuerpo.select_set(True)
bpy.ops.object.shade_flat()

# ---------- 5) Bultos decorativos EMPARENTADOS (E-11) ----------
# Se calcula la altura real de la superficie y se hunde el bulto para que
# nunca flote: el centro de la esfera queda por debajo de la superficie.
R_BULTO = 0.022
for k in range(N_BULTOS):
    ang = k * PASO + PASO * 0.5
    r = 0.105
    # radio del borde superior en esta direccion (contorno mas cercano)
    r_top = R_VALLE * K_INSET
    z_sup = z_superior_en(r, r_top)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=R_BULTO,
                                          location=(r * math.cos(ang),
                                                    r * math.sin(ang),
                                                    z_sup - R_BULTO * 0.55))
    bulto = bpy.context.object
    bulto.name = 'SM_EstrellaMar_Bulto_%d' % (k + 1)
    bulto.data.materials.append(MAT_textura)
    bpy.ops.object.select_all(action='DESELECT')
    bulto.select_set(True)
    bpy.context.view_layer.objects.active = bulto
    bpy.ops.object.shade_flat()
    # E-11: emparentar con matrix_parent_inverse = inversa del cuerpo
    bulto.parent = cuerpo
    bulto.matrix_parent_inverse = cuerpo.matrix_world.inverted()

# ---------- 6) Asentado (E-12) ----------
# Solo se mueve el cuerpo; los bultos siguen por el parent (E-11).
Z_APOYO = 0.045
bpy.context.view_layer.update()
z_min = min((cuerpo.matrix_world @ Vector(c)).z for c in cuerpo.bound_box)
delta = Z_APOYO - z_min
cuerpo.location.z += delta
bpy.context.view_layer.update()
z_min_final = min((cuerpo.matrix_world @ Vector(c)).z for c in cuerpo.bound_box)
print('ESTRELLA MAR asento: z_min %.3f -> %.3f (delta %+.3f)' % (z_min, z_min_final, delta))

# ---------- 7) Iluminacion + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(6), math.radians(28)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 8) Camara ----------
bpy.ops.object.camera_add(location=(0.0, -0.62, 0.40))
cam = bpy.context.object
cam.name = 'CAM_EstrellaMar'
blanco = Vector((0.0, 0.0, 0.03))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '45-Arte3D',
                          'estrella_mar_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_sm = len([o for o in bpy.data.objects if o.name.startswith('SM_')])
print('ESTRELLA MAR OK — objetos: %d (SM_: %d) — caras: %d — blend: %s'
      % (len(bpy.data.objects), n_sm, len(me.polygons), ruta_blend))
