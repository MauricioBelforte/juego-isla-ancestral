import json, struct, os, math

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d"

def load(p):
    data = open(p, "rb").read()
    magic, ver, length = struct.unpack_from("<III", data, 0)
    off, js = 12, None
    while off < length:
        clen, ctype = struct.unpack_from("<II", data, off)
        if ctype == 0x4E4F534A:
            js = json.loads(data[off + 8: off + 8 + clen].decode("utf-8"))
        off += 8 + clen
    return js

def mm(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(4)) for j in range(4)] for i in range(4)]

def trs(n):
    if "matrix" in n:
        m = n["matrix"]
        return [[m[0], m[4], m[8], m[12]], [m[1], m[5], m[9], m[13]],
                [m[2], m[6], m[10], m[14]], [m[3], m[7], m[11], m[15]]]
    t = n.get("translation", [0, 0, 0]); r = n.get("rotation", [0, 0, 0, 1]); s = n.get("scale", [1, 1, 1])
    x, y, z, w = r
    R = [[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w), 0],
         [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w), 0],
         [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y), 0], [0, 0, 0, 1]]
    for i in range(3):
        for j in range(3):
            R[i][j] *= s[j]
    R[0][3], R[1][3], R[2][3] = t
    return R

def wbbox(p):
    js = load(p)
    nodes = js.get("nodes", [])
    if not nodes:
        return None
    roots = js.get("scenes", [{}])[js.get("scene", 0)].get("nodes", list(range(len(nodes))))
    lo, hi = [1e18] * 3, [-1e18] * 3
    seen = set()

    def walk(ni, P):
        if ni in seen:
            return
        seen.add(ni)
        nd = nodes[ni]
        M = mm(P, trs(nd))
        if "mesh" in nd:
            for prim in js["meshes"][nd["mesh"]].get("primitives", []):
                ai = prim.get("attributes", {}).get("POSITION")
                if ai is None:
                    continue
                a = js["accessors"][ai]
                if "min" not in a:
                    continue
                for cx in (a["min"][0], a["max"][0]):
                    for cy in (a["min"][1], a["max"][1]):
                        for cz in (a["min"][2], a["max"][2]):
                            v = [M[i][0] * cx + M[i][1] * cy + M[i][2] * cz + M[i][3] for i in range(3)]
                            for k in range(3):
                                lo[k] = min(lo[k], v[k]); hi[k] = max(hi[k], v[k])
        for c in nd.get("children", []):
            walk(c, M)

    I = [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
    for r in roots:
        walk(r, I)
    if lo[0] > hi[0]:
        return None
    return lo, hi

files = []
for dp, _, ns in os.walk(ROOT):
    for nm in ns:
        if nm.lower().endswith(".glb"):
            files.append(os.path.join(dp, nm))

rows = []
for p in files:
    bb = wbbox(p)
    if not bb:
        continue
    lo, hi = bb
    rows.append((os.path.relpath(p, ROOT), lo[0], lo[1], lo[2], hi[0], hi[1], hi[2]))

float_ = [r for r in rows if r[2] > 0.02]
sunk = [r for r in rows if r[2] < -0.02]
ok = [r for r in rows if -0.02 <= r[2] <= 0.02]
offcenter = [r for r in rows if abs(r[1]) > 0.05 or abs(r[3]) > 0.05]

print("TOTAL:", len(rows))
print("Ymin en [-0.02, 0.02] (origen al ras):", len(ok))
print("Ymin > 0.02 (flotan):", len(float_))
print("Ymin < -0.02 (hundidos):", len(sunk))
print("Fuera de centro XZ (>5cm):", len(offcenter))

print("\n--- flotan (top 12) ---")
for r in sorted(float_, key=lambda x: -x[2])[:12]:
    print("  ymin=%7.3f  %s" % (r[2], r[0]))
print("\n--- hundidos (top 12) ---")
for r in sorted(sunk, key=lambda x: x[2])[:12]:
    print("  ymin=%8.3f  %s" % (r[2], r[0]))
print("\n--- fuera de centro XZ (top 12) ---")
for r in sorted(offcenter, key=lambda x: -max(abs(x[1]), abs(x[3])))[:12]:
    print("  x=%7.3f z=%7.3f  %s" % (r[1], r[3], r[0]))