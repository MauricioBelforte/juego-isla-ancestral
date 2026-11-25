import os, re, json

ROOT = os.path.abspath('.')
DOC = os.path.join(ROOT, 'DOCUMENTACION')

def walk(base):
    for r, ds, fs in os.walk(base):
        ds[:] = [d for d in ds if d not in ('.git', '.workbuddy-ai', '.kilo', '.godot')]
        for f in fs:
            yield os.path.join(r, f), f

def read(p):
    return open(p, encoding='utf-8', errors='replace').read()

def marks(s):
    return {k: len(re.findall(r'(?m)^\s*- \[' + re.escape(k) + r'\]', s)) for k in ('x', ' ', '?')}

# patron: Totales ... **: N items/ítems/lineas-item ; y complementos
PAT_N = re.compile(r'Totales[^*]*(?:\*\*)?\s*:?\s*\*{0,2}\s*(\d+)\s*(?:ítems|items|lineas-item|lineas|lineas-)', re.I)
PAT_COMP = re.compile(r'Completados\s*:\s*(\d+)', re.I)
PAT_PEND = re.compile(r'Pendientes\s*:\s*(\d+)', re.I)
PAT_RES = re.compile(r'(?:No resueltos|Sin resolver)\s*:\s*(\d+)', re.I)

rows = []
for r, f in walk(DOC):
    if f != '05-Checklist.md' or os.path.basename(os.path.dirname(r)) != 'plan-actual':
        continue
    parent = os.path.basename(os.path.dirname(os.path.dirname(r)))
    m = re.match(r'^(\d+)-', parent)
    if not m:
        continue
    mid = m.group(1)
    s = read(r)
    lines = s.splitlines()
    c = marks(s)
    real_total = c['x'] + c[' '] + c['?']
    best = None
    for i, l in enumerate(lines, 1):
        if not re.search(r'(?i)\bTotales\b', l):
            continue
        mn = PAT_N.search(l)
        if not mn:
            continue
        best = (i, l.strip(), int(mn.group(1)))
        break
    if not best:
        continue
    i, text, decl_total = best
    mc, mp, mr = PAT_COMP.search(text), PAT_PEND.search(text), PAT_RES.search(text)
    decl_x = int(mc.group(1)) if mc else None
    decl_pend = int(mp.group(1)) if mp else None
    decl_res = int(mr.group(1)) if mr else None
    rows.append({
        'mod': mid, 'path': os.path.relpath(r, ROOT), 'line': i, 'text': text,
        'decl_total': decl_total, 'real_total': real_total,
        'd_total': decl_total - real_total,
        'decl_x': decl_x, 'real_x': c['x'], 'd_x': (decl_x - c['x']) if decl_x is not None else None,
        'decl_pend': decl_pend, 'real_pend': c[' '],
        'decl_res': decl_res, 'real_q': c['?'],
    })

rows.sort(key=lambda a: -abs(a['d_total']))
gt5_total = [a for a in rows if abs(a['d_total']) > 5]
gt5_x = [a for a in rows if a['d_x'] is not None and abs(a['d_x']) > 5]
print(' TOTAL lineas Totales parseadas:', len(rows))
print(' abs(d_total)>5:', len(gt5_total), [a['mod'] for a in gt5_total])
print(' abs(d_x)>5:', len(gt5_x), [a['mod'] for a in gt5_x])
print(' interseccion:', [a['mod'] for a in gt5_total if any(b['mod']==a['mod'] for b in gt5_x)])
print()
for a in rows:
    if abs(a['d_total']) > 5 or (a['d_x'] is not None and abs(a['d_x'])>5):
        print(' ', a['mod'], 'L%d'%a['line'], 'decl_total',a['decl_total'],'real_total',a['real_total'],
              'dT',a['d_total'],'| decl_x',a['decl_x'],'real_x',a['real_x'],'dX',a['d_x'],
              '| pend',a['decl_pend'],a['real_pend'],'res',a['decl_res'],a['real_q'])
json.dump(rows, open(os.path.join(ROOT,'Temp','b59_totales.json'),'w',encoding='utf-8'), ensure_ascii=False, indent=1)
