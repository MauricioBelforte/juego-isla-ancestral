"""Bug triage + verificacion de documentacion del backlog 02 (HY4 Flash). Solo lectura."""
from pathlib import Path
import re
from datetime import date, datetime
from collections import Counter, defaultdict

R = Path('.')
DOC = R / 'DOCUMENTACION'
HOY = date(2026, 11, 17)
CORTE = date(2026, 10, 18)  # 30 dias antes
BUGS = DOC / '11-BUGS.md'
bl = BUGS.read_text(encoding='utf-8').splitlines()

# --- tabla resumen (seccion 5) ---
ini5 = next(i for i, l in enumerate(bl) if l.startswith('## 5.'))
fin5 = next(i for i, l in enumerate(bl) if l.startswith('## 6.'))
filas = []
for i in range(ini5, fin5):
    l = bl[i].strip()
    if not l.startswith('|') or re.match(r'^\|[\s\-:|]+\|$', l):
        continue
    c = [x.strip() for x in l.strip('|').split('|')]
    if len(c) >= 7 and re.match(r'^BUG-\d+$', c[0]):
        filas.append((i + 1, c[:7]))
print('=== T1: bugs [?] por severidad ===')
print('filas de tabla resumen:', len(filas))
por_estado = Counter()
por_sev = defaultdict(Counter)
interrogantes = []
for ln, c in filas:
    idb, titulo, mod, sev, estado, reporter, fecha = c
    mark = '?' if '[?]' in estado else '->' if ('[→]' in estado or '[->]' in estado) else 'x' if '[x]' in estado else '?' if 'Delegado' in estado else 'otro'
    por_estado[mark] += 1
    if mark == '?':
        sev_key = ('🔴' if '🔴' in sev else '🟠' if '🟠' in sev else
                   '🟡' if '🟡' in sev else '⚪' if '⚪' in sev else 'sin-color')
        por_sev[sev_key][idb] += 1
        interrogantes.append((idb, sev_key, fecha, reporter, ln))
print('estados (tabla):', dict(por_estado))
for k in ('🔴', '🟠', '🟡', '⚪', 'sin-color'):
    if k in por_sev:
        ids = sorted(por_sev[k])
        print(' ', k, len(ids), '->', ids[:12], '...' if len(ids) > 12 else '')
print('total [?]:', len(interrogantes))

print()
print('=== T2: candidatos a resueltos sin marcar [x] ===')
# indice de bloques de detalle por ID
bloques = defaultdict(list)
pat = re.compile(r'^#{2,4}\s+(?:RESOLUCION\s+)?(BUG-\d+|B-\d+)\b')
for i, l in enumerate(bl):
    m = pat.match(l)
    if m:
        bloques[m.group(1)].append(i)
candidatos = []
for ln, c in filas:
    idb, titulo, mod, sev, estado, reporter, fecha = c
    if '[x]' in estado:
        continue
    idxs = bloques.get(idb, [])
    senales = []
    for ix in idxs:
        j = min([x for v in bloques.values() for x in v if x > ix] + [len(bl)])
        trozo = '\n'.join(bl[ix:j])
        for s in ('RESUELTO', 'RESOLUCION', 'CIERRE', 'cerrado', 'CERRADO'):
            if s in trozo:
                senales.append((s, ix + 1))
    if senales:
        candidatos.append((idb, estado[:28], fecha, sorted(set(senales))[:4]))
print('candidatos:', len(candidatos))
for x in candidatos[:20]:
    print(' ', x)

print()
print('=== T3: seccion 8 delegados, firmas ===')
ini8 = next(i for i, l in enumerate(bl) if l.startswith('## 8.'))
fin8 = next((i for i, l in enumerate(bl[ini8 + 1:], ini8 + 1)
             if l.startswith('## ') and (l.startswith('## Bugs abiertos')
                                          or l.startswith('## Hallazgos colaterales')
                                          or re.match(r'^## (?!8\.)\d+\.', l))), len(bl))
ent = [(i + 1, l) for i, l in enumerate(bl[ini8:fin8], ini8)
       if re.match(r'^#{2,3}\s+(BUG-\d+|B-\d+)\b', l)]
print('seccion 8: L%d-L%d | entradas BUG/B-: %d' % (ini8 + 1, fin8, len(ent)))
sin_firma = []
con_firma = 0
for k, (ln, l) in enumerate(ent):
    j = ent[k + 1][0] if k + 1 < len(ent) else fin8
    txt = '\n'.join(bl[ln - 1:j - 1])
    idb = re.match(r'^#{2,3}\s+(BUG-\d+|B-\d+)', l).group(1)
    tiene = any(s in txt for s in ('**Firma', '**Modelo', '**Reportado por'))
    if tiene:
        con_firma += 1
    else:
        sin_firma.append((idb, ln))
print('con firma:', con_firma, '| sin firma:', len(sin_firma), sin_firma[:20])
print('primeras 8 entradas:', [(a, b[:70]) for a, b in ent[:8]])

print()
print('=== T4: bugs en progreso con agente ===')
en_progreso = []
for ln, c in filas:
    idb, titulo, mod, sev, estado, reporter, fecha = c
    if '[→]' in estado or '[->]' in estado:
        en_progreso.append((idb, estado, reporter, ln))
print('filas [→]/[->]:', len(en_progreso))
for x in en_progreso[:12]:
    print(' ', x)
print('sin agente (reporter vacio/—):', [x for x in en_progreso if not x[2] or x[2] in ('—', '-')])
print('nota: archivo usa [→] (unicode) %d veces, [->] (ascii) %d veces' %
      (sum('[→]' in l for l in bl), sum('[->]' in l for l in bl)))

print()
print('=== T5: duplicados en 5-FUTURAS-MEJORAS.md ===')
fut = (DOC / '5-FUTURAS-MEJORAS.md').read_text(encoding='utf-8').splitlines()
items = [(i + 1, l.strip()) for i, l in enumerate(fut) if l.strip().startswith('- [')]
norm = lambda s: re.sub(r'\s+', ' ', re.sub(r'^- \[[^\]]\]\s*', '', s)).lower()
cnt = Counter(norm(t) for _, t in items)
dups = [(k, v) for k, v in cnt.items() if v > 1]
print('items:', len(items), '| duplicados exactos normalizados:', len(dups))
for k, v in dups[:10]:
    print('  x%d %s' % (v, k[:130]))
# similitud por primeras 60 chars
c60 = Counter(norm(t)[:60] for _, t in items)
print('duplicados por primeros 60 chars:', [(k, v) for k, v in c60.items() if v > 1][:10])

print()
print('=== T12: bugs con mas de 30 dias sin movimiento ===')
viejos = []
for ln, c in filas:
    idb, titulo, mod, sev, estado, reporter, fecha = c
    if '[x]' in estado:
        continue
    m = re.match(r'(\d{4}-\d{2}-\d{2})', fecha)
    if not m:
        continue
    f = date.fromisoformat(m.group(1))
    if (HOY - f).days > 30:
        viejos.append((idb, (HOY - f).days, fecha, sev, estado[:26], ln))
viejos.sort(key=lambda x: -x[1])
print('abiertos/delegados con fecha > 30 dias (corte %s): %d' % (CORTE, len(viejos)))
for x in viejos[:15]:
    print(' ', x)
