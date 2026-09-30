#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Medición de cota Z (z_min/z_max) de .glb vía parseo de glTF — QA de flotación.

Complemento numérico del QA visual orbital (M166 Z_APOYO=0.045, tol ±0.020;
ver tools/mcp/blender-mcp/scripts-reutilizables/auditar_flotantes.py).

Para cada .glb:
  - parsea el chunk JSON de glTF
  - extrae los accessors POSITION de cada mesh
  - aplica las TRS de los nodos (translation/rotation/scale, cadena de parents)
  - z_min/z_max mundiales de TODOS los vértices

Criterios (M166/GUIA-BLENDER §E-12):
  z_min > 0.045 + 0.020  -> FLOTA
  z_min < 0.045 - 0.020  -> HUNDIDO
  resto                  -> OK

Uso:
  python scripts/auditar_flotacion_glb.py            # todos los .glb versionados
  python scripts/auditar_flotacion_glb.py --json    # + tools/legal/flotacion_glb.json
"""
import argparse
import collections
import json
import math
import os
import struct
import subprocess
import sys
from math import cos, sin, sqrt

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
Z_APOYO = 0.045
TOL = 0.020
OUT = os.path.join(ROOT, 'tools', 'legal', 'flotacion_glb.json')


def quat_to_mat(q):
    """Matriz 3x3 (lista de 3 filas) de un cuaternión (w,x,y,z)."""
    w, x, y, z = q
    xx, yy, zz = x * x, y * y, z * z
    xy, xz, yz = x * y, x * z, y * z
    wx, wx2, wy, wz = w * x, w * x, w * y, w * z
    return [
        [1 - 2 * (yy + zz), 2 * (xy - wz), 2 * (xz + wy)],
        [2 * (xy + wz), 1 - 2 * (xx + zz), 2 * (yz - wx)],
        [2 * (xz - wy), 2 * (yz + wx2), 1 - 2 * (xx + yy)],
    ]


def glb_zbounds(path):
    """Devuelve (z_min, z_max, n_verts) o (None, None, 0)."""
    with open(path, 'rb') as f:
        data = f.read()
    if len(data) < 12 or data[:4] != b'glTF':
        return None, None, 0
    total = struct.unpack('<I', data[8:12])[0]
    pos = 12
    js = None
    bin_off = None
    bin_len = 0
    while pos + 8 <= min(total, len(data)):
        clen, ctype = struct.unpack('<II', data[pos:pos + 8])
        if ctype == 0x4E4F534A:
            try:
                js = json.loads(data[pos + 8:pos + 8 + clen].decode('utf-8'))
            except Exception:
                return None, None, 0
        elif ctype == 0x004E4942:  # "BIN\0" (glTF 2.0 spec)
            bin_off = pos + 8
            bin_len = clen
        pos += 8 + clen
    if js is None or bin_off is None:
        return None, None, 0

    acc = js.get('accessors', [])
    views = js.get('bufferViews', [])
    nodes = js.get('nodes', [])
    meshes = js.get('meshes', [])

    # Transformación mundial por nodo: M[i] = M[parent] @ (R * S), T[ padre ]
    def mat_mul(a, b):
        return [[sum(a[a_i][k] * b[k][b_j] for k in range(3)) for b_j in range(3)]
                for a_i in range(3)]

    world = [None] * len(nodes)  # (mat3x3, trans3) por índice de nodo
    def walk(i, pm, pt):
        n = nodes[i]
        s = n.get('scale', [1, 1, 1])
        r = quat_to_mat(n.get('rotation', [0, 0, 0, 1]))
        m = mat_mul(r, [[s[0], 0, 0], [0, s[1], 0], [0, 0, s[2]]])
        t = n.get('translation', [0, 0, 0])
        if pm is not None:
            m = mat_mul(pm, m)
            t = [pm[0][0] * t[0] + pm[0][1] * t[1] + pm[0][2] * t[2] + pt[0],
                 pm[1][0] * t[0] + pm[1][1] * t[1] + pm[1][2] * t[2] + pt[1],
                 pm[2][0] * t[0] + pm[2][1] * t[1] + pm[2][2] * t[2] + pt[2]]
        world[i] = (m, t)
        for ch in n.get('children', []):
            walk(ch, m, t)

    hijos = set()
    for n in nodes:
        for c in n.get('children', []):
            hijos.add(c)
    for i in range(len(nodes)):
        if i not in hijos:
            walk(i, None, None)
    # los nodos no alcanzados se tratan como identidad
    for i in range(len(nodes)):
        if world[i] is None:
            world[i] = ([[1, 0, 0], [0, 1, 0], [0, 0, 1]], [0, 0, 0])
    mesh_owner = {}
    for i, n in enumerate(nodes):
        if 'mesh' in n and n['mesh'] not in mesh_owner:
            mesh_owner[n['mesh']] = i

    zmin, zmax, nv = None, None, 0
    for mi, msh in enumerate(meshes):
        owner = mesh_owner.get(mi, 0)
        m, t = world[owner]
        for prim in msh.get('primitives', []):
            pidx = prim.get('attributes', {}).get('POSITION')
            if pidx is None:
                continue
            try:
                a = acc[pidx]
                bv = views[a['bufferView']]
                off = bin_off + bv.get('byteOffset', 0) + a.get('byteOffset', 0)
                n = a['count']
                flat = struct.unpack_from('<%df' % (3 * n), data, off)
            except (IndexError, KeyError, struct.error):
                continue
            for i in range(0, len(flat), 3):
                x, y, z = flat[i], flat[i + 1], flat[i + 2]
                wz = m[2][0] * x + m[2][1] * y + m[2][2] * z + t[2]
                if zmin is None or wz < zmin:
                    zmin = wz
                if zmax is None or wz > zmax:
                    zmax = wz
                nv += 1
    return zmin, zmax, nv


def main():
    # consola Windows (cp1252): forzar UTF-8 para no perder la corrida
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding='utf-8', errors='replace')
        except Exception:
            pass
    ap = argparse.ArgumentParser()
    ap.add_argument('--json', action='store_true')
    args = ap.parse_args()

    out = subprocess.run(['git', 'ls-files', '*.glb'], capture_output=True,
                         text=True, cwd=ROOT, timeout=60).stdout
    files = [l for l in out.splitlines() if l]
    files.sort()

    recs = []
    for rel in files:
        full = os.path.join(ROOT, rel)
        zmin, zmax, nv = glb_zbounds(full)
        recs.append({'archivo': rel, 'z_min': zmin, 'z_max': zmax, 'verts': nv,
                     'parse_ok': zmin is not None})

    ok = [r for r in recs if r['parse_ok']]
    okk = [r for r in ok if Z_APOYO - TOL <= r['z_min'] <= Z_APOYO + TOL]
    flo = [r for r in ok if r['z_min'] > Z_APOYO + TOL and (r['z_max'] - r['z_min']) < 3.0]
    hun = [r for r in ok if r['z_min'] < Z_APOYO - TOL and (r['z_max'] - r['z_min']) < 3.0
           and r['z_min'] > -0.5]
    cent = [r for r in ok if r['z_min'] < -0.065 and abs(r['z_min']) <= 1.0]
    prof = [r for r in ok if r['z_min'] <= -0.5 and (r['z_max'] - r['z_min']) < 8.0]
    isla = [r for r in ok if (r['z_max'] or 0) - (r['z_min'] or 0) >= 8.0]

    print('Total .glb versionados: %d (parseables %d)' % (len(recs), len(ok)))
    print('Criterio Z_APOYO %.3f ± %.3f (M166) — SOLO aplica a props que tocan arena' % (Z_APOYO, TOL))
    print('ASENTADO (0.045±0.020): %d' % len(okk))
    print('FLOTA  (z_min > %.3f, prop chico): %d' % (Z_APOYO + TOL, len(flo)))
    print('HUNDIDO (z_min < %.3f, prop chico): %d' % (Z_APOYO - TOL, len(hun)))
    print('ORIGEN-CENTRADO (z_min -0.065..-1.0, piezas montadas/raíces embebidas): %d' % len(cent))
    print('HUNDIDO-PROFUNDO (z_min ≤ -0.5, rango <8m — chequeo visual recomendado): %d' % len(prof))
    print('ISLA/TERRENO (rango ≥8m, E-62: fuera de Z_APOYO): %d' % len(isla))
    print()
    print('FLOTANTES (%d):' % len(flo))
    for r in sorted(flo, key=lambda x: -x['z_min']):
        print('  z_min=%8.4f z_max=%8.4f  %s' % (r['z_min'], r['z_max'], r['archivo']))
    print()
    print('HUNDIDOS-CHICOS (%d):' % len(hun))
    for r in sorted(hun, key=lambda x: x['z_min']):
        print('  z_min=%8.4f z_max=%8.4f  %s' % (r['z_min'], r['z_max'], r['archivo']))
    print()
    print('HUNDIDOS-PROFUNDOS (%d) — top 25:' % len(prof))
    for r in sorted(prof, key=lambda x: x['z_min'])[:25]:
        print('  z_min=%8.4f z_max=%8.4f  %s' % (r['z_min'], r['z_max'], r['archivo']))
    print()
    print('ORIGEN-CENTRADOS (%d) — top 15 por |z_min|:' % len(cent))
    for r in sorted(cent, key=lambda x: x['z_min'])[:15]:
        print('  z_min=%8.4f z_max=%8.4f  %s' % (r['z_min'], r['z_max'], r['archivo']))
    # histograma por módulo (cartera de blender-mcp) para contexto
    hist = collections.Counter()
    for r in ok:
        parts = r['archivo'].split('/')
        if len(parts) > 4 and parts[0] == 'tools' and parts[2] == 'blender-mcp':
            key = parts[3]
        elif r['archivo'].startswith('game/isla-ancestral/assets'):
            key = 'assets(3d)'
        elif r['archivo'].startswith('game/Obsoletos'):
            key = 'Obsoletos'
        else:
            key = '?'
        rng = (r['z_max'] or 0) - (r['z_min'] or 0)
        if Z_APOYO - TOL <= r['z_min'] <= Z_APOYO + TOL:
            st = 'ASENTADO'
        elif r['z_min'] > Z_APOYO + TOL and rng < 3.0:
            st = 'FLOTA'
        elif r['z_min'] < Z_APOYO - TOL and rng < 3.0 and r['z_min'] > -0.5:
            st = 'HUNDIDO'
        elif r['z_min'] <= -0.5 and rng < 8.0:
            st = 'HUNDO-PROF'
        elif rng >= 8.0:
            st = 'ISLA'
        else:
            st = 'CENTRADO'
        hist[(key, st)] += 1
    print()
    print('Por módulo x estado:')
    for (k, st), c in sorted(hist.items()):
        print('  %-28s %-8s %d' % (k, st, c))
    if args.json:
        with open(OUT, 'w', encoding='utf-8') as f:
            json.dump({'z_apoyo': Z_APOYO, 'tolerancia': TOL,
                       'conteos': {'total': len(recs), 'parse_ok': len(ok),
                                   'asentado': len(okk), 'flota': len(flo),
                                   'hunde_chico': len(hun),
                                   'origen_centrado': len(cent),
                                   'hunde_profundo': len(prof),
                                   'isla_terrain': len(isla)},
                       'flotantes': flo, 'hundidos_chicos': hun,
                       'origen_centrados': cent, 'hundidos_profundos': prof,
                       'isla_terrain': [r['archivo'] for r in isla]},
                   f, ensure_ascii=False, indent=1)
        print()
        print('JSON:', OUT)


if __name__ == '__main__':
    main()
