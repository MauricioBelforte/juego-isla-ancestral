# -*- coding: utf-8 -*-
"""
T-A3: fix estructural de CHECKLIST-GLOBAL.md — version IDEMPOTENTE.
Split sobre pipes NO escapados ( (?<!\\)\| ) para no re-escapar pipes ya escapados.
- >11 celdas  -> cells[0:10] intactas + cells[10:] escapadas ('|'->'\\|') en la celda Notas.
- ==10 celdas -> insertar '—' en posicion 8 (celda 'Agente actual' colapsada).
- ==11 y sin pipe final -> agregar pipe final (normalizando CR sueltos a espacio).
No toca Estado(col2)/Progreso(col3). Preserva CRLF: solo se reconstruyen lineas objetivo,
cada una con su '\r' final; el resto del archivo queda byte-identico.
IDEMPOTENTE: si la fila ya esta en 11 celdas con pipes escapados y pipe final -> no-op.
Uso:  t_a3_fix2.py (preview)  |  t_a3_fix2.py --write
"""
import re, sys

P = r'CHECKLIST-GLOBAL.md'
text = open(P, 'rb').read().decode('utf-8')
lines = text.split('\n')

def split_cells(b):
    """(cells, has_final_pipe) usando solo pipes no escapados."""
    has_final = b.rstrip().endswith('|')
    toks = re.split(r'(?<!\\)\|', b)
    toks = toks[1:]
    if has_final and toks and toks[-1].strip() == '':
        toks = toks[:-1]
    return toks, has_final

changed = 0
for i, L in enumerate(lines):
    b = L.rstrip('\r')
    if not (b.startswith('| ') and re.match(r'^\|\s*[0-9]+\s*\|', b)):
        continue
    toks, has_final = split_cells(b)
    n = len(toks)
    new = None
    if n > 11:
        lead = [t.strip() for t in toks[0:10]]
        notas = '|'.join(toks[10:]).replace('\r', ' ').replace('\n', ' ')
        notas = notas.replace('|', '\\|').strip()
        new = '| ' + ' | '.join(lead) + ' | ' + notas + ' |'
    elif n == 10:
        cells = [t.strip() for t in toks]
        cells.insert(8, '—')
        new = '| ' + ' | '.join(cells) + ' |'
    elif n == 11 and not has_final:
        cells = [t.replace('\r', ' ').strip() for t in toks]
        new = '| ' + ' | '.join(cells) + ' |'
    else:
        continue
    lines[i] = new + '\r'
    changed += 1

print(f'filas de datos tocadas: {changed}')
# verificacion post: todas las filas de datos deben tener 11 celdas reales y pipe final
bad = 0
for i, L in enumerate(lines):
    b = L.rstrip('\r')
    if b.startswith('| ') and re.match(r'^\|\s*[0-9]+\s*\|', b):
        toks, has_final = split_cells(b)
        if len(toks) != 11 or not has_final:
            bad += 1
            print(f'  ⚠️ L{i+1} celdas={len(toks)} has_final={has_final}')
print(f'filas de datos !=11 o sin pipe final: {bad}')

if '--write' in sys.argv:
    open(P, 'wb').write('\n'.join(lines).encode('utf-8'))
    raw = open(P, 'rb').read()
    print('ESCRITO · CRLF=', raw.count(b'\r\n'), 'bareCR=', raw.count(b'\r') - raw.count(b'\r\n'),
          'LF=', raw.count(b'\n') - raw.count(b'\r\n'), 'NUL=', raw.count(b'\x00'))
else:
    print('PREVIEW. --write para aplicar.')
