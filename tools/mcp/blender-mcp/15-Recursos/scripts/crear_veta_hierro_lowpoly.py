# crear_veta_hierro_lowpoly.py — Veta de hierro (M15-Recursos)
# Checklist: "Veta de hierro"
#
# Variante más oscura y "metálica apagada" de la veta de cobre. Misma
# estructura: roca base (icosphere) + 5-6 cristales prismáticos emergiendo.
# Material del cristal: gris oscuro con metalness bajo y roughness alta
# (mineral sin pulir).
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
def crear_mat(nombre, color, rough=0.6, spec=0.25, metal=0.7):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_roca    = crear_mat('MAT_Roca_Hierro',      (0.34, 0.32, 0.30), rough=0.92, metal=0.0)
MAT_cristal = crear_mat('MAT_Cristal_Hierro',   (0.36, 0.34, 0.32), rough=0.45, metal=0.65)
MAT_cristal_osc = crear_mat('MAT_Cristal_Hierro_Oscuro', (0.22, 0.20, 0.19), rough=0.55, metal=0.55)
MAT_arena   = crear_mat('MAT_Arena_Isla',       (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.2, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Roca base (icosphere erosionada) ----------
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.0,
                                       location=(0.0, 0.0, 0.05))
roca = bpy.context.object
roca.name = 'SM_Veta_Roca'
roca.scale = (1.30, 1.15, 0.55)  # achatada
# vertices jitter
me = roca.data
rng_geom = random.Random(91)
for v in me.vertices:
    v.co = (v.co.x + rng_geom.uniform(-0.04, 0.04),
            v.co.y + rng_geom.uniform(-0.04, 0.04),
            v.co.z + rng_geom.uniform(-0.04, 0.04))
me.update()
roca.data.materials.append(MAT_roca)
bpy.ops.object.select_all(action='DESELECT')
roca.select_set(True)
bpy.context.view_layer.objects.active = roca
bpy.ops.object.shade_flat()

# ---------- 5) Cristales hexagonales emergiendo (5 piezas) ----------
# Igual técnica que veta_cobre, pero gris y más cortos/anchos
N_CRIST = 5
rng = random.Random(53)
for k in range(N_CRIST):
    LADOS = 6
    SEG_L = 4
    largo = rng.uniform(0.55, 0.90)
    radio = rng.uniform(0.14, 0.20)
    # ángulo azimutal
    az = rng.uniform(0, 2 * math.pi)
    rad = rng.uniform(0.10, 0.55)  # distancia del centro de la roca
    px = rad * math.cos(az)
    py = rad * math.sin(az)
    # base enterrada: empezamos desde un poco adentro de la roca
    pz = rng.uniform(0.05, 0.18)
    # tilt
    tilt_x = rng.uniform(-0.25, 0.25)
    tilt_y = rng.uniform(-0.25, 0.25)

    bm = bmesh.new()
    anillos = []
    for i in range(SEG_L + 1):
        t = i / SEG_L
        z = t * largo
        r = radio * (1.0 - 0.65 * t)  # taper
        verts = []
        for kk in range(LADOS):
            ang = 2 * math.pi * kk / LADOS + rng.uniform(0, 0.15)
            verts.append(bm.verts.new((r * math.cos(ang), r * math.sin(ang), z)))
        anillos.append(verts)
    # caras laterales
    for i in range(SEG_L):
        for kk in range(LADOS):
            k2 = (kk + 1) % LADOS
            bm.faces.new((anillos[i][kk], anillos[i][k2],
                          anillos[i + 1][k2], anillos[i + 1][kk]))
    # tapas
    for anillo, invertir in ((anillos[0], True), (anillos[-1], False)):
        centro = bm.verts.new(sum((v.co for v in anillo), Vector()) / LADOS)
        for kk in range(LADOS):
            k2 = (kk + 1) % LADOS
            if invertir:
                bm.faces.new((centro, anillo[k2], anillo[kk]))
            else:
                bm.faces.new((centro, anillo[kk], anillo[k2]))
    bm.normal_update()
    me_c = bpy.data.meshes.new('SM_Veta_Cristal_%d' % (k + 1))
    bm.to_mesh(me_c)
    bm.free()
    o = bpy.data.objects.new('SM_Veta_Cristal_%d' % (k + 1), me_c)
    escena.collection.objects.link(o)
    o.location = (px, py, pz)
    o.rotation_euler = Euler((tilt_x, tilt_y, rng.uniform(0, 2 * math.pi)), 'XYZ')
    o.data.materials.append(MAT_cristal if k % 2 == 0 else MAT_cristal_osc)
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()

# ---------- 6) Asentado (E-12) — solo la roca base (los cristales emergen) ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas_base = [o for o in escena.objects
               if o.type == 'MESH' and o.name.startswith('SM_Veta_Roca')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas_base)
delta = Z_APOYO - z_min
for o in piezas_base:
    o.location.z += delta
print('VETA HIERRO roca asento: z_min %.3f -> %.3f (delta %+.3f)' % (z_min, Z_APOYO, delta))

# ---------- 7) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.4
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(8), math.radians(30)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 8) Cámara ----------
bpy.ops.object.camera_add(location=(2.4, -2.6, 1.5))
cam = bpy.context.object
cam.name = 'CAM_VetaHierro'
blanco = Vector((0.0, 0.0, 0.30))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '15-Recursos',
                          'veta_hierro_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('VETA HIERRO OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
