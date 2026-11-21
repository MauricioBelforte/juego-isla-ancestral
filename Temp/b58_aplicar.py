#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""b58: flips con evidencia + anotaciones KnownIssue. Verifica antes/despues."""
import os, re, json, unicodedata, datetime

ROOT = os.path.abspath('.')
DOC = os.path.join(ROOT, 'DOCUMENTACION')

def cp(mid):
    pre = '%d-' % int(mid)
    for r, ds, fs in os.walk(DOC):
        if '05-Checklist.md' in fs and os.path.basename(r) == 'plan-actual':
            parent = os.path.basename(os.path.dirname(r))
            if parent.startswith(pre):
                return os.path.join(r, '05-Checklist.md')
    raise RuntimeError(mid)

def counts(path):
    s = open(path, encoding='utf-8').read()
    return {k: len(re.findall(r'(?m)^\s*- \[%s\]' % re.escape(k), s)) for k in ['x','?',' ']}

def flips(path, linenos):
    lines = open(path, encoding='utf-8').read().split('\n')
    for n in linenos:
        assert re.match(r'^\s*- \[\?\]', lines[n-1]), (path, n, lines[n-1][:100])
        lines[n-1] = lines[n-1].replace('- [?]', '- [x]', 1)
    open(path, 'wb').write('\n'.join(lines).encode('utf-8'))

def annotate(path, items):
    """items: {linea: motivo}"""
    lines = open(path, encoding='utf-8').read().split('\n')
    for n, motivo in items.items():
        l = lines[n-1]
        assert re.match(r'^\s*- \[\?\]', l), (path, n)
        assert 'KnownIssue:' not in l, (path, n, 'ya etiquetado')
        lines[n-1] = l.rstrip() + '  **KnownIssue: ' + motivo + '**'
    open(path, 'wb').write('\n'.join(lines).encode('utf-8'))

P49, P94, P105, P115 = cp('49'), cp('94'), cp('105'), cp('115')
before = {m: counts(p) for m, p in [('49',P49),('94',P94),('105',P105),('115',P115)]}

FLIP49 = [39,40,86,87,93,94,148,167]
FLIP94 = [64,73,74,85,90,91,102,103,108,110,111,116,117,118,123,124,125,126,130,131,132,133,137,138,140,144,145,146,147,148,153,154,155,156,163,164,171,178,179,180,181,187,190]
KI105 = {
 196:'requiere volumen real de datos de gameplay (post-release); M105 ya emite puzzle_abandoned',
 197:'requiere volumen real de datos; M105 ya emite zone_ignored',
 198:'API track_* existe pero 1/13 trackers con productor real (Log 2075); analisis requiere volumen',
 199:'requiere volumen real; M105 ya emite time_to_first_* y session_duration',
 210:'documentacion legal editorial transversal, fuera de M105 (§5 documenta el flujo)',
 233:'integracion con M102 depende de volumen real de issues detectadas',
}
KI115 = {116:'test de hot-plug requiere gamepad fisico, fuera de headless'}

flips(P49, FLIP49)
flips(P94, FLIP94)
annotate(P105, KI105)
annotate(P115, KI115)
after = {m: counts(p) for m, p in [('49',P49),('94',P94),('105',P105),('115',P115)]}

assert after['49']['x'] == before['49']['x'] + len(FLIP49)
assert after['49']['?'] == before['49']['?'] - len(FLIP49)
assert after['94']['x'] == before['94']['x'] + len(FLIP94)
assert after['94']['?'] == before['94']['?'] - len(FLIP94)
for m in ['105','115']:
    assert after[m] == before[m], (m, before[m], after[m])

res = {'antes': before, 'despues': after,
       'flip49': FLIP49, 'flip94': FLIP94,
       'ki105': KI105, 'ki115': KI115}
json.dump(res, open(os.path.join(ROOT,'Temp','b58_aplicado.json'),'w',encoding='utf-8'), ensure_ascii=False, indent=1)
print('M49', before['49'], '->', after['49'])
print('M94', before['94'], '->', after['94'])
print('M105', before['105'], '->', after['105'])
print('M115', before['115'], '->', after['115'])
