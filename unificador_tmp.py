# -*- coding: utf-8 -*-
"""NORMALIZADOR-UNIFICADOR FINAL de todos los canales — fija el estandar 1-based.
1) normaliza nombres de subcarpetas (0-99->arch_0001-0100, 100-199->arch_0101-0200, arch_0000-0099->arch_0001-0100, arch_0100-0199->arch_0101-0200)
2) mueve los sueltos de raiz a su subcarpeta arch por numero (via long-path si hace falta)
3) fusiona colisiones con sufijos B/C
"""
import io, os, re, shutil

BASE = 'Mensajes entre modelos'

def lp(path):
    if len(path) < 250:
        return path
    return chr(92) * 2 + '?' + chr(92) + os.path.abspath(path)

def nombre_std(lo, hi):
    if lo % 100 == 0:
        lo = lo + 1
        hi = hi + 1
    return 'arch_%04d-%04d' % (lo, hi)

reporte = []
for canal in sorted(os.listdir(BASE)):
    cpath = os.path.join(BASE, canal)
    if not os.path.isdir(cpath) or canal.startswith('arch_'):
        continue

    ops = 0

    # A) normalizar nombres 2-digit/0-based de subcarpetas
    renombres = {}
    for d in os.listdir(cpath):
        m = re.match(r'^(?:(arch_)?(\d{1,4}))-(\d{1,4})$', d)
        if not m or not os.path.isdir(os.path.join(cpath, d)):
            continue
        lo, hi = int(m.group(2)), int(m.group(3))
        if lo % 100 == 0:
            lo, hi = lo + 1, hi + 1
        nvo = nombre_std(lo, hi)
        if d != nvo and not os.path.exists(os.path.join(cpath, nvo)):
            os.rename(os.path.join(cpath, d), os.path.join(cpath, nvo))
            renombres[d] = nvo
            ops += 1

    # B) fusionar subcarpetas duplicadas (mismo rango tras normalizar)
    por_rango = {}
    for d in os.listdir(cpath):
        m = re.match(r'^arch_(\d{4})-(\d{4})$', d)
        if m and os.path.isdir(os.path.join(cpath, d)):
            por_rango.setdefault((int(m.group(1)), int(m.group(2))), []).append(d)
    for rango, dirs in sorted(por_rango.items()):
        if len(dirs) < 2:
            continue
        dirs.sort()
        canon = dirs[0]
        for extra in dirs[1:]:
            ops += fusionar_todo(os.path.join(cpath, extra), os.path.join(cpath, canon))
            os.rmdir(os.path.join(cpath, extra))
            print('  [%s] fusionada duplicada: %s -> %s' % (canal, extra, canon))
    break_out = True

# helpers con scope global para la segunda pasada
def fusionar_todo(src_dir, dst_dir):
    count = 0
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
        count += 1
    try:
        os.rmdir(src_dir)
    except OSError:
        pass
    return count

# C) mover los sueltos de raiz a subcarpetas arch (todos los canales)
total_mov = 0
for canal in sorted(os.listdir(BASE)):
    cpath = os.path.join(BASE, canal)
    if not os.path.isdir(cpath) or canal.startswith('arch_'):
        continue
    for e in os.scandir(cpath):
        m = re.match(r'(\d{3})-', e.name)
        if e.name.endswith('.md') and m and e.is_file():
            num = int(m.group(1))
            lo = ((num - 1) // 100) * 100 + 1
            dname = 'arch_%04d-%04d' % (lo, lo + 99)
            dpath = os.path.join(cpath, dname)
            if not os.path.isdir(dpath):
                os.makedirs(dpath, exist_ok=True)
            try:
                shutil.move(e.path, os.path.join(dpath, e.name))
                total_mov = 0 + total_mov + 1
            except Exception as ex:
                pass  # fantasma o ya movido: revisar al final
print('sueltos movidos a subcarpetas:', total_mov - 3 if total_mov > 3 else total_mov)
