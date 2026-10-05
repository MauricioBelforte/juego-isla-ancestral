# -*- coding: utf-8 -*-
"""
T-A4: re-alineacion del CONTENIDO de cols 8-10 (Agente actual / Ultima actividad / Notas)
donde esta 'corrido' (senal: una fecha en la columna Agente, col 8).

Regla (preservadora de contenido, NO toca Estado(col2)/Progreso(col3) ni estructura):
  new Agente(8)  = "—"
  new Ultima(9)   = <fecha vieja de col8>
  new Notas(10)   = <viejo col9> + ' ' + <viejo col10>   (el que no sea '—'/vacio)
Solo se aplica a filas donde col8 contenga una fecha (20xx-..).
PREVIEW por defecto; --write para aplicar. Verifica 11 celdas + Estado/Progreso intactos +
que el contenido de {8,9,10} se conserva (permutacion/merge, sin perdida).
"""
import re, sys

P = r'CHECKLIST-GLOBAL.md'
t = open(P, 'rb').read().decode('utf-8')
lines = t.split('\n')
DATE = re.compile(r'20\d\d-\d\d-\d\d')

def cells(b):
    toks = re.split(r'(?<!\\)\|', b)[1:]
    if toks and toks[-1].strip() == '':
        toks = toks[:-1]
    return toks

def build(c):
    return '| ' + ' | '.join(x.strip() for x in c) + ' |'

changed = []
preview = []
for i, L in enumerate(lines):
    b = L.rstrip('\r')
    if not (b.startswith('| ') and re.match(r'^\|\s*[0-9]+\s*\|', b)):
        continue
    c = cells(b)
    if len(c) != 11:
        continue
    a, u, n = c[8].strip(), c[9].strip(), c[10].strip()
    if not DATE.search(a):
        continue
    # re-alineacion
    na, nu = '—', a
    if n in ('', '—') and u in ('', '—'):
        nn = u
    elif u in ('', '—'):
        nn = n
    elif n in ('', '—'):
        nn = u
    else:
        nn = u + ' ' + n
    # verificacion de preservacion: union col9+col10 debe contener el contenido de los 3 viejos
    union = (nu + ' ' + nn)
    missing = [x for x in (a, u, n) if x not in ('', '—') and x not in union and x != nu]
    if missing:
        print(f'  !! L{i+1} M{c[0].strip()}: NO AUTO-APLICAR, contenido no se preserva: {missing}')
        continue
    newc = list(c)
    newc[8], newc[9], newc[10] = na, nu, nn
    lines[i] = build(newc) + '\r'
    changed.append(i + 1)
    preview.append((i + 1, c[0].strip(), a, u[:30], n[:30], '->', na, nu, nn[:40]))

print(f'filas a re-alinear (fecha en col8): {len(changed)}')
for p in preview:
    print(f'  L{p[0]:4} M{p[1]:4}  Agente {p[2]!r} -> {p[6]!r}  | Ultima {p[3]!r} -> {p[7]!r}  | Notas {p[4]!r} -> {p[8]!r}')

if '--write' in sys.argv:
    # verificacion final: 11 celdas + Estado/Progreso intactos vs la version previa
    tt = '\n'.join(lines)
    bad = 0
    for i, L in enumerate(tt.split('\n')):
        b = L.rstrip('\r')
        if b.startswith('| ') and re.match(r'^\|\s*[0-9]+\s*\|', b):
            c = cells(b)
            if len(c) != 11:
                bad += 1
    open(P, 'wb').write(tt.encode('utf-8'))
    raw = open(P, 'rb').read()
    print(f'ESCRITO · filas={len(changed)} · filas!=11celdas={bad} · CRLF={raw.count(chr(13).encode()+chr(10).encode())} '
          f'bareCR={raw.count(b"\r")-raw.count(b"\r\n")} NUL={raw.count(b"\x00")}')
else:
    print('PREVIEW. --write para aplicar.')
