import os, re, json, datetime

ROOT = os.path.abspath('.')
DOC = os.path.join(ROOT, 'DOCUMENTACION')
NOW = datetime.datetime.now()
STAMP = NOW.strftime('%Y-%m-%d_%H-%M-%S')

# ---------- A: fix 12 lineas Totales (criterio canonico scan_drift.py: ultima linea con "Totales") ----------
mods = json.load(open('Temp/b59_beam_replica.json', encoding='utf-8'))
targets = [m for m in mods if m['drift'] is not None and m['drift'] > 5]
assert len(targets) in (0, 12), len(targets)  # 0 = re-run (A ya aplicada)
A_done = []
for m in sorted(targets, key=lambda z: int(z['id'])):
    path = None
    for d in os.listdir(DOC):
        if d.startswith(m['id'] + '-'):
            cand = os.path.join(DOC, d, 'plan-actual', '05-Checklist.md')
            if os.path.isfile(cand):
                path = cand
                break
    assert path, m['id']
    text = open(path, encoding='utf-8').read()
    lines = text.splitlines()
    idx = [i for i, l in enumerate(lines) if 'Totales' in l][-1]
    old = lines[idx]
    rx = len(re.findall(r'^[-*]\s*\[x\]', text, re.M))
    sp = len(re.findall(r'^[-*]\s*\[ \]', text, re.M))
    q = len(re.findall(r'^[-*]\s*\[\?\]', text, re.M))
    total = rx + sp + q
    # reemplazar SOLO los numeros en la ultima linea Totales: N items, Completados, Pendientes, No resueltos
    new = old
    new = re.sub(r'(\bTotales\b[^*:\n]{0,80}[*`]{0,2}\s*:?\s*)(\d+)(\s*(?:ítems|items|lineas))',
                 lambda x: x.group(1) + str(total) + x.group(3), new, count=1, flags=re.I)
    new = re.sub(r'(Completados\s*:\s*)(\d+)', lambda x: x.group(1) + str(rx), new, count=1, flags=re.I)
    new = re.sub(r'(Pendientes\s*:\s*)(\d+)', lambda x: x.group(1) + str(sp), new, count=1, flags=re.I)
    new = re.sub(r'((?:No resueltos|Sin resolver)\s*:\s*)(\d+)', lambda x: x.group(1) + str(q), new, count=1, flags=re.I)
    assert new != old, 'sin cambio M' + m['id']
    # verificar que solo cambio esa linea y solo numeros
    assert len(new.split('|')) == len(old.split('|'))
    lines[idx] = new
    open(path, 'wb').write(('\n'.join(lines) + '\n').encode('utf-8'))
    A_done.append({'mod': m['id'], 'linea': idx + 1, 'antes': old.strip()[:120], 'despues': new.strip()[:120],
                   'real': '%d/%d/%d' % (rx, sp, q), 'drift': m['drift']})

# ---------- B: verificar 18 iconos y anotar KnownIssue en M53 ----------
B = json.load(open('Temp/b59_mediciones.json', encoding='utf-8'))['B']
missing = B['faltantes']
assert len(missing) == 18
m53 = None
for d in os.listdir(DOC):
    if d.startswith('53-'):
        cand = os.path.join(DOC, d, 'plan-actual', '05-Checklist.md')
        if os.path.isfile(cand):
            m53 = cand
            break
assert m53
text = open(m53, encoding='utf-8').read()
anchor = '**KnownIssue b59 (logros.json:** 18 refs `res://assets/ui/logros/*.png` inexistentes en todo el repo;'
note = ('\n\n> ' + anchor + ' verificadas por nombre exacto el ' + STAMP[:10] +
        '. Iconos: ' + ', '.join(missing) +
        '. Solo documentado (T59-09); sin crear archivos ni fixear codigo. Ver Log 2438.\n')
if anchor not in text:
    open(m53, 'wb').write((text.rstrip('\n') + note).encode('utf-8'))

# ---------- C: clasificar 79 [ ] de M01 (sin tocar marcas) ----------
m01 = os.path.join(DOC, '01-Fundamentos-Del-Proyecto', 'plan-actual', '05-Checklist.md')
lines = open(m01, encoding='utf-8').read().splitlines()
C = []
for i, l in enumerate(lines, 1):
    m = re.match(r'^\s*-\s*\[\s\]\s*(\*\*M(\d+)\*\*.*)$', l)
    if not m:
        continue
    body = m.group(1)
    rojo = '🔴' in body
    amarillo = '🟡' in body
    verde = '🟢' in body
    cls = 'FUNDAMENTAL (bloquea v1.0)' if rojo else ('IMPORTANTE (no bloquea)' if amarillo else 'NICE-TO-HAVE / post-v1.0')
    C.append({'linea': i, 'mod': m.group(2), 'clase': cls,
              'texto': re.sub(r'\s+', ' ', body)[:120]})
assert len(C) == 79, len(C)

if not A_done:
    # A ya aplicada en el primer intento: reconstruir detalle desde replica (post-fix)
    for m in sorted(mods, key=lambda z: int(z['id'])):
        if m['id'] in ['18','26','28','31','35','37','63','72','104','106','160','164']:
            A_done.append({'mod': m['id'], 'linea': None, 'antes': 'ver git diff',
                           'despues': m['ultima'], 'real': '%d/%d/%d' % (m['real_x'], 0, 0),
                           'drift': m['drift']})
out = {'A': A_done, 'B': {'faltantes': missing, 'm53': os.path.relpath(m53, ROOT)}, 'C': C,
       'stamp': STAMP}
json.dump(out, open('Temp/b59_aplicado.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print('A fixes:', len(A_done))
for a in A_done:
    print('  M%-4s L%-4s %s' % (a['mod'], a['linea'], a['real']))
print('B: 18 faltantes, KnownIssue en', os.path.relpath(m53, ROOT))
print('C: 79 clasificados', {c['clase']: sum(1 for x in C if x['clase'] == c['clase']) for c in C})
