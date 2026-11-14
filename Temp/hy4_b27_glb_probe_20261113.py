#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Sonda de CALIBRACION B27: decodifica el BIN real de los 12 GLB de la
nueva COLA ACTIVA del acuse 71 (Columnas M25 / Semillero / Palanca).

NO es un test: es medicion previa. Reutiliza el decoder AUTOCONTENIDO ya
probado de `verificar_mariposa.py` (B26). La guardia B27 sera independiente.

Ejes glTF Y-up: p[0]=X, p[1]=ALTURA (Z de Blender), p[2]=LATERAL.
"""
import json
import os
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
SCRIPTS = os.path.join(REPO, 'tools', 'mcp', 'blender-mcp', '36-Fauna', 'scripts')
sys.path.insert(0, SCRIPTS)
from verificar_mariposa import (  # noqa: E402
    cargar, recorrer, leer_vec, aplicar, sha12,
)

GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
LODS = ('alta', 'media', 'baja')
GRUPOS = {
    'columna_rota_alta': '25-Ruinas-Templos_columna_rota_alta.glb',
    'columna_rota_baja': '25-Ruinas-Templos_columna_rota_baja.glb',
    'cultivo_brote': '33-Agricultura_cultivo_brote.glb',
    'palanca_madera': '70-Interacciones_palanca_madera.glb',
}


def medir(path):
    raw, doc, bin_, ok = cargar(path)
    assert ok, 'GLB ilegible: %s' % path
    alcanzables, instancias = recorrer(doc)

    nombre_por_mesh = {}
    for i, n in enumerate(doc['nodes']):
        if 'mesh' in n:
            nombre_por_mesh.setdefault(n['mesh'], []).append(n.get('name', ''))

    puntos, por_nodo = [], {}
    tris = 0
    for mi, m in instancias:
        nombre = (nombre_por_mesh.get(mi) or ['?'])[0]
        for pr in doc['meshes'][mi].get('primitives', []):
            pos, e = leer_vec(doc, bin_, pr['attributes']['POSITION'], 'f', 3)
            assert not e and pos, 'POSITION ilegible: %s' % e
            ai = pr.get('indices')
            if ai is None:
                count = len(pos)
            else:
                fmt = {5121: 'B', 5123: 'H', 5125: 'I'}.get(
                    doc['accessors'][ai]['componentType'], 'H')
                vals, e2 = leer_vec(doc, bin_, ai, fmt, 1)
                assert not e2
                count = doc['accessors'][ai]['count']
            tris += count // 3
            for q in pos:
                w = aplicar(m, q)
                puntos.append(w)
                por_nodo.setdefault(nombre, []).append(w)

    xs = [p[0] for p in puntos]
    alt = [p[1] for p in puntos]
    lat = [p[2] for p in puntos]
    apoyo = {(round(p[0], 4), round(p[2], 4)) for p in puntos
             if abs(p[1] - 0.045) <= 1e-3}

    return {
        'bytes': len(raw), 'tris': tris,
        'mats': len(doc.get('materials', [])), 'mallas': len(doc['meshes']),
        'nodos': len(alcanzables), 'verts': len(puntos),
        'x': [round(min(xs), 4), round(max(xs), 4)],
        'alt': [round(min(alt), 4), round(max(alt), 4)],
        'lat': [round(min(lat), 4), round(max(lat), 4)],
        'altura': round(max(alt) - min(alt), 4),
        'apoyo': len(apoyo),
        'niveles_alt': sorted({round(v, 4) for v in alt}),
        'niveles_x': sorted({round(v, 4) for v in xs}),
        'niveles_lat': sorted({round(v, 4) for v in lat}),
        'materiales': sorted(m.get('name', '')
                             for m in doc.get('materials', [])),
        'nodos_sm': sorted(n for n in por_nodo if n.startswith('SM_')),
        'sha': sha12(path),
    }


def main():
    out = {}
    for grupo, base in GRUPOS.items():
        out[grupo] = {}
        for lod in LODS:
            p = os.path.join(GODOT, lod, base)
            d = medir(p)
            out[grupo][lod] = d
            print('%-20s %-5s tris=%-5d mats=%-2d mallas=%-3d nodos=%-3d '
                  'verts=%-5d alt=[%.4f..%.4f] h=%.4f apoyo=%-3d sha=%s'
                  % (grupo, lod, d['tris'], d['mats'], d['mallas'], d['nodos'],
                     d['verts'], d['alt'][0], d['alt'][1], d['altura'],
                     d['apoyo'], d['sha']))
            print('    niveles_alt=%s' % d['niveles_alt'])
            print('    materiales=%s' % d['materiales'])
        aa = out[grupo]['alta']
        print('    >> altura ALTA=%.4f MEDIA=%.4f BAJA=%.4f | '
              'tris=%d/%d/%d | mats=%d/%d/%d'
              % (aa['altura'], out[grupo]['media']['altura'],
                 out[grupo]['baja']['altura'],
                 aa['tris'], out[grupo]['media']['tris'],
                 out[grupo]['baja']['tris'],
                 aa['mats'], out[grupo]['media']['mats'],
                 out[grupo]['baja']['mats']))

    print('=== DIFERENCIA ENTRE VARIANTES DE COLUMNA ROTA ===')
    for lod in LODS:
        a = out['columna_rota_alta'][lod]
        b = out['columna_rota_baja'][lod]
        print('%-5s alta_h=%.4f baja_h=%.4f diff=%.4f | '
              'topes %.4f / %.4f | tris %d / %d'
              % (lod, a['altura'], b['altura'],
                 a['altura'] - b['altura'],
                 a['alt'][1], b['alt'][1], a['tris'], b['tris']))

    ruta = os.path.join(REPO, 'Temp', 'hy4_b27_glb_probe_20261113.json')
    with open(ruta, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(out, f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write('\n')
    print('PROBE_JSON %s' % ruta)


if __name__ == '__main__':
    main()
