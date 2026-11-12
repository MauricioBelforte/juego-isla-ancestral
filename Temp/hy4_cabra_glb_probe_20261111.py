#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Sonda de CALIBRACION B24: decodifica el BIN real de los 3 GLB de `cabra`.
NO es un test: es medicion previa. Reutiliza el decoder AUTOCONTENIDO de
`verificar_cangrejo_ermitano.py` (B21); la guardia B24 sera independiente.
"""
import json
import os
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
SCRIPTS = os.path.join(REPO, 'tools', 'mcp', 'blender-mcp', '36-Fauna', 'scripts')
sys.path.insert(0, SCRIPTS)
from verificar_cangrejo_ermitano import (  # noqa: E402
    cargar, recorrer, leer_vec, aplicar, ident,
)

GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
BASE = '36-Fauna_cabra.glb'
LODS = ('alta', 'media', 'baja')


def medir(path):
    raw, doc, bin_, ok = cargar(path)
    assert ok, 'GLB ilegible: %s' % path
    _, instancias = recorrer(doc)
    mat_por_mesh = {}
    for mi, m in instancias:
        mat_por_mesh.setdefault(mi, []).append(m)

    puntos, tris = [], 0
    for mi, mesh in enumerate(doc['meshes']):
        mats = mat_por_mesh.get(mi, [ident()])
        for pr in mesh.get('primitives', []):
            pos_i = pr.get('attributes', {}).get('POSITION')
            pos, e = leer_vec(doc, bin_, pos_i, 'f', 3)
            assert not e and pos, 'POSITION ilegible: %s' % e
            ai = pr.get('indices')
            if ai is None:
                count = len(pos)
            else:
                fmt = {5121: 'B', 5123: 'H', 5125: 'I'}.get(
                    doc['accessors'][ai]['componentType'], 'H')
                vals, e = leer_vec(doc, bin_, ai, fmt, 1)
                assert not e
                count = doc['accessors'][ai]['count']
            tris += count // 3
            for m in mats:
                for q in pos:
                    puntos.append(aplicar(m, q))

    xs = [p[0] for p in puntos]
    ys = [p[1] for p in puntos]
    zs = [p[2] for p in puntos]
    lx = sorted({round(v, 4) for v in xs})
    ly = sorted({round(v, 4) for v in ys})
    lz = sorted({round(v, 4) for v in zs})
    apoyo = {(round(p[0], 4), round(p[2], 4)) for p in puntos
             if abs(p[1] - 0.045) <= 1e-3}
    nombres = sorted(m.get('name', '') for m in doc.get('materials', []))

    return {
        'bytes': len(raw), 'tris': tris,
        'mats': len(doc.get('materials', [])), 'mallas': len(doc['meshes']),
        'verts': len(puntos),
        'x': [round(min(xs), 4), round(max(xs), 4)],
        'y': [round(min(ys), 4), round(max(ys), 4)],
        'z': [round(min(zs), 4), round(max(zs), 4)],
        'xr': round(max(xs) - min(xs), 4),
        'zr': round(max(zs) - min(zs), 4),
        'apoyo': len(apoyo),
        'escalones': {t: sum(1 for p in puntos if abs(p[1] - t) < 1e-4)
                      for t in (0.155, 0.225, 0.245, 0.265, 0.335)},
        'hocico_x035': sum(1 for p in puntos if abs(p[0] - 0.35) < 1e-4),
        'barba_x0365': sum(1 for p in puntos if abs(p[0] - 0.365) < 1e-4),
        'trasero_x-019': sum(1 for p in puntos if abs(p[0] + 0.19) < 1e-4),
        'cima': sum(1 for p in puntos if abs(p[1] - 0.335) < 1e-4),
        'ojos_y2225': sum(1 for p in puntos if abs(p[1] - 0.2225) < 1e-4),
        'manchas_y215': sum(1 for p in puntos if abs(p[1] - 0.215) < 1e-4),
        'zona_vacia_27_28': sorted(v for v in ly if 0.27 < v < 0.28),
        'niveles_x': lx, 'niveles_y': ly, 'niveles_z': lz,
        'materiales': nombres,
    }


def main():
    out = {}
    for lod in LODS:
        path = os.path.join(GODOT, lod, BASE)
        d = medir(path)
        out[lod] = d
        print('%-5s tris=%-4d mats=%d mallas=%d verts=%-4d '
              'x=[%.4f..%.4f] y=[%.4f..%.4f] z=[%.4f..%.4f] '
              'xr=%.4f zr=%.2f apoyo=%d'
              % (lod, d['tris'], d['mats'], d['mallas'], d['verts'],
                 d['x'][0], d['x'][1], d['y'][0], d['y'][1],
                 d['z'][0], d['z'][1], d['xr'], d['zr'], d['apoyo']))
        print('   escalones=%s hocico=%d barba=%d trasero=%d cima=%d '
              'ojos=%d manchas=%d zona_vacia=%s'
              % (d['escalones'], d['hocico_x035'], d['barba_x0365'],
                 d['trasero_x-019'], d['cima'], d['ojos_y2225'],
                 d['manchas_y215'], d['zona_vacia_27_28']))
        print('   niveles_x=%s' % d['niveles_x'])
        print('   niveles_y=%s' % d['niveles_y'])
        print('   niveles_z=%s' % d['niveles_z'])
        print('   materiales=%s' % d['materiales'])

    ruta = os.path.join(REPO, 'Temp', 'hy4_cabra_glb_probe_20261111.json')
    with open(ruta, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(out, f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write('\n')
    print('PROBE_JSON %s' % ruta)


if __name__ == '__main__':
    main()
