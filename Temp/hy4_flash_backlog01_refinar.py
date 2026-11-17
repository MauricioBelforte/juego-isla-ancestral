"""Refinamiento de hallazgos del backlog 01 (HY4 Flash). Solo lectura."""
from pathlib import Path
import re
from collections import Counter

R = Path('.')

print('=== T1 refine: distancia de "Totales" al final ===')
cks = sorted((R / 'DOCUMENTACION').glob('*/plan-actual/05-Checklist.md'))
dist = Counter()
for p in cks:
    ls = p.read_text(encoding='utf-8').splitlines()
    nlast = max((i for i, l in enumerate(ls) if l.strip()), default=-1)
    hits = [i for i, l in enumerate(ls) if re.search(r'(?i)\btotales\b', l)]
    if hits:
        d = nlast - hits[-1]
        bucket = '0 (es la ultima)' if d == 0 else '1-3' if d <= 3 else '4-10' if d <= 10 else '>10'
        dist[bucket] += 1
print(dict(dist))

print()
print('=== T9 refine: que tienen los bugs sin Modelo ===')
bl = (R / 'DOCUMENTACION' / '11-BUGS.md').read_text(encoding='utf-8').splitlines()
encs = [(i, l) for i, l in enumerate(bl) if re.match(r'^### BUG-\d+\b', l)]
sin = []
for k, (i, l) in enumerate(encs):
    j = encs[k + 1][0] if k + 1 < len(encs) else len(bl)
    bloque = '\n'.join(bl[i:j])
    if '**Modelo:**' not in bloque:
        idb = re.match(r'### (BUG-\d+)', l).group(1)
        senales = [s for s in ('**Firma:**', '**Reportado por:**', 'Reportado por:',
                               '**Plataforma:**', '**Fecha:**', '**Estado:**') if s in bloque]
        sin.append((idb, i + 1, j - i, senales))
for x in sin[:12]:
    print(' ', x[0], 'L%d' % x[1], '(%d lineas)' % x[2], 'senales:', x[3])
print('total sin Modelo:', len(sin))

print()
print('=== T10 refine: pares de filas GLOBAL con misma ID ===')
gl = (R / 'CHECKLIST-GLOBAL.md').read_text(encoding='utf-8').splitlines()
por_id = {}
for i, l in enumerate(gl, 1):
    m = re.match(r'^\|\s*(\d{1,3})\s*\|\s*([^|]+?)\s*\|', l)
    if m:
        por_id.setdefault(m.group(1), []).append((i, m.group(2).strip(), l))
for k, filas in por_id.items():
    if len(filas) > 1:
        print(' ID', k, '->', len(filas), 'filas')
        for lineno, nombre, l in filas:
            celdas = [c.strip() for c in l.split('|')]
            print('   L%d %s | estado=%s | prog=%s | dueno=%s | fecha=%s' %
                  (lineno, nombre, celdas[3] if len(celdas) > 3 else '?',
                   celdas[4] if len(celdas) > 4 else '?',
                   celdas[9] if len(celdas) > 9 else '?',
                   celdas[10] if len(celdas) > 10 else '?'))

print()
print('=== T11 refine: estado de reclamos 🔵 ===')
ep = (R / 'Mensajes entre modelos' / 'ESTADO-PARALELO.md').read_text(encoding='utf-8').splitlines()
heads = [(i + 1, l) for i, l in enumerate(ep) if l.startswith('## ')]
print('total encabezados:', len(heads))
print('primeros 3:', [(n, l[:90]) for n, l in heads[:3]])
print('ultimos 3:', [(n, l[:90]) for n, l in heads[-3:]])
print('🔵 con fecha 2026-10 o anterior:',
      sum(1 for _, h in heads if '🔵' in h and re.search(r'2026-10-', h)))
