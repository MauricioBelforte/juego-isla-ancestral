"""HY4 Flash - diseno original de buque lowpoly desde cero (M169).
Sin importar .blend de ERNIE. Todo se construye con mallas parametrizadas.
"""
import bpy, math, os, sys
from mathutils import Vector

OUT = sys.argv[sys.argv.index('--') + 1]
os.makedirs(OUT, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene

# ---------------- materiales (paleta propia, sin texturas)
def srgb(v):
    return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4

def mat(tag, hexs, rough=0.82, metal=0.0):
    h = hexs.lstrip('#')
    rgb = [srgb(int(h[i:i+2], 16) / 255) for i in (0, 2, 4)]
    m = bpy.data.materials.new(tag)
    m.diffuse_color = (*rgb, 1)
    m.use_nodes = True
    bs = m.node_tree.nodes.get('Principled BSDF')
    bs.inputs['Base Color'].default_value = (*rgb, 1)
    bs.inputs['Roughness'].default_value = rough
    bs.inputs['Metallic'].default_value = metal
    return m

CASCO   = mat('HY4F_Casco_Azul', '#2E5A73')
FRANJA  = mat('HY4F_Franja_Roja', '#B23A3A')
CUBIERTA= mat('HY4F_Cubierta_Madera', '#9B6A45')
BLANCO  = mat('HY4F_Superestructura', '#E6E1D4')
VENTANA = mat('HY4F_Ventanas', '#214E64', 0.35, 0.25)
BARANDA = mat('HY4F_Barandas', '#C6CBCB', 0.55, 0.4)
BOTE    = mat('HY4F_Botes_Naranja', '#E07C39')
CHIMENEA= mat('HY4F_Chimenea', '#D6D2C6')
NEGRO   = mat('HY4F_Detalle_Negro', '#262C31')
AGUA    = mat('HY4F_Mar', '#1C4A5B', 0.35, 0.1)
ORO     = mat('HY4F_Dorado', '#C7A24B', 0.5, 0.5)

# ---------------- helpers
def box(tag, loc, dim, material, rot=None):
    bpy.ops.mesh.primitive_cube_add(location=loc)
    o = bpy.context.object
    o.name = 'SM_HY4F_' + tag
    o.dimensions = dim
    if rot:
        o.rotation_euler = rot
    o.data.materials.append(material)
    return o

def cyl(tag, loc, radius, depth, material, verts=16, rot=None):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=depth, location=loc)
    o = bpy.context.object
    o.name = 'SM_HY4F_' + tag
    if rot:
        o.rotation_euler = rot
    o.data.materials.append(material)
    return o

# ---------------- casco: loft de 13 estaciones
stations = [-42, -39, -35, -29, -21, -11, 0, 11, 21, 29, 35, 39, 42]
beams    = [0.30, 0.62, 0.82, 0.95, 1.00, 1.00, 1.00, 1.00, 0.97, 0.87, 0.62, 0.32, 0.06]
BMAX = 8.6
verts, faces = [], []
for y, k in zip(stations, beams):
    b = BMAX * k
    ring = [(0, y, -3.4), (b*.52, y, -3.0), (b*.88, y, -1.1),
            (b, y, 0.9), (b*.97, y, 2.9), (0, y, 3.05),
            (-b*.97, y, 2.9), (-b, y, 0.9), (-b*.88, y, -1.1),
            (-b*.52, y, -3.0)]
    verts.extend(ring)
nring = 10
for i in range(len(stations) - 1):
    a, c = i * nring, (i + 1) * nring
    for j in range(nring):
        jn = (j + 1) % nring
        faces.append((a + j, c + j, c + jn, a + jn))
faces.append(tuple(reversed(range(nring))))
faces.append(tuple((len(stations) - 1) * nring + j for j in range(nring)))
me = bpy.data.meshes.new('HY4F_Casco_Mesh')
me.from_pydata(verts, [], faces)
me.update()
hull = bpy.data.objects.new('SM_HY4F_Casco_Loft', me)
sc.collection.objects.link(hull)
me.materials.append(CASCO)

# franja de flotacion CONTINUA, malla siguiendo el loft (no tramos sueltos)
for side in (-1, 1):
    fv, ff = [], []
    for y, k in zip(stations, beams):
        b = BMAX * k * 1.004
        fv.extend([(side*b, y, 0.62), (side*b, y, 1.08)])
    for i in range(len(stations)-1):
        a = 2*i
        ff.append((a, a+2, a+3, a+1))
    fm = bpy.data.meshes.new('HY4F_Franja_Mesh_%s' % side)
    fm.from_pydata(fv, [], ff); fm.update(); fm.materials.append(FRANJA)
    fo = bpy.data.objects.new('SM_HY4F_Franja_Continua_%s' % ('E' if side > 0 else 'O'), fm)
    sc.collection.objects.link(fo)

# ---------------- cubiertas: la principal SIGUE el casco, sin voladizo
dv, df = [], []
for y, k in zip(stations, beams):
    b = BMAX * k * 0.965
    dv.extend([(-b, y, 3.12), (b, y, 3.12)])
for i in range(len(stations)-1):
    a = 2*i
    df.append((a, a+2, a+3, a+1))
dm = bpy.data.meshes.new('HY4F_Cubierta_Principal_Mesh')
dm.from_pydata(dv, [], df); dm.update(); dm.materials.append(CUBIERTA)
do = bpy.data.objects.new('SM_HY4F_Cubierta_Principal_Loft', dm)
sc.collection.objects.link(do)
box('Cubierta_Promenade', (0, 1.5, 6.05), (14.6, 54, 0.24), CUBIERTA)
box('Cubierta_Sol', (0, 3, 9.15), (11.8, 40, 0.22), CUBIERTA)

box('Nivel_1', (0, -1, 4.55), (13.2, 58, 2.9), BLANCO)
box('Nivel_2', (0, 1, 7.55), (11.4, 42, 2.8), BLANCO)
box('Nivel_3_Puente', (0, 4, 10.55), (9.4, 20, 2.7), BLANCO)
box('Techo_Puente', (0, 4, 12.05), (10.2, 21, 0.20), BLANCO)
# alas del puente
box('Ala_Puente_E', (6.2, 5.5, 10.8), (4.0, 6.0, 0.22), BLANCO)
box('Ala_Puente_O', (-6.2, 5.5, 10.8), (4.0, 6.0, 0.22), BLANCO)

# ventanas: tres bandas
for tier, (halfx, y0, y1, z, step) in enumerate([
        (6.65, -28, 26, 5.05, 2.4),
        (5.75, -18, 20, 8.05, 2.4),
        (4.75, -5, 13, 11.05, 2.2)]):
    y = y0
    idx = 0
    while y <= y1:
        for side in (-1, 1):
            box('Ventana_T%d_%s_%02d' % (tier, 'E' if side > 0 else 'O', idx),
                (side * (halfx + 0.06), y, z), (0.10, 1.15, 0.85), VENTANA)
        y += step
        idx += 1

# barandillas de promenade y solario
for name, x, y0, y1, z in [('Prom_E', 8.1, -30, 27, 4.2), ('Prom_O', -8.1, -30, 27, 4.2),
                           ('Sol_E', 5.9, -15, 21, 7.3), ('Sol_O', -5.9, -15, 21, 7.3)]:
    box('Baranda_%s_Topa' % name, (x, (y0+y1)/2, z), (0.10, y1-y0, 0.10), BARANDA)
    box('Baranda_%s_Media' % name, (x, (y0+y1)/2, z-0.45), (0.08, y1-y0, 0.08), BARANDA)
    for i in range(int((y1-y0)/3)+1):
        yy = y0 + i*3
        box('Pilar_%s_%02d' % (name, i), (x, yy, z-0.25), (0.10, 0.10, 0.9), BARANDA)

# botes salvavidas
for side in (-1, 1):
    for i, y in enumerate([-22, -13, -4, 5, 14]):
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=6,
                                             location=(side * 8.7, y, 4.15))
        o = bpy.context.object
        o.name = 'SM_HY4F_Bote_%s_%02d' % ('E' if side > 0 else 'O', i)
        o.scale = (0.80, 2.35, 0.95)
        o.data.materials.append(BOTE)
        box('Pescante_%s_%02d_A' % ('E' if side > 0 else 'O', i),
            (side * 8.2, y-1.5, 5.1), (0.14, 0.14, 1.9), BARANDA)
        box('Pescante_%s_%02d_B' % ('E' if side > 0 else 'O', i),
            (side * 8.2, y+1.5, 5.1), (0.14, 0.14, 1.9), BARANDA)

# chimeneas, mastil, radar
cyl('Chimenea_1', (0, -14, 13.5), 1.75, 5.6, CHIMENEA, 16)
cyl('Chimenea_1_Faja', (0, -14, 15.2), 1.79, 0.8, FRANJA, 16)
cyl('Chimenea_2', (0, -20, 12.6), 1.45, 4.2, CHIMENEA, 16)
cyl('Chimenea_2_Faja', (0, -20, 14.0), 1.49, 0.6, FRANJA, 16)
cyl('Mastil', (0, 10, 16.5), 0.22, 8.5, BARANDA, 10)
box('Radar_Barra', (0, 10, 20.6), (6.0, 0.35, 0.22), BARANDA)
cyl('Radar_Disco', (0, 10, 21.0), 1.6, 0.18, BLANCO, 20)
box('Proa_Dorada', (0, 41.0, 2.9), (0.5, 1.6, 0.55), ORO)
box('Popa_Nombre', (0, -42.3, 2.4), (4.2, 0.12, 0.8), ORO)

# mar de contexto
box('Mar', (0, 0, -3.6), (520, 520, 0.12), AGUA)

# ---------------- luz y camaras
def area(tag, loc, energy, size):
    d = bpy.data.lights.new(tag, 'AREA'); d.energy = energy; d.shape = 'DISK'; d.size = size
    o = bpy.data.objects.new(tag, d); sc.collection.objects.link(o); o.location = loc
    o.rotation_euler = (Vector((0, 0, 5)) - o.location).to_track_quat('-Z', 'Y').to_euler()

area('HY4F_Sol_Area', (45, -35, 60), 260000, 30)
area('HY4F_Relleno', (-50, 25, 35), 90000, 25)
sun = bpy.data.lights.new('HY4F_Sol_Dir', 'SUN'); sun.energy = 2.2
so = bpy.data.objects.new('HY4F_Sol_Dir', sun); sc.collection.objects.link(so)
so.rotation_euler = (math.radians(35), math.radians(-25), math.radians(20))

w = bpy.data.worlds.new('HY4F_Cielo'); sc.world = w; w.use_nodes = True
bg = w.node_tree.nodes.get('Background')
bg.inputs['Color'].default_value = (0.22, 0.31, 0.38, 1)
bg.inputs['Strength'].default_value = 0.85

def camera(tag, typ, lens=35, ortho=None):
    d = bpy.data.cameras.new(tag); d.type = typ
    if typ == 'ORTHO': d.ortho_scale = ortho
    else: d.lens = lens
    o = bpy.data.objects.new(tag, d); sc.collection.objects.link(o); return o

views = [
    ('tres_cuartos', camera('HY4F_Cam_3_4', 'PERSP', lens=38), (82, 88, 46), (0, 4, 7)),
    ('perfil', camera('HY4F_Cam_Perfil', 'PERSP', lens=42), (130, -4, 18), (0, 0, 7)),
    ('cenital', camera('HY4F_Cam_Cenital', 'ORTHO', ortho=175), (0, 0, 150), (0, 0, 0)),
    ('proa', camera('HY4F_Cam_Proa', 'PERSP', lens=38), (34, 105, 26), (0, 10, 7)),
]
sc.render.engine = 'BLENDER_EEVEE_NEXT'
sc.render.resolution_x = 1280
sc.render.resolution_y = 720
sc.render.resolution_percentage = 100
sc.render.image_settings.file_format = 'PNG'
for name, cam, loc, tgt in views:
    cam.location = loc
    up = 'X' if name == 'cenital' else 'Y'
    cam.rotation_euler = (Vector(tgt) - cam.location).to_track_quat('-Z', up).to_euler()
    sc.camera = cam
    sc.render.filepath = os.path.join(OUT, 'buque_HY4F_%s.png' % name)
    bpy.ops.render.render(write_still=True)
    print('VIEW', name, os.path.getsize(sc.render.filepath))

sc.camera = views[0][1]
blend = os.path.join(OUT, 'buque_HY4F_concepto_v1.blend')
bpy.ops.wm.save_as_mainfile(filepath=blend)
print('SAVED', os.path.basename(blend), 'OBJECTS', len(bpy.data.objects))
