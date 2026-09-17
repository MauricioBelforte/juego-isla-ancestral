# -*- coding: utf-8 -*-
"""
Extractor de tareas por modelo — DeepSeek-V4.1-Flash / WorkBuddy.

Lee la columna **Recom** de CHECKLIST-GLOBAL.md y arma el backlog personal
del modelo (BACKLOG-MASTER.md + <ID-Modulo>/checklist.md).

Uso:
    python scripts-reutilizables/generar_tareas_deepseek_v41.py --listar
    python scripts-reutilizables/generar_tareas_deepseek_v41.py

Regla de la metodología (AGENTS.md §29 + GUIA-METODOLOGIA.md):
  - mínimo 100 tareas asignadas
  - 1 tarea = 1 ítem verificable, ID T-### secuencial POR MÓDULO
  - fuente de verdad del ítem = el 05-Checklist.md del módulo
"""
import os
import re
import sys

BASE = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
MODELO = 'DeepSeek-V4.1-Flash'
PLATAFORMA = 'WorkBuddy'
PATRON_RECOM = 'deepseek'   # subcadena, case-insensitive
RAIZ = os.path.join(BASE, 'DOCUMENTACION', 'TAREAS-POR-MODELO', MODELO)
CHECKLIST_GLOBAL = os.path.join(BASE, 'CHECKLIST-GLOBAL.md')


def leer(path):
    with open(path, 'r', encoding='utf-8-sig', errors='replace') as f:
        return f.read()


def parsear_global():
    """Devuelve las filas de la tabla de módulos (dict por módulo).

    Normaliza las filas malformadas: varias filas de CHECKLIST-GLOBAL.md tienen
    10 celdas en vez de 11 (les falta la celda 'Agente actual'), lo que desplaza
    todas las columnas siguientes. Se inserta un '' en la posición 8.
    """
    filas = []
    for line in leer(CHECKLIST_GLOBAL).split('\n'):
        if not line.startswith('| '):
            continue
        celdas = [c.strip() for c in line.strip().strip('|').split('|')]
        if len(celdas) < 10:
            continue
        if not re.match(r'^\d+$', celdas[0]):
            continue
        if len(celdas) == 10:          # falta 'Agente actual'
            celdas.insert(8, '')
        filas.append({
            'id': celdas[0],
            'modulo': celdas[1],
            'estado': celdas[2],
            'progreso': celdas[3],
            'prioridad': celdas[4] if celdas[4] in ('Alta', 'Media', 'Baja') else 'Media',
            'complejidad': celdas[5],
            'dependencias': celdas[6],
            'recom': celdas[7],
            'agente': celdas[8],
            'actividad': celdas[9],
            'notas': celdas[10] if len(celdas) > 10 else '',
            'malformada': len(celdas) == 10,
        })
    return filas


def extraer_modulo(nombre_modulo):
    """Extrae los ítems del 05-Checklist.md del módulo."""
    path = os.path.join(BASE, 'DOCUMENTACION', nombre_modulo, 'plan-actual', '05-Checklist.md')
    if not os.path.exists(path):
        return None
    lineas, pend, comp, dud = [], 0, 0, 0
    idx = 0
    for line in leer(path).split('\n'):
        m = re.match(r'^\s*- \[ \] (.*)$', line)
        mq = re.match(r'^\s*- \[\?\] (.*)$', line)
        mx = re.match(r'^\s*- \[x\] (.*)$', line)
        if not (m or mq or mx):
            continue
        idx += 1
        tid = 'T-%03d' % idx
        if m:
            lineas.append('- [ ] %s %s' % (tid, m.group(1).strip()))
            pend += 1
        elif mq:
            lineas.append('- [?] %s %s' % (tid, mq.group(1).strip()))
            dud += 1
        else:
            lineas.append('- [x] %s %s' % (tid, mx.group(1).strip()))
            comp += 1
    return {'path': path, 'lineas': lineas, 'pend': pend, 'comp': comp, 'dud': dud}


def main():
    listar = '--listar' in sys.argv
    filas = parsear_global()
    mias = [f for f in filas if PATRON_RECOM in f['recom'].lower()]

    print('Modulos con Recom ~ "%s": %d' % (PATRON_RECOM, len(mias)))
    print('%-4s %-42s %-34s %-9s %-6s %-4s %-4s' % ('ID', 'Modulo', 'Estado', 'Progreso', 'Prior', 'Cplx', 'Pend'))
    detalle = []
    for f in mias:
        d = extraer_modulo(f['modulo'])
        pend = d['pend'] if d else -1
        detalle.append((f, d))
        print('%-4s %-42s %-34s %-9s %-6s %-4s %-4s' % (
            f['id'], f['modulo'][:42], f['estado'][:34], f['progreso'],
            f['prioridad'], f['complejidad'], pend))

    total_pend = sum(d['pend'] for _, d in detalle if d)
    total_dud = sum(d['dud'] for _, d in detalle if d)
    total = sum(len(d['lineas']) for _, d in detalle if d)
    print('\nTOTAL a trabajar: %d (pendientes [ ] %d + dudas [?] %d)  |  items totales: %d'
          % (total_pend + total_dud, total_pend, total_dud, total))

    if listar:
        return

    os.makedirs(RAIZ, exist_ok=True)
    master = []
    master.append('**Modelo:** %s' % MODELO)
    master.append('**Plataforma:** %s' % PLATAFORMA)
    master.append('')
    master.append('# BACKLOG MASTER — %s' % MODELO)
    master.append('')
    master.append('> Backlog personal según `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`. '
                  'Fuente: columna **Recom** de `CHECKLIST-GLOBAL.md` (patrón `%s`), ítems pendientes `[ ]`/`[?]` '
                  'de los `05-Checklist.md`.' % PATRON_RECOM)
    master.append('')
    master.append('> **Nota de asignación (2026-09-10):** se toman los TRES valores de Recom de la familia '
                  'DeepSeek — `DeepSeek`, `deepseek-v4-flash` y `deepseek-v4-flash-vision-exp` — porque '
                  'DeepSeek **descatalogó** V4 Flash y V4 Flash Vision EXP al lanzar **V4.1 Flash**, que unifica '
                  'texto + visión + agentes en un solo modelo. Los alias viejos se rutean a V4.1 Flash '
                  '(ver `10-GUIA-COMPARATIVA-MODELOS.md` §5.B3 y §17).')
    master.append('')
    master.append('**Módulos asignados:** %d  |  **Tareas a trabajar:** %d (`[ ]` %d + `[?]` %d)'
                  % (len(mias), total_pend + total_dud, total_pend, total_dud))
    master.append('')
    master.append('## Orden de trabajo')
    master.append('')
    master.append('| # | ID | Módulo | Estado global | Progreso | Prioridad | Complejidad | `[ ]` | `[?]` | Subcarpeta |')
    master.append('|---|----|--------|---------------|----------|-----------|-------------|-------|-------|------------|')

    orden = sorted(
        [x for x in detalle if x[1]],
        key=lambda x: (
            {'Alta': 0, 'Media': 1, 'Baja': 2}.get(x[0]['prioridad'], 3),
            int(x[0]['id']),
        ),
    )
    for i, (f, d) in enumerate(orden, 1):
        sub = '%s/checklist.md' % f['modulo']
        master.append('| %d | %s | %s | %s | %s | %s | %s | %d | %d | `%s` |' % (
            i, f['id'], f['modulo'], f['estado'][:34], f['progreso'],
            f['prioridad'], f['complejidad'], d['pend'], d['dud'], sub))
        dest = os.path.join(RAIZ, f['modulo'])
        os.makedirs(dest, exist_ok=True)
        with open(os.path.join(dest, 'checklist.md'), 'w', encoding='utf-8') as fh:
            fh.write('**Modelo:** %s\n' % MODELO)
            fh.write('**Plataforma:** %s\n\n' % PLATAFORMA)
            fh.write('**Módulo:** %s (%s)\n\n' % (f['modulo'], f['id']))
            fh.write('# Checklist personal tareas — %s\n\n' % f['modulo'])
            fh.write('> Extraídas del `05-Checklist.md` del módulo (%d pendientes / %d dudas de %d ítems). '
                     'Fuente de verdad del ítem: el `05-Checklist.md`.\n\n' % (d['pend'], d['dud'], len(d['lineas'])))
            fh.write('## Tareas\n\n')
            fh.write('\n'.join(d['lineas']))
            fh.write('\n')

    master.append('')
    master.append('## Reglas de sincronización (al completar una T-###)')
    master.append('')
    master.append('1. Marcar `[x]` en esta checklist personal (con evidencia: log + test).')
    master.append('2. Marcar el ítem correspondiente en el `05-Checklist.md` del módulo.')
    master.append('3. Actualizar la fila del módulo en `CHECKLIST-GLOBAL.md` (progreso).')
    master.append('')
    master.append('---')
    master.append('')
    master.append('**Creado:** 2026-09-11 por %s / %s' % (MODELO, PLATAFORMA))

    with open(os.path.join(RAIZ, 'BACKLOG-MASTER.md'), 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(master) + '\n')

    print('\nGenerado: %s' % RAIZ)
    print('BACKLOG-MASTER.md + %d subcarpetas' % len(orden))


if __name__ == '__main__':
    main()
