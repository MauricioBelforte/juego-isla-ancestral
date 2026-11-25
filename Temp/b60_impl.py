# -*- coding: utf-8 -*-
import os, re
ROOT = os.path.abspath('.')
GAME = os.path.join(ROOT,'game','isla-ancestral')
def grep(pat, exts=('.gd','.tscn','.tres','.json')):
    rx = re.compile(pat, re.I); hits=[]
    for r, ds, fs in os.walk(GAME):
        ds[:] = [d for d in ds if d not in ('.godot','addons','Godot')]
        for f in fs:
            if not f.endswith(exts): continue
            p=os.path.join(r,f)
            try: t=open(p,encoding='utf-8',errors='replace').read()
            except: continue
            for i,l in enumerate(t.splitlines(),1):
                if rx.search(l): hits.append((os.path.relpath(p,ROOT).replace('\\','/'),i,l.strip()[:110]))
    return hits
for pat,label in [
    (r'lightmap|baked|bake_|hornead', 'L120/L199 baked lightmap implementation'),
    (r'fog_curve|niebla_por_bioma|fog_enabled|fog_density','L200 fog implementation'),
]:
    h=grep(pat)
    print('=== %s : %d hits ==='%(label,len(h)))
    for x in h[:12]: print('  %s L%d %s'%x)
    print()
