# crear_carreta_ancestral_lowpoly.py -- T-02 (M157 / T04 Carreta), Hy4, 2026-11-06
#
# Carreta Ancestral: carreta de DOS RUEDAS con toldo de lona y limones (varas)
# para el animal de tiro. 4.20 m de largo total (eje Y), 2.21 m de manga,
# 2.36 m de alto. El ANIMAL NO SE MODELA: es un NPC de M19/M22 (dueno ajeno);
# el runtime lo engancha a los limones. Solo se entrega la geometria del carro.
#
# Fuente de datos:
#   DOCUMENTACION/157-Medios-De-Transporte/plan-actual/03-Diseno.md
#     T04 Carreta | 0.5x | Media (25 items) | 25 monedas | Inicio | 10-15 evt
#   02-Analisis.md: "Recorrido terrestre lido por animales. Velocidad baja.
#     Contacto cercano con el entorno." + eventos EVT-C01..C08.
#   01-Requerimientos.md RF-04 (5 tipos: Barco, Tren, Avion, Carreta, A pie).
#   05-Checklist.md C-15 (escenas 3D representativas) y C-10 (definicion 0.5x).
#   M67 vehicles.json NO define `carreta`: solo barco/dirigible/submarino/
#   locomotora. La Carreta es el tipo M157 que NO tiene asset equivalente.
#
# CONDICION DE ARRANQUE (05-Checklist.md L26): requiere GO del fundador +
# vision M154 + owner de gameplay; "sin GO, la implementacion no debe
# empezar". Por eso ESTA TAREA ES SOLO DE ASSET (autoria Blender, nicho Hy4
# segun #04/#05 de la directora). NO se toca runtime, escenas, terrain
# locator, TransportManager ni scripts de M157: siguen BLOQUEADOS sin GO.
#
# DECISION DE DISENO (busqueda Poly Haven MEDIDA antes de generar):
#   Catalogo completo por API con User-Agent: 521 modelos.
#   CERO carretas / wagons / carriages / chariots / oxcarts / buggies /
#   trineos / carretillas de animal. 18 hits por keyword son FALSOS POSITIVOS:
#     - 4 `cart` (CoffeeCart_01, industrial_storage_cart,
#       portable_welding_cart, tool_cart): muebles industriales medidos en
#       T-01d, 18902..29418 polys y 0.84..2.17 m.
#     - 2 `horse` (horse_head, horse_statue_01): estatuas decorativas.
#     - 12 `ox` son SUBSTRING de `box` (ammo_box, boombox, planter_box_01..03,
#       cardboard_box_01, CheeseBox_01, medical_box, metal_toolbox,
#       power_box_01, utility_box_01/02). TRAMPA NUEVA de substring: buscar
#       "oxcart" por la raiz "ox" pesca cajas, no bueyes.
#   Se usa la alternativa CUSTOM LOWPOLY que el backlog 07 habilita.
#
# REGLAS APLICADAS:
#   E-12 Z_APOYO=0.045; el apoyo lo dan las 2 RUEDAS (octogono de arista
#       inferior plana), no patines. 8 vertices reales de huella.
#   E-24 asentado medido sobre VERTICES REALES, nunca bound_box.
#   E-44 solo SM_ se exporta; Base_Arena/SOL/CAM_* se purgan en el export.
#   E-47 la fuente se guarda como <asset>_lowpoly.blend.
#   E-50 huella no puntual: se mide en asentar() (min_toca=8, min_fp=0.30).
#   E-60/E-62 las piezas MONTADAS (lona, aros, cubos, carga, farol,
#       limones, eje) NO usan Z_APOYO: se validan por guard POSITIVO contra
#       la superficie REAL que las sostiene.
#   E-32 la lona se construye con winding explicito hacia AFUERA y se MIDE
#       cara por cara (producto punto radial), sin recalc sobre tiras abiertas.
#   DECISION DE 4 MATERIALES (fix REAL de T-01c, acta 15; reusado en T-01d):
#       Con 6 materiales la poda BAJA --max-mats 4 blanqueaba piezas de
#       identidad. Con EXACTAMENTE 4 la poda es un NO-OP: 4 grupos de
#       merge => MEDIA 4 obj (<=8) y BAJA 4 obj (<=6), 4 mats (<=4).
#       No se toca generar_variante.py (script COMPARTIDO).
#   E-63: el modulo 157-Medios-De-Transporte debe agregarse a MODULOS en
#       exportar_godot.py o los 3 GLB se exportan EN SILENCIO 0 archivos.
import bpy
import bmesh
import math
import os
import sys
from mathutils import Vector

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar,
                             camara, shade_flat, guardar)

escena = limpiar()

Z_APOYO = 0.045
Y_POPA, Y_PROA = -1.90, 2.30
LARGO = Y_PROA - Y_POPA            # 4.20 m
BED_Y0, BED_Y1 = -1.90, 1.10      # plataforma 3.00 m
BED_W, BED_H, BED_Z = 1.70, 0.16, 1.04
BED_TOP = BED_Z + BED_H / 2.0     # 1.12
Z_LONA_BASE = 1.52                # linea de arranque del toldo
R_LONA = 0.88                     # cima = 2.40
LONA_Y = (-1.55, -0.95, -0.35, 0.25, 0.85)
LONA_M = (0.94, 1.00, 1.00, 1.00, 0.94)
N_ARCO = 8
R_RUEDA, RIN_RUEDA = 0.62, 0.10
T_RUEDA, X_RUEDA, Y_RUEDA = 0.08, 1.02, -0.30
COS_PLANO = math.cos(math.pi / 8.0)   # 0.92388: fondo plano del octogono
Z_RUEDA = Z_APOYO + COS_PLANO * R_RUEDA

# ---------- 1) Materiales: EXACTAMENTE 4 (BAJA no necesita poda) ----------
MAT_madera = mat('MAT_Carreta_Madera', (0.56, 0.37, 0.21), rough=0.86)
MAT_lona = mat('MAT_Carreta_Lona', (0.92, 0.86, 0.70), rough=0.92,
               emisivo=((1.00, 0.88, 0.62), 0.10))
MAT_acento = mat('MAT_Carreta_Verde', (0.16, 0.45, 0.42), rough=0.80)
MAT_hierro = mat('MAT_Carreta_Hierro', (0.20, 0.22, 0.24), rough=0.74)

MATS = (MAT_madera, MAT_lona, MAT_acento, MAT_hierro)


def malla(nombre, verts, caras, material, normal_ref=None, z_eje=None):
    """Malla desde vertices/caras.

    normal_ref='explicito' -> NO recalcular; exigir normal radial SALIENTE
    en TODAS las caras de la lona (tira abierta). z_eje = centro del arco.
    normal_ref='ninguno'   -> NO recalcular (aros de dos caras, winding dado).
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
    elif normal_ref is None:
        bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(me)
    bm.free()
    me.update()
    return ob


def add_caja(V, F, c, s):
    """UNA caja centrada a acumuladores V/F (ahorra objetos)."""
    x, y, z = c
    sx, sy, sz = s
    base = len(V)
    for dx, dy, dz in ((-1, -1, -1), (1, -1, -1), (1, 1, -1), (-1, 1, -1),
                       (-1, -1, 1), (1, -1, 1), (1, 1, 1), (-1, 1, 1)):
        V.append((x + dx * sx / 2.0, y + dy * sy / 2.0, z + dz * sz / 2.0))
    for q in ((0, 3, 2, 1), (4, 5, 6, 7), (0, 1, 5, 4),
              (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)):
        F.append(tuple(base + i for i in q))


def add_viga(V, F, p0, p1, w, h):
    """Prisma entre p0 y p1; seccion w en X y h en Z (para limones/barra)."""
    base = len(V)
    for (x, y, z) in (p0, p1):
        V.extend([(x - w / 2.0, y, z - h / 2.0),
                  (x + w / 2.0, y, z - h / 2.0),
                  (x + w / 2.0, y, z + h / 2.0),
                  (x - w / 2.0, y, z + h / 2.0)])
    for q in ((0, 3, 2, 1), (4, 5, 6, 7), (0, 1, 5, 4),
              (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)):
        F.append(tuple(base + i for i in q))


def add_rueda(V, F, x, y, z, r, t, lados=8, rin=0.10, nsp=6):
    """Rueda de eje X: llanta de ESPESOR + 6 rayos + cubo.

    ARISTA INFERIOR PLANA: angulo -5*pi/8 + k*2*pi/lados deja 2 vertices
    abajo en cada anillo (fondo en z - r*cos(pi/8)).
    """
    base = len(V)
    for xx in (x - t, x + t):
        for rad in (r, r - rin):
            for k in range(lados):
                a = -5.0 * math.pi / 8.0 + k * 2.0 * math.pi / lados
                V.append((xx, y + rad * math.cos(a), z + rad * math.sin(a)))
    r0, r1, r2, r3 = 0, lados, 2 * lados, 3 * lados
    for k in range(lados):
        j = (k + 1) % lados
        # superficie exterior, interior y dos caras del anillo
        F.append((base + r0 + k, base + r2 + k, base + r2 + j, base + r0 + j))
        F.append((base + r1 + k, base + r1 + j, base + r3 + j, base + r3 + k))
        F.append((base + r0 + k, base + r0 + j, base + r1 + j, base + r1 + k))
        F.append((base + r2 + k, base + r3 + k, base + r3 + j, base + r2 + j))
    # Rayos: quads de DOS CARAS en el plano central de la rueda.
    for k in range(nsp):
        a = k * 2.0 * math.pi / nsp
        ux, uz = math.cos(a), math.sin(a)
        vx, vz = -uz, ux
        q = []
        for rad, ancho in ((0.10, 0.028), (r - rin, 0.018)):
            q.append((x, y + rad * ux - ancho * vx, z + rad * uz - ancho * vz))
            q.append((x, y + rad * ux + ancho * vx, z + rad * uz + ancho * vz))
        b = len(V)
        V.extend((q[0], q[2], q[3], q[1]))
        F.append((b, b + 1, b + 2, b + 3))
        F.append((b + 3, b + 2, b + 1, b))
    # Cubo macizo (el disco de laton se agrega aparte, en MAT_acento).
    add_caja(V, F, (x, y, z), (2.0 * t + 0.02, 0.20, 0.20))


# ---------- 2) Bastidor + plataforma (MADERA) ----------
V_bas, F_bas = [], []
add_caja(V_bas, F_bas, (0.0, (BED_Y0 + BED_Y1) / 2.0, BED_Z),
         (BED_W, BED_Y1 - BED_Y0, BED_H))
for x in (-0.66, 0.66):
    add_caja(V_bas, F_bas, (x, -0.40, 0.92), (0.16, 2.90, 0.12))
# DEFECTO CORREGIDO EN AUTORIA (revision de las 6 capturas): el primer
# intento ponia un "montante de eje" en Z_RUEDA-0.24, es decir DEBAJO del
# eje y sin tocar la plataforma -> la caja FLOTABA sobre las ruedas. La
# suspension real son 2 postes verticales que van del eje (z~0.618) a las
# vigas longitudinales (z~0.92). E-60: se mide la union, no se asume.
for x in (-0.66, 0.66):
    add_caja(V_bas, F_bas, (x, Y_RUEDA, (Z_RUEDA + 0.95) / 2.0),
             (0.16, 0.22, 0.95 - Z_RUEDA + 0.10))
bastidor = malla('SM_Carreta_Bastidor', V_bas, F_bas, MAT_madera)
bpy.context.view_layer.update()
w_bas = [bastidor.matrix_world @ v.co for v in bastidor.data.vertices]
postes = [p.z for p in w_bas
          if abs(abs(p.x) - 0.66) < 0.12 and abs(p.y - Y_RUEDA) < 0.15]
assert postes and min(postes) < Z_RUEDA + 0.05 and max(postes) > 0.90, \
    'la suspension NO une el eje con las vigas: z=[%.3f..%.3f]' % (
        min(postes) if postes else -1, max(postes) if postes else -1)
# Guard POSITIVO adicional: no basta UN vertice suelto a la altura del eje;
# deben existir los 2 postes completos (8 vertices cada uno).
# MEDIDO, no estimado: add_caja() crea 8 vertices por caja (4 abajo + 4
# arriba). 2 postes => 8 vertices a la altura del eje. El primer intento
# pidio 16 por suponer 8 abajo por caja y salto AssertionError en rojo.
assert sum(1 for z in postes if z < Z_RUEDA + 0.05) >= 8, \
    'solo %d vertices a la altura del eje (esperados >=8)' % sum(
        1 for z in postes if z < Z_RUEDA + 0.05)
print('SUSPENSION: %d vertices, z=[%.3f..%.3f] cubre eje %.3f y viga 0.92'
      % (len(postes), min(postes), max(postes), Z_RUEDA))

# ---------- 3) Tablones: laterales, tableros y vetas (MADERA) ----------
V_tab, F_tab = [], []
for x in (-0.82, 0.82):
    add_caja(V_tab, F_tab, (x, -0.40, 1.32), (0.10, 2.90, 0.40))
add_caja(V_tab, F_tab, (0.0, Y_POPA + 0.05, 1.32), (1.66, 0.10, 0.40))
add_caja(V_tab, F_tab, (0.0, BED_Y1 - 0.05, 1.32), (1.66, 0.10, 0.40))
for x in (-0.82, 0.82):
    for y in (-1.35, -0.40, 0.55):
        add_caja(V_tab, F_tab, (x, y, 1.53), (0.14, 0.10, 0.06))
tablones = malla('SM_Carreta_Tablones', V_tab, F_tab, MAT_madera)
bpy.context.view_layer.update()
z_tab_top = max((tablones.matrix_world @ v.co).z
                for v in tablones.data.vertices)
assert Z_LONA_BASE - 0.01 <= z_tab_top < Z_LONA_BASE + 0.10, \
    'los tablones NO empalman con el toldo: %.3f' % z_tab_top

# ---------- 4) Lona: arco de 5 estaciones, normales explicitas ----------
V_lon, F_lon = [], []
base_lon = len(V_lon)
for (y, mult) in zip(LONA_Y, LONA_M):
    for j in range(N_ARCO + 1):
        th = math.pi * j / N_ARCO
        V_lon.append((R_LONA * mult * math.cos(th), y,
                      Z_LONA_BASE + R_LONA * mult * math.sin(th)))
for i in range(len(LONA_Y) - 1):
    for j in range(N_ARCO):
        a = base_lon + i * (N_ARCO + 1) + j
        b = a + 1
        d = base_lon + (i + 1) * (N_ARCO + 1) + j
        c = d + 1
        F_lon.append((a, d, c, b))
lona = malla('SM_Carreta_Lona', V_lon, F_lon, MAT_lona,
             normal_ref='explicito', z_eje=Z_LONA_BASE)
bpy.context.view_layer.update()
z_lona_top = max((lona.matrix_world @ v.co).z for v in lona.data.vertices)
assert abs(z_lona_top - (Z_LONA_BASE + R_LONA)) < 1e-4, \
    'la lona no corona en 2.40: %.4f' % z_lona_top

# ---------- 5) Aros del toldo (VERDE), por FUERA de la lona ----------
V_aro, F_aro = [], []
RADIOS_ARO = []
for idx_y in (0, 1, 3, 4):
    y = LONA_Y[idx_y]
    mult = LONA_M[idx_y]
    for j in range(N_ARCO):
        th0 = math.pi * j / N_ARCO
        th1 = math.pi * (j + 1) / N_ARCO
        r_out = R_LONA * mult + 0.030
        r_in = R_LONA * mult + 0.006
        b = len(V_aro)
        V_aro.extend([
            (r_out * math.cos(th0), y, Z_LONA_BASE + r_out * math.sin(th0)),
            (r_out * math.cos(th1), y, Z_LONA_BASE + r_out * math.sin(th1)),
            (r_in * math.cos(th1), y, Z_LONA_BASE + r_in * math.sin(th1)),
            (r_in * math.cos(th0), y, Z_LONA_BASE + r_in * math.sin(th0)),
        ])
        F_aro.append((b, b + 1, b + 2, b + 3))
        F_aro.append((b + 3, b + 2, b + 1, b))
        # Cada vertice se compara contra el radio REAL de SU estacion:
        # los extremos del toldo tienen mult=0.94 (mas angostos).
        RADIOS_ARO.extend([R_LONA * mult + 0.004] * 4)
aros = malla('SM_Carreta_Aros', V_aro, F_aro, MAT_acento,
             normal_ref='ninguno')
bpy.context.view_layer.update()
holguras = [math.hypot((aros.matrix_world @ v.co).x,
                       (aros.matrix_world @ v.co).z - Z_LONA_BASE) - r_esp
            for v, r_esp in zip(aros.data.vertices, RADIOS_ARO)]
assert min(holguras) > 0.0, \
    'aros ENTERRADOS en la lona: holgura minima=%.4f' % min(holguras)
print('AROS: holgura minima=%.4f m sobre la lona (4 estaciones, '
      'extremos con mult=0.94)' % min(holguras))

# ---------- 6) Ruedas (HIERRO) con apoyo REAL medido ----------
V_rue, F_rue = [], []
for sgn in (-1, 1):
    add_rueda(V_rue, F_rue, sgn * X_RUEDA, Y_RUEDA, Z_RUEDA,
              R_RUEDA, T_RUEDA)
ruedas = malla('SM_Carreta_Ruedas', V_rue, F_rue, MAT_hierro)
bpy.context.view_layer.update()
z_rueda_min = min((ruedas.matrix_world @ v.co).z
                  for v in ruedas.data.vertices)
assert abs(z_rueda_min - Z_APOYO) < 1e-5, \
    'las ruedas NO apoyan: %.5f != %.5f' % (z_rueda_min, Z_APOYO)

# ---------- 7) Eje (HIERRO) atravesando los cubos ----------
V_eje, F_eje = [], []
add_caja(V_eje, F_eje, (0.0, Y_RUEDA, Z_RUEDA),
         (2.0 * (X_RUEDA + T_RUEDA), 0.09, 0.09))
eje = malla('SM_Carreta_Eje', V_eje, F_eje, MAT_hierro)
bpy.context.view_layer.update()
verts_eje = [eje.matrix_world @ v.co for v in eje.data.vertices]
for sgn in (-1, 1):
    c = Vector((sgn * (X_RUEDA + T_RUEDA), Y_RUEDA, Z_RUEDA))
    d = min((p - c).length for p in verts_eje)
    assert d < 0.07, 'el eje NO atraviesa el cubo de la rueda: d=%.4f' % d

# ---------- 8) Cubos de rueda (VERDE): discos planos, no cilindros ----------
V_cub, F_cub = [], []
for sgn in (-1, 1):
    x = sgn * (X_RUEDA + T_RUEDA + 0.006)
    b = len(V_cub)
    V_cub.extend([(x, Y_RUEDA - 0.13, Z_RUEDA - 0.13),
                  (x, Y_RUEDA + 0.13, Z_RUEDA - 0.13),
                  (x, Y_RUEDA + 0.13, Z_RUEDA + 0.13),
                  (x, Y_RUEDA - 0.13, Z_RUEDA + 0.13)])
    F_cub.append((b, b + 1, b + 2, b + 3))
    assert abs(x) > X_RUEDA + T_RUEDA, 'cubo ENTERRADO en la rueda'
cubos = malla('SM_Carreta_Cubos', V_cub, F_cub, MAT_acento,
              normal_ref='ninguno')
assert len(V_cub) == 8, 'faltan cubos: %d vertices' % len(V_cub)

# ---------- 9) Limones / varas (MADERA) + yunque ----------
V_lim, F_lim = [], []
for sgn in (-1, 1):
    add_viga(V_lim, F_lim,
             (sgn * 0.55, BED_Y1 - 0.08, BED_Z),
             (sgn * 0.42, Y_PROA, 0.88), 0.10, 0.10)
add_caja(V_lim, F_lim, (0.0, 2.05, 0.905), (0.92, 0.10, 0.09))
limones = malla('SM_Carreta_Limones', V_lim, F_lim, MAT_madera)
bpy.context.view_layer.update()
ys_lim = [(limones.matrix_world @ v.co).y for v in limones.data.vertices]
assert abs(max(ys_lim) - Y_PROA) < 1e-5, \
    'los limones no llegan a la proa: %.4f' % max(ys_lim)
assert min(ys_lim) < BED_Y1, \
    'los limones NO se unen a la plataforma: %.4f' % min(ys_lim)

# ---------- 10) Carga (VERDE): 2 cajones + 1 bulto sobre la plataforma -----
V_car, F_car = [], []
for x in (-0.52, 0.52):
    add_caja(V_car, F_car, (x, -1.64, BED_TOP + 0.17), (0.42, 0.42, 0.34))
    add_caja(V_car, F_car, (x, -1.64, BED_TOP + 0.355), (0.46, 0.46, 0.03))
add_caja(V_car, F_car, (0.0, -1.64, BED_TOP + 0.12), (0.50, 0.50, 0.24))
carga = malla('SM_Carreta_Carga', V_car, F_car, MAT_acento)
bpy.context.view_layer.update()
z_carga = [(carga.matrix_world @ v.co).z for v in carga.data.vertices]
assert abs(min(z_carga) - BED_TOP) < 1e-4, \
    'la carga FLOTA o esta ENTERRADA: %.4f vs %.4f' % (min(z_carga), BED_TOP)

# ---------- 11) Farol de papel (LONA) colgado del arco frontal ----------
V_far, F_far = [], []
Z_FAROL_TOP = z_lona_top
add_caja(V_far, F_far, (0.0, LONA_Y[-1], (2.04 + Z_FAROL_TOP) / 2.0),
         (0.06, 0.06, Z_FAROL_TOP - 2.04))
add_caja(V_far, F_far, (0.0, LONA_Y[-1], 1.90), (0.28, 0.28, 0.30))
add_caja(V_far, F_far, (0.0, LONA_Y[-1], 2.07), (0.34, 0.34, 0.05))
farol = malla('SM_Carreta_Farol', V_far, F_far, MAT_lona)
bpy.context.view_layer.update()
zs_far = [(farol.matrix_world @ v.co).z for v in farol.data.vertices]
assert abs(max(zs_far) - z_lona_top) < 1e-4, \
    'el farol NO cuelga del arco: %.4f vs %.4f' % (max(zs_far), z_lona_top)
assert min(zs_far) > BED_TOP + 0.40, 'el farol esta ENTERRADO en la carga'

# ---------- 12) Herrajes (HIERRO): flejes, ganchos, remaches ----------
V_her, F_her = [], []
for x in (-0.78, 0.78):
    for y in (-1.60, 0.80):
        add_caja(V_her, F_her, (x, y, 1.33), (0.13, 0.10, 0.44))
for x in (-0.70, 0.70):
    add_caja(V_her, F_her, (x, BED_Y1 - 0.02, 0.98), (0.14, 0.14, 0.06))
herrajes = malla('SM_Carreta_Herrajes', V_her, F_her, MAT_hierro)
assert len(V_her) == 6 * 8, 'faltan herrajes: %d vertices' % len(V_her)

# ---------- 13) Escena, asentado y medicion POSITIVA de cotas ----------
arena(radio=3.60)
iluminar(escena, energia=3.1)
camara(escena, 'CAM_Carreta', loc=(6.2, -7.8, 4.2), mira=(0.0, 0.2, 1.2))
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
assert abs(min(ys) - Y_POPA) < 0.02, \
    'la popa no llega al limite: %.3f' % min(ys)
assert abs(min(zs) - Z_APOYO) < 1e-4, 'z_min %.4f != Z_APOYO' % min(zs)
assert 2.30 < max(zs) < 2.50, \
    'el toldo no corona la carreta: %.3f' % max(zs)
assert 2.10 < manga < 2.30, 'manga fuera de diseno: %.3f' % manga
assert n_toca >= 8 and min(fp_x, fp_y) > 0.30, 'huella puntual (E-50)'
assert len(piezas) <= 16, 'ALTA excede 16 objetos: %d' % len(piezas)
assert len(MATS) == 4, '4 materiales => 4 grupos y BAJA sin poda: %d' % len(MATS)
assert len(ruedas.data.vertices) == 2 * (4 * 8 + 6 * 4 + 8), \
    'faltan ruedas o rayos: %d vertices' % len(ruedas.data.vertices)
assert len(V_lon) == 5 * (N_ARCO + 1), 'la lona perdio estaciones'
assert len(V_aro) == 4 * N_ARCO * 4, 'faltan aros del toldo'
for _o, _nom in ((bastidor, 'SM_Carreta_Bastidor'),
                 (tablones, 'SM_Carreta_Tablones'),
                 (lona, 'SM_Carreta_Lona'),
                 (aros, 'SM_Carreta_Aros'),
                 (ruedas, 'SM_Carreta_Ruedas'),
                 (eje, 'SM_Carreta_Eje'),
                 (cubos, 'SM_Carreta_Cubos'),
                 (limones, 'SM_Carreta_Limones'),
                 (carga, 'SM_Carreta_Carga'),
                 (farol, 'SM_Carreta_Farol'),
                 (herrajes, 'SM_Carreta_Herrajes')):
    assert _o is not None and len(_o.data.vertices) > 0, \
        '%s existe pero esta VACIA' % _nom

guardar(escena, '157-Medios-De-Transporte', 'carreta_ancestral')
