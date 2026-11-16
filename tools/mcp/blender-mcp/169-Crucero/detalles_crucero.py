"""Detalles del crucero M169 (segunda pasada): ventanas E-107, puertas, puente, chimeneas,
barandas, botes, pileta. Se ejecuta DESPUES de construir_crucero.py.

Las piezas chicas (puertas, ventanas, barandas) mantienen tamano humano; solo la planta
escala con ESC.
"""
import bpy
import bmesh
import math

# ------------------------------------------------------------------ helpers
def bb(o):
    dg = bpy.context.evaluated_depsgraph_get()
    dg.update()
    oe = o.evaluated_get(dg)
    me = oe.to_mesh()
    mw = oe.matrix_world
    vs = [mw @ v.co for v in me.vertices]
    oe.to_mesh_clear()
    return (min(v.x for v in vs), max(v.x for v in vs), min(v.y for v in vs),
            max(v.y for v in vs), min(v.z for v in vs), max(v.z for v in vs))


def mat_get(n):
    return bpy.data.materials[n]


def contorno(L, B, n=26):
    pts = []
    r = B
    rect = L / 2 - r
    for i in range(n):
        t = i / (n - 1)
        pts.append((B, -rect + t * 2 * rect))
    for i in range(1, n):
        a = (math.pi / 2) * i / (n - 1)
        pts.append((B * math.cos(a), rect + r * math.sin(a)))
    for i in range(n):
        t = i / (n - 1)
        pts.append((-B, rect - t * 2 * rect))
    for i in range(1, n):
        a = (math.pi / 2) * i / (n - 1)
        pts.append((-B * math.cos(a), -rect - r * math.sin(a)))
    return pts


def caja(name, x0, x1, y0, y1, z0, z1, material):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x = x0 if v.co.x < 0 else x1
        v.co.y = y0 if v.co.y < 0 else y1
        v.co.z = z0 if v.co.z < 0 else z1
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    me.update()
    ob = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(ob)
    ob.data.materials.append(material)
    return ob


# ------------------------------------------------------------------ ventanas E-107
M_VIDRIO = mat_get('MAT_Crucero_Vidrio')
Z0_OFF, H_WIN, OFF = 0.95, 2.20, 0.030

for tag in ('1', '2', '3'):
    nivel = bpy.data.objects['SM_Crucero_Nivel_' + tag]
    z0b = bb(nivel)[4]
    z0, z1 = z0b + Z0_OFF, z0b + Z0_OFF + H_WIN
    bm = bmesh.new()
    bm.from_mesh(nivel.data)
    g = bm.verts[:] + bm.edges[:] + bm.faces[:]
    bmesh.ops.bisect_plane(bm, geom=g, plane_co=(0, 0, z0), plane_no=(0, 0, 1))
    g = bm.verts[:] + bm.edges[:] + bm.faces[:]
    bmesh.ops.bisect_plane(bm, geom=g, plane_co=(0, 0, z1), plane_no=(0, 0, 1))
    kill = [f for f in bm.faces
            if f.calc_center_median().z < z0 - 1e-4 or f.calc_center_median().z > z1 + 1e-4]
    bmesh.ops.delete(bm, geom=kill, context='FACES')
    # separar en ventanas con paso angular
    paso = 2 * math.pi / (24 if tag == '1' else (20 if tag == '2' else 17))
    ancho = paso * 0.64
    keep = []
    for f in bm.faces:
        c = f.calc_center_median()
        if tag == '1' and abs(c.y) < 10.8 * 3.2:      # nivel 1: los costados son puertas
            continue
        a = math.atan2(c.y, c.x) % (2 * math.pi)
        if (a % paso) < ancho:
            keep.append(f)
    bmesh.ops.delete(bm, geom=[f for f in bm.faces if f not in keep], context='FACES')
    bm.normal_update()
    for v in bm.verts:
        v.co += v.normal * OFF
    me = bpy.data.meshes.new('SM_Crucero_Ventanas_' + tag)
    bm.to_mesh(me)
    bm.free()
    me.update()
    ob = bpy.data.objects.new('SM_Crucero_Ventanas_' + tag, me)
    bpy.context.scene.collection.objects.link(ob)
    ob.data.materials.append(M_VIDRIO)

# ------------------------------------------------------------------ puertas de paseo (raycast)
n1 = bpy.data.objects['SM_Crucero_Nivel_1']
invi = n1.matrix_world.inverted()
ZB1 = bb(n1)[4]
M_VIDRIOD = mat_get('MAT_Crucero_VidrioOscuro')
Y_PUERTAS = [-8.4 * 3.2, -5.2 * 3.2, -2.0 * 3.2, 2.0 * 3.2, 5.2 * 3.2, 8.4 * 3.2]

for i, y in enumerate(Y_PUERTAS):
    for sx, tag in ((1, 'E'), (-1, 'B')):
        o = invi @ __import__('mathutils').Vector((sx * 60.0, y, ZB1 + 1.60))
        d = (invi.to_3x3() @ __import__('mathutils').Vector((-sx, 0.0, 0.0))).normalized()
        ok, loc, nor, idx = n1.ray_cast(o, d)
        if not ok:
            continue
        p = n1.matrix_world @ loc
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x = v.co.x * 0.07 + (p.x + sx * 0.05)
            v.co.y = v.co.y * 1.60 + y
            v.co.z = v.co.z * 2.05 + ZB1 + 1.05
        me = bpy.data.meshes.new('SM_Crucero_Puerta_Paseo_%s%d' % (tag, i + 1))
        bm.to_mesh(me)
        bm.free()
        me.update()
        ob = bpy.data.objects.new('SM_Crucero_Puerta_Paseo_%s%d' % (tag, i + 1), me)
        bpy.context.scene.collection.objects.link(ob)
        ob.data.materials.append(M_VIDRIOD)

print('ventanas y puertas: ok')

# ------------------------------------------------------------------ chimeneas
M_NEGRO = mat_get('MAT_Crucero_Chimenea')
M_DORADO = mat_get('MAT_Crucero_Dorado')
D4 = bb(bpy.data.objects['SM_Crucero_Cubierta_4'])[4]
R_CHIM = 1.45 * 3.2

for i, y in enumerate((-6.0 * 3.2, 6.0 * 3.2)):
    rings = []
    for (z, f) in [(D4, 1.0), (D4 + 2.6, 0.97), (D4 + 3.4, 0.92)]:
        ring = []
        for k in range(12):
            a = 2 * math.pi * k / 12
            ring.append((R_CHIM * f * math.cos(a), y + R_CHIM * 0.78 * f * math.sin(a), z))
        rings.append(ring)
    bm = bmesh.new()
    vr = [[bm.verts.new(p) for p in ring] for ring in rings]
    for a, b in zip(vr[:-1], vr[1:]):
        for k in range(12):
            j = (k + 1) % 12
            bm.faces.new((a[k], a[j], b[j], b[k]))
    bm.faces.new(list(reversed(vr[0])))
    bm.faces.new(vr[-1])
    bm.normal_update()
    me = bpy.data.meshes.new('SM_Crucero_Chimenea_%d' % (i + 1))
    bm.to_mesh(me)
    bm.free()
    me.update()
    ob = bpy.data.objects.new('SM_Crucero_Chimenea_%d' % (i + 1), me)
    bpy.context.scene.collection.objects.link(ob)
    ob.data.materials.append(M_NEGRO)

print('chimeneas: ok  (D4=%.2f)' % D4)
print('objetos:', len([o for o in bpy.data.objects if o.type == 'MESH']),
      ' verts:', sum(len(o.data.vertices) for o in bpy.data.objects if o.type == 'MESH'))