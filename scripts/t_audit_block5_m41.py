# -*- coding: utf-8 -*-
import glob, re

# M41 Totales update
g41 = glob.glob("DOCUMENTACION/41-*")[0] + "/plan-actual/05-Checklist.md"
c = open(g41, "rb").read().decode("utf-8")
lines = c.splitlines(keepends=True)
for i, L in enumerate(lines):
    if "Totales:" in L:
        L = re.sub(r"Completados: \d+", "Completados: 59", L)
        L = re.sub(r"No resueltos: \d+", "No resueltos: 2", L)
        lines[i] = L
        break
open(g41, "w", encoding="utf-8", newline="").write("".join(lines))
print("M41 Totales -> 59 / No resueltos 2")

# GLOBAL M41 row: 61/110 -> 59/110 (byte-level)
P = "CHECKLIST-GLOBAL.md"
d = open(P, "rb").read()
i = d.find(b"41-Musica")
if i < 0:
    i = d.find(b"41-Musica")
# find the row start
rs = d.rfind(b"|", 0, i)
re_ = d.find(b"\r\n", i)
seg = d[rs:re_]
print("GLOBAL M41 row seg:", seg[:60])
d = d[:rs] + seg.replace(b"61/110", b"59/110") + d[re_:]
open(P, "wb").write(d)
v = open(P, "rb").read()
i2 = v.find(b"41-Musica"); print("M41 now 59/110:", b"59/110" in v[i2:v.find(b"\r\n", i2)])
print("GLOBAL EOL:", (v.count(b"\r\n"), v.count(b"\r") - v.count(b"\r\n"), v.count(b"\n") - v.count(b"\r\n")))
