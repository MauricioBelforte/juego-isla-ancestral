"""Verificacion de Progreso GLOBAL del backlog 04 (HY4 Flash). Solo lectura."""
from pathlib import Path
import re

R = Path('.')
DOC = R / 'DOCUMENTACION'
BL = (R / 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/04-Backlog-Verificacion-Progreso-GLOBAL.md').read_text(encoding='utf-8')
GL = (R / 'CHECKLIST-GLOBAL.md').read_text(encoding='utf-8').splitlines()

tareas = []
for l in BL.splitlines():
    m = re.match(r'^- \[ \] T4-(\d\d): Verificar M(\d{2,3})-([\w\-]+) \(real (.+?)\) - drift report$', l.strip())
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
print('%-6s %-32s %-18s %-8s %-8s %-8s %-8s %-14s %s' %
      ('Tarea', 'Modulo', 'Claim director', 'x^', 'x-ind', 'x-any', 'totales', 'GLOBAL', 'linea'))
resultados = []
for nro, mid, nombre, claim in tareas:
    carpetas = list(DOC.glob(mid + '-*/plan-actual/05-Checklist.md'))
    if not carpetas:
        print('FALTA ARCHIVO', mid, nombre)
        continue
    p = carpetas[0]
    txt = p.read_text(encoding='utf-8')
    ls = txt.splitlines()
    x_start = sum(1 for l in ls if re.match(r'^- \[x\]', l))
    x_ind = sum(1 for l in ls if re.match(r'^\s*- \[x\]', l))
    x_any = len(re.findall(r'\[x\]', txt))
    b_start = sum(1 for l in ls if re.match(r'^- \[ \]', l))
    q_start = sum(1 for l in ls if re.match(r'^- \[\?\]', l))
    tot = None
    for l in reversed(ls):
        if re.match(r'^\s*\*{0,2}Totales\*{0,2}\s*:', l, re.I):
            m = re.search(r'(\d{1,4})\s*(?:ítems|items|lineas-item)', l, re.I)
            if m:
                tot = (int(m.group(1)),
                       re.search(r'Completados?\s*:?\s*(?:\[[^\]]*\]\s*)?(\d+)', l, re.I),
                       l.strip()[:90])
                break
    ln, gname, gprog, gstate = global_row(mid)
    resultados.append((nro, mid, nombre, claim, x_start, x_ind, x_any, b_start, q_start,
                       tot, ln, gprog, gstate, p))
    print('T4-%s M%-3s %-30s %-18s %-8d %-8d %-8d %-8s %-14s L%s' %
          (nro, mid, nombre[:30], claim[:18], x_start, x_ind, x_any,
           (str(tot[0]) if tot else '-'), (str(gprog) if gprog else '-'), ln))

print()
print('=== Detalle por tarea ===')
for (nro, mid, nombre, claim, x_start, x_ind, x_any, b, q, tot, ln, gprog, gstate, p) in resultados:
    print('T4-%s M%s %s' % (nro, mid, nombre))
    print('  archivo:', p.as_posix())
    print('  claim director:', claim)
    print('  conteo exacto ^- [x]:', x_start, '| con indentacion:', x_ind, '| [x] en todo el archivo:', x_any)
    print('  ^- [ ]:', b, '| ^- [?]:', q, '| Totales:', tot[2] if tot else 'SIN LINEA')
    print('  GLOBAL L%s: estado=%s progreso=%s modulo=%s' % (ln, gstate, gprog, gname if False else ''))
