# crear_hierba_alta_lowpoly.py — Hierba alta / tusca (M50-Vegetacion)
# Checklist: "Hierba alta (tusca de 3-4 matas)"
#
# Composición: 4 matas de hierba alta, cada una con 7-9 briznas (cilindros
# finos que se curvan) y color verde seco. Las matas se distribuyen en un
# pequeño parche. E-12: asentar las matas en bloque a z_min=0.045.
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
def crear_mat(nombre, color, rough=0.85, spec=0.15, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

# Verde seco (mezcla de amarillo y verde)
MAT_hierba = crear_mat('MAT_Hierba_Alta',  (0.55, 0.55, 0.22), rough=0.95)
MAT_hierba_osc = crear_mat('MAT_Hierba_Alta_Osc', (0.42, 0.45, 0.18), rough=0.95)
MAT_arena = crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Brizna individual (curva + taper) ----------
def crear_brizna(idx, pos_xy, alto, azimut, tilt_amt):
    """Brizna: cilindro fino curvado que se afina hacia la punta."""
    SEG = 5
    LADOS = 4  # lowpoly
    r_ini = 0.008
    r_fin = 0.002

    bm = bmesh.new()
    anillos = []
    for i in range(SEG + 1):
        t = i / SEG
        z = t * alto
        # curvatura lateral: se va inclinando hacia un lado
        offset = tilt_amt * t * t  # cuadrática
        r = r_ini + (r_fin - r_ini) * t
        verts = []
        for k in range(LADOS):
            ang = 2 * math.pi * k / LADOS
            verts.append(bm.verts.new((offset + r * math.cos(ang), r * math.sin(ang), z)))
        anillos.append(verts)
    for i in range(SEG):
        for k in range(LADOS):
            k2 = (k + 1) % LADOS
            bm.faces.new((anillos[i][k], anillos[i][k2],
                          anillos[i + 1][k2], anillos[i + 1][k]))
    for anillo, invertir in ((anillos[0], True), (anillos[-1], False)):
        centro = bm.verts.new(sum((v.co for v in anillo), Vector()) / LADOS)
        for k in range(LADOS):
            k2 = (k + 1) % LADOS
            if invertir:
                bm.faces.new((centro, anillo[k2], anillo[k]))
            else:
                bm.faces.new((centro, anillo[k], anillo[k2]))
    bm.normal_update()
    me = bpy.data.meshes.new('SM_HierbaBrizna_%d' % idx)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new('SM_HierbaBrizna_%d' % idx, me)
    escena.collection.objects.link(o)
    o.data.materials.append(MAT_hierba if idx % 2 == 0 else MAT_hierba_osc)
    o.location = (pos_xy[0], pos_xy[1], 0.0)
    o.rotation_euler = Euler((0.0, 0.0, azimut), 'XYZ')
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()

# ---------- 5) 4 matas en parche ----------
mata_posiciones = [(-0.45, 0.10), (0.35, 0.20), (-0.10, -0.35), (0.40, -0.10)]
brizna_id = 0
for mi, (mx, my) in enumerate(mata_posiciones):
    n_briznas = 8
    rng = random.Random(mi * 41 + 5)
    for j in range(n_briznas):
        # posición relativa al centro de la mata
        off_x = rng.uniform(-0.06, 0.06)
        off_y = rng.uniform(-0.06, 0.06)
        brizna_id += 1
        alto = rng.uniform(0.28, 0.42)
        azimut = rng.uniform(0, 2 * math.pi)
        tilt = rng.choice([-1, 1]) * rng.uniform(0.04, 0.09)
        crear_brizna(brizna_id, (mx + off_x, my + off_y), alto, azimut, tilt)

# ---------- 6) Asentado (E-12) — todas las briznas en bloque ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_HierbaBrizna_')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    o.location.z += delta
print('HIERBA ALTA asento: z_min %.3f -> %.3f (delta %+.3f, n=%d)' % (z_min, Z_APOYO, delta, len(piezas)))

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

# ---------- 8) Cámara (cerca, levemente arriba) ----------
bpy.ops.object.camera_add(location=(0.9, -0.9, 0.45))
cam = bpy.context.object
cam.name = 'CAM_HierbaAlta'
blanco = Vector((0.0, 0.0, 0.18))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'hierba_alta_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('HIERBA ALTA OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
