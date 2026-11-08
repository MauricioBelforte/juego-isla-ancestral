"""Compara triangulos REALES del GLB contra los del .blend (original y validado).

Uso: python Temp/hy4_comparar_tris_glb.py <glb> <json_del_blend>
"""
import json
import struct
import sys
from collections import Counter

glb, dump = sys.argv[1], sys.argv[2]
raw = open(glb, 'rb').read()
assert raw[:4] == b'glTF'
jlen = struct.unpack_from('<I', raw, 12)[0]
doc = json.loads(raw[20:20 + jlen].decode('utf-8'))
off = 20 + jlen
blen = struct.unpack_from('<I', raw, off)[0]
bin_ = raw[off + 8:off + 8 + blen]

# Matrices de nodo (column-major). Identidad si no hay matrix ni TRS.
def ident():
    return [1., 0., 0., 0., 0., 1., 0., 0.,
            0., 0., 1., 0., 0., 0., 0., 1.]


def trs(n):
    if 'matrix' in n:
        return list(n['matrix'])
    t = n.get('translation', [0, 0, 0])
    r = n.get('rotation', [0, 0, 0, 1])
    s = n.get('scale', [1, 1, 1])
    x, y, z, w = r
    rm = [1 - 2 * (y * y + z * z), 2 * (x * y + z * w), 2 * (x * z - y * w), 0,
          2 * (x * y - z * w), 1 - 2 * (x * x + z * z), 2 * (y * z + x * w), 0,
          2 * (x * z + y * w), 2 * (y * z - x * w), 1 - 2 * (x * x + y * y), 0,
          0, 0, 0, 1]
    for c in range(3):
        for r_ in range(3):
            rm[c * 4 + r_] *= s[c]
    rm[12], rm[13], rm[14] = t
    return rm


def aplicar(m, p):
    x, y, z = p
    return (m[0] * x + m[4] * y + m[8] * z + m[12],
            m[1] * x + m[5] * y + m[9] * z + m[13],
            m[2] * x + m[6] * y + m[10] * z + m[14])


def leer_vec(acc_i, fmt, ncomp):
    acc = doc['accessors'][acc_i]
    bv = doc['bufferViews'][acc['bufferView']]
    stride = bv.get('byteStride') or struct.calcsize('<' + fmt * ncomp)
    base = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
    out = []
    for k in range(acc['count']):
        out.append(struct.unpack_from('<' + fmt * ncomp, bin_, base + k * stride))
    return out


def clave(pts):
    return tuple(sorted(tuple(round(v, 4) for v in p) for p in pts))


# nombre de malla -> matriz del nodo que la instancia
mat_por_malla = {}
for n in doc.get('nodes', []):
    if 'mesh' in n:
        mat_por_malla.setdefault(n['mesh'], []).append(trs(n))

glb_por_malla = {}
glb_area = {}
for mi, mesh in enumerate(doc['meshes']):
    tris = []
    area_total = 0.0
    mats = mat_por_malla.get(mi, [ident()])
    for pr in mesh['primitives']:
        pos = leer_vec(pr['attributes']['POSITION'], 'f', 3)
        idx_fmt = {5121: 'B', 5123: 'H', 5125: 'I'}.get(
            doc['accessors'][pr['indices']]['componentType'], 'H')
        idx = [i[0] for i in leer_vec(pr['indices'], idx_fmt, 1)] \
            if 'indices' in pr else list(range(len(pos)))
        for m in mats:
            for k in range(0, len(idx), 3):
                # glTF Y-up -> Blender Z-up: (x, -z, y)
                pts = []
                for ii in idx[k:k + 3]:
                    gx, gy, gz = aplicar(m, pos[ii])
                    pts.append((gx, -gz, gy))
                a, b, c = pts
                u = tuple(b[i] - a[i] for i in range(3))
                v = tuple(c[i] - a[i] for i in range(3))
                cr = (u[1] * v[2] - u[2] * v[1],
                      u[2] * v[0] - u[0] * v[2],
                      u[0] * v[1] - u[1] * v[0])
                area_total += (cr[0] ** 2 + cr[1] ** 2 + cr[2] ** 2) ** 0.5 * 0.5
                tris.append(clave(pts))
    nombre_malla = mesh.get('name', 'mesh%d' % mi)
    glb_por_malla[nombre_malla] = tris
    glb_area[nombre_malla] = area_total

blend = json.load(open(dump, encoding='utf-8'))
alias = {
    'SM_Mansion_M_Mansion_Madera.001': 'SM_Mansion_M_Mansion_Madera',
    'SM_Mansion_M_Mansion_Piedra.001': 'SM_Mansion_M_Mansion_Piedra',
    'SM_Mansion_M_Mansion_Acento.001': 'SM_Mansion_M_Mansion_Acento',
    'SM_Mansion_M_Mansion_Jade.001': 'SM_Mansion_M_Mansion_Jade',
    'Cube': 'SM_Mansion_Zocalo_NOFUNDIR',
    'Cube.051': 'SM_Mansion_Pedestal_NOFUNDIR',
}

print('%-42s %7s %7s %7s %8s %8s %8s %11s %11s' %
      ('MALLA', 'GLB', 'VALID', 'ORIG', 'G==V', 'FALTA', 'SOBRA',
       'AREA_GLB', 'AREA_VALID'))
tot = Counter()
for nombre, tris in sorted(glb_por_malla.items()):
    obj = alias.get(nombre)
    if obj is None:
        print('%-42s SIN ALIAS' % nombre)
        continue
    g = Counter(tris)
    v = Counter(clave(t['p']) for t in blend[obj]['validado'])
    o = Counter(clave(t['p']) for t in blend[obj]['original'])
    falta = sum((v - g).values())
    sobra = sum((g - v).values())
    igual = g == v
    area_v = sum(t['a'] for t in blend[obj]['validado'])
    print('%-42s %7d %7d %7d %8s %8d %8d %11.4f %11.4f  dA=%+.6f' %
          (nombre, sum(g.values()), sum(v.values()), sum(o.values()),
           'SI' if igual else 'NO', falta, sobra,
           glb_area[nombre], area_v, glb_area[nombre] - area_v))
    tot['glb'] += sum(g.values()); tot['valid'] += sum(v.values())
    tot['orig'] += sum(o.values()); tot['falta'] += falta; tot['sobra'] += sobra
print()
print('TOTALES glb=%d validado=%d original=%d falta=%d sobra=%d' %
      (tot['glb'], tot['valid'], tot['orig'], tot['falta'], tot['sobra']))
print('ARTEFACTOS_ELIMINADOS_POR_VALIDACION = %d' % (tot['orig'] - tot['valid']))
