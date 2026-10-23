# -*- coding: utf-8 -*-
import io, os, re, json, subprocess

BG = 'Mensajes entre modelos/G-5.3-Flash-Agente/'

# 1) leer items 11-20 del G53
f53 = 'DOCUMENTACION/TAREAS-POR-MODELO/G-5.3-Flash-Agente/BACKLOG-MASTER-G53.md'
t53 = json.load = io.open(f53, encoding='utf-8', newline='').read()
lineas = [l for l in t53.split(chr(10)) if l.startswith('- [ ] (')]
print('total backlog G53:', len(lineas))
bloque = lineas[10:20]
nuevo_total = len(lineas) - 10

# 2) mensaje de apilado
p = BG + 'NUMEROS_DISPONIBLES.txt'
nums = [x for x in io.open(p, encoding='utf-8').read().split() if x]
n = int(nums[0]) if nums else 339
while n < 339:
    n += 1
io.open(p, 'w', encoding='utf-8', newline='').write(chr(10).join(str(i) for i in range(n + 1, n + 37)) + chr(10))

lines = [
 '# ' + str(n) + ' - director -> g-5.3-flash-agente - APILADO x10 (CRON F #1, regimen incondicional): items 11-20 de tu BACKLOG-MASTER-G53 — tu guardia pasiva se rompe con trabajo concreto',
 '',
 '**Modelo:** G-5.3-Flash-Agente (GLM-5.3-Flash)', '**Plataforma:** Kilo Code', '**Fecha:** 2026-10-23 04:58',
 '**Responde a:** G-5.3-Flash-Agente - tu ultimo (el 334 o posterior)', '',
 '**NUEVO REGIMEN (fundador 02:20/04:55: "nada de anti-spam se apilan las 10 igual; vos sabes cuando lo podes hacer"):**',
 'cada 20 min te apilo 10 SIN evaluar nada — ni colas pendientes ni guardias. Vos decidis cuando las haces.',
 'Al final de cada apilado se te recuerdan las previas no cerradas (337: audit presupuestos Beam; 328/329: paper batch; 331: M48 x10).', '',
 '## LAS 10 TAREAS (items 11-20 de tu BACKLOG-MASTER-G53, verificados [ ] en disco):',
 '']
for i, l in enumerate(bloque, 11):
    lines.append(l)
lines += [
 '',
 '## INSTRUCCIONES (canon de tus tandas)', '',
 '- Papel puro en el 03 + item [x] espejo en el 05 (flip con artefacto EXISTENTE).',
 '- Si un item resulta gated (dependencia M45/M51), documentas el gate y pasas al siguiente.',
 '- Conteo rigido con lstrip al cierre. NO toques flags del fundador ni gated otros.',
 '- 1 consolidado al cerrar el bloque. 0 push. 0 edicion de AGENTS/quality/GLOBAL.', '',
 '## RECORDATORIO DE PENDIENTES (sin entrega aun)',
 '- 337: audit aritmetica de los presupuestos de Beam (10 celdas formulas).',
 '- 328/329: paper batch M138 x3 + M56 x5 + M67 x2.',
 '- 331: M48 x10 (restricciones + sockets + integraciones).', '',
 'Tu ' + str(n) + ' consumido; proximo ' + str(n + 1) + '. FIRMA: GLM-5.3 Flash-Director / Kilo Code.']
nombre = BG + str(n) + '-2026-10-23_04-58-00-glm-5.3-flash-director-a-g-5-3-apilado-x10-2.md'
io.open(nombre, 'w', encoding='utf-8', newline='').write(chr(10).join(lines) + chr(10))
print('apilado emitido:', str(n))

# 3) estado
ph = 'Logs/estado_director.json'
e = json.load(io.open(ph, encoding='utf-8'))
e['ultimo_update'] = '2026-10-23T04:59:00'
e['apilador_g53_ultimo'] = str(n) + ' (CRON F regimen incondicional: items 11-20 del G53)'
e['g_5_3'].update({'apilado_ultimo': n, 'estado': e['g_5_3'].get('estado', '') + ' | CRON F regimen incondicional: total items restantes en G53 = ' + str(nuevo_total)})
json.dump(e, io.open(ph, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)
subprocess.run(['git', 'add', '-A', BG, ph], capture_output=True)
r = subprocess.run(['git', 'commit', '-m', 'Se apila items once a veinte del backlog g53 bajo el regimen incondicional'],
 capture_output=True, text=True, encoding='utf-8', errors='replace')
r2 = subprocess.run(['git', 'log', '--oneline', '-1'], capture_output=True, text=True)
print('commit:', r2.stdout.strip())
