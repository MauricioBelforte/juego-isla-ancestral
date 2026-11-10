#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Sonda de CALIBRACION B22: decodifica el BIN real de los 6 GLB de
`pez_tropical` (azul/naranja x alta/media/baja) y publica TODAS las cotas
que la guardia positiva necesita. NO es un test: es medicion previa.

Reutiliza el decoder AUTOCONTENIDO de `verificar_cangrejo_ermitano.py` (B21)
para no inventar un segundo parser. La guardia B22 sera independiente.
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
VARIANTES = ('azul', 'naranja')
LODS = ('alta', 'media', 'baja')


def medir(path):
    raw, doc, bin_, ok = cargar(path)
    assert ok, 'GLB ilegible: %s' % path
    _, instancias = recorrer(doc)
    mat_por_mesh = {}
    for mi, m in instancias:
        mat_por_mesh.setdefault(mi, []).append(m)

    puntos, tris, n_prims = [], 0, 0
    for mi, mesh in enumerate(doc['meshes']):
        mats = mat_por_mesh.get(mi, [ident()])
        for pr in mesh.get('primitives', []):
            n_prims += 1
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
    colores = {m.get('name', ''): (m.get('pbrMetallicRoughness', {})
               .get('baseColorFactor', [])) for m in doc.get('materials', [])}

    # Senales de silueta (POSITIVAS, no AABB)
    escalones = {t: round(max([p[0] for p in puntos
                               if abs(p[1] - t) < 1e-4] or [-1])
                          - min([p[0] for p in puntos
                                 if abs(p[1] - t) < 1e-4] or [1]), 4)
                 for t in (0.155, 0.215, 0.255)}
    ojos = sum(1 for p in puntos if abs(p[1] - 0.205) < 1e-4)
    detalles = sum(1 for p in puntos if 0.155 < p[1] < 0.19)
    caudal = sum(1 for p in puntos if abs(p[0] + 0.30) < 1e-4)
    hocico = sum(1 for p in puntos if abs(p[0] - 0.29) < 1e-4)
    cima = sum(1 for p in puntos if abs(p[1] - 0.335) < 1e-4)

    return {
        'bytes': len(raw), 'tris': tris, 'prims': n_prims,
        'mats': len(doc.get('materials', [])), 'mallas': len(doc['meshes']),
        'nodos': len(doc['nodes']), 'verts': len(puntos),
        'x': [round(min(xs), 4), round(max(xs), 4)],
        'y': [round(min(ys), 4), round(max(ys), 4)],
        'z': [round(min(zs), 4), round(max(zs), 4)],
        'xr': round(max(xs) - min(xs), 4),
        'zr': round(max(zs) - min(zs), 4),
        'apoyo': len(apoyo),
        'escalones': escalones,
        'ojos_y205': ojos, 'detalles_155_19': detalles,
        'caudal_x-030': caudal, 'hocico_x029': hocico, 'cima_y0335': cima,
        'zona_vacia_26_27': sorted(v for v in ly if 0.26 < v < 0.27),
        'niveles_x': lx, 'niveles_y': ly, 'niveles_z': lz,
        'materiales': nombres, 'colores': colores,
    }


def main():
    out = {}
    for v in VARIANTES:
        for lod in LODS:
            path = os.path.join(GODOT, lod, '36-Fauna_pez_tropical_%s.glb' % v)
            d = medir(path)
            out['%s/%s' % (v, lod)] = d
            print('%s/%-5s tris=%-4d mats=%d mallas=%d verts=%-4d '
                  'x=[%.4f..%.4f] y=[%.4f..%.4f] z=[%.4f..%.4f] '
                  'xr=%.4f zr=%.4f apoyo=%d'
                  % (v, lod, d['tris'], d['mats'], d['mallas'], d['verts'],
                     d['x'][0], d['x'][1], d['y'][0], d['y'][1],
                     d['z'][0], d['z'][1], d['xr'], d['zr'], d['apoyo']))
            print('   escalones=%s ojos=%d detalles=%d caudal=%d hocico=%d '
                  'cima=%d zona_vacia=%s'
                  % (d['escalones'], d['ojos_y205'], d['detalles_155_19'],
                     d['caudal_x-030'], d['hocico_x029'], d['cima_y0335'],
                     d['zona_vacia_26_27']))
            print('   niveles_x=%s' % d['niveles_x'])
            print('   niveles_y=%s' % d['niveles_y'])
            print('   niveles_z=%s' % d['niveles_z'])
            print('   materiales=%s' % d['materiales'])
            print('   colores=%s' % json.dumps(d['colores'],
                                              ensure_ascii=False,
                                              sort_keys=True))

    ruta = os.path.join(REPO, 'Temp', 'hy4_pez_glb_probe_20261110.json')
    with open(ruta, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(out, f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write('\n')
    print('PROBE_JSON %s' % ruta)

    # Comparacion POSITIVA entre variantes: NO pueden ser copias.
    # Los nombres de material llevan el token Azul/Naranja -> normalizar.
    def canon(d):
        return {k.replace('_Azul_', '_V_').replace('_Naranja_', '_V_'): v
                for k, v in d.items()}

    for lod in LODS:
        a = canon(out['azul/' + lod]['colores'])
        n = canon(out['naranja/' + lod]['colores'])
        comunes = set(a) & set(n)
        dif = sum(1 for k in comunes if a[k] != n[k])
        print('VARIANTE %-5s pares_comunes=%d colores_distintos=%d/%d'
              % (lod, len(comunes), dif, len(comunes)))


if __name__ == '__main__':
    main()
