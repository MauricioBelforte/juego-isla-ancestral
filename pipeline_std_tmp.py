# -*- coding: utf-8 -*-
"""PIPELINE COMPLETO Y DEFINITIVO de estandarizacion de canales (fundador 23oct 05:55).
Metodo unico: centena COMPLETA -> arch_XXXX-XXXX 1-based; raiz = centena EN CURSO.
Fases: (1) fusionar carpetas duplicadas 0-based/1-based, (2) mover sueltos de raiz,
(3) verificacion por canal. Long-path prefix para rutas > 250. Sin push. Sin -c inline."""
import io, os, re, shutil, json

BASE = os.path.abspath('Mensajes entre modelos')
PFX = chr(92) * 2 + '?' + chr(92)

def lp(p):
    return PFX + os.path.abspath(p) if len(p) > 200 else p

def canon(lo, hi):
    if lo % 100 == 0:
        lo, hi = lo + 1, hi + 1
    return (lo, hi)

def nombre(r):
    return 'arch_%04d-%04d' % r

def std_dir(canal):
    cd = os.path.join(BASE, canal)
    # convertir carpetas 2-digit y 0-based
    conv = 0
    for d in sorted(os.listdir(cd)):
        dp = os.path.join(cd, d)
        if not os.path.isdir(dp):
            continue
        m2 = re.match(r'^(\d{1,4})-(\d{1,4})$', d)
        m1 = re.match(r'^arch_(\d{4})-(\d{4})$', d)
        lo, hi = (None, None)
        if m2:
            lo, hi = int(m2.group(1)), int(m2.group(2))
        elif m1:
            _l, _h = int(m1.group(1)), int(m1.group(2))
            if _l % 100 == 0:
                lo, hi = _l + 1, _h + 1
            else:
                lo, hi = _l, _h
        if lo is None:
            continue
        r = canon(lo, hi)
        nvo = nombre(r)
        if d == nvo:
            continue
        dst = os.path.join(cd, nvo)
        if os.path.isdir(dst):
            # fusionar
            for f in os.listdir(dp):
                s = os.path.join(dp, f)
                dd = os.path.join(dst, f)
                if os.path.exists(dd):
                    dd2 = os.path.join(dst, re.sub(r'^(\d{3})-', r'\1B-', f))
                    if os.path.exists(dd2):
                        dd2 = os.path.join(dst, re.sub(r'^(\d{3})([BC]?)-', r'\1C-', f))
                    try:
                        shutil.move(s, dd2)
                    except OSError:
                        continue
                else:
                    try:
                        os.rename(s, dd)
                    except OSError:
                        continue
            try:
                os.rmdir(dp)
            except OSError:
                pass
        else:
            try:
                os.rename(dp, dst)
            except OSError as ex:
                print('  [FALLO rename %s]: %s' % (d, ex))
                continue
        conv += 1
        print('  [%s] convertida: %s -> %s' % (canal, d, nvo))
    return conv

def mover_sueltos(canal):
    cd = os.path.join(BASE, canal)
    mov, errs, mapping = 0, [], []
    items = []
    for e in os.scandir(cd):
        m = re.match(r'(\d{3})-', e.name)
        if e.name.endswith('.md') and m and e.is_file():
            items.append((int(m.group(1)), e.name, e.path))
    items.sort()
    maxnum = max((n for n, _, _ in items), default=0)
    curso_lo = (maxnum // 100) * 100 + 1 if maxnum else 1
    for num, name, path in items:
        if num >= curso_lo:
            continue
        r = canon(((num - 1) // 100) * 100 + 1, ((num - 1) // 100) * 100 + 100)
        dname = nombre(r)
        dpath = os.path.join(cd, dname)
        os.makedirs(dpath, exist_ok=True)
        dst = os.path.join(dpath, name)
        if os.path.exists(dst):
            dst = os.path.join(dpath, re.sub(r'^(\d{3})-', r'\1B-', name))
        try:
            shutil.move(path, dst)
            mov += 1
        except Exception as ex:
            try:
                shutil.move(lp(path), lp(dst))
                mov += 1
            except Exception as ex2:
                errs.append((num, name[:60], str(ex2)[:40]))
    print('  [%s] sueltos movidos: %d | fallos: %d | raiz queda: %d' % (canal, mov, len(errs), maxnum - curso_lo + 1 if maxnum else 0))
    return mov, errs, maxnum

def verificar(canal):
    cd = os.path.join(BASE, canal)
    raiz_n, por_cent = 0, {}
    for e in os.scandir(cd):
        m = re.match(r'(\d{3})-', e.name)
        if e.name.endswith('.md') and m and e.is_file():
            n = int(m.group(1))
            raiz_n += 1
            r = canon(((n - 1) // 100) * 100 + 1, ((n - 1) // 100) * 100 + 100)
            por_cent.setdefault(r, []).append(n)
    issues = []
    for r, ns in sorted(por_cent.items()):
        if len(ns) != 100 and r[1] < max((max(v) for v in por_cent.values()), default=0):
            issues.append('centena %s incompleta en subcarpeta (%d items)' % (nombre(r), len(ns)))
    print('  [VERIFICACION %s] raiz=%d | centenas: %s | issues: %s' % (canal, raiz_n, ', '.join(nombre(r) + '=' + str(len(v)) for r, v in sorted(por_cent.items())), issues if issues else 'NINGUNA'))
    return issues

total_mov = 0
for canal in sorted(os.listdir(BASE)):
    cpath = os.path.join(BASE, canal)
    if not os.path.isdir(cpath) or canal.startswith('arch_'):
        continue
    conv = std_dir(cpath)
    mov, errs, mx = mover_sueltos(canal)
    issues = verificar(canal)
    total_mov += mov

print('TOTAL movidos: %d' % total_mov)
