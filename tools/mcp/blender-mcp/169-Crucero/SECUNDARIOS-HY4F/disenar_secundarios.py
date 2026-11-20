"""HY4 Flash - diseno/correccion sobre copias secundarias M169.
Anade rig de captura corregido + geometria de apoyo en bodega y casino.
"""
import bpy, sys, os
from mathutils import Vector

argv = sys.argv[sys.argv.index('--') + 1:]
src, outdir = argv[0], argv[1]
os.makedirs(outdir, exist_ok=True)
name = os.path.basename(src).replace('.blend', '')
bpy.ops.wm.open_mainfile(filepath=src)
s = bpy.context.scene

def bounds(objs):
    pts = []
    for o in objs:
        if o.type == 'MESH':
            pts += [o.matrix_world @ Vector(c) for c in o.bound_box]
    lo = [min(p[i] for p in pts) for i in range(3)]
    hi = [max(p[i] for p in pts) for i in range(3)]
    return lo, hi

meshes = [o for o in bpy.data.objects if o.type == 'MESH']
floors = [o for o in meshes if 'Piso' in o.name]
ceil = [o for o in meshes if 'Techo' in o.name]
walls = [o for o in meshes if 'Pared' in o.name]
lo, hi = bounds(floors)
w, d = hi[0] - lo[0], hi[1] - lo[1]
cx, cy = (lo[0] + hi[0]) / 2, (lo[1] + hi[1]) / 2
ch = bounds(ceil)[1][2] if ceil else hi[2] + 2.5
base_floor = lo[2]

def material(tag, rgb):
    m = bpy.data.materials.get(tag)
    if m:
        return m
    m = bpy.data.materials.new(tag)
    m.diffuse_color = (*rgb, 1)
    m.use_nodes = True
    bs = m.node_tree.nodes.get('Principled BSDF')
    if bs:
        bs.inputs['Base Color'].default_value = (*rgb, 1)
        bs.inputs['Roughness'].default_value = 0.85
    return m

MADERA = material('HY4F_Madera_Clara', (0.62, 0.40, 0.28))
CARTON = material('HY4F_Carton', (0.72, 0.52, 0.34))
CINCHA = material('HY4F_Cincha', (0.25, 0.22, 0.20))
AZUL = material('HY4F_Pantalla', (0.30, 0.55, 0.72))
GRIS = material('HY4F_Metal', (0.42, 0.45, 0.48))
ROJO = material('HY4F_Slot_Rojo', (0.62, 0.20, 0.24))

def box(tag, loc, size, mat):
    bpy.ops.mesh.primitive_cube_add(location=loc)
    o = bpy.context.object
    o.name = tag
    o.dimensions = size
    o.data.materials.append(mat)
    return o

added = []
if 'bodega' in name:
    # Estibaje: bloques de cajas a ambos lados, pasillo central libre
    for side in (-1, 1):
        for i, y in enumerate([-24, -15, -6, 3, 12, 21]):
            x = side * (w / 2 - 1.5)
            for level in range(2 if i % 2 == 0 else 1):
                z = base_floor + 0.45 + level * 0.9
                c = box('SM_HY4F_Caja_%s_%02d_%d' % ('E' if side > 0 else 'O', i, level),
                        (x, y, z), (1.5, 2.2, 0.85), CARTON if level == 0 else MADERA)
                c.rotation_euler.z = 0.02 * (i % 3 - 1)
                added.append(c)
                tapa = box('SM_HY4F_Caja_Tapa_%s_%02d_%d' % ('E' if side > 0 else 'O', i, level),
                           (x, y, z + 0.45), (1.55, 2.25, 0.06), CINCHA)
                added.append(tapa)
    for side in (-1, 1):
        for i, y in enumerate([-19, -10, 8, 17]):
            x = side * (w / 2 - 0.7)
            bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.42, depth=0.9,
                                                location=(x, y, base_floor + 0.5))
            o = bpy.context.object
            o.name = 'SM_HY4F_Barril_%s_%02d' % ('E' if side > 0 else 'O', i)
            o.data.materials.append(MADERA)
            added.append(o)
    # Senalizacion de pasillo
    for i in range(20):
        y = lo[1] + 1.5 + i * (d - 3) / 19
        added.append(box('SM_HY4F_Senal_%02d' % i, (cx, y, base_floor + 0.02),
                         (0.18, 0.55, 0.02), CINCHA))

if 'casino' in name:
    # Filas de tragamonedas contra la pared Oeste, mirando al pasillo
    for i, y in enumerate([-8, -4.5, -1, 2.5, 6, 9.5]):
        x = lo[0] + 0.55
        added.append(box('SM_HY4F_Slot_%02d_Cuerpo' % i, (x, y, base_floor + 0.95),
                         (0.85, 0.75, 1.8), ROJO))
        added.append(box('SM_HY4F_Slot_%02d_Pantalla' % i, (x + 0.45, y, base_floor + 1.4),
                         (0.06, 0.55, 0.55), AZUL))
        added.append(box('SM_HY4F_Slot_%02d_Pedestal' % i, (x, y, base_floor + 0.12),
                         (0.95, 0.85, 0.22), GRIS))

# Luces: menos energia que en el corte para no quemar la cenital
def area(loc, energy, size, tag):
    data = bpy.data.lights.new(tag, 'AREA')
    data.energy = energy
    data.shape = 'DISK'
    data.size = size
    o = bpy.data.objects.new(tag, data)
    s.collection.objects.link(o)
    o.location = loc
    o.rotation_euler = (Vector((cx, cy, 0.8)) - o.location).to_track_quat('-Z', 'Y').to_euler()
    return o

lights = []
n = max(2, min(8, int(d / 6) + 1))
for i in range(n):
    y = lo[1] + d * (i + 0.5) / n
    lights.append(area((cx, y, ch - 0.4), 420 * max(1.0, w / 3.0), 2.6, 'HY4F_Luz_%02d' % i))

world = s.world or bpy.data.worlds.new('HY4F_World')
s.world = world
world.use_nodes = True
bg = world.node_tree.nodes.get('Background')
bg.inputs['Color'].default_value = (0.30, 0.33, 0.37, 1)
bg.inputs['Strength'].default_value = 0.55

def mkcam(tag, typ, **kw):
    data = bpy.data.cameras.new(tag)
    data.type = typ
    if typ == 'ORTHO':
        data.ortho_scale = kw['ortho']
    else:
        data.lens = kw['lens']
    o = bpy.data.objects.new(tag, data)
    s.collection.objects.link(o)
    return o

cut = mkcam('HY4F_Cam_Corte', 'PERSP', lens=32)
cut.location = (hi[0] + w * 0.55 + 1.0, cy - d * 0.12, ch + 0.9)
cut.rotation_euler = (Vector((cx, cy, 0.9)) - cut.location).to_track_quat('-Z', 'Y').to_euler()

# Cenital: eje largo va HORIZONTAL (up='X') y escala calculada para que quepa
top = mkcam('HY4F_Cam_Cenital', 'ORTHO', ortho=max(d * 1.12, w * 1.9))
top.location = (cx, cy, ch + 5)
up = 'X' if d > w else 'Y'
top.rotation_euler = (Vector((cx, cy, 0)) - top.location).to_track_quat('-Z', up).to_euler()

s.render.engine = 'BLENDER_EEVEE_NEXT'
s.render.resolution_x = 1200
s.render.resolution_y = 700
s.render.resolution_percentage = 100
s.render.image_settings.file_format = 'PNG'

wall_x = [o for o in walls if any(k in o.name for k in ['_E', '_Der'])]
for view, camera, hide in [('corte', cut, True), ('cenital', top, False)]:
    for o in ceil + (wall_x if hide else []):
        o.hide_render = True
    # cenital mas tenue
    old = [l.data.energy for l in lights]
    if view == 'cenital':
        for l in lights:
            l.data.energy = old[0] * 0.18
    s.camera = camera
    s.render.filepath = os.path.join(outdir, '%s_%s.png' % (name, view))
    bpy.ops.render.render(write_still=True)
    print('VIEW', view, os.path.getsize(s.render.filepath))
    for l, e in zip(lights, old):
        l.data.energy = e
    for o in ceil + wall_x:
        o.hide_render = False

s.camera = cut
dst = os.path.join(outdir, name + '_HY4F_diseno.blend')
bpy.ops.wm.save_as_mainfile(filepath=dst)
print('RESULT', name, 'added', len(added), 'lights', len(lights), 'saved', os.path.basename(dst))
