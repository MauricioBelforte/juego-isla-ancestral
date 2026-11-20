import io, os, re

backlog_dir = 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS'
base = 'DOCUMENTACION'
game = 'game/isla-ancestral'

def write_backlog(name, title, tasks, header=''):
    lines = ['# %s' % name, '', '> Creada por: agnes-3-flash - 2026-11-20 07:52', title, '']
    if header:
        lines.append(header)
        lines.append('')
    lines.append('## Tareas')
    lines.append('')
    for t in tasks:
        lines.append(t)
    lines.append('')
    with io.open(os.path.join(backlog_dir, name), 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(lines) + '\n')
    print('%s: %d tareas' % (name.split('-')[0], len(tasks)))

# 41: Remaining [?] (344 in 68 modules)
top10 = {'75','156','74','73','94','71','27','159','49','11'}
q_mods = []
for d in sorted(os.listdir(base)):
    m = re.match(r'^(\d{2,3})-', d)
    if not m: continue
    mid = m.group(1)
    if mid in top10: continue
    checklist = os.path.join(base, d, 'plan-actual', '05-Checklist.md')
    if not os.path.isfile(checklist): continue
    with io.open(checklist, encoding='utf-8') as f:
        c = f.read()
    q = len(re.findall(r'^- \[?\]', c, re.MULTILINE))
    if q > 0:
        q_mods.append((mid, d, q))
q_mods.sort(key=lambda x: -x[2])

tasks41 = []
tnum = 0
for mid, modname, q in q_mods:
    for i in range(q):
        tnum += 1
        tasks41.append('- [ ] T41-%03d: M%s [?]-%d - diagnosticar' % (tnum, mid, i+1))
write_backlog('41-Backlog-RootCause-Q-Remaining.md', 'Bug Root-Cause [?] restantes (%d en %d modulos)' % (tnum, len(q_mods)), tasks41,
    'Metodo: para cada [?] en 05-Checklist: causa + archivo:linea + confianza. Max 30% [?] nuevo.')

# 42: .gd TODO/FIXME (1264 in batches of 20 = 64)
gd_files = []
for root, dirs, files in os.walk(os.path.join(game, 'scripts')):
    for f in sorted(files):
        if f.endswith('.gd'):
            gd_files.append(os.path.join(root, f))
tasks42 = []
for i in range((len(gd_files) + 19) // 20):
    chunk = gd_files[i*20:(i+1)*20]
    tasks42.append('- [ ] T42-%02d: Batch %d-%d - TODO/FIXME count' % (i+1, i*20+1, min((i+1)*20, len(gd_files))))
write_backlog('42-Backlog-GD-Script-TODO.md', 'GDScript TODO/FIXME scan (%d archivos)' % len(gd_files), tasks42,
    'Metodo: grep -c "TODO\\|FIXME" por archivo. Anotar: archivo + count. No fixear.')

# 43: .md signature (3021 in batches of 30 = 101)
md_files = []
for root, dirs, files in os.walk('DOCUMENTACION'):
    for f in sorted(files):
        if f.endswith('.md') and 'plan-inicial' not in root and 'OBSOLETOS' not in root:
            md_files.append(os.path.join(root, f))
tasks43 = []
for i in range((len(md_files) + 29) // 30):
    chunk = md_files[i*30:(i+1)*30]
    tasks43.append('- [ ] T43-%03d: Batch %d-%d - firma Modelo/Plataforma/Fecha' % (i+1, i*30+1, min((i+1)*30, len(md_files))))
write_backlog('43-Backlog-MD-Signature.md', 'Firma docs (%d archivos .md)' % len(md_files), tasks43,
    'Metodo: verificar **Modelo:**, **Plataforma:**, **Fecha:** presentes. Anotar falta. No corregir.')

# 44: .tscn node hierarchy (53)
tscn_files = []
for root, dirs, files in os.walk(os.path.join(game, 'scenes')):
    for f in sorted(files):
        if f.endswith('.tscn'):
            tscn_files.append(os.path.join(root, f))
tasks44 = []
for i, sf in enumerate(tscn_files, 1):
    tasks44.append('- [ ] T44-%02d: %s - contar nodos + verificar scripts' % (i, os.path.basename(sf)))
write_backlog('44-Backlog-TSCN-Nodes.md', 'Scene node hierarchy (%d escenas)' % len(tscn_files), tasks44,
    'Metodo: grep -c "^node " + grep "script=" por escena. Anotar: nodos + scripts + orphans.')

# 45: .blend vertex (834 in batches of 20 = 42)
blend_files = []
for root, dirs, files in os.walk('tools/mcp/blender-mcp'):
    for f in sorted(files):
        if f.endswith('.blend') and not f.endswith('.blend1'):
            blend_files.append(os.path.join(root, f))
tasks45 = []
for i in range((len(blend_files) + 19) // 20):
    chunk = blend_files[i*20:(i+1)*20]
    tasks45.append('- [ ] T45-%02d: Batch %d-%d - verts + materiales' % (i+1, i*20+1, min((i+1)*20, len(blend_files))))
write_backlog('45-Backlog-BLEND-Vertices.md', 'Blender vertex audit (%d .blend)' % len(blend_files), tasks45,
    'Metodo: python bpy (si Blender MCP) o binario. Anotar: verts + tris + materials. No abrir.')

# 46: .glb size (493 in batches of 20 = 25)
glb_files = []
for root, dirs, files in os.walk(os.path.join(game, 'assets')):
    for f in sorted(files):
        if f.endswith('.glb'):
            glb_files.append(os.path.join(root, f))
tasks46 = []
for i in range((len(glb_files) + 19) // 20):
    chunk = glb_files[i*20:(i+1)*20]
    tasks46.append('- [ ] T46-%02d: Batch %d-%d - size + magic bytes' % (i+1, i*20+1, min((i+1)*20, len(glb_files))))
write_backlog('46-Backlog-GLB-Size.md', 'GLB file size + magic (%d archivos)' % len(glb_files), tasks46,
    'Metodo: ls -la + xxd | head -1. Anotar: size KB + valid GLB? (magic 0x46546C67). No borrar.')

# 47: .png resolution (300 in batches of 20 = 15)
png_files = []
for root, dirs, files in os.walk(os.path.join(game, 'assets')):
    for f in sorted(files):
        if f.endswith('.png'):
            png_files.append(os.path.join(root, f))
tasks47 = []
for i in range((len(png_files) + 19) // 20):
    chunk = png_files[i*20:(i+1)*20]
    tasks47.append('- [ ] T47-%02d: Batch %d-%d - res + BOM + U+FFFD' % (i+1, i*20+1, min((i+1)*20, len(png_files))))
write_backlog('47-Backlog-PNG-Resolution.md', 'PNG resolution + integrity (%d archivos)' % len(png_files), tasks47,
    'Metodo: python PIL (si disponible) o file command. Anotar: WxH + size. Flag >4K.')

# 48: .gd naming (1264 in batches of 30 = 43)
tasks48 = []
for i in range((len(gd_files) + 29) // 30):
    chunk = gd_files[i*30:(i+1)*30]
    tasks48.append('- [ ] T48-%02d: Batch %d-%d - class_name + snake_case' % (i+1, i*30+1, min((i+1)*30, len(gd_files))))
write_backlog('48-Backlog-GD-Naming.md', 'GDScript naming conventions (%d archivos)' % len(gd_files), tasks48,
    'Metodo: grep class_name + grep def para verificar PascalCase/snake_case. Anotar violaciones.')

# 49: .md broken refs (3021 in batches of 30 = 101)
tasks49 = []
for i in range((len(md_files) + 29) // 30):
    chunk = md_files[i*30:(i+1)*30]
    tasks49.append('- [ ] T49-%03d: Batch %d-%d - refs [link](path) resuelven' % (i+1, i*30+1, min((i+1)*30, len(md_files))))
write_backlog('49-Backlog-MD-BrokenRefs.md', 'MD broken references (%d archivos)' % len(md_files), tasks49,
    'Metodo: grep -oP "\\]\\([^)]+\\)" por archivo. Verificar que el target existe. Anotar rotos.')

# 50: Full CHECKLIST-GLOBAL recount (169)
all_mods = []
for d in sorted(os.listdir(base)):
    m = re.match(r'^(\d{2,3})-', d)
    if m:
        all_mods.append((m.group(1), d))
all_mods.sort(key=lambda x: int(x[0]))
tasks50 = []
for i, (mid, modname) in enumerate(all_mods, 1):
    tasks50.append('- [ ] T50-%03d: M%s - recount 3 fuentes' % (i, mid))
write_backlog('50-Backlog-Full-Global-Recount.md', 'Full recount GLOBAL (%d modulos)' % len(all_mods), tasks50,
    'Metodo: grep -cF en 05-Checklist + linea Totales + fila GLOBAL. Reportar drift >5.')

# Update BACKLOG-MASTER
master = os.path.join(backlog_dir, 'BACKLOG-MASTER.md')
with io.open(master, encoding='utf-8') as f:
    content = f.read()
total = tnum + len(tasks42) + len(tasks43) + len(tasks44) + len(tasks45) + len(tasks46) + len(tasks47) + len(tasks48) + len(tasks49) + len(tasks50)
content += '\n## NUEVO 20nov 07:52 (%d tareas)\n' % total
content += '- 41-Backlog-RootCause-Q-Remaining.md (%d)\n' % tnum
content += '- 42-Backlog-GD-Script-TODO.md (%d)\n' % len(tasks42)
content += '- 43-Backlog-MD-Signature.md (%d)\n' % len(tasks43)
content += '- 44-Backlog-TSCN-Nodes.md (%d)\n' % len(tasks44)
content += '- 45-Backlog-BLEND-Vertices.md (%d)\n' % len(tasks45)
content += '- 46-Backlog-GLB-Size.md (%d)\n' % len(tasks46)
content += '- 47-Backlog-PNG-Resolution.md (%d)\n' % len(tasks47)
content += '- 48-Backlog-GD-Naming.md (%d)\n' % len(tasks48)
content += '- 49-Backlog-MD-BrokenRefs.md (%d)\n' % len(tasks49)
content += '- 50-Backlog-Full-Global-Recount.md (%d)\n' % len(tasks50)
with io.open(master, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print('TOTAL: %d tareas (backlogs 41-50)' % total)
