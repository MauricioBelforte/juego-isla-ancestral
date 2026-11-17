"""Backlog 11: triage de campos de 152 bugs en 11-BUGS.md. Solo lectura + marcas."""
from pathlib import Path
import re
from collections import Counter

R = Path('.')
BP = R / 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/11-Backlog-Triage-BUGS.md'
BUG = (R / 'DOCUMENTACION/11-BUGS.md').read_text(encoding='utf-8').splitlines()

# Indice de bloques por ID (incluye secciones RESOLUCION BUG-NNN)
headings = []
for i, l in enumerate(BUG):
    if re.match(r'^#{2,4}\s', l):
        m = re.search(r'BUG-(\d+)', l)
        if m:
            headings.append((i, m.group(1)))
segmentos = {}
for k, (pos, bid) in enumerate(headings):
    fin = headings[k + 1][0] if k + 1 < len(headings) else len(BUG)
    segmentos.setdefault(bid, []).append('\n'.join(BUG[pos:fin]))

# Tabla resumen
tabla = {}
for l in BUG:
    if not l.startswith('|'):
        continue
    c = [x.strip() for x in l.strip('|').split('|')]
    if len(c) >= 7 and re.match(r'^BUG-\d+$', c[0]):
        tabla[c[0]] = c[:7]

def norm_sev(s):
    if not s:
        return 'sin-color'
    m = re.match(r'^(🔴|🟠|🟡|🟢|⚪)\s*([A-Za-zÀ-ÿ]{0,14})', s)
    return (m.group(1) + ' ' + m.group(2)).strip() if m else 'sin-color/tabla-rota'

def analizar(bid):
    txt = '\n'.join(segmentos.get(bid.lstrip('BUG-'), []))
    fila = tabla.get(bid, [''] * 7)
    estado = bool(re.search(r'\*\*Estado:', txt)) or bool(fila[4])
    sev = bool(re.search(r'\*\*Severidad:', txt)) or bool(fila[3])
    repro = bool(re.search(r'\*\*(Pasos para reproducir|Reproducción|Repro)', txt, re.I))
    firma = bool(re.search(r'\*\*(Modelo|Firma|Reportado por):', txt)) or bool(fila[5] and fila[5] not in ('—', '-'))
    return estado, sev, repro, firma, norm_sev(fila[3])

txt = BP.read_text(encoding='utf-8')
if '\n## Evidencia de la tanda' in txt:
    txt = txt.split('\n## Evidencia de la tanda')[0] + '\n'
lineas = txt.splitlines(keepends=True)
res = []
for i, raw in enumerate(lineas):
    l = raw.rstrip('\n')
    m = re.match(r'^- \[[ x?]\] (T11-\d+): (BUG-\d+) - verificar campos completos \+ clasificar severidad(?: —.*)?$', l)
    if not m:
        continue
    tag, bid = m.group(1), m.group(2)
    e, s, r, f, sev = analizar(bid)
    faltan = [n for n, ok in (('E', e), ('S', s), ('R', r), ('F', f)) if not ok]
    marca = '[x]'  # la verificacion se completo; la ausencia de campos es el hallazgo, no un bloqueo
    estado_txt = 'OK E/S/R/F' if not faltan else 'FALTA ' + '/'.join(faltan)
    lineas[i] = '- %s %s: %s - verificar campos completos + clasificar severidad — %s · severidad=%s\n' % (
        marca, tag, bid, estado_txt, sev)
    res.append((tag, bid, e, s, r, f, sev, faltan))

ev = ['\n## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:1x UTC)\n\n']
ev.append('Fuente: `DOCUMENTACION/11-BUGS.md` (tabla resumen de la sección 5 + bloques de detalle, incluidas secciones `RESOLUCION BUG-NNN`). '
          'Campos verificados: **E** estado, **S** severidad, **R** pasos de reproducción, **F** firma/attribución. '
          'No se corrigió ningún bug.\n\n')
c = Counter(x for r in res for x in r[7])
ev.append('| Resultado | Bugs |\n|---|---|\n')
ev.append('| Completos (E/S/R/F) | %d |\n' % sum(1 for r in res if not r[7]))
ev.append('| Con algún campo faltante | %d |\n' % sum(1 for r in res if r[7]))
for k, nombre in (('E', 'estado'), ('S', 'severidad'), ('R', 'repro'), ('F', 'firma')):
    ev.append('| Falta %s (%s) | %d |\n' % (k, nombre, c[k]))
ev.append('\nSeveridad declarada en la tabla: ')
ev.append('; '.join('%s=%d' % (k, v) for k, v in Counter(r[6] for r in res).most_common()) + '.\n\n')
ev.append('Bugs con algún campo faltante (primeros 40): ')
ev.append(', '.join('%s[%s]' % (r[1], '/'.join(r[7])) for r in res if r[7]) + '.\n\n')
ev.append('**Firma:** agnes-3-flash (directora) - 2026-11-17 07:55\n'
          '**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:1x\n')

BP.write_text(''.join(lineas) + ''.join(ev), encoding='utf-8', newline='\n')
print('bugs procesados:', len(res))
print('completos:', sum(1 for r in res if not r[7]))
print('faltan campos:', dict(c))
print('severidades:', dict(Counter(r[6] for r in res)))
print('ejemplos incompletos:', [(r[1], r[7]) for r in res if r[7]][:20])
