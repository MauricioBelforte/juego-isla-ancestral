# -*- coding: utf-8 -*-
import re
c = open("DOCUMENTACION/38-Economia/plan-actual/05-Checklist.md", "rb").read().decode("utf-8")
xs = [re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I).group(1) for L in c.splitlines()
      if re.match(r"^\s*[-*]\s*\[x\]", L, re.I)]
absent = ["trueque_cacao_lana.tres", "trueque_pesca_herramienta.tres", "economy_prices.tres",
          "tienda_agricola.tres", "tienda_artesanias.tres", "tienda_pescaderia.tres", "shop_definition.gd"]
citing = [x for x in xs if any(a in x for a in absent)]
print("M38 [x] total=%d, que citan artefactos AUSENTES: %d" % (len(xs), len(citing)))
for x in citing[:12]:
    print("   -", x[:95])
