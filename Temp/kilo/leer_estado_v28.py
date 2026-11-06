# -*- coding: utf-8 -*-
"""PASO 0 vuelta 28: leer estado_director.json — conteo + delta de claves de interes."""
import io
import json

e = json.load(io.open("Logs/estado_director.json", encoding="utf-8"))
print("TOTAL CLAVES:", len(e))
terminos = ["ling", "deepseek", "beam", "nemotron", "m01", "p100", "p-100", "dirty", "m59",
            "pt_", "riel", "cron", "go4", "herencia", "tanda", "cierre", "1nov", "flota",
            "gate", "qa", "bug", "m11", "m67", "m74", "wire", "quality"]
print("\n=== CLAVES DE INTERES (valor truncado a 220 chars) ===")
for k in sorted(e.keys(), key=str.lower):
    if any(t in k.lower() for t in terminos):
        v = str(e[k]).replace("\n", " | ")
        print("- %s = %s" % (k, v[:220]))
print("\n=== ULTIMAS 8 CLAVES POR ORDEN DE INSERCION (proxy de novedad) ===")
for k in list(e.keys())[-8:]:
    print("-", k, "=", str(e[k])[:150].replace("\n", " | "))
