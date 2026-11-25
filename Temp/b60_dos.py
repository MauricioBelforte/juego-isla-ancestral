# -*- coding: utf-8 -*-
import os, re
ROOT = os.path.abspath('.')
p = os.path.join(ROOT,'DOCUMENTACION','49-Iluminacion','plan-actual','03-Diseno.md')
lines = open(p, encoding='utf-8', errors='replace').read().splitlines()
for pat, label in [(r'hornea|bake|interior','L120/donde-hornea'),(r'niebla|fog','L200/niebla')]:
    print('=== %s en 03-Diseno.md ===' % label)
    for i, l in enumerate(lines, 1):
        if re.search(pat, l, re.I):
            print('  L%d %s' % (i, l.strip()[:200]))
    print()
