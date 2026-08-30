#!/usr/bin/env python3
# ejecutar_script.py — Ejecuta un script crear_*_lowpoly.py contra Blender via MCP.
#
# Uso:
#   python ejecutar_script.py 16-Crafting crear_hacha_piedra_lowpoly.py
#   python ejecutar_script.py 15-Recursos crear_tronco_caido_lowpoly.py
#
# Imprime el stdout que devuelve Blender (los print() del script).
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command

if len(sys.argv) < 3:
    print(__doc__)
    sys.exit(1)

MODULO = sys.argv[1]
NOMBRE = sys.argv[2]
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
RUTA = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', MODULO, 'scripts', NOMBRE)

if not os.path.exists(RUTA):
    print('NO EXISTE:', RUTA)
    sys.exit(1)

codigo = open(RUTA, 'r', encoding='utf-8').read()
r = blender_command('execute_code', {'code': codigo}, timeout=120)

if r.get('status') != 'success':
    print('ERROR:')
    print(str(r)[:3000])
    sys.exit(2)

salida = r.get('result', {})
if isinstance(salida, dict):
    salida = salida.get('result', '')
print(salida if salida else '(sin salida)')
