# -*- coding: utf-8 -*-
import os, re
ROOT = os.path.abspath('.')
p = os.path.join(ROOT,'DOCUMENTACION','49-Iluminacion','plan-actual','05-Checklist.md')
lines = open(p, encoding='utf-8', errors='replace').read().splitlines()
# lineas flippeadas en b58 + las 5 verificables
targets = [39,40,86,87,93,94,148,167,79,109,120,199,200]
for n in targets:
    print('L%-4d %s' % (n, lines[n-1].strip()[:210]))
