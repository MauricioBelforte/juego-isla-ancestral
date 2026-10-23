# -*- coding: utf-8 -*-
"""NORMALIZADOR COMPLETO DEFINITIVO de todos los canales de mensajes.
Estándar único (fundador 23oct 06:17): centenas 1-based sin solapamiento.
- carpeta 001-100: contiene mensajes 001-100
- carpeta 101-200: contiene mensajes 101-200
- etc. (ningún número se repite entre carpetas)
- carpetas viejas (2-digit, 0-based, cruza-frontera) se fusionan/alinean
- sueltos de raíz se mueven a su centena (long-path por si la ruta supera 260)
"""
import os, re, shutil

BASE = 'Mensajes entre modelos'
PFX = chr(92) * 2 + '?' + chr(92)  # \\?\ long-path prefix

def std_carpeta(num):
    """el numero de mensaje -> (lo, hi) de su carpeta 1-based"""
    lo = ((num - 1) // 100) * 100 + 1
    return (lo, lo + 99)

def norm_carpetas(canal_path, reporte):
    """1) convierte carpetas 2-digit (0-99, 100-199) al estandar arch_ 1-based
       2) fusiona duplicados del mismo rango normalizado
       devuelve nº de operaciones"""
    carpetas = {}
    for d in os.listdir(canal_path):
        dp = os.path.join(canal_path, d)
        if not os.path.isdir(dp):
            continue
        m2 = re.match(r'^(\d+)-(\d+)$', d)
        if m2:
            lo_n, hi_n = int(m2.group(1)), int(m2.group(2))
            # 0-99 es 0-based=1..100? convencion 2digit incluye 0: 0-99 -> 001-100
            lo, hi = max(lo_n + 1, 1), hi_n + 1 if hi_n % 100 == 99 and lo_n == 0 else (lo_n, hi_n)
            if lo_n == 0:
                lo, hi = 1, 100
        else:
            continue
        r = std_carpeta(lo)
        carpetas.setdefault(r, []).append((d, dp))

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
                s = os.path.join(dp, f)
                dst = os.path.join(canon, f)
                if os.path.exists(dst):
                    nvo = re.sub(r'^(\d{3})-', r'\1B-', f)
                    dst = os.path.join(canon, nvo)
                    if os.path.exists(dst):
                        nvo = re.sub(r'^(\d{3})([BC]?)-', r'\1C-', f)
                        dst = os.path.join(canon, nvo)
                shutil.move(s, dst)
            try:
                os.rmdir(dp)
            except OSError:
                pass
            ops += 1
            print('   [%s] normalizada/carpetada: %s -> %s' % (canal, d, dname))
    # tambien las que eran arch_ 0-based: arch_0000-0099 -> arch_0001-0100, etc.
    for d in list(os.listdir(canal_path)):
        m = re.match(r'^arch_(\d{4})-(\d{4})$', d)
        if not m:
            continue
        lo0 = int(m.group(1))
        if lo0 % 100 != 0:
            continue
        lo, hi = lo0 + 1, int(m.group(2)) + 1
        dname = 'arch_%04d-%04d' % (lo, hi)
        canon = os.path.join(canal_path, dname)
        dp = os.path.join(canal_path, d)
        if os.path.normpath(dp) == os.path.normpath(canon):
            continue
        if os.path.isdir(canon):
            for f in os.listdir(dp):
                s = os.path.join(dp, f)
                dst = os.path.join(canon, f)
                if os.path.exists(dst):
                    continue
                shutil.move(s, dst)
            try:
                os.rmdir(dp)
            except OSError:
                pass
            ops += 1
            print('   [%s] normalizada 0-based: %s -> %s' % (canal, d, dname))
        else:
            os.rename(dp, canon)
            ops += 1
            print('   [%s] normalizada 0-based rename: %s -> %s' % (canal, d, dname))
    return ops

def mover_sueltos(canal_path, reporte):
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
        src_abs = os.path.abspath(e.path)
        dst_abs = os.path.abspath(os.path.join(dpath, e.name))
        try:
            os.rename(e.path, os.path.join(dpath, e.name))
            mov += 1
        except OSError:
            try:
                datos = open(PFX + src_abs, 'rb').read()
                open(PFX + dst_abs, 'wb').write(datos)
                os.remove(PFX + src_abs)
                mov += 1
            except Exception as ex:
                reporte.append(num)
    return mov

total_ops, total_sueltos = 0, 0
reportes = {}
for canal in sorted(os.listdir(BASE)):
    cpath = os.path.join(BASE, canal)
    if not os.path.isdir(cpath) or canal.startswith('arch_'):
        continue
    ops1 = norm_carpetas(cpath, reportes.setdefault(canal, []))
    mov = mover_sueltos(cpath, reportes[canal])
    total_ops += ops1
    total_sueltos += mov
    # verificacion
    raiz_final = [f for f in os.listdir(cpath) if f.endswith('.md') and re.match(r'\d{3}-', f) and os.path.isfile(os.path.join(cpath, f))]
    print('[%s] ops-fase1=%d sueltos-movidos=%d raiz-final=%.0d' % (canal, ops1, mov, len(raiz_final)))

print('TOTAL carpetas normalizadas: %d | sueltos movidos: %d' % (total_ops, total_sueltos))
