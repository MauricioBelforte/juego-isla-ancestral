#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Guardia POSITIVA sobre el BIN de los 6 GLB que quedaban SIN verificar:
`33-Agricultura_cultivo_brote.glb` (Semillero) y
`70-Interacciones_palanca_madera.glb` (Palanca), 3 LOD cada uno. B30.

NO es QA seccion 21.8 ni sello: es una guardia de AUTORIA/REGRESION sobre
EL ARTEFACTO QUE GODOT CONSUME. chk_asset.py mide COSTE, no FORMA, y un
verde del .blend NO se hereda al GLB (B12/B13). Decodifica VERTICES REALES
del BIN y aplica las matrices COLUMN-MAJOR de los nodos (glTF Y-up:
p[0]=X, p[1]=ALTURA, p[2]=LATERAL).

HUECO QUE CIERRA: B27 (log 2412) y B28 (log 2414) y B29 (log 2419)
publicaron repetidamente que estas DOS guardias faltaban. Los 6 GLB
estan trackeados desde 2026-11-05 (logs 2320/233, acta 11, COBJ L182
para la palanca) pero NUNCA se verificaron por dentro: 0 archivos
*verificar*cultivo* / *verificar*palanca* / *verificar*semillero* en
todo el repo (medido 2026-11-14).

DECISION DE AUTORIA: UNA guardia con DOS perfiles (6 bloques) en vez de
dos archivos duplicando ~130 lineas de decoder. Es el mismo patron de B27
(una guardia / 6 GLB / 2 variantes, 114 checks). Se publica en el canal 81.

COTAS: TODAS medidas en el BIN por Temp/hy4_b27_glb_probe_20261113.py
(2026-11-13) y re-verificadas en B30. No se estimo ninguna.

Trampas evitadas: POSITION real + matrices COLUMN-MAJOR + Y-up, inversa
GENERAL 3x3 (Cramer) para inyectar, un check que FALLA sigue contando
como EJECUTADO, CIEGO = menos bloques/checks que el verde medido (exit 3),
ROJO sobre COPIA en Temp/ con los GLB publicados intactos.

Uso:
  python verificar_pendientes_M33_M70.py             # VERDE (6 GLB)
  python verificar_pendientes_M33_M70.py --piso 0    # mide el piso en verde
  python verificar_pendientes_M33_M70.py --inyectar  # ROJO
  python verificar_pendientes_M33_M70.py --solo <glb>  # CIEGO (exit 3)
"""
import hashlib
import json
import os
import struct
import sys

REPO = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
TEMP = os.path.join(REPO, 'Temp')
LODS = ('alta', 'media', 'baja')
GRUPOS = {
    'cultivo_brote': '33-Agricultura_cultivo_brote.glb',
    'palanca_madera': '70-Interacciones_palanca_madera.glb',
}

# MEDIDO EN VERDE 2026-11-14 con `--piso 0` ANTES de fijar la constante:
#   18 checks x 6 GLB + 6 globales = 114, CHECKS=114 PASADOS=114
#   FALLOS=0 BLOQUES=6 GLOBALES=6 RC=0. Ver acta 40 / log 2420.
CHECKS_MINIMOS = 114
BLOQUES_MINIMOS = 6

Y_APOYO = 0.045
TOL = 0.001

# (tris, mats, mallas, verts, alt_max, x_min, x_max, lat_min, lat_max, apoyo)
# MEDIDO EN EL BIN. Los nodos SM_ se validan aparte por su nombre real.
ESPERADO = {
    'cultivo_brote': {
        'alta':  (152, 3, 4, 252, 0.1998, -0.1400, 0.1400, -0.14, 0.14, 13),
        'media': (152, 3, 3, 252, 0.1998, -0.1400, 0.1400, -0.14, 0.14, 13),
        'baja':  (102, 3, 3, 216, 0.1979, -0.1365, 0.1365, -0.14, 0.14, 10),
    },
    'palanca_madera': {
        'alta':  (516, 3, 1, 1068, 0.6155, -0.5506, 0.6445, -0.17, 0.17, 4),
        'media': (516, 3, 1, 1068, 0.6155, -0.5506, 0.6445, -0.17, 0.17, 4),
        'baja':  (66,  3, 1, 166,  0.6155, -0.5538, 0.6445, -0.17, 0.17, 4),
    },
}
MATS = {
    'cultivo_brote': frozenset(['MAT_Cultivo_Hoja', 'MAT_Cultivo_Tallo',
                                'MAT_Cultivo_Tierra']),
    'palanca_madera': frozenset(['MAT_Hierro_Perno', 'MAT_Madera_Pal_Cla',
                                 'MAT_Madera_Pal_Osc']),
}
NODOS = {
    ('cultivo_brote', 'alta'): frozenset([
        'SM_Cultivo_Hoja_0', 'SM_Cultivo_Hoja_1',
        'SM_Cultivo_Monticulo', 'SM_Cultivo_Tallo']),
    ('cultivo_brote', 'media'): frozenset([
        'SM_Cultivo_M_Cultivo_Hoja', 'SM_Cultivo_M_Cultivo_Tallo',
        'SM_Cultivo_M_Cultivo_Tierra']),
    ('cultivo_brote', 'baja'): frozenset([
        'SM_Cultivo_M_Cultivo_Hoja', 'SM_Cultivo_M_Cultivo_Tallo',
        'SM_Cultivo_M_Cultivo_Tierra']),
    ('palanca_madera', 'alta'): frozenset(['SM_Palanca_Madera']),
    ('palanca_madera', 'media'): frozenset([
        'SM_Palanca_M_Madera_Pal_Osc_Madera_Pal_Cla_Hierro_Perno']),
    ('palanca_madera', 'baja'): frozenset([
        'SM_Palanca_M_Madera_Pal_Osc_Madera_Pal_Cla_Hierro_Perno']),
}


# ------------------------------------------------------------------ glTF ----
def ident():
    return [1., 0., 0., 0.,
            0., 1., 0., 0.,
            0., 0., 1., 0.,
            0., 0., 0., 1.]


def mul(a, b):
    out = [0.] * 16
    for c in range(4):
        for r in range(4):
            out[c * 4 + r] = sum(a[k * 4 + r] * b[c * 4 + k] for k in range(4))
    return out


def trs(n):
    if 'matrix' in n:
        return list(n['matrix'])
    t = n.get('translation', [0., 0., 0.])
    r = n.get('rotation', [0., 0., 0., 1.])
    s = n.get('scale', [1., 1., 1.])
    x, y, z, w = r
    m = [1 - 2 * (y * y + z * z), 2 * (x * y + z * w), 2 * (x * z - y * w), 0.,
         2 * (x * y - z * w), 1 - 2 * (x * x + z * z), 2 * (y * z + x * w), 0.,
         2 * (x * z + y * w), 2 * (y * z - x * w), 1 - 2 * (x * x + y * y), 0.,
         0., 0., 0., 1.]
    for c in range(3):
        for k in range(3):
            m[c * 4 + k] *= s[c]
    m[12], m[13], m[14] = t
    return m


def aplicar(m, p):
    x, y, z = p
    return (m[0] * x + m[4] * y + m[8] * z + m[12],
            m[1] * x + m[5] * y + m[9] * z + m[13],
            m[2] * x + m[6] * y + m[10] * z + m[14])


def desaplicar(m, w):
    """Inversa GENERAL de la parte lineal 3x3 + traslacion (Cramer)."""
    a = ((m[0], m[4], m[8]),
         (m[1], m[5], m[9]),
         (m[2], m[6], m[10]))
    b = (w[0] - m[12], w[1] - m[13], w[2] - m[14])
    det = (a[0][0] * (a[1][1] * a[2][2] - a[1][2] * a[2][1])
           - a[0][1] * (a[1][0] * a[2][2] - a[1][2] * a[2][0])
           + a[0][2] * (a[1][0] * a[2][1] - a[1][1] * a[2][0]))
    if abs(det) < 1e-12:
        raise RuntimeError('matriz singular: no se puede invertir el nodo')
    out = []
    for c in range(3):
        ac = [list(fila) for fila in a]
        for r in range(3):
            ac[r][c] = b[r]
        dc = (ac[0][0] * (ac[1][1] * ac[2][2] - ac[1][2] * ac[2][1])
              - ac[0][1] * (ac[1][0] * ac[2][2] - ac[1][2] * ac[2][0])
              + ac[0][2] * (ac[1][0] * ac[2][1] - ac[1][1] * ac[2][0]))
        out.append(dc / det)
    return tuple(out)


def raices(doc):
    out = []
    for esc in doc.get('scenes', []):
        out.extend(esc.get('nodes', []))
    if not out and doc.get('nodes'):
        out = [0]
    return out


def recorrer(doc):
    nodes = doc.get('nodes', [])
    alcanzables, instancias = set(), []
    pila = [(i, ident()) for i in raices(doc)]
    while pila:
        i, padre = pila.pop()
        if i in alcanzables or i < 0 or i >= len(nodes):
            continue
        alcanzables.add(i)
        n = nodes[i]
        m = mul(padre, trs(n))
        if 'mesh' in n:
            instancias.append((n['mesh'], m, n.get('name', '')))
        for hijo in n.get('children', []):
            pila.append((hijo, m))
    return alcanzables, instancias


def leer_vec(doc, bin_, acc_i, fmt, ncomp):
    try:
        acc = doc['accessors'][acc_i]
        bv = doc['bufferViews'][acc['bufferView']]
        unidad = struct.calcsize('<' + fmt * ncomp)
        stride = bv.get('byteStride') or unidad
        base = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
        fin = base + (acc['count'] - 1) * stride + unidad
        if base < 0 or fin > len(bin_):
            return [], 'rango'
        return [struct.unpack_from('<' + fmt * ncomp, bin_, base + k * stride)
                for k in range(acc['count'])], None
    except (KeyError, IndexError, struct.error, ValueError) as e:
        return [], type(e).__name__


def cargar(path):
    raw = open(path, 'rb').read()
    if len(raw) < 20 or raw[:4] != b'glTF':
        return raw, None, b'', False
    version, total = struct.unpack_from('<II', raw, 4)
    jlen, jtipo = struct.unpack_from('<II', raw, 12)
    estructura = (version == 2 and jtipo == 0x4E4F534A and total == len(raw))
    if not estructura:
        return raw, None, b'', False
    try:
        doc = json.loads(raw[20:20 + jlen].decode('utf-8'))
    except (UnicodeDecodeError, ValueError):
        return raw, None, b'', False
    off = 20 + jlen
    blen, btipo = struct.unpack_from('<II', raw, off)
    estructura = (btipo == 0x004E4942 and len(raw) == off + 8 + blen
                  and blen > 0)
    bin_ = bytearray(raw[off + 8:off + 8 + blen])
    return raw, doc, bin_, estructura


def sha12(path):
    return hashlib.sha256(open(path, 'rb').read()).hexdigest()[:12]


# --------------------------------------------------------------- geometria ----
def medir(path):
    """Devuelve (datos, error). Decodifica POSITION real de TODAS las mallas."""
    raw, doc, bin_, ok = cargar(path)
    if not ok or doc is None:
        return None, 'GLB ilegible'
    claves = all(k in doc for k in ('meshes', 'nodes', 'accessors', 'bufferViews'))
    if not claves:
        return None, 'estructura glTF incompleta'
    alcanzables, instancias = recorrer(doc)
    puntos, nombres = [], set()
    tris = 0
    errores = []
    for mi, m, nombre in instancias:
        if nombre.startswith('SM_'):
            nombres.add(nombre)
        for pr in doc['meshes'][mi].get('primitives', []):
            pos, e = leer_vec(doc, bin_, pr['attributes']['POSITION'], 'f', 3)
            if e or not pos:
                errores.append(e or 'vacio')
                continue
            ai = pr.get('indices')
            count = len(pos) if ai is None else doc['accessors'][ai]['count']
            tris += count // 3
            for q in pos:
                puntos.append(aplicar(m, q))
    if not puntos:
        return None, 'sin POSITION: %s' % errores[:2]
    xs = [p[0] for p in puntos]
    alt = [p[1] for p in puntos]
    lat = [p[2] for p in puntos]
    apoyo = {(round(p[0], 4), round(p[2], 4)) for p in puntos
             if abs(p[1] - Y_APOYO) <= 1e-3}
    return {
        'bytes': len(raw), 'tris': tris,
        'mats': len(doc.get('materials', [])),
        'nombres_mats': frozenset(m.get('name', '')
                                  for m in doc.get('materials', [])),
        'mallas': len(doc['meshes']), 'nodos': len(alcanzables),
        'verts': len(puntos), 'nombres_sm': frozenset(nombres),
        'alt_min': min(alt), 'alt_max': max(alt),
        'x_min': min(xs), 'x_max': max(xs),
        'lat_min': min(lat), 'lat_max': max(lat),
        'apoyo': len(apoyo),
        'niveles_alt': frozenset(round(v, 4) for v in alt),
        'errores': errores,
        'sha': sha12(path),
        'doc': doc, 'bin': bin_, 'instancias': instancias,
    }, None


def analizar(path, grupo, lod):
    """Publica SIEMPRE 18 checks por GLB, incluso si el archivo falta."""
    N = 18
    checks, d = [], {'path': path, 'grupo': grupo, 'lod': lod}

    def chk(codigo, ok, detalle):
        checks.append((codigo, bool(ok), detalle))

    def falta(desde, motivo):
        for i in range(desde, N + 1):
            chk('C%d' % i, False, motivo)

    if not os.path.isfile(path):
        falta(1, 'archivo ausente')
        return checks, d

    m, err = medir(path)
    e = ESPERADO[grupo][lod]
    chk('C1', err is None, 'glTF v2 + BIN coherente (%s)' % (err or 'OK'))
    if err:
        falta(2, err)
        return checks, d

    d.update({k: m[k] for k in ('tris', 'mats', 'mallas', 'verts', 'alt_max',
                                'apoyo', 'nombres_mats', 'sha')})
    chk('C2', not m['errores'], 'POSITION legible en todas las primitivas')
    chk('C3', m['nodos'] > 0, 'nodos alcanzables=%d' % m['nodos'])
    chk('C4', m['verts'] > 0, 'vertices decodificados=%d' % m['verts'])
    chk('C5', m['tris'] == e[0], 'tris=%d (esperado %d)' % (m['tris'], e[0]))
    chk('C6', m['mats'] == e[1], 'materiales=%d (esperado %d)'
        % (m['mats'], e[1]))
    chk('C7', m['nombres_mats'] == MATS[grupo],
        'nombres_materiales=%d %s' % (len(m['nombres_mats']),
                                      sorted(m['nombres_mats'])))
    chk('C8', m['mallas'] == e[2], 'mallas=%d (esperado %d)'
        % (m['mallas'], e[2]))
    chk('C9', m['verts'] == e[3], 'vertices=%d (esperado %d)'
        % (m['verts'], e[3]))
    chk('C10', abs(m['alt_min'] - Y_APOYO) <= TOL,
        'alt_min=%.4f (Z_APOYO=%.4f)' % (m['alt_min'], Y_APOYO))
    chk('C11', abs(m['alt_max'] - e[4]) <= TOL,
        'alt_max=%.4f (esperado %.4f)' % (m['alt_max'], e[4]))
    chk('C12', abs(m['x_min'] - e[5]) <= TOL and abs(m['x_max'] - e[6]) <= TOL,
        'x=[%.4f..%.4f] (esperado [%.4f..%.4f])'
        % (m['x_min'], m['x_max'], e[5], e[6]))
    chk('C13', abs(m['lat_min'] - e[7]) <= TOL
        and abs(m['lat_max'] - e[8]) <= TOL,
        'lat=[%.4f..%.4f] (esperado [%.4f..%.4f])'
        % (m['lat_min'], m['lat_max'], e[7], e[8]))
    chk('C14', m['apoyo'] == e[9], 'pares_apoyo=%d (esperado %d)'
        % (m['apoyo'], e[9]))
    chk('C15', m['nombres_sm'] == NODOS[(grupo, lod)],
        'nodos SM_=%d (esperado %d) %s'
        % (len(m['nombres_sm']), len(NODOS[(grupo, lod)]),
           sorted(m['nombres_sm'])[:2]))
    clave = Y_APOYO in m['niveles_alt'] and any(
        abs(n - e[4]) <= TOL for n in m['niveles_alt'])
    chk('C16', clave, 'niveles clave: apoyo 0.045 y tope %.4f presentes'
        % e[4])
    if grupo == 'cultivo_brote':
        silueta = (any('Hoja' in n for n in m['nombres_sm'])
                   and any(('Tallo' in n or 'Tierra' in n)
                           for n in m['nombres_sm']))
        det = 'brote: Hoja + Tallo/Tierra presentes'
    else:
        silueta = (m['x_max'] - m['x_min'] > 1.0
                   and m['alt_max'] > 0.5)
        det = 'palanca: brazo x=%.4f y altura=%.4f' % (
            m['x_max'] - m['x_min'], m['alt_max'])
    chk('C17', silueta, det)
    Alta = ESPERADO[grupo]['alta']
    chk('C18', m['tris'] <= Alta[0] and m['mallas'] <= Alta[2],
        'LOD real: tris=%d<=%d mallas=%d<=%d (ALTA)'
        % (m['tris'], Alta[0], m['mallas'], Alta[2]))
    return checks, d


def inyectar(src, dst):
    """Mueve +0.0133 m en ALTURA todos los vertices, EN UNA COPIA.

    Reproduce la familia de defectos de B18/B29 (DECIMATE que desplaza
    vertices fuera de los planos autorizados). El GLB publicado NO se toca.
    """
    raw, doc, bin_, ok = cargar(src)
    assert ok, 'GLB ilegible para inyectar'
    _, instancias = recorrer(doc)
    cambiados = 0
    for mi, m, _nombre in instancias:
        for pr in doc['meshes'][mi].get('primitives', []):
            ai = pr['attributes']['POSITION']
            acc = doc['accessors'][ai]
            bv = doc['bufferViews'][acc['bufferView']]
            unidad = struct.calcsize('<fff')
            stride = bv.get('byteStride') or unidad
            base = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
            for k in range(acc['count']):
                off = base + k * stride
                q = struct.unpack_from('<fff', bin_, off)
                w = aplicar(m, q)
                nuevo = desaplicar(m, (w[0], w[1] + 0.0133, w[2]))
                struct.pack_into('<fff', bin_, off, *nuevo)
                cambiados += 1
    jlen = struct.unpack_from('<I', raw, 12)[0]
    off = 20 + jlen
    blen = struct.unpack_from('<I', raw, off)[0]
    salida = bytearray(raw[:off + 8]) + bin_
    assert len(salida) == len(raw), 'la inyeccion cambio el tamanio del GLB'
    os.makedirs(TEMP, exist_ok=True)
    with open(dst, 'wb') as f:
        f.write(salida)
    return cambiados


# -------------------------------------------------------------------- main ----
def main(argv):
    piso = CHECKS_MINIMOS
    solo, rojo = None, False
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
            rojo = True
        i += 1

    rutas = []
    for grupo, base in GRUPOS.items():
        for lod in LODS:
            rutas.append((grupo, lod, os.path.join(GODOT, lod, base)))

    if solo:
        nombre = os.path.basename(solo)
        grupo = next((g for g, b in GRUPOS.items() if nombre == b),
                     'cultivo_brote')
        lod = os.path.basename(os.path.dirname(solo)).lower()
        rutas = [(grupo, lod, solo)]

    if rojo:
        src = rutas[-1][2]
        publicado = sha12(src)
        dst = os.path.join(TEMP, 'hy4_b30_rojo_20261114.glb')
        cambiados = inyectar(src, dst)
        assert sha12(src) == publicado, 'la inyeccion toco el GLB publicado'
        print('INYECCION: %d vertices +0.0133 m en %s | publicado sha=%s '
              'INTACTO' % (cambiados, os.path.relpath(dst, REPO), publicado))
        rutas[-1] = (rutas[-1][0], rutas[-1][1], dst)

    ok = fallos = bloques = 0
    datos = {}
    for grupo, lod, ruta in rutas:
        checks, d = analizar(ruta, grupo, lod)
        for codigo, bueno, detalle in checks:
            if bueno:
                ok += 1
            else:
                fallos += 1
            print('%s %-16s %-5s %-3s %s'
                  % ('OK  ' if bueno else 'FAIL', grupo, lod, codigo, detalle))
        bloques += 1
        datos[(grupo, lod)] = d

    # 6 globales POSITIVOS: 3 por grupo. Con --solo no se publica ninguno
    # (publicar un check que no se ejecuto seria cobertura falsa, trampa 46).
    globales = 0
    if not solo:
        for grupo in GRUPOS:
            tops = [datos.get((grupo, l), {}).get('alt_max') for l in LODS]
            mats = [datos.get((grupo, l), {}).get('nombres_mats') for l in LODS]
            tris = [datos.get((grupo, l), {}).get('tris') for l in LODS]
            g = [
                ('G1', tops[0] is not None and all(
                    t is not None and abs(t - tops[0]) <= 0.003 for t in tops),
                 'alt_max consistente en 3 LOD: %s'
                 % [None if t is None else round(t, 4) for t in tops]),
                ('G2', all(x == mats[0] and x for x in mats),
                 'materiales identicos en 3 LOD: %d sets'
                 % len(set(map(str, mats)))),
                ('G3', tris[2] is not None and tris[0] is not None
                 and tris[2] < tris[0],
                 'LOD real: tris BAJA=%s < ALTA=%s' % (tris[2], tris[0])),
            ]
            for codigo, bueno, detalle in g:
                globales += 1
                if bueno:
                    ok += 1
                else:
                    fallos += 1
                print('%s %-16s %-5s %-3s %s'
                      % ('OK  ' if bueno else 'FAIL', grupo, '-----',
                         codigo, detalle))

    # Un check que FALLA sigue siendo EJECUTADO: si se contara solo el
    # verde, el ROJO pareceria CIEGO. CIEGO = bloque que NO corrio.
    total = ok + fallos
    print('CHECKS=%d PASADOS=%d FALLOS=%d BLOQUES=%d GLOBALES=%d PISO=%d'
          % (total, ok, fallos, bloques, globales, piso))
    if total < piso or bloques < BLOQUES_MINIMOS:
        print('CIEGO: faltan bloques o checks respecto del verde medido')
        sys.exit(3)
    if fallos:
        print('ROJO: %d aserciones de forma fallaron' % fallos)
        sys.exit(1)
    print('VERDE: 6 GLB pendientes verificados en %d bloques' % bloques)
    sys.exit(0)


if __name__ == '__main__':
    main(sys.argv[1:])
