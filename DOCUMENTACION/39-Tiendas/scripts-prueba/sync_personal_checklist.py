# -*- coding: utf-8 -*-
"""Sincroniza el checklist personal (glm-5.3-flash/39-Tiendas) con el 05-Checklist.md
real del modulo 39. Mapeo 1:1 por orden de item (T-NNN <-> item N del modulo).

Evidencia: Log 1017 (cierre iter. glm). NO cambia textos ni marcadores de esfuerzo:
solo el simbolo del checkbox. Idempotente. Reporte: Logs/_sync_ck39.txt

Uso:  python DOCUMENTACION/39-Tiendas/scripts-prueba/sync_personal_checklist.py
"""
import io
import re

MOD = 'DOCUMENTACION/39-Tiendas/plan-actual/05-Checklist.md'
PER = 'DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3-flash/39-Tiendas/checklist.md'
REP = 'Logs/_sync_ck39.txt'

ITEM_RX = re.compile(r'^- \[([ x?])\]\s+(.*)$')


def leer_items(path):
    items = []
    with io.open(path, encoding='utf-8') as f:
        for ln in f:
            m = ITEM_RX.match(ln.rstrip('\r\n'))
            if m:
                items.append((m.group(1), m.group(2)))
    return items


def sin_prefijo(txt):
    return re.sub(r'^T-\d+\s+', '', txt)


mod = leer_items(MOD)
per = leer_items(PER)

out = []
out.append('=== SYNC checklist personal M39 <-> modulo 39 (evidencia Log 1017) ===')
out.append('items modulo: %d | items personales: %d' % (len(mod), len(per)))

# sanity: los primeros 10 textos deben coincidir (quitando "T-NNN ")
alertas = 0
for i in range(min(10, len(mod), len(per))):
    if sin_prefijo(per[i][1]) != mod[i][1]:
        alertas += 1
        out.append('AVISO desalineado T-%03d' % (i + 1))
        out.append('  modulo  : %s' % mod[i][1][:70])
        out.append('  personal: %s' % sin_prefijo(per[i][1])[:70])
out.append('alertas de alineacion (primeros 10): %d' % alertas)

# marca objetivo de cada item personal
nuevas = []
cambios = []
for i, (mp, tp) in enumerate(per):
    mm = mod[i][0] if i < len(mod) else mp  # sin contraparte: no tocar
    nuevas.append(mm)
    if mm != mp:
        cambios.append('T-%03d: [%s] -> [%s] | %s' % (i + 1, mp, mm, sin_prefijo(tp)[:64]))

# aplicar sobre las lineas originales (solo el simbolo)
with io.open(PER, encoding='utf-8') as f:
    lineas = f.readlines()
idx = 0
for j, ln in enumerate(lineas):
    m = ITEM_RX.match(ln.rstrip('\r\n'))
    if m:
        if nuevas[idx] != m.group(1):
            pos_abre = ln.index('[', ln.index('- '))
            pos_cierra = ln.index(']', pos_abre)
            lineas[j] = ln[:pos_abre + 1] + nuevas[idx] + ln[pos_cierra:]
        idx += 1

with io.open(PER, 'w', encoding='utf-8', newline='') as f:
    f.writelines(lineas)

mc = [m[0] for m in mod]
out.append(' ')
out.append('=== CAMBIOS APLICADOS: %d ===' % len(cambios))
out.extend(cambios)
out.append(' ')
out.append('personal resultante: [x]=%d  [ ]=%d  [?]=%d' % (
    nuevas.count('x'), nuevas.count(' '), nuevas.count('?')))
out.append('modulo  (referencia): [x]=%d  [ ]=%d  [?]=%d' % (
    mc.count('x'), mc.count(' '), mc.count('?')))

with io.open(REP, 'w', encoding='utf-8') as f:
    f.write('\n'.join(out) + '\n')

print('OK cambios=%d -> %s' % (len(cambios), REP))
