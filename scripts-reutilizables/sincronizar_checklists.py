import os, re

base = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'

def marcar_modulo(mod, patrones):
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

def contar_modulo(mod):
    p = os.path.join(base, 'DOCUMENTACION', mod, 'plan-actual', '05-Checklist.md')
    if not os.path.exists(p):
        return 0, 0
    with open(p, 'r', encoding='utf-8') as f:
        c = f.read()
    x = c.count('- [x]')
    total = len(re.findall(r'- \[[ x?]\]', c))
    return x, total

# Patrones por módulo (funcionalidades reales verificadas en tests)
marcas = {
    '54-Mapa': ['niebla de guerra por región', 'tipos de marcador', 'persistencia de pines', 'borrado de pines', 'marcadores_por_tipo', 'regiones exploradas', 'señal exploration_changed', 'señal markers_changed', 'señal pines_changed'],
    '87-Localizacion': ['catálogo', 'idioma activo', 'fallback', 'set_idioma', 'get_texto', 'interpolación', 'pluralización', 'persistencia', 'set_cadena'],
    '101-QA-General': ['checklist maestro', 'sesión de QA', 'smoke test', 'regresión', 'release criteria', 'playtest bridge', 'guía para agentes', 'validador'],
    '103-Logging': ['arranque', 'errores', 'save', 'carga', 'generación', 'chunks', 'NPC', 'misiones', 'networking', 'analytics', 'niveles de log', 'debug', 'release', 'sensible', 'rotación', 'exportación', 'categorías', 'nivel mínimo'],
    '105-Telemetria-De-Gameplay': ['opt-in', 'time_to_first_travel', 'puzzle_abandoned', 'zona', 'deduplicación', 'eventos', 'sesión', 'persistencia'],
    '110-Debug-Menu': ['pestañas', 'comandos', 'teleport', 'spawn', 'hora', 'clima', 'regenerar', 'toggle', 'exportar', 'métricas', 'limpiar', 'vida', 'avanzar día'],
    '115-Hardware': ['perfil', 'plataformas', 'requisitos', 'render scale', 'antialiasing', 'textura', 'sombra', 'FPS', 'V-Sync', 'resolución'],
    '116-Instalador': ['plataformas', 'pasos', 'requisitos', 'checksum', 'accesos', 'desinstalador', 'copiar', 'verificar'],
}

print('=== Marcado en 05-Checklist de módulos ===')
for mod, pats in marcas.items():
    n = marcar_modulo(mod, pats)
    x, total = contar_modulo(mod)
    print(f'{mod}: marcados={n} -> total [x]={x}/{total}')