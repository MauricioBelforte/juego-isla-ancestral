# -*- coding: utf-8 -*-
"""repoblar_backlog.py — repuebla el BACKLOG-MASTER de un agente con items REALES
de los 05-Checklist de sus modulos (nunca inventadas). Fundador 2026-10-19: 100 disponibles por agente.

Uso: python repoblar_backlog.py <carpeta-modelo> M87,M91,M114 [--cota 100]
"""
import io, os, re, sys
from glob import glob

carpeta = sys.argv[1].strip()
mods = [m.strip() for m in sys.argv[2].split(',')]
cota = int(sys.argv[sys.argv.index('--cota') + 1]) if '--cota' in sys.argv else 100

BLP = os.path.join('DOCUMENTACION', 'TAREAS-POR-MODELO', carpeta, 'BACKLOG-MASTER.md')
bl = io.open(BLP, encoding='utf-8-sig', errors='replace').read()

def norm(s):
    return re.sub(r'\W+', '', s.lower())[:80]

tenidos = set(norm(l) for l in bl.splitlines() if len(l.strip()) > 10)
pend_act = len(re.findall(r'(?m)^\s*-?\s*\[ \]', bl))

lineas = []
no_encontrados = []
for mod in mods:
    g = (glob(os.path.join('DOCUMENTACION', mod + '-*', 'plan-actual', '05-Checklist.md')) or
         glob(os.path.join('DOCUMENTACION', mod + ' *', 'plan-actual', '05-Checklist.md')) or
         glob(os.path.join('DOCUMENTACION', mod + '-*', '05-Checklist.md')))
    if not g:
        no_encontrados.append(mod)
        continue
    p = g[0]
    tt = io.open(p, encoding='utf-8', errors='replace').read()
    for it in re.finditer(r'(?m)^\s*-?\s*\[ \]\s*(.+)$', tt):
        txt = re.sub(r'\s+', ' ', it.group(1)).strip()[:150]
        clave = norm(txt)
        if clave in tenidos:
            continue
        tenidos.add(clave)
        fuente = os.path.basename(os.path.dirname(os.path.dirname(p)))
        lineas.append('- [ ] [%s] %s <!-- fuente: %s/05-Checklist.md -->' % (mod, txt, fuente))

if not lineas:
    print('%s: sin items nuevos en %s (todo ya citado) | no encontrados: %s' % (carpeta, mods, no_encontrados))
    sys.exit(0)

sec = []
ancla_ult = None
for m in re.finditer(r'(?m)^## REPOBLACION V3[^
]*$', bl):
    ancla_ult = m
if ancla_ult:
    # anexar a la ultima seccion existente
    lineas_n = ['%d. %s' % (i, l) for i, l in enumerate(lineas, 1)]
    t = bl[:ancla_ult.end()] + chr(10) + chr(10).join(lineas_n) + bl[ancla_ult.end():]
    io.open(BLP, 'w', encoding='utf-8', newline='
').write(t)
    print('%s: +%d items anexados a la seccion REPOBLACION V3 existente' % (carpeta, len(lineas)))
    sys.exit(0)
sec = ['', '', '## REPOBLACION V3 (%s) — items REALES de 05-Checklist (fuente en comentario)' % __import__('datetime').datetime.now().isoformat(timespec='seconds'), '']
for i, l in enumerate(lineas, 1):
    sec.append('%d. %s' % (i, l))
sec.append('')

io.open(BLP, 'w', encoding='utf-8', newline='\n').write(bl.rstrip() + '\n' + '\n'.join(sec))
raw = io.open(BLP, 'rb').read()
print('%s: agregados %d items reales (tenia %d marcados) | no encontrados: %s | sin BOM: %s' % (
    carpeta, len(lineas), pend_act, no_encontrados, not raw.startswith(b'\xef\xbb\xbf')))
