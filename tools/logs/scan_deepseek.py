# -*- coding: utf-8 -*-
# Temporal: escanear módulos deepseek con progreso bajo. Se borra.
import io, sys, re
sys.stdout.reconfigure(encoding='utf-8')
path = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\CHECKLIST-GLOBAL.md'
with open(path, 'rb') as f:
    content = f.read()
c = content.decode('utf-8', errors='replace')
for line in c.split('\n'):
    if 'deepseek' not in line.lower():
        continue
    m = re.search(r'\|\s*(\d+)\s*\|\s*(\S+(?:-[A-Za-z0-9]+)*)\s*\|\s*(\d+)/(\d+)\s*\|', line)
    if m:
        mid = m.group(1)
        nombre = m.group(2)[:35]
        done = int(m.group(3))
        total = int(m.group(4))
        if done < total * 0.75:
            print('M%s %s: %d/%d (%.0f%%)' % (mid, nombre, done, total, done/total*100))
