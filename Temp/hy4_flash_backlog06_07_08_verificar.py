"""Verificacion GLOBAL M01-M39 (backlogs 06/07/08) de HY4 Flash. Solo lectura."""
from pathlib import Path
import re

R = Path('.')
DOC = R / 'DOCUMENTACION'
BASE = R / 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS'
GL = (R / 'CHECKLIST-GLOBAL.md').read_text(encoding='utf-8').splitlines()

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
            return i, prog, (c[2] if len(c) > 2 else '')
    return None, None, ''

for archivo in ('06-Backlog-Verificacion-GLOBAL-M01-M12.md',
                '07-Backlog-Verificacion-GLOBAL-M13-M26.md',
                '08-Backlog-Verificacion-GLOBAL-M27-M39.md'):
    bl = (BASE / archivo).read_text(encoding='utf-8')
    tareas = []
    for l in bl.splitlines():
        m = re.match(r'^- \[ \] T(\d)-(\d\d): M(\d{2}) ([\w\-]+) \(real (.+?)\) - drift GLOBAL$', l.strip())
        if m:
            tareas.append((m.group(1), m.group(2), m.group(3), m.group(4), m.group(5)))
    print('=' * 100)
    print(archivo, '| tareas:', len(tareas))
    print('%-7s %-4s %-26s %-22s %-12s %-14s %-8s %s' %
          ('Tarea', 'ID', 'Modulo', 'Claim', 'Real x/[//?', 'GLOBAL', 'Drift', 'Accion'))
    material = []
    for tag, nro, mid, nombre, claim in tareas:
        fs = list(DOC.glob(mid + '-*/plan-actual/05-Checklist.md'))
        if not fs:
            print('T%s-%s M%s FALTA ARCHIVO -> [?]' % (tag, nro, mid))
            continue
        p = fs[0]
        ls = p.read_text(encoding='utf-8').splitlines()
        x = sum(1 for l in ls if l.startswith('- [x]'))
        b = sum(1 for l in ls if l.startswith('- [ ]'))
        q = sum(1 for l in ls if l.startswith('- [?]'))
        cx = re.search(r'(\d+)x', claim)
        cb = re.search(r'(\d+)o', claim)
        cq = re.search(r'(\d+)q', claim)
        claim_tuple = (int(cx.group(1)) if cx else 0,
                       int(cb.group(1)) if cb else 0,
                       int(cq.group(1)) if cq else 0)
        ln, gp, estado = global_row(mid)
        drift = (x - gp[0]) if gp else None
        accion = ('REPORTAR' if drift is not None and abs(drift) > 5 else 'anotar')
        if accion == 'REPORTAR':
            material.append((nro, mid, nombre, x, b, q, gp, drift, ln))
        coincide = 'OK' if claim_tuple == (x, b, q) else 'CLAIM-DIFF %s' % (claim_tuple,)
        print('T%s-%s M%-3s %-26s %-22s %-12s %-14s %-8s %s L%s %s' %
              (tag, nro, mid, nombre[:26], claim[:22], '%d/%d/%d' % (x, b, q),
               (str(gp) if gp else '-'), ('%+d' % drift if drift is not None else '-'),
               accion, ln, coincide))
    print('--- drifts >5 de este backlog:', len(material))
    for m in material:
        print('   T%s M%s %s: real %d/%d/%d vs GLOBAL %s (drift %+d) L%s' %
              (m[0], m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8]))
