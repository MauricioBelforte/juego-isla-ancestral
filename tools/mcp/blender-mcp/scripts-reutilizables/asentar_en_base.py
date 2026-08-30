#!/usr/bin/env python3
# asentar_en_base.py — Baja un grupo de objetos hasta que su z_min mundial
# coincida con un objetivo. Informa la magnitud del movimiento y AVISA si
# el grupo quedo flotando (z_min > 0.05 = tope del disco de arena standard)
# o hundido en exceso (z_min < -0.05).
#
# Uso:
#   python asentar_en_base.py SM_Palmera_Joven [Z_OBJETIVO]
#       Sin Z_OBJETIVO: usa 0.05 (tope de la arena) por defecto.
#
#   python asentar_en_base.py SM_Tronco_Caido 0.08
#       Asienta el tronco con el fondo a z=0.08 (empotrado 3 cm en la arena).
#
# Pensado para re-ejecutarse sobre assets ya creados durante la auditoria de
# "ningun objeto debe verse flotando al rotar la camara" (regla E-12).
import sys
import os
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command

if len(sys.argv) < 2:
    print(__doc__)
    sys.exit(1)

PREFIJO = sys.argv[1]
Z_OBJ = float(sys.argv[2]) if len(sys.argv) > 2 else 0.05

PLANTILLA = """
import bpy
from mathutils import Vector
obs = [o for o in bpy.data.objects
       if o.type == 'MESH' and o.name.startswith('@@PREF@@')]
if not obs:
    print('SIN OBJETOS con prefijo @@PREF@@')
else:
    bpy.context.view_layer.update()
    zmin_actual = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in obs)
    delta = @@Z@@ - zmin_actual
    for o in obs:
        o.location.z += delta
    bpy.context.view_layer.update()
    zmin_nuevo = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in obs)
    if abs(delta) < 1e-4:
        aviso = 'YA ESTABA ASENTADO'
    elif zmin_nuevo > 0.05:
        aviso = 'ATENCION: sigue flotando (z_min > 0.05) tras asentar'
    elif zmin_nuevo < -0.05:
        aviso = 'ATENCION: quedo muy hundido (z_min < -0.05)'
    else:
        aviso = 'OK'
    print('objetos: %d  z_min antes: %.3f  z_min nuevo: %.3f  delta: %+.3f  %s' % (
        len(obs), zmin_actual, zmin_nuevo, delta, aviso))
"""

code = PLANTILLA.replace('@@PREF@@', PREFIJO).replace('@@Z@@', repr(Z_OBJ))
r = blender_command('execute_code', {'code': code})
print(json.dumps(r, ensure_ascii=False)[:700])
