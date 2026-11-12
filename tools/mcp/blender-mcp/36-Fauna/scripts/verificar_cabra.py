#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Guardia POSITIVA de FORMA sobre los 3 GLB de runtime de `cabra`
(M36 / L21 / B24): ALTA / MEDIA / BAJA.

NO es QA §21.8 ni sello: es una guardia de AUTORIA sobre EL ARTEFACTO QUE
Godot consume. `chk_asset.py` mide COSTE, no FORMA, y B12/B13 probaron que
el verde del `.blend` NO se hereda al GLB. Decodifica VERTICES REALES del
BIN y aplica la matriz del nodo.

DEFECTO QUE MOTIVA LA GUARDIA (B18 / acta 28, aplicado en B19..B24): el
DECIMATE 0.70 sobre cajas disjuntas movia vertices FUERA de los planos
autorizados, invisible en el render y NO detectado por `chk_asset.py`.
B24 lo evita POR DISENIO: 6 detalles sueltos con volumen_bbox < 1e-4,
FASE 0 los poda en BAJA y el DECIMATE actua sobre **0 mallas**.

C10/C11/C12: niveles de coordenada (x, z, y) del BIN dentro del conjunto
AUTORIZADO, calibrado con `Temp/hy4_cabra_glb_probe_20261111.py`.
C9: zona anti-cunia (0.27, 0.28) sin niveles. C14: silueta POSITIVA de
cabra (3 escalones del lomo, hocico x=0.35, cuernos y=0.335, trasero
x=-0.19). C16: 4 materiales base en LOS 3 LOD y Ojo/Barba/Mancha SOLO en
ALTA/MEDIA. C17: PODA REAL. C18: CUERNOS APOYADOS (36 vertices en y=0.245
compartidos con el tope de la cabeza) — leccion del hallazgo visual B23,
donde la cresta flotaba.

Trampas evitadas: POSITION real + matrices COLUMN-MAJOR (M[c*4+r]), Y-up,
inversa GENERAL 3x3 (Cramer) para inyectar, deriva .blend->GLB publicada
como DATO (no check), un check que FALLA sigue contando como EJECUTADO,
CIEGO = menos bloques/checks que los medidos en verde (exit 3).

Uso:
  python verificar_cabra.py             # VERDE (3 GLB)
  python verificar_cabra.py --piso 0    # mide el piso en verde
  python verificar_cabra.py --inyectar  # ROJO (colapso en copia)
  python verificar_cabra.py --solo <glb>  # CIEGO (exit 3)
  python verificar_cabra.py --volcar    # niveles de coordenada
"""
import hashlib
import json
import math
import os
import struct
import sys

REPO = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', '..'))
GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
TEMP = os.path.join(REPO, 'Temp')
LODS = ('alta', 'media', 'baja')
BASE = '36-Fauna_cabra.glb'

# MEDIDO EN VERDE con `--piso 0` ANTES de fijar la constante (regla:
# medir antes de escribir la cifra): CHECKS=58 PASADOS=58 FALLOS=0
# BLOQUES=3 RC=0. 18 checks x 3 GLB + 4 globales = 58.
CHECKS_MINIMOS = 58
BLOQUES_MINIMOS = 3

Y_APOYO = 0.045
Y_CIMA = 0.335
ZONA_LO, ZONA_HI = 0.27, 0.28
TOL = 0.0005
PERFIL_TRIS = {'alta': 6000, 'media': 1500, 'baja': 700}

NIVELES_X_ALTA = frozenset([
    -0.22, -0.19, -0.13, -0.095, -0.09, -0.07, -0.05, -0.025, 0.03,
    0.05, 0.06, 0.09, 0.105, 0.13, 0.15, 0.175, 0.21, 0.22, 0.255,
    0.2925, 0.305, 0.3275, 0.345, 0.35, 0.365,
])
NIVELES_X_BAJA = frozenset([
    -0.22, -0.19, -0.13, -0.095, -0.09, -0.025, 0.06, 0.09, 0.105,
    0.175, 0.21, 0.22, 0.255, 0.305, 0.35,
])
NIVELES_Y_ALTA = frozenset([
    0.045, 0.085, 0.125, 0.155, 0.165, 0.185, 0.1875, 0.215, 0.2225,
    0.225, 0.245, 0.265, 0.335,
])
NIVELES_Y_BAJA = frozenset([
    0.045, 0.085, 0.125, 0.155, 0.225, 0.245, 0.265, 0.335,
])
NIVELES_Z_ALTA = frozenset([
    -0.18, -0.13, -0.105, -0.095, -0.09, -0.08, -0.075, -0.07, -0.06,
    -0.05, -0.03, -0.025, 0.025, 0.03, 0.05, 0.06, 0.07, 0.075, 0.08,
    0.09, 0.095, 0.13, 0.18,
])
NIVELES_Z_BAJA = frozenset([
    -0.18, -0.13, -0.09, -0.08, -0.075, -0.07, -0.06, -0.05, -0.03,
    0.03, 0.05, 0.06, 0.07, 0.075, 0.08, 0.09, 0.13, 0.18,
])

# (tris, materiales, mallas, vertices, x_range) MEDIDOS EN EL BIN.
ESPERADO = {
    'alta':  (228, 7, 10, 456, 0.585),
    'media': (228, 7, 7, 456, 0.585),
    'baja':  (156, 4, 4, 312, 0.570),
}
Z_RANGE = 0.36
OJOS_LOD = {'alta': 24, 'media': 24, 'baja': 0}
MANCHAS_LOD = {'alta': 36, 'media': 36, 'baja': 0}
LOMO_NIVELES = (0.155, 0.225, 0.265)


# ---------------------------------------------------------------- glTF -----
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
            instancias.append((n['mesh'], m))
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


# ------------------------------------------------------------ geometria -----
def analizar(path, lod):
    """Devuelve (checks, datos). Publica SIEMPRE 18 checks por GLB."""
    N = 18
    checks, d = [], {'path': path, 'lod': lod}

    def chk(codigo, ok, detalle):
        checks.append((codigo, bool(ok), detalle))

    def falta(desde, motivo):
        for i in range(desde, N + 1):
            chk('C%d' % i, False, motivo)

    if not os.path.isfile(path):
        falta(1, 'archivo ausente')
        return checks, d

    raw, doc, bin_, estructura = cargar(path)
    chk('C1', estructura, 'glTF v2 + chunks coherentes (%d bytes)' % len(raw))
    if not estructura or doc is None:
        falta(2, 'GLB ilegible')
        return checks, d

    tiene = all(k in doc for k in ('meshes', 'nodes', 'accessors', 'bufferViews'))
    chk('C2', tiene, 'meshes=%d nodes=%d accessors=%d' %
        (len(doc.get('meshes', [])), len(doc.get('nodes', [])),
         len(doc.get('accessors', []))))
    if not tiene:
        falta(3, 'estructura glTF incompleta')
        return checks, d

    alcanzables, instancias = recorrer(doc)
    mesh_nodes = {i for i, n in enumerate(doc['nodes']) if 'mesh' in n}
    chk('C3', mesh_nodes.issubset(alcanzables),
        'nodos con mesh alcanzables %d/%d' %
        (len(mesh_nodes & alcanzables), len(mesh_nodes)))

    mat_por_mesh = {}
    for mi, m in instancias:
        mat_por_mesh.setdefault(mi, []).append(m)

    puntos, total_tris, n_prims = [], 0, 0
    modos_ok, idx_ok, verts_ok = True, True, True
    for mi, mesh in enumerate(doc['meshes']):
        mats = mat_por_mesh.get(mi, [ident()])
        for pr in mesh.get('primitives', []):
            n_prims += 1
            if pr.get('mode', 4) != 4:
                modos_ok = False
            pos_i = pr.get('attributes', {}).get('POSITION')
            if pos_i is None:
                verts_ok = False
                continue
            pos, e1 = leer_vec(doc, bin_, pos_i, 'f', 3)
            if e1 or not pos:
                verts_ok = False
                continue
            if not all(math.isfinite(float(v)) for p in pos for v in p):
                verts_ok = False
            ai = pr.get('indices')
            if ai is None:
                count, indices = len(pos), list(range(len(pos)))
            else:
                fmt = {5121: 'B', 5123: 'H', 5125: 'I'}.get(
                    doc['accessors'][ai]['componentType'], 'H')
                vals, e2 = leer_vec(doc, bin_, ai, fmt, 1)
                count = doc['accessors'][ai]['count']
                indices = [v[0] for v in vals]
                if e2 or len(indices) != count:
                    idx_ok = False
            if count % 3 != 0:
                idx_ok = False
            if indices and max(indices) >= len(pos):
                idx_ok = False
            total_tris += count // 3
            for m in mats:
                for q in pos:
                    puntos.append(aplicar(m, q))

    chk('C4', n_prims > 0 and modos_ok,
        '%d primitivas, todas TRIANGLES(4)=%s' % (n_prims, modos_ok))
    chk('C5', idx_ok, 'indices en rango y count multiplo de 3')
    chk('C6', verts_ok and len(puntos) > 0,
        '%d vertices REALES del BIN decodificados' % len(puntos))
    if not puntos:
        falta(7, 'sin vertices: no se puede medir la forma')
        return checks, d

    xs = [p[0] for p in puntos]
    ys = [p[1] for p in puntos]
    zs = [p[2] for p in puntos]
    lx = {round(v, 4) for v in xs}
    ly = {round(v, 4) for v in ys}
    lz = {round(v, 4) for v in zs}
    xr, zr = max(xs) - min(xs), max(zs) - min(zs)
    ymin, ymax = min(ys), max(ys)

    chk('C7', abs(ymin - Y_APOYO) <= TOL,
        'y_min=%.4f (Z_APOYO=%.4f)' % (ymin, Y_APOYO))
    chk('C8', abs(ymax - Y_CIMA) <= TOL,
        'y_max=%.4f (tope de los cuernos 0.335)' % ymax)

    espurios = sorted(v for v in ly if ZONA_LO < v < ZONA_HI)
    chk('C9', not espurios,
        'zona anti-cunia (%.2f, %.2f): %d niveles espurios %s'
        % (ZONA_LO, ZONA_HI, len(espurios), espurios[:4]))

    ex = NIVELES_X_BAJA if lod == 'baja' else NIVELES_X_ALTA
    ez = NIVELES_Z_BAJA if lod == 'baja' else NIVELES_Z_ALTA
    ey = NIVELES_Y_BAJA if lod == 'baja' else NIVELES_Y_ALTA
    chk('C10', lx.issubset(ex) and len(lx) >= 15,
        'planos X: %d niveles, todos AUTORIZADOS (fuera=%s)'
        % (len(lx), sorted(lx - ex)[:4]))
    chk('C11', lz.issubset(ez) and len(lz) >= 18,
        'planos Z: %d niveles, todos AUTORIZADOS (fuera=%s)'
        % (len(lz), sorted(lz - ez)[:4]))
    chk('C12', ly == ey,
        'planos Y: %d niveles (esperados %d); diff=%s'
        % (len(ly), len(ey), sorted(ly ^ ey)[:6]))

    apoyo = {(round(p[0], 4), round(p[2], 4)) for p in puntos
             if abs(p[1] - Y_APOYO) <= 1e-3}
    chk('C13', len(apoyo) == 12,
        '12 pares (x,z) APOYADOS en y=%.3f (3 franjas x 4 esquinas): %d'
        % (Y_APOYO, len(apoyo)))

    # C14 POSITIVA: silueta de cabra, no una caja generica.
    escalones = all(any(abs(w - t) < 1e-4 for w in ly) for t in LOMO_NIVELES)
    cima = sum(1 for p in puntos if abs(p[1] - Y_CIMA) < 1e-4)
    hocico = sum(1 for p in puntos if abs(p[0] - 0.35) < 1e-4)
    trasero = sum(1 for p in puntos if abs(p[0] + 0.19) < 1e-4)
    chk('C14', (escalones and cima >= 4 and hocico >= 4 and trasero >= 4
                and abs(xr - ESPERADO[lod][4]) <= TOL
                and abs(zr - Z_RANGE) <= TOL),
        'silueta: lomo=%s cuernos=%d/4 hocico=%d/4 trasero=%d/4 '
        'xr=%.4f/%.4f zr=%.4f/%.4f'
        % (escalones, cima, hocico, trasero, xr, ESPERADO[lod][4],
           zr, Z_RANGE))

    e_tris, e_mats, e_mallas, e_verts, _ = ESPERADO[lod]
    mats = len(doc.get('materials', []))
    chk('C15', (total_tris == e_tris and mats == e_mats
                and len(doc['meshes']) == e_mallas
                and len(puntos) == e_verts
                and total_tris <= PERFIL_TRIS[lod]),
        'M166 runtime: %d/%d tris, %d/%d mats, %d/%d mallas, %d/%d verts '
        '<= %d' % (total_tris, e_tris, mats, e_mats,
                   len(doc['meshes']), e_mallas, len(puntos), e_verts,
                   PERFIL_TRIS[lod]))

    nombres = {m.get('name', '') for m in doc.get('materials', [])}
    base = tuple('MAT_Cabra_%s' % p
                 for p in ('Roca', 'Cuerpo', 'Cabeza', 'Cuerno'))
    podables = tuple('MAT_Cabra_%s' % p for p in ('Ojo', 'Barba', 'Mancha'))
    chk('C16', (all(n in nombres for n in base)
                and all((n in nombres) == (lod != 'baja') for n in podables)),
        '4 materiales base CONSERVADOS en los 3 LOD; Ojo/Barba/Mancha '
        'solo ALTA/MEDIA: %s'
        % '/'.join(str(n in nombres) for n in podables))

    ojos = sum(1 for p in puntos if abs(p[1] - 0.2225) < 1e-4)
    manchas = sum(1 for p in puntos if abs(p[1] - 0.215) < 1e-4)
    chk('C17', ojos == OJOS_LOD[lod] and manchas == MANCHAS_LOD[lod],
        'LOD real por PODA: ojos(y=0.2225)=%d/%d manchas(y=0.215)=%d/%d'
        % (ojos, OJOS_LOD[lod], manchas, MANCHAS_LOD[lod]))

    # C18: los CUERNOS deben estar APOYADOS (leccion del hallazgo visual
    # B23). 36 vertices en y=0.245 = tope de la cabeza + bases de los
    # 2 cuernos, triplicados por normales de cara en el BIN.
    union = sum(1 for p in puntos if abs(p[1] - 0.245) < 1e-4)
    chk('C18', union == 36 and cima == 24,
        'cuernos APOYADOS (no flotantes): %d vertices en y=0.245 (=36) '
        'y %d en la cima (=24)' % (union, cima))

    d.update({'tris': total_tris, 'vertices': len(puntos),
              'materiales': mats, 'mallas': len(doc['meshes']),
              'x_range': xr, 'z_range': zr, 'y_min': ymin, 'y_max': ymax,
              'apoyo': len(apoyo), 'ojos': ojos, 'manchas': manchas,
              'niveles_x': sorted(lx), 'niveles_y': sorted(ly),
              'niveles_z': sorted(lz), 'bytes': len(raw), 'sha': sha12(path)})
    return checks, d


# ------------------------------------------------------------- inyeccion ----
def inyectar(src, dst):
    """Reproduce EN UNA COPIA el dano del decimate: vertices fuera de plano.

    Mueve al plano y=0.275 (DENTRO de la zona anti-cunia 0.27..0.28) y
    desplaza z +0.0133 los vertices de y=0.335 (tope de los cuernos).
    Introduce niveles NUEVOS, destruye el tope de los cuernos y la
    relacion de subconjunto BAJA/ALTA. El GLB publicado NO se toca.
    """
    raw, doc, bin_, ok = cargar(src)
    if not ok:
        raise RuntimeError('no se puede inyectar: GLB ilegible')
    jlen = struct.unpack_from('<I', raw, 12)[0]
    _, instancias = recorrer(doc)
    vistos, cambios = set(), 0
    for mi, m in instancias:
        for pr in doc['meshes'][mi].get('primitives', []):
            pos_i = pr.get('attributes', {}).get('POSITION')
            if pos_i is None or pos_i in vistos:
                continue
            vistos.add(pos_i)
            acc = doc['accessors'][pos_i]
            bv = doc['bufferViews'][acc['bufferView']]
            base = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
            stride = bv.get('byteStride') or 12
            for k in range(acc['count']):
                off = base + k * stride
                w = aplicar(m, struct.unpack_from('<fff', bin_, off))
                if abs(w[1] - Y_CIMA) < 1e-3:
                    nuevo = (w[0], 0.275, w[2] + 0.0133)
                    struct.pack_into('<fff', bin_, off, *desaplicar(m, nuevo))
                    cambios += 1
    if cambios < 4:
        raise RuntimeError('inyeccion no reprodujo el colapso: %d vertices'
                           % cambios)
    chunk = raw[20:20 + jlen]
    off = 20 + jlen
    blen, btipo = struct.unpack_from('<II', raw, off)
    total = 12 + 8 + len(chunk) + 8 + blen
    salida = (struct.pack('<III', 0x46546C67, 2, total) +
              struct.pack('<II', len(chunk), 0x4E4F534A) + chunk +
              struct.pack('<II', blen, btipo) + bytes(bin_))
    with open(dst, 'wb') as f:
        f.write(salida)
    return dst, cambios


# ------------------------------------------------------------------- main ----
def main(argv):
    piso = CHECKS_MINIMOS
    solo, volcar, rojo = None, False, False
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
        elif a == '--volcar':
            volcar = True
        i += 1

    if solo:
        lod = os.path.basename(os.path.dirname(solo)).lower()
        paths = [(lod, solo)]
    else:
        paths = [(lod, os.path.join(GODOT, lod, BASE)) for lod in LODS]

    if rojo:
        src = paths[-1][1]
        publicado = sha12(src)
        dst = os.path.join(TEMP, 'hy4_cabra_rojo_20261111.glb')
        _, cambios = inyectar(src, dst)
        assert sha12(src) == publicado, 'la inyeccion toco el GLB publicado'
        print('INYECCION: %d vertices mutados en %s | publicado sha=%s '
              'INTACTO' % (cambios, dst, publicado))
        paths[-1] = (paths[-1][0], dst)

    todos, datos = [], []
    print('=== FORMA DE RUNTIME: cabra M36 (3 GLB) ===')
    for lod, path in paths:
        checks, d = analizar(path, lod)
        todos.extend(checks)
        datos.append(d)
        print('%-5s tris=%-4d verts=%-4d mats=%d mallas=%d '
              'xr=%.4f zr=%.2f apoyo=%d ojos=%d manchas=%d sha=%s'
              % (lod, d.get('tris', 0), d.get('vertices', 0),
                 d.get('materiales', 0), d.get('mallas', 0),
                 d.get('x_range', 0), d.get('z_range', 0),
                 d.get('apoyo', 0), d.get('ojos', 0),
                 d.get('manchas', 0), d.get('sha', '-')))
        if volcar:
            print('   Bloque %s: %d checks' % (lod, len(checks)))
            for eje in ('x', 'y', 'z'):
                print('   niveles_%s=%s' % (eje, d.get('niveles_' + eje, [])))

    lods_vistos = {d['lod'] for d in datos}
    todos.append(('G1', lods_vistos == set(LODS) and len(datos) == 3,
                  'cobertura 3 LOD = %d bloques' % len(datos)))

    por = {d['lod']: d for d in datos}
    mono = (len(por) == 3
            and por['alta']['tris'] == por['media']['tris'] > por['baja']['tris']
            and por['alta']['mallas'] > por['media']['mallas'] > por['baja']['mallas']
            and (por['alta']['materiales'], por['media']['materiales'],
                 por['baja']['materiales']) == (7, 7, 4)
            and por['baja']['ojos'] < por['alta']['ojos']
            and por['baja']['manchas'] < por['alta']['manchas'])
    todos.append(('G2', mono,
                  'LOD real por PODA deliberada (no por decimate)'))

    sub = []
    if len(por) == 3:
        for eje in ('x', 'y', 'z'):
            sub.append(set(por['baja']['niveles_' + eje]).issubset(
                set(por['alta']['niveles_' + eje])))
    todos.append(('G3', len(sub) == 3 and all(sub),
                  'niveles(BAJA) SUBCONJUNTO de niveles(ALTA) en x/y/z '
                  '(%d/3)' % sum(sub)))

    shas = [d.get('sha') for d in datos]
    todos.append(('G4', len(shas) == 3 and len(set(shas)) == 3,
                  '3 GLB con sha DISTINTO (no 3 copias del mismo LOD)'))

    pasados = sum(1 for _, ok, _ in todos if ok)
    fallos = len(todos) - pasados
    bloques = len(datos)
    for codigo, ok, detalle in todos:
        if not ok:
            print('   FAIL %-4s %s' % (codigo, detalle))
    print('CHECKS=%d PASADOS=%d FALLOS=%d BLOQUES=%d PISO=%d' %
          (len(todos), pasados, fallos, bloques, piso))

    if bloques < BLOQUES_MINIMOS or len(todos) < piso:
        print('CIEGO: faltan bloques o checks ejecutados (no se hereda ningun verde)')
        return 3
    if fallos:
        print('ROJO: la guardia detecto geometria fuera de plano en runtime')
        return 1
    print('VERDE: forma positiva de la cabra en 3 GLB de runtime')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
