import sys
sys.stdout.reconfigure(encoding='utf-8')
data = open('game/isla-ancestral/project.godot','r',encoding='utf-8').read()
if 'ServiceRegistry' not in data:
    lines = data.split('\n')
    last_auto = -1
    in_autoload = False
    for i, line in enumerate(lines):
        if line.strip() == '[autoload]':
            in_autoload = True
        elif in_autoload and (line.startswith('[') or line.strip() == ''):
            in_autoload = False
            if last_auto == -1:
                last_auto = i - 1
            break
        if in_autoload and line.strip():
            last_auto = i
    new_line = 'ServiceRegistry="res://scripts/core/service_registry.gd"'
    lines.insert(last_auto + 1, new_line)
    open('game/isla-ancestral/project.godot','w',encoding='utf-8').write('\n'.join(lines))
    print(f'Inserted ServiceRegistry after line {last_auto+1}')
else:
    print('Already there')
