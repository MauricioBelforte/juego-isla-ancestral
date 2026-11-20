"""Constructor parametrico del crucero M169.

Uso (dentro de Blender):
    ESC = 3.0                      # escala de PLANTA (eslora, manga, separacion de camaras)
    exec(open(r"...\\construir_crucero.py", encoding='utf-8').read())

Diseno:
  - Casco: loft de 13 estaciones (mismas proporciones que el original), escaladas por ESC.
  - 4 cubiertas (forjados de madera, espesor arriba del piso).
  - 3 niveles de superestructura (tubos verticales, sin inclinacion).
  - Ventanas por E-107: se EXTRAEN de la pared (bisecar + desplazar por la normal), nunca se aproximan.
  - Puertas de paseo por raycast contra la pared.
  - Puente, alas, mastil, radar, chimeneas, botes, pileta, jacuzzis, tumbonas, barandas.
  - Z_APOYO = 0.045, un material por pieza, sin texturas.

Las medidas del casco se derivan de ESC; las piezas pequenas (puertas, ventanas, barandas)
mantienen tamano humano para que el barco siga siendo habitable.
"""
import bpy
import bmesh
import math

ESC = 3.2            # escala de PLANTA: 3,2 lineal = 10x superficie por ambiente, 32x volumen
ESP = 0.12           # espesor de forjado
Z_APOYO = 0.045

# ---------------------------------------------------------------- utilidades
def srgb(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def hexcod(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))


def mat(name, hexstr, rough=0.8, metal=0.0):
    m = bpy.data.materials.get(name)
    if m:
        return m
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = next(n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    r, g, bl = hexcod(hexstr)
    b.inputs['Base Color'].default_value = (srgb(r), srgb(g), srgb(bl), 1)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Metallic'].default_value = metal
    m.diffuse_color = (r, g, bl, 1)
    return m


def loft(name, rings, material, cap_bottom=True, cap_top=True):
    bm = bmesh.new()
    vr = [[bm.verts.new(p) for p in ring] for ring in rings]
    n = len(vr[0])
    for a, b in zip(vr[:-1], vr[1:]):
        for i in range(n):
            j = (i + 1) % n
            try:
                bm.faces.new((a[i], a[j], b[j], b[i]))
            except ValueError:
                pass
    if cap_bottom:
        try:
            bm.faces.new(list(reversed(vr[0])))
        except ValueError:
            pass
    if cap_top:
        try:
            bm.faces.new(vr[-1])
        except ValueError:
            pass
    bm.normal_update()
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    me.update()
    ob = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(ob)
    ob.data.materials.append(material)
    return ob


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


def placa(name, cont, z, esp, material):
    bm = bmesh.new()
    inf = [bm.verts.new((x, y, z)) for (x, y) in cont]
    sup = [bm.verts.new((x, y, z + esp)) for (x, y) in cont]
    n = len(inf)
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((inf[i], inf[j], sup[j], sup[i]))
    bm.faces.new(inf)
    bm.faces.new(sup)
    bm.normal_update()
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    me.update()
    ob = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(ob)
    ob.data.materials.append(material)
    return ob


# ---------------------------------------------------------------- limpiar
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
for m in list(bpy.data.meshes):
    if m.users == 0:
        bpy.data.meshes.remove(m)
bpy.context.view_layer.update()

# ---------------------------------------------------------------- materiales
M_CASCO = mat('MAT_Crucero_Casco', '#1B3A5C', 0.55)
M_FRANJA = mat('MAT_Crucero_Franja', '#8C2F39', 0.60)
M_SUPER = mat('MAT_Crucero_Super', '#F5F0E8', 0.80)
M_CUBI = mat('MAT_Crucero_Cubierta', '#B4864B', 0.85)
M_METAL = mat('MAT_Crucero_Metal', '#9EA7AD', 0.35, 0.85)
M_NEGRO = mat('MAT_Crucero_Chimenea', '#22262B', 0.70, 0.30)
M_DORADO = mat('MAT_Crucero_Dorado', '#C9A227', 0.30, 0.90)
M_VIDRIO = mat('MAT_Crucero_Vidrio', '#A8D8E8', 0.08, 0.0)
M_VIDRIOD = mat('MAT_Crucero_VidrioOscuro', '#2C4A5A', 0.12, 0.0)
M_ROJO = mat('MAT_Crucero_Emergencia', '#C0392B', 0.70)
M_MADERA = mat('MAT_Crucero_Madera', '#6B4A2F', 0.80)
M_AGUA = mat('MAT_Crucero_Agua', '#3FA9C9', 0.05, 0.0)
M_BAMBU = mat('MAT_Crucero_Bambu', '#C8A96B', 0.80)

# ---------------------------------------------------------------- dimensiones
HB = 7.0 * ESC                     # media manga maxima del casco
KEEL = Z_APOYO                     # quilla
WL = KEEL + 1.80                   # linea de flotacion
D1 = WL + 2.20                     # cubierta 1 (piso de la superestructura, francobordo alto)
H_CUBIERTA = 5.60                  # altura libre entre cubiertas (techos muy altos)
D2, D3, D4 = D1 + H_CUBIERTA, D1 + 2 * H_CUBIERTA, D1 + 3 * H_CUBIERTA

# estaciones del loft (y en metros, factor de manga) escaladas por ESC
EST_BASE = [(-36.0, 0.12), (-34.0, 0.30), (-31.0, 0.48), (-27.0, 0.62), (-22.0, 0.74),
            (-15.0, 0.84), (-6.0, 0.92), (4.0, 0.96), (14.0, 0.97), (24.0, 0.95),
            (30.0, 0.88), (34.0, 0.74), (36.0, 0.60)]
EST = [(y * ESC, f) for (y, f) in EST_BASE]
Y_BQ, Y_PP = EST[0][0], EST[-1][0]

# niveles de superestructura: (eslora, media manga) escalados
NIVELES = [('1', 33.0 * ESC, 4.45 * ESC, D1, H_CUBIERTA),
           ('2', 30.0 * ESC, 4.30 * ESC, D2, H_CUBIERTA),
           ('3', 26.0 * ESC, 3.90 * ESC, D3, H_CUBIERTA)]

# ---------------------------------------------------------------- casco
def seccion(y, hb, deck):
    pts = [(0.00, y, KEEL), (0.45 * hb, y, KEEL + 0.02), (0.85 * hb, y, KEEL + 0.28),
           (0.98 * hb, y, KEEL + 0.75), (1.00 * hb, y, WL), (0.985 * hb, y, WL + 1.0),
           (0.955 * hb, y, deck - 0.9), (0.930 * hb, y, deck - 0.25), (0.905 * hb, y, deck),
           (0.45 * hb, y, deck), (0.00, y, deck)]
    esq = [(-x, yy, z) for (x, yy, z) in reversed(pts[1:-1])]
    return [(x, yy, z) for (x, yy, z) in pts] + esq


rings = [seccion(y, HB * f, D1) for (y, f) in EST]
loft('SM_Crucero_Casco', rings, M_CASCO, True, True)

# franja de flotacion
banda = [[(1.002 * HB * f, y, WL - 0.30), (1.002 * HB * f, y, WL + 0.10),
          (-1.002 * HB * f, y, WL + 0.10), (-1.002 * HB * f, y, WL - 0.30)] for (y, f) in EST]
loft('SM_Crucero_Franja', banda, M_FRANJA, True, True)

# ---------------------------------------------------------------- niveles (tubos verticales)
def contorno(L, B, n=26):
    """contorno tipo estadio (rectas + arcos): recta de estribor, arco de popa, recta de babor, arco de proa."""
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


for tag, L, B, z0, h in NIVELES:
    c = contorno(L, B)
    bm = bmesh.new()
    inf = [bm.verts.new((x, y, z0)) for (x, y) in c]
    sup = [bm.verts.new((x, y, z0 + h)) for (x, y) in c]
    n = len(inf)
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((inf[i], inf[j], sup[j], sup[i]))
    bm.faces.new(sup)
    bm.normal_update()
    me = bpy.data.meshes.new('SM_Crucero_Nivel_' + tag)
    bm.to_mesh(me)
    bm.free()
    me.update()
    ob = bpy.data.objects.new('SM_Crucero_Nivel_' + tag, me)
    bpy.context.scene.collection.objects.link(ob)
    ob.data.materials.append(M_SUPER)

# ---------------------------------------------------------------- forjados
# cubierta 1: contorno tomado de las MISMAS estaciones del casco (E-24 / leccion del 2026-11-14)
cont1 = [(0.905 * HB * f * 0.99, y) for (y, f) in EST]
cont1 += [(-0.905 * HB * f * 0.99, y) for (y, f) in reversed(EST)]
placa('SM_Crucero_Cubierta_1', cont1, D1, ESP, M_CUBI)

# cubiertas 2-4: contorno del nivel que las sostiene, 1% de holgura
for tag, L, B, z0, h in NIVELES:
    c = [(x * 0.99, y * 0.99) for (x, y) in contorno(L, B)]
    placa('SM_Crucero_Cubierta_' + str(int(tag) + 1), c, z0 + h, ESP, M_CUBI)

print('casco y niveles: eslora %.1f m  manga %.1f m  D1=%.2f D4=%.2f' % (Y_PP - Y_BQ, 2 * HB, D1, D4))