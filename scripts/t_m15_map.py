# -*- coding: utf-8 -*-
import re, glob
items = []  # (id, nombre)
for f in glob.glob("game/isla-ancestral/data/items/*.tres", recursive=True):
    c = open(f, encoding="utf-8", errors="ignore").read()
    mi = re.search(r"(?m)^\s*id\s*=\s*\"([^\"]+)\"", c)
    mn = re.search(r"(?m)^\s*nombre\s*=\s*\"([^\"]+)\"", c)
    if mi:
        items.append((mi.group(1), mn.group(1) if mn else ""))
print("M15: %d items" % len(items))
# los 8 ids M39 (nombres en español) → buscar match por 'nombre'
m39 = {
    "baya_roja": "baya", "fibra_algodon": "fibra", "madera_roble": "madera",
    "mineral_cobre": "cobre", "pergamino_rec_tela_lino": "pergamino",
    "herramienta_basica": "herramienta", "fragmento_ancestral": "ancestral",
    "piedra_caliza": "piedra",
}
for m39name, kw in m39.items():
    hits = [(i, n) for (i, n) in items if kw.lower() in i.lower() or kw.lower() in n.lower()]
    print("\n%s (kw='%s') -> %d matches M15:" % (m39name, kw, len(hits)))
    for i, n in hits[:8]:
        print("     %-16s nombre=%s" % (i, n))
