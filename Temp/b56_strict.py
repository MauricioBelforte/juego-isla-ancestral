#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Chequeo estricto: solo archivo EXPLICTAMENTE pedido en el item [?]."""
import os, re, json

ROOT = os.path.abspath('.')
d = json.load(open(os.path.join(ROOT, 'Temp', 'b56_mediciones.json'), encoding='utf-8'))
idx = {}
for r, ds, fs in os.walk(ROOT):
    if '.kilo' in r or '.git' in r:
        continue
    for f in fs:
        idx.setdefault(f, []).append(r)
pat = re.compile(r'(?:crear|no existe|falta|ausente|implementar)\s+(?:el|la|los|las)?\s*[`"]?([A-Za-z0-9_\-]+\.(?:gd|tscn|tres|png|glb|blend|json|shader|po))', re.I)
res = []
for a in d.get('A', []):
    if 'linea' not in a:
        continue
    for m in pat.finditer(a['texto']):
        name = m.group(1)
        res.append({'mod': a['mod'], 'linea': a['linea'], 'pedido': name,
                    'existe': name in idx, 'texto': a['texto'][:160]})
print('items con pedido explicito:', len(res), 'existen:', sum(1 for x in res if x['existe']))
for x in res:
    print(x)
json.dump(res, open(os.path.join(ROOT, 'Temp', 'b56_strict.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
