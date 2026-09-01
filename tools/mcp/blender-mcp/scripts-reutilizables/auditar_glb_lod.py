#!/usr/bin/env python3
# auditar_glb_lod.py — Audita el artefacto QUE SE ENVIA AL JUEGO, no el .blend.
#
# Por qué existe
# --------------
# `auditar_flotantes.py` mide los `.blend` de autoría. Pero lo que importa en
# Godot es el `.glb`. Este script cierra el círculo:_parsea_ el GLB (binario
# glTF 2.0) sin Blender ni Godot, reconstruye la cota inferior mundial en Y
# (glTF es Y-up; el exportador mapea Blender Z -> glTF Y) y la compara entre
# las tres variantes de LOD.
#
# Dos fallos que detecta y que ningún otro auditor veía:
#
#  1. LOD INCONSISTENTE. Si el GLB alta tiene un min Y distinto al de media o
#     baja, el objeto SALTA de posición al cambiar de nivel de detalle. Caso
#     real (2026-08-30, E-48): `roca_pedernal` alta apoyaba en -0.963 y su
#     media/baja en +0.045 — un salto de UN METRO al acercarse. La causa: las
#     fuentes de autoría nunca se asentaban y `generar_variante.py` sí lo hace
#     (Z_APOYO) al derivar, así que el derivado "corregía" en silencio.
#
#  2. FLOTADO/HUNDIDO EN EL SHIPPED. Que el `.blend` esté bien no garantiza que
#     el GLB lo esté (purgas, transforms, ejes). Se verifica contra Z_APOYO.
#
# Detalle de implementación que importa
# -------------------------------------
# El `min`/`max` de un accessor está en el espacio LOCAL de la malla. Los
# objetos llevan su posición en el nodo. Medir solo el accessor da cualquier
# cosa (incluye además accessors de NORMAL/TEXCOORD, cuyo min[1] es -1 o 0).
# Hay que: filtrar solo POSITION, formar las 8 esquinas del AABB local y
# transformarlas por la matriz mundial del nodo.
#
# Uso:
#   python auditar_glb_lod.py
#   python auditar_glb_lod.py --tolerancia 0.02
#   python auditar_glb_lod.py --modulo 15-Recursos
import sys
import os
import glob
import json
import struct

Z_APOYO = 0.045          # E-12: 5 mm bajo el tope de arena (z=0.05 en Blender)
TOLERANCIA = 0.02        # separación máxima admitida entre LODs
def _encontrar_raiz():
    """Sube desde este script hasta hallar `game/isla-ancestral/assets/3d`.

    Se busca hacia arriba en vez de contar `..` a mano: el script puede moverse
    de carpeta y una cuenta fija de niveles rompe en silencio.
    """
    cur = os.path.dirname(os.path.abspath(__file__))
    while True:
        cand = os.path.join(cur, 'game', 'isla-ancestral', 'assets', '3d')
        if os.path.isdir(cand):
            return cand
        padre = os.path.dirname(cur)
        if padre == cur:
            return cand
        cur = padre


RAIZ = _encontrar_raiz()

argv = sys.argv[1:]
MODULO = None
i = 0
while i < len(argv):
    if argv[i] == '--modulo' and i + 1 < len(argv):
        MODULO = argv[i + 1]
        i += 2
    elif argv[i] == '--tolerancia' and i + 1 < len(argv):
        TOLERANCIA = float(argv[i + 1])
        i += 2
    else:
        i += 1


# ---------------- lectura de GLB ----------------
def leer_glb(path):
    """Devuelve (json, bin) de un .glb (glTF 2.0 binario)."""
    with open(path, 'rb') as fh:
        d = fh.read()
    if len(d) < 20 or d[:4] != b'glTF':
        return None, None
    total = struct.unpack_from('<I', d, 8)[0]
    off = 12
    js = None
    binario = None
    while off + 8 <= min(total, len(d)):
        clen, ctype = struct.unpack_from('<I4s', d, off)
        tipo = ctype.rstrip(b'\x00')
        if tipo == b'JSON':
            js = json.loads(d[off + 8:off + 8 + clen].decode('utf-8'))
        elif tipo == b'BIN\x00' or tipo == b'BIN':
            binario = d[off + 8:off + 8 + clen]
        off += 8 + clen
    return js, binario


# Tamaño y formato struct por componentType de glTF.
_COMP = {
    5120: (1, 'b'),   # BYTE
    5121: (1, 'B'),   # UNSIGNED_BYTE
    5122: (2, 'h'),   # SHORT
    5123: (2, 'H'),   # UNSIGNED_SHORT
    5125: (4, 'I'),   # UNSIGNED_INT
    5126: (4, 'f'),   # FLOAT
}


def posiciones_locales(js, binario, idx_acc):
    """Decodifica las posiciones REALES de un accessor POSITION.

    Devolver None obliga a usar el AABB del accessor. Eso es exacto solo si la
    malla no está rotada: una pieza girada tiene esquinas vacías por debajo de
    la geometría real (E-24) y hunde la medición. Por eso se prefieren siempre
    los vértices reales.
    """
    if binario is None:
        return None
    acc = js['accessors'][idx_acc]
    ctype = acc.get('componentType')
    if ctype not in _COMP or acc.get('type') != 'VEC3':
        return None
    if 'bufferView' not in acc:
        return None
    bv = js['bufferViews'][acc['bufferView']]
    tam, fmt = _COMP[ctype]
    elem = tam * 3
    stride = bv.get('byteStride') or elem
    base = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
    cantidad = acc['count']
    if base + cantidad * stride > len(binario):
        return None
    norm = acc.get('normalized', False)
    out = []
    # Los normalizados (SHORT/USHORT/BYTE) van cuantizados; se desnormalizan.
    div = {5120: 127.0, 5121: 255.0, 5122: 32767.0, 5123: 65535.0}.get(ctype, 1.0)
    for i in range(cantidad):
        off = base + i * stride
        vals = struct.unpack_from('<' + fmt * 3, binario, off)
        if norm:
            vals = tuple(v / div for v in vals)
        out.append(vals)
    return out


# ---------------- álgebra mínima (sin numpy) ----------------
def identidad():
    return [[1.0 if i == j else 0.0 for j in range(4)] for i in range(4)]


def multiplicar(a, b):
    r = [[0.0] * 4 for _ in range(4)]
    for i in range(4):
        for j in range(4):
            s = 0.0
            for k in range(4):
                s += a[i][k] * b[k][j]
            r[i][j] = s
    return r


def desde_trs(nodo):
    t = nodo.get('translation', [0.0, 0.0, 0.0])
    q = nodo.get('rotation', [0.0, 0.0, 0.0, 1.0])
    s = nodo.get('scale', [1.0, 1.0, 1.0])
    x, y, z, w = q
    m = identidad()
    m[0][0] = 1 - 2 * (y * y + z * z)
    m[0][1] = 2 * (x * y - z * w)
    m[0][2] = 2 * (x * z + y * w)
    m[1][0] = 2 * (x * y + z * w)
    m[1][1] = 1 - 2 * (x * x + z * z)
    m[1][2] = 2 * (y * z - x * w)
    m[2][0] = 2 * (x * z - y * w)
    m[2][1] = 2 * (y * z + x * w)
    m[2][2] = 1 - 2 * (x * x + y * y)
    for r in range(3):
        for c in range(3):
            m[r][c] *= s[c]
        m[r][3] = t[r]
    return m


def matriz_nodo(nodo):
    if 'matrix' in nodo:
        m = nodo['matrix']
        # glTF guarda column-major
        return [[m[c * 4 + r] for c in range(4)] for r in range(4)]
    return desde_trs(nodo)


def transformar_punto(m, p):
    return [m[0][0] * p[0] + m[0][1] * p[1] + m[0][2] * p[2] + m[0][3],
            m[1][0] * p[0] + m[1][1] * p[1] + m[1][2] * p[2] + m[1][3],
            m[2][0] * p[0] + m[2][1] * p[1] + m[2][2] * p[2] + m[2][3]]


# ---------------- medición ----------------
def min_y_mundial(path):
    """Cota inferior en Y (vertical en glTF) ya transformada a mundo."""
    js, binario = leer_glb(path)
    if js is None:
        return None
    nodos = js.get('nodes', [])
    acceso = js.get('accessors', [])
    mallas = js.get('meshes', [])
    vertices_cache = {}

    # mundo[i] = producto de las matrices desde la raíz hasta el nodo i
    mundo = [None] * len(nodos)
    padres = {}
    for i, n in enumerate(nodos):
        for h in n.get('children', []):
            padres[h] = i

    def resolver(i):
        if mundo[i] is not None:
            return mundo[i]
        m = matriz_nodo(nodos[i])
        if i in padres:
            m = multiplicar(resolver(padres[i]), m)
        mundo[i] = m
        return m

    mejor = None
    for i, n in enumerate(nodos):
        mi = n.get('mesh')
        if mi is None or mi >= len(mallas):
            continue
        m = resolver(i)
        for prim in mallas[mi].get('primitives', []):
            ai = prim.get('attributes', {}).get('POSITION')
            if ai is None or ai >= len(acceso):
                continue
            acc = acceso[ai]
            if ai not in vertices_cache:
                vertices_cache[ai] = posiciones_locales(js, binario, ai)
            verts = vertices_cache[ai]
            if verts is not None:
                # Camino exacto: vértices reales transformados a mundo.
                for v in verts:
                    y = transformar_punto(m, v)[1]
                    if mejor is None or y < mejor:
                        mejor = y
                continue
            if 'min' not in acc or 'max' not in acc:
                continue
            lo, hi = acc['min'], acc['max']
            # Reserva: 8 esquinas del AABB local -> mundo (inexacto si hay
            # rotación, ver E-24).
            for cx in (lo[0], hi[0]):
                for cy in (lo[1], hi[1]):
                    for cz in (lo[2], hi[2]):
                        y = transformar_punto(m, [cx, cy, cz])[1]
                        if mejor is None or y < mejor:
                            mejor = y
    return mejor


def main():
    if not os.path.isdir(RAIZ):
        print('No existe', RAIZ)
        return 2
    dirs = {'alta': os.path.join(RAIZ, 'alta'),
            'media': os.path.join(RAIZ, 'media'),
            'baja': os.path.join(RAIZ, 'baja')}
    for k, v in dirs.items():
        if not os.path.isdir(v):
            print('Falta el directorio', v)
            return 2

    nombres = sorted(os.path.basename(p)[:-4]
                     for p in glob.glob(os.path.join(dirs['alta'], '*.glb')))
    if MODULO:
        nombres = [n for n in nombres if n.startswith(MODULO + '_')]

    print('GLB auditados: %d | Z_APOYO=%.3f tolerancia=%.3f'
          % (len(nombres), Z_APOYO, TOLERANCIA))
    print('-' * 88)
    print('%-40s %9s %9s %9s  %s' % ('ASSET', 'alta', 'media', 'baja', 'ESTADO'))
    print('-' * 88)

    problemas = []
    for nombre in nombres:
        vals = {}
        for lod, d in dirs.items():
            p = os.path.join(d, nombre + '.glb')
            vals[lod] = min_y_mundial(p) if os.path.exists(p) else None
        if any(v is None for v in vals.values()):
            faltan = [k for k, v in vals.items() if v is None]
            print('%-40s  FALTA: %s' % (nombre[:40], ','.join(faltan)))
            problemas.append((nombre, 'FALTA_GLB', None))
            continue
        spread = max(vals.values()) - min(vals.values())
        if spread > TOLERANCIA:
            estado = 'LOD-INCONSISTENTE (%.3f)' % spread
            problemas.append((nombre, 'LOD', spread))
        else:
            base = sum(vals.values()) / 3.0
            if base > Z_APOYO + TOLERANCIA:
                estado = 'FLOTA'
                problemas.append((nombre, 'FLOTA', base))
            elif base < Z_APOYO - TOLERANCIA:
                estado = 'HUNDIDO'
                problemas.append((nombre, 'HUNDIDO', base))
            else:
                estado = 'ok'
        print('%-40s %9.4f %9.4f %9.4f  %s'
              % (nombre[:40], vals['alta'], vals['media'], vals['baja'], estado))

    print('-' * 88)
    print('TOTAL %d | con problemas %d' % (len(nombres), len(problemas)))
    if problemas:
        print('')
        for nombre, tipo, val in problemas:
            extra = '' if val is None else ' (%.4f)' % val
            print('   %-42s %s%s' % (nombre, tipo, extra))
    return 1 if problemas else 0


if __name__ == '__main__':
    sys.exit(main())
