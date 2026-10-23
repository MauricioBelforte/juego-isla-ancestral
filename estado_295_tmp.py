# -*- coding: utf-8 -*-
import io, os, json, subprocess

BB = 'Mensajes entre modelos/Reflection-Beam-1.0/'
ph = 'Logs/estado_director.json'

e = json.load(io.open(ph, encoding='utf-8'))
e['ultimo_update'] = '2026-10-23T03:46:00'
e['reflection_beam_1_0'].update({'cron_activo': 'cada 12-min wku_16789f1c001suEFXhgcQ8QkQ0 (prompt canon completo PASO 0/1/1.5)', 'acuse_enviado': 295, 'estado': e['reflection_beam_1_0'].get('estado', '') + ' | jornada TOTAL LACRADA (295: cron 12-min activo registrado; en espera del precio Coleccionista del fundador)'})
json.dump(e, io.open(ph, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)
print('estado OK')

subprocess.run(['git', 'add', '-A', BB, ph], capture_output=True)
r = subprocess.run(['git', 'commit', '-m', 'Se registra el cron de doce minutos de beam y se lacra su jornada'],
 capture_output=True, text=True, encoding='utf-8', errors='replace')
r2 = subprocess.run(['git', 'log', '--oneline', '-1'], capture_output=True, text=True)
print('commit:', r2.stdout.strip())
