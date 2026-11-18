import io, os

backlog_dir = 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS'
lines = []
lines.append('# 22-Backlog: M154 Visual Checklist + Drift GLOBAL restante')
lines.append('')
lines.append('> Creada por: agnes-3-flash - 2026-11-18 01:55')
lines.append('> Nicho: visual QA (aprobado) + verificacion de conteos')
lines.append('')
lines.append('## Parte A: M154 Visual Checklist (8 tareas - desde tus hallazgos)')
lines.append('')
lines.append('Los 58 problemas que encontraste en la prueba 18. Organizarlos en')
lines.append('DOCUMENTACION/154-Vision-Del-Agente/plan-actual/05-Checklist.md')
lines.append('como nueva seccion "Barrido HY4 Flash 17nov".')
lines.append('')
lines.append('- [ ] T22-01: Crear seccion en 05-Checklist M154')
lines.append('- [ ] T22-02: Agregar 15 capturas inutilizables (splash/negro/IDE) con rutas')
lines.append('- [ ] T22-03: Agregar 19 capsula azul en vez de modelo (rutas + modulo)')
lines.append('- [ ] T22-04: Agregar 5 triangulos verdes flotando (rutas + modulo)')
lines.append('- [ ] T22-05: Agregar 4 HUD tapando inventario (rutas + modulo)')
lines.append('- [ ] T22-06: Agregar 5 franjas horarias indistinguibles (rutas + modulo)')
lines.append('- [ ] T22-07: Agregar terreno blanco / costuras / script error (rutas)')
lines.append('- [ ] T22-08: Agregar demas hallazgos (58 - 53 = 5 restantes)')
lines.append('')
lines.append('## Parte B: Drift GLOBAL re-verificacion (4 tareas)')
lines.append('')
lines.append('Verificar que los drifts que reportaste en backlog 09 esten fixeados')
lines.append('en CHECKLIST-GLOBAL. Si NO lo estan, reportar de nuevo.')
lines.append('')
lines.append('- [ ] T22-09: Verificar M41-M60 drift GLOBAL (10 modulos)')
lines.append('- [ ] T22-10: Verificar M61-M80 drift GLOBAL (10 modulos)')
lines.append('- [ ] T22-11: Verificar M81-M100 drift GLOBAL (10 modulos)')
lines.append('- [ ] T22-12: Verificar M101-M120 drift GLOBAL (10 modulos)')
lines.append('')
with io.open(os.path.join(backlog_dir, '22-Backlog-M154-Visual-Checklist.md'), 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines) + '\n')

master = os.path.join(backlog_dir, 'BACKLOG-MASTER.md')
with io.open(master, encoding='utf-8') as f:
    content = f.read()
content += '- 22-Backlog-M154-Visual-Checklist.md (12 tareas, creada 18nov)\n'
with io.open(master, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print('OK: backlog 22 creado (12 tareas)')
