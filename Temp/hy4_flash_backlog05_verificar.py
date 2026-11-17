"""Verificacion masiva GLOBAL del backlog 05 (HY4 Flash). Solo lectura."""
from pathlib import Path
import re

R = Path('.')
DOC = R / 'DOCUMENTACION'
BL = (R / 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/05-Backlog-Verificacion-Masiva-GLOBAL.md').read_text(encoding='utf-8')
GL = (R / 'CHECKLIST-GLOBAL.md').read_text(encoding='utf-8').splitlines()

tareas = []
for l in BL.splitlines():
    m = re.match(r'^- \[ \] T5-(\d\d): M(\d{2,3}) ([\w\-]+) \(real (.+?)\) - drift GLOBAL$', l.strip())
    if m:
        tareas.append((m.group(1), m.group(2), m.group(3), m.group(4)))

def global_row(mid):
    for i, l in enumerate(GL, 1):
        if not l.startswith('|'):
            continue
        c = [x.strip() for x in l.strip('|').split('|')]
        if c and c[0] == mid:
            prog = None
            for x in c[1:5]:
                mp = re.search(r'(?<!\d)(\d{1,4})/(\d{1,4})(?!\d)', x)
                if mp:
                    prog = (int(mp.group(1)), int(mp.group(2)))
                    break
            return i, c[1] if len(c) > 1 else '', prog, c[2] if len(c) > 2 else ''
    return None, '', None, ''

print('tareas detectadas:', len(tareas))
print('%-6s %-4s %-28s %-24s %-8s %-8s %-8s %-14s %s' %
      ('Tarea', 'ID', 'Modulo', 'Claim director', 'x', '[]', '[?]', 'GLOBAL', 'linea'))
res = []
for nro, mid, nombre, claim in tareas:
    carpetas = list(DOC.glob(mid + '-*/plan-actual/05-Checklist.md'))
    if not carpetas:
        print('FALTA ARCHIVO', mid, nombre)
        res.append((nro, mid, nombre, claim, None, None, None, None, None, None))
        continue
    p = carpetas[0]
    ls = p.read_text(encoding='utf-8').splitlines()
    x = sum(1 for l in ls if l.startswith('- [x]'))
    b = sum(1 for l in ls if l.startswith('- [ ]'))
    q = sum(1 for l in ls if l.startswith('- [?]'))
    tot = None
    for l in reversed(ls):
        if re.match(r'^\s*\*{0,2}Totales\*{0,2}\s*:', l, re.I):
            m = re.search(r'(\d{1,4})\s*(?:ítems|items|lineas-item)', l, re.I)
            if m:
                tot = l.strip()[:110]
                break
    ln, gname, gprog, gstate = global_row(mid)
    res.append((nro, mid, nombre, claim, x, b, q, tot, gprog, (ln, gstate), p))
    print('T5-%s M%-3s %-28s %-24s %-8d %-8d %-8d %-14s L%s' %
          (nro, mid, nombre[:28], claim[:24], x, b, q, (str(gprog) if gprog else '-'), ln))

print()
print('=== Detalle y drift ===')
for r in res:
    nro, mid, nombre, claim, x, b, q, tot, gprog, extra, *resto = r
    print('T5-%s M%s %s' % (nro, mid, nombre))
    if x is None:
        print('  MODULO/checklist AUSENTE -> marca [?]')
        continue
    p = resto[0]
    print('  archivo:', p.as_posix())
    print('  claim:', claim)
    print('  real: %d [x] / %d [ ] / %d [?] = %d' % (x, b, q, x + b + q))
    print('  Totales:', tot if tot else 'SIN LINEA')
    print('  GLOBAL: L%s estado=%s progreso=%s' % (extra[0], extra[1], gprog))
    if gprog:
        d = x - gprog[0]
        print('  DRIFT [x]: %+d -> %s' % (d, 'REPORTAR (>5)' if abs(d) > 5 else 'anotar (<=5)'))
