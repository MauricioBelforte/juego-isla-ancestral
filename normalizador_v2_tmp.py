# -*- coding: utf-8 -*-
"""NORMALIZADOR DEFINITIVO v2 — long-path en TODAS las operaciones con rutas largas."""
import io, os, re, shutil

BASE = os.path.abspath('Mensajes entre modelos')
PFX = chr(92) * 2 + '?' + chr(92)

def lp(p):
    return p if len(p) < 240 else PFX + os.path.abspath(p)

def norm_carpetas(canal_path):
    carpetas = {}
    for d in os.listdir(canal_path):
        dp = os.path.join(canal_path, d)
        if not os.path.isdir(dp):
            continue
        m2 = re.match(r'^(\d+)-(\d+)$', d)
        if m2:
            lo_n, hi_n = int(m2.group(1)), int(m2.group(2))
            lo, hi = (1, 100) if lo_n == 0 else (lo_n, hi_n)
        else:
            continue
        lo = max(lo, 1) + (1 if lo == 0 else 0) - (1 if lo == 0 else 0)
        r = ((max(lo, 1) - 1) // 100) * 100 + 1
        carpetas.setdefault((r, r + 99), []).append((d, dp))
    ops = 0
    for (lo, hi), dirs in sorted(carpetas.items()):
        dname = 'arch_%04d-%04d' % (lo, hi)
        canon = os.path.join(canal_path, dname)
        if not os.path.isdir(canon):
            os.makedirs(canon, exist_ok=True)
        for d, dp in dirs:
            if os.path.normpath(dp) == os.path.normpath(canon):
                continue
            for f in os.listdir(dp):
                s = lp(os.path.join(dp, f))
                dst = lp(os.path.join(canon, f))
                if os.path.exists(dst if len(dst) < 240 else dst):
                    dst = lp(os.path.join(canon, re.sub(r'^(\d{3})-', r'\1B-', f)))
                try:
                    shutil.move(os.path.join(dp, f), dst)
                    ops += 1
                except Exception as ex:
                    print('   [SKIP %s]: %s' % (f[:50], ex))
            try:
                os.rmdir(dp)
            except OSError:
                pass
            ops += 1
            print('   [%s] normalizada: %s -> %s' % (canal_path_split(canal_path), d, dname))
    return ops

def canal_path_split(canal_path):
    return os.path.basename(canal_path)

def mover_sueltos(canal_path):
    mov = 0
    for e in os.scandir(canal_path):
        m = re.match(r'(\d{3})-', e.name)
        if not (e.is_file() and e.name.endswith('.md') and m):
            continue
        num = int(m.group(1))
        lo = ((num - 1) // 100) * 100 + 1
        dname = 'arch_%04d-%04d' % (lo, lo + 99)
        dpath = os.path.join(canal_path, dname)
        os.makedirs(dpath, exist_ok=True)
        try:
            shutil.move(e.path, os.path.join(dpath, e.name))
            mov += 1
        except Exception as ex:
            try:
                s_lp = lp(os.path.abspath(e.path))
                d_lp = lp(os.path.abspath(os.path.join(dpath, e.name)))
                datos = open(s_lp, 'rb').read()
                open(d_lp, 'wb').write(datos)
                os.remove(s_lp)
                mov += 1
            except Exception as ex2:
                print('   [FALLO %s]: %s / %s' % (e.name[:60], ex, ex2))
    return mov

total_ops, total_sueltos = 0, 0
for canal in sorted(os.listdir(BASE)):
    cpath = os.path.join(BASE, canal)
    if not os.path.isdir(cpath) or canal.startswith('arch_'):
        continue
    ops1 = norm_carpetas(cpath)
    mov = mover_sueltos(cpath)
    total_ops += ops1
    total_sueltos += mov

print('TOTAL: ops=%d sueltos=%d' % (total_ops, total_sueltos))
