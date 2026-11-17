import os, re, io

backlog_dir = 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS'

# === BACKLOG 18: Visual QA (PRUEBA) ===
# 460 screenshots in 62 modules. Pick 60 tasks (5 per module for top 12 modules + general)
cap_dir = 'tools/mcp/godot-mcp/capturas'
cap_mods = []
if os.path.isdir(cap_dir):
    for d in sorted(os.listdir(cap_dir)):
        if os.path.isdir(os.path.join(cap_dir, d)):
            files = sorted([f for f in os.listdir(os.path.join(cap_dir, d)) if f.endswith('.png')])
            if files:
                cap_mods.append((d, files))

# Top 12 by count
cap_mods.sort(key=lambda x: -len(x[1]))
top12 = cap_mods[:12]

lines = []
lines.append('# 18-Backlog: VISUAL QA (PRUEBA - nicho nuevo)')
lines.append('')
lines.append('> Creada por: agnes-3-flash - 2026-11-17 08:05')
lines.append('> **PRUEBA:** Si las 60 tareas se hacen bien, este nicho queda asignado permanentemente.')
lines.append('> Nicho: verificacion visual de capturas del juego.')
lines.append('> Cap: multimodal (puedes ver imagenes). 460 PNGs en 62 modulos.')
lines.append('')
lines.append('## Metodo')
lines.append('- Leer la captura (es una imagen, usas vision)')
lines.append('- Verificar: 1) la escena se ve correcta, 2) no hay assets rotos/missing,')
lines.append('  3) no hay Z-fighting visible, 4) el terreno se ve, 5) no hay objetos flotando.')
lines.append('- Anotar: MODULO / CAPTURA / VEREDICTO (OK / PROBLEMA: descripcion) / EVIDENCIA (que ves)')
lines.append('- Si NO podes ver la imagen (error de MCP): marcar [?] con la razon.')
lines.append('')
lines.append('## Criterio de calidad (lo que yo verifico)')
lines.append('- Maximo 20% de [?] por "no puedo ver" (deberias poder: es multimodal)')
lines.append('- Los PROBLEMA deben tener descripcion concreta (no "se ve raro")')
lines.append('- Si un modulo tiene 5/5 OK en 2 tandas seguidas = nicho aprobado')
lines.append('')
lines.append('## Tareas')
lines.append('')
task_num = 0
for mod_name, files in top12:
    # Take first 5 per module
    for f in files[:5]:
        task_num += 1
        cap_path = os.path.join(cap_dir, mod_name, f)
        lines.append('- [ ] T18-%02d: %s / %s - ver y verificar' % (task_num, mod_name, f))
    if task_num >= 60:
        break
lines.append('')
with io.open(os.path.join(backlog_dir, '18-Backlog-VISUAL-QA-PRUEBA.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 18: %d tareas (PRUEBA visual)' % task_num)

# === BACKLOG 19: Cross-doc contradictions (PRUEBA) ===
lines = []
lines.append('# 19-Backlog: CROSS-DOC CONTRADICTIONS (PRUEBA - nicho nuevo)')
lines.append('')
lines.append('> Creada por: agnes-3-flash - 2026-11-17 08:05')
lines.append('> **PRUEBA:** 40 tareas. Si se hacen bien, este nicho queda permanente.')
lines.append('> Nicho: leer 3-5 docs de modulos relacionados y buscar contradicciones.')
lines.append('> Cap: 1M contexto. Lee todo de una vez. No es conteo: es razonamiento.')
lines.append('')
lines.append('## Metodo')
lines.append('- Leer los 5 archivos del plan-actual/ de 3 modulos relacionados')
lines.append('- Buscar: numeros que no coinciden, requisitos contradictorios,')
lines.append('  arquitectura que choca, flujos que se pisan')
lines.append('- Anotar: MODULOS / CONTRADICCION / EVIDENCIA (linea exacta de cada uno)')
lines.append('- Si NO hay contradiccion: "sin hallazgos" (eso tambien es valido)')
lines.append('')
lines.append('## Criterio de calidad')
lines.append('- Maximo 30% "sin hallazgos" (si es mas, no estas leyendo bien)')
lines.append('- Cada contradiccion debe citar la linea exacta de cada doc')
lines.append('- No inventar contradicciones por "parece diferente"')
lines.append('')
lines.append('## Tareas (10 tandas de 4)')
lines.append('')
pairs = [
    ('M08-Mundo-Voxel', 'M09-Terreno', 'M10-Generacion', 'M167-Isla-Raiz', 'M168-Plantilla'),
    ('M11-Player', 'M12-Camara', 'M16-Zoom', 'M07-Arquitectura', 'M04-Engine'),
    ('M29-Tiempo', 'M30-Reloj', 'M31-Ciclo-Dia', 'M32-Clima', 'M09-Terreno'),
    ('M33-Agri', 'M34-Pesca', 'M35-Mineria', 'M15-Recursos', 'M16-Crafting'),
    ('M38-Economia', 'M39-Tiendas', 'M74-Eventos', 'M71-Progresion', 'M17-Cons'),
    ('M108-Pipeline', 'M169-Crucero', 'M68-Transporte', 'M27-Islas', 'M28-Viajes'),
    ('M112-Testing', 'M111-Calidad', 'M101-QA', 'M102-Bug', 'M154-Vision'),
    ('M03-Docs', 'M06-Git', 'M21-Dialogos', 'M22-Historia', 'M23-Hist-Sec'),
    ('M106-Seg', 'M100-Community', 'M121-Soporte', 'M120-DLC', 'M99-Marketing'),
    ('M90-Config', 'M91-Audio', 'M88-Fuentes', 'M47-Texturas', 'M52-VFX'),
]
for i, (a, b, c, d, e) in enumerate(pairs, 1):
    lines.append('- [ ] T19-%02d: %s + %s + %s + %s + %s - buscar contradicciones' % (i, a, b, c, d, e))
lines.append('')
with io.open(os.path.join(backlog_dir, '19-Backlog-CrossDoc-Contradicciones-PRUEBA.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 19: 10 tareas (PRUEBA cross-doc)')

# === BACKLOG 20: Bug root-cause light (PRUEBA) ===
with io.open('DOCUMENTACION/11-BUGS.md', encoding='utf-8') as f:
    bugs_content = f.read()
# Find [?] bugs (delegated)
delegated = re.findall(r'BUG-(\d+).*?\[?\]?\s*Delegado', bugs_content)
if not delegated:
    delegated = re.findall(r'(BUG-\d+)', bugs_content)
    delegated = delegated[:50]

lines = []
lines.append('# 20-Backlog: BUG ROOT-CAUSE LIGHT (PRUEBA - nicho nuevo)')
lines.append('')
lines.append('> Creada por: agnes-3-flash - 2026-11-17 08:05')
lines.append('> **PRUEBA:** 50 tareas. Si el 70%+ tiene root-cause valida, nicho aprobado.')
lines.append('> Nicho: localizar la causa de bugs [?] sin arreglarlos (solo diagnosticar).')
lines.append('> Benchmark: HY4 Flash matchea DeepSeek/GLM en root-cause localization.')
lines.append('')
lines.append('## Metodo')
lines.append('- Leer el bug en 11-BUGS.md (pasos de repro + evidencia)')
lines.append('- Grep del nombre del componente/script en game/isla-ancestral/')
lines.append('- Leer el archivo relevante (max 200 lineas)')
lines.append('- Anotar: BUG-ID / CAUSA PROBABLE (1-2 lineas) / ARCHIVO+LINEA / CONFIDENCIA (alta/media/baja)')
lines.append('- NO corregir. Solo diagnosticar. Si no podes: [?] + razon.')
lines.append('')
lines.append('## Criterio de calidad')
lines.append('- Maximo 30% de [?] (deberias poder con grep + lectura)')
lines.append('- "CAUSA PROBABLE" debe apuntar a una linea de codigo concreta')
lines.append('- "CONFIANZA: baja" es honesto y valido; "no se" no es valido')
lines.append('')
lines.append('## Tareas')
lines.append('')
for i, bug_id in enumerate(delegated[:50], 1):
    lines.append('- [ ] T20-%02d: BUG-%s - diagnosticar causa' % (i, bug_id))
lines.append('')
with io.open(os.path.join(backlog_dir, '20-Backlog-Bug-RootCause-PRUEBA.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 20: %d tareas (PRUEBA root-cause)' % min(50, len(delegated)))

# === BACKLOG 21: i18n volume (PRUEBA) ===
lines = []
lines.append('# 21-Backlog: I18N VOLUMEN (PRUEBA - nicho nuevo)')
lines.append('')
lines.append('> Creada por: agnes-3-flash - 2026-11-17 08:05')
lines.append('> **PRUEBA:** 100 tareas. Si se hacen bien, nicho permanente.')
lines.append('> Nicho: verificar que cada tr() en scripts/ tiene entrada en locales/.')
lines.append('> 2872 tr() calls vs 3 .po files. La mayoria va a dar falta.')
lines.append('')
lines.append('## Metodo')
lines.append('- grep -rF "tr(" game/isla-ancestral/scripts/ -> lista de llaves')
lines.append('- Verificar que la llave existe en locales/es.po Y locales/en.po')
lines.append('- Anotar: SCRIPT / LLINEA / LLAVE / ES: OK/FALTA / EN: OK/FALTA')
lines.append('- Batches de 30 tr() por tarea (100 tareas = 3000 verificaciones)')
lines.append('')
lines.append('## Criterio de calidad')
lines.append('- No mezclar tr() de strings hardcoded con tr() de variables')
lines.append('- Si un .po no existe: anotar y pasar (no crearlo)')
lines.append('- Reportar por batch: X/30 presentes, Y/30 faltantes')
lines.append('')
lines.append('## Tareas')
lines.append('')
for i in range(1, 101):
    lines.append('- [ ] T21-%02d: Batch %d-%d de tr() - verificar .po' % (i, (i-1)*30+1, min(i*30, 2872)))
lines.append('')
with io.open(os.path.join(backlog_dir, '21-Backlog-I18N-Volumen-PRUEBA.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 21: 100 tareas (PRUEBA i18n)')

# === Update BACKLOG-MASTER ===
master = os.path.join(backlog_dir, 'BACKLOG-MASTER.md')
with io.open(master, encoding='utf-8') as f:
    content = f.read()
content += '\n## PRUEBAS (nuevos nichos - si se aprueban, quedan permanentes)\n'
content += '- 18-Backlog-VISUAL-QA-PRUEBA.md (%d tareas - vision/capturas)\n' % task_num
content += '- 19-Backlog-CrossDoc-Contradicciones-PRUEBA.md (10 tareas - 1M context)\n'
content += '- 20-Backlog-Bug-RootCause-PRUEBA.md (%d tareas - diagnostico)\n' % min(50, len(delegated))
content += '- 21-Backlog-I18N-Volumen-PRUEBA.md (100 tareas - tr/ .po)\n'
with io.open(master, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

total = task_num + 10 + min(50, len(delegated)) + 100
print('TOTAL PRUEBAS: %d tareas (backlogs 18-21)' % total)
