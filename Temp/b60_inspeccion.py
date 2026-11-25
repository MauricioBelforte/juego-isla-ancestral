# -*- coding: utf-8 -*-
import os, re, json
ROOT = os.path.abspath('.')
DOC = os.path.join(ROOT, 'DOCUMENTACION')

TARGETS = {
    '75': 'Postgame', '156': 'Terrenos', '74': 'Eventos', '73': 'Coleccionables',
    '71': 'Progresion', '27': 'Islas', '159': 'Catalogo', '49': 'Iluminacion',
    '115': 'Hardware', '105': 'Telemetria',
}

def find_checklist(mid):
    pre = mid + '-'
    for d in sorted(os.listdir(DOC)):
        if not d.startswith(pre):
            continue
        cp = os.path.join(DOC, d, 'plan-actual', '05-Checklist.md')
        if os.path.isfile(cp):
            return cp
    # buscar alternativo
    for r, ds, fs in os.walk(DOC):
        for f in fs:
            if f.startswith('05-Checklist') and f.endswith('.md'):
                parent = os.path.basename(os.path.dirname(os.path.dirname(r)))
                if parent.startswith(pre):
                    return os.path.join(r, f)
    return None

out = {}
for mid in TARGETS:
    cp = find_checklist(mid)
    if not cp:
        out[mid] = {'error': 'sin checklist'}
        continue
    lines = open(cp, encoding='utf-8', errors='replace').read().splitlines()
    qs = [(i + 1, l.strip()) for i, l in enumerate(lines) if re.match(r'^\s*-\s*\[\?\]', l)]
    xs = len(re.findall(r'(?m)^\s*-\s*\[x\]', '\n'.join(lines)))
    bl = len(re.findall(r'(?m)^\s*-\s*\[ \]', '\n'.join(lines)))
    out[mid] = {'path': os.path.relpath(cp, ROOT), 'q': len(qs), 'x': xs, 'blank': bl,
                'sample': [{'line': n, 'text': t[:180]} for n, t in qs[:6]]}

json.dump(out, open('Temp/b60_inspeccion.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
for mid, v in out.items():
    if 'error' in v:
        print('M%s %s' % (mid, v['error']))
        continue
    print('=== M%s %s | [?]=%d x=%d [ ]=%d | %s' % (mid, TARGETS[mid], v['q'], v['x'], v['blank'], v['path']))
    for s in v['sample']:
        print('   L%d %s' % (s['line'], s['text']))
