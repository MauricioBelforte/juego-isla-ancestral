# crear_cristal_ancestral_lowpoly.py — Cristal ancestral (M15-Recursos)
# Checklist: "Cristal ancestral (recurso raro, brillante)"
#
# Composición: un cristal grande central (obelisco bmesh) + 4-5 cristales
# más pequeños alrededor, apoyado sobre un pequeño pedestal de piedra con
# grabados. Emisión sutil para que se vea "mágico" (no agresiva).
import bpy
import bmesh
import os
import random
import math
from mathutils import Vector, Euler, Matrix

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
def crear_mat(nombre, color, rough=0.25, spec=0.5, metal=0.0, emission=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    if emission > 0.0:
        bsdf.inputs['Emission Color'].default_value = (*color, 1.0)
        bsdf.inputs['Emission Strength'].default_value = emission
    return m

MAT_piedra = crear_mat('MAT_Piedra_CristalAncestral', (0.45, 0.41, 0.35), rough=0.92)
MAT_pedra  = crear_mat('MAT_Pedestal_Cristal',        (0.50, 0.46, 0.40), rough=0.88)
MAT_talla  = crear_mat('MAT_Talla_Cristal',           (0.82, 0.68, 0.40), rough=0.75)
MAT_cristal = crear_mat('MAT_Cristal_Ancestral_Central',
                        (0.55, 0.78, 0.95), rough=0.18, spec=0.9, emission=0.35)
MAT_cristal_claro = crear_mat('MAT_Cristal_Ancestral_Claro',
                              (0.75, 0.92, 0.98), rough=0.15, spec=0.9, emission=0.25)
MAT_arena  = crear_mat('MAT_Arena_Isla',              (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.4, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Pedestal de piedra ----------
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=6, radius1=0.32, radius2=0.42, depth=0.20)
for v in bm.verts:
    v.co.z += 0.10
bm.normal_update()
me = bpy.data.meshes.new('SM_Cristal_Pedestal')
bm.to_mesh(me)
bm.free()
ped = bpy.data.objects.new('SM_Cristal_Pedestal', me)
escena.collection.objects.link(ped)
ped.data.materials.append(MAT_pedra)
bpy.ops.object.select_all(action='DESELECT')
ped.select_set(True)
bpy.context.view_layer.objects.active = ped
bpy.ops.object.shade_flat()

# Banda dorada grabada en el pedestal
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=0.36, depth=0.04,
                                    location=(0.0, 0.0, 0.12))
banda = bpy.context.object
banda.name = 'SM_Cristal_Banda'
banda.data.materials.append(MAT_talla)
bpy.ops.object.select_all(action='DESELECT')
banda.select_set(True)
bpy.context.view_layer.objects.active = banda
bpy.ops.object.shade_flat()

# ---------- 5) Cristal central (bmesh, hexagonal alargado) ----------
def crear_cristal_central():
    LADOS = 6
    SEG = 6
    LARGO = 0.62
    RADIO = 0.14
    bm = bmesh.new()
    anillos = []
    for i in range(SEG + 1):
        t = i / SEG
        z = t * LARGO
        # Radio: ancho en el medio, fino en los extremos
        if t < 0.25:
            r = RADIO * (t / 0.25) * 0.7
        elif t < 0.75:
            r = RADIO * 0.7 + (RADIO - RADIO * 0.7) * ((t - 0.25) / 0.5)
        else:
            r = RADIO * (1.0 - (t - 0.75) / 0.25) * 0.85
        verts = []
        for kk in range(LADOS):
            ang = 2 * math.pi * kk / LADOS
            verts.append(bm.verts.new((r * math.cos(ang), r * math.sin(ang), z)))
        anillos.append(verts)
    for i in range(SEG):
        for kk in range(LADOS):
            k2 = (kk + 1) % LADOS
            bm.faces.new((anillos[i][kk], anillos[i][k2],
                          anillos[i + 1][k2], anillos[i + 1][kk]))
    # tapa inferior
    anillo = anillos[0]
    centro = bm.verts.new(sum((v.co for v in anillo), Vector()) / LADOS)
    for kk in range(LADOS):
        k2 = (kk + 1) % LADOS
        bm.faces.new((centro, anillo[kk], anillo[k2]))
    bm.normal_update()
    me = bpy.data.meshes.new('SM_Cristal_Central')
    bm.to_mesh(me)
    bm.free()
    return me

cristal = bpy.data.objects.new('SM_Cristal_Central', crear_cristal_central())
escena.collection.objects.link(cristal)
cristal.data.materials.append(MAT_cristal)
bpy.ops.object.select_all(action='DESELECT')
cristal.select_set(True)
bpy.context.view_layer.objects.active = cristal
bpy.ops.object.shade_flat()

# ---------- 6) Cristales menores alrededor (5) ----------
rng = random.Random(43)
for k in range(5):
    LADOS = 5
    SEG = 4
    largo = rng.uniform(0.18, 0.32)
    radio = rng.uniform(0.05, 0.08)
    az = rng.uniform(0, 2 * math.pi)
    dist = rng.uniform(0.22, 0.32)
    tilt = rng.uniform(-0.4, 0.4)

    bm = bmesh.new()
    anillos = []
    for i in range(SEG + 1):
        t = i / SEG
        z = t * largo
        r = radio * (1.0 - 0.5 * t)
        verts = []
        for kk in range(LADOS):
            ang = 2 * math.pi * kk / LADOS + rng.uniform(0, 0.2)
            verts.append(bm.verts.new((r * math.cos(ang), r * math.sin(ang), z)))
        anillos.append(verts)
    for i in range(SEG):
        for kk in range(LADOS):
            k2 = (kk + 1) % LADOS
            bm.faces.new((anillos[i][kk], anillos[i][k2],
                          anillos[i + 1][k2], anillos[i + 1][kk]))
    bm.normal_update()
    me = bpy.data.meshes.new('SM_Cristal_Menor_%d' % (k + 1))
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new('SM_Cristal_Menor_%d' % (k + 1), me)
    escena.collection.objects.link(o)
    o.data.materials.append(MAT_cristal_claro)
    o.location = (dist * math.cos(az), dist * math.sin(az), 0.20)
    o.rotation_euler = (rng.uniform(0, 0.3), rng.uniform(0, 0.3),
                        rng.uniform(0, 2 * math.pi))
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()

# ---------- 7) Asentado (E-12) — grupo completo, base en 0.045 ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Cristal')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:
        o.location.z += delta
print('CRISTAL ANCESTRAL asento: z_min %.3f -> %.3f (delta %+.3f)'
      % (z_min, Z_APOYO, delta))

# ---------- 8) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.0
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(8), math.radians(35)), 'XYZ')

# Luz extra para resaltar el cristal
sol2_data = bpy.data.lights.new('SOL2', type='SUN')
sol2_data.energy = 1.2
sol2_data.color = (0.7, 0.85, 1.0)
sol2 = bpy.data.objects.new('SOL2', sol2_data)
escena.collection.objects.link(sol2)
sol2.rotation_euler = Euler((math.radians(150), math.radians(8), math.radians(220)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.45, 0.62, 0.78, 1.0)   # atardecer
bg.inputs[1].default_value = 0.40

# ---------- 9) Cámara ----------
bpy.ops.object.camera_add(location=(1.4, 1.4, 0.7))
cam = bpy.context.object
cam.name = 'CAM_CristalAncestral'
blanco = Vector((0.0, 0.0, 0.35))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 10) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '15-Recursos',
                          'cristal_ancestral_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('CRISTAL ANCESTRAL OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
