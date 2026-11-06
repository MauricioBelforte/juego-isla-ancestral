#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Censo de drift entre las lineas `Totales` y las marcas reales de cada 05-Checklist.

Herramienta READ-ONLY (no escribe nada). Sirve para priorizar auditorias gate-1
(AGENTS.md §21.8.2.b): un modulo cuyo `[x]` en disco supera TODO lo que el
archivo declara es candidato a promocion silenciosa.

Uso:
    python scripts/censo_drift_totales.py
    python scripts/censo_drift_totales.py --top 30
    python scripts/censo_drift_totales.py --json

Criterio de conteo (el canonico del proyecto): lineas que empiezan con
`- [x]`, `- [ ]` o `- [?]` (con indentado permitido), sobre el archivo en disco.

DECLARACION — reglas, todas nacidas de falsos positivos medidos contra el repo:

1. Se aceptan lineas de blockquote (`> **Totales:** ...`): la v1 las ignoraba y
   acababa parseando numeros de prosa ("M30 98/104") como declaracion.
2. Se descartan las lineas TACHADAS (`~~**Totales:** ...~~`), aunque el tachado
   empiece despues del `>`: son historial. (M151 declaraba 156/6/5 arriba y
   tenia una linea tachada 112/49/6 al pie; la v1 leia la tachada.)
3. Se exige que `**Totales` vaya seguido de `:` antes del cierre del negrita
   (`**Totales:**`, `**Totales (fecha):**`, `**Totales T-M112:**`). Asi se
   descarta la prosa que HABLA de totales: M122 tiene
   `- **Totales inventados** (335/335/0 sobre 265 marcadores)` y la v2.1 lo
   leia como declaracion de 335, fabricando un tipo B de -79.
4. Se aceptan las dos notaciones del proyecto:
   `Completados: N · Pendientes: M · No resueltos: K` y
   ``N `[x]` · M `[ ]` · K `[?]` `` (M32 usa la segunda y la v1 lo daba por
   "sin Totales").
5. Se descartan los SUBTOTALES: una declaracion valida debe sumar el total de
   items del archivo (x+o+q == marcas). M112 tiene `**Totales T-M112:** 17 [x]`
   (subtotal de una tanda) y sin este filtro el censo le atribuia 17 items.

VIGENCIA (el punto delicado): un archivo acumula declaraciones y NO hay un
orden fijo —M49 y M151 tienen la vigente arriba, M71 y M27 abajo, y M27 ademas
tiene una linea vieja con formato distinto al pie—. Por eso no se elige "la
ultima" ni "la primera", que produjeron ambos tipos de falso positivo:

  * tipo A: disco [x] > MAXIMO [x] declarado  -> crecimiento no declarado.
    El delta se mide contra la declaracion mas optimista, asi que es un PISO.
  * tipo B: disco [x] < MINIMO [x] declarado   -> degradaciones no reflejadas.
  * tipo C: el [x] del disco cae dentro del rango pero ninguna declaracion
    coincide en las tres cifras ([ ]/[?] desincronizados).
  * limpio: alguna declaracion coincide exactamente en x, y ademas el [ ] y el
    [?] del disco cuadran con esa misma declaracion.

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
RE_TITULO = re.compile(r'\*\*Totales\s*(?:\([^)\n]*\)|T-[A-Za-z0-9-]+)?\s*:\*\*')
CLAVES = {'x': 'x', ' ': 'o', '?': 'q'}


def es_declaracion(linea):
    """True si la linea ES una declaracion de totales (no prosa que la menciona)."""
    m = RE_TITULO.search(linea)
    if not m:
        return False
    return linea[:m.start()].count('~~') % 2 == 0


def leer_checklist(path):
    """Devuelve (conteo, declaraciones_validas)."""
    with io.open(path, 'rb') as fh:
        texto = fh.read().decode('utf-8', errors='replace')
    lineas = texto.replace('\r\n', '\n').split('\n')

    conteo = {'x': 0, 'o': 0, 'q': 0}
    for linea in lineas:
        m = RE_ITEM.match(linea)
        if m:
            conteo[CLAVES[m.group(1)]] += 1
    total = sum(conteo.values())

    candidatas = []
    for l in lineas:
        if '**Totales' not in l or not es_declaracion(l):
            continue
        decl = parsear_declaracion(l)
        if decl is None:
            continue
        candidatas.append((decl, l))

    con_total = [c for c in candidatas if sum(normalizar(c[0])) == total]
    return conteo, (con_total or candidatas)


def parsear_declaracion(linea):
    """Extrae (x, o, q) de la linea de Totales o None si no es parseable."""
    if not linea:
        return None

    def numero(patron):
        m = re.search(patron, linea, re.I)
        return int(m.group(1)) if m else None

    x = numero(r'Completados?\b[^\d]{0,12}(\d+)')
    o = numero(r'Pendientes?\b[^\d]{0,12}(\d+)')
    q = numero(r'(?:No\s+resueltos?|Sin\s+resolver)\b[^\d]{0,12}(\d+)')
    if x is None:
        x = numero(r'(\d+)\s*`?\[x\]')
    if o is None:
        o = numero(r'(\d+)\s*`?\[ ?\]')
    if q is None:
        q = numero(r'(\d+)\s*`?\[\?\]')
    if x is not None and o is not None:
        return x, o, q
    m = re.search(r'(\d+)\s*/\s*(\d+)\s*/\s*(\d+)', linea)
    if m:
        return int(m.group(1)), int(m.group(2)), int(m.group(3))
    m = re.search(r'(\d+)\s*/\s*(\d+)', linea)
    if m:
        return int(m.group(1)), int(m.group(2)), None
    return None


def normalizar(decl):
    """None en 'No resueltos' significa 0 declarado, no desconocido."""
    x, o, q = decl
    return x, o, (0 if q is None else q)


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

    crecio, bajo, desinc, limpios, sin_totales = [], [], [], 0, []
    ambiguos = 0
    for path in archivos:
        modulo = os.path.normpath(path).split(os.sep)[-3]
        conteo, cands = leer_checklist(path)
        total = sum(conteo.values())
        disco = (conteo['x'], conteo['o'], conteo['q'])
        if not cands:
            sin_totales.append({'modulo': modulo, 'disco': conteo, 'total': total})
            continue

        norm = [(normalizar(c[0]), c[1]) for c in cands]
        xs = [n[0][0] for n in norm]
        exactas = [n for n in norm if n[0] == disco]
        if exactas:
            limpios += 1
            if len(cands) > 1:
                ambiguos += 1
            continue

        if disco[0] > max(xs):
            decl, linea = max(norm, key=lambda n: n[0][0])
            fila = {'modulo': modulo, 'disco': conteo, 'declara': decl, 'total': total,
                    'linea': linea, 'declaraciones': len(cands),
                    'declara_todas': [n[0] for n in norm],
                    'delta': disco[0] - decl[0]}
            crecio.append(fila)
        elif disco[0] < min(xs):
            decl, linea = min(norm, key=lambda n: n[0][0])
            fila = {'modulo': modulo, 'disco': conteo, 'declara': decl, 'total': total,
                    'linea': linea, 'declaraciones': len(cands),
                    'declara_todas': [n[0] for n in norm],
                    'delta': decl[0] - disco[0]}
            bajo.append(fila)
        else:
            decl, linea = norm[-1]
            desinc.append({'modulo': modulo, 'disco': conteo, 'declara': decl, 'total': total,
                           'linea': linea, 'declaraciones': len(cands),
                           'declara_todas': [n[0] for n in norm]})

    crecio.sort(key=lambda r: -r['delta'])
    bajo.sort(key=lambda r: -r['delta'])
    resumen = {
        'checklists': len(archivos),
        'limpios': limpios,
        'limpios_con_varias_declaraciones': ambiguos,
        'tipo_A_x_crecio': len(crecio),
        'tipo_B_x_bajo': len(bajo),
        'tipo_C_desincronizado': len(desinc),
        'sin_totales': len(sin_totales),
        'marcas_crecidas': sum(r['delta'] for r in crecio),
        'marcas_bajadas': sum(r['delta'] for r in bajo),
    }

    if args.json:
        print(json.dumps({'resumen': resumen, 'tipo_A': crecio, 'tipo_B': bajo,
                          'tipo_C': desinc, 'sin_totales': sin_totales},
                         ensure_ascii=False, indent=2))
        return 0

    print('CENSO DE DRIFT — Totales vs marcas reales (read-only)')
    print('checklists=%d | limpios=%d | tipo A ([x] crecio)=%d (+%d marcas) | '
          'tipo B ([x] bajo)=%d (-%d marcas) | tipo C ([x] igual, [ ]/[?] no cuadran)=%d | '
          'sin Totales=%d'
          % (resumen['checklists'], limpios, len(crecio), resumen['marcas_crecidas'],
             len(bajo), resumen['marcas_bajadas'], len(desinc), len(sin_totales)))

    print('\n=== TIPO A: [x] del disco por encima de TODO lo declarado (candidatos a gate-1) ===')
    print('%-42s %-14s %-14s %-6s %s' % ('MODULO', 'DISCO', 'DECLARA (max)', '+[x]', 'DECLARACIONES'))
    for r in crecio[:args.top]:
        d, s = r['disco'], r['declara']
        print('%-42s %-14s %-14s +%-5d %s' % (r['modulo'][:42],
                                              '%d/%d/%d=%d' % (d['x'], d['o'], d['q'], r['total']),
                                              '%d/%d/%d' % s, r['delta'],
                                              '/'.join(str(x[0]) for x in r['declara_todas'])))

    print('\n=== TIPO B: [x] del disco por debajo de TODO lo declarado (degradaciones sin reflejar) ===')
    print('%-42s %-14s %-14s %-6s %s' % ('MODULO', 'DISCO', 'DECLARA (min)', '-[x]', 'DECLARACIONES'))
    for r in bajo[:args.top]:
        d, s = r['disco'], r['declara']
        print('%-42s %-14s %-14s -%-5d %s' % (r['modulo'][:42],
                                              '%d/%d/%d=%d' % (d['x'], d['o'], d['q'], r['total']),
                                              '%d/%d/%d' % s, r['delta'],
                                              '/'.join(str(x[0]) for x in r['declara_todas'])))

    if desinc:
        print('\n=== TIPO C: [x] dentro del rango declarado pero sin declaracion exacta ===')
        print('%-42s %-14s %-14s %s' % ('MODULO', 'DISCO', 'ULTIMA DECLARA', 'DECLARACIONES'))
        for r in desinc[:args.top]:
            d, s = r['disco'], r['declara']
            print('%-42s %-14s %-14s %s' % (r['modulo'][:42],
                                            '%d/%d/%d=%d' % (d['x'], d['o'], d['q'], r['total']),
                                            '%d/%d/%d' % s,
                                            '/'.join(str(x[0]) for x in r['declara_todas'])))

    print('\n=== SIN linea de Totales parseable (deuda de higiene) ===')
    for r in sin_totales:
        d = r['disco']
        print('  %-42s disco %d/%d/%d = %d' % (r['modulo'][:42], d['x'], d['o'], d['q'], r['total']))
    return 0


if __name__ == '__main__':
    sys.exit(main())
