import os, re, glob

base = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
modelo = 'deepseek-v4-flash'
raiz = os.path.join(base, 'DOCUMENTACION', 'TAREAS-POR-MODELO', modelo)

# Módulos asignados a deepseek-v4-flash (Recom en CHECKLIST-GLOBAL)
modulos = [
    '54-Mapa', '87-Localizacion', '101-QA-General', '103-Logging',
    '105-Telemetria-De-Gameplay', '110-Debug-Menu', '115-Hardware', '116-Instalador',
]

os.makedirs(raiz, exist_ok=True)

def extraer_modulo(mod):
    """Extrae las tareas del 05-Checklist.md del módulo."""
    path = os.path.join(base, 'DOCUMENTACION', mod, 'plan-actual', '05-Checklist.md')
    if not os.path.exists(path):
        return [], 0, 0, 0
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    lineas = []
    pendientes = completadas = dudas = 0
    idx = 0
    for line in content.split('\n'):
        m = re.match(r'^- \[ \] (.*)$', line)
        mq = re.match(r'^- \[\?\] (.*)$', line)
        mx = re.match(r'^- \[x\] (.*)$', line)
        if m or mq or mx:
            idx += 1
            tid = f'T-{idx:03d}'
            texto = (m or mq or mx).group(1).strip()
            if m:
                lineas.append(f'- [ ] {tid} {texto}')
                pendientes += 1
            elif mq:
                lineas.append(f'- [?] {tid} {texto}')
                dudas += 1
            else:
                lineas.append(f'- [x] {tid} {texto}')
                completadas += 1
    return lineas, pendientes, completadas, dudas

master = []
master.append('# BACKLOG-MASTER.md — deepseek-v4-flash (Kilo Code)')
master.append('')
master.append('**Creado:** 2026-09-02')
master.append('**Total módulos:** %d' % len(modulos))
master.append('')
master.append('| Módulo | Pendientes | Completadas | Dudas | Total |')
master.append('|---|---|---|---|---|')

total_pend = total_comp = total_dud = total_tareas = 0
for mod in modulos:
    dest_dir = os.path.join(raiz, mod)
    os.makedirs(dest_dir, exist_ok=True)
    lineas, pend, comp, dud = extraer_modulo(mod)
    with open(os.path.join(dest_dir, 'checklist.md'), 'w', encoding='utf-8') as f:
        f.write('# Checklist de tareas — %s (%s / Kilo Code)\n\n' % (mod, modelo))
        f.write('Tareas extraídas del 05-Checklist.md del módulo. IDs T-001 en adelante.\n\n')
        f.write('\n'.join(lineas))
        f.write('\n')
    n = len(lineas)
    total_pend += pend; total_comp += comp; total_dud += dud; total_tareas += n
    master.append('| %s | %d | %d | %d | %d |' % (mod, pend, comp, dud, n))
    print('%s: %d tareas (%d pendientes, %d completadas)' % (mod, n, pend, comp))

master.append('')
master.append('**Total tareas: %d** (pendientes %d, completadas %d, dudas %d)' % (total_tareas, total_pend, total_comp, total_dud))
master.append('')
master.append('## Orden de prioridad (regla §5 de la guía)')
master.append('1. Módulos con núcleo existente (verificación rápida): 103, 105, 87')
master.append('2. Dependencia resuelta: 110 (dep 109✅), 115 (dep 61✅), 116 (dep 117✅), 54 (dep 08✅), 101 (dep 110/112/114)')
master.append('3. Prioridad del módulo: Alta (101), Media (103/104/105/110/115/116/54/87)')

with open(os.path.join(raiz, 'BACKLOG-MASTER.md'), 'w', encoding='utf-8') as f:
    f.write('\n'.join(master))
    f.write('\n')

print('\nBACKLOG-MASTER.md generado. Total tareas: %d' % total_tareas)