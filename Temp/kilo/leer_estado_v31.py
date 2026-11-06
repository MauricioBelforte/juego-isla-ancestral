# -*- coding: utf-8 -*-
"""PASO 0 v31: estado_director.json — total, claves nuevas (post-v30), campos ling/pt/go/bug152/gemelos/nemotron/hy3."""
import io
import json

e = json.load(io.open("Logs/estado_director.json", encoding="utf-8"))
print("TOTAL CLAVES:", len(e))
print("=== ULTIMAS 14 CLAVES (orden de insercion = mas nuevas) ===")
for k in list(e.keys())[-14:]:
    v = e[k]
    s = json.dumps(v, ensure_ascii=False) if not isinstance(v, str) else v
    print("- %s = %s" % (k, s[:280]))
print("=== CAMPOS DE INTERES (ling/pt/go/bug152/gemelos/nemotron/hy3/m157/m87) ===")
for k, v in e.items():
    kl = k.lower()
    if any(t in kl for t in ("ling", "pt_", "go4", "bug152", "gemelo", "nemotron", "hy3", "m157", "m87", "rielp", "design_docs", "fragiles", "338", "340")):
        s = json.dumps(v, ensure_ascii=False) if not isinstance(v, str) else v
        print("--- %s = %s" % (k, s[:300]))
