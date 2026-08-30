# crear_anillo_piedras_ritual_lowpoly.py — Anillo de piedras ritual (M45-Arte3D)
# Checklist: "Anillo de piedras ritual"
#
# Composición: 9 piedras irregulares en círculo, todas apoyadas en la arena
# con leve variación de altura. Centro despejado (puede tener una fogata u ofrenda
# luego). Cada piedra es un prisma erosionado (E-01). Distribución: azimut
# 360/9 = 40° entre cada una. Radio del círculo = 1.30 m. Sin el monolito
# central (eso es otro asset).
#
# Asentado: z_min del conjunto a 0.045 (E-12).
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

# Variación de grises/marrones para distinguir piedras
piedra_palette = [
    (0.48, 0.44, 0.38),
    (0.42, 0.40, 0.36),
    (0.55, 0.48, 0.38),
    (0.40, 0.39, 0.34),
    (0.50, 0.46, 0.40),
]
mat_piedras = []
for i, col in enumerate(piedra_palette):
    mat_piedras.append(crear_mat('MAT_Piedra_Anillo_%d' % i, col, rough=0.92))

MAT_arena = crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena (NO exportar) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=2.8, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) 9 piedras en círculo ----------
N_PIEDRAS = 9
RADIO = 1.30
rng = random.Random(31)

def crear_piedra(idx, azimut, radio_circulo, alto_objetivo, ancho_objetivo):
    """Crea una piedra erosionada (prisma de 5-6 lados) en la posición azimutal."""
    LADOS = rng.choice([5, 6])
    SEG_H = 3  # anillos a lo largo de la altura
    H = alto_objetivo
    W = ancho_objetivo

    bm = bmesh.new()
    anillos = []
    for i in range(SEG_H + 1):
        t = i / SEG_H
        z = t * H
        # erosion hacia arriba (tope más pequeño)
        esc = 1.0 - 0.18 * t
        verts = []
        for k in range(LADOS):
            ang = 2 * math.pi * k / LADOS + rng.uniform(-0.05, 0.05)
            r = (W / 2) * esc * rng.uniform(0.92, 1.08)
            x = r * math.cos(ang)
            y = r * math.sin(ang)
            # pequeño tilt en la base (parece clavada en la arena)
            if i == 0:
                x += rng.uniform(-0.02, 0.02)
                y += rng.uniform(-0.02, 0.02)
            verts.append(bm.verts.new((x, y, z)))
        anillos.append(verts)

    # caras laterales
    for i in range(SEG_H):
        for k in range(LADOS):
            k2 = (k + 1) % LADOS
            bm.faces.new((anillos[i][k], anillos[i][k2],
                          anillos[i + 1][k2], anillos[i + 1][k]))
    # tapas
    for anillo, invertir in ((anillos[0], True), (anillos[-1], False)):
        centro = bm.verts.new(sum((v.co for v in anillo), Vector()) / LADOS)
        for k in range(LADOS):
            k2 = (k + 1) % LADOS
            if invertir:
                bm.faces.new((centro, anillo[k2], anillo[k]))
            else:
                bm.faces.new((centro, anillo[k], anillo[k2]))
    bm.normal_update()

    me = bpy.data.meshes.new('SM_Anillo_Piedra_%d' % idx)
    bm.to_mesh(me)
    bm.free()

    ob = bpy.data.objects.new('SM_Anillo_Piedra_%d' % idx, me)
    escena.collection.objects.link(ob)
    # material: rotar entre la paleta
    ob.data.materials.append(mat_piedras[idx % len(mat_piedras)])
    # posición en el círculo
    cx = radio_circulo * math.cos(azimut)
    cy = radio_circulo * math.sin(azimut)
    ob.location = (cx, cy, 0.0)
    # rotación aleatoria leve en Y (no en Z para que no se incline)
    ob.rotation_euler = Euler((0.0, 0.0, rng.uniform(0, 2 * math.pi)), 'XYZ')
    # shade flat
    bpy.ops.object.select_all(action='DESELECT')
    ob.select_set(True)
    bpy.context.view_layer.objects.active = ob
    bpy.ops.object.shade_flat()

# Variación: algunas piedras más altas (verticales), otras más anchas (puestos de ofrenda)
perfiles = [
    (0.55, 0.32),  # alta delgada
    (0.42, 0.40),  # media
    (0.30, 0.50),  # ancha baja
    (0.50, 0.30),  # alta delgada
    (0.38, 0.42),  # media
    (0.62, 0.28),  # alta delgada (piedra de cierre al norte)
    (0.34, 0.48),  # ancha baja
    (0.45, 0.36),  # media
    (0.40, 0.40),  # media
]

for i in range(N_PIEDRAS):
    az = 2 * math.pi * i / N_PIEDRAS + rng.uniform(-0.04, 0.04)
    H, W = perfiles[i]
    crear_piedra(i, az, RADIO + rng.uniform(-0.05, 0.05), H, W)

# ---------- 5) Asentado en la base (E-12) ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Anillo_')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    o.location.z += delta
print('ANILLO asento: z_min %.3f -> %.3f (delta %+.3f, n=%d)' % (z_min, Z_APOYO, delta, len(piezas)))

# ---------- 6) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(48), math.radians(6), math.radians(28)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 7) Cámara (cenital-picada para ver el círculo) ----------
bpy.ops.object.camera_add(location=(2.4, 2.4, 2.4))
cam = bpy.context.object
cam.name = 'CAM_Anillo'
blanco = Vector((0.0, 0.0, 0.35))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 8) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '45-Arte3D',
                          'anillo_piedras_ritual_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('ANILLO PIEDRAS RITUAL OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
