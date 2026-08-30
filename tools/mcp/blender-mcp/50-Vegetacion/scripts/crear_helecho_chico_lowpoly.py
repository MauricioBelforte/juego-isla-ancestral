# crear_helecho_chico_lowpoly.py — Helecho chico (M50-Vegetacion)
# Checklist: "Helecho chico" (variante pequeña del helecho gigante)
#
# Composición: tronco corto + 6 frondas arqueadas con 6 hojuelas cada una.
# Helecho de "sotobosque" — menor escala que el gigante.
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
def crear_mat(nombre, color, rough=0.7, spec=0.1, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_tronco = crear_mat('MAT_Tronco_HelechoChico', (0.30, 0.42, 0.18), rough=0.80)
MAT_hoja   = crear_mat('MAT_Hoja_HelechoChico',   (0.35, 0.62, 0.22), rough=0.62)
MAT_tallo  = crear_mat('MAT_Tallo_HelechoChico',  (0.32, 0.50, 0.20), rough=0.75)
MAT_arena  = crear_mat('MAT_Arena_Isla',          (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Tronco ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.06, depth=0.30,
                                    location=(0.0, 0.0, 0.15))
tronco = bpy.context.object
tronco.name = 'SM_HelechoChico_Tronco'
tronco.data.materials.append(MAT_tronco)
bpy.ops.object.select_all(action='DESELECT')
tronco.select_set(True)
bpy.context.view_layer.objects.active = tronco
bpy.ops.object.shade_flat()

# ---------- 5) Frondas ----------
# Cada fronda = tallo curvo bmesh (8 anillos × 5 lados) + 6 hojuelas parentadas
N_FRONDAS = 6
HOJAS_POR_FRONDAS = 6
rng = random.Random(13)

for k in range(N_FRONDAS):
    az = 2 * math.pi * k / N_FRONDAS + rng.uniform(-0.1, 0.1)
    elev = rng.uniform(15, 30)  # ángulo de elevación (tallo va hacia arriba y afuera)
    # Tallo curvo: empieza en la base del tronco, sube y se arquea hacia afuera
    SEG = 8
    LADOS = 5
    LARGO = 0.45
    RADIO = 0.012

    bm = bmesh.new()
    anillos = []
    for i in range(SEG + 1):
        t = i / SEG
        # Curva 3D: la fronda sale horizontal-radial y arquea
        radial = 0.08 + t * 0.35 * math.cos(math.radians(elev))  # distancia del centro
        altura = 0.05 + t * LARGO * math.sin(math.radians(elev))
        # arqueo: baja un poco al final
        altura -= 0.10 * (t ** 2)
        r = RADIO * (1.0 - 0.3 * t)
        verts = []
        for kk in range(LADOS):
            ang = 2 * math.pi * kk / LADOS
            verts.append(bm.verts.new((radial * math.cos(az) + r * math.cos(ang),
                                       radial * math.sin(az) + r * math.sin(ang),
                                       altura)))
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
    me = bpy.data.meshes.new('SM_HelechoChico_Fronda_%d' % (k + 1))
    bm.to_mesh(me)
    bm.free()
    fronda = bpy.data.objects.new('SM_HelechoChico_Fronda_%d' % (k + 1), me)
    escena.collection.objects.link(fronda)
    fronda.data.materials.append(MAT_tallo)
    bpy.ops.object.select_all(action='DESELECT')
    fronda.select_set(True)
    bpy.context.view_layer.objects.active = fronda
    bpy.ops.object.shade_flat()

    # Hojuelas: parentadas a la fronda, en posiciones a lo largo del tallo
    for j in range(HOJAS_POR_FRONDAS):
        t = (j + 1) / (HOJAS_POR_FRONDAS + 1)
        # tamaño de la hojuela decrece hacia la punta
        w_hoja = 0.12 * (1.0 - 0.5 * t)
        # Local coords: a la mitad del arco, a un lado y otro alternados
        radial = 0.08 + t * 0.35 * math.cos(math.radians(elev))
        altura = 0.05 + t * LARGO * math.sin(math.radians(elev)) - 0.10 * (t ** 2)
        lado = 1 if j % 2 == 0 else -1
        local_x = (radial + w_hoja * 0.5) * math.cos(az) * lado
        local_y = (radial + w_hoja * 0.5) * math.sin(az) * lado
        local_z = altura

        bm2 = bmesh.new()
        bmesh.ops.create_cube(bm2, size=1.0)
        for v in bm2.verts:
            v.co.x = v.co.x * w_hoja + local_x
            v.co.y = v.co.y * 0.005 + local_y
            v.co.z = v.co.z * 0.04 + local_z
        bm2.normal_update()
        me2 = bpy.data.meshes.new('SM_HelechoChico_Hojuela_%d_%d' % (k + 1, j + 1))
        bm2.to_mesh(me2)
        bm2.free()
        hoj = bpy.data.objects.new('SM_HelechoChico_Hojuela_%d_%d' % (k + 1, j + 1), me2)
        escena.collection.objects.link(hoj)
        hoj.data.materials.append(MAT_hoja)
        hoj.parent = fronda
        hoj.matrix_parent_inverse = Matrix()
        bpy.ops.object.select_all(action='DESELECT')
        hoj.select_set(True)
        bpy.context.view_layer.objects.active = hoj
        bpy.ops.object.shade_flat()

# ---------- 6) Asentado (E-12) ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_HelechoChico')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:
        o.location.z += delta
print('HELECHO CHICO asento: z_min %.3f -> %.3f (delta %+.3f)'
      % (z_min, Z_APOYO, delta))

# ---------- 7) Iluminación + mundo ----------
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

# ---------- 8) Cámara ----------
bpy.ops.object.camera_add(location=(1.3, 1.3, 0.7))
cam = bpy.context.object
cam.name = 'CAM_HelechoChico'
blanco = Vector((0.0, 0.0, 0.30))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 9) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'helecho_chico_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('HELECHO CHICO OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
