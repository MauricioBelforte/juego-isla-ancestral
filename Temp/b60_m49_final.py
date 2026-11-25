# -*- coding: utf-8 -*-
import os, re
ROOT = os.path.abspath('.')
# localizar TODOS los 03-Diseno.md de M49 (plan-actual, plan-inicial, otros)
for r, ds, fs in os.walk(os.path.join(ROOT, 'DOCUMENTACION', '49-Iluminacion')):
    for f in fs:
        p = os.path.join(r, f)
        if f.endswith('.md'):
            txt = open(p, encoding='utf-8', errors='replace').read()
            glow = len(re.findall(r'glow|bloom', txt, re.I))
            pcf = len(re.findall(r'\bPCF\b', txt, re.I))
            print('%-70s glow=%d PCF=%d bytes=%d' % (os.path.relpath(p, ROOT).replace('\\','/'), glow, pcf, len(txt)))

# todos los glow hits en game, agrupados por archivo
GAME = os.path.join(ROOT, 'game', 'isla-ancestral')
byfile = {}
for r, ds, fs in os.walk(GAME):
    ds[:] = [d for d in ds if d not in ('.godot','addons','Godot')]
    for f in fs:
        p = os.path.join(r, f)
        if not f.endswith(('.gd','.tscn','.tres','.json')):
            continue
        txt = open(p, encoding='utf-8', errors='replace').read()
        hits = [(i+1, l.strip()[:90]) for i, l in enumerate(txt.splitlines()) if re.search(r'glow|bloom', l, re.I)]
        if hits:
            byfile[os.path.relpath(p, ROOT).replace('\\','/')] = hits
print()
print('Archivos con glow/bloom en game:', len(byfile))
for p, hits in sorted(byfile.items(), key=lambda x: -len(x[1]))[:12]:
    print(' %-65s %d hits' % (p, len(hits)))
    for n, l in hits[:2]: print('      L%d %s' % (n, l))
