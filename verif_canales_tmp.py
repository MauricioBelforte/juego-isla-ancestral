# -*- coding: utf-8 -*-
"""VERIFICACION FINAL modelo-por-modelo: cada canal debe quedar con
raiz = SOLO centena en curso (sin carpetas 2-digit, sin gemelos visibles, sin carpetas viejas)
subcarpetas = SOLO formato arch_XXXX-XXXX (4 digitos, 1-based, sin rangos duplicados)
"""
import os, re

BASE = 'Mensajes entre modelos'
problemas_totales = 0

for canal in sorted(os.listdir(BASE)):
    cpath = os.path.join(BASE, canal)
    if not os.path.isdir(cpath):
        continue
    issues = []

    raiz_md = [f for f in os.listdir(cpath) if f.endswith('.md') and os.path.isfile(os.path.join(cpath, f))]
    subs = [d for d in os.listdir(cpath) if os.path.isdir(os.path.join(cpath, d))]

    # problema 1: subcarpetas en formato 2-digit sin convertir
    for d in subs:
        if re.match(r'^\d{1,4}-\d{1,4}$', d) or re.match(r'^\d{1,4}_\d{1,4}$', d):
            issues.append('subcarpeta 2-digit sin convertir: ' + d)
        if re.match(r'^arch_(\d{4})-(\d{4})$', d):
            lo, hi = int(d[5:9]), int(d[10:14])
            if lo % 100 == 0 and lo > 0:  # 0000-0099 = 0-based residual
                issues.append('centena 0-based residual: ' + d)
            if lo != hi - 99 + 1 and (hi - lo + 1) != 100:
                issues.append('rango no-centena: %s (%d items)' % (d, hi - lo + 1))

    # problema 2: carpetas duplicadas mismo rango (mismo par en 2 formats)
    par_map = {}
    for d in subs:
        m = re.match(r'^(?:arch_)?(\d{1,4})-(\d{1,4})$', d)
        if m:
            lo0, hi0 = int(m.group(1)), int(m.group(2))
            if lo0 % 100 == 0:
                lo0, hi0 = lo0 + 1, hi0 + 1  # normal 0->1-based
            centena = 'arch_%04d-%04d' % (lo0, hi0)
            par_map.setdefault(centena, []).append(d)
    for cent, dirs in par_map.items():
        if len(dirs) > 1:
            issues.append('rango duplicado en carpetas: %s <- %s' % (cent, dirs))

    # problema 3: archivos fantasma en raiz fuera de la centena en curso
    nums_raiz = []
    for f in raiz_md:
        m = re.match(r'(\d{3})', f)
        if m:
            try:
                nums_raiz.append((int(m.group(1)), os.path.getmtime(os.path.join(cpath, f)), f))
            except OSError:
                issues.append('FANTASMA en raiz: ' + f[:60])
    if nums_raiz:
        mx = max(n for n, _, _ in nums_raiz)
        curso_lo = (mx // 100) * 100 + 1 if mx else 1
        fuera = [n for n, _, _ in nums_raiz if n < curso_lo]
        if fuera and len(fuera) > 0 and mx >= curso_lo + 100:
            issues.append('raiz tiene %d archivos fuera de la centena en curso (min=%d)' % (len(fuera), min(fuera)))

    status = 'OK' if not issues else 'PROBLEMAS'
    if issues:
        problemas_totales += len(issues)
        print('[%s] %s' % (canal, status))
        for i in issues:
            print('   -', i)
    else:
        print('[%s] OK (raiz %d, subs %d)' % (canal, len(raiz_md), len(subs)))

print()
print('=== TOTAL PROBLEMAS RESIDUALES:', problemas_totales, '===')
