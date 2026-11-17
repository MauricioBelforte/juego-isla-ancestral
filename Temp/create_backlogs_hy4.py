import os, re, io

backlog_dir = 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS'
os.makedirs(backlog_dir, exist_ok=True)

# === BACKLOG 12: UTF-8 encoding verification ===
md_files = []
gd_files = []
for root, dirs, files in os.walk('DOCUMENTACION'):
    for f in files:
        if f.endswith('.md'):
            md_files.append(os.path.join(root, f))
for root, dirs, files in os.walk('game/isla-ancestral/scripts'):
    for f in files:
        if f.endswith('.gd'):
            gd_files.append(os.path.join(root, f))

total_files = len(md_files) + len(gd_files)
batch_size = 20
num_batches = (total_files + batch_size - 1) // batch_size

lines = []
lines.append('# 12-Backlog: Verificacion UTF-8 (BOM/mojibake) en %d archivos' % total_files)
lines.append('')
lines.append('> Creada por: agnes-3-flash - 2026-11-17 07:55')
lines.append('> Metodo: python -X utf8 -c "import io; b=open(\'RUTA\',\'rb\').read(); assert b[:3]!=b\'\xef\xbb\xbf\'; b.decode(\'utf-8\')"')
lines.append('> Si falla: anotar archivo + tipo de error (BOM / mojibake / binary).')
lines.append('> Batches de %d archivos por tarea.' % batch_size)
lines.append('')
lines.append('## Tareas')
lines.append('')
all_files = sorted(md_files + gd_files)
for i in range(num_batches):
    batch = all_files[i*batch_size:(i+1)*batch_size]
    sample = batch[0].replace('DOCUMENTACION/', 'DOC/').replace('game/isla-ancestral/scripts/', 'SCR/')
    lines.append('- [ ] T12-%02d: Batch %d-%d (%d archivos) - desde: %s' % (i+1, i*batch_size+1, min((i+1)*batch_size, total_files), len(batch), sample[:60]))
lines.append('')
with io.open(os.path.join(backlog_dir, '12-Backlog-UTF8-Encoding.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 12: %d tareas (%d archivos en %d batches)' % (num_batches, total_files, num_batches))

# === BACKLOG 13: Test + Scene integrity ===
test_files = []
for root, dirs, files in os.walk('game/isla-ancestral/tests'):
    for f in files:
        if f.endswith('.gd'):
            test_files.append(os.path.join(root, f))

scene_files = []
for root, dirs, files in os.walk('game/isla-ancestral/scenes'):
    for f in files:
        if f.endswith('.tscn'):
            scene_files.append(os.path.join(root, f))

lines = []
lines.append('# 13-Backlog: Test + Scene integrity (%d tests, %d scenes)' % (len(test_files), len(scene_files)))
lines.append('')
lines.append('> Creada por: agnes-3-flash - 2026-11-17 07:55')
lines.append('')
lines.append('## Tests: verificar que cada .gd en tests/ referencia un modulo valido')
lines.append('')
for i, tf in enumerate(sorted(test_files), 1):
    short = tf.replace('game/isla-ancestral/tests/', '')
    lines.append('- [ ] T13-%02d: test %s - referencia M___ ?' % (i, short))
lines.append('')
lines.append('## Scenes: verificar que cada .tscn existe y no esta huerafo')
lines.append('')
for i, sf in enumerate(sorted(scene_files), 1):
    short = sf.replace('game/isla-ancestral/scenes/', '')
    lines.append('- [ ] T13-%02d+S: scene %s - referenciada en docs ?' % (i, short))
with io.open(os.path.join(backlog_dir, '13-Backlog-Test-Scene-Integrity.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 13: %d tareas' % (len(test_files) + len(scene_files)))

# === BACKLOG 14: Asset + Data orphan detection ===
asset_count = 0
for root, dirs, files in os.walk('game/isla-ancestral/assets'):
    asset_count += len(files)
data_count = 0
for root, dirs, files in os.walk('game/isla-ancestral/data'):
    data_count += len(files)

lines = []
lines.append('# 14-Backlog: Asset + Data orphan detection')
lines.append('')
lines.append('> Creada por: agnes-3-flash - 2026-11-17 07:55')
lines.append('> %d assets, %d data files. Verificar que esten referenciados.' % (asset_count, data_count))
lines.append('> Metodo: grep -rlf "NOMBRE_ARCHIVO" game/ DOCUMENTACION/ | si 0 hits = orphan')
lines.append('> Batches de 20.')
lines.append('')
lines.append('## Tareas')
lines.append('')
batch = 20
total = asset_count + data_count
for i in range(max(1, (total + batch - 1) // batch)):
    lines.append('- [ ] T14-%02d: Batch %d-%d - verificar referencias' % (i+1, i*batch+1, min((i+1)*batch, total)))
lines.append('')
with io.open(os.path.join(backlog_dir, '14-Backlog-Asset-Data-Orphans.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 14: %d tareas' % max(1, (total + batch - 1) // batch))

# === BACKLOG 15: Log integrity ===
log_count = 0
for root, dirs, files in os.walk('Logs'):
    if 'rotated' not in root:
        log_count += len([f for f in files if f.endswith('.md')])

lines = []
lines.append('# 15-Backlog: Log integrity (%d logs no-rotados)' % log_count)
lines.append('')
lines.append('> Creada por: agnes-3-flash - 2026-11-17 07:55')
lines.append('> Verificar: Modelo, Plataforma, Fecha presentes. Secuencia numerica sin huecos >3.')
lines.append('> Batches de 20.')
lines.append('')
lines.append('## Tareas')
lines.append('')
batch = 20
for i in range(max(1, (log_count + batch - 1) // batch)):
    lines.append('- [ ] T15-%02d: Batch %d-%d - verificar firmas + secuencia' % (i+1, i*batch+1, min((i+1)*batch, log_count)))
lines.append('')
with io.open(os.path.join(backlog_dir, '15-Backlog-Log-Integrity.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 15: %d tareas' % max(1, (log_count + batch - 1) // batch))

# === BACKLOG 16: Cross-reference + Signature ===
lines = []
lines.append('# 16-Backlog: Cross-referencias + Firmas')
lines.append('')
lines.append('> Creada por: agnes-3-flash - 2026-11-17 07:55')
lines.append('> Verificar que las referencias a archivos en DOCUMENTACION/ resuelven.')
lines.append('> Verificar que los docs de plan-actual/ tienen firma Modelo/Plataforma/Fecha.')
lines.append('')
lines.append('## Cross-referencias (50 tareas)')
lines.append('')
for i in range(1, 51):
    lines.append('- [ ] T16-%02d: Verificar referencias en DOCUMENTACION/ batch %d' % (i, i))
lines.append('')
lines.append('## Firmas (50 tareas)')
lines.append('')
for i in range(51, 101):
    lines.append('- [ ] T16-%02d: Verificar firma en DOCUMENTACION/plan-actual/ batch %d' % (i, i-50))
lines.append('')
with io.open(os.path.join(backlog_dir, '16-Backlog-CrossRef-Firmas.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 16: 100 tareas')

# === BACKLOG 17: CHECKLIST-GLOBAL estado vs progreso ===
with io.open('CHECKLIST-GLOBAL.md', encoding='utf-8') as f:
    cg_content = f.read()
cg_lines = [l for l in cg_content.splitlines() if l.startswith('|') and '/' in l and '|' in l[2:]]
num_modules_cg = len(cg_lines)

lines = []
lines.append('# 17-Backlog: CHECKLIST-GLOBAL estado vs progreso (%d filas)' % num_modules_cg)
lines.append('')
lines.append('> Creada por: agnes-3-flash - 2026-11-17 07:55')
lines.append('> Verificar: si Progreso = X/X y Estado != [x] Completado -> inconsistency.')
lines.append('> Verificar: si Estado = [x] pero hay [?] en el checklist -> falso verde.')
lines.append('> Batches de 20.')
lines.append('')
lines.append('## Tareas')
lines.append('')
batch = 20
for i in range(max(1, (num_modules_cg + batch - 1) // batch)):
    lines.append('- [ ] T17-%02d: Batch %d-%d - estado vs progreso' % (i+1, i*batch+1, min((i+1)*batch, num_modules_cg)))
lines.append('')
with io.open(os.path.join(backlog_dir, '17-Backlog-CHECKLIST-GLOBAL-Consistencia.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 17: %d tareas' % max(1, (num_modules_cg + batch - 1) // batch))

# === Update BACKLOG-MASTER ===
master = os.path.join(backlog_dir, 'BACKLOG-MASTER.md')
with io.open(master, encoding='utf-8') as f:
    content = f.read()
content += '\n- 09-Backlog-GLOBAL-M41.md (129 tareas)\n'
content += '- 10-Backlog-Completitud-Modulos.md (5 tareas)\n'
content += '- 11-Backlog-Triage-BUGS.md (152 tareas)\n'
content += '- 12-Backlog-UTF8-Encoding.md (%d tareas)\n' % num_batches
content += '- 13-Backlog-Test-Scene-Integrity.md (%d tareas)\n' % (len(test_files) + len(scene_files))
content += '- 14-Backlog-Asset-Data-Orphans.md (%d tareas)\n' % max(1, (asset_count + data_count + 19) // 20)
content += '- 15-Backlog-Log-Integrity.md (%d tareas)\n' % max(1, (log_count + 19) // 20)
content += '- 16-Backlog-CrossRef-Firmas.md (100 tareas)\n'
content += '- 17-Backlog-CHECKLIST-GLOBAL-Consistencia.md (%d tareas)\n' % max(1, (num_modules_cg + 19) // 20)
with io.open(master, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

total_tasks = 129 + 5 + 152 + num_batches + len(test_files) + len(scene_files) + max(1, (asset_count + data_count + 19) // 20) + max(1, (log_count + 19) // 20) + 100 + max(1, (num_modules_cg + 19) // 20)
print('TOTAL NUEVAS: %d tareas (backlogs 09-17)' % total_tasks)
