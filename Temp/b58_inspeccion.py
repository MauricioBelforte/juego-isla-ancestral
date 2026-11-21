#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Inspeccion de los items b58 antes de cualquier flip."""
import os, re, json

ROOT = os.path.abspath('.')
DOC = os.path.join(ROOT, 'DOCUMENTACION')

def cp(mid):
    pre = '%d-' % int(mid)
    for r, ds, fs in os.walk(DOC):
        if '05-Checklist.md' in fs and os.path.basename(r) == 'plan-actual':
            parent = os.path.basename(os.path.dirname(r))
            if parent.startswith(pre):
                return os.path.join(r, '05-Checklist.md')
    return None

targets = {
 '49': [39,40,79,86,87,93,94,109,148,167],
 '16': [54],
 '115': [23,24,25,90,116,153],
 '105': [145,196,197,198,199,210,233],
}
out = {}
for mid, lines in targets.items():
    p = cp(mid)
    s = open(p, encoding='utf-8').read().splitlines()
    out[mid] = {}
    for n in lines:
        out[mid][n] = s[n-1] if n <= len(s) else 'FUERA DE RANGO'

# M94 duplicados segun Nemotron 305
m94 = cp('94')
s94 = open(m94, encoding='utf-8').read().splitlines()
dup_lines = [64,73,74,85,90,91,102,103] + list(range(107,112)) + list(range(116,119)) + list(range(123,128)) + list(range(130,134)) + list(range(137,141)) + list(range(144,150)) + list(range(153,157)) + [163,164,171] + list(range(178,182)) + [187,190,192]
out['94'] = {}
for n in dup_lines:
    line = s94[n-1] if n <= len(s94) else 'FUERA DE RANGO'
    m = re.search(r'duplicad[oa] id[éa]ntic[oa] de la l[íi]nea\s*(\d+)', line, re.I)
    first = int(m.group(1)) if m else None
    out['94'][n] = {'linea': line[:260], 'first': first,
                    'first_es_x': bool(first and re.match(r'^\s*- \[x\]', s94[first-1])) if first else False,
                    'mismo_texto': bool(first and re.sub(r'^\s*- \[\?\]\s*','',line).strip().split('DEGRADADO')[0].strip() == re.sub(r'^\s*- \[x\]\s*','',s94[first-1]).strip().split('DEGRADADO')[0].strip()) if first else False}

json.dump(out, open(os.path.join(ROOT,'Temp','b58_inspeccion.json'),'w',encoding='utf-8'), ensure_ascii=False, indent=1)
for mid in ['49','16','115','105']:
    print('=== M'+mid)
    for n,t in out[mid].items(): print(n, t[:230])
print('=== M94 duplicados:',len(out['94']),
      'con first x:',sum(1 for v in out['94'].values() if v['first_es_x']),
      'mismo texto:',sum(1 for v in out['94'].values() if v['mismo_texto']))
for n,v in out['94'].items():
    if not (v['first_es_x'] and v['mismo_texto']): print('  MAL',n,v)
