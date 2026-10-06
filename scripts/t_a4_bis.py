# -*- coding: utf-8 -*-
"""T-A4-bis: re-alinea M11 cols 5-10, reemplazo PUNTOAL que PRESERVA todos los bytes/EOL del
resto del archivo. Solo toca la linea M11 (interior). No hace split/join de todo el archivo.
"""
import re
P = r'CHECKLIST-GLOBAL.md'
s = open(P, encoding='utf-8', newline='').read()   # newline='' conserva \r\n

m = re.search(r'(?m)^\| 11 \|[^\n]*', s)
assert m, 'fila M11 no encontrada'
old_line = m.group(0)
ends_cr = old_line.endswith('\r')
body = old_line.rstrip('\r')

toks = re.split(r'(?<!\\)\|', body)[1:]
if toks and toks[-1].strip() == '':
    toks = toks[:-1]
assert len(toks) == 11, len(toks)
old = [x.strip() for x in toks]

model = 'DeepSeek-V4.1-Flash'
dates = re.findall(r'20\d\d-\d\d-\d\d \d\d:\d\d', old[5] + ' ' + old[6] + ' ' + old[9])
most_recent = max(dates) if dates else old[9]
notas = ' '.join(x for x in [old[7], old[9], old[10]] if x and x != '—').replace('|', '\\|')

new = list(old)
new[5] = '—'
new[6] = '—'
new[7] = model
new[8] = '—'
new[9] = most_recent
new[10] = notas

new_line = '| ' + ' | '.join(new) + ' |'
if ends_cr:
    new_line += '\r'

s2 = s.replace(old_line, new_line, 1)
assert s2 != s, 'no se reemplazo'
open(P, 'w', encoding='utf-8', newline='').write(s2)

r = open(P, 'rb').read()
print('M11 re-alineada (puntoal, EOL preservado)')
for k, v in enumerate(new):
    print(f'  [{k}] {v[:45]}')
print('CRLF=', r.count(b'\r\n'), 'bareCR=', r.count(b'\r') - r.count(b'\r\n'),
      'loneLF=', r.count(b'\n') - r.count(b'\r\n'), 'NUL=', r.count(b'\x00'))
