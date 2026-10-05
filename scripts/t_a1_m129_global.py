# -*- coding: utf-8 -*-
import re
p = r'CHECKLIST-GLOBAL.md'
raw = open(p, 'rb').read().decode('utf-8')
lines = raw.split('\n')
note = (' **T-A1 (2026-10-05, agnes-3.0-flash, Log 1299): capa data+servicio implementada - '
        '`merchandising.json` v2 (10 prod) + `MerchManager` autoload (contrato "merch") + '
        'validator/test 24/0 + `merch_catalog.md`; 40 [ ] resueltos = 35 [x] + 5 [?] '
        '(dueño M45/M46 arte, M41 música, M53 web). 103/108 - 5 [?].** ')
changed = 0
for i, L in enumerate(lines):
    b = L.rstrip('\r')
    if re.match(r'^\|\s*129\s*\|', b):
        nb = b
        nb = nb.replace('🟡 Con dudas | 68/108 | Baja', '🟡 Con dudas | 103/108 | Baja', 1)
        nb = nb.replace('✓ agnes-3-flash | 2026-10-03 06:40 |', '✓ agnes-3-flash | 2026-10-05 01:45 |', 1)
        idx = nb.rfind('|')
        nb = nb[:idx] + note + nb[idx:]
        lines[i] = nb + '\r'
        changed += 1
        break
open(p, 'wb').write('\n'.join(lines).encode('utf-8'))
print('M129 cambiado:', changed)
raw = open(p, 'rb').read()
print('CRLF=', raw.count(b'\r\n'), 'bareCR=', raw.count(b'\r') - raw.count(b'\r\n'), 'NUL=', raw.count(b'\x00'))
for L in raw.decode('utf-8').split('\n'):
    b = L.rstrip('\r')
    if re.match(r'^\|\s*129\s*\|', b):
        toks = re.split(r'(?<!\\)\|', b)[1:]
        if toks and toks[-1].strip() == '':
            toks = toks[:-1]
        print('M129 celdas:', len(toks), '| Progreso:', [t.strip() for t in toks if '/' in t][:1])
