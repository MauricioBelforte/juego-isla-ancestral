# -*- coding: utf-8 -*-
import os, re, json
ROOT = os.path.abspath('.')
DOC = os.path.join(ROOT, 'DOCUMENTACION')

# (numero director, nombre director, dir real candidato, esperado)
ROWS = [
 ('21','Dialogos','21-Dialogos',31),
 ('33','Agricultura','33-Agricultura',30),
 ('14','Recursos','15-Recursos',30),
 ('30','Ciclo-Dia-Noche','31-Ciclo-Dia-Noche',28),
 ('61','Rendimiento','61-Rendimiento',28),
 ('36','Museos','37-Museos-Y-Colecciones',27),
 ('155','Fotos','56-Fotografia',26),
 ('52','UI-UX','53-UI-UX',25),
 ('137','Vertical-Slice','138-Vertical-Slice',25),
 ('44','Arte-3D','45-Arte-3D',24),
]
print('label             dir real                  esp  canonico  str.count  inline-diff')
for num,name,dname,exp in ROWS:
    cp = os.path.join(DOC, dname, 'plan-actual', '05-Checklist.md')
    txt = open(cp, encoding='utf-8', errors='replace').read()
    canon = len(re.findall(r'(?m)^\s*-\s*\[\?\]', txt))
    naive = txt.count('[?]')
    print('M%-4s %-16s %-25s %3d  %3d      %3d       %+d' % (
        num,name[:16],dname,exp,canon,naive,naive-canon))
