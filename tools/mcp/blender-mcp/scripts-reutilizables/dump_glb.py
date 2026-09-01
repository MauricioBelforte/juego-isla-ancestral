"""Volcado crudo de un GLB: nodos, TRS, mallas, min/max de POSITION."""
import json
import struct
import sys

path = sys.argv[1] if len(sys.argv) > 1 else ''
data = open(path, 'rb').read()
assert data[:4] == b'glTF', 'no es GLB'
ver, total = struct.unpack_from('<II', data, 4)
off = 12
chunks = []
while off < total:
    ln, ty = struct.unpack_from('<II', data, off)
    body = data[off + 8: off + 8 + ln]
    chunks.append((struct.pack('<I', ty).rstrip(b'\x00').decode(), body))
    off += 8 + ln

js = json.loads(chunks[0][1].decode('utf-8'))
bin_ = b''.join(c[1] for c in chunks[1:] if c[0] == 'BIN')

COMP = {5120: (1, 'b'), 5121: (1, 'B'), 5122: (2, 'h'),
        5123: (2, 'H'), 5125: (4, 'I'), 5126: (4, 'f')}
DIV = {5120: 127.0, 5121: 255.0, 5122: 32767.0, 5123: 65535.0}
NCOMP = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3, 'VEC4': 4, 'MAT4': 16}


def leer(ai):
    a = js['accessors'][ai]
    n = NCOMP[a['type']]
    sz, fmt = COMP[a['componentType']]
    dv = DIV.get(a['componentType'], 1.0)
    bv = js['bufferViews'][a['bufferView']]
    start = bv.get('byteOffset', 0) + a.get('byteOffset', 0)
    out = []
    stride = bv.get('byteStride') or (sz * n)
    for i in range(a['count']):
        base = start + i * stride
        vals = struct.unpack_from('<%d%s' % (n, fmt), bin_, base)
        out.append(tuple(v / dv for v in vals))
    return out


def trs(n):
    if 'matrix' in n:
        return n['matrix']
    t = n.get('translation', [0, 0, 0])
    r = n.get('rotation', [0, 0, 0, 1])
    s = n.get('scale', [1, 1, 1])
    x, y, z, w = r
    m = [[0.0] * 4 for _ in range(4)]
    m[0][0] = 1 - 2 * (y * y + z * z)
    m[0][1] = 2 * (x * y - z * w)
    m[0][2] = 2 * (x * z + y * w)
    m[1][0] = 2 * (x * y + z * w)
    m[1][1] = 1 - 2 * (x * x + z * z)
    m[1][2] = 2 * (y * z - x * w)
    m[2][0] = 2 * (x * z - y * w)
    m[2][1] = 2 * (y * z + x * w)
    m[2][2] = 1 - 2 * (x * x + y * y)
    for i in range(3):
        for j in range(3):
            m[i][j] *= s[j] if False else s[i] if False else 1.0
        m[i][3] = t[i]
    # aplicar escala por columna
    for c in range(3):
        for r_ in range(3):
            m[r_][c] *= s[c]
    m[3][3] = 1.0
    return [m[r_][c] for c in range(4) for r_ in range(4)]


def mul(A, B):
    """A*B con matrices columna-mayor (glTF)."""
    out = [0.0] * 16
    for c in range(4):
        for r in range(4):
            s = 0.0
            for k in range(4):
                s += A[k * 4 + r] * B[c * 4 + k]
            out[c * 4 + r] = s
    return out


def aplicar(M, p):
    x = y = z = 0.0
    for i, v in enumerate(p[:3]):
        x += M[0 * 4 + i] * v
        y += M[1 * 4 + i] * v
        z += M[2 * 4 + i] * v
    x += M[0 * 4 + 3]
    y += M[1 * 4 + 3]
    z += M[2 * 4 + 3]
    return x, y, z


print('ARCHIVO:', path)
print('escena:', js.get('scene'), 'escenas:', len(js.get('scenes', [])))
for si, sc in enumerate(js.get('scenes', [])):
    print('  escena[%d] nodos raiz:' % si, sc.get('nodes'))

padre = {}
for i, n in enumerate(js.get('nodes', [])):
    for c in n.get('children', []):
        padre[c] = i

scenes = js.get('scenes', [])
roots = scenes[js.get('scene', 0)].get('nodes', []) if scenes else []


def mundo(i):
    cad = []
    cur = i
    while cur is not None:
        cad.append(cur)
        cur = padre.get(cur)
    M = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]
    for k in reversed(cad):
        M = mul(M, trs(js['nodes'][k]))
    return M


print()
for i, n in enumerate(js.get('nodes', [])):
    M = mundo(i)
    extra = ''
    if 'mesh' in n:
        me = js['meshes'][n['mesh']]
        for pr in me['primitives']:
            ai = pr['attributes'].get('POSITION')
            a = js['accessors'][ai]
            mn = a.get('min')
            mx = a.get('max')
            vs = leer(ai)
            ys = [aplicar(M, v)[1] for v in vs]
            extra += ('\n      mesh=%s prim nv=%d min=%s max=%s'
                      '\n           minY_local=%.4f  minY_MUNDO=%.4f  maxY_MUNDO=%.4f'
                      % (me.get('name'), a['count'],
                         ['%.4f' % q for q in mn] if mn else None,
                         ['%.4f' % q for q in mx] if mx else None,
                         min(v[1] for v in vs), min(ys), max(ys)))
    print('  [%2d] %-45s T=%s R=%s S=%s%s' % (
        i, n.get('name', '?'),
        n.get('translation'), n.get('rotation'), n.get('scale'), extra))
