# -*- coding: utf-8 -*-
import io, os, re, sys
sys.stdout.reconfigure(encoding='utf-8')
muestra = ['event_bus.gd','world_seed.gd','save_schema.gd','fishing_manager.gd','island_registry.gd']
base = 'game/isla-ancestral/scripts'
encontrados = {}
for dirpath, dirs, files in os.walk(base):
    for f in files:
        if f in muestra:
            encontrados[f] = os.path.join(dirpath, f)
for nombre in muestra:
    if nombre not in encontrados:
        print(' ', nombre, '-> NO ENCONTRADO'); continue
    t = io.open(encontrados[nombre], encoding='utf-8').read()
    tiene_class = 'class_name' in t
    # docstring: lineas ## o # en las primeras 10 lineas antes de class_name
    previas = []
    for l in t.split(chr(10))[:12]:
        if 'class_name' in l: break
        previas.append(l)
    doc = any(l.strip().startswith('#') for l in previas)
    print('  %-24s class_name=%-5s docstring=%s' % (nombre, tiene_class, doc))
