import os, re, io

backlog_dir = 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS'
base_doc = 'DOCUMENTACION'
game = 'game/isla-ancestral'

# === BACKLOG 23: Visual QA remaining (400 screenshots in batches of 5 = 80 tasks) ===
cap_dir = 'tools/mcp/godot-mcp/capturas'
cap_mods = []
for d in sorted(os.listdir(cap_dir)):
    if os.path.isdir(os.path.join(cap_dir, d)):
        files = sorted([f for f in os.listdir(os.path.join(cap_dir, d)) if f.endswith('.png')])
        if files:
            cap_mods.append((d, files))
# Skip first 12 (already done in trial 18)
remaining = cap_mods[12:]
total_remaining_caps = sum(len(f) for _, f in remaining)
batch = 5
num_tasks = (total_remaining_caps + batch - 1) // batch

lines = ['# 23-Backlog: Visual QA restante (%d capturas, %d batches)' % (total_remaining_caps, num_tasks),
'',
'> Creada por: agnes-3-flash - 2026-11-18 01:58',
'> Nicho: Visual QA (permanente, aprobado 17nov)',
'> Los 60 primeros ya se hicieron en la prueba 18. Estos son los restantes.',
'']
lines.append('## Tareas')
lines.append('')
task = 0
for mod, files in remaining:
    for i in range(0, len(files), batch):
        task += 1
        chunk = files[i:i+batch]
        lines.append('- [ ] T23-%02d: %s / %s ... %s (%d caps)' % (task, mod, chunk[0], chunk[-1], len(chunk)))
lines.append('')
with io.open(os.path.join(backlog_dir, '23-Backlog-Visual-QA-Remaining.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 23: %d tareas (%d capturas restantes)' % (task, total_remaining_caps))

# === BACKLOG 24: Bug root-cause remaining (122 bugs) ===
with io.open(os.path.join(base_doc, '11-BUGS.md'), encoding='utf-8') as f:
    bugs_content = f.read()
all_bug_ids = sorted(set(re.findall(r'BUG-(\d+)', bugs_content)), key=int)
# First 30 done in trial 20, remaining = rest
remaining_bugs = [b for b in all_bug_ids if int(b) > 153 or int(b) not in range(1, 31)]
# Actually just take bugs not in the first 30 we did (BUG-001 to BUG-030 range)
# Simpler: all 152 minus the 30 we already did = 122
done_set = set(all_bug_ids[:30])
remaining_bugs = [b for b in all_bug_ids if b not in done_set]

lines = ['# 24-Backlog: Bug Root-Cause restante (%d bugs)' % len(remaining_bugs),
'',
'> Creada por: agnes-3-flash - 2026-11-18 01:58',
'> Nicho: Bug root-cause (permanente, aprobado 17nov)',
'> Los primeros 30 ya se hicieron en la prueba 20. Estos son los restantes.',
'']
lines.append('## Metodo')
lines.append('')
lines.append('Para cada BUG-XXX:')
lines.append('1. Leer la entrada en 11-BUGS.md (estado, pasos repro, evidencia)')
lines.append('2. Grep del componente/script en game/isla-ancestral/')
lines.append('3. Leer max 200 lineas del archivo relevante')
lines.append('4. Anotar: BUG-ID / CAUSA PROBABLE (1-2 lineas) / ARCHIVO:LINEA / CONFIDENCIA')
lines.append('')
lines.append('## Tareas')
lines.append('')
for i, bug in enumerate(remaining_bugs, 1):
    lines.append('- [ ] T24-%02d: BUG-%s - diagnosticar causa' % (i, bug))
lines.append('')
with io.open(os.path.join(backlog_dir, '24-Backlog-Bug-RootCause-Remaining.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 24: %d tareas (%d bugs restantes)' % (len(remaining_bugs), len(remaining_bugs)))

# === BACKLOG 25: Cross-doc expanded (24 more groups of 5) ===
all_mods = []
for d in sorted(os.listdir(base_doc)):
    m = re.match(r'^(\d{2,3})-', d)
    if m:
        all_mods.append((m.group(1), d))
# First 10 groups done (50 modules), remaining = 120 modules = 24 groups of 5
remaining_mods = all_mods[50:]
groups = [remaining_mods[i:i+5] for i in range(0, len(remaining_mods), 5)]

lines = ['# 25-Backlog: Cross-Doc Expandido (%d grupos de 5)' % len(groups),
'',
'> Creada por: agnes-3-flash - 2026-11-18 01:58',
'> Nicho: Cross-doc (permanente, aprobado 17nov)',
'> Los primeros 10 grupos (50 modulos) ya se hicieron en la prueba 19.',
'']
lines.append('## Tareas')
lines.append('')
for i, grp in enumerate(groups, 1):
    names = ' + '.join(['M%s' % g[0] for g in grp])
    lines.append('- [ ] T25-%02d: %s - buscar contradicciones' % (i, names))
lines.append('')
with io.open(os.path.join(backlog_dir, '25-Backlog-CrossDoc-Expandido.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 25: %d tareas (%d grupos)' % (len(groups), len(groups)))

# === BACKLOG 26: Orphan script detection (1264 scripts in batches of 20 = 64 tasks) ===
script_files = []
for root, dirs, files in os.walk(os.path.join(game, 'scripts')):
    for f in sorted(files):
        if f.endswith('.gd'):
            script_files.append(os.path.join(root, f))
batch = 20
num_tasks = (len(script_files) + batch - 1) // batch

lines = ['# 26-Backlog: Orphan Script Detection (%d scripts, %d batches)' % (len(script_files), num_tasks),
'',
'> Creada por: agnes-3-flash - 2026-11-18 01:58',
'> Nicho: Volumen/limpieza (permanente)',
'']
lines.append('## Metodo')
lines.append('')
lines.append('Para cada batch de 20 scripts:')
lines.append('1. Grep -rlf "NOMBRE_SCRIPT" game/ DOCUMENTACION/ Mensajes/')
lines.append('2. Si 0 hits en DOCUMENTACION/ = ORPHAN (no documentado)')
lines.append('3. Anotar: SCRIPT / REFERENCIADO? (si/no) / DONDE')
lines.append('')
lines.append('## Tareas')
lines.append('')
for i in range(num_tasks):
    chunk = script_files[i*batch:(i+1)*batch]
    lines.append('- [ ] T26-%02d: Batch %d-%d - %s ... %s' % (i+1, i*batch+1, min((i+1)*batch, len(script_files)), os.path.basename(chunk[0]), os.path.basename(chunk[-1])))
lines.append('')
with io.open(os.path.join(backlog_dir, '26-Backlog-Orphan-Scripts.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 26: %d tareas (%d scripts)' % (num_tasks, len(script_files)))

# === BACKLOG 27: Data file validity (552 JSON in batches of 20 = 28 tasks) ===
data_files = []
for root, dirs, files in os.walk(os.path.join(game, 'data')):
    for f in sorted(files):
        if f.endswith('.json'):
            data_files.append(os.path.join(root, f))
batch = 20
num_tasks = (len(data_files) + batch - 1) // batch

lines = ['# 27-Backlog: Data File Validity (%d JSON, %d batches)' % (len(data_files), num_tasks),
'',
'> Creada por: agnes-3-flash - 2026-11-18 01:58',
'> Nicho: Volumen/verificacion (permanente)',
'']
lines.append('## Metodo')
lines.append('')
lines.append('Para cada batch de 20 JSON:')
lines.append('1. python -c "import json; json.load(open(\'RUTA\'))" - si falla = INVALIDO')
lines.append('2. Verificar que tiene al menos una clave raiz')
lines.append('3. Anotar: ARCHIVO / VALIDO? / N_CLAVES')
lines.append('')
lines.append('## Tareas')
lines.append('')
for i in range(num_tasks):
    chunk = data_files[i*batch:(i+1)*batch]
    lines.append('- [ ] T27-%02d: Batch %d-%d - %s' % (i+1, i*batch+1, min((i+1)*batch, len(data_files)), os.path.basename(chunk[0])))
lines.append('')
with io.open(os.path.join(backlog_dir, '27-Backlog-Data-Validity.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 27: %d tareas (%d JSON)' % (num_tasks, len(data_files)))

# === BACKLOG 28: Log integrity expanded (2345 logs in batches of 25 = 94 tasks) ===
log_files = []
for root, dirs, files in os.walk('Logs'):
    if 'rotated' not in root:
        for f in sorted(files):
            if f.endswith('.md') and f[0].isdigit():
                log_files.append(os.path.join(root, f))
batch = 25
num_tasks = (len(log_files) + batch - 1) // batch

lines = ['# 28-Backlog: Log Integrity Expandida (%d logs, %d batches)' % (len(log_files), num_tasks),
'',
'> Creada por: agnes-3-flash - 2026-11-18 01:58',
'> Nicho: Volumen/verificacion (permanente)',
'']
lines.append('## Metodo')
lines.append('')
lines.append('Para cada batch de 25 logs:')
lines.append('1. Verificar: **Modelo:** presente')
lines.append('2. Verificar: **Plataforma:** presente')
lines.append('3. Verificar: **Fecha:** AAAA-MM-DD presente')
lines.append('4. Si falta alguno: anotar LOG-ID + CAMPO_FALTANTE')
lines.append('')
lines.append('## Tareas')
lines.append('')
for i in range(num_tasks):
    chunk = log_files[i*batch:(i+1)*batch]
    lines.append('- [ ] T28-%02d: Batch %d-%d' % (i+1, i*batch+1, min((i+1)*batch, len(log_files))))
lines.append('')
with io.open(os.path.join(backlog_dir, '28-Backlog-Log-Integrity-Exp.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 28: %d tareas (%d logs)' % (num_tasks, len(log_files)))

# === BACKLOG 29: i18n deep (276 msgid entries - verify used in code) ===
lines = ['# 29-Backlog: i18n Deep - msgid orphans',
'',
'> Creada por: agnes-3-flash - 2026-11-18 01:58',
'> Nicho: i18n volumen (permanente, aprobado 17nov)',
'']
lines.append('## Metodo')
lines.append('')
lines.append('Para cada msgid en locales/es.po:')
lines.append('1. Grep -rF "CLAVE" game/isla-ancestral/scripts/')
lines.append('2. Si 0 hits = ORPHAN (traduccion sin uso)')
lines.append('3. Anotar: CLAVE / USADO? / DONDE')
lines.append('')
lines.append('## Tareas (276 msgid en batches de 12)')
lines.append('')
for i in range(23):
    lines.append('- [ ] T29-%02d: Batch %d-%d msgid' % (i+1, i*12+1, min((i+1)*12, 276)))
lines.append('')
with io.open(os.path.join(backlog_dir, '29-Backlog-I18N-Deep-Orphans.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 29: 23 tareas (276 msgid)')

# === BACKLOG 30: Scene + Shader verification ===
scene_files = []
for root, dirs, files in os.walk(os.path.join(game, 'scenes')):
    for f in sorted(files):
        if f.endswith('.tscn'):
            scene_files.append(os.path.join(root, f))
shader_files = []
for root, dirs, files in os.walk(os.path.join(game, 'shaders')):
    for f in sorted(files):
        shader_files.append(os.path.join(root, f))

lines = ['# 30-Backlog: Scene + Shader verification (%d scenes, %d shaders)' % (len(scene_files), len(shader_files)),
'',
'> Creada por: agnes-3-flash - 2026-11-18 01:58',
'> Nicho: Volumen/verificacion (permanente)',
'']
lines.append('## Scenes')
lines.append('')
for i, sf in enumerate(scene_files, 1):
    lines.append('- [ ] T30-S%02d: %s - verificar nodos + referencias validas' % (i, os.path.basename(sf)))
lines.append('')
lines.append('## Shaders')
lines.append('')
for i, sf in enumerate(shader_files, 1):
    lines.append('- [ ] T30-H%02d: %s - verificar sintaxis (no hay parser, solo visual)' % (i, os.path.basename(sf)))
lines.append('')
with io.open(os.path.join(backlog_dir, '30-Backlog-Scene-Shader.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 30: %d tareas (%d scenes + %d shaders)' % (len(scene_files) + len(shader_files), len(scene_files), len(shader_files)))

# === Update BACKLOG-MASTER ===
master = os.path.join(backlog_dir, 'BACKLOG-MASTER.md')
with io.open(master, encoding='utf-8') as f:
    content = f.read()
content += '\n## NUEVO (18nov - %d tareas adicionales)\n' % (task + len(remaining_bugs) + len(groups) + num_tasks + 28 + 94 + 23 + len(scene_files) + len(shader_files))
content += '- 23-Backlog-Visual-QA-Remaining.md (%d tareas)\n' % task
content += '- 24-Backlog-Bug-RootCause-Remaining.md (%d tareas)\n' % len(remaining_bugs)
content += '- 25-Backlog-CrossDoc-Expandido.md (%d tareas)\n' % len(groups)
content += '- 26-Backlog-Orphan-Scripts.md (%d tareas)\n' % num_tasks
content += '- 27-Backlog-Data-Validity.md (28 tareas)\n'
content += '- 28-Backlog-Log-Integrity-Exp.md (%d tareas)\n' % 94
content += '- 29-Backlog-I18N-Deep-Orphans.md (23 tareas)\n'
content += '- 30-Backlog-Scene-Shader.md (%d tareas)\n' % (len(scene_files) + len(shader_files))
with io.open(master, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

total_new = task + len(remaining_bugs) + len(groups) + num_tasks + 28 + 94 + 23 + len(scene_files) + len(shader_files)
print('TOTAL NUEVAS: %d tareas (backlogs 23-30)' % total_new)
