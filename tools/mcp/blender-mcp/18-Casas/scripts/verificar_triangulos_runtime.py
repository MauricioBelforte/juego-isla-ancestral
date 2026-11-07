#!/usr/bin/env python3
"""Mide TRIANGULOS REALES DEL GLB (artefacto de runtime), no del .blend.

Motivo (B12, 2026-11-07): chk_asset.py midio 676 tris en el .blend BAJA de la
mansion y el GLB entregado a Godot tenia 530. La causa medida es que el merge +
decimate deja poligonos invalidos: calc_loop_triangles() los triangula de mas,
mesh.validate() los elimina (-146) y el exportador glTF valida antes de escribir.
Los 146 NO son geometria perdida: el GLB es la malla validada, con la misma
superficie. Pero la cifra de presupuesto debe medirse sobre el GLB.

Esta guardia NO compara contra el .blend (eso exige Blender/bpy). Publica la
cifra de runtime, acepta un manifiesto opcional de cifras declaradas y expone la
deriva como DATO, nunca como check: un numero documental viejo no debe hacer
fallar la guardia ni consagrarse como asercion.

Uso:
  python verificar_triangulos_runtime.py                       # VERDE (3 GLB)
  python verificar_triangulos_runtime.py --piso 0             # mide el piso
  python verificar_triangulos_runtime.py --inyectar           # ROJO (exit 1)
  python verificar_triangulos_runtime.py --solo <glb>         # CIEGO (exit 3)
  python verificar_triangulos_runtime.py --declarado <json>   # publica derivas
  python verificar_triangulos_runtime.py --extra <glb> ...    # mas GLB

Convenciones: glTF Y-up (la altura es y), matrices column-major M[c*4+r],
traslacion en M[12..14], vertices REALES del BIN (no las 8 esquinas del AABB).
"""
import hashlib
import json
import math
import os
import struct
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '..'))
GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
TEMP = os.path.join(REPO, 'Temp')

PERFIL_TRIS = {'alta': 6000, 'media': 1500, 'baja': 700}
BASE_MANSION = '18-Casas_casa_mansion.glb'
CHECKS_MINIMOS = 24       # MEDIDO en verde con --piso 0 (3 GLB x 8 checks)
BLOQUES_MINIMOS = 3       # MEDIDO: ALTA / MEDIA / BAJA
Z_APOYO = 0.045
TOL_APOYO = 0.0005


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
    """Devuelve (alcanzables, instancias) donde instancias = (mesh_idx, matriz)."""
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
    """Lee un accessor completo; devuelve (valores, error)."""
    try:
        acc = doc['accessors'][acc_i]
        bv = doc['bufferViews'][acc['bufferView']]
        unidad = struct.calcsize('<' + fmt * ncomp)
        stride = bv.get('byteStride') or unidad
        base = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
        fin = base + (acc['count'] - 1) * stride + unidad
        if base < 0 or fin > len(bin_):
            return [], 'rango'
        out = []
        for k in range(acc['count']):
            out.append(struct.unpack_from('<' + fmt * ncomp, bin_, base + k * stride))
        return out, None
    except (KeyError, IndexError, struct.error, ValueError) as e:
        return [], type(e).__name__


def cargar(path):
    raw = open(path, 'rb').read()
    if len(raw) < 20 or raw[:4] != b'glTF':
        return raw, None, b''
    version, total = struct.unpack_from('<II', raw, 4)
    jlen, jtipo = struct.unpack_from('<II', raw, 12)
    if version != 2 or jtipo != 0x4E4F534A or total != len(raw):
        return raw, None, b''
    doc = json.loads(raw[20:20 + jlen].decode('utf-8'))
    off = 20 + jlen
    blen = struct.unpack_from('<I', raw, off)[0]
    bin_ = raw[off + 8:off + 8 + blen]
    return raw, doc, bin_


def sha12(path):
    return hashlib.sha256(open(path, 'rb').read()).hexdigest()[:12]


def analizar(path, piso, lod_hint=None):
    checks, d = [], {'path': path, 'lod': '?', 'tris': 0, 'primitivas': []}
    raw, doc, bin_ = cargar(path)

    def chk(codigo, ok, detalle):
        checks.append((codigo, bool(ok), detalle))

    chk('C1', doc is not None and len(bin_) > 0,
        'cabecera glTF 2.0 + BIN (%d bytes)' % len(bin_))
    if doc is None:
        return checks, d

    if lod_hint:
        # El GLB inyectado para el ROJO vive en Temp/: su directorio NO es el LOD.
        d['lod'] = lod_hint
    else:
        piezas = os.path.basename(path).lower()
        for lod in ('alta', 'media', 'baja'):
            if os.path.basename(os.path.dirname(path)).lower() == lod or lod in piezas:
                d['lod'] = lod
                break
        if d['lod'] == '?':
            d['lod'] = os.path.basename(os.path.dirname(path)).lower()

    tiene = all(k in doc for k in ('meshes', 'nodes', 'accessors', 'bufferViews'))
    chk('C2', tiene, 'meshes=%d nodes=%d accessors=%d' %
        (len(doc.get('meshes', [])), len(doc.get('nodes', [])),
         len(doc.get('accessors', []))))
    if not tiene:
        return checks, d

    alcanzables, instancias = recorrer(doc)
    mesh_nodes = {i for i, n in enumerate(doc['nodes']) if 'mesh' in n}
    chk('C6', mesh_nodes.issubset(alcanzables),
        'nodos con mesh alcanzables %d/%d' %
        (len(mesh_nodes & alcanzables), len(mesh_nodes)))

    mat_por_mesh = {}
    for mi, m in instancias:
        mat_por_mesh.setdefault(mi, []).append(m)

    total_tris = 0
    modos_ok = True
    idx_ok = True
    verts_ok = True
    puntos = []
    n_prims = 0
    max_indice_error = []
    for mi, mesh in enumerate(doc['meshes']):
        mats = mat_por_mesh.get(mi, [ident()])
        for pr in mesh.get('primitives', []):
            n_prims += 1
            modo = pr.get('mode', 4)
            if modo != 4:
                modos_ok = False
            ai = pr.get('indices')
            pos_i = pr.get('attributes', {}).get('POSITION')
            if pos_i is None:
                verts_ok = False
                continue
            pos, e1 = leer_vec(doc, bin_, pos_i, 'f', 3)
            if e1 or not pos:
                verts_ok = False
                continue
            for p in pos:
                if not all(math.isfinite(float(v)) for v in p):
                    verts_ok = False
                    break
            if ai is None:
                count = len(pos)
                indices = list(range(count))
            else:
                fmt = {5121: 'B', 5123: 'H', 5125: 'I'}.get(
                    doc['accessors'][ai]['componentType'], 'H')
                vals, e2 = leer_vec(doc, bin_, ai, fmt, 1)
                count = doc['accessors'][ai]['count']
                indices = [v[0] for v in vals]
                if e2 or len(indices) != count:
                    idx_ok = False
                    max_indice_error.append('%s=%s' % (mesh.get('name', '?'), e2 or 'corto'))
            if count % 3 != 0:
                idx_ok = False
                max_indice_error.append('%s count=%d no multiplo de 3' %
                                        (mesh.get('name', '?'), count))
            if indices and max(indices) >= len(pos):
                idx_ok = False
                max_indice_error.append('%s indice fuera de rango' %
                                        mesh.get('name', '?'))
            tris = count // 3
            total_tris += tris
            d['primitivas'].append((mesh.get('name', 'mesh%d' % mi), tris))
            for m in mats:
                for ii in indices:
                    if ii < len(pos):
                        puntos.append(aplicar(m, pos[ii]))

    chk('C3', n_prims > 0 and modos_ok,
        '%d primitivas, todas TRIANGLES(4)=%s' % (n_prims, modos_ok))
    chk('C4', idx_ok,
        'indices en rango y count multiple de 3' if idx_ok else
        'FALLO: ' + '; '.join(max_indice_error[:3]))
    chk('C5', verts_ok and len(puntos) > 0,
        '%d vertices REALES decodificados del BIN' % len(puntos))
    d['tris'] = total_tris
    d['vertices'] = len(puntos)
    d['mesh_count'] = len(doc['meshes'])
    d['materiales'] = len(doc.get('materials', []))
    d['bytes'] = len(raw)
    d['sha'] = sha12(path)
    if puntos:
        ys = [p[1] for p in puntos]
        d['y_min'], d['y_max'] = min(ys), max(ys)
    else:
        d['y_min'], d['y_max'] = float('nan'), float('nan')

    chk('C7', abs(d['y_min'] - Z_APOYO) <= TOL_APOYO,
        'y_min=%.4f (apoyo %.4f +- %.4f)' %
        (d['y_min'], Z_APOYO, TOL_APOYO))
    limite = PERFIL_TRIS.get(d['lod'])
    chk('C8', limite is not None and 0 < total_tris <= limite,
        'tris_runtime=%d <= %s' % (total_tris, limite))
    return checks, d


def inyectar(src, dst):
    """Corrompe el primer accessor de indices: count no multiple de 3."""
    raw = open(src, 'rb').read()
    jlen = struct.unpack_from('<I', raw, 12)[0]
    doc = json.loads(raw[20:20 + jlen].decode('utf-8'))
    for mesh in doc['meshes']:
        for pr in mesh.get('primitives', []):
            if 'indices' in pr:
                doc['accessors'][pr['indices']]['count'] += 1
                break
        else:
            continue
        break
    else:
        raise RuntimeError('sin accessor de indices para inyectar')
    chunk = json.dumps(doc, separators=(',', ':')).encode('utf-8')
    chunk += b' ' * ((4 - len(chunk) % 4) % 4)
    off = 20 + jlen
    blen, btipo = struct.unpack_from('<II', raw, off)
    bin_ = raw[off + 8:off + 8 + blen]
    total = 12 + 8 + len(chunk) + 8 + len(bin_)
    salida = (struct.pack('<III', 0x46546C67, 2, total) +
              struct.pack('<II', len(chunk), 0x4E4F534A) + chunk +
              struct.pack('<II', len(bin_), btipo) + bin_)
    open(dst, 'wb').write(salida)
    return dst


def main(argv):
    piso = CHECKS_MINIMOS
    solo = None
    extras = []
    declarado = {}
    inyectar_rojo = False
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == '--piso':
            i += 1; piso = int(argv[i])
        elif a == '--solo':
            i += 1; solo = argv[i]
        elif a == '--extra':
            i += 1; extras.append(argv[i])
        elif a == '--declarado':
            i += 1; declarado = json.load(open(argv[i], encoding='utf-8'))
        elif a == '--inyectar':
            inyectar_rojo = True
        i += 1

    if solo:
        paths = [solo]
    else:
        paths = [os.path.join(GODOT, lod, BASE_MANSION)
                 for lod in ('alta', 'media', 'baja')]
    paths.extend(extras)

    if inyectar_rojo:
        dst = os.path.join(TEMP, 'hy4_runtime_rojo_20261107.glb')
        inyectar(paths[-1], dst)
        paths[-1] = dst
        alias = {dst: os.path.join(GODOT, 'baja', BASE_MANSION)}
    else:
        alias = {}

    todos, datos = [], []
    print('=== TRIANGULOS DE RUNTIME (GLB, no .blend) ===')
    for path in paths:
        hint = (os.path.basename(os.path.dirname(alias[path])).lower()
                if path in alias else None)
        checks, d = analizar(path, piso, hint)
        todos.extend(checks)
        datos.append(d)
        origen = alias.get(d['path'], d['path'])
        lod = os.path.basename(os.path.dirname(origen)).lower()
        decl = declarado.get(lod)
        deriva = (decl - d['tris']) if decl is not None else None
        print('%-5s tris=%-5d verts=%-5d meshes=%-2d mats=%-2d '
              'y=[%.4f,%.4f] sha=%s%s' %
              (lod, d['tris'], d['vertices'], d['mesh_count'], d['materiales'],
               d['y_min'], d['y_max'], d['sha'],
               '' if deriva is None else '  declarado=%d deriva=%+d' % (decl, deriva)))
    print()
    print('=== DETALLE POR PRIMITIVA (ultimo GLB) ===')
    for nombre, tris in datos[-1]['primitivas']:
        print('  %-45s %5d tris' % (nombre, tris))
    print()

    pasados = sum(1 for _, ok, _ in todos if ok)
    fallos = len(todos) - pasados
    bloques = len(datos)
    for codigo, ok, detalle in todos:
        if not ok:
            print('   FAIL %s %s' % (codigo, detalle))
    print('CHECKS=%d PASADOS=%d FALLOS=%d BLOQUES=%d PISO=%d' %
          (len(todos), pasados, fallos, bloques, piso))

    ciego = bloques < BLOQUES_MINIMOS or len(todos) < piso
    if ciego:
        print('CIEGO: faltan bloques o checks ejecutados (%d/%d, %d/%d)' %
              (bloques, BLOQUES_MINIMOS, len(todos), piso))
        return 3
    if fallos:
        print('ROJO')
        return 1
    print('VERDE')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
