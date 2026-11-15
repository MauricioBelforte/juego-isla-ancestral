"""Auditoria EXACTA de z_min sobre todos los GLB del juego.

Metodo correcto (leccion del 2026-11-14):
  - accessor POSITION: min/max son bounds EXACTOS de los vertices locales.
  - la matriz del nodo se aplica a los VENSORES, no a las 8 esquinas del AABB
    (las esquinas se van por debajo en objetos rotados = trampa E-24).
  - si hay rotacion, se transforman los vertices con numpy (rapido y exacto).
"""
import json
import os
import struct
import sys

try:
    import numpy as np
except ImportError:
    np = None

ROOT = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d'
Z_APOYO = 0.045
TOL = 0.020

CT = {5120: ('b', 1), 5121: ('B', 1), 5122: ('h', 2), 5123: ('H', 2), 5125: ('I', 4), 5126: ('f', 4)}
NC = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3, 'VEC4': 4}


def load_glb(path):
    data = open(path, 'rb').read()
    magic, ver, length = struct.unpack_from('<III', data, 0)
    if magic != 0x46546C67:
        return None, None
    off, js, binc = 12, None, None
    while off < length:
        clen, ctype = struct.unpack_from('<II', data, off)
        if ctype == 0x4E4F534A:
            js = json.loads(data[off + 8:off + 8 + clen].decode('utf-8'))
        elif ctype == 0x004E4942:
            binc = data[off + 8:off + 8 + clen]
        off += 8 + clen
    return js, binc


def read_positions(js, binc, idx):
    acc = js['accessors'][idx]
    bv = js['bufferViews'][acc['bufferView']]
    fmt, sz = CT[acc['componentType']]
    n = NC[acc['type']]
    start = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
    stride = bv.get('byteStride', n * sz)
    count = acc['count']
    if np is not None:
        if stride == n * sz:
            arr = np.frombuffer(binc, dtype=np.float32, count=count * 3, offset=start)
            return arr.reshape(-1, 3)
        out = np.empty((count, 3), dtype=np.float32)
        for i in range(count):
            out[i] = struct.unpack_from('<3f', binc, start + i * stride)
        return out
    return [struct.unpack_from('<3f', binc, start + i * stride) for i in range(count)]


def mat_mul(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(4)) for j in range(4)] for i in range(4)]


def trs(n):
    if 'matrix' in n:
        m = n['matrix']
        return [[m[0], m[4], m[8], m[12]], [m[1], m[5], m[9], m[13]],
                [m[2], m[6], m[10], m[14]], [m[3], m[7], m[11], m[15]]]
    t = n.get('translation', [0, 0, 0])
    r = n.get('rotation', [0, 0, 0, 1])
    s = n.get('scale', [1, 1, 1])
    x, y, z, w = r
    R = [[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w), 0],
         [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w), 0],
         [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y), 0],
         [0, 0, 0, 1]]
    for i in range(3):
        for j in range(3):
            R[i][j] *= s[j]
    R[0][3], R[1][3], R[2][3] = t
    return R


def apply_m(m, pts):
    if np is not None:
        M = np.array(m, dtype=np.float64)
        v = np.hstack([pts.astype(np.float64), np.ones((len(pts), 1))])
        return (v @ M.T)[:, :3]
    out = []
    for p in pts:
        out.append(tuple(m[i][0] * p[0] + m[i][1] * p[1] + m[i][2] * p[2] + m[i][3] for i in range(3)))
    return out


def zmin_glb(path):
    js, binc = load_glb(path)
    if js is None:
        return None, 0
    nodes = js.get('nodes', [])
    roots = js.get('scenes', [{}])[js.get('scene', 0)].get('nodes', list(range(len(nodes))))
    lo, hi = 1e18, -1e18
    nverts = 0
    seen = set()

    def walk(ni, P):
        nonlocal lo, hi, nverts
        if ni in seen:
            return
        seen.add(ni)
        nd = nodes[ni]
        M = mat_mul(P, trs(nd))
        if 'mesh' in nd:
            for prim in js['meshes'][nd['mesh']].get('primitives', []):
                ai = prim.get('attributes', {}).get('POSITION')
                if ai is None:
                    continue
                pts = read_positions(js, binc, ai)
                if len(pts) == 0:
                    continue
                w = apply_m(M, pts)
                nverts += len(w)
                lo = min(lo, float(min(p[1] for p in w)))
                hi = max(hi, float(max(p[1] for p in w)))
        for c in nd.get('children', []):
            walk(c, M)

    I = [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
    for r in roots:
        walk(r, I)
    if lo > hi:
        return None, 0
    return (lo, hi), nverts


def main():
    files = []
    for d in ('alta', 'media', 'baja'):
        p = os.path.join(ROOT, d)
        if not os.path.isdir(p):
            continue
        for f in sorted(os.listdir(p)):
            if f.lower().endswith('.glb'):
                files.append((d, f, os.path.join(p, f)))

    print('numpy:', 'si' if np is not None else 'NO')
    print('archivos:', len(files))
    fuera, ok, error = [], 0, []
    for d, f, p in files:
        try:
            r, nv = zmin_glb(p)
        except Exception as e:
            error.append((d, f, str(e)[:60]))
            continue
        if r is None:
            error.append((d, f, 'sin malla'))
            continue
        lo, hi = r
        if abs(lo - Z_APOYO) <= TOL:
            ok += 1
        else:
            fuera.append((lo, d, f, hi, nv))

    print('dentro de Z_APOYO %.3f +-%.3f : %d' % (Z_APOYO, TOL, ok))
    print('FUERA : %d' % len(fuera))
    print('errores: %d' % len(error))
    for lo, d, f, hi, nv in sorted(fuera):
        print('  %-5s %-46s zmin=%8.4f  alto=%6.3f  v=%d' % (d, f, lo, hi - lo, nv))
    if error:
        print('\nERRORES:')
        for d, f, e in error[:15]:
            print('  %-5s %-46s %s' % (d, f, e))


if __name__ == '__main__':
    main()