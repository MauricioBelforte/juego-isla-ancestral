# crear_tronco_caido_lowpoly.py — Tronco caído (M15-Recursos, madera recolectable)
# Checklist: "Tronco caído (madera recolectable)"
# Composición: tronco horizontal de una sola malla bmesh (E-01), corteza oscura
# en el cuerpo y madera clara en los dos extremos cortados (faces con
# material_index distinto). + 2 muñones de rama y raíces expuestas en la base.
import bpy
import bmesh
import os
import random
from math import radians, sin, cos, pi
from mathutils import Vector, Euler

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
def crear_mat(nombre, color, rough=0.8, spec=0.15, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    b.inputs['Metallic'].default_value = metal
    return m

MAT_corteza = crear_mat('MAT_Corteza_Tronco', (0.26, 0.17, 0.11), rough=0.92)
MAT_madera  = crear_mat('MAT_Madera_Corte',   (0.62, 0.44, 0.26), rough=0.80)
MAT_arena   = crear_mat('MAT_Arena_Isla',     (0.92, 0.84, 0.63), rough=1.00)
MAT_hojaras = crear_mat('MAT_Hojarasca',      (0.38, 0.30, 0.14), rough=0.95)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.6, depth=0.22,
                                    location=(0, 0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Tronco: UNA sola malla bmesh ----------
LARGO = 3.20
SEG_L = 8      # anillos a lo largo (más que una curva pronunciada: leve pandeo)
LADOS = 9      # lowpoly
R_INI = 0.40
R_FIN = 0.30

rng = random.Random(77)
ruido = [[rng.uniform(0.90, 1.10) for _ in range(LADOS)] for _ in range(SEG_L + 1)]

bm = bmesh.new()
anillos = []
for i in range(SEG_L + 1):
    t = i / SEG_L
    x = -LARGO / 2 + t * LARGO
    # pandeo suave en Y y Z (el tronco no es perfectamente recto)
    cy = 0.14 * sin(t * pi * 0.9)
    cz = 0.05 * sin(t * pi * 0.6 + 0.7)
    r = (R_INI + (R_FIN - R_INI) * t) * (1.0 - 0.05 * sin(t * pi * 3.0))
    anillo = []
    for k in range(LADOS):
        ang = 2 * pi * k / LADOS
        rr = r * ruido[i][k]
        anillo.append(bm.verts.new((x,
                                    cy + rr * sin(ang),
                                    cz + rr * cos(ang))))
    anillos.append(anillo)

# caras laterales (corteza)
caras_laterales = []
for i in range(SEG_L):
    for k in range(LADOS):
        k2 = (k + 1) % LADOS
        f = bm.faces.new([anillos[i][k], anillos[i][k2],
                          anillos[i + 1][k2], anillos[i + 1][k]])
        f.material_index = 0
        caras_laterales.append(f)

# tapas (extremos cortados = madera interior)
for anillo, idx in ((anillos[0], 0), (anillos[-1], SEG_L)):
    centro = bm.verts.new(anillo[0].co.lerp(anillo[LADOS // 2].co, 0.5))
    centro.co.x = anillo[0].co.x  # alinear el centro con el plano del corte
    if idx == 0:
        centro.co.y = sum(v.co.y for v in anillo) / LADOS
        centro.co.z = sum(v.co.z for v in anillo) / LADOS
        fan = [bm.faces.new([centro, anillo[k], anillo[(k + 1) % LADOS]])
               for k in range(LADOS)]
    else:
        centro.co.y = sum(v.co.y for v in anillo) / LADOS
        centro.co.z = sum(v.co.z for v in anillo) / LADOS
        fan = [bm.faces.new([centro, anillo[(k + 1) % LADOS], anillo[k]])
               for k in range(LADOS)]
    for f in fan:
        f.material_index = 1

bm.normal_update()
me = bpy.data.meshes.new('M_Tronco_Caido')
bm.to_mesh(me); bm.free()

tronco = bpy.data.objects.new('SM_Tronco_Caido', me)
escena.collection.objects.link(tronco)
me.materials.append(MAT_corteza)   # index 0
me.materials.append(MAT_madera)    # index 1
tronco.location = (0.0, 0.0, 0.42)
tronco.rotation_euler = Euler((0.0, 0.0, radians(18)), 'XYZ')
bpy.ops.object.select_all(action='DESELECT')
tronco.select_set(True)
bpy.context.view_layer.objects.active = tronco
bpy.ops.object.shade_flat()

# ---------- 5) Muñones de rama (conos) ----------
def crear_munon(idx, pos, largo, radio, rot):
    bpy.ops.mesh.primitive_cone_add(vertices=7, radius1=radio, radius2=radio * 0.35,
                                    depth=largo, location=pos, rotation=rot)
    o = bpy.context.object
    o.name = 'SM_Munon_%d' % idx
    o.data.materials.append(MAT_corteza)
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()

crear_munon(1, (0.55, 0.18, 0.72), 0.62, 0.11, (radians(-52), radians(24), radians(-38)))
crear_munon(2, (-0.62, -0.20, 0.70), 0.50, 0.09, (radians(-48), radians(-18), radians(30)))

# ---------- 6) Raíces expuestas en la base ----------
def crear_raiz(idx, pos, largo, radio, rot):
    # NOTA Blender 4.x: primitive_cylinder_add solo acepta `radius` (sin radius2).
    # Para el afinado usamos primitive_cone_add, que sí tiene radius1/radius2.
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=radio * 0.35, radius2=radio,
                                    depth=largo, location=pos, rotation=rot)
    o = bpy.context.object
    o.name = 'SM_Raiz_%d' % idx
    o.data.materials.append(MAT_corteza)
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()

crear_raiz(1, ( 1.28,  0.05, 0.24), 0.60, 0.12, (radians( 72), 0.0, radians(-12)))
crear_raiz(2, ( 1.20, -0.16, 0.20), 0.48, 0.10, (radians( 78), 0.0, radians( 22)))
crear_raiz(3, (-1.24,  0.10, 0.22), 0.52, 0.11, (radians( 70), 0.0, radians( 16)))

# ---------- 7) Hojarasca (3 placas planas) ----------
for i, (px, py, pz, ry) in enumerate([(0.35, 0.62, 0.03, 20),
                                      (-0.55, -0.58, 0.03, -35),
                                      (1.05, -0.42, 0.03, 60)]):
    bpy.ops.mesh.primitive_cylinder_add(vertices=7, radius=0.16, depth=0.035,
                                        location=(px, py, pz))
    o = bpy.context.object
    o.name = 'SM_Hojarasca_%d' % i
    o.rotation_euler = Euler((0.0, 0.0, radians(ry)), 'XYZ')
    o.data.materials.append(MAT_hojaras)

# ---------- 7b) Autocorreccion de apoyo del tronco + raices (E-12) ----------
# Tronco acostado: tiene raices, muñones, hojarasca alrededor. Asentamos todo
# el conjunto (tronco + raices + muñones + hojarasca) en bloque a z_min=0.045.
bpy.context.view_layer.update()
raices = [o for o in escena.objects if o.type == 'MESH' and
          (o.name.startswith('SM_Tronco_') or o.name.startswith('SM_Raiz_') or
           o.name.startswith('SM_Munon_') or o.name.startswith('SM_Hojarasca_'))]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in raices)
delta = 0.045 - z_min
for o in raices:
    o.location.z += delta
bpy.context.view_layer.update()
print('TRONCO CAIDO asento: z_min %.3f -> 0.045 (delta %+.3f, n=%d)' % (z_min, delta, len(raices)))

# ---------- 8) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.4
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((radians(52), radians(6), radians(32)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 9) Cámara ----------
bpy.ops.object.camera_add(location=(2.4, -3.0, 1.5))
cam = bpy.context.object
cam.name = 'CAM_TroncoCaido'
dir_mira = Vector((0.0, 0.0, 0.45)) - cam.location
cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 10) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '15-Recursos',
                          'tronco_caido_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('TRONCO CAIDO OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
