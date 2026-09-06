#!/usr/bin/env python3
"""Ejecuta nutria_ribera_v2.py en Blender via MCP"""
import sys
sys.stdout.reconfigure(encoding='utf-8')
sys.path.insert(0, r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\scripts-reutilizables')
from bpy_cliente import blender_command

# Limpiar escena
blender_command('execute_code', {'code': 'import bpy; bpy.ops.object.select_all(action="SELECT"); bpy.ops.object.delete()'})

# Leer y ejecutar script
with open(r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\36-Fauna\nutria_ribera_v2.py', 'r', encoding='utf-8') as f:
    code = f.read()

resp = blender_command('execute_code', {'code': code})
print('Script ejecutado')
print(type(resp))
print(str(resp)[:2000])
