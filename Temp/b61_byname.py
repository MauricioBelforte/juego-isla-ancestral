# -*- coding: utf-8 -*-
import os, re, json
ROOT = os.path.abspath('.')
DOC = os.path.join(ROOT, 'DOCUMENTACION')

# nombre -> (dir real, [?] esperado del director, etiqueta director)
CAND = {
    '21-Dialogos': (31, 'M21 Dialogos'),
    '33-Agricultura': (30, 'M33 Agricultura'),
    '15-Recursos': (30, 'M14 Recursos'),
    '31-Ciclo-Dia-Noche': (28, 'M30 Ciclo-Dia-Noche'),
    '61-Rendimiento': (28, 'M61 Rendimiento'),
    '37-Museos-Y-Colecciones': (27, 'M36 Museos'),
    '56-Fotografia': (26, 'M155 Fotos'),
    '53-UI-UX': (25, 'M52 UI-UX'),
    '138-Vertical-Slice': (25, 'M137 Vertical-Slice'),
    '45-Arte-3D': (24, 'M44 Arte-3D'),
}

out = {}
for dname, (exp, label) in CAND.items():
    cp = os.path.join(DOC, dname, 'plan-actual', '05-Checklist.md')
    if not os.path.isfile(cp):
        out[dname] = {'error':'sin checklist','exp':exp,'label':label}; continue
    lines = open(cp, encoding='utf-8', errors='replace').read().splitlines()
    q = len(re.findall(r'(?m)^\s*-\s*\[\?\]', '\n'.join(lines)))
    x = len(re.findall(r'(?m)^\s*-\s*\[x\]', '\n'.join(lines)))
    bl = len(re.findall(r'(?m)^\s*-\s*\[ \]', '\n'.join(lines)))
    out[dname] = {'exp':exp,'label':label,'q':q,'x':x,'blank':bl,
                  'path':os.path.relpath(cp,ROOT).replace('\\','/')}

json.dump(out, open('Temp/b61_byname.json','w',encoding='utf-8'), ensure_ascii=False, indent=1)
print('DIR                        director-label        exp  disco  dif  x')
for dname, v in out.items():
    if 'error' in v:
        print('%-26s %-20s %s' % (dname, v['label'], v['error'])); continue
    print('%-26s %-20s %3d  %3d   %+d  %3d' % (dname, v['label'][:20], v['exp'], v['q'], v['q']-v['exp'], v['x']))
