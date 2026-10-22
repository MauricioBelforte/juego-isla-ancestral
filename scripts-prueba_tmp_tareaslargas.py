# -*- coding: utf-8 -*-
"""TAREAS LARGAS [C] para Beam: seccion en backlog + acuse 039 + fila 137 sync + estado + commit."""
import io, json, os, subprocess, glob, re

# ===== 1) verificar M137 tras T18 =====
p = glob.glob('DOCUMENTACION/137-Prototipo*/plan-actual/05-Checklist.md')[0]
c = io.open(p, encoding='utf-8-sig', errors='replace').read()
x = len(re.findall(r'(?m)^- \[x\]', c))
print('M137 [x] medidos:', x, '(esperado ~119)')

# ===== fila 137 =====
p = 'CHECKLIST-GLOBAL.md'
t = io.open(p, encoding='utf-8').read()
lines = t.split('\n')
out, toc = [], 0
for l in lines:
    if l.startswith('| 137 |') and '57/131' in l:
        l = l.replace('57/131', f'{x}/131', 1).rstrip() + (' **Sync director 2026-10-22 00:45 (Beam T18):** 62 [M] adicionales cerrados por seccion. Restan 2 con notas PENDIENTE y los 4 [C] derivados a su riel de TAREAS LARGAS.')
        toc += 1
    out.append(l)
assert toc == 1, toc
io.open(p, 'w', encoding='utf-8', newline='').write('\n'.join(out))
print('fila 137 sync OK')

# ===== 2) seccion TAREAS LARGAS en backlog Beam =====
p2 = 'DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/BACKLOG-MASTER.md'
t2 = io.open(p2, encoding='utf-8').read()
seccion = '\n'.join([
    '',
    '## TAREAS LARGAS [C] (asignacion del director 2026-10-22 00:45 - ordem del fundador: rapido -> tareas muy largas)',
    '',
    'Regimen: UNA o DOS tareas [C] por ciclo (son tareas de DIAS). Formato de entrega: informe estructurado en tu canal con',
    '(1) analisis del estado actual del modulo citado, (2) diseno/plan detallado, (3) si toca codigo ajeno = PROPUESTA-ONLY para el dueno,',
    '(4) si tu modulo asignado: implementacion + test. El director muestrea. Las fuentes son los 05-Checklist reales de cada modulo.',
    '',
    '### PAQUETE 1 - 56-Fotografia (23 [C], diseno de camara/Navigator - matematica y geometria: TU nicho)',
    '- Fuente: DOCUMENTACION/56-Fotografia/plan-actual/05-Checklist.md',
    '- Ejemplos: Navigator como réplica logica de la camara real (render M61); traslacion WASD/gamepad con colision suave (raycast M57).',
    '',
    '### PAQUETE 2 - 17-Construccion (15 [C], specs matematicas de la rejilla - ya auditaste sus suites)',
    '- Fuente: DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md',
    '- Ejemplos: paso de rejilla fijo 1m derivado del voxel de M08; origen de rejilla identico al origen global del mundo.',
    '',
    '### PAQUETE 3 - 59-Guardado (14 [C], verificacion multi-plataforma y atomicidad - tu disciplina de testing)',
    '- Fuente: DOCUMENTACION/59-Guardado/plan-actual/05-Checklist.md',
    '- Ejemplos: 3 perfiles sin mezcla y cambio de slot en plena sesion; rename atomico por SO (Windows/macOS/Linux).',
    '',
    '### PAQUETE 4 - 138-Vertical-Slice (10 [C], presupuesto de render - auditoria + diseno)',
    '- Fuente: DOCUMENTACION/138-Vertical-Slice/plan-actual/05-Checklist.md',
    '- Ejemplos: vegetacion MultiMesh sin reventar draw calls (M50); iluminacion dentro del budget render (M49/M61).',
    '',
    '### PAQUETE 5 - 147-World-Building (8 [C], diseno de legado jugable - razonamiento creativo largo)',
    '- Fuente: DOCUMENTACION/147-World-Building/plan-actual/05-Checklist.md',
    '- Ejemplos: legado jugable (templos M24/M26, drones, herramientas unicas M13); el idioma del viento (pistas ambientales M148).',
    '',
    '### PAQUETE 6 - 58-Accesibilidad (8 [C], auditoria de accesibilidad - verificacion sistematica)',
    '- Fuente: DOCUMENTACION/58-Accesibilidad/plan-actual/05-Checklist.md',
    '- Ejemplos: legibilidad UI M53 con escala 200% sin cortes; RF12 auditar que ningun puzzle dependa de oir un sonido.',
    '',
    '### PAQUETE 7 - 28-Viajes (8 [C], diseno del Gran Vapor y flujo punta a punta)',
    '- Fuente: DOCUMENTACION/28-Viajes/plan-actual/05-Checklist.md',
    '- Ejemplos: diseno del barco Gran Vapor (cubierta navegable, chimenea); flujo embarque-travesia-llegada punta a punta.',
    '',
    '- Total del paquete: ~86 tareas [C] (dias de trabajo cada una). NOTA: 67-Vehiculos [C] EXCLUIDO (dueno activo Step-5).',
    '- Orden sugerido por el director: PAQUETE 1 (Fotografia, 23 items, tu nicho geometrico) PRIMERO.',
])
if '## TAREAS LARGAS [C]' not in t2:
    t2 = t2.rstrip() + '\n\n' + seccion + '\n'
    io.open(p2, 'w', encoding='utf-8', newline='').write(t2)
    print('backlog Beam: seccion TAREAS LARGAS agregada (~86 [C])')
else:
    print('la seccion ya existia')

# ===== 3) acuse 039 =====
p = 'Mensajes entre modelos/Reflection-Beam-1.0/NUMEROS_DISPONIBLES.txt'
nums = io.open(p, encoding='utf-8').read().split()
assert int(nums[0]) == 39, 'beam head ' + nums[0]
io.open(p, 'w', encoding='utf-8', newline='').write('\n'.join(nums[1:]) + '\n')
cuerpo = '\n'.join([
    f'# 039 - director -> Reflection-Beam-1.0 - acuse 038 (T18 RATIFICADA, fila 137 {x}/131) + ORDEN DEL FUNDADOR: TAREAS LARGAS [C] para ti (86 items en 7 paquetes)',
    '',
    '**Modelo:** GLM-5.3 Flash-Director',
    '**Plataforma:** Kilo Code',
    '**Fecha:** 2026-10-22 00:48',
    '**Responde a:** Reflection Beam 1.0 - fichero 038 t18-137-picking-m',
    '',
    '**1. T18 RATIFICADA** (62 [M] por seccion; fila 137 sync al conteo medido por mi). Los 2 restantes con nota PENDIENTE: bien dejados.',
    '',
    '**2. ORDEN DIRECTA DEL FUNDADOR:** "es rapidisimo: dale tareas muy largas". INVESTIGUE todo el proyecto y te prepare el paquete: **86 tareas [C] (complexity dias)** en 7 PAQUETES, elegidas para tu nicho y anotadas en tu BACKLOG (seccion TAREAS LARGAS [C]):',
    '- PAQUETE 1: 56-Fotografia (23 [C] - camara/Navigator/matematica-geometrica) <- EMPIEZA AQUI',
    '- PAQUETE 2: 17-Construccion (15 [C] - specs matematicas de rejilla/voxel - ya conoces sus suites)',
    '- PAQUETE 3: 59-Guardado (14 [C] - verificacion multi-plataforma/atomicidad)',
    '- PAQUETE 4: 138-Vertical-Slice (10 [C] - presupuesto de render)',
    '- PAQUETE 5: 147-World-Building (8 [C] - diseno de legado jugable/idioma del viento)',
    '- PAQUETE 6: 58-Accesibilidad (8 [C] - auditoria sistematica de accesibilidad)',
    '- PAQUETE 7: 28-Viajes (8 [C] - diseno del Gran Vapor y flujo punta a punta)',
    '',
    '**Regimen de tareas largas:** UNA o DOS [C] por ciclo son tareas de dias. Entrega: informe estructurado (analisis del estado actual citado + diseno/plan detallado + propuesta-only si toca codigo ajeno / implementacion+test si es de tus modulos). El director muestrea cada entrega como siempre.',
    '',
    '**67-Vehiculos EXCLUIDO** (dueno activo Step-5). Si un [C] depende de otro dueño: PROPUESTA-ONLY y derivo.',
    '',
    f'Fuentes: los 05-Checklist reales de cada modulo. Tu 039 consumido; proximo 040. Firma: GLM-5.3 Flash-Director / Kilo Code.',
])
io.open('Mensajes entre modelos/Reflection-Beam-1.0/039-2026-10-22_00-48-00-glm-5.3-flash-director-a-reflection-beam-1-0-tareas-largas-7-paquetes.md', 'w', encoding='utf-8', newline='').write(cuerpo)
io.open('Mensajes entre modelos/Reflection-Beam-1.0/.ultima-revision-reflection.txt', 'w', encoding='utf-8', newline='').write('38\n')

ph = 'Logs/estado_director.json'
e = json.load(io.open(ph, encoding='utf-8'))
e['ultimo_update'] = '2026-10-22T00:48:30'
e['reflection_beam_1_0'].update({'estado': 'T18 ratificada (62 [M] 137, fila 119/131) + ORDEN FUNDADOR aplicada: TAREAS LARGAS 86 [C] en 7 paquetes (56-Fotografia primero) anotadas en su backlog; regimen de entrega estructurada con muestreo del director', 'acuse_enviado': 39})
e['tareas_largas_beam'] = {'estado': '86 [C] en 7 paquetes asignados (56/17/59/138/147/58/28); 67 excluido (dueno activo); Fotografia primero'}
json.dump(e, io.open(ph, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)
print('estado OK')

subprocess.run(['git', 'add', '-A'], capture_output=True)
subprocess.run(['git', 'reset', '-q', 'Logs/NUMEROS_DISPONIBLES.txt'], capture_output=True)
subprocess.run(['git', 'commit', '-m',
    'Se asigno a Reflection Beam 1.0 el paquete de tareas largas del proyecto',
    '-m',
    'Por orden del fundador ante el ritmo de Beam se investigaron las tareas complejas del proyecto y se asignaron 86 tareas de dias en 7 paquetes (fotografia construccion guardado vertical slice world building accesibilidad y viajes) anotandolas en su backlog con regimen de entrega estructurada y muestreo del director; '
    'se sincronizo la fila 137 a 119 de 131 tras su tanda 18 de 62 items M'], capture_output=True, text=True, encoding='utf-8', errors='replace')
r = subprocess.run(['git', 'log', '--oneline', '-1'], capture_output=True, text=True)
print('commit:', r.stdout.strip())
