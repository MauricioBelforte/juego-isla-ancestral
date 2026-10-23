# -*- coding: utf-8 -*-
import io, os, re, shutil

BASE = 'Mensajes entre modelos'

def renombrar_2digit_a_arch(cpath):
    """convertir 0-99 -> arch_0001-0100 y 100-199 -> arch_0101-0200"""
    conv = 0
    for e in os.scandir(cpath):
        m = re.match(r'^(\d+)-(\d+)$', e.name)
        if not (e.is_dir() and m):
            continue
        lo, hi = int(m.group(1)), int(m.group(2))
        nvo_d = 'arch_%04d-%04d' % (lo + 1, hi + 1)
        destino = os.path.join(cpath, nvo_d)
        if os.path.exists(destino):
            # fusionar: mover items y borrar la carpeta vieja
            for f in os.listdir(e.path):
                shutil.move(os.path.join(e.path, f), os.path.join(destino, f))
            os.rmdir(e.path)
        else:
            os.rename(e.path, destino)
        print('  convertida: %s -> %s (%d items)' % (e.name, nvo_d, sum(1 for _ in os.scandir(destino))))
        conv += 1
    return conv

canales_2d = ['DeepSeek-V4.1-Flash', 'Hy3']
for canal in canales_2d:
    cpath = os.path.join(BASE, canal)
    if os.path.isdir(cpath):
        print('==', canal)
        renombrar_2digit_a_arch(cpath)

# mover los sueltos de TODOS los canales con el agrupador estándar
r = subprocess.run(['python', '-X', 'utf8', 'scripts/agrupar_canales.py'], capture_output=True, text=True, encoding='utf-8', errors='replace')
print(r.stdout[-1200:])
