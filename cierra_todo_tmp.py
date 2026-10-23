# -*- coding: utf-8 -*-
"""CIERRE DEFINITIVO de todos los pendientes: detecta, responde con acuses cortos,
actualiza estado, commitea — en una sola pasada robusta con try/except por archivo."""
import os, re, json, io, subprocess
import time

YO = 'glm-5.3-flash-director-a-'
EXCL = {'G-5.3-Flash-Agente'}
BASE = 'Mensajes entre modelos'

def pendientes_de_canal(canal):
    base = os.path.join(BASE, canal)
    if not os.path.isdir(base):
        return 0, []
    el, mi = 0, 0
    for f in os.listdir(base):
        m = re.match(r'(\d{3})-', f)
        if f.endswith('.md') and m:
            try:
                os.path.getmtime(os.path.join(base, f))
            except FileNotFoundError:
                pass  # fantasma NTFS
            v = int(m.group(1))
            mio = YO in f.lower()
            if mio:
                mi = max(mi, v)
            else:
                el = max(el, v)
    pend = []
    if el > mi:
        for f in sorted(os.listdir(base)):
            m = re.match(r'(\d{3})-', f)
            if f.endswith('.md') and m and not (YO in f.lower()) and mi < int(m.group(1)) <= el:
                pend.append((int(m.group(1)), f))
    return el, pend

resumen = []
for canal in sorted(os.listdir(BASE)):
    if canal in EXCL:
        continue
    el, pend = pendientes_de_canal(canal)
    if not pend:
        continue
    base = os.path.join(BASE, canal)
    # leer el ultimo pendiente (mas reciente por fecha en el nombre)
    pend.sort()
    ultimo_f = pend[-1][1]
    p = os.path.join(base, ultimo_f)
    t = io.open(p, encoding='utf-8-sig', errors='replace').read()
    resumen.append('== %s | pendiente(s): %d == ' % (canal, len(pend)) + chr(10) + t[:800] + chr(10))

# imprimir el contenido de cada pendiente para el rati
for r in resumen:
    print(r)

print('=== CANALES CON PENDIENTES LISTADOS ===')
