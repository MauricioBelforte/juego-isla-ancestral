"""Backlog 16: cross-referencias y firmas en DOCUMENTACION. Solo lectura."""
from pathlib import Path
import re
from collections import Counter

R = Path('.')
BP = R / 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/16-Backlog-CrossRef-Firmas.md'
docs = sorted((R / 'DOCUMENTACION').rglob('*.md'))
actual = sorted(p for p in docs if 'plan-actual' in p.parts)
todos_md = sorted(p for p in R.rglob('*.md') if '.git' not in p.parts)
nombres_md = {p.name for p in todos_md}
print('docs:', len(docs), '| plan-actual:', len(actual), '| .md totales:', len(todos_md))

def refs_rotas(p):
    try:
        t = p.read_text(encoding='utf-8', errors='replace')
    except Exception:
        return []
    malas = []
    # enlaces markdown y rutas entre backticks que terminen en .md
    for m in re.finditer(r'(?:\[[^\]]*\]\(([^)]+)\)|`([^`]+?\.md)`)', t):
        ref = (m.group(1) or m.group(2)).split('#', 1)[0].strip()
        if not ref or ref.startswith(('http://', 'https://', 'mailto:')):
            continue
        ref = ref.replace('\\', '/')
        # descartar globs, elipsis, comandos y listas: no son referencias a un archivo concreto
        if any(s in ref for s in ('*', '?', '...', ',', ' --', 'git ', '{', '}', 'NN-', 'YYYY-', '%s', '<', 'XX')):
            continue
        candidatos = [R / ref, p.parent / ref, (R / 'DOCUMENTACION') / ref]
        if any(c.exists() for c in candidatos):
            continue
        nombre = Path(ref).name
        if nombre in nombres_md:
            continue
        malas.append(ref[:100])
    return malas

ref_state = [refs_rotas(p) for p in docs]
firma_state = []
for p in actual:
    try:
        t = p.read_text(encoding='utf-8', errors='replace')
    except Exception:
        firma_state.append('NO-LECTURA'); continue
    ok = [bool(re.search(r'\*\*Modelo:', t)), bool(re.search(r'\*\*Plataforma:', t)), bool(re.search(r'\*\*Fecha:', t))]
    firma_state.append('OK' if all(ok) else 'FALTA ' + '/'.join(n for n, v in zip(('M','P','F'), ok) if not v))
print('docs con refs rotas:', sum(1 for r in ref_state if r))
print('plan-actual con firma incompleta:', sum(1 for f in firma_state if f != 'OK'))

txt = BP.read_text(encoding='utf-8')
if '\n## Evidencia de la tanda' in txt:
    txt = txt.split('\n## Evidencia de la tanda')[0] + '\n'
lineas = txt.splitlines(keepends=True)
res = []
for i, raw in enumerate(lineas):
    l = raw.rstrip('\n')
    mref = re.match(r'^- \[[ x]\] (T16-(\d+)): Verificar referencias en DOCUMENTACION/ batch (\d+)(?: —.*)?$', l)
    mfirma = re.match(r'^- \[[ x]\] (T16-(\d+)): Verificar firma en DOCUMENTACION/plan-actual/ batch (\d+)(?: —.*)?$', l)
    if mref:
        n = int(mref.group(2)); b = int(mref.group(3)) - 1
        ini, fin = b * 60, min((b + 1) * 60, len(docs))
        chunk = ref_state[ini:fin]
        malas = [(docs[ini+k], r) for k, r in enumerate(chunk) if r]
        nota = 'OK %d/%d docs' % (len(chunk), len(chunk)) if not malas else \
               '%d/%d OK · %d docs con refs rotas: %s' % (len(chunk)-len(malas), len(chunk), len(malas),
                    ', '.join('%s(%d)' % (p.relative_to(R), len(r)) for p, r in malas[:3]))
        tipo = 'refs'
    elif mfirma:
        n = int(mfirma.group(2)); b = int(mfirma.group(3)) - 1
        ini, fin = b * 21, min((b + 1) * 21, len(actual))
        chunk = firma_state[ini:fin]
        malas = [(actual[ini+k], f) for k, f in enumerate(chunk) if f != 'OK']
        nota = 'OK %d/%d docs' % (len(chunk), len(chunk)) if not malas else \
               '%d/%d OK · %d sin firma completa: %s' % (len(chunk)-len(malas), len(chunk), len(malas),
                    ', '.join('%s:%s' % (p.name, f) for p, f in malas[:3]))
        tipo = 'firmas'
    else:
        continue
    base = re.sub(r' — .*$', '', l)
    lineas[i] = '- [x] ' + base[6:] + ' — ' + nota + '\n'
    res.append((n, tipo, nota, malas))

ev = ['\n## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:6x UTC)\n\n']
ev.append('Universos reconstruidos de forma determinista: %d archivos `.md` bajo `DOCUMENTACION/` para las 50 tareas de cross-referencias (60 por batch) '
          'y %d archivos under `plan-actual/` para las 50 tareas de firmas (21 por batch, último incompleto). '
          'Referencia rota = enlace/ruta `.md` que no resuelve ni por ruta relativa, raíz, `DOCUMENTACION/` ni por nombre de archivo existente. '
          'Firma completa = `**Modelo:**` + `**Plataforma:**` + `**Fecha:**`. No se editó nada.\n\n' % (len(docs), len(actual)))
ev.append('| bloque | tareas | hallazgos |\n|---|---|---|\n')
ev.append('| Cross-referencias | 50 | %d documentos con al menos una referencia no resuelta |\n' % sum(1 for r in ref_state if r))
ev.append('| Firmas plan-actual | 50 | %d documentos con firma incompleta |\n' % sum(1 for f in firma_state if f != 'OK'))
ev.append('\nPrimeros documentos con referencias no resueltas:\n\n')
for p, r in [(p, r) for p, r in zip(docs, ref_state) if r][:25]:
    ev.append('- %s → %s\n' % (p.relative_to(R).as_posix(), ', '.join(r[:4])))
ev.append('\nPrimeros documentos `plan-actual/` con firma incompleta:\n\n')
for p, f in [(p, f) for p, f in zip(actual, firma_state) if f != 'OK'][:25]:
    ev.append('- %s → %s\n' % (p.relative_to(R).as_posix(), f))
ev.append('\n**Firma:** agnes-3-flash (directora) - 2026-11-17 07:55\n'
          '**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:6x\n')

BP.write_text(''.join(lineas) + ''.join(ev), encoding='utf-8', newline='\n')
print('tareas marcadas:', sum(1 for l in lineas if l.startswith('- [x] T16-')))
print('refs:', len(res))
