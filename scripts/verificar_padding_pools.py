# -*- coding: utf-8 -*-
"""verificar_padding_pools.py — convención de 3 cifras (fundador 2026-10-19 07:40).

Normaliza TODOS los canales de `Mensajes entre modelos/`:
  - `NUMEROS_DISPONIBLES.txt`: cada número con padding de 3 cifras, sin huecos internos, UTF-8 sin BOM.
  - `.ultima-revision-*.txt`: valor con padding de 3 cifras.

Exit 0 = todo ya estaba bien. Exit 1 = corrigió algo (o faltaba algo).
Cron C lo ejecuta en CADA vuelta: la corrección deja de depender de memoria.
"""
import io, os, re, sys

R = 'Mensajes entre modelos'

FIXES = 0
EERRORES = []

dirs = sorted(d for d in os.listdir(R) if os.path.isdir(os.path.join(R, d)) and not d.startswith('.'))
for canal in dirs:
    D = os.path.join(R, canal)

    pp = os.path.join(D, 'NUMEROS_DISPONIBLES.txt')
    if os.path.isfile(pp):
        raw = io.open(pp, 'rb').read()
        txt = raw.decode('utf-8-sig', errors='replace')
        nums = sorted(set(int(x) for x in txt.split() if x.strip().isdigit()))
        if not nums:
            EERRORES.append('%s: pool vacio o ilegible' % canal)
            continue
        limpio = list(range(nums[0], nums[-1] + 1))
        nuevo = '\n'.join('%03d' % n for n in limpio) + '\n'
        if raw != nuevo.encode('utf-8'):
            io.open(pp, 'wb').write(nuevo.encode('utf-8'))
            FIXES += 1
            print('pool corregido: %s (%03d-%03d)' % (canal, nums[0], nums[-1]))

    for f in os.listdir(D):
        if f.startswith('.ultima-revision'):
            pa = os.path.join(D, f)
            raw = io.open(pa, 'rb').read()
            v = raw.decode('utf-8-sig', errors='replace').strip()
            if not v.isdigit():
                continue
            nuevo = '%03d' % int(v)
            if raw != nuevo.encode('utf-8'):
                io.open(pa, 'wb').write(nuevo.encode('utf-8'))
                FIXES += 1
                print('puntero corregido: %s/%s -> %s' % (canal, f, nuevo))

print('CANAL pendiente (exit por):', '; '.join(EERRORES) if EERRORES else 'ninguno')
print('TOTAL correcciones de padding: %d' % FIXES)
sys.exit(1 if (FIXES or EERRORES) else 0)
