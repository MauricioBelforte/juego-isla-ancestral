# -*- coding: utf-8 -*-
import re, io, sys, json, glob, os
sys.stdout.reconfigure(encoding='utf-8')
# islas: buscar en generar_islas.gd y catalogo
for f in ['game/isla-ancestral/scripts/world/generar_islas.gd']:
    if os.path.exists(f):
        t = io.open(f, encoding='utf-8').read()
        nombres = re.findall(r'nombre\s*[:=]\s*"([^"]+)"', t)
        if not nombres:
            nombres = re.findall(r'"([A-Z][a-z]+ [A-Za-z \u00e1\u00e9\u00ed\u00f3\u00fa]+)"', t)
        print(f.split('/')[-1], '->', len(nombres), 'nombres:', nombres[:18])
print()
d = json.load(io.open('game/isla-ancestral/data/coleccionables/catalog.json', encoding='utf-8'))
print('coleccionables/catalog.json ->', type(d).__name__, list(d.keys())[:6] if isinstance(d, dict) else len(d))
items = d.get('coleccionables', d.get('items', [])) if isinstance(d, dict) else d
print('  items:', len(items))
