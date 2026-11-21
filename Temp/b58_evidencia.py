#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Evidencia estricta de los candidatos a flip b58."""
import os, re, json, unicodedata

ROOT = os.path.abspath('.')
DOC = os.path.join(ROOT, 'DOCUMENTACION')
GAME = os.path.join(ROOT, 'game', 'isla-ancestral')
insp = json.load(open(os.path.join(ROOT, 'Temp', 'b58_inspeccion.json'), encoding='utf-8'))

def norm(s):
    s = unicodedata.normalize('NFKD', s).encode('ascii', 'ignore').decode('ascii').lower()
    s = re.sub(r'^\s*-\s*\[.\]\s*', '', s)
    s = s.split('-- agnes')[0].split('— **degradado')[0].split('— **DEGRADADO')[0]
    s = re.sub(r'\s+', ' ', s).strip().rstrip(' .')
    return s

def check(mid):
    pre = '%d-' % int(mid)
    for r, ds, fs in os.walk(DOC):
        if '05-Checklist.md' in fs and os.path.basename(r) == 'plan-actual':
            parent = os.path.basename(os.path.dirname(r))
            if parent.startswith(pre):
                return os.path.join(r, '05-Checklist.md')
    return None

# M49: evidencia en 03-Diseno y codigo
p49 = check('49')
diseno = open(os.path.join(os.path.dirname(p49), '03-Diseno.md'), encoding='utf-8', errors='replace').read()
sources = []
for r, ds, fs in os.walk(GAME):
    ds[:] = [d for d in ds if d not in ('.godot','Godot','addons')]
    for f in fs:
        if f.endswith(('.gd','.tscn','.json')):
            sources.append(os.path.join(r, f))
bodies = [(p, open(p, encoding='utf-8', errors='replace').read()) for p in sources]

ev49 = {}
for n, text in insp['49'].items():
    secs = re.findall(r'§\s*([\d.]+)', text)
    sec_ok = []
    for sec in secs:
        pat = re.escape(sec)
        sec_ok.append(bool(re.search(r'(?m)^#{1,5}\s*' + pat + r'\b|^' + pat + r'\s', diseno)))
    keys = []
    low = text.lower()
    if 'easing' in low: keys.append('easing')
    if 'luna' in low: keys.append('luna')
    if 'glow' in low or 'bloom' in low: keys.append('glow/bloom')
    if 'cueva' in low: keys.append('cueva')
    if 'subterraneo' in low: keys.append('subterraneo')
    if 'ambience' in low: keys.append('ambience')
    if 'interior_templo' in low: keys.append('interior_templo')
    if 'pcf' in low: keys.append('PCF')
    if 'cozy' in low: keys.append('cozy')
    hits = {}
    for k in keys:
        hits[k] = {'diseno': diseno.lower().count(k.lower()),
                   'code_files': sum(1 for _, b in bodies if k.lower() in b.lower())}
    ev49[n] = {'secciones': secs, 'seccion_en_diseno': sec_ok, 'hits': hits}

# M94: duplicados estrictos
p94 = check('94')
s94 = open(p94, encoding='utf-8').read().splitlines()
dup_lines = [64,73,74,85,90,91,102,103] + list(range(107,112)) + list(range(116,119)) + list(range(123,128)) + list(range(130,134)) + list(range(137,141)) + list(range(144,150)) + list(range(153,157)) + [163,164,171] + list(range(178,182)) + [187,190,192]
dups = []
for n in dup_lines:
    if n > len(s94): continue
    line = s94[n-1]
    m = re.search(r'duplicad[oa] id[éa]ntic[oa] de la l[íi]nea\s*(\d+)', line, re.I)
    first = int(m.group(1)) if m else None
    is_q = bool(re.match(r'^\s*- \[\?\]', line))
    first_line = s94[first-1] if first and first <= len(s94) else ''
    first_x = bool(re.match(r'^\s*- \[x\]', first_line))
    same = bool(first and norm(line) == norm(first_line))
    dups.append({'linea': n, 'es_interrogante': is_q, 'primera': first,
                 'primera_x': first_x, 'mismo_texto': same,
                 'norm': norm(line)[:110], 'first_norm': norm(first_line)[:110]})

out = {'M49': ev49, 'M94': dups,
       'M94_resumen': {
           'listados': len(dups),
           'interrogantes': sum(1 for d in dups if d['es_interrogante']),
           'duplicados_validos': sum(1 for d in dups if d['es_interrogante'] and d['primera_x'] and d['mismo_texto']),
           'no_validos': [d for d in dups if not (d['es_interrogante'] and d['primera_x'] and d['mismo_texto'])]}}
json.dump(out, open(os.path.join(ROOT,'Temp','b58_evidencia.json'),'w',encoding='utf-8'), ensure_ascii=False, indent=1)
print('M94 resumen', {k:v for k,v in out['M94_resumen'].items() if k!='no_validos'})
print('M94 no validos', len(out['M94_resumen']['no_validos']))
for d in out['M94_resumen']['no_validos'][:12]: print(' ',d)
print('M49 evidencia:')
for n,v in ev49.items(): print(' L%s'%n, v)
