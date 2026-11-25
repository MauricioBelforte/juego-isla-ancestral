# -*- coding: utf-8 -*-
"""Reclasificacion estricta de los 91 'candidatos':
  delegado  -> texto nombra otro modulo como dueno (-> Mxx, — Mxx, integrar con Mxx, Mxx (...))
  pendiente -> autoría pendiente / iteraciones futuras / 'pendiente'
  verificable -> candidato real que podria flippearse con evidencia en disco
"""
import json, re, collections
d = json.load(open('Temp/b60_clasificacion.json', encoding='utf-8'))

MODREF = re.compile(
    r'(?:→|->|—|\(|\b)(?:M\d{2,3})\b'          # M任何引用做dueno
    r'|integrar con M\d|delegad|fuera de alcance|no duplica|solo delega|expone|emite|solo-escritura|observador pasivo'
    r'|requiere M\d|con M\d|para M\d', re.I)
PEND = re.compile(r'pendiente|iter 1|iter 2|futura|por definir|sin implementar|no implementado', re.I)

out = collections.Counter()
detail = collections.defaultdict(lambda: collections.Counter())
verificables = []
for mid, v in d.items():
    for it in v['items']:
        if it['cat'] != 'candidato':
            out[it['cat']] += 1
            detail[mid][it['cat']] += 1
            continue
        t = it['text']
        if MODREF.search(t):
            cat = 'delegado'
        elif PEND.search(t):
            cat = 'pendiente'
        else:
            cat = 'verificable'
            verificables.append((mid, it['line'], t))
        out[cat] += 1
        detail[mid][cat] += 1

print('MODULO        cand  delegado  pendiente  verificable')
for mid in ['75','156','74','73','71','27','159','49','105','115']:
    c = detail[mid]
    print('M%-4s  %5d  %5d  %5d  %5d' % (mid, c.get('candidato',0), c.get('delegado',0), c.get('pendiente',0), c.get('verificable',0)))
print('-'*50)
print('TOTALES', dict(out))
print()
print('VERIFICABLES (%d):' % len(verificables))
for mid, n, t in verificables:
    print(' M%-4s L%-4d %s' % (mid, n, t[:180]))
