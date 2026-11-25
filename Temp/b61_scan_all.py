# -*- coding: utf-8 -*-
import os, re, json
ROOT = os.path.abspath('.')
DOC = os.path.join(ROOT, 'DOCUMENTACION')
WANT = {31,30,28,27,26,25,24}

rows=[]
for d in sorted(os.listdir(DOC)):
    cp = os.path.join(DOC, d, 'plan-actual', '05-Checklist.md')
    if not os.path.isfile(cp): continue
    txt = open(cp, encoding='utf-8', errors='replace').read()
    q = len(re.findall(r'(?m)^\s*-\s*\[\?\]', txt))
    rows.append((d, q))

print('=== checklists con [?] en {24..31} ===')
for d,q in rows:
    if q in WANT:
        print('  %-40s %d' % (d,q))
print()
print('=== distribucion 20..35 ===')
for d,q in rows:
    if 20<=q<=35:
        print('  %-40s %d' % (d,q))
