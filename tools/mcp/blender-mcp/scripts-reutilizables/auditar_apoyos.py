#!/usr/bin/env python3
# auditar_apoyos.py — Recorre todos los scripts crear_*_lowpoly.py de un
# modulo, los ejecuta contra Blender via MCP y verifica si el/los SM_*
# principales quedan "flotando" (z_min > 0.05 = tope de la arena standard).
#
# Imprime una tabla compacta y deja el ultimo .blend cargado en la escena,
# para que el operador pueda hacer correcciones y volver a auditar.
#
# Uso:
#   python auditar_apoyos.py 15-Recursos
#   python auditar_apoyos.py 50-Vegetacion
import sys
import os
import json
import glob
import re

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command

if len(sys.argv) < 2:
    print(__doc__)
    sys.exit(1)

MODULO = sys.argv[1]
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
DIR_SCRIPTS = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', MODULO, 'scripts')
scripts = sorted(glob.glob(os.path.join(DIR_SCRIPTS, 'crear_*_lowpoly.py')))

if not scripts:
    print('No se encontraron scripts en', DIR_SCRIPTS)
    sys.exit(1)

# Lista de prefijos a auditar dentro de cada asset (los SM_* principales).
# Para los assets que NO tienen un unico SM_* principal sino varios, el
# auditor reporta el z_min de TODOS los SM_ del prefijo conocido.
PREFIJOS_POR_SCRIPT = {
    'crear_palmera_lowpoly.py':         ['SM_Tronco_', 'SM_Corona_', 'SM_Fronda_'],
    'crear_palmera_joven_lowpoly.py':   ['SM_Tronco_Joven', 'SM_Corona_Joven', 'SM_Fronda_Joven_'],
    'crear_palmera_inclinada_lowpoly.py':['SM_Tronco_Inclinado', 'SM_Corona_Incl', 'SM_Fronda_Incl_'],
    'crear_arbusto_redondo_lowpoly.py': ['SM_Arbusto_'],
    'crear_canas_bambu_lowpoly.py':     ['SM_Cana_'],
    'crear_hongo_luminoso_lowpoly.py':  ['SM_Piedra_Hongo', 'SM_Pie_Hongo', 'SM_Capa_Hongo'],
    'crear_flor_isla_lowpoly.py':       ['SM_Tallo_Flor'],
    'crear_roca_lowpoly.py':            ['SM_Roca'],
    'crear_roca_pedernal_lowpoly.py':   ['SM_Roca_Pedernal'],
    'crear_veta_cobre_lowpoly.py':      ['SM_Roca_VetaCobre', 'SM_Cristal_'],
    'crear_tronco_caido_lowpoly.py':    ['SM_Tronco_Caido'],
    'crear_nido_cocos_lowpoly.py':      ['SM_Coco_', 'SM_Nido_Base'],
}

TEMPLATE = """
import bpy
from mathutils import Vector
bpy.context.view_layer.update()
resultados = []
# Z_MAX_BASE: altura maxima esperada de la PIEZA QUE TOCA LA ARENA.
# Cualquier objeto con z_min superior a este umbral no es la base (puede
# ser corona, frondas, sombrero de hongo, cristales, ...) -> no se audita.
Z_MAX_BASE = 0.50
for prefijo in @@PREFS@@:
    obs = [o for o in bpy.data.objects
           if o.type == 'MESH' and o.name.startswith(prefijo)]
    if not obs:
        resultados.append((prefijo, None, None, None, 0, 'NO ENCONTRADO'))
        continue
    zmin = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in obs)
    zmax = max(max((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in obs)
    if zmin > Z_MAX_BASE:
        estado = 'no es base (alto)'
    elif zmin > 0.05:
        estado = 'FLOTA'
    else:
        estado = 'ok'
    resultados.append((prefijo, round(zmin, 3), round(zmax, 3), zmin > 0.05, len(obs), estado))
for r in resultados:
    print(r)
"""

print('Auditando %d scripts en %s' % (len(scripts), MODULO))
print('-' * 78)
print('%-40s %8s %7s  %s' % ('SCRIPT', 'z_min', 'z_max', 'ESTADO'))
print('-' * 78)

for s in scripts:
    nombre = os.path.basename(s)
    try:
        codigo = open(s, 'r', encoding='utf-8').read()
        r = blender_command('execute_code', {'code': codigo})
        if r.get('status') != 'success':
            print('%-40s ERROR: %s' % (nombre, str(r)[:80]))
            continue
    except Exception as e:
        print('%-40s EXCEPCION: %s' % (nombre, e))
        continue

    prefs = PREFIJOS_POR_SCRIPT.get(nombre)
    if not prefs:
        print('%-40s (sin prefijos definidos, skip)' % nombre)
        continue

    code = TEMPLATE.replace('@@PREFS@@', repr(prefs))
    r2 = blender_command('execute_code', {'code': code})
    if r2.get('status') != 'success':
        print('%-40s (no se pudo medir)' % nombre)
        continue
    lineas = [l for l in r2.get('result', {}).get('result', '').splitlines() if l.strip()]
    if not lineas:
        print('%-40s (sin resultados)' % nombre)
        continue
    for ln in lineas:
        try:
            tup = eval(ln)
            prefijo, zmin, zmax, flota, n, estado = tup
            print('%-40s z=%.3f..%.3f (n=%d) %s' % (nombre[:40], zmin, zmax, n, estado))
        except Exception as e:
            print('%-40s parse-fail: %s' % (nombre, ln[:60]))

print('-' * 78)
print('(ultimo .blend quedo cargado en Blender, para correcciones)')
