# -*- coding: utf-8 -*-
import io, json

for h in io.open(r"game\isla-ancestral\scripts\saving\_cat.txt", encoding="utf-8").read().split("\n"):
    ruta = h.split(" (")[0]
    if not ruta:
        continue
    d = json.load(io.open(ruta, encoding="utf-8"))
    recs = d.get("recetas") if isinstance(d, dict) else d
    if isinstance(recs, dict):
        recs = list(recs.values())
    headers = []
    for r in (recs or []):
        if isinstance(r, dict):
            rid = str(r.get("id", ""))
            res = str(r.get("resultado_id", r.get("resultado", "")))
            est = r.get("estacion", "?")
            if any(res.startswith(t + "_") for t in ["hacha", "martillo", "azada", "machete"]):
                headers.append("%s -> %s (est=%s)" % (rid, res, est))
    if headers:
        print(ruta)
        for h2 in headers:
            print("   ", h2)
