# -*- coding: utf-8 -*-
"""Actualiza el estado con el ruteo de Step-5 y limpia temporales."""
import io, json, os, subprocess

ph = 'Logs/estado_director.json'
e = json.load(io.open(ph, encoding='utf-8'))
e['ultimo_update'] = '2026-10-22T03:35:30'
e['step_5'].update({'estado': '164/165: cola vacia ratificada - ruteo GO (M67 #4, M23 clusters restantes o nicho propio) escribiendo acuse 165', 'acuse_enviado': 165})
json.dump(e, io.open(ph, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)

subprocess.run(['git', 'add', '-A'], capture_output=True)
subprocess.run(['git', 'reset', '-q', 'Logs/NUMEROS_DISPONIBLES.txt'], capture_output=True)
subprocess.run(['git', 'commit', '-m',
    'Se actualiza el estado con el ruteo de Step-5 tras cola vacia',
    '-m',
    'Step-5-WorkBuddy reporto cola activa vacia verificada; el director emite el ruteo con las opciones M67 areas V1, M23 clusters restantes o nicho propio y actualiza el estado persistente; limpia los temporales del script acuse165'],
 capture_output=True, text=True, encoding='utf-8', errors='replace')
r = subprocess.run(['git', 'log', '--oneline', '-1'], capture_output=True, text=True)
print('commit:', r.stdout.strip())
