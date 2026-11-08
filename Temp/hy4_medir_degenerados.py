"""Sonda de solo lectura: triángulos degenerados por objeto SM_ en un .blend.

No guarda el .blend. Cuenta, por cada triangulo real:
  - indices de vertice repetidos
  - area < 1e-9
  - lados de longitud cero
Uso: blender.exe -b --factory-startup --python-exit-code 1 --python <script> -- <blend>
"""
import bpy
import os
import sys
from mathutils import Vector

argv = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
if not argv:
    raise SystemExit('FALTA ARG: <blend>')
blend = argv[0]
bpy.ops.wm.open_mainfile(filepath=os.path.abspath(blend))
M = 'HY4_DEG'
print('%s INICIO %s' % (M, blend))

gran_total = 0
for o in sorted([x for x in bpy.data.objects
                 if x.type == 'MESH' and x.name.startswith('SM_')],
                key=lambda x: x.name):
    me = o.data
    me.calc_loop_triangles()
    rep = area0 = lado0 = 0
    areas = []
    for t in me.loop_triangles:
        idx = tuple(t.vertices)
        v = [me.vertices[i].co for i in idx]
        area = (v[1] - v[0]).cross(v[2] - v[0]).length * 0.5
        areas.append(area)
        if len(set(idx)) < 3:
            rep += 1
        if area < 1e-9:
            area0 += 1
        if min((v[1] - v[0]).length, (v[2] - v[0]).length,
               (v[2] - v[1]).length) < 1e-9:
            lado0 += 1
    n = len(me.loop_triangles)
    gran_total += n
    print('%s OBJ %-42s tris=%-5d repetidos=%-4d area0=%-4d lado0=%-4d '
          'area_min=%.3e area_max=%.4f' %
          (M, o.name, n, rep, area0, lado0, min(areas) if areas else -1,
           max(areas) if areas else -1))
print('%s TOTAL_TRIS=%d' % (M, gran_total))
print('%s FIN' % M)
