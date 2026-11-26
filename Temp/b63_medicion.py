import os, re, io, subprocess

root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
doc = os.path.join(root, 'DOCUMENTACION')
rx = re.compile(r'^\s*-\s+\[([ x?>-])\]', re.M)

mods = [
    ('M75', 'Postgame', 87),
    ('M156', 'Terrenos', 82),
    ('M74', 'Eventos', 58),
    ('M73', 'Coleccionables', 56),
    ('M71', 'Progresion', 44),
    ('M27', 'Islas', 40),
    ('M159', 'Catalogo', 37),
    ('M49', 'Iluminacion', 25),
    ('M115', 'Hardware', 26),
    ('M105', 'Telemetria', 28),
]

def folder_for(mid, name):
    pref = mid[1:] + '-'
    for d in os.listdir(doc):
        if d.startswith(pref):
            return d
    return None

print('modulo | director | real | delta | archivo | git diff desde b60 (956215c)', flush=True)
total = 0
for mid, name, claimed in mods:
    d = folder_for(mid, name)
    p = os.path.join(doc, d, 'plan-actual', '05-Checklist.md') if d else ''
    if not os.path.isfile(p):
        print(mid, 'SIN CHECKLIST', p, flush=True)
        continue
    t = io.open(p, encoding='utf-8', errors='replace').read()
    c = {}
    for m in rx.finditer(t):
        c[m.group(1)] = c.get(m.group(1), 0) + 1
    q = c.get('?', 0)
    total += q
    rel = os.path.relpath(p, root).replace('\\', '/')
    changed = subprocess.check_output(['git', 'diff', '--name-only', '956215c..HEAD', '--', rel], cwd=root).decode('utf-8', 'replace').strip()
    tl = [l for l in t.splitlines() if 'Totales' in l]
    print('%s | %d | %d | %+d | %s | %s | Totales=%s' % (
        mid, claimed, q, q-claimed, rel, changed or 'SIN CAMBIOS', tl[-1][:100] if tl else 'NA'), flush=True)
    print('   marcas:', c, flush=True)

print('TOTAL [?] real =', total, ' director suma =', sum(x[2] for x in mods), flush=True)
