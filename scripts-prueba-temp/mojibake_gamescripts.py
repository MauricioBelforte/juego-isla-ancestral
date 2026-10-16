# -*- coding: utf-8 -*-
import io, os, re

raiz = "game/isla-ancestral/scripts"
# marcadores clasicos de doble-encoding (bytes UTF-8 leidos como cp1252 y regrabados)
marcas = ["\u00c3\u0083\u00c2", "\u00c3\u0083\u00c2\u00b3", "\u00c3\u0082", "\u00e2\u20ac\u0153", "\u00e2\u20ac\u009d", "\u00ef\u00bf\u00bd", "\u00c3\u0192"]
pat = re.compile("|".join(re.escape(m) for m in marcas))

sucios = {}
total = 0
for dirpath, dirnames, filenames in os.walk(raiz):
    for fn in filenames:
        if not fn.endswith((".gd", ".tscn", ".tres", ".cfg", ".md", ".gdshader")):
            continue
        p = os.path.join(dirpath, fn)
        total += 1
        try:
            with io.open(p, "r", encoding="utf-8") as f:
                t = f.read()
        except Exception:
            continue
        n = len(pat.findall(t))
        if n > 0:
            sucios[p.replace("\\", "/")] = n

print("archivos escaneados:", total)
print("archivos con mojibake (chequeo laxo byte-level):", len(sucios))
for p, n in sorted(sucios.items(), key=lambda kv: -kv[1]):
    print("  {0:4d}  {1}".format(n, p))
