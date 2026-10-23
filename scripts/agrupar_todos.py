# -*- coding: utf-8 -*-
"""AGRUPADOR DE TODOS LOS CANALES — usa la regla de centena completa.
Uso: python -X utf8 scripts/agrupar_todos.py"""
import os, subprocess

BASE = 'Mensajes entre modelos'
for canal in sorted(os.listdir(BASE)):
    cpath = os.path.join(BASE, canal)
    if not os.path.isdir(cpath):
        continue
    if canal.startswith('arch_'):
        continue
    # invoca el agrupador idempotente por canal
    r = subprocess.run(['python', '-X', 'utf8', 'scripts/agrupar_canal.py', cpath],
                       capture_output=True, text=True, encoding='utf-8', errors='replace')
    out = (r.stdout or '').strip().split(chr(10))
    for line in out:
        if line.startswith(('canal:', 'centena en curso', 'movidos', 'centenas archivadas')):
            print(' ', line)
