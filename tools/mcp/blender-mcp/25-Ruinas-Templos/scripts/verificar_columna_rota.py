#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Guardia POSITIVA de FORMA sobre los 6 GLB de runtime de `columna_rota`
(M25 / B27): 2 VARIANTES DE ALTURA x 3 LOD (ALTA / MEDIA / BAJA).

NO es QA §21.8 ni sello: es una guardia de AUTORIA sobre EL ARTEFACTO QUE
Godot consume. `chk_asset.py` mide COSTE, no FORMA (acta 28 / B12 / B13), y
la guardia hermana `verificar_columna_entera.py` trabaja sobre `.blend` con
bpy, NO sobre el GLB. Hasta B27 los 6 GLB de columna rota (exportados en
B10bis, log 2335) NO tenian NINGUNA verificacion sobre su BIN.

===========================================================================
POR QUE ESTA GUARDIA EXISTE (B27, 2026-11-13)
===========================================================================
El acuse 71 fijo la nueva COLA ACTIVA «Columnas M25 + Semillero + Palanca».
Medicion: los 3 items YA ESTAN EJECUTADOS y trackeados (9 GLB de columnas,
3 de cultivo_brote, 3 de palanca_madera). Lo pendiente son FLIPS del
director (REGLA CERO) y este HUECO DE VERIFICACION REAL: no existia
`verificar_columna_rota.py` en todo el repo. Hy4 no re-autora assets ni
aplica flips; aporta EVIDENCIA MEDIDA sobre el BIN para que el director
pueda flippear `02` L26/L27, COBJ L174/L175 y L50 con fundamento.

CHECK CLAVE: las «2 variantes de altura» del checklist NO pueden ser 2
copias. Medicion en el BIN: `columna_rota_alta` tope 2.1900 y
`columna_rota_baja` tope 1.4900 => diferencia EXACTA de 0.7000 m en los
3 LOD. G2 exige esa diferencia; C17 exige que cada GLB tenga la altura
que corresponde a su PROPIO nombre de variante (anti-confusion).

DERIVA HEREDADA PUBLICADA COMO DATO, NO CONSAGRADA: las variantes BAJA
tienen tope 2.1907 / 1.4907 (deriva +0.0007 m por decimate sobre cajas
disjuntas, familia B18 / acta 28) y niveles de altura espurios. La guardia
NO exige esos niveles: exige la FORMA ESENCIAL (altura dentro de 1e-3,
apoyo, silueta, materiales, LOD por poda) y publica la deriva en el acta.
No se re-autora ni se corrige el asset legacy sin GO.

EJES glTF Y-up: p[0]=X, p[1]=ALTURA (Z de Blender), p[2]=LATERAL.

Trampas evitadas: POSITION real + matrices COLUMN-MAJOR (M[c*4+r]),
inversa GENERAL 3x3 (Cramer) para inyectar, PISO medido EN VERDE antes de
fijarlo, un check que FALLA sigue contando como EJECUTADO, CIEGO = menos
bloques/checks (exit 3), ROJO sobre COPIA en Temp/ con GLB intactos.

Uso:
  python verificar_columna_rota.py             # VERDE (6 GLB)
  python verificar_columna_rota.py --piso 0    # mide el piso en verde
  python verificar_columna_rota.py --inyectar  # ROJO (confunde variantes)
  python verificar_columna_rota.py --solo <glb>  # CIEGO (exit 3)
  python verificar_columna_rota.py --volcar    # niveles de altura
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
VARIANTES = ('columna_rota_alta', 'columna_rota_baja')
BASE = {'columna_rota_alta': '25-Ruinas-Templos_columna_rota_alta.glb',
        'columna_rota_baja': '25-Ruinas-Templos_columna_rota_baja.glb'}

# MEDIDO EN VERDE con `--piso 0` ANTES de fijar la constante (regla:
# medir antes de escribir la cifra): CHECKS=114 PASADOS=114 FALLOS=0
# BLOQUES=6 RC=0. 18 checks x 6 GLB + 6 globales = 114.
CHECKS_MINIMOS = 114
BLOQUES_MINIMOS = 6

Y_APOYO = 0.045
TOL = 0.001           # 1 mm: absorbe la deriva +0.0007 del decimate legacy
DIF_VARIANTES = 0.7000
PERFIL_TRIS = {'alta': 6000, 'media': 1500, 'baja': 700}

# (tris, materiales, mallas, vertices, altura, tope, apoyo) MEDIDOS EN EL BIN
# por Temp/hy4_b27_glb_probe_20261113.py. Nada estimado.
ESPERADO = {
    'columna_rota_alta': {
        'alta':  (464, 5, 12, 857, 2.1450, 2.1900, 28),
        'media': (464, 5,  5, 857, 2.1450, 2.1900, 28),
        'baja':  (303, 4,  4, 605, 2.1457, 2.1907, 24),
    },
    'columna_rota_baja': {
        'alta':  (464, 5, 12, 857, 1.4450, 1.4900, 28),
        'media': (464, 5,  5, 857, 1.4450, 1.4900, 28),
        'baja':  (304, 4,  4, 626, 1.4457, 1.4907, 24),
    },
}
X_RANGE, LAT_RANGE = 1.4544, 1.0210
MAT_BASE = ('MAT_ColRota_CorteFresco', 'MAT_ColRota_Musgo',
            'MAT_ColRota_Piedra', 'MAT_ColRota_PiedraOsc')
MAT_PODABLE = 'MAT_ColRota_Glifo'
NODOS_CLAVE = ('SM_ColRota_Basa', 'SM_ColRota_Fuste', 'SM_ColRota_Corona')


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
def analizar(path, variante, lod):
    """Devuelve (checks, datos). Publica SIEMPRE 18 checks por GLB."""
    N = 18
    checks, d = [], {'path': path, 'variante': variante, 'lod': lod}

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
    xr, zr = max(xs) - min(xs), max(zs) - min(zs)
    ymin, ymax = min(ys), max(ys)
    altura = ymax - ymin
    lalt = {round(v, 4) for v in ys}

    e_tris, e_mats, e_mallas, e_verts, e_h, e_tope, e_apoyo = \
        ESPERADO[variante][lod]

    chk('C7', abs(ymin - Y_APOYO) <= TOL,
        'alt_min=%.4f (Z_APOYO=%.4f)' % (ymin, Y_APOYO))
    chk('C8', abs(ymax - e_tope) <= TOL,
        'tope=%.4f (esperado %.4f para %s/%s)' %
        (ymax, e_tope, variante, lod))
    chk('C9', abs(altura - e_h) <= TOL,
        'altura=%.4f (esperada %.4f); deriva decimate heredada <= %.3f'
        % (altura, e_h, TOL))

    apoyo = {(round(p[0], 4), round(p[2], 4)) for p in puntos
             if abs(p[1] - Y_APOYO) <= 1e-3}
    chk('C10', len(apoyo) == e_apoyo,
        'pares (x,lat) APOYADOS en alt=%.3f: %d (esperados %d)'
        % (Y_APOYO, len(apoyo), e_apoyo))

    clave = [t for t in (Y_APOYO, e_tope) if any(abs(w - t) < TOL for w in lalt)]
    chk('C11', len(clave) == 2,
        'niveles ESTRUCTURALES presentes (base %.3f + tope %.4f): %d/2'
        % (Y_APOYO, e_tope, len(clave)))

    mats_nombres = {m.get('name', '') for m in doc.get('materials', [])}
    chk('C12', (all(n in mats_nombres for n in MAT_BASE)
                and (MAT_PODABLE in mats_nombres) == (lod != 'baja')),
        '4 materiales base en los 3 LOD; %s solo ALTA/MEDIA: %s'
        % (MAT_PODABLE, MAT_PODABLE in mats_nombres))

    chk('C13', (total_tris == e_tris and len(doc.get('materials', [])) == e_mats
                and total_tris <= PERFIL_TRIS[lod]),
        'M166 runtime: %d/%d tris <= %d, %d/%d mats'
        % (total_tris, e_tris, PERFIL_TRIS[lod],
           len(doc.get('materials', [])), e_mats))
    chk('C14', len(doc['meshes']) == e_mallas,
        'mallas=%d (esperadas %d)' % (len(doc['meshes']), e_mallas))
    chk('C15', len(puntos) == e_verts,
        'vertices=%d (esperados %d)' % (len(puntos), e_verts))

    chk('C16', (abs(xr - X_RANGE) <= TOL and abs(zr - LAT_RANGE) <= TOL
                and xr >= 0.30 and zr >= 0.30),
        'HUELLA E-50: x=%.4f/%.4f lat=%.4f/%.4f (min 0.30)'
        % (xr, X_RANGE, zr, LAT_RANGE))

    # C17 ANTI-CONFUSION: cada GLB debe tener la altura de SU variante.
    otra = ('columna_rota_baja' if variante == 'columna_rota_alta'
            else 'columna_rota_alta')
    otro_tope = ESPERADO[otra][lod][5]
    chk('C17', (abs(ymax - e_tope) <= TOL
                and abs(ymax - otro_tope) > 0.10),
        'variante %s: tope=%.4f NO confundido con %s (%.4f)'
        % (variante, ymax, otra, otro_tope))

    # C18 mide la estructura REAL de cada LOD. MEDIDO 2026-11-13: la FASE 1
    # de generar_variante.py RENOMBRA los nodos a
    # `SM_ColRota_M_ColRota_<Material>`; exigir Basa/Fuste/Corona en MEDIA/
    # BAJA daba un FALSO ROJO (4 checks). No se relaja: se exige la forma
    # que cada LOD realmente tiene.
    if lod == 'alta':
        estructura_ok = all(k in nombres_nodos for k in NODOS_CLAVE)
        detalle = 'nodos originales Basa/Fuste/Corona'
    else:
        grupos = ['SM_ColRota_M_ColRota_%s' % m
                  for m in ('Piedra', 'CorteFresco', 'PiedraOsc', 'Musgo')]
        if lod == 'media':
            grupos.append('SM_ColRota_M_ColRota_Glifo')
        estructura_ok = all(g in nombres_nodos for g in grupos)
        detalle = 'grupos por material del merge (%d)' % len(grupos)
    chk('C18', estructura_ok and len(alcanzables) == e_mallas,
        'estructura %s: %s=%s nodos=%d/%d'
        % (lod, detalle, estructura_ok, len(alcanzables), e_mallas))

    d.update({'tris': total_tris, 'vertices': len(puntos),
              'materiales': len(doc.get('materials', [])),
              'mallas': len(doc['meshes']), 'nodos': len(alcanzables),
              'altura': round(altura, 4), 'tope': round(ymax, 4),
              'apoyo': len(apoyo), 'x_range': round(xr, 4),
              'lat_range': round(zr, 4), 'glifo': MAT_PODABLE in mats_nombres,
              'niveles_alt': sorted(lalt), 'bytes': len(raw),
              'sha': sha12(path)})
    return checks, d


# ------------------------------------------------------------- inyeccion ----
def inyectar(src, dst, tope):
    """Reproduce EN UNA COPIA una CONFUSION DE VARIANTES.

    Mueve -0.70 m (la diferencia entre variantes) los vertices que estan en
    el tope de la variante ALTA y desplaza lateral +0.0133. MEDIDO: 9
    vertices mutados; el tope RESULTANTE del GLB inyectado es 2.1649 (no
    1.4907) porque otros vertices del fuste quedan por encima. Aun asi
    G2 cae a 0.6742 y fallan C8/C9/C11/C17/G2/G6: la guardia detecta la
    CONFUSION DE VARIANTES, que es el riesgo real de «2 variantes de
    altura» que en verdad sean la misma. El GLB publicado NO se toca.
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
                if abs(w[1] - tope) < 1e-3:
                    nuevo = (w[0], w[1] - DIF_VARIANTES, w[2] + 0.0133)
                    struct.pack_into('<fff', bin_, off, *desaplicar(m, nuevo))
                    cambios += 1
    if cambios < 4:
        raise RuntimeError('inyeccion no reprodujo la confusion: %d vertices'
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
        nombre = os.path.basename(solo)
        variante = ('columna_rota_baja' if 'columna_rota_baja' in nombre
                    else 'columna_rota_alta')
        lod = os.path.basename(os.path.dirname(solo)).lower()
        paths = [(variante, lod, solo)]
    else:
        paths = [(v, l, os.path.join(GODOT, l, BASE[v]))
                 for v in VARIANTES for l in LODS]

    if rojo:
        variante, lod, src = paths[-1]
        # La inyeccion se aplica al bloque BAJA de la variante ALTA.
        variante, lod, src = 'columna_rota_alta', 'baja', \
            os.path.join(GODOT, 'baja', BASE['columna_rota_alta'])
        publicado = sha12(src)
        dst = os.path.join(TEMP, 'hy4_b27_rojo_20261113.glb')
        tope = ESPERADO[variante][lod][5]
        _, cambios = inyectar(src, dst, tope)
        assert sha12(src) == publicado, 'la inyeccion toco el GLB publicado'
        print('INYECCION CONFUSION DE VARIANTES: %d vertices mutados en %s '
              '| publicado sha=%s INTACTO' % (cambios, dst, publicado))
        paths = [(v, l, dst if (v, l) == (variante, lod) else p)
                 for v, l, p in paths]

    todos, datos = [], []
    print('=== FORMA DE RUNTIME: columna_rota M25 (6 GLB) ===')
    for variante, lod, path in paths:
        checks, d = analizar(path, variante, lod)
        todos.extend(checks)
        datos.append(d)
        print('%-19s %-5s tris=%-4d verts=%-4d mats=%d mallas=%-2d '
              'h=%.4f tope=%.4f apoyo=%-2d glifo=%s sha=%s'
              % (variante, lod, d.get('tris', 0), d.get('vertices', 0),
                 d.get('materiales', 0), d.get('mallas', 0),
                 d.get('altura', 0), d.get('tope', 0), d.get('apoyo', 0),
                 d.get('glifo', False), d.get('sha', '-')))
        if volcar:
            print('   Bloque %s/%s: %d checks' % (variante, lod, len(checks)))
            print('   niveles_alt=%s' % d.get('niveles_alt', []))

    por = {(d['variante'], d['lod']): d for d in datos}
    todos.append(('G1', len(datos) == 6 and len(por) == 6,
                  'cobertura 2 variantes x 3 LOD = %d bloques' % len(datos)))

    diffs = []
    for lod in LODS:
        a, b = por.get(('columna_rota_alta', lod)), por.get(('columna_rota_baja', lod))
        if a and b:
            diffs.append(a['tope'] - b['tope'])
    todos.append(('G2', len(diffs) == 3
                  and all(abs(v - DIF_VARIANTES) <= TOL for v in diffs),
                  '2 VARIANTES DE ALTURA: diferencia %.4f m en los 3 LOD %s'
                  % (DIF_VARIANTES, [round(v, 4) for v in diffs])))

    mono = all(
        por.get((v, 'alta')) and por.get((v, 'media')) and por.get((v, 'baja'))
        and por[(v, 'alta')]['tris'] == por[(v, 'media')]['tris']
        > por[(v, 'baja')]['tris']
        and por[(v, 'alta')]['mallas'] > por[(v, 'media')]['mallas']
        > por[(v, 'baja')]['mallas']
        and (por[(v, 'alta')]['materiales'], por[(v, 'media')]['materiales'],
             por[(v, 'baja')]['materiales']) == (5, 5, 4)
        for v in VARIANTES)
    todos.append(('G3', mono, 'LOD real por PODA deliberada en las 2 variantes'))

    glifo_ok = all(por.get((v, l)) and
                   (por[(v, l)]['glifo'] == (l != 'baja'))
                   for v in VARIANTES for l in LODS)
    todos.append(('G4', glifo_ok,
                  'MAT_ColRota_Glifo solo en ALTA/MEDIA (4/2 variantes)'))

    shas = [d.get('sha') for d in datos]
    todos.append(('G5', len(shas) == 6 and len(set(shas)) == 6,
                  '6 GLB con sha DISTINTO (no 2 copias de la misma variante)'))

    consist = all(abs(por[(v, 'alta')]['altura'] - por[(v, l)]['altura']) <= TOL
                  for v in VARIANTES for l in LODS
                  if por.get((v, 'alta')) and por.get((v, l)))
    todos.append(('G6', consist,
                  'altura de cada variante CONSISTENTE en los 3 LOD '
                  '(deriva decimate <= %.3f m, no colapso)' % TOL))

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
    print('VERDE: 2 variantes de altura de columna_rota en 6 GLB de runtime')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
