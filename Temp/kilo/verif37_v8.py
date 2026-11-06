#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# verif37_v8.py — verificar que las 37 FORMULA-C estan en A2 con el detector v8.
import sys, os
sys.path.insert(0, os.path.abspath('scripts'))
import detectar_autocontradiccion as det

buckets, tot_x, formula_ok, gris, promovidos, n = det.escanear('DOCUMENTACION')
a2 = set((m, l) for m, l, _ in buckets['A2'])

LISTA_37 = {
    '34-Pesca': [47, 111, 134, 179, 184, 199],
    '31-Ciclo-Dia-Noche': [46, 49, 55, 57, 58, 83, 84, 85, 118, 133, 134, 135, 141, 142, 150, 153, 223, 224, 225, 226],
    '27-Islas-Del-Mundo': [77, 92, 93, 94, 98, 136, 202, 221],
    '156-Terrenos-Y-Movimiento': [247, 270, 354],
}
ok = 0
fallas = []
for mod, lines in LISTA_37.items():
    for ln in lines:
        if (mod, ln) in a2:
            ok += 1
        else:
            fallas.append((mod, ln))
print(f'FORMULA-C verificacion v8: {ok}/37 en bucket A2')
for f in fallas:
    print('  FALLA (no esta en A2):', f)
print(f'promovidos_vecinos v8: {promovidos} | checklists: {n} | items [x]: {tot_x}')
m157 = sorted(l for m, l, s in buckets['A2'] if m == '157-Medios-De-Transporte')
print('M157 lineas en A2 v8:', m157)
m31 = sorted(l for m, l, s in buckets['A2'] if m == '31-Ciclo-Dia-Noche')
print('M31 lineas en A2 v8 (%d):' % len(m31), m31)
m34 = sorted(l for m, l, s in buckets['A2'] if m == '34-Pesca')
print('M34 lineas en A2 v8 (%d):' % len(m34), m34)
m27 = sorted(l for m, l, s in buckets['A2'] if m == '27-Islas-Del-Mundo')
print('M27 lineas en A2 v8 (%d):' % len(m27), m27)
m156 = sorted(l for m, l, s in buckets['A2'] if m == '156-Terrenos-Y-Movimiento')
print('M156 lineas en A2 v8 (%d):' % len(m156), m156)
