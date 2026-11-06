# -*- coding: utf-8 -*-
"""PASO 0 v30: estado_director.json — total, ULTIMAS claves (mas nuevas por insercion), campos de interes."""
import io
import json
import re

e = json.load(io.open("Logs/estado_director.json", encoding="utf-8"))
ks = list(e.keys())
print("TOTAL CLAVES:", len(ks))
print("=== ULTIMAS 18 CLAVES (orden de insercion = mas nuevas) ===")
for k in ks[-18:]:
    print("-", k, "=", str(e[k])[:280])
print("=== CAMPOS DE INTERES ===")
pat = re.compile(r"ling|riel|\bpt\b|go4|go_|bug152|nemotron_fuel|m01|gemelo|qa|wiring|cable|m87|i18n|validador", re.I)
for k in ks:
    if pat.search(k):
        print("---", k, "=", str(e[k])[:380])
