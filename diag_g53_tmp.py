# -*- coding: utf-8 -*-
import io, os, re, shutil

base = 'Mensajes entre modelos/G-5.3-Flash-Agente'

# listar TODOS .md en RAIZ (primer nivel) con su numero
raiz = []
for f in os.listdir(base):
    if f.endswith('.md') and os.path.isfile(os.path.join(base, f)):
        m = re.match(r'(\d{3})', f)
        if m:
            raiz.append((int(m.group(1)), f))
raiz.sort()

# listar lo que ya esta en subcarpetas
ya_en_arch = {}
for d in os.listdir(base):
    dp = os.path.join(base, d)
    if os.path.isdir(dp) and d.startswith('arch_'):
        m = re.match(r'arch_(\d{4})-(\d{4})', d)
        if m:
            ya_en_arch[(int(m.group(1)), int(m.group(2)))] = [os.listdir(dp), ]

# diagnostico: los [ ] en raiz vs ranges
print('RAIZ: %d archivos .md numericos' % len(raiz))
nums = [n for n, _ in raiz]
print('rango raiz:', min(nums) if nums else '-', '-', max(nums) if nums else '-')
from collections import Counter
c = Counter(nums)
print('duplicados en raiz:', {n: k for n, k in c.items() if k > 1} or 'NINGUNO')
# kontiguos faltantes entre 1 y max
faltantes = [i for i in range(1, max(nums) + 1) if i not in set(nums)] if nums else []
print('huecos: %d' % len(faltantes), faltantes[:15] if faltantes else '')
print()
print('detalle raiz (num - nombre):')
for n, f in raiz[:60]:
    print('  %03d' % n, f[:90])
