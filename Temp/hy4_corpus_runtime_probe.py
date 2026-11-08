#!/usr/bin/env python3
"""Sonda de solo lectura: mide tris/y_min/mats REALES del BIN para el corpus Hy4.

No es la guardia. Sirve para MEDIR antes de escribir cualquier constante.
Reutiliza el decodificador ya commiteado (verificar_triangulos_runtime.py).
"""
import importlib.util
import json
import os
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
DEC = os.path.join(REPO, 'tools', 'mcp', 'blender-mcp', '18-Casas',
                   'scripts', 'verificar_triangulos_runtime.py')
spec = importlib.util.spec_from_file_location('vtr', DEC)
vtr = importlib.util.module_from_spec(spec)
spec.loader.exec_module(vtr)

BASES = [
    '67-Vehiculos_barquita_aurora',
    '67-Vehiculos_globo_del_viento',
    '67-Vehiculos_perla_ancestral',
    '67-Vehiculos_gran_vapor',
    '157-Medios-De-Transporte_carreta_ancestral',
    '25-Ruinas-Templos_columna_rota_alta',
    '25-Ruinas-Templos_columna_rota_baja',
    '25-Ruinas-Templos_columna_entera',
    '18-Casas_casa_mansion',
    '18-Casas_casa_vecino',
]
LODS = ('alta', 'media', 'baja')

out = []
for base in BASES:
    for lod in LODS:
        p = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d',
                         lod, base + '.glb')
        if not os.path.isfile(p):
            print('FALTA %s/%s' % (lod, base), file=sys.stderr)
            continue
        checks, d = vtr.analizar(p, 0, lod)
        fallos = [c for c, ok, _ in checks if not ok]
        out.append({'base': base, 'lod': lod, 'tris': d['tris'],
                    'meshes': d['mesh_count'], 'mats': d['materiales'],
                    'y_min': round(d['y_min'], 4), 'y_max': round(d['y_max'], 4),
                    'bytes': d['bytes'], 'sha': d['sha'],
                    'fallos': fallos})
        print('%-42s %-5s tris=%-5d meshes=%-2d mats=%-2d y=[%.4f,%.4f] '
              'fallos=%s' % (base, lod, d['tris'], d['mesh_count'],
                             d['materiales'], d['y_min'], d['y_max'],
                             ','.join(fallos) or '-'))

dst = os.path.join(REPO, 'Temp', 'hy4_corpus_runtime_20261107.json')
json.dump(out, open(dst, 'w', encoding='utf-8'), indent=1)
print('\nGLB medidos: %d -> %s' % (len(out), dst))
