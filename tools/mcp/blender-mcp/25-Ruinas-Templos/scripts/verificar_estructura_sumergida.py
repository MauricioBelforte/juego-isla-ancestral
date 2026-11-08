#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Guardia POSITIVA de FORMA sobre los 3 GLB de runtime de
`estructura_sumergida` (M25, L31 / B17).

NO es QA §21.8 ni sello: es una guardia de AUTORIA sobre el ARTEFACTO QUE
Godot consume, para no creerle a un `chk_asset.py` verde.

Motivo (medido 2026-11-08, B15/B16/B17): `chk_asset.py` mide COSTE, no
FORMA. Dos BAJA de B15 pasaron los tres presupuestos M166 con el panel
COLAPSADO en una cunia triangular. B12/B13 probaron ademas que el verde del
`.blend` NO se hereda al GLB. Por eso esta guardia decodifica VERTICES
REALES del BIN, no el `.blend` ni el AABB de los accessors.

COTAS: la spec de M25 (`03-Diseno.md`: 40 piezas + 13 ensamblajes) NO define
`estructura sumergida` ni `marea`. Todas las cotas de abajo son la DECISION
DE AUTORIA documentada en `crear_estructura_sumergida_lowpoly.py` y
CALIBRADAS EN EL BIN con `Temp/hy4_sumerg_glb_probe.py`. No se heredan de
`dintel_caido` ni de `bloque_tallado`.

SENAL POSITIVA DE "SUMERGIDA PARCIAL" (4 hechos geometricos, ninguno es un
plano de agua transparente): (1) plataforma + 3 peldanos + fragmento por
DEBAJO de la marea 0.545; (2) banda de algas que ENVUELVE ambas columnas y
CRUZA esa cota (0.515..0.575); (3) dos columnas de altura DISTINTA que
emergen (1.245 vs 2.145) con dintel hundido; (4) algas colgantes desde la
banda hacia la zona sumergida.

Trampas evitadas a proposito:
  * No usa las 8 esquinas del AABB del accessor: decodifica POSITION real y
    aplica la matriz del nodo.
  * Matrices glTF COLUMN-MAJOR: M[c*4+r], traslacion en M[12..14].
  * glTF es Y-up: ALTURA = y; Blender y<0 -> glTF z>0 (signo invertido).
  * Los nombres de malla del GLB son `Cube`, `Cube.001`, ... (el exportador
    usa el datablock, NO el objeto `SM_*`): TODA asercion es GEOMETRICA.
  * La inyeccion usa la INVERSA GENERAL de la parte lineal 3x3 (Cramer),
    NO la inversa diagonal (trampa ya documentada en B15).
  * La deriva `.blend` -> GLB se publica como DATO, nunca como check (B13).
    En este asset es 0 en los 3 LOD (192/192/176 -> 192/192/176).
  * Un check que FALLA sigue contando como EJECUTADO.
  * CIEGO = menos bloques/checks de los medidos en verde (exit 3), no un
    "0 fallos" heredado.

Uso:
  python verificar_estructura_sumergida.py             # VERDE (3 GLB)
  python verificar_estructura_sumergida.py --piso 0    # mide el piso en verde
  python verificar_estructura_sumergida.py --inyectar  # ROJO (colapso)
  python verificar_estructura_sumergida.py --solo <glb># CIEGO (exit 3)
  python verificar_estructura_sumergida.py --volcar    # estadistica de cotas
"""
import hashlib
import json
import math
import os
import struct
import sys
from collections import Counter

REPO = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', '..'))
GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
TEMP = os.path.join(REPO, 'Temp')
BASE = '25-Ruinas-Templos_estructura_sumergida.glb'
LODS = ('alta', 'media', 'baja')

# MEDIDO EN VERDE con --piso 0 antes de fijar la constante (ver acta 27).
# 18 checks x 3 GLB + 2 globales = 56.
CHECKS_MINIMOS = 56
BLOQUES_MINIMOS = 3

# --- Cotas CALIBRADAS EN EL BIN (glTF Y-up; ver cabecera) ---
Y_APOYO = 0.045
Y_CIMA = 2.145
MAREA = 0.545
Y_BANDA_LO, Y_BANDA_HI = 0.515, 0.575
Y_PLAT_TOP = 0.245
Y_PELDANOS = (0.145, 0.245, 0.345)
Y_COL_CORTA = 1.245
Y_COL_ALTA = 2.045
Y_DINTEL_LO, Y_DINTEL_HI = 1.345, 1.565
Y_GLIFOS = (1.385, 1.525)
Z_VACIA_LO, Z_VACIA_HI = 0.60, 1.20

X_PLAT = (-1.00, 1.00)
Z_PLAT = (-0.50, 0.50)
X_COL = (-0.70, 0.70)
DX_BANDA = 0.18
Z_BANDA = (-0.18, 0.18)
X_DINTEL = (-0.85, 0.85)
Z_DINTEL = (-0.15, 0.15)

TOL = 0.0005
PERFIL_TRIS = {'alta': 6000, 'media': 1500, 'baja': 700}


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
def esquinas(puntos, altura, xs, zs, tol=1e-3):
    """Cuenta pares (x, z) PRESENTES en un plano horizontal y=altura."""
    req = {(x, z) for x in xs for z in zs}
    got = set()
    for p in puntos:
        if abs(p[1] - altura) > tol:
            continue
        for x, z in req:
            if abs(p[0] - x) < tol and abs(p[2] - z) < tol:
                got.add((x, z))
    return len(got), len(req)


def masa(puntos, altura, tol=1e-3):
    return sum(1 for p in puntos if abs(p[1] - altura) <= tol)


def analizar(path, lod):
    """Devuelve (checks, datos). Publica SIEMPRE 18 checks por GLB."""
    N = 18
    checks, d = [], {'path': path, 'lod': lod, 'tris': 0}

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

    ymin = min(p[1] for p in puntos)
    ymax = max(p[1] for p in puntos)
    chk('C7', abs(ymin - Y_APOYO) <= TOL,
        'y_min=%.4f (Z_APOYO=%.4f)' % (ymin, Y_APOYO))
    chk('C8', abs(ymax - Y_CIMA) <= TOL,
        'y_max=%.4f (cima columna alta=%.4f)' % (ymax, Y_CIMA))

    n_pl, req_pl = esquinas(puntos, Y_APOYO, X_PLAT, Z_PLAT)
    chk('C9', n_pl == req_pl == 4,
        'plataforma APOYADA %d/4 esquinas -> %.2f x %.2f m' %
        (n_pl, X_PLAT[1] - X_PLAT[0], Z_PLAT[1] - Z_PLAT[0]))

    masas_pel = [masa(puntos, h) for h in Y_PELDANOS]
    chk('C10', all(c >= 8 for c in masas_pel)
        and max(Y_PELDANOS) < MAREA,
        '3 peldanos SUMERGIDOS bajo marea: masas %s' % masas_pel)

    n_banda, req_banda = 0, 0
    for xc in X_COL:
        xs = (xc - DX_BANDA, xc + DX_BANDA)
        for h in (Y_BANDA_LO, Y_BANDA_HI):
            g, r = esquinas(puntos, h, xs, Z_BANDA)
            n_banda += g
            req_banda += r
    chk('C11', n_banda == req_banda == 16,
        'banda de algas ENVUELVE 2 columnas: %d/16 esquinas en '
        'y=%.3f/%.3f' % (n_banda, Y_BANDA_LO, Y_BANDA_HI))

    m_marea = masa(puntos, MAREA)
    chk('C12', m_marea >= 12,
        'linea de marea y=%.3f con %d vertices REALES (no pintura)' %
        (MAREA, m_marea))

    m_abajo, m_arriba = masa(puntos, Y_PLAT_TOP), masa(puntos, Y_COL_CORTA)
    chk('C13', m_abajo >= 24 and m_arriba >= 12,
        'ambas columnas CRUZAN la marea: masa y=%.3f -> %d, '
        'y=%.3f -> %d' % (Y_PLAT_TOP, m_abajo, Y_COL_CORTA, m_arriba))

    m_corta, m_alta = masa(puntos, Y_COL_CORTA), masa(puntos, Y_COL_ALTA)
    chk('C14', m_corta >= 12 and m_alta >= 12
        and Y_COL_ALTA - Y_COL_CORTA >= 0.50,
        'columnas de altura DISTINTA: %.3f (%d verts) vs %.3f (%d verts)'
        % (Y_COL_CORTA, m_corta, Y_COL_ALTA, m_alta))

    n_lo, r_lo = esquinas(puntos, Y_DINTEL_LO, X_DINTEL, Z_DINTEL)
    n_hi, r_hi = esquinas(puntos, Y_DINTEL_HI, X_DINTEL, Z_DINTEL)
    chk('C15', n_lo == r_lo == 4 and n_hi == r_hi == 4,
        'dintel HUNDIDO rectangular %d/4 + %d/4 esquinas (sin cunia)'
        % (n_lo, n_hi))

    masas_gli = [masa(puntos, h) for h in Y_GLIFOS]
    chk('C16', all(c >= 12 for c in masas_gli),
        '2 glifos EMPOTRADOS con relieve 3D: masas %s en %s' %
        (masas_gli, Y_GLIFOS))

    zona = sorted({round(p[1], 4) for p in puntos
                   if Z_VACIA_LO < p[1] < Z_VACIA_HI})
    chk('C17', len(zona) == 0,
        'vertices a media columna=%.2f..%.2f -> %d %s (cunia/flotante)'
        % (Z_VACIA_LO, Z_VACIA_HI, len(zona), zona[:4]))

    mats = len(doc.get('materials', []))
    limite = PERFIL_TRIS.get(lod)
    chk('C18', mats == 4 and limite is not None
        and 100 <= total_tris <= limite,
        'M166 runtime: %d tris <= %s, materiales=%d'
        % (total_tris, limite, mats))

    hist = Counter(round(p[1], 4) for p in puntos)
    d.update({'tris': total_tris, 'vertices': len(puntos),
              'materiales': mats, 'y_min': ymin, 'y_max': ymax,
              'bytes': len(raw), 'sha': sha12(path),
              'banda': n_banda, 'marea': m_marea, 'zona': len(zona),
              'niveles': [(n, c) for n, c in sorted(hist.items()) if c >= 4]})
    return checks, d


# ------------------------------------------------------------- inyeccion ----
def inyectar(src, dst):
    """Reproduce EN EL BIN un colapso estructural como los de B15 v1/v2.

    Colapsa las 4 esquinas de la plataforma apoyada hacia (0, 0.045, 0) y
    las esquinas de la banda de marea hacia (0, 0.80, 0), introduciendo
    geometria EN LA ZONA VACIA. No toca el GLB publicado: escribe una
    COPIA en Temp/. Usa la inversa GENERAL 3x3.
    """
    raw, doc, bin_, _ = cargar(src)
    jlen = struct.unpack_from('<I', raw, 12)[0]
    _, instancias = recorrer(doc)
    usados = set()
    cambios_plat, cambios_banda = 0, 0
    for mi, m in instancias:
        if mi in usados:
            continue
        usados.add(mi)
        for pr in doc['meshes'][mi].get('primitives', []):
            pos_i = pr.get('attributes', {}).get('POSITION')
            if pos_i is None:
                continue
            acc = doc['accessors'][pos_i]
            bv = doc['bufferViews'][acc['bufferView']]
            base = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
            stride = bv.get('byteStride') or 12
            for k in range(acc['count']):
                off = base + k * stride
                local = struct.unpack_from('<fff', bin_, off)
                w = aplicar(m, local)
                nuevo = None
                es_plat = (abs(w[1] - Y_APOYO) < 1e-3
                           and any(abs(w[0] - x) < 1e-3 for x in X_PLAT)
                           and any(abs(w[2] - z) < 1e-3 for z in Z_PLAT))
                es_banda = ((abs(w[1] - Y_BANDA_LO) < 1e-3
                             or abs(w[1] - Y_BANDA_HI) < 1e-3)
                            and any(abs(abs(w[0] - xc) - DX_BANDA) < 1e-3
                                    for xc in X_COL)
                            and any(abs(w[2] - z) < 1e-3 for z in Z_BANDA))
                if es_plat:
                    nuevo = (0.0, Y_APOYO, 0.0)
                    cambios_plat += 1
                elif es_banda:
                    nuevo = (0.0, 0.80, 0.0)
                    cambios_banda += 1
                if nuevo is None:
                    continue
                struct.pack_into('<fff', bin_, off, *desaplicar(m, nuevo))
    if cambios_plat < 4 or cambios_banda < 8:
        raise RuntimeError('inyeccion no reprodujo el colapso: plat=%d banda=%d'
                           % (cambios_plat, cambios_banda))
    chunk = raw[20:20 + jlen]
    off = 20 + jlen
    blen, btipo = struct.unpack_from('<II', raw, off)
    total = 12 + 8 + len(chunk) + 8 + blen
    salida = (struct.pack('<III', 0x46546C67, 2, total) +
              struct.pack('<II', len(chunk), 0x4E4F534A) + chunk +
              struct.pack('<II', blen, btipo) + bytes(bin_))
    with open(dst, 'wb') as f:
        f.write(salida)
    return dst, cambios_plat + cambios_banda


# ------------------------------------------------------------------- main ----
def main(argv):
    piso = CHECKS_MINIMOS
    solo, volcar, rojo = None, False, False
    extras = []
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == '--piso':
            i += 1; piso = int(argv[i])
        elif a == '--solo':
            i += 1; solo = argv[i]
        elif a == '--extra':
            i += 1; extras.append(argv[i])
        elif a == '--inyectar':
            rojo = True
        elif a == '--volcar':
            volcar = True
        i += 1

    if solo:
        paths = [(os.path.basename(os.path.dirname(solo)).lower(), solo)]
    else:
        paths = [(lod, os.path.join(GODOT, lod, BASE)) for lod in LODS]
    for e in extras:
        paths.append((os.path.basename(os.path.dirname(e)).lower(), e))

    if rojo:
        dst = os.path.join(TEMP, 'hy4_sumerg_rojo_20261108.glb')
        _, cambios = inyectar(paths[-1][1], dst)
        print('INYECCION: %d vertices mutados en %s' % (cambios, dst))
        paths[-1] = (paths[-1][0], dst)

    todos, datos = [], []
    print('=== FORMA DE RUNTIME: estructura_sumergida (GLB, no .blend) ===')
    for lod, path in paths:
        checks, d = analizar(path, lod)
        todos.extend(checks)
        datos.append(d)
        print('%-5s tris=%-4d verts=%-4d mats=%d y=[%.4f,%.4f] '
              'banda=%d marea=%d zona=%d sha=%s' %
              (lod, d['tris'], d.get('vertices', 0), d.get('materiales', 0),
               d.get('y_min', float('nan')), d.get('y_max', float('nan')),
               d.get('banda', 0), d.get('marea', 0), d.get('zona', 0),
               d.get('sha', '-')))
        if volcar:
            print('   Bloque %s: %d checks ejecutados' % (lod, len(checks)))
            print('   Niveles Y con masa >=4: %s' % d.get('niveles', []))

    lods_vistos = {d['lod'] for d in datos}
    todos.append(('G1', lods_vistos == set(LODS) and len(datos) >= 3,
                  'cobertura ALTA/MEDIA/BAJA: %s' % sorted(lods_vistos)))
    tris = [d['tris'] for d in datos]
    mono = len(tris) >= 3 and tris[0] >= tris[1] >= tris[2] and tris[2] < tris[0]
    todos.append(('G2', mono,
                  'LOD real (tris no crecientes y BAJA < ALTA): %s' % tris))

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
        print('ROJO: la guardia detecto el colapso en la geometria de runtime')
        return 1
    print('VERDE: forma positiva de la estructura sumergida en 3 GLB de runtime')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
