# -*- coding: utf-8 -*-
import re, os, glob
ck = "DOCUMENTACION/39-Tiendas/plan-actual/05-Checklist.md"
c = open(ck, "rb").read().decode("utf-8")
xs = [re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I).group(1) for L in c.splitlines()
      if re.match(r"^\s*[-*]\s*\[x\]", L, re.I)]
absent = ["catalogo_ferreteria.tres", "catalogo_pesca.tres", "catalogo_semillas.tres", "ferreteria.tres",
          "mercader_viajero.tres", "pescaderia.tres", "puesto_semillas.tres", "tienda_general.tres",
          "shop_catalog.gd", "shop_definition.gd", "stock_entry.gd"]
citing = [x for x in xs if any(a in x for a in absent)]
impl = [x for x in xs if re.search(r"[Ii]mplement", x)]
print("M39 total [x]=%d" % len(xs))
print("[x] que citan artefacto AUSENTE (.tres/.gd): %d" % len(citing))
for x in citing[:10]:
    print("   -", x[:95])
print("[x] 'Implementar': %d" % len(impl))
for x in impl[:5]:
    print("   -", x[:95])
for t in ["ferreteria.tres", "tienda_general.tres", "catalogo_ferreteria.tres"]:
    print("  %s: %s" % (t, [g.split("isla-ancestral/")[-1] for g in glob.glob("game/isla-ancestral/**/" + t, recursive=True)] or "AUSENTE"))
