#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""b57: medicion + fix acotado de drifts en CHECKLIST-GLOBAL + volumen. Solo lectura salvo GLOBAL."""
import os, re, json, collections, configparser, datetime

ROOT = os.path.abspath('.')
GAME = os.path.join(ROOT, 'game', 'isla-ancestral')
DOC = os.path.join(ROOT, 'DOCUMENTACION')
GLOBAL = os.path.join(ROOT, 'CHECKLIST-GLOBAL.md')
EXCL = {'.git', '.workbuddy-ai', '.kilo'}

def walk(base, skip_addons=False):
    for root, dirs, files in os.walk(base):
        dirs[:] = [d for d in dirs if d not in EXCL and not (skip_addons and d == 'addons')]
        for f in files:
            yield os.path.join(root, f), f

def read(p):
    with open(p, encoding='utf-8', errors='replace') as fh:
        return fh.read()

def marks(p):
    s = read(p)
    return {k: len(re.findall(r'(?m)^\s*- \[%s\]' % re.escape(k), s)) for k in ['x', '?', ' ']}

CPATH = {}
for r, f in walk(DOC):
    if f == '05-Checklist.md' and os.path.basename(os.path.dirname(r)) == 'plan-actual':
        parent = os.path.basename(os.path.dirname(os.path.dirname(r)))
        m = re.match(r'^(\d+)-', parent)
        if m:
            CPATH[m.group(1)] = r

out = {'fecha': datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

# --- A/F: drifts GLOBAL ---
gl = read(GLOBAL).splitlines()
rows = []
for idx, line in enumerate(gl):
    m = re.match(r'^\|\s*(\d{2,3})\s*\|', line)
    if not m:
        continue
    mid = m.group(1)
    if mid not in CPATH:
        continue
    cells = line.split('|')
    if len(cells) < 5:
        continue
    prog = cells[4].strip()
    pm = re.match(r'^(\d+)/(\d+)$', prog)
    if not pm:
        continue
    c = marks(CPATH[mid])
    total = c['x'] + c['?'] + c[' ']
    g, gt = int(pm.group(1)), int(pm.group(2))
    rows.append({'linea': idx, 'id': mid, 'global': g, 'global_total': gt,
                 'real_x': c['x'], 'real_q': c['?'], 'real_blanco': c[' '],
                 'total': total, 'delta': g - c['x'], 'denom_delta': gt - total})
drifts = [r for r in rows if r['delta'] != 0]
top20 = sorted(rows, key=lambda r: -r['real_x'])[:20]
out['A_pre'] = {'filas': len(rows), 'drifts': len(drifts),
                'denom_desalineados': len([r for r in rows if r['denom_delta'] != 0]),
                'lista': drifts, 'top20': top20}

# Aplicar SOLO celdas de progreso en filas con drift.
new = list(gl)
for r in drifts:
    line = new[r['linea']]
    cells = line.split('|')
    cells[4] = ' %d/%d ' % (r['real_x'], r['total'] if r['denom_delta'] else r['global_total'])
    new[r['linea']] = '|'.join(cells)
with open(GLOBAL, 'wb') as fh:
    fh.write(('\n'.join(new) + '\n').encode('utf-8'))

# Re-medir post
post = read(GLOBAL).splitlines()
post_rows = []
for idx, line in enumerate(post):
    m = re.match(r'^\|\s*(\d{2,3})\s*\|', line)
    if not m or m.group(1) not in CPATH:
        continue
    cells = line.split('|')
    if len(cells) < 5:
        continue
    pm = re.match(r'^(\d+)/(\d+)$', cells[4].strip())
    if not pm:
        continue
    c = marks(CPATH[m.group(1)])
    post_rows.append({'id': m.group(1), 'global': int(pm.group(1)),
                      'global_total': int(pm.group(2)), 'real_x': c['x'],
                      'delta': int(pm.group(1)) - c['x']})
out['A_post'] = {'filas': len(post_rows), 'drifts': len([r for r in post_rows if r['delta']]),
                 'top20': sorted(post_rows, key=lambda r: -r['real_x'])[:20],
                 'restantes': [r for r in post_rows if r['delta']]}

# --- B: data files ---
data = [r for r, f in walk(os.path.join(GAME, 'data'))
        if f.endswith(('.json', '.tres'))]
ext_count = collections.Counter(os.path.splitext(r)[1] for r in data)
errs = []
for p in data:
    e = os.path.splitext(p)[1]
    try:
        if e == '.json':
            json.load(open(p, encoding='utf-8'))
        elif e == '.cfg':
            cp = configparser.ConfigParser(strict=False)
            cp.read(p, encoding='utf-8')
        else:
            s = read(p)
            ids = set(re.findall(r'(?m)^\s*\[?(?:ext_resource|sub_resource)\b.*?\bid\s*=\s*"?([^"\s\]]+)', s))
            for m in re.finditer(r'(?:ExtResource|SubResource)\("([^"]+)"\)', s):
                if m.group(1) not in ids:
                    errs.append((os.path.relpath(p, ROOT), 'id roto ' + m.group(1)))
    except Exception as ex:
        errs.append((os.path.relpath(p, ROOT), type(ex).__name__ + ': ' + str(ex)[:90]))
refs, broken = [], []
for p in data:
    s = read(p)
    for n, line in enumerate(s.splitlines(), 1):
        for m in re.finditer(r'res://[^\s"\'\]),]+', line):
            rel = m.group(0)[6:].rstrip('\\/,);')
            if not rel or '::' in rel:
                continue
            refs.append((os.path.relpath(p, ROOT), n, rel))
            if not os.path.exists(os.path.join(GAME, rel)):
                broken.append((os.path.relpath(p, ROOT), n, rel))
out['B'] = {'archivos': len(data), 'por_extension': dict(ext_count),
            'errores': len(errs), 'errores_ej': errs[:30],
            'refs': len(refs), 'refs_rotas': len(broken), 'rotas_ej': broken[:30]}

# --- C: .tscn ---
tscn = [r for r, f in walk(GAME) if f.endswith('.tscn')]
ext_refs, ext_broken, no_root, multi_root = [], [], [], []
for p in tscn:
    s = read(p)
    rel = os.path.relpath(p, ROOT)
    ids = set(re.findall(r'(?m)^\s*\[?(?:ext_resource|sub_resource)\b.*?\bid\s*=\s*"?([^"\s\]]+)', s))
    for m in re.finditer(r'(?m)^\s*\[ext_resource\b[^\n]*?path="res://([^"]+)"', s):
        ext_refs.append((rel, m.group(1)))
        if not os.path.exists(os.path.join(GAME, m.group(1))):
            ext_broken.append((rel, m.group(1)))
    for m in re.finditer(r'(?:ExtResource|SubResource)\("([^"]+)"\)', s):
        if m.group(1) not in ids:
            ext_broken.append((rel, 'ID rotos: ' + m.group(1)))
    roots = re.findall(r'(?m)^\[node\s+[^\]]*\broot\b[^\]]*\]', s)
    if not roots:
        first = re.search(r'(?m)^\[node\s+name="([^"]+)"\s+type="([^"]+)"', s)
        if not first:
            no_root.append(rel)
    if len(roots) > 1:
        multi_root.append((rel, len(roots)))
out['C'] = {'tscn': len(tscn), 'ext_refs': len(ext_refs), 'problems': len(ext_broken),
            'problems_ej': ext_broken[:30], 'sin_nodo_raiz': len(no_root),
            'sin_raiz_ej': no_root[:20], 'multi_root': len(multi_root), 'multi_ej': multi_root[:10]}

# --- D: audio ---
aud = collections.Counter()
locs = collections.defaultdict(list)
for r, f in walk(ROOT):
    e = os.path.splitext(f)[1].lower()
    if e in ('.wav', '.ogg', '.mp3', '.flac'):
        aud[e] += 1
        if len(locs[e]) < 6:
            locs[e].append(os.path.relpath(r, ROOT))
out['D'] = {'por_extension': dict(aud), 'ejemplos': dict(locs)}

# --- E: TODO/FIXME/HACK + autoloads ---
todos, files_with = [], set()
for r, f in walk(GAME, skip_addons=True):
    if not f.endswith('.gd'):
        continue
    for n, line in enumerate(read(r).splitlines(), 1):
        if re.search(r'\b(?:TODO|FIXME|HACK)\b', line):
            todos.append((os.path.relpath(r, ROOT), n, line.strip()[:150]))
            files_with.add(r)
autos = []
pg = read(os.path.join(GAME, 'project.godot'))
in_autoload = False
for line in pg.splitlines():
    if line.strip().startswith('[autoload]'):
        in_autoload = True
        continue
    if in_autoload and line.startswith('['):
        break
    if in_autoload:
        m = re.match(r'^\s*([A-Za-z_]\w*)\s*=\s*"([^"]+)"', line)
        if m:
            path = m.group(2)
            rel = path.lstrip('*')
            rel = rel[6:] if rel.startswith('res://') else rel
            full = os.path.join(GAME, rel)
            autos.append((m.group(1), path, os.path.exists(full)))
out['E'] = {'todo_count': len(todos), 'gd_files': len(files_with),
            'todos_ej': todos[:25], 'autoloads': len(autos),
            'autoloads_rotos': [a for a in autos if not a[2]]}

with open(os.path.join(ROOT, 'Temp', 'b57_mediciones.json'), 'w', encoding='utf-8') as fh:
    json.dump(out, fh, ensure_ascii=False, indent=1)
print('A pre drifts', out['A_pre']['drifts'], 'post', out['A_post']['drifts'])
print('A denom desalineados', out['A_pre']['denom_desalineados'])
print('B', out['B']['archivos'], dict(out['B']['por_extension']), 'errores', out['B']['errores'], 'refs rotas', out['B']['refs_rotas'])
print('C', out['C']['tscn'], 'problemas', out['C']['problems'], 'sin raiz', out['C']['sin_nodo_raiz'])
print('D', out['D']['por_extension'])
print('E', out['E']['todo_count'], out['E']['gd_files'], 'autoloads', out['E']['autoloads'], 'rotos', len(out['E']['autoloads_rotos']))
