import os
base = 'game/isla-ancestral/'
p = os.path.join(base, 'project.godot')
t = open(p, encoding='utf-8').read()
i = t.find('[autoload]')
j = t.find('[', i + 1)
seg = t[i:j] if j >= 0 else t[i:]
missing = []
ok = 0
for line in seg.splitlines():
    line = line.strip()
    if not line or line.startswith(';') or '=' not in line:
        continue
    name, path = line.split('=', 1)
    name = name.strip()
    path = path.strip().strip('"').lstrip('*')
    fp = base + path.replace('res://', '')
    if os.path.exists(fp):
        ok += 1
    else:
        missing.append((name, path))
print('Autoloads OK:', ok, '| Faltantes:', len(missing))
for m in missing:
    print('  FALTA:', m)
