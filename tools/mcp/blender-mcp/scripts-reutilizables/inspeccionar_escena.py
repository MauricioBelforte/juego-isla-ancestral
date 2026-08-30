#!/usr/bin/env python3
"""
inspeccionar_escena.py — Lista todo lo que hay en la escena activa de Blender.

Sirve para saber, antes de capturar, qué objetos van a entrar en el render:
el set de captura (Base_Arena, SOL, Mundo, CAM_*) NO debe exportarse a Godot
(guia 09 seccion 7), pero si esta presente se ve en las capturas.

Uso:
    python inspeccionar_escena.py
"""
import sys
import os
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command

CODIGO = r'''
import bpy
from mathutils import Vector

esc = bpy.context.scene
print("archivo:", bpy.data.filepath)
print("motor  :", esc.render.engine)
print("objetos:", len(esc.objects))
print()

# z_min global solo de SM_ (lo que se exporta)
sm = [o for o in esc.objects if o.type == 'MESH' and o.name.startswith('SM_')]
if sm:
    zmin = min((o.matrix_world @ Vector(c)).z
               for o in sm for c in o.bound_box)
    tris = sum(len(o.data.loop_triangles) if o.data.loop_triangles else 0
               for o in sm)
    print("SM_ meshes   :", len(sm))
    print("SM_ z_min    : %.4f" % zmin)
    print("SM_ materiales:", len({m.name for o in sm
                                  for m in o.data.materials if m}))
print()

for o in sorted(esc.objects, key=lambda x: x.name):
    tipo = o.type
    bb = [o.matrix_world @ Vector(c) for c in o.bound_box] if tipo == 'MESH' else []
    zmin = min(v.z for v in bb) if bb else 0.0
    zmax = max(v.z for v in bb) if bb else 0.0
    mats = [m.name for m in o.data.materials if m] if tipo == 'MESH' else []
    marca = 'SM' if o.name.startswith('SM_') else ('SET' if (
        o.name.startswith(('Base_', 'SOL', 'Mundo', 'CAM_'))) else 'OTRO')
    print("[%-4s] %-28s z %6.3f..%6.3f  mats=%s" % (
        marca, o.name, zmin, zmax, ','.join(mats) if mats else '-'))
'''


def main():
    r = blender_command('execute_code', {'code': CODIGO}, timeout=60)
    if r.get('status') != 'success':
        print('ERROR:', json.dumps(r, ensure_ascii=False)[:800])
        sys.exit(1)
    print(r.get('result', {}).get('result', '').strip())


if __name__ == '__main__':
    main()
