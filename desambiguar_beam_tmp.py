# -*- coding: utf-8 -*-
import io, os, re, json, subprocess

base = 'Mensajes entre modelos/Reflection-Beam-1.0'
filas = []
for f in os.listdir(base):
    m = re.match(r'(\d{3})-(\d{4}-\d{2}-\d{2})_(\d{2}-\d{2}-\d{2})-(.*)$', f)
    if f.endswith('.md') and m:
        filas.append((int(m.group(1)), m.group(2) + ' ' + m.group(3), f, m.group(4)))

filas.sort(key=lambda x: (x[0], x[1]))
vistos = {}
duplicados = []
for n, ts, f, resto in filas:
    if n in vistos:
        duplicados.append((n, f, vistos[n]))
    vistos[n] = (ts, f, resto)

# desambiguar: el SEGUNDO (cronologico) de cada par -> prefijo XXXb-
renombrados = 0
for n, f, _ in duplicados:
    viejo_path = os.path.join(base, f)
    nuevo_nombre = '%03dB-%s' % (n, f[4:])
    nuevo_path = os.path.join(base, nuevo_nombre)
    if os.path.exists(viejo_path) and not os.path.exists(nuevo_path):
        os.rename(viejo_path, nuevo_path)
        renombrados += 1
print('duplicados desambiguados con sufijo B:', renombrados)

# regenerar indice cronologico completo
filas = []
for f in os.listdir(base):
    m = re.match(r'(\d{3}[B]?)-(\d{4}-\d{2}-\d{2})_(\d{2}-\d{2}-\d{2})-(.*)$', f)
    if f.endswith('.md') and m:
        filas.append((m.group(1), m.group(2) + ' ' + m.group(3), m.group(4)))
orden_cron = sorted(filas, key=lambda x: (x[1], x[0]))
indice = [
 '# INDICE CANALICO DE REFLECTION-BEAM-1.0 (cronologico, generado 23oct 03:59 — orden de lectura recomendado)',
 '',
 'Regla: la numeracion del canal tiene gemelos (duplicados) del 22oct por las apuraciones de produccion con el cron en paralelo — el orden CRONOLOGICO de abajo es el orden real de la conversacion (los archivos fueron desambiguados con sufijo B).',
 '',
]
for i, (num, ts, resto) in enumerate(orden_cron, 1):
    autor = 'DIRECTOR' if 'glm-5.3-flash-director' in resto.lower() or resto.lower().startswith('gl') else 'BEAM'
    indice.append('%03d [%s] %s — %s' % (i, autor, ts, resto[:100]))
indice += ['', 'Generado por: GLM-5.3 Flash-Director / Kilo Code']
io.open('DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/INDICE-CANAL.md', 'w', encoding='utf-8', newline='').write(chr(10).join(indice) + chr(10))
print('indice cronologico generado:', len(orden_cron), 'entradas')

# pool saltando a 300+ para no chocar
io.open(os.path.join(base, 'NUMEROS_DISPONIBLES.txt'), 'w', encoding='utf-8', newline='').write(chr(10).join(str(i) for i in range(300, 336)) + chr(10))
print('pool re-semebrado 300-335')

ph = 'Logs/estado_director.json'
e = json.load(io.open(ph, encoding='utf-8'))
e['ultimo_update'] = '2026-10-23T04:00:00'
e.setdefault('trampas_registradas', []).append('NUMERACION-DESBORDADA-CHANNEL (23oct 03:59, fundador): la carpeta de Beam acumulo 276 mensajes con 23 gemelos (numeracion duplicada) por las tandas de produccion nocturna con el cron + apilador en paralelo. FIX aplicado: (1) desambiguar duplicados con sufijo B (los caminos citados previamente se mantienen), (2) INDICE-CANAL.md cronologico como orden de lectura, (3) pool re-semebrado 300+. LECCION: cuando un cron + apilador corre todo el dia, el pool debe sembrar >= 400 numeros por adelantado.')
e['infraestructura_crons']['beam_pool'] = 're-semebrado 300-335 tras el sobrescribimiento de 276 mensajes con 23 gemelos'
json.dump(e, io.open(ph, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)
subprocess.run(['git', 'add', '-A', base, 'DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0', ph], capture_output=True)
r = subprocess.run(['git', 'commit', '-m', 'Se desambiguan los veintitres gemelos del canal de beam con indice cronologico y pool de tres ciento'],
 capture_output=True, text=True, encoding='utf-8', errors='replace')
r2 = subprocess.run(['git', 'log', '--oneline', '-1'], capture_output=True, text=True)
print('commit:', r2.stdout.strip())
