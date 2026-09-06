# -*- coding: utf-8 -*-
# Temporal: verificar M160. Se borra.
import io, sys, re
sys.stdout.reconfigure(encoding='utf-8')

# Checklist
path = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\DOCUMENTACION\160-Diseno-De-Ubicaciones-Del-Mundo\plan-actual\05-Checklist.md'
with io.open(path, 'r', encoding='utf-8') as f:
    c = f.read()
x = len(re.findall(r'^\s*- \[x\]', c, re.M))
p = len(re.findall(r'^\s*- \[ \]', c, re.M))
print('M160: [x]=%d [ ]=%d' % (x, p))

# Ubicaciones en world_locations.gd
path2 = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\scripts\data\world_locations.gd'
with io.open(path2, 'r', encoding='utf-8') as f:
    cd = f.read()
locs = re.findall(r'"(RIZ|COR|CEN|AUR)_(\w+)"', cd)
print('Ubicaciones en world_locations.gd: %d' % len(locs))
# Mostrar primeras 10
for isla, nombre in locs[:10]:
    print('  %s_%s' % (isla, nombre))

# Items accionables del checklist
for l in c.split('\n'):
    s = l.strip()
    if s.startswith('- [ ]') and any(k in s for k in ['M45', 'ubicaciones', 'Ubicaciones', 'data-driven', 'JSON', 'M53', 'marca visual']):
        print('ACCIONABLE:', s[:130])
