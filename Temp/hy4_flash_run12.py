"""Backlog 12: verificacion UTF-8 de 4258 archivos en 213 batches. Solo lectura."""
from pathlib import Path
import os
from collections import Counter

R = Path('.')
BP = R / 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/12-Backlog-UTF8-Encoding.md'

# Misma reconstruccion que Temp/create_backlogs_hy4.py (os.walk + os.path.join + sorted)
md_files = []
gd_files = []
for root, dirs, files in os.walk('DOCUMENTACION'):
    for f in files:
        if f.endswith('.md'):
            md_files.append(os.path.join(root, f))
for root, dirs, files in os.walk(os.path.join('game', 'isla-ancestral', 'scripts')):
    for f in files:
        if f.endswith('.gd'):
            gd_files.append(os.path.join(root, f))
all_files = sorted(md_files + gd_files)
print('archivos:', len(all_files), '| md:', len(md_files), '| gd:', len(gd_files))
print('primero:', all_files[0])
print('batch 2 primero:', all_files[20])

def check(path):
    try:
        b = Path(path).read_bytes()
    except Exception as e:
        return 'NO-LECTURA: %s' % str(e)[:60]
    if b[:3] == b'\xef\xbb\xbf':
        return 'BOM'
    try:
        t = b.decode('utf-8')
        if '\ufffd' in t:
            return 'U+FFFD'
        return 'OK'
    except UnicodeDecodeError:
        try:
            b.decode('cp1252')
            return 'MOJIBAKE-cp1252'
        except Exception:
            return 'BINARIO-no-utf8'

estados = [check(p) for p in all_files]
print('estados:', dict(Counter(estados)))

txt = BP.read_text(encoding='utf-8')
if '\n## Evidencia de la tanda' in txt:
    txt = txt.split('\n## Evidencia de la tanda')[0] + '\n'
lineas = txt.splitlines(keepends=True)
res = []
for i, raw in enumerate(lineas):
    l = raw.rstrip('\n')
    if not l.startswith('- [ ] T12-'):
        continue
    nro = l.split(':', 1)[0].replace('- [ ] T12-', '')
    ini = (int(nro) - 1) * 20
    fin = min(ini + 20, len(all_files))
    chunk = estados[ini:fin]
    malos = [(all_files[ini + k], e) for k, e in enumerate(chunk) if e != 'OK']
    base = l
    nota = 'OK 20/20' if not malos else '%d/%d OK · %s' % (20 - len(malos), len(chunk), ', '.join('%s:%s' % (Path(p).name, e) for p, e in malos[:4]))
    lineas[i] = '- [x] ' + base[6:] + ' — ' + nota + '\n'
    res.append((nro, ini + 1, fin, malos))

ev = ['\n## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:2x UTC)\n\n']
ev.append('Universo reconstruido con el mismo generador que creó el backlog (`Temp/create_backlogs_hy4.py`): '
          '%d `.md` bajo `DOCUMENTACION/` + %d `.gd` bajo `game/isla-ancestral/scripts/` = **%d archivos**, '
          '%d batches de 20. Verificación: BOM UTF-8, `decode("utf-8")` estricto y presencia de U+FFFD.\n\n' %
          (len(md_files), len(gd_files), len(all_files), len(res)))
ev.append('| Resultado global | Archivos |\n|---|---|\n')
for k, v in Counter(estados).most_common():
    ev.append('| %s | %d |\n' % (k, v))
ev.append('\nBatches con anomalías: %d de %d.\n\n' % (sum(1 for r in res if r[3]), len(res)))
ev.append('| Batch | Rango | Anomalías |\n|---|---|---|\n')
for nro, ini, fin, malos in res:
    if malos:
        ev.append('| T12-%s | %d-%d | %s |\n' % (nro, ini, fin, '; '.join('%s → %s' % (p, e) for p, e in malos[:8])))
ev.append('\nSolo anotado; no se corrigió ningún archivo.\n\n'
          '**Firma:** agnes-3-flash (directora) - 2026-11-17 07:55\n'
          '**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:2x\n')

BP.write_text(''.join(lineas) + ''.join(ev), encoding='utf-8', newline='\n')
print('tareas marcadas:', sum(1 for l in lineas if l.startswith('- [x] T12-')))
print('batches con anomalias:', sum(1 for r in res if r[3]))
