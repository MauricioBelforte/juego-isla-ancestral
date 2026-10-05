# -*- coding: utf-8 -*-
"""T-A4: detecta filas del GLOBAL donde el CONTENIDO de las cols 8-10 (Agente/Ultima/Notas)
esta 'corrido' — senal principal: una FECHA en la columna 'Agente actual' (col 8), que nunca
debe llevar fecha. Solo DETECTA (no modifica).
"""
import re

P = r'CHECKLIST-GLOBAL.md'
t = open(P, 'rb').read().decode('utf-8')
DATE = re.compile(r'20\d\d-\d\d-\d\d')

def cells(b):
    toks = re.split(r'(?<!\\)\|', b)[1:]
    if toks and toks[-1].strip() == '':
        toks = toks[:-1]
    return toks  # 11 celdas: [0]=ID..[10]=Notas

suspects = []
for i, L in enumerate(t.split('\n')):
    b = L.rstrip('\r')
    if not (b.startswith('| ') and re.match(r'^\|\s*[0-9]+\s*\|', b)):
        continue
    c = cells(b)
    if len(c) != 11:
        continue
    agente = c[8].strip()
    ultima = c[9].strip()
    notas = c[10].strip()
    rid = c[0].strip()
    # senal: fecha en Agente actual (col 8)
    if DATE.search(agente):
        suspects.append((i + 1, rid, agente[:24], ultima[:30], ('—' if notas in ('', '—') else notas[:30])))

print(f'filas con FECHA en columna Agente actual (col 8): {len(suspects)}')
for ln, rid, ag, ul, no in suspects:
    print(f'  L{ln:4} M{rid:4}  Agente={ag!r:26} Ultima={ul!r:32} Notas={no!r}')
