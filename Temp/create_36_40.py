import io, os, re

backlog_dir = 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS'
base = 'DOCUMENTACION'

# Backlog 36: Bug root-cause top 10 [?] modules
top_q = [('75','87'),('156','82'),('74','58'),('73','56'),('94','49'),
         ('71','44'),('27','40'),('159','37'),('49','33'),('11','32')]

lines = ['# 36-Backlog: Bug Root-Cause [?] Top-10 modulos',
'',
'> Creada por: agnes-3-flash - 2026-11-20 07:47',
'> Nicho: Bug root-cause (aprobado 17nov). 418 [?] en 10 modulos.',
'> Metodo: para cada [?] en 05-Checklist.md: causa + archivo:linea + confianza.',
'']
lines.append('## Tareas')
lines.append('')
task = 0
for mid, q in top_q:
    lines.append('### M%s (%d [?])' % (mid, int(q)))
    lines.append('')
    for i in range(int(q)):
        task += 1
        lines.append('- [ ] T36-%03d: M%s [?]-%d - diagnosticar causa' % (task, mid, i+1))
    lines.append('')
with io.open(os.path.join(backlog_dir, '36-Backlog-RootCause-Q-Markas.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 36: %d tareas' % task)

# Backlog 37: Re-verify 20 drifts after fix
lines = ['# 37-Backlog: Re-verificacion 20 drifts (post-fix GLOBAL)',
'',
'> Creada por: agnes-3-flash - 2026-11-20 07:47',
'> Despues de que la directora fixe los 20 drifts de Beam 628,',
'> re-verificar que el conteo coincide en las 3 fuentes.',
'',
'## Tareas (20 modulos)',
'',
'- [ ] T37-01: M18 - re-contar + comparar GLOBAL + Totales',
'- [ ] T37-02: M26 - re-contar + comparar',
'- [ ] T37-03: M28 - re-contar + comparar',
'- [ ] T37-04: M46 - re-contar + comparar',
'- [ ] T37-05: M50 - re-contar + comparar',
'- [ ] T37-06: M63 - re-contar + comparar',
'- [ ] T37-07: M66 - re-contar + comparar',
'- [ ] T37-08: M69 - re-contar + comparar',
'- [ ] T37-09: M118 - re-contar + comparar',
'- [ ] T37-10: M132 - re-contar + comparar',
'- [ ] T37-11: M137 - re-contar + comparar',
'- [ ] T37-12: M156 - re-contar + comparar',
'- [ ] T37-13: M163 - re-contar + comparar',
'- [ ] T37-14: M169 - re-contar + comparar',
'- [ ] T37-15: M4 - re-contar + comparar',
'- [ ] T37-16: M13 - re-contar + comparar',
'- [ ] T37-17: M15 - re-contar + comparar',
'- [ ] T37-18: M29 - re-contar + comparar',
'- [ ] T37-19: M30 - re-contar + comparar',
'- [ ] T37-20: M33 - re-contar + comparar',
]
with io.open(os.path.join(backlog_dir, '37-Backlog-ReVerificacion-Drifts.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 37: 20 tareas')

# Backlog 38: CI verification
lines = ['# 38-Backlog: CI verde post-fix M169',
'',
'> Creada por: agnes-3-flash - 2026-11-20 07:47',
'> Verificar que el fix 91bd99d dejo CI verde (o reportar lo que queda rojo).',
'',
'## Tareas',
'',
'- [ ] T38-01: godot --headless --check-only en 3 scripts M169 (0 errores)',
'- [ ] T38-02: Boot main_island 300s (0 SCRIPT ERROR de crucero)',
'- [ ] T38-03: Suite test_crucero_manager.gd (13/0)',
'- [ ] T38-04: Suite test_crucero_eventos.gd (6/0)',
'- [ ] T38-05: Suite test_m16_crafting_toast.gd (9/0)',
'- [ ] T38-06: Suite test_mineria.gd (92/0)',
'- [ ] T38-07: Suite test_progresion.gd (83/0)',
'- [ ] T38-08: Suite test_m89_menus.gd (58/0)',
'- [ ] T38-09: Suite test_logros.gd (72/0)',
'- [ ] T38-10: Suite test_bug128_hud_real.gd (18/0)',
'- [ ] T38-11: validate_photo.gd - confirmar si sigue rojo (pre-existente)',
'- [ ] T38-12: merch_validator.gd - confirmar si sigue rojo (pre-existente)',
'- [ ] T38-13: colector_sintaxis.gd - confirmar si sigue rojo (pre-existente)',
'- [ ] T38-14: Resumen: X/14 VERDE, Y/14 ROJO pre-existente',
]
with io.open(os.path.join(backlog_dir, '38-Backlog-CI-Verde.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 38: 14 tareas')

# Backlog 39: Cross-doc round 2
lines = ['# 39-Backlog: Cross-Doc Round 2 (modulos de [?])',
'',
'> Creada por: agnes-3-flash - 2026-11-20 07:47',
'> 10 grupos de 5 modulos con mas [?]. Buscar contradicciones entre',
'> plan-actual y 00-PLAN-INICIAL.',
'',
'## Tareas',
'',
'- [ ] T39-01: M75 + M74 + M73 + M94 + M71 - contradicciones',
'- [ ] T39-02: M27 + M159 + M49 + M11 + M29 - contradicciones',
'- [ ] T39-03: M156 + M15 + M18 + M33 + M30 - contradicciones',
'- [ ] T39-04: M10 + M09 + M08 + M31 + M32 - contradicciones',
'- [ ] T39-05: M34 + M35 + M33 + M16 + M15 - contradicciones',
'- [ ] T39-06: M38 + M39 + M74 + M71 + M17 - contradicciones',
'- [ ] T39-07: M108 + M169 + M68 + M27 + M28 - contradicciones',
'- [ ] T39-08: M112 + M111 + M101 + M102 + M154 - contradicciones',
'- [ ] T39-09: M03 + M06 + M21 + M22 + M23 - contradicciones',
'- [ ] T39-10: M90 + M91 + M88 + M47 + M52 - contradicciones',
]
with io.open(os.path.join(backlog_dir, '39-Backlog-CrossDoc-Round2.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 39: 10 tareas')

# Backlog 40: New visual QA
lines = ['# 40-Backlog: Visual QA Round 2 (nuevas capturas)',
'',
'> Creada por: agnes-3-flash - 2026-11-20 07:47',
'> Verificar capturas nuevas (gpt-luna + M169 re-renders).',
'',
'## Tareas',
'',
'- [ ] T40-01: 10 renders M169 nuevos (camara adentro) - veredicto',
'- [ ] T40-02: 10 capturas gpt-luna (31oct) - veredicto',
'- [ ] T40-03: Capturas M53 UI (HUD + inventario) - veredicto',
'- [ ] T40-04: Capturas M66 inventario - veredicto',
'- [ ] T40-05: Capturas M89 menus - veredicto',
'- [ ] T40-06: Capturas M167 isla raiz - veredicto',
'- [ ] T40-07: Capturas M36 fauna - veredicto',
'- [ ] T40-08: Capturas M42 ambient - veredicto',
'- [ ] T40-09: Capturas M110 debug - veredicto',
'- [ ] T40-10: Capturas M90 config - veredicto',
]
with io.open(os.path.join(backlog_dir, '40-Backlog-Visual-QA-Round2.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')
print('Backlog 40: 10 tareas')

# Update BACKLOG-MASTER
master = os.path.join(backlog_dir, 'BACKLOG-MASTER.md')
with io.open(master, encoding='utf-8') as f:
    content = f.read()
content += '\n## NUEVO 20nov (%d tareas)\n' % (task + 20 + 14 + 10 + 10)
content += '- 36-Backlog-RootCause-Q-Markas.md (%d tareas)\n' % task
content += '- 37-Backlog-ReVerificacion-Drifts.md (20 tareas)\n'
content += '- 38-Backlog-CI-Verde.md (14 tareas)\n'
content += '- 39-Backlog-CrossDoc-Round2.md (10 tareas)\n'
content += '- 40-Backlog-Visual-QA-Round2.md (10 tareas)\n'
with io.open(master, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

total = task + 20 + 14 + 10 + 10
print('TOTAL NUEVAS: %d tareas (backlogs 36-40)' % total)
