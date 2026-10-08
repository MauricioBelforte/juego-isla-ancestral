# -*- coding: utf-8 -*-
import re, glob, os
from collections import Counter
ids = {}
for f in glob.glob("game/isla-ancestral/data/items/*.tres", recursive=True):
    c = open(f, encoding="utf-8", errors="ignore").read()
    # line-start 'id = "..."' (el campo del recurso, no el ext_resource id="1")
    m = re.search(r"(?m)^id\s*=\s*\"([a-z0-9_]+)\"", c)
    if m:
        ids[m.group(1)] = os.path.basename(f)
print("M15 tiene %d item ids (line-start):" % len(ids))
basics = sorted(k for k in ids if not k.startswith("item_obj_"))
objs = sorted(k for k in ids if k.startswith("item_obj_"))
print("Básicos (%d):" % len(basics))
for k in basics:
    print("   %-16s %s" % (k, ids[k]))
print("item_obj_ (%d) por prefix:" % len(objs))
for p, n in sorted(Counter(k.split("_")[1] for k in objs).items()):
    print("   item_obj_%s: %d" % (p, n))
print()
# los 8 ids de M39 + pieda_caliza
m39 = ["baya_roja", "fibra_algodon", "madera_roble", "mineral_cobre",
       "pergamino_rec_tela_lino", "herramienta_basica", "fragmento_ancestral", "piedra_caliza"]
allk = set(ids)
print("=== los 8 ids M39 vs M15 ===")
for k in m39:
    print("   %-22s %s" % (k, "EXISTE" if k in allk else "AUSENTE"))
print("Total M15 ids: %d (basicos %d + item_obj %d)" % (len(allk), len(basics), len(objs)))
