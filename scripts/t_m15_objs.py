# -*- coding: utf-8 -*-
import re, glob, os
# todos los ids de M15 (basicos + item_obj_*) con su campo 'id'
ids = {}
for f in glob.glob("game/isla-ancestral/data/items/*.tres", recursive=True):
    c = open(f, encoding="utf-8", errors="ignore").read()
    m = re.search(r"(?m)^\s*id\s*=\s*\"([a-z0-9_]+)\"", c)
    nm = re.search(r"(?m)^\s*nombre\s*=\s*\"([^\"]+)\"", c)
    if m:
        ids[m.group(1)] = nm.group(1) if nm else ""
objs = {k: v for k, v in ids.items() if k.startswith("item_obj_")}
print("M15 item_obj_ ids: %d" % len(objs))
# buscar por concepto
for kw in ["her", "tool", "herr", "perga", "scroll", "recep", "baya", "berry", "fibra", "coton", "tela", "lino"]:
    hits = [k for k in objs if kw in k.lower() or kw in ids.get(k, "").lower()]
    if hits:
        for h in hits[:6]:
            print("  %-20s nombre=%s" % (h, ids.get(h, "")))
print("\n=== todos item_obj (ids+nombre, los primeros 40) ===")
for k in sorted(objs)[:40]:
    print("  %-18s %s" % (k, ids[k]))
print("\n=== M15 total ids = %d" % len(ids))
