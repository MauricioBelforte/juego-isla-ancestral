# -*- coding: utf-8 -*-
import os, re
ROOT = os.path.abspath('.')
# buscar asset_catalog.json y validate_mesh.gd en todo el repo
targets = ['asset_catalog.json','validate_mesh.gd','dialogue_ui.tscn','dialogo_ejemplo.json']
found = {t:[] for t in targets}
for r, ds, fs in os.walk(ROOT):
    ds[:] = [d for d in ds if d not in ('.git','.workbuddy-ai','.kilo','.godot')]
    for f in fs:
        if f in found:
            found[f].append(os.path.relpath(os.path.join(r,f), ROOT).replace('\\','/'))
for t, hits in found.items():
    print('%-24s %d %s' % (t, len(hits), hits[:4]))

# @tool en scripts/dialogos
D = os.path.join(ROOT,'game','isla-ancestral','scripts','dialogos')
tool_hits=[]
if os.path.isdir(D):
    for r,ds,fs in os.walk(D):
        for f in fs:
            if f.endswith('.gd'):
                p=os.path.join(r,f)
                for i,l in enumerate(open(p,encoding='utf-8',errors='replace').read().splitlines(),1):
                    if re.search(r'@tool', l):
                        tool_hits.append((os.path.relpath(p,ROOT).replace('\\','/'),i,l.strip()[:80]))
print('@tool en scripts/dialogos:', len(tool_hits), tool_hits[:5])

# LRU en dialogue_manager
p=os.path.join(ROOT,'game','isla-ancestral','scripts','dialogos','dialogue_manager.gd')
if os.path.isfile(p):
    t=open(p,encoding='utf-8',errors='replace').read()
    print('dialogue_manager LRU hits:', len(re.findall(r'LRU|descarte|max_cache|cache.*limit|_grafos_cache', t, re.I)))
else:
    print('dialogue_manager.gd NO existe')
