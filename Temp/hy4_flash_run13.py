"""Backlog 13: integridad de 71 tests y 53 escenas. Solo lectura + marcas."""
from pathlib import Path
import re

R = Path('.')
BP = R / 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/13-Backlog-Test-Scene-Integrity.md'
MODS = {int(p.name.split('-')[0]) for p in (R / 'DOCUMENTACION').iterdir()
        if p.is_dir() and re.match(r'^\d{2,3}-', p.name)}

# Corpus de documentacion para buscar referencias a escenas
corpus = []
for p in (R / 'DOCUMENTACION').rglob('*.md'):
    try:
        corpus.append(p.read_text(encoding='utf-8'))
    except Exception:
        pass
corpus = '\n'.join(corpus)

txt = BP.read_text(encoding='utf-8')
if '\n## Evidencia de la tanda' in txt:
    txt = txt.split('\n## Evidencia de la tanda')[0] + '\n'
lineas = txt.splitlines(keepends=True)
res = []
for i, raw in enumerate(lineas):
    l = raw.rstrip('\n')
    m = re.match(r'^- \[ \] (T13-\d+(?:\+S)?): (test|scene) (.+?) - (referencia M___ \?|referenciada en docs \?)(?: —.*)?$', l)
    if not m:
        continue
    tag, tipo, ruta, _ = m.groups()
    p = Path(ruta.replace('\\', '/'))
    existe = p.is_file()
    if tipo == 'test':
        contenido = p.read_text(encoding='utf-8', errors='replace') if existe else ''
        ids = set(int(x) for x in re.findall(r'(?<!\d)M(\d{2,3})(?!\d)', ruta + '\n' + contenido))
        validos = sorted(ids & MODS)
        if not existe:
            nota = 'ARCHIVO AUSENTE'
        elif not ids:
            nota = 'existe · sin M referenciada en ruta/contenido'
        elif validos:
            nota = 'existe · M%s' % ','.join('M%03d' % v for v in validos[:6])
        else:
            nota = 'existe · M citada sin carpeta: %s' % ','.join('M%03d' % v for v in sorted(ids)[:6])
    else:
        hits = corpus.count(p.name) if existe else 0
        nota = ('existe · %d refs en docs' % hits) if existe else 'ARCHIVO AUSENTE'
    base = re.sub(r' — .*$', '', l)
    lineas[i] = '- [x] ' + base[6:] + ' — ' + nota + '\n'
    res.append((tag, tipo, ruta, existe, nota))

ev = ['\n## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:3x UTC)\n\n']
ev.append('Se verificó existencia en disco de cada ruta; en tests se buscó `M\\d+` en ruta y contenido y se validó contra las carpetas `DOCUMENTACION/NN-*`; '
          'en escenas se contaron apariciones del nombre de archivo en todo `DOCUMENTACION/**/*.md`. No se creó ni borró nada.\n\n')
ev.append('| Resultado | Tareas |\n|---|---|\n')
ev.append('| Tests revisados | %d |\n' % sum(1 for r in res if r[1] == 'test'))
ev.append('| Escenas revisadas | %d |\n' % sum(1 for r in res if r[1] == 'scene'))
ev.append('| Archivos ausentes | %d |\n' % sum(1 for r in res if not r[3]))
ev.append('| Tests sin M referenciada | %d |\n' % sum(1 for r in res if r[1] == 'test' and 'sin M referenciada' in r[4]))
ev.append('| Escenas sin referencia en docs | %d |\n' % sum(1 for r in res if r[1] == 'scene' and '0 refs' in r[4]))
ev.append('\nDetalle de hallazgos:\n\n')
for r in res:
    if (not r[3]) or 'sin M referenciada' in r[4] or 'sin carpeta' in r[4] or '0 refs' in r[4]:
        ev.append('- %s %s → %s\n' % (r[0], r[2], r[4]))
ev.append('\n**Firma:** agnes-3-flash (directora) - 2026-11-17 07:55\n'
          '**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:3x\n')

BP.write_text(''.join(lineas) + ''.join(ev), encoding='utf-8', newline='\n')
print('tareas marcadas:', sum(1 for l in lineas if l.startswith('- [x] T13-')))
print('tests:', sum(1 for r in res if r[1] == 'test'), 'escenas:', sum(1 for r in res if r[1] == 'scene'))
print('ausentes:', sum(1 for r in res if not r[3]))
print('tests sin M:', sum(1 for r in res if r[1] == 'test' and 'sin M referenciada' in r[4]))
print('escenas 0 refs:', sum(1 for r in res if r[1] == 'scene' and '0 refs' in r[4]))
