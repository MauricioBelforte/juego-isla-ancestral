#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Sonda de CALIBRACION B26: decodifica el BIN real de los 3 GLB `mariposa`.

NO es un test: es medicion previa. Reutiliza el decoder AUTOCONTENIDO ya
probado de `verificar_gallina.py` (B25); la guardia B26 sera independiente.

Particularidad de B26: las alas se separan en el eje Y de Blender, que en
glTF aparece como la coordenada p[2] (lateral), mientras la ALTURA es p[1].
Por eso se miden `niveles_alt` y `niveles_lat` por separado.
"""
import json
import os
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
SCRIPTS = os.path.join(REPO, 'tools', 'mcp', 'blender-mcp', '36-Fauna', 'scripts')
sys.path.insert(0, SCRIPTS)
from verificar_gallina import (  # noqa: E402
    cargar, recorrer, leer_vec, aplicar,
)

GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
BASE = '36-Fauna_mariposa.glb'
LODS = ('alta', 'media', 'baja')


def medir(path):
    raw, doc, bin_, ok = cargar(path)
    assert ok, 'GLB ilegible: %s' % path
    alcanzables, instancias = recorrer(doc)

    nombre_por_mesh = {}
    for i in sorted(alcanzables):
        n = doc['nodes'][i]
        if 'mesh' in n:
            nombre_por_mesh.setdefault(n['mesh'], []).append(n.get('name', ''))

    puntos = []       # (x, alt, lat, nombre_nodo, material)
    por_nodo = {}
    tris = 0
    for mi, m in instancias:
        nombres = nombre_por_mesh.get(mi, [])
        nombre = nombres[0] if nombres else '?'
        for pr in doc['meshes'][mi].get('primitives', []):
            mat_i = pr.get('material')
            mat = (doc['materials'][mat_i].get('name', '')
                   if mat_i is not None else '')
            pos, e = leer_vec(doc, bin_, pr['attributes']['POSITION'], 'f', 3)
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
            for q in pos:
                w = aplicar(m, q)
                p = (w[0], w[1], w[2])
                puntos.append((w[0], w[1], w[2], nombre, mat))
                por_nodo.setdefault(nombre, []).append((p, mat))

    xs = [p[0] for p in puntos]
    alt = [p[1] for p in puntos]
    lat = [p[2] for p in puntos]
    lx = sorted({round(v, 4) for v in xs})
    la = sorted({round(v, 4) for v in alt})
    ll = sorted({round(v, 4) for v in lat})
    apoyo = {(round(p[0], 4), round(p[2], 4)) for p in puntos
             if abs(p[1] - 0.045) <= 1e-3}

    alas = {}
    for nombre, items in sorted(por_nodo.items()):
        if 'Ala_' not in nombre:
            continue
        vs = [p for p, _ in items]
        mats = sorted({m for _, m in items})
        alas[nombre] = {
            'verts': len(vs), 'materiales': mats,
            'x': [round(min(p[0] for p in vs), 4), round(max(p[0] for p in vs), 4)],
            'alt': [round(min(p[1] for p in vs), 4), round(max(p[1] for p in vs), 4)],
            'lat': [round(min(p[2] for p in vs), 4), round(max(p[2] for p in vs), 4)],
            'niveles_alt': sorted({round(p[1], 4) for p in vs}),
            'niveles_lat': sorted({round(p[2], 4) for p in vs}),
        }

    # Contacto REAL ala-cuerpo medido en el BIN: vertices de ala con
    # |lat|<=0.06, altura dentro del cuerpo y x dentro del cuerpo.
    contacto = {}
    for nombre, items in sorted(por_nodo.items()):
        if 'Ala_' not in nombre:
            continue
        contacto[nombre] = sum(
            1 for p, _ in items
            if abs(p[2]) <= 0.0601 and 0.0849 <= p[1] <= 0.2651
            and -0.1901 <= p[0] <= 0.2201)

    colores = {}
    for m in doc.get('materials', []):
        f = m.get('pbrMetallicRoughness', {}).get('baseColorFactor')
        if f:
            colores[m.get('name', '')] = [round(v, 4) for v in f[:3]]

    return {
        'bytes': len(raw), 'tris': tris,
        'mats': len(doc.get('materials', [])), 'mallas': len(doc['meshes']),
        'nodos': len(alcanzables), 'verts': len(puntos),
        'x': [round(min(xs), 4), round(max(xs), 4)],
        'alt': [round(min(alt), 4), round(max(alt), 4)],
        'lat': [round(min(lat), 4), round(max(lat), 4)],
        'apoyo': len(apoyo),
        'escalones': {t: sum(1 for p in puntos if abs(p[1] - t) < 1e-4)
                      for t in (0.155, 0.225, 0.265)},
        'niveles_ala': {t: sum(1 for p in puntos if abs(p[1] - t) < 1e-4)
                        for t in (0.105, 0.205, 0.21, 0.31)},
        'zona_vacia_27_28': sorted(v for v in la if 0.27 < v < 0.28),
        'lat_ext_022': sum(1 for p in puntos if abs(abs(p[2]) - 0.22) < 1e-4),
        'lat_int_004': sum(1 for p in puntos if abs(abs(p[2]) - 0.04) < 1e-4),
        'niveles_x': lx, 'niveles_alt': la, 'niveles_lat': ll,
        'alas': alas, 'contacto': contacto,
        'materiales': sorted(m.get('name', '') for m in doc.get('materials', [])),
        'colores': colores,
    }


def main():
    out = {}
    for lod in LODS:
        d = medir(os.path.join(GODOT, lod, BASE))
        out[lod] = d
        print('%-5s tris=%-4d mats=%d mallas=%d nodos=%d verts=%-4d '
              'x=[%.4f..%.4f] alt=[%.4f..%.4f] lat=[%.4f..%.4f] apoyo=%d'
              % (lod, d['tris'], d['mats'], d['mallas'], d['nodos'], d['verts'],
                 d['x'][0], d['x'][1], d['alt'][0], d['alt'][1],
                 d['lat'][0], d['lat'][1], d['apoyo']))
        print('   escalones=%s niveles_ala=%s zona_vacia=%s '
              'lat_ext022=%d lat_int004=%d'
              % (d['escalones'], d['niveles_ala'], d['zona_vacia_27_28'],
                 d['lat_ext_022'], d['lat_int_004']))
        print('   niveles_x=%s' % d['niveles_x'])
        print('   niveles_alt=%s' % d['niveles_alt'])
        print('   niveles_lat=%s' % d['niveles_lat'])
        print('   ALAS:')
        for nombre, a in d['alas'].items():
            print('     %-38s verts=%-3d mats=%s x=%s alt=%s lat=%s'
                  % (nombre, a['verts'], a['materiales'], a['x'], a['alt'], a['lat']))
            print('       niveles_alt=%s niveles_lat=%s'
                  % (a['niveles_alt'], a['niveles_lat']))
        print('   CONTACTO ala-cuerpo (vertices BIN)=%s' % d['contacto'])
        print('   materiales=%s' % d['materiales'])
        print('   colores=%s' % d['colores'])

    ruta = os.path.join(REPO, 'Temp', 'hy4_mariposa_glb_probe_20261113.json')
    with open(ruta, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(out, f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write('\n')
    print('PROBE_JSON %s' % ruta)


if __name__ == '__main__':
    main()
