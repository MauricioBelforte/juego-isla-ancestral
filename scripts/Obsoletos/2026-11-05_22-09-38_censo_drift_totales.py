#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Censo de drift entre la linea `Totales` y las marcas reales de cada 05-Checklist.

Herramienta READ-ONLY (no escribe nada). Sirve para priorizar auditorias gate-1
(AGENTS.md §21.8.2.b): un modulo cuyo `[x]` crecio despues del ultimo `Totales`
es candidato a promocion silenciosa; uno cuyo `[x]` bajo es un Totales stale
por degradaciones posteriores.

Uso:
    python scripts/censo_drift_totales.py
    python scripts/censo_drift_totales.py --top 30
    python scripts/censo_drift_totales.py --json

Criterio de conteo (el canonico del proyecto): lineas que empiezan con
`- [x]`, `- [ ]` o `- [?]` (con indentado permitido), sobre el archivo en disco.
La declaracion se toma de la ULTIMA linea `**Totales:**` no tachada, parseada
por etiqueta (Completados / Pendientes / No resueltos). Si no hay etiquetas se
acepta `a/b` o `a/b/c`.

Salida: codigo 0 siempre que pueda leer; 2 si no encuentra checklists.
"""

import argparse
import glob
import io
import json
import os
import re
import sys

RE_ITEM = re.compile(r'^\s*-\s*\[([ x?])\]')
RE_TOT_STRONG = re.compile(r'^\s*\*\*Totales')
RE_TOT_ANY = re.compile(r'\bTotales\b\s*[:\-]')
CLAVES = {'x': 'x', ' ': 'o', '?': 'q'}


def leer_checklist(path):
    """Devuelve (conteo, declaracion, linea_declarada)."""
    with io.open(path, 'rb') as fh:
        texto = fh.read().decode('utf-8', errors='replace')
    lineas = texto.replace('\r\n', '\n').split('\n')

    conteo = {'x': 0, 'o': 0, 'q': 0}
    for linea in lineas:
        m = RE_ITEM.match(linea)
        if m:
            conteo[CLAVES[m.group(1)]] += 1

    candidatas = [l for l in lineas if RE_TOT_STRONG.match(l) and not l.strip().startswith('~~')]
    if not candidatas:
        candidatas = [l for l in lineas
                      if RE_TOT_ANY.search(l)
                      and not l.strip().startswith(('~~', '>', '-', '*'))]
    linea_tot = candidatas[-1] if candidatas else None
    return conteo, parsear_declaracion(linea_tot) if linea_tot else None, linea_tot


def parsear_declaracion(linea):
    """Extrae (x, o, q) de la linea de Totales o None si no es parseable."""
    if not linea:
        return None

    def numero(patron):
        m = re.search(patron, linea, re.I)
        return int(m.group(1)) if m else None

    x = numero(r'Completados?\b[^\d]{0,8}(\d+)')
    o = numero(r'Pendientes?\b[^\d]{0,8}(\d+)')
    q = numero(r'(?:No\s+resueltos?|Sin\s+resolver)\b[^\d]{0,8}(\d+)')
    if x is not None and o is not None and q is not None:
        return x, o, q

    m = re.search(r'(\d+)\s*/\s*(\d+)\s*/\s*(\d+)', linea)
    if m:
        return int(m.group(1)), int(m.group(2)), int(m.group(3))
    m = re.search(r'(\d+)\s*/\s*(\d+)', linea)
    if m:
        return int(m.group(1)), int(m.group(2)), None
    return None


def main():
    ap = argparse.ArgumentParser(description='Censo de drift Totales vs marcas reales (read-only).')
    ap.add_argument('--raiz', default='.', help='raiz del proyecto (default: .)')
    ap.add_argument('--top', type=int, default=20, help='cuantos modulos mostrar por lista (default 20)')
    ap.add_argument('--json', action='store_true', help='salida JSON')
    args = ap.parse_args()

    patron = os.path.join(args.raiz, 'DOCUMENTACION', '*', 'plan-actual', '05-Checklist.md')
    archivos = sorted(glob.glob(patron))
    if not archivos:
        print('No se encontraron checklists en %s' % patron, file=sys.stderr)
        return 2

    crecio, bajo, limpios, sin_totales = [], [], 0, []
    for path in archivos:
        modulo = os.path.normpath(path).split(os.sep)[-3]
        conteo, decl, linea = leer_checklist(path)
        total = sum(conteo.values())
        if decl is None:
            sin_totales.append({'modulo': modulo, 'disco': conteo, 'total': total})
        elif (decl[0], decl[1], decl[2]) == (conteo['x'], conteo['o'], conteo['q']):
            limpios += 1
        elif conteo['x'] > decl[0]:
            crecio.append({'modulo': modulo, 'disco': conteo, 'declara': decl,
                           'delta': conteo['x'] - decl[0], 'total': total})
        else:
            bajo.append({'modulo': modulo, 'disco': conteo, 'declara': decl,
                         'delta': decl[0] - conteo['x'], 'total': total})

    crecio.sort(key=lambda r: -r['delta'])
    bajo.sort(key=lambda r: -r['delta'])
    resumen = {
        'checklists': len(archivos),
        'limpios': limpios,
        'tipo_A_x_crecio': len(crecio),
        'tipo_B_x_bajo': len(bajo),
        'sin_totales': len(sin_totales),
        'marcas_crecidas': sum(r['delta'] for r in crecio),
        'marcas_bajadas': sum(r['delta'] for r in bajo),
    }

    if args.json:
        print(json.dumps({'resumen': resumen, 'tipo_A': crecio, 'tipo_B': bajo,
                          'sin_totales': sin_totales}, ensure_ascii=False, indent=2))
        return 0

    print('CENSO DE DRIFT — Totales vs marcas reales (read-only)')
    print('checklists=%d | limpios=%d | tipo A ([x] crecio)=%d (+%d marcas) | '
          'tipo B ([x] bajo)=%d (-%d marcas) | sin Totales=%d'
          % (resumen['checklists'], limpios, len(crecio), resumen['marcas_crecidas'],
             len(bajo), resumen['marcas_bajadas'], len(sin_totales)))

    print('\n=== TIPO A: [x] crecio despues del ultimo Totales (candidatos a gate-1) ===')
    print('%-42s %-14s %-14s %s' % ('MODULO', 'DISCO', 'DECLARA', '+[x]'))
    for r in crecio[:args.top]:
        d, s = r['disco'], r['declara']
        print('%-42s %-14s %-14s +%d' % (r['modulo'][:42],
                                         '%d/%d/%d=%d' % (d['x'], d['o'], d['q'], r['total']),
                                         '%d/%d/%s' % (s[0], s[1], s[2]), r['delta']))

    print('\n=== TIPO B: [x] bajo despues del Totales (degradaciones sin actualizar) ===')
    print('%-42s %-14s %-14s %s' % ('MODULO', 'DISCO', 'DECLARA', '-[x]'))
    for r in bajo[:args.top]:
        d, s = r['disco'], r['declara']
        print('%-42s %-14s %-14s -%d' % (r['modulo'][:42],
                                         '%d/%d/%d=%d' % (d['x'], d['o'], d['q'], r['total']),
                                         '%d/%d/%s' % (s[0], s[1], s[2]), r['delta']))

    print('\n=== SIN linea de Totales parseable (deuda de higiene) ===')
    for r in sin_totales:
        d = r['disco']
        print('  %-42s disco %d/%d/%d = %d' % (r['modulo'][:42], d['x'], d['o'], d['q'], r['total']))
    return 0


if __name__ == '__main__':
    sys.exit(main())
