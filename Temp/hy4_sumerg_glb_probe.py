#!/usr/bin/env python3
# Sonda de calibracion del BIN de los 3 GLB de estructura_sumergida (M25).
# Reutiliza la maquinaria glTF de verificar_dintel_caido.py (no duplica codigo).
# Scratch: NO se versiona. Solo mide, no modifica ningun GLB.
import os
import sys
from collections import Counter

R = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, os.path.join(R, 'tools', 'mcp', 'blender-mcp',
                                '25-Ruinas-Templos', 'scripts'))
import verificar_dintel_caido as v

BASE = os.path.join(R, 'game', 'isla-ancestral', 'assets', '3d')
NAME = '25-Ruinas-Templos_estructura_sumergida.glb'


def puntos(path):
    raw, doc, bin_, ok = v.cargar(path)
    if not ok:
        raise RuntimeError('GLB ilegible: ' + path)
    _, instancias = v.recorrer(doc)
    mats = {}
    for mi, m in instancias:
        mats.setdefault(mi, []).append(m)
    pts, tris = [], 0
    for mi, mesh in enumerate(doc['meshes']):
        for pr in mesh.get('primitives', []):
            pos_i = pr.get('attributes', {}).get('POSITION')
            pos, e = v.leer_vec(doc, bin_, pos_i, 'f', 3)
            if e or not pos:
                continue
            ai = pr.get('indices')
            if ai is None:
                n = len(pos)
            else:
                fmt = {5121: 'B', 5123: 'H', 5125: 'I'}.get(
                    doc['accessors'][ai]['componentType'], 'H')
                vals, _ = v.leer_vec(doc, bin_, ai, fmt, 1)
                n = doc['accessors'][ai]['count']
            tris += n // 3
            for m in mats.get(mi, [v.ident()]):
                for q in pos:
                    pts.append(v.aplicar(m, q))
    return raw, doc, tris, pts


def niveles(pts, lo=None, hi=None, masa=1):
    h = Counter(round(p[1], 4) for p in pts
                if (lo is None or p[1] > lo) and (hi is None or p[1] < hi))
    return [(n, c) for n, c in sorted(h.items()) if c >= masa]


for lod in ('alta', 'media', 'baja'):
    p = os.path.join(BASE, lod, NAME)
    raw, doc, tris, pts = puntos(p)
    print('\n===== %s | %d B | tris=%d | verts=%d | mats=%d ====='
          % (lod, len(raw), tris, len(pts), len(doc.get('materials', []))))
    print('y_min=%.4f y_max=%.4f' % (min(q[1] for q in pts),
                                     max(q[1] for q in pts)))
    print('x_min=%.4f x_max=%.4f z_min(glTF)=%.4f z_max(glTF)=%.4f'
          % (min(q[0] for q in pts), max(q[0] for q in pts),
             min(q[2] for q in pts), max(q[2] for q in pts)))
    print('NIVELES Y (masa>=4):', niveles(pts, masa=4))
    print('NIVELES Y en zona 0.60..1.20:', niveles(pts, 0.60, 1.20, masa=1))
    for h in (0.045, 0.245, 0.515, 0.545, 0.575, 1.345, 1.565, 2.045, 2.145):
        sel = [q for q in pts if abs(q[1] - h) < 5e-4]
        if not sel:
            continue
        xs = sorted({round(q[0], 4) for q in sel})
        zs = sorted({round(q[2], 4) for q in sel})
        print('  y=%.3f n=%-4d xs=%s' % (h, len(sel), xs[:14]))
        print('             zs=%s' % (zs[:14],))
    # esquinas de plataforma en y=0.045
    esq = [(x, z) for x in (-1.00, 1.00) for z in (-0.50, 0.50)]
    got = sum(1 for x, z in esq
              if any(abs(q[0] - x) < 1e-3 and abs(q[1] - 0.045) < 1e-3
                     and abs(q[2] - z) < 1e-3 for q in pts))
    print('PLATAFORMA esquinas apoyadas %d/4 (glTF z=+/-0.50)' % got)
    # banda de marea
    for xcol in (-0.70, 0.70):
        n = sum(1 for q in pts
                if abs(abs(q[0] - xcol) - 0.18) < 1e-3
                and abs(abs(q[1] - 0.545) - 0.03) < 1e-3)
        print('BANDA x=%.2f vertices en planos 0.515/0.575: %d' % (xcol, n))
    bajo = sum(1 for q in pts if q[1] < 0.545 - 1e-4)
    arriba = sum(1 for q in pts if q[1] > 0.545 + 1e-4)
    print('MAREA bajo=%d arriba=%d' % (bajo, arriba))
