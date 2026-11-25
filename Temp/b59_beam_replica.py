import os, re, json

ROOT = os.path.abspath('.')
DOCS = os.path.join(ROOT, 'DOCUMENTACION')
mods = []
for d in sorted(os.listdir(DOCS)):
    m = re.match(r'^(\d+)-', d)
    if not m:
        continue
    mid = m.group(1)
    cp = os.path.join(DOCS, d, 'plan-actual', '05-Checklist.md')
    if not os.path.isfile(cp):
        continue
    text = open(cp, encoding='utf-8').read()
    rx = len(re.findall(r'^[-*]\s*\[x\]', text, re.M))
    tls = [l for l in text.splitlines() if 'Totales' in l]
    tl = tls[-1] if tls else None
    comp, ttot = None, None
    if tl:
        cm = re.search(r'Completados:\s*(\d+)', tl)
        if cm:
            comp = int(cm.group(1))
        tm = re.search(r'(\d+)\s*[íi]tems', tl)
        if tm:
            ttot = int(tm.group(1))
    mods.append({'id': mid, 'name': d, 'real_x': rx, 'comp': comp, 'tot': ttot,
                 'drift': abs(rx - comp) if comp is not None else None,
                 'ultima': tl.strip() if tl else None})

big = [m for m in mods if m['drift'] is not None and m['drift'] > 5]
print('modulos', len(mods), '| drift_totals>5:', len(big))
for m in sorted(big, key=lambda z: int(z['id'])):
    print(' M%-4s realX=%-4d decl=%-4s drift=%-3d | %s' % (m['id'], m['real_x'], m['comp'], m['drift'], (m['ultima'] or '')[:90]))
beam = {18, 26, 28, 31, 35, 37, 63, 72, 104, 106, 160, 164}
mine = {int(m['id']) for m in big}
print('Beam12 - mio:', sorted(beam - mine))
print('mio - Beam12:', sorted(mine - beam))
json.dump(mods, open('Temp/b59_beam_replica.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
