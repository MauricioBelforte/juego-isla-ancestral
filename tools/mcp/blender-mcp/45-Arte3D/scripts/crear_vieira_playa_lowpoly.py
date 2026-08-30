# crear_vieira_playa_lowpoly.py — Vieira / concha abanico (M45-Arte3D)
# Checklist: "Conchas y caracoles adicionales (M45)"
#
# Vieira (concha de Santiago) clavada de canto en la arena: bisagra abajo,
# abanico abierto hacia arriba. Se distingue de `concha_mar` (que es una
# caracola ESPIRAL acostada) en que acá la silueta es un ABANICO con
# costillas radiales y dos aurículas (orejitas) junto a la bisagra.
#
# Todo en UNA sola malla bmesh con UN solo objeto (E-01: mínima cantidad de
# mallas / draw calls). Geometría con GROSOR real (capa externa + capa
# interna + borde perimetral), para que se vea sólida desde cualquier ángulo
# y no haga falta material de doble cara (que Godot no trae gratis).
#
# Lecciones aplicadas:
#   E-01  una sola malla y un solo objeto, no primitivas apiladas
#   E-12  asentado MEDIDO en caliente (no calculado del espesor nominal)
#   E-16  winding invertido en tapas/cierres
#   E-21  borrar el .blend@ antes de save_as_mainfile
#   E-27  sin matrix_parent_inverse a mano (no hay parenting acá, queda
#         documentado por si alguien agrega piezas hijas después)
#   E-32  el winding derivado a mano es FRÁGIL (ver abajo)
#
# ---------------------------------------------------------------------------
# E-32 — no deducir el winding "a mano"
# ---------------------------------------------------------------------------
# La v1 de este script elegía el orden de los vértices de cada cara a partir
# de un producto vectorial hecho en el papel. Dos de las tres familias de
# caras quedaron invertidas (capa exterior apuntando a +X y capa interior a
# -X) y el error no se veía hasta renderizar. En vez de "pensar mejor" el
# orden, la v2 delega: crea las caras en cualquier orden, unifica la isla con
# `bmesh.ops.recalc_face_normals` y después corrige la orientación GLOBAL con
# una sola comprobación medible (¿la capa externa mira a -X?). Regla:
#   - isla cerrada y conexa  -> recalc + reverse_faces global si hace falta
#   - isla cerrada y convexa (cuña/tubo) -> recalc + test centroide
# Nunca deducir el winding a mano cuando se puede medir.
# ---------------------------------------------------------------------------
import bpy
import bmesh
import os
import math
from mathutils import Vector, Euler

# ---------- 1) Limpieza (E-14: NUNCA wm.read_factory_settings por socket) ----------
for _obj in list(bpy.data.objects):
    bpy.data.objects.remove(_obj, do_unlink=True)
for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                bpy.data.cameras, bpy.data.worlds):
    for _dato in list(_bloque):
        if _dato.users == 0:
            _bloque.remove(_dato)
escena = bpy.context.scene

# ---------- 2) Materiales ----------
def crear_mat(nombre, color, rough=0.85, spec=0.20, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

# Cara externa: crema arenosa, mate (la concha está a la intemperie).
MAT_exterior = crear_mat('MAT_Vieira_Exterior', (0.88, 0.74, 0.62), rough=0.82, spec=0.25)
# Cara interna: nacarada, más clara y más brillante (es lo que se ve "adentro").
MAT_interior = crear_mat('MAT_Vieira_Interior', (0.97, 0.90, 0.84), rough=0.35, spec=0.75)
# Bisagra: el ligamento oscuro que une las dos valvas.
MAT_bisagra  = crear_mat('MAT_Vieira_Bisagra',  (0.42, 0.30, 0.24), rough=0.90)
MAT_arena    = crear_mat('MAT_Arena_Isla',      (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.2, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Parámetros de la vieira ----------
R_MAX     = 0.150   # radio del arco EXTERIOR (borde del abanico)
R_MIN     = 0.035   # radio del arco INTERIOR (linea de bisagra).
                    # > 0 es OBLIGATORIO: con R_MIN = 0 los N_ANG+1 vertices
                    # del arco interior colapsan en un mismo punto (r = 0) y
                    # se generan caras degeneradas de area cero.
TH_MIN    = math.radians(-78.0)   # apertura angular del abanico
TH_MAX    = math.radians(78.0)
N_RAD     = 7       # divisiones radiales (bisagra -> borde)
N_ANG     = 28      # divisiones angulares
N_COST    = 6       # cos(N_COST*pi*u) -> 3 periodos -> 4 crestas visibles
AMP_COST  = 0.013   # profundidad del relieve de cada costilla
ESPESOR   = 0.020   # grosor de la valva (concha con cuerpo, no un papel)
Z_BASE    = 0.030   # altura del CENTRO de la bisagra sobre el origen local

# Extremo de la linea de bisagra (de donde arrancan las auriculas).
Y_HINGE = R_MIN * math.sin(TH_MAX)
Z_HINGE = Z_BASE + R_MIN * math.cos(TH_MAX)

# ---------- 5) Rejilla de vertices (dos capas: externa e interna) ----------
# El abanico vive en el plano Y-Z (la concha esta "de canto", mirando a +-X).
#   th = 0      -> arriba (borde superior del abanico)
#   th = +-78   -> los dos bordes laterales
# El relieve de las costillas modula X: es 0 en la bisagra y maximo en el borde
# (por eso el factor `t`), que es como se comporta una vieira real.
def verts_valva(bm, x_offset):
    """Devuelve la rejilla [i][k] de una capa de la valva."""
    rejilla = []
    for i in range(N_RAD + 1):
        t = i / N_RAD
        r = R_MIN + t * (R_MAX - R_MIN)
        fila = []
        for k in range(N_ANG + 1):
            u = k / N_ANG
            th = TH_MIN + u * (TH_MAX - TH_MIN)
            relieve = AMP_COST * math.cos(N_COST * math.pi * u) * t
            y = r * math.sin(th)
            z = Z_BASE + r * math.cos(th)
            # ligera curvatura: la concha se "abomba" hacia -X en el borde
            bombeo = -0.018 * t * t
            fila.append(bm.verts.new((x_offset + relieve + bombeo, y, z)))
        rejilla.append(fila)
    return rejilla

bm = bmesh.new()
rej_ext = verts_valva(bm, -ESPESOR / 2.0)   # capa exterior (mira a -X)
rej_int = verts_valva(bm, +ESPESOR / 2.0)   # capa interior  (mira a +X)

# --- Capa EXTERIOR (debe mirar a -X) ---------------------------------------
caras_ext = []
for i in range(N_RAD):
    for k in range(N_ANG):
        caras_ext.append(bm.faces.new((rej_ext[i][k], rej_ext[i][k + 1],
                                       rej_ext[i + 1][k + 1], rej_ext[i + 1][k])))

# --- Capa INTERIOR (debe mirar a +X) ---------------------------------------
caras_int = []
for i in range(N_RAD):
    for k in range(N_ANG):
        caras_int.append(bm.faces.new((rej_int[i][k], rej_int[i + 1][k],
                                       rej_int[i + 1][k + 1], rej_int[i][k + 1])))

# --- Borde perimetral: une las dos capas por todo el contorno --------------
caras_borde = []
def canto(a, b, c, d):
    caras_borde.append(bm.faces.new((a, b, c, d)))

for k in range(N_ANG):      # arco EXTERIOR (borde del abanico)
    canto(rej_ext[N_RAD][k], rej_ext[N_RAD][k + 1],
          rej_int[N_RAD][k + 1], rej_int[N_RAD][k])
for i in range(N_RAD):      # lado +Y del abanico
    canto(rej_ext[i][N_ANG], rej_ext[i + 1][N_ANG],
          rej_int[i + 1][N_ANG], rej_int[i][N_ANG])
for k in range(N_ANG):      # arco INTERIOR (junto a la bisagra)
    canto(rej_int[0][k], rej_int[0][k + 1],
          rej_ext[0][k + 1], rej_ext[0][k])
for i in range(N_RAD):      # lado -Y del abanico
    canto(rej_int[i][0], rej_int[i + 1][0],
          rej_ext[i + 1][0], rej_ext[i][0])

# --- E-32: unificar el winding de la isla y orientarla ---------------------
# La valva (ext + int + borde) es UNA isla cerrada y conexa: recalc unifica
# todas las normales y despues una sola medicion decide si hay que darla
# vuelta entera. Si alguien cambia el orden de los vertices de arriba, esto
# lo corrige solo.
caras_valva = caras_ext + caras_int + caras_borde
bmesh.ops.recalc_face_normals(bm, faces=caras_valva)
suma_ext = sum(f.normal.x for f in caras_ext)
if suma_ext > 0.0:
    bmesh.ops.reverse_faces(bm, faces=caras_valva)
suma_ext = sum(f.normal.x for f in caras_ext)
assert suma_ext < 0.0, ('E-32: la capa exterior no mira a -X (suma %.2f). '
                        'El recalc no unifico la isla.' % suma_ext)

# ---------- 6) Auriculas (las dos "orejitas" junto a la bisagra) ----------
# Una vieira real tiene dos aletas triangulares a los lados del ligamento.
# Son cuñas finas y CONVEXAS: recalc + test de centroide (E-32).
def auricula(signo_y):
    w, h, e = 0.038, 0.045, 0.013
    # arranca un poco ADENTRO del extremo de la bisagra para que no quede
    # suelta: la auricula tiene que solaparse con la valva.
    y0 = signo_y * (Y_HINGE - 0.006)
    pts = [
        (0.0,    Z_HINGE - 0.006),
        (w,      Z_HINGE + h * 0.30),
        (w*0.70, Z_HINGE + h),
    ]
    v = []
    for dx in (-e / 2.0, +e / 2.0):
        for (dy, dz) in pts:
            v.append(bm.verts.new((dx, y0 + signo_y * dy, dz)))
    # v[0..2] = capa -X, v[3..5] = capa +X
    caras = [
        bm.faces.new((v[0], v[1], v[2])),            # tapa
        bm.faces.new((v[3], v[4], v[5])),            # tapa
        bm.faces.new((v[0], v[1], v[4], v[3])),      # canto A-B
        bm.faces.new((v[1], v[2], v[5], v[4])),      # canto B-C
        bm.faces.new((v[2], v[0], v[3], v[5])),      # canto C-A
    ]
    bmesh.ops.recalc_face_normals(bm, faces=caras)
    centro = Vector((0.0, y0 + signo_y * w * 0.55, Z_HINGE + h * 0.40))
    for f in caras:
        # isla convexa: si el normal apunta al centro de la cuña, esta al reves
        if f.normal.dot(f.calc_center_median() - centro) < 0.0:
            f.normal_flip()
    return caras

caras_aur = auricula(+1) + auricula(-1)

# ---------- 7) Bisagra (ligamento oscuro entre las dos valvas) -------------
# Tubo eliptico a lo largo de X: ancho en Y (abarca la linea de bisagra) y
# chato en Z (es un ligamento, no un chorizo). Va en la MISMA malla que la
# valva -> el asset queda en 1 solo objeto / 1 solo draw call por material.
def crear_bisagra(bm):
    N, A_Y, A_Z, LARGO = 8, 0.034, 0.010, 0.030
    Z_CEN = Z_BASE + 0.006
    anillo_a, anillo_b = [], []
    for k in range(N):
        a = 2.0 * math.pi * k / N
        y = A_Y * math.sin(a)
        z = Z_CEN + A_Z * math.cos(a)
        anillo_a.append(bm.verts.new((-LARGO / 2.0, y, z)))
        anillo_b.append(bm.verts.new((+LARGO / 2.0, y, z)))
    tapa_a = bm.faces.new(anillo_a)
    tapa_b = bm.faces.new(list(reversed(anillo_b)))
    caras = [tapa_a, tapa_b]
    for k in range(N):
        k2 = (k + 1) % N
        caras.append(bm.faces.new((anillo_a[k], anillo_a[k2],
                                   anillo_b[k2], anillo_b[k])))
    bmesh.ops.recalc_face_normals(bm, faces=caras)
    centro = Vector((0.0, 0.0, Z_CEN))
    for f in caras:
        if f.normal.dot(f.calc_center_median() - centro) < 0.0:
            f.normal_flip()
    return caras

caras_bis = crear_bisagra(bm)
for _c in caras_bis:
    _c.material_index = 2   # MAT_bisagra

# ---------- 8) Material por cara (regla MEDIBLE, no por orden de creacion) --
# Una vez que E-32 garantiza la orientacion, el slot sale de la normal en X:
#   nx >  0.45 -> interior nacarado
#   nx < -0.45 -> exterior crema
#   |nx| chico -> canto: mismo que el exterior
bm.normal_update()
for cara in bm.faces:
    if cara.material_index == 2:
        continue                      # bisagra: ya asignada
    cara.material_index = 1 if cara.normal.x > 0.45 else 0

n_tris = sum(len(f.verts) - 2 for f in bm.faces)

# ---------- 9) Crear el objeto ----------
me_valva = bpy.data.meshes.new('SM_Vieira_Valva')
bm.to_mesh(me_valva)
bm.free()

valva = bpy.data.objects.new('SM_Vieira_Valva', me_valva)
escena.collection.objects.link(valva)
valva.data.materials.append(MAT_exterior)   # slot 0
valva.data.materials.append(MAT_interior)   # slot 1
valva.data.materials.append(MAT_bisagra)    # slot 2

bpy.ops.object.select_all(action='DESELECT')
valva.select_set(True)
bpy.context.view_layer.objects.active = valva
bpy.ops.object.shade_flat()

# ---------- 10) Asentado (E-12) — medido en caliente ----------
# La vieira esta clavada de canto: lo mas bajo es el vientre de la bisagra.
# Se mide el z_min real y se traslada hasta Z_APOYO.
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Vieira')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:      # solo la raiz; los hijos la siguen solos
        o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
print('VIEIRA asentada: z_min %.4f -> %.4f (delta %+.4f, piezas=%d)'
      % (z_min, z_fin, delta, len(piezas)))

# ---------- 11) Iluminación + mundo (set IDENTICO al resto de los assets) ----------
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

# ---------- 12) Cámara ----------
bpy.ops.object.camera_add(location=(0.85, -0.75, 0.30))
cam = bpy.context.object
cam.name = 'CAM_Vieira'
blanco = Vector((0.0, 0.0, 0.13))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 13) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '45-Arte3D',
                          'vieira_playa_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
# E-21: si quedo un .blend@ de un crash, save_as_mainfile falla.
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_obj = len([o for o in escena.objects if o.name.startswith('SM_')])
print('VIEIRA PLAYA OK — objetos SM_: %d — tris: %d — materiales: %d — blend: %s'
      % (n_obj, n_tris, len(valva.data.materials), ruta_blend))
