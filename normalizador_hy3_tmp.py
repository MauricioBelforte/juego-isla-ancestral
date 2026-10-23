# -*- coding: utf-8 -*-
"""NORMALIZADOR HY3 + TODOS LOS CANALES — con try por archivo y long-path.
Fusiona arch_0100-0199 (0-based) con su igual 1-based; mueve sueltos de raíz."""
import os, re, shutil, io

BASE = 'Mensajes entre modelos'
PFX = chr(92) * 2 + '?' + chr(92)

def norm_rango(nombre):
    m = re.match(r'^arch_(\d{4})-(\d{4})$', nombre)
    if not m:
        return None
    lo, hi = int(m.group(1)), int(m.group(2))
    if lo % 100 == 0:
        return (lo + 1, hi + 1)
    return (lo, hi)

def fusionar_dir(src, dst):
    mov = 0
    for f in os.listdir(src):
        s = os.path.join(src, f)
        d = os.path.join(dst, f)
        if os.path.exists(d):
            nvo = re.sub(r'^(\d{3})-', r'\1B-', f)
            d = os.path.join(dst, nvo)
    for f in os.listdir(src):
        s = os.path.join(src, f)
        d = os.path.join(dst, f)
        try:
            shutil.move(s, d)
            mov += 1
        except OSError:
            try:
                shutil.move(PFX + os.path.abspath(s), PFX + os.path.abspath(d))
                mov += 1
            except OSError:
                pass
    try:
        os.rmdir(src)
    except OSError:
        pass
    return mov

# ============ PASO A: por canal — fusionar 0-based con 1-based del mismo rango ============
for canal in sorted(os.listdir(BASE)):
    ccanal = os.path.join(BASE, canal)
    if not os.path.isdir(ccanal):
        continue
    grupos = {}
    for d in os.listdir(ccanal):
        dp = os.path.join(ccanal, d)
        if not os.path.isdir(dp):
            continue
        r = norm_rango(d)
        if not r:
            continue
        grupos.setdefault(r, []).append((d, dp))
    for r, dirs in sorted(grupos.items()):
        if len(dirs) < 2:
            continue
        canon_d = 'arch_%04d-%04d' % r
        canon_p = os.path.join(ccanal, canon_d)
        if not os.path.isdir(canon_p):
            os.rename(dirs[0][1], canon_p)
            dirs = dirs[1:]
        for d, dp in dirs:
            mov = fusionar_dir(dp, canon_p)
            print('[%s] fusionada %s -> %s (%d)' % (canal, d, canon_d, mov))
            try:
                os.rmdir(dp)
            except OSError:
                pass

# ============ PASO B: mover sueltos de raiz a su carpeta (todos canales, excepto G-5.3) ============
for canal in sorted(os.listdir(BASE)):
    if canal == 'G-5.3-Flash-Agente':
        continue
    ccanal = os.path.join(BASE, canal)
    if not os.path.isdir(ccanal):
        continue
    mov2 = 0
    for e in os.scandir(ccanal):
        m = re.match(r'(\d{3})-', e.name)
        if not (e.is_file() and e.name.endswith('.md') and m):
            continue
        num = int(m.group(1))
        r = (((num - 1) // 100) * 100 + 1, ((num - 1) // 100) * 100 + 100)
        dname = 'arch_%04d-%04d' % r
        dpath = os.path.join(ccanal, dname)
        os.makedirs(dpath, exist_ok=True)
        dst = os.path.join(dpath, e.name)
        if os.path.exists(dst):
            dst = os.path.join(dpath, e.name.replace('-2026', 'B-2026'))
        try:
            os.rename(e.path, dst)
            mov2 += 1
        except OSError:
            try:
                shutil.move(PFX + os.path.abspath(e.path), PFX + os.path.abspath(dst))
                mov2 += 1
            except OSError:
                pass
    if mov2:
        print('[%s] sueltos movidos: %d' % (canal, mov2))

# ============ PASO C: verificacion Hy3 y global ============
print()
print('=== HY3 FINAL ===')
h = os.path.join(BASE, 'Hy3')
for d in sorted(os.listdir(h)):
    dp = os.path.join(h, d)
    if os.path.isdir(dp):
        print(' ', d, '->', len(os.listdir(dp)), 'items')
raiz_h = len([f for f in os.listdir(h) if f.endswith('.md') and os.path.isfile(os.path.join(h, f))])
print('  raiz sueltos:', raiz_h)
print()
resid = 0
for canal in sorted(os.listdir(BASE)):
    c2 = os.path.join(BASE, canal)
    if not os.path.isdir(c2):
        continue
    for d in os.listdir(c2):
        m = re.match(r'^arch_(\d{4})-(\d{4})$', d)
        if m and int(m.group(1)) % 100 == 0 and int(m.group(1)) > 0:
            print('RESIDUAL 0-based:', canal, d)
            resid += 1
print('RESIDUALES 0-based TOTALES:', resid)
