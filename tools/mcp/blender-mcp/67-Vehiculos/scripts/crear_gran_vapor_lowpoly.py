# crear_gran_vapor_lowpoly.py -- T-01d (M67/M68), Hy4, 2026-11-06
#
# Gran Vapor: locomotora de RIEL, 15.00 m de largo total (eje Y).
# Fuente de datos: game/isla-ancestral/data/vehiculos/vehicles.json
#   id=locomotora, tipo=riel, nombre="Gran Vapor (plantilla M68)",
#   velocidad_max=20, velocidad_crucero=20, giro=0, frenado=6,
#   baul_slots=16, tiene_reversa=false, condicional="M68".
#   M68 m68_spec.md: estacion central "solo si M67 define locomotora",
#   anden de 8 m, 1 ruta lineal. Los RIELES y la ruta los aplica el RUNTIME;
#   el asset solo aporta geometria con la referencia comun de apoyo.
#
# DECISION DE DISENO (busqueda Poly Haven MEDIDA antes de generar):
#   Catalogo completo por API con User-Agent: 521 modelos.
#   CERO trenes / locomotoras / vagones / rieles / tramvias. Los 29 hits por
#   keyword son FALSOS POSITIVOS y dos de ellos son trampas de substring:
#     - "rail" esta contenido en "trail" (20 nature assets: coast_rocks,
#       boulders, dead_tree_trunk, grass, root_cluster...) -> NO son vias.
#     - "cart" da 4 carritos (CoffeeCart_01, industrial_storage_cart,
#       portable_welding_cart, tool_cart) que midieron 18902..29418 polys
#       y 0.84..2.17 m: son muebles industriales, NO material rodante.
#   Se usa la alternativa CUSTOM LOWPOLY que el backlog 07 habilita.
#
# REGLAS APLICADAS:
#   E-12 Z_APOYO=0.045. A diferencia de T-01a/b/c (patines), AQUI el apoyo
#       lo dan las RUEDAS: disposicion 4-6-2 (6 motrices + 6 de bogie),
#       octogonos con ARISTA INFERIOR PLANA (2 vertices por anillo,
#       4 por rueda = 48 vertices de huella).
#   E-24 asentado medido sobre VERTICES REALES, nunca bound_box.
#   E-44 solo SM_ se exporta; Base_Arena/SOL/CAM_* se purgan en el export.
#   E-47 la fuente se guarda como <asset>_lowpoly.blend.
#   E-50 huella no puntual: se mide en asentar() (min_toca=8, min_fp=0.30).
#   E-60/E-62 las piezas MONTADAS (chimenea, domo, farol, bandas, bielas,
#       parachoques) NO usan Z_APOYO: se validan por guard POSITIVO contra
#       la superficie REAL de la caldera / el bastidor / las ruedas.
#   E-32 normales: la caldera se construye con winding explicito hacia
#       AFUERA y se MIDE cara por cara, no se confia en
#       recalc_face_normals sobre tiras abiertas.
#   DECISION DE 4 MATERIALES (defecto REAL detectado en T-01c, acta 15):
#       Con 6 materiales la poda BAJA --max-mats 4 remapeaba por numero de
#       caras y blanqueaba las piezas de identidad. Con EXACTAMENTE 4 la
#       poda es un NO-OP: 4 grupos de merge => MEDIA 4 obj (<=8) y BAJA
#       4 obj (<=6), 4 mats (<=4). Cada pieza lleva UN solo material.
#       No se toca generar_variante.py (script COMPARTIDO).
import bpy
import bmesh
import math
import os
import sys
from mathutils import Vector

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar,
                             camara, shade_flat, guardar, loft)

escena = limpiar()

Z_APOYO = 0.045
LARGO = 15.00
Y_POPA, Y_PROA = -7.50, 7.50
Z_CALDERA = 2.05
R_CALDERA = 0.95
N = 12
COS_PLANO = math.cos(math.pi / 8.0)     # 0.92388: fondo plano del octogono

# ---------- 1) Materiales: EXACTAMENTE 4 (BAJA no necesita poda) ----------
MAT_casco = mat('MAT_Vapor_Marfil', (0.90, 0.87, 0.78), rough=0.70)
MAT_acento = mat('MAT_Vapor_Verde', (0.13, 0.42, 0.40), rough=0.80)
MAT_laton = mat('MAT_Vapor_Laton', (0.98, 0.76, 0.32), rough=0.42,
                emisivo=((1.00, 0.82, 0.40), 0.55))
MAT_oscuro = mat('MAT_Vapor_Hierro', (0.17, 0.20, 0.23), rough=0.74)

MATS = (MAT_casco, MAT_acento, MAT_laton, MAT_oscuro)


def malla(nombre, verts, caras, material, normal_ref=None, z_eje=None):
    """Malla desde vertices/caras.

    normal_ref='explicito' -> NO recalcular; exigir normal radial SALIENTE
    en TODAS las caras laterales (caldera). z_eje es el centro del tubo.
    normal_ref=None        -> recalc_face_normals (piezas cerradas).
    """
    me = bpy.data.meshes.new(nombre)
    me.from_pydata(verts, [], caras)
    me.update()
    ob = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(ob)
    ob.data.materials.append(material)

    bm = bmesh.new()
    bm.from_mesh(me)
    if normal_ref == 'explicito':
        assert z_eje is not None, 'falta z_eje para el guard de normales'
        revisar = [(f.calc_center_median(), f.normal) for f in bm.faces]
        malas = 0
        for c, n in revisar:
            radial = Vector((c.x, 0.0, c.z - z_eje))
            if radial.length > 1e-6 and n.dot(radial.normalized()) < -0.02:
                malas += 1
        assert malas == 0, '%s: %d caras con normal hacia ADENTRO' % (
            nombre, malas)
        print('NORMALES %s: %d caras, 0 hacia adentro (winding explicito)' %
              (nombre, len(revisar)))
    else:
        bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(me)
    bm.free()
    me.update()
    return ob


def add_caja(V, F, c, s):
    """Agrega UNA caja centrada a acumuladores V/F (ahorra objetos)."""
    x, y, z = c
    sx, sy, sz = s
    base = len(V)
    for dx, dy, dz in ((-1, -1, -1), (1, -1, -1), (1, 1, -1), (-1, 1, -1),
                       (-1, -1, 1), (1, -1, 1), (1, 1, 1), (-1, 1, 1)):
        V.append((x + dx * sx / 2.0, y + dy * sy / 2.0, z + dz * sz / 2.0))
    for q in ((0, 3, 2, 1), (4, 5, 6, 7), (0, 1, 5, 4),
              (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)):
        F.append(tuple(base + i for i in q))


def add_tubo(V, F, estaciones, z_eje, lados, tapar=True):
    """Agrega un tubo por ESTACIONES (y, radio) con eje en Y.

    Winding (a,d,c,b) = normal SALIENTE (mismo patron verificado en T-01c).
    """
    base = len(V)
    for (y, r) in estaciones:
        for j in range(lados):
            a = 2.0 * math.pi * j / lados
            V.append((r * math.cos(a), y, z_eje + r * math.sin(a)))
    for i in range(len(estaciones) - 1):
        for j in range(lados):
            k = (j + 1) % lados
            a = base + i * lados + j
            b = base + i * lados + k
            d = base + (i + 1) * lados + j
            c = base + (i + 1) * lados + k
            F.append((a, d, c, b))
    if tapar:
        i0 = len(V)
        V.append((0.0, estaciones[0][0], z_eje))
        i1 = len(V)
        V.append((0.0, estaciones[-1][0], z_eje))
        ult = (len(estaciones) - 1) * lados
        for j in range(lados):
            k = (j + 1) % lados
            F.append((i0, base + j, base + k))
            F.append((i1, base + ult + k, base + ult + j))


def add_rueda(V, F, x, y, z, r, t, lados=8):
    """Rueda de eje X con ARISTA INFERIOR PLANA (fondo en z - r*cos(pi/8))."""
    base = len(V)
    for xr in (x - t, x + t):
        for k in range(lados):
            a = -5.0 * math.pi / 8.0 + k * 2.0 * math.pi / lados
            V.append((xr, y + r * math.cos(a), z + r * math.sin(a)))
    for k in range(lados):
        j = (k + 1) % lados
        F.append((base + k, base + j, base + lados + j, base + lados + k))
    F.append(tuple(base + k for k in range(lados)))
    F.append(tuple(base + lados + k for k in reversed(range(lados))))


def barras(nombre, segmentos, radio, material, lados=4):
    """N prismas entre p0/p1 unidos en UN solo objeto (ahorra objetos)."""
    obs = []
    for p0, p1 in segmentos:
        a, b = Vector(p0), Vector(p1)
        d = b - a
        assert d.length > 1e-6, 'barra de largo 0'
        bpy.ops.mesh.primitive_cylinder_add(
            vertices=lados, radius=radio, depth=d.length,
            location=tuple((a + b) * 0.5))
        o = bpy.context.object
        o.rotation_euler = d.to_track_quat('Z', 'Y').to_euler()
        obs.append(o)
    bpy.ops.object.select_all(action='DESELECT')
    for o in obs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = obs[0]
    bpy.ops.object.join()
    res = bpy.context.object
    res.name = nombre
    res.data.materials.append(material)
    return res


# ---------- 2) Estaciones de la caldera (eje Y) ----------
EST_CALDERA = [
    (-3.60, 0.86),     # union con la cabina
    (-3.10, 0.95),
    (4.90, 0.95),
    (5.60, 1.00),      # caja de humos
    (6.35, 1.00),
]
Y_CAB_FRONT = EST_CALDERA[0][0]


def interp_r(y):
    for i in range(len(EST_CALDERA) - 1):
        y0, r0 = EST_CALDERA[i]
        y1, r1 = EST_CALDERA[i + 1]
        if y0 <= y <= y1:
            u = (y - y0) / (y1 - y0)
            return r0 + (r1 - r0) * u
    return EST_CALDERA[-1][1]


def z_caldera_inf(y, x):
    """Vientre REAL de la caldera en el lateral x (seccion circular)."""
    r = interp_r(y)
    return Z_CALDERA - math.sqrt(max(r * r - x * x, 0.0))


def z_caldera_sup(y):
    """Lomo REAL de la caldera en x=0 (para montar chimenea y domo)."""
    return Z_CALDERA + interp_r(y)


# ---------- 3) Bastidor + topes (HIERRO) ----------
CHASSIS_Z, CHASSIS_H = 1.18, 0.30
CHASSIS_TOP = CHASSIS_Z + CHASSIS_H / 2.0
V_bas, F_bas = [], []
add_caja(V_bas, F_bas, (0.0, 0.0, CHASSIS_Z), (2.10, 13.70, CHASSIS_H))
for y in (Y_POPA + 0.12, 6.42):
    add_caja(V_bas, F_bas, (0.0, y, 0.72), (2.80, 0.24, 0.30))
for x in (-1.00, 1.00):
    add_caja(V_bas, F_bas, (x, -4.20, 0.72), (0.34, 0.60, 0.16))
bastidor = malla('SM_Vapor_Bastidor', V_bas, F_bas, MAT_oscuro)
assert CHASSIS_TOP > z_caldera_inf(0.0, 0.0) + 0.05, \
    'la caldera FLOTA sobre el bastidor: %.3f vs %.3f' % (
        CHASSIS_TOP, z_caldera_inf(0.0, 0.0))

# ---------- 4) Caldera (MARFIL) con normales explicitas ----------
V_cal, F_cal = [], []
add_tubo(V_cal, F_cal, EST_CALDERA, Z_CALDERA, N, tapar=True)
caldera = malla('SM_Vapor_Caldera', V_cal, F_cal, MAT_casco,
                normal_ref='explicito', z_eje=Z_CALDERA)

# ---------- 5) Bandas + franja de cabina (VERDE) ----------
V_faj, F_faj = [], []
for y in (-2.20, 0.90, 4.10):
    r = interp_r(y) + 0.022
    add_tubo(V_faj, F_faj, [(y - 0.07, r), (y + 0.07, r)],
             Z_CALDERA, N, tapar=True)
    assert r > interp_r(y) + 0.01, 'banda ENTERRADA en la caldera'
add_caja(V_faj, F_faj, (0.0, -5.55, 2.15), (2.62, 0.16, 0.22))
franjas = malla('SM_Vapor_Franjas', V_faj, F_faj, MAT_acento)

# ---------- 6) Cabina + techo (MARFIL) ----------
V_cab, F_cab = [], []
add_caja(V_cab, F_cab, (0.0, -5.55, 2.30), (2.60, 3.90, 2.30))
# El techo NO puede volar por detras de la popa: el guard de LARGO=15.00
# lo detecto en el primer intento (15.100). Rear exacto en Y_POPA.
add_caja(V_cab, F_cab, (0.0, -5.50, 3.53), (2.86, 4.00, 0.16))
cabina = malla('SM_Vapor_Cabina', V_cab, F_cab, MAT_casco)
bpy.context.view_layer.update()
y_cab_max = max((cabina.matrix_world @ v.co).y for v in cabina.data.vertices)
y_cal_min = min((caldera.matrix_world @ v.co).y for v in caldera.data.vertices)
assert abs(y_cab_max - y_cal_min) < 0.20, \
    'la cabina NO se une a la caldera: %.3f vs %.3f' % (y_cab_max, y_cal_min)

# ---------- 7) Ventanas de la cabina (LATON) ----------
V_ven, F_ven = [], []
for x in (-1.311, 1.311):
    for y in (-6.60, -4.55):
        base = len(V_ven)
        V_ven.extend([(x, y - 0.42, 2.45), (x, y + 0.42, 2.45),
                      (x, y + 0.42, 3.15), (x, y - 0.42, 3.15)])
        F_ven.append((base, base + 1, base + 2, base + 3))
        assert abs(x) > 1.30 + 0.005, 'ventana ENTERRADA en la cabina'
ventanas = malla('SM_Vapor_Ventanas', V_ven, F_ven, MAT_laton)
assert len(V_ven) == 16, 'faltan ventanas: %d vertices' % len(V_ven)

# ---------- 8) Chimenea (HIERRO) y domo (LATON) ----------
Y_CHIM = 4.60
Z_CHIM_BASE = z_caldera_sup(Y_CHIM) - 0.12
Z_CHIM_TOP = 4.18
assert Z_CHIM_BASE < z_caldera_sup(Y_CHIM) - 0.05, \
    'la chimenea NO penetra la caldera: %.3f vs %.3f' % (
        Z_CHIM_BASE, z_caldera_sup(Y_CHIM))
chimenea = loft('SM_Vapor_Chimenea', [
    (Z_CHIM_BASE, 0.0, Y_CHIM, 0.34, 0.34),
    (Z_CHIM_BASE + 0.20, 0.0, Y_CHIM, 0.26, 0.26),
    (Z_CHIM_TOP - 0.16, 0.0, Y_CHIM, 0.30, 0.30),
    (Z_CHIM_TOP, 0.0, Y_CHIM, 0.42, 0.42),
], MAT_oscuro, lados=8)
assert chimenea.data.materials[0] == MAT_oscuro

Y_DOMO = 1.20
Z_DOMO_BASE = z_caldera_sup(Y_DOMO) - 0.10
assert Z_DOMO_BASE < z_caldera_sup(Y_DOMO) - 0.05, \
    'el domo NO penetra la caldera'
domo = loft('SM_Vapor_Domo', [
    (Z_DOMO_BASE, 0.0, Y_DOMO, 0.34, 0.34),
    (Z_DOMO_BASE + 0.38, 0.0, Y_DOMO, 0.30, 0.30),
    (Z_DOMO_BASE + 0.52, 0.0, Y_DOMO, 0.16, 0.16),
], MAT_laton, lados=8)

# ---------- 9) Farol frontal (LATON) sobre la caja de humos ----------
V_far, F_far = [], []
Y_FAROL = 6.05
Z_FAROL = z_caldera_sup(Y_FAROL) + 0.20
add_caja(V_far, F_far, (0.0, Y_FAROL, Z_FAROL), (0.44, 0.30, 0.44))
add_caja(V_far, F_far, (0.0, Y_FAROL + 0.16, Z_FAROL),
         (0.36, 0.04, 0.36))
farol = malla('SM_Vapor_Farol', V_far, F_far, MAT_laton)
assert Z_FAROL - 0.22 > z_caldera_sup(Y_FAROL) - 0.05, \
    'el farol esta ENTERRADO en la caja de humos'

# ---------- 10) Ruedas: 4-6-2 Pacific, 6 motrices + 6 de bogie ----------
R_GRANDE, R_CHICA = 0.95, 0.50
Z_RG = Z_APOYO + COS_PLANO * R_GRANDE
Z_RC = Z_APOYO + COS_PLANO * R_CHICA
Y_MOTRICES = (-2.60, -0.40, 1.80)
Y_CHICAS = (-6.20, 5.00, 6.10)
X_MOTRIZ, X_CHICA = 1.15, 1.00
T_MOTRIZ, T_CHICA = 0.09, 0.07

V_rg, F_rg = [], []
for y in Y_MOTRICES:
    for sgn in (-1, 1):
        add_rueda(V_rg, F_rg, sgn * X_MOTRIZ, y, Z_RG,
                  R_GRANDE, T_MOTRIZ)
ruedas_motrices = malla('SM_Vapor_Ruedas_Motrices', V_rg, F_rg, MAT_oscuro)

V_rc, F_rc = [], []
for y in Y_CHICAS:
    for sgn in (-1, 1):
        add_rueda(V_rc, F_rc, sgn * X_CHICA, y, Z_RC,
                  R_CHICA, T_CHICA)
ruedas_chicas = malla('SM_Vapor_Ruedas_Chicas', V_rc, F_rc, MAT_oscuro)

bpy.context.view_layer.update()
for o, nom in ((ruedas_motrices, 'motrices'), (ruedas_chicas, 'chicas')):
    zmin = min((o.matrix_world @ v.co).z for v in o.data.vertices)
    assert abs(zmin - Z_APOYO) < 1e-5, \
        'ruedas %s no apoyan: %.5f != %.5f' % (nom, zmin, Z_APOYO)

# ---------- 11) Cubos de rueda (LATON) ----------
# DISCOS PLANOS, no cilindros: 6 cilindros de 6 lados costaban 120 tris y
# llevaron BAJA a 720 > 700 (techo M166). 6 quads = 12 tris, misma identidad.
V_cub, F_cub = [], []
for y in Y_MOTRICES:
    for sgn in (-1, 1):
        x = sgn * (X_MOTRIZ + T_MOTRIZ + 0.006)
        base = len(V_cub)
        V_cub.extend([(x, y - 0.14, Z_RG - 0.14),
                      (x, y + 0.14, Z_RG - 0.14),
                      (x, y + 0.14, Z_RG + 0.14),
                      (x, y - 0.14, Z_RG + 0.14)])
        F_cub.append((base, base + 1, base + 2, base + 3))
        assert abs(x) > X_MOTRIZ + T_MOTRIZ, 'cubo ENTERRADO en la rueda'
cubos = malla('SM_Vapor_Cubos', V_cub, F_cub, MAT_laton)
assert len(V_cub) == 24, 'faltan cubos: %d vertices' % len(V_cub)

# ---------- 12) Bielas (LATON) con guard POSITIVO de union ----------
PIN_DY, PIN_DZ = 0.60, 0.10
Z_PIN = Z_RG + PIN_DZ
Y_PIN0 = Y_MOTRICES[0] + PIN_DY
Y_PIN1 = Y_MOTRICES[-1] + PIN_DY
X_BIELA = X_MOTRIZ + T_MOTRIZ + 0.035
segs_biel = []
for sgn in (-1, 1):
    x = sgn * X_BIELA
    segs_biel.append(((x, Y_PIN0, Z_PIN), (x, Y_PIN1, Z_PIN)))
    segs_biel.append(((x, Y_PIN1, Z_PIN), (x, 4.55, 1.45)))
bielas = barras('SM_Vapor_Bielas', segs_biel, 0.045, MAT_laton)
bpy.context.view_layer.update()
verts_biel = [bielas.matrix_world @ v.co for v in bielas.data.vertices]
for sgn in (-1, 1):
    pin = Vector((sgn * X_BIELA, Y_PIN0, Z_PIN))
    d = min((p - pin).length for p in verts_biel)
    assert d < 0.07, 'biela DESPEGADA del perno de rueda: d=%.4f' % d

# ---------- 13) Parachoques / limpiavias (VERDE) ----------
Y_PC0, Y_PC1 = 6.50, Y_PROA
V_pc, F_pc = [], []
add_caja(V_pc, F_pc, (0.0, Y_PC0, 0.55), (2.80, 0.16, 0.44))
# cuna trapezoidal: 4 vertices atras (y=Y_PC0), 4 adelante (y=Y_PC1)
base = len(V_pc)
for y, half_x, z0, z1 in ((Y_PC0, 1.30, 0.34, 0.90),
                          (Y_PC1, 0.55, 0.12, 0.34)):
    V_pc.extend([(-half_x, y, z0), (half_x, y, z0),
                 (half_x, y, z1), (-half_x, y, z1)])
F_pc.extend([(base, base + 3, base + 2, base + 1),
             (base + 4, base + 5, base + 6, base + 7),
             (base, base + 1, base + 5, base + 4),
             (base + 1, base + 2, base + 6, base + 5),
             (base + 2, base + 3, base + 7, base + 6),
             (base + 3, base, base + 4, base + 7)])
parachoques = malla('SM_Vapor_Parachoques', V_pc, F_pc, MAT_acento)
bpy.context.view_layer.update()
y_pc_max = max((parachoques.matrix_world @ v.co).y
               for v in parachoques.data.vertices)
assert abs(y_pc_max - Y_PROA) < 1e-5, \
    'el parachoques no llega a la proa: %.4f' % y_pc_max

# ---------- 14) Escena, asentado y medicion POSITIVA de cotas ----------
arena(radio=9.00)
iluminar(escena, energia=3.2)
camara(escena, 'CAM_Vapor', loc=(17.0, -21.0, 9.5), mira=(0.0, 0.0, 2.0))
shade_flat(escena)
z_fin, n_toca, fp_x, fp_y = asentar(escena)
bpy.context.view_layer.update()

piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_')]
pts = [o.matrix_world @ v.co for o in piezas for v in o.data.vertices]
xs = [p.x for p in pts]
ys = [p.y for p in pts]
zs = [p.z for p in pts]
largo_total = max(ys) - min(ys)
manga = max(xs) - min(xs)
alto_total = max(zs) - min(zs)
print('COTAS: largo_total=%.3f manga=%.3f alto_total=%.3f '
      'z_min=%.4f z_max=%.4f' %
      (largo_total, manga, alto_total, min(zs), max(zs)))
print('APOYO: toca=%d footprint=%.3f x %.3f' % (n_toca, fp_x, fp_y))
print('PIEZAS SM_: %d  MATERIALES: %d' % (len(piezas), len(MATS)))

# --- Guardas POSITIVAS (el "no fallo" del script NO alcanza) ---
assert abs(largo_total - LARGO) < 0.02, \
    'largo %.3f != %.2f' % (largo_total, LARGO)
assert abs(min(zs) - Z_APOYO) < 1e-4, 'z_min %.4f != Z_APOYO' % min(zs)
assert 4.0 < max(zs) < 4.40, \
    'la chimenea no corona la locomotora: %.3f' % max(zs)
assert 2.60 < manga < 3.00, 'manga fuera de diseno: %.3f' % manga
assert n_toca >= 8 and min(fp_x, fp_y) > 0.30, 'huella puntual (E-50)'
assert len(piezas) <= 16, 'ALTA excede 16 objetos: %d' % len(piezas)
assert len(MATS) == 4, '4 materiales => 4 grupos y BAJA sin poda: %d' % len(MATS)
assert len(ruedas_motrices.data.vertices) == 6 * 16, 'faltan ruedas motrices'
assert len(ruedas_chicas.data.vertices) == 6 * 16, 'faltan ruedas de bogie'
assert len(V_ven) == 16 and len(V_faj) > 40, 'piezas de identidad vacias'
for _o, _nom in ((caldera, 'SM_Vapor_Caldera'),
                 (chimenea, 'SM_Vapor_Chimenea'),
                 (domo, 'SM_Vapor_Domo'),
                 (farol, 'SM_Vapor_Farol'),
                 (cubos, 'SM_Vapor_Cubos'),
                 (bielas, 'SM_Vapor_Bielas'),
                 (parachoques, 'SM_Vapor_Parachoques')):
    assert _o is not None and len(_o.data.vertices) > 0, \
        '%s existe pero esta VACIA' % _nom
assert abs(min(ys) - Y_POPA) < 0.02, \
    'la popa no llega al limite: %.3f' % min(ys)

guardar(escena, '67-Vehiculos', 'gran_vapor')
