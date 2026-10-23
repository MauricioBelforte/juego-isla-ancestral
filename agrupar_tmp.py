# -*- coding: utf-8 -*-
import io, os, re, shutil

BASE = 'Mensajes entre modelos'
reporte = []

for canal in sorted(os.listdir(BASE)):
    cpath = os.path.join(BASE, canal)
    if not os.path.isdir(cpath):
        continue
    if canal.startswith('arch_') or canal in ('RESUELTOS',):
        continue

    # 1) listar .md de PRIMER NIVEL con prefijo numerico
    mds = []
    for f in os.listdir(cpath):
        m = re.match(r'(\d{3})-', f)
        if f.endswith('.md') and m and os.path.isfile(os.path.join(cpath, f)):
            mds.append((int(m.group(1)), f))
    mds.sort()
    total = len(mds)
    if total <= 100:
        continue  # nada que agrupar

    a_mover = mds[:total - 100]
    # 2) agrupar en bloques de 100 por rango de numeros
    bloques = {}
    for num, f in a_mover:
        lo = ((num - 1) // 100) * 100 + 1
        hi = lo + 99
        key = 'arch_%04d-%04d' % (lo, hi)
        bloques.setdefault(key, []).append((num, f))

    movidos = 0
    skip = 0
    for key, items in sorted(bloques.items()):
        bdir = os.path.join(cpath, key)
        os.makedirs(bdir, exist_ok=True)
        for num, f in items:
            src = os.path.join(cpath, f)
            dst = os.path.join(bdir, f)
            try:
                os.rename(src, dst)
                movidos += 1
            except OSError:
                skip += 1  # fantasma NTFS o bloqueo: se queda

    reporte.append('%s: %d mensajes, movidos %d a %d subcarpetas (skip fantasma %d), raiz queda con %d ultimos' % (canal, total, movidos, len(bloques), skip, total - movidos))

print('== REPORTE DE AGRUPADO ==')
for r in reporte:
    print(' ', r)
io.open(os.path.join(BASE, 'ARCHIVO-AGRUPADO-23oct.md'), 'w', encoding='utf-8', newline='').write(
    '# AGRUPADO DE CANALES 23oct (fundador: grupos cada 100, raiz con ultimos 100)' + chr(10) + chr(10) + chr(10).join(reporte) + chr(10))
print('reporte escrito')
