"""Verificacion de checklists y deep search del backlog 03 (HY4 Flash). Solo lectura."""
from pathlib import Path
import re
from collections import Counter, defaultdict

R = Path('.')
DOC = R / 'DOCUMENTACION'
GL = (R / 'CHECKLIST-GLOBAL.md').read_text(encoding='utf-8').splitlines()

# --- filas GLOBAL ---
filas = []
for i, l in enumerate(GL, 1):
    if not l.startswith('|'):
        continue
    c = [x.strip() for x in l.strip('|').split('|')]
    if len(c) < 6 or not re.match(r'^\d{1,3}$', c[0]):
        continue
    estado = ''
    progreso = None
    for x in c[1:5]:
        m = re.search(r'(🟢|🟡|🔵|🔴|✅|⬜)', x)
        if m and not estado:
            estado = m.group(1)
        mp = re.search(r'(?<!\d)(\d{1,4})/(\d{1,4})(?!\d)', x)
        if mp and progreso is None:
            progreso = (int(mp.group(1)), int(mp.group(2)))
    dep = c[6] if len(c) > 6 else ''
    filas.append({'linea': i, 'id': c[0], 'nombre': c[1] if len(c) > 1 else '',
                  'estado': estado, 'progreso': progreso, 'dep': dep})
por_id = {}
for f in filas:
    por_id.setdefault(f['id'], []).append(f)
print('=== GLOBAL ===')
print('filas:', len(filas), '| IDs unicos:', len(por_id))
print('estados:', dict(Counter(f['estado'] or 'SIN-ESTADO' for f in filas)))
print('IDs duplicados:', {k: [f['linea'] for f in v] for k, v in por_id.items() if len(v) > 1})

# --- Totales de checklists ---
def tot_de(p):
    ls = p.read_text(encoding='utf-8').splitlines()
    candidatas = [l for l in ls if re.match(r'^\s*\*{0,2}Totales\*{0,2}\s*:', l, re.I)]
    for l in reversed(candidatas):  # la ultima línea Totales manda; las anteriores son historial
        m = re.search(r'(\d{1,4})\s*(?:ítems|items|lineas-item|líneas-item)', l, re.I)
        if m:
            total = int(m.group(1))
            done = re.search(r'Completados?\s*:\s*(?:\[[^\]]*\]\s*)?(\d+)', l, re.I)
            pend = re.search(r'Pendientes\s*:\s*(?:\[[^\]]*\]\s*)?(\d+)', l, re.I)
            nres = re.search(r'No resueltos\s*(?:\([^)]*\)\s*)?:\s*(?:\[[^\]]*\]\s*)?(\d+)', l, re.I)
            if done and pend and nres:
                return total, int(done.group(1)), int(pend.group(1)), int(nres.group(1)), 'formato-A', len(candidatas)
        m2 = re.search(r'\*{0,2}(\d{1,4})/(\d{1,4})\*{0,2}', l)
        if m2:
            return int(m2.group(2)), int(m2.group(1)), None, None, 'formato-B', len(candidatas)
    # fallback: conteo de marcas en todo el archivo
    t = '\n'.join(ls)
    x = len(re.findall(r'^\s*[-*+]\s+\[x\]', t, flags=re.M))
    b = len(re.findall(r'^\s*[-*+]\s+\[\s\]', t, flags=re.M))
    q = len(re.findall(r'^\s*[-*+]\s+\[\?\]', t, flags=re.M))
    return x + b + q, x, b, q, 'FALLBACK-conteo', len(candidatas)

checks = {}
for p in sorted(DOC.glob('*/plan-actual/05-Checklist.md')):
    mid = p.parent.parent.name.split('-')[0]
    checks[mid] = (p, tot_de(p))
print('checklists parsed:', len(checks))
print('formatos:', dict(Counter(v[1][4] for v in checks.values())))

print()
print('=== T1: modulos 🟢 con menos de 100 items ===')
verdes = [f for f in filas if f['estado'] == '🟢']
print('filas 🟢:', len(verdes))
bajos = []
for f in verdes:
    v = checks.get(f['id'])
    if v and v[1][0] < 100:
        bajos.append((f['id'], f['nombre'], v[1][0], v[1][4]))
print('🟢 con <100 items:', len(bajos))
for x in bajos[:15]:
    print('  ', x)

print()
print('=== T2: modulos 🟡 con [?] sin explicacion (proxy) ===')
amarillos = [f for f in filas if f['estado'] == '🟡']
print('filas 🟡:', len(amarillos))
proxy = []
claves = ('por', 'porque', 'due', 'extern', 'depende', 'pendiente', 'requiere', 'usuario',
          'vision', 'qa', 'fuera de', 'deuda', 'esperando', 'bloque', 'knownissue', 'no implementado',
          'audit', 'revisado', 're-verificado', 're-baseline', 'degradado', 'sello', 'verif',
          'motivo', 'razon', 'debido', 'sin ', 'no ', 'pasa a ', '→', '->')
for f in amarillos:
    v = checks.get(f['id'])
    if not v:
        continue
    p = v[0]
    ls = p.read_text(encoding='utf-8').splitlines()
    qs = [(i + 1, l.strip()) for i, l in enumerate(ls) if re.match(r'^\s*[-*+]\s+\[\?\]', l)]
    def explicado(t):
        b = t.lower()
        if any(k in b for k in claves):
            return True
        # los items suelen llevar "texto | explicacion" o "texto — explicacion"
        return bool(re.search(r'[|—–-]\s*\S.{12,}', t))
    sospechosos = [(n, t) for n, t in qs if not explicado(t)]
    if v[1][3] and (v[1][3] > 0) and sospechosos:
        proxy.append((f['id'], v[1][3], len(sospechosos), sospechosos[:2]))
proxy.sort(key=lambda x: -x[2])
print('🟡 con [?] y candidatos a explicacion debil:', len(proxy))
for x in proxy[:12]:
    print('  ', x[0], 'declarados:', x[1], 'debiles:', x[2], 'ejemplo:', str(x[3][0])[:150] if x[3] else '')

print()
print('=== T3: modulos ✅ con [?] o [ ] ===')
cerrados = [f for f in filas if f['estado'] == '✅']
print('filas ✅:', len(cerrados))
mal = []
for f in cerrados:
    v = checks.get(f['id'])
    if not v:
        continue
    total, done, pend, nres, fmt, _ = v[1]
    if (pend or 0) > 0 or (nres or 0) > 0:
        mal.append((f['id'], f['nombre'], total, done, pend, nres, fmt))
print('✅ con pendientes/no-resueltos declarados:', len(mal))
for x in mal[:15]:
    print('  ', x)

print()
print('=== T4: drift GLOBAL <-> Totales (top 12) ===')
drift = []
for f in filas:
    v = checks.get(f['id'])
    if not v or not f['progreso']:
        continue
    total, done, pend, nres, fmt, _ = v[1]
    gdone, gtotal = f['progreso']
    d_done = (done or 0) - gdone
    d_total = total - gtotal
    if abs(d_done) > 5 or abs(d_total) > 5:
        drift.append((max(abs(d_done), abs(d_total)), f['id'], f['nombre'], f['estado'],
                      (done, total), (gdone, gtotal), fmt, f['linea']))
drift.sort(reverse=True)
print('drift >5 items:', len(drift))
for d in drift[:12]:
    print('  M%s %s (%s): checklist %s/%s vs GLOBAL %s/%s delta %d/%d fmt=%s L%d' %
          (d[1], d[2][:30], d[3], d[4][0], d[4][1], d[5][0], d[5][1],
           d[4][0]-d[5][0], d[4][1]-d[5][1], d[6], d[7]))

print()
print('=== T5/T6/T9/T10: carpetas y planes ===')
dirs = sorted([d for d in DOC.iterdir() if d.is_dir()])
mods = [d for d in dirs if re.match(r'^\d{2,3}-', d.name)]
print('directorios DOCUMENTACION:', len(dirs), '| carpetas de modulo NN-:', len(mods))
print('sin plan-actual:', [d.name for d in mods if not (d / 'plan-actual').is_dir()])
print('sin plan-inicial:', [d.name for d in mods if not (d / 'plan-inicial').is_dir()])
print('sin 05-Checklist (modulos):', [d.name for d in mods if not (d / 'plan-actual' / '05-Checklist.md').is_file()])
print('sin 05-Checklist (TODOS los directorios):', [d.name for d in dirs if not (d / 'plan-actual' / '05-Checklist.md').is_file()])

print()
print('=== T7: README.md ===')
rd = (DOC / 'README.md').read_text(encoding='utf-8')
listed = set(re.findall(r'(?:^|[│├└─\s])(\d{2,3}-[\w\-À-ÿ]+)/', rd, flags=re.M))
reales = {d.name for d in mods}
print('fecha README:', re.search(r'\*\*Fecha:\*\*[^\n]*', rd).group(0) if '**Fecha:**' in rd else '?')
print('modulos listados:', len(listed), '| reales:', len(reales))
print('listados pero ausentes:', sorted(listed - reales)[:15])
print('reales no listados:', len(reales - listed))

print()
print('=== T12: dependencias circulares en GLOBAL ===')
grafo = defaultdict(set)
for f in filas:
    for m in re.finditer(r'\b(\d{2,3})\b', f['dep']):
        d = m.group(1)
        if d != f['id']:
            grafo[f['id']].add(d)
# Tarjan SCC
idx = 0
stack, on, ids, low, scc = [], set(), {}, {}, []
def strong(v):
    global idx
    ids[v] = low[v] = idx; idx += 1
    stack.append(v); on.add(v)
    for w in grafo[v]:
        if w not in ids:
            strong(w); low[v] = min(low[v], low[w])
        elif w in on:
            low[v] = min(low[v], ids[w])
    if low[v] == ids[v]:
        comp = []
        while True:
            w = stack.pop(); on.discard(w); comp.append(w)
            if w == v: break
        if len(comp) > 1:
            scc.append(sorted(comp))
for n in list(grafo):
    if n not in ids:
        strong(n)
scc.sort(key=len, reverse=True)
print('aristas:', sum(len(v) for v in grafo.values()), '| SCC circulares:', len(scc))
for c in scc[:10]:
    nombres = [por_id.get(x, [{}])[0].get('nombre', '')[:24] for x in c]
    print('  ', c, nombres)
