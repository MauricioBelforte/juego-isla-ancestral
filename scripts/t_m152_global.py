# -*- coding: utf-8 -*-
import re
p = r'CHECKLIST-GLOBAL.md'
raw = open(p, 'rb').read().decode('utf-8')
lines = raw.split('\n')
note = (' **T (2026-10-05, agnes-3.0-flash, Log 1300): 28 de 29 [?] resueltos via '
        '`resolucion_pendiente_m152.md` (integraciones 5 + ejemplos->D-R1/D-R2 5 + metricas 5 + '
        'responsable 2 + pair/KS 4 + licencias/comunicacion 2). Queda 1 [?] = D-R2 '
        '(aprobacion del fundador). 201/202 - 1 [?].** ')
for i, L in enumerate(lines):
    b = L.rstrip('\r')
    if re.match(r'^\|\s*152\s*\|', b):
        nb = b
        nb = nb.replace('| 173/202 |', '| 201/202 |', 1)
        # actualizar Ultima actividad si es la que hay; anclar por el patron de la fila
        idx = nb.rfind('|')
        nb = nb[:idx] + note + nb[idx:]
        lines[i] = nb + '\r'
        print('M152 fila actualizada (Progreso 173/202 -> 201/202)')
        break
open(p, 'wb').write('\n'.join(lines).encode('utf-8'))
raw = open(p, 'rb').read()
print('CRLF=', raw.count(b'\r\n'), 'bareCR=', raw.count(b'\r') - raw.count(b'\r\n'), 'NUL=', raw.count(b'\x00'))
for L in raw.decode('utf-8').split('\n'):
    b = L.rstrip('\r')
    if re.match(r'^\|\s*152\s*\|', b):
        toks = re.split(r'(?<!\\)\|', b)[1:]
        if toks and toks[-1].strip() == '':
            toks = toks[:-1]
        print('M152 celdas:', len(toks), '| Prog:', [t.strip() for t in toks if '/' in t][:1])
