# crear_monton_ramas_lowpoly.py — Montón de ramas (M15-Recursos)
# Checklist: "Montón de ramas"
#
# Composición: 6-8 ramas cilíndricas de madera apiladas en el suelo formando
# un pequeño montículo. Cada rama es un cilindro erosionado (bmesh) con dos
# materiales: corteza oscura afuera, madera interior clara en los extremos
# cortados. E-01: una sola malla por rama (sin multiparte). E-12: todas
# apoyadas en la arena con autocorrección a z_min=0.045.
import bpy
import bmesh
import os
import random
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

MAT_corteza = crear_mat('MAT_Corteza_Rama', (0.30, 0.20, 0.13), rough=0.92)
MAT_madera  = crear_mat('MAT_Madera_Rama',  (0.66, 0.48, 0.30), rough=0.80)
MAT_arena   = crear_mat('MAT_Arena_Isla',   (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.2, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Función: rama erosionada con dos materiales ----------
def crear_rama(idx, largo, radio_ini, radio_fin, azimut, pos_xy, tilt):
    """Crea una rama como una sola malla bmesh con 2 materiales."""
    SEG_L = 5
    LADOS = 7
    rng = random.Random(idx * 13 + 7)
    ruido = [[rng.uniform(0.92, 1.08) for _ in range(LADOS)] for _ in range(SEG_L + 1)]

    bm = bmesh.new()
    anillos = []
    for i in range(SEG_L + 1):
        t = i / SEG_L
        x = -largo / 2 + t * largo
        # pequeña curvatura en Y/Z
        cy = 0.04 * math.sin(t * math.pi * 1.2) * (1.0 if rng.random() > 0.5 else -1.0)
        cz = 0.03 * math.sin(t * math.pi * 0.8)
        r = (radio_ini + (radio_fin - radio_ini) * t)
        verts = []
        for k in range(LADOS):
            ang = 2 * math.pi * k / LADOS
            rr = r * ruido[i][k]
            verts.append(bm.verts.new((x, cy + rr * math.sin(ang), cz + rr * math.cos(ang))))
        anillos.append(verts)

    # caras laterales (corteza = mat 0)
    for i in range(SEG_L):
        for k in range(LADOS):
            k2 = (k + 1) % LADOS
            f = bm.faces.new((anillos[i][k], anillos[i][k2],
                              anillos[i + 1][k2], anillos[i + 1][k]))
            f.material_index = 0

    # tapas (madera interior = mat 1)
    for anillo, idx_tapa in ((anillos[0], 0), (anillos[-1], SEG_L)):
        centro = bm.verts.new(Vector((0, 0, 0)))
        centro.co = sum((v.co for v in anillo), Vector()) / LADOS
        if idx_tapa == 0:
            fan = [bm.faces.new((centro, anillo[k], anillo[(k + 1) % LADOS]))
                   for k in range(LADOS)]
        else:
            fan = [bm.faces.new((centro, anillo[(k + 1) % LADOS], anillo[k]))
                   for k in range(LADOS)]
        for f in fan:
            f.material_index = 1

    bm.normal_update()
    me = bpy.data.meshes.new('SM_Monton_Rama_%d' % idx)
    bm.to_mesh(me)
    bm.free()

    o = bpy.data.objects.new('SM_Monton_Rama_%d' % idx, me)
    escena.collection.objects.link(o)
    me.materials.append(MAT_corteza)   # index 0
    me.materials.append(MAT_madera)    # index 1
    o.location = (pos_xy[0], pos_xy[1], 0.0)
    o.rotation_euler = Euler((tilt[0], tilt[1], azimut), 'XYZ')
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()


# ---------- 5) Componer el montón: 7 ramas de variados tamaños ----------
# Patrón: 2 grandes abajo (suelo), 3 medianas cruzadas encima, 2 pequeñas arriba
ramas = [
    # (largo, radio_ini, radio_fin, azimut_Z, (x, y), tilt)
    (0.95, 0.055, 0.045, 0.0,  (-0.30,  0.05), (math.radians(0),   math.radians(0))),    # base, va a la izq
    (0.95, 0.055, 0.045, math.radians(8),  (0.32, -0.04),  (math.radians(0),   math.radians(0))),  # base, va a la der
    (0.75, 0.045, 0.035, math.radians(82), (0.05,  0.10),  (math.radians(0),   math.radians(0))),  # cruzada en X
    (0.80, 0.050, 0.040, math.radians(-72),(-0.08, -0.12), (math.radians(0),   math.radians(0))), # cruzada perpendicular
    (0.65, 0.040, 0.032, math.radians(40),  (0.20,  0.15),  (math.radians(0),   math.radians(0))),
    (0.50, 0.038, 0.030, math.radians(120), (-0.18, 0.18),  (math.radians(0),   math.radians(0))),
    (0.45, 0.035, 0.028, math.radians(-30), (0.05, -0.18),  (math.radians(0),   math.radians(0))),
]
for i, (l, ri, rf, az, pos, tilt) in enumerate(ramas):
    crear_rama(i + 1, l, ri, rf, az, pos, tilt)

# ---------- 6) Asentado (E-12) ----------
# Asentar todo el montón en bloque.
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Monton_')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    o.location.z += delta
print('MONTON RAMAS asento: z_min %.3f -> %.3f (delta %+.3f, n=%d)' % (z_min, Z_APOYO, delta, len(piezas)))

# ---------- 7) Iluminación + mundo ----------
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

# ---------- 8) Cámara ----------
bpy.ops.object.camera_add(location=(1.6, -1.8, 1.0))
cam = bpy.context.object
cam.name = 'CAM_MontonRamas'
blanco = Vector((0.0, 0.0, 0.10))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '15-Recursos',
                          'monton_ramas_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('MONTON RAMAS OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
