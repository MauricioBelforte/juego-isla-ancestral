# -*- coding: utf-8 -*-
import io, os, re, time

# verificar los lotes restantes no commiteados: dânear y logs
pendientes = []
for rp in ('DATA', 'Logs', 'Mensajes entre modelos/DeepSeek-V4.1-Flash', 'Mensajes entre modelos/agnes-3-flash'):
    pass
r2 = subprocess.run(['git', 'status', '--short'], capture_output=True, text=True, encoding='utf-8', errors='replace')
resto = [l for l in r2.stdout.split(chr(10)) if l.strip()]
print('resto despues de preservar:', len(resto))
for l in resto[:12]: print(' ', l)
