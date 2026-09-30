# -*- coding: utf-8 -*-
"""Verifica la alineacion 1:1 del checklist personal (glm-5.3-flash/39-Tiendas)
contra el 05-Checklist.md del modulo 39. Compara el texto de cada item par
normalizado (sin prefijo T-NNN, sin marcador [S]/[M]/[C], sin sufijos *( ...)*).

Reporte: Logs/_verif_ali39.txt
Uso:  python DOCUMENTACION/39-Tiendas/scripts-prueba/verificar_alineacion_ck39.py
"""
import io
import re

MOD = 'DOCUMENTACION/39-Tiendas/plan-actual/05-Checklist.md'
PER = 'DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3-flash/39-Tiendas/checklist.md'
REP = 'Logs/_verif_ali39.txt'

ITEM_RX = re.compile(r'^- \[([ x?])\]\s+(.*)$')
ANOT_RX = re.compile(r'\s*\*\(.*?\)\*\s*$')
ESF_RX = re.compile(r'\s*\[[SMC]\]\s*$')


def norm(txt):
    t = re.sub(r'^T-\d+\s+', '', txt)
    t = ANOT_RX.sub('', t)
    t = ESF_RX.sub('', t)
    return t.strip()


def leer(path):
    items = []
    with io.open(path, encoding='utf-8') as f:
        for ln in f:
            m = ITEM_RX.match(ln.rstrip('\r\n'))
            if m:
                items.append((m.group(1), norm(m.group(2))))
    return items


mod = leer(MOD)
per = leer(PER)

out = []
out.append('=== VERIFICACION ALINEACION 1:1 checklist personal M39 <-> modulo 39 ===')
out.append('items modulo: %d | items personales: %d' % (len(mod), len(per)))

iguales = 0
distintos = []
for i, (ms, mt) in enumerate(per):
    if i >= len(mod):
        distintos.append((i + 1, mt, '(sin contraparte en modulo)'))
        continue
    mt_mod = mod[i][1]
    if mt == mt_mod:
        iguales += 1
    else:
        distintos.append((i + 1, mt, mt_mod))

out.append('coincidencias exactas: %d' % iguales)
out.append('discrepancias: %d' % len(distintos))
for (n, a, b) in distintos:
    out.append('T-%03d DISCREPANCIA' % n)
    out.append('   personal: %s' % a[:100])
    out.append('   modulo  : %s' % b[:100])

# conteo de simbolos
out.append('')
out.append('personal: [x]=%d [ ]=%d [?]=%d' % (
    sum(1 for s, _ in per if s == 'x'),
    sum(1 for s, _ in per if s == ' '),
    sum(1 for s, _ in per if s == '?')))
out.append('modulo  : [x]=%d [ ]=%d [?]=%d' % (
    sum(1 for s, _ in mod if s == 'x'),
    sum(1 for s, _ in mod if s == ' '),
    sum(1 for s, _ in mod if s == '?')))

with io.open(REP, 'w', encoding='utf-8') as f:
    f.write('\n'.join(out) + '\n')

print('OK discrepancias=%d -> %s' % (len(distintos), REP))
