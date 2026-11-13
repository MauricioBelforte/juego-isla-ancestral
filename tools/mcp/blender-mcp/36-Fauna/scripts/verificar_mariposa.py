#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Guardia POSITIVA de FORMA sobre los 3 GLB de runtime de `mariposa`
(M36 / L23 / B26): ALTA / MEDIA / BAJA.

NO es QA §21.8 ni sello: es una guardia de AUTORIA sobre EL ARTEFACTO QUE
Godot consume. `chk_asset.py` mide COSTE, no FORMA, y B12/B13 probaron que
el verde del `.blend` NO se hereda al GLB. Decodifica VERTICES REALES del
BIN y aplica la matriz COLUMN-MAJOR del nodo.

EJES: en glTF Y-up, p[0]=X de Blender, p[1]=ALTURA (Z de Blender) y
p[2]=LATERAL (Y de Blender, con signo invertido). Las alas de B26 se
separan en el eje LATERAL; por eso C12 mide `niveles_lat` y no `niveles_z`.

===========================================================================
HALLAZGO REAL DE AUTORIA QUE MOTIVA C18 (B26, 2026-11-13)
===========================================================================
La primera version ponia las 4 alas como PLACAS HORIZONTALES en
alt=0.29..0.31 y |lat|=0.10..0.22, con el cuerpo hasta |lat|=0.06 y
alt=0.265. En las hojas de contacto las alas FLOTABAN 4 cm en lateral y
2.5 cm en altura. `chk_asset.py` dio OK y la sonda geometrica dio
`total_defectos=0`: NINGUNO detecta una pieza DESCONECTADA, porque todas
las caras seguian siendo axis-aligned. Misma familia que la cresta
flotante de B23.
C18 exige CONTACTO REAL EN EL BIN: 18 vertices de cada ala dentro de la
caja AABB del nodo Cuerpo (MEDIDOS: 18 en los 3 LOD, 12+6 por panel) y
al menos 6 vertices de contacto POR PANEL. No alcanza con que el AABB
global de las 2 cajas unidas intersecte el cuerpo: eso daria un falso
verde aunque un panel estuviera suelto.
===========================================================================
C17 - ALAS SEPARADAS ("para animar"): exactamente 2 nodos `Ala_`,
materiales DISTINTOS (`AlaL`/`AlaR`) y en semiplanos laterales OPUESTOS,
en los 3 LOD. El merge por lista de materiales de `generar_variante.py`
NO puede fusionarlas. NO se implementa rig, pivote ni animacion: el
contrato bimodo completo (GUIA-BLENDER/10 §10.2, loft por anillos) queda
PROPUESTO para una eventual B26-bis; el checklist L23 pide alas SIMPLES.

C9: zona anti-cunia (0.27, 0.28) sin niveles. C14: silueta POSITIVA de
mariposa (3 escalones del cuerpo, 4 niveles de ala, bordes |lat|=0.22 y
|lat|=0.04). C16: 4 materiales base en los 3 LOD y Ojo/Antena/Mancha
SOLO en ALTA/MEDIA (poda deliberada, DECIMATE sobre 0 mallas).

Trampas evitadas: POSITION real + matrices COLUMN-MAJOR (M[c*4+r]), Y-up,
inversa GENERAL 3x3 (Cramer) para inyectar, deriva .blend->GLB publicada
como DATO (no check), un check que FALLA sigue contando como EJECUTADO,
CIEGO = menos bloques/checks que los medidos en verde (exit 3),
ROJO sobre COPIA en Temp/ con el GLB publicado intacto.

Uso:
  python verificar_mariposa.py             # VERDE (3 GLB)
  python verificar_mariposa.py --piso 0    # mide el piso en verde
  python verificar_mariposa.py --inyectar  # ROJO A (colapso de planos)
  python verificar_mariposa.py --inyectar-alas  # ROJO B (alas desconectadas)
  python verificar_mariposa.py --solo <glb>  # CIEGO (exit 3)
  python verificar_mariposa.py --volcar    # niveles de coordenada
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
BASE = '36-Fauna_mariposa.glb'

# MEDIDO EN VERDE con `--piso 0` ANTES de fijar la constante (regla:
# medir antes de escribir la cifra): CHECKS=58 PASADOS=58 FALLOS=0
# BLOQUES=3 RC=0. 18 checks x 3 GLB + 4 globales = 58.
CHECKS_MINIMOS = 58
BLOQUES_MINIMOS = 3

Y_APOYO = 0.045
Y_CIMA = 0.310
ZONA_LO, ZONA_HI = 0.27, 0.28
TOL = 0.0005
PERFIL_TRIS = {'alta': 6000, 'media': 1500, 'baja': 700}

# Niveles MEDIDOS en el BIN por Temp/hy4_mariposa_glb_probe_20261113.py.
NIVELES_X_ALTA = frozenset([
    -0.22, -0.19, -0.13, -0.11, -0.09, -0.05, -0.03, 0.01, 0.03,
    0.06, 0.09, 0.11, 0.1925, 0.22, 0.2275, 0.24,
])
NIVELES_X_BAJA = frozenset([
    -0.22, -0.19, -0.13, -0.11, -0.09, 0.01, 0.03, 0.06, 0.09, 0.22,
])
NIVELES_ALT_ALTA = frozenset([
    0.045, 0.085, 0.105, 0.155, 0.185, 0.205, 0.21, 0.215, 0.2175,
    0.225, 0.2525, 0.265, 0.305, 0.31,
])
NIVELES_ALT_BAJA = frozenset([
    0.045, 0.085, 0.105, 0.155, 0.205, 0.21, 0.225, 0.265, 0.31,
])
NIVELES_LAT_ALTA = frozenset([
    -0.22, -0.18, -0.08, -0.075, -0.067, -0.06, -0.057, -0.055,
    -0.05, -0.04, -0.02, 0.02, 0.04, 0.05, 0.055, 0.06, 0.075,
    0.08, 0.18, 0.22,
])
NIVELES_LAT_BAJA = frozenset([
    -0.22, -0.18, -0.08, -0.06, -0.05, -0.04, 0.04, 0.05, 0.06,
    0.08, 0.18, 0.22,
])

# (tris, materiales, mallas, vertices, rango_x, rango_lat) MEDIDOS EN EL BIN.
ESPERADO = {
    'alta':  (192, 7, 10, 384, 0.460, 0.44),
    'media': (192, 7,  7, 384, 0.460, 0.44),
    'baja':  (120, 4,  4, 240, 0.440, 0.44),
}
ESCALONES = (0.155, 0.225, 0.265)
NIVELES_ALA = (0.105, 0.205, 0.21, 0.31)
PANELES = ((0.105, 0.205), (0.21, 0.31))
CONTACTO_ESPERADO = 18       # MEDIDO en los 3 LOD, por ala
CONTACTO_PANEL_MIN = 6       # MEDIDO: 12 y 6 por panel


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

    # Nombre de nodo y material POR PUNTO: necesario para C17/C18.
    nombre_por_mesh = {}
    for i, n in enumerate(doc['nodes']):
        if 'mesh' in n:
            nombre_por_mesh.setdefault(n['mesh'], []).append(n.get('name', ''))
    mats_doc = doc.get('materials', [])

    mat_por_mesh = {}
    for mi, m in instancias:
        mat_por_mesh.setdefault(mi, []).append(m)

    puntos, por_nodo = [], {}
    total_tris, n_prims = 0, 0
    modos_ok, idx_ok, verts_ok = True, True, True
    for mi, mesh in enumerate(doc['meshes']):
        mats = mat_por_mesh.get(mi, [ident()])
        nombre = (nombre_por_mesh.get(mi) or ['?'])[0]
        for pr in mesh.get('primitives', []):
            n_prims += 1
            if pr.get('mode', 4) != 4:
                modos_ok = False
            mat_i = pr.get('material')
            mat_n = (mats_doc[mat_i].get('name', '')
                     if mat_i is not None and mat_i < len(mats_doc) else '')
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
                    w = aplicar(m, q)
                    puntos.append(w)
                    por_nodo.setdefault(nombre, []).append((w, mat_n))

    chk('C4', n_prims > 0 and modos_ok,
        '%d primitivas, todas TRIANGLES(4)=%s' % (n_prims, modos_ok))
    chk('C5', idx_ok, 'indices en rango y count multiplo de 3')
    chk('C6', verts_ok and len(puntos) > 0,
        '%d vertices REALES del BIN decodificados' % len(puntos))
    if not puntos:
        falta(7, 'sin vertices: no se puede medir la forma')
        return checks, d

    xs = [p[0] for p in puntos]
    ys = [p[1] for p in puntos]          # ALTURA
    zs = [p[2] for p in puntos]          # LATERAL
    lx = {round(v, 4) for v in xs}
    ly = {round(v, 4) for v in ys}
    lz = {round(v, 4) for v in zs}
    xr, zr = max(xs) - min(xs), max(zs) - min(zs)
    ymin, ymax = min(ys), max(ys)

    chk('C7', abs(ymin - Y_APOYO) <= TOL,
        'alt_min=%.4f (Z_APOYO=%.4f)' % (ymin, Y_APOYO))
    chk('C8', abs(ymax - Y_CIMA) <= TOL,
        'alt_max=%.4f (tope del ala superior 0.310)' % ymax)

    espurios = sorted(v for v in ly if ZONA_LO < v < ZONA_HI)
    chk('C9', not espurios,
        'zona anti-cunia (%.2f, %.2f): %d niveles espurios %s'
        % (ZONA_LO, ZONA_HI, len(espurios), espurios[:4]))

    ex = NIVELES_X_BAJA if lod == 'baja' else NIVELES_X_ALTA
    ey = NIVELES_ALT_BAJA if lod == 'baja' else NIVELES_ALT_ALTA
    ez = NIVELES_LAT_BAJA if lod == 'baja' else NIVELES_LAT_ALTA
    chk('C10', lx.issubset(ex) and len(lx) >= 10,
        'planos X: %d niveles, todos AUTORIZADOS (fuera=%s)'
        % (len(lx), sorted(lx - ex)[:4]))
    chk('C11', ly == ey,
        'planos ALTURA: %d niveles (esperados %d); diff=%s'
        % (len(ly), len(ey), sorted(ly ^ ey)[:6]))
    chk('C12', lz.issubset(ez) and len(lz) >= 12,
        'planos LATERAL: %d niveles, todos AUTORIZADOS (fuera=%s)'
        % (len(lz), sorted(lz - ez)[:4]))

    apoyo = {(round(p[0], 4), round(p[2], 4)) for p in puntos
             if abs(p[1] - Y_APOYO) <= 1e-3}
    chk('C13', len(apoyo) == 12,
        '12 pares (x,lat) APOYADOS en alt=%.3f (3 franjas x 4 esquinas): %d'
        % (Y_APOYO, len(apoyo)))

    # C14 POSITIVA: silueta de MARIPOSA, no una caja generica.
    escalones = all(any(abs(w - t) < 1e-4 for w in ly) for t in ESCALONES)
    niv_ala = all(any(abs(w - t) < 1e-4 for w in ly) for t in NIVELES_ALA)
    lat_ext = sum(1 for p in puntos if abs(abs(p[2]) - 0.22) < 1e-4)
    lat_int = sum(1 for p in puntos if abs(abs(p[2]) - 0.04) < 1e-4)
    e_tris, e_mats, e_mallas, e_verts, e_xr, e_zr = ESPERADO[lod]
    chk('C14', (escalones and niv_ala and lat_ext >= 24 and lat_int >= 48
                and abs(xr - e_xr) <= TOL and abs(zr - e_zr) <= TOL),
        'silueta MARIPOSA: escalones=%s niveles_ala=%s borde|lat|0.22=%d/24 '
        'anclaje|lat|0.04=%d/48 xr=%.4f/%.4f lat_r=%.4f/%.4f'
        % (escalones, niv_ala, lat_ext, lat_int, xr, e_xr, zr, e_zr))

    mats = len(mats_doc)
    chk('C15', (total_tris == e_tris and mats == e_mats
                and len(doc['meshes']) == e_mallas
                and len(puntos) == e_verts
                and total_tris <= PERFIL_TRIS[lod]),
        'M166 runtime: %d/%d tris, %d/%d mats, %d/%d mallas, %d/%d verts '
        '<= %d' % (total_tris, e_tris, mats, e_mats,
                   len(doc['meshes']), e_mallas, len(puntos), e_verts,
                   PERFIL_TRIS[lod]))

    nombres = {m.get('name', '') for m in mats_doc}
    base = tuple('MAT_Mariposa_%s' % p
                 for p in ('Roca', 'Cuerpo', 'AlaL', 'AlaR'))
    podables = tuple('MAT_Mariposa_%s' % p for p in ('Ojo', 'Antena', 'Mancha'))
    chk('C16', (all(n in nombres for n in base)
                and all((n in nombres) == (lod != 'baja') for n in podables)),
        '4 materiales base CONSERVADOS en los 3 LOD; Ojo/Antena/Mancha '
        'solo ALTA/MEDIA: %s'
        % '/'.join(str(n in nombres) for n in podables))

    # C17 POSITIVA: ALAS SEPARADAS (el "para animar" del checklist L23).
    alas_nombres = sorted(n for n in por_nodo if 'Ala_' in n)
    alas_info = {}
    for n in alas_nombres:
        items = por_nodo[n]
        vs = [w for w, _ in items]
        alas_info[n] = {
            'verts': len(vs),
            'mats': sorted({m for _, m in items}),
            'lat': (min(w[2] for w in vs), max(w[2] for w in vs)),
        }
    dos = len(alas_nombres) == 2
    distintos = (dos
                 and all(len(a['mats']) == 1 for a in alas_info.values())
                 and len({a['mats'][0] for a in alas_info.values()}) == 2)
    lados = sorted((a['lat'] for a in alas_info.values()))
    opuestos = (len(lados) == 2 and lados[0][1] < 0 and lados[1][0] > 0)
    chk('C17', dos and distintos and opuestos,
        'ALAS SEPARADAS: nodos=%d materiales=%s semiplanos=%s (L/R '
        'independientes en %s)' %
        (len(alas_nombres),
         sorted({a['mats'][0] for a in alas_info.values()}) if dos else [],
         [[round(v, 3) for v in par] for par in lados], lod))

    # C18 POSITIVA: ALAS APOYADAS (hallazgo visual B26).
    cuerpo = next((n for n in por_nodo if 'Cuerpo' in n), None)
    contactos, por_panel = {}, {}
    if cuerpo:
        cv = [w for w, _ in por_nodo[cuerpo]]
        caja = tuple((min(w[i] for w in cv), max(w[i] for w in cv))
                     for i in range(3))

        def dentro(w, tol=1e-3):
            return all(caja[i][0] - tol <= w[i] <= caja[i][1] + tol
                       for i in range(3))

        for n in alas_nombres:
            vs = [w for w, _ in por_nodo[n]]
            contactos[n] = sum(1 for w in vs if dentro(w))
            por_panel[n] = [
                sum(1 for w in vs
                    if any(abs(w[1] - t) < 1e-3 for t in par) and dentro(w))
                for par in PANELES]
    apoyadas = (dos and bool(cuerpo)
                and all(v == CONTACTO_ESPERADO for v in contactos.values())
                and all(all(v >= CONTACTO_PANEL_MIN for v in vs)
                        for vs in por_panel.values()))
    chk('C18', apoyadas,
        'ALAS APOYADAS (no flotantes): contacto=%s (esperado %d/ala) '
        'por_panel=%s (min %d) caja_cuerpo=%s'
        % (contactos, CONTACTO_ESPERADO, por_panel, CONTACTO_PANEL_MIN,
           [[round(v, 3) for v in c] for c in caja] if cuerpo else 'AUSENTE'))

    d.update({'tris': total_tris, 'vertices': len(puntos),
              'materiales': mats, 'mallas': len(doc['meshes']),
              'x_range': xr, 'lat_range': zr, 'y_min': ymin, 'y_max': ymax,
              'apoyo': len(apoyo), 'lat_ext': lat_ext, 'lat_int': lat_int,
              'alas_ok': dos and distintos and opuestos,
              'contacto_min': min(contactos.values()) if contactos else 0,
              'niveles_x': sorted(lx), 'niveles_y': sorted(ly),
              'niveles_z': sorted(lz), 'bytes': len(raw), 'sha': sha12(path)})
    return checks, d


# ------------------------------------------------------------- inyeccion ----
def inyectar(src, dst):
    """Reproduce EN UNA COPIA una pieza desconectada / fuera de plano.

    Mueve los vertices del tope del ala (alt=0.310) a alt=0.275 (DENTRO
    de la zona anti-cunia 0.27..0.28) y desplaza lateral +0.0133.
    Introduce niveles NUEVOS, destruye el tope del ala, el contacto del
    panel superior y la relacion de subconjunto BAJA/ALTA. El GLB
    publicado NO se toca.
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


def inyectar_alas(src, dst):
    """Reproduce EN UNA COPIA el DEFECTO REAL de autoria de B26.

    Mueve el borde INTERIOR de las alas de |lat|=0.04 a |lat|=0.12,
    FUERA de la caja del cuerpo (|lat|<=0.06): las alas quedan
    DESCONECTADAS. NO toca ningun nivel de ALTURA, para probar que C18
    (contacto) es infalsable POR SEPARADO de C9/C11 (planos). Es la
    inyeccion que el ROJO A no ejercitaba. El GLB publicado NO se toca.
    """
    raw, doc, bin_, ok = cargar(src)
    if not ok:
        raise RuntimeError('no se puede inyectar: GLB ilegible')
    jlen = struct.unpack_from('<I', raw, 12)[0]
    _, instancias = recorrer(doc)
    nombre_por_mesh, mat_por_mesh = {}, {}
    for n in doc['nodes']:
        if 'mesh' in n:
            nombre_por_mesh.setdefault(n['mesh'], []).append(n.get('name', ''))
    for mi, m in instancias:
        mat_por_mesh.setdefault(mi, []).append(m)

    vistos, cambios = set(), 0
    for mi, matrices in mat_por_mesh.items():
        nombre = (nombre_por_mesh.get(mi) or [''])[0]
        if 'Ala_' not in nombre:
            continue
        m = matrices[0]
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
                if abs(abs(w[2]) - 0.04) < 1e-3:
                    nueva_lat = 0.12 if w[2] > 0 else -0.12
                    nuevo = (w[0], w[1], nueva_lat)
                    struct.pack_into('<fff', bin_, off, *desaplicar(m, nuevo))
                    cambios += 1
    if cambios < 8:
        raise RuntimeError('inyeccion de alas no reprodujo la desconexion: '
                           '%d vertices' % cambios)
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
    solo, volcar, rojo, rojo_alas = None, False, False, False
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
        elif a == '--inyectar-alas':
            rojo_alas = True
        elif a == '--volcar':
            volcar = True
        i += 1

    if solo:
        lod = os.path.basename(os.path.dirname(solo)).lower()
        paths = [(lod, solo)]
    else:
        paths = [(lod, os.path.join(GODOT, lod, BASE)) for lod in LODS]

    if rojo or rojo_alas:
        src = paths[-1][1]
        publicado = sha12(src)
        if rojo_alas:
            dst = os.path.join(TEMP, 'hy4_mariposa_rojo_alas_20261113.glb')
            _, cambios = inyectar_alas(src, dst)
            etiqueta = 'ROJO B / ALAS DESCONECTADAS'
        else:
            dst = os.path.join(TEMP, 'hy4_mariposa_rojo_20261113.glb')
            _, cambios = inyectar(src, dst)
            etiqueta = 'ROJO A / COLAPSO DE PLANOS'
        assert sha12(src) == publicado, 'la inyeccion toco el GLB publicado'
        print('INYECCION %s: %d vertices mutados en %s | publicado sha=%s '
              'INTACTO' % (etiqueta, cambios, dst, publicado))
        paths[-1] = (paths[-1][0], dst)

    todos, datos = [], []
    print('=== FORMA DE RUNTIME: mariposa M36 (3 GLB) ===')
    for lod, path in paths:
        checks, d = analizar(path, lod)
        todos.extend(checks)
        datos.append(d)
        print('%-5s tris=%-4d verts=%-4d mats=%d mallas=%d '
              'xr=%.4f lat_r=%.2f apoyo=%d alas_ok=%s contacto=%d sha=%s'
              % (lod, d.get('tris', 0), d.get('vertices', 0),
                 d.get('materiales', 0), d.get('mallas', 0),
                 d.get('x_range', 0), d.get('lat_range', 0),
                 d.get('apoyo', 0), d.get('alas_ok', False),
                 d.get('contacto_min', 0), d.get('sha', '-')))
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
            and por['baja']['vertices'] < por['alta']['vertices'])
    todos.append(('G2', mono,
                  'LOD real por PODA deliberada (no por decimate)'))

    sub = []
    if len(por) == 3:
        for eje in ('x', 'y', 'z'):
            sub.append(set(por['baja']['niveles_' + eje]).issubset(
                set(por['alta']['niveles_' + eje])))
    todos.append(('G3', len(sub) == 3 and all(sub),
                  'niveles(BAJA) SUBCONJUNTO de niveles(ALTA) en x/alt/lat '
                  '(%d/3)' % sum(sub)))

    independientes = (len(por) == 3
                      and all(por[k].get('alas_ok') for k in LODS)
                      and all(por[k].get('contacto_min') == CONTACTO_ESPERADO
                              for k in LODS))
    todos.append(('G4', independientes,
                  '2 ALAS independientes y APOYADAS en los 3 LOD '
                  '(listas para animar)'))

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
    print('VERDE: forma positiva de la mariposa en 3 GLB de runtime')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
