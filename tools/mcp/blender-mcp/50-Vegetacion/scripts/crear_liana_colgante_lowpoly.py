# crear_liana_colgante_lowpoly.py — Liana colgante (M50-Vegetacion)
# Checklist: "Liana colgante (para ruinas/templos)"
#
# Composición: dos postes de piedra verticales + viga horizontal de madera
# sobre la que cuelgan 4 lianas de distinta longitud. Así la pieza entera
# está apoyada en la arena (no flota) y las lianas penden del dintel.
#
# Cada liana = bmesh cilíndrico con taper y leve curvatura. Pequeñas hojitas
# parentadas (E-11) a la liana a alturas variables.
#
# Convenciones:
#   - Geometría horneada; los objetos con location=(0,0,0) y scale=(1,1,1)
#     para evitar el doble-escalado en hijos.
#   - Postes, viga, lianas y hojas se asientan POR GRUPO: el grupo de la liana
#     (viga + postes) es estructural; cada liana cuelga y NO se asienta.
#   - Asentado en z_min=0.045 (E-12).
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
def crear_mat(nombre, color, rough=0.85, spec=0.12, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_piedra = crear_mat('MAT_Piedra_Liana',    (0.55, 0.50, 0.43), rough=0.93)
MAT_madera = crear_mat('MAT_Madera_Liana',    (0.45, 0.32, 0.18), rough=0.86)
MAT_tallo  = crear_mat('MAT_Tallo_Liana',     (0.36, 0.46, 0.22), rough=0.78)
MAT_hoja   = crear_mat('MAT_Hoja_Liana',      (0.30, 0.55, 0.20), rough=0.65)
MAT_arena  = crear_mat('MAT_Arena_Isla',      (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.4, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Helpers ----------
def nueva_caja(nombre, cx, cy, cz, sx, sy, sz):
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
        o.matrix_parent_inverse = Matrix()
    return o

# ---------- 5) Postes de piedra (2) ----------
POSTE_H = 1.85
SEP_X = 0.95
for k, x in enumerate((-SEP_X, SEP_X)):
    agregar('SM_Liana_Poste_%d' % (k + 1),
            nueva_caja('SM_Liana_Poste_%d' % (k + 1), x, 0.0, POSTE_H / 2,
                       0.20, 0.20, POSTE_H),
            MAT_piedra)

# ---------- 6) Viga horizontal de madera sobre los postes ----------
VIGA_Y = 0.0
VIGA_Z = POSTE_H - 0.05
viga = agregar('SM_Liana_Viga',
               nueva_caja('SM_Liana_Viga', 0.0, VIGA_Y, VIGA_Z,
                          SEP_X * 2 + 0.22, 0.20, 0.16),
               MAT_madera)

# ---------- 7) Lianas colgantes (4) ----------
# Cada liana: cilindro bmesh con taper y leve curvatura.
rng = random.Random(31)
for k in range(4):
    LADOS = 6
    SEG = 6
    # Longitud variable y desplazamiento en X bajo la viga
    largo = rng.uniform(0.95, 1.45)
    offset_x = rng.uniform(-SEP_X * 0.6, SEP_X * 0.6)
    offset_y = rng.uniform(-0.18, 0.18)
    radio_top = 0.030
    radio_bot = 0.045
    # Curvatura lateral: se aplica un pequeño offset X a los anillos intermedios
    curvatura = rng.uniform(-0.06, 0.06)

    bm = bmesh.new()
    anillos = []
    for i in range(SEG + 1):
        t = i / SEG
        r = radio_top * t + radio_bot * (1.0 - t)
        z = -t * largo  # hacia abajo desde la viga
        # Curvatura senoidal
        curva_x = math.sin(t * math.pi) * curvatura
        verts = []
        for kk in range(LADOS):
            ang = 2 * math.pi * kk / LADOS
            verts.append(bm.verts.new((curva_x + r * math.cos(ang),
                                       r * math.sin(ang), z)))
        anillos.append(verts)
    # caras laterales
    for i in range(SEG):
        for kk in range(LADOS):
            k2 = (kk + 1) % LADOS
            bm.faces.new((anillos[i][kk], anillos[i][k2],
                          anillos[i + 1][k2], anillos[i + 1][kk]))
    # tapa superior (la inferior queda abierta)
    anillo = anillos[0]
    centro = bm.verts.new(sum((v.co for v in anillo), Vector()) / LADOS)
    for kk in range(LADOS):
        k2 = (kk + 1) % LADOS
        bm.faces.new((centro, anillo[kk], anillo[k2]))
    bm.normal_update()
    me = bpy.data.meshes.new('SM_Liana_Tallo_%d' % (k + 1))
    bm.to_mesh(me)
    bm.free()
    # Posición de la liana: arranca desde la cara inferior de la viga
    tallo = agregar('SM_Liana_Tallo_%d' % (k + 1), me, MAT_tallo)
    tallo.location = (offset_x, VIGA_Y + offset_y, VIGA_Z - 0.08)

    # Hojas parentadas (3 a lo largo del tallo)
    for j in range(3):
        # Posición local sobre el tallo (t = 0.25, 0.50, 0.75)
        t = (j + 1) / 4.0
        # Las hojas miran en distintas direcciones azimutales
        azim = rng.uniform(0, 2 * math.pi)
        angulo = 30 + rng.uniform(-15, 15)
        hoja = agregar('SM_Liana_Hoja_%d_%d' % (k + 1, j + 1),
                       nueva_caja('SM_Liana_Hoja_%d_%d' % (k + 1, j + 1),
                                  0.0, 0.0, 0.0, 0.12, 0.02, 0.08),
                       MAT_hoja, padre=tallo)
        # Posicionar la hoja en el tallo: distancia radial = radio actual
        r_actual = radio_top * t + radio_bot * (1.0 - t)
        local_x = r_actual * math.cos(azim) + math.sin(t * math.pi) * curvatura
        local_y = r_actual * math.sin(azim)
        local_z = -t * largo
        hoja.location = (local_x, local_y, local_z)
        # Rotar: que salga perpendicular al tallo
        hoja.rotation_euler = (math.radians(60 + angulo),
                               math.radians(rng.uniform(-20, 20)),
                               azim + math.pi / 2)

# ---------- 8) Asentado (E-12) — solo la estructura (postes + viga) ----------
Z_APOYO = 0.045


def asentar_grupo(prefijos, etiqueta):
    bpy.context.view_layer.update()
    piezas = [o for o in escena.objects
              if o.type == 'MESH' and any(o.name.startswith(p) for p in prefijos)]
    if not piezas:
        return
    z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
                for o in piezas)
    delta = Z_APOYO - z_min
    for o in piezas:
        if o.parent is None:
            o.location.z += delta
    print('%s asento: z_min %.3f -> %.3f (delta %+.3f, raices=%d)'
          % (etiqueta, z_min, Z_APOYO, delta,
             sum(1 for o in piezas if o.parent is None)))


asentar_grupo(['SM_Liana_Poste', 'SM_Liana_Viga'], 'LIANA estructura')
# Las lianas y sus hojas cuelgan desde la viga, no se tocan el suelo a propósito.

# ---------- 9) Iluminación + mundo ----------
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

# ---------- 10) Cámara ----------
bpy.ops.object.camera_add(location=(2.8, 2.8, 1.5))
cam = bpy.context.object
cam.name = 'CAM_Liana'
blanco = Vector((0.0, 0.0, 1.00))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 11) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'liana_colgante_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('LIANA COLGANTE OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
