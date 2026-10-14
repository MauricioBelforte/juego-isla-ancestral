# -*- coding: utf-8 -*-
import re, io, sys, json, glob, os
sys.stdout.reconfigure(encoding='utf-8')
t = io.open('game/isla-ancestral/scripts/islas/definir_islas.gd', encoding='utf-8').read()
nombres = re.findall(r'nombre = "([^"]+)"', t)
print('islas definidas en codigo (%d):' % len(nombres))
for n in nombres: print('  -', n)
print()
for f in glob.glob('game/isla-ancestral/data/**/catalog.json', recursive=True):
    d = json.load(io.open(f, encoding='utf-8'))
    if isinstance(d, dict):
        print(f.split('data')[-1][:50], '| claves:', list(d.keys())[:6])
        for k, v in d.items():
            if isinstance(v, (list, dict)):
                print('    ', k, '->', len(v))
