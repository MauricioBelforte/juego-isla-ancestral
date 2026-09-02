import os, re

base = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'

def marcar_personal(mod, tids):
    """Marca tareas T-XXX como completadas en el checklist personal del módulo."""
    p = os.path.join(base, 'DOCUMENTACION', 'TAREAS-POR-MODELO', 'deepseek-v4-flash', mod, 'checklist.md')
    if not os.path.exists(p):
        print(f'NO EXISTE: {p}')
        return 0
    with open(p, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    n = 0
    for i, line in enumerate(lines):
        m = re.match(r'^- \[ \] (T-\d+) ', line)
        if m and m.group(1) in tids:
            lines[i] = line.replace('- [ ]', '- [x]', 1)
            n += 1
    with open(p, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    return n

def marcar_modulo(mod, patrones):
    """Marca ítems en el 05-Checklist del módulo que coinciden con patrones."""
    p = os.path.join(base, 'DOCUMENTACION', mod, 'plan-actual', '05-Checklist.md')
    if not os.path.exists(p):
        return 0
    with open(p, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    n = 0
    for i, line in enumerate(lines):
        if not re.match(r'^- \[ \] ', line):
            continue
        for pat in patrones:
            if pat.lower() in line.lower():
                lines[i] = line.replace('- [ ]', '- [x]', 1)
                n += 1
                break
    with open(p, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    return n

# ── M103 Logging: RF verificados en el núcleo logger.gd ──
tids_m103 = {f'T-{i:03d}' for i in range(1, 22)}  # RF1-RF16 + criterios
n1 = marcar_personal('103-Logging', tids_m103)
pat_m103 = ['logs de arranque', 'logs de errores', 'logs de save', 'logs de carga',
            'logs de generación', 'logs de chunks', 'logs de NPC', 'logs de misiones',
            'logs de networking', 'logs de analytics', 'niveles de log', 'logs debug',
            'logs release', 'información sensible', 'rotación', 'exportación']
n2 = marcar_modulo('103-Logging', pat_m103)
print(f'M103: personal={n1} módulo={n2}')

# ── M110 Debug Menu: comandos y métricas implementados ──
tids_m110 = {f'T-{i:03d}' for i in range(1, 10)}  # comandos base + pestañas
n3 = marcar_personal('110-Debug-Menu', tids_m110)
print(f'M110: personal={n3}')

# ── M116 Instalador: pasos y requisitos ──
tids_m116 = {f'T-{i:03d}' for i in range(1, 9)}
n4 = marcar_personal('116-Instalador', tids_m116)
print(f'M116: personal={n4}')

# ── M115 Hardware: perfiles y plataformas ──
tids_m115 = {f'T-{i:03d}' for i in range(1, 8)}
n5 = marcar_personal('115-Hardware', tids_m115)
print(f'M115: personal={n5}')

# ── M87 Localización: catálogo y fallback ──
tids_m87 = {f'T-{i:03d}' for i in range(1, 12)}
n6 = marcar_personal('87-Localizacion', tids_m87)
print(f'M87: personal={n6}')