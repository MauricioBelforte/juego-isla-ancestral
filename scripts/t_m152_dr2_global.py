# -*- coding: utf-8 -*-
import re
p = r'CHECKLIST-GLOBAL.md'
raw = open(p, 'rb').read().decode('utf-8')
lines = raw.split('\n')
note = (' **Cierre D-R2 (2026-10-05, agnes-3.0-flash, Log 1313): el FUNDADOR aprobó la '
        'ampliacion parcial 2/3 patas (canal arch. 38). Ultimo [?] de M152 -> [x]. 202/202 - 0 [?]. '
        'M152 sigue 🟡 hasta la QA §21.8 de Hy3 (T-H5).** ')
for i, L in enumerate(lines):
    b = L.rstrip('\r')
    if re.match(r'^\|\s*152\s*\|', b):
        nb = b
        nb = nb.replace('| 201/202 |', '| 202/202 |', 1)
        idx = nb.rfind('|')
        nb = nb[:idx] + note + nb[idx:]
        lines[i] = nb + '\r'
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
