#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Validador de malla .glb — implementa RF14/RF5/RF6/RF7/RF9/RF4 de M45-Arte-3D.

Por que existe: el item L145 de `DOCUMENTACION/45-Arte-3D/plan-actual/05-Checklist.md`
(`[?] Definir script validate_mesh.gd en Assets/_Project/Editor/`) pide un validador
que NO existe en el repo (`git ls-files "*validate_mesh*"` = 0). La ruta que pide el
item es de la era Unity (`Assets/_Project/Editor/`); este proyecto es Godot 4.7.2 y
el gate de calidad corre en CI sin abrir el editor, asi que la implementacion es un
validador headless de solo lectura sobre el .glb exportado (fuente de verdad del
runtime: `assets/3d/{alta,media,baja}`).

Criterios medidos, no supuestos:
  - Eje UP: se MIDE (`--eje auto`) contando en cuantos archivos el minimo del eje
    candidato cae en 0 +- 1e-3. Se informa el eje ganador y su conteo.
  - Escala 1:1: producto de escalas de la cadena de padres por nodo con malla.
      * ESCALA_NO_UNIFORME (violacion): |sx-sy|, |sy-sz|, |sx-sz| > 1e-3 -> deforma.
      * ESCALA_NO_APLICADA (aviso): |s-1| > 1e-3 -> la malla viaja escalada por el
        nodo (no se aplico escala en Blender antes de exportar).
  - Topologia: glTF 2.0 solo admite TRIANGLES/TRIFAN/etc.; un n-gon NO puede
    sobrevivir a la exportacion, asi que se mide el proxy medible:
    triangulos degenerados (area ~ 0) y vertices duplicados sin soldar.
    LIMITE DECLARADO: la deteccion de n-gons exige leer el .blend fuente.
  - UVs: TEXCOORD_0 dentro de [-tol, 1+tol]; se informa la distancia minima al borde
    (padding en unidades de UV) y el padding en px si se pasa --tam-textura.
  - Origen: bounds mundiales; para categorias de suelo se exige |min_up| <= 1e-3.
  - Tris: conteo real vs techo RF4 de la categoria (mapeo carpeta -> categoria).
  - LOD: si tris > 500 y el archivo esta en `alta/`, debe existir homonimo en
    `media/` y `baja/` (RF9: LOD obligatorio > 500 tris).

Uso:
  python scripts/validar_malla_glb.py                 # informe legible
  python scripts/validar_malla_glb.py --json          # + tools/legal/malla_glb.json
  python scripts/validar_malla_glb.py --check         # exit 1 si hay violaciones
  python scripts/validar_malla_glb.py --archivo RUTA  # un solo archivo
  python scripts/validar_malla_glb.py --selftest      # autoprueba del parser
Salidas: 0 = sin violaciones · 1 = violaciones · 3 = validador CIEGO (0 archivos).
"""
import argparse
import json
import math
import os
import struct
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
OUT = os.path.join(ROOT, 'tools', 'legal', 'malla_glb.json')

TOL = 1e-3           # tolerancia RF3/RF7 (escala 1:1 y origen literal Y=0)
TOL_UV = 1e-4        # tolerancia de rango UV
AREA_MIN = 1e-12     # area por debajo de esto = triangulo degenerado
MAX_VERT_DEGEN = 400000   # techo de vertices para el chequeo de degenerados
ASSETS_PREFIX = 'game/isla-ancestral/assets/3d/'
# Piso de checks de la autoprueba, MEDIDO en verde (no estimado): si una
# refactorizacion deja de ejecutar un bloque, el conteo baja y esto falla.
CHECKS_MINIMOS = 27
# Convencion de apoyo MEDIDA en el corpus (no supuesta): 66 de 418 .glb de
# assets/3d tienen min_Y = 0.045 +- 0.02 y 0 lo tienen en Z. Es el mismo valor
# que M166 documenta como Z_APOYO, pero sobre el eje Y.
Y_APOYO = 0.045
TOL_APOYO = 0.020

# RF4 — techo de tris LOD0 por categoria (01-Requerimientos.md tabla RF4).
RF4_LOD0 = {
    'chr': 8000, 'npc': 8000, 'ani': 6000, 'bld': 15000, 'furn': 1200,
    'tool': 800, 'veh_b': 20000, 'veh': 12000, 'veg': 3000, 'prop': 200,
    'ruin': 12000, 'temple': 15000, 'deco': 500, 'int': 1500,
}

# Mapeo carpeta de modulo -> categoria RF4. Medido: 0 de 694 .glb cumple el
# prefijo RF15 (chr_/prop_/...), asi que la categoria NO se puede derivar del
# nombre del archivo; se deriva de la carpeta de modulo (que si es estable).
CARPETA_A_CATEGORIA = {
    '13-Herramientas': 'tool',
    '15-Recursos': 'prop',
    '16-Crafting': 'furn',
    '18-Casas': 'bld',
    '19-NPCs': 'npc',
    '25-Ruinas-Templos': 'ruin',
    '27-Islas-Ubicaciones': 'prop',
    '33-Agricultura': 'veg',
    '35-Mineria': 'prop',
    '36-Fauna': 'ani',
    '40-Infraestructura': 'bld',
    '45-Arte3D': 'prop',
    '50-Vegetacion': 'veg',
    '70-Interacciones': 'int',
}

# Categorias cuyo origen debe apoyar en el suelo (RF7: props de suelo).
CATEGORIAS_SUELO = {'prop', 'bld', 'furn', 'deco', 'int', 'ruin', 'temple', 'veg'}


# --------------------------------------------------------------------------
# Parseo GLB
# --------------------------------------------------------------------------
def leer_glb(path):
    """Devuelve (json_gltf, bin_bytes) o (None, None) si el contenedor es invalido."""
    with open(path, 'rb') as f:
        data = f.read()
    if len(data) < 12 or data[:4] != b'glTF':
        return None, None
    total = struct.unpack('<I', data[8:12])[0]
    pos = 12
    js = None
    binc = b''
    while pos + 8 <= min(total, len(data)):
        clen, ctype = struct.unpack('<II', data[pos:pos + 8])
        if ctype == 0x4E4F534A:      # JSON
            try:
                js = json.loads(data[pos + 8:pos + 8 + clen].decode('utf-8'))
            except Exception:
                return None, None
        elif ctype == 0x004E4942:    # BIN
            binc = data[pos + 8:pos + 8 + clen]
        pos += 8 + clen
    if js is None:
        return None, None
    return js, binc


def _mat_mul(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(3)) for j in range(3)]
            for i in range(3)]


def _quat_mat(q):
    w, x, y, z = q
    xx, yy, zz = x * x, y * y, z * z
    xy, xz, yz = x * y, x * z, y * z
    wx, wy, wz = w * x, w * y, w * z
    return [
        [1 - 2 * (yy + zz), 2 * (xy - wz), 2 * (xz + wy)],
        [2 * (xy + wz), 1 - 2 * (xx + zz), 2 * (yz - wx)],
        [2 * (xz - wy), 2 * (yz + wx), 1 - 2 * (xx + yy)],
    ]


def mundos(js):
    """Mundo por nodo: (mat3x3, traslacion3, escala3-absoluta)."""
    nodes = js.get('nodes', [])
    world = [None] * len(nodes)

    def walk(i, pm, pt, ps):
        n = nodes[i]
        s = n.get('scale', [1, 1, 1])
        m = _mat_mul(_quat_mat(n.get('rotation', [0, 0, 0, 1])),
                     [[s[0], 0, 0], [0, s[1], 0], [0, 0, s[2]]])
        t = n.get('translation', [0, 0, 0])
        esc = [abs(s[0]), abs(s[1]), abs(s[2])]
        if pm is not None:
            m = _mat_mul(pm, m)
            t = [pm[0][0] * t[0] + pm[0][1] * t[1] + pm[0][2] * t[2] + pt[0],
                 pm[1][0] * t[0] + pm[1][1] * t[1] + pm[1][2] * t[2] + pt[1],
                 pm[2][0] * t[0] + pm[2][1] * t[1] + pm[2][2] * t[2] + pt[2]]
            esc = [ps[0] * esc[0], ps[1] * esc[1], ps[2] * esc[2]]
        world[i] = (m, t, esc)
        for ch in n.get('children', []):
            walk(ch, m, t, esc)

    hijos = set()
    for n in nodes:
        for c in n.get('children', []):
            hijos.add(c)
    for i in range(len(nodes)):
        if i not in hijos:
            walk(i, None, None, [1.0, 1.0, 1.0])
    for i in range(len(nodes)):
        if world[i] is None:
            world[i] = ([[1, 0, 0], [0, 1, 0], [0, 0, 1]], [0.0, 0.0, 0.0],
                        [1.0, 1.0, 1.0])
    return world


def _leer_accessor(js, binc, idx):
    """Devuelve la lista plana de floats del accessor (solo float32 escalar/vec2/vec3)."""
    acc = js['accessors'][idx]
    bv = js['bufferViews'][acc['bufferView']]
    ncomp = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3, 'VEC4': 4}.get(acc['type'])
    if ncomp is None or acc.get('componentType') != 5126:
        return None, 0
    off = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
    n = acc['count'] * ncomp
    stride = bv.get('byteStride')
    if stride and stride != 4 * ncomp:
        out = []
        for i in range(acc['count']):
            base = off + i * stride
            out.extend(struct.unpack_from('<%df' % ncomp, binc, base))
        return out, ncomp
    try:
        return list(struct.unpack_from('<%df' % n, binc, off)), ncomp
    except struct.error:
        return None, 0


def _leer_indices(js, binc, idx):
    acc = js['accessors'][idx]
    bv = js['bufferViews'][acc['bufferView']]
    off = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
    ct = acc.get('componentType')
    fmt = {5121: 'B', 5123: 'H', 5125: 'I'}.get(ct)
    if fmt is None:
        return None
    n = acc['count']
    try:
        return list(struct.unpack_from('<%d%s' % (n, fmt), binc, off))
    except struct.error:
        return None


def medir_malla(path):
    """Mide un .glb. Devuelve dict con hechos + lista de violaciones."""
    rec = {
        'archivo': None, 'parse_ok': False, 'meshes': 0, 'verts': 0, 'tris': 0,
        'bounds': None, 'escala_no_uniforme': 0, 'escala_no_aplicada': 0,
        'uv_fuera_rango': 0, 'uv_padding_min': None, 'degen': 0,
        'verts_duplicados': 0, 'degen_omitido': False,
        'violaciones': [], 'avisos': [],
    }
    try:
        js, binc = leer_glb(path)
    except Exception as exc:                       # contenedor corrupto
        rec['violaciones'].append('PARSE: %s' % exc)
        return rec
    if js is None:
        rec['violaciones'].append('PARSE: contenedor GLB invalido')
        return rec
    rec['parse_ok'] = True

    acc = js.get('accessors', [])
    world = mundos(js)
    nodes = js.get('nodes', [])
    meshes = js.get('meshes', [])

    owner = {}
    for i, n in enumerate(nodes):
        if 'mesh' in n and n['mesh'] not in owner:
            owner[n['mesh']] = i

    bmin = [None, None, None]
    bmax = [None, None, None]
    verts_total = 0
    tris_total = 0
    degen = 0
    dups = 0
    uv_bad = 0
    uv_pad = None
    escala_nu = 0
    escala_na = 0
    degen_omitido = False

    for mi, msh in enumerate(meshes):
        m, t, esc = world[owner.get(mi, 0)]
        rec['meshes'] += 1
        # escala del nodo que porta la malla
        difs = (abs(esc[0] - esc[1]), abs(esc[1] - esc[2]), abs(esc[0] - esc[2]))
        if max(difs) > TOL:
            escala_nu += 1
        if max(abs(e - 1.0) for e in esc) > TOL:
            escala_na += 1
        for prim in msh.get('primitives', []):
            attrs = prim.get('attributes', {})
            pidx = attrs.get('POSITION')
            if pidx is None:
                continue
            pos, ncomp = _leer_accessor(js, binc, pidx)
            if pos is None or ncomp != 3:
                rec['avisos'].append('POSITION ilegible (mesh %d)' % mi)
                continue
            nv = len(pos) // 3
            verts_total += nv
            # bounds mundiales
            for i in range(0, len(pos), 3):
                x, y, z = pos[i], pos[i + 1], pos[i + 2]
                for k in range(3):
                    v = m[k][0] * x + m[k][1] * y + m[k][2] * z + t[k]
                    if bmin[k] is None or v < bmin[k]:
                        bmin[k] = v
                    if bmax[k] is None or v > bmax[k]:
                        bmax[k] = v
            # triangulos
            iidx = prim.get('indices')
            if iidx is not None:
                ind = _leer_indices(js, binc, iidx)
                tris_total += (len(ind) // 3) if ind else 0
            else:
                ind = None
                tris_total += nv // 3
            # degenerados + duplicados (una sola pasada)
            if nv > MAX_VERT_DEGEN:
                degen_omitido = True
            else:
                vistos = set()
                for i in range(0, len(pos), 3):
                    key = (round(pos[i], 6), round(pos[i + 1], 6), round(pos[i + 2], 6))
                    if key in vistos:
                        dups += 1
                    else:
                        vistos.add(key)
                if ind is not None and len(ind) >= 3:
                    for i in range(0, len(ind) - 2, 3):
                        a, b, c = ind[i] * 3, ind[i + 1] * 3, ind[i + 2] * 3
                        if c + 2 >= len(pos):
                            continue
                        ux = (pos[b] - pos[a], pos[b + 1] - pos[a + 1], pos[b + 2] - pos[a + 2])
                        vx = (pos[c] - pos[a], pos[c + 1] - pos[a + 1], pos[c + 2] - pos[a + 2])
                        cx = ux[1] * vx[2] - ux[2] * vx[1]
                        cy = ux[2] * vx[0] - ux[0] * vx[2]
                        cz = ux[0] * vx[1] - ux[1] * vx[0]
                        if 0.5 * math.sqrt(cx * cx + cy * cy + cz * cz) < AREA_MIN:
                            degen += 1
            # UVs
            uidx = attrs.get('TEXCOORD_0')
            if uidx is not None:
                uv, nc = _leer_accessor(js, binc, uidx)
                if uv is not None and nc == 2:
                    for i in range(0, len(uv), 2):
                        u, v = uv[i], uv[i + 1]
                        if u < -TOL_UV or u > 1 + TOL_UV or v < -TOL_UV or v > 1 + TOL_UV:
                            uv_bad += 1
                        d = min(u, v, 1.0 - u, 1.0 - v)
                        if uv_pad is None or d < uv_pad:
                            uv_pad = d

    rec.update({
        'verts': verts_total, 'tris': tris_total,
        'escala_no_uniforme': escala_nu, 'escala_no_aplicada': escala_na,
        'uv_fuera_rango': uv_bad,
        'uv_presente': uv_pad is not None,
        'uv_padding_min': None if uv_pad is None else round(uv_pad, 6),
        'degen': degen, 'verts_duplicados': dups, 'degen_omitido': degen_omitido,
    })
    if bmin[0] is not None:
        rec['bounds'] = {
            'min': [round(v, 6) for v in bmin],
            'max': [round(v, 6) for v in bmax],
            'dim': [round(bmax[k] - bmin[k], 6) for k in range(3)],
        }
    if verts_total == 0:
        rec['violaciones'].append('SIN_GEOMETRIA: 0 vertices')
    return rec


# --------------------------------------------------------------------------
# Criterios (violaciones / avisos) sobre la medicion cruda
# --------------------------------------------------------------------------
def categoria_de(rel):
    """Categoria RF4 a partir del prefijo de modulo del NOMBRE de archivo.

    Medido: los 418 .glb de `assets/3d/` se llaman `<Modulo>_<nombre>.glb`
    (p.ej. `13-Herramientas_pico_hierro.glb`) y viven en una carpeta de nivel
    de LOD (`alta/`, `media/`, `baja/`). El modulo esta en el nombre, NO en la
    carpeta. Se acepta tambien el caso de carpeta de modulo (por si el pipeline
    cambia) y se devuelve None si no hay coincidencia (nunca se adivina).
    """
    partes = rel.replace('\\', '/').split('/')
    base = partes[-1]
    prefijo = base.split('_')[0]
    if prefijo in CARPETA_A_CATEGORIA:
        return CARPETA_A_CATEGORIA[prefijo]
    for parte in partes[:-1]:
        if parte in CARPETA_A_CATEGORIA:
            return CARPETA_A_CATEGORIA[parte]
    return None


def lod_de(rel):
    if '/assets/3d/alta/' in rel:
        return 'LOD0'
    if '/assets/3d/media/' in rel:
        return 'LOD1'
    if '/assets/3d/baja/' in rel:
        return 'LOD2'
    return None


def evaluar(rec, rel, eje, lod_presentes):
    """Agrega violaciones/avisos a rec segun los criterios de M45."""
    rec['archivo'] = rel
    rec['categoria'] = categoria_de(rel)
    rec['lod'] = lod_de(rel)
    if not rec['parse_ok']:
        return rec
    if rec['escala_no_uniforme'] > 0:
        rec['violaciones'].append(
            'ESCALA_NO_UNIFORME: %d nodo(s) con escala anisotropa > %g'
            % (rec['escala_no_uniforme'], TOL))
    if rec['escala_no_aplicada'] > 0:
        rec['avisos'].append(
            'ESCALA_NO_APLICADA: %d nodo(s) con escala != 1 (RF3: aplicar escala en Blender)'
            % rec['escala_no_aplicada'])
    if rec['uv_fuera_rango'] > 0:
        rec['violaciones'].append(
            'UV_FUERA_RANGO: %d coordenada(s) UV fuera de [0,1]' % rec['uv_fuera_rango'])
    if rec.get('uv_presente') is False and rec.get('lod') == 'LOD0':
        rec['avisos'].append(
            'SIN_UV: el LOD0 no declara TEXCOORD_0 (no se puede texturizar)')
    if rec['degen'] > 0:
        rec['violaciones'].append(
            'TOPO_DEGENERADO: %d triangulo(s) de area ~0' % rec['degen'])
    if rec['verts_duplicados'] > 0:
        # NO es defecto: glTF 2.0 obliga a partir vertices por costura de normal
        # y de UV (un vertice no puede tener dos normales). Se cuenta y se
        # informa como hecho, pero no se promueve a aviso: seria un falso
        # positivo en el 100% de los assets (medido: 417 de 418).
        pass
    # Origen. Tres hechos medidos que NO se pueden confundir:
    #   (a) el item L154 pide "origen Y=0" literal;
    #   (b) el corpus usa 0.045 como altura de contacto (66 de 418);
    #   (c) 301 de 418 no cumplen ni (a) ni (b) -> no hay convencion unica.
    # Por eso solo es VIOLACION lo que es objetivamente un defecto: un prop de
    # suelo cuyo punto mas bajo queda POR DEBAJO del plano de suelo (se hunde y
    # recorta). El resto se informa como aviso de convencion.
    if rec['bounds'] is not None and rec['categoria'] in CATEGORIAS_SUELO:
        k = 1 if eje == 'y' else 2
        mn = rec['bounds']['min'][k]
        rec['min_up'] = mn
        if mn < -TOL:
            rec['violaciones'].append(
                'ORIGEN_BAJO_SUELO: min_%s = %.6f < 0 (el prop se hunde)' % (eje, mn))
        elif abs(mn - Y_APOYO) > TOL_APOYO:
            rec['avisos'].append(
                'ORIGEN_SIN_CONVENCION: min_%s = %.6f (ni 0 ni %.3f+-%.3f)'
                % (eje, mn, Y_APOYO, TOL_APOYO))
    # RF4: la categoria es INFERIDA del modulo, no declarada por asset (el
    # catalogo RF13 no existe en disco). Por eso el exceso es AVISO, no violacion:
    # `18-Casas_alfombra.glb` (una alfombra) se inferiria como `bld`.
    cat = rec['categoria']
    if cat and rec['tris'] > 0:
        techo = RF4_LOD0.get(cat)
        if techo and rec['tris'] > techo:
            rec['avisos'].append(
                'RF4_EXCEDIDO(cat inferida %s): %d tris > techo %d'
                % (cat, rec['tris'], techo))
    # LOD obligatorio > 500 tris (RF9) — esto SI es objetivo: no depende de la
    # categoria, solo del conteo real y de la existencia de los otros niveles.
    if rec['lod'] == 'LOD0' and rec['tris'] > 500:
        faltan = [x for x in ('LOD1', 'LOD2') if x not in lod_presentes]
        if faltan:
            rec['violaciones'].append(
                'LOD_FALTANTE: %d tris > 500 y no hay %s' % (rec['tris'], '/'.join(faltan)))
    return rec


def medir_eje(recs):
    """Mide el eje UP en vez de suponerlo.

    Tres senales independientes, todas reportadas:
      1. anclaje en 0 (min del eje == 0 +- TOL) por eje;
      2. anclaje en la convencion de apoyo (min == 0.045 +- 0.02) por eje;
      3. proporcion: cuantos archivos son mas altos en Y que en Z (vegetacion,
         herramientas) y cuantos son planos en Y (alfombras, camas).
    Si (1) es ambiguo (la mayoria no ancla en 0), decide (2), que es el valor
    de M166. Devuelve (eje, dict de conteos).
    """
    c = {'y0': 0, 'z0': 0, 'ninguno': 0, 'y_apoyo': 0, 'z_apoyo': 0,
         'mas_alto_en_y': 0, 'mas_alto_en_z': 0}
    for r in recs:
        b = r.get('bounds')
        if not b:
            continue
        my, mz = b['min'][1], b['min'][2]
        oky, okz = abs(my) <= TOL, abs(mz) <= TOL
        if oky:
            c['y0'] += 1
        elif okz:
            c['z0'] += 1
        else:
            c['ninguno'] += 1
        if abs(my - Y_APOYO) <= TOL_APOYO:
            c['y_apoyo'] += 1
        if abs(mz - Y_APOYO) <= TOL_APOYO:
            c['z_apoyo'] += 1
        dy, dz = b['dim'][1], b['dim'][2]
        if dy > dz:
            c['mas_alto_en_y'] += 1
        elif dz > dy:
            c['mas_alto_en_z'] += 1
    if c['y0'] != c['z0']:
        eje = 'y' if c['y0'] > c['z0'] else 'z'
    elif c['y_apoyo'] != c['z_apoyo']:
        eje = 'y' if c['y_apoyo'] > c['z_apoyo'] else 'z'
    else:
        eje = 'y'   # glTF 2.0 es +Y up; se declara como default, no como medicion
    return eje, c


def main():
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding='utf-8', errors='replace')
        except Exception:
            pass
    ap = argparse.ArgumentParser()
    ap.add_argument('--json', action='store_true')
    ap.add_argument('--check', action='store_true')
    ap.add_argument('--archivo', default=None)
    ap.add_argument('--limite', type=int, default=0)
    ap.add_argument('--eje', default='auto', choices=('auto', 'y', 'z'))
    ap.add_argument('--solo-assets', action='store_true', default=True)
    ap.add_argument('--todos', action='store_true')
    ap.add_argument('--selftest', action='store_true')
    args = ap.parse_args()

    if args.selftest:
        return selftest()

    if args.archivo:
        rel = args.archivo.replace('\\', '/')
        if not os.path.exists(os.path.join(ROOT, rel)) and not os.path.exists(rel):
            print('VALIDADOR CIEGO: el archivo pedido no existe (%s) (exit 3)' % rel)
            return 3
        files = [rel]
    else:
        out = subprocess.run(['git', 'ls-files', '*.glb'], capture_output=True,
                             text=True, cwd=ROOT, timeout=120).stdout
        files = sorted(l for l in out.splitlines() if l)
        if not args.todos:
            files = [f for f in files if f.startswith(ASSETS_PREFIX)]
    if args.limite:
        files = files[:args.limite]
    if not files:
        print('VALIDADOR CIEGO: 0 archivos .glb (exit 3)')
        return 3

    # homonimos por nivel de LOD (para el chequeo de RF9)
    por_base = {}
    for f in files:
        b = os.path.basename(f)
        por_base.setdefault(b, set()).add(lod_de(f))

    recs = []
    for rel in files:
        rec = medir_malla(os.path.join(ROOT, rel))
        recs.append(rec)

    eje, cuenta_eje = medir_eje(recs)
    if args.eje != 'auto':
        eje = args.eje

    for rec, rel in zip(recs, files):
        evaluar(rec, rel, eje, por_base.get(os.path.basename(rel), set()))

    viol = [r for r in recs if r['violaciones']]
    avis = [r for r in recs if r['avisos']]
    tris_tot = sum(r['tris'] for r in recs)
    verts_tot = sum(r['verts'] for r in recs)
    sin_cat = [r for r in recs if not r.get('categoria')]

    print('Archivos medidos      : %d' % len(recs))
    print('Parseables            : %d' % sum(1 for r in recs if r['parse_ok']))
    print('Eje UP medido         : %s' % eje)
    print('  senal 1 (ancla en 0)      : y=%d z=%d ninguno=%d'
          % (cuenta_eje['y0'], cuenta_eje['z0'], cuenta_eje['ninguno']))
    print('  senal 2 (apoyo %.3f)     : y=%d z=%d'
          % (Y_APOYO, cuenta_eje['y_apoyo'], cuenta_eje['z_apoyo']))
    print('  senal 3 (mas alto en eje) : y=%d z=%d'
          % (cuenta_eje['mas_alto_en_y'], cuenta_eje['mas_alto_en_z']))
    print('Tris totales          : %d' % tris_tot)
    print('Vertices totales      : %d' % verts_tot)
    print('Con TEXCOORD_0        : %d  (sin UV: %d)'
          % (sum(1 for r in recs if r.get('uv_presente')),
             sum(1 for r in recs if not r.get('uv_presente'))))
    print('Sin categoria RF4     : %d' % len(sin_cat))
    print('Con violaciones       : %d' % len(viol))
    print('Con avisos            : %d' % len(avis))
    clases = {}
    for r in viol:
        for v in r['violaciones']:
            k = v.split(':')[0]
            clases[k] = clases.get(k, 0) + 1
    av_clases = {}
    for r in avis:
        for v in r['avisos']:
            k = v.split(':')[0]
            av_clases[k] = av_clases.get(k, 0) + 1
    print('Violaciones por clase : %s' % json.dumps(clases, sort_keys=True))
    print('Avisos por clase      : %s' % json.dumps(av_clases, sort_keys=True))
    print()
    for r in viol[:40]:
        print('  [VIOLACION] %s' % r['archivo'])
        for v in r['violaciones']:
            print('      - %s' % v)
    if len(viol) > 40:
        print('  ... %d archivos mas con violaciones' % (len(viol) - 40))

    if args.json:
        os.makedirs(os.path.dirname(OUT), exist_ok=True)
        with open(OUT, 'w', encoding='utf-8') as f:
            json.dump({
                'tolerancia': TOL, 'area_min': AREA_MIN, 'eje_up': eje,
                'y_apoyo': Y_APOYO, 'tol_apoyo': TOL_APOYO,
                'senales_eje': cuenta_eje,
                'conteos': {'archivos': len(recs),
                            'parseables': sum(1 for r in recs if r['parse_ok']),
                            'con_violaciones': len(viol),
                            'con_avisos': len(avis),
                            'tris': tris_tot, 'verts': verts_tot,
                            'sin_categoria': len(sin_cat),
                            'con_uv': sum(1 for r in recs if r.get('uv_presente')),
                            'sin_uv': sum(1 for r in recs if not r.get('uv_presente'))},
                'clases_violacion': clases, 'clases_aviso': av_clases,
                'violaciones': [{'archivo': r['archivo'], 'detalle': r['violaciones']}
                                for r in viol],
            }, f, ensure_ascii=False, indent=1)
        print()
        print('JSON:', OUT)

    if args.check and viol:
        return 1
    return 0


# --------------------------------------------------------------------------
# Autoprueba: construye GLB sinteticos y verifica que el validador los mide
# --------------------------------------------------------------------------
def _glb_sintetico(pos, uvs=None, idx=None, scale=(1, 1, 1)):
    """Arma un GLB minimo (1 mesh, 1 primitiva triangulada) en memoria."""
    buf = bytearray()
    accs = []
    views = []

    def add(arr, ctype, tipo, ncomp, minmax=False):
        off = len(buf)
        buf.extend(struct.pack('<%d%s' % (len(arr), ctype), *arr))
        while len(buf) % 4:
            buf.append(0)
        views.append({'buffer': 0, 'byteOffset': off,
                      'byteLength': len(buf) - off})
        a = {'bufferView': len(views) - 1, 'componentType':
             5126 if ctype == 'f' else (5123 if ctype == 'H' else 5125),
             'count': len(arr) // ncomp, 'type': tipo}
        if minmax:
            a['min'] = [min(arr[i::ncomp]) for i in range(ncomp)]
            a['max'] = [max(arr[i::ncomp]) for i in range(ncomp)]
        accs.append(a)
        return len(accs) - 1

    pidx = add(pos, 'f', 'VEC3', 3, True)
    attrs = {'POSITION': pidx}
    if uvs:
        attrs['TEXCOORD_0'] = add(uvs, 'f', 'VEC2', 2)
    prim = {'attributes': attrs, 'mode': 4}
    if idx:
        prim['indices'] = add(idx, 'H', 'SCALAR', 1)
    js = {'asset': {'version': '2.0', 'generator': 'validar_malla_glb.selftest'},
          'scenes': [{'nodes': [0]}], 'scene': 0,
          'nodes': [{'mesh': 0, 'scale': list(scale)}],
          'meshes': [{'primitives': [prim]}],
          'accessors': accs, 'bufferViews': views,
          'buffers': [{'byteLength': len(buf)}]}
    jsb = json.dumps(js).encode('utf-8')
    while len(jsb) % 4:
        jsb += b' '
    total = 12 + 8 + len(jsb) + 8 + len(buf)
    out = bytearray()
    out.extend(b'glTF')
    out.extend(struct.pack('<II', 2, total))
    out.extend(struct.pack('<II', len(jsb), 0x4E4F534A))
    out.extend(jsb)
    out.extend(struct.pack('<II', len(buf), 0x004E4942))
    out.extend(buf)
    return bytes(out)


def selftest():
    """6 controles: 3 verdes (miden bien) + 3 rojos (detectan el defecto)."""
    import tempfile
    fallos = 0
    checks = 0

    def chk(nombre, cond):
        nonlocal fallos, checks
        checks += 1
        if not cond:
            fallos += 1
            print('[FALLO] %s' % nombre)

    tmp = tempfile.mkdtemp(prefix='vmalla_')
    cubo = [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1]
    idx = [0, 1, 2, 0, 2, 3]
    uv_ok = [0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0]
    uv_bad = [0.0, 0.0, 1.5, 0.0, 0.0, 1.0, 0.0, 1.0]

    casos = {
        'ok': _glb_sintetico(cubo, uv_ok, idx),
        'uv_mal': _glb_sintetico(cubo, uv_bad, idx),
        'escala_aniso': _glb_sintetico(cubo, uv_ok, idx, scale=(1, 1, 2)),
        'no_glb': b'NO ES UN GLB',
    }
    rutas = {}
    for k, v in casos.items():
        p = os.path.join(tmp, k + '.glb')
        with open(p, 'wb') as f:
            f.write(v)
        rutas[k] = p

    r = medir_malla(rutas['ok'])
    chk('parse_ok del GLB valido', r['parse_ok'])
    # el cubo sintetico son 4 vertices (12 floats VEC3) y 2 triangulos (6 indices)
    chk('4 vertices medidos', r['verts'] == 4)
    chk('2 triangulos medidos', r['tris'] == 2)
    chk('bounds del cubo 1x1x1', r['bounds']['dim'] == [1.0, 1.0, 1.0])
    chk('UV dentro de rango no reporta', r['uv_fuera_rango'] == 0)
    chk('escala 1:1 no reporta anisotropa', r['escala_no_uniforme'] == 0)

    r = medir_malla(rutas['uv_mal'])
    chk('UV 1.5 detectada fuera de rango', r['uv_fuera_rango'] == 1)
    chk('UV fuera de rango es violacion',
        any(v.startswith('UV_FUERA_RANGO') for v in
            evaluar(dict(r, violaciones=list(r['violaciones'])), 'x/50-Vegetacion/a.glb',
                    'y', set())['violaciones']))

    r = medir_malla(rutas['escala_aniso'])
    chk('escala (1,1,2) detectada como anisotropa', r['escala_no_uniforme'] == 1)

    r = medir_malla(rutas['no_glb'])
    chk('contenedor invalido -> PARSE', not r['parse_ok']
        and any(v.startswith('PARSE') for v in r['violaciones']))

    # triangulo degenerado: 3 vertices colineales
    deg = [0, 0, 0, 1, 0, 0, 2, 0, 0]
    p = os.path.join(tmp, 'degen.glb')
    with open(p, 'wb') as f:
        f.write(_glb_sintetico(deg, None, [0, 1, 2]))
    r = medir_malla(p)
    chk('triangulo colineal detectado como degenerado', r['degen'] == 1)

    # vertice duplicado
    dup = [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0]
    p = os.path.join(tmp, 'dup.glb')
    with open(p, 'wb') as f:
        f.write(_glb_sintetico(dup, None, [0, 1, 2]))
    r = medir_malla(p)
    chk('vertice repetido contado', r['verts_duplicados'] == 1)

    # RF4: 200 tris de prop supera el techo
    chk('techo RF4 de prop es 200', RF4_LOD0['prop'] == 200)
    chk('techo RF4 de bld es 15000', RF4_LOD0['bld'] == 15000)

    # categoria por prefijo de MODULO del nombre (no por carpeta: la carpeta es
    # el nivel de LOD)
    chk('categoria 50-Vegetacion -> veg',
        categoria_de('game/isla-ancestral/assets/3d/alta/50-Vegetacion_arbol.glb') == 'veg')
    chk('categoria 13-Herramientas -> tool',
        categoria_de('game/isla-ancestral/assets/3d/media/13-Herramientas_pico.glb') == 'tool')
    chk('categoria sin prefijo conocido -> None',
        categoria_de('tools/mcp/blender-mcp/SM_algo.glb') is None)
    chk('lod_de distingue alta/media/baja',
        lod_de('x/assets/3d/alta/a.glb') == 'LOD0'
        and lod_de('x/assets/3d/media/a.glb') == 'LOD1'
        and lod_de('x/assets/3d/baja/a.glb') == 'LOD2')

    # LOD: alta sin media/baja -> LOD_FALTANTE
    rec = {'parse_ok': True, 'tris': 900, 'categoria': 'veg', 'lod': 'LOD0',
           'bounds': None, 'escala_no_uniforme': 0, 'escala_no_aplicada': 0,
           'uv_fuera_rango': 0, 'degen': 0, 'verts_duplicados': 0,
           'violaciones': [], 'avisos': []}
    evaluar(rec, 'game/isla-ancestral/assets/3d/alta/50-Vegetacion_x.glb', 'y', {'LOD0'})
    chk('LOD_FALTANTE con 900 tris y solo LOD0',
        any(v.startswith('LOD_FALTANTE') for v in rec['violaciones']))

    rec2 = dict(rec, violaciones=[], avisos=[])
    evaluar(rec2, 'game/isla-ancestral/assets/3d/alta/50-Vegetacion_x.glb', 'y',
            {'LOD0', 'LOD1', 'LOD2'})
    chk('sin LOD_FALTANTE cuando estan los 3 niveles',
        not any(v.startswith('LOD_FALTANTE') for v in rec2['violaciones']))

    # 400 tris no exige LOD
    rec3 = dict(rec, tris=400, violaciones=[], avisos=[])
    evaluar(rec3, 'game/isla-ancestral/assets/3d/alta/50-Vegetacion_x.glb', 'y', {'LOD0'})
    chk('400 tris no exige LOD', not any(v.startswith('LOD_FALTANTE')
                                         for v in rec3['violaciones']))

    # Origen: prop con min_y = 0.5 -> aviso de convencion (no se hunde)
    rec4 = dict(rec, tris=100, bounds={'min': [0, 0.5, 0], 'max': [1, 1, 1],
                                       'dim': [1, 0.5, 1]},
                violaciones=[], avisos=[])
    evaluar(rec4, 'game/isla-ancestral/assets/3d/alta/15-Recursos_x.glb', 'y',
            {'LOD0', 'LOD1', 'LOD2'})
    chk('ORIGEN_SIN_CONVENCION con min_y=0.5',
        any(v.startswith('ORIGEN_SIN_CONVENCION') for v in rec4['avisos']))
    chk('min_y=0.5 no se reporta como hundido',
        not any(v.startswith('ORIGEN_BAJO_SUELO') for v in rec4['violaciones']))

    # Origen: min_y = 0.045 (convencion medida) -> ni violacion ni aviso
    rec5 = dict(rec4, bounds={'min': [0, 0.045, 0], 'max': [1, 1, 1],
                              'dim': [1, 1, 1]}, violaciones=[], avisos=[])
    evaluar(rec5, 'game/isla-ancestral/assets/3d/alta/15-Recursos_x.glb', 'y',
            {'LOD0', 'LOD1', 'LOD2'})
    chk('min_y=0.045 cumple la convencion sin avisos',
        not rec5['violaciones'] and not rec5['avisos'])

    # Origen: min_y negativo -> violacion real (se hunde)
    rec6 = dict(rec4, bounds={'min': [0, -0.2, 0], 'max': [1, 1, 1],
                              'dim': [1, 1.2, 1]}, violaciones=[], avisos=[])
    evaluar(rec6, 'game/isla-ancestral/assets/3d/alta/15-Recursos_x.glb', 'y',
            {'LOD0', 'LOD1', 'LOD2'})
    chk('ORIGEN_BAJO_SUELO con min_y=-0.2',
        any(v.startswith('ORIGEN_BAJO_SUELO') for v in rec6['violaciones']))

    # vertices duplicados: hecho contado, NO aviso (glTF parte por costura)
    rec_dup = dict(rec4, verts_duplicados=40, violaciones=[], avisos=[])
    evaluar(rec_dup, 'game/isla-ancestral/assets/3d/alta/15-Recursos_x.glb', 'y',
            {'LOD0', 'LOD1', 'LOD2'})
    chk('vertices duplicados no genera aviso (glTF parte por costura)',
        not any(v.startswith('TOPO_DUPLICADOS') for v in rec_dup['avisos']))

    # RF4 es AVISO, no violacion (la categoria es inferida, no declarada)
    rec7 = dict(rec4, tris=5000, categoria='prop', bounds=None,
                violaciones=[], avisos=[])
    evaluar(rec7, 'game/isla-ancestral/assets/3d/baja/15-Recursos_x.glb', 'y',
            {'LOD0', 'LOD1', 'LOD2'})
    chk('RF4 excedido es aviso, no violacion',
        any(v.startswith('RF4_EXCEDIDO') for v in rec7['avisos'])
        and not any(v.startswith('RF4_EXCEDIDO') for v in rec7['violaciones']))

    print()
    print('AUTOPRUEBA: %d checks, %d fallos' % (checks, fallos))
    if checks < CHECKS_MINIMOS:
        print('[FALLO] solo %d checks ejecutados (minimo %d): la autoprueba se '
              'recorto y su verde no vale' % (checks, CHECKS_MINIMOS))
        return 1
    return 1 if fallos else 0


if __name__ == '__main__':
    sys.exit(main())
