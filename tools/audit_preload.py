import os, re
root = 'game/isla-ancestral'
bad = []
count = 0
pat = re.compile(r'(preload|load|ResourceLoader\.load|load_step|ResourceLoader\.exists)\s*\(\s*[\'"](res://[^\'"]+)[\'"]')
for dp, _, fns in os.walk(root):
    for fn in fns:
        if not fn.endswith('.gd'):
            continue
        fp = os.path.join(dp, fn)
        try:
            txt = open(fp, encoding='utf-8', errors='ignore').read()
        except Exception:
            continue
        for m in pat.finditer(txt):
            count += 1
            rel = m.group(2).replace('res://', '')
            target = os.path.join(root, rel)
            if not os.path.exists(target):
                bad.append((fp.replace(root + os.sep, ''), m.group(2)))
print('Referencias res:// escaneadas:', count)
print('FALTANTES:', len(bad))
for b in bad:
    print('  ', b[0], '->', b[1])
