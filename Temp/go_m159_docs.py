import os, re, io
root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
items = os.path.join(root, 'game', 'isla-ancestral', 'data', 'items')
pref = ['OBJ-COC','OBJ-TAL','OBJ-EXT','OBJ-NAT','OBJ-CON','OBJ-HER','OBJ-ITE','OBJ-ROP','OBJ-ART','OBJ-EVE','OBJ-SEC']
stats = {}
for p in pref:
    stats[p] = {'total':0, 'desc':0, 'icono':0, 'precio':0, 'modelo':0, 'named':0}
for f in sorted(os.listdir(items)):
    if not f.endswith('.tres'): continue
    t = io.open(os.path.join(items, f), encoding='utf-8', errors='replace').read()
    ids = re.findall(r'OBJ-[A-Z]{3}-\d{3}', t)
    if not ids: continue
    p = ids[0].rsplit('-',1)[0]
    if p not in stats: continue
    s = stats[p]
    s['total'] += 1
    for key, field in [('desc','descripcion'),('icono','icono'),('precio','precio_compra'),('modelo','modelo_3d')]:
        m = re.search(r'^%s\s*=\s*(.+)$' % field, t, re.M)
        if m and m.group(1).strip() not in ('', 'null', '0', '""'):
            s[key] += 1
    m = re.search(r'^nombre\s*=\s*"(.+)"', t, re.M)
    if m and m.group(1).strip(): s['named'] += 1
print('prefijo | .tres | con descripcion | con nombre | con icono | con precio | con modelo3d')
for p in pref:
    s = stats[p]
    print('%s | %d | %d | %d | %d | %d | %d' % (p, s['total'], s['desc'], s['named'], s['icono'], s['precio'], s['modelo']))
