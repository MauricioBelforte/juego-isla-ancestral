# -*- coding: utf-8 -*-
import io, re, sys
sys.stdout.reconfigure(encoding='utf-8')
c = io.open('DOCUMENTACION/137-Prototipo/plan-actual/05-Checklist.md', encoding='utf-8').read()
lineas = c.split("\n")
actual = None
conteos = {}
orden = []
for l in lineas:
    m = re.match(r"^## ([A-T])\. (.+)$", l)
    if m:
        actual = m.group(1)
        orden.append((actual, m.group(2)))
        conteos[actual] = [0, 0, 0]
        continue
    if actual and re.match(r"^## ", l):
        actual = None
    if actual:
        if re.match(r"^\s*- \[x\]", l): conteos[actual][0] += 1
        elif re.match(r"^\s*- \[ \]", l): conteos[actual][1] += 1
        elif re.match(r"^\s*- \[\?\]", l): conteos[actual][2] += 1

tot = [0, 0, 0]
for k, nombre in orden:
    x, s, q = conteos[k]
    tot[0] += x; tot[1] += s; tot[2] += q
    print("  %s  %-44s %2d [x]  %3d [ ]" % (k, nombre[:44], x, s))
print("")
print("  TOTAL: %d [x] / %d [ ] / %d [?] = %d items" % (tot[0], tot[1], tot[2], sum(tot)))
