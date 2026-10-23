# -*- coding: utf-8 -*-
import io, os, re, shutil

BASE = 'Mensajes entre modelos'

def norm_rango(nombre):
    """arch_0000-0099 (0-based) -> (101, 200); arch_0100-0199 -> (201, 200+100) etc."""
    m = re.match(r'^arch_(\d{4})-(\d{4})$', nombre)
    if not m:
        return None
    lo0, hi0 = int(m.group(1)), int(m.group(2))
    if lo0 % 100 == 0:
        return (lo0 + 1, hi0 + 1)
    return (lo0, hi0)

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

total_ops = 0
for canal in sorted(os.listdir(BASE)):
    cpath = os.path.join(BASE, canal)
    if not os.path.isdir(cpath) or canal.startswith('arch_'):
        continue
    ops = 0

    # acumular carpetas por rango normalizado
    grupos = {}
    for d in os.listdir(cpath):
        dp = os.path.join(cpath, d)
        if not os.path.isdir(dp):
            continue
        r = norm_rango(d)
        if not r:
            continue
        grupos.setdefault(r, []).append((d, dp))

    for r, dirs in sorted(grupos.items()):
        canon_d = 'arch_%04d-%04d' % r
        canon_p = os.path.join(cpath, canon_d)
        otros = [(d, dp) for d, dp in dirs if d != canon_d]
        if not otros:
            continue
        if r[1] - r[0] + 1 != 100:
            continue  # rango no-centena: skip (no tocar)
        os.makedirs(canon_p, exist_ok=True)
        for d, dp in otros:
            ops += fusionar(dp, canon_p)
            print('  [%s] fusion %s -> %s' % (canal, d, canon_d))
            os.rmdir(dp)

    if ops:
        total_ops += ops
        print('[%s] %d operaciones de normalizacion' % (canal, ops))

print('TOTAL operaciones de normalizacion:', total_ops)
