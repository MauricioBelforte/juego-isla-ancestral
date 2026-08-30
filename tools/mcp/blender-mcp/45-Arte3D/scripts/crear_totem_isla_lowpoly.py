# crear_totem_isla_lowpoly.py — Tótem de isla (M45-Arte3D)
# Checklist: "Tótem de isla (lore)"
#
# Composición: basamento + 3 bloques tallados apilados (decrecen hacia arriba)
# + remate piramidal. Cada bloque tiene "cara" en +Y: ceja, dos ojos con
# pupila y boca, más alas laterales (orejas). Los adornos son hijos del bloque
# (E-11) para que sigan al cuerpo si se mueve.
#
# Convenciones:
#   - Geometría horneada en coordenadas de mundo; los objetos quedan con
#     location=(0,0,0) y scale=(1,1,1) para que los hijos NO hereden escala
#     (evita el doble-escalado de padres con scale != 1).
#   - Bloques = raíces (sin padre). Adornos = hijos. El asentado (E-12) mueve
#     SOLO las raíces, así los hijos acompañan sin duplicar el delta.
#   - Asentado en z_min=0.045 (E-12).
import bpy
import bmesh
import os
import random
import math
from mathutils import Vector, Euler, Matrix

# ---------- 1) Limpieza (idempotencia) ----------
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

MAT_piedra  = crear_mat('MAT_Piedra_Totem',     (0.54, 0.49, 0.41), rough=0.93)
MAT_piedra2 = crear_mat('MAT_Piedra_Totem_Osc', (0.42, 0.38, 0.32), rough=0.94)
MAT_talla   = crear_mat('MAT_Talla_Totem',      (0.80, 0.66, 0.42), rough=0.76)
MAT_ojo     = crear_mat('MAT_Ojo_Totem',        (0.13, 0.11, 0.10), rough=0.50)
MAT_arena   = crear_mat('MAT_Arena_Isla',       (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena (NO exportar) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.8, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Helpers ----------
def nueva_caja(nombre, cx, cy, cz, sx, sy, sz):
    """Caja con geometría horneada: el objeto queda en (0,0,0) y escala 1."""
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
        o.matrix_parent_inverse = Matrix()   # padre con matriz identidad
    return o

# ---------- 5) Basamento ----------
rng = random.Random(21)
PLINTH_H = 0.14
agregar('SM_Totem_Basamento',
        nueva_caja('SM_Totem_Basamento', 0.0, 0.0, PLINTH_H / 2, 0.78, 0.70, PLINTH_H),
        MAT_piedra2)

# ---------- 6) Bloques tallados ----------
BLOQUES = [
    # (nombre, ancho X, prof Y, alto, z_inferior, material)
    ('Cuerpo1', 0.62, 0.56, 0.66, PLINTH_H,               MAT_piedra),
    ('Cuerpo2', 0.56, 0.50, 0.60, PLINTH_H + 0.66,        MAT_piedra2),
    ('Cuerpo3', 0.50, 0.45, 0.54, PLINTH_H + 0.66 + 0.60, MAT_piedra),
]

for (nom, w, d, h, z0, mat) in BLOQUES:
    cuerpo = agregar('SM_Totem_%s' % nom,
                     nueva_caja('SM_Totem_%s' % nom, 0.0, 0.0, z0 + h / 2, w, d, h),
                     mat)
    # --- ceja (barra horizontal sobre los ojos) ---
    agregar('SM_Totem_%s_Ceja' % nom,
            nueva_caja('SM_Totem_%s_Ceja' % nom, 0.0, d / 2 + 0.02, z0 + h * 0.80,
                       w * 0.62, 0.05, 0.05),
            MAT_talla, padre=cuerpo)
    # --- ojos (2) + pupilas (2) ---
    for sx in (-1, 1):
        ox = sx * w * 0.21
        agregar('SM_Totem_%s_Ojo_%s' % (nom, 'I' if sx < 0 else 'D'),
                nueva_caja('SM_Totem_%s_Ojo_%s' % (nom, 'I' if sx < 0 else 'D'),
                           ox, d / 2 + 0.02, z0 + h * 0.66, 0.13, 0.05, 0.10),
                MAT_talla, padre=cuerpo)
        agregar('SM_Totem_%s_Pupila_%s' % (nom, 'I' if sx < 0 else 'D'),
                nueva_caja('SM_Totem_%s_Pupila_%s' % (nom, 'I' if sx < 0 else 'D'),
                           ox, d / 2 + 0.05, z0 + h * 0.66, 0.06, 0.04, 0.06),
                MAT_ojo, padre=cuerpo)
    # --- boca ---
    agregar('SM_Totem_%s_Boca' % nom,
            nueva_caja('SM_Totem_%s_Boca' % nom, 0.0, d / 2 + 0.02, z0 + h * 0.42,
                       w * 0.46, 0.05, 0.09),
            MAT_talla, padre=cuerpo)
    # --- alas / orejas laterales ---
    for sx in (-1, 1):
        agregar('SM_Totem_%s_Ala_%s' % (nom, 'I' if sx < 0 else 'D'),
                nueva_caja('SM_Totem_%s_Ala_%s' % (nom, 'I' if sx < 0 else 'D'),
                           sx * (w / 2 + 0.045), 0.0, z0 + h * 0.55,
                           0.09, d * 0.80, h * 0.44),
                MAT_talla, padre=cuerpo)

# ---------- 7) Remate piramidal ----------
Z_TOP = PLINTH_H + 0.66 + 0.60 + 0.54
bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.36, radius2=0.0,
                                depth=0.26, location=(0.0, 0.0, Z_TOP + 0.13))
remate = bpy.context.object
remate.name = 'SM_Totem_Remate'
remate.rotation_euler = (0.0, 0.0, math.radians(45))
remate.data.materials.append(MAT_talla)
bpy.ops.object.select_all(action='DESELECT')
remate.select_set(True)
bpy.context.view_layer.objects.active = remate
bpy.ops.object.shade_flat()

# ---------- 8) Piedras rotas al pie (adorno, raíces independientes) ----------
for k in range(3):
    ang = rng.uniform(0, 2 * math.pi)
    rad = rng.uniform(0.55, 0.80)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,
                                          radius=rng.uniform(0.10, 0.16),
                                          location=(rad * math.cos(ang),
                                                    rad * math.sin(ang), 0.08))
    roca = bpy.context.object
    roca.name = 'SM_Totem_Roca_%d' % (k + 1)
    roca.scale = (1.0, 0.85, 0.70)
    roca.rotation_euler = (rng.uniform(0, 0.4), rng.uniform(0, 0.4), rng.uniform(0, 3.0))
    roca.data.materials.append(MAT_piedra2)
    bpy.ops.object.select_all(action='DESELECT')
    roca.select_set(True)
    bpy.context.view_layer.objects.active = roca
    bpy.ops.object.shade_flat()

# ---------- 9) Asentado en la base (E-12) ----------
# OJO (E-12): el asentado NO puede hacerse sobre el grupo completo si hay
# adornos sueltos (las rocas del pie). Si la roca más baja queda por debajo del
# basamento, el z_min del conjunto la toma a ella y al compensar se LEVANTA el
# basamento, dejándolo FLOTANDO. Por eso se asienta por separado:
#   a) la estructura (basamento + cuerpos + remate) como un bloque;
#   b) cada roca decorativa de forma individual.
Z_APOYO = 0.045


def asentar_grupo(prefijos, etiqueta):
    """Asienta un grupo: mide el z_min del conjunto y mueve SOLO las raíces
    (los hijos acompañan al padre, así no se duplica el delta)."""
    bpy.context.view_layer.update()
    piezas = [o for o in escena.objects
              if o.type == 'MESH' and any(o.name.startswith(p) for p in prefijos)]
    if not piezas:
        print('AVISO: sin piezas para asentar %s' % etiqueta)
        return
    z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
                for o in piezas)
    delta = Z_APOYO - z_min
    n_raices = 0
    for o in piezas:
        if o.parent is None:
            o.location.z += delta
            n_raices += 1
    print('%s asento: z_min %.3f -> %.3f (delta %+.3f, piezas=%d, raices=%d)'
          % (etiqueta, z_min, Z_APOYO, delta, len(piezas), n_raices))


def asentar_uno(o, etiqueta):
    """Asienta un objeto individual (adorno suelto)."""
    bpy.context.view_layer.update()
    z_min = min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
    o.location.z += Z_APOYO - z_min
    print('%s asento individual: z_min %.3f -> %.3f' % (etiqueta, z_min, Z_APOYO))


asentar_grupo(['SM_Totem_Basamento', 'SM_Totem_Cuerpo', 'SM_Totem_Remate'], 'TOTEM')

for _k in range(3):
    _o = escena.objects.get('SM_Totem_Roca_%d' % (_k + 1))
    if _o is not None:
        asentar_uno(_o, 'TOTEM roca %d' % (_k + 1))

# ---------- 10) Iluminación + mundo ----------
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

# ---------- 11) Cámara ----------
bpy.ops.object.camera_add(location=(2.6, 2.8, 1.5))
cam = bpy.context.object
cam.name = 'CAM_Totem'
blanco = Vector((0.0, 0.0, 1.10))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 12) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '45-Arte3D',
                          'totem_isla_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('TOTEM ISLA OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
