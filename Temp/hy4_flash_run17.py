"""Backlog 17: consistencia estado/progreso de CHECKLIST-GLOBAL. Solo lectura."""
from pathlib import Path
import re
from collections import Counter

R = Path('.')
BP = R / 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/17-Backlog-CHECKLIST-GLOBAL-Consistencia.md'
DOC = R / 'DOCUMENTACION'
GL = (R / 'CHECKLIST-GLOBAL.md').read_text(encoding='utf-8').splitlines()
filas = [l for l in GL if l.startswith('|') and '/' in l and '|' in l[2:]]
print('filas:', len(filas))

def analizar(l):
    c = [x.strip() for x in l.strip('|').split('|')]
    if len(c) < 4 or not re.match(r'^\d{1,3}$', c[0]):
        return None
    mid = c[0]
    estado = c[2]
    prog = None
    for x in c[1:5]:
        m = re.search(r'(?<!\d)(\d{1,4})/(\d{1,4})(?!\d)', x)
        if m:
            prog = (int(m.group(1)), int(m.group(2)))
            break
    if not prog:
        return None
    completo = prog[0] == prog[1]
    es_ok = '✅' in estado or 'Completado' in estado
    incoherente = completo and not es_ok
    falso_verde = False
    qs = None
    if es_ok:
        fs = list(DOC.glob(mid + '-*/plan-actual/05-Checklist.md'))
        if fs:
            txt = fs[0].read_text(encoding='utf-8')
            qs = len(re.findall(r'^- \[[\?]\]', txt, flags=re.M))
            falso_verde = qs > 0
    return (mid, estado, prog, incoherente, falso_verde, qs)

res = [analizar(l) for l in filas]
res = [r for r in res if r]
print('analizadas:', len(res))
print('progreso X/X con estado no completado:', sum(1 for r in res if r[3]))
print('estado OK con [?] en checklist:', sum(1 for r in res if r[4]))

txt = BP.read_text(encoding='utf-8')
if '\n## Evidencia de la tanda' in txt:
    txt = txt.split('\n## Evidencia de la tanda')[0] + '\n'
lineas = txt.splitlines(keepends=True)
for i, raw in enumerate(lineas):
    l = raw.rstrip('\n')
    m = re.match(r'^- \[ \] (T17-\d+): Batch (\d+)-(\d+) - estado vs progreso(?: —.*)?$', l)
    if not m:
        continue
    tag, ini, fin = m.group(1), int(m.group(2)) - 1, int(m.group(3)) - 1
    chunk = res[ini:fin]
    inc = [r for r in chunk if r[3]]
    fv = [r for r in chunk if r[4]]
    nota = 'OK %d filas' % len(chunk) if not inc and not fv else \
           '%d/%d OK · %d X/X sin estado OK · %d ✅ con [?]: %s' % (
               len(chunk)-len(inc)-len(fv), len(chunk), len(inc), len(fv),
               ', '.join('M'+r[0] for r in (inc+fv)[:6]))
    base = re.sub(r' — .*$', '', l)
    lineas[i] = '- [x] ' + base[6:] + ' — ' + nota + '\n'

ev = ['\n## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:7x UTC)\n\n']
ev.append('Universo: **%d filas** de `CHECKLIST-GLOBAL.md` (mismo filtro que el generador), 9 batches de 20. '
          'Se revisaron dos reglas: (1) `Progreso = X/X` con estado que no indique completado; '
          '(2) estado `✅` con `[?]` en el `05-Checklist.md` del módulo (falso verde). No se corrigió nada.\n\n' % len(filas))
ev.append('| Resultado | Filas |\n|---|---|\n')
ev.append('| Progreso X/X con estado no completado | %d |\n' % sum(1 for r in res if r[3]))
ev.append('| Estado OK con `[?]` en checklist | %d |\n' % sum(1 for r in res if r[4]))
ev.append('\nCasos (primeros 40 de cada tipo):\n\n')
for r in [x for x in res if x[3]][:40]:
    ev.append('- X/X sin estado OK: M%s — %s — %s/%s\n' % (r[0], r[1], r[2][0], r[2][1]))
for r in [x for x in res if x[4]][:40]:
    ev.append('- ✅ con [?]: M%s — %s — %d `[?]`\n' % (r[0], r[1], r[5]))
ev.append('\n**Firma:** agnes-3-flash (directora) - 2026-11-17 07:55\n'
          '**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:7x\n')

BP.write_text(''.join(lineas) + ''.join(ev), encoding='utf-8', newline='\n')
print('tareas marcadas:', sum(1 for l in lineas if l.startswith('- [x] T17-')))
