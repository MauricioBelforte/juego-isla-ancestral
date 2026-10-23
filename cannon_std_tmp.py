# -*- coding: utf-8 -*-
"""NORMALIZADOR FINAL DEFINITIVO v3 — uso directo del prefijo \\?\ en TODO.
Sin try/except que escondan: los fallos se reportan y salteamos con indices."""
import io, os, re, json, shutil

BASE = os.path.abspath('Mensajes entre modelos')
PFX = chr(92) * 2 + '?' + chr(92)

def lp(p):
    p_abs = p if os.path.isabs(p) else os.path.abspath(p)
    return PFX + p_abs if len(p_abs) > 150 else p

def std_rango(lo, hi):
    if lo % 100 == 0:
        return (lo + 1, hi + 1)
    return (lo, hi)

def nombre_std(r):
    return 'arch_%04d-%04d' % r

total_fusion = 0
total_renom = 0
total_sueltos = 0
errores = []

for canal in sorted(os.listdir(BASE)):
    cpath = os.path.join(BASE, canal)
    if not os.path.isdir(cpath) or canal.startswith('arch_'):
        continue
    reporte_canal = []

    # ---- FASE 1: renombrar carpetas no-estándar + fusionar duplicadas del rango ----
    carpetas = {}
    try:
        for f in os.listdir(cpath):
            if not os.path.isdir(os.path.join(cpath, f)):
                continue
            m2 = re.match(r'^(\d{1,4})-(\d{1,4})$', f)
            m1 = re.match(r'^arch_(\d{4})-(\d{4})$', f)
            lo = hi = None
            if m2:
                lo, hi = int(m2.group(1)), int(m2.group(2))
            elif m1:
                lo, hi = int(m1.group(1)), int(m1.group(2))
            if lo is None:
                continue
            r = std_rango(lo, hi)
            carpetas.setdefault(r, []).append((f, os.path.join(cpath, f)))
    except OSError:
        continue

    for r, dirs in sorted(carpetas.items()):
        nvo_d = nombre_std(r)
        # renombrar las que no tienen el nombre canón
        for d, dp in dirs:
            if d == nvo_d:
                continue
            dst = os.path.join(cpath, nvo_d)
            try:
                if os.path.isdir(dst):
                    # fusionar
                    for f in os.listdir(dp):
                        s = os.path.join(dp, f)
                        dd = lp(os.path.join(dst, f))
                        if os.path.exists(dd if len(dd) < 250 else d):
                            continue
                        shutil.move(s, lp(dd) if len(dd) > 200 else dd)
                        total_fusion += 1
                    try:
                        os.rmdir(dp)
                    except OSError:
                        pass
                    print('[%s] fusion: %s -> %s' % (canal, d, nvo_d))
                else:
                    try:
                        os.rename(dp, dst) if len(dst) < 240 else os.rename(lp(dp), lp(dst))
                    except OSError:
                        shutil.move(lp(dp), lp(dst))
                    total_renom += 1
                    print('[%s] renombrada: %s -> %s' % (canal, d, nvo_d))
            except OSError as ex:
                errores.append('[%s] %s: %s' % (canal, d, ex))

    # ---- FASE 2: mover sueltos de raíz a su centena (long-path si hace falta) ----
    sueltos = 0
    try:
        for e in os.scandir(cpath):
            m = re.match(r'(\d{3})-', e.name)
            if not (e.is_file() and e.name.endswith('.md') and m):
                continue
            num = int(m.group(1))
            lo = ((num - 1) // 100) * 100 + 1
            dname = nombre_std((lo, lo + 99))
            dpath = os.path.join(cpath, dname)
            os.makedirs(dpath, exist_ok=True)
            dst = os.path.join(dpath, e.name)
            try:
                os.rename(e.path, dst)
                sueltos += 1
                total_sueltos += 1
            except OSError:
                try:
                    shutil.move(lp(e.path), lp(dst) if len(dst) < 240 else lp(os.path.abspath(dst)))
                    sueltos += 1
                except Exception as ex:
                    errores.append('[%s] %s: %s' % (canal, e.name[:50], ex))
    except OSError:
        pass
    if sueltos:
        print('[%s] sueltos: %d' % (canal, sueltos))

for err in errores[:10]:
    print('ERROR:', err)
print('TOTAL fusionadas/renombradas/sueltos:', total_fusion, total_renom, total_sueltos)
