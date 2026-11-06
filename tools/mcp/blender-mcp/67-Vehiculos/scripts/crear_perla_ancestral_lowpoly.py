# crear_perla_ancestral_lowpoly.py -- T-01c (M67), Hy4, 2026-11-06
#
# Perla Ancestral: vehiculo de SUBAGUA (submarino), eslora de casco 8.00 m.
# Fuente de datos: game/isla-ancestral/data/vehiculos/vehicles.json
#   id=submarino, tipo=subagua, nombre="Perla Ancestral", velocidad_max=8,
#   profundidad_max=-40.0, baul_slots=10, tiene_reversa=true.
#   La profundidad la aplica el RUNTIME (M67); el asset solo aporta geometria
#   con la referencia comun de apoyo del proyecto.
#
# DECISION DE DISENO (busqueda Poly Haven MEDIDA antes de generar):
#   Catalogo completo por API con User-Agent: 521 modelos.
#   CERO submarinos / sumergibles / nautilus / bathiscafos. Los 4 candidatos
#   por palabra clave "underwater" son FALSOS POSITIVOS (3 estatuas de bronce
#   de ray/tiburon/ballena + una concha lambis). Los 4 barcos del catalogo
#   (dutch_ship_large_01/02, dutch_ship_medium, ship_pinnace) midieron
#   69162..183837 polys y 24..40 m: fuera de presupuesto M166 y de escala.
#   Se usa la alternativa CUSTOM LOWPOLY que el backlog 07 habilita.
#
# REGLAS APLICADAS:
#   E-12 Z_APOYO=0.045. Para un vehiculo SUBAGUA el apoyo lo dan DOS PATINES
#       de quilla: el asset se modela en configuracion "posado / en dique".
#   E-24 asentado medido sobre VERTICES REALES, nunca bound_box.
#   E-44 solo SM_ se exporta; Base_Arena/SOL/CAM_* se purgan en el export.
#   E-47 la fuente se guarda como <asset>_lowpoly.blend.
#   E-50 huella no puntual: DOS cajas = 8 vertices de apoyo (4 por cara
#       inferior), footprint 1.78 x 3.60 m.
#   E-60/E-62 las piezas MONTADAS (torreta, escotilla, periscopio, ojos de
#       buey, aletas, helice, caja de carga, perla) NO usan Z_APOYO: se
#       validan por guard POSITIVO contra la superficie REAL del casco.
#   E-32 normales: el casco se construye con winding explicito hacia AFUERA
#       y se MIDE cara por cara, no se confia en recalc_face_normals sobre
#       tiras abiertas.
#   DECISION DE 4 MATERIALES (defecto REAL detectado en la hoja BAJA):
#       Con 6 materiales la poda BAJA --max-mats 4 conservaba los 4 de MAS
#       caras y remapeaba Cristal (ojos de buey + perla) y Coral (caja) a
#       Casco (blanco). Resultado MEDIDO en la hoja _hoja_cap_67_perla_baja:
#       la perla, los ojos de buey y la caja se volvian BLANCOS sobre un casco
#       blanco y el asset perdia su identidad. El derivador elige por numero
#       de caras, no por importancia, y CRITICAS_NO_FUNDIR esta vacio en el
#       script COMPARTIDO (que no se toca). Solucion LOCAL: usar exactamente
#       4 materiales => la poda 4 <= 4 NO corre => ningun color se remapea.
#       Presupuesto: 4 grupos de merge => MEDIA 4 obj (<=8) y BAJA 4 obj
#       (<=6), 4 mats (<=4). Cada pieza lleva UN solo material.
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
ESLORA = 8.00          # largo del CASCO (eje Y), popa -4.00 -> proa +4.00
RADIO_MAX = 1.05
Z_CASCO = 1.42         # altura del eje del casco; vientre en 0.37, lomo en 2.47
N = 12                 # sectores angulares (6 gajos casco + 6 gajos acento)

# ---------- 1) Materiales: EXACTAMENTE 4 (BAJA no necesita poda) ----------
MAT_casco = mat('MAT_Perla_Casco', (0.87, 0.93, 0.94), rough=0.62)
MAT_acento = mat('MAT_Perla_Acento', (0.13, 0.44, 0.52), rough=0.80)
MAT_cristal = mat('MAT_Perla_Cristal', (0.98, 0.80, 0.38), rough=0.40,
                  emisivo=((1.00, 0.84, 0.45), 0.75))
MAT_oscuro = mat('MAT_Perla_MetalOscuro', (0.20, 0.24, 0.28), rough=0.72)

MATS = (MAT_casco, MAT_acento, MAT_cristal, MAT_oscuro)


def malla(nombre, verts, caras, material, normal_ref=None):
    """Malla desde vertices/caras.

    normal_ref=None        -> recalc_face_normals (piezas cerradas).
    normal_ref='explicito' -> NO recalcular; exigir normal radial SALIENTE
                              en TODAS las caras (casco en gajos).
    normal_ref=callable(c) -> recalcular, medir mayoria y voltear si hace
                              falta (torreta).
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
            radial = Vector((c.x, 0.0, c.z - Z_CASCO))
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
                    dot = f.normal.dot(ref.normalized())
                    if dot > 0.10:
                        buenas += 1
                    elif dot < -0.10:
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


# ---------- 2) Estaciones del casco ----------
# (y, radio). Popa estrecha para el eje de la helice, proa roma.
EST_CASCO = [
    (-4.00, 0.20),
    (-3.75, 0.46),
    (-3.30, 0.78),
    (-2.40, 1.00),
    (-1.00, 1.05),
    (0.60, RADIO_MAX),
    (2.20, 0.96),
    (3.20, 0.74),
    (3.75, 0.46),
    (4.00, 0.26),
]


def interp_r(y):
    for i in range(len(EST_CASCO) - 1):
        y0, r0 = EST_CASCO[i]
        y1, r1 = EST_CASCO[i + 1]
        if y0 <= y <= y1:
            u = (y - y0) / (y1 - y0)
            return r0 + (r1 - r0) * u
    return EST_CASCO[-1][1]


def z_casco_inf(y, x):
    """Vientre REAL del casco en el lateral x (seccion circular).

    Permite verificar POSITIVAMENTE que un montante nace EN el casco y no
    30 cm por debajo (pieza colgada) ni 30 cm por encima (atravesandolo).
    """
    r = interp_r(y)
    return Z_CASCO - math.sqrt(max(r * r - x * x, 0.0))


def z_casco_sup(y):
    """Lomo del casco en x=0 (para apoyar torreta y caja de carga)."""
    return Z_CASCO + interp_r(y)


def angulo(j):
    return 2.0 * math.pi * j / N


# ---------- 3) Casco en 2 objetos, 6 gajos cada uno ----------
# p(ang,y)=(r cos, y, Z_CASCO + r sin); winding (a,d,c,b) = normal SALIENTE.
v_casco, f_casco, v_gajos, f_gajos = [], [], [], []
for j in range(N):
    V, F = (v_casco, f_casco) if j % 2 == 0 else (v_gajos, f_gajos)
    t0, t1 = angulo(j), angulo(j + 1)
    base = len(V)
    for (y, r) in EST_CASCO:
        V.append((r * math.cos(t0), y, Z_CASCO + r * math.sin(t0)))
        V.append((r * math.cos(t1), y, Z_CASCO + r * math.sin(t1)))
    for i in range(len(EST_CASCO) - 1):
        a = base + 2 * i
        b = a + 1
        d = base + 2 * (i + 1)
        c = d + 1
        F.append((a, d, c, b))


def tapa(V, F, y, r, signo):
    """Abanico de cierre. Popa (-Y): (c,j,j+1); Proa (+Y): (c,j+1,j)."""
    base = len(V)
    for j in range(N):
        t = angulo(j)
        V.append((r * math.cos(t), y, Z_CASCO + r * math.sin(t)))
    c = len(V)
    V.append((0.0, y, Z_CASCO))
    for j in range(N):
        k = (j + 1) % N
        F.append((c, base + j, base + k) if signo < 0
                 else (c, base + k, base + j))


tapa(v_casco, f_casco, EST_CASCO[0][0], EST_CASCO[0][1], -1)
tapa(v_casco, f_casco, EST_CASCO[-1][0], EST_CASCO[-1][1], +1)
casco_liso = malla('SM_Perla_Casco_Liso', v_casco, f_casco, MAT_casco,
                   normal_ref='explicito')
casco_gajos = malla('SM_Perla_Casco_Gajos', v_gajos, f_gajos, MAT_acento,
                    normal_ref='explicito')

# ---------- 4) Torreta (vela) + escotilla + periscopio ----------
Y_TORRE = -0.35
Z_TORRE_BASE = 2.20        # 27 cm DENTRO del lomo (2.47): no flota
Z_TORRE_TOP = 3.02
assert Z_TORRE_BASE < z_casco_sup(Y_TORRE) - 0.05, \
    'la torreta no penetra el casco: %.3f vs %.3f' % (
        Z_TORRE_BASE, z_casco_sup(Y_TORRE))

PERIM_TORRE = [(-0.31, -0.85), (0.31, -0.85), (0.40, -0.60),
               (0.40, 0.60), (0.31, 0.85), (-0.31, 0.85),
               (-0.40, 0.60), (-0.40, -0.60)]
NT = len(PERIM_TORRE)
v_torre, f_torre = [], []
for z, esc in ((Z_TORRE_BASE, 1.0), (Z_TORRE_TOP, 0.86)):
    for (px, py) in PERIM_TORRE:
        v_torre.append((px * esc, Y_TORRE + py * esc, z))
for i in range(NT):
    j = (i + 1) % NT
    f_torre.append((i, j, NT + j, NT + i))
centro = len(v_torre)
v_torre.append((0.0, Y_TORRE, Z_TORRE_TOP))
for i in range(NT):
    f_torre.append((centro, NT + i, NT + (i + 1) % NT))


def ref_torre(c):
    return Vector((c.x, c.y - Y_TORRE, c.z - 0.5 * (Z_TORRE_BASE + Z_TORRE_TOP)))


malla('SM_Perla_Torreta', v_torre, f_torre, MAT_casco, normal_ref=ref_torre)

HATCH_H = 0.08
escotilla = caja('SM_Perla_Escotilla', 0.0, Y_TORRE,
                 Z_TORRE_TOP + HATCH_H / 2, 0.46, 0.46, HATCH_H, MAT_cristal)
bpy.context.view_layer.update()
z_hatch_min = min((escotilla.matrix_world @ v.co).z
                  for v in escotilla.data.vertices)
assert abs(z_hatch_min - Z_TORRE_TOP) < 1e-6, \
    'la escotilla no apoya en el techo de la torreta: %.4f vs %.4f' % (
        z_hatch_min, Z_TORRE_TOP)

Z_PERI_BASE = Z_TORRE_TOP + HATCH_H
Z_PERI_TOP = 3.52
peri = barras('SM_Perla_Periscopio',
              [((0.0, Y_TORRE, Z_PERI_BASE), (0.0, Y_TORRE, Z_PERI_TOP)),
               ((0.0, Y_TORRE, Z_PERI_TOP), (0.0, Y_TORRE - 0.27, Z_PERI_TOP))],
              0.035, MAT_oscuro, lados=6)
bpy.context.view_layer.update()
z_peri_min = min((peri.matrix_world @ v.co).z for v in peri.data.vertices)
assert abs(z_peri_min - Z_PERI_BASE) < 1e-4, \
    'el periscopio no nace en la escotilla: %.4f vs %.4f' % (
        z_peri_min, Z_PERI_BASE)

# Barandilla de la torreta: 4 postes + 2 travesanos, en UN objeto.
segs_bar = []
for (px, py) in ((-0.34, -0.72), (0.34, -0.72), (-0.34, 0.72), (0.34, 0.72)):
    segs_bar.append(((px, Y_TORRE + py, Z_TORRE_TOP),
                     (px, Y_TORRE + py, Z_TORRE_TOP + 0.22)))
for py in (-0.72, 0.72):
    segs_bar.append(((-0.34, Y_TORRE + py, Z_TORRE_TOP + 0.22),
                     (0.34, Y_TORRE + py, Z_TORRE_TOP + 0.22)))
barandilla = barras('SM_Perla_Barandilla', segs_bar, 0.022, MAT_cristal)

# ---------- 5) Ojos de buey (3 por banda) sobre el lateral REAL ----------
v_ojos, f_ojos = [], []
OJO_Y = (-1.80, -0.20, 1.40)
for y in OJO_Y:
    r = interp_r(y)
    for sgn in (-1, 1):
        x = sgn * (r + 0.012)
        base = len(v_ojos)
        v_ojos.extend([(x, y - 0.17, Z_CASCO - 0.13),
                       (x, y + 0.17, Z_CASCO - 0.13),
                       (x, y + 0.17, Z_CASCO + 0.13),
                       (x, y - 0.17, Z_CASCO + 0.13)])
        f_ojos.append((base, base + 1, base + 2, base + 3))
        assert abs(x) > r + 0.005, 'ojo de buey ENTERRADO en el casco'
        assert abs(x) - r < 0.03, 'ojo de buey DESPEGADO del casco'
malla('SM_Perla_OjosDeBuey', v_ojos, f_ojos, MAT_cristal)

# ---------- 6) Caja de carga (baul_slots=10) apoyada en el lomo ----------
Y_CARGA = 1.60
Z_CARGA_BASE = z_casco_sup(Y_CARGA) - 0.02
caja('SM_Perla_Carga', 0.0, Y_CARGA, Z_CARGA_BASE + 0.14,
     0.70, 0.85, 0.28, MAT_acento)
assert Z_CARGA_BASE < z_casco_sup(Y_CARGA) < Z_CARGA_BASE + 0.05, \
    'la caja de carga no esta montada sobre el lomo del casco'

# ---------- 7) Aletas de popa (4) + planos de proa (2) ----------
v_al, f_al = [], []
DIRS_POPA = ((0.0, 1.0), (0.0, -1.0), (-1.0, 0.0), (1.0, 0.0))
for dx, dz in DIRS_POPA:
    d = Vector((dx, 0.0, dz))
    base = len(v_al)
    for (y, extra) in ((-3.30, 0.0), (-4.00, 0.0),
                       (-4.00, 0.55), (-3.55, 0.45)):
        r = interp_r(y) + extra
        v_al.append((d.x * r, y, Z_CASCO + d.z * r))
    f_al.append((base, base + 1, base + 2, base + 3))
    # Guard POSITIVO: el primer vertice esta EXACTAMENTE en la superficie.
    p0 = v_al[base]
    r0 = interp_r(-3.30)
    assert abs(p0[0] - d.x * r0) < 1e-9 and \
        abs(p0[2] - (Z_CASCO + d.z * r0)) < 1e-9, \
        'aleta de popa despegada del casco'
for sgn in (-1, 1):
    y = 2.20
    r = interp_r(y)
    base = len(v_al)
    for (yy, extra) in ((y - 0.45, 0.0), (y + 0.35, 0.0),
                        (y + 0.35, 0.52), (y - 0.10, 0.42)):
        rr = interp_r(yy) + extra
        v_al.append((sgn * rr, yy, Z_CASCO))
    f_al.append((base, base + 1, base + 2, base + 3))
    assert abs(v_al[base][0] - sgn * interp_r(y - 0.45)) < 1e-9, \
        'plano de proa despegado del casco'
aletas = malla('SM_Perla_Aletas', v_al, f_al, MAT_acento)
assert len(aletas.data.vertices) == 24, 'faltan aletas: %d vertices' % \
    len(aletas.data.vertices)

# ---------- 8) Eje + helice de 3 palas en la popa ----------
EJE_Y0, EJE_Y1 = EST_CASCO[0][0], -4.32
eje = barras('SM_Perla_Eje_Helice',
             [((0.0, EJE_Y0, Z_CASCO), (0.0, EJE_Y1, Z_CASCO))],
             0.045, MAT_oscuro)
v_hel, f_hel = [], []
for sx, sy, sz in ((-1, -1, -1), (1, -1, -1), (1, 1, -1), (-1, 1, -1),
                   (-1, -1, 1), (1, -1, 1), (1, 1, 1), (-1, 1, 1)):
    v_hel.append((0.09 * sx, EJE_Y1 + 0.06 * sy, Z_CASCO + 0.09 * sz))
f_hel.extend([(0, 3, 2, 1), (4, 5, 6, 7), (0, 1, 5, 4),
              (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)])
for k in range(3):
    a = 2.0 * math.pi * k / 3.0
    dv = Vector((math.cos(a), 0.0, math.sin(a)))
    pv = Vector((-math.sin(a), 0.0, math.cos(a)))
    c = Vector((0.0, EJE_Y1, Z_CASCO))
    base = len(v_hel)
    for radio, ancho in ((0.10, 0.10), (0.10, -0.10),
                         (0.66, -0.05), (0.66, 0.05)):
        p = c + radio * dv + ancho * pv
        v_hel.append(tuple(p))
    f_hel.append((base, base + 1, base + 2, base + 3))
helice = malla('SM_Perla_Helice', v_hel, f_hel, MAT_cristal)

# Perla ancestral: octaedro luminoso engarzado en la proa (da nombre al asset).
Y_PERLA = 4.12
R_PERLA = 0.20
v_per = [(R_PERLA, Y_PERLA, Z_CASCO), (-R_PERLA, Y_PERLA, Z_CASCO),
         (0.0, Y_PERLA + R_PERLA, Z_CASCO), (0.0, Y_PERLA - R_PERLA, Z_CASCO),
         (0.0, Y_PERLA, Z_CASCO + R_PERLA), (0.0, Y_PERLA, Z_CASCO - R_PERLA)]
f_per = [(0, 2, 4), (2, 1, 4), (1, 3, 4), (3, 0, 4),
         (2, 0, 5), (1, 2, 5), (3, 1, 5), (0, 3, 5)]
malla('SM_Perla_Gema', v_per, f_per, MAT_cristal)
assert Y_PERLA - R_PERLA < EST_CASCO[-1][0], \
    'la perla no esta engarzada en la proa'

# ---------- 9) Patines de quilla + montantes (APOYO E-12/E-50) ----------
PATIN_X, PATIN_Y0, PATIN_Y1 = 0.82, -1.80, 1.80
PATIN_H, PATIN_W, PATIN_L = 0.18, 0.18, PATIN_Y1 - PATIN_Y0
PATIN_Z = Z_APOYO + PATIN_H / 2.0
PATIN_TOP = Z_APOYO + PATIN_H
for sgn, nombre in ((-1, 'SM_Perla_Patin_Izq'), (1, 'SM_Perla_Patin_Der')):
    caja(nombre, sgn * PATIN_X, 0.5 * (PATIN_Y0 + PATIN_Y1), PATIN_Z,
         PATIN_W, PATIN_L, PATIN_H, MAT_oscuro)

segs_mont = []
for sgn in (-1, 1):
    for y in (-1.35, 1.35):
        x_top = 0.55
        z_top = z_casco_inf(y, x_top) + 0.02   # 2 cm dentro del casco
        segs_mont.append(((sgn * PATIN_X, y, PATIN_TOP),
                          (sgn * x_top, y, z_top)))
        assert abs(z_top - z_casco_inf(y, x_top)) < 0.03, \
            'montante despegado del casco en y=%.2f' % y
        assert z_top > PATIN_TOP + 0.15, 'montante no llega al casco'
montantes = barras('SM_Perla_Montantes', segs_mont, 0.050, MAT_oscuro)
for p0, _p1 in segs_mont:
    assert abs(p0[2] - PATIN_TOP) < 1e-9, 'montante no apoya en el patin'

# ---------- 10) Escena, asentado y medicion POSITIVA de cotas ----------
arena(radio=6.00)          # disco NO exportado; top z=0.05 (E-67)
iluminar(escena, energia=3.2)
camara(escena, 'CAM_Perla', loc=(11.0, -15.0, 7.0), mira=(0.0, 0.0, 1.7))
shade_flat(escena)
z_fin, n_toca, fp_x, fp_y = asentar(escena)
bpy.context.view_layer.update()

piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_')]
pts = [o.matrix_world @ v.co for o in piezas for v in o.data.vertices]
xs = [p.x for p in pts]
ys = [p.y for p in pts]
zs = [p.z for p in pts]
ys_casco = [(casco_liso.matrix_world @ v.co).y for v in casco_liso.data.vertices]
ys_casco += [(casco_gajos.matrix_world @ v.co).y for v in casco_gajos.data.vertices]
eslora_casco = max(ys_casco) - min(ys_casco)
cota_y_total = max(ys) - min(ys)
manga = max(xs) - min(xs)
alto_total = max(zs) - min(zs)
print('COTAS: eslora_casco=%.3f cota_y_total=%.3f manga=%.3f '
      'alto_total=%.3f z_min=%.4f z_max=%.4f'
      % (eslora_casco, cota_y_total, manga, alto_total, min(zs), max(zs)))
print('APOYO: toca=%d footprint=%.3f x %.3f' % (n_toca, fp_x, fp_y))
print('PIEZAS SM_: %d  MATERIALES: %d' % (len(piezas), len(MATS)))

# --- Guardas POSITIVAS (el "no fallo" del script NO alcanza) ---
assert abs(eslora_casco - ESLORA) < 0.02, \
    'eslora casco %.3f != %.2f' % (eslora_casco, ESLORA)
assert abs(min(zs) - Z_APOYO) < 1e-4, 'z_min %.4f != Z_APOYO' % min(zs)
assert 3.45 < max(zs) < 3.70, \
    'el periscopio no sobresale por encima del casco: %.3f' % max(zs)
assert n_toca >= 8 and min(fp_x, fp_y) > 0.30, 'huella puntual (E-50)'
assert len(piezas) <= 16, 'ALTA excede 16 objetos: %d' % len(piezas)
assert len(MATS) == 4, '4 materiales => 4 grupos y BAJA sin poda: %d' % len(MATS)
assert z_casco_inf(0.0, 0.0) > PATIN_TOP + 0.10, \
    'el casco esta pegado a los patines: no hay sitio para los montantes'
for _o, _nom in ((peri, 'SM_Perla_Periscopio'),
                 (barandilla, 'SM_Perla_Barandilla'),
                 (montantes, 'SM_Perla_Montantes'),
                 (eje, 'SM_Perla_Eje_Helice')):
    assert _o is not None and len(_o.data.vertices) > 0, \
        '%s existe pero esta VACIA' % _nom
assert len(helice.data.vertices) >= 20, 'helice sin palas reales'
assert abs(EJE_Y0 - EST_CASCO[0][0]) < 1e-9 and EJE_Y1 < EJE_Y0, \
    'eje de la helice no nace en la punta de popa'
assert len(v_ojos) == 24, 'faltan ojos de buey: %d vertices' % len(v_ojos)

guardar(escena, '67-Vehiculos', 'perla_ancestral')
