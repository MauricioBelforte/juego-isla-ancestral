# -*- coding: utf-8 -*-
import os, re, json
ROOT = os.path.abspath('.')
DOC = os.path.join(ROOT, 'DOCUMENTACION')

TARGETS = {
    '21': ('Dialogos', 31), '33': ('Agricultura', 30), '14': ('Recursos', 30),
    '30': ('Ciclo-Dia-Noche', 28), '61': ('Rendimiento', 28), '36': ('Museos', 27),
    '155': ('Fotos', 26), '52': ('UI-UX', 25), '137': ('Vertical-Slice', 25),
    '44': ('Arte-3D', 24),
}

def find_checklist(mid):
    pre = mid + '-'
    for d in sorted(os.listdir(DOC)):
        if d.startswith(pre):
            cp = os.path.join(DOC, d, 'plan-actual', '05-Checklist.md')
            if os.path.isfile(cp):
                return cp, d
    return None, None

out = {}
for mid, (name, exp) in TARGETS.items():
    cp, dname = find_checklist(mid)
    if not cp:
        out[mid] = {'error': 'sin checklist', 'name': name, 'exp': exp}
        continue
    lines = open(cp, encoding='utf-8', errors='replace').read().splitlines()
    qs = [(i + 1, l.strip()) for i, l in enumerate(lines) if re.match(r'^\s*-\s*\[\?\]', l)]
    xs = len(re.findall(r'(?m)^\s*-\s*\[x\]', '\n'.join(lines)))
    bl = len(re.findall(r'(?m)^\s*-\s*\[ \]', '\n'.join(lines)))
    out[mid] = {'name': name, 'dir': dname, 'path': os.path.relpath(cp, ROOT).replace('\\','/'),
                'exp': exp, 'q': len(qs), 'x': xs, 'blank': bl,
                'sample': [{'line': n, 'text': t[:170]} for n, t in qs[:5]]}

json.dump(out, open('Temp/b61_inspeccion.json','w',encoding='utf-8'), ensure_ascii=False, indent=1)
print('MOD   nombre            exp  disco  x    [ ]  dif  dir')
for mid, v in out.items():
    if 'error' in v:
        print('M%-4s %-16s %s' % (mid, v['name'], v['error'])); continue
    print('M%-4s %-16s %3d  %3d   %3d  %2d  %+d  %s' % (
        mid, v['name'][:16], v['exp'], v['q'], v['x'], v['blank'], v['q']-v['exp'], v['dir']))
print('TOTAL esperado', sum(x[1] for x in TARGETS.values()),
      'disco', sum(v.get('q',0) for v in out.values()))
