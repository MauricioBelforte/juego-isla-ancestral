#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Guardia POSITIVA de FORMA sobre los 3 GLB de runtime de `dintel_caido` (M25).

NO es QA §21.8 ni sello: es una guardia de AUTORIA sobre el ARTEFACTO QUE
Godot consume, para no creerle a un `chk_asset.py` verde.

Motivo (medido 2026-11-08, B16/L29): `chk_asset.py` mide COSTE, no FORMA.
En B15/L28 dos BAJA pasaron los tres presupuestos M166 con el panel
COLAPSADO en una cunia triangular. Y B12/B13 probaron que el verde del
`.blend` NO se hereda al GLB: aca el exportador aviso
`Mesh SM_Dintel_M_Dintel_Tallado.001 is not valid` y la BAJA pasa de
132 tris (.blend) a 130 tris (GLB) por `mesh.validate()` del glTF.
Por eso esta guardia decodifica VERTICES REALES del BIN, no el `.blend`.

COTAS: la spec de M25 NO define `dintel` (tabla de 24 piezas de
`03-Diseno.md`). Todas las cotas de abajo son la DECISION DE AUTORIA
documentada en `crear_dintel_caido_lowpoly.py` y CALIBRADAS EN EL BIN con
`Temp/hy4_dintel_glb_probe.py`. No se heredan de `bloque_tallado`.

Trampas evitadas a proposito:
  * No usa las 8 esquinas del AABB del accessor (inflan el bbox con nodos
    rotados): decodifica POSITION real y aplica la matriz del nodo.
  * Matrices glTF COLUMN-MAJOR: M[c*4+r], traslacion en M[12..14].
  * glTF es Y-up: ALTURA = y; Blender y=-0.200 -> glTF z=+0.200.
  * Los nombres de malla del GLB son `Cube`, `Cube.001`, ... (el exportador
    usa el datablock, NO el objeto `SM_*`): TODA asercion es GEOMETRICA.
  * La HUELLA DEL CONJUNTO (1.90 x 0.56) es MAYOR que la viga (1.40 x 0.40)
    porque hay fragmento y escombro SEPARADOS. Exigir `fp == 1.40x0.40`
    seria consagrar una mentira: se miden las 4 esquinas DEL CUERPO.
  * El decimate BAJA introduce niveles Y legitimos (0.3423/0.3427/0.3473/
    0.3477) en el RELIEVE. La guardia NO exige "0 vertices intermedios"
    en esa franja: exige 0 vertices en la zona DONDE NO HAY GEOMETRIA
    (0.20 < y < 0.30), que si detecta una cunia estructural.
  * La deriva 132 -> 130 se publica como DATO, nunca como check (B13).
  * Un check que FALLA sigue contando como EJECUTADO.
  * La inyeccion usa la INVERSA GENERAL de la parte lineal 3x3 (Cramer),
    NO la inversa diagonal: asumir diagonal es una trampa ya documentada.

Uso:
  python verificar_dintel_caido.py                  # VERDE (3 GLB)
  python verificar_dintel_caido.py --piso 0        # mide el piso en verde
  python verificar_dintel_caido.py --inyectar      # ROJO (cunia inyectada)
  python verificar_dintel_caido.py --solo <glb>    # CIEGO (exit 3)
  python verificar_dintel_caido.py --volcar        # estadistica de cotas
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
BASE = '25-Ruinas-Templos_dintel_caido.glb'
LODS = ('alta', 'media', 'baja')

# MEDIDO EN VERDE con --piso 0 antes de fijar la constante (ver acta 26).
# 17 checks x 3 GLB + 2 globales = 53.
CHECKS_MINIMOS = 53
BLOQUES_MINIMOS = 3

# --- Cotas CALIBRADAS EN EL BIN (glTF Y-up; ver cabecera) ---
Y_APOYO = 0.045
Y_CARA_SUP = 0.345         # cara superior de la SILUETA portante
Y_RELIEVE_MAX = 0.353      # relieve empotrado sobresale 8 mm
TOL = 0.0005

X0, X_CORTE, X1 = -0.70, 0.40, 0.70
Z_CARA = 0.20              # blender y=-0.20 -> glTF z=+0.20
DIENTES = (0.60, 0.66, 0.70)   # X_CORTE + (0.20, 0.26, 0.30)

FRAG_X, FRAG_Z = (0.75, 0.93), (-0.10, 0.06)
ESC_X, ESC_Z = (-0.97, -0.83), (-0.36, -0.24)
GRI_X = (-0.295, -0.265)   # grieta de 30 mm centrada en x=-0.28

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
    """Inversa GENERAL de la parte lineal 3x3 + traslacion (Cramer).

    B15 asumia matriz diagonal. Aca NO se asume: si el exportador bakea una
    rotacion en el nodo, la inversa diagonal escribiria coordenadas falsas y
    la inyeccion ROJO pareceria no detectar nada (falso verde del guardia).
    """
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


def niveles_x(puntos, altura, tol=1e-3):
    """Valores x distintos presentes a una altura dada."""
    return {round(p[0], 4) for p in puntos if abs(p[1] - altura) <= tol}


def niveles_y_con_masa(puntos, lo, hi, masa=6):
    """Planos de altura con masa real (detecta relieve 3D, no pintura)."""
    from collections import Counter
    hist = Counter(round(p[1], 4) for p in puntos if lo < p[1] <= hi)
    return [n for n, c in sorted(hist.items()) if c >= masa], sorted(hist.items())


def analizar(path, lod):
    """Devuelve (checks, datos). Publica SIEMPRE 17 checks por GLB."""
    N = 17
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
    chk('C8', abs(ymax - Y_RELIEVE_MAX) <= TOL,
        'y_max=%.4f -> relieve empotrado +%.4f m' %
        (ymax, ymax - Y_CARA_SUP))

    n_base, req_base = esquinas(puntos, Y_APOYO, (X0, X_CORTE),
                                (-Z_CARA, Z_CARA))
    chk('C9', n_base == req_base == 4,
        'cuerpo apoyado %d/4 esquinas -> viga %.2f x %.2f m' %
        (n_base, X_CORTE - X0, 2 * Z_CARA))

    xs_sup = niveles_x(puntos, Y_CARA_SUP)
    xs_base = niveles_x(puntos, Y_APOYO)
    presentes = [x for x in DIENTES
                 if any(abs(v - x) < 1e-3 for v in xs_sup | xs_base)]
    chk('C10', len(presentes) == 3,
        'extremo astillado: %d/3 dientes de largo distinto %s' %
        (len(presentes), presentes))

    n_fr, req_fr = esquinas(puntos, Y_APOYO, FRAG_X, FRAG_Z)
    chk('C11', n_fr == req_fr == 4,
        'fragmento desprendido APOYADO %d/4 esquinas' % n_fr)

    n_es, req_es = esquinas(puntos, Y_APOYO, ESC_X, ESC_Z)
    chk('C12', n_es == req_es == 4,
        'escombro APOYADO %d/4 esquinas' % n_es)

    n_sup, req_sup = esquinas(puntos, Y_CARA_SUP, (X0, X_CORTE),
                              (-Z_CARA, Z_CARA))
    chk('C13', n_sup == req_sup == 4,
        'cara superior rectangular %d/4 esquinas (sin cunia)' % n_sup)

    niveles, hist = niveles_y_con_masa(puntos, 0.330, 0.355)
    chk('C14', len(niveles) >= 4,
        'relieve 3D: %d planos de altura con masa %s' %
        (len(niveles), niveles[:6]))

    xs_gri = niveles_x(puntos, Y_RELIEVE_MAX)
    gri = [x for x in GRI_X if any(abs(v - x) < 1e-3 for v in xs_gri)]
    chk('C15', len(gri) == 2,
        'grieta transversal %d/2 bordes en la cara superior' % len(gri))

    zona = sorted({round(p[1], 4) for p in puntos if 0.20 < p[1] < 0.30})
    chk('C16', len(zona) == 0,
        'vertices a media viga=%d %s (cunia/flotante)' % (len(zona), zona[:4]))

    mats = len(doc.get('materials', []))
    limite = PERFIL_TRIS.get(lod)
    chk('C17', mats == 4 and limite is not None
        and 100 <= total_tris <= limite,
        'M166 runtime: %d tris <= %s, materiales=%d' %
        (total_tris, limite, mats))

    d.update({'tris': total_tris, 'vertices': len(puntos), 'materiales': mats,
              'y_min': ymin, 'y_max': ymax, 'bytes': len(raw),
              'sha': sha12(path), 'dientes': len(presentes),
              'niveles': len(niveles), 'zona': len(zona)})
    return checks, d


# ------------------------------------------------------------- inyeccion ----
def inyectar(src, dst):
    """Reproduce EN EL BIN una cunia estructural como la de B15 v1/v2.

    Colapsa las 4 esquinas de la cara superior del cuerpo hacia (0, 0.25, 0)
    y desplaza el diente mas largo (x=0.70) a x=0.55. No toca el GLB
    publicado: escribe una COPIA en Temp/. Usa la inversa GENERAL 3x3.
    """
    raw, doc, bin_, _ = cargar(src)
    jlen = struct.unpack_from('<I', raw, 12)[0]
    _, instancias = recorrer(doc)
    usados = set()
    cambios_cara, cambios_diente = 0, 0
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
                es_esquina_sup = (abs(w[1] - Y_CARA_SUP) < 1e-3
                                  and (abs(w[0] - X0) < 1e-3
                                       or abs(w[0] - X_CORTE) < 1e-3)
                                  and abs(abs(w[2]) - Z_CARA) < 1e-3)
                es_diente = (abs(w[0] - X1) < 1e-3
                             and (abs(w[1] - Y_APOYO) < 1e-3
                                  or abs(w[1] - Y_CARA_SUP) < 1e-3))
                if es_esquina_sup:
                    nuevo = (0.0, 0.25, 0.0)
                    cambios_cara += 1
                elif es_diente:
                    nuevo = (0.55, w[1], w[2])
                    cambios_diente += 1
                if nuevo is None:
                    continue
                struct.pack_into('<fff', bin_, off, *desaplicar(m, nuevo))
    if cambios_cara < 2 or cambios_diente < 1:
        raise RuntimeError('inyeccion no reprodujo la cunia: cara=%d diente=%d'
                           % (cambios_cara, cambios_diente))
    chunk = raw[20:20 + jlen]
    off = 20 + jlen
    blen, btipo = struct.unpack_from('<II', raw, off)
    total = 12 + 8 + len(chunk) + 8 + blen
    salida = (struct.pack('<III', 0x46546C67, 2, total) +
              struct.pack('<II', len(chunk), 0x4E4F534A) + chunk +
              struct.pack('<II', blen, btipo) + bytes(bin_))
    with open(dst, 'wb') as f:
        f.write(salida)
    return dst, cambios_cara + cambios_diente


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
        dst = os.path.join(TEMP, 'hy4_dintel_caido_rojo_20261108.glb')
        _, cambios = inyectar(paths[-1][1], dst)
        print('INYECCION: %d vertices mutados en %s' % (cambios, dst))
        paths[-1] = (paths[-1][0], dst)

    todos, datos = [], []
    print('=== FORMA DE RUNTIME: dintel_caido (GLB, no .blend) ===')
    for lod, path in paths:
        checks, d = analizar(path, lod)
        todos.extend(checks)
        datos.append(d)
        print('%-5s tris=%-4d verts=%-4d mats=%d y=[%.4f,%.4f] '
              'dientes=%d niveles=%d zona=%d sha=%s' %
              (lod, d['tris'], d.get('vertices', 0), d.get('materiales', 0),
               d.get('y_min', float('nan')), d.get('y_max', float('nan')),
               d.get('dientes', 0), d.get('niveles', 0),
               d.get('zona', 0), d.get('sha', '-')))
        if volcar:
            print('   Bloque %s: %d checks ejecutados' % (lod, len(checks)))

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
        print('ROJO: la guardia detecto la cunia en la geometria de runtime')
        return 1
    print('VERDE: forma positiva del dintel caido en 3 GLB de runtime')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
