#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Guardia positiva de los 3 GLB de `casa_vecino` (18-BIS -> Godot).

No es QA §21.8 ni sello: verifica EFECTOS medibles sobre el binario GLB,
no la existencia del archivo ni un conteo de checks declarado.

Uso:
    python verificar_casa_vecino.py -- <alta.glb> <media.glb> <baja.glb>

    VERDE  -> 3 bloques (36 checks), fallos 0, exit 0
    ROJO   -> 3 bloques, fallos > 0, exit 1   (inyectar un GLB mutado)
    CIEGO  -> menos de 3 bloques, exit 3     (un bloque que no se llama
              NO puede hacerse pasar por verde)

Un check que FALLA sigue contando como EJECUTADO. Si solo se contaran los
verdes, el rojo pareceria CIEGO y la guardia seria un falso verde.

Trampas que esta guardia evita a proposito:
  * No usa las 8 esquinas del AABB del accessor: con nodos rotados inflan
    el bounding box. Decodifica VERTICES REALES del BIN.
  * Matrices glTF COLUMN-MAJOR: M[c*4+r], traslacion en M[12..14].
  * glTF es Y-up: la ALTURA es y, no z (Blender es Z-up).
  * No busca el literal de un nombre de merge: MiMo conserva los 14 nodos
    SM_ en los 3 LOD, asi que la asercion positiva es por PRESENCIA de nodos
    de identidad, no por ausencia de un sufijo.
"""

import json
import os
import struct
import sys

# MEDIDO en verde con el piso en 0 el 2026-11-07: 12 checks x 3 bloques.
CHECKS_MINIMOS = 36

NODOS_IDENTIDAD = (
    ('SM_Cama', 'C4'),
    ('SM_Cocina', 'C5'),
    ('SM_Mesa_Sillas', 'C6'),
    ('SM_Pared_Sur', 'C7'),
)
PROHIBIDOS = ('Base_Arena', 'SOL', 'CAM_', 'Arena', 'Luz', 'Light')
MATS_ESPERADOS = {'alta': 8, 'media': 6, 'baja': 4}


def ident():
    return [1., 0., 0., 0.,
            0., 1., 0., 0.,
            0., 0., 1., 0.,
            0., 0., 0., 1.]


def mul(a, b):
    r = [0.0] * 16
    for c in range(4):
        for rr in range(4):
            r[c * 4 + rr] = sum(a[k * 4 + rr] * b[c * 4 + k] for k in range(4))
    return r


def trs(n):
    if 'matrix' in n:
        return list(n['matrix'])
    q = n.get('rotation', [0, 0, 0, 1])
    s = n.get('scale', [1, 1, 1])
    t = n.get('translation', [0, 0, 0])
    x, y, z, w = q
    R = [1 - 2 * (y * y + z * z), 2 * (x * y + z * w), 2 * (x * z - y * w),
         2 * (x * y - z * w), 1 - 2 * (x * x + z * z), 2 * (y * z + x * w),
         2 * (x * z + y * w), 2 * (y * z - x * w), 1 - 2 * (x * x + y * y)]
    Rc = [R[0], R[3], R[6], 0,
          R[1], R[4], R[7], 0,
          R[2], R[5], R[8], 0,
          0, 0, 0, 1]
    S = [s[0], 0, 0, 0, 0, s[1], 0, 0, 0, 0, s[2], 0, 0, 0, 0, 1]
    T = ident()
    T[12], T[13], T[14] = t[0], t[1], t[2]
    return mul(T, mul(Rc, S))


def aplicar(m, p):
    x, y, z = p
    return (m[0] * x + m[4] * y + m[8] * z + m[12],
            m[1] * x + m[5] * y + m[9] * z + m[13],
            m[2] * x + m[6] * y + m[10] * z + m[14])


def walk(doc, i, parent, out):
    n = doc['nodes'][i]
    m = mul(parent, trs(n))
    if 'mesh' in n:
        for prim in doc['meshes'][n['mesh']]['primitives']:
            acc = doc['accessors'][prim['attributes']['POSITION']]
            bv = doc['bufferViews'][acc['bufferView']]
            start = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
            stride = bv.get('byteStride') or 12
            out.append((n.get('name', '?'), m, start, acc['count'], stride))
    for hijo in n.get('children', []):
        walk(doc, hijo, m, out)


def analizar(path, variante):
    """Devuelve (checks, datos). checks = [(nombre, ok, detalle), ...]."""
    checks = []

    def chk(nombre, ok, detalle):
        checks.append((nombre, bool(ok), detalle))

    if not os.path.isfile(path):
        for i in range(1, 13):
            chk('C%d' % i, False, 'archivo ausente: %s' % path)
        return checks, {}

    raw = open(path, 'rb').read()
    try:
        magia = raw[:4] == b'glTF'
        version = struct.unpack_from('<I', raw, 4)[0]
        total = struct.unpack_from('<I', raw, 8)[0]
        jlen = struct.unpack_from('<I', raw, 12)[0]
        jtipo = struct.unpack_from('<I', raw, 16)[0]
        off = 20 + jlen
        blen = struct.unpack_from('<I', raw, off)[0]
        btipo = struct.unpack_from('<I', raw, off + 4)[0]
        estructura = (magia and version == 2 and total == len(raw)
                      and jtipo == 0x4E4F534A and btipo == 0x004E4942
                      and len(raw) == off + 8 + blen)
        doc = json.loads(raw[20:20 + jlen].decode('utf8'))
        bin_ = raw[off + 8:off + 8 + blen]
    except (struct.error, UnicodeDecodeError, ValueError, KeyError, IndexError) as e:
        for i in range(1, 13):
            chk('C%d' % i, False, 'GLB ilegible: %s' % e)
        return checks, {}

    chk('C1', estructura, 'glTF v2, chunks coherentes, %d bytes' % len(raw))
    if not estructura:
        for i in range(2, 13):
            chk('C%d' % i, False, 'estructura invalida')
        return checks, {}

    nombres = sorted(n.get('name', '?') for n in doc['nodes'] if 'mesh' in n)
    chk('C2', len(nombres) >= 14 and all(n.startswith('SM_') for n in nombres),
        '%d nodos de malla, todos SM_' % len(nombres))
    prohibidos = [n for n in nombres if any(s in n for s in PROHIBIDOS)]
    chk('C3', not prohibidos, 'set de captura: %s' % (prohibidos or 'NINGUNO'))

    for nodo, etiqueta in NODOS_IDENTIDAD:
        chk(etiqueta, nodo in nombres, '%s presente' % nodo)
    chk('C8', 'SM_Techo_Izq' in nombres and 'SM_Techo_Der' in nombres,
        'techo a dos aguas en dos mitades')
    chk('C9', 'SM_Portico' in nombres and 'SM_Valla_Patio' in nombres,
        'portico + patio cozy')

    prims = []
    for esc in doc['scenes']:
        for raiz in esc.get('nodes', []):
            walk(doc, raiz, ident(), prims)
    puntos = []
    for nombre, m, start, cuenta, stride in prims:
        # OJO: evaluar el generador ACA (extend), no guardarlo para despues.
        # Un generador con late binding reutiliza start/count de la ultima
        # primitiva y lee fuera del BIN (fallo real medido el 2026-11-07).
        for k in range(cuenta):
            puntos.append(aplicar(m, struct.unpack_from('<fff', bin_, start + k * stride)))
    y_min = min(p[1] for p in puntos)
    y_max = max(p[1] for p in puntos)
    chk('C10', len(puntos) > 1000 and abs(y_min - 0.045) < 1e-3,
        '%d vertices, y_min=%.4f (apoyado)' % (len(puntos), y_min))
    chk('C11', y_max >= 3.55,
        'cumbrera y_max=%.4f (el techo viaja al LOD)' % y_max)
    mats = len(doc.get('materials', []))
    chk('C12', mats == MATS_ESPERADOS[variante],
        'materiales=%d, esperado=%d' % (mats, MATS_ESPERADOS[variante]))

    datos = {'bytes': len(raw), 'nodos': nombres, 'vertices': len(puntos),
             'y_min': y_min, 'y_max': y_max, 'materiales': mats}
    return checks, datos


def main(argv):
    args = [a for a in argv if a != '--']
    if len(args) > 3:
        args = args[:3]
    variantes = ('alta', 'media', 'baja')
    todos = []
    for i, path in enumerate(args):
        checks, datos = analizar(path, variantes[i])
        todos.extend(checks)
        print('BLOQUE %s (%s): %d checks, %d fallos' %
              (variantes[i], os.path.basename(path), len(checks),
               sum(1 for _, ok, _ in checks if not ok)))
        for nombre, ok, detalle in checks:
            if not ok:
                print('  FAIL %-4s %s: %s' % (nombre, os.path.basename(path), detalle))
        if datos:
            print('  y=[%.4f, %.4f] verts=%d mats=%d nodos=%d' %
                  (datos['y_min'], datos['y_max'], datos['vertices'],
                   datos['materiales'], len(datos['nodos'])))

    pasados = sum(1 for _, ok, _ in todos if ok)
    fallos = len(todos) - pasados
    bloques = len(args)
    print('CHECKS=%d PASADOS=%d FALLOS=%d BLOQUES=%d PISO=%d' %
          (len(todos), pasados, fallos, bloques, CHECKS_MINIMOS))

    if bloques < 3 or len(todos) < CHECKS_MINIMOS:
        print('CIEGO: faltan bloques por ejecutar (no se hereda ningun verde)')
        return 3
    if fallos:
        print('ROJO: la guardia detecto los defectos inyectados')
        return 1
    print('VERDE: 3 GLB con evidencia positiva de geometria e identidad')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
