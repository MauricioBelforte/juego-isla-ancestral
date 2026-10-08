# -*- coding: utf-8 -*-
"""
T-A3: fix estructural de CHECKLIST-GLOBAL.md.
- >11 celdas  -> cells[0:10] intactas + cells[10:] escapadas ('|'->'\\|') en la celda Notas.
- sin pipe final -> agregar '|'.
- ==10 celdas -> insertar '—' en la posicion 8 (celda 'Agente actual' colapsada) para llegar a 11.
No toca Estado(col2)/Progreso(col3). Preserva CRLF: solo se reconstruyen las lineas objetivo,
cada una terminando en '\r' (el resto del archivo queda byte-identico).
Uso:  python t_a3_fix.py            -> PREVIEW
       python t_a3_fix.py --write    -> escribir
"""
import subprocess, re, sys

P = r'CHECKLIST-GLOBAL.md'
text = open(P, 'rb').read().decode('utf-8')
lines = text.split('\n')            # cada elemento conserva su '\r' final (CRLF)

data_idx = []                       # indices de lineas de datos
for i, L in enumerate(lines):
    b = L.rstrip('\r')
    if b.startswith('| ') and re.match(r'^\|\s*([0-9]+)\s*\|', b):
        data_idx.append(i)

def rebuild(b):
    """Devuelve la linea reconstruida a 11 celdas (o None si ya es correcta)."""
    has_pipe = b.rstrip().endswith('|')
    parts = b.split('|')[1:]
    # si termina en |, la ultima parte (tras el pipe final) es basura/vacia
    if has_pipe and parts and parts[-1].strip() == '':
        parts = parts[:-1]
    n = len(parts)
    if n == 11 and has_pipe:
        # ya correcta (verificar que no tenga pipe sin escapar dentro de Notas)
        # no tocamos: una fila con 11 celdas y pipe final es estructuramente ok
        return None
    if n > 11:
        lead = [x.strip() for x in parts[0:10]]
        notas = '|'.join(parts[10:]).replace('\r', ' ').replace('|', '\\|').strip()
        return '| ' + ' | '.join(lead) + ' | ' + notas + ' |'
    if n == 10:
        # insertar '—' en la posicion 8 (Agente actual)
        new = [x.strip() for x in parts]
        new.insert(8, '—')
        return '| ' + ' | '.join(new) + ' |'
    if n == 11:
        if not has_pipe:
            cells = [x.replace('\r', ' ').strip() for x in parts]
            return '| ' + ' | '.join(cells) + ' |'
        return None
    return None  # n<10: no auto-fixear

changed = []
for i in data_idx:
    b = lines[i].rstrip('\r')
    new = rebuild(b)
    if new is not None:
        lines[i] = new + '\r'
        changed.append((i, new))

print(f'filas de datos: {len(data_idx)} · cambiadas: {len(changed)}')
# verificacion: todas las cambiadas deben quedar en 11 celdas
bad = 0
for i, new in changed:
    c = new.count('|') - 1          # pipes crudos
    # contar celdas ignorando pipes escapados
    real = new.replace('\\|', '~').count('|') - 1
    if real != 11:
        bad += 1
        print(f'  ⚠️ L{i+1} celdas_reales={real}  {new[:60]}')
print(f'filas cambiadas con !=11 celdas reales: {bad}')

if '--write' in sys.argv:
    open(P, 'wb').write('\n'.join(lines).encode('utf-8'))
    print('ESCRITO')
else:
    print('PREVIEW (sin escribir). --write para aplicar.')
