"""Backlog 09: reconstruccion idempotente de las 129 tareas con evidencia."""
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
                    return i, (int(mp.group(1)), int(mp.group(2)))
    return None, None

txt = BP.read_text(encoding='utf-8')
if '\n## Evidencia de la tanda' in txt:
    txt = txt.split('\n## Evidencia de la tanda')[0] + '\n'
lineas = txt.splitlines(keepends=True)
res = []
match_claim = 0
drifts = []
for i, raw in enumerate(lineas):
    l = raw.rstrip('\n')
    m = re.match(r'^- \[[ x]\] (T9-\d+): M(\d{2,3}) (.+?) \((\d+)x\+(\d+)o\+(\d+)q=\d+\) - drift GLOBAL(?: —.*)?$', l)
    if not m:
        continue
    tag, mid, nombre = m.group(1), m.group(2), m.group(3)
    cx, cb, cq = int(m.group(4)), int(m.group(5)), int(m.group(6))
    fs = list(DOC.glob(mid + '-*/plan-actual/05-Checklist.md'))
    if not fs:
        res.append((tag, mid, nombre, None, None, None, None, None, None))
        lineas[i] = '- [?] ' + l[6:] + ' — MODULO/checklist AUSENTE\n'
        continue
    ls = fs[0].read_text(encoding='utf-8').splitlines()
    x = sum(1 for z in ls if z.startswith('- [x]'))
    b = sum(1 for z in ls if z.startswith('- [ ]'))
    q = sum(1 for z in ls if z.startswith('- [?]'))
    ln, gp = global_row(mid)
    drift = (x - gp[0]) if gp else None
    accion = 'REPORTADO' if drift is not None and abs(drift) > 5 else 'anotado'
    if (x, b, q) == (cx, cb, cq):
        match_claim += 1
    if abs(drift or 0) > 5:
        drifts.append((tag, mid, nombre, x, b, q, gp, drift, ln))
    base = re.sub(r' — .*$', '', l)
    lineas[i] = '- [x] ' + base[6:] + ' — real %d/%d/%d · GLOBAL %s (L%s) · drift %+d (%s)\n' % (
        x, b, q, ('%d/%d' % gp if gp else 'SIN FILA'), ln, drift or 0, accion)
    res.append((tag, mid, nombre, x, b, q, gp, drift, ln))

ev = ['\n## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:0x UTC)\n\n']
ev.append('Conteo anclado a inicio de línea (`grep -cF`) y comparación con el Progreso de `CHECKLIST-GLOBAL.md`. '
          'Claims reproducidos exactamente: %d/129.\n\n' % match_claim)
ev.append('| Tarea | Módulo | Real `[x]` | GLOBAL | Drift | Resultado |\n|---|---|---|---|---|---|\n')
for tag, mid, nombre, x, b, q, gp, drift, ln in res:
    ev.append('| %s | M%s %s | %s | %s | %s | %s |\n' % (
        tag, mid, nombre, (str(x) if x is not None else '—'),
        ('%d/%d (L%s)' % (gp[0], gp[1], ln) if gp else '—'),
        ('%+d' % drift if drift is not None else '—'),
        ('REPORTADO' if drift is not None and abs(drift) > 5 else 'anotado')))
ev.append('\n**Drifts >5: %d de 129.** ' % len(drifts))
ev.append('; '.join('%s M%s %s: real %d/%d/%d vs GLOBAL %s (drift %+d, L%s)' %
                    (d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7], d[8]) for d in drifts) + '.\n\n')
ev.append('Solo reportar; ninguna corrección.\n\n**Firma:** agnes-3-flash (directora) - 2026-11-17 07:55\n'
          '**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:0x\n')

BP.write_text(''.join(lineas) + ''.join(ev), encoding='utf-8', newline='\n')
print('tareas procesadas:', len(res))
print('marcadas [x]:', sum(1 for l in lineas if l.startswith('- [x] T9-')))
print('claims reproducidos:', match_claim, '/129')
print('drifts >5:', len(drifts))
for d in drifts:
    print('  ', d[0], 'M'+d[1], d[2][:30], 'real %d/%d/%d' % (d[3], d[4], d[5]), d[6], 'drift', d[7])
