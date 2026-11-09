#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Guardia POSITIVA de FORMA sobre los 3 GLB de runtime de `carrito_vias`
(M35, L40 / B20): ALTA / MEDIA / BAJA.

NO es QA §21.8 ni sello: es una guardia de AUTORIA sobre EL ARTEFACTO QUE
Godot consume. `chk_asset.py` mide COSTE, no FORMA, y B12/B13 probaron que
el verde del `.blend` NO se hereda al GLB. Esta guardia decodifica VERTICES
REALES del BIN y aplica la matriz del nodo.

DEFECTO QUE MOTIVA LA GUARDIA (medido en B18, acta 28; aplicado en B19):
el DECIMATE 0.70 de `generar_variante.py` sobre mallas de cajas disjuntas
movia vertices FUERA de los planos autorizados, produciendo quads inclinados
y triangulos INVISIBLES en las capturas. `chk_asset.py` daba BAJA OK porque
mide coste. B20 evita el defecto POR DISENIO: los 6 detalles son objetos
sueltos con volumen_bbox < UMBRAL_PODA (1e-4), la FASE 0 los poda en BAJA y
el DECIMATE actua sobre **0 mallas**. LOD real por poda deliberada.

Por eso C10/C11/C12 verifican que TODOS los niveles de coordenada (x, z, y)
del BIN pertenecen al conjunto AUTORIZADO, calibrado en el BIN con
`Temp/hy4_carrito_glb_probe_20261109.py`. Un vertice fuera de plano (aunque
no cambie la altura ni el bbox) introduce un nivel nuevo y la guardia lo
detecta. C16 exige el Hierro de los rieles en LOS 3 LOD y el Mineral/Cuerda/
Herraje SOLO en ALTA/MEDIA (el LOD deliberado), lo que evita la trampa de
B18 donde la poda se llevaba puesto un material entero.

Trampas evitadas a proposito:
  * No usa las 8 esquinas del AABB del accessor: decodifica POSITION real y
    aplica la matriz del nodo. Matrices glTF COLUMN-MAJOR: M[c*4+r].
  * glTF es Y-up: ALTURA = y; Blender y -> glTF z con signo invertido.
  * Los nombres de malla del GLB son `Cube`, `Cube.001`, ... TODA asercion
    es GEOMETRICA (salvo C16, que es semantica de materiales).
  * La inyeccion usa la INVERSA GENERAL 3x3 (Cramer), no la diagonal.
  * La deriva `.blend` -> GLB se publica como DATO, nunca como check (B13).
  * Un check que FALLA sigue contando como EJECUTADO.
  * CIEGO = menos bloques/checks que los medidos en verde (exit 3).

Uso:
  python verificar_carrito_vias.py             # VERDE (3 GLB)
  python verificar_carrito_vias.py --piso 0    # mide el piso en verde
  python verificar_carrito_vias.py --inyectar  # ROJO (colapso en copia)
  python verificar_carrito_vias.py --solo <glb># CIEGO (exit 3)
  python verificar_carrito_vias.py --volcar    # niveles de coordenada
"""
import hashlib
import json
import math
import os
import struct
import sys

REPO = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', '..'))
GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
TEMP = os.path.join(REPO, 'Temp')
LODS = ('alta', 'media', 'baja')
BASE = '35-Mineria_carrito_vias.glb'

# MEDIDO EN VERDE con `--piso 0` ANTES de fijar la constante (regla:
# medir antes de escribir la cifra): CHECKS=55 PASADOS=55 FALLOS=0
# BLOQUES=3 RC=0. 17 checks x 3 GLB + 4 globales = 55.
CHECKS_MINIMOS = 55
BLOQUES_MINIMOS = 3

# --- Cotas y niveles CALIBRADOS EN EL BIN (glTF Y-up) ---
Y_APOYO = 0.045
Y_CIMA = 0.625
X_ANCHO = 1.40
Z_FONDO = 0.69
ZONA_LO, ZONA_HI = 0.15, 0.28
TOL = 0.0005
PERFIL_TRIS = {'alta': 6000, 'media': 1500, 'baja': 700}

NIVELES_X_ALTA = frozenset([
    -0.7, -0.62, -0.5, -0.475, -0.425, -0.42, -0.38, -0.37, -0.34,
    -0.22, -0.145, -0.095, -0.06, -0.02, 0.02, 0.06, 0.095, 0.145,
    0.22, 0.34, 0.37, 0.38, 0.42, 0.425, 0.475, 0.5, 0.62, 0.7,
])
NIVELES_X_BAJA = frozenset([
    -0.7, -0.62, -0.5, -0.42, -0.38, -0.37, -0.34, -0.22, -0.06,
    0.06, 0.22, 0.34, 0.37, 0.38, 0.42, 0.5, 0.62, 0.7,
])
NIVELES_Y_ALTA = frozenset([
    0.045, 0.085, 0.135, 0.295, 0.345, 0.3825, 0.4175,
    0.5, 0.52, 0.53, 0.58, 0.625,
])
NIVELES_Y_BAJA = frozenset([
    0.045, 0.085, 0.135, 0.295, 0.345, 0.625,
])
NIVELES_Z_ALTA = frozenset([
    -0.345, -0.33, -0.32, -0.28, -0.27, -0.24, -0.19, -0.025,
    0.025, 0.19, 0.24, 0.27, 0.28, 0.32, 0.33, 0.345,
])
NIVELES_Z_BAJA = frozenset([
    -0.345, -0.33, -0.32, -0.28, -0.27, -0.24, -0.19,
    0.19, 0.24, 0.27, 0.28, 0.32, 0.33, 0.345,
])

# (tris, materiales, mallas, pares de apoyo) MEDIDOS EN EL BIN.
ESPERADO = {
    'alta':  (264, 7, 10, 20),
    'media': (264, 7, 7, 20),
    'baja':  (192, 4, 4, 20),
}
# Vertices con y > 0.48: en ALTA/MEDIA incluyen topes, asas y mineral;
# en BAJA solo quedan los 48 del borde de la batea (LOD deliberado).
DETALLES_LOD = {'alta': 144, 'media': 144, 'baja': 48}


# ---------------------------------------------------------------- glTF -----
def ident():
    return [1., 0., 0., 0.,
            0., 1., 0., 0.,
            0., 0., 1., 0.,
            0., 0., 0., 1.]


def mul(a, b):
    out = [0.] * 16
    for c in range(4):
        for r in range(4):
            out[c * 4 + r] = sum(a[k * 4 + r] * b[c * 4 + k] for k in range(4))
    return out


def trs(n):
    if 'matrix' in n:
        return list(n['matrix'])
    t = n.get('translation', [0., 0., 0.])
    r = n.get('rotation', [0., 0., 0., 1.])
    s = n.get('scale', [1., 1., 1.])
    x, y, z, w = r
    m = [1 - 2 * (y * y + z * z), 2 * (x * y + z * w), 2 * (x * z - y * w), 0.,
         2 * (x * y - z * w), 1 - 2 * (x * x + z * z), 2 * (y * z + x * w), 0.,
         2 * (x * z + y * w), 2 * (y * z - x * w), 1 - 2 * (x * x + y * y), 0.,
         0., 0., 0., 1.]
    for c in range(3):
        for k in range(3):
            m[c * 4 + k] *= s[c]
    m[12], m[13], m[14] = t
    return m


def aplicar(m, p):
    x, y, z = p
    return (m[0] * x + m[4] * y + m[8] * z + m[12],
            m[1] * x + m[5] * y + m[9] * z + m[13],
            m[2] * x + m[6] * y + m[10] * z + m[14])


def desaplicar(m, w):
    """Inversa GENERAL de la parte lineal 3x3 + traslacion (Cramer)."""
    a = ((m[0], m[4], m[8]),
         (m[1], m[5], m[9]),
         (m[2], m[6], m[10]))
    b = (w[0] - m[12], w[1] - m[13], w[2] - m[14])
    det = (a[0][0] * (a[1][1] * a[2][2] - a[1][2] * a[2][1])
           - a[0][1] * (a[1][0] * a[2][2] - a[1][2] * a[2][0])
           + a[0][2] * (a[1][0] * a[2][1] - a[1][1] * a[2][0]))
    if abs(det) < 1e-12:
        raise RuntimeError('matriz singular: no se puede invertir el nodo')
    out = []
    for c in range(3):
        ac = [list(fila) for fila in a]
        for r in range(3):
            ac[r][c] = b[r]
        dc = (ac[0][0] * (ac[1][1] * ac[2][2] - ac[1][2] * ac[2][1])
              - ac[0][1] * (ac[1][0] * ac[2][2] - ac[1][2] * ac[2][0])
              + ac[0][2] * (ac[1][0] * ac[2][1] - ac[1][1] * ac[2][0]))
        out.append(dc / det)
    return tuple(out)


def raices(doc):
    out = []
    for esc in doc.get('scenes', []):
        out.extend(esc.get('nodes', []))
    if not out and doc.get('nodes'):
        out = [0]
    return out


def recorrer(doc):
    nodes = doc.get('nodes', [])
    alcanzables, instancias = set(), []
    pila = [(i, ident()) for i in raices(doc)]
    while pila:
        i, padre = pila.pop()
        if i in alcanzables or i < 0 or i >= len(nodes):
            continue
        alcanzables.add(i)
        n = nodes[i]
        m = mul(padre, trs(n))
        if 'mesh' in n:
            instancias.append((n['mesh'], m))
        for hijo in n.get('children', []):
            pila.append((hijo, m))
    return alcanzables, instancias


def leer_vec(doc, bin_, acc_i, fmt, ncomp):
    try:
        acc = doc['accessors'][acc_i]
        bv = doc['bufferViews'][acc['bufferView']]
        unidad = struct.calcsize('<' + fmt * ncomp)
        stride = bv.get('byteStride') or unidad
        base = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
        fin = base + (acc['count'] - 1) * stride + unidad
        if base < 0 or fin > len(bin_):
            return [], 'rango'
        return [struct.unpack_from('<' + fmt * ncomp, bin_, base + k * stride)
                for k in range(acc['count'])], None
    except (KeyError, IndexError, struct.error, ValueError) as e:
        return [], type(e).__name__


def cargar(path):
    raw = open(path, 'rb').read()
    if len(raw) < 20 or raw[:4] != b'glTF':
        return raw, None, b'', False
    version, total = struct.unpack_from('<II', raw, 4)
    jlen, jtipo = struct.unpack_from('<II', raw, 12)
    estructura = (version == 2 and jtipo == 0x4E4F534A and total == len(raw))
    if not estructura:
        return raw, None, b'', False
    try:
        doc = json.loads(raw[20:20 + jlen].decode('utf-8'))
    except (UnicodeDecodeError, ValueError):
        return raw, None, b'', False
    off = 20 + jlen
    blen, btipo = struct.unpack_from('<II', raw, off)
    estructura = (btipo == 0x004E4942 and len(raw) == off + 8 + blen
                  and blen > 0)
    bin_ = bytearray(raw[off + 8:off + 8 + blen])
    return raw, doc, bin_, estructura


def sha12(path):
    return hashlib.sha256(open(path, 'rb').read()).hexdigest()[:12]


# ------------------------------------------------------------ geometria -----
def analizar(path, lod):
    """Devuelve (checks, datos). Publica SIEMPRE 17 checks por GLB."""
    N = 17
    checks, d = [], {'path': path, 'lod': lod}

    def chk(codigo, ok, detalle):
        checks.append((codigo, bool(ok), detalle))

    def falta(desde, motivo):
        for i in range(desde, N + 1):
            chk('C%d' % i, False, motivo)

    if not os.path.isfile(path):
        falta(1, 'archivo ausente')
        return checks, d

    raw, doc, bin_, estructura = cargar(path)
    chk('C1', estructura, 'glTF v2 + chunks coherentes (%d bytes)' % len(raw))
    if not estructura or doc is None:
        falta(2, 'GLB ilegible')
        return checks, d

    tiene = all(k in doc for k in ('meshes', 'nodes', 'accessors', 'bufferViews'))
    chk('C2', tiene, 'meshes=%d nodes=%d accessors=%d' %
        (len(doc.get('meshes', [])), len(doc.get('nodes', [])),
         len(doc.get('accessors', []))))
    if not tiene:
        falta(3, 'estructura glTF incompleta')
        return checks, d

    alcanzables, instancias = recorrer(doc)
    mesh_nodes = {i for i, n in enumerate(doc['nodes']) if 'mesh' in n}
    chk('C3', mesh_nodes.issubset(alcanzables),
        'nodos con mesh alcanzables %d/%d' %
        (len(mesh_nodes & alcanzables), len(mesh_nodes)))

    mat_por_mesh = {}
    for mi, m in instancias:
        mat_por_mesh.setdefault(mi, []).append(m)

    puntos, total_tris, n_prims = [], 0, 0
    modos_ok, idx_ok, verts_ok = True, True, True
    for mi, mesh in enumerate(doc['meshes']):
        mats = mat_por_mesh.get(mi, [ident()])
        for pr in mesh.get('primitives', []):
            n_prims += 1
            if pr.get('mode', 4) != 4:
                modos_ok = False
            pos_i = pr.get('attributes', {}).get('POSITION')
            if pos_i is None:
                verts_ok = False
                continue
            pos, e1 = leer_vec(doc, bin_, pos_i, 'f', 3)
            if e1 or not pos:
                verts_ok = False
                continue
            if not all(math.isfinite(float(v)) for p in pos for v in p):
                verts_ok = False
            ai = pr.get('indices')
            if ai is None:
                count, indices = len(pos), list(range(len(pos)))
            else:
                fmt = {5121: 'B', 5123: 'H', 5125: 'I'}.get(
                    doc['accessors'][ai]['componentType'], 'H')
                vals, e2 = leer_vec(doc, bin_, ai, fmt, 1)
                count = doc['accessors'][ai]['count']
                indices = [v[0] for v in vals]
                if e2 or len(indices) != count:
                    idx_ok = False
            if count % 3 != 0:
                idx_ok = False
            if indices and max(indices) >= len(pos):
                idx_ok = False
            total_tris += count // 3
            for m in mats:
                for q in pos:
                    puntos.append(aplicar(m, q))

    chk('C4', n_prims > 0 and modos_ok,
        '%d primitivas, todas TRIANGLES(4)=%s' % (n_prims, modos_ok))
    chk('C5', idx_ok, 'indices en rango y count multiplo de 3')
    chk('C6', verts_ok and len(puntos) > 0,
        '%d vertices REALES del BIN decodificados' % len(puntos))
    if not puntos:
        falta(7, 'sin vertices: no se puede medir la forma')
        return checks, d

    xs = [p[0] for p in puntos]
    ys = [p[1] for p in puntos]
    zs = [p[2] for p in puntos]
    lx = {round(v, 4) for v in xs}
    ly = {round(v, 4) for v in ys}
    lz = {round(v, 4) for v in zs}
    xr, zr = max(xs) - min(xs), max(zs) - min(zs)
    ymin, ymax = min(ys), max(ys)

    chk('C7', abs(ymin - Y_APOYO) <= TOL,
        'y_min=%.4f (Z_APOYO=%.4f)' % (ymin, Y_APOYO))
    chk('C8', abs(ymax - Y_CIMA) <= TOL,
        'y_max=%.4f (borde de la batea 0.625)' % ymax)

    espurios = sorted(v for v in ly if ZONA_LO < v < ZONA_HI)
    chk('C9', not espurios,
        'zona anti-cunia (%.2f, %.2f): %d niveles espurios %s'
        % (ZONA_LO, ZONA_HI, len(espurios), espurios[:4]))

    ex = NIVELES_X_BAJA if lod == 'baja' else NIVELES_X_ALTA
    ez = NIVELES_Z_BAJA if lod == 'baja' else NIVELES_Z_ALTA
    ey = NIVELES_Y_BAJA if lod == 'baja' else NIVELES_Y_ALTA
    chk('C10', lx.issubset(ex) and len(lx) >= 18,
        'planos X: %d niveles, todos AUTORIZADOS (fuera=%s)'
        % (len(lx), sorted(lx - ex)[:4]))
    chk('C11', lz.issubset(ez) and len(lz) >= 14,
        'planos Z: %d niveles, todos AUTORIZADOS (fuera=%s)'
        % (len(lz), sorted(lz - ez)[:4]))
    chk('C12', ly == ey,
        'planos Y: %d niveles (esperados %d); diff=%s'
        % (len(ly), len(ey), sorted(ly ^ ey)[:6]))

    apoyo = {(round(p[0], 4), round(p[2], 4)) for p in puntos
             if abs(p[1] - Y_APOYO) <= 1e-3}
    chk('C13', len(apoyo) == 20,
        '20 pares (x,z) APOYADOS en y=%.3f (5 traviesas x 4 esquinas): %d'
        % (Y_APOYO, len(apoyo)))

    riel_ext = sum(1 for p in puntos
                   if abs(p[0]) > 0.69 and 0.08 < p[1] < 0.14)
    ruedas = sum(1 for p in puntos
                 if 0.13 < p[1] < 0.30 and 0.20 < abs(p[0]) < 0.40)
    borde = sum(1 for p in puntos if p[1] > 0.60)
    chk('C14', (riel_ext >= 48 and ruedas >= 96 and borde >= 48
                and abs(xr - X_ANCHO) <= TOL and abs(zr - Z_FONDO) <= TOL),
        'silueta carrito: riel_ext=%d ruedas=%d borde=%d '
        'xr=%.2f/%.2f zr=%.2f/%.2f'
        % (riel_ext, ruedas, borde, xr, X_ANCHO, zr, Z_FONDO))

    e_tris, e_mats, e_mallas, _ = ESPERADO[lod]
    mats = len(doc.get('materials', []))
    chk('C15', (total_tris == e_tris and mats == e_mats
                and len(doc['meshes']) == e_mallas
                and total_tris <= PERFIL_TRIS[lod]),
        'M166 runtime: %d/%d tris, %d/%d mats, %d/%d mallas <= %d'
        % (total_tris, e_tris, mats, e_mats, len(doc['meshes']), e_mallas,
           PERFIL_TRIS[lod]))

    nombres = {m.get('name', '') for m in doc.get('materials', [])}
    chk('C16', ('MAT_Carrito_Hierro' in nombres
                and all((n in nombres) == (lod != 'baja') for n in
                        ('MAT_Carrito_Mineral', 'MAT_Carrito_Cuerda',
                         'MAT_Carrito_Herraje'))),
        'rieles (Hierro) CONSERVADOS en los 3 LOD; Mineral/Cuerda/Herraje '
        'solo ALTA/MEDIA: %s/%s/%s'
        % tuple(n in nombres for n in ('MAT_Carrito_Mineral',
                                       'MAT_Carrito_Cuerda',
                                       'MAT_Carrito_Herraje')))

    detalles = sum(1 for p in puntos if p[1] > 0.48)
    chk('C17', detalles == DETALLES_LOD[lod],
        'LOD de detalle y>0.48: %d/%d (BAJA poda 6 detalles a proposito)'
        % (detalles, DETALLES_LOD[lod]))

    d.update({'tris': total_tris, 'vertices': len(puntos),
              'materiales': mats, 'mallas': len(doc['meshes']),
              'x_range': xr, 'z_range': zr, 'y_min': ymin, 'y_max': ymax,
              'apoyo': len(apoyo), 'riel_ext': riel_ext, 'ruedas': ruedas,
              'borde': borde, 'detalles': detalles,
              'niveles_x': sorted(lx), 'niveles_y': sorted(ly),
              'niveles_z': sorted(lz), 'bytes': len(raw), 'sha': sha12(path)})
    return checks, d


# ------------------------------------------------------------- inyeccion ----
def inyectar(src, dst):
    """Reproduce EN UNA COPIA el dano del decimate: vertices fuera de plano.

    Mueve al plano y=0.20 (zona anti-cunia) y desplaza z +0.0133 los
    vertices del nivel y=0.345 (piso de la batea / arranque de las paredes).
    Eso introduce niveles NUEVOS en y y z, exactamente la firma del colapso
    que esta guardia debe detectar. El GLB publicado NO se toca: se escribe
    en Temp/. Usa inversa GENERAL 3x3.
    """
    raw, doc, bin_, ok = cargar(src)
    if not ok:
        raise RuntimeError('no se puede inyectar: GLB ilegible')
    jlen = struct.unpack_from('<I', raw, 12)[0]
    _, instancias = recorrer(doc)
    vistos, cambios = set(), 0
    for mi, m in instancias:
        for pr in doc['meshes'][mi].get('primitives', []):
            pos_i = pr.get('attributes', {}).get('POSITION')
            if pos_i is None or pos_i in vistos:
                continue
            vistos.add(pos_i)
            acc = doc['accessors'][pos_i]
            bv = doc['bufferViews'][acc['bufferView']]
            base = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
            stride = bv.get('byteStride') or 12
            for k in range(acc['count']):
                off = base + k * stride
                w = aplicar(m, struct.unpack_from('<fff', bin_, off))
                if abs(w[1] - 0.345) < 1e-3:
                    nuevo = (w[0], 0.20, w[2] + 0.0133)
                    struct.pack_into('<fff', bin_, off, *desaplicar(m, nuevo))
                    cambios += 1
    if cambios < 8:
        raise RuntimeError('inyeccion no reprodujo el colapso: %d vertices'
                           % cambios)
    chunk = raw[20:20 + jlen]
    off = 20 + jlen
    blen, btipo = struct.unpack_from('<II', raw, off)
    total = 12 + 8 + len(chunk) + 8 + blen
    salida = (struct.pack('<III', 0x46546C67, 2, total) +
              struct.pack('<II', len(chunk), 0x4E4F534A) + chunk +
              struct.pack('<II', blen, btipo) + bytes(bin_))
    with open(dst, 'wb') as f:
        f.write(salida)
    return dst, cambios


# ------------------------------------------------------------------- main ----
def main(argv):
    piso = CHECKS_MINIMOS
    solo, volcar, rojo = None, False, False
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == '--piso':
            i += 1
            piso = int(argv[i])
        elif a == '--solo':
            i += 1
            solo = argv[i]
        elif a == '--inyectar':
            rojo = True
        elif a == '--volcar':
            volcar = True
        i += 1

    if solo:
        padre = os.path.basename(os.path.dirname(solo)).lower()
        paths = [(padre, solo)]
    else:
        paths = [(lod, os.path.join(GODOT, lod, BASE)) for lod in LODS]

    if rojo:
        dst = os.path.join(TEMP, 'hy4_carrito_rojo_20261109.glb')
        _, cambios = inyectar(paths[-1][1], dst)
        print('INYECCION: %d vertices mutados en %s' % (cambios, dst))
        paths[-1] = (paths[-1][0], dst)

    todos, datos = [], []
    print('=== FORMA DE RUNTIME: carrito_vias M35 (GLB) ===')
    for lod, path in paths:
        checks, d = analizar(path, lod)
        todos.extend(checks)
        datos.append(d)
        print('%-5s tris=%-4d verts=%-4d mats=%d mallas=%d '
              'xr=%.2f zr=%.2f apoyo=%d riel=%d ruedas=%d detalles=%d sha=%s'
              % (lod, d.get('tris', 0), d.get('vertices', 0),
                 d.get('materiales', 0), d.get('mallas', 0),
                 d.get('x_range', 0), d.get('z_range', 0),
                 d.get('apoyo', 0), d.get('riel_ext', 0),
                 d.get('ruedas', 0), d.get('detalles', 0),
                 d.get('sha', '-')))
        if volcar:
            print('   Bloque %s: %d checks' % (lod, len(checks)))
            for eje in ('x', 'y', 'z'):
                print('   niveles_%s=%s' % (eje, d.get('niveles_' + eje, [])))

    lods_vistos = {d['lod'] for d in datos}
    todos.append(('G1', lods_vistos == set(LODS) and len(datos) == 3,
                  'cobertura 3 LOD = %d bloques' % len(datos)))

    por = {d['lod']: d for d in datos}
    mono = (len(por) == 3
            and por['alta']['tris'] == por['media']['tris'] > por['baja']['tris']
            and por['alta']['mallas'] > por['media']['mallas'] > por['baja']['mallas']
            and (por['alta']['materiales'], por['media']['materiales'],
                 por['baja']['materiales']) == (7, 7, 4)
            and por['baja']['detalles'] < por['alta']['detalles'])
    todos.append(('G2', mono,
                  'LOD real por PODA deliberada (no por decimate)'))

    sub = []
    if len(por) == 3:
        for eje in ('x', 'y', 'z'):
            sub.append(set(por['baja']['niveles_' + eje]).issubset(
                set(por['alta']['niveles_' + eje])))
    todos.append(('G3', len(sub) == 3 and all(sub),
                  'niveles(BAJA) SUBCONJUNTO de niveles(ALTA) en x/y/z '
                  '(%d/3)' % sum(sub)))

    shas = [d.get('sha') for d in datos]
    todos.append(('G4', len(shas) == 3 and len(set(shas)) == 3,
                  '3 GLB con sha DISTINTO (no 3 copias del mismo LOD)'))

    pasados = sum(1 for _, ok, _ in todos if ok)
    fallos = len(todos) - pasados
    bloques = len(datos)
    for codigo, ok, detalle in todos:
        if not ok:
            print('   FAIL %-4s %s' % (codigo, detalle))
    print('CHECKS=%d PASADOS=%d FALLOS=%d BLOQUES=%d PISO=%d' %
          (len(todos), pasados, fallos, bloques, piso))

    if bloques < BLOQUES_MINIMOS or len(todos) < piso:
        print('CIEGO: faltan bloques o checks ejecutados (no se hereda ningun verde)')
        return 3
    if fallos:
        print('ROJO: la guardia detecto geometria fuera de plano en runtime')
        return 1
    print('VERDE: forma positiva del carrito de vias en 3 GLB de runtime')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
