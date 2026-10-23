# -*- coding: utf-8 -*-
"""FUSIONADOR de subcarpetas duplicadas del mismo rango + distribucion de sueltos.
Maneja colisiones de nombre (gemelos) renombrando con sufijo B en el destino."""
import io, os, re, shutil

BASE = 'Mensajes entre modelos'
reporte = []

def fusionar(origen_dir, destino_dir):
    """mueve los items de origen a destino; si colisiona nombre, renombra con -B"""
    mov = 0
    for f in os.listdir(origen_dir):
        src = os.path.join(origen_dir, f)
        dst = os.path.join(destino_dir, f)
        if os.path.exists(dst):
            # colision: renombrar el origen con sufijo B delante del numero
            nvo = re.sub(r'^(\d{3})-', r'\1B-', f)
            dst = os.path.join(destino_dir, nvo)
            if os.path.exists(dst):
                # gemelo x2 ya: usar sufijo C
                nvo = re.sub(r'^(\d{3})([BC]?)-', r'\1C-', f)
                dst = os.path.join(destino_dir, nvo)
        try:
            shutil.move(src, dst)
            mov += 1
        except OSError as ex:
            print('   [SKIP fantasma] %s: %s' % (f[:50], ex))
    try:
        os.rmdir(origen_dir)
    except OSError:
        pass
    return mov

# 1) DeepSeek: fusionar 100-199 (98) + extras y ya? en arch_0101-0200
cpath = os.path.join(BASE, 'DeepSeek-V4.1-Flash')
vieja = os.path.join(cpath, '100-199')
buena = os.path.join(cpath, 'arch_0101-0200')
if os.path.isdir(vieja) and os.path.isdir(buena):
    mov = fusionar(vieja, buena)
    os.rmdir(vieja)
    reporte.append('DeepSeek: fusionadas 100-199 + arch_0101-0200 en arch_0101-0200 (%d movidos)' % mov)

# 2) Hy3: fusionar 100-199 -> arch_0101-0200
hpath = os.path.join(BASE, 'Hy3')
vieja = os.path.join(hpath, '100-199')
buena = os.path.join(hpath, 'arch_0101-0200')
if os.path.isdir(vieja) and os.path.isdir(buena):
    mov = fusionar(vieja, buena)
    os.rmdir(vieja)
    reporte.append('Hy3: fusionadas 100-199 + arch_0101-0200 (%d movidos)' % mov)

# 3) atria-dawn: fusionar arch_0000-0099 + arch_0001-0100 (mismo rango, formatos mezclados)
apath = os.path.join(BASE, 'atria-dawn')
v00 = os.path.join(apath, 'arch_0000-0099')
b01 = os.path.join(apath, 'arch_0001-0100')
if os.path.isdir(v00) and os.path.isdir(b01):
    mov = fusionar(v00, b01)
    os.rmdir(v00)
    reporte.append('atria-dawn: fusionadas arch_0000-0099 + arch_0001-0100 (%d movidos)' % mov)

# 4) Ling: fusionar 0-99 -> arch_0001-0100 + mover sueltos 101+ -> arch_0101-0200
lpath = os.path.join(BASE, 'Ling-3.1-Flash')
v = os.path.join(lpath, '0-99')
b = os.path.join(lpath, 'arch_0001-0100')
if os.path.isdir(v) and os.path.isdir(b):
    mov = fusionar(v, b)
    os.rmdir(v)
    mov2 = 0
    n2 = os.path.join(lpath, 'arch_0101-0200')
    os.makedirs(n2, exist_ok=True)
    for e in os.scandir(lpath):
        m = re.match(r'(\d{3})-', e.name)
        if e.is_file() and m and 101 <= int(m.group(1)) <= 200:
            shutil.move(e.path, os.path.join(n2, e.name))
            mov2 += 1
    reporte.append('Ling: 0-99 fusionada en arch_0001-0100 (%d) + 101-200 sueltos a arch_0101-0200 (%d)' % (mov, mov2))

for r in reporte:
    print(r)
io.open(os.path.join(BASE, 'FUSIONES-23oct.md'), 'w', encoding='utf-8', newline='').write('# FUSIONES DE CARPETAS DUPLICADAS 23oct' + chr(10) + chr(10) + chr(10).join(reporte) + chr(10))
