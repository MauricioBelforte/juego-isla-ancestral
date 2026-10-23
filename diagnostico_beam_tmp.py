# -*- coding: utf-8 -*-
import io, os, re

base = 'Mensajes entre modelos/Reflection-Beam-1.0'
filas = []
for f in os.listdir(base):
    m = re.match(r'(\d{3})-(\d{4}-\d{2}-\d{2})_(\d{2}-\d{2}-\d{2})-(.*)$', f)
    if f.endswith('.md') and m:
        filas.append((int(m.group(1)), m.group(2), m.group(3), m.group(4)))

filas.sort()
len_f = len(filas)
print('TOTAL mensajes:', len_f)
# detectar: numeros duplicados (gemelos), saltos, fuera de secuencia por fecha
vistos = {}
problemas = []
prev = 0
for n, fecha, hora, resto in filas:
    if n in vistos:
        problemas.append('DUPLICADO %d: %s vs %s' % (n, vistos[n][:60], resto[:60]))
    vistos[n] = resto
    if n < prev - 5:
        problemas.append('FUERA DE ORDEN %d (prev %d): %s' % (n, prev, resto[:60]))
    prev = n
for p in problemas[:20]:
    print(p)
print('total problemas detectados:', len(problemas))
