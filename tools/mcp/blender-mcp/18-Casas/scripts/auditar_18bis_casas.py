#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Auditoria MEDIDA del legado `18-BIS-Casas-Grandes` (autor: MiMo, flota baja).

NO es QA §21.8, NO es sello, NO aprueba assets. Este programa tiene una sola
funcion: impedir que el inventario de los GLB heredados sea un informe CIEGO.

Dos capas, deliberadamente separadas:

  * CHECKS (guardia): por cada GLB se ejecutan 8 aserciones POSITIVAS sobre
    el binario real (estructura, alcanzabilidad de nodos, identidad SM_,
    vertices decodificados del BIN, y_min finito, geometria no degenerada,
    triangulos contados, materiales). Su VERDE solo significa "medi de
    verdad los 13 GLB"; NO significa "los assets estan bien".
  * HALLAZGOS (datos): presupuesto M166, apoyo z=0.045, LOD faltantes y
    presencia en Godot por sha256. Se PUBLICAN, no se cuentan como checks:
    si un asset invalido hiciera fallar la guardia, un arreglo futuro podria
    consagrar el defecto solo para volver al verde.

Uso:
    python auditar_18bis_casas.py                    # VERDE: 13 bloques
    python auditar_18bis_casas.py --piso 0          # medir el piso de checks
    python auditar_18bis_casas.py --inyectar        # ROJO: GLB mutado
    python auditar_18bis_casas.py --solo <glb>      # CIEGO: 1 bloque, exit 3

Trampas evitadas a proposito:
  * glTF es Y-up: la altura es `y`, no `z` (Blender es Z-up).
  * Matrices COLUMN-MAJOR: M[c*4+r], traslacion en M[12..14].
  * No se usan las 8 esquinas del AABB del accessor (inflan la caja con
    nodos rotados): se decodifican los VERTICES REALES del BIN.
  * Alcanzabilidad: un nodo con `mesh` que no cuelga de ninguna raiz de
    escena no se exporta; contarlo seria inflar el inventario.
  * Un check que FALLA sigue contando como EJECUTADO. Si solo se contaran
    los verdes, el ROJO pareceria CIEGO (falso verde).
"""

import glob
import hashlib
import json
import os
import struct
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(AQUI, '..', '..', '..', '..', '..'))
ORIGEN = os.path.join(REPO, 'tools', 'mcp', 'blender-mcp', '18-BIS-Casas-Grandes')
GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
CATALOGO = os.path.join(ORIGEN, 'CATALOGO_CASAS_02_05.json')
TEMP = os.path.join(REPO, 'Temp')

# Presupuesto M166 §3.3 (POST-merge), copiado de chk_asset.py:32-35.
PRESUPUESTO = {
    'ALTA':  {'objetos': 16, 'tris': 6000, 'materiales': 12},
    'MEDIA': {'objetos': 8,  'tris': 1500, 'materiales': 8},
    'BAJA':  {'objetos': 6,  'tris': 700,  'materiales': 4},
}
Z_APOYO = 0.045
CASAS_ESPERADAS = 5
GLB_MINIMOS = 13          # MEDIDO el 2026-11-07 en el arbol vivo
CHECKS_MINIMOS = 104      # MEDIDO en verde forzando --piso 0 (13 x 8)


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


def raices(doc):
    out = []
    for esc in doc.get('scenes', []):
        out.extend(esc.get('nodes', []))
    return out


def recorrer(doc, i, padre, visitados, prims):
    if i in visitados:
        return
    visitados.add(i)
    n = doc['nodes'][i]
    m = mul(padre, trs(n))
    if 'mesh' in n:
        prims.append((n, m, doc['meshes'][n['mesh']]['primitives']))
    for hijo in n.get('children', []):
        recorrer(doc, hijo, m, visitados, prims)


def sha256(path):
    return hashlib.sha256(open(path, 'rb').read()).hexdigest()


def analizar(path, piso):
    """Devuelve (checks, datos). checks = [(nombre, ok, detalle), ...]."""
    checks = []

    def chk(nombre, ok, detalle):
        checks.append((nombre, bool(ok), detalle))

    datos = {'path': path, 'sha': sha256(path) if os.path.isfile(path) else ''}
    if not os.path.isfile(path):
        for i in range(1, 9):
            chk('C%d' % i, False, 'archivo ausente')
        return checks, datos

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
        for i in range(1, 9):
            chk('C%d' % i, False, 'GLB ilegible: %s' % e)
        return checks, datos

    chk('C1', estructura,
        'glTF v2, chunks coherentes, %d bytes' % len(raw))
    if not estructura:
        for i in range(2, 9):
            chk('C%d' % i, False, 'estructura invalida')
        return checks, datos

    todos_mallas = {i for i, n in enumerate(doc.get('nodes', [])) if 'mesh' in n}
    visitados, prims = set(), []
    for raiz in raices(doc):
        recorrer(doc, raiz, ident(), visitados, prims)
    alcanzables = visitados & todos_mallas
    chk('C2', todos_mallas and alcanzables == todos_mallas,
        '%d/%d nodos de malla alcanzables desde escena' %
        (len(alcanzables), len(todos_mallas)))

    nombres = [n.get('name', '?') for n, _, _ in prims]
    chk('C3', nombres and all(n.startswith('SM_') for n in nombres),
        '%d nodos, identidad SM_=%s' %
        (len(nombres), all(n.startswith('SM_') for n in nombres)))

    puntos, tris = [], 0
    for n, m, primitivas in prims:
        for prim in primitivas:
            acc = doc['accessors'][prim['attributes']['POSITION']]
            bv = doc['bufferViews'][acc['bufferView']]
            start = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
            stride = bv.get('byteStride') or 12
            for k in range(acc['count']):
                puntos.append(aplicar(m, struct.unpack_from('<fff', bin_, start + k * stride)))
            if 'indices' in prim:
                tris += doc['accessors'][prim['indices']]['count'] // 3
            else:
                tris += acc['count'] // 3

    chk('C4', len(puntos) > 100,
        '%d vertices REALES decodificados del BIN' % len(puntos))
    y_min = min((p[1] for p in puntos), default=float('nan'))
    y_max = max((p[1] for p in puntos), default=float('nan'))
    finito = (y_min == y_min and y_max == y_max)
    chk('C5', finito and -1.0 < y_min < 1.0,
        'y_min=%.4f (Y-up) finito y fisico' % y_min if finito else 'y_min no finito')
    chk('C6', finito and y_max > y_min + 0.5,
        'y=[%.4f, %.4f] no degenerado' % (y_min, y_max))
    chk('C7', tris > 0, '%d triangulos contados por accessor' % tris)
    mats = len(doc.get('materials', []))
    chk('C8', mats > 0, '%d materiales declarados' % mats)

    datos.update({'bytes': len(raw), 'nodos': nombres, 'vertices': len(puntos),
                  'y_min': y_min, 'y_max': y_max, 'tris': tris,
                  'objetos': len(nombres), 'materiales': mats})
    return checks, datos


def inyectar(src, dst):
    """Mutacion REAL y reproducible: renombra un nodo SM_ -> BASURA_."""
    raw = open(src, 'rb').read()
    jlen = struct.unpack_from('<I', raw, 12)[0]
    doc = json.loads(raw[20:20 + jlen].decode('utf8'))
    for n in doc['nodes']:
        if 'mesh' in n:
            n['name'] = 'BASURA_' + n.get('name', '?')
            break
    j = json.dumps(doc, separators=(',', ':')).encode('utf8')
    j += b' ' * ((4 - len(j) % 4) % 4)
    off = 20 + jlen
    blen = struct.unpack_from('<I', raw, off)[0]
    bin_ = raw[off + 8:off + 8 + blen]
    bchunk = struct.pack('<II', blen, 0x004E4942) + bin_
    total = 12 + 8 + len(j) + len(bchunk)
    out = (struct.pack('<4sII', b'glTF', 2, total)
           + struct.pack('<II', len(j), 0x4E4F534A) + j + bchunk)
    if not os.path.isdir(TEMP):
        os.makedirs(TEMP)
    open(dst, 'wb').write(out)
    return dst


def main(argv):
    piso = CHECKS_MINIMOS
    solo, inyectar_rojo = None, False
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == '--piso':
            i += 1
            piso = int(argv[i])
        elif a == '--solo':
            i += 1
            solo = argv[i]
        elif a == '--inyectar':
            inyectar_rojo = True
        elif a != '--':
            solo = a
        i += 1

    if solo:
        paths = [solo]
    else:
        paths = sorted(glob.glob(os.path.join(ORIGEN, 'CASA_*', '*', 'SM_*.glb')))
        paths = [p for p in paths if os.path.isfile(p)]

    # El GLB inyectado vive en Temp/, pero su etiqueta debe seguir siendo la
    # de la casa de origen: si no, el informe inventa una 6.a casa y el
    # conteo de CASAS deja de ser una medida confiable.
    alias = {}
    if inyectar_rojo:
        original = paths[-1]
        dst = os.path.join(TEMP, 'hy4_18bis_rojo_20261107.glb')
        inyectar(original, dst)
        paths[-1] = dst
        alias[dst] = original

    hashes_godot = {}
    for lod in ('alta', 'media', 'baja'):
        for p in glob.glob(os.path.join(GODOT, lod, '*.glb')):
            hashes_godot.setdefault(sha256(p), []).append(
                os.path.relpath(p, REPO).replace('\\', '/'))

    todos, datos = [], []
    for path in paths:
        checks, d = analizar(path, piso)
        d['origen'] = alias.get(path, path)
        todos.extend(checks)
        datos.append(d)
        etiqueta = os.path.basename(os.path.dirname(os.path.dirname(d['origen'])))
        lod = os.path.basename(os.path.dirname(d['origen']))
        print('BLOQUE %-20s %-5s %2d checks / %d fallos' %
              (etiqueta, lod, len(checks), sum(1 for _, ok, _ in checks if not ok)))
        for nombre, ok, detalle in checks:
            if not ok:
                print('   FAIL %-3s %s' % (nombre, detalle))

    print()
    print('=== HALLAZGOS (DATOS, no checks) ===')
    casas = {}
    for d in datos:
        etiqueta = os.path.basename(os.path.dirname(os.path.dirname(d['origen'])))
        lod = os.path.basename(os.path.dirname(d['origen']))
        casas.setdefault(etiqueta, set()).add(lod)
        if not d.get('tris'):
            print('%-20s %-5s SIN MEDICION (GLB ilegible)' % (etiqueta, lod))
            continue
        p = PRESUPUESTO.get(lod, PRESUPUESTO['ALTA'])
        excede = []
        if d['tris'] > p['tris']:
            excede.append('tris %d>%d' % (d['tris'], p['tris']))
        if d['materiales'] > p['materiales']:
            excede.append('mats %d>%d' % (d['materiales'], p['materiales']))
        if d['objetos'] > p['objetos']:
            # La excepcion §6.1 esta documentada para los generadores
            # canonicos de 18-Casas; NO esta confirmada para el set 18-BIS.
            excede.append('obj %d>%d' % (d['objetos'], p['objetos']))
        apoyo = 'OK' if abs(d['y_min'] - Z_APOYO) < 1e-3 else 'DEFECTO y_min=%.4f' % d['y_min']
        en_godot = ','.join(hashes_godot.get(d['sha'], [])) or 'AUSENTE'
        print('%-20s %-5s tris=%-5d mats=%-2d obj=%-2d y=[%.4f,%.4f] presupuesto=%-11s apoyo=%-22s godot=%s' %
              (etiqueta, lod, d['tris'], d['materiales'], d['objetos'],
               d['y_min'], d['y_max'], ','.join(excede) or 'OK', apoyo, en_godot))

    print()
    print('=== LOD ===')
    for casa in sorted(casas):
        falta = sorted({'ALTA', 'MEDIA', 'BAJA'} - casas[casa])
        print('%-20s %s' % (casa, 'COMPLETO' if not falta else 'FALTA ' + ','.join(falta)))

    # Deriva de cumbrera: el apoyo puede estar bien y el techo NO viajar igual.
    # El catalogo de MiMo solo miraba el apoyo; esta es la medicion que falta.
    print()
    print('=== DERIVA DE CUMBRERA (y_max del LOD vs ALTA) ===')
    por_casa = {}
    for d in datos:
        if not d.get('tris'):
            continue
        casa = os.path.basename(os.path.dirname(os.path.dirname(d['origen'])))
        lod = os.path.basename(os.path.dirname(d['origen']))
        por_casa.setdefault(casa, {})[lod] = d['y_max']
    for casa in sorted(por_casa):
        alta = por_casa[casa].get('ALTA')
        if alta is None:
            print('%-20s SIN ALTA: no se puede comparar' % casa)
            continue
        for lod in ('MEDIA', 'BAJA'):
            if lod not in por_casa[casa]:
                continue
            delta = por_casa[casa][lod] - alta
            print('%-20s %-5s delta=%+.4f m  %s' %
                  (casa, lod, delta, 'DERIVA' if abs(delta) > 0.01 else 'ok'))

    if os.path.isfile(CATALOGO):
        print()
        print('=== CATALOGO DE MiMo vs MEDICION REAL ===')
        cat = json.load(open(CATALOGO, encoding='utf-8'))
        medido = {}
        for d in datos:
            if d.get('tris'):
                medido[(os.path.basename(os.path.dirname(os.path.dirname(d['origen']))),
                        os.path.basename(os.path.dirname(d['origen'])))] = d
        for e in cat.get('errores', []):
            k = ('CASA_%02d_' % e['id'], 'ALTA')
            real = next((v for key, v in medido.items()
                         if key[0].startswith(k[0]) and key[1] == 'ALTA'), None)
            print('%-20s catalogo=%-55s medido=%s' %
                  (e['nombre'], e['error'][:55],
                   ('%d tris' % real['tris']) if real else 'SIN GLB'))
        for e in cat.get('correctos', []):
            for err in e.get('errores_lod', []):
                real = next((v for key, v in medido.items()
                             if key[0].startswith('CASA_%02d_' % e['id'])
                             and key[1] == err['nivel']), None)
                print('%-20s catalogo=%-55s medido=%s' %
                      (e['nombre'] + '/' + err['nivel'], err['error'][:55],
                       ('y_min=%.4f' % real['y_min']) if real else 'SIN GLB'))

    pasados = sum(1 for _, ok, _ in todos if ok)
    fallos = len(todos) - pasados
    bloques = len(paths)
    casas_vistas = len(casas)
    print()
    print('CHECKS=%d PASADOS=%d FALLOS=%d BLOQUES=%d CASAS=%d PISO=%d' %
          (len(todos), pasados, fallos, bloques, casas_vistas, piso))

    ciego = (bloques < GLB_MINIMOS or casas_vistas < CASAS_ESPERADAS
             or len(todos) < piso)
    if ciego:
        print('CIEGO: faltan bloques/casas por medir (no se hereda ningun verde)')
        return 3
    if fallos:
        print('ROJO: la guardia detecto el GLB mutado')
        return 1
    print('VERDE: inventario MEDIDO sobre vertices reales; los hallazgos de calidad siguen abiertos')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
