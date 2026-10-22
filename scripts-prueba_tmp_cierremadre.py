# -*- coding: utf-8 -*-
"""Estado actualizado con el cierre de la noche + commit de preservacion final."""
import io, json, subprocess

ph = 'Logs/estado_director.json'
e = json.load(io.open(ph, encoding='utf-8'))
e['ultimo_update'] = '2026-10-22T03:30:00'
e['reflection_beam_1_0'].update({'estado': 'T51/T52 (backlog M137 200-213 sync + extraccion/colocacion) ratificadas por acuse combinado 110; isla.tscn/VoxelTerrain/generador [ ] honestos de editor', 'acuse_enviado': 110})
e['agnes'].update({'estado': 'M73 en curso: lote 4 posible en vuelo (05 M marcado sin nuevo mensaje); proximo acuse pendiente de leer' , 'acuse_enviado': 933})
e['crons_vuelta_bd10'] = 'CRON B/D 03:30: acuse combinado 110 a Beam (T51+T52), estado persistente sincronizado, lote nocturno preservado; agnes M73 05 en vuelo para proximo ciclo'
json.dump(e, io.open(ph, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)
print('estado OK')

subprocess.run(['git', 'add', '-A'], capture_output=True)
subprocess.run(['git', 'reset', '-q', 'Logs/NUMEROS_DISPONIBLES.txt'], capture_output=True)
subprocess.run(['git', 'commit', '-m',
    'Se preserva el estado final de la noche y los ultimos cambios de agnes en M73 en vuelo',
    '-m',
    'El estado persistente queda actualizado con el acuse combinado 110 a Reflection Beam 1.0 (T51 T52 del prototipo M137 ratificadas) y la tanda de agnes en M73 queda en vuelo para el proximo ciclo de preservacion'], capture_output=True, text=True, encoding='utf-8', errors='replace')
r = subprocess.run(['git', 'log', '--oneline', '-1'], capture_output=True, text=True)
print('commit:', r.stdout.strip())
