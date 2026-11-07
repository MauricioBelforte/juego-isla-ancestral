#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Guardia POSITIVA de FORMA sobre los 3 GLB de runtime de `bloque_tallado` (M25).

NO es QA §21.8 ni sello: es una guardia de AUTORIA sobre el ARTEFACTO ENTREGADO
a Godot, para no creerle a un `chk_asset.py` verde.

Motivo (medido 2026-11-07, L28): las dos primeras BAJA pasaban los tres
presupuestos M166 (6 obj / 136-140 tris / 4 mats, z_min 0.0450, alto 2.000)
con el PANEL COLAPSADO en una cunia triangular y AIRE bajo la cornisa. El
presupuesto mide COSTE, no FORMA. Ademas B12/B13 probaron que el verde del
`.blend` NO se hereda al GLB: aca el `.blend` BAJA declara 144 tris y el GLB
entregado tiene 136 (mesh.validate() del exportador glTF). Por eso esta guardia
decodifica VERTICES REALES del BIN del GLB, no el `.blend`.

Trampas evitadas a proposito:
  * No usa las 8 esquinas del AABB del accessor (inflan el bbox con nodos
    rotados): decodifica POSITION real y aplica la matriz del nodo.
  * Matrices glTF COLUMN-MAJOR: M[c*4+r], traslacion en M[12..14].
  * glTF es Y-up: la ALTURA es y; el FRENTE del muro es z POSITIVO
    (Blender y=-0.200 -> glTF z=+0.200). Medido, no supuesto.
  * Los nombres de malla del GLB son `Cube`, `Cube.001`, ... (el exportador
    usa el nombre del datablock, NO el del objeto `SM_*`). Por eso TODAS las
    aserciones de identidad son GEOMETRICAS (coordenadas), nunca por nombre.
  * Un check que FALLA sigue contando como EJECUTADO: si solo se contaran los
    verdes, el ROJO pareceria CIEGO y la guardia seria un falso verde.
  * Las derivas documentales (`.blend` 144 vs GLB 136) se publican como DATO,
    nunca como check (B13): un numero viejo no debe consagrarse ni hacer fallar
    la guardia.

Uso:
  python verificar_bloque_tallado.py                  # VERDE (3 GLB)
  python verificar_bloque_tallado.py --piso 0        # mide el piso en verde
  python verificar_bloque_tallado.py --inyectar      # ROJO (cunia inyectada)
  python verificar_bloque_tallado.py --solo <glb>    # CIEGO (exit 3)
  python verificar_bloque_tallado.py --volcar        # estadistica de cotas

Caminos MEDIDOS antes de fijar CHECKS_MINIMOS (ver acta 25):
  PISO  --piso 0        -> CHECKS=47 PASADOS=47 FALLOS=0 exit 0
  VERDE                 -> CHECKS=47 PASADOS=47 FALLOS=0 exit 0
  ROJO  --inyectar      -> CHECKS=47 FALLOS>=2 (C10/C11/C14) exit 1
  CIEGO --solo <alta>   -> BLOQUES=1 exit 3
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
BASE = '25-Ruinas-Templos_bloque_tallado.glb'
LODS = ('alta', 'media', 'baja')

# MEDIDO EN VERDE con --piso 0 el 2026-11-07: 15 checks x 3 GLB + 2 globales.
# Primero se midio con el piso en 0 y RECIEN entonces se fijo la cifra real.
CHECKS_MINIMOS = 47
BLOQUES_MINIMOS = 3

# Cotas MEDIDAS en el BIN (spec `03-Diseno.md` L30: muro_recto 1x2 voxel).
Z_APOYO = 0.045
Z_TOP = 2.045                 # altura FISICA 2.000 m desde 0.045
TOL = 0.0005
HUELLA_X, HUELLA_Z = 0.50, 0.20       # 1.00 x 0.40 m
COR_X, COR_Z = 0.54, 0.23             # cornisa 1.08 x 0.46 m
PAN_X, PAN_Y0, PAN_Y1, PAN_Z = 0.36, 0.445, 1.625, 0.216
MED_R, MED_CY, MED_CZ = 0.17, 1.035, 0.235
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


def raices(doc):
    out = []
    for esc in doc.get('scenes', []):
        out.extend(esc.get('nodes', []))
    if not out and doc.get('nodes'):
        out = [0]
    return out


def recorrer(doc):
    """(alcanzables, instancias) con instancias = (mesh_idx, matriz_mundo)."""
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
    """Cuenta esquinas PRESENTES en un plano horizontal y=altura."""
    req = {(x, z) for x in xs for z in zs}
    got = set()
    for p in puntos:
        if abs(p[1] - altura) > tol:
            continue
        for x, z in req:
            if abs(p[0] - x) < tol and abs(p[2] - z) < tol:
                got.add((x, z))
    return len(got), len(req)


def esquinas_panel(puntos, tol=1e-3):
    """4 esquinas del RECTANGULO frontal del panel (detecta la cunia)."""
    req = {(x, y) for x in (-PAN_X, PAN_X) for y in (PAN_Y0, PAN_Y1)}
    got = set()
    for p in puntos:
        if abs(p[2] - PAN_Z) > tol:
            continue
        for x, y in req:
            if abs(p[0] - x) < tol and abs(p[1] - y) < tol:
                got.add((x, y))
    return len(got), len(req)


def anillo_medallon(puntos, tol=1e-3):
    """Vertices distintos sobre el anillo de radio MED_R en el plano frontal."""
    got = set()
    for p in puntos:
        if abs(p[2] - MED_CZ) > tol:
            continue
        r = math.hypot(p[0], p[1] - MED_CY)
        if abs(r - MED_R) < 0.002:
            got.add((round(p[0], 4), round(p[1], 4)))
    return len(got)


def niveles_relieve(puntos):
    """Planos de profundidad con masa real por DELANTE de la cara (z > 0.20)."""
    hist = {}
    for p in puntos:
        if 0.20 < p[2] < 0.24:
            hist[round(p[2], 4)] = hist.get(round(p[2], 4), 0) + 1
    return sum(1 for n in hist.values() if n >= 3), sorted(hist.items())


def analizar(path, lod):
    """Devuelve (checks, datos). Siempre publica 15 checks por GLB."""
    checks, d = [], {'path': path, 'lod': lod, 'tris': 0}

    def chk(codigo, ok, detalle):
        checks.append((codigo, bool(ok), detalle))

    if not os.path.isfile(path):
        for i in range(1, 16):
            chk('C%d' % i, False, 'archivo ausente')
        return checks, d

    raw, doc, bin_, estructura = cargar(path)
    chk('C1', estructura, 'glTF v2 + chunks coherentes (%d bytes)' % len(raw))
    if not estructura or doc is None:
        for i in range(2, 16):
            chk('C%d' % i, False, 'GLB ilegible')
        return checks, d

    tiene = all(k in doc for k in ('meshes', 'nodes', 'accessors', 'bufferViews'))
    chk('C2', tiene, 'meshes=%d nodes=%d accessors=%d' %
        (len(doc.get('meshes', [])), len(doc.get('nodes', [])),
         len(doc.get('accessors', []))))
    if not tiene:
        for i in range(3, 16):
            chk('C%d' % i, False, 'estructura glTF incompleta')
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
                for q in pos:            # TODOS los vertices, no solo indices
                    puntos.append(aplicar(m, q))

    chk('C4', n_prims > 0 and modos_ok,
        '%d primitivas, todas TRIANGLES(4)=%s' % (n_prims, modos_ok))
    chk('C5', idx_ok, 'indices en rango y count multiplo de 3')
    chk('C6', verts_ok and len(puntos) > 0,
        '%d vertices REALES del BIN decodificados' % len(puntos))
    if not puntos:
        for i in range(7, 16):
            chk('C%d' % i, False, 'sin vertices: no se puede medir la forma')
        return checks, d

    ymin = min(p[1] for p in puntos)
    ymax = max(p[1] for p in puntos)
    chk('C7', abs(ymin - Z_APOYO) <= TOL,
        'y_min=%.4f (Z_APOYO=%.4f)' % (ymin, Z_APOYO))
    chk('C8', abs(ymax - Z_TOP) <= TOL,
        'y_max=%.4f -> alto fisico %.4f m (spec 1x2 voxel)' %
        (ymax, ymax - ymin))

    n_base, req_base = esquinas(puntos, Z_APOYO, (-HUELLA_X, HUELLA_X),
                                (-HUELLA_Z, HUELLA_Z))
    chk('C9', n_base == req_base == 4,
        'huella de apoyo %d/4 esquinas -> %.2f x %.2f m' %
        (n_base, 2 * HUELLA_X, 2 * HUELLA_Z))

    n_cor, req_cor = esquinas(puntos, Z_TOP, (-COR_X, COR_X),
                              (-COR_Z, COR_Z))
    chk('C10', n_cor == req_cor == 4,
        'cornisa %d/4 esquinas -> %.2f x %.2f m (vuela 4 cm)' %
        (n_cor, 2 * COR_X, 2 * COR_Z))

    n_pan, req_pan = esquinas_panel(puntos)
    chk('C11', n_pan == req_pan == 4,
        'panel tallado %d/4 esquinas rectangulares en z=%.3f (sin cunia)' %
        (n_pan, PAN_Z))

    n_anillo = anillo_medallon(puntos)
    chk('C12', n_anillo >= 10,
        'medallon circular: %d vertices en anillo r=%.2f' % (n_anillo, MED_R))

    n_niv, hist = niveles_relieve(puntos)
    chk('C13', n_niv >= 5,
        'relieve 3D: %d planos de profundidad con masa %s' %
        (n_niv, [z for z, _ in hist[:6]]))

    huerfanos = [round(p[1], 4) for p in puntos
                 if Z_TOP - 0.20 + 0.01 < p[1] < Z_TOP - 0.01]
    chk('C14', len(huerfanos) == 0,
        'vertices a media cornisa=%d %s (cunia del decimate)' %
        (len(huerfanos), sorted(set(huerfanos))[:4]))

    mats = len(doc.get('materials', []))
    limite = PERFIL_TRIS.get(lod)
    chk('C15', mats == 4 and limite is not None and 100 <= total_tris <= limite,
        'M166 runtime: %d tris <= %s, materiales=%d' %
        (total_tris, limite, mats))

    d.update({'tris': total_tris, 'vertices': len(puntos), 'materiales': mats,
              'y_min': ymin, 'y_max': ymax, 'bytes': len(raw),
              'sha': sha12(path), 'huerfanos': len(huerfanos),
              'niveles': n_niv, 'medallon': n_anillo})
    return checks, d


# ------------------------------------------------------------- inyeccion ----
def inyectar(src, dst):
    """Reproduce EN EL BIN la cunia medida de las BAJA v1/v2.

    Colapsa las 4 esquinas frontales del panel (x -> 0) y baja una esquina de
    la cornisa a y=1.95. No toca el GLB publicado: escribe una copia en Temp/.
    Las matrices de estos nodos son escala diagonal + traslacion (MEDIDO), asi
    que la inversa es (mundo - t) / s.
    """
    raw, doc, bin_, _ = cargar(src)
    jlen = struct.unpack_from('<I', raw, 12)[0]
    _, instancias = recorrer(doc)
    usados = set()
    cambios = 0
    cambios_cornisa = 0
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
                if (abs(abs(w[0]) - PAN_X) < 1e-3
                        and (abs(w[1] - PAN_Y0) < 1e-3 or abs(w[1] - PAN_Y1) < 1e-3)
                        and abs(w[2] - PAN_Z) < 1e-3):
                    nuevo = (0.0, w[1], w[2])
                elif (abs(w[1] - Z_TOP) < 1e-3 and abs(w[0] - COR_X) < 1e-3
                      and abs(w[2] - COR_Z) < 1e-3 and cambios_cornisa < 3):
                    nuevo = (w[0], 1.95, w[2])
                    cambios_cornisa += 1
                if nuevo is None:
                    continue
                # inversa de la matriz (diagonal + traslacion)
                loc = [(nuevo[c] - m[12 + c]) / m[c * 4 + c] for c in range(3)]
                struct.pack_into('<fff', bin_, off, *loc)
                cambios += 1
    if cambios < 2 or cambios_cornisa < 1:
        raise RuntimeError('inyeccion no reprodujo la cunia: %d cambios' % cambios)
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
        dst = os.path.join(TEMP, 'hy4_bloque_tallado_rojo_20261107.glb')
        _, cambios = inyectar(paths[-1][1], dst)
        print('INYECCION: %d vertices mutados en %s' % (cambios, dst))
        paths[-1] = (paths[-1][0], dst)

    todos, datos = [], []
    print('=== FORMA DE RUNTIME: bloque_tallado (GLB, no .blend) ===')
    for lod, path in paths:
        checks, d = analizar(path, lod)
        todos.extend(checks)
        datos.append(d)
        print('%-5s tris=%-4d verts=%-4d mats=%d y=[%.4f,%.4f] '
              'medallon=%d niveles=%d huerfanos=%d sha=%s' %
              (lod, d['tris'], d.get('vertices', 0), d.get('materiales', 0),
               d.get('y_min', float('nan')), d.get('y_max', float('nan')),
               d.get('medallon', 0), d.get('niveles', 0),
               d.get('huerfanos', 0), d.get('sha', '-')))
        # Los FAIL se publican UNA sola vez, en el resumen global de abajo.
        if volcar:
            print('   Bloque %s: %d checks ejecutados' % (lod, len(checks)))

    # 2 checks GLOBALES (cobertura triple + LOD real), medidos con --piso 0.
    lods_vistos = {d['lod'] for d in datos}
    todos.append(('G1', lods_vistos == set(LODS) and len(datos) >= 3,
                  'cobertura ALTA/MEDIA/BAJA: %s' % sorted(lods_vistos)))
    tris = [d['tris'] for d in datos]
    mono = len(tris) >= 3 and tris[0] >= tris[1] >= tris[2] and tris[2] < tris[0]
    todos.append(('G2', mono, 'LOD real (tris no crecientes y BAJA < ALTA): %s' % tris))

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
    print('VERDE: forma positiva del bloque tallado en 3 GLB de runtime')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
