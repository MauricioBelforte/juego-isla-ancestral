# -*- coding: utf-8 -*-
import io, re, sys, os
sys.stdout.reconfigure(encoding='utf-8')
p = 'game/isla-ancestral/scripts/island_catalog.gd'
if os.path.exists(p):
    t = io.open(p, encoding='utf-8').read()
    nombres = re.findall(r'nombre\s*[:=]\s*"([^"]+)"', t)
    print('island_catalog.gd ->', len(nombres), 'islas')
    for n in nombres:
        print('  -', n)
else:
    print('(sin island_catalog.gd)')
