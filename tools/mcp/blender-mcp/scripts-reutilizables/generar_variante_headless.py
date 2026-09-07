# generar_variante_headless.py - Variantes MEDIA/BAJA sin Blender GUI
#
# PROBLEMA (E-56): `generar_variante.py` es un CLIENTE del socket BlenderMCP
# (127.0.0.1:9876). Si Blender no esta abierto con el addon, falla y no hay
# forma de generar las variantes. Y abrir Blender a mano es una interrupcion
# innecesaria: el merge por material y el decimate son operaciones 100 % de
# `bpy`, no necesitan GUI.
#
# SOLUCION: este wrapper importa `generar_variante` y REEMPLAZA su unica
# llamada de red (`blender_command`, linea 493) por un `exec` local del mismo
# string de codigo. Es decir: se ejecuta EXACTAMENTE el mismo payload que
# ejecutaria el addon, sin red de por medio. El resultado es identico al de la
# via MCP y no hay logica duplicada que mantener.
#
# USO (headless, E-45):
#   blender -b --factory-startup --python generar_variante_headless.py -- \
#       33-Agricultura cultivo_brote_lowpoly --media --baja
#
# Los argumentos despues de `--` son los MISMOS de `generar_variante.py`
# (modulo, blend de ALTA, --media/--baja, --ratio, --max-mats...).
import sys
import os
import json
import math

import bpy
import bmesh
import mathutils

_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, _DIR)

import generar_variante as gv

# Entorno en el que se ejecuta el payload. Debe traer lo que el payload usa:
# el propio payload importa lo suyo, pero bpy/bmesh/mathutils conviene
# inyectarlos porque son los que el addon ya tendria en su contexto.
_ENV = {
    '__builtins__': __builtins__,
    'bpy': bpy,
    'bmesh': bmesh,
    'mathutils': mathutils,
    'os': os,
    'sys': sys,
    'json': json,
    'math': math,
}


def ejecutar_local(type_, params=None, timeout=60):
    """Sustituye a `bpy_cliente.blender_command`: ejecuta el payload aqui."""
    assert type_ == 'execute_code', 'comando inesperado: %r' % type_
    codigo = params['code']
    exec(compile(codigo, '<variante>', 'exec'), _ENV)
    # El payload ya imprime su propio resumen por stdout.
    return {'status': 'success', 'result': {'result': ''}}


def main():
    if '--' in sys.argv:
        argv = sys.argv[sys.argv.index('--') + 1:]
    else:
        argv = sys.argv[1:]
    gv.blender_command = ejecutar_local
    sys.argv = ['generar_variante_headless.py'] + argv
    gv.main()


if __name__ == '__main__':
    main()
