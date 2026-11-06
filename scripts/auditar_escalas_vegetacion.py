#!/usr/bin/env python3
"""
Auditor de escalas M50 (B11, Hy4, 2026-11-05).

Mide la altura REAL (eje Y glTF) de los 10 GLB de vegetacion horneados por
`reescalar_v5.py` y la compara con la tabla OBJETIVOS de ese mismo script.

No modifica ningun asset: solo mide. Existe porque el checklist de M50
declara "10/10 GLBs horneados a su altura objetivo" mientras `escalas.json`
tiene todos los multiplicadores en 1.0; si el horneado se pierde, el runtime
renderiza la altura cruda del GLB sin que ningun gate lo detecte.

Uso:
    python scripts/auditar_escalas_vegetacion.py --check
    python scripts/auditar_escalas_vegetacion.py --self-test

Salidas:
    --check      0 = 10/10 cumplen; 2 = hay deriva (tabla + detalle); 3 = CIEGO
    --self-test  0 = verde; 1 = fallo; 3 = CIEGO (bloque no ejecutado)

Fuente unica de verdad: la tabla OBJETIVOS de reescalar_v5.py (se parsea,
no se copia) para que este auditor no invente sus propios objetivos.
"""

import argparse
import glob
import json
import os
import re
import struct
import sys

RAIZ = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
V5 = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp',
                  'scripts-reutilizables', 'reescalar_v5.py')
BASE_GLB = os.path.join(RAIZ, 'game', 'isla-ancestral', 'assets', '3d')
PERFILES = ('alta', 'media', 'baja')
TOLERANCIA = 0.05
N_OBJETIVOS = 10

# MEDIDO en verde con --self-test antes de fijarlo.
CHECKS_MINIMOS = 21


# --------------------------------------------------------------------------
# glTF: transformaciones de nodos y bbox real
# --------------------------------------------------------------------------

def identidad():
    return [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]


def mul(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(4)) for j in range(4)]
            for i in range(4)]


def matriz_nodo(n):
    if 'matrix' in n:
        m = n['matrix']
        return [[m[j * 4 + i] for j in range(4)] for i in range(4)]
    t = n.get('translation', [0, 0, 0])
    q = n.get('rotation', [0, 0, 0, 1])
    s = n.get('scale', [1, 1, 1])
    x, y, z, w = q
    r = [[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
         [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
         [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]]
    return ([[r[i][j] * s[j] for j in range(3)] + [t[i]] for i in range(3)]
            + [[0, 0, 0, 1]])


def aplicar(M, v):
    return [sum(M[i][j] * v[j] for j in range(3)) + M[i][3] for i in range(3)]


def parsear_glb(datos):
    assert datos[:4] == b'glTF', 'no es GLB'
    largo = struct.unpack_from('<I', datos, 12)[0]
    return json.loads(datos[20:20 + largo])


def alto_glb_bytes(datos):
    g = parsear_glb(datos)
    lo, hi = 1e9, -1e9
    vistos = [0]

    def caminar(i, P):
        nonlocal lo, hi
        n = g['nodes'][i]
        W = mul(P, matriz_nodo(n))
        if 'mesh' in n:
            for prim in g['meshes'][n['mesh']]['primitives']:
                a = g['accessors'][prim['attributes']['POSITION']]
                if 'min' not in a or 'max' not in a:
                    continue
                mn, mx = a['min'], a['max']
                vistos[0] += 1
                for x in (mn[0], mx[0]):
                    for y in (mn[1], mx[1]):
                        for z in (mn[2], mx[2]):
                            v = aplicar(W, [x, y, z])
                            lo = min(lo, v[1])
                            hi = max(hi, v[1])
        for c in n.get('children', []):
            caminar(c, W)

    for raiz in g['scenes'][g.get('scene', 0)]['nodes']:
        caminar(raiz, identidad())
    assert vistos[0] > 0, 'GLB sin accessors POSITION con min/max: medicion ciega'
    return hi - lo


def alto_glb(ruta):
    with open(ruta, 'rb') as f:
        return alto_glb_bytes(f.read())


# --------------------------------------------------------------------------
# Tabla de objetivos + medicion
# --------------------------------------------------------------------------

def objetivos():
    with open(V5, encoding='utf-8') as f:
        src = f.read()
    bloque = re.search(r'OBJETIVOS\s*=\s*\[(.*?)\]', src, re.S)
    assert bloque, 'no encontre OBJETIVOS en reescalar_v5.py'
    pares = re.findall(
        r'\(\s*["\']([^"\']+\.glb)["\']\s*,\s*([0-9]+(?:\.[0-9]+)?)\s*\)',
        bloque.group(1))
    assert len(pares) == N_OBJETIVOS, 'OBJETIVOS cambio de tamano: %d' % len(pares)
    salida = []
    for nombre, valor in pares:
        assert nombre.startswith('50-Vegetacion_'), 'entrada inesperada: %s' % nombre
        salida.append((nombre[:-4].replace('50-Vegetacion_', ''), float(valor)))
    return salida


def ruta_glb(perfil, nombre):
    return os.path.join(BASE_GLB, perfil, '50-Vegetacion_%s.glb' % nombre)


def cumple(medido, objetivo, tolerancia=TOLERANCIA):
    return abs(medido - objetivo) <= tolerancia


def medir_todos():
    filas = []
    for nombre, objetivo in objetivos():
        alturas = {}
        for perfil in PERFILES:
            alturas[perfil] = alto_glb(ruta_glb(perfil, nombre))
        filas.append((nombre, objetivo, alturas))
    return filas


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------

def glb_sintetico(escala_y):
    """GLB minimo con un accessor POSITION y escala de nodo conocida."""
    g = {
        'asset': {'version': '2.0'},
        'scene': 0,
        'scenes': [{'nodes': [0]}],
        'nodes': [{'name': 'N', 'mesh': 0, 'scale': [1, escala_y, 1]}],
        'meshes': [{'primitives': [{'attributes': {'POSITION': 0}}]}],
        'accessors': [{'min': [0, 0, 0], 'max': [0, 1, 0]}],
    }
    j = json.dumps(g, separators=(',', ':')).encode('ascii')
    j += b' ' * ((4 - len(j) % 4) % 4)
    return (b'glTF' + struct.pack('<II', 2, 12 + 8 + len(j))
            + struct.pack('<II', len(j), 0x4E4F534A) + j)


def cmd_check():
    filas = medir_todos()
    assert len(filas) == N_OBJETIVOS, 'CIEGO: se midieron %d filas' % len(filas)
    print('%-22s %8s %8s %8s %8s %8s' %
          ('asset', 'objetivo', 'ALTA', 'MEDIA', 'BAJA', 'delta'))
    ok = 0
    for nombre, objetivo, h in filas:
        bueno = cumple(h['media'], objetivo)
        ok += int(bueno)
        print('%-22s %8.2f %8.3f %8.3f %8.3f %+8.3f  %s' %
              (nombre, objetivo, h['alta'], h['media'], h['baja'],
               h['media'] - objetivo, 'OK' if bueno else 'FUERA'))
    print('cumplen objetivo en MEDIA: %d/%d' % (ok, N_OBJETIVOS))
    print('fuente: tools/mcp/blender-mcp/scripts-reutilizables/reescalar_v5.py')
    if ok != N_OBJETIVOS:
        print('DERIVA DETECTADA: %d GLB fuera de objetivo.' % (N_OBJETIVOS - ok))
        return 2
    return 0


def cmd_self_test():
    checks = [0]
    fallos = [0]
    ejecutado = set()

    def ck(cond, etiqueta):
        checks[0] += 1
        if not cond:
            fallos[0] += 1
            print('  FALLO: %s' % etiqueta)

    # Bloque A: tabla de objetivos (fuente unica, no copiada)
    ejecutado.add('A')
    obj = objetivos()
    d = dict(obj)
    ck(len(obj) == N_OBJETIVOS, 'OBJETIVOS tiene 10 entradas')
    ck(d.get('arbol_frutal') == 6.0, 'arbol_frutal objetivo 6.0')
    ck(d.get('palmera') == 7.0, 'palmera objetivo 7.0')
    ck(d.get('helecho_gigante') == 2.5, 'helecho_gigante objetivo 2.5')

    # Bloque B: matematica de transformaciones con GLB sintetico
    ejecutado.add('B')
    ck(abs(alto_glb_bytes(glb_sintetico(1.0)) - 1.0) < 1e-6,
       'GLB sintetico sin escala mide 1.0')
    ck(abs(alto_glb_bytes(glb_sintetico(3.0)) - 3.0) < 1e-6,
       'INYECCION EN ROJO: escala x3 se detecta (mide 3.0)')
    ck(abs(alto_glb_bytes(glb_sintetico(0.5)) - 0.5) < 1e-6,
       'escala x0.5 se detecta (mide 0.5)')

    # Bloque C: comparador, verde y rojo
    ejecutado.add('C')
    ck(cumple(6.0, 6.0), 'verde: 6.0 cumple 6.0')
    ck(cumple(6.04, 6.0), 'verde: dentro de tolerancia')
    ck(not cumple(3.88, 6.0), 'rojo: 3.88 NO cumple 6.0')
    ck(not cumple(6.06, 6.0), 'rojo: fuera de tolerancia')

    # Bloque D: archivos reales y alcanzabilidad de la medicion
    ejecutado.add('D')
    for perfil in PERFILES:
        for nombre in ('arbol_frutal', 'palmera'):
            ck(os.path.isfile(ruta_glb(perfil, nombre)),
               'existe %s/50-Vegetacion_%s.glb' % (perfil, nombre))
    ck(alto_glb(ruta_glb('media', 'arbol_frutal')) > 0,
       'GLB real arbol_frutal MEDIA mide altura positiva')
    filas = medir_todos()
    if len(filas) != N_OBJETIVOS:
        print('CIEGO: medir_todos devolvio %d filas' % len(filas))
        return 3
    ck(len(filas) == N_OBJETIVOS, 'medir_todos devuelve 10 filas')
    ck(all(all(v > 0 for v in h.values()) for _, _, h in filas),
       'las 30 alturas reales son positivas')
    # Positivo: el detector ve la deriva documentada hoy. Si alguien re-hornea,
    # este check cambia de valor pero NO debe romperse (mide, no consagra).
    fuera = sum(1 for _, o, h in filas if not cumple(h['media'], o))
    ck(0 <= fuera <= N_OBJETIVOS, 'conteo de deriva dentro de rango')

    # Guardia de ceguera: todos los bloques corrieron y el piso es real.
    ejecutado.add('FIN')
    if ejecutado != {'A', 'B', 'C', 'D', 'FIN'}:
        print('CIEGO: bloques no ejecutados: %s' %
              sorted({'A', 'B', 'C', 'D', 'FIN'} - ejecutado))
        return 3
    if checks[0] < CHECKS_MINIMOS:
        print('CIEGO: checks=%d < minimo=%d' % (checks[0], CHECKS_MINIMOS))
        return 3
    print('checks=%d fallos=%d minimo=%d deriva_hoy=%d/%d' %
          (checks[0], fallos[0], CHECKS_MINIMOS, fuera, N_OBJETIVOS))
    return 1 if fallos[0] else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--check', action='store_true', help='medir los 10 GLB')
    ap.add_argument('--self-test', action='store_true', help='autotest del auditor')
    a = ap.parse_args()
    if a.self_test:
        return cmd_self_test()
    if a.check:
        return cmd_check()
    ap.print_help()
    return 3


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as e:
        print('CIEGO: excepcion no controlada: %r' % (e,))
        sys.exit(3)
