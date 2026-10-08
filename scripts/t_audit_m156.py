# -*- coding: utf-8 -*-
import re, glob, os
BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
g = os.path.join(BASE, "DOCUMENTACION", "156-Terrenos-Y-Movimiento")
c = open(g + "/plan-actual/05-Checklist.md", "rb").read().decode("utf-8")
xs = [m.group(1).strip() for m in (re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I) for L in c.splitlines()) if m]
named = [x for x in xs if re.search(r"\b\w+\.gd\b", x)]
print("M156 [x] que nombran .gd:", len(named), "de", len(xs))
names = set()
for x in named:
    for m in re.findall(r"([A-Za-z0-9_]+\.gd)", x):
        names.add(m)
print("verificando %d .gd nombrados:" % len(names))
missing = []
for n in sorted(names):
    hits = glob.glob(os.path.join(BASE, "game", "isla-ancestral", "**", n), recursive=True)
    if not hits:
        missing.append(n)
    else:
        print("  OK   ", n)
print("AUSENTES:", missing or "NINGUNO")
