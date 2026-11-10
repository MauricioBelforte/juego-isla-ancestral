#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Guardia POSITIVA de FORMA sobre los 6 GLB de runtime de `pez_tropical`
(M36, L19 / B22): 2 variantes de color (azul / naranja) x 3 LOD.

NO es QA §21.8 ni sello: es una guardia de AUTORIA sobre EL ARTEFACTO QUE
Godot consume. `chk_asset.py` mide COSTE, no FORMA, y B12/B13 probaron que
el verde del `.blend` NO se hereda al GLB. Esta guardia decodifica VERTICES
REALES del BIN y aplica la matriz del nodo.

DEFECTO QUE MOTIVA LA GUARDIA (medido en B18 / acta 28, aplicado en B19,
B20, B21 y B22): el DECIMATE 0.70 de `generar_variante.py` sobre mallas de
cajas disjuntas movia vertices FUERA de los planos autorizados, produciendo
quads inclinados y triangulos INVISIBLES en las capturas. `chk_asset.py`
daba BAJA OK porque mide coste. B22 evita el defecto POR DISENIO: los 6
detalles son objetos sueltos con volumen_bbox < UMBRAL_PODA (1e-4), la
FASE 0 los poda en BAJA y el DECIMATE actua sobre **0 mallas**. LOD real
por poda deliberada, SIN deformacion.

C10/C11/C12 exigen que TODOS los niveles de coordenada (x, z, y) del BIN
pertenezcan al conjunto AUTORIZADO, calibrado en el BIN real con
`Temp/hy4_pez_glb_probe_20261110.py` (JSON + TXT en Temp/). Un vertice
fuera de plano introduce un nivel nuevo y la guardia lo detecta. C9 exige
la ZONA VACIA (0.26, 0.27) entre el lomo (0.255) y la base de la dorsal
(0.275): anti-cunia. C14 exige la silueta POSITIVA (3 escalones del lomo,
aleta caudal, dorsal, hocico). C16/C18 y G5/G6 distinguen las DOS
VARIANTES DE COLOR: no basta con 6 GLB distintos, deben ser la MISMA
geometria con paletas DISTINTAS y el token correcto en cada una.

Trampas evitadas a proposito:
  * No usa las 8 esquinas del AABB del accessor: decodifica POSITION real
    y aplica la matriz del nodo. Matrices glTF COLUMN-MAJOR: M[c*4+r].
  * glTF es Y-up: ALTURA = y; Blender y -> glTF z con signo invertido.
  * Los nombres de malla del GLB son `Cube`, `Cube.001`, ... TODA asercion
    geometrica es sobre VERTICES; la semantica de materiales es explicita.
  * La inyeccion usa la INVERSA GENERAL 3x3 (Cramer), no la diagonal.
  * La deriva `.blend` -> GLB se publica como DATO, nunca como check (B13):
    MEDIDO 216/216/144 en AMBOS lados = deriva 0.
  * Un check que FALLA sigue contando como EJECUTADO.
  * CIEGO = menos bloques/checks que los medidos en verde (exit 3).

Uso:
  python verificar_pez_tropical.py             # VERDE (6 GLB)
  python verificar_pez_tropical.py --piso 0    # mide el piso en verde
  python verificar_pez_tropical.py --inyectar  # ROJO (colapso en copia)
  python verificar_pez_tropical.py --solo <glb>  # CIEGO (exit 3)
  python verificar_pez_tropical.py --volcar    # niveles de coordenada
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
VARIANTES = ('azul', 'naranja')
LODS = ('alta', 'media', 'baja')
TOKENS = {'azul': 'Azul', 'naranja': 'Naranja'}

# MEDIDO EN VERDE con `--piso 0` ANTES de fijar la constante (regla:
# medir antes de escribir la cifra): CHECKS=114 PASADOS=114 FALLOS=0
# BLOQUES=6 RC=0. 18 checks x 6 GLB + 6 globales = 114.
CHECKS_MINIMOS = 114
BLOQUES_MINIMOS = 6

# --- Cotas y niveles CALIBRADOS EN EL BIN REAL (glTF Y-up) ---
Y_APOYO = 0.045
Y_CIMA = 0.335
ZONA_LO, ZONA_HI = 0.26, 0.27   # zona anti-cunia: 0 niveles autorizados
TOL = 0.0005
PERFIL_TRIS = {'alta': 6000, 'media': 1500, 'baja': 700}

NIVELES_X_ALTA = frozenset([
    -0.3, -0.22, -0.15, -0.12, -0.05, -0.03, -0.02, 0.01, 0.03, 0.05,
    0.065, 0.11, 0.13, 0.135, 0.15, 0.18, 0.22, 0.2375, 0.2725, 0.285,
    0.29, 0.305,
])
NIVELES_X_BAJA = frozenset([
    -0.3, -0.22, -0.15, -0.12, -0.02, 0.01, 0.03, 0.065, 0.11, 0.135,
    0.15, 0.18, 0.22, 0.29,
])
NIVELES_Y_ALTA = frozenset([
    0.045, 0.085, 0.095, 0.1125, 0.12, 0.1375, 0.155, 0.18, 0.185,
    0.1875, 0.205, 0.215, 0.2225, 0.235, 0.255, 0.275, 0.335,
])
NIVELES_Y_BAJA = frozenset([
    0.045, 0.085, 0.095, 0.12, 0.155, 0.18, 0.205, 0.215, 0.235,
    0.255, 0.275, 0.335,
])
NIVELES_Z_ALTA = frozenset([
    -0.18, -0.125, -0.1, -0.095, -0.09, -0.085, -0.08, -0.075, -0.07,
    -0.05, -0.04, -0.035, -0.025, -0.015, 0.015, 0.025, 0.035, 0.04,
    0.05, 0.07, 0.075, 0.08, 0.085, 0.09, 0.095, 0.125, 0.18,
])
NIVELES_Z_BAJA = frozenset([
    -0.18, -0.125, -0.09, -0.085, -0.08, -0.075, -0.07, -0.05, -0.04,
    -0.035, -0.015, 0.015, 0.035, 0.04, 0.05, 0.07, 0.075, 0.08,
    0.085, 0.09, 0.125, 0.18,
])

# (tris, materiales, mallas, vertices, x_range) MEDIDOS EN EL BIN.
ESPERADO = {
    'alta':  (216, 7, 10, 432, 0.605),
    'media': (216, 7, 7, 432, 0.605),
    'baja':  (144, 4, 4, 288, 0.590),
}
Z_RANGE = 0.36
DETALLES_LOD = {'alta': 120, 'media': 120, 'baja': 24}
LOMO_NIVELES = (0.155, 0.215, 0.255)

# baseColorFactor de Cuerpo y Aleta, MEDIDOS EN EL BIN (no estimados).
COLOR_REF = {
    'azul': {'Cuerpo': (0.16, 0.52, 0.86), 'Aleta': (0.95, 0.78, 0.22)},
    'naranja': {'Cuerpo': (0.92, 0.42, 0.14), 'Aleta': (0.96, 0.94, 0.88)},
}
TOL_COLOR = 0.01


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
def analizar(path, variante, lod):
    """Devuelve (checks, datos). Publica SIEMPRE 18 checks por GLB."""
    N = 18
    checks, d = [], {'path': path, 'variante': variante, 'lod': lod}

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
        'y_max=%.4f (apice de la dorsal 0.335)' % ymax)

    espurios = sorted(v for v in ly if ZONA_LO < v < ZONA_HI)
    chk('C9', not espurios,
        'zona anti-cunia (%.2f, %.2f): %d niveles espurios %s'
        % (ZONA_LO, ZONA_HI, len(espurios), espurios[:4]))

    ex = NIVELES_X_BAJA if lod == 'baja' else NIVELES_X_ALTA
    ez = NIVELES_Z_BAJA if lod == 'baja' else NIVELES_Z_ALTA
    ey = NIVELES_Y_BAJA if lod == 'baja' else NIVELES_Y_ALTA
    chk('C10', lx.issubset(ex) and len(lx) >= 14,
        'planos X: %d niveles, todos AUTORIZADOS (fuera=%s)'
        % (len(lx), sorted(lx - ex)[:4]))
    chk('C11', lz.issubset(ez) and len(lz) >= 22,
        'planos Z: %d niveles, todos AUTORIZADOS (fuera=%s)'
        % (len(lz), sorted(lz - ez)[:4]))
    chk('C12', ly == ey,
        'planos Y: %d niveles (esperados %d); diff=%s'
        % (len(ly), len(ey), sorted(ly ^ ey)[:6]))

    apoyo = {(round(p[0], 4), round(p[2], 4)) for p in puntos
             if abs(p[1] - Y_APOYO) <= 1e-3}
    chk('C13', len(apoyo) == 12,
        '12 pares (x,z) APOYADOS en y=%.3f (3 franjas x 4 esquinas): %d'
        % (Y_APOYO, len(apoyo)))

    # C14 POSITIVA: silueta de pez, no una caja generica.
    escalones = all(any(abs(w - t) < 1e-4 for w in ly) for t in LOMO_NIVELES)
    cima = sum(1 for p in puntos if abs(p[1] - Y_CIMA) < 1e-4)
    caudal = sum(1 for p in puntos if abs(p[0] + 0.30) < 1e-4)
    hocico = sum(1 for p in puntos if abs(p[0] - 0.29) < 1e-4)
    chk('C14', (escalones and cima >= 4 and caudal >= 8 and hocico >= 4
                and abs(xr - ESPERADO[lod][4]) <= TOL
                and abs(zr - Z_RANGE) <= TOL),
        'silueta: lomo=%s cima=%d/4 caudal=%d/8 hocico=%d/4 xr=%.4f/%.4f '
        'zr=%.4f/%.4f'
        % (escalones, cima, caudal, hocico, xr, ESPERADO[lod][4],
           zr, Z_RANGE))

    e_tris, e_mats, e_mallas, e_verts, _ = ESPERADO[lod]
    mats = len(doc.get('materials', []))
    chk('C15', (total_tris == e_tris and mats == e_mats
                and len(doc['meshes']) == e_mallas
                and len(puntos) == e_verts
                and total_tris <= PERFIL_TRIS[lod]),
        'M166 runtime: %d/%d tris, %d/%d mats, %d/%d mallas, %d/%d verts '
        '<= %d' % (total_tris, e_tris, mats, e_mats,
                   len(doc['meshes']), e_mallas, len(puntos), e_verts,
                   PERFIL_TRIS[lod]))

    docs_mat = doc.get('materials', [])
    nombres = {m.get('name', '') for m in docs_mat}
    tok = TOKENS[variante]
    otro = TOKENS['naranja' if variante == 'azul' else 'azul']
    base = tuple('MAT_Pez_%s_%s' % (tok, p)
                 for p in ('Arena', 'Cuerpo', 'Cabeza', 'Aleta'))
    podables = tuple('MAT_Pez_%s_%s' % (tok, p)
                     for p in ('Ojo', 'Boca', 'Escama'))
    chk('C16', (all(n in nombres for n in base)
                and all((n in nombres) == (lod != 'baja') for n in podables)
                and all(tok in n and otro not in n for n in nombres)),
        '4 base CONSERVADOS en 3 LOD; Ojo/Boca/Escama solo ALTA/MEDIA; '
        'token %s sin mezcla de %s: %s'
        % (tok, otro, '/'.join(str(n in nombres) for n in podables)))

    detalles = sum(1 for p in puntos if 0.155 < p[1] < 0.19)
    chk('C17', detalles == DETALLES_LOD[lod],
        'LOD real por PODA: detalles(0.155<y<0.19)=%d/%d'
        % (detalles, DETALLES_LOD[lod]))

    colores = {}
    for m in docs_mat:
        f = (m.get('pbrMetallicRoughness', {}) or {}).get('baseColorFactor')
        if f:
            colores[m.get('name', '')] = tuple(round(float(c), 4) for c in f[:3])

    def color_ok(pieza):
        c = colores.get('MAT_Pez_%s_%s' % (tok, pieza))
        r = COLOR_REF[variante][pieza]
        return c is not None and len(c) == 3 and all(
            abs(c[i] - r[i]) <= TOL_COLOR for i in range(3))

    chk('C18', color_ok('Cuerpo') and color_ok('Aleta'),
        'variante %s REAL en el BIN: Cuerpo=%s esperado=%s Aleta=%s'
        % (variante, colores.get('MAT_Pez_%s_Cuerpo' % tok),
           COLOR_REF[variante]['Cuerpo'],
           colores.get('MAT_Pez_%s_Aleta' % tok)))

    d.update({'tris': total_tris, 'vertices': len(puntos),
              'materiales': mats, 'mallas': len(doc['meshes']),
              'x_range': xr, 'z_range': zr, 'y_min': ymin, 'y_max': ymax,
              'apoyo': len(apoyo), 'detalles': detalles,
              'niveles_x': sorted(lx), 'niveles_y': sorted(ly),
              'niveles_z': sorted(lz), 'colores': colores,
              'bytes': len(raw), 'sha': sha12(path)})
    return checks, d


# ------------------------------------------------------------- inyeccion ----
def inyectar(src, dst):
    """Reproduce EN UNA COPIA el dano del decimate: vertices fuera de plano.

    Mueve al plano y=0.265 (DENTRO de la zona anti-cunia 0.26..0.27) y
    desplaza z +0.0133 los vertices del nivel y=0.275 (base de la aleta
    dorsal). Introduce niveles NUEVOS en y y z y rompe la relacion de
    subconjunto BAJA/ALTA: exactamente la firma del colapso que esta
    guardia debe detectar. El GLB publicado NO se toca: se escribe en
    Temp/. Usa inversa GENERAL 3x3.
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
                if abs(w[1] - 0.275) < 1e-3:
                    nuevo = (w[0], 0.265, w[2] + 0.0133)
                    struct.pack_into('<fff', bin_, off, *desaplicar(m, nuevo))
                    cambios += 1
    if cambios < 4:
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
        lod = os.path.basename(os.path.dirname(solo)).lower()
        nombre = os.path.basename(solo).lower()
        variante = 'azul' if 'azul' in nombre else 'naranja'
        paths = [(variante, lod, solo)]
    else:
        paths = [(v, lod, os.path.join(
            GODOT, lod, '36-Fauna_pez_tropical_%s.glb' % v))
            for v in VARIANTES for lod in LODS]

    if rojo:
        src = paths[-1][2]
        publicado = sha12(src)
        dst = os.path.join(TEMP, 'hy4_pez_rojo_20261110.glb')
        _, cambios = inyectar(src, dst)
        assert sha12(src) == publicado, 'la inyeccion toco el GLB publicado'
        print('INYECCION: %d vertices mutados en %s | publicado sha=%s '
              'INTACTO' % (cambios, dst, publicado))
        paths[-1] = (paths[-1][0], paths[-1][1], dst)

    todos, datos = [], []
    print('=== FORMA DE RUNTIME: pez_tropical M36 (6 GLB) ===')
    for variante, lod, path in paths:
        checks, d = analizar(path, variante, lod)
        todos.extend(checks)
        datos.append(d)
        print('%-8s %-5s tris=%-4d verts=%-4d mats=%d mallas=%d '
              'xr=%.4f zr=%.2f apoyo=%d detalles=%d sha=%s'
              % (variante, lod, d.get('tris', 0), d.get('vertices', 0),
                 d.get('materiales', 0), d.get('mallas', 0),
                 d.get('x_range', 0), d.get('z_range', 0),
                 d.get('apoyo', 0), d.get('detalles', 0),
                 d.get('sha', '-')))
        if volcar:
            print('   Bloque %s/%s: %d checks' % (variante, lod, len(checks)))
            for eje in ('x', 'y', 'z'):
                print('   niveles_%s=%s' % (eje, d.get('niveles_' + eje, [])))

    por = {(d['variante'], d['lod']): d for d in datos}
    cub = {(v, l) for v in VARIANTES for l in LODS}
    todos.append(('G1', set(por) == cub and len(datos) == 6,
                  'cobertura 2 variantes x 3 LOD = %d bloques' % len(datos)))

    mono = []
    for v in VARIANTES:
        a, m, b = (por.get((v, l)) for l in LODS)
        if a and m and b:
            mono.append(a['tris'] == m['tris'] > b['tris']
                        and a['mallas'] > m['mallas'] > b['mallas']
                        and (a['materiales'], m['materiales'],
                             b['materiales']) == (7, 7, 4)
                        and b['detalles'] < a['detalles'])
    todos.append(('G2', len(mono) == 2 and all(mono),
                  'LOD real por PODA deliberada en 2/2 variantes '
                  '(no por decimate)'))

    sub = []
    for v in VARIANTES:
        a, b = por.get((v, 'alta')), por.get((v, 'baja'))
        if a and b:
            for eje in ('x', 'y', 'z'):
                sub.append(set(b['niveles_' + eje]).issubset(
                    set(a['niveles_' + eje])))
    todos.append(('G3', len(sub) == 6 and all(sub),
                  'niveles(BAJA) SUBCONJUNTO de niveles(ALTA) en x/y/z '
                  '(%d/6)' % sum(sub)))

    shas = [d.get('sha') for d in datos]
    todos.append(('G4', len(shas) == 6 and len(set(shas)) == 6,
                  '6 GLB con sha DISTINTO (no 6 copias del mismo LOD)'))

    dif = []
    for lod in LODS:
        a, n = por.get(('azul', lod)), por.get(('naranja', lod))
        if a and n:
            ca = a['colores'].get('MAT_Pez_Azul_Cuerpo')
            cn = n['colores'].get('MAT_Pez_Naranja_Cuerpo')
            dif.append(bool(ca and cn
                            and max(abs(ca[i] - cn[i]) for i in range(3)) > 0.3))
    todos.append(('G5', len(dif) == 3 and all(dif),
                  '2 VARIANTES DE COLOR reales en 3/3 LOD (Cuerpo difiere '
                  '>0.3 en algun canal)'))

    geom = []
    for lod in LODS:
        a, n = por.get(('azul', lod)), por.get(('naranja', lod))
        if a and n:
            geom.append(all(a[k] == n[k] for k in
                            ('tris', 'vertices', 'apoyo', 'detalles'))
                        and all(a['niveles_' + e] == n['niveles_' + e]
                                for e in ('x', 'y', 'z')))
    todos.append(('G6', len(geom) == 3 and all(geom),
                  'MISMA geometria entre variantes en 3/3 LOD (solo cambia '
                  'la paleta): %d/3' % sum(geom)))

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
    print('VERDE: forma positiva del pez tropical en 6 GLB de runtime')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
