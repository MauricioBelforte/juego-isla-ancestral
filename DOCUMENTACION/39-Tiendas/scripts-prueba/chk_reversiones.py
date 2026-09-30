# -*- coding: utf-8 -*-
"""Verifica las 4 reversiones [x]->[ ] aplicadas por sync_personal_checklist.py
(2026-09-19, glm-5.3-flash) contra el modulo 39, el checklist personal y la guia 08.

Salida: Logs/_chk_rev2.txt (y eco ASCII por consola)
"""
import io

MOD = 'DOCUMENTACION/39-Tiendas/plan-actual/05-Checklist.md'
PER = 'DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3-flash/39-Tiendas/checklist.md'
GLOB = 'CHECKLIST-GLOBAL.md'
G08 = 'DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md'

out = []


def grep(p, needles, label):
    L = io.open(p, encoding='utf-8').read().splitlines()
    for i, l in enumerate(L, 1):
        for n in needles:
            if n in l:
                out.append('%s L%d: %s' % (label, i, l.strip()[:180]))
                break


# Items reversionados: buscar su estado real en el modulo
grep(MOD, ['criterios de aceptaci', 'defaults de cat', 'Evento finalizado revierte',
           'precargados en _ready', 'pool_rodante', 'marcadores de esfuerzo'], 'MOD')
# Estado actual en el checklist personal
grep(PER, ['T-006', 'T-007', 'T-011', 'T-014', 'T-110', 'T-131'], 'PER')
# Fila de M39 en CHECKLIST-GLOBAL
grep(GLOB, ['| 39 '], 'GLOB')
# M39 en la guia 08 (fila rota + menciones)
L08 = io.open(G08, encoding='utf-8').read().splitlines()
for i, l in enumerate(L08, 1):
    if 'M39' in l or '39-Tiendas' in l:
        out.append('G08 L%d: %s' % (i, l.strip()[:180]))

txt = '\n'.join(out)
io.open('Logs/_chk_rev2.txt', 'w', encoding='utf-8').write(txt)
print(txt.encode('ascii', 'replace').decode('ascii'))
