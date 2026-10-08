# -*- coding: utf-8 -*-
import os, re
BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
g = os.path.join(BASE, "DOCUMENTACION", "156-Terrenos-Y-Movimiento", "plan-actual", "05-Checklist.md")
c = open(g, "rb").read().decode("utf-8")
lines = c.splitlines(keepends=True)
for i, L in enumerate(lines):
    if "307 ítems" in L and "Totales:" in L:
        L2 = re.sub(r"Completados: \d+", "Completados: 234", L)
        L2 = re.sub(r"No resueltos: \d+", "No resueltos: 14", L2)
        lines[i] = L2
        break
# append new audit note
note = ("\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque M156 autorizado por Atria canal/52)\n"
        "M156 (243 [x]) auditado método A con test_terrenos.gd 0/0 ('7 terrenos cargados'). 9 [x] DEGRADADOS a [?] "
        "(243 -> 234 [x], 5 -> 14 [?]): los [x] citaban .gd ausentes en disco (particulas_agua/arena/barro/nieve/rocas.gd, "
        "player_movement.gd, terrain_footstep_audio.gd, test_terrain_provider.gd, test_terrain_detector.gd) — la funcionalidad "
        "real es data-driven (data/terrenos/terrenos.json 7 tipos) + test_terrenos.gd. Sello 🔒 M167 (hy3) respetado; "
        "glm-5.3 inactivo (§21.4: asignación nominal muerta, auditoría autorizada). No pisé el sistema de terreno (core OK).\n")
with open(g, "wb") as f:
    f.write(("".join(lines) + note).encode("utf-8"))
print("M156 Totales -> 234 / No resueltos 14; nota appendida")

# GLOBAL M156 row 243/307 -> 234/307 (byte-level)
P = os.path.join(BASE, "CHECKLIST-GLOBAL.md")
d = open(P, "rb").read()
i = d.find(b"156-Terrenos-Y-Movimiento")
rs = d.rfind(b"|", 0, i); e = d.find(b"\r\n", i)
seg = d[rs:e]
assert b"243/307" in seg, "M156 243/307 not in row"
d = d[:rs] + seg.replace(b"243/307", b"234/307") + d[e:]
open(P, "wb").write(d)
v = open(P, "rb").read()
print("GLOBAL M156 234/307:", b"234/307" in v[v.find(b"156-Terrenos"):v.find(b"\r\n", v.find(b"156-Terrenos"))])
print("GLOBAL EOL: CRLF=%d CR=%d LF=%d" % (v.count(b"\r\n"), v.count(b"\r") - v.count(b"\r\n"), v.count(b"\n") - v.count(b"\r\n")))
