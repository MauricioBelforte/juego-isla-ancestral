import os, re, json, unicodedata

ROOT = os.path.abspath('.')
DOC = os.path.join(ROOT, 'DOCUMENTACION')
GAME = os.path.join(ROOT, 'game', 'isla-ancestral')

def walk(base):
    for r, ds, fs in os.walk(base):
        ds[:] = [d for d in ds if d not in ('.git', '.workbuddy-ai', '.kilo', '.godot')]
        for f in fs:
            yield os.path.join(r, f), f

def read(p):
    return open(p, encoding='utf-8', errors='replace').read()

def marks(s):
    return {k: len(re.findall(r'(?m)^\s*- \[' + re.escape(k) + r'\]', s)) for k in ('x', ' ', '?')}

def cp_path(mid):
    pre = '%d-' % int(mid)
    for r, f in walk(DOC):
        if f == '05-Checklist.md' and os.path.basename(os.path.dirname(r)) == 'plan-actual':
            parent = os.path.basename(os.path.dirname(os.path.dirname(r)))
            if parent.startswith(pre):
                return r
    return None

out = {}

# ---- A: drifts "Totales" ----
A = []
for r, f in walk(DOC):
    if f != '05-Checklist.md' or os.path.basename(os.path.dirname(r)) != 'plan-actual':
        continue
    parent = os.path.basename(os.path.dirname(os.path.dirname(r)))
    m = re.match(r'^(\d+)-', parent)
    if not m:
        continue
    mid = m.group(1)
    lines = read(r).splitlines()
    c = marks('\n'.join(lines))
    total = c['x'] + c[' '] + c['?']
    tot_lines = [(i + 1, l.strip()) for i, l in enumerate(lines)
                 if re.search(r'(?i)^\s*[-*#]*\s*\*\*?totales?\b', l) and '|' not in l]
    declared = None
    for n, l in tot_lines:
        nums = re.findall(r'\d+', l)
        if nums:
            declared = (n, l, int(nums[0]))
            break
    if declared and declared[2] != total:
        A.append({'mod': mid, 'path': os.path.relpath(r, ROOT), 'decl_line': declared[0],
                  'decl_text': declared[1], 'declared': declared[2], 'real_x': c['x'],
                  'real_blanco': c[' '], 'real_q': c['?'], 'total': total,
                  'delta': declared[2] - total})
A.sort(key=lambda a: -abs(a['delta']))
out['A'] = A
out['A_top13'] = [a for a in A if abs(a['delta']) > 5]

# ---- B: logros iconos ----
B = {'refs': [], 'encontrados': [], 'faltantes': []}
p = os.path.join(GAME, 'data', 'logros', 'logros.json')
s = read(p)
refs = sorted(set(re.findall(r'res://assets/ui/logros/([^\"\s]+\.png)', s)))
idx = {}
for r, f in walk(ROOT):
    idx.setdefault(f, []).append(os.path.relpath(r, ROOT).replace('\\', '/'))
for name in refs:
    B['refs'].append(name)
    if name in idx:
        B['encontrados'].append({'name': name, 'where': idx[name][:4]})
    else:
        B['faltantes'].append(name)
B['total_refs'] = len(refs)
B['total_encontrados'] = len(B['encontrados'])
B['total_faltantes'] = len(B['faltantes'])

# otros png en assets/ui/logros y rutas alternas por stem
stem_match = {}
for name in B['faltantes']:
    stem = os.path.splitext(name)[0]
    hits = [v for k, vv in idx.items() if os.path.splitext(k)[0] == stem for v in vv]
    if hits:
        stem_match[name] = hits[:4]
B['por_stem'] = stem_match
out['B'] = B

# ---- C: M01 blanks ----
cpath = cp_path('01')
C = {'path': os.path.relpath(cpath, ROOT) if cpath else None, 'items': [], 'marks': None}
if cpath:
    lines = read(cpath).splitlines()
    C['marks'] = marks('\n'.join(lines))
    for i, l in enumerate(lines, 1):
        m = re.match(r'^\s*-\s*\[\s\]\s*(.*)$', l)
        if m:
            C['items'].append({'linea': i, 'texto': re.sub(r'\s+', ' ', m.group(1)).strip()})
out['C'] = C

json.dump(out, open(os.path.join(ROOT, 'Temp', 'b59_mediciones.json'), 'w', encoding='utf-8'),
          ensure_ascii=False, indent=1)

print('A modulos con Totales drift:', len(A), '| abs(delta)>5:', len(out['A_top13']))
for a in out['A_top13'][:20]:
    print('  ', a['mod'], 'decl', a['declared'], 'real', a['total'], 'delta', a['delta'], 'L', a['decl_line'])
print('B refs', B['total_refs'], 'encontrados', B['total_encontrados'], 'faltantes', B['total_faltantes'])
for n in B['faltantes'][:20]: print('   FALTA', n)
for n, h in stem_match.items(): print('   STEM', n, h)
print('C path', C['path'], 'marks', C['marks'], 'blancos', len(C['items']))
