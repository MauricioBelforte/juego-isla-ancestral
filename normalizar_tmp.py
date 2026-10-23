# -*- coding: utf-8 -*-
"""NORMALIZADOR: fusiona arch_0000-0099 -> arch_0001-0100, arch_0100-0199 -> arch_0101-0200, etc."""
import io, os, re, shutil

BASE = 'Mensajes entre modelos'

def norm_dir(name):
    """arch_0000-0099 (0-based) -> (100, 199) equivalente 1-based; arch_0100-0199 -> (101, 200)"""
    m = re.match(r'^arch_(\d{4})-(\d{4})$', name)
    if not m:
        return None
    lo0, hi0 = int(m.group(1)), int(m.group(2))
    if lo0 % 100 == 0:  # 0000, 0100, 0200... = 0-based
        return (lo0 + 1, hi0 + 1)  # 1-based equivalente
    return (lo0, hi0)  # ya 1-based

def fusionar(src_dir, dst_dir):
    mov = 0
    for f in os.listdir(src_dir):
        s = os.path.join(src_dir, f)
        d = os.path.join(dst_dir, f)
        if os.path.exists(d):
            nvo = re.sub(r'^(\d{3})-', r'\1B-', f)
            d = os.path.join(dst_dir, nvo)
            if os.path.exists(d):
                nvo = re.sub(r'^(\d{3})([BC]?)-', r'\1C-', f)
                d = os.path.join(dst_dir, nvo)
        shutil.move(s, d)
        mov += 1
    try:
        os.rmdir(src_dir)
    except OSError:
        pass
    return mov

reporte = []
for canal in sorted(os.listdir(BASE)):
    cpath = os.path.join(BASE, canal)
    if not os.path.isdir(cpath) or canal.startswith('arch_'):
        continue
    # encontrar carpetas 0-based que convertan a 1-based canon
    conversiones = []
    for d in os.listdir(cpath):
        dp = os.path.join(cpath, d)
        if not os.path.isdir(dp):
            continue
        r = norm_dir(d)
        if r and r != (int(d[5:9]), int(d[10:14])) and not os.path.isdir(os.path.join(cpath, 'arch_%04d-%04d' % r)):
            conversiones.append((d, os.path.join(cpath, 'arch_%04d-%04d' % r)))
    for viejo, nuevo in conversiones:
        os.rename(viejo, nuevo)
        reporte.append('%s: renombrada %s -> %s' % (canal, os.path.basename(viejo), os.path.basename(nuevo)))
    # fusionar las que quedan duplicadas (misma norm)
    por_rango = {}
    for d in os.listdir(cpath):
        dp = os.path.join(cpath, d)
        if not os.path.isdir(dp):
            continue
        n = norm_dir(d)
        if not n:
            continue
        clave = 'arch_%04d-%04d' % n
        por_rango.setdefault(clave, []).append(dp)
    for clave, dirs in sorted(por_rango.items()):
        if len(dirs) < 2:
            continue
        canon = dirs[0]
        for extra in dirs[1:]:
            mov = fusionar(extra, canon)
            reporte.append('%s: fusionadas -> %s (%d movidos)' % (canal, clave, mov))

for r in reporte:
    print(r)
print('total operaciones:', len(reporte))
