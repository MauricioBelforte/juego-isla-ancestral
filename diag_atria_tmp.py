# -*- coding: utf-8 -*-
import io, os, re

base = os.path.join('Mensajes entre modelos', 'atria-dawn')
raiz = []
for f in os.listdir(base):
    m = re.match(r'(\d{3})-', f)
    if f.endswith('.md') and m and os.path.isfile(os.path.join(base, f)):
        raiz.append((int(m.group(1)), f))
raiz.sort()
print('== RAIZ atria-dawn: %d archivos == | rango: %d-%d' % (len(raiz), raiz[0][0], raiz[-1][0]))
for n, f in raiz:
    print('  %03d | %s' % (n, f[len(f) - min(len(f), 85):]))
print()
for d in sorted(os.listdir(base)):
    dp = os.path.join(base, d)
    if os.path.isdir(dp):
        try:
            cnt = sum(1 for x in os.listdir(dp) if x.endswith('.md'))
        except OSError:
            cnt = '>'
        print('SUBCARPETA:', d, '->', cnt, 'items')
