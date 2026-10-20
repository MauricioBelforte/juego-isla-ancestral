import os, re
D = 'DOCUMENTACION'
univ = []
for m in sorted(os.listdir(D)):
    if not re.match(r'^\d+-', m):
        continue
    p = os.path.join(D, m, 'plan-actual', '05-Checklist.md')
    if not os.path.isfile(p):
        p = os.path.join(D, m, '05-Checklist.md')
    if os.path.isfile(p):
        univ.append((m, p))

R_XQN = re.compile(r'([\d.]+)\s*\**`?\[[xX]\]\**`?[^0-9]{1,6}([\d.]+)\s*\**`?\[ \]`?\**`?[^0-9]{1,6}([\d.]+)\s*\**`?\[\?\]`?\**`?')
R_XQN_VIEJO = re.compile(r'([\d.]+)\s*\[[xX]\][^/]*/\s*([\d.]+)\s*\[\?\]\s*/\s*([\d.]+)\s*\[ \]')
R_COMP = re.compile(r'Completados?:?\s*:?([\d.]+)')
R_PEND = re.compile(r'Pendientes?:?\s*:?([\d.]+)')
R_NRES = re.compile(r'No\s+resueltos?:?\s*:?([\d.]+)')
R_ITEMS = re.compile(r'(\d[\d.]*)\s*[^\s]{0,3}tems')
SKIP = ('no tenía línea', 'no tenia linea', 'históric', 'historico', 'Conteo real de marcas',
        'Corregí', 'Corregido', 'staleda', 'SUPERADO', 'decía', 'decian', 'dicho', 'era ')

def n(x):
    return int(x.replace('.', '')) if x else 0

res = []
for m, p in univ:
    raw = open(p, 'rb').read().decode('utf-8', errors='replace')
    lines = raw.splitlines()
    med = (sum(1 for l in lines if l.startswith('- [x]')),
           sum(1 for l in lines if l.startswith('- [?]')),
           sum(1 for l in lines if l.startswith('- [ ]')))
    mejor = None  # (linea_idx, dec, fmt, texto)
    for i, l in enumerate(lines, 1):
        if 'totales' not in l.lower() or not re.search(r'\d', l):
            continue
        if l.lstrip().startswith('~~') or '~~' in l:
            continue
        if any(s in l for s in SKIP):
            continue
        dec = fmt = None
        mm = R_XQN.search(l)
        if mm:
            g = [int(x.replace('.', '')) for x in mm.groups()]
            dec, fmt = (g[0], g[2], g[1]), 'x/[ ]/?'
        else:
            mm2 = R_XQN_VIEJO.search(l)
            if mm2:
                g = [int(x.replace('.', '')) for x in mm2.groups()]
                dec, fmt = (g[0], g[1], g[2]), 'x/?/[ ]'
            else:
                mc = R_COMP.search(l)
                mi = R_ITEMS.search(l)
                if mc and mi:
                    dec = (n(mc.group(1)),
                           n(R_NRES.search(l).group(1)) if R_NRES.search(l) else 0,
                           n(R_PEND.search(l).group(1)) if R_PEND.search(l) else 0)
                    fmt = 'Completados'
        if dec:
            mejor = (i, dec, fmt, l.strip())
    res.append((m, med, mejor))

drift = [r for r in res if r[2] and r[2][1] != r[1]]
ok = [r for r in res if r[2] and r[2][1] == r[1]]
sindec = [r for r in res if not r[2]]
print('universo: %d | comparables: %d | OK: %d | DRIFT: %d | sin Totales vigente: %d'
      % (len(res), len(ok) + len(drift), len(ok), len(drift), len(sindec)))
print()
print('=== DRIFT REAL (declarado vigente != medido) ===')
for m, med, mejor in sorted(drift, key=lambda t: -sum(abs(a - b) for a, b in zip(t[2][1], t[1]))):
    i, dec, fmt, txt = mejor
    print('%-38s L%-4d [%s] decl=%s med=%s diff=%d' % (m, i, fmt, dec, med, sum(abs(a - b) for a, b in zip(dec, med))))
print()
print('=== SIN TOTALES VIGENTE (solo líneas barrídas/históricas) ===')
for m, med, mejor in sindec:
    print('%-38s med=%s' % (m, med))
