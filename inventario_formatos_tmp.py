# -*- coding: utf-8 -*-
import os, re

BASE = 'Mensajes entre modelos'
reporte = {}
for canal in sorted(os.listdir(BASE)):
    cpath = os.path.join(BASE, canal)
    if not os.path.isdir(cpath):
        continue
    subdirs = []
    sueltos = 0
    for e in os.scandir(cpath):
        if not e.is_dir():
            continue
        # formatos reconocidos de subcarpetas de archivo
        m1 = re.match(r'^arch_(\d{4})-(\d{4})$', e.name)
        m2 = re.match(r'^(\d+)-(\d+)$', e.name)  # formato 0-99 / 100-199
        m3 = re.match(r'^(\d+)_(\d+)$', e.name)
        if m1:
            subdirs.append(e.name + ' (arch-formato-4digit, %d items)' % sum(1 for _ in os.scandir(e.path)))
        elif m2:
            subdirs.append(e.name + ' (formato-2digit, %d items)' % sum(1 for _ in os.scandir(e.path)))
        elif re.match(r'^\w+[\s_-]+\d+', e.name) and not e.name.startswith(('arch_', '.git', 'logs', 'kilo')):
            # otras subcarpetas no tecnicas: inspeccionar si contienen .md numerados
            cnt = sum(1 for f in os.listdir(e.path) if re.match(r'\d{3}-', f))
            if cnt:
                subdirs.append(e.name + ' (carpeta-libre con %d mensajes)' % cnt)
    for e in os.scandir(cpath):
        if e.is_file() and re.match(r'^\d{3}-', e.name) and e.name.endswith('.md'):
            sueltos += 1
    reporte[canal] = {'subcarpetas': subdirs, 'sueltos': sueltos}

for canal, r in sorted(reporte.items()):
    if r['subcarpetas'] or r['sueltos']:
        print('==', canal)
        for s in r['subcarpetas']:
            print('   ', s)
        print('    sueltos en raiz:', r['sueltos'])
