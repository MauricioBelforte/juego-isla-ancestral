# -*- coding: utf-8 -*-
"""PASO 0 v29: estado_director.json — total de claves, nombres ordenados, y campos relevantes."""
import io
import json

e = json.load(io.open("Logs/estado_director.json", encoding="utf-8"))
print("TOTAL CLAVES:", len(e))
print("=== NOMBRES DE CLAVES (ordenados) ===")
for k in sorted(e.keys()):
    print(k)
print("=== CAMPOS DE INTERES (ling/pt/riel/GO/fundador/encargo/m87/i18n/nemotron/deepseek) ===")
import re
pat = re.compile(r"ling|ling-3|\bpt\b|riel|\bGO\b|fundador|encargo|m87|i18n|nemotron|deepseek", re.I)
for k in sorted(e.keys()):
    if pat.search(k):
        v = str(e[k])
        print("--- %s = %s" % (k, v[:600]))
