# -*- coding: utf-8 -*-
import io, os, re, json, subprocess

base = 'Mensajes entre modelos/Reflection-Beam-1.0'

# === PASO 1: revertir los sufijos B (volver a nombres originales) ===
revertidos = 0
for f in os.listdir(base):
    m = re.match(r'(\d{3})B-(.*)$', f)
    if f.endswith('.md') and m and m.group(1) == 'nnn' or (f.endswith('.md') and re.search(r'\d{3}B-', f)):
        nvo = re.sub(r'(\d{3})B-', r'\1-', f)
        try:
            os.rename(os.path.join(base, f), os.path.join(base, nvo))
            revertidos += 1
        except OSError:
            # posible colision: mover a tmp primero
            tmp = os.path.join(base, 'tmp_' + f)
            os.rename(os.path.join(base, f), tmp)
            os.rename(tmp, os.path.join(base, nvo))
            revertidos += 1
print('revertidos -B:', revertidos)

# === PASO 2: listar todos con metadata, orden cronologico (fecha_hora + nombre como desempate) ===
filas = []
for f in os.listdir(base):
    m = re.match(r'(\d{3})-(\d{4}-\d{2}-\d{2})_(\d{2}-\d{2}-\d{2})-(.*)$', f)
    if f.endswith('.md') and m:
        filas.append((m.group(2) + ' ' + m.group(3), m.group(4), f, int(m.group(1))))
filas.sort()
print('total a renumerar:', len(filas))

# === PASO 3: mapping viejo -> nuevo y renombrado en 2 pasadas (tmp para evitar colisiones) ===
mapping = []
for i, (ts, resto, f, old) in enumerate(filas, 1):
    new = '%03d-%s_%s-%s' % (i, ts[0:10], ts[11:19], resto)
    mapping.append((f, new, old, resto))

# pasada 1: renombrar todo a tmp
for f, new, old, resto in mapping:
    os.rename(os.path.join(base, f), os.path.join(base, 'tmp__' + new))
# pasada 2: tmp -> nombre final
for f, new, old, resto in mapping:
    os.rename(os.path.join(base, 'tmp__' + new), os.path.join(base, new))

print('renumeracion secuencial 001-%03d completa' % len(filas))

# === PASO 4: INDICE-CANAL.md con el MAPPING viejo->nuevo ===
indice = [
 '# INDICE-CANAL DE REFLECTION-BEAM-1.0 (RENUMERACION SECUENCIAL 23oct 03:59 — misma estrategia que el canal DS-OC)',
 '',
 'Estrategia del fundador: reenumeracion secuencial por fecha cronologica real (001-%03d). Los mensajes ya citados en conversaciones por su numero VIEJO mapean con esta tabla (old -> new).',
 '' % len(filas),
 'MaPEO VIEJO -> NUEVO (por si una cita historica apunta al numero viejo):',
 '']
for old_num, new_num, ts, resto in [(m[1], i, m[0], m[3]) for i, m in enumerate(filas, 1)]:
    if str(old_num) != new_num[0:3]:
        indice.append('  %03d -> %03d | %s | %s' % (old_num, int(new_num[0:3]), ts, resto[:80]))
indice += ['', 'Los numeros sin fila en esta tabla NO cambiaron (numeros unicos ya correctos).',
           '', 'Pool re-semebrado: %03d+ (277+).' % (len(filas) + 1),
           '', 'Firma: GLM-5.3 Flash-Director / Kilo Code - 23oct 04:00']
io.open('DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/INDICE-CANAL.md', 'w', encoding='utf-8', newline='').write(chr(10).join(indice) + chr(10))
print('INDICE-CANAL con mapping escrito')

# === PASO 5: pool re-semebrado ===
io.open(os.path.join(base, 'NUMEROS_DISPONIBLES.txt'), 'w', encoding='utf-8', newline='').write(chr(10).join(str(i) for i in range(277, 317)) + chr(10))
print('pool re-semebrado 277-316')

# === PASO 6: estado + commit ===
ph = 'Logs/estado_director.json'
e = json.load(io.open(ph, encoding='utf-8'))
e['ultimo_update'] = '2026-10-23T04:00:30'
e['infraestructura_crons']['beam_pool'] = 'canal complitamente RENUMERADO secuencial 001-%03d (estrategia DS-OC: por fecha cronologica real); INDICE-CANAL.md con mapping viejo->nuevo; pool 277-316' % len(filas)
e.setdefault('trampas_registradas', []).append('RENUMERACION-SECUENCIAL-CANAL (23oct 03:59, el fundador corrige mi sufijo-B: la estrategia del proyecto es la del canal DS-OC — reenumeracion secuencial 001-N por fecha cronologica + INDICE-CANAL.md con mapping viejo->nuevo + pool rearmed. Los sufijos -B no son la estrategia del proyecto')
json.dump(e, io.open(ph, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)

subprocess.run(['git', 'add', '-A', base, 'DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0', ph], capture_output=True)
r = subprocess.run(['git', 'commit', '-m', 'Se reenumera todo el canal de beam secuencialmente por fecha con indice de mapeo viejo nuovo'], capture_output=True, text=True, encoding='utf-8', errors='replace')
r2 = subprocess.run(['git', 'log', '--oneline', '-1'], capture_output=True, text=True)
print('commit:', r2.stdout.strip())
