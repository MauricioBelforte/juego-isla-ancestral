# -*- coding: utf-8 -*-
import io, json, subprocess

ph = 'Logs/estado_director.json'
e = json.load(io.open(ph, encoding='utf-8'))
e['ultimo_update'] = '2026-10-23T02:12:00'
e['apilador_beam_ultimo'] = '236 (apilado x30 #2: auditoria numerica de los 6 modulos sellados por agnes - 5 audits x modulo; regla anti-spam REDEFINIDA: reapilar cuando Beam DECLARA bloque completado - su declaracion vale, no mi lectura)'
e.setdefault('trampas_registradas', []).append('MAL-JUICIO ANTI-SPAM (23oct 02:06, autocritica): el CRON E decidio no reapilar basandose en MI lectura equivocada del 231/235 (dije sigue-bloque-2-en-ejecucion cuando Beam ya habia COMPLETADO en 230 y pedia mas). REGLA NUEVA: la declaracion de completado del AGENTE manda; mi interpretacion posterior no bloquea reapilados')
e['reflection_beam_1_0'].update({'apilado_ultimo': 236})
json.dump(e, io.open(ph, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)
print('estado OK')

subprocess.run(['git', 'add', '-A', 'Mensajes entre modelos/Reflection-Beam-1.0', ph], capture_output=True)
r = subprocess.run(['git', 'commit', '-m', 'Se emite el apilado x30 dos y queda redefinida la regla anti spam por declaracion del agente'],
 capture_output=True, text=True, encoding='utf-8', errors='replace')
r2 = subprocess.run(['git', 'log', '--oneline', '-1'], capture_output=True, text=True)
print('commit:', r2.stdout.strip())
