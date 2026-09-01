# crear_arbol_frutal_lowpoly.py — Arbol frutal (M50-Vegetacion) — Tier F
# Checklist: "Árbol frutal (mango/coco según lore)"
#
# DECISION DE DISENO (especie):
#   El lore NO fija la especie. El catalogo (33-Agricultura 03-Diseno.md §`is_tree`)
#   solo dice "Árbol frutal (perenne, no requiere replantar)" y menciona "coco",
#   pero el coco ya esta cubierto por la `palmera` de M50. Repetirlo daria dos
#   assets identicos en silueta. Se modela entonces un FRUTAL DE COPA ANCHA
#   (frondosa, no palmera) con fruto tropical generico amarillo-naranja: es la
#   silueta complementaria y la que el jugador distingue de la palmera a distancia.
#   Si mas adelante el lore fija otra especie, cambiar MAT_fruto y la escala de
#   los frutos alcanza — la estructura (tronco + copa + frutos) no cambia.
#
# Composicion: 1 tronco conico + 4 raices de anclaje en la base + 3 ico-esferas
# de copa + 6 frutos ovalados colgando del borde inferior de la copa.
# Las raices NO son decorativas: ensanchan la huella de apoyo para que el ojo
# lea el tronco plantado y no apoyado en punta (E-50).
import bpy
import os
from math import radians, cos, sin, pi
from mathutils import Vector, Euler

# ---------- 1) Limpieza idempotente (E-05) ----------
for _obj in list(bpy.data.objects):
    bpy.data.objects.remove(_obj, do_unlink=True)
for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                bpy.data.cameras, bpy.data.worlds):
    for _dato in list(_bloque):
        if _dato.users == 0:
            _bloque.remove(_dato)
escena = bpy.context.scene

# ---------- 2) Materiales ----------
def crear_mat(nombre, color, rough=0.85, spec=0.10, emis=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    if emis > 0.0:
        b.inputs['Emission Strength'].default_value = emis
        b.inputs['Emission Color'].default_value = (*color, 1.0)
    return m

MAT_corteza = crear_mat('MAT_Frutal_Corteza', (0.36, 0.25, 0.15), rough=0.95)
MAT_hoja    = crear_mat('MAT_Frutal_Hoja',    (0.22, 0.52, 0.17), rough=0.85)
MAT_hoja2   = crear_mat('MAT_Frutal_HojaClr', (0.32, 0.62, 0.20), rough=0.85)
MAT_fruto   = crear_mat('MAT_Frutal_Fruto',   (0.98, 0.68, 0.16), rough=0.55, spec=0.35)
MAT_arena   = crear_mat('MAT_Arena_Isla',     (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena (set de captura, NO se exporta — E-44) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.22,
                                    location=(0, 0, -0.11))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Faldon de raices (ensancha la huella de apoyo, E-50) ----------
# El tronco solo no basta: apoyaria en su circunferencia de 0.19 de radio y el
# conjunto se leeria "clavado" en vez de plantado. Este cono ensancha la huella.
# REGLA DE ORO DE ESTE SCRIPT (aprendida por bug propio, ver §9): TODA pieza de
# apoyo se construye con su generatriz inferior EXACTAMENTE en z = 0. Si una
# sola pieza rota hunde su vertice mas bajo por debajo de las demas, el
# re-asentado la toma como referencia, eleva el grupo y deja FLOTANDO al tronco.
# Version 1 de este script inclinaba las raices 62°: bajaban a -0.0807, el grupo
# subia +0.1257 y el tronco quedaba 12.5 cm en el aire. El assert lo atrapo.
FALDON_ALTO = 0.34
FALDON_R_BASE = 0.36
FALDON_R_TOP = 0.19
bpy.ops.mesh.primitive_cone_add(vertices=10, radius1=FALDON_R_BASE,
                                radius2=FALDON_R_TOP, depth=FALDON_ALTO,
                                location=(0, 0, FALDON_ALTO / 2))
faldon = bpy.context.object
faldon.name = 'SM_Frutal_Faldon'
faldon.data.materials.append(MAT_corteza)

# ---------- 5) Raices horizontales de anclaje ----------
# Conos ACOSTADOS (eje del cono rotado 90° sobre Y para apuntar hacia afuera) y
# centrados en z = RAIZ_R, de modo que su generatriz inferior queda en z = 0 por
# construccion. El extremo grueso (radius1) queda hacia el tronco y la punta
# hacia afuera, que es como se lee una raiz.
# Acostarlos en vez de inclinarlos es lo que evita el bug de la v1: una pieza
# acostada sobre un eje principal tiene su cota inferior exacta y previsible,
# mientras que una inclinada a 62° mezcla las tres componentes del vertice.
N_RAIZ = 4
RAIZ_R = 0.085
RAIZ_L = 0.40
RAIZ_D = 0.42
for i in range(N_RAIZ):
    ang = i * (2 * pi / N_RAIZ) + radians(25)
    lx, ly = cos(ang) * RAIZ_D, sin(ang) * RAIZ_D
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=RAIZ_R, radius2=0.0,
                                    depth=RAIZ_L, location=(lx, ly, RAIZ_R))
    r = bpy.context.object
    r.name = 'SM_Frutal_Raiz_%d' % i
    # Euler XYZ: Ry(90°) voltea el eje +Z a +X, y Rz(ang) lo gira al azimut.
    r.rotation_euler = (0.0, radians(90), ang)
    bpy.context.view_layer.update()
    r.data.materials.append(MAT_corteza)

# ---------- 6) Tronco ----------
# Apoya SOBRE el faldon: su base arranca en z = FALDON_ALTO y su radio inferior
# coincide con FALDON_R_TOP para que no haya escalon.
ALTURA_TRONCO = 2.30
bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=FALDON_R_TOP, radius2=0.13,
                                depth=ALTURA_TRONCO,
                                location=(0, 0, FALDON_ALTO + ALTURA_TRONCO / 2))
tronco = bpy.context.object
tronco.name = 'SM_Frutal_Tronco'
tronco.data.materials.append(MAT_corteza)
TOP_TRONCO = FALDON_ALTO + ALTURA_TRONCO      # 2.64

# ---------- 7) Copa: 3 ico-esferas solapadas ----------
# Solaparlas evita que se vean tres pelotas separadas; con flat shading el
# conjunto lee como una masa de follaje facetada.
COPA = (
    # (x,     y,     z,    radio, material)
    (0.00,  0.00,  3.00, 0.88, MAT_hoja),
    (0.52,  0.34,  2.62, 0.60, MAT_hoja2),
    (-0.48, -0.30, 2.66, 0.56, MAT_hoja2),
)
for i, (x, y, z, rad, mat) in enumerate(COPA):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=rad,
                                          location=(x, y, z))
    c = bpy.context.object
    c.name = 'SM_Frutal_Copa_%d' % i
    c.data.materials.append(mat)

# ---------- 8) Frutos colgando del borde inferior de la copa ----------
# Ubicados en el ecuador inferior de la copa principal (z ~ 2.3-2.8) para que se
# vean desde abajo sin quedar ocultos por el follaje.
FRUTOS = (
    (0.62,  0.10, 2.40),
    (-0.30, 0.58, 2.28),
    (-0.58, -0.28, 2.46),
    (0.18,  -0.62, 2.34),
    (0.72,  0.52, 2.74),
    (-0.66, 0.34, 2.78),
)
for i, (x, y, z) in enumerate(FRUTOS):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.105,
                                          location=(x, y, z))
    f = bpy.context.object
    f.name = 'SM_Frutal_Fruto_%d' % i
    f.scale = (0.85, 0.85, 1.30)          # ovalo vertical, silueta de fruta
    f.rotation_euler = (0.0, 0.0, radians(i * 37))
    bpy.context.view_layer.update()
    bpy.ops.object.select_all(action='DESELECT')
    f.select_set(True)
    bpy.context.view_layer.objects.active = f
    bpy.ops.object.transform_apply(scale=True, rotation=True)
    f.data.materials.append(MAT_fruto)

# ---------- 8) Iluminacion + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.0
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((radians(52), radians(6), radians(32)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 9) Asentado (E-12 + E-24): medir en caliente, nunca estimar -------
# El apoyo se MIDE sobre la geometria ya generada (E-09). Se usa el vertice real
# mas bajo y NO el AABB: las raices estan ROTADAS y su bound_box tiene esquinas
# vacias que harian creer que estan hundidas (E-24). Objetivo z_min = 0.045
# (5 mm bajo el tope de arena z = 0.05).
Z_APOYO = 0.045
bpy.context.view_layer.update()

def zmin_real(o):
    if len(o.data.vertices) == 0:
        return min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
    return min((o.matrix_world @ v.co).z for v in o.data.vertices)

piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_')]
z_ini = min(zmin_real(o) for o in piezas)
delta = Z_APOYO - z_ini
for o in piezas:
    if o.parent is None:
        o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(zmin_real(o) for o in piezas)
print('ASENTADO: z_min %.4f -> %.4f (delta %+.4f)' % (z_ini, z_fin, delta))

# Anti-regresion: si esto salta, el asset flota o se hunde.
assert abs(z_fin - Z_APOYO) < 1e-4, 'z_min %.4f != Z_APOYO %.4f' % (z_fin, Z_APOYO)

# La pieza que toca el suelo tiene que ser el FALDON (la base ancha), no una
# raiz fina. El tronco apoya SOBRE el faldon, asi que su z es mayor y esta bien
# que lo sea: no confundir "el tronco no toca la arena" con "el tronco flota".
z_faldon = zmin_real(faldon)
assert abs(z_faldon - Z_APOYO) < 1e-3, \
    'el faldon no apoya (z=%.4f) -> la base ancha no toca el suelo' % z_faldon

# Guarda E-50 (apoyo puntual): z_min correcto con 1 solo vertice tocando no
# alcanza — el ojo lo lee flotando. Hay que medir la HUELLA: cuantos vertices
# tocan y cuanto abarcan en XY.
TOL = 0.005
pts = []
for o in piezas:
    for v in o.data.vertices:
        w = o.matrix_world @ v.co
        if abs(w.z - Z_APOYO) < TOL:
            pts.append(w)
xs = [p.x for p in pts]
ys = [p.y for p in pts]
fp_x = max(xs) - min(xs) if xs else 0.0
fp_y = max(ys) - min(ys) if ys else 0.0
print('HUELLA: toca=%d  footprint=%.2f x %.2f' % (len(pts), fp_x, fp_y))
assert len(pts) >= 8, 'apoyo puntual: solo %d verts tocan el suelo (E-50)' % len(pts)
assert min(fp_x, fp_y) > 0.30, \
    ('huella demasiado chica %.2fx%.2f -> se leeria apoyado en punta (E-50)'
     % (fp_x, fp_y))

# ---------- 10) Camara ----------
bpy.ops.object.camera_add(location=(3.2, -3.8, 2.2))
cam = bpy.context.object
cam.name = 'CAM_ArbolFrutal'
cam.rotation_euler = (Vector((0, 0, 1.9)) - cam.location).to_track_quat('-Z', 'Y').to_euler()
escena.camera = cam

# ---------- 11) Flat shading ----------
for ob in escena.objects:
    ob.select_set(True)
bpy.context.view_layer.objects.active = tronco
bpy.ops.object.shade_flat()

# ---------- 12) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'arbol_frutal_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
# E-21: save_as_mainfile falla con "Unable to make version backup" si existe el @
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_sm = len([o for o in bpy.data.objects if o.name.startswith('SM_')])
print('ARBOL FRUTAL OK — SM_: %d — blend: %s' % (n_sm, ruta_blend))
