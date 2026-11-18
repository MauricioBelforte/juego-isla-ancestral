"""Backlog 15: integridad de firmas y secuencia de 2345 logs. Solo lectura."""
from pathlib import Path
import os, re
from collections import Counter

R = Path('.')
BP = R / 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/15-Backlog-Log-Integrity.md'

logs = []
for root, _dirs, fs in os.walk('Logs'):
    if 'rotated' not in root:
        logs += [os.path.join(root, f) for f in fs if f.endswith('.md')]
logs = sorted(logs)
print('logs:', len(logs))

def check(p):
    try:
        t = Path(p).read_text(encoding='utf-8', errors='replace')
    except Exception as e:
        return (False, False, False, 'NO-LECTURA')
    m = bool(re.search(r'\*\*Modelo:', t))
    pl = bool(re.search(r'\*\*Plataforma:', t))
    f = bool(re.search(r'\*\*Fecha:', t))
    return (m, pl, f, 'OK' if (m and pl and f) else 'FALTA ' + '/'.join(
        n for n, ok in (('M', m), ('P', pl), ('F', f)) if not ok))

estados = [check(p) for p in logs]
numeros = [(int(m.group(1)), i) for i, p in enumerate(logs)
           for m in [re.match(r'^(\d{4})-', os.path.basename(p))] if m]
huecos = []
for k in range(1, len(numeros)):
    d = numeros[k][0] - numeros[k-1][0]
    if d > 3:
        huecos.append((numeros[k-1][0], numeros[k][0], d))
print('firmas OK:', sum(1 for e in estados if e[3] == 'OK'))
print('logs con numerico 4 digits:', len(numeros), '| huecos >3:', len(huecos))

txt = BP.read_text(encoding='utf-8')
if '\n## Evidencia de la tanda' in txt:
    txt = txt.split('\n## Evidencia de la tanda')[0] + '\n'
lineas = txt.splitlines(keepends=True)
res = []
for i, raw in enumerate(lineas):
    l = raw.rstrip('\n')
    mat = re.match(r'^- \[ \] (T15-\d+): Batch (\d+)-(\d+) - verificar firmas \+ secuencia(?: —.*)?$', l)
    if not mat:
        continue
    tag, ini, fin = mat.group(1), int(mat.group(2)) - 1, int(mat.group(3)) - 1
    chunk = estados[ini:fin + 1]
    malos = [(logs[ini + k], e[3]) for k, e in enumerate(chunk) if e[3] != 'OK']
    nota = 'OK %d/%d firmas' % (len(chunk), len(chunk)) if not malos else \
           '%d/%d OK · %d con firma incompleta: %s' % (len(chunk)-len(malos), len(chunk), len(malos),
                                                       ', '.join('%s:%s' % (os.path.basename(p), e) for p, e in malos[:3]))
    base = re.sub(r' — .*$', '', l)
    lineas[i] = '- [x] ' + base[6:] + ' — ' + nota + '\n'
    res.append((tag, ini, fin, malos))

ev = ['\n## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:5x UTC)\n\n']
ev.append('Universo: **%d logs** `.md` bajo `Logs/` (excluidos `rotated`), 118 batches de 20. '
          'Por log se verificaron `**Modelo:**`, `**Plataforma:**` y `**Fecha:**`; la secuencia se revisó sobre los prefijos numéricos de 4 dígitos. '
          '**Solo verificación: ningún log fue editado.**\n\n' % len(logs))
ev.append('| Resultado | Logs |\n|---|---|\n')
ev.append('| Firmas completas | %d |\n' % sum(1 for e in estados if e[3] == 'OK'))
ev.append('| Firma incompleta | %d |\n' % sum(1 for e in estados if e[3] != 'OK'))
for k, nom in (('M', 'falta Modelo'), ('P', 'falta Plataforma'), ('F', 'falta Fecha')):
    ev.append('| %s | %d |\n' % (nom, sum(1 for e in estados if not e[0 if k=='M' else 1 if k=='P' else 2])))
ev.append('| Logs con prefijo numérico de 4 dígitos | %d |\n' % len(numeros))
ev.append('| Huecos >3 en la secuencia | %d |\n' % len(huecos))
ev.append('\nBatches con firma incompleta: %d de %d.\n\n' % (sum(1 for r in res if r[3]), len(res)))
ev.append('Primeros logs con firma incompleta:\n\n')
for p, e in [(p, e) for p, e in zip(logs, estados) if e[3] != 'OK'][:40]:
    ev.append('- %s → %s\n' % (p.replace('\\', '/'), e[3]))
ev.append('\nHuecos >3 detectados (primeros 20): ')
ev.append('; '.join('%d→%d (%d)' % h for h in huecos[:20]) + '.\n\n')
ev.append('**Firma:** agnes-3-flash (directora) - 2026-11-17 07:55\n'
          '**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:5x\n')

BP.write_text(''.join(lineas) + ''.join(ev), encoding='utf-8', newline='\n')
print('tareas marcadas:', sum(1 for l in lineas if l.startswith('- [x] T15-')))
print('batches con firma incompleta:', sum(1 for r in res if r[3]))
