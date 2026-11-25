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

def strip_parens(s):
    prev = None
    while prev != s:
        prev = s
        s = re.sub(r'\([^()]*\)', '', s)
    return s

LINE_START = re.compile(r'^\s*(?:~~)?\s*(?:[-*>]\s*)*\*{0,2}Totales\b', re.I)
NUM_TOTAL = re.compile(r'^\s*Totales[^:]{0,80}:\s*(\d+)\s*(?:ítems|items|lineas-item|lineas)', re.I)
NUM_COMP = re.compile(r'Completados\s*:\s*(\d+)', re.I)
NUM_PEND = re.compile(r'Pendientes\s*:\s*(\d+)', re.I)
NUM_RES = re.compile(r'(?:No resueltos|Sin resolver)\s*:\s*(\d+)', re.I)

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
    cand = []
    for i, l in enumerate(lines, 1):
        if not LINE_START.match(l):
            continue
        norm = strip_parens(l.replace('~~', '').replace('*', '').replace('>', ''))
        norm = re.sub(r'^\s*[-]\s*', '', norm).strip()
        mn = NUM_TOTAL.match(norm)
        if not mn:
            continue
        cand.append({
            'mod': mid, 'path': os.path.relpath(r, ROOT), 'line': i, 'text': l.strip(),
            'norm': norm[:160], 'decl_total': int(mn.group(1)),
            'decl_x': int(NUM_COMP.search(norm).group(1)) if NUM_COMP.search(norm) else None,
            'decl_pend': int(NUM_PEND.search(norm).group(1)) if NUM_PEND.search(norm) else None,
            'decl_res': int(NUM_RES.search(norm).group(1)) if NUM_RES.search(norm) else None,
            'real_x': c['x'], 'real_blanco': c[' '], 'real_q': c['?'], 'real_total': real_total,
            'struck': l.lstrip().startswith('~~'),
        })
    if not cand:
        continue
    a = cand[0]
    a['total_candidates'] = len(cand)
    a['all_candidates'] = [{'line': x['line'], 'decl_total': x['decl_total'], 'struck': x['struck']} for x in cand]
    a['d_total'] = a['decl_total'] - a['real_total']
    a['d_x'] = (a['decl_x'] - a['real_x']) if a['decl_x'] is not None else None
    a['d_total_vs_x'] = a['decl_total'] - a['real_x']
    rows.append(a)

rows.sort(key=lambda a: int(a['mod']))
json.dump(rows, open(os.path.join(ROOT,'Temp','b59_totales_strict.json'),'w',encoding='utf-8'), ensure_ascii=False, indent=1)

def report(label, key, pred=lambda a: True):
    hits = [a for a in rows if pred(a) and a[key] is not None and abs(a[key]) > 5]
    print(label, len(hits), [a['mod'] for a in hits])
    return hits

print('lineas Totales canonicas:', len(rows))
h1 = report('abs(decl_total-real_total)>5', 'd_total', lambda a: not a['struck'])
h2 = report('abs(decl_x-real_x)>5       ', 'd_x', lambda a: not a['struck'])
h3 = report('abs(decl_total-real_x)>5   ', 'd_total_vs_x', lambda a: not a['struck'])
print()
for mid in ['122','91','40','106','18','72','09','114','105','112','116','118','107','119','30','31','38','32','150','73','157','163','23']:
    a = next((x for x in rows if x['mod']==mid), None)
    if a: print('M%-4s L%-4d dT=%-5s dX=%-5s dTx=%-5s struck=%s cands=%s'%(mid,a['line'],a['d_total'],a['d_x'],a['d_total_vs_x'],a['struck'],a['all_candidates']))
    else: print('M%s SIN linea canonica'%mid)
print()
print('--- 13 por d_total ---')
for a in h1: print(' M%-4s L%-4d declT=%-4s realT=%-4s dT=%-4s declX=%-4s realX=%-4s dX=%-4s'%(a['mod'],a['line'],a['decl_total'],a['real_total'],a['d_total'],a['decl_x'],a['real_x'],a['d_x']))
