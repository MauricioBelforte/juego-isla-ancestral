# verificar_bounds.py — Verificación numérica de un grupo de objetos (V5)
# Uso: python verificar_bounds.py SM_Coco_
# Devuelve cantidad, rango Z (min/max) y rango X/Y de los centros.
# Sirve como QA cuando no se dispone de revisión visual de la captura.
import sys
import os
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command

PREFIJO = sys.argv[1] if len(sys.argv) > 1 else 'SM_'

PLANTILLA = """
import bpy
from mathutils import Vector

# E-24: vertices reales para reportar zmin/zmax honestos. AABB miente en
# rotados (esquinas vacias). El script es informativo (no decide), pero
# el output se lee como dato y debe ser real.
def zmin_real(o):
    if len(o.data.vertices) == 0:
        return min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
    return min((o.matrix_world @ v.co).z for v in o.data.vertices)
def zmax_real(o):
    if len(o.data.vertices) == 0:
        return max((o.matrix_world @ Vector(c)).z for c in o.bound_box)
    return max((o.matrix_world @ v.co).z for v in o.data.vertices)

obs = [o for o in bpy.data.objects if o.type == 'MESH' and o.name.startswith('@@PREF@@')]
if not obs:
    print('SIN OBJETOS con prefijo @@PREF@@')
else:
    zmin = min(zmin_real(o) for o in obs)
    zmax = max(zmax_real(o) for o in obs)
    xs = [o.matrix_world.translation.x for o in obs]
    ys = [o.matrix_world.translation.y for o in obs]
    print('objetos:', len(obs))
    print('z_min:', round(zmin, 3), ' z_max:', round(zmax, 3), ' alto:', round(zmax - zmin, 3))
    print('x_rango:', round(min(xs), 2), '..', round(max(xs), 2),
          '  y_rango:', round(min(ys), 2), '..', round(max(ys), 2))
    solape = any(
        (obs[i].matrix_world.translation - obs[j].matrix_world.translation).length < 0.05
        for i in range(len(obs)) for j in range(i + 1, len(obs)))
    print('centros casi coincidentes (posible duplicado):', solape)
"""

code = PLANTILLA.replace('@@PREF@@', PREFIJO)
r = blender_command('execute_code', {'code': code})
print(json.dumps(r, ensure_ascii=False)[:900])
