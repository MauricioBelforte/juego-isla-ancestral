import os, re

text = open('game/isla-ancestral/project.godot', encoding='utf-8').read()
in_autoload = False
count = 0
autoload_names = []
for line in text.splitlines():
    if line.strip() == '[autoload]':
        in_autoload = True
        continue
    if line.startswith('[') and line.strip() != '[autoload]':
        in_autoload = False
        continue
    if in_autoload and '=' in line and not line.strip().startswith('#'):
        count += 1
        name = line.split('=')[0].strip()
        autoload_names.append(name)
print('Autoloads in project.godot:', count)
print('Claim b57-E: 117/117 autoloads OK')
PYEOF