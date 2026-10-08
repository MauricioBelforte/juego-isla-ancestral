# -*- coding: utf-8 -*-
"""
T-A3: clasifica las 167 filas de datos de CHECKLIST-GLOBAL.md (desde git HEAD) y aplica
los fixes ESTRUCTURALES seguros:
  - Sobran celdas (>11, pipes sin escapar en Notas): unirlas en una celda Notas con '|'->'\\|'
  - Faltan pipe final: agregar '|'
  - Faltan celdas (10): NO se auto-fijan; se DUMPean para revision manual (punto de insercion
    semantico no deducible a ciegas).
Invariante: no tocar Estado (col 2) ni Progreso (col 3). Celdas 0-9 se preservan tal cual.
"""
import subprocess

P = r'CHECKLIST-GLOBAL.md'
head = subprocess.check_output(['git', 'show', 'HEAD:' + P]).decode('utf-8')

# separa cuerpo de tabla: filas que empiezan con '| ' y tienen ID numerico
import re
lines = head.split('\n')
data_rows = []
for i, L in enumerate(lines):
    b = L.rstrip('\r')
    if b.startswith('| ') and re.match(r'^\|\s*([0-9]+)\s*\|', b):
        data_rows.append((i, b))

def cells(b):
    return b.split('|')[1:]

fixable, missing = [], []
report = []
for i, b in data_rows:
    c = cells(b)
    # c incluye la posicion tras el pipe final (puede ser '' o '\r'-containing)
    n = len([x for x in c])  # crudo
    has_final_pipe = b.rstrip().endswith('|')
    # celdas "reales": si termina con |, la ultima parte es '' (o '\r'); descartar solo si vacio tras strip
    real = c
    if has_final_pipe and real and real[-1].strip() == '':
        real = real[:-1]
    realn = len(real)
    if realn > 11:
        fixable.append((i, 'EXTRA', realn, b))
    elif not has_final_pipe:
        fixable.append((i, 'NOPIPE', realn, b))
    elif realn == 11:
        pass  # correcta
    else:  # realn == 10 (o <11)
        missing.append((i, realn, real, b))

print(f'filas de datos: {len(data_rows)}')
print(f'FIXABLE (extra/nopipe): {len(fixable)}')
print(f'MISSING (10 celdas, revisar): {len(missing)}')

print('\n===== FILAS FALTAN CELDA (dump para decision manual) =====')
HDR=['ID','Modulo','Estado','Progreso','Prioridad','Complejidad','Dependencias','Recom','Agente actual','Ultima actividad','Notas']
for i, rn, real, b in missing:
    print(f'\n--- L{i+1} ({rn} celdas) ---')
    for k in range(rn):
        lab = HDR[k] if k < len(HDR) else f'EXTRA{k}'
        print(f'  [{k:2d}] {lab:16s} = {real[k].strip()[:50]!r}')

# aplicacion de los fixes seguros (solo en memoria; print preview)
print('\n===== PREVIEW de fixes EXTRA/NOPIPE (primeras 8) =====')
for i, kind, rn, b in fixable[:8]:
    real = cells(b)
    if has_final := b.rstrip().endswith('|'):
        if real and real[-1].strip() == '':
            real = real[:-1]
    fixed10 = [x.strip() for x in real[0:10]]
    notas_frags = real[10:]
    notas = '|'.join(notas_frags).replace('\r', ' ')
    notas = notas.replace('|', '\\|').strip()
    new = '| ' + ' | '.join(fixed10) + ' | ' + notas + ' |'
    print(f'  {kind} L{i+1}: {rn}c -> 11c   {new[:90]}...')
