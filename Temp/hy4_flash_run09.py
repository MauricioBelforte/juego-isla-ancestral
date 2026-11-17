"""Backlog 09: verificacion de drift GLOBAL M41-M169 y marcado con evidencia."""
from pathlib import Path
import re

R = Path('.')
DOC = R / 'DOCUMENTACION'
BP = R / 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/09-Backlog-GLOBAL-M41.md'
GL = (R / 'CHECKLIST-GLOBAL.md').read_text(encoding='utf-8').splitlines()

def global_row(mid):
    for i, l in enumerate(GL, 1):
        if not l.startswith('|'):
            continue
        c = [x.strip() for x in l.strip('|').split('|')]
        if c and c[0] == mid:
            for x in c[1:5]:
                mp = re.search(r'(?<!\d)(\d{1,4})/(\d{1,4})(?!\d)', x)
                if mp:
                    return i, (int(mp.group(1)), int(mp.group(2))), (c[2] if len(c) > 2 else '')
    return None, None, ''

txt = BP.read_text(encoding='utf-8')
lineas = txt.splitlines(keepends=True)
salidas = []
drifts = []
match_claim = 0
for i, raw in enumerate(lineas):
    l = raw.rstrip('\n')
    m = re.match(r'^- \[ \] (T9-\d\d): M(\d{2,3}) (.+?) \((\d+)x\+(\d+)o\+(\d+)q=\d+\) - drift GLOBAL$', l)
    if not m:
        continue
    tag, mid, nombre, cx, cb, cq = m.group(1), m.group(2), m.group(3), int(m.group(4)), int(m.group(5)), int(m.group(6))
    fs = list(DOC.glob(mid + '-*/plan-actual/05-Checklist.md'))
    if not fs:
        salidas.append((tag, mid, nombre, None, None, None, None, None, None, 'MODULO/checklist AUSENTE'))
        continue
    ls = fs[0].read_text(encoding='utf-8').splitlines()
    x = sum(1 for z in ls if z.startswith('- [x]'))
    b = sum(1 for z in ls if z.startswith('- [ ]'))
    q = sum(1 for z in ls if z.startswith('- [?]'))
    ln, gp, estado = global_row(mid)
    drift = (x - gp[0]) if gp else None
    accion = 'REPORTADO' if drift is not None and abs(drift) > 5 else 'anotado'
    if (x, b, q) == (cx, cb, cq):
        match_claim += 1
    if abs(drift or 0) > 5:
        drifts.append((tag, mid, nombre, x, b, q, gp, drift, ln))
    extra = ' — real %d/%d/%d · GLOBAL %s (L%s) · drift %+d (%s)' % (
        x, b, q, ('%d/%d' % gp if gp else 'SIN FILA'), ln, drift or 0, accion)
    lineas[i] = '- [x] ' + l[6:] + extra + '\n'

evidencia = ['\n## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:0x UTC)\n\n']
evidencia.append('Conteo anclado a inicio de línea (`grep -cF` sobre `- [x]` / `- [ ]` / `- [?]`) y comparación con el Progreso de `CHECKLIST-GLOBAL.md`. '
                 'Claims reproducidos exactamente: %d/129.\n\n' % match_claim)
evidencia.append('| Tarea | Módulo | Real `[x]` | GLOBAL | Drift | Resultado |\n|---|---|---|---|---|---|\n')
for tag, mid, nombre, x, b, q, ln, gp, note in salidas:
    if x is None:
        evidencia.append('| %s | M%s %s | — | — | — | %s |\n' % (tag, mid, nombre, note))
        continue
    evidencia.append('| %s | M%s %s | %d | %s (L%s) | %+d | %s |\n' % (
        tag, mid, nombre, x, ('%d/%d' % gp if gp else '—'), ln, (x-gp[0]) if gp else 0,
        'REPORTADO' if abs(x-gp[0]) > 5 else 'anotado'))
evidencia.append('\n**Drifts >5: %d de 129.** ' % len(drifts))
evidencia.append('; '.join('M%s %s real %d/%d/%d vs GLOBAL %s (drift %+d, L%s)' %
                           (d[1], d[2], d[3], d[4], d[5], d[6], d[7], d[8]) for d in drifts) + '.\n\n')
evidencia.append('Todo reportado, nada corregido.\n\n**Firma:** agnes-3-flash (directora) - 2026-11-17 07:55\n'
                 '**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:0x\n')

BP.write_text(''.join(lineas) + ''.join(evidencia), encoding='utf-8', newline='\n')
print('tareas marcadas:', sum(1 for l in lineas if l.startswith('- [x] T9-')))
print('claims reproducidos:', match_claim, '/129')
print('drifts >5:', len(drifts))
for d in drifts:
    print('  ', d[0], 'M'+d[1], d[2][:28], 'real %d/%d/%d' % (d[3], d[4], d[5]), 'GLOBAL', d[6], 'drift', d[7], 'L'+str(d[8]))
