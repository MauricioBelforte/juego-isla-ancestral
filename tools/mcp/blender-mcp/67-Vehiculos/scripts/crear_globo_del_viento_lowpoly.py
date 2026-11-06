# crear_globo_del_viento_lowpoly.py -- T-01b (M67), Hy4, 2026-11-06
#
# Globo del Viento: vehiculo de AIRE (dirigible), eslora de envolvente 12.00 m.
# Fuente de datos: game/isla-ancestral/data/vehiculos/vehicles.json
#   id=dirigible, tipo=aire, nombre="Globo del Viento", baul_slots=8,
#   altitud_max=60.0. La altitud la aplica el RUNTIME (M67): este asset solo
#   aporta la geometria con la referencia comun de apoyo del proyecto.
#
# DECISION DE DISENO (busqueda Poly Haven MEDIDA antes de generar):
#   Catalogo completo de modelos medido por API con User-Agent: 521 entradas.
#   CERO globos / dirigibles / zeppelines / aeronaves. Los 5 candidatos por
#   palabra clave son falsos positivos (hand_plane_no4 = cepillo de mano,
#   kite_shield = escudo, rollershutter_window_01/02/03 = persianas).
#   Los unicos vehiculos siguen siendo los 4 barcos de T-01a (69162..183837
#   polys, 24-40 m). Se elige AUTORIA LOWPOLY PROPIA, alternativa que el
#   backlog 07 habilita literalmente ("or custom lowpoly").
#
# REGLAS APLICADAS:
#   E-12 Z_APOYO=0.045. Para un vehiculo de AIRE el apoyo lo dan los PATINES
#       de aterrizaje: el asset se modela en configuracion "posado / amarrado"
#       y el runtime lo eleva hasta altitud_max. No se modela el aire.
#   E-24 asentado medido sobre VERTICES REALES, nunca bound_box.
#   E-44 solo SM_ se exporta; Base_Arena/SOL/CAM_* se purgan en el export.
#   E-47 la fuente se guarda como <asset>_lowpoly.blend.
#   E-50 huella no puntual: DOS patines = 8 vertices de apoyo (4 por caja),
#       footprint 1.88 x 3.80 m. Ojo: un cubo aporta SOLO 4 vertices en su
#       cara inferior, no 8 (trampa ya medida en T-01a).
#   E-60/E-62 las piezas MONTADAS (gondola, cables, aletas, helice, bandera)
#       NO usan Z_APOYO: se validan por rango/guard POSITIVO contra la pieza
#       que las sostiene. Un "el script no fallo" NO prueba que esten pegadas.
#   E-32 normales: la envolvente se construye con winding explicito hacia
#       AFUERA y se MIDE cara por cara (guard positivo), no se confia en
#       recalc_face_normals sobre tiras abiertas (puede voltear algun gajo).
#
# PRESUPUESTO: 6 materiales, 14 objetos SM_. El derivador agrupa por LISTA de
# materiales; al ser todos de un solo material quedan 6 grupos -> MEDIA 6 obj
# (<=8) y BAJA 6 obj (<=6). Con 7 materiales BAJA naceria con 7 y fallaria.
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
ESLORA = 12.00          # largo de la ENVOLVENTE (eje Y), cola -6.00 -> morro +6.00
RADIO_MAX = 2.10
Z_ENV = 5.60            # altura del eje de la envolvente
N = 12                  # sectores angulares (6 gajos lona + 6 gajos acento)
Z_GOND_CENTRO = 1.85    # centro aproximado de la gondola (para normales)

# ---------- 1) Materiales (6 <= 12 ALTA, <= 8 MEDIA, poda a 4 en BAJA) ----------
MAT_lona = mat('MAT_Globo_Lona', (0.93, 0.87, 0.73), rough=0.98)
MAT_acento = mat('MAT_Globo_Acento', (0.18, 0.62, 0.66))
MAT_madera = mat('MAT_Globo_Madera', (0.62, 0.40, 0.23))
MAT_oscura = mat('MAT_Globo_MaderaOscura', (0.27, 0.18, 0.12))
MAT_cuerda = mat('MAT_Globo_Cuerda', (0.78, 0.68, 0.48), rough=0.99)
MAT_farol = mat('MAT_Globo_Farol', (0.98, 0.76, 0.30), rough=0.50,
                emisivo=((1.00, 0.82, 0.42), 0.60))

MATS = (MAT_lona, MAT_acento, MAT_madera, MAT_oscura, MAT_cuerda, MAT_farol)


def malla(nombre, verts, caras, material, normal_ref=None):
    """Malla desde vertices/caras.

    normal_ref=None          -> recalc_face_normals (placas/partes cerradas).
    normal_ref='explicito'   -> NO recalcular; exigir normal radial saliente
                                en TODAS las caras (envolvente en gajos).
    normal_ref=callable(c)   -> recalcular, medir mayoria y voltear si hace
                                falta (casco abierto de la gondola).
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
        revisar = [(f.calc_center_median(), f.normal) for f in bm.faces]
        malas = 0
        for c, n in revisar:
            radial = Vector((c.x, 0.0, c.z - Z_ENV))
            if radial.length > 1e-6 and n.dot(radial.normalized()) < -0.02:
                malas += 1
        assert malas == 0, '%s: %d caras con normal hacia ADENTRO' % (
            nombre, malas)
        print('NORMALES %s: %d caras, 0 hacia adentro (winding explicito)' %
              (nombre, len(revisar)))
    else:
        bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
        if callable(normal_ref):
            buenas = malas = 0
            for f in bm.faces:
                c = f.calc_center_median()
                ref = normal_ref(c)
                if ref.length > 1e-6:
                    d = f.normal.dot(ref.normalized())
                    if d > 0.10:
                        buenas += 1
                    elif d < -0.10:
                        malas += 1
            if malas > buenas:
                bmesh.ops.reverse_faces(bm, faces=list(bm.faces))
                bm.normal_update()
            print('NORMALES %s: buenas=%d malas=%d flip=%s' %
                  (nombre, buenas, malas, malas > buenas))
    bm.to_mesh(me)
    bm.free()
    me.update()
    return ob


def barras(nombre, segmentos, radio, material, lados=4):
    """N prismas entre p0/p1 unidos en UN solo objeto (para no gastar objetos)."""
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


# ---------- 2) Estaciones de la envolvente ----------
# (y, radio). Cola puntiaguda en -Y, morro romo en +Y (silueta Zeppelin).
EST_ENV = [
    (-6.00, 0.10),
    (-5.55, 0.62),
    (-4.70, 1.30),
    (-3.50, 1.82),
    (-1.80, 2.06),
    (0.00, RADIO_MAX),
    (1.80, 2.06),
    (3.50, 1.82),
    (4.80, 1.32),
    (5.60, 0.78),
    (6.00, 0.28),
]


def interp_r(y):
    for i in range(len(EST_ENV) - 1):
        y0, r0 = EST_ENV[i]
        y1, r1 = EST_ENV[i + 1]
        if y0 <= y <= y1:
            u = (y - y0) / (y1 - y0)
            return r0 + (r1 - r0) * u
    return EST_ENV[-1][1]


def z_env_inf(y, x):
    """Cota INFERIOR de la envolvente en el lateral x (seccion circular).

    Permite verificar POSITIVAMENTE que un cable nace EN la tela y no 30 cm
    por debajo (pieza colgada) ni 30 cm por encima (atravesandola).
    """
    r = interp_r(y)
    return Z_ENV - math.sqrt(max(r * r - x * x, 0.0))


def angulo(j):
    return 2.0 * math.pi * j / N


# ---------- 3) Envolvente en 2 objetos, 6 gajos cada uno ----------
# Cada gajo es una tira de 10 quads. Winding (a, d, c, b) = normal SALIENTE:
#   p(ang,y)=(r cos, y, Z_ENV + r sin)  =>  (dp/dy)x(dp/dang) apunta afuera.
v_lona, f_lona, v_acento, f_acento = [], [], [], []
for j in range(N):
    V, F = (v_lona, f_lona) if j % 2 == 0 else (v_acento, f_acento)
    t0, t1 = angulo(j), angulo(j + 1)
    base = len(V)
    for (y, r) in EST_ENV:
        V.append((r * math.cos(t0), y, Z_ENV + r * math.sin(t0)))
        V.append((r * math.cos(t1), y, Z_ENV + r * math.sin(t1)))
    for i in range(len(EST_ENV) - 1):
        a = base + 2 * i          # estacion i, angulo t0
        b = a + 1                 # estacion i, angulo t1
        d = base + 2 * (i + 1)    # estacion i+1, angulo t0
        c = d + 1                 # estacion i+1, angulo t1
        F.append((a, d, c, b))


def tapa(V, F, y, r, signo):
    """Abanico de cierre. Cola (-Y): (c,j,j+1); Morro (+Y): (c,j+1,j)."""
    base = len(V)
    for j in range(N):
        t = angulo(j)
        V.append((r * math.cos(t), y, Z_ENV + r * math.sin(t)))
    c = len(V)
    V.append((0.0, y, Z_ENV))
    for j in range(N):
        k = (j + 1) % N
        F.append((c, base + j, base + k) if signo < 0
                 else (c, base + k, base + j))


tapa(v_lona, f_lona, EST_ENV[0][0], EST_ENV[0][1], -1)
tapa(v_lona, f_lona, EST_ENV[-1][0], EST_ENV[-1][1], +1)
env_lona = malla('SM_Globo_Envolvente_Lona', v_lona, f_lona, MAT_lona,
                 normal_ref='explicito')
env_gajos = malla('SM_Globo_Envolvente_Gajos', v_acento, f_acento,
                  MAT_acento, normal_ref='explicito')

# ---------- 4) Gondola (casco en U + cubierta + ventanas + farol) ----------
# (y, semimanga, z_borda, z_quilla). 5.00 m de largo, 1.44 m de manga.
EST_GOND = [
    (-2.60, 0.28, 2.05, 1.52),
    (-2.10, 0.62, 2.10, 1.30),
    (0.00, 0.72, 2.12, 1.20),
    (1.90, 0.58, 2.10, 1.32),
    (2.40, 0.24, 2.04, 1.54),
]
KG = 5


def interp_gond(y):
    for i in range(len(EST_GOND) - 1):
        y0, b0, t0, k0 = EST_GOND[i]
        y1, b1, t1, k1 = EST_GOND[i + 1]
        if y0 <= y <= y1:
            u = (y - y0) / (y1 - y0)
            return (b0 + (b1 - b0) * u, t0 + (t1 - t0) * u,
                    k0 + (k1 - k0) * u)
    return EST_GOND[-1][1], EST_GOND[-1][2], EST_GOND[-1][3]


def seccion_gond(y, b, z_top, z_kee):
    z_mid = z_kee + 0.55 * (z_top - z_kee)
    return [(-b, y, z_top), (-0.60 * b, y, z_mid), (0.0, y, z_kee),
            (0.60 * b, y, z_mid), (b, y, z_top)]


v_gond, f_gond = [], []
for est in EST_GOND:
    v_gond.extend(seccion_gond(*est))
for i in range(len(EST_GOND) - 1):
    for j in range(KG - 1):
        a = i * KG + j
        b = (i + 1) * KG + j
        f_gond.append((a, a + 1, b + 1, b))
for idx in (0, len(EST_GOND) - 1):
    y, _b, z_top, z_kee = EST_GOND[idx]
    pos = idx * KG
    centro = len(v_gond)
    v_gond.append((0.0, y, 0.5 * (z_top + z_kee)))
    for j in range(KG - 1):
        f_gond.append((centro, pos + j, pos + j + 1))


def ref_gond(c):
    """Normal esperada: alejandose del centro de la gondola."""
    return Vector((c.x, 0.0, c.z - Z_GOND_CENTRO))


casco_gond = malla('SM_Globo_Gondola_Casco', v_gond, f_gond, MAT_madera,
                   normal_ref=ref_gond)

# Cubierta: dos paneles que dejan un cockpit abierto en el centro.
def panel_gond(ys):
    v, f = [], []
    for y in ys:
        b, z_top, _k = interp_gond(y)
        w = 0.94 * b          # llega hasta el costado, como en T-01a
        v.extend([(-w, y, z_top - 0.06), (w, y, z_top - 0.06)])
    for i in range(len(ys) - 1):
        f.append((2 * i, 2 * i + 1, 2 * i + 3, 2 * i + 2))
    return v, f


v_a, f_a = panel_gond([-2.55, -2.10, -1.30])
v_b, f_b = panel_gond([1.20, 1.90, 2.35])
off = len(v_a)
malla('SM_Globo_Gondola_Cubierta', v_a + v_b,
      f_a + [tuple(i + off for i in c) for c in f_b], MAT_madera)
for _y in (-2.10, 1.90):
    _b, _zt, _zk = interp_gond(_y)
    assert abs(_zt - 0.06 - (Z_ENV - RADIO_MAX)) > 1.0, \
        'cubierta demasiado cerca de la envolvente'

# Ventanas: 3 por banda, ligeramente fuera del costado (sin z-fighting).
v_ven, f_ven = [], []
for y in (-1.60, -0.20, 1.20):
    b, _zt, _zk = interp_gond(y)
    for sgn in (-1, 1):
        x = sgn * (b + 0.012)
        base = len(v_ven)
        v_ven.extend([(x, y - 0.22, 1.58), (x, y + 0.22, 1.58),
                      (x, y + 0.22, 1.88), (x, y - 0.22, 1.88)])
        f_ven.append((base, base + 1, base + 2, base + 3))
malla('SM_Globo_Ventanas', v_ven, f_ven, MAT_farol)

# Farol de proa: cuelga del morro de la gondola, 8 slots de baul en el casco.
caja('SM_Globo_Farol', 0.0, 2.52, 1.78, 0.20, 0.20, 0.26, MAT_farol)
caja('SM_Globo_Canastilla', 0.0, -1.75, 2.18, 0.62, 0.52, 0.30, MAT_cuerda)

# ---------- 5) Cables de suspension (nacen EN la tela, medido) ----------
CABLE_X = 0.55
CABLE_YS = (-2.10, 1.80)
segs_cables = []
for y in CABLE_YS:
    z_top = z_env_inf(y, CABLE_X) + 0.02     # 2 cm dentro de la tela
    for sgn in (-1, 1):
        segs_cables.append(((sgn * CABLE_X, y, z_top),
                            (sgn * 0.52, y + 0.10, 2.06)))
        assert abs(z_top - z_env_inf(y, CABLE_X)) < 0.03, \
            'cable despegado de la envolvente en y=%.2f' % y
        assert z_top > 2.06 + 0.90, 'cable no llega a la gondola'
cables = barras('SM_Globo_Cuerdas', segs_cables, 0.035, MAT_cuerda)

# ---------- 6) Patines de aterrizaje + montantes (APOYO E-12/E-50) ----------
# DOS cajas = 8 vertices exactamente en z=0.045 (4 por cara inferior).
PATIN_X, PATIN_Y0, PATIN_Y1 = 0.85, -1.90, 1.90
PATIN_H, PATIN_W, PATIN_L = 0.18, 0.18, PATIN_Y1 - PATIN_Y0
PATIN_Z = Z_APOYO + PATIN_H / 2.0
PATIN_TOP = Z_APOYO + PATIN_H
for sgn, nombre in ((-1, 'SM_Globo_Patin_Izq'), (1, 'SM_Globo_Patin_Der')):
    caja(nombre, sgn * PATIN_X, 0.5 * (PATIN_Y0 + PATIN_Y1), PATIN_Z,
         PATIN_W, PATIN_L, PATIN_H, MAT_oscura)

segs_mont = []
for sgn in (-1, 1):
    for y in (-1.45, 1.45):
        segs_mont.append(((sgn * PATIN_X, y, PATIN_TOP),
                          (sgn * 0.48, y, 1.24)))
for p0, _p1 in segs_mont:
    assert abs(p0[2] - PATIN_TOP) < 1e-9, 'montante no apoya en el patin'
montantes = barras('SM_Globo_Montantes', segs_mont, 0.055, MAT_oscura)

# ---------- 7) Aletas de cola (4), helice de popa, banderin ----------
DIRS = ((0.0, 0.0, 1.0), (0.0, 0.0, -1.0), (-1.0, 0.0, 0.0),
        (1.0, 0.0, 0.0))
v_al, f_al = [], []
for dx, dy, dz in DIRS:
    d = Vector((dx, dy, dz))
    base = len(v_al)
    for (y, extra) in ((-4.40, 0.0), (-5.50, 0.0),
                       (-5.50, 0.90), (-4.90, 0.55)):
        r = interp_r(y) + extra
        v_al.append((d.x * r, y, Z_ENV + d.z * r))
    f_al.append((base, base + 1, base + 2, base + 3))
    # v_al guarda TUPLAS, no Vector: usar [2], no .z (AttributeError medido).
    assert d.length > 0.99 and abs(v_al[base][2] - (Z_ENV + d.z * interp_r(-4.40))) < 1e-6
malla('SM_Globo_Aletas', v_al, f_al, MAT_acento)

# Eje + helice de 3 palas en el plano XZ, en la cola (-Y).
EJE_Y0, EJE_Y1 = EST_ENV[0][0], -6.28
eje = barras('SM_Globo_Eje_Helice',
             [((0.0, EJE_Y0, Z_ENV), (0.0, EJE_Y1, Z_ENV))],
             0.055, MAT_oscura)
v_hel, f_hel = [], []
# Cubo del buje
for sx, sy, sz in ((-1, -1, -1), (1, -1, -1), (1, 1, -1), (-1, 1, -1),
                   (-1, -1, 1), (1, -1, 1), (1, 1, 1), (-1, 1, 1)):
    v_hel.append((0.10 * sx, EJE_Y1 + 0.06 * sy, Z_ENV + 0.10 * sz))
f_hel.extend([(0, 3, 2, 1), (4, 5, 6, 7), (0, 1, 5, 4),
              (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)])
for k in range(3):
    a = 2.0 * math.pi * k / 3.0
    dv = Vector((math.cos(a), 0.0, math.sin(a)))
    pv = Vector((-math.sin(a), 0.0, math.cos(a)))
    c = Vector((0.0, EJE_Y1, Z_ENV))
    base = len(v_hel)
    for radio, ancho in ((0.12, 0.11), (0.12, -0.11),
                         (0.78, -0.05), (0.78, 0.05)):
        p = c + radio * dv + ancho * pv
        v_hel.append(tuple(p))
    f_hel.append((base, base + 1, base + 2, base + 3))
malla('SM_Globo_Helice', v_hel, f_hel, MAT_oscura)

# Banderin sobre un mastil EN el morro.
# DEFECTO CORREGIDO (revision az000/az120): la primera version ponia la
# bandera en z=5.66..5.90 entre y=5.20 y 6.00. En y=5.20 la tela llega a
# z=Z_ENV+interp_r(5.20)=6.65, asi que la bandera quedaba ENTERRADA dentro
# del globo y solo asomaba un filo en el morro. Ahora el mastil NACE en la
# superficie (z_base) y el pendon queda por encima de la tela en TODO su
# recorrido, con guard numerico de despeje.
Y_MAST = 5.60
Z_BASE = Z_ENV + interp_r(Y_MAST)       # 6.38 = superficie REAL de la tela
Z_MAST = Z_BASE + 0.72
Y_PUNTA = Y_MAST - 0.70
Z_PUNTA = Z_MAST - 0.18
assert Z_PUNTA > Z_ENV + interp_r(Y_PUNTA) + 0.02, \
    'el pendon atraviesa la envolvente en y=%.2f (%.3f vs %.3f)' % (
        Y_PUNTA, Z_PUNTA, Z_ENV + interp_r(Y_PUNTA))
v_ban, f_ban = [], []
mx, my = 0.025, 0.025
for zz in (Z_BASE, Z_MAST):
    for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
        v_ban.append((sx * mx, Y_MAST + sy * my, zz))
f_ban = [(0, 3, 2, 1), (4, 5, 6, 7), (0, 1, 5, 4),
         (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)]
base = len(v_ban)
for x in (0.0, 0.045):
    v_ban.extend([(x, Y_MAST, Z_MAST - 0.04),
                  (x, Y_PUNTA, Z_PUNTA),
                  (x, Y_MAST, Z_MAST - 0.28)])
f_ban += [(base, base + 1, base + 2), (base + 3, base + 5, base + 4),
          (base, base + 3, base + 4, base + 1),
          (base + 1, base + 4, base + 5, base + 2),
          (base + 2, base + 5, base + 3, base)]
malla('SM_Globo_Bandera', v_ban, f_ban, MAT_acento)
print('BANDERIN: mastil z=%.3f (tela %.3f) -> %.3f, punta z=%.3f > tela %.3f'
      % (Z_BASE, Z_ENV + interp_r(Y_MAST), Z_MAST,
         Z_PUNTA, Z_ENV + interp_r(Y_PUNTA)))

# ---------- 8) Escena, asentado y medicion POSITIVA de cotas ----------
arena(radio=7.20)          # disco NO exportado; top z=0.05 (E-67)
iluminar(escena, energia=3.2)
camara(escena, 'CAM_Globo', loc=(15.0, -20.0, 10.0), mira=(0.0, 0.0, 3.4))
shade_flat(escena)
z_fin, n_toca, fp_x, fp_y = asentar(escena)
bpy.context.view_layer.update()

piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_')]
pts = [o.matrix_world @ v.co for o in piezas for v in o.data.vertices]
xs = [p.x for p in pts]
ys = [p.y for p in pts]
zs = [p.z for p in pts]
# La ESLORA se mide sobre la ENVOLVENTE: la helice y el banderin sobresalen
# y estiran el bbox. Reportar las dos evita confundir "12 m de dirigible"
# con "12.3 m de bounding box incluyendo la helice".
ys_env = [(env_lona.matrix_world @ v.co).y for v in env_lona.data.vertices]
ys_env += [(env_gajos.matrix_world @ v.co).y for v in env_gajos.data.vertices]
eslora_env = max(ys_env) - min(ys_env)
cota_y_total = max(ys) - min(ys)
manga = max(xs) - min(xs)
alto_total = max(zs) - min(zs)
print('COTAS: eslora_env=%.3f cota_y_total=%.3f manga=%.3f '
      'alto_total=%.3f z_min=%.4f z_max=%.4f'
      % (eslora_env, cota_y_total, manga, alto_total, min(zs), max(zs)))
print('APOYO: toca=%d footprint=%.3f x %.3f' % (n_toca, fp_x, fp_y))
print('PIEZAS SM_: %d  MATERIALES: %d' % (len(piezas), len(MATS)))

# --- Guardas POSITIVAS (el "no fallo" del script NO alcanza) ---
assert abs(eslora_env - ESLORA) < 0.02, \
    'eslora envolvente %.3f != %.2f' % (eslora_env, ESLORA)
assert abs(min(zs) - Z_APOYO) < 1e-4, 'z_min %.4f != Z_APOYO' % min(zs)
assert abs(max(zs) - (Z_ENV + RADIO_MAX)) < 0.10, \
    'techo de la envolvente no esta donde se diseno: %.3f' % max(zs)
assert n_toca >= 8 and min(fp_x, fp_y) > 0.30, 'huella puntual (E-50)'
assert len(piezas) <= 16, 'ALTA excede 16 objetos: %d' % len(piezas)
assert len(MATS) == 6, '6 materiales => 6 grupos => BAJA 6 objetos'
# La gondola cuelga DEBAJO de la envolvente, con luz real para los cables.
assert 2.12 < Z_ENV - RADIO_MAX - 0.50, \
    'gondola pegada a la envolvente: no hay sitio para los cables'
for _o, _nom in ((cables, 'SM_Globo_Cuerdas'),
                 (montantes, 'SM_Globo_Montantes'),
                 (eje, 'SM_Globo_Eje_Helice')):
    assert _o is not None and len(_o.data.vertices) > 0, \
        '%s existe pero esta VACIA' % _nom
assert any(o.name == 'SM_Globo_Helice' and len(o.data.vertices) >= 20
           for o in piezas), 'helice sin palas reales'
assert abs(EJE_Y0 - EST_ENV[0][0]) < 1e-9 and EJE_Y1 < EJE_Y0, \
    'eje de la helice no nace en la punta de cola'

guardar(escena, '67-Vehiculos', 'globo_del_viento')
