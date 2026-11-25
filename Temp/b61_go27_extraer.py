# -*- coding: utf-8 -*-
"""Extrae los 27 [?] reales de los 10 modulos (resueltos por nombre) con texto completo."""
import os, re, json
ROOT = os.path.abspath('.')
DOC = os.path.join(ROOT, 'DOCUMENTACION')

ROWS = [
 ('21','Dialogos','21-Dialogos'), ('33','Agricultura','33-Agricultura'),
 ('14','Recursos','15-Recursos'), ('30','Ciclo-Dia-Noche','31-Ciclo-Dia-Noche'),
 ('61','Rendimiento','61-Rendimiento'), ('36','Museos','37-Museos-Y-Colecciones'),
 ('155','Fotos','56-Fotografia'), ('52','UI-UX','53-UI-UX'),
 ('137','Vertical-Slice','138-Vertical-Slice'), ('44','Arte-3D','45-Arte-3D'),
]

items = []
for num, name, dname in ROWS:
    cp = os.path.join(DOC, dname, 'plan-actual', '05-Checklist.md')
    lines = open(cp, encoding='utf-8', errors='replace').read().splitlines()
    for i, l in enumerate(lines, 1):
        if re.match(r'^\s*-\s*\[\?\]', l):
            items.append({'mod': num, 'name': name, 'dir': dname,
                          'line': i, 'text': l.strip()})

json.dump(items, open('Temp/b61_go27_items.json','w',encoding='utf-8'), ensure_ascii=False, indent=1)
print('TOTAL [?] reales:', len(items))
for it in items:
    print('M%-4s L%-4d %s' % (it['mod'], it['line'], it['text'][:260]))
