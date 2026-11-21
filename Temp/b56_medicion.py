#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Medicion de la tanda b56. Solo lectura; salida JSON en Temp/b56_mediciones.json."""
import os, re, json, collections

ROOT = os.path.abspath('.')
GAME = os.path.join(ROOT, 'game', 'isla-ancestral')
DOC = os.path.join(ROOT, 'DOCUMENTACION')
EXCL = {'.git', '.workbuddy-ai', '.kilo', 'Godot'}

def walk(base, skip_addons=False):
    for root, dirs, files in os.walk(base):
        dirs[:] = [d for d in dirs if d not in EXCL and not (skip_addons and d == 'addons')]
        for f in files:
            yield os.path.join(root, f), f

def read(p):
    with open(p, encoding='utf-8', errors='replace') as fh:
        return fh.read()

def checklist_path(mid):
    pre = '%d-' % int(mid)
    for root, dirs, files in os.walk(DOC):
        if '.kilo' in root:
            continue
        for d in dirs:
            pass
        for f in files:
            if f == '05-Checklist.md' and os.path.basename(root) == 'plan-actual':
                parent = os.path.basename(os.path.dirname(root))
                if parent.startswith(pre):
                    return os.path.join(root, f)
    return None

def counts(p):
    s = read(p)
    return {k: len(re.findall(r'(?m)^\s*- \[%s\]' % re.escape(k), s)) for k in ['x', '?', ' ']}

out = {}

# --- A: root cause [?] ---
MODS = sorted(set(
    os.path.basename(os.path.dirname(os.path.dirname(r)))[:os.path.basename(os.path.dirname(os.path.dirname(r))).find('-')]
    for r, f in walk(DOC)
    if f == '05-Checklist.md' and os.path.basename(os.path.dirname(r)) == 'plan-actual'
    and re.search(r'(?m)^\s*- \[\?\]', read(r))
), key=lambda x: int(x) if x.isdigit() else 999)
EXCL_PAT = re.compile(r'GATE|AUDIT|KnownIssue|known.?issue', re.I)
FILE_PAT = re.compile(r'[A-Za-z0-9_./\-]+\.(?:gd|tscn|tres|md|png|blend|glb|json|cfg|import|po|shader|svg)')
IDENT_PAT = re.compile(r'`([A-Za-z_][A-Za-z0-9_]{3,})`')
A = []
BY_NAME = collections.defaultdict(list)
for r, f in walk(ROOT):
    if '.kilo' not in r and '.git' not in r:
        BY_NAME[f].append(r)
SRC = [(r, read(r)) for r, f in walk(GAME, skip_addons=True)
       if f.endswith(('.gd', '.tscn', '.tres'))]
for mid in MODS:
    p = checklist_path(mid)
    if not p:
        A.append({'mod': mid, 'error': 'checklist no encontrada'})
        continue
    lines = read(p).splitlines()
    for i, line in enumerate(lines, 1):
        m = re.match(r'^\s*- \[\?\]\s*(.*)$', line)
        if not m:
            continue
        txt = m.group(1).strip()
        files = FILE_PAT.findall(txt)
        exist = []
        for token in files:
            name = os.path.basename(token)
            if BY_NAME.get(name):
                exist.append({'pedido': token, 'encontrado': os.path.relpath(BY_NAME[name][0], ROOT)})
        idents = IDENT_PAT.findall(txt)
        grep = []
        if idents:
            needle = idents[0]
            for r, body in SRC:
                if needle in body:
                    grep.append(os.path.relpath(r, ROOT))
                    if len(grep) >= 3:
                        break
        if EXCL_PAT.search(txt):
            cause = 'fuera de alcance (GATE/AUDIT/KnownIssue)'
        elif exist and grep and re.search(r'no existe|crear|falta|ausente|implementar', txt, re.I):
            cause = 'CANDIDATO FLIP: archivo exacto presente + grep con hit'
        elif exist:
            cause = 'archivo exacto presente (sin grep unico)'
        elif re.search(r'KnownIssue|known.?issue', txt, re.I):
            cause = 'KnownIssue'
        elif re.search(r'decidir|definir|pendiente de decision|\?', txt, re.I):
            cause = 'decision pendiente'
        elif re.search(r'fase|futuro|post-|postgame|v2|planificad|deuda|pendiente', txt, re.I):
            cause = 'deuda documentada / alcance posterior'
        else:
            cause = 'sin evidencia automatica: requiere lectura humana'
        A.append({'mod': mid, 'linea': i, 'texto': txt[:300], 'causa': cause,
                  'archivos': exist, 'grep': grep})
out['A'] = A
out['A_resumen'] = {
    'items': len([a for a in A if 'linea' in a]),
    'por_modulo': dict(collections.Counter(a['mod'] for a in A if 'linea' in a)),
    'por_causa': dict(collections.Counter(a['causa'] for a in A if 'linea' in a)),
}
out['A_reales'] = {mid: counts(checklist_path(mid)) for mid in MODS if checklist_path(mid)}

# --- B: audio ---
audio_ext = ('.wav', '.ogg', '.mp3')
b_files = {}
for base in [GAME, DOC]:
    c = collections.Counter()
    paths = []
    for r, f in walk(base):
        if f.lower().endswith(audio_ext):
            c[os.path.splitext(f)[1].lower()] += 1
            if len(paths) < 5:
                paths.append(os.path.relpath(r, ROOT))
    b_files[os.path.relpath(base, ROOT)] = {'conteo': dict(c), 'ejemplos': paths}
refs = []
missing = []
for r, f in walk(GAME, skip_addons=True):
    if not f.endswith(('.gd', '.tres', '.tscn')):
        continue
    for n, line in enumerate(read(r).splitlines(), 1):
        for m in re.finditer(r'res://[^\s"\']+\.(?:wav|ogg|mp3)', line):
            rel = m.group(0)[6:]
            refs.append((os.path.relpath(r, ROOT), n, rel))
            if not os.path.exists(os.path.join(GAME, rel)):
                missing.append((os.path.relpath(r, ROOT), n, rel))
proc = []
for r, f in walk(GAME, skip_addons=True):
    if f.endswith('.gd'):
        s = read(r)
        if re.search(r'AudioStreamGenerator|generate|procedural|sin\.ruido|noise', s, re.I):
            proc.append(os.path.relpath(r, ROOT))
out['B'] = {'archivos': b_files, 'refs': len(refs), 'refs_rotas': len(missing),
            'ej_refs_rotas': missing[:20], 'generacion_procedural': proc[:20]}

# --- C: .tres ---
tres = [r for r, f in walk(GAME) if f.endswith('.tres')]
_extra = [os.path.join(GAME, 'Godot', f) for f in os.listdir(os.path.join(GAME, 'Godot'))
          if f.endswith('.tres')] if os.path.isdir(os.path.join(GAME, 'Godot')) else []
for r, f in walk(os.path.join(GAME, 'Godot', 'app_userdata')) if os.path.isdir(os.path.join(GAME, 'Godot', 'app_userdata')) else []:
    if f.endswith('.tres'):
        _extra.append(r)
tres = sorted(set(tres + _extra))
nulls = []
empties = []
broken = []
badpath = []
classfits = []
for p in tres:
    s = read(p)
    rel = os.path.relpath(p, ROOT)
    ids = set(re.findall(r'(?m)^\s*\[?(?:ext_resource|sub_resource)\b.*?\bid\s*=\s*"?([^"\s\]]+)', s))
    for n, line in enumerate(s.splitlines(), 1):
        if re.search(r'=\s*null\s*$', line):
            nulls.append((rel, n, line.strip()[:120]))
        if re.search(r'=\s*""\s*$', line):
            empties.append((rel, n, line.strip()[:120]))
        for m in re.finditer(r'(?:ExtResource|SubResource)\("([^"]+)"\)', line):
            if m.group(1) not in ids:
                broken.append((rel, n, m.group(1)))
        m = re.search(r'\[ext_resource\b.*?path="res://([^"]+)"', line)
        if m:
            if not os.path.exists(os.path.join(GAME, m.group(1))):
                badpath.append((rel, n, m.group(1)))
    m = re.search(r'^\[gd_resource\s+type="([^"]+)"(?:\s+script_class="([^"]+)")?', s, re.M)
    if m:
        typ, sc = m.group(1), m.group(2)
        sm = re.search(r'(?m)^script\s*=\s*ExtResource\("([^"]+)"\)', s)
        if sm:
            pm = re.search(r'\[ext_resource\b[^"]*path="res://([^"]+\.gd)"[^"]*\bid="%s"' % re.escape(sm.group(1)), s)
            if pm and os.path.exists(os.path.join(GAME, pm.group(1))):
                g = read(os.path.join(GAME, pm.group(1)))
                cn = re.search(r'(?m)^class_name\s+(\w+)', g)
                if cn and cn.group(1) != typ and (not sc or cn.group(1) != sc):
                    classfits.append((rel, typ, sc or '', cn.group(1), pm.group(1)))
out['C'] = {'tres': len(tres), 'nulls': len(nulls), 'nulls_ej': nulls[:20],
            'vacios': len(empties), 'vacios_ej': empties[:20],
            'refs_rotas': len(broken), 'refs_rotas_ej': broken[:20],
            'paths_rotos': len(badpath), 'paths_rotos_ej': badpath[:20],
            'class_name_inconsistente': len(classfits), 'class_ej': classfits[:20]}

# --- D: .import ---
imps = [r for r, f in walk(GAME) if f.endswith('.import')]
orph = []
no_source = []
for p in imps:
    s = read(p)
    m = re.search(r'(?m)^source_file="res://([^"]+)"', s)
    if not m:
        no_source.append(os.path.relpath(p, ROOT))
    elif not os.path.exists(os.path.join(GAME, m.group(1))):
        orph.append((os.path.relpath(p, ROOT), m.group(1)))
out['D'] = {'import': len(imps), 'sin_source_file': len(no_source),
            'orphaned': len(orph), 'orphaned_ej': orph[:30],
            'orphaned_en_addons': len([o for o in orph if 'addons' in o[0]])}

# --- E: i18n ---
E = {}
for loc in ['en', 'es', 'pt']:
    p = os.path.join(GAME, 'locales', loc + '.po')
    s = read(p)
    blocks = re.split(r'(?=\n?msgid )', s)
    empty = []
    fuzzy = 0
    for b in blocks:
        mi = re.search(r'(?m)^msgid\s+"(.*)"', b)
        ms = re.search(r'(?m)^msgstr\s+"(.*)"', b)
        if mi and ms and mi.group(1) and not ms.group(1):
            empty.append({'msgid': mi.group(1)[:120], 'fuzzy': '#, fuzzy' in b,
                          'contexto': (re.search(r'(?m)^msgctxt\s+"(.*)"', b).group(1) if re.search(r'(?m)^msgctxt\s+"(.*)"', b) else '')})
        if '#, fuzzy' in b:
            fuzzy += 1
    E[loc] = {'msgstr_vacios': len(empty), 'fuzzy': fuzzy, 'ej': empty[:15]}
out['E'] = E

# --- F: cross-doc ---
rows = []
for line in read(os.path.join(ROOT, 'CHECKLIST-GLOBAL.md')).splitlines():
    m = re.match(r'^\|\s*(\d{2,3})\s*\|\s*([^|]+)\|\s*([^|]*)\|\s*(\d+)\s*/\s*(\d+)', line)
    if m:
        mid = int(m.group(1))
        cp = checklist_path('%02d' % mid) or checklist_path('%03d' % mid)
        if cp:
            c = counts(cp)
            rows.append({'id': mid, 'modulo': m.group(2).strip(),
                         'global': int(m.group(4)), 'global_total': int(m.group(5)),
                         'real_x': c['x'], 'real_q': c['?'], 'real_blanco': c[' '],
                         'delta': int(m.group(4)) - c['x']})
top = sorted(rows, key=lambda r: -r['real_x'])[:20]
out['F'] = {'filas': len(rows), 'top20': top,
            'top20_con_drift': [r for r in top if r['delta'] != 0],
            'todos_con_drift': len([r for r in rows if r['delta'] != 0])}

with open(os.path.join(ROOT, 'Temp', 'b56_mediciones.json'), 'w', encoding='utf-8') as fh:
    json.dump(out, fh, ensure_ascii=False, indent=1)

print('A items:', out['A_resumen'])
print('B:', out['B']['archivos'], 'refs', out['B']['refs'], 'rotas', out['B']['refs_rotas'])
print('C:', {k: v for k, v in out['C'].items() if isinstance(v, int)})
print('D:', {k: v for k, v in out['D'].items() if isinstance(v, int)})
print('E:', {k: (v['msgstr_vacios'], v['fuzzy']) for k, v in out['E'].items()})
print('F:', 'filas', out['F']['filas'], 'drift top20', len(out['F']['top20_con_drift']), 'drift total', out['F']['todos_con_drift'])
