#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Guardia POSITIVA de FORMA sobre los 6 GLB de runtime de `valla_madera`
(M40, L34 / B18): modulo RECTO + modulo ESQUINA x ALTA/MEDIA/BAJA.

NO es QA §21.8 ni sello: es una guardia de AUTORIA sobre EL ARTEFACTO QUE
Godot consume. `chk_asset.py` mide COSTE, no FORMA, y B12/B13 probaron que
el verde del `.blend` NO se hereda al GLB. Esta guardia decodifica VERTICES
REALES del BIN.

DEFECTO QUE MOTIVA LA GUARDIA (medido 2026-11-08, B18): el DECIMATE 0.70 de
`generar_variante.py` sobre mallas de cajas disjuntas (clavos y musgo) movia
vertices FUERA de los planos autoriados (y=-0.0617 donde solo debia haber
-0.055/-0.075), produciendo quads inclinados y triangulos INVISIBLES en las
capturas. Barrido medido: ratio 1.00 -> 0 defectos; 0.95 -> 8; 0.90 -> 8;
0.85 -> 6; 0.80 -> 10; 0.70 -> 12. Los 3 presupuestos M166 daban BAJA OK.
FIX: clavos `_NOFUNDIR` + musgo en 2 cajitas podables; el BAJA exportado
decima 0 mallas y baja de coste por PODA deliberada, no por colapso.

Por eso los checks C10/C11/C12 verifican que TODOS los niveles de coordenada
(x, z, y) del BIN pertenecen al conjunto AUTORIADO, calibrado en el BIN con
`Temp/hy4_valla_glb_probe.py`. Un vertice fuera de plano (aunque no cambie
la altura ni el bbox) introduce un nivel nuevo y la guardia lo detecta.

TRAMPA 1 (tambien medida en este ciclo): con clavos SUELTOS, la FASE 0 poda
los eliminaba en BAJA y se perdia `MAT_Valla_Herraje`. C16 exige el Herraje
en LOS 3 LOD y el Musgo SOLO en ALTA/MEDIA (el LOD deliberado).

Trampas evitadas a proposito:
  * No usa las 8 esquinas del AABB del accessor: decodifica POSITION real y
    aplica la matriz del nodo. Matrices glTF COLUMN-MAJOR: M[c*4+r].
  * glTF es Y-up: ALTURA = y; Blender y -> glTF z con signo invertido.
  * Los nombres de malla del GLB son `Cube`, `Cube.001`, ... TODA asercion
    es GEOMETRICA (salvo C16, que es semantica de materiales).
  * La inyeccion usa la INVERSA GENERAL 3x3 (Cramer), no la diagonal.
  * La deriva `.blend` -> GLB se publica como DATO, nunca como check (B13).
  * Un check que FALLA sigue contando como EJECUTADO.
  * CIEGO = menos bloques/checks que los medidos en verde (exit 3).

Uso:
  python verificar_valla_madera.py             # VERDE (6 GLB)
  python verificar_valla_madera.py --piso 0    # mide el piso en verde
  python verificar_valla_madera.py --inyectar  # ROJO (colapso en copia)
  python verificar_valla_madera.py --solo <glb># CIEGO (exit 3)
  python verificar_valla_madera.py --volcar    # niveles de coordenada
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
TIPOS = ('recto', 'esquina')
LODS = ('alta', 'media', 'baja')
BASE = '40-Infraestructura_valla_madera_%s.glb'

# MEDIDO EN VERDE con --piso 0 ANTES de fijar la constante (regla: medir
# antes de escribir la cifra). 16 checks x 6 GLB + 4 globales = 100.
# Salida real: CHECKS=100 PASADOS=100 FALLOS=0 BLOQUES=6. Ver acta 28.
CHECKS_MINIMOS = 100
BLOQUES_MINIMOS = 6

# --- Cotas y niveles CALIBRADOS EN EL BIN (glTF Y-up) ---
Y_APOYO = 0.045
Y_CIMA = 1.045
ZONA_LO, ZONA_HI = 0.16, 0.26
TOL = 0.0005
PERFIL_TRIS = {'alta': 6000, 'media': 1500, 'baja': 700}

NIVELES_Y = frozenset([
    0.045, 0.065, 0.115, 0.145, 0.275, 0.300, 0.335, 0.365,
    0.400, 0.750, 0.785, 0.815, 0.850, 0.875, 0.985, 1.045,
])
NIVELES_Y_BAJA = NIVELES_Y - {0.065, 0.115}

NIVELES_X = {
    'recto': frozenset([
        -1.12, -1.03, -1.0, -0.98, -0.955, -0.925, -0.9, -0.88,
        -0.85, -0.76, -0.68, -0.52, -0.38, -0.22, -0.08, 0.08,
        0.22, 0.38, 0.52, 0.68, 0.76, 0.85, 0.88, 0.9, 0.925,
        0.955, 0.98, 1.0, 1.03, 1.12,
    ]),
    'esquina': frozenset([
        -0.18, -0.09, -0.08, -0.06, -0.04, -0.03, -0.015, 0.0,
        0.015, 0.04, 0.06, 0.09, 0.18, 0.22, 0.38, 0.52, 0.68,
        0.76, 0.85, 0.88, 0.9, 0.925, 0.955, 0.98, 1.0, 1.03, 1.12,
    ]),
}
NIVELES_Z = {
    'recto': frozenset([
        -0.18, -0.09, -0.06, -0.04, 0.03, 0.04, 0.055, 0.06,
        0.075, 0.08, 0.09, 0.18, 0.2,
    ]),
    'esquina': frozenset([
        -1.12, -1.03, -1.0, -0.885, -0.88, -0.865, -0.85, -0.76,
        -0.68, -0.52, -0.38, -0.22, -0.18, -0.09, -0.06, -0.04,
        0.0, 0.03, 0.04, 0.055, 0.06, 0.075, 0.08, 0.09, 0.18, 0.2,
    ]),
}

# (tris, materiales, mallas, pares de apoyo) MEDIDOS EN EL BIN.
ESPERADO = {
    ('recto', 'alta'):   (228, 4, 7, 16),
    ('recto', 'media'):  (228, 4, 6, 16),
    ('recto', 'baja'):   (204, 3, 5, 16),
    ('esquina', 'alta'):  (300, 4, 7, 24),
    ('esquina', 'media'): (300, 4, 6, 24),
    ('esquina', 'baja'):  (276, 3, 5, 24),
}


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
def analizar(path, tipo, lod):
    """Devuelve (checks, datos). Publica SIEMPRE 16 checks por GLB."""
    N = 16
    checks, d = [], {'path': path, 'tipo': tipo, 'lod': lod}

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
        'y_max=%.4f (altura 1.00 m de valla)' % ymax)

    espurios = sorted(v for v in ly if ZONA_LO < v < ZONA_HI)
    chk('C9', not espurios,
        'zona anti-cunia (%.2f, %.2f): %d niveles espurios %s'
        % (ZONA_LO, ZONA_HI, len(espurios), espurios[:4]))

    chk('C10', lx.issubset(NIVELES_X[tipo]) and len(lx) >= 24,
        'planos X: %d niveles, todos AUTORIZADOS (fuera=%s)'
        % (len(lx), sorted(lx - NIVELES_X[tipo])[:4]))
    chk('C11', lz.issubset(NIVELES_Z[tipo]) and len(lz) >= 10,
        'planos Z: %d niveles, todos AUTORIZADOS (fuera=%s)'
        % (len(lz), sorted(lz - NIVELES_Z[tipo])[:4]))
    esperado_y = NIVELES_Y_BAJA if lod == 'baja' else NIVELES_Y
    chk('C12', ly == esperado_y,
        'planos Y: %d niveles (esperados %d); diff=%s'
        % (len(ly), len(esperado_y), sorted(ly ^ esperado_y)[:6]))

    apoyo = {(round(p[0], 4), round(p[2], 4)) for p in puntos
             if abs(p[1] - Y_APOYO) <= 1e-3}
    n_postes = 2 if tipo == 'recto' else 3
    chk('C13', len(apoyo) == 8 * n_postes,
        '%d postes APOYADOS: %d/8 pares (x,z) en y=%.3f'
        % (n_postes, len(apoyo), Y_APOYO))

    brazo_x = sum(1 for p in puntos if p[0] > 0.8 and abs(p[2]) < 0.25)
    brazo_y = sum(1 for p in puntos if p[2] < -0.8 and abs(p[0]) < 0.25)
    if tipo == 'recto':
        forma = xr >= 2.0 and zr <= 0.50 and brazo_y == 0 and brazo_x >= 100
    else:
        forma = (xr >= 1.20 and zr >= 1.20
                 and brazo_x >= 100 and brazo_y >= 100)
    chk('C14', forma,
        'NOMBRE=%s COINCIDE con la forma: xr=%.2f zr=%.2f '
        'brazo_x=%d brazo_y=%d'
        % (tipo, xr, zr, brazo_x, brazo_y))

    e_tris, e_mats, e_mallas, _ = ESPERADO[(tipo, lod)]
    mats = len(doc.get('materials', []))
    chk('C15', (total_tris == e_tris and mats == e_mats
                and len(doc['meshes']) == e_mallas
                and total_tris <= PERFIL_TRIS[lod]),
        'M166 runtime: %d/%d tris, %d/%d mats, %d/%d mallas <= %d'
        % (total_tris, e_tris, mats, e_mats, len(doc['meshes']), e_mallas,
           PERFIL_TRIS[lod]))

    nombres = {m.get('name', '') for m in doc.get('materials', [])}
    chk('C16', ('MAT_Valla_Herraje' in nombres
                and (('MAT_Valla_Musgo' in nombres) == (lod != 'baja'))),
        'Herraje CONSERVADO en los 3 LOD; Musgo=%s (BAJA lo poda a proposito)'
        % ('MAT_Valla_Musgo' in nombres))

    d.update({'tris': total_tris, 'vertices': len(puntos),
              'materiales': mats, 'mallas': len(doc['meshes']),
              'x_range': xr, 'z_range': zr, 'y_min': ymin, 'y_max': ymax,
              'apoyo': len(apoyo), 'brazo_x': brazo_x, 'brazo_y': brazo_y,
              'niveles_x': sorted(lx), 'niveles_y': sorted(ly),
              'niveles_z': sorted(lz), 'bytes': len(raw), 'sha': sha12(path)})
    return checks, d


# ------------------------------------------------------------- inyeccion ----
def inyectar(src, dst):
    """Reproduce EN UNA COPIA el dano del decimate: vertices fuera de plano.

    Mueve al plano y=0.20 (zona anti-cunia) y desplaza z +0.0133 los
    vertices del nivel y=0.335. Eso introduce niveles NUEVOS en los 3 ejes,
    exactamente la firma del colapso que esta guardia debe detectar. El GLB
    publicado NO se toca: se escribe en Temp/. Usa inversa GENERAL 3x3.
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
                if abs(w[1] - 0.335) < 1e-3:
                    nuevo = (w[0], 0.20, w[2] + 0.0133)
                    struct.pack_into('<fff', bin_, off, *desaplicar(m, nuevo))
                    cambios += 1
    if cambios < 8:
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
    extras = []
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == '--piso':
            i += 1; piso = int(argv[i])
        elif a == '--solo':
            i += 1; solo = argv[i]
        elif a == '--extra':
            i += 1; extras.append(argv[i])
        elif a == '--inyectar':
            rojo = True
        elif a == '--volcar':
            volcar = True
        i += 1

    if solo:
        nombre = os.path.basename(solo)
        tipo = 'esquina' if 'esquina' in nombre else 'recto'
        padre = os.path.basename(os.path.dirname(solo)).lower()
        paths = [(tipo, padre, solo)]
    else:
        paths = [(tipo, lod, os.path.join(GODOT, lod, BASE % tipo))
                 for tipo in TIPOS for lod in LODS]
    for e in extras:
        nombre = os.path.basename(e)
        paths.append(('esquina' if 'esquina' in nombre else 'recto',
                      os.path.basename(os.path.dirname(e)).lower(), e))

    if rojo:
        dst = os.path.join(TEMP, 'hy4_valla_rojo_20261108.glb')
        _, cambios = inyectar(paths[-1][2], dst)
        print('INYECCION: %d vertices mutados en %s' % (cambios, dst))
        paths[-1] = (paths[-1][0], paths[-1][1], dst)

    todos, datos = [], []
    print('=== FORMA DE RUNTIME: valla_madera RECTO + ESQUINA (GLB) ===')
    for tipo, lod, path in paths:
        checks, d = analizar(path, tipo, lod)
        todos.extend(checks)
        datos.append(d)
        print('%-7s/%-5s tris=%-4d verts=%-4d mats=%d mallas=%d '
              'xr=%.2f zr=%.2f apoyo=%d bx=%d by=%d sha=%s'
              % (tipo, lod, d.get('tris', 0), d.get('vertices', 0),
                 d.get('materiales', 0), d.get('mallas', 0),
                 d.get('x_range', 0), d.get('z_range', 0),
                 d.get('apoyo', 0), d.get('brazo_x', 0),
                 d.get('brazo_y', 0), d.get('sha', '-')))
        if volcar:
            print('   Bloque %s/%s: %d checks' % (tipo, lod, len(checks)))
            for eje in ('x', 'y', 'z'):
                print('   niveles_%s=%s' % (eje, d.get('niveles_' + eje, [])))

    pares = {(d['tipo'], d['lod']) for d in datos}
    todos.append(('G1', pares == {(t, l) for t in TIPOS for l in LODS}
                  and len(datos) == 6,
                  'cobertura 2 modulos x 3 LOD = %d bloques' % len(datos)))

    mono = []
    for t in TIPOS:
        por = {d['lod']: d for d in datos if d['tipo'] == t}
        if len(por) == 3:
            mono.append(por['alta']['tris'] == por['media']['tris']
                        > por['baja']['tris']
                        and por['alta']['mallas'] > por['media']['mallas']
                        > por['baja']['mallas']
                        and (por['alta']['materiales'],
                             por['media']['materiales'],
                             por['baja']['materiales']) == (4, 4, 3))
    todos.append(('G2', len(mono) == 2 and all(mono),
                  'LOD real por PODA en ambos modulos (no por decimate)'))

    sub = []
    for t in TIPOS:
        a = next((d for d in datos if d['tipo'] == t and d['lod'] == 'alta'), None)
        b = next((d for d in datos if d['tipo'] == t and d['lod'] == 'baja'), None)
        if a and b:
            for eje in ('x', 'y', 'z'):
                sub.append(set(b['niveles_' + eje]).issubset(
                    set(a['niveles_' + eje])))
    todos.append(('G3', len(sub) == 6 and all(sub),
                  'niveles(BAJA) SUBCONJUNTO de niveles(ALTA) en x/y/z '
                  '(%d/6)' % sum(sub)))

    shas = [d.get('sha') for d in datos]
    todos.append(('G4', len(shas) == 6 and len(set(shas)) == 6,
                  '6 GLB con sha DISTINTO (no 3 copias del mismo LOD)'))

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
    print('VERDE: forma positiva de recto + esquina en 6 GLB de runtime')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
