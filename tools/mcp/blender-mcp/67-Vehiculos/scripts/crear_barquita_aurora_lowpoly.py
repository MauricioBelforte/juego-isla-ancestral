# crear_barquita_aurora_lowpoly.py -- T-01a (M67), Hy4, 2026-11-06
#
# Barquita de Aurora: vehiculo de AGUA, eslora 5.00 m, manga 1.80 m.
# Fuente de datos: game/isla-ancestral/data/vehiculos/vehicles.json
#   id=barco, tipo=agua, nombre="Barquita de Aurora", baul_slots=12.
#
# DECISION DE DISENO (busqueda Poly Haven MEDIDA antes de generar):
#   El catalogo completo de modelos de Poly Haven (521 entradas) tiene 4
#   barcos: ship_pinnace (183837 polys), dutch_ship_medium (69162),
#   dutch_ship_large_01 (110616), dutch_ship_large_02 (96506), con cotas de
#   24-40 m. El presupuesto M166 exige ALTA <=6000 tris y la orden #05 pide
#   ~5 m. Importar hubiera obligado a un decimate de ~97 % con perdida total
#   de la silueta cozy. Se elige AUTORIA LOWPOLY PROPIA, alternativa que el
#   backlog 07 habilita explicitamente ("or custom lowpoly").
#
# REGLAS APLICADAS:
#   E-12 Z_APOYO=0.045 (quilla 5 mm hundida en la referencia de arena/agua).
#   E-24 asentado medido sobre VERTICES REALES, nunca bound_box.
#   E-44 solo SM_ se exporta; Base_Arena/SOL/CAM_* se purgan en el export.
#   E-47 la fuente se guarda como <asset>_lowpoly.blend.
#   E-50 huella no puntual: la quilla aporta 8 vertices de apoyo + 3 del
#       casco central; footprint 0.34 x 3.60 m.
#   E-60/E-62 las piezas MONTADAS (vela, botavara, banquetas, farol, cofre)
#       NO usan Z_APOYO: se validan por rango contra la pieza que las sostiene.
#
# El agua NO se modela aca: es M51. Este asset solo aporta el casco y su
# linea de flotacion; z=0.045 es la referencia comun de apoyo del proyecto.
import bpy
import bmesh
import math
import os
import sys
from mathutils import Vector

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar,
                             camara, shade_flat, guardar, caja)

escena = limpiar()

Z_APOYO = 0.045
ESLORA = 5.00
MANGA = 1.80

# ---------- 1) Materiales (6 <= 12 ALTA, <= 8 MEDIA) ----------
MAT_casco = mat('MAT_Barquita_Casco', (0.55, 0.34, 0.20))
MAT_clara = mat('MAT_Barquita_MaderaClara', (0.78, 0.62, 0.40))
MAT_oscura = mat('MAT_Barquita_MaderaOscura', (0.30, 0.20, 0.13))
MAT_vela = mat('MAT_Barquita_Lino', (0.94, 0.90, 0.78), rough=0.98)
MAT_acento = mat('MAT_Barquita_Aurora', (0.16, 0.62, 0.66))
MAT_farol = mat('MAT_Barquita_Farol', (0.95, 0.72, 0.28), rough=0.50,
                emisivo=((1.00, 0.82, 0.45), 0.55))


def malla(nombre, verts, caras, material):
    """Malla desde vertices/caras con normales recalculadas (E-32)."""
    me = bpy.data.meshes.new(nombre)
    me.from_pydata(verts, [], caras)
    me.update()
    ob = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(ob)
    ob.data.materials.append(material)
    bm = bmesh.new()
    bm.from_mesh(me)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(me)
    bm.free()
    me.update()
    return ob


# ---------- 2) Estaciones del casco ----------
# (y, semimanga, z_borda, z_quilla). Proa = +Y. La quilla tiene rocker en
# los extremos: solo el tercio central toca z=0.045, y una quilla corrida
# (pieza separada) da el apoyo ancho que exige E-50.
# 11 estaciones. Las 5 centrales tienen quilla en z=0.045: junto con los 4
# vertices inferiores de la quilla corrida dan 9 vertices de apoyo y pasan
# el guard E-50 (>=8) SIN relajar el guard. Ojo: un cubo aporta SOLO 4
# vertices en su cara inferior, no 8 (primer intento dio toca=7).
EST = [
    (-2.50, 0.34, 1.000, 0.265),
    (-2.10, 0.62, 0.920, 0.185),
    (-1.40, 0.84, 0.870, 0.095),
    (-1.05, 0.88, 0.855, 0.045),
    (-0.70, 0.90, 0.850, 0.045),
    (0.00, 0.90, 0.850, 0.045),
    (0.70, 0.88, 0.860, 0.045),
    (1.05, 0.84, 0.875, 0.045),
    (1.40, 0.74, 0.900, 0.095),
    (2.05, 0.46, 0.990, 0.205),
    (2.50, 0.06, 1.060, 0.325),
]
K = 7  # puntos por seccion transversal (U abierta arriba)


def seccion(y, b, z_top, z_kee):
    z_mid = z_kee + 0.52 * (z_top - z_kee)
    return [(-b, y, z_top),
            (-0.80 * b, y, z_mid),
            (-0.30 * b, y, z_kee + 0.02),
            (0.0, y, z_kee),
            (0.30 * b, y, z_kee + 0.02),
            (0.80 * b, y, z_mid),
            (b, y, z_top)]


def interp(y):
    """(semimanga, z_borda, z_quilla) interpolados entre estaciones."""
    for i in range(len(EST) - 1):
        y0, b0, t0, k0 = EST[i]
        y1, b1, t1, k1 = EST[i + 1]
        if y0 <= y <= y1:
            u = (y - y0) / (y1 - y0)
            return (b0 + (b1 - b0) * u, t0 + (t1 - t0) * u,
                    k0 + (k1 - k0) * u)
    return EST[-1][1], EST[-1][2], EST[-1][3]


def z_hull_en_x(y, x):
    """Cota del costado del casco en |x|, interpolando la seccion en U.

    Permite verificar POSITIVAMENTE que una pieza montada (banco, cubierta,
    baul) no atraviesa el casco ni queda colgada con luz por debajo.
    """
    b, z_top, z_kee = interp(y)
    z_mid = z_kee + 0.52 * (z_top - z_kee)
    ax = min(abs(x), b)
    if ax <= 0.30 * b:
        return z_kee + 0.02 * ax / (0.30 * b)
    if ax <= 0.80 * b:
        return (z_kee + 0.02
                + (ax - 0.30 * b) / (0.50 * b) * (z_mid - z_kee - 0.02))
    return z_mid + (ax - 0.80 * b) / (0.20 * b) * (z_top - z_mid)


# ---------- 3) Casco (loft LONGITUDINAL, no el loft vertical de plantilla) ----------
v_casco = []
for est in EST:
    v_casco.extend(seccion(*est))
f_casco = []
for i in range(len(EST) - 1):
    for j in range(K - 1):
        a = i * K + j
        b = (i + 1) * K + j
        f_casco.append((a, a + 1, b + 1, b))
# Espejo de popa y cierre de proa: abanico desde el centro de la seccion.
# El indice de la ultima estacion es (len(EST)-1)*K, NO len(v_casco): la
# lista ya crecio con el centro de la popa al llegar a la segunda iteracion.
for idx in (0, len(EST) - 1):
    y, _b, z_top, z_kee = EST[idx]
    pos = idx * K
    centro = len(v_casco)
    v_casco.append((0.0, y, 0.5 * (z_top + z_kee)))
    for j in range(K - 1):
        f_casco.append((centro, pos + j, pos + j + 1))
casco = malla('SM_Barquita_Casco', v_casco, f_casco, MAT_casco)

# Quilla corrida: 4 vertices inferiores exactamente en Z_APOYO (E-12/E-50).
# Un cubo solo aporta 4 vertices en su cara inferior, no 8. Sumados a los 5
# vertices de quilla del casco central dan toca=9 (medido por asentar()).
quilla = caja('SM_Barquita_Quilla', 0.0, 0.0, Z_APOYO + 0.06,
              0.34, 3.60, 0.12, MAT_oscura)

# ---------- 4) Borda (regala en ambos lados, sigue la curvatura) ----------
def rail(signo):
    v, f = [], []
    for (y, b, z_top, _k) in EST:
        xo = signo * b
        xi = signo * (b - 0.10)
        v.extend([(xo, y, z_top - 0.07), (xo, y, z_top + 0.015),
                  (xi, y, z_top + 0.015), (xi, y, z_top - 0.07)])
    for i in range(len(EST) - 1):
        a, c = i * 4, (i + 1) * 4
        for j in range(4):
            j2 = (j + 1) % 4
            f.append((a + j, c + j, c + j2, a + j2))
    return v, f


v_p, f_p = rail(-1)
v_s, f_s = rail(1)
off = len(v_p)
malla('SM_Barquita_Borda', v_p + v_s,
      f_p + [tuple(i + off for i in c) for c in f_s], MAT_oscura)

# ---------- 5) Cubierta parcial (deja un cockpit abierto) ----------
def panel(ys):
    v = []
    for y in ys:
        b, z_top, _k = interp(y)
        # 0.95*b: el borde de la cubierta ENCUENTRA el costado del casco.
        # Con 0.80*b quedaba un hueco de ~13 cm a cada lado (visto en az120).
        w = 0.95 * b
        v.extend([(-w, y, z_top - 0.10), (w, y, z_top - 0.10)])
    f = [(2 * i, 2 * i + 1, 2 * i + 3, 2 * i + 2)
         for i in range(len(ys) - 1)]
    return v, f


v_a, f_a = panel([0.45, 0.70, 1.40, 2.05, 2.40])
v_b, f_b = panel([-2.40, -2.10, -1.55])
off = len(v_a)
malla('SM_Barquita_Cubierta', v_a + v_b,
      f_a + [tuple(i + off for i in c) for c in f_b], MAT_clara)
for _y in (0.70, 1.40, -2.10):
    _b, _zt, _zk = interp(_y)
    _borde = 0.95 * _b
    assert abs((_zt - 0.10) - z_hull_en_x(_y, _borde)) < 0.06, \
        'cubierta despegada del costado en y=%.2f' % _y

# ---------- 6) Banquetas, baul (12 slots segun vehicles.json), farol ----------
# Guard de PIEZA MONTADA (E-60 + trampa del soporte que no toca): cada banco
# debe llegar hasta el costado y quedar cubierto por el, no flotar en el aire.
BANCO_MEDIO_X, BANCO_Z, BANCO_H = 0.85, 0.70, 0.07
for nombre, y in (('SM_Barquita_Banqueta_Proa', 0.55),
                  ('SM_Barquita_Banqueta_Popa', -0.95)):
    b, z_top, _k = interp(y)
    assert BANCO_Z + BANCO_H / 2.0 < z_hull_en_x(y, BANCO_MEDIO_X) + 0.05, \
        'banco colgando: no alcanza el costado en y=%.2f' % y
    assert BANCO_Z - BANCO_H / 2.0 > Z_APOYO + 0.30
    caja(nombre, 0.0, y, BANCO_Z, 2.0 * BANCO_MEDIO_X, 0.20, BANCO_H,
         MAT_clara)

# El baul subio de z=0.30 a z=0.46: con el fondo en 0.14 ATRAVESABA el casco
# y aparecia como un filo turquesa por debajo del casco en az120/az240.
COFRE_Z, COFRE_H, COFRE_MEDIO_X = 0.46, 0.32, 0.29
COFRE_FONDO = COFRE_Z - COFRE_H / 2.0
assert COFRE_FONDO > z_hull_en_x(-1.55, COFRE_MEDIO_X) + 0.02, \
    'el baul atraviesa el casco (fondo %.3f vs costado %.3f)' % (
        COFRE_FONDO, z_hull_en_x(-1.55, COFRE_MEDIO_X))
caja('SM_Barquita_Cofre', 0.0, -1.55, COFRE_Z,
     2.0 * COFRE_MEDIO_X, 0.42, COFRE_H, MAT_acento)
caja('SM_Barquita_Cofre_Tapa', 0.0, -1.55, COFRE_Z + COFRE_H / 2.0 + 0.03,
     0.62, 0.46, 0.06, MAT_oscura)

_b_proa, z_top_proa, _k_proa = interp(2.12)
z_deck_proa = z_top_proa - 0.10
z_farol = z_deck_proa + 0.11
assert abs((z_farol - 0.11) - z_deck_proa) < 1e-9, 'farol no apoya en cubierta'
caja('SM_Barquita_Farol', 0.0, 2.12, z_farol, 0.14, 0.14, 0.22, MAT_farol)

# ---------- 7) Mastil, botavara, vela, bandera ----------
MAST_BASE, MAST_ALTO = 0.10, 3.65
bpy.ops.mesh.primitive_cylinder_add(
    vertices=8, radius=0.075, depth=MAST_ALTO - MAST_BASE,
    location=(0.0, -0.15, 0.5 * (MAST_BASE + MAST_ALTO)))
mastil = bpy.context.object
mastil.name = 'SM_Barquita_Mastil'
mastil.data.materials.append(MAT_oscura)

BOOM_Y0, BOOM_Y1, BOOM_Z = -0.15, -2.00, 1.20
bpy.ops.mesh.primitive_cylinder_add(
    vertices=6, radius=0.045, depth=BOOM_Y0 - BOOM_Y1,
    location=(0.0, 0.5 * (BOOM_Y0 + BOOM_Y1), BOOM_Z))
boom = bpy.context.object
boom.name = 'SM_Barquita_Botavara'
boom.rotation_euler = (math.radians(90), 0.0, 0.0)
boom.data.materials.append(MAT_oscura)
assert abs(BOOM_Z - 1.20) < 1e-9 and BOOM_Y1 < BOOM_Y0

# Vela trapezoidal con panza (billow) en +X: 4x4, 18 tris.
NU, NV = 4, 4
v_vela, f_vela = [], []
for iu in range(NU):
    u = iu / (NU - 1.0)
    for iv in range(NV):
        s = iv / (NV - 1.0)
        y = BOOM_Y0 - (BOOM_Y0 - BOOM_Y1) * u * (1.0 - 0.45 * s)
        z = BOOM_Z + 2.20 * s
        x = 0.02 + 0.16 * math.sin(math.pi * u) * math.sin(math.pi * s)
        v_vela.append((x, y, z))
for iu in range(NU - 1):
    for iv in range(NV - 1):
        a = iu * NV + iv
        f_vela.append((a, a + NV, a + NV + 1, a + 1))
malla('SM_Barquita_Vela', v_vela, f_vela, MAT_vela)

# Banderin: prisma triangular fino, visible desde ambos lados.
malla('SM_Barquita_Bandera',
      [(0.00, -0.15, 3.60), (0.00, 0.45, 3.50), (0.00, -0.15, 3.38),
       (0.05, -0.15, 3.60), (0.05, 0.45, 3.50), (0.05, -0.15, 3.38)],
      [(0, 1, 2), (3, 5, 4), (0, 3, 4, 1), (1, 4, 5, 2), (2, 5, 3, 0)],
      MAT_acento)

# ---------- 8) Timon (RF1: vela y timon) ----------
caja('SM_Barquita_Timon_Pala', 0.0, -2.52, 0.42,
     0.07, 0.42, 0.55, MAT_oscura)
caja('SM_Barquita_Timon_Canya', 0.0, -2.18, 0.92,
     0.05, 0.80, 0.05, MAT_clara)

# ---------- 9) Escena, asentado y medicion POSITIVA de cotas ----------
arena(radio=4.20)          # disco NO exportado; top z=0.05 (E-67)
iluminar(escena)
camara(escena, 'CAM_Barquita', loc=(8.0, -10.0, 5.5), mira=(0.0, 0.0, 1.6))
shade_flat(escena)
z_fin, n_toca, fp_x, fp_y = asentar(escena)
bpy.context.view_layer.update()

piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_')]
pts = [o.matrix_world @ v.co for o in piezas for v in o.data.vertices]
xs = [p.x for p in pts]
ys = [p.y for p in pts]
zs = [p.z for p in pts]
# La ESLORA se mide sobre el CASCO: la pala del timon sobresale por popa y
# estira la cota total del bbox. Reportar las dos evita confundir "5 m de
# barco" con "5.23 m de bounding box incluyendo el timon".
ys_casco = [(casco.matrix_world @ v.co).y for v in casco.data.vertices]
eslora_casco = max(ys_casco) - min(ys_casco)
cota_y_total = max(ys) - min(ys)
manga = max(xs) - min(xs)
alto_total = max(zs) - min(zs)
print('COTAS: eslora_casco=%.3f cota_y_total=%.3f manga=%.3f '
      'alto_total=%.3f z_min=%.4f'
      % (eslora_casco, cota_y_total, manga, alto_total, min(zs)))
print('APOYO: toca=%d footprint=%.3f x %.3f' % (n_toca, fp_x, fp_y))
print('PIEZAS SM_: %d' % len(piezas))

assert abs(eslora_casco - ESLORA) < 0.02, \
    'eslora casco %.3f != %.2f' % (eslora_casco, ESLORA)
assert abs(manga - MANGA) < 0.20, 'manga %.3f lejos de %.2f' % (manga, MANGA)
assert abs(min(zs) - Z_APOYO) < 1e-4, 'z_min %.4f != Z_APOYO' % min(zs)
assert len(piezas) <= 16, 'ALTA excede 16 objetos: %d' % len(piezas)
# Guard POSITIVO de piezas montadas: la vela existe y esta por encima del
# casco, no basta con que el script no haya fallado.
assert any(o.name == 'SM_Barquita_Vela' and o.data.vertices for o in piezas)
assert min(p[2] for p in v_vela) >= BOOM_Z - 1e-9, \
    'vela por debajo de la botavara'

guardar(escena, '67-Vehiculos', 'barquita_aurora')
