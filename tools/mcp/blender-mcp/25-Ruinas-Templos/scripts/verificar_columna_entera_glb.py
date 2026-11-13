#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Guardia POSITIVA de FORMA sobre los 3 GLB de runtime de `columna_entera`
(M25 / B28): ALTA / MEDIA / BAJA.

NO es QA §21.8 ni sello: es una guardia de AUTORIA sobre EL ARTEFACTO QUE
Godot consume. COMPLEMENTA (no sustituye) a `verificar_columna_entera.py`,
que es `bpy` y verifica los 3 `.blend`, NO los GLB.

===========================================================================
DEFECTO QUE MOTIVA LA GUARDIA (2026-11-06, documentado en la hermana bpy)
===========================================================================
La BAJA de `columna_entera` pasaba los TRES presupuestos M166
(342/700 tris, 4/6 obj, 4/4 mats) con el ABACO COLAPSADO por el decimate:
0 caras laterales completas, vertices a 2.8267 / 2.8733 (media losa) y
aire visible bajo la losa. `chk_asset.py` mide COSTE, no FORMA. Y un verde
sobre el `.blend` NO se hereda al GLB (B12/B13). Hasta B28 los 3 GLB que
Godot importa NUNCA habian sido verificados sobre su BIN.

Esta guardia replica sobre TRIANGULOS del BIN las mediciones de la hermana:
  - huella de APOYO 1.0 x 1.0 (vertices en alt=0.045),
  - caras laterales completas de ABACO (2.78..2.92), REMATE (2.92..3.00)
    y EQUINO (centroide 2.55..2.77),
  - BANDA ANTI-COLAPSO (2.79, 2.91): 0 niveles y 0 vertices a media losa.
Umbrales MEDIDOS EN EL BIN por Temp/hy4_b28_glb_probe_20261113.py, NO
heredados de la guardia bpy: abaco=4, remate=4, equino=64 en los 3 LOD
(el glTF triangula, pero el conteo resultante se mide, no se supone).

Trampas evitadas: POSITION real + matrices COLUMN-MAJOR (M[c*4+r]), Y-up,
inversa GENERAL 3x3 (Cramer) para inyectar, PISO medido EN VERDE antes de
fijarlo, un check que FALLA sigue contando como EJECUTADO, CIEGO = menos
bloques/checks (exit 3), ROJO sobre COPIA en Temp/ con GLB intactos.

Uso:
  python verificar_columna_entera_glb.py             # VERDE (3 GLB)
  python verificar_columna_entera_glb.py --piso 0    # mide el piso en verde
  python verificar_columna_entera_glb.py --inyectar  # ROJO (abaco colapsado)
  python verificar_columna_entera_glb.py --solo <glb>  # CIEGO (exit 3)
  python verificar_columna_entera_glb.py --volcar    # niveles de altura
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
BASE = '25-Ruinas-Templos_columna_entera.glb'

# MEDIDO EN VERDE con `--piso 0` ANTES de fijar la constante (regla:
# medir antes de escribir la cifra): CHECKS=58 PASADOS=58 FALLOS=0
# BLOQUES=3 RC=0. 18 checks x 3 GLB + 4 globales = 58.
CHECKS_MINIMOS = 58
BLOQUES_MINIMOS = 3

Z_APOYO, H = 0.045, 3.0000
Z_ABACO_0, Z_ABACO_1 = 2.78, 2.92
Z_REMATE_0, Z_REMATE_1 = 2.92, 3.00
BANDA_LO, BANDA_HI = 2.79, 2.91
TOL = 0.0005
PERFIL_TRIS = {'alta': 6000, 'media': 1500, 'baja': 700}
MATS = frozenset(('MAT_ColEnt_Piedra', 'MAT_ColEnt_PiedraOsc',
                  'MAT_ColEnt_Tallado', 'MAT_ColEnt_Musgo'))
NIVELES_CLAVE = (0.045, 2.78, 2.92, 3.00)
NODOS_ALTA = ('SM_ColEnt_Abaco_NOFUNDIR', 'SM_ColEnt_Plinto_NOFUNDIR',
              'SM_ColEnt_Equino', 'SM_ColEnt_Remate', 'SM_ColEnt_Fuste')
NODOS_MERGE = ('SM_ColEnt_M_ColEnt_Musgo', 'SM_ColEnt_M_ColEnt_Piedra',
               'SM_ColEnt_M_ColEnt_Tallado',
               'SM_ColEnt_Abaco_NOFUNDIR', 'SM_ColEnt_Plinto_NOFUNDIR')

# (tris, mats, mallas, verts, abaco, remate, equino, apoyo_pares,
#  apoyo_verts) MEDIDOS EN EL BIN. Nada estimado.
ESPERADO = {
    'alta':  (492, 4, 13, 890, 4, 4, 64, 16, 48),
    'media': (492, 4,  5, 890, 4, 4, 64, 16, 48),
    'baja':  (348, 4,  5, 667, 4, 4, 64, 16, 48),
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


def normal_z(a, b, c):
    """|componente Z| de la normal normalizada del triangulo."""
    ux, uy, uz = (b[i] - a[i] for i in range(3))
    vx, vy, vz = (c[i] - a[i] for i in range(3))
    nx, ny, nz = uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
    mod = math.sqrt(nx * nx + ny * ny + nz * nz)
    return abs(nz) / mod if mod > 1e-12 else 0.0


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

    nombres_nodos = [n.get('name', '') for n in doc['nodes']]
    mat_por_mesh = {}
    for mi, m in instancias:
        mat_por_mesh.setdefault(mi, []).append(m)

    puntos, triangulos = [], []
    total_tris, n_prims = 0, 0
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
            wpos = [aplicar(m, q) for m in mats for q in pos]
            # Se construyen los triangulos con la primera matriz (una sola
            # instancia por mesh en este asset, medido en la sonda).
            wm = [aplicar(mats[0], q) for q in pos]
            puntos.extend(wpos)
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
            if indices and max(indices) >= len(wm):
                idx_ok = False
            total_tris += count // 3
            for k in range(0, count - 2, 3):
                triangulos.append((wm[indices[k]], wm[indices[k + 1]],
                                   wm[indices[k + 2]]))

    chk('C4', n_prims > 0 and modos_ok,
        '%d primitivas, todas TRIANGLES(4)=%s' % (n_prims, modos_ok))
    chk('C5', idx_ok, 'indices en rango y count multiplo de 3')
    chk('C6', verts_ok and len(puntos) > 0 and len(triangulos) > 0,
        '%d vertices y %d triangulos REALES del BIN' %
        (len(puntos), len(triangulos)))
    if not puntos or not triangulos:
        falta(7, 'sin geometria: no se puede medir la forma')
        return checks, d

    alt = [p[1] for p in puntos]
    ymin, ymax = min(alt), max(alt)
    lalt = {round(v, 4) for v in alt}
    e = ESPERADO[lod]
    (e_tris, e_mats, e_mallas, e_verts, e_abaco, e_remate, e_equino,
     e_apoyo, e_apoyo_verts) = e

    chk('C7', abs(ymin - Z_APOYO) <= TOL,
        'alt_min=%.4f (Z_APOYO=%.4f)' % (ymin, Z_APOYO))
    chk('C8', abs(ymax - H) <= TOL,
        'alt_max=%.4f (H=%.2f, capitel completo)' % (ymax, H))

    va = [p for p in puntos if abs(p[1] - Z_APOYO) <= 1e-4]
    pares = {(round(p[0], 4), round(p[2], 4)) for p in va}
    fx = (max(p[0] for p in va) - min(p[0] for p in va)) if va else -1
    fy = (max(p[2] for p in va) - min(p[2] for p in va)) if va else -1
    chk('C9', (len(pares) == e_apoyo and len(va) == e_apoyo_verts
               and abs(fx - 1.0) <= TOL and abs(fy - 1.0) <= TOL),
        'HUELLA DE APOYO=%.4fx%.4f con %d pares / %d verts (spec 1x1)'
        % (fx, fy, len(pares), len(va)))

    banda = sorted(v for v in lalt if BANDA_LO < v < BANDA_HI)
    media_losa = sum(1 for p in puntos if BANDA_LO < p[1] < BANDA_HI)
    chk('C10', not banda and media_losa == 0,
        'BANDA ANTI-COLAPSO (%.2f,%.2f): %d niveles espurios %s y '
        '%d vertices a media losa (defecto 2026-11-06)'
        % (BANDA_LO, BANDA_HI, len(banda), banda[:4], media_losa))

    presentes = [t for t in NIVELES_CLAVE
                 if any(abs(w - t) <= TOL for w in lalt)]
    chk('C11', len(presentes) == 4,
        'niveles ESTRUCTURALES 0.045/2.78/2.92/3.00: %d/4 %s'
        % (len(presentes), presentes))

    n_abaco = n_remate = n_equino = 0
    for a, b, c in triangulos:
        zs = [p[1] for p in (a, b, c)]
        nz = normal_z(a, b, c)
        for z0, z1, cual in ((Z_ABACO_0, Z_ABACO_1, 'abaco'),
                             (Z_REMATE_0, Z_REMATE_1, 'remate')):
            if min(zs) < z0 - 1e-3 or max(zs) > z1 + 1e-3:
                continue
            if abs(min(zs) - z0) > 1e-3 or abs(max(zs) - z1) > 1e-3:
                continue
            if any(abs(z - z0) > 1e-3 and abs(z - z1) > 1e-3 for z in zs):
                continue
            if nz < 0.5:
                if cual == 'abaco':
                    n_abaco += 1
                else:
                    n_remate += 1
        cz = sum(zs) / 3.0
        if 2.55 < cz < 2.77 and nz < 0.9:
            n_equino += 1

    chk('C12', n_abaco >= e_abaco,
        'caras laterales completas ABACO=%d (medido %d, umbral >=%d)'
        % (n_abaco, e_abaco, e_abaco))
    chk('C13', n_remate >= e_remate,
        'caras laterales completas REMATE=%d (medido %d, umbral >=%d)'
        % (n_remate, e_remate, e_remate))
    chk('C14', n_equino >= 16,
        'caras laterales EQUINO=%d (medido %d, umbral >=16 de la hermana bpy)'
        % (n_equino, e_equino))

    mats_nombres = {m.get('name', '') for m in doc.get('materials', [])}
    chk('C15', mats_nombres == MATS,
        '4 materiales del capitel: %s' % sorted(mats_nombres))
    chk('C16', (total_tris == e_tris and len(mats_nombres) == e_mats
                and len(doc['meshes']) == e_mallas
                and len(puntos) == e_verts
                and total_tris <= PERFIL_TRIS[lod]),
        'M166 runtime: %d/%d tris <= %d, %d/%d mats, %d/%d mallas, %d/%d verts'
        % (total_tris, e_tris, PERFIL_TRIS[lod], len(mats_nombres), e_mats,
           len(doc['meshes']), e_mallas, len(puntos), e_verts))

    if lod == 'alta':
        estructura_ok = all(n in nombres_nodos for n in NODOS_ALTA)
        detalle = '13 nodos originales (Abaco/Plinto/Equino/Remate/Fuste)'
    else:
        estructura_ok = (all(n in nombres_nodos for n in NODOS_MERGE)
                         and len(nombres_nodos) == 5)
        detalle = '5 nodos del merge FASE 1 (3 grupos + 2 _NOFUNDIR)'
    chk('C17', estructura_ok and len(alcanzables) == e_mallas,
        'estructura %s: %s=%s nodos=%d/%d'
        % (lod, detalle, estructura_ok, len(alcanzables), e_mallas))

    niveles_capitel = sorted(v for v in lalt if v > 2.4)
    chk('C18', len(niveles_capitel) >= 5,
        'CAPITEL no colapsado: %d niveles por encima de 2.4 %s'
        % (len(niveles_capitel), niveles_capitel[:8]))

    d.update({'tris': total_tris, 'triangulos': len(triangulos),
              'vertices': len(puntos), 'materiales': len(mats_nombres),
              'mallas': len(doc['meshes']), 'nodos': len(alcanzables),
              'alt_min': round(ymin, 4), 'alt_max': round(ymax, 4),
              'huella': [round(fx, 4), round(fy, 4)],
              'apoyo_pares': len(pares), 'apoyo_verts': len(va),
              'abaco': n_abaco, 'remate': n_remate, 'equino': n_equino,
              'banda': banda, 'media_losa': media_losa,
              'niveles_alt': sorted(lalt), 'bytes': len(raw),
              'sha': sha12(path)})
    return checks, d


# ------------------------------------------------------------- inyeccion ----
def inyectar(src, dst):
    """Reproduce EN UNA COPIA el COLAPSO DEL ABACO de 2026-11-06.

    Mueve los vertices del plano alt=2.92 (tope del abaco / base del
    remate) a 2.8267, DENTRO de la banda anti-colapso (2.79, 2.91), y
    desplaza lateral +0.0133. Es el defecto real que la guardia bpy C9
    detectaba en el .blend. Rompe C10/C11/C12/C13/C18 y G2.
    El GLB publicado NO se toca.
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
                if abs(w[1] - Z_ABACO_1) < 1e-3:
                    nuevo = (w[0], 2.8267, w[2] + 0.0133)
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
        dst = os.path.join(TEMP, 'hy4_b28_rojo_20261113.glb')
        _, cambios = inyectar(src, dst)
        assert sha12(src) == publicado, 'la inyeccion toco el GLB publicado'
        print('INYECCION COLAPSO DEL ABACO: %d vertices mutados en %s | '
              'publicado sha=%s INTACTO' % (cambios, dst, publicado))
        paths[-1] = (paths[-1][0], dst)

    todos, datos = [], []
    print('=== FORMA DE RUNTIME: columna_entera M25 (3 GLB) ===')
    for lod, path in paths:
        checks, d = analizar(path, lod)
        todos.extend(checks)
        datos.append(d)
        print('%-5s tris=%-4d verts=%-4d mats=%d mallas=%-2d '
              'alt=[%.4f..%.4f] huella=%s apoyo=%d/%d '
              'abaco=%d remate=%d equino=%d banda=%d sha=%s'
              % (lod, d.get('tris', 0), d.get('vertices', 0),
                 d.get('materiales', 0), d.get('mallas', 0),
                 d.get('alt_min', 0), d.get('alt_max', 0),
                 d.get('huella', []), d.get('apoyo_pares', 0),
                 d.get('apoyo_verts', 0), d.get('abaco', 0),
                 d.get('remate', 0), d.get('equino', 0),
                 d.get('media_losa', 0), d.get('sha', '-')))
        if volcar:
            print('   Bloque %s: %d checks' % (lod, len(checks)))
            print('   niveles_alt=%s' % d.get('niveles_alt', []))

    por = {d['lod']: d for d in datos}
    todos.append(('G1', len(datos) == 3 and len(por) == 3,
                  'cobertura 3 LOD = %d bloques' % len(datos)))

    capitel_ok = (len(por) == 3
                  and all(por[k].get('abaco', 0) >= 4
                          and por[k].get('remate', 0) >= 4
                          and por[k].get('equino', 0) >= 16
                          and por[k].get('media_losa', 1) == 0
                          and not por[k].get('banda') for k in LODS))
    todos.append(('G2', capitel_ok,
                  'CAPITEL INTEGRO en los 3 GLB (abaco/remate/equino + '
                  'banda anti-colapso vacia)'))

    mono = (len(por) == 3
            and por['alta']['tris'] == por['media']['tris'] > por['baja']['tris']
            and por['alta']['mallas'] > por['media']['mallas']
            and por['media']['mallas'] == por['baja']['mallas']
            and (por['alta']['materiales'], por['media']['materiales'],
                 por['baja']['materiales']) == (4, 4, 4)
            and por['baja']['vertices'] < por['alta']['vertices'])
    todos.append(('G3', mono, 'LOD real por PODA deliberada (no por decimate)'))

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
        print('ROJO: la guardia detecto geometria fuera de forma en runtime')
        return 1
    print('VERDE: capitel integro en 3 GLB de runtime')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
